;  IOLIB
;
;  Simple unbuffered IO and other utility functions
;
;  Paul Griffiths, March 21, 2015

%include        'unix.inc'
%include        'ascii.inc'

global  put_string, get_string, exit_success, get_char, put_char
global  print_newline
extern  string_length

        segment .text


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

        mov     rax, rdi
        mov     BYTE [rbp-.c], al
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


;  Prints a newline character

print_newline:
        push    rbp
        mov     rbp, rsp

        mov     rdi, CHAR_LF
        call    put_char

        xor     rax, rax
        leave
        ret
