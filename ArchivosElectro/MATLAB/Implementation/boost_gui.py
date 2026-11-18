"""Interfaz de referencia y telemetría para una sesión MATLAB existente."""
import json
import math
import queue
import threading
import time
from collections import deque
from pathlib import Path
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import csv
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

ROOT = Path(__file__).resolve().parent
CFG = json.loads((ROOT / 'config.json').read_text())


def validate_reference(text):
    value = float(text.replace(',', '.'))
    if not math.isfinite(value) or not CFG['vmin'] <= value <= CFG['vmax']:
        raise ValueError(f"La referencia debe estar entre {CFG['vmin']} y {CFG['vmax']} V.")
    return value


class Bridge(threading.Thread):
    def __init__(self):
        super().__init__(daemon=True)
        self.commands = queue.Queue()
        self.events = queue.Queue()
        self.halt = threading.Event()

    def run(self):
        eng = None
        while not self.halt.is_set():
            try:
                command, arg = self.commands.get(timeout=CFG['poll_seconds'])
            except queue.Empty:
                command, arg = 'poll', None
            try:
                if command == 'connect':
                    import matlab.engine
                    sessions = matlab.engine.find_matlab()
                    if CFG['session'] not in sessions:
                        raise RuntimeError(f"No se encontró {CFG['session']}. Sesiones: {sessions}. Ejecute boost_prepare en MATLAB.")
                    eng = matlab.engine.connect_matlab(CFG['session'])
                    # Requires the same extracted directory on the local machine.
                    eng.addpath(str(ROOT), nargout=0)
                    packet = json.loads(eng.boost_read())
                    self.events.put(('connected', packet))
                elif command == 'set':
                    if eng is None:
                        raise RuntimeError('Conecte MATLAB primero.')
                    accepted = eng.boost_set_reference(float(arg))
                    self.events.put(('accepted', accepted))
                elif command == 'poll' and eng is not None:
                    self.events.put(('data', json.loads(eng.boost_read())))
            except Exception as exc:
                if command in ('connect', 'poll'):
                    eng = None
                self.events.put(('error', (command, str(exc))))
        # Do not quit the shared MATLAB session or stop the hardware model.


class App:
    def __init__(self, root):
        self.root = root
        root.title('Boost · Referencia y monitoreo')
        root.geometry('1050x760')
        self.bridge = Bridge()
        self.bridge.start()
        self.connected = False
        self.last_data = [None, None]
        self.history = [deque(maxlen=20000), deque(maxlen=20000)]
        self.status = tk.StringVar(value='Desconectado. Inicie Monitor & Tune en MATLAB.')
        self.telemetry = tk.StringVar(value='Vout: —     Duty: —')
        self.accepted = tk.StringVar(value='Última referencia aceptada: —')
        bar = ttk.Frame(root, padding=12); bar.pack(fill='x')
        self.connect_btn = ttk.Button(bar, text='Conectar MATLAB', command=self.connect)
        self.connect_btn.pack(side='left', padx=5)
        ttk.Label(bar, text=f"Referencia ({CFG['vmin']:g}–{CFG['vmax']:g} V):").pack(side='left', padx=8)
        self.value = tk.StringVar(value=str(CFG['vmin']))
        ttk.Entry(bar, textvariable=self.value, width=10).pack(side='left')
        self.apply_btn = ttk.Button(bar, text='Aplicar referencia', command=self.apply, state='disabled')
        self.apply_btn.pack(side='left', padx=8)
        ttk.Button(bar, text='Exportar CSV', command=self.export).pack(side='right')
        ttk.Label(root, textvariable=self.accepted, padding=5).pack(anchor='w')
        ttk.Label(root, textvariable=self.telemetry, padding=5).pack(anchor='w')
        self.fig = Figure(figsize=(9, 5), dpi=100, constrained_layout=True)
        self.axes = self.fig.subplots(2, 1)
        self.lines = []
        for ax, title, color in zip(self.axes, ['Voltaje en la carga (V)', 'Duty comandado (%)'], ['#1976d2', '#e67e22']):
            ax.set_ylabel(title); ax.set_xlabel('Tiempo del modelo (s)'); ax.grid(alpha=.25)
            self.lines.append(ax.plot([], [], color=color, linewidth=1.4)[0])
        self.canvas = FigureCanvasTkAgg(self.fig, master=root)
        self.canvas.get_tk_widget().pack(fill='both', expand=True)
        ttk.Label(root, textvariable=self.status, wraplength=1000, padding=10).pack(fill='x')
        ttk.Label(root, text='Cerrar esta ventana NO detiene el Arduino. Duty mostrado: comando, no medición del PWM.', padding=5).pack()
        root.protocol('WM_DELETE_WINDOW', self.close)
        root.after(150, self.tick)

    def connect(self):
        self.connect_btn.config(state='disabled')
        self.status.set('Conectando a la sesión compartida…')
        self.bridge.commands.put(('connect', None))

    def apply(self):
        try:
            value = validate_reference(self.value.get())
        except ValueError as exc:
            messagebox.showerror('Referencia inválida', str(exc)); return
        self.apply_btn.config(state='disabled')
        self.status.set('Enviando referencia…')
        self.bridge.commands.put(('set', value))

    @staticmethod
    def rows(data):
        if not data:
            return []
        if isinstance(data[0], (int, float)):
            return [data]
        return data

    def ingest(self, packet):
        for i, key in enumerate(('va0', 'duty')):
            rows = self.rows(packet.get(key, []))
            for t, v in rows:
                t, v = float(t), float(v)
                if not (math.isfinite(t) and math.isfinite(v)):
                    continue
                if self.history[i] and t < self.history[i][-1][0]:
                    self.history[i].clear()
                # Keep incoming key 'va0'; scale only the displayed/stored voltage.
                if i == 0:
                    v *= 5.0
                elif i == 1:
                    v *= CFG['duty_scale_to_percent']
                self.history[i].append((t, v))
                self.last_data[i] = time.monotonic()
        self.model_status = packet.get('status', '?')
        self.dropped = packet.get('dropped', 0)

    def tick(self):
        changed = False
        while True:
            try:
                event, data = self.bridge.events.get_nowait()
            except queue.Empty:
                break
            if event == 'connected':
                self.connected = True
                self.apply_btn.config(state='normal')
                self.ingest(data); changed = True
            elif event == 'data':
                self.ingest(data); changed = True
            elif event == 'accepted':
                self.accepted.set(f'Última referencia aceptada por Simulink: {data:g} V')
                self.apply_btn.config(state='normal')
            elif event == 'error':
                command, msg = data
                if command in ('poll', 'connect'):
                    self.connected = False
                    self.connect_btn.config(state='normal')
                    self.apply_btn.config(state='disabled')
                else:
                    self.apply_btn.config(state='normal')
                self.status.set(msg)
                messagebox.showerror('Comunicación / configuración', msg)
        if self.connected:
            stale = [i for i, t in enumerate(self.last_data) if t is None or time.monotonic()-t > 3]
            names = ['Vout (VA0_GUI)', 'duty']
            note = 'Sin datos nuevos de ' + ', '.join(names[i] for i in stale) if stale else 'Recibiendo señales'
            self.status.set(f"Conectado · Modelo: {getattr(self, 'model_status', '?')} · {note} · Muestras descartadas en MATLAB: {getattr(self, 'dropped', 0)}")
        readings = []
        for i, label in enumerate(('Vout', 'Duty')):
            if self.history[i]:
                age = time.monotonic()-self.last_data[i] if self.last_data[i] else float('inf')
                readings.append(f"{label}: {self.history[i][-1][1]:.3f} {'V' if i==0 else '%'}" + (' (dato antiguo)' if age>3 else ''))
            else:
                readings.append(f'{label}: —')
        self.telemetry.set('     '.join(readings))
        if changed:
            for i, ax in enumerate(self.axes):
                if not self.history[i]:
                    continue
                end = self.history[i][-1][0]
                points = [(t,v) for t,v in self.history[i] if t >= end-CFG['plot_seconds']]
                # Bound plotting load; CSV retains the buffered samples.
                stride = max(1, len(points)//3000)
                visible = points[::stride]
                self.lines[i].set_data([p[0] for p in visible], [p[1] for p in visible])
                ax.relim(); ax.autoscale_view()
                ax.set_xlim(max(0, end-CFG['plot_seconds']), max(end, .1))
            self.canvas.draw_idle()
        self.root.after(150, self.tick)

    def export(self):
        name = filedialog.asksaveasfilename(defaultextension='.csv', filetypes=[('CSV', '*.csv')])
        if not name:
            return
        try:
            with open(name, 'w', newline='', encoding='utf-8') as stream:
                writer = csv.writer(stream)
                writer.writerow(['signal', 'time_s', 'value', 'unit'])
                for i, signal in enumerate(('Vout', 'duty_command')):
                    writer.writerows((signal,t,v,'V' if i==0 else '%') for t,v in self.history[i])
        except OSError as exc:
            messagebox.showerror('No se pudo exportar', str(exc))

    def close(self):
        if messagebox.askokcancel('Cerrar interfaz', 'El Arduino seguirá ejecutando el controlador. ¿Cerrar solo esta interfaz?'):
            self.bridge.halt.set()
            self.root.destroy()


if __name__ == '__main__':
    root = tk.Tk()
    App(root)
    root.mainloop()
