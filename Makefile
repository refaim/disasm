.PHONY: all clean inform

# Written on GNU Make, which comes with MinGW
# Using: 'make [CFG=<debug|release>]' ('CFG=debug' by default)

APPNAME = disasm
OBJS = main.obj common.obj parse.obj
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

$(APPNAME).exe: inform $(OBJS)
	$(TLINK) $(LFLAGS) $(OBJS), $(APPNAME).exe

main.obj:
	$(TASM) $(TFLAGS) main.asm

common.obj:
	$(TASM) $(TFLAGS) common.asm

parse.obj:
	$(TASM) $(TFLAGS) parse.asm

test:
	$(TASM) $(TFLAGS) $@.asm
	$(TLINK) /t /c $@.obj
