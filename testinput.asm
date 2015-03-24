;  Tests IO input functions

%include        'ascii.inc'

extern  put_string, exit_success, get_string, get_int, put_int, print_newline
global  _start

        segment .rodata
hwstr   db      'Hello, world!', CHAR_LF, CHAR_NUL
ystr    db      'You entered: ', CHAR_NUL
pstr    db      'Enter a string: ', CHAR_NUL
nstr    db      'Enter an integer: ', CHAR_NUL

        segment .bss
buffer  resb    128
n       resq    1

        segment .text

_start:
        lea     rdi, [pstr]
        call    put_string

        lea     rdi, [buffer]
        call    get_string

        lea     rdi, [ystr]
        call    put_string

        lea     rdi, [buffer]
        call    put_string

        lea     rdi, [nstr]
        call    put_string

        call    get_int
        mov     [n], rax

        lea     rdi, [ystr]
        call    put_string

        mov     rdi, [n]
        call    put_int

        call    print_newline

        call    exit_success
