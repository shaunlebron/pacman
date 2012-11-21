;;;; source: http://www.bartgrantham.com/_projects/mspacman/mspac_fruit_documentation/mspac-fruit-path.asm

;; $4DA4 == num_blue_ghosts??
;; $4DD2/3 == fruit_YX
;; $4DD4 == fruit_points
;; $4C0C == fruit_color
;; $4C0D == fruit_sprite
;; $4C40 == num_path_segments == 3rd entry of path_table (example from $84BF: "0: 0x8B63, 13, 94, 0c")
;; $4C41 == bounce_direction_idx, initialized to 0x1F by __87CD()
;; 4EBC == sound register?
;; 4E0C == fruit_flag_1  // 0 if num_dots_eaten < 0x40, 1 otherwise
;; 4E0D == fruit_flag_2  // 0 if num_dots_eaten < 0xB0, 1 otherwise
;; 4E0E == num_dots_eaten
;; 4E13 == current board

;;; vsync_fruit();  // $86EE;
;;; This is the fruit vsync function.  It is called every frame by ???.
;;; It relies on init_fruit() to set up datastructures, indexes, and other state
;;; variables for processing.  Once set up, it processes its animation data
;;; as well as loads in more path data until the fruit is either eaten or leaves
;;; the maze.  Because of this arrangement where init_fruit() starts the cycle
;;; but vsync_fruit() perpetuates it, it can be difficult for a modern programmer
;;; to read this code straight from top to bottom because it appears to use
;;; parameters at the top that only appear to be properly initialized at the bottom.
;;; It's best to read the code for the common case of processing an active fruit path.
;;;
;;; ???First it checks to see if there are ghosts in the home (or flee?) state and
;;; returns if there are.???
;;;
;;; Next it determines if it is currently processing a fruit path by checking
;;; to see if the amount of fruit points or the fruit's Y coordinate is 0.  If
;;; either are 0 then the fruit path is in an uninitialized state and the init_fruit()
;;; function is jumped to, which in turn returns directly to the vsync caller.
;;;
;;; If there is a fruit path currently active, the fruit_YX is incremented with the
;;; next bounce animation accumulator and the bounce animation index is incremented.
;;; These bounce animation accumulators build off of the original Pac-Man "YX"
;;; playfield datastructure, where each 2-byte entry is added to the current playfield
;;; offset.  In this scheme 0x01 is down or left, 0xFF (interpreted as 2's compliment
;;; -1) is up or right.  So 0xFF01 has the effect of moving up and to the left.
;;; This table, located at 0x8841 and 128 bytes long, is set up as 4 sets of 16
;;; 2-byte entries.  The 4 sets of animations consist of 16 frames for bounce right?
;;; ($xxx-$xxx), bounce down?, bounce left?, and bounce up?.
;;;
;;; After processing the animation frame, it checks to see if the animation frame
;;; index is a multiple of 16, which indicates that it's finished animating a segment
;;; of a fruit path.  If so, it decrements the current count of remaining path
;;; segments.  If this count is less than 0 it means that it's finished all segments
;;; in a path and needs to load a new one or end the fruit animation if the fruit has
;;; exited the maze.  It does this by jumping to load_path(), which directly returns
;;; to the vsync caller.
;;;
;;; At this point in the code the system must be mid-path, but have exhausted the
;;; current bounce segment.  In other words, it needs to load a new bounce segment
;;; from the path data pointed to by the address stored in the path_data_addr pointer
;;; ($4C42, initialized by load_path()).
;;;
;;; First, a new bounce segment means a new bounce sound, so the 5th bit of the 
;;; 3rd sound channel's ??? parameter is set.  (??what is the physical manifestation
;;; of this in the speaker??)
;;;
;;; Using num_path_segments / 4 the code pulls the appropriate byte from the 
;;; Next it decodes a two-bit bounce animation index from the path data by shifting
;;; right ((num_path_segments % 4) * 2) times and then bitmasking by 0x03.  This value
;;; is then multiplied by 16 (through left-shifting) to produce an offset into the
;;; bounce animation table. 
;;;
;;; Note that the decreasing index into the path data segments means that the path
;;; segments are arranged *backwards*.  But that the data is padded at the *end* 
;;; (highest address) of the path segments (ie. if the count of segments is not a
;;; multiple of 4, the extra 0 bits will be in the first byte of the segment
;;; processed.  (??double-check this??).  Also, because it checks if this count drops
;;; below zero, the number of path segments is actually one more than in the path
;;; entry tables;

;;; For an example, let's assume that the player is on the first board and that
;;; init_path() has initialized the path variables to the path entry held in
;;; $8B4F: 0x8B63, 13, 94, 0c 
;;;
;;;     *path_data_addr = 0x8B63
;;;     num_path_segments = 0x13;  // +1 == 20 path segments
;;;     fruit_YX = 0x0C94;         // upper-right tunnel entrance
;;;
;;; Finally, let's assume that the first set of bounce animation frames (which was
;;; initialized by init_path()??) has been exhausted and it's now time to load a new
;;; path segment.  The path data at $8B63 is 0x80 0xAA 0xAA 0xBF 0xAA, which when
;;; split into 2-bit addresses looks like this:
;;;
;;;     //  80           AA           AA           BF           AA
;;;     10 00 00 00  10 10 10 10  10 10 10 10  10 11 11 11  10 10 10 10
;;;
;;;  Since we're done with the bounce animation, the bounce_animation_idx % 16 is 0,
;;; and we fall through the return statement at $8718.  num_path_segments is
;;; decremented to 0x12.  We grab the (0x12 >> 4) or 4th byte, 0xAA, and then
;;; take the (0x12 & 0x03) or 2nd pair of bits, 0b10.  Multiplied by 16, this gives
;;; us the offset (32) into the bounce animation table for the this segment.
;;;
;;; On the next 16 vsync's this function will only process the top half, from $86EE
;;; to $8718, stepping along the bounce animation table and adding these values
;;; to the fruit_YX giving the illusion of the fruit bouncing along the path.

;; if ( num_blue_ghosts != 0 ) {  return;  }
;; if ( fruit_points == 0 || fruit_Y == 0 ) {  init_fruit();  return;  }
;; fruit_YX += bounce_animation_table[bounce_animation_idx];
;; bounce_animation_idx++;
;; if ( bounce_animation_idx % 16 != 0 ) {  return;  }
;; num_path_segments--;
;; if ( num_path_segments < 0 ) {  load_path();  return;  }
;; $4EBC |= 0x20;  // Sound channel 3 ??? parameter
;; // The next few statements extract the 2-bit bounce parameter indexed by num_path_segments in
;; // the path pointed to by path_data_addr (addr in $4C42)
;; path_byte = path_data_addr[num_path_segments / 4];  // 4 directions per byte
;; bounce_direction_bit_offset = (num_path_segments%4)*2;  // 0, 2, 4, 6 corresponding to 0/1, 2/3, 4/5, 6/7
;; bounce_direction_idx = path_byte >> bounce_direction_bit_offset;
;; bounce_direction_idx &= 0x03;
;; bounce_animation_idx = bounce_direction_idx << 4;  // 0, 16, 32, or 48.  Offsets for bounce_animation_table.
;; return;

; if ( $4DA4 != 0 ) {  return;  }
; if ( $4DD4 == 0 || $4DD2 == 0 ) {  init_fruit();  }
; B = $4C41;
; HL = table_and_index_to_address_16(0x8841, B);  // via RST_18()
; $4DD2 += HL;
; $4C41++;
; if ( $4C41 & 0x0F != 0 ) {  return;  }
; if ( --$4C40 < 0 ) {  load_path();  }  // jump_87B5();
; A = $4C40;
; D = A;
; A = A >> 2;
; $4EBC |= 0x20;  // Sound channel 3 ??? parameter
; HL = 0x4C42;  // 16bit load
; A = $(4C42 + A);           // via HL = 0x4C42 and RST_10()
; C = A;
; A = 0x03 & D;  // ie. bottom 2 bits of $4C40;
; while ( A != 0 )
; {
;     C >>= 2;
;     A--;
; }
; A = C & 0x03;
; $4C41 = A << 4;
; return;

$86ee   0x3a    LD A, (nn)      a44d        ;  Load Accumulator with memory $nn
$86f1   0xa7    AND A, A                    ;  AND of register A to register A
$86f2   0xc0    RETNZ                       ;  Return if Z flag is 0
$86f3   0x3a    LD A, (nn)      d44d        ;  Load Accumulator with memory $nn
$86f6   0xa7    AND A, A                    ;  AND of register A to register A
$86f7   0xca    JPZ nn          4787        ;  Jump to $nn if Z flag is 1
$86fa   0x3a    LD A, (nn)      d24d        ;  Load Accumulator with memory $nn
$86fd   0xa7    AND A, A                    ;  AND of register A to register A
$86fe   0xca    JPZ nn          4787        ;  Jump to $nn if Z flag is 1
$8701   0x3a    LD A, (nn)      414c        ;  Load Accumulator with memory $nn
$8704   0x47    LD B, A                     ;  Load register B with register A
$8705   0x21    LD HL, nn       4188        ;  Load HL (16bit) with nn
$8708   0xdf    RST $18                     ;  Restart to $0018
$8709   0xed5b  LD DE, (nn)     d24d        ;  Load (16bit) register DE with memory $nn
$870d   0x19    ADD HL, DE                  ;  Add (16bit) DE to HL
$870e   0x22    LD (nn), HL     d24d        ;  Load memory $nn (16bit) with register HL
$8711   0x21    LD HL, nn       414c        ;  Load HL (16bit) with nn
$8714   0x34    INC (HL)                    ;  Increment memory $HL
$8715   0x7e    LD A, (HL)                  ;  Load register A with memory $HL
$8716   0xe6    AND A, n        0f          ;  AND of n to register A
$8718   0xc0    RETNZ                       ;  Return if Z flag is 0
$8719   0x21    LD HL, nn       404c        ;  Load HL (16bit) with nn
$871c   0x35    DEC (HL)                    ;  Decrement memory $HL
$871d   0xfa    JPM nn          b587        ;  Jump to $nn if S flag is 1 (negative)
$8720   0x7e    LD A, (HL)                  ;  Load register A with memory $HL
$8721   0x57    LD D, A                     ;  Load register D with register A
$8722   0xcb3f  SRL A                       ;  Shift right-logical register A
$8724   0xcb3f  SRL A                       ;  Shift right-logical register A
$8726   0x21    LD HL, nn       bc4e        ;  Load HL (16bit) with nn
$8729   0xcbee  SET 5, (HL)                 ;  Set bit 5 of memory $HL
$872b   0x2a    LD HL, (nn)     424c        ;  Load HL (16bit) with memory $nn
$872e   0xd7    RST $10                     ;  Restart to $0010
$872f   0x4f    LD C, A                     ;  Load register C with register A
$8730   0x3e    LD A, n         03          ;  Load Accumulator with n
$8732   0xa2    AND A, D                    ;  AND of register D to register A
$8733   0x28    JRZ d           07          ;  Jump d if z flag is 1
$8735   0xcb39  SRL C                       ;  Shift right-logical register C
$8737   0xcb39  SRL C                       ;  Shift right-logical register C
$8739   0x3d    DEC A                       ;  Decrement A
$873a   0x20    JRNZ d          f9          ;  Jump d if z flag is 0
$873c   0x3e    LD A, n         03          ;  Load Accumulator with n
$873e   0xa1    AND A, C                    ;  AND of register C to register A
$873f   0x07    RLCA                        ;  Rotate left-circular Accumulator
$8740   0x07    RLCA                        ;  Rotate left-circular Accumulator
$8741   0x07    RLCA                        ;  Rotate left-circular Accumulator
$8742   0x07    RLCA                        ;  Rotate left-circular Accumulator
$8743   0x32    LD (nn), A      414c        ;  Load memory $nn with Accumulator
$8746   0xc9    RET                         ;  Return


;;; init_fruit()  // __8747()
;;; Based on the number of dots eaten, either sets up fruit display and path data or returns.
;;; First it updates flags for which of the two fruit thresholds have been reached.
;;; Provided that one of the thresholds are being crossed (the code for this doesn't
;;; translate easily into a higher level language), it sets the fruit flag and continues
;;; with the path loading process.
;;;
;;; Next is determining the index into the fruit_parameter table.  For levels 1 through 8,
;;; cherry through banana, it simply uses the indices 0 to 7.  After the 8th board it
;;; reads an effectively random number from the memory refresh register and and takes the
;;; modulo 7 of this number.  It now uses this index to load the fruit sprite, color,
;;; and points into $4C0C/$4C0D/$4DD4 from the fruit parameter table at $879D.
;;; ??Why doesn't this result in a bug that prevents the banana from showing up again??
;;; ??It should be that the range of possible indices this produces is 0..6??
;;;
;;; Next, it sets HL to 0x87F8 and calls to ??__87CD()?? to get a random entry path based
;;; on the current board.  ??__87CD()?? choses a random entrance path and initializes
;;; many state variables to the parameters for this path.  These variables are the
;;; address of the path segment data (bytes 0 and 1 in the entry), the number of
;;; segments in this path (byte 2 of the entry), and it initializes the bounce direction
;;; index to 0x1f.
;;;
;;; This last initialization ensures that the first vsync will, after an animation NOP
;;; due to a null fruit direction accumulator, immediately load the first path segment
;;; direction index and begin moving and animating the fruit's bouncing around the screen.
;;;
;;; Because ??__87CD()?? is also used (via load_path()) during the animation processing
;;; it doesn't reset the fruit's playfield YX.  So after the call returns the code takes
;;; the value in HL left over from ??__87CD()??, increments it, and loads the fruit's
;;; initial playfield YX from this address (bytes 3 and 4 in the entry).
;;;
;;; With nearly a dozen bytes worth of state variables initialized, this function returns.

;; if ( number_of_dots_eaten == 64 && fruit_flag_1 != 0 ) {  return;  } else {  fruit_flag_1 += 1;  }
;; if ( number_of_dots_eaten == 176 && fruit_flag_2 != 0 ) {  return;  } else {  fruit_flag_2 += 1;  }
;; index = (current_board > 7) ? (current_board + RANDOM) % 7 : current_board;  // RANDOM via memory refresh register
;; fruit_sprite = fruit_param_table[index];    // $4C0C
;; fruit_color  = fruit_param_table[index+1];  // $4C0D
;; fruit_points = fruit_param_table[index+2];  // $4DD4
;; path_data = __87CD();
;; // num_path_segments = entry[3], bounce_direction_idx == 0x1F, path_data_addr = entry[0,1]
;; fruit_YX = path_data[4,5];  // 16bit copy
;; return;

; // The following if/else blocks correspond to $8747-$875E and
; // are very convoluted.  It seems like the it could be more
; // concise than it is.
; if ( $4E0E == 0x40 )
; {
;     if ( $4E0C != 0 ) {  return;  }   // $875B-875E
;                  else {  $4E0C++;  }
; }
; else
; {
;     if ( $4E0E == 0xB0 ) {  return;  }
;     if ( $4E0D != 0 ) {  return;  }   // $875B-875E
;                  else {  $4E0D++;  }
; }
; A = $4E13;
; if ( A > 0x07 )
; {
;     // fancy way of doing: A = R % 0x07
;     B = 0x07;
;     A = R & 0x1F;
;     while ( (A -= B) > 0 ) {  }  // overshoot the modulo?
;     A += B;                      // restore the overshoot?
; }
; A *= 3;
; $4C0C = $879D[A];    // fruit_param_table: fruit sprite
; $4C0D = $879D[A+1];  // fruit_param_table: fruit color
; $4DD4 = $879D[A+2];  // fruit_param_table: fruit points
; HL = 0x87F8;
; __87CD();
; // calling to 87CD figures out what map we're on, looks up the entrance path
; // address table for this map in $87F8, and picks a random entry from the list.
; // The it loads the path data from this entry into the animation state variables.
; //  The following are now set:
; // $4C40 == third byte of 5 byte entry
; // $4C41 == 0x1F
; // $4C42/3 == first/second bytes
; HL++;
; $4DD2 = $HL;  // 16bit load through DE
; // and now $4DD2/3 == fourth/fifth bytes
; return;

$8747   0x3a    LD A, (nn)      0e4e        ;  Load Accumulator with memory $nn
$874a   0xfe    CP A, n         40          ;  Compare n and register A
$874c   0xca    JPZ nn          5887        ;  Jump to $nn if Z flag is 1
$874f   0xfe    CP A, n         b0          ;  Compare n and register A
$8751   0xc0    RETNZ                       ;  Return if Z flag is 0
$8752   0x21    LD HL, nn       0d4e        ;  Load HL (16bit) with nn
$8755   0xc3    JP nn           5b87        ;  Jump to $nn
$8758   0x21    LD HL, nn       0c4e        ;  Load HL (16bit) with nn
$875b   0x7e    LD A, (HL)                  ;  Load register A with memory $HL
$875c   0xa7    AND A, A                    ;  AND of register A to register A
$875d   0xc0    RETNZ                       ;  Return if Z flag is 0
$875e   0x34    INC (HL)                    ;  Increment memory $HL
$875f   0x3a    LD A, (nn)      134e        ;  Load Accumulator with memory $nn
$8762   0xfe    CP A, n         07          ;  Compare n and register A
$8764   0x38    JRC d           0a          ;  Jump d if c flag is 1
$8766   0x06    LD B, n         07          ;  Load register B with n
$8768   0xed5f  LD A, R                     ;  Load Accumulator with memory refresh register
$876a   0xe6    AND A, n        1f          ;  AND of n to register A
$876c   0x90    SUB A, B                    ;  Subtract register B from register A
$876d   0x30    JRNC d          fd          ;  Jump d if c flag is 0
$876f   0x80    ADD A, B                    ;  Add register B to register A
$8770   0x21    LD HL, nn       9d87        ;  Load HL (16bit) with nn
$8773   0x47    LD B, A                     ;  Load register B with register A
$8774   0x87    ADD A, A                    ;  Add register A to register A
$8775   0x80    ADD A, B                    ;  Add register B to register A
$8776   0xd7    RST $10                     ;  Restart to $0010
$8777   0x32    LD (nn), A      0c4c        ;  Load memory $nn with Accumulator
$877a   0x23    INC HL                      ;  Increment HL (16bit)
$877b   0x7e    LD A, (HL)                  ;  Load register A with memory $HL
$877c   0x32    LD (nn), A      0d4c        ;  Load memory $nn with Accumulator
$877f   0x23    INC HL                      ;  Increment HL (16bit)
$8780   0x7e    LD A, (HL)                  ;  Load register A with memory $HL
$8781   0x32    LD (nn), A      d44d        ;  Load memory $nn with Accumulator
$8784   0x21    LD HL, nn       f887        ;  Load HL (16bit) with nn
$8787   0xcd    CALL nn         cd87        ;  Call $nn
$878a   0x23    INC HL                      ;  Increment HL (16bit)
$878b   0x5e    LD E, (HL)                  ;  Load register E with memory $HL
$878c   0x23    INC HL                      ;  Increment HL (16bit)
$878d   0x56    LD D, (HL)                  ;  Load register D with memory $HL
$878e   0xed53  LD (nn), DE     d24d        ;  Load (16bit) memory $nn with register DE
$8792   0xc9    RET                         ;  Return


;;; __8793();
;;; patch for $2BF0 aka draw_fruit() @ $2BF4 (11252)

; if ( a > 8 ) {  A = 0x07;  }
; jump_2BF9();

$8793   0xfe    CP A, n         08          ;  Compare n and register A
$8795   0xda    JPC nn          f92b        ;  Jump to $nn if C flag is 1
$8798   0x3e    LD A, n         07          ;  Load Accumulator with n
$879a   0xc3    JP nn           f92b        ;  Jump to $nn


      /------------------------\
      |   fruit_param_table    |
      |      $879D..$87B4      |
      +-------+-------+--------+
      | fruit | color | points |
      +-------+-------+--------+
$879D | 0x00  | 0x14  | 0x06   |
$87A0 | 0x01  | 0x0f  | 0x07   |
$87A3 | 0x02  | 0x15  | 0x08   |
$87A6 | 0x03  | 0x07  | 0x09   |
$87A9 | 0x04  | 0x14  | 0x0a   |
$87AC | 0x05  | 0x15  | 0x0b   |
$87AF | 0x06  | 0x16  | 0x0c   |
$87B2 | 0x07  | 0x00  | 0x0d   |
      +-------+-------+--------+


;;; load_path();  // __87B5()

;; if ( fruit_X < 32 ) {  clear_fruit_path();  }
;; if ( $4C42 != 0x8800 )
;; {
;;     $4C42 = 0x8800;
;;     $4C40 = 0x1D;
;;     $4C41 = 0x1F;
;;     return;  // HL == 0x8802
;; }
;; else
;; {
;;     path_table = level_2_maze_path_table_addr(HL);  // HL is either 0x87F8 (from init_fruit) or 0x8800 (from this function)
;;     path_data = path_table[rand(4)];
;;     $4C42 = path_data;  // 16bit
;;     $4C40 = path_data[3];
;;     $4C41 = 0x1F;
;;     return;  // HL == path_table + 2
;; }

; if ( $4DD3 + 32 < 64 ) {  clear_fruit_path();  }  // __8810() : $4C0D = $4DD2 = $4DD3 = $4DD4 = 0x00;  return;
; HL = $4C42;
; DE = 0x8808;
; clear_carry_flag();    // SCF, CCF
; if ( HL != 0x8808 )
; {
;     // via jump_87ED():
;     HL = 0x8808;
;     $4C42 = HL;  // 16bit
;     A = 0x1D;
; }
; else // 87CD:
; {
;     HL = level_2_maze_path_table_addr(HL);
;     A = 5 * ( R & 0x03 );  // R is the memory refresh register.. effectively rand()
;     HL = $HL[A];           // via RST_10();
;     $4C42 = HL;            // 16bit load, though DE
;     // HL++;               // side-effect of previous 16bit load
;     HL++;
;     A = $HL;
; }
; $4C40 = A;
; $4C41 = 0x1F;
; return;  // side effect: HL is left pointing to the 3rd byte in the 5-byte path data structure, eg. $8B4F + 2

$87b5   0x3a    LD A, (nn)      d34d        ;  Load Accumulator with memory $nn
$87b8   0xc6    ADD A, n        20          ;  Add n to register A
$87ba   0xfe    CP A, n         40          ;  Compare n and register A
$87bc   0x38    JRC d           52          ;  Jump d if c flag is 1
$87be   0x2a    LD HL, (nn)     424c        ;  Load HL (16bit) with memory $nn
$87c1   0x11    LD DE, nn       0888        ;  Load DE (16bit) with nn
$87c4   0x37    SCF                         ;  Set Carry flag
$87c5   0x3f    CCF                         ;  Invert Carry flag
$87c6   0xed52  SBC HL, DE                  ;  Subtract with carry (16bit) DE from HL
$87c8   0x20    JRNZ d          23          ;  Jump d if z flag is 0
$87ca   0x21    LD HL, nn       0088        ;  Load HL (16bit) with nn
; level_2_maze_path_table_addr();  // BC = $HL[current_board]; (16bit)
$87cd   0xcd    CALL nn         bd94        ;  Call $nn
$87d0   0x69    LD L, C                     ;  Load register L with register C
$87d1   0x60    LD H, B                     ;  Load register H with register B
$87d2   0xed5f  LD A, R                     ;  Load Accumulator with memory refresh register
$87d4   0xe6    AND A, n        03          ;  AND of n to register A
$87d6   0x47    LD B, A                     ;  Load register B with register A
$87d7   0x87    ADD A, A                    ;  Add register A to register A
$87d8   0x87    ADD A, A                    ;  Add register A to register A
$87d9   0x80    ADD A, B                    ;  Add register B to register A
$87da   0xd7    RST $10                     ;  Restart to $0010
$87db   0x5f    LD E, E                     ;  Load register E with register A
$87dc   0x23    INC HL                      ;  Increment HL (16bit)
$87dd   0x56    LD D, (HL)                  ;  Load register D with memory $HL
$87de   0xed53  LD (nn), DE     424c        ;  Load (16bit) memory $nn with register DE
$87e2   0x23    INC HL                      ;  Increment HL (16bit)
$87e3   0x7e    LD A, (HL)                  ;  Load register A with memory $HL
$87e4   0x32    LD (nn), A      404c        ;  Load memory $nn with Accumulator
$87e7   0x3e    LD A, n         1f          ;  Load Accumulator with n
$87e9   0x32    LD (nn), A      414c        ;  Load memory $nn with Accumulator
$87ec   0xc9    RET                         ;  Return
$87ed   0x21    LD HL, nn       0888        ;  Load HL (16bit) with nn
$87f0   0x22    LD (nn), HL     424c        ;  Load memory $nn (16bit) with register HL
$87f3   0x3e    LD A, n         1d          ;  Load Accumulator with n
$87f5   0xc3    JP nn           e487        ;  Jump to $nn


...


;;; maze_2_paths_entrance : $87F8-$87FF - first table of addresses of fruit paths
0 : 0x8B4F
1 : 0x8E40
2 : 0x911A
3 : 0x940A

;;; maze_2_paths_exit     : $8800-$8807 - second table of addresses of fruit paths
0 : 0x8B82
1 : 0x8E73
2 : 0x9142
3 : 0x943C

;;; ghost_pen_path        : $8808-$8815 - clockwise path around ghost box.  360', from 5 o'clock to 5 o'clock
: fa ff 55 55 01 80 aa 02


;;; clear_fruit_path();
;;; Clears the current fruit sprite, fruit points, and fruit playfield YX,
;;; the latter two being handled by a jump to clear_fruit_points_YX() at $4096.
;;; clear_fruit_points_YX() returns to the calling function.

; $4C0D = 0x00;
; clear_fruit_points_YX(); // $4DD2 = $4DD3 = $4DD4 = 0x00;
; return;                  // handled by clear_fruit_points_YX()

$8810   0x3e    LD A, n         00          ;  Load Accumulator with n
$8812   0x32    LD (nn), A      0d4c        ;  Load memory $nn with Accumulator
$8815   0xc3    JP nn           0010        ;  Jump to $nn


...

;;; $8841: bounce_animation_table

0: 0xFF, 0xFF - R, D
1: 0xFF, 0xFF - R, D
2: 0xFF, 0xFF - R, D
3: 0xFF, 0xFF - R, D
4: 0xFF, 0xFF - R, D
5: 0xFF, 0xFF - R, D
6: 0xFF, 0xFF - R, D
7: 0xFF, 0xFF - R, D
8: 0xFF, 0xFF - R, D
9: 0x00, 0x00
10: 0xFF, 0xFF - R, D
11: 0x00, 0x00
12: 0x00, 0x00
13: 0x01, 0x00 - L
14: 0x00, 0x00
15: 0x01, 0x00 - L

16: 0x00, 0x00
17: 0xFF, 0xFE - R, DD
18: 0x00, 0x00
19: 0x00, 0xFF - D
20: 0x00, 0x00
21: 0xFF, 0xFE - R, DD
22: 0x00, 0x00
23: 0x00, 0xFF - D
24: 0x00, 0x00
25: 0x00, 0xFF - D
26: 0x00, 0x00
27: 0x00, 0xFF - D
28: 0x00, 0x00
29: 0x01, 0xFF - L, D
30: 0x01, 0xFF - L, D
31: 0x00, 0x00

32: 0x00, 0x00
33: 0x00, 0x00
34: 0xFF, 0x00 - R
35: 0x00, 0x00 
36: 0x00, 0x01 - U
37: 0x00, 0x00
38: 0xFF, 0x00 - R
39: 0x00, 0x00
40: 0x00, 0x01 - U
41: 0x00, 0x00
42: 0x00, 0x01 - U
43: 0x00, 0x00
44: 0x00, 0x01 - U
45: 0x00, 0x00
46: 0x01, 0x01 - L, U
47: 0x01, 0x01 - L, U

48: 0x00, 0x00
49: 0x01, 0x00 - L
50: 0x01, 0x00 - L
51: 0x01, 0x00 - L
52: 0x01, 0x00 - L
53: 0x01, 0x00 - L
54: 0x01, 0x00 - L
55: 0x01, 0x00 - L
56: 0x01, 0x00 - L
57: 0x01, 0x00 - L
58: 0x01, 0x00 - L
59: 0x01, 0x00 - L
60: 0xFF, 0xFF - R, D
61: 0xFF, 0xFF - R, D
62: 0x00, 0x00
63: 0xFF, 0xFF - R, D


...


;;; $8B4F-$8B62 : Table of pointers for fruit paths for map set 1, map 1
0: 0x8B63, 13, 94, 0c  (upper right)
1: 0x8B68, 22, 94, f4  (upper left)
2: 0x8B71, 27, 4c, f4  (lower left)
3: 0x8B7B, 1c, 4c, 0c  (lower right)

;;; $8B63-$8B7B : Data for fruit paths for map set 1, map 1
$8B63: 80 aa aa bf aa                 // 10 00 00 00  10 10 10 10  10 10 10 10  10 11 11 11  10 10 10 10
$8B68: 80 0a 54 55 55 55 ff 5f 55
$8B71: ea ff 57 55 f5 57 ff 15 40 55
$8B7B: ea af 02 ea ff ff aa


;;; $8B82-8B93 : Table of pointers for fruit paths for map set 2, map 1
0: 0x8B94, 14, 00, 00
1: 0x8B99, 17, 00, 00
2: 0x8B9f, 1a, 00, 00
3: 0x8BA6, 1d             // why short?

;;; $8B94-$8BAD : Data for fruit paths for map set 2, map 1
$8B94: 55 40 55 55 bf
$8B99: aa 80 aa aa bf aa
$8B9F: aa 80 aa 02 80 aa aa
$8BA6: 55 00 00 00 55 55 fd aa


...


;;; $8E40-$8E53 : Table of pointers for fruit paths for map set 1, map 2
0: 0x8E54, 13, c4, 0c
1: 0x8E59, 1e, c4, f4
2: 0x8E61, 26, 14, f4
3: 0x8E6B, 1d, 14, 0c

;;; $8E54-$8E72 : Data for fruit paths for map set 1, map 2
$8E54: 02 aa aa 80 2a
$8E59: 02 40 55 7f 55 15 50 05
$8E61: ea ff 57 55 f5 ff 57 7f 55 05
$8E6B: ea ff ff ff ea af aa 02


;;; $8E73-$8E86 : Table of pointers for fruit paths for map set 2, map 2
0: 0x8E87, 12, 00, 00
1: 0x8E8C, 1d, 00, 00
2: 0x8E94, 21, 00, 00
3: 0x8E9D, 2c, 00, 00

;;; $8E87-$8E?? : Data for fruit paths for map set 2, map 2
$8E87: 55 7f 55 d5 ff
$8E8C: aa bf aa 2a a0 ea ff ff
$8E94: aa 2a a0 02 00 00 a0 aa 02
$8E9D: 55 15 a0 2a 00 54 05 00 00 55 fd


...


;;; $911A-$912D : Table of pointers for fruit paths for map set 1, map 3
0: 0x912E, 15, 54, 0c
1: 0x9134, 1e, 54, f4
2: 0x9134, 1e, 54, f4
3: 0x913C, 15, 54, 0c

;;; $912E-$9141 : Data for fruit paths for map set 1, map 3
$912E: ea ff ab fa aa aa
$9134: ea ff 57 55 55 d5 57 55
$913C: aa aa bf fa bf aa


;;; $9142-$9155 : Table of pointers for fruit paths for map set 2, map 3
0: 0x9156, 22, 00, 00
1: 0x915F, 25, 00, 00
2: 0x915F, 25, 00, 00
3: 0x916F, 28, 00, 00

;;; $9156-$9178 : Data for fruit paths for map set 2, map 3
$9156: 05 00 00 54 05 54 7f f5 0b
$915F: 0a 00 00 a8 0a a8 bf fa ab aa aa 82 aa 00 a0 aa
$916F: 55 41 55 00 a0 02 40 f5 57 bf


...


;;; $940A-$941D : Table of pointers for fruit paths for map set 1, map 4
0: 0x941E, 14, 8c, 0c
1: 0x9423, 1d, 8c, f4
2: 0x942B, 2a, 74, f4
3: 0x9436, 15, 74, 0c 

;;; $941E-$943B : Data for fruit paths for map set 1, map 4
$941E: 80 aa be fa aa
$9423: 00 50 fd 55 f5 d5 57 55
$942B: ea ff 57 d5 5f fd 15 50 01 50 55
$9436: ea af fe 2a a8 aa


;;; $943C-$944F : Table of pointers for fruit paths for map set 2, map 4
0: 0x9450, 15, 00, 00
1: 0x9456, 18, 00, 00
2: 0x945C, 19, 00, 00
3: 0x9463, 1c, 00, 00

;;; $9450-$9468 : Data for fruit paths for map set 2, map 4
$9450: 55 50 41 55 fd aa
$9456: aa a0 82 aa fe aa
$945C: aa af 02 2a a0 aa aa
$9463: 55 5f 01 00 50 55


...


;;; level_2_maze_path_table_addr();  // __94BD() - BC = $HL[current_board];  (16bit)

;; Given the address in HL of a table of four 2-byte pointers,
;; load BC with the 2-byte entry for the current board, based on
;; the board advancing algo (ie. 0...11, 4...11, 4...11, ...)
;; [side effect: HL is left pointing to the upper byte of this 2 byte entry]

; A = $4E13;              // current board
; push(HL);
; if ( A >= 0x0D )         // detour through $94D4..$94DD
; {
;     A = ( A % 8 ) + 4;  // IOW: 0...11, 4...11, 4...11, ...
; }
; A = $94DF[A];           // via HL = 0x94DF and RST_10()
; pop(HL);
; BC = $HL[A*2];          // 16-bt load


$94bd   0x3a    LD A, (nn)      134e        ;  Load Accumulator with memory $nn
$94c0   0xe5    PUSH HL                     ;  Load top of stack (16bit) with HL
$94c1   0xfe    CP A, n         0d          ;  Compare n and register A
$94c3   0xf2    JPP nn          d494        ;  Jump to $nn if S flag is 0 (positive)
$94c6   0x21    LD HL, nn       df94        ;  Load HL (16bit) with nn
$94c9   0xd7    RST $10                     ;  Restart to $0010
$94ca   0xe1    POP HL                      ;  Load HL (16bit) with top of stack
$94cb   0x87    ADD A, A                    ;  Add register A to register A
$94cc   0x4f    LD C, A                     ;  Load register C with register A
$94cd   0x06    LD B, n         00          ;  Load register B with n
$94cf   0x09    ADD HL, BC                  ;  Add (16bit) BC to HL
$94d0   0x4e    LD C, (HL)                  ;  Load register C with memory $HL
$94d1   0x23    INC HL                      ;  Increment HL (16bit)
$94d2   0x46    LD B, (HL)                  ;  Load register B with memory $HL
$94d3   0xc9    RET                         ;  Return
$94d4   0xd6    SUB A, n        0d          ;  Subtract n from register A
$94d6   0xd6    SUB A, n        08          ;  Subtract n from register A
$94d8   0xf2    JPP nn          d694        ;  Jump to $nn if S flag is 0 (positive)
$94db   0xc6    ADD A, n        0d          ;  Add n to register A
$94dd   0x18    JR d            e7          ;  Jump d


;;; $94DF-$94EB : Table mapping levels to mazes
0  : 0
1  : 0
2  : 1
3  : 1
4  : 1
5  : 2
6  : 2
7  : 2
8  : 2
9  : 3
10 : 3
11 : 3
12 : 3
