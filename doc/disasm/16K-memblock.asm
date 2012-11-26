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
0       0xf3    DI                          ;  Disable Interrupts
1       0x3e    LD A,N          3f          ;  Load Accumulator with 0x3f (63)
; This sets the Int tables to 0x3f00
3       0xed    LD I, A                     ;  Load the register I with Accumulator
5       0xc3    JP NN           0b23        ;  Jump to 0x0b23 (8971)

; ( rst 8 - Fill (HL)...(HL+B) with Accumulator )
8       0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
9       0x23    INC HL                      ;  Increment register pair HL
10      0x10    DJNZ N          fc          ;  Decrement B and jump relative 0xfc (-4) if B!=0
12      0xc9    RET                         ;  Return


13      0xc3    JP NN           0e07        ;  Jump to 0x0e07 (1806)

; ( rst 10 )
; HL = HL + A;
; A = (char *)HL;
;;; A = $(HL + A);
16      0x85    ADD A, L                    ;  Add register L to Accumulator (no carry)
17      0x6f    LD L, A                     ;  Load register L with Accumulator
18      0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
20      0x8c    ADC A, H                    ;  Add with carry register H to Accumulator
21      0x67    LD H, A                     ;  Load register H with Accumulator
22      0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
23      0xc9    RET                         ;  Return

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
24      0x78    LD A, B                     ;  Load Accumulator with register B
25      0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
26      0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
27      0x5f    LD E, A                     ;  Load register E with Accumulator
28      0x23    INC HL                      ;  Increment register pair HL
29      0x56    LD D, (HL)                  ;  Load register D with location (HL)
30      0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
31      0xc9    RET                         ;  Return

; ( rst 20 )
; jump forward from calling point, based on value of A
; if A=0, jump to the address in the 2 bytes following the
; calling point (SP).  If A=1, jump to (SP+2), etc.
; RST 10 in the middle advances HL by A.
32      0xe1    POP HL                      ;  Load register pair HL with top of stack
33      0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
34      0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
35      0x5f    LD E, A                     ;  Load register E with Accumulator
36      0x23    INC HL                      ;  Increment register pair HL
37      0x56    LD D, (HL)                  ;  Load register D with location (HL)
38      0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
39      0xe9    JP (HL)                     ;  Jump to location (HL)

;;; insert_display_list_PC();
; ( rst 28 )
; Take the two bytes after the jump point, put them in BC, push the jump point + 2 back on the stack,
; then jump to insert_msg();
40      0xe1    POP HL                      ;  Load register pair HL with top of stack
41      0x46    LD B, (HL)                  ;  Load register B with location (HL)
42      0x23    INC HL                      ;  Increment register pair HL
43      0x4e    LD C, (HL)                  ;  Load register C with location (HL)
44      0x23    INC HL                      ;  Increment register pair HL
45      0xe5    PUSH HL                     ;  Load the stack with register pair HL
46      0x18    JR N            12          ;  Jump relative 0x12 (18)

;;; insert_msg();
; Interrupt 250 ( rst 30 ) - insert a 3 byte message into the 16 slot message queue at $4C90
; Pop the location from the stack, which is the first byte after the opcode that called this,
; and copy the 3 bytes the location refers to into the first open 3 byte block in $4C90-$4CBD.  Then
; jump to the location following those three bytes.
48      0x11    LD  DE, NN      904c        ;  Load register pair DE with 0x904c (19600)
51      0x06    LD  B, N        10          ;  Load register B with 0x10 (16)
53      0xc3    JP NN           5100        ;  Jump to 0x5100 (81)

; ( rst 38 - Kick the Watchdog, Kick the Coin Counter, Repeat )
56      0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
57      0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
60      0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
63      0xc3    JP NN           3800        ;  Jump to 0x3800 (56)


;;; insert_display_list();
; // BC == new queue msg, B == index into call table, C == param;
; ($4C80) = BC;
; $4C80 = ($4C80) + 2 // with the constraint that it wraps around 255 to 192
66      0x2a    LD HL, (NN)     804c        ;  Load register pair HL with location 0x804c (19584)
69      0x70    LD (HL), B                  ;  Load location (HL) with register B
70      0x2c    INC L                       ;  Increment register L
71      0x71    LD (HL), C                  ;  Load location (HL) with register C
72      0x2c    INC L                       ;  Increment register L
73      0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
75      0x2e    LD L,N          c0          ;  Load register L with 0xc0 (192)
77      0x22    LD (NN), HL     804c        ;  Load location 0x804c (19584) with the register pair HL
80      0xc9    RET                         ;  Return


; ( rst 30 - continuation )
; Find the next open 3 byte block in $4C90-$4CBD
81      0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
82      0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
83      0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
85      0x1c    INC E                       ;  Increment register E
86      0x1c    INC E                       ;  Increment register E
87      0x1c    INC E                       ;  Increment register E
88      0x10    DJNZ N          f7          ;  Decrement B and jump relative 0xf7 (-9) if B!=0
90      0xc9    RET                         ;  Return
; Copy (stack)...(stack+2) to (DE)...(DE+2)
91      0xe1    POP HL                      ;  Load register pair HL with top of stack
92      0x06    LD  B, N        03          ;  Load register B with 0x03 (3)
94      0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
95      0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
96      0x23    INC HL                      ;  Increment register pair HL
97      0x1c    INC E                       ;  Increment register E
98      0x10    DJNZ N          fa          ;  Decrement B and jump relative 0xfa (-6) if B!=0
; Jump to (stack+3)
100     0xe9    JP (HL)                     ;  Jump to location (HL)

; YX_to_playfieldaddr()
101     0xc3    JP NN           2d20        ;  Jump to 0x2d20 (8237)

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
141     0xf5    PUSH AF                     ;  Load the stack with register pair AF
142     0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
145     0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
146     0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
149     0xf3    DI                          ;  Disable Interrupts
150     0xc5    PUSH BC                     ;  Load the stack with register pair BC
151     0xd5    PUSH DE                     ;  Load the stack with register pair DE
152     0xe5    PUSH HL                     ;  Load the stack with register pair HL
153     0xdd    PUSH IX                     ;  Load the stack with register pair IX
155     0xfd    PUSH IY                     ;  Load the stack with register pair IY
; copy $4E8C..$4E9B -> $5050..$505F   (Sound 1/2/3 Freq and Volume)
157     0x21    LD HL, NN       8c4e        ;  Load register pair HL with 0x8c4e (20108)
160     0x11    LD  DE, NN      5050        ;  Load register pair DE with 0x5050 (80)
163     0x01    LD  BC, NN      1000        ;  Load register pair BC with 0x1000 (16)
166     0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; decrement BC; repeat until BC == 0
; if ( $4ECC == 0 ) { $5045 = $4E9F; } else { $5045 = $4ECF; }
168     0x3a    LD A, (NN)      cc4e        ;  Load Accumulator with location 0xcc4e (20172)
171     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
172     0x3a    LD A, (NN)      cf4e        ;  Load Accumulator with location 0xcf4e (20175)
175     0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
177     0x3a    LD A, (NN)      9f4e        ;  Load Accumulator with location 0x9f4e (20127)
180     0x32    LD (NN), A      4550        ;  Load location 0x4550 (20549) with the Accumulator
; if ( $4EDC == 0 ) { $504A = $4EAF; } else { $504A = $4EDF; }
183     0x3a    LD A, (NN)      dc4e        ;  Load Accumulator with location 0xdc4e (20188)
186     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
187     0x3a    LD A, (NN)      df4e        ;  Load Accumulator with location 0xdf4e (20191)
190     0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
192     0x3a    LD A, (NN)      af4e        ;  Load Accumulator with location 0xaf4e (20143)
195     0x32    LD (NN), A      4a50        ;  Load location 0x4a50 (20554) with the Accumulator
; if ( $4EEC == 0 ) { $504F = $4EBF; } else { $504F = $4EEF; }
198     0x3a    LD A, (NN)      ec4e        ;  Load Accumulator with location 0xec4e (20204)
201     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
202     0x3a    LD A, (NN)      ef4e        ;  Load Accumulator with location 0xef4e (20207)
205     0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
207     0x3a    LD A, (NN)      bf4e        ;  Load Accumulator with location 0xbf4e (20159)
210     0x32    LD (NN), A      4f50        ;  Load location 0x4f50 (20559) with the Accumulator
; copy $4C02..$4C1D -> $4C22..$4C3D
213     0x21    LD HL, NN       024c        ;  Load register pair HL with 0x024c (19458)
216     0x11    LD  DE, NN      224c        ;  Load register pair DE with 0x224c (34)
219     0x01    LD  BC, NN      1c00        ;  Load register pair BC with 0x1c00 (28)
222     0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; decrement BC; repeat until BC == 0
; foreach loc ($4C22, $4C24, $4C26, $4C28, $4C2A, $4C2C) { loc *= 4; }
224     0xdd    LD IX, NN       204c        ;  Load register pair IX with 0x204c (19488)
228     0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
231     0x07    RLCA                        ;  Rotate left circular Accumulator
232     0x07    RLCA                        ;  Rotate left circular Accumulator
233     0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
236     0xdd    LD A, (IX+d)    04          ;  Load Accumulator with location ( IX + 0x04 () )
239     0x07    RLCA                        ;  Rotate left circular Accumulator
240     0x07    RLCA                        ;  Rotate left circular Accumulator
241     0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
244     0xdd    LD A, (IX+d)    06          ;  Load Accumulator with location ( IX + 0x06 () )
247     0x07    RLCA                        ;  Rotate left circular Accumulator
248     0x07    RLCA                        ;  Rotate left circular Accumulator
249     0xdd    LD (IX+d), A    06          ;  Load location ( IX + 0x06 () ) with Accumulator
252     0xdd    LD A, (IX+d)    08          ;  Load Accumulator with location ( IX + 0x08 () )
255     0x07    RLCA                        ;  Rotate left circular Accumulator
256     0x07    RLCA                        ;  Rotate left circular Accumulator
257     0xdd    LD (IX+d), A    08          ;  Load location ( IX + 0x08 () ) with Accumulator
260     0xdd    LD A, (IX+d)    0a          ;  Load Accumulator with location ( IX + 0x0a () )
263     0x07    RLCA                        ;  Rotate left circular Accumulator
264     0x07    RLCA                        ;  Rotate left circular Accumulator
265     0xdd    LD (IX+d), A    0a          ;  Load location ( IX + 0x0a () ) with Accumulator
268     0xdd    LD A, (IX+d)    0c          ;  Load Accumulator with location ( IX + 0x0c () )
271     0x07    RLCA                        ;  Rotate left circular Accumulator
272     0x07    RLCA                        ;  Rotate left circular Accumulator
273     0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
; if ( $4DD1 != 1 )
; {
;     IX = 0x4C20 + ( $4DA4 * 2 );
;     swap($4C24, $IX);  swap($4C34, $(IX+16));
;     //  HL = $4C24/5;  DE = $4C34/5;
;     //  $4C24 = $IX;  $4C25 = $(IX+1);
;     //  $4C34 = $(IX+16); $4C35 = $(IX+17);
;     //  $IX = HL;  $(IX+16) = DE;
; }
276     0x3a    LD A, (NN)      d14d        ;  Load Accumulator with location 0xd14d (19921)
279     0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
281     0x20    JR NZ, N        38          ;  Jump relative 0x38 (56) if ZERO flag is 0
283     0xdd    LD IX, NN       204c        ;  Load register pair IX with 0x204c (19488)
287     0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
290     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
291     0x5f    LD E, A                     ;  Load register E with Accumulator
292     0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
294     0xdd    ADD IX, DE                  ;  Add register pair DE to IX
296     0x2a    LD HL, (NN)     244c        ;  Load register pair HL with location 0x244c (19492)
299     0xed    LD DE, (NN)     344c        ;  Load register pair DE with location 0x344c (19508)
303     0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
306     0x32    LD (NN), A      244c        ;  Load location 0x244c (19492) with the Accumulator
309     0xdd    LD A, (IX+d)    01          ;  Load Accumulator with location ( IX + 0x01 () )
312     0x32    LD (NN), A      254c        ;  Load location 0x254c (19493) with the Accumulator
315     0xdd    LD A, (IX+d)    10          ;  Load Accumulator with location ( IX + 0x10 () )
318     0x32    LD (NN), A      344c        ;  Load location 0x344c (19508) with the Accumulator
321     0xdd    LD A, (IX+d)    11          ;  Load Accumulator with location ( IX + 0x11 () )
324     0x32    LD (NN), A      354c        ;  Load location 0x354c (19509) with the Accumulator
327     0xdd    LD (IX+d), L    00          ;  Load location ( IX + 0x00 () ) with register L
330     0xdd    LD (IX+d), H    01          ;  Load location ( IX + 0x01 () ) with register H
333     0xdd    LD (IX+d), E    10          ;  Load location ( IX + 0x10 () ) with register E
336     0xdd    LD (IX+d), D    11          ;  Load location ( IX + 0x11 () ) with register D
; if ( $4DA6 != 0 )
;     swap($4C22, $4C2A);  swap($4C32, $4C3A);
339     0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
342     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
343     0xca    JP Z,           7601        ;  Jump to 0x7601 (374) if ZERO flag is 1
346     0xed    LD BC, (NN)     224c        ;  Load register pair BC with location 0x224c (19490)
350     0xed    LD DE, (NN)     324c        ;  Load register pair DE with location 0x324c (19506)
354     0x2a    LD HL, (NN)     2a4c        ;  Load register pair HL with location 0x2a4c (19498)
357     0x22    LD (NN), HL     224c        ;  Load location 0x224c (19490) with the register pair HL
360     0x2a    LD HL, (NN)     3a4c        ;  Load register pair HL with location 0x3a4c (19514)
363     0x22    LD (NN), HL     324c        ;  Load location 0x324c (19506) with the register pair HL
366     0xed    LD (NN), BC     2a4c        ;  Load location 0x2a4c (19498) with register pair BC
370     0xed    LD (NN), DE     3a4c        ;  Load location 0x3a4c (19514) with register pair DE
; copy $4C22..$4C2D to $4CF2..$4CFD
374     0x21    LD HL, NN       224c        ;  Load register pair HL with 0x224c (19490)
377     0x11    LD  DE, NN      f24f        ;  Load register pair DE with 0xf24f (242)
380     0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
383     0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
; copy $4C32..$4C3D to $5062..$506D
385     0x21    LD HL, NN       324c        ;  Load register pair HL with 0x324c (19506)
388     0x11    LD  DE, NN      6250        ;  Load register pair DE with 0x6250 (98)
391     0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
394     0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
; uptime_counter();  process_messages();  call_968();
396     0xcd    CALL NN         dc01        ;  Call to 0xdc01 (476) // uptime_counter()
399     0xcd    CALL NN         2102        ;  Call to 0x2102 (545) // process_messages()
402     0xcd    CALL NN         c803        ;  Call to 0xc803 (968)
; if ( $4E00 != 0 )
; {  /*make a bunch of calls*/  }
405     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
408     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
409     0x28    JR Z, N         12          ;  Jump relative 0x12 (18) if ZERO flag is 1
411     0xcd    CALL NN         9d03        ;  Call to 0x9d03 (925)
414     0xcd    CALL NN         9014        ;  Call to 0x9014 (5264)
417     0xcd    CALL NN         1f14        ;  Call to 0x1f14 (5151)
420     0xcd    CALL NN         6702        ;  Call to 0x6702 (615)
423     0xcd    CALL NN         ad02        ;  Call to 0xad02 (685)
426     0xcd    CALL NN         fd02        ;  Call to 0xfd02 (765)
; if ( $4E00 - 1 == 0 )
; { $4EAC = $4EBC = 0; }
429     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
432     0x3d    DEC A                       ;  Decrement Accumulator
433     0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
435     0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
438     0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator
; call_11532(); call_11457();
441     0xcd    CALL NN         0c2d        ;  Call to 0x0c2d (11532)
444     0xcd    CALL NN         c12c        ;  Call to 0xc12c (11457)
; Pop most registers
447     0xfd    POP IY                      ;  Load register pair IY with top of stack
449     0xdd    POP IX                      ;  Load register pair IX with top of stack
451     0xe1    POP HL                      ;  Load register pair HL with top of stack
452     0xd1    POP DE                      ;  Load register pair DE with top of stack
453     0xc1    POP BC                      ;  Load register pair BC with top of stack
; if ( $4E00 != 0 && ( $5040 & 0x10 ) ) { reset; } // $5040.4 == service mode
454     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
457     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
458     0x28    JR Z, N         08          ;  Jump relative 0x08 (8) if ZERO flag is 1
460     0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
463     0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
465     0xca    JP Z,           0000        ;  Jump to 0x0000 (0) if ZERO flag is 1
; Set V-Sync Interupt, Enable Interrupts, Pop AF
468     0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
470     0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
473     0xfb    EI                          ;  Enable Interrupts
474     0xf1    POP AF                      ;  Load register pair AF with top of stack
475     0xc9    RET                         ;  Return



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
476     0x21    LD HL, NN       844c        ;  Load register pair HL with 0x844c (19588)
479     0x34    INC (HL)                    ;  Increment location (HL)
480     0x23    INC HL                      ;  Increment register pair HL
481     0x35    DEC (HL)                    ;  Decrement location (HL)
482     0x23    INC HL                      ;  Increment register pair HL
483     0x11    LD  DE, NN      1902        ;  Load register pair DE with 0x1902 (537)
486     0x01    LD  BC, NN      0104        ;  Load register pair BC with 0x0104 (1025)
; Our loop begins here
489     0x34    INC (HL)                    ;  Increment location (HL)
490     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
491     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
493     0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
; if first digit has wrapped
494     0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
495     0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
; increase wrap count
497     0x0c    INC C                       ;  Increment register C
; add one to the second digit and store back
498     0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
499     0xc6    ADD A, N        10          ;  Add 0x10 (16) to Accumulator (no carry)
501     0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
503     0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
; if second digit has wrapped
504     0x23    INC HL                      ;  Increment register pair HL
505     0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
506     0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
; increase wrap count
508     0x0c    INC C                       ;  Increment register C
509     0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
; reset that counter
510     0x36    LD (HL), N    00            ;  Load register pair HL with 0x00 (0)
512     0x23    INC HL                      ;  Increment register pair HL
513     0x13    INC DE                      ;  Increment register pair DE
514     0x10    DJNZ N          e5          ;  Decrement B and jump relative 0xe5 (-27) if B!=0
; store wrap count
516     0x21    LD HL, NN       8a4c        ;  Load register pair HL with 0x8a4c (19594)
519     0x71    LD (HL), C                  ;  Load location (HL) with register C
;; Pattern Generator 1
; $4C8B = ( $4C8B * 5 ) + 1;
520     0x2c    INC L                       ;  Increment register L
521     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
522     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
523     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
524     0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
525     0x3c    INC A                       ;  Increment Accumulator
526     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
;; Pattern Generator 2
; $4C8C = ( $4C8C * 13 ) + 1;
527     0x2c    INC L                       ;  Increment register L
528     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
529     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
530     0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
531     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
532     0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
533     0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
534     0x3c    INC A                       ;  Increment Accumulator
535     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
536     0xc9    RET                         ;  Return

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
545     0x21    LD HL, NN       904c        ;  Load register pair HL with 0x904c (19600)
548     0x3a    LD A, (NN)      8a4c        ;  Load Accumulator with location 0x8a4c (19594)
551     0x4f    LD c, A                     ;  Load register C with Accumulator
552     0x06    LD  B, N        10          ;  Load register B with 0x10 (16)
554     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
555     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
556     0x28    JR Z, N         2f          ;  Jump relative 0x2f (47) if ZERO flag is 1
558     0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
560     0x07    RLCA                        ;  Rotate left circular Accumulator
561     0x07    RLCA                        ;  Rotate left circular Accumulator
562     0xb9    CP A, C                     ;  Compare register C with Accumulator
563     0x30    JR NC, N        28          ;  Jump relative 0x28 (40) if CARRY flag is 0
565     0x35    DEC (HL)                    ;  Decrement location (HL)
566     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
567     0xe6    AND N           3f          ;  Bitwise AND of 0x3f (63) to Accumulator
569     0x20    JR NZ, N        22          ;  Jump relative 0x22 (34) if ZERO flag is 0
571     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
572     0xc5    PUSH BC                     ;  Load the stack with register pair BC
573     0xe5    PUSH HL                     ;  Load the stack with register pair HL
574     0x2c    INC L                       ;  Increment register L
575     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
576     0x2c    INC L                       ;  Increment register L
577     0x46    LD B, (HL)                  ;  Load register B with location (HL)
578     0x21    LD HL, NN       5b02        ;  Load register pair HL with 0x5b02 (603)
581     0xe5    PUSH HL                     ;  Load the stack with register pair HL
582     0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
603     0xe1    POP HL                      ;  Load register pair HL with top of stack
604     0xc1    POP BC                      ;  Load register pair BC with top of stack
605     0x2c    INC L                       ;  Increment register L
606     0x2c    INC L                       ;  Increment register L
607     0x2c    INC L                       ;  Increment register L
608     0x10    DJNZ N          c8          ;  Decrement B and jump relative 0xc8 (-56) if B!=0
610     0xc9    RET                         ;  Return


; display_erase("READY!") by way of write_msg();
611     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x86
614     0xc9    RET                         ;  Return


; $5006 = $4E6E << 1;  // really weird bit of logic in here. carry bit will always be 1, gets rotated into a:0
; if ( $4E6E > 0x99 )  return;  // if ( credits > 99 ) {  return;  }
615     0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
618     0xfe    CP N            99          ;  Compare 0x99 (153) with Accumulator
620     0x17    RLA                         ;  Rotate left Accumulator through carry
621     0x32    LD (NN), A      0650        ;  Load location 0x0650 (20486) with the Accumulator
624     0x1f    RRA                         ;  Rotate right Accumulator through carry
625     0xd0    RET NC                      ;  Return if CARRY flag is 0
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
626     0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
629     0x47    LD B, A                     ;  Load register B with Accumulator
630     0xcb    RLC B                       ;  Rotate register B left circular
632     0x3a    LD A, (NN)      664e        ;  Load Accumulator with location 0x664e (20070)
635     0x17    RLA                         ;  Rotate left Accumulator through carry
636     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
638     0x32    LD (NN), A      664e        ;  Load location 0x664e (20070) with the Accumulator
641     0xd6    SUB N           0c          ;  Subtract 0x0c (12) from Accumulator (no carry)
643     0xcc    CALL Z,NN       df02        ;  Call to 0xdf02 (735) if ZERO flag is 1
646     0xcb    RLC B                       ;  Rotate register B left circular
648     0x3a    LD A, (NN)      674e        ;  Load Accumulator with location 0x674e (20071)
651     0x17    RLA                         ;  Rotate left Accumulator through carry
652     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
654     0x32    LD (NN), A      674e        ;  Load location 0x674e (20071) with the Accumulator
657     0xd6    SUB N           0c          ;  Subtract 0x0c (12) from Accumulator (no carry)
659     0xc2    JP NZ, NN       9a02        ;  Jump to 0x9a02 (666) if ZERO flag is 0
662     0x21    LD HL, NN       694e        ;  Load register pair HL with 0x694e (20073)
665     0x34    INC (HL)                    ;  Increment location (HL)
666     0xcb    RLC B                       ;  Rotate register B left circular
668     0x3a    LD A, (NN)      684e        ;  Load Accumulator with location 0x684e (20072)
671     0x17    RLA                         ;  Rotate left Accumulator through carry
672     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
674     0x32    LD (NN), A      684e        ;  Load location 0x684e (20072) with the Accumulator
677     0xd6    SUB N           0c          ;  Subtract 0x0c (12) from Accumulator (no carry)
679     0xc0    RET NZ                      ;  Return if ZERO flag is 0
680     0x21    LD HL, NN       694e        ;  Load register pair HL with 0x694e (20073)
683     0x34    INC (HL)                    ;  Increment location (HL)
684     0xc9    RET                         ;  Return


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
685     0x3a    LD A, (NN)      694e        ;  Load Accumulator with location 0x694e (20073)
688     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
689     0xc8    RET Z                       ;  Return if ZERO flag is 1
690     0x47    LD B, A                     ;  Load register B with Accumulator
691     0x3a    LD A, (NN)      6a4e        ;  Load Accumulator with location 0x6a4e (20074)
694     0x5f    LD E, A                     ;  Load register E with Accumulator
695     0xfe    CP N            00          ;  Compare 0x00 (0) with Accumulator
697     0xc2    JP NZ, NN       c402        ;  Jump to 0xc402 (708) if ZERO flag is 0
700     0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
702     0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
705     0xcd    CALL NN         df02        ;  Call to 0xdf02 (735)
708     0x7b    LD A, E                     ;  Load Accumulator with register E
709     0xfe    CP N            08          ;  Compare 0x08 (8) with Accumulator
711     0xc2    JP NZ, NN       ce02        ;  Jump to 0xce02 (718) if ZERO flag is 0
714     0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
715     0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
718     0x1c    INC E                       ;  Increment register E
719     0x7b    LD A, E                     ;  Load Accumulator with register E
720     0x32    LD (NN), A      6a4e        ;  Load location 0x6a4e (20074) with the Accumulator
723     0xd6    SUB N           10          ;  Subtract 0x10 (16) from Accumulator (no carry)
725     0xc0    RET NZ                      ;  Return if ZERO flag is 0
726     0x32    LD (NN), A      6a4e        ;  Load location 0x6a4e (20074) with the Accumulator
729     0x05    DEC B                       ;  Decrement register B
730     0x78    LD A, B                     ;  Load Accumulator with register B
731     0x32    LD (NN), A      694e        ;  Load location 0x694e (20073) with the Accumulator
734     0xc9    RET                         ;  Return


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
735     0x3a    LD A, (NN)      6b4e        ;  Load Accumulator with location 0x6b4e (20075)
738     0x21    LD HL, NN       6c4e        ;  Load register pair HL with 0x6c4e (20076)
741     0x34    INC (HL)                    ;  Increment location (HL)
742     0x96    SUB A, (HL)                 ;  Subtract location (HL) from Accumulator (no carry)
743     0xc0    RET NZ                      ;  Return if ZERO flag is 0
744     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
745     0x3a    LD A, (NN)      6d4e        ;  Load Accumulator with location 0x6d4e (20077)
748     0x21    LD HL, NN       6e4e        ;  Load register pair HL with 0x6e4e (20078)
751     0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
752     0x27    DAA                         ;  Decimal adjust Accumulator
753     0xd2    JP NC, NN       f602        ;  Jump to 0xf602 (758) if CARRY flag is 0
756     0x3e    LD A,N          99          ;  Load Accumulator with 0x99 (153)
758     0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
759     0x21    LD HL, NN       9c4e        ;  Load register pair HL with 0x9c4e (20124)
762     0xcb    SET 1,(HL)                  ;  Set bit 1 of location (HL)
764     0xc9    RET                         ;  Return


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
765     0x21    LD HL, NN       ce4d        ;  Load register pair HL with 0xce4d (19918)
768     0x34    INC (HL)                    ;  Increment location (HL)
769     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
770     0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
772     0x20    JR NZ, N        1f          ;  Jump relative 0x1f (31) if ZERO flag is 0
774     0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
775     0x0f    RRCA                        ;  Rotate right circular Accumulator
776     0x0f    RRCA                        ;  Rotate right circular Accumulator
777     0x0f    RRCA                        ;  Rotate right circular Accumulator
778     0x0f    RRCA                        ;  Rotate right circular Accumulator
779     0x47    LD B, A                     ;  Load register B with Accumulator
780     0x3a    LD A, (NN)      d64d        ;  Load Accumulator with location 0xd64d (19926)
783     0x2f    CPL                         ;  Complement Accumulator (1's complement)
784     0xb0    OR A, B                     ;  Bitwise OR of register B to Accumulator
785     0x4f    LD c, A                     ;  Load register C with Accumulator
786     0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
789     0xd6    SUB N           01          ;  Subtract 0x01 (1) from Accumulator (no carry)
791     0x30    JR NC, N        02          ;  Jump relative 0x02 (2) if CARRY flag is 0
793     0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
794     0x4f    LD c, A                     ;  Load register C with Accumulator
795     0x28    JR Z, N         01          ;  Jump relative 0x01 (1) if ZERO flag is 1
797     0x79    LD A, C                     ;  Load Accumulator with register C
798     0x32    LD (NN), A      0550        ;  Load location 0x0550 (20485) with the Accumulator
801     0x79    LD A, C                     ;  Load Accumulator with register C
802     0x32    LD (NN), A      0450        ;  Load location 0x0450 (20484) with the Accumulator
805     0xdd    LD IX, NN       d843        ;  Load register pair IX with 0xd843 (17368)
809     0xfd    LD IY, NN       c543        ;  Load register pair IY with 0xc543 (17349)
813     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
816     0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
818     0xca    JP Z,           4403        ;  Jump to 0x4403 (836) if ZERO flag is 1
821     0x3a    LD A, (NN)      034e        ;  Load Accumulator with location 0x034e (19971)
824     0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
826     0xd2    JP NC, NN       4403        ;  Jump to 0x4403 (836) if CARRY flag is 0
829     0xcd    CALL NN         6903        ;  Call to 0x6903 (873)
832     0xcd    CALL NN         7603        ;  Call to 0x7603 (886)
835     0xc9    RET                         ;  Return


; A = $4DCE;
; if ( $4E09 == 0 )
; {  if ( A & 0x10 ) draw_1up();  else clear_1up();  }
; else
; {  if ( A & 0x10 ) draw_2up();  else clear_2up();  }
; if ( $4E07 == 0 )  clear_2up();  // $4E07 == Act I Scenes
; return;
836     0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
839     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
840     0x3a    LD A, (NN)      ce4d        ;  Load Accumulator with location 0xce4d (19918)
843     0xc2    JP NZ, NN       5903        ;  Jump to 0x5903 (857) if ZERO flag is 0
846     0xcb    BIT 4,A                     ;  Test bit 4 of Accumulator
848     0xcc    CALL Z,NN       6903        ;  Call to 0x6903 (873) if ZERO flag is 1
851     0xc4    CALL NZ,NN      8303        ;  Call to 0x8303 (899) if ZERO flag is 0
854     0xc3    JP NN           6103        ;  Jump to 0x6103 (865)
857     0xcb    BIT 4,A                     ;  Test bit 4 of Accumulator
859     0xcc    CALL Z,NN       7603        ;  Call to 0x7603 (886) if ZERO flag is 1
862     0xc4    CALL NZ,NN      9003        ;  Call to 0x9003 (912) if ZERO flag is 0
865     0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
868     0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
869     0xcc    CALL Z,NN       9003        ;  Call to 0x9003 (912) if ZERO flag is 1
872     0xc9    RET                         ;  Return

;; draw_1up(); // according to my written notes...
873     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x00 () ) with 0x50 ()
877     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x01 () ) with 0x55 ()
881     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x31 ()
885     0xc9    RET                         ;  Return

;; draw_2up(); // according to my written notes...
886     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x50 ()
890     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x55 ()
894     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x02 () ) with 0x32 ()
898     0xc9    RET                         ;  Return

;; clear_1up(); // according to my written notes...
899     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x00 () ) with 0x40 ()
903     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x01 () ) with 0x40 ()
907     0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x40 ()
911     0xc9    RET                         ;  Return

;; clear_2up(); // according to my written notes...
912     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x40 ()
916     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x40 ()
920     0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x02 () ) with 0x40 ()
924     0xc9    RET                         ;  Return

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
925     0x3a    LD A, (NN)      064e        ;  Load Accumulator with location 0x064e (19974)
928     0xd6    SUB N           05          ;  Subtract 0x05 (5) from Accumulator (no carry)
930     0xd8    RET C                       ;  Return if CARRY flag is 1
931     0x2a    LD HL, (NN)     084d        ;  Load register pair HL with location 0x084d (19720)
934     0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
936     0x0e    LD  C, N        10          ;  Load register C with 0x10 (16)
938     0x7d    LD A, L                     ;  Load Accumulator with register L
939     0x32    LD (NN), A      064d        ;  Load location 0x064d (19718) with the Accumulator
942     0x32    LD (NN), A      d24d        ;  Load location 0xd24d (19922) with the Accumulator
945     0x91    SUB A, C                    ;  Subtract register C from Accumulator (no carry)
946     0x32    LD (NN), A      024d        ;  Load location 0x024d (19714) with the Accumulator
949     0x32    LD (NN), A      044d        ;  Load location 0x044d (19716) with the Accumulator
952     0x7c    LD A, H                     ;  Load Accumulator with register H
953     0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
954     0x32    LD (NN), A      034d        ;  Load location 0x034d (19715) with the Accumulator
957     0x32    LD (NN), A      074d        ;  Load location 0x074d (19719) with the Accumulator
960     0x91    SUB A, C                    ;  Subtract register C from Accumulator (no carry)
961     0x32    LD (NN), A      054d        ;  Load location 0x054d (19717) with the Accumulator
964     0x32    LD (NN), A      d34d        ;  Load location 0xd34d (19923) with the Accumulator
967     0xc9    RET                         ;  Return

; A = $4E00;  jump_table();
968     0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
971     0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $03D4 : 980
; 1 : $03FE : 1022
; 2 : $05E5 : 1509
; 3 : $06BE : 1726

; A = $4E01;  jump_table();
980     0x3a    LD A, (NN)      014e        ;  Load Accumulator with location 0x014e (19969)
983     0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $03DC : 988
; 1 : $000C : return;

988     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x00
991     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x06, 0x00
994     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x00
997     0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x14, 0x00
1000    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x18, 0x00
1003    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x00
1006    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1E, 0x00
1009    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x07, 0x00

; $4E01++;  $5001 = 1;
1012    0x21    LD HL, NN       014e        ;  Load register pair HL with 0x014e (19969)
1015    0x34    INC (HL)                    ;  Increment location (HL)
1016    0x21    LD HL, NN       0150        ;  Load register pair HL with 0x0150 (20481)
1019    0x36    LD (HL), N      01          ;  Load register pair HL with 0x01 (1)
1021    0xc9    RET                         ;  Return


; display_credits_info();  // via call_11169();
1022    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
1025    0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
1028    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
1029    0x28    JR Z, N         0c          ;  Jump relative 0x0c (12) if ZERO flag is 1
1031    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
1032    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
1035    0x32    LD (NN), A      024e        ;  Load location 0x024e (19970) with the Accumulator
1038    0x21    LD HL, NN       004e        ;  Load register pair HL with 0x004e (19968)
;; 1040-1047 : On Ms. Pac-Man patched in from $8008-$800F
1041    0x34    INC (HL)                    ;  Increment location (HL)
1042    0xc9    RET                         ;  Return
1043    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
;; On Ms. Pac-Man:
;; 1043  $0413   0xc3    JP nn           5c3e        ;  Jump to $nn
1046    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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

1119    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01  // clear(0x01);  // clear playfield
1122    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x00
1125    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x00
1128    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1E, 0x00
1131    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
1133    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
1136    0xc9    RET                         ;  Return


; draw_ghost($4304, 1); // draw red ghost at 5, 4 on playfield
1137    0x21    LD HL, NN       0443        ;  Load register pair HL with 0x0443 (17156)
1140    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
1142    0xcd    CALL NN         bf05        ;  Call to 0xbf05 (1471)
; write_string("CHARACTER : NICKNAME"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
1145    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
1147    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
1150    0xc9    RET                         ;  Return

; write_string("-SHADOW    "); via 1427 -> Call to 0x4200 (66) -> RST 0x30
1151    0x0e    LD  C, N        14          ;  Load register C with 0x14 (20)
1153    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
1156    0xc9    RET                         ;  Return

; write_string(""BLINKY""); via 1427 -> Call to 0x4200 (66) -> RST 0x30
1157    0x0e    LD  C, N        0d          ;  Load register C with 0x0d (13)
1159    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
1162    0xc9    RET                         ;  Return

; draw_ghost($4307, 3); // draw pink ghost at 5, 7 on playfield 
1163    0x21    LD HL, NN       0743        ;  Load register pair HL with 0x0743 (17159)
1166    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
1168    0xcd    CALL NN         bf05        ;  Call to 0xbf05 (1471)
; write_string("CHARACTER : NICKNAME"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
1171    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
1173    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
1176    0xc9    RET                         ;  Return

; write_string("-SPEEDY   "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
1177    0x0e    LD  C, N        16          ;  Load register C with 0x16 (22)
1179    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
1182    0xc9    RET                         ;  Return

; write_string(""PINKY"  "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
1183    0x0e    LD  C, N        0f          ;  Load register C with 0x0f (15)
1185    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
1188    0xc9    RET                         ;  Return

; draw_ghost($430A, 5); // draw blue ghost at 5, 10 on playfield
1189    0x21    LD HL, NN       0a43        ;  Load register pair HL with 0x0a43 (17162)
1192    0x3e    LD A,N          05          ;  Load Accumulator with 0x05 (5)
1194    0xcd    CALL NN         bf05        ;  Call to 0xbf05 (1471)
; write_string("CHARACTER : NICKNAME"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
1197    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
1199    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
1202    0xc9    RET                         ;  Return

; write_string("-BASHFUL  "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
1203    0x0e    LD  C, N        33          ;  Load register C with 0x33 (51)
1205    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
1208    0xc9    RET                         ;  Return

; write_string(""INKY"   "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
1209    0x0e    LD  C, N        2f          ;  Load register C with 0x2f (47)
1211    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
1214    0xc9    RET                         ;  Return

; draw_ghost($430D, 7); // draw orange ghost at 5, 13 on playfield
1215    0x21    LD HL, NN       0d43        ;  Load register pair HL with 0x0d43 (17165)
1218    0x3e    LD A,N          07          ;  Load Accumulator with 0x07 (7)
1220    0xcd    CALL NN         bf05        ;  Call to 0xbf05 (1471)
; write_string("CHARACTER : NICKNAME"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
1223    0x0e    LD  C, N        0c          ;  Load register C with 0x0c (12)
1225    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
1228    0xc9    RET                         ;  Return

; write_string("-POKEY    "); via 1427  -> Call to 0x4200 (66) -> RST 0x30
1229    0x0e    LD  C, N        35          ;  Load register C with 0x35 (53)
1231    0xcd    CALL NN         9305        ;  Call to 0x9305 (1427)
1234    0xc9    RET                         ;  Return

; write_string(""CLYDE"  "); via 1408  -> Call to 0x4200 (66) -> RST 0x30
1235    0x0e    LD  C, N        31          ;  Load register C with 0x31 (49)
1237    0xc3    JP NN           8005        ;  Jump to 0x8005 (1408)

; display("&littledot; 10 pts") by way of write_msg();
1240    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x11
; write_string("&bigdot; 50 pts"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
1243    0x0e    LD  C, N        12          ;  Load register C with 0x12 (18)
1245    0xc3    JP NN           8505        ;  Jump to 0x8505 (1413)

; write_string("&copy; 1980 MIDWAY MFG CO"); via 1413 -> Call to 0x4200 (66) -> RST 0x30
1248    0x0e    LD  C, N        13          ;  Load register C with 0x13 (19)
1250    0xcd    CALL NN         8505        ;  Call to 0x8505 (1413)
;
1253    0xcd    CALL NN         7908        ;  Call to 0x7908 (2169)
1256    0x35    DEC (HL)                    ;  Decrement location (HL)
1257    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x11, 0x00
1260    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x05, 0x01
1263    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x10, 0x14
1266    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x01
1269    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
1271    0x32    LD (NN), A      144e        ;  Load location 0x144e (19988) with the Accumulator
1274    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
1275    0x32    LD (NN), A      704e        ;  Load location 0x704e (20080) with the Accumulator
1278    0x32    LD (NN), A      154e        ;  Load location 0x154e (19989) with the Accumulator
1281    0x21    LD HL, NN       3243        ;  Load register pair HL with 0x3243 (17202)
1284    0x36    LD (HL), N      14          ;  Load register pair HL with 0x14 (20)

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
1286    0x3e    LD A,N          fc          ;  Load Accumulator with 0xfc (252)
1288    0x11    LD  DE, NN      2000        ;  Load register pair DE with 0x2000 (32)
1291    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
1293    0xdd    LD IX, NN       4040        ;  Load register pair IX with 0x4040 (16448)
1297    0xdd    LD (IX+d), A    11          ;  Load location ( IX + 0x11 () ) with Accumulator
1300    0xdd    LD (IX+d), A    13          ;  Load location ( IX + 0x13 () ) with Accumulator
1303    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
1305    0x10    DJNZ N          f6          ;  Decrement B and jump relative 0xf6 (-10) if B!=0
1307    0xc9    RET                         ;  Return


;; HL = 0x4DA0;
;; B = 0x21;
;; A = $4D3A;  // Pacman.X (21-3A)
1308    0x21    LD HL, NN       a04d        ;  Load register pair HL with 0xa04d (19872)
1311    0x06    LD  B, N        21          ;  Load register B with 0x21 (33)
1313    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
;; if ( A == B )
;; {
;;     $HL = 0x01;
;;     $4E02++;  return;  // via advance_attract_screen(); 
;; }
1316    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
1317    0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
1319    0x36    LD (HL), N      01          ;  Load register pair HL with 0x01 (1)
1321    0xc3    JP NN           8e05        ;  Jump to 0x8e05 (1422)
;; else, all these calls...
1324    0xcd    CALL NN         1710        ;  Call to 0x1710 (4119)
1327    0xcd    CALL NN         1710        ;  Call to 0x1710 (4119)
1330    0xcd    CALL NN         230e        ;  Call to 0x230e (3619)
1333    0xcd    CALL NN         0d0c        ;  Call to 0x0d0c (3085)
1336    0xcd    CALL NN         d60b        ;  Call to 0xd60b (3030)
1339    0xcd    CALL NN         a505        ;  Call to 0xa505 (1445)
1342    0xcd    CALL NN         fe1e        ;  Call to 0xfe1e (7934)
1345    0xcd    CALL NN         251f        ;  Call to 0x251f (7973)
1348    0xcd    CALL NN         4c1f        ;  Call to 0x4c1f (8012)
1351    0xcd    CALL NN         731f        ;  Call to 0x731f (8051)
1354    0xc9    RET                         ;  Return


;; HL = 0x4DA1;
;; B = 0x20;
;; A = $4D32;
;; jump(1316);
1355    0x21    LD HL, NN       a14d        ;  Load register pair HL with 0xa14d (19873)
1358    0x06    LD  B, N        20          ;  Load register B with 0x20 (32)
1360    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
1363    0xc3    JP NN           2405        ;  Jump to 0x2405 (1316)


;; HL = 0x4DA2;
;; B = 0x22;
;; A = $4D32;
;; jump(1316);
1366    0x21    LD HL, NN       a24d        ;  Load register pair HL with 0xa24d (19874)
1369    0x06    LD  B, N        22          ;  Load register B with 0x22 (34)
1371    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
1374    0xc3    JP NN           2405        ;  Jump to 0x2405 (1316)


;; HL = 0x4DA3;
;; B = 0x24;
;; A = $4D32;
;; jump(1316);
1377    0x21    LD HL, NN       a34d        ;  Load register pair HL with 0xa34d (19875)
1380    0x06    LD  B, N        24          ;  Load register B with 0x24 (36)
1382    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
1385    0xc3    JP NN           2405        ;  Jump to 0x2405 (1316)


;; if ( $4DD0 + $4DD1 == 6 ) {  jump(1422);  } else {  jump(1324);  }
1388    0x3a    LD A, (NN)      d04d        ;  Load Accumulator with location 0xd04d (19920)
1391    0x47    LD B, A                     ;  Load register B with Accumulator
1392    0x3a    LD A, (NN)      d14d        ;  Load Accumulator with location 0xd14d (19921)
1395    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
1396    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
1398    0xca    JP Z,           8e05        ;  Jump to 0x8e05 (1422) if ZERO flag is 1
1401    0xc3    JP NN           2c05        ;  Jump to 0x2c05 (1324)


; call(1726);
1404    0xcd    CALL NN         be06        ;  Call to 0xbe06 (1726)
1407    0xc9    RET                         ;  Return


; display($4E75+C) by way of insert_msg(0x1c, A);
1408    0x3a    LD A, (NN)      754e        ;  Load Accumulator with location 0x754e (20085)
1411    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
1412    0x4f    LD c, A                     ;  Load register C with Accumulator
1413    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
1415    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
1418    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4A, 0x02, 0x00


; advance_attract_screen();
;; $4E02++;  // attract screen frame
1422    0x21    LD HL, NN       024e        ;  Load register pair HL with 0x024e (19970)
1425    0x34    INC (HL)                    ;  Increment location (HL)
1426    0xc9    RET                         ;  Return


; display($4E75+C) by way of insert_msg(0x1c, A);
1427    0x3a    LD A, (NN)      754e        ;  Load Accumulator with location 0x754e (20085)
1430    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
1431    0x4f    LD c, A                     ;  Load register C with Accumulator
1432    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
1434    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
1437    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x45, 0x02, 0x00
1441    0xcd    CALL NN         8e05        ;  Call to 0x8e05 (1422)
1444    0xc9    RET                         ;  Return


;; if ( $4DB5 == 0 ) {  return;  }
;; $4DB5 = 0;
;;;;  The XOR indexing into the dir table is a 180 degree turn
;; $4D3C = B = $4D30 ^ 0x02;
;; $4D26/7 = table_and_index_to_address($GHOST_DIR_TABLE, B);  // rst_18;
1445    0x3a    LD A, (NN)      b54d        ;  Load Accumulator with location 0xb54d (19893)
1448    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
1449    0xc8    RET Z                       ;  Return if ZERO flag is 1
1450    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
1451    0x32    LD (NN), A      b54d        ;  Load location 0xb54d (19893) with the Accumulator
1454    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
1457    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
1459    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
1462    0x47    LD B, A                     ;  Load register B with Accumulator
1463    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
1466    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
1467    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
1470    0xc9    RET                         ;  Return


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
1471    0x36    LD (HL), N      b1          ;  Load location (HL) with 0xb1 (177)
1473    0x2c    INC L                       ;  Increment register L
1474    0x36    LD (HL), N      b3          ;  Load location (HL) with 0xb3 (179)
1476    0x2c    INC L                       ;  Increment register L
1477    0x36    LD (HL), N      b5          ;  Load location (HL) with 0xb5 (181)
1479    0x01    LD  BC, NN      1e00        ;  Load register pair BC with 0x1e00 (30)
1482    0x09    ADD HL, BC                  ;  Add register pair BC to HL
1483    0x36    LD (HL), N      b0          ;  Load location (HL) with 0xb0 (176)
1485    0x2c    INC L                       ;  Increment register L
1486    0x36    LD (HL), N      b2          ;  Load register pair HL with 0xb2 (178)
1488    0x2c    INC L                       ;  Increment register L
1489    0x36    LD (HL), N      b4          ;  Load location (HL) with 0xb4 (180)
1491    0x11    LD  DE, NN      0004        ;  Load register pair DE with 0x0004 (0)
1494    0x19    ADD HL, DE                  ;  Add register pair DE to HL
1495    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
1496    0x2d    DEC L                       ;  Decrement register L
1497    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
1498    0x2d    DEC L                       ;  Decrement register L
1499    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
1500    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
1501    0xed    SBC HL, BC                  ;  Subtract with carry register pair BC from HL
1503    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
1504    0x2d    DEC L                       ;  Decrement register L
1505    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
1506    0x2d    DEC L                       ;  Decrement register L
1507    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
1508    0xc9    RET                         ;  Return


; A = $4E03;  // $4E03 = Mode [00 - Attract Screen + Gameplay, 01 - Push Start Button, 03 - Game Start ("Ready!")]
1509    0x3a    LD A, (NN)      034e        ;  Load Accumulator with location 0x034e (19971)
1512    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $05F3 - 
; 1 : $061B -
; 2 : $0674 -
; 3 : $000C - return;
; 4 : $06A8 -

; display_credits_info();  // via call_11169();
1523    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
1526    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01  // clear(0x01);  // clear playfield
1529    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x00
; display("PUSH START BUTTON") by way of write_msg();
1532    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x07
; display("&copy; MIDWAY MFG.CO.") by way of write_msg();
1535    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x0B
1538    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1E, 0x00
; $4E03++;  // $4E03 = Mode [00 - Attract Screen + Gameplay, 01 - Push Start Button, 03 - Game Start ("Ready!")]
; $4DD6 = 0x01;
1541    0x21    LD HL, NN       034e        ;  Load register pair HL with 0x034e (19971)
1544    0x34    INC (HL)                    ;  Increment location (HL)
1545    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
1547    0x32    LD (NN), A      d64d        ;  Load location 0xd64d (19926) with the Accumulator
; if ( $4E71 == 0xFF ) {  return;  }
1550    0x3a    LD A, (NN)      714e        ;  Load Accumulator with location 0x714e (20081)
1553    0xfe    CP N            ff          ;  Compare 0xff (255) with Accumulator
1555    0xc8    RET Z                       ;  Return if ZERO flag is 1
; display("BONUS PAC-MAN FOR   00pts") by way of write_msg();
1556    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x0A
1559    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1F, 0x00
1562    0xc9    RET                         ;  Return


; display_credits();  // via call_11169();
1563    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
; if ( $4E6E == 0x01 ) {  write_string(8);  }  // "1 PLAYER ONLY "
;                 else {  write_string(9);  }  // "1 OR 2 PLAYERS"
1566    0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
1569    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
1571    0x06    LD  B, N        09          ;  Load register B with 0x09 (9)
1573    0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
1575    0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
1577    0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

;;; this seems like a very convoluted way of testing for start button presses,
;;; filtering Start 2 if the number of credits is > 1
; A = $5040; // $5040 - IN1 - cocktail/upright, Start 2, Start 1, service mode, 2 down, 2 right, 2 left, 2 up
; if ( $4E6E =! 0x01 && IN1.Start2 == 1 ) {  $4E70 = 0x01;  }
; elsif ( IN1.Start1 != 1 ) {  return;  }
1580    0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
1583    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
1585    0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
1588    0x28    JR Z, N         0c          ;  Jump relative 0x0c (12) if ZERO flag is 1
1590    0xcb    BIT 6,A                     ;  Test bit 6 of Accumulator
1592    0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
1594    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
1596    0x32    LD (NN), A      704e        ;  Load location 0x704e (20080) with the Accumulator
1599    0xc3    JP NN           4906        ;  Jump to 0x4906 (1609)
1602    0xcb    BIT 5,A                     ;  Test bit 5 of Accumulator
1604    0xc0    RET NZ                      ;  Return if ZERO flag is 0
; $4E70 = 0x00;
1605    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
1606    0x32    LD (NN), A      704e        ;  Load location 0x704e (20080) with the Accumulator

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
1609    0x3a    LD A, (NN)      6b4e        ;  Load Accumulator with location 0x6b4e (20075)
1612    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
1613    0x28    JR Z, N         15          ;  Jump relative 0x15 (21) if ZERO flag is 1
1615    0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
1618    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
1619    0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
1622    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
1624    0xc6    ADD A, N        99          ;  Add 0x99 (153) to Accumulator (no carry)
1626    0x27    DAA                         ;  Decimal adjust Accumulator
1627    0xc6    ADD A, N        99          ;  Add 0x99 (153) to Accumulator (no carry)
1629    0x27    DAA                         ;  Decimal adjust Accumulator
1630    0x32    LD (NN), A      6e4e        ;  Load location 0x6e4e (20078) with the Accumulator

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
1633    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
1636    0x21    LD HL, NN       034e        ;  Load register pair HL with 0x034e (19971)
1639    0x34    INC (HL)                    ;  Increment location (HL)
1640    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
1641    0x32    LD (NN), A      d64d        ;  Load location 0xd64d (19926) with the Accumulator
1644    0x3c    INC A                       ;  Increment Accumulator
1645    0x32    LD (NN), A      cc4e        ;  Load location 0xcc4e (20172) with the Accumulator
1648    0x32    LD (NN), A      dc4e        ;  Load location 0xdc4e (20188) with the Accumulator
1651    0xc9    RET                         ;  Return


1652    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01  // clear(0x01);  // clear playfield
1655    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x01
1658    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x02, 0x00
1661    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x12, 0x00
1664    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x03, 0x00
; display("PLAYER ONE") by way of write_msg();
1667    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x03
; display("READY!") by way of write_msg();
1670    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x06
1673    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x18, 0x00
1676    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1B, 0x00
; $4E13 = 0;  // Current board?
; $4E14 = $4E15 = $4E6F;  // remaining_lives = ??? = lives_per_game;
1679    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
1680    0x32    LD (NN), A      134e        ;  Load location 0x134e (19987) with the Accumulator
1683    0x3a    LD A, (NN)      6f4e        ;  Load Accumulator with location 0x6f4e (20079)
1686    0x32    LD (NN), A      144e        ;  Load location 0x144e (19988) with the Accumulator
1689    0x32    LD (NN), A      154e        ;  Load location 0x154e (19989) with the Accumulator
1692    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1A, 0x00
1695    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x57, 0x01, 0x03
; Mode++;
1699    0x21    LD HL, NN       034e        ;  Load register pair HL with 0x034e (19971)
1702    0x34    INC (HL)                    ;  Increment location (HL)
1703    0xc9    RET                         ;  Return


; remaining_lives--;
; call(11114);
; $4E02 = $4E03 = $4E04 = 0;  // Attract_frame = Mode = Game_frame = 0;
; $4E00++;  // Soundbank++;
; return;
1704    0x21    LD HL, NN       154e        ;  Load register pair HL with 0x154e (19989)
1707    0x35    DEC (HL)                    ;  Decrement location (HL)
1708    0xcd    CALL NN         6a2b        ;  Call to 0x6a2b (11114)
1711    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
1712    0x32    LD (NN), A      034e        ;  Load location 0x034e (19971) with the Accumulator
1715    0x32    LD (NN), A      024e        ;  Load location 0x024e (19970) with the Accumulator
1718    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
1721    0x21    LD HL, NN       004e        ;  Load register pair HL with 0x004e (19968)
1724    0x34    INC (HL)                    ;  Increment location (HL)
1725    0xc9    RET                         ;  Return


; rst_20(Game_frame);
1726    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
1729    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
1806    0x78    LD A, B                     ;  Load Accumulator with register B
1807    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
1808    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
1810    0x2a    LD HL, (NN)     0a4e        ;  Load register pair HL with location 0x0a4e (19978)
1813    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
1814    0xdd    LD IX, NN       9607        ;  Load register pair IX with 0x9607 (1942)
1818    0x47    LD B, A                     ;  Load register B with Accumulator
1819    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1820    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1821    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
1822    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
1823    0x5f    LD E, A                     ;  Load register E with Accumulator
1824    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
1826    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
1828    0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
1831    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1832    0x47    LD B, A                     ;  Load register B with Accumulator
1833    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1834    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1835    0x4f    LD c, A                     ;  Load register C with Accumulator
1836    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1837    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1838    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
1839    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
1840    0x5f    LD E, A                     ;  Load register E with Accumulator
1841    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
1843    0x21    LD HL, NN       0f33        ;  Load register pair HL with 0x0f33 (13071)
1846    0x19    ADD HL, DE                  ;  Add register pair DE to HL
1847    0xcd    CALL NN         1408        ;  Call to 0x1408 (2068)

;; $4DB0 = $(IX+1);
;; HL = $0843 + ( $(IX+2) * 3 );  // double-byte operations
;; call_2106();  // triple_byte_copy_4DB8(HL);
1850    0xdd    LD A, (IX+d)    01          ;  Load Accumulator with location ( IX + 0x01 () )
1853    0x32    LD (NN), A      b04d        ;  Load location 0xb04d (19888) with the Accumulator
1856    0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
1859    0x47    LD B, A                     ;  Load register B with Accumulator
1860    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1861    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
1862    0x5f    LD E, A                     ;  Load register E with Accumulator
1863    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
1865    0x21    LD HL, NN       4308        ;  Load register pair HL with 0x4308 (2115)
1868    0x19    ADD HL, DE                  ;  Add register pair DE to HL
1869    0xcd    CALL NN         3a08        ;  Call to 0x3a08 (2106)

;; $4DBB = $084F + ( $(IX+3) * 2 );  // double-byte operations
1872    0xdd    LD A, (IX+d)    03          ;  Load Accumulator with location ( IX + 0x03 () )
1875    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1876    0x5f    LD E, A                     ;  Load register E with Accumulator
1877    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
1879    0xfd    LD IY, NN       4f08        ;  Load register pair IY with 0x4f08 (2127)
1883    0xfd    ADD IY, DE                  ;  Add register pair DE to IY
1885    0xfd    LD L, (IY + N)  00          ;  Load register L with location ( IY + 0x00 () )
1888    0xfd    LD H, (IY + N)  01          ;  Load register H with location ( IY + 0x01 () )
1891    0x22    LD (NN), HL     bb4d        ;  Load location 0xbb4d (19899) with the register pair HL

;; $4DBD = $0861 + ( $(IX+4) * 2 );  // double-byte operations
1894    0xdd    LD A, (IX+d)    04          ;  Load Accumulator with location ( IX + 0x04 () )
1897    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1898    0x5f    LD E, A                     ;  Load register E with Accumulator
1899    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
1901    0xfd    LD IY, NN       6108        ;  Load register pair IY with 0x6108 (2145)
1905    0xfd    ADD IY, DE                  ;  Add register pair DE to IY
1907    0xfd    LD L, (IY + N)  00          ;  Load register L with location ( IY + 0x00 () )
1910    0xfd    LD H, (IY + N)  01          ;  Load register H with location ( IY + 0x01 () )
1913    0x22    LD (NN), HL     bd4d        ;  Load location 0xbd4d (19901) with the register pair HL

;; $4D95 = $0873 + ( $(IX+5) * 2 );  // double-byte operations
1916    0xdd    LD A, (IX+d)    05          ;  Load Accumulator with location ( IX + 0x05 () )
1919    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
1920    0x5f    LD E, A                     ;  Load register E with Accumulator
1921    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
1923    0xfd    LD IY, NN       7308        ;  Load register pair IY with 0x7308 (2163)
1927    0xfd    ADD IY, DE                  ;  Add register pair DE to IY
1929    0xfd    LD L, (IY + N)  00          ;  Load register L with location ( IY + 0x00 () )
1932    0xfd    LD H, (IY + N)  01          ;  Load register H with location ( IY + 0x01 () )
1935    0x22    LD (NN), HL     954d        ;  Load location 0x954d (19861) with the register pair HL

;; call_11242();
1938    0xcd    CALL NN         ea2b        ;  Call to 0xea2b (11242)
1941    0xc9    RET                         ;  Return


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
2068    0x11    LD  DE, NN      464d        ;  Load register pair DE with 0x464d (70)
2071    0x01    LD  BC, NN      1c00        ;  Load register pair BC with 0x1c00 (28)
2074    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
2076    0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
2079    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2080    0xed    SBC HL, BC                  ;  Subtract with carry register pair BC from HL
2082    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
2084    0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
2087    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2088    0xed    SBC HL, BC                  ;  Subtract with carry register pair BC from HL
2090    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
2092    0x01    LD  BC, NN      0c00        ;  Load register pair BC with 0x0c00 (12)
2095    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2096    0xed    SBC HL, BC                  ;  Subtract with carry register pair BC from HL
2098    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
2100    0x01    LD  BC, NN      0e00        ;  Load register pair BC with 0x0e00 (14)
2103    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
2105    0xc9    RET                         ;  Return

;; triple_byte_copy_4DB8(HL);
; $4DB8 = $HL;
; $4DB9 = $(HL+1);
; $4DBA = $(HL+2);
; return;
2106    0x11    LD  DE, NN      b84d        ;  Load register pair DE with 0xb84d (184)
2109    0x01    LD  BC, NN      0300        ;  Load register pair BC with 0x0300 (3)
2112    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
2114    0xc9    RET                         ;  Return


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
2169    0x21    LD HL, NN       094e        ;  Load register pair HL with 0x094e (19977)
2172    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
2173    0x06    LD  B, N        0b          ;  Load register B with 0x0b (11)
2175    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
; Fill $4E16-$4E33 with 0xFF
; Fill $4D34-$4D37 with 0x14
2176    0xcd    CALL NN         c924        ;  Call to 0xc924 (9417)
; $4E0A = Difficuly ( Normal=0x6800, Hard=0x7D00 )
2179    0x2a    LD HL, (NN)     734e        ;  Load register pair HL with location 0x734e (20083)
2182    0x22    LD (NN), HL     0a4e        ;  Load location 0x0a4e (19978) with the register pair HL
; memcpy($4E0A, $4E38, 46);
2185    0x21    LD HL, NN       0a4e        ;  Load register pair HL with 0x0a4e (19978)
2188    0x11    LD  DE, NN      384e        ;  Load register pair DE with 0x384e (56)
2191    0x01    LD  BC, NN      2e00        ;  Load register pair BC with 0x2e00 (46)
2194    0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; decrement BC;
; $4E04++;  // $4E04 == game frame
2196    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2199    0x34    INC (HL)                    ;  Increment location (HL)
2200    0xc9    RET                         ;  Return


; if ( $4E00 == 1 ) { $4E04 = 0x09; }
; else display_erase("PLAYER ONE") by way of 2213 by way of write_msg();
2201    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
2204    0x3d    DEC A                       ;  Decrement Accumulator
2205    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
2207    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
2209    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
2212    0xc9    RET                         ;  Return
2213    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x11, 0x00
; display_erase("PLAYER ONE") by way of write_msg();
2215    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1c, 0x83
2219    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x00
2222    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x05, 0x00
2225    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x10, 0x00
2228    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1A, 0x00
2231    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
2235    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x06, 0x00
; $5003 = $4E72 & $4E09;  // ScreenFlip = Cocktail & CurrentPlayer;
; jump(2196);
2239    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
2242    0x47    LD B, A                     ;  Load register B with Accumulator
2243    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
2246    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
2247    0x32    LD (NN), A      0350        ;  Load location 0x0350 (20483) with the Accumulator
2250    0xc3    JP NN           9408        ;  Jump to 0x9408 (2196)


; if ( $5000 & 0x10 ) {  jump(2270);  }  // $5000.4 == RackTest
; $4E04 = 0x0E;
; rst_28(0x13, 0x00);
2253    0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
2256    0xcb    BIT 4,A                     ;  Test bit 4 of Accumulator
2258    0xc2    JP NZ, NN       de08        ;  Jump to 0xde08 (2270) if ZERO flag is 0
2261    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2264    0x36    LD (HL), N      0e          ;  Load register pair HL with 0x0e (14)
2266    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x13, 0x00
2269    0xc9    RET                         ;  Return


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
2270    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
;; 2272-2279 : On Ms. Pac-Man patched in from $81D8-$81DF
;; On Ms. Pac-Man:
;; 2273  $08e1   0xc3    JP nn           a194        ;  Jump to $nn
;; 2276  $08e4   0x00    NOP                         ;  NOP
2273    0xfe    CP N            f4          ;  Compare 0xf4 (244) with Accumulator
2275    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
2277    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2280    0x36    LD (HL), N      0c          ;  Load location HL with 0x0c (12)
2282    0xc9    RET                         ;  Return
2283    0xcd    CALL NN         1710        ;  Call to 0x1710 (4119)
2286    0xcd    CALL NN         1710        ;  Call to 0x1710 (4119)
2289    0xcd    CALL NN         dd13        ;  Call to 0xdd13 (5085)
2292    0xcd    CALL NN         420c        ;  Call to 0x420c (3138)
2295    0xcd    CALL NN         230e        ;  Call to 0x230e (3619)
2298    0xcd    CALL NN         360e        ;  Call to 0x360e (3638)
2301    0xcd    CALL NN         c30a        ;  Call to 0xc30a (2755)
2304    0xcd    CALL NN         d60b        ;  Call to 0xd60b (3030)
2307    0xcd    CALL NN         0d0c        ;  Call to 0x0d0c (3085)
2310    0xcd    CALL NN         6c0e        ;  Call to 0x6c0e (3692)
2313    0xcd    CALL NN         ad0e        ;  Call to 0xad0e (3757)
2316    0xc9    RET                         ;  Return


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
2317    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
2319    0x32    LD (NN), A      124e        ;  Load location 0x124e (19986) with the Accumulator
2322    0xcd    CALL NN         8724        ;  Call to 0x8724 (9351)
2325    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2328    0x34    INC (HL)                    ;  Increment location (HL)
2329    0x3a    LD A, (NN)      144e        ;  Load Accumulator with location 0x144e (19988)
2332    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2333    0x20    JR NZ, N        1f          ;  Jump relative 0x1f (31) if ZERO flag is 0
2335    0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
2338    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2339    0x28    JR Z, N         19          ;  Jump relative 0x19 (25) if ZERO flag is 1
2341    0x3a    LD A, (NN)      424e        ;  Load Accumulator with location 0x424e (20034)
2344    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2345    0x28    JR Z, N         13          ;  Jump relative 0x13 (19) if ZERO flag is 1
2347    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
2350    0xc6    ADD A, N        03          ;  Add 0x03 (3) to Accumulator (no carry)
2352    0x4f    LD c, A                     ;  Load register C with Accumulator
2353    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
2355    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
2358    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x05
2361    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
2365    0xc9    RET                         ;  Return
2366    0x34    INC (HL)                    ;  Increment location (HL)
2367    0xc9    RET                         ;  Return


;;; Not the cleanest code I've seen
; if ( $4E70 == 0 && $4E14 != 0 ) {  $4E04 = 0x09;  return;  }
; if ( $4E70 != 0 && $4E42 != 0 ) {  swap_player_state();  }
; if ( $4E70 != 0 && $4E42 == 0 && $4E14 != 0 ) {  $4E04 = 0x09;  return;  }
; display_credits_info();  // via call_11169();
; display("GAME OVER") by way of write_msg();
; rst_30(0x54, 0x00, 0x00);
; $HL++;
; return;
2368    0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
2371    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2372    0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
2374    0x3a    LD A, (NN)      424e        ;  Load Accumulator with location 0x424e (20034)
2377    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2378    0x20    JR NZ, N        15          ;  Jump relative 0x15 (21) if ZERO flag is 0
2380    0x3a    LD A, (NN)      144e        ;  Load Accumulator with location 0x144e (19988)
2383    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2384    0x20    JR NZ, N        1a          ;  Jump relative 0x1a (26) if ZERO flag is 0
2386    0xcd    CALL NN         a12b        ;  Call to 0xa12b (11169)
2389    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x05
2392    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
2396    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2399    0x34    INC (HL)                    ;  Increment location (HL)
2400    0xc9    RET                         ;  Return


;;; swap_player_state()?
; $4E09 ^= 0x01;  // current player
; $4E04 = 0x09;
2401    0xcd    CALL NN         a60a        ;  Call to 0xa60a (2726)  //  swap($4E0A..$4E37,$4E38..$4E65)
2404    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
2407    0xee    XOR N           01          ;  Bitwise XOR of 0x01 (1) to Accumulator
2409    0x32    LD (NN), A      094e        ;  Load location 0x094e (19977) with the Accumulator
2412    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
2414    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
2417    0xc9    RET                         ;  Return


;;; clear_a_bunch_of_state_info()?
;  $4E02 = $4E04 = $4E70 = $4E09 = $5003 = 0x00;
;  $4E00 = 0x01;
2418    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
2419    0x32    LD (NN), A      024e        ;  Load location 0x024e (19970) with the Accumulator
2422    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
2425    0x32    LD (NN), A      704e        ;  Load location 0x704e (20080) with the Accumulator
2428    0x32    LD (NN), A      094e        ;  Load location 0x094e (19977) with the Accumulator
2431    0x32    LD (NN), A      0350        ;  Load location 0x0350 (20483) with the Accumulator
2434    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
2436    0x32    LD (NN), A      004e        ;  Load location 0x004e (19968) with the Accumulator
2439    0xc9    RET                         ;  Return


2440    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01
2443    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x01, 0x01
2446    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x02, 0x00
2449    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x11, 0x00
2452    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x13, 0x00
2455    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x03, 0x00
2458    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x00
2461    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x05, 0x00
2464    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x10, 0x00
2467    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1A, 0x00
; display("READY!") by way of write_msg();
2470    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
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
2473    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
2476    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
2478    0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
; display("GAME OVER") by way of write_msg();
2480    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x05
2483    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1D, 0x00
2486    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
2490    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
2493    0x3d    DEC A                       ;  Decrement Accumulator
2494    0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
2496    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x06, 0x00
2500    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
2503    0x47    LD B, A                     ;  Load register B with Accumulator
2504    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
2507    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
2508    0x32    LD (NN), A      0350        ;  Load location 0x0350 (20483) with the Accumulator
2511    0xc3    JP NN           9408        ;  Jump to 0x9408 (2196)



; $4E04 = 0x03;  return;
2514    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
2516    0x32    LD (NN), A      044e        ;  Load location 0x044e (19972) with the Accumulator
2519    0xc9    RET                         ;  Return



; rst_30(0x54, 0x00, 0x00);
; $4E04++;
; $4EAC = $4EBC = 0;  // Sound 2 Waveform A, Sound 3 Waveform A
; return;
2520    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x00, 0x00
2524    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2527    0x34    INC (HL)                    ;  Increment location (HL)
2528    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
2529    0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
2532    0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator
2535    0xc9    RET                         ;  Return


; insert_msg(0x01, 0x02);  
; rst_30(0x42, 0x00, 0x00);
; HL = 0x0000;
; call_9854();  // Clear 0x4D00-0x4D07
; $4E04++;
; return;
2536    0x0e    LD  C, N        02          ;  Load register C with 0x02 (2)
2538    0x06    LD  B, N        01          ;  Load register B with 0x01 (1)
2540    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
2543    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x42, 0x00, 0x00
2547    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
2550    0xcd    CALL NN         7e26        ;  Call to 0x7e26 (9854)
2553    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2556    0x34    INC (HL)                    ;  Increment location (HL)
2557    0xc9    RET                         ;  Return

; C = 0;
2558    0x0e    LD  C, N        00          ;  Load register C with 0x00 (0)
; jump_2538();  // insert_msg(0x01, 0x00) ... etc.
2560    0x18    JR N            e8          ;  Jump relative 0xe8 (-24)
; jump_2536();  // insert_msg(0x01, 0x02) ... etc.
2562    0x18    JR N            e4          ;  Jump relative 0xe4 (-28)
; jump_2558();  // insert_msg(0x01, 0x00) ... etc.
2564    0x18    JR N            f8          ;  Jump relative 0xf8 (-8)
; jump_2536();  // insert_msg(0x01, 0x02) ... etc.
2566    0x18    JR N            e0          ;  Jump relative 0xe0 (-32)
; jump_2558();  // insert_msg(0x01, 0x00) ... etc.
2568    0x18    JR N            f4          ;  Jump relative 0xf4 (-12)
; jump_2536();  // insert_msg(0x01, 0x02) ... etc.
2570    0x18    JR N            dc          ;  Jump relative 0xdc (-36)
; jump_2558();  // insert_msg(0x01, 0x00) ... etc.
2572    0x18    JR N            f0          ;  Jump relative 0xf0 (-16)



2574    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x00, 0x01
2577    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x06, 0x00
2580    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x11, 0x00
2583    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x13, 0x00
2586    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x04, 0x01
2589    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x05, 0x01
2592    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x10, 013
2595    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x43, 0x00, 0x00
; $4E04++;
; return;
2599    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2602    0x34    INC (HL)                    ;  Increment location (HL)
2603    0xc9    RET                         ;  Return


;;; post_board_jump();
; $4EAC = $4EBC = 0;  // Sound 2 Waveform A, Sound 3 Waveform A
; $4ECC = $4EDC = 2;  // Sound 1 Waveform Selector, Sound 2 Waveform Selector, 2 == Intermission Music
; if ( $4E13 > 20 ) {  A = 20;  }  // $4E13 ==  current board?
;              else {  A = $4E13;  }
; rst_20();
2604    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
2605    0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
;; 2608-2615 : On Ms. Pac-Man patched in from $8118-$811F
2608    0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator
;; On Ms. Pac-Man:
;; 2611  $0a33   0x18    JR d            06          ;  Jump d
2611    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
2613    0x32    LD (NN), A      cc4e        ;  Load location 0xcc4e (20172) with the Accumulator
2616    0x32    LD (NN), A      dc4e        ;  Load location 0xdc4e (20188) with the Accumulator
2619    0x3a    LD A, (NN)      134e        ;  Load Accumulator with location 0x134e (19987)
2622    0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
2624    0x38    JR C, N         02          ;  Jump to 0x02 (2) if CARRY flag is 1
2626    0x3e    LD A,N          14          ;  Load Accumulator with 0x14 (20)
2628    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
2671    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2674    0x34    INC (HL)                    ;  Increment location (HL)
2675    0x34    INC (HL)                    ;  Increment location (HL)
2676    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
2677    0x32    LD (NN), A      cc4e        ;  Load location 0xcc4e (20172) with the Accumulator
2680    0x32    LD (NN), A      dc4e        ;  Load location 0xdc4e (20188) with the Accumulator
2683    0xc9    RET                         ;  Return


; $4ECC = $4EDC = 0;  // Sound 1 Waveform Selector, Sound 2 Waveform Selector, 0 == Gameplay
; fill(0x00, $4E0C, 0x07);  // via rst_8();  // $4E0C..$4E12 = 0x00;
; call_9417();  //  $4E16..$4E33 = 0xFF;  $4D34..$4D37 = 0x14
; $4E04++;
; $4E13++;
; if ( $4E0A == 0x14 ) {  return;  }
; $4E0A++;
; return;
2684    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
2685    0x32    LD (NN), A      cc4e        ;  Load location 0xcc4e (20172) with the Accumulator
2688    0x32    LD (NN), A      dc4e        ;  Load location 0xdc4e (20188) with the Accumulator
2691    0x06    LD  B, N        07          ;  Load register B with 0x07 (7)
2693    0x21    LD HL, NN       0c4e        ;  Load register pair HL with 0x0c4e (19980)
2696    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
2697    0xcd    CALL NN         c924        ;  Call to 0xc924 (9417)
2700    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
2703    0x34    INC (HL)                    ;  Increment location (HL)
2704    0x21    LD HL, NN       134e        ;  Load register pair HL with 0x134e (19987)
2707    0x34    INC (HL)                    ;  Increment location (HL)
2708    0x2a    LD HL, (NN)     0a4e        ;  Load register pair HL with location 0x0a4e (19978)
2711    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
2712    0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
2714    0xc8    RET Z                       ;  Return if ZERO flag is 1
2715    0x23    INC HL                      ;  Increment register pair HL
2716    0x22    LD (NN), HL     0a4e        ;  Load location 0x0a4e (19978) with the register pair HL
2719    0xc9    RET                         ;  Return


2720    0xc3    JP NN           8809        ;  Jump to 0x8809 (2440)
2723    0xc3    JP NN           d209        ;  Jump to 0xd209 (2514)


;;; swap_player_state();
; swap($4E0A..$4E37,$4E38..$4E65)
2726    0x06    LD  B, N        2e          ;  Load register B with 0x2e (46)
2728    0xdd    LD IX, NN       0a4e        ;  Load register pair IX with 0x0a4e (19978)
2732    0xfd    LD IY, NN       384e        ;  Load register pair IY with 0x384e (20024)
2736    0xdd    LD D, (IX + N)  00          ;  Load register D with location ( IX + 0x00 () )
2739    0xfd    LD E, (IY + N)  00          ;  Load register E with location ( IY + 0x00 () )
2742    0xfd    LD (IY+d), D    00          ;  Load location ( IY + 0x00 () ) with register D
2745    0xdd    LD (IX+d), E    00          ;  Load location ( IX + 0x00 () ) with register E
2748    0xdd    INC IX                      ;  Increment register pair IX
2750    0xfd    INC IY                      ;  Increment register pair IY
2752    0x10    DJNZ N          ee          ;  Decrement B and jump relative 0xee (-18) if B!=0
2754    0xc9    RET                         ;  Return


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
2755    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
2758    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2759    0xc0    RET NZ                      ;  Return if ZERO flag is 0
2760    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
2764    0xfd    LD IY, NN       c84d        ;  Load register pair IY with 0xc84d (19912)
2768    0x11    LD  DE, NN      0001        ;  Load register pair DE with 0x0001 (0)
2771    0xfd    CP A, (IY+d)    00          ;  Compare location ( IY + 0x00 () ) with Accumulator
2774    0xc2    JP NZ, NN       d20b        ;  Jump to 0xd20b (3026) if ZERO flag is 0
2777    0xfd    LOAD (IY + N),  0e          ;  Load location ( IY + 0x00 () ) with 0x0e ()
2781    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
2784    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2785    0x28    JR Z, N         1b          ;  Jump relative 0x1b (27) if ZERO flag is 1
2787    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
2790    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2791    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
2793    0x30    JR NC, N        13          ;  Jump relative 0x13 (19) if CARRY flag is 0
2795    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
2798    0xcb    SET 7,(HL)                  ;  Set bit 7 of location (HL)
2800    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
2802    0xdd    CP A, (IX+d)    0b          ;  Compare location ( IX + 0x0b () ) with Accumulator
2805    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
2807    0xcb    RES 7,(HL)                  ;  Reset bit 7 of location (HL)
2809    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
2811    0x32    LD (NN), A      0b4c        ;  Load location 0x0b4c (19467) with the Accumulator

; if ( $4DA7 != 0 )  // $4DA7 == Red Edible
; {
;     if ( $4DCB == 0 ) // $4DCB is evaluated here as 16-bit location via loading into HL
;     {
;         if ( $4C03 == 17 ) {  $4C03 = 18;  } else {  $4C03 = 17;  }
;     }
;     jump(2867);
; }
; if ( $4C03 != 1 ) {  $4C03 = 1;  } else {  $4C03 = 1;  } // WTF?!?!?
2814    0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
2817    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2818    0x28    JR Z, N         1d          ;  Jump relative 0x1d (29) if ZERO flag is 1
2820    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
2823    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2824    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
2826    0x30    JR NC, N        27          ;  Jump relative 0x27 (39) if CARRY flag is 0
2828    0x3e    LD A,N          11          ;  Load Accumulator with 0x11 (17)
2830    0xdd    CP A, (IX+d)    03          ;  Compare location ( IX + 0x03 () ) with Accumulator
2833    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
2835    0xdd    LOAD (IX + N),              ;  Load location ( IX + 0x03 () ) with 0x11 ()
2839    0xc3    JP NN           330b        ;  Jump to 0x330b (2867)
2842    0xdd    LOAD (IX + N),              ;  Load location ( IX + 0x03 () ) with 0x12 ()
2846    0xc3    JP NN           330b        ;  Jump to 0x330b (2867)
2849    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
2851    0xdd    CP A, (IX+d)    03          ;  Compare location ( IX + 0x03 () ) with Accumulator
2854    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
2856    0xdd    LOAD (IX + N),              ;  Load location ( IX + 0x03 () ) with 0x01 ()
2860    0xc3    JP NN           330b        ;  Jump to 0x330b (2867)
2863    0xdd    LOAD (IX + N),              ;  Load location ( IX + 0x03 () ) with 0x01 ()

; if ( $4DA8 != 0 )  // $4DA8 = Pink Edible
; {
;     if ( $4DCB == 0 ) // $4DCB is evaluated here as 16-bit location via loading into HL
;     {
;         if ( $4C05 == 17 ) {  $4C05 = 18;  } else {  $4C05 = 17;  }
;     }
;     jump(2920);
; }
; if ( $4C05 != 3 ) {  $4C05 = 3;  } else {  $4C05 = 3;  } // WTF?!?!?
2867    0x3a    LD A, (NN)      a84d        ;  Load Accumulator with location 0xa84d (19880)
2870    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2871    0x28    JR Z, N         1d          ;  Jump relative 0x1d (29) if ZERO flag is 1
2873    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
2876    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2877    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
2879    0x30    JR NC, N        27          ;  Jump relative 0x27 (39) if CARRY flag is 0
2881    0x3e    LD A,N          11          ;  Load Accumulator with 0x11 (17)
2883    0xdd    CP A, (IX+d)    05          ;  Compare location ( IX + 0x05 () ) with Accumulator
2886    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
2888    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x11 ()
2892    0xc3    JP NN           680b        ;  Jump to 0x680b (2920)
2895    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x12 ()
2899    0xc3    JP NN           680b        ;  Jump to 0x680b (2920)
2902    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
2904    0xdd    CP A, (IX+d)    05          ;  Compare location ( IX + 0x05 () ) with Accumulator
2907    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
2909    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x03 ()
2913    0xc3    JP NN           680b        ;  Jump to 0x680b (2920)
2916    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x03 ()

; if ( $4DA9 != 0 )  // $4DA9 = Blue Edible
; {
;     if ( $4DCB == 0 ) // $4DCB is evaluated here as 16-bit location via loading into HL
;     {
;         if ( $4C07 == 17 ) {  $4C07 = 18;  } else {  $4C07 = 17;  }
;     }
;     jump(2969);
; }
; if ( $4C07 != 5 ) {  $4C07 = 5;  } else {  $4C07 = 5;  } // WTF?!?!?
2920    0x3a    LD A, (NN)      a94d        ;  Load Accumulator with location 0xa94d (19881)
2923    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2924    0x28    JR Z, N         1d          ;  Jump relative 0x1d (29) if ZERO flag is 1
2926    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
2929    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2930    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
2932    0x30    JR NC, N        27          ;  Jump relative 0x27 (39) if CARRY flag is 0
2934    0x3e    LD A,N          11          ;  Load Accumulator with 0x11 (17)
2936    0xdd    CP A, (IX+d)    07          ;  Compare location ( IX + 0x07 () ) with Accumulator
2939    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
2941    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x11 ()
2945    0xc3    JP NN           9d0b        ;  Jump to 0x9d0b (2973)
2948    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x12 ()
2952    0xc3    JP NN           9d0b        ;  Jump to 0x9d0b (2973)
2955    0x3e    LD A,N          05          ;  Load Accumulator with 0x05 (5)
2957    0xdd    CP A, (IX+d)    07          ;  Compare location ( IX + 0x07 () ) with Accumulator
2960    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
2962    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x05 ()
2966    0xc3    JP NN           9d0b        ;  Jump to 0x9d0b (2973)
2969    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x05 ()

; if ( $4DAA != 0 )  // $4DAA = Orange Edible
; {
;     if ( $4DCB == 0 ) // $4DCB is evaluated here as 16-bit location via loading into HL
;     {
;         if ( $4C09 == 17 ) {  $4C09 = 18;  } else {  $4C09 = 17;  }
;     }
;     jump(3026);
; }
; if ( $4C09 != 7 ) {  $4C07 = 7;  } else {  $4C07 = 7;  } // WTF?!?!?
2973    0x3a    LD A, (NN)      aa4d        ;  Load Accumulator with location 0xaa4d (19882)
2976    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2977    0x28    JR Z, N         1d          ;  Jump relative 0x1d (29) if ZERO flag is 1
2979    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
2982    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
2983    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
2985    0x30    JR NC, N        27          ;  Jump relative 0x27 (39) if CARRY flag is 0
2987    0x3e    LD A,N          11          ;  Load Accumulator with 0x11 (17)
2989    0xdd    CP A, (IX+d)    09          ;  Compare location ( IX + 0x09 () ) with Accumulator
2992    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
2994    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x11 ()
2998    0xc3    JP NN           d20b        ;  Jump to 0xd20b (3026)
3001    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x12 ()
3005    0xc3    JP NN           d20b        ;  Jump to 0xd20b (3026)
3008    0x3e    LD A,N          07          ;  Load Accumulator with 0x07 (7)
3010    0xdd    CP A, (IX+d)    09          ;  Compare location ( IX + 0x09 () ) with Accumulator
3013    0x28    JR Z, N         07          ;  Jump relative 0x07 (7) if ZERO flag is 1
3015    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x07 ()
3019    0xc3    JP NN           d20b        ;  Jump to 0xd20b (3026)
3022    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x07 ()

;; 3024-3031 : On Ms. Pac-Man patched in from $80D8-$80DF

; $4DC8--;  return;
3026    0xfd    DEC (IY + N)    00          ;  Decrement location IY + 0x00 ()
3029    0xc9    RET                         ;  Return


; B = 0x25;
; if ( $4E02 == 0x22 ) {  B = 0;  }
; if ( $4DAC != 0 ) {  $4C03 = B;  }
; if ( $4DAD != 0 ) {  $4C05 = B;  }
; if ( $4DAE != 0 ) {  $4C07 = B;  }
; if ( $4DAF != 0 ) {  $4C09 = B;  }
; return;
3030    0x06    LD  B, N        19          ;  Load register B with 0x19 (25)
3032    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
3035    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
3037    0xc2    JP NZ, NN       e20b        ;  Jump to 0xe20b (3042) if ZERO flag is 0
3040    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
3042    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
3046    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
3049    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3050    0xca    JP Z,           f00b        ;  Jump to 0xf00b (3056) if ZERO flag is 1
3053    0xdd    LD (IX+d), B    03          ;  Load location ( IX + 0x03 () ) with register B
3056    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
3059    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3060    0xca    JP Z,           fa0b        ;  Jump to 0xfa0b (3066) if ZERO flag is 1
3063    0xdd    LD (IX+d), B    05          ;  Load location ( IX + 0x05 () ) with register B
3066    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
3069    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3070    0xca    JP Z,           040c        ;  Jump to 0x040c (3076) if ZERO flag is 1
3073    0xdd    LD (IX+d), B    07          ;  Load location ( IX + 0x07 () ) with register B
3076    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
3079    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3080    0xc8    RET Z                       ;  Return if ZERO flag is 1
3081    0xdd    LD (IX+d), B    09          ;  Load location ( IX + 0x09 () ) with register B
3084    0xc9    RET                         ;  Return


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
3085    0x21    LD HL, NN       cf4d        ;  Load register pair HL with 0xcf4d (19919)
3088    0x34    INC (HL)                    ;  Increment location (HL)
3089    0x3e    LD A,N          0a          ;  Load Accumulator with 0x0a (10)
3091    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
3092    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3093    0x36    LD (HL), N      00          ;  Load register pair HL with 0x00 (0)
3095    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
3098    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
3100    0x20    JR NZ, N        15          ;  Jump relative 0x15 (21) if ZERO flag is 0
3102    0x21    LD HL, NN       6444        ;  Load register pair HL with 0x6444 (17508)
;; 3104-3111 : On Ms. Pac-Man patched in from $8120-$8127
;; On Ms. Pac-Man:
;; 3105  $0c21   0xc3    JP nn           2495        ;  Jump to $nn
3105    0x3e    LD A,N          10          ;  Load Accumulator with 0x10 (16)
3107    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
3108    0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
3110    0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
3112    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
3113    0x32    LD (NN), A      7844        ;  Load location 0x7844 (17528) with the Accumulator
3116    0x32    LD (NN), A      8447        ;  Load location 0x8447 (18308) with the Accumulator
3119    0x32    LD (NN), A      9847        ;  Load location 0x9847 (18328) with the Accumulator
3122    0xc9    RET                         ;  Return
3123    0x21    LD HL, NN       3247        ;  Load register pair HL with 0x3247 (18226)
3126    0x3e    LD A,N          10          ;  Load Accumulator with 0x10 (16)
3128    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
3129    0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
3131    0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
3133    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
3134    0x32    LD (NN), A      7846        ;  Load location 0x7846 (18040) with the Accumulator
3137    0xc9    RET                         ;  Return


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
3138    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
3141    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3142    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3143    0x3a    LD A, (NN)      944d        ;  Load Accumulator with location 0x944d (19860)
3146    0x07    RLCA                        ;  Rotate left circular Accumulator
3147    0x32    LD (NN), A      944d        ;  Load location 0x944d (19860) with the Accumulator
3150    0xd0    RET NC                      ;  Return if CARRY flag is 0
3151    0x3a    LD A, (NN)      a04d        ;  Load Accumulator with location 0xa04d (19872)
3154    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3155    0xc2    JP NZ, NN       900c        ;  Jump to 0x900c (3216) if ZERO flag is 0
3158    0xdd    LD IX, NN       0533        ;  Load register pair IX with 0x0533 (13061)
3162    0xfd    LD IY, NN       004d        ;  Load register pair IY with 0x004d (19712)
; HL = (IY) + (IX);
3166    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
3169    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
3172    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
3174    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
3177    0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
3180    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
3183    0xfe    CP N            64          ;  Compare 0x64 (100) with Accumulator
3185    0xc2    JP NZ, NN       900c        ;  Jump to 0x900c (3216) if ZERO flag is 0
3188    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
3191    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
3194    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
3197    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
3200    0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
3203    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
3205    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
3208    0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
3211    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
3213    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator

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
3216    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
3219    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
3221    0xca    JP Z,           fb0c        ;  Jump to 0xfb0c (3323) if ZERO flag is 1
3224    0xfe    CP N            00          ;  Compare 0x00 (0) with Accumulator
3226    0xc2    JP NZ, NN       c10c        ;  Jump to 0xc10c (3265) if ZERO flag is 0
3229    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
3232    0xfe    CP N            78          ;  Compare 0x78 (120) with Accumulator
3234    0xcc    CALL Z,NN       2e1f        ;  Call to 0x2e1f (7982) if ZERO flag is 1
3237    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
3239    0xcc    CALL Z,NN       2e1f        ;  Call to 0x2e1f (7982) if ZERO flag is 1
3242    0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
3245    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
3248    0xdd    LD IX, NN       204d        ;  Load register pair IX with 0x204d (19744)
3252    0xfd    LD IY, NN       024d        ;  Load register pair IY with 0x024d (19714)
; HL = (IY) + (IX);
3256    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
3259    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
3262    0xc3    JP NN           fb0c        ;  Jump to 0xfb0c (3323)
3265    0xdd    LD IX, NN       0533        ;  Load register pair IX with 0x0533 (13061)
3269    0xfd    LD IY, NN       024d        ;  Load register pair IY with 0x024d (19714)
; HL = (IY) + (IX);
3273    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
3276    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
3279    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
3281    0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
3284    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
3287    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
3290    0xfe    CP N            64          ;  Compare 0x64 (100) with Accumulator
3292    0xc2    JP NZ, NN       fb0c        ;  Jump to 0xfb0c (3323) if ZERO flag is 0
3295    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
3298    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
3301    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
3304    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
3307    0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
3310    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
3312    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
3315    0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
3318    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
3320    0x32    LD (NN), A      a14d        ;  Load location 0xa14d (19873) with the Accumulator

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
3323    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
3326    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
3328    0xca    JP Z,           930d        ;  Jump to 0x930d (3475) if ZERO flag is 1
3331    0xfe    CP N            00          ;  Compare 0x00 (0) with Accumulator
3333    0xc2    JP NZ, NN       2c0d        ;  Jump to 0x2c0d (3372) if ZERO flag is 0
3336    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
3339    0xfe    CP N            78          ;  Compare 0x78 (120) with Accumulator
3341    0xcc    CALL Z,NN       551f        ;  Call to 0x551f (8021) if ZERO flag is 1
3344    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
3346    0xcc    CALL Z,NN       551f        ;  Call to 0x551f (8021) if ZERO flag is 1
3349    0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
3352    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
3355    0xdd    LD IX, NN       224d        ;  Load register pair IX with 0x224d (19746)
3359    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
; HL = (IY) + (IX);
3363    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
3366    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
3369    0xc3    JP NN           930d        ;  Jump to 0x930d (3475)
3372    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
3375    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
3377    0xc2    JP NZ, NN       590d        ;  Jump to 0x590d (3417) if ZERO flag is 0
3380    0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
3384    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
; HL = (IY) + (IX);
3388    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
3391    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
3394    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
3395    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
3398    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
3401    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
3404    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
3406    0xc2    JP NZ, NN       930d        ;  Jump to 0x930d (3475) if ZERO flag is 0
3409    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
3411    0x32    LD (NN), A      a24d        ;  Load location 0xa24d (19874) with the Accumulator
3414    0xc3    JP NN           930d        ;  Jump to 0x930d (3475)
3417    0xdd    LD IX, NN       0533        ;  Load register pair IX with 0x0533 (13061)
3421    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
; HL = (IY) + (IX);
3425    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
3428    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
3431    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
3433    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
3436    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
3439    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
3442    0xfe    CP N            64          ;  Compare 0x64 (100) with Accumulator
3444    0xc2    JP NZ, NN       930d        ;  Jump to 0x930d (3475) if ZERO flag is 0
3447    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
3450    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
3453    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
3456    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
3459    0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
3462    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
3464    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
3467    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
3470    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
3472    0x32    LD (NN), A      a24d        ;  Load location 0xa24d (19874) with the Accumulator


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
3475    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
3478    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
3480    0xc8    RET Z                       ;  Return if ZERO flag is 1
3481    0xfe    CP N            00          ;  Compare 0x00 (0) with Accumulator
3483    0xc2    JP NZ, NN       c00d        ;  Jump to 0xc00d (3520) if ZERO flag is 0
3486    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
3489    0xfe    CP N            78          ;  Compare 0x78 (120) with Accumulator
3491    0xcc    CALL Z,NN       7c1f        ;  Call to 0x7c1f (8060) if ZERO flag is 1
3494    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
3496    0xcc    CALL Z,NN       7c1f        ;  Call to 0x7c1f (8060) if ZERO flag is 1
3499    0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
3502    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
3505    0xdd    LD IX, NN       244d        ;  Load register pair IX with 0x244d (19748)
3509    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
; HL = (IY) + (IX);
3513    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
3516    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
3519    0xc9    RET                         ;  Return
3520    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
3523    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
3525    0xc2    JP NZ, NN       ea0d        ;  Jump to 0xea0d (3562) if ZERO flag is 0
3528    0xdd    LD IX, NN       0333        ;  Load register pair IX with 0x0333 (13059)
3532    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
; HL = (IY) + (IX);
3536    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
3539    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
3542    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
3544    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
3547    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
3550    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
3553    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
3555    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3556    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
3558    0x32    LD (NN), A      a34d        ;  Load location 0xa34d (19875) with the Accumulator
3561    0xc9    RET                         ;  Return
3562    0xdd    LD IX, NN       0533        ;  Load register pair IX with 0x0533 (13061)
3566    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
; HL = (IY) + (IX);
3570    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
3573    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
3576    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
3578    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
3581    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
3584    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
3587    0xfe    CP N            64          ;  Compare 0x64 (100) with Accumulator
3589    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3590    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
3593    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
3596    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
3599    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
3602    0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
3605    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
3607    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
3610    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
3613    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
3615    0x32    LD (NN), A      a34d        ;  Load location 0xa34d (19875) with the Accumulator
3618    0xc9    RET                         ;  Return


; if ( ++$4DC4 != 8 ) {  return;  }
; $4DC4 = 0;
; $4DC0 ^= 0x01;
; return;
3619    0x21    LD HL, NN       c44d        ;  Load register pair HL with 0xc44d (19908)
3622    0x34    INC (HL)                    ;  Increment location (HL)
3623    0x3e    LD A,N          08          ;  Load Accumulator with 0x08 (8)
3625    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
3626    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3627    0x36    LD (HL), N      00          ;  Load register pair HL with 0x00 (0)
3629    0x3a    LD A, (NN)      c04d        ;  Load Accumulator with location 0xc04d (19904)
3632    0xee    XOR N           01          ;  Bitwise XOR of 0x01 (1) to Accumulator
3634    0x32    LD (NN), A      c04d        ;  Load location 0xc04d (19904) with the Accumulator
3637    0xc9    RET                         ;  Return



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
3638    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
3641    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3642    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3643    0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
3646    0xfe    CP N            07          ;  Compare 0x07 (7) with Accumulator
3648    0xc8    RET Z                       ;  Return if ZERO flag is 1
3649    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
3650    0x2a    LD HL, (NN)     c24d        ;  Load register pair HL with location 0xc24d (19906)
3653    0x23    INC HL                      ;  Increment register pair HL
3654    0x22    LD (NN), HL     c24d        ;  Load location 0xc24d (19906) with the register pair HL
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
3657    0x5f    LD E, A                     ;  Load register E with Accumulator
3658    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
3660    0xdd    LD IX, NN       864d        ;  Load register pair IX with 0x864d (19846)
3664    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
3666    0xdd    LD E, (IX + N)  00          ;  Load register E with location ( IX + 0x00 () )
3669    0xdd    LD D, (IX + N)  01          ;  Load register D with location ( IX + 0x01 () )
;; 3672-3679 : On Ms. Pac-Man patched in from $8168-$816F
3672    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
3673    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
3675    0xc0    RET NZ                      ;  Return if ZERO flag is 0
;; On Ms. Pac-Man:
;; 3676  $0e5c   0xaf    XOR A, A                    ;  XOR of register A to register A
;; 3677  $0e5d   0x00    NOP                         ;  NOP
3676    0xcb    SRL A                       ;  Shift Accumulator right logical
3678    0x3c    INC A                       ;  Increment Accumulator
3679    0x32    LD (NN), A      c14d        ;  Load location 0xc14d (19905) with the Accumulator
3682    0x21    LD HL, NN       0101        ;  Load register pair HL with 0x0101 (257)
3685    0x22    LD (NN), HL     b14d        ;  Load location 0xb14d (19889) with the register pair HL
3688    0x22    LD (NN), HL     b34d        ;  Load location 0xb34d (19891) with the register pair HL
3691    0xc9    RET                         ;  Return


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
3692    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
3695    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
3696    0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
3698    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
3699    0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
3702    0xc9    RET                         ;  Return
; if ( $4E0E == 0xE4 ) {  A = $4EAC & 0xE0;  $4EAC = A | 0x10;  return; }
3703    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
3706    0x06    LD  B, N        e0          ;  Load register B with 0xe0 (224)
3708    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
3711    0xfe    CP N            e4          ;  Compare 0xe4 (228) with Accumulator
3713    0x38    JR C, N         06          ;  Jump to 0x06 (6) if CARRY flag is 1
3715    0x78    LD A, B                     ;  Load Accumulator with register B
3716    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
3717    0xcb    SET 4,A                     ;  Set bit 4 of Accumulator
3719    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
3720    0xc9    RET                         ;  Return
; if ( $4E0E == 0xD4 ) {  A = $4EAC & 0xE0;  $4EAC = A | 0x08;  return; }
3721    0xfe    CP N            d4          ;  Compare 0xd4 (212) with Accumulator
3723    0x38    JR C, N         06          ;  Jump to 0x06 (6) if CARRY flag is 1
3725    0x78    LD A, B                     ;  Load Accumulator with register B
3726    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
3727    0xcb    SET 4,A                     ;  Set bit 3 of Accumulator
3729    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
3730    0xc9    RET                         ;  Return
; if ( $4E0E == 0xB4 ) {  A = $4EAC & 0xE0;  $4EAC = A | 0x04;  return; }
3731    0xfe    CP N            b4          ;  Compare 0xb4 (180) with Accumulator
3733    0x38    JR C, N         06          ;  Jump to 0x06 (6) if CARRY flag is 1
3735    0x78    LD A, B                     ;  Load Accumulator with register B
3736    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
3737    0xcb    SET 4,A                     ;  Set bit 2 of Accumulator
3739    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
3740    0xc9    RET                         ;  Return
; if ( $4E0E == 0x74 ) {  A = $4EAC & 0xE0;  $4EAC = A | 0x02;  return; }
3741    0xfe    CP N            74          ;  Compare 0x74 (116) with Accumulator
3743    0x38    JR C, N         06          ;  Jump to 0x06 (6) if CARRY flag is 1
3745    0x78    LD A, B                     ;  Load Accumulator with register B
3746    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
3747    0xcb    SET 4,A                     ;  Set bit 1 of Accumulator
3749    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
3750    0xc9    RET                         ;  Return
; A = $4EAC & 0xE0;  $($4EAC) = A | 0x01;  return;
3751    0x78    LD A, B                     ;  Load Accumulator with register B
;; 3752-3759 : On Ms. Pac-Man patched in from $8198-$819F
3752    0xa6    AND A, (HL)                 ;  Bitwise AND of location (HL) to Accumulator
;; On Ms. Pac-Man:
;; 3753  $0ea9   0xcbc7  SET 0, A                    ;  Set bit 0 of register A
3753    0xcb    SET 4,A                     ;  Set bit 0 of Accumulator
3755    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
3756    0xc9    RET                         ;  Return


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
3757    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
3760    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3761    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3762    0x3a    LD A, (NN)      d44d        ;  Load Accumulator with location 0xd44d (19924)
3765    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3766    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3767    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
3770    0xfe    CP N            46          ;  Compare 0x46 (70) with Accumulator
3772    0x28    JR Z, N         0e          ;  Jump relative 0x0e (14) if ZERO flag is 1
3774    0xfe    CP N            aa          ;  Compare 0xaa (170) with Accumulator
3776    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3777    0x3a    LD A, (NN)      0d4e        ;  Load Accumulator with location 0x0d4e (19981)
3780    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3781    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3782    0x21    LD HL, NN       0d4e        ;  Load register pair HL with 0x0d4e (19981)
3785    0x34    INC (HL)                    ;  Increment location (HL)
3786    0x18    JR N            09          ;  Jump relative 0x09 (9)
3788    0x3a    LD A, (NN)      0c4e        ;  Load Accumulator with location 0x0c4e (19980)
3791    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
3792    0xc0    RET NZ                      ;  Return if ZERO flag is 0
3793    0x21    LD HL, NN       0c4e        ;  Load register pair HL with 0x0c4e (19980)
3796    0x34    INC (HL)                    ;  Increment location (HL)
3797    0x21    LD HL, NN       9480        ;  Load register pair HL with 0x9480 (32916)
3800    0x22    LD (NN), HL     d24d        ;  Load location 0xd24d (19922) with the register pair HL
3803    0x21    LD HL, NN       fd0e        ;  Load register pair HL with 0xfd0e (3837)
3806    0x3a    LD A, (NN)      134e        ;  Load Accumulator with location 0x134e (19987)
3809    0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
3811    0x38    JR C, N         02          ;  Jump to 0x02 (2) if CARRY flag is 1
3813    0x3e    LD A,N          14          ;  Load Accumulator with 0x14 (20)
3815    0x47    LD B, A                     ;  Load register B with Accumulator
3816    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
3817    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
3818    0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
3819    0x32    LD (NN), A      0c4c        ;  Load location 0x0c4c (19468) with the Accumulator
3822    0x23    INC HL                      ;  Increment register pair HL
3823    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
3824    0x32    LD (NN), A      0d4c        ;  Load location 0x0d4c (19469) with the Accumulator
3827    0x23    INC HL                      ;  Increment register pair HL
3828    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
3829    0x32    LD (NN), A      d44d        ;  Load location 0xd44d (19924) with the Accumulator
3832    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x8A, 0x04, 0x00
3836    0xc9    RET                         ;  Return


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
4096    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
4097    0x32    LD (NN), A      d44d        ;  Load location 0xd44d (19924) with the Accumulator
; Clear $4DD2/3 (fruit_YX)
4100    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
4103    0x22    LD (NN), HL     d24d        ;  Load location 0xd24d (19922) with the register pair HL
4106    0xc9    RET                         ;  Return


; display_erase("100" (stylized)) by way of write_msg();
4107    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0x9B
; if ( $4E00 != 1 ) {  display_erase("MEMORY  OK") by way of write_msg();  }
;; On Ms. Pac-Man:
;; 4110  $100e   0x3a    LD A, (nn)      00c3        ;  Load Accumulator with memory $nn
4110    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
4113    0x3d    DEC A                       ;  Decrement Accumulator
4114    0xc8    RET Z                       ;  Return if ZERO flag is 1
4115    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x1C, 0xA2
4118    0xc9    RET                         ;  Return



4119    0xcd    CALL NN         9112        ;  Call to 0x9112 (4753)
; if ( $4DA5 != 0 ) {  return;  }
4122    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
4125    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4126    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4127    0xcd    CALL NN         6610        ;  Call to 0x6610 (4198)
4130    0xcd    CALL NN         9410        ;  Call to 0x9410 (4244)
4133    0xcd    CALL NN         9e10        ;  Call to 0x9e10 (4254)
4136    0xcd    CALL NN         a810        ;  Call to 0xa810 (4264)
4139    0xcd    CALL NN         b410        ;  Call to 0xb410 (4276)
; if ( $4DA4 != 0 ) {  call_4661();  return;  }
4142    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
4145    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4146    0xca    JP Z,           3910        ;  Jump to 0x3910 (4153) if ZERO flag is 1
4149    0xcd    CALL NN         3512        ;  Call to 0x3512 (4661)
4152    0xc9    RET                         ;  Return
4153    0xcd    CALL NN         1d17        ;  Call to 0x1d17 (5917)
4156    0xcd    CALL NN         8917        ;  Call to 0x8917 (6025)
; if ( $4DA4 != 0 ) {  return;  }
4159    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
4162    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4163    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4164    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
4167    0xcd    CALL NN         361b        ;  Call to 0x361b (6966)
4170    0xcd    CALL NN         4b1c        ;  Call to 0x4b1c (7243)
4173    0xcd    CALL NN         221d        ;  Call to 0x221d (7458)
4176    0xcd    CALL NN         f91d        ;  Call to 0xf91d (7673)
; if ( $4E04 != 3 ) {  return;  } // $4E04 = GameFrame ( 3 == 'Running Game' )
4179    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
4182    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
4184    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4185    0xcd    CALL NN         7613        ;  Call to 0x7613 (4982)
4188    0xcd    CALL NN         6920        ;  Call to 0x6920 (8297)
4191    0xcd    CALL NN         8c20        ;  Call to 0x8c20 (8332)
4194    0xcd    CALL NN         af20        ;  Call to 0xaf20 (8367)
4197    0xc9    RET                         ;  Return


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
4198    0x3a    LD A, (NN)      ab4d        ;  Load Accumulator with location 0xab4d (19883)
4201    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4202    0xc8    RET Z                       ;  Return if ZERO flag is 1
4203    0x3d    DEC A                       ;  Decrement Accumulator
4204    0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
4206    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
4209    0x3c    INC A                       ;  Increment Accumulator
4210    0x32    LD (NN), A      ac4d        ;  Load location 0xac4d (19884) with the Accumulator
4213    0xc9    RET                         ;  Return
4214    0x3d    DEC A                       ;  Decrement Accumulator
4215    0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
4217    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
4220    0x3c    INC A                       ;  Increment Accumulator
4221    0x32    LD (NN), A      ad4d        ;  Load location 0xad4d (19885) with the Accumulator
4224    0xc9    RET                         ;  Return
4225    0x3d    DEC A                       ;  Decrement Accumulator
4226    0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
4228    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
4231    0x3c    INC A                       ;  Increment Accumulator
4232    0x32    LD (NN), A      ae4d        ;  Load location 0xae4d (19886) with the Accumulator
4235    0xc9    RET                         ;  Return
4236    0x32    LD (NN), A      af4d        ;  Load location 0xaf4d (19887) with the Accumulator
4239    0x3d    DEC A                       ;  Decrement Accumulator
4240    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
4243    0xc9    RET                         ;  Return


; // $4DAC - Red chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
4244    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
4247    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $000C : return;
; 1 : $10C0 : 4288
; 2 : $10D2 : 4306

; // $4DAD - Pink chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
4254    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
4257    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $000C : return;
; 1 : $1118 : 4376
; 2 : $112A : 4394

; // $4DAE - Blue chomp status ( 0=chase/flee, 1=run back to base, 2=enter base, 3=?)
4264    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
4267    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $000C : return;
; 1 : $115C : 4444
; 2 : $116E : 4462
; 3 : $118F : 4495

; // $4DAF - Orange chomp status ( 0=chase/flee, 1=run back to base, 2=enter base, 3=?)
4276    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
4279    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $000C : return;
; 1 : $11C9 : 4553
; 2 : $11DB : 4571
; 3 : $11FC : 4604


; call_7128();
; if ( carry_flag ) {  return;  }
; if ( $4D00 == 100 ) {  $4DAC++;  }  //  $4DAC = Red chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
4288    0xcd    CALL NN         d81b        ;  Call to 0xd81b (7128)
4289    0xd8    RET C                       ;  Return if CARRY flag is 1
4290    0x1b    DEC DE                      ;  Decrement register pair DE
4291    0x2a    LD HL, (NN)     004d        ;  Load register pair HL with location 0x004d (19712)
4294    0x11    LD  DE, NN      6480        ;  Load register pair DE with 0x6480 (100)
4297    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4298    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
4300    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4301    0x21    LD HL, NN       ac4d        ;  Load register pair HL with 0xac4d (19884)
4304    0x34    INC (HL)                    ;  Increment location (HL)
4305    0xc9    RET                         ;  Return


; $4D00 += $3301;  // $4D00++;
; $4D28 = $4D2C = 1;  //  $4D28 - Red Ghost Direction Iterator??, $4D2C - Red Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D00 != 128 ) {  return;  }
; $4D0A = $4D31 = 0x2E2F;  //  $4D0A/B - Red Y/X
; $4DA0 = $4DAC = $4DA7 = 0;  //  $4DAC - Red chomp status ( 0=chase/flee, 1=run back to base, 2=enter base), $4DA7 - Red edible
; if ( $4DAC | $4DAD | $4DAE | $4DAF == 0 )  //  $4DAC/D/E/F - R/P/B/O chomp status ( 0=chase/flee, 1=run back to base, 2=enter base)
; {  $4EAC &= 0xBF;  }  //  $4EAC - maze completion status
; return;
4306    0xdd    LD IX, NN       0133        ;  Load register pair IX with 0x0133 (13057)
4310    0xfd    LD IY, NN       004d        ;  Load register pair IY with 0x004d (19712)  
4314    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
4317    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
4320    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
4322    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
4325    0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
4328    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
4331    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
4333    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4334    0x21    LD HL, NN       2f2e        ;  Load register pair HL with 0x2f2e (11823)
4337    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
4340    0x22    LD (NN), HL     314d        ;  Load location 0x314d (19761) with the register pair HL
4343    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
4344    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
4347    0x32    LD (NN), A      ac4d        ;  Load location 0xac4d (19884) with the Accumulator
4350    0x32    LD (NN), A      a74d        ;  Load location 0xa74d (19879) with the Accumulator
4353    0xdd    LD IX, NN       ac4d        ;  Load register pair IX with 0xac4d (19884)
4357    0xdd    OR A, (IX+d)   00           ;  Bitwise OR location ( IX + 0x00 () ) with Accumulator
4360    0xdd    OR A, (IX+d)   01           ;  Bitwise OR location ( IX + 0x01 () ) with Accumulator
4363    0xdd    OR A, (IX+d)   02           ;  Bitwise OR location ( IX + 0x02 () ) with Accumulator
4366    0xdd    OR A, (IX+d)   03           ;  Bitwise OR location ( IX + 0x03 () ) with Accumulator
4369    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4370    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
4373    0xcb    RES 6,(HL)                  ;  Reset bit 6 of location (HL)
4375    0xc9    RET                         ;  Return


; call_7343();
; if ( $4D02 == 100 ) {  $4DAD++;  }  //  $4DAD = Pink chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
4376    0xcd    CALL NN         af1c        ;  Call to 0xaf1c (7343)
4379    0x2a    LD HL, (NN)     024d        ;  Load register pair HL with location 0x024d (19714)
4382    0x11    LD  DE, NN      6480        ;  Load register pair DE with 0x6480 (100)
4385    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4386    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
4388    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4389    0x21    LD HL, NN       ad4d        ;  Load register pair HL with 0xad4d (19885)
4392    0x34    INC (HL)                    ;  Increment location (HL)
4393    0xc9    RET                         ;  Return


; $4D02 += $3301;  // $4D02++;
; $4D29 = $4D2D = 1;  //  $4D29 - Pink Ghost Direction Iterator??, $4D2D - Pink Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D00 != 128 ) {  return;  }
; $4D0C = $4D33 = 0x2E2F;  //  $4D0C/D - Pink Y/X
; $4DA1 = $4DAD = $4DA8 = 0;  //  $4DAD - Pink chomp status ( 0=chase/flee, 1=run back to base, 2=enter base), $4DA8 - Pink edible
; jump_4353();
4394    0xdd    LD IX, NN       0133        ;  Load register pair IX with 0x0133 (13057)
4398    0xfd    LD IY, NN       024d        ;  Load register pair IY with 0x024d (19714)
4402    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
4405    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
4408    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
4410    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
4413    0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
4416    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
4419    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
4421    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4422    0x21    LD HL, NN       2f2e        ;  Load register pair HL with 0x2f2e (11823)
4425    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
4428    0x22    LD (NN), HL     334d        ;  Load location 0x334d (19763) with the register pair HL
4431    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
4432    0x32    LD (NN), A      a14d        ;  Load location 0xa14d (19873) with the Accumulator
4435    0x32    LD (NN), A      ad4d        ;  Load location 0xad4d (19885) with the Accumulator
4438    0x32    LD (NN), A      a84d        ;  Load location 0xa84d (19880) with the Accumulator
4441    0xc3    JP NN           0111        ;  Jump to 0x0111 (4353)


; call_7558();
; if ( $4D04 == 100 ) {  $4DAE++;  }  //  $4DAE = Blue chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
4444    0xcd    CALL NN         861d        ;  Call to 0x861d (7558)
4447    0x2a    LD HL, (NN)     044d        ;  Load register pair HL with location 0x044d (19716)
4450    0x11    LD  DE, NN      6480        ;  Load register pair DE with 0x6480 (100)
4453    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4454    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
4456    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4457    0x21    LD HL, NN       ae4d        ;  Load register pair HL with 0xae4d (19886)
4460    0x34    INC (HL)                    ;  Increment location (HL)
4461    0xc9    RET                         ;  Return


; $4D04 += $3301;  // $4D04++;
; $4D2A = $4D2E = 1;  //  $4D2A - Blue Ghost Direction Iterator??, $4D2E - Blue Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D04 == 128 ) {  $4DAE++;  }  //  $4DAE = Blue chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
4462    0xdd    LD IX, NN       0133        ;  Load register pair IX with 0x0133 (13057)
4466    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
4470    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
4473    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
4476    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
4478    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
4481    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
4484    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
4487    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
4489    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4490    0x21    LD HL, NN       ae4d        ;  Load register pair HL with 0xae4d (19886)
4493    0x34    INC (HL)                    ;  Increment location (HL)
4494    0xc9    RET                         ;  Return


; $4D04 += $3301;  // $4D04++;
; $4D2A = $4D2E = 2;  //  $4D2A - Blue Ghost Direction Iterator??, $4D2E - Blue Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D05 != 144 ) {  return;  }
; $4D0E = $4D35 = 0x2F30;  //  $4D0E/F = Blue Y/X
; $4D2A = $4D2E = 1;  //  $4D2A - Blue Ghost Direction Iterator??, $4D2E - Blue Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; $4DA2 = $4DAE = $4DA9 = 0;  //  $4DAE - Blue chomp status ( 0=chase/flee, 1=run back to base, 2=enter base), $4DA9 - Blue edible
; jump_4353();
4495    0xdd    LD IX, NN       0333        ;  Load register pair IX with 0x0333 (13059)
4499    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
4503    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
4506    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
4509    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
4511    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
4514    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
4517    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
4520    0xfe    CP N            90          ;  Compare 0x90 (144) with Accumulator
4522    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4523    0x21    LD HL, NN       2f30        ;  Load register pair HL with 0x2f30 (12335)
4526    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
4529    0x22    LD (NN), HL     354d        ;  Load location 0x354d (19765) with the register pair HL
4532    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
4534    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
4537    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
4540    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
4541    0x32    LD (NN), A      a24d        ;  Load location 0xa24d (19874) with the Accumulator
4544    0x32    LD (NN), A      ae4d        ;  Load location 0xae4d (19886) with the Accumulator
4547    0x32    LD (NN), A      a94d        ;  Load location 0xa94d (19881) with the Accumulator
4550    0xc3    JP NN           0111        ;  Jump to 0x0111 (4353)


; call_7773();
; if ( $4D06 == 100 ) {  $4DAF++;  }  //  $4DAF = Orange chomp status - 0=chase/flee, 1=run back to base, 2=enter base)
; return;
4553    0xcd    CALL NN         5d1e        ;  Call to 0x5d1e (7773)
4556    0x2a    LD HL, (NN)     064d        ;  Load register pair HL with location 0x064d (19718)
4559    0x11    LD  DE, NN      6480        ;  Load register pair DE with 0x6480 (100)
4562    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4563    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
4565    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4566    0x21    LD HL, NN       af4d        ;  Load register pair HL with 0xaf4d (19887)
4569    0x34    INC (HL)                    ;  Increment location (HL)
4570    0xc9    RET                         ;  Return


; $4D06 += $3301;  // $4D04++;
; $4D2B = $4D2F = 1;  //  $4D2B - Orange Ghost Direction Iterator??, $4D2F - Orange Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D06 == 128 ) {  $4D2F++  }
; return;
4571    0xdd    LD IX, NN       0133        ;  Load register pair IX with 0x0133 (13057)
4575    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
4579    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
4582    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
4585    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
4587    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
4590    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
4593    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
4596    0xfe    CP N            80          ;  Compare 0x80 (128) with Accumulator
4598    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4599    0x21    LD HL, NN       af4d        ;  Load register pair HL with 0xaf4d (19887)
4602    0x34    INC (HL)                    ;  Increment location (HL)
4603    0xc9    RET                         ;  Return


; $4D06 += $3301;  // $4D06++;
; $4D2B = $4D2F = 0;  //  $4D2B - Orange Ghost Direction Iterator??, $4D2F - Orange Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; if ( $4D07 != 112 ) {  return;  }
; $4D10 = $4D37 = 0x2F2C;  //  $4D10/1 = Ornage Y/X
; $4D2B = $4D2F = 1;  //  $4D2B - Orange Ghost Direction Iterator??, $4D2F - Orange Ghost Direction ( 0=right, 1=down, 2=left, 3=up )
; $4DA3 = $4DAF = $4DAA = 0;  //  $4DAF - Orange chomp status ( 0=chase/flee, 1=run back to base, 2=enter base), $4DAA - Orange edible
; jump_4353();
4604    0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
4608    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
4612    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)  ; HL = (IY) + (IX);
4615    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
4618    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
4619    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
4622    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
4625    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
4628    0xfe    CP N            70          ;  Compare 0x70 (112) with Accumulator
4630    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4631    0x21    LD HL, NN       2f2c        ;  Load register pair HL with 0x2f2c (11311)
4634    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
4637    0x22    LD (NN), HL     374d        ;  Load location 0x374d (19767) with the register pair HL
4640    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
4642    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
4645    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
4648    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
4649    0x32    LD (NN), A      a34d        ;  Load location 0xa34d (19875) with the Accumulator
4652    0x32    LD (NN), A      af4d        ;  Load location 0xaf4d (19887) with the Accumulator
4655    0x32    LD (NN), A      aa4d        ;  Load location 0xaa4d (19882) with the Accumulator
4658    0xc3    JP NN           0111        ;  Jump to 0x0111 (4353)

; A = 4DD1;
; rst_20();
4661    0x3a    LD A, (NN)      d14d        ;  Load Accumulator with location 0xd14d (19921)
4664    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
4671    0x21    LD HL, NN       004c        ;  Load register pair HL with 0x004c (19456)
4674    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
4677    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
4678    0x5f    LD E, A                     ;  Load register E with Accumulator
4679    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
4681    0x19    ADD HL, DE                  ;  Add register pair DE to HL
4682    0x3a    LD A, (NN)      d14d        ;  Load Accumulator with location 0xd14d (19921)
4685    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4686    0x20    JR NZ, N        27          ;  Jump relative 0x27 (39) if ZERO flag is 0
4688    0x3a    LD A, (NN)      d04d        ;  Load Accumulator with location 0xd04d (19920)
4691    0x06    LD  B, N        27          ;  Load register B with 0x27 (39)
4693    0x80    ADD A, B                    ;  Add register B to Accumulator (no carry)
4694    0x47    LD B, A                     ;  Load register B with Accumulator
4695    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
4698    0x4f    LD c, A                     ;  Load register C with Accumulator
4699    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
4702    0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
4703    0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
4705    0xcb    SET 6,B                     ;  Set bit 6 of register B
4707    0xcb    SET 6,B                     ;  Set bit 7 of register B
4709    0x70    LD (HL), B                  ;  Load location (HL) with register B
4710    0x23    INC HL                      ;  Increment register pair HL
4711    0x36    LD (HL), N      18          ;  Load register pair HL with 0x18 (24)
4713    0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
4715    0x32    LD (NN), A      0b4c        ;  Load location 0x0b4c (19467) with the Accumulator
4718    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4A, 0x03, 0x00
4722    0x21    LD HL, NN       d14d        ;  Load register pair HL with 0xd14d (19921)
4725    0x34    INC (HL)                    ;  Increment location (HL)
4726    0xc9    RET                         ;  Return
4727    0x36    LD (HL), N      20          ;  Load register pair HL with 0x20 (32)
4729    0x3e    LD A,N          09          ;  Load Accumulator with 0x09 (9)
4731    0x32    LD (NN), A      0b4c        ;  Load location 0x0b4c (19467) with the Accumulator
4734    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
4737    0x32    LD (NN), A      ab4d        ;  Load location 0xab4d (19883) with the Accumulator
4740    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
4741    0x32    LD (NN), A      a44d        ;  Load location 0xa44d (19876) with the Accumulator
;; 4744-4751 : On Ms. Pac-Man patched in from $8098-$809F
4744    0x32    LD (NN), A      d14d        ;  Load location 0xd14d (19921) with the Accumulator
4747    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
4750    0xcb    SET 6,(HL)                  ;  Set bit 6 of location (HL)
4752    0xc9    RET                         ;  Return


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

4753    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
4756    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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


4791    0x2a    LD HL, (NN)     c54d        ;  Load register pair HL with location 0xc54d (19909)
4794    0x23    INC HL                      ;  Increment register pair HL
4795    0x22    LD (NN), HL     c54d        ;  Load location 0xc54d (19909) with the register pair HL
4798    0x11    LD  DE, NN      7800        ;  Load register pair DE with 0x7800 (120)
4801    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
4802    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
4804    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4805    0x3e    LD A,N          05          ;  Load Accumulator with 0x05 (5)
4807    0x32    LD (NN), A      a54d        ;  Load location 0xa54d (19877) with the Accumulator
4810    0xc9    RET                         ;  Return

4811    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
4814    0xcd    CALL NN         7e26        ;  Call to 0x7e26 (9854)
4817    0x3e    LD A,N          34          ;  Load Accumulator with 0x34 (52)
4819    0x11    LD  DE, NN      b400        ;  Load register pair DE with 0xb400 (180)

;; used by a number of entry points in nearby....
4822    0x4f    LD c, A                     ;  Load register C with Accumulator
4823    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
4826    0x47    LD B, A                     ;  Load register B with Accumulator
4827    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
4830    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
4831    0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
4833    0x3e    LD A,N          c0          ;  Load Accumulator with 0xc0 (192)
4835    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
4836    0x4f    LD c, A                     ;  Load register C with Accumulator
4837    0x79    LD A, C                     ;  Load Accumulator with register C
4838    0x32    LD (NN), A      0a4c        ;  Load location 0x0a4c (19466) with the Accumulator
4841    0x2a    LD HL, (NN)     c54d        ;  Load register pair HL with location 0xc54d (19909)
4844    0x23    INC HL                      ;  Increment register pair HL
4845    0x22    LD (NN), HL     c54d        ;  Load location 0xc54d (19909) with the register pair HL
4848    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4849    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
4851    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4852    0x21    LD HL, NN       a54d        ;  Load register pair HL with 0xa54d (19877)
4855    0x34    INC (HL)                    ;  Increment location (HL)
4856    0xc9    RET                         ;  Return

4857    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
4860    0xcb    SET 4,(HL)                  ;  Set bit 4 of location (HL)
4862    0x3e    LD A,N          35          ;  Load Accumulator with 0x35 (53)
4864    0x11    LD  DE, NN      c300        ;  Load register pair DE with 0xc300 (195)
4867    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4870    0x3e    LD A,N          36          ;  Load Accumulator with 0x36 (54)
4872    0x11    LD  DE, NN      d200        ;  Load register pair DE with 0xd200 (210)
4875    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4878    0x3e    LD A,N          37          ;  Load Accumulator with 0x37 (55)
4880    0x11    LD  DE, NN      e100        ;  Load register pair DE with 0xe100 (225)
4883    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4886    0x3e    LD A,N          38          ;  Load Accumulator with 0x38 (56)
4888    0x11    LD  DE, NN      f000        ;  Load register pair DE with 0xf000 (240)
4891    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4894    0x3e    LD A,N          39          ;  Load Accumulator with 0x39 (57)
4896    0x11    LD  DE, NN      ff00        ;  Load register pair DE with 0xff00 (255)
4899    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4902    0x3e    LD A,N          3a          ;  Load Accumulator with 0x3a (58)
4904    0x11    LD  DE, NN      0e01        ;  Load register pair DE with 0x0e01 (14)
4907    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4910    0x3e    LD A,N          3b          ;  Load Accumulator with 0x3b (59)
4912    0x11    LD  DE, NN      1d01        ;  Load register pair DE with 0x1d01 (29)
4915    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4918    0x3e    LD A,N          3c          ;  Load Accumulator with 0x3c (60)
4920    0x11    LD  DE, NN      2c01        ;  Load register pair DE with 0x2c01 (44)
4923    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4926    0x3e    LD A,N          3d          ;  Load Accumulator with 0x3d (61)
4928    0x11    LD  DE, NN      3b01        ;  Load register pair DE with 0x3b01 (59)
4931    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4934    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
;; 4936-4943 : On Ms. Pac-Man patched in from $8048-$804F
;; On Ms. Pac-Man:
;; 4937  $1349   0x36    LD (HL), n      00          ;  Load memory $HL with n
4937    0x36    LD (HL), N      20          ;  Load register pair HL with 0x20 (32)
4939    0x3e    LD A,N          3e          ;  Load Accumulator with 0x3e (62)
4941    0x11    LD  DE, NN      5901        ;  Load register pair DE with 0x5901 (89)
4944    0xc3    JP NN           d612        ;  Jump to 0xd612 (4822)

4947    0x3e    LD A,N          3f          ;  Load Accumulator with 0x3f (63)
4949    0x32    LD (NN), A      0a4c        ;  Load location 0x0a4c (19466) with the Accumulator
4952    0x2a    LD HL, (NN)     c54d        ;  Load register pair HL with location 0xc54d (19909)
4955    0x23    INC HL                      ;  Increment register pair HL
4956    0x22    LD (NN), HL     c54d        ;  Load location 0xc54d (19909) with the register pair HL
4959    0x11    LD  DE, NN      b801        ;  Load register pair DE with 0xb801 (184)
4962    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4963    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
4965    0xc0    RET NZ                      ;  Return if ZERO flag is 0
4966    0x21    LD HL, NN       144e        ;  Load register pair HL with 0x144e (19988)
4969    0x35    DEC (HL)                    ;  Decrement location (HL)
4970    0x21    LD HL, NN       154e        ;  Load register pair HL with 0x154e (19989)
4973    0x35    DEC (HL)                    ;  Decrement location (HL)
4974    0xcd    CALL NN         7526        ;  Call to 0x7526 (9845)
4977    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
4980    0x34    INC (HL)                    ;  Increment location (HL)
4981    0xc9    RET                         ;  Return


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
4982    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
4985    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
4986    0xc8    RET Z                       ;  Return if ZERO flag is 1
4987    0xdd    LD IX, NN       a74d        ;  Load register pair IX with 0xa74d (19879)
4991    0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
4994    0xdd    XOR A, (IX+d)   01          ;  Bitwise XOR location ( IX + 0x01 () ) with Accumulator
4997    0xdd    XOR A, (IX+d)   02          ;  Bitwise XOR location ( IX + 0x02 () ) with Accumulator
5000    0xdd    XOR A, (IX+d)   03          ;  Bitwise XOR location ( IX + 0x03 () ) with Accumulator
5003    0xca    JP Z,           9813        ;  Jump to 0x9813 (5016) if ZERO flag is 1
5006    0x2a    LD HL, (NN)     cb4d        ;  Load register pair HL with location 0xcb4d (19915)
5009    0x2b    DEC HL                      ;  Decrement register pair HL
5010    0x22    LD (NN), HL     cb4d        ;  Load location 0xcb4d (19915) with the register pair HL
5013    0x7c    LD A, H                     ;  Load Accumulator with register H
5014    0xb5    OR A, L                     ;  Bitwise OR of register L to Accumulator
5015    0xc0    RET NZ                      ;  Return if ZERO flag is 0
5016    0x21    LD HL, NN       0b4c        ;  Load register pair HL with 0x0b4c (19467)
5019    0x36    LD (HL), N      09          ;  Load register pair HL with 0x09 (9)
5021    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
5024    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5025    0xc2    JP NZ, NN       a713        ;  Jump to 0xa713 (5031) if ZERO flag is 0
5028    0x32    LD (NN), A      a74d        ;  Load location 0xa74d (19879) with the Accumulator
5031    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
5034    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5035    0xc2    JP NZ, NN       b113        ;  Jump to 0xb113 (5041) if ZERO flag is 0
5038    0x32    LD (NN), A      a84d        ;  Load location 0xa84d (19880) with the Accumulator
5041    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
5044    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5045    0xc2    JP NZ, NN       bb13        ;  Jump to 0xbb13 (5051) if ZERO flag is 0
5048    0x32    LD (NN), A      a94d        ;  Load location 0xa94d (19881) with the Accumulator
5051    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
5054    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5055    0xc2    JP NZ, NN       c513        ;  Jump to 0xc513 (5061) if ZERO flag is 0
5058    0x32    LD (NN), A      aa4d        ;  Load location 0xaa4d (19882) with the Accumulator
5061    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
5062    0x32    LD (NN), A      cb4d        ;  Load location 0xcb4d (19915) with the Accumulator
5065    0x32    LD (NN), A      cc4d        ;  Load location 0xcc4d (19916) with the Accumulator
5068    0x32    LD (NN), A      a64d        ;  Load location 0xa64d (19878) with the Accumulator
5071    0x32    LD (NN), A      c84d        ;  Load location 0xc84d (19912) with the Accumulator
5074    0x32    LD (NN), A      d04d        ;  Load location 0xd04d (19920) with the Accumulator
5077    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
5080    0xcb    RES 5,(HL)                  ;  Reset bit 5 of location (HL)
5082    0xcb    RES 7,(HL)                  ;  Reset bit 7 of location (HL)
5084    0xc9    RET                         ;  Return


; if ( $4D9E != A=$4E0E ) {  $4D97 = 0x0000;  return;  }
5085    0x21    LD HL, NN       9e4d        ;  Load register pair HL with 0x9e4d (19870)
5088    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
5091    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
5092    0xca    JP Z,           ee13        ;  Jump to 0xee13 (5102) if ZERO flag is 1
5095    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
5098    0x22    LD (NN), HL     974d        ;  Load location 0x974d (19863) with the register pair HL
5101    0xc9    RET                         ;  Return


; $4D97++;
; if ( $4D97 - $4D95 != 0 ) {  return;  }
; $4D97 = 0x00;
; if ( $4DA1 == 0 ) {  $4DA1 = 2; /*via 8326*/  return;  }
; if ( $4DA2 == 0 ) {  $4DA2 = 3; /*via 8361*/  return;  }
; if ( $4DA3 == 0 ) {  $4DA3 = 3; /*via 8401*/  return;  }
; return;
5102    0x2a    LD HL, (NN)     974d        ;  Load register pair HL with location 0x974d (19863)
5105    0x23    INC HL                      ;  Increment register pair HL
5106    0x22    LD (NN), HL     974d        ;  Load location 0x974d (19863) with the register pair HL
5109    0xed    LD DE, (NN)     954d        ;  Load register pair DE with location 0x954d (19861)
5113    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5114    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
5116    0xc0    RET NZ                      ;  Return if ZERO flag is 0
5117    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
5120    0x22    LD (NN), HL     974d        ;  Load location 0x974d (19863) with the register pair HL
5123    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
5126    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5127    0xf5    PUSH AF                     ;  Load the stack with register pair AF
5128    0xcc    CALL Z,NN       8620        ;  Call to 0x8620 (8326) if ZERO flag is 1
5131    0xf1    POP AF                      ;  Load register pair AF with top of stack
5132    0xc8    RET Z                       ;  Return if ZERO flag is 1
5133    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
5136    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5137    0xf5    PUSH AF                     ;  Load the stack with register pair AF
5138    0xcc    CALL Z,NN       a920        ;  Call to 0xa920 (8361) if ZERO flag is 1
5141    0xf1    POP AF                      ;  Load register pair AF with top of stack
5142    0xc8    RET Z                       ;  Return if ZERO flag is 1
5143    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
5146    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5147    0xcc    CALL Z,NN       d120        ;  Call to 0xd120 (8401) if ZERO flag is 1
5150    0xc9    RET                         ;  Return


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
5151    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
5154    0x47    LD B, A                     ;  Load register B with Accumulator
5155    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
5158    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
5159    0xc8    RET Z                       ;  Return if ZERO flag is 1
5160    0x47    LD B, A                     ;  Load register B with Accumulator
5161    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
5165    0x1e    LD E,N          08          ;  Load register E with 0x08 (8)
5167    0x0e    LD  C, N        08          ;  Load register C with 0x08 (8)
5169    0x16    LD  D, N        07          ;  Load register D with 0x07 (7)
5171    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
5174    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5175    0xdd    LD (IX+d), A    13          ;  Load location ( IX + 0x13 () ) with Accumulator
5178    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
5181    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5182    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
5183    0xdd    LD (IX+d), A    12          ;  Load location ( IX + 0x12 () ) with Accumulator
5186    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
5189    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5190    0xdd    LD (IX+d), A    15          ;  Load location ( IX + 0x15 () ) with Accumulator
5193    0x3a    LD A, (NN)      034d        ;  Load Accumulator with location 0x034d (19715)
5196    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5197    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
5198    0xdd    LD (IX+d), A    14          ;  Load location ( IX + 0x14 () ) with Accumulator
5201    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
5204    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5205    0xdd    LD (IX+d), A    17          ;  Load location ( IX + 0x17 () ) with Accumulator
5208    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
5211    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5212    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5213    0xdd    LD (IX+d), A    16          ;  Load location ( IX + 0x16 () ) with Accumulator
5216    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
5219    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5220    0xdd    LD (IX+d), A    19          ;  Load location ( IX + 0x19 () ) with Accumulator
5223    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
5226    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5227    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5228    0xdd    LD (IX+d), A    18          ;  Load location ( IX + 0x18 () ) with Accumulator
5231    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
5234    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5235    0xdd    LD (IX+d), A    1b          ;  Load location ( IX + 0x1b () ) with Accumulator
5238    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
5241    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5242    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5243    0xdd    LD (IX+d), A    1a          ;  Load location ( IX + 0x1a () ) with Accumulator
5246    0x3a    LD A, (NN)      d24d        ;  Load Accumulator with location 0xd24d (19922)
5249    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5250    0xdd    LD (IX+d), A    1d          ;  Load location ( IX + 0x1d () ) with Accumulator
5253    0x3a    LD A, (NN)      d34d        ;  Load Accumulator with location 0xd34d (19923)
5256    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5257    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5258    0xdd    LD (IX+d), A    1c          ;  Load location ( IX + 0x1c () ) with Accumulator
5261    0xc3    JP NN           fe14        ;  Jump to 0xfe14 (5374)


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
5264    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
5267    0x47    LD B, A                     ;  Load register B with Accumulator
5268    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
5271    0xa0    AND A, B                    ;  Bitwise AND of register B to Accumulator
5272    0xc0    RET NZ                      ;  Return if ZERO flag is 0
5273    0x47    LD B, A                     ;  Load register B with Accumulator
5274    0x1e    LD E,N          09          ;  Load register E with 0x09 (9)
5276    0x0e    LD  C, N        07          ;  Load register C with 0x07 (7)
5278    0x16    LD  D, N        06          ;  Load register D with 0x06 (6)
5280    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
5284    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
5287    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5288    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5289    0xdd    LD (IX+d), A    13          ;  Load location ( IX + 0x13 () ) with Accumulator
5292    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
5295    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
5296    0xdd    LD (IX+d), A    12          ;  Load location ( IX + 0x12 () ) with Accumulator
5299    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
5302    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5303    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5304    0xdd    LD (IX+d), A    15          ;  Load location ( IX + 0x15 () ) with Accumulator
5307    0x3a    LD A, (NN)      034d        ;  Load Accumulator with location 0x034d (19715)
5310    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
5311    0xdd    LD (IX+d), A    14          ;  Load location ( IX + 0x14 () ) with Accumulator
5314    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
5317    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5318    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5319    0xdd    LD (IX+d), A    17          ;  Load location ( IX + 0x17 () ) with Accumulator
5322    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
5325    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5326    0xdd    LD (IX+d), A    16          ;  Load location ( IX + 0x16 () ) with Accumulator
5329    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
5332    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5333    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5334    0xdd    LD (IX+d), A    19          ;  Load location ( IX + 0x19 () ) with Accumulator
5337    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
5340    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5341    0xdd    LD (IX+d), A    18          ;  Load location ( IX + 0x18 () ) with Accumulator
5344    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
5347    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5348    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5349    0xdd    LD (IX+d), A    1b          ;  Load location ( IX + 0x1b () ) with Accumulator
5352    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
5355    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5356    0xdd    LD (IX+d), A    1a          ;  Load location ( IX + 0x1a () ) with Accumulator
5359    0x3a    LD A, (NN)      d24d        ;  Load Accumulator with location 0xd24d (19922)
5362    0x2f    CPL                         ;  Complement Accumulator (1's complement)
5363    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5364    0xdd    LD (IX+d), A    1d          ;  Load location ( IX + 0x1d () ) with Accumulator
5367    0x3a    LD A, (NN)      d34d        ;  Load Accumulator with location 0xd34d (19923)
5370    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5371    0xdd    LD (IX+d), A    1c          ;  Load location ( IX + 0x1c () ) with Accumulator

; if ( $4DA5 != 0 ) {  jump_5451();  }
; if ( $4DA4 != 0 ) {  jump_5556();  }
; push(5404);
; A = $4D03;  //  $4E03 == Mode:  00 - Attract Screen + Gameplay, 01 - Push Start Button, 03 - Game Start (Ready!)
; rst20();
5374    0x3a    LD A, (NN)      a54d        ;  Load Accumulator with location 0xa54d (19877)
5377    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5378    0xc2    JP NZ, NN       4b15        ;  Jump to 0x4b15 (5451) if ZERO flag is 0
5381    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
5384    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5385    0xc2    JP NZ, NN       b415        ;  Jump to 0xb415 (5556) if ZERO flag is 0
5388    0x21    LD HL, NN       1c15        ;  Load register pair HL with 0x1c15 (5404)
5391    0xe5    PUSH HL                     ;  Load the stack with register pair HL
5392    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
5395    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
5404    0x78    LD A, B                     ;  Load Accumulator with register B
5405    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5406    0x28    JR Z, N         2b          ;  Jump relative 0x2b (43) if ZERO flag is 1
5408    0x0e    LD  C, N        c0          ;  Load register C with 0xc0 (192)
5410    0x3a    LD A, (NN)      0a4c        ;  Load Accumulator with location 0x0a4c (19466)
5413    0x57    LD D, A                     ;  Load register D with Accumulator
5414    0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
5415    0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
5417    0x7a    LD A, D                     ;  Load Accumulator with register D
5418    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
5419    0xc3    JP NN           4815        ;  Jump to 0x4815 (5448)
5422    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
5425    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
5427    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5429    0xcb    BIT 7,D                     ;  Test bit 7 of register D
5431    0x28    JR Z, N         12          ;  Jump relative 0x12 (18) if ZERO flag is 1
5433    0x7a    LD A, D                     ;  Load Accumulator with register D
5434    0xa9    XOR A, C                    ;  Bitwise XOR of register C to Accumulator
5435    0xc3    JP NN           4815        ;  Jump to 0x4815 (5448)
5438    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
5440    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5442    0xcb    BIT 6,D                     ;  Test bit 6 of register D
5444    0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
5446    0x7a    LD A, D                     ;  Load Accumulator with register D
5447    0xa9    XOR A, C                    ;  Bitwise XOR of register C to Accumulator
5448    0x32    LD (NN), A      0a4c        ;  Load location 0x0a4c (19466) with the Accumulator
; $4C02 = $4C04 = $4C06 = $4C08 = $4DC0 + 28;
5451    0x21    LD HL, NN       c04d        ;  Load register pair HL with 0xc04d (19904)
5454    0x56    LD D, (HL)                  ;  Load register D with location (HL)
5455    0x3e    LD A,N          1c          ;  Load Accumulator with 0x1c (28)
5457    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
5458    0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
5461    0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
5464    0xdd    LD (IX+d), A    06          ;  Load location ( IX + 0x06 () ) with Accumulator
5467    0xdd    LD (IX+d), A    08          ;  Load location ( IX + 0x08 () ) with Accumulator
; C = 32;
; if ( $4DAC != 0 || $4DA7 == 0 ) {  $4C02 = ( $4D2C * 2 ) + C + D;  }  // D == $4DC0
; if ( $4DAD != 0 || $4DA8 == 0 ) {  $4C04 = ( $4D2D * 2 ) + D + C;  }
; if ( $4DAE != 0 || $4DA9 == 0 ) {  $4C06 = ( $4D2E * 2 ) + D + C;  }
; if ( $4DAF != 0 || $4DAA == 0 ) {  $4C08 = ( $4D2F * 2 ) + D + C;  }
5470    0x0e    LD  C, N        20          ;  Load register C with 0x20 (32)
5472    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
5475    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5476    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
5478    0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
5481    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5482    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5484    0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
5487    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
5488    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
5489    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5490    0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
5493    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
5496    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5497    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
5499    0x3a    LD A, (NN)      a84d        ;  Load Accumulator with location 0xa84d (19880)
5502    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5503    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5505    0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
5508    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
5509    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
5510    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5511    0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
5514    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
5517    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5518    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
5520    0x3a    LD A, (NN)      a94d        ;  Load Accumulator with location 0xa94d (19881)
5523    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5524    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5526    0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
5529    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
5530    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
5531    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5532    0xdd    LD (IX+d), A    06          ;  Load location ( IX + 0x06 () ) with Accumulator
5535    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
5538    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5539    0x20    JR NZ, N        06          ;  Jump relative 0x06 (6) if ZERO flag is 0
5541    0x3a    LD A, (NN)      aa4d        ;  Load Accumulator with location 0xaa4d (19882)
5544    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5545    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5547    0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
5550    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
5551    0x82    ADD A, D                    ;  Add register D to Accumulator (no carry)
5552    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
5553    0xdd    LD (IX+d), A    08          ;  Load location ( IX + 0x08 () ) with Accumulator
; call_5606();
; call_5677();
; call_5714();
5556    0xcd    CALL NN         e615        ;  Call to 0xe615 (5606)
5559    0xcd    CALL NN         2d16        ;  Call to 0x2d16 (5677)
5562    0xcd    CALL NN         5216        ;  Call to 0x5216 (5714)
5565    0x78    LD A, B                     ;  Load Accumulator with register B
5566    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5567    0xc8    RET Z                       ;  Return if ZERO flag is 1
5568    0x0e    LD  C, N        c0          ;  Load register C with 0xc0 (192)
5570    0x3a    LD A, (NN)      024c        ;  Load Accumulator with location 0x024c (19458)
5573    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
5574    0x32    LD (NN), A      024c        ;  Load location 0x024c (19458) with the Accumulator
5577    0x3a    LD A, (NN)      044c        ;  Load Accumulator with location 0x044c (19460)
5580    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
5581    0x32    LD (NN), A      044c        ;  Load location 0x044c (19460) with the Accumulator
5584    0x3a    LD A, (NN)      064c        ;  Load Accumulator with location 0x064c (19462)
5587    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
5588    0x32    LD (NN), A      064c        ;  Load location 0x064c (19462) with the Accumulator
5591    0x3a    LD A, (NN)      084c        ;  Load Accumulator with location 0x084c (19464)
5594    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
5595    0x32    LD (NN), A      084c        ;  Load location 0x084c (19464) with the Accumulator
5598    0x3a    LD A, (NN)      0c4c        ;  Load Accumulator with location 0x0c4c (19468)
5601    0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
5602    0x32    LD (NN), A      0c4c        ;  Load location 0x0c4c (19468) with the Accumulator
5605    0xc9    RET                         ;  Return


;; Act I - $4E07 determines which scene
; if ( $4E06 < 5 ) {  return;  }  // Act I Scenes
5606    0x3a    LD A, (NN)      064e        ;  Load Accumulator with location 0x064e (19974)
5609    0xd6    SUB N           05          ;  Subtract 0x05 (5) from Accumulator (no carry)
5611    0xd8    RET C                       ;  Return if CARRY flag is 1
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
5612    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
5615    0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
5617    0xfe    CP N            0c          ;  Compare 0x0c (12) with Accumulator
5619    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
5621    0x16    LD  D, N        18          ;  Load register D with 0x18 (24)
5623    0x18    JR N            12          ;  Jump relative 0x12 (18)
5625    0xfe    CP N            08          ;  Compare 0x08 (8) with Accumulator
5627    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
5629    0x16    LD  D, N        14          ;  Load register D with 0x14 (20)
5631    0x18    JR N            0a          ;  Jump relative 0x0a (10)
5633    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
5635    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
5637    0x16    LD  D, N        10          ;  Load register D with 0x10 (16)
5639    0x18    JR N            02          ;  Jump relative 0x02 (2)
5641    0x16    LD  D, N        14          ;  Load register D with 0x14 (20)
5643    0xdd    LD (IX+d), D    04          ;  Load location ( IX + 0x04 () ) with register D
5646    0x14    INC D                       ;  Increment register D
5647    0xdd    LD (IX+d), D    06          ;  Load location ( IX + 0x06 () ) with register D
5650    0x14    INC D                       ;  Increment register D
5651    0xdd    LD (IX+d), D    08          ;  Load location ( IX + 0x08 () ) with register D
5654    0x14    INC D                       ;  Increment register D
5655    0xdd    LD (IX+d), D    0c          ;  Load location ( IX + 0x0c () ) with register D
5658    0xdd    LOAD (IX + N),  3f          ;  Load location ( IX + 0x0a () ) with 0x3f ()
5662    0x16    LD  D, N        16          ;  Load register D with 0x16 (22)
5664    0xdd    LD (IX+d), D    05          ;  Load location ( IX + 0x05 () ) with register D
5667    0xdd    LD (IX+d), D    07          ;  Load location ( IX + 0x07 () ) with register D
5670    0xdd    LD (IX+d), D    09          ;  Load location ( IX + 0x09 () ) with register D
5673    0xdd    LD (IX+d), D    0d          ;  Load location ( IX + 0x0d () ) with register D
5676    0xc9    RET                         ;  Return


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
5677    0x3a    LD A, (NN)      074e        ;  Load Accumulator with location 0x074e (19975)
5680    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5681    0xc8    RET Z                       ;  Return if ZERO flag is 1
5682    0x57    LD D, A                     ;  Load register D with Accumulator
5683    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
5686    0xd6    SUB N           3d          ;  Subtract 0x3d (61) from Accumulator (no carry)
5688    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
5690    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0b () ) with 0x00 ()
5694    0x7a    LD A, D                     ;  Load Accumulator with register D
5695    0xfe    CP N            0a          ;  Compare 0x0a (10) with Accumulator
5697    0xd8    RET C                       ;  Return if CARRY flag is 1
5698    0xdd    LOAD (IX + N),  32          ;  Load location ( IX + 0x02 () ) with 0x32 ()
5702    0xdd    LOAD (IX + N),  1d          ;  Load location ( IX + 0x03 () ) with 0x1d ()
5706    0xfe    CP N            0c          ;  Compare 0x0c (12) with Accumulator
5708    0xd8    RET C                       ;  Return if CARRY flag is 1
5709    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x33 ()
5713    0xc9    RET                         ;  Return


;; Act III - $4E08 determines which scene
; if ( $4E08 == 0 ) {  return;  }
; if ( $4D3A != 0x3D ) {  $4C0B == 0x00;  }
; if ( $4E08 < 1 )  {  return;  }  // HUH?  How could this ever evaluate?
; $4C02 = $4DC0 + 8;
; if ( $4E08 < 3 )  {  return;  }
5714    0x3a    LD A, (NN)      084e        ;  Load Accumulator with location 0x084e (19976)
5717    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5718    0xc8    RET Z                       ;  Return if ZERO flag is 1
5719    0x57    LD D, A                     ;  Load register D with Accumulator
5720    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
5723    0xd6    SUB N           3d          ;  Subtract 0x3d (61) from Accumulator (no carry)
5725    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
5727    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0b () ) with 0x00 ()
5731    0x7a    LD A, D                     ;  Load Accumulator with register D
5732    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
5734    0xd8    RET C                       ;  Return if CARRY flag is 1
5735    0x3a    LD A, (NN)      c04d        ;  Load Accumulator with location 0xc04d (19904)
5738    0x1e    LD E,N          08          ;  Load register E with 0x08 (8)
5740    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5741    0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
5744    0x7a    LD A, D                     ;  Load Accumulator with register D
5745    0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
5747    0xd8    RET C                       ;  Return if CARRY flag is 1
; A = $4D01 & 0x08;
; A <<cir 3;
; A += 10;
; $4C0C = A;
; A += 2;
; $4C02 = A;
; $4C0D = 0x1E;
5748    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
5751    0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
5753    0x0f    RRCA                        ;  Rotate right circular Accumulator
5754    0x0f    RRCA                        ;  Rotate right circular Accumulator
5755    0x0f    RRCA                        ;  Rotate right circular Accumulator
5756    0x1e    LD E,N          0a          ;  Load register E with 0x0a (10)
5758    0x83    ADD A, E                    ;  Add register E to Accumulator (no carry)
5759    0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
5762    0x3c    INC A                       ;  Increment Accumulator
5763    0x3c    INC A                       ;  Increment Accumulator
5764    0xdd    LD (IX+d), A    02          ;  Load location ( IX + 0x02 () ) with Accumulator
5767    0xdd    LOAD (IX + N),  1e          ;  Load location ( IX + 0x0d () ) with 0x1e ()
;; 5768-5775 : On Ms. Pac-Man patched in from $8088-$808F
5771    0xc9    RET                         ;  Return


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
5772    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
5775    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
5777    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
5779    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
5781    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x30 ()
5785    0xc9    RET                         ;  Return
5786    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
5788    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
5790    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x2e ()
5794    0xc9    RET                         ;  Return
5795    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
5797    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
5799    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x2c ()
5803    0xc9    RET                         ;  Return
5804    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x2e ()
5808    0xc9    RET                         ;  Return


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
5809    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
5812    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
5814    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
5816    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
5818    0xdd    LD (IX+d), n    0a2f        ;  Load location ( IX + 0x0a () ) with 0x2f ()
5822    0xc9    RET                         ;  Return
5823    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
5825    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
5827    0xdd    LD (IX+d), n    0a2d        ;  Load location ( IX + 0x0a () ) with 0x2d ()
5831    0xc9    RET                         ;  Return
5832    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
5834    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
5836    0xdd    LD (IX+d), n    0a2f        ;  Load location ( IX + 0x0a () ) with 0x2f ()
5840    0xc9    RET                         ;  Return
5841    0xdd    LD (IX+d), n    0a30        ;  Load location ( IX + 0x0a () ) with 0x30 ()
5845    0xc9    RET                         ;  Return


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
5846    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
5849    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
5851    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
5853    0x38    JR C, N         08          ;  Jump to 8 (8) if CARRY flag is 1
5855    0x1e    LD E,N          2e          ;  Load register E with 0x2e (46)
5857    0xcb    SET 7,E                     ;  Set bit 7 of register E
5859    0xdd    LD (IX+d), E    0a          ;  Load location ( IX + 0x0a () ) with register E
5862    0xc9    RET                         ;  Return
5863    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
5865    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
5867    0x1e    LD E,N          2c          ;  Load register E with 0x2c (44)
5869    0x18    JR N            f2          ;  Jump relative 0xf2 (-14)
5871    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
5873    0x30    JR NC, N        ec          ;  Jump relative 0xec (-20) if CARRY flag is 1
5875    0x1e    LD E,N          30          ;  Load register E with 0x30 (48)
5877    0x18    JR N            ea          ;  Jump relative 0xea (-22)


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
5879    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
;; On Ms. Pac-Man:
;; 5882  $16fa   0xc3    JP nn           d986        ;  Jump to $nn
;; 5885  $16fd   0xc9    RET                         ;  Return
5882    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
5884    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
5886    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
5888    0xdd    LOAD (IX + N),  30          ;  Load location ( IX + 0x0a () ) with 0x30 ()
5892    0xc9    RET                         ;  Return
5893    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
5895    0x38    JR C, N         08          ;  Jump to 0x08 (8) if CARRY flag is 1
5897    0x1e    LD E,N          2f          ;  Load register E with 0x2f (47)
5899    0xcb    SET 6,E                     ;  Set bit 6 of register E
5901    0xdd    LD (IX+d), E    0a          ;  Load location ( IX + 0x0a () ) with register E
5904    0xc9    RET                         ;  Return
5905    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
5907    0x38    JR C, N         04          ;  Jump to 0x04 (4) if CARRY flag is 1
5909    0x1e    LD E,N          2d          ;  Load register E with 0x2d (45)
5911    0x18    JR N            f2          ;  Jump relative 0xf2 (-14)
5913    0x1e    LD E,N          2f          ;  Load register E with 0x2f (47)
5915    0x18    JR N            ee          ;  Jump relative 0xee (-18)


;; eat_ghost_test() ??
; B = 4;
; DE = $4D39;
; A = $4DAF;
; if ( $4DAF == 0 ) {  HL = $4D37;  if ( HL -= DE == 0 ) {  jump_5987();  }  }  // WTF?!?
5917    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
5919    0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
5923    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
5926    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5927    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5929    0x2a    LD HL, (NN)     374d        ;  Load register pair HL with location 0x374d (19767)
5932    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5933    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
5935    0xca    JP Z,           6317        ;  Jump to 0x6317 (5987) if ZERO flag is 1
; B--;
; if ( $4DAE == 0 ) {  HL = $4D35;  if ( HL -= DE == 0 ) {  jump_5987();  }  }
5938    0x05    DEC B                       ;  Decrement register B
5939    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
5942    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5943    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5945    0x2a    LD HL, (NN)     354d        ;  Load register pair HL with location 0x354d (19765)
5948    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5949    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
5951    0xca    JP Z,           6317        ;  Jump to 0x6317 (5987) if ZERO flag is 1
; B--;
; if ( $4DAD == 0 ) {  HL = $4D33;  if ( HL -= DE == 0 ) {  jump_5987();  }  }
5954    0x05    DEC B                       ;  Decrement register B
5955    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
5958    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5959    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5961    0x2a    LD HL, (NN)     334d        ;  Load register pair HL with location 0x334d (19763)
5964    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5965    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
5967    0xca    JP Z,           6317        ;  Jump to 0x6317 (5987) if ZERO flag is 1
; B--;
; if ( $4DAC == 0 ) {  HL = $4D31;  if ( HL -= DE == 0 ) {  jump_5987();  }  }
5970    0x05    DEC B                       ;  Decrement register B
5971    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
5974    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5975    0x20    JR NZ, N        09          ;  Jump relative 0x09 (9) if ZERO flag is 0
5977    0x2a    LD HL, (NN)     314d        ;  Load register pair HL with location 0x314d (19761)
5980    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5981    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
5983    0xca    JP Z,           6317        ;  Jump to 0x6317 (5987) if ZERO flag is 1
; B--; // B == 0;
5986    0x05    DEC B                       ;  Decrement register B
; $4DA4 = $4DA5 = B;
; if ( B == 0 ) {  return;  }
5987    0x78    LD A, B                     ;  Load Accumulator with register B
5988    0x32    LD (NN), A      a44d        ;  Load location 0xa44d (19876) with the Accumulator
5991    0x32    LD (NN), A      a54d        ;  Load location 0xa54d (19877) with the Accumulator
5994    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
5995    0xc8    RET Z                       ;  Return if ZERO flag is 1
; if ( $(4DA6 + B) == 0 ) {  return;  }  //  4DA7/8/9/A == 0 - R/P/B/O normal, 1 - R/P/B/O edible, running away
; $4DA5 = 0;
; $4DD0++;
; B = $4DD0;  B++;  //  B == 2, 3, 4, or 5
; call_10842();  // score(), B == score event - 10, 50, 200, 400, 800, 1600, 100, 300, 500, 700, 1000, 2000, 3000, 5000
; HL = 0x4EBC;   // pointer to ghost who just got eaten?
; $(HL) |= 0x08;
; return;
5996    0x21    LD HL, NN       a64d        ;  Load register pair HL with 0xa64d (19878)
5999    0x5f    LD E, A                     ;  Load register E with Accumulator
6000    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
6002    0x19    ADD HL, DE                  ;  Add register pair DE to HL
6003    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
6004    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6005    0xc8    RET Z                       ;  Return if ZERO flag is 1
6006    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
6007    0x32    LD (NN), A      a54d        ;  Load location 0xa54d (19877) with the Accumulator
6010    0x21    LD HL, NN       d04d        ;  Load register pair HL with 0xd04d (19920)
6013    0x34    INC (HL)                    ;  Increment location (HL)
6014    0x46    LD B, (HL)                  ;  Load register B with location (HL)
6015    0x04    INC B                       ;  Increment register B
6016    0xcd    CALL NN         5a2a        ;  Call to 0x5a2a (10842)
6019    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
6022    0xcb    SET 3,(HL)                  ;  Set bit 3 of location (HL)
6024    0xc9    RET                         ;  Return

; if ( $4DA4 != 0 ) {  return;  }
; if ( $4DA6 == 0 ) {  return;  }
6025    0x3a    LD A, (NN)      a44d        ;  Load Accumulator with location 0xa44d (19876)
6028    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6029    0xc0    RET NZ                      ;  Return if ZERO flag is 0
6030    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
6033    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6034    0xc8    RET Z                       ;  Return if ZERO flag is 1
; C = 4;  B = 4;  IX = 0x4D08;
; if ( $4DAF != 0 )
; {  if ( $4D06 - $4D08 < 4 && $4D07 - $4D09 < 4 ) {  call_5987();  }  }  // with B==4
; // 200702200238 - I'm pretty sure that 06/08 and 07/09 here are the sq of the XY distances from pac to ghost
; //                and that this routine determines if pac gets eaten.
6035    0x0e    LD  C, N        04          ;  Load register C with 0x04 (4)
6037    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
6039    0xdd    LD IX, NN       084d        ;  Load register pair IX with 0x084d (19720)
6043    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
6046    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6047    0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
6049    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
6052    0xdd    SUB A, (IX+d)   00          ;  Subtract location ( IX + 0x00 () ) from Accumulator
6055    0xb9    CP A, C                     ;  Compare register C with Accumulator
6056    0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
6058    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
6061    0xdd    SUB A, (IX+d)   01          ;  Subtract location ( IX + 0x01 () ) from Accumulator
6064    0xb9    CP A, C                     ;  Compare register C with Accumulator
6065    0xda    JP C, NN        6317        ;  Jump to 0x6317 (5987) if CARRY flag is 1
; B--;
; if ( $4DAE != 0 )
; {  if ( $4D04 - $4D08 < 4 && $4D05 - $4D09 < 4 ) {  call_5987();  }  }  // with B==3
6068    0x05    DEC B                       ;  Decrement register B
6069    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
6072    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6073    0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
6075    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
6078    0xdd    SUB A, (IX+d)   00          ;  Subtract location ( IX + 0x00 () ) from Accumulator
6081    0xb9    CP A, C                     ;  Compare register C with Accumulator
6082    0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
6084    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
6087    0xdd    SUB A, (IX+d)   01          ;  Subtract location ( IX + 0x01 () ) from Accumulator
6090    0xb9    CP A, C                     ;  Compare register C with Accumulator
6091    0xda    JP C, NN        6317        ;  Jump to 0x6317 (5987) if CARRY flag is 1
; B--;
; if ( $4DAD != 0 )
; {  if ( $4D02 - $4D08 < 4 && $4D03 - $4D09 < 4 ) {  call_5987();  }  }  // with B==2
6094    0x05    DEC B                       ;  Decrement register B
6095    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
6098    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6099    0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
6101    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
6104    0xdd    SUB A, (IX+d)   00          ;  Subtract location ( IX + 0x00 () ) from Accumulator
6107    0xb9    CP A, C                     ;  Compare register C with Accumulator
6108    0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
6110    0x3a    LD A, (NN)      034d        ;  Load Accumulator with location 0x034d (19715)
6113    0xdd    SUB A, (IX+d)   01          ;  Subtract location ( IX + 0x01 () ) from Accumulator
6116    0xb9    CP A, C                     ;  Compare register C with Accumulator
6117    0xda    JP C, NN        6317        ;  Jump to 0x6317 (5987) if CARRY flag is 1
; B--;
; if ( $4DAC != 0 )
; {  if ( $4D00 - $4D08 < 4 && $4D01 - $4D09 < 4 ) {  call_5987();  }  }  // with B==1
6120    0x05    DEC B                       ;  Decrement register B
6121    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
6124    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6125    0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
6127    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
6130    0xdd    SUB A, (IX+d)   00          ;  Subtract location ( IX + 0x00 () ) from Accumulator
6133    0xb9    CP A, C                     ;  Compare register C with Accumulator
6134    0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
6136    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
6139    0xdd    SUB A, (IX+d)   01          ;  Subtract location ( IX + 0x01 () ) from Accumulator
6142    0xb9    CP A, C                     ;  Compare register C with Accumulator
6143    0xda    JP C, NN        6317        ;  Jump to 0x6317 (5987) if CARRY flag is 1
; B--;
; call_5987();  // with B==0
6146    0x05    DEC B                       ;  Decrement register B
6147    0xc3    JP NN           6317        ;  Jump to 0x6317 (5987)


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
6150    0x21    LD HL, NN       9d4d        ;  Load register pair HL with 0x9d4d (19869)
6153    0x3e    LD A,N          ff          ;  Load Accumulator with 0xff (255)
6155    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
6156    0xca    JP Z,           1118        ;  Jump to 0x1118 (6161) if ZERO flag is 1
6159    0x35    DEC (HL)                    ;  Decrement location (HL)
6160    0xc9    RET                         ;  Return
6161    0x3a    LD A, (NN)      a64d        ;  Load Accumulator with location 0xa64d (19878)
6164    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6165    0xca    JP Z,           2f18        ;  Jump to 0x2f18 (6191) if ZERO flag is 1
6168    0x2a    LD HL, (NN)     4c4d        ;  Load register pair HL with location 0x4c4d (19788)
6171    0x29    ADD HL, HL                  ;  Add register pair HL to HL
6172    0x22    LD (NN), HL     4c4d        ;  Load location 0x4c4d (19788) with the register pair HL
6175    0x2a    LD HL, (NN)     4a4d        ;  Load register pair HL with location 0x4a4d (19786)
6178    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
6180    0x22    LD (NN), HL     4a4d        ;  Load location 0x4a4d (19786) with the register pair HL
6183    0xd0    RET NC                      ;  Return if CARRY flag is 0
6184    0x21    LD HL, NN       4c4d        ;  Load register pair HL with 0x4c4d (19788)
6187    0x34    INC (HL)                    ;  Increment location (HL)
6188    0xc3    JP NN           4318        ;  Jump to 0x4318 (6211)
6191    0x2a    LD HL, (NN)     484d        ;  Load register pair HL with location 0x484d (19784)
6194    0x29    ADD HL, HL                  ;  Add register pair HL to HL
6195    0x22    LD (NN), HL     484d        ;  Load location 0x484d (19784) with the register pair HL
6198    0x2a    LD HL, (NN)     464d        ;  Load register pair HL with location 0x464d (19782)
6201    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
6203    0x22    LD (NN), HL     464d        ;  Load location 0x464d (19782) with the register pair HL
6206    0xd0    RET NC                      ;  Return if CARRY flag is 0
6207    0x21    LD HL, NN       484d        ;  Load register pair HL with 0x484d (19784)
6210    0x34    INC (HL)                    ;  Increment location (HL)

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
6211    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
6214    0x32    LD (NN), A      9e4d        ;  Load location 0x9e4d (19870) with the Accumulator
6217    0x3a    LD A, (NN)      724e        ;  Load Accumulator with location 0x724e (20082)
6220    0x4f    LD c, A                     ;  Load register C with Accumulator
6221    0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
6224    0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
6225    0x4f    LD c, A                     ;  Load register C with Accumulator
6226    0x21    LD HL, NN       3a4d        ;  Load register pair HL with 0x3a4d (19770)
6229    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
6230    0x06    LD  B, N        21          ;  Load register B with 0x21 (33)
6232    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
6233    0x38    JR C, N         09          ;  Jump to 0x09 (9) if CARRY flag is 1
6235    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
6236    0x06    LD  B, N        3b          ;  Load register B with 0x3b (59)
6238    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
6239    0x30    JR NC, N        03          ;  Jump relative 0x03 (3) if CARRY flag is 0
6241    0xc3    JP NN           ab18        ;  Jump to 0xab18 (6315)
6244    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
6246    0x32    LD (NN), A      bf4d        ;  Load location 0xbf4d (19903) with the Accumulator
6249    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
6252    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
6254    0xca    JP Z,           191a        ;  Jump to 0x191a (6681) if ZERO flag is 1
6257    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
6260    0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
6262    0xd2    JP NC, NN       191a        ;  Jump to 0x191a (6681) if CARRY flag is 0
6265    0x79    LD A, C                     ;  Load Accumulator with register C
6266    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6267    0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
6269    0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
6272    0xc3    JP NN           8618        ;  Jump to 0x8618 (6278)
6275    0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
6278    0xcb    BIT 1,A                     ;  Test bit 1 of Accumulator
6280    0xc2    JP NZ, NN       9918        ;  Jump to 0x9918 (6297) if ZERO flag is 0
6283    0x2a    LD HL, (NN)     0333        ;  Load register pair HL with location 0x0333 (13059)
6286    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
6288    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
6291    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
6294    0xc3    JP NN           5019        ;  Jump to 0x5019 (6480)
6297    0xcb    BIT 2,A                     ;  Test bit 2 of Accumulator
6299    0xc2    JP NZ, NN       5019        ;  Jump to 0x5019 (6480) if ZERO flag is 0
6302    0x2a    LD HL, (NN)     ff32        ;  Load register pair HL with location 0xff32 (13055)
6305    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
6306    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
6309    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
6312    0xc3    JP NN           5019        ;  Jump to 0x5019 (6480)


; if ( $4E00 == 1 ) {  jump_6681();  }
; if ( $4E04 >= 16 ) {  jump_6681();  }
; if ( C != 0 ) {  A = $5040;  }  // C = $4E72 & $4E09 : upright vs. cocktail & player 1 vs player 2
;          else {  A = $5000;  }
; if ( A & 0x02 )  jump_6857();  // 6857 : $4D26 = 0x00, 0x01;  B = 0;  $4DC3 = 2;  jump_6372();
; if ( A & 0x04 )  jump_6873();  // 6873 : $4D26 = 0x00, 0xFF;  B = 0;  $4DC3 = 0;  jump_6372();
; if ( A & 0x01 )  jump_6888();  // 6888 : $4D26 = 0xFF, 0x00;  B = 0;  $4DC3 = 3;  jump_6372();
; if ( A & 0x08 )  jump_6904();  // 6904 : $4D26 = 0x01, 0x00;  B = 0;  $4DC3 = 1;  jump_6372();
; $4D2C = $4D1C;  // double-byte
6315    0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
6318    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
6320    0xca    JP Z,           191a        ;  Jump to 0x191a (6681) if ZERO flag is 1
6323    0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
6326    0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
6328    0xd2    JP NC, NN       191a        ;  Jump to 0x191a (6681) if CARRY flag is 0
6331    0x79    LD A, C                     ;  Load Accumulator with register C
6332    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6333    0x28    JR Z, N         06          ;  Jump relative 0x06 (6) if ZERO flag is 1
6335    0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
6338    0xc3    JP NN           c818        ;  Jump to 0xc818 (6344)
6341    0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
6344    0xcb    BIT 1,A                     ;  Test bit 1 of Accumulator
6346    0xca    JP Z,           c91a        ;  Jump to 0xc91a (6857) if ZERO flag is 1
6349    0xcb    BIT 2,A                     ;  Test bit 2 of Accumulator
6351    0xca    JP Z,           d91a        ;  Jump to 0xd91a (6873) if ZERO flag is 1
6354    0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
6356    0xca    JP Z,           e81a        ;  Jump to 0xe81a (6888) if ZERO flag is 1
6359    0xcb    BIT 3,A                     ;  Test bit 3 of Accumulator
6361    0xca    JP Z,           f81a        ;  Jump to 0xf81a (6904) if ZERO flag is 1
6364    0x2a    LD HL, (NN)     1c4d        ;  Load register pair HL with location 0x1c4d (19740)
6367    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL

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
6370    0x06    LD  B, N        01          ;  Load register B with 0x01 (1)
6372    0xdd    LD IX, NN       264d        ;  Load register pair IX with 0x264d (19750)
6376    0xfd    LD IY, NN       394d        ;  Load register pair IY with 0x394d (19769)
6380    0xcd    CALL NN         0f20        ;  Call to 0x0f20 (8207)
6383    0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
6385    0xd6    SUB N           c0          ;  Subtract 0xc0 (192) from Accumulator (no carry)
6387    0x20    JR NZ, N        4b          ;  Jump relative 0x4b (75) if ZERO flag is 0
6389    0x05    DEC B                       ;  Decrement register B
6390    0xc2    JP NZ, NN       1619        ;  Jump to 0x1619 (6422) if ZERO flag is 0
6393    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
6396    0x0f    RRCA                        ;  Rotate right circular Accumulator
6397    0xda    JP C, NN        0b19        ;  Jump to 0x0b19 (6411) if CARRY flag is 1
6400    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
6403    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
6405    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
6407    0xc8    RET Z                       ;  Return if ZERO flag is 1
6408    0xc3    JP NN           4019        ;  Jump to 0x4019 (6464)
6411    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
6414    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
6416    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
6418    0xc8    RET Z                       ;  Return if ZERO flag is 1
6419    0xc3    JP NN           4019        ;  Jump to 0x4019 (6464)
6422    0xdd    LD IX, NN       1c4d        ;  Load register pair IX with 0x1c4d (19740)
6426    0xcd    CALL NN         0f20        ;  Call to 0x0f20 (8207)
6429    0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
6431    0xd6    SUB N           c0          ;  Subtract 0xc0 (192) from Accumulator (no carry)
6433    0x20    JR NZ, N        2d          ;  Jump relative 0x2d (45) if ZERO flag is 0
6435    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
6438    0x0f    RRCA                        ;  Rotate right circular Accumulator
6439    0xda    JP C, NN        3519        ;  Jump to 0x3519 (6453) if CARRY flag is 1
6442    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
6445    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
6447    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
6449    0xc8    RET Z                       ;  Return if ZERO flag is 1
6450    0xc3    JP NN           5019        ;  Jump to 0x5019 (6480)
6453    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
6456    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
6458    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
6460    0xc8    RET Z                       ;  Return if ZERO flag is 1
6461    0xc3    JP NN           5019        ;  Jump to 0x5019 (6480)
6464    0x2a    LD HL, (NN)     264d        ;  Load register pair HL with location 0x264d (19750)
6467    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
6470    0x05    DEC B                       ;  Decrement register B
6471    0xca    JP Z,           5019        ;  Jump to 0x5019 (6480) if ZERO flag is 1
6474    0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
6477    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
6480    0xdd    LD IX, NN       1c4d        ;  Load register pair IX with 0x1c4d (19740)
6484    0xfd    LD IY, NN       084d        ;  Load register pair IY with 0x084d (19720)
6488    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)

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
6491    0x3a    LD A, (NN)      304d        ;  Load Accumulator with location 0x304d (19760)
6494    0x0f    RRCA                        ;  Rotate right circular Accumulator
6495    0xda    JP C, NN        7519        ;  Jump to 0x7519 (6517) if CARRY flag is 1
6498    0x7d    LD A, L                     ;  Load Accumulator with register L
6499    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
6501    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
6503    0xca    JP Z,           8519        ;  Jump to 0x8519 (6533) if ZERO flag is 1
6506    0xda    JP C, NN        7119        ;  Jump to 0x7119 (6513) if CARRY flag is 1
6509    0x2d    DEC L                       ;  Decrement register L
6510    0xc3    JP NN           8519        ;  Jump to 0x8519 (6533)
6513    0x2c    INC L                       ;  Increment register L
6514    0xc3    JP NN           8519        ;  Jump to 0x8519 (6533)
6517    0x7c    LD A, H                     ;  Load Accumulator with register H
6518    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
6520    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
6522    0xca    JP Z,           8519        ;  Jump to 0x8519 (6533) if ZERO flag is 1
6525    0xda    JP C, NN        8419        ;  Jump to 0x8419 (6532) if CARRY flag is 1
6528    0x25    DEC H                       ;  Decrement register H
6529    0xc3    JP NN           8519        ;  Jump to 0x8519 (6533)
6532    0x24    INC H                       ;  Increment register H
; $4D08 = HL;
; call_8216();
6533    0x22    LD (NN), HL     084d        ;  Load location 0x084d (19720) with the register pair HL
6536    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
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

6539    0x22    LD (NN), HL     394d        ;  Load location 0x394d (19769) with the register pair HL
6542    0xdd    LD IX, NN       bf4d        ;  Load register pair IX with 0xbf4d (19903)
6546    0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
6549    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x00 () ) with 0x00 ()
6553    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6554    0xc0    RET NZ                      ;  Return if ZERO flag is 0
6555    0x3a    LD A, (NN)      d24d        ;  Load Accumulator with location 0xd24d (19922)
6558    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6559    0x28    JR Z, N         2c          ;  Jump relative 0x2c (44) if ZERO flag is 1
6561    0x3a    LD A, (NN)      d44d        ;  Load Accumulator with location 0xd44d (19924)
6564    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6565    0x28    JR Z, N         26          ;  Jump relative 0x26 (38) if ZERO flag is 1
6567    0x2a    LD HL, (NN)     084d        ;  Load register pair HL with location 0x084d (19720)
;; 6568-6575 : On Ms. Pac-Man patched in from $80A8-$80AF
6570    0x11    LD  DE, NN      9480        ;  Load register pair DE with 0x9480 (148)
;; On Ms. Pac-Man:
;; 6573  $19ad   0xc3    JP nn           1888        ;  Jump to $nn
6573    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6574    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
6576    0x20    JR NZ, N        1b          ;  Jump relative 0x1b (27) if ZERO flag is 0
6578    0x06    LD  B, N        19          ;  Load register B with 0x19 (25)
6580    0x4f    LD c, A                     ;  Load register C with Accumulator
6581    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
6584    0x0e    LD  C, N        15          ;  Load register C with 0x15 (21)
6586    0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
6587    0x4f    LD c, A                     ;  Load register C with Accumulator
6588    0x06    LD  B, N        1c          ;  Load register B with 0x1c (28)
6590    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
6593    0xcd    CALL NN         0410        ;  Call to 0x0410 (4100)
6596    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x05, 0x00
6600    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
6603    0xcb    SET 2,(HL)                  ;  Set bit 2 of location (HL)
6605    0x3e    LD A,N          ff          ;  Load Accumulator with 0xff (255)
6607    0x32    LD (NN), A      9d4d        ;  Load location 0x9d4d (19869) with the Accumulator
6610    0x2a    LD HL, (NN)     394d        ;  Load register pair HL with location 0x394d (19769)
; HL = YX_to_playfieldaddr(HL);  // via 101
6613    0xcd    CALL NN         6500        ;  Call to 0x6500 (101)
6616    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
6617    0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
6619    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
6621    0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
6623    0xc0    RET NZ                      ;  Return if ZERO flag is 0
6624    0xdd    LD IX, NN       0e4e        ;  Load register pair IX with 0x0e4e (19982)
6628    0xdd    INC (IX + N)    00          ;  Increment location IX + 0x00 ()
6631    0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
6633    0xcb    SRL A                       ;  Shift Accumulator right logical
6635    0x06    LD  B, N        40          ;  Load register B with 0x40 (64)
6637    0x70    LD (HL), B                  ;  Load location (HL) with register B
6638    0x06    LD  B, N        19          ;  Load register B with 0x19 (25)
6640    0x4f    LD c, A                     ;  Load register C with Accumulator
6641    0xcb    SRL C                       ;  Shift register C right logical
; insert_msg(0x19, A);
6643    0xcd    CALL NN         4200        ;  Call to 0x4200 (66)
6646    0x3c    INC A                       ;  Increment Accumulator
6647    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
6649    0xca    JP Z,           fd19        ;  Jump to 0xfd19 (6653) if ZERO flag is 1
6652    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
6653    0x32    LD (NN), A      9d4d        ;  Load location 0x9d4d (19869) with the Accumulator
6656    0xcd    CALL NN         081b        ;  Call to 0x081b (6920)
6659    0xcd    CALL NN         6a1a        ;  Call to 0x6a1a (6762)
6662    0x21    LD HL, NN       bc4e        ;  Load register pair HL with 0xbc4e (20156)
6665    0x3a    LD A, (NN)      0e4e        ;  Load Accumulator with location 0x0e4e (19982)
6668    0x0f    RRCA                        ;  Rotate right circular Accumulator
6669    0x38    JR C, N         05          ;  Jump to 0x05 (5) if CARRY flag is 1
6671    0xcb    SET 0,(HL)                  ;  Set bit 0 of location (HL)
6673    0xcb    RES 1,(HL)                  ;  Reset bit 1 of location (HL)
6675    0xc9    RET                         ;  Return
6676    0xcb    RES 0,(HL)                  ;  Reset bit 0 of location (HL)
6678    0xcb    SET 1,(HL)                  ;  Set bit 1 of location (HL)
6680    0xc9    RET                         ;  Return


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
6681    0x21    LD HL, NN       1c4d        ;  Load register pair HL with 0x1c4d (19740)
6684    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
6685    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6686    0xca    JP Z,           2e1a        ;  Jump to 0x2e1a (6702) if ZERO flag is 1
6689    0x3a    LD A, (NN)      084d        ;  Load Accumulator with location 0x084d (19720)
6692    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
6694    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
6696    0xca    JP Z,           381a        ;  Jump to 0x381a (6712) if ZERO flag is 1
6699    0xc3    JP NN           5c1a        ;  Jump to 0x5c1a (6748)
6702    0x3a    LD A, (NN)      094d        ;  Load Accumulator with location 0x094d (19721)
6705    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
6707    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
6709    0xc2    JP NZ, NN       5c1a        ;  Jump to 0x5c1a (6748) if ZERO flag is 0
6712    0x3e    LD A,N          05          ;  Load Accumulator with 0x05 (5)
6714    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
6717    0x38    JR C, N         03          ;  Jump to 0x03 (3) if CARRY flag is 1
6719    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x17, 0x00
6722    0xdd    LD IX, NN       264d        ;  Load register pair IX with 0x264d (19750)
6726    0xfd    LD IY, NN       124d        ;  Load register pair IY with 0x124d (19730)
6730    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
6733    0x22    LD (NN), HL     124d        ;  Load location 0x124d (19730) with the register pair HL
6736    0x2a    LD HL, (NN)     264d        ;  Load register pair HL with location 0x264d (19750)
6739    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
6742    0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
6745    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
6748    0xdd    LD IX, NN       1c4d        ;  Load register pair IX with 0x1c4d (19740)
6752    0xfd    LD IY, NN       084d        ;  Load register pair IY with 0x084d (19720)
6756    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
6759    0xc3    JP NN           8519        ;  Jump to 0x8519 (6533)


; if ( $4D9D != 6 ) {  return;  }
; $4DCB = $4DBD;  // double-byte copy
; $4DA6 = $4DA7 = $4DA8 = $4DA9 = $4DAA = 1;
; $4DB1 = $4DB2 = $4DB3 = $4DB4 = $4DB5 = 1;
; $4DC8 = $4DD0 = 0;
; $4C02 = $4C04 = $4C06 = $4C08 = 0x1C;
; $4C03 = $4C05 = $4C07 = $4C09 = 0x11;
; $4EAC |= 020;  $4EAC &= 0x7F;
; return;
6762    0x3a    LD A, (NN)      9d4d        ;  Load Accumulator with location 0x9d4d (19869)
6765    0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
6767    0xc0    RET NZ                      ;  Return if ZERO flag is 0
6768    0x2a    LD HL, (NN)     bd4d        ;  Load register pair HL with location 0xbd4d (19901)
6771    0x22    LD (NN), HL     cb4d        ;  Load location 0xcb4d (19915) with the register pair HL
6774    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
6776    0x32    LD (NN), A      a64d        ;  Load location 0xa64d (19878) with the Accumulator
6779    0x32    LD (NN), A      a74d        ;  Load location 0xa74d (19879) with the Accumulator
6782    0x32    LD (NN), A      a84d        ;  Load location 0xa84d (19880) with the Accumulator
6785    0x32    LD (NN), A      a94d        ;  Load location 0xa94d (19881) with the Accumulator
6788    0x32    LD (NN), A      aa4d        ;  Load location 0xaa4d (19882) with the Accumulator
6791    0x32    LD (NN), A      b14d        ;  Load location 0xb14d (19889) with the Accumulator
6794    0x32    LD (NN), A      b24d        ;  Load location 0xb24d (19890) with the Accumulator
6797    0x32    LD (NN), A      b34d        ;  Load location 0xb34d (19891) with the Accumulator
6800    0x32    LD (NN), A      b44d        ;  Load location 0xb44d (19892) with the Accumulator
6803    0x32    LD (NN), A      b54d        ;  Load location 0xb54d (19893) with the Accumulator
6806    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
6807    0x32    LD (NN), A      c84d        ;  Load location 0xc84d (19912) with the Accumulator
6810    0x32    LD (NN), A      d04d        ;  Load location 0xd04d (19920) with the Accumulator
6813    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
6817    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x1c ()
6821    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x04 () ) with 0x1c ()
6825    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x06 () ) with 0x1c ()
6829    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x08 () ) with 0x1c ()
6833    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x03 () ) with 0x11 ()
6837    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x11 ()
6841    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x11 ()
6845    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x11 ()
6849    0x21    LD HL, NN       ac4e        ;  Load register pair HL with 0xac4e (20140)
6852    0xcb    SET 5,(HL)                  ;  Set bit 5 of location (HL)
6854    0xcb    RES 7,(HL)                  ;  Reset bit 7 of location (HL)
6856    0xc9    RET                         ;  Return


; $4D26 = $3303 // $3303 == 0x00, 0x01
; B = 0;  $4DC3 = 2;  jump_6372();
6857    0x2a    LD HL, (NN)     0333        ;  Load register pair HL with location 0x0333 (13059)
6860    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
6862    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
6865    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
6868    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
6870    0xc3    JP NN           e418        ;  Jump to 0xe418 (6372)

; $4D26 = $32FF // $32FF == 0x00, 0xFF
; B = 0;  $4DC3 = 0;  jump_6372();
6873    0x2a    LD HL, (NN)     ff32        ;  Load register pair HL with location 0xff32 (13055)
6876    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
6877    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
6880    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
6883    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
6885    0xc3    JP NN           e418        ;  Jump to 0xe418 (6372)

; $4D26 = $3305 // $3305 == 0xFF, 0x00
; B = 0;  $4DC3 = 3;  jump_6372();
6888    0x2a    LD HL, (NN)     0533        ;  Load register pair HL with location 0x0533 (13061)
6891    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
6893    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
6896    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
6899    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
6901    0xc3    JP NN           e418        ;  Jump to 0xe418 (6372)

; $4D26 = $3301 // $3301 == 0x01, 0x00
; B = 0;  $4DC3 = 1;  jump_6372();
6904    0x2a    LD HL, (NN)     0133        ;  Load register pair HL with location 0x0133 (13057)
6907    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
6909    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
6912    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
6915    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
6917    0xc3    JP NN           e418        ;  Jump to 0xe418 (6372)

; if ( $4E12 == 0 ) {  jump_6932();  }
; $4D9F++;
; return;
6920    0x3a    LD A, (NN)      124e        ;  Load Accumulator with location 0x124e (19986)
6923    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6924    0xca    JP Z,           141b        ;  Jump to 0x141b (6932) if ZERO flag is 1
6927    0x21    LD HL, NN       9f4d        ;  Load register pair HL with 0x9f4d (19871)
6930    0x34    INC (HL)                    ;  Increment location (HL)
6931    0xc9    RET                         ;  Return

; if ( $4DA3 != 0 ) {  return;  }
; if ( $4DA2 == 0 ) {  jump_6949();  }
; $4E11++;
; return;
6932    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
6935    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6936    0xc0    RET NZ                      ;  Return if ZERO flag is 0
6937    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
6940    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6941    0xca    JP Z,           251b        ;  Jump to 0x251b (6949) if ZERO flag is 1
6944    0x21    LD HL, NN       114e        ;  Load register pair HL with 0x114e (19985)
6947    0x34    INC (HL)                    ;  Increment location (HL)
6948    0xc9    RET                         ;  Return

; if ( $4DA1 != 0 ) $4E10++;
;              else $4E0F++;
; return;
6949    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
6952    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6953    0xca    JP Z,           311b        ;  Jump to 0x311b (6961) if ZERO flag is 1
6956    0x21    LD HL, NN       104e        ;  Load register pair HL with 0x104e (19984)
6959    0x34    INC (HL)                    ;  Increment location (HL)
6960    0xc9    RET                         ;  Return
6961    0x21    LD HL, NN       0f4e        ;  Load register pair HL with 0x0f4e (19983)
6964    0x34    INC (HL)                    ;  Increment location (HL)
6965    0xc9    RET                         ;  Return


; if ( $4DA0 == 0 ) {  return;  }
; if ( $4DAC != 0 ) {  return;  }
; call_8407();
6966    0x3a    LD A, (NN)      a04d        ;  Load Accumulator with location 0xa04d (19872)
6969    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6970    0xc8    RET Z                       ;  Return if ZERO flag is 1
6971    0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
6974    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6975    0xc0    RET NZ                      ;  Return if ZERO flag is 0
6976    0xcd    CALL NN         d720        ;  Call to 0xd720 (8407)
; HL = $4D31;  BC = 0x4D99;
; $BC = ( YX_to_playfield_addr_plus4() == 0x1B ) ? 0x01 : 0x00; // via call_8282()
6979    0x2a    LD HL, (NN)     314d        ;  Load register pair HL with location 0x314d (19761)
6982    0x01    LD  BC, NN      994d        ;  Load register pair BC with 0x994d (19865)
6985    0xcd    CALL NN         5a20        ;  Call to 0x5a20 (8282)
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
6988    0x3a    LD A, (NN)      994d        ;  Load Accumulator with location 0x994d (19865)
6991    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
6992    0xca    JP Z,           6a1b        ;  Jump to 0x6a1b (7018) if ZERO flag is 1
6995    0x2a    LD HL, (NN)     604d        ;  Load register pair HL with location 0x604d (19808)
6998    0x29    ADD HL, HL                  ;  Add register pair HL to HL
6999    0x22    LD (NN), HL     604d        ;  Load location 0x604d (19808) with the register pair HL
7002    0x2a    LD HL, (NN)     5e4d        ;  Load register pair HL with location 0x5e4d (19806)
7005    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7007    0x22    LD (NN), HL     5e4d        ;  Load location 0x5e4d (19806) with the register pair HL
7010    0xd0    RET NC                      ;  Return if CARRY flag is 0
7011    0x21    LD HL, NN       604d        ;  Load register pair HL with 0x604d (19808)
7014    0x34    INC (HL)                    ;  Increment location (HL)
7015    0xc3    JP NN           d81b        ;  Jump to 0xd81b (7128)
7018    0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
7021    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7022    0xca    JP Z,           881b        ;  Jump to 0x881b (7048) if ZERO flag is 1
7025    0x2a    LD HL, (NN)     5c4d        ;  Load register pair HL with location 0x5c4d (19804)
7028    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7029    0x22    LD (NN), HL     5c4d        ;  Load location 0x5c4d (19804) with the register pair HL
7032    0x2a    LD HL, (NN)     5a4d        ;  Load register pair HL with location 0x5a4d (19802)
7035    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7037    0x22    LD (NN), HL     5a4d        ;  Load location 0x5a4d (19802) with the register pair HL
7040    0xd0    RET NC                      ;  Return if CARRY flag is 0
7041    0x21    LD HL, NN       5c4d        ;  Load register pair HL with 0x5c4d (19804)
7044    0x34    INC (HL)                    ;  Increment location (HL)
7045    0xc3    JP NN           d81b        ;  Jump to 0xd81b (7128)
7048    0x3a    LD A, (NN)      b74d        ;  Load Accumulator with location 0xb74d (19895)
7051    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7052    0xca    JP Z,           a61b        ;  Jump to 0xa61b (7078) if ZERO flag is 1
7055    0x2a    LD HL, (NN)     504d        ;  Load register pair HL with location 0x504d (19792)
7058    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7059    0x22    LD (NN), HL     504d        ;  Load location 0x504d (19792) with the register pair HL
7062    0x2a    LD HL, (NN)     4e4d        ;  Load register pair HL with location 0x4e4d (19790)
7065    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7067    0x22    LD (NN), HL     4e4d        ;  Load location 0x4e4d (19790) with the register pair HL
7070    0xd0    RET NC                      ;  Return if CARRY flag is 0
7071    0x21    LD HL, NN       504d        ;  Load register pair HL with 0x504d (19792)
7074    0x34    INC (HL)                    ;  Increment location (HL)
7075    0xc3    JP NN           d81b        ;  Jump to 0xd81b (7128)
7078    0x3a    LD A, (NN)      b64d        ;  Load Accumulator with location 0xb64d (19894)
7081    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7082    0xca    JP Z,           c41b        ;  Jump to 0xc41b (7108) if ZERO flag is 1
7085    0x2a    LD HL, (NN)     544d        ;  Load register pair HL with location 0x544d (19796)
7088    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7089    0x22    LD (NN), HL     544d        ;  Load location 0x544d (19796) with the register pair HL
7092    0x2a    LD HL, (NN)     524d        ;  Load register pair HL with location 0x524d (19794)
7095    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7097    0x22    LD (NN), HL     524d        ;  Load location 0x524d (19794) with the register pair HL
7100    0xd0    RET NC                      ;  Return if CARRY flag is 0
7101    0x21    LD HL, NN       544d        ;  Load register pair HL with 0x544d (19796)
7104    0x34    INC (HL)                    ;  Increment location (HL)
7105    0xc3    JP NN           d81b        ;  Jump to 0xd81b (7128)
7108    0x2a    LD HL, (NN)     584d        ;  Load register pair HL with location 0x584d (19800)
7111    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7112    0x22    LD (NN), HL     584d        ;  Load location 0x584d (19800) with the register pair HL
7115    0x2a    LD HL, (NN)     564d        ;  Load register pair HL with location 0x564d (19798)
7118    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7120    0x22    LD (NN), HL     564d        ;  Load location 0x564d (19798) with the register pair HL
7123    0xd0    RET NC                      ;  Return if CARRY flag is 0
7124    0x21    LD HL, NN       584d        ;  Load register pair HL with 0x584d (19800)
7127    0x34    INC (HL)                    ;  Increment location (HL)
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
7128    0x21    LD HL, NN       144d        ;  Load register pair HL with 0x144d (19732)
7131    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7132    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7133    0xca    JP Z,           ed1b        ;  Jump to 0xed1b (7149) if ZERO flag is 1
7136    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
7139    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
7141    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
7143    0xca    JP Z,           f71b        ;  Jump to 0xf71b (7159) if ZERO flag is 1
7146    0xc3    JP NN           361c        ;  Jump to 0x361c (7222)
7149    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
7152    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
7154    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
7156    0xc2    JP NZ, NN       361c        ;  Jump to 0x361c (7222) if ZERO flag is 0


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
7159    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
7161    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
7164    0x38    JR C, N         1b          ;  Jump to 0x1b (27) if CARRY flag is 1
7166    0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
7169    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7170    0xca    JP Z,           0b1c        ;  Jump to 0x0b1c (7179) if ZERO flag is 1
7173    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0C, 0x00
7176    0xc3    JP NN           191c        ;  Jump to 0x191c (7193)
7179    0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
7182    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
7185    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7186    0xfe    CP N            1a          ;  Compare 0x1a (26) with Accumulator
7188    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
7190    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x08, 0x00
7193    0xcd    CALL NN         fe1e        ;  Call to 0xfe1e (7934)
7196    0xdd    LD IX, NN       1e4d        ;  Load register pair IX with 0x1e4d (19742)
7200    0xfd    LD IY, NN       0a4d        ;  Load register pair IY with 0x0a4d (19722)
; HL = (IY) + (IX);
7204    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
7207    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
7210    0x2a    LD HL, (NN)     1e4d        ;  Load register pair HL with location 0x1e4d (19742)
7213    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
7216    0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
7219    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
7222    0xdd    LD IX, NN       144d        ;  Load register pair IX with 0x144d (19732)
7226    0xfd    LD IY, NN       004d        ;  Load register pair IY with 0x004d (19712)
; HL = (IY) + (IX);
7230    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
7233    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
7236    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
7239    0x22    LD (NN), HL     314d        ;  Load location 0x314d (19761) with the register pair HL
7242    0xc9    RET                         ;  Return


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
7243    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
7246    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
7248    0xc0    RET NZ                      ;  Return if ZERO flag is 0
7249    0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
7252    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7253    0xc0    RET NZ                      ;  Return if ZERO flag is 0
7254    0x2a    LD HL, (NN)     334d        ;  Load register pair HL with location 0x334d (19763)
7257    0x01    LD  BC, NN      9a4d        ;  Load register pair BC with 0x9a4d (19866)
7260    0xcd    CALL NN         5a20        ;  Call to 0x5a20 (8282)
7263    0x3a    LD A, (NN)      9a4d        ;  Load Accumulator with location 0x9a4d (19866)
7266    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7267    0xca    JP Z,           7d1c        ;  Jump to 0x7d1c (7293) if ZERO flag is 1
7270    0x2a    LD HL, (NN)     6c4d        ;  Load register pair HL with location 0x6c4d (19820)
7273    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7274    0x22    LD (NN), HL     6c4d        ;  Load location 0x6c4d (19820) with the register pair HL
7277    0x2a    LD HL, (NN)     6a4d        ;  Load register pair HL with location 0x6a4d (19818)
7280    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7282    0x22    LD (NN), HL     6a4d        ;  Load location 0x6a4d (19818) with the register pair HL
7285    0xd0    RET NC                      ;  Return if CARRY flag is 0
7286    0x21    LD HL, NN       6c4d        ;  Load register pair HL with 0x6c4d (19820)
7289    0x34    INC (HL)                    ;  Increment location (HL)
7290    0xc3    JP NN           af1c        ;  Jump to 0xaf1c (7343)
7293    0x3a    LD A, (NN)      a84d        ;  Load Accumulator with location 0xa84d (19880)
7296    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7297    0xca    JP Z,           9b1c        ;  Jump to 0x9b1c (7323) if ZERO flag is 1
7300    0x2a    LD HL, (NN)     684d        ;  Load register pair HL with location 0x684d (19816)
7303    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7304    0x22    LD (NN), HL     684d        ;  Load location 0x684d (19816) with the register pair HL
7307    0x2a    LD HL, (NN)     664d        ;  Load register pair HL with location 0x664d (19814)
7310    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7312    0x22    LD (NN), HL     664d        ;  Load location 0x664d (19814) with the register pair HL
7315    0xd0    RET NC                      ;  Return if CARRY flag is 0
7316    0x21    LD HL, NN       684d        ;  Load register pair HL with 0x684d (19816)
7319    0x34    INC (HL)                    ;  Increment location (HL)
7320    0xc3    JP NN           af1c        ;  Jump to 0xaf1c (7343)
7323    0x2a    LD HL, (NN)     644d        ;  Load register pair HL with location 0x644d (19812)
7326    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7327    0x22    LD (NN), HL     644d        ;  Load location 0x644d (19812) with the register pair HL
7330    0x2a    LD HL, (NN)     624d        ;  Load register pair HL with location 0x624d (19810)
7333    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7335    0x22    LD (NN), HL     624d        ;  Load location 0x624d (19810) with the register pair HL
7338    0xd0    RET NC                      ;  Return if CARRY flag is 0
7339    0x21    LD HL, NN       644d        ;  Load register pair HL with 0x644d (19812)
7342    0x34    INC (HL)                    ;  Increment location (HL)

; HL = 0x4D16
; if ( $HL != 1 )
; {
;     if ( $4D02 & 0x07 != 4 ) {  jump_7437();  }  // 7437 is {  $4D02 += $4D16;  L = ( L >> 3 ) + 0x20;  H = ( H >> 3 ) + 0x1E;  return;  }
; }
; else
; {
;     if ( $4D03 & 0x07 != 4 ) {  jump_7437();  }  // 7437 is {  $4D02 += $4D16;  L = ( L >> 3 ) + 0x20;  H = ( H >> 3 ) + 0x1E;  return;  }
; }
7343    0x21    LD HL, NN       164d        ;  Load register pair HL with 0x164d (19734)
7346    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7347    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7348    0xca    JP Z,           c41c        ;  Jump to 0xc41c (7364) if ZERO flag is 1
7351    0x3a    LD A, (NN)      024d        ;  Load Accumulator with location 0x024d (19714)
7354    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
7356    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
7358    0xca    JP Z,           ce1c        ;  Jump to 0xce1c (7374) if ZERO flag is 1
7361    0xc3    JP NN           0d1d        ;  Jump to 0x0d1d (7437)
7364    0x3a    LD A, (NN)      034d        ;  Load Accumulator with location 0x034d (19715)
7367    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
7369    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
7371    0xc2    JP NZ, NN       0d1d        ;  Jump to 0x0d1d (7437) if ZERO flag is 0
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
7374    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
7376    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
7379    0x38    JR C, N         1b          ;  Jump to 0x1b (27) if CARRY flag is 1
7381    0x3a    LD A, (NN)      a84d        ;  Load Accumulator with location 0xa84d (19880)
7384    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7385    0xca    JP Z,           e21c        ;  Jump to 0xe21c (7394) if ZERO flag is 1
7388    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0D, 0x00
7391    0xc3    JP NN           f01c        ;  Jump to 0xf01c (7408)
7394    0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
7397    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
7400    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7401    0xfe    CP N            1a          ;  Compare 0x1a (26) with Accumulator
7403    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
7405    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x09, 0x00
7408    0xcd    CALL NN         251f        ;  Call to 0x251f (7973)
7411    0xdd    LD IX, NN       204d        ;  Load register pair IX with 0x204d (19744)
7415    0xfd    LD IY, NN       0c4d        ;  Load register pair IY with 0x0c4d (19724)
; HL = (IY) + (IX);
7419    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
7422    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
7425    0x2a    LD HL, (NN)     204d        ;  Load register pair HL with location 0x204d (19744)
7428    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
7431    0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
7434    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
; $4D02 += $4D16;
; L = ( L >> 3 ) + 0x20;  H = ( H >> 3 ) + 0x1E;
; $4DEE = HL;
; return;
7437    0xdd    LD IX, NN       164d        ;  Load register pair IX with 0x164d (19734)
7441    0xfd    LD IY, NN       024d        ;  Load register pair IY with 0x024d (19714)
; HL = (IY) + (IX);
7445    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
7448    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
7451    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
7454    0x22    LD (NN), HL     334d        ;  Load location 0x334d (19763) with the register pair HL
7457    0xc9    RET                         ;  Return


; if ( $4DA2 != 1 ) {  return;  }
; if ( $4DAE != 0 ) {  return;  }
; HL = $4D35;  BC = 0x4D9B;
; $BC = ( YX_to_playfield_addr_plus4() == 0x1B ) ? 0x01 : 0x00; // via call_8282()
7458    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
7461    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
7463    0xc0    RET NZ                      ;  Return if ZERO flag is 0
7464    0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
7467    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7468    0xc0    RET NZ                      ;  Return if ZERO flag is 0
7469    0x2a    LD HL, (NN)     354d        ;  Load register pair HL with location 0x354d (19765)
7472    0x01    LD  BC, NN      9b4d        ;  Load register pair BC with 0x9b4d (19867)
7475    0xcd    CALL NN         5a20        ;  Call to 0x5a20 (8282)

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
7478    0x3a    LD A, (NN)      9b4d        ;  Load Accumulator with location 0x9b4d (19867)
7481    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7482    0xca    JP Z,           541d        ;  Jump to 0x541d (7508) if ZERO flag is 1
7485    0x2a    LD HL, (NN)     784d        ;  Load register pair HL with location 0x784d (19832)
7488    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7489    0x22    LD (NN), HL     784d        ;  Load location 0x784d (19832) with the register pair HL
7492    0x2a    LD HL, (NN)     764d        ;  Load register pair HL with location 0x764d (19830)
7495    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7497    0x22    LD (NN), HL     764d        ;  Load location 0x764d (19830) with the register pair HL
7500    0xd0    RET NC                      ;  Return if CARRY flag is 0
7501    0x21    LD HL, NN       784d        ;  Load register pair HL with 0x784d (19832)
7504    0x34    INC (HL)                    ;  Increment location (HL)
7505    0xc3    JP NN           861d        ;  Jump to 0x861d (7558)
7508    0x3a    LD A, (NN)      a94d        ;  Load Accumulator with location 0xa94d (19881)
7511    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7512    0xca    JP Z,           721d        ;  Jump to 0x721d (7538) if ZERO flag is 1
7515    0x2a    LD HL, (NN)     744d        ;  Load register pair HL with location 0x744d (19828)
7518    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7519    0x22    LD (NN), HL     744d        ;  Load location 0x744d (19828) with the register pair HL
7522    0x2a    LD HL, (NN)     724d        ;  Load register pair HL with location 0x724d (19826)
7525    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7527    0x22    LD (NN), HL     724d        ;  Load location 0x724d (19826) with the register pair HL
7530    0xd0    RET NC                      ;  Return if CARRY flag is 0
7531    0x21    LD HL, NN       744d        ;  Load register pair HL with 0x744d (19828)
7534    0x34    INC (HL)                    ;  Increment location (HL)
7535    0xc3    JP NN           861d        ;  Jump to 0x861d (7558)
7538    0x2a    LD HL, (NN)     704d        ;  Load register pair HL with location 0x704d (19824)
7541    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7542    0x22    LD (NN), HL     704d        ;  Load location 0x704d (19824) with the register pair HL
7545    0x2a    LD HL, (NN)     6e4d        ;  Load register pair HL with location 0x6e4d (19822)
7548    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7550    0x22    LD (NN), HL     6e4d        ;  Load location 0x6e4d (19822) with the register pair HL
7553    0xd0    RET NC                      ;  Return if CARRY flag is 0
7554    0x21    LD HL, NN       704d        ;  Load register pair HL with 0x704d (19824)
7557    0x34    INC (HL)                    ;  Increment location (HL)

; if ( $4D18 != 0 )
; {
; //    if ( $4D04 & 0x07 == 4 ) {  jump_7589();  } else {  jump_7652();  }
;     if ( $4D04 & 0x07 != 4 ) {  jump_7652();  }
; }
; else
; {
;     if ( $4D05 & 0x07 != 4 ) {  jump_7652();  }
; }
7558    0x21    LD HL, NN       184d        ;  Load register pair HL with 0x184d (19736)
7561    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7562    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7563    0xca    JP Z,           9b1d        ;  Jump to 0x9b1d (7579) if ZERO flag is 1
7566    0x3a    LD A, (NN)      044d        ;  Load Accumulator with location 0x044d (19716)
7569    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
7571    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
7573    0xca    JP Z,           a51d        ;  Jump to 0xa51d (7589) if ZERO flag is 1
7576    0xc3    JP NN           e41d        ;  Jump to 0xe41d (7652)

7579    0x3a    LD A, (NN)      054d        ;  Load Accumulator with location 0x054d (19717)
7582    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
7584    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
7586    0xc2    JP NZ, NN       e41d        ;  Jump to 0xe41d (7652) if ZERO flag is 0
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
7589    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
7591    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
7594    0x38    JR C, N         1b          ;  Jump to 0x1b (27) if CARRY flag is 1
7596    0x3a    LD A, (NN)      a94d        ;  Load Accumulator with location 0xa94d (19881)
7599    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7600    0xca    JP Z,           b91d        ;  Jump to 0xb91d (7609) if ZERO flag is 1
7603    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0E, 0x00
7606    0xc3    JP NN           c71d        ;  Jump to 0xc71d (7623)
7609    0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
7612    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
7615    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7616    0xfe    CP N            1a          ;  Compare 0x1a (26) with Accumulator
7618    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
7620    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0a, 0x00
7623    0xcd    CALL NN         4c1f        ;  Call to 0x4c1f (8012)
7626    0xdd    LD IX, NN       224d        ;  Load register pair IX with 0x224d (19746)
7630    0xfd    LD IY, NN       0e4d        ;  Load register pair IY with 0x0e4d (19726)
; HL = (IY) + (IX);
7634    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
7637    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
7640    0x2a    LD HL, (NN)     224d        ;  Load register pair HL with location 0x224d (19746)
7643    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
7646    0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
7649    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
7652    0xdd    LD IX, NN       184d        ;  Load register pair IX with 0x184d (19736)
7656    0xfd    LD IY, NN       044d        ;  Load register pair IY with 0x044d (19716)
; HL = (IY) + (IX);
7660    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
7663    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
7666    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
7669    0x22    LD (NN), HL     354d        ;  Load location 0x354d (19765) with the register pair HL
7672    0xc9    RET                         ;  Return


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
7673    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
7676    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
7678    0xc0    RET NZ                      ;  Return if ZERO flag is 0
7679    0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
7682    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7683    0xc0    RET NZ                      ;  Return if ZERO flag is 0
7684    0x2a    LD HL, (NN)     374d        ;  Load register pair HL with location 0x374d (19767)
7687    0x01    LD  BC, NN      9c4d        ;  Load register pair BC with 0x9c4d (19868)
7690    0xcd    CALL NN         5a20        ;  Call to 0x5a20 (8282)
7693    0x3a    LD A, (NN)      9c4d        ;  Load Accumulator with location 0x9c4d (19868)
7696    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7697    0xca    JP Z,           2b1e        ;  Jump to 0x2b1e (7723) if ZERO flag is 1
7700    0x2a    LD HL, (NN)     844d        ;  Load register pair HL with location 0x844d (19844)
7703    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7704    0x22    LD (NN), HL     844d        ;  Load location 0x844d (19844) with the register pair HL
7707    0x2a    LD HL, (NN)     824d        ;  Load register pair HL with location 0x824d (19842)
7710    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7712    0x22    LD (NN), HL     824d        ;  Load location 0x824d (19842) with the register pair HL
7715    0xd0    RET NC                      ;  Return if CARRY flag is 0
7716    0x21    LD HL, NN       844d        ;  Load register pair HL with 0x844d (19844)
7719    0x34    INC (HL)                    ;  Increment location (HL)
7720    0xc3    JP NN           5d1e        ;  Jump to 0x5d1e (7773)
7723    0x3a    LD A, (NN)      aa4d        ;  Load Accumulator with location 0xaa4d (19882)
7726    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7727    0xca    JP Z,           491e        ;  Jump to 0x491e (7753) if ZERO flag is 1
7730    0x2a    LD HL, (NN)     804d        ;  Load register pair HL with location 0x804d (19840)
7733    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7734    0x22    LD (NN), HL     804d        ;  Load location 0x804d (19840) with the register pair HL
7737    0x2a    LD HL, (NN)     7e4d        ;  Load register pair HL with location 0x7e4d (19838)
7740    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7742    0x22    LD (NN), HL     7e4d        ;  Load location 0x7e4d (19838) with the register pair HL
7745    0xd0    RET NC                      ;  Return if CARRY flag is 0
7746    0x21    LD HL, NN       804d        ;  Load register pair HL with 0x804d (19840)
7749    0x34    INC (HL)                    ;  Increment location (HL)
7750    0xc3    JP NN           5d1e        ;  Jump to 0x5d1e (7773)
7753    0x2a    LD HL, (NN)     7c4d        ;  Load register pair HL with location 0x7c4d (19836)
7756    0x29    ADD HL, HL                  ;  Add register pair HL to HL
7757    0x22    LD (NN), HL     7c4d        ;  Load location 0x7c4d (19836) with the register pair HL
7760    0x2a    LD HL, (NN)     7a4d        ;  Load register pair HL with location 0x7a4d (19834)
7763    0xed    ADC HL, HL                  ;  Add with carry register pair HL to HL
7765    0x22    LD (NN), HL     7a4d        ;  Load location 0x7a4d (19834) with the register pair HL
7768    0xd0    RET NC                      ;  Return if CARRY flag is 0
7769    0x21    LD HL, NN       7c4d        ;  Load register pair HL with 0x7c4d (19836)
7772    0x34    INC (HL)                    ;  Increment location (HL)

; if ( $4D1A != 0 )
; {
;     if ( $4D06 & 0x07 != 0x04 ) {  jump_7867();  }
; }
; else
; {
;     if ( $4D07 & 0x07 != 0x04 ) {  jump_7867();  }
; }
7773    0x21    LD HL, NN       1a4d        ;  Load register pair HL with 0x1a4d (19738)
7776    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7777    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7778    0xca    JP Z,           721e        ;  Jump to 0x721e (7794) if ZERO flag is 1
7781    0x3a    LD A, (NN)      064d        ;  Load Accumulator with location 0x064d (19718)
7784    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
7786    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
7788    0xca    JP Z,           7c1e        ;  Jump to 0x7c1e (7804) if ZERO flag is 1
7791    0xc3    JP NN           bb1e        ;  Jump to 0xbb1e (7867)
7794    0x3a    LD A, (NN)      074d        ;  Load Accumulator with location 0x074d (19719)
7797    0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
7799    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
7801    0xc2    JP NZ, NN       bb1e        ;  Jump to 0xbb1e (7867) if ZERO flag is 0

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
7804    0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
7806    0xcd    CALL NN         d01e        ;  Call to 0xd01e (7888)
7809    0x38    JR C, N         1b          ;  Jump to 0x1b (27) if CARRY flag is 1
7811    0x3a    LD A, (NN)      aa4d        ;  Load Accumulator with location 0xaa4d (19882)
7814    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7815    0xca    JP Z,           901e        ;  Jump to 0x901e (7824) if ZERO flag is 1
7818    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0F, 0x00
7821    0xc3    JP NN           9e1e        ;  Jump to 0x9e1e (7838)
7824    0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
7827    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
7830    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7831    0xfe    CP N            1a          ;  Compare 0x1a (26) with Accumulator
7833    0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
7835    0xef    RST 0x28                    ;  Restart to location 0x28 (40) (Reset)
; DATA for RST 0x28 - 0x0B, 0x00
7838    0xcd    CALL NN         731f        ;  Call to 0x731f (8051)
7841    0xdd    LD IX, NN       244d        ;  Load register pair IX with 0x244d (19748)
7845    0xfd    LD IY, NN       104d        ;  Load register pair IY with 0x104d (19728)
; HL = (IY) + (IX);
7849    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
7852    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
7855    0x2a    LD HL, (NN)     244d        ;  Load register pair HL with location 0x244d (19748)
7858    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
7861    0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
7864    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
7867    0xdd    LD IX, NN       1a4d        ;  Load register pair IX with 0x1a4d (19738)
7871    0xfd    LD IY, NN       064d        ;  Load register pair IY with 0x064d (19718)
; HL = (IY) + (IX);
7875    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
7878    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
7881    0xcd    CALL NN         1820        ;  Call to 0x1820 (8216)
7884    0x22    LD (NN), HL     374d        ;  Load location 0x374d (19767) with the register pair HL
7887    0xc9    RET                         ;  Return



; tunnel_warp(ghost=A)  // ghost = {1=red, 2=pink, 3=blue, 4=orange, 5=pacman?}
; HL = $(0x4D09+A*2);    // A = ghost_x;
; if ( $HL == 0x1D ) {  $HL = 0x3D;  set_carry();  return;  }
; if ( $HL == 0x3E ) {  $HL = 0x1E;  set_carry();  return;  }
; if ( $HL < 0x21 ) {  set_carry();  return;  }  // this happens with a 'no carry' subtract... bug?
; if ( $HL > 0x3B ) {  set_carry();  return;  } 
; A &= A;  // why?  probably to clear the carry flag
; return;
7888    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
7889    0x4f    LD c, A                     ;  Load register C with Accumulator
7890    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
7892    0x21    LD HL, NN       094d        ;  Load register pair HL with 0x094d (19721)
7895    0x09    ADD HL, BC                  ;  Add register pair BC to HL
7896    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7897    0xfe    CP N            1d          ;  Compare 0x1d (29) with Accumulator
7899    0xc2    JP NZ, NN       e31e        ;  Jump to 0xe31e (7907) if ZERO flag is 0
7902    0x36    LD (HL), N      3d          ;  Load register pair HL with 0x3d (61)
7904    0xc3    JP NN           fc1e        ;  Jump to 0xfc1e (7932)
7907    0xfe    CP N            3e          ;  Compare 0x3e (62) with Accumulator
7909    0xc2    JP NZ, NN       ed1e        ;  Jump to 0xed1e (7917) if ZERO flag is 0
7912    0x36    LD (HL), N      1e          ;  Load register pair HL with 0x1e (30)
7914    0xc3    JP NN           fc1e        ;  Jump to 0xfc1e (7932)
7917    0x06    LD  B, N        21          ;  Load register B with 0x21 (33)
7919    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
7920    0xda    JP C, NN        fc1e        ;  Jump to 0xfc1e (7932) if CARRY flag is 1
7923    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
7924    0x06    LD  B, N        3b          ;  Load register B with 0x3b (59)
7926    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
7927    0xd2    JP NC, NN       fc1e        ;  Jump to 0xfc1e (7932) if CARRY flag is 0
7930    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
7931    0xc9    RET                         ;  Return
7932    0x37    SCF                         ;  Set CARRY flag
7933    0xc9    RET                         ;  Return


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
7934    0x3a    LD A, (NN)      b14d        ;  Load Accumulator with location 0xb14d (19889)
7937    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7938    0xc8    RET Z                       ;  Return if ZERO flag is 1
7939    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
7940    0x32    LD (NN), A      b14d        ;  Load location 0xb14d (19889) with the Accumulator
7943    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
7946    0x3a    LD A, (NN)      284d        ;  Load Accumulator with location 0x284d (19752)
7949    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
7951    0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
7954    0x47    LD B, A                     ;  Load register B with Accumulator
7955    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
7956    0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
7959    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
7962    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
7964    0xc0    RET NZ                      ;  Return if ZERO flag is 0
7965    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
7968    0x78    LD A, B                     ;  Load Accumulator with register B
7969    0x32    LD (NN), A      284d        ;  Load location 0x284d (19752) with the Accumulator
7972    0xc9    RET                         ;  Return


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
7973    0x3a    LD A, (NN)      b24d        ;  Load Accumulator with location 0xb24d (19890)
7976    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
7977    0xc8    RET Z                       ;  Return if ZERO flag is 1
7978    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
7979    0x32    LD (NN), A      b24d        ;  Load location 0xb24d (19890) with the Accumulator
7982    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
7985    0x3a    LD A, (NN)      294d        ;  Load Accumulator with location 0x294d (19753)
7988    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
7990    0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
7993    0x47    LD B, A                     ;  Load register B with Accumulator
7994    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
7995    0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
7998    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
8001    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
8003    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8004    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
8007    0x78    LD A, B                     ;  Load Accumulator with register B
8008    0x32    LD (NN), A      294d        ;  Load location 0x294d (19753) with the Accumulator
8011    0xc9    RET                         ;  Return


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
8012    0x3a    LD A, (NN)      b34d        ;  Load Accumulator with location 0xb34d (19891)
8015    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8016    0xc8    RET Z                       ;  Return if ZERO flag is 1
8017    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
8018    0x32    LD (NN), A      b34d        ;  Load location 0xb34d (19891) with the Accumulator
8021    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
8024    0x3a    LD A, (NN)      2a4d        ;  Load Accumulator with location 0x2a4d (19754)
8027    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
8029    0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
8032    0x47    LD B, A                     ;  Load register B with Accumulator
8033    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
8034    0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
8037    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
8040    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
8042    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8043    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
8046    0x78    LD A, B                     ;  Load Accumulator with register B
8047    0x32    LD (NN), A      2a4d        ;  Load location 0x2a4d (19754) with the Accumulator
8050    0xc9    RET                         ;  Return


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
8051    0x3a    LD A, (NN)      b44d        ;  Load Accumulator with location 0xb44d (19892)
8054    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8055    0xc8    RET Z                       ;  Return if ZERO flag is 1
8056    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
8057    0x32    LD (NN), A      b44d        ;  Load location 0xb44d (19892) with the Accumulator
8060    0x21    LD HL, NN       ff32        ;  Load register pair HL with 0xff32 (13055)
8063    0x3a    LD A, (NN)      2b4d        ;  Load Accumulator with location 0x2b4d (19755)
8066    0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
8068    0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
8071    0x47    LD B, A                     ;  Load register B with Accumulator
8072    0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
8073    0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
8076    0x3a    LD A, (NN)      024e        ;  Load Accumulator with location 0x024e (19970)
8079    0xfe    CP N            22          ;  Compare 0x22 (34) with Accumulator
8081    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8082    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
8085    0x78    LD A, B                     ;  Load Accumulator with register B
8086    0x32    LD (NN), A      2b4d        ;  Load location 0x2b4d (19755) with the Accumulator
8089    0xc9    RET                         ;  Return


8090    0x00    NOP                         ;  No Operation
8091    0x00    NOP                         ;  No Operation
8092    0x00    NOP                         ;  No Operation
8093    0x00    NOP                         ;  No Operation
8094    0x00    NOP                         ;  No Operation
8095    0x00    NOP                         ;  No Operation
8096    0x00    NOP                         ;  No Operation
8097    0x00    NOP                         ;  No Operation
8098    0x00    NOP                         ;  No Operation
8099    0x00    NOP                         ;  No Operation
8100    0x00    NOP                         ;  No Operation
8101    0x00    NOP                         ;  No Operation
8102    0x00    NOP                         ;  No Operation
8103    0x00    NOP                         ;  No Operation
8104    0x00    NOP                         ;  No Operation
8105    0x00    NOP                         ;  No Operation
8106    0x00    NOP                         ;  No Operation
8107    0x00    NOP                         ;  No Operation
8108    0x00    NOP                         ;  No Operation
8109    0x00    NOP                         ;  No Operation
8110    0x00    NOP                         ;  No Operation
8111    0x00    NOP                         ;  No Operation
8112    0x00    NOP                         ;  No Operation
8113    0x00    NOP                         ;  No Operation
8114    0x00    NOP                         ;  No Operation
8115    0x00    NOP                         ;  No Operation
8116    0x00    NOP                         ;  No Operation
8117    0x00    NOP                         ;  No Operation
8118    0x00    NOP                         ;  No Operation
8119    0x00    NOP                         ;  No Operation
8120    0x00    NOP                         ;  No Operation
8121    0x00    NOP                         ;  No Operation
8122    0x00    NOP                         ;  No Operation
8123    0x00    NOP                         ;  No Operation
8124    0x00    NOP                         ;  No Operation
8125    0x00    NOP                         ;  No Operation
8126    0x00    NOP                         ;  No Operation
8127    0x00    NOP                         ;  No Operation
8128    0x00    NOP                         ;  No Operation
8129    0x00    NOP                         ;  No Operation
8130    0x00    NOP                         ;  No Operation
8131    0x00    NOP                         ;  No Operation
8132    0x00    NOP                         ;  No Operation
8133    0x00    NOP                         ;  No Operation
8134    0x00    NOP                         ;  No Operation
8135    0x00    NOP                         ;  No Operation
8136    0x00    NOP                         ;  No Operation
8137    0x00    NOP                         ;  No Operation
8138    0x00    NOP                         ;  No Operation
8139    0x00    NOP                         ;  No Operation
8140    0x00    NOP                         ;  No Operation
8141    0x00    NOP                         ;  No Operation
8142    0x00    NOP                         ;  No Operation
8143    0x00    NOP                         ;  No Operation
8144    0x00    NOP                         ;  No Operation
8145    0x00    NOP                         ;  No Operation
8146    0x00    NOP                         ;  No Operation
8147    0x00    NOP                         ;  No Operation
8148    0x00    NOP                         ;  No Operation
8149    0x00    NOP                         ;  No Operation
8150    0x00    NOP                         ;  No Operation
8151    0x00    NOP                         ;  No Operation
8152    0x00    NOP                         ;  No Operation
8153    0x00    NOP                         ;  No Operation
8154    0x00    NOP                         ;  No Operation
8155    0x00    NOP                         ;  No Operation
8156    0x00    NOP                         ;  No Operation
8157    0x00    NOP                         ;  No Operation
8158    0x00    NOP                         ;  No Operation
8159    0x00    NOP                         ;  No Operation
8160    0x00    NOP                         ;  No Operation
8161    0x00    NOP                         ;  No Operation
8162    0x00    NOP                         ;  No Operation
8163    0x00    NOP                         ;  No Operation
8164    0x00    NOP                         ;  No Operation
8165    0x00    NOP                         ;  No Operation
8166    0x00    NOP                         ;  No Operation
8167    0x00    NOP                         ;  No Operation
8168    0x00    NOP                         ;  No Operation
8169    0x00    NOP                         ;  No Operation
8170    0x00    NOP                         ;  No Operation
8171    0x00    NOP                         ;  No Operation
8172    0x00    NOP                         ;  No Operation
8173    0x00    NOP                         ;  No Operation

8174    0x00    NOP                         ;  No Operation
8175    0x00    NOP                         ;  No Operation
8176    0x00    NOP                         ;  No Operation
8177    0x00    NOP                         ;  No Operation
8178    0x00    NOP                         ;  No Operation
8179    0x00    NOP                         ;  No Operation
8180    0x00    NOP                         ;  No Operation
8181    0x00    NOP                         ;  No Operation
8182    0x00    NOP                         ;  No Operation
8183    0x00    NOP                         ;  No Operation
8184    0x00    NOP                         ;  No Operation
8185    0x00    NOP                         ;  No Operation
8186    0x00    NOP                         ;  No Operation
8187    0x00    NOP                         ;  No Operation
8188    0x00    NOP                         ;  No Operation
8189    0x00    NOP                         ;  No Operation

; Checksum: 0x5D, 0xE1


; L = (IY) + (IX);  H = (IY + 1) + (IX + 1);
8192    0xfd    LD A, (IY+d)    00          ;  Load Accumulator with location ( IY + 0x00 () )
8195    0xdd    ADD A, (IX+d)   00          ;  Add location ( IX + 0x00 () ) to Accumulator
8198    0x6f    LD L, A                     ;  Load register L with Accumulator
8199    0xfd    LD A, (IY+d)    01          ;  Load Accumulator with location ( IY + 0x01 () )
8202    0xdd    ADD A, (IX+d)   01          ;  Add location ( IX + 0x01 () ) to Accumulator
8205    0x67    LD H, A                     ;  Load register H with Accumulator
8206    0xc9    RET                         ;  Return


;;; HL = get_playfield_byte(IY, IX)
;;; Takes an accumulator and an YX coordinate pair from the pointers in IY and IX,
;;; adds them together, and converts the resulting YX coordinates to a memory location
;;; with YX_to_playfieldaddr() (via 101).  The resulting memory location is stored in HL,
;;; and the value at that location is stored in the Accumulator.

;
; HL = YX_to_playfieldaddr($IY + $IX);  // via call_8192();
; A = $HL;
; return; 
8207    0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
8210    0xcd    CALL NN         6500        ;  Call to 0x6500 (101)
8213    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
; clear flags
8214    0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
8215    0xc9    RET                         ;  Return


; L = ( L >> 3 ) + 0x20;
; H = ( H >> 3 ) + 0x1E;
; return;
8216    0x7d    LD A, L                     ;  Load Accumulator with register L
8217    0xcb    SRL A                       ;  Shift Accumulator right logical
8219    0xcb    SRL A                       ;  Shift Accumulator right logical
8221    0xcb    SRL A                       ;  Shift Accumulator right logical
8223    0xc6    ADD A, N        20          ;  Add 0x20 (32) to Accumulator (no carry)
8225    0x6f    LD L, A                     ;  Load register L with Accumulator
8226    0x7c    LD A, H                     ;  Load Accumulator with register H
8227    0xcb    SRL A                       ;  Shift Accumulator right logical
8229    0xcb    SRL A                       ;  Shift Accumulator right logical
8231    0xcb    SRL A                       ;  Shift Accumulator right logical
8233    0xc6    ADD A, N        1e          ;  Add 0x1e (30) to Accumulator (no carry)
8235    0x67    LD H, A                     ;  Load register H with Accumulator
8236    0xc9    RET                         ;  Return



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

8237    0xf5    PUSH AF                     ;  Load the stack with register pair AF
8238    0xc5    PUSH BC                     ;  Load the stack with register pair BC
8239    0x7d    LD A, L                     ;  Load Accumulator with register L
8240    0xd6    SUB N           20          ;  Subtract 0x20 (32) from Accumulator (no carry)
8242    0x6f    LD L, A                     ;  Load register L with Accumulator
8243    0x7c    LD A, H                     ;  Load Accumulator with register H
8244    0xd6    SUB N           20          ;  Subtract 0x20 (32) from Accumulator (no carry)
8246    0x67    LD H, A                     ;  Load register H with Accumulator
8247    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
8249    0xcb24  SLA H                       ;  Shift left-arithmetic register H
8251    0xcb24  SLA H                       ;  Shift left-arithmetic register H
8253    0xcb24  SLA H                       ;  Shift left-arithmetic register H
8255    0xcb24  SLA H                       ;  Shift left-arithmetic register H
8257    0xcb10  RL B                        ;  Rotate left through carry register B
8259    0xcb24  SLA H                       ;  Shift left-arithmetic register H
8261    0xcb10  RL B                        ;  Rotate left through carry register B
8263    0x4c    LD C, H                     ;  Load register C with register H
8264    0x26    LD H, N         00          ;  Load register H with 0x00 (0)
8266    0x09    ADD HL, BC                  ;  Add register pair BC to HL
8267    0x01    LD  BC, NN      4040        ;  Load register pair BC with 0x4040 (16448)
8270    0x09    ADD HL, BC                  ;  Add register pair BC to HL
8271    0xc1    POP BC                      ;  Load register pair BC with top of stack
8272    0xf1    POP AF                      ;  Load register pair AF with top of stack
8273    0xc9    RET                         ;  Return


;;; YX_to_playfield_addr_plus4() // via call_101() -> jump_8237()
;;; See YX_to_playfield_addr() above.
8274    0xcd    CALL NN         6500        ;  Call to 0x6500 (101)
8277    0x11    LD  DE, NN      0004        ;  Load register pair DE with 0x0004 (0)
8280    0x19    ADD HL, DE                  ;  Add register pair DE to HL
8281    0xc9    RET                         ;  Return


;;; $BC = ( YX_to_playfieldaddr_plus4() == 0x1B ) ? 0x01 : 0x00;

; YX_to_playfield_addr_plus4(HL)
; A = $HL;
; if ( $HL == 0x1B ) {  $BC = 0x01;  }
;               else {  $BC = 0x01;  }
; return;

8282    0xcd    CALL NN         5220        ;  Call to 0x5220 (8274)
8285    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
8286    0xfe    CP N            1b          ;  Compare 0x1b (27) with Accumulator
;; 8288-8295 : On Ms. Pac-Man patched in from $8148-$814F
;; On Ms. Pac-Man:
;; 8288  $2060   0xc3    JP nn           6f36        ;  Jump to $nn
;; 8291  $2063   0x00    NOP                         ;  NOP
8288    0x20    JR NZ, N        04          ;  Jump relative 0x04 (4) if ZERO flag is 0
8290    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
8292    0x02    LD  (BC), A                 ;  Load location (BC) with the Accumulator
8293    0xc9    RET                         ;  Return
8294    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
8295    0x02    LD  (BC), A                 ;  Load location (BC) with the Accumulator
8296    0xc9    RET                         ;  Return


;; if ( $4DA1 != 0 ) {  return;  }
;; if ( $4E12 != 0 )
;; {
;;     if ( $4D9F != 0x07 ) {  return;  }
;;     if ( $4D9F == 0x07 ) {  $4DA1 = 2;  return;  }
;; }
;; if ( $4E0F < $4DB8 ) {  return;  }
;; $4DA1 = 2;  return;
8297    0x3a    LD A, (NN)      a14d        ;  Load Accumulator with location 0xa14d (19873)
8300    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8301    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8302    0x3a    LD A, (NN)      124e        ;  Load Accumulator with location 0x124e (19986)
8305    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8306    0xca    JP Z,           7e20        ;  Jump to 0x7e20 (8318) if ZERO flag is 1
8309    0x3a    LD A, (NN)      9f4d        ;  Load Accumulator with location 0x9f4d (19871)
8312    0xfe    CP N            07          ;  Compare 0x07 (7) with Accumulator
8314    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8315    0xc3    JP NN           8620        ;  Jump to 0x8620 (8326)
8318    0x21    LD HL, NN       b84d        ;  Load register pair HL with 0xb84d (19896)
8321    0x3a    LD A, (NN)      0f4e        ;  Load Accumulator with location 0x0f4e (19983)
8324    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
8325    0xd8    RET C                       ;  Return if CARRY flag is 1
8326    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
8328    0x32    LD (NN), A      a14d        ;  Load location 0xa14d (19873) with the Accumulator
8331    0xc9    RET                         ;  Return


;; if ( $4DA2 != 0 ) {  return;  }
;; if ( $4E12 != 0 )  
;; {
;;     if ( $4D9F != 0x11 ) {  return;  }
;;     if ( $4D9F == 0x11 ) {  $4DA2 = 3;  return;  }
;; }
;; if ( $4E10 < $4DB9 ) {  return;  }
;; $4DA2 = 3;  return;
8332    0x3a    LD A, (NN)      a24d        ;  Load Accumulator with location 0xa24d (19874)
8335    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8336    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8337    0x3a    LD A, (NN)      124e        ;  Load Accumulator with location 0x124e (19986)
8340    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8341    0xca    JP Z,           a120        ;  Jump to 0xa120 (8353) if ZERO flag is 1
8344    0x3a    LD A, (NN)      9f4d        ;  Load Accumulator with location 0x9f4d (19871)
8347    0xfe    CP N            11          ;  Compare 0x11 (17) with Accumulator
8349    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8350    0xc3    JP NN           a920        ;  Jump to 0xa920 (8361)
8353    0x21    LD HL, NN       b94d        ;  Load register pair HL with 0xb94d (19897)
8356    0x3a    LD A, (NN)      104e        ;  Load Accumulator with location 0x104e (19984)
8359    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
8360    0xd8    RET C                       ;  Return if CARRY flag is 1
8361    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
8363    0x32    LD (NN), A      a24d        ;  Load location 0xa24d (19874) with the Accumulator
8366    0xc9    RET                         ;  Return


;; if ( $4DA3 != 0 ) {  return;  }
;; if ( $4E12 != 0 )
;; {
;;     if ( $4D9F != 0x20 ) {  return;  }
;;     if ( $4D9F == 0x20 ) {  $4E12 = $4D9F = 0;  return;  }
;; }
;; if ( $4E11 < $4DBA ) {  return;  }
;; $4DA3 = 3;  return;
8367    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
8370    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8371    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8372    0x3a    LD A, (NN)      124e        ;  Load Accumulator with location 0x124e (19986)
8375    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8376    0xca    JP Z,           c920        ;  Jump to 0xc920 (8393) if ZERO flag is 1
8379    0x3a    LD A, (NN)      9f4d        ;  Load Accumulator with location 0x9f4d (19871)
8382    0xfe    CP N            20          ;  Compare 0x20 (32) with Accumulator
8384    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8385    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
8386    0x32    LD (NN), A      124e        ;  Load location 0x124e (19986) with the Accumulator
8389    0x32    LD (NN), A      9f4d        ;  Load location 0x9f4d (19871) with the Accumulator
8392    0xc9    RET                         ;  Return
8393    0x21    LD HL, NN       ba4d        ;  Load register pair HL with 0xba4d (19898)
8396    0x3a    LD A, (NN)      114e        ;  Load Accumulator with location 0x114e (19985)
8399    0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
8400    0xd8    RET C                       ;  Return if CARRY flag is 1
8401    0x3e    LD A,N          03          ;  Load Accumulator with 0x03 (3)
8403    0x32    LD (NN), A      a34d        ;  Load location 0xa34d (19875) with the Accumulator
8406    0xc9    RET                         ;  Return


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

8407    0x3a    LD A, (NN)      a34d        ;  Load Accumulator with location 0xa34d (19875)
8410    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8411    0xc8    RET Z                       ;  Return if ZERO flag is 1
8412    0x21    LD HL, NN       0e4e        ;  Load register pair HL with 0x0e4e (19982)
8415    0x3a    LD A, (NN)      b64d        ;  Load Accumulator with location 0xb64d (19894)
8418    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8419    0xc2    JP NZ, NN       f420        ;  Jump to 0xf420 (8436) if ZERO flag is 0
8422    0x3e    LD A,N          f4          ;  Load Accumulator with 0xf4 (244)
8424    0x96    SUB A, (HL)                 ;  Subtract location (HL) from Accumulator (no carry)
8425    0x47    LD B, A                     ;  Load register B with Accumulator
8426    0x3a    LD A, (NN)      bb4d        ;  Load Accumulator with location 0xbb4d (19899)
8429    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
8430    0xd8    RET C                       ;  Return if CARRY flag is 1
8431    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
8433    0x32    LD (NN), A      b64d        ;  Load location 0xb64d (19894) with the Accumulator
8436    0x3a    LD A, (NN)      b74d        ;  Load Accumulator with location 0xb74d (19895)
8439    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
8440    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8441    0x3e    LD A,N          f4          ;  Load Accumulator with 0xf4 (244)
8443    0x96    SUB A, (HL)                 ;  Subtract location (HL) from Accumulator (no carry)
8444    0x47    LD B, A                     ;  Load register B with Accumulator
8445    0x3a    LD A, (NN)      bc4d        ;  Load Accumulator with location 0xbc4d (19900)
8448    0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
8449    0xd8    RET C                       ;  Return if CARRY flag is 1
8450    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
8452    0x32    LD (NN), A      b74d        ;  Load location 0xb74d (19895) with the Accumulator
8455    0xc9    RET                         ;  Return

;; rst_20($4E06);  // Act I Scenes
;; 8456-8463 : On Ms. Pac-Man patched in from $8018-$801F
;; On Ms. Pac-Man:
;; 8456  $2108   0xc3    JP nn           3534        ;  Jump to $nn

8456    0x3a    LD A, (NN)      064e        ;  Load Accumulator with location 0x064e (19974)
8459    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
8474    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
8477    0xd6    SUB N           21          ;  Subtract 0x21 (33) from Accumulator (no carry)
8479    0x20    JR NZ, N        0f          ;  Jump relative 0x0f (15) if ZERO flag is 0
8481    0x3c    INC A                       ;  Increment Accumulator
8482    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
8485    0x32    LD (NN), A      b74d        ;  Load location 0xb74d (19895) with the Accumulator
8488    0xcd    CALL NN         0605        ;  Call to 0x0605 (1286)
8491    0x21    LD HL, NN       064e        ;  Load register pair HL with 0x064e (19974)
8494    0x34    INC (HL)                    ;  Increment location (HL)
8495    0xc9    RET                         ;  Return
8496    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
8499    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
8502    0xcd    CALL NN         361b        ;  Call to 0x361b (6966)
8505    0xcd    CALL NN         361b        ;  Call to 0x361b (6966)
8508    0xcd    CALL NN         230e        ;  Call to 0x230e (3619)
8511    0xc9    RET                         ;  Return


;; if ( $4D3A != 0x1E ) {  jump_8496();  } else {  jump_8491();  }
8512    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
8515    0xd6    SUB N           1e          ;  Subtract 0x1e (30) from Accumulator (no carry)
8517    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
8520    0xc3    JP NN           2b21        ;  Jump to 0x2b21 (8491)


;; if ( $4D32 != 0x1E ) {  jump_8502();  }
;; call_6768();
;; $4EAC = $4EBC = 0;
;; call_1445();
;; $4D1C = HL;  // HL after call_1445() is the opposite direction "incrementor" from the index at $4D30
;; $4D30 = $4D3C;
;; rst_30(0x45, 0x07, 0x00);
;; jump_8491();
8523    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
8526    0xd6    SUB N           1e          ;  Subtract 0x1e (30) from Accumulator (no carry)
8528    0xc2    JP NZ, NN       3621        ;  Jump to 0x3621 (8502) if ZERO flag is 0
8531    0xcd    CALL NN         701a        ;  Call to 0x701a (6768)
8534    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
8535    0x32    LD (NN), A      ac4e        ;  Load location 0xac4e (20140) with the Accumulator
8538    0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator
8541    0xcd    CALL NN         a505        ;  Call to 0xa505 (1445)
8544    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
8547    0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
8550    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
8553    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x45, 0x07, 0x00 - (something to do with Act I)
8557    0xc3    JP NN           2b21        ;  Jump to 0x2b21 (8491)


;; if ( $4D32 != 0x2F ) {  jump_8502();  } else {  jump_8491();  }
8560    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
8563    0xd6    SUB N           2f          ;  Subtract 0x2f (47) from Accumulator (no carry)
8565    0xc2    JP NZ, NN       3621        ;  Jump to 0x3621 (8502) if ZERO flag is 0
8568    0xc3    JP NN           2b21        ;  Jump to 0x2b21 (8491)


;; if ( $4D32 != 0x61 ) {  jump_8496();  } else {  jump_8491();  }
8571    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
8574    0xd6    SUB N           3d          ;  Subtract 0x3d (61) from Accumulator (no carry)
8576    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
8579    0xc3    JP NN           2b21        ;  Jump to 0x2b21 (8491)


;; call(6150);  call(6150);
;; if ( $4D3A != 0x3D ) {  return;  }
;; $4D06 = 0x00;
;; rst_30(0x45, 0x00, 0x00);
;; $HL++;
;; return;
8582    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
8585    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
8588    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
8591    0xd6    SUB N           3d          ;  Subtract 0x3d (61) from Accumulator (no carry)
8593    0xc0    RET NZ                      ;  Return if ZERO flag is 0
8594    0x32    LD (NN), A      064e        ;  Load location 0x064e (19974) with the Accumulator
8597    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x45, 0x00, 0x00
8601    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
8604    0x34    INC (HL)                    ;  Increment location (HL)
8605    0xc9    RET                         ;  Return


;; A = $4E07;  // Act II Scenes
;; IY = $41D2;
;; rst_20();
8606    0x3a    LD A, (NN)      074e        ;  Load Accumulator with location 0x074e (19975)
;; 8608-8615 : On Ms. Pac-Man patched in from $81A0-$81A7
;; On Ms. Pac-Man:
;; 8609  $21a1   0xc3    JP nn           4f34        ;  Jump to $nn
8609    0xfd    LD IY, NN       d241        ;  Load register pair IY with 0xd241 (16850)
8613    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
8642    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
8644    0x32    LD (NN), A      d245        ;  Load location 0xd245 (17874) with the Accumulator
8647    0x32    LD (NN), A      d345        ;  Load location 0xd345 (17875) with the Accumulator
8650    0x32    LD (NN), A      f245        ;  Load location 0xf245 (17906) with the Accumulator
8653    0x32    LD (NN), A      f345        ;  Load location 0xf345 (17907) with the Accumulator
8656    0xcd    CALL NN         0605        ;  Call to 0x0605 (1286)

; $IY = 0x60;  $(IY+1) = 0x61;  // IY *was* 0x41D2
; rst_30(0x43, 0x08, 0x00);
; $4E07++;  // Act II Scenes
; return;  // this is due to a jump_rel(15);
8659    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x60 ()
8663    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x61 ()
8667    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x43, 0x08, 0x00 - (something to do with Act II)
8671    0x18    JR N            0f          ;  Jump relative 0x0f (15)


; if ( $4D3A != 44 ) {  jump_8496();  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; $4DA0 = $4DB7 = 1;
; $4E07++;  // Act II Scenes
; return;
8673    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
8676    0xd6    SUB N           2c          ;  Subtract 0x2c (44) from Accumulator (no carry)
8678    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
8681    0x3c    INC A                       ;  Increment Accumulator
8682    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
8685    0x32    LD (NN), A      b74d        ;  Load location 0xb74d (19895) with the Accumulator
8688    0x21    LD HL, NN       074e        ;  Load register pair HL with 0x074e (19975)
8691    0x34    INC (HL)                    ;  Increment location (HL)
8692    0xc9    RET                         ;  Return


; if ( $4D01 != 0x77 && $4D01 != 0x78 ) {  jump_8496();  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; $4D4E = $4D50 = 0x2084;
; $4E07++;  // via a jump_rel(-28);  // Act II Scenes
; return;
8693    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
8696    0xfe    CP N            77          ;  Compare 0x77 (119) with Accumulator
8698    0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
8700    0xfe    CP N            78          ;  Compare 0x78 (120) with Accumulator
8702    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
8705    0x21    LD HL, NN       8420        ;  Load register pair HL with 0x8420 (8324)
8708    0x22    LD (NN), HL     4e4d        ;  Load location 0x4e4d (19790) with the register pair HL
8711    0x22    LD (NN), HL     504d        ;  Load location 0x504d (19792) with the register pair HL
8714    0x18    JR N            e4          ;  Jump relative 0xe4 (-28)


; if ( $4D01 == 0x78 )
; {
;     $IY = 0x62;  $(IY+1) = 0x63; // IY *was* 0x41D2
;     $4E07++;  // via a jump_rel(-46);  // Act II Scenes
;     return;
; }
; else {  jump_8759();  }  // call_6150();  call_6150();  call_6966();  call_3619();  return;
8716    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
8719    0xd6    SUB N           78          ;  Subtract 0x78 (120) from Accumulator (no carry)
8721    0xc2    JP NZ, NN       3722        ;  Jump to 0x3722 (8759) if ZERO flag is 0
8724    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x62 ()
8728    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x63 ()
8732    0x18    JR N            d2          ;  Jump relative 0xd2 (-46)


; if ( $4D01 == 123 )
; {
;     $IY = 0x64;  $(IY+1) = 0x65; // IY *was* 0x41D2
;     $(IY+32) = 0x66;  $(IY+33) = 0x67;
;     $4E07++;  // via a jump_rel(-71);  // Act II Scenes
;     return;
; }
8734    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
8737    0xd6    SUB N           7b          ;  Subtract 0x7b (123) from Accumulator (no carry)
8739    0x20    JR NZ, N        12          ;  Jump relative 0x12 (18) if ZERO flag is 0
8741    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x64 ()
8745    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x65 ()
8749    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x20 () ) with 0x66 ()
8753    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x21 () ) with 0x67 ()
8757    0x18    JR N            b9          ;  Jump relative 0xb9 (-71)


; call_6150();  call_6150();
; call_6966();
; call_3619();
; return;
8759    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
8762    0xcd    CALL NN         0618        ;  Call to 0x0618 (6150)
8765    0xcd    CALL NN         361b        ;  Call to 0x361b (6966)
8768    0xcd    CALL NN         230e        ;  Call to 0x230e (3619)
8771    0xc9    RET                         ;  Return


; if ( $4D01 != 126 ) {  jump_rel(-20);  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; else
; {
;     $IY = 0x68;  $(IY+1) = 0x69; // IY *was* 0x41D2
;     $(IY+32) = 0x6A;  $(IY+33) = 0x6B;
;     $4E07++;  // via a jump_rel(-109);  // Act II Scenes
;     return;
; }
8772    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
8775    0xd6    SUB N           7e          ;  Subtract 0x7e (126) from Accumulator (no carry)
8777    0x20    JR NZ, N        ec          ;  Jump relative 0xec (-20) if ZERO flag is 0
8779    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x68 ()
8783    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x69 ()
8787    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x20 () ) with 0x6a ()
8791    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x21 () ) with 0x6b ()
8795    0x18    JR N            93          ;  Jump relative 0x93 (-109)


; if ( $4D01 != 128 ) {  jump_rel(-45);  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; rst_30(0x4F, 0x08, 0x00);
; $4E07++;  return;  // this is due to a jump_rel(-122);  // Act II Scenes
8797    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
8800    0xd6    SUB N           80          ;  Subtract 0x80 (128) from Accumulator (no carry)
8802    0x20    JR NZ, N        d3          ;  Jump relative 0xd3 (-45) if ZERO flag is 0
8804    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4F, 0x08, 0x00 - (something to do with Act II)
8808    0x18    JR N            86          ;  Jump relative 0x86 (-122)


; $4D01 += 2;
; $IY = 0x6C;  $(IY+1) = 0x6D; // IY *was* 0x41D2
; $(IY+32) = 0x40;  $(IY+33) = 0x40;
; rst_30(0x4A, 0x08, 0x00);
; $4E07++;  // Act II Scenes
; return;  // via jump(8688);
8810    0x21    LD HL, NN       014d        ;  Load register pair HL with 0x014d (19713)
8813    0x34    INC (HL)                    ;  Increment location (HL)
8814    0x34    INC (HL)                    ;  Increment location (HL)
8815    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x6c ()
8819    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x6d ()
8823    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x20 () ) with 0x40 ()
8827    0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x21 () ) with 0x40 ()
8831    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4A, 0x08, 0x00 - (something to do with Act II)
8835    0xc3    JP NN           f021        ;  Jump to 0xf021 (8688)


; rst_30(0x54, 0x08, 0x00);
; $4E07++;  // Act II Scenes
; return;  // via jump(8688);
8838    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x54, 0x08, 0x00 - (something to do with Act II)
8842    0xc3    JP NN           f021        ;  Jump to 0xf021 (8688)


; $4E07 = 0;   // Act II scenes
; $4E04 += 2;  // Game 'frames'
; return;
8845    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
8846    0x32    LD (NN), A      074e        ;  Load location 0x074e (19975) with the Accumulator
8849    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
8852    0x34    INC (HL)                    ;  Increment location (HL)
8853    0x34    INC (HL)                    ;  Increment location (HL)
8854    0xc9    RET                         ;  Return


; rst_20($4E08);  // Act III Scenes
8855    0x3a    LD A, (NN)      084e        ;  Load Accumulator with location 0x084e (19976)
;; 8856-8863 : On Ms. Pac-Man patched in from $80A0-$80A7
;; On Ms. Pac-Man:
;; 8858  $229a   0xc3    JP nn           6934        ;  Jump to $nn
8858    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
8871    0x3a    LD A, (NN)      3a4d        ;  Load Accumulator with location 0x3a4d (19770)
8874    0xd6    SUB N           25          ;  Subtract 0x25 (37) from Accumulator (no carry)
8876    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
8879    0x3c    INC A                       ;  Increment Accumulator
8880    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
8883    0x32    LD (NN), A      b74d        ;  Load location 0xb74d (19895) with the Accumulator
8886    0xcd    CALL NN         0605        ;  Call to 0x0605 (1286)
8889    0x21    LD HL, NN       084e        ;  Load register pair HL with 0x084e (19976)
8892    0x34    INC (HL)                    ;  Increment location (HL)
8893    0xc9    RET                         ;  Return


; if ( $4D01 != 0xFF && $4D01 != 0xFE ) {  jump_8496();  }  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
; $4D01 = 2;
; $4DB1 = 1;
; call_7934();
; rst_30(0x4A, 0x09, 0x00);
; $4E08++;  // via a jump_rel(-36);  // Act III Scenes
; return;
8894    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
8897    0xfe    CP N            ff          ;  Compare 0xff (255) with Accumulator
8899    0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
8901    0xfe    CP N            fe          ;  Compare 0xfe (254) with Accumulator
8903    0xc2    JP NZ, NN       3021        ;  Jump to 0x3021 (8496) if ZERO flag is 0
8906    0x3c    INC A                       ;  Increment Accumulator
8907    0x3c    INC A                       ;  Increment Accumulator
8908    0x32    LD (NN), A      014d        ;  Load location 0x014d (19713) with the Accumulator
8911    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
8913    0x32    LD (NN), A      b14d        ;  Load location 0xb14d (19889) with the Accumulator
8916    0xcd    CALL NN         fe1e        ;  Call to 0xfe1e (7934)
8919    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x4A, 0x09, 0x00 - (something to do with Act III)
8923    0x18    JR N            dc          ;  Jump relative 0xdc (-36)


; if ( $4D32 == 0x2D )
; {
;     $4E08++;  // via a jump_rel(-43);  // Act III Scenes
;     return;
; }
; 
; $4DD2 = $4D00;
; $4DD3 = $4D01 - 8;
; jump(8496);  // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;
8925    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
8928    0xd6    SUB N           2d          ;  Subtract 0x2d (45) from Accumulator (no carry)
8930    0x28    JR Z, N         d5          ;  Jump relative 0xd5 (-43) if ZERO flag is 1
8932    0x3a    LD A, (NN)      004d        ;  Load Accumulator with location 0x004d (19712)
8935    0x32    LD (NN), A      d24d        ;  Load location 0xd24d (19922) with the Accumulator
8938    0x3a    LD A, (NN)      014d        ;  Load Accumulator with location 0x014d (19713)
8941    0xd6    SUB N           08          ;  Subtract 0x08 (8) from Accumulator (no carry)
8943    0x32    LD (NN), A      d34d        ;  Load location 0xd34d (19923) with the Accumulator
8946    0xc3    JP NN           3021        ;  Jump to 0x3021 (8496)


; if ( $4D32 == 0x1E ) {  $4E08++;  return;  }  // via a jump_rel(-43);  // Act III Scenes
;                 else {  $4DD2 = $4D00;  $4DD3 = $4D01 - 8;  jump(8496);  }
;                        // call(6150);  call(6150);  call(6966);  call(6966);  call(3619);  return;  // via jump_rel(-26);
8949    0x3a    LD A, (NN)      324d        ;  Load Accumulator with location 0x324d (19762)
8952    0xd6    SUB N           1e          ;  Subtract 0x1e (30) from Accumulator (no carry)
8954    0x28    JR Z, N         bd          ;  Jump relative 0xbd (-67) if ZERO flag is 1
8956    0x18    JR N            e6          ;  Jump relative 0xe6 (-26)


; $4E08 = 0;  // Act III Scenes;
; rst_30(0x45, 0x00, 0x00);
; $4E04++;
; return;
8958    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
8959    0x32    LD (NN), A      084e        ;  Load location 0x084e (19976) with the Accumulator
8962    0xf7    RST 0x30                    ;  Restart to location 0x30 (48) (Reset)
; DATA for RST 0x30 - 0x45, 0x00, 0x00
8966    0x21    LD HL, NN       044e        ;  Load register pair HL with 0x044e (19972)
8969    0x34    INC (HL)                    ;  Increment location (HL)
8970    0xc9    RET                         ;  Return


;;; boot()
; Clear Memory Mapped Hardware I/O from 0x5000 - 0x5008 with 0x00
;
; for(i=0; i>8; i++)
; {
;     *(0x5000 + i) == 0;
; }
8971    0x21    LD HL, NN       0050        ;  Load register pair HL with 0x0050 (20480)
8974    0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
8976    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
8977    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
8978    0x2c    INC L                       ;  Increment register L
8979    0x10    DJNZ N          fc          ;  Decrement B and jump relative 0xfc (-4) if B!=0

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
8981    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
8984    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
; Watchdog set to 0 first time through, then 64 2nd, 3rd, 4th times
8986    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; Coin Counter set to 0 first time through, then 64 2nd, 3rd, 4th times
8989    0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
8992    0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
8994    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
8995    0x2c    INC L                       ;  Increment register L
8996    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
8998    0x24    INC H                       ;  Increment register H
8999    0x10    DJNZ N          f1          ;  Decrement B and jump relative 0xf1 (-15) if B!=0

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
9001    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
; Watchdog set to 64, then 15
9003    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
9006    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
; Coin Counter set to 00
9007    0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
9010    0x3e    LD A,N          0f          ;  Load Accumulator with 0x0f (15)
9012    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
9013    0x2c    INC L                       ;  Increment register L
9014    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
9016    0x24    INC H                       ;  Increment register H
9017    0x10    DJNZ N          f0          ;  Decrement B and jump relative 0xf0 (-16) if B!=0

; Set up our interrupt handling scheme
; This sets up interrupt mode 2 (byte on int bus=index into interrupt vector table)
; and configures the external interrupt generator so that each V-Sync drops a value of
; 0xFA (250) onto the interrupt bus.  Since I is set to 0x3F (63), V-Sync calls the
; routine at the address at the location 0x3FFA (16378), which is 0x0030 (48).
; Summary : after this, the routine at 0x0030 (RST 30) is called 60 times a sec.
; Interrupt mode 2 means that the byte on the bus is an index into the 256b page pointed to by I
9019    0xed    IM 2                        ;  Set interrupt mode 2
; Program the V-Sync interrupt with byte 0xFA (interrupt vector index 250)
9021    0x3e    LD A,N          fa          ;  Load Accumulator with 0xfa (250)
9023    0xd3    OUT (N),A       00          ;  Load output port 0x00 (0) with Accumulator
; Coin Counter set to 00
9025    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
9026    0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
; Enable external interrupt generator
9029    0x3c    INC A                       ;  Increment Accumulator
9030    0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
9033    0xfb    EI                          ;  Enable Interrupts

; Stop here and wait for the next interrupt
9034    0x76    HALT                        ;  HALT



;;; clear_memory()
; Watchdog set to 0x00, set up stack at 0x4FC0
9035    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
9038    0x31    LD SP, NN       c04f        ;  Load register pair SP with 0xc04f (20416)
9041    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator

; Write 0x00 to 0x5000...0x5007
; ( Int enable, sound enable, ????, flip screen, player 1 lamp, player 2 lamp, coin lockout, coin counter )
9042    0x21    LD HL, NN       0050        ;  Load register pair HL with 0x0050 (20480)
9045    0x01    LD  BC, NN      0808        ;  Load register pair BC with 0x0808 (2056)
9048    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x4C00...0x4CBD
; First 190 bytes of RAM
9049    0x21    LD HL, NN       004c        ;  Load register pair HL with 0x004c (19456)
9052    0x06    LD  B, N        be          ;  Load register B with 0xbe (190)
9054    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x4CBE...0x4DBD ???
; Next 256 bytes of RAM
9055    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x4DBE...0x4EBD ???
; Next 256 bytes of RAM
9056    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x4EBE...0x4FBD ???
;Next 256 bytes of RAM
9057    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Write 0x00 to 0x5040...0x507F ???
; Next 256 bytes of RAM
9058    0x21    LD HL, NN       4050        ;  Load register pair HL with 0x4050 (20544)
9061    0x06    LD  B, N        40          ;  Load register B with 0x40 (64)
9063    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Watchdog set to 0x00
9064    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; Clear Video Color RAM
9067    0xcd    CALL NN         0d24        ;  Call to 0x0d24 (9229)

; Watchdog set to 0x00
9070    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
9073    0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
9075    0xcd    CALL NN         ed23        ;  Call to 0xed23 (9197) [Clear Sprite Mem With Spaces]

; Watchdog set to 0x40
9078    0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator

; Put 0x4CC0 into 0x4C80 and 0x4C82
; Fill 0x4CC0-0x4D00 with 0xFF
9081    0x21    LD HL, NN       c04c        ;  Load register pair HL with 0xc04c (19648)
9084    0x22    LD (NN), HL     804c        ;  Load location 0x804c (19584) with the register pair HL
9087    0x22    LD (NN), HL     824c        ;  Load location 0x824c (19586) with the register pair HL
9090    0x3e    LD A,N          ff          ;  Load Accumulator with 0xff (255)
9092    0x06    LD  B, N        40          ;  Load register B with 0x40 (64)
9094    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)

; Enable V-Sync interrupt circuitry, enable interrupts on CPU
9095    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
9097    0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
9100    0xfb    EI                          ;  Enable Interrupts


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
9101    0x2a    LD HL, (NN)     824c        ;  Load register pair HL with location 0x824c (19586)
9104    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
9105    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
9106    0xfa    JP M, NN        8d23        ;  Jump to 0x8d23 (9101) if SIGN flag is 1 (Negative)
; A == index of routine to jump to
9109    0x36    LD (HL), N      ff          ;  Load location (HL) with 0xff (255)
9111    0x2c    INC L                       ;  Increment register L
; B == param for routine
9112    0x46    LD B, (HL)                  ;  Load register B with location (HL)
9113    0x36    LD (HL), N      ff          ;  Load location (HL) with 0xff (255)
9115    0x2c    INC L                       ;  Increment register L
; Wrap address at 0x4C82 back to 0x4CC0 if it hits 0x4D00
9116    0x20    JR NZ, N        02          ;  Jump relative 0x02 (2) if ZERO flag is 0
9118    0x2e    LD L,N          c0          ;  Load register L with 0xc0 (192)
9120    0x22    LD (NN), HL     824c        ;  Load location 0x824c (19586) with the register pair HL
; load stack backtrace with 'watcher'
9123    0x21    LD HL, NN       8d23        ;  Load register pair HL with 0x8d23 (9101)
9126    0xe5    PUSH HL                     ;  Load the stack with register pair HL
; Call our routine
9127    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)

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
9192    0x21    LD HL, NN       044E        ;  Load register pair HL with 0x4E04 (19972)
9195    0x34    INC (HL)                    ;  Increment location (HL)
9196    0xc9    RET                         ;  Return


; clear()
;  -- Clear Screen
;  Branch based on the value of A (see rst 20)
;  A = 0 : Clear entire screen
;  A = 1 : Clear playing field only
9197    0x78    LD A, B                     ;  Load Accumulator with register B
9198    0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
; 0 : $23F3 - clear_sprite()
; 1 : $2400 - clear_sprite_playfield()

; clear_sprite()
; Fill 0x4000-0x43FF (Video RAM) with 0x40 (space)
; Pacman family boards use quasi-ascii, notable difference is 0x40 == <space>
; clear all of screen
9203    0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
9205    0x01    LD  BC, NN      0400        ;  Load register pair BC with 0x0400 (4)
9208    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
9211    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
9212    0x0d    DEC C                       ;  Decrement register C
9213    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is not 0
9215    0xc9    RET                         ;  Return

; clear_sprite_playfield()
; Fill 0x4040-0x43BF (Video RAM) with 0x40 (space)
; Pacman family boards use quasi-ascii, notable difference is 0x40 == <space>
; clear the playing field, leave score fields intact
9216    0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
9218    0x21    LD HL, NN       4040        ;  Load register pair HL with 0x4040 (16448)
9221    0x01    LD  BC, NN      0480        ;  Load register pair BC with 0x0480 (32772)
9224    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
9225    0x0d    DEC C                       ;  Decrement register C
9226    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is not 0
9228    0xc9    RET                         ;  Return

; clear_color()
; Write 0x00 to 0x4400...0x47ff
; Clear Video Color RAM
9229    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
9230    0x01    LD  BC, NN      0400        ;  Load register pair BC with 0x0400 (4)
9233    0x21    LD HL, NN       0044        ;  Load register pair HL with 0x0044 (17408)
9236    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
9237    0x0d    DEC C                       ;  Decrement register C
9238    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is not 0
9240    0xc9    RET                         ;  Return


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
9241    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
9244    0x01    LD  BC, NN      3534        ;  Load register pair BC with 0x3534 (13365)
9247    0x0a    LD  A, (BC)                 ;  Load Accumulator with location (BC)
9248    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
9249    0xc8    RET Z                       ;  Return if ZERO flag is 1
9250    0xfa    JP M, NN        2c24        ;  Jump to 0x2c24 (9260) if SIGN flag is 1 (Negative)
9253    0x5f    LD E, A                     ;  Load register E with Accumulator
9254    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
9256    0x19    ADD HL, DE                  ;  Add register pair DE to HL
9257    0x2b    DEC HL                      ;  Decrement register pair HL
9258    0x03    INC BC                      ;  Increment register pair BC
9259    0x0a    LD  A, (BC)                 ;  Load Accumulator with location (BC)
9260    0x23    INC HL                      ;  Increment register pair HL
9261    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
9262    0xf5    PUSH AF                     ;  Load the stack with register pair AF
9263    0xe5    PUSH HL                     ;  Load the stack with register pair HL
9264    0x11    LD  DE, NN      e083        ;  Load register pair DE with 0xe083 (224)
9267    0x7d    LD A, L                     ;  Load Accumulator with register L
9268    0xe6    AND N           1f          ;  Bitwise AND of 0x1f (31) to Accumulator
9270    0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
9271    0x26    LD H, N         00          ;  Load register H with 0x00 (0)
9273    0x6f    LD L, A                     ;  Load register L with Accumulator
9274    0x19    ADD HL, DE                  ;  Add register pair DE to HL
9275    0xd1    POP DE                      ;  Load register pair DE with top of stack
9276    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
9277    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
9279    0xf1    POP AF                      ;  Load register pair AF with top of stack
9280    0xee    XOR N           01          ;  Bitwise XOR of 0x01 (1) to Accumulator
9282    0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
9283    0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
9284    0x03    INC BC                      ;  Increment register pair BC
9285    0xc3    JP NN           1f24        ;  Jump to 0x1f24 (9247)


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
9288    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
9291    0xdd    LD IX, NN       164e        ;  Load register pair IX with 0x164e (19990)
9295    0xfd    LD IY, NN       b535        ;  Load register pair IY with 0xb535 (13749)
9299    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
9301    0x06    LD  B, N        1e          ;  Load register B with 0x1e (30)
9303    0x0e    LD  C, N        08          ;  Load register C with 0x08 (8)
9305    0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
9308    0xfd    LD E, (IY + N)  00          ;  Load register E with location ( IY + 0x00 () )
9311    0x19    ADD HL, DE                  ;  Add register pair DE to HL
9312    0x07    RLCA                        ;  Rotate left circular Accumulator
9313    0x30    JR NC, N        02          ;  Jump relative 0x02 (2) if CARRY flag is 0
9315    0x36    LD (HL), N      10          ;  Load register pair HL with 0x10 (16)
9317    0xfd    INC IY                      ;  Increment register pair IY
9319    0x0d    DEC C                       ;  Decrement register C
9320    0x20    JR NZ, N        f2          ;  Jump relative 0xf2 (-14) if ZERO flag is 0
9322    0xdd    INC IX                      ;  Increment register pair IX
9324    0x05    DEC B                       ;  Decrement register B
9325    0x20    JR NZ, N        e8          ;  Jump relative 0xe8 (-24) if ZERO flag is 0
9327    0x21    LD HL, NN       344e        ;  Load register pair HL with 0x344e (20020)
;; 9328-9335 : On Ms. Pac-Man patched in from $8140-$8147
;; 9330  $2472   0xc3    JP nn           ec94        ;  Jump to $nn
9330    0x11    LD  DE, NN      6440        ;  Load register pair DE with 0x6440 (100)
9333    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
9335    0x11    LD  DE, NN      7840        ;  Load register pair DE with 0x7840 (120)
9338    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
9340    0x11    LD  DE, NN      8443        ;  Load register pair DE with 0x8443 (132)
9343    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
9345    0x11    LD  DE, NN      9843        ;  Load register pair DE with 0x9843 (152)
9348    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
9350    0xc9    RET                         ;  Return


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
9351    0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
;; 9352-9359 : On Ms. Pac-Man patched in from $8080-$8087
;; 9354  $248a   0xc3    JP nn           8194        ;  Jump to $nn
9354    0xdd    LD IX, NN       164e        ;  Load register pair IX with 0x164e (19990)
9358    0xfd    LD IY, NN       b535        ;  Load register pair IY with 0xb535 (13749)
9362    0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
9364    0x06    LD  B, N        1e          ;  Load register B with 0x1e (30)
9366    0x0e    LD  C, N        08          ;  Load register C with 0x08 (8)
9368    0xfd    LD E, (IY + N)  00          ;  Load register E with location ( IY + 0x00 () )
9371    0x19    ADD HL, DE                  ;  Add register pair DE to HL
9372    0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
9373    0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
9375    0x37    SCF                         ;  Set CARRY flag
9376    0x28    JR Z, N         01          ;  Jump relative 0x01 (1) if ZERO flag is 1
9378    0x3f    CCF                         ;  Complement CARRY flag
9379    0xdd    LD B,RLC (IX+d) 16          ;  Load IX + 0x00 with A rotated left-circular B-times
9383    0xfd    INC IY                      ;  Increment register pair IY
9385    0x0d    DEC C                       ;  Decrement register C
9386    0x20    JR NZ, N        ec          ;  Jump relative 0xec (-20) if ZERO flag is 0
9388    0xdd    INC IX                      ;  Increment register pair IX
9390    0x05    DEC B                       ;  Decrement register B
9391    0x20    JR NZ, N        e5          ;  Jump relative 0xe5 (-27) if ZERO flag is 0
9393    0x21    LD HL, NN       6440        ;  Load register pair HL with 0x6440 (16484)
;; 9392-9399 : On Ms. Pac-Man patched in from $8180-$8187
;; 9396  $24b4   0xc3    JP nn           0495        ;  Jump to $nn
9396    0x11    LD  DE, NN      344e        ;  Load register pair DE with 0x344e (52)
9399    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
9401    0x21    LD HL, NN       7840        ;  Load register pair HL with 0x7840 (16504)
9404    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
9406    0x21    LD HL, NN       8443        ;  Load register pair HL with 0x8443 (17284)
9409    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
9411    0x21    LD HL, NN       9843        ;  Load register pair HL with 0x9843 (17304)
9414    0xed    LDI                         ;  Load location (DE) with location (HL); increment DE, HL; de
9416    0xc9    RET                         ;  Return


;;; init_dotpowerpillstate();
; Fill $4E16-$4E33 with 0xFF
9417    0x21    LD HL, NN       164e        ;  Load register pair HL with 0x164e (19990)
9420    0x3e    LD A,N          ff          ;  Load Accumulator with 0xff (255)
9422    0x06    LD  B, N        1e          ;  Load register B with 0x1e (30)
9424    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
; Fill $4D34-$4D37 with 0x14
9425    0x3e    LD A,N          14          ;  Load Accumulator with 0x14 (20)
9427    0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
9429    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
9430    0xc9    RET                         ;  Return


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
9431    0x58    LD E, B                     ;  Load register E with register B
9432    0x78    LD A, B                     ;  Load Accumulator with register B
9433    0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
9435    0x3e    LD A,N          1f          ;  Load Accumulator with 0x1f (31)
;; 9432-9439 : On Ms. Pac-Man patched in from $80C0-$80C7
;; 9437  $24dd   0xc3    JP nn           8095        ;  Jump to $nn
9437    0x28    JR Z, N         02          ;  Jump relative 0x02 (2) if ZERO flag is 1
9439    0x3e    LD A,N          10          ;  Load Accumulator with 0x10 (16)
9441    0x21    LD HL, NN       4044        ;  Load register pair HL with 0x4044 (17472)
9444    0x01    LD  BC, NN      0480        ;  Load register pair BC with 0x0480 (32772)
9447    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
9448    0x0d    DEC C                       ;  Decrement register C
9449    0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
9451    0x3e    LD A,N          0f          ;  Load Accumulator with 0x0f (15)
9453    0x06    LD  B, N        40          ;  Load register B with 0x40 (64)
9455    0x21    LD HL, NN       c047        ;  Load register pair HL with 0xc047 (18368)
9458    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
9459    0x7b    LD A, E                     ;  Load Accumulator with register E
9460    0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
9462    0xc0    RET NZ                      ;  Return if ZERO flag is 0
9463    0x3e    LD A,N          1a          ;  Load Accumulator with 0x1a (26)
;; 9464-9471 : On Ms. Pac-Man patched in from $81C0-$81C7
;; 9465  $24f9   0xc3    JP nn           c395        ;  Jump to $nn
9465    0x11    LD  DE, NN      2000        ;  Load register pair DE with 0x2000 (32)
9468    0x06    LD  B, N        06          ;  Load register B with 0x06 (6)
;; 9470  $24fe   0xdd21  LD IY, nn       084d        ;  Load (16bit) IY with nn
9470    0xdd    LD IX, NN       a045        ;  Load register pair IX with 0xa045 (17824)
9474    0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
9477    0xdd    LD (IX+d), A    18          ;  Load location ( IX + 0x18 () ) with Accumulator
9480    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
9482    0x10    DJNZ N          f6          ;  Decrement B and jump relative 0xf6 (-10) if B!=0
9484    0x3e    LD A,N          1b          ;  Load Accumulator with 0x1b (27)
9486    0x06    LD  B, N        05          ;  Load register B with 0x05 (5)
9488    0xdd    LD IX, NN       4044        ;  Load register pair IX with 0x4044 (17472)
9492    0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
9495    0xdd    LD (IX+d), A    0f          ;  Load location ( IX + 0x0f () ) with Accumulator
9498    0xdd    LD (IX+d), A    10          ;  Load location ( IX + 0x10 () ) with Accumulator
9501    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
9503    0x10    DJNZ N          f3          ;  Decrement B and jump relative 0xf3 (-13) if B!=0
9505    0x06    LD  B, N        05          ;  Load register B with 0x05 (5)
9507    0xdd    LD IX, NN       2047        ;  Load register pair IX with 0x2047 (18208)
9511    0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
9514    0xdd    LD (IX+d), A    0f          ;  Load location ( IX + 0x0f () ) with Accumulator
9517    0xdd    LD (IX+d), A    10          ;  Load location ( IX + 0x10 () ) with Accumulator
9520    0xdd    ADD IX, DE                  ;  Add register pair DE to IX
9522    0x10    DJNZ N          f3          ;  Decrement B and jump relative 0xf3 (-13) if B!=0
9524    0x3e    LD A,N          18          ;  Load Accumulator with 0x18 (24)
9526    0x32    LD (NN), A      ed45        ;  Load location 0xed45 (17901) with the Accumulator
9529    0x32    LD (NN), A      0d46        ;  Load location 0x0d46 (17933) with the Accumulator
9532    0xc9    RET                         ;  Return


; Initialize 4C02-4C0D with params?  indexes?
; Initialize 4D00-4DD2 with data
9533    0xdd    LD IX, NN       004c        ;  Load register pair IX with 0x004c (19456)
9537    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x20 ()
9541    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x04 () ) with 0x20 ()
9545    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x06 () ) with 0x20 ()
9549    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x08 () ) with 0x20 ()
9553    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0a () ) with 0x2c ()
9557    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0c () ) with 0x3f ()
9561    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x03 () ) with 0x01 ()
9565    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x05 () ) with 0x03 ()
9569    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x07 () ) with 0x05 ()
9573    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x09 () ) with 0x07 ()
9577    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0b () ) with 0x09 ()
9581    0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0d () ) with 0x00 ()
9585    0x78    LD A, B                     ;  Load Accumulator with register B
9586    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
9587    0xc2    JP NZ, NN       0f26        ;  Jump to 0x0f26 (9743) if ZERO flag is 0
9590    0x21    LD HL, NN       6480        ;  Load register pair HL with 0x6480 (32868)
9593    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
9596    0x21    LD HL, NN       7c80        ;  Load register pair HL with 0x7c80 (32892)
9599    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
9602    0x21    LD HL, NN       7c90        ;  Load register pair HL with 0x7c90 (36988)
9605    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
9608    0x21    LD HL, NN       7c70        ;  Load register pair HL with 0x7c70 (28796)
9611    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
9614    0x21    LD HL, NN       c480        ;  Load register pair HL with 0xc480 (32964)
9617    0x22    LD (NN), HL     084d        ;  Load location 0x084d (19720) with the register pair HL
9620    0x21    LD HL, NN       2c2e        ;  Load register pair HL with 0x2c2e (11820)
9623    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
9626    0x22    LD (NN), HL     314d        ;  Load location 0x314d (19761) with the register pair HL
9629    0x21    LD HL, NN       2f2e        ;  Load register pair HL with 0x2f2e (11823)
9632    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
9635    0x22    LD (NN), HL     334d        ;  Load location 0x334d (19763) with the register pair HL
9638    0x21    LD HL, NN       2f30        ;  Load register pair HL with 0x2f30 (12335)
9641    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
9644    0x22    LD (NN), HL     354d        ;  Load location 0x354d (19765) with the register pair HL
9647    0x21    LD HL, NN       2f2c        ;  Load register pair HL with 0x2f2c (11311)
9650    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
9653    0x22    LD (NN), HL     374d        ;  Load location 0x374d (19767) with the register pair HL
9656    0x21    LD HL, NN       382e        ;  Load register pair HL with 0x382e (11832)
9659    0x22    LD (NN), HL     124d        ;  Load location 0x124d (19730) with the register pair HL
9662    0x22    LD (NN), HL     394d        ;  Load location 0x394d (19769) with the register pair HL
9665    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
9668    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
9671    0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
9674    0x21    LD HL, NN       0100        ;  Load register pair HL with 0x0100 (1)
9677    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
9680    0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
9683    0x21    LD HL, NN       ff00        ;  Load register pair HL with 0xff00 (255)
9686    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
9689    0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
9692    0x21    LD HL, NN       ff00        ;  Load register pair HL with 0xff00 (255)
9695    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
9698    0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
9701    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
9704    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
9707    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
9710    0x21    LD HL, NN       0201        ;  Load register pair HL with 0x0201 (258)
9713    0x22    LD (NN), HL     284d        ;  Load location 0x284d (19752) with the register pair HL
9716    0x22    LD (NN), HL     2c4d        ;  Load location 0x2c4d (19756) with the register pair HL
9719    0x21    LD HL, NN       0303        ;  Load register pair HL with 0x0303 (771)
9722    0x22    LD (NN), HL     2a4d        ;  Load location 0x2a4d (19754) with the register pair HL
9725    0x22    LD (NN), HL     2e4d        ;  Load location 0x2e4d (19758) with the register pair HL
9728    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
9730    0x32    LD (NN), A      304d        ;  Load location 0x304d (19760) with the Accumulator
9733    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
9736    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
9739    0x22    LD (NN), HL     d24d        ;  Load location 0xd24d (19922) with the register pair HL
9742    0xc9    RET                         ;  Return

; Load 4D00-4D3C (fragmented) with data
9743    0x21    LD HL, NN       9400        ;  Load register pair HL with 0x9400 (148)
9746    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
9749    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
9752    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
9755    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
9758    0x21    LD HL, NN       321e        ;  Load register pair HL with 0x321e (7730)
9761    0x22    LD (NN), HL     0a4d        ;  Load location 0x0a4d (19722) with the register pair HL
9764    0x22    LD (NN), HL     0c4d        ;  Load location 0x0c4d (19724) with the register pair HL
9767    0x22    LD (NN), HL     0e4d        ;  Load location 0x0e4d (19726) with the register pair HL
9770    0x22    LD (NN), HL     104d        ;  Load location 0x104d (19728) with the register pair HL
9773    0x22    LD (NN), HL     314d        ;  Load location 0x314d (19761) with the register pair HL
9776    0x22    LD (NN), HL     334d        ;  Load location 0x334d (19763) with the register pair HL
9779    0x22    LD (NN), HL     354d        ;  Load location 0x354d (19765) with the register pair HL
9782    0x22    LD (NN), HL     374d        ;  Load location 0x374d (19767) with the register pair HL
9785    0x21    LD HL, NN       0001        ;  Load register pair HL with 0x0001 (256)
9788    0x22    LD (NN), HL     144d        ;  Load location 0x144d (19732) with the register pair HL
9791    0x22    LD (NN), HL     164d        ;  Load location 0x164d (19734) with the register pair HL
9794    0x22    LD (NN), HL     184d        ;  Load location 0x184d (19736) with the register pair HL
9797    0x22    LD (NN), HL     1a4d        ;  Load location 0x1a4d (19738) with the register pair HL
9800    0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
9803    0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
9806    0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
9809    0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
9812    0x22    LD (NN), HL     1c4d        ;  Load location 0x1c4d (19740) with the register pair HL
9815    0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
; Fill $4D28-$4D30 with 0x02
9818    0x21    LD HL, NN       284d        ;  Load register pair HL with 0x284d (19752)
9821    0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
9823    0x06    LD  B, N        09          ;  Load register B with 0x09 (9)
9825    0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
9826    0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
9829    0x21    LD HL, NN       9408        ;  Load register pair HL with 0x9408 (2196)
9832    0x22    LD (NN), HL     084d        ;  Load location 0x084d (19720) with the register pair HL
9835    0x21    LD HL, NN       321f        ;  Load register pair HL with 0x321f (7986)
9838    0x22    LD (NN), HL     124d        ;  Load location 0x124d (19730) with the register pair HL
9841    0x22    LD (NN), HL     394d        ;  Load location 0x394d (19769) with the register pair HL
9844    0xc9    RET                         ;  Return

; Clear 0x4D00-0x4D09,0x4DD2-0x4DD3
9845    0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
9848    0x22    LD (NN), HL     d24d        ;  Load location 0xd24d (19922) with the register pair HL
9851    0x22    LD (NN), HL     084d        ;  Load location 0x084d (19720) with the register pair HL
9854    0x22    LD (NN), HL     004d        ;  Load location 0x004d (19712) with the register pair HL
9857    0x22    LD (NN), HL     024d        ;  Load location 0x024d (19714) with the register pair HL
9860    0x22    LD (NN), HL     044d        ;  Load location 0x044d (19716) with the register pair HL
9863    0x22    LD (NN), HL     064d        ;  Load location 0x064d (19718) with the register pair HL
9866    0xc9    RET                         ;  Return


; $4D94 = 0x55;
; if ( --B ) $4DA0 = 0x01;
; return;
9867    0x3e    LD A,N          55          ;  Load Accumulator with 0x55 (85)
9869    0x32    LD (NN), A      944d        ;  Load location 0x944d (19860) with the Accumulator
9872    0x05    DEC B                       ;  Decrement register B
9873    0xc8    RET Z                       ;  Return if ZERO flag is 1
9874    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
9876    0x32    LD (NN), A      a04d        ;  Load location 0xa04d (19872) with the Accumulator
9879    0xc9    RET                         ;  Return


; $4E00 = 1;
; $4E01 = 0;
; return;
9880    0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
9882    0x32    LD (NN), A      004e        ;  Load location 0x004e (19968) with the Accumulator
9885    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
9886    0x32    LD (NN), A      014e        ;  Load location 0x014e (19969) with the Accumulator
9889    0xc9    RET                         ;  Return


; Clear 0x4D00-0x4EFF
9890    0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
9891    0x11    LD  DE, NN      004d        ;  Load register pair DE with 0x004d (0)
9894    0x21    LD HL, NN       004e        ;  Load register pair HL with 0x004e (19968)
9897    0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
9898    0x13    INC DE                      ;  Increment register pair DE
9899    0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to location (HL)
9900    0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
9902    0xc2    JP NZ, NN       a626        ;  Jump to 0xa626 (9894) if ZERO flag is 0
9905    0xc9    RET                         ;  Return


;;; draw_bonuspac_points()
; Display bonus pac points based on stored variable
; $4156, $4136 - Screen location for 10/15/20/blank Kpts for bonus
9906    0xdd    LD IX, NN       3641        ;  Load register pair IX with 0x3641 (16694)
; $4E71 = Kilopoints for bonus pac in BCD. ( 10 | 15 | 20 | FF ).  FF = no bonus
9910    0x3a    LD A, (NN)      714e        ;  Load Accumulator with location 0x714e (20081)
; decode BCD in $4E71 and place corresponding ascii chars for the digits in $4136 ( thousands )
; and $4156 ( ten thousands )
9913    0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
9915    0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
9917    0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
9920    0x3a    LD A, (NN)      714e        ;  Load Accumulator with location 0x714e (20081)
9923    0x0f    RRCA                        ;  Rotate right circular Accumulator
9924    0x0f    RRCA                        ;  Rotate right circular Accumulator
9925    0x0f    RRCA                        ;  Rotate right circular Accumulator
9926    0x0f    RRCA                        ;  Rotate right circular Accumulator
9927    0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
9929    0xc8    RET Z                       ;  Return if ZERO flag is 1
9930    0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
9932    0xdd    LD (IX+d), A    20          ;  Load location ( IX + 0x20 () ) with Accumulator
9935    0xc9    RET                         ;  Return

;;; init_mem_jumper_values()
; Set up memory with jumper values
; $5080:0,1 : Coins/Credits
;   0 = Free Play
;   1 = 1 Coin/1 Credit
;   2 = 1 Coin/2 Credits
;   3 = 2 Coins/1 Credit
9936    0x3a    LD A, (NN)      8050        ;  Load Accumulator with location 0x8050 (20608)
9939    0x47    LD B, A                     ;  Load register B with Accumulator
9940    0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
; If zero, set credits ( $4E6E ) to 0xFF
9942    0xc2    JP NZ, NN       de26        ;  Jump to 0xde26 (9950) if ZERO flag is 0
9945    0x21    LD HL, NN       6e4e        ;  Load register pair HL with 0x6e4e (20078)
9948    0x36    LD (HL), N      ff          ;  Load register pair HL with 0xff (255)
; bizzare bit of bit fiddling means $4E6B and $4E6D contain the coin to credits relationship,
; respectively.  ie, 1 coin/2 credits means $4E6B=1, $4E6D=2, etc.  Both equal 0 for freeplay.
9950    0x4f    LD c, A                     ;  Load register C with Accumulator
9951    0x1f    RRA                         ;  Rotate right Accumulator through carry
9952    0xce    ADC A, N        00          ;  Add with carry 0x00 (0) to Accumulator
9954    0x32    LD (NN), A      6b4e        ;  Load location 0x6b4e (20075) with the Accumulator
9957    0xe6    AND N           02          ;  Bitwise AND of 0x02 (2) to Accumulator
9959    0xa9    XOR A, C                    ;  Bitwise XOR of register C to Accumulator
9960    0x32    LD (NN), A      6d4e        ;  Load location 0x6d4e (20077) with the Accumulator
; $5080:2,3 : Lives per game
;   0 = 1 Lives
;   1 = 2 Lives
;   2 = 3 Lives
;   3 = 5 Lives
; Set $4E6F to 1/2/3/5 Lives per game
9963    0x78    LD A, B                     ;  Load Accumulator with register B
9964    0x0f    RRCA                        ;  Rotate right circular Accumulator
9965    0x0f    RRCA                        ;  Rotate right circular Accumulator
9966    0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
9968    0x3c    INC A                       ;  Increment Accumulator
9969    0xfe    CP N            04          ;  Compare 0x04 (4) with Accumulator
9971    0x20    JR NZ, N        01          ;  Jump relative 0x01 (1) if ZERO flag is 0
9973    0x3c    INC A                       ;  Increment Accumulator
9974    0x32    LD (NN), A      6f4e        ;  Load location 0x6f4e (20079) with the Accumulator
; $5080:4,5 : Bonus Pac @ ...
;   0 = 10000 points
;   1 = 15000 points
;   2 = 20000 points
;   3 = None
; Set $4E71 to BCD of bonus pac points, indexed into a table at $2728
9977    0x78    LD A, B                     ;  Load Accumulator with register B
9978    0x0f    RRCA                        ;  Rotate right circular Accumulator
9979    0x0f    RRCA                        ;  Rotate right circular Accumulator
9980    0x0f    RRCA                        ;  Rotate right circular Accumulator
9981    0x0f    RRCA                        ;  Rotate right circular Accumulator
9982    0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
9984    0x21    LD HL, NN       2827        ;  Load register pair HL with 0x2827 (10024)
9987    0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
9988    0x32    LD (NN), A      714e        ;  Load location 0x714e (20081) with the Accumulator
; $5080:7 : Ghost Names
;   0 = Alternative
;   1 = Normal
; Set $4E75 to the ! of the ghost name jumper ( ie. 1 = alternative, 0 = normal )
9991    0x78    LD A, B                     ;  Load Accumulator with register B
9992    0x07    RLCA                        ;  Rotate left circular Accumulator
9993    0x2f    CPL                         ;  Complement Accumulator (1's complement)
9994    0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
9996    0x32    LD (NN), A      754e        ;  Load location 0x754e (20085) with the Accumulator
; $5080:6 : Difficulty
;   0 = Hard
;   1 = Normal
; Set $4E73 to 0x6800 for normal, 0x7D00 for difficult
9999    0x78    LD A, B                     ;  Load Accumulator with register B
10000   0x07    RLCA                        ;  Rotate left circular Accumulator
10001   0x07    RLCA                        ;  Rotate left circular Accumulator
10002   0x2f    CPL                         ;  Complement Accumulator (1's complement)
10003   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
10005   0x47    LD B, A                     ;  Load register B with Accumulator
10006   0x21    LD HL, NN       2c27        ;  Load register pair HL with 0x2c27 (10028)
10009   0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
10010   0x22    LD (NN), HL     734e        ;  Load location 0x734e (20083) with the register pair HL
; $5040:7
;   0 = Cocktail
;   1 = Upright
10013   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
10016   0x07    RLCA                        ;  Rotate left circular Accumulator
10017   0x2f    CPL                         ;  Complement Accumulator (1's complement)
10018   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
10020   0x32    LD (NN), A      724e        ;  Load location 0x724e (20082) with the Accumulator
10023   0xc9    RET                         ;  Return

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

10032   0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
10035   0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
10037   0xc2    JP NZ, NN       5827        ;  Jump to 0x5827 (10072) if ZERO flag is 0
10040   0x3a    LD A, (NN)      b64d        ;  Load Accumulator with location 0xb64d (19894)
10043   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
10044   0x20    JR NZ, N        1a          ;  Jump relative 0x1a (26) if ZERO flag is 0
10046   0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
10049   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
10051   0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
10053   0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
10056   0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
;; 10056-10063 : On Ms. Pac-Man patched in from $8050-$8057
;; 10059 $274b   0xcd    CALL nn         6195        ;  Call $nn
;; 10062 $274e   0xcd    CALL nn         6621        ;  Call $nn
10059   0x11    LD  DE, NN      1d22        ;  Load register pair DE with 0x1d22 (29)
10062   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10065   0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
10068   0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
10071   0xc9    RET                         ;  Return
10072   0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
10075   0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
10079   0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
10082   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10085   0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
10088   0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
10091   0xc9    RET                         ;  Return


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

10092   0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
10095   0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
10097   0xc2    JP NZ, NN       8e27        ;  Jump to 0x8e27 (10126) if ZERO flag is 0
10100   0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
10103   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
10105   0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
10107   0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
;; 10112-10119 : On Ms. Pac-Man patched in from $8090-$8097
;; 10110 $2781   0xcd    CALL nn         6195        ;  Call $nn
;; 10113 $2784   0xcd    CALL nn         6629        ;  Call $nn
10110   0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
10113   0x11    LD  DE, NN      1d39        ;  Load register pair DE with 0x1d39 (29)
10116   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10119   0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
10122   0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
10125   0xc9    RET                         ;  Return
10126   0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
10130   0x2a    LD HL, (NN)     1c4d        ;  Load register pair HL with location 0x1c4d (19740)
10133   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10134   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10135   0x19    ADD HL, DE                  ;  Add register pair DE to HL
10136   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
10137   0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
10140   0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
10143   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10146   0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
10149   0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
10152   0xc9    RET                         ;  Return


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

10153   0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
10156   0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
10158   0xc2    JP NZ, NN       cb27        ;  Jump to 0xcb27 (10187) if ZERO flag is 0
10161   0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
10164   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
10166   0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
10168   0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
;; 10168-10175 : On Ms. Pac-Man patched in from $8190-$8197
;; 10171 $27bb   0xcd    CALL nn         5995        ;  Call $nn
;; 10174 $27be   0x11    LD DE, nn       40a6        ;  Load DE (16bit) with nn
10171   0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
10174   0x11    LD  DE, NN      4020        ;  Load register pair DE with 0x4020 (64)
10177   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10180   0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
10183   0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
10186   0xc9    RET                         ;  Return
10187   0xed    LD BC, (NN)     0a4d        ;  Load register pair BC with location 0x0a4d (19722)
10191   0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
10195   0x2a    LD HL, (NN)     1c4d        ;  Load register pair HL with location 0x1c4d (19740)
10198   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10199   0x19    ADD HL, DE                  ;  Add register pair DE to HL
10200   0x7d    LD A, L                     ;  Load Accumulator with register L
10201   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
10202   0x91    SUB A, C                    ;  Subtract register C from Accumulator (no carry)
10203   0x6f    LD L, A                     ;  Load register L with Accumulator
10204   0x7c    LD A, H                     ;  Load Accumulator with register H
10205   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
10206   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
10207   0x67    LD H, A                     ;  Load register H with Accumulator
10208   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
10209   0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
10212   0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
10215   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10218   0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
10221   0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
10224   0xc9    RET                         ;  Return


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

10225   0x3a    LD A, (NN)      c14d        ;  Load Accumulator with location 0xc14d (19905)
10228   0xcb    BIT 0,A                     ;  Test bit 0 of Accumulator
10230   0xc2    JP NZ, NN       1328        ;  Jump to 0x1328 (10259) if ZERO flag is 0
10233   0x3a    LD A, (NN)      044e        ;  Load Accumulator with location 0x044e (19972)
10236   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
10238   0x20    JR NZ, N        13          ;  Jump relative 0x13 (19) if ZERO flag is 0
10240   0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
;; 10240-10247 : On Ms. Pac-Man patched in from $8028-$802F
;; 10243 $2803   0xcd    CALL nn         5e95        ;  Call $nn
;; 10246 $2806   0x11    LD DE, nn       40ff        ;  Load DE (16bit) with nn
10243   0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
10246   0x11    LD  DE, NN      403b        ;  Load register pair DE with 0x403b (64)
10249   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10252   0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
10255   0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
10258   0xc9    RET                         ;  Return
10259   0xdd    LD IX, NN       394d        ;  Load register pair IX with 0x394d (19769)
10263   0xfd    LD IY, NN       104d        ;  Load register pair IY with 0x104d (19728)
; HL = square(abs($IX-$IY)) + square(abs(($IX+1)-($IY+1))
10267   0xcd    CALL NN         ea29        ;  Call to 0xea29 (10730)
10270   0x11    LD  DE, NN      4000        ;  Load register pair DE with 0x4000 (64)
; clear flags
10273   0xa7    AND A, A                    ;  Bitwise AND of Accumulator to Accumulator
10274   0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
10276   0xda    JP C, NN        0028        ;  Jump to 0x0028 (10240) if CARRY flag is 1
10279   0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
10282   0xed    LD DE, (NN)     394d        ;  Load register pair DE with location 0x394d (19769)
10286   0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
10289   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10292   0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
10295   0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
10298   0xc9    RET                         ;  Return


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

10299   0x3a    LD A, (NN)      ac4d        ;  Load Accumulator with location 0xac4d (19884)
10302   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
10303   0xca    JP Z,           5528        ;  Jump to 0x5528 (10325) if ZERO flag is 1
10306   0x11    LD  DE, NN      2c2e        ;  Load register pair DE with 0x2c2e (44)
10309   0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
10312   0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
10315   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10318   0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
10321   0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
10324   0xc9    RET                         ;  Return
10325   0x2a    LD HL, (NN)     0a4d        ;  Load register pair HL with location 0x0a4d (19722)
10328   0x3a    LD A, (NN)      2c4d        ;  Load Accumulator with location 0x2c4d (19756)
10331   0xcd    CALL NN         1e29        ;  Call to 0x1e29 (10526)
10334   0x22    LD (NN), HL     1e4d        ;  Load location 0x1e4d (19742) with the register pair HL
10337   0x32    LD (NN), A      2c4d        ;  Load location 0x2c4d (19756) with the Accumulator
10340   0xc9    RET                         ;  Return


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

10341   0x3a    LD A, (NN)      ad4d        ;  Load Accumulator with location 0xad4d (19885)
10344   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
10345   0xca    JP Z,           7f28        ;  Jump to 0x7f28 (10367) if ZERO flag is 1
10348   0x11    LD  DE, NN      2c2e        ;  Load register pair DE with 0x2c2e (44)
10351   0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
10354   0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
10357   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10360   0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
10363   0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
10366   0xc9    RET                         ;  Return
10367   0x2a    LD HL, (NN)     0c4d        ;  Load register pair HL with location 0x0c4d (19724)
10370   0x3a    LD A, (NN)      2d4d        ;  Load Accumulator with location 0x2d4d (19757)
10373   0xcd    CALL NN         1e29        ;  Call to 0x1e29 (10526)
10376   0x22    LD (NN), HL     204d        ;  Load location 0x204d (19744) with the register pair HL
10379   0x32    LD (NN), A      2d4d        ;  Load location 0x2d4d (19757) with the Accumulator
10382   0xc9    RET                         ;  Return


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

10383   0x3a    LD A, (NN)      ae4d        ;  Load Accumulator with location 0xae4d (19886)
10386   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
10387   0xca    JP Z,           a928        ;  Jump to 0xa928 (10409) if ZERO flag is 1
10390   0x11    LD  DE, NN      2c2e        ;  Load register pair DE with 0x2c2e (44)
10393   0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
10396   0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
10399   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10402   0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
10405   0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
10408   0xc9    RET                         ;  Return
10409   0x2a    LD HL, (NN)     0e4d        ;  Load register pair HL with location 0x0e4d (19726)
10412   0x3a    LD A, (NN)      2e4d        ;  Load Accumulator with location 0x2e4d (19758)
10415   0xcd    CALL NN         1e29        ;  Call to 0x1e29 (10526)
10418   0x22    LD (NN), HL     224d        ;  Load location 0x224d (19746) with the register pair HL
10421   0x32    LD (NN), A      2e4d        ;  Load location 0x2e4d (19758) with the Accumulator
10424   0xc9    RET                         ;  Return


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

10425   0x3a    LD A, (NN)      af4d        ;  Load Accumulator with location 0xaf4d (19887)
10428   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
10429   0xca    JP Z,           d328        ;  Jump to 0xd328 (10451) if ZERO flag is 1
10432   0x11    LD  DE, NN      2c2e        ;  Load register pair DE with 0x2c2e (44)
10435   0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
10438   0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
10441   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10444   0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
10447   0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
10450   0xc9    RET                         ;  Return
10451   0x2a    LD HL, (NN)     104d        ;  Load register pair HL with location 0x104d (19728)
10454   0x3a    LD A, (NN)      2f4d        ;  Load Accumulator with location 0x2f4d (19759)
10457   0xcd    CALL NN         1e29        ;  Call to 0x1e29 (10526)
10460   0x22    LD (NN), HL     244d        ;  Load location 0x244d (19748) with the register pair HL
10463   0x32    LD (NN), A      2f4d        ;  Load location 0x2f4d (19759) with the Accumulator
10466   0xc9    RET                         ;  Return


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

10467   0x3a    LD A, (NN)      a74d        ;  Load Accumulator with location 0xa74d (19879)
10470   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
10471   0xca    JP Z,           fe28        ;  Jump to 0xfe28 (10494) if ZERO flag is 1
10474   0x2a    LD HL, (NN)     124d        ;  Load register pair HL with location 0x124d (19730)
10477   0xed    LD DE, (NN)     0c4d        ;  Load register pair DE with location 0x0c4d (19724)
10481   0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
10484   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10487   0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
10490   0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
10493   0xc9    RET                         ;  Return
10494   0x2a    LD HL, (NN)     394d        ;  Load register pair HL with location 0x394d (19769)
10497   0xed    LD BC, (NN)     0c4d        ;  Load register pair BC with location 0x0c4d (19724)
10501   0x7d    LD A, L                     ;  Load Accumulator with register L
10502   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
10503   0x91    SUB A, C                    ;  Subtract register C from Accumulator (no carry)
10504   0x6f    LD L, A                     ;  Load register L with Accumulator
10505   0x7c    LD A, H                     ;  Load Accumulator with register H
10506   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
10507   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
10508   0x67    LD H, A                     ;  Load register H with Accumulator
10509   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
10510   0x2a    LD HL, (NN)     124d        ;  Load register pair HL with location 0x124d (19730)
10513   0x3a    LD A, (NN)      3c4d        ;  Load Accumulator with location 0x3c4d (19772)
10516   0xcd    CALL NN         6629        ;  Call to 0x6629 (10598)
10519   0x22    LD (NN), HL     264d        ;  Load location 0x264d (19750) with the register pair HL
10522   0x32    LD (NN), A      3c4d        ;  Load location 0x3c4d (19772) with the Accumulator
10525   0xc9    RET                         ;  Return


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

10526   0x22    LD (NN), HL     3e4d        ;  Load location 0x3e4d (19774) with the register pair HL
10529   0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
10531   0x32    LD (NN), A      3d4d        ;  Load location 0x3d4d (19773) with the Accumulator
10534   0xcd    CALL NN         232a        ;  Call to 0x232a (10787)
10537   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
10539   0x21    LD HL, NN       3b4d        ;  Load register pair HL with 0x3b4d (19771)
10542   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
10543   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
10544   0x5f    LD E, A                     ;  Load register E with Accumulator
10545   0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
10547   0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
10551   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
10553   0xfd    LD IY, NN       3e4d        ;  Load register pair IY with 0x3e4d (19774)
10557   0x3a    LD A, (NN)      3d4d        ;  Load Accumulator with location 0x3d4d (19773)
10560   0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
10561   0xca    JP Z,           5729        ;  Jump to 0x5729 (10583) if ZERO flag is 1
; get_playfield_byte($(IX)+$(IY));
10564   0xcd    CALL NN         0f20        ;  Call to 0x0f20 (8207)
10567   0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
10569   0xd6    SUB N           c0          ;  Subtract 0xc0 (192) from Accumulator (no carry)
10571   0x28    JR Z, N         0a          ;  Jump relative 0x0a (10) if ZERO flag is 1
10573   0xdd    LD L, (IX + N)  00          ;  Load register L with location ( IX + 0x00 () )
10576   0xdd    LD H, (IX + N)  01          ;  Load register H with location ( IX + 0x01 () )
10579   0x3a    LD A, (NN)      3b4d        ;  Load Accumulator with location 0x3b4d (19771)
10582   0xc9    RET                         ;  Return
10583   0xdd    INC IX                      ;  Increment register pair IX
10585   0xdd    INC IX                      ;  Increment register pair IX
10587   0x21    LD HL, NN       3b4d        ;  Load register pair HL with 0x3b4d (19771)
10590   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
10591   0x3c    INC A                       ;  Increment Accumulator
10592   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
10594   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
10595   0xc3    JP NN           3d29        ;  Jump to 0x3d29 (10557)


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

10598   0x22    LD (NN), HL     3e4d        ;  Load location 0x3e4d (19774) with the register pair HL
10601   0xed    LD (NN), DE     404d        ;  Load location 0x404d (19776) with register pair DE
10605   0x32    LD (NN), A      3b4d        ;  Load location 0x3b4d (19771) with the Accumulator
10608   0xee    XOR N           02          ;  Bitwise XOR of 0x02 (2) to Accumulator
10610   0x32    LD (NN), A      3d4d        ;  Load location 0x3d4d (19773) with the Accumulator
10613   0x21    LD HL, NN       ffff        ;  Load register pair HL with 0xffff (65535)
10616   0x22    LD (NN), HL     444d        ;  Load location 0x444d (19780) with the register pair HL
10619   0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
10623   0xfd    LD IY, NN       3e4d        ;  Load register pair IY with 0x3e4d (19774)
10627   0x21    LD HL, NN       c74d        ;  Load register pair HL with 0xc74d (19911)
10630   0x36    LD (HL), N      00          ;  Load location HL with 0x00 (0)
10632   0x3a    LD A, (NN)      3d4d        ;  Load Accumulator with location 0x3d4d (19773)
10635   0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
10636   0xca    JP Z,           c629        ;  Jump to 0xc629 (10694) if ZERO flag is 1
; L = (IY) + (IX);  H = (IY + 1) + (IX + 1);
10639   0xcd    CALL NN         0020        ;  Call to 0x0020 (8192)
10642   0x22    LD (NN), HL     424d        ;  Load location 0x424d (19778) with the register pair HL
; YX_to_playfield_addr() // via 101
10645   0xcd    CALL NN         6500        ;  Call to 0x6500 (101)
10648   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
; At this point, A contains the byte on the screen that is pointed to by $4D3E + $IX ($32FF-...) as Y,
; and $4D3F + $(IX+1) ($3300-...) as X
10649   0xe6    AND N           c0          ;  Bitwise AND of 0xc0 (192) to Accumulator
; if that byte on the screen is a space (C0 in the tile roms), jump to 10694
10651   0xd6    SUB N           c0          ;  Subtract 0xc0 (192) from Accumulator (no carry)
10653   0x28    JR Z, N         27          ;  Jump relative 0x27 (39) if ZERO flag is 1
10655   0xdd    PUSH IX                     ;  Load the stack with register pair IX
10657   0xfd    PUSH IY                     ;  Load the stack with register pair IY
10659   0xdd    LD IX, NN       404d        ;  Load register pair IX with 0x404d (19776)
10663   0xfd    LD IY, NN       424d        ;  Load register pair IY with 0x424d (19778)
; HL == square of distance from ghost to pacman
10667   0xcd    CALL NN         ea29        ;  Call to 0xea29 (10730)
10670   0xfd    POP IY                      ;  Load register pair IY with top of stack
10672   0xdd    POP IX                      ;  Load register pair IX with top of stack
10674   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
10675   0x2a    LD HL, (NN)     444d        ;  Load register pair HL with location 0x444d (19780)
; clear flags
10678   0xa7    AND A, A                    ;  Bitwise AND of Accumulator and Accumulator
10679   0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
10681   0xda    JP C, NN        c629        ;  Jump to 0xc629 (10694) if CARRY flag is 1
10684   0xed    LD (NN), DE     444d        ;  Load location 0x444d (19780) with register pair DE
10688   0x3a    LD A, (NN)      c74d        ;  Load Accumulator with location 0xc74d (19911)
10691   0x32    LD (NN), A      3b4d        ;  Load location 0x3b4d (19771) with the Accumulator
10694   0xdd    INC IX                      ;  Increment register pair IX
10696   0xdd    INC IX                      ;  Increment register pair IX
10698   0x21    LD HL, NN       c74d        ;  Load register pair HL with 0xc74d (19911)
10701   0x34    INC (HL)                    ;  Increment location (HL)
10702   0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
; repeat 10632-10705 4 times
10704   0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
10705   0xc2    JP NZ, NN       8829        ;  Jump to 0x8829 (10632) if ZERO flag is 0
10708   0x3a    LD A, (NN)      3b4d        ;  Load Accumulator with location 0x3b4d (19771)
10711   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
10712   0x5f    LD E, A                     ;  Load register E with Accumulator
10713   0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
10715   0xdd    LD IX, NN       ff32        ;  Load register pair IX with 0xff32 (13055)
10719   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
10721   0xdd    LD L, (IX + N)  00          ;  Load register L with location ( IX + 0x00 () )
10724   0xdd    LD H, (IX + N)  01          ;  Load register H with location ( IX + 0x01 () )
10727   0xcb    SRL A                       ;  Shift Accumulator right logical
10729   0xc9    RET                         ;  Return



;; square_distance(IX = location_a, IY = location_b);
; HL = square(abs($IX-$IY)) + square(abs(($IX+1)-($IY+1))
; Determines the square of the distance from the distorted Ghost position (in $IY, $IY+1)
; to Pacman's perceived position (in $IX, $IX+1)
10730   0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
10733   0xfd    LD B, (IY + N)  00          ;  Load register B with location ( IY + 0x00 () )
10736   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
10737   0xd2    JP NC, NN       f929        ;  Jump to 0xf929 (10745) if CARRY flag is 0
10740   0x78    LD A, B                     ;  Load Accumulator with register B
10741   0xdd    LD B, (IX + N)  00          ;  Load register B with location ( IX + 0x00 () )
10744   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
; square(A);
10745   0xcd    CALL NN         122a        ;  Call to 0x122a (10770)
10748   0xe5    PUSH HL                     ;  Load the stack with register pair HL
10749   0xdd    LD A, (IX+d)    01          ;  Load Accumulator with location ( IX + 0x01 () )
10752   0xfd    LD B, (IY + N)  01          ;  Load register B with location ( IY + 0x01 () )
10755   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
10756   0xd2    JP NC, NN       0c2a        ;  Jump to 0x0c2a (10764) if CARRY flag is 0
10759   0x78    LD A, B                     ;  Load Accumulator with register B
10760   0xdd    LD B, (IX + N)  01          ;  Load register B with location ( IX + 0x01 () )
10763   0x90    SUB A, B                    ;  Subtract register B from Accumulator (no carry)
; square(A);
10764   0xcd    CALL NN         122a        ;  Call to 0x122a (10770)
10767   0xc1    POP BC                      ;  Load register pair BC with top of stack
10768   0x09    ADD HL, BC                  ;  Add register pair BC to HL
10769   0xc9    RET                         ;  Return


; square(A);
; Incredible.  Works on the principle that for each 1 bit of the multiplicand in
; position N, you add the multiplicand << ( 8-N ) to the product accumulator.  In
; this case, HL.  I'm not convinced that it works mathematically, but it seems to
; on a few back-of-the-envelope cases.
10770   0x67    LD H, A                     ;  Load register H with Accumulator
10771   0x5f    LD E, A                     ;  Load register E with Accumulator
10772   0x2e    LD L,N          00          ;  Load register L with 0x00 (0)
10774   0x55    LD D, L                     ;  Load register D with register L
10775   0x0e    LD  C, N        08          ;  Load register C with 0x08 (8)
10777   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10778   0xd2    JP NC, NN       1e2a        ;  Jump to 0x1e2a (10782) if CARRY flag is 0
10781   0x19    ADD HL, DE                  ;  Add register pair DE to HL
10782   0x0d    DEC C                       ;  Decrement register C
10783   0xc2    JP NZ, NN       192a        ;  Jump to 0x192a (10777) if ZERO flag is 0
10786   0xc9    RET                         ;  Return


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

10787   0x2a    LD HL, (NN)     c94d        ;  Load register pair HL with location 0xc94d (19913)
10790   0x54    LD D, H                     ;  Load register D with register H
10791   0x5d    LD E, L                     ;  Load register E with register L
10792   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10793   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10794   0x19    ADD HL, DE                  ;  Add register pair DE to HL
10795   0x23    INC HL                      ;  Increment register pair HL
10796   0x7c    LD A, H                     ;  Load Accumulator with register H
10797   0xe6    AND N           1f          ;  Bitwise AND of 0x1f (31) to Accumulator
10799   0x67    LD H, A                     ;  Load register H with Accumulator
10800   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
10801   0x22    LD (NN), HL     c94d        ;  Load location 0xc94d (19913) with the register pair HL
10804   0xc9    RET                         ;  Return


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
10805   0x11    LD  DE, NN      4040        ;  Load register pair DE with 0x4040 (64)
10808   0x21    LD HL, NN       c043        ;  Load register pair HL with 0xc043 (17344)
10811   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to location (HL)
10812   0xed    SBC HL, DE                  ;  Subtract with carry register pair DE from HL
10814   0xc8    RET Z                       ;  Return if ZERO flag is 1
10815   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
10816   0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
10818   0xca    JP Z,           532a        ;  Jump to 0x532a (10835) if ZERO flag is 1
10821   0xfe    CP N            12          ;  Compare 0x12 (18) with Accumulator
10823   0xca    JP Z,           532a        ;  Jump to 0x532a (10835) if ZERO flag is 1
10826   0xfe    CP N            14          ;  Compare 0x14 (20) with Accumulator
10828   0xca    JP Z,           532a        ;  Jump to 0x532a (10835) if ZERO flag is 1
10831   0x13    INC DE                      ;  Increment register pair DE
10832   0xc3    JP NN           382a        ;  Jump to 0x382a (10808)
10835   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
10837   0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
10838   0x13    INC DE                      ;  Increment register pair DE
10839   0xc3    JP NN           382a        ;  Jump to 0x382a (10808)

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
10842   0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
10845   0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
10847   0xc8    RET Z                       ;  Return if ZERO flag is 1
10848   0x21    LD HL, NN       172b        ;  Load register pair HL with 0x172b (11031)
10851   0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
10852   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
10853   0xcd    CALL NN         0b2b        ;  Call to 0x0b2b (11019)
10856   0x7b    LD A, E                     ;  Load Accumulator with register E
10857   0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
10858   0x27    DAA                         ;  Decimal adjust Accumulator
10859   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
10860   0x23    INC HL                      ;  Increment register pair HL
10861   0x7a    LD A, D                     ;  Load Accumulator with register D
10862   0x8e    ADC A, (HL)                 ;  Add with carry location (HL) to Accumulator
10863   0x27    DAA                         ;  Decimal adjust Accumulator
10864   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
10865   0x5f    LD E, A                     ;  Load register E with Accumulator
10866   0x23    INC HL                      ;  Increment register pair HL
10867   0x3e    LD A,N          00          ;  Load Accumulator with 0x00 (0)
10869   0x8e    ADC A, (HL)                 ;  Add with carry location (HL) to Accumulator
10870   0x27    DAA                         ;  Decimal adjust Accumulator
10871   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
10872   0x57    LD D, A                     ;  Load register D with Accumulator
10873   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
10874   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10875   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10876   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10877   0x29    ADD HL, HL                  ;  Add register pair HL to HL
10878   0x3a    LD A, (NN)      714e        ;  Load Accumulator with location 0x714e (20081)
10881   0x3d    DEC A                       ;  Decrement Accumulator
10882   0xbc    CP A, H                     ;  Compare register H with Accumulator
10883   0xdc    CALL C,NN       332b        ;  Call to 0x332b (11059) if CARRY flag is 1
10886   0xcd    CALL NN         af2a        ;  Call to 0xaf2a (10927)
10889   0x13    INC DE                      ;  Increment register pair DE
10890   0x13    INC DE                      ;  Increment register pair DE
10891   0x13    INC DE                      ;  Increment register pair DE
10892   0x21    LD HL, NN       8a4e        ;  Load register pair HL with 0x8a4e (20106)
10895   0x06    LD  B, N        03          ;  Load register B with 0x03 (3)
10897   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
10898   0xbe    CP A, (HL)                  ;  Compare location (HL) with Accumulator
10899   0xd8    RET C                       ;  Return if CARRY flag is 1
10900   0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
10902   0x1b    DEC DE                      ;  Decrement register pair DE
10903   0x2b    DEC HL                      ;  Decrement register pair HL
10904   0x10    DJNZ N          f7          ;  Decrement B and jump relative 0xf7 (-9) if B!=0
10906   0xc9    RET                         ;  Return


; draw_highscore()
; HL = ($4E09 == 0)?0x4E80:0x4E84;
; DE = 0x4E88;  BC = 0x0003;
; $DE..$DE+2 = $HL..$HL+2;
; DE--;  // 0x4E8A ??
; BC = 0x0304;
; HL = 0x43F2;
; jump(15); // 10942
10907   0xcd    CALL NN         0b2b        ;  Call to 0x0b2b (11019)
10910   0x11    LD  DE, NN      884e        ;  Load register pair DE with 0x884e (136)
10913   0x01    LD  BC, NN      0300        ;  Load register pair BC with 0x0300 (3)
10916   0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; decrement BC; repeat until BC == 0
10918   0x1b    DEC DE                      ;  Decrement register pair DE
10919   0x01    LD  BC, NN      0403        ;  Load register pair BC with 0x0403 (772)
10922   0x21    LD HL, NN       f243        ;  Load register pair HL with 0xf243 (17394)
10925   0x18    JR N            0f          ;  Jump relative 0x0f (15)


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
10927   0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
10930   0x01    LD  BC, NN      0403        ;  Load register pair BC with 0x0403 (772)
10933   0x21    LD HL, NN       fc43        ;  Load register pair HL with 0xfc43 (17404)
10936   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
10937   0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
10939   0x21    LD HL, NN       e943        ;  Load register pair HL with 0xe943 (17385)
10942   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
10943   0x0f    RRCA                        ;  Rotate right circular Accumulator
10944   0x0f    RRCA                        ;  Rotate right circular Accumulator
10945   0x0f    RRCA                        ;  Rotate right circular Accumulator
10946   0x0f    RRCA                        ;  Rotate right circular Accumulator
10947   0xcd    CALL NN         ce2a        ;  Call to 0xce2a (10958)
10950   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
10951   0xcd    CALL NN         ce2a        ;  Call to 0xce2a (10958)
10954   0x1b    DEC DE                      ;  Decrement register pair DE
10955   0x10    DJNZ N          f1          ;  Decrement B and jump relative 0xf1 (-15) if B!=0
10957   0xc9    RET                         ;  Return

; draw_padded_score_digit()
; // draw a digit, but pad the score by up to (5?) 4 blanks for leading zeros
; // if (digit == 0 ) {  A=C;  if ( C=0 ) { draw; return; } else { A=0x40; C--; draw; return; } }
; //             else {  C=0;  draw; return;  }
; if ( A &= 0x15 != 0 ) {  C = 0x00;  }
; else if ( A = C != 0 ) {  A = 0x40;  C--;  }
; $HL = A;
; HL--;
; return;
10958   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
10960   0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
10962   0x0e    LD  C, N        00          ;  Load register C with 0x00 (0)
10964   0x18    JR N            07          ;  Jump relative 0x07 (7)
10966   0x79    LD A, C                     ;  Load Accumulator with register C
10967   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
10968   0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
10970   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
10972   0x0d    DEC C                       ;  Decrement register C
10973   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
10974   0x2b    DEC HL                      ;  Decrement register pair HL
10975   0xc9    RET                         ;  Return


; write_string(0); "HIGH SCORE"
10976   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
10978   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
; Fill $4E80-$4E87 with 0x00
10981   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
10982   0x21    LD HL, NN       804e        ;  Load register pair HL with 0x804e (20096)
10985   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
10987   0xcf    RST 0x8                     ;  Restart to location 8 (Reset)
; draw $4E82 to player one score field
10988   0x01    LD  BC, NN      0403        ;  Load register pair BC with 0x0403 (772)
10991   0x11    LD  DE, NN      824e        ;  Load register pair DE with 0x824e (130)
10994   0x21    LD HL, NN       fc43        ;  Load register pair HL with 0xfc43 (17404)
10997   0xcd    CALL NN         be2a        ;  Call to 0xbe2a (10942)
; // prepare to draw $4E86 to player two score field, but don't actually make the call
11000   0x01    LD  BC, NN      0403        ;  Load register pair BC with 0x0403 (772)
11003   0x11    LD  DE, NN      864e        ;  Load register pair DE with 0x864e (134)
11006   0x21    LD HL, NN       e943        ;  Load register pair HL with 0xe943 (17385)
; // this has something to do with the millions digit, but I don't know what
; A = $4E70;
; if ( $HL &= A == 0 ) {  C = 0x06;  }  // HL = $43E9
; draw_padded_score_digit()
11009   0x3a    LD A, (NN)      704e        ;  Load Accumulator with location 0x704e (20080)
11012   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to location (HL)
11013   0x20    JR NZ, N        b7          ;  Jump relative 0xb7 (-73) if ZERO flag is 0 // 10960
11015   0x0e    LD  C, N        06          ;  Load register C with 0x06 (6)
11017   0x18    JR N            b3          ;  Jump relative 0xb3 (-77)                   // 10960

; get_score_address()
; if ( $4E09 == 0 ) HL = 0x4E80;
;              else HL = 0x4E84;
; return;
11019   0x3a    LD A, (NN)      094e        ;  Load Accumulator with location 0x094e (19977)
11022   0x21    LD HL, NN       804e        ;  Load register pair HL with 0x804e (20096)
11025   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11026   0xc8    RET Z                       ;  Return if ZERO flag is 1
11027   0x21    LD HL, NN       844e        ;  Load register pair HL with 0x844e (20100)
11030   0xc9    RET                         ;  Return

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
11059   0x13    INC DE                      ;  Increment register pair DE
11060   0x6b    LD L, E                     ;  Load register L with register E
11061   0x62    LD H, D                     ;  Load register H with register D
11062   0x1b    DEC DE                      ;  Decrement register pair DE
11063   0xcb    BIT 0,(HL)                  ;  Test bit 0 of location (HL)
11065   0xc0    RET NZ                      ;  Return if ZERO flag is 0
11066   0xcb    SET 0,(HL)                  ;  Set bit 0 of location (HL)
11068   0x21    LD HL, NN       9c4e        ;  Load register pair HL with 0x9c4e (20124)
11071   0xcb    SET 0,(HL)                  ;  Set bit 0 of location (HL)
11073   0x21    LD HL, NN       144e        ;  Load register pair HL with 0x144e (19988)
11076   0x34    INC (HL)                    ;  Increment location (HL)
11077   0x21    LD HL, NN       154e        ;  Load register pair HL with 0x154e (19989)
11080   0x34    INC (HL)                    ;  Increment location (HL)
11081   0x46    LD B, (HL)                  ;  Load register B with location (HL)


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
11082   0x21    LD HL, NN       1a40        ;  Load register pair HL with 0x1a40 (16410)
11085   0x0e    LD  C, N        05          ;  Load register C with 0x05 (5)
11087   0x78    LD A, B                     ;  Load Accumulator with register B
11088   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11089   0x28    JR Z, N         0e          ;  Jump relative 0x0e (14) if ZERO flag is 1
11091   0xfe    CP N            06          ;  Compare 0x06 (6) with Accumulator
11093   0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
11095   0x3e    LD A,N          20          ;  Load Accumulator with 0x20 (32)
11097   0xcd    CALL NN         8f2b        ;  Call to 0x8f2b (11151)
11100   0x2b    DEC HL                      ;  Decrement register pair HL
11101   0x2b    DEC HL                      ;  Decrement register pair HL
11102   0x0d    DEC C                       ;  Decrement register C
11103   0x10    DJNZ N          f6          ;  Decrement B and jump relative 0xf6 (-10) if B!=0
11105   0x0d    DEC C                       ;  Decrement register C
11106   0xf8    RET M                       ;  Return if SIGN flag is 1 (Negative)
11107   0xcd    CALL NN         7e2b        ;  Call to 0x7e2b (11134)
11110   0x2b    DEC HL                      ;  Decrement register pair HL
11111   0x2b    DEC HL                      ;  Decrement register pair HL
11112   0x18    JR N            f7          ;  Jump relative 0xf7 (-9)
; if ( A = $4E00 == 1 ) return;
; call(11213); //  rectangular_fill(); // stack = loc of params, params (5 bytes) = upper-left of rect (2), width (1), char to fill (1), height (1)
; $DE = A;
; B = H;
; HL += BC;
; A = $BC;
; HL = 0x4E15;
; B = $HL;
; jump(draw_extra_lives());
11114   0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
11117   0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
11119   0xc8    RET Z                       ;  Return if ZERO flag is 1
11120   0xcd    CALL NN         cd2b        ;  Call to 0xcd2b (11213)
11123   0x12    LD  (DE), A                 ;  Load location (DE) with the Accumulator
11124   0x44    LD B, H                     ;  Load register B with register H
11125   0x09    ADD HL, BC                  ;  Add register pair BC to HL
11126   0x0a    LD  A, (BC)                 ;  Load Accumulator with location (BC)
11127   0x02    LD  (BC), A                 ;  Load location (BC) with the Accumulator
11128   0x21    LD HL, NN       154e        ;  Load register pair HL with 0x154e (19989)
11131   0x46    LD B, (HL)                  ;  Load register B with location (HL)
11132   0x18    JR N            cc          ;  Jump relative 0xcc (-52)


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
11134   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
11136   0xe5    PUSH HL                     ;  Load the stack with register pair HL
11137   0xd5    PUSH DE                     ;  Load the stack with register pair DE
11138   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
11139   0x23    INC HL                      ;  Increment register pair HL
11140   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
11141   0x11    LD  DE, NN      1f00        ;  Load register pair DE with 0x1f00 (31)
11144   0x19    ADD HL, DE                  ;  Add register pair DE to HL
11145   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
11146   0x23    INC HL                      ;  Increment register pair HL
11147   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
11148   0xd1    POP DE                      ;  Load register pair DE with top of stack
11149   0xe1    POP HL                      ;  Load register pair HL with top of stack
11150   0xc9    RET                         ;  Return


; draw_4tile();
; (HL)    = A
; (HL+1)  = A+1
; (HL+32) = A+2
; (HL+33) = A+3
11151   0xe5    PUSH HL                     ;  Load the stack with register pair HL
11152   0xd5    PUSH DE                     ;  Load the stack with register pair DE
11153   0x11    LD  DE, NN      1f00        ;  Load register pair DE with 0x1f00 (31)
11156   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
11157   0x3c    INC A                       ;  Increment Accumulator
11158   0x23    INC HL                      ;  Increment register pair HL
11159   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
11160   0x3c    INC A                       ;  Increment Accumulator
11161   0x19    ADD HL, DE                  ;  Add register pair DE to HL
11162   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
11163   0x3c    INC A                       ;  Increment Accumulator
11164   0x23    INC HL                      ;  Increment register pair HL
11165   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
11166   0xd1    POP DE                      ;  Load register pair DE with top of stack
11167   0xe1    POP HL                      ;  Load register pair HL with top of stack
11168   0xc9    RET                         ;  Return


;;; draw_credits_info()
;;; Display credits/play info
;;; This info is in $4E6E.
; if $4E6E == 0x00, display("FREE PLAY") ?
; else display("CREDIT   ");
; Then draw out the BCD of the number of credits ($4E6E) to $4034/$4033
11169   0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
11172   0xfe    CP N            ff          ;  Compare 0xff (255) with Accumulator
11174   0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
; write_string(2); "FREE PLAY"
11176   0x06    LD  B, N        02          ;  Load register B with 0x02 (2)
11178   0xc3    JP NN           5e2c        ;  Jump to 0x5e2c (11358)
; write_string(1); "CREDIT   "
11181   0x06    LD  B, N        01          ;  Load register B with 0x01 (1)
11183   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
; Get BCD credits ($4E6E)
11186   0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
; Skip tens digit if it's 0
11189   0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
11191   0x28    JR Z, N         09          ;  Jump relative 0x09 (9) if ZERO flag is 1
; Rotate tens digit around, add 0x30 (beginning of ASCII numbers) to it, put in Video RAM $4034
11193   0x0f    RRCA                        ;  Rotate right circular Accumulator
11194   0x0f    RRCA                        ;  Rotate right circular Accumulator
11195   0x0f    RRCA                        ;  Rotate right circular Accumulator
11196   0x0f    RRCA                        ;  Rotate right circular Accumulator
11197   0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
11199   0x32    LD (NN), A      3440        ;  Load location 0x3440 (16436) with the Accumulator
; Get BCD credits ($4E6E), block out tens digit, add 0x30 to it, put in Video RAM $4033
11202   0x3a    LD A, (NN)      6e4e        ;  Load Accumulator with location 0x6e4e (20078)
11205   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
11207   0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
11209   0x32    LD (NN), A      3340        ;  Load location 0x3340 (16435) with the Accumulator
11212   0xc9    RET                         ;  Return


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
11213   0xe1    POP HL                      ;  Load register pair HL with top of stack
11214   0x5e    LD E, (HL)                  ;  Load register E with location (HL)
11215   0x23    INC HL                      ;  Increment register pair HL
11216   0x56    LD D, (HL)                  ;  Load register D with location (HL)
11217   0x23    INC HL                      ;  Increment register pair HL
11218   0x4e    LD C, (HL)                  ;  Load register C with location (HL)
11219   0x23    INC HL                      ;  Increment register pair HL
11220   0x46    LD B, (HL)                  ;  Load register B with location (HL)
11221   0x23    INC HL                      ;  Increment register pair HL
11222   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
11223   0x23    INC HL                      ;  Increment register pair HL
11224   0xe5    PUSH HL                     ;  Load the stack with register pair HL
11225   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
11226   0x11    LD  DE, NN      2000        ;  Load register pair DE with 0x2000 (32)
11229   0xe5    PUSH HL                     ;  Load the stack with register pair HL
11230   0xc5    PUSH BC                     ;  Load the stack with register pair BC
11231   0x71    LD (HL), C                  ;  Load location (HL) with register C
11232   0x23    INC HL                      ;  Increment register pair HL
11233   0x10    DJNZ N          fc          ;  Decrement B and jump relative 0xfc (-4) if B!=0
11235   0xc1    POP BC                      ;  Load register pair BC with top of stack
11236   0xe1    POP HL                      ;  Load register pair HL with top of stack
11237   0x19    ADD HL, DE                  ;  Add register pair DE to HL
11238   0x3d    DEC A                       ;  Decrement Accumulator
11239   0x20    JR NZ, N        f4          ;  Jump relative 0xf4 (-12) if ZERO flag is 0
11241   0xc9    RET                         ;  Return


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
11242   0x3a    LD A, (NN)      004e        ;  Load Accumulator with location 0x004e (19968)
11245   0xfe    CP N            01          ;  Compare 0x01 (1) with Accumulator
11247   0xc8    RET Z                       ;  Return if ZERO flag is 1
11248   0x3a    LD A, (NN)      134e        ;  Load Accumulator with location 0x134e (19987)
11251   0x3c    INC A                       ;  Increment Accumulator
;; 11248-11255 : On Ms. Pac-Man patched in from $81D0-$81D7
;; 11252 $2bf4   0xc3    JP nn           9387        ;  Jump to $nn
11252   0xfe    CP N            08          ;  Compare 0x08 (8) with Accumulator
11254   0xd2    JP NC, NN       2e2c        ;  Jump to 0x2e2c (11310) if CARRY flag is 0
11257   0x11    LD  DE, NN      083b        ;  Load register pair DE with 0x083b (8)
11260   0x47    LD B, A                     ;  Load register B with Accumulator
11261   0x0e    LD  C, N        07          ;  Load register C with 0x07 (7)
11263   0x21    LD HL, NN       0440        ;  Load register pair HL with 0x0440 (16388)
11266   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
11267   0xcd    CALL NN         8f2b        ;  Call to 0x8f2b (11151)  // draw_4tile();
11270   0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
11272   0x84    ADD A, H                    ;  Add register H to Accumulator (no carry)
11273   0x67    LD H, A                     ;  Load register H with Accumulator
11274   0x13    INC DE                      ;  Increment register pair DE
11275   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
11276   0xcd    CALL NN         802b        ;  Call to 0x802b (11136)   // blank_4tile(A);
11279   0x3e    LD A,N          fc          ;  Load Accumulator with 0xfc (252)
11281   0x84    ADD A, H                    ;  Add register H to Accumulator (no carry)
11282   0x67    LD H, A                     ;  Load register H with Accumulator
11283   0x13    INC DE                      ;  Increment register pair DE
11284   0x23    INC HL                      ;  Increment register pair HL
11285   0x23    INC HL                      ;  Increment register pair HL
11286   0x0d    DEC C                       ;  Decrement register C
11287   0x10    DJNZ N          e9          ;  Decrement B and jump relative 0xe9 (-23) if B!=0
11289   0x0d    DEC C                       ;  Decrement register C
11290   0xf8    RET M                       ;  Return if SIGN flag is 1 (Negative)
11291   0xcd    CALL NN         7e2b        ;  Call to 0x7e2b (11134)    // blank_4tile();
11294   0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
11296   0x84    ADD A, H                    ;  Add register H to Accumulator (no carry)
11297   0x67    LD H, A                     ;  Load register H with Accumulator
11298   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
11299   0xcd    CALL NN         802b        ;  Call to 0x802b (11136)    // blank_4tile(A);
11302   0x3e    LD A,N          fc          ;  Load Accumulator with 0xfc (252)
11304   0x84    ADD A, H                    ;  Add register H to Accumulator (no carry)
11305   0x67    LD H, A                     ;  Load register H with Accumulator
11306   0x23    INC HL                      ;  Increment register pair HL
11307   0x23    INC HL                      ;  Increment register pair HL
11308   0x18    JR N            eb          ;  Jump relative 0xeb (-21)


; draw_fruit_gt8();
; if ( A > 19 ) A = 19;
; A -= 7;
; C = A;  B = 0x00;
; HL = $3B08;  // 15112 - fruit table
; HL += BC;  HL += BC;
; DE = HL, HL = DE;
; B = 0x07;
; jump(11261); // draw fruit from the bumped index
11310   0xfe    CP N            13          ;  Compare 0x13 (19) with Accumulator
11312   0x38    JR C, N         02          ;  Jump to 0x02 (2) if CARRY flag is 0
11314   0x3e    LD A,N          13          ;  Load Accumulator with 0x13 (19)
11316   0xd6    SUB N           07          ;  Subtract 0x07 (7) from Accumulator (no carry)
11318   0x4f    LD c, A                     ;  Load register C with Accumulator
11319   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
11321   0x21    LD HL, NN       083b        ;  Load register pair HL with 0x083b (15112)
11324   0x09    ADD HL, BC                  ;  Add register pair BC to HL
11325   0x09    ADD HL, BC                  ;  Add register pair BC to HL
11326   0xeb    EX DE,HL                    ;  Exchange the location DE with register pair HL
11327   0x06    LD  B, N        07          ;  Load register B with 0x07 (7)
11329   0xc3    JP NN           fd2b        ;  Jump to 0xfd2b (11261)


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
11332   0x47    LD B, A                     ;  Load register B with Accumulator
11333   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
11335   0xc6    ADD A, N        00          ;  Add 0x00 (0) to Accumulator (no carry)
11337   0x27    DAA                         ;  Decimal adjust Accumulator
11338   0x4f    LD c, A                     ;  Load register C with Accumulator
11339   0x78    LD A, B                     ;  Load Accumulator with register B
11340   0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
11342   0x28    JR Z, N         0b          ;  Jump relative 0x0b (11) if ZERO flag is 1
11344   0x0f    RRCA                        ;  Rotate right circular Accumulator
11345   0x0f    RRCA                        ;  Rotate right circular Accumulator
11346   0x0f    RRCA                        ;  Rotate right circular Accumulator
11347   0x0f    RRCA                        ;  Rotate right circular Accumulator
11348   0x47    LD B, A                     ;  Load register B with Accumulator
11349   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
11350   0xc6    ADD A, N        16          ;  Add 0x16 (22) to Accumulator (no carry)
11352   0x27    DAA                         ;  Decimal adjust Accumulator
11353   0x10    DJNZ N          fb          ;  Decrement B and jump relative 0xfb (-5) if B!=0
11355   0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
11356   0x27    DAA                         ;  Decimal adjust Accumulator
11357   0xc9    RET                         ;  Return



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
11358   0x21    LD HL, NN       a536        ;  Load register pair HL with 0xa536 (13989)
11361   0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
11362   0x5e    LD E, (HL)                  ;  Load register E with location (HL)
11363   0x23    INC HL                      ;  Increment register pair HL
11364   0x56    LD D, (HL)                  ;  Load register D with location (HL)

; Put location of string's color bytes on stack
11365   0xdd    LD IX, NN       0044        ;  Load register pair IX with 0x0044 (17408)
11369   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
11371   0xdd    PUSH IX                     ;  Load the stack with register pair IX

; Adjust IX to location of string's char bytes
11373   0x11    LD  DE, NN      00fc        ;  Load register pair DE with 0x00fc (0)
11376   0xdd    ADD IX, DE                  ;  Add register pair DE to IX

; XXX this is incorrect
; Set DE to the difference between sequential L-to-R chars, based on bit 1 of the MSB of
; the string's location:
; MSB:1==0 (playfield)     - DE = -32
; MSB:1==1 (top of screen) - DE = -1
11378   0x11    LD  DE, NN      ffff        ;  Load register pair DE with 0xffff (255)
11381   0xcb    BIT 7,(HL)                  ;  Test bit 7 of location (HL)
;11381   0xcb    SET 1, (HL)                 ;  Set bit 1 of location (HL)
11383   0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
11385   0x11    LD  DE, NN      e0ff        ;  Load register pair DE with 0xe0ff (224)

; If B, the string's index number, is more than 128 jump to 11436...  (why?!?)
11388   0x23    INC HL                      ;  Increment register pair HL
11389   0x78    LD A, B                     ;  Load Accumulator with register B
11390   0x01    LD  BC, NN      0000        ;  Load register pair BC with 0x0000 (0)
11393   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
11394   0x38    JR C, N         28          ;  Jump to 0x28 (40) if CARRY flag is 1

; right now IX = video+first 2 bytes of 'string', SP = color byte corresponding to IX
; HL points to the string plus 2 bytes and we know that B (the index into the string table) wasn't 0
; ... so let's write it to memory until we reach a delimiter character of 0x2F...
11396   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
11397   0xfe    CP N            2f          ;  Compare 0x2f (47) with Accumulator
11399   0x28    JR Z, N         09          ;  Jump relative 0x09 (9) if ZERO flag is 1
11401   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
11404   0x23    INC HL                      ;  Increment register pair HL
11405   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
11407   0x04    INC B                       ;  Increment register B
11408   0x18    JR N            f2          ;  Jump relative 0xf2 (-14)
11410   0x23    INC HL                      ;  Increment register pair HL

; if the color byte is > 127, we're going to write the color byte to the whole string
; otherwise, we're writing different colors to the whole string.
11411   0xdd    POP IX                      ;  Load register pair IX with top of stack
11413   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
11414   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11415   0xfa    JP M, NN        a42c        ;  Jump to 0xa42c (11428) if SIGN flag is 1 (Negative)
11418   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
11419   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
11422   0x23    INC HL                      ;  Increment register pair HL
11423   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
11425   0x10    DJNZ N          f7          ;  Decrement B and jump relative 0xf7 (-9) if B!=0
11427   0xc9    RET                         ;  Return

; write the color byte to the whole string.  only the bottom 5 bits are used; the top
; three, including our whole-string monocolor flag (C:7), are ignored
11428   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
11431   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
11433   0x10    DJNZ N          f9          ;  Decrement B and jump relative 0xf9 (-7) if B!=0
11435   0xc9    RET                         ;  Return


; String index was < 128, write byte to screen
11436   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
11437   0xfe    CP N            2f          ;  Compare 0x2f (47) with Accumulator
11439   0x28    JR Z, N         0a          ;  Jump relative 0x0a (10) if ZERO flag is 1
11441   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x00 () ) with 0x40 ()
; actually - DD 36 00 40 : LD   (IX+d),n    ; Load location (IX + d) with N
11445   0x23    INC HL                      ;  Increment register pair HL
11446   0xdd    ADD IX, DE                  ;  Add register pair DE to IX
11448   0x04    INC B                       ;  Increment register B
11449   0x18    JR N            f1          ;  Jump relative 0xf1 (-15)
11451   0x23    INC HL                      ;  Increment register pair HL
11452   0x04    INC B                       ;  Increment register B
; find the next 0x2F
11453   0xed    CPIR                        ;  Compare location (HL) and accumulator, increment HL, decrement BC 
11455   0x18    JR N            d2          ;  Jump relative 0xd2 (-46)





;; Sound handling code, I think.  Probably reads some kind of table and 'advances' the sound parameters
;;
; call_11588($3BC8, $4ECC, $4E8C);  //  15304 == $3BD4, $3BF3
; if ( $4ECC != 0 ) $4E91 = A;
;; 11456-11463 : On Ms. Pac-Man patched in from $80D0-$80D7
;; 11457 $2cc1  0xc3    JP nn           9797        ;  Jump to $nn
11457   0x21    LD HL, NN       c83b        ;  Load register pair HL with 0xc83b (15304)
11460   0xdd    LD IX, NN       cc4e        ;  Load register pair IX with 0xcc4e (20172)
11464   0xfd    LD IY, NN       8c4e        ;  Load register pair IY with 0x8c4e (20108)
11468   0xcd    CALL NN         442d        ;  Call to 0x442d (11588)
11471   0x47    LD B, A                     ;  Load register B with Accumulator
11472   0x3a    LD A, (NN)      cc4e        ;  Load Accumulator with location 0xcc4e (20172)
11475   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11476   0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
11478   0x78    LD A, B                     ;  Load Accumulator with register B
11479   0x32    LD (NN), A      914e        ;  Load location 0x914e (20113) with the Accumulator

; call_11588($3BCC, $4EDC, $4E92);  //  15308 == $3C58, $3C95
; if ( $4EDC != 0 ) $4E96 = A;
;; 11480-11487 : On Ms. Pac-Man patched in from $80E0-$80E7
;; 11482 $2cda   0x21    LD HL, nn       7d96        ;  Load HL (16bit) with nn
;; 11485 $2cdd   0xdd21  LD IY, nn       dce3        ;  Load (16bit) IY with nn
11482   0x21    LD HL, NN       cc3b        ;  Load register pair HL with 0xcc3b (15308)
11485   0xdd    LD IX, NN       dc4e        ;  Load register pair IX with 0xdc4e (20188)
11489   0xfd    LD IY, NN       924e        ;  Load register pair IY with 0x924e (20114)
11493   0xcd    CALL NN         442d        ;  Call to 0x442d (11588)
11496   0x47    LD B, A                     ;  Load register B with Accumulator
11497   0x3a    LD A, (NN)      dc4e        ;  Load Accumulator with location 0xdc4e (20188)
11500   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11501   0x28    JR Z, N         04          ;  Jump relative 0x04 (4) if ZERO flag is 1
11503   0x78    LD A, B                     ;  Load Accumulator with register B
11504   0x32    LD (NN), A      964e        ;  Load location 0x964e (20118) with the Accumulator

; call_11588($3BD0, $4EEC, $4E97);  //  15312 == $3CDE, $3CDF
; if ( $4EEC != 0 ) $4E9B = A;
; return;
;; 11504-11511 : On Ms. Pac-Man patched in from $81E0-$81E7
;; 11507 $2cf3   0x21    LD HL, nn       8d96        ;  Load HL (16bit) with nn
;; 11510 $2cf6   0xdd21  LD IY, nn       ffff        ;  Load (16bit) IY with nn
11507   0x21    LD HL, NN       d03b        ;  Load register pair HL with 0xd03b (15312)
11510   0xdd    LD IX, NN       ec4e        ;  Load register pair IX with 0xec4e (20204)
11514   0xfd    LD IY, NN       974e        ;  Load register pair IY with 0x974e (20119)
11518   0xcd    CALL NN         442d        ;  Call to 0x442d (11588)
11521   0x47    LD B, A                     ;  Load register B with Accumulator
11522   0x3a    LD A, (NN)      ec4e        ;  Load Accumulator with location 0xec4e (20204)
11525   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11526   0xc8    RET Z                       ;  Return if ZERO flag is 1
11527   0x78    LD A, B                     ;  Load Accumulator with register B
11528   0x32    LD (NN), A      9b4e        ;  Load location 0x9b4e (20123) with the Accumulator
11531   0xc9    RET                         ;  Return


; $4E91 = call_11758($3B30, $4E9C, $4E8C);
; $4E96 = call_11758($3B40, $4EAC, $4E92);
; $4E9B = call_11758($3B80, $4EBC, $4E97);
; $4E90 = $4E9B ^ 0xFF;
; return;
11532   0x21    LD HL, NN       303b        ;  Load register pair HL with 0x303b (15152)
11535   0xdd    LD IX, NN       9c4e        ;  Load register pair IX with 0x9c4e (20124)
11539   0xfd    LD IY, NN       8c4e        ;  Load register pair IY with 0x8c4e (20108)
11543   0xcd    CALL NN         ee2d        ;  Call to 0xee2d (11758)
11546   0x32    LD (NN), A      914e        ;  Load location 0x914e (20113) with the Accumulator
11549   0x21    LD HL, NN       403b        ;  Load register pair HL with 0x403b (15168)
11552   0xdd    LD IX, NN       ac4e        ;  Load register pair IX with 0xac4e (20140)
11556   0xfd    LD IY, NN       924e        ;  Load register pair IY with 0x924e (20114)
11560   0xcd    CALL NN         ee2d        ;  Call to 0xee2d (11758)
11563   0x32    LD (NN), A      964e        ;  Load location 0x964e (20118) with the Accumulator
11566   0x21    LD HL, NN       803b        ;  Load register pair HL with 0x803b (15232)
11569   0xdd    LD IX, NN       bc4e        ;  Load register pair IX with 0xbc4e (20156)
11573   0xfd    LD IY, NN       974e        ;  Load register pair IY with 0x974e (20119)
11577   0xcd    CALL NN         ee2d        ;  Call to 0xee2d (11758)
11580   0x32    LD (NN), A      9b4e        ;  Load location 0x9b4e (20123) with the Accumulator
11583   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
11584   0x32    LD (NN), A      904e        ;  Load location 0x904e (20112) with the Accumulator
11587   0xc9    RET                         ;  Return


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
11588   0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
11591   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11592   0xca    JP Z,           f42d        ;  Jump to 0xf42d (11764) if ZERO flag is 1
11595   0x4f    LD c, A                     ;  Load register C with Accumulator
11596   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
11598   0x1e    LD E,N          80          ;  Load register E with 0x80 (128)
11600   0x7b    LD A, E                     ;  Load Accumulator with register E
11601   0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
11602   0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
11604   0xcb    SRL E                       ;  Shift register E right logical
11606   0x10    DJNZ N          f8          ;  Decrement B and jump relative 0xf8 (-8) if B!=0
11608   0xc9    RET                         ;  Return
11609   0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
11612   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
11613   0x20    JR NZ, N        07          ;  Jump relative 0x07 (7) if ZERO flag is 0
11615   0xdd    LD (IX+d), E    02          ;  Load location ( IX + 0x02 () ) with register E
;; 11616-11623 : On Ms. Pac-Man patched in from $8160-$8167
;; 11618 $2d62   0xc3    JP nn           4e36        ;  Jump to $nn
11618   0x05    DEC B                       ;  Decrement register B
; table_and_index_to_address()  //  called with 15304/15308/15312
11619   0xdf    RST 0x18                    ;  Restart to location 0x18 (24) (Reset)
11620   0x18    JR N            0c          ;  Jump relative 0x0c (12)
11622   0xdd    DEC (IX + N)    0c          ;  Decrement location IX + 0x0c ()
11625   0xc2    JP NZ, NN       d72d        ;  Jump to 0xd72d (11735) if ZERO flag is 0
11628   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
11631   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
11634   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
11635   0x23    INC HL                      ;  Increment register pair HL
11636   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
11639   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
11642   0xfe    CP N            f0          ;  Compare 0xf0 (240) with Accumulator
11644   0x38    JR C, N         27          ;  Jump to 0x27 (39) if CARRY flag is 0
11646   0x21    LD HL, NN       6c2d        ;  Load register pair HL with 0x6c2d (11628)
11649   0xe5    PUSH HL                     ;  Load the stack with register pair HL
11650   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
11652   0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
11685   0x47    LD B, A                     ;  Load register B with Accumulator
11686   0xe6    AND N           1f          ;  Bitwise AND of 0x1f (31) to Accumulator
11688   0x28    JR Z, N         03          ;  Jump relative 0x03 (3) if ZERO flag is 1
11690   0xdd    LD (IX+d), B    0d          ;  Load location ( IX + 0x0d () ) with register B
; if ( $(IX+11) & 0x08 ) $(IX+15) = 0x00;
;                   else $(IX+15) = $(IX+9);
11693   0xdd    LD C, (IX + N)  09          ;  Load register C with location ( IX + 0x09 () )
11696   0xdd    LD A, (IX+d)    0b          ;  Load Accumulator with location ( IX + 0x0b () )
11699   0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
11701   0x28    JR Z, N         02          ;  Jump relative 0x02 (2) if ZERO flag is 1
11703   0x0e    LD  C, N        00          ;  Load register C with 0x00 (0)
11705   0xdd    LD (IX+d), C    0f          ;  Load location ( IX + 0x0f () ) with register C
; A = B;
; A cir<<= 3;
; A &= 0x07;
; HL = 0x3BB0; // (15280)
; RST 10;
11708   0x78    LD A, B                     ;  Load Accumulator with register B
11709   0x07    RLCA                        ;  Rotate left circular Accumulator
11710   0x07    RLCA                        ;  Rotate left circular Accumulator
11711   0x07    RLCA                        ;  Rotate left circular Accumulator
11712   0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
11714   0x21    LD HL, NN       b03b        ;  Load register pair HL with 0xb03b (15280)
11717   0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
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
11718   0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
11721   0x78    LD A, B                     ;  Load Accumulator with register B
11722   0xe6    AND N           1f          ;  Bitwise AND of 0x1f (31) to Accumulator
11724   0x28    JR Z, N         09          ;  Jump relative 0x09 (9) if ZERO flag is 1
11726   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
11728   0x21    LD HL, NN       b83b        ;  Load register pair HL with 0xb83b (15288)
11731   0xd7    RST 0x10                    ;  Restart to location 0x10 (16) (Reset)
11732   0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
11735   0xdd    LD L, (IX + N)  0e          ;  Load register L with location ( IX + 0x0e () )
11738   0x26    LD H, N         00          ;  Load register H with 0x00 (0)
11740   0xdd    LD A, (IX+d)    0d          ;  Load Accumulator with location ( IX + 0x0d () )
11743   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
11745   0x28    JR Z, N         02          ;  Jump relative 0x02 (2) if ZERO flag is 1
11747   0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
11749   0xdd    ADD A, (IX+d)   04          ;  Add location ( IX + 0x04 () ) to Accumulator
11752   0xca    JP Z,           e82e        ;  Jump to 0xe82e (12008) if ZERO flag is 1
11755   0xc3    JP NN           e42e        ;  Jump to 0xe42e (12004)

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
11758   0xdd    LD A, (IX+d)    00          ;  Load Accumulator with location ( IX + 0x00 () )
11761   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11762   0x20    JR NZ, N        27          ;  Jump relative 0x27 (39) if ZERO flag is 0
11764   0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
11767   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11768   0xc8    RET Z                       ;  Return if ZERO flag is 1
11769   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x02 () ) with 0x00 ()
11773   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0d () ) with 0x00 ()
11777   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0e () ) with 0x00 ()
11781   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0f () ) with 0x00 ()
11785   0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x00 () ) with 0x00 ()
11789   0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x01 () ) with 0x00 ()
11793   0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x02 () ) with 0x00 ()
11797   0xfd    LOAD (IY + N),              ;  Decrement location ( IY + 0x03 () ) with 0x00 ()
11801   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
11802   0xc9    RET                         ;  Return
11803   0x4f    LD c, A                     ;  Load register C with Accumulator
11804   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
11806   0x1e    LD E,N          80          ;  Load register E with 0x80 (128)
11808   0x7b    LD A, E                     ;  Load Accumulator with register E
11809   0xa1    AND A, C                    ;  Bitwise AND of register C to Accumulator
11810   0x20    JR NZ, N        05          ;  Jump relative 0x05 (5) if ZERO flag is 0
11812   0xcb    SRL E                       ;  Shift register E right logical
11814   0x10    DJNZ N          f8          ;  Decrement B and jump relative 0xf8 (-8) if B!=0
11816   0xc9    RET                         ;  Return


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
11817   0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
11820   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
11821   0x20    JR NZ, N        3f          ;  Jump relative 0x3f (63) if ZERO flag is 0
11823   0xdd    LD (IX+d), E    02          ;  Load location ( IX + 0x02 () ) with register E
11826   0x05    DEC B                       ;  Decrement register B
11827   0x78    LD A, B                     ;  Load Accumulator with register B
11828   0x07    RLCA                        ;  Rotate left circular Accumulator
11829   0x07    RLCA                        ;  Rotate left circular Accumulator
11830   0x07    RLCA                        ;  Rotate left circular Accumulator
11831   0x4f    LD c, A                     ;  Load register C with Accumulator
11832   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
11834   0xe5    PUSH HL                     ;  Load the stack with register pair HL
11835   0x09    ADD HL, BC                  ;  Add register pair BC to HL
11836   0xdd    PUSH IX                     ;  Load the stack with register pair IX
11838   0xd1    POP DE                      ;  Load register pair DE with top of stack
11839   0x13    INC DE                      ;  Increment register pair DE
11840   0x13    INC DE                      ;  Increment register pair DE
11841   0x13    INC DE                      ;  Increment register pair DE
11842   0x01    LD  BC, NN      0800        ;  Load register pair BC with 0x0800 (8)
11845   0xed    LDIR                        ;  Load location (DE) with location (HL); increment DE, HL; de
11847   0xe1    POP HL                      ;  Load register pair HL with top of stack
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
11848   0xdd    LD A, (IX+d)    06          ;  Load Accumulator with location ( IX + 0x06 () )
11851   0xe6    AND N           7f          ;  Bitwise AND of 0x7f (127) to Accumulator
11853   0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
11856   0xdd    LD A, (IX+d)    04          ;  Load Accumulator with location ( IX + 0x04 () )
11859   0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
11862   0xdd    LD A, (IX+d)    09          ;  Load Accumulator with location ( IX + 0x09 () )
11865   0x47    LD B, A                     ;  Load register B with Accumulator
11866   0x0f    RRCA                        ;  Rotate right circular Accumulator
11867   0x0f    RRCA                        ;  Rotate right circular Accumulator
11868   0x0f    RRCA                        ;  Rotate right circular Accumulator
11869   0x0f    RRCA                        ;  Rotate right circular Accumulator
11870   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
11872   0xdd    LD (IX+d), A    0b          ;  Load location ( IX + 0x0b () ) with Accumulator
11875   0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
11877   0x20    JR NZ, N        07          ;  Jump relative 0x07 (7) if ZERO flag is 0
11879   0xdd    LD (IX+d), B    0f          ;  Load location ( IX + 0x0f () ) with register B
11882   0xdd    LOAD (IX + N),              ;  Decrement location ( IX + 0x0d () ) with 0x00 ()
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
11886   0xdd    DEC (IX + N)    0c          ;  Decrement location IX + 0x0c ()
11889   0x20    JR NZ, N        5a          ;  Jump relative 0x5a (90) if ZERO flag is 0
11891   0xdd    LD A, (IX+d)    08          ;  Load Accumulator with location ( IX + 0x08 () )
11894   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
11895   0x28    JR Z, N         10          ;  Jump relative 0x10 (16) if ZERO flag is 1
11897   0xdd    DEC (IX + N)    08          ;  Decrement location IX + 0x08 ()
11900   0x20    JR NZ, N        0b          ;  Jump relative 0x0b (11) if ZERO flag is 0
; I had 11902-11910 asterisk'ed... why?  Is this code unreachable?
11902   0x7b    LD A, E                     ;  Load Accumulator with register E
11903   0x2f    CPL                         ;  Complement Accumulator (1's complement)
11904   0xdd    AND A, (IX+d)   00          ;  Bitwise AND location ( IX + 0x00 () ) with Accumulator
11907   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
11910   0xc3    JP NN           ee2d        ;  Jump to 0xee2d (11758)
11913   0xdd    LD A, (IX+d)    06          ;  Load Accumulator with location ( IX + 0x06 () )
11916   0xe6    AND N           7f          ;  Bitwise AND of 0x7f (127) to Accumulator
11918   0xdd    LD (IX+d), A    0c          ;  Load location ( IX + 0x0c () ) with Accumulator
11921   0xdd    BIT 7, (IX+d)   06          ;  Test bit 7 of ( IX + 0x06 )
11925   0x28    JR Z, N         16          ;  Jump relative 0x16 (22) if ZERO flag is 1
11927   0xdd    LD A, (IX+d)    05          ;  Load Accumulator with location ( IX + 0x05 () )
11930   0xed    NEG                         ;  Negate Accumulator (2's compliment)
11932   0xdd    LD (IX+d), A    05          ;  Load location ( IX + 0x05 () ) with Accumulator
11935   0xdd    BIT 0, (IX+d)   0d          ;  Test bit 0 of ( IX + 0x0d )
11939   0xdd    SET 0, (IX+d)   0d          ;  Set bit 0 of ( IX + 0x0d )
11943   0x28    JR Z, N         24          ;  Jump relative 0x24 (36) if ZERO flag is 1
11945   0xdd    RES 0, (IX+d)   0d          ;  Reset bit 0 of ( IX + 0x0d )
11949   0xdd    LD A, (IX+d)    04          ;  Load Accumulator with location ( IX + 0x04 () )
11952   0xdd    ADD A, (IX+d)   07          ;  Add location ( IX + 0x07 () ) to Accumulator
11955   0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
11958   0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
11961   0xdd    LD A, (IX+d)    09          ;  Load Accumulator with location ( IX + 0x09 () )
11964   0xdd    ADD A, (IX+d)   0a          ;  Add location ( IX + 0x0a () ) to Accumulator
11967   0xdd    LD (IX+d), A    09          ;  Load location ( IX + 0x09 () ) with Accumulator
11970   0x47    LD B, A                     ;  Load register B with Accumulator
11971   0xdd    LD A, (IX+d)    0b          ;  Load Accumulator with location ( IX + 0x0b () )
11974   0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
11976   0x20    JR NZ, N        03          ;  Jump relative 0x03 (3) if ZERO flag is 0
11978   0xdd    LD (IX+d), B    0f          ;  Load location ( IX + 0x0f () ) with register B

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
11981   0xdd    LD A, (IX+d)    0e          ;  Load Accumulator with location ( IX + 0x0e () )
11984   0xdd    ADD A, (IX+d)   05          ;  Add location ( IX + 0x05 () ) to Accumulator
11987   0xdd    LD (IX+d), A    0e          ;  Load location ( IX + 0x0e () ) with Accumulator
11990   0x6f    LD L, A                     ;  Load register L with Accumulator
11991   0x26    LD H, N         00          ;  Load register H with 0x00 (0)
11993   0xdd    LD A, (IX+d)    03          ;  Load Accumulator with location ( IX + 0x03 () )
11996   0xe6    AND N           70          ;  Bitwise AND of 0x70 (112) to Accumulator
11998   0x28    JR Z, N         08          ;  Jump relative 0x08 (8) if ZERO flag is 1
12000   0x0f    RRCA                        ;  Rotate right circular Accumulator
12001   0x0f    RRCA                        ;  Rotate right circular Accumulator
12002   0x0f    RRCA                        ;  Rotate right circular Accumulator
12003   0x0f    RRCA                        ;  Rotate right circular Accumulator
12004   0x47    LD B, A                     ;  Load register B with Accumulator
12005   0x29    ADD HL, HL                  ;  Add register pair HL to HL
12006   0x10    DJNZ N          fd          ;  Decrement B and jump relative 0xfd (-3) if B!=0
12008   0xfd    LD (IY+d), L    00          ;  Load location ( IY + 0x00 () ) with register L
12011   0x7d    LD A, L                     ;  Load Accumulator with register L
12012   0x0f    RRCA                        ;  Rotate right circular Accumulator
12013   0x0f    RRCA                        ;  Rotate right circular Accumulator
12014   0x0f    RRCA                        ;  Rotate right circular Accumulator
12015   0x0f    RRCA                        ;  Rotate right circular Accumulator
12016   0xfd    LD (IY+d), A    01          ;  Load location ( IY + 0x01 () ) with Accumulator
12019   0xfd    LD (IY+d), H    02          ;  Load location ( IY + 0x02 () ) with register H
12022   0x7c    LD A, H                     ;  Load Accumulator with register H
12023   0x0f    RRCA                        ;  Rotate right circular Accumulator
12024   0x0f    RRCA                        ;  Rotate right circular Accumulator
12025   0x0f    RRCA                        ;  Rotate right circular Accumulator
12026   0x0f    RRCA                        ;  Rotate right circular Accumulator
12027   0xfd    LD (IY+d), A    03          ;  Load location ( IY + 0x03 () ) with Accumulator
12030   0xdd    LD A, (IX+d)    0b          ;  Load Accumulator with location ( IX + 0x0b () )
12033   0xe7    RST 0x20                    ;  Restart to location 0x20 (32) (Reset)
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
12066   0xdd    LD A, (IX+d)    0f          ;  Load Accumulator with location ( IX + 0x0f () )
12069   0xc9    RET                         ;  Return


; if ( A = $(IX+15) & 0x0F ) A = --$(IX+15);  return;    // via jump
12070   0xdd    LD A, (IX+d)    0f          ;  Load Accumulator with location ( IX + 0x0f () )
12073   0x18    JR N            09          ;  Jump relative 0x09 (9)
; if ( $4C84 & 0x01 ) return;  if ( A = $(IX+15) & 0x0F ) A = --$(IX+15);  return;
12075   0x3a    LD A, (NN)      844c        ;  Load Accumulator with location 0x844c (19588)
12078   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
12080   0xdd    LD A, (IX+d)    0f          ;  Load Accumulator with location ( IX + 0x0f () )
12083   0xc0    RET NZ                      ;  Return if ZERO flag is 0
12084   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
12086   0xc8    RET Z                       ;  Return if ZERO flag is 1
12087   0x3d    DEC A                       ;  Decrement Accumulator
12088   0xdd    LD (IX+d), A    0f          ;  Load location ( IX + 0x0f () ) with Accumulator
12091   0xc9    RET                         ;  Return


; if ( $4C84 & 0x03 ) return;  if ( A = $(IX+15) & 0x0F ) A = --$(IX+15);  return;    // via jump
12092   0x3a    LD A, (NN)      844c        ;  Load Accumulator with location 0x844c (19588)
12095   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
12097   0x18    JR N            ed          ;  Jump relative 0xed (-19)


; if ( $4C84 & 0x07 ) return;  if ( A = $(IX+15) & 0x0F ) A = --$(IX+15);  return;    // via jump
12099   0x3a    LD A, (NN)      844c        ;  Load Accumulator with location 0x844c (19588)
12102   0xe6    AND N           07          ;  Bitwise AND of 0x07 (7) to Accumulator
12104   0x18    JR N            e6          ;  Jump relative 0xe6 (-26)


12106   0xc9    RET                         ;  Return
12107   0xc9    RET                         ;  Return
12108   0xc9    RET                         ;  Return
12109   0xc9    RET                         ;  Return
12110   0xc9    RET                         ;  Return
12111   0xc9    RET                         ;  Return
12112   0xc9    RET                         ;  Return
12113   0xc9    RET                         ;  Return
12114   0xc9    RET                         ;  Return
12115   0xc9    RET                         ;  Return
12116   0xc9    RET                         ;  Return


; dereference_IX67();
; $(IX+6/7) = $$(IX+6/7);
12117   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
12120   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
12123   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
12124   0xdd    LD (IX+d), A    06          ;  Load location ( IX + 0x06 () ) with Accumulator
12127   0x23    INC HL                      ;  Increment register pair HL
12128   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
12129   0xdd    LD (IX+d), A    07          ;  Load location ( IX + 0x07 () ) with Accumulator
12132   0xc9    RET                         ;  Return


; IX67_to_IX3();
; $(IX+3) = $$(IX+6/7);  $(IX+6/7)++;
12133   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
12136   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
12139   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
12140   0x23    INC HL                      ;  Increment register pair HL
12141   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
12144   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
12147   0xdd    LD (IX+d), A    03          ;  Load location ( IX + 0x03 () ) with Accumulator
12150   0xc9    RET                         ;  Return


; IX67_to_IX4();
; $(IX+4) = $$(IX+6/7);  $(IX+6/7)++;
12151   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
12154   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
12157   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
12158   0x23    INC HL                      ;  Increment register pair HL
12159   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
12162   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
12165   0xdd    LD (IX+d), A    04          ;  Load location ( IX + 0x04 () ) with Accumulator
12168   0xc9    RET                         ;  Return


; IX67_to_IX9();
; $(IX+9) = $$(IX+6/7);  $(IX+6/7)++;
12169   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
12172   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
12175   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
12176   0x23    INC HL                      ;  Increment register pair HL
12177   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
12180   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
12183   0xdd    LD (IX+d), A    09          ;  Load location ( IX + 0x09 () ) with Accumulator
12186   0xc9    RET                         ;  Return


; IX67_to_IX11();
; $(IX+11) = $$(IX+6/7);  $(IX+6/7)++;
12187   0xdd    LD L, (IX + N)  06          ;  Load register L with location ( IX + 0x06 () )
12190   0xdd    LD H, (IX + N)  07          ;  Load register H with location ( IX + 0x07 () )
12193   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
12194   0x23    INC HL                      ;  Increment register pair HL
12195   0xdd    LD (IX+d), L    06          ;  Load location ( IX + 0x06 () ) with register L
12198   0xdd    LD (IX+d), H    07          ;  Load location ( IX + 0x07 () ) with register H
12201   0xdd    LD (IX+d), A    0b          ;  Load location ( IX + 0x0b () ) with Accumulator
12204   0xc9    RET                         ;  Return


; $IX &= compliment($IX2);
; jump(11764);
12205   0xdd    LD A, (IX+d)    02          ;  Load Accumulator with location ( IX + 0x02 () )
12208   0x2f    CPL                         ;  Complement Accumulator (1's complement)
12209   0xdd    AND A, (IX+d)   00          ;  Bitwise AND location ( IX + 0x00 () ) with Accumulator
12212   0xdd    LD (IX+d), A    00          ;  Load location ( IX + 0x00 () ) with Accumulator
12215   0xc3    JP NN           f42d        ;  Jump to 0xf42d (11764)


12218   0x00    NOP                         ;  No Operation
12219   0x00    NOP                         ;  No Operation
12220   0x00    NOP                         ;  No Operation
12221   0x00    NOP                         ;  No Operation
12222   0x00    NOP                         ;  No Operation
12223   0x00    NOP                         ;  No Operation
12224   0x00    NOP                         ;  No Operation
12225   0x00    NOP                         ;  No Operation
12226   0x00    NOP                         ;  No Operation
12227   0x00    NOP                         ;  No Operation
12228   0x00    NOP                         ;  No Operation
12229   0x00    NOP                         ;  No Operation
12230   0x00    NOP                         ;  No Operation
12231   0x00    NOP                         ;  No Operation
12232   0x00    NOP                         ;  No Operation
12233   0x00    NOP                         ;  No Operation
12234   0x00    NOP                         ;  No Operation
12235   0x00    NOP                         ;  No Operation
12236   0x00    NOP                         ;  No Operation
12237   0x00    NOP                         ;  No Operation
12238   0x00    NOP                         ;  No Operation
12239   0x00    NOP                         ;  No Operation
12240   0x00    NOP                         ;  No Operation
12241   0x00    NOP                         ;  No Operation
12242   0x00    NOP                         ;  No Operation
12243   0x00    NOP                         ;  No Operation
12244   0x00    NOP                         ;  No Operation
12245   0x00    NOP                         ;  No Operation
12246   0x00    NOP                         ;  No Operation
12247   0x00    NOP                         ;  No Operation
12248   0x00    NOP                         ;  No Operation
12249   0x00    NOP                         ;  No Operation
12250   0x00    NOP                         ;  No Operation
12251   0x00    NOP                         ;  No Operation
12252   0x00    NOP                         ;  No Operation
12253   0x00    NOP                         ;  No Operation
12254   0x00    NOP                         ;  No Operation
12255   0x00    NOP                         ;  No Operation
12256   0x00    NOP                         ;  No Operation
12257   0x00    NOP                         ;  No Operation
12258   0x00    NOP                         ;  No Operation
12259   0x00    NOP                         ;  No Operation
12260   0x00    NOP                         ;  No Operation
12261   0x00    NOP                         ;  No Operation
12262   0x00    NOP                         ;  No Operation
12263   0x00    NOP                         ;  No Operation
12264   0x00    NOP                         ;  No Operation
12265   0x00    NOP                         ;  No Operation
12266   0x00    NOP                         ;  No Operation
12267   0x00    NOP                         ;  No Operation
12268   0x00    NOP                         ;  No Operation
12269   0x00    NOP                         ;  No Operation
12270   0x00    NOP                         ;  No Operation
12271   0x00    NOP                         ;  No Operation
12272   0x00    NOP                         ;  No Operation
12273   0x00    NOP                         ;  No Operation
12274   0x00    NOP                         ;  No Operation
12275   0x00    NOP                         ;  No Operation
12276   0x00    NOP                         ;  No Operation
12277   0x00    NOP                         ;  No Operation
12278   0x00    NOP                         ;  No Operation
12279   0x00    NOP                         ;  No Operation
12280   0x00    NOP                         ;  No Operation
12281   0x00    NOP                         ;  No Operation
12282   0x00    NOP                         ;  No Operation
12283   0x00    NOP                         ;  No Operation
12284   0x00    NOP                         ;  No Operation
12285   0x00    NOP                         ;  No Operation

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
12288   0x21    LD HL, NN       0000        ;  Load register pair HL with 0x0000 (0)
12291   0x01    LD  BC, NN      0010        ;  Load register pair BC with 0x0010 (4096)
; Watchdog set to A
12294   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
12297   0x79    LD A, C                     ;  Load Accumulator with register C
12298   0x86    ADD A, (HL)                 ;  Add location (HL) to Accumulator (no carry)
12299   0x4f    LD C, A                     ;  Load register C with Accumulator
12300   0x7d    LD A, L                     ;  Load Accumulator with register L
12301   0xc6    ADD A, N        02          ;  Add 0x02 (2) to Accumulator (no carry)
12303   0x6f    LD L, A                     ;  Load register L with Accumulator
12304   0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
12306   0xd2    JP NC, NN       0930        ;  Jump to 0x0930 (12297) if CARRY flag is 0
12309   0x24    INC H                       ;  Increment register H
12310   0x10    DJNZ N          ee          ;  Decrement B and jump relative 0xee (-18) if B!=0
12312   0x79    LD A, C                     ;  Load Accumulator with register C
12313   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
; often patched to NOP, NOP to defeat ROM checksum
12314   0x20    JR NZ, N        15          ;  Jump relative 0x15 (21) if ZERO flag is 0
; Clear coin
12316   0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
12319   0x7c    LD A, H                     ;  Load Accumulator with register H
12320   0xfe    CP N            30          ;  Compare 0x30 (48) with Accumulator
12322   0xc2    JP NZ, NN       0330        ;  Jump to 0x0330 (12291) if ZERO flag is 0
12325   0x26    LD H, N         00          ;  Load register H with 0x00 (0)
12327   0x2c    INC L                       ;  Increment register L
12328   0x7d    LD A, L                     ;  Load Accumulator with register L
12329   0xfe    CP N            02          ;  Compare 0x02 (2) with Accumulator
12331   0xda    JP C, NN        0330        ;  Jump to 0x0330 (12291) if CARRY flag is 1
12334   0xc3    JP NN           4230        ;  Jump to 0x4230 (12354)


;;; checksum_failure()
; // H == { 0x10, 0x20, 0x30, 0x40 } // top nibble of the last 1K page CRC'ed before failure + 1
; H--;
; H &= 0xf0;
; (char *)(0xC007) = A;  // clear coincounter
; H = H << 4;            // wraps around.  Now H = { 0x00, 0x01, 0x02, 0x03 }
; E = H;
; B = 0;
; jump(12477); // B == 0, E == which 1k page failed checksum
12337   0x25    DEC H                       ;  Decrement register H
12338   0x7c    LD A, H                     ;  Load Accumulator with register H
12339   0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
12341   0x32    LD (NN), A      0750        ;  Load location 0x0750 (20487) with the Accumulator
12344   0x0f    RRCA                        ;  Rotate right circular Accumulator
12345   0x0f    RRCA                        ;  Rotate right circular Accumulator
12346   0x0f    RRCA                        ;  Rotate right circular Accumulator
12347   0x0f    RRCA                        ;  Rotate right circular Accumulator
12348   0x5f    LD E, A                     ;  Load register E with Accumulator
12349   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)
12351   0xc3    JP NN           bd30        ;  Jump to 0xbd30 (12477)

;;; video_test()
; checksum ok... let's continue
; Clear $4C00-$4FFF with random numbers
; //$C = 255;  // to start
; Location = $C
; 0..15 : $C = ( ( $C & 0x0F ) + 51 ) % 256;
;    16 : $C = ( ( ( ( $C & 0x0F ) + 51 ) * 5 ) + 49 ) % 256;
;; Pattern repeats every 256 iterations.
12354   0x31    LD SP, NN       5431        ;  Load register pair SP with 0x5431 (12628)
12357   0x06    LD  B, N        ff          ;  Load register B with 0xff (255)
; HL = 0x4C00
12359   0xe1    POP HL                      ;  Load register pair HL with top of stack
; DE = 0x040F
12360   0xd1    POP DE                      ;  Load register pair DE with top of stack
12361   0x48    LD C, B                     ;  Load register C with register B
; Watchdog set to A
12362   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator

; wild random number generator for clearing RAM
12365   0x79    LD A, C                     ;  Load Accumulator with register C
12366   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
; (HL)=C & 0x0F
12367   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
12368   0xc6    ADD A, N        33          ;  Add 0x33 (51) to Accumulator (no carry)
12370   0x4f    LD c, A                     ;  Load register C with Accumulator
12371   0x2c    INC L                       ;  Increment register L
12372   0x7d    LD A, L                     ;  Load Accumulator with register L
12373   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
12375   0xc2    JP NZ, NN       4d30        ;  Jump to 0x4d30 (12365) if ZERO flag is 0
; next 6: C = (C*5 + 49) % 256
12378   0x79    LD A, C                     ;  Load Accumulator with register C
12379   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
12380   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
12381   0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
12382   0xc6    ADD A, N        31          ;  Add 0x31 (49) to Accumulator (no carry)
12384   0x4f    LD c, A                     ;  Load register C with Accumulator
12385   0x7d    LD A, L                     ;  Load Accumulator with register L
12386   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
12387   0xc2    JP NZ, NN       4d30        ;  Jump to 0x4d30 (12365) if ZERO flag is 0

12390   0x24    INC H                       ;  Increment register H
12391   0x15    DEC D                       ;  Decrement register D
12392   0xc2    JP NZ, NN       4a30        ;  Jump to 0x4a30 (12362) if ZERO flag is 0

; back up stack and do the same algorithm, but just read and verify
12395   0x3b    DEC SP                      ;  Decrement register pair SP
12396   0x3b    DEC SP                      ;  Decrement register pair SP
12397   0x3b    DEC SP                      ;  Decrement register pair SP
12398   0x3b    DEC SP                      ;  Decrement register pair SP
12399   0xe1    POP HL                      ;  Load register pair HL with top of stack
12400   0xd1    POP DE                      ;  Load register pair DE with top of stack
12401   0x48    LD C, B                     ;  Load register C with register B
12402   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; next 3: Similiar to 12367, but reading back instead
12405   0x79    LD A, C                     ;  Load Accumulator with register C
12406   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
12407   0x4f    LD c, A                     ;  Load register C with Accumulator
12408   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
12409   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
12410   0xb9    CP A, C                     ;  Compare register C with Accumulator
; Jump to 12469 if any byte fails verification
12411   0xc2    JP NZ, NN       b530        ;  Jump to 0xb530 (12469) if ZERO flag is 0
12414   0xc6    ADD A, N        33          ;  Add 0x33 (51) to Accumulator (no carry)
12416   0x4f    LD c, A                     ;  Load register C with Accumulator
12417   0x2c    INC L                       ;  Increment register L
12418   0x7d    LD A, L                     ;  Load Accumulator with register L
12419   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
12421   0xc2    JP NZ, NN       7530        ;  Jump to 0x7530 (12405) if ZERO flag is 0
; next 6: C = (C*5 + 49) % 256
12424   0x79    LD A, C                     ;  Load Accumulator with register C
12425   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
12426   0x87    ADD A, A                    ;  Add Accumulator to Accumulator (no carry)
12427   0x81    ADD A, C                    ;  Add register C to Accumulator (no carry)
12428   0xc6    ADD A, N        31          ;  Add 0x31 (49) to Accumulator (no carry)
12430   0x4f    LD c, A                     ;  Load register C with Accumulator
12431   0x7d    LD A, L                     ;  Load Accumulator with register L
12432   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
12433   0xc2    JP NZ, NN       7530        ;  Jump to 0x7530 (12405) if ZERO flag is 0
12436   0x24    INC H                       ;  Increment register H
12437   0x15    DEC D                       ;  Decrement register D
12438   0xc2    JP NZ, NN       7230        ;  Jump to 0x7230 (12402) if ZERO flag is 0

;
12441   0x3b    DEC SP                      ;  Decrement register pair SP
12442   0x3b    DEC SP                      ;  Decrement register pair SP
12443   0x3b    DEC SP                      ;  Decrement register pair SP
12444   0x3b    DEC SP                      ;  Decrement register pair SP
12445   0x78    LD A, B                     ;  Load Accumulator with register B
12446   0xd6    SUB N           10          ;  Subtract 0x10 (16) from Accumulator (no carry)
12448   0x47    LD B, A                     ;  Load register B with Accumulator
; Do the test 16 times
12449   0x10    DJNZ N          a4          ;  Decrement B and jump relative 0xa4 (-92) if B!=0

;  Different behavior based on the area being tested?  Seems like this function could take
;  multiple memory areas if the table was properly pre-populated
12451   0xf1    POP AF                      ;  Load register pair AF with top of stack
12452   0xd1    POP DE                      ;  Load register pair DE with top of stack
12453   0xfe    CP N            44          ;  Compare 0x44 (68) with Accumulator
12455   0xc2    JP NZ, NN       4530        ;  Jump to 0x4530 (12357) if ZERO flag is 0
12458   0x7b    LD A, E                     ;  Load Accumulator with register E
12459   0xee    XOR N           f0          ;  Bitwise XOR of 0xf0 (240) to Accumulator
12461   0xc2    JP NZ, NN       4530        ;  Jump to 0x4530 (12357) if ZERO flag is 0
12464   0x06    LD  B, N        01          ;  Load register B with 0x01 (1)
12466   0xc3    JP NN           bd30        ;  Jump to 0xbd30 (12477)

;; failed color RAM test, set some params, fall through to clear screen, then display error codes
; E = (E & 0x01) ^ 0x01;  // mask and invert E:0
12469   0x7b    LD A, E                     ;  Load Accumulator with register E
12470   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
12472   0xee    XOR N           01          ;  Bitwise XOR of 0x01 (1) to Accumulator
12474   0x5f    LD E, A                     ;  Load register E with Accumulator
12475   0x06    LD  B, N        00          ;  Load register B with 0x00 (0)


; CLEAR RAM()
; Swap out BC,DE,HL...
12477   0x31    LD SP, NN       c04f        ;  Load register pair SP with 0xc04f (20416)
12480   0xd9    EXX                         ;  Exchange the contents of BC,DE,HL with BC',DE',HL'

; ...and clear 0x4C00-0x4FFF...
12481   0x21    LD HL, NN       004c        ;  Load register pair HL with 0x004c (19456)
12484   0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
; (reset watchdog)
12486   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
12489   0x36    LD (HL), N      00          ;  Load location (HL) with 0x00 (0)
12491   0x2c    INC L                       ;  Increment register L
12492   0x20    JR NZ, N        fb          ;  Jump relative 0xfb (-5) if ZERO flag is 0
12494   0x24    INC H                       ;  Increment register H
12495   0x10    DJNZ N          f5          ;  Decrement B and jump relative 0xf5 (-11) if B!=0

; ...then clear video memory (0x4000-0x43FF) with spaces (0x40)...
12497   0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
12500   0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
; (reset watchdog)
12502   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
12505   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
12507   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
12508   0x2c    INC L                       ;  Increment register L
12509   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
12511   0x24    INC H                       ;  Increment register H
12512   0x10    DJNZ N          f4          ;  Decrement B and jump relative 0xf4 (-12) if B!=0

; ...then clear color memory (0x4400-0x47FF) with white/green/red/black palette (0x0F)...
12514   0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
12516   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
12519   0x3e    LD A,N          0f          ;  Load Accumulator with 0x0f (15)
12521   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
12522   0x2c    INC L                       ;  Increment register L
12523   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
12525   0x24    INC H                       ;  Increment register H
12526   0x10    DJNZ N          f4          ;  Decrement B and jump relative 0xf4 (-12) if B!=0
; ...and swap BC,DE,HL back in
12528   0xd9    EXX                         ;  Exchange the contents of BC,DE,HL with BC',DE',HL'

; B--;  if ( B==0 ) {  B=35;  call(11358);  jump(12660);  }
;       else {  jump(12539);  } // in checksum failure B != 0
12529   0x10    DJNZ N          08          ;  Decrement B and jump relative 0x08 (8) if B!=0
; write_string(35); "MEMORY  OK"
12531   0x06    LD  B, N        23          ;  Load register B with 0x23 (35)
12533   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
12536   0xc3    JP NN           7431        ;  Jump to 0x7431 (12660)

; Display the page that failed the checksum
; // E == { 0x00, 0x01, 0x02, 0x03 } // page that failed the checksum
; A = E;
; E += 0x30;                         // ASCII 0x30 = '0', 0x31 = '1', etc.
; (char *)(0x4184) = A;              // four from the top, just left of center on playing field
12539   0x7b    LD A, E                     ;  Load Accumulator with register E
12540   0xc6    ADD A, N        30          ;  Add 0x30 (48) to Accumulator (no carry)
12542   0x32    LD (NN), A      8441        ;  Load location 0x8441 (16772) with the Accumulator

; write_string(36); "BAD    R M"
12545   0xc5    PUSH BC                     ;  Load the stack with register pair BC
12546   0xe5    PUSH HL                     ;  Load the stack with register pair HL
12547   0x06    LD  B, N        24          ;  Load register B with 0x24 (36)
12549   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

; HL = pop();
; A = H;
; A == 0..64  : HL = 0x316C; //  0x4F, 0x40 "O "
; A == 65..68 : HL = 0x3170; //  0x41, 0x56 "AV"
; A == 69..75 : HL = 0x3172; //  0x41, 0x43 "AC"
; A == 76.... : HL = 0x316E; //  0x41, 0x57 "AW"
12552   0xe1    POP HL                      ;  Load register pair HL with top of stack
12553   0x7c    LD A, H                     ;  Load Accumulator with register H
12554   0xfe    CP N            40          ;  Compare 0x40 (64) with Accumulator
12556   0x2a    LD HL, (NN)     6c31        ;  Load register pair HL with location 0x6c31 (12652)
12559   0x38    JR C, N         11          ;  Jump relative 0x11 (17) if CARRY flag is 1
12561   0xfe    CP N            4c          ;  Compare 0x4c (76) with Accumulator
12563   0x2a    LD HL, (NN)     6e31        ;  Load register pair HL with location 0x6e31 (12654)
12566   0x30    JR NC, N        0a          ;  Jump relative 0x0a (10) if CARRY flag is 0
12568   0xfe    CP N            44          ;  Compare 0x44 (68) with Accumulator
12570   0x2a    LD HL, (NN)     7031        ;  Load register pair HL with location 0x7031 (12656)
12573   0x38    JR C, N         03          ;  Jump to 0x03 (3) if CARRY flag is 1
12575   0x2a    LD HL, (NN)     7231        ;  Load register pair HL with location 0x7231 (12658)
; $4204 = L;
; $4264 = H;
12578   0x7d    LD A, L                     ;  Load Accumulator with register L
12579   0x32    LD (NN), A      0442        ;  Load location 0x0442 (16900) with the Accumulator
12582   0x7c    LD A, H                     ;  Load Accumulator with register H
12583   0x32    LD (NN), A      6442        ;  Load location 0x6442 (16996) with the Accumulator
; if ( $5000 | $5040 & 0x01 ) // either joystick is 'up'
; {
;     BC = pop();
;     B = C & 0x0F;
;     C &= 0xF0;
;     C C>> 4;
;     $4185 = BC;
; }
12586   0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
12589   0x47    LD B, A                     ;  Load register B with Accumulator
12590   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
12593   0xb0    OR A, B                     ;  Bitwise OR of register B to Accumulator
12594   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
12596   0x20    JR NZ, N        11          ;  Jump relative 0x11 (17) if ZERO flag is 0
12598   0xc1    POP BC                      ;  Load register pair BC with top of stack
12599   0x79    LD A, C                     ;  Load Accumulator with register C
12600   0xe6    AND N           0f          ;  Bitwise AND of 0x0f (15) to Accumulator
12602   0x47    LD B, A                     ;  Load register B with Accumulator
12603   0x79    LD A, C                     ;  Load Accumulator with register C
12604   0xe6    AND N           f0          ;  Bitwise AND of 0xf0 (240) to Accumulator
12606   0x0f    RRCA                        ;  Rotate right circular Accumulator
12607   0x0f    RRCA                        ;  Rotate right circular Accumulator
12608   0x0f    RRCA                        ;  Rotate right circular Accumulator
12609   0x0f    RRCA                        ;  Rotate right circular Accumulator
12610   0x4f    LD c, A                     ;  Load register C with Accumulator
12611   0xed    LD (NN), BC     8541        ;  Load location 0x8541 (16773) with register pair BC
; repeat { kick_dog() } until ( servicemode != 1 );
12615   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
12618   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
12621   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
12623   0x28    JR Z, N         f6          ;  Jump relative 0xf6 (-10) if ZERO flag is 1
12625   0xc3    JP NN           0b23        ;  Jump to 0x0b23 (8971)

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
12660   0x21    LD HL, NN       0650        ;  Load register pair HL with 0x0650 (20486)
12663   0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
12665   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
12666   0x2d    DEC L                       ;  Decrement register L
12667   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
; flip the screen back to normal (0x5003 = 0)
12669   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
12670   0x32    LD (NN), A      0350        ;  Load location 0x0350 (20483) with the Accumulator
; Set interrupt vector for V-Sync to entry 252 ($(3F00+FC) == 0x8D00 == 141)
12673   0xd6    SUB N           04          ;  Subtract 0x04 (4) from Accumulator (no carry)
12675   0xd3    OUT (N),A       00          ;  Load output port 0x00 (0) with Accumulator
12677   0x31    LD SP, NN       c04f        ;  Load register pair SP with 0xc04f (20416)

; (reset watchdog)
12680   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; (0x4E00) = 0, (0x4E01) = 1
12683   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
12684   0x32    LD (NN), A      004e        ;  Load location 0x004e (19968) with the Accumulator
12687   0x3c    INC A                       ;  Increment Accumulator
12688   0x32    LD (NN), A      014e        ;  Load location 0x014e (19969) with the Accumulator
; Arm external interrupt latch, enable interrupts
12691   0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
12694   0xfb    EI                          ;  Enable Interrupts

; Read IN0: 01=1up,02=1left,04=1right,08=1down,10=rack test,20=coin 1,40=coin 2,80=coin 3
; Set (0x4E9C) to 2 if we have coins
; Leave a copy of complimented IN0 in B
12695   0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
12698   0x2f    CPL                         ;  Complement Accumulator (reverse bitwise)
12699   0x47    LD B, A                     ;  Load register B with Accumulator
12700   0xe6    AND N           e0          ;  Bitwise AND of 0xe0 (224) to Accumulator
12702   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
12704   0x3e    LD A,N          02          ;  Load Accumulator with 0x02 (2)
12706   0x32    LD (NN), A      9c4e        ;  Load location 0x9c4e (20124) with the Accumulator

; Read IN1: 01=2up,02=2left,04=2right,08=2down,10=service,20=start 1,40=start 2,80=cabinet upright
; Set (0x4E9E) to 1 if we have player 1 or 2 start
; Leave a copy of complimented IN1 in C
12709   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
12712   0x2f    CPL                         ;  Complement Accumulator (reverse bitwise)
12713   0x4f    LD c, A                     ;  Load register C with Accumulator
12714   0xe6    AND N           60          ;  Bitwise AND of 0x60 (96) to Accumulator
12716   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
12718   0x3e    LD A,N          01          ;  Load Accumulator with 0x01 (1)
12720   0x32    LD (NN), A      9c4e        ;  Load location 0x9c4e (20124) with the Accumulator

; If either joystick is pointing up ((B|C)&0x01), set (0x4EBC) to 8
12723   0x78    LD A, B                     ;  Load Accumulator with register B
12724   0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
12725   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
12727   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
12729   0x3e    LD A,N          08          ;  Load Accumulator with 0x08 (8)
12731   0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator

; If either joystick is pointing left ((B|C)&0x02), set (0x4EBC) to 4
12734   0x78    LD A, B                     ;  Load Accumulator with register B
12735   0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
12736   0xe6    AND N           02          ;  Bitwise AND of 0x02 (2) to Accumulator
12738   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
12740   0x3e    LD A,N          04          ;  Load Accumulator with 0x04 (4)
12742   0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator

; If either joystick is pointing right ((B|C)&0x02), set (0x4EBC) to 16
12745   0x78    LD A, B                     ;  Load Accumulator with register B
12746   0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
12747   0xe6    AND N           04          ;  Bitwise AND of 0x04 (4) to Accumulator
12749   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
12751   0x3e    LD A,N          10          ;  Load Accumulator with 0x10 (16)
12753   0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator

; If either joystick is pointing down ((B|C)&0x02), set (0x4EBC) to 32
12756   0x78    LD A, B                     ;  Load Accumulator with register B
12757   0xb1    OR A, C                     ;  Bitwise OR of register C to Accumulator
12758   0xe6    AND N           08          ;  Bitwise AND of 0x08 (8) to Accumulator
12760   0x28    JR Z, N         05          ;  Jump relative 0x05 (5) if ZERO flag is 1
12762   0x3e    LD A,N          20          ;  Load Accumulator with 0x20 (32)
12764   0x32    LD (NN), A      bc4e        ;  Load location 0xbc4e (20156) with the Accumulator

; Depending on the value of the 'credit' jumpers (0&1), display the proper message
; 37="FREE  PLAY"
; 38="1 COIN  1 CREDIT " 
; 39="1 COIN  2 CREDITS"
; 40="2 COINS 1 CREDIT "
12767   0x3a    LD A, (NN)      8050        ;  Load Accumulator with location 0x8050 (20608)
12770   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
12772   0xc6    ADD A, N        25          ;  Add 0x25 (37) to Accumulator (no carry)
12774   0x47    LD B, A                     ;  Load register B with Accumulator
12775   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

; Depending on the value of the 'bonus' jumpers (4-7), display the proper message
; 0 = 10000
; 1 = 15000
; 2 = 20000
; 3 = No Bonus
12778   0x3a    LD A, (NN)      8050        ;  Load Accumulator with location 0x8050 (20608)
12781   0x0f    RRCA                        ;  Rotate right circular Accumulator
12782   0x0f    RRCA                        ;  Rotate right circular Accumulator
12783   0x0f    RRCA                        ;  Rotate right circular Accumulator
12784   0x0f    RRCA                        ;  Rotate right circular Accumulator
12785   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
12787   0xfe    CP N            03          ;  Compare 0x03 (3) with Accumulator
12789   0x20    JR NZ, N        08          ;  Jump relative 0x08 (8) if ZERO flag is 0
; No bonus, display "BONUS NONE" and jump over the bonus value display
; write_string(42); // "BONUS  NONE"
12791   0x06    LD  B, N        2a          ;  Load register B with 0x2a (42)
12793   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
12796   0xc3    JP NN           1c32        ;  Jump to 0x1c32 (12828)
; Bonus configured, display the triple zero tile + the number of thousands for the bonus
; after pushing, displaying "BONUS " and "000", and popping, E will contain
; either 0, 2 or 4
12799   0x07    RLCA                        ;  Rotate left circular Accumulator
12800   0x5f    LD E, A                     ;  Load register E with Accumulator
12801   0xd5    PUSH DE                     ;  Load the stack with register pair DE
; write_string(43); "BONUS "
12802   0x06    LD  B, N        2b          ;  Load register B with 0x2b (43)
12804   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
; write_string(46); "000"
12807   0x06    LD  B, N        2e          ;  Load register B with 0x2e (46)
12809   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)
12812   0xd1    POP DE                      ;  Load register pair DE with top of stack
12813   0x16    LD  D, N        00          ;  Load register D with 0x00 (0)
; Index into the small table at 0x32F9 for the bonus sprite, write it to the screen at
; (0x422A) (remember, right to left, so this is the less significant digit of the two)
12815   0x21    LD HL, NN       f932        ;  Load register pair HL with 0xf932 (13049)
12818   0x19    ADD HL, DE                  ;  Add register pair DE to HL
12819   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
12820   0x32    LD (NN), A      2a42        ;  Load location 0x2a42 (16938) with the Accumulator
; ... and display the second bonus display sprite (the more significant of the two)
12823   0x23    INC HL                      ;  Increment register pair HL
12824   0x7e    LD A, (HL)                  ;  Load Accumulator with location (HL)
12825   0x32    LD (NN), A      4a42        ;  Load location 0x4a42 (16970) with the Accumulator

; Lives per play (jumpers 2&3)
; 0 = 1
; 1 = 2
; 2 = 3
; 3 = 5
12828   0x3a    LD A, (NN)      8050        ;  Load Accumulator with location 0x8050 (20608)
12831   0x0f    RRCA                        ;  Rotate right circular Accumulator
12832   0x0f    RRCA                        ;  Rotate right circular Accumulator
12833   0xe6    AND N           03          ;  Bitwise AND of 0x03 (3) to Accumulator
; Accomodate 3 by adding 1; otherwise jumpers + 31 == correct number byte
12835   0xc6    ADD A, N        31          ;  Add 0x31 (49) to Accumulator (no carry)
12837   0xfe    CP N            34          ;  Compare 0x34 (52) with Accumulator
12839   0x20    JR NZ, N        01          ;  Jump relative 0x01 (1) if ZERO flag is 0
12841   0x3c    INC A                       ;  Increment Accumulator
12842   0x32    LD (NN), A      0c42        ;  Load location 0x0c42 (16908) with the Accumulator

; write_string(41); "PAC-MAN"
12845   0x06    LD  B, N        29          ;  Load register B with 0x29 (41)
12847   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

; Read IN0: 01=2up,02=2left,04=2right,08=2down,10=service,20=start 1,40=start 2,80=cabinet upright
; Display table or upright (0=table, 1=upright)
12850   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
12853   0x07    RLCA                        ;  Rotate left circular Accumulator
12854   0xe6    AND N           01          ;  Bitwise AND of 0x01 (1) to Accumulator
12856   0xc6    ADD A, N        2c          ;  Add 0x2c (44) to Accumulator (no carry)
12858   0x47    LD B, A                     ;  Load register B with Accumulator
12859   0xcd    CALL NN         5e2c        ;  Call to 0x5e2c (11358)

; Keep showing this set of data while the service bit of IN0 is jumpered (remember.. jumpers == opposite)
12862   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
12865   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
12867   0xca    JP Z,           8831        ;  Jump to 0x8831 (12680) if ZERO flag is 1

; Clear Coin1/2/3, Rack Test, Joystick 1
12870   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
12871   0x32    LD (NN), A      0050        ;  Load location 0x0050 (20480) with the Accumulator
12874   0xf3    DI                          ;  Disable Interrupts


; Clear out 0x5007-0x5001 with 0x00
12875   0x21    LD HL, NN       0750        ;  Load register pair HL with 0x0750 (20487)
12878   0xaf    XOR A, A                    ;  Bitwise XOR of Accumulator to Accumulator
12879   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
12880   0x2d    DEC L                       ;  Decrement register L
12881   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0


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
12883   0x31    LD SP, NN       e23a        ;  Load register pair SP with 0xe23a (15074)
12886   0x06    LD  B, N        03          ;  Load register B with 0x03 (3)

12888   0xd9    EXX                         ;  Exchange the contents of BC,DE,HL with BC',DE',HL'
12889   0xe1    POP HL                      ;  Load register pair HL with top of stack
12890   0xd1    POP DE                      ;  Load register pair DE with top of stack
; while ( E != 0 ) 12891 to 12917, E--
; kick dog
12891   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
12894   0xc1    POP BC                      ;  Load register pair BC with top of stack
; for B-1 times (HL=0x3C, HL++, HL=D, HL++ )
12895   0x3e    LD A,N          3c          ;  Load Accumulator with 0x3c (60)
12897   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
12898   0x23    INC HL                      ;  Increment register pair HL
12899   0x72    LD (HL), D                  ;  Load location (HL) with register D
12900   0x23    INC HL                      ;  Increment register pair HL
12901   0x10    DJNZ N          f8          ;  Decrement B and jump relative 0xf8 (-8) if B!=0

; reload BC from stack
12903   0x3b    DEC SP                      ;  Decrement register pair SP
12904   0x3b    DEC SP                      ;  Decrement register pair SP
12905   0xc1    POP BC                      ;  Load register pair BC with top of stack
; for B-1 times (HL=C, HL++, HL=0x3F, HL++ )
12906   0x71    LD (HL), C                  ;  Load location (HL) with register C
12907   0x23    INC HL                      ;  Increment register pair HL
12908   0x3e    LD A,N          3f          ;  Load Accumulator with 0x3f (63)
12910   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
12911   0x23    INC HL                      ;  Increment register pair HL
12912   0x10    DJNZ N          f8          ;  Decrement B and jump relative 0xf8 (-8) if B!=0
12914   0x3b    DEC SP                      ;  Decrement register pair SP
12915   0x3b    DEC SP                      ;  Decrement register pair SP
12916   0x1d    DEC E                       ;  Decrement register E
12917   0xc2    JP NZ, NN       5b32        ;  Jump to 0x5b32 (12891) if ZERO flag is 0

; throw away to advance SP for loop to repeat
12920   0xf1    POP AF                      ;  Load register pair AF with top of stack
12921   0xd9    EXX                         ;  Exchange the contents of BC,DE,HL with BC',DE',HL'
12922   0x10    DJNZ N          dc          ;  Decrement B and jump relative 0xdc (-36) if B!=0

; back to a normal stack
12924   0x31    LD SP, NN       c04f        ;  Load register pair SP with 0xc04f (20416)

; call wait() 7 times
12927   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
12929   0xcd    CALL NN         ed32        ;  Call to 0xed32 (13037)
12932   0x10    DJNZ N          fb          ;  Decrement B and jump relative 0xfb (-5) if B!=0


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
12934   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; Read IN1: 01=2up,02=2left,04=2right,08=2down,10=service,20=start 1,40=start 2,80=cabinet upright
; if service mode, infinite loop until it's not service mode
12937   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
12940   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
12942   0x28    JR Z, N         f6          ;  Jump relative 0xf6 (-10) if ZERO flag is 1
; if neither start button pressed, jump back to right after the HALT after setting V-sync
12944   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
12947   0xe6    AND N           60          ;  Bitwise AND of 0x60 (96) to Accumulator
12949   0xc2    JP NZ, NN       4b23        ;  Jump to 0x4b23 (9035) if ZERO flag is 0

; call wait() 7 times
12952   0x06    LD  B, N        08          ;  Load register B with 0x08 (8)
12954   0xcd    CALL NN         ed32        ;  Call to 0xed32 (13037)
12957   0x10    DJNZ N          fb          ;  Decrement B and jump relative 0xfb (-5) if B!=0

; See if service bit is set again
12959   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
12962   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator

12964   0xc2    JP NZ, NN       4b23        ;  Jump to 0x4b23 (9035) if ZERO flag is 0


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
12967   0x1e    LD E,N          01          ;  Load register E with 0x01 (1)
12969   0x06    LD B,N          04          ;  Load register B with 0x04 (4)
; kick dog
12971   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; wait()
12974   0xcd    CALL NN         ed32        ;  Call to 0xed32 (13037)
; Read IN0: 01=1up,02=1left,04=1right,08=1down,10=rack test,20=coin 1,40=coin 2,80=coin 3
12977   0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
12980   0xa3    AND A, E                    ;  Bitwise AND of register E to Accumulator
12981   0x20    JR NZ, N        f4          ;  Jump relative 0xf4 (-12) if ZERO flag is 0
; wait()
12983   0xcd    CALL NN         ed32        ;  Call to 0xed32 (13037)
; kick dog
12986   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
12989   0x3a    LD A, (NN)      0050        ;  Load Accumulator with location 0x0050 (20480)
12992   0xee    XOR N           ff          ;  Bitwise XOR of 0xff (255) to Accumulator
12994   0x20    JR NZ, N        f3          ;  Jump relative 0xf3 (-13) if ZERO flag is 0
12996   0x10    DJNZ N          e5          ;  Decrement B and jump relative 0xe5 (-27) if B!=0
12998   0xcb    RLC E                       ;  Rotate register E left circular
13000   0x7b    LD A, E                     ;  Load Accumulator with register E
13001   0xfe    CP N            10          ;  Compare 0x10 (16) with Accumulator
13003   0xda    JP C, NN        a932        ;  Jump to 0xa932 (12969) if CARRY flag is 1

; Clear 0x4000-0x43FF with 0x40
13006   0x21    LD HL, NN       0040        ;  Load register pair HL with 0x0040 (16384)
13009   0x06    LD  B, N        04          ;  Load register B with 0x04 (4)
13011   0x3e    LD A,N          40          ;  Load Accumulator with 0x40 (64)
13013   0x77    LD (HL), A                  ;  Load location (HL) with Accumulator
13014   0x2c    INC L                       ;  Increment register L
13015   0x20    JR NZ, N        fc          ;  Jump relative 0xfc (-4) if ZERO flag is 0
13017   0x24    INC H                       ;  Increment register H
13018   0x10    DJNZ N          f7          ;  Decrement B and jump relative 0xf7 (-9) if B!=0
13020   0xcd    CALL NN         f43a        ;  Call to 0xf43a (15092)

; kick dog
13023   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
; hang until rackmode jumper clear
13026   0x3a    LD A, (NN)      4050        ;  Load Accumulator with location 0x4050 (20544)
13029   0xe6    AND N           10          ;  Bitwise AND of 0x10 (16) to Accumulator
13031   0xca    JP Z,           df32        ;  Jump to 0xdf32 (13023) if ZERO flag is 1
; jump back to right after the HALT after setting V-sync
13034   0xc3    JP NN           4b23        ;  Jump to 0x4b23 (9035)


;;; wait()
;; kick dog, count from 10240 down to 0... a primitive wait()?
;; T-states: 13, 10, ( 6, 4, 4, 12 ), 10
;; duration = 13 + 10 + ( ( 6 + 4 + 4 + 12 ) * 10240 ) + 10  =  266240 + 33  =  266273 cycles  =  0.0866s (@3.072Mhz)
13037   0x32    LD (NN), A      c050        ;  Load location 0xc050 (20672) with the Accumulator
13040   0x21    LD HL, NN       0028        ;  Load register pair HL with 0x0028 (10240)
13043   0x2b    DEC HL                      ;  Decrement register pair HL
13044   0x7c    LD A, H                     ;  Load Accumulator with register H
13045   0xb5    OR A, L                     ;  Bitwise OR of register L to Accumulator
13046   0x20    JR NZ, N        fb          ;  Jump relative 0xfb (-5) if ZERO flag is 0
13048   0xc9    RET                         ;  Return

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



13745   0x00    NOP                         ;  No Operation
13746   0x00    NOP                         ;  No Operation
13747   0x00    NOP                         ;  No Operation
13748   0x00    NOP                         ;  No Operation



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
15092   0x21    LD HL, NN       a240        ;  Load register pair HL with 0xa240 (16546)
15095   0x11    LD DE, NN       4f3a        ;  Load register pair DE with 0x4f3a (14927)
15098   0x36    LD (HL), N      14          ;  Load location HL with 0x14 (20)
15100   0x1a    LD  A, (DE)                 ;  Load Accumulator with location (DE)
15101   0xa7    AND A, (HL)                 ;  Bitwise AND of Accumulator to Accumulator
15102   0xc8    RET Z                       ;  Return if ZERO flag is 1
15103   0x13    INC DE                      ;  Increment register pair DE
15104   0x85    ADD A, L                    ;  Add register L to Accumulator (no carry)
15105   0x6f    LD L, A                     ;  Load register L with Accumulator
15106   0xd2    JP NC, NN       fa3a        ;  Jump to 0xfa3a (15098) if CARRY flag is 0
15109   0x24    INC H                       ;  Increment register H
15110   0x18    JR N            f2          ;  Jump relative 0xf2 (-14)


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


15964   0x00    NOP                         ;  No Operation
15965   0x00    NOP                         ;  No Operation
15966   0x00    NOP                         ;  No Operation
15967   0x00    NOP                         ;  No Operation
15968   0x00    NOP                         ;  No Operation
15969   0x00    NOP                         ;  No Operation
15970   0x00    NOP                         ;  No Operation
15971   0x00    NOP                         ;  No Operation
15972   0x00    NOP                         ;  No Operation
15973   0x00    NOP                         ;  No Operation
15974   0x00    NOP                         ;  No Operation
15975   0x00    NOP                         ;  No Operation
15976   0x00    NOP                         ;  No Operation
15977   0x00    NOP                         ;  No Operation
15978   0x00    NOP                         ;  No Operation
15979   0x00    NOP                         ;  No Operation
15980   0x00    NOP                         ;  No Operation
15981   0x00    NOP                         ;  No Operation
15982   0x00    NOP                         ;  No Operation
15983   0x00    NOP                         ;  No Operation
15984   0x00    NOP                         ;  No Operation
15985   0x00    NOP                         ;  No Operation
15986   0x00    NOP                         ;  No Operation
15987   0x00    NOP                         ;  No Operation
15988   0x00    NOP                         ;  No Operation
15989   0x00    NOP                         ;  No Operation
15990   0x00    NOP                         ;  No Operation
15991   0x00    NOP                         ;  No Operation
15992   0x00    NOP                         ;  No Operation
15993   0x00    NOP                         ;  No Operation
15994   0x00    NOP                         ;  No Operation
15995   0x00    NOP                         ;  No Operation
15996   0x00    NOP                         ;  No Operation
15997   0x00    NOP                         ;  No Operation
15998   0x00    NOP                         ;  No Operation
15999   0x00    NOP                         ;  No Operation
16000   0x00    NOP                         ;  No Operation
16001   0x00    NOP                         ;  No Operation
16002   0x00    NOP                         ;  No Operation
16003   0x00    NOP                         ;  No Operation
16004   0x00    NOP                         ;  No Operation
16005   0x00    NOP                         ;  No Operation
16006   0x00    NOP                         ;  No Operation
16007   0x00    NOP                         ;  No Operation
16008   0x00    NOP                         ;  No Operation
16009   0x00    NOP                         ;  No Operation
16010   0x00    NOP                         ;  No Operation
16011   0x00    NOP                         ;  No Operation
16012   0x00    NOP                         ;  No Operation
16013   0x00    NOP                         ;  No Operation
16014   0x00    NOP                         ;  No Operation
16015   0x00    NOP                         ;  No Operation
16016   0x00    NOP                         ;  No Operation
16017   0x00    NOP                         ;  No Operation
16018   0x00    NOP                         ;  No Operation
16019   0x00    NOP                         ;  No Operation
16020   0x00    NOP                         ;  No Operation
16021   0x00    NOP                         ;  No Operation
16022   0x00    NOP                         ;  No Operation
16023   0x00    NOP                         ;  No Operation
16024   0x00    NOP                         ;  No Operation
16025   0x00    NOP                         ;  No Operation
16026   0x00    NOP                         ;  No Operation
16027   0x00    NOP                         ;  No Operation
16028   0x00    NOP                         ;  No Operation
16029   0x00    NOP                         ;  No Operation
16030   0x00    NOP                         ;  No Operation
16031   0x00    NOP                         ;  No Operation
16032   0x00    NOP                         ;  No Operation
16033   0x00    NOP                         ;  No Operation
16034   0x00    NOP                         ;  No Operation
16035   0x00    NOP                         ;  No Operation
16036   0x00    NOP                         ;  No Operation
16037   0x00    NOP                         ;  No Operation
16038   0x00    NOP                         ;  No Operation
16039   0x00    NOP                         ;  No Operation
16040   0x00    NOP                         ;  No Operation
16041   0x00    NOP                         ;  No Operation
16042   0x00    NOP                         ;  No Operation
16043   0x00    NOP                         ;  No Operation
16044   0x00    NOP                         ;  No Operation
16045   0x00    NOP                         ;  No Operation
16046   0x00    NOP                         ;  No Operation
16047   0x00    NOP                         ;  No Operation
16048   0x00    NOP                         ;  No Operation
16049   0x00    NOP                         ;  No Operation
16050   0x00    NOP                         ;  No Operation
16051   0x00    NOP                         ;  No Operation
16052   0x00    NOP                         ;  No Operation
16053   0x00    NOP                         ;  No Operation
16054   0x00    NOP                         ;  No Operation
16055   0x00    NOP                         ;  No Operation
16056   0x00    NOP                         ;  No Operation
16057   0x00    NOP                         ;  No Operation
16058   0x00    NOP                         ;  No Operation
16059   0x00    NOP                         ;  No Operation
16060   0x00    NOP                         ;  No Operation
16061   0x00    NOP                         ;  No Operation
16062   0x00    NOP                         ;  No Operation
16063   0x00    NOP                         ;  No Operation
16064   0x00    NOP                         ;  No Operation
16065   0x00    NOP                         ;  No Operation
16066   0x00    NOP                         ;  No Operation
16067   0x00    NOP                         ;  No Operation
16068   0x00    NOP                         ;  No Operation
16069   0x00    NOP                         ;  No Operation
16070   0x00    NOP                         ;  No Operation
16071   0x00    NOP                         ;  No Operation
16072   0x00    NOP                         ;  No Operation
16073   0x00    NOP                         ;  No Operation
16074   0x00    NOP                         ;  No Operation
16075   0x00    NOP                         ;  No Operation
16076   0x00    NOP                         ;  No Operation
16077   0x00    NOP                         ;  No Operation
16078   0x00    NOP                         ;  No Operation
16079   0x00    NOP                         ;  No Operation
16080   0x00    NOP                         ;  No Operation
16081   0x00    NOP                         ;  No Operation
16082   0x00    NOP                         ;  No Operation
16083   0x00    NOP                         ;  No Operation
16084   0x00    NOP                         ;  No Operation
16085   0x00    NOP                         ;  No Operation
16086   0x00    NOP                         ;  No Operation
16087   0x00    NOP                         ;  No Operation
16088   0x00    NOP                         ;  No Operation
16089   0x00    NOP                         ;  No Operation
16090   0x00    NOP                         ;  No Operation
16091   0x00    NOP                         ;  No Operation
16092   0x00    NOP                         ;  No Operation
16093   0x00    NOP                         ;  No Operation
16094   0x00    NOP                         ;  No Operation
16095   0x00    NOP                         ;  No Operation
16096   0x00    NOP                         ;  No Operation
16097   0x00    NOP                         ;  No Operation
16098   0x00    NOP                         ;  No Operation
16099   0x00    NOP                         ;  No Operation
16100   0x00    NOP                         ;  No Operation
16101   0x00    NOP                         ;  No Operation
16102   0x00    NOP                         ;  No Operation
16103   0x00    NOP                         ;  No Operation
16104   0x00    NOP                         ;  No Operation
16105   0x00    NOP                         ;  No Operation
16106   0x00    NOP                         ;  No Operation
16107   0x00    NOP                         ;  No Operation
16108   0x00    NOP                         ;  No Operation
16109   0x00    NOP                         ;  No Operation
16110   0x00    NOP                         ;  No Operation
16111   0x00    NOP                         ;  No Operation
16112   0x00    NOP                         ;  No Operation
16113   0x00    NOP                         ;  No Operation
16114   0x00    NOP                         ;  No Operation
16115   0x00    NOP                         ;  No Operation
16116   0x00    NOP                         ;  No Operation
16117   0x00    NOP                         ;  No Operation
16118   0x00    NOP                         ;  No Operation
16119   0x00    NOP                         ;  No Operation
16120   0x00    NOP                         ;  No Operation
16121   0x00    NOP                         ;  No Operation
16122   0x00    NOP                         ;  No Operation
16123   0x00    NOP                         ;  No Operation
16124   0x00    NOP                         ;  No Operation
16125   0x00    NOP                         ;  No Operation
16126   0x00    NOP                         ;  No Operation
16127   0x00    NOP                         ;  No Operation
16128   0x00    NOP                         ;  No Operation
16129   0x00    NOP                         ;  No Operation
16130   0x00    NOP                         ;  No Operation
16131   0x00    NOP                         ;  No Operation
16132   0x00    NOP                         ;  No Operation
16133   0x00    NOP                         ;  No Operation
16134   0x00    NOP                         ;  No Operation
16135   0x00    NOP                         ;  No Operation
16136   0x00    NOP                         ;  No Operation
16137   0x00    NOP                         ;  No Operation
16138   0x00    NOP                         ;  No Operation
16139   0x00    NOP                         ;  No Operation
16140   0x00    NOP                         ;  No Operation
16141   0x00    NOP                         ;  No Operation
16142   0x00    NOP                         ;  No Operation
16143   0x00    NOP                         ;  No Operation
16144   0x00    NOP                         ;  No Operation
16145   0x00    NOP                         ;  No Operation
16146   0x00    NOP                         ;  No Operation
16147   0x00    NOP                         ;  No Operation
16148   0x00    NOP                         ;  No Operation
16149   0x00    NOP                         ;  No Operation
16150   0x00    NOP                         ;  No Operation
16151   0x00    NOP                         ;  No Operation
16152   0x00    NOP                         ;  No Operation
16153   0x00    NOP                         ;  No Operation
16154   0x00    NOP                         ;  No Operation
16155   0x00    NOP                         ;  No Operation
16156   0x00    NOP                         ;  No Operation
16157   0x00    NOP                         ;  No Operation
16158   0x00    NOP                         ;  No Operation
16159   0x00    NOP                         ;  No Operation
16160   0x00    NOP                         ;  No Operation
16161   0x00    NOP                         ;  No Operation
16162   0x00    NOP                         ;  No Operation
16163   0x00    NOP                         ;  No Operation
16164   0x00    NOP                         ;  No Operation
16165   0x00    NOP                         ;  No Operation
16166   0x00    NOP                         ;  No Operation
16167   0x00    NOP                         ;  No Operation
16168   0x00    NOP                         ;  No Operation
16169   0x00    NOP                         ;  No Operation
16170   0x00    NOP                         ;  No Operation
16171   0x00    NOP                         ;  No Operation
16172   0x00    NOP                         ;  No Operation
16173   0x00    NOP                         ;  No Operation
16174   0x00    NOP                         ;  No Operation
16175   0x00    NOP                         ;  No Operation
16176   0x00    NOP                         ;  No Operation
16177   0x00    NOP                         ;  No Operation
16178   0x00    NOP                         ;  No Operation
16179   0x00    NOP                         ;  No Operation
16180   0x00    NOP                         ;  No Operation
16181   0x00    NOP                         ;  No Operation
16182   0x00    NOP                         ;  No Operation
16183   0x00    NOP                         ;  No Operation
16184   0x00    NOP                         ;  No Operation
16185   0x00    NOP                         ;  No Operation
16186   0x00    NOP                         ;  No Operation
16187   0x00    NOP                         ;  No Operation
16188   0x00    NOP                         ;  No Operation
16189   0x00    NOP                         ;  No Operation
16190   0x00    NOP                         ;  No Operation
16191   0x00    NOP                         ;  No Operation
16192   0x00    NOP                         ;  No Operation
16193   0x00    NOP                         ;  No Operation
16194   0x00    NOP                         ;  No Operation
16195   0x00    NOP                         ;  No Operation
16196   0x00    NOP                         ;  No Operation
16197   0x00    NOP                         ;  No Operation
16198   0x00    NOP                         ;  No Operation
16199   0x00    NOP                         ;  No Operation
16200   0x00    NOP                         ;  No Operation
16201   0x00    NOP                         ;  No Operation
16202   0x00    NOP                         ;  No Operation
16203   0x00    NOP                         ;  No Operation
16204   0x00    NOP                         ;  No Operation
16205   0x00    NOP                         ;  No Operation
16206   0x00    NOP                         ;  No Operation
16207   0x00    NOP                         ;  No Operation
16208   0x00    NOP                         ;  No Operation
16209   0x00    NOP                         ;  No Operation
16210   0x00    NOP                         ;  No Operation
16211   0x00    NOP                         ;  No Operation
16212   0x00    NOP                         ;  No Operation
16213   0x00    NOP                         ;  No Operation
16214   0x00    NOP                         ;  No Operation
16215   0x00    NOP                         ;  No Operation
16216   0x00    NOP                         ;  No Operation
16217   0x00    NOP                         ;  No Operation
16218   0x00    NOP                         ;  No Operation
16219   0x00    NOP                         ;  No Operation
16220   0x00    NOP                         ;  No Operation
16221   0x00    NOP                         ;  No Operation
16222   0x00    NOP                         ;  No Operation
16223   0x00    NOP                         ;  No Operation
16224   0x00    NOP                         ;  No Operation
16225   0x00    NOP                         ;  No Operation
16226   0x00    NOP                         ;  No Operation
16227   0x00    NOP                         ;  No Operation
16228   0x00    NOP                         ;  No Operation
16229   0x00    NOP                         ;  No Operation
16230   0x00    NOP                         ;  No Operation
16231   0x00    NOP                         ;  No Operation
16232   0x00    NOP                         ;  No Operation
16233   0x00    NOP                         ;  No Operation
16234   0x00    NOP                         ;  No Operation
16235   0x00    NOP                         ;  No Operation
16236   0x00    NOP                         ;  No Operation
16237   0x00    NOP                         ;  No Operation
16238   0x00    NOP                         ;  No Operation
16239   0x00    NOP                         ;  No Operation
16240   0x00    NOP                         ;  No Operation
16241   0x00    NOP                         ;  No Operation
16242   0x00    NOP                         ;  No Operation
16243   0x00    NOP                         ;  No Operation
16244   0x00    NOP                         ;  No Operation
16245   0x00    NOP                         ;  No Operation
16246   0x00    NOP                         ;  No Operation
16247   0x00    NOP                         ;  No Operation
16248   0x00    NOP                         ;  No Operation
16249   0x00    NOP                         ;  No Operation
16250   0x00    NOP                         ;  No Operation
16251   0x00    NOP                         ;  No Operation
16252   0x00    NOP                         ;  No Operation
16253   0x00    NOP                         ;  No Operation
16254   0x00    NOP                         ;  No Operation
16255   0x00    NOP                         ;  No Operation
16256   0x00    NOP                         ;  No Operation
16257   0x00    NOP                         ;  No Operation
16258   0x00    NOP                         ;  No Operation
16259   0x00    NOP                         ;  No Operation
16260   0x00    NOP                         ;  No Operation
16261   0x00    NOP                         ;  No Operation
16262   0x00    NOP                         ;  No Operation
16263   0x00    NOP                         ;  No Operation
16264   0x00    NOP                         ;  No Operation
16265   0x00    NOP                         ;  No Operation
16266   0x00    NOP                         ;  No Operation
16267   0x00    NOP                         ;  No Operation
16268   0x00    NOP                         ;  No Operation
16269   0x00    NOP                         ;  No Operation
16270   0x00    NOP                         ;  No Operation
16271   0x00    NOP                         ;  No Operation
16272   0x00    NOP                         ;  No Operation
16273   0x00    NOP                         ;  No Operation
16274   0x00    NOP                         ;  No Operation
16275   0x00    NOP                         ;  No Operation
16276   0x00    NOP                         ;  No Operation
16277   0x00    NOP                         ;  No Operation
16278   0x00    NOP                         ;  No Operation
16279   0x00    NOP                         ;  No Operation
16280   0x00    NOP                         ;  No Operation
16281   0x00    NOP                         ;  No Operation
16282   0x00    NOP                         ;  No Operation
16283   0x00    NOP                         ;  No Operation
16284   0x00    NOP                         ;  No Operation
16285   0x00    NOP                         ;  No Operation
16286   0x00    NOP                         ;  No Operation
16287   0x00    NOP                         ;  No Operation
16288   0x00    NOP                         ;  No Operation
16289   0x00    NOP                         ;  No Operation
16290   0x00    NOP                         ;  No Operation
16291   0x00    NOP                         ;  No Operation
16292   0x00    NOP                         ;  No Operation
16293   0x00    NOP                         ;  No Operation
16294   0x00    NOP                         ;  No Operation
16295   0x00    NOP                         ;  No Operation
16296   0x00    NOP                         ;  No Operation
16297   0x00    NOP                         ;  No Operation
16298   0x00    NOP                         ;  No Operation
16299   0x00    NOP                         ;  No Operation
16300   0x00    NOP                         ;  No Operation
16301   0x00    NOP                         ;  No Operation
16302   0x00    NOP                         ;  No Operation
16303   0x00    NOP                         ;  No Operation
16304   0x00    NOP                         ;  No Operation
16305   0x00    NOP                         ;  No Operation
16306   0x00    NOP                         ;  No Operation
16307   0x00    NOP                         ;  No Operation
16308   0x00    NOP                         ;  No Operation
16309   0x00    NOP                         ;  No Operation
16310   0x00    NOP                         ;  No Operation
16311   0x00    NOP                         ;  No Operation
16312   0x00    NOP                         ;  No Operation
16313   0x00    NOP                         ;  No Operation
16314   0x00    NOP                         ;  No Operation
16315   0x00    NOP                         ;  No Operation
16316   0x00    NOP                         ;  No Operation
16317   0x00    NOP                         ;  No Operation
16318   0x00    NOP                         ;  No Operation
16319   0x00    NOP                         ;  No Operation
16320   0x00    NOP                         ;  No Operation
16321   0x00    NOP                         ;  No Operation
16322   0x00    NOP                         ;  No Operation
16323   0x00    NOP                         ;  No Operation
16324   0x00    NOP                         ;  No Operation
16325   0x00    NOP                         ;  No Operation
16326   0x00    NOP                         ;  No Operation
16327   0x00    NOP                         ;  No Operation
16328   0x00    NOP                         ;  No Operation
16329   0x00    NOP                         ;  No Operation
16330   0x00    NOP                         ;  No Operation
16331   0x00    NOP                         ;  No Operation
16332   0x00    NOP                         ;  No Operation
16333   0x00    NOP                         ;  No Operation
16334   0x00    NOP                         ;  No Operation
16335   0x00    NOP                         ;  No Operation
16336   0x00    NOP                         ;  No Operation
16337   0x00    NOP                         ;  No Operation
16338   0x00    NOP                         ;  No Operation
16339   0x00    NOP                         ;  No Operation
16340   0x00    NOP                         ;  No Operation
16341   0x00    NOP                         ;  No Operation
16342   0x00    NOP                         ;  No Operation
16343   0x00    NOP                         ;  No Operation
16344   0x00    NOP                         ;  No Operation
16345   0x00    NOP                         ;  No Operation
16346   0x00    NOP                         ;  No Operation
16347   0x00    NOP                         ;  No Operation
16348   0x00    NOP                         ;  No Operation
16349   0x00    NOP                         ;  No Operation
16350   0x00    NOP                         ;  No Operation
16351   0x00    NOP                         ;  No Operation
16352   0x00    NOP                         ;  No Operation
16353   0x00    NOP                         ;  No Operation
16354   0x00    NOP                         ;  No Operation
16355   0x00    NOP                         ;  No Operation
16356   0x00    NOP                         ;  No Operation
16357   0x00    NOP                         ;  No Operation
16358   0x00    NOP                         ;  No Operation
16359   0x00    NOP                         ;  No Operation
16360   0x00    NOP                         ;  No Operation
16361   0x00    NOP                         ;  No Operation
16362   0x00    NOP                         ;  No Operation
16363   0x00    NOP                         ;  No Operation
16364   0x00    NOP                         ;  No Operation
16365   0x00    NOP                         ;  No Operation
16366   0x00    NOP                         ;  No Operation
16367   0x00    NOP                         ;  No Operation
16368   0x00    NOP                         ;  No Operation
16369   0x00    NOP                         ;  No Operation
16370   0x00    NOP                         ;  No Operation
16371   0x00    NOP                         ;  No Operation
16372   0x00    NOP                         ;  No Operation
16373   0x00    NOP                         ;  No Operation
16374   0x00    NOP                         ;  No Operation
16375   0x00    NOP                         ;  No Operation
16376   0x00    NOP                         ;  No Operation
16377   0x00    NOP                         ;  No Operation

; Interrupt data vectors.
; 16378   0x00    0x30            0x3000
; 16380   0x8D    0x00            0x008D

;checksum
; 16382   0x75    0x73            0x7375
