;  Tests character type library functions.
;
;  Paul Griffiths, March 21, 2015


%include        'ascii.inc'

extern  put_string, exit_success
extern  char_is_digit, char_is_space, char_is_alpha, char_is_alnum
global  _start

        segment .rodata

args    dq      0x32, 0x4b, 0x39, 0x5d, 0x6d, 0x40, 0x20, 0x00
argsz   equ     8
funcs   dq      test_char_is_digit, test_char_is_alpha, test_char_is_space, \
                test_char_is_alnum, 0x00
funcsz  equ     8

        segment .text


;  Start function
;  Loops through all test functions in 'funcs', and for each one,
;  pass each of the arguments in 'args' in turn. Both 'funcs' and
;  'args' must be NULL and zero terminated, respectively.

_start:
        mov     rbp, rsp                ;  Set up stack
        sub     rsp, 16 

.ncount         equ     16              ;  Local - argument counter
.fcount         equ     8               ;  Local - function counter

        mov     QWORD [rbp-.ncount], 0  ;  Set argument counter to zero
        mov     QWORD [rbp-.fcount], 0  ;  Set function counter to zero

.funcloop:
        mov     rcx, [rbp-.fcount]      ;  Get function counter
        mov     rdx, funcs              ;  Get base function pointer
        lea     r12, [rdx+rcx*funcsz]   ;  Calculate current function address
        mov     r12, [r12]              ;  Get actual address of function
        cmp     r12, 0                  ;  If function pointer is NULL...
        je      .funcend                ;  ...terminate outer loop

        inc     QWORD [rbp-.fcount]     ;  Increment function count
        mov     rcx, [rbp-.ncount]      ;  Retrieve argument count

.argloop:
        mov     rdx, args               ;  Get base argument pointer
        lea     rax, [rdx+rcx*argsz]    ;  Calculate current argument address
        mov     rdi, [rax]              ;  Get value of current argument
        cmp     rdi, 0                  ;  If current argument is zero...
        je      .argend                 ;  ...terminate inner loop.

        inc     rcx                     ;  Increment loop counter
        mov     [rbp-.ncount], rcx      ;  Save loop counter
        call    r12                     ;  Call function
        mov     rcx, [rbp-.ncount]      ;  Retrieve loop counter
        jmp     .argloop                ;  Loop again

.argend:
        mov     QWORD [rbp-.ncount], 0  ;  Reset argument counter to zero
        jmp     .funcloop               ;  Loop again

.funcend:
        call    exit_success


;  Tests whether a character is a digit, and outputs a message
;  Argument 1 - the character to test
;  Returns 0

test_char_is_digit:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .data
.stris          db      "'?' is a digit.", CHAR_LF, CHAR_NUL
.strisnt        db      "'?' is not a digit.", CHAR_LF, CHAR_NUL

        segment .text
        
        mov     rsi, char_is_digit      ;  Pass relevant test function
        lea     rdx, [.stris]           ;  Pass success string
        lea     rcx, [.strisnt]         ;  Pass failure string
        call    test_char_generic       ;  Call generic test function

        xor     rax, rax                ;  Return 0
        leave
        ret


;  Tests whether a character is alphabetic, and outputs a message
;  Argument 1 - the character to test
;  Returns 0

test_char_is_alpha:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .data
.stris          db      "'?' is alphabetic.", CHAR_LF, CHAR_NUL
.strisnt        db      "'?' is not alphabetic.", CHAR_LF, CHAR_NUL

        segment .text
        
        mov     rsi, char_is_alpha      ;  Pass relevant test function
        lea     rdx, [.stris]           ;  Pass success string
        lea     rcx, [.strisnt]         ;  Pass failure string
        call    test_char_generic       ;  Call generic test function

        xor     rax, rax                ;  Return 0
        leave
        ret


;  Tests whether a character is whitespace, and outputs a message
;  Argument 1 - the character to test
;  Returns 0

test_char_is_space:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .data
.stris          db      "'?' is whitespace.", CHAR_LF, CHAR_NUL
.strisnt        db      "'?' is not whitespace.", CHAR_LF, CHAR_NUL

        segment .text
        
        mov     rsi, char_is_space      ;  Pass relevant test function
        lea     rdx, [.stris]           ;  Pass success string
        lea     rcx, [.strisnt]         ;  Pass failure string
        call    test_char_generic       ;  Call generic test function

        xor     rax, rax                ;  Return 0
        leave
        ret


;  Tests whether a character is alphanumeric, and outputs a message
;  Argument 1 - the character to test
;  Returns 0

test_char_is_alnum:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .data
.stris          db      "'?' is alphanumeric.", CHAR_LF, CHAR_NUL
.strisnt        db      "'?' is not alphanumeric.", CHAR_LF, CHAR_NUL

        segment .text
        
        mov     rsi, char_is_alnum      ;  Pass relevant test function
        lea     rdx, [.stris]           ;  Pass success string
        lea     rcx, [.strisnt]         ;  Pass failure string
        call    test_char_generic       ;  Call generic test function

        xor     rax, rax                ;  Return 0
        leave
        ret


;  Generic test of a character with output message
;  Argument 1 - the character to test
;  Argument 2 - address of the test function
;  Argument 3 - address of the success string
;  Argument 4 - address of the failure string
;  The second byte of the success and failure strings will be
;  modified to contain the test character.
;  Returns 0

test_char_generic:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp
        sub     rsp, 32 

.storeb equ     24                      ;  Local - save rbx register value
.succ   equ     16                      ;  Local - success string
.fail   equ     8                       ;  Local - failure string

.coff   equ     1                       ;  Offset to changing byte

        mov     [rbp-.storeb], rbx      ;  Store value of rbx
        mov     [rbp-.succ], rdx        ;  Save success string
        mov     [rbp-.fail], rcx        ;  Save failure string
        mov     rax, rdi                ;  Move character to rax for al

        lea     rbx, [rdx+.coff]        ;  Get address of changing byte of...
        mov     BYTE [rbx], al          ;  ...success string and store char

        lea     rbx, [rcx+.coff]        ;  Get address of changing byte of...
        mov     BYTE [rbx], al          ;  ...failure string and store char
        
        mov     rbx, [rbp-.fail]        ;  Store fail string as default
        call    rsi                     ;  Call test function
        cmp     rax, 1                  ;  Test return value and store...
        cmove   rbx, [rbp-.succ]        ;  ...success string if true. 
        mov     rdi, rbx                ;  Pass relevant string
        call    put_string              ;  Output relevant string

        mov     rbx, [rbp-.storeb]      ;  Restore value of rbx
        xor     rax, rax                ;  Return 0
        leave
        ret
