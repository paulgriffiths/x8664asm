;  unix.inc
;  
;  UNIX constants
;
;  Paul Griffiths, March 21, 2015

SC_READ         equ     0               ;  read system call constant
SC_WRITE        equ     1               ;  write system call constant
SC_OPEN         equ     2               ;  open system call constant
SC_CLOSE        equ     3               ;  close system call constant
SC_LSEEK        equ     8               ;  lseek system call constant
SC_PIPE         equ     22              ;  pipe system call constant
SC_DUP          equ     32              ;  dup system call constant
SC_DUP2         equ     33              ;  dup2 system call constant
SC_GETPID       equ     39              ;  getpid system call constant
SC_FORK         equ     57              ;  fork system call constant
SC_EXECVE       equ     59              ;  execve system call constant
SC_EXIT         equ     60              ;  exit system call constant
SC_WAIT4        equ     61              ;  wait4 system call constant
SC_TIME         equ     201             ;  time system call constant

STDIN           equ     0               ;  Standard input file descriptor
STDOUT          equ     1               ;  Standard output file descriptor
STDERR          equ     2               ;  Standard error file descriptor
