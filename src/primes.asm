;  Calculates first n prime numbers

extern  put_int, print_newline, exit_success
global  _start

nprimes equ     15                      ;  Number of prime numbers to find
nsz     equ     8                       ;  Size of prime number array element

        section .bss

primes  resq    nprimes                 ;  Array of prime numbers

        section .text


;  Main entry point

_start:
        mov     rbp, rsp                        ;  Set up stack

        mov     rdi, nprimes                    ;  Pass number of primes
        lea     rsi, [primes]                   ;  Pass address of array
        call    calcprimes                      ;  Find primes

        mov     rdi, nprimes                    ;  Pass number of primes
        lea     rsi, [primes]                   ;  Pass address of array
        call    printqarray                     ;  Print found primes

        call    exit_success                    ;  Exit


;  Prints an array of quad words
;  Argument 1 - number of elements in array
;  Argument 2 - address of array
;  Return 0.

printqarray:
        push    rbp                             ;  Set up stack
        mov     rbp, rsp
        sub     rsp, 32 

.size   equ     32                              ;  Local - size of array
.array  equ     24                              ;  Local - address of array
.count  equ     16                              ;  Local - current count

        mov     [rbp-.size], rdi                ;  Store size of array
        mov     [rbp-.array], rsi               ;  Store address of array
        mov     QWORD [rbp-.count], 0           ;  Set count to zero

.loop:
        mov     rdx, [rbp-.size]                ;  Retrieve size of array
        mov     rcx, [rbp-.count]               ;  Retrieve count
        cmp     rcx, rdx                        ;  If at end of array...
        je      .done                           ;  ...then stop looping.

        mov     rax, QWORD [rbp-.array]         ;  Retrieve address of array
        mov     rdi, [rax+rcx*nsz]              ;  Load value of array element
        call    put_int                         ;  Output it
        call    print_newline                   ;  Output newline
        inc     QWORD [rbp-.count]              ;  Increment count
        jmp     .loop                           ;  Loop again
        
.done:
        xor     rax, rax                        ;  Return 0
        leave
        ret


;  Calculates the first n prime numbers
;  Argument 1 - the number of primes to find
;  Argument 2 - the quad word array in which to store them
;  Returns 0.
;  Caller is responsible for making array large enough.

calcprimes:
        push    rbp                             ;  Set up stack
        mov     rbp, rsp

        cmp     rdi, 2                          ;  If number is less than 2...
        jl      .done                           ;  ...don't even try.

        mov     QWORD [rsi], 2                  ;  Manually populate...
        mov     QWORD [rsi+nsz], 3              ;  ...the first 2 primes.
        xor     rcx, 2                          ;  Number of primes found
        mov     r8, 5                           ;  Current number to test

.outerloop:
        cmp     rcx, rdi                        ;  If all primes are found...
        jge     .done                           ;  ...then stop.
        mov     r9, 1                           ;  Primes found index, skip 2
        mov     r10, 1                          ;  Found flag, default true

.innerloop:
        cmp     r9, rcx                         ;  If past found primes...
        je      .endinner                       ;  ...then stop.
        mov     r11, [rsi+r9*nsz]               ;  Get next found prime
        inc     r9                              ;  Increment found prime index
        xor     rdx, rdx                        ;  Zero HO bits for idiv
        mov     rax, r8                         ;  Get current test number
        idiv    r11                             ;  Divide by next found prime
        cmp     rdx, 0                          ;  If it doesn't divide...
        jne     .innerloop                      ;  ...keep looking
        mov     r10, 0                          ;  Otherwise found flag false

.endinner:
        cmp     r10, 1                          ;  Check if we found a prime...
        jne     .endouter                       ;  ...and skip if we didn't.
        mov     QWORD [rsi+rcx*nsz], r8         ;  Store the found prime
        inc     rcx                             ;  Increment primes found count

.endouter:
        add     r8, 2                           ;  Go to next odd number
        jmp     .outerloop                      ;  Loop again.

.done:
        xor     rax, rax                        ;  Return 0
        leave
        ret
