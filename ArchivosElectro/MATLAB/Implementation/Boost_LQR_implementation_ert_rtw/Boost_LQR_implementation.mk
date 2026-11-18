###########################################################################
## Makefile generated for component 'Boost_LQR_implementation'. 
## 
## Makefile     : Boost_LQR_implementation.mk
## Generated on : Wed Nov 18 10:37:50 2026
## Final product: $(RELATIVE_PATH_TO_ANCHOR)/Boost_LQR_implementation.elf
## Product type : executable
## 
###########################################################################

###########################################################################
## MACROS
###########################################################################

# Macro Descriptions:
# PRODUCT_NAME            Name of the system to build
# MAKEFILE                Name of this makefile

PRODUCT_NAME              = Boost_LQR_implementation
MAKEFILE                  = Boost_LQR_implementation.mk
MATLAB_ROOT               = /home/pablo_elizondo17/MATLAB/R2026a
MATLAB_BIN                = /home/pablo_elizondo17/MATLAB/R2026a/bin
MATLAB_ARCH_BIN           = $(MATLAB_BIN)/glnxa64
START_DIR                 = /home/pablo_elizondo17/Desktop/Repositories/ProyectoFinal_LabControl/ArchivosElectro/MATLAB/Implementation
SOLVER                    = 
SOLVER_OBJ                = 
CLASSIC_INTERFACE         = 0
TGT_FCN_LIB               = ISO_C
MODEL_HAS_DYNAMICALLY_LOADED_SFCNS = 0
RELATIVE_PATH_TO_ANCHOR   = ..
SLIB_PATH                 = /home/pablo_elizondo17/Documents/MATLAB/R2026a/ArduinoStaticLibrary/ArduinoMega2560/FasterRuns
SSLIB_PATH                = /home/pablo_elizondo17/Documents/MATLAB/R2026a/ArduinoStaticLibrary/ArduinoMega2560/FasterRuns
C_STANDARD_OPTS           = 
CPP_STANDARD_OPTS         = 

###########################################################################
## TOOLCHAIN SPECIFICATIONS
###########################################################################

# Toolchain Name:          Arduino AVR
# Supported Version(s):    
# ToolchainInfo Version:   2026a
# Specification Revision:  1.0
# 
#-------------------------------------------
# Macros assumed to be defined elsewhere
#-------------------------------------------

# ARDUINO_ROOT
# ARDUINO_PORT
# ARDUINO_MCU
# ARDUINO_BAUD
# ARDUINO_PROTOCOL
# ARDUINO_F_CPU

#-----------
# MACROS
#-----------

PRODUCT_HEX      = $(RELATIVE_PATH_TO_ANCHOR)/$(PRODUCT_NAME).hex
PRODUCT_BIN      = $(RELATIVE_PATH_TO_ANCHOR)/$(PRODUCT_NAME).eep
ARDUINO_TOOLS    = $(ARDUINO_AVR_ROOT)/tools/avr-gcc/$(AVR_GCC_LIB_VERSION)/bin
ELF2EEP_OPTIONS  = -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0
DOWNLOAD_ARGS    =  >tmp.trash 2>&1 -P$(ARDUINO_PORT) -V -q -q -q -q -F -C$(ARDUINO_ROOT)/hardware/tools/avr/etc/avrdude.conf -p$(ARDUINO_MCU) -c$(ARDUINO_PROTOCOL) -b$(ARDUINO_BAUD) -D -Uflash:w:

TOOLCHAIN_SRCS = 
TOOLCHAIN_INCS = 
TOOLCHAIN_LIBS = -lm -lcore

FORMAT_FOR_ECHO_SH               = ""'$1'
FORMAT_FOR_ECHO                  = $(FORMAT_FOR_ECHO_SH)
HASH                             = \#
SEMICOLON                        = ;
OPEN_PAREN                       = (
CLOSE_PAREN                      = )
ESCAPE_SPECIAL_CHARS             = $(strip $(subst $(CLOSE_PAREN),\$(CLOSE_PAREN),\
	$(subst $(OPEN_PAREN),\$(OPEN_PAREN),\
	$(subst &,\&,\
	$(subst ~,\~,\
	$(subst ?,\?,\
	$(subst *,\*,\
	$(subst },\},\
	$(subst {,\{,\
	$(subst >,\>,\
	$(subst <,\<,\
	$(subst !,\!,\
	$(subst ],\],\
	$(subst [,\[,\
	$(subst $(HASH),\$(HASH),\
	$(subst \\,\\\,\
	$(subst ',\',\
	$(subst ",\",\
	$1))))))))))))))))))

#------------------------
# BUILD TOOL COMMANDS
#------------------------

# Assembler: Arduino AVR Assembler
AS_PATH = $(ARDUINO_TOOLS)
AS = "$(AS_PATH)/avr-gcc"

# C Compiler: Arduino AVR C Compiler
CC_PATH = $(ARDUINO_TOOLS)
CC = "$(CC_PATH)/avr-gcc"

# Linker: Arduino AVR Linker
LD_PATH = $(ARDUINO_TOOLS)
LD = "$(LD_PATH)/avr-gcc"

# C++ Compiler: Arduino AVR C++ Compiler
CPP_PATH = $(ARDUINO_TOOLS)
CPP = "$(CPP_PATH)/avr-g++"

# C++ Linker: Arduino AVR C++ Linker
CPP_LD_PATH = $(ARDUINO_TOOLS)
CPP_LD = "$(CPP_LD_PATH)/avr-gcc"

# Archiver: Arduino AVR Archiver
AR_PATH = $(ARDUINO_TOOLS)
AR = "$(AR_PATH)/avr-ar"

# MEX Tool: MEX Tool
MEX_PATH = $(MATLAB_ARCH_BIN)
MEX = "$(MEX_PATH)/mex"

# Binary Converter: Binary Converter
OBJCOPY_PATH = $(ARDUINO_TOOLS)
OBJCOPY = "$(OBJCOPY_PATH)/avr-objcopy"

# Hex Converter: Hex Converter
OBJCOPY_PATH = $(ARDUINO_TOOLS)
OBJCOPY = "$(OBJCOPY_PATH)/avr-objcopy"

# Download: Download
DOWNLOAD_PATH = $(ARDUINO_TOOLS)
DOWNLOAD = "$(DOWNLOAD_PATH)/avrdude"

# Execute: Execute
EXECUTE = $(PRODUCT)

# Builder: Make Tool
MAKE_PATH = %MATLAB%/bin/glnxa64
MAKE = "$(MAKE_PATH)/gmake"


#-------------------------
# Directives/Utilities
#-------------------------

ASDEBUG             = -g
AS_OUTPUT_FLAG      = -o
CDEBUG              = -g
C_OUTPUT_FLAG       = -o
LDDEBUG             = -g
OUTPUT_FLAG         = -o
CPPDEBUG            = -g
CPP_OUTPUT_FLAG     = -o
CPPLDDEBUG          = -g
OUTPUT_FLAG         = -o
ARDEBUG             =
STATICLIB_OUTPUT_FLAG =
MEX_DEBUG           = -g
RM                  =
ECHO                = echo
MV                  =
RUN                 =

#----------------------------------------
# "Faster Builds" Build Configuration
#----------------------------------------

MEX_CPPFLAGS         =
MEX_CPPLDFLAGS       =
MEX_CFLAGS           =
MEX_LDFLAGS          =



#---------------------------
# Model-Specific Options
#---------------------------

ASFLAGS = -MMD -MP -MF"$(@:%.o=%.dep)" -MT"$@"  -Wall -x assembler-with-cpp $(ASFLAGS_ADDITIONAL) $(DEFINES) $(INCLUDES) -c

CFLAGS = -std=gnu11  -c -w -ffunction-sections -fdata-sections  -MMD -DARDUINO=10801  -MMD -MP -MF"$(@:%.o=%.dep)" -MT"$@"  -Os -g

LDFLAGS = -w -Os -Wl,--gc-sections,--relax -g

SHAREDLIB_LDFLAGS = -g

CPPFLAGS = -std=gnu++11 -fpermissive -fno-exceptions -fno-threadsafe-statics  -c -w -ffunction-sections -fdata-sections  -MMD -DARDUINO=10801  -MMD -MP -MF"$(@:%.o=%.dep)" -MT"$@"  -Os -g

CPP_LDFLAGS = -w -Os -Wl,--gc-sections,--relax -g

CPP_SHAREDLIB_LDFLAGS = -g

ARFLAGS = rcs

OBJCOPYFLAGS_BIN = $(ELF2EEP_OPTIONS) $(PRODUCT) $(PRODUCT_BIN)

OBJCOPYFLAGS_HEX = -O ihex -R .eeprom $(PRODUCT) $(PRODUCT_HEX)

DOWNLOAD_FLAGS = $(DOWNLOAD_ARGS)$(PRODUCT_HEX):i

EXECUTE_FLAGS = 

MAKE_FLAGS = -f $(MAKEFILE)

###########################################################################
## OUTPUT INFO
###########################################################################

PRODUCT = $(RELATIVE_PATH_TO_ANCHOR)/Boost_LQR_implementation.elf
PRODUCT_TYPE = "executable"
BUILD_TYPE = "Top-Level Standalone Executable"

###########################################################################
## INCLUDE PATHS
###########################################################################

INCLUDES_BUILDINFO = -I$(START_DIR)/slprj/ert/Controlador_LQR_implementation -I$(START_DIR) -I$(MATLAB_ROOT)/toolbox/target/shared/svd/common/include -I/home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/include -I$(START_DIR)/Boost_LQR_implementation_ert_rtw -I$(MATLAB_ROOT)/extern/include -I$(MATLAB_ROOT)/simulink/include -I$(MATLAB_ROOT)/rtw/c/src -I$(MATLAB_ROOT)/rtw/c/src/ext_mode/common -I$(MATLAB_ROOT)/rtw/c/ert -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/include -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src -I$(MATLAB_ROOT)/toolbox/coder/rtiostream/src -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/include -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/common -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/include -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/include -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/include -I$(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/default -I$(START_DIR)/slprj/ert/_sharedutils -I$(ARDUINO_AVR_ROOT)/hardware/avr/$(AVR_LIB_VERSION)/cores/arduino -I$(ARDUINO_AVR_ROOT)/hardware/avr/$(AVR_LIB_VERSION)/variants/mega -I/home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/include -I/home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/scheduler/include -I$(ARDUINO_AVR_ROOT)/tools/avr-gcc/$(AVR_GCC_LIB_VERSION)/avr/include

INCLUDES = $(INCLUDES_BUILDINFO)

###########################################################################
## DEFINES
###########################################################################

DEFINES_ = -DXCP_ADDRESS_GRANULARITY=XCP_ADDRESS_GRANULARITY_BYTE -DCODERTARGET_XCP_DAQ_PACKED_MODE -DCODERTARGET_XCP_MAX_CONTIGUOUS_SAMPLES=2 -D__MW_TARGET_USE_HARDWARE_RESOURCES_H__ -DMW_TIMERID=5 -DMW_PRESCALAR=8 -DMW_TIMERCOUNT=65036 -DMW_SCHEDULERCOUNTER=1 -DARDUINO_NUM_SERIAL_PORTS=4 -DARDUINO_SERIAL_RECEIVE_BUFFER_SIZE=64 -D_RTT_BAUDRATE_SERIAL0_=9600 -D_RTT_BAUDRATE_SERIAL1_=9600 -D_RTT_BAUDRATE_SERIAL2_=9600 -D_RTT_BAUDRATE_SERIAL3_=9600 -D_RTT_CONFIG_SERIAL0_=SERIAL_8N1 -D_RTT_CONFIG_SERIAL1_=SERIAL_8N1 -D_RTT_CONFIG_SERIAL2_=SERIAL_8N1 -D_RTT_CONFIG_SERIAL3_=SERIAL_8N1 -D_RTT_ANALOG_REF_=0 -DMW_RTIO_SERIAL0 -DMW_NUM_PINS=70 -D_RTT_PWM_BLOCKS_ -D_RTT_PWM_CUSTOM_FREQUENCY_ -D_ONBOARD_EEPROM_SIZE_=4096
DEFINES_BUILD_ARGS = -DCLASSIC_INTERFACE=0 -DALLOCATIONFCN=0 -DTERMFCN=1 -DONESTEPFCN=1 -DMAT_FILE=0 -DMULTI_INSTANCE_CODE=0 -DEXT_MODE=1 -DINTEGER_CODE=0 -DMT=0
DEFINES_CUSTOM = 
DEFINES_OPTS = -DXCP_EXTMODE_SIMULATION_TIME_IN_TICKS -DXCP_MEM_BLOCK_1_SIZE=32 -DXCP_MEM_BLOCK_1_NUMBER=1 -DXCP_MEM_BLOCK_2_SIZE=56 -DXCP_MEM_BLOCK_2_NUMBER=1 -DXCP_MEM_BLOCK_3_SIZE=32 -DXCP_MEM_BLOCK_3_NUMBER=1 -DXCP_MEM_RESERVED_POOLS_TOTAL_SIZE=445 -DXCP_MEM_RESERVED_POOLS_NUMBER=2 -DXCP_MEM_DAQ_RESERVED_POOL_BLOCKS_NUMBER=3 -DXCP_MEM_DAQ_RESERVED_POOLS_NUMBER=1 -DXCP_MIN_EVENT_NO_RESERVED_POOL=1 -DXCP_MAX_CTO_SIZE=32 -DXCP_MAX_DTO_SIZE=65532 -DXCP_MAX_ODT_ENTRY_SIZE=255 -DEXTMODE_XCP_TRIGGER_SUPPORT -DXCP_TIMESTAMP_BASED_ON_SIMULATION_TIME -DON_TARGET_WAIT_FOR_START=1 -DXCP_DAQ_SUPPORT -DXCP_CALIBRATION_SUPPORT -DXCP_TIMESTAMP_SUPPORT -DXCP_SET_MTA_SUPPORT -DTID01EQ=0
DEFINES_SKIPFORSIL = -DXCP_CUSTOM_PLATFORM -DEXIT_FAILURE=1 -DEXTMODE_DISABLEPRINTF -DEXTMODE_DISABLETESTING -DEXTMODE_DISABLE_ARGS_PROCESSING=1 -DSTACK_SIZE=64 -DRT
DEFINES_STANDARD = -DMODEL=Boost_LQR_implementation -DNUMST=1 -DNCSTATES=0 -DHAVESTDIO -DMODEL_HAS_DYNAMICALLY_LOADED_SFCNS=0

DEFINES = $(DEFINES_) $(DEFINES_BUILD_ARGS) $(DEFINES_CUSTOM) $(DEFINES_OPTS) $(DEFINES_SKIPFORSIL) $(DEFINES_STANDARD)

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/MW_AnalogInput.cpp /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/ArduinoPinHandleMap.cpp /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/MW_PWM.cpp /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/MW_PWMDriver.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/xcp_ext_mode.c $(START_DIR)/Boost_LQR_implementation_ert_rtw/Boost_LQR_implementation.c $(START_DIR)/Boost_LQR_implementation_ert_rtw/Boost_LQR_implementation_data.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/xcp_ext_common.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/xcp_ext_classic_trigger.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/xcp_ext_param_default_serial.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/xcp.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/xcp_standard.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/xcp_daq.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/xcp_calibration.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/xcp_fifo.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/xcp_transport.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/default/xcp_mem_default.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/default/xcp_drv_rtiostream.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/common/xcp_utils.c $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/xcp_frame_serial.c /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/src/MW_ArduinoHWInit.cpp /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/io_wrappers.cpp /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/src/platform_timer.cpp /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/src/rtiostream_serial_daemon.cpp /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/scheduler/src/arduinoAVRScheduler.cpp

MAIN_SRC = $(START_DIR)/Boost_LQR_implementation_ert_rtw/ert_main.c

ALL_SRCS = $(SRCS) $(MAIN_SRC)

###########################################################################
## OBJECTS
###########################################################################

OBJS = MW_AnalogInput.o ArduinoPinHandleMap.o MW_PWM.o MW_PWMDriver.o xcp_ext_mode.o Boost_LQR_implementation.o Boost_LQR_implementation_data.o xcp_ext_common.o xcp_ext_classic_trigger.o xcp_ext_param_default_serial.o xcp.o xcp_standard.o xcp_daq.o xcp_calibration.o xcp_fifo.o xcp_transport.o xcp_mem_default.o xcp_drv_rtiostream.o xcp_utils.o xcp_frame_serial.o MW_ArduinoHWInit.o io_wrappers.o platform_timer.o rtiostream_serial_daemon.o arduinoAVRScheduler.o

MAIN_OBJ = ert_main.o

ALL_OBJS = $(OBJS) $(MAIN_OBJ)

###########################################################################
## PREBUILT OBJECT FILES
###########################################################################

PREBUILT_OBJS = 

###########################################################################
## LIBRARIES
###########################################################################

MODELREF_LIBS = ../slprj/ert/Controlador_LQR_implementation/Controlador_LQR_implementation_rtwlib.a

LIBS = $(START_DIR)/slprj/ert/_sharedutils/rtwshared.a $(SSLIB_PATH)/MW_RebuildSrc_Core.o

###########################################################################
## SYSTEM LIBRARIES
###########################################################################

SYSTEM_LIBS = 

###########################################################################
## ADDITIONAL TOOLCHAIN FLAGS
###########################################################################

#---------------
# C Compiler
#---------------

CFLAGS_SKIPFORSIL = -mmcu=atmega2560 -DF_CPU=16000000L -DARDUINO_AVR_MEGA2560 -DARDUINO_ARCH_AVR -D_RUNONTARGETHARDWARE_BUILD_ -D_ROTH_MEGA2560_ -DARDUINO_NUM_SERIAL_PORTS=4
CFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CFLAGS += $(CFLAGS_SKIPFORSIL) $(CFLAGS_BASIC)

#-----------
# Linker
#-----------

LDFLAGS_ = -L"$(SLIB_PATH)"
LDFLAGS_SKIPFORSIL = -mmcu=atmega2560 

LDFLAGS += $(LDFLAGS_) $(LDFLAGS_SKIPFORSIL)

#--------------------------
# Shared Library Linker
#--------------------------

SHAREDLIB_LDFLAGS_ = -L"$(SLIB_PATH)"
SHAREDLIB_LDFLAGS_SKIPFORSIL = -mmcu=atmega2560 

SHAREDLIB_LDFLAGS += $(SHAREDLIB_LDFLAGS_) $(SHAREDLIB_LDFLAGS_SKIPFORSIL)

#-----------------
# C++ Compiler
#-----------------

CPPFLAGS_SKIPFORSIL = -mmcu=atmega2560 -DF_CPU=16000000L -DARDUINO_AVR_MEGA2560 -DARDUINO_ARCH_AVR -D_RUNONTARGETHARDWARE_BUILD_ -D_ROTH_MEGA2560_ -DARDUINO_NUM_SERIAL_PORTS=4
CPPFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CPPFLAGS += $(CPPFLAGS_SKIPFORSIL) $(CPPFLAGS_BASIC)

#---------------
# C++ Linker
#---------------

CPP_LDFLAGS_ = -L"$(SLIB_PATH)"
CPP_LDFLAGS_SKIPFORSIL = -mmcu=atmega2560 

CPP_LDFLAGS += $(CPP_LDFLAGS_) $(CPP_LDFLAGS_SKIPFORSIL)

#------------------------------
# C++ Shared Library Linker
#------------------------------

CPP_SHAREDLIB_LDFLAGS_ = -L"$(SLIB_PATH)"
CPP_SHAREDLIB_LDFLAGS_SKIPFORSIL = -mmcu=atmega2560 

CPP_SHAREDLIB_LDFLAGS += $(CPP_SHAREDLIB_LDFLAGS_) $(CPP_SHAREDLIB_LDFLAGS_SKIPFORSIL)

###########################################################################
## INLINED COMMANDS
###########################################################################


DERIVED_SRCS = $(subst .o,.dep,$(OBJS))

build:

%.dep:



-include arduino_macros.mk
-include codertarget_assembly_flags.mk
-include *.dep


###########################################################################
## PHONY TARGETS
###########################################################################

.PHONY : all build buildobj clean info prebuild postbuild download execute


all : build postbuild
	echo $(call FORMAT_FOR_ECHO,### Successfully generated all binary outputs.)


build : prebuild $(PRODUCT)


buildobj : prebuild $(OBJS) $(PREBUILT_OBJS) $(LIBS)
	echo $(call FORMAT_FOR_ECHO,### Successfully generated all binary outputs.)


prebuild : 


postbuild : $(PRODUCT)
	echo $(call FORMAT_FOR_ECHO,### Invoking postbuild tool Binary Converter ...)
	$(OBJCOPY) $(OBJCOPYFLAGS_BIN)
	echo $(call FORMAT_FOR_ECHO,### Done invoking postbuild tool.)
	echo $(call FORMAT_FOR_ECHO,### Invoking postbuild tool Hex Converter ...)
	$(OBJCOPY) $(OBJCOPYFLAGS_HEX)
	echo $(call FORMAT_FOR_ECHO,### Done invoking postbuild tool.)


download : postbuild
	echo $(call FORMAT_FOR_ECHO,### Invoking postbuild tool Download ...)
	$(DOWNLOAD) $(DOWNLOAD_FLAGS)
	echo $(call FORMAT_FOR_ECHO,### Done invoking postbuild tool.)


execute : download
	echo $(call FORMAT_FOR_ECHO,### Invoking postbuild tool Execute ...)
	$(EXECUTE) $(EXECUTE_FLAGS)
	echo $(call FORMAT_FOR_ECHO,### Done invoking postbuild tool.)


###########################################################################
## FINAL TARGET
###########################################################################

#-------------------------------------------
# Create a standalone executable            
#-------------------------------------------

$(PRODUCT) : $(OBJS) $(PREBUILT_OBJS) $(MODELREF_LIBS) $(LIBS) $(MAIN_OBJ)
	echo $(call FORMAT_FOR_ECHO,### Creating standalone executable "$(PRODUCT)" ...)
	$(CPP_LD) $(CPP_LDFLAGS) -o $(PRODUCT) $(OBJS) $(MAIN_OBJ) ../slprj/ert/Controlador_LQR_implementation/Controlador_LQR_implementation_rtwlib.a $(LIBS) $(SYSTEM_LIBS) $(TOOLCHAIN_LIBS)
	echo $(call FORMAT_FOR_ECHO,### Created: "$(PRODUCT)")


###########################################################################
## INTERMEDIATE TARGETS
###########################################################################

#---------------------
# SOURCE-TO-OBJECT
#---------------------

%.o : %.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : %.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : %.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : %.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(RELATIVE_PATH_TO_ANCHOR)/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(RELATIVE_PATH_TO_ANCHOR)/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(START_DIR)/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(START_DIR)/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/Boost_LQR_implementation_ert_rtw/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/Boost_LQR_implementation_ert_rtw/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(START_DIR)/Boost_LQR_implementation_ert_rtw/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(START_DIR)/Boost_LQR_implementation_ert_rtw/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/rtw/c/src/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/rtw/c/src/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/rtw/c/src/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/rtw/c/src/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/simulink/src/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/simulink/src/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/simulink/src/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/simulink/src/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/simulink/blocks/src/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/simulink/blocks/src/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/simulink/blocks/src/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/simulink/blocks/src/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/common/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/common/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/common/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/common/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/default/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/default/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/default/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.S.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/default/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


MW_AnalogInput.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/MW_AnalogInput.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


ArduinoPinHandleMap.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/ArduinoPinHandleMap.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


MW_PWM.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/MW_PWM.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


MW_PWMDriver.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/MW_PWMDriver.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_ext_mode.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/xcp_ext_mode.c
	$(CC) $(CFLAGS) -o "$@" "$<"


Boost_LQR_implementation.o : $(START_DIR)/Boost_LQR_implementation_ert_rtw/Boost_LQR_implementation.c
	$(CC) $(CFLAGS) -o "$@" "$<"


Boost_LQR_implementation_data.o : $(START_DIR)/Boost_LQR_implementation_ert_rtw/Boost_LQR_implementation_data.c
	$(CC) $(CFLAGS) -o "$@" "$<"


ert_main.o : $(START_DIR)/Boost_LQR_implementation_ert_rtw/ert_main.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_ext_common.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/xcp_ext_common.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_ext_classic_trigger.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/xcp_ext_classic_trigger.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_ext_param_default_serial.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/ext_mode/src/xcp_ext_param_default_serial.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/xcp.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_standard.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/xcp_standard.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_daq.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/xcp_daq.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_calibration.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/protocol/src/xcp_calibration.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_fifo.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/xcp_fifo.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_transport.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/xcp_transport.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_mem_default.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/default/xcp_mem_default.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_drv_rtiostream.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/platform/default/xcp_drv_rtiostream.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_utils.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/common/xcp_utils.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xcp_frame_serial.o : $(MATLAB_ROOT)/toolbox/coder/xcp/src/target/server/transport/src/xcp_frame_serial.c
	$(CC) $(CFLAGS) -o "$@" "$<"


MW_ArduinoHWInit.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/src/MW_ArduinoHWInit.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


io_wrappers.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinobase/src/io_wrappers.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


platform_timer.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/src/platform_timer.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


rtiostream_serial_daemon.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/src/rtiostream_serial_daemon.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


arduinoAVRScheduler.o : /home/pablo_elizondo17/Documents/MATLAB/SupportPackages/R2026a/toolbox/target/supportpackages/arduinotarget/scheduler/src/arduinoAVRScheduler.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


###########################################################################
## DEPENDENCIES
###########################################################################

$(ALL_OBJS) : rtw_proj.tmw $(MAKEFILE)


###########################################################################
## MISCELLANEOUS TARGETS
###########################################################################

info : 
	echo $(call FORMAT_FOR_ECHO,### PRODUCT = $(PRODUCT))
	echo $(call FORMAT_FOR_ECHO,### PRODUCT_TYPE = $(PRODUCT_TYPE))
	echo $(call FORMAT_FOR_ECHO,### BUILD_TYPE = $(BUILD_TYPE))
	echo $(call FORMAT_FOR_ECHO,### INCLUDES = $(INCLUDES))
	echo $(call FORMAT_FOR_ECHO,### DEFINES = $(DEFINES))
	echo $(call FORMAT_FOR_ECHO,### ALL_SRCS = $(ALL_SRCS))
	echo $(call FORMAT_FOR_ECHO,### ALL_OBJS = $(ALL_OBJS))
	echo $(call FORMAT_FOR_ECHO,### LIBS = $(LIBS))
	echo $(call FORMAT_FOR_ECHO,### MODELREF_LIBS = $(MODELREF_LIBS))
	echo $(call FORMAT_FOR_ECHO,### SYSTEM_LIBS = $(SYSTEM_LIBS))
	echo $(call FORMAT_FOR_ECHO,### TOOLCHAIN_LIBS = $(TOOLCHAIN_LIBS))
	echo $(call FORMAT_FOR_ECHO,### ASFLAGS = $(ASFLAGS))
	echo $(call FORMAT_FOR_ECHO,### CFLAGS = $(CFLAGS))
	echo $(call FORMAT_FOR_ECHO,### LDFLAGS = $(LDFLAGS))
	echo $(call FORMAT_FOR_ECHO,### SHAREDLIB_LDFLAGS = $(SHAREDLIB_LDFLAGS))
	echo $(call FORMAT_FOR_ECHO,### CPPFLAGS = $(CPPFLAGS))
	echo $(call FORMAT_FOR_ECHO,### CPP_LDFLAGS = $(CPP_LDFLAGS))
	echo $(call FORMAT_FOR_ECHO,### CPP_SHAREDLIB_LDFLAGS = $(CPP_SHAREDLIB_LDFLAGS))
	echo $(call FORMAT_FOR_ECHO,### ARFLAGS = $(ARFLAGS))
	echo $(call FORMAT_FOR_ECHO,### MEX_CFLAGS = $(MEX_CFLAGS))
	echo $(call FORMAT_FOR_ECHO,### MEX_CPPFLAGS = $(MEX_CPPFLAGS))
	echo $(call FORMAT_FOR_ECHO,### MEX_LDFLAGS = $(MEX_LDFLAGS))
	echo $(call FORMAT_FOR_ECHO,### MEX_CPPLDFLAGS = $(MEX_CPPLDFLAGS))
	echo $(call FORMAT_FOR_ECHO,### OBJCOPYFLAGS_BIN = $(OBJCOPYFLAGS_BIN))
	echo $(call FORMAT_FOR_ECHO,### OBJCOPYFLAGS_HEX = $(OBJCOPYFLAGS_HEX))
	echo $(call FORMAT_FOR_ECHO,### DOWNLOAD_FLAGS = $(DOWNLOAD_FLAGS))
	echo $(call FORMAT_FOR_ECHO,### EXECUTE_FLAGS = $(EXECUTE_FLAGS))
	echo $(call FORMAT_FOR_ECHO,### MAKE_FLAGS = $(MAKE_FLAGS))


clean : 
	$(ECHO) "### Deleting all derived files ..."
	$(RM) $(PRODUCT)
	$(RM) $(ALL_OBJS)
	$(RM) *.dep
	$(ECHO) "### Deleted all derived files."


