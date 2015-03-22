;  String manipulation functions.
;
;  Paul Griffiths, March 21, 2015

%include        'unix.inc'
%include        'ascii.inc'

global  string_to_int, string_length
extern  char_is_digit

        segment .text


;  Calculates the length of a string
;  Argument 1 (rdi) - address of string
;  Returns (rax) the length of the string

string_length:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        mov     rcx, -1                 ;  Set rcx to maximum value
        xor     al, al                  ;  Set al to '\0'
        repne   scasb                   ;  Scan until '\0'
        mov     rax, -2                 ;  Set to not count null terminator
        sub     rax, rcx                ;  Calculate length of string

        leave                           ;  Return the length
        ret


;  Converts a string containing a decimal integer representation to an integer
;  Argument 1, address of string
;  Returns the integer, or zero on failure
;  Note - assumes ASCII character set
;  Note - currently only handles positive integers

string_to_int:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp
        sub     rsp, 32 

.sr12   equ     24                      ;  Local - to save r12 register
.sr13   equ     16                      ;  Local - to save r13 register
.sr14   equ     8                       ;  Local - to save r14 register

        mov     [rbp-.sr12], r12        ;  Save value of r12 register
        mov     [rbp-.sr13], r13        ;  Save value of r13 register
        mov     [rbp-.sr14], r14        ;  Save value of r14 register

        mov     r12, rdi                ;  Store string
        xor     r13, r13                ;  Store running total
        
.loop:
        movzx   r14, BYTE [r12]         ;  Extract current character
        mov     rdi, r14                ;  Pass current character
        call    char_is_digit           ;  Call digit test function
        cmp     rax, 1                  ;  Test if character is a digit...
        jne     .done                   ;  ...and terminate loop if it isn't.

        imul    r13, 10                 ;  Multiply running total by 10
        sub     r14, CHAR_ZERO          ;  Convert current character to number
        add     r13, r14                ;  Add current character to total
        inc     r12                     ;  Increment string pointer
        jmp     .loop                   ;  Loop again

.done:
        mov     rax, r13                ;  Return running total
        mov     r12, [rbp-.sr12]        ;  Restore value of r12 register
        mov     r13, [rbp-.sr13]        ;  Restore value of r13 register
        mov     r14, [rbp-.sr14]        ;  Restore value of r14 register
        leave
        ret
