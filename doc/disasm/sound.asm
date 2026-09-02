; FROM: https://www.vecoven.com/elec/download/download.html
; sound.asm.zip
; Pacman sound (Z80, disassembled)

;;; $Id: sound.asm,v 1.7 2008/06/20 09:35:53 fvecoven Exp $
;;;
;;;  PACMAN/MSPACMAN SOUND CODE
;;;
;;;
;;;  The copyright holders for the core program
;;;  included within this file are:
;;;	(c) 1980 NAMCO
;;;	(c) 1980 Bally/Midway
;;;	(c) 1981 General Computer Corporation (GCC)
;;;
;;;
;;; The goal of this project is to reproduce the pacman sound in a single
;;; microcontroller. This goal has been achieved using a PIC18, running at 10MHz
;;; (40MHz internally). For more information, check http://www.vecoven.com
;;;
;;; After looking on the net, I found the dissassembled file of Ms Pacman, where
;;; the contributors are below. This file was a great start, but it didn't contain
;;; much about the sound routines. After spending some time reading the Z80 code,
;;; and monitor it using MAME and its debugger (great tool!), the code is now fully
;;; understood. I've commented the sound portion in this file; others may find this
;;; interesting.
;;;
;;;		F. Vecoven  (frederic@vecoven.com)    6/15/2008
;;;
;;;
;;; Research and compilation of the documentation by
;;;	Scott 'Jerry' Lawrence
;;;	pacman@umlautllama.com
;;;
;;; Documentation and Hack Contributors:
;;;     David Caldwell			http://www.porkrind.org
;;;	Fred K "Juice"
;;;     Marcel "The Sil" Silvius	http://home.kabelfoon.nl/~msilvius/
;;;	Mark Spaeth 			http://rgvac.978.org/asm
;;;	Dave Widel			http://www.widel.com/
;;;	M.A.B. from Vigasoco
;;;
;;;
;;; This file contains the Z80 sound code of pacman and mspacman.
;;;
;;; The pacman hardware has basically a 3-voices. Each voice requires a frequency
;;; (20 bits for voice 1, 16 bits for voices 2 and 3), a wave number (3 bits) and a
;;; volume (4 bits).
;;;
;;; The software refreshes these value every 1/60 sec, during the vblank interrupt.
;;;
;;; Each voice can play an effect or a wave (for song).
;;;
;;; Effects are encoded with 8 bytes :
;;;
;;; 0 : upper 3 bits = frequency shift, lower 3 bits = wave select
;;; 1 : initial base frequency
;;; 2 : frequency increment (added to base freq)
;;; 3 : upper bit = reverse   lower 7 bits = duration
;;; 4 : frequency increment (added to initial base frequency). Used when repeat > 1
;;; 5 : repeat
;;; 6 : upper 4 bits = volume adjust type   lower 4 bits = volume
;;; 7 : volume increment
;;;
;;; Songs are coded using a combination of special bytes and tone information.
;;; Special bytes allow selection of wave, volume, etc...
;;;
;;; Special bytes :
;;; F0 : followed by 2 bytes : address where song continues (allows loop or jump in rom)
;;; F1 : followed by 1 byte  : wave select
;;; F2 : followed by 1 byte  : frequency increment
;;; F3 : followed by 1 byte  : volume
;;; F4 : followed by 1 byte  : type
;;; FF : mark end of song
;;;
;;; Regular byte :
;;; - upper 3 bits = duration (power of 2 of these bits = duration)
;;; - lower 4 bits = base frequency (using a lookup table)
;;; - lower 5 bits are also assigned to W_DIR, where the 5th bit has a signification
;;;
;;; Songs are played on voices 1 and 2 simultaneously. Neither Pacman nor MsPacman play
;;; song on channel 3. Effects are played on any channel.
;;;
;;; Note that you cannot play songs or effects designed for channel 1 on channel 2 or 3,
;;; and vice-versa. This is due to the fact that channel 1 has a 20 bits adder, and therefore
;;; frequency range is different.
;;;
;;;


	;; these 16 values are copied to the hardware every vblank interrupt.
CH1_FREQ0	EQU	4e8c	; 20 bits
CH1_FREQ1	EQU	4e8d
CH1_FREQ2	EQU	4e8e
CH1_FREQ3	EQU	4e8f
CH1_FREQ4	EQU	4e90
CH1_VOL		EQU	4e91
CH2_FREQ1	EQU	4e92	; 16 bits
CH2_FREQ2	EQU	4e93
CH2_FREQ3	EQU	4e94
CH2_FREQ4	EQU	4e95
CH2_VOL		EQU	4e96
CH3_FREQ1	EQU	4e97	; 16 bits
CH3_FREQ2	EQU	4e98
CH3_FREQ3	EQU	4e99
CH3_FREQ4	EQU	4e9a
CH3_VOL		EQU	4e9b

SOUND_COUNTER	EQU	4c84	; counter, incremented each VBLANK
				; (used to adjust sound volume)

EFFECT_TABLE_1	EQU	3b30	; channel 1 effects. 8 bytes per effect
EFFECT_TABLE_2	EQU	3b40	; channel 2 effects. 8 bytes per effect
EFFECT_TABLE_3	EQU	3b80	; channel 3 effects. 8 bytes per effect

#if MSPACMAN
SONG_TABLE_1	EQU	9685	; channel 1 song table
SONG_TABLE_2	EQU	967d	; channel 2 song table
SONG_TABLE_3	EQU	968d	; channel 3 song table
#else
SONG_TABLE_1	EQU	3bc8
SONG_TABLE_2	EQU	3bcc
SONG_TABLE_3	EQU	3bd0
#endif


CH1_E_NUM	EQU	4e9c	; effects to play sequentially (bitmask)
CH1_E_1		EQU	4e9d	; unused
CH1_E_CUR_BIT	EQU	4e9e	; current effect
CH1_E_TABLE0	EQU	4e9f	; table of parameters, initially copied from ROM
CH1_E_TABLE1	EQU	4ea0
CH1_E_TABLE2	EQU	4ea1
CH1_E_TABLE3	EQU	4ea2
CH1_E_TABLE4	EQU	4ea3
CH1_E_TABLE5	EQU	4ea4
CH1_E_TABLE6	EQU	4ea5
CH1_E_TABLE7	EQU	4ea6
CH1_E_TYPE	EQU	4ea7
CH1_E_DURATION	EQU	4ea8
CH1_E_DIR	EQU	4ea9
CH1_E_BASE_FREQ	EQU	4eaa
CH1_E_VOL	EQU	4eab

CH1_W_NUM	EQU	4ecc	; wave to play (bitmask)
CH1_W_1		EQU	4ecd	; unused
CH1_W_CUR_BIT	EQU	4ece	; current wave
CH1_W_SEL	EQU	4ecf
CH1_W_4		EQU	4ed0
CH1_W_5		EQU	4ed1
CH1_W_OFFSET1	EQU	4ed2	; address in ROM to find the next byte
CH1_W_OFFSET2	EQU	4ed3	; (16 bits)
CH1_W_8		EQU	4ed4
CH1_W_9		EQU	4ed5
CH1_W_A		EQU	4ed6
CH1_W_TYPE	EQU	4ed7
CH1_W_DURATION	EQU	4ed8
CH1_W_DIR	EQU	4ed9
CH1_W_BASE_FREQ	EQU	4eda
CH1_W_VOL	EQU	4edb


	;;
	;; VBLANK - 1
	;;
	;; load the sound into the hardware
	;;
009d  ld      hl,#CH1_FREQ0		; pointer to frequencies and volumes of the 3 voices
00a0  ld      de,#5050			; hardware address
00a3  ld      bc,#0010			; 16 bytes
00a6  ldir    				; copy !

	;; voice 1 wave select
00a8  ld      a,(#CH1_W_NUM)		; if we play a wave
00ab  and     a
00ac  ld      a,(#CH1_W_SEL)		; then WaveSelect = CH1_W_SEL
00af  jr      nz,#00b4
00b1  ld      a,(#CH1_E_TABLE0)		; else WaveSelect = CH1_E_TABLE0

00b4  ld      (#5045),a			; write WaveSelect to hardware

	;; voice 2 wave select
00b7  ld      a,(#CH2_W_NUM)
00ba  and     a
00bb  ld      a,(#CH2_W_SEL)
00be  jr      nz,#00c3
00c0  ld      a,(#CH2_E_TABLE0)
00c3  ld      (#504a),a

	;; voice 3 wave select
00c6  ld      a,(#CH3_W_NUM)
00c9  and     a
00ca  ld      a,(#CH3_W_SEL)
00cd  jr      nz,#00d2
00cf  ld      a,(#CH3_E_TABLE0)
00d2  ld      (#504f),a


	;;
	;; VBLANK - 2
	;;
	;; Process sound
01b9	call	#2d0c			; process effects
01bc	call	#2cc1			; process waves



	;;
	;; PROCESS WAVE (all voices)
	;;
#if MSPACMAN
2cc1  jp      #9797			; sprite/cocktail stuff. we don't care for sound.
					; The routine ends with "ld hl,#9685", "jp #2cc4"
					; so this is a Ms Pacman patch
#else
2cc1  ld      hl,#SONG_TABLE_1
#endif

	;; channel 1 song
2cc4  ld      ix,#CH1_W_NUM		; ix = Pointer to Song number
2cc8  ld      iy,#CH1_FREQ0		; iy = Pointer to Freq/Vol parameters
2ccc  call    #2d44			; call process_wave
2ccf  ld      b,a			; A is the returned volume (save it in B)
2cd0  ld      a,(#CH1_W_NUM)		; if we are playing a song
2cd3  and     a
2cd4  jr      z,#2cda
2cd6  ld      a,b			; then
2cd7  ld      (#CH1_VOL),a		;      save volume

	;; channel 2 song
2cda  ld      hl,#SONG_TABLE_2
2cdd  ld      ix,#CH2_W_NUM
2ce1  ld      iy,#CH2_FREQ1
2ce5  call    #2d44
2ce8  ld      b,a
2ce9  ld      a,(#CH2_W_NUM)
2cec  and     a
2ced  jr      z,#2cf3
2cef  ld      a,b
2cf0  ld      (#CH2_VOL),a

	;; channel 3 song
2cf3  ld      hl,#SONG_TABLE_3
2cf6  ld      ix,#CH3_W_NUM
2cfa  ld      iy,#CH3_FREQ1
2cfe  call    #2d44
2d01  ld      b,a
2d02  ld      a,(#CH3_W_NUM)
2d05  and     a
2d06  ret     z
2d07  ld      a,b
2d08  ld      (#CH3_VOL),a
2d0b  ret


	;;
	;; Process wave (one voice)
	;;
2d44  ld      a,(ix+#00)	; if (W_NUM == 0)
2d47  and     a
2d48  jp      z,#2df4		; then goto init_param

2d4b  ld      c,a		; c = W_NUM
2d4c  ld      b,#08		; b = 0x08
2d4e  ld      e,#80		; e = 0x80

2d50  ld      a,e		; find which bit is set in W_NUM
2d51  and     c
2d52  jr      nz,#2d59		; found one, goto process wave bis
2d54  srl     e
2d56  djnz    #2d50
2d58  ret     			; return

	;;
	;; Process wave bis : process one wave, represented by 1 bit (in E)
	;;
2d59  ld      a,(ix+#02)	; A = CUR_BIT
2d5c  and     e
2d5d  jr      nz,#2d66	 	; if (CUR_BIT & E != 0) then goto #ed66
2d5f  ld      (ix+#02),e	; else save E in CUR_BIT
2d62  jp      #364e		; and goto #36e4

2d65  inc     c			; junk

2d66  dec     (ix+#0c)		; decrement W_DURATION
2d69  jp      nz,#2dd7		; if W_DURATION == 0
2d6c  ld      l,(ix+#06)	; then HL = pointer store in W_OFFSET
2d6f  ld      h,(ix+#07)

	;; process byte
2d72  ld      a,(hl)		; A = (HL)
2d73  inc     hl
2d74  ld      (ix+#06),l	; W_OFFSET = ++HL
2d77  ld      (ix+#07),h
2d7a  cp      #f0		; if (A < 0xF)
2d7c  jr      c,#2da5		; then process A  (regular byte)
2d7e  ld      hl,#2d6c		; else process special byte using a jump table
2d81  push    hl		;
2d82  and     #0f		; take lowest nibble of special byte
2d84  rst     #20		; and jump (return in HL = 2d6c)

	;; jump table
2d85  55 2f			; byte is F0
2d87  65 2f			; byte is F1
2d89  77 2f			; byte is F2
2d8b  89 2f			; byte is F3
2d8d  9b 2f			; byte is F4
2d8f  0c 00			;
2d91  0c 00			;
2d93  0c 00			;
2d95  0c 00			;
2d97  0c 00			;
2d99  0c 00			;
2d9b  0c 00			;
2d9d  0c 00			;
2d9f  0c 00			;
2da1  0c 00			;
2da3  ad 2f			; byte is FF


	;;
	;; Special byte F0 : this is followed by 2 bytes, the new offset (to allow loops)
	;;
2f55  ld      l,(ix+#06)
2f58  ld      h,(ix+#07)	; HL = (W_OFFSET)
2f5b  ld      a,(hl)
2f5c  ld      (ix+#06),a
2f5f  inc     hl
2f60  ld      a,(hl)
2f61  ld      (ix+#07),a	; HL = (HL)
2f64  ret

	;;
	;; Special byte F1 : followed by one byte (wave select)
	;;
2f65  ld      l,(ix+#06)
2f68  ld      h,(ix+#07)
2f6b  ld      a,(hl)		; A = (++HL)
2f6c  inc     hl
2f6d  ld      (ix+#06),l
2f70  ld      (ix+#07),h
2f73  ld      (ix+#03),a	; save A in W_WAVE_SEL
2f76  ret

	;;
	;; Special byte F2 : followed by one byte (Frequency increment)
	;;
2f77  ld      l,(ix+#06)
2f7a  ld      h,(ix+#07)
2f7d  ld      a,(hl)		; A = (++HL)
2f7e  inc     hl
2f7f  ld      (ix+#06),l
2f82  ld      (ix+#07),h
2f85  ld      (ix+#04),a	; save A in W_A
2f88  ret

	;;
	;; Special byte F3 : followed by one byte (Volume)
	;;
2f89  ld      l,(ix+#06)
2f8c  ld      h,(ix+#07)
2f8f  ld      a,(hl)		; A = (++HL)
2f90  inc     hl
2f91  ld      (ix+#06),l
2f94  ld      (ix+#07),h
2f97  ld      (ix+#09),a	; save A in W_VOL
2f9a  ret

	;;
	;; Special byte F4 : followed by one byte (Type)
2f9b  ld      l,(ix+#06)
2f9e  ld      h,(ix+#07)
2fa1  ld      a,(hl)		; A = (++HL)
2fa2  inc     hl
2fa3  ld      (ix+#06),l
2fa6  ld      (ix+#07),h
2fa9  ld      (ix+#0b),a	; save A in W_TYPE
2fac  ret

	;;
	;; Special byte FF : mark the end of the song
	;;
2fad  ld      a,(ix+#02)
2fb0  cpl
2fb1  and     (ix+#00)
2fb4  ld      (ix+#00),a	; W_NUM &= ~W_CUR_BIT
2fb7  jp      #2df4



	;; select song
364e  dec     b			; B = current bit of song being played (from loop in 2d50)
364f  push    bc		; adapt B to the current level to find out the song number
3650  ld      a,b
3651  cp      #01
3653  jr      z,#3659
3655  ld      b,#00
3657  jr      #366a
3659  ld      a,(#4e13)
365c  ld      b,#01
365e  cp      #01
3660  jr      z,#366a
3662  ld      b,#02
3664  cp      #04
3666  jr      z,#366a
3668  ld      b,#03		; now B is adapted, and hold the song number
366a  rst     #18		; HL = (HL+2B)  [read from table in HL, i.e. SONG_TABLE_x]
366b  pop     bc
366c  jp      #2d72		; jump to "process byte" routine

	;; process regular byte (A=byte to process, it's not a special byte)
2da5  ld      b,a		; copy A in B

2da6  and     #1f
2da8  jr      z,#2dad		; if (A & 0x1f == 0)
2daa  ld      (ix+#0d),b	; then W_DIR = B
2dad  ld      c,(ix+#09)	; C = W_9
2db0  ld      a,(ix+#0b)
2db3  and     #08
2db5  jr      z,#2db9		; if (W_8 & 0x8 == 0)
2db7  ld      c,#00		; then VOL = 0
2db9  ld      (ix+#0f),c	; else VOL = W_9

2dbc  ld      a,b		; restore A
2dbd  rlca
2dbe  rlca
2dbf  rlca
2dc0  and     #07		; A = (A & 0xE0) >> 5
2dc2  ld      hl,#3bb0
2dc5  rst     #10		; A = ROM[0x3bb0 + A]
				; Note: this is just A = 2**A

2dc6  ld      (ix+#0c),a	; W_DURATION = A

2dc9  ld      a,b		; restore A
2dca  and     #1f
2dcc  jr      z,#2dd7 		; if (A & 0x1f == 0) then goto compute_wave_freq
2dce  and     #0f		; A = A & 0x0F
2dd0  ld      hl,#3bb8		; lookup table, contains a table a frequencies
2dd3  rst     #10
2dd4  ld      (ix+#0e),a	; W_BASE_FREQ = ROM[3bb8 + A]

	;; compute wave frequency
2dd7  ld      l,(ix+#0e)
2dda  ld      h,#00		; HL = W_BASE_FREQ (on 16 bits)

2ddc  ld      a,(ix+#0d)	; A = W_DIR
2ddf  and     #10
2de1  jr      z,#2de5 		; if (W_DIR & 0x10 != 0) then
2de3  ld      a,#01		; 	A = 1
2de5  add     a,(ix+#04)	; A += W_4

2de8  jp      z,#2ee8		; compute new frequency  FREQ = BASE_FREQ * (1 << A)
2deb  jp      #2ee4



	;;
	;; PROCESS EFFECT (all voices)
	;;

2d0c  ld      hl,#EFFECT_TABLE_1	; pointer to sound table
2d0f  ld      ix,#CH1_E_NUM		; effect number (voice 1)
2d13  ld      iy,#CH1_FREQ0
2d17  call    #2dee			; call process effect, returns volume in A
2d1a  ld      (#CH1_VOL),a		; store volume

2d1d  ld      hl,#EFFECT_TABLE_2 	; same for voice 2
2d20  ld      ix,#CH2_E_NUM
2d24  ld      iy,#CH2_FREQ1
2d28  call    #2dee
2d2b  ld      (#CH2_VOL),a

2d2e  ld      hl,#EFFECT_TABLE_3 	; same for voice 3
2d31  ld      ix,#CH3_E_NUM
2d35  ld      iy,#CH3_FREQ1
2d39  call    #2dee
2d3c  ld      (#CH3_VOL),a

2d3f  xor     a				; A = 0
2d40  ld      (#CH1_FREQ4),a		; freq 4 channel 1 = 0
2d43  ret


	;;
	;; Process effect (one voice)
	;;
2dee  	ld      a,(ix+#00)	; if (E_NUM != 0)
2df1    and     a		;
2df2    jr      nz,#2e1b	; then goto find effect

	;;
	;; Init Param
	;;
2df4    ld      a,(ix+#02)	; if (CUR_BIT == 0)
2df7    and     a
2df8    ret     z		; then return

2df9    ld      (ix+#02),#00	; CUR_BIT = 0
2dfd    ld      (ix+#0d),#00	; DIR = 0
2e01    ld      (ix+#0e),#00	; BASE_FREQ = 0
2e05    ld      (ix+#0f),#00	; VOL = 0
2e09    ld      (iy+#00),#00	; FREQ0 or 1   (5 freq for channel 1)
2e0d    ld      (iy+#01),#00	; FREQ1 or 2
2e11    ld      (iy+#02),#00	; FREQ2 or 3
2e15    ld      (iy+#03),#00	; FREQ3 or 4
2e19    xor     a		;
2e1a    ret     		; return 0

	;;
	;; find effect. Effect num is not zero, find which bits are set
	;;
2e1b  ld      c,a		; c = E_NUM
2e1c  ld      b,#08		; b = 0x08
2e1e  ld      e,#80		; e = 0x80

2e20  ld      a,e		; find which bit is set in E_NUM
2e21  and     c
2e22  jr      nz,#2e29		; found one, goto proces effect bis
2e24  srl     e
2e26  djnz    #2e20
2e28  ret

	;;
	;; Process effect bis : process one effect, represented by 1 bit (in E)
	;;
2e29  ld      a,(ix+#02)	; A = CUR_BIT
2e2c  and     e
2e2d  jr      nz,#2e6e		; if (CUR_BIT & E != 0) then goto 2e6e
2e2f  ld      (ix+#02),e	; else save E in CUR_BIT

				; locate the 8 bytes for this effect in the rom tables
2e32  dec     b			; the address is at HL + (B-1) * 8
2e33  ld      a,b
2e34  rlca
2e35  rlca
2e36  rlca
2e37  ld      c,a		; C = (B-1)*8
2e38  ld      b,#00		; B = 0
2e3a  push    hl		; save HL (pointer to EFFECT_TABLE)
2e3b  add     hl,bc		; HL = HL + (B-1)*8
2e3c  push    ix
2e3e  pop     de		; DE = E_NUM
2e3f  inc     de
2e40  inc     de
2e41  inc     de		; DE = E_TABLE0
2e42  ld      bc,#0008
2e45  ldir    			; copy 8 bytes from rom
2e47  pop     hl		; restore HL (pointer to EFFECT_TABLE)

2e48  ld      a,(ix+#06)
2e4b  and     #7f
2e4d  ld      (ix+#0c),a	; E_DURATION = E_TABLE3 & 0x7F

2e50  ld      a,(ix+#04)
2e53  ld      (ix+#0e),a	; E_BASE_FREQ = E_TABLE1

2e56  ld      a,(ix+#09)
2e59  ld      b,a		; B = E_TABLE6
2e5a  rrca
2e5b  rrca
2e5c  rrca
2e5d  rrca
2e5e  and     #0f
2e60  ld      (ix+#0b),a	; E_TYPE = (E_TABLE6 >> 4) & 0xF

2e63  and     #08
2e65  jr      nz,#2e6e		; if (E_TYPE & 0x8 == 0) then
2e67  ld      (ix+#0f),b	; 	E_VOL = E_TABLE6
2e6a  ld      (ix+#0d),#00	;	E_DIR = 0

	;; compute effect
2e6e  dec     (ix+#0c)		; E_DURATION--
2e71  jr      nz,#2ecd		; if (E_DURATION == 0) then
2e73  ld      a,(ix+#08)
2e76  and     a
2e77  jr      z,#2e89		;	if (E_TABLE5 != 0) then
2e79  dec     (ix+#08)		;		E_TABLE5--
2e7c  jr      nz,#2e89		;		if (E_TABLE5 == 0) then
2e7e  ld      a,e
2e7f  cpl
2e80  and     (ix+#00)
2e83  ld      (ix+#00),a	;			E_NUM &= ~E_CUR_BIT
2e86  jp      #2dee		;			goto process effect (one voice)
2e89  ld      a,(ix+#06)
2e8c  and     #7f
2e8e  ld      (ix+#0c),a	;	E_DURATION = E_TABLE3 & 0x7F
2e91  bit     7,(ix+#06)
2e95  jr      z,#2ead 		;	if (E_TABLE3 & 0x80 != 0) then
2e97  ld      a,(ix+#05)
2e9a  neg
2e9c  ld      (ix+#05),a	;		E_TABLE2 = - E_TABLE2
2e9f  bit     0,(ix+#0d)	;		if (E_DIR & 0x1 == 0) then
2ea3  set     0,(ix+#0d)	;			E_DIR |= 0x1
2ea7  jr      z,#2ecd 		;			goto update_freq
2ea9  res     0,(ix+#0d)	;		E_DIR &= ~0x1
2ead  ld      a,(ix+#04)
2eb0  add     a,(ix+#07)
2eb3  ld      (ix+#04),a	; 	E_TABLE1 += E_TABLE4
2eb6  ld      (ix+#0e),a	;	E_BASE_FREQ = E_TABLE1
2eb9  ld      a,(ix+#09)
2ebc  add     a,(ix+#0a)
2ebf  ld      (ix+#09),a	;	E_TABLE6 += E_TABLE7
2ec2  ld      b,a
2ec3  ld      a,(ix+#0b)
2ec6  and     #08
2ec8  jr      nz,#2ecd		;	if (E_TYPE & 0x8 == 0) then
2eca  ld      (ix+#0f),b	;		E_VOL = E_TABLE6

	;; update freq
2ecd  ld      a,(ix+#0e)
2ed0  add     a,(ix+#05)
2ed3  ld      (ix+#0e),a	; E_BASE_FREQ += E_TABLE2

2ed6  ld      l,a
2ed7  ld      h,#00		; HL = E_BASE_FREQ (on 16 bits)

2ed9  ld      a,(ix+#03)	; compute new frequency
2edc  and     #70		; FREQ = E_BASE_FREQ * ((1 << E_TABLE0 & 0x70) >> 4)
2ede  jr      z,#2ee8
2ee0  rrca
2ee1  rrca
2ee2  rrca
2ee3  rrca

	;; compute new frequency
2ee4  ld      b,a		; B = counter
2ee5  add     hl,hl		; HL = 2 * HL
2ee6  djnz    #2ee5
				; HL = HL * 2**B
				; now extract the nibbles from HL

2ee8  ld      (iy+#00),l	; 1st nibble
2eeb  ld      a,l
2eec  rrca
2eed  rrca
2eee  rrca
2eef  rrca
2ef0  ld      (iy+#01),a	; 2nd nibble
2ef3  ld      (iy+#02),h	; 3rd nibble
2ef6  ld      a,h
2ef7  rrca
2ef8  rrca
2ef9  rrca
2efa  rrca
2efb  ld      (iy+#03),a	; 4th nibble

2efe  ld      a,(ix+#0b)	; A = W_TYPE
2f01  rst     #20		; jump table to volume adjust routine


	; jump table to adjust volume
2f02  22 2f 26 2f 2b 2f 3c 2f 43 2f 4a 2f 4b 2f 4c 2f
2f12  4d 2f 4e 2f 4f 2f 50 2f 51 2f 52 2f 53 2f 54 2f


	;; type 0
2f22  ld      a,(ix+#0f) 	; constant volume
2f25  ret

	;; type 1
2f26  ld      a,(ix+#0f)	; decreasing volume
2f29  jr      #2f34

	;; type 2
2f2b  ld      a,(#4c84)		; decreasing volume (1/2 rate)
2f2e  and     #01
2f30  ld      a,(ix+#0f)	; (skip decrease if sound_counter (4c84) is odd)
2f33  ret     nz

2f34  and     #0f		; decrease routine
2f36  ret     z
2f37  dec     a
2f38  ld      (ix+#0f),a
2f3b  ret

	;; type 3
2f3c  ld      a,(#4c84)		; decreasing volume (1/4 rate)
2f3f  and     #03
2f41  jr      #2f30

	;; type 4
2f43  ld      a,(#4c84)		; decreasing volume (1/8 rate)
2f46  and     #07
2f48  jr      #2f30

	;; type 5-15
2f4a  ret
2f4b  ret
2f4c  ret
2f4d  ret
2f4e  ret
2f4f  ret
2f50  ret
2f51  ret
2f52  ret
2f53  ret
2f54  ret


	;;
	;; PACMAN sound tables
	;;

	;; channel 1 effects
3b30 73 20 00 0c 00 0a 1f 00  72 20 fb 87 00 02 0f 00

	;; channel 2 effects
3b40  36 20 04 8c 00 00 06 00  36 28 05 8b 00 00 06 00
3b50  36 30 06 8a 00 00 06 00  36 3c 07 89 00 00 06 00
3b60  36 48 08 88 00 00 06 00  24 00 06 08 00 00 0a 00
3b70  40 70 fa 10 00 00 0a 00  70 04 00 00 00 00 08 00

	;; channel 3 effects
3b80  42 18 fd 06 00 01 0c 00  42 04 03 06 00 01 0c 00
3b90  56 0c ff 8c 00 02 0f 00  05 00 02 20 00 01 0c 00
3ba0  41 20 ff 86 fe 1c 0f ff  70 00 01 0c 00 01 08 00

	;; lookup tables
3bb0  01 02 04 08 10 20 40 80

3bb8  00 57 5c 61 67 6d 74 7b  82 8a 92 9a a3 ad b8 c3

	;; channel 1 : jump table to song data
3bc8  d4 3b f3 3b

	;; channel 2 : jump table to song data
3bcc  58 3c 95 3c

	;; channel 3 : jump table to song data
3bd0  de 3c df 3c

	;; song data
3bd4  f1 02 f2 03 f3 0f f4 01  82 70 69 82 70 69 83 70
3be4  6a 83 70 6a 82 70 69 82  70 69 89 8b 8d 8e ff

3bf3  f1 02 f2 03 f3 0f f4 01  67 50 30 47 30 67 50 30
3c03  47 30 67 50 30 47 30 4b  10 4c 10 4d 10 4e 10 67
3c13  50 30 47 30 67 50 30 47  30 67 50 30 47 30 4b 10
3c23  4c 10 4d 10 4e 10 67 50  30 47 30 67 50 30 47 30
3c33  67 50 30 47 30 4b 10 4c  10 4d 10 4e 10 77 20 4e
3c43  10 4d 10 4c 10 4a 10 47  10 46 10 65 30 66 30 67
3c53  40 70 f0 fb 3b

3c58  f1 00 f2 02 f3 0f f4 00  42 50 4e 50 49 50 46 50
3c68  4e 49 70 66 70 43 50 4f  50 4a 50 47 50 4f 4a 70
3c78  67 70 42 50 4e 50 49 50  46 50 4e 49 70 66 70 45
3c88  46 47 50 47 48 49 50 49  4a 4b 50 6e ff

3c95  f1 01 f2 01 f3 0f f4 00  26 67 26 67 26 67 23 44
3ca4  42 47 30 67 2a 8b 70 26  67 26 67 26 67 23 44 42
3cb4  47 30 67 23 84 70 26 67  26 67 26 67 23 44 42 47
3cc4  30 67 29 6a 2b 6c 30 2c  6d 40 2b 6c 29 6a 67 20
3cd4  29 6a 40 26 87 70 f0 9d  3c
3cdd  00 00 00


	;;
	;; MSPACMAN sound tables
	;;

	;; 2 effects for channel 1
3b30  73 20 00 0c 00 0a 1f 00  72 20 fb 87 00 02 0f 00

	;; 8 effects for channel 2
3b40  59 01 06 08 00 00 02 00  59 01 06 09 00 00 02 00
3b50  59 02 06 0a 00 00 02 00  59 03 06 0b 00 00 02 00
3b60  59 04 06 0c 00 06 02 00  24 00 06 08 02 00 0a 00
3b70  36 07 87 6f 00 00 04 00  70 04 00 00 00 00 08 00

	;; 6 effects for channel 3
3b80  1c 70 8b 08 00 01 06 00  1c 70 8b 08 00 01 06 00
3b90  56 0c ff 8c 00 02 08 00  56 00 02 0a 07 03 0c 00
3ba0  36 38 fe 12 f8 04 0f fc  22 01 01 06 00 01 07 00

	;; lookup tables
3bb0  01 02 04 08 10 20 40 80

3bb8  00 57 5c 61 67 6d 74 7b  82 8a 92 9a a3 ad b8 c3

	;; junk left from pacman
3bc8  d4 3b f3 3b 58 3c 95 3c  de 3c df 3c

	;; song data
3bd4  f1 03 f2 03 f3 0a f4 02  90 7c 7b 7a 79 79 78 97
3be4  76 75 74 73 73 72 91 a8  88 60 4a 4c 91 95 88 95
3bf4  91 95 88 95 91 95 88 95  95 98 94 97 93 96 88 96
3c04  93 96 88 96 93 96 88 96  b6 b3 75 76 77 78 78 75
3c14  73 68 91 95 88 95 91 95  88 95 86 96 95 92 93 8c
3c24  8a 88 86 90 90 96 95 90  90 86 90 96 90 96 91 88
3c34  81 ff

3c36  47 30 4b 10 4c 10 4d 10  4e 10 77 20 4e 10 4d 10
3c46  4c 10 4a 10 47 10 46 10  65 30 66 30 67 40 70 f0
3c56  fb 3b

	;;  song data
3c58  f1 00 f2 02 f3 0a f4 00  88 6c 71 72 73 73 71 93
3c68  6c 73 75 76 76 75 96 7c  7a 78 76 75 96 6c 91 a0
3c78  88 75 76 77 78 71 73 74  75 71 75 71 68 68 65 66
3d78  67 a8 ab ac 8c 86 76 75  6c 71 75 73 6b 6c 73 76
3d88  7a 78 78 76 73 6c aa a8  71 73 74 75 6a 6b 6c 73
3d98  75 76 77 78 71 73 74 75  71 75 71 68 48 40 68 67
3da8  68 aa a9 aa 6a 60 8a 76  75 73 71 71 73 95 75 73
3db8  71 68 68 61 63 6a a8 6c  76 6a 6c 91 90 91 ff

3dc7  40 26 87 70 f0 9d 3c 00 00

	;;
	;; Song pointers. When selecting one song,
	;; use channels 1 and 2.
	;;
	;; song 0x01 : start
	;; song 0x02 : act 1
	;; song 0x04 : act 2
	;; song 0x08 : act 3
	;;

	;; channel 2 : jump table to song data
967d  95 96 d6 96 58 3c 4f 97

	;; channel 1 : jump table to song data
9685  b6 96 19 97 d4 3b 72 97

	;; channel 3 : jump table to song data (nothing here, 9796 = 0xff)
968d  96 97 96 97 96 97 96 97

	;; songs data
9695  f1 00 f2 02 f3 0a f4 00  41 43 45 86 8a 88 8b 6a
96a5  6b 71 6a 88 8b 6a 6b 71  6a 6b 71 73 75 96 95 96
96b5  ff

96b6  f1 02 f2 03 f3 0a f4 02  50 70 86 90 81 90 86 90
96c6  68 6a 6b 68 6a 68 66 6a  68 66 65 68 86 81 86 ff

96d6  f1 00 f2 02 f3 0a f4 00  69 6b 69 86 61 64 65 86
96e6  86 64 66 64 61 69 6b 69  86 61 64 64 a1 70 71 74
96f6  75 35 76 30 50 35 76 30  50 54 56 54 51 6b 69 6b
9706  69 6b 91 6b 69 66 f2 01  74 76 74 71 74 71 6b 69
9716  a6 a6 ff

9719  f1 03 f2 03 f3 0a f4 02  70 66 70 46 50 86 90 70
9729  66 70 46 50 86 90 70 66  70 46 50 86 90 70 61 70
9739  41 50 81 90 f4 00 a6 a4  a2 a1 f4 01 86 89 8b 81
9749  74 71 6b 69 a6 ff

974f  f1 00 f2 02 f3 0a f4 00  65 64 65 88 67 88 61 63
975f  64 85 64 85 6a 69 6a 8c  75 93 90 91 90 91 70 8a
976f  68 71 ff

9772  f1 02 f2 03 f3 0a f4 02  65 90 68 70 68 67 66 65
9782  90 61 70 61 65 68 66 90  63 90 86 90 85 90 85 70
9792  86 68 65 ff

9796  ff





	;; rst 20 (jump table)
	;;
	;; jump to (HL+2*A)
0020  pop     hl		; get HL from stack
0021  add     a,a
0022  rst     #10		; HL += 2A   A = (HL)
0023  ld      e,a		; E = A = (HL)
0024  inc     hl		;
0025  ld      d,(hl)		; D = (HL+1)  so  DE = 16-bits at HL+2A
0026  ex      de,hl		; DE <-> HL
0027  jp      (hl)		; goto HL

	;; rst 10  (for dereferencing pointers to bytes)
        ;; hl = hl + a, (hl) -> a
	;; HL = base address of table
	;; A  = index
	;; after the call, A gets the data in HL+A
0010  add     a,l
0011  ld      l,a
0012  ld      a,#00
0014  adc     a,h
0015  ld      h,a
0016  ld      a,(hl)
0017  ret

	;; rst 18 (for dereferencing pointers to words)
        ;; hl = hl + 2*b,  (hl) -> e, (++hl) -> d, de -> hl
        ;; HL = base address of table
	;; B  = index
	;; after the call, DE gets the data in HL+(2*B)
0018  78        ld      a,b
0019  87        add     a,a
001a  d7        rst     #10
001b  5f        ld      e,a	; E = (HL+2B)
001c  23        inc     hl
001d  56        ld      d,(hl)	; D = (HL+2B+1)
001e  eb        ex      de,hl	; HL = (HL+2B)
001f  c9        ret
