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

.count  equ     32                      ;  Local - loop counter
.total  equ     24                      ;  Local - running total
.str    equ     16                      ;  Local - string to read
.c      equ     8                       ;  Local - current character

        mov     [rbp-.str], rdi         ;  Store string to read
        mov     QWORD [rbp-.count], 0   ;  Zero loop counter
        mov     QWORD [rbp-.total], 0   ;  Zero running total

        xor     rcx, rcx                ;  Loop counter
        
.loop:
        mov     rdi, [rbp-.str]         ;  Load address of string
        movzx   rdi, BYTE [rdi+rcx]     ;  Extract current character
        mov     [rbp-.c], rdi           ;  Save current character
        mov     [rbp-.count], rcx       ;  Save loop counter
        call    char_is_digit           ;  Call digit test function
        mov     rcx, [rbp-.count]       ;  Restore loop counter
        mov     rdi, [rbp-.c]           ;  Restore current character
        cmp     rax, 1                  ;  Test if character is a digit...
        jne     .done                   ;  ...and terminate if it isn't.

        mov     rax, [rbp-.total]       ;  Retrieve running total
        imul    rax, 10                 ;  Multiply running total by 10
        sub     rdi, CHAR_ZERO          ;  Convert current character to number
        add     rax, rdi                ;  Add current character to total
        mov     [rbp-.total], rax       ;  Save running total
        inc     rcx                     ;  Increment loop count
        jmp     .loop                   ;  Loop again

.done:
        mov     rax, [rbp-.total]       ;  Return running total
        leave
        ret
