PROGS	:= hello testchartype
AS		:= yasm
ASFLAGS	:= -f elf64 -g dwarf2
RM		:= rm -f
LD		:= ld

all: $(PROGS)

%.o : %.asm
	 $(AS) $(ASFLAGS) -l $*.lst -o $*.o $*.asm

hello: hello.o iolib.o char_types.o
	$(LD) -o $@ $^

testchartype: testchartype.o iolib.o char_types.o
	$(LD) -o $@ $^

clean:
	$(RM) *.o *.lst $(PROGS)
