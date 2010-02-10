.PHONY: all clean disasm

# Tested with GNU Make, which comes with MinGW
# to use - type: make [TARGET], where TARGET can be one that looks like
# <TARGET>: <actions>

ifeq ($(CFG),)
CFG = debug
endif

objects = *.exe *.com *.lst *.map *.tr *.tr2 disasm.obj parse.obj

TPATH = C:/TASM/BIN

TASM = $(TPATH)/TASM.EXE
TLINK = $(TPATH)/TLINK.EXE
TD = $(TPATH)/TD.EXE

LFLAGS = /v /C /d
TFLAGS = /ml /t /w2
ifeq ($(CFG), debug)
	TFLAGS += /l /z /zi
endif

all: clean disasm

clean:
	del /q $(objects) 2> nul

inform:
ifneq ($(CFG), release)
ifneq ($(CFG), debug)
	@echo Invalid configuration "$(CFG)" specified.
	@exit 1
endif
endif

disasm: inform parse.obj disasm.obj
	$(TLINK) $(LFLAGS) disasm.obj + parse.obj

#test.asm: inform
#	$(TASM) $@
#	$(TLINK) /t $@

parse.obj: 
	$(TASM) $(TFLAGS) parse.asm

disasm.obj: 
	$(TASM) $(TFLAGS) main.asm
