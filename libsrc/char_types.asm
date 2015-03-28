;  Char types
;
;  Functions to test ASCII character types.
;
;  Paul Griffiths, March 21, 2015

%include        'ascii.inc'

global  char_is_digit, char_is_space, char_is_alpha, char_is_alnum

        segment .rodata

ZERO    dq      0                       ;  Zero constant
ONE     dq      1                       ;  One constant


        segment .text


;  Tests if a character is a digit
;  Argument 1 - the character to test
;  Returns - 1 if the character is a digit, 0 if it is not

char_is_digit:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        mov     rax, 1                  ;  Default return value of 1 if true

        cmp     rdi, CHAR_ZERO          ;  Not digit if less than '0'...
        cmovl   rax, [ZERO]             ;  ...so return 0 if true.
        cmp     rdi, CHAR_NINE          ;  Not digit if more than '9'...
        cmovg   rax, [ZERO]             ;  ...so return 0 if true.

        leave                           ;  Return
        ret


;  Tests if a character is a space
;  Argument 1 - the character to test
;  Returns - 1 if the character is a space, 0 if it is not

char_is_space:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        mov     rax, 1                  ;  Default return value 1 if true

        cmp     rdi, CHAR_HTAB          ;  Not space if less than htab...
        cmovl   rax, [ZERO]             ;  ...so return 0 if true

        cmp     rdi, CHAR_CR            ;  Not space if more than CR...
        cmovg   rax, [ZERO]             ;  ...so return 0 if true...

        cmp     rdi, CHAR_SPACE         ;  ...unless it's space, then...
        cmove   rax, [ONE]              ;  ...return 1 if true.

        leave                           ;  Return
        ret


;  Tests if character is alphabetic
;  Argument 1 - the character to test
;  Returns 1 if the character is alphabetic, 0 if not

char_is_alpha:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        mov     rdx, 1                  ;  Default result is true for uppercase
        cmp     rdi, CHAR_UPPER_A       ;  False if below 'A'
        cmovl   rdx, [ZERO]
        cmp     rdi, CHAR_UPPER_Z       ;  False if above 'Z'
        cmovg   rdx, [ZERO]

        mov     rax, 1                  ;  Default result is true for lowercase
        cmp     rdi, CHAR_LOWER_A       ;  False if below 'a'
        cmovl   rax, [ZERO]
        cmp     rdi, CHAR_LOWER_Z       ;  False if above 'z'
        cmovg   rax, [ZERO]

        or      rax, rdx                ;  True if either test was true

        leave                           ;  Return
        ret


;  Tests if character is alphanumeric
;  Argument 1 - the character to test
;  Returns 1 if the character is alphanumeric, 0 if not

char_is_alnum:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp
        sub     rsp, 16

.n      equ     8                       ;  Local - character to test

        mov     [rbp-.n], rdi           ;  Store character

        call    char_is_alpha           ;  Check if alphabetic...
        mov     rdx, rax                ;  ...and store result

        mov     rdi, [rbp-.n]           ;  Pass character to test
        call    char_is_digit           ;  Check if digit

        or      rax, rdx                ;  True if either test was true

        leave                           ;  Return
        ret
