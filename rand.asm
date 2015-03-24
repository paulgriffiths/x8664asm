;  Tests random number function

%include        'ascii.inc'

extern  pgrandom, seedrandom, put_int, print_newline, exit_success
global  _start

        segment .rodata
rnstr   db      '%d', CHAR_LF, CHAR_NUL

        segment .text

_start:
        call    seedrandom
        mov     rbx, 10

.loop:
        cmp     rbx, 0
        je      .end
        mov     rdi, 100
        call    pgrandom
        mov     rdi, rax
        call    put_int
        call    print_newline
        dec     rbx
        jmp     .loop

.end:
        call    exit_success
