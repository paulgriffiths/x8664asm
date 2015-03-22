;  IOLIB
;
;  Simple unbuffered IO and other utility functions
;
;  Paul Griffiths, March 21, 2015

%include        'unix.inc'
%include        'ascii.inc'

global  put_string, get_string, exit_success, get_char, put_char
global  string_to_int

        segment .text


;  Exits successfully

exit_success:
        mov     rax, SC_EXIT            ;  Pass system call number
        xor     rdi, rdi                ;  Pass zero exit status
        syscall                         ;  Make exit system call


;  Reads a character from standard input
;  Returns the character read, or -1 on failure

get_char:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp
        sub     rsp, 16

.c      equ     16                      ;  Local - buffer, one character used

        mov     rax, SC_READ            ;  Pass system call number
        mov     rdi, STDIN              ;  Pass file descriptor
        lea     rsi, [rbp-.c]           ;  Pass address of buffer
        mov     rdx, 1                  ;  Pass number of characters to read
        syscall                         ;  Make read system call

        cmp     rax, 1                  ;  Check number of characters read...
        jl      .failed                 ;  ...and fail if less than one

        movsx   rax, BYTE [rbp-.c]      ;  Return the character read
        jmp     .done

.failed:
        mov     rax, -1                 ;  Return -1 on failure

.done:
        leave                           ;  Finish
        ret


;  Writes a character to standard input
;  Argument 1 - the character to output
;  Returns 0 on success, -1 on failure

put_char:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp
        sub     rsp, 16

.c      equ     16                      ;  Local - buffer, one character used 

        mov     rax, SC_WRITE           ;  Pass system call number
        mov     rdi, STDOUT             ;  Pass file descriptor
        lea     rsi, [rbp-.c]           ;  Pass address of buffer
        mov     rdx, 1                  ;  Pass number of characters to write
        syscall                         ;  Make write system call

        cmp     rax, 1                  ;  Check number of characters written
        jl      .failed                 ;  Fail if less than one
        mov     rax, 0                  ;  Return 0 on success
        jmp     .done

.failed:
        mov     rax, -1                 ;  Return -1 on failure

.done:
        leave
        ret


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


;  Prints a null-terminated string to standard output
;  Does not automatically add a new line character
;  Argument 1 - address of the string
;  Returns result of write system call 

put_string:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp
        sub     rsp, 16

.str    equ     8                       ;  Local - address of string

        mov     [rbp-.str], rdi         ;  Save address of string
        call    string_length           ;  Calculate string length
        mov     rdi, [rbp-.str]         ;  Restore address of string
        mov     rdx, rax                ;  Pass length of string
        mov     rax, SC_WRITE           ;  Pass system call number
        mov     rsi, rdi                ;  Pass address of string
        mov     rdi, STDOUT             ;  Pass file descriptor
        syscall                         ;  Make write system call

        leave                           ;  Return
        ret


;  Gets a line from standard input
;  Does not remove the new line character
;  Note - performs no sanity checks on buffer length
;  Argument 1 - address of the buffer into which to write
;  Argument 2 - length of the buffer
;  Returns number of characters read

get_string:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp
        sub     rsp, 32 

.storeb         equ     24              ;  Save value of rbx
.count          equ     16              ;  Local - loop counter
.bufflen        equ     8               ;  Local - length of buffer

        mov     [rbp-.storeb], rbx      ;  Store rbx register
        mov     [rbp-.bufflen], rsi     ;  Save length of buffer
        mov     rbx, rdi                ;  Store address of buffer, rbx is
                                        ;  preserved through function calls

        mov     rcx, 1                  ;  Set loop counter to one, to allow
                                        ;  room for terminating null

.loop:
        cmp     rcx, [rbp-.bufflen]     ;  Compare loop count to buffer length
        je      .end                    ;  and end if only one space in buffer

        mov     [rbp-.count], rcx       ;  Save loop count
        call    get_char                ;  Get character from standard input
        mov     rcx, [rbp-.count]       ;  Restore loop count

        mov     BYTE [rbx+rcx-1], al    ;  Store character in buffer
        inc     rcx                     ;  Increment loop count

        cmp     rax, CHAR_LF            ;  Check if character is new line...
        jne     .loop                   ;  ...and continue loop if it isn't.

.end:
        mov     BYTE [rbx+rcx-1], CHAR_NUL      ;  Write terminating null

        mov     rbx, [rbp-.storeb]      ;  Restore rbx register
        dec     rcx                     ;  Decrement rcx for terminating null
        mov     rax, rcx                ;  Returns number of character read
        leave
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
