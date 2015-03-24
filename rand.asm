;  Tests random number function

%include        'ascii.inc'

extern  pgrandom, printf, seedrandom
global  main

        segment .rodata
rnstr   db      '%d', CHAR_LF, CHAR_NUL

        segment .text

main:
        push    rbp
        mov     rbp, rsp

        call    seedrandom
        mov     rbx, 10

.loop:
        cmp     rbx, 0
        je      .end
        mov     rdi, 100
        call    pgrandom
        mov     rsi, rax
        lea     rdi, [rnstr]
        xor     rax, rax
        call    printf
        dec     rbx
        jmp     .loop

.end:
        leave
        ret
