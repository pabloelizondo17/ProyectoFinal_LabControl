#ifndef BOOST_MEGA_DAQ_H
#define BOOST_MEGA_DAQ_H
#include "LibraryBase.h"
#include <Arduino.h>
#if !defined(__AVR_ATmega2560__)
#error "BoostDAQMega requires ATmega2560"
#endif
#if F_CPU != 16000000UL
#error "BoostDAQMega requires a 16 MHz clock"
#endif

class BoostDAQMega : public LibraryBase {
    enum { CAPACITY=800, MAX_STAGES=8 };
    uint16_t values[CAPACITY], ticks[CAPACITY];
    uint16_t changes[MAX_STAGES];
    uint16_t count, maxLate;
    byte status;
    bool ready, leased;
    unsigned long leaseStart;
    static uint16_t word(const byte *p) { return uint16_t(p[0]) | (uint16_t(p[1])<<8); }
    static void put(byte *p,uint16_t x) { p[0]=byte(x); p[1]=byte(x>>8); }
    void stopPWM() {
        TCCR2A &= ~(_BV(COM2B1)|_BV(COM2B0));
        PORTH &= ~_BV(PH6);
        leased=false;
    }
    void initHW() {
        pinMode(9,OUTPUT); digitalWrite(9,LOW);
        // Mega D9 = PH6 / OC2B. Timer2 mode 7, TOP=OCR2A.
        // Timer0 remains untouched for micros()/millis() and USB timing.
        TCCR2B=0; TCCR2A=0; TIMSK2=0;
        ASSR=0; TCNT2=0;
        OCR2A=199; OCR2B=0;
        TIFR2=_BV(OCF2A)|_BV(OCF2B)|_BV(TOV2);
        TCCR2A=_BV(WGM21)|_BV(WGM20);
        TCCR2B=_BV(WGM22)|_BV(CS20);
        // AVcc, A0. ADC clock 125 kHz; conversion approx. 104 us.
        ADMUX=_BV(REFS0); ADCSRB=0;
        ADCSRA=_BV(ADEN)|_BV(ADPS2)|_BV(ADPS1)|_BV(ADPS0);
        DIDR0 |= _BV(ADC0D);
        ready=true; stopPWM(); readADC();
    }
    void pwm(byte n) {
        if(n==0) { stopPWM(); return; }
        // Fast PWM non-inverting: high counts = OCR2B+1.
        OCR2B=n-1;
        TCCR2A=_BV(WGM21)|_BV(WGM20)|_BV(COM2B1);
    }
    uint16_t readADC() {
        ADCSRA |= _BV(ADSC);
        while(ADCSRA & _BV(ADSC)) {}
        return ADC;
    }
    bool monitor(unsigned long us, uint16_t cut) {
        unsigned long start=micros();
        do {
            if(readADC()>=cut) { status=1; stopPWM(); return false; }
        } while((unsigned long)(micros()-start)<us);
        return true;
    }
    void replyError(byte cmd,byte e) { sendResponseMsg(cmd,&e,1); }
public:
    BoostDAQMega(MWArduinoClass &a): count(0),maxLate(0),status(0),ready(false),leased(false),leaseStart(0) {
        libName="BoostMega/BoostDAQMega"; a.registerLibrary(this);
    }
    void setup() { pinMode(9,OUTPUT); digitalWrite(9,LOW); }
    void loop() {
        if(leased && (unsigned long)(millis()-leaseStart)>=5000UL) stopPWM();
    }
    void commandHandler(byte cmd,byte *in,unsigned int len) {
        if(cmd==0) { initHW(); byte ok=0; sendResponseMsg(cmd,&ok,1); return; }
        if(!ready) { replyError(cmd,240); return; }
        if(cmd==1) { stopPWM(); byte ok=0; sendResponseMsg(cmd,&ok,1); return; }
        if(cmd==2) {
            if(len!=1 || in[0]>150) { replyError(cmd,241); return; }
            pwm(in[0]); leaseStart=millis(); leased=in[0]!=0;
            byte ok=0; sendResponseMsg(cmd,&ok,1); return;
        }
        if(cmd==4) {
            if(len!=3) { replyError(cmd,241); return; }
            uint16_t first=word(in); byte n=in[2];
            if(n>12 || (uint32_t)first+n>count) { replyError(cmd,241); return; }
            byte out[48];
            for(byte j=0;j<n;j++) { put(out+4*j,values[first+j]); put(out+4*j+2,ticks[first+j]); }
            sendResponseMsg(cmd,out,4*n); return;
        }
        if(cmd!=3 || len<7) { replyError(cmd,241); return; }
        byte K=in[0]; uint16_t ts=word(in+1),cut=word(in+3),settle=word(in+5);
        if(K<1 || K>MAX_STAGES || len!=unsigned(7+3*K) || ts<250 || ts>2000 || cut<1 || cut>1022 || settle>2000) {
            replyError(cmd,241); return;
        }
        uint16_t total=0;
        for(byte j=0;j<K;j++) {
            byte n=in[7+3*j]; uint16_t ns=word(in+8+3*j);
            if(n<100 || n>150 || ns<1 || ns>CAPACITY || uint32_t(total)+ns>CAPACITY) { replyError(cmd,241); return; }
            total+=ns;
        }
        if(uint32_t(total)*ts>240000UL) { replyError(cmd,241); return; }
        stopPWM(); count=0; maxLate=0; status=0;
        for(byte j=0;j<K;j++) changes[j]=65535;
        // Ramp at 0.5 percentage points / 2 ms, then settle at initial duty.
        if(monitor(2000,cut)) {
            for(byte n=1;n<=in[7];n++) { pwm(n); if(!monitor(2000,cut)) break; }
        }
        if(status==0) monitor(uint32_t(settle)*1000UL,cut);
        if(status==0) {
            readADC();
            unsigned long base=micros();
            uint16_t endStage=word(in+8); byte stage=0;
            for(uint16_t i=0;i<total;i++) {
                unsigned long due=base+uint32_t(i)*ts;
                while((long)(micros()-due)<0) {}
                if(i==endStage && stage+1<K) { stage++; endStage+=word(in+8+3*stage); }
                if(i==0 || i==endStage-word(in+8+3*stage)) {
                    changes[stage]=uint16_t((micros()-base)/4);
                    pwm(in[7+3*stage]);
                }
                unsigned long t=micros(); unsigned long late=t-due;
                if(late>maxLate) maxLate=late>65535?65535:uint16_t(late);
                if(late>ts/4) { status=2; break; }
                ticks[count]=uint16_t((t-base)/4);
                values[count]=readADC(); count++;
                if(values[count-1]>=cut) { status=1; break; }
            }
            if(status==0) {
                unsigned long endTime=base+uint32_t(total)*ts;
                while((long)(micros()-endTime)<0) {}
            }
        }
        // Always off before any USB transfer, including partial/aborted captures.
        stopPWM();
        byte out[5+2*MAX_STAGES]; out[0]=status; put(out+1,count); put(out+3,maxLate);
        for(byte j=0;j<K;j++) put(out+5+2*j,changes[j]);
        sendResponseMsg(cmd,out,5+2*K);
    }
};
#endif
