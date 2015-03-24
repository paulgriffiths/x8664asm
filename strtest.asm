;  Tests string library functions.

%include        'ascii.inc'

extern  put_string, exit_success, string_rev, print_newline
global  _start

        segment .rodata

revtst  db      '=== String Reverse Test ===', CHAR_LF, CHAR_NUL
orgstr  db      'Original: ', CHAR_NUL
revstr  db      'Reversed: ', CHAR_NUL

        segment .data
hwstr   db      'Hello, world!', CHAR_NUL

        segment .text

_start:
        lea     rdi, [revtst]
        call    put_string

        lea     rdi, [orgstr]
        call    put_string
        lea     rdi, [hwstr]
        call    put_string
        call    print_newline

        lea     rdi, [hwstr]
        call    string_rev

        lea     rdi, [revstr]
        call    put_string
        lea     rdi, [hwstr]
        call    put_string
        call    print_newline

        call    exit_success
