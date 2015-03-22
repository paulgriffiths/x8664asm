;  Tests string conversion function

%include        'ascii.inc'

extern  put_string, exit_success, string_to_int
global  _start

        segment .rodata
numstr1         db      '12345', CHAR_NUL       ;  String to test for success
numstr2         db      '23456', CHAR_NUL       ;  String to test for failure

testnum1        dq      12345           ;  Matches first string
testnum2        dq      23455           ;  Does NOT match second string

success         db      'Success!', CHAR_LF, CHAR_NUL
failure         db      'Failed!', CHAR_LF, CHAR_NUL

        segment .text

_start:
        lea     rdi, [numstr1]          ;  Pass first string
        call    string_to_int           ;  Call atoi function
        mov     rdi, failure            ;  Store failure string as default
        mov     rsi, success            ;  Store success string for cmovz
        cmp     rax, [testnum1]         ;  Compare to test number
        cmovz   rdi, rsi                ;  Choose success if zero
        call    put_string              ;  Output message

        lea     rdi, [numstr2]          ;  Pass second string
        call    string_to_int           ;  Call atoi function
        mov     rdi, success            ;  Store success string as default
        mov     rsi, failure            ;  Store failure string for cmovz
        cmp     rax, [testnum2]         ;  Compare to test number
        cmovz   rdi, rsi                ;  Choose failure if zero
        call    put_string              ;  Output message

        call    exit_success
