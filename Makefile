.PHONY: all clean test_clean inform test debug

# Written on GNU Make, which comes with MinGW
# Using: 'make [debug|test] [CFG=<debug|release>]' ('CFG=debug' by default)

APPNAME = disasm
OBJS = main.obj common.obj
TESTOBJS = test.com test.obj test.lst test.map
PTEMPLATE = p_*
WLC_PTEMPLATE = $(wildcard $(PTEMPLATE).obj)
OUTFILES = $(APPNAME).exe $(OBJS) $(WLC_PTEMPLATE) *.lst *.map *.tr *.tr2

ifeq ($(CFG),)
CFG = debug
endif

TASM = ${TASM_PATH}/TASM.EXE
TLINK = ${TASM_PATH}/TLINK.EXE
TD = ${TASM_PATH}/TD.EXE

TFLAGS = /ml /t /w2
LFLAGS = /C /d
ifeq ($(CFG), debug)
TFLAGS += /l /z /zi
LFLAGS += /v
endif

all: clean $(APPNAME).exe

clean:
	del /q $(OUTFILES) 2> nul

inform:
ifneq ($(CFG), release)
ifneq ($(CFG), debug)
	@echo Invalid configuration "$(CFG)" specified.
	@exit 1
endif
endif

debug: all
	$(TD) $(APPNAME).exe

test:
	$(TASM) $(TFLAGS) $@.asm
	$(TLINK) /t /c $@.obj

test_clean:
	del /q $(TESTOBJS) 2> nul

$(APPNAME).exe: inform $(OBJS) $(PTEMPLATE).obj
	$(TLINK) $(LFLAGS) $(OBJS) $(WLC_PTEMPLATE), $(APPNAME).exe

main.obj:
	$(TASM) $(TFLAGS) main.asm

common.obj:
	$(TASM) $(TFLAGS) common.asm

$(PTEMPLATE).obj:
	$(TASM) $(TFLAGS) $(PTEMPLATE).asm
