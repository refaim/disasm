.PHONY: all clean inform debug

# Written on GNU Make, which comes with MinGW
# Using: 'make [debug|test] [CFG=<debug|release>]' ('CFG=debug' by default)

APPNAME = disasm
OBJS = main.obj common.obj p_jxx.obj p_nop.obj
TESTOBJS = test.com test.obj
OUTFILES = $(APPNAME).exe $(OBJS) $(TESTOBJS) *.lst *.map *.tr *.tr2

ifeq ($(CFG),)
CFG = debug
endif

TPATH = H:/TASM/BIN
TASM = $(TPATH)/TASM.EXE
TLINK = $(TPATH)/TLINK.EXE
TD = $(TPATH)/TD.EXE

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

$(APPNAME).exe: inform $(OBJS)
	$(TLINK) $(LFLAGS) $(OBJS), $(APPNAME).exe

main.obj:
	$(TASM) $(TFLAGS) main.asm

common.obj:
	$(TASM) $(TFLAGS) common.asm

p_jxx.obj:
	$(TASM) $(TFLAGS) p_jxx.asm
p_nop.obj:
	$(TASM) $(TFLAGS) p_nop.asm
