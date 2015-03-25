PROGS	:= hello testchartype testatoi rand strtest testinput guesser
AS		:= yasm
ASFLAGS	:= -f elf64 -g dwarf2
RM		:= rm -f
LD		:= ld
LIBOBJS	:= iolib.o char_types.o string.o general.o math.o

all: $(PROGS)

%.o : %.asm
	 $(AS) $(ASFLAGS) -l $*.lst -o $*.o $*.asm

testatoi: testatoi.o $(LIBOBJS)
	$(LD) -o $@ $^

guesser: guesser.o $(LIBOBJS)
	$(LD) -o $@ $^

testinput: testinput.o $(LIBOBJS)
	$(LD) -o $@ $^

rand: rand.o $(LIBOBJS)
	$(LD) -o $@ $^

hello: hello.o $(LIBOBJS)
	$(LD) -o $@ $^

strtest: strtest.o $(LIBOBJS)
	$(LD) -o $@ $^

testchartype: testchartype.o $(LIBOBJS)
	$(LD) -o $@ $^

clean:
	$(RM) *.o *.lst $(PROGS)
