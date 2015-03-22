;  String manipulation functions.
;
;  Paul Griffiths, March 21, 2015

%include        'unix.inc'
%include        'ascii.inc'

global  string_to_int, string_length

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

        xor     rax, rax                ;  For the running total
        xor     rdx, rdx                ;  For each individual character
        xor     rcx, rcx                ;  Loop counter
        
.loop:
        movzx   rdx, BYTE [rdi+rcx]     ;  Move character into rdx
        cmp     rdx, CHAR_ZERO          ;  Stop if less than '0' (includes
        jl      .done                   ;    terminating null)
        cmp     rdx, CHAR_NINE          ;  Stop if more than '9'
        jg      .done

        imul    rax, 10                 ;  Multiply running total by 10
        sub     rdx, CHAR_ZERO          ;  Convert current character to number
        add     rax, rdx                ;  Add current character to total
        inc     rcx                     ;  Increment loop count
        jmp     .loop                   ;  Loop again

.done:
        leave
        ret
