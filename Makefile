MKFLPATH    := $(realpath $(lastword $(MAKEFILE_LIST)))
MKFLDIR     := $(dir $(MKFLPATH))
LIBDIR      := $(MKFLDIR)lib
BINDIR      := $(MKFLDIR)bin
INCLDIR     := $(MKFLDIR)include
LIBRARIES   :=
OBJECTS	    :=
LISTFILES   :=
PROGRAMS    :=

AS          := yasm
ASFLAGS	    := -f elf64 -g dwarf2 -I$(INCLDIR)
CC          := gcc
CFLAGS      := -std=c99 -pedantic -Wall -Wextra -I$(INCLDIR)
RM          := rm -f
LD          := ld
LDFLAGS     := -Llib
LDLIBS	    := -lpgasm

default: all

%.o : %.c
	 $(CC) -c $(CFLAGS) -o $*.o $*.c

%.o : %.asm
	 $(AS) $(ASFLAGS) -l $*.lst -o $*.o $*.asm

include libsrc/module.mk
include src/module.mk
include csrc/module.mk

all: $(PROGRAMS)

clean:
	$(RM) *.o *.lst $(PROGRAMS) $(LIBRARIES) $(OBJECTS) $(LISTFILES)
