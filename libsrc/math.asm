;  General utility functions

global  intlog

        segment .rodata

one     dq      1

        segment .text

;  Returns the integral (floored) log of an integer
;  e.g. intlog(12345, 10) would return 5
;  Argument 1 - the integer
;  Argument 2 - the base
;  Returns the requested log

intlog:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        mov     rax, rdi                ;  Move integer to rax
        xor     rcx, rcx                ;  Zero counter

.loop:
        cmp     rax, 0                  ;  Stop if integer is zero
        je      .done
        xor     rdx, rdx                ;  Zero high order bits for idiv
        idiv    rsi                     ;  Divide by base
        inc     rcx                     ;  Increment counter
        jmp     .loop                   ;  Loop again

.done:
        mov     rax, rcx                ;  Return counter
        cmp     rax, 0                  ;  If result is zero...
        cmove   rax, [one]              ;  ...set log to 1
        leave
        ret
