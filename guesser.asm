;  Number guessing game

%include        'ascii.inc'

extern  put_string, exit_success, pgrandom, seedrandom
extern  get_int, put_int, put_char, print_newline, get_char_line
global  _start


        segment .bss

answer  resq    1                       ;  Variable to hold answer
turns   resq    1                       ;  Variable to hold number of turns


        segment .text


;  Program entry point

_start:
        call    start_program           ;  Welcome and initialize program

.gamestart:                             ;  New game starts here
        call    start_game              ;  Start new game

.turnstart:                             ;  New turn starts here
        call    get_guess               ;  Get the player's guess
        mov     rdi, rax                ;  Pass guess as argument and...
        call    eval_guess              ;  ...evaluate the guess

        cmp     rax, 0                  ;  Guess was right if return 0...
        jne     .turnstart              ;  ...so new turn if not 0.

.gameover:                              ;  Game ends here
        call    end_game                ;  Finish game
        call    query_new               ;  Ask for new game
        cmp     rax, 1                  ;  If return value was 0...
        je      .gamestart              ;  ...then start new game.

.end:                                   ;  Otherwise, exit program.
        call    exit_success


;  Initializes the program and prints a welcome message.
;  No arguments, no return value.

start_program:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .rodata

.msg1   db      'Guess The Number!', CHAR_LF, CHAR_NUL
.msg2   db      '=================', CHAR_LF, CHAR_NUL

        segment .text

        lea     rdi, [.msg1]            ;  Output welcome message
        call    put_string
        lea     rdi, [.msg2]
        call    put_string

        call    seedrandom              ;  Seed random number generator

        leave                           ;  Return
        ret


;  Initializes a new game.
;  No arguments, no return value.

start_game:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .rodata

.msg:
        db      "I'm thinking of a number between 1 and 100..."
        db      'can you guess it?', CHAR_LF, CHAR_NUL

        segment .text

        lea     rdi, [.msg]             ;  Output new game message
        call    put_string

        mov     rdi, 100                ;  Get a random number between...
        call    pgrandom                ;  ...0 and 99, inclusive.
        inc     rax                     ;  Add 1 to it...
        mov     [answer], rax           ;  ...and store as the answer.

        mov     QWORD [turns], 0        ;  Reset number of turns to zero

        leave                           ;  Return
        ret


;  Gets a guess from the player.
;  No arguments, returns player's guess.

get_guess:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .rodata

.msg    db      'Enter your guess: ', CHAR_NUL

        segment .text

        lea     rdi, [.msg]             ;  Prompt user for guess
        call    put_string

        call    get_int                 ;  Get the guess...

        leave                           ;  ...and return it.
        ret


;  Evaluates a guess.
;  Single argument is the guess to evaluate.
;  Returns:
;    -1 if guess is too low
;     1 if guess is too high
;     0 if guess is correct

eval_guess:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .rodata

.high   db      'Too high! Try again.', CHAR_LF, CHAR_NUL
.low    db      'Too low! Try again.', CHAR_LF, CHAR_NUL
.right  db      'You got it! It was ', CHAR_NUL
.endstr db      '.', CHAR_LF, CHAR_NUL

        segment .text

        cmp     rdi, QWORD [answer]     ;  Compare guess with answer
        jl      .toolow                 ;  Branch if guess is lower
        jg      .toohigh                ;  Branch if guess is higher

.correct:
        lea     rdi, [.right]           ;  Output initial message
        call    put_string

        mov     rdi, [answer]           ;  Output answer
        call    put_int

        lea     rdi, [.endstr]          ;  Output trailing message
        call    put_string

        xor     rax, rax                ;  Set return value to 0

        jmp     .end

.toolow:
        lea     rdi, [.low]             ;  Output message
        call    put_string

        mov     rax, -1                 ;  Set return value to -1

        jmp     .end

.toohigh:
        lea     rdi, [.high]            ;  Output message
        call    put_string

        mov     rax, 1                  ;  Set return value to 1

.end:
        inc     QWORD [turns]           ;  Increment number of turns taken
        leave                           ;  Return
        ret


;  Ends the game.
;  No arguments, no return

end_game:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .rodata

.msg1   db      'It took you ', CHAR_NUL
.msgp   db      ' turns.', CHAR_LF, CHAR_NUL
.msgs   db      ' turn.', CHAR_LF, CHAR_NUL

        segment .text

        lea     rdi, [.msg1]            ;  Output leading message
        call    put_string

        mov     rdi, [turns]            ;  Output number of turns
        call    put_int

        lea     rdi, [.msgp]            ;  Default is more than one turn
        lea     rsi, [.msgs]            ;  Load address for cmove
        cmp     QWORD [turns], 1        ;  If only one turn was needed...
        cmove   rdi, rsi                ;  ...use the singular, not the plural
        call    put_string              ;  Output trailing message

        leave                           ;  Return
        ret


;  Asks player if they want a new game.
;  No arguments.
;  Returns 1 if players wants a new game, 0 otherwise.

query_new:
        push    rbp                     ;  Set up stack
        mov     rbp, rsp

        segment .rodata

.msg    db      'Would you like to play again (y/n)? ', CHAR_NUL

        segment .text

        lea     rdi, [.msg]             ;  Prompt for new game
        call    put_string

        call    get_char_line

        cmp     rax, 'y'                ;  New game if 'y'
        je      .yes
        cmp     rax, 'Y'                ;  New game if 'Y'
        je      .yes

.no:
        mov     rax, 0                  ;  Otherwise end game, return 0
        jmp     .end

.yes:
        mov     rax, 1                  ;  Return 1 for new game

.end:
        leave                           ;  Return
        ret
