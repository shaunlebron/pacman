
SOUND_COUNTER   EQU     4c84    ; counter, incremented each VBLANK
                                ; (used to adjust sound volume)

EFFECT_TABLE_1  EQU     3b30    ; channel 1 effects. 8 bytes per effect
EFFECT_TABLE_2  EQU     3b40    ; channel 2 effects. 8 bytes per effect
EFFECT_TABLE_3  EQU     3b80    ; channel 3 effects. 8 bytes per effect

#if MSPACMAN
SONG_TABLE_1    EQU     9685    ; channel 1 song table
SONG_TABLE_2    EQU     967d    ; channel 2 song table
SONG_TABLE_3    EQU     968d    ; channel 3 song table
#else
SONG_TABLE_1    EQU     3bc8
SONG_TABLE_2    EQU     3bcc
SONG_TABLE_3    EQU     3bd0
#endif


--------------------------------------------------------------------------------


	;;
	;; MSPACMAN sound tables
	;;

	;; 2 effects for channel 1

3b30  73 20 00 0c 00 0a 1f 00  		; extra life sound
3b38  72 20 fb 87 00 02 0f 00		; credit sound

	;; 8 effects for channel 2

3b40  59 01 06 08 00 00 02 00		; end of energizer
3b48  59 01 06 09 00 00 02 00		; higher frequency when 155 dots eaten
3b50  59 02 06 0a 00 00 02 00  		; higher frequency when 179 dots eaten
3b58  59 03 06 0b 00 00 02 00		; higher frequency when 12 dots left
3b60  59 04 06 0c 00 06 02 00  		; reset higher frequency when 12 or less dots left
3b68  24 00 06 08 02 00 0a 00		; engergizer eaten
3b70  36 07 87 6f 00 00 04 00		; eyes returning sound
3b78  70 04 00 00 00 00 08 00		; unused ???

	;; 6 effects for channel 3

3b80  1c 70 8b 08 00 01 06 00		; dot eating sound 1
3b88  1c 70 8b 08 00 01 06 00		; dot eating sound 2
3b90  56 0c ff 8c 00 02 08 00		; fruit eating sound
3b98  56 00 02 0a 07 03 0c 00		; blue ghost eaten sound
3ba0  36 38 fe 12 f8 04 0f fc 		; ghosts bumping during act 1 sound
3ba8  22 01 01 06 00 01 07 00		; fruit bouncing sound
        
        ;; lookup tables

3bb0  01 02 04 08 10 20 40 80

3bb8  00 57 5c 61 67 6d 74 7b  82 8a 92 9a a3 ad b8 c3
        
        ;; channel 1 : jump table to song data

3bc8  d4 3b				; #3bd4
3bca  f3 3b				; #3bf3
        
        ;; channel 2 : jump table to song data

3bcc  58 3c 				; #3c58
3bce  95 3c				; #3c95
        
        ;; channel 3 : jump table to song data

3bd0  de 3c 				; #3cde	; data is #00, no sounds on this channel
3bd2  df 3c				; #3cdf	; data is #00, no sounds on this channel
        
        ;; song data 

; act 2 song

3bd4  f1 02 f2 03 f3 0f f4 01 82 70 69 82 70 69 83 70
3be4  6a 83 70 6a 82 70 69 82 70 69 89 8b 8d 8e ff

; act 2 song

3bf3  f1 02 f2 03 f3 0f f4 01 67 50 30 47 30 67 50 30
3c03  47 30 67 50 30 47 30 4b 10 4c 10 4d 10 4e 10 67
3c13  50 30 47 30 67 50 30 47 30 67 50 30 47 30 4b 10
3c23  4c 10 4d 10 4e 10 67 50 30 47 30 67 50 30 47 30
3c33  67 50 30 47 30 4b 10 4c 10 4d 10 4e 10 77 20 4e
3c43  10 4d 10 4c 10 4a 10 47 10 46 10 65 30 66 30 67
3c53  40 70 f0 fb 3b

; act 2 song

3c58  f1 00 f2 02 f3 0f f4 00 42 50 4e 50 49 50 46 50
3c68  4e 49 70 66 70 43 50 4f 50 4a 50 47 50 4f 4a 70
3c78  67 70 42 50 4e 50 49 50 46 50 4e 49 70 66 70 45
3c88  46 47 50 47 48 49 50 49 4a 4b 50 6e ff

; act 2 song (2nd half)

3c95  f1 01 f2 01 f3 0f f4 00 26 67 26 67 26 67 23 44
3ca4  42 47 30 67 2a 8b 70 26 67 26 67 26 67 23 44 42
3cb4  47 30 67 23 84 70 26 67 26 67 26 67 23 44 42 47
3cc4  30 67 29 6a 2b 6c 30 2c 6d 40 2b 6c 29 6a 67 20
3cd4  29 6a 40 26 87 70 f0 9d 3c 00 

3cde  00

3cdf  00


--------------------------------------------------------------------------------

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

967d  95 96				; #9695	; startup song
967f  d6 96				; #96d6	; act 1 song
9681  58 3c				; #3c58	; act 2 song
9683  4f 97				; #974f	; act 3 song

       ;; channel 1 : jump table to song data

9685  b6 96				; #96b6	; startup song
9687  19 97				; #9719	; act 1 song
9689  d4 3b				; #3bd4	; act 2 song
968b  72 97				; #9772	; act 3 song

       ;; channel 3 : jump table to song data (nothing here, 9796 = 0xff)

968d  96 97 96 97 96 97 96 97

       ;; songs data
       

;; songs data
; if '1' = 0 & '2' = MELODY
; MELODY = 0
; HARMONY = 1

; startup song
!    !    IF '1' = 0 & '2' = MELODY

!    TITLE!    "SONATA FOR UNACCOMPANIED VIDEO GAME"

9695  f1 00 f2 02 f3 0a f4 00  41 43 45 86 8a 88 8b 6a
96a5  6b 71 6a 88 8b 6a 6b 71  6a 6b 71 73 75 96 95 96
96b5  ff

.org 0x9695
.byte 0xf1, 0x00, 0xf2, 0x02, 0xf3, 0x0a, 0xf4, 0x00
.byte 0x41, 0x43, 0x45
.byte 0x86, 0x8a, 0x88, 0x8b
.byte 0x6a, 0x6b, 0x71, 0x6a, 0x88, 0x8b
.byte 0x6a, 0x6b, 0x71, 0x6a, 0x6b, 0x71, 0x73, 0x75
.byte 0x96, 0x95, 0x96, 0xff


; startup song

96b6  f1 02 f2 03 f3 0a f4 02  50 70 86 90 81 90 86 90
96c6  68 6a 6b 68 6a 68 66 6a  68 66 65 68 86 81 86 ff

; act 1 song

96d6  f1 00 f2 02 f3 0a f4 00  69 6b 69 86 61 64 65 86
96e6  86 64 66 64 61 69 6b 69  86 61 64 64 a1 70 71 74
96f6  75 35 76 30 50 35 76 30  50 54 56 54 51 6b 69 6b
9706  69 6b 91 6b 69 66 f2 01  74 76 74 71 74 71 6b 69
9716  a6 a6 ff

; act 1 song

9719  f1 03 f2 03 f3 0a f4 02  70 66 70 46 50 86 90 70
9729  66 70 46 50 86 90 70 66  70 46 50 86 90 70 61 70
9739  41 50 81 90 f4 00 a6 a4  a2 a1 f4 01 86 89 8b 81
9749  74 71 6b 69 a6 ff

; act 3 song

974f  f1 00 f2 02 f3 0a f4 00  65 64 65 88 67 88 61 63
975f  64 85 64 85 6a 69 6a 8c  75 93 90 91 90 91 70 8a
976f  68 71 ff

; act 3 song

9772  f1 02 f2 03 f3 0a f4 02  65 90 68 70 68 67 66 65
9782  90 61 70 61 65 68 66 90  63 90 86 90 85 90 85 70
9792  86 68 65 ff

9796  ff


