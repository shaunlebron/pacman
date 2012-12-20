; 
; 
; - The stack is initialized to 0x4FC0, 64 bytes from the top of RAM
; - 4ff0-4fff 8 pairs of two bytes:
;     the first byte contains the sprite image number (bits 2-7),
;     Y flip (bit 0), X flip (bit 1); the second byte the color 
; 
; palette .7f 32x1 byte   32 discrete colors max
;     lookup  .4a 64x4 byte   64 four-color entries
; 
; strip msdos chars :
; cat msdoschars | perl -e 'while(<STDIN>){$_=~ s/\015//gem; print $_}' > unixized
; 
; - it'd be interesting to perform an FFT on the output from the functions at 521 and 528
; - How does the coin lockout work? (where is it referenced?)
; 
; Important RAM locations
; -----------------------
; service mode:
;     4E9C - Coin insert (==2) or start game (==1)
;     4EBC - Joystick Direction (up=8, left=4, right=16, down=32)
; 
; all other times:
;     $3B30 - important for fcns at 11735, 11758, 11764
;     $3B80 -
;     $403B - 0x2340 during game, 0x4340 otherwise
;     $4C02-4C0D - Initialized by functions at 9533 and/or 9743
;     $4C80/4C81 - End of message queue
;     $4C82/4C83 - Beginning of message queue
;     $4C8A - Flip-flops between 1 and 2 (seems to mostly be on 1, though)
;     $4C90-4CBD - 3-byte block queue
;     $4CC0-4D00 - Message queue
;     $4D00-4DD2 - Initialized by function at 9533
;     $4D0A - Red Y
;     $4D0B - Red X
;     $4D0C - Pink Y
;     $4D0D - Pink X
;     $4D0E - Blue Y
;     $4D0F - Blue X
;     $4D10 - Orange Y
;     $4D11 - Orange X
;     $4D12 - Pacman Y (predicted?)
;     $4D13 - Pacman X (predicted?)
;     $4D14 - Red Ghost Direction Iterator??? ( 0x00FF = right, 0x0100 = down, 0x0001 = left, 0xFF00 = up )
;     $4D16 - Pink Ghost Direction Iterator??? ( 0x00FF = right, 0x0100 = down, 0x0001 = left, 0xFF00 = up )
;     $4D18 - Blue Ghost Direction Iterator??? ( 0x00FF = right, 0x0100 = down, 0x0001 = left, 0xFF00 = up )
;     $4D1A - Orange Ghost Direction Iterator??? ( 0x00FF = right, 0x0100 = down, 0x0001 = left, 0xFF00 = up )
;     $4D1C - Pacman Position Predictor ( 0xFF00 = up, 0x00FF = right, 0x0100 = down, 0x0001 = left )
;     $4D1E - Red Position Predictor ( 0xFF00 = up, 0x00FF = right, 0x0100 = down, 0x0001 = left )
;     $4D26 - ?Delayed? Pacman Position Predictor ( 0xFF00 = up, 0x00FF = right, 0x0100 = down, 0x0001 = left )
;     // What's the difference?
;     $4D28 - Red Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
;     $4D29 - Pink Ghost Direction
;     $4D2A - Blue Ghost Direction
;     $4D2B - Orange Ghost Direction
;     $4D2C - Red Ghost Eye Direction ( 0=right, 1=down, 2=left, 3=up )
;     $4D2D - Pink Ghost Eye Direction
;     $4D2E - Blue Ghost Eye Direction
;     $4D2F - Orange Ghost Eye Direction
;     $4D39 - Pacman Y (22-3E)
;     $4D3A - Pacman X (21-3A)
;     $4D3B - Ghost (eyes?) direction [TEMP] ( 0=right, 1=down, 2=left, 3=up )
;     $4D3C - Pacman direction ( 0=right, 1=down, 2=left, 3=up )
;     $4D3D - $4D3B XOR 0x01, slightly lagged
;     $4D3E - Ghost Y (22-3E), $4D3F - Ghost X (21-3A)
;     $4D40 - Ghost's perceived Pacman Y (22-3E)/1D when Ghosts ignoring,
;     $4D41 - Ghost's perceived Pacman X (21-3A)/22 when Ghosts ignoring
;         Red - Red sees exactly where pacman was a split second before
;     $4D42 - Ghost Y (22-3E), $4D43 - Ghost X (21-3A) - but warped somehow
;     $4D44 - scratch
;     $4DA4 - 
;     $4DA5 - related to ghost eat-ability (cheat sets to 1 for perpetual eating), also related to 
;     $4DA6 - 0 = normal, 1 = ghosts blue, running away
;     $4DA7 - Red edible
;     $4DA8 - Pink edible
;     $4DA9 - Blue edible
;     $4DAA - Orange edible
;     $4DAB - Fruit edible?
;     $4DAC - Red chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
;     $4DAD - Pink chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
;     $4DAE - Blue chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
;     $4DAF - Orange chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
;     $4DB1/2/3/4 - Red/Pink/Blue/Orange reversal (?) ( set by frame_counter() )
;     $4DB6 - 1 if 224 dots have been eaten and all 4 ghosts are free, 0 otherwise
;     $4DC1 - ghost reversal status (altered by timer at $4DC2/3
;     $4DC2/3 - chase frames since board/pac start (paused during powerpill)
;     $4DC7 - scratch
;     $4DC9 - starts 0x0000 at level start, random gibberish while flee mode, static inbetween
;     $4DCE - 0-255 repeating frame counter?
;     $4DCF - 0-9 repeating frame counter?
;     $4DD0 - how many ghosts eaten this powerpill?
;     $4DD2 - ?
;     $4DD4 - ?
;     $4E00 - Sound Bank switcher
;             00 - Post-boot blanking
;             01 - Attract Screen
;             02 - Push Start / Get Ready
;             03 - Gameplay
;     $4E02 - Attract screen 'frames'
;             01 - Character / Nickname
;             03 - Red Ghost
;             05 - Shadow
;             07 - "Blinky"
;             09 - Pink Ghost
;             0B - Speedy
;             0D - "Pinky"
;             0F - Aqua Ghost
;             11 - Bashful
;             13 - "Inky"
;             15 - Yellow Ghost
;             17 - Pokey
;             19 - "Clyde"
;             1B - 10pts dot, 50pts dot
;             1D - &copy; 1980 MIDWAY MFG.CO.
;             1E-22 - Pacman Entrance, Ghost 1-4 Entrance
;             23 - demo game
;     $4E03 - Mode
;             00 - Attract Screen + Gameplay
;             01 - Push Start Button
;             03 - Game Start (Ready!)
;     $4E04 - Game 'frames'
;             00 - ?
;             02 - Maze, Ghosts, Pacman, Ready!
;             03 - Running game
;             09 - player change?
;             07 - Game Over
;             0D-1F - Level Clear Maze Flash
;             20 - Act 1/2/3
;             21-24 - Clear Level
; 
;     $4E06 - Act I Scenes
;             00 - Clear Screen
;             01 - Ghost and Pac across Screen
;             02-03 - Ghost and Pac offscreen
;             04 - Ghost going right
;             05 - Bigpac chasing
;             06 - Ghost offscreen
;             00 - Clear Screen
;     $4E07 - Act I Scenes
;             00 - Clear Screen
;             01 - Pac Appears
;             02 - Ghost Appears
;             03 - Pac passes peg
;             04-08 - Ghost Ripping sheet
;             0A - Ghost Looks up
;             0C - Ghost Looks at peg
;     $4E08 - Act III Scenes
;             00 - Clear screen
;             01 - Pac and Ghost
;             02 - Pac and Ghost offscreen
;             03-04 - unrobed ghost moving right
; 
;     $4E09 - current player ( 0=Player1, !0= Player2 )
;     $4E0C - 0 if num_dots_eaten < 0x40, 1 otherwise
;     $4E0D - 0 if num_dots_eaten < 0xB0, 1 otherwise
;     $4E0E - dots eaten this board
;     $4E13 - current board?
;     $4E14 - ??  (got extra life already?)
;     $4E15 - pacs left?
;     $4E16-$4E33 - bit mask of what dots have/have not been eaten yet 
;     $4E34-$4E37 - power pill statuses; 0x14 = not eaten, 0x40 - eaten (really, the indexes of the sprites)
; 
;     $4E66 - Always 0x0F?
;     $4E67 - Count up from 0x00..0x0F  Sound for coin2?  Debounce?
;     $4E68 - Count up from 0x00..0x0F  Sound for coin1?  Debounce?
;     $4E69 - Number of coins to announce via sound
;     $4E6B - Coins ( per credit )
;     $4E6D - Credits ( per coin )
;     $4E6E - Credits
;     $4E6F - Lives per game
;     $4E71 - Kilopoints for bonus pac in BCD. FF = no bonus
;     $4E72 - Upright ( 0 ) vs Cocktail ( 1 )
;     $4E73-$4E74 - Difficulty ( Normal=0x6800, Hard=0x7D00 )
;     $4E75 - Ghost Names ( On = normal, off = alternate )
;     $4E80-$4E83 - Player 1 score in BCD
;     $4E84-$4E87 - Player 2 score in BCD
;     $4E88-$4E8B - High Score in BCD
;     $4E8C-$4E91 - Sound 1 sound packet?
;     $4E92-$4E96 - Sound 2 sound packet?
;     $4E97-$4E9B - Sound 3 sound packet?
;     $4E9C - Sound 1 Waveform A? ( 0=gameplay, 2=coin drop)
;     $4EAC - Sound 2 Waveform A?
;     $4EBC - Sound 3 Waveform A?
;     $4ECC - Sound 1 Waveform Selector (0=Gameplay, 1=Intro Music, 2=Intermission Music)
;     $4ECF - Sound 1 Waveform B
;     $4EDC - Sound 2 Waveform Selector (0=Gameplay, 1=Intro Music, 2=Intermission Music)
;     $4EDF - Sound 2 Waveform B
;     $4EEC - Sound 3 Waveform Selector (0=Gameplay, 1=Intro Music, 2=Intermission Music)
;     $4EEF - Sound 3 Waveform B
; 
;     IN:
;     $5000 - IN0 - coin 3, coin 2, coin 1, rack test, 1 down, 1 right, 1 left, 1 up
;     $5040 - IN1 - cocktail/upright, Start 2, Start 1, service mode, 2 down, 2 right, 2 left, 2 up
;     $5080 - Jumper block - ; ghost names, difficulty, bonuslife 1, bonuslife 0 : lives 1, lives 0, coinage 1, coinage 0
; 
;     OUT:
;     $5002 - Enable Ms. Pac-Man aux board
;     $5003 - Screen Flip
;     $5004 - Player 1 Lamp
;     $5005 - Player 2 Lamp
;     $5006 - Coin Lockout
;     $5007 - Coin Counter
;     $5045 - Sound 1 Waveform
;     $504A - Sound 2 Waveform
;     $504F - Sound 3 Waveform
;     $5050-$5054 - Sound 1 Frequency
;     $5055 - Sound 1 Volume
;     $5056-$5059 - Sound 2 Frequency
;     $505A - Sound 2 Volume
;     $505B-$505E - Sound 3 Frequency
;     $505F - Sound 3 Volume
;     $5062-$506F - ??
;     $50C0 - Sound Enable (or watchdog)
; 
; 
; ----
; sound packet IX:
; 0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
; M       PS  S   S   S   S   S   S   S  S   VS1         T1  VS2
; 
; SQ = Sound Queue
; PS = Process Sound Data
; [M==PS==0 -> blindly return without processing sound data]
; S = copied from HL+((B-1)*8) [b=leftmost bit of $IX)
; VS1 = Volume Strategy (which RST20 @ 12033 to use?)
; VS2 = Parameter for vol strategy
; [note: if VS1&8==0, vol=VS2=9]
; T1 = Frequency scratch (for nybble-shifting)
; 
; 
; Red - Blinky: Oikake - "Akabei" (oikake-ru = to run down/to pursue/to chase down). Or of course the english "Shadow".. the guy is literally on your tail and can be thought of as your shadow
; 
; Pink - Pinky: Machibuse (machibuse = performing an ambush). Or in the english "speedy". He is indeed just as fast as Blinky and works with him to ambush and cut you off.
; 
; Blue - Inky: Kimagure - "Aosuke" (kimagure = fickle/moody/uneven temper). Or in english "Bashful". He is unpredictable. Sometimes he follows you, sometimes he goes away from you.
; 
; Orange - Clyde: Otoboke - "Guzuta" (Otoboke = Pretending Ignorance). The nick "Guzuta" means someone who lags behind). Or of course "pokey" in english. The guy is slow. He's always going somewhere on his own. But he does sometimes successfully cut you off, but almost never outright chases you.
; AF and SP are 0xFFFF on start

; DISASM is wrong:
;    opcode 0x11 generates argument in comments wrong
;    opcode 0x30 is jump if CARRY = 0, not CARRY = 1
;    opcode 0x31 is Load register pair SP, not HL
;    opcode 0x36 is load LOCATION HL, not register pair
;    opcode 0x38 is jump RELATIVE, not jump to
;    opcode 0x38 is jump if CARRY = 1, not CARRY = 0
;    opcode 0xa7 is location (HL), not Accumulator  // WRONG!  0xa7 _IS_ (A & A)
;    opcode 0xDDCD00 at 9379 is incorrect, it is "LD B,RLC (IX+d)"
;    opcode 0xDD36ddnn is incorrect, it is "LD (IX+d), n"
;    opcode 0xeb is REGISTER PAIR DE, not location
;    opcode 0xff is RST 0x38, not 0x30
;    DD opcode at 5781 is commented wrong; DD/FD @ 11769 is wrong, too
;    DD B6 is OR, not XOR
;    DDCB are all wrong (11921, 11935, 11939, 11945)
;    FD36 is wrong (should be load, not decrement)

; ( rst 0 - reboot )
[0x0] 0       0xf3    DI                          ;  Disable Interrupts
[0x1] 1       0x3e    LD A,N          3f          ;  Load Accumulator with 0x3f (63)
; This sets the Int tables to 0x3f00
[0x3] 3       0xed    LD I, A                     ;  Load the register I with Accumulator
[0x5] 5       0xc3    JP NN           0b23        ;  Jump to 0x0b23 (8971)

; ( rst 8 - Fill (HL)...(HL+B) with Accumulator )
[0x8] 8       0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x9] 9       0x23    INC HL                      ;  Increment register pair HL
[0xa] 10      0x10    DJNZ N          fc          ;  Decrement B and jump relative 0xfc (-4) if B!=0
[0xc] 12      0xc9    RET                         ;  Return


[0xd] 13      0xc3    JP NN           0e07        ;  Jump to 0x0e07 (1806)

; ( rst 10 )
; HL = HL + A;
; A = (char *)HL;
;;; A = $(HL + A);
[0x10] 16      0x85    ADD A, L                    ;  Add register L to Accumulator (no carry)
[0x11] 17      0x6f    LD L, A                     ;  Load register L with Accumulator
[0x12] 18      0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
[0x14] 20      0x8c    ADC A, H                    ;  Add with carry register H to Accumulator
[0x15] 21      0x67    LD H, A                     ;  Load register H with Accumulator
[0x16] 22      0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x17] 23      0xc9    RET                         ;  Return

; table_and_index_to_address(HL==table, B==index)  ( rst 18 )
;;;; aka short_load(table, index)
;     returns DE==address, HL=data_at_index;
; // HL == address of table of data
; // B  == index into that table
;
; A = B;
; A *= 2;
; // HL = HL + A;          // via rst 10
; // A = (char *)HL;       // via rst 10
; E = A;
; HL++;
; D = (char *)HL;
; DE = HL, HL = DE;
;
; // HL == 16 bit data at table + index (*2)
; // DE == address+1 of the index that contains what is now in HL
;
[0x18] 24      0x78    LD A, B                     ;  Load Accumulator with register B
[0x19] 25      0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x1a] 26      0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
[0x1b] 27      0x5f    LD E, A                     ;  Load register E with Accumulator
[0x1c] 28      0x23    INC HL                      ;  Increment register pair HL
[0x1d] 29      0x56    LD D, (HL)                  ;  Load register D with location (HL)
[0x1e] 30      0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x1f] 31      0xc9    RET                         ;  Return

; ( rst 20 )
; jump forward from calling point, based on value of A
; if A=0, jump to the address in the 2 bytes following the
; calling point (SP).  If A=1, jump to (SP+2), etc.
; RST 10 in the middle advances HL by A.
[0x20] 32      0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x21] 33      0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x22] 34      0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
[0x23] 35      0x5f    LD E, A                     ;  Load register E with Accumulator
[0x24] 36      0x23    INC HL                      ;  Increment register pair HL
[0x25] 37      0x56    LD D, (HL)                  ;  Load register D with location (HL)
[0x26] 38      0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x27] 39      0xe9    JP (HL)                     ;  Jump to location (HL)

;;; insert_display_list_PC();
; ( rst 28 )
; Take the two bytes after the jump point, put them in BC, push the jump point + 2 back on the stack,
; then jump to insert_msg();
[0x28] 40      0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x29] 41      0x46    LD B, (HL)                  ;  Load register B with location (HL)
[0x2a] 42      0x23    INC HL                      ;  Increment register pair HL
[0x2b] 43      0x4e    LD C, (HL)                  ;  Load register C with location (HL)
[0x2c] 44      0x23    INC HL                      ;  Increment register pair HL
[0x2d] 45      0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x2e] 46      0x18    JR N            12          ;  Jump relative 0x12 (18)

;;; insert_msg();
; Interrupt 250 ( rst 30 ) - insert a 3 byte message into the 16 slot message queue at $4C90
; Pop the location from the stack, which is the first byte after the opcode that called this,
; and copy the 3 bytes the location refers to into the first open 3 byte block in $4C90-$4CBD.  Then
; jump to the location following those three bytes.
[0x30] 48      0x11    LD  DE, NN      904c        ;  Load register pair DE with 0x904c (19600)
[0x33] 51      0x06    LD  B, N        10          ;  Load register B with 0x10 (16)
[0x35] 53      0xc3    JP NN           5100        ;  Jump to 0x5100 (81)

; ( rst 38 - Kick the Watchdog, Kick the Coin Counter, Repeat )
[0x38] 56      0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x39] 57      0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
[0x3c] 60      0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
[0x3f] 63      0xc3    JP NN           3800        ;  Jump to 0x3800 (56)


;;; insert_display_list();
; // BC == new queue msg, B == index into call table, C == param;
; ($4C80) = BC;
; $4C80 = ($4C80) + 2 // with the constraint that it wraps around 255 to 192
[0x42] 66      0x2a    LD HL, (NN)     804c        ;  Load register pair HL with location 0x804c (19584)
[0x45] 69      0x70    LD (HL), B                  ;  Load location (HL) with register B
[0x46] 70      0x2c    INC L                       ;  Increment register L
[0x47] 71      0x71    LD (HL), C                  ;  Load location (HL) with register C
[0x48] 72      0x2c    INC L                       ;  Increment register L
[0x49] 73      0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
[0x4b] 75      0x2e    LD L,N          c0          ;  Load register L with 0xc0 (192)
[0x4d] 77      0x22    LD (NN), HL     804c        ;  Load location 0x804c (19584) with the register pair HL
[0x50] 80      0xc9    RET                         ;  Return


; ( rst 30 - continuation )
; Find the next open 3 byte block in $4C90-$4CBD
[0x51] 81      0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
[0x52] 82      0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
[0x53] 83      0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
[0x55] 85      0x1c    INC E                       ;  Increment register E
[0x56] 86      0x1c    INC E                       ;  Increment register E
[0x57] 87      0x1c    INC E                       ;  Increment register E
[0x58] 88      0x10    DJNZ N          f7          ;  Decrement B and jump relative 0xf7 (-9) if B!=0
[0x5a] 90      0xc9    RET                         ;  Return
; Copy (stack)...(stack+2) to (DE)...(DE+2)
[0x5b] 91      0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x5c] 92      0x06    LD  B, N        03          ;  Load register B with 0x03 (3)
[0x5e] 94      0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x5f] 95      0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
[0x60] 96      0x23    INC HL                      ;  Increment register pair HL
[0x61] 97      0x1c    INC E                       ;  Increment register E
[0x62] 98      0x10    DJNZ N          fa          ;  Decrement B and jump relative 0xfa (-6) if B!=0
; Jump to (stack+3)
[0x64] 100     0xe9    JP (HL)                     ;  Jump to location (HL)

; YX_to_playfieldaddr()
[0x65] 101     0xc3    JP NN           2d20        ;  Jump to 0x2d20 (8237)

; Level Difficulty Table - Normal
;104 - 124
;    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x08, 0x09
;    0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14

; Level Difficulty Table - Hard
;125 - 140
;    0x01, 0x03, 0x04, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D
;    0x0E, 0x0F, 0x10, 0x11, 0x14


;;; vsync_game
;
;
;
; Push AF, Kick Watchdog, Clear VBlank Interrupt, Disable Interrupts, Push the rest of the registers
[0x8d] 141     0xf5    PUSH AF                     ;  Load the stack with register pair AF
[0x8e] 142     0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x91] 145     0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x92] 146     0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
[0x95] 149     0xf3    DI                          ;  Disable Interrupts
[0x96] 150     0xc5    PUSH BC                     ;  Load the stack with register pair BC
[0x97] 151     0xd5    PUSH DE                     ;  Load the stack with register pair DE
[0x98] 152     0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x99] 153     0xdd    PUSH IX                     ;  Load the stack with register pair IX
[0x9b] 155     0xfd    PUSH IY                     ;  Load the stack with register pair IY
; copy $4E8C..$4E9B -> $5050..$505F   (Sound 1/2/3 Freq and Volume)
[0x9d] 157     0x21    LD HL, NN       8c4e        ;  Load register pair HL with 0x8c4e (20108)
[0xa0] 160     0x11    LD  DE, NN      5050        ;  Load register pair DE with 0x5050 (80)
[0xa3] 163     0x01    LD  BC, NN      1000        ;  Load register pair BC with 0x1000 (16)
[0xa6] 166     0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; decrement BC; repeat until BC == 0
; if ( $4ECC == 0 ) { $5045 = $4E9F; } else { $5045 = $4ECF; }
[0xa8] 168     0x3a    LD A, (NN)      cc4e        ;  Load Accumulator with location 0xcc4e (20172)
[0xab] 171     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xac] 172     0x3a    LD A, (NN)      cf4e        ;  Load Accumulator with location 0xcf4e (20175)
[0xaf] 175     0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
[0xb1] 177     0x3a    LD A, (NN)      9f4e        ;  Load Accumulator with location 0x9f4e (20127)
[0xb4] 180     0x32    LD (NN), A      4550        ;  Load location 0x4550 (20549) with the Accumulator
; if ( $4EDC == 0 ) { $504A = $4EAF; } else { $504A = $4EDF; }
[0xb7] 183     0x3a    LD A, (NN)      dc4e        ;  Load Accumulator with location 0xdc4e (20188)
[0xba] 186     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xbb] 187     0x3a    LD A, (NN)      df4e        ;  Load Accumulator with location 0xdf4e (20191)
[0xbe] 190     0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
[0xc0] 192     0x3a    LD A, (NN)      af4e        ;  Load Accumulator with location 0xaf4e (20143)
[0xc3] 195     0x32    LD (NN), A      4a50        ;  Load location 0x4a50 (20554) with the Accumulator
; if ( $4EEC == 0 ) { $504F = $4EBF; } else { $504F = $4EEF; }
[0xc6] 198     0x3a    LD A, (NN)      ec4e        ;  Load Accumulator with location 0xec4e (20204)
[0xc9] 201     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xca] 202     0x3a    LD A, (NN)      ef4e        ;  Load Accumulator with location 0xef4e (20207)
[0xcd] 205     0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
[0xcf] 207     0x3a    LD A, (NN)      bf4e        ;  Load Accumulator with location 0xbf4e (20159)
[0xd2] 210     0x32    LD (NN), A      4f50        ;  Load location 0x4f50 (20559) with the Accumulator
; copy $4C02..$4C1D -> $4C22..$4C3D
[0xd5] 213     0x21    LD HL, NN       024c        ;  Load register pair HL with 0x024c (19458)
[0xd8] 216     0x11    LD  DE, NN      224c        ;  Load register pair DE with 0x224c (34)
[0xdb] 219     0x01    LD  BC, NN      1c00        ;  Load register pair BC with 0x1c00 (28)
[0xde] 222     0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; decrement BC; repeat until BC == 0
; foreach loc ($4C22, $4C24, $4C26, $4C28, $4C2A, $4C2C) { loc *= 4; }
[0xe0] 224     0xdd    LD IX, NN       204c        ;  Load register pair IX with 0x204c (19488)
[0xe4] 228     0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
[0xe7] 231     0x07    RLCA                        ;  Rotate left circular Accumulator
[0xe8] 232     0x07    RLCA                        ;  Rotate left circular Accumulator
[0xe9] 233     0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
[0xec] 236     0xdd    LD A, (IX+d)    04          ;  Load Accumulator with location ( IX + 0x04 () )
[0xef] 239     0x07    RLCA                        ;  Rotate left circular Accumulator
[0xf0] 240     0x07    RLCA                        ;  Rotate left circular Accumulator
[0xf1] 241     0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
[0xf4] 244     0xdd    LD A, (IX+d)    06          ;  Load Accumulator with location ( IX + 0x06 () )
[0xf7] 247     0x07    RLCA                        ;  Rotate left circular Accumulator
[0xf8] 248     0x07    RLCA                        ;  Rotate left circular Accumulator
[0xf9] 249     0xdd    LD (IX+d), A    06          ;  Load location ( IX + 0x06 () ) with Accumulator
[0xfc] 252     0xdd    LD A, (IX+d)    08          ;  Load Accumulator with location ( IX + 0x08 () )
[0xff] 255     0x07    RLCA                        ;  Rotate left circular Accumulator
[0x100] 256     0x07    RLCA                        ;  Rotate left circular Accumulator
[0x101] 257     0xdd    LD (IX+d), A    08          ;  Load location ( IX + 0x08 () ) with Accumulator
[0x104] 260     0xdd    LD A, (IX+d)    0a          ;  Load Accumulator with location ( IX + 0x0a () )
[0x107] 263     0x07    RLCA                        ;  Rotate left circular Accumulator
[0x108] 264     0x07    RLCA                        ;  Rotate left circular Accumulator
[0x109] 265     0xdd    LD (IX+d), A    0a          ;  Load location ( IX + 0x0a () ) with Accumulator
[0x10c] 268     0xdd    LD A, (IX+d)    0c          ;  Load Accumulator with location ( IX + 0x0c () )
[0x10f] 271     0x07    RLCA                        ;  Rotate left circular Accumulator
[0x110] 272     0x07    RLCA                        ;  Rotate left circular Accumulator
[0x111] 273     0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
; if ( $4DD1 != 1 )
; {
;     IX = 0x4C20 + ( $4DA4 * 2 );
;     swap($4C24, $IX);  swap($4C34, $(IX+16));
;     //  HL = $4C24/5;  DE = $4C34/5;
;     //  $4C24 = $IX;  $4C25 = $(IX+1);
;     //  $4C34 = $(IX+16); $4C35 = $(IX+17);
;     //  $IX = HL;  $(IX+16) = DE;
; }
[0x114] 276     0x3a    LD A, (NN)      d14d        ;  Load Accumulator with location 0xd14d (19921)
[0x117] 279     0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x119] 281     0x20    JR NZ, N        38          ;  Jump relative 0x38 (56) if ZERO flag is 0
[0x11b] 283     0xdd    LD IX, NN       204c        ;  Load register pair IX with 0x204c (19488)
[0x11f] 287     0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
[0x122] 290     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x123] 291     0x5f    LD E, A                     ;  Load register E with Accumulator
[0x124] 292     0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x126] 294     0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x128] 296     0x2a    LD HL, (NN)     244c        ;  Load register pair HL with location 0x244c (19492)
[0x12b] 299     0xed    LD DE, (NN)     344c        ;  Load register pair DE with location 0x344c (19508)
[0x12f] 303     0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
[0x132] 306     0x32    LD (NN), A      244c        ;  Load location 0x244c (19492) with the Accumulator
[0x135] 309     0xdd    LD A, (IX+d)    01          ;  Load Accumulator with location ( IX + 0x01 () )
[0x138] 312     0x32    LD (NN), A      254c        ;  Load location 0x254c (19493) with the Accumulator
[0x13b] 315     0xdd    LD A, (IX+d)    10          ;  Load Accumulator with location ( IX + 0x10 () )
[0x13e] 318     0x32    LD (NN), A      344c        ;  Load location 0x344c (19508) with the Accumulator
[0x141] 321     0xdd    LD A, (IX+d)    11          ;  Load Accumulator with location ( IX + 0x11 () )
[0x144] 324     0x32    LD (NN), A      354c        ;  Load location 0x354c (19509) with the Accumulator
[0x147] 327     0xdd    LD (IX+d), L    00          ;  Load location ( IX + 0x00 () ) with register L
[0x14a] 330     0xdd    LD (IX+d), H    01          ;  Load location ( IX + 0x01 () ) with register H
[0x14d] 333     0xdd    LD (IX+d), E    10          ;  Load location ( IX + 0x10 () ) with register E
[0x150] 336     0xdd    LD (IX+d), D    11          ;  Load location ( IX + 0x11 () ) with register D
; if ( $4DA6 != 0 )
;     swap($4C22, $4C2A);  swap($4C32, $4C3A);
[0x153] 339     0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
[0x156] 342     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x157] 343     0xca    JP Z,           7601        ;  Jump to 0x7601 (374) if ZERO flag is 1
[0x15a] 346     0xed    LD BC, (NN)     224c        ;  Load register pair BC with location 0x224c (19490)
[0x15e] 350     0xed    LD DE, (NN)     324c        ;  Load register pair DE with location 0x324c (19506)
[0x162] 354     0x2a    LD HL, (NN)     2a4c        ;  Load register pair HL with location 0x2a4c (19498)
[0x165] 357     0x22    LD (NN), HL     224c        ;  Load location 0x224c (19490) with the register pair HL
[0x168] 360     0x2a    LD HL, (NN)     3a4c        ;  Load register pair HL with location 0x3a4c (19514)
[0x16b] 363     0x22    LD (NN), HL     324c        ;  Load location 0x324c (19506) with the register pair HL
[0x16e] 366     0xed    LD (NN), BC     2a4c        ;  Load location 0x2a4c (19498) with register pair BC
[0x172] 370     0xed    LD (NN), DE     3a4c        ;  Load location 0x3a4c (19514) with register pair DE
; copy $4C22..$4C2D to $4CF2..$4CFD
[0x176] 374     0x21    LD HL, NN       224c        ;  Load register pair HL with 0x224c (19490)
[0x179] 377     0x11    LD  DE, NN      f24f        ;  Load register pair DE with 0xf24f (242)
[0x17c] 380     0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
[0x17f] 383     0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
; copy $4C32..$4C3D to $5062..$506D
[0x181] 385     0x21    LD HL, NN       324c        ;  Load register pair HL with 0x324c (19506)
[0x184] 388     0x11    LD  DE, NN      6250        ;  Load register pair DE with 0x6250 (98)
[0x187] 391     0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
[0x18a] 394     0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
; uptime_counter();  process_messages();  call_968();
[0x18c] 396     0xcd    CALL NN         dc01        ;  Call to 0xdc01 (476) // uptime_counter()
[0x18f] 399     0xcd    CALL NN         2102        ;  Call to 0x2102 (545) // process_messages()
[0x192] 402     0xcd    CALL NN         c803        ;  Call to 0xc803 (968)
; if ( $4E00 != 0 )
; {  /*make a bunch of calls*/  }
[0x195] 405     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x198] 408     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x199] 409     0x28    JR Z, N         12          ;  Jump relative 0x12 (18) if ZERO flag is 1
[0x19b] 411     0xcd    CALL NN         9d03        ;  Call to 0x9d03 (925)
[0x19e] 414     0xcd    CALL NN         9014        ;  Call to 0x9014 (5264)
[0x1a1] 417     0xcd    CALL NN         1f14        ;  Call to 0x1f14 (5151)
[0x1a4] 420     0xcd    CALL NN         6702        ;  Call to 0x6702 (615)
[0x1a7] 423     0xcd    CALL NN         ad02        ;  Call to 0xad02 (685)
[0x1aa] 426     0xcd    CALL NN         fd02        ;  Call to 0xfd02 (765)
; if ( $4E00 - 1 == 0 )
; { $4EAC = $4EBC = 0; }
[0x1ad] 429     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x1b0] 432     0x3d    DEC A                       ;  Decrement Accumulator
[0x1b1] 433     0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
[0x1b3] 435     0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
[0x1b6] 438     0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator
; call_11532(); call_11457();
[0x1b9] 441     0xcd    CALL NN         0c2d        ;  Call to 0x0c2d (11532)
[0x1bc] 444     0xcd    CALL NN         c12c        ;  Call to 0xc12c (11457)
; Pop most registers
[0x1bf] 447     0xfd    POP IY                      ;  Load register pair IY with top of stack
[0x1c1] 449     0xdd    POP IX                      ;  Load register pair IX with top of stack
[0x1c3] 451     0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x1c4] 452     0xd1    POP DE                      ;  Load register pair DE with top of stack
[0x1c5] 453     0xc1    POP BC                      ;  Load register pair BC with top of stack
; if ( $4E00 != 0 && ( $5040 & 0x10 ) ) { reset; } // $5040.4 == service mode
[0x1c6] 454     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x1c9] 457     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1ca] 458     0x28    JR Z, N         08          ;  Jump relative 0x08 (8) if ZERO flag is 1
[0x1cc] 460     0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x1cf] 463     0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
[0x1d1] 465     0xca    JP Z,           0000        ;  Jump to 0x0000 (0) if ZERO flag is 1
; Set V-Sync Interupt, Enable Interrupts, Pop AF
[0x1d4] 468     0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x1d6] 470     0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
[0x1d9] 473     0xfb    EI                          ;  Enable Interrupts
[0x1da] 474     0xf1    POP AF                      ;  Load register pair AF with top of stack
[0x1db] 475     0xc9    RET                         ;  Return



; uptime_counter()
; {
;     //// I think this is full of bugs.  It seems to work by flip/flopping the HL/DE pairs properly only after
;     //// a wrapped counter, otherwise the INC $HL at 489 tries to increment a location in ROM.  I may be
;     //// incorrect, though.  It may require a very careful walkthough.
;     // keep the following up to date
;     // $4C84 = Frame counter, increasing per frame (wraps)
;     // $4C85 = Frame counter, decreasing per frame (wraps)
;     // $4C86 = Sec.frame counter, first digit is tenths of a sec, second digit is sixths of that tenth
;     // $4C87 = Seconds since reboot 0-59 (carries to minutes on wrap)
;     // $4C88 = Minutes since reboot 0-59 (carries to hours on wrap)
;     // $4C89 = Hours since reboot 0-99   (wraps back to 00)
;     // $4C8A = Number of wraps in last sec.frame 1-3; each counts as one: a frame, Sec.frame.1 wrap, sec.frame.2 wrap
;     // $4C8B = Randomness Generator 1
;     // $4C8C = Randomness Generator 2
;     $4C84++;  $4C85--;
;     foreach($4C86, $4C87, $4C88, $4C89)
;     {
;         // using the appropriate digit comparator in the table at 537
;         check first digit for wrap;
;         check second digit for wrap;
;     }
;     $4C8A = wrap_count;  // (but ONLY for $4C86)
;     $4C8B = ( $4C8B * 5 ) + 1;
;     $4C8C = ( $4C8C * 13 ) + 1;
; }
; $4C84++;  $4C85--;  $4C86++;
[0x1dc] 476     0x21    LD HL, NN       844c        ;  Load register pair HL with 0x844c (19588)
[0x1df] 479     0x34    INC (HL)                    ;  Increment location (HL)
[0x1e0] 480     0x23    INC HL                      ;  Increment register pair HL
[0x1e1] 481     0x35    DEC (HL)                    ;  Decrement location (HL)
[0x1e2] 482     0x23    INC HL                      ;  Increment register pair HL
[0x1e3] 483     0x11    LD  DE, NN      1902        ;  Load register pair DE with 0x1902 (537)
[0x1e6] 486     0x01    LD  BC, NN      0104        ;  Load register pair BC with 0x0104 (1025)
; Our loop begins here
[0x1e9] 489     0x34    INC (HL)                    ;  Increment location (HL)
[0x1ea] 490     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1eb] 491     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x1ed] 493     0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
; if first digit has wrapped
[0x1ee] 494     0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x1ef] 495     0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
; increase wrap count
[0x1f1] 497     0x0c    INC C                       ;  Increment register C
; add one to the second digit and store back
[0x1f2] 498     0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
[0x1f3] 499     0xc6    ADD A, N        10          ;  Add 0x10 (16) to Accumulator (no carry)
[0x1f5] 501     0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
[0x1f7] 503     0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
; if second digit has wrapped
[0x1f8] 504     0x23    INC HL                      ;  Increment register pair HL
[0x1f9] 505     0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x1fa] 506     0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
; increase wrap count
[0x1fc] 508     0x0c    INC C                       ;  Increment register C
[0x1fd] 509     0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
; reset that counter
[0x1fe] 510     0x36    LD (HL), N    00            ;  Load register pair HL with 0x00 (0)
[0x200] 512     0x23    INC HL                      ;  Increment register pair HL
[0x201] 513     0x13    INC DE                      ;  Increment register pair DE
[0x202] 514     0x10    DJNZ N          e5          ;  Decrement B and jump relative 0xe5 (-27) if B!=0
; store wrap count
[0x204] 516     0x21    LD HL, NN       8a4c        ;  Load register pair HL with 0x8a4c (19594)
[0x207] 519     0x71    LD (HL), C                  ;  Load location (HL) with register C
;; Pattern Generator 1
; $4C8B = ( $4C8B * 5 ) + 1;
[0x208] 520     0x2c    INC L                       ;  Increment register L
[0x209] 521     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x20a] 522     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x20b] 523     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x20c] 524     0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
[0x20d] 525     0x3c    INC A                       ;  Increment Accumulator
[0x20e] 526     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
;; Pattern Generator 2
; $4C8C = ( $4C8C * 13 ) + 1;
[0x20f] 527     0x2c    INC L                       ;  Increment register L
[0x210] 528     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x211] 529     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x212] 530     0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
[0x213] 531     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x214] 532     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x215] 533     0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
[0x216] 534     0x3c    INC A                       ;  Increment Accumulator
[0x217] 535     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x218] 536     0xc9    RET                         ;  Return

; Table used for digit wrapping code at 489:
;         0x06, 0xA0, 0x0A, 0x60, 0x0A, 0x60, 0x0A, 0xA0
;          6  , 160 ,  10 ,  96 ,  10 ,  96 ,  10 ,  160


;;; process_messages()
;;; Interesting things to note about these messages:
;;; if the first byte is 0, then skip it
;;; the highest two bits of the first byte must be higher than $4C8A, or it will get skipped
;;; the lowest six bits of the first byte must be zero, or it will get skipped
;;; there's only 10 jump points, and it looks like only one of them takes parameters
;;;
;;; process_messages()
;;; {
;;;     foreach message ( message_queue )
;;;     {
;;;         if ( message.0 == 0 ) {  next;  }
;;;         if ( ( message.0 & 0xC0 ) << 2 > $4C8A ) {  next;  }
;;;         message.0--;
;;;         A = message.0;
;;;         if ( A & 0x3F ), next;
;;;         message.0 = A & 0x3F;
;;;         push BC; // B = 16 - message_queue.index, C = $4C8A
;;;         push HL; // points to the current msg
;;;         A = message.1;
;;;         B = message.2;
;;;         push 0x025B;  // return point after the rst20 == 603
;;;         RST20(); // includes a pop on return...
;;;         pop HL;
;;;         pop BC;
;;;     }
;;; }
[0x221] 545     0x21    LD HL, NN       904c        ;  Load register pair HL with 0x904c (19600)
[0x224] 548     0x3a    LD A, (NN)      8a4c        ;  Load Accumulator with location 0x8a4c (19594)
[0x227] 551     0x4f    LD c, A                     ;  Load register C with Accumulator
[0x228] 552     0x06    LD  B, N        10          ;  Load register B with 0x10 (16)
[0x22a] 554     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x22b] 555     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x22c] 556     0x28    JR Z, N         2f          ;  Jump relative 0x2f (47) if ZERO flag is 1
[0x22e] 558     0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
[0x230] 560     0x07    RLCA                        ;  Rotate left circular Accumulator
[0x231] 561     0x07    RLCA                        ;  Rotate left circular Accumulator
[0x232] 562     0xb9    CP A, C                     ;  Compare register C with Accumulator
[0x233] 563     0x30    JR NC, N        28          ;  Jump relative 0x28 (40) if CARRY flag is 0
[0x235] 565     0x35    DEC (HL)                    ;  Decrement location (HL)
[0x236] 566     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x237] 567     0xe6    AND N           3f          ;  Bitwise AND of 0x3f (63) to Accumulator
[0x239] 569     0x20    JR NZ, N        22          ;  Jump relative 0x22 (34) if ZERO flag is 0
[0x23b] 571     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x23c] 572     0xc5    PUSH BC                     ;  Load the stack with register pair BC
[0x23d] 573     0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x23e] 574     0x2c    INC L                       ;  Increment register L
[0x23f] 575     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x240] 576     0x2c    INC L                       ;  Increment register L
[0x241] 577     0x46    LD B, (HL)                  ;  Load register B with location (HL)
[0x242] 578     0x21    LD HL, NN       5b02        ;  Load register pair HL with 0x5b02 (603)
[0x245] 581     0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x246] 582     0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : 0x0894 // increment $4E04
; 1 : 0x06A3 // increment $4E03
; 2 : 0x058E // increment $4E02
; 3 : 0x1272 // increment $4DD1
; 4 : 0x1000 // clear $4DD2, $4DD3, $4DD4
; 5 : 0x100B // display_erase("100" (stylized)) by way of write_msg() , write memory ok if A!=1
; 6 : 0x0263 // display_erase("READY!") by way of write_msg()
; 7 : 0x212B // increment $4E06 (Act I Scenes)
; 8 : 0x21F0 // increment $4E07 (Act II Scenes)
; 9 : 0x22B9 // increment $4E08 (Act III Scenes)
[0x25b] 603     0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x25c] 604     0xc1    POP BC                      ;  Load register pair BC with top of stack
[0x25d] 605     0x2c    INC L                       ;  Increment register L
[0x25e] 606     0x2c    INC L                       ;  Increment register L
[0x25f] 607     0x2c    INC L                       ;  Increment register L
[0x260] 608     0x10    DJNZ N          c8          ;  Decrement B and jump relative 0xc8 (-56) if B!=0
[0x262] 610     0xc9    RET                         ;  Return


; display_erase("READY!") by way of write_msg();
[0x263] 611     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x86
[0x266] 614     0xc9    RET                         ;  Return


; $5006 = $4E6E << 1;  // really weird bit of logic in here. carry bit will always be 1, gets rotated into a:0
; if ( $4E6E > 0x99 )  return;  // if ( credits > 99 ) {  return;  }
[0x267] 615     0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
[0x26a] 618     0xfe    CP N            99          ;  Compare 0x99 (153) with Accumulator
[0x26c] 620     0x17    RLA                         ;  Rotate left Accumulator through carry
[0x26d] 621     0x32    LD (NN), A      0650        ;  Load location 0x0650 (20486) with the Accumulator
[0x270] 624     0x1f    RRA                         ;  Rotate right Accumulator through carry
[0x271] 625     0xd0    RET NC                      ;  Return if CARRY flag is 0
; A = $5000;
; B = A;
;; Coin 3
; B <<cir 1;
; A = $4E66; A <<carry= 1;
; A &= 0x0F;
; $4E66 = A;
; if ( A == 0x0C ) call_735;  // coin_advance();
;; Coin 2
; B cir<<= 1;
; A = $4E67; A <<carry= 1
; A &= 0x0F;
; $4E67 = A;
; if ( A == 0x0C ) $4E69++;
;; Coin 1
; B cir<<= 1;
; A = $4E68; A <<carry= 1
; A &= 0x0F;
; $4E68 = A;
; if ( A == 0x0C ) $4E69++;
; return;
[0x272] 626     0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
[0x275] 629     0x47    LD B, A                     ;  Load register B with Accumulator
[0x276] 630     0xcb    RLC B                       ;  Rotate register B left circular
[0x278] 632     0x3a    LD A, (NN)      664e        ;  Load Accumulator with location 0x664e (20070)
[0x27b] 635     0x17    RLA                         ;  Rotate left Accumulator through carry
[0x27c] 636     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x27e] 638     0x32    LD (NN), A      664e        ;  Load location 0x664e (20070) with the Accumulator
[0x281] 641     0xd6    SUB N           0c          ;  Subtract 0x0c (12) from Accumulator (no carry)
[0x283] 643     0xcc    CALL Z,NN       df02        ;  Call to 0xdf02 (735) if ZERO flag is 1
[0x286] 646     0xcb    RLC B                       ;  Rotate register B left circular
[0x288] 648     0x3a    LD A, (NN)      674e        ;  Load Accumulator with location 0x674e (20071)
[0x28b] 651     0x17    RLA                         ;  Rotate left Accumulator through carry
[0x28c] 652     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x28e] 654     0x32    LD (NN), A      674e        ;  Load location 0x674e (20071) with the Accumulator
[0x291] 657     0xd6    SUB N           0c          ;  Subtract 0x0c (12) from Accumulator (no carry)
[0x293] 659     0xc2    JP NZ, NN       9a02        ;  Jump to 0x9a02 (666) if ZERO flag is 0
[0x296] 662     0x21    LD HL, NN       694e        ;  Load register pair HL with 0x694e (20073)
[0x299] 665     0x34    INC (HL)                    ;  Increment location (HL)
[0x29a] 666     0xcb    RLC B                       ;  Rotate register B left circular
[0x29c] 668     0x3a    LD A, (NN)      684e        ;  Load Accumulator with location 0x684e (20072)
[0x29f] 671     0x17    RLA                         ;  Rotate left Accumulator through carry
[0x2a0] 672     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x2a2] 674     0x32    LD (NN), A      684e        ;  Load location 0x684e (20072) with the Accumulator
[0x2a5] 677     0xd6    SUB N           0c          ;  Subtract 0x0c (12) from Accumulator (no carry)
[0x2a7] 679     0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x2a8] 680     0x21    LD HL, NN       694e        ;  Load register pair HL with 0x694e (20073)
[0x2ab] 683     0x34    INC (HL)                    ;  Increment location (HL)
[0x2ac] 684     0xc9    RET                         ;  Return


; if ( A = $4E69 == 0 ) return;
; B = A;
; E = A = $4E6A;
; if ( A == 0 )  // if $4E6A == 0
; {  $5007 = 0x01;  call_735();  }
; A = E;  // E == $4E6A;
; if ( A == 0x08 )
; {  $5007 = 0;  }
; $4E6A = A = E++;
; if ( ( A -= 0x10 ) != 0 )  return;
; $4E6A = A;
; $4E69 = A = B--;
; return;
[0x2ad] 685     0x3a    LD A, (NN)      694e        ;  Load Accumulator with location 0x694e (20073)
[0x2b0] 688     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2b1] 689     0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2b2] 690     0x47    LD B, A                     ;  Load register B with Accumulator
[0x2b3] 691     0x3a    LD A, (NN)      6a4e        ;  Load Accumulator with location 0x6a4e (20074)
[0x2b6] 694     0x5f    LD E, A                     ;  Load register E with Accumulator
[0x2b7] 695     0xfe    CP N            00          ;  Compare 0x00 (0) with Accumulator
[0x2b9] 697     0xc2    JP NZ, NN       c402        ;  Jump to 0xc402 (708) if ZERO flag is 0
[0x2bc] 700     0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x2be] 702     0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
[0x2c1] 705     0xcd    CALL NN         df02        ;  Call to 0xdf02 (735)
[0x2c4] 708     0x7b    LD A, E                     ;  Load Accumulator with register E
[0x2c5] 709     0xfe    CP N            08          ;  Compare 0x08 (8) with Accumulator
[0x2c7] 711     0xc2    JP NZ, NN       ce02        ;  Jump to 0xce02 (718) if ZERO flag is 0
[0x2ca] 714     0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2cb] 715     0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
[0x2ce] 718     0x1c    INC E                       ;  Increment register E
[0x2cf] 719     0x7b    LD A, E                     ;  Load Accumulator with register E
[0x2d0] 720     0x32    LD (NN), A      6a4e        ;  Load location 0x6a4e (20074) with the Accumulator
[0x2d3] 723     0xd6    SUB N           10          ;  Subtract 0x10 (16) from Accumulator (no carry)
[0x2d5] 725     0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x2d6] 726     0x32    LD (NN), A      6a4e        ;  Load location 0x6a4e (20074) with the Accumulator
[0x2d9] 729     0x05    DEC B                       ;  Decrement register B
[0x2da] 730     0x78    LD A, B                     ;  Load Accumulator with register B
[0x2db] 731     0x32    LD (NN), A      694e        ;  Load location 0x694e (20073) with the Accumulator
[0x2de] 734     0xc9    RET                         ;  Return


;; count_coins()
; A = $4E6B;  HL = 0x4E6C;
; $HL++;
; if ( ( A -= $HL ) != 0 )  return;
; $HL = A;
; A = $4E6D;  HL = 0x4E6E;
; A += $HL;
; DAA;  if ( carry ) {  jump_758();  }  // if coin_count <= 99;
; A = 0x99;
; $HL = A;
; HL = 0x4E9C;
; $HL |= 0x02;
[0x2df] 735     0x3a    LD A, (NN)      6b4e        ;  Load Accumulator with location 0x6b4e (20075)
[0x2e2] 738     0x21    LD HL, NN       6c4e        ;  Load register pair HL with 0x6c4e (20076)
[0x2e5] 741     0x34    INC (HL)                    ;  Increment location (HL)
[0x2e6] 742     0x96    SUB A, (HL)                 ;  Subtract location (HL) from Accumulator (no carry)
[0x2e7] 743     0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x2e8] 744     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2e9] 745     0x3a    LD A, (NN)      6d4e        ;  Load Accumulator with location 0x6d4e (20077)
[0x2ec] 748     0x21    LD HL, NN       6e4e        ;  Load register pair HL with 0x6e4e (20078)
[0x2ef] 751     0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
[0x2f0] 752     0x27    DAA                         ;  Decimal adjust Accumulator
[0x2f1] 753     0xd2    JP NC, NN       f602        ;  Jump to 0xf602 (758) if CARRY flag is 0
[0x2f4] 756     0x3e    LD A,N          99          ;  Load Accumulator with 0x99 (153)
[0x2f6] 758     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2f7] 759     0x21    LD HL, NN       9c4e        ;  Load register pair HL with 0x9c4e (20124)
[0x2fa] 762     0xcb    SET 1,(HL)                  ;  Set bit 1 of location (HL)
[0x2fc] 764     0xc9    RET                         ;  Return


; A = $4DCE++;
; if ( A & 0x0F != 0 )  return;
; A cir>>= 4;  // swap nibbles
; B = A;
; A = $4DD6;
; A ^= 0xFF;  // 1's Compliment .. is this right?
; A |= B;
; C = A;
; A = $4E6E - 1;
; if ( carry ) {  A = 0;  C = A;  }  // if ( A < 0 ) ...
;         else {  C = A;  }
; $5005 = A;
; A = C;
; $5004 = A;
; IX = 0x43D8;  IY = 0x43C5;
; if ( A = $4E00 == 3 ) {  jump_836();  }
; if ( A = $4E03 > 1 ) {  jump_836();  }
; call_873();  // draw_1up();
; call_886();  // draw_2up();
; return;
[0x2fd] 765     0x21    LD HL, NN       ce4d        ;  Load register pair HL with 0xce4d (19918)
[0x300] 768     0x34    INC (HL)                    ;  Increment location (HL)
[0x301] 769     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x302] 770     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x304] 772     0x20    JR NZ, N        1f          ;  Jump relative 0x1f (31) if ZERO flag is 0
[0x306] 774     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x307] 775     0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x308] 776     0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x309] 777     0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x30a] 778     0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x30b] 779     0x47    LD B, A                     ;  Load register B with Accumulator
[0x30c] 780     0x3a    LD A, (NN)      d64d        ;  Load Accumulator with location 0xd64d (19926)
[0x30f] 783     0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x310] 784     0xb0    OR A, B                     ;  Bitwise OR of register B to Accumulator
[0x311] 785     0x4f    LD c, A                     ;  Load register C with Accumulator
[0x312] 786     0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
[0x315] 789     0xd6    SUB N           01          ;  Subtract 0x01 (1) from Accumulator (no carry)
[0x317] 791     0x30    JR NC, N        02          ;  Jump relative 0x02 (2) if CARRY flag is 0
[0x319] 793     0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x31a] 794     0x4f    LD c, A                     ;  Load register C with Accumulator
[0x31b] 795     0x28    JR Z, N         01          ;  Jump relative 0x01 (1) if ZERO flag is 1
[0x31d] 797     0x79    LD A, C                     ;  Load Accumulator with register C
[0x31e] 798     0x32    LD (NN), A      0550        ;  Load location 0x0550 (20485) with the Accumulator
[0x321] 801     0x79    LD A, C                     ;  Load Accumulator with register C
[0x322] 802     0x32    LD (NN), A      0450        ;  Load location 0x0450 (20484) with the Accumulator
[0x325] 805     0xdd    LD IX, NN       d843        ;  Load register pair IX with 0xd843 (17368)
[0x329] 809     0xfd    LD IY, NN       c543        ;  Load register pair IY with 0xc543 (17349)
[0x32d] 813     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x330] 816     0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x332] 818     0xca    JP Z,           4403        ;  Jump to 0x4403 (836) if ZERO flag is 1
[0x335] 821     0x3a    LD A, (NN)      034e        ;  Load Accumulator with location 0x034e (19971)
[0x338] 824     0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
[0x33a] 826     0xd2    JP NC, NN       4403        ;  Jump to 0x4403 (836) if CARRY flag is 0
[0x33d] 829     0xcd    CALL NN         6903        ;  Call to 0x6903 (873)
[0x340] 832     0xcd    CALL NN         7603        ;  Call to 0x7603 (886)
[0x343] 835     0xc9    RET                         ;  Return


; A = $4DCE;
; if ( $4E09 == 0 )
; {  if ( A & 0x10 ) draw_1up();  else clear_1up();  }
; else
; {  if ( A & 0x10 ) draw_2up();  else clear_2up();  }
; if ( $4E07 == 0 )  clear_2up();  // $4E07 == Act I Scenes
; return;
[0x344] 836     0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x347] 839     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x348] 840     0x3a    LD A, (NN)      ce4d        ;  Load Accumulator with location 0xce4d (19918)
[0x34b] 843     0xc2    JP NZ, NN       5903        ;  Jump to 0x5903 (857) if ZERO flag is 0
[0x34e] 846     0xcb    BIT 4,A                     ;  Test bit 4 of Accumulator
[0x350] 848     0xcc    CALL Z,NN       6903        ;  Call to 0x6903 (873) if ZERO flag is 1
[0x353] 851     0xc4    CALL NZ,NN      8303        ;  Call to 0x8303 (899) if ZERO flag is 0
[0x356] 854     0xc3    JP NN           6103        ;  Jump to 0x6103 (865)
[0x359] 857     0xcb    BIT 4,A                     ;  Test bit 4 of Accumulator
[0x35b] 859     0xcc    CALL Z,NN       7603        ;  Call to 0x7603 (886) if ZERO flag is 1
[0x35e] 862     0xc4    CALL NZ,NN      9003        ;  Call to 0x9003 (912) if ZERO flag is 0
[0x361] 865     0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
[0x364] 868     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x365] 869     0xcc    CALL Z,NN       9003        ;  Call to 0x9003 (912) if ZERO flag is 1
[0x368] 872     0xc9    RET                         ;  Return

;; draw_1up(); // according to my written notes...
[0x369] 873     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x00 () ) with 0x50 ()
[0x36d] 877     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x01 () ) with 0x55 ()
[0x371] 881     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x31 ()
[0x375] 885     0xc9    RET                         ;  Return

;; draw_2up(); // according to my written notes...
[0x376] 886     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x50 ()
[0x37a] 890     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x55 ()
[0x37e] 894     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x02 () ) with 0x32 ()
[0x382] 898     0xc9    RET                         ;  Return

;; clear_1up(); // according to my written notes...
[0x383] 899     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x00 () ) with 0x40 ()
[0x387] 903     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x01 () ) with 0x40 ()
[0x38b] 907     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x40 ()
[0x38f] 911     0xc9    RET                         ;  Return

;; clear_2up(); // according to my written notes...
[0x390] 912     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x40 ()
[0x394] 916     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x40 ()
[0x398] 920     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x02 () ) with 0x40 ()
[0x39c] 924     0xc9    RET                         ;  Return

; if ( $4E06 < 5 ) {  return;  }  // $4E06 == Act I Scenes
; HL = $4D08;
; B = 8;  C = 16;  A = L;
; $4D06= $4DD2 = A;
; A -= C;
; $4D02 = $4D04 = A;
; A = H + B;
; $4D03 = $4D07 = A;
; A -= C;
; $4D05 = $4DD3 = A;
; return;
[0x39d] 925     0x3a    LD A, (NN)      064e        ;  Load Accumulator with location 0x064e (19974)
[0x3a0] 928     0xd6    SUB N           05          ;  Subtract 0x05 (5) from Accumulator (no carry)
[0x3a2] 930     0xd8    RET C                       ;  Return if CARRY flag is 1
[0x3a3] 931     0x2a    LD HL, (NN)     084d        ;  Load register pair HL with location 0x084d (19720)
[0x3a6] 934     0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
[0x3a8] 936     0x0e    LD  C, N        10          ;  Load register C with 0x10 (16)
[0x3aa] 938     0x7d    LD A, L                     ;  Load Accumulator with register L
[0x3ab] 939     0x32    LD (NN), A      064d        ;  Load location 0x064d (19718) with the Accumulator
[0x3ae] 942     0x32    LD (NN), A      d24d        ;  Load location 0xd24d (19922) with the Accumulator
[0x3b1] 945     0x91    SUB A, C                    ;  Subtract register C from Accumulator (no carry)
[0x3b2] 946     0x32    LD (NN), A      024d        ;  Load location 0x024d (19714) with the Accumulator
[0x3b5] 949     0x32    LD (NN), A      044d        ;  Load location 0x044d (19716) with the Accumulator
[0x3b8] 952     0x7c    LD A, H                     ;  Load Accumulator with register H
[0x3b9] 953     0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
[0x3ba] 954     0x32    LD (NN), A      034d        ;  Load location 0x034d (19715) with the Accumulator
[0x3bd] 957     0x32    LD (NN), A      074d        ;  Load location 0x074d (19719) with the Accumulator
[0x3c0] 960     0x91    SUB A, C                    ;  Subtract register C from Accumulator (no carry)
[0x3c1] 961     0x32    LD (NN), A      054d        ;  Load location 0x054d (19717) with the Accumulator
[0x3c4] 964     0x32    LD (NN), A      d34d        ;  Load location 0xd34d (19923) with the Accumulator
[0x3c7] 967     0xc9    RET                         ;  Return

; A = $4E00;  jump_table();
[0x3c8] 968     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x3cb] 971     0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $03D4 : 980
; 1 : $03FE : 1022
; 2 : $05E5 : 1509
; 3 : $06BE : 1726

; A = $4E01;  jump_table();
[0x3d4] 980     0x3a    LD A, (NN)      014e        ;  Load Accumulator with location 0x014e (19969)
[0x3d7] 983     0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $03DC : 988
; 1 : $000C : return;

[0x3dc] 988     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x00
[0x3df] 991     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x06, 0x00
[0x3e2] 994     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x00
[0x3e5] 997     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x14, 0x00
[0x3e8] 1000    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x18, 0x00
[0x3eb] 1003    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x00
[0x3ee] 1006    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1E, 0x00
[0x3f1] 1009    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x07, 0x00

; $4E01++;  $5001 = 1;
[0x3f4] 1012    0x21    LD HL, NN       014e        ;  Load register pair HL with 0x014e (19969)
[0x3f7] 1015    0x34    INC (HL)                    ;  Increment location (HL)
[0x3f8] 1016    0x21    LD HL, NN       0150        ;  Load register pair HL with 0x0150 (20481)
[0x3fb] 1019    0x36    LD (HL), N      01          ;  Load register pair HL with 0x01 (1)
[0x3fd] 1021    0xc9    RET                         ;  Return


; display_credits_info();  // via call_11169();
[0x3fe] 1022    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
[0x401] 1025    0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
[0x404] 1028    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x405] 1029    0x28    JR Z, N         0c          ;  Jump relative 0x0c (12) if ZERO flag is 1
[0x407] 1031    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x408] 1032    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
[0x40b] 1035    0x32    LD (NN), A      024e        ;  Load location 0x024e (19970) with the Accumulator
[0x40e] 1038    0x21    LD HL, NN       004e        ;  Load register pair HL with 0x004e (19968)
;; 1040-1047 : On Ms. Pac-Man patched in from $8008-$800F
[0x411] 1041    0x34    INC (HL)                    ;  Increment location (HL)
[0x412] 1042    0xc9    RET                         ;  Return
[0x413] 1043    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
;; On Ms. Pac-Man:
;; 1043  $0413   0xc3    JP nn           5c3e        ;  Jump to $nn
[0x416] 1046    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $045F : RST 0x28 - 0x00, 0x01  // clear(0x01);  // clear playfield
; 1 : $000C : return;
; 2 : $0471 : draw red ghost
; 3 : $000C : return;
; 4 : $047F : draw -SHADOW
; 5 : $000C : return;
; 6 : $0485 : draw "BLINKY"
; 7 : $000C : return;
; 8 : $048B : draw pink ghost
; 9 : $000C : return;
; 10 : $0499 : draw -SPEEDY
; 11 : $000C : return;
; 12 : $049F : draw "PINKY"
; 13 : $000C : return;
; 14 : $04A5 : draw blue ghost
; 15 : $000C : return;
; 16 : $04B3 : draw -BASHFUL
; 17 : $000C : return;
; 18 : $04B9 : draw "INKY"
; 19 : $000C : return;
; 20 : $04BF : draw orange ghost
; 21 : $000C : return;
; 22 : $04CD : draw -POKEY
; 23 : $000C : return;
; 24 : $04D3 : draw "CLYDE"
; 25 : $000C : return;
; 26 : $04D8 : draw &littledot; 10 pts
; 27 : $000C : return;
; 28 : $04E0 : draw &copy; 1980 MIDWAY MFG CO
; 29 : $000C : return;
; 30 : $051C : 
; 31 : $054B :
; 32 : $0556 :
; 33 : $0561 :
; 34 : $056C :
; 35 : $057C :

[0x45f] 1119    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01  // clear(0x01);  // clear playfield
[0x462] 1122    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x00
[0x465] 1125    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x00
[0x468] 1128    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1E, 0x00
[0x46b] 1131    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
[0x46d] 1133    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
[0x470] 1136    0xc9    RET                         ;  Return


; draw_ghost($4304, 1); // draw red ghost at 5, 4 on playfield
[0x471] 1137    0x21    LD HL, NN       0443        ;  Load register pair HL with 0x0443 (17156)
[0x474] 1140    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x476] 1142    0xcd    CALL NN         bf05        ;  Call to 0xbf05 (1471)
; write_string("CHARACTER : NICKNAME"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
[0x479] 1145    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
[0x47b] 1147    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
[0x47e] 1150    0xc9    RET                         ;  Return

; write_string("-SHADOW    "); via 1427 -> Call to 0x4200 (66) -> RST 0x30
[0x47f] 1151    0x0e    LD  C, N        14          ;  Load register C with 0x14 (20)
[0x481] 1153    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
[0x484] 1156    0xc9    RET                         ;  Return

; write_string(""BLINKY""); via 1427 -> Call to 0x4200 (66) -> RST 0x30
[0x485] 1157    0x0e    LD  C, N        0d          ;  Load register C with 0x0d (13)
[0x487] 1159    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
[0x48a] 1162    0xc9    RET                         ;  Return

; draw_ghost($4307, 3); // draw pink ghost at 5, 7 on playfield 
[0x48b] 1163    0x21    LD HL, NN       0743        ;  Load register pair HL with 0x0743 (17159)
[0x48e] 1166    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0x490] 1168    0xcd    CALL NN         bf05        ;  Call to 0xbf05 (1471)
; write_string("CHARACTER : NICKNAME"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
[0x493] 1171    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
[0x495] 1173    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
[0x498] 1176    0xc9    RET                         ;  Return

; write_string("-SPEEDY   "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
[0x499] 1177    0x0e    LD  C, N        16          ;  Load register C with 0x16 (22)
[0x49b] 1179    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
[0x49e] 1182    0xc9    RET                         ;  Return

; write_string(""PINKY"  "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
[0x49f] 1183    0x0e    LD  C, N        0f          ;  Load register C with 0x0f (15)
[0x4a1] 1185    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
[0x4a4] 1188    0xc9    RET                         ;  Return

; draw_ghost($430A, 5); // draw blue ghost at 5, 10 on playfield
[0x4a5] 1189    0x21    LD HL, NN       0a43        ;  Load register pair HL with 0x0a43 (17162)
[0x4a8] 1192    0x3e    LD A,N          05          ;  Load Accumulator with 0x05 (5)
[0x4aa] 1194    0xcd    CALL NN         bf05        ;  Call to 0xbf05 (1471)
; write_string("CHARACTER : NICKNAME"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
[0x4ad] 1197    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
[0x4af] 1199    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
[0x4b2] 1202    0xc9    RET                         ;  Return

; write_string("-BASHFUL  "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
[0x4b3] 1203    0x0e    LD  C, N        33          ;  Load register C with 0x33 (51)
[0x4b5] 1205    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
[0x4b8] 1208    0xc9    RET                         ;  Return

; write_string(""INKY"   "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
[0x4b9] 1209    0x0e    LD  C, N        2f          ;  Load register C with 0x2f (47)
[0x4bb] 1211    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
[0x4be] 1214    0xc9    RET                         ;  Return

; draw_ghost($430D, 7); // draw orange ghost at 5, 13 on playfield
[0x4bf] 1215    0x21    LD HL, NN       0d43        ;  Load register pair HL with 0x0d43 (17165)
[0x4c2] 1218    0x3e    LD A,N          07          ;  Load Accumulator with 0x07 (7)
[0x4c4] 1220    0xcd    CALL NN         bf05        ;  Call to 0xbf05 (1471)
; write_string("CHARACTER : NICKNAME"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
[0x4c7] 1223    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
[0x4c9] 1225    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
[0x4cc] 1228    0xc9    RET                         ;  Return

; write_string("-POKEY    "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
[0x4cd] 1229    0x0e    LD  C, N        35          ;  Load register C with 0x35 (53)
[0x4cf] 1231    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
[0x4d2] 1234    0xc9    RET                         ;  Return

; write_string(""CLYDE"  "); via 1408  -> Call to 0x4200 (66) -> RST 0x30
[0x4d3] 1235    0x0e    LD  C, N        31          ;  Load register C with 0x31 (49)
[0x4d5] 1237    0xc3    JP NN           8005        ;  Jump to 0x8005 (1408)

; display("&littledot; 10 pts") by way of write_msg();
[0x4d8] 1240    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x11
; write_string("&bigdot; 50 pts"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
[0x4db] 1243    0x0e    LD  C, N        12          ;  Load register C with 0x12 (18)
[0x4dd] 1245    0xc3    JP NN           8505        ;  Jump to 0x8505 (1413)

; write_string("&copy; 1980 MIDWAY MFG CO"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
[0x4e0] 1248    0x0e    LD  C, N        13          ;  Load register C with 0x13 (19)
[0x4e2] 1250    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
;
[0x4e5] 1253    0xcd    CALL NN         7908        ;  Call to 0x7908 (2169)
[0x4e8] 1256    0x35    DEC (HL)                    ;  Decrement location (HL)
[0x4e9] 1257    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x11, 0x00
[0x4ec] 1260    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x05, 0x01
[0x4ef] 1263    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x10, 0x14
[0x4f2] 1266    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x01
[0x4f5] 1269    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x4f7] 1271    0x32    LD (NN), A      144e        ;  Load location 0x144e (19988) with the Accumulator
[0x4fa] 1274    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x4fb] 1275    0x32    LD (NN), A      704e        ;  Load location 0x704e (20080) with the Accumulator
[0x4fe] 1278    0x32    LD (NN), A      154e        ;  Load location 0x154e (19989) with the Accumulator
[0x501] 1281    0x21    LD HL, NN       3243        ;  Load register pair HL with 0x3243 (17202)
[0x504] 1284    0x36    LD (HL), N      14          ;  Load register pair HL with 0x14 (20)

;;;; fill_playfield_rows_11_13_with_FC();
;; B = 28;
;; IX = 0x4040
;; while ( B-- )
;; {
;;    $(IX+11) = 0xFC;
;;    $(IX+13) = 0xFC;
;;    IX += 0x0020;
;; }
;; return;
[0x506] 1286    0x3e    LD A,N          fc          ;  Load Accumulator with 0xfc (252)
[0x508] 1288    0x11    LD  DE, NN      2000        ;  Load register pair DE with 0x2000 (32)
[0x50b] 1291    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
[0x50d] 1293    0xdd    LD IX, NN       4040        ;  Load register pair IX with 0x4040 (16448)
[0x511] 1297    0xdd    LD (IX+d), A    11          ;  Load location ( IX + 0x11 () ) with Accumulator
[0x514] 1300    0xdd    LD (IX+d), A    13          ;  Load location ( IX + 0x13 () ) with Accumulator
[0x517] 1303    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x519] 1305    0x10    DJNZ N          f6          ;  Decrement B and jump relative 0xf6 (-10) if B!=0
[0x51b] 1307    0xc9    RET                         ;  Return


;; HL = 0x4DA0;
;; B = 0x21;
;; A = $4D3A;  // Pacman.X (21-3A)
[0x51c] 1308    0x21    LD HL, NN       a04d        ;  Load register pair HL with 0xa04d (19872)
[0x51f] 1311    0x06    LD  B, N        21          ;  Load register B with 0x21 (33)
[0x521] 1313    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
;; if ( A == B )
;; {
;;     $HL = 0x01;
;;     $4E02++;  return;  // via advance_attract_screen(); 
;; }
[0x524] 1316    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x525] 1317    0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
[0x527] 1319    0x36    LD (HL), N      01          ;  Load register pair HL with 0x01 (1)
[0x529] 1321    0xc3    JP NN           8e05        ;  Jump to 0x8e05 (1422)
;; else, all these calls...
[0x52c] 1324    0xcd    CALL NN         1710        ;  Call to 0x1710 (4119)
[0x52f] 1327    0xcd    CALL NN         1710        ;  Call to 0x1710 (4119)
[0x532] 1330    0xcd    CALL NN         230e        ;  Call to 0x230e (3619)
[0x535] 1333    0xcd    CALL NN         0d0c        ;  Call to 0x0d0c (3085)
[0x538] 1336    0xcd    CALL NN         d60b        ;  Call to 0xd60b (3030)
[0x53b] 1339    0xcd    CALL NN         a505        ;  Call to 0xa505 (1445)
[0x53e] 1342    0xcd    CALL NN         fe1e        ;  Call to 0xfe1e (7934)
[0x541] 1345    0xcd    CALL NN         251f        ;  Call to 0x251f (7973)
[0x544] 1348    0xcd    CALL NN         4c1f        ;  Call to 0x4c1f (8012)
[0x547] 1351    0xcd    CALL NN         731f        ;  Call to 0x731f (8051)
[0x54a] 1354    0xc9    RET                         ;  Return


;; HL = 0x4DA1;
;; B = 0x20;
;; A = $4D32;
;; jump(1316);
[0x54b] 1355    0x21    LD HL, NN       a14d        ;  Load register pair HL with 0xa14d (19873)
[0x54e] 1358    0x06    LD  B, N        20          ;  Load register B with 0x20 (32)
[0x550] 1360    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
[0x553] 1363    0xc3    JP NN           2405        ;  Jump to 0x2405 (1316)


;; HL = 0x4DA2;
;; B = 0x22;
;; A = $4D32;
;; jump(1316);
[0x556] 1366    0x21    LD HL, NN       a24d        ;  Load register pair HL with 0xa24d (19874)
[0x559] 1369    0x06    LD  B, N        22          ;  Load register B with 0x22 (34)
[0x55b] 1371    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
[0x55e] 1374    0xc3    JP NN           2405        ;  Jump to 0x2405 (1316)


;; HL = 0x4DA3;
;; B = 0x24;
;; A = $4D32;
;; jump(1316);
[0x561] 1377    0x21    LD HL, NN       a34d        ;  Load register pair HL with 0xa34d (19875)
[0x564] 1380    0x06    LD  B, N        24          ;  Load register B with 0x24 (36)
[0x566] 1382    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
[0x569] 1385    0xc3    JP NN           2405        ;  Jump to 0x2405 (1316)


;; if ( $4DD0 + $4DD1 == 6 ) {  jump(1422);  } else {  jump(1324);  }
[0x56c] 1388    0x3a    LD A, (NN)      d04d        ;  Load Accumulator with location 0xd04d (19920)
[0x56f] 1391    0x47    LD B, A                     ;  Load register B with Accumulator
[0x570] 1392    0x3a    LD A, (NN)      d14d        ;  Load Accumulator with location 0xd14d (19921)
[0x573] 1395    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
[0x574] 1396    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
[0x576] 1398    0xca    JP Z,           8e05        ;  Jump to 0x8e05 (1422) if ZERO flag is 1
[0x579] 1401    0xc3    JP NN           2c05        ;  Jump to 0x2c05 (1324)


; call(1726);
[0x57c] 1404    0xcd    CALL NN         be06        ;  Call to 0xbe06 (1726)
[0x57f] 1407    0xc9    RET                         ;  Return


; display($4E75+C) by way of insert_msg(0x1c, A);
[0x580] 1408    0x3a    LD A, (NN)      754e        ;  Load Accumulator with location 0x754e (20085)
[0x583] 1411    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x584] 1412    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x585] 1413    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
[0x587] 1415    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
[0x58a] 1418    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4A, 0x02, 0x00


; advance_attract_screen();
;; $4E02++;  // attract screen frame
[0x58e] 1422    0x21    LD HL, NN       024e        ;  Load register pair HL with 0x024e (19970)
[0x591] 1425    0x34    INC (HL)                    ;  Increment location (HL)
[0x592] 1426    0xc9    RET                         ;  Return


; display($4E75+C) by way of insert_msg(0x1c, A);
[0x593] 1427    0x3a    LD A, (NN)      754e        ;  Load Accumulator with location 0x754e (20085)
[0x596] 1430    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x597] 1431    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x598] 1432    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
[0x59a] 1434    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
[0x59d] 1437    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x45, 0x02, 0x00
[0x5a1] 1441    0xcd    CALL NN         8e05        ;  Call to 0x8e05 (1422)
[0x5a4] 1444    0xc9    RET                         ;  Return


;; if ( $4DB5 == 0 ) {  return;  }
;; $4DB5 = 0;
;;;;  The XOR indexing into the dir table is a 180 degree turn
;; $4D3C = B = $4D30 ^ 0x02;
;; $4D26/7 = table_and_index_to_address($GHOST_DIR_TABLE, B);  // rst_18;
[0x5a5] 1445    0x3a    LD A, (NN)      b54d        ;  Load Accumulator with location 0xb54d (19893)
[0x5a8] 1448    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x5a9] 1449    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x5aa] 1450    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x5ab] 1451    0x32    LD (NN), A      b54d        ;  Load location 0xb54d (19893) with the Accumulator
[0x5ae] 1454    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
[0x5b1] 1457    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
[0x5b3] 1459    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
[0x5b6] 1462    0x47    LD B, A                     ;  Load register B with Accumulator
[0x5b7] 1463    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
[0x5ba] 1466    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
[0x5bb] 1467    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
[0x5be] 1470    0xc9    RET                         ;  Return


; draw_ghost(HL=mem_loc to draw ghost, A=color palette)
; {
;     $HL = [ 0xB1, 0xB3, 0xB5 ];
;     $HL += 0x1E; // after the two increments, jumps to next column to the left on display
;     $HL = [ 0xB0, 0xB2, 0xB4 ];
;     $HL += 0x0400;
;     // it does the following counting by backwards
;     $HL = [ A, A, A ];
;     $HL -= 0x1E; // after the two decrements, jumps to the next columm to the right on display
;     $HL = [ A, A, A ];
;     return;
; }
[0x5bf] 1471    0x36    LD (HL), N      b1          ;  Load location (HL) with 0xb1 (177)
[0x5c1] 1473    0x2c    INC L                       ;  Increment register L
[0x5c2] 1474    0x36    LD (HL), N      b3          ;  Load location (HL) with 0xb3 (179)
[0x5c4] 1476    0x2c    INC L                       ;  Increment register L
[0x5c5] 1477    0x36    LD (HL), N      b5          ;  Load location (HL) with 0xb5 (181)
[0x5c7] 1479    0x01    LD  BC, NN      1e00        ;  Load register pair BC with 0x1e00 (30)
[0x5ca] 1482    0x09    ADD HL, BC                  ;  Add register pair BC to HL
[0x5cb] 1483    0x36    LD (HL), N      b0          ;  Load location (HL) with 0xb0 (176)
[0x5cd] 1485    0x2c    INC L                       ;  Increment register L
[0x5ce] 1486    0x36    LD (HL), N      b2          ;  Load register pair HL with 0xb2 (178)
[0x5d0] 1488    0x2c    INC L                       ;  Increment register L
[0x5d1] 1489    0x36    LD (HL), N      b4          ;  Load location (HL) with 0xb4 (180)
[0x5d3] 1491    0x11    LD  DE, NN      0004        ;  Load register pair DE with 0x0004 (0)
[0x5d6] 1494    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x5d7] 1495    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x5d8] 1496    0x2d    DEC L                       ;  Decrement register L
[0x5d9] 1497    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x5da] 1498    0x2d    DEC L                       ;  Decrement register L
[0x5db] 1499    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x5dc] 1500    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
[0x5dd] 1501    0xed    SBC HL, BC                  ;  Subtract with carry register pair BC from HL
[0x5df] 1503    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x5e0] 1504    0x2d    DEC L                       ;  Decrement register L
[0x5e1] 1505    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x5e2] 1506    0x2d    DEC L                       ;  Decrement register L
[0x5e3] 1507    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x5e4] 1508    0xc9    RET                         ;  Return


; A = $4E03;  // $4E03 = Mode [00 - Attract Screen + Gameplay, 01 - Push Start Button, 03 - Game Start ("Ready!")]
[0x5e5] 1509    0x3a    LD A, (NN)      034e        ;  Load Accumulator with location 0x034e (19971)
[0x5e8] 1512    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $05F3 - 
; 1 : $061B -
; 2 : $0674 -
; 3 : $000C - return;
; 4 : $06A8 -

; display_credits_info();  // via call_11169();
[0x5f3] 1523    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
[0x5f6] 1526    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01  // clear(0x01);  // clear playfield
[0x5f9] 1529    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x00
; display("PUSH START BUTTON") by way of write_msg();
[0x5fc] 1532    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x07
; display("&copy; MIDWAY MFG.CO.") by way of write_msg();
[0x5ff] 1535    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x0B
[0x602] 1538    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1E, 0x00
; $4E03++;  // $4E03 = Mode [00 - Attract Screen + Gameplay, 01 - Push Start Button, 03 - Game Start ("Ready!")]
; $4DD6 = 0x01;
[0x605] 1541    0x21    LD HL, NN       034e        ;  Load register pair HL with 0x034e (19971)
[0x608] 1544    0x34    INC (HL)                    ;  Increment location (HL)
[0x609] 1545    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x60b] 1547    0x32    LD (NN), A      d64d        ;  Load location 0xd64d (19926) with the Accumulator
; if ( $4E71 == 0xFF ) {  return;  }
[0x60e] 1550    0x3a    LD A, (NN)      714e        ;  Load Accumulator with location 0x714e (20081)
[0x611] 1553    0xfe    CP N            ff          ;  Compare 0xff (255) with Accumulator
[0x613] 1555    0xc8    RET Z                       ;  Return if ZERO flag is 1
; display("BONUS PAC-MAN FOR   00pts") by way of write_msg();
[0x614] 1556    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x0A
[0x617] 1559    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1F, 0x00
[0x61a] 1562    0xc9    RET                         ;  Return


; display_credits();  // via call_11169();
[0x61b] 1563    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
; if ( $4E6E == 0x01 ) {  write_string(8);  }  // "1 PLAYER ONLY "
;                 else {  write_string(9);  }  // "1 OR 2 PLAYERS"
[0x61e] 1566    0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
[0x621] 1569    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x623] 1571    0x06    LD  B, N        09          ;  Load register B with 0x09 (9)
[0x625] 1573    0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
[0x627] 1575    0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
[0x629] 1577    0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

;;; this seems like a very convoluted way of testing for start button presses,
;;; filtering Start 2 if the number of credits is > 1
; A = $5040; // $5040 - IN1 - cocktail/upright, Start 2, Start 1, service mode, 2 down, 2 right, 2 left, 2 up
; if ( $4E6E =! 0x01 && IN1.Start2 == 1 ) {  $4E70 = 0x01;  }
; elsif ( IN1.Start1 != 1 ) {  return;  }
[0x62c] 1580    0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
[0x62f] 1583    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x631] 1585    0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x634] 1588    0x28    JR Z, N         0c          ;  Jump relative 0x0c (12) if ZERO flag is 1
[0x636] 1590    0xcb    BIT 6,A                     ;  Test bit 6 of Accumulator
[0x638] 1592    0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
[0x63a] 1594    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x63c] 1596    0x32    LD (NN), A      704e        ;  Load location 0x704e (20080) with the Accumulator
[0x63f] 1599    0xc3    JP NN           4906        ;  Jump to 0x4906 (1609)
[0x642] 1602    0xcb    BIT 5,A                     ;  Test bit 5 of Accumulator
[0x644] 1604    0xc0    RET NZ                      ;  Return if ZERO flag is 0
; $4E70 = 0x00;
[0x645] 1605    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x646] 1606    0x32    LD (NN), A      704e        ;  Load location 0x704e (20080) with the Accumulator

;; if ( Coins_Per_Credit != 1 )
;; {
;;     if ( $4E70 == 0x00 ) {  Credits -= 2;  }  // BCD, not actual arithmetic
;;                     else {  Credits -= 1;  }  // BCD, not actual arithmetic
;; }
; if ( $4E6B != 0x01 )
; {
;     if ( $4E70 == 0x00 )
;     {  decimal_add_A(0x99);  }  // effectively subtract -1
;     decimal_add_A(0x99);        // effectively subtract -1
;     $4E6E = A;  // Credits
; }
[0x649] 1609    0x3a    LD A, (NN)      6b4e        ;  Load Accumulator with location 0x6b4e (20075)
[0x64c] 1612    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x64d] 1613    0x28    JR Z, N         15          ;  Jump relative 0x15 (21) if ZERO flag is 1
[0x64f] 1615    0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
[0x652] 1618    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x653] 1619    0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
[0x656] 1622    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
[0x658] 1624    0xc6    ADD A, N        99          ;  Add 0x99 (153) to Accumulator (no carry)
[0x65a] 1626    0x27    DAA                         ;  Decimal adjust Accumulator
[0x65b] 1627    0xc6    ADD A, N        99          ;  Add 0x99 (153) to Accumulator (no carry)
[0x65d] 1629    0x27    DAA                         ;  Decimal adjust Accumulator
[0x65e] 1630    0x32    LD (NN), A      6e4e        ;  Load location 0x6e4e (20078) with the Accumulator

;; display_credits_info();
;; Mode++;
;; $4DD6 = 0;
;; Sound1.Waveform = 1;  // Intro Music
;; Sound2.Waveform = 1;  // Intro Music
; display_credits_info();  // via call_11169();
; $4E03++;
; $4DD6 = 0;
; $4ECC = 1;
; $4EDC = 1;
; return;
[0x661] 1633    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
[0x664] 1636    0x21    LD HL, NN       034e        ;  Load register pair HL with 0x034e (19971)
[0x667] 1639    0x34    INC (HL)                    ;  Increment location (HL)
[0x668] 1640    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x669] 1641    0x32    LD (NN), A      d64d        ;  Load location 0xd64d (19926) with the Accumulator
[0x66c] 1644    0x3c    INC A                       ;  Increment Accumulator
[0x66d] 1645    0x32    LD (NN), A      cc4e        ;  Load location 0xcc4e (20172) with the Accumulator
[0x670] 1648    0x32    LD (NN), A      dc4e        ;  Load location 0xdc4e (20188) with the Accumulator
[0x673] 1651    0xc9    RET                         ;  Return


[0x674] 1652    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01  // clear(0x01);  // clear playfield
[0x677] 1655    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x01
[0x67a] 1658    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x02, 0x00
[0x67d] 1661    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x12, 0x00
[0x680] 1664    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x03, 0x00
; display("PLAYER ONE") by way of write_msg();
[0x683] 1667    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x03
; display("READY!") by way of write_msg();
[0x686] 1670    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x06
[0x689] 1673    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x18, 0x00
[0x68c] 1676    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1B, 0x00
; $4E13 = 0;  // Current board?
; $4E14 = $4E15 = $4E6F;  // remaining_lives = ??? = lives_per_game;
[0x68f] 1679    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x690] 1680    0x32    LD (NN), A      134e        ;  Load location 0x134e (19987) with the Accumulator
[0x693] 1683    0x3a    LD A, (NN)      6f4e        ;  Load Accumulator with location 0x6f4e (20079)
[0x696] 1686    0x32    LD (NN), A      144e        ;  Load location 0x144e (19988) with the Accumulator
[0x699] 1689    0x32    LD (NN), A      154e        ;  Load location 0x154e (19989) with the Accumulator
[0x69c] 1692    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1A, 0x00
[0x69f] 1695    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x57, 0x01, 0x03
; Mode++;
[0x6a3] 1699    0x21    LD HL, NN       034e        ;  Load register pair HL with 0x034e (19971)
[0x6a6] 1702    0x34    INC (HL)                    ;  Increment location (HL)
[0x6a7] 1703    0xc9    RET                         ;  Return


; remaining_lives--;
; call(11114);
; $4E02 = $4E03 = $4E04 = 0;  // Attract_frame = Mode = Game_frame = 0;
; $4E00++;  // Soundbank++;
; return;
[0x6a8] 1704    0x21    LD HL, NN       154e        ;  Load register pair HL with 0x154e (19989)
[0x6ab] 1707    0x35    DEC (HL)                    ;  Decrement location (HL)
[0x6ac] 1708    0xcd    CALL NN         6a2b        ;  Call to 0x6a2b (11114)
[0x6af] 1711    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x6b0] 1712    0x32    LD (NN), A      034e        ;  Load location 0x034e (19971) with the Accumulator
[0x6b3] 1715    0x32    LD (NN), A      024e        ;  Load location 0x024e (19970) with the Accumulator
[0x6b6] 1718    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
[0x6b9] 1721    0x21    LD HL, NN       004e        ;  Load register pair HL with 0x004e (19968)
[0x6bc] 1724    0x34    INC (HL)                    ;  Increment location (HL)
[0x6bd] 1725    0xc9    RET                         ;  Return


; rst_20(Game_frame);
[0x6be] 1726    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
[0x6c1] 1729    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 [?]                            : $0879 - 
; 1 [?]                            : $0899 - 
; 2 [Maze, Ghosts, Pacman, Ready!] : $000C - return;
; 3 [Running game]                 : $08CD - 
; 4 [?]                            : $090D - 
; 5 [?]                            : $000C - return;
; 6 [?]                            : $0940 - 
; 7 [Game Over]                    : $000C - return;
; 8 [player change?]               : $0972 - 
; 9 [?]                            : $0988 - 
; 10 [?]                           : $000C - return;
; 11 [?]                           : $09D2 - 
; 12 [?]                           : $09D8 - 
; 13 [Level Clear Maze Flash]      : $000C - return;
; 14 [Level Clear Maze Flash]      : $09E8 - 
; 15 [Level Clear Maze Flash]      : $000C - return;
; 16 [Level Clear Maze Flash]      : $09FE - 
; 17 [Level Clear Maze Flash]      : $000C - return;
; 18 [Level Clear Maze Flash]      : $0A02 - 
; 19 [Level Clear Maze Flash]      : $000C - return;
; 20 [Level Clear Maze Flash]      : $0A04 - 
; 21 [Level Clear Maze Flash]      : $000C - return;
; 22 [Level Clear Maze Flash]      : $0A06 - 
; 23 [Level Clear Maze Flash]      : $000C - return;
; 24 [Level Clear Maze Flash]      : $0A08 - 
; 25 [Level Clear Maze Flash]      : $000C - return;
; 26 [Level Clear Maze Flash]      : $0A0A - 
; 27 [Level Clear Maze Flash]      : $000C - return;
; 28 [Level Clear Maze Flash]      : $0A0C - 
; 29 [Level Clear Maze Flash]      : $000C - return;
; 30 [Level Clear Maze Flash]      : $0A0E - 
; 31 [Level Clear Maze Flash]      : $000C - return;
; 32 [Act 1/2/3]                   : $0A2C - 
; 33 [Clear Level]                 : $000C - 
; 34 [Clear Level]                 : $0A7C - 
; 35 [Clear Level]                 : $0AA0 - 
; 36 [Clear Level]                 : $000C -
; 37 [?]                           : $0AA3 - 


; A = B;
; if ( A == 0 ) {  A = $4E0A;  }
; IX = $0796;  // table for game mechanics?
; A *= 6;
; IX += A;
; A = $IX;
; B = A*2;
; C = A*8;
; A = A*32 + C + B;  // A *= 42;
; HL = 0x330F + A;
; call_2068();
[0x70e] 1806    0x78    LD A, B                     ;  Load Accumulator with register B
[0x70f] 1807    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x710] 1808    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
[0x712] 1810    0x2a    LD HL, (NN)     0a4e        ;  Load register pair HL with location 0x0a4e (19978)
[0x715] 1813    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x716] 1814    0xdd    LD IX, NN       9607        ;  Load register pair IX with 0x9607 (1942)
[0x71a] 1818    0x47    LD B, A                     ;  Load register B with Accumulator
[0x71b] 1819    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x71c] 1820    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x71d] 1821    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
[0x71e] 1822    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
[0x71f] 1823    0x5f    LD E, A                     ;  Load register E with Accumulator
[0x720] 1824    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x722] 1826    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x724] 1828    0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
[0x727] 1831    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x728] 1832    0x47    LD B, A                     ;  Load register B with Accumulator
[0x729] 1833    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x72a] 1834    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x72b] 1835    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x72c] 1836    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x72d] 1837    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x72e] 1838    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x72f] 1839    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
[0x730] 1840    0x5f    LD E, A                     ;  Load register E with Accumulator
[0x731] 1841    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x733] 1843    0x21    LD HL, NN       0f33        ;  Load register pair HL with 0x0f33 (13071)
[0x736] 1846    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x737] 1847    0xcd    CALL NN         1408        ;  Call to 0x1408 (2068)

;; $4DB0 = $(IX+1);
;; HL = $0843 + ( $(IX+2) * 3 );  // double-byte operations
;; call_2106();  // triple_byte_copy_4DB8(HL);
[0x73a] 1850    0xdd    LD A, (IX+d)    01          ;  Load Accumulator with location ( IX + 0x01 () )
[0x73d] 1853    0x32    LD (NN), A      b04d        ;  Load location 0xb04d (19888) with the Accumulator
[0x740] 1856    0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
[0x743] 1859    0x47    LD B, A                     ;  Load register B with Accumulator
[0x744] 1860    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x745] 1861    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
[0x746] 1862    0x5f    LD E, A                     ;  Load register E with Accumulator
[0x747] 1863    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x749] 1865    0x21    LD HL, NN       4308        ;  Load register pair HL with 0x4308 (2115)
[0x74c] 1868    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x74d] 1869    0xcd    CALL NN         3a08        ;  Call to 0x3a08 (2106)

;; $4DBB = $084F + ( $(IX+3) * 2 );  // double-byte operations
[0x750] 1872    0xdd    LD A, (IX+d)    03          ;  Load Accumulator with location ( IX + 0x03 () )
[0x753] 1875    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x754] 1876    0x5f    LD E, A                     ;  Load register E with Accumulator
[0x755] 1877    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x757] 1879    0xfd    LD IY, NN       4f08        ;  Load register pair IY with 0x4f08 (2127)
[0x75b] 1883    0xfd    ADD IY, DE                  ;  Add register pair DE to IY
[0x75d] 1885    0xfd    LD L, (IY + N)  00          ;  Load register L with location ( IY + 0x00 () )
[0x760] 1888    0xfd    LD H, (IY + N)  01          ;  Load register H with location ( IY + 0x01 () )
[0x763] 1891    0x22    LD (NN), HL     bb4d        ;  Load location 0xbb4d (19899) with the register pair HL

;; $4DBD = $0861 + ( $(IX+4) * 2 );  // double-byte operations
[0x766] 1894    0xdd    LD A, (IX+d)    04          ;  Load Accumulator with location ( IX + 0x04 () )
[0x769] 1897    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x76a] 1898    0x5f    LD E, A                     ;  Load register E with Accumulator
[0x76b] 1899    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x76d] 1901    0xfd    LD IY, NN       6108        ;  Load register pair IY with 0x6108 (2145)
[0x771] 1905    0xfd    ADD IY, DE                  ;  Add register pair DE to IY
[0x773] 1907    0xfd    LD L, (IY + N)  00          ;  Load register L with location ( IY + 0x00 () )
[0x776] 1910    0xfd    LD H, (IY + N)  01          ;  Load register H with location ( IY + 0x01 () )
[0x779] 1913    0x22    LD (NN), HL     bd4d        ;  Load location 0xbd4d (19901) with the register pair HL

;; $4D95 = $0873 + ( $(IX+5) * 2 );  // double-byte operations
[0x77c] 1916    0xdd    LD A, (IX+d)    05          ;  Load Accumulator with location ( IX + 0x05 () )
[0x77f] 1919    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x780] 1920    0x5f    LD E, A                     ;  Load register E with Accumulator
[0x781] 1921    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x783] 1923    0xfd    LD IY, NN       7308        ;  Load register pair IY with 0x7308 (2163)
[0x787] 1927    0xfd    ADD IY, DE                  ;  Add register pair DE to IY
[0x789] 1929    0xfd    LD L, (IY + N)  00          ;  Load register L with location ( IY + 0x00 () )
[0x78c] 1932    0xfd    LD H, (IY + N)  01          ;  Load register H with location ( IY + 0x01 () )
[0x78f] 1935    0x22    LD (NN), HL     954d        ;  Load location 0x954d (19861) with the register pair HL

;; call_11242();
[0x792] 1938    0xcd    CALL NN         ea2b        ;  Call to 0xea2b (11242)
[0x795] 1941    0xc9    RET                         ;  Return


;; 1942 : ghost behavior modifier table? (used by 1806)
;; fields: ??, ??, ??, red_aggression_dot_threshold_idx, ??, ??
; 0 : 03 01 01 00 02 00
; 1 : 04 01 02 01 03 00
; 2 : 04 01 03 02 04 01
; 3 : 04 02 03 02 05 01
; 4 : 05 00 03 02 06 02
; 5 : 05 01 03 03 03 02
; 6 : 05 02 03 03 06 02
; 7 : 05 02 03 03 06 02
; 8 : 05 00 03 04 07 02
; 9 : 05 01 03 04 03 02
; 10 : 05 02 03 04 06 02
; 11 : 05 02 03 05 07 02
; 12 : 05 00 03 05 07 02
; 13 : 05 02 03 05 05 02
; 14 : 05 01 03 06 07 02
; 15 : 05 02 03 06 07 02
; 16 : 05 02 03 06 08 02
; 17 : 05 02 03 06 07 02
; 18 : 05 02 03 07 08 02
; 19 : 05 02 03 07 08 02
; 20 : 06 02 03 07 08 02


;;; blockcopy_4D46(HL);
;;; Copies the block pointed to by HL into $4D46-$4D93, in a strange/interesting pattern.  Visually:
;;;
;;;    HL = ABCDEFGHIJKLMNOPabcdefghijklmnop0123456789
;;; $4D46 = ABCDEFGHIJKLMNOPabcdefghijkl abcdefghijkl abcdefghijkl abcdefghijkl mnop0123456789
;;;
;;;     $4D 4444444444555555555555555566 666666666666 667777777777 777777888888 88888888889999
;;;         6789ABCDEF0123456789ABCDEF01 23456789ABCD EF0123456789 ABCDEF012345 6789ABCDEF0123
;;;
;; memcpy($HL, 0x4D46, 28);
;; A &= A;  // clear flags?
;; memcpy($(HL+16), 0x4D62, 12);
;; A &= A;  // clear flags?
;; memcpy($(HL+16), 0x4D6E, 12);
;; A &= A;  // clear flags?
;; memcpy($(HL+16), 0x4D7A, 12);
;; memcpy($(HL+28), 0x4D86, 14);
;; return;
[0x814] 2068    0x11    LD  DE, NN      464d        ;  Load register pair DE with 0x464d (70)
[0x817] 2071    0x01    LD  BC, NN      1c00        ;  Load register pair BC with 0x1c00 (28)
[0x81a] 2074    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
[0x81c] 2076    0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
[0x81f] 2079    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x820] 2080    0xed    SBC HL, BC                  ;  Subtract with carry register pair BC from HL
[0x822] 2082    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
[0x824] 2084    0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
[0x827] 2087    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x828] 2088    0xed    SBC HL, BC                  ;  Subtract with carry register pair BC from HL
[0x82a] 2090    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
[0x82c] 2092    0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
[0x82f] 2095    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x830] 2096    0xed    SBC HL, BC                  ;  Subtract with carry register pair BC from HL
[0x832] 2098    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
[0x834] 2100    0x01    LD  BC, NN      0e00        ;  Load register pair BC with 0x0e00 (14)
[0x837] 2103    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
[0x839] 2105    0xc9    RET                         ;  Return

;; triple_byte_copy_4DB8(HL);
; $4DB8 = $HL;
; $4DB9 = $(HL+1);
; $4DBA = $(HL+2);
; return;
[0x83a] 2106    0x11    LD  DE, NN      b84d        ;  Load register pair DE with 0xb84d (184)
[0x83d] 2109    0x01    LD  BC, NN      0300        ;  Load register pair BC with 0x0300 (3)
[0x840] 2112    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
[0x842] 2114    0xc9    RET                         ;  Return


;2115 : table used by 1850
; 0 : 14 1E 46
; 1 : 00 1E 3C
; 2 : 00 00 32
; 3 : 00 00 00


;;; 2127 : red_aggression_dot_thresholds
;;; This is the Red Ghost aggression dot threshold table.  It contains dot counts
;;; below which the red_aggression_1 and red_aggression_2 flags are set.
;;;
;;; Indexed into by ghost_behavior_table @ 1942, copied into $4DBB/$4DBC by code at 1872
; 0 : 14 0A  //  20 10
; 1 : 1E 0F  //  30 15
; 2 : 28 14  //  40 20
; 3 : 32 19  //  50 25
; 4 : 3C 1E  //  60 30
; 5 : 50 28  //  80 30
; 6 : 64 32  // 100 50
; 7 : 78 3C  // 120 60
; 8 : 8C 46  // 140 70


;2145 : table used by 1894
; 0 : 0C 03  //  12 3
; 1 : 48 03  //  72 3
; 2 : D0 02  // 208 2
; 3 : 58 02  //  88 2
; 4 : E0 01  // 224 1
; 5 : 68 01  // 104 1
; 6 : F0 00  // 240 0
; 7 : 78 00  // 120 0
; 8 : 01 00  //   1 0


;2163 : table used by 1916
; 0 : F0 00
; 1 : F0 00
; 2 : B4 00



; Fill $4E09-$4E13 with 0x00
[0x879] 2169    0x21    LD HL, NN       094e        ;  Load register pair HL with 0x094e (19977)
[0x87c] 2172    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x87d] 2173    0x06    LD  B, N        0b          ;  Load register B with 0x0b (11)
[0x87f] 2175    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
; Fill $4E16-$4E33 with 0xFF
; Fill $4D34-$4D37 with 0x14
[0x880] 2176    0xcd    CALL NN         c924        ;  Call to 0xc924 (9417)
; $4E0A = Difficuly ( Normal=0x6800, Hard=0x7D00 )
[0x883] 2179    0x2a    LD HL, (NN)     734e        ;  Load register pair HL with location 0x734e (20083)
[0x886] 2182    0x22    LD (NN), HL     0a4e        ;  Load location 0x0a4e (19978) with the register pair HL
; memcpy($4E0A, $4E38, 46);
[0x889] 2185    0x21    LD HL, NN       0a4e        ;  Load register pair HL with 0x0a4e (19978)
[0x88c] 2188    0x11    LD  DE, NN      384e        ;  Load register pair DE with 0x384e (56)
[0x88f] 2191    0x01    LD  BC, NN      2e00        ;  Load register pair BC with 0x2e00 (46)
[0x892] 2194    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; decrement BC;
; $4E04++;  // $4E04 == game frame
[0x894] 2196    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x897] 2199    0x34    INC (HL)                    ;  Increment location (HL)
[0x898] 2200    0xc9    RET                         ;  Return


; if ( $4E00 == 1 ) { $4E04 = 0x09; }
; else display_erase("PLAYER ONE") by way of 2213 by way of write_msg();
[0x899] 2201    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x89c] 2204    0x3d    DEC A                       ;  Decrement Accumulator
[0x89d] 2205    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
[0x89f] 2207    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
[0x8a1] 2209    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
[0x8a4] 2212    0xc9    RET                         ;  Return
[0x8a5] 2213    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x11, 0x00
; display_erase("PLAYER ONE") by way of write_msg();
[0x8a7] 2215    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x83
[0x8ab] 2219    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x00
[0x8ae] 2222    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x05, 0x00
[0x8b1] 2225    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x10, 0x00
[0x8b4] 2228    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1A, 0x00
[0x8b7] 2231    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
[0x8bb] 2235    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x06, 0x00
; $5003 = $4E72 & $4E09;  // ScreenFlip = Cocktail & CurrentPlayer;
; jump(2196);
[0x8bf] 2239    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
[0x8c2] 2242    0x47    LD B, A                     ;  Load register B with Accumulator
[0x8c3] 2243    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x8c6] 2246    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
[0x8c7] 2247    0x32    LD (NN), A      0350        ;  Load location 0x0350 (20483) with the Accumulator
[0x8ca] 2250    0xc3    JP NN           9408        ;  Jump to 0x9408 (2196)


; if ( $5000 & 0x10 ) {  jump(2270);  }  // $5000.4 == RackTest
; $4E04 = 0x0E;
; rst_28(0x13, 0x00);
[0x8cd] 2253    0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
[0x8d0] 2256    0xcb    BIT 4,A                     ;  Test bit 4 of Accumulator
[0x8d2] 2258    0xc2    JP NZ, NN       de08        ;  Jump to 0xde08 (2270) if ZERO flag is 0
[0x8d5] 2261    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x8d8] 2264    0x36    LD (HL), N      0e          ;  Load register pair HL with 0x0e (14)
[0x8da] 2266    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x13, 0x00
[0x8dd] 2269    0xc9    RET                         ;  Return


; if ( $4E0E == 0xF4 )
; {
;     $4E04 = 0x0C;
;     return;
; }
; else
; {
;     // make a ton of calls
; }
; return;
[0x8de] 2270    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
;; 2272-2279 : On Ms. Pac-Man patched in from $81D8-$81DF
;; On Ms. Pac-Man:
;; 2273  $08e1   0xc3    JP nn           a194        ;  Jump to $nn
;; 2276  $08e4   0x00    NOP                         ;  NOP
[0x8e1] 2273    0xfe    CP N            f4          ;  Compare 0xf4 (244) with Accumulator
[0x8e3] 2275    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
[0x8e5] 2277    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x8e8] 2280    0x36    LD (HL), N      0c          ;  Load location HL with 0x0c (12)
[0x8ea] 2282    0xc9    RET                         ;  Return
[0x8eb] 2283    0xcd    CALL NN         1710        ;  Call to 0x1710 (4119)
[0x8ee] 2286    0xcd    CALL NN         1710        ;  Call to 0x1710 (4119)
[0x8f1] 2289    0xcd    CALL NN         dd13        ;  Call to 0xdd13 (5085)
[0x8f4] 2292    0xcd    CALL NN         420c        ;  Call to 0x420c (3138)
[0x8f7] 2295    0xcd    CALL NN         230e        ;  Call to 0x230e (3619)
[0x8fa] 2298    0xcd    CALL NN         360e        ;  Call to 0x360e (3638)
[0x8fd] 2301    0xcd    CALL NN         c30a        ;  Call to 0xc30a (2755)
[0x900] 2304    0xcd    CALL NN         d60b        ;  Call to 0xd60b (3030)
[0x903] 2307    0xcd    CALL NN         0d0c        ;  Call to 0x0d0c (3085)
[0x906] 2310    0xcd    CALL NN         6c0e        ;  Call to 0x6c0e (3692)
[0x909] 2313    0xcd    CALL NN         ad0e        ;  Call to 0xad0e (3757)
[0x90c] 2316    0xc9    RET                         ;  Return


; $4E12 = 0x01;
; call_9351();
; $4E04++;  // GameFrame++;
; if ( $4E14 != 0 ) {  $4E04++;  return;  }
; if ( $4E70 == 0 ) {  $4E04++;  return;  }
; if ( $4E42 == 0 ) {  $4E04++;  return;  }
; display($4E09) by way of insert_msg(0x1c, A);
; display("GAME OVER") by way of write_msg(); // rst_28(0x1C, 0x05);
; rst_30(0x54, 0x00, 0x00);
; return;
[0x90d] 2317    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x90f] 2319    0x32    LD (NN), A      124e        ;  Load location 0x124e (19986) with the Accumulator
[0x912] 2322    0xcd    CALL NN         8724        ;  Call to 0x8724 (9351)
[0x915] 2325    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x918] 2328    0x34    INC (HL)                    ;  Increment location (HL)
[0x919] 2329    0x3a    LD A, (NN)      144e        ;  Load Accumulator with location 0x144e (19988)
[0x91c] 2332    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x91d] 2333    0x20    JR NZ, N        1f          ;  Jump relative 0x1f (31) if ZERO flag is 0
[0x91f] 2335    0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
[0x922] 2338    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x923] 2339    0x28    JR Z, N         19          ;  Jump relative 0x19 (25) if ZERO flag is 1
[0x925] 2341    0x3a    LD A, (NN)      424e        ;  Load Accumulator with location 0x424e (20034)
[0x928] 2344    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x929] 2345    0x28    JR Z, N         13          ;  Jump relative 0x13 (19) if ZERO flag is 1
[0x92b] 2347    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x92e] 2350    0xc6    ADD A, N        03          ;  Add 0x03 (3) to Accumulator (no carry)
[0x930] 2352    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x931] 2353    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
[0x933] 2355    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
[0x936] 2358    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x05
[0x939] 2361    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
[0x93d] 2365    0xc9    RET                         ;  Return
[0x93e] 2366    0x34    INC (HL)                    ;  Increment location (HL)
[0x93f] 2367    0xc9    RET                         ;  Return


;;; Not the cleanest code I've seen
; if ( $4E70 == 0 && $4E14 != 0 ) {  $4E04 = 0x09;  return;  }
; if ( $4E70 != 0 && $4E42 != 0 ) {  swap_player_state();  }
; if ( $4E70 != 0 && $4E42 == 0 && $4E14 != 0 ) {  $4E04 = 0x09;  return;  }
; display_credits_info();  // via call_11169();
; display("GAME OVER") by way of write_msg();
; rst_30(0x54, 0x00, 0x00);
; $HL++;
; return;
[0x940] 2368    0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
[0x943] 2371    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x944] 2372    0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
[0x946] 2374    0x3a    LD A, (NN)      424e        ;  Load Accumulator with location 0x424e (20034)
[0x949] 2377    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x94a] 2378    0x20    JR NZ, N        15          ;  Jump relative 0x15 (21) if ZERO flag is 0
[0x94c] 2380    0x3a    LD A, (NN)      144e        ;  Load Accumulator with location 0x144e (19988)
[0x94f] 2383    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x950] 2384    0x20    JR NZ, N        1a          ;  Jump relative 0x1a (26) if ZERO flag is 0
[0x952] 2386    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
[0x955] 2389    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x05
[0x958] 2392    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
[0x95c] 2396    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x95f] 2399    0x34    INC (HL)                    ;  Increment location (HL)
[0x960] 2400    0xc9    RET                         ;  Return


;;; swap_player_state()?
; $4E09 ^= 0x01;  // current player
; $4E04 = 0x09;
[0x961] 2401    0xcd    CALL NN         a60a        ;  Call to 0xa60a (2726)  //  swap($4E0A..$4E37,$4E38..$4E65)
[0x964] 2404    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x967] 2407    0xee    XOR N           01          ;  Bitwise XOR of 0x01 (1) to Accumulator
[0x969] 2409    0x32    LD (NN), A      094e        ;  Load location 0x094e (19977) with the Accumulator
[0x96c] 2412    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
[0x96e] 2414    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
[0x971] 2417    0xc9    RET                         ;  Return


;;; clear_a_bunch_of_state_info()?
;  $4E02 = $4E04 = $4E70 = $4E09 = $5003 = 0x00;
;  $4E00 = 0x01;
[0x972] 2418    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x973] 2419    0x32    LD (NN), A      024e        ;  Load location 0x024e (19970) with the Accumulator
[0x976] 2422    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
[0x979] 2425    0x32    LD (NN), A      704e        ;  Load location 0x704e (20080) with the Accumulator
[0x97c] 2428    0x32    LD (NN), A      094e        ;  Load location 0x094e (19977) with the Accumulator
[0x97f] 2431    0x32    LD (NN), A      0350        ;  Load location 0x0350 (20483) with the Accumulator
[0x982] 2434    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x984] 2436    0x32    LD (NN), A      004e        ;  Load location 0x004e (19968) with the Accumulator
[0x987] 2439    0xc9    RET                         ;  Return


[0x988] 2440    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01
[0x98b] 2443    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x01
[0x98e] 2446    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x02, 0x00
[0x991] 2449    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x11, 0x00
[0x994] 2452    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x13, 0x00
[0x997] 2455    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x03, 0x00
[0x99a] 2458    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x00
[0x99d] 2461    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x05, 0x00
[0x9a0] 2464    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x10, 0x00
[0x9a3] 2467    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1A, 0x00
; display("READY!") by way of write_msg();
[0x9a6] 2470    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x06

; if ( $4E00 != 0 )
; {
;     display("GAME OVER") by way of write_msg();
;     rst_28(0x1D, 0x00);
; }
; rst_30(0x54, 0x00, 0x00);
; if ( $4E00 != 1 )
; {
;     rst_30(0x54, 0x06, 0x00);
; }
; $5003 = $4E72 & $4E09;  // ScreenFlip = Cocktail & CurrentPlayer;
; jump(2196);
[0x9a9] 2473    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x9ac] 2476    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x9ae] 2478    0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
; display("GAME OVER") by way of write_msg();
[0x9b0] 2480    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x05
[0x9b3] 2483    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1D, 0x00
[0x9b6] 2486    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
[0x9ba] 2490    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x9bd] 2493    0x3d    DEC A                       ;  Decrement Accumulator
[0x9be] 2494    0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
[0x9c0] 2496    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x06, 0x00
[0x9c4] 2500    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
[0x9c7] 2503    0x47    LD B, A                     ;  Load register B with Accumulator
[0x9c8] 2504    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x9cb] 2507    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
[0x9cc] 2508    0x32    LD (NN), A      0350        ;  Load location 0x0350 (20483) with the Accumulator
[0x9cf] 2511    0xc3    JP NN           9408        ;  Jump to 0x9408 (2196)



; $4E04 = 0x03;  return;
[0x9d2] 2514    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0x9d4] 2516    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
[0x9d7] 2519    0xc9    RET                         ;  Return



; rst_30(0x54, 0x00, 0x00);
; $4E04++;
; $4EAC = $4EBC = 0;  // Sound 2 Waveform A, Sound 3 Waveform A
; return;
[0x9d8] 2520    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
[0x9dc] 2524    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x9df] 2527    0x34    INC (HL)                    ;  Increment location (HL)
[0x9e0] 2528    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x9e1] 2529    0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
[0x9e4] 2532    0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator
[0x9e7] 2535    0xc9    RET                         ;  Return


; insert_msg(0x01, 0x02);  
; rst_30(0x42, 0x00, 0x00);
; HL = 0x0000;
; call_9854();  // Clear 0x4D00-0x4D07
; $4E04++;
; return;
[0x9e8] 2536    0x0e    LD  C, N        02          ;  Load register C with 0x02 (2)
[0x9ea] 2538    0x06    LD  B, N        01          ;  Load register B with 0x01 (1)
[0x9ec] 2540    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
[0x9ef] 2543    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x42, 0x00, 0x00
[0x9f3] 2547    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
[0x9f6] 2550    0xcd    CALL NN         7e26        ;  Call to 0x7e26 (9854)
[0x9f9] 2553    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x9fc] 2556    0x34    INC (HL)                    ;  Increment location (HL)
[0x9fd] 2557    0xc9    RET                         ;  Return

; C = 0;
[0x9fe] 2558    0x0e    LD  C, N        00          ;  Load register C with 0x00 (0)
; jump_2538();  // insert_msg(0x01, 0x00) ... etc.
[0xa00] 2560    0x18    JR N            e8          ;  Jump relative 0xe8 (-24)
; jump_2536();  // insert_msg(0x01, 0x02) ... etc.
[0xa02] 2562    0x18    JR N            e4          ;  Jump relative 0xe4 (-28)
; jump_2558();  // insert_msg(0x01, 0x00) ... etc.
[0xa04] 2564    0x18    JR N            f8          ;  Jump relative 0xf8 (-8)
; jump_2536();  // insert_msg(0x01, 0x02) ... etc.
[0xa06] 2566    0x18    JR N            e0          ;  Jump relative 0xe0 (-32)
; jump_2558();  // insert_msg(0x01, 0x00) ... etc.
[0xa08] 2568    0x18    JR N            f4          ;  Jump relative 0xf4 (-12)
; jump_2536();  // insert_msg(0x01, 0x02) ... etc.
[0xa0a] 2570    0x18    JR N            dc          ;  Jump relative 0xdc (-36)
; jump_2558();  // insert_msg(0x01, 0x00) ... etc.
[0xa0c] 2572    0x18    JR N            f0          ;  Jump relative 0xf0 (-16)



[0xa0e] 2574    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01
[0xa11] 2577    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x06, 0x00
[0xa14] 2580    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x11, 0x00
[0xa17] 2583    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x13, 0x00
[0xa1a] 2586    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x01
[0xa1d] 2589    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x05, 0x01
[0xa20] 2592    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x10, 013
[0xa23] 2595    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x43, 0x00, 0x00
; $4E04++;
; return;
[0xa27] 2599    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0xa2a] 2602    0x34    INC (HL)                    ;  Increment location (HL)
[0xa2b] 2603    0xc9    RET                         ;  Return


;;; post_board_jump();
; $4EAC = $4EBC = 0;  // Sound 2 Waveform A, Sound 3 Waveform A
; $4ECC = $4EDC = 2;  // Sound 1 Waveform Selector, Sound 2 Waveform Selector, 2 == Intermission Music
; if ( $4E13 > 20 ) {  A = 20;  }  // $4E13 ==  current board?
;              else {  A = $4E13;  }
; rst_20();
[0xa2c] 2604    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0xa2d] 2605    0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
;; 2608-2615 : On Ms. Pac-Man patched in from $8118-$811F
[0xa30] 2608    0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator
;; On Ms. Pac-Man:
;; 2611  $0a33   0x18    JR d            06          ;  Jump d
[0xa33] 2611    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0xa35] 2613    0x32    LD (NN), A      cc4e        ;  Load location 0xcc4e (20172) with the Accumulator
[0xa38] 2616    0x32    LD (NN), A      dc4e        ;  Load location 0xdc4e (20188) with the Accumulator
[0xa3b] 2619    0x3a    LD A, (NN)      134e        ;  Load Accumulator with location 0x134e (19987)
[0xa3e] 2622    0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
[0xa40] 2624    0x38    JR C, N         02          ;  Jump to 0x02 (2) if CARRY flag is 1
[0xa42] 2626    0x3e    LD A,N          14          ;  Load Accumulator with 0x14 (20)
[0xa44] 2628    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 1 : $2108 - 
; 2 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 3 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 4 : $219E - 
; 5 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 6 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 7 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 8 : $2297 - 
; 9 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 10 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 11 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 12 : $2297 - 
; 13 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 14 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 15 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 16 : $2297 - 
; 17 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 18 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 19 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();
; 20 : $0A6F - mode_plus_two_and_clear_gameplay_waveforms();


;; mode_plus_two_and_clear_gameplay_waveforms();
; $4E04 += 2;
; $4ECC = $4EDC = 0;  // Sound 1 Waveform Selector, Sound 2 Waveform Selector, 0 == Gameplay
; return;
[0xa6f] 2671    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0xa72] 2674    0x34    INC (HL)                    ;  Increment location (HL)
[0xa73] 2675    0x34    INC (HL)                    ;  Increment location (HL)
[0xa74] 2676    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0xa75] 2677    0x32    LD (NN), A      cc4e        ;  Load location 0xcc4e (20172) with the Accumulator
[0xa78] 2680    0x32    LD (NN), A      dc4e        ;  Load location 0xdc4e (20188) with the Accumulator
[0xa7b] 2683    0xc9    RET                         ;  Return


; $4ECC = $4EDC = 0;  // Sound 1 Waveform Selector, Sound 2 Waveform Selector, 0 == Gameplay
; fill(0x00, $4E0C, 0x07);  // via rst_8();  // $4E0C..$4E12 = 0x00;
; call_9417();  //  $4E16..$4E33 = 0xFF;  $4D34..$4D37 = 0x14
; $4E04++;
; $4E13++;
; if ( $4E0A == 0x14 ) {  return;  }
; $4E0A++;
; return;
[0xa7c] 2684    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0xa7d] 2685    0x32    LD (NN), A      cc4e        ;  Load location 0xcc4e (20172) with the Accumulator
[0xa80] 2688    0x32    LD (NN), A      dc4e        ;  Load location 0xdc4e (20188) with the Accumulator
[0xa83] 2691    0x06    LD  B, N        07          ;  Load register B with 0x07 (7)
[0xa85] 2693    0x21    LD HL, NN       0c4e        ;  Load register pair HL with 0x0c4e (19980)
[0xa88] 2696    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
[0xa89] 2697    0xcd    CALL NN         c924        ;  Call to 0xc924 (9417)
[0xa8c] 2700    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0xa8f] 2703    0x34    INC (HL)                    ;  Increment location (HL)
[0xa90] 2704    0x21    LD HL, NN       134e        ;  Load register pair HL with 0x134e (19987)
[0xa93] 2707    0x34    INC (HL)                    ;  Increment location (HL)
[0xa94] 2708    0x2a    LD HL, (NN)     0a4e        ;  Load register pair HL with location 0x0a4e (19978)
[0xa97] 2711    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0xa98] 2712    0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
[0xa9a] 2714    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0xa9b] 2715    0x23    INC HL                      ;  Increment register pair HL
[0xa9c] 2716    0x22    LD (NN), HL     0a4e        ;  Load location 0x0a4e (19978) with the register pair HL
[0xa9f] 2719    0xc9    RET                         ;  Return


[0xaa0] 2720    0xc3    JP NN           8809        ;  Jump to 0x8809 (2440)
[0xaa3] 2723    0xc3    JP NN           d209        ;  Jump to 0xd209 (2514)


;;; swap_player_state();
; swap($4E0A..$4E37,$4E38..$4E65)
[0xaa6] 2726    0x06    LD  B, N        2e          ;  Load register B with 0x2e (46)
[0xaa8] 2728    0xdd    LD IX, NN       0a4e        ;  Load register pair IX with 0x0a4e (19978)
[0xaac] 2732    0xfd    LD IY, NN       384e        ;  Load register pair IY with 0x384e (20024)
[0xab0] 2736    0xdd    LD D, (IX + N)  00          ;  Load register D with location ( IX + 0x00 () )
[0xab3] 2739    0xfd    LD E, (IY + N)  00          ;  Load register E with location ( IY + 0x00 () )
[0xab6] 2742    0xfd    LD (IY+d), D    00          ;  Load location ( IY + 0x00 () ) with register D
[0xab9] 2745    0xdd    LD (IX+d), E    00          ;  Load location ( IX + 0x00 () ) with register E
[0xabc] 2748    0xdd    INC IX                      ;  Increment register pair IX
[0xabe] 2750    0xfd    INC IY                      ;  Increment register pair IY
[0xac0] 2752    0x10    DJNZ N          ee          ;  Decrement B and jump relative 0xee (-18) if B!=0
[0xac2] 2754    0xc9    RET                         ;  Return


;;; The next 270 bytes are spaghetti

; if ( $4DA4 != 0 ) {  return; }
; if ( $4DC8 != 0 ) {  $4DC8--;  return;  }  // via jump(3026);
; $4DC8 = 14;
; if ( $4DCB == 0 )
; {
;     $4EAC |= 0x80; //  Sound 2 Waveform A?
;     if ( $4DD3 == 9 )
;     {
;         $4EAC &= 0x7F;
;         $4C0B = 9;
;     }
;     else
;     {
;         $4C0B = 0;
;     }
; }
[0xac3] 2755    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
[0xac6] 2758    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xac7] 2759    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xac8] 2760    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
[0xacc] 2764    0xfd    LD IY, NN       c84d        ;  Load register pair IY with 0xc84d (19912)
[0xad0] 2768    0x11    LD  DE, NN      0001        ;  Load register pair DE with 0x0001 (0)
[0xad3] 2771    0xfd    CP A, (IY+d)    00          ;  Compare location ( IY + 0x00 () ) with Accumulator
[0xad6] 2774    0xc2    JP NZ, NN       d20b        ;  Jump to 0xd20b (3026) if ZERO flag is 0
[0xad9] 2777    0xfd    LOAD (IY + N),  0e          ;  Load location ( IY + 0x00 () ) with 0x0e ()
[0xadd] 2781    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
[0xae0] 2784    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xae1] 2785    0x28    JR Z, N         1b          ;  Jump relative 0x1b (27) if ZERO flag is 1
[0xae3] 2787    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
[0xae6] 2790    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xae7] 2791    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0xae9] 2793    0x30    JR NC, N        13          ;  Jump relative 0x13 (19) if CARRY flag is 0
[0xaeb] 2795    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
[0xaee] 2798    0xcb    SET 7,(HL)                  ;  Set bit 7 of location (HL)
[0xaf0] 2800    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
[0xaf2] 2802    0xdd    CP A, (IX+d)    0b          ;  Compare location ( IX + 0x0b () ) with Accumulator
[0xaf5] 2805    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
[0xaf7] 2807    0xcb    RES 7,(HL)                  ;  Reset bit 7 of location (HL)
[0xaf9] 2809    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
[0xafb] 2811    0x32    LD (NN), A      0b4c        ;  Load location 0x0b4c (19467) with the Accumulator

; if ( $4DA7 != 0 )  // $4DA7 == Red Edible
; {
;     if ( $4DCB == 0 ) // $4DCB is evaluated here as 16-bit location via loading into HL
;     {
;         if ( $4C03 == 17 ) {  $4C03 = 18;  } else {  $4C03 = 17;  }
;     }
;     jump(2867);
; }
; if ( $4C03 != 1 ) {  $4C03 = 1;  } else {  $4C03 = 1;  } // WTF?!?!?
[0xafe] 2814    0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
[0xb01] 2817    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xb02] 2818    0x28    JR Z, N         1d          ;  Jump relative 0x1d (29) if ZERO flag is 1
[0xb04] 2820    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
[0xb07] 2823    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xb08] 2824    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0xb0a] 2826    0x30    JR NC, N        27          ;  Jump relative 0x27 (39) if CARRY flag is 0
[0xb0c] 2828    0x3e    LD A,N          11          ;  Load Accumulator with 0x11 (17)
[0xb0e] 2830    0xdd    CP A, (IX+d)    03          ;  Compare location ( IX + 0x03 () ) with Accumulator
[0xb11] 2833    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
[0xb13] 2835    0xdd    LOAD (IX + N),              ;  Load location ( IX + 0x03 () ) with 0x11 ()
[0xb17] 2839    0xc3    JP NN           330b        ;  Jump to 0x330b (2867)
[0xb1a] 2842    0xdd    LOAD (IX + N),              ;  Load location ( IX + 0x03 () ) with 0x12 ()
[0xb1e] 2846    0xc3    JP NN           330b        ;  Jump to 0x330b (2867)
[0xb21] 2849    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0xb23] 2851    0xdd    CP A, (IX+d)    03          ;  Compare location ( IX + 0x03 () ) with Accumulator
[0xb26] 2854    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
[0xb28] 2856    0xdd    LOAD (IX + N),              ;  Load location ( IX + 0x03 () ) with 0x01 ()
[0xb2c] 2860    0xc3    JP NN           330b        ;  Jump to 0x330b (2867)
[0xb2f] 2863    0xdd    LOAD (IX + N),              ;  Load location ( IX + 0x03 () ) with 0x01 ()

; if ( $4DA8 != 0 )  // $4DA8 = Pink Edible
; {
;     if ( $4DCB == 0 ) // $4DCB is evaluated here as 16-bit location via loading into HL
;     {
;         if ( $4C05 == 17 ) {  $4C05 = 18;  } else {  $4C05 = 17;  }
;     }
;     jump(2920);
; }
; if ( $4C05 != 3 ) {  $4C05 = 3;  } else {  $4C05 = 3;  } // WTF?!?!?
[0xb33] 2867    0x3a    LD A, (NN)      a84d        ;  Load Accumulator with location 0xa84d (19880)
[0xb36] 2870    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xb37] 2871    0x28    JR Z, N         1d          ;  Jump relative 0x1d (29) if ZERO flag is 1
[0xb39] 2873    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
[0xb3c] 2876    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xb3d] 2877    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0xb3f] 2879    0x30    JR NC, N        27          ;  Jump relative 0x27 (39) if CARRY flag is 0
[0xb41] 2881    0x3e    LD A,N          11          ;  Load Accumulator with 0x11 (17)
[0xb43] 2883    0xdd    CP A, (IX+d)    05          ;  Compare location ( IX + 0x05 () ) with Accumulator
[0xb46] 2886    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
[0xb48] 2888    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x11 ()
[0xb4c] 2892    0xc3    JP NN           680b        ;  Jump to 0x680b (2920)
[0xb4f] 2895    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x12 ()
[0xb53] 2899    0xc3    JP NN           680b        ;  Jump to 0x680b (2920)
[0xb56] 2902    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0xb58] 2904    0xdd    CP A, (IX+d)    05          ;  Compare location ( IX + 0x05 () ) with Accumulator
[0xb5b] 2907    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
[0xb5d] 2909    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x03 ()
[0xb61] 2913    0xc3    JP NN           680b        ;  Jump to 0x680b (2920)
[0xb64] 2916    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x03 ()

; if ( $4DA9 != 0 )  // $4DA9 = Blue Edible
; {
;     if ( $4DCB == 0 ) // $4DCB is evaluated here as 16-bit location via loading into HL
;     {
;         if ( $4C07 == 17 ) {  $4C07 = 18;  } else {  $4C07 = 17;  }
;     }
;     jump(2969);
; }
; if ( $4C07 != 5 ) {  $4C07 = 5;  } else {  $4C07 = 5;  } // WTF?!?!?
[0xb68] 2920    0x3a    LD A, (NN)      a94d        ;  Load Accumulator with location 0xa94d (19881)
[0xb6b] 2923    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xb6c] 2924    0x28    JR Z, N         1d          ;  Jump relative 0x1d (29) if ZERO flag is 1
[0xb6e] 2926    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
[0xb71] 2929    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xb72] 2930    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0xb74] 2932    0x30    JR NC, N        27          ;  Jump relative 0x27 (39) if CARRY flag is 0
[0xb76] 2934    0x3e    LD A,N          11          ;  Load Accumulator with 0x11 (17)
[0xb78] 2936    0xdd    CP A, (IX+d)    07          ;  Compare location ( IX + 0x07 () ) with Accumulator
[0xb7b] 2939    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
[0xb7d] 2941    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x11 ()
[0xb81] 2945    0xc3    JP NN           9d0b        ;  Jump to 0x9d0b (2973)
[0xb84] 2948    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x12 ()
[0xb88] 2952    0xc3    JP NN           9d0b        ;  Jump to 0x9d0b (2973)
[0xb8b] 2955    0x3e    LD A,N          05          ;  Load Accumulator with 0x05 (5)
[0xb8d] 2957    0xdd    CP A, (IX+d)    07          ;  Compare location ( IX + 0x07 () ) with Accumulator
[0xb90] 2960    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
[0xb92] 2962    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x05 ()
[0xb96] 2966    0xc3    JP NN           9d0b        ;  Jump to 0x9d0b (2973)
[0xb99] 2969    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x05 ()

; if ( $4DAA != 0 )  // $4DAA = Orange Edible
; {
;     if ( $4DCB == 0 ) // $4DCB is evaluated here as 16-bit location via loading into HL
;     {
;         if ( $4C09 == 17 ) {  $4C09 = 18;  } else {  $4C09 = 17;  }
;     }
;     jump(3026);
; }
; if ( $4C09 != 7 ) {  $4C07 = 7;  } else {  $4C07 = 7;  } // WTF?!?!?
[0xb9d] 2973    0x3a    LD A, (NN)      aa4d        ;  Load Accumulator with location 0xaa4d (19882)
[0xba0] 2976    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xba1] 2977    0x28    JR Z, N         1d          ;  Jump relative 0x1d (29) if ZERO flag is 1
[0xba3] 2979    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
[0xba6] 2982    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xba7] 2983    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0xba9] 2985    0x30    JR NC, N        27          ;  Jump relative 0x27 (39) if CARRY flag is 0
[0xbab] 2987    0x3e    LD A,N          11          ;  Load Accumulator with 0x11 (17)
[0xbad] 2989    0xdd    CP A, (IX+d)    09          ;  Compare location ( IX + 0x09 () ) with Accumulator
[0xbb0] 2992    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
[0xbb2] 2994    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x11 ()
[0xbb6] 2998    0xc3    JP NN           d20b        ;  Jump to 0xd20b (3026)
[0xbb9] 3001    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x12 ()
[0xbbd] 3005    0xc3    JP NN           d20b        ;  Jump to 0xd20b (3026)
[0xbc0] 3008    0x3e    LD A,N          07          ;  Load Accumulator with 0x07 (7)
[0xbc2] 3010    0xdd    CP A, (IX+d)    09          ;  Compare location ( IX + 0x09 () ) with Accumulator
[0xbc5] 3013    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
[0xbc7] 3015    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x07 ()
[0xbcb] 3019    0xc3    JP NN           d20b        ;  Jump to 0xd20b (3026)
[0xbce] 3022    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x07 ()

;; 3024-3031 : On Ms. Pac-Man patched in from $80D8-$80DF

; $4DC8--;  return;
[0xbd2] 3026    0xfd    DEC (IY + N)    00          ;  Decrement location IY + 0x00 ()
[0xbd5] 3029    0xc9    RET                         ;  Return


; B = 0x25;
; if ( $4E02 == 0x22 ) {  B = 0;  }
; if ( $4DAC != 0 ) {  $4C03 = B;  }
; if ( $4DAD != 0 ) {  $4C05 = B;  }
; if ( $4DAE != 0 ) {  $4C07 = B;  }
; if ( $4DAF != 0 ) {  $4C09 = B;  }
; return;
[0xbd6] 3030    0x06    LD  B, N        19          ;  Load register B with 0x19 (25)
[0xbd8] 3032    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
[0xbdb] 3035    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
[0xbdd] 3037    0xc2    JP NZ, NN       e20b        ;  Jump to 0xe20b (3042) if ZERO flag is 0
[0xbe0] 3040    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0xbe2] 3042    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
[0xbe6] 3046    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
[0xbe9] 3049    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xbea] 3050    0xca    JP Z,           f00b        ;  Jump to 0xf00b (3056) if ZERO flag is 1
[0xbed] 3053    0xdd    LD (IX+d), B    03          ;  Load location ( IX + 0x03 () ) with register B
[0xbf0] 3056    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
[0xbf3] 3059    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xbf4] 3060    0xca    JP Z,           fa0b        ;  Jump to 0xfa0b (3066) if ZERO flag is 1
[0xbf7] 3063    0xdd    LD (IX+d), B    05          ;  Load location ( IX + 0x05 () ) with register B
[0xbfa] 3066    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
[0xbfd] 3069    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xbfe] 3070    0xca    JP Z,           040c        ;  Jump to 0x040c (3076) if ZERO flag is 1
[0xc01] 3073    0xdd    LD (IX+d), B    07          ;  Load location ( IX + 0x07 () ) with register B
[0xc04] 3076    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
[0xc07] 3079    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xc08] 3080    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0xc09] 3081    0xdd    LD (IX+d), B    09          ;  Load location ( IX + 0x09 () ) with register B
[0xc0c] 3084    0xc9    RET                         ;  Return


; if ( $4DCF++ != 10 ) {  return;  }
; $4DCF = 0;
; if ( $4D04 == 3 )
; {
;     A = ($4464==16)?0:16;  // in absence of other manipulation, causes A to flip-flop between 0/16
;     $4798 = $4784 = $4478 = $4464 = A;  // upper right and left in color RAM
;     return;
; }
; else
; {
;     A = ($4732 == 16)?0:16;
;     $4678 = $4732 = A; // middle-lower and right-middle
;     return; 
; }
[0xc0d] 3085    0x21    LD HL, NN       cf4d        ;  Load register pair HL with 0xcf4d (19919)
[0xc10] 3088    0x34    INC (HL)                    ;  Increment location (HL)
[0xc11] 3089    0x3e    LD A,N          0a          ;  Load Accumulator with 0x0a (10)
[0xc13] 3091    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0xc14] 3092    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xc15] 3093    0x36    LD (HL), N      00          ;  Load register pair HL with 0x00 (0)
[0xc17] 3095    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
[0xc1a] 3098    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0xc1c] 3100    0x20    JR NZ, N        15          ;  Jump relative 0x15 (21) if ZERO flag is 0
[0xc1e] 3102    0x21    LD HL, NN       6444        ;  Load register pair HL with 0x6444 (17508)
;; 3104-3111 : On Ms. Pac-Man patched in from $8120-$8127
;; On Ms. Pac-Man:
;; 3105  $0c21   0xc3    JP nn           2495        ;  Jump to $nn
[0xc21] 3105    0x3e    LD A,N          10          ;  Load Accumulator with 0x10 (16)
[0xc23] 3107    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0xc24] 3108    0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
[0xc26] 3110    0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
[0xc28] 3112    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0xc29] 3113    0x32    LD (NN), A      7844        ;  Load location 0x7844 (17528) with the Accumulator
[0xc2c] 3116    0x32    LD (NN), A      8447        ;  Load location 0x8447 (18308) with the Accumulator
[0xc2f] 3119    0x32    LD (NN), A      9847        ;  Load location 0x9847 (18328) with the Accumulator
[0xc32] 3122    0xc9    RET                         ;  Return
[0xc33] 3123    0x21    LD HL, NN       3247        ;  Load register pair HL with 0x3247 (18226)
[0xc36] 3126    0x3e    LD A,N          10          ;  Load Accumulator with 0x10 (16)
[0xc38] 3128    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0xc39] 3129    0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
[0xc3b] 3131    0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
[0xc3d] 3133    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0xc3e] 3134    0x32    LD (NN), A      7846        ;  Load location 0x7846 (18040) with the Accumulator
[0xc41] 3137    0xc9    RET                         ;  Return


; if ( $4DA4 != 0 ) {  return;  }
; $4D94 c<<= 1;
; if ( ! CARRY ) {  return;  }
; if ( $4DA0 == 0 )
; {
;     $4D00 += 0xFF00;  // double-byte add, $3305 == 0xFF00
;     $4D2C = $4D28 = 3;
;     if ( $4D00 == 100 )
;     {
;         $4D0A = 0x2C2E;  // Red X/Y
;         $4D14 = 0x0001;  // Red direction iterator = left
;         $4D1E = 0x0001;  // Red position predictor iterator = left
;         $4D2C = $4D28 = 2;  // Red direction / eyes = left
;         $4DA0 = 1;
;     }
; }
[0xc42] 3138    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
[0xc45] 3141    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xc46] 3142    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xc47] 3143    0x3a    LD A, (NN)      944d        ;  Load Accumulator with location 0x944d (19860)
[0xc4a] 3146    0x07    RLCA                        ;  Rotate left circular Accumulator
[0xc4b] 3147    0x32    LD (NN), A      944d        ;  Load location 0x944d (19860) with the Accumulator
[0xc4e] 3150    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0xc4f] 3151    0x3a    LD A, (NN)      a04d        ;  Load Accumulator with location 0xa04d (19872)
[0xc52] 3154    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xc53] 3155    0xc2    JP NZ, NN       900c        ;  Jump to 0x900c (3216) if ZERO flag is 0
[0xc56] 3158    0xdd    LD IX, NN       0533        ;  Load register pair IX with 0x0533 (13061)
[0xc5a] 3162    0xfd    LD IY, NN       004d        ;  Load register pair IY with 0x004d (19712)
; HL = (IY) + (IX);
[0xc5e] 3166    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0xc61] 3169    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
[0xc64] 3172    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0xc66] 3174    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
[0xc69] 3177    0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
[0xc6c] 3180    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
[0xc6f] 3183    0xfe    CP N            64          ;  Compare 0x64 (100) with Accumulator
[0xc71] 3185    0xc2    JP NZ, NN       900c        ;  Jump to 0x900c (3216) if ZERO flag is 0
[0xc74] 3188    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
[0xc77] 3191    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
[0xc7a] 3194    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
[0xc7d] 3197    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
[0xc80] 3200    0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
[0xc83] 3203    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0xc85] 3205    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
[0xc88] 3208    0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
[0xc8b] 3211    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0xc8d] 3213    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator

; if ( $4DA1 != 1 )
; {
;     if ( $4DA1 == 0 )
;     {
;         if ( $4D02 == 0x78 ) {  call_7982();  }  // pink_reverse();
;         if ( $4D02 == 0x80 ) {  call_7982();  }  // pink_reverse();
;         $4D29 = $4D2D;
;         $4D02 += $4D20;  // double-byte add
;     }
;     else
;     {
;         $4D02 += 0xFF00;  // double-byte add, $3305 == 0xFF00
;         $4D29 = $4D2D = 3;
;         if ( $4D02 == 100 )
;         {
;             $4D0C = 0x2C2E;  // Pink X/Y
;             $4D16 = 0x0001;  // Pink direction iterator = left
;             $4D20 = 0x0001;  // Pink position predictor iterator = left
;             $4D29 = $4D2D = 2;  // Pink direction / eyes = left
;             $4DA1 = 1;
;         }
;     }
; }
[0xc90] 3216    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
[0xc93] 3219    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0xc95] 3221    0xca    JP Z,           fb0c        ;  Jump to 0xfb0c (3323) if ZERO flag is 1
[0xc98] 3224    0xfe    CP N            00          ;  Compare 0x00 (0) with Accumulator
[0xc9a] 3226    0xc2    JP NZ, NN       c10c        ;  Jump to 0xc10c (3265) if ZERO flag is 0
[0xc9d] 3229    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
[0xca0] 3232    0xfe    CP N            78          ;  Compare 0x78 (120) with Accumulator
[0xca2] 3234    0xcc    CALL Z,NN       2e1f        ;  Call to 0x2e1f (7982) if ZERO flag is 1
[0xca5] 3237    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
[0xca7] 3239    0xcc    CALL Z,NN       2e1f        ;  Call to 0x2e1f (7982) if ZERO flag is 1
[0xcaa] 3242    0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
[0xcad] 3245    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
[0xcb0] 3248    0xdd    LD IX, NN       204d        ;  Load register pair IX with 0x204d (19744)
[0xcb4] 3252    0xfd    LD IY, NN       024d        ;  Load register pair IY with 0x024d (19714)
; HL = (IY) + (IX);
[0xcb8] 3256    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0xcbb] 3259    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
[0xcbe] 3262    0xc3    JP NN           fb0c        ;  Jump to 0xfb0c (3323)
[0xcc1] 3265    0xdd    LD IX, NN       0533        ;  Load register pair IX with 0x0533 (13061)
[0xcc5] 3269    0xfd    LD IY, NN       024d        ;  Load register pair IY with 0x024d (19714)
; HL = (IY) + (IX);
[0xcc9] 3273    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0xccc] 3276    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
[0xccf] 3279    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0xcd1] 3281    0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
[0xcd4] 3284    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
[0xcd7] 3287    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
[0xcda] 3290    0xfe    CP N            64          ;  Compare 0x64 (100) with Accumulator
[0xcdc] 3292    0xc2    JP NZ, NN       fb0c        ;  Jump to 0xfb0c (3323) if ZERO flag is 0
[0xcdf] 3295    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
[0xce2] 3298    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
[0xce5] 3301    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
[0xce8] 3304    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
[0xceb] 3307    0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
[0xcee] 3310    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0xcf0] 3312    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
[0xcf3] 3315    0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
[0xcf6] 3318    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0xcf8] 3320    0x32    LD (NN), A      a14d        ;  Load location 0xa14d (19873) with the Accumulator

; if ( $4DA2 != 1 )
; {
;     if ( $4DA2 == 0 )
;     {
;         if ( $4D04 == 0x78 ) {  call_8021();  }  // blue_reverse();
;         if ( $4D04 == 0x80 ) {  call_8021();  }  // blue_reverse();
;         $4D2A = $4D2E;
;         $4D04 += $4D22;  // double-byte add
;     }
;     else
;     {
;         if ( $4DA2 == 3 )
;         {
;             $4D04 += 0xFF00;  // double-byte add, $3305 == 0xFF00
;             $4D2E = $4D2A = 0;
;             if ( $4D05 == 128 ) {  $4DA2 = 2;  }
;         }
;         else
;         {
;             $4D04 += 0xFF00;  // double-byte add, $3305 == 0xFF00
;             $4D2A = $4D2E = 3;  // Blue direction / eyes = up
;             if ( $4D04 == 100 )
;             {
;                 $4D0E = 0x2C2E;  // Blue X/Y
;                 $4D18 = 0x0001;  // Blue direction iterator = left
;                 $4D22 = 0x0001;  // Blue position predictor iterator = left
;                 $4D2A = $4D2E = 2;  // Blue direction / eyes = left
;                 $4DA2 = 1;
;             }
;         }
;     }
; }
[0xcfb] 3323    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
[0xcfe] 3326    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0xd00] 3328    0xca    JP Z,           930d        ;  Jump to 0x930d (3475) if ZERO flag is 1
[0xd03] 3331    0xfe    CP N            00          ;  Compare 0x00 (0) with Accumulator
[0xd05] 3333    0xc2    JP NZ, NN       2c0d        ;  Jump to 0x2c0d (3372) if ZERO flag is 0
[0xd08] 3336    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
[0xd0b] 3339    0xfe    CP N            78          ;  Compare 0x78 (120) with Accumulator
[0xd0d] 3341    0xcc    CALL Z,NN       551f        ;  Call to 0x551f (8021) if ZERO flag is 1
[0xd10] 3344    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
[0xd12] 3346    0xcc    CALL Z,NN       551f        ;  Call to 0x551f (8021) if ZERO flag is 1
[0xd15] 3349    0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
[0xd18] 3352    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
[0xd1b] 3355    0xdd    LD IX, NN       224d        ;  Load register pair IX with 0x224d (19746)
[0xd1f] 3359    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
; HL = (IY) + (IX);
[0xd23] 3363    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0xd26] 3366    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
[0xd29] 3369    0xc3    JP NN           930d        ;  Jump to 0x930d (3475)
[0xd2c] 3372    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
[0xd2f] 3375    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0xd31] 3377    0xc2    JP NZ, NN       590d        ;  Jump to 0x590d (3417) if ZERO flag is 0
[0xd34] 3380    0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
[0xd38] 3384    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
; HL = (IY) + (IX);
[0xd3c] 3388    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0xd3f] 3391    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
[0xd42] 3394    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0xd43] 3395    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
[0xd46] 3398    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0xd49] 3401    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
[0xd4c] 3404    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
[0xd4e] 3406    0xc2    JP NZ, NN       930d        ;  Jump to 0x930d (3475) if ZERO flag is 0
[0xd51] 3409    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0xd53] 3411    0x32    LD (NN), A      a24d        ;  Load location 0xa24d (19874) with the Accumulator
[0xd56] 3414    0xc3    JP NN           930d        ;  Jump to 0x930d (3475)
[0xd59] 3417    0xdd    LD IX, NN       0533        ;  Load register pair IX with 0x0533 (13061)
[0xd5d] 3421    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
; HL = (IY) + (IX);
[0xd61] 3425    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0xd64] 3428    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
[0xd67] 3431    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0xd69] 3433    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
[0xd6c] 3436    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0xd6f] 3439    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
[0xd72] 3442    0xfe    CP N            64          ;  Compare 0x64 (100) with Accumulator
[0xd74] 3444    0xc2    JP NZ, NN       930d        ;  Jump to 0x930d (3475) if ZERO flag is 0
[0xd77] 3447    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
[0xd7a] 3450    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
[0xd7d] 3453    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
[0xd80] 3456    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
[0xd83] 3459    0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
[0xd86] 3462    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0xd88] 3464    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
[0xd8b] 3467    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0xd8e] 3470    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0xd90] 3472    0x32    LD (NN), A      a24d        ;  Load location 0xa24d (19874) with the Accumulator


; if ( $4DA3 == 1 ) {  return;  }
; if ( $4DA3 == 0 )
; {
;     if ( $4D06 == 0x78 ) {  call_8060();  }  // orange_reverse();
;     if ( $4D06 == 0x80 ) {  call_8060();  }  // orange_reverse();
;     $4D2B = $4D2F;
;     $4D06 += $4D24;  // double-byte add
;     return;
; }
; else
; {
;     if ( $4DA3 == 3 )
;     {
;         $4D06 += $3303;  // double-byte add, $3303 == 0x0001
;         $4D2F = $4D2B = 2;  // Orange direction / eyes = left
;         if ( $4D07 == 128 ) {  $4DA3 = 2;  }
;         return;
;     }
;     else
;     {
;         $4D06 += $3303;  // double-byte add, $3303 == 0x0001
;         $4D2F = $4D2B = 3;  // Orange direction / eyes = up
;         if ( $4D06 == 128 )
;         {
;             $4D10 = 0x2C2E;
;             $4D24 = 0x0001;  // Orange direction iterator = left
;             $4D1A = 0x0001;  // Orange position predictor iterator = left
;             $4D2B = 4D2F = 2;  // Orange direction / eyes = left
;             $4DA3 = 1;
;         }
;         return;
;     }
; }
[0xd93] 3475    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
[0xd96] 3478    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0xd98] 3480    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0xd99] 3481    0xfe    CP N            00          ;  Compare 0x00 (0) with Accumulator
[0xd9b] 3483    0xc2    JP NZ, NN       c00d        ;  Jump to 0xc00d (3520) if ZERO flag is 0
[0xd9e] 3486    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
[0xda1] 3489    0xfe    CP N            78          ;  Compare 0x78 (120) with Accumulator
[0xda3] 3491    0xcc    CALL Z,NN       7c1f        ;  Call to 0x7c1f (8060) if ZERO flag is 1
[0xda6] 3494    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
[0xda8] 3496    0xcc    CALL Z,NN       7c1f        ;  Call to 0x7c1f (8060) if ZERO flag is 1
[0xdab] 3499    0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
[0xdae] 3502    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
[0xdb1] 3505    0xdd    LD IX, NN       244d        ;  Load register pair IX with 0x244d (19748)
[0xdb5] 3509    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
; HL = (IY) + (IX);
[0xdb9] 3513    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0xdbc] 3516    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
[0xdbf] 3519    0xc9    RET                         ;  Return
[0xdc0] 3520    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
[0xdc3] 3523    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0xdc5] 3525    0xc2    JP NZ, NN       ea0d        ;  Jump to 0xea0d (3562) if ZERO flag is 0
[0xdc8] 3528    0xdd    LD IX, NN       0333        ;  Load register pair IX with 0x0333 (13059)
[0xdcc] 3532    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
; HL = (IY) + (IX);
[0xdd0] 3536    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0xdd3] 3539    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
[0xdd6] 3542    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0xdd8] 3544    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
[0xddb] 3547    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0xdde] 3550    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
[0xde1] 3553    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
[0xde3] 3555    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xde4] 3556    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0xde6] 3558    0x32    LD (NN), A      a34d        ;  Load location 0xa34d (19875) with the Accumulator
[0xde9] 3561    0xc9    RET                         ;  Return
[0xdea] 3562    0xdd    LD IX, NN       0533        ;  Load register pair IX with 0x0533 (13061)
[0xdee] 3566    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
; HL = (IY) + (IX);
[0xdf2] 3570    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0xdf5] 3573    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
[0xdf8] 3576    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0xdfa] 3578    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
[0xdfd] 3581    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0xe00] 3584    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
[0xe03] 3587    0xfe    CP N            64          ;  Compare 0x64 (100) with Accumulator
[0xe05] 3589    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xe06] 3590    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
[0xe09] 3593    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
[0xe0c] 3596    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
[0xe0f] 3599    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
[0xe12] 3602    0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
[0xe15] 3605    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0xe17] 3607    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
[0xe1a] 3610    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0xe1d] 3613    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0xe1f] 3615    0x32    LD (NN), A      a34d        ;  Load location 0xa34d (19875) with the Accumulator
[0xe22] 3618    0xc9    RET                         ;  Return


; if ( ++$4DC4 != 8 ) {  return;  }
; $4DC4 = 0;
; $4DC0 ^= 0x01;
; return;
[0xe23] 3619    0x21    LD HL, NN       c44d        ;  Load register pair HL with 0xc44d (19908)
[0xe26] 3622    0x34    INC (HL)                    ;  Increment location (HL)
[0xe27] 3623    0x3e    LD A,N          08          ;  Load Accumulator with 0x08 (8)
[0xe29] 3625    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0xe2a] 3626    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xe2b] 3627    0x36    LD (HL), N      00          ;  Load register pair HL with 0x00 (0)
[0xe2d] 3629    0x3a    LD A, (NN)      c04d        ;  Load Accumulator with location 0xc04d (19904)
[0xe30] 3632    0xee    XOR N           01          ;  Bitwise XOR of 0x01 (1) to Accumulator
[0xe32] 3634    0x32    LD (NN), A      c04d        ;  Load location 0xc04d (19904) with the Accumulator
[0xe35] 3637    0xc9    RET                         ;  Return



; frame_counter()
; {
;     if ( $4DA6 != 0 ) return;  // $4DA6 == ghosts in chase/flee mode (0/1)
;     if ( $4DC1 == 7 ) return;  // $4DC1 == ghost reversal status
;     $4DC2++;
;     if ( $4DC2 > (short)$4D86[$4DC1] )
;     {
;         $4DC1++;
;         $4DB1 = 0x01;
;         $4DB2 = 0x01;
;         $4DB3 = 0x01;
;         $4DB4 = 0x01;
;     }
;     return;
; }
;
; [0x01A4, 0x0654, 0x07F8, 0x0CA8, 0x0DD4, 0x1284, 0x13B0] =
; [420, 1620, 2040, 3240, 3540, 4740, 5040] frames =
; [7, 27, 34, 54, 79, 84] seconds
;
; if ( $4DA6 != 0 ) return;  // $4DA6 == ghosts in chase/flee mode (0/1)
; if ( $4DC1 == 7 ) return;  // $4DC1 == ghost reversal status
; A *= 2;
; HL = $4DC2++;                // $4DC2/3 == chase frames since board/pac start (paused during powerpill)
[0xe36] 3638    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
[0xe39] 3641    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xe3a] 3642    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xe3b] 3643    0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
[0xe3e] 3646    0xfe    CP N            07          ;  Compare 0x07 (7) with Accumulator
[0xe40] 3648    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0xe41] 3649    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0xe42] 3650    0x2a    LD HL, (NN)     c24d        ;  Load register pair HL with location 0xc24d (19906)
[0xe45] 3653    0x23    INC HL                      ;  Increment register pair HL
[0xe46] 3654    0x22    LD (NN), HL     c24d        ;  Load location 0xc24d (19906) with the register pair HL
; DE = ( 0x00, $4DC1 * 2 );
; IX = $4D86[A];  // $4D86 == 0x01A4... (420frames =  7 seconds)
; IX += DE;
; DE = $IX;
; A &= A;
; if ( HL -= DE != 0 ) return;
; A /= 2;
; A++;
; $4DC1 = A;
; $4DB1 = 0x0101;
; $4DB3 = 0x0101;
; return;
[0xe49] 3657    0x5f    LD E, A                     ;  Load register E with Accumulator
[0xe4a] 3658    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0xe4c] 3660    0xdd    LD IX, NN       864d        ;  Load register pair IX with 0x864d (19846)
[0xe50] 3664    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0xe52] 3666    0xdd    LD E, (IX + N)  00          ;  Load register E with location ( IX + 0x00 () )
[0xe55] 3669    0xdd    LD D, (IX + N)  01          ;  Load register D with location ( IX + 0x01 () )
;; 3672-3679 : On Ms. Pac-Man patched in from $8168-$816F
[0xe58] 3672    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
[0xe59] 3673    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0xe5b] 3675    0xc0    RET NZ                      ;  Return if ZERO flag is 0
;; On Ms. Pac-Man:
;; 3676  $0e5c   0xaf    XOR A, A                    ;  XOR of register A to register A
;; 3677  $0e5d   0x00    NOP                         ;  NOP
[0xe5c] 3676    0xcb    SRL A                       ;  Shift Accumulator right logical
[0xe5e] 3678    0x3c    INC A                       ;  Increment Accumulator
[0xe5f] 3679    0x32    LD (NN), A      c14d        ;  Load location 0xc14d (19905) with the Accumulator
[0xe62] 3682    0x21    LD HL, NN       0101        ;  Load register pair HL with 0x0101 (257)
[0xe65] 3685    0x22    LD (NN), HL     b14d        ;  Load location 0xb14d (19889) with the register pair HL
[0xe68] 3688    0x22    LD (NN), HL     b34d        ;  Load location 0xb34d (19891) with the register pair HL
[0xe6b] 3691    0xc9    RET                         ;  Return


; set_maze_completion_status()
; {
;     if ( $4DA5 != 0 ) { $4EAC = 0x00;  return; }
;     switch ( $4E0E )
;     {
;         case 228:
;                  $4EAC:4 == 1;
;                  break;
;         case 212:
;                  $4EAC:3 == 1;
;                  break;
;         case 180:
;                  $4EAC:2 == 1;
;                  break;
;         case 116:
;                  $4EAC:1 == 1;
;                  break;
;         default:
;                  $4EAC:0 == 1;
;     }
;     return;
; }

; if ( $4DA5 != 0 ) { $4EAC = 0x00;  return; }
[0xe6c] 3692    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
[0xe6f] 3695    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
[0xe70] 3696    0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0xe72] 3698    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0xe73] 3699    0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
[0xe76] 3702    0xc9    RET                         ;  Return
; if ( $4E0E == 0xE4 ) {  A = $4EAC & 0xE0;  $4EAC = A | 0x10;  return; }
[0xe77] 3703    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
[0xe7a] 3706    0x06    LD  B, N        e0          ;  Load register B with 0xe0 (224)
[0xe7c] 3708    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
[0xe7f] 3711    0xfe    CP N            e4          ;  Compare 0xe4 (228) with Accumulator
[0xe81] 3713    0x38    JR C, N         06          ;  Jump to 0x06 (6) if CARRY flag is 1
[0xe83] 3715    0x78    LD A, B                     ;  Load Accumulator with register B
[0xe84] 3716    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
[0xe85] 3717    0xcb    SET 4,A                     ;  Set bit 4 of Accumulator
[0xe87] 3719    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0xe88] 3720    0xc9    RET                         ;  Return
; if ( $4E0E == 0xD4 ) {  A = $4EAC & 0xE0;  $4EAC = A | 0x08;  return; }
[0xe89] 3721    0xfe    CP N            d4          ;  Compare 0xd4 (212) with Accumulator
[0xe8b] 3723    0x38    JR C, N         06          ;  Jump to 0x06 (6) if CARRY flag is 1
[0xe8d] 3725    0x78    LD A, B                     ;  Load Accumulator with register B
[0xe8e] 3726    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
[0xe8f] 3727    0xcb    SET 4,A                     ;  Set bit 3 of Accumulator
[0xe91] 3729    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0xe92] 3730    0xc9    RET                         ;  Return
; if ( $4E0E == 0xB4 ) {  A = $4EAC & 0xE0;  $4EAC = A | 0x04;  return; }
[0xe93] 3731    0xfe    CP N            b4          ;  Compare 0xb4 (180) with Accumulator
[0xe95] 3733    0x38    JR C, N         06          ;  Jump to 0x06 (6) if CARRY flag is 1
[0xe97] 3735    0x78    LD A, B                     ;  Load Accumulator with register B
[0xe98] 3736    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
[0xe99] 3737    0xcb    SET 4,A                     ;  Set bit 2 of Accumulator
[0xe9b] 3739    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0xe9c] 3740    0xc9    RET                         ;  Return
; if ( $4E0E == 0x74 ) {  A = $4EAC & 0xE0;  $4EAC = A | 0x02;  return; }
[0xe9d] 3741    0xfe    CP N            74          ;  Compare 0x74 (116) with Accumulator
[0xe9f] 3743    0x38    JR C, N         06          ;  Jump to 0x06 (6) if CARRY flag is 1
[0xea1] 3745    0x78    LD A, B                     ;  Load Accumulator with register B
[0xea2] 3746    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
[0xea3] 3747    0xcb    SET 4,A                     ;  Set bit 1 of Accumulator
[0xea5] 3749    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0xea6] 3750    0xc9    RET                         ;  Return
; A = $4EAC & 0xE0;  $($4EAC) = A | 0x01;  return;
[0xea7] 3751    0x78    LD A, B                     ;  Load Accumulator with register B
;; 3752-3759 : On Ms. Pac-Man patched in from $8198-$819F
[0xea8] 3752    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
;; On Ms. Pac-Man:
;; 3753  $0ea9   0xcbc7  SET 0, A                    ;  Set bit 0 of register A
[0xea9] 3753    0xcb    SET 4,A                     ;  Set bit 0 of Accumulator
[0xeab] 3755    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0xeac] 3756    0xc9    RET                         ;  Return


; if ( $4DA5 != 0 ) {  return;  }  // $4DA5 == related to ghost eat-ability
; if ( $4DD4 != 0 ) {  return;  }  // $4DD4 == ?
; if ( $4E0E != 70 ) // $4E0E == number of dots eaten this board
; {
;     if ( $4E0E != 170 ) {  return;  }
;     if ( $4E0D != 0 )   {  return;  }
;     $4E0D++;
; }
; else
; {
;     if ( $4E0C != 0 ) {  return;  }
;     $4E0C++;
; }
; $4DD2 = 0x9480;
; table = 0x0EFD;  // 3837
; A = ($4E13<=20) ? $4E13 : 20;
; A *= 3;
; A = rst_10(A);
; $4C0C = table[A];
; $4C0D = table[A+1];
; $4DD4 = table[A+2];
; rst_30(0x8A, 0x04, 0x00);
; return;
[0xead] 3757    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
[0xeb0] 3760    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xeb1] 3761    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xeb2] 3762    0x3a    LD A, (NN)      d44d        ;  Load Accumulator with location 0xd44d (19924)
[0xeb5] 3765    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xeb6] 3766    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xeb7] 3767    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
[0xeba] 3770    0xfe    CP N            46          ;  Compare 0x46 (70) with Accumulator
[0xebc] 3772    0x28    JR Z, N         0e          ;  Jump relative 0x0e (14) if ZERO flag is 1
[0xebe] 3774    0xfe    CP N            aa          ;  Compare 0xaa (170) with Accumulator
[0xec0] 3776    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xec1] 3777    0x3a    LD A, (NN)      0d4e        ;  Load Accumulator with location 0x0d4e (19981)
[0xec4] 3780    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xec5] 3781    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xec6] 3782    0x21    LD HL, NN       0d4e        ;  Load register pair HL with 0x0d4e (19981)
[0xec9] 3785    0x34    INC (HL)                    ;  Increment location (HL)
[0xeca] 3786    0x18    JR N            09          ;  Jump relative 0x09 (9)
[0xecc] 3788    0x3a    LD A, (NN)      0c4e        ;  Load Accumulator with location 0x0c4e (19980)
[0xecf] 3791    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0xed0] 3792    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0xed1] 3793    0x21    LD HL, NN       0c4e        ;  Load register pair HL with 0x0c4e (19980)
[0xed4] 3796    0x34    INC (HL)                    ;  Increment location (HL)
[0xed5] 3797    0x21    LD HL, NN       9480        ;  Load register pair HL with 0x9480 (32916)
[0xed8] 3800    0x22    LD (NN), HL     d24d        ;  Load location 0xd24d (19922) with the register pair HL
[0xedb] 3803    0x21    LD HL, NN       fd0e        ;  Load register pair HL with 0xfd0e (3837)
[0xede] 3806    0x3a    LD A, (NN)      134e        ;  Load Accumulator with location 0x134e (19987)
[0xee1] 3809    0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
[0xee3] 3811    0x38    JR C, N         02          ;  Jump to 0x02 (2) if CARRY flag is 1
[0xee5] 3813    0x3e    LD A,N          14          ;  Load Accumulator with 0x14 (20)
[0xee7] 3815    0x47    LD B, A                     ;  Load register B with Accumulator
[0xee8] 3816    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0xee9] 3817    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
[0xeea] 3818    0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
[0xeeb] 3819    0x32    LD (NN), A      0c4c        ;  Load location 0x0c4c (19468) with the Accumulator
[0xeee] 3822    0x23    INC HL                      ;  Increment register pair HL
[0xeef] 3823    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0xef0] 3824    0x32    LD (NN), A      0d4c        ;  Load location 0x0d4c (19469) with the Accumulator
[0xef3] 3827    0x23    INC HL                      ;  Increment register pair HL
[0xef4] 3828    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0xef5] 3829    0x32    LD (NN), A      d44d        ;  Load location 0xd44d (19924) with the Accumulator
[0xef8] 3832    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x8A, 0x04, 0x00
[0xefc] 3836    0xc9    RET                         ;  Return


; table used by 3818
; 0 - 0x00
; 1 - 0x14
; 2 - 0x06

; 3 - 0x01
; 4 - 0x0F
; 5 - 0x07

; 6 - 0x02
; 7 - 0x15
; 8 - 0x08

; 9 - 0x02
; 10 - 0x15
; 11 - 0x08

; 12 - 0x04
; 13 - 0x14
; 14 - 0x09

; 15 - 0x04
; 16 - 0x14
; 17 - 0x09

; 18 - 0x05
; 19 - 0x17
; 20 - 0x0A

; 21 - 0x05
; 22 - 0x17
; 23 - 0x0A

; 24 - 0x06
; 25 - 0x09
; 26 - 0x0B

; 27 - 0x06
; 28 - 0x09
; 29 - 0x0B

; 30 - 0x03
; 31 - 0x16
; 32 - 0x0C

; 33 - 0x03
; 34 - 0x16
; 35 - 0x0C

; 36 - 0x07
; 37 - 0x16
; 38 - 0x0D

; 39 - 0x07
; 40 - 0x16
; 41 - 0x0D

; 42 - 0x07
; 43 - 0x16
; 44 - 0x0D

; 45 - 0x07
; 46 - 0x16
; 47 - 0x0D

; 48 - 0x07
; 49 - 0x16
; 50 - 0x0D

; 51 - 0x07
; 52 - 0x16
; 53 - 0x0D

; 54 - 0x07
; 55 - 0x16
; 56 - 0x0D

; 57 - 0x07
; 58 - 0x16
; 59 - 0x0D

; 60 - 0x07
; 61 - 0x16
; 62 - 0x0D

; 3900-4093 = 0x00 NOP
; 4094, 4095 - Checksum: 0x48, 0x36


;;; clear_fruit_points_YX()
; Clear $4DD4 (fruit_points)
;; 4096-4103 : On Ms. Pac-Man patched in from $8020-$8027
;; On Ms. Pac-Man:
;; 4096  $1000   0xaf    XOR A, A                    ;  XOR of register A to register A
;; 4097  $1001   0x32    LD (nn), A      d44d        ;  Load memory $nn with Accumulator
;; 4100  $1004   0xc9    RET                         ;  Return
;; 4101  $1005   0x00    NOP                         ;  NOP
;; 4102  $1006   0x00    NOP                         ;  NOP
[0x1000] 4096    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1001] 4097    0x32    LD (NN), A      d44d        ;  Load location 0xd44d (19924) with the Accumulator
; Clear $4DD2/3 (fruit_YX)
[0x1004] 4100    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
[0x1007] 4103    0x22    LD (NN), HL     d24d        ;  Load location 0xd24d (19922) with the register pair HL
[0x100a] 4106    0xc9    RET                         ;  Return


; display_erase("100" (stylized)) by way of write_msg();
[0x100b] 4107    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x9B
; if ( $4E00 != 1 ) {  display_erase("MEMORY  OK") by way of write_msg();  }
;; On Ms. Pac-Man:
;; 4110  $100e   0x3a    LD A, (nn)      00c3        ;  Load Accumulator with memory $nn
[0x100e] 4110    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x1011] 4113    0x3d    DEC A                       ;  Decrement Accumulator
[0x1012] 4114    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1013] 4115    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0xA2
[0x1016] 4118    0xc9    RET                         ;  Return



[0x1017] 4119    0xcd    CALL NN         9112        ;  Call to 0x9112 (4753)
; if ( $4DA5 != 0 ) {  return;  }
[0x101a] 4122    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
[0x101d] 4125    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x101e] 4126    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x101f] 4127    0xcd    CALL NN         6610        ;  Call to 0x6610 (4198)
[0x1022] 4130    0xcd    CALL NN         9410        ;  Call to 0x9410 (4244)
[0x1025] 4133    0xcd    CALL NN         9e10        ;  Call to 0x9e10 (4254)
[0x1028] 4136    0xcd    CALL NN         a810        ;  Call to 0xa810 (4264)
[0x102b] 4139    0xcd    CALL NN         b410        ;  Call to 0xb410 (4276)
; if ( $4DA4 != 0 ) {  call_4661();  return;  }
[0x102e] 4142    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
[0x1031] 4145    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1032] 4146    0xca    JP Z,           3910        ;  Jump to 0x3910 (4153) if ZERO flag is 1
[0x1035] 4149    0xcd    CALL NN         3512        ;  Call to 0x3512 (4661)
[0x1038] 4152    0xc9    RET                         ;  Return
[0x1039] 4153    0xcd    CALL NN         1d17        ;  Call to 0x1d17 (5917)
[0x103c] 4156    0xcd    CALL NN         8917        ;  Call to 0x8917 (6025)
; if ( $4DA4 != 0 ) {  return;  }
[0x103f] 4159    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
[0x1042] 4162    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1043] 4163    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1044] 4164    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
[0x1047] 4167    0xcd    CALL NN         361b        ;  Call to 0x361b (6966)
[0x104a] 4170    0xcd    CALL NN         4b1c        ;  Call to 0x4b1c (7243)
[0x104d] 4173    0xcd    CALL NN         221d        ;  Call to 0x221d (7458)
[0x1050] 4176    0xcd    CALL NN         f91d        ;  Call to 0xf91d (7673)
; if ( $4E04 != 3 ) {  return;  } // $4E04 = GameFrame ( 3 == 'Running Game' )
[0x1053] 4179    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
[0x1056] 4182    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x1058] 4184    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1059] 4185    0xcd    CALL NN         7613        ;  Call to 0x7613 (4982)
[0x105c] 4188    0xcd    CALL NN         6920        ;  Call to 0x6920 (8297)
[0x105f] 4191    0xcd    CALL NN         8c20        ;  Call to 0x8c20 (8332)
[0x1062] 4194    0xcd    CALL NN         af20        ;  Call to 0xaf20 (8367)
[0x1065] 4197    0xc9    RET                         ;  Return


; if ( $4DAB = 0 )
; {  return;  }
; if ( $4DAB = 1 }
; {  $4DAB = 0; $4DAC = 1; return;  }
; if ( $4DAB = 2 }
; {  $4DAB = 0; $4DAD = 1; return;  }
; if ( $4DAB = 3 }
; {  $4DAB = 0; $4DAE = 1; return;  }
; $4DAF = A;   // presumably 1
; $4DAB = A-1; // presumably 0
; return;
[0x1066] 4198    0x3a    LD A, (NN)      ab4d        ;  Load Accumulator with location 0xab4d (19883)
[0x1069] 4201    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x106a] 4202    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x106b] 4203    0x3d    DEC A                       ;  Decrement Accumulator
[0x106c] 4204    0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
[0x106e] 4206    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
[0x1071] 4209    0x3c    INC A                       ;  Increment Accumulator
[0x1072] 4210    0x32    LD (NN), A      ac4d        ;  Load location 0xac4d (19884) with the Accumulator
[0x1075] 4213    0xc9    RET                         ;  Return
[0x1076] 4214    0x3d    DEC A                       ;  Decrement Accumulator
[0x1077] 4215    0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
[0x1079] 4217    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
[0x107c] 4220    0x3c    INC A                       ;  Increment Accumulator
[0x107d] 4221    0x32    LD (NN), A      ad4d        ;  Load location 0xad4d (19885) with the Accumulator
[0x1080] 4224    0xc9    RET                         ;  Return
[0x1081] 4225    0x3d    DEC A                       ;  Decrement Accumulator
[0x1082] 4226    0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
[0x1084] 4228    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
[0x1087] 4231    0x3c    INC A                       ;  Increment Accumulator
[0x1088] 4232    0x32    LD (NN), A      ae4d        ;  Load location 0xae4d (19886) with the Accumulator
[0x108b] 4235    0xc9    RET                         ;  Return
[0x108c] 4236    0x32    LD (NN), A      af4d        ;  Load location 0xaf4d (19887) with the Accumulator
[0x108f] 4239    0x3d    DEC A                       ;  Decrement Accumulator
[0x1090] 4240    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
[0x1093] 4243    0xc9    RET                         ;  Return


; // $4DAC - Red chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
[0x1094] 4244    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
[0x1097] 4247    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $000C : return;
; 1 : $10C0 : 4288
; 2 : $10D2 : 4306

; // $4DAD - Pink chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
[0x109e] 4254    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
[0x10a1] 4257    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $000C : return;
; 1 : $1118 : 4376
; 2 : $112A : 4394

; // $4DAE - Blue chomp status ( 0=chase/flee, 1=run back to base, 2=enter base, 3=?)
[0x10a8] 4264    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
[0x10ab] 4267    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $000C : return;
; 1 : $115C : 4444
; 2 : $116E : 4462
; 3 : $118F : 4495

; // $4DAF - Orange chomp status ( 0=chase/flee, 1=run back to base, 2=enter base, 3=?)
[0x10b4] 4276    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
[0x10b7] 4279    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $000C : return;
; 1 : $11C9 : 4553
; 2 : $11DB : 4571
; 3 : $11FC : 4604


; call_7128();
; if ( carry_flag ) {  return;  }
; if ( $4D00 == 100 ) {  $4DAC++;  }  //  $4DAC = Red chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
[0x10c0] 4288    0xcd    CALL NN         d81b        ;  Call to 0xd81b (7128)
[0x10c1] 4289    0xd8    RET C                       ;  Return if CARRY flag is 1
[0x10c2] 4290    0x1b    DEC DE                      ;  Decrement register pair DE
[0x10c3] 4291    0x2a    LD HL, (NN)     004d        ;  Load register pair HL with location 0x004d (19712)
[0x10c6] 4294    0x11    LD  DE, NN      6480        ;  Load register pair DE with 0x6480 (100)
[0x10c9] 4297    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x10ca] 4298    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x10cc] 4300    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x10cd] 4301    0x21    LD HL, NN       ac4d        ;  Load register pair HL with 0xac4d (19884)
[0x10d0] 4304    0x34    INC (HL)                    ;  Increment location (HL)
[0x10d1] 4305    0xc9    RET                         ;  Return


; $4D00 += $3301;  // $4D00++;
; $4D28 = $4D2C = 1;  //  $4D28 - Red Ghost Direction Iterator??, $4D2C - Red Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D00 != 128 ) {  return;  }
; $4D0A = $4D31 = 0x2E2F;  //  $4D0A/B - Red Y/X
; $4DA0 = $4DAC = $4DA7 = 0;  //  $4DAC - Red chomp status ( 0=chase/flee, 1=run back to base, 2=enter base), $4DA7 - Red edible
; if ( $4DAC | $4DAD | $4DAE | $4DAF == 0 )  //  $4DAC/D/E/F - R/P/B/O chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
; {  $4EAC &= 0xBF;  }  //  $4EAC - maze completion status
; return;
[0x10d2] 4306    0xdd    LD IX, NN       0133        ;  Load register pair IX with 0x0133 (13057)
[0x10d6] 4310    0xfd    LD IY, NN       004d        ;  Load register pair IY with 0x004d (19712)  
[0x10da] 4314    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
[0x10dd] 4317    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
[0x10e0] 4320    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x10e2] 4322    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
[0x10e5] 4325    0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
[0x10e8] 4328    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
[0x10eb] 4331    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
[0x10ed] 4333    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x10ee] 4334    0x21    LD HL, NN       2f2e        ;  Load register pair HL with 0x2f2e (11823)
[0x10f1] 4337    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
[0x10f4] 4340    0x22    LD (NN), HL     314d        ;  Load location 0x314d (19761) with the register pair HL
[0x10f7] 4343    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x10f8] 4344    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
[0x10fb] 4347    0x32    LD (NN), A      ac4d        ;  Load location 0xac4d (19884) with the Accumulator
[0x10fe] 4350    0x32    LD (NN), A      a74d        ;  Load location 0xa74d (19879) with the Accumulator
[0x1101] 4353    0xdd    LD IX, NN       ac4d        ;  Load register pair IX with 0xac4d (19884)
[0x1105] 4357    0xdd    OR A, (IX+d)   00           ;  Bitwise OR location ( IX + 0x00 () ) with Accumulator
[0x1108] 4360    0xdd    OR A, (IX+d)   01           ;  Bitwise OR location ( IX + 0x01 () ) with Accumulator
[0x110b] 4363    0xdd    OR A, (IX+d)   02           ;  Bitwise OR location ( IX + 0x02 () ) with Accumulator
[0x110e] 4366    0xdd    OR A, (IX+d)   03           ;  Bitwise OR location ( IX + 0x03 () ) with Accumulator
[0x1111] 4369    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1112] 4370    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
[0x1115] 4373    0xcb    RES 6,(HL)                  ;  Reset bit 6 of location (HL)
[0x1117] 4375    0xc9    RET                         ;  Return


; call_7343();
; if ( $4D02 == 100 ) {  $4DAD++;  }  //  $4DAD = Pink chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
[0x1118] 4376    0xcd    CALL NN         af1c        ;  Call to 0xaf1c (7343)
[0x111b] 4379    0x2a    LD HL, (NN)     024d        ;  Load register pair HL with location 0x024d (19714)
[0x111e] 4382    0x11    LD  DE, NN      6480        ;  Load register pair DE with 0x6480 (100)
[0x1121] 4385    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1122] 4386    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x1124] 4388    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1125] 4389    0x21    LD HL, NN       ad4d        ;  Load register pair HL with 0xad4d (19885)
[0x1128] 4392    0x34    INC (HL)                    ;  Increment location (HL)
[0x1129] 4393    0xc9    RET                         ;  Return


; $4D02 += $3301;  // $4D02++;
; $4D29 = $4D2D = 1;  //  $4D29 - Pink Ghost Direction Iterator??, $4D2D - Pink Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D00 != 128 ) {  return;  }
; $4D0C = $4D33 = 0x2E2F;  //  $4D0C/D - Pink Y/X
; $4DA1 = $4DAD = $4DA8 = 0;  //  $4DAD - Pink chomp status ( 0=chase/flee, 1=run back to base, 2=enter base), $4DA8 - Pink edible
; jump_4353();
[0x112a] 4394    0xdd    LD IX, NN       0133        ;  Load register pair IX with 0x0133 (13057)
[0x112e] 4398    0xfd    LD IY, NN       024d        ;  Load register pair IY with 0x024d (19714)
[0x1132] 4402    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
[0x1135] 4405    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
[0x1138] 4408    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x113a] 4410    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
[0x113d] 4413    0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
[0x1140] 4416    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
[0x1143] 4419    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
[0x1145] 4421    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1146] 4422    0x21    LD HL, NN       2f2e        ;  Load register pair HL with 0x2f2e (11823)
[0x1149] 4425    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
[0x114c] 4428    0x22    LD (NN), HL     334d        ;  Load location 0x334d (19763) with the register pair HL
[0x114f] 4431    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1150] 4432    0x32    LD (NN), A      a14d        ;  Load location 0xa14d (19873) with the Accumulator
[0x1153] 4435    0x32    LD (NN), A      ad4d        ;  Load location 0xad4d (19885) with the Accumulator
[0x1156] 4438    0x32    LD (NN), A      a84d        ;  Load location 0xa84d (19880) with the Accumulator
[0x1159] 4441    0xc3    JP NN           0111        ;  Jump to 0x0111 (4353)


; call_7558();
; if ( $4D04 == 100 ) {  $4DAE++;  }  //  $4DAE = Blue chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
[0x115c] 4444    0xcd    CALL NN         861d        ;  Call to 0x861d (7558)
[0x115f] 4447    0x2a    LD HL, (NN)     044d        ;  Load register pair HL with location 0x044d (19716)
[0x1162] 4450    0x11    LD  DE, NN      6480        ;  Load register pair DE with 0x6480 (100)
[0x1165] 4453    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1166] 4454    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x1168] 4456    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1169] 4457    0x21    LD HL, NN       ae4d        ;  Load register pair HL with 0xae4d (19886)
[0x116c] 4460    0x34    INC (HL)                    ;  Increment location (HL)
[0x116d] 4461    0xc9    RET                         ;  Return


; $4D04 += $3301;  // $4D04++;
; $4D2A = $4D2E = 1;  //  $4D2A - Blue Ghost Direction Iterator??, $4D2E - Blue Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D04 == 128 ) {  $4DAE++;  }  //  $4DAE = Blue chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
[0x116e] 4462    0xdd    LD IX, NN       0133        ;  Load register pair IX with 0x0133 (13057)
[0x1172] 4466    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
[0x1176] 4470    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
[0x1179] 4473    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
[0x117c] 4476    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x117e] 4478    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
[0x1181] 4481    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0x1184] 4484    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
[0x1187] 4487    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
[0x1189] 4489    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x118a] 4490    0x21    LD HL, NN       ae4d        ;  Load register pair HL with 0xae4d (19886)
[0x118d] 4493    0x34    INC (HL)                    ;  Increment location (HL)
[0x118e] 4494    0xc9    RET                         ;  Return


; $4D04 += $3301;  // $4D04++;
; $4D2A = $4D2E = 2;  //  $4D2A - Blue Ghost Direction Iterator??, $4D2E - Blue Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D05 != 144 ) {  return;  }
; $4D0E = $4D35 = 0x2F30;  //  $4D0E/F = Blue Y/X
; $4D2A = $4D2E = 1;  //  $4D2A - Blue Ghost Direction Iterator??, $4D2E - Blue Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; $4DA2 = $4DAE = $4DA9 = 0;  //  $4DAE - Blue chomp status ( 0=chase/flee, 1=run back to base, 2=enter base), $4DA9 - Blue edible
; jump_4353();
[0x118f] 4495    0xdd    LD IX, NN       0333        ;  Load register pair IX with 0x0333 (13059)
[0x1193] 4499    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
[0x1197] 4503    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
[0x119a] 4506    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
[0x119d] 4509    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0x119f] 4511    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
[0x11a2] 4514    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0x11a5] 4517    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
[0x11a8] 4520    0xfe    CP N            90          ;  Compare 0x90 (144) with Accumulator
[0x11aa] 4522    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x11ab] 4523    0x21    LD HL, NN       2f30        ;  Load register pair HL with 0x2f30 (12335)
[0x11ae] 4526    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
[0x11b1] 4529    0x22    LD (NN), HL     354d        ;  Load location 0x354d (19765) with the register pair HL
[0x11b4] 4532    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x11b6] 4534    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
[0x11b9] 4537    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0x11bc] 4540    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x11bd] 4541    0x32    LD (NN), A      a24d        ;  Load location 0xa24d (19874) with the Accumulator
[0x11c0] 4544    0x32    LD (NN), A      ae4d        ;  Load location 0xae4d (19886) with the Accumulator
[0x11c3] 4547    0x32    LD (NN), A      a94d        ;  Load location 0xa94d (19881) with the Accumulator
[0x11c6] 4550    0xc3    JP NN           0111        ;  Jump to 0x0111 (4353)


; call_7773();
; if ( $4D06 == 100 ) {  $4DAF++;  }  //  $4DAF = Orange chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
[0x11c9] 4553    0xcd    CALL NN         5d1e        ;  Call to 0x5d1e (7773)
[0x11cc] 4556    0x2a    LD HL, (NN)     064d        ;  Load register pair HL with location 0x064d (19718)
[0x11cf] 4559    0x11    LD  DE, NN      6480        ;  Load register pair DE with 0x6480 (100)
[0x11d2] 4562    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x11d3] 4563    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x11d5] 4565    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x11d6] 4566    0x21    LD HL, NN       af4d        ;  Load register pair HL with 0xaf4d (19887)
[0x11d9] 4569    0x34    INC (HL)                    ;  Increment location (HL)
[0x11da] 4570    0xc9    RET                         ;  Return


; $4D06 += $3301;  // $4D04++;
; $4D2B = $4D2F = 1;  //  $4D2B - Orange Ghost Direction Iterator??, $4D2F - Orange Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D06 == 128 ) {  $4D2F++  }
; return;
[0x11db] 4571    0xdd    LD IX, NN       0133        ;  Load register pair IX with 0x0133 (13057)
[0x11df] 4575    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
[0x11e3] 4579    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
[0x11e6] 4582    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
[0x11e9] 4585    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x11eb] 4587    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
[0x11ee] 4590    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0x11f1] 4593    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
[0x11f4] 4596    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
[0x11f6] 4598    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x11f7] 4599    0x21    LD HL, NN       af4d        ;  Load register pair HL with 0xaf4d (19887)
[0x11fa] 4602    0x34    INC (HL)                    ;  Increment location (HL)
[0x11fb] 4603    0xc9    RET                         ;  Return


; $4D06 += $3301;  // $4D06++;
; $4D2B = $4D2F = 0;  //  $4D2B - Orange Ghost Direction Iterator??, $4D2F - Orange Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D07 != 112 ) {  return;  }
; $4D10 = $4D37 = 0x2F2C;  //  $4D10/1 = Ornage Y/X
; $4D2B = $4D2F = 1;  //  $4D2B - Orange Ghost Direction Iterator??, $4D2F - Orange Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; $4DA3 = $4DAF = $4DAA = 0;  //  $4DAF - Orange chomp status ( 0=chase/flee, 1=run back to base, 2=enter base), $4DAA - Orange edible
; jump_4353();
[0x11fc] 4604    0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
[0x1200] 4608    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
[0x1204] 4612    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
[0x1207] 4615    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
[0x120a] 4618    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x120b] 4619    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
[0x120e] 4622    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0x1211] 4625    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
[0x1214] 4628    0xfe    CP N            70          ;  Compare 0x70 (112) with Accumulator
[0x1216] 4630    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1217] 4631    0x21    LD HL, NN       2f2c        ;  Load register pair HL with 0x2f2c (11311)
[0x121a] 4634    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
[0x121d] 4637    0x22    LD (NN), HL     374d        ;  Load location 0x374d (19767) with the register pair HL
[0x1220] 4640    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x1222] 4642    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
[0x1225] 4645    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0x1228] 4648    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1229] 4649    0x32    LD (NN), A      a34d        ;  Load location 0xa34d (19875) with the Accumulator
[0x122c] 4652    0x32    LD (NN), A      af4d        ;  Load location 0xaf4d (19887) with the Accumulator
[0x122f] 4655    0x32    LD (NN), A      aa4d        ;  Load location 0xaa4d (19882) with the Accumulator
[0x1232] 4658    0xc3    JP NN           0111        ;  Jump to 0x0111 (4353)

; A = 4DD1;
; rst_20();
[0x1235] 4661    0x3a    LD A, (NN)      d14d        ;  Load Accumulator with location 0xd14d (19921)
[0x1238] 4664    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; Table for RST20 @ 4665
; 00 : 0x123F - 4671
; 01 : 0x000C - return;
; 02 : 0x123F - 4671


; HL = 0x4C00 + ( $4DA4 * 2 );
; if ( $4DD1 == 0 )
; {
;     B = $4DD0 + 39;  //  $4DD0 - how many ghosts eaten this powerpill?
;     A = $4E72;  //  $4E72 - Upright ( 0 ) vs Cocktail ( 1 )
;     C = $4E09;  //  $4E09 - current player ( 0=Player1, !0= Player2 )
;     if ( cocktail && player_2 ) {  B |= 0xC0;  }
;     $HL = B;
;     $HL++;
;     $HL = 0x18;
;     $4C0B = A;
;     rst_30(0x4A, 0x03, 0x00);
;     $4DD1++;
;     return;
; }
; $HL = 0x20;
; $4C0B = 9;
; $4DAB = $4DA4;
; $4DA4 = $4DD1 = 0;
; $4EAC |= 0x40;
; return;
[0x123f] 4671    0x21    LD HL, NN       004c        ;  Load register pair HL with 0x004c (19456)
[0x1242] 4674    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
[0x1245] 4677    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x1246] 4678    0x5f    LD E, A                     ;  Load register E with Accumulator
[0x1247] 4679    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x1249] 4681    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x124a] 4682    0x3a    LD A, (NN)      d14d        ;  Load Accumulator with location 0xd14d (19921)
[0x124d] 4685    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x124e] 4686    0x20    JR NZ, N        27          ;  Jump relative 0x27 (39) if ZERO flag is 0
[0x1250] 4688    0x3a    LD A, (NN)      d04d        ;  Load Accumulator with location 0xd04d (19920)
[0x1253] 4691    0x06    LD  B, N        27          ;  Load register B with 0x27 (39)
[0x1255] 4693    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
[0x1256] 4694    0x47    LD B, A                     ;  Load register B with Accumulator
[0x1257] 4695    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
[0x125a] 4698    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x125b] 4699    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x125e] 4702    0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
[0x125f] 4703    0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
[0x1261] 4705    0xcb    SET 6,B                     ;  Set bit 6 of register B
[0x1263] 4707    0xcb    SET 6,B                     ;  Set bit 7 of register B
[0x1265] 4709    0x70    LD (HL), B                  ;  Load location (HL) with register B
[0x1266] 4710    0x23    INC HL                      ;  Increment register pair HL
[0x1267] 4711    0x36    LD (HL), N      18          ;  Load register pair HL with 0x18 (24)
[0x1269] 4713    0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
[0x126b] 4715    0x32    LD (NN), A      0b4c        ;  Load location 0x0b4c (19467) with the Accumulator
[0x126e] 4718    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4A, 0x03, 0x00
[0x1272] 4722    0x21    LD HL, NN       d14d        ;  Load register pair HL with 0xd14d (19921)
[0x1275] 4725    0x34    INC (HL)                    ;  Increment location (HL)
[0x1276] 4726    0xc9    RET                         ;  Return
[0x1277] 4727    0x36    LD (HL), N      20          ;  Load register pair HL with 0x20 (32)
[0x1279] 4729    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
[0x127b] 4731    0x32    LD (NN), A      0b4c        ;  Load location 0x0b4c (19467) with the Accumulator
[0x127e] 4734    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
[0x1281] 4737    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
[0x1284] 4740    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1285] 4741    0x32    LD (NN), A      a44d        ;  Load location 0xa44d (19876) with the Accumulator
;; 4744-4751 : On Ms. Pac-Man patched in from $8098-$809F
[0x1288] 4744    0x32    LD (NN), A      d14d        ;  Load location 0xd14d (19921) with the Accumulator
[0x128b] 4747    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
[0x128e] 4750    0xcb    SET 6,(HL)                  ;  Set bit 6 of location (HL)
[0x1290] 4752    0xc9    RET                         ;  Return


;; 4753-4981:
; switch ( $4DA5)
; {
;     case 0 : return;
;     case 1 :
;     case 2 :
;     case 3 :
;     case 4 : if ( $4DC5++ == 120 ) {  $4DA5 = 5;  }
;              return;
;     case 5 : HL = 0x0000;
;              call_9854();   // Clear 0x4D00-0x4D07
;              A=52;    DE=180;    break;
;     case 6 : $4EBC &= 0x10;
;              A=53;    DE=195;    break;
;     case 7 : A=54;    DE=210;    break;
;     case 8 : A=55;    DE=225;    break;
;     case 9 : A=56;    DE=240;    break;
;     case 10 : A=57;    DE=255;    break;
;     case 11 : A=58;    DE=270;    break;
;     case 12 : A=59;    DE=285;    break;
;     case 13 : A=60;    DE=300;    break;
;     case 14 : A=61;    DE=315;    break;
;     case 15 : $4EBC = 0x20;
;               A=62;    DE=345;    break;
;     case 16 : $4C0A = 63;
;               HL = ++$4DC5;
;                        DE=440;
;               A &= A;  // clear flags
;               if ( DE != HL ) {  return;  }
;               $4E14++;
;               $4E15++;
;               call_9845();  // Clear 0x4D00-0x4D09,0x4DD2-0x4DD3
;               $4E04++;
; }
; // the following is from 4822-4856
; C=A;
; if ( ! $4E72 & $4E09 ) {  A = 0xC0; } //  if ( ! cocktail_mode & player_two ) ...
; $4C0A = A | C;
; HL = ++$4DC5;
; if ( HL == DE ) {  $4DA5++;  }
; return;

[0x1291] 4753    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
[0x1294] 4756    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $000C - return;
; 1 : $12B7 - jump_4791()
; 2 : $12B7 - jump_4791()
; 3 : $12B7 - jump_4791()
; 4 : $12B7 - jump_4791()
; 5 : $12CB - jump_4811()
; 6 : $12F9 - jump_4857()
; 7 : $1306 - jump_4870()
; 8 : $130E - jump_4878()
; 9 : $1316 - jump_4886()
; 10 : $131E - jump_4894()
; 11 : $1326 - jump_4902()
; 12 : $132E - jump_4910()
; 13 : $1336 - jump_4918()
; 14 : $133E - jump_4926()
; 15 : $1346 - jump_4934()
; 16 : $1353 - jump_4947()


[0x12b7] 4791    0x2a    LD HL, (NN)     c54d        ;  Load register pair HL with location 0xc54d (19909)
[0x12ba] 4794    0x23    INC HL                      ;  Increment register pair HL
[0x12bb] 4795    0x22    LD (NN), HL     c54d        ;  Load location 0xc54d (19909) with the register pair HL
[0x12be] 4798    0x11    LD  DE, NN      7800        ;  Load register pair DE with 0x7800 (120)
[0x12c1] 4801    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
[0x12c2] 4802    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x12c4] 4804    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x12c5] 4805    0x3e    LD A,N          05          ;  Load Accumulator with 0x05 (5)
[0x12c7] 4807    0x32    LD (NN), A      a54d        ;  Load location 0xa54d (19877) with the Accumulator
[0x12ca] 4810    0xc9    RET                         ;  Return

[0x12cb] 4811    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
[0x12ce] 4814    0xcd    CALL NN         7e26        ;  Call to 0x7e26 (9854)
[0x12d1] 4817    0x3e    LD A,N          34          ;  Load Accumulator with 0x34 (52)
[0x12d3] 4819    0x11    LD  DE, NN      b400        ;  Load register pair DE with 0xb400 (180)

;; used by a number of entry points in nearby....
[0x12d6] 4822    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x12d7] 4823    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
[0x12da] 4826    0x47    LD B, A                     ;  Load register B with Accumulator
[0x12db] 4827    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x12de] 4830    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
[0x12df] 4831    0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
[0x12e1] 4833    0x3e    LD A,N          c0          ;  Load Accumulator with 0xc0 (192)
[0x12e3] 4835    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x12e4] 4836    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x12e5] 4837    0x79    LD A, C                     ;  Load Accumulator with register C
[0x12e6] 4838    0x32    LD (NN), A      0a4c        ;  Load location 0x0a4c (19466) with the Accumulator
[0x12e9] 4841    0x2a    LD HL, (NN)     c54d        ;  Load register pair HL with location 0xc54d (19909)
[0x12ec] 4844    0x23    INC HL                      ;  Increment register pair HL
[0x12ed] 4845    0x22    LD (NN), HL     c54d        ;  Load location 0xc54d (19909) with the register pair HL
[0x12f0] 4848    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x12f1] 4849    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x12f3] 4851    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x12f4] 4852    0x21    LD HL, NN       a54d        ;  Load register pair HL with 0xa54d (19877)
[0x12f7] 4855    0x34    INC (HL)                    ;  Increment location (HL)
[0x12f8] 4856    0xc9    RET                         ;  Return

[0x12f9] 4857    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
[0x12fc] 4860    0xcb    SET 4,(HL)                  ;  Set bit 4 of location (HL)
[0x12fe] 4862    0x3e    LD A,N          35          ;  Load Accumulator with 0x35 (53)
[0x1300] 4864    0x11    LD  DE, NN      c300        ;  Load register pair DE with 0xc300 (195)
[0x1303] 4867    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x1306] 4870    0x3e    LD A,N          36          ;  Load Accumulator with 0x36 (54)
[0x1308] 4872    0x11    LD  DE, NN      d200        ;  Load register pair DE with 0xd200 (210)
[0x130b] 4875    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x130e] 4878    0x3e    LD A,N          37          ;  Load Accumulator with 0x37 (55)
[0x1310] 4880    0x11    LD  DE, NN      e100        ;  Load register pair DE with 0xe100 (225)
[0x1313] 4883    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x1316] 4886    0x3e    LD A,N          38          ;  Load Accumulator with 0x38 (56)
[0x1318] 4888    0x11    LD  DE, NN      f000        ;  Load register pair DE with 0xf000 (240)
[0x131b] 4891    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x131e] 4894    0x3e    LD A,N          39          ;  Load Accumulator with 0x39 (57)
[0x1320] 4896    0x11    LD  DE, NN      ff00        ;  Load register pair DE with 0xff00 (255)
[0x1323] 4899    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x1326] 4902    0x3e    LD A,N          3a          ;  Load Accumulator with 0x3a (58)
[0x1328] 4904    0x11    LD  DE, NN      0e01        ;  Load register pair DE with 0x0e01 (14)
[0x132b] 4907    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x132e] 4910    0x3e    LD A,N          3b          ;  Load Accumulator with 0x3b (59)
[0x1330] 4912    0x11    LD  DE, NN      1d01        ;  Load register pair DE with 0x1d01 (29)
[0x1333] 4915    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x1336] 4918    0x3e    LD A,N          3c          ;  Load Accumulator with 0x3c (60)
[0x1338] 4920    0x11    LD  DE, NN      2c01        ;  Load register pair DE with 0x2c01 (44)
[0x133b] 4923    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x133e] 4926    0x3e    LD A,N          3d          ;  Load Accumulator with 0x3d (61)
[0x1340] 4928    0x11    LD  DE, NN      3b01        ;  Load register pair DE with 0x3b01 (59)
[0x1343] 4931    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x1346] 4934    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
;; 4936-4943 : On Ms. Pac-Man patched in from $8048-$804F
;; On Ms. Pac-Man:
;; 4937  $1349   0x36    LD (HL), n      00          ;  Load memory $HL with n
[0x1349] 4937    0x36    LD (HL), N      20          ;  Load register pair HL with 0x20 (32)
[0x134b] 4939    0x3e    LD A,N          3e          ;  Load Accumulator with 0x3e (62)
[0x134d] 4941    0x11    LD  DE, NN      5901        ;  Load register pair DE with 0x5901 (89)
[0x1350] 4944    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

[0x1353] 4947    0x3e    LD A,N          3f          ;  Load Accumulator with 0x3f (63)
[0x1355] 4949    0x32    LD (NN), A      0a4c        ;  Load location 0x0a4c (19466) with the Accumulator
[0x1358] 4952    0x2a    LD HL, (NN)     c54d        ;  Load register pair HL with location 0xc54d (19909)
[0x135b] 4955    0x23    INC HL                      ;  Increment register pair HL
[0x135c] 4956    0x22    LD (NN), HL     c54d        ;  Load location 0xc54d (19909) with the register pair HL
[0x135f] 4959    0x11    LD  DE, NN      b801        ;  Load register pair DE with 0xb801 (184)
[0x1362] 4962    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1363] 4963    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x1365] 4965    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1366] 4966    0x21    LD HL, NN       144e        ;  Load register pair HL with 0x144e (19988)
[0x1369] 4969    0x35    DEC (HL)                    ;  Decrement location (HL)
[0x136a] 4970    0x21    LD HL, NN       154e        ;  Load register pair HL with 0x154e (19989)
[0x136d] 4973    0x35    DEC (HL)                    ;  Decrement location (HL)
[0x136e] 4974    0xcd    CALL NN         7526        ;  Call to 0x7526 (9845)
[0x1371] 4977    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x1374] 4980    0x34    INC (HL)                    ;  Increment location (HL)
[0x1375] 4981    0xc9    RET                         ;  Return


;; powerpill_off()  // ??
; if ( $4DA6 == 0 ) {  return;  }   // if ( ! ghosts_blue ) {  return;  }
; $4DA8 ^= $4DA7;    // pink_edible ^= red_edible;
; $4DA9 ^= $4DA7;    // blue_edible ^= red_edible;
; if ( $4DAA ^= $4DA7 ) // orange_edible ^= red_edible;
; {  if ( --$4DCB == 0 ) {  return;  }  }
; $4C0B = 9;
; if ( $4DAC == 0 ) {  $4DA7 = 0;  }  // if ( red_status == chase/flee ) {  red_edible = 0;  }
; if ( $4DAD == 0 ) {  $4DA8 = 0;  }  // if ( pink_status == chase/flee ) {  pink_edible = 0;  }
; if ( $4DAE == 0 ) {  $4DA9 = 0;  }  // if ( blue_status == chase/flee ) {  blue_edible = 0;  }
; if ( $4DAF == 0 ) {  $4DAA = 0;  }  // if ( orange_status == chase/flee ) {  orange_edible = 0;  }
; $4DD0 = $4DC8 = $4DA6 = $4DCC = $4DCB = 0;
; $4EAC &= 0x5F;                   // $4EAC == maze completion status
; return;
[0x1376] 4982    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
[0x1379] 4985    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x137a] 4986    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x137b] 4987    0xdd    LD IX, NN       a74d        ;  Load register pair IX with 0xa74d (19879)
[0x137f] 4991    0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
[0x1382] 4994    0xdd    XOR A, (IX+d)   01          ;  Bitwise XOR location ( IX + 0x01 () ) with Accumulator
[0x1385] 4997    0xdd    XOR A, (IX+d)   02          ;  Bitwise XOR location ( IX + 0x02 () ) with Accumulator
[0x1388] 5000    0xdd    XOR A, (IX+d)   03          ;  Bitwise XOR location ( IX + 0x03 () ) with Accumulator
[0x138b] 5003    0xca    JP Z,           9813        ;  Jump to 0x9813 (5016) if ZERO flag is 1
[0x138e] 5006    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
[0x1391] 5009    0x2b    DEC HL                      ;  Decrement register pair HL
[0x1392] 5010    0x22    LD (NN), HL     cb4d        ;  Load location 0xcb4d (19915) with the register pair HL
[0x1395] 5013    0x7c    LD A, H                     ;  Load Accumulator with register H
[0x1396] 5014    0xb5    OR A, L                     ;  Bitwise OR of register L to Accumulator
[0x1397] 5015    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1398] 5016    0x21    LD HL, NN       0b4c        ;  Load register pair HL with 0x0b4c (19467)
[0x139b] 5019    0x36    LD (HL), N      09          ;  Load register pair HL with 0x09 (9)
[0x139d] 5021    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
[0x13a0] 5024    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x13a1] 5025    0xc2    JP NZ, NN       a713        ;  Jump to 0xa713 (5031) if ZERO flag is 0
[0x13a4] 5028    0x32    LD (NN), A      a74d        ;  Load location 0xa74d (19879) with the Accumulator
[0x13a7] 5031    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
[0x13aa] 5034    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x13ab] 5035    0xc2    JP NZ, NN       b113        ;  Jump to 0xb113 (5041) if ZERO flag is 0
[0x13ae] 5038    0x32    LD (NN), A      a84d        ;  Load location 0xa84d (19880) with the Accumulator
[0x13b1] 5041    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
[0x13b4] 5044    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x13b5] 5045    0xc2    JP NZ, NN       bb13        ;  Jump to 0xbb13 (5051) if ZERO flag is 0
[0x13b8] 5048    0x32    LD (NN), A      a94d        ;  Load location 0xa94d (19881) with the Accumulator
[0x13bb] 5051    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
[0x13be] 5054    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x13bf] 5055    0xc2    JP NZ, NN       c513        ;  Jump to 0xc513 (5061) if ZERO flag is 0
[0x13c2] 5058    0x32    LD (NN), A      aa4d        ;  Load location 0xaa4d (19882) with the Accumulator
[0x13c5] 5061    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x13c6] 5062    0x32    LD (NN), A      cb4d        ;  Load location 0xcb4d (19915) with the Accumulator
[0x13c9] 5065    0x32    LD (NN), A      cc4d        ;  Load location 0xcc4d (19916) with the Accumulator
[0x13cc] 5068    0x32    LD (NN), A      a64d        ;  Load location 0xa64d (19878) with the Accumulator
[0x13cf] 5071    0x32    LD (NN), A      c84d        ;  Load location 0xc84d (19912) with the Accumulator
[0x13d2] 5074    0x32    LD (NN), A      d04d        ;  Load location 0xd04d (19920) with the Accumulator
[0x13d5] 5077    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
[0x13d8] 5080    0xcb    RES 5,(HL)                  ;  Reset bit 5 of location (HL)
[0x13da] 5082    0xcb    RES 7,(HL)                  ;  Reset bit 7 of location (HL)
[0x13dc] 5084    0xc9    RET                         ;  Return


; if ( $4D9E != A=$4E0E ) {  $4D97 = 0x0000;  return;  }
[0x13dd] 5085    0x21    LD HL, NN       9e4d        ;  Load register pair HL with 0x9e4d (19870)
[0x13e0] 5088    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
[0x13e3] 5091    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x13e4] 5092    0xca    JP Z,           ee13        ;  Jump to 0xee13 (5102) if ZERO flag is 1
[0x13e7] 5095    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
[0x13ea] 5098    0x22    LD (NN), HL     974d        ;  Load location 0x974d (19863) with the register pair HL
[0x13ed] 5101    0xc9    RET                         ;  Return


; $4D97++;
; if ( $4D97 - $4D95 != 0 ) {  return;  }
; $4D97 = 0x00;
; if ( $4DA1 == 0 ) {  $4DA1 = 2; /*via 8326*/  return;  }
; if ( $4DA2 == 0 ) {  $4DA2 = 3; /*via 8361*/  return;  }
; if ( $4DA3 == 0 ) {  $4DA3 = 3; /*via 8401*/  return;  }
; return;
[0x13ee] 5102    0x2a    LD HL, (NN)     974d        ;  Load register pair HL with location 0x974d (19863)
[0x13f1] 5105    0x23    INC HL                      ;  Increment register pair HL
[0x13f2] 5106    0x22    LD (NN), HL     974d        ;  Load location 0x974d (19863) with the register pair HL
[0x13f5] 5109    0xed    LD DE, (NN)     954d        ;  Load register pair DE with location 0x954d (19861)
[0x13f9] 5113    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x13fa] 5114    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x13fc] 5116    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x13fd] 5117    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
[0x1400] 5120    0x22    LD (NN), HL     974d        ;  Load location 0x974d (19863) with the register pair HL
[0x1403] 5123    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
[0x1406] 5126    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1407] 5127    0xf5    PUSH AF                     ;  Load the stack with register pair AF
[0x1408] 5128    0xcc    CALL Z,NN       8620        ;  Call to 0x8620 (8326) if ZERO flag is 1
[0x140b] 5131    0xf1    POP AF                      ;  Load register pair AF with top of stack
[0x140c] 5132    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x140d] 5133    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
[0x1410] 5136    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1411] 5137    0xf5    PUSH AF                     ;  Load the stack with register pair AF
[0x1412] 5138    0xcc    CALL Z,NN       a920        ;  Call to 0xa920 (8361) if ZERO flag is 1
[0x1415] 5141    0xf1    POP AF                      ;  Load register pair AF with top of stack
[0x1416] 5142    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1417] 5143    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
[0x141a] 5146    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x141b] 5147    0xcc    CALL Z,NN       d120        ;  Call to 0xd120 (8401) if ZERO flag is 1
[0x141e] 5150    0xc9    RET                         ;  Return


;; ????
; if ( $4E72 & $4E09 == 0 ) {  return;  }
; B = $4E72 & $4E09;
; E = 8;  C = 8;  D =7;
; $4C13 = $4D00 + E;
; $4C12 = compliment($4D01) + D;
; $4C15 = $4D02 + E;
; $4C14 = compliment($4D03) + D;
; $4C17 = $4D04 + E;
; $4C16 = compliment($4D05) + C;
; $4C19 = $4D06 + E;
; $4C18 = compliment($4D07) + C;
; $4C1B = $4D08 + E;
; $4C1A = compliment($4D09) + C;
; $4C1D = $4DD2 + E;
; $4C1C = compliment($4DD3) + C;
; jump_5374();
[0x141f] 5151    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
[0x1422] 5154    0x47    LD B, A                     ;  Load register B with Accumulator
[0x1423] 5155    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x1426] 5158    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
[0x1427] 5159    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1428] 5160    0x47    LD B, A                     ;  Load register B with Accumulator
[0x1429] 5161    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
[0x142d] 5165    0x1e    LD E,N          08          ;  Load register E with 0x08 (8)
[0x142f] 5167    0x0e    LD  C, N        08          ;  Load register C with 0x08 (8)
[0x1431] 5169    0x16    LD  D, N        07          ;  Load register D with 0x07 (7)
[0x1433] 5171    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
[0x1436] 5174    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x1437] 5175    0xdd    LD (IX+d), A    13          ;  Load location ( IX + 0x13 () ) with Accumulator
[0x143a] 5178    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x143d] 5181    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x143e] 5182    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
[0x143f] 5183    0xdd    LD (IX+d), A    12          ;  Load location ( IX + 0x12 () ) with Accumulator
[0x1442] 5186    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
[0x1445] 5189    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x1446] 5190    0xdd    LD (IX+d), A    15          ;  Load location ( IX + 0x15 () ) with Accumulator
[0x1449] 5193    0x3a    LD A, (NN)      034d        ;  Load Accumulator with location 0x034d (19715)
[0x144c] 5196    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x144d] 5197    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
[0x144e] 5198    0xdd    LD (IX+d), A    14          ;  Load location ( IX + 0x14 () ) with Accumulator
[0x1451] 5201    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
[0x1454] 5204    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x1455] 5205    0xdd    LD (IX+d), A    17          ;  Load location ( IX + 0x17 () ) with Accumulator
[0x1458] 5208    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
[0x145b] 5211    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x145c] 5212    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x145d] 5213    0xdd    LD (IX+d), A    16          ;  Load location ( IX + 0x16 () ) with Accumulator
[0x1460] 5216    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
[0x1463] 5219    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x1464] 5220    0xdd    LD (IX+d), A    19          ;  Load location ( IX + 0x19 () ) with Accumulator
[0x1467] 5223    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
[0x146a] 5226    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x146b] 5227    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x146c] 5228    0xdd    LD (IX+d), A    18          ;  Load location ( IX + 0x18 () ) with Accumulator
[0x146f] 5231    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
[0x1472] 5234    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x1473] 5235    0xdd    LD (IX+d), A    1b          ;  Load location ( IX + 0x1b () ) with Accumulator
[0x1476] 5238    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
[0x1479] 5241    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x147a] 5242    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x147b] 5243    0xdd    LD (IX+d), A    1a          ;  Load location ( IX + 0x1a () ) with Accumulator
[0x147e] 5246    0x3a    LD A, (NN)      d24d        ;  Load Accumulator with location 0xd24d (19922)
[0x1481] 5249    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x1482] 5250    0xdd    LD (IX+d), A    1d          ;  Load location ( IX + 0x1d () ) with Accumulator
[0x1485] 5253    0x3a    LD A, (NN)      d34d        ;  Load Accumulator with location 0xd34d (19923)
[0x1488] 5256    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x1489] 5257    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x148a] 5258    0xdd    LD (IX+d), A    1c          ;  Load location ( IX + 0x1c () ) with Accumulator
[0x148d] 5261    0xc3    JP NN           fe14        ;  Jump to 0xfe14 (5374)


;; ????
; if ( $4E72 & $4E09 != 0 ) {  return;  }
; B = $4E72 & $4E09;
; E = 9;  C = 7;  D = 6;
; $4C13 = compliment($4D00) + E;
; $4C12 = $4D01 + D;
; $4C15 = compliment($4D02) + E;
; $4C14 = $4D03 + D;
; $4C17 = compliment($4D04) + E;
; $4C16 = $4D05 + C;
; $4C19 = compliment($4D06) + E;
; $4C18 = $4D07 + C;
; $4C1B = compliment($4D08) + E;
; $4C1A = $4D09 + C;
; $4C1D = compliment($4DD2) + E;
; $4C1C = $4DD3 + C;
; fallthrough_to_5374();
[0x1490] 5264    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
[0x1493] 5267    0x47    LD B, A                     ;  Load register B with Accumulator
[0x1494] 5268    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x1497] 5271    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
[0x1498] 5272    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1499] 5273    0x47    LD B, A                     ;  Load register B with Accumulator
[0x149a] 5274    0x1e    LD E,N          09          ;  Load register E with 0x09 (9)
[0x149c] 5276    0x0e    LD  C, N        07          ;  Load register C with 0x07 (7)
[0x149e] 5278    0x16    LD  D, N        06          ;  Load register D with 0x06 (6)
[0x14a0] 5280    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
[0x14a4] 5284    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
[0x14a7] 5287    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x14a8] 5288    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x14a9] 5289    0xdd    LD (IX+d), A    13          ;  Load location ( IX + 0x13 () ) with Accumulator
[0x14ac] 5292    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x14af] 5295    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
[0x14b0] 5296    0xdd    LD (IX+d), A    12          ;  Load location ( IX + 0x12 () ) with Accumulator
[0x14b3] 5299    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
[0x14b6] 5302    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x14b7] 5303    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x14b8] 5304    0xdd    LD (IX+d), A    15          ;  Load location ( IX + 0x15 () ) with Accumulator
[0x14bb] 5307    0x3a    LD A, (NN)      034d        ;  Load Accumulator with location 0x034d (19715)
[0x14be] 5310    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
[0x14bf] 5311    0xdd    LD (IX+d), A    14          ;  Load location ( IX + 0x14 () ) with Accumulator
[0x14c2] 5314    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
[0x14c5] 5317    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x14c6] 5318    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x14c7] 5319    0xdd    LD (IX+d), A    17          ;  Load location ( IX + 0x17 () ) with Accumulator
[0x14ca] 5322    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
[0x14cd] 5325    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x14ce] 5326    0xdd    LD (IX+d), A    16          ;  Load location ( IX + 0x16 () ) with Accumulator
[0x14d1] 5329    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
[0x14d4] 5332    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x14d5] 5333    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x14d6] 5334    0xdd    LD (IX+d), A    19          ;  Load location ( IX + 0x19 () ) with Accumulator
[0x14d9] 5337    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
[0x14dc] 5340    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x14dd] 5341    0xdd    LD (IX+d), A    18          ;  Load location ( IX + 0x18 () ) with Accumulator
[0x14e0] 5344    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
[0x14e3] 5347    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x14e4] 5348    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x14e5] 5349    0xdd    LD (IX+d), A    1b          ;  Load location ( IX + 0x1b () ) with Accumulator
[0x14e8] 5352    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
[0x14eb] 5355    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x14ec] 5356    0xdd    LD (IX+d), A    1a          ;  Load location ( IX + 0x1a () ) with Accumulator
[0x14ef] 5359    0x3a    LD A, (NN)      d24d        ;  Load Accumulator with location 0xd24d (19922)
[0x14f2] 5362    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x14f3] 5363    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x14f4] 5364    0xdd    LD (IX+d), A    1d          ;  Load location ( IX + 0x1d () ) with Accumulator
[0x14f7] 5367    0x3a    LD A, (NN)      d34d        ;  Load Accumulator with location 0xd34d (19923)
[0x14fa] 5370    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x14fb] 5371    0xdd    LD (IX+d), A    1c          ;  Load location ( IX + 0x1c () ) with Accumulator

; if ( $4DA5 != 0 ) {  jump_5451();  }
; if ( $4DA4 != 0 ) {  jump_5556();  }
; push(5404);
; A = $4D03;  //  $4E03 == Mode:  00 - Attract Screen + Gameplay, 01 - Push Start Button, 03 - Game Start (Ready!)
; rst20();
[0x14fe] 5374    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
[0x1501] 5377    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1502] 5378    0xc2    JP NZ, NN       4b15        ;  Jump to 0x4b15 (5451) if ZERO flag is 0
[0x1505] 5381    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
[0x1508] 5384    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1509] 5385    0xc2    JP NZ, NN       b415        ;  Jump to 0xb415 (5556) if ZERO flag is 0
[0x150c] 5388    0x21    LD HL, NN       1c15        ;  Load register pair HL with 0x1c15 (5404)
[0x150f] 5391    0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x1510] 5392    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
[0x1513] 5395    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; Table for RST20 @ 5396
; 00 : 0x168C - 5772
; 01 : 0x16B1 - 5809
; 02 : 0x16D6 - 5846
; 03 : 0x16F7 - 5879


; if ( B != 0 )
; {
;     if ( $4C0A & 0xC0 == 0 ||
;          ( $4D30 == 2 && $4C0A & 0x80 ) ||
;          ( $4D30 == 3 && $4C0A & 0x40 ) )
;     {  $4C0A |= 0xC0;  }
; }
[0x151c] 5404    0x78    LD A, B                     ;  Load Accumulator with register B
[0x151d] 5405    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x151e] 5406    0x28    JR Z, N         2b          ;  Jump relative 0x2b (43) if ZERO flag is 1
[0x1520] 5408    0x0e    LD  C, N        c0          ;  Load register C with 0xc0 (192)
[0x1522] 5410    0x3a    LD A, (NN)      0a4c        ;  Load Accumulator with location 0x0a4c (19466)
[0x1525] 5413    0x57    LD D, A                     ;  Load register D with Accumulator
[0x1526] 5414    0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
[0x1527] 5415    0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
[0x1529] 5417    0x7a    LD A, D                     ;  Load Accumulator with register D
[0x152a] 5418    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x152b] 5419    0xc3    JP NN           4815        ;  Jump to 0x4815 (5448)
[0x152e] 5422    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
[0x1531] 5425    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
[0x1533] 5427    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x1535] 5429    0xcb    BIT 7,D                     ;  Test bit 7 of register D
[0x1537] 5431    0x28    JR Z, N         12          ;  Jump relative 0x12 (18) if ZERO flag is 1
[0x1539] 5433    0x7a    LD A, D                     ;  Load Accumulator with register D
[0x153a] 5434    0xa9    XOR A, C                    ;  Bitwise XOR of register C to Accumulator
[0x153b] 5435    0xc3    JP NN           4815        ;  Jump to 0x4815 (5448)
[0x153e] 5438    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x1540] 5440    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x1542] 5442    0xcb    BIT 6,D                     ;  Test bit 6 of register D
[0x1544] 5444    0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0x1546] 5446    0x7a    LD A, D                     ;  Load Accumulator with register D
[0x1547] 5447    0xa9    XOR A, C                    ;  Bitwise XOR of register C to Accumulator
[0x1548] 5448    0x32    LD (NN), A      0a4c        ;  Load location 0x0a4c (19466) with the Accumulator
; $4C02 = $4C04 = $4C06 = $4C08 = $4DC0 + 28;
[0x154b] 5451    0x21    LD HL, NN       c04d        ;  Load register pair HL with 0xc04d (19904)
[0x154e] 5454    0x56    LD D, (HL)                  ;  Load register D with location (HL)
[0x154f] 5455    0x3e    LD A,N          1c          ;  Load Accumulator with 0x1c (28)
[0x1551] 5457    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
[0x1552] 5458    0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
[0x1555] 5461    0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
[0x1558] 5464    0xdd    LD (IX+d), A    06          ;  Load location ( IX + 0x06 () ) with Accumulator
[0x155b] 5467    0xdd    LD (IX+d), A    08          ;  Load location ( IX + 0x08 () ) with Accumulator
; C = 32;
; if ( $4DAC != 0 || $4DA7 == 0 ) {  $4C02 = ( $4D2C * 2 ) + C + D;  }  // D == $4DC0
; if ( $4DAD != 0 || $4DA8 == 0 ) {  $4C04 = ( $4D2D * 2 ) + D + C;  }
; if ( $4DAE != 0 || $4DA9 == 0 ) {  $4C06 = ( $4D2E * 2 ) + D + C;  }
; if ( $4DAF != 0 || $4DAA == 0 ) {  $4C08 = ( $4D2F * 2 ) + D + C;  }
[0x155e] 5470    0x0e    LD  C, N        20          ;  Load register C with 0x20 (32)
[0x1560] 5472    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
[0x1563] 5475    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1564] 5476    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
[0x1566] 5478    0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
[0x1569] 5481    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x156a] 5482    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x156c] 5484    0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
[0x156f] 5487    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x1570] 5488    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
[0x1571] 5489    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x1572] 5490    0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
[0x1575] 5493    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
[0x1578] 5496    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1579] 5497    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
[0x157b] 5499    0x3a    LD A, (NN)      a84d        ;  Load Accumulator with location 0xa84d (19880)
[0x157e] 5502    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x157f] 5503    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x1581] 5505    0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
[0x1584] 5508    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x1585] 5509    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
[0x1586] 5510    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x1587] 5511    0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
[0x158a] 5514    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
[0x158d] 5517    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x158e] 5518    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
[0x1590] 5520    0x3a    LD A, (NN)      a94d        ;  Load Accumulator with location 0xa94d (19881)
[0x1593] 5523    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1594] 5524    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x1596] 5526    0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
[0x1599] 5529    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x159a] 5530    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
[0x159b] 5531    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x159c] 5532    0xdd    LD (IX+d), A    06          ;  Load location ( IX + 0x06 () ) with Accumulator
[0x159f] 5535    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
[0x15a2] 5538    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x15a3] 5539    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
[0x15a5] 5541    0x3a    LD A, (NN)      aa4d        ;  Load Accumulator with location 0xaa4d (19882)
[0x15a8] 5544    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x15a9] 5545    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x15ab] 5547    0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
[0x15ae] 5550    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x15af] 5551    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
[0x15b0] 5552    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x15b1] 5553    0xdd    LD (IX+d), A    08          ;  Load location ( IX + 0x08 () ) with Accumulator
; call_5606();
; call_5677();
; call_5714();
[0x15b4] 5556    0xcd    CALL NN         e615        ;  Call to 0xe615 (5606)
[0x15b7] 5559    0xcd    CALL NN         2d16        ;  Call to 0x2d16 (5677)
[0x15ba] 5562    0xcd    CALL NN         5216        ;  Call to 0x5216 (5714)
[0x15bd] 5565    0x78    LD A, B                     ;  Load Accumulator with register B
[0x15be] 5566    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x15bf] 5567    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x15c0] 5568    0x0e    LD  C, N        c0          ;  Load register C with 0xc0 (192)
[0x15c2] 5570    0x3a    LD A, (NN)      024c        ;  Load Accumulator with location 0x024c (19458)
[0x15c5] 5573    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x15c6] 5574    0x32    LD (NN), A      024c        ;  Load location 0x024c (19458) with the Accumulator
[0x15c9] 5577    0x3a    LD A, (NN)      044c        ;  Load Accumulator with location 0x044c (19460)
[0x15cc] 5580    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x15cd] 5581    0x32    LD (NN), A      044c        ;  Load location 0x044c (19460) with the Accumulator
[0x15d0] 5584    0x3a    LD A, (NN)      064c        ;  Load Accumulator with location 0x064c (19462)
[0x15d3] 5587    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x15d4] 5588    0x32    LD (NN), A      064c        ;  Load location 0x064c (19462) with the Accumulator
[0x15d7] 5591    0x3a    LD A, (NN)      084c        ;  Load Accumulator with location 0x084c (19464)
[0x15da] 5594    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x15db] 5595    0x32    LD (NN), A      084c        ;  Load location 0x084c (19464) with the Accumulator
[0x15de] 5598    0x3a    LD A, (NN)      0c4c        ;  Load Accumulator with location 0x0c4c (19468)
[0x15e1] 5601    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x15e2] 5602    0x32    LD (NN), A      0c4c        ;  Load location 0x0c4c (19468) with the Accumulator
[0x15e5] 5605    0xc9    RET                         ;  Return


;; Act I - $4E07 determines which scene
; if ( $4E06 < 5 ) {  return;  }  // Act I Scenes
[0x15e6] 5606    0x3a    LD A, (NN)      064e        ;  Load Accumulator with location 0x064e (19974)
[0x15e9] 5609    0xd6    SUB N           05          ;  Subtract 0x05 (5) from Accumulator (no carry)
[0x15eb] 5611    0xd8    RET C                       ;  Return if CARRY flag is 1
; A = $4D09 & 0x0F;
; if ( A >= 12 ) {  D = 0x18;  }
; else if ( A >= 8 )  {  D = 0x14;  }
; else if ( A >= 4 )  {  D = 0x14;  }
;               else  {  D = 0x10;  }
; $4C04 = D;  D++;
; $4C06 = D;  D++;
; $4C08 = D;  D++;
; $4C0C = D;  D++;
; $4C0A = 0x3F;
; $4C05 = $4C07 = $4C09 = $4C0D = 0x16;
; return;
[0x15ec] 5612    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
[0x15ef] 5615    0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x15f1] 5617    0xfe    CP N            0c          ;  Compare 0x0c (12) with Accumulator
[0x15f3] 5619    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
[0x15f5] 5621    0x16    LD  D, N        18          ;  Load register D with 0x18 (24)
[0x15f7] 5623    0x18    JR N            12          ;  Jump relative 0x12 (18)
[0x15f9] 5625    0xfe    CP N            08          ;  Compare 0x08 (8) with Accumulator
[0x15fb] 5627    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
[0x15fd] 5629    0x16    LD  D, N        14          ;  Load register D with 0x14 (20)
[0x15ff] 5631    0x18    JR N            0a          ;  Jump relative 0x0a (10)
[0x1601] 5633    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1603] 5635    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
[0x1605] 5637    0x16    LD  D, N        10          ;  Load register D with 0x10 (16)
[0x1607] 5639    0x18    JR N            02          ;  Jump relative 0x02 (2)
[0x1609] 5641    0x16    LD  D, N        14          ;  Load register D with 0x14 (20)
[0x160b] 5643    0xdd    LD (IX+d), D    04          ;  Load location ( IX + 0x04 () ) with register D
[0x160e] 5646    0x14    INC D                       ;  Increment register D
[0x160f] 5647    0xdd    LD (IX+d), D    06          ;  Load location ( IX + 0x06 () ) with register D
[0x1612] 5650    0x14    INC D                       ;  Increment register D
[0x1613] 5651    0xdd    LD (IX+d), D    08          ;  Load location ( IX + 0x08 () ) with register D
[0x1616] 5654    0x14    INC D                       ;  Increment register D
[0x1617] 5655    0xdd    LD (IX+d), D    0c          ;  Load location ( IX + 0x0c () ) with register D
[0x161a] 5658    0xdd    LOAD (IX + N),  3f          ;  Load location ( IX + 0x0a () ) with 0x3f ()
[0x161e] 5662    0x16    LD  D, N        16          ;  Load register D with 0x16 (22)
[0x1620] 5664    0xdd    LD (IX+d), D    05          ;  Load location ( IX + 0x05 () ) with register D
[0x1623] 5667    0xdd    LD (IX+d), D    07          ;  Load location ( IX + 0x07 () ) with register D
[0x1626] 5670    0xdd    LD (IX+d), D    09          ;  Load location ( IX + 0x09 () ) with register D
[0x1629] 5673    0xdd    LD (IX+d), D    0d          ;  Load location ( IX + 0x0d () ) with register D
[0x162c] 5676    0xc9    RET                         ;  Return


;; Act II - $4E07 determines which scene
; A = ($4E07)
; if ( A != 0 )
; {
;     D = A;
;     A = $4D3A;
;     if ( A <= 61 )
;         IX+0x0B = 0x00;
;     if ( D >= 10 )
;     {
;         IX+0x02 = 0x32;
;         IX+0x03 = 0x1D;
;         if ( D >= 12 )
;         {
;             IX+0x02 = 0x33;
;         }
;     }
; }
[0x162d] 5677    0x3a    LD A, (NN)      074e        ;  Load Accumulator with location 0x074e (19975)
[0x1630] 5680    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1631] 5681    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1632] 5682    0x57    LD D, A                     ;  Load register D with Accumulator
[0x1633] 5683    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
[0x1636] 5686    0xd6    SUB N           3d          ;  Subtract 0x3d (61) from Accumulator (no carry)
[0x1638] 5688    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
[0x163a] 5690    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0b () ) with 0x00 ()
[0x163e] 5694    0x7a    LD A, D                     ;  Load Accumulator with register D
[0x163f] 5695    0xfe    CP N            0a          ;  Compare 0x0a (10) with Accumulator
[0x1641] 5697    0xd8    RET C                       ;  Return if CARRY flag is 1
[0x1642] 5698    0xdd    LOAD (IX + N),  32          ;  Load location ( IX + 0x02 () ) with 0x32 ()
[0x1646] 5702    0xdd    LOAD (IX + N),  1d          ;  Load location ( IX + 0x03 () ) with 0x1d ()
[0x164a] 5706    0xfe    CP N            0c          ;  Compare 0x0c (12) with Accumulator
[0x164c] 5708    0xd8    RET C                       ;  Return if CARRY flag is 1
[0x164d] 5709    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x33 ()
[0x1651] 5713    0xc9    RET                         ;  Return


;; Act III - $4E08 determines which scene
; if ( $4E08 == 0 ) {  return;  }
; if ( $4D3A != 0x3D ) {  $4C0B == 0x00;  }
; if ( $4E08 < 1 )  {  return;  }  // HUH?  How could this ever evaluate?
; $4C02 = $4DC0 + 8;
; if ( $4E08 < 3 )  {  return;  }
[0x1652] 5714    0x3a    LD A, (NN)      084e        ;  Load Accumulator with location 0x084e (19976)
[0x1655] 5717    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1656] 5718    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1657] 5719    0x57    LD D, A                     ;  Load register D with Accumulator
[0x1658] 5720    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
[0x165b] 5723    0xd6    SUB N           3d          ;  Subtract 0x3d (61) from Accumulator (no carry)
[0x165d] 5725    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
[0x165f] 5727    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0b () ) with 0x00 ()
[0x1663] 5731    0x7a    LD A, D                     ;  Load Accumulator with register D
[0x1664] 5732    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x1666] 5734    0xd8    RET C                       ;  Return if CARRY flag is 1
[0x1667] 5735    0x3a    LD A, (NN)      c04d        ;  Load Accumulator with location 0xc04d (19904)
[0x166a] 5738    0x1e    LD E,N          08          ;  Load register E with 0x08 (8)
[0x166c] 5740    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x166d] 5741    0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
[0x1670] 5744    0x7a    LD A, D                     ;  Load Accumulator with register D
[0x1671] 5745    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x1673] 5747    0xd8    RET C                       ;  Return if CARRY flag is 1
; A = $4D01 & 0x08;
; A <<cir 3;
; A += 10;
; $4C0C = A;
; A += 2;
; $4C02 = A;
; $4C0D = 0x1E;
[0x1674] 5748    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x1677] 5751    0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
[0x1679] 5753    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x167a] 5754    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x167b] 5755    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x167c] 5756    0x1e    LD E,N          0a          ;  Load register E with 0x0a (10)
[0x167e] 5758    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
[0x167f] 5759    0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
[0x1682] 5762    0x3c    INC A                       ;  Increment Accumulator
[0x1683] 5763    0x3c    INC A                       ;  Increment Accumulator
[0x1684] 5764    0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
[0x1687] 5767    0xdd    LOAD (IX + N),  1e          ;  Load location ( IX + 0x0d () ) with 0x1e ()
;; 5768-5775 : On Ms. Pac-Man patched in from $8088-$808F
[0x168b] 5771    0xc9    RET                         ;  Return


;;; attract_screen_and_demo() ??
;; switch ( $4D09 & 0x07 )
;; {
;;     case 7, 6 : $(IX + 10) = 0x2F;  return;
;;     case 5, 4 : $(IX + 10) = 0x2D;  return;
;;     case 3, 2 : $(IX + 10) = 0x2F;  return;
;;     case 1, 0 : $(IX + 10) = 0x30;  return;
;; }
;
; if ( $4D09 & 0x07 >= 6 ) {  $(IX + 10) = 0x2F;  return;  }
; if ( $4D09 & 0x07 >= 4 ) {  $(IX + 10) = 0x2D;  return;  }
; if ( $4D09 & 0x07 >= 2 ) {  $(IX + 10) = 0x2F;  return;  }
;                     else {  $(IX + 10) = 0x30;  return;  } 

;; 5768-5775 : On Ms. Pac-Man patched in from $8088-$808F
;; On Ms. Pac-Man:
;; 5772  $168c   0xc3    JP nn           9c86        ;  Jump to $nn
[0x168c] 5772    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
[0x168f] 5775    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1691] 5777    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
[0x1693] 5779    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
[0x1695] 5781    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x30 ()
[0x1699] 5785    0xc9    RET                         ;  Return
[0x169a] 5786    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x169c] 5788    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
[0x169e] 5790    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x2e ()
[0x16a2] 5794    0xc9    RET                         ;  Return
[0x16a3] 5795    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
[0x16a5] 5797    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
[0x16a7] 5799    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x2c ()
[0x16ab] 5803    0xc9    RET                         ;  Return
[0x16ac] 5804    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x2e ()
[0x16b0] 5808    0xc9    RET                         ;  Return


;; switch ( $4D08 & 0x07 )
;; {
;;     case 7, 6 : $(IX + 10) = 0x2F;  return;
;;     case 5, 4 : $(IX + 10) = 0x2D;  return;
;;     case 3, 2 : $(IX + 10) = 0x2F;  return;
;;     case 1, 0 : $(IX + 10) = 0x30;  return;
;; }
;
; if ( $4D08 & 0x07 >= 6 ) {  $(IX + 10) = 0x2F;  return;  }
; if ( $4D08 & 0x07 >= 4 ) {  $(IX + 10) = 0x2D;  return;  }
; if ( $4D08 & 0x07 >= 2 ) {  $(IX + 10) = 0x2F;  return;  }
;                     else {  $(IX + 10) = 0x30;  return;  } 

;; 5808-5815 : On Ms. Pac-Man patched in from $8188-$818F
;; On Ms. Pac-Man:
;; 5809  $16b1   0xc3    JP nn           b186        ;  Jump to $nn
;; 5812  $16b4   0xc9    RET                         ;  Return
[0x16b1] 5809    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
[0x16b4] 5812    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x16b6] 5814    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
[0x16b8] 5816    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
[0x16ba] 5818    0xdd    LD (IX+d), n    0a2f        ;  Load location ( IX + 0x0a () ) with 0x2f ()
[0x16be] 5822    0xc9    RET                         ;  Return
[0x16bf] 5823    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x16c1] 5825    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
[0x16c3] 5827    0xdd    LD (IX+d), n    0a2d        ;  Load location ( IX + 0x0a () ) with 0x2d ()
[0x16c7] 5831    0xc9    RET                         ;  Return
[0x16c8] 5832    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
[0x16ca] 5834    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
[0x16cc] 5836    0xdd    LD (IX+d), n    0a2f        ;  Load location ( IX + 0x0a () ) with 0x2f ()
[0x16d0] 5840    0xc9    RET                         ;  Return
[0x16d1] 5841    0xdd    LD (IX+d), n    0a30        ;  Load location ( IX + 0x0a () ) with 0x30 ()
[0x16d5] 5845    0xc9    RET                         ;  Return


;; switch ( $4D09 & 0x07 )
;; {
;;     case 7, 6 : $(IX + 10) = 0xAE;  return;
;;     case 5, 4 : $(IX + 10) = 0xAC;  return;
;;     case 3, 2 : $(IX + 10) = 0xB0;  return;
;;     case 1, 0 : $(IX + 10) = 0xAE;  return;
;; }
;
; // Strange use of CBFB opcode here.  Why not just put all values in the loads?
; if ( $4D09 & 0x07 >= 6 ) {  $(IX + 10) = 0xAE;  return;  }  // 0x2e | 0x80
; if ( $4D09 & 0x07 >= 4 ) {  $(IX + 10) = 0xAC;  return;  }  // 0x2c | 0x80
; if ( $4D09 & 0x07 >= 2 ) {  $(IX + 10) = 0xB0;  return;  }  // 0x30 | 0x80
;                     else {  $(IX + 10) = 0xAE;  return;  }  // 0x2e | 0x80
[0x16d6] 5846    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
[0x16d9] 5849    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x16db] 5851    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
[0x16dd] 5853    0x38    JR C, N         08          ;  Jump to 8 (8) if CARRY flag is 1
[0x16df] 5855    0x1e    LD E,N          2e          ;  Load register E with 0x2e (46)
[0x16e1] 5857    0xcb    SET 7,E                     ;  Set bit 7 of register E
[0x16e3] 5859    0xdd    LD (IX+d), E    0a          ;  Load location ( IX + 0x0a () ) with register E
[0x16e6] 5862    0xc9    RET                         ;  Return
[0x16e7] 5863    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x16e9] 5865    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
[0x16eb] 5867    0x1e    LD E,N          2c          ;  Load register E with 0x2c (44)
[0x16ed] 5869    0x18    JR N            f2          ;  Jump relative 0xf2 (-14)
[0x16ef] 5871    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
[0x16f1] 5873    0x30    JR NC, N        ec          ;  Jump relative 0xec (-20) if CARRY flag is 1
[0x16f3] 5875    0x1e    LD E,N          30          ;  Load register E with 0x30 (48)
[0x16f5] 5877    0x18    JR N            ea          ;  Jump relative 0xea (-22)


;; switch ( $4D08 & 0x07 )
;; {
;;     case 7, 6 : 
;;     case 5, 4 : 
;;     case 3, 2 :
;;     case 1, 0 : 
;; }
;
; // Strange use of CBFB opcode here.  Why not just put all values in the loads?
; if ( $4D09 & 0x07 >= 6 ) {  $(IX + 10) = 0x30;  return;  }
; if ( $4D09 & 0x07 >= 4 ) {  $(IX + 10) = 0x6F;  return;  }
; if ( $4D09 & 0x07 >= 2 ) {  $(IX + 10) = 0x6D;  return;  }
;                     else {  $(IX + 10) = 0x2F;  return;  }

;; 5880-5887 : On Ms. Pac-Man patched in from $81C8-$81CF
[0x16f7] 5879    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
;; On Ms. Pac-Man:
;; 5882  $16fa   0xc3    JP nn           d986        ;  Jump to $nn
;; 5885  $16fd   0xc9    RET                         ;  Return
[0x16fa] 5882    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x16fc] 5884    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
[0x16fe] 5886    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
[0x1700] 5888    0xdd    LOAD (IX + N),  30          ;  Load location ( IX + 0x0a () ) with 0x30 ()
[0x1704] 5892    0xc9    RET                         ;  Return
[0x1705] 5893    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1707] 5895    0x38    JR C, N         08          ;  Jump to 0x08 (8) if CARRY flag is 1
[0x1709] 5897    0x1e    LD E,N          2f          ;  Load register E with 0x2f (47)
[0x170b] 5899    0xcb    SET 6,E                     ;  Set bit 6 of register E
[0x170d] 5901    0xdd    LD (IX+d), E    0a          ;  Load location ( IX + 0x0a () ) with register E
[0x1710] 5904    0xc9    RET                         ;  Return
[0x1711] 5905    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
[0x1713] 5907    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
[0x1715] 5909    0x1e    LD E,N          2d          ;  Load register E with 0x2d (45)
[0x1717] 5911    0x18    JR N            f2          ;  Jump relative 0xf2 (-14)
[0x1719] 5913    0x1e    LD E,N          2f          ;  Load register E with 0x2f (47)
[0x171b] 5915    0x18    JR N            ee          ;  Jump relative 0xee (-18)


;; eat_ghost_test() ??
; B = 4;
; DE = $4D39;
; A = $4DAF;
; if ( $4DAF == 0 ) {  HL = $4D37;  if ( HL -= DE == 0 ) {  jump_5987();  }  }  // WTF?!?
[0x171d] 5917    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
[0x171f] 5919    0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
[0x1723] 5923    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
[0x1726] 5926    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1727] 5927    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x1729] 5929    0x2a    LD HL, (NN)     374d        ;  Load register pair HL with location 0x374d (19767)
[0x172c] 5932    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x172d] 5933    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x172f] 5935    0xca    JP Z,           6317        ;  Jump to 0x6317 (5987) if ZERO flag is 1
; B--;
; if ( $4DAE == 0 ) {  HL = $4D35;  if ( HL -= DE == 0 ) {  jump_5987();  }  }
[0x1732] 5938    0x05    DEC B                       ;  Decrement register B
[0x1733] 5939    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
[0x1736] 5942    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1737] 5943    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x1739] 5945    0x2a    LD HL, (NN)     354d        ;  Load register pair HL with location 0x354d (19765)
[0x173c] 5948    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x173d] 5949    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x173f] 5951    0xca    JP Z,           6317        ;  Jump to 0x6317 (5987) if ZERO flag is 1
; B--;
; if ( $4DAD == 0 ) {  HL = $4D33;  if ( HL -= DE == 0 ) {  jump_5987();  }  }
[0x1742] 5954    0x05    DEC B                       ;  Decrement register B
[0x1743] 5955    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
[0x1746] 5958    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1747] 5959    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x1749] 5961    0x2a    LD HL, (NN)     334d        ;  Load register pair HL with location 0x334d (19763)
[0x174c] 5964    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x174d] 5965    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x174f] 5967    0xca    JP Z,           6317        ;  Jump to 0x6317 (5987) if ZERO flag is 1
; B--;
; if ( $4DAC == 0 ) {  HL = $4D31;  if ( HL -= DE == 0 ) {  jump_5987();  }  }
[0x1752] 5970    0x05    DEC B                       ;  Decrement register B
[0x1753] 5971    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
[0x1756] 5974    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1757] 5975    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
[0x1759] 5977    0x2a    LD HL, (NN)     314d        ;  Load register pair HL with location 0x314d (19761)
[0x175c] 5980    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x175d] 5981    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x175f] 5983    0xca    JP Z,           6317        ;  Jump to 0x6317 (5987) if ZERO flag is 1
; B--; // B == 0;
[0x1762] 5986    0x05    DEC B                       ;  Decrement register B
; $4DA4 = $4DA5 = B;
; if ( B == 0 ) {  return;  }
[0x1763] 5987    0x78    LD A, B                     ;  Load Accumulator with register B
[0x1764] 5988    0x32    LD (NN), A      a44d        ;  Load location 0xa44d (19876) with the Accumulator
[0x1767] 5991    0x32    LD (NN), A      a54d        ;  Load location 0xa54d (19877) with the Accumulator
[0x176a] 5994    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x176b] 5995    0xc8    RET Z                       ;  Return if ZERO flag is 1
; if ( $(4DA6 + B) == 0 ) {  return;  }  //  4DA7/8/9/A == 0 - R/P/B/O normal, 1 - R/P/B/O edible, running away
; $4DA5 = 0;
; $4DD0++;
; B = $4DD0;  B++;  //  B == 2, 3, 4, or 5
; call_10842();  // score(), B == score event - 10, 50, 200, 400, 800, 1600, 100, 300, 500, 700, 1000, 2000, 3000, 5000
; HL = 0x4EBC;   // pointer to ghost who just got eaten?
; $(HL) |= 0x08;
; return;
[0x176c] 5996    0x21    LD HL, NN       a64d        ;  Load register pair HL with 0xa64d (19878)
[0x176f] 5999    0x5f    LD E, A                     ;  Load register E with Accumulator
[0x1770] 6000    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x1772] 6002    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x1773] 6003    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1774] 6004    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1775] 6005    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1776] 6006    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1777] 6007    0x32    LD (NN), A      a54d        ;  Load location 0xa54d (19877) with the Accumulator
[0x177a] 6010    0x21    LD HL, NN       d04d        ;  Load register pair HL with 0xd04d (19920)
[0x177d] 6013    0x34    INC (HL)                    ;  Increment location (HL)
[0x177e] 6014    0x46    LD B, (HL)                  ;  Load register B with location (HL)
[0x177f] 6015    0x04    INC B                       ;  Increment register B
[0x1780] 6016    0xcd    CALL NN         5a2a        ;  Call to 0x5a2a (10842)
[0x1783] 6019    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
[0x1786] 6022    0xcb    SET 3,(HL)                  ;  Set bit 3 of location (HL)
[0x1788] 6024    0xc9    RET                         ;  Return

; if ( $4DA4 != 0 ) {  return;  }
; if ( $4DA6 == 0 ) {  return;  }
[0x1789] 6025    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
[0x178c] 6028    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x178d] 6029    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x178e] 6030    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
[0x1791] 6033    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1792] 6034    0xc8    RET Z                       ;  Return if ZERO flag is 1
; C = 4;  B = 4;  IX = 0x4D08;
; if ( $4DAF != 0 )
; {  if ( $4D06 - $4D08 < 4 && $4D07 - $4D09 < 4 ) {  call_5987();  }  }  // with B==4
; // 200702200238 - I'm pretty sure that 06/08 and 07/09 here are the sq of the XY distances from pac to ghost
; //                and that this routine determines if pac gets eaten.
[0x1793] 6035    0x0e    LD  C, N        04          ;  Load register C with 0x04 (4)
[0x1795] 6037    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
[0x1797] 6039    0xdd    LD IX, NN       084d        ;  Load register pair IX with 0x084d (19720)
[0x179b] 6043    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
[0x179e] 6046    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x179f] 6047    0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
[0x17a1] 6049    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
[0x17a4] 6052    0xdd    SUB A, (IX+d)   00          ;  Subtract location ( IX + 0x00 () ) from Accumulator
[0x17a7] 6055    0xb9    CP A, C                     ;  Compare register C with Accumulator
[0x17a8] 6056    0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
[0x17aa] 6058    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
[0x17ad] 6061    0xdd    SUB A, (IX+d)   01          ;  Subtract location ( IX + 0x01 () ) from Accumulator
[0x17b0] 6064    0xb9    CP A, C                     ;  Compare register C with Accumulator
[0x17b1] 6065    0xda    JP C, NN        6317        ;  Jump to 0x6317 (5987) if CARRY flag is 1
; B--;
; if ( $4DAE != 0 )
; {  if ( $4D04 - $4D08 < 4 && $4D05 - $4D09 < 4 ) {  call_5987();  }  }  // with B==3
[0x17b4] 6068    0x05    DEC B                       ;  Decrement register B
[0x17b5] 6069    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
[0x17b8] 6072    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x17b9] 6073    0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
[0x17bb] 6075    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
[0x17be] 6078    0xdd    SUB A, (IX+d)   00          ;  Subtract location ( IX + 0x00 () ) from Accumulator
[0x17c1] 6081    0xb9    CP A, C                     ;  Compare register C with Accumulator
[0x17c2] 6082    0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
[0x17c4] 6084    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
[0x17c7] 6087    0xdd    SUB A, (IX+d)   01          ;  Subtract location ( IX + 0x01 () ) from Accumulator
[0x17ca] 6090    0xb9    CP A, C                     ;  Compare register C with Accumulator
[0x17cb] 6091    0xda    JP C, NN        6317        ;  Jump to 0x6317 (5987) if CARRY flag is 1
; B--;
; if ( $4DAD != 0 )
; {  if ( $4D02 - $4D08 < 4 && $4D03 - $4D09 < 4 ) {  call_5987();  }  }  // with B==2
[0x17ce] 6094    0x05    DEC B                       ;  Decrement register B
[0x17cf] 6095    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
[0x17d2] 6098    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x17d3] 6099    0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
[0x17d5] 6101    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
[0x17d8] 6104    0xdd    SUB A, (IX+d)   00          ;  Subtract location ( IX + 0x00 () ) from Accumulator
[0x17db] 6107    0xb9    CP A, C                     ;  Compare register C with Accumulator
[0x17dc] 6108    0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
[0x17de] 6110    0x3a    LD A, (NN)      034d        ;  Load Accumulator with location 0x034d (19715)
[0x17e1] 6113    0xdd    SUB A, (IX+d)   01          ;  Subtract location ( IX + 0x01 () ) from Accumulator
[0x17e4] 6116    0xb9    CP A, C                     ;  Compare register C with Accumulator
[0x17e5] 6117    0xda    JP C, NN        6317        ;  Jump to 0x6317 (5987) if CARRY flag is 1
; B--;
; if ( $4DAC != 0 )
; {  if ( $4D00 - $4D08 < 4 && $4D01 - $4D09 < 4 ) {  call_5987();  }  }  // with B==1
[0x17e8] 6120    0x05    DEC B                       ;  Decrement register B
[0x17e9] 6121    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
[0x17ec] 6124    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x17ed] 6125    0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
[0x17ef] 6127    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
[0x17f2] 6130    0xdd    SUB A, (IX+d)   00          ;  Subtract location ( IX + 0x00 () ) from Accumulator
[0x17f5] 6133    0xb9    CP A, C                     ;  Compare register C with Accumulator
[0x17f6] 6134    0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
[0x17f8] 6136    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x17fb] 6139    0xdd    SUB A, (IX+d)   01          ;  Subtract location ( IX + 0x01 () ) from Accumulator
[0x17fe] 6142    0xb9    CP A, C                     ;  Compare register C with Accumulator
[0x17ff] 6143    0xda    JP C, NN        6317        ;  Jump to 0x6317 (5987) if CARRY flag is 1
; B--;
; call_5987();  // with B==0
[0x1802] 6146    0x05    DEC B                       ;  Decrement register B
[0x1803] 6147    0xc3    JP NN           6317        ;  Jump to 0x6317 (5987)


; if $4D9D != 0xFF, (HL)-- and return
; else
; {
;   A = $4DA6;  // 0 = normal, 1 = ghosts blue, running away
;   if ( A != 0 )
;   {
;     $4D4C += $4D4C;
;     $4D4A += $4D4A;
;     return if the last add didn't carry;
;     $4D4C++;
;   }
;   else
;   {
;     $4D48 += $4D48;
;     $4D46 += $4D46;
;     return if the last add didn't carry;
;     $4D48++;
;   }
[0x1806] 6150    0x21    LD HL, NN       9d4d        ;  Load register pair HL with 0x9d4d (19869)
[0x1809] 6153    0x3e    LD A,N          ff          ;  Load Accumulator with 0xff (255)
[0x180b] 6155    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x180c] 6156    0xca    JP Z,           1118        ;  Jump to 0x1118 (6161) if ZERO flag is 1
[0x180f] 6159    0x35    DEC (HL)                    ;  Decrement location (HL)
[0x1810] 6160    0xc9    RET                         ;  Return
[0x1811] 6161    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
[0x1814] 6164    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1815] 6165    0xca    JP Z,           2f18        ;  Jump to 0x2f18 (6191) if ZERO flag is 1
[0x1818] 6168    0x2a    LD HL, (NN)     4c4d        ;  Load register pair HL with location 0x4c4d (19788)
[0x181b] 6171    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x181c] 6172    0x22    LD (NN), HL     4c4d        ;  Load location 0x4c4d (19788) with the register pair HL
[0x181f] 6175    0x2a    LD HL, (NN)     4a4d        ;  Load register pair HL with location 0x4a4d (19786)
[0x1822] 6178    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1824] 6180    0x22    LD (NN), HL     4a4d        ;  Load location 0x4a4d (19786) with the register pair HL
[0x1827] 6183    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1828] 6184    0x21    LD HL, NN       4c4d        ;  Load register pair HL with 0x4c4d (19788)
[0x182b] 6187    0x34    INC (HL)                    ;  Increment location (HL)
[0x182c] 6188    0xc3    JP NN           4318        ;  Jump to 0x4318 (6211)
[0x182f] 6191    0x2a    LD HL, (NN)     484d        ;  Load register pair HL with location 0x484d (19784)
[0x1832] 6194    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1833] 6195    0x22    LD (NN), HL     484d        ;  Load location 0x484d (19784) with the register pair HL
[0x1836] 6198    0x2a    LD HL, (NN)     464d        ;  Load register pair HL with location 0x464d (19782)
[0x1839] 6201    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x183b] 6203    0x22    LD (NN), HL     464d        ;  Load location 0x464d (19782) with the register pair HL
[0x183e] 6206    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x183f] 6207    0x21    LD HL, NN       484d        ;  Load register pair HL with 0x484d (19784)
[0x1842] 6210    0x34    INC (HL)                    ;  Increment location (HL)

; $4D9E = $4E0E;  // current state of maze completion/ghost hunt vs. flee
; C = $4E72 & $4E09;  // upright vs. cocktail, player 1 vs player 2
; if ( $4D3A >= 33 && $4D3A < 59 ) {  jump_6315();  }  // if pacman.x is off_screen
; $4DBF = 1;
; if ( $4E00 == 1 ) {  jump_6681();  }
; if ( $4E04 >= 16 ) {  jump_6681();  }
; if ( C != 0 ) {  A=$5040;  }  // $5040 == IN1 (cockail, start 1/2, service, joystick 2)
;          else {  A=$5000;  }  // $5000 =- IN0 (coin 3/2/1, rack test, joystick 1)
; if ( ! A & 2 ) {  $4D30=2;  $4D1C = $3303;  jump_6480();  }  // if joystick_left ...
; if ( ! A & 4 ) {  $4D30=0;  $4D1C = $32FF;  jump_6480();  }  // if joystick_right ...
; jump_6480();
[0x1843] 6211    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
[0x1846] 6214    0x32    LD (NN), A      9e4d        ;  Load location 0x9e4d (19870) with the Accumulator
[0x1849] 6217    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
[0x184c] 6220    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x184d] 6221    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x1850] 6224    0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
[0x1851] 6225    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x1852] 6226    0x21    LD HL, NN       3a4d        ;  Load register pair HL with 0x3a4d (19770)
[0x1855] 6229    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1856] 6230    0x06    LD  B, N        21          ;  Load register B with 0x21 (33)
[0x1858] 6232    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x1859] 6233    0x38    JR C, N         09          ;  Jump to 0x09 (9) if CARRY flag is 1
[0x185b] 6235    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x185c] 6236    0x06    LD  B, N        3b          ;  Load register B with 0x3b (59)
[0x185e] 6238    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x185f] 6239    0x30    JR NC, N        03          ;  Jump relative 0x03 (3) if CARRY flag is 0
[0x1861] 6241    0xc3    JP NN           ab18        ;  Jump to 0xab18 (6315)
[0x1864] 6244    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x1866] 6246    0x32    LD (NN), A      bf4d        ;  Load location 0xbf4d (19903) with the Accumulator
[0x1869] 6249    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x186c] 6252    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x186e] 6254    0xca    JP Z,           191a        ;  Jump to 0x191a (6681) if ZERO flag is 1
[0x1871] 6257    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
[0x1874] 6260    0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
[0x1876] 6262    0xd2    JP NC, NN       191a        ;  Jump to 0x191a (6681) if CARRY flag is 0
[0x1879] 6265    0x79    LD A, C                     ;  Load Accumulator with register C
[0x187a] 6266    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x187b] 6267    0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
[0x187d] 6269    0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x1880] 6272    0xc3    JP NN           8618        ;  Jump to 0x8618 (6278)
[0x1883] 6275    0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
[0x1886] 6278    0xcb    BIT 1,A                     ;  Test bit 1 of Accumulator
[0x1888] 6280    0xc2    JP NZ, NN       9918        ;  Jump to 0x9918 (6297) if ZERO flag is 0
[0x188b] 6283    0x2a    LD HL, (NN)     0333        ;  Load register pair HL with location 0x0333 (13059)
[0x188e] 6286    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0x1890] 6288    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
[0x1893] 6291    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
[0x1896] 6294    0xc3    JP NN           5019        ;  Jump to 0x5019 (6480)
[0x1899] 6297    0xcb    BIT 2,A                     ;  Test bit 2 of Accumulator
[0x189b] 6299    0xc2    JP NZ, NN       5019        ;  Jump to 0x5019 (6480) if ZERO flag is 0
[0x189e] 6302    0x2a    LD HL, (NN)     ff32        ;  Load register pair HL with location 0xff32 (13055)
[0x18a1] 6305    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x18a2] 6306    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
[0x18a5] 6309    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
[0x18a8] 6312    0xc3    JP NN           5019        ;  Jump to 0x5019 (6480)


; if ( $4E00 == 1 ) {  jump_6681();  }
; if ( $4E04 >= 16 ) {  jump_6681();  }
; if ( C != 0 ) {  A = $5040;  }  // C = $4E72 & $4E09 : upright vs. cocktail & player 1 vs player 2
;          else {  A = $5000;  }
; if ( A & 0x02 )  jump_6857();  // 6857 : $4D26 = 0x00, 0x01;  B = 0;  $4DC3 = 2;  jump_6372();
; if ( A & 0x04 )  jump_6873();  // 6873 : $4D26 = 0x00, 0xFF;  B = 0;  $4DC3 = 0;  jump_6372();
; if ( A & 0x01 )  jump_6888();  // 6888 : $4D26 = 0xFF, 0x00;  B = 0;  $4DC3 = 3;  jump_6372();
; if ( A & 0x08 )  jump_6904();  // 6904 : $4D26 = 0x01, 0x00;  B = 0;  $4DC3 = 1;  jump_6372();
; $4D2C = $4D1C;  // double-byte
[0x18ab] 6315    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x18ae] 6318    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x18b0] 6320    0xca    JP Z,           191a        ;  Jump to 0x191a (6681) if ZERO flag is 1
[0x18b3] 6323    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
[0x18b6] 6326    0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
[0x18b8] 6328    0xd2    JP NC, NN       191a        ;  Jump to 0x191a (6681) if CARRY flag is 0
[0x18bb] 6331    0x79    LD A, C                     ;  Load Accumulator with register C
[0x18bc] 6332    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x18bd] 6333    0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
[0x18bf] 6335    0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x18c2] 6338    0xc3    JP NN           c818        ;  Jump to 0xc818 (6344)
[0x18c5] 6341    0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
[0x18c8] 6344    0xcb    BIT 1,A                     ;  Test bit 1 of Accumulator
[0x18ca] 6346    0xca    JP Z,           c91a        ;  Jump to 0xc91a (6857) if ZERO flag is 1
[0x18cd] 6349    0xcb    BIT 2,A                     ;  Test bit 2 of Accumulator
[0x18cf] 6351    0xca    JP Z,           d91a        ;  Jump to 0xd91a (6873) if ZERO flag is 1
[0x18d2] 6354    0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
[0x18d4] 6356    0xca    JP Z,           e81a        ;  Jump to 0xe81a (6888) if ZERO flag is 1
[0x18d7] 6359    0xcb    BIT 3,A                     ;  Test bit 3 of Accumulator
[0x18d9] 6361    0xca    JP Z,           f81a        ;  Jump to 0xf81a (6904) if ZERO flag is 1
[0x18dc] 6364    0x2a    LD HL, (NN)     1c4d        ;  Load register pair HL with location 0x1c4d (19740)
[0x18df] 6367    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL

; B = 1;
; get_playfield_byte(0x4D26, 0x4D39); // via 8207
; if ( ! A & 0xC0 )
; {
;     if ( --B == 0 )
;     {
;         if ( ! $4D30 & 0x80 )
;         {
;             if ( $4D09 & 0x07 == 4 ) {  return;  }
;             jump(6464);
;         }
;         else
;         {
;             if ( $4D08 & 0x07 == 4 ) {  return;  }
;             jump(6464);
;         }
;     }
;     else
;     {
;         get_playfield_byte(0x4D1C, 0x4D39); // via 8207
;         if ( ! $4D30 & 0x80 )
;         {
;             if ( $4D09 & 0x07 == 4 ) {  return;  }
;             jump(6480);
;         }
;         else
;         {
;             if ( $4D08 & 0x07 == 4 ) {  return;  }
;             jump(6480);
;         }
;     }
; }
;;; 6464:
; $4D1C = $4D26;  // double-byte copy
; if ( --B != 0 ) {  $4D3C = $4D30;  }
;;; 6480:
; HL = $4D1C + $4D08;  // via call_8192(0x4D1C, 0x4D08);
[0x18e2] 6370    0x06    LD  B, N        01          ;  Load register B with 0x01 (1)
[0x18e4] 6372    0xdd    LD IX, NN       264d        ;  Load register pair IX with 0x264d (19750)
[0x18e8] 6376    0xfd    LD IY, NN       394d        ;  Load register pair IY with 0x394d (19769)
[0x18ec] 6380    0xcd    CALL NN         0f20        ;  Call to 0x0f20 (8207)
[0x18ef] 6383    0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
[0x18f1] 6385    0xd6    SUB N           c0          ;  Subtract 0xc0 (192) from Accumulator (no carry)
[0x18f3] 6387    0x20    JR NZ, N        4b          ;  Jump relative 0x4b (75) if ZERO flag is 0
[0x18f5] 6389    0x05    DEC B                       ;  Decrement register B
[0x18f6] 6390    0xc2    JP NZ, NN       1619        ;  Jump to 0x1619 (6422) if ZERO flag is 0
[0x18f9] 6393    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
[0x18fc] 6396    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x18fd] 6397    0xda    JP C, NN        0b19        ;  Jump to 0x0b19 (6411) if CARRY flag is 1
[0x1900] 6400    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
[0x1903] 6403    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1905] 6405    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1907] 6407    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1908] 6408    0xc3    JP NN           4019        ;  Jump to 0x4019 (6464)
[0x190b] 6411    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
[0x190e] 6414    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1910] 6416    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1912] 6418    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1913] 6419    0xc3    JP NN           4019        ;  Jump to 0x4019 (6464)
[0x1916] 6422    0xdd    LD IX, NN       1c4d        ;  Load register pair IX with 0x1c4d (19740)
[0x191a] 6426    0xcd    CALL NN         0f20        ;  Call to 0x0f20 (8207)
[0x191d] 6429    0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
[0x191f] 6431    0xd6    SUB N           c0          ;  Subtract 0xc0 (192) from Accumulator (no carry)
[0x1921] 6433    0x20    JR NZ, N        2d          ;  Jump relative 0x2d (45) if ZERO flag is 0
[0x1923] 6435    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
[0x1926] 6438    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x1927] 6439    0xda    JP C, NN        3519        ;  Jump to 0x3519 (6453) if CARRY flag is 1
[0x192a] 6442    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
[0x192d] 6445    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x192f] 6447    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1931] 6449    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1932] 6450    0xc3    JP NN           5019        ;  Jump to 0x5019 (6480)
[0x1935] 6453    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
[0x1938] 6456    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x193a] 6458    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x193c] 6460    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x193d] 6461    0xc3    JP NN           5019        ;  Jump to 0x5019 (6480)
[0x1940] 6464    0x2a    LD HL, (NN)     264d        ;  Load register pair HL with location 0x264d (19750)
[0x1943] 6467    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
[0x1946] 6470    0x05    DEC B                       ;  Decrement register B
[0x1947] 6471    0xca    JP Z,           5019        ;  Jump to 0x5019 (6480) if ZERO flag is 1
[0x194a] 6474    0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
[0x194d] 6477    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
[0x1950] 6480    0xdd    LD IX, NN       1c4d        ;  Load register pair IX with 0x1c4d (19740)
[0x1954] 6484    0xfd    LD IY, NN       084d        ;  Load register pair IY with 0x084d (19720)
[0x1958] 6488    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)

; if ( ! $4D30 & 0x01 )
; {
;     switch ( L & 0x07 )
;     {
;         case 4  : break;
;         case <4 : L++;  break;
;         case >4 : L--;  break;
;     }
; }
; else
; {
;     switch ( H & 0x07 )
;     {
;         case 4  : break;
;         case <4 : H++;  break;
;         case >4 : H--;  break;
;     }
; }
[0x195b] 6491    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
[0x195e] 6494    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x195f] 6495    0xda    JP C, NN        7519        ;  Jump to 0x7519 (6517) if CARRY flag is 1
[0x1962] 6498    0x7d    LD A, L                     ;  Load Accumulator with register L
[0x1963] 6499    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1965] 6501    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1967] 6503    0xca    JP Z,           8519        ;  Jump to 0x8519 (6533) if ZERO flag is 1
[0x196a] 6506    0xda    JP C, NN        7119        ;  Jump to 0x7119 (6513) if CARRY flag is 1
[0x196d] 6509    0x2d    DEC L                       ;  Decrement register L
[0x196e] 6510    0xc3    JP NN           8519        ;  Jump to 0x8519 (6533)
[0x1971] 6513    0x2c    INC L                       ;  Increment register L
[0x1972] 6514    0xc3    JP NN           8519        ;  Jump to 0x8519 (6533)
[0x1975] 6517    0x7c    LD A, H                     ;  Load Accumulator with register H
[0x1976] 6518    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1978] 6520    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x197a] 6522    0xca    JP Z,           8519        ;  Jump to 0x8519 (6533) if ZERO flag is 1
[0x197d] 6525    0xda    JP C, NN        8419        ;  Jump to 0x8419 (6532) if CARRY flag is 1
[0x1980] 6528    0x25    DEC H                       ;  Decrement register H
[0x1981] 6529    0xc3    JP NN           8519        ;  Jump to 0x8519 (6533)
[0x1984] 6532    0x24    INC H                       ;  Increment register H
; $4D08 = HL;
; call_8216();
[0x1985] 6533    0x22    LD (NN), HL     084d        ;  Load location 0x084d (19720) with the register pair HL
[0x1988] 6536    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
; $4D39 = HL;
; A = $4DBF;
; $4DBF = 0;
; if ( A != 0 ) {  return;  }
; if ( $4DD2 == 0 || $4DD4 == 0 ) {  jump_6605();  }
;; A = $4DD4
; HL = 0x4D08;
; (HL) &= A;
; if ( HL -= 148 == 0 )  // actually DE, not hard-wired 148
; {
;     insert_msg(0x19, A);  // msg 0x19 == score event (call_10842(B);)
;     display(A+21);  // by way of insert_msg(0x1C, 0x15+A);
;     call_4100();
;     rst_30();  // DATA for RST 0x30 - 0x54, 0x05, 0x00
;     $4EBC |= 0x04;
; }
; $4D9D = 0xFF;
; HL = 0x4D39;
; HL = YX_to_playfieldaddr(HL);  // via 101
; A = $HL;
; if ( A != 16 && A != 20 ) {  return;  }
; $4E0E++;
; A &= 0x15;
; A << 1;
; $HL = 0x40
; insert_msg(0x19, A << 1);
; A++;
; if ( A != 0x01 ) {  A += A;  }
; $4D9D = A;
; call_6920();
; call_6762();
; HL = 0x4EBC;
; A = $4E0E;
; A <<cir 1;
; if ( __carry ) {  HL |= 0x01;  HL &= 0xFD;  return;  }
;           else {  HL &= 0xFE;  HL |= 0x02;  return;  }

[0x198b] 6539    0x22    LD (NN), HL     394d        ;  Load location 0x394d (19769) with the register pair HL
[0x198e] 6542    0xdd    LD IX, NN       bf4d        ;  Load register pair IX with 0xbf4d (19903)
[0x1992] 6546    0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
[0x1995] 6549    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x00 () ) with 0x00 ()
[0x1999] 6553    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x199a] 6554    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x199b] 6555    0x3a    LD A, (NN)      d24d        ;  Load Accumulator with location 0xd24d (19922)
[0x199e] 6558    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x199f] 6559    0x28    JR Z, N         2c          ;  Jump relative 0x2c (44) if ZERO flag is 1
[0x19a1] 6561    0x3a    LD A, (NN)      d44d        ;  Load Accumulator with location 0xd44d (19924)
[0x19a4] 6564    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x19a5] 6565    0x28    JR Z, N         26          ;  Jump relative 0x26 (38) if ZERO flag is 1
[0x19a7] 6567    0x2a    LD HL, (NN)     084d        ;  Load register pair HL with location 0x084d (19720)
;; 6568-6575 : On Ms. Pac-Man patched in from $80A8-$80AF
[0x19aa] 6570    0x11    LD  DE, NN      9480        ;  Load register pair DE with 0x9480 (148)
;; On Ms. Pac-Man:
;; 6573  $19ad   0xc3    JP nn           1888        ;  Jump to $nn
[0x19ad] 6573    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x19ae] 6574    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x19b0] 6576    0x20    JR NZ, N        1b          ;  Jump relative 0x1b (27) if ZERO flag is 0
[0x19b2] 6578    0x06    LD  B, N        19          ;  Load register B with 0x19 (25)
[0x19b4] 6580    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x19b5] 6581    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
[0x19b8] 6584    0x0e    LD  C, N        15          ;  Load register C with 0x15 (21)
[0x19ba] 6586    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x19bb] 6587    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x19bc] 6588    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
[0x19be] 6590    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
[0x19c1] 6593    0xcd    CALL NN         0410        ;  Call to 0x0410 (4100)
[0x19c4] 6596    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x05, 0x00
[0x19c8] 6600    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
[0x19cb] 6603    0xcb    SET 2,(HL)                  ;  Set bit 2 of location (HL)
[0x19cd] 6605    0x3e    LD A,N          ff          ;  Load Accumulator with 0xff (255)
[0x19cf] 6607    0x32    LD (NN), A      9d4d        ;  Load location 0x9d4d (19869) with the Accumulator
[0x19d2] 6610    0x2a    LD HL, (NN)     394d        ;  Load register pair HL with location 0x394d (19769)
; HL = YX_to_playfieldaddr(HL);  // via 101
[0x19d5] 6613    0xcd    CALL NN         6500        ;  Call to 0x6500 (101)
[0x19d8] 6616    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x19d9] 6617    0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
[0x19db] 6619    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
[0x19dd] 6621    0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
[0x19df] 6623    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x19e0] 6624    0xdd    LD IX, NN       0e4e        ;  Load register pair IX with 0x0e4e (19982)
[0x19e4] 6628    0xdd    INC (IX + N)    00          ;  Increment location IX + 0x00 ()
[0x19e7] 6631    0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x19e9] 6633    0xcb    SRL A                       ;  Shift Accumulator right logical
[0x19eb] 6635    0x06    LD  B, N        40          ;  Load register B with 0x40 (64)
[0x19ed] 6637    0x70    LD (HL), B                  ;  Load location (HL) with register B
[0x19ee] 6638    0x06    LD  B, N        19          ;  Load register B with 0x19 (25)
[0x19f0] 6640    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x19f1] 6641    0xcb    SRL C                       ;  Shift register C right logical
; insert_msg(0x19, A);
[0x19f3] 6643    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
[0x19f6] 6646    0x3c    INC A                       ;  Increment Accumulator
[0x19f7] 6647    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x19f9] 6649    0xca    JP Z,           fd19        ;  Jump to 0xfd19 (6653) if ZERO flag is 1
[0x19fc] 6652    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x19fd] 6653    0x32    LD (NN), A      9d4d        ;  Load location 0x9d4d (19869) with the Accumulator
[0x1a00] 6656    0xcd    CALL NN         081b        ;  Call to 0x081b (6920)
[0x1a03] 6659    0xcd    CALL NN         6a1a        ;  Call to 0x6a1a (6762)
[0x1a06] 6662    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
[0x1a09] 6665    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
[0x1a0c] 6668    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x1a0d] 6669    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
[0x1a0f] 6671    0xcb    SET 0,(HL)                  ;  Set bit 0 of location (HL)
[0x1a11] 6673    0xcb    RES 1,(HL)                  ;  Reset bit 1 of location (HL)
[0x1a13] 6675    0xc9    RET                         ;  Return
[0x1a14] 6676    0xcb    RES 0,(HL)                  ;  Reset bit 0 of location (HL)
[0x1a16] 6678    0xcb    SET 1,(HL)                  ;  Set bit 1 of location (HL)
[0x1a18] 6680    0xc9    RET                         ;  Return


; eat_powerpill() ?
; if ( $4D1C != 0 )
; {
;     if ( $4D08 & 0x07 != 4 ) {  jump(6748);  }  // more accurately: if ( $4D08 & 0x07 == 4 ) {  jump(6712);  } else {  jump(6748);  }
; }
; else
; {
;     if ( $4D09 & 0x07 != 4 ) {  jump(6748);  }
; }
; call_7888(5);  // tunnel_warp?()
; if ( CARRY ) {  rst_28(0x17, 0x00);  }
; $4D12 = $4D26 + $4D12;  // via call_8192(0x4D26, 0x4D12);
; $4D1C = $4D26;
; $4D30 = $4D3C;
;;; 6748:
; HL = $4D1C + $4D08;  // via call_8192(0x4D1C, 0x4D08);
; jump(6533);
[0x1a19] 6681    0x21    LD HL, NN       1c4d        ;  Load register pair HL with 0x1c4d (19740)
[0x1a1c] 6684    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1a1d] 6685    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1a1e] 6686    0xca    JP Z,           2e1a        ;  Jump to 0x2e1a (6702) if ZERO flag is 1
[0x1a21] 6689    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
[0x1a24] 6692    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1a26] 6694    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1a28] 6696    0xca    JP Z,           381a        ;  Jump to 0x381a (6712) if ZERO flag is 1
[0x1a2b] 6699    0xc3    JP NN           5c1a        ;  Jump to 0x5c1a (6748)
[0x1a2e] 6702    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
[0x1a31] 6705    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1a33] 6707    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1a35] 6709    0xc2    JP NZ, NN       5c1a        ;  Jump to 0x5c1a (6748) if ZERO flag is 0
[0x1a38] 6712    0x3e    LD A,N          05          ;  Load Accumulator with 0x05 (5)
[0x1a3a] 6714    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
[0x1a3d] 6717    0x38    JR C, N         03          ;  Jump to 0x03 (3) if CARRY flag is 1
[0x1a3f] 6719    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x17, 0x00
[0x1a42] 6722    0xdd    LD IX, NN       264d        ;  Load register pair IX with 0x264d (19750)
[0x1a46] 6726    0xfd    LD IY, NN       124d        ;  Load register pair IY with 0x124d (19730)
[0x1a4a] 6730    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1a4d] 6733    0x22    LD (NN), HL     124d        ;  Load location 0x124d (19730) with the register pair HL
[0x1a50] 6736    0x2a    LD HL, (NN)     264d        ;  Load register pair HL with location 0x264d (19750)
[0x1a53] 6739    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
[0x1a56] 6742    0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
[0x1a59] 6745    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
[0x1a5c] 6748    0xdd    LD IX, NN       1c4d        ;  Load register pair IX with 0x1c4d (19740)
[0x1a60] 6752    0xfd    LD IY, NN       084d        ;  Load register pair IY with 0x084d (19720)
[0x1a64] 6756    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1a67] 6759    0xc3    JP NN           8519        ;  Jump to 0x8519 (6533)


; if ( $4D9D != 6 ) {  return;  }
; $4DCB = $4DBD;  // double-byte copy
; $4DA6 = $4DA7 = $4DA8 = $4DA9 = $4DAA = 1;
; $4DB1 = $4DB2 = $4DB3 = $4DB4 = $4DB5 = 1;
; $4DC8 = $4DD0 = 0;
; $4C02 = $4C04 = $4C06 = $4C08 = 0x1C;
; $4C03 = $4C05 = $4C07 = $4C09 = 0x11;
; $4EAC |= 020;  $4EAC &= 0x7F;
; return;
[0x1a6a] 6762    0x3a    LD A, (NN)      9d4d        ;  Load Accumulator with location 0x9d4d (19869)
[0x1a6d] 6765    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
[0x1a6f] 6767    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1a70] 6768    0x2a    LD HL, (NN)     bd4d        ;  Load register pair HL with location 0xbd4d (19901)
[0x1a73] 6771    0x22    LD (NN), HL     cb4d        ;  Load location 0xcb4d (19915) with the register pair HL
[0x1a76] 6774    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x1a78] 6776    0x32    LD (NN), A      a64d        ;  Load location 0xa64d (19878) with the Accumulator
[0x1a7b] 6779    0x32    LD (NN), A      a74d        ;  Load location 0xa74d (19879) with the Accumulator
[0x1a7e] 6782    0x32    LD (NN), A      a84d        ;  Load location 0xa84d (19880) with the Accumulator
[0x1a81] 6785    0x32    LD (NN), A      a94d        ;  Load location 0xa94d (19881) with the Accumulator
[0x1a84] 6788    0x32    LD (NN), A      aa4d        ;  Load location 0xaa4d (19882) with the Accumulator
[0x1a87] 6791    0x32    LD (NN), A      b14d        ;  Load location 0xb14d (19889) with the Accumulator
[0x1a8a] 6794    0x32    LD (NN), A      b24d        ;  Load location 0xb24d (19890) with the Accumulator
[0x1a8d] 6797    0x32    LD (NN), A      b34d        ;  Load location 0xb34d (19891) with the Accumulator
[0x1a90] 6800    0x32    LD (NN), A      b44d        ;  Load location 0xb44d (19892) with the Accumulator
[0x1a93] 6803    0x32    LD (NN), A      b54d        ;  Load location 0xb54d (19893) with the Accumulator
[0x1a96] 6806    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1a97] 6807    0x32    LD (NN), A      c84d        ;  Load location 0xc84d (19912) with the Accumulator
[0x1a9a] 6810    0x32    LD (NN), A      d04d        ;  Load location 0xd04d (19920) with the Accumulator
[0x1a9d] 6813    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
[0x1aa1] 6817    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x1c ()
[0x1aa5] 6821    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x04 () ) with 0x1c ()
[0x1aa9] 6825    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x06 () ) with 0x1c ()
[0x1aad] 6829    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x08 () ) with 0x1c ()
[0x1ab1] 6833    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x03 () ) with 0x11 ()
[0x1ab5] 6837    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x11 ()
[0x1ab9] 6841    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x11 ()
[0x1abd] 6845    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x11 ()
[0x1ac1] 6849    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
[0x1ac4] 6852    0xcb    SET 5,(HL)                  ;  Set bit 5 of location (HL)
[0x1ac6] 6854    0xcb    RES 7,(HL)                  ;  Reset bit 7 of location (HL)
[0x1ac8] 6856    0xc9    RET                         ;  Return


; $4D26 = $3303 // $3303 == 0x00, 0x01
; B = 0;  $4DC3 = 2;  jump_6372();
[0x1ac9] 6857    0x2a    LD HL, (NN)     0333        ;  Load register pair HL with location 0x0333 (13059)
[0x1acc] 6860    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0x1ace] 6862    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
[0x1ad1] 6865    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
[0x1ad4] 6868    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x1ad6] 6870    0xc3    JP NN           e418        ;  Jump to 0xe418 (6372)

; $4D26 = $32FF // $32FF == 0x00, 0xFF
; B = 0;  $4DC3 = 0;  jump_6372();
[0x1ad9] 6873    0x2a    LD HL, (NN)     ff32        ;  Load register pair HL with location 0xff32 (13055)
[0x1adc] 6876    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1add] 6877    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
[0x1ae0] 6880    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
[0x1ae3] 6883    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x1ae5] 6885    0xc3    JP NN           e418        ;  Jump to 0xe418 (6372)

; $4D26 = $3305 // $3305 == 0xFF, 0x00
; B = 0;  $4DC3 = 3;  jump_6372();
[0x1ae8] 6888    0x2a    LD HL, (NN)     0533        ;  Load register pair HL with location 0x0533 (13061)
[0x1aeb] 6891    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0x1aed] 6893    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
[0x1af0] 6896    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
[0x1af3] 6899    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x1af5] 6901    0xc3    JP NN           e418        ;  Jump to 0xe418 (6372)

; $4D26 = $3301 // $3301 == 0x01, 0x00
; B = 0;  $4DC3 = 1;  jump_6372();
[0x1af8] 6904    0x2a    LD HL, (NN)     0133        ;  Load register pair HL with location 0x0133 (13057)
[0x1afb] 6907    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x1afd] 6909    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
[0x1b00] 6912    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
[0x1b03] 6915    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x1b05] 6917    0xc3    JP NN           e418        ;  Jump to 0xe418 (6372)

; if ( $4E12 == 0 ) {  jump_6932();  }
; $4D9F++;
; return;
[0x1b08] 6920    0x3a    LD A, (NN)      124e        ;  Load Accumulator with location 0x124e (19986)
[0x1b0b] 6923    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1b0c] 6924    0xca    JP Z,           141b        ;  Jump to 0x141b (6932) if ZERO flag is 1
[0x1b0f] 6927    0x21    LD HL, NN       9f4d        ;  Load register pair HL with 0x9f4d (19871)
[0x1b12] 6930    0x34    INC (HL)                    ;  Increment location (HL)
[0x1b13] 6931    0xc9    RET                         ;  Return

; if ( $4DA3 != 0 ) {  return;  }
; if ( $4DA2 == 0 ) {  jump_6949();  }
; $4E11++;
; return;
[0x1b14] 6932    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
[0x1b17] 6935    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1b18] 6936    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1b19] 6937    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
[0x1b1c] 6940    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1b1d] 6941    0xca    JP Z,           251b        ;  Jump to 0x251b (6949) if ZERO flag is 1
[0x1b20] 6944    0x21    LD HL, NN       114e        ;  Load register pair HL with 0x114e (19985)
[0x1b23] 6947    0x34    INC (HL)                    ;  Increment location (HL)
[0x1b24] 6948    0xc9    RET                         ;  Return

; if ( $4DA1 != 0 ) $4E10++;
;              else $4E0F++;
; return;
[0x1b25] 6949    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
[0x1b28] 6952    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1b29] 6953    0xca    JP Z,           311b        ;  Jump to 0x311b (6961) if ZERO flag is 1
[0x1b2c] 6956    0x21    LD HL, NN       104e        ;  Load register pair HL with 0x104e (19984)
[0x1b2f] 6959    0x34    INC (HL)                    ;  Increment location (HL)
[0x1b30] 6960    0xc9    RET                         ;  Return
[0x1b31] 6961    0x21    LD HL, NN       0f4e        ;  Load register pair HL with 0x0f4e (19983)
[0x1b34] 6964    0x34    INC (HL)                    ;  Increment location (HL)
[0x1b35] 6965    0xc9    RET                         ;  Return


; if ( $4DA0 == 0 ) {  return;  }
; if ( $4DAC != 0 ) {  return;  }
; call_8407();
[0x1b36] 6966    0x3a    LD A, (NN)      a04d        ;  Load Accumulator with location 0xa04d (19872)
[0x1b39] 6969    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1b3a] 6970    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1b3b] 6971    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
[0x1b3e] 6974    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1b3f] 6975    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1b40] 6976    0xcd    CALL NN         d720        ;  Call to 0xd720 (8407)
; HL = $4D31;  BC = 0x4D99;
; $BC = ( YX_to_playfield_addr_plus4() == 0x1B ) ? 0x01 : 0x00; // via call_8282()
[0x1b43] 6979    0x2a    LD HL, (NN)     314d        ;  Load register pair HL with location 0x314d (19761)
[0x1b46] 6982    0x01    LD  BC, NN      994d        ;  Load register pair BC with 0x994d (19865)
[0x1b49] 6985    0xcd    CALL NN         5a20        ;  Call to 0x5a20 (8282)
; if ( $4D99 != 0 )
; {
;     $4D60 *= 2;
;     if ( $4D5E *= 2 < 2**16 ) {  return;  }
;     $4D60++;
; }
; else
; {
;     if ( $4DA7 != 0 )
;     {
;         $4D5C *= 2;
;         if ( $4D5A *= 2 < 2**16 ) {  return;  }
;         $4D5C++;
;         if ( $4DB7 != 0 )  // this indention level is located at 7048
;         {
;             $4D50 *= 2;
;             if ( $4D4E *= 2 < 2*16 ) {  return;  }
;             $4D50++;
;         }
;         else
;         {
;             if ( $4DB6 != 1 )
;             {
;                 $4D54 *= 2;
;                 if ( $4D52 *= 2 < 2**16 ) {  return;  }
;                 $4D54++;
;             }
;             else
;             {
;                 $4D58 *= 2;
;                 if ( $4D56 *= 2 < 2**16 ) {  return;  }
;                 $4D58++;
;             }
;         }
;     }
;     else
;     {
;         $4D5C *= 2;
;         if ( $4D5A *= 2 < 2**16 ) {  return;  }
;     }
; }
[0x1b4c] 6988    0x3a    LD A, (NN)      994d        ;  Load Accumulator with location 0x994d (19865)
[0x1b4f] 6991    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1b50] 6992    0xca    JP Z,           6a1b        ;  Jump to 0x6a1b (7018) if ZERO flag is 1
[0x1b53] 6995    0x2a    LD HL, (NN)     604d        ;  Load register pair HL with location 0x604d (19808)
[0x1b56] 6998    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1b57] 6999    0x22    LD (NN), HL     604d        ;  Load location 0x604d (19808) with the register pair HL
[0x1b5a] 7002    0x2a    LD HL, (NN)     5e4d        ;  Load register pair HL with location 0x5e4d (19806)
[0x1b5d] 7005    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1b5f] 7007    0x22    LD (NN), HL     5e4d        ;  Load location 0x5e4d (19806) with the register pair HL
[0x1b62] 7010    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1b63] 7011    0x21    LD HL, NN       604d        ;  Load register pair HL with 0x604d (19808)
[0x1b66] 7014    0x34    INC (HL)                    ;  Increment location (HL)
[0x1b67] 7015    0xc3    JP NN           d81b        ;  Jump to 0xd81b (7128)
[0x1b6a] 7018    0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
[0x1b6d] 7021    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1b6e] 7022    0xca    JP Z,           881b        ;  Jump to 0x881b (7048) if ZERO flag is 1
[0x1b71] 7025    0x2a    LD HL, (NN)     5c4d        ;  Load register pair HL with location 0x5c4d (19804)
[0x1b74] 7028    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1b75] 7029    0x22    LD (NN), HL     5c4d        ;  Load location 0x5c4d (19804) with the register pair HL
[0x1b78] 7032    0x2a    LD HL, (NN)     5a4d        ;  Load register pair HL with location 0x5a4d (19802)
[0x1b7b] 7035    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1b7d] 7037    0x22    LD (NN), HL     5a4d        ;  Load location 0x5a4d (19802) with the register pair HL
[0x1b80] 7040    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1b81] 7041    0x21    LD HL, NN       5c4d        ;  Load register pair HL with 0x5c4d (19804)
[0x1b84] 7044    0x34    INC (HL)                    ;  Increment location (HL)
[0x1b85] 7045    0xc3    JP NN           d81b        ;  Jump to 0xd81b (7128)
[0x1b88] 7048    0x3a    LD A, (NN)      b74d        ;  Load Accumulator with location 0xb74d (19895)
[0x1b8b] 7051    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1b8c] 7052    0xca    JP Z,           a61b        ;  Jump to 0xa61b (7078) if ZERO flag is 1
[0x1b8f] 7055    0x2a    LD HL, (NN)     504d        ;  Load register pair HL with location 0x504d (19792)
[0x1b92] 7058    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1b93] 7059    0x22    LD (NN), HL     504d        ;  Load location 0x504d (19792) with the register pair HL
[0x1b96] 7062    0x2a    LD HL, (NN)     4e4d        ;  Load register pair HL with location 0x4e4d (19790)
[0x1b99] 7065    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1b9b] 7067    0x22    LD (NN), HL     4e4d        ;  Load location 0x4e4d (19790) with the register pair HL
[0x1b9e] 7070    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1b9f] 7071    0x21    LD HL, NN       504d        ;  Load register pair HL with 0x504d (19792)
[0x1ba2] 7074    0x34    INC (HL)                    ;  Increment location (HL)
[0x1ba3] 7075    0xc3    JP NN           d81b        ;  Jump to 0xd81b (7128)
[0x1ba6] 7078    0x3a    LD A, (NN)      b64d        ;  Load Accumulator with location 0xb64d (19894)
[0x1ba9] 7081    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1baa] 7082    0xca    JP Z,           c41b        ;  Jump to 0xc41b (7108) if ZERO flag is 1
[0x1bad] 7085    0x2a    LD HL, (NN)     544d        ;  Load register pair HL with location 0x544d (19796)
[0x1bb0] 7088    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1bb1] 7089    0x22    LD (NN), HL     544d        ;  Load location 0x544d (19796) with the register pair HL
[0x1bb4] 7092    0x2a    LD HL, (NN)     524d        ;  Load register pair HL with location 0x524d (19794)
[0x1bb7] 7095    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1bb9] 7097    0x22    LD (NN), HL     524d        ;  Load location 0x524d (19794) with the register pair HL
[0x1bbc] 7100    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1bbd] 7101    0x21    LD HL, NN       544d        ;  Load register pair HL with 0x544d (19796)
[0x1bc0] 7104    0x34    INC (HL)                    ;  Increment location (HL)
[0x1bc1] 7105    0xc3    JP NN           d81b        ;  Jump to 0xd81b (7128)
[0x1bc4] 7108    0x2a    LD HL, (NN)     584d        ;  Load register pair HL with location 0x584d (19800)
[0x1bc7] 7111    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1bc8] 7112    0x22    LD (NN), HL     584d        ;  Load location 0x584d (19800) with the register pair HL
[0x1bcb] 7115    0x2a    LD HL, (NN)     564d        ;  Load register pair HL with location 0x564d (19798)
[0x1bce] 7118    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1bd0] 7120    0x22    LD (NN), HL     564d        ;  Load location 0x564d (19798) with the register pair HL
[0x1bd3] 7123    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1bd4] 7124    0x21    LD HL, NN       584d        ;  Load register pair HL with 0x584d (19800)
[0x1bd7] 7127    0x34    INC (HL)                    ;  Increment location (HL)
; if ( $4D14 != 0 ) // if blinky is moving up or down
; {
;     if ( $4D00 & 0x07 == 4 ) {  jump_7159();  }
;                         else {  jump_7222();  }
; }
; else // if blinky is moving left or right
; {
;     if ( $4D01 & 0x07 != 4 ) {  jump_7222();  }
;                      // else {  jump_7159();  }
; }
[0x1bd8] 7128    0x21    LD HL, NN       144d        ;  Load register pair HL with 0x144d (19732)
[0x1bdb] 7131    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1bdc] 7132    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1bdd] 7133    0xca    JP Z,           ed1b        ;  Jump to 0xed1b (7149) if ZERO flag is 1
[0x1be0] 7136    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
[0x1be3] 7139    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1be5] 7141    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1be7] 7143    0xca    JP Z,           f71b        ;  Jump to 0xf71b (7159) if ZERO flag is 1
[0x1bea] 7146    0xc3    JP NN           361c        ;  Jump to 0x361c (7222)
[0x1bed] 7149    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x1bf0] 7152    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1bf2] 7154    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1bf4] 7156    0xc2    JP NZ, NN       361c        ;  Jump to 0x361c (7222) if ZERO flag is 0


; if ( tunnel_warp(red_ghost) )
; {
;     if ( $4DA7 != 0 ) {  rst_28(0x0C,0x00);  }  // $4DA7 = red_edible
;     else
;     {
;         HL = YX_to_playfieldaddr(0x4D0A);
;         if ( $HL != 0x1A ) {  rst_28(0x08,0x00);  }
;     }
;     call_7934();
; }
; $4D0A += $4D1E; // double-byte
; $4D14 = $4D1E;  // double-byte
; $4D2C = $4D28;
; $4D00 += $4D14;  // double-byte
; $4D31 = call_8216();  // return value from 8216 in HL, I assume?
; return;
[0x1bf7] 7159    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x1bf9] 7161    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
[0x1bfc] 7164    0x38    JR C, N         1b          ;  Jump to 0x1b (27) if CARRY flag is 1
[0x1bfe] 7166    0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
[0x1c01] 7169    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1c02] 7170    0xca    JP Z,           0b1c        ;  Jump to 0x0b1c (7179) if ZERO flag is 1
[0x1c05] 7173    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0C, 0x00
[0x1c08] 7176    0xc3    JP NN           191c        ;  Jump to 0x191c (7193)
[0x1c0b] 7179    0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
[0x1c0e] 7182    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
[0x1c11] 7185    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1c12] 7186    0xfe    CP N            1a          ;  Compare 0x1a (26) with Accumulator
[0x1c14] 7188    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
[0x1c16] 7190    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x08, 0x00
[0x1c19] 7193    0xcd    CALL NN         fe1e        ;  Call to 0xfe1e (7934)
[0x1c1c] 7196    0xdd    LD IX, NN       1e4d        ;  Load register pair IX with 0x1e4d (19742)
[0x1c20] 7200    0xfd    LD IY, NN       0a4d        ;  Load register pair IY with 0x0a4d (19722)
; HL = (IY) + (IX);
[0x1c24] 7204    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1c27] 7207    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
[0x1c2a] 7210    0x2a    LD HL, (NN)     1e4d        ;  Load register pair HL with location 0x1e4d (19742)
[0x1c2d] 7213    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
[0x1c30] 7216    0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
[0x1c33] 7219    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
[0x1c36] 7222    0xdd    LD IX, NN       144d        ;  Load register pair IX with 0x144d (19732)
[0x1c3a] 7226    0xfd    LD IY, NN       004d        ;  Load register pair IY with 0x004d (19712)
; HL = (IY) + (IX);
[0x1c3e] 7230    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1c41] 7233    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
[0x1c44] 7236    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
[0x1c47] 7239    0x22    LD (NN), HL     314d        ;  Load location 0x314d (19761) with the register pair HL
[0x1c4a] 7242    0xc9    RET                         ;  Return


; if ( $4DA1 != 1 ) {  return;  }
; if ( $4DAD != 0 ) {  return;  }
; HL = $4D33;  // double-byte
; BC = 0x4D9A;
; $BC = ( YX_to_playfield_addr_plus4() == 0x1B ) ? 0x01 : 0x00; // via call_8282()
; if ( $4D9A != 0 )
; {
;     $4D6C *= 2;  // double-byte;
;     if ( $4D6A *= 2 < 2**16 ) {  return;  }
;     $4D6C++;
; }
; else
; {
;     if ( $4DA8 != 0 )
;     {
;         $4D68 *= 2;
;         if ( $4D66 *= 2 < 2**16 ) {  return;  }
;         $4D68++;
;     }
;     else
;     {
;         $4D64 *= 2;
;         if ( $4D62 *= 2 < 2**16 ) {  return;  }
;         $4D64++;
;     }
; }
[0x1c4b] 7243    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
[0x1c4e] 7246    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x1c50] 7248    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1c51] 7249    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
[0x1c54] 7252    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1c55] 7253    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1c56] 7254    0x2a    LD HL, (NN)     334d        ;  Load register pair HL with location 0x334d (19763)
[0x1c59] 7257    0x01    LD  BC, NN      9a4d        ;  Load register pair BC with 0x9a4d (19866)
[0x1c5c] 7260    0xcd    CALL NN         5a20        ;  Call to 0x5a20 (8282)
[0x1c5f] 7263    0x3a    LD A, (NN)      9a4d        ;  Load Accumulator with location 0x9a4d (19866)
[0x1c62] 7266    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1c63] 7267    0xca    JP Z,           7d1c        ;  Jump to 0x7d1c (7293) if ZERO flag is 1
[0x1c66] 7270    0x2a    LD HL, (NN)     6c4d        ;  Load register pair HL with location 0x6c4d (19820)
[0x1c69] 7273    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1c6a] 7274    0x22    LD (NN), HL     6c4d        ;  Load location 0x6c4d (19820) with the register pair HL
[0x1c6d] 7277    0x2a    LD HL, (NN)     6a4d        ;  Load register pair HL with location 0x6a4d (19818)
[0x1c70] 7280    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1c72] 7282    0x22    LD (NN), HL     6a4d        ;  Load location 0x6a4d (19818) with the register pair HL
[0x1c75] 7285    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1c76] 7286    0x21    LD HL, NN       6c4d        ;  Load register pair HL with 0x6c4d (19820)
[0x1c79] 7289    0x34    INC (HL)                    ;  Increment location (HL)
[0x1c7a] 7290    0xc3    JP NN           af1c        ;  Jump to 0xaf1c (7343)
[0x1c7d] 7293    0x3a    LD A, (NN)      a84d        ;  Load Accumulator with location 0xa84d (19880)
[0x1c80] 7296    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1c81] 7297    0xca    JP Z,           9b1c        ;  Jump to 0x9b1c (7323) if ZERO flag is 1
[0x1c84] 7300    0x2a    LD HL, (NN)     684d        ;  Load register pair HL with location 0x684d (19816)
[0x1c87] 7303    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1c88] 7304    0x22    LD (NN), HL     684d        ;  Load location 0x684d (19816) with the register pair HL
[0x1c8b] 7307    0x2a    LD HL, (NN)     664d        ;  Load register pair HL with location 0x664d (19814)
[0x1c8e] 7310    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1c90] 7312    0x22    LD (NN), HL     664d        ;  Load location 0x664d (19814) with the register pair HL
[0x1c93] 7315    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1c94] 7316    0x21    LD HL, NN       684d        ;  Load register pair HL with 0x684d (19816)
[0x1c97] 7319    0x34    INC (HL)                    ;  Increment location (HL)
[0x1c98] 7320    0xc3    JP NN           af1c        ;  Jump to 0xaf1c (7343)
[0x1c9b] 7323    0x2a    LD HL, (NN)     644d        ;  Load register pair HL with location 0x644d (19812)
[0x1c9e] 7326    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1c9f] 7327    0x22    LD (NN), HL     644d        ;  Load location 0x644d (19812) with the register pair HL
[0x1ca2] 7330    0x2a    LD HL, (NN)     624d        ;  Load register pair HL with location 0x624d (19810)
[0x1ca5] 7333    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1ca7] 7335    0x22    LD (NN), HL     624d        ;  Load location 0x624d (19810) with the register pair HL
[0x1caa] 7338    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1cab] 7339    0x21    LD HL, NN       644d        ;  Load register pair HL with 0x644d (19812)
[0x1cae] 7342    0x34    INC (HL)                    ;  Increment location (HL)

; HL = 0x4D16
; if ( $HL != 1 )
; {
;     if ( $4D02 & 0x07 != 4 ) {  jump_7437();  }  // 7437 is {  $4D02 += $4D16;  L = ( L >> 3 ) + 0x20;  H = ( H >> 3 ) + 0x1E;  return;  }
; }
; else
; {
;     if ( $4D03 & 0x07 != 4 ) {  jump_7437();  }  // 7437 is {  $4D02 += $4D16;  L = ( L >> 3 ) + 0x20;  H = ( H >> 3 ) + 0x1E;  return;  }
; }
[0x1caf] 7343    0x21    LD HL, NN       164d        ;  Load register pair HL with 0x164d (19734)
[0x1cb2] 7346    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1cb3] 7347    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1cb4] 7348    0xca    JP Z,           c41c        ;  Jump to 0xc41c (7364) if ZERO flag is 1
[0x1cb7] 7351    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
[0x1cba] 7354    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1cbc] 7356    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1cbe] 7358    0xca    JP Z,           ce1c        ;  Jump to 0xce1c (7374) if ZERO flag is 1
[0x1cc1] 7361    0xc3    JP NN           0d1d        ;  Jump to 0x0d1d (7437)
[0x1cc4] 7364    0x3a    LD A, (NN)      034d        ;  Load Accumulator with location 0x034d (19715)
[0x1cc7] 7367    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1cc9] 7369    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1ccb] 7371    0xc2    JP NZ, NN       0d1d        ;  Jump to 0x0d1d (7437) if ZERO flag is 0
; if ( tunnel_warp(pink_ghost) )
; {
;     if ( $4DA8 != 0 )
;     {
;         rst_28(0x0D,0x00);
;         HL = YX_to_playfieldaddr(HL=0x4D0C);
;         if ( $HL != 0x1A ) {  rst_28(0x09, 0x00);  }
;     }
; }
; call_7973();
; $4D0C += $4D20;
; $4D16 = $4D20; // double-byte
; $4D29 = $4D2D;
[0x1cce] 7374    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0x1cd0] 7376    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
[0x1cd3] 7379    0x38    JR C, N         1b          ;  Jump to 0x1b (27) if CARRY flag is 1
[0x1cd5] 7381    0x3a    LD A, (NN)      a84d        ;  Load Accumulator with location 0xa84d (19880)
[0x1cd8] 7384    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1cd9] 7385    0xca    JP Z,           e21c        ;  Jump to 0xe21c (7394) if ZERO flag is 1
[0x1cdc] 7388    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0D, 0x00
[0x1cdf] 7391    0xc3    JP NN           f01c        ;  Jump to 0xf01c (7408)
[0x1ce2] 7394    0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
[0x1ce5] 7397    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
[0x1ce8] 7400    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1ce9] 7401    0xfe    CP N            1a          ;  Compare 0x1a (26) with Accumulator
[0x1ceb] 7403    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
[0x1ced] 7405    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x09, 0x00
[0x1cf0] 7408    0xcd    CALL NN         251f        ;  Call to 0x251f (7973)
[0x1cf3] 7411    0xdd    LD IX, NN       204d        ;  Load register pair IX with 0x204d (19744)
[0x1cf7] 7415    0xfd    LD IY, NN       0c4d        ;  Load register pair IY with 0x0c4d (19724)
; HL = (IY) + (IX);
[0x1cfb] 7419    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1cfe] 7422    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
[0x1d01] 7425    0x2a    LD HL, (NN)     204d        ;  Load register pair HL with location 0x204d (19744)
[0x1d04] 7428    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
[0x1d07] 7431    0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
[0x1d0a] 7434    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
; $4D02 += $4D16;
; L = ( L >> 3 ) + 0x20;  H = ( H >> 3 ) + 0x1E;
; $4DEE = HL;
; return;
[0x1d0d] 7437    0xdd    LD IX, NN       164d        ;  Load register pair IX with 0x164d (19734)
[0x1d11] 7441    0xfd    LD IY, NN       024d        ;  Load register pair IY with 0x024d (19714)
; HL = (IY) + (IX);
[0x1d15] 7445    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1d18] 7448    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
[0x1d1b] 7451    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
[0x1d1e] 7454    0x22    LD (NN), HL     334d        ;  Load location 0x334d (19763) with the register pair HL
[0x1d21] 7457    0xc9    RET                         ;  Return


; if ( $4DA2 != 1 ) {  return;  }
; if ( $4DAE != 0 ) {  return;  }
; HL = $4D35;  BC = 0x4D9B;
; $BC = ( YX_to_playfield_addr_plus4() == 0x1B ) ? 0x01 : 0x00; // via call_8282()
[0x1d22] 7458    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
[0x1d25] 7461    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x1d27] 7463    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1d28] 7464    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
[0x1d2b] 7467    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1d2c] 7468    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1d2d] 7469    0x2a    LD HL, (NN)     354d        ;  Load register pair HL with location 0x354d (19765)
[0x1d30] 7472    0x01    LD  BC, NN      9b4d        ;  Load register pair BC with 0x9b4d (19867)
[0x1d33] 7475    0xcd    CALL NN         5a20        ;  Call to 0x5a20 (8282)

; if ( $4D9B != 0 )
; {
;     $4D78 *= 2;
;     if ( $4D76 *= 2 < 2**16 ) {  return;  }
;     $4D78++;
; }
; else
; {
;     if ( $4DA9 != 0 )
;     {
;         $4D74 *= 2;
;         if ( $4D72 *= 2 < 2**16 ) {  return;  }
;         $4D74++;
;     }
;     else
;     {
;         $4D70 *= $4D70;
;         if ( $4D6E *= 2 < 2**16 ) {  return;  }
;         $4D70++;
;     }
; }
[0x1d36] 7478    0x3a    LD A, (NN)      9b4d        ;  Load Accumulator with location 0x9b4d (19867)
[0x1d39] 7481    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1d3a] 7482    0xca    JP Z,           541d        ;  Jump to 0x541d (7508) if ZERO flag is 1
[0x1d3d] 7485    0x2a    LD HL, (NN)     784d        ;  Load register pair HL with location 0x784d (19832)
[0x1d40] 7488    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1d41] 7489    0x22    LD (NN), HL     784d        ;  Load location 0x784d (19832) with the register pair HL
[0x1d44] 7492    0x2a    LD HL, (NN)     764d        ;  Load register pair HL with location 0x764d (19830)
[0x1d47] 7495    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1d49] 7497    0x22    LD (NN), HL     764d        ;  Load location 0x764d (19830) with the register pair HL
[0x1d4c] 7500    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1d4d] 7501    0x21    LD HL, NN       784d        ;  Load register pair HL with 0x784d (19832)
[0x1d50] 7504    0x34    INC (HL)                    ;  Increment location (HL)
[0x1d51] 7505    0xc3    JP NN           861d        ;  Jump to 0x861d (7558)
[0x1d54] 7508    0x3a    LD A, (NN)      a94d        ;  Load Accumulator with location 0xa94d (19881)
[0x1d57] 7511    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1d58] 7512    0xca    JP Z,           721d        ;  Jump to 0x721d (7538) if ZERO flag is 1
[0x1d5b] 7515    0x2a    LD HL, (NN)     744d        ;  Load register pair HL with location 0x744d (19828)
[0x1d5e] 7518    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1d5f] 7519    0x22    LD (NN), HL     744d        ;  Load location 0x744d (19828) with the register pair HL
[0x1d62] 7522    0x2a    LD HL, (NN)     724d        ;  Load register pair HL with location 0x724d (19826)
[0x1d65] 7525    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1d67] 7527    0x22    LD (NN), HL     724d        ;  Load location 0x724d (19826) with the register pair HL
[0x1d6a] 7530    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1d6b] 7531    0x21    LD HL, NN       744d        ;  Load register pair HL with 0x744d (19828)
[0x1d6e] 7534    0x34    INC (HL)                    ;  Increment location (HL)
[0x1d6f] 7535    0xc3    JP NN           861d        ;  Jump to 0x861d (7558)
[0x1d72] 7538    0x2a    LD HL, (NN)     704d        ;  Load register pair HL with location 0x704d (19824)
[0x1d75] 7541    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1d76] 7542    0x22    LD (NN), HL     704d        ;  Load location 0x704d (19824) with the register pair HL
[0x1d79] 7545    0x2a    LD HL, (NN)     6e4d        ;  Load register pair HL with location 0x6e4d (19822)
[0x1d7c] 7548    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1d7e] 7550    0x22    LD (NN), HL     6e4d        ;  Load location 0x6e4d (19822) with the register pair HL
[0x1d81] 7553    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1d82] 7554    0x21    LD HL, NN       704d        ;  Load register pair HL with 0x704d (19824)
[0x1d85] 7557    0x34    INC (HL)                    ;  Increment location (HL)

; if ( $4D18 != 0 )
; {
; //    if ( $4D04 & 0x07 == 4 ) {  jump_7589();  } else {  jump_7652();  }
;     if ( $4D04 & 0x07 != 4 ) {  jump_7652();  }
; }
; else
; {
;     if ( $4D05 & 0x07 != 4 ) {  jump_7652();  }
; }
[0x1d86] 7558    0x21    LD HL, NN       184d        ;  Load register pair HL with 0x184d (19736)
[0x1d89] 7561    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1d8a] 7562    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1d8b] 7563    0xca    JP Z,           9b1d        ;  Jump to 0x9b1d (7579) if ZERO flag is 1
[0x1d8e] 7566    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
[0x1d91] 7569    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1d93] 7571    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1d95] 7573    0xca    JP Z,           a51d        ;  Jump to 0xa51d (7589) if ZERO flag is 1
[0x1d98] 7576    0xc3    JP NN           e41d        ;  Jump to 0xe41d (7652)

[0x1d9b] 7579    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
[0x1d9e] 7582    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1da0] 7584    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1da2] 7586    0xc2    JP NZ, NN       e41d        ;  Jump to 0xe41d (7652) if ZERO flag is 0
; if ( tunnel_warp(blue_ghost) )
; {
;     if ( $4DA9 != 0 )
;     {  rst_28(0x0E,0x00);  }
;     else
;     {
;         HL = YX_to_playfieldaddr(HL=0x4D0E);
;         if ( $HL != 0x1A ) {  rst_28(0x0A, 0x00);  }
;     }
; }
; call_8012();
; $4D0E += $4D22; // double-byte
; $4D18 = $4D22; // double-byte
; $4D2A = $4D2E;
; HL = $4D04 += $4D18; // double-byte
; L = ( L >> 3 ) + 0x20;  H = ( H >> 3 ) + 0x1E;
; $4D35 = HL;
[0x1da5] 7589    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0x1da7] 7591    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
[0x1daa] 7594    0x38    JR C, N         1b          ;  Jump to 0x1b (27) if CARRY flag is 1
[0x1dac] 7596    0x3a    LD A, (NN)      a94d        ;  Load Accumulator with location 0xa94d (19881)
[0x1daf] 7599    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1db0] 7600    0xca    JP Z,           b91d        ;  Jump to 0xb91d (7609) if ZERO flag is 1
[0x1db3] 7603    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0E, 0x00
[0x1db6] 7606    0xc3    JP NN           c71d        ;  Jump to 0xc71d (7623)
[0x1db9] 7609    0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
[0x1dbc] 7612    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
[0x1dbf] 7615    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1dc0] 7616    0xfe    CP N            1a          ;  Compare 0x1a (26) with Accumulator
[0x1dc2] 7618    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
[0x1dc4] 7620    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0a, 0x00
[0x1dc7] 7623    0xcd    CALL NN         4c1f        ;  Call to 0x4c1f (8012)
[0x1dca] 7626    0xdd    LD IX, NN       224d        ;  Load register pair IX with 0x224d (19746)
[0x1dce] 7630    0xfd    LD IY, NN       0e4d        ;  Load register pair IY with 0x0e4d (19726)
; HL = (IY) + (IX);
[0x1dd2] 7634    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1dd5] 7637    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
[0x1dd8] 7640    0x2a    LD HL, (NN)     224d        ;  Load register pair HL with location 0x224d (19746)
[0x1ddb] 7643    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
[0x1dde] 7646    0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
[0x1de1] 7649    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
[0x1de4] 7652    0xdd    LD IX, NN       184d        ;  Load register pair IX with 0x184d (19736)
[0x1de8] 7656    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
; HL = (IY) + (IX);
[0x1dec] 7660    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1def] 7663    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
[0x1df2] 7666    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
[0x1df5] 7669    0x22    LD (NN), HL     354d        ;  Load location 0x354d (19765) with the register pair HL
[0x1df8] 7672    0xc9    RET                         ;  Return


; if ( $4DA3 != 1 ) {  return;  }
; if ( $4DAF != 0 ) {  return;  }
; HL = $4D37;  BC = 0x4D9C;
; $BC = ( YX_to_playfield_addr_plus4() == 0x1B ) ? 0x01 : 0x00; // via call_8282()
; if ( $4D9C != 0 )
; {
;     $4D84 *= 2;
;     if ( $4D82 *= 2 < 2**16 ) {  return;  }
;     $4D84++;
; }
; else
; {
;     if ( $4DAA != 0 )
;     {
;         $4D80 *= 2;
;         if ( $4D7E *= 2 < 2**16 ) {  return;  }
;         $4D80++;
;     }
;     else
;     {
;         $4D7C *= 2;
;         if ( $4D7A *= 2 , 2**16 ) {  return;  }
;         $4D7C++;
;     }
; }
[0x1df9] 7673    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
[0x1dfc] 7676    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x1dfe] 7678    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1dff] 7679    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
[0x1e02] 7682    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1e03] 7683    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1e04] 7684    0x2a    LD HL, (NN)     374d        ;  Load register pair HL with location 0x374d (19767)
[0x1e07] 7687    0x01    LD  BC, NN      9c4d        ;  Load register pair BC with 0x9c4d (19868)
[0x1e0a] 7690    0xcd    CALL NN         5a20        ;  Call to 0x5a20 (8282)
[0x1e0d] 7693    0x3a    LD A, (NN)      9c4d        ;  Load Accumulator with location 0x9c4d (19868)
[0x1e10] 7696    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1e11] 7697    0xca    JP Z,           2b1e        ;  Jump to 0x2b1e (7723) if ZERO flag is 1
[0x1e14] 7700    0x2a    LD HL, (NN)     844d        ;  Load register pair HL with location 0x844d (19844)
[0x1e17] 7703    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1e18] 7704    0x22    LD (NN), HL     844d        ;  Load location 0x844d (19844) with the register pair HL
[0x1e1b] 7707    0x2a    LD HL, (NN)     824d        ;  Load register pair HL with location 0x824d (19842)
[0x1e1e] 7710    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1e20] 7712    0x22    LD (NN), HL     824d        ;  Load location 0x824d (19842) with the register pair HL
[0x1e23] 7715    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1e24] 7716    0x21    LD HL, NN       844d        ;  Load register pair HL with 0x844d (19844)
[0x1e27] 7719    0x34    INC (HL)                    ;  Increment location (HL)
[0x1e28] 7720    0xc3    JP NN           5d1e        ;  Jump to 0x5d1e (7773)
[0x1e2b] 7723    0x3a    LD A, (NN)      aa4d        ;  Load Accumulator with location 0xaa4d (19882)
[0x1e2e] 7726    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1e2f] 7727    0xca    JP Z,           491e        ;  Jump to 0x491e (7753) if ZERO flag is 1
[0x1e32] 7730    0x2a    LD HL, (NN)     804d        ;  Load register pair HL with location 0x804d (19840)
[0x1e35] 7733    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1e36] 7734    0x22    LD (NN), HL     804d        ;  Load location 0x804d (19840) with the register pair HL
[0x1e39] 7737    0x2a    LD HL, (NN)     7e4d        ;  Load register pair HL with location 0x7e4d (19838)
[0x1e3c] 7740    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1e3e] 7742    0x22    LD (NN), HL     7e4d        ;  Load location 0x7e4d (19838) with the register pair HL
[0x1e41] 7745    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1e42] 7746    0x21    LD HL, NN       804d        ;  Load register pair HL with 0x804d (19840)
[0x1e45] 7749    0x34    INC (HL)                    ;  Increment location (HL)
[0x1e46] 7750    0xc3    JP NN           5d1e        ;  Jump to 0x5d1e (7773)
[0x1e49] 7753    0x2a    LD HL, (NN)     7c4d        ;  Load register pair HL with location 0x7c4d (19836)
[0x1e4c] 7756    0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x1e4d] 7757    0x22    LD (NN), HL     7c4d        ;  Load location 0x7c4d (19836) with the register pair HL
[0x1e50] 7760    0x2a    LD HL, (NN)     7a4d        ;  Load register pair HL with location 0x7a4d (19834)
[0x1e53] 7763    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
[0x1e55] 7765    0x22    LD (NN), HL     7a4d        ;  Load location 0x7a4d (19834) with the register pair HL
[0x1e58] 7768    0xd0    RET NC                      ;  Return if CARRY flag is 0
[0x1e59] 7769    0x21    LD HL, NN       7c4d        ;  Load register pair HL with 0x7c4d (19836)
[0x1e5c] 7772    0x34    INC (HL)                    ;  Increment location (HL)

; if ( $4D1A != 0 )
; {
;     if ( $4D06 & 0x07 != 0x04 ) {  jump_7867();  }
; }
; else
; {
;     if ( $4D07 & 0x07 != 0x04 ) {  jump_7867();  }
; }
[0x1e5d] 7773    0x21    LD HL, NN       1a4d        ;  Load register pair HL with 0x1a4d (19738)
[0x1e60] 7776    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1e61] 7777    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1e62] 7778    0xca    JP Z,           721e        ;  Jump to 0x721e (7794) if ZERO flag is 1
[0x1e65] 7781    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
[0x1e68] 7784    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1e6a] 7786    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1e6c] 7788    0xca    JP Z,           7c1e        ;  Jump to 0x7c1e (7804) if ZERO flag is 1
[0x1e6f] 7791    0xc3    JP NN           bb1e        ;  Jump to 0xbb1e (7867)
[0x1e72] 7794    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
[0x1e75] 7797    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x1e77] 7799    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x1e79] 7801    0xc2    JP NZ, NN       bb1e        ;  Jump to 0xbb1e (7867) if ZERO flag is 0

; if ( tunnel_warp(orange_ghost) )
; {
;     if ( $4DAA != 0 )
;     {  rst_28(0x0E,0x00);  }
;     else
;     {
;         HL = YX_to_playfieldaddr(HL=0x4D10);
;         if ( $HL != 0x1A ) {  rst_28(0x0B, 0x00);  }
;     }
; }
; call_8051();
; $4D10 += $4D24;
; $4D1A = $4D24;
; $4D2B = $4D2F;
; HL = $4D06 += $4D1A;
; L = ( L >> 3 ) + 0x20;  H = ( H >> 3 ) + 0x1E;
; $4D37 = HL;
; return;
[0x1e7c] 7804    0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
[0x1e7e] 7806    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
[0x1e81] 7809    0x38    JR C, N         1b          ;  Jump to 0x1b (27) if CARRY flag is 1
[0x1e83] 7811    0x3a    LD A, (NN)      aa4d        ;  Load Accumulator with location 0xaa4d (19882)
[0x1e86] 7814    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1e87] 7815    0xca    JP Z,           901e        ;  Jump to 0x901e (7824) if ZERO flag is 1
[0x1e8a] 7818    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0F, 0x00
[0x1e8d] 7821    0xc3    JP NN           9e1e        ;  Jump to 0x9e1e (7838)
[0x1e90] 7824    0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
[0x1e93] 7827    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
[0x1e96] 7830    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1e97] 7831    0xfe    CP N            1a          ;  Compare 0x1a (26) with Accumulator
[0x1e99] 7833    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
[0x1e9b] 7835    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0B, 0x00
[0x1e9e] 7838    0xcd    CALL NN         731f        ;  Call to 0x731f (8051)
[0x1ea1] 7841    0xdd    LD IX, NN       244d        ;  Load register pair IX with 0x244d (19748)
[0x1ea5] 7845    0xfd    LD IY, NN       104d        ;  Load register pair IY with 0x104d (19728)
; HL = (IY) + (IX);
[0x1ea9] 7849    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1eac] 7852    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
[0x1eaf] 7855    0x2a    LD HL, (NN)     244d        ;  Load register pair HL with location 0x244d (19748)
[0x1eb2] 7858    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
[0x1eb5] 7861    0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
[0x1eb8] 7864    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
[0x1ebb] 7867    0xdd    LD IX, NN       1a4d        ;  Load register pair IX with 0x1a4d (19738)
[0x1ebf] 7871    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
; HL = (IY) + (IX);
[0x1ec3] 7875    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x1ec6] 7878    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
[0x1ec9] 7881    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
[0x1ecc] 7884    0x22    LD (NN), HL     374d        ;  Load location 0x374d (19767) with the register pair HL
[0x1ecf] 7887    0xc9    RET                         ;  Return



; tunnel_warp(ghost=A)  // ghost = {1=red, 2=pink, 3=blue, 4=orange, 5=pacman?}
; HL = $(0x4D09+A*2);    // A = ghost_x;
; if ( $HL == 0x1D ) {  $HL = 0x3D;  set_carry();  return;  }
; if ( $HL == 0x3E ) {  $HL = 0x1E;  set_carry();  return;  }
; if ( $HL < 0x21 ) {  set_carry();  return;  }  // this happens with a 'no carry' subtract... bug?
; if ( $HL > 0x3B ) {  set_carry();  return;  } 
; A &= A;  // why?  probably to clear the carry flag
; return;
[0x1ed0] 7888    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x1ed1] 7889    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x1ed2] 7890    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x1ed4] 7892    0x21    LD HL, NN       094d        ;  Load register pair HL with 0x094d (19721)
[0x1ed7] 7895    0x09    ADD HL, BC                  ;  Add register pair BC to HL
[0x1ed8] 7896    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1ed9] 7897    0xfe    CP N            1d          ;  Compare 0x1d (29) with Accumulator
[0x1edb] 7899    0xc2    JP NZ, NN       e31e        ;  Jump to 0xe31e (7907) if ZERO flag is 0
[0x1ede] 7902    0x36    LD (HL), N      3d          ;  Load register pair HL with 0x3d (61)
[0x1ee0] 7904    0xc3    JP NN           fc1e        ;  Jump to 0xfc1e (7932)
[0x1ee3] 7907    0xfe    CP N            3e          ;  Compare 0x3e (62) with Accumulator
[0x1ee5] 7909    0xc2    JP NZ, NN       ed1e        ;  Jump to 0xed1e (7917) if ZERO flag is 0
[0x1ee8] 7912    0x36    LD (HL), N      1e          ;  Load register pair HL with 0x1e (30)
[0x1eea] 7914    0xc3    JP NN           fc1e        ;  Jump to 0xfc1e (7932)
[0x1eed] 7917    0x06    LD  B, N        21          ;  Load register B with 0x21 (33)
[0x1eef] 7919    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x1ef0] 7920    0xda    JP C, NN        fc1e        ;  Jump to 0xfc1e (7932) if CARRY flag is 1
[0x1ef3] 7923    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x1ef4] 7924    0x06    LD  B, N        3b          ;  Load register B with 0x3b (59)
[0x1ef6] 7926    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x1ef7] 7927    0xd2    JP NC, NN       fc1e        ;  Jump to 0xfc1e (7932) if CARRY flag is 0
[0x1efa] 7930    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
[0x1efb] 7931    0xc9    RET                         ;  Return
[0x1efc] 7932    0x37    SCF                         ;  Set CARRY flag
[0x1efd] 7933    0xc9    RET                         ;  Return


;; red_reverse()
; if ( $4DB1 == 0 ) {  return;  }  // $4DB1 = red_reversal
; $4DB1 = 0;
; HL = 0x32FF;  // 0x32FF is the table for ghost direction: 0x00, 0xFF ; 0x01, 0x00 ; 0x00, 0x01 ; 0xFF, 0x00
; $4D2C = A = $4D28 ^ 0x02;  // Reverse vertical direction component... hack to compensate for table being reversed?
; B = A;
; $4D1E = HL = short_load(HL==table, B==index);  // short_load(0x32FF, $4D28 ^ 0x02);
; A = $4E02;
; if ( $4E02 != 0x22 ) {  return;  }
; $4D14 = HL;  // short_load(0x32FF, $4D28 ^ 0x02);
; $4D28 = A = B;  // $4D28 ^ 0x02
; return;
[0x1efe] 7934    0x3a    LD A, (NN)      b14d        ;  Load Accumulator with location 0xb14d (19889)
[0x1f01] 7937    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1f02] 7938    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1f03] 7939    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1f04] 7940    0x32    LD (NN), A      b14d        ;  Load location 0xb14d (19889) with the Accumulator
[0x1f07] 7943    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
[0x1f0a] 7946    0x3a    LD A, (NN)      284d        ;  Load Accumulator with location 0x284d (19752)
[0x1f0d] 7949    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
[0x1f0f] 7951    0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
[0x1f12] 7954    0x47    LD B, A                     ;  Load register B with Accumulator
[0x1f13] 7955    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
[0x1f14] 7956    0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
[0x1f17] 7959    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
[0x1f1a] 7962    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
[0x1f1c] 7964    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1f1d] 7965    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
[0x1f20] 7968    0x78    LD A, B                     ;  Load Accumulator with register B
[0x1f21] 7969    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
[0x1f24] 7972    0xc9    RET                         ;  Return


;; pink_reverse()
; if ( $4DB2 == 0 ) {  return;  }
; $4DB2 = 0;
; HL = 0x32FF;  // 0x32FF is the table for ghost direction: 0x00, 0xFF ; 0x01, 0x00 ; 0x00, 0x01 ; 0xFF, 0x00
; $4D2D = A = $4D29 ^ 0x02;
; B = A;
; $4D20 = HL = short_load(HL==table, B==index);  // short_load(0x32FF, $4D29 ^ 0x02);
; A = $4E02;
; if ( $4E02 != 0x22 ) {  return;  }
; $4D16 = HL;  // short_load(0x32FF, $4D29 ^ 0x02);
; $4D29 = A = B;  // $4D29 ^ 0x02
; return;
[0x1f25] 7973    0x3a    LD A, (NN)      b24d        ;  Load Accumulator with location 0xb24d (19890)
[0x1f28] 7976    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1f29] 7977    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1f2a] 7978    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1f2b] 7979    0x32    LD (NN), A      b24d        ;  Load location 0xb24d (19890) with the Accumulator
[0x1f2e] 7982    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
[0x1f31] 7985    0x3a    LD A, (NN)      294d        ;  Load Accumulator with location 0x294d (19753)
[0x1f34] 7988    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
[0x1f36] 7990    0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
[0x1f39] 7993    0x47    LD B, A                     ;  Load register B with Accumulator
[0x1f3a] 7994    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
[0x1f3b] 7995    0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
[0x1f3e] 7998    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
[0x1f41] 8001    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
[0x1f43] 8003    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1f44] 8004    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
[0x1f47] 8007    0x78    LD A, B                     ;  Load Accumulator with register B
[0x1f48] 8008    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
[0x1f4b] 8011    0xc9    RET                         ;  Return


;; blue_reverse()
; if ( $4DB3 == 0 ) {  return;  }
; $4DB3 = 0;
; HL = 0x32FF;  // 0x32FF is the table for ghost direction: 0x00, 0xFF ; 0x01, 0x00 ; 0x00, 0x01 ; 0xFF, 0x00
; $4D2E = A = $4D2A ^ 0x02;
; B = A;
; $4D22 = HL = short_load(HL==table, B==index);  // short_load(0x32FF, $4D2A ^ 0x02);
; A = $4E02;
; if ( $4E02 != 0x22 ) {  return;  }
; $4D18 = HL;  // short_load(0x32FF, $4D2A ^ 0x02);
; $4D2A = A = B;  // $4D2A ^ 0x02
; return;
[0x1f4c] 8012    0x3a    LD A, (NN)      b34d        ;  Load Accumulator with location 0xb34d (19891)
[0x1f4f] 8015    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1f50] 8016    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1f51] 8017    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1f52] 8018    0x32    LD (NN), A      b34d        ;  Load location 0xb34d (19891) with the Accumulator
[0x1f55] 8021    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
[0x1f58] 8024    0x3a    LD A, (NN)      2a4d        ;  Load Accumulator with location 0x2a4d (19754)
[0x1f5b] 8027    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
[0x1f5d] 8029    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0x1f60] 8032    0x47    LD B, A                     ;  Load register B with Accumulator
[0x1f61] 8033    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
[0x1f62] 8034    0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
[0x1f65] 8037    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
[0x1f68] 8040    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
[0x1f6a] 8042    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1f6b] 8043    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
[0x1f6e] 8046    0x78    LD A, B                     ;  Load Accumulator with register B
[0x1f6f] 8047    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
[0x1f72] 8050    0xc9    RET                         ;  Return


;; orange_reverse()
; if ( $4DB4 == 0 ) {  return;  }
; $4DB4 = 0;
; HL = 0x32FF;  // 0x32FF is the table for ghost direction: 0x00, 0xFF ; 0x01, 0x00 ; 0x00, 0x01 ; 0xFF, 0x00
; $4D2F = A = $4D2B ^ 0x02;
; B = A;
; $4D24 = HL = short_load(HL==table, B==index);  // short_load(0x32FF, $4D2B ^ 0x02);
; if ( $4E02 != 0x22 ) {  return;  }
; $4D1A = HL;  // short_load(0x32FF, $4D2B ^ 0x02);
; $4D2B = A = B;  // $4D2B ^ 0x02
; return;
[0x1f73] 8051    0x3a    LD A, (NN)      b44d        ;  Load Accumulator with location 0xb44d (19892)
[0x1f76] 8054    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x1f77] 8055    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x1f78] 8056    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x1f79] 8057    0x32    LD (NN), A      b44d        ;  Load location 0xb44d (19892) with the Accumulator
[0x1f7c] 8060    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
[0x1f7f] 8063    0x3a    LD A, (NN)      2b4d        ;  Load Accumulator with location 0x2b4d (19755)
[0x1f82] 8066    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
[0x1f84] 8068    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0x1f87] 8071    0x47    LD B, A                     ;  Load register B with Accumulator
[0x1f88] 8072    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
[0x1f89] 8073    0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
[0x1f8c] 8076    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
[0x1f8f] 8079    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
[0x1f91] 8081    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x1f92] 8082    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
[0x1f95] 8085    0x78    LD A, B                     ;  Load Accumulator with register B
[0x1f96] 8086    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
[0x1f99] 8089    0xc9    RET                         ;  Return


[0x1f9a] 8090    0x00    NOP                         ;  No Operation
[0x1f9b] 8091    0x00    NOP                         ;  No Operation
[0x1f9c] 8092    0x00    NOP                         ;  No Operation
[0x1f9d] 8093    0x00    NOP                         ;  No Operation
[0x1f9e] 8094    0x00    NOP                         ;  No Operation
[0x1f9f] 8095    0x00    NOP                         ;  No Operation
[0x1fa0] 8096    0x00    NOP                         ;  No Operation
[0x1fa1] 8097    0x00    NOP                         ;  No Operation
[0x1fa2] 8098    0x00    NOP                         ;  No Operation
[0x1fa3] 8099    0x00    NOP                         ;  No Operation
[0x1fa4] 8100    0x00    NOP                         ;  No Operation
[0x1fa5] 8101    0x00    NOP                         ;  No Operation
[0x1fa6] 8102    0x00    NOP                         ;  No Operation
[0x1fa7] 8103    0x00    NOP                         ;  No Operation
[0x1fa8] 8104    0x00    NOP                         ;  No Operation
[0x1fa9] 8105    0x00    NOP                         ;  No Operation
[0x1faa] 8106    0x00    NOP                         ;  No Operation
[0x1fab] 8107    0x00    NOP                         ;  No Operation
[0x1fac] 8108    0x00    NOP                         ;  No Operation
[0x1fad] 8109    0x00    NOP                         ;  No Operation
[0x1fae] 8110    0x00    NOP                         ;  No Operation
[0x1faf] 8111    0x00    NOP                         ;  No Operation
[0x1fb0] 8112    0x00    NOP                         ;  No Operation
[0x1fb1] 8113    0x00    NOP                         ;  No Operation
[0x1fb2] 8114    0x00    NOP                         ;  No Operation
[0x1fb3] 8115    0x00    NOP                         ;  No Operation
[0x1fb4] 8116    0x00    NOP                         ;  No Operation
[0x1fb5] 8117    0x00    NOP                         ;  No Operation
[0x1fb6] 8118    0x00    NOP                         ;  No Operation
[0x1fb7] 8119    0x00    NOP                         ;  No Operation
[0x1fb8] 8120    0x00    NOP                         ;  No Operation
[0x1fb9] 8121    0x00    NOP                         ;  No Operation
[0x1fba] 8122    0x00    NOP                         ;  No Operation
[0x1fbb] 8123    0x00    NOP                         ;  No Operation
[0x1fbc] 8124    0x00    NOP                         ;  No Operation
[0x1fbd] 8125    0x00    NOP                         ;  No Operation
[0x1fbe] 8126    0x00    NOP                         ;  No Operation
[0x1fbf] 8127    0x00    NOP                         ;  No Operation
[0x1fc0] 8128    0x00    NOP                         ;  No Operation
[0x1fc1] 8129    0x00    NOP                         ;  No Operation
[0x1fc2] 8130    0x00    NOP                         ;  No Operation
[0x1fc3] 8131    0x00    NOP                         ;  No Operation
[0x1fc4] 8132    0x00    NOP                         ;  No Operation
[0x1fc5] 8133    0x00    NOP                         ;  No Operation
[0x1fc6] 8134    0x00    NOP                         ;  No Operation
[0x1fc7] 8135    0x00    NOP                         ;  No Operation
[0x1fc8] 8136    0x00    NOP                         ;  No Operation
[0x1fc9] 8137    0x00    NOP                         ;  No Operation
[0x1fca] 8138    0x00    NOP                         ;  No Operation
[0x1fcb] 8139    0x00    NOP                         ;  No Operation
[0x1fcc] 8140    0x00    NOP                         ;  No Operation
[0x1fcd] 8141    0x00    NOP                         ;  No Operation
[0x1fce] 8142    0x00    NOP                         ;  No Operation
[0x1fcf] 8143    0x00    NOP                         ;  No Operation
[0x1fd0] 8144    0x00    NOP                         ;  No Operation
[0x1fd1] 8145    0x00    NOP                         ;  No Operation
[0x1fd2] 8146    0x00    NOP                         ;  No Operation
[0x1fd3] 8147    0x00    NOP                         ;  No Operation
[0x1fd4] 8148    0x00    NOP                         ;  No Operation
[0x1fd5] 8149    0x00    NOP                         ;  No Operation
[0x1fd6] 8150    0x00    NOP                         ;  No Operation
[0x1fd7] 8151    0x00    NOP                         ;  No Operation
[0x1fd8] 8152    0x00    NOP                         ;  No Operation
[0x1fd9] 8153    0x00    NOP                         ;  No Operation
[0x1fda] 8154    0x00    NOP                         ;  No Operation
[0x1fdb] 8155    0x00    NOP                         ;  No Operation
[0x1fdc] 8156    0x00    NOP                         ;  No Operation
[0x1fdd] 8157    0x00    NOP                         ;  No Operation
[0x1fde] 8158    0x00    NOP                         ;  No Operation
[0x1fdf] 8159    0x00    NOP                         ;  No Operation
[0x1fe0] 8160    0x00    NOP                         ;  No Operation
[0x1fe1] 8161    0x00    NOP                         ;  No Operation
[0x1fe2] 8162    0x00    NOP                         ;  No Operation
[0x1fe3] 8163    0x00    NOP                         ;  No Operation
[0x1fe4] 8164    0x00    NOP                         ;  No Operation
[0x1fe5] 8165    0x00    NOP                         ;  No Operation
[0x1fe6] 8166    0x00    NOP                         ;  No Operation
[0x1fe7] 8167    0x00    NOP                         ;  No Operation
[0x1fe8] 8168    0x00    NOP                         ;  No Operation
[0x1fe9] 8169    0x00    NOP                         ;  No Operation
[0x1fea] 8170    0x00    NOP                         ;  No Operation
[0x1feb] 8171    0x00    NOP                         ;  No Operation
[0x1fec] 8172    0x00    NOP                         ;  No Operation
[0x1fed] 8173    0x00    NOP                         ;  No Operation

[0x1fee] 8174    0x00    NOP                         ;  No Operation
[0x1fef] 8175    0x00    NOP                         ;  No Operation
[0x1ff0] 8176    0x00    NOP                         ;  No Operation
[0x1ff1] 8177    0x00    NOP                         ;  No Operation
[0x1ff2] 8178    0x00    NOP                         ;  No Operation
[0x1ff3] 8179    0x00    NOP                         ;  No Operation
[0x1ff4] 8180    0x00    NOP                         ;  No Operation
[0x1ff5] 8181    0x00    NOP                         ;  No Operation
[0x1ff6] 8182    0x00    NOP                         ;  No Operation
[0x1ff7] 8183    0x00    NOP                         ;  No Operation
[0x1ff8] 8184    0x00    NOP                         ;  No Operation
[0x1ff9] 8185    0x00    NOP                         ;  No Operation
[0x1ffa] 8186    0x00    NOP                         ;  No Operation
[0x1ffb] 8187    0x00    NOP                         ;  No Operation
[0x1ffc] 8188    0x00    NOP                         ;  No Operation
[0x1ffd] 8189    0x00    NOP                         ;  No Operation

; Checksum: 0x5D, 0xE1


; L = (IY) + (IX);  H = (IY + 1) + (IX + 1);
[0x2000] 8192    0xfd    LD A, (IY+d)    00          ;  Load Accumulator with location ( IY + 0x00 () )
[0x2003] 8195    0xdd    ADD A, (IX+d)   00          ;  Add location ( IX + 0x00 () ) to Accumulator
[0x2006] 8198    0x6f    LD L, A                     ;  Load register L with Accumulator
[0x2007] 8199    0xfd    LD A, (IY+d)    01          ;  Load Accumulator with location ( IY + 0x01 () )
[0x200a] 8202    0xdd    ADD A, (IX+d)   01          ;  Add location ( IX + 0x01 () ) to Accumulator
[0x200d] 8205    0x67    LD H, A                     ;  Load register H with Accumulator
[0x200e] 8206    0xc9    RET                         ;  Return


;;; HL = get_playfield_byte(IY, IX)
;;; Takes an accumulator and an YX coordinate pair from the pointers in IY and IX,
;;; adds them together, and converts the resulting YX coordinates to a memory location
;;; with YX_to_playfieldaddr() (via 101).  The resulting memory location is stored in HL,
;;; and the value at that location is stored in the Accumulator.

;
; HL = YX_to_playfieldaddr($IY + $IX);  // via call_8192();
; A = $HL;
; return; 
[0x200f] 8207    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x2012] 8210    0xcd    CALL NN         6500        ;  Call to 0x6500 (101)
[0x2015] 8213    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
; clear flags
[0x2016] 8214    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
[0x2017] 8215    0xc9    RET                         ;  Return


; L = ( L >> 3 ) + 0x20;
; H = ( H >> 3 ) + 0x1E;
; return;
[0x2018] 8216    0x7d    LD A, L                     ;  Load Accumulator with register L
[0x2019] 8217    0xcb    SRL A                       ;  Shift Accumulator right logical
[0x201b] 8219    0xcb    SRL A                       ;  Shift Accumulator right logical
[0x201d] 8221    0xcb    SRL A                       ;  Shift Accumulator right logical
[0x201f] 8223    0xc6    ADD A, N        20          ;  Add 0x20 (32) to Accumulator (no carry)
[0x2021] 8225    0x6f    LD L, A                     ;  Load register L with Accumulator
[0x2022] 8226    0x7c    LD A, H                     ;  Load Accumulator with register H
[0x2023] 8227    0xcb    SRL A                       ;  Shift Accumulator right logical
[0x2025] 8229    0xcb    SRL A                       ;  Shift Accumulator right logical
[0x2027] 8231    0xcb    SRL A                       ;  Shift Accumulator right logical
[0x2029] 8233    0xc6    ADD A, N        1e          ;  Add 0x1e (30) to Accumulator (no carry)
[0x202b] 8235    0x67    LD H, A                     ;  Load register H with Accumulator
[0x202c] 8236    0xc9    RET                         ;  Return



;;; HL = YX_to_playfield_addr(HL)
;;; Given an YX coordinate pair in HL, determine the memory location on the playfield
;;; and return that location in HL.  Assumes that H and L are both positively biased by
;;; 32.  The lower 5 bits of H become the 5-9 bits of the playfield address offset
;;; and L becomes the lower 5 bits of the playfield address offset.

;; YX_to_playfield_addr(HL)
;; {
;;     HL = 0x4040 + ((H-32)<<5) + (L-32);
;;     return HL;
;; }

; PUSH(AF);  PUSH(BC);
; L -= 32;
; H -= 32;
; BC = H << 5;  // Only for the bottom 5 bits of H, top three are lost
; H = 0;
; // BC = 0x00(H*32), HL = 0x00(L-32)
; HL += BC;
; BC = 0x4040;
; HL += BC;
; POP(BC);  POP(AF);
; return;

[0x202d] 8237    0xf5    PUSH AF                     ;  Load the stack with register pair AF
[0x202e] 8238    0xc5    PUSH BC                     ;  Load the stack with register pair BC
[0x202f] 8239    0x7d    LD A, L                     ;  Load Accumulator with register L
[0x2030] 8240    0xd6    SUB N           20          ;  Subtract 0x20 (32) from Accumulator (no carry)
[0x2032] 8242    0x6f    LD L, A                     ;  Load register L with Accumulator
[0x2033] 8243    0x7c    LD A, H                     ;  Load Accumulator with register H
[0x2034] 8244    0xd6    SUB N           20          ;  Subtract 0x20 (32) from Accumulator (no carry)
[0x2036] 8246    0x67    LD H, A                     ;  Load register H with Accumulator
[0x2037] 8247    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x2039] 8249    0xcb24  SLA H                       ;  Shift left-arithmetic register H
[0x203b] 8251    0xcb24  SLA H                       ;  Shift left-arithmetic register H
[0x203d] 8253    0xcb24  SLA H                       ;  Shift left-arithmetic register H
[0x203f] 8255    0xcb24  SLA H                       ;  Shift left-arithmetic register H
[0x2041] 8257    0xcb10  RL B                        ;  Rotate left through carry register B
[0x2043] 8259    0xcb24  SLA H                       ;  Shift left-arithmetic register H
[0x2045] 8261    0xcb10  RL B                        ;  Rotate left through carry register B
[0x2047] 8263    0x4c    LD C, H                     ;  Load register C with register H
[0x2048] 8264    0x26    LD H, N         00          ;  Load register H with 0x00 (0)
[0x204a] 8266    0x09    ADD HL, BC                  ;  Add register pair BC to HL
[0x204b] 8267    0x01    LD  BC, NN      4040        ;  Load register pair BC with 0x4040 (16448)
[0x204e] 8270    0x09    ADD HL, BC                  ;  Add register pair BC to HL
[0x204f] 8271    0xc1    POP BC                      ;  Load register pair BC with top of stack
[0x2050] 8272    0xf1    POP AF                      ;  Load register pair AF with top of stack
[0x2051] 8273    0xc9    RET                         ;  Return


;;; YX_to_playfield_addr_plus4() // via call_101() -> jump_8237()
;;; See YX_to_playfield_addr() above.
[0x2052] 8274    0xcd    CALL NN         6500        ;  Call to 0x6500 (101)
[0x2055] 8277    0x11    LD  DE, NN      0004        ;  Load register pair DE with 0x0004 (0)
[0x2058] 8280    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x2059] 8281    0xc9    RET                         ;  Return


;;; $BC = ( YX_to_playfieldaddr_plus4() == 0x1B ) ? 0x01 : 0x00;

; YX_to_playfield_addr_plus4(HL)
; A = $HL;
; if ( $HL == 0x1B ) {  $BC = 0x01;  }
;               else {  $BC = 0x01;  }
; return;

[0x205a] 8282    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
[0x205d] 8285    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x205e] 8286    0xfe    CP N            1b          ;  Compare 0x1b (27) with Accumulator
;; 8288-8295 : On Ms. Pac-Man patched in from $8148-$814F
;; On Ms. Pac-Man:
;; 8288  $2060   0xc3    JP nn           6f36        ;  Jump to $nn
;; 8291  $2063   0x00    NOP                         ;  NOP
[0x2060] 8288    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
[0x2062] 8290    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x2064] 8292    0x02    LD  (BC), A                 ;  Load location (BC) with the Accumulator
[0x2065] 8293    0xc9    RET                         ;  Return
[0x2066] 8294    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2067] 8295    0x02    LD  (BC), A                 ;  Load location (BC) with the Accumulator
[0x2068] 8296    0xc9    RET                         ;  Return


;; if ( $4DA1 != 0 ) {  return;  }
;; if ( $4E12 != 0 )
;; {
;;     if ( $4D9F != 0x07 ) {  return;  }
;;     if ( $4D9F == 0x07 ) {  $4DA1 = 2;  return;  }
;; }
;; if ( $4E0F < $4DB8 ) {  return;  }
;; $4DA1 = 2;  return;
[0x2069] 8297    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
[0x206c] 8300    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x206d] 8301    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x206e] 8302    0x3a    LD A, (NN)      124e        ;  Load Accumulator with location 0x124e (19986)
[0x2071] 8305    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2072] 8306    0xca    JP Z,           7e20        ;  Jump to 0x7e20 (8318) if ZERO flag is 1
[0x2075] 8309    0x3a    LD A, (NN)      9f4d        ;  Load Accumulator with location 0x9f4d (19871)
[0x2078] 8312    0xfe    CP N            07          ;  Compare 0x07 (7) with Accumulator
[0x207a] 8314    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x207b] 8315    0xc3    JP NN           8620        ;  Jump to 0x8620 (8326)
[0x207e] 8318    0x21    LD HL, NN       b84d        ;  Load register pair HL with 0xb84d (19896)
[0x2081] 8321    0x3a    LD A, (NN)      0f4e        ;  Load Accumulator with location 0x0f4e (19983)
[0x2084] 8324    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x2085] 8325    0xd8    RET C                       ;  Return if CARRY flag is 1
[0x2086] 8326    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0x2088] 8328    0x32    LD (NN), A      a14d        ;  Load location 0xa14d (19873) with the Accumulator
[0x208b] 8331    0xc9    RET                         ;  Return


;; if ( $4DA2 != 0 ) {  return;  }
;; if ( $4E12 != 0 )  
;; {
;;     if ( $4D9F != 0x11 ) {  return;  }
;;     if ( $4D9F == 0x11 ) {  $4DA2 = 3;  return;  }
;; }
;; if ( $4E10 < $4DB9 ) {  return;  }
;; $4DA2 = 3;  return;
[0x208c] 8332    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
[0x208f] 8335    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2090] 8336    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x2091] 8337    0x3a    LD A, (NN)      124e        ;  Load Accumulator with location 0x124e (19986)
[0x2094] 8340    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2095] 8341    0xca    JP Z,           a120        ;  Jump to 0xa120 (8353) if ZERO flag is 1
[0x2098] 8344    0x3a    LD A, (NN)      9f4d        ;  Load Accumulator with location 0x9f4d (19871)
[0x209b] 8347    0xfe    CP N            11          ;  Compare 0x11 (17) with Accumulator
[0x209d] 8349    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x209e] 8350    0xc3    JP NN           a920        ;  Jump to 0xa920 (8361)
[0x20a1] 8353    0x21    LD HL, NN       b94d        ;  Load register pair HL with 0xb94d (19897)
[0x20a4] 8356    0x3a    LD A, (NN)      104e        ;  Load Accumulator with location 0x104e (19984)
[0x20a7] 8359    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x20a8] 8360    0xd8    RET C                       ;  Return if CARRY flag is 1
[0x20a9] 8361    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0x20ab] 8363    0x32    LD (NN), A      a24d        ;  Load location 0xa24d (19874) with the Accumulator
[0x20ae] 8366    0xc9    RET                         ;  Return


;; if ( $4DA3 != 0 ) {  return;  }
;; if ( $4E12 != 0 )
;; {
;;     if ( $4D9F != 0x20 ) {  return;  }
;;     if ( $4D9F == 0x20 ) {  $4E12 = $4D9F = 0;  return;  }
;; }
;; if ( $4E11 < $4DBA ) {  return;  }
;; $4DA3 = 3;  return;
[0x20af] 8367    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
[0x20b2] 8370    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x20b3] 8371    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x20b4] 8372    0x3a    LD A, (NN)      124e        ;  Load Accumulator with location 0x124e (19986)
[0x20b7] 8375    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x20b8] 8376    0xca    JP Z,           c920        ;  Jump to 0xc920 (8393) if ZERO flag is 1
[0x20bb] 8379    0x3a    LD A, (NN)      9f4d        ;  Load Accumulator with location 0x9f4d (19871)
[0x20be] 8382    0xfe    CP N            20          ;  Compare 0x20 (32) with Accumulator
[0x20c0] 8384    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x20c1] 8385    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x20c2] 8386    0x32    LD (NN), A      124e        ;  Load location 0x124e (19986) with the Accumulator
[0x20c5] 8389    0x32    LD (NN), A      9f4d        ;  Load location 0x9f4d (19871) with the Accumulator
[0x20c8] 8392    0xc9    RET                         ;  Return
[0x20c9] 8393    0x21    LD HL, NN       ba4d        ;  Load register pair HL with 0xba4d (19898)
[0x20cc] 8396    0x3a    LD A, (NN)      114e        ;  Load Accumulator with location 0x114e (19985)
[0x20cf] 8399    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x20d0] 8400    0xd8    RET C                       ;  Return if CARRY flag is 1
[0x20d1] 8401    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
[0x20d3] 8403    0x32    LD (NN), A      a34d        ;  Load location 0xa34d (19875) with the Accumulator
[0x20d6] 8406    0xc9    RET                         ;  Return


;;; set_red_aggression_flags()
;;; Using the thresholds set in $4DBB and $4DBC, set the Red Ghost's aggression 
;;; flags based on the number of dots left.

;; if ( $4DA3 == 0 ) {  return;  }
;; if ( red_aggression_1 == 0 && dots_left < $4DBB )
;; {
;;     red_aggression_1 = 1;
;; }
;; if ( red_aggression_2 == 0 && dots_left < $4DBC )
;; {
;;     red_aggression_2 = 1;
;; }
;; return;

; if ( $4DA3 == 0 ) {  return;  }
; if ( $4DB6 == 0 )
; {
;     if ( $4DBB > (0xF4 - $4E0E) ) {  return;  }  // $4E0E == dots_eaten_so_far
;     $4DB6 = 1;
; }
; if ( $4DB7 != 0 ) {  return;  }
; if ( $4DBC > (0xF4 - $4E0E) ) {  return;  }  // $4E0E == dots_eaten_so_far
; $4DB7 = 1;
; return;

[0x20d7] 8407    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
[0x20da] 8410    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x20db] 8411    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x20dc] 8412    0x21    LD HL, NN       0e4e        ;  Load register pair HL with 0x0e4e (19982)
[0x20df] 8415    0x3a    LD A, (NN)      b64d        ;  Load Accumulator with location 0xb64d (19894)
[0x20e2] 8418    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x20e3] 8419    0xc2    JP NZ, NN       f420        ;  Jump to 0xf420 (8436) if ZERO flag is 0
[0x20e6] 8422    0x3e    LD A,N          f4          ;  Load Accumulator with 0xf4 (244)
[0x20e8] 8424    0x96    SUB A, (HL)                 ;  Subtract location (HL) from Accumulator (no carry)
[0x20e9] 8425    0x47    LD B, A                     ;  Load register B with Accumulator
[0x20ea] 8426    0x3a    LD A, (NN)      bb4d        ;  Load Accumulator with location 0xbb4d (19899)
[0x20ed] 8429    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x20ee] 8430    0xd8    RET C                       ;  Return if CARRY flag is 1
[0x20ef] 8431    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x20f1] 8433    0x32    LD (NN), A      b64d        ;  Load location 0xb64d (19894) with the Accumulator
[0x20f4] 8436    0x3a    LD A, (NN)      b74d        ;  Load Accumulator with location 0xb74d (19895)
[0x20f7] 8439    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x20f8] 8440    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x20f9] 8441    0x3e    LD A,N          f4          ;  Load Accumulator with 0xf4 (244)
[0x20fb] 8443    0x96    SUB A, (HL)                 ;  Subtract location (HL) from Accumulator (no carry)
[0x20fc] 8444    0x47    LD B, A                     ;  Load register B with Accumulator
[0x20fd] 8445    0x3a    LD A, (NN)      bc4d        ;  Load Accumulator with location 0xbc4d (19900)
[0x2100] 8448    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x2101] 8449    0xd8    RET C                       ;  Return if CARRY flag is 1
[0x2102] 8450    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x2104] 8452    0x32    LD (NN), A      b74d        ;  Load location 0xb74d (19895) with the Accumulator
[0x2107] 8455    0xc9    RET                         ;  Return

;; rst_20($4E06);  // Act I Scenes
;; 8456-8463 : On Ms. Pac-Man patched in from $8018-$801F
;; On Ms. Pac-Man:
;; 8456  $2108   0xc3    JP nn           3534        ;  Jump to $nn

[0x2108] 8456    0x3a    LD A, (NN)      064e        ;  Load Accumulator with location 0x064e (19974)
[0x210b] 8459    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : 0x211A (8474) //
; 1 : 0x2140 (8512) //
; 2 : 0x214B (8523) //
; 3 : 0x000C (0012) // return;
; 4 : 0x2170 (8560) //
; 5 : 0x217B (8571) //
; 6 : 0x2186 (8582) //


;; if ( $4D3A == 33 )  // $4D3A == Pacman X
;; {
;;     $4DA0 == $4DB7 = 1;
;;     fill_playfield_rows_11_13_with_FC();  // call_1286();
;;     $4E06++;  // Act I Scenes
;;     return;
;; }
;; else
;; {
;;     call(6150);  call(6150);
;;     call(6966);  call(6966);
;;     call(3619);
;;     return;
;; }
[0x211a] 8474    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
[0x211d] 8477    0xd6    SUB N           21          ;  Subtract 0x21 (33) from Accumulator (no carry)
[0x211f] 8479    0x20    JR NZ, N        0f          ;  Jump relative 0x0f (15) if ZERO flag is 0
[0x2121] 8481    0x3c    INC A                       ;  Increment Accumulator
[0x2122] 8482    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
[0x2125] 8485    0x32    LD (NN), A      b74d        ;  Load location 0xb74d (19895) with the Accumulator
[0x2128] 8488    0xcd    CALL NN         0605        ;  Call to 0x0605 (1286)
[0x212b] 8491    0x21    LD HL, NN       064e        ;  Load register pair HL with 0x064e (19974)
[0x212e] 8494    0x34    INC (HL)                    ;  Increment location (HL)
[0x212f] 8495    0xc9    RET                         ;  Return
[0x2130] 8496    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
[0x2133] 8499    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
[0x2136] 8502    0xcd    CALL NN         361b        ;  Call to 0x361b (6966)
[0x2139] 8505    0xcd    CALL NN         361b        ;  Call to 0x361b (6966)
[0x213c] 8508    0xcd    CALL NN         230e        ;  Call to 0x230e (3619)
[0x213f] 8511    0xc9    RET                         ;  Return


;; if ( $4D3A != 0x1E ) {  jump_8496();  } else {  jump_8491();  }
[0x2140] 8512    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
[0x2143] 8515    0xd6    SUB N           1e          ;  Subtract 0x1e (30) from Accumulator (no carry)
[0x2145] 8517    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
[0x2148] 8520    0xc3    JP NN           2b21        ;  Jump to 0x2b21 (8491)


;; if ( $4D32 != 0x1E ) {  jump_8502();  }
;; call_6768();
;; $4EAC = $4EBC = 0;
;; call_1445();
;; $4D1C = HL;  // HL after call_1445() is the opposite direction "incrementor" from the index at $4D30
;; $4D30 = $4D3C;
;; rst_30(0x45, 0x07, 0x00);
;; jump_8491();
[0x214b] 8523    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
[0x214e] 8526    0xd6    SUB N           1e          ;  Subtract 0x1e (30) from Accumulator (no carry)
[0x2150] 8528    0xc2    JP NZ, NN       3621        ;  Jump to 0x3621 (8502) if ZERO flag is 0
[0x2153] 8531    0xcd    CALL NN         701a        ;  Call to 0x701a (6768)
[0x2156] 8534    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2157] 8535    0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
[0x215a] 8538    0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator
[0x215d] 8541    0xcd    CALL NN         a505        ;  Call to 0xa505 (1445)
[0x2160] 8544    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
[0x2163] 8547    0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
[0x2166] 8550    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
[0x2169] 8553    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x45, 0x07, 0x00 - (something to do with Act I)
[0x216d] 8557    0xc3    JP NN           2b21        ;  Jump to 0x2b21 (8491)


;; if ( $4D32 != 0x2F ) {  jump_8502();  } else {  jump_8491();  }
[0x2170] 8560    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
[0x2173] 8563    0xd6    SUB N           2f          ;  Subtract 0x2f (47) from Accumulator (no carry)
[0x2175] 8565    0xc2    JP NZ, NN       3621        ;  Jump to 0x3621 (8502) if ZERO flag is 0
[0x2178] 8568    0xc3    JP NN           2b21        ;  Jump to 0x2b21 (8491)


;; if ( $4D32 != 0x61 ) {  jump_8496();  } else {  jump_8491();  }
[0x217b] 8571    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
[0x217e] 8574    0xd6    SUB N           3d          ;  Subtract 0x3d (61) from Accumulator (no carry)
[0x2180] 8576    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
[0x2183] 8579    0xc3    JP NN           2b21        ;  Jump to 0x2b21 (8491)


;; call(6150);  call(6150);
;; if ( $4D3A != 0x3D ) {  return;  }
;; $4D06 = 0x00;
;; rst_30(0x45, 0x00, 0x00);
;; $HL++;
;; return;
[0x2186] 8582    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
[0x2189] 8585    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
[0x218c] 8588    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
[0x218f] 8591    0xd6    SUB N           3d          ;  Subtract 0x3d (61) from Accumulator (no carry)
[0x2191] 8593    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x2192] 8594    0x32    LD (NN), A      064e        ;  Load location 0x064e (19974) with the Accumulator
[0x2195] 8597    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x45, 0x00, 0x00
[0x2199] 8601    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x219c] 8604    0x34    INC (HL)                    ;  Increment location (HL)
[0x219d] 8605    0xc9    RET                         ;  Return


;; A = $4E07;  // Act II Scenes
;; IY = $41D2;
;; rst_20();
[0x219e] 8606    0x3a    LD A, (NN)      074e        ;  Load Accumulator with location 0x074e (19975)
;; 8608-8615 : On Ms. Pac-Man patched in from $81A0-$81A7
;; On Ms. Pac-Man:
;; 8609  $21a1   0xc3    JP nn           4f34        ;  Jump to $nn
[0x21a1] 8609    0xfd    LD IY, NN       d241        ;  Load register pair IY with 0xd241 (16850)
[0x21a5] 8613    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : 0x21C2 (8642) //
; 1 : 0x000C (0012) // return;
; 2 : 0x21E1 (8673) //
; 3 : 0x21F5 (8693) //
; 4 : 0x220C (8716) //
; 5 : 0x221E (8734) //
; 6 : 0x2244 (8772) //
; 7 : 0x225D (8797) //
; 8 : 0x000C (0012) // return;
; 9 : 0x226A (8810) //
; 10 : 0x000C (0012) // return;
; 11 : 0x2286 (8838) //
; 12 : 0x000C (0012) // return;
; 13 : 0x228D (8845) //


;; $45F3 = $45F2 = $45D3 = $45D2 = 0x01;
;; fill_playfield_rows_11_13_with_FC();  // call_1286();
[0x21c2] 8642    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x21c4] 8644    0x32    LD (NN), A      d245        ;  Load location 0xd245 (17874) with the Accumulator
[0x21c7] 8647    0x32    LD (NN), A      d345        ;  Load location 0xd345 (17875) with the Accumulator
[0x21ca] 8650    0x32    LD (NN), A      f245        ;  Load location 0xf245 (17906) with the Accumulator
[0x21cd] 8653    0x32    LD (NN), A      f345        ;  Load location 0xf345 (17907) with the Accumulator
[0x21d0] 8656    0xcd    CALL NN         0605        ;  Call to 0x0605 (1286)

; $IY = 0x60;  $(IY+1) = 0x61;  // IY *was* 0x41D2
; rst_30(0x43, 0x08, 0x00);
; $4E07++;  // Act II Scenes
; return;  // this is due to a jump_rel(15);
[0x21d3] 8659    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x60 ()
[0x21d7] 8663    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x61 ()
[0x21db] 8667    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x43, 0x08, 0x00 - (something to do with Act II)
[0x21df] 8671    0x18    JR N            0f          ;  Jump relative 0x0f (15)


; if ( $4D3A != 44 ) {  jump_8496();  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; $4DA0 = $4DB7 = 1;
; $4E07++;  // Act II Scenes
; return;
[0x21e1] 8673    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
[0x21e4] 8676    0xd6    SUB N           2c          ;  Subtract 0x2c (44) from Accumulator (no carry)
[0x21e6] 8678    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
[0x21e9] 8681    0x3c    INC A                       ;  Increment Accumulator
[0x21ea] 8682    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
[0x21ed] 8685    0x32    LD (NN), A      b74d        ;  Load location 0xb74d (19895) with the Accumulator
[0x21f0] 8688    0x21    LD HL, NN       074e        ;  Load register pair HL with 0x074e (19975)
[0x21f3] 8691    0x34    INC (HL)                    ;  Increment location (HL)
[0x21f4] 8692    0xc9    RET                         ;  Return


; if ( $4D01 != 0x77 && $4D01 != 0x78 ) {  jump_8496();  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; $4D4E = $4D50 = 0x2084;
; $4E07++;  // via a jump_rel(-28);  // Act II Scenes
; return;
[0x21f5] 8693    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x21f8] 8696    0xfe    CP N            77          ;  Compare 0x77 (119) with Accumulator
[0x21fa] 8698    0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0x21fc] 8700    0xfe    CP N            78          ;  Compare 0x78 (120) with Accumulator
[0x21fe] 8702    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
[0x2201] 8705    0x21    LD HL, NN       8420        ;  Load register pair HL with 0x8420 (8324)
[0x2204] 8708    0x22    LD (NN), HL     4e4d        ;  Load location 0x4e4d (19790) with the register pair HL
[0x2207] 8711    0x22    LD (NN), HL     504d        ;  Load location 0x504d (19792) with the register pair HL
[0x220a] 8714    0x18    JR N            e4          ;  Jump relative 0xe4 (-28)


; if ( $4D01 == 0x78 )
; {
;     $IY = 0x62;  $(IY+1) = 0x63; // IY *was* 0x41D2
;     $4E07++;  // via a jump_rel(-46);  // Act II Scenes
;     return;
; }
; else {  jump_8759();  }  // call_6150();  call_6150();  call_6966();  call_3619();  return;
[0x220c] 8716    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x220f] 8719    0xd6    SUB N           78          ;  Subtract 0x78 (120) from Accumulator (no carry)
[0x2211] 8721    0xc2    JP NZ, NN       3722        ;  Jump to 0x3722 (8759) if ZERO flag is 0
[0x2214] 8724    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x62 ()
[0x2218] 8728    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x63 ()
[0x221c] 8732    0x18    JR N            d2          ;  Jump relative 0xd2 (-46)


; if ( $4D01 == 123 )
; {
;     $IY = 0x64;  $(IY+1) = 0x65; // IY *was* 0x41D2
;     $(IY+32) = 0x66;  $(IY+33) = 0x67;
;     $4E07++;  // via a jump_rel(-71);  // Act II Scenes
;     return;
; }
[0x221e] 8734    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x2221] 8737    0xd6    SUB N           7b          ;  Subtract 0x7b (123) from Accumulator (no carry)
[0x2223] 8739    0x20    JR NZ, N        12          ;  Jump relative 0x12 (18) if ZERO flag is 0
[0x2225] 8741    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x64 ()
[0x2229] 8745    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x65 ()
[0x222d] 8749    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x20 () ) with 0x66 ()
[0x2231] 8753    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x21 () ) with 0x67 ()
[0x2235] 8757    0x18    JR N            b9          ;  Jump relative 0xb9 (-71)


; call_6150();  call_6150();
; call_6966();
; call_3619();
; return;
[0x2237] 8759    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
[0x223a] 8762    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
[0x223d] 8765    0xcd    CALL NN         361b        ;  Call to 0x361b (6966)
[0x2240] 8768    0xcd    CALL NN         230e        ;  Call to 0x230e (3619)
[0x2243] 8771    0xc9    RET                         ;  Return


; if ( $4D01 != 126 ) {  jump_rel(-20);  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; else
; {
;     $IY = 0x68;  $(IY+1) = 0x69; // IY *was* 0x41D2
;     $(IY+32) = 0x6A;  $(IY+33) = 0x6B;
;     $4E07++;  // via a jump_rel(-109);  // Act II Scenes
;     return;
; }
[0x2244] 8772    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x2247] 8775    0xd6    SUB N           7e          ;  Subtract 0x7e (126) from Accumulator (no carry)
[0x2249] 8777    0x20    JR NZ, N        ec          ;  Jump relative 0xec (-20) if ZERO flag is 0
[0x224b] 8779    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x68 ()
[0x224f] 8783    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x69 ()
[0x2253] 8787    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x20 () ) with 0x6a ()
[0x2257] 8791    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x21 () ) with 0x6b ()
[0x225b] 8795    0x18    JR N            93          ;  Jump relative 0x93 (-109)


; if ( $4D01 != 128 ) {  jump_rel(-45);  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; rst_30(0x4F, 0x08, 0x00);
; $4E07++;  return;  // this is due to a jump_rel(-122);  // Act II Scenes
[0x225d] 8797    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x2260] 8800    0xd6    SUB N           80          ;  Subtract 0x80 (128) from Accumulator (no carry)
[0x2262] 8802    0x20    JR NZ, N        d3          ;  Jump relative 0xd3 (-45) if ZERO flag is 0
[0x2264] 8804    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4F, 0x08, 0x00 - (something to do with Act II)
[0x2268] 8808    0x18    JR N            86          ;  Jump relative 0x86 (-122)


; $4D01 += 2;
; $IY = 0x6C;  $(IY+1) = 0x6D; // IY *was* 0x41D2
; $(IY+32) = 0x40;  $(IY+33) = 0x40;
; rst_30(0x4A, 0x08, 0x00);
; $4E07++;  // Act II Scenes
; return;  // via jump(8688);
[0x226a] 8810    0x21    LD HL, NN       014d        ;  Load register pair HL with 0x014d (19713)
[0x226d] 8813    0x34    INC (HL)                    ;  Increment location (HL)
[0x226e] 8814    0x34    INC (HL)                    ;  Increment location (HL)
[0x226f] 8815    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x6c ()
[0x2273] 8819    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x6d ()
[0x2277] 8823    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x20 () ) with 0x40 ()
[0x227b] 8827    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x21 () ) with 0x40 ()
[0x227f] 8831    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4A, 0x08, 0x00 - (something to do with Act II)
[0x2283] 8835    0xc3    JP NN           f021        ;  Jump to 0xf021 (8688)


; rst_30(0x54, 0x08, 0x00);
; $4E07++;  // Act II Scenes
; return;  // via jump(8688);
[0x2286] 8838    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x08, 0x00 - (something to do with Act II)
[0x228a] 8842    0xc3    JP NN           f021        ;  Jump to 0xf021 (8688)


; $4E07 = 0;   // Act II scenes
; $4E04 += 2;  // Game 'frames'
; return;
[0x228d] 8845    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x228e] 8846    0x32    LD (NN), A      074e        ;  Load location 0x074e (19975) with the Accumulator
[0x2291] 8849    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x2294] 8852    0x34    INC (HL)                    ;  Increment location (HL)
[0x2295] 8853    0x34    INC (HL)                    ;  Increment location (HL)
[0x2296] 8854    0xc9    RET                         ;  Return


; rst_20($4E08);  // Act III Scenes
[0x2297] 8855    0x3a    LD A, (NN)      084e        ;  Load Accumulator with location 0x084e (19976)
;; 8856-8863 : On Ms. Pac-Man patched in from $80A0-$80A7
;; On Ms. Pac-Man:
;; 8858  $229a   0xc3    JP nn           6934        ;  Jump to $nn
[0x229a] 8858    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : 0x22A7 (8871) //
; 1 : 0x22BE (8894) //
; 2 : 0x000C (0012) // return;
; 3 : 0x22DD (8925) //
; 4 : 0x22F5 (8949) //
; 5 : 0x22FE (8958) //


; if ( $4D3A != 37 ) {  jump_8496();  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; $4D0A = $4DB7 = 1;
; fill_playfield_rows_11_13_with_FC();  // call_1286();
; $4E08++; // Act III Scenes
; return;
[0x22a7] 8871    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
[0x22aa] 8874    0xd6    SUB N           25          ;  Subtract 0x25 (37) from Accumulator (no carry)
[0x22ac] 8876    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
[0x22af] 8879    0x3c    INC A                       ;  Increment Accumulator
[0x22b0] 8880    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
[0x22b3] 8883    0x32    LD (NN), A      b74d        ;  Load location 0xb74d (19895) with the Accumulator
[0x22b6] 8886    0xcd    CALL NN         0605        ;  Call to 0x0605 (1286)
[0x22b9] 8889    0x21    LD HL, NN       084e        ;  Load register pair HL with 0x084e (19976)
[0x22bc] 8892    0x34    INC (HL)                    ;  Increment location (HL)
[0x22bd] 8893    0xc9    RET                         ;  Return


; if ( $4D01 != 0xFF && $4D01 != 0xFE ) {  jump_8496();  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; $4D01 = 2;
; $4DB1 = 1;
; call_7934();
; rst_30(0x4A, 0x09, 0x00);
; $4E08++;  // via a jump_rel(-36);  // Act III Scenes
; return;
[0x22be] 8894    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x22c1] 8897    0xfe    CP N            ff          ;  Compare 0xff (255) with Accumulator
[0x22c3] 8899    0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0x22c5] 8901    0xfe    CP N            fe          ;  Compare 0xfe (254) with Accumulator
[0x22c7] 8903    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
[0x22ca] 8906    0x3c    INC A                       ;  Increment Accumulator
[0x22cb] 8907    0x3c    INC A                       ;  Increment Accumulator
[0x22cc] 8908    0x32    LD (NN), A      014d        ;  Load location 0x014d (19713) with the Accumulator
[0x22cf] 8911    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x22d1] 8913    0x32    LD (NN), A      b14d        ;  Load location 0xb14d (19889) with the Accumulator
[0x22d4] 8916    0xcd    CALL NN         fe1e        ;  Call to 0xfe1e (7934)
[0x22d7] 8919    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4A, 0x09, 0x00 - (something to do with Act III)
[0x22db] 8923    0x18    JR N            dc          ;  Jump relative 0xdc (-36)


; if ( $4D32 == 0x2D )
; {
;     $4E08++;  // via a jump_rel(-43);  // Act III Scenes
;     return;
; }
; 
; $4DD2 = $4D00;
; $4DD3 = $4D01 - 8;
; jump(8496);  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
[0x22dd] 8925    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
[0x22e0] 8928    0xd6    SUB N           2d          ;  Subtract 0x2d (45) from Accumulator (no carry)
[0x22e2] 8930    0x28    JR Z, N         d5          ;  Jump relative 0xd5 (-43) if ZERO flag is 1
[0x22e4] 8932    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
[0x22e7] 8935    0x32    LD (NN), A      d24d        ;  Load location 0xd24d (19922) with the Accumulator
[0x22ea] 8938    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
[0x22ed] 8941    0xd6    SUB N           08          ;  Subtract 0x08 (8) from Accumulator (no carry)
[0x22ef] 8943    0x32    LD (NN), A      d34d        ;  Load location 0xd34d (19923) with the Accumulator
[0x22f2] 8946    0xc3    JP NN           3021        ;  Jump to 0x3021 (8496)


; if ( $4D32 == 0x1E ) {  $4E08++;  return;  }  // via a jump_rel(-43);  // Act III Scenes
;                 else {  $4DD2 = $4D00;  $4DD3 = $4D01 - 8;  jump(8496);  }
;                        // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;  // via jump_rel(-26);
[0x22f5] 8949    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
[0x22f8] 8952    0xd6    SUB N           1e          ;  Subtract 0x1e (30) from Accumulator (no carry)
[0x22fa] 8954    0x28    JR Z, N         bd          ;  Jump relative 0xbd (-67) if ZERO flag is 1
[0x22fc] 8956    0x18    JR N            e6          ;  Jump relative 0xe6 (-26)


; $4E08 = 0;  // Act III Scenes;
; rst_30(0x45, 0x00, 0x00);
; $4E04++;
; return;
[0x22fe] 8958    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x22ff] 8959    0x32    LD (NN), A      084e        ;  Load location 0x084e (19976) with the Accumulator
[0x2302] 8962    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x45, 0x00, 0x00
[0x2306] 8966    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
[0x2309] 8969    0x34    INC (HL)                    ;  Increment location (HL)
[0x230a] 8970    0xc9    RET                         ;  Return


;;; boot()
; Clear Memory Mapped Hardware I/O from 0x5000 - 0x5008 with 0x00
;
; for(i=0; i>8; i++)
; {
;     *(0x5000 + i) == 0;
; }
[0x230b] 8971    0x21    LD HL, NN       0050        ;  Load register pair HL with 0x0050 (20480)
[0x230e] 8974    0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
[0x2310] 8976    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2311] 8977    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2312] 8978    0x2c    INC L                       ;  Increment register L
[0x2313] 8979    0x10    DJNZ N          fc          ;  Decrement B and jump relative 0xfc (-4) if B!=0

; Clear Sprite RAM from 0x4000 - 0x43FF with 0x40
;
;
; // A == 0
; for(i=0; i>4; i++)
; {
;     *(watchdog) = A;
;     *(coincounter) = A;
;     for(j=0; j>256; j++)
;     {
;         A = 64;
;         *(4000 + (i*256) + j ) = A;
;     }
; }
[0x2315] 8981    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
[0x2318] 8984    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
; Watchdog set to 0 first time through, then 64 2nd, 3rd, 4th times
[0x231a] 8986    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; Coin Counter set to 0 first time through, then 64 2nd, 3rd, 4th times
[0x231d] 8989    0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
[0x2320] 8992    0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
[0x2322] 8994    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2323] 8995    0x2c    INC L                       ;  Increment register L
[0x2324] 8996    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
[0x2326] 8998    0x24    INC H                       ;  Increment register H
[0x2327] 8999    0x10    DJNZ N          f1          ;  Decrement B and jump relative 0xf1 (-15) if B!=0

; Clear Color RAM from 0x4400 - 0x47FF with 0x0f
;
;
; // A == 64...
; for(i=0; i>4; i++)
; {
;     *(watchdog) = A;
;     A = 0;
;     *(coincounter) = A;
;     for(j=0; j>256; j++)
;     {
;         A = 15;
;         *(4400 + (i*256) + j ) = A;
;     }
; }
[0x2329] 9001    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
; Watchdog set to 64, then 15
[0x232b] 9003    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x232e] 9006    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
; Coin Counter set to 00
[0x232f] 9007    0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
[0x2332] 9010    0x3e    LD A,N          0f          ;  Load Accumulator with 0x0f (15)
[0x2334] 9012    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2335] 9013    0x2c    INC L                       ;  Increment register L
[0x2336] 9014    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
[0x2338] 9016    0x24    INC H                       ;  Increment register H
[0x2339] 9017    0x10    DJNZ N          f0          ;  Decrement B and jump relative 0xf0 (-16) if B!=0

; Set up our interrupt handling scheme
; This sets up interrupt mode 2 (byte on int bus=index into interrupt vector table)
; and configures the external interrupt generator so that each V-Sync drops a value of
; 0xFA (250) onto the interrupt bus.  Since I is set to 0x3F (63), V-Sync calls the
; routine at the address at the location 0x3FFA (16378), which is 0x0030 (48).
; Summary : after this, the routine at 0x0030 (RST 30) is called 60 times a sec.
; Interrupt mode 2 means that the byte on the bus is an index into the 256b page pointed to by I
[0x233b] 9019    0xed    IM 2                        ;  Set interrupt mode 2
; Program the V-Sync interrupt with byte 0xFA (interrupt vector index 250)
[0x233d] 9021    0x3e    LD A,N          fa          ;  Load Accumulator with 0xfa (250)
[0x233f] 9023    0xd3    OUT (N),A       00          ;  Load output port 0x00 (0) with Accumulator
; Coin Counter set to 00
[0x2341] 9025    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2342] 9026    0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
; Enable external interrupt generator
[0x2345] 9029    0x3c    INC A                       ;  Increment Accumulator
[0x2346] 9030    0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
[0x2349] 9033    0xfb    EI                          ;  Enable Interrupts

; Stop here and wait for the next interrupt
[0x234a] 9034    0x76    HALT                        ;  HALT



;;; clear_memory()
; Watchdog set to 0x00, set up stack at 0x4FC0
[0x234b] 9035    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x234e] 9038    0x31    LD SP, NN       c04f        ;  Load register pair SP with 0xc04f (20416)
[0x2351] 9041    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator

; Write 0x00 to 0x5000...0x5007
; ( Int enable, sound enable, ????, flip screen, player 1 lamp, player 2 lamp, coin lockout, coin counter )
[0x2352] 9042    0x21    LD HL, NN       0050        ;  Load register pair HL with 0x0050 (20480)
[0x2355] 9045    0x01    LD  BC, NN      0808        ;  Load register pair BC with 0x0808 (2056)
[0x2358] 9048    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x4C00...0x4CBD
; First 190 bytes of RAM
[0x2359] 9049    0x21    LD HL, NN       004c        ;  Load register pair HL with 0x004c (19456)
[0x235c] 9052    0x06    LD  B, N        be          ;  Load register B with 0xbe (190)
[0x235e] 9054    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x4CBE...0x4DBD ???
; Next 256 bytes of RAM
[0x235f] 9055    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x4DBE...0x4EBD ???
; Next 256 bytes of RAM
[0x2360] 9056    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x4EBE...0x4FBD ???
;Next 256 bytes of RAM
[0x2361] 9057    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x5040...0x507F ???
; Next 256 bytes of RAM
[0x2362] 9058    0x21    LD HL, NN       4050        ;  Load register pair HL with 0x4050 (20544)
[0x2365] 9061    0x06    LD  B, N        40          ;  Load register B with 0x40 (64)
[0x2367] 9063    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Watchdog set to 0x00
[0x2368] 9064    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; Clear Video Color RAM
[0x236b] 9067    0xcd    CALL NN         0d24        ;  Call to 0x0d24 (9229)

; Watchdog set to 0x00
[0x236e] 9070    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x2371] 9073    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x2373] 9075    0xcd    CALL NN         ed23        ;  Call to 0xed23 (9197) [Clear Sprite Mem With Spaces]

; Watchdog set to 0x40
[0x2376] 9078    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator

; Put 0x4CC0 into 0x4C80 and 0x4C82
; Fill 0x4CC0-0x4D00 with 0xFF
[0x2379] 9081    0x21    LD HL, NN       c04c        ;  Load register pair HL with 0xc04c (19648)
[0x237c] 9084    0x22    LD (NN), HL     804c        ;  Load location 0x804c (19584) with the register pair HL
[0x237f] 9087    0x22    LD (NN), HL     824c        ;  Load location 0x824c (19586) with the register pair HL
[0x2382] 9090    0x3e    LD A,N          ff          ;  Load Accumulator with 0xff (255)
[0x2384] 9092    0x06    LD  B, N        40          ;  Load register B with 0x40 (64)
[0x2386] 9094    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Enable V-Sync interrupt circuitry, enable interrupts on CPU
[0x2387] 9095    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x2389] 9097    0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
[0x238c] 9100    0xfb    EI                          ;  Enable Interrupts


;;; queue_watcher()
;;; 9101-9127 implments a very basic shared-memory message passing scheme
;;; 0x4C80 = end of queue
;;; 0x4C82 = beginning of queue
;;; The first byte of a message is an index into a table of memory locations of routines (@9128).  The second
;;; byte is a parameter to pass that routine.  A message box (2 byte block) is identified as holding a
;;; message because the first byte is equal to or less than 0x7F, the maximum allowed value for the
;;; index dereferencing call routine.
;;;
;;; Loop until char at location pointed to by 0x4C82 != 0xff
[0x238d] 9101    0x2a    LD HL, (NN)     824c        ;  Load register pair HL with location 0x824c (19586)
[0x2390] 9104    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2391] 9105    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2392] 9106    0xfa    JP M, NN        8d23        ;  Jump to 0x8d23 (9101) if SIGN flag is 1 (Negative)
; A == index of routine to jump to
[0x2395] 9109    0x36    LD (HL), N      ff          ;  Load location (HL) with 0xff (255)
[0x2397] 9111    0x2c    INC L                       ;  Increment register L
; B == param for routine
[0x2398] 9112    0x46    LD B, (HL)                  ;  Load register B with location (HL)
[0x2399] 9113    0x36    LD (HL), N      ff          ;  Load location (HL) with 0xff (255)
[0x239b] 9115    0x2c    INC L                       ;  Increment register L
; Wrap address at 0x4C82 back to 0x4CC0 if it hits 0x4D00
[0x239c] 9116    0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
[0x239e] 9118    0x2e    LD L,N          c0          ;  Load register L with 0xc0 (192)
[0x23a0] 9120    0x22    LD (NN), HL     824c        ;  Load location 0x824c (19586) with the register pair HL
; load stack backtrace with 'watcher'
[0x23a3] 9123    0x21    LD HL, NN       8d23        ;  Load register pair HL with 0x8d23 (9101)
[0x23a6] 9126    0xe5    PUSH HL                     ;  Load the stack with register pair HL
; Call our routine
[0x23a7] 9127    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)

; Table for RST20 @ 9127
; 00 : 0x23ED - 9197 - clear(); // B==0 entire screen, B==1 playfield
; 01 : 0x24D7 - 9431 - ?
; 02 : 0x2419 - 9241 - draw_maze();
; 03 : 0x2448 - 9288 - restore_dotpowerpillstate();
; 04 : 0x253D - 9533 - ?
; 05 : 0x268B - 9867 - ?
; 06 : 0x240D - 9229 - clear_color()
; 07 : 0x2698 - 9880 - ?
; 08 : 0x2730 - 10032 - 
; 09 : 0x276C - 10092 - 
; 0A : 0x27A9 - 10153 - 
; 0B : 0x27F1 - 10225 - 
; 0C : 0x283B - 10299 - 
; 0D : 0x2865 - 10341 - 
; 0E : 0x288F - 10383 - 
; 0F : 0x28B9 - 10425 - 
; 10 : 0x000D - 13 // jump(1806)
; 11 : 0x26A2 - 9890 - ?
; 12 : 0x24C9 - 9417 - init_dotpowerpillstate()
; 13 : 0x2A35 - 10805 // clear playfield of small, medium and large dots
; 14 : 0x26D0 - 9936 - init_mem_jumper_values()
; 15 : 0x2487 - 9351 - save_dotpowerpillstate()
; 16 : 0x23E8 - 9192 - adv_game_frame();
; 17 : 0x28E3 - 10467 - 
; 18 : 0x2AE0 - 10976 - draw_score();  // DE = location of score
; 19 : 0x2A5A - 10842 - score_event();  // B = score event
; 1A : 0x2B6A - 11114 - ?
; 1B : 0x2BEA - 11242 - draw_fruit()
;; 9184-9191 : On Ms. Pac-Man patched in from $80E8-$80EF
;; On Ms. Pac-Man:
;; 1C : 0x95E3 - ?
; 1C : 0x2C5E - 11358 - write_string(B);
; 1D : 0x2BA1 - 11169 - display_credits_info();
; 1E : 0x2675 - 9845 - ?
; 1F : 0x26B2 - 9906 - draw_bonuspac_points()


; adv_game_frame()
; $4E04++;  return;
[0x23e8] 9192    0x21    LD HL, NN       044E        ;  Load register pair HL with 0x4E04 (19972)
[0x23eb] 9195    0x34    INC (HL)                    ;  Increment location (HL)
[0x23ec] 9196    0xc9    RET                         ;  Return


; clear()
;  -- Clear Screen
;  Branch based on the value of A (see rst 20)
;  A = 0 : Clear entire screen
;  A = 1 : Clear playing field only
[0x23ed] 9197    0x78    LD A, B                     ;  Load Accumulator with register B
[0x23ee] 9198    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $23F3 - clear_sprite()
; 1 : $2400 - clear_sprite_playfield()

; clear_sprite()
; Fill 0x4000-0x43FF (Video RAM) with 0x40 (space)
; Pacman family boards use quasi-ascii, notable difference is 0x40 == <space>
; clear all of screen
[0x23f3] 9203    0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
[0x23f5] 9205    0x01    LD  BC, NN      0400        ;  Load register pair BC with 0x0400 (4)
[0x23f8] 9208    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
[0x23fb] 9211    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
[0x23fc] 9212    0x0d    DEC C                       ;  Decrement register C
[0x23fd] 9213    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is not 0
[0x23ff] 9215    0xc9    RET                         ;  Return

; clear_sprite_playfield()
; Fill 0x4040-0x43BF (Video RAM) with 0x40 (space)
; Pacman family boards use quasi-ascii, notable difference is 0x40 == <space>
; clear the playing field, leave score fields intact
[0x2400] 9216    0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
[0x2402] 9218    0x21    LD HL, NN       4040        ;  Load register pair HL with 0x4040 (16448)
[0x2405] 9221    0x01    LD  BC, NN      0480        ;  Load register pair BC with 0x0480 (32772)
[0x2408] 9224    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
[0x2409] 9225    0x0d    DEC C                       ;  Decrement register C
[0x240a] 9226    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is not 0
[0x240c] 9228    0xc9    RET                         ;  Return

; clear_color()
; Write 0x00 to 0x4400...0x47ff
; Clear Video Color RAM
[0x240d] 9229    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x240e] 9230    0x01    LD  BC, NN      0400        ;  Load register pair BC with 0x0400 (4)
[0x2411] 9233    0x21    LD HL, NN       0044        ;  Load register pair HL with 0x0044 (17408)
[0x2414] 9236    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
[0x2415] 9237    0x0d    DEC C                       ;  Decrement register C
[0x2416] 9238    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is not 0
[0x2418] 9240    0xc9    RET                         ;  Return


;;; draw_maze();
;;; // this function walks through the maze data encoded in the table at 13365 and draws it on the screen
;;; // the table is represented as tile values and "skip" amounts.  In short, any tiles with a value < 128
;;; // are interpreted as being the number of addresses to skip before drawing the next tile (otherwise the
;;; // skip is 1, aka the next tile).  After drawing each tile it calculates the reciprocal address in the
;;; // horizontal mirror image and draws the tile ^ 0x01 (flipped) into that address.  This calculation is 
;;; // tricky and very clever.
;;; //
;;; // This function/table could be improved by being RLE'ed.  (Perhaps this is what mspacman does?)
;;; HL = 0x4000;
;;; for(i=0x3435; $i != 0; i++)
;;; {
;;;     if ( $i < 128 ) {  HL+=i;  $i++;  } else {  HL++;  }
;;;     $HL = i;  (((HL & 0x1F)*2) + 0x83E0 - HL) = i ^ 1;
;;; }
;;;
; low-level version:
; HL = 0x4000;
; BC = 0x3435;  // 13365
; while ( (A = $BC) != 0 )
; {
;     if ( A < 128 )  // sign bit positive
;     {
;         DE = 0x00, A;
;         HL += (DE - 1);  // - 1 to compensate for ++ at 9260
;         BC++;
;         A = $BC;
;     }
;     HL++;
;     $HL = A;
;     push(AF);
;     push(HL);

;;; HL = the bottom 5 bits of HL left-shifted 1 digit + 0x83E0  (- 0x7C1F)
;     DE = 0x83E0;
;     A = L & 0x1F;
;     A += A;
;     HL = 0x00, A;
;     HL += DE;
;     DE = pop();
;     HL -= DE;
;     AF = pop();
;     A ^= 0x01;
;     $HL = A;
;     swap(DE, HL);
;     BC++;
; }
;; 9240-9247 : On Ms. Pac-Man patched in from $8000-$8007
;; 9241 $2419   0x21    LD HL, nn       0040        ;  Load HL (16bit) with nn
;; 9244 $241c   0xcd    CALL nn         6a94        ;  Call $nn
[0x2419] 9241    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
[0x241c] 9244    0x01    LD  BC, NN      3534        ;  Load register pair BC with 0x3534 (13365)
[0x241f] 9247    0x0a    LD  A, (BC)                 ;  Load Accumulator with location (BC)
[0x2420] 9248    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2421] 9249    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2422] 9250    0xfa    JP M, NN        2c24        ;  Jump to 0x2c24 (9260) if SIGN flag is 1 (Negative)
[0x2425] 9253    0x5f    LD E, A                     ;  Load register E with Accumulator
[0x2426] 9254    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x2428] 9256    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x2429] 9257    0x2b    DEC HL                      ;  Decrement register pair HL
[0x242a] 9258    0x03    INC BC                      ;  Increment register pair BC
[0x242b] 9259    0x0a    LD  A, (BC)                 ;  Load Accumulator with location (BC)
[0x242c] 9260    0x23    INC HL                      ;  Increment register pair HL
[0x242d] 9261    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x242e] 9262    0xf5    PUSH AF                     ;  Load the stack with register pair AF
[0x242f] 9263    0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x2430] 9264    0x11    LD  DE, NN      e083        ;  Load register pair DE with 0xe083 (224)
[0x2433] 9267    0x7d    LD A, L                     ;  Load Accumulator with register L
[0x2434] 9268    0xe6    AND N           1f          ;  Bitwise AND of 0x1f (31) to Accumulator
[0x2436] 9270    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x2437] 9271    0x26    LD H, N         00          ;  Load register H with 0x00 (0)
[0x2439] 9273    0x6f    LD L, A                     ;  Load register L with Accumulator
[0x243a] 9274    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x243b] 9275    0xd1    POP DE                      ;  Load register pair DE with top of stack
[0x243c] 9276    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x243d] 9277    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x243f] 9279    0xf1    POP AF                      ;  Load register pair AF with top of stack
[0x2440] 9280    0xee    XOR N           01          ;  Bitwise XOR of 0x01 (1) to Accumulator
[0x2442] 9282    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2443] 9283    0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x2444] 9284    0x03    INC BC                      ;  Increment register pair BC
[0x2445] 9285    0xc3    JP NN           1f24        ;  Jump to 0x1f24 (9247)


;;; restore_dotpowerpillstate();
;;; Based on the 30 byte bitmask in 4E16-4E33 multiplexed by the "incrementor" table at 0x35B5 (13749),
;;; draw the dots that have not yet been eaten, then draw the powerpills based on their status in $4E34-$4E37
; HL = 0x4000;
; IX = 0x4E16;
; IY = 0x35B5; // 0x62, 0x01, 0x02, 0x01, 0x01, 0x01, 0x01, 0x0c,...
; for(B=0x1E; B!=0; B--)
; {
;     A = $IX;
;     for(C=8; C!=0;C--)
;     {
;         HL += $IY;
;         A <<= 1;
;         if ( ! CARRY ) {  $HL = 0x10;  }
;         IY++;
;     }
;     IX++;
; }
; $4064 = $4E34;
; $4078 = $4E35;
; $4384 = $4E36;
; $4398 = $4E37;
; return;
;; 9288-9295 : On Ms. Pac-Man patched in from $8058-$805F
;; 9288  $2448   0x21    LD HL, nn       0040        ;  Load HL (16bit) with nn
;; 9291  $244b   0xc3    JP nn           7c94        ;  Jump to $nn
[0x2448] 9288    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
[0x244b] 9291    0xdd    LD IX, NN       164e        ;  Load register pair IX with 0x164e (19990)
[0x244f] 9295    0xfd    LD IY, NN       b535        ;  Load register pair IY with 0xb535 (13749)
[0x2453] 9299    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x2455] 9301    0x06    LD  B, N        1e          ;  Load register B with 0x1e (30)
[0x2457] 9303    0x0e    LD  C, N        08          ;  Load register C with 0x08 (8)
[0x2459] 9305    0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
[0x245c] 9308    0xfd    LD E, (IY + N)  00          ;  Load register E with location ( IY + 0x00 () )
[0x245f] 9311    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x2460] 9312    0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2461] 9313    0x30    JR NC, N        02          ;  Jump relative 0x02 (2) if CARRY flag is 0
[0x2463] 9315    0x36    LD (HL), N      10          ;  Load register pair HL with 0x10 (16)
[0x2465] 9317    0xfd    INC IY                      ;  Increment register pair IY
[0x2467] 9319    0x0d    DEC C                       ;  Decrement register C
[0x2468] 9320    0x20    JR NZ, N        f2          ;  Jump relative 0xf2 (-14) if ZERO flag is 0
[0x246a] 9322    0xdd    INC IX                      ;  Increment register pair IX
[0x246c] 9324    0x05    DEC B                       ;  Decrement register B
[0x246d] 9325    0x20    JR NZ, N        e8          ;  Jump relative 0xe8 (-24) if ZERO flag is 0
[0x246f] 9327    0x21    LD HL, NN       344e        ;  Load register pair HL with 0x344e (20020)
;; 9328-9335 : On Ms. Pac-Man patched in from $8140-$8147
;; 9330  $2472   0xc3    JP nn           ec94        ;  Jump to $nn
[0x2472] 9330    0x11    LD  DE, NN      6440        ;  Load register pair DE with 0x6440 (100)
[0x2475] 9333    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
[0x2477] 9335    0x11    LD  DE, NN      7840        ;  Load register pair DE with 0x7840 (120)
[0x247a] 9338    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
[0x247c] 9340    0x11    LD  DE, NN      8443        ;  Load register pair DE with 0x8443 (132)
[0x247f] 9343    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
[0x2481] 9345    0x11    LD  DE, NN      9843        ;  Load register pair DE with 0x9843 (152)
[0x2484] 9348    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
[0x2486] 9350    0xc9    RET                         ;  Return


;;; save_dotpowerpillstate();  // see above
; HL = 0x4000;
; IX = 0x4E16;
; IY = 0x35B5; // 0x62, 0x01, 0x02, 0x01, 0x01, 0x01, 0x01, 0x0c,...
; for(B=0x1E; B!=0; B--)
; {
;     for(C=8; C!=0;C--)
;     {
;         HL += $IY;
;         CARRY = ($HL == 16) ? 1 : 0;
;         $IX c<<= 1;
;         IY++;
;     }
;     IX++;
; }
; $4E34 = $4064;
; $4E35 = $4078;
; $4E36 = $4384;
; $4E37 = $4398;
; return;
[0x2487] 9351    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
;; 9352-9359 : On Ms. Pac-Man patched in from $8080-$8087
;; 9354  $248a   0xc3    JP nn           8194        ;  Jump to $nn
[0x248a] 9354    0xdd    LD IX, NN       164e        ;  Load register pair IX with 0x164e (19990)
[0x248e] 9358    0xfd    LD IY, NN       b535        ;  Load register pair IY with 0xb535 (13749)
[0x2492] 9362    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x2494] 9364    0x06    LD  B, N        1e          ;  Load register B with 0x1e (30)
[0x2496] 9366    0x0e    LD  C, N        08          ;  Load register C with 0x08 (8)
[0x2498] 9368    0xfd    LD E, (IY + N)  00          ;  Load register E with location ( IY + 0x00 () )
[0x249b] 9371    0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x249c] 9372    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x249d] 9373    0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
[0x249f] 9375    0x37    SCF                         ;  Set CARRY flag
[0x24a0] 9376    0x28    JR Z, N         01          ;  Jump relative 0x01 (1) if ZERO flag is 1
[0x24a2] 9378    0x3f    CCF                         ;  Complement CARRY flag
[0x24a3] 9379    0xdd    LD B,RLC (IX+d) 16          ;  Load IX + 0x00 with A rotated left-circular B-times
[0x24a7] 9383    0xfd    INC IY                      ;  Increment register pair IY
[0x24a9] 9385    0x0d    DEC C                       ;  Decrement register C
[0x24aa] 9386    0x20    JR NZ, N        ec          ;  Jump relative 0xec (-20) if ZERO flag is 0
[0x24ac] 9388    0xdd    INC IX                      ;  Increment register pair IX
[0x24ae] 9390    0x05    DEC B                       ;  Decrement register B
[0x24af] 9391    0x20    JR NZ, N        e5          ;  Jump relative 0xe5 (-27) if ZERO flag is 0
[0x24b1] 9393    0x21    LD HL, NN       6440        ;  Load register pair HL with 0x6440 (16484)
;; 9392-9399 : On Ms. Pac-Man patched in from $8180-$8187
;; 9396  $24b4   0xc3    JP nn           0495        ;  Jump to $nn
[0x24b4] 9396    0x11    LD  DE, NN      344e        ;  Load register pair DE with 0x344e (52)
[0x24b7] 9399    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
[0x24b9] 9401    0x21    LD HL, NN       7840        ;  Load register pair HL with 0x7840 (16504)
[0x24bc] 9404    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
[0x24be] 9406    0x21    LD HL, NN       8443        ;  Load register pair HL with 0x8443 (17284)
[0x24c1] 9409    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
[0x24c3] 9411    0x21    LD HL, NN       9843        ;  Load register pair HL with 0x9843 (17304)
[0x24c6] 9414    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
[0x24c8] 9416    0xc9    RET                         ;  Return


;;; init_dotpowerpillstate();
; Fill $4E16-$4E33 with 0xFF
[0x24c9] 9417    0x21    LD HL, NN       164e        ;  Load register pair HL with 0x164e (19990)
[0x24cc] 9420    0x3e    LD A,N          ff          ;  Load Accumulator with 0xff (255)
[0x24ce] 9422    0x06    LD  B, N        1e          ;  Load register B with 0x1e (30)
[0x24d0] 9424    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
; Fill $4D34-$4D37 with 0x14
[0x24d1] 9425    0x3e    LD A,N          14          ;  Load Accumulator with 0x14 (20)
[0x24d3] 9427    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
[0x24d5] 9429    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
[0x24d6] 9430    0xc9    RET                         ;  Return


;;; weirdblock_init_screen(E)
; if ( E == 2 ) {  $4440..$47BF = 0x1F;  }  // playfield color RAM
;          else {  $4440..$47BF = 0x10;  }
; $47C0..$47FF = 0x0F;  // screen top color RAM
; if ( E != 1 ) {  return;  }
; // actually a loop, clears two horizontal lines,
; // 6 sprites across, one and two thirds down the screenO
; $45AC = $45B8 = 0x26;
; $45CC = $45D8 = 0x26;
; $45EC = $45F8 = 0x26;
; $450C = $4518 = 0x26;
; $452C = $4538 = 0x26;
; $454C = $4558 = 0x1A;
; // another loop, clears 5x3 block in the far right, center of screen
; $444E = $444F = $4450 = 0x1B;
; $446E = $446F = $4470 = 0x1B;
; $448E = $448F = $4490 = 0x1B;
; $44AE = $44AF = $44B0 = 0x1B;
; $44CE = $44CF = $44D0 = 0x1B;
; // another loop, clears 5x3 block in the far left, center of screen
; $472E = $472F = $4730 = 0x1B;
; $474E = $474F = $4750 = 0x1B;
; $476E = $476F = $4770 = 0x1B;
; $478E = $478F = $4790 = 0x1B;
; $47AE = $47AF = $47B0 = 0x1B;
; // two sprites near the dead center of the screen
; $460D = $45ED = 0x18;
; return;
[0x24d7] 9431    0x58    LD E, B                     ;  Load register E with register B
[0x24d8] 9432    0x78    LD A, B                     ;  Load Accumulator with register B
[0x24d9] 9433    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
[0x24db] 9435    0x3e    LD A,N          1f          ;  Load Accumulator with 0x1f (31)
;; 9432-9439 : On Ms. Pac-Man patched in from $80C0-$80C7
;; 9437  $24dd   0xc3    JP nn           8095        ;  Jump to $nn
[0x24dd] 9437    0x28    JR Z, N         02          ;  Jump relative 0x02 (2) if ZERO flag is 1
[0x24df] 9439    0x3e    LD A,N          10          ;  Load Accumulator with 0x10 (16)
[0x24e1] 9441    0x21    LD HL, NN       4044        ;  Load register pair HL with 0x4044 (17472)
[0x24e4] 9444    0x01    LD  BC, NN      0480        ;  Load register pair BC with 0x0480 (32772)
[0x24e7] 9447    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
[0x24e8] 9448    0x0d    DEC C                       ;  Decrement register C
[0x24e9] 9449    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
[0x24eb] 9451    0x3e    LD A,N          0f          ;  Load Accumulator with 0x0f (15)
[0x24ed] 9453    0x06    LD  B, N        40          ;  Load register B with 0x40 (64)
[0x24ef] 9455    0x21    LD HL, NN       c047        ;  Load register pair HL with 0xc047 (18368)
[0x24f2] 9458    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
[0x24f3] 9459    0x7b    LD A, E                     ;  Load Accumulator with register E
[0x24f4] 9460    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x24f6] 9462    0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x24f7] 9463    0x3e    LD A,N          1a          ;  Load Accumulator with 0x1a (26)
;; 9464-9471 : On Ms. Pac-Man patched in from $81C0-$81C7
;; 9465  $24f9   0xc3    JP nn           c395        ;  Jump to $nn
[0x24f9] 9465    0x11    LD  DE, NN      2000        ;  Load register pair DE with 0x2000 (32)
[0x24fc] 9468    0x06    LD  B, N        06          ;  Load register B with 0x06 (6)
;; 9470  $24fe   0xdd21  LD IY, nn       084d        ;  Load (16bit) IY with nn
[0x24fe] 9470    0xdd    LD IX, NN       a045        ;  Load register pair IX with 0xa045 (17824)
[0x2502] 9474    0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
[0x2505] 9477    0xdd    LD (IX+d), A    18          ;  Load location ( IX + 0x18 () ) with Accumulator
[0x2508] 9480    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x250a] 9482    0x10    DJNZ N          f6          ;  Decrement B and jump relative 0xf6 (-10) if B!=0
[0x250c] 9484    0x3e    LD A,N          1b          ;  Load Accumulator with 0x1b (27)
[0x250e] 9486    0x06    LD  B, N        05          ;  Load register B with 0x05 (5)
[0x2510] 9488    0xdd    LD IX, NN       4044        ;  Load register pair IX with 0x4044 (17472)
[0x2514] 9492    0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
[0x2517] 9495    0xdd    LD (IX+d), A    0f          ;  Load location ( IX + 0x0f () ) with Accumulator
[0x251a] 9498    0xdd    LD (IX+d), A    10          ;  Load location ( IX + 0x10 () ) with Accumulator
[0x251d] 9501    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x251f] 9503    0x10    DJNZ N          f3          ;  Decrement B and jump relative 0xf3 (-13) if B!=0
[0x2521] 9505    0x06    LD  B, N        05          ;  Load register B with 0x05 (5)
[0x2523] 9507    0xdd    LD IX, NN       2047        ;  Load register pair IX with 0x2047 (18208)
[0x2527] 9511    0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
[0x252a] 9514    0xdd    LD (IX+d), A    0f          ;  Load location ( IX + 0x0f () ) with Accumulator
[0x252d] 9517    0xdd    LD (IX+d), A    10          ;  Load location ( IX + 0x10 () ) with Accumulator
[0x2530] 9520    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x2532] 9522    0x10    DJNZ N          f3          ;  Decrement B and jump relative 0xf3 (-13) if B!=0
[0x2534] 9524    0x3e    LD A,N          18          ;  Load Accumulator with 0x18 (24)
[0x2536] 9526    0x32    LD (NN), A      ed45        ;  Load location 0xed45 (17901) with the Accumulator
[0x2539] 9529    0x32    LD (NN), A      0d46        ;  Load location 0x0d46 (17933) with the Accumulator
[0x253c] 9532    0xc9    RET                         ;  Return


; Initialize 4C02-4C0D with params?  indexes?
; Initialize 4D00-4DD2 with data
[0x253d] 9533    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
[0x2541] 9537    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x20 ()
[0x2545] 9541    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x04 () ) with 0x20 ()
[0x2549] 9545    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x06 () ) with 0x20 ()
[0x254d] 9549    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x08 () ) with 0x20 ()
[0x2551] 9553    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x2c ()
[0x2555] 9557    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0c () ) with 0x3f ()
[0x2559] 9561    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x03 () ) with 0x01 ()
[0x255d] 9565    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x03 ()
[0x2561] 9569    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x05 ()
[0x2565] 9573    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x07 ()
[0x2569] 9577    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0b () ) with 0x09 ()
[0x256d] 9581    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0d () ) with 0x00 ()
[0x2571] 9585    0x78    LD A, B                     ;  Load Accumulator with register B
[0x2572] 9586    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2573] 9587    0xc2    JP NZ, NN       0f26        ;  Jump to 0x0f26 (9743) if ZERO flag is 0
[0x2576] 9590    0x21    LD HL, NN       6480        ;  Load register pair HL with 0x6480 (32868)
[0x2579] 9593    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
[0x257c] 9596    0x21    LD HL, NN       7c80        ;  Load register pair HL with 0x7c80 (32892)
[0x257f] 9599    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
[0x2582] 9602    0x21    LD HL, NN       7c90        ;  Load register pair HL with 0x7c90 (36988)
[0x2585] 9605    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
[0x2588] 9608    0x21    LD HL, NN       7c70        ;  Load register pair HL with 0x7c70 (28796)
[0x258b] 9611    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
[0x258e] 9614    0x21    LD HL, NN       c480        ;  Load register pair HL with 0xc480 (32964)
[0x2591] 9617    0x22    LD (NN), HL     084d        ;  Load location 0x084d (19720) with the register pair HL
[0x2594] 9620    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
[0x2597] 9623    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
[0x259a] 9626    0x22    LD (NN), HL     314d        ;  Load location 0x314d (19761) with the register pair HL
[0x259d] 9629    0x21    LD HL, NN       2f2e        ;  Load register pair HL with 0x2f2e (11823)
[0x25a0] 9632    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
[0x25a3] 9635    0x22    LD (NN), HL     334d        ;  Load location 0x334d (19763) with the register pair HL
[0x25a6] 9638    0x21    LD HL, NN       2f30        ;  Load register pair HL with 0x2f30 (12335)
[0x25a9] 9641    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
[0x25ac] 9644    0x22    LD (NN), HL     354d        ;  Load location 0x354d (19765) with the register pair HL
[0x25af] 9647    0x21    LD HL, NN       2f2c        ;  Load register pair HL with 0x2f2c (11311)
[0x25b2] 9650    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
[0x25b5] 9653    0x22    LD (NN), HL     374d        ;  Load location 0x374d (19767) with the register pair HL
[0x25b8] 9656    0x21    LD HL, NN       382e        ;  Load register pair HL with 0x382e (11832)
[0x25bb] 9659    0x22    LD (NN), HL     124d        ;  Load location 0x124d (19730) with the register pair HL
[0x25be] 9662    0x22    LD (NN), HL     394d        ;  Load location 0x394d (19769) with the register pair HL
[0x25c1] 9665    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
[0x25c4] 9668    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
[0x25c7] 9671    0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
[0x25ca] 9674    0x21    LD HL, NN       0100        ;  Load register pair HL with 0x0100 (1)
[0x25cd] 9677    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
[0x25d0] 9680    0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
[0x25d3] 9683    0x21    LD HL, NN       ff00        ;  Load register pair HL with 0xff00 (255)
[0x25d6] 9686    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
[0x25d9] 9689    0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
[0x25dc] 9692    0x21    LD HL, NN       ff00        ;  Load register pair HL with 0xff00 (255)
[0x25df] 9695    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
[0x25e2] 9698    0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
[0x25e5] 9701    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
[0x25e8] 9704    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
[0x25eb] 9707    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
[0x25ee] 9710    0x21    LD HL, NN       0201        ;  Load register pair HL with 0x0201 (258)
[0x25f1] 9713    0x22    LD (NN), HL     284d        ;  Load location 0x284d (19752) with the register pair HL
[0x25f4] 9716    0x22    LD (NN), HL     2c4d        ;  Load location 0x2c4d (19756) with the register pair HL
[0x25f7] 9719    0x21    LD HL, NN       0303        ;  Load register pair HL with 0x0303 (771)
[0x25fa] 9722    0x22    LD (NN), HL     2a4d        ;  Load location 0x2a4d (19754) with the register pair HL
[0x25fd] 9725    0x22    LD (NN), HL     2e4d        ;  Load location 0x2e4d (19758) with the register pair HL
[0x2600] 9728    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0x2602] 9730    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
[0x2605] 9733    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
[0x2608] 9736    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
[0x260b] 9739    0x22    LD (NN), HL     d24d        ;  Load location 0xd24d (19922) with the register pair HL
[0x260e] 9742    0xc9    RET                         ;  Return

; Load 4D00-4D3C (fragmented) with data
[0x260f] 9743    0x21    LD HL, NN       9400        ;  Load register pair HL with 0x9400 (148)
[0x2612] 9746    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
[0x2615] 9749    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
[0x2618] 9752    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
[0x261b] 9755    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
[0x261e] 9758    0x21    LD HL, NN       321e        ;  Load register pair HL with 0x321e (7730)
[0x2621] 9761    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
[0x2624] 9764    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
[0x2627] 9767    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
[0x262a] 9770    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
[0x262d] 9773    0x22    LD (NN), HL     314d        ;  Load location 0x314d (19761) with the register pair HL
[0x2630] 9776    0x22    LD (NN), HL     334d        ;  Load location 0x334d (19763) with the register pair HL
[0x2633] 9779    0x22    LD (NN), HL     354d        ;  Load location 0x354d (19765) with the register pair HL
[0x2636] 9782    0x22    LD (NN), HL     374d        ;  Load location 0x374d (19767) with the register pair HL
[0x2639] 9785    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
[0x263c] 9788    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
[0x263f] 9791    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
[0x2642] 9794    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
[0x2645] 9797    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
[0x2648] 9800    0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
[0x264b] 9803    0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
[0x264e] 9806    0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
[0x2651] 9809    0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
[0x2654] 9812    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
[0x2657] 9815    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
; Fill $4D28-$4D30 with 0x02
[0x265a] 9818    0x21    LD HL, NN       284d        ;  Load register pair HL with 0x284d (19752)
[0x265d] 9821    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0x265f] 9823    0x06    LD  B, N        09          ;  Load register B with 0x09 (9)
[0x2661] 9825    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
[0x2662] 9826    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
[0x2665] 9829    0x21    LD HL, NN       9408        ;  Load register pair HL with 0x9408 (2196)
[0x2668] 9832    0x22    LD (NN), HL     084d        ;  Load location 0x084d (19720) with the register pair HL
[0x266b] 9835    0x21    LD HL, NN       321f        ;  Load register pair HL with 0x321f (7986)
[0x266e] 9838    0x22    LD (NN), HL     124d        ;  Load location 0x124d (19730) with the register pair HL
[0x2671] 9841    0x22    LD (NN), HL     394d        ;  Load location 0x394d (19769) with the register pair HL
[0x2674] 9844    0xc9    RET                         ;  Return

; Clear 0x4D00-0x4D09,0x4DD2-0x4DD3
[0x2675] 9845    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
[0x2678] 9848    0x22    LD (NN), HL     d24d        ;  Load location 0xd24d (19922) with the register pair HL
[0x267b] 9851    0x22    LD (NN), HL     084d        ;  Load location 0x084d (19720) with the register pair HL
[0x267e] 9854    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
[0x2681] 9857    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
[0x2684] 9860    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
[0x2687] 9863    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
[0x268a] 9866    0xc9    RET                         ;  Return


; $4D94 = 0x55;
; if ( --B ) $4DA0 = 0x01;
; return;
[0x268b] 9867    0x3e    LD A,N          55          ;  Load Accumulator with 0x55 (85)
[0x268d] 9869    0x32    LD (NN), A      944d        ;  Load location 0x944d (19860) with the Accumulator
[0x2690] 9872    0x05    DEC B                       ;  Decrement register B
[0x2691] 9873    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2692] 9874    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x2694] 9876    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
[0x2697] 9879    0xc9    RET                         ;  Return


; $4E00 = 1;
; $4E01 = 0;
; return;
[0x2698] 9880    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x269a] 9882    0x32    LD (NN), A      004e        ;  Load location 0x004e (19968) with the Accumulator
[0x269d] 9885    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x269e] 9886    0x32    LD (NN), A      014e        ;  Load location 0x014e (19969) with the Accumulator
[0x26a1] 9889    0xc9    RET                         ;  Return


; Clear 0x4D00-0x4EFF
[0x26a2] 9890    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x26a3] 9891    0x11    LD  DE, NN      004d        ;  Load register pair DE with 0x004d (0)
[0x26a6] 9894    0x21    LD HL, NN       004e        ;  Load register pair HL with 0x004e (19968)
[0x26a9] 9897    0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
[0x26aa] 9898    0x13    INC DE                      ;  Increment register pair DE
[0x26ab] 9899    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to location (HL)
[0x26ac] 9900    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x26ae] 9902    0xc2    JP NZ, NN       a626        ;  Jump to 0xa626 (9894) if ZERO flag is 0
[0x26b1] 9905    0xc9    RET                         ;  Return


;;; draw_bonuspac_points()
; Display bonus pac points based on stored variable
; $4156, $4136 - Screen location for 10/15/20/blank Kpts for bonus
[0x26b2] 9906    0xdd    LD IX, NN       3641        ;  Load register pair IX with 0x3641 (16694)
; $4E71 = Kilopoints for bonus pac in BCD. ( 10 | 15 | 20 | FF ).  FF = no bonus
[0x26b6] 9910    0x3a    LD A, (NN)      714e        ;  Load Accumulator with location 0x714e (20081)
; decode BCD in $4E71 and place corresponding ascii chars for the digits in $4136 ( thousands )
; and $4156 ( ten thousands )
[0x26b9] 9913    0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x26bb] 9915    0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
[0x26bd] 9917    0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
[0x26c0] 9920    0x3a    LD A, (NN)      714e        ;  Load Accumulator with location 0x714e (20081)
[0x26c3] 9923    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26c4] 9924    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26c5] 9925    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26c6] 9926    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26c7] 9927    0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x26c9] 9929    0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x26ca] 9930    0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
[0x26cc] 9932    0xdd    LD (IX+d), A    20          ;  Load location ( IX + 0x20 () ) with Accumulator
[0x26cf] 9935    0xc9    RET                         ;  Return

;;; init_mem_jumper_values()
; Set up memory with jumper values
; $5080:0,1 : Coins/Credits
;   0 = Free Play
;   1 = 1 Coin/1 Credit
;   2 = 1 Coin/2 Credits
;   3 = 2 Coins/1 Credit
[0x26d0] 9936    0x3a    LD A, (NN)      8050        ;  Load Accumulator with location 0x8050 (20608)
[0x26d3] 9939    0x47    LD B, A                     ;  Load register B with Accumulator
[0x26d4] 9940    0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
; If zero, set credits ( $4E6E ) to 0xFF
[0x26d6] 9942    0xc2    JP NZ, NN       de26        ;  Jump to 0xde26 (9950) if ZERO flag is 0
[0x26d9] 9945    0x21    LD HL, NN       6e4e        ;  Load register pair HL with 0x6e4e (20078)
[0x26dc] 9948    0x36    LD (HL), N      ff          ;  Load register pair HL with 0xff (255)
; bizzare bit of bit fiddling means $4E6B and $4E6D contain the coin to credits relationship,
; respectively.  ie, 1 coin/2 credits means $4E6B=1, $4E6D=2, etc.  Both equal 0 for freeplay.
[0x26de] 9950    0x4f    LD c, A                     ;  Load register C with Accumulator
[0x26df] 9951    0x1f    RRA                         ;  Rotate right Accumulator through carry
[0x26e0] 9952    0xce    ADC A, N        00          ;  Add with carry 0x00 (0) to Accumulator
[0x26e2] 9954    0x32    LD (NN), A      6b4e        ;  Load location 0x6b4e (20075) with the Accumulator
[0x26e5] 9957    0xe6    AND N           02          ;  Bitwise AND of 0x02 (2) to Accumulator
[0x26e7] 9959    0xa9    XOR A, C                    ;  Bitwise XOR of register C to Accumulator
[0x26e8] 9960    0x32    LD (NN), A      6d4e        ;  Load location 0x6d4e (20077) with the Accumulator
; $5080:2,3 : Lives per game
;   0 = 1 Lives
;   1 = 2 Lives
;   2 = 3 Lives
;   3 = 5 Lives
; Set $4E6F to 1/2/3/5 Lives per game
[0x26eb] 9963    0x78    LD A, B                     ;  Load Accumulator with register B
[0x26ec] 9964    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26ed] 9965    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26ee] 9966    0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
[0x26f0] 9968    0x3c    INC A                       ;  Increment Accumulator
[0x26f1] 9969    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
[0x26f3] 9971    0x20    JR NZ, N        01          ;  Jump relative 0x01 (1) if ZERO flag is 0
[0x26f5] 9973    0x3c    INC A                       ;  Increment Accumulator
[0x26f6] 9974    0x32    LD (NN), A      6f4e        ;  Load location 0x6f4e (20079) with the Accumulator
; $5080:4,5 : Bonus Pac @ ...
;   0 = 10000 points
;   1 = 15000 points
;   2 = 20000 points
;   3 = None
; Set $4E71 to BCD of bonus pac points, indexed into a table at $2728
[0x26f9] 9977    0x78    LD A, B                     ;  Load Accumulator with register B
[0x26fa] 9978    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26fb] 9979    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26fc] 9980    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26fd] 9981    0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x26fe] 9982    0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
[0x2700] 9984    0x21    LD HL, NN       2827        ;  Load register pair HL with 0x2827 (10024)
[0x2703] 9987    0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
[0x2704] 9988    0x32    LD (NN), A      714e        ;  Load location 0x714e (20081) with the Accumulator
; $5080:7 : Ghost Names
;   0 = Alternative
;   1 = Normal
; Set $4E75 to the ! of the ghost name jumper ( ie. 1 = alternative, 0 = normal )
[0x2707] 9991    0x78    LD A, B                     ;  Load Accumulator with register B
[0x2708] 9992    0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2709] 9993    0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x270a] 9994    0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
[0x270c] 9996    0x32    LD (NN), A      754e        ;  Load location 0x754e (20085) with the Accumulator
; $5080:6 : Difficulty
;   0 = Hard
;   1 = Normal
; Set $4E73 to 0x6800 for normal, 0x7D00 for difficult
[0x270f] 9999    0x78    LD A, B                     ;  Load Accumulator with register B
[0x2710] 10000   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2711] 10001   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2712] 10002   0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x2713] 10003   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
[0x2715] 10005   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2716] 10006   0x21    LD HL, NN       2c27        ;  Load register pair HL with 0x2c27 (10028)
[0x2719] 10009   0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
[0x271a] 10010   0x22    LD (NN), HL     734e        ;  Load location 0x734e (20083) with the register pair HL
; $5040:7
;   0 = Cocktail
;   1 = Upright
[0x271d] 10013   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x2720] 10016   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2721] 10017   0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x2722] 10018   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
[0x2724] 10020   0x32    LD (NN), A      724e        ;  Load location 0x724e (20082) with the Accumulator
[0x2727] 10023   0xc9    RET                         ;  Return

; 10024 - table for bonus pac
;10024 : 0x10
;10025 : 0x15
;10026 : 0x20
;10027 : 0xFF

; 10028 - table for difficulty
;10028 : 0x6800
;10030 : 0x7D00


;;; red_chase_AI()
;;; This is the AI for the Red Ghost in chase mode.  If the ghosts are in reverse
;;; chase mode, or the game frame is not 3 (attract mode?), and provided that
;;; the red_full_agressive flag hasn't been set by the player eating > 224 dots,
;;; the Red Ghost is drawn toward the ??? corner of the playfield.
;;;
;;; In normal chase mode, the Red Ghost targets Pac-Man's current position.
;;; Unlike Blue and Pink, who have predictive targetting, this gives the
;;; feeling that the Red Ghost is right on the player's tail.  Also, by skipping
;;; the reverse chase mode when the maze's completion gets close means that the
;;; Red Ghost becomes relentless, even at the start of a new life.

;; if ( ghost_reversal_status == 1 && red_aggression_1 == 0 game_frame == 3 )
;; {
;;     return min_distance_direction(red_YX, red_direction_idx, 0x1D22);
;; }
;; else
;; {
;;     return min_distance_direction(red_YX, red_direction_idx, pacman_YX);
;; }

; if ( ($4DC1 & 0x01 == 0) && ($4DB6 != 0) && ($4E04 == 0x03) )
; {
;     ($4D1E, $4D2C) = min_distance_direction($4D0A, $4D2C, 0x1d22);
; }
; else
; {
;     ($4D1E, $4D2C) = min_distance_direction($4D0A, $4D2C, $4D39);
; }
; return;

[0x2730] 10032   0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
[0x2733] 10035   0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
[0x2735] 10037   0xc2    JP NZ, NN       5827        ;  Jump to 0x5827 (10072) if ZERO flag is 0
[0x2738] 10040   0x3a    LD A, (NN)      b64d        ;  Load Accumulator with location 0xb64d (19894)
[0x273b] 10043   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x273c] 10044   0x20    JR NZ, N        1a          ;  Jump relative 0x1a (26) if ZERO flag is 0
[0x273e] 10046   0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
[0x2741] 10049   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x2743] 10051   0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
[0x2745] 10053   0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
[0x2748] 10056   0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
;; 10056-10063 : On Ms. Pac-Man patched in from $8050-$8057
;; 10059 $274b   0xcd    CALL nn         6195        ;  Call $nn
;; 10062 $274e   0xcd    CALL nn         6621        ;  Call $nn
[0x274b] 10059   0x11    LD  DE, NN      1d22        ;  Load register pair DE with 0x1d22 (29)
[0x274e] 10062   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x2751] 10065   0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
[0x2754] 10068   0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
[0x2757] 10071   0xc9    RET                         ;  Return
[0x2758] 10072   0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
[0x275b] 10075   0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
[0x275f] 10079   0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
[0x2762] 10082   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x2765] 10085   0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
[0x2768] 10088   0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
[0x276b] 10091   0xc9    RET                         ;  Return


;;; pink_chase_AI()
;;; This is the AI for the Pink Ghost in chase mode.  If the ghosts are in reverse
;;; chase mode, or the game frame is not 3 (attract mode?), the Pink ghost is
;;; drawn toward the upper left corner of the playfield?.
;;;
;;; If the ghosts are in normal chase mode, the Pink Ghost will target the point
;;; 4 tiles ahead of Pac-Man's current position, based on where Pac-Man is expected
;;; to go.  (expection based on last joystick position?)
;;;
;;; In other words, the Pink Ghost tries to go where the player is predicted to be.
;;; This, combined with the Red Ghost's agressive, direct targetting, explains why
;;; being squeezed by Red behind and Pink in front of the player is such a common
;;; occurance during gameplay.

;; if ( ghost_reversal_status == 1 && game_frame == 3 )
;; {
;;     // YX_to_playfield_addr(0x1D39) == ??
;;     return min_distance_direction(pink_YX, pink_direction_idx, upper_left_playfield?);
;; }
;; else
;; {
;;    target_YX = pacman_YX + (pacman_future_dir_accum * 4);
;;    return min_distance_direction(pink_YX, pink_direction_idx, target_YX);
;; }

; if ( ($4DC1 & 0x01 == 0) && ($4E04 == 0x03) )
; {
;     ($4D20, $4D2D) = min_distance_direction($4D0C, $4D2D, 0x1D39);
; }
; else
; {
;     DE = $4D39;  // pacman_YX
;     HL = $4D1C;  // pacman_future_dir_accum
;     HL = (HL * 4) + DE;
;     SWAP(HL, DE);
;     ($4D20, $4D2D) = min_distance_direction($4D0C, $4D2D, DE);
; }
; return;

[0x276c] 10092   0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
[0x276f] 10095   0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
[0x2771] 10097   0xc2    JP NZ, NN       8e27        ;  Jump to 0x8e27 (10126) if ZERO flag is 0
[0x2774] 10100   0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
[0x2777] 10103   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x2779] 10105   0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
[0x277b] 10107   0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
;; 10112-10119 : On Ms. Pac-Man patched in from $8090-$8097
;; 10110 $2781   0xcd    CALL nn         6195        ;  Call $nn
;; 10113 $2784   0xcd    CALL nn         6629        ;  Call $nn
[0x277e] 10110   0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
[0x2781] 10113   0x11    LD  DE, NN      1d39        ;  Load register pair DE with 0x1d39 (29)
[0x2784] 10116   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x2787] 10119   0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
[0x278a] 10122   0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
[0x278d] 10125   0xc9    RET                         ;  Return
[0x278e] 10126   0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
[0x2792] 10130   0x2a    LD HL, (NN)     1c4d        ;  Load register pair HL with location 0x1c4d (19740)
[0x2795] 10133   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2796] 10134   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2797] 10135   0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x2798] 10136   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x2799] 10137   0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
[0x279c] 10140   0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
[0x279f] 10143   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x27a2] 10146   0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
[0x27a5] 10149   0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
[0x27a8] 10152   0xc9    RET                         ;  Return


;;; blue_chase_AI()
;;; This is the AI for the Blue Ghost in chase mode.  If the ghosts are in reverse
;;; chase mode, or the game frame is not 3 (attract mode?), the Blue Ghost is
;;; drawn toward the upper right corner of the playfield?.
;;;
;;; If the ghosts are in normal chase mode, the Blue Ghost will target a point in the
;;; opposite direction and distance from the Red Ghost, as calculated __4 tiles ahead_
;;; from Pac-Man's current position, based on where Pac-Man is expected to go.
;;; (expection based on last joystick position?)
;;;
;;; To put this differently, extend Pac-Man's current predicted trajectory 4 tiles.
;;; Using this point, take the point in the direct opposite distance and direction
;;; from the Red Ghost.  This is the point that the Blue Ghost is drawn to.
;;;
;;; The principle here is that the Blue Ghost will try to predict where the player will
;;; be targeting to avoid the direct, aggressive targetting of the Red Ghost.

;; if ( ghost_reversal_status == 1 && game_frame == 3 )
;; {
;;     // YX_to_playfield_addr(0x4020) == upper right corner of playfield?
;;     return min_distance_direction(blue_YX, blue_direction_idx, upper_right_playfield?);
;; }
;; else
;; {
;;    target_YX = pacman_YX + (pacman_future_dir_accum * 2);
;;    target_YX = (target_YX * 2) - red_YX; 
;;    return min_distance_direction(blue_YX, blue_direction_idx, target_YX);
;; }

; if ( ($4DC1 & 0x01 == 0) && ($4E04 == 0x03) )
; {
;     ($4D22, $4D2E) = min_distance_direction($4D0E, $4D2E, 0x4020);
; }
; else
; {
;     BC = $4D0A;  // red_YX
;     DE = $4D39;  // pacman_YX
;     HL = $4D1C;  // pacman_future_dir_accum
;     HL = (HL*2) + DE;
;     L = (L*2) - C;
;     H = (H*2) - B;
;     SWAP(DE, HL);
;     ($4D22, $4D2E) = min_distance_direction($4D0E, $4D2E, DE);
; }
; return;

[0x27a9] 10153   0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
[0x27ac] 10156   0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
[0x27ae] 10158   0xc2    JP NZ, NN       cb27        ;  Jump to 0xcb27 (10187) if ZERO flag is 0
[0x27b1] 10161   0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
[0x27b4] 10164   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x27b6] 10166   0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
[0x27b8] 10168   0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
;; 10168-10175 : On Ms. Pac-Man patched in from $8190-$8197
;; 10171 $27bb   0xcd    CALL nn         5995        ;  Call $nn
;; 10174 $27be   0x11    LD DE, nn       40a6        ;  Load DE (16bit) with nn
[0x27bb] 10171   0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
[0x27be] 10174   0x11    LD  DE, NN      4020        ;  Load register pair DE with 0x4020 (64)
[0x27c1] 10177   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x27c4] 10180   0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
[0x27c7] 10183   0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0x27ca] 10186   0xc9    RET                         ;  Return
[0x27cb] 10187   0xed    LD BC, (NN)     0a4d        ;  Load register pair BC with location 0x0a4d (19722)
[0x27cf] 10191   0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
[0x27d3] 10195   0x2a    LD HL, (NN)     1c4d        ;  Load register pair HL with location 0x1c4d (19740)
[0x27d6] 10198   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x27d7] 10199   0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x27d8] 10200   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x27d9] 10201   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x27da] 10202   0x91    SUB A, C                    ;  Subtract register C from Accumulator (no carry)
[0x27db] 10203   0x6f    LD L, A                     ;  Load register L with Accumulator
[0x27dc] 10204   0x7c    LD A, H                     ;  Load Accumulator with register H
[0x27dd] 10205   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x27de] 10206   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x27df] 10207   0x67    LD H, A                     ;  Load register H with Accumulator
[0x27e0] 10208   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x27e1] 10209   0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
[0x27e4] 10212   0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
[0x27e7] 10215   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x27ea] 10218   0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
[0x27ed] 10221   0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0x27f0] 10224   0xc9    RET                         ;  Return


;;; orange_chase_AI()
;;; This is the AI for the Orange Ghost in chase mode.  If the ghosts are in normal chase
;;; mode and the orange ghost is within 8 tiles of Pac-Man, it will move straight for the
;;; the player.  Otherwise, if the Orange Ghost is more than 8 tiles away, or if the ghosts
;;; are in reverse chase mode, or the game is not in game_frame == 3 (ie. attract mode?)
;;; it will be drawn toward the upper right corner of the playfield.

;; if ( ghost_reversal_status == 1 && game_frame == 3 )
;; {
;;     // YX_to_playfield_addr(0x403B) == upper right corner of screen?
;;     return min_distance_direction(orange_YX, orange_direction_idx, upper_right_screen?);
;; }
;; else
;; {
;;     square_distance_to_pacman(pacman_YX, orange_YX);
;;     if ( square_distance_to_pacman > 64 )
;;     {
;;         return min_distance_direction(orange_YX, orange_direction_idx, upper_right_screen?);
;;     }
;;     else
;;     {
;;         return min_distance_direction(orange_YX, orange_direction_idx, pacman_YX);
;;     }
;; }

; if ( ($4DC1 & 0x01 == 0) && ($4E04 == 0x03) )
; {
;     ($4D24, $4D2F) = min_distance_direction($4D10, $4D2F, 0x403B);
; }
; else
; {
;     IX = 0x4D39;
;     IY = 0x4D10;
;     HL = square_distance(IX, IY);
;     DE = 0x0040;
;     A &= A;  // clear flags
;     if ( HL > DE )  // square_distance($IX, $IY) > 64
;     {
;         ($4D24, $4D2F) = min_distance_direction($4D10, $4D2F, 0x403B);
;     }
;     else
;     {
;        ($4D24, $4D2F) = min_distance_direction($4D10, $4D2F, $4D39); 
;     }
; }
; return;

[0x27f1] 10225   0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
[0x27f4] 10228   0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
[0x27f6] 10230   0xc2    JP NZ, NN       1328        ;  Jump to 0x1328 (10259) if ZERO flag is 0
[0x27f9] 10233   0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
[0x27fc] 10236   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x27fe] 10238   0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
[0x2800] 10240   0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
;; 10240-10247 : On Ms. Pac-Man patched in from $8028-$802F
;; 10243 $2803   0xcd    CALL nn         5e95        ;  Call $nn
;; 10246 $2806   0x11    LD DE, nn       40ff        ;  Load DE (16bit) with nn
[0x2803] 10243   0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
[0x2806] 10246   0x11    LD  DE, NN      403b        ;  Load register pair DE with 0x403b (64)
[0x2809] 10249   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x280c] 10252   0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
[0x280f] 10255   0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0x2812] 10258   0xc9    RET                         ;  Return
[0x2813] 10259   0xdd    LD IX, NN       394d        ;  Load register pair IX with 0x394d (19769)
[0x2817] 10263   0xfd    LD IY, NN       104d        ;  Load register pair IY with 0x104d (19728)
; HL = square(abs($IX-$IY)) + square(abs(($IX+1)-($IY+1))
[0x281b] 10267   0xcd    CALL NN         ea29        ;  Call to 0xea29 (10730)
[0x281e] 10270   0x11    LD  DE, NN      4000        ;  Load register pair DE with 0x4000 (64)
; clear flags
[0x2821] 10273   0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
[0x2822] 10274   0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x2824] 10276   0xda    JP C, NN        0028        ;  Jump to 0x0028 (10240) if CARRY flag is 1
[0x2827] 10279   0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
[0x282a] 10282   0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
[0x282e] 10286   0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
[0x2831] 10289   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x2834] 10292   0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
[0x2837] 10295   0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0x283a] 10298   0xc9    RET                         ;  Return


;;; red_flee_AI()
;;; This is the AI for the Red Ghost in edible mode.  If the ghost is "fleeing" Pac-Man
;;; it chooses directions at random.  Otherwise it goes straight to the playfield location
;;; just the left of the ghost home entrance/exit.

;; red_flee_AI()
;; if ( red_ghost_status != 0 )  // 0 == chase/flee
;; {
;;     // YX_to_playfield_addr(0x2E2C) == just left of the ghost home
;;     return min_distance_direction(red_YX, red_direction_idx, 0x2E2C);
;; }
;; else
;; {
;;     return random_direction(red_YX, red_direction_idx);
;; }

; if ( $4DAC != 0 )
; {
;     ($4D1E, $4D2C) = min_distance_direction($4D0A, $4D2C, 0x2E2C);
; }
; else
; {
;     ($4D1E, $4D2C) = random_direction($4D0A, $4D2C);
; }
; return;

[0x283b] 10299   0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
[0x283e] 10302   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x283f] 10303   0xca    JP Z,           5528        ;  Jump to 0x5528 (10325) if ZERO flag is 1
[0x2842] 10306   0x11    LD  DE, NN      2c2e        ;  Load register pair DE with 0x2c2e (44)
[0x2845] 10309   0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
[0x2848] 10312   0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
[0x284b] 10315   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x284e] 10318   0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
[0x2851] 10321   0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
[0x2854] 10324   0xc9    RET                         ;  Return
[0x2855] 10325   0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
[0x2858] 10328   0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
[0x285b] 10331   0xcd    CALL NN         1e29        ;  Call to 0x1e29 (10526)
[0x285e] 10334   0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
[0x2861] 10337   0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
[0x2864] 10340   0xc9    RET                         ;  Return


;;; pink_flee_AI()
;;; This is the AI for the Pink Ghost in edible mode.  If the ghost is "fleeing" Pac-Man
;;; it chooses directions at random.  Otherwise it goes straight to the playfield location
;;; just the left of the ghost home entrance/exit.

;; pink_flee_AI()
;; if ( pink_ghost_status != 0 )  // 0 == chase/flee
;; {
;;     // YX_to_playfield_addr(0x2E2C) == just left of the ghost home
;;     return min_distance_direction(pink_YX, pink_direction_idx, 0x2E2C);
;; }
;; else
;; {
;;     return random_direction(pink_YX, pink_direction_idx);
;; }

; if ( $4DAD != 0 )
; {
;     ($4D20, $4D2D) = min_distance_direction($4D0C, $4D2D, 0x2E2C);
; }
; else
; {
;     ($4D20, $4D2D) = random_direction($4D0C, $4D2D);
; }
; return;

[0x2865] 10341   0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
[0x2868] 10344   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2869] 10345   0xca    JP Z,           7f28        ;  Jump to 0x7f28 (10367) if ZERO flag is 1
[0x286c] 10348   0x11    LD  DE, NN      2c2e        ;  Load register pair DE with 0x2c2e (44)
[0x286f] 10351   0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
[0x2872] 10354   0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
[0x2875] 10357   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x2878] 10360   0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
[0x287b] 10363   0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
[0x287e] 10366   0xc9    RET                         ;  Return
[0x287f] 10367   0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
[0x2882] 10370   0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
[0x2885] 10373   0xcd    CALL NN         1e29        ;  Call to 0x1e29 (10526)
[0x2888] 10376   0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
[0x288b] 10379   0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
[0x288e] 10382   0xc9    RET                         ;  Return


;;; blue_flee_AI()
;;; This is the AI for the Blue Ghost in edible mode.  If the ghost is "fleeing" Pac-Man
;;; it chooses directions at random.  Otherwise it goes straight to the playfield location
;;; just the left of the ghost home entrance/exit.

;; blue_flee_AI()
;; if ( blue_ghost_status != 0 )  // 0 == chase/flee
;; {
;;     // YX_to_playfield_addr(0x2E2C) == just left of the ghost home
;;     return min_distance_direction(blue_YX, blue_direction_idx, 0x2E2C);  
;; }
;; else
;; {
;;     return random_direction(blue_YX, blue_direction_idx);
;; }

; if ( $4DAE != 0 )
; {
;     ($4D22, $4D2E) = min_distance_direction($4D0E, $4D2E, 0x2E2C);
; }
; else
; {
;     ($4D22, $4D2E) = random_direction($4D0E, $4D2E);
; }
; return;

[0x288f] 10383   0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
[0x2892] 10386   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2893] 10387   0xca    JP Z,           a928        ;  Jump to 0xa928 (10409) if ZERO flag is 1
[0x2896] 10390   0x11    LD  DE, NN      2c2e        ;  Load register pair DE with 0x2c2e (44)
[0x2899] 10393   0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
[0x289c] 10396   0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
[0x289f] 10399   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x28a2] 10402   0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
[0x28a5] 10405   0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0x28a8] 10408   0xc9    RET                         ;  Return
[0x28a9] 10409   0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
[0x28ac] 10412   0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
[0x28af] 10415   0xcd    CALL NN         1e29        ;  Call to 0x1e29 (10526)
[0x28b2] 10418   0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
[0x28b5] 10421   0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
[0x28b8] 10424   0xc9    RET                         ;  Return


;;; orange_flee_AI()
;;; This is the AI for the Orange Ghost in edible mode.  If the ghost is "fleeing" Pac-Man
;;; it chooses directions at random.  Otherwise it goes straight to the playfield location
;;; just the left of the ghost home entrance/exit.

;; orange_flee_AI()
;; if ( orange_ghost_status != 0 )  // 0 == chase/flee
;; {
;;     // YX_to_playfield_addr(0x2E2C) == just left of the ghost home
;;     return min_distance_direction(orange_YX, orange_direction_idx, 0x2E2C);
;; }
;; else
;; {
;;     return random_direction(orange_YX, orange_direction_idx);
;; }

; if ( $4DAF != 0 )
; {
;     ($4D24, $4D2F) = min_distance_direction($4D10, $4D2F, 0x2E2C); 
; }
; else
; {
;     ($4D24, $4D2F) = random_direction($4D10, $4D2F);
; }
; return;

[0x28b9] 10425   0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
[0x28bc] 10428   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x28bd] 10429   0xca    JP Z,           d328        ;  Jump to 0xd328 (10451) if ZERO flag is 1
[0x28c0] 10432   0x11    LD  DE, NN      2c2e        ;  Load register pair DE with 0x2c2e (44)
[0x28c3] 10435   0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
[0x28c6] 10438   0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
[0x28c9] 10441   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x28cc] 10444   0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
[0x28cf] 10447   0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0x28d2] 10450   0xc9    RET                         ;  Return
[0x28d3] 10451   0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
[0x28d6] 10454   0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
[0x28d9] 10457   0xcd    CALL NN         1e29        ;  Call to 0x1e29 (10526)
[0x28dc] 10460   0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
[0x28df] 10463   0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
[0x28e2] 10466   0xc9    RET                         ;  Return


;;; pacman_AI()
;;; This appears to be AI for Pac-Man in attract mode.  If the Red Ghost is edible,
;;; go straight for the Pink Ghost.  Otherwise, calculate the position that is in the exact
;;; opposite direction and distance as the Pink Ghost and go there.  In other words, Pac-Man is
;;; either chasing the the exact position of the Pink Ghost, or running in the opposite direction,
;;; depending on the status of the Red Ghost.
;;;
;;; This is a very clever bit of geometry.  Given two points, P1 and P2, the point that is
;;; the exact opposite direction and distance to P2 from P1 is:
;;;
;;; P1 - (P2-P1)  ===  P1 + (-P2 + P1)  ===  P1 + P1 - P2  ===  (P1 * 2) + P2
;;;                                                             -------------
;;;
;;; This avoids underflow, which would happen if the first form was implemented.

;; pacman_AI()
;; {
;;     if ( red_edible )  // $4DA7 != 0
;;     {
;;         return min_distance_direction(pacman_?predicted?_YX, pacman_direction_idx, pink_YX);
;;     }
;;     else
;;     {
;;         pac_pink_opposite_YX = pacman_YX * 2 + pink_YX;
;;         return min_distance_direction(pacman_?predicted?_YX, pacman_direction_idx, pac_pink_opposite_YX);
;;     }
;;     return;
;; }

; if ( $4DA7 != 0 )
; {
;     ($4D26, $4D3C) = min_distance_direction($4D12, $4D3C, $4D0C); 
; }
; else
; {
;     HL = $4D39;  // pacman_YX
;     BC = $4D0C;  // pink_YX
;     L = L + L - C;
;     H = H + H - B;
;     SWAP(DE, HL);
;     ($4D26, $4D3C) = min_distance_direction($4D12, $4D3C, DE);
; }
; return;

[0x28e3] 10467   0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
[0x28e6] 10470   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x28e7] 10471   0xca    JP Z,           fe28        ;  Jump to 0xfe28 (10494) if ZERO flag is 1
[0x28ea] 10474   0x2a    LD HL, (NN)     124d        ;  Load register pair HL with location 0x124d (19730)
[0x28ed] 10477   0xed    LD DE, (NN)     0c4d        ;  Load register pair DE with location 0x0c4d (19724)
[0x28f1] 10481   0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
[0x28f4] 10484   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x28f7] 10487   0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
[0x28fa] 10490   0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
[0x28fd] 10493   0xc9    RET                         ;  Return
[0x28fe] 10494   0x2a    LD HL, (NN)     394d        ;  Load register pair HL with location 0x394d (19769)
[0x2901] 10497   0xed    LD BC, (NN)     0c4d        ;  Load register pair BC with location 0x0c4d (19724)
[0x2905] 10501   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x2906] 10502   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x2907] 10503   0x91    SUB A, C                    ;  Subtract register C from Accumulator (no carry)
[0x2908] 10504   0x6f    LD L, A                     ;  Load register L with Accumulator
[0x2909] 10505   0x7c    LD A, H                     ;  Load Accumulator with register H
[0x290a] 10506   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x290b] 10507   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x290c] 10508   0x67    LD H, A                     ;  Load register H with Accumulator
[0x290d] 10509   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x290e] 10510   0x2a    LD HL, (NN)     124d        ;  Load register pair HL with location 0x124d (19730)
[0x2911] 10513   0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
[0x2914] 10516   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
[0x2917] 10519   0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
[0x291a] 10522   0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
[0x291d] 10525   0xc9    RET                         ;  Return


;;; random_direction(character_YX, character_direction_idx)
;;; Given a character's coordinates and a character direction, pick a new random direction to go
;;; that isn't back the way it came or a 0x0C character (huh?).  This code is pretty convoluted.
;;;
;;; Incrementing the pointer to the ghost direction table explains why that table is duplicated
;;; in memory, to handle overflow.  The code is structured so that there is no ghost_dir_table
;;; index dereferencing.  The pointer is simply initialized to ghost_dir_table + new_direction_idx
;;; (random), and then advances through the next 4 possibilities until a direction that works is
;;; found.  This isn't necessarily a bug, but it certainly isn't clear.
;;; 
;;; Results are returned in A (new_character_direction) and HL (new_character_YX).

;; (HL = new_character_adder, A = new_character_direction_idx) random_direction (HL = character_YX, A = character_direction_idx)
;; {
;;     character_YX_local = character_YX;
;;     opposite_current_direction_idx = character_direction ^ 0x02;  // $4D3D = A ^= 0x02;
;;     new_direction_idx = rand() & 0x03;  // new_direction_idx = $4D3B
;;     while ( new_direction_idx == opposite_current_direction_idx &&
;;             get_playfield_byte(ghost_dir_table[new_direction_idx] + character_YX_local) == " " ) )
;;             // why guarantee that the next char is *not* a space?  wouldn't we want it to be a space?
;;     {
;;         new_direction_idx++;  // also increments ghost_dir_table pointer, explaination above.
;;     }
;; }

; 
; // ( HL = {$4D0A, $4D0C, $4D0E, $4D10}, A = {$4D2C, $4D2D, $4D2E, $4D2F} )
; $4D3E = HL;  // Character YX
; A ^= 0x02;   // Character direction
; $4D3D = A;
; A = rand();
; A &= 0x03;
; HL = 0x4D3B;
; $HL = A;
; A += A;
; DE = A;
; IX = 0x32FF;  // 13055 : Table for ghost direction
; DE += IX;
; IY = 0x4D3E;
; // this compound conditional is condensed here, the real code is a bit more spaghetti-like
; while ( $HL == $4D3D && get_playfield_byte($(IX)+$(IY)) == 0x0C )  // 0x0C == space character
; {
;     // this block is 10583-10594
;     IX += 2;
;     $4D3B = ( $4D3B + 1 ) & 0x03;
; }
; // this block is 10573-10582
; HL = $IX;
; A = $4D3B;
; return;

[0x291e] 10526   0x22    LD (NN), HL     3e4d        ;  Load location 0x3e4d (19774) with the register pair HL
[0x2921] 10529   0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
[0x2923] 10531   0x32    LD (NN), A      3d4d        ;  Load location 0x3d4d (19773) with the Accumulator
[0x2926] 10534   0xcd    CALL NN         232a        ;  Call to 0x232a (10787)
[0x2929] 10537   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
[0x292b] 10539   0x21    LD HL, NN       3b4d        ;  Load register pair HL with 0x3b4d (19771)
[0x292e] 10542   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x292f] 10543   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x2930] 10544   0x5f    LD E, A                     ;  Load register E with Accumulator
[0x2931] 10545   0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x2933] 10547   0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
[0x2937] 10551   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x2939] 10553   0xfd    LD IY, NN       3e4d        ;  Load register pair IY with 0x3e4d (19774)
[0x293d] 10557   0x3a    LD A, (NN)      3d4d        ;  Load Accumulator with location 0x3d4d (19773)
[0x2940] 10560   0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x2941] 10561   0xca    JP Z,           5729        ;  Jump to 0x5729 (10583) if ZERO flag is 1
; get_playfield_byte($(IX)+$(IY));
[0x2944] 10564   0xcd    CALL NN         0f20        ;  Call to 0x0f20 (8207)
[0x2947] 10567   0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
[0x2949] 10569   0xd6    SUB N           c0          ;  Subtract 0xc0 (192) from Accumulator (no carry)
[0x294b] 10571   0x28    JR Z, N         0a          ;  Jump relative 0x0a (10) if ZERO flag is 1
[0x294d] 10573   0xdd    LD L, (IX + N)  00          ;  Load register L with location ( IX + 0x00 () )
[0x2950] 10576   0xdd    LD H, (IX + N)  01          ;  Load register H with location ( IX + 0x01 () )
[0x2953] 10579   0x3a    LD A, (NN)      3b4d        ;  Load Accumulator with location 0x3b4d (19771)
[0x2956] 10582   0xc9    RET                         ;  Return
[0x2957] 10583   0xdd    INC IX                      ;  Increment register pair IX
[0x2959] 10585   0xdd    INC IX                      ;  Increment register pair IX
[0x295b] 10587   0x21    LD HL, NN       3b4d        ;  Load register pair HL with 0x3b4d (19771)
[0x295e] 10590   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x295f] 10591   0x3c    INC A                       ;  Increment Accumulator
[0x2960] 10592   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
[0x2962] 10594   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2963] 10595   0xc3    JP NN           3d29        ;  Jump to 0x3d29 (10557)


;;; min_distance_direction(character_YX, character_direction_idx, target_YX);
;;; Given a character's coordinates and direction and a target's coordinates, provide a
;;; new direction that brings the character closer to the target.  It makes sure that
;;; the new direction isn't the opposite of the character's current direction and that
;;; the new position isn't the space character, 0xC0 (huh?, why *not* the space char?).
;;;
;;; Note that there is no actual indexing into the ghost_direction_table, instead it simply
;;; advances the table pointer (in IX), at the same time it advances the index (in $4DC7)

;; (HL = new_character_adder, A = new_character_direction_idx) min_distance_direction = (HL = character_YX, A = character_direction_idx, DE = target_YX)
;; {
;;     new_dir_dist = 0xFFFF;
;;     for ( test_direction=0; test_direction<4; test_direction++)
;;     {
;;         if ( test_direction == opposite_current_direction )  continue;
;;         test_YX = playfield_addr(character_position, ghost_direction_table[test_direction]);
;;         if ( char_at_position(test_YX) == 0xC0 )  continue;    // 0xC0 == open space
;;         if ( distance(target_YX, test_YX) < new_dir_dist )
;;         {
;;             new_dir_dist = dist(target_YX, test_YX);
;;             new_dir = test_direction;
;;         }
;;     }
;; }

; $4D3E = HL;  // character YX
; $4D40 = DE;  // target YX
; $4D3B = A;   // character direction
; A ^= 0x02;
; $4D3D = A;
; $4D44 = 0xFFFF;  // distance from character to target, init to MAX_UINT
; IX = 0x32FF;     // ghost_direction_table
; IY = 0x4D3E;
; $4DC7 = 0x00;    // HL = 0x4DC7
; while ( $4DC7 != 4 )
; {
;     if ( $HL != $4D3D )
;     {
;         L = (IY) + (IX);  H = (IY + 1) + (IX + 1);  // via call_8192()
;         HL = YX_to_playfield_addr();  // via call_101();
;         A = $HL;
;         if ( A != 0xC0 )  // $HL is not a space char
;         {
;             PUSH IX;  PUSH IY;
;             HL = square_distance(0x4D40, 0x4D42);  // distance from character to target
;             POP IY;  POP IX;
;             SWAP(DE, HL);
;             if ( DE <= $4D44 )
;             {
;                 $4D44 = DE;     // was HL, aka min_distance_seen
;                 $4D3B = $4DC7;  // current direction being tested, aka min_distance_direction
;             }
;         }
;     IX += 2;
;     $4DC7++;
; }      
; HL = ghost_direction_table[$4D3B * 2];
; A /= 2;
; return;

[0x2966] 10598   0x22    LD (NN), HL     3e4d        ;  Load location 0x3e4d (19774) with the register pair HL
[0x2969] 10601   0xed    LD (NN), DE     404d        ;  Load location 0x404d (19776) with register pair DE
[0x296d] 10605   0x32    LD (NN), A      3b4d        ;  Load location 0x3b4d (19771) with the Accumulator
[0x2970] 10608   0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
[0x2972] 10610   0x32    LD (NN), A      3d4d        ;  Load location 0x3d4d (19773) with the Accumulator
[0x2975] 10613   0x21    LD HL, NN       ffff        ;  Load register pair HL with 0xffff (65535)
[0x2978] 10616   0x22    LD (NN), HL     444d        ;  Load location 0x444d (19780) with the register pair HL
[0x297b] 10619   0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
[0x297f] 10623   0xfd    LD IY, NN       3e4d        ;  Load register pair IY with 0x3e4d (19774)
[0x2983] 10627   0x21    LD HL, NN       c74d        ;  Load register pair HL with 0xc74d (19911)
[0x2986] 10630   0x36    LD (HL), N      00          ;  Load location HL with 0x00 (0)
[0x2988] 10632   0x3a    LD A, (NN)      3d4d        ;  Load Accumulator with location 0x3d4d (19773)
[0x298b] 10635   0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x298c] 10636   0xca    JP Z,           c629        ;  Jump to 0xc629 (10694) if ZERO flag is 1
; L = (IY) + (IX);  H = (IY + 1) + (IX + 1);
[0x298f] 10639   0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
[0x2992] 10642   0x22    LD (NN), HL     424d        ;  Load location 0x424d (19778) with the register pair HL
; YX_to_playfield_addr() // via 101
[0x2995] 10645   0xcd    CALL NN         6500        ;  Call to 0x6500 (101)
[0x2998] 10648   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
; At this point, A contains the byte on the screen that is pointed to by $4D3E + $IX ($32FF-...) as Y,
; and $4D3F + $(IX+1) ($3300-...) as X
[0x2999] 10649   0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
; if that byte on the screen is a space (C0 in the tile roms), jump to 10694
[0x299b] 10651   0xd6    SUB N           c0          ;  Subtract 0xc0 (192) from Accumulator (no carry)
[0x299d] 10653   0x28    JR Z, N         27          ;  Jump relative 0x27 (39) if ZERO flag is 1
[0x299f] 10655   0xdd    PUSH IX                     ;  Load the stack with register pair IX
[0x29a1] 10657   0xfd    PUSH IY                     ;  Load the stack with register pair IY
[0x29a3] 10659   0xdd    LD IX, NN       404d        ;  Load register pair IX with 0x404d (19776)
[0x29a7] 10663   0xfd    LD IY, NN       424d        ;  Load register pair IY with 0x424d (19778)
; HL == square of distance from ghost to pacman
[0x29ab] 10667   0xcd    CALL NN         ea29        ;  Call to 0xea29 (10730)
[0x29ae] 10670   0xfd    POP IY                      ;  Load register pair IY with top of stack
[0x29b0] 10672   0xdd    POP IX                      ;  Load register pair IX with top of stack
[0x29b2] 10674   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x29b3] 10675   0x2a    LD HL, (NN)     444d        ;  Load register pair HL with location 0x444d (19780)
; clear flags
[0x29b6] 10678   0xa7    AND A, A                    ;  Bitwise AND of Accumulator and Accumulator
[0x29b7] 10679   0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x29b9] 10681   0xda    JP C, NN        c629        ;  Jump to 0xc629 (10694) if CARRY flag is 1
[0x29bc] 10684   0xed    LD (NN), DE     444d        ;  Load location 0x444d (19780) with register pair DE
[0x29c0] 10688   0x3a    LD A, (NN)      c74d        ;  Load Accumulator with location 0xc74d (19911)
[0x29c3] 10691   0x32    LD (NN), A      3b4d        ;  Load location 0x3b4d (19771) with the Accumulator
[0x29c6] 10694   0xdd    INC IX                      ;  Increment register pair IX
[0x29c8] 10696   0xdd    INC IX                      ;  Increment register pair IX
[0x29ca] 10698   0x21    LD HL, NN       c74d        ;  Load register pair HL with 0xc74d (19911)
[0x29cd] 10701   0x34    INC (HL)                    ;  Increment location (HL)
[0x29ce] 10702   0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
; repeat 10632-10705 4 times
[0x29d0] 10704   0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x29d1] 10705   0xc2    JP NZ, NN       8829        ;  Jump to 0x8829 (10632) if ZERO flag is 0
[0x29d4] 10708   0x3a    LD A, (NN)      3b4d        ;  Load Accumulator with location 0x3b4d (19771)
[0x29d7] 10711   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x29d8] 10712   0x5f    LD E, A                     ;  Load register E with Accumulator
[0x29d9] 10713   0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
[0x29db] 10715   0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
[0x29df] 10719   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x29e1] 10721   0xdd    LD L, (IX + N)  00          ;  Load register L with location ( IX + 0x00 () )
[0x29e4] 10724   0xdd    LD H, (IX + N)  01          ;  Load register H with location ( IX + 0x01 () )
[0x29e7] 10727   0xcb    SRL A                       ;  Shift Accumulator right logical
[0x29e9] 10729   0xc9    RET                         ;  Return



;; square_distance(IX = location_a, IY = location_b);
; HL = square(abs($IX-$IY)) + square(abs(($IX+1)-($IY+1))
; Determines the square of the distance from the distorted Ghost position (in $IY, $IY+1)
; to Pacman's perceived position (in $IX, $IX+1)
[0x29ea] 10730   0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
[0x29ed] 10733   0xfd    LD B, (IY + N)  00          ;  Load register B with location ( IY + 0x00 () )
[0x29f0] 10736   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x29f1] 10737   0xd2    JP NC, NN       f929        ;  Jump to 0xf929 (10745) if CARRY flag is 0
[0x29f4] 10740   0x78    LD A, B                     ;  Load Accumulator with register B
[0x29f5] 10741   0xdd    LD B, (IX + N)  00          ;  Load register B with location ( IX + 0x00 () )
[0x29f8] 10744   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
; square(A);
[0x29f9] 10745   0xcd    CALL NN         122a        ;  Call to 0x122a (10770)
[0x29fc] 10748   0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x29fd] 10749   0xdd    LD A, (IX+d)    01          ;  Load Accumulator with location ( IX + 0x01 () )
[0x2a00] 10752   0xfd    LD B, (IY + N)  01          ;  Load register B with location ( IY + 0x01 () )
[0x2a03] 10755   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
[0x2a04] 10756   0xd2    JP NC, NN       0c2a        ;  Jump to 0x0c2a (10764) if CARRY flag is 0
[0x2a07] 10759   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2a08] 10760   0xdd    LD B, (IX + N)  01          ;  Load register B with location ( IX + 0x01 () )
[0x2a0b] 10763   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
; square(A);
[0x2a0c] 10764   0xcd    CALL NN         122a        ;  Call to 0x122a (10770)
[0x2a0f] 10767   0xc1    POP BC                      ;  Load register pair BC with top of stack
[0x2a10] 10768   0x09    ADD HL, BC                  ;  Add register pair BC to HL
[0x2a11] 10769   0xc9    RET                         ;  Return


; square(A);
; Incredible.  Works on the principle that for each 1 bit of the multiplicand in
; position N, you add the multiplicand << ( 8-N ) to the product accumulator.  In
; this case, HL.  I'm not convinced that it works mathematically, but it seems to
; on a few back-of-the-envelope cases.
[0x2a12] 10770   0x67    LD H, A                     ;  Load register H with Accumulator
[0x2a13] 10771   0x5f    LD E, A                     ;  Load register E with Accumulator
[0x2a14] 10772   0x2e    LD L,N          00          ;  Load register L with 0x00 (0)
[0x2a16] 10774   0x55    LD D, L                     ;  Load register D with register L
[0x2a17] 10775   0x0e    LD  C, N        08          ;  Load register C with 0x08 (8)
[0x2a19] 10777   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2a1a] 10778   0xd2    JP NC, NN       1e2a        ;  Jump to 0x1e2a (10782) if CARRY flag is 0
[0x2a1d] 10781   0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x2a1e] 10782   0x0d    DEC C                       ;  Decrement register C
[0x2a1f] 10783   0xc2    JP NZ, NN       192a        ;  Jump to 0x192a (10777) if ZERO flag is 0
[0x2a22] 10786   0xc9    RET                         ;  Return


;;; rand()
;;; Pseudo-random number generator.  Keeps its state in $4DC9 and returns a new random value in A.
;;; It works by scanning through the bottom 8K of memory space, using the byte it finds as the
;;; value.  On each invocation it fetches the previous address (the "state" it holds in $4DC9),
;;; multiplies that address by 5, adds 1, and bitmasks the bottom 13 bits.  This new address is
;;; used to find the next value and is stored back into the state location.

;; rand()
;; {
;;     $4DC9 = ( ( $4DC9 * 5 ) + 1 ) & 0x1FFF;  // mask keeps us within the bottom 8K
;;     A = ($4DC9);  // A is the value that is pointed to by the value in $4DC9
;; }

; HL = $4DC9;
; DE = HL;
; HL += HL;
; HL += HL;
; HL += DE;  // HL == $4DC9 * 5
; HL++;
; H &= 0x1F;
; A = $HL;
; $4DC9 = HL;
; return;

[0x2a23] 10787   0x2a    LD HL, (NN)     c94d        ;  Load register pair HL with location 0xc94d (19913)
[0x2a26] 10790   0x54    LD D, H                     ;  Load register D with register H
[0x2a27] 10791   0x5d    LD E, L                     ;  Load register E with register L
[0x2a28] 10792   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2a29] 10793   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2a2a] 10794   0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x2a2b] 10795   0x23    INC HL                      ;  Increment register pair HL
[0x2a2c] 10796   0x7c    LD A, H                     ;  Load Accumulator with register H
[0x2a2d] 10797   0xe6    AND N           1f          ;  Bitwise AND of 0x1f (31) to Accumulator
[0x2a2f] 10799   0x67    LD H, A                     ;  Load register H with Accumulator
[0x2a30] 10800   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2a31] 10801   0x22    LD (NN), HL     c94d        ;  Load location 0xc94d (19913) with the register pair HL
[0x2a34] 10804   0xc9    RET                         ;  Return


;;; clear_playfield()
; // clean the playfield of small dots, medium dots, and large dots
; // A = ??;
; DE = 0x4040; // top right corner of playfield
; while ( 1 )
; {
;     HL = 0x43C0; // $43C0 == top right corner of upper field
;     $HL &= A;  // huh?!?
;     if ( HL -= DE == 0 ) return;  // return once we've incremented out of the playfield
;     if ( $DE == 0x10 || $DE == 0x12 || $DE == 0x14 ) {  A = 0x40;  $DE = A;  }
;     $DE++;
; }
[0x2a35] 10805   0x11    LD  DE, NN      4040        ;  Load register pair DE with 0x4040 (64)
[0x2a38] 10808   0x21    LD HL, NN       c043        ;  Load register pair HL with 0xc043 (17344)
[0x2a3b] 10811   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to location (HL)
[0x2a3c] 10812   0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
[0x2a3e] 10814   0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2a3f] 10815   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
[0x2a40] 10816   0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
[0x2a42] 10818   0xca    JP Z,           532a        ;  Jump to 0x532a (10835) if ZERO flag is 1
[0x2a45] 10821   0xfe    CP N            12          ;  Compare 0x12 (18) with Accumulator
[0x2a47] 10823   0xca    JP Z,           532a        ;  Jump to 0x532a (10835) if ZERO flag is 1
[0x2a4a] 10826   0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
[0x2a4c] 10828   0xca    JP Z,           532a        ;  Jump to 0x532a (10835) if ZERO flag is 1
[0x2a4f] 10831   0x13    INC DE                      ;  Increment register pair DE
[0x2a50] 10832   0xc3    JP NN           382a        ;  Jump to 0x382a (10808)
[0x2a53] 10835   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
[0x2a55] 10837   0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
[0x2a56] 10838   0x13    INC DE                      ;  Increment register pair DE
[0x2a57] 10839   0xc3    JP NN           382a        ;  Jump to 0x382a (10808)

; score_event()  // B = score event
; if ( $4E00 == 1 ) return;
; HL = $2B17[B];
; DE = HL, HL = DE;
; call(11019);  // HL = ($4E09==0)?0x4E80:0x4E84;
; A = E;
; $HL = decimal_adj(A += $HL); 
; HL++;
; A = D;
; E = $HL = decimal_adj(A +C= $HL);
; HL++;
; A = 0;
; D = $HL = decimal_adj(A +C= $HL);
; DE = HL, HL = DE;  // DE == ( 0x4E80 or 0x4E84 ) + 2,  HL == second and third digits of the addition above
; HL *= 4;  // why?!?
; A = $4E71;
; A--;
; if ( H > A ) call(11059);  // did we cross the threshold for an extra pac?
;         else call(10927);  add_extra_life() vs draw_score() // ??
; DE += 3;
; HL = 0x4E8A;
; while ( B-- != 0 )
; {
;     if ( $HL > $DE ) {  return;  }
;     if ( $HL != $DE ) { draw_score_with_highscore(); }
;     HL--;  DE--;
; }
[0x2a5a] 10842   0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x2a5d] 10845   0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x2a5f] 10847   0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2a60] 10848   0x21    LD HL, NN       172b        ;  Load register pair HL with 0x172b (11031)
[0x2a63] 10851   0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
[0x2a64] 10852   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x2a65] 10853   0xcd    CALL NN         0b2b        ;  Call to 0x0b2b (11019)
[0x2a68] 10856   0x7b    LD A, E                     ;  Load Accumulator with register E
[0x2a69] 10857   0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
[0x2a6a] 10858   0x27    DAA                         ;  Decimal adjust Accumulator
[0x2a6b] 10859   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2a6c] 10860   0x23    INC HL                      ;  Increment register pair HL
[0x2a6d] 10861   0x7a    LD A, D                     ;  Load Accumulator with register D
[0x2a6e] 10862   0x8e    ADC A, (HL)                 ;  Add with carry location (HL) to Accumulator
[0x2a6f] 10863   0x27    DAA                         ;  Decimal adjust Accumulator
[0x2a70] 10864   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2a71] 10865   0x5f    LD E, A                     ;  Load register E with Accumulator
[0x2a72] 10866   0x23    INC HL                      ;  Increment register pair HL
[0x2a73] 10867   0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
[0x2a75] 10869   0x8e    ADC A, (HL)                 ;  Add with carry location (HL) to Accumulator
[0x2a76] 10870   0x27    DAA                         ;  Decimal adjust Accumulator
[0x2a77] 10871   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2a78] 10872   0x57    LD D, A                     ;  Load register D with Accumulator
[0x2a79] 10873   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x2a7a] 10874   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2a7b] 10875   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2a7c] 10876   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2a7d] 10877   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2a7e] 10878   0x3a    LD A, (NN)      714e        ;  Load Accumulator with location 0x714e (20081)
[0x2a81] 10881   0x3d    DEC A                       ;  Decrement Accumulator
[0x2a82] 10882   0xbc    CP A, H                     ;  Compare register H with Accumulator
[0x2a83] 10883   0xdc    CALL C,NN       332b        ;  Call to 0x332b (11059) if CARRY flag is 1
[0x2a86] 10886   0xcd    CALL NN         af2a        ;  Call to 0xaf2a (10927)
[0x2a89] 10889   0x13    INC DE                      ;  Increment register pair DE
[0x2a8a] 10890   0x13    INC DE                      ;  Increment register pair DE
[0x2a8b] 10891   0x13    INC DE                      ;  Increment register pair DE
[0x2a8c] 10892   0x21    LD HL, NN       8a4e        ;  Load register pair HL with 0x8a4e (20106)
[0x2a8f] 10895   0x06    LD  B, N        03          ;  Load register B with 0x03 (3)
[0x2a91] 10897   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
[0x2a92] 10898   0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
[0x2a93] 10899   0xd8    RET C                       ;  Return if CARRY flag is 1
[0x2a94] 10900   0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
[0x2a96] 10902   0x1b    DEC DE                      ;  Decrement register pair DE
[0x2a97] 10903   0x2b    DEC HL                      ;  Decrement register pair HL
[0x2a98] 10904   0x10    DJNZ N          f7          ;  Decrement B and jump relative 0xf7 (-9) if B!=0
[0x2a9a] 10906   0xc9    RET                         ;  Return


; draw_highscore()
; HL = ($4E09 == 0)?0x4E80:0x4E84;
; DE = 0x4E88;  BC = 0x0003;
; $DE..$DE+2 = $HL..$HL+2;
; DE--;  // 0x4E8A ??
; BC = 0x0304;
; HL = 0x43F2;
; jump(15); // 10942
[0x2a9b] 10907   0xcd    CALL NN         0b2b        ;  Call to 0x0b2b (11019)
[0x2a9e] 10910   0x11    LD  DE, NN      884e        ;  Load register pair DE with 0x884e (136)
[0x2aa1] 10913   0x01    LD  BC, NN      0300        ;  Load register pair BC with 0x0300 (3)
[0x2aa4] 10916   0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; decrement BC; repeat until BC == 0
[0x2aa6] 10918   0x1b    DEC DE                      ;  Decrement register pair DE
[0x2aa7] 10919   0x01    LD  BC, NN      0403        ;  Load register pair BC with 0x0403 (772)
[0x2aaa] 10922   0x21    LD HL, NN       f243        ;  Load register pair HL with 0xf243 (17394)
[0x2aad] 10925   0x18    JR N            0f          ;  Jump relative 0x0f (15)


; draw_score();  // DE = location of score
; if ( A = $4E09 == 0 ) {  HL = 0x43FC;  }  // player 1
;                  else {  HL = 0x43E9;  }  // player 2
; BC = 0x0304;
; while ( B-- != 0 )
; {
;    A = $DE;
;    A C<< 4;
;    draw_padded_score_digit();
;    A = $DE;
;    draw_padded_score_digit();
; }
[0x2aaf] 10927   0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x2ab2] 10930   0x01    LD  BC, NN      0403        ;  Load register pair BC with 0x0403 (772)
[0x2ab5] 10933   0x21    LD HL, NN       fc43        ;  Load register pair HL with 0xfc43 (17404)
[0x2ab8] 10936   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2ab9] 10937   0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
[0x2abb] 10939   0x21    LD HL, NN       e943        ;  Load register pair HL with 0xe943 (17385)
[0x2abe] 10942   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
[0x2abf] 10943   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ac0] 10944   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ac1] 10945   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ac2] 10946   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ac3] 10947   0xcd    CALL NN         ce2a        ;  Call to 0xce2a (10958)
[0x2ac6] 10950   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
[0x2ac7] 10951   0xcd    CALL NN         ce2a        ;  Call to 0xce2a (10958)
[0x2aca] 10954   0x1b    DEC DE                      ;  Decrement register pair DE
[0x2acb] 10955   0x10    DJNZ N          f1          ;  Decrement B and jump relative 0xf1 (-15) if B!=0
[0x2acd] 10957   0xc9    RET                         ;  Return

; draw_padded_score_digit()
; // draw a digit, but pad the score by up to (5?) 4 blanks for leading zeros
; // if (digit == 0 ) {  A=C;  if ( C=0 ) { draw; return; } else { A=0x40; C--; draw; return; } }
; //             else {  C=0;  draw; return;  }
; if ( A &= 0x15 != 0 ) {  C = 0x00;  }
; else if ( A = C != 0 ) {  A = 0x40;  C--;  }
; $HL = A;
; HL--;
; return;
[0x2ace] 10958   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x2ad0] 10960   0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
[0x2ad2] 10962   0x0e    LD  C, N        00          ;  Load register C with 0x00 (0)
[0x2ad4] 10964   0x18    JR N            07          ;  Jump relative 0x07 (7)
[0x2ad6] 10966   0x79    LD A, C                     ;  Load Accumulator with register C
[0x2ad7] 10967   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2ad8] 10968   0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
[0x2ada] 10970   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
[0x2adc] 10972   0x0d    DEC C                       ;  Decrement register C
[0x2add] 10973   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2ade] 10974   0x2b    DEC HL                      ;  Decrement register pair HL
[0x2adf] 10975   0xc9    RET                         ;  Return


; write_string(0); "HIGH SCORE"
[0x2ae0] 10976   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x2ae2] 10978   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
; Fill $4E80-$4E87 with 0x00
[0x2ae5] 10981   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2ae6] 10982   0x21    LD HL, NN       804e        ;  Load register pair HL with 0x804e (20096)
[0x2ae9] 10985   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
[0x2aeb] 10987   0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
; draw $4E82 to player one score field
[0x2aec] 10988   0x01    LD  BC, NN      0403        ;  Load register pair BC with 0x0403 (772)
[0x2aef] 10991   0x11    LD  DE, NN      824e        ;  Load register pair DE with 0x824e (130)
[0x2af2] 10994   0x21    LD HL, NN       fc43        ;  Load register pair HL with 0xfc43 (17404)
[0x2af5] 10997   0xcd    CALL NN         be2a        ;  Call to 0xbe2a (10942)
; // prepare to draw $4E86 to player two score field, but don't actually make the call
[0x2af8] 11000   0x01    LD  BC, NN      0403        ;  Load register pair BC with 0x0403 (772)
[0x2afb] 11003   0x11    LD  DE, NN      864e        ;  Load register pair DE with 0x864e (134)
[0x2afe] 11006   0x21    LD HL, NN       e943        ;  Load register pair HL with 0xe943 (17385)
; // this has something to do with the millions digit, but I don't know what
; A = $4E70;
; if ( $HL &= A == 0 ) {  C = 0x06;  }  // HL = $43E9
; draw_padded_score_digit()
[0x2b01] 11009   0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
[0x2b04] 11012   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to location (HL)
[0x2b05] 11013   0x20    JR NZ, N        b7          ;  Jump relative 0xb7 (-73) if ZERO flag is 0 // 10960
[0x2b07] 11015   0x0e    LD  C, N        06          ;  Load register C with 0x06 (6)
[0x2b09] 11017   0x18    JR N            b3          ;  Jump relative 0xb3 (-77)                   // 10960

; get_score_address()
; if ( $4E09 == 0 ) HL = 0x4E80;
;              else HL = 0x4E84;
; return;
[0x2b0b] 11019   0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
[0x2b0e] 11022   0x21    LD HL, NN       804e        ;  Load register pair HL with 0x804e (20096)
[0x2b11] 11025   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2b12] 11026   0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2b13] 11027   0x21    LD HL, NN       844e        ;  Load register pair HL with 0x844e (20100)
[0x2b16] 11030   0xc9    RET                         ;  Return

; 11031 - table used by score_event()
; 0 - 0x0010
; 1 - 0x0050
; 2 - 0x0200
; 3 - 0x0400
; 4 - 0x0800

;; 11040-11047 : On Ms. Pac-Man patched in from $8100-$8107
;; 5 - 0x1600
;; 6 - 0x0100
;; 7 - 0x0200

; 5 - 0x1600
; 6 - 0x0100
; 7 - 0x0300
; 8 - 0x0500
; 9 - 0x0700
; 10 - 0x1000
; 11 - 0x2000

;; 11056-11063 : On Ms. Pac-Man patched in from $8110-$8117
;; 12 - 0x5000

; 12 - 0x3000
; 13 - 0x5000


; add_extra_life() // ??
; //DE++;
; //HL=DE;
; //DE--;
; HL = DE++;
; if ( $HL & 0x01 ) return; else $HL |= 0x01;
; $4E9C |= 0x01;
; $4E14++; // ??
; $4E15++; // ??
; B = $4E15;   // $4E15 == pacs left
[0x2b33] 11059   0x13    INC DE                      ;  Increment register pair DE
[0x2b34] 11060   0x6b    LD L, E                     ;  Load register L with register E
[0x2b35] 11061   0x62    LD H, D                     ;  Load register H with register D
[0x2b36] 11062   0x1b    DEC DE                      ;  Decrement register pair DE
[0x2b37] 11063   0xcb    BIT 0,(HL)                  ;  Test bit 0 of location (HL)
[0x2b39] 11065   0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x2b3a] 11066   0xcb    SET 0,(HL)                  ;  Set bit 0 of location (HL)
[0x2b3c] 11068   0x21    LD HL, NN       9c4e        ;  Load register pair HL with 0x9c4e (20124)
[0x2b3f] 11071   0xcb    SET 0,(HL)                  ;  Set bit 0 of location (HL)
[0x2b41] 11073   0x21    LD HL, NN       144e        ;  Load register pair HL with 0x144e (19988)
[0x2b44] 11076   0x34    INC (HL)                    ;  Increment location (HL)
[0x2b45] 11077   0x21    LD HL, NN       154e        ;  Load register pair HL with 0x154e (19989)
[0x2b48] 11080   0x34    INC (HL)                    ;  Increment location (HL)
[0x2b49] 11081   0x46    LD B, (HL)                  ;  Load register B with location (HL)


; draw_extra_lives();
; HL = $401A;  // $401A == pacs left (on playfield)
; C = 0x05;
; if ( A != 0x00 && A < 0x06 ) // draw extra lives on screen
; {
;     repeat
;     {
;         A = 0x20;
;         draw_4tile();  // Draw pac in left of lower field
;         HL -= 2;
;         C--;
;     } until ( --B = 0 );
; }
; while ( C-- >= 0 ) {  blank_4tile();  HL -= 2;  }
; return;
[0x2b4a] 11082   0x21    LD HL, NN       1a40        ;  Load register pair HL with 0x1a40 (16410)
[0x2b4d] 11085   0x0e    LD  C, N        05          ;  Load register C with 0x05 (5)
[0x2b4f] 11087   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2b50] 11088   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2b51] 11089   0x28    JR Z, N         0e          ;  Jump relative 0x0e (14) if ZERO flag is 1
[0x2b53] 11091   0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
[0x2b55] 11093   0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
[0x2b57] 11095   0x3e    LD A,N          20          ;  Load Accumulator with 0x20 (32)
[0x2b59] 11097   0xcd    CALL NN         8f2b        ;  Call to 0x8f2b (11151)
[0x2b5c] 11100   0x2b    DEC HL                      ;  Decrement register pair HL
[0x2b5d] 11101   0x2b    DEC HL                      ;  Decrement register pair HL
[0x2b5e] 11102   0x0d    DEC C                       ;  Decrement register C
[0x2b5f] 11103   0x10    DJNZ N          f6          ;  Decrement B and jump relative 0xf6 (-10) if B!=0
[0x2b61] 11105   0x0d    DEC C                       ;  Decrement register C
[0x2b62] 11106   0xf8    RET M                       ;  Return if SIGN flag is 1 (Negative)
[0x2b63] 11107   0xcd    CALL NN         7e2b        ;  Call to 0x7e2b (11134)
[0x2b66] 11110   0x2b    DEC HL                      ;  Decrement register pair HL
[0x2b67] 11111   0x2b    DEC HL                      ;  Decrement register pair HL
[0x2b68] 11112   0x18    JR N            f7          ;  Jump relative 0xf7 (-9)
; if ( A = $4E00 == 1 ) return;
; call(11213); //  rectangular_fill(); // stack = loc of params, params (5 bytes) = upper-left of rect (2), width (1), char to fill (1), height (1)
; $DE = A;
; B = H;
; HL += BC;
; A = $BC;
; HL = 0x4E15;
; B = $HL;
; jump(draw_extra_lives());
[0x2b6a] 11114   0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x2b6d] 11117   0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x2b6f] 11119   0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2b70] 11120   0xcd    CALL NN         cd2b        ;  Call to 0xcd2b (11213)
[0x2b73] 11123   0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
[0x2b74] 11124   0x44    LD B, H                     ;  Load register B with register H
[0x2b75] 11125   0x09    ADD HL, BC                  ;  Add register pair BC to HL
[0x2b76] 11126   0x0a    LD  A, (BC)                 ;  Load Accumulator with location (BC)
[0x2b77] 11127   0x02    LD  (BC), A                 ;  Load location (BC) with the Accumulator
[0x2b78] 11128   0x21    LD HL, NN       154e        ;  Load register pair HL with 0x154e (19989)
[0x2b7b] 11131   0x46    LD B, (HL)                  ;  Load register B with location (HL)
[0x2b7c] 11132   0x18    JR N            cc          ;  Jump relative 0xcc (-52)


;;; clear_4tile();
; A = 0x40
; push(HL);
; push(DE);
; $HL = A;  $HL++;  $HL = A;
; $DE = 0x001F;  $HL += DE;
; $HL = A;  $HL++;  $HL = A;
; pop(DE);
; pop(HL);
; return;
[0x2b7e] 11134   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
[0x2b80] 11136   0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x2b81] 11137   0xd5    PUSH DE                     ;  Load the stack with register pair DE
[0x2b82] 11138   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2b83] 11139   0x23    INC HL                      ;  Increment register pair HL
[0x2b84] 11140   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2b85] 11141   0x11    LD  DE, NN      1f00        ;  Load register pair DE with 0x1f00 (31)
[0x2b88] 11144   0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x2b89] 11145   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2b8a] 11146   0x23    INC HL                      ;  Increment register pair HL
[0x2b8b] 11147   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2b8c] 11148   0xd1    POP DE                      ;  Load register pair DE with top of stack
[0x2b8d] 11149   0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x2b8e] 11150   0xc9    RET                         ;  Return


; draw_4tile();
; (HL)    = A
; (HL+1)  = A+1
; (HL+32) = A+2
; (HL+33) = A+3
[0x2b8f] 11151   0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x2b90] 11152   0xd5    PUSH DE                     ;  Load the stack with register pair DE
[0x2b91] 11153   0x11    LD  DE, NN      1f00        ;  Load register pair DE with 0x1f00 (31)
[0x2b94] 11156   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2b95] 11157   0x3c    INC A                       ;  Increment Accumulator
[0x2b96] 11158   0x23    INC HL                      ;  Increment register pair HL
[0x2b97] 11159   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2b98] 11160   0x3c    INC A                       ;  Increment Accumulator
[0x2b99] 11161   0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x2b9a] 11162   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2b9b] 11163   0x3c    INC A                       ;  Increment Accumulator
[0x2b9c] 11164   0x23    INC HL                      ;  Increment register pair HL
[0x2b9d] 11165   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x2b9e] 11166   0xd1    POP DE                      ;  Load register pair DE with top of stack
[0x2b9f] 11167   0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x2ba0] 11168   0xc9    RET                         ;  Return


;;; draw_credits_info()
;;; Display credits/play info
;;; This info is in $4E6E.
; if $4E6E == 0x00, display("FREE PLAY") ?
; else display("CREDIT   ");
; Then draw out the BCD of the number of credits ($4E6E) to $4034/$4033
[0x2ba1] 11169   0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
[0x2ba4] 11172   0xfe    CP N            ff          ;  Compare 0xff (255) with Accumulator
[0x2ba6] 11174   0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
; write_string(2); "FREE PLAY"
[0x2ba8] 11176   0x06    LD  B, N        02          ;  Load register B with 0x02 (2)
[0x2baa] 11178   0xc3    JP NN           5e2c        ;  Jump to 0x5e2c (11358)
; write_string(1); "CREDIT   "
[0x2bad] 11181   0x06    LD  B, N        01          ;  Load register B with 0x01 (1)
[0x2baf] 11183   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
; Get BCD credits ($4E6E)
[0x2bb2] 11186   0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
; Skip tens digit if it's 0
[0x2bb5] 11189   0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
[0x2bb7] 11191   0x28    JR Z, N         09          ;  Jump relative 0x09 (9) if ZERO flag is 1
; Rotate tens digit around, add 0x30 (beginning of ASCII numbers) to it, put in Video RAM $4034
[0x2bb9] 11193   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2bba] 11194   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2bbb] 11195   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2bbc] 11196   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2bbd] 11197   0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
[0x2bbf] 11199   0x32    LD (NN), A      3440        ;  Load location 0x3440 (16436) with the Accumulator
; Get BCD credits ($4E6E), block out tens digit, add 0x30 to it, put in Video RAM $4033
[0x2bc2] 11202   0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
[0x2bc5] 11205   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x2bc7] 11207   0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
[0x2bc9] 11209   0x32    LD (NN), A      3340        ;  Load location 0x3340 (16435) with the Accumulator
[0x2bcc] 11212   0xc9    RET                         ;  Return


; rectangular_fill();
; // stack = loc of params
; // params (5 bytes) = upper-left of rect (2), width (1), char to fill (1), height (1)
; // fill $HL..$HL+B, $HL+DE..$HL+DE+B, $HL+(DE*2)..$HL+(DE*2)+B, and so on with C
; // IOW, fill a rectangular space in mem with C, starting at $HL, B wide, A tall, and DE (32) between rows
; HL = pop();
; DE = $HL++, $HL++;
; BC = $HL++, $HL++;
; A = $HL++;
; push(HL);
; DE = HL, HL = DE;
; DE = 0x0020;
; while ( A-- != 0 )
; {
;     push(HL);
;     push(BC);
;     while ( B-- != 0 )
;     {  $HL = C;  HL++;  }  // fill $HL..$HL+B with C;
;     pop(BC);
;     pop(HL);
;     HL += DE;
; }
;
[0x2bcd] 11213   0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x2bce] 11214   0x5e    LD E, (HL)                  ;  Load register E with location (HL)
[0x2bcf] 11215   0x23    INC HL                      ;  Increment register pair HL
[0x2bd0] 11216   0x56    LD D, (HL)                  ;  Load register D with location (HL)
[0x2bd1] 11217   0x23    INC HL                      ;  Increment register pair HL
[0x2bd2] 11218   0x4e    LD C, (HL)                  ;  Load register C with location (HL)
[0x2bd3] 11219   0x23    INC HL                      ;  Increment register pair HL
[0x2bd4] 11220   0x46    LD B, (HL)                  ;  Load register B with location (HL)
[0x2bd5] 11221   0x23    INC HL                      ;  Increment register pair HL
[0x2bd6] 11222   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2bd7] 11223   0x23    INC HL                      ;  Increment register pair HL
[0x2bd8] 11224   0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x2bd9] 11225   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x2bda] 11226   0x11    LD  DE, NN      2000        ;  Load register pair DE with 0x2000 (32)
[0x2bdd] 11229   0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x2bde] 11230   0xc5    PUSH BC                     ;  Load the stack with register pair BC
[0x2bdf] 11231   0x71    LD (HL), C                  ;  Load location (HL) with register C
[0x2be0] 11232   0x23    INC HL                      ;  Increment register pair HL
[0x2be1] 11233   0x10    DJNZ N          fc          ;  Decrement B and jump relative 0xfc (-4) if B!=0
[0x2be3] 11235   0xc1    POP BC                      ;  Load register pair BC with top of stack
[0x2be4] 11236   0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x2be5] 11237   0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x2be6] 11238   0x3d    DEC A                       ;  Decrement Accumulator
[0x2be7] 11239   0x20    JR NZ, N        f4          ;  Jump relative 0xf4 (-12) if ZERO flag is 0
[0x2be9] 11241   0xc9    RET                         ;  Return


; draw_fruit()
; if ( $4E00 == 1 ) return;
; A = $4E13;  A++;
; if ( A >= 8 )  draw_fruit_gt8();
; DE = 0x3B08;  // 15112 - fruit table
; B = A;
; C = 0x07;
; HL = 0x4004;
; while ( B-- != 0 )
; {
;     A = $DE;
;     draw_4tile();    // draw fruit
;     HL += 0x0400;
;     DE++;
;     A = $DE;
;     blank_4tile(A);  // fill color
;     HL += 0xFC00;    // subtract 0x0400
;     DE++;
;     HL += 2;
;     C--;
; }
; while ( --C > 0 )
; {
;     blank_4tile();  // clear remaining fruit
;     HL += 0x0400;
;     A = 0;
;     blank_4tile();  // clear fruit color
;     HL += 0xFC00;    // subtract 0x0400
;     HL++;
; }
; return;
[0x2bea] 11242   0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
[0x2bed] 11245   0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
[0x2bef] 11247   0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2bf0] 11248   0x3a    LD A, (NN)      134e        ;  Load Accumulator with location 0x134e (19987)
[0x2bf3] 11251   0x3c    INC A                       ;  Increment Accumulator
;; 11248-11255 : On Ms. Pac-Man patched in from $81D0-$81D7
;; 11252 $2bf4   0xc3    JP nn           9387        ;  Jump to $nn
[0x2bf4] 11252   0xfe    CP N            08          ;  Compare 0x08 (8) with Accumulator
[0x2bf6] 11254   0xd2    JP NC, NN       2e2c        ;  Jump to 0x2e2c (11310) if CARRY flag is 0
[0x2bf9] 11257   0x11    LD  DE, NN      083b        ;  Load register pair DE with 0x083b (8)
[0x2bfc] 11260   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2bfd] 11261   0x0e    LD  C, N        07          ;  Load register C with 0x07 (7)
[0x2bff] 11263   0x21    LD HL, NN       0440        ;  Load register pair HL with 0x0440 (16388)
[0x2c02] 11266   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
[0x2c03] 11267   0xcd    CALL NN         8f2b        ;  Call to 0x8f2b (11151)  // draw_4tile();
[0x2c06] 11270   0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
[0x2c08] 11272   0x84    ADD A, H                    ;  Add register H to Accumulator (no carry)
[0x2c09] 11273   0x67    LD H, A                     ;  Load register H with Accumulator
[0x2c0a] 11274   0x13    INC DE                      ;  Increment register pair DE
[0x2c0b] 11275   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
[0x2c0c] 11276   0xcd    CALL NN         802b        ;  Call to 0x802b (11136)   // blank_4tile(A);
[0x2c0f] 11279   0x3e    LD A,N          fc          ;  Load Accumulator with 0xfc (252)
[0x2c11] 11281   0x84    ADD A, H                    ;  Add register H to Accumulator (no carry)
[0x2c12] 11282   0x67    LD H, A                     ;  Load register H with Accumulator
[0x2c13] 11283   0x13    INC DE                      ;  Increment register pair DE
[0x2c14] 11284   0x23    INC HL                      ;  Increment register pair HL
[0x2c15] 11285   0x23    INC HL                      ;  Increment register pair HL
[0x2c16] 11286   0x0d    DEC C                       ;  Decrement register C
[0x2c17] 11287   0x10    DJNZ N          e9          ;  Decrement B and jump relative 0xe9 (-23) if B!=0
[0x2c19] 11289   0x0d    DEC C                       ;  Decrement register C
[0x2c1a] 11290   0xf8    RET M                       ;  Return if SIGN flag is 1 (Negative)
[0x2c1b] 11291   0xcd    CALL NN         7e2b        ;  Call to 0x7e2b (11134)    // blank_4tile();
[0x2c1e] 11294   0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
[0x2c20] 11296   0x84    ADD A, H                    ;  Add register H to Accumulator (no carry)
[0x2c21] 11297   0x67    LD H, A                     ;  Load register H with Accumulator
[0x2c22] 11298   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2c23] 11299   0xcd    CALL NN         802b        ;  Call to 0x802b (11136)    // blank_4tile(A);
[0x2c26] 11302   0x3e    LD A,N          fc          ;  Load Accumulator with 0xfc (252)
[0x2c28] 11304   0x84    ADD A, H                    ;  Add register H to Accumulator (no carry)
[0x2c29] 11305   0x67    LD H, A                     ;  Load register H with Accumulator
[0x2c2a] 11306   0x23    INC HL                      ;  Increment register pair HL
[0x2c2b] 11307   0x23    INC HL                      ;  Increment register pair HL
[0x2c2c] 11308   0x18    JR N            eb          ;  Jump relative 0xeb (-21)


; draw_fruit_gt8();
; if ( A > 19 ) A = 19;
; A -= 7;
; C = A;  B = 0x00;
; HL = $3B08;  // 15112 - fruit table
; HL += BC;  HL += BC;
; DE = HL, HL = DE;
; B = 0x07;
; jump(11261); // draw fruit from the bumped index
[0x2c2e] 11310   0xfe    CP N            13          ;  Compare 0x13 (19) with Accumulator
[0x2c30] 11312   0x38    JR C, N         02          ;  Jump to 0x02 (2) if CARRY flag is 0
[0x2c32] 11314   0x3e    LD A,N          13          ;  Load Accumulator with 0x13 (19)
[0x2c34] 11316   0xd6    SUB N           07          ;  Subtract 0x07 (7) from Accumulator (no carry)
[0x2c36] 11318   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x2c37] 11319   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x2c39] 11321   0x21    LD HL, NN       083b        ;  Load register pair HL with 0x083b (15112)
[0x2c3c] 11324   0x09    ADD HL, BC                  ;  Add register pair BC to HL
[0x2c3d] 11325   0x09    ADD HL, BC                  ;  Add register pair BC to HL
[0x2c3e] 11326   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
[0x2c3f] 11327   0x06    LD  B, N        07          ;  Load register B with 0x07 (7)
[0x2c41] 11329   0xc3    JP NN           fd2b        ;  Jump to 0xfd2b (11261)


; hex2bcd();  // A is input & output
; C = decimal_adjust(B & 0x0F);
; if ( A = B & 0xF0 )
; {
;     A C>> 4;
;     B = A;
;     A = 0;
;     while ( B-- != 0 ) {  A += 0x16;  decimal_adjust(A);  }
; }
; A += C;
; decimal_adjust(A);
; return;
[0x2c44] 11332   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2c45] 11333   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x2c47] 11335   0xc6    ADD A, N        00          ;  Add 0x00 (0) to Accumulator (no carry)
[0x2c49] 11337   0x27    DAA                         ;  Decimal adjust Accumulator
[0x2c4a] 11338   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x2c4b] 11339   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2c4c] 11340   0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
[0x2c4e] 11342   0x28    JR Z, N         0b          ;  Jump relative 0x0b (11) if ZERO flag is 1
[0x2c50] 11344   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2c51] 11345   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2c52] 11346   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2c53] 11347   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2c54] 11348   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2c55] 11349   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2c56] 11350   0xc6    ADD A, N        16          ;  Add 0x16 (22) to Accumulator (no carry)
[0x2c58] 11352   0x27    DAA                         ;  Decimal adjust Accumulator
[0x2c59] 11353   0x10    DJNZ N          fb          ;  Decrement B and jump relative 0xfb (-5) if B!=0
[0x2c5b] 11355   0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x2c5c] 11356   0x27    DAA                         ;  Decimal adjust Accumulator
[0x2c5d] 11357   0xc9    RET                         ;  Return



; write_string(B==string_index)
; B = index of string to write
; Strings are stored at ..... in the format:
; LLSSSSSSSS/C/C
; or
; LLSSSSSSSS/CCCCCCCC/CCCCCCCC
; where LL is a 16-bit offset from the beginning of video RAM, SSS.. is the string,
; / is a delimiter, and C is a color code.  The first color code is the color for
; drawing the string and the second is for clearing the string.
; IX contains the location where the string will be written.
; DE contains the left-to-right difference between adjacent characters on the playfield (-32)
; so that it will be subtracted from IX to advance a character.
; - There is a tricky half-implemented feature here at location 11381-11385: If the second
; bit of the LL offset of the string is 1, it knows that the writing is happening to the
; upper part of the screen where the score is and adjusts the left-to-right subtractor
; accordingly, setting it to -1.
; - Interesting Feature: due to the table/index dereferencing function at RST 18, the index
; (B) can't be above 127.  If it is, the index will end up wrapping around when indexing
; into the table.  This generally harmless bug is exploited to use the upper bit of the
; index to indicate that the string's shape and position should be filled with spaces.
; For example, B=2 means "draw string #2 with it's shape and position", whereas B=130 means
; "draw spaces with string #2's shape and position".
;
; In English: when this function is called, it takes B and either draws the string at
;             index B in the string table or clears the string B-128, using the top
;             bit of B as a toggle for draw vs. clear.  It also features color
;             efficiency by using the top bit of the first color byte to indicate if
;             the entire string should be that color or if a full string's worth of
;             color codes follows.  Finally, it has the feature of using different
;             color codes for draw and clear.
;
; // B==index into string table to write
; HL = 0x36A5;                                // The string table in ROM
; HL = table_and_index_to_address(HL, B);     // RST 18
; DE = (void *)HL;                            // first 2 bytes of the string are its offset
; IX = 0x4400;                                // color RAM
; IX += DE;
; push(IX);                                   // push location of color RAM for this string to stack
; DE = -400;
; IX += DE;                                   // IX == location of video RAM for this string
; DE = -1;
; if ( (char *)HL & 0x80 )
;     {  DE = -32;  }
; HL++;
; A = B;
; BC = 0;
; if ( ( A += A ) < 256 )            // string index's top bit was not set
; {
;     while ( ( A = *HL ) != 0x2F )  // while char != 0x2F, byte-by-byte copy into video RAM
;     {
;         *(IX + 0x00) = A;
;         HL++;
;         IX += DE;                  // make sure we're advancing appropriately (top vs. playfield)
;         B;
;     }
;     HL++;
; }
; else                               // string index's top bit was set (draw spaces)
; {
;     while ( ( A = *HL ) != 0x2F )
;     {
;         *(IX + 0x00) = 0x40;
;         HL++;
;         IX += DE;                  // make sure we're advancing appropriately (top vs. playfield)
;         B;
;     }
;     HL++;
;     B++;
;     while ( ( A != *HL ) || ( BC != 0 ) ) {  HL++;  B--;  }
; }
;
; IX = pop();                                 // IX == location of color RAM for this string
; A = *HL;
; if ( A < 128 )

; {
;     do
;     {
;         A = *HL;
;         ( IX + 0x00 ) = A;
;         HL++;
;         IX += DE;
;         B--;
;     } while ( B != 0 )
; }
; else
; {
;     do
;     {
;         ( IX + 0x00 ) = A;
;         IX += DE;
;         B--;
;     } while ( B != 0 )
; }
;
;
; load DE with ((HL) + B*2)
[0x2c5e] 11358   0x21    LD HL, NN       a536        ;  Load register pair HL with 0xa536 (13989)
[0x2c61] 11361   0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
[0x2c62] 11362   0x5e    LD E, (HL)                  ;  Load register E with location (HL)
[0x2c63] 11363   0x23    INC HL                      ;  Increment register pair HL
[0x2c64] 11364   0x56    LD D, (HL)                  ;  Load register D with location (HL)

; Put location of string's color bytes on stack
[0x2c65] 11365   0xdd    LD IX, NN       0044        ;  Load register pair IX with 0x0044 (17408)
[0x2c69] 11369   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x2c6b] 11371   0xdd    PUSH IX                     ;  Load the stack with register pair IX

; Adjust IX to location of string's char bytes
[0x2c6d] 11373   0x11    LD  DE, NN      00fc        ;  Load register pair DE with 0x00fc (0)
[0x2c70] 11376   0xdd    ADD IX, DE                  ;  Add register pair DE to IX

; XXX this is incorrect
; Set DE to the difference between sequential L-to-R chars, based on bit 1 of the MSB of
; the string's location:
; MSB:1==0 (playfield)     - DE = -32
; MSB:1==1 (top of screen) - DE = -1
[0x2c72] 11378   0x11    LD  DE, NN      ffff        ;  Load register pair DE with 0xffff (255)
[0x2c75] 11381   0xcb    BIT 7,(HL)                  ;  Test bit 7 of location (HL)
;11381   0xcb    SET 1, (HL)                 ;  Set bit 1 of location (HL)
[0x2c77] 11383   0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
[0x2c79] 11385   0x11    LD  DE, NN      e0ff        ;  Load register pair DE with 0xe0ff (224)

; If B, the string's index number, is more than 128 jump to 11436...  (why?!?)
[0x2c7c] 11388   0x23    INC HL                      ;  Increment register pair HL
[0x2c7d] 11389   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2c7e] 11390   0x01    LD  BC, NN      0000        ;  Load register pair BC with 0x0000 (0)
[0x2c81] 11393   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x2c82] 11394   0x38    JR C, N         28          ;  Jump to 0x28 (40) if CARRY flag is 1

; right now IX = video+first 2 bytes of 'string', SP = color byte corresponding to IX
; HL points to the string plus 2 bytes and we know that B (the index into the string table) wasn't 0
; ... so let's write it to memory until we reach a delimiter character of 0x2F...
[0x2c84] 11396   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2c85] 11397   0xfe    CP N            2f          ;  Compare 0x2f (47) with Accumulator
[0x2c87] 11399   0x28    JR Z, N         09          ;  Jump relative 0x09 (9) if ZERO flag is 1
[0x2c89] 11401   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
[0x2c8c] 11404   0x23    INC HL                      ;  Increment register pair HL
[0x2c8d] 11405   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x2c8f] 11407   0x04    INC B                       ;  Increment register B
[0x2c90] 11408   0x18    JR N            f2          ;  Jump relative 0xf2 (-14)
[0x2c92] 11410   0x23    INC HL                      ;  Increment register pair HL

; if the color byte is > 127, we're going to write the color byte to the whole string
; otherwise, we're writing different colors to the whole string.
[0x2c93] 11411   0xdd    POP IX                      ;  Load register pair IX with top of stack
[0x2c95] 11413   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2c96] 11414   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2c97] 11415   0xfa    JP M, NN        a42c        ;  Jump to 0xa42c (11428) if SIGN flag is 1 (Negative)
[0x2c9a] 11418   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2c9b] 11419   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
[0x2c9e] 11422   0x23    INC HL                      ;  Increment register pair HL
[0x2c9f] 11423   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x2ca1] 11425   0x10    DJNZ N          f7          ;  Decrement B and jump relative 0xf7 (-9) if B!=0
[0x2ca3] 11427   0xc9    RET                         ;  Return

; write the color byte to the whole string.  only the bottom 5 bits are used; the top
; three, including our whole-string monocolor flag (C:7), are ignored
[0x2ca4] 11428   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
[0x2ca7] 11431   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x2ca9] 11433   0x10    DJNZ N          f9          ;  Decrement B and jump relative 0xf9 (-7) if B!=0
[0x2cab] 11435   0xc9    RET                         ;  Return


; String index was < 128, write byte to screen
[0x2cac] 11436   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2cad] 11437   0xfe    CP N            2f          ;  Compare 0x2f (47) with Accumulator
[0x2caf] 11439   0x28    JR Z, N         0a          ;  Jump relative 0x0a (10) if ZERO flag is 1
[0x2cb1] 11441   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x00 () ) with 0x40 ()
; actually - DD 36 00 40 : LD   (IX+d),n    ; Load location (IX + d) with N
[0x2cb5] 11445   0x23    INC HL                      ;  Increment register pair HL
[0x2cb6] 11446   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
[0x2cb8] 11448   0x04    INC B                       ;  Increment register B
[0x2cb9] 11449   0x18    JR N            f1          ;  Jump relative 0xf1 (-15)
[0x2cbb] 11451   0x23    INC HL                      ;  Increment register pair HL
[0x2cbc] 11452   0x04    INC B                       ;  Increment register B
; find the next 0x2F
[0x2cbd] 11453   0xed    CPIR                        ;  Compare location (HL) and accumulator, increment HL, decrement BC 
[0x2cbf] 11455   0x18    JR N            d2          ;  Jump relative 0xd2 (-46)





;; Sound handling code, I think.  Probably reads some kind of table and 'advances' the sound parameters
;;
; call_11588($3BC8, $4ECC, $4E8C);  //  15304 == $3BD4, $3BF3
; if ( $4ECC != 0 ) $4E91 = A;
;; 11456-11463 : On Ms. Pac-Man patched in from $80D0-$80D7
;; 11457 $2cc1  0xc3    JP nn           9797        ;  Jump to $nn
[0x2cc1] 11457   0x21    LD HL, NN       c83b        ;  Load register pair HL with 0xc83b (15304)
[0x2cc4] 11460   0xdd    LD IX, NN       cc4e        ;  Load register pair IX with 0xcc4e (20172)
[0x2cc8] 11464   0xfd    LD IY, NN       8c4e        ;  Load register pair IY with 0x8c4e (20108)
[0x2ccc] 11468   0xcd    CALL NN         442d        ;  Call to 0x442d (11588)
[0x2ccf] 11471   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2cd0] 11472   0x3a    LD A, (NN)      cc4e        ;  Load Accumulator with location 0xcc4e (20172)
[0x2cd3] 11475   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2cd4] 11476   0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
[0x2cd6] 11478   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2cd7] 11479   0x32    LD (NN), A      914e        ;  Load location 0x914e (20113) with the Accumulator

; call_11588($3BCC, $4EDC, $4E92);  //  15308 == $3C58, $3C95
; if ( $4EDC != 0 ) $4E96 = A;
;; 11480-11487 : On Ms. Pac-Man patched in from $80E0-$80E7
;; 11482 $2cda   0x21    LD HL, nn       7d96        ;  Load HL (16bit) with nn
;; 11485 $2cdd   0xdd21  LD IY, nn       dce3        ;  Load (16bit) IY with nn
[0x2cda] 11482   0x21    LD HL, NN       cc3b        ;  Load register pair HL with 0xcc3b (15308)
[0x2cdd] 11485   0xdd    LD IX, NN       dc4e        ;  Load register pair IX with 0xdc4e (20188)
[0x2ce1] 11489   0xfd    LD IY, NN       924e        ;  Load register pair IY with 0x924e (20114)
[0x2ce5] 11493   0xcd    CALL NN         442d        ;  Call to 0x442d (11588)
[0x2ce8] 11496   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2ce9] 11497   0x3a    LD A, (NN)      dc4e        ;  Load Accumulator with location 0xdc4e (20188)
[0x2cec] 11500   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2ced] 11501   0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
[0x2cef] 11503   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2cf0] 11504   0x32    LD (NN), A      964e        ;  Load location 0x964e (20118) with the Accumulator

; call_11588($3BD0, $4EEC, $4E97);  //  15312 == $3CDE, $3CDF
; if ( $4EEC != 0 ) $4E9B = A;
; return;
;; 11504-11511 : On Ms. Pac-Man patched in from $81E0-$81E7
;; 11507 $2cf3   0x21    LD HL, nn       8d96        ;  Load HL (16bit) with nn
;; 11510 $2cf6   0xdd21  LD IY, nn       ffff        ;  Load (16bit) IY with nn
[0x2cf3] 11507   0x21    LD HL, NN       d03b        ;  Load register pair HL with 0xd03b (15312)
[0x2cf6] 11510   0xdd    LD IX, NN       ec4e        ;  Load register pair IX with 0xec4e (20204)
[0x2cfa] 11514   0xfd    LD IY, NN       974e        ;  Load register pair IY with 0x974e (20119)
[0x2cfe] 11518   0xcd    CALL NN         442d        ;  Call to 0x442d (11588)
[0x2d01] 11521   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2d02] 11522   0x3a    LD A, (NN)      ec4e        ;  Load Accumulator with location 0xec4e (20204)
[0x2d05] 11525   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2d06] 11526   0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2d07] 11527   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2d08] 11528   0x32    LD (NN), A      9b4e        ;  Load location 0x9b4e (20123) with the Accumulator
[0x2d0b] 11531   0xc9    RET                         ;  Return


; $4E91 = call_11758($3B30, $4E9C, $4E8C);
; $4E96 = call_11758($3B40, $4EAC, $4E92);
; $4E9B = call_11758($3B80, $4EBC, $4E97);
; $4E90 = $4E9B ^ 0xFF;
; return;
[0x2d0c] 11532   0x21    LD HL, NN       303b        ;  Load register pair HL with 0x303b (15152)
[0x2d0f] 11535   0xdd    LD IX, NN       9c4e        ;  Load register pair IX with 0x9c4e (20124)
[0x2d13] 11539   0xfd    LD IY, NN       8c4e        ;  Load register pair IY with 0x8c4e (20108)
[0x2d17] 11543   0xcd    CALL NN         ee2d        ;  Call to 0xee2d (11758)
[0x2d1a] 11546   0x32    LD (NN), A      914e        ;  Load location 0x914e (20113) with the Accumulator
[0x2d1d] 11549   0x21    LD HL, NN       403b        ;  Load register pair HL with 0x403b (15168)
[0x2d20] 11552   0xdd    LD IX, NN       ac4e        ;  Load register pair IX with 0xac4e (20140)
[0x2d24] 11556   0xfd    LD IY, NN       924e        ;  Load register pair IY with 0x924e (20114)
[0x2d28] 11560   0xcd    CALL NN         ee2d        ;  Call to 0xee2d (11758)
[0x2d2b] 11563   0x32    LD (NN), A      964e        ;  Load location 0x964e (20118) with the Accumulator
[0x2d2e] 11566   0x21    LD HL, NN       803b        ;  Load register pair HL with 0x803b (15232)
[0x2d31] 11569   0xdd    LD IX, NN       bc4e        ;  Load register pair IX with 0xbc4e (20156)
[0x2d35] 11573   0xfd    LD IY, NN       974e        ;  Load register pair IY with 0x974e (20119)
[0x2d39] 11577   0xcd    CALL NN         ee2d        ;  Call to 0xee2d (11758)
[0x2d3c] 11580   0x32    LD (NN), A      9b4e        ;  Load location 0x9b4e (20123) with the Accumulator
[0x2d3f] 11583   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2d40] 11584   0x32    LD (NN), A      904e        ;  Load location 0x904e (20112) with the Accumulator
[0x2d43] 11587   0xc9    RET                         ;  Return


; if ( $IX == 0 ) jump_11764;
; E = find_leftmost_bit($IX); B = bitnumber_leftmost_bit($IX);
; A = $(IX+2);
; if ( A &= E == 0)
; {
;     $(IX+2) = E;
;     B--;
;     RST 18;  // 15304 - $3BD4, $3BF3;  15308 - $3C58, $3C95;  15312 - $3CDE, $3CDF
; }
; else
; {
;     $(IX+12)--;
;     if ( Z == 0 ) jump_11735;
;     HL = $(IX+7), $(IX+6);
; }
; A = $HL;
; HL++;
; $(IX+7), $(IX+6) = HL;
; if ( A < 0xF0 )
; {
;     push 0x2D6C;
;     A &= 0x0F;
;     RST 20;
; }
; else
; {
[0x2d44] 11588   0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
[0x2d47] 11591   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2d48] 11592   0xca    JP Z,           f42d        ;  Jump to 0xf42d (11764) if ZERO flag is 1
[0x2d4b] 11595   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x2d4c] 11596   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
[0x2d4e] 11598   0x1e    LD E,N          80          ;  Load register E with 0x80 (128)
[0x2d50] 11600   0x7b    LD A, E                     ;  Load Accumulator with register E
[0x2d51] 11601   0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
[0x2d52] 11602   0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
[0x2d54] 11604   0xcb    SRL E                       ;  Shift register E right logical
[0x2d56] 11606   0x10    DJNZ N          f8          ;  Decrement B and jump relative 0xf8 (-8) if B!=0
[0x2d58] 11608   0xc9    RET                         ;  Return
[0x2d59] 11609   0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
[0x2d5c] 11612   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
[0x2d5d] 11613   0x20    JR NZ, N        07          ;  Jump relative 0x07 (7) if ZERO flag is 0
[0x2d5f] 11615   0xdd    LD (IX+d), E    02          ;  Load location ( IX + 0x02 () ) with register E
;; 11616-11623 : On Ms. Pac-Man patched in from $8160-$8167
;; 11618 $2d62   0xc3    JP nn           4e36        ;  Jump to $nn
[0x2d62] 11618   0x05    DEC B                       ;  Decrement register B
; table_and_index_to_address()  //  called with 15304/15308/15312
[0x2d63] 11619   0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
[0x2d64] 11620   0x18    JR N            0c          ;  Jump relative 0x0c (12)
[0x2d66] 11622   0xdd    DEC (IX + N)    0c          ;  Decrement location IX + 0x0c ()
[0x2d69] 11625   0xc2    JP NZ, NN       d72d        ;  Jump to 0xd72d (11735) if ZERO flag is 0
[0x2d6c] 11628   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
[0x2d6f] 11631   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
[0x2d72] 11634   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2d73] 11635   0x23    INC HL                      ;  Increment register pair HL
[0x2d74] 11636   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
[0x2d77] 11639   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
[0x2d7a] 11642   0xfe    CP N            f0          ;  Compare 0xf0 (240) with Accumulator
[0x2d7c] 11644   0x38    JR C, N         27          ;  Jump to 0x27 (39) if CARRY flag is 0
[0x2d7e] 11646   0x21    LD HL, NN       6c2d        ;  Load register pair HL with 0x6c2d (11628)
[0x2d81] 11649   0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x2d82] 11650   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x2d84] 11652   0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; RST 20 address table
; 0 - $2F55 - 12117
; 1 - $2F65 - 12133
; 2 - $2F77 - 12151
; 3 - $2F89 - 12169
; 4 - $2F9B - 12187
; 5 - $000C - 12    [return;]
; 6 - $000C - 12    [return;]
; 7 - $000C - 12    [return;]
; 8 - $000C - 12    [return;]
; 9 - $000C - 12    [return;]
; 10 - $000C - 12    [return;]
; 11 - $000C - 12    [return;]
; 12 - $000C - 12    [return;]
; 13 - $000C - 12    [return;]
; 14 - $000C - 12    [return;]
; 15 - $000C - 12    [return;]
; 16 - $2FAD - 12205


; if ( B & 0x1F ) $($IX+14) = B;
[0x2da5] 11685   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2da6] 11686   0xe6    AND N           1f          ;  Bitwise AND of 0x1f (31) to Accumulator
[0x2da8] 11688   0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
[0x2daa] 11690   0xdd    LD (IX+d), B    0d          ;  Load location ( IX + 0x0d () ) with register B
; if ( $(IX+11) & 0x08 ) $(IX+15) = 0x00;
;                   else $(IX+15) = $(IX+9);
[0x2dad] 11693   0xdd    LD C, (IX + N)  09          ;  Load register C with location ( IX + 0x09 () )
[0x2db0] 11696   0xdd    LD A, (IX+d)    0b          ;  Load Accumulator with location ( IX + 0x0b () )
[0x2db3] 11699   0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
[0x2db5] 11701   0x28    JR Z, N         02          ;  Jump relative 0x02 (2) if ZERO flag is 1
[0x2db7] 11703   0x0e    LD  C, N        00          ;  Load register C with 0x00 (0)
[0x2db9] 11705   0xdd    LD (IX+d), C    0f          ;  Load location ( IX + 0x0f () ) with register C
; A = B;
; A cir<<= 3;
; A &= 0x07;
; HL = 0x3BB0; // (15280)
; RST 10;
[0x2dbc] 11708   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2dbd] 11709   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2dbe] 11710   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2dbf] 11711   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2dc0] 11712   0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x2dc2] 11714   0x21    LD HL, NN       b03b        ;  Load register pair HL with 0xb03b (15280)
[0x2dc5] 11717   0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
; $(IX+12) = A;
; A = B;
; if ( A &= 0x0F )
; {
;     HL = 0x3BB8; // 15288
;     RST 10; // 0x00, 0x57, 0x5c, 0x61, 0x67, 0x6d, 0x74, 0x7b, 0x82, 0x8a, 0x92, 0x9a, 0xa3, 0xad, 0xb8, 0xc3
; }
; $(IX+14) = A;
; L = $(IX+14);
; H = 0x00;
; A = $(IX+13);
; if ( A &= 0x10 ) A = 0x01;
; if ( A += $(IX+4) == 0x00 ) jump_12008;
;                        else jump_12004;
[0x2dc6] 11718   0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
[0x2dc9] 11721   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2dca] 11722   0xe6    AND N           1f          ;  Bitwise AND of 0x1f (31) to Accumulator
[0x2dcc] 11724   0x28    JR Z, N         09          ;  Jump relative 0x09 (9) if ZERO flag is 1
[0x2dce] 11726   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x2dd0] 11728   0x21    LD HL, NN       b83b        ;  Load register pair HL with 0xb83b (15288)
[0x2dd3] 11731   0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
[0x2dd4] 11732   0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
[0x2dd7] 11735   0xdd    LD L, (IX + N)  0e          ;  Load register L with location ( IX + 0x0e () )
[0x2dda] 11738   0x26    LD H, N         00          ;  Load register H with 0x00 (0)
[0x2ddc] 11740   0xdd    LD A, (IX+d)    0d          ;  Load Accumulator with location ( IX + 0x0d () )
[0x2ddf] 11743   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
[0x2de1] 11745   0x28    JR Z, N         02          ;  Jump relative 0x02 (2) if ZERO flag is 1
[0x2de3] 11747   0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x2de5] 11749   0xdd    ADD A, (IX+d)   04          ;  Add location ( IX + 0x04 () ) to Accumulator
[0x2de8] 11752   0xca    JP Z,           e82e        ;  Jump to 0xe82e (12008) if ZERO flag is 1
[0x2deb] 11755   0xc3    JP NN           e42e        ;  Jump to 0xe42e (12004)

;;; $4E00 = 0..3 (Post-boot blanking, Attract Screen, Press Start/Get Ready, Gameplay)
;;; 15152 ($3B30) - Sound Data (waveform?)
;;; 73 20 00 0C 00 0A 1F 00 72 20 FB 87 00 02 0F 00
;;; 15168 ($3B40) - Sound Data (waveform?)
;;; 36 20 04 8C 00 00 06 00 36 28 05 8B 00 00 06 00
;;; 15184 ($3B50) - Sound Data (waveform?)
;;; 36 30 06 8A 00 00 06 00 36 3C 07 89 00 00 06 00
;;; 15200 ($3B60) - Sound Data? (waveform?)
;;; 36 48 08 88 00 00 06 00 24 00 06 08 00 00 0A 00
;;; 15216 ($3B70) - Sound Data? (waveform?)
;;; 40 70 FA 10 00 00 0A 00 70 04 00 00 00 00 08 00
;;; 15232 ($3B80) - Sound Data? (waveform?)
;;; 42 18 FD 06 00 01 0C 00 42 04 03 06 00 01 0C 00
;;; 15248 ($3B90) - Sound Data? (waveform?)
;;; 56 0C FF 8C 00 02 0F 00 05 00 02 20 00 01 0C 00
;;; 15264 ($3BA0) - Sound Data? (waveform?)
;;; 41 20 FF 86 FE 1C 0F FF 70 00 01 0C 00 01 08 00
;; invoked with:        HL     IX     IY
;; $4E91 = call_11758($3B30, $4E9C, $4E8C);  // Waka Quarter Drop, Ding-ding-ding for extra life
;; $4E96 = call_11758($3B40, $4EAC, $4E92);  // Woo-woo of ghosts (incl. increasing pitches), bew-bew-bew of eyes returning to base
;; $4E9B = call_11758($3B80, $4EBC, $4E97);  // All eating sounds (waka-waka-waka), and the gobble of ghosts
; if ( (A=$IX) == 0 )
; {
;     if ( $(IX+2) == 0 ) return;
;     $(IX+2) = $(IX+13) = $(IX+14) = $(IX+15) = 0;
;     $IY = $(IY+1) = $(IY+2) = $(IY+3) = 0;
;     A = 0;
;     return;
; }
;; C = A; // A == $IX;
;; B = 0x08;
;; E = 0x80;
;; do
;; {
;;     A = E;
;;     if ( A &= C ) jump 11817;
;;     E >> 1;
;; } until ( --B == 0 );
; E = find_leftmost_bit($IX); B = bitnumber_leftmost_bit($IX);  // summarized
; jump_11817;
[0x2dee] 11758   0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
[0x2df1] 11761   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2df2] 11762   0x20    JR NZ, N        27          ;  Jump relative 0x27 (39) if ZERO flag is 0
[0x2df4] 11764   0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
[0x2df7] 11767   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2df8] 11768   0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2df9] 11769   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x00 ()
[0x2dfd] 11773   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0d () ) with 0x00 ()
[0x2e01] 11777   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0e () ) with 0x00 ()
[0x2e05] 11781   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0f () ) with 0x00 ()
[0x2e09] 11785   0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x00 ()
[0x2e0d] 11789   0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x00 ()
[0x2e11] 11793   0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x02 () ) with 0x00 ()
[0x2e15] 11797   0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x03 () ) with 0x00 ()
[0x2e19] 11801   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x2e1a] 11802   0xc9    RET                         ;  Return
[0x2e1b] 11803   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x2e1c] 11804   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
[0x2e1e] 11806   0x1e    LD E,N          80          ;  Load register E with 0x80 (128)
[0x2e20] 11808   0x7b    LD A, E                     ;  Load Accumulator with register E
[0x2e21] 11809   0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
[0x2e22] 11810   0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
[0x2e24] 11812   0xcb    SRL E                       ;  Shift register E right logical
[0x2e26] 11814   0x10    DJNZ N          f8          ;  Decrement B and jump relative 0xf8 (-8) if B!=0
[0x2e28] 11816   0xc9    RET                         ;  Return


;;; first_time_through_with_new_sound??
;;; Seems to set IX+2 to whatever is in E, indexes into HL to copy out freq/vol data
;; E contains the leftmost bit of $IX, B contains which position that is + 1
; if ( $(IX+2) & E ) jump_11886;
; $(IX+2) = E;
; C = (B-1) * 8;  // effectively, since B < 8;
; B = 0;
; push HL;
; HL += BC;
; DE = IX+3; 
; $DE...$(DE+7) = $HL..$(HL+7);
; pop HL;
[0x2e29] 11817   0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
[0x2e2c] 11820   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
[0x2e2d] 11821   0x20    JR NZ, N        3f          ;  Jump relative 0x3f (63) if ZERO flag is 0
[0x2e2f] 11823   0xdd    LD (IX+d), E    02          ;  Load location ( IX + 0x02 () ) with register E
[0x2e32] 11826   0x05    DEC B                       ;  Decrement register B
[0x2e33] 11827   0x78    LD A, B                     ;  Load Accumulator with register B
[0x2e34] 11828   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2e35] 11829   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2e36] 11830   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x2e37] 11831   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x2e38] 11832   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x2e3a] 11834   0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x2e3b] 11835   0x09    ADD HL, BC                  ;  Add register pair BC to HL
[0x2e3c] 11836   0xdd    PUSH IX                     ;  Load the stack with register pair IX
[0x2e3e] 11838   0xd1    POP DE                      ;  Load register pair DE with top of stack
[0x2e3f] 11839   0x13    INC DE                      ;  Increment register pair DE
[0x2e40] 11840   0x13    INC DE                      ;  Increment register pair DE
[0x2e41] 11841   0x13    INC DE                      ;  Increment register pair DE
[0x2e42] 11842   0x01    LD  BC, NN      0800        ;  Load register pair BC with 0x0800 (8)
[0x2e45] 11845   0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
[0x2e47] 11847   0xe1    POP HL                      ;  Load register pair HL with top of stack
; $(IX+12) = $(IX+6) & 0x7F;
; $(IX+14) = $(IX+4);
; B = A = $(IX+9);
; A cir>>= 4;
; A &= 0x0F;
; $(IX+11) = A;
; if ( A & 0x08 == 0 )
; {
;     $(IX+15) = B;
;     $(IX+13) = 0x00;
;     $(IX+12)--;  // shared (crazy Z-carrying)
; }
[0x2e48] 11848   0xdd    LD A, (IX+d)    06          ;  Load Accumulator with location ( IX + 0x06 () )
[0x2e4b] 11851   0xe6    AND N           7f          ;  Bitwise AND of 0x7f (127) to Accumulator
[0x2e4d] 11853   0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
[0x2e50] 11856   0xdd    LD A, (IX+d)    04          ;  Load Accumulator with location ( IX + 0x04 () )
[0x2e53] 11859   0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
[0x2e56] 11862   0xdd    LD A, (IX+d)    09          ;  Load Accumulator with location ( IX + 0x09 () )
[0x2e59] 11865   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2e5a] 11866   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2e5b] 11867   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2e5c] 11868   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2e5d] 11869   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2e5e] 11870   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x2e60] 11872   0xdd    LD (IX+d), A    0b          ;  Load location ( IX + 0x0b () ) with Accumulator
[0x2e63] 11875   0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
[0x2e65] 11877   0x20    JR NZ, N        07          ;  Jump relative 0x07 (7) if ZERO flag is 0
[0x2e67] 11879   0xdd    LD (IX+d), B    0f          ;  Load location ( IX + 0x0f () ) with register B
[0x2e6a] 11882   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0d () ) with 0x00 ()
; else
; {
;     if ( $(IX+12)-- != 0 ) {  jump_11981;  }
; }
; if ( $(IX+8) != 0 ) $(IX+8)--;  // either way, jump_11913, aka skip the next 5 instructions
;;;; A = E;
;;;; A ^= 0xFF;
;;;; A &= $IX;
;;;; $IX = A;
;;;; jump_11758;
; $(IX+12) = $(IX+6) &= 0x7F;
; if ( $(IX+6) & 0x80 )
; {
;     $(IX+5) *= -1;
;     if ( $(IX+13) & 0x01 ) { $(IX+13) |= 0x01;  jump_11981; }
;                       else { $(IX+13) &= 0xFE; }
; }
; $(IX+4) = $(IX+14) = $(IX+4) + $(IX+7);
; $(IX+9) += $(IX+10);
; if ( $(IX+11) & 0x08 == 0 ) { $(IX+15) = $(IX+9); }
[0x2e6e] 11886   0xdd    DEC (IX + N)    0c          ;  Decrement location IX + 0x0c ()
[0x2e71] 11889   0x20    JR NZ, N        5a          ;  Jump relative 0x5a (90) if ZERO flag is 0
[0x2e73] 11891   0xdd    LD A, (IX+d)    08          ;  Load Accumulator with location ( IX + 0x08 () )
[0x2e76] 11894   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x2e77] 11895   0x28    JR Z, N         10          ;  Jump relative 0x10 (16) if ZERO flag is 1
[0x2e79] 11897   0xdd    DEC (IX + N)    08          ;  Decrement location IX + 0x08 ()
[0x2e7c] 11900   0x20    JR NZ, N        0b          ;  Jump relative 0x0b (11) if ZERO flag is 0
; I had 11902-11910 asterisk'ed... why?  Is this code unreachable?
[0x2e7e] 11902   0x7b    LD A, E                     ;  Load Accumulator with register E
[0x2e7f] 11903   0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x2e80] 11904   0xdd    AND A, (IX+d)   00          ;  Bitwise AND location ( IX + 0x00 () ) with Accumulator
[0x2e83] 11907   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
[0x2e86] 11910   0xc3    JP NN           ee2d        ;  Jump to 0xee2d (11758)
[0x2e89] 11913   0xdd    LD A, (IX+d)    06          ;  Load Accumulator with location ( IX + 0x06 () )
[0x2e8c] 11916   0xe6    AND N           7f          ;  Bitwise AND of 0x7f (127) to Accumulator
[0x2e8e] 11918   0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
[0x2e91] 11921   0xdd    BIT 7, (IX+d)   06          ;  Test bit 7 of ( IX + 0x06 )
[0x2e95] 11925   0x28    JR Z, N         16          ;  Jump relative 0x16 (22) if ZERO flag is 1
[0x2e97] 11927   0xdd    LD A, (IX+d)    05          ;  Load Accumulator with location ( IX + 0x05 () )
[0x2e9a] 11930   0xed    NEG                         ;  Negate Accumulator (2's compliment)
[0x2e9c] 11932   0xdd    LD (IX+d), A    05          ;  Load location ( IX + 0x05 () ) with Accumulator
[0x2e9f] 11935   0xdd    BIT 0, (IX+d)   0d          ;  Test bit 0 of ( IX + 0x0d )
[0x2ea3] 11939   0xdd    SET 0, (IX+d)   0d          ;  Set bit 0 of ( IX + 0x0d )
[0x2ea7] 11943   0x28    JR Z, N         24          ;  Jump relative 0x24 (36) if ZERO flag is 1
[0x2ea9] 11945   0xdd    RES 0, (IX+d)   0d          ;  Reset bit 0 of ( IX + 0x0d )
[0x2ead] 11949   0xdd    LD A, (IX+d)    04          ;  Load Accumulator with location ( IX + 0x04 () )
[0x2eb0] 11952   0xdd    ADD A, (IX+d)   07          ;  Add location ( IX + 0x07 () ) to Accumulator
[0x2eb3] 11955   0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
[0x2eb6] 11958   0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
[0x2eb9] 11961   0xdd    LD A, (IX+d)    09          ;  Load Accumulator with location ( IX + 0x09 () )
[0x2ebc] 11964   0xdd    ADD A, (IX+d)   0a          ;  Add location ( IX + 0x0a () ) to Accumulator
[0x2ebf] 11967   0xdd    LD (IX+d), A    09          ;  Load location ( IX + 0x09 () ) with Accumulator
[0x2ec2] 11970   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2ec3] 11971   0xdd    LD A, (IX+d)    0b          ;  Load Accumulator with location ( IX + 0x0b () )
[0x2ec6] 11974   0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
[0x2ec8] 11976   0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
[0x2eca] 11978   0xdd    LD (IX+d), B    0f          ;  Load location ( IX + 0x0f () ) with register B

; $(IX+14) += $(IX+5);
; HL = 0x00, $(IX+14);
; A = $(IX+3);
; if ( A &= 0x70 )
; {
;     A cir>> 4;
;     B = A;
;     HL *= 2^B;  // B > 0;
; }
; $IY = L;
; A = L;
; A cir>>= 4;
; $(IY+3) = A;
; A = $(IX+11);
; jump_table(A);
[0x2ecd] 11981   0xdd    LD A, (IX+d)    0e          ;  Load Accumulator with location ( IX + 0x0e () )
[0x2ed0] 11984   0xdd    ADD A, (IX+d)   05          ;  Add location ( IX + 0x05 () ) to Accumulator
[0x2ed3] 11987   0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
[0x2ed6] 11990   0x6f    LD L, A                     ;  Load register L with Accumulator
[0x2ed7] 11991   0x26    LD H, N         00          ;  Load register H with 0x00 (0)
[0x2ed9] 11993   0xdd    LD A, (IX+d)    03          ;  Load Accumulator with location ( IX + 0x03 () )
[0x2edc] 11996   0xe6    AND N           70          ;  Bitwise AND of 0x70 (112) to Accumulator
[0x2ede] 11998   0x28    JR Z, N         08          ;  Jump relative 0x08 (8) if ZERO flag is 1
[0x2ee0] 12000   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ee1] 12001   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ee2] 12002   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ee3] 12003   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ee4] 12004   0x47    LD B, A                     ;  Load register B with Accumulator
[0x2ee5] 12005   0x29    ADD HL, HL                  ;  Add register pair HL to HL
[0x2ee6] 12006   0x10    DJNZ N          fd          ;  Decrement B and jump relative 0xfd (-3) if B!=0
[0x2ee8] 12008   0xfd    LD (IY+d), L    00          ;  Load location ( IY + 0x00 () ) with register L
[0x2eeb] 12011   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x2eec] 12012   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2eed] 12013   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2eee] 12014   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2eef] 12015   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ef0] 12016   0xfd    LD (IY+d), A    01          ;  Load location ( IY + 0x01 () ) with Accumulator
[0x2ef3] 12019   0xfd    LD (IY+d), H    02          ;  Load location ( IY + 0x02 () ) with register H
[0x2ef6] 12022   0x7c    LD A, H                     ;  Load Accumulator with register H
[0x2ef7] 12023   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ef8] 12024   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2ef9] 12025   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2efa] 12026   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x2efb] 12027   0xfd    LD (IY+d), A    03          ;  Load location ( IY + 0x03 () ) with Accumulator
[0x2efe] 12030   0xdd    LD A, (IX+d)    0b          ;  Load Accumulator with location ( IX + 0x0b () )
[0x2f01] 12033   0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $2F22 : A = $(IX+15);
; 1 : $2F26 : A = ( $(IX+15) & 0x0F ) ? --$(IX+15) : $(IX+15);
; 2 : $2F2B : if ( $4C84 & 0x01 ) return;  A = ( $(IX+15) & 0x0F ) ? --$(IX+15) : $(IX+15);  return;
; 3 : $2F3C : if ( $4C84 & 0x03 ) return;  A = ( $(IX+15) & 0x0F ) ? --$(IX+15) : $(IX+15);  return;
; 4 : $2F43 : if ( $4C84 & 0x07 ) return;  A = ( $(IX+15) & 0x0F ) ? --$(IX+15) : $(IX+15);  return;
; 5 : $2F4A : return;
; 6 : $2F4B : return;
; 7 : $2F4C : return;
; 8 : $2F4D : return;
; 9 : $2F4E : return;
; 10 : $2F4F : return;
; 11 : $2F50 : return;
; 12 : $2F51 : return;
; 13 : $2F52 : return;
; 14 : $2F53 : return;
; 15 : $2F54 : return;


; A = $(IX+15);
[0x2f22] 12066   0xdd    LD A, (IX+d)    0f          ;  Load Accumulator with location ( IX + 0x0f () )
[0x2f25] 12069   0xc9    RET                         ;  Return


; if ( A = $(IX+15) & 0x0F ) A = --$(IX+15);  return;    // via jump
[0x2f26] 12070   0xdd    LD A, (IX+d)    0f          ;  Load Accumulator with location ( IX + 0x0f () )
[0x2f29] 12073   0x18    JR N            09          ;  Jump relative 0x09 (9)
; if ( $4C84 & 0x01 ) return;  if ( A = $(IX+15) & 0x0F ) A = --$(IX+15);  return;
[0x2f2b] 12075   0x3a    LD A, (NN)      844c        ;  Load Accumulator with location 0x844c (19588)
[0x2f2e] 12078   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
[0x2f30] 12080   0xdd    LD A, (IX+d)    0f          ;  Load Accumulator with location ( IX + 0x0f () )
[0x2f33] 12083   0xc0    RET NZ                      ;  Return if ZERO flag is 0
[0x2f34] 12084   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x2f36] 12086   0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x2f37] 12087   0x3d    DEC A                       ;  Decrement Accumulator
[0x2f38] 12088   0xdd    LD (IX+d), A    0f          ;  Load location ( IX + 0x0f () ) with Accumulator
[0x2f3b] 12091   0xc9    RET                         ;  Return


; if ( $4C84 & 0x03 ) return;  if ( A = $(IX+15) & 0x0F ) A = --$(IX+15);  return;    // via jump
[0x2f3c] 12092   0x3a    LD A, (NN)      844c        ;  Load Accumulator with location 0x844c (19588)
[0x2f3f] 12095   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
[0x2f41] 12097   0x18    JR N            ed          ;  Jump relative 0xed (-19)


; if ( $4C84 & 0x07 ) return;  if ( A = $(IX+15) & 0x0F ) A = --$(IX+15);  return;    // via jump
[0x2f43] 12099   0x3a    LD A, (NN)      844c        ;  Load Accumulator with location 0x844c (19588)
[0x2f46] 12102   0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
[0x2f48] 12104   0x18    JR N            e6          ;  Jump relative 0xe6 (-26)


[0x2f4a] 12106   0xc9    RET                         ;  Return
[0x2f4b] 12107   0xc9    RET                         ;  Return
[0x2f4c] 12108   0xc9    RET                         ;  Return
[0x2f4d] 12109   0xc9    RET                         ;  Return
[0x2f4e] 12110   0xc9    RET                         ;  Return
[0x2f4f] 12111   0xc9    RET                         ;  Return
[0x2f50] 12112   0xc9    RET                         ;  Return
[0x2f51] 12113   0xc9    RET                         ;  Return
[0x2f52] 12114   0xc9    RET                         ;  Return
[0x2f53] 12115   0xc9    RET                         ;  Return
[0x2f54] 12116   0xc9    RET                         ;  Return


; dereference_IX67();
; $(IX+6/7) = $$(IX+6/7);
[0x2f55] 12117   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
[0x2f58] 12120   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
[0x2f5b] 12123   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2f5c] 12124   0xdd    LD (IX+d), A    06          ;  Load location ( IX + 0x06 () ) with Accumulator
[0x2f5f] 12127   0x23    INC HL                      ;  Increment register pair HL
[0x2f60] 12128   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2f61] 12129   0xdd    LD (IX+d), A    07          ;  Load location ( IX + 0x07 () ) with Accumulator
[0x2f64] 12132   0xc9    RET                         ;  Return


; IX67_to_IX3();
; $(IX+3) = $$(IX+6/7);  $(IX+6/7)++;
[0x2f65] 12133   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
[0x2f68] 12136   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
[0x2f6b] 12139   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2f6c] 12140   0x23    INC HL                      ;  Increment register pair HL
[0x2f6d] 12141   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
[0x2f70] 12144   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
[0x2f73] 12147   0xdd    LD (IX+d), A    03          ;  Load location ( IX + 0x03 () ) with Accumulator
[0x2f76] 12150   0xc9    RET                         ;  Return


; IX67_to_IX4();
; $(IX+4) = $$(IX+6/7);  $(IX+6/7)++;
[0x2f77] 12151   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
[0x2f7a] 12154   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
[0x2f7d] 12157   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2f7e] 12158   0x23    INC HL                      ;  Increment register pair HL
[0x2f7f] 12159   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
[0x2f82] 12162   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
[0x2f85] 12165   0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
[0x2f88] 12168   0xc9    RET                         ;  Return


; IX67_to_IX9();
; $(IX+9) = $$(IX+6/7);  $(IX+6/7)++;
[0x2f89] 12169   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
[0x2f8c] 12172   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
[0x2f8f] 12175   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2f90] 12176   0x23    INC HL                      ;  Increment register pair HL
[0x2f91] 12177   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
[0x2f94] 12180   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
[0x2f97] 12183   0xdd    LD (IX+d), A    09          ;  Load location ( IX + 0x09 () ) with Accumulator
[0x2f9a] 12186   0xc9    RET                         ;  Return


; IX67_to_IX11();
; $(IX+11) = $$(IX+6/7);  $(IX+6/7)++;
[0x2f9b] 12187   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
[0x2f9e] 12190   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
[0x2fa1] 12193   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x2fa2] 12194   0x23    INC HL                      ;  Increment register pair HL
[0x2fa3] 12195   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
[0x2fa6] 12198   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
[0x2fa9] 12201   0xdd    LD (IX+d), A    0b          ;  Load location ( IX + 0x0b () ) with Accumulator
[0x2fac] 12204   0xc9    RET                         ;  Return


; $IX &= compliment($IX2);
; jump(11764);
[0x2fad] 12205   0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
[0x2fb0] 12208   0x2f    CPL                         ;  Complement Accumulator (1's complement)
[0x2fb1] 12209   0xdd    AND A, (IX+d)   00          ;  Bitwise AND location ( IX + 0x00 () ) with Accumulator
[0x2fb4] 12212   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
[0x2fb7] 12215   0xc3    JP NN           f42d        ;  Jump to 0xf42d (11764)


[0x2fba] 12218   0x00    NOP                         ;  No Operation
[0x2fbb] 12219   0x00    NOP                         ;  No Operation
[0x2fbc] 12220   0x00    NOP                         ;  No Operation
[0x2fbd] 12221   0x00    NOP                         ;  No Operation
[0x2fbe] 12222   0x00    NOP                         ;  No Operation
[0x2fbf] 12223   0x00    NOP                         ;  No Operation
[0x2fc0] 12224   0x00    NOP                         ;  No Operation
[0x2fc1] 12225   0x00    NOP                         ;  No Operation
[0x2fc2] 12226   0x00    NOP                         ;  No Operation
[0x2fc3] 12227   0x00    NOP                         ;  No Operation
[0x2fc4] 12228   0x00    NOP                         ;  No Operation
[0x2fc5] 12229   0x00    NOP                         ;  No Operation
[0x2fc6] 12230   0x00    NOP                         ;  No Operation
[0x2fc7] 12231   0x00    NOP                         ;  No Operation
[0x2fc8] 12232   0x00    NOP                         ;  No Operation
[0x2fc9] 12233   0x00    NOP                         ;  No Operation
[0x2fca] 12234   0x00    NOP                         ;  No Operation
[0x2fcb] 12235   0x00    NOP                         ;  No Operation
[0x2fcc] 12236   0x00    NOP                         ;  No Operation
[0x2fcd] 12237   0x00    NOP                         ;  No Operation
[0x2fce] 12238   0x00    NOP                         ;  No Operation
[0x2fcf] 12239   0x00    NOP                         ;  No Operation
[0x2fd0] 12240   0x00    NOP                         ;  No Operation
[0x2fd1] 12241   0x00    NOP                         ;  No Operation
[0x2fd2] 12242   0x00    NOP                         ;  No Operation
[0x2fd3] 12243   0x00    NOP                         ;  No Operation
[0x2fd4] 12244   0x00    NOP                         ;  No Operation
[0x2fd5] 12245   0x00    NOP                         ;  No Operation
[0x2fd6] 12246   0x00    NOP                         ;  No Operation
[0x2fd7] 12247   0x00    NOP                         ;  No Operation
[0x2fd8] 12248   0x00    NOP                         ;  No Operation
[0x2fd9] 12249   0x00    NOP                         ;  No Operation
[0x2fda] 12250   0x00    NOP                         ;  No Operation
[0x2fdb] 12251   0x00    NOP                         ;  No Operation
[0x2fdc] 12252   0x00    NOP                         ;  No Operation
[0x2fdd] 12253   0x00    NOP                         ;  No Operation
[0x2fde] 12254   0x00    NOP                         ;  No Operation
[0x2fdf] 12255   0x00    NOP                         ;  No Operation
[0x2fe0] 12256   0x00    NOP                         ;  No Operation
[0x2fe1] 12257   0x00    NOP                         ;  No Operation
[0x2fe2] 12258   0x00    NOP                         ;  No Operation
[0x2fe3] 12259   0x00    NOP                         ;  No Operation
[0x2fe4] 12260   0x00    NOP                         ;  No Operation
[0x2fe5] 12261   0x00    NOP                         ;  No Operation
[0x2fe6] 12262   0x00    NOP                         ;  No Operation
[0x2fe7] 12263   0x00    NOP                         ;  No Operation
[0x2fe8] 12264   0x00    NOP                         ;  No Operation
[0x2fe9] 12265   0x00    NOP                         ;  No Operation
[0x2fea] 12266   0x00    NOP                         ;  No Operation
[0x2feb] 12267   0x00    NOP                         ;  No Operation
[0x2fec] 12268   0x00    NOP                         ;  No Operation
[0x2fed] 12269   0x00    NOP                         ;  No Operation
[0x2fee] 12270   0x00    NOP                         ;  No Operation
[0x2fef] 12271   0x00    NOP                         ;  No Operation
[0x2ff0] 12272   0x00    NOP                         ;  No Operation
[0x2ff1] 12273   0x00    NOP                         ;  No Operation
[0x2ff2] 12274   0x00    NOP                         ;  No Operation
[0x2ff3] 12275   0x00    NOP                         ;  No Operation
[0x2ff4] 12276   0x00    NOP                         ;  No Operation
[0x2ff5] 12277   0x00    NOP                         ;  No Operation
[0x2ff6] 12278   0x00    NOP                         ;  No Operation
[0x2ff7] 12279   0x00    NOP                         ;  No Operation
[0x2ff8] 12280   0x00    NOP                         ;  No Operation
[0x2ff9] 12281   0x00    NOP                         ;  No Operation
[0x2ffa] 12282   0x00    NOP                         ;  No Operation
[0x2ffb] 12283   0x00    NOP                         ;  No Operation
[0x2ffc] 12284   0x00    NOP                         ;  No Operation
[0x2ffd] 12285   0x00    NOP                         ;  No Operation

;Checksum: 0x83, 0x4C


;;; system_check()
; System Check V-Sync interrupt handler
; ROM CRC Check (skips every other byte)
;
; HL = 0x0000;
; do
; {
;     do
;     {
;         B = 0x10; C = 0x00;        // BC = 0x1000;
;         for ( B=0x10; B!=0; B-- )
;         {
;             (char *)(0xC050) = A;  // reset watchdog
;             do
;             {
;                 A = C;
;                 A += (char *)HL;       // no carry
;                 C = A;
;                 A = L;
;                 A += 2;
;                 L = A;
;             } while ( A > 2 )
;             H++;
;         }
;         if ( C = 0 ) { jump_relative_+21() }
;         (char *)(0xC007) = A;  // clear coincounter
;     } while ( H != 0x30 )
;     H=0x00;
;     L++;
; } while ( L < 2 )
; jump(12354)
;
[0x3000] 12288   0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
[0x3003] 12291   0x01    LD  BC, NN      0010        ;  Load register pair BC with 0x0010 (4096)
; Watchdog set to A
[0x3006] 12294   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x3009] 12297   0x79    LD A, C                     ;  Load Accumulator with register C
[0x300a] 12298   0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
[0x300b] 12299   0x4f    LD C, A                     ;  Load register C with Accumulator
[0x300c] 12300   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x300d] 12301   0xc6    ADD A, N        02          ;  Add 0x02 (2) to Accumulator (no carry)
[0x300f] 12303   0x6f    LD L, A                     ;  Load register L with Accumulator
[0x3010] 12304   0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
[0x3012] 12306   0xd2    JP NC, NN       0930        ;  Jump to 0x0930 (12297) if CARRY flag is 0
[0x3015] 12309   0x24    INC H                       ;  Increment register H
[0x3016] 12310   0x10    DJNZ N          ee          ;  Decrement B and jump relative 0xee (-18) if B!=0
[0x3018] 12312   0x79    LD A, C                     ;  Load Accumulator with register C
[0x3019] 12313   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
; often patched to NOP, NOP to defeat ROM checksum
[0x301a] 12314   0x20    JR NZ, N        15          ;  Jump relative 0x15 (21) if ZERO flag is 0
; Clear coin
[0x301c] 12316   0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
[0x301f] 12319   0x7c    LD A, H                     ;  Load Accumulator with register H
[0x3020] 12320   0xfe    CP N            30          ;  Compare 0x30 (48) with Accumulator
[0x3022] 12322   0xc2    JP NZ, NN       0330        ;  Jump to 0x0330 (12291) if ZERO flag is 0
[0x3025] 12325   0x26    LD H, N         00          ;  Load register H with 0x00 (0)
[0x3027] 12327   0x2c    INC L                       ;  Increment register L
[0x3028] 12328   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x3029] 12329   0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
[0x302b] 12331   0xda    JP C, NN        0330        ;  Jump to 0x0330 (12291) if CARRY flag is 1
[0x302e] 12334   0xc3    JP NN           4230        ;  Jump to 0x4230 (12354)


;;; checksum_failure()
; // H == { 0x10, 0x20, 0x30, 0x40 } // top nibble of the last 1K page CRC'ed before failure + 1
; H--;
; H &= 0xf0;
; (char *)(0xC007) = A;  // clear coincounter
; H = H << 4;            // wraps around.  Now H = { 0x00, 0x01, 0x02, 0x03 }
; E = H;
; B = 0;
; jump(12477); // B == 0, E == which 1k page failed checksum
[0x3031] 12337   0x25    DEC H                       ;  Decrement register H
[0x3032] 12338   0x7c    LD A, H                     ;  Load Accumulator with register H
[0x3033] 12339   0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
[0x3035] 12341   0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
[0x3038] 12344   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x3039] 12345   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x303a] 12346   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x303b] 12347   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x303c] 12348   0x5f    LD E, A                     ;  Load register E with Accumulator
[0x303d] 12349   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
[0x303f] 12351   0xc3    JP NN           bd30        ;  Jump to 0xbd30 (12477)

;;; video_test()
; checksum ok... let's continue
; Clear $4C00-$4FFF with random numbers
; //$C = 255;  // to start
; Location = $C
; 0..15 : $C = ( ( $C & 0x0F ) + 51 ) % 256;
;    16 : $C = ( ( ( ( $C & 0x0F ) + 51 ) * 5 ) + 49 ) % 256;
;; Pattern repeats every 256 iterations.
[0x3042] 12354   0x31    LD SP, NN       5431        ;  Load register pair SP with 0x5431 (12628)
[0x3045] 12357   0x06    LD  B, N        ff          ;  Load register B with 0xff (255)
; HL = 0x4C00
[0x3047] 12359   0xe1    POP HL                      ;  Load register pair HL with top of stack
; DE = 0x040F
[0x3048] 12360   0xd1    POP DE                      ;  Load register pair DE with top of stack
[0x3049] 12361   0x48    LD C, B                     ;  Load register C with register B
; Watchdog set to A
[0x304a] 12362   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator

; wild random number generator for clearing RAM
[0x304d] 12365   0x79    LD A, C                     ;  Load Accumulator with register C
[0x304e] 12366   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
; (HL)=C & 0x0F
[0x304f] 12367   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x3050] 12368   0xc6    ADD A, N        33          ;  Add 0x33 (51) to Accumulator (no carry)
[0x3052] 12370   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x3053] 12371   0x2c    INC L                       ;  Increment register L
[0x3054] 12372   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x3055] 12373   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x3057] 12375   0xc2    JP NZ, NN       4d30        ;  Jump to 0x4d30 (12365) if ZERO flag is 0
; next 6: C = (C*5 + 49) % 256
[0x305a] 12378   0x79    LD A, C                     ;  Load Accumulator with register C
[0x305b] 12379   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x305c] 12380   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x305d] 12381   0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x305e] 12382   0xc6    ADD A, N        31          ;  Add 0x31 (49) to Accumulator (no carry)
[0x3060] 12384   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x3061] 12385   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x3062] 12386   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x3063] 12387   0xc2    JP NZ, NN       4d30        ;  Jump to 0x4d30 (12365) if ZERO flag is 0

[0x3066] 12390   0x24    INC H                       ;  Increment register H
[0x3067] 12391   0x15    DEC D                       ;  Decrement register D
[0x3068] 12392   0xc2    JP NZ, NN       4a30        ;  Jump to 0x4a30 (12362) if ZERO flag is 0

; back up stack and do the same algorithm, but just read and verify
[0x306b] 12395   0x3b    DEC SP                      ;  Decrement register pair SP
[0x306c] 12396   0x3b    DEC SP                      ;  Decrement register pair SP
[0x306d] 12397   0x3b    DEC SP                      ;  Decrement register pair SP
[0x306e] 12398   0x3b    DEC SP                      ;  Decrement register pair SP
[0x306f] 12399   0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x3070] 12400   0xd1    POP DE                      ;  Load register pair DE with top of stack
[0x3071] 12401   0x48    LD C, B                     ;  Load register C with register B
[0x3072] 12402   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; next 3: Similiar to 12367, but reading back instead
[0x3075] 12405   0x79    LD A, C                     ;  Load Accumulator with register C
[0x3076] 12406   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
[0x3077] 12407   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x3078] 12408   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x3079] 12409   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
[0x307a] 12410   0xb9    CP A, C                     ;  Compare register C with Accumulator
; Jump to 12469 if any byte fails verification
[0x307b] 12411   0xc2    JP NZ, NN       b530        ;  Jump to 0xb530 (12469) if ZERO flag is 0
[0x307e] 12414   0xc6    ADD A, N        33          ;  Add 0x33 (51) to Accumulator (no carry)
[0x3080] 12416   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x3081] 12417   0x2c    INC L                       ;  Increment register L
[0x3082] 12418   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x3083] 12419   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x3085] 12421   0xc2    JP NZ, NN       7530        ;  Jump to 0x7530 (12405) if ZERO flag is 0
; next 6: C = (C*5 + 49) % 256
[0x3088] 12424   0x79    LD A, C                     ;  Load Accumulator with register C
[0x3089] 12425   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x308a] 12426   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
[0x308b] 12427   0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
[0x308c] 12428   0xc6    ADD A, N        31          ;  Add 0x31 (49) to Accumulator (no carry)
[0x308e] 12430   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x308f] 12431   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x3090] 12432   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x3091] 12433   0xc2    JP NZ, NN       7530        ;  Jump to 0x7530 (12405) if ZERO flag is 0
[0x3094] 12436   0x24    INC H                       ;  Increment register H
[0x3095] 12437   0x15    DEC D                       ;  Decrement register D
[0x3096] 12438   0xc2    JP NZ, NN       7230        ;  Jump to 0x7230 (12402) if ZERO flag is 0

;
[0x3099] 12441   0x3b    DEC SP                      ;  Decrement register pair SP
[0x309a] 12442   0x3b    DEC SP                      ;  Decrement register pair SP
[0x309b] 12443   0x3b    DEC SP                      ;  Decrement register pair SP
[0x309c] 12444   0x3b    DEC SP                      ;  Decrement register pair SP
[0x309d] 12445   0x78    LD A, B                     ;  Load Accumulator with register B
[0x309e] 12446   0xd6    SUB N           10          ;  Subtract 0x10 (16) from Accumulator (no carry)
[0x30a0] 12448   0x47    LD B, A                     ;  Load register B with Accumulator
; Do the test 16 times
[0x30a1] 12449   0x10    DJNZ N          a4          ;  Decrement B and jump relative 0xa4 (-92) if B!=0

;  Different behavior based on the area being tested?  Seems like this function could take
;  multiple memory areas if the table was properly pre-populated
[0x30a3] 12451   0xf1    POP AF                      ;  Load register pair AF with top of stack
[0x30a4] 12452   0xd1    POP DE                      ;  Load register pair DE with top of stack
[0x30a5] 12453   0xfe    CP N            44          ;  Compare 0x44 (68) with Accumulator
[0x30a7] 12455   0xc2    JP NZ, NN       4530        ;  Jump to 0x4530 (12357) if ZERO flag is 0
[0x30aa] 12458   0x7b    LD A, E                     ;  Load Accumulator with register E
[0x30ab] 12459   0xee    XOR N           f0          ;  Bitwise XOR of 0xf0 (240) to Accumulator
[0x30ad] 12461   0xc2    JP NZ, NN       4530        ;  Jump to 0x4530 (12357) if ZERO flag is 0
[0x30b0] 12464   0x06    LD  B, N        01          ;  Load register B with 0x01 (1)
[0x30b2] 12466   0xc3    JP NN           bd30        ;  Jump to 0xbd30 (12477)

;; failed color RAM test, set some params, fall through to clear screen, then display error codes
; E = (E & 0x01) ^ 0x01;  // mask and invert E:0
[0x30b5] 12469   0x7b    LD A, E                     ;  Load Accumulator with register E
[0x30b6] 12470   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
[0x30b8] 12472   0xee    XOR N           01          ;  Bitwise XOR of 0x01 (1) to Accumulator
[0x30ba] 12474   0x5f    LD E, A                     ;  Load register E with Accumulator
[0x30bb] 12475   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)


; CLEAR RAM()
; Swap out BC,DE,HL...
[0x30bd] 12477   0x31    LD SP, NN       c04f        ;  Load register pair SP with 0xc04f (20416)
[0x30c0] 12480   0xd9    EXX                         ;  Exchange the contents of BC,DE,HL with BC',DE',HL'

; ...and clear 0x4C00-0x4FFF...
[0x30c1] 12481   0x21    LD HL, NN       004c        ;  Load register pair HL with 0x004c (19456)
[0x30c4] 12484   0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
; (reset watchdog)
[0x30c6] 12486   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x30c9] 12489   0x36    LD (HL), N      00          ;  Load location (HL) with 0x00 (0)
[0x30cb] 12491   0x2c    INC L                       ;  Increment register L
[0x30cc] 12492   0x20    JR NZ, N        fb          ;  Jump relative 0xfb (-5) if ZERO flag is 0
[0x30ce] 12494   0x24    INC H                       ;  Increment register H
[0x30cf] 12495   0x10    DJNZ N          f5          ;  Decrement B and jump relative 0xf5 (-11) if B!=0

; ...then clear video memory (0x4000-0x43FF) with spaces (0x40)...
[0x30d1] 12497   0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
[0x30d4] 12500   0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
; (reset watchdog)
[0x30d6] 12502   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x30d9] 12505   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
[0x30db] 12507   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x30dc] 12508   0x2c    INC L                       ;  Increment register L
[0x30dd] 12509   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
[0x30df] 12511   0x24    INC H                       ;  Increment register H
[0x30e0] 12512   0x10    DJNZ N          f4          ;  Decrement B and jump relative 0xf4 (-12) if B!=0

; ...then clear color memory (0x4400-0x47FF) with white/green/red/black palette (0x0F)...
[0x30e2] 12514   0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
[0x30e4] 12516   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x30e7] 12519   0x3e    LD A,N          0f          ;  Load Accumulator with 0x0f (15)
[0x30e9] 12521   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x30ea] 12522   0x2c    INC L                       ;  Increment register L
[0x30eb] 12523   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
[0x30ed] 12525   0x24    INC H                       ;  Increment register H
[0x30ee] 12526   0x10    DJNZ N          f4          ;  Decrement B and jump relative 0xf4 (-12) if B!=0
; ...and swap BC,DE,HL back in
[0x30f0] 12528   0xd9    EXX                         ;  Exchange the contents of BC,DE,HL with BC',DE',HL'

; B--;  if ( B==0 ) {  B=35;  call(11358);  jump(12660);  }
;       else {  jump(12539);  } // in checksum failure B != 0
[0x30f1] 12529   0x10    DJNZ N          08          ;  Decrement B and jump relative 0x08 (8) if B!=0
; write_string(35); "MEMORY  OK"
[0x30f3] 12531   0x06    LD  B, N        23          ;  Load register B with 0x23 (35)
[0x30f5] 12533   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
[0x30f8] 12536   0xc3    JP NN           7431        ;  Jump to 0x7431 (12660)

; Display the page that failed the checksum
; // E == { 0x00, 0x01, 0x02, 0x03 } // page that failed the checksum
; A = E;
; E += 0x30;                         // ASCII 0x30 = '0', 0x31 = '1', etc.
; (char *)(0x4184) = A;              // four from the top, just left of center on playing field
[0x30fb] 12539   0x7b    LD A, E                     ;  Load Accumulator with register E
[0x30fc] 12540   0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
[0x30fe] 12542   0x32    LD (NN), A      8441        ;  Load location 0x8441 (16772) with the Accumulator

; write_string(36); "BAD    R M"
[0x3101] 12545   0xc5    PUSH BC                     ;  Load the stack with register pair BC
[0x3102] 12546   0xe5    PUSH HL                     ;  Load the stack with register pair HL
[0x3103] 12547   0x06    LD  B, N        24          ;  Load register B with 0x24 (36)
[0x3105] 12549   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

; HL = pop();
; A = H;
; A == 0..64  : HL = 0x316C; //  0x4F, 0x40 "O "
; A == 65..68 : HL = 0x3170; //  0x41, 0x56 "AV"
; A == 69..75 : HL = 0x3172; //  0x41, 0x43 "AC"
; A == 76.... : HL = 0x316E; //  0x41, 0x57 "AW"
[0x3108] 12552   0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x3109] 12553   0x7c    LD A, H                     ;  Load Accumulator with register H
[0x310a] 12554   0xfe    CP N            40          ;  Compare 0x40 (64) with Accumulator
[0x310c] 12556   0x2a    LD HL, (NN)     6c31        ;  Load register pair HL with location 0x6c31 (12652)
[0x310f] 12559   0x38    JR C, N         11          ;  Jump relative 0x11 (17) if CARRY flag is 1
[0x3111] 12561   0xfe    CP N            4c          ;  Compare 0x4c (76) with Accumulator
[0x3113] 12563   0x2a    LD HL, (NN)     6e31        ;  Load register pair HL with location 0x6e31 (12654)
[0x3116] 12566   0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
[0x3118] 12568   0xfe    CP N            44          ;  Compare 0x44 (68) with Accumulator
[0x311a] 12570   0x2a    LD HL, (NN)     7031        ;  Load register pair HL with location 0x7031 (12656)
[0x311d] 12573   0x38    JR C, N         03          ;  Jump to 0x03 (3) if CARRY flag is 1
[0x311f] 12575   0x2a    LD HL, (NN)     7231        ;  Load register pair HL with location 0x7231 (12658)
; $4204 = L;
; $4264 = H;
[0x3122] 12578   0x7d    LD A, L                     ;  Load Accumulator with register L
[0x3123] 12579   0x32    LD (NN), A      0442        ;  Load location 0x0442 (16900) with the Accumulator
[0x3126] 12582   0x7c    LD A, H                     ;  Load Accumulator with register H
[0x3127] 12583   0x32    LD (NN), A      6442        ;  Load location 0x6442 (16996) with the Accumulator
; if ( $5000 | $5040 & 0x01 ) // either joystick is 'up'
; {
;     BC = pop();
;     B = C & 0x0F;
;     C &= 0xF0;
;     C C>> 4;
;     $4185 = BC;
; }
[0x312a] 12586   0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
[0x312d] 12589   0x47    LD B, A                     ;  Load register B with Accumulator
[0x312e] 12590   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x3131] 12593   0xb0    OR A, B                     ;  Bitwise OR of register B to Accumulator
[0x3132] 12594   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
[0x3134] 12596   0x20    JR NZ, N        11          ;  Jump relative 0x11 (17) if ZERO flag is 0
[0x3136] 12598   0xc1    POP BC                      ;  Load register pair BC with top of stack
[0x3137] 12599   0x79    LD A, C                     ;  Load Accumulator with register C
[0x3138] 12600   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
[0x313a] 12602   0x47    LD B, A                     ;  Load register B with Accumulator
[0x313b] 12603   0x79    LD A, C                     ;  Load Accumulator with register C
[0x313c] 12604   0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
[0x313e] 12606   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x313f] 12607   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x3140] 12608   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x3141] 12609   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x3142] 12610   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x3143] 12611   0xed    LD (NN), BC     8541        ;  Load location 0x8541 (16773) with register pair BC
; repeat { kick_dog() } until ( servicemode != 1 );
[0x3147] 12615   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x314a] 12618   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x314d] 12621   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
[0x314f] 12623   0x28    JR Z, N         f6          ;  Jump relative 0xf6 (-10) if ZERO flag is 1
[0x3151] 12625   0xc3    JP NN           0b23        ;  Jump to 0x0b23 (8971)

; tabular data used by the video testing routines @ 12354
; 12628 : 0x4C00, 0x040F
; 12632 : 0x4C00, 0x040F
; 12636 : 0x4000, 0x04F0
; 12640 : 0x4000, 0x04F0
; 12644 : 0x4400, 0x040F
; 12648 : 0x4400, 0x04F0

; two-character status codes for the system test @ 12552
; 12652 : "O "
; 12654 : "AW"
; 12656 : "AV"
; 12658 : "AC"


;;; display_config()?
; Fill 0x5006-0x5001 with 0x01
[0x3174] 12660   0x21    LD HL, NN       0650        ;  Load register pair HL with 0x0650 (20486)
[0x3177] 12663   0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x3179] 12665   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x317a] 12666   0x2d    DEC L                       ;  Decrement register L
[0x317b] 12667   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
; flip the screen back to normal (0x5003 = 0)
[0x317d] 12669   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x317e] 12670   0x32    LD (NN), A      0350        ;  Load location 0x0350 (20483) with the Accumulator
; Set interrupt vector for V-Sync to entry 252 ($(3F00+FC) == 0x8D00 == 141)
[0x3181] 12673   0xd6    SUB N           04          ;  Subtract 0x04 (4) from Accumulator (no carry)
[0x3183] 12675   0xd3    OUT (N),A       00          ;  Load output port 0x00 (0) with Accumulator
[0x3185] 12677   0x31    LD SP, NN       c04f        ;  Load register pair SP with 0xc04f (20416)

; (reset watchdog)
[0x3188] 12680   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; (0x4E00) = 0, (0x4E01) = 1
[0x318b] 12683   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x318c] 12684   0x32    LD (NN), A      004e        ;  Load location 0x004e (19968) with the Accumulator
[0x318f] 12687   0x3c    INC A                       ;  Increment Accumulator
[0x3190] 12688   0x32    LD (NN), A      014e        ;  Load location 0x014e (19969) with the Accumulator
; Arm external interrupt latch, enable interrupts
[0x3193] 12691   0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
[0x3196] 12694   0xfb    EI                          ;  Enable Interrupts

; Read IN0: 01=1up,02=1left,04=1right,08=1down,10=rack test,20=coin 1,40=coin 2,80=coin 3
; Set (0x4E9C) to 2 if we have coins
; Leave a copy of complimented IN0 in B
[0x3197] 12695   0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
[0x319a] 12698   0x2f    CPL                         ;  Complement Accumulator (reverse bitwise)
[0x319b] 12699   0x47    LD B, A                     ;  Load register B with Accumulator
[0x319c] 12700   0xe6    AND N           e0          ;  Bitwise AND of 0xe0 (224) to Accumulator
[0x319e] 12702   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0x31a0] 12704   0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
[0x31a2] 12706   0x32    LD (NN), A      9c4e        ;  Load location 0x9c4e (20124) with the Accumulator

; Read IN1: 01=2up,02=2left,04=2right,08=2down,10=service,20=start 1,40=start 2,80=cabinet upright
; Set (0x4E9E) to 1 if we have player 1 or 2 start
; Leave a copy of complimented IN1 in C
[0x31a5] 12709   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x31a8] 12712   0x2f    CPL                         ;  Complement Accumulator (reverse bitwise)
[0x31a9] 12713   0x4f    LD c, A                     ;  Load register C with Accumulator
[0x31aa] 12714   0xe6    AND N           60          ;  Bitwise AND of 0x60 (96) to Accumulator
[0x31ac] 12716   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0x31ae] 12718   0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
[0x31b0] 12720   0x32    LD (NN), A      9c4e        ;  Load location 0x9c4e (20124) with the Accumulator

; If either joystick is pointing up ((B|C)&0x01), set (0x4EBC) to 8
[0x31b3] 12723   0x78    LD A, B                     ;  Load Accumulator with register B
[0x31b4] 12724   0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x31b5] 12725   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
[0x31b7] 12727   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0x31b9] 12729   0x3e    LD A,N          08          ;  Load Accumulator with 0x08 (8)
[0x31bb] 12731   0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator

; If either joystick is pointing left ((B|C)&0x02), set (0x4EBC) to 4
[0x31be] 12734   0x78    LD A, B                     ;  Load Accumulator with register B
[0x31bf] 12735   0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x31c0] 12736   0xe6    AND N           02          ;  Bitwise AND of 0x02 (2) to Accumulator
[0x31c2] 12738   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0x31c4] 12740   0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
[0x31c6] 12742   0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator

; If either joystick is pointing right ((B|C)&0x02), set (0x4EBC) to 16
[0x31c9] 12745   0x78    LD A, B                     ;  Load Accumulator with register B
[0x31ca] 12746   0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x31cb] 12747   0xe6    AND N           04          ;  Bitwise AND of 0x04 (4) to Accumulator
[0x31cd] 12749   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0x31cf] 12751   0x3e    LD A,N          10          ;  Load Accumulator with 0x10 (16)
[0x31d1] 12753   0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator

; If either joystick is pointing down ((B|C)&0x02), set (0x4EBC) to 32
[0x31d4] 12756   0x78    LD A, B                     ;  Load Accumulator with register B
[0x31d5] 12757   0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
[0x31d6] 12758   0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
[0x31d8] 12760   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
[0x31da] 12762   0x3e    LD A,N          20          ;  Load Accumulator with 0x20 (32)
[0x31dc] 12764   0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator

; Depending on the value of the 'credit' jumpers (0&1), display the proper message
; 37="FREE  PLAY"
; 38="1 COIN  1 CREDIT " 
; 39="1 COIN  2 CREDITS"
; 40="2 COINS 1 CREDIT "
[0x31df] 12767   0x3a    LD A, (NN)      8050        ;  Load Accumulator with location 0x8050 (20608)
[0x31e2] 12770   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
[0x31e4] 12772   0xc6    ADD A, N        25          ;  Add 0x25 (37) to Accumulator (no carry)
[0x31e6] 12774   0x47    LD B, A                     ;  Load register B with Accumulator
[0x31e7] 12775   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

; Depending on the value of the 'bonus' jumpers (4-7), display the proper message
; 0 = 10000
; 1 = 15000
; 2 = 20000
; 3 = No Bonus
[0x31ea] 12778   0x3a    LD A, (NN)      8050        ;  Load Accumulator with location 0x8050 (20608)
[0x31ed] 12781   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x31ee] 12782   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x31ef] 12783   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x31f0] 12784   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x31f1] 12785   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
[0x31f3] 12787   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
[0x31f5] 12789   0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
; No bonus, display "BONUS NONE" and jump over the bonus value display
; write_string(42); // "BONUS  NONE"
[0x31f7] 12791   0x06    LD  B, N        2a          ;  Load register B with 0x2a (42)
[0x31f9] 12793   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
[0x31fc] 12796   0xc3    JP NN           1c32        ;  Jump to 0x1c32 (12828)
; Bonus configured, display the triple zero tile + the number of thousands for the bonus
; after pushing, displaying "BONUS " and "000", and popping, E will contain
; either 0, 2 or 4
[0x31ff] 12799   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x3200] 12800   0x5f    LD E, A                     ;  Load register E with Accumulator
[0x3201] 12801   0xd5    PUSH DE                     ;  Load the stack with register pair DE
; write_string(43); "BONUS "
[0x3202] 12802   0x06    LD  B, N        2b          ;  Load register B with 0x2b (43)
[0x3204] 12804   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
; write_string(46); "000"
[0x3207] 12807   0x06    LD  B, N        2e          ;  Load register B with 0x2e (46)
[0x3209] 12809   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
[0x320c] 12812   0xd1    POP DE                      ;  Load register pair DE with top of stack
[0x320d] 12813   0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
; Index into the small table at 0x32F9 for the bonus sprite, write it to the screen at
; (0x422A) (remember, right to left, so this is the less significant digit of the two)
[0x320f] 12815   0x21    LD HL, NN       f932        ;  Load register pair HL with 0xf932 (13049)
[0x3212] 12818   0x19    ADD HL, DE                  ;  Add register pair DE to HL
[0x3213] 12819   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x3214] 12820   0x32    LD (NN), A      2a42        ;  Load location 0x2a42 (16938) with the Accumulator
; ... and display the second bonus display sprite (the more significant of the two)
[0x3217] 12823   0x23    INC HL                      ;  Increment register pair HL
[0x3218] 12824   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
[0x3219] 12825   0x32    LD (NN), A      4a42        ;  Load location 0x4a42 (16970) with the Accumulator

; Lives per play (jumpers 2&3)
; 0 = 1
; 1 = 2
; 2 = 3
; 3 = 5
[0x321c] 12828   0x3a    LD A, (NN)      8050        ;  Load Accumulator with location 0x8050 (20608)
[0x321f] 12831   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x3220] 12832   0x0f    RRCA                        ;  Rotate right circular Accumulator
[0x3221] 12833   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
; Accomodate 3 by adding 1; otherwise jumpers + 31 == correct number byte
[0x3223] 12835   0xc6    ADD A, N        31          ;  Add 0x31 (49) to Accumulator (no carry)
[0x3225] 12837   0xfe    CP N            34          ;  Compare 0x34 (52) with Accumulator
[0x3227] 12839   0x20    JR NZ, N        01          ;  Jump relative 0x01 (1) if ZERO flag is 0
[0x3229] 12841   0x3c    INC A                       ;  Increment Accumulator
[0x322a] 12842   0x32    LD (NN), A      0c42        ;  Load location 0x0c42 (16908) with the Accumulator

; write_string(41); "PAC-MAN"
[0x322d] 12845   0x06    LD  B, N        29          ;  Load register B with 0x29 (41)
[0x322f] 12847   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

; Read IN0: 01=2up,02=2left,04=2right,08=2down,10=service,20=start 1,40=start 2,80=cabinet upright
; Display table or upright (0=table, 1=upright)
[0x3232] 12850   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x3235] 12853   0x07    RLCA                        ;  Rotate left circular Accumulator
[0x3236] 12854   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
[0x3238] 12856   0xc6    ADD A, N        2c          ;  Add 0x2c (44) to Accumulator (no carry)
[0x323a] 12858   0x47    LD B, A                     ;  Load register B with Accumulator
[0x323b] 12859   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

; Keep showing this set of data while the service bit of IN0 is jumpered (remember.. jumpers == opposite)
[0x323e] 12862   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x3241] 12865   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
[0x3243] 12867   0xca    JP Z,           8831        ;  Jump to 0x8831 (12680) if ZERO flag is 1

; Clear Coin1/2/3, Rack Test, Joystick 1
[0x3246] 12870   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x3247] 12871   0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
[0x324a] 12874   0xf3    DI                          ;  Disable Interrupts


; Clear out 0x5007-0x5001 with 0x00
[0x324b] 12875   0x21    LD HL, NN       0750        ;  Load register pair HL with 0x0750 (20487)
[0x324e] 12878   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
[0x324f] 12879   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x3250] 12880   0x2d    DEC L                       ;  Decrement register L
[0x3251] 12881   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0


;;; set_game_params()?
;;; Munge $4002-$4005, $4040-$405D, $43C2-$4345 according to table at 15074
;; // Table at 15074:
;; //  H  L   D  E   B  C
;; //  40 02, 3e 01, 10 3d,
;; //  40 40, 3d 0e, 10 3e,
;; //  43 c2, 3e 01, 10 3d,
;; for([HL, DE, BC] = [[40 02, 3e 01, 10 3d], [40 40, 3d 0e, 10 3e], [43 c2, 3e 01, 10 3d]])
;; {
;;     for(E..0)
;;     {
;;         for(B..0)
;;         {
;;             $HL = 0x3C;  $HL++;
;;             $HL = D;     $HL++;
;;         }
;;         // Reset BC
;;         for(B..0)
;;         {
;;             $HL = C;     $HL++;
;;             $HL = 0x3F;  $HL++;
;;         }
;;         E--;
;;     }
;; }
; HL = 0xE23A // Table at 15074: 02 40, 01 3e, 3d 10,  40 40, 0e 3d, 3e 10,  c2 43, 01 3e, 3d 10,  21 a2 40
; B = 3;
; exchange_BC_DE_HL();  //  HL = last push, DE = second to last, BC = third to last
; pop_HL();
; pop_DE();
[0x3253] 12883   0x31    LD SP, NN       e23a        ;  Load register pair SP with 0xe23a (15074)
[0x3256] 12886   0x06    LD  B, N        03          ;  Load register B with 0x03 (3)

[0x3258] 12888   0xd9    EXX                         ;  Exchange the contents of BC,DE,HL with BC',DE',HL'
[0x3259] 12889   0xe1    POP HL                      ;  Load register pair HL with top of stack
[0x325a] 12890   0xd1    POP DE                      ;  Load register pair DE with top of stack
; while ( E != 0 ) 12891 to 12917, E--
; kick dog
[0x325b] 12891   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x325e] 12894   0xc1    POP BC                      ;  Load register pair BC with top of stack
; for B-1 times (HL=0x3C, HL++, HL=D, HL++ )
[0x325f] 12895   0x3e    LD A,N          3c          ;  Load Accumulator with 0x3c (60)
[0x3261] 12897   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x3262] 12898   0x23    INC HL                      ;  Increment register pair HL
[0x3263] 12899   0x72    LD (HL), D                  ;  Load location (HL) with register D
[0x3264] 12900   0x23    INC HL                      ;  Increment register pair HL
[0x3265] 12901   0x10    DJNZ N          f8          ;  Decrement B and jump relative 0xf8 (-8) if B!=0

; reload BC from stack
[0x3267] 12903   0x3b    DEC SP                      ;  Decrement register pair SP
[0x3268] 12904   0x3b    DEC SP                      ;  Decrement register pair SP
[0x3269] 12905   0xc1    POP BC                      ;  Load register pair BC with top of stack
; for B-1 times (HL=C, HL++, HL=0x3F, HL++ )
[0x326a] 12906   0x71    LD (HL), C                  ;  Load location (HL) with register C
[0x326b] 12907   0x23    INC HL                      ;  Increment register pair HL
[0x326c] 12908   0x3e    LD A,N          3f          ;  Load Accumulator with 0x3f (63)
[0x326e] 12910   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x326f] 12911   0x23    INC HL                      ;  Increment register pair HL
[0x3270] 12912   0x10    DJNZ N          f8          ;  Decrement B and jump relative 0xf8 (-8) if B!=0
[0x3272] 12914   0x3b    DEC SP                      ;  Decrement register pair SP
[0x3273] 12915   0x3b    DEC SP                      ;  Decrement register pair SP
[0x3274] 12916   0x1d    DEC E                       ;  Decrement register E
[0x3275] 12917   0xc2    JP NZ, NN       5b32        ;  Jump to 0x5b32 (12891) if ZERO flag is 0

; throw away to advance SP for loop to repeat
[0x3278] 12920   0xf1    POP AF                      ;  Load register pair AF with top of stack
[0x3279] 12921   0xd9    EXX                         ;  Exchange the contents of BC,DE,HL with BC',DE',HL'
[0x327a] 12922   0x10    DJNZ N          dc          ;  Decrement B and jump relative 0xdc (-36) if B!=0

; back to a normal stack
[0x327c] 12924   0x31    LD SP, NN       c04f        ;  Load register pair SP with 0xc04f (20416)

; call wait() 7 times
[0x327f] 12927   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
[0x3281] 12929   0xcd    CALL NN         ed32        ;  Call to 0xed32 (13037)
[0x3284] 12932   0x10    DJNZ N          fb          ;  Decrement B and jump relative 0xfb (-5) if B!=0


;;; easter_egg_part_one()
;;; Easter Egg, part 1: In service mode, hold down one of the start buttons and quickly toggle service mode
;;
;; while ( service_mode ) { }
;; if ( ! start1 && ! start2 ) {  jump(9035);  }
;; for(i=0;i<=8;i++)
;;     wait();  // 0.0866 * 8 = .683s
;; if ( service_mode ) {  jump(9035);  }
;;
; kick dog
[0x3286] 12934   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; Read IN1: 01=2up,02=2left,04=2right,08=2down,10=service,20=start 1,40=start 2,80=cabinet upright
; if service mode, infinite loop until it's not service mode
[0x3289] 12937   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x328c] 12940   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
[0x328e] 12942   0x28    JR Z, N         f6          ;  Jump relative 0xf6 (-10) if ZERO flag is 1
; if neither start button pressed, jump back to right after the HALT after setting V-sync
[0x3290] 12944   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x3293] 12947   0xe6    AND N           60          ;  Bitwise AND of 0x60 (96) to Accumulator
[0x3295] 12949   0xc2    JP NZ, NN       4b23        ;  Jump to 0x4b23 (9035) if ZERO flag is 0

; call wait() 7 times
[0x3298] 12952   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
[0x329a] 12954   0xcd    CALL NN         ed32        ;  Call to 0xed32 (13037)
[0x329d] 12957   0x10    DJNZ N          fb          ;  Decrement B and jump relative 0xfb (-5) if B!=0

; See if service bit is set again
[0x329f] 12959   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x32a2] 12962   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator

[0x32a4] 12964   0xc2    JP NZ, NN       4b23        ;  Jump to 0x4b23 (9035) if ZERO flag is 0


;;; easter_egg_part_two()
;;; Easter Egg, part 2: Four times each: joystick Up, Left, Right, then Down.  Short pauses in between each one.
;;
;;// important to remember: jumper blocks are default *CLOSED*, so bit testing is reversed
;;for E in ( Up, Left, Right, Down )
;;{
;;    wait_until_direction(E);
;;    wait_until_no_direction();
;;}
;;
; for E ( 0x01, 0x02, 0x04, 0x08 )
; {
;     for B (4..1)
;     {
;         // wait_until_direction(E);
;         while($5000 & E)          // while the "E" direction isn't triggered
;         {
;             kick_dog();
;             wait();  // _13037()
;         }
;
;         // wait_until_no_direction();
;         while($5000 ^ 0xFF != 0)  // while any direction is triggered
;         {
;             wait();  // _13037()
;             kick_dog();
;         }
;     }
; }
[0x32a7] 12967   0x1e    LD E,N          01          ;  Load register E with 0x01 (1)
[0x32a9] 12969   0x06    LD B,N          04          ;  Load register B with 0x04 (4)
; kick dog
[0x32ab] 12971   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; wait()
[0x32ae] 12974   0xcd    CALL NN         ed32        ;  Call to 0xed32 (13037)
; Read IN0: 01=1up,02=1left,04=1right,08=1down,10=rack test,20=coin 1,40=coin 2,80=coin 3
[0x32b1] 12977   0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
[0x32b4] 12980   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
[0x32b5] 12981   0x20    JR NZ, N        f4          ;  Jump relative 0xf4 (-12) if ZERO flag is 0
; wait()
[0x32b7] 12983   0xcd    CALL NN         ed32        ;  Call to 0xed32 (13037)
; kick dog
[0x32ba] 12986   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x32bd] 12989   0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
[0x32c0] 12992   0xee    XOR N           ff          ;  Bitwise XOR of 0xff (255) to Accumulator
[0x32c2] 12994   0x20    JR NZ, N        f3          ;  Jump relative 0xf3 (-13) if ZERO flag is 0
[0x32c4] 12996   0x10    DJNZ N          e5          ;  Decrement B and jump relative 0xe5 (-27) if B!=0
[0x32c6] 12998   0xcb    RLC E                       ;  Rotate register E left circular
[0x32c8] 13000   0x7b    LD A, E                     ;  Load Accumulator with register E
[0x32c9] 13001   0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
[0x32cb] 13003   0xda    JP C, NN        a932        ;  Jump to 0xa932 (12969) if CARRY flag is 1

; Clear 0x4000-0x43FF with 0x40
[0x32ce] 13006   0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
[0x32d1] 13009   0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
[0x32d3] 13011   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
[0x32d5] 13013   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
[0x32d6] 13014   0x2c    INC L                       ;  Increment register L
[0x32d7] 13015   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
[0x32d9] 13017   0x24    INC H                       ;  Increment register H
[0x32da] 13018   0x10    DJNZ N          f7          ;  Decrement B and jump relative 0xf7 (-9) if B!=0
[0x32dc] 13020   0xcd    CALL NN         f43a        ;  Call to 0xf43a (15092)

; kick dog
[0x32df] 13023   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; hang until rackmode jumper clear
[0x32e2] 13026   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
[0x32e5] 13029   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
[0x32e7] 13031   0xca    JP Z,           df32        ;  Jump to 0xdf32 (13023) if ZERO flag is 1
; jump back to right after the HALT after setting V-sync
[0x32ea] 13034   0xc3    JP NN           4b23        ;  Jump to 0x4b23 (9035)


;;; wait()
;; kick dog, count from 10240 down to 0... a primitive wait()?
;; T-states: 13, 10, ( 6, 4, 4, 12 ), 10
;; duration = 13 + 10 + ( ( 6 + 4 + 4 + 12 ) * 10240 ) + 10  =  266240 + 33  =  266273 cycles  =  0.0866s (@3.072Mhz)
[0x32ed] 13037   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
[0x32f0] 13040   0x21    LD HL, NN       0028        ;  Load register pair HL with 0x0028 (10240)
[0x32f3] 13043   0x2b    DEC HL                      ;  Decrement register pair HL
[0x32f4] 13044   0x7c    LD A, H                     ;  Load Accumulator with register H
[0x32f5] 13045   0xb5    OR A, L                     ;  Bitwise OR of register L to Accumulator
[0x32f6] 13046   0x20    JR NZ, N        fb          ;  Jump relative 0xfb (-5) if ZERO flag is 0
[0x32f8] 13048   0xc9    RET                         ;  Return

; 13049 : Table for bonus display sprite (right to left)
; 0x30, 0x31  // "10" (000)
; 0x35, 0x31  // "15" (000)
; 0x30, 0x32  // "20" (000)

;;; 13055 : ghost_dir_table
;;; This table is used to provide a 2-byte accumlator for advancing a sprite in the
;;; Pac-Man 2-byte coordinates datastructure (0xFF here is used as -1).  There are
;;; 4 entries, listed twice.  It is repeated because of the way some algorithms use
;;; this table, advancing a pointer and overflowing past the 4th entry, instead of
;;; indexing into the table with an appropriately clamped (modulo 4) index.
; 
;       Y     X
; 0 : 0x00, 0xFF - Right
; 1 : 0x01, 0x00 - Down
; 2 : 0x00, 0x01 - Left
; 3 : 0xFF, 0x00 - Up
; 4 : 0x00, 0xFF - Right
; 5 : 0x01, 0x00 - Down
; 6 : 0x00, 0x01 - Left
; 7 : 0xFF, 0x00 - Up



;; 13071-13356 - Table used by 1843, stride is 42, it is copied directly into $4D46.  Indexes into this table are the
;; first elements of the table at 1942.  The only values are 3, 4, 5, and 6, making me wonder what this is
;; and what are 0, 1, and 2?
;;
;;  01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42
;;  -----------------------------------------------------------------------------------------------------------------------------
; 0 : 00 FF 01 00 00 01 FF 00 55 2A 55 2A 55 55 55 55 55 2A 55 2A 52 4A A5 94 25 25 25 25 22 22 22 22 01 01 01 01 58 02 08 07 60 09
; 1 : 10 0E 68 10 70 17 14 19 52 4A A5 94 AA 2A 55 55 55 2A 55 2A 52 4A A5 94 92 24 25 49 48 24 22 91 01 01 01 01 00 00 00 00 00 00
; 2 : 00 00 00 00 00 00 00 00 55 2A 55 2A 55 55 55 55 AA 2A 55 55 55 2A 55 2A 52 4A A5 94 48 24 22 91 21 44 44 08 58 02 34 08 D8 09
; 3 : B4 0F 58 11 08 16 34 17 55 55 55 55 D5 6A D5 6A AA 6A 55 D5 55 55 55 55 AA 2A 55 55 92 24 92 24 22 22 22 22 A4 01 54 06 F8 07
; 4 : A8 0C D4 0D 84 12 B0 13 D5 6A D5 6A D6 5A AD B5 D6 5A AD B5 D5 6A D5 6A AA 6A 55 D5 92 24 25 49 48 24 22 91 A4 01 54 06 F8 07
; 5 : A8 0C D4 0D FE FF FF FF 6D 6D 6D 6D 6D 6D 6D 6D B6 6D 6D DB 6D 6D 6D 6D D6 5A AD B5 25 25 25 25 92 24 92 24 2C 01 DC 05 08 07
; 6 : B8 0B E4 0C FE FF FF FF D5 6A D5 6A D5 6A D5 6A B6 6D 6D DB 6D 6D 6D 6D D6 5A AD B5 48 24 22 91 92 24 92 24 2C 01 DC 05 08 07


;; 13357-13364: ??
;; b8 0b e4 0c fe ff ff ff
;13357   0xb8    CP A, B                     ;  Compare register B with Accumulator
;13358   0x0b    DEC BC                      ;  Decrement register pair BC
;13359   0xe4    CALL PO,NN      0cfe        ;  Call to 0x0cfe (65036) if PARITY flag is 1 (Odd parity)
;13362   0xff    RST 0x38                    ;  Restart to location 0x38 (56) (Reset)
;13363   0xff    RST 0x38                    ;  Restart to location 0x38 (56) (Reset)
;13364   0xff    RST 0x38                    ;  Restart to location 0x38 (56) (Reset)


;;; 13365-13744 : maze data, used by draw_maze() at 9241
;;; This table is encoded so that any chars less than 0x80 are interpreted as a "skip".  Also,
;;; only half the screen is represented and draw_maze() does some complex bit-fiddling to 
;;; draw the mirror image [only the explicitly addressed tiles are shown graphically below.
;-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
;-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- FC FC FC FC FC FC FC FC FC FC FC FC FC FC
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- FA DA DA DA DA DA DA DA DA DA DA DA DA D0
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- E8 -- -- -- -- -- -- -- -- -- -- -- -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- E8 -- E7 DE DE DE E6 -- E7 DE DE E6 -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- E8 -- E9 FC FC FC E8 -- E9 FC FC E8 -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- EA -- EB E4 E4 E4 F8 -- EB E4 E4 EA -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- DE DE DE E6 -- F7 F6 -- E7 DE DE E6 -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- F2 E4 E4 EA -- E9 E8 -- EB E4 E4 EA -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- E8 -- -- -- -- E9 E8 -- -- -- -- -- -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- E8 -- E7 DE DE F5 E8 -- E7 DC DC DC DC D4
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- EA -- EB E4 E4 F3 E8 -- D2 FC FC FC FC FC
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- E9 E8 -- D2 FC FC FC FC FC
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- CE F0 DC EC -- E9 E8 -- D2 FC FC FC FC FC
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- FC FC FC D3 -- F9 F8 -- EB DA DA DA DA DA
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- FC FC FC D3 -- -- -- -- -- -- -- -- -- --
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- FC FC FC D3 -- F7 F6 -- E7 DC DC DC DC DC
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- DA DA DA EE -- E9 E8 -- D2 FC FC FC FC FC
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- E9 E8 -- D2 FC FC FC FC FC
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- DE DE DE E6 -- E9 E8 -- D2 FC FC FC FC FC
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- F2 E4 E4 EA -- EB EA -- EB DA DA DA DA D0
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- E8 -- -- -- -- -- -- -- -- -- -- -- -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- E8 -- E7 DE DE DE E6 -- E7 DE DE E6 -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- EA -- EB E4 E4 E4 F8 -- E9 F2 E4 EA -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- E9 E8 -- -- -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- DE DE DE E6 -- F7 F6 -- E9 E8 -- E7 DE D6
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- F2 E4 E4 EA -- E9 E8 -- EB EA -- EB E4 D8
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- E8 -- -- -- -- E9 E8 -- -- -- -- -- -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- E8 -- E7 DE DE F5 F4 DE DE DE DE E6 -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- EA -- EB E4 E4 E4 E4 E4 E4 E4 E4 EA -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- D2
;      -- -- -- -- -- -- -- -- -- -- -- -- -- -- DC DC DC DC DC DC DC DC DC DC DC DC DC D4
;-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
;-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
; 40 FC D0 D2 D2 D2 D2 D2 D2 D2 D2 D4 FC FC FC DA 02 DC FC FC FC D0 D2 D2 D2 D2 D6 D8 D2 D2 D2 D2 D4
; FC DA 09 DC FC FC FC DA 02 DC FC FC FC DA 05 DE E4 05 DC
; FC DA 02 E6 E8 EA 02 E6 EA 02 DC FC FC FC DA 02 DC FC FC FC DA 02 E6 EA 02 E7 EB 02 E6 EA 02 DC
; FC DA 02 DE FC E4 02 DE E4 02 DC FC FC FC DA 02 DC FC FC FC DA 02 DE E4 05 DE E4 02 DC
; FC DA 02 DE FC E4 02 DE E4 02 DC FC FC FC DA 02 DC FC FC FC DA 02 DE F2 E8 E8 EA 02 DE E4 02 DC
; FC DA 02 E7 E9 EB 02 E7 EB 02 E7 D2 D2 D2 EB 02 E7 D2 D2 D2 EB 02 E7 E9 E9 E9 EB 02 DE E4 02 DC
; FC DA 1B DE E4 02 DC
; FC DA 02 E6 E8 F8 02 F6 E8 E8 E8 E8 E8 E8 F8 02 F6 E8 E8 E8 EA 02 E6 F8 02 F6 E8 E8 F4 E4 02 DC
; FC DA 02 DE FC E4 02 F7 E9 E9 F5 F3 E9 E9 F9 02 F7 E9 E9 E9 EB 02 DE E4 02 F7 E9 E9 F5 E4 02 DC
; FC DA 02 DE FC E4 05 DE E4 0B DE E4 05 DE E4 02 DC
; FC DA 02 DE FC E4 02 E6 EA 02 DE E4 02 EC D3 D3 D3 EE 02 E6 EA 02 DE E4 02 E6 EA 02 DE E4 02 DC
; FC DA 02 E7 E9 EB 02 DE E4 02 E7 EB 02 DC FC FC FC DA 02 DE E4 02 E7 EB 02 DE E4 02 E7 EB 02 DC
; FC DA 06 DE E4 05 F0 FC FC FC DA 02 DE E4 05 DE E4 05 DC
; FC FA E8 E8 E8 EA 02 DE F2 E8 E8 EA 02 CE FC FC FC DA 02 DE F2 E8 E8 EA 02 DE F2 E8 E8 EA 02 DC



[0x35b1] 13745   0x00    NOP                         ;  No Operation
[0x35b2] 13746   0x00    NOP                         ;  No Operation
[0x35b3] 13747   0x00    NOP                         ;  No Operation
[0x35b4] 13748   0x00    NOP                         ;  No Operation



;;; 13749-13988 - Table for address-skipping when drawing dots [starts with "S" in diagram, going top->down, right->left]
; -------|||||||-------|||||||
;|                            
;|                            
;| ************  ***********S 
;| *    *     *  *     *    * 
;|      *     *  *     *      
;| *    *     *  *     *    *  
;| **************************  
;| *    *  *        *  *    *  
;- *    *  *        *  *    *  
;- ******  ****  ****  ******  
;-      *              *      
;-      *              *      
;-      *              *      
;-      *              *      
;-      *              *      
;-      *              *      
;|      *              *      
;|      *              *      
;|      *              *      
;|      *              *      
;|      *              *      
;| ************  ************  
;| *    *     *  *     *    *  
;| *    *     *  *     *    *  
;-  **  *******  *******  **  
;-   *  *  *        *  *  *    
;-   *  *  *        *  *  *    
;- ******  ****  ****  ******  
;- *          *  *          *  
;- *          *  *          *  
;- **************************  
;-                            
; 0x62, 0x01, 0x02, 0x01, 0x01, 0x01, 0x01, 0x0C, 
; 0x01, 0x01, 0x04, 0x01, 0x01, 0x01, 0x04, 0x04, 
; 0x03, 0x0C, 0x03, 0x03, 0x03, 0x04, 0x04, 0x03, 
; 0x0C, 0x03, 0x01, 0x01, 0x01, 0x03, 0x04, 0x04, 
; 0x03, 0x0C, 0x06, 0x03, 0x04, 0x04, 0x03, 0x0C, 
; 0x06, 0x03, 0x04, 0x01, 0x01, 0x01, 0x01, 0x01, 
; 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 
; 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 
; 0x01, 0x01, 0x01, 0x01, 0x03, 0x04, 0x04, 0x0F, 
; 0x03, 0x06, 0x04, 0x04, 0x0F, 0x03, 0x06, 0x04, 
; 0x04, 0x01, 0x01, 0x01, 0x0C, 0x03, 0x01, 0x01, 
; 0x01, 0x03, 0x04, 0x04, 0x03, 0x0C, 0x03, 0x03, 
; 0x03, 0x04, 0x04, 0x03, 0x0C, 0x03, 0x03, 0x03, 
; 0x04, 0x01, 0x01, 0x01, 0x01, 0x03, 0x0C, 0x01, 
; 0x01, 0x01, 0x03, 0x01, 0x01, 0x01, 0x08, 0x18, 

; 0x08, 0x18, 0x04, 0x01, 0x01, 0x01, 0x01, 0x03, 
; 0x0C, 0x01, 0x01, 0x01, 0x03, 0x01, 0x01, 0x01, 
; 0x04, 0x04, 0x03, 0x0C, 0x03, 0x03, 0x03, 0x04, 
; 0x04, 0x03, 0x0C, 0x03, 0x03, 0x03, 0x04, 0x04, 
; 0x01, 0x01, 0x01, 0x0C, 0x03, 0x01, 0x01, 0x01, 
; 0x03, 0x04, 0x04, 0x0F, 0x03, 0x06, 0x04, 0x04, 
; 0x0F, 0x03, 0x06, 0x04, 0x01, 0x01, 0x01, 0x01, 
; 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 
; 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 
; 0x01, 0x01, 0x01, 0x01, 0x01, 0x03, 0x04, 0x04, 
; 0x03, 0x0C, 0x06, 0x03, 0x04, 0x04, 0x03, 0x0C, 
; 0x06, 0x03, 0x04, 0x04, 0x03, 0x0C, 0x03, 0x01, 
; 0x01, 0x01, 0x03, 0x04, 0x04, 0x03, 0x0C, 0x03, 
; 0x03, 0x03, 0x04, 0x01, 0x02, 0x01, 0x01, 0x01, 
; 0x01, 0x0C, 0x01, 0x01, 0x04, 0x01, 0x01, 0x01



; String index table 0-54, used with write_string();
;13989 : 0x3713 "HIGH SCORE"
;13991 : 0x3723 "CREDIT   "
;13993 : 0x3732 "FREE PLAY"
;13995 : 0x3741 "PLAYER ONE" (+a bunch of spaces)
;13997 : 0x375A "PLAYER TWO"
;13999 : 0x376A "GAME OVER"
;14001 : 0x377A "READY!"
;14003 : 0x3786 "PUSH START BUTTON"
;14005 : 0x379D "1 PLAYER ONLY "
;14007 : 0x37B1 "1 OR 2 PLAYERS"

;14009 : 0x3D00 "BONUS PAC-MAN FOR   00pts" (patched)
;14011 : 0x3D21 "&copy; MIDWAY MFG.CO."     (patched)
;14013 : 0x37FD "CHARACTER : NICKNAME"
;14015 : 0x3D67 ""BLINKY""
;14017 : 0x3DE3 ""BBBBBBB""
;14019 : 0x3D86 ""PINKY"  "
;14021 : 0x3E02 ""DDDDDDD""
;14023 : 0x384C "&littledot; 10 pts"
;14025 : 0x385A "&bigdot; 50 pts"
;14027 : 0x3D3C "&copy; 1980 MIDWAY MFG CO" (patched)

;14029 : 0x3D57 "-SHADOW   "
;14031 : 0x3DD3 "-AAAAAAAA-"
;14033 : 0x3D76 "-SPEEDY   "
;14035 : 0x3DF2 "-CCCCCCCC-"
;14037 : 0x0001
;14039 : 0x0002
;14041 : 0x0003
;14043 : 0x38BC "100" (stylized)
;14045 : 0x38C4 " 300 " (stylized)
;14047 : 0x38CE " 500 "

;14049 : 0x38D8 " 700 "
;14051 : 0x38E2 " 1000 " (stylized)
;14053 : 0x38EC " 2000 " (stylized)
;14055 : 0x38F6 " 3000 " (stylized)
;14057 : 0x3900 " 5000 " (stylized)
;14059 : 0x390A "MEMORY  OK"
;14061 : 0x391A "BAD    R M"
;14063 : 0x396F "FREE  PLAY"
;14065 : 0x392A "1 COIN  1 CREDIT " 
;14067 : 0x3958 "1 COIN  2 CREDITS"

;14069 : 0x3941 "2 COINS 1 CREDIT "
;14071 : 0x3E4F "PAC-MAN" (patched)
;14073 : 0x3986 "BONUS  NONE"
;14075 : 0x3997 "BONUS "
;14077 : 0x39B0 "TABLE  "
;14079 : 0x39BD "UPRIGHT"
;14081 : 0x39CA "000"
;14083 : 0x3DA5 ""INKY"   "
;14085 : 0x3E21 ""FFFFFFF""
;14087 : 0x3DC4 ""CLYDE"  "

;14089 : 0x3E40 ""HHHHHHH""
;14091 : 0x3D95 "-BASHFUL  "
;14093 : 0x3E11 "-EEEEEEEE-"
;14095 : 0x3DB4 "-POKEY    "
;14097 : 0x3E30 "-GGGGGGGG-"

;14099 (string)
;  0x83D4
;  HIGH@SCORE/(8F)/(80)

;14115 (string)
;  0x803B
;  CREDIT@@@/(8F)/(80)

;14130 (string)
;  0x803B
;  FREE@PLAY/(8F)/(80)

;14145 (string)
;  0x028C
;  PLAYER@ONE/(85)/(80)(10)(10)(1A)(1A)(1A)(1A)(1A)(1A)(10)(10)

;14170 (string)
;  0x028C
;  PLAYER@TWO/(85)/(80)

;14186 (string)
;  0x0292
;  GAME@@OVER/(81)/(80)

;14202 (string)
;  0x0252
;  READY[/(89)/(90)

;14214 (string)
;  0x02EE
;  PUSH@START@BUTTON/(87)/(80)

;14237 (string)
;  0x02B2
;  1@PLAYER@ONLY@/(85)/(80)

;14257 (string)
;  0x02B2
;  1@OR@2@PLAYERS/(85)(00)/(00)(80)(00)

;14280 (string)
;  0x0396
;  BONUS@PUCKMAN@FOR@@@00]^_/(8E)/(80)

;14313 (string)
;  0x02BA
;  \@()*+,-.@1980/(83)/(80)

;14333 (string)
;  0x02C3
;  CHARACTER@:@NICKNAME/(8F)/(80)

;14359 (string):
;  0x0165
;  &AKABEI&/(81)/(80)

;14373 (string):
;  0x0145
;  &MACKY&/(81)/(80)

;14386 (string):
;  0x0148
;  &PINKY&/(83)/(80)

;14399 (string):
;  0x0148
;  &MICKY&/(83)/(80)

;14412 (string):
;  0x0276
;  (10)@10@]^_/(9F)/(80)

;14426 (string):
;  0x0278
;  (14)@50@]^_/(9F)/(80)

;14440 (string):
;  0x025D
;  ()*+,-./(83)/(80)

;14453 (string):
;  0x02C5
;  @OIKAKE;;;;/(81)/(80)

;14470 (string):
;  0x02C5
;  @URCHIN;;;;;/(81)/(80)

;14488 (string):
;  0x02C8
;  @MACHIBUSE;;/(83)/(80)

;14506 (string):
;  0x02C8
;  @ROMP;;;;;;;/(83)/(80)

;14524 (string):
;  0x0212
;  (81)(85)/(83)/(90)

;14532 (string):
;  0x0232
;  @(82)(85)@/(83)/(90)

;14542 (string):
;  0x0232
;  @(83)(85)@/(83)/(90)

;14552 (string):
;  0x0232
;  @(84)(85)@/(83)/(90)

;14562 (string):
;  0x0232
;  @(86)(8D)(8F)/(83)/(90)

;14572 (string):
;  0x0232
;  (87)(88)(8D)(8E)/(83)/(90)

;14582 (string):
;  0x0232
;  (89)(8A)(8D)(8E)/(83)/(90)

;14592 (string):
;  0x0232
;  (8B)(8C)(8D)(8E)/(83)/(90)

;14602 (string):
;  0x0304
;  MEMORY@@OK/(8F)/(80)

;14618 (string):
;  0x0304
;  BAD@@@@R@M/(8F)/(80)

;14634 (string):
;  0x0308
;  1@COIN@@1@CREDIT /(8F)/(80)

;14657 (string):
;  0x0308
;  2@COINS@1@CREDIT /(8F)/(80)

;14680 (string):
;  0x0308
;  1@COIN@2@CREDITS/(8F)/(80)

;14703 (string):
;  0x0308
;  FREE@@PLAY@@@@@@@/(8F)/(80)

;14726 (string):
;  0x030A
;  BONUS@@NONE/(8F)/(80)

;14743 (string):
;  0x030A
;  BONUS@/(8F)/(80)

;14755 (string):
;  0x030C
;  PUCKMAN/(8F)/(80)

;14768 (string):
;  0x030E
;  TABLE@@/(8F)/(80)

;14781 (string):
;  0x030E
;  UPRIGHT/(8F)/(80)

;14794
;  0x020A
;  000/(8F)/(80)

;14803
;  0x016B
;  &AOSUKE&/(85)/(80)

;14817
;  0x014B
;  &MUCKY&/(85)/(80)

;14830
;  0x016E
;  &GUZUTA&/(87)/(80)

;14844
;  0x014E
;  &MOCKY&/(87)/(80)

;14857
;  0x02CB
;   KIMAGURE;;/(85)/(80)

;14874
;  0x02CB
;  @STYLST;;;;/(85)/(80)

;14892
;  0x02CE
;  @OTOBOKE;;;/(87)/(80)

;14909
;  0x02CE
;  @CRYBABY;;;;/(87)/(80)

;; RLE top to bottom, right to left starting from $40A2 in sprite RAM
;; Used by 15092 - 146 numbers, plus ending 0x00
;14927 - 01 01 03 01 01 01 03 02 02 02 01 01 01 01 02 04
;        04 04 06 02 02 02 02 04 02 04 04 04 06 02 02 02
;        02 01 01 01 01 02 04 04 04 06 02 02 02 02 06 04
;        05 01 01 03 01 01 01 04 01 01 01 03 01 01 04 01
;        01 01 6c 05 01 01 01 18 04 04 18 05 01 01 01 17
;        02 03 04 16 04 03 01 01 01 76 01 01 01 01 03 01
;        01 01 02 04 02 04 0e 02 04 02 04 02 04 0b 01 01
;        01 02 04 02 01 01 01 01 02 02 02 0e 02 04 02 04
;        02 01 02 01 0a 01 01 01 01 03 01 01 01 03 01 01
;        03 04 00
;
; When decoded produces the following (start on "S"):
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;  - - - - - - - - - - - - - - - - - - - - - - # # # - - -
;  - - - - - - - - - - - - - - - - - - - - - # - - - S - -
;  - - - - - - - - - - - - - - - - - - - - - # - - - # - -
;  - - - - - - - - - - - - - - - - - - - - - # - - - # - -
;  - - - - - - - - - - - - - - - - - - - - - - # # # - - -
;  - - - - - # - - - # - - - # - - - - - - - - - - - - - -
;  - - - - - # - # - # - - - - # - - - - - - # - - - # - -
;  - - - - - # - # - # - - - - - # # # - - - # - - - # - -
;  - - - - - # - # - # - - - - # - - - - - - # - - - # - -
;  - - - - - # # # # # - - - # - - - - - - - # - - - # - -
;  - - - - - - - - - - - - - - - - - - - - - - # # # - - -
;  - - - - - - # # # - - - - - # - # - - - - - - - - - - -
;  - - - - - # - - - # - - - # - # - # - - - - # # # # - -
;  - - - - - # - - - # - - - # - # - # - - - # - - - - - -
;  - - - - - # - - - # - - - # - # - # - - - # # # # # - -
;  - - - - - # # # # # - - - # # # # # - - - # - - - - - -
;  - - - - - - - - - - - - - - - - - - - - - - # # # # - -
;  - - - - - - # # # # - - - - - - - - - - - - - - - - - -
;  - - - - - # - # - - - - - - - - - - - - - # # # # # - -
;  - - - - - # - # - - - - - - - - - - - - - # - # - # - -
;  - - - - - # - # - - - - - - - - - - - - - # - # - # - -
;  - - - - - - # # # # - - - - - - - - - - - - - # - # - -
;  - - - - - - - - - - - - - - - - - - - - - - - # # # - -
;  - - - - - # # # # # - - - - - - - - - - - - - - - - - -
;  - - - - - - # - - - - - - - - - - - - - - # # # # # - -
;  - - - - - - - # - - - - - - - - - - - - - # - - - - - -
;  - - - - - - # - - - - - - - - - - - - - - # - - - - - -
;  - - - - - # # # # # - - - - - - - - - - - # - - - - - -
;  - - - - - - - - - - - - - - - - - - - - - - # # # # - -
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;  - - - - - - - - - - - - - - - - - - - - - - - - - - - -


;; Table used by 12883
;15074 - 02 40 01 3e 3d 10 40 40 0e 3d 3e 10 c2 43 01 3e 3d 10


;; draw_easter_egg()
;; draws the RLE table at $3A4F into sprite RAM at $40A2 (2 down and 2 left
;; from the upper right corner of the sprite playfield) with the large circle
;; sprites character (0x14)
;;
; HL = 0x40A2;
; DE = 0x3A4F;
; while ( true )
; {
;     $HL = 0x14;  // Large circle
;     A = $DE;
;     if ( A == 0 ) {  return;  }
;     DE++;
;     HL += A;
; }
;
[0x3af4] 15092   0x21    LD HL, NN       a240        ;  Load register pair HL with 0xa240 (16546)
[0x3af7] 15095   0x11    LD DE, NN       4f3a        ;  Load register pair DE with 0x4f3a (14927)
[0x3afa] 15098   0x36    LD (HL), N      14          ;  Load location HL with 0x14 (20)
[0x3afc] 15100   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
[0x3afd] 15101   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
[0x3afe] 15102   0xc8    RET Z                       ;  Return if ZERO flag is 1
[0x3aff] 15103   0x13    INC DE                      ;  Increment register pair DE
[0x3b00] 15104   0x85    ADD A, L                    ;  Add register L to Accumulator (no carry)
[0x3b01] 15105   0x6f    LD L, A                     ;  Load register L with Accumulator
[0x3b02] 15106   0xd2    JP NC, NN       fa3a        ;  Jump to 0xfa3a (15098) if CARRY flag is 0
[0x3b05] 15109   0x24    INC H                       ;  Increment register H
[0x3b06] 15110   0x18    JR N            f2          ;  Jump relative 0xf2 (-14)


; 15112 - Index into tile fruit table, Index for color table
; 0 - 0x90, 0x14 - Cherry
; 1 - 0x94, 0x0f - Strawberry
; 2 - 0x98, 0x15 - Orange
; 3 - 0x98, 0x15 - Orange
; 4 - 0xA0, 0x14 - Apple
; 5 - 0xA0, 0x14 - Apple
; 6 - 0xA4, 0x17 - Pineapple
; 7 - 0xA4, 0x17 - Pineapple
; 8 - 0xA8, 0x09 - Galaxian
; 9 - 0xA8, 0x09 - Galaxian
; 10 - 0x9c, 0x16 - Bell
; 11 - 0x9c, 0x16 - Bell
; 12 - 0xAC, 0x16 - Key
; 13 - 0xAC, 0x16 - Key
; 14 - 0xAC, 0x16 - Key
; 15 - 0xAC, 0x16 - Key
; 16 - 0xAC, 0x16 - Key
; 17 - 0xAC, 0x16 - Key
; 18 - 0xAC, 0x16 - Key
; 19 - 0xAC, 0x16 - Key
; 20 - 0x9c, 0x16 - Bell
; 21 - 0x9c, 0x16 - Bell
; 22 - 0xAC, 0x16 - Key
; 23 - 0xAC, 0x16 - Key
; 24 - 0xAC, 0x16 - Key
; 25 - 0xAC, 0x16 - Key
; 26 - 0xAC, 0x16 - Key
; 27 - 0xAC, 0x16 - Key
; 28 - 0xAC, 0x16 - Key
; 29 - 0xAC, 0x16 - Key


;; 15152 - Sound Data (waveform?)
;73 20 00 0C 00 0A 1F 00 72 20 FB 87 00 02 0F 00
;; 15168 - Sound Data (waveform?)
;36 20 04 8C 00 00 06 00 36 28 05 8B 00 00 06 00
;; 15184 - Sound Data (waveform?)
;36 30 06 8A 00 00 06 00 36 3C 07 89 00 00 06 00
;; 15200 - Sound Data? (waveform?)
;36 48 08 88 00 00 06 00 24 00 06 08 00 00 0A 00
;; 15216 - Sound Data? (waveform?)
;40 70 FA 10 00 00 0A 00 70 04 00 00 00 00 08 00
;; 15232 - Sound Data? (waveform?)
;42 18 FD 06 00 01 0C 00 42 04 03 06 00 01 0C 00
;; 15248 - Sound Data? (waveform?)
;56 0C FF 8C 00 02 0F 00 05 00 02 20 00 01 0C 00
;; 15264 - Sound Data? (waveform?)
;41 20 FF 86 FE 1C 0F FF 70 00 01 0C 00 01 08 00


; 15280 - table used by 11731
; 0 - 0x01
; 1 - 0x02
; 2 - 0x04
; 3 - 0x08
; 4 - 0x10
; 5 - 0x20
; 6 - 0x40
; 7 - 0x80


; 15288 - table used by 11728
; 0 - 0x00
; 1 - 0x57
; 2 - 0x5c
; 3 - 0x61
; 4 - 0x67
; 5 - 0x6d
; 6 - 0x74
; 7 - 0x7b
; 8 - 0x82
; 9 - 0x8a
; 10 - 0x92
; 11 - 0x9a
; 12 - 0xa3
; 13 - 0xad
; 14 - 0xb8
; 15 - 0xc3


; tables used by 11457
; 15304 - $3BD4, $3BF3
; 15308 - $3C58, $3C95
; 15312 - $3CDE, $3CDF


; 15316-15346: table pointed to by 15304
; f1 02  f2 03  f3 0f  f4 01  82 70  69 82  70 69  83 70
; 6a 83  70 6a  82 70  69 82  70 69  89 8b  8d 8e  ff


; 15347-15447: table pointed to by 15306
; f1 02  f2 03  f3 0f  f4 01  67 50  30 47  30 67  50 30
; 47 30  67 50  30 47  30 4b  10 4c  10 4d  10 4e  10 67
; 50 30  47 30  67 50  30 47  30 67  50 30  47 30  4b 10
; 4c 10  4d 10  4e 10  67 50  30 47  30 67  50 30  47 30
; 67 50  30 47  30 4b  10 4c  10 4d  10 4e  10 77  20 4e
; 10 4d  10 4c  10 4a  10 47  10 46  10 65  30 66  30 67
; 40 70  f0 fb  3b


; 15448-15508: table pointed to by 15308
; f1 00  f2 02  f3 0f  f4 00  42 50  4e 50  49 50  46 50
; 4e 49  70 66  70 43  50 4f  50 4a  50 47  50 4f  4a 70
; 67 70  42 50  4e 50  49 50  46 50  4e 49  70 66  70 45
; 46 47  50 47  48 49  50 49  4a 4b  50 6e  ff


; 15509-15581: table pointed to by 15310
; f1 01  f2 01  f3 0f  f4 00  26 67  26 67  26 67  23 44
; 42 47  30 67  2a 8b  70 26  67 26  67 26  67 23  44 42
; 47 30  67 23  84 70  26 67  26 67  26 67  23 44  42 47
; 30 67  29 6a  2b 6c  30 2c  6d 40  2b 6c  29 6a  67 20
; 29 6a  40 26  87 70  f0 9d  3c


; 15582: table pointed to by 15312
; 00


; 15583-15615: table pointed to by 15314
; 00 ... 00 (all zeros)


;15616 (string)
;  0x0396
;  BONUS@PAC;MAN@FOR@@@000@]^_/(8E)/(80)

;15649 (string)
;  0x033A
;  \@1980@MIDWAY@MFG%CO%/(83)/(80)

;15676 (string)
;  0x033D
;  \@1980@MIDWAY@MFG%CO%/(83)/(80)

;15703 (string)
;  0x02C5
;  ;SHADOW@@@/(81)/(80)

;15719 (string)
;  0x0165
;  &BLINKY&@/(81)/(80)

;15734 (string)
;  0x02C8
;  ;SPEEDY@@@/(83)/(80)

;15750 (string)
;  0x0168
;  &PINKY@@/(83)/(80)

;15765 (string)
;  0x02CB
;  ;BASHFUL@@/(85)/(80)

;15781 (string)
;  0x016B
;  &INKY&   /(85)/(80)

;15796 (string)
;  0x02CE
;  ;POKEY    /(87)/(80)

;15812 (string)
;  0x016E
;  &CLYDE /(87)/(80)

;15827 (string)
;  0x02C5
;  ;AAAAAAAA;/(81)/(80)

;15843 (string)
;  0x0165
;  &BBBBBBB&/(81)/(80)

;15858 (string)
;  0x02C8
;  ;CCCCCCCC;/(83)/(80)

;15874 (string)
;  0x0168
;  &DDDDDDD&/(83)/(80)

;15889 (string)
;  0x02CB
;  ;EEEEEEEE;/(85)/(80)

;15905 (string)
;  0x016B
;  &FFFFFFF&/(85)/(80)

;15920 (string)
;  0x02CE
;  ;GGGGGGGG;/(87)/(80)

;15936 (string)
;  0x016E
;  &HHHHHHH&/(87)/(80)

;15951 (string):
;  0x030C
;  PAC;MAN/(8F)/(80)


[0x3e5c] 15964   0x00    NOP                         ;  No Operation
[0x3e5d] 15965   0x00    NOP                         ;  No Operation
[0x3e5e] 15966   0x00    NOP                         ;  No Operation
[0x3e5f] 15967   0x00    NOP                         ;  No Operation
[0x3e60] 15968   0x00    NOP                         ;  No Operation
[0x3e61] 15969   0x00    NOP                         ;  No Operation
[0x3e62] 15970   0x00    NOP                         ;  No Operation
[0x3e63] 15971   0x00    NOP                         ;  No Operation
[0x3e64] 15972   0x00    NOP                         ;  No Operation
[0x3e65] 15973   0x00    NOP                         ;  No Operation
[0x3e66] 15974   0x00    NOP                         ;  No Operation
[0x3e67] 15975   0x00    NOP                         ;  No Operation
[0x3e68] 15976   0x00    NOP                         ;  No Operation
[0x3e69] 15977   0x00    NOP                         ;  No Operation
[0x3e6a] 15978   0x00    NOP                         ;  No Operation
[0x3e6b] 15979   0x00    NOP                         ;  No Operation
[0x3e6c] 15980   0x00    NOP                         ;  No Operation
[0x3e6d] 15981   0x00    NOP                         ;  No Operation
[0x3e6e] 15982   0x00    NOP                         ;  No Operation
[0x3e6f] 15983   0x00    NOP                         ;  No Operation
[0x3e70] 15984   0x00    NOP                         ;  No Operation
[0x3e71] 15985   0x00    NOP                         ;  No Operation
[0x3e72] 15986   0x00    NOP                         ;  No Operation
[0x3e73] 15987   0x00    NOP                         ;  No Operation
[0x3e74] 15988   0x00    NOP                         ;  No Operation
[0x3e75] 15989   0x00    NOP                         ;  No Operation
[0x3e76] 15990   0x00    NOP                         ;  No Operation
[0x3e77] 15991   0x00    NOP                         ;  No Operation
[0x3e78] 15992   0x00    NOP                         ;  No Operation
[0x3e79] 15993   0x00    NOP                         ;  No Operation
[0x3e7a] 15994   0x00    NOP                         ;  No Operation
[0x3e7b] 15995   0x00    NOP                         ;  No Operation
[0x3e7c] 15996   0x00    NOP                         ;  No Operation
[0x3e7d] 15997   0x00    NOP                         ;  No Operation
[0x3e7e] 15998   0x00    NOP                         ;  No Operation
[0x3e7f] 15999   0x00    NOP                         ;  No Operation
[0x3e80] 16000   0x00    NOP                         ;  No Operation
[0x3e81] 16001   0x00    NOP                         ;  No Operation
[0x3e82] 16002   0x00    NOP                         ;  No Operation
[0x3e83] 16003   0x00    NOP                         ;  No Operation
[0x3e84] 16004   0x00    NOP                         ;  No Operation
[0x3e85] 16005   0x00    NOP                         ;  No Operation
[0x3e86] 16006   0x00    NOP                         ;  No Operation
[0x3e87] 16007   0x00    NOP                         ;  No Operation
[0x3e88] 16008   0x00    NOP                         ;  No Operation
[0x3e89] 16009   0x00    NOP                         ;  No Operation
[0x3e8a] 16010   0x00    NOP                         ;  No Operation
[0x3e8b] 16011   0x00    NOP                         ;  No Operation
[0x3e8c] 16012   0x00    NOP                         ;  No Operation
[0x3e8d] 16013   0x00    NOP                         ;  No Operation
[0x3e8e] 16014   0x00    NOP                         ;  No Operation
[0x3e8f] 16015   0x00    NOP                         ;  No Operation
[0x3e90] 16016   0x00    NOP                         ;  No Operation
[0x3e91] 16017   0x00    NOP                         ;  No Operation
[0x3e92] 16018   0x00    NOP                         ;  No Operation
[0x3e93] 16019   0x00    NOP                         ;  No Operation
[0x3e94] 16020   0x00    NOP                         ;  No Operation
[0x3e95] 16021   0x00    NOP                         ;  No Operation
[0x3e96] 16022   0x00    NOP                         ;  No Operation
[0x3e97] 16023   0x00    NOP                         ;  No Operation
[0x3e98] 16024   0x00    NOP                         ;  No Operation
[0x3e99] 16025   0x00    NOP                         ;  No Operation
[0x3e9a] 16026   0x00    NOP                         ;  No Operation
[0x3e9b] 16027   0x00    NOP                         ;  No Operation
[0x3e9c] 16028   0x00    NOP                         ;  No Operation
[0x3e9d] 16029   0x00    NOP                         ;  No Operation
[0x3e9e] 16030   0x00    NOP                         ;  No Operation
[0x3e9f] 16031   0x00    NOP                         ;  No Operation
[0x3ea0] 16032   0x00    NOP                         ;  No Operation
[0x3ea1] 16033   0x00    NOP                         ;  No Operation
[0x3ea2] 16034   0x00    NOP                         ;  No Operation
[0x3ea3] 16035   0x00    NOP                         ;  No Operation
[0x3ea4] 16036   0x00    NOP                         ;  No Operation
[0x3ea5] 16037   0x00    NOP                         ;  No Operation
[0x3ea6] 16038   0x00    NOP                         ;  No Operation
[0x3ea7] 16039   0x00    NOP                         ;  No Operation
[0x3ea8] 16040   0x00    NOP                         ;  No Operation
[0x3ea9] 16041   0x00    NOP                         ;  No Operation
[0x3eaa] 16042   0x00    NOP                         ;  No Operation
[0x3eab] 16043   0x00    NOP                         ;  No Operation
[0x3eac] 16044   0x00    NOP                         ;  No Operation
[0x3ead] 16045   0x00    NOP                         ;  No Operation
[0x3eae] 16046   0x00    NOP                         ;  No Operation
[0x3eaf] 16047   0x00    NOP                         ;  No Operation
[0x3eb0] 16048   0x00    NOP                         ;  No Operation
[0x3eb1] 16049   0x00    NOP                         ;  No Operation
[0x3eb2] 16050   0x00    NOP                         ;  No Operation
[0x3eb3] 16051   0x00    NOP                         ;  No Operation
[0x3eb4] 16052   0x00    NOP                         ;  No Operation
[0x3eb5] 16053   0x00    NOP                         ;  No Operation
[0x3eb6] 16054   0x00    NOP                         ;  No Operation
[0x3eb7] 16055   0x00    NOP                         ;  No Operation
[0x3eb8] 16056   0x00    NOP                         ;  No Operation
[0x3eb9] 16057   0x00    NOP                         ;  No Operation
[0x3eba] 16058   0x00    NOP                         ;  No Operation
[0x3ebb] 16059   0x00    NOP                         ;  No Operation
[0x3ebc] 16060   0x00    NOP                         ;  No Operation
[0x3ebd] 16061   0x00    NOP                         ;  No Operation
[0x3ebe] 16062   0x00    NOP                         ;  No Operation
[0x3ebf] 16063   0x00    NOP                         ;  No Operation
[0x3ec0] 16064   0x00    NOP                         ;  No Operation
[0x3ec1] 16065   0x00    NOP                         ;  No Operation
[0x3ec2] 16066   0x00    NOP                         ;  No Operation
[0x3ec3] 16067   0x00    NOP                         ;  No Operation
[0x3ec4] 16068   0x00    NOP                         ;  No Operation
[0x3ec5] 16069   0x00    NOP                         ;  No Operation
[0x3ec6] 16070   0x00    NOP                         ;  No Operation
[0x3ec7] 16071   0x00    NOP                         ;  No Operation
[0x3ec8] 16072   0x00    NOP                         ;  No Operation
[0x3ec9] 16073   0x00    NOP                         ;  No Operation
[0x3eca] 16074   0x00    NOP                         ;  No Operation
[0x3ecb] 16075   0x00    NOP                         ;  No Operation
[0x3ecc] 16076   0x00    NOP                         ;  No Operation
[0x3ecd] 16077   0x00    NOP                         ;  No Operation
[0x3ece] 16078   0x00    NOP                         ;  No Operation
[0x3ecf] 16079   0x00    NOP                         ;  No Operation
[0x3ed0] 16080   0x00    NOP                         ;  No Operation
[0x3ed1] 16081   0x00    NOP                         ;  No Operation
[0x3ed2] 16082   0x00    NOP                         ;  No Operation
[0x3ed3] 16083   0x00    NOP                         ;  No Operation
[0x3ed4] 16084   0x00    NOP                         ;  No Operation
[0x3ed5] 16085   0x00    NOP                         ;  No Operation
[0x3ed6] 16086   0x00    NOP                         ;  No Operation
[0x3ed7] 16087   0x00    NOP                         ;  No Operation
[0x3ed8] 16088   0x00    NOP                         ;  No Operation
[0x3ed9] 16089   0x00    NOP                         ;  No Operation
[0x3eda] 16090   0x00    NOP                         ;  No Operation
[0x3edb] 16091   0x00    NOP                         ;  No Operation
[0x3edc] 16092   0x00    NOP                         ;  No Operation
[0x3edd] 16093   0x00    NOP                         ;  No Operation
[0x3ede] 16094   0x00    NOP                         ;  No Operation
[0x3edf] 16095   0x00    NOP                         ;  No Operation
[0x3ee0] 16096   0x00    NOP                         ;  No Operation
[0x3ee1] 16097   0x00    NOP                         ;  No Operation
[0x3ee2] 16098   0x00    NOP                         ;  No Operation
[0x3ee3] 16099   0x00    NOP                         ;  No Operation
[0x3ee4] 16100   0x00    NOP                         ;  No Operation
[0x3ee5] 16101   0x00    NOP                         ;  No Operation
[0x3ee6] 16102   0x00    NOP                         ;  No Operation
[0x3ee7] 16103   0x00    NOP                         ;  No Operation
[0x3ee8] 16104   0x00    NOP                         ;  No Operation
[0x3ee9] 16105   0x00    NOP                         ;  No Operation
[0x3eea] 16106   0x00    NOP                         ;  No Operation
[0x3eeb] 16107   0x00    NOP                         ;  No Operation
[0x3eec] 16108   0x00    NOP                         ;  No Operation
[0x3eed] 16109   0x00    NOP                         ;  No Operation
[0x3eee] 16110   0x00    NOP                         ;  No Operation
[0x3eef] 16111   0x00    NOP                         ;  No Operation
[0x3ef0] 16112   0x00    NOP                         ;  No Operation
[0x3ef1] 16113   0x00    NOP                         ;  No Operation
[0x3ef2] 16114   0x00    NOP                         ;  No Operation
[0x3ef3] 16115   0x00    NOP                         ;  No Operation
[0x3ef4] 16116   0x00    NOP                         ;  No Operation
[0x3ef5] 16117   0x00    NOP                         ;  No Operation
[0x3ef6] 16118   0x00    NOP                         ;  No Operation
[0x3ef7] 16119   0x00    NOP                         ;  No Operation
[0x3ef8] 16120   0x00    NOP                         ;  No Operation
[0x3ef9] 16121   0x00    NOP                         ;  No Operation
[0x3efa] 16122   0x00    NOP                         ;  No Operation
[0x3efb] 16123   0x00    NOP                         ;  No Operation
[0x3efc] 16124   0x00    NOP                         ;  No Operation
[0x3efd] 16125   0x00    NOP                         ;  No Operation
[0x3efe] 16126   0x00    NOP                         ;  No Operation
[0x3eff] 16127   0x00    NOP                         ;  No Operation
[0x3f00] 16128   0x00    NOP                         ;  No Operation
[0x3f01] 16129   0x00    NOP                         ;  No Operation
[0x3f02] 16130   0x00    NOP                         ;  No Operation
[0x3f03] 16131   0x00    NOP                         ;  No Operation
[0x3f04] 16132   0x00    NOP                         ;  No Operation
[0x3f05] 16133   0x00    NOP                         ;  No Operation
[0x3f06] 16134   0x00    NOP                         ;  No Operation
[0x3f07] 16135   0x00    NOP                         ;  No Operation
[0x3f08] 16136   0x00    NOP                         ;  No Operation
[0x3f09] 16137   0x00    NOP                         ;  No Operation
[0x3f0a] 16138   0x00    NOP                         ;  No Operation
[0x3f0b] 16139   0x00    NOP                         ;  No Operation
[0x3f0c] 16140   0x00    NOP                         ;  No Operation
[0x3f0d] 16141   0x00    NOP                         ;  No Operation
[0x3f0e] 16142   0x00    NOP                         ;  No Operation
[0x3f0f] 16143   0x00    NOP                         ;  No Operation
[0x3f10] 16144   0x00    NOP                         ;  No Operation
[0x3f11] 16145   0x00    NOP                         ;  No Operation
[0x3f12] 16146   0x00    NOP                         ;  No Operation
[0x3f13] 16147   0x00    NOP                         ;  No Operation
[0x3f14] 16148   0x00    NOP                         ;  No Operation
[0x3f15] 16149   0x00    NOP                         ;  No Operation
[0x3f16] 16150   0x00    NOP                         ;  No Operation
[0x3f17] 16151   0x00    NOP                         ;  No Operation
[0x3f18] 16152   0x00    NOP                         ;  No Operation
[0x3f19] 16153   0x00    NOP                         ;  No Operation
[0x3f1a] 16154   0x00    NOP                         ;  No Operation
[0x3f1b] 16155   0x00    NOP                         ;  No Operation
[0x3f1c] 16156   0x00    NOP                         ;  No Operation
[0x3f1d] 16157   0x00    NOP                         ;  No Operation
[0x3f1e] 16158   0x00    NOP                         ;  No Operation
[0x3f1f] 16159   0x00    NOP                         ;  No Operation
[0x3f20] 16160   0x00    NOP                         ;  No Operation
[0x3f21] 16161   0x00    NOP                         ;  No Operation
[0x3f22] 16162   0x00    NOP                         ;  No Operation
[0x3f23] 16163   0x00    NOP                         ;  No Operation
[0x3f24] 16164   0x00    NOP                         ;  No Operation
[0x3f25] 16165   0x00    NOP                         ;  No Operation
[0x3f26] 16166   0x00    NOP                         ;  No Operation
[0x3f27] 16167   0x00    NOP                         ;  No Operation
[0x3f28] 16168   0x00    NOP                         ;  No Operation
[0x3f29] 16169   0x00    NOP                         ;  No Operation
[0x3f2a] 16170   0x00    NOP                         ;  No Operation
[0x3f2b] 16171   0x00    NOP                         ;  No Operation
[0x3f2c] 16172   0x00    NOP                         ;  No Operation
[0x3f2d] 16173   0x00    NOP                         ;  No Operation
[0x3f2e] 16174   0x00    NOP                         ;  No Operation
[0x3f2f] 16175   0x00    NOP                         ;  No Operation
[0x3f30] 16176   0x00    NOP                         ;  No Operation
[0x3f31] 16177   0x00    NOP                         ;  No Operation
[0x3f32] 16178   0x00    NOP                         ;  No Operation
[0x3f33] 16179   0x00    NOP                         ;  No Operation
[0x3f34] 16180   0x00    NOP                         ;  No Operation
[0x3f35] 16181   0x00    NOP                         ;  No Operation
[0x3f36] 16182   0x00    NOP                         ;  No Operation
[0x3f37] 16183   0x00    NOP                         ;  No Operation
[0x3f38] 16184   0x00    NOP                         ;  No Operation
[0x3f39] 16185   0x00    NOP                         ;  No Operation
[0x3f3a] 16186   0x00    NOP                         ;  No Operation
[0x3f3b] 16187   0x00    NOP                         ;  No Operation
[0x3f3c] 16188   0x00    NOP                         ;  No Operation
[0x3f3d] 16189   0x00    NOP                         ;  No Operation
[0x3f3e] 16190   0x00    NOP                         ;  No Operation
[0x3f3f] 16191   0x00    NOP                         ;  No Operation
[0x3f40] 16192   0x00    NOP                         ;  No Operation
[0x3f41] 16193   0x00    NOP                         ;  No Operation
[0x3f42] 16194   0x00    NOP                         ;  No Operation
[0x3f43] 16195   0x00    NOP                         ;  No Operation
[0x3f44] 16196   0x00    NOP                         ;  No Operation
[0x3f45] 16197   0x00    NOP                         ;  No Operation
[0x3f46] 16198   0x00    NOP                         ;  No Operation
[0x3f47] 16199   0x00    NOP                         ;  No Operation
[0x3f48] 16200   0x00    NOP                         ;  No Operation
[0x3f49] 16201   0x00    NOP                         ;  No Operation
[0x3f4a] 16202   0x00    NOP                         ;  No Operation
[0x3f4b] 16203   0x00    NOP                         ;  No Operation
[0x3f4c] 16204   0x00    NOP                         ;  No Operation
[0x3f4d] 16205   0x00    NOP                         ;  No Operation
[0x3f4e] 16206   0x00    NOP                         ;  No Operation
[0x3f4f] 16207   0x00    NOP                         ;  No Operation
[0x3f50] 16208   0x00    NOP                         ;  No Operation
[0x3f51] 16209   0x00    NOP                         ;  No Operation
[0x3f52] 16210   0x00    NOP                         ;  No Operation
[0x3f53] 16211   0x00    NOP                         ;  No Operation
[0x3f54] 16212   0x00    NOP                         ;  No Operation
[0x3f55] 16213   0x00    NOP                         ;  No Operation
[0x3f56] 16214   0x00    NOP                         ;  No Operation
[0x3f57] 16215   0x00    NOP                         ;  No Operation
[0x3f58] 16216   0x00    NOP                         ;  No Operation
[0x3f59] 16217   0x00    NOP                         ;  No Operation
[0x3f5a] 16218   0x00    NOP                         ;  No Operation
[0x3f5b] 16219   0x00    NOP                         ;  No Operation
[0x3f5c] 16220   0x00    NOP                         ;  No Operation
[0x3f5d] 16221   0x00    NOP                         ;  No Operation
[0x3f5e] 16222   0x00    NOP                         ;  No Operation
[0x3f5f] 16223   0x00    NOP                         ;  No Operation
[0x3f60] 16224   0x00    NOP                         ;  No Operation
[0x3f61] 16225   0x00    NOP                         ;  No Operation
[0x3f62] 16226   0x00    NOP                         ;  No Operation
[0x3f63] 16227   0x00    NOP                         ;  No Operation
[0x3f64] 16228   0x00    NOP                         ;  No Operation
[0x3f65] 16229   0x00    NOP                         ;  No Operation
[0x3f66] 16230   0x00    NOP                         ;  No Operation
[0x3f67] 16231   0x00    NOP                         ;  No Operation
[0x3f68] 16232   0x00    NOP                         ;  No Operation
[0x3f69] 16233   0x00    NOP                         ;  No Operation
[0x3f6a] 16234   0x00    NOP                         ;  No Operation
[0x3f6b] 16235   0x00    NOP                         ;  No Operation
[0x3f6c] 16236   0x00    NOP                         ;  No Operation
[0x3f6d] 16237   0x00    NOP                         ;  No Operation
[0x3f6e] 16238   0x00    NOP                         ;  No Operation
[0x3f6f] 16239   0x00    NOP                         ;  No Operation
[0x3f70] 16240   0x00    NOP                         ;  No Operation
[0x3f71] 16241   0x00    NOP                         ;  No Operation
[0x3f72] 16242   0x00    NOP                         ;  No Operation
[0x3f73] 16243   0x00    NOP                         ;  No Operation
[0x3f74] 16244   0x00    NOP                         ;  No Operation
[0x3f75] 16245   0x00    NOP                         ;  No Operation
[0x3f76] 16246   0x00    NOP                         ;  No Operation
[0x3f77] 16247   0x00    NOP                         ;  No Operation
[0x3f78] 16248   0x00    NOP                         ;  No Operation
[0x3f79] 16249   0x00    NOP                         ;  No Operation
[0x3f7a] 16250   0x00    NOP                         ;  No Operation
[0x3f7b] 16251   0x00    NOP                         ;  No Operation
[0x3f7c] 16252   0x00    NOP                         ;  No Operation
[0x3f7d] 16253   0x00    NOP                         ;  No Operation
[0x3f7e] 16254   0x00    NOP                         ;  No Operation
[0x3f7f] 16255   0x00    NOP                         ;  No Operation
[0x3f80] 16256   0x00    NOP                         ;  No Operation
[0x3f81] 16257   0x00    NOP                         ;  No Operation
[0x3f82] 16258   0x00    NOP                         ;  No Operation
[0x3f83] 16259   0x00    NOP                         ;  No Operation
[0x3f84] 16260   0x00    NOP                         ;  No Operation
[0x3f85] 16261   0x00    NOP                         ;  No Operation
[0x3f86] 16262   0x00    NOP                         ;  No Operation
[0x3f87] 16263   0x00    NOP                         ;  No Operation
[0x3f88] 16264   0x00    NOP                         ;  No Operation
[0x3f89] 16265   0x00    NOP                         ;  No Operation
[0x3f8a] 16266   0x00    NOP                         ;  No Operation
[0x3f8b] 16267   0x00    NOP                         ;  No Operation
[0x3f8c] 16268   0x00    NOP                         ;  No Operation
[0x3f8d] 16269   0x00    NOP                         ;  No Operation
[0x3f8e] 16270   0x00    NOP                         ;  No Operation
[0x3f8f] 16271   0x00    NOP                         ;  No Operation
[0x3f90] 16272   0x00    NOP                         ;  No Operation
[0x3f91] 16273   0x00    NOP                         ;  No Operation
[0x3f92] 16274   0x00    NOP                         ;  No Operation
[0x3f93] 16275   0x00    NOP                         ;  No Operation
[0x3f94] 16276   0x00    NOP                         ;  No Operation
[0x3f95] 16277   0x00    NOP                         ;  No Operation
[0x3f96] 16278   0x00    NOP                         ;  No Operation
[0x3f97] 16279   0x00    NOP                         ;  No Operation
[0x3f98] 16280   0x00    NOP                         ;  No Operation
[0x3f99] 16281   0x00    NOP                         ;  No Operation
[0x3f9a] 16282   0x00    NOP                         ;  No Operation
[0x3f9b] 16283   0x00    NOP                         ;  No Operation
[0x3f9c] 16284   0x00    NOP                         ;  No Operation
[0x3f9d] 16285   0x00    NOP                         ;  No Operation
[0x3f9e] 16286   0x00    NOP                         ;  No Operation
[0x3f9f] 16287   0x00    NOP                         ;  No Operation
[0x3fa0] 16288   0x00    NOP                         ;  No Operation
[0x3fa1] 16289   0x00    NOP                         ;  No Operation
[0x3fa2] 16290   0x00    NOP                         ;  No Operation
[0x3fa3] 16291   0x00    NOP                         ;  No Operation
[0x3fa4] 16292   0x00    NOP                         ;  No Operation
[0x3fa5] 16293   0x00    NOP                         ;  No Operation
[0x3fa6] 16294   0x00    NOP                         ;  No Operation
[0x3fa7] 16295   0x00    NOP                         ;  No Operation
[0x3fa8] 16296   0x00    NOP                         ;  No Operation
[0x3fa9] 16297   0x00    NOP                         ;  No Operation
[0x3faa] 16298   0x00    NOP                         ;  No Operation
[0x3fab] 16299   0x00    NOP                         ;  No Operation
[0x3fac] 16300   0x00    NOP                         ;  No Operation
[0x3fad] 16301   0x00    NOP                         ;  No Operation
[0x3fae] 16302   0x00    NOP                         ;  No Operation
[0x3faf] 16303   0x00    NOP                         ;  No Operation
[0x3fb0] 16304   0x00    NOP                         ;  No Operation
[0x3fb1] 16305   0x00    NOP                         ;  No Operation
[0x3fb2] 16306   0x00    NOP                         ;  No Operation
[0x3fb3] 16307   0x00    NOP                         ;  No Operation
[0x3fb4] 16308   0x00    NOP                         ;  No Operation
[0x3fb5] 16309   0x00    NOP                         ;  No Operation
[0x3fb6] 16310   0x00    NOP                         ;  No Operation
[0x3fb7] 16311   0x00    NOP                         ;  No Operation
[0x3fb8] 16312   0x00    NOP                         ;  No Operation
[0x3fb9] 16313   0x00    NOP                         ;  No Operation
[0x3fba] 16314   0x00    NOP                         ;  No Operation
[0x3fbb] 16315   0x00    NOP                         ;  No Operation
[0x3fbc] 16316   0x00    NOP                         ;  No Operation
[0x3fbd] 16317   0x00    NOP                         ;  No Operation
[0x3fbe] 16318   0x00    NOP                         ;  No Operation
[0x3fbf] 16319   0x00    NOP                         ;  No Operation
[0x3fc0] 16320   0x00    NOP                         ;  No Operation
[0x3fc1] 16321   0x00    NOP                         ;  No Operation
[0x3fc2] 16322   0x00    NOP                         ;  No Operation
[0x3fc3] 16323   0x00    NOP                         ;  No Operation
[0x3fc4] 16324   0x00    NOP                         ;  No Operation
[0x3fc5] 16325   0x00    NOP                         ;  No Operation
[0x3fc6] 16326   0x00    NOP                         ;  No Operation
[0x3fc7] 16327   0x00    NOP                         ;  No Operation
[0x3fc8] 16328   0x00    NOP                         ;  No Operation
[0x3fc9] 16329   0x00    NOP                         ;  No Operation
[0x3fca] 16330   0x00    NOP                         ;  No Operation
[0x3fcb] 16331   0x00    NOP                         ;  No Operation
[0x3fcc] 16332   0x00    NOP                         ;  No Operation
[0x3fcd] 16333   0x00    NOP                         ;  No Operation
[0x3fce] 16334   0x00    NOP                         ;  No Operation
[0x3fcf] 16335   0x00    NOP                         ;  No Operation
[0x3fd0] 16336   0x00    NOP                         ;  No Operation
[0x3fd1] 16337   0x00    NOP                         ;  No Operation
[0x3fd2] 16338   0x00    NOP                         ;  No Operation
[0x3fd3] 16339   0x00    NOP                         ;  No Operation
[0x3fd4] 16340   0x00    NOP                         ;  No Operation
[0x3fd5] 16341   0x00    NOP                         ;  No Operation
[0x3fd6] 16342   0x00    NOP                         ;  No Operation
[0x3fd7] 16343   0x00    NOP                         ;  No Operation
[0x3fd8] 16344   0x00    NOP                         ;  No Operation
[0x3fd9] 16345   0x00    NOP                         ;  No Operation
[0x3fda] 16346   0x00    NOP                         ;  No Operation
[0x3fdb] 16347   0x00    NOP                         ;  No Operation
[0x3fdc] 16348   0x00    NOP                         ;  No Operation
[0x3fdd] 16349   0x00    NOP                         ;  No Operation
[0x3fde] 16350   0x00    NOP                         ;  No Operation
[0x3fdf] 16351   0x00    NOP                         ;  No Operation
[0x3fe0] 16352   0x00    NOP                         ;  No Operation
[0x3fe1] 16353   0x00    NOP                         ;  No Operation
[0x3fe2] 16354   0x00    NOP                         ;  No Operation
[0x3fe3] 16355   0x00    NOP                         ;  No Operation
[0x3fe4] 16356   0x00    NOP                         ;  No Operation
[0x3fe5] 16357   0x00    NOP                         ;  No Operation
[0x3fe6] 16358   0x00    NOP                         ;  No Operation
[0x3fe7] 16359   0x00    NOP                         ;  No Operation
[0x3fe8] 16360   0x00    NOP                         ;  No Operation
[0x3fe9] 16361   0x00    NOP                         ;  No Operation
[0x3fea] 16362   0x00    NOP                         ;  No Operation
[0x3feb] 16363   0x00    NOP                         ;  No Operation
[0x3fec] 16364   0x00    NOP                         ;  No Operation
[0x3fed] 16365   0x00    NOP                         ;  No Operation
[0x3fee] 16366   0x00    NOP                         ;  No Operation
[0x3fef] 16367   0x00    NOP                         ;  No Operation
[0x3ff0] 16368   0x00    NOP                         ;  No Operation
[0x3ff1] 16369   0x00    NOP                         ;  No Operation
[0x3ff2] 16370   0x00    NOP                         ;  No Operation
[0x3ff3] 16371   0x00    NOP                         ;  No Operation
[0x3ff4] 16372   0x00    NOP                         ;  No Operation
[0x3ff5] 16373   0x00    NOP                         ;  No Operation
[0x3ff6] 16374   0x00    NOP                         ;  No Operation
[0x3ff7] 16375   0x00    NOP                         ;  No Operation
[0x3ff8] 16376   0x00    NOP                         ;  No Operation
[0x3ff9] 16377   0x00    NOP                         ;  No Operation

; Interrupt data vectors.
; 16378   0x00    0x30            0x3000
; 16380   0x8D    0x00            0x008D

;checksum
; 16382   0x75    0x73            0x7375
