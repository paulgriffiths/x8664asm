MAKEFLAGS	+= --no-builtin-rules
MKFLPATH    := $(realpath $(lastword $(MAKEFILE_LIST)))
MKFLDIR     := $(dir $(MKFLPATH))
LIBDIR      := $(MKFLDIR)lib
BINDIR      := $(MKFLDIR)bin
INCLDIR     := $(MKFLDIR)include
LIBRARIES	:=
OBJECTS		:=
LISTFILES	:=
PROGRAMS	:=

PROGS	:= hello testchartype testatoi rand strtest testinput guesser primes
AS		:= yasm
ASFLAGS	:= -f elf64 -g dwarf2 -I$(INCLDIR)
RM		:= rm -f
LD		:= ld
LIBOBJS	:= iolib.o char_types.o string.o general.o math.o
LDFLAGS := -Llib
LDLIBS	:= -lpgasm

default: all

%.o : %.asm
	 $(AS) $(ASFLAGS) -l $*.lst -o $*.o $*.asm

include libsrc/module.mk
include src/module.mk

all: $(PROGRAMS)

clean:
	$(RM) *.o *.lst $(PROGRAMS) $(LIBRARIES) $(OBJECTS) $(LISTFILES)
