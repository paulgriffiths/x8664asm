;  Tests IO library functions with "Hello, World!" program.

%include        'ascii.inc'

extern  put_string, exit_success
global  _start

        segment .rodata
hwstr   db      'Hello, world!', CHAR_LF, CHAR_NUL

        segment .text

_start:
        lea     rdi, [hwstr]
        call    put_string
        call    exit_success
