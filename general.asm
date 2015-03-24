;  General utility functions.

%include        'unix.inc'

global  exit_success, exit_failure, pgrandom, seedrandom

        section .data

rand_x  DD      123456789               ;  X value for PRNG
rand_y  DD      362436069               ;  Y value for PRNG
rand_z  DD      521288629               ;  Z value for PRNG
rand_w  DD      88675123                ;  W value for PRNG


        section .text


;  Exits with successful status

exit_success:
        mov    rax, SC_EXIT
        xor    rdi, rdi
        syscall 


;  Exits with unsuccessful status

exit_failure:
        mov    rax, SC_EXIT
        mov    rdi, 1
        syscall 


;  Generates a random number within a range.
;  Uses 'XORShift' algorithm.
;  Argument 1 - the exclusive top end of the desired range
;  Returns a pseudo-random number between 0 and n-1, inclusive

pgrandom:
        push   rbp                      ;  Set up stack
        mov    rbp,rsp
        sub    rsp, 16

.range  equ     16                      ;  Local - argument
.t      equ     8                       ;  Local - temporary

        mov    [rbp-.range], rdi        ;  Store argument

        mov    eax, [rand_x]            ;  Get x value
        mov    ecx, eax                 ;  Copy x value
        shl    ecx, 11                  ;  x << 11
        xor    eax, ecx                 ;  t = x ^ (x << 11)
        mov    ecx, eax                 ;  Copy t value
        shr    ecx, 8                   ;  t >> 8
        xor    eax, ecx                 ;  t = t ^ (t >> 8)
        mov    [rbp-.t], eax            ;  Store t value

        mov    eax, [rand_y]            ;  Copy y value...
        mov    [rand_x] ,eax            ;  ...to x
        mov    eax, [rand_z]            ;  Copy z value...
        mov    [rand_y] ,eax            ;  ...to y
        mov    eax, [rand_w]            ;  Copy w value...
        mov    [rand_z], eax            ;  ...to z

        mov    ecx, eax                 ;  Copy w value
        shr    ecx, 19                  ;  w >> 19
        xor    eax, ecx                 ;  w = w ^ (w >> 19)
        mov    ecx, [rbp-.t]            ;  Retrieve t value
        xor    eax, ecx                 ;  w = w ^ t
        mov    [rand_w], eax            ;  Store w value

        xor    edx, edx                 ;  Zero high order bits for idiv
        idiv   QWORD [rbp-.range]       ;  Divide by range

        mov    eax, edx                 ;  Return remainder
        leave  
        ret    


;  Seeds the pseudo-random number generator.

seedrandom:
        push   rbp                      ;  Set up stack
        mov    rbp, rsp
        sub    rsp, 16

.a      equ     16                      ;  Local - temporary value

        mov    rax, SC_TIME             ;  Make time system call
        mov    rdi, 0
        syscall 
        mov    [rbp-.a],eax             ;  Store result

        mov    rax, SC_GETPID           ;  Make getpid system call
        syscall 

        mov    rcx, [rbp-.a]            ;  Add result of time to it...
        add    rax,rcx
        mov    [rand_x],eax             ;  ...and store the sum in x value

        xor    rax,rax                  ;  Return 0
        leave  
        ret    
