;  String manipulation functions.
;
;  Paul Griffiths, March 21, 2015

%include        'ascii.inc'

global  int_to_string, string_to_int, string_length, string_rev
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
        sub     rsp, 8                  ;  Align stack to save 3 registers

        push    r12
        push    r13
        push    r14

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

        pop     r14
        pop     r13
        pop     r12

        leave
        ret


;  Reverses a string in-place
;  Argument 1 - the string to reverse

string_rev:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp
        sub     rsp, 16 

.str    equ     8                       ;  Local - address of string

        mov     [rbp-.str], rdi         ;  Save address of string
        call    string_length           ;  Get length of string
        mov     rdi, [rbp-.str]         ;  Restore address of string
        mov     rdx, rax                ;  Set back counter to string...
        dec     rdx                     ;  ...length minus 1
        xor     rcx, rcx                ;  Set front counter to zero

.loop:
        cmp     rcx, rdx                ;  If front counter passes back...
        jge     .end                    ;  ...counter, then stop looping

        mov     al, BYTE [rdi+rcx]      ;  Get front byte...
        mov     rsi, rax                ;  ...and save it
        mov     al, BYTE [rdi+rdx]      ;  Get back byte...
        mov     BYTE [rdi+rcx], al      ;  ...and put it at the front
        mov     rax, rsi                ;  Retrieve saved front byte...
        mov     BYTE [rdi+rdx], al      ;  ...and put it at the back

        inc     rcx                     ;  Increment front counter
        dec     rdx                     ;  Decrement back counter
        jmp     .loop                   ;  Loop again

.end:
        xor     rax, rax                ;  Return 0
        leave
        ret


;  Converts an integer to a string
;  Note: only handles unsigned integers
;  Note: caller is responsible for ensuring string is sufficiently large
;  Argument 1 - the integer to convert
;  Argument 2 - the address of the string

int_to_string:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        xor     rcx, rcx                ;  Set counter to zero
        mov     r9, 10                  ;  Store divisor in r9
        xor     rax, rax                ;  Clear all bits of rax register

.loop:
        cmp     rdi, 0                  ;  If integer is zero...
        je      .done                   ;  ...then we're done

        xor     rdx, rdx                ;  Clear high order bits for idiv
        mov     rax, rdi                ;  Move integer into rax
        idiv    r9                      ;  Divide by 10
        mov     rdi, rax                ;  Replace previous int with quotient
        mov     rax, rdx                ;  Move remainder to rax
        add     rax, CHAR_ZERO          ;  Convert to digit character
        mov     BYTE [rsi+rcx], al      ;  Store character
        inc     rcx                     ;  Increment counter
        jmp     .loop                   ;  Loop again

.done:
        mov     BYTE [rsi+rcx], CHAR_NUL        ;  Add terminating null
        mov     rdi, rsi                ;  Pass address of string...
        call    string_rev              ;  ...and reverse it

        xor     rax, rax                ;  Return 0
        leave
        ret
