;; Ms. Pac-Man documented disassembly
;;
;;  The copyright holders for the core program
;;  included within this file are:
;;	(c) 1980 NAMCO
;;	(c) 1980 Bally/Midway
;;	(c) 1981 General Computer Corporation (GCC)
;;
;;  Research and compilation of the documentation by
;;	Scott Lawrence
;;	pacman@umlautllama.com  @yorgle
;;
;;  Documentation and Hack Contributors:
;;      Don Hodges                 http://www.donhodges.com
;;      David Caldwell             http://www.porkrind.org
;;      Frederic Vecoven           http://www.vecoven.com (Music, Sound)
;;      Fred K "Juice"
;;      Marcel "The Sil" Silvius   http://home.kabelfoon.nl/~msilvius/
;;      Mark Spaeth                http://rgvac.978.org/asm
;;      Dave Widel                 http://www.widel.com/
;;      M.A.B. from Vigasoco

;;
;; DISCLAIMER:
;;	This project is a learning experience.  The goal is to try
;;	to figure out how the original programmers and subsequent
;;	GCC programmers wrote Pac-Man, Crazy Otto, and Ms. Pac-Man.
;;	This disassembly and comments are not sanctioned in any
;;	way by any of the copyright holders of these programs.
;;
;;  Over time, this document may transform from a documented disassembly
;;   of the bootleg ms-pacman roms into a re-assemblable source file.
;;
;;  This is also made to determine which spaces in the roms are available
;;   for patches and extra functionality for your own hacks.
;;
;;	NOTE:  This disassembly is based on the base "bootleg" 
;;		version of Ms. Pac-Man.   ("boot1" through "boot6")
;; 	rom images used:
;;		0x0000 - 0x0fff		boot1
;;		0x1000 - 0x1fff		boot2
;;		0x2000 - 0x2fff		boot3
;;		0x3000 - 0x3fff		boot4
;;		0x8000 - 0x8fff		boot5
;;		0x9000 - 0x9fff		boot6
;;
;;  More information about the actual Ms. Pac-Man aux board is below.
;;

;;
;;	IF YOU ARE AWARE OF ANY BITS OF CODE THAT ARE NOT DOCUMENTED
;;	HERE, OR KNOW OF MORE RAM ADDRESSES OR SUCH, PLEASE EMAIL
;;	ME SO THAT I MAY INTEGRATE YOUR INFORMATION INTO HERE.
;;
;;				THANKS!

;; 2014-01-18
;;	tried to document HACK2 (standard speedup hack) but it makes no sense
;;	added more info about #f2 LOOP and ANIMATIONS in general
;;
;; 2014-01-16
;;	Completely documented DrawText (2c5e)
;;
;; 2014-01-12
;;	Text string decodings (0x3713, 0x3d00) for readibility
;;	Animation code engine at 0x34a9
;;	Animation code lists at 0x8251, Rosetta stone at 0x8395
;;
;; 2014-01-06
;;	Don Hodges' documentation work added
;;	bugfix section added.
;;		HACK8 -> BUGFIX01
;;		HACK9 -> BUGFIX02
;;		HACK10 -> HACK8
;;		HACK11 -> HACK9
;;
;; 2014-01-02
;;	Added "OTTOPATCH" information from Crazy Otto source
;;
;; 2009-12-16
;;	Added some Crazy Otto notes
;;
;; 2009-01-18
;;	Added content from Don Hodges for much of the undocumented code
;;
;; 2008-06-20
;;	Added content from Frederic Vecoven for all of the sound code
;;
;; 2007-09-03
;;	added more notes about mspac blocks in 8000/9000
;;	RAM layout, data tables from M.A.B. in the VIGASOCO project (pac)
;;
;; 2004-12-28
;;	added Interrupt Mode 1/2 documentation
;;
;; 2004-12-22
;;	added HACK12 - the C000 text mirror bug fix
;;
;; 2004-03-21
;;	added information for most of the reference tables for map-related-data
;;
;; 2004-03-15
;;	working on figuring out RST 28	
;;
;; 2004-03-09
;;	added comments about how the text rendering works (at 0x2c5e)
;;	added more details about the text string look up table
;;	added information about midway logo rendering at 0x964a
;;	changed all of the RST 28 calls to have data after them
;;
;; 2004-03-03
;;	mapped out most of the patches in 8000-81ef range
;;	(some are unused ff's, some I couldn't find...)
;;
;; 2004-03-02
;;	HACK10: Dave Widel's fast intermission fix (based on Dock Cutlip's code)
;;		(now HACK8)
;;	HACK11: Dave Widel's coin light blink with power pellets
;;		(now HACK9)
;;
;; 2004-02-18
;;	HACK8: Mark Spaeth's "20 byte" level 255 Pac-Man rom fix (BUGFIX01)
;;	HACK9: Mark Spaeth's Ms. Pac-Man level fix (BUGFIX02)
;;
;; 2004-01-10
;;	figured out some of the sound generation triggering
;;
;; 2004-01-09
;;	added notes about HACK7 : eliminating all of the startup tests
;;	figured out the easter egg routine as well as storage method for data
;;
;; 2004-01-05
;;	added notes about HACK6 : the standard "HARD" romset
;;	changed all of the HACK numbers
;;
;; 2004-01-04
;;	added notes from Fred K's roms about skipping the self test  HACK4
;;	added notes about the pause routine HACK5
;;	added notes from Fred K about 018c game loop
;;
;; 2004-01-03
;;	added note about 0068-008c being junk - INCORRECT! (ed.)
;;
;; 2004-01-02
;;	added in more information about controllers
;;	added info about the always-on fast upgrade  HACK2
;;	added info about the P1P2 cheat HACK3
;;
;; 2004-01-01
;;	integrated in Mark Spaeth's random fruit doc.
;;
;; 2003-07-16
;; 	added in red ghost AI code documentation (2730, 9561)
;;
;; 2003-03-26
;;	changed some 'kick the dog' text
;;	added a note about the checksum hack ; HACK1
;;
;; 2003-03
;;	cleaned up some notes, added the "Made By Namco" egg notes
;;
;; + 2001-07-13
;;       more notes from David Widel.  Ram variables, $2a23m $8768
;;
;; + 2001-06-25,26
;;      integrated in some notes from David Widel (THANKS!)
;;
;; 2001-03-06
;;      integrated in Fred K's pacman notes.
;;
;; 2001-03-04
;;      corrected text strings in the lookup table at 36a5
;;      commented some of the text string routines
;;
;; 2001-02-28
;;      added text string lookup tables
;;      added indirect lookup at 36a5
;;      added more commenting over from the pacman.asm file
;;  
;; 2001-02-27
;;      table data pulled out, and bogus opcodes removed.
;;      more score information found as well

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Documented Hacks
;;
;;	these are common hacks done to this codebase

	HACK1
		Skips the traditional bad-rom checksum routine.

	HACK2
		Traditional "Fast Chip" hack

	HACK3
		Dock Cutlip's Fast/Invincibility hack.
		Press P1 start for super speed
		Press P2 start for invincibility

	HACK4
		Self-Test skip
		Reclaims rom space 3006 - 30c0 for custom code use

	HACK5
		Game pause routine
		Press P1 start to pause
		Press P2 start to unpause

	HACK6
		The standard "HARD" romset.
		Unknown exactly what the changes are. (data table)

	HACK7
		Skips the Test startup display
		(Alternate) just skips the grid.

	HACK8 (formerly HACK10)
		Dave Widel's faster intermission fix
		Based on Dock Cutlip's code
		Pac moves at normal speeds in intermissions
		(this is a hack, not a fix, since it's based on a hack/mod

	HACK9 (formerly HACK11)
		Dave Widel's coin light blink with power pellets
		Coin lights blink when power pellets blink now

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Documented bugfixes
;;
;;	these are bugfixes to the code base

	BUGFIX01 - Level 255 Pac-Man kill screen killer
		from: Mark Spaeth
		notes: Mark Spaeth's level 255 Pac-Man fix
			Mspac never gets to 255, so this fix is pac-only

	BUGFIX02 - Level 141 Ms. Pac-Man kill screen killer
		ref: http://www.funspotnh.com/discus/messages/10/508.html?1077146991
		from: Mark Spaeth
		notes: This fix is Ms. Pac only, but will work for pac as well.

	BUGFIX03 - Blue Maze
		from: Don Hodges
		ref: http://donhodges.com/ms_pacman_bugs.htm
		symptoms: Sometimes when starting Ms Pac, the first
			board is blue.

	BUGFIX04 - Marquee left side animation fix
		from: Don Hodges
		ref: http://donhodges.com/ms_pacman_bugs.htm
		symptoms: incorrect character in the intro screen
		causes the intro marquee to not work on the left side

	BUGFIX05 - Map discoloration fix
		from: Don Hodges
		ref: http://donhodges.com/ms_pacman_bugs.htm
		symptoms: The marquee doesn't light correctly,
			Other characters glitch on gameplay maps


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Known Ms. Pac variants:
;
; Pac variants:
;	Puckman              Namco "original"
;	Hanglyman            Maze disappears sometimes, vertical tunnel?
;	Pac-Man              Namco/Midway
;	Pac-Man Hard         (table changes)
;	Pac-Man Plus         Midway upgrade - New ghosts, 
;                            harder gameplay, disappearing map
;
; (pre-release GCC versions:)
;   Crazy Otto           10/12/1981 (P1) Pac-man intro, legs, monsters, 
;                                        GENCOMP logo,
;                                        no eyes when ghosts return to jail
;   Crazy Otto           10/20/1981 (P2) Marquee (Mspac) intro, legs,
;                                        ghosts, Midway logo
;   Super Pac-Man        10/29/1981 (P3) Same as P2, with no legs, monsters
;   Super Pac-Man        10/29/1981 (P4) Same as P3, ghosts
;   Miss Pac-Man         11/12/1981 (P5) Marquee, "Pac-Woman" graphics, monsters
;   Ms. Pac-Man          11/25/1981 (P6) Same as P5, MsPac graphics, Bonnie
;
' (Released versions)
;	Ms. Pac-Man          12/18/1981  Original GCC/Midway w/ aux board
;                                        (hardware protected)
;	Ms. Pac-Man          Bootleg (various) decoded aux board
;                                        (no hardware protection)
;	Ms. Pac-Man Attack   four new maps, broken fruit movement
;	Miss Pac Plus        four new maps (same as Attack, reversed)
; and of course, the "fast" and "cheat" versions of those above.
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; JUNK REGIONS OF ROMSPACE
;;

	There are a few regions of rom space that are unused by
	the ms-pac program.  These can be used for your own patches,
	or for data, or whatever.

	This list is most definitely incomplete.
	Not all of these regions have been tested.
	The list is inclusive of the start and end byte listed below.

	Some routines (like the self-test) can be dropped to give
	you more romspace to work with.  You should be careful
	however in that some chunks of romspace might not be free
	with some rom hacks.
	(0f3c - 0f4b for example)

	003b - 0041	  7 bytes	Tested
	0f3c - 0fff	195 bytes	Untested, nops
	1fa9 - 1fff	 87 bytes	Untested, nops, 48 used for HACK3 cheat
	2fba - 2fff	 70 bytes	Untested, nops
	3ce0 - 3cff	 32 bytes	Untested, nops
	8000 - 81ef	1f0 bytes	Untested, bootleg hardware ONLY!
	97c4 - 97cf	  c bytes	Untested, FF's
	97d0 - 97f0	 30 bytes	Untested, message
	9800 - 9fff     400 bytes	not available on "pure" mspac.
    
    Similarly, there are chunks of code in the 0x0000-0x3fff area that are previously
    used for Pac functionality that has been replaced by the aux roms, which can be
    re-purposed.
    
    If you're working with a bootleg romset, then the roms specific
    to the Aux Board, namely "BOOT5" 0x8000-0x8fff, has a lot of space
    previously used by the patching mechanism, in 0x8000-0x87ff, which 
    can be re-used for other code/tables.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Ms Pacman Aux board information (GCC/Midway Pac-Man "Upgrade")

ED note:  The U5, U6 and U7 notes below have yet to be confirmed.

	It turns out the bootleg is the decrypted version with the
	checksum check removed and interrupt mode changed to 1.

	u7= boot 4($3000-$3fff) other than 4 bytes(checksum check
	and interupt mode)

	u6= boot 6($9000-$9fff). The second half of u6 gets mirrored
	Renders to the second half of boot5($8800-$8fff) where it
	is used.
	u5= first half of boot5($8000-$87ff)

	$8000-$81ef contain 8 byte patches that are overlayed on
	locations in $0000-$2fff

	The Ms Pacman aux board is not activated with the
	mainboard.  As near as I can tell it requires a sequence
	of bytes starting at around 3176 and ending with 3196. The
	location of the bytes doesn't seem to matter, just that
	those bytes are executed. That sequence of bytes includes
	a write to 5006 so I'm using that to bankswitch, but that
	is not accurate. The actual change is I believe at $317D.
	The aux board can also be deactivated. A read to any
	of the several 8 byte chunks listed will cause the Ms Pac
	roms to disappear and Pacman to show up.  As a result I
	couldn't verify what they contained. They should be the
	same as the pacman roms, but I don't see how it could
	matter. These areas can be accessed by the random number
	generator at $2a23 and the board is deactivated but is
	immediately reactivated. So the net result is no change.
	The exact trigger for this is not yet known.

	deactivation, 8 bytes starting at:
	$38,$3b0,$1600,$2120,$3ff0,$8000

	David Widel
	d_widel@hotmail.com

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Ghost names:

            Pac-Man         Otto            Ms pre      Ms Release

Red         Shadow/Blinky   Mad Dog/Plato   Blinky      Blinky
Pink        Speedy/Pinky    Killer/Darwin   Pinky       Pinky
Cyan        Bashful/Inky    Brute/Freud     Inky        Inky
Orange      Pokey/Clyde     Sam/Newton      Bonnie      Sue

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; ram:
;	4c00	unknown
;	4c01	unknown
;
; Sprite variables
;
;	4c02	red ghost sprite number
;	4c03	red ghost color entry
;	4c04	pink ghost sprite number
;	4c05	pink ghost color entry
;	4c06	blue ghost sprite number
;	4c07	blue ghost color entry
;	4c08	orange ghost sprite number
;	4c09	orange ghost color entry
;	4c0a	pacman sprite number
;	4c0b	pacman color entry
;	4c0c	fruit sprite number
;	4c0d	fruit sprite entry
;
;	4c20	sprite data that goes to the hardware sprite system
;
;	4c22-4c2f sprite positions for spriteram2
;	4c32-4c3f sprite number and color for spriteram
;	
;	4C40-4C41 used for moving fruit positions
; 	4C42-4C43 used to hold address of the fruit path
;	4c44-4c7f unused/unknown
;
; Tasks and Timers
;
;	4c80	\ pointer to the end of the tasks list
;	4c81	/
;	4c82	\ pointer to the beginning of the tasks list
;	4c83	/
;	4c84	8 bit counter (0x00 to 0xff) used by sound routines
;	4c85	8 bit counter (0xff to 0x00) (unused)
;	4c86	counter 0: 0..5 10..15 20..25  ..  90..95 - hundreths
;	4c87	counter 1: 0..9 10..19 20..29  ..  50..59 - seconds
;	4c88	counter 2: 0..9 10..19 20..29  ..  50..59 - minutes
;	4c89	counter 3: 0..9 10..19 20..29  ..  90..99 - hours
;
;	4c8a	number of counter limits changes in this frame (to init time)
;		0x01	1 hundredth
;		0x02	10 hundredths
;		0x03	1 second
;		0x04	10 seconds
;		0x05	1 minute
;		0x06	10 minutes
;		0x07	1 hour
;		0x08	10 hours
;		0x09	100 hours
;	4c8b	random number generation (unused)
;	4c8c	random number generation (unused)
;
;	4c90-4cbf scheduled tasks list (run inside IRQ)
;		16 entries, 3 bytes per entry
;		Format:
;		byte 0: scheduled time
;                        7 6 5 4 3 2 1 0
;                        | | | | | | | |
;                        | | ------------ number of time units to wait
;                        | |
;                        ---------------- time units
;                                                0x40 -> 10 hundredths
;                                                0x80 -> 1 second
;                                                0xc0 -> 10 seconds
;		byte 1: index for the jump table
;		byte 2: parameter for b
;		these tasks are assigned using RST #30, with the three data bytes immediatly after the call used for the timer, index and parameter
;		these tasks are decoded at routine starting at #0221		
;
;	4cc0-4ccf tasks to execute outside of IRQ
;		0xFF fill for empty task
;		16 entries, 2 bytes per entry
;		Format:
;		byte 0: routine number
;		byte 1: parameter
;		these tasks are assigned using RST #28, with the two data bytes immedately after the call used for the routine number and parameter
		alternately, tasks can be assigned by manually loading B and C with routine and parameter, and then executing call #0042
;		tasks are decoded at routine starting at #238D
;
; Game variables
; ** note - need to be sorted
;
;   4DD2    FRUITP  fruit position
;   4DD4    FVALUE  value of the current fruit (0=no fruit)
;   4C40    COUNT current place in fruit path
;   4E0C    FIRSTF  flag to indicate that first fruit has been released
;   4E0D    SECONDF flag to indicate that second fruit has been eaten
;   4C41    BCNT    current place within bounce
;   4C42    PATH    pointer to the path the fruit is currently following
;   4E0E    DOTSEAT how many dots the current player has eaten
;   4EBC    BNOISE  set bit 5 of BNOISE to make the bounce sound

;	4d00	red ghost Y position (bottom to top = decreases)
;	4d01	red ghost X position (left to right = decreases)
;	4d02	pink ghost Y position (bottom to top = decreases)
;	4d03	pink ghost X position (left to right = decreases)
;	4d04	blue ghost Y position (bottom to top = decreases)
;	4d05	blue ghost X position (left to right = decreases)
;	4d06	orange ghost Y position (bottom to top = decreases)
;	4d07	orange ghost X position (left to right = decreases)
;
;	4d08	pacman Y position
;	4d09	pacman X position
;
;	4d0a	red ghost Y tile pos (mid of tile) (bottom to top = decrease)
;	4d0b	red ghost X tile pos (mid of tile) (left to right = decrease)
;	4d0c	pink ghost Y tile pos (mid of tile) (bottom to top = decrease)
;	4d0d	pink ghost X tile pos (mid of tile) (left to right = decrease)
;	4d0e	blue ghost Y tile pos (mid of tile) (bottom to top = decrease)
;	4d0f	blue ghost X tile pos (mid of tile) (left to right = decrease)
;	4d10	orange ghost Y tile pos (mid of tile) (bottom to top = decrease)
;	4d11	orange ghost X tile pos (mid of tile) (left to right = decrease)
;	4d12	pacman tile pos in demo and cut scenes
;	4d13	pacman tile pos in demo and cut scenes
;
;	for the following, last move was 
;		(A) 0x00 = left/right, 0x01 = down, 0xff = up
;		(B) 0x00 = up/down, 0x01 = left, 0xff = right
;	4d14	red ghost Y tile changes (A)
;	4d15	red ghost X tile changes (B)
;	4d16	pink ghost Y tile changes (A)
;	4d17	pink ghost X tile changes (B)
;	4d18	blue ghost Y tile changes (A)
;	4d19	blue ghost X tile changes (B)
;	4d1a	orange ghost Y tile changes (A)
;	4d1b	orange ghost X tile changes (B)
;	4d1c	pacman Y tile changes (A)
;	4d1d	pacman X tile changes (B)
;
;	4d1e	red ghost y tile changes
;	4d1f	red ghost x tile changes
;	4d20	pink ghost y tile changes
;	4d21	pink ghost x tile changes
;	4d22	blue ghost y tile changes
;	4d23	blue ghost x tile changes
;	4d24	orange ghost y tile changes
;	4d25	orange ghost x tile changes
;	4d26	wanted pacman tile changes
;	4d27	wanted pacman tile changes
;
;		character orientations:
;		0 = right, 1 = down, 2 = left, 3 = up
;	4d28	previous red ghost orientation (stored middle of movement)
;	4d29	previous pink ghost orientation (stored middle of movement)
;	4d2a	previous blue ghost orientation (stored middle of movement)
;	4d2b	previous orange ghost orientation (stored middle of movement)
;	4d2c	red ghost orientation (stored middle of movement)
;	4d2d	pink ghost orientation (stored middle of movement)
;	4d2e	blue ghost orientation (stored middle of movement)
;	4d2f	orange ghost orientation (stored middle of movement)
;
;	4d30	pacman orientation
;
;		these are updated after a move
;	4d31	red ghost Y tile position 2 (See 4d0a)
;	4d32	red ghost X tile position 2 (See 4d0b)
;	4d33	pink ghost Y tile position 2
;	4d34	pink ghost X tile position 2
;	4d35	blue ghost Y tile position 2
;	4d36	blue ghost X tile position 2
;	4d37	orange ghost Y tile position 2
;	4d38	orange ghost X tile position 2
;
;	4d39	pacman Y tile position (0x22..0x3e) (bottom-top = decrease)
;	4d3a	pacman X tile position (0x1e..0x3d) (left-right = decrease)
;
;	4d3c	wanted pacman orientation
;
;	path finding algorithm:
;	4d3b		best orientation found 
;	4d3d		saves the opposite orientation
;	4d3e-4d3f 	saves the current tile position
;	4d40-4d41 	saves the destination tile position
;	4d42-4d43 	temp resulting position
;	4d44-4d45 	minimum distance^2 found
;
;	4dc7		current orientation we're trying
;	4d46-4d85 	speed bit patterns (difficulty dependant)
;	4D46-4D49       speed bit patterns for pacman in normal state
;	4D4A-4D4D       speed bit patterns for pacman in big pill state
;	4D4E-4D51       speed bit patterns for second difficulty flag
;	4D52-4D55       speed bit patterns for first difficulty flag
;	4D56-4D59       speed bit patterns for red ghost normal state
;	4D5A-4D5D       speed bit patterns for red ghost blue state
;	4D5E-4D61       speed bit patterns for red ghost tunnel areas
;	4D62-4D65       speed bit patterns for pink ghost normal state
;	4D66-4D69       speed bit patterns for pink ghost blue state
;	4D6A-4D6D       speed bit patterns for pink ghost tunnel areas
;	4D6E-4D71       speed bit patterns for blue ghost normal state
;	4D72-4D75       speed bit patterns for blue ghost blue state
;	4D76-4D79       speed bit patterns for blue ghost tunnel areas
;	4D7A-4D7D       speed bit patterns for orange ghost normal state
;	4D7E-4D81       speed bit patterns for orange ghost blue state
;	4D82-4D83       speed bit patterns for orange ghost tunnel areas
;
;	4d86-4d93
;	    Difficulty related table. Each entry is 2 bytes, and
;	    contains a counter value.  when the counter at 4DC2
;	    reaches each entry value, the ghosts changes their
;	    orientation and 4DC1 increments it's value to point to
;	    the next entry
;
;	4d94	counter related to ghost movement inside home
;	4d95-4d96 number of units before ghost leaves home (no change w/ pills)
;	4d97-4d98 inactivity counter for units of the above
;
;	4d99 - 4d9c
;	    These values are normally 0, but are changed to 1 when a ghost has
;	    entered a tunnel slowdown area
;	4d99	aux var used by red ghost to check positions
;	4d9a	aux var used by pink ghost to check positions
;	4d9b	aux var used by blue ghost to check positions
;	4d9c	aux var used by orange ghost to check positions
;
;	4d9d	delay to update pacman movement
;		not 0xff - the game doesn't move pacman, but decrements instead
;		0x01	when eating pill
;		0x06	when eating big pill
;		0xff	when not eating a pill
;	4d9e	related to number of pills eaten before last pacman move
;	4d9f	eaten pills counter after pacman has died in a level
;		used to make ghosts go out of home after # pills eaten
;
;		ghost substates:
;		0 = at home
;		1 = going for pac-man
;		2 = crossing the door
;		3 = going to the door
;
;	4da0	red ghost substate (if alive)
;	4da1	pink ghost substate (if alive)
;	4da2	blue ghost substate (if alive)
;	4da3	orange ghost substate (if alive)
;	4da4	# of ghost killed but no collision for yet [0..4]
;	4da5	pacman dead animation state (0 if not dead)
;	4da6	power pill effect (1=active, 0=no effect)
;
;	4da7	red ghost blue flag (0=not blue)
;	4da8	pink ghost blue flag (0=not blue)
;	4da9	blue ghost blue flag (0=not blue)
;	4daa	orange ghost blue flag (0=not blue)
;
;	4dab	killing ghost state
;		0 = nothing
;		1 = kill red ghost
;		2 = kill pink ghost
;		3 = kill blue ghost
;		4 = kill orange ghost
;
;		ghost states:
;		0 = alive
;		1 = dead
;		2 = entering home after being killed
;		3 = go left after entering home after dead (blue)
;		3 = go right after entering home after dead (orange)
;	4dac	red ghost state
;	4dad	pink ghost state
;	4dae	blue ghost state
;	4daf	orange ghost state
;
;	4db0	related to difficulty, appears to be unused 
;
;		with these, if they're set, ghosts change orientation
;	4db1	red ghost change orientation flag
;	4db2	pink ghost change orientation flag
;	4db3	blue ghost change orientation flag
;	4db4	orange ghost change orientation flag
;	4bd5	pacman change orientation flag
;
; Difficulty settings
;
;	4db6	1st difficulty flag (rel 4dbb) (cruise elroy 1)
;		0: red ghost goes to upper right corner on scatter
;		1: red ghost goes for pacman on scatter
;		1: red ghost goes faster
;	4db7	2nd difficulty flag (rel 4dbc) (cruise elroy 2)
;		when set, red uses a faster bit speed pattern
;		0: not set
		1: faster movement
;	4db8	pink ghost counter to go out of home limit (rel 4e0f)
;	4db9	blue ghost counter to go out of home limit (rel 4e10)
;	4dba	orange ghost counter to go out of home limit (rel 4e11)
;	4dbb	remainder of pills when first diff. flag is set (cruise elroy 1)
;	4dbc	remainder of pills when second diff. flag is set (cruise elroy 2)
;	4dbd-4dbe Time the ghosts stay blue when pacman eats a big pill
;
;	4dbf	1=pacman about to enter a tunnel, otherwise 0
;
; Counters
;
;	4dc0	changes every 8 frames; used for ghost animations
;	4dc1	orientation changes index [0..7]. used to get value 4d86-4d93
;		0: random ghost movement, 1: normal movement (?)
;	4dc2-4dc3 counter related to ghost orientation changes
;	4dc4	counter 0..8 to handle things once every 8 times
;	4dc5-4dc6 counter started after pacman killed
; 	4dc7	counter for current orientation we're trying
;	4dc8	counter used to change ghost colors under big pill effects
;
;	4dc9-4dca pointer to pick a random value from the ROM (routine 2a23)
;
;	4dcb-4dcc counter while ghosts are blue. effect ceases at 0
;	4dce	counter started after insert coin (LED and 1UP/2UP blink)
;	4dcf	counter to handle power pill flashes
;	4dd0	current number of killed ghosts (0..4)	(rel 4da5)
;
;	4dd1	killed ghost animation state
;		if 4da4 != 0:
;			4dd1 = 0: killed, showing points per kill
;			4dd1 = 1: wating
;			4dd1 = 2: clearing killed ghost, changing state to 0
;	4dd2-4dd3 fruit position (sometimes for other sprite)
;
;	4dd4	entry to fruit points or 0 if no fruit
;	4dd6	used for LED state( 1: game waits for 1P/2P start button press)
;
; Main States
;
;	4e00	main routine number
;		0: init
;		1: demo
;		2: coin inserted
;		3: playing
;	4e01	main routine 0, subroutine #
;	4e02	main routine 1, subroutine # (related to blue maze bug)
;	4e03	main routine 2, subroutine #
;	4e04	level state subroutine #
;		3=ghost move, 2=ghost wait for start
;		(set to 2 to pause game)
;
;	4e06	state in first cutscene (pac-man only)
;	4e07	state in second cutscene (pac-man only)
;	4e08	state in third cutscene (pac-man only)
;
;	4e09	current player number:  0=P1, 1=P2
;
;	4e0a-4e0b pointer to current difficulty settings
;
;	4C40	COUNT current place in fruit path
;	4E0C	FIRSTF  flag to indicate that first fruit has been released
;	4E0D	SECONDF flag to indicate that second fruit has been eaten
;	4C41	BCNT	current place within bounce
;	4C42	PATH	pointer to the path the fruit is currently following
;	4E0E	DOTSEAT	how many dots the current player has eaten
;	4EBC	BNOISE	set bit 5 of BNOISE to make the bounce sound
;
;	4e0c	first fruit flag (1 if fruit has appeared)
;	4e0d	second fruit flag (1 if fruit has appeared)
;	4e0e	number of pills eaten in this level
;	4e0f	counter incremented if orange, blue and pink ghosts are home
;		and pacman is eating pills.
;		used to make pink ghost leave home (rel 4db8)
;	4e10	counter incremented if orange, blue and pink ghosts are home
;		and pacman is eating pills.
;		used to make blue ghost leave home (rel 4db9)
;	4e11	counter incremented if orange, blue and pink ghosts are home
;		and pacman is eating pills.
;		used to make orange ghost leave home (rel 4db9)
;	4e12	1 after dying in a level, reset to 0 if ghosts have left home
;		because of 4d9f
;
;	4e13	current level
;	4e14	real number of lives
;	4e15	number of lives displayed
;
;	4e16-4e33 0x13 pill data entries. each bit means if a pill is there
;		or not (1=yes 0=no)
;		the pills start at upper right corner, go down, then left.
;		first pill is bit 7 of 4e16
;	4e34-4e37 power pills data entries
;	4e38-4e65 copy of level data (430a-4e37)
;
; coins, credits
;
;	4e66	last 4 SERVICE1 to detect transitions
;	4e67	last 4 COIN2 to detect transitions
;	4e68	last 4 COIN1 to detect transitions
;
;	4e69	coin counter (coin->credts, this gets decremented)
;	4e6a	coin counter timeout, used to write coin counters
;
;		these are copied from the dipswitches
;	4e6b	number of coins per credit
;	4e6c	number of coins inserted
;	4e6d	number of credits per coin
;	4e6e	number of credits, 0xff for free play
;	4e6f	number of lives
;	4e70	number of players (0=1 player, 1=2 players)
;	4e71	bonus/life
;		0x10 = 10000	0x15 = 15000
;		0x20 = 20000	0xff = none
;	4e72	cocktail mode (0=no, 1=yes)
;	4e73-4e74 pointer to difficulty settings
;		4e73: 68=normal 7d=hard checked at start of game
;	4e75	ghost names mode (0 or 1)
;
;		SCORE AABBCC
;	4e80-4e82 score P1	80=CC 81=BB 82=CC
;	4e83	P1 got bonus life?  1=yes
;	4e84-4e86 score P2	84=CC 85=BB 86=CC
;	4e87	P2 got bonus life?  1=yes
;	4e88-4e8a high score	88=CC 89=BB 8A=CC
;
; Sound Registers

        ;; these 16 values are copied to the hardware every vblank interrupt.

CH1_FREQ0       EQU     4e8c    ; 20 bits
CH1_FREQ1       EQU     4e8d
CH1_FREQ2       EQU     4e8e
CH1_FREQ3       EQU     4e8f
CH1_FREQ4       EQU     4e90
CH1_VOL         EQU     4e91
CH2_FREQ1       EQU     4e92    ; 16 bits
CH2_FREQ2       EQU     4e93
CH2_FREQ3       EQU     4e94
CH2_FREQ4       EQU     4e95
CH2_VOL         EQU     4e96
CH3_FREQ1       EQU     4e97    ; 16 bits
CH3_FREQ2       EQU     4e98
CH3_FREQ3       EQU     4e99
CH3_FREQ4       EQU     4e9a
CH3_VOL         EQU     4e9b

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

CH1_E_NUM       EQU     4e9c    ; effects to play sequentially (bitmask)
CH1_E_1         EQU     4e9d    ; unused
CH1_E_CUR_BIT   EQU     4e9e    ; current effect
CH1_E_TABLE0    EQU     4e9f    ; table of parameters, initially copied from ROM
CH1_E_TABLE1    EQU     4ea0
CH1_E_TABLE2    EQU     4ea1
CH1_E_TABLE3    EQU     4ea2
CH1_E_TABLE4    EQU     4ea3
CH1_E_TABLE5    EQU     4ea4
CH1_E_TABLE6    EQU     4ea5
CH1_E_TABLE7    EQU     4ea6
CH1_E_TYPE      EQU     4ea7
CH1_E_DURATION  EQU     4ea8
CH1_E_DIR       EQU     4ea9
CH1_E_BASE_FREQ EQU     4eaa
CH1_E_VOL       EQU     4eab

; 4EAC repeats the above for channel 2
; 4EBC repeats the above for channel 3

CH1_W_NUM       EQU     4ecc    ; wave to play (bitmask)
CH1_W_1         EQU     4ecd    ; unused
CH1_W_CUR_BIT   EQU     4ece    ; current wave
CH1_W_SEL       EQU     4ecf
CH1_W_4         EQU     4ed0
CH1_W_5         EQU     4ed1
CH1_W_OFFSET1   EQU     4ed2    ; address in ROM to find the next byte
CH1_W_OFFSET2   EQU     4ed3    ; (16 bits)
CH1_W_8         EQU     4ed4
CH1_W_9         EQU     4ed5
CH1_W_A         EQU     4ed6
CH1_W_TYPE      EQU     4ed7
CH1_W_DURATION  EQU     4ed8
CH1_W_DIR       EQU     4ed9
CH1_W_BASE_FREQ EQU     4eda
CH1_W_VOL       EQU     4edb
;
; 4EDC repeats the above for channel 2
; 4EEC repeats the above for channel 3
;
;
; Runtime
;
;	4F00		Is set to 1 during intermissions and parts of the attract mode, otherwise 0
;	4F01-4FBF	Stack
;	4FC0-4FEF	Unused
;	4FF0-4FFF	Sprite RAM
;
;
;
;
; Memory mapped ports:
; Read ports:
;	port#	Name	; condition & change			Example value
;	----------------------------------------------------------------------
;	5000	IN0	; When Nothing pressed 			#FF
;			; Joystick 1 UP clears bit 0		#FE
;			; Joystick 1 LEFT clears bit 1		#FD
;			; Joystick 1 RIGHT clears bit 2		#FB
;			; Joystick 1 DOWN clears bit 3		#F7
;			; Rack test clears bit 4		#EF
;			; Coin 1 inserted clears bit 5		#DF
;			; Coin 2 inserted clears bit 6		#BF
;			; Service 1 pressed clears bit 7	#7F
;
;	5040	IN1	; When Nothing pressed			#FF
;			; Joystick 2 UP clears bit 0		#FE
;			; Joystick 2 LEFT clears bit 1		#FD
;			; Joystick 2 RIGHT clears bit 2		#FB
;			; Joystick 2 DOWN clears bit 3		#F7
;			; service mode switch clears bit 4	#EF
;			; Player 1 start button clears bit 5	#DF
;			; Player 2 start button clears bit 6	#BF
;			; Cocktail cabinet DIP clears bit 7	#7F
;
;	5080	DSW 1	; controls free play/coins per credit, # of lives per game, 
;			; points needed for bonus, rack test, game freeze
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       PAC-MAN SPRITE CODES
;
;       00-07   fruits
;       08-0D   naked ghosts for cutscenes
;       0E-0F   empty
;       10-1B   big pacman
;       1C-1D   ghost in panic mode
;       1E-1F   empty
;       20-27   ghosts
;       28-2B   points
;       2C-2F   pacmans
;       30      big pacman
;       31      explosion
;       32-33   broken ghost
;       34-3F   pacman dead
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	MS. PAC-MAN SPRITE CODES
;
;	00 	cherry
; 	01	strawberry
;	02	peach
;	03	pretzel
;	04 	apple
;	05 	pear
;	06	banana
;	07 	sack that is dropped from stork in act 3
;	08 	100
;	09	200
;	0A	500
;	0B	700
;	0C	1000
;	0D	2000
;	0E	5000
;	0F	junior pac-man seen in act 3
;	10-17	parts of ACT director's sign
;	18	stork
;	19-1B 	pac-man
;	1C-1D	ghost in panic mode
;	1E	heart
;	1F	empty
;	20-27	ghosts
;	28	200
;	29	400
;	2A	800
;	2B	1600
;	2C	stork
;	2D	ms pacman	
;	2E	pac-man
;	2F	ms pacman
;	30	stork head + beak
;	31	ms pacman
;	32	pac-man
;	33-3F	ms pacman (used during dying animation)
;	40-7F	same as 00-3F, but upside down
;	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;       PACMAN TILE CODES
;
;       00-0F   hex digits
;       10-15   pills
;       16-1F   empty
;       ...
;       40-5B   space + ASCII chars
;       5C      copyright
;       5D-5F   PTS
;       ...
;       C0-FF   map obstacles
;
;       SPECIAL COLOR ENTRIES
;
;       18      for ghost's door
;       1A      for pacman's and ghost's initial map positions
;       1B      for tunnel area
;
;       PACMAN TILE CONFIGURATION
;
;       tile position x can go from 0x1e to 0x3d.
;       0x1d == wraparound -> 0x3d
;       0x3e == wraparound -> 0x1e
;       tile position y can go from 0x22 to 0x3e.
;       Why?
;       Because of the graphics hardware.
;       With that configuration, you can convert directly between 
;	tile position to hardware sprite positions
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	; rst 0 - initialization
	; init

0000  f3        di			; Disable interrupts
0001  3e00      ld      a,#00		; A := #00  
0003  ed47      ld      i,a		; Clear interrupt status register 
0005  c30b23    jp      #230b		; jump to startup test 

;; PAC
;0001  3e3f      ld      a,#3f
;;
	
	; rst 8 - memset()
	; Fill HL to HL+B with A

0008  77        ld      (hl),a		; store A
0009  23        inc     hl		; next memory
000a  10fc      djnz    #0008           ; loop until B == #00
000c  c9        ret     		; return

	; arrive here from #23A7

000d  c30e07    jp      #070e		; sets up difficulty

	; rst 10  (for dereferencing pointers to bytes)
        ; HL = HL + A, , A := (HL)
	; HL = base address of table
	; A  = index
	; after the call, A gets the data in HL+A

0010  85        add     a,l		; Add L into A
0011  6f        ld      l,a		; copy result into L
0012  3e00      ld      a,#00		; A := #00
0014  8c        adc     a,h		; Add with carry into H
0015  67        ld      h,a		; copy result into H
0016  7e        ld      a,(hl)		; load A with value in HL
0017  c9        ret     		; return

	; rst 18 (for dereferencing pointers to words)
        ; hl = hl + 2*b,  (hl) -> e, (++hl) -> d, de -> hl
        ; HL = base address of table
	; B  = index
	; after the call, HL gets the data in HL+(2*B).  DE becomes HL+2B
	; modified: DE, A

0018  78	ld	a,b		; load A with B
0019  87	add	a,a		; double it
001a  d7	rst	#10		; A:= data in (HL + 2B), HL := HL + 2B
001b  5f	ld	e,a		; copy result into E
001c  23	inc	hl		; next HL
001d  56	ld	d,(hl)		; D := (HL+2B+1)
001e  eb	ex	de,hl		; Exchange DE with HL.
001f  c9        ret     		; return


        ; rst 20 (jump table)
        ; Uses A as a vector to jump to the location indicated by 2*A after the call
	; For example, if A has #00 and the two bytes following the call are #AB and #CD, the program will jump to #CDAB

0020: E1	pop	hl		; load HL with return address.  This is the next byte after the call.
0021: 87	add	a,a		; A := 2*A
0022: D7	rst	#10		; HL += A,   A = (HL)
0023: 5F	ld	e,a		; Copy first (low) byte to E
0024: 23	inc	hl		; next Address
0025: 56 	ld	d,(hl)		; D = (HL+1) [high byte], so  DE = 16-bit address at 2*A after the call
0026: EB	ex	de,hl		; DE <-> HL
0027: E9	jp	(hl)		; jump to HL


	; rst 28
	; takes the 2 bytes after the call as data and inserts them into the task list

0028  e1        pop     hl		; HL = next byte after call, first data element
0029  46        ld      b,(hl)		; load B with first data byte
002a  23        inc     hl		; next data byte
002b  4e        ld      c,(hl)		; load C with second data byte
002c  23        inc     hl		; HL now has the proper return address
002d  e5        push    hl		; push to stack so RET will return properly
002e  1812      jr      #0042           ; continue this sub below

; rst #30
; when rst #30 is called, the 3 data bytes following the call are inserted
; into the timed task list at the next available location.  Up to #10 (16 decimal)
; locations are searched before giving up.

0030: 11 90 4C	ld	de,#4C90	; load DE with starting address of task table
0033: 06 10	ld	b,#10		; For B = 1 to #10
0035: C3 51 00	jp	#0051		; continue this sub below


	; rst 38 (vblank)
	; INTERRUPT MODE 1 handler

0038  c39b1f	jp      #1f9b		; patched jump from pacman.
003b  ----50 				; junk from pac-man
003c  320750    ld      (#5007),a	; junk from pac-man
003f  c33800    jp      #0038		; junk from pac-man

;; INTERRUPT MODE 2 (original hardware, non-bootlegs, puckman, pac plus)
;0038  af	xor	a
;0039  320050	ld	(#5000),a
;003c  320750	ld	(#5007),a   
;003f  c33800	jp	#0038
;;


	; continuation of rst 28 from #002E
	; this sub can be called with call #0042, if B and C are loaded manually

					; B and C have the data bytes
0042  2a804c    ld      hl,(#4c80)	; load HL with address pointing to the beginning of the task list
0045  70        ld      (hl),b		; store task 
0046  2c        inc     l		; next address
0047  71        ld      (hl),c		; store parameter
0048  2c        inc     l		; next address
0049  2002      jr      nz,#004d	; If non zero, skip next step
004b  2ec0      ld      l,#c0		; else load L with C0 to cycle HL back to #4CC0 (spins #C0-#FF)
004d  22804c    ld      (#4c80),hl	; store new task pointer back (4c80, 4c81) = hl
0050  c9        ret     		; return to program

	; continuation of rst 30 from #0035 (Task manager)

0051: 1A	ld	a,(de)		; load A with task
0052: A7	and	a		; == #00 ?
0053: 28 06	jr	z,#005B 	; yes, skip ahead, we will insert the new task here

0055: 1C	inc	e		; else inc E by 3
0056: 1C	inc	e
0057: 1C	inc	e		; DE now at next task
0058: 10 F7	djnz	#0051		; Next B, loops up to #10 times
005A: C9	ret			; return

005B: E1	pop	hl		; HL = data address of the 3 data bytes to be inserted
005C: 06 03	ld	b,#03		; For B = 1 to 3

005E: 7E	ld	a,(hl)		; load A with table value
005F: 12	ld 	(de),a		; store into task list
0060: 23	inc	hl		; next HL
0061: 1C	inc	e		; next DE
0062: 10 FA	djnz	#005E		; next B
0064: E9	jp	(hl)		; return to program (HL now has return address following the 3 data bytes)

	; this is a common call
	; converts pac-mans sprite position into a grid position

0065  c32d20    jp      #202d

	; difficulty settings table data - normal #0068
	; these are assigned at a routine starting at #070E

0068  00 01 02 03 04 05 06 07
0070  08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 

	; difficulty settings table data - hard #007D
	; these are assigned at a routine starting at #070E

007D  01 03 04
0080  06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 14 

	;; part of the interrupt routine (non-test)
	;; continuation of RST 38 partially...  (vblank)
	;; (gets called from the #1f9b patch, from #0038)

008d  f5        push    af		; save AF [restored at #01DA]
008e  32c050    ld      (#50c0),a	; kick the dog
0091  af        xor     a		; 0 -> a
0092  320050    ld      (#5000),a	; disable hardware interrupts
0095  f3        di			; disable cpu interrupts

; save registers. they are restored starting at #01BF

0096  c5        push    bc		; save BC
0097  d5        push    de		; save DE
0098  e5        push    hl		; save HL
0099  dde5      push    ix		; save IX
009b  fde5      push    iy		; save IY

        ;;
        ;; VBLANK - 1 (SOUND)
        ;;
        ;; load the sound into the hardware
	;;

009d  ld      hl,#CH1_FREQ0             ; pointer to frequencies and volumes of the 3 voices
00a0  ld      de,#5050                  ; hardware address
00a3  ld      bc,#0010                  ; #10 (16 decimal) byte to copy
00a6  ldir                              ; copy

        ;; voice 1 wave select

00a8  ld      a,(#CH1_W_NUM)            ; if we play a wave
00ab  and     a
00ac  ld      a,(#CH1_W_SEL)            ; then WaveSelect = CH1_W_SEL
00af  jr      nz,#00b4

00b1  ld      a,(#CH1_E_TABLE0)         ; else WaveSelect = CH1_E_TABLE0

00b4  ld      (#5045),a                 ; write WaveSelect to hardware

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


	; copy last frame calculated sprite data into sprite buffer

00d5  21024c    ld      hl,#4c02	; load HL with source address (calculated sprite data)
00d8  11224c    ld      de,#4c22	; load DE with destination (sprite buffer)
00db  011c00    ld      bc,#001c	; load counter with #1C bytes to copy
00de  edb0      ldir    		; copy

	; update sprite data, adjusting to hardware

00e0  dd21204c  ld      ix,#4c20	; load IX with start of sprite buffer	
00e4  dd7e02    ld      a,(ix+#02) 	; load A with red ghost sprite
00e7  07        rlca
00e8  07        rlca			; rotate 2 bits up 
00e9  dd7702    ld      (ix+#02),a	; store
00ec  dd7e04    ld      a,(ix+#04)	; load A with pink ghost sprite
00ef  07        rlca    
00f0  07        rlca    		; rotate 2 bits up
00f1  dd7704    ld      (ix+#04),a	; store
00f4  dd7e06    ld      a,(ix+#06)	; load A with blue (inky) ghost sprite
00f7  07        rlca    
00f8  07        rlca    		; rotate 2 bits up
00f9  dd7706    ld      (ix+#06),a	; store
00fc  dd7e08    ld      a,(ix+#08)	; load A with orange ghost sprite
00ff  07        rlca    
0100  07        rlca    		; rotate 2 bits up
0101  dd7708    ld      (ix+#08),a	; store
0104  dd7e0a    ld      a,(ix+#0a)	; load A with ms pac sprite
0107  07        rlca    
0108  07        rlca    		; rotate 2 bits up
0109  dd770a    ld      (ix+#0a),a	; store
010c  dd7e0c    ld      a,(ix+#0c)	; load A with fruit sprite
010f  07        rlca    
0110  07        rlca    		; rotate 2 bits up
0111  dd770c    ld      (ix+#0c),a	; store

0114  3ad14d    ld      a,(#4dd1)	; load A with killed ghost animation state
0117  fe01      cp      #01		; is there a ghost being eaten ?
0119  2038      jr      nz,#0153        ; no , skip ahead

011b  dd21204c  ld      ix,#4c20	; else load IX with sprite data buffer start
011f  3aa44d    ld      a,(#4da4)	; load A with the unhandled killed ghost #
0122  87        add     a,a		; A := A * 2
0123  5f        ld      e,a		; copy to E
0124  1600      ld      d,#00		; D := #00
0126  dd19      add     ix,de		; add to index.  now has the eaten ghost sprite
0128  2a244c    ld      hl,(#4c24)	; load HL with start of ghost sprite address
012b  ed5b344c  ld      de,(#4c34)	; load DE with sprite number and color for spriteram
012f  dd7e00    ld      a,(ix+#00)	; load A with eaten ghost sprite
0132  32244c    ld      (#4c24),a	; store
0135  dd7e01    ld      a,(ix+#01)	; load A with next ghost sprite
0138  32254c    ld      (#4c25),a	; store
013b  dd7e10    ld      a,(ix+#10)	; load A with eaten ghost spriteram
013e  32344c    ld      (#4c34),a	; store
0141  dd7e11    ld      a,(ix+#11)	; load A with next ghost spriteram
0144  32354c    ld      (#4c35),a	; store
0147  dd7500    ld      (ix+#00),l	; 
014a  dd7401    ld      (ix+#01),h
014d  dd7310    ld      (ix+#10),e
0150  dd7211    ld      (ix+#11),d	; store L, H, E, and D

0153  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
0156  a7        and     a		; is a power pill active ?
0157  ca7601    jp      z,#0176		; no, skip ahead

; power pill active

015a  ed4b224c  ld      bc,(#4c22)	; else swap pac for first ghost.  load BC with red ghost sprite
015e  ed5b324c  ld      de,(#4c32)	; load DE with highest sprite for spriteram
0162  2a2a4c    ld      hl,(#4c2a)	; load HL with fruit sprite
0165  22224c    ld      (#4c22),hl	; store into highest priority sprite
0168  2a3a4c    ld      hl,(#4c3a)	; load HL with ms pac spriteram
016b  22324c    ld      (#4c32),hl	; store into highest priority spriteram
016e  ed432a4c  ld      (#4c2a),bc	; store first ghost sprite
0172  ed533a4c  ld      (#4c3a),de	; store first ghost spriteram

;

0176  21224c    ld      hl,#4c22	; load source address with start of sprites
0179  11f24f    ld      de,#4ff2	; load destiantion address with spriteram2
017c  010c00    ld      bc,#000c	; set counter at #0C bytes

; green eyed ghost bug encountered here
; 4FF2,3 - 
; 4FF2,3 - red ghost (8x,11)
; 4FF4,5 - pink ghost (8x,11)
; 4FF6,7 - blue ghost (8x,11)
; 4FF8,9 - orange ghost (8x,11)


017f  edb0      ldir    		; copy

0181  21324c    ld      hl,#4c32	; load source address with start of spriteram	
0184  116250    ld      de,#5062	; load destination address with hardware sprite
0187  010c00    ld      bc,#000c	; set counter at #0C bytes
018a  edb0      ldir			; copy [write updated sprites to spriteram]

	;
	; Core game loop
	;

018c  cddc01    call    #01dc		; update all timers
018f  cd2102    call    #0221		; check timed tasks and execute them if it is time to do so
0192  cdc803    call    #03c8		; runs subprograms based on game mode, power-on stuff, attract mode, push start screen, and core loops for game playing
0195  3a004e    ld      a,(#4e00)	; load A with game mode
0198  a7        and     a		; is the game still in power-on mode ?
0199  2812      jr      z,#01ad         ; yes, skip over next calls

019B  cd9d03    call    #039d		; check for double size pacman in intermission (pac-man only)
019E  cd9014    call    #1490		; when player 1 or 2 is played without cockatil mode, update all sprites
01a1  cd1f14    call    #141f		; when player 2 is played on cockatil mode, update all sprites
01a4  cd6702    call    #0267		; debounce rack input / add credits
01a7  cdad02    call    #02ad		; debounce coin input / add credits
01aa  cdfd02    call    #02fd		; blink coin lights
					; print player 1 and player two
					; check for game mode 3
					; draw cprt stuff

01ad  3a004e    ld      a,(#4e00)	; load A with game mode
01b0  3d        dec     a		; are we in the demo mode ?
01b1  2006      jr      nz,#01b9        ; no, skip next 2 steps		; set to jr #01b9 to enable sound in demo
01B3: 32 AC 4E	ld	(#4EAC),a	; yes, clear sound channel 2
01B6: 32 BC 4E	ld	(#4EBC),a	; clear sound channel 3

        ;; VBLANK - 2 (SOUND)
        ;;
        ;; Process sound

01b9    call    #2d0c                   ; process effects
01bc    call    #2cc1                   ; process waves

; restore registers.  they were saved at #0096

01bf  fde1      pop     iy		; restore IY
01c1  dde1      pop     ix		; restore IX
01c3  e1        pop     hl		; restore HL
01c4  d1        pop     de		; restore DE
01c5  c1        pop     bc		; restore BC

;

01c6  3a004e    ld      a,(#4e00)	; load A with game mode
01c9  a7        and     a		; is this the initialization?
01ca  2808      jr      z,#01d4         ; yes, skip ahead

01cc  3a4050    ld      a,(#5040)	; else load A with IN1
01cf  e610      and     #10		; is the service mode switch set ?

	; elimiate test mode ; HACK7
	;01d1  00        nop
	;01d2  00        nop
	;01d3  00        nop
	;

01d1  ca0000    jp      z,#0000		; yes, reset

01d4  3e01      ld      a,#01		; else A := #01
01d6  320050    ld      (#5000),a	; reenable hardware interrupts
01d9  fb        ei      		; enable cpu interrupts
01da  f1        pop     af		; restore AF [was saved at #008D]
01db  c9        ret     		; return

	; called from #018C
	; this sub increments the timers and random numbers from #4C84 to #4C8C

01dc  21844c    ld      hl,#4c84	; load HL with sound counter address
01df  34        inc     (hl)		; increment
01e0  23        inc     hl		; load HL with 2nd sound counter address
01e1  35        dec     (hl)		; decrement
01e2  23        inc     hl		; next address.  HL now has #4C86
01e3  111902    ld      de,#0219	; load DE with start of table data
01e6  010104    ld      bc,#0401	; C := #01,  For B = 1 to 4, 

01e9  34        inc     (hl)		; increase memory
01ea  7e        ld      a,(hl)		; load A with this value
01eb  e60f      and     #0f		; mask bits, now between #00 and #0F
01ed  eb        ex      de,hl		; DE <-> HL
01ee  be        cp      (hl)		; compare with value in table
01ef  2013      jr      nz,#0204        ; if not equal, break out of loop
01f1  0c        inc     c		; else C := C + 1
01f2  1a        ld      a,(de)		; load A with the value
01f3  c610      add     a,#10		; add #10
01f5  e6f0      and     #f0		; mask bits
01f7  12        ld      (de),a		; store result
01f8  23        inc     hl		; next table value
01f9  be        cp      (hl)		; compare with value in table
01fa  2008      jr      nz,#0204        ; if not equal, break out of loop
01fc  0c        inc     c		; else C := C + 1
01fd  eb        ex      de,hl		; DE <-> HL
01fe  3600      ld      (hl),#00	; clear the value in HL
0200  23        inc     hl		; next HL
0201  13        inc     de		; next table value
0202  10e5      djnz    #01e9           ; loop

; set up psuedo random number generator values, #4C8A, #4C8B, #4C8C

0204  218a4c    ld      hl,#4c8a	; load HL with timer address
0207  71        ld      (hl),c		; store C which was computed above
0208  2c        inc     l		; next address.  HL now has #4C8B
0209  7e        ld      a,(hl)		; load A with the value from this timer
020a  87        add     a,a		; A := A * 2
020b  87        add     a,a		; A := A * 2
020c  86        add     a,(hl)		; A := A + (HL) (A is now 5 times what it was)
020d  3c        inc     a		; increment.   (A is now 5 times plus 1 what it was)
020e  77        ld      (hl),a		; store new value
020f  2c        inc     l		; next address.  HL now has #4C8C
0210  7e        ld      a,(hl)		; load A with the value from this timer
0211  87        add     a,a		; A := A * 2
0212  86        add     a,(hl)		; A := A + (HL) (A is now 3 times what it was)  
0213  87        add     a,a		; A := A * 2
0214  87        add     a,a		; A := A * 2
0215  86        add     a,(hl)		; A := A + (HL) (A is now 13 times what it was)
0216  3c        inc     a		; increment.  (A is now 13 times plus 1 what it was)
0217  77        ld      (hl),a		; store result
0218  c9        ret			; return

; data used in subrotine above, loaded at #01E3

0219  06 A0 0A 60 0A 60 0A A0 

; checks timed tasks
; counts down timer and executes the task if the timer has expired
; called from #018F

0221: 21 90 4C	ld	hl,#4C90	; load HL with task list address
0224: 3A 8A 4C	ld	a,(#4C8A)	; load A with number of counter limits changes in this frame
0227: 4F	ld	c,a		; save to C for testing in line #0232
0228: 06 10	ld	b,#10		; for B = 1 to #10

022A: 7E	ld	a,(hl)		; load A with task list first value (timer)
022B: A7	and	a		; == #00 ?  (is this task empty?)
022C: 28 2F	jr	z,#025D		; Yes, jump ahead and loop for next task

022E: E6 C0	and	#C0		; else mask bits with binary 1100 0000 - the left 2 bits (6 and 7) are the time units
0230: 07	rlca		
0231: 07	rlca			; rotate twice left.  The time unit bits are now rightmost, in bits 0 and 1.  EG #02 for seconds
0232: B9	cp	c		; compare to counter.  is it time to count down the timer?
0233: 30 28	jr	nc,#025D	; if no, jump ahead and loop for next task

0235: 35	dec	(hl)		; else decrease the task timer
0236: 7E	ld	a,(hl)		; load A with new task timer
0237: E6 3F	and	#3F		; mask bits with binary 0011 1111. This will erase the units in the left 2 bits. is the timer counted all the way down?
0239: 20 22	jr	nz,#025D	; no, jump ahead and loop for next task

023B: 77	ld	(hl),a		; yes, store A into task timer.  this should be zero and effectively clears the task
023C: C5	push	bc		; save BC
023D: E5	push	hl		; save HL
023E: 2C	inc	l		; HL now has the coded task number address
023F: 7E	ld	a,(hl)		; load A with task number, used for jump table below
0240: 2C	inc	l		; HL now has the coded task parameter address
0241: 46	ld	b,(hl)		; load B with task parameter
0242: 21 5B 02	ld	hl,#025B	; load HL with return address
0245: E5	push	hl		; push to stack so a RET call will return to #025B
0246: E7	rst	#20		; jump based on A

0247: 94 08				; A==0, #0894  	; increases main subroutine number (#4E04) and returns 
0249: A3 06				; A==1, #06A3	; increments main routine 2, subroutine # (#4E03)
024B: 8E 05				; A==2, #058E 	; increases the main routine # (#4E02)
024D: 72 12				; A==3, #1272 	; increases killed ghost animation state when a ghost is eaten
024F: 00 10				; A==4, #1000 	; clears the fruit sprite
0251: 0B 10				; A==5, #100B 	; clears the fruit score sprite
0253: 63 02				; A==6, #0263 	; clears the "READY!" message
0255: 2B 21				; A==7, #212B 	; to increase state in 1st cutscene (#4E06) (pac-man only)
0257: F0 21				; A==8, #21F0 	; to increase state in 2nd cutscene (#4E07) (pac-man only)
0259: B9 22				; A==9, #22B9 	; to increase state in 3rd cutscene (#4E08) (pac-man only)

025B: E1            pop  hl		; restore HL
025C: C1            pop  bc		; restore BC

025D: 2C            inc  l
025E: 2C            inc  l
025F: 2C            inc  l		; next task
0260: 10 C8         djnz #022A		; next B
0262: C9            ret			; return    

	; timed task #06 - clears ready message

0263  EF        rst     #28		; insert task #1C, parameter 86 to clear the "READY!" message
0264  1C 86				; task data
0266  C9        ret     		; return

	;; debounce rack input / add credits (if 99 or over, return)
	; called from #01A4

0267  3a6e4e    ld      a,(#4e6e)	; load A with number of  current credits in BCD
026a  fe99      cp      #99		; == #99 ? (99 is max number of credits avail)
026c  17        rla     		; rotate left A
026d  320650    ld      (#5006),a	; store into #5006 (coin lockout, not used ?)
0270  1f        rra     		; rotate right A
0271  d0        ret     nc		; return if 99 credits

0272  3a0050    ld      a,(#5000)	; load A with IN0 input (joystick, credits, service mode button)
0275  47        ld      b,a		; copy to B
0276  cb00      rlc     b		; rotate left
0278  3a664e    ld      a,(#4e66)	; load A with service mode indicator
027b  17        rla     		; rotate left with carry
027c  e60f      and     #0f		; and it with #0F
027e  32664e    ld      (#4e66),a	; put it back
0281  d60c      sub     #0c		; subtract #0C.  is the service mode being used to add a credit?
0283  ccdf02    call    z,#02df		; If yes, call #02df  ; add credit
0286  cb00      rlc     b		; rotate left B
0288  3a674e    ld      a,(#4e67)	; load A with coin input #1
028b  17        rla     		; rotate left
028c  e60f      and     #0f		; mask bits
028e  32674e    ld      (#4e67),a	; put back
0291  d60c      sub     #0c		; subtract C.  is a coin being inserted?
0293  c29a02    jp      nz,#029a	; no, skip ahead
0296  21694e    ld      hl,#4e69	; yes, load HL with coin counter
0299  34        inc     (hl)		; increase counter
029a  cb00      rlc     b		; rotaate left B
029c  3a684e    ld      a,(#4e68)	; load A with coint input #2
029f  17        rla     		; rotate left
02a0  e60f      and     #0f		; maks bits
02a2  32684e    ld      (#4e68),a	; put back
02a5  d60c      sub     #0c		; subtract #0C.  is a coin being inserted?
02a7  c0        ret     nz		; no, return

02a8  21694e    ld      hl,#4e69	; else load HL with coin counter
02ab  34        inc     (hl)		; increase
02ac  c9        ret     		; return

	;; debounce coin input / add credits
	; called from #01A7

02ad  3a694e    ld      a,(#4e69)	; load A with coin counter
02b0  a7        and     a		; == #00 ?
02b1  c8        ret     z		; yes, return

02b2  47        ld      b,a		; else copy coin counter to B
02b3  3a6a4e    ld      a,(#4e6a)	; load A with coin counter timeout
02b6  5f        ld      e,a		; copy timeout to E
02b7  fe00      cp      #00		; is the timeout == #00?
02b9  c2c402    jp      nz,#02c4	; no, skip ahead

02bc  3e01      ld      a,#01		; else A := #01
02be  320750    ld      (#5007),a	; store into coin counter
02c1  cddf02    call    #02df		; call coins -> credits routine

02c4  7b        ld      a,e		; load A with timeout
02c5  fe08      cp      #08		; is the timeout == #08 ?
02c7  c2ce02    jp      nz,#02ce	; no, skip next 2 steps

02ca  af        xor     a		; A := #00
02cb  320750    ld      (#5007),a	; clear coin counter

02ce  1c        inc     e		; increment timeout
02cf  7b        ld      a,e		; copy to A
02d0  326a4e    ld      (#4e6a),a	; store into coin counter timeout
02d3  d610      sub     #10		; subtract #10.  did the timeout end?
02d5  c0        ret     nz		; no, return

02d6  326a4e    ld      (#4e6a),a	; else clear the counter timeout [A now has #00]
02d9  05        dec     b		; decrement B, this was a copy of the coin counter
02da  78        ld      a,b		; copy to A
02db  32694e    ld      (#4e69),a	; store into coin counter
02de  c9        ret     		; return

	;; coins -> credits routine

02df  3a6b4e    ld      a,(#4e6b)	; load A with #coins per #credits
02e2  216c4e    ld      hl,#4e6c	; load HL with # of leftover coins
02e5  34        inc     (hl)		; add 1
02e6  96        sub     (hl)		; subract this value from A
02e7  c0        ret     nz		; if not zero, then not enough coins for credits.  return

02e8  77        ld      (hl),a		; else store A into leftover coins
02e9  3a6d4e    ld      a,(#4e6d)	; load A with #credits per #coins
02ec  216e4e    ld      hl,#4e6e	; load HL with #credits
02ef  86        add     a,(hl)		; add # credits
02f0  27        daa     		; decimal adjust
02f1  d2f602    jp      nc,#02f6	; if no carry, skip ahead
02f4  3e99      ld      a,#99		; else load a with #99
02f6  77        ld      (hl),a		; store #credits, max #99
02f7  219c4e    ld      hl,#4e9c	; load HL with sound register
02fa  cbce      set     1,(hl)		; play credit sound
02fc  c9        ret     		; return

	;; blink coin lights, print player 1 and player 2, check for mode 3
	; called from #01AA

02fd  21ce4d    ld      hl,#4dce	; load HL with counter started after insert coin (LED and 1UP/2UP blink)
0300  34        inc     (hl)		; increment counter
0301  7e        ld      a,(hl)		; load A with counter
0302  e60f      and     #0f		; mask 4 left bits to zero
0304  201f      jr      nz,#0325        ; skip ahead if result is not zero

0306  7e        ld      a,(hl)		; load A with counter
0307  0f        rrca    
0308  0f        rrca    
0309  0f        rrca    
030a  0f        rrca 			; shift right 4 times
030b  47        ld      b,a		; copy A to B

	;; blink coin lights to pellets ; HACK9
	;;
	;; 030c  3aa74d	ld	a,(#4da7) 
	;; 030f  4f	ld	c,a
	;; 0310  180b	jr	#0317
	;;

030c  3ad64d    ld      a,(#4dd6)	; load A with LED state (1: game waits for 1P/2P start button press)	 
030f  2f        cpl     		; 1's complement of A
0310  b0        or      b		; or with B
0311  4f        ld      c,a		; load C with result
0312  3a6e4e    ld      a,(#4e6e)	; load A with number of credits
0315  d601      sub     #01		; subtract one from it.

0317  3002      jr      nc,#031b        ; if no carry then skip next 2 steps
0319  af        xor     a		; A := #00
031a  4f        ld      c,a		; c := #00

031b  2801      jr      z,#031e         ; If zero then skip next step

031d  79        ld      a,c		; else load A with C

031e  320550    ld      (#5005),a	; Store A into player 2 start lamp
0321  79        ld      a,c		; load A with C
0322  320450    ld      (#5004),a	; store A into player 1 start lamp

0325  dd21d843  ld      ix,#43d8	; load IX with start address where the screen shows "1UP"
0329  fd21c543  ld      iy,#43c5	; load IY with start address where the screen shows "1UP"
032d  3a004e    ld      a,(#4e00)	; load A with game mode
0330  fe03      cp      #03		; is a game being played ?
0332  ca4403    jp      z,#0344		; Yes, Jump ahead

0335  3a034e    ld      a,(#4e03)	; else load A with main routine 2, subroutine #
0338  fe02      cp      #02		; <= 2 ?
033a  d24403    jp      nc,#0344	; yes, skip ahead

033d  cd6903    call    #0369		; else draw "1UP"
0340  cd7603    call    #0376		; draw "2UP"
0343  c9        ret     		; return

	;; display and blink 1UP/2UP depending on player up

0344  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
0347  a7        and     a		; is this player 1 ?
0348  3ace4d    ld      a,(#4dce)	; load A with counter started after insert coin (LED and 1UP/2UP blink)
034b  c25903    jp      nz,#0359	; 

034e  cb67      bit     4,a		; test bit 4 of the counter.  is it on?
0350  cc6903    call    z,#0369		; no, draw  "1UP"
0353  c48303    call    nz,#0383	; yes, clear "1UP"
0356  c36103    jp      #0361		; skip ahead

0359  cb67      bit     4,a		; test bit 4 of the counter.  is it on?
035b  cc7603    call    z,#0376		; no, draw  "2UP"
035e  c49003    call    nz,#0390	; yes, clear "2UP"

0361  3a704e    ld      a,(#4e70)	; load A with player# (0=player1, 1=player2)
0364  a7        and     a		; is this player 1 ?
0365  cc9003    call    z,#0390		; yes, clear "2UP"
0368  c9        ret			; return     

	; draw "1UP"

0369  dd360050  ld      (ix+#00),#50	; 'P'
036d  dd360155  ld      (ix+#01),#55	; 'U'
0371  dd360231  ld      (ix+#02),#31	; '1'
0375  c9        ret     

	; draw "2UP"

0376  fd360050  ld      (iy+#00),#50	; 'P'
037a  fd360155  ld      (iy+#01),#55	; 'U'
037e  fd360232  ld      (iy+#02),#32	; '2'
0382  c9        ret     

	; clear "1UP"

0383  dd360040  ld      (ix+#00),#40	; ' '
0387  dd360140  ld      (ix+#01),#40	; ' '
038b  dd360240  ld      (ix+#02),#40	; ' '
038f  c9        ret     

	; clear "2UP"

0390  fd360040  ld      (iy+#00),#40	; ' '
0394  fd360140  ld      (iy+#01),#40	; ' '
0398  fd360240  ld      (iy+#02),#40	; ' '
039c  c9        ret     

	; draws big pacman in intermission. used for pac-man only, not ms.pac
	; called from #019b

039d  3a064e    ld      a,(#4e06)	; load A with 1st intermission counter
03a0  d605      sub     #05		; is big-pac onscreen ?
03a2  d8        ret     c		; no, return.  (always returns in ms. pacman)

	; draw big pac (pac-man only, during 1st cutscene)

03a3  2a084d    ld      hl,(#4d08)
03a6  0608      ld      b,#08
03a8  0e10      ld      c,#10
03aa  7d        ld      a,l
03ab  32064d    ld      (#4d06),a
03ae  32d24d    ld      (#4dd2),a
03b1  91        sub     c
03b2  32024d    ld      (#4d02),a
03b5  32044d    ld      (#4d04),a
03b8  7c        ld      a,h
03b9  80        add     a,b
03ba  32034d    ld      (#4d03),a
03bd  32074d    ld      (#4d07),a
03c0  91        sub     c
03c1  32054d    ld      (#4d05),a
03c4  32d34d    ld      (#4dd3),a
03c7  c9        ret     

	;; enable sound out and other stuff
	; called from #0192

03c8  3a004e    ld      a,(#4e00)	; load A with game mode
03cb  e7        rst     #20		; jump based on A

03cc  d4 03				;#03D4		;#4E00 = 0	;GAME POWER ON
03ce  fe 03				;#03FE		;#4E00 = 1      ;ALL ATTRACT MODES.  this runs until a credit is inserted
03d0  e5 05				;#05E5		;#4E00 = 2      ;PLAYER 1 OR 2 SCREEN.  draw screen and wait for start to be pressed
03d2  be 06				;#06BE		;#4E00 = 3      ;PLAYER 1 OR 2 PLAYING.  runs core game loop

; arrive here after power on

03d4  3a014e	ld	a,(#4e01)	; load A with main routine 0, subroutine #
03d5  e7        rst     #20		; jump based on A

03D8: DC 03				; #03DC
03DA: 0C 00				; #000C.  returns immediately (to #0195)

; arrive here after powering on
; this sets up the following tasks

03DC: EF        rst	#28		; insert task to clear the whole screen
03DD: 00 00				; data for above, task #00         
03DF: EF        rst	#28		; insert task to clear the color RAM
03E0: 06 00				; data for above, task #06
03e2  ef        rst     #28		; insert task color the maze
03e3  01 00				; data for above, task #01
03e5  ef        rst     #28		; insert task to check all dip switches and assign memories to the settings indicated
03e6  14 00				; data for above, task #14
03e8  ef        rst     #28		; insert task - draws "high score" and scores.  clears player 1 and 2 scores to zero.
03e9  18 00				; data for above, task #18
03eb  ef        rst     #28		; insert task - resets a bunch of memories
03ec  04 00				; data for above, task #04
03ee  ef        rst     #28		; insert task - clear fruit, pacman, and all ghosts
03ef  1e 00				; data for above, task #1E
03f1  ef        rst     #28		; insert task - set game to demo mode
03f2  07 00				; data for above, task #07

03F4: 21 01 4E	ld	hl,#4E01	; load HL with main routine 0, subroutine #
03F7: 34	inc	(hl)		; increase so this sub doesn't run again.
03f8  210150    ld      hl,#5001	; load HL with sound address
03fb  3601      ld      (hl),#01	; enable sound
03fd  c9        ret     		; return

	; attract mode main routine

03fe  cda12b    call    #2ba1		; write # of credits on screen
0401  3a6e4e    ld      a,(#4e6e)	; load A with # of credits
0404  a7        and     a		; == #00 ?
0405  280c      jr      z,#0413         ; yes, skip ahead

0407  af        xor     a		; else A := #00
0408  32044e    ld      (#4e04),a	; clear level state subroutine #
040b  32024e    ld      (#4e02),a	; clear main routine 1, subroutine #
040e  21004e    ld      hl,#4e00	; load HL with game mode
0411  34        inc     (hl)		; increase game mode to press start screen
0412  c9        ret     		; return (to #0195)

	; table lookup
; OTTOPATCH
;PATCH FOR NEW ATTRACT MODE
ORG 0413H
JP ATTRACT
0413  c35c3e    jp      #3e5c		; jump to mspac patch when there are no credits - controls the demo mode
					; code resumes at #045F

; Pac-man code:
; 0413  3a024e	ld	a,(#4e02)	; load A with main routine 1, subroutine #
; end Pac-man code

0416  e7	rst	#20		; jump based on A (pac-man only)

	; jump table based from value in #4E02
	; task routine to draw out the attract screen, only used in pac-man, not ms. pac

0417  5f 04				; #045F	;(#4e02)=#00    ; clear screen, reset memories, clear sprites          
0419  0c 00	 			; #000C	;(#4e02)=#01	; returns immediately
041b  71 04				; #0471 ;(#4e02)=#02	; draw red ghost
041d  0c 00				; #000C ;(#4e02)=#03	; returns immediately
041f  7f 04				; #047F ;(#4e02)=#04  	; draw "-SHADOW"
0421  0C 00				; #000C ;(#4e02)=#05	; returns immediately
0423  85 04				; #0485 ;(#4e02)=#06	; draw ""BLINKY""
0425  0c 00				; #000C ;(#4e02)=#07	; returns immediately
0427  8b 04				; #048B ;(#4e02)=#08	; draw pink ghost
0429  0c 00				; #000C ;(#4e02)=#09	; returns immediately
042b  99 04				; #0499 ;(#4e02)=#0A	; draw "-SPEEDY"
042d  0c 00				; #000C ;(#4e02)=#0B	; returns immediately
042f  9f 04				; #049F ;(#4e02)=#0C	; draw ""PINKY""
0431  0c 00				; #000C ;(#4e02)=#0D	; returns immediately
0433  a5 04				; #04A5 ;(#4e02)=#0E	; draw blue ghost (inky)
0435  0c 00				; #000C ;(#4e02)=#0F	; returns immediately
0437  b3 04				; #04B3 ;(#4E02)=#10	; draw "-BASHFUL"
0439: 0C 00				; #000C ;(#4E02)=#11	; returns immediately
043B: B9 04				; #04B9 ;(#4E02)=#12	; draw ""INKY""
043D: 0C 00				; #000C ;(#4E02)=#13	; returns immediately
043F: BF 04				; #04BF ;(#4E02)=#14	; draw orange ghost
0441: 0C 00				; #000C ;(#4E02)=#15	; returns immediately
0443: CD 04				; #04CD ;(#4E02)=#16	; draw "-POKEY"
4445: 0C 00				; #000C ;(#4E02)=#17	; returns immediately
0447: D3 04				; #04D3 ;(#4E02)=#18	; draw ""CLYDE""
0449: 0C 00				; #000C ;(#4E02)=#19	; returns immediately
044B: D8 04				; #04D8 ;(#4E02)=#1A	; draw ". 10 Pts" and "o 50pts"
044D: 0C 00				; #000C ;(#4E02)=#1B	; returns immediately
044F: E0 04				; #04E0 ;(#4E02)=#1C	; get demo ready and draw invisible maze
0451: 0C 00				; #000C ;(#4E02)=#1D	; returns immediately
0453: 1C 05				; #051C ;(#4E02)=#1E	; start and run demo
0455: 4B 05				; #054B ;(#4E02)=#1F	; check to release pink ghost
0457: 56 05				; #0556 ;(#4E02)=#20	; check to release inky
0459: 61 05				; #0561 ;(#4E02)=#21	; check to release orange ghost
045B: 6C 05				; #056C ;(#4E02)=#22	; check for completion of demo
045D: 7C 05				; #057C ;(#4E02)=#23	; end demo and return to program


	; ms. pac code resumes here
	; arrive here from #3E67 when subroutine # = 00
	; sets up the attract mode

045f  ef        rst     #28		; insert task #00 - clears the maze
0460  00 01
0462  ef        rst     #28		; insert task #01 - colors the screen
0464  01 00
0465  ef        rst     #28		; insert task #04 - resets a bunch of memories
0466  04 00
0468  ef        rst     #28		; insert task #1E - clear fruit, pacman and all ghosts
0469  1e 00
046b  0e0c      ld      c,#0c		; load C with text code for "Ms Pac Man"
046d  cd8505    call    #0585		; draw text to screen, increase subroutine #
0470  c9        ret     		; return (to #0195)

; pac-man only attract mode code from #0471 to #0579

0471  210443    ld      hl,#4304	; load HL with starting screen address of stationary red ghost
0474  3e01      ld      a,#01		; load A with the color code for red
0476  cdbf05    call    #05bf		; draw stationary red ghost on screen
0479  0e0c      ld      c,#0c		; load C with text code for "CHARACTER / NICKNAME"
047b  cd8505    call    #0585		; insert task to write text to screen
047e  c9        ret     		; return

047f  0e14      ld      c,#14		; load C with text code for "-SHADOW"
0481  cd9305    call    #0593		; draw text to screen
0484  c9        ret     		; return

0485  0e0d      ld      c,#0d		; load C with text code for ""BLINKY""
0487  cd9305    call    #0593		; draw text to screen
048a  c9        ret     		; return

048b  210743    ld      hl,#4307	; load HL with starting screen address of stationary pink ghost
048e  3e03      ld      a,#03		; load A with color code for pink
0490  cdbf05    call    #05bf		; draw stationary pink ghost on screen
0493  0e0c      ld      c,#0c		; load C with text code for "CHARACTER / NICKNAME"
0495  cd8505    call    #0585		; insert task to write text to screen
0498  c9        ret     		; return

0499  0e16      ld      c,#16		; load C with text code for "-SPEEDY"
049b  cd9305    call    #0593		; draw text to screen
049e  c9        ret     		; return

049f  0e0f      ld      c,#0f		; load C with text code for ""PINKY""
04a1  cd9305    call    #0593		; draw text to screen
04a4  c9        ret     		; return

04a5  210a43    ld      hl,#430a	; load HL with starting screen address of stationary blue ghost (inky)
04a8  3e05      ld      a,#05		; load A with color code for light blue
04aa  cdbf05    call    #05bf		; draw stationary inky on screen
04ad  0e0c      ld      c,#0c		; load C with text code for "CHARACTER / NICKNAME"
04af  cd8505    call    #0585		; insert task to write text to screen
04b2  c9        ret     		; return

04b3  0e33      ld      c,#33		; load C with text code for "-BASHFUL"
04b5  cd9305    call    #0593		; draw text to screen
04b8  c9        ret     		; return

04b9  0e2f      ld      c,#2f		; load C with text code for ""INKY""
04bb  cd9305    call    #0593		; draw text to screen
04be  c9        ret     		; return

04bf  210d43    ld      hl,#430d	; load HL with starting screen address of staionary orange ghost
04c2  3e07      ld      a,#07		; load A with color code for orange
04c4  cdbf05    call    #05bf		; draw stationary orange ghost on screen
04c7  0e0c      ld      c,#0c		; load C with text code for "CHARACTER / NICKNAME"
04c9  cd8505    call    #0585		; insert task to write text to screen
04cc  c9        ret     		; return

04cd  0e35      ld      c,#35		; load C with text code for "-POKEY"
04cf  cd9305    call    #0593		; draw text on screen
04d2  c9        ret     		; return

04d3  0e31      ld      c,#31		; load C with text code for ""CLYDE""
04d5  c38005    jp      #0580		; draw text and increase game mode

04d8  ef        rst     #28		; insert task to write text ". 10 Pts"
04d9  1c 11
04da  0e12      ld      c,#12
04dd  c38505    jp      #0585		; insert task to write text "o 50 Pts"

04e0  0e13      ld      c,#13		; load C with text code for "(C) MIDWAY MFG CO"
04e2  cd8505    call    #0585		; insert task to write text to screen
04e5  cd7908    call    #0879		; setup game start variables
04e8  35        dec     (hl)
04e9  ef        rst     #28		; set task #11 to clear memories #4d00 through #4dff
04ea  11 00
04ec  ef        rst     #28		; set task #05 to reset ghost home counter
04ed  05 01
04EF  ef	rst	#28		; set task #10 to set up difficulty
04F0  10 14
04f2  ef        rst     #28		; set task #04 to reset a bunch of memories and set up sprite locations for demo mode
04f3  04 01
04f4  3e01      ld      a,#01		; A := #01
04f7  32144e    ld      (#4e14),a	; store into number of lives left 
04fa  af        xor     a		; A := #00
04fb  32704e    ld      (#4e70),a	; store into number of players ( 0=1 1=2 )
04fe  32154e    ld      (#4e15),a	; store into number of lives displayed
0501  213243    ld      hl,#4332	; load HL with screen address where energizer is in attract mode
0504  3614      ld      (hl),#14	; draw energizer
0506  3efc      ld      a,#fc		; load A with code for invisible maze block
0508  112000    ld      de,#0020	; load DE with offset for columns
050b  061c      ld      b,#1c		; For B = 1 to #1C
050d  dd214040  ld      ix,#4040	; load IX with start address of video memory for playfield

0511  dd7711    ld      (ix+#11),a	; draw invisible maze block
0514  dd7713    ld      (ix+#13),a	; draw invisible maze block
0517  dd19      add     ix,de		; add offset for next column
0519  10f6      djnz    #0511           ; Next B
051b  c9        ret     		; return

	; called during attract mode, pac-man only, not ms. pac

051c  21a04d    ld      hl,#4da0	; load HL with red ghost substate address
051f  0621      ld      b,#21		; B := #21
0521  3a3a4d    ld      a,(#4d3a)	; load A with pacman X tile position

0524  90        sub     b		; has pacman/ghost reached the far right side of the screen?
0525  2005      jr      nz,#052c        ; no, skip ahead and do a core loop
0527  3601      ld      (hl),#01	; yes, change ghost substate to going for pac-man
0529  c38e05    jp      #058e		; jump ahead, increase game state and return

	; a core game loop used in pac-man demo mode only, not used in ms. pac

052c  cd1710    call    #1017		; another core game loop which does many things
052f  cd1710    call    #1017		; another core game loop which does many things
0532  cd230e    call    #0e23		; change animation of ghosts every 8th frame
0535  cd0d0c    call    #0c0d		; handle power pill flashes
0538  cdd60b    call    #0bd6		; set ghost colors
053b  cda505    call    #05a5		; check for direction reversal after eating power pill
053e  cdfe1e    call    #1efe		; check for red ghost direction reversal
0541  cd251f    call    #1f25		; check for pink ghost direction reversal
0544  cd4c1f    call    #1f4c		; check for blue ghost (inky) direction reversal
0547  cd731f    call    #1f73		; check for orange ghost direction reversal
054a  c9        ret     

054b  21a14d    ld      hl,#4da1	; load HL with pink ghost substate
054e  0620      ld      b,#20		; B := #20
0550  3a324d    ld      a,(#4d32)	; load A with red ghost X tile position 2
0553  c32405    jp      #0524		; check for reaching position to release next ghost

0556  21a24d    ld      hl,#4da2	; load HL with blue ghost (inky) substate
0559  0622      ld      b,#22		; B := #22
055b  3a324d    ld      a,(#4d32)	; load A with red ghost X tile position 2
055e  c32405    jp      #0524		; check for reaching position to release next ghost

0561  21a34d    ld      hl,#4da3	; load HL with orange ghost substate
0564  0624      ld      b,#24		; B := #24
0566  3a324d    ld      a,(#4d32)	; load A with red ghost X tile position 2
0569  c32405    jp      #0524		; check for reaching position to release next ghost

056c  3ad04d    ld      a,(#4dd0)	; load A with current number of killed ghosts
056f  47        ld      b,a		; copy to B
0570  3ad14d    ld      a,(#4dd1)	; load A with killed ghost animation state
0573  80        add     a,b		; add to number of killed ghosts
0574  fe06      cp      #06		; == #06?  (are we done ?)
0576  ca8e05    jp      z,#058e		; yes, skip ahead and increase subroutine number

0579  c32c05    jp      #052c		; no, loop back again to core loop

; arrive here in demo mode from #3ECD

057c  cdbe06    call    #06be		; jump to new subroutine based on game state
057f  c9        ret   			; returns to #0195  

; pac-man only ???
; arrive here from #04D5

0580  3a754e    ld      a,(#4e75)	; load A with ghost name mode (0 or 1)
0583  81        add     a,c
0584  4f        ld      c,a

; called from #046D and other places.  C is preloaded with the text code to display

0585  061c      ld      b,#1c		; load B with task code for text display
0587  cd4200    call    #0042		; insert task to display text, parameter = variable text
058a  f7        rst     #30		; insert timed task to increase the main routine # (#4E02)
058b  4a 02 00		    		; timer = #4A, task = 2, parameter = 0

; BUGFIX03 - Blue maze - Don Hodges
058b  41 02 00		    		; 41 is 1/10 second rather than 1 second


; called from # 0246 from jump table based on game state
; or, timed task number #02 has been encountered, arrive from #0246
; also arrive from #3E93 during marquee mode in demo

058e  21024e    ld      hl,#4E02	; load HL with main routine 1, subroutine #
0591  34        inc     (hl)		; increase
0592  c9        ret     		; return

; pac-man only - used in demo mode for introducing ghost names
; called from several places after C has been preloaded with ghost name code

0593  3a754e    ld      a,(#4e75)	; Load A with ghost name mode (0 or 1)
0596  81        add     a,c		; add to C
0597  4f        ld      c,a		; load result into C
0598  061c      ld      b,#1c		; load B with task code for text display
059a  cd4200    call    #0042		; set task to display ghost name
059d  f7        rst     #30		; set timed task to increase the main routine # (#4E02)
059e  45 02 00     			; data for rst #30 above.  timer=45, task=2, param=0
05a1  cd8e05    call    #058e		; increase main routine 1, subroutine # (#4E02)
05a4  c9        ret     		; return

; pac-man only, used during attract mode when pac-man moves toward energizer followed by the 4 ghosts

05a5  3ab54d    ld      a,(#4db5)	; load A with pacman change orientation flag
05a8  a7        and     a		; == #00 ?
05a9  c8        ret     z		; yes, return

; pac-man only, used during attract mode when pac-man reaches the energizer

05aa  af        xor     a		; no, A := #00
05ab  32b54d    ld      (#4db5),a	; store into pacman change orientation flag
05ae  3a304d    ld      a,(#4d30)	; load A with pacman orientation
05b1  ee02      xor     #02		; flip bit = change direction
05b3  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
05b6  47        ld      b,a		; store into B
05b7  21ff32    ld      hl,#32ff	; load HL with tile direction table
05ba  df        rst     #18		; load HL with tile direction based on direction
05bb  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
05be  c9        ret     		; return

; pac-man only, used during attract mode to draw the stationary ghosts during introductions
; HL is preloaded with starting screen address,
; A is preloaded with the ghost color code

05bf  36b1      ld      (hl),#b1	; draw first part of ghost
05c1  2c        inc     l
05c2  36b3      ld      (hl),#b3	; draw 2nd part of ghost
05c4  2c        inc     l
05c5  36b5      ld      (hl),#b5	; draw 3rd part of ghost
05c7  011e00    ld      bc,#001e	; load BC with offset for next column
05ca  09        add     hl,bc		; add offset
05cb  36b0      ld      (hl),#b0	; draw 4th part of ghost
05cd  2c        inc     l
05ce  36b2      ld      (hl),#b2	; draw 5th part of ghost
05d0  2c        inc     l
05d1  36b4      ld      (hl),#b4	; draw last part of ghost
05d3  110004    ld      de,#0400	
05d6  19        add     hl,de		; add offset for color
05d7  77        ld      (hl),a		; color last part of ghost
05d8  2d        dec     l
05d9  77        ld      (hl),a		; color 5th part of ghost
05da  2d        dec     l
05db  77        ld      (hl),a		; color 4th part of ghost
05dc  a7        and     a		; clear carry flag
05dd  ed42      sbc     hl,bc		; subtract offset for previous column
05df  77        ld      (hl),a		; color 3rd part of ghost
05e0  2d        dec     l
05e1  77        ld      (hl),a		; color 2nd part of ghost
05e2  2d        dec     l
05e3  77        ld      (hl),a		; color first part of ghost
05e4  c9        ret     		; return


; arrive from #03CB
; arrive here when credit has been inserted and game is waiting for start button to be pressed

05E5: 3A 03 4E	ld	a,(#4E03)	; load A with main routine 2, subroutine #
05E8: E7	rst	#20		; jump based on A

05E9: F3 05				; #05F3		; inserts tasks to draw info on screen
05EB: 1B 06				; #061B		; display 1/2 player and check start buttons
05ED: 74 06				; #0674		; run when start button pressed, gets game ready to be played
05EF: 0C 00				; #000C		; returns immediately
05F1: A8 06				; #06A8		; draw remaining lives at bottom of screen and start game

05F3: CD A1 2B	call	#2BA1		; write # of credits on screen

05F6: EF	rst	#28		; insert task to clear the maze
05F7: 00 01				; task #00, parameter #01
05F9: EF	rst	#28		; insert task to color the maze
05FB: 01 00				; task #01
05FC: EF	rst	#28		; insert task to display "PUSH START BUTTON"
05FD: 1C 07				; task #1c, parameter #07.  
05FF: EF	rst	#28		; insert task to display "ADDITIONAL    AT   000"
0600: 1C 0B				; task #1C, parameter #0B. 
0602: EF	rst	#28		; insert task to clear fruit, pacman, and all ghosts
0603: 1E 00				; task #1E

0605: 21 03 4E	ld	hl,#4E03	; load HL with main routine 2, subroutine #
0608: 34	inc	(hl)		; increase
0609: 3E 01	ld	a,#01		; A := #01
060B: 32 D6 4D	ld	(#4DD6),a	; store in LED state ( 1: game waits for 1P/2P start button press)
060E: 3A 71 4E	ld	a,(#4E71)	; load A with setting for bonus life
0611: FE FF	cp	#FF		; does this game award any bonus lives?
0613: C8	ret	z		; no, return

0614: EF	rst	#28		; else insert task to draw the MS PAC MAN graphic which appears between "ADDITIONAL" and "AT 10,000 pts"
0615: 1C 0A				; task data
0617: EF	rst	#28		; insert task to write points needed for extra life digits to screen
0618: 1F 00				; task data
061A: C9	ret			; return

	;; jump here from #05E8
	;; display 1/2 player and check start buttons

061b  cda12b    call    #2ba1		; write # of credits on screen
061e  3a6e4e    ld      a,(#4e6e)	; load A with # of credits
0621  fe01      cp      #01		; is it 1?
0623  0609      ld      b,#09		; load B with message #9:  "1 OR 2 PLAYERS"
0625  2002      jr      nz,#0629        ; if >= 2 credits, skip next step
0627  0608      ld      b,#08		; load B with message #8:  "1 PLAYER ONLY"
0629  cd5e2c    call    #2c5e		; print message
062c  3a6e4e    ld      a,(#4e6e)	; load A with # of credits
062f  fe01      cp      #01		; 1 credit?
0631  3a4050    ld      a,(#5040)	; load A with IN1 (player start buttons)
0634  280c      jr      z,#0642         ; don't check p2 with 1 credit
0636  cb77      bit     6,a		; check for player 2 start button
0638  2008      jr      nz,#0642        ; if not, pressed, skip ahead to check for player 1 start
063a  3e01      ld      a,#01		; else set 2 players
063c  32704e    ld      (#4e70),a	; store into # of players (0=1 player, 1=2 players)
063f  c34906    jp      #0649		; jump ahead
0642  cb6f      bit     5,a		; player 1 start being pressed ?
0644  c0        ret     nz		; no, return

0645  af        xor     a		; A := #00
0646  32704e    ld      (#4e70),a	; store into # of players (0=1 player, 1=2 players)
0649  3a6b4e    ld      a,(#4e6b)	; load A with number of coins per credit
064c  a7        and     a		; Is free play activated?
064d  2815      jr      z,#0664         ; Yes, skip ahead
064f  3a704e    ld      a,(#4e70)	; else load A with # of players
0652  a7        and     a		; Is this a 1 player game?
0653  3a6e4e    ld      a,(#4e6e)	; load A with number of credits
0656  2803      jr      z,#065b         ; If 1 player game, skip ahead and only subtract 1 credit
0658  c699      add     a,#99		; else subtract 2 credits.  one here...
065a  27        daa     		; decimal adjust

065b  c699      add     a,#99		; subtract a credit
065d  27        daa     		; decimal adjust
065e  326e4e    ld      (#4e6e),a	; save result in credits counter
0661  cda12b    call    #2ba1		; write # of credits on screen

0664  21034e    ld      hl,#4e03	; load HL with main routine 2, subroutine #
0667  34        inc     (hl)		; increase
0668  af        xor     a		; A := #00
0669  32d64d    ld      (#4dd6),a	; store in LED state ( 1: game waits for 1P/2P start button press)
066c  3c        inc     a		; A := #01
066d  32cc4e    ld      (#4ecc),a	; store in wave to play (begins intro music tune)
0670  32dc4e    ld      (#4edc),a	; store in wave to play (beigns intro music tune)
0673  c9        ret     		; return (to #0195)

	; arrive from #05E8 when start button has been pressed

0674  ef        rst     #28		; set task #00, parameter #01 - clears the maze
0675  00 01
0677  ef        rst     #28		; set task #01, parameter #01 - colors the maze
0678  01 01
067a  ef        rst     #28		; set task #02, parameter #00 - draws the maze
067b  02 00
067d  ef        rst     #28		; set task #12, parameter #00 - sets up coded pill and power pill memories
067e  12 00
0680  ef        rst     #28		; set task #03, parameter #00 - draws the pellets
0681  03 00
0683  ef        rst     #28		; set task #1C, parameter #03 - draws text on screen "PLAYER 1"
0684  1c 03
0686  ef        rst     #28		; set task #1C, parameter #06 - draws text on screen "READY!" and clears the intermission indicator
0687  1c 06
0689  ef        rst     #28		; set task #18, parameter #00 - draws "high score" and scores.  clears player 1 and 2 scores to zero.
068a  18 00
068c  ef        rst     #28		; set task #1B, parameter #00 - draws fruit at bottom right of screen
068d  1b 00

068f  af        xor     a		; A := #00
0690  32134e    ld      (#4e13),a	; current board level = 0
0693  3a6f4e    ld      a,(#4e6f)	; load number of lives to start
0696  32144e    ld      (#4e14),a	; set number of lives
0699  32154e    ld      (#4e15),a	; set number of lives displayed
069c  ef        rst     #28		; set task #1A, parameter #00 - draws remaining lives at bottom of screen
069d  1a 00
069f  f7        rst     #30		; set timed task to increment main routine 2, subroutine # (#4E03)
06a0  57 01 00				; task data: timer=#57, task=01, parameter=0.

; also arrive here from #0246.   This is timed task #01

06a3  21 03 4E	ld	hl,#4E03	; load HL with main routine 2, subroutine #
06a6  34        inc     (hl)		; increase
06a7  c9        ret     		; return

	;; draw lives displayed onto the screen

06a8  21154e    ld      hl,#4e15	; load HL with lives displayed on screen loc
06ab  35        dec     (hl)		; decrement
06ac  cd6a2b    call    #2b6a		; draw remaining lives at bottom of screen 
06af  af        xor     a		; A := #00
06b0  32034e    ld      (#4e03),a	; clear main routine 2, subroutine #
06b3  32024e    ld      (#4e02),a	; clear main routine 1, subroutine #
06b6  32044e    ld      (#4e04),a	; clear level state subroutine #
06b9  21004e    ld      hl,#4e00	; load HL with game mode address
06bc  34        inc     (hl)		; inc game mode.  game mode is now 3 = game is just now starting
06bd  c9        ret     		; return

; arrive here from #03CB or from #057C, when someone or demo is playing

06BE: 3A 04 4E      ld   a,(#4E04)	; load A with level state
06C1: E7            rst  #20		; jump based on A

06C2: 79 08				; #0879		; set up game initialization
06C4: 99 08 				; #0899		; set up tasks for beginning of game
06C6: 0C 00 				; #000C		; returns immediately
06C8: CD 08 				; #08CD		; demo mode or player is playing
06CA: 0D 09 				; #090D		; when player has collided with hostile ghost (died)
06CC: 0C 00 				; #000C		; returns immediately
06CE: 40 09				; #0940		; check for game over, do things if true
06D0: 0C 00 				; #000C		; returns immediately
06D2: 72 09 				; #0972		; end of demo mode when ms pac dies in demo.  clears a bunch of memories.
06D4: 88 09 				; #0988		; sets a bunch of tasks and displays "ready" or "game over"
06D6: 0C 00 				; #000C		; returns immediately
06D8: D2 09 				; #09D2		; begin start of maze demo after marquee
06DA: D8 09 				; #09D8		; clears sounds and sets a small delay.  run at end of each level
06DC: 0C 00 				; #000C		; returns immediately
06DE: E8 09				; #09E8		; flash screen
06E0: 0C 00 				; #000C		; returns immediately
06E2: FE 09				; #09FE		; flash screen
06E4: 0C 00 				; #000C		; returns immediately
06E6: 02 0A 				; #0A02		; flash screen
06E8: 0C 00 				; #000C		; returns immediately
06EA: 04 0A 				; #0A04		; flash screen
06EC: 0C 00				; #000C		; returns immediately
06EE: 06 0A				; #0A06		; flash screen
06F0: 0C 00 				; #000C		; returns immediately
06F2: 08 0A 				; #0A08		; flash screen
06F4: 0C 00 				; #000C		; returns immediately
06F6: 0A 0A 				; #0A0A		; flash screen
06F8: 0C 00 				; #000C		; returns immediately
06FA: 0C 0A 				; #0A0C		; flash screen
06FC: 0C 00 				; #000C		; returns immediately
06FE: 0E 0A				; #0A0E		; set a bunch of tasks
0700: 0C 00 				; #000C		; returns immediately
0702: 2C 0A 				; #0A2C		; clears all sounds and runs intermissions when needed
0704: 0C 00 				; #000C		; returns immediately
0706: 7C 0A 				; #0A7C		; clears sounds, increases level, increases difficulty if needed, resets pill maps
0708: A0 0A 				; #0AA0		; get game ready to play and set this sub back to #03
070A: 0C 00 				; #000C		; returns immediately
070C: A3 0A 				; #0AA3		; sets sub # back to #03

; arrive here from #000D
; sets up game difficulty

070e  78        ld      a,b		; load A with parameter from task
070f  a7        and     a		; == #00 ?
0710  2004      jr      nz,#0716        ; no, skip ahead
0712  2a0a4e    ld      hl,(#4e0a)	; else load HL with difficulty setting pointer.  EG #0068
0715  7e        ld      a,(hl)		; load A with difficulty, EG #00

0716  dd219607  ld      ix,#0796	; load IX with difficulty table start
071a  47        ld      b,a
071b  87        add     a,a
071c  87        add     a,a
071d  80        add     a,b
071e  80        add     a,b		; A is now 6 times what it was
071f  5f        ld      e,a
0720  1600      ld      d,#00
0722  dd19      add     ix,de		; adjust IX based on current difficulty
0724  dd7e00    ld      a,(ix+#00)	; load A with first value from table
0727  87        add     a,a
0728  47        ld      b,a
0729  87        add     a,a
072a  87        add     a,a
072b  4f        ld      c,a
072c  87        add     a,a
072d  87        add     a,a
072e  81        add     a,c
072f  80        add     a,b
0730  5f        ld      e,a
0731  1600      ld      d,#00
0733  210f33    ld      hl,#330f	; load HL with start of data table - speeds of ghosts and pacman
0736  19        add     hl,de		; add offset computed above
0737  cd1408    call    #0814		; copy data into #4d46 through #4d94
073a  dd7e01    ld      a,(ix+#01)	; load A with second value from table
073d  32b04d    ld      (#4db0),a	; store.  appears to be unused
0740  dd7e02    ld      a,(ix+#02)	; load A with third value from table
0743  47        ld      b,a		; copy to B
0744  87        add     a,a		; A := A*2
0745  80        add     a,b		; A is now 3 times value in table
0746  5f        ld      e,a		; store in E
0747  1600      ld      d,#00		; D := #00
0749  214308    ld      hl,#0843	; load HL with hard/easy data table check 
074c  19        add     hl,de		; add offset computed above
074d  cd3a08    call    #083a		; copy difficulty info to #4DB8 to #4DBA
0750  dd7e03    ld      a,(ix+#03)	; load A with fourth value from table
0753  87        add     a,a		; A := A * 2
0754  5f        ld      e,a		; copy to E
0755  1600      ld      d,#00		; D := #00
0757  fd214f08  ld      iy,#084f	; load IY with data table start
075b  fd19      add     iy,de		; add offset
075d  fd6e00    ld      l,(iy+#00)	; 
0760  fd6601    ld      h,(iy+#01)	; load HL with table data
0763  22bb4d    ld      (#4dbb),hl	; store into remainder of pills when first diff. flag is set
0766  dd7e04    ld      a,(ix+#04)	; load A with fifth value from table
0769  87        add     a,a		; A := A * 2
076a  5f        ld      e,a		; store into E
076b  1600      ld      d,#00		; clear D
076d  fd216108  ld      iy,#0861	; load IY with start of table that controls time that ghosts stay blue
0771  fd19      add     iy,de		; add offset
0773  fd6e00    ld      l,(iy+#00)	; 
0776  fd6601    ld      h,(iy+#01)	; load HL with data from table
0779  22bd4d    ld      (#4dbd),hl	; store into time the ghosts stay blue when pacman eats a power pill
077c  dd7e05    ld      a,(ix+#05)	; load A with sixth value from table
077f  87        add     a,a		; A := A * 2
0780  5f        ld      e,a		; copy to E
0781  1600      ld      d,#00		; clear D
0783  fd217308  ld      iy,#0873	; load IY with start of difficulty table - number of units before ghosts leaves home
0787  fd19      add     iy,de		; add offset
0789  fd6e00    ld      l,(iy+#00)
078c  fd6601    ld      h,(iy+#01)	; load HL with data from table
078f  22954d    ld      (#4d95),hl	; store
0792  cdea2b    call    #2bea		; draw fruit at bottom of screen
0795  c9        ret			; return (to # 238D ?) 

;	-- difficulty related table
;	each entry is 6 bytes
;	byte 0: (0..6) speed bit patterns and orientation changes (table at #330F)
;	byte 1: (00, 01, 02) stored at #4DB0 - seems to be unused
;	byte 2: (0..3) ghost counter table to exit home (table at #0843)
;	byte 3: (0..7) remaining number of pills to set difficulty flags (table at #084F)
;	byte 4: (0..8) ghost time to stay blue when pacman eats the big pill (table at #0861)
;	byte 5: (0..2) number of units before a ghost goes out of home (table at #0873)

	
0796  03 01 01 00 02 00
079c  04 01 02 01 03 00
07a2  04 01 03 02 04 01
07a8  04 02 03 02 05 01
07ae  05 00 03 02 06 02
07b4  05 01 03 03 03 02
07ba  05 02 03 03 06 02
07c0  05 02 03 03 06 02
07c6  05 00 03 04 07 02
07cc  05 01 03 04 03 02
07d2  05 02 03 04 06 02
07d8  05 02 03 05 07 02
07de  05 00 03 05 07 02
07e4  05 02 03 05 05 02
07ea  05 01 03 06 07 02
07f0  05 02 03 06 07 02
07f6  05 02 03 06 08 02
07fc  05 02 03 06 07 02
0802  05 02 03 07 08 02
0808  05 02 03 07 08 02
080e  06 02 03 07 08 02


; called from #0737
; copies difficulty-related data into #4d46 through #4d94
; includes 4d58 which is blinky's normal speed
; include 4d86 which controls timing of reversals


0814  11464d    ld      de,#4d46	; set destination
0817  011c00    ld      bc,#001c	; set counter
081a  edb0      ldir    		; copy
081c  010c00    ld      bc,#000c	; set counter
081f  a7        and     a		; clear carry flag
0820  ed42      sbc     hl,bc		; subtract from source
0822  edb0      ldir    		; copy
0824  010c00    ld      bc,#000c	; set counter
0827  a7        and     a		; clear carry flag
0828  ed42      sbc     hl,bc		; subtract from source
082a  edb0      ldir    		; copy
082c  010c00    ld      bc,#000c	; set counter
082f  a7        and     a		; clear carry flag
0830  ed42      sbc     hl,bc		; subtract source
0832  edb0      ldir    		; copy
0834  010e00    ld      bc,#000e	; set counter
0837  edb0      ldir    		; copy
0839  c9        ret     		; return

; called from #0749

083a  11b84d    ld      de,#4db8	; load destination with #4DB8
083d  010300    ld      bc,#0003	; set bytes to copy at 3
0840  edb0      ldir    		; copy
0842  c9        ret     		; return

;-- table related to difficulty - each entry is 3 bytes
; b0: when counter at 4E0F reaches this value, pink ghost goes out of home
; b1: when counter at 4E10 reaches this value, blue ghost goes out of home
; b2: when counter at 4E11 reaches this value, orange ghost goes out of home

    ; these don't seem to be used in ms-pac at all.

0843  14 1e 46   00 1e 3c   00 00 32   00 00 00

	; hard hack: HACK6
	; 0843  0f 14 37 04  18 34  02 06 28   00 04 08
	;

; -- difficulty table --
; each entry is 2 bytes
; b1: remaining number of pills when first difficulty flag is set (cruise elroy 1)
; b2: remaining number of pills when second difficulty flag is set (cruise elroy 2)


084f  14 0a
0851  1e 0f
0853  28 14
0855  32 19
0857  3c 1e
0859  50 28
085B  64 32
085D  78 3c
085F  8c 46


; difficulty table - Time the ghosts stay blue when pacman eats a big pill
;		-- do not use with l set up at #076D 

0861  c0 03				; 03c0 (960) 8 seconds (not used)
0863  48 03				; 0348 (840) 7 seconds (not used)
0865  d0 02				; 02d0 (720) 6 seconds
0867  58 02				; 0258 (600) 5 seconds
0869  e0 01				; 01e0 (480) 4 seconds
086b  68 01				; 0168 (360) 3 seconds
086d  f0 00				; 00f0 (240) 2 seconds
086f  78 00				; 0078 (120) 1 second
0871  01 00				; 0001 (1)   0 seconds

; difficulty table - number of units before ghosts leaves home
; set up at #0783

0873  f0 00				; 00f0 (240) 2 seconds
0875  f0 00				; 00f0 (240) 2 seconds
0877  b4 00				; 00b4 (180) 1.5 seconds

; main routine #3.  arrive here at the start of the game when a new game is started
; arrive from #04E5 or #06C1

0879  21094e    ld      hl,#4e09	; load HL with player # address
087c  af        xor     a		; A := #00
087d  060b      ld      b,#0b		; set counter to #0B
087f  cf        rst     #8		; clear memories from #4E09 through #4E09 + #0B
0880  cdc924    call    #24c9		; set up pills and power pills in RAM
0883  2a734e    ld      hl,(#4e73)	; load HL with difficulty
0886  220a4e    ld      (#4e0a),hl	; store difficulty
0889  210a4e    ld      hl,#4e0a	; load source with difficulty
088c  11384e    ld      de,#4e38	; load destination with difficulty
088f  012e00    ld      bc,#002e	; set byte counter at #2E
0892  edb0      ldir    		; copy

; arrive here from #09CF
; this is also timed task #00, arrive from #0246

0894  21044e    ld      hl,#4e04	; load HL with main subroutine number
0897  34        inc     (hl)		; increment
0898  c9        ret     		; return

; arrive from #06C1

0899  3a004e    ld      a,(#4e00)	; load A with game mode
089c  3d        dec     a		; are we in the demo mode ?
089d  2006      jr      nz,#08a5        ; no, skip ahead

089f  3e09      ld      a,#09		; yes, load A with #09
08a1  32044e    ld      (#4e04),a	; store in main subroutine
08a4  c9        ret    			; return 

08a5  ef        rst     #28		; insert task #11 - clears memories from #4D00 through #4DFF
08a6  11 00
08a8  ef        rst     #28		; insert task #1C, parameter #83 - displays or clears text
08a9  1c 83
08ab  ef        rst     #28		; insert task #04 - resets a bunch of memories and
08ac  04 00
08ae  ef        rst     #28		; insert task #05 - resets ghost home counter
08af  05 00
08b1  ef        rst     #28		; insert task #10 - sets up difficulty
08b2  10 00
08b4  ef        rst     #28		; insert task #1A - draws remaining lives at bottom of screen
08b5  1a 00
08b7  f7        rst     #30		; set timed task to increase the main subroutine number (#4E04)
08b8  54 00 00				; task timer=#54, task=0, param=0    
08bb  f7        rst     #30		; set timed task to clear the "READY!" message
08bc  54 06 00				; task timer=#54, task=6, param=0
08bf  3a724e    ld      a,(#4e72)	; load A with cocktail or upright
08c2  47        ld      b,a		; copy to B
08c3  3a094e    ld      a,(#4e09)	; load A with current player #
08c6  a0        and     b		; is this game cockatil mode and player # 2 ? If so , this value becomes 1
08c7  320350    ld      (#5003),a	; store into flip screen register
08ca  c39408    jp      #0894		; loop back to increment level complete register and return

; demo or game is playing

08cd  3a0050    ld      a,(#5000)	; load A with IN0
08d0  cb67      bit     4,a		; is rack test on?
08d2  c2de08    jp      nz,#08de	; no, skip ahead

08d5  21044e    ld      hl,#4e04	; else rack switch on, so advance.  load HL with game state
08d8  360e      ld      (hl),#0e	; store value of #0E.  this signals end of level
08da  ef        rst     #28		; insert task #13 with parameter #00 - clears the sprites
08db  13 00
08dd  c9        ret   			; return  

	;; routine to determine the number of pellets which must be eaten

08de  3a0e4e    ld      a,(#4e0e)	; load A with number of pellets eaten

; OTTOPATCH
;PATCH TO ADJUST THE TOTAL DOT NUMBER
ORG 08E1H
JP MOREDOTS
NOP
08e1  c3a194    jp      #94a1		; jump to ms pac man new check for end of level routine
08e4  00        nop 			; junk
    
	; returns here if the level is complete

08e5  21044e    ld      hl,#4e04	; load HL with game state
08e8  360c      ld      (hl),#0c	; store value of #0C, signals end of level
08ea  c9        ret     		; return

;; pacman original:
; 08de  3a0e4e	ld	a,(#4e0e)	; load A with number of pellets eaten
; 08e1  fef4	cp	#f4		; == 244 ?
; 08e3  2006	jr	nz,#08eb	; No, jump ahead
; 08e5  21044e	ld	hl,#4e04	; Yes, then end of level.  Load HL with main subroutine #
; 08e8  360c	ld	(hl),#0c	; store #0C into main sub #to signal end of level
; 08ea  c9	ret			; return
;;

	; returns here if level is not complete
	; core game loop

08eb  cd1710    call    #1017		; another core game loop that does many things
08ee  cd1710    call    #1017		; another core game loop that does many things
08f1  cddd13    call    #13dd		; check for release of ghosts from ghost house
08f4  cd420c    call    #0c42		; adjust movement of ghosts if moving out of ghost house
08f7  cd230e    call    #0e23		; change animation of ghosts every 8th frame
08fa  cd360e    call    #0e36		; periodically reverse ghost direction based on difficulty (only when energizer not active)
08fd  cdc30a    call    #0ac3		; handle ghost flashing and colors when power pills are eaten
0900  cdd60b    call    #0bd6		; color dead ghosts the correct colors
0903  cd0d0c    call    #0c0d		; handle power pill (dot) flashes
0906  cd6c0e    call    #0e6c		; change the background sound based on # of pills eaten
0909: CD AD 0E	call	#0EAD		; check for fruit to come out.  (new ms. pac sub actually at #86EE.)
090C: C9	ret			; return ( to #0195 )


; arrive here from #06C1 when player has died

090d  3e01      ld      a,#01		; A := #01
090f  32124e    ld      (#4e12),a	; store into player dead flag

;	4e12	1 after dying in a level, reset to 0 if ghosts have left home
;		because of 4d9f

0912  cd8724    call    #2487		; save pellet info to memory
0915  21044e    ld      hl,#4e04	; load HL with main subroutine number
0918  34        inc     (hl)		; increase it
0919  3a144e    ld      a,(#4e14)	; load A with number of lives left
091c  a7        and     a		; == #00 ?
091d  201f      jr      nz,#093e        ; no, skip ahead

091f  3a704e    ld      a,(#4e70)	; else game over.  load A with number of players (0=1 player, 1=2 players)
0922  a7        and     a		; is this a one player game?
0923  2819      jr      z,#093e         ; yes, skip ahead
0925  3a424e    ld      a,(#4e42)	; else load A with game state
0928  a7        and     a		; is this the demo mode ?
0929  2813      jr      z,#093e         ; yes, skip ahead
092b  3a094e    ld      a,(#4e09)	; else load A with current player number:  0=P1, 1=P2
092e  c603      add     a,#03		; add #03, result is either #03 or #04
0930  4f        ld      c,a		; store into C for call below
0931  061c      ld      b,#1c		; load B with #1C for task call below
0933  cd4200    call    #0042		; insert task to draw to screen either "PLAYER ONE" or "PLAYER TWO"
0936  ef        rst     #28		; insert task to draw "GAME OVER"
0937  1c 05
0939  f7        rst     #30		; set timed task to increase the main subroutine number (#4E04)
093a  54 00 00				; task timer=#54, task=0, param=0    
093d  c9        ret     		; return

093e  34        inc     (hl)		; increase game state
093f  c9        ret     		; return

; arrive from #06C1

0940  3a704e    ld      a,(#4e70)	; load A with number of players
0943  a7        and     a		; == #00 ?
0944  2806      jr      z,#094c         ; yes, skip ahead if 1 player
0946  3a424e    ld      a,(#4e42)	; else load A with game state 
0949  a7        and     a		; is a game being played ?
094a  2015      jr      nz,#0961        ; yes, skip ahead and switch from player 1 to player 2 or vice versa
094c  3a144e    ld      a,(#4e14)	; else load A with number of lives left
094f  a7        and     a		; are there any lives left ?
0950  201a      jr      nz,#096c        ; yes, jump ahead

	; change 0950 to 
	; 0950  18 1a		jr	#096C 	; always jump ahead 
	; for never-ending pac goodness


0952  cda12b    call    #2ba1		; else draw # credits or free play on bottom of screen
0955  ef        rst     #28		; insert task #1C , parameter #05 .  Draws text on screen "GAME OVER"
0956  1c 05				; task data
0958  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
0959  54 00 00    			; task timer=#54, task=0, param=0
095c  21044e    ld      hl,#4e04	; Load HL with level state subroutine #
095f  34        inc     (hl)		; increment
0960  c9        ret     		; return

; arrive here from #094a when there 2 players, when a player dies

0961  cda60a    call    #0aa6		; transposes data from #4e0a through #4e37 into #4e38 through #4e66
0964  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
0967  ee01      xor     #01		; flip bit 0
0969  32094e    ld      (#4e09),a	; store result.  toggles between player 1 and 2

096c  3e09      ld      a,#09		; A := #09
096e  32044e    ld      (#4e04),a	; store into level state subroutine #
0971  c9        ret     		; return


	; arrive from #06C1 when subroutine# (#4E04)= #08
	; zeros some important variables
	; arrive here after demo mode finishes (ms pac man dies in demo)

0972  af        xor     a		; A := #00
0973  32024e    ld      (#4e02),a	; clear main routine 1, subroutine #
0976  32044e    ld      (#4e04),a	; clear level state subroutine #
0979  32704e    ld      (#4e70),a	; clear number of players
097c  32094e    ld      (#4e09),a	; clear current player number
097f  320350    ld      (#5003),a	; clear flip screen register
0982  3e01      ld      a,#01		; A := #01
0984  32004e    ld      (#4e00),a	; set game mode to demo
0987  c9        ret     		; return (to #057F)


; arrive from #06C1 when (#4E04==#09)  when marquee mode ends or after player has been killed
; or from #06C1 when (#4E04 == #20) when a level has ended and a new one is about to begin


0988  ef        rst     #28		; set task #00, parameter = #01. - clears the maze
0989  00 01
098b  ef        rst     #28		; set task #01, parameter = #01. - colors the maze
098c  01 01
098e  ef        rst     #28		; set task #02, parameter = #00. - draws the maze
098f  02 00
0991  ef        rst     #28		; set task #11, parameter = #00. - clears memories from #4D00 through #4DFF
0992  11 00
0994  ef        rst     #28		; set task #13, parameter = #00. - clears the sprites
0995  13 00
0997  ef        rst     #28		; set task #03, parameter = #00. - draws the pellets
0998  03 00
099a  ef        rst     #28		; set task #04, parameter = #00. - resets a bunch of memories
099b  04 00
099d  ef        rst     #28		; set task #05, parameter = #00. - resets ghost home counter
099e  05 00
09a0  ef        rst     #28		; set task #10, parameter = #00. - sets up difficulty
09a1  10 00
09a3  ef        rst     #28		; set task #1A, parameter = #00. - draws remaining lives at bottom of screen
09a4  1a 00
09a6  ef        rst     #28		; set task #1C, parameter = #06. Draws text on screen "READY!" and clears the intermission indicator
09a7  1c 06
09a8  3a004e    ld      a,(#4e00)	; load A with game state
09ac  fe03      cp      #03		; is someone playing ?
09ae  2806      jr      z,#09b6         ; Yes, skip ahead

09b0  ef        rst     #28		; set task #1C, parameter = #05.  Draws text on screeen "GAME OVER"
09b1  1c 05
09b3  ef        rst     #28		; set task #1D - write # of credits on screen
09b4  1d 00

09b6  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
09b7  54 00 00				; taks timer = #54, task = 00, parameter = 00    
09ba  3a004e    ld      a,(#4e00)	; load A with game sate
09bd  3d        dec     a		; is this the demo mode ?
09be  2804      jr      z,#09c4         ; yes, skip next step

09c0  f7        rst     #30		; set timed task to clear the "READY!" text from the screen
09c1  54 06 00				; timer = #54, task = 6, parameter = 00

09c4  3a724e    ld      a,(#4e72)	; load A with cocktail mode (0=no, 1=yes)
09c7  47        ld      b,a		; copy to B
09c8  3a094e    ld      a,(#4e09)	; load A with current player #
09cb  a0        and     b		; mix together
09cc  320350    ld      (#5003),a	; flip screens if player 2 in cocktail mode, else screen is set upright
09cf  c39408    jp      #0894		; increase main routine # and return from sub

; called after marquee mode is done during demo
; called from #06C1 when (#4E04 == #0B)

09d2  3e03      ld      a,#03		; A := #03
09d4  32044e    ld      (#4e04),a	; store into main routine #.  signals the maze part of game is on
09d7  c9        ret     		; return

; called from #06C1 when (#4E04 == #0C)
; arrive here at end of level

09d8  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
09d9  54 00 00    			; timer = #54, task = #00, parameter = #00
09DC: 21 04 4E	ld	hl,#4E04	; load HL with game subroutine #
09DF: 34	inc	(hl)		; increase 
09E0: AF	xor	a		; A := #00
09E1: 32 AC 4E	ld	(#4EAC),a	; clear sound channel 2
09E4: 32 BC 4E	ld	(#4EBC),a	; clear sound channel 3
09E7: C9	ret			; return   

; Called from #06C1 when (#4E04 == #0E)

09e8  0e02      ld      c,#02		; C := #02

09ea  0601      ld      b,#01		; B := #01
09ec  cd4200    call    #0042		; set task #01 with parameter #02, or task #01 with parameter #00
09ef  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
09f0  42 00 00				; timer = #42, task = #00, parameter = #00
09f3  210000    ld      hl,#0000	; clear HL
09f6  cd7e26    call    #267e		; clears all ghosts from screen
09f9  21044e    ld      hl,#4e04	; load HL with game subroutine #
09fc  34        inc     (hl)		; increase
09fd  c9        ret     		; return

; the following calls are made at end of level to flash the screen

09fe  0e00      ld      c,#00		; set code to flash screen
0a00  18e8      jr      #09ea           ; flash screen

0a02  18e4      jr      #09e8           ; flash screen

0a04  18f8      jr      #09fe           ; flash screen

0a06  18e0      jr      #09e8           ; flash screen

0a08  18f4      jr      #09fe           ; flash screen

0a0a  18dc      jr      #09e8           ; flash screen

0a0c  18f0      jr      #09fe           ; flash screen

; arrive here at end of level after screen has flashed several times
; called from #06C1 when (#4E04 == #14)

0a0e  ef        rst     #28		; insert task #00, parameter #01 - clears the maze
0a0f  00 01
0a11  ef        rst     #28		; insert task #06, parameter #00 - clears the color RAM
0a12  06 00
0a14  ef        rst     #28		; insert task #11, parameter #00 - clears memories from #4D00 through #4DFF
0a15  11 00
0a17  ef        rst     #28		; insert task #13, parameter #00 - clears the sprites
0a18  13 00
0a1a  ef        rst     #28		; insert task #04, parameter #01 - resets a bunch of memories
0a1b  04 01
0a1d  ef        rst     #28		; insert task #05, parameter #01 - resets ghost home counter
0a1e  05 01
0a20  ef        rst     #28		; insert task #10, parameter #13 - sets up difficulty
0a21  10 13
0a23  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
0a24  43 00 00     			; task timer = #43, task #00, parameter #00
0a27  21044e    ld      hl,#4e04	; load HL with main subroutine number
0a2a  34        inc     (hl)		; increase subroutine number
0a2b  c9        ret     		; return

; arrive here at end of level
; called from #06C1 when (#4E04 == #16)
; clear sounds and run intermissions when needed

0A2C: AF            xor  a		; A := #00
0A2D: 32 AC 4E      ld   (#4EAC),a	; clear sound channel #2
0A30: 32 BC 4E      ld   (#4EBC),a	; clear sound channel #3
0A33: 18 06         jr   #0A3B		; skip next 2 steps

; junk from pac-man

0A35: 32CC4E	ld	(#4ECC),a	
0A38: 32DC4E	ld	(#4EDC),a

0a3b  3a134e    ld      a,(#4e13)	; load A with current board level
0a3e  fe14      cp      #14		; > #14 ?
0a40  3802      jr      c,#0a44         ; no, skip next step
0a42  3e14      ld      a,#14		; else load A with #14
0a44  e7        rst     #20		; jump based on A

	; jump table to control when cutscenes occur

0a45  6f 0a				; #0A6F ; increment level state and stop sound
0a47  08 21				; #2108 ; cut scene 1
0a49  6f 0a				; #0A6F ; increment level state and stop sound
0a4b  6f 0a				; #0A6F ; increment level state and stop sound
0a4d  9e 21				; #219E ; cut scene 2
0a4f  6f 0a				; #0A6F ; increment level state and stop sound
0a51  6f 0a				; #0A6F ; increment level state and stop sound
0a53  6f 0a				; #0A6F ; increment level state and stop sound
0a55  97 22				; #2297 ; cut scene 3
0a57  6f 0a				; #0A6F ; increment level state and stop sound
0a59  6f 0a				; #0A6F ; increment level state and stop sound
0a5b  6f 0a				; #0A6F ; increment level state and stop sound
0a5d  97 22				; #2297 ; cut scene 3
0a5f  6f 0a				; #0A6F ; increment level state and stop sound
0a61  6f 0a				; #0A6F ; increment level state and stop sound
0a63  6f 0a				; #0A6F ; increment level state and stop sound
0a65  97 22				; #2297 ; cut scene 3
0a67  6f 0a				; #0A6F ; increment level state and stop sound
0a69  6f 0a				; #0A6F ; increment level state and stop sound
0a6b  6f 0a				; #0A6F ; increment level state and stop sound
0a6d  6f 0a				; #0A6F ; increment level state and stop sound

	; increment level state and stop sound

0a6f  21044e    ld      hl,#4e04	; load HL with level state subroutine #
0a72  34        inc     (hl)
0a73  34        inc     (hl)		; increase twice
0a74  af        xor     a		; A := #00
0a75  32cc4e    ld      (#4ecc),a	; clear sound
0a78  32dc4e    ld      (#4edc),a	; clear sound
0a7b  c9        ret     		; return

	;; we're about to start the next board, (it's about to be drawn)
	; called from #06C1 when (#4E04 == #18)

0a7c  af        xor     a		; A := #00
0a7d  32cc4e    ld      (#4ecc),a	; clear sound
0a80  32dc4e    ld      (#4edc),a	; clear sound
0a83  0607      ld      b,#07		; B := #07
0a85  210c4e    ld      hl,#4e0c	; load HL with start address to clear
0a88  cf        rst     #8		; clear #4e0c through #4e0c+7.  these flags are reset at beginning of each level
0a89  cdc924    call    #24c9		; set addresses #4E16 through #4E39 with #FF and #14 (pill map???)
0a8c  21044e    ld      hl,#4e04	; load HL with subroutine #
0a8f  34        inc     (hl)		; increase


	; level 255 pac fix ; BUGFIX01 (1 of 2)
	; 0a90  c3800f	jp	#0f88      
	; 0a93  00	nop
	;


	; level 141 mspac fix ; BUGFIX02 (1 of 2)
	; 0a90  c3960f	jp	#0f96
	; 0a93  00	nop
 	;


0a90  21134e    ld      hl,#4e13	; load HL with current board level
0a93  34        inc     (hl)		; increment board level
0a94  2a0a4e    ld      hl,(#4e0a)	; load HL with pointer to current difficulty settings (#0068 for easy, #007D for hard)
0a97  7e        ld      a,(hl)		; load A with the result
0a98  fe14      cp      #14		; == #14 (is this already the highest difficulty?)
0a9a  c8        ret     z		; yes, return

0a9b  23        inc     hl		; else increase difficulty
0a9c  220a4e    ld      (#4e0a),hl	; store result
0a9f  c9        ret     		; return

; called from #06C1 when (#4E04 == #20)

0aa0  c38809    jp      #0988		; 

; ; called from #06C1 when (#4E04 == #22)

0aa3  c3d209    jp      #09d2		; 

; called from #0961
; transposes data from #4e0a through #4e37 into #4e38 through #4e66
; used to copy data in and out for 2 player games

0aa6  062e      ld      b,#2e		; For B = 1 to #2E
0aa8  dd210a4e  ld      ix,#4e0a	; load IX with group 1 start address
0aac  fd21384e  ld      iy,#4e38	; load IY with group 2 start address

0ab0  dd5600    ld      d,(ix+#00)	; load D with data from group 1
0ab3  fd5e00    ld      e,(iy+#00)	; load E with data from group 2
0ab6  fd7200    ld      (iy+#00),d	; store D into group 2
0ab9  dd7300    ld      (ix+#00),e	; store E into group 1
0abc  dd23      inc     ix		; next address
0abe  fd23      inc     iy		; next address
0ac0  10ee      djnz    #0ab0           ; next B
0ac2  c9        ret     		; return

; called from #08FD

0ac3  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
0ac6  a7        and     a		; is there a collision ?
0ac7  c0        ret     nz		; yes, return

; this subroutine never gets called when the green-eyed ghost bug occurs

0ac8  dd21004c  ld      ix,#4c00	; else load IX with start of sprites address
0acc  fd21c84d  ld      iy,#4dc8	; load IY with (counter used to change ghost colors under big pill effects?)
0ad0  110001    ld      de,#0100	; load DE with offset value of #0100.  [used at #0AE7]
0ad3  fdbe00    cp      (iy+#00)	; compare.  is it time to flash?
0ad6  c2d20b    jp      nz,#0bd2	; no, decrement (IY) and return

0ad9  fd36000e  ld      (iy+#00),#0e	; else reset counter to #0E
0add  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
0ae0  a7        and     a		; is a power pill still active ?
0ae1  281b      jr      z,#0afe         ; no, skip ahead

0ae3  2acb4d    ld      hl,(#4dcb)	; yes, load HL with counter while ghosts are blue
0ae6  a7        and     a		; clear carry flag
0ae7  ed52      sbc     hl,de		; subtract offset of #0100.  has this counter gone under?
0ae9  3013      jr      nc,#0afe        ; no, skip ahead

; arrive here when ghosts start flashing after being blue
; this sub controls the flashing and the return

0AEB: 21 AC 4E	ld	hl,#4EAC	; yes, load HL with sound 2 channel
0AEE: CB FE	set	7,(hl)		; play sound = high frequency
0AF0: 3E 09	ld	a,#09		; A := #09
0AF2: DD BE 0B	cp	(ix+#0b)	; compare with #4C0b = pacman color entry.  is a ghost being eaten?
0AF5: 20 04	jr	nz,#0AFB	; no, skip ahead

0AF7: CB BE	res	7,(hl)		; clear sound
0AF9: 3E 09	ld	a,#09		; A := #09

0afb  320b4c    ld      (#4c0b),a	; set pacman color to yellow




0afe  3aa74d    ld      a,(#4da7)	; load A with red ghost blue flag (0=not blue)
0b01  a7        and     a		; is red ghost blue (edible) ?
0b02  281d      jr      z,#0b21         ; no, skip ahead and set red ghost to red

0b04  2acb4d    ld      hl,(#4dcb)	; else load HL with counter while ghosts are blue
0b07  a7        and     a		; clear carry flag
0b08  ed52      sbc     hl,de		; subtract offset (#0100).  has this counter gone under?
0b0a  3027      jr      nc,#0b33        ; no, jump ahead and check next ghost

0b0c  3e11      ld      a,#11		; yes, A := #11
0b0e  ddbe03    cp      (ix+#03)	; compare with red ghost color. is red ghost blue ?
0b11  2807      jr      z,#0b1a         ; yes, skip ahead and change his color to white

0b13  dd360311  ld      (ix+#03),#11	; no, set red ghost to blue color
0b17  c3330b    jp      #0b33		; skip ahead and check next ghost

0b1a  dd360312  ld      (ix+#03),#12	; set red ghost color to white
0b1e  c3330b    jp      #0b33		; skip ahead and check next ghost

0b21  3e01      ld      a,#01		; A := #01
0b23  ddbe03    cp      (ix+#03)	; compare with red ghost color.  is the red ghost red?
0b26  2807      jr      z,#0b2f         ; yes, then jump ahead

0b28  dd360301  ld      (ix+#03),#01	; set red ghost back to red
0b2c  c3330b    jp      #0b33		; skip ahead

0b2f  dd360301  ld      (ix+#03),#01	; set red ghost back to red

0b33  3aa84d    ld      a,(#4da8)	; load A with pink ghost blue flag
0b36  a7        and     a		; is pink ghost blue (edible) ?
0b37  281d      jr      z,#0b56         ; no, skip ahead and set pink ghost to pink

0b39  2acb4d    ld      hl,(#4dcb)	; else load HL with counter while ghosts are blue 
0b3c  a7        and     a		; clear carry flag
0b3d  ed52      sbc     hl,de		; subtract offset (#0100).  has this counter gone under?
0b3f  3027      jr      nc,#0b68        ; no, jump ahead and check next ghost

0b41  3e11      ld      a,#11		; A := #11
0b43  ddbe05    cp      (ix+#05)	; compare with pink ghost color.  is the pink ghost blue?
0b46  2807      jr      z,#0b4f         ; yes, jump ahead and change his color to white

0b48  dd360511  ld      (ix+#05),#11	; no, set pink ghost back to blue
0b4c  c3680b    jp      #0b68		; skip ahead

0b4f  dd360512  ld      (ix+#05),#12	; set pink ghost color to white
0b53  c3680b    jp      #0b68		; skip ahead

0b56  3e03      ld      a,#03		; A := #03
0b58  ddbe05    cp      (ix+#05)	; is the pink ghost pink ?
0b5b  2807      jr      z,#0b64         ; yes, skip ahead

0b5d  dd360503  ld      (ix+#05),#03	; set pink ghost to pink
0b61  c3680b    jp      #0b68		; jump ahead

0b64  dd360503  ld      (ix+#05),#03	; set pink ghost to pink

0b68  3aa94d    ld      a,(#4da9)	; load A with blue ghost (inky) blue flag
0b6b  a7        and     a		; is inky blue (edible) ?
0b6c  281d      jr      z,#0b8b         ; no, skip ahead

0b6e  2acb4d    ld      hl,(#4dcb)	; else load HL with counter while ghosts are blue
0b71  a7        and     a		; clear carry flag
0b72  ed52      sbc     hl,de		; subtract offset (#0100).  has this counter gone under?
0b74  3027      jr      nc,#0b9d        ; no, jump ahead and check next ghost

0b76  3e11      ld      a,#11		; A := #11
0b78  ddbe07    cp      (ix+#07)	; is inky blue (edible) ?
0b7b  2807      jr      z,#0b84         ; yes, jump ahead and change his color to white

0b7d  dd360711  ld      (ix+#07),#11	; no, set inky to blue color
0b81  c39d0b    jp      #0b9d		; skip ahead

0b84  dd360712  ld      (ix+#07),#12	; set inky to white color
0b88  c39d0b    jp      #0b9d		; skip ahead

0b8b  3e05      ld      a,#05		; A := #05
0b8d  ddbe07    cp      (ix+#07)	; is inky his regular color ?
0b90  2807      jr      z,#0b99         ; yes, skip ahead

0b92  dd360705  ld      (ix+#07),#05	; set inky to his regular color
0b96  c39d0b    jp      #0b9d		; skip ahead

0b99  dd360705  ld      (ix+#07),#05	; set inky to his regular color

0b9d  3aaa4d    ld      a,(#4daa)	; load A with orange ghost blue flag
0ba0  a7        and     a		; is orange ghost blue (edible) ?
0ba1  281d      jr      z,#0bc0         ; no, skip ahead

0ba3  2acb4d    ld      hl,(#4dcb)	; else load HL with counter while ghosts are blue 
0ba6  a7        and     a		; clear carry flag
0ba7  ed52      sbc     hl,de		; subtract offset (#0100).  has this counter gone under?
0ba9  3027      jr      nc,#0bd2        ; no, jump ahead

0bab  3e11      ld      a,#11		; A := #11
0bad  ddbe09    cp      (ix+#09)	; is orange ghost blue (edible) ?
0bb0  2807      jr      z,#0bb9         ; yes, skip ahead and change to white

0bb2  dd360911  ld      (ix+#09),#11	; no, set orange ghost color to blue
0bb6  c3d20b    jp      #0bd2		; skip ahead

0bb9  dd360912  ld      (ix+#09),#12	; set orange ghost color to white
0bbd  c3d20b    jp      #0bd2		; skip ahead

0bc0  3e07      ld      a,#07		; A := #07
0bc2  ddbe09    cp      (ix+#09)	; is orange ghost orange ?
0bc5  2807      jr      z,#0bce         ; yes, skip ahead

0bc7  dd360907  ld      (ix+#09),#07	; set orange ghost to orange
0bcb  c3d20b    jp      #0bd2		; skip ahead

0bce  dd360907  ld      (ix+#09),#07	; set orange ghost to orange

0bd2  fd3500    dec     (iy+#00)	; decrease the flash counter
0bd5  c9        ret     		; return

; called from #0900

    ; set the color for a dead ghost
0bd6  0619      ld      b,#19		; B := #19 - floating death eyes (good band name!)
0bd8  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
0bdb  fe22      cp      #22		; == #22 ? is code is used in pac-man only, not ms. pac.  its checking for the routine where pacman heads towards the energizer followed by 4 ghosts
0bdd  c2e20b    jp      nz,#0be2	; no, skip next step

0be0  0600      ld      b,#00		; B := #00.  code used to clear ghosts after they get eaten in the pac-man attract

0be2  dd21004c  ld      ix,#4c00	; load IX with start of offset for ghost sprites and colors
0be6  3aac4d    ld      a,(#4dac)	; load A with red ghost state

0be9  a7        and     a		; is red ghost alive ?
0bea  caf00b    jp      z,#0bf0		; yes, skip next step. only set color if not alive

0bed  dd7003    ld      (ix+#03),b	; store B into red ghost color entry

0bf0  3aad4d    ld      a,(#4dad)	; load A wtih pink ghost state
0bf3  a7        and     a		; is pink ghost alive ?
0bf4  cafa0b    jp      z,#0bfa		; yes, skip next step

0bf7  dd7005    ld      (ix+#05),b	; store B into pink ghost color entry

0bfa  3aae4d    ld      a,(#4dae)	; load A with blue ghost (inky) state
0bfd  a7        and     a		; is inky alive ?
0bfe  ca040c    jp      z,#0c04		; yes, skip next step

0c01  dd7007    ld      (ix+#07),b	; store B into blue ghost (inky) color entry

0c04  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
0c07  a7        and     a		; is orange ghost alive ? 
0c08  c8        ret     z		; yes, return

0c09  dd7009    ld      (ix+#09),b	; store B into orange ghost color entry
0c0c  c9        ret   			; return  

; called from #0903
; routine to handle power pill flashes

0c0d  21cf4d    ld      hl,#4dcf	; load HL with power pill counter
0c10  34        inc     (hl)		; increment
0c11  3e0a      ld      a,#0a		; A := #0A
0c13  be        cp      (hl)		; is it time to flash the power pellets ?
0c14  c0        ret     nz		; no, return

0c15  3600      ld      (hl),#00	; else we will flash the pellets.  reset counter to #00
0c17  3a044e    ld      a,(#4e04)	; load A with game state indicator.  this is #03 when game or demo is in play
0c1a  fe03      cp      #03		; == #03 ?  Is a game being played ?
0c1c  2015      jr      nz,#0c33        ; no, skip ahead and flash the pellets in the demo screen where pac is chased by 4 ghosts and then eats a power pill and eats them all

; BUGFIX05 - Map discoloration fix - Don Hodges
0c1c  2000	jr 	nz,#0c1e	; no, do nothing

0c1e  216444    ld      hl,#4464	; else load HL with first power pellet address (legacy from pac-man.  new routine loads new value)

; OTTOPATCH
;PATCH TO MAKE THE ENERGIZERS FLASH IN NEW AND EXCITING COLORS
ORG 0C21H
JP FLASHEN
0c21  c32495    jp      #9524		; jump to new ms pac routine to flash power pellets

;; Pac-man code:
; 0c21  3e10      ld      a,#10		; load A with code for power pellet
; 0c23  be        cp      (hl)		; is there already a power pellet there?
;; end pac-man code

; junk from pac-man, flashes power pellets for non-changing maze

0c24  2002      jr      nz,#0c28        ; no, skip ahead
0c26  3e00      ld      a,#00		; yes, change code to empty graphic
0c28  77        ld      (hl),a		; flash power pellet
0c29  327844    ld      (#4478),a	; flash power pellet
0c2c  328447    ld      (#4784),a	; flash power pellet
0c2f  329847    ld      (#4798),a	; flash power pellet
0c32  c9        ret     		; return

; arrive from #0C1C
; flash the pellets in the demo screen where pac is chased by 4 ghosts and then eats a power pill and eats them all
; this causes a very minor bug in pac-man and ms. pac man.  
; potentially 2 screen elements can sometimes get colored wrong when player dies.
; in pac-man, a dot may disappear at #4678

0c33  213247    ld      hl,#4732	; load HL with screen color address (?)
0c36  3e10      ld      a,#10		; A := #10
0c38  be        cp      (hl)		; is the screen color in this address == #10 ?
0c39  2002      jr      nz,#0c3d        ; no, skip next step

0c3b  3e00      ld      a,#00		; A := #00

0c3d  77        ld      (hl),a		; store #10 or #00 into this color location to flash the power pill in the demo
0c3e  327846    ld      (#4678),a	; store into #4678 to flash the other power pill
0c41  c9        ret     		; return (to #0906)

; called from #08f4
; handles ghost movements when they are moving around in or coming out of the ghost home

; red ghost

0c42  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
0c45  a7        and     a		; == #00 ?
0c46  c0        ret     nz		; return if no collision

0c47  3a944d    ld      a,(#4d94)	; else load A with counter related to ghost movement inside home
0c4a  07        rlca    		; rotate left
0c4b  32944d    ld      (#4d94),a	; store result
0c4e  d0        ret     nc		; return if no carry

0c4f  3aa04d    ld      a,(#4da0)	; else load A with red ghost substate
0c52  a7        and     a		; is red ghost out of the ghost house ?
0c53  c2900c    jp      nz,#0c90	; yes, skip ahead and check next ghost

0c56  dd210533  ld      ix,#3305	; no, load IX with address for offsets to move up
0c5a  fd21004d  ld      iy,#4d00	; load IY with red ghost position
0c5e  cd0020    call    #2000		; load HL with IY + IX = new position by moving up
0c61  22004d    ld      (#4d00),hl	; store into red ghost position
0c64  3e03      ld      a,#03		; A := #03
0c66  32284d    ld      (#4d28),a	; set previous red ghost orientation as moving up
0c69  322c4d    ld      (#4d2c),a	; set red ghost orientation as moving up
0c6c  3a004d    ld      a,(#4d00)	; load A with red ghost Y position
0c6f  fe64      cp      #64		; is the red ghost out of the ghost house ?
0c71  c2900c    jp      nz,#0c90	; no, skip ahead and check next ghost

0c74  212c2e    ld      hl,#2e2c	; yes, HL := #2E, 2C
0c77  220a4d    ld      (#4d0a),hl	; store into red ghost position
0c7a  210001    ld      hl,#0100	; HL := #01 00 (code for moving to left)
0c7d  22144d    ld      (#4d14),hl	; store into red ghost tile changes
0c80  221e4d    ld      (#4d1e),hl	; store into red ghost tile changes
0c83  3e02      ld      a,#02		; A := #02
0c85  32284d    ld      (#4d28),a	; set previous red ghost orientation as moving left
0c88  322c4d    ld      (#4d2c),a	; set red ghost orientation as moving left
0c8b  3e01      ld      a,#01		; A := #01
0c8d  32a04d    ld      (#4da0),a	; set red ghost indicator to outside the ghost house

; pink ghost

0c90  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
0c93  fe01      cp      #01		; is pink ghost out of the ghost house ?
0c95  cafb0c    jp      z,#0cfb		; yes, skip ahead and check next ghost

0c98  fe00      cp      #00		; is pink ghost waiting to leave the ghost house?
0c9a  c2c10c    jp      nz,#0cc1	; no, skip ahead

; pink ghost is moving up and down in the ghost house

0c9d  3a024d    ld      a,(#4d02)	; yes, load A with pink ghost Y position
0ca0  fe78      cp      #78		; is pink ghost at the upper limit of the ghost house?
0ca2  cc2e1f    call    z,#1f2e		; yes, reverse direction of pink ghost

0ca5  fe80      cp      #80		; is pink ghost at bottom of the ghost house?
0ca7  cc2e1f    call    z,#1f2e		; yes, reverse direction of pink ghost

0caa  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost orientation
0cad  32294d    ld      (#4d29),a	; store into previous pink ghost orienation
0cb0  dd21204d  ld      ix,#4d20	; load IX with pink ghost tile changes
0cb4  fd21024d  ld      iy,#4d02	; load IY with pink ghost position
0cb8  cd0020    call    #2000		; load HL with IX + IY = new pink ghost position
0cbb  22024d    ld      (#4d02),hl	; store into pink ghost position
0cbe  c3fb0c    jp      #0cfb		; skip ahead and check next ghost

; pink ghost is moving up out of the ghost house

0cc1  dd210533  ld      ix,#3305	; load IX with address for offsets to move up
0cc5  fd21024d  ld      iy,#4d02	; load IY with pink ghost position
0cc9  cd0020    call    #2000		; load HL with IY + IX = new pink ghost position
0ccc  22024d    ld      (#4d02),hl	; store result into pink ghost position
0ccf  3e03      ld      a,#03		; A := #03
0cd1  322d4d    ld      (#4d2d),a	; set previous pink ghost orientation as moving up
0cd4  32294d    ld      (#4d29),a	; set pink ghost orientation as moving up
0cd7  3a024d    ld      a,(#4d02)	; load A with pink ghost Y position
0cda  fe64      cp      #64		; is pink ghost out of the ghost house ?
0cdc  c2fb0c    jp      nz,#0cfb	; no, skip ahead and check next ghost

; pink ghost has made it out of the ghost house

0cdf  212c2e    ld      hl,#2e2c	; HL := 2E, 2C
0ce2  220c4d    ld      (#4d0c),hl	; store into pink ghost position
0ce5  210001    ld      hl,#0100	; HL := #01 00 (code for moving left)
0ce8  22164d    ld      (#4d16),hl	; store into pink ghost tile changes
0ceb  22204d    ld      (#4d20),hl	; store into pink ghost tile changes
0cee  3e02      ld      a,#02		; A := #02
0cf0  32294d    ld      (#4d29),a	; set previous pink ghost orientation as moving left
0cf3  322d4d    ld      (#4d2d),a	; set pink ghost orientation as moving left
0cf6  3e01      ld      a,#01		; A := #01
0cf8  32a14d    ld      (#4da1),a	; set pink ghost indicator to outside the ghost house

; blue ghost (inky)

0cfb  3aa24d    ld      a,(#4da2)	; load A with blue ghost (inky) substate
0cfe  fe01      cp      #01		; is inky out of the ghost house ?
0d00  ca930d    jp      z,#0d93		; yes, skip ahead and check next ghost

0d03  fe00      cp      #00		; is inky waiting to leave the ghost house ?
0d05  c22c0d    jp      nz,#0d2c	; no, skip ahead

; inky is moving up and down in the ghost house

0d08  3a044d    ld      a,(#4d04)	; load A with inky Y position
0d0b  fe78      cp      #78		; is inky at the upper limit of ghost house ?
0d0d  cc551f    call    z,#1f55		; yes, reverse direction of inky
0d10  fe80      cp      #80		; is inky at the bottom of the ghost house ?
0d12  cc551f    call    z,#1f55		; yes, reverse direction of inky

0d15  3a2e4d    ld      a,(#4d2e)	; load A with inky orientation
0d18  322a4d    ld      (#4d2a),a	; store into previous inky orientation
0d1b  dd21224d  ld      ix,#4d22	; load IX with inky tile changes
0d1f  fd21044d  ld      iy,#4d04	; load IY with inky position
0d23  cd0020    call    #2000		; load HL with IX + IY = new inky position
0d26  22044d    ld      (#4d04),hl	; store into inky position
0d29  c3930d    jp      #0d93		; skip ahead and check next ghost

0d2c  3aa24d    ld      a,(#4da2)	; load A with inky substate
0d2f  fe03      cp      #03		; is inky moving to his right, on his way out of the ghost house?
0d31  c2590d    jp      nz,#0d59	; no, skip ahead

; inky is on his way out of ghost house to right

0d34  dd21ff32  ld      ix,#32ff	; yes, load IX with tile movement for moving right
0d38  fd21044d  ld      iy,#4d04	; load IY with inky position
0d3c  cd0020    call    #2000		; load HL with IX + IY = new inky position
0d3f  22044d    ld      (#4d04),hl	; store new position for inky
0d42  af        xor     a		; A := #00
0d43  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving right
0d46  322e4d    ld      (#4d2e),a	; set inky orientation as moving right
0d49  3a054d    ld      a,(#4d05)	; load A with inky X position
0d4c  fe80      cp      #80		; is inky exactly under the ghost house door ?
0d4e  c2930d    jp      nz,#0d93	; no, skip ahead and check next ghost

0d51  3e02      ld      a,#02		; yes, A := #02
0d53  32a24d    ld      (#4da2),a	; store into inky substate to indicate moving up and out of ghost house
0d56  c3930d    jp      #0d93		; skip ahead and check next ghost

; inky is moving up out of the ghost house

0d59  dd210533  ld      ix,#3305	; load IX with address for offsets to move up
0d5d  fd21044d  ld      iy,#4d04	; load IY with inky position
0d61  cd0020    call    #2000		; load HL with IX + IY = new inky position
0d64  22044d    ld      (#4d04),hl	; store into inky position
0d67  3e03      ld      a,#03		; A := #03
0d69  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving up
0d6c  322e4d    ld      (#4d2e),a	; set inky orientation as moving up
0d6f  3a044d    ld      a,(#4d04)	; load A with inky's Y position
0d72  fe64      cp      #64		; is inky out of the ghost house ?
0d74  c2930d    jp      nz,#0d93	; no, skip ahead and check next ghost

; inky has made it out of the ghost house

0d77  212c2e    ld      hl,#2e2c	; load HL with 2E, 2C
0d7a  220e4d    ld      (#4d0e),hl	; store into inky tile position
0d7d  210001    ld      hl,#0100	; load HL with code for moving left
0d80  22184d    ld      (#4d18),hl	; store into inky tile changes
0d83  22224d    ld      (#4d22),hl	; store into inky tile changes
0d86  3e02      ld      a,#02		; A := #02
0d88  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving left
0d8b  322e4d    ld      (#4d2e),a	; set inky orientation as moving left
0d8e  3e01      ld      a,#01		; A := #01	
0d90  32a24d    ld      (#4da2),a	; set inky ghost indicator to outside the ghost house

; orange ghost

0d93  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
0d96  fe01      cp      #01		; is orange ghost out of the ghost house ?
0d98  c8        ret     z		; yes, return

0d99  fe00      cp      #00		; is orange ghost waiting to leave the ghost house ?
0d9b  c2c00d    jp      nz,#0dc0	; no, skip ahead

; orange ghost is moving up and down in the ghost house

0d9e  3a064d    ld      a,(#4d06)	; yes, load A with orange ghost Y position
0da1  fe78      cp      #78		; is orange ghost at upper limit of ghost house ?
0da3  cc7c1f    call    z,#1f7c		; yes, reverse orange ghost direction

0da6  fe80      cp      #80		; is orange ghost at bottom of ghost house ?
0da8  cc7c1f    call    z,#1f7c		; yes, reverse orange ghost direction

0dab  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost orientation
0dae  322b4d    ld      (#4d2b),a	; store into previous orange ghost orientation
0db1  dd21244d  ld      ix,#4d24	; load IX with orange ghost tile changes
0db5  fd21064d  ld      iy,#4d06	; load IY with orange ghost position
0db9  cd0020    call    #2000		; load HL with IX + IY = new orange ghost position
0dbc  22064d    ld      (#4d06),hl	; store into orange ghost position
0dbf  c9        ret     		; return

0dc0  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
0dc3  fe03      cp      #03		; is orange ghost moving to his left, on his way out of the ghost house ?
0dc5  c2ea0d    jp      nz,#0dea	; no, skip ahead

; orange ghost is moving left, on his way out of ghost house

0dc8  dd210333  ld      ix,#3303	; load IX with address for offsets to move left
0dcc  fd21064d  ld      iy,#4d06	; load IY with orange ghost position 
0dd0  cd0020    call    #2000		; load HL with IX + IY = new orange ghost position
0dd3  22064d    ld      (#4d06),hl	; store new orange ghost position
0dd6  3e02      ld      a,#02		; A := #02
0dd8  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving left
0ddb  322f4d    ld      (#4d2f),a	; set orange ghost orientation as moving left
0dde  3a074d    ld      a,(#4d07)	; load A with orange ghost X position
0de1  fe80      cp      #80		; is orange ghost exactly under the ghost house door ?
0de3  c0        ret     nz		; no, return

0de4  3e02      ld      a,#02		; yes, A := #02
0de6  32a34d    ld      (#4da3),a	; store into orange ghost substate to indicate moving up and out of ghost house
0de9  c9        ret			; return

; orange ghost is moving up and out of ghost house

0dea  dd210533  ld      ix,#3305	; load IX with address for offsets to move up
0dee  fd21064d  ld      iy,#4d06	; load IY with orange ghost position
0df2  cd0020    call    #2000		; load HL with IX + IY = new orange ghost position
0df5  22064d    ld      (#4d06),hl	; store into orange ghost position
0df8  3e03      ld      a,#03		; A := #03
0dfa  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving up
0dfd  322f4d    ld      (#4d2f),a	; set orange ghost orientation as moving up
0e00  3a064d    ld      a,(#4d06)	; load A with orange ghost Y position
0e03  fe64      cp      #64		; is orange ghost out of the ghost house ?
0e05  c0        ret     nz		; no, return

; orange ghost has made it out of the ghost house

0e06  212c2e    ld      hl,#2e2c	; load HL with 2E, 2C
0e09  22104d    ld      (#4d10),hl	; store into orange ghost tile position
0e0c  210001    ld      hl,#0100	; load HL with code for moving left
0e0f  221a4d    ld      (#4d1a),hl	; store into oragne ghost tile changes
0e12  22244d    ld      (#4d24),hl	; store into orange ghost tile changes
0e15  3e02      ld      a,#02		; A := #02
0e17  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving left
0e1a  322f4d    ld      (#4d2f),a	; set orange ghost orientation as moving left
0e1d  3e01      ld      a,#01		; A := #01
0e1f  32a34d    ld      (#4da3),a	; set orange ghost indicator to outside the ghost house
0e22  c9        ret     		; return

; called from #08f7

0e23  21c44d    ld      hl,#4dc4	; load HL with counter
0e26  34        inc     (hl)		; increment
0e27  3e08      ld      a,#08		; A := #08
0e29  be        cp      (hl)		; is the counter == #08 ?
0e2a  c0        ret     nz		; no, return

0e2b  3600      ld      (hl),#00	; else clear counter
0e2d  3ac04d    ld      a,(#4dc0)	; load A with address used for ghost animations
0e30  ee01      xor     #01		; flip bit 0
0e32  32c04d    ld      (#4dc0),a	; store result
0e35  c9        ret     		; return

; called from #08fa

0e36  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
0e39  a7        and     a		; is a power pill active ?
0e3a  c0        ret     nz		; yes, return, we never reverse dir. when power pill is on

0e3b  3ac14d    ld      a,(#4dc1)	; no, load A with ghost orientation index
0e3e  fe07      cp      #07		; == #07 ?
0e40  c8        ret     z		; yes, return, we never reverse dir. more than 7 times (pac-man only)

0e41  87        add     a,a		; Double the index, this is used below for offset in the table
0e42  2ac24d    ld      hl,(#4dc2)	; load HL with counter for ghost reversals
0e45  23        inc     hl		; increment
0e46  22c24d    ld      (#4dc2),hl	; store result
0e49  5f        ld      e,a		; E := A
0e4a  1600      ld      d,#00		; D := #00
0e4c  dd21864d  ld      ix,#4d86	; load IX with start of difficulty table
0e50  dd19      add     ix,de		; add offset based on which reversal this is
0e52  dd5e00    ld      e,(ix+#00)	; 
0e55  dd5601    ld      d,(ix+#01)	; load DE with result from table.  for first reverse this is #01A4
0e58  a7        and     a		; clear carry flag
0e59  ed52      sbc     hl,de		; subtract.  are they equal ? = time to reverse direction of ghosts
0e5b  c0        ret     nz		; if not, return

; arrive here when ghosts reverse direction
; this differs from the pac-man code

; OTTOPATCH
;PATCH TO MAKE RED MONSTER GO AFTER OTTO TO AVOID PARKING
0e5c  af        xor     a		; else A := #00
0e5d  00        nop     		; 


;; Pac-Man code follows
	; 0E5C CB 3F SRL A		; this undoes the double from line #0E41
;; end pac-man code

0e5e  3c        inc     a		; increment
0e5f  32c14d    ld      (#4dc1),a	; store into orientation index
0e62  210101    ld      hl,#0101
0e65  22b14d    ld      (#4db1),hl
0e68  22b34d    ld      (#4db3),hl	; load #01 ghost orientations - reverses ghosts direction
0e6b  c9        ret     		; return

; called from #0906
; changes the background sound based on # of pills eaten

0e6c  3aa54d    ld      a,(#4da5)	; load A with pacman dead animation state (0 if not dead)
0e6f  a7        and     a		; is pacman dead ?
0e70  2805      jr      z,#0e77         ; no, skip ahead
0e72  af        xor     a		; else A := #00
0e73  32ac4e    ld      (#4eac),a	; clear sound channel 2
0e76  c9        ret     		; return

0E77: 21 AC 4E	ld	hl,#4EAC	; else pacman is alive.  load HL with sound 2 channel
0E7A: 06 E0	ld	b,#E0		; B := #E0.  this is a binary bitmask of 11100000 applied later
0E7C: 3A 0E 4E	ld	a,(#4E0E)	; load A with number of pills eaten in this level
0E7F: FE E4	cp	#E4		; > #E4 ?
0E81: 38 06	jr	c,#0E89		; no, skip ahead

0E83: 78	ld	a,b		; else load A with bitmask
0E84: A6	and	(hl)		; apply bitmask to sound 2 channel. this turns off bits 0 through 4
0E85: CB E7	set	4,a		; turn on bit 4
0E87: 77	ld	(hl),a		; play sound
0E88: C9	ret  			; return

0e89  fed4      cp      #d4		; is the number of pills eaten in this level > #D4 ? 
0e8b  3806      jr      c,#0e93         ; no, skip ahead

0e8d  78        ld      a,b		; else load A with bitmask
0e8e  a6        and     (hl)		; turn off bits 0 through 4 on sound channel
0e8f  cbdf      set     3,a		; turn on bit 3
0e91  77        ld      (hl),a		; play sound
0e92  c9        ret     		; return

0e93  feb4      cp      #b4		; is the number of pills eaten in this level > #B4 ?
0e95  3806      jr      c,#0e9d         ; no, skip ahead
0e97  78        ld      a,b		; else load A with bitmask
0e98  a6        and     (hl)		; turn off bits 0 through 4 on sound channel
0e99  cbd7      set     2,a		; turn on bit 2
0e9b  77        ld      (hl),a		; play sound
0e9c  c9        ret     		; return

0e9d  fe74      cp      #74		; is the number of pills eaten in this level > #74 ?
0e9f  3806      jr      c,#0ea7         ; no, skip ahead
0ea1  78        ld      a,b		; load A with bitmask
0ea2  a6        and     (hl)		; turn off bits 0 through 4 on sound channel
0ea3  cbcf      set     1,a		; turn on bit 1
0ea5  77        ld      (hl),a		; play sound
0ea6  c9        ret     		; return

0ea7  78        ld      a,b		; else load A with bitmask
0ea8  a6        and     (hl)		; turn off bits 0 through 4 on sound channel
0ea9  cbc7      set     0,a		; turn on bit 0
0eab  77        ld      (hl),a		; play sound
0eac  c9        ret     		; return

; called from #0909

; OTTOPATCH
;PATCH TO THE PRIMARY FRUIT ROUTINE, THIS ROUTINE IS CALLED ONCE PER
;GAME STEP (THE MINIMUM TIME IT TAKES A MONSTER TO MOVE A PIXEL)
ORG 0EADH
JP DOFRUIT
0ead  c3ee86    jp      #86ee		; jump to Ms. Pac patch for fruit release OTTO DOFRUIT

; original pac man code:
; 0EAD  3aa54d	ld	a,(#4da5)	; load A with pacman dead animation state (0 if not dead)
; end original pac man code

; junk from pac-man, used for fruit release

0eb0  a7        and     a		; is pac man dead ?
0eb1  c0        ret     nz		; yes, return

0eb2  3ad44d    ld      a,(#4dd4)	; load A with entry to fruit points (0 if no fruit)
0eb5  a7        and     a		; is a fruit already onscreen?
0eb6  c0        ret     nz		; yes, return

0eb7  3a0e4e    ld      a,(#4e0e)	; load A with # of pills eaten this level
0eba  fe46      cp      #46		; == #46 ?
0ebc  280e      jr      z,#0ecc         ; yes, skip ahead to check for launch of first fruit
0ebe  feaa      cp      #aa		; == #AA ?
0ec0  c0        ret     nz		; no, return

0ec1  3a0d4e    ld      a,(#4e0d)	; load A with second fruit flag (1 if fruit has appeared)
0ec4  a7        and     a		; has the second fruit already appeared ?
0ec5  c0        ret     nz		; yes, return

0ec6  210d4e    ld      hl,#4e0d	; else load HL with second fruit flag
0ec9  34        inc     (hl)		; set the flag
0eca  1809      jr      #0ed5           ; skip ahead to release fruit

0ecc  3a0c4e    ld      a,(#4e0c)	; load A with first fruit flag (1 if fruit has appeared)
0ecf  a7        and     a		; has the first fruit already appeared ?
0ed0  c0        ret     nz		; yes, return

0ed1  210c4e    ld      hl,#4e0c	; else load HL with first fruit flag
0ed4  34        inc     (hl)		; set the flag
0ed5  219480    ld      hl,#8094	; load H with #80, L with #94
0ed8  22d24d    ld      (#4dd2),hl	; store #80 into #4dd2, #94 into #4dd3.  sets fruit position to #80,#94 onscreen
0edb  21fd0e    ld      hl,#0efd	; load HL with start of fruit data table below
0ede  3a134e    ld      a,(#4e13)	; load A with board level
0ee1  fe14      cp      #14		; > #14 ? (20 decimal)
0ee3  3802      jr      c,#0ee7         ; yes, skip ahead

0ee5  3e14      ld      a,#14		; else load A with #14
0ee7  47        ld      b,a		; copy to B
0ee8  87        add     a,a		; A := A*2
0ee9  80        add     a,b		; A := A + B.  A now has 3 times the board level
0eea  d7        rst     #10		; A: = (HL + A), HL := HL + A
0eeb  320c4c    ld      (#4c0c),a	; Store fruit shape code
0eee  23        inc     hl		; next address for color
0eef  7e        ld      a,(hl)		; load A with fruit color
0ef0  320d4c    ld      (#4c0d),a	; Store fruit color code
0ef3  23        inc     hl		; next address for point value
0ef4  7e        ld      a,(hl)		; Load A with point value
0ef5  32d44d    ld      (#4dd4),a	; Store fruit point value
0ef8  f7        rst     #30		; set timed task to clear the fruit sprite.
0ef9  8a 04 00				; timer=8a, task=4, param=0.  clears fruit after timer runs out (10 seconds)
0efc  c9        ret  			; return
 
	; table for fruit sprites, colors, point value.  pac-man only, not used in ms. pac
	; (the 3 bytes are stored in the above order)
	; [the corresponding ms pac fruit table is at #879D]

0EFD  00 14 06				; cherry
0F00  01 0F 07 				; strawberry
0F03  02 15 08				; 1st peach
0F06  02 15 08				; 2nd peach
0F09  04 14 09				; 1st apple
0F0C  04 14 09				; 2nd apple
0F0F  05 17 0A				; 1st grape
0F12  05 17 0A				; 2nd grape
0F15  06 09 0B				; 1st galaxian
0F18  06 09 0B				; 2nd galaxian
0F1B  03 16 0C				; 1st bell
0F1E  03 16 0C				; 2nd bell
0F21  07 16 0D				; 1st key
0F24  07 16 0D				; 2nd key
0F27  07 16 0D				; 3rd key
0F2A  07 16 0D				; 4th key
0F2D  07 16 0D				; 5th key
0F30  07 16 0D				; 6th key
0F33  07 16 0D				; 7th key
0F36  07 16 0D				; 8th key
0F39  07 16 0D				; 9th key

; end pac-man code for fruit release


0F3C:                                     00 00 00 00
0F40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0F50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0F60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0F70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0F80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0F90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0FA0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0FB0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0FC0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0FD0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0FE0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0FF0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

0FFE: 81 CE				; checksum bytes for this rom bank #0000 through #0FFF
    
    
	; hacks start at 0f5c since 0f3c-0f5b is used in other romsets.

	;; Pause toggle ; HACK5
        ; start 1 enters pause, start 2 leaves pause

	; 0f5c  3a4050    ld      a,(#5040)       ; IN1
	; 0f5f  e620      and     #20             ; start 1
	; 0f61  c2db1f    jp      nz,#1fdb        ; nope. jump away
	; 1fd0 for HACK3

        ; pause 
   
	;0f64  f5        push    af
	;0f65  af        xor     a		; a=0
	;0f66  320150    ld      (#5001),a	; disable sound
	;0f69  32c050    ld      (#50c0),a	; kick dog
	;0f6c  320050    ld      (#5000),a	; disable interrupts
	;0f6f  f3        di			; disable interrupts
	;0f70  af        xor     a		; a=0
	;0f71  32c050    ld      (#50c0),a	; kick dog
	;0f74  3a4050    ld      a,(#5040)	; IN1
	;0f77  cb77      bit     6,a		; start 2
	;0f79  20f5      jr      nz,#0f70	; not pressed, loop back

        ; turn it back on

	;0f7b  3e01      ld	a,#01		; a=1
	;0f7d  320050    ld	(#5000),a	; enable interrupts
	;0f80  320150    ld	(#5001),a	; enable sound
	;0f83  fb        ei			; enable interrupts
	;0f84  f1        pop	af		; retore a
	;0f85  c3db1f    jp	#1fdb		; jump back


	; level 255 pac fix ; BUGFIX01 (2 of 2)

	;0f88  3a134e    ld      a,(#4e13)  	; board number
	;0f8b  3c        inc     a
	;0f8c  feff      cp      #ff
	;0f8e  2803      jr      z,#0f93	; don't store level if == 255
	;0f90  32134e    ld      (#4e13),a	; store new board number
	;0f93  c3940a    jp      #0a94		; jump back

	; level 141 mspac fix ; BUGFIX02 (2 of 2)

	;0f96  3a134e    ld      a,(#4e13)	; board number
	;0f99  3c        inc     a
	;0f9a  f37b      cp      #7b		; compare to bad board point
	;0f9c  2002      jr      nz,#0fa0	; don't store if out of range
	;0f9e  d608      sub     #08		; loop around for all 8 boards
	;0fa0  32134e    ld      (#4e13),a	; store the level number
	;0fa3  c3940a    jp      #0a94		; return


	;; blink coin lights to pellets ; HACK9

	; 0ffe  e089				; checksum patch



	; clear fruit
	; arrive from #0246 as timed task #04

1000  af        xor     a		; A := #00
1001  32d44d    ld      (#4dd4),a	; clear fruit
1004  c9        ret     		; return

; pac-man code:
; 1004 210000	ld	hl,#0000	; clear HL
; end pac-man code

; junk from pac-man
     
1007  22d24d    ld      (#4dd2),hl	; clear fruit position 
100a  c9        ret     		; return

; this is timed task #05, arrive from #0246

100B: C3 78 36	jp	#3678		; ms pac patch to erase the fruit score

; pac-man code:
; 100b  ef        rst     #28		; insert task to display text code #9B
; 100c  1C 9B
; end pac-man code

; junk from pac-man

100e  3a004e    ld      a,(#4e00)	; load A with main routine number
1011  3d        dec     a		; decrease.  are we in the demo?
1012  c8        ret     z		; yes, return
1013  ef        rst     #28		; no, insert task to display text code #A2
1014  1c a2				; task data
1016  c9        ret     		; return

; called from #052C, #052F, #08EB and #08EE 

1017  cd9112    call    #1291		; do things if pacman is dead
101a  3aa54d    ld      a,(#4da5)	; load A with pacman dead animation state (0 if pac is alive)
101d  a7        and     a		; is pacman alive?
101e  c0        ret     nz		; no, return (to #08F1)

101f  cd6610    call    #1066		; check for ghosts being eaten and set ghost states accordingly
1022  cd9410    call    #1094		; check for red ghost state and do things if not alive
1025  cd9e10    call    #109e		; check for pink ghost state and do things if not alive
1028  cda810    call    #10a8		; check for blue ghost (inky) state and do things if not alive
102b  cdb410    call    #10b4		; check for orange ghost state and do things if not alive
102e  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
1031  a7        and     a		; == #00 ?
1032  ca3910    jp      z,#1039		; yes, skip ahead

1035  cd3512    call    #1235		; no, call this sub
1038  c9        ret     		; and return

1039  cd1d17    call    #171d		; check for collision with regular ghosts
103c  cd8917    call    #1789		; check for collision with blue ghosts
103f  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet [0..4]
1042  a7        and     a		; is there a collsion ?
1043  c0        ret     nz		; yes, return

1044  cd0618    call    #1806		; handle all pac-man movement
1047  cd361b    call    #1b36		; control movement for red ghost
104a  cd4b1c    call    #1c4b		; control movement for pink ghost
104d  cd221d    call    #1d22		; control movement for blue ghost (inky)
1050  cdf91d    call    #1df9		; control movement for orange ghost
1053  3a044e    ld      a,(#4e04)	; load A with level state subroutine #
1056  fe03      cp      #03		; is a game being played ?
1058  c0        ret     nz		; no, return

1059  cd7613    call    #1376		; control blue ghost timer and reset ghosts when it is over or when pac eats all blue ghosts
105c  cd6920    call    #2069		; check for pink ghost to leave the ghost house
105f  cd8c20    call    #208c		; check for blue ghost (inky) to leave the ghost house
1062  cdaf20    call    #20af		; check for orange ghost to leave the ghost house
1065  c9        ret     		; return

; called from #101F

1066  3aab4d    ld      a,(#4dab)	; load A with killing ghost state
1069  a7        and     a		; is a ghost being eaten ?
106a  c8        ret     z		; no, return

106b  3d        dec     a		; is the red ghost being eaten?
106c  2008      jr      nz,#1076        ; no, skip ahead and check next ghost
106e  32ab4d    ld      (#4dab),a	; yes, store A (#00) into the killing ghost state
1071  3c        inc     a		; A := A + 1 [ A is now #01, code for dead ghost]
1072  32ac4d    ld      (#4dac),a	; store into red ghost state
1075  c9        ret     		; return

1076  3d        dec     a		; is the pink ghost being eaten?
1077  2008      jr      nz,#1081        ; no, skip ahead and check next ghost
1079  32ab4d    ld      (#4dab),a	; yes, store A (#00) into the killing ghost state
107c  3c        inc     a		; A := #01
107d  32ad4d    ld      (#4dad),a	; set pink ghost state to dead
1080  c9        ret     		; return

1081  3d        dec     a		; is the blue ghost (inky) being eaten?
1082  2008      jr      nz,#108c        ; no, skip ahead
1084  32ab4d    ld      (#4dab),a	; yes, store A (#00) into the killing ghost state
1087  3c        inc     a		; A := #01
1088  32ae4d    ld      (#4dae),a	; set inky ghost state to dead
108b  c9        ret     		; return

108c  32af4d    ld      (#4daf),a	; else orange ghost is being eaten.   set orange ghost state to dead
108f  3d        dec     a		; A := #00
1090  32ab4d    ld      (#4dab),a	; clear killing ghost state 
1093  c9        ret     		; return

; called from #1022

1094: 3A AC 4D	ld	a,(#4DAC)	; load A with red ghost state
1097: E7	rst	#20		; jump based on A
1098: 0C 00				; #000C	; return immediately when ghost is alive
109A: C0 10				; #10C0	; when ghost is dead
109C: D2 10				; #10D2	; when ghost eyes are above and entering the ghost house when returning home

; called from #1025

109E: 3A AD 4D	ld	a,(#4DAD)	; load A with pink ghost state
10A1: E7	rst	#20		; jump based on A
10A2: 0C 00				; #000C	; return immediately when ghost is alive
10A4: 18 11				; #1118	; when ghost is dead
10A6: 2A 11				; #112A	; when ghost eyes are above and entering the ghost house when returning home

; called from #1028

10A8: 3A AE 4D	ld	a,(#4DAE)	; load A with blue ghost (Inky) state
10AB: E7	rst	#20		; jump based on A
10AC: 0C 00				; #000C	; return immediately when ghost is alive
10AE: 5C 11				; #115C	; when ghost is dead
10B0: 6E 11 				; #116E	; when ghost eyes are above and entering the ghost house when returning home
10B2: 8F 11				; #118F	; when ghost eyes have arrived in ghost house and when moving to left side of ghost house

; called from #102B

10B4: 3A AF 4D	ld	a,(#4DAF)	; load A with orange ghost state
10B7: E7	rst	#20		; jump based on A
10B8: 0C 00				; #000C	; return immediately when ghost is alive
10BA: C9 11				; #11C9	; when ghost is dead
10BC: DB 11 				; #11DB	; when ghost eyes are above and entering the ghost house when returning home
10BE: FC 11				; #11FC	; when ghost eyes have arrived in ghost house and when moving to right side of ghost house

; arrive here from #1097 when red ghost is dead (eyes)

10C0: CD D8 1B	call	#1BD8		; handle red ghost movement
10C3: 2A 00 4D	ld	hl,(#4D00)	; load HL with red ghost (Y,X) position
10c6  116480    ld      de,#8064	; load DE with X=80, Y=64 position which is right above the ghost house
10c9  a7        and     a		; clear carry flag
10ca  ed52      sbc     hl,de		; is red ghost eyes right above the ghost house?
10cc  c0        ret     nz		; no, return

10cd  21ac4d    ld      hl,#4dac	; yes, load HL with red ghost state
10d0  34        inc     (hl)		; increase
10d1  c9        ret			; return

; arrive here from #1097 when red ghost eyes are above and entering the ghost house when returning home

10d2  dd210133  ld      ix,#3301	; load IX with direction address tiles for moving down
10d6  fd21004d  ld      iy,#4d00	; load IY with red ghost position
10da  cd0020    call    #2000		; HL := (IX) + (IY)
10dd  22004d    ld      (#4d00),hl	; store new position for red ghost
10e0  3e01      ld      a,#01		; A := #01
10e2  32284d    ld      (#4d28),a	; set previous red ghost orientation as moving down
10e5  322c4d    ld      (#4d2c),a	; set red ghost orientation as moving down
10e8  3a004d    ld      a,(#4d00)	; load A with red ghost Y position
10eb  fe80      cp      #80		; has the red ghost eyes fully entered the ghost house?
10ed  c0        ret     nz		; no, return

10ee  212f2e    ld      hl,#2e2f	; yes, load HL with 2E, 2F location which is the center of the ghost house
10f1  220a4d    ld      (#4d0a),hl	; store into red ghost tile position
10f4  22314d    ld      (#4d31),hl	; store into red ghost tile position 2
10f7  af        xor     a		; A := #00
10f8  32a04d    ld      (#4da0),a	; set red ghost substate as at home
10fb  32ac4d    ld      (#4dac),a	; set red ghost state as alive
10fe  32a74d    ld      (#4da7),a	; set red ghost blue flag as not edible

; the other ghost subroutines arrive here after the ghost has arrived at home

1101  dd21ac4d  ld      ix,#4dac	; load IX with ghost state starting address
1105  ddb600    or      (ix+#00)	; is red ghost dead?
1108  ddb601    or      (ix+#01)	; or the pink ghost dead?
110b  ddb602    or      (ix+#02)	; or the blue ghost dead?
110e  ddb603    or      (ix+#03)	; or the orange ghost dead
1111  c0        ret     nz		; yes, return

; arrive here when ghost eyes return to ghost home and there are no other ghost eyes still moving around

1112: 21 AC 4E	ld	hl,#4EAC	; load HL with sound channel 2
1115: CB B6	res	6,(hl)		; clear sound on bit 6
1117: C9	ret			; return

; arrive here from #10A1 when pink ghost is dead (eyes)

1118  cdaf1c    call    #1caf		; handle pink ghost movement
111b  2a024d    ld      hl,(#4d02)	; load HL with pink ghost position
111e  116480    ld      de,#8064	; load DE with Y,X position above ghost house 
1121  a7        and     a		; clear carry flag
1122  ed52      sbc     hl,de		; subtract. is the pink ghost eyes right above the ghost home?
1124  c0        ret     nz		; no, return

1125  21ad4d    ld      hl,#4dad	; yes, load HL with pink ghost state
1128  34        inc     (hl)		; increase
1129  c9        ret  			; return

; arrive here from #10A1 when pink ghost eyes are above and entering the ghost house when returning home

112a  dd210133  ld      ix,#3301	; load IX with direction address tiles for moving down
112e  fd21024d  ld      iy,#4d02	; load IY with pink ghost position
1132  cd0020    call    #2000		; HL := (IX) + (IY)
1135  22024d    ld      (#4d02),hl	; store new position for pink ghost
1138  3e01      ld      a,#01		; A := #01
113a  32294d    ld      (#4d29),a	; set previous pink ghost orientation as moving down
113d  322d4d    ld      (#4d2d),a	; set pink ghost orientation as moving down
1140  3a024d    ld      a,(#4d02)	; load A with pink ghost Y position
1143  fe80      cp      #80		; has the pink ghost eyes fully entered the ghost house?
1145  c0        ret     nz		; no, return

1146  212f2e    ld      hl,#2e2f	; yes, load HL with 2E, 2F location which is the center of the ghost house
1149  220c4d    ld      (#4d0c),hl	; store into pink ghost tile position
114c  22334d    ld      (#4d33),hl	; store into pink ghost tile position 2
114f  af        xor     a		; A := #00
1150  32a14d    ld      (#4da1),a	; set pink ghost substate as at home
1153  32ad4d    ld      (#4dad),a	; set pink ghost state as alive
1156  32a84d    ld      (#4da8),a	; set pink ghost blue flag as not edible
1159  c30111    jp      #1101		; jump to check for clearing eyes sound

; arrive here from #10AB when blue ghost (inky) is dead (eyes)

115c  cd861d    call    #1d86		; handle inky movement
115f  2a044d    ld      hl,(#4d04)	; load HL with blue ghost (inky) position
1162  116480    ld      de,#8064	; load DE with Y,X position above ghost house
1165  a7        and     a		; clear carry flag
1166  ed52      sbc     hl,de		; subtract.  are inky's eyes right above the ghost home?
1168  c0        ret     nz		; no, return

1169  21ae4d    ld      hl,#4dae	; yes, load HL with blue ghost (inky) state
116c  34        inc     (hl)		; increase
116d  c9        ret			; return

; arrive here from #10AB when blue ghost (inky) eyes are above and entering the ghost house when returning home

116e  dd210133  ld      ix,#3301	; load IX with direction address tiles for moving down
1172  fd21044d  ld      iy,#4d04	; load IY with inky position
1176  cd0020    call    #2000		; HL := (IX) + (IY)
1179  22044d    ld      (#4d04),hl	; store new position for inky
117c  3e01      ld      a,#01		; A := #01
117e  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving down
1181  322e4d    ld      (#4d2e),a	; set inky orientation as moving down
1184  3a044d    ld      a,(#4d04)	; load A with inky Y position
1187  fe80      cp      #80		; have the inky eyes fully entered the ghost house?
1189  c0        ret     nz		; no, return

118a  21ae4d    ld      hl,#4dae	; yes, load HL with blue ghost (inky) state 
118d  34        inc     (hl)		; increase
118e  c9        ret			; return

; arrive here from #10AB when inky ghost eyes have arrived in ghost house and when moving to left side of ghost house

118f  dd210333  ld      ix,#3303	; load IX with direction address tiles for moving left
1193  fd21044d  ld      iy,#4d04	; load IY with inky position
1197  cd0020    call    #2000		; HL := (IX) + (IY)
119a  22044d    ld      (#4d04),hl	; store new position for inky
119d  3e02      ld      a,#02		; A := #02
119f  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving left
11a2  322e4d    ld      (#4d2e),a	; set inky orientation as moving left
11a5  3a054d    ld      a,(#4d05)	; load A with inky X position
11a8  fe90      cp      #90		; has inky reached the left side of the ghost house?
11aa  c0        ret     nz		; no, return

11ab  212f30    ld      hl,#302f	; yes, load HL with #30, #2F for tile position inside ghost house
11ae  220e4d    ld      (#4d0e),hl	; store into inky tile position
11b1  22354d    ld      (#4d35),hl	; store into inky tile position 2
11b4  3e01      ld      a,#01		; A := #01
11b6  322a4d    ld      (#4d2a),a	; set previous inky orientation as moving down
11b9  322e4d    ld      (#4d2e),a	; set inky orientation as moving down
11bc  af        xor     a		; A := #00
11bd  32a24d    ld      (#4da2),a	; set inky substate as at home
11c0  32ae4d    ld      (#4dae),a	; set inky state as alive
11c3  32a94d    ld      (#4da9),a	; set inky blue flag as not edible
11c6  c30111    jp      #1101		; jump to check for clearing eyes sound

; arrive here from #10B7 when orange ghost is dead (eyes)

11c9  cd5d1e    call    #1e5d		; handle orange ghost movement
11cc  2a064d    ld      hl,(#4d06)	; load HL with orange ghost position
11cf  116480    ld      de,#8064	; load DE with Y,X position above ghost home
11d2  a7        and     a		; clear carry flag
11d3  ed52      sbc     hl,de		; subtract.  is orange ghost eyes right above ghost home?
11d5  c0        ret     nz		; no, return

11d6  21af4d    ld      hl,#4daf	; yes, load HL with orange ghost state
11d9  34        inc     (hl)		; increase
11da  c9        ret 			; return

; arrive here from #10B7 when orange ghost eyes are above and entering the ghost house when returning home

11db  dd210133  ld      ix,#3301	; load IX with direction address tiles for moving down
11df  fd21064d  ld      iy,#4d06	; load IY with orange ghost position 
11e3  cd0020    call    #2000		; HL := (IX) + (IY)
11e6  22064d    ld      (#4d06),hl	; store new position for orange ghost
11e9  3e01      ld      a,#01		; A := #01
11eb  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving down
11ee  322f4d    ld      (#4d2f),a	; set orange orientation as moving down
11f1  3a064d    ld      a,(#4d06)	; load A with orange ghost Y position
11f4  fe80      cp      #80		; has the orange ghost eyes fully entered the ghost house?
11f6  c0        ret     nz		; no, return

11f7  21af4d    ld      hl,#4daf	; yes, load HL with orange ghost state
11fa  34        inc     (hl)		; increase
11fb  c9        ret			; return

; arrive here from #10B7 when orange ghost eyes have arrived in ghost house and when moving to right side of ghost house

11fc  dd21ff32  ld      ix,#32ff	; load IX with direction address tiles for moving right
1200  fd21064d  ld      iy,#4d06	; load IY with orange ghost position 
1204  cd0020    call    #2000		; HL := (IX) + (IY)
1207  22064d    ld      (#4d06),hl	; store new position for orange ghost
120a  af        xor     a		; A := #00
120b  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving right
120e  322f4d    ld      (#4d2f),a	; set orange orientation as moving right
1211  3a074d    ld      a,(#4d07)	; load A with orange ghost X position
1214  fe70      cp      #70		; has the orange ghost reached the right side of the ghost house?
1216  c0        ret     nz		; no, return

1217  212f2c    ld      hl,#2c2f	; yes, load HL with tile position of the right side of ghost house
121a  22104d    ld      (#4d10),hl	; store into orange ghost tile position
121d  22374d    ld      (#4d37),hl	; store into orange ghost tile position 2
1220  3e01      ld      a,#01		; A := #01
1222  322b4d    ld      (#4d2b),a	; set previous orange ghost orientation as moving down
1225  322f4d    ld      (#4d2f),a	; set orange ghost orientation as moving down
1228  af        xor     a		; A := #00
1229  32a34d    ld      (#4da3),a	; set orange ghost substate as at home
122c  32af4d    ld      (#4daf),a	; set orange ghost state as alive
122f  32aa4d    ld      (#4daa),a	; set orange ghost blue flag as not edible
1232  c30111    jp      #1101		; jump to check for clearing eyes sound

; called from #1035
; arrive here when a ghost is eaten, or after the point score for eating a ghost is set to vanish

1235: 3A D1 4D	ld	a,(#4DD1)	; load A with killed ghost animation state
1238: E7 	rst  #20		; jump based on A

1239: 3F 12				; #123F	; a ghost is being eaten
123B: 0C 00				; #000C	; return immediately
123D: 3F 12				; #123F	; point score is set to vanish

123f  21004c    ld      hl,#4c00	; load HL with starting address for ghost sprites and colors
1242  3aa44d    ld      a,(#4da4)	; load A with # of ghost killed but no collision for yet
1245  87        add     a,a		; A := A * 2
1246  5f        ld      e,a		; store into E
1247  1600      ld      d,#00		; clear D
1249  19        add     hl,de		; add.  now HL has the sprite address of the ghost killed
124a  3ad14d    ld      a,(#4dd1)	; load A with killed ghost animation state
124d  a7        and     a		; is this ghost killed, showing points per kill ?
124e  2027      jr      nz,#1277        ; no, skip ahead

1250  3ad04d    ld      a,(#4dd0)	; yes, load A with current number of killed ghosts
1253  0627      ld      b,#27		; B := #27
1255  80        add     a,b		; add together to choose correct sprite (200, 400, 800 or 1600)
1256  47        ld      b,a		; store result into B
1257  3a724e    ld      a,(#4e72)	; load A with cocktail mode (0=no, 1=yes)
125a  4f        ld      c,a		; copy to C
125b  3a094e    ld      a,(#4e09)	; load A with current player number (0=P1, 1=P2)
125e  a1        and     c		; is this player 2 and cocktail mode ?
125f  2804      jr      z,#1265         ; no, skip next 2 steps

1261  cbf0      set     6,b		; set bit 6 of B
1263  cbf8      set     7,b		; set bit 7 of B

1265  70        ld      (hl),b		; store B into ghost sprite score
1266  23        inc     hl		; HL now has ghost sprite color
1267  3618      ld      (hl),#18	; store color #18
1269  3e00      ld      a,#00		; A := #00
126b  320b4c    ld      (#4c0b),a	; store into pacman sprite color
126e  f7        rst     #30		; set timed task to increase killed ghost animation state when a ghost is eaten
126f  4a 03 00				; task timer=#4A, task=3, param=0.  

; arrive here from task table when a ghost has been eaten.  Task #03, arrive from #0246

1272  21d14d    ld      hl,#4dd1	; load HL with killed ghost animation state
1275  34        inc     (hl)		; increase to next type
1276  c9        ret     		; return

; arrive here when score for eating a ghost is set to dissapear

1277: 36 20	ld	(hl),#20	; set ghost sprite to eyes
1279: 3E 09	ld	a,#09		; load A with #09
127B: 32 0B 4C	ld	(#4C0B),a	; store into pacman sprite color to restore pacman to screen
127E: 3A A4 4D	ld	a,(#4DA4)	; load A with # of ghost killed but no collision for yet
1281: 32 AB 4D	ld	(#4DAB),a	; store into killing ghost state
1284: AF	xor	a		; A := #00
1285: 32 A4 4D	ld	(#4DA4),a	; store into # of ghost killed but no collision for yet
1288: 32 D1 4D	ld	(#4DD1),a	; store into killed ghost animation state
128B: 21 AC 4E	ld	hl,#4EAC	; load HL with sound channel 2
128E: CB F6	set	6,(hl)		; play sound for ghost eyes
1290: C9	ret			; return

; called from #1017

1291: 3A A5 4D	ld	a,(#4DA5)	; load A with pacman dead animation state (0 if alive)
1294: E7	rst	#20		; jump based on A

1295: 0C 00				; #000C	; alive returns immediately
1297: B7 12				; #12B7	; increase counter
1299: B7 12				; #12B7	; increase counter
129B: B7 12				; #12B7	; increase counter
129D: B7 12				; #12B7	; increase counter
129F: CB 12				; #12CB	; animate dead mspac
12A1: F9 12				; #12F9	; animate dead mspac + start dying sound
12A3: 06 13				; #1306	; animate dead mspac
12A5: 0E 13				; #130E	; animate dead mspac
12A7: 16 13				; #1316	; animate dead mspac
12A9: 1E 13				; #131E	; animate dead mspac
12AB: 26 13				; #1326	; animate dead mspac
12AD: 2E 13				; #132E	; animate dead mspac
12AF: 36 13				; #1336	; animate dead mspac
12B1: 3E 13				; #133E	; animate dead mspac
12B3: 46 13				; #1346	; animate dead mspac + clear sound
12B5: 53 13				; #1353	; animate last time, decrease lives, clear ghosts, increase game state


12b7  2ac54d    ld      hl,(#4dc5)	; load HL with counter started after pacman killed
12ba  23        inc     hl		; increase counter
12bb  22c54d    ld      (#4dc5),hl	; store counter
12be  117800    ld      de,#0078	; load DE with counter timer result 
12c1  a7        and     a		; clear carry flag
12c2  ed52      sbc     hl,de		; is the counter == #78 ?
12c4  c0        ret     nz		; no, return

12c5  3e05      ld      a,#05		; yes, A := #05
12c7  32a54d    ld      (#4da5),a	; store into pacman dead animation state (0 if not dead)
12ca  c9        ret     		; return (to #101A)

	; adjust mspac sprite animation while dying

12cb  210000    ld      hl,#0000	; HL := #0000
12ce  cd7e26    call    #267e		; clears #4d00 through #4d07
12d1  3e34      ld      a,#34		; A := #34
12d3  11b400    ld      de,#00b4	; DE := #00B4

12d6  4f        ld      c,a		; Copy A into C
12d7  3a724e    ld      a,(#4e72)	; load A with cocktail mode (0=no, 1=yes)
12da  47        ld      b,a		; copy cocktail mode into B
12db  3a094e    ld      a,(#4e09)	; load A with current player number
12de  a0        and     b		; mix with cocktail mode.  Is this player 2 and cocktail mode ?
12df  2804      jr      z,#12e5         ; no, skip ahead

12e1  3ec0      ld      a,#c0		; yes, A := #C0
12e3  b1        or      c		; OR with C which has mspac sprite # in it
12e4  4f        ld      c,a		; store result into C

; death animation display
12e5  79        ld      a,c		; A := C
12e6  320a4c    ld      (#4c0a),a	; store into mspac sprite number
12e9  2ac54d    ld      hl,(#4dc5)	; load HL with counter started after pacman killed
12ec  23        inc     hl		; increase counter
12ed  22c54d    ld      (#4dc5),hl	; store counter
12f0  a7        and     a		; clear carry flag
12f1  ed52      sbc     hl,de		; is the counter == DE ?
12f3  c0        ret     nz		; no, return

12f4  21a54d    ld      hl,#4da5	; yes, load HL with pacman dead animation state
12f7  34        inc     (hl)		; increase pacman dead animation state
12f8  c9        ret     		; return

12F9: 21 BC 4E	ld	hl,#4EBC	; load HL with sound channel 3
12FC: CB E6	set	4,(hl)		; set dying sound
12fe  3e35      ld      a,#35		; mspac sprite := #35  Frame 1
1300  11c300    ld      de,#00c3	; timer := #C3
1303  c3d612    jp      #12d6		; animate dead mspac

1306  3e36      ld      a,#36		; mspac sprite := #36  Frame 2
1308  11d200    ld      de,#00d2	; timer := #D2
130b  c3d612    jp      #12d6		; animate dead mspac

130e  3e37      ld      a,#37		; mspac sprite := #37  Frame 3
1310  11e100    ld      de,#00e1	; timer := #E1
1313  c3d612    jp      #12d6		; animate dead mspac

1316  3e38      ld      a,#38		; mspac sprite := #38  Frame 4
1318  11f000    ld      de,#00f0	; timer := #F0
131b  c3d612    jp      #12d6		; animate dead mspac

131e  3e39      ld      a,#39		; mspac sprite := #39  Frame 5
1320  11ff00    ld      de,#00ff	; timer := #FF
1323  c3d612    jp      #12d6		; animate dead mspac

1326  3e3a      ld      a,#3a		; mspac sprite := #3A  Frame 6
1328  110e01    ld      de,#010e	; timer := #10E
132b  c3d612    jp      #12d6		; animate dead mspac

132e  3e3b      ld      a,#3b		; mspac sprite := #3B  Frame 7
1330  111d01    ld      de,#011d	; timer := #11D
1333  c3d612    jp      #12d6		; animate dead mspac

1336  3e3c      ld      a,#3c		; mspac sprite := #3C  Frame 8
1338  112c01    ld      de,#012c	; timer := #12C
133b  c3d612    jp      #12d6		; animate dead mspac

133e  3e3d      ld      a,#3d		; mspac sprite := #3D  Frame 9
1340  113b01    ld      de,#013b	; timer := #13B
1343  c3d612    jp      #12d6		; animate dead mspac

1346: 21 BC 4E	ld	hl,#4EBC	; load HL with sound channel 3
1349: 36 00	ld	(hl),#00	; clear sound
134b  3e3e      ld      a,#3e		; mspac sprite = #3E  Frame 10
134d  115901    ld      de,#0159	; timer := #159
1350  c3d612    jp      #12d6		; animate dead mspac

1353  3e3f      ld      a,#3f		; A := #3F
1355  320a4c    ld      (#4c0a),a	; store into mspac sprite number
1358  2ac54d    ld      hl,(#4dc5)	; load HL with counter started after pacman killed
135b  23        inc     hl		; increase timer
135c  22c54d    ld      (#4dc5),hl	; store timer
135f  11b801    ld      de,#01b8	; load timer check with #01B8
1362  a7        and     a		; clear carry flag
1363  ed52      sbc     hl,de		; is timer == #01B8 ?
1365  c0        ret     nz		; no, return

	; decrement lives
	; this gets called after the death animation, but before the screen gets redrawn.
	; -- probably a good hook point for 'insert coin to contunue' --

1366  21144e    ld      hl,#4e14	; load HL with number of lives left
1369  35        dec     (hl)		; subtract 1
136a  21154e    ld      hl,#4e15	; load HL with number of lives on screen
136d  35        dec     (hl)		; subtract 1
136e  cd7526    call    #2675		; clears all ghosts
1371  21044e    ld      hl,#4e04	; load HL with game state.  
1374  34        inc     (hl)		; increase game state
1375  c9        ret     		; return


	;; routine to control blue time
	;; ret immediately to make ghosts stay blue till eaten 

1376  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
1379  a7        and     a		; is a power pill active ?
137a  c8        ret     z		; no, return

137b  dd21a74d  ld      ix,#4da7	; yes, load IX with ghost blue flag starting address
137f  dd7e00    ld      a,(ix+#00)	; load A with red ghost blue flag
1382  ddb601    or      (ix+#01)	; OR with pink ghost blue flag
1385  ddb602    or      (ix+#02)	; OR with blue ghost (inky) blue flag
1388  ddb603    or      (ix+#03)	; OR with oragne ghost blue flag
138b  ca9813    jp      z,#1398		; if all ghosts are not blue, then skip ahead and reset power pill effect

138e  2acb4d    ld      hl,(#4dcb)	; else load HL with blue ghost counter
1391  2b        dec     hl		; count down
1392  22cb4d    ld      (#4dcb),hl	; store result
1395  7c        ld      a,h		; load A with counter high byte
1396  b5        or      l		; or with counter low byte.  are both counters at #00 ?
1397  c0        ret     nz		; no, return

; arrive here when power pill effect is over, either by timer or by eating all ghosts

1398  210b4c    ld      hl,#4c0b	; load HL with pacman color entry
139b  3609      ld      (hl),#09	; store #09 into pacman color entry
139d  3aac4d    ld      a,(#4dac)	; load A with red ghost state
13a0  a7        and     a		; is red ghost alive ?
13a1  c2a713    jp      nz,#13a7	; yes, skip next step

13a4  32a74d    ld      (#4da7),a	; clear red ghost blue state

13a7  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
13aa  a7        and     a		; is pink ghost alive ?
13ab  c2b113    jp      nz,#13b1	; yes, skip next step

13ae  32a84d    ld      (#4da8),a	; clear pink ghost blue state

13b1  3aae4d    ld      a,(#4dae)	; load A with blue ghost (inky) state
13b4  a7        and     a		; is inky alive ?
13b5  c2bb13    jp      nz,#13bb	; yes, skip next step

13b8  32a94d    ld      (#4da9),a	; clear inky blue state

13bb  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
13be  a7        and     a		; is orange ghost alive ?
13bf  c2c513    jp      nz,#13c5	; yes, skip next step

13C2: 32 AA 4D	ld	(#4DAA),a	; clear orange ghost blue state

13C5: AF	xor	a		; A := #00
13C6: 32 CB 4D	ld	(#4DCB),a	; clear counter while ghosts are blue
13C9: 32 CC 4D	ld	(#4DCC),a	; clear counter while ghosts are blue
13CC: 32 A6 4D	ld	(#4DA6),a	; clear pill effect
13CF: 32 C8 4D	ld	(#4DC8),a	; clear counter used to change ghost colors under big pill effects
13D2: 32 D0 4D	ld	(#4DD0),a	; clear current number of killed ghosts
13D5: 21 AC 4E	ld	hl,#4EAC	; load HL with sound channel 2
13D8: CB AE	res	5,(hl)		; clear sound bit 5
13DA: CB BE	res	7,(hl)		; clear sound bit 7
13DC: C9	ret			; return

; arrive here from call at #08F1

13dd  219e4d    ld      hl,#4d9e	; load HL with address related to number of pills eaten before last pacman move
13e0  3a0e4e    ld      a,(#4e0e)	; load A with # of pills eaten
13e3  be        cp      (hl)		; are they equal ?
13e4  caee13    jp      z,#13ee		; yes, skip ahead

13e7  210000    ld      hl,#0000	; else HL := #0000
13ea  22974d    ld      (#4d97),hl	; clear inactivity counter
13ed  c9        ret     		; return

13ee  2a974d    ld      hl,(#4d97)	; load HL with inactivity counter
13f1  23        inc     hl		; increment
13f2  22974d    ld      (#4d97),hl	; store
13f5  ed5b954d  ld      de,(#4d95)	; load DE with number of units before ghost leaves home (no change w/ pills)
13f9  a7        and     a		; clear carry flag
13fa  ed52      sbc     hl,de		; subtract.  are they equal ?
13fc  c0        ret     nz		; no, return

13fd  210000    ld      hl,#0000	; else HL := #0000
1400  22974d    ld      (#4d97),hl	; clear inactivity counter
1403  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
1406  a7        and     a		; is pink ghost in the ghost house ?
1407  f5        push    af		; save AF
1408  cc8620    call    z,#2086		; yes, then call this sub which will release the pink ghost
140b  f1        pop     af		; restore AF
140c  c8        ret     z		; yes, then return

140d  3aa24d    ld      a,(#4da2)	; else load A with blue (inky) ghost state
1410  a7        and     a		; is inky in the ghost house ?
1411  f5        push    af		; save AF
1412  cca920    call    z,#20a9		; yes, then call this sub which will release Inky
1415  f1        pop     af		; restore AF
1416  c8        ret     z		; yes, then return

1417  3aa34d    ld      a,(#4da3)	; else load A with orange ghost state
141a  a7        and     a		; is orange ghost in the ghost house?
141b  ccd120    call    z,#20d1		; yes, then call this sub which will release orange ghost
141e  c9        ret     		; return

; arrive here from #01A1
; during core game loop

141f  3a724e    ld      a,(#4e72)	; load A with cocktail mode (0=no, 1=yes)
1422  47        ld      b,a		; copy to B
1423  3a094e    ld      a,(#4e09)	; load A with player #
1426  a0        and     b		; is cocktail mode on and and player 2 playing?
1427  c8        ret     z		; no, return

; yes, handle sprite flips

1428  47        ld      b,a		; B := #01
1429  dd21004c  ld      ix,#4c00	; load IX with start of sprite address
142d  1e08      ld      e,#08		; E := #08
142f  0e08      ld      c,#08		; C := #08
1431  1607      ld      d,#07		; D := #07
1433  3a004d    ld      a,(#4d00)	; load A with red ghost Y position
1436  83        add     a,e		; add #08
1437  dd7713    ld      (ix+#13),a	; store into #4C13 (?)
143a  3a014d    ld      a,(#4d01)	; load A with red ghost X position
143d  2f        cpl     		; invert
143e  82        add     a,d		; add #07
143f  dd7712    ld      (ix+#12),a	; store into #4C12 (?)
1442  3a024d    ld      a,(#4d02)	; load A with pink ghost Y position
1445  83        add     a,e		; add #08
1446  dd7715    ld      (ix+#15),a	; store into #4C15 (?)
1449  3a034d    ld      a,(#4d03)	; load A with pink ghost X position
144c  2f        cpl     		; invert
144d  82        add     a,d		; add #07
144e  dd7714    ld      (ix+#14),a	; store into #4C14 (?)
1451  3a044d    ld      a,(#4d04)	; load A with inky Y position
1454  83        add     a,e		; add #08
1455  dd7717    ld      (ix+#17),a	; store into #4C17 (?)
1458  3a054d    ld      a,(#4d05)	; load A with inky X position
145b  2f        cpl     		; invert
145c  81        add     a,c		; add #08
145d  dd7716    ld      (ix+#16),a	; store into #4C16 (?)
1460  3a064d    ld      a,(#4d06)	; load A with orange ghost Y position
1463  83        add     a,e		; add #08
1464  dd7719    ld      (ix+#19),a	; store into #4C19 (?)
1467  3a074d    ld      a,(#4d07)	; load A with orange ghost X position
146a  2f        cpl     		; invert
146b  81        add     a,c		; add #08
146c  dd7718    ld      (ix+#18),a	; store into #4C18 (?)
146f  3a084d    ld      a,(#4d08)	; load A with pacman Y position
1472  83        add     a,e		; add #08
1473  dd771b    ld      (ix+#1b),a	; store into #4C1B (?)
1476  3a094d    ld      a,(#4d09)	; load A with pacman X position
1479  2f        cpl     		; invert
147a  81        add     a,c		; add #08
147b  dd771a    ld      (ix+#1a),a	; store into #4C1A (?)
147e  3ad24d    ld      a,(#4dd2)	; load A with fruit Y position
1481  83        add     a,e		; add #08
1482  dd771d    ld      (ix+#1d),a	; store into #4C1D (?)
1485  3ad34d    ld      a,(#4dd3)	; load A with fruit X position
1488  2f        cpl     		; invert
1489  81        add     a,c		; add #08
148a  dd771c    ld      (ix+#1c),a	; store into #4C1C (?)
148d  c3fe14    jp      #14fe		; jump ahead

; called from #019E during core game loop
; display the sprites in the intro and game and cutscenes

1490  3a724e    ld      a,(#4e72)	; load A with cocktail mode
1493  47        ld      b,a		; store into B
1494  3a094e    ld      a,(#4e09)	; load A with player number
1497  a0        and     b		; is this player 2 and cocktail mode ?
1498  c0        ret     nz		; yes, return

1499  47        ld      b,a		; B := #00
149a  1e09      ld      e,#09		; E := #09
149c  0e07      ld      c,#07		; C := #07
149e  1606      ld      d,#06		; D := #06
14a0  dd21004c  ld      ix,#4c00	; load IX with starting address of sprite values

14a4  3a004d    ld      a,(#4d00)	; load A with red ghost Y position
14a7  2f        cpl			; invert A
14a8  83        add     a,e		; Add #09
14a9  dd7713    ld      (ix+#13),a	; store into #4C13 (?)

14ac  3a014d    ld      a,(#4d01)	; load A with red ghost X position
14af  82        add     a,d		; add #06
14b0  dd7712    ld      (ix+#12),a	; store into #4C12 (?)

14b3  3a024d    ld      a,(#4d02)	; load A with pink ghost Y position
14b6  2f        cpl     		; invert
14b7  83        add     a,e		; add #09
14b8  dd7715    ld      (ix+#15),a	; store into #4C15 (?)

14bb  3a034d    ld      a,(#4d03)	; load A with pink ghost X position
14be  82        add     a,d		; add #06
14bf  dd7714    ld      (ix+#14),a	; store into #4C14 (?)

14c2  3a044d    ld      a,(#4d04)	; load A with inky Y position
14c5  2f        cpl     		; invert
14c6  83        add     a,e		; add #06
14c7  dd7717    ld      (ix+#17),a	; store into #4C17 (?)

14ca  3a054d    ld      a,(#4d05)	; load A with inky X position
14cd  81        add     a,c		; add #07
14ce  dd7716    ld      (ix+#16),a	; store into #4C16 (?)

14d1  3a064d    ld      a,(#4d06)	; load A with orange ghost Y position
14d4  2f        cpl     		; invert
14d5  83        add     a,e		; add #09
14d6  dd7719    ld      (ix+#19),a	; store into #4C19 (?)

14d9  3a074d    ld      a,(#4d07)	; load A with orange ghost X position
14dc  81        add     a,c		; add #07
14dd  dd7718    ld      (ix+#18),a	; store into #4C18 (?)

14e0  3a084d    ld      a,(#4d08)	; load A with pacman Y position
14e3  2f        cpl     		; invert
14e4  83        add     a,e		; add #09
14e5  dd771b    ld      (ix+#1b),a	; store into #4C1B (?)

14e8  3a094d    ld      a,(#4d09)	; load A with pacman X position
14eb  81        add     a,c		; add #07
14ec  dd771a    ld      (ix+#1a),a	; store into #4C1A (?)

14ef  3ad24d    ld      a,(#4dd2)	; load A with fruit Y position
14f2  2f        cpl     		; invert
14f3  83        add     a,e		; add #09
14f4  dd771d    ld      (ix+#1d),a	; store into #4C1D (?)

14f7  3ad34d    ld      a,(#4dd3)	; load A with fruit X position
14fa  81        add     a,c		; add #07
14fb  dd771c    ld      (ix+#1c),a	; store into #4C1C (?)

; also arrive here if player 2 and cocktail mode from #148D

14fe  3aa54d    ld      a,(#4da5)	; load A with pacman dead animation state (0 if not dead)
1501  a7        and     a		; is pacman dead ?
1502  c24b15    jp      nz,#154b	; yes, jump ahead

1505  3aa44d    ld      a,(#4da4)	; no, load A with # of ghost killed but no collision for yet
1508  a7        and     a		; are we currently eating a ghost ?
1509  c2b415    jp      nz,#15b4	; yes, jump ahead

150c  211c15    ld      hl,#151c	; no, load HL with return address
150f  e5        push    hl		; push return address to stack so RET comes back to #151C

1510: 3A 30 4D	ld	a,(#4D30)	; load A with pacman orientation
1513: E7	rst	#20		; jump based on which way pac man is facing - for drawing sprite frames to the screen

1514: 8C 16				; #168C	; right
1516: B1 16				; #16B1	; down
1518: D6 16				; #16D6	; left
151A: F7 16				; #16F7	; up

151C: 78	ld	a,b		; load A with B which was created earlier to indicate 2 player and cocktail
151D: A7	and	a		; is this player 2 and cocktail mode ?
151e  282b      jr      z,#154b         ; no, skip ahead

1520  0ec0      ld      c,#c0		; yes, C := #C0
1522  3a0a4c    ld      a,(#4c0a)	; load A with mspac sprite number
1525  57        ld      d,a		; copy into D
1526  a1        and     c		; apply mask of #1100 0000 = #C0
1527  2005      jr      nz,#152e        ; not zero, skip ahead

1529  7a        ld      a,d		; zero, load A with original value
152a  b1        or      c		; turn on bits 7 and 6
152b  c34815    jp      #1548		; skip ahead

152e  3a304d    ld      a,(#4d30)	; load A with pacman orientation
1531  fe02      cp      #02		; pacman facing left ?
1533  2009      jr      nz,#153e        ; no, skip ahead

1535  cb7a      bit     7,d		; yes, turn on bit 7 of D
1537  2812      jr      z,#154b         ; if zero, skip ahead

1539  7a        ld      a,d		; else A := D
153a  a9        xor     c		; flip bits 6 and 7
153b  c34815    jp      #1548		; skip ahead

153e  fe03      cp      #03		; pacman facing up ?
1540  2009      jr      nz,#154b        ; no, skip ahead

1542  cb72      bit     6,d		; yes, turn on bit 6 of D
1544  2805      jr      z,#154b         ; if zero, skip ahead

1546  7a        ld      a,d		; else A := D
1547  a9        xor     c		; flip bits 6 and 7

1548  320a4c    ld      (#4c0a),a	; store result into mspac sprite number

; the next section of code toggles the sprites for the ghosts based on the counter that flips every 8 frames

154b  21c04d    ld      hl,#4dc0	; load HL with counter that changes from 0 to 1 and back every 8 frames; used for ghost animations
154e  56        ld      d,(hl)		; load D with the counter
154f  3e1c      ld      a,#1c		; A := #1C
1551  82        add     a,d		; add to counter

; toggle between #1C and #1D (edible ghost sprites) for all ghosts ... those that are not edible are changed again later

1552  dd7702    ld      (ix+#02),a	; store into red ghost sprite
1555  dd7704    ld      (ix+#04),a	; store into pink ghost sprite
1558  dd7706    ld      (ix+#06),a	; store into inky sprite
155b  dd7708    ld      (ix+#08),a	; store into orange ghost sprite
155e  0e20      ld      c,#20		; C := #20

1560  3aac4d    ld      a,(#4dac)	; load A with red ghost state
1563  a7        and     a		; is red ghost alive ?
1564  2006      jr      nz,#156c        ; no, skip next 3 steps

1566  3aa74d    ld      a,(#4da7)	; yes, load A with red ghost blue flag (0=not blue)
1569  a7        and     a		; is red ghost blue (edible) ?
156a  2009      jr      nz,#1575        ; yes, skip ahead and check next ghost

156c  3a2c4d    ld      a,(#4d2c)	; no, load A with red ghost orientation
156f  87        add     a,a		; A := A * 2
1570  82        add     a,d		; A := A + D
1571  81        add     a,c		; A := A + #20
1572  dd7702    ld      (ix+#02),a	; store into red ghost sprite

1575  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
1578  a7        and     a		; is pink ghost alive ?
1579  2006      jr      nz,#1581        ; no, skip next 3 steps

157b  3aa84d    ld      a,(#4da8)	; load A with pink ghost blue flag
157e  a7        and     a		; is pink ghost blue (edible) ?
157f  2009      jr      nz,#158a        ; yes, skip ahead and check next ghost

1581  3a2d4d    ld      a,(#4d2d)	; no, load A with pink ghost orientation
1584  87        add     a,a		; A := A * 2
1585  82        add     a,d		; A := A + D
1586  81        add     a,c		; A := A + #20
1587  dd7704    ld      (ix+#04),a	; store into pink ghost sprite

158a  3aae4d    ld      a,(#4dae)	; load A with inky state
158d  a7        and     a		; is inky alive ?
158e  2006      jr      nz,#1596        ; no, skip next 3 steps

1590  3aa94d    ld      a,(#4da9)	; load A with inky blue flag
1593  a7        and     a		; is inky edible ?
1594  2009      jr      nz,#159f        ; yes, skip ahead and check next ghost

1596  3a2e4d    ld      a,(#4d2e)	; no, load A with inky orientation
1599  87        add     a,a		; A := A * 2
159a  82        add     a,d		; A := A + D
159b  81        add     a,c		; A := A + #20
159c  dd7706    ld      (ix+#06),a	; store into inky sprite

159f  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
15a2  a7        and     a		; is orange ghost alive ?
15a3  2006      jr      nz,#15ab        ; no, skip next 3 steps

15a5  3aaa4d    ld      a,(#4daa)	; load A with orange ghost blue flag
15a8  a7        and     a		; is orange ghost blue (edible) ?
15a9  2009      jr      nz,#15b4        ; yes, skip ahead

15ab  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost orienation
15ae  87        add     a,a		; A = A * 2
15af  82        add     a,d		; A = A + D
15b0  81        add     a,c		; A = A + #20
15b1  dd7708    ld      (ix+#08),a	; store into orange ghost sprite

15b4  cde615    call    #15e6		; check for and handle big pac-man sprites in 1st cutscene (pac-man only)
15b7  cd2d16    call    #162d		; check for and handle sprites in 2nd cutscene (pac-man only)
15ba  cd5216    call    #1652		; check for and handle sprites in 3rd cutscene (pac-man only)
15bd  78        ld      a,b		; A := B
15be  a7        and     a		; is this player 2 and cocktail mode ?
15bf  c8        ret     z		; no, return

; 2 player and cocktail

15c0  0ec0      ld      c,#c0		; C := #C0 (binary 1100 0000)

15c2  3a024c    ld      a,(#4c02)	; load A with red ghost sprite
15c5  b1        or      c		; make upside down
15c6  32024c    ld      (#4c02),a	; store

15c9  3a044c    ld      a,(#4c04)	; load A with pink ghost sprite
15cc  b1        or      c		; make upside down
15cd  32044c    ld      (#4c04),a	; store

15d0  3a064c    ld      a,(#4c06)	; load A with inky sprite
15d3  b1        or      c		; make upside down
15d4  32064c    ld      (#4c06),a	; store

15d7  3a084c    ld      a,(#4c08)	; load A with orange ghost sprite
15da  b1        or      c		; make upside down
15db  32084c    ld      (#4c08),a	; store

15de  3a0c4c    ld      a,(#4c0c)	; load A with pacman sprite
15e1  b1        or      c		; make upside down
15e2  320c4c    ld      (#4c0c),a	; store
15e5  c9        ret     		; return

; called from #15B4

15e6  3a064e    ld      a,(#4e06)	; load A with state in first cutscene
15e9  d605      sub     #05		; is this cutscene state <= 5 ?
15eb  d8        ret     c		; yes, return

; pac-man only, not used in ms. pac
; arrive here when the big pac-man needs to be animated in the 1st cutscene

15ec  3a094d    ld      a,(#4d09)
15ef  e60f      and     #0f
15f1  fe0c      cp      #0c
15f3  3804      jr      c,#15f9         ; (4)

15f5  1618      ld      d,#18
15f7  1812      jr      #160b           ; (18)

15f9  fe08      cp      #08
15fb  3804      jr      c,#1601         ; (4)

15fd  1614      ld      d,#14
15ff  180a      jr      #160b           ; (10)

1601  fe04      cp      #04
1603  3804      jr      c,#1609         ; (4)

1605  1610      ld      d,#10
1607  1802      jr      #160b           ; (2)

1609  1614      ld      d,#14
160b  dd7204    ld      (ix+#04),d
160e  14        inc     d
160f  dd7206    ld      (ix+#06),d
1612  14        inc     d
1613  dd7208    ld      (ix+#08),d
1616  14        inc     d
1617  dd720c    ld      (ix+#0c),d
161a  dd360a3f  ld      (ix+#0a),#3f
161e  1616      ld      d,#16
1620  dd7205    ld      (ix+#05),d
1623  dd7207    ld      (ix+#07),d
1626  dd7209    ld      (ix+#09),d
1629  dd720d    ld      (ix+#0d),d
162c  c9        ret     

; called from #15B7

162d  3a074e    ld      a,(#4e07)	; load A with state in second cutscene
1630  a7        and     a		; == #00 ?
1631  c8        ret     z		; yes, return

; pac-man only, not used in ms. pac
; arrive here during 2nd cutscene

1632  57        ld      d,a
1633  3a3a4d    ld      a,(#4d3a)
1636  d63d      sub     #3d
1638  2004      jr      nz,#163e        ;

163a  dd360b00  ld      (ix+#0b),#00
163e  7a        ld      a,d
163f  fe0a      cp      #0a
1641  d8        ret     c

1642  dd360232  ld      (ix+#02),#32
1646  dd36031d  ld      (ix+#03),#1d
164a  fe0c      cp      #0c
164c  d8        ret     c

164d  dd360233  ld      (ix+#02),#33
1651  c9        ret     

; called from #15BA

1652  3a084e    ld      a,(#4e08)	; load A with state in third cutscene
1655  a7        and     a		; == #00 ?
1656  c8        ret     z		; yes, return

; pac-man only, not used is ms. pac
; arrive here during 3rd cutscene

1657  57        ld      d,a
1658  3a3a4d    ld      a,(#4d3a)
165b  d63d      sub     #3d
165d  2004      jr      nz,#1663        ; (4)

165f  dd360b00  ld      (ix+#0b),#00
1663  7a        ld      a,d
1664  fe01      cp      #01
1666  d8        ret     c

1667  3ac04d    ld      a,(#4dc0)
166a  1e08      ld      e,#08
166c  83        add     a,e
166d  dd7702    ld      (ix+#02),a
1670  7a        ld      a,d
1671  fe03      cp      #03
1673  d8        ret     c

1674  3a014d    ld      a,(#4d01)
1677  e608      and     #08
1679  0f        rrca    
167a  0f        rrca    
167b  0f        rrca    
167c  1e0a      ld      e,#0a
167e  83        add     a,e
167f  dd770c    ld      (ix+#0c),a
1682  3c        inc     a
1683  3c        inc     a
1684  dd7702    ld      (ix+#02),a
1687  dd360d1e  ld      (ix+#0d),#1e
168b  c9        ret     


; arrive here when pac man is facing right from #1513

; MOVING EAST
168c  c39c86    jp      #869c		; jump to ms. pacman patch to animate ms pac
168f  c9        ret     

1690  07				; junk from pac-man    
1691  fe06      cp      #06
1693  3805      jr      c,#169a         ;
1695  dd360a30  ld      (ix+#0a),#30
1699  c9        ret     

169a  fe04      cp      #04
169c  3805      jr      c,#16a3         ;
169e  dd360a2e  ld      (ix+#0a),#2e
16a2  c9        ret     

16a3  fe02      cp      #02
16a5  3805      jr      c,#16ac         ;
16a7  dd360a2c  ld      (ix+#0a),#2c
16ab  c9        ret     

16ac  dd360a2e  ld      (ix+#0a),#2e
16b0  c9        ret 

; arrive here when pac man is facing down from #1513
; MOVING SOUTH
16b1  c3b186    jp      #86b1		; jump to ms. pacman patch to animate ms pac
16b4  c9        ret     

16b5  07				; junk from pac-man    
16b6  fe06      cp      #06
16b8  3805      jr      c,#16bf         ;
16ba  dd360a2f  ld      (ix+#0a),#2f
16be  c9        ret     

16bf  fe04      cp      #04
16c1  3805      jr      c,#16c8         ;
16c3  dd360a2d  ld      (ix+#0a),#2d
16c7  c9        ret     

16c8  fe02      cp      #02
16ca  3805      jr      c,#16d1         ;
16cc  dd360a2f  ld      (ix+#0a),#2f
16d0  c9        ret     

16d1  dd360a30  ld      (ix+#0a),#30
16d5  c9        ret

; arrive here when pac man is facing left from #1513
; MOVING WEST
16d6  3a094d    ld      a,(#4d09)
16d9  c3c586    jp      #86c5		; jump to ms. pacman patch to animate ms pac
16dc  c9        ret     

16dd  3808      jr      c,#16e7         ;
16df  1e2e      ld      e,#2e
16e1  cbfb      set     7,e
16e3  dd730a    ld      (ix+#0a),e
16e6  c9        ret     

16e7  fe04      cp      #04
16e9  3804      jr      c,#16ef         ;
16eb  1e2c      ld      e,#2c
16ed  18f2      jr      #16e1           ;
16ef  fe02      cp      #02

16f1  30ec      jr      nc,#16df        ;
16f3  1e30      ld      e,#30
16f5  18ea      jr      #16e1           ;

; arrive here when pac man is facing up from #1513
; MOVING NORTH
16f7  3a084d    ld      a,(#4d08)
16fa  c3d986    jp      #86d9		; jump to ms. pacman patch to animate ms pac

16fd  c9        ret     

16fe  3805      jr      c,#1705         ;
1700  dd360a30  ld      (ix+#0a),#30
1704  c9        ret     

1705  fe04      cp      #04
1707  3808      jr      c,#1711         ; (8)
1709  1e2f      ld      e,#2f
170b  cbf3      set     6,e
170d  dd730a    ld      (ix+#0a),e
1710  c9        ret     

1711  fe02      cp      #02
1713  3804      jr      c,#1719         ; (4)

1715  1e2d      ld      e,#2d
1717  18f2      jr      #170b           ; (-14)

1719  1e2f      ld      e,#2f
171b  18ee      jr      #170b           ; (-18)


	;; normal ghost collision detect
	;; called from #1039

171d  0604      ld      b,#04		; B := #04
171f  ed5b394d  ld      de,(#4d39)	; load DE with pacman Y and X tile positions
1723  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
1726  a7        and     a		; is orange ghost alive ?
1727  2009      jr      nz,#1732        ; no, skip ahead for next ghost

1729  2a374d    ld      hl,(#4d37)	; else load HL with orange ghost Y and X tile positions
172c  a7        and     a		; clear the carry flag
172d  ed52      sbc     hl,de		; is pacman colliding with orange ghost?
172f  ca6317    jp      z,#1763		; yes, jump ahead and continue checks

1732  05        dec     b		; B := #03
1733  3aae4d    ld      a,(#4dae)	; load A with blue ghost (inky) state
1736  a7        and     a		; is inky alive ?
1737  2009      jr      nz,#1742        ; no, skip ahead for next ghost

1739  2a354d    ld      hl,(#4d35)	; else load HL with inky's Y and X tile positions
173c  a7        and     a		; clear carry flag
173d  ed52      sbc     hl,de		; is pacman colliding with inky ?
173f  ca6317    jp      z,#1763		; yes, jump ahead and continue checks

1742  05        dec     b		; B := #02
1743  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
1746  a7        and     a		; is pink ghost alive ?
1747  2009      jr      nz,#1752        ; no, skip ahead

1749  2a334d    ld      hl,(#4d33)	; else load HL with pink ghost Y and X tile positions
174c  a7        and     a		; clear carry flag
174d  ed52      sbc     hl,de		; is pacman colliding with pink ghost?
174f  ca6317    jp      z,#1763		; yes, jump ahead and continue checks

1752  05        dec     b		; B := #01
1753  3aac4d    ld      a,(#4dac)	; load A with red ghost state
1756  a7        and     a		; is red ghost alive ?
1757  2009      jr      nz,#1762        ; no, skip ahead

1759  2a314d    ld      hl,(#4d31)	; else load HL with red ghost Y and X tile positions
175c  a7        and     a		; clear carry flag
175d  ed52      sbc     hl,de		; is pacman colliding with red ghost?
175f  ca6317    jp      z,#1763		; yes, jump ahead and continue checks

1762  05        dec     b		; B := #00 , no collision occurred

1763  78        ld      a,b		; load A with ghost # that collided with pacman
1764  32a44d    ld      (#4da4),a	; store

	; invincibility check ; HACK3
	; 1764 c3b01f    jp      #1fb0
	;

1767  32a54d    ld      (#4da5),a	; store into pacman dead animation state (0 if not dead)
176a  a7        and     a		; was there a collision?
176b  c8        ret     z		; no, return

176c  21a64d    ld      hl,#4da6	; else load HL with start of ghost flags
176f  5f        ld      e,a		; load E with ghost # that collided
1770  1600      ld      d,#00		; D := #00
1772  19        add     hl,de		; add.  HL now has the ghost blue flag (0 if not blue)
1773  7e        ld      a,(hl)		; load A with the ghost's status
1774  a7        and     a		; is this ghost blue (eatable) ?
1775  c8        ret     z		; no, return

; else arrive here when eating a blue ghost

1776  af        xor     a		; A := #00
1777  32a54d    ld      (#4da5),a	; store into pacman dead animation state (0 if not dead)
177a  21d04d    ld      hl,#4dd0	; load HL with # of ghosts killed
177d  34        inc     (hl)		; increase
177e  46        ld      b,(hl)		; load B with this # of ghosts killed
177f  04        inc     b		; increase by one, used for scoring routine
1780  cd5a2a    call    #2a5a		; update score.  B has code for items scored. draws score on screen, checks for high score and extra lives

1783: 21 BC 4E	ld	hl,#4EBC	; load HL with sound channel 3
1786: CB DE	set	3,(hl)		; set sound for eating a ghost
1788: C9	ret			; return

	;; end normal ghost collision detect


	;; blue (edible) ghost collision detect

; called from #103C

1789  3aa44d    ld      a,(#4da4)	; load A with ghost # that collided with pacman (0=no collision)
178c  a7        and     a		; was there a collision ?
178d  c0        ret     nz		; yes, return

178e  3aa64d    ld      a,(#4da6)	; no, load A with power pill status
1791  a7        and     a		; is a power pill active ?
1792  c8        ret     z		; no, return

1793  0e04      ld      c,#04		; else C := #04
1795  0604      ld      b,#04		; B := #04
1797  dd21084d  ld      ix,#4d08	; load IX with pacman Y position
179b  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
179e  a7        and     a		; is ghost alive ?
179f  2013      jr      nz,#17b4        ; no, skip ahead for next ghost

17a1  3a064d    ld      a,(#4d06)	; yes, load A with orange ghost Y position
17a4  dd9600    sub     (ix+#00)	; subtract pacman's Y position
17a7  b9        cp      c		; <= #04 ?
17a8  300a      jr      nc,#17b4        ; no, skip ahead for next ghost

17aa  3a074d    ld      a,(#4d07)	; yes, load A with orange ghost X position
17ad  dd9601    sub     (ix+#01)	; subtract pacman's X position
17b0  b9        cp      c		; <= #04 ?
17b1  da6317    jp      c,#1763		; yes, jump back and set collision

17b4  05        dec     b		; B := #03
17b5  3aae4d    ld      a,(#4dae)	; load A with blue ghost (inky) state
17b8  a7        and     a		; is inky alive ?
17b9  2013      jr      nz,#17ce        ; no, skip ahead for next ghost

17bb  3a044d    ld      a,(#4d04)	; load A with inky's Y position
17be  dd9600    sub     (ix+#00)	; subtract pacman's Y position
17c1  b9        cp      c		; <= #04 ?
17c2  300a      jr      nc,#17ce        ; no, skip ahead for next ghost

17c4  3a054d    ld      a,(#4d05)	; yes, load A with inky's X position
17c7  dd9601    sub     (ix+#01)	; subtract pacman's X position
17ca  b9        cp      c		; <= #04 ?
17cb  da6317    jp      c,#1763		; yes, jump back and set collision

17ce  05        dec     b		; B := #02
17cf  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
17d2  a7        and     a		; is pink ghost alive ?
17d3  2013      jr      nz,#17e8        ; no, skip ahead for next ghost

17d5  3a024d    ld      a,(#4d02)	; load A with pink ghost Y position
17d8  dd9600    sub     (ix+#00)	; subtract pacman's Y position
17db  b9        cp      c		; <= #04 ?
17dc  300a      jr      nc,#17e8        ; no, skip ahead for next ghost

17de  3a034d    ld      a,(#4d03)	; yes, load A with pink ghost X position
17e1  dd9601    sub     (ix+#01)	; subtract pacman's X position
17e4  b9        cp      c		; <= #04 ?
17e5  da6317    jp      c,#1763		; yes, jump back and set collision

17e8  05        dec     b		; B := #01
17e9  3aac4d    ld      a,(#4dac)	; load A with red ghost state
17ec  a7        and     a		; is red ghost alive ?
17ed  2013      jr      nz,#1802        ; no, skip ahead

17ef  3a004d    ld      a,(#4d00)	; yes, load A with red ghost Y position
17f2  dd9600    sub     (ix+#00)	; subtract pacman's Y position
17f5  b9        cp      c		; <= #04 ?
17f6  300a      jr      nc,#1802        ; no, skip ahead

17f8  3a014d    ld      a,(#4d01)	; yes, load A with red ghost X position
17fb  dd9601    sub     (ix+#01)	; subtract pacman's X position
17fe  b9        cp      c		; <= #04 ?
17ff  da6317    jp      c,#1763		; yes, jump back and set collision

1802  05        dec     b		; else no collision ; B := #00
1803  c36317    jp      #1763		; jump back and set collision

	; end of blue ghost collision detection


; called from #1044

1806  219d4d    ld      hl,#4d9d	; load HL with address of delay to update pacman movement
1809  3eff      ld      a,#ff		; A := #FF = code for no delay


	; Hack code:
	; 1809  c3c01f	jp	#1fc0		; Intermission fast fix ; HACK8 (1 of 3)
	; 1809  c3d01f	jp	#1fd0		; P1P2 cheat  ; HACK3
	; 1809  c34c0f	jp	#0f4c		; pause cheat ; HACK5
	; end hack code


180b  be        cp      (hl)		; is pacman slow due to the eating of a pill ?

	; Hack code
	; set 0xbe to 0x01 for fast cheat.	; HACK2 (1 of 2)
	; 180b  01
	;		i'm not entirely sure how this works.  it mangles
	;		the opcodes starting at 180b to be:
	;
	;	    080b 01ca11    ld      bc,11cah
	;	    080e 1835      jr      1845h
	;	    0810 c9        ret     
	;
	;	which makes little to no sense, but it works


	; end hack code

180c  ca1118    jp      z,#1811		; no, skip ahead
180f  35        dec     (hl)		; yes, decrement the counter to delay pacman movement
1810  c9        ret     		; return without movement

1811  3aa64d    ld      a,(#4da6)	; load A with power pill effect (1=active, 0=no effect)
1814  a7        and     a		; is a power pill active ?
1815  ca2f18    jp      z,#182f		; no, skip ahead

; movement when power pill active

1818  2a4c4d    ld      hl,(#4d4c)	; yes, load HL with speed bit patterns for pacman in power pill state (low bytes)
181b  29        add     hl,hl		; double
181c  224c4d    ld      (#4d4c),hl	; store result
181f  2a4a4d    ld      hl,(#4d4a)	; load HL with speed bit patterns for pacman in power pill state (high bytes)
1822  ed6a      adc     hl,hl		; double, with the carry = we have doubled the speed
1824  224a4d    ld      (#4d4a),hl	; store result. have we reached the threshold ?
1827  d0        ret     nc		; no, return

1828  214c4d    ld      hl,#4d4c	; yes, load HL with speed bit patterns for pacman in power pill state (low bytes)
182b  34        inc     (hl)		; increase
182c  c34318    jp      #1843		; skip ahead to move pacman

; movement when power pill not active

182f  2a484d    ld      hl,(#4d48)	; load HL with speed for pacman in normal state (low bytes)
1832  29        add     hl,hl		; double
1833  22484d    ld      (#4d48),hl	; store result
1836  2a464d    ld      hl,(#4d46)	; load HL with speed for pacman in normal state (high bytes)
1839  ed6a      adc     hl,hl		; double with carry
183b  22464d    ld      (#4d46),hl	; store result.  is it time for pacman to move?
183e  d0        ret     nc		; no, return.  pacman will be idle this time.

183f  21484d    ld      hl,#4d48	; yes, load HL with speed for pacman in normal state (low byte)
1842  34        inc     (hl)		; increase by one

; all pacman movement

1843  3a0e4e    ld      a,(#4e0e)	; load A with number of pills eaten in this level
1846  329e4d    ld      (#4d9e),a	; store into counter related to number of pills eaten before last pacman move
1849  3a724e    ld      a,(#4e72)	; load A with cocktail mode (0=no, 1=yes)
184c  4f        ld      c,a		; copy to C
184d  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
1850  a1        and     c		; mix together
1851  4f        ld      c,a		; copy to C.  This is checked at #1879 and #18BB
1852  213a4d    ld      hl,#4d3a	; load HL with address of pacman X tile position 
1855  7e        ld      a,(hl)		; load A with pacman X tile position
1856  0621      ld      b,#21		; B := #21
1858  90        sub     b		; subtract.  is pacman past the right edge of the screen?
1859  3809      jr      c,#1864         ; yes, skip ahead to handle tunnel movement

185b  7e        ld      a,(hl)		; load A with pacman X tile position
185c  063b      ld      b,#3b		; B := #3B
185e  90        sub     b		; subtract. is pacman pas the left edge of the screen?
185f  3003      jr      nc,#1864        ; yes, skip ahead to handle tunnel movement

1861  c3ab18    jp      #18ab		; no tunnel movement.  jump ahead to handle normal movement

; this sub is only called while player is in a tunnel

1864  3e01      ld      a,#01		; A := #01
1866  32bf4d    ld      (#4dbf),a	; store into pacman about to enter a tunnel flag
1869  3a004e    ld      a,(#4e00)	; load A with game state
186c  fe01      cp      #01		; are we in demo mode ?
186e  ca191a    jp      z,#1a19		; yes, skip ahead [ zero this instruction to NOP's to enable playing in demo mode (part 1/2) ] 

1871  3a044e    ld      a,(#4e04)	; else load A with subroutine #
1874  fe10      cp      #10		; <=#10 ?
1876  d2191a    jp      nc,#1a19	; no, skip ahead

1879  79        ld      a,c		; load A with mix of cocktail mode and player number, created above at #1849-#1851
187a  a7        and     a		; is this player 2 and cocktail mode ?
187b  2806      jr      z,#1883         ; No, skip ahead and check IN0

; check player 1 or player 2 input
; the program jumps to one of two locations to check
; player input based on whether it's player 1 or player 2 currently playing, and cocktail mode is enabled
; if player 2 is playing and cocktail mode enabled, 187b will fall through to 187d.
; if player 1 is playing or cocktail mode is disabled, 187b will jump to 1883 

187d  3a4050    ld      a,(#5040)	; else load A with IN1 (player 2)
1880  c38618    jp      #1886		; skip ahead

1883  3a0050    ld      a,(#5000)	; load A with IN0 (player 1)

1886  cb4f      bit     1,a		; is joystick pushed to left?
1888  c29918    jp      nz,#1899	; no, skip ahead

188b  2a0333    ld      hl,(#3303)	; yes, load HL with move left tile change
188e  3e02      ld      a,#02		; A := #02
1890  32304d    ld      (#4d30),a	; store into pac orientation
1893  221c4d    ld      (#4d1c),hl	; store HL into pacman Y tile changes (A)
1896  c35019    jp      #1950		; jump back to program

1899  cb57      bit     2,a		; is joystick pushed to right?
189b  c25019    jp      nz,#1950	; no, skip ahead

189e  2aff32    ld      hl,(#32ff)	; load HL with move right tile change
18a1  af        xor     a		; A := #00
18a2  32304d    ld      (#4d30),a	; store into pac orientation
18a5  221c4d    ld      (#4d1c),hl	; store HL into pacman Y tile changes (A)
18a8  c35019    jp      #1950		; jump back to program

; arrive here via #1861, this handles normal (not tunnel) movement

18ab  3a004e    ld      a,(#4e00)	; load A with game state
18ae  fe01      cp      #01		; are we in demo mode ?
18b0  ca191a    jp      z,#1a19		; yes, skip ahead [ zero this instruction into NOP's to enable playable demo mode, (part 2/2) ]

18b3  3a044e    ld      a,(#4e04)	; else load A with subroutine #
18b6  fe10      cp      #10		; <= #10 ?
18b8  d2191a    jp      nc,#1a19	; no, skip ahead

18bb  79        ld      a,c		; A := C
18bc  a7        and     a		; is this player 2 and cocktail mode ?
18bd  2806      jr      z,#18c5         ; yes, skip next 2 steps

; p1/p2 check.  see 187b above for info.

	; p2 movement check

18bf  3a4050    ld      a,(#5040)	; load A with IN1
18c2  c3c818    jp      #18c8		; skip next step

	; p1 movement check

18c5  3a0050    ld      a,(#5000)	; load A with IN0

18c8  cb4f      bit     1,a		; joystick pressed left?
18ca  cac91a    jp      z,#1ac9		; yes, jump to process

18cd  cb57      bit     2,a		; joystick pressed right?
18cf  cad91a    jp      z,#1ad9		; yes, jump to process

18d2  cb47      bit     0,a		; joystick pressed up?
18d4  cae81a    jp      z,#1ae8		; yes, jump to process

18d7  cb5f      bit     3,a		; joystick pressed down?
18d9  caf81a    jp      z,#1af8		; yes, jump to process

	; no change in movement - joystick is centered

18dc  2a1c4d    ld      hl,(#4d1c)	; load HL with pacman tile change
18df  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
18e2  0601      ld      b,#01		; B := #01 - this codes that the joystick was not moved

	; movement checks return to here

18e4  dd21264d  ld      ix,#4d26	; load IX with wanted pacman tile changes
18e8  fd21394d  ld      iy,#4d39	; load IY with pacman tile position
18ec  cd0f20    call    #200f		; load A with screen value of position computed in (IX) + (IY)
18ef  e6c0      and     #c0		; mask bits
18f1  d6c0      sub     #c0		; subtract.  is the maze blocking pacman from moving this way?
18f3  204b      jr      nz,#1940        ; no, skip ahead

18f5  05        dec     b		; yes, was the joystick moved ?
18f6  c21619    jp      nz,#1916	; yes, skip ahead

18f9  3a304d    ld      a,(#4d30)	; no, load A with pacman orientation
18fc  0f        rrca    		; roll right with carry.  is pacman moving either up or down?
18fd  da0b19    jp      c,#190b		; yes, skip next 5 steps

1900  3a094d    ld      a,(#4d09)	; no, load A with pacman X position
1903  e607      and     #07		; mask bits, now between 0 and 7
1905  fe04      cp      #04		; == #04 ?  (In center of tile ?)
1907  c8        ret     z		; yes, return

1908  c34019    jp      #1940		; else skip ahead

190b  3a084d    ld      a,(#4d08)	; load A with pacman Y position
190e  e607      and     #07		; mask bits, now between 0 and 7
1910  fe04      cp      #04		; == #04 ? (In center of tile ?)
1912  c8        ret     z		; yes, return

1913  c34019    jp      #1940		; no, skip ahead

1916  dd211c4d  ld      ix,#4d1c	; load IX with pacman Y,X tile changes 
191a  cd0f20    call    #200f		; load A with screen value of position computed in (IX) + (IY)
191d  e6c0      and     #c0		; mask bits
191f  d6c0      sub     #c0		; subtract.  is the maze blocking pacman from moving this way?
1921  202d      jr      nz,#1950        ; no, skip ahead

; code seems to be why pacman turns corners fast.  it gives an extra boost to the new direction

1923  3a304d    ld      a,(#4d30)	; yes, load A with pacman orientation
1926  0f        rrca    		; roll right with carry.  is pacman moving either up or down ?
1927  da3519    jp      c,#1935		; yes, skip next 5 steps

192a  3a094d    ld      a,(#4d09)	; no, load A with pacman X position
192d  e607      and     #07		; mask bits, now between 0 and 7
192f  fe04      cp      #04		; == #04 ? ( In center of tile ? )
1931  c8        ret     z		; yes, return

1932  c35019    jp      #1950		; no, skip ahead

1935  3a084d    ld      a,(#4d08)	; load A with pacman Y position
1938  e607      and     #07		; mask bits, now between 0 and 7
193a  fe04      cp      #04		; == #04 ( In center of tile?)
193c  c8        ret     z		; yes, return

193d  c35019    jp      #1950		; no, jump ahead

; arrive when changing direction (???)

1940  2a264d    ld      hl,(#4d26)	; load HL with wanted pacman tile changes
1943  221c4d    ld      (#4d1c),hl	; store into pacman tile changes
1946  05        dec     b		; was the joystick moved?
1947  ca5019    jp      z,#1950		; no, skip ahead

194a  3a3c4d    ld      a,(#4d3c)	; yes, load A with wanted pacman orientation
194d  32304d    ld      (#4d30),a	; store into pacman orientation

1950  dd211c4d  ld      ix,#4d1c	; load IX with pacman Y,X tile changes
1954  fd21084d  ld      iy,#4d08	; load IY with pacman position
1958  cd0020    call    #2000		; HL := (IX) + (IY)
195b  3a304d    ld      a,(#4d30)	; load A with pacman orientation
195e  0f        rrca    		; roll right, is pacman moving either up or down ?
195f  da7519    jp      c,#1975		; yes, skip ahead

1962  7d        ld      a,l		; load A with X position of new location
1963  e607      and     #07		; mask bits, now between 0 and 7
1965  fe04      cp      #04		; == #04 ( in center of tile ?)
1967  ca8519    jp      z,#1985		; yes, skip ahead

196a  da7119    jp      c,#1971		; was the last comparison less than #04 ?, if yes, skip next 2 steps

; cornering up to the left or up to the right

196d  2d        dec     l		; lower the X position
196e  c38519    jp      #1985		; skip ahead

; cornering right from down , cornering left from down

1971  2c        inc     l		; else increase the X position
1972  c38519    jp      #1985		; skip ahead

; handle up/down movement turns

1975  7c        ld      a,h		; load A with Y position of new loctaion
1976  e607      and     #07		; mask bits, now between 0 and 7
1978  fe04      cp      #04		; == #04 ( in center of tile ?)
197a  ca8519    jp      z,#1985		; yes, skip ahead

197d  da8419    jp      c,#1984		; was the last comparison less than #04 ?, if yes, skip next 2 steps

; cornering up from the left side, or down from the left side

1980  25        dec     h		; else lower the Y position 
1981  c38519    jp      #1985		; skip ahead

; arrive here when cornering up from the right side
; or when cornering down from the right side

1984  24        inc     h		; increase the Y position

; arrive here from several locations
; HL has the expected new position of a sprite

1985  22084d    ld      (#4d08),hl	; store the new sprite position into pacman position
1988  cd1820    call    #2018		; convert sprite position into a tile position
198b  22394d    ld      (#4d39),hl	; store tile position into pacman's tile position
198e  dd21bf4d  ld      ix,#4dbf	; load IX with tunnel indicator address
1992  dd7e00    ld      a,(ix+#00)	; load A with tunnel indiacator.  1=pacman in a tunnel
1995  dd360000  ld      (ix+#00),#00	; clear the tunnel indicator
1999  a7        and     a		; is pacman in a tunnel ?
199a  c0        ret     nz		; yes, return

; check for items eaten

199B: 3A D2 4D	ld	a,(#4DD2)	; load A with fruit position
199E: A7	and	a		; == #00 ?
199F: 28 2C	jr	z,#19CD		; yes, skip ahead

19A1: 3A D4 4D	ld	a,(#4DD4)	; else load A with entry to fruit points, or 0 if no fruit
19A4: A7	and	a		; == #00 ?
19A5: 28 26	jr	z,#19CD		; yes, skip ahead

; else check for fruit to be eaten

19A7: 2A 08 4D	ld	hl,(#4D08)	; load HL with pacman Y position
19AA: 11 94 80	ld	de,#8094	; load DE with #8094 (why?  on jump DE is loaded with new values.  this is junk from pac-man)

; OTTOPATCH
;PATCH TO MAKE THE PACMAN AWARE OF THE CHANGING POSITION OF THE FRUIT
ORG 19ADH
JP EATFRUIT
19AD: C3 18 88	jp	#8818		; MS Pac-man patch. jump to check for fruit being eaten

19B0: 20 1B	jr	nz,#19CD	; junk from pac-man

; arrive here when fruit is eaten

19B2: 06 19	ld	b,#19		; else a fruit is eaten.  load B with task #19
19B4: 4F	ld	c,a		; load C with task from A register
19B5: CD 42 00	call	#0042		; set task #19 with parameter variable A.  updates score.  B has code for items scored, draw score on screen, check for high score and extra lives
19B8: CD 00 10	call	#1000		; clear fruit.  clears #4DD4 and returns
19BB: 18 07	jr	#19C4		; skip ahead.  a fruit has been eaten

; Pac man code:
; 19b8  0e15      ld      c,#15
; 19ba  81        add     a,c
; 19bb  4f        ld      c,a
; 19bc  061c      ld      b,#1c
; end pac-man code


19BD: 1C				; junk from pac-man
19BE: CD 42 00	call	#0042		; pac-man only
19C1: CD 04 10	call	#1004		; pac-man only

19C4: F7	rst	#30		; set timed task to clear the fruit score sprite
19C5: 54 05 00				; timer=54, task=5, param=0

19C8: 21 BC 4E	ld	hl,#4EBC	; load HL with voice 3 address
19CB: CB D6	set	2,(hl)		; set up fruit eating sound.

; arrive here when no fruit eaten from fruit eating check subroutine

19CD: 3E FF	ld	a,#FF		; load A with #FF
19CF: 32 9D 4D	ld	(#4D9D),a	; store into delay to update pacman movement
19D2: 2A 39 4D	ld	hl,(#4D39)	; load HL with pacman's position
19D5: CD 65 00	call	#0065		; load HL with pacman's grid position
19D8: 7E	ld	a,(hl)		; load A with item on grid
19D9: FE 10	cp	#10		; is a dot being eaten ?
19DB: 28 03	jr	z,#19E0		; yes, skip ahead

19DD: FE 14	cp	#14		; else is an energizer being eaten?
19DF: C0	ret	nz		; no, return

; arrive here when a dot or energizer has been eaten
; A has either #10 or #14 loaded

19E0: DD210E4E	ld	ix,#4E0E	; else load number of pills eaten in this level
19E4: DD 34 00	inc	(ix+#00)	; increase
19E7: E6 0F	and	#0F		; mask bits.  If a dot is eaten, A is now #00.  Energizer, A is now #04
19E9: CB 3F	srl	a		; shift right (div by 2)
19EB: 06 40	ld	b,#40		; load B with #40 (clear graphic)
19ED: 70	ld	(hl),b		; update maze to clear the dot that has been eaten
19EE: 06 19	ld	b,#19		; load B with #19 for task call below
19F0: 4F	ld	c,a		; load C with A (either #00 or #02)
19F1: CB 39	srl	c		; shift right (div by 2).  now C is either #00 or #01
19F3: CD 42 00	call	#0042		; set task #19 with variable parameter

; task #19 will update score.  B has code for items scored, draw score on screen, check for high score and extra lives

19F6: 3C	inc	a		; A := A + 1.  A is now either 1 or 3
19F7: FE 01	cp	#01		; was a dot just eaten?
19F9: CA FD 19	jp	z,#19FD		; yes, skip next step

19FC: 87	add  a,a		; else it was an energizer. double A to 6

19FD: 32 9D 4D	ld	(#4D9D),a	; store A to delay update pacman movement
1A00: CD 08 1B	call	#1B08		; update timers for ghosts to leave ghost house
1A03: CD 6A 1A	call	#1A6A		; check for energizer eaten
1A06: 21 BC 4E	ld	hl,#4EBC	; load HL with sound #3
1A09: 3A 0E 4E	ld	a,(#4E0E)	; load A with number of pills eaten in this level
1A0C: 0F	rrca			; roll right
1A0D: 38 05	jr	c,#1A14		; if carry then use other sound pattern

1A0F: CB C6	set	0,(hl)		; else set sound bit 0
1A11: CB 8E	res	1,(hl)		; clear sound bit 1
1A13: C9	ret			; return

1A14: CB 86	res	0,(hl)		; clear sound bit 0
1A16: CB CE	set	1,(hl)		; set sound bit 1
1A18: C9	ret			; return     

; arrive here from #18b0 when game is in demo mode

1a19  211c4d    ld      hl,#4d1c	; load HL with pacman Y tile changes (A) location
1a1c  7e        ld      a,(hl)		; load A pacman Y tile changes (A)
1a1d  a7        and     a		; == #00 ?  is pacman moving left-right ?
1a1e  ca2e1a    jp      z,#1a2e		; yes, skip ahead

1a21  3a084d    ld      a,(#4d08)	; else load A with pacman Y position
1a24  e607      and     #07		; mask bits, now between 0 and 7
1a26  fe04      cp      #04		; == #04?
1a28  ca381a    jp      z,#1a38		; yes, skip ahead
1a2b  c35c1a    jp      #1a5c		; else jump ahead

1a2e  3a094d    ld      a,(#4d09)	; load A with pacman X position
1a31  e607      and     #07		; mask bits, now between 0 and 7
1a33  fe04      cp      #04		; == #04 ?
1a35  c25c1a    jp      nz,#1a5c	; no, skip ahead

1a38  3e05      ld      a,#05		; yes, A := #05. sets up call below to check if pacman is using tunnel in demo
1a3a  cdd01e    call    #1ed0		; if using tunnel, set carry flag
1a3d  3803      jr      c,#1a42		; is pacman in tunnel?  no, skip next 2 steps
1a3f  ef        rst     #28		; insert task to control pacman AI during demo mode.
1a40  17 00				; task #17, parameter #00

1a42  dd21264d  ld      ix,#4d26	; load IX with wanted pacman tile changes
1a46  fd21124d  ld      iy,#4d12	; load IY with pacman tile pos in demo and cut scenes
1a4a  cd0020    call    #2000		; load HL with new position of pacman
1a4d  22124d    ld      (#4d12),hl	; store new position into pacman tile position in demo and cut scenes
1a50  2a264d    ld      hl,(#4d26)	; load HL with wanted pacman tile changes
1a53  221c4d    ld      (#4d1c),hl	; store into pacman tile changes (Y,X)
1a56  3a3c4d    ld      a,(#4d3c)	; load A with wanted pacman orientation
1a59  32304d    ld      (#4d30),a	; store into pacman orientation

1a5c  dd211c4d  ld      ix,#4d1c	; load IX with pacman tile changes (Y,X)
1a60  fd21084d  ld      iy,#4d08	; load IY with pacman position (Y,X) address
1a64  cd0020    call    #2000		; load HL with new position of pacman
1a67  c38519    jp      #1985		; jump to movement check

; called from #1A03 after a dot has been eaten

1a6a  3a9d4d    ld      a,(#4d9d)	; load A with dot just eaten
1a6d  fe06      cp      #06		; was it an energizer?
1a6f  c0        ret     nz		; no, return

; else an engergizer has been eaten
; this is also called even on boards where energizers have "no effect"

1A70: 2A BD 4D	ld	hl,(#4DBD)	; load HL with time the ghosts stay blue when pacman eats a big pill
1a73  22cb4d    ld      (#4dcb),hl	; store into counter used while ghosts are blue
1a76  3e01      ld      a,#01		; A := #01
1a78  32a64d    ld      (#4da6),a	; set power pill to active
1a7b  32a74d    ld      (#4da7),a	; set red ghost blue flag
1a7e  32a84d    ld      (#4da8),a	; set pink ghost blue flag
1a81  32a94d    ld      (#4da9),a	; set inky blue flag
1a84  32aa4d    ld      (#4daa),a	; set orange ghost blue flag
1a87  32b14d    ld      (#4db1),a	; set red ghost change orientation flag
1a8a  32b24d    ld      (#4db2),a	; set pink ghost change orientation flag
1a8d  32b34d    ld      (#4db3),a	; set blue ghost (inky) change orientation flag
1a90  32b44d    ld      (#4db4),a	; set orange ghost change orientation flag
1a93  32b54d    ld      (#4db5),a	; set pacman change orientation flag (?)
1a96  af        xor     a		; A := #00
1a97  32c84d    ld      (#4dc8),a	; clear counter used to change ghost colors under big pill effects
1a9a  32d04d    ld      (#4dd0),a	; clear current number of killed ghosts (used for scoring)
1a9d  dd21004c  ld      ix,#4c00	; load IX with start of sprites address
1aa1  dd36021c  ld      (ix+#02),#1c	; set red ghost sprite to edible
1aa5  dd36041c  ld      (ix+#04),#1c	; set pink ghost sprite to edible
1aa9  dd36061c  ld      (ix+#06),#1c	; set inky sprite to edible
1aad  dd36081c  ld      (ix+#08),#1c	; set orange ghost sprite to edible

1ab1  dd360311  ld      (ix+#03),#11	; set red ghost color to blue

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Patch to fix the green-eye bug
; by Don Hodges 1/19/2009
; part 1/2 (rest at #1FB0):
;
; 1AB1 C3B01F	JP	#1FB0		; jump to new sub to only color ghosts when enough time
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


1ab5  dd360511  ld      (ix+#05),#11	; set pink ghost color to blue
1ab9  dd360711  ld      (ix+#07),#11	; set inky color to blue
1abd  dd360911  ld      (ix+#09),#11	; set orange ghost color to blue

1AC1: 21 AC 4E	ld	hl,#4EAC	; load HL with sound channel 2
1AC4: CB EE	set	5,(hl)		; play sound bit 5
1AC6: CB BE	res	7,(hl)		; clear sound bit 7
1AC8: C9	ret			; return

	; Player move Left

1ac9  2a0333    ld      hl,(#3303)	; load HL with tile movement left
1acc  3e02      ld      a,#02		; load A with code for moving left
1ace  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
1ad1  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
1ad4  0600      ld      b,#00		; B := #00
1ad6  c3e418    jp      #18e4		; return to program

	; player move Right

1ad9  2aff32    ld      hl,(#32ff)	; load HL with tile movement right
1adc  af        xor     a		; A := #00, code for moving right
1add  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
1ae0  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes 
1ae3  0600      ld      b,#00		; B := #00
1ae5  c3e418    jp      #18e4		; return to program

	; player move Up

1ae8  2a0533    ld      hl,(#3305)	; load HL with tile movement up
1aeb  3e03      ld      a,#03		; load A with code for moving up
1aed  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
1af0  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
1af3  0600      ld      b,#00		; B := #00
1af5  c3e418    jp      #18e4		; return to program

	; player move Down

1af8  2a0133    ld      hl,(#3301)	; load HL with tile movement down
1afb  3e01      ld      a,#01		; load A with code for moving down
1afd  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
1b00  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
1b03  0600      ld      b,#00		; B := #00
1b05  c3e418    jp      #18e4		; return to program

; called from #1A00

1b08  3a124e    ld      a,(#4e12)	; load A with flag set to 1 after dying in a level, reset to 0 if ghosts have left home
1b0b  a7        and     a		; has pacman died this level?  (or has this flag been reset after eating enough dots after death) ?
1b0c  ca141b    jp      z,#1b14		; no, skip ahead

1b0f  219f4d    ld      hl,#4d9f	; no, load HL with eaten pills counter after pacman has died in a level
1b12  34        inc     (hl)		; increase
1b13  c9        ret     		; return

1b14  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
1b17  a7        and     a		; is orange ghost at home ?
1b18  c0        ret     nz		; no, return

1b19  3aa24d    ld      a,(#4da2)	; yes, load A with inky substate
1b1c  a7        and     a		; is inky at home ?
1b1d  ca251b    jp      z,#1b25		; yes, skip ahead

1b20  21114e    ld      hl,#4e11	; no, load HL with counter incremented if orange ghost is home but inky is not
1b23  34        inc     (hl)		; increase counter
1b24  c9        ret     		; return

1b25  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
1b28  a7        and     a		; is pink ghost at home ?
1b29  ca311b    jp      z,#1b31		; yes, skip ahead

1b2c  21104e    ld      hl,#4e10	; no, load HL with counter incremented if inky and orange ghost are home but pinky is not
1b2f  34        inc     (hl)		; increase counter
1b30  c9        ret     		; return

1b31  210f4e    ld      hl,#4e0f	; load HL with counter incremented if pink ghost is home
1b34  34        inc     (hl)		; increase counter
1b35  c9        ret     		; return

; called from several locations

1b36  3aa04d    ld      a,(#4da0)	; load A with red ghost substate
1b39  a7        and     a		; is red ghost at home ?
1b3a  c8        ret     z		; yes, return

1b3b  3aac4d    ld      a,(#4dac)	; else load A with red ghost state
1b3e  a7        and     a		; is red ghost alive ?
1b3f  c0        ret     nz		; no, return

1b40  cdd720    call    #20d7		; checks for and sets the difficulty flags based on number of pellets eaten
1b43  2a314d    ld      hl,(#4d31)	; load HL with red ghost Y, X tile position 2
1b46  01994d    ld      bc,#4d99	; load BC with address of aux var used by red ghost to check positions
1b49  cd5a20    call    #205a		; check to see if red ghost has entered a tunnel slowdown area
1b4c  3a994d    ld      a,(#4d99)	; load A with aux var used by red ghost to check positions
1b4f  a7        and     a		; is the red ghost in a tunnel slowdown area ?
1b50  ca6a1b    jp      z,#1b6a		; no, skip ahead

1b53  2a604d    ld      hl,(#4d60)	; else load HL with red ghost speed bit patterns for tunnel areas
1b56  29        add     hl,hl		; double it
1b57  22604d    ld      (#4d60),hl	; store result
1b5a  2a5e4d    ld      hl,(#4d5e)	; load HL with red ghost speed bit patterns for tunnel areas
1b5d  ed6a      adc     hl,hl		; double it
1b5f  225e4d    ld      (#4d5e),hl	; store result.  have we exceeded the threshold ?
1b62  d0        ret     nc		; no, return

1b63  21604d    ld      hl,#4d60	; else load HL with red ghost speed bit patterns for tunnel areas
1b66  34        inc     (hl)		; increase
1b67  c3d81b    jp      #1bd8		; skip ahead

1b6a  3aa74d    ld      a,(#4da7)	; load A with red ghost blue flag (0=not blue)
1b6d  a7        and     a		; is red ghost blue ?
1b6e  ca881b    jp      z,#1b88		; no, skip ahead

1b71  2a5c4d    ld      hl,(#4d5c)	; yes, load HL with red ghost speed bit patterns for blue state
1b74  29        add     hl,hl		; double it
1b75  225c4d    ld      (#4d5c),hl	; store result
1b78  2a5a4d    ld      hl,(#4d5a)	; load HL with red ghost speed bit patterns for blue state
1b7b  ed6a      adc     hl,hl		; double it
1b7d  225a4d    ld      (#4d5a),hl	; store result.  have we exceeded the threshold ?
1b80  d0        ret     nc		; no, return

1b81  215c4d    ld      hl,#4d5c	; yes, load HL with red ghost speed bit patterns for blue state
1b84  34        inc     (hl)		; increase
1b85  c3d81b    jp      #1bd8		; skip ahead

1b88  3ab74d    ld      a,(#4db7)	; load A with 2nd difficulty flag
1b8b  a7        and     a		; is cruise elroy 2 active ?
1b8c  caa61b    jp      z,#1ba6		; no, skip ahead

1b8f  2a504d    ld      hl,(#4d50)	; yes, load HL with speed bit patterns for second difficulty flag
1b92  29        add     hl,hl		; double
1b93  22504d    ld      (#4d50),hl	; store result
1b96  2a4e4d    ld      hl,(#4d4e)	; load HL with speed bit patterns for second difficulty flag
1b99  ed6a      adc     hl,hl		; double
1b9b  224e4d    ld      (#4d4e),hl	; store result.  have we exceeded the threshold ?
1b9e  d0        ret     nc		; no, return

1b9f  21504d    ld      hl,#4d50	; yes, load HL with movement bit patterns for second difficulty flag
1ba2  34        inc     (hl)		; increase
1ba3  c3d81b    jp      #1bd8		; skip ahead

1ba6  3ab64d    ld      a,(#4db6)	; load A with 1st difficulty flag
1ba9  a7        and     a		; is cruise elroy 1 active?
1baa  cac41b    jp      z,#1bc4		; no, skip ahead

1bad  2a544d    ld      hl,(#4d54)	; yes, load HL with speed bit patterns for first difficulty flag
1bb0  29        add     hl,hl		; double
1bb1  22544d    ld      (#4d54),hl	; store result
1bb4  2a524d    ld      hl,(#4d52)	; load HL with speed bit patterns for first difficulty flag
1bb7  ed6a      adc     hl,hl		; double
1bb9  22524d    ld      (#4d52),hl	; store result.  have we exceeded the threshold ?
1bbc  d0        ret     nc		; no, return

1bbd  21544d    ld      hl,#4d54	; yes, load HL with speed bit patterns for first difficulty flag
1bc0  34        inc     (hl)		; increase
1bc1  c3d81b    jp      #1bd8		; skip ahead

1bc4  2a584d    ld      hl,(#4d58)	; load HL with speed bit patterns for red ghost normal state
1bc7  29        add     hl,hl		; double
1bc8  22584d    ld      (#4d58),hl	; store result
1bcb  2a564d    ld      hl,(#4d56)	; load HL with  speed bit patterns for red ghost normal state
1bce  ed6a      adc     hl,hl		; double
1bd0  22564d    ld      (#4d56),hl	; store result.  have we exceed the threshold ?
1bd3  d0        ret     nc		; no, return

1bd4  21584d    ld      hl,#4d58	; yes, load HL with speed bit patterns for red ghost normal state
1bd7  34        inc     (hl)		; increase

; called from #10C0 and several other places
; handles red ghost movement

1bd8  21144d    ld      hl,#4d14	; load HL with red ghost Y tile changes address
1bdb  7e        ld      a,(hl)		; load A with red ghost Y tile changes
1bdc  a7        and     a		; is the red ghost moving left to right or right to left ?
1bdd  caed1b    jp      z,#1bed		; yes, skip ahead

1be0  3a004d    ld      a,(#4d00)	; load A with red ghost Y position
1be3  e607      and     #07		; mask out bits, result is between 0 and 7
1be5  fe04      cp      #04		; == #04 ?  Is the red ghost in the middle of a tile where he can change direction?
1be7  caf71b    jp      z,#1bf7		; yes, skip ahead
1bea  c3361c    jp      #1c36		; no, jump ahead

1bed  3a014d    ld      a,(#4d01)	; load A with red ghost X position
1bf0  e607      and     #07		; mask bits.  result is between 0 and 7
1bf2  fe04      cp      #04		; == #04 ? Is the red ghost in the middle of a tile where he can change direction?
1bf4  c2361c    jp      nz,#1c36	; no, jump ahead

1bf7  3e01      ld      a,#01		; A := #01
1bf9  cdd01e    call    #1ed0		; check to see if red ghost is on the edge of the screen (tunnel)
1bfc  381b      jr      c,#1c19         ; yes, jump ahead

1bfe  3aa74d    ld      a,(#4da7)	; no, load A with red ghost blue flag (0=not blue)
1c01  a7        and     a		; is the red ghost blue (edible) ?
1c02  ca0b1c    jp      z,#1c0b		; no, skip ahead
1c05  ef        rst     #28		; yes, insert task #0C to control red ghost movement when power pill active
1c06  0c 00
1c08  c3191c    jp      #1c19		; skip ahead

1c0b  2a0a4d    ld      hl,(#4d0a)	; else load HL with red tile position (Y,X)
1c0e  cd5220    call    #2052		; convert ghost Y,X position in HL to a color screen location
1c11  7e        ld      a,(hl)		; load A with color of screen location of ghost
1c12  fe1a      cp      #1a		; == #1A ?  (this color marks zones where ghosts cannot change direction, e.g. above the ghost house in pac-man)
1c14  2803      jr      z,#1c19         ; yes, skip next step

1c16  ef        rst     #28		; no, insert task #08 to control red ghost AI
1c17  08 00

1c19  cdfe1e    call    #1efe		; check for and handle red ghost direction reversals
1c1c  dd211e4d  ld      ix,#4d1e	; load IX with red ghost tile changes
1c20  fd210a4d  ld      iy,#4d0a	; load IY with red ghost tile position
1c24  cd0020    call    #2000		; HL := (IX) + (IY)
1c27  220a4d    ld      (#4d0a),hl	; store new result into red ghost tile position
1c2a  2a1e4d    ld      hl,(#4d1e)	; load HL with red ghost tile changes
1c2d  22144d    ld      (#4d14),hl	; store into red ghost tile changes (A)
1c30  3a2c4d    ld      a,(#4d2c)	; load A with red ghost orientation
1c33  32284d    ld      (#4d28),a	; store into previous red ghost orientation

1c36  dd21144d  ld      ix,#4d14	; load IX with red ghost tile changes (A)
1c3a  fd21004d  ld      iy,#4d00	; load IY with red ghost position
1c3e  cd0020    call    #2000		; HL := (IX) + (IY)
1c41  22004d    ld      (#4d00),hl	; store result into red ghost position
1c44  cd1820    call    #2018		; convert sprite position into a tile position
1c47  22314d    ld      (#4d31),hl	; store into red ghost tile position 2 
1c4a  c9        ret			; return

; control movement patterns for pink ghost
; called from #104A

1c4b  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
1c4e  fe01      cp      #01		; is pink ghost at home ?
1c50  c0        ret     nz		; yes, return

1c51  3aad4d    ld      a,(#4dad)	; else load A with pink ghost state
1c54  a7        and     a		; is pink ghost alive ?
1c55  c0        ret     nz		; no, return

1c56  2a334d    ld      hl,(#4d33)	; load HL with pink ghost tile position 2
1c59  019a4d    ld      bc,#4d9a	; load BC with address of aux var used by pink ghost to check positions
1c5c  cd5a20    call    #205a		; check to see if pink ghost has entered a tunnel slowdown area
1c5f  3a9a4d    ld      a,(#4d9a)	; load A with aux var used by pink ghost to check positions
1c62  a7        and     a		; is the pink ghost in a tunnel slowdown area ?
1c63  ca7d1c    jp      z,#1c7d		; no, skip ahead

1c66  2a6c4d    ld      hl,(#4d6c)	; else load HL with speed bit patterns for pink ghost tunnel areas
1c69  29        add     hl,hl		; double it
1c6a  226c4d    ld      (#4d6c),hl	; store result
1c6d  2a6a4d    ld      hl,(#4d6a)	; load HL with speed bit patterns for pink ghost tunnel areas
1c70  ed6a      adc     hl,hl		; double it
1c72  226a4d    ld      (#4d6a),hl	; store result.   Have we exceeded the threshold ?
1c75  d0        ret     nc		; no, return

1c76  216c4d    ld      hl,#4d6c	; else load HL with address of speed bit patterns for pink ghost tunnel areas
1c79  34        inc     (hl)		; increase
1c7a  c3af1c    jp      #1caf		; skip ahead

1c7d  3aa84d    ld      a,(#4da8)	; load A with pink ghost blue flag
1c80  a7        and     a		; is the pink ghost blue ?
1c81  ca9b1c    jp      z,#1c9b		; no, skip ahead

1c84  2a684d    ld      hl,(#4d68)	; yes, load HL with speed bit patterns for pink ghost blue state
1c87  29        add     hl,hl		; double it
1c88  22684d    ld      (#4d68),hl	; store result
1c8b  2a664d    ld      hl,(#4d66)	; load HL with speed bit patterns for pink ghost blue state
1c8e  ed6a      adc     hl,hl		; double it
1c90  22664d    ld      (#4d66),hl	; store result.  have we exceeded the threshold ?
1c93  d0        ret     nc		; no, return

1c94  21684d    ld      hl,#4d68	; yes, load HL with speed bit patterns for pink ghost blue state
1c97  34        inc     (hl)		; increase
1c98  c3af1c    jp      #1caf		; skip ahead

1c9b  2a644d    ld      hl,(#4d64)	; load HL with speed bit patterns for pink ghost normal state
1c9e  29        add     hl,hl		; double it
1c9f  22644d    ld      (#4d64),hl	; store result
1ca2  2a624d    ld      hl,(#4d62)	; load HL with speed bit patterns for pink ghost normal state
1ca5  ed6a      adc     hl,hl		; double it
1ca7  22624d    ld      (#4d62),hl	; store result.  have we exceeded the threshold ?
1caa  d0        ret     nc		; no, return

1cab  21644d    ld      hl,#4d64	; yes, load HL with speed bit patterns for pink ghost normal state
1cae  34        inc     (hl)		; increase

1caf  21164d    ld      hl,#4d16	; load HL with address for pink ghost Y tile changes
1cb2  7e        ld      a,(hl)		; load A with pink ghost Y tile changes
1cb3  a7        and     a		; Is the pink ghost moving left-right or right-left ?
1cb4  cac41c    jp      z,#1cc4		; yes, skip ahead

1cb7  3a024d    ld      a,(#4d02)	; no, load A with pink ghost Y position
1cba  e607      and     #07		; mask bits
1cbc  fe04      cp      #04		; is pink ghost in the middle of the tile ?
1cbe  cace1c    jp      z,#1cce		; yes, skip ahead

1cc1  c30d1d    jp      #1d0d		; no, jump ahead

1cc4  3a034d    ld      a,(#4d03)	; load A with pink ghost X position
1cc7  e607      and     #07		; mask bits
1cc9  fe04      cp      #04		; is pink ghost in the middle of the tile ?
1ccb  c20d1d    jp      nz,#1d0d	; no, skip ahead

1cce  3e02      ld      a,#02		; yes, A := #02
1cd0  cdd01e    call    #1ed0		; check to see if pink ghost is on the edge of the screen (tunnel)
1cd3  381b      jr      c,#1cf0         ; yes, jump ahead

1cd5  3aa84d    ld      a,(#4da8)	; no, load A with pink ghost blue flag (0=not blue)
1cd8  a7        and     a		; is the pink ghost blue ?
1cd9  cae21c    jp      z,#1ce2		; no, skip ahead

1cdc  ef        rst     #28		; yes, insert task to handle pink ghost movement when power pill active
1cdd  0d 00				; task data
1cdf  c3f01c    jp      #1cf0		; skip ahead

1ce2  2a0c4d    ld      hl,(#4d0c)	; load HL with pink ghost Y,X tile pos
1ce5  cd5220    call    #2052		; convert ghost Y,X position in HL to a color screen location
1ce8  7e        ld      a,(hl)		; load A with color screen position of ghost
1ce9  fe1a      cp      #1a		; == #1A? (this color marks zones where ghosts cannot change direction, e.g. above the ghost house in pac-man)
1ceb  2803      jr      z,#1cf0         ; yes, skip next step

1ced  ef        rst     #28		; insert task to handle pink ghost AI
1cee  09 00				; task data

1cf0  cd251f    call    #1f25		; check for and handle when pink ghost reverses directions
1cf3  dd21204d  ld      ix,#4d20	; load IX with pink ghost tile changes
1cf7  fd210c4d  ld      iy,#4d0c	; load IY with pink ghost tile position
1cfb  cd0020    call    #2000		; HL := (IX) + (IY)
1cfe  220c4d    ld      (#4d0c),hl	; store new result into pink ghost tile position
1d01  2a204d    ld      hl,(#4d20)	; load HL with pink ghost tile changes
1d04  22164d    ld      (#4d16),hl	; store into pink ghost tile changes (A)
1d07  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost orientation
1d0a  32294d    ld      (#4d29),a	; store into previous pink ghost orientation

1d0d  dd21164d  ld      ix,#4d16	; load IX with pink ghost tile changes (A)
1d11  fd21024d  ld      iy,#4d02	; load IY with pink ghost position
1d15  cd0020    call    #2000		; HL := (IX) + (IY)
1d18  22024d    ld      (#4d02),hl	; store result into pink ghost postion
1d1b  cd1820    call    #2018		; convert sprite position into a tile position
1d1e  22334d    ld      (#4d33),hl	; store into pink ghost tile position 2
1d21  c9        ret     		; return

; check movement patterns for inky
; called from #104D

1d22  3aa24d    ld      a,(#4da2)	; load A with blue ghost (inky) substate
1d25  fe01      cp      #01		; is blue ghost at home ?
1d27  c0        ret     nz		; yes, return

1d28  3aae4d    ld      a,(#4dae)	; else load A with blue ghost (inky) state
1d2b  a7        and     a		; is inky alive ?
1d2c  c0        ret     nz		; no, return

1d2d  2a354d    ld      hl,(#4d35)	; load HL with inky tile position 2
1d30  019b4d    ld      bc,#4d9b	; load BC with address of aux var used by inky to check positions
1d33  cd5a20    call    #205a		; check to see if inky has entered a tunnel slowdown area
1d36  3a9b4d    ld      a,(#4d9b)	; load A with aux var used by inky to check positions
1d39  a7        and     a		; is inky in a tunnel slowdown area?
1d3a  ca541d    jp      z,#1d54		; no, skip ahead

1d3d  2a784d    ld      hl,(#4d78)	; yes, load HL with speed bit patterns for inky tunnel areas
1d40  29        add     hl,hl		; double it
1d41  22784d    ld      (#4d78),hl	; store result
1d44  2a764d    ld      hl,(#4d76)	; load HL with speed bit patterns for inky tunnel areas
1d47  ed6a      adc     hl,hl		; double it
1d49  22764d    ld      (#4d76),hl	; store result.  have we exceeded the threshold?
1d4c  d0        ret     nc		; no, return

1d4d  21784d    ld      hl,#4d78	; yes, load HL with address of speed bit patterns for inky tunnel areas
1d50  34        inc     (hl)		; increase
1d51  c3861d    jp      #1d86		; skip ahead

1d54  3aa94d    ld      a,(#4da9)	; load A with inky blue flag
1d57  a7        and     a		; is inky edible ?
1d58  ca721d    jp      z,#1d72		; no, skip ahead

1d5b  2a744d    ld      hl,(#4d74)	; yes, load HL with speed bit patterns for inky in blue state
1d5e  29        add     hl,hl		; double it
1d5f  22744d    ld      (#4d74),hl	; store result
1d62  2a724d    ld      hl,(#4d72)	; load HL with speed bit patterns for inky in blue state
1d65  ed6a      adc     hl,hl		; double it
1d67  22724d    ld      (#4d72),hl	; store result.  have we exceeded the threshold?
1d6a  d0        ret     nc		; no, return

1d6b  21744d    ld      hl,#4d74	; yes, load HL with speed bit patterns for inky in blue state
1d6e  34        inc     (hl)		; increase
1d6f  c3861d    jp      #1d86		; jump ahead

1d72  2a704d    ld      hl,(#4d70)	; load HL with speed bit patterns for inky normal state
1d75  29        add     hl,hl		; double it
1d76  22704d    ld      (#4d70),hl	; store result
1d79  2a6e4d    ld      hl,(#4d6e)	; load HL with speed bit patterns for inky normal state
1d7c  ed6a      adc     hl,hl		; double it
1d7e  226e4d    ld      (#4d6e),hl	; store result. have we exceeded the threshold ?
1d81  d0        ret     nc		; no, return

1d82  21704d    ld      hl,#4d70	; yes, load HL with speed bit patterns for inky normal state
1d85  34        inc     (hl)		; increase
		
1d86  21184d    ld      hl,#4d18	; load HL with address of inky Y tile changes
1d89  7e        ld      a,(hl)		; load A with inky Y tile changes
1d8a  a7        and     a		; is inky moving left-right or right left ?
1d8b  ca9b1d    jp      z,#1d9b		; yes, skip ahead

1d8e  3a044d    ld      a,(#4d04)	; no, load A with inky Y position
1d91  e607      and     #07		; mask bits
1d93  fe04      cp      #04		; is inky in the middle of a tile ?
1d95  caa51d    jp      z,#1da5		; yes, skip ahead
1d98  c3e41d    jp      #1de4		; no, jump ahead

1d9b  3a054d    ld      a,(#4d05)	; load A with inky X position
1d9e  e607      and     #07		; mask bits
1da0  fe04      cp      #04		; is inky in the middle of the tile ?
1da2  c2e41d    jp      nz,#1de4	; no, skip ahead

1da5  3e03      ld      a,#03		; yes, A := #03
1da7  cdd01e    call    #1ed0		; check to see if inky is on the edge of the screen (tunnel)
1daa  381b      jr      c,#1dc7         ; yes, jump ahead

1dac  3aa94d    ld      a,(#4da9)	; no, load A with inky blue flag (0 = not blue)
1daf  a7        and     a		; is inky edible ?
1db0  cab91d    jp      z,#1db9		; no, skip ahead

1db3  ef        rst     #28		; yes, insert task to handle blue ghost (inky) movement when power pill active
1db4  0e 00
1db6  c3c71d    jp      #1dc7		; skip ahead

1db9  2a0e4d    ld      hl,(#4d0e)	; load HL with inky tile position
1dbc  cd5220    call    #2052		; covert to color screen location
1dbf  7e        ld      a,(hl)		; load A with color of screen location
1dc0  fe1a      cp      #1a		; == #1A ? (this color marks zones where ghosts cannot change direction, e.g. above the ghost house in pac-man)
1dc2  2803      jr      z,#1dc7         ; yes, skip next step

1dc4  ef        rst     #28		; insert task to handle blue ghost (inky) AI
1dc5  0a 00

1dc7  cd4c1f    call    #1f4c		; check for and handle when inky reverses directions
1dca  dd21224d  ld      ix,#4d22	; load IX with inky tile changes
1dce  fd210e4d  ld      iy,#4d0e	; load IY with inky tile position
1dd2  cd0020    call    #2000		; HL := (IX) + (IY)
1dd5  220e4d    ld      (#4d0e),hl	; store new result into inky tile position
1dd8  2a224d    ld      hl,(#4d22)	; load HL with inky tile changes
1ddb  22184d    ld      (#4d18),hl	; store into inky tile changes (A)
1dde  3a2e4d    ld      a,(#4d2e)	; load A with inky orientation
1de1  322a4d    ld      (#4d2a),a	; store into inky previous orientation

1de4  dd21184d  ld      ix,#4d18	; load IX with inky tile changes (A)
1de8  fd21044d  ld      iy,#4d04	; load IY with inky position
1dec  cd0020    call    #2000		; HL := (IX) + (IY)
1def  22044d    ld      (#4d04),hl	; store result into inky position
1df2  cd1820    call    #2018		; convert sprite position into a tile position
1df5  22354d    ld      (#4d35),hl	; store into inky tile position 2
1df8  c9        ret     		; return

; control movement patterns for orange ghost
; called from #1050

1df9  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
1dfc  fe01      cp      #01		; is orange ghost at home ?
1dfe  c0        ret     nz		; yes, return

1dff  3aaf4d    ld      a,(#4daf)	; else load A with orange ghost state
1e02  a7        and     a		; is orange ghost alive ?
1e03  c0        ret     nz		; no, return

1e04  2a374d    ld      hl,(#4d37)	; load HL with orange ghost tile position 2
1e07  019c4d    ld      bc,#4d9c	; load BC with address of aux var used by orange ghost to check positions
1e0a  cd5a20    call    #205a		; check to see if orange ghost has entered a tunnel slowdown area
1e0d  3a9c4d    ld      a,(#4d9c)	; load A with aux var used by orange ghost to check positions
1e10  a7        and     a		; is the orange ghost in a tunnel slowdown area?
1e11  ca2b1e    jp      z,#1e2b		; no, skip ahead

1e14  2a844d    ld      hl,(#4d84)	; yes, load HL with speed bit patterns for orange ghost tunnel areas
1e17  29        add     hl,hl		; double it
1e18  22844d    ld      (#4d84),hl	; store result
1e1b  2a824d    ld      hl,(#4d82)	; load HL with speed bit patterns for orange ghost tunnel areas
1e1e  ed6a      adc     hl,hl		; double it
1e20  22824d    ld      (#4d82),hl	; store result.  have we exceeded the threshold?
1e23  d0        ret     nc		; no, return

1e24  21844d    ld      hl,#4d84	; yes, load HL with speed bit patterns for orange ghost tunnel areas
1e27  34        inc     (hl)		; increase
1e28  c35d1e    jp      #1e5d		; skip ahead

1e2b  3aaa4d    ld      a,(#4daa)	; load A with orange ghost blue flag
1e2e  a7        and     a		; is the orange ghost blue ( edible ) ?
1e2f  ca491e    jp      z,#1e49		; no, skip ahead

1e32  2a804d    ld      hl,(#4d80)	; yes, load HL with speed bit patterns for orange ghost blue state
1e35  29        add     hl,hl		; double it
1e36  22804d    ld      (#4d80),hl	; store result
1e39  2a7e4d    ld      hl,(#4d7e)	; load HL with speed bit patterns for orange ghost blue state
1e3c  ed6a      adc     hl,hl		; double it
1e3e  227e4d    ld      (#4d7e),hl	; store result.  have we exceeded the threshold ?
1e41  d0        ret     nc		; no, return

1e42  21804d    ld      hl,#4d80	; yes, load HL with speed bit patterns for orange ghost blue state
1e45  34        inc     (hl)		; increase 
1e46  c35d1e    jp      #1e5d		; skip ahead

1e49  2a7c4d    ld      hl,(#4d7c)	; load HL with speed bit patterns for orange ghost normal state
1e4c  29        add     hl,hl		; double it
1e4d  227c4d    ld      (#4d7c),hl	; store result
1e50  2a7a4d    ld      hl,(#4d7a)	; load HL with speed bit patterns for orange ghost normal state
1e53  ed6a      adc     hl,hl		; double it
1e55  227a4d    ld      (#4d7a),hl	; store result.  have we exceeded the threshold ?
1e58  d0        ret     nc		; no, return

1e59  217c4d    ld      hl,#4d7c	; yes, load HL with speed bit patterns for orange ghost normal state
1e5c  34        inc     (hl)		; increase

1e5d  211a4d    ld      hl,#4d1a	; load HL with address for orange ghost Y tile changes
1e60  7e        ld      a,(hl)		; load A with orange ghost Y tile changes
1e61  a7        and     a		; is the orange ghost moving left-right or right-left ?
1e62  ca721e    jp      z,#1e72		; yes, skip ahead

1e65  3a064d    ld      a,(#4d06)	; no, load A with orange ghost Y position
1e68  e607      and     #07		; mask bits
1e6a  fe04      cp      #04		; is orange ghost in the middle of the tile ?
1e6c  ca7c1e    jp      z,#1e7c		; yes, skip ahead

1e6f  c3bb1e    jp      #1ebb		; no, jump ahead

1e72  3a074d    ld      a,(#4d07)	; load A with orange ghost X position
1e75  e607      and     #07		; mask bits
1e77  fe04      cp      #04		; is orange ghost in the middle of the tile ?
1e79  c2bb1e    jp      nz,#1ebb	; no, skip ahead

1e7c  3e04      ld      a,#04		; yes, A := #04
1e7e  cdd01e    call    #1ed0		; check to see if orange ghost is on the edge of the screen (tunnel)
1e81  381b      jr      c,#1e9e         ; yes, jump ahead

1e83  3aaa4d    ld      a,(#4daa)	; no, load A with orange ghost blue flag (0 = not blue)
1e86  a7        and     a		; is the orange ghost blue (edible) ?
1e87  ca901e    jp      z,#1e90		; no, skip ahead

1e8a  ef        rst     #28		; yes, insert task to handle orange ghost movement when power pill active
1e8b  0f 00				; task data
1e8d  c39e1e    jp      #1e9e		; skip ahead

1e90  2a104d    ld      hl,(#4d10)	; load HL with orange ghost Y,X tile position
1e93  cd5220    call    #2052		; covert Y,X position in HL to color screen location
1e96  7e        ld      a,(hl)		; load A with color screen position of ghost
1e97  fe1a      cp      #1a		; == #1A ((this color marks zones where ghosts cannot change direction, e.g. above the ghost house in pac-man)
1e99  2803      jr      z,#1e9e         ; yes, skip next step

1e9b  ef        rst     #28		; insert task to control orange ghost AI
1e9c  0b 00				; task data

1e9e  cd731f    call    #1f73		; check for and handle when orange ghost reverses directions
1ea1  dd21244d  ld      ix,#4d24	; load IX with orange ghost tile changes
1ea5  fd21104d  ld      iy,#4d10	; load IY with orange ghost tile position
1ea9  cd0020    call    #2000		; HL := (IX) + (IY)
1eac  22104d    ld      (#4d10),hl	; store result into orange ghost tile position
1eaf  2a244d    ld      hl,(#4d24)	; load HL with orange ghost tile changes
1eb2  221a4d    ld      (#4d1a),hl	; store into orange ghost tile changes (A)
1eb5  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost orientation
1eb8  322b4d    ld      (#4d2b),a	; store into previous orange ghost orientation
1ebb  dd211a4d  ld      ix,#4d1a	; load IX with orange ghost tile changes (A)
1ebf  fd21064d  ld      iy,#4d06	; load IY with orange ghost position
1ec3  cd0020    call    #2000		; HL := (IX) + (IY)
1ec6  22064d    ld      (#4d06),hl	; store result into orange ghost position
1ec9  cd1820    call    #2018		; convert sprite position into a tile position
1ecc  22374d    ld      (#4d37),hl	; store into orange ghost tile position 2
1ecf  c9        ret			; return

; called from #1A3A while in demo mode
; called from #1BF9 when red ghost movement checking.  A is preloaded with #01
; if the ghost/pacman is on the edge of the screen, the carry flag is set, else it is cleared

1ed0  87        add     a,a		; A := A * 2
1ed1  4f        ld      c,a		; copy to C
1ed2  0600      ld      b,#00		; B := #00
1ed4  21094d    ld      hl,#4d09	; load HL with pacman X position address
1ed7  09        add     hl,bc		; add offset to HL.  HL how has the ghost/pacman tile position address
1ed8  7e        ld      a,(hl)		; load A with ghost/pacman tile X position
1ed9  fe1d      cp      #1d		; has the ghost moved off the far right side of the screen?
1edb  c2e31e    jp      nz,#1ee3	; no, skip next 2 steps

1ede  363d      ld      (hl),#3d	; yes, change ghost/pacman X position to far left side of screen
1ee0  c3fc1e    jp      #1efc		; jump ahead, set carry flag and return

1ee3  fe3e      cp      #3e		; has the ghost/pacman moved off the far left side of the screen ?
1ee5  c2ed1e    jp      nz,#1eed	; no, skip next 2 steps

1ee8  361e      ld      (hl),#1e	; yes, change ghost/pacman X position to far right side of screen
1eea  c3fc1e    jp      #1efc		; jump ahead, set carry flag and return

1eed  0621      ld      b,#21		; B := #21
1eef  90        sub     b		; subtract from ghost/pacman X position.  is the ghost on the far right edge ?
1ef0  dafc1e    jp      c,#1efc		; yes, set carry flag and return

1ef3  7e        ld      a,(hl)		; else load A with ghost/pacman tile X position
1ef4  063b      ld      b,#3b		; B := #3B
1ef6  90        sub     b		; subtract.  is the ghost/pacman on the far left edge?
1ef7  d2fc1e    jp      nc,#1efc	; yes, set carry flag and return

1efa  a7        and     a		; else clear carry flag
1efb  c9        ret			; return

1efc  37        scf			; set carry flag   
1efd  c9        ret			; return

; check for reverse direction of red ghost

1efe  3ab14d    ld      a,(#4db1)	; load A with red ghost change orientation flag
1f01  a7        and     a		; is the red ghost reversing direction ?
1f02  c8        ret     z		; no, return

; reverse direction of red ghost

1f03  af        xor     a		; yes, A := #00
1f04  32b14d    ld      (#4db1),a	; clear red ghost change orientation flag
1f07  21ff32    ld      hl,#32ff	; load HL with table data - tile differences tables for movements
1f0a  3a284d    ld      a,(#4d28)	; load A with previous red ghost orientation
1f0d  ee02      xor     #02		; toggle bit 1
1f0f  322c4d    ld      (#4d2c),a	; store into red ghost orientation
1f12  47        ld      b,a		; copy to B
1f13  df        rst     #18		; load HL with tile difference for movements based on table at #32FF
1f14  221e4d    ld      (#4d1e),hl	; store into red ghost tile changes
1f17  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
1f1a  fe22      cp      #22		; == #22 ?
1f1c  c0        ret     nz		; no, return

1f1d  22144d    ld      (#4d14),hl	; yes, store movement into alternate red ghost tile changes
1f20  78        ld      a,b		; load A with red ghost orientation
1f21  32284d    ld      (#4d28),a	; store into previous red ghost orientation
1f24  c9        ret			; return

; check for reverse direction of pink ghost

1f25  3ab24d    ld      a,(#4db2)	; load A with pink ghost change orientation flag
1f28  a7        and     a		; is the pink ghost reversing direction ?
1f29  c8        ret     z		; no, return

; reverse direction of pink ghost

1f2a  af        xor     a		; yes, A := #00
1f2b  32b24d    ld      (#4db2),a	; clear pink ghost change orientation flag
1f2e  21ff32    ld      hl,#32ff	; load HL with table data - tile differences tables for movements
1f31  3a294d    ld      a,(#4d29)	; load A with previous pink ghost orientation
1f34  ee02      xor     #02		; flip bit #1
1f36  322d4d    ld      (#4d2d),a	; store into pink ghost orientation
1f39  47        ld      b,a		; copy to B
1f3a  df        rst     #18		; load HL with new direction tile offsets
1f3b  22204d    ld      (#4d20),hl	; store into pink ghost tile offsets
1f3e  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
1f41  fe22      cp      #22		; == #22 (check for demo mode, pac-man only, when pac-man is chased by 4 ghosts on title screen)
1f43  c0        ret     nz		; no, return

1f44  22164d    ld      (#4d16),hl	; yes, store new direction tile offsets into alternate pink ghost tile changes
1f47  78        ld      a,b		; load A with pink ghost orientation
1f48  32294d    ld      (#4d29),a	; store into previous pink ghost direction
1f4b  c9        ret     		; return

; check for reverse direction of inky

1f4c  3ab34d    ld      a,(#4db3)	; load A with blue ghost (inky) change orientation flag
1f4f  a7        and     a		; is inky reversing direction ?
1f50  c8        ret     z		; no, return

; reverse direction of inky

+-------1f51  af        xor     a		; yes, A := #00
1f52  32b34d    ld      (#4db3),a	; clear inky ghost change orienation flag
1f55  21ff32    ld      hl,#32ff	; load HL with table data - tile differences tables for movements
1f58  3a2a4d    ld      a,(#4d2a)	; load A with previous inky orientation
1f5b  ee02      xor     #02		; flip bit #1
1f5d  322e4d    ld      (#4d2e),a	; store into inky orientation
1f60  47        ld      b,a		; copy to B
1f61  df        rst     #18		; load HL with new direction tile offsets
1f62  22224d    ld      (#4d22),hl	; store into inky ghost tile offsets
1f65  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
1f68  fe22      cp      #22		; == #22 ? (check for demo mode, pac-man only, when pac-man is chased by 4 ghosts on title screen)
1f6a  c0        ret     nz		; no, return

1f6b  22184d    ld      (#4d18),hl	; yes, store new direction tile offsets into alternate inky ghost tile changes
1f6e  78        ld      a,b		; load A with inky orientation
1f6f  322a4d    ld      (#4d2a),a	; store into previous inky direction
1f72  c9        ret			; return

; check for reverse direction of orange ghost

1f73  3ab44d    ld      a,(#4db4)	; load A with orange ghost change orientation flag
1f76  a7        and     a		; is orange ghost reversing direction ?
1f77  c8        ret     z		; no, return

; reverse direction of orange ghost

1f78  af        xor     a		; yes, A := #00
1f79  32b44d    ld      (#4db4),a	; clear orange ghost change orientation flag
1f7c  21ff32    ld      hl,#32ff	; load HL with table data - tile differences tables for movements
1f7f  3a2b4d    ld      a,(#4d2b)	; load A with previous orange ghost orienation
1f82  ee02      xor     #02		; flip bit #1
1f84  322f4d    ld      (#4d2f),a	; store into orange ghost orienation
1f87  47        ld      b,a		; copy to B
1f88  df        rst     #18		; load HL with new direction tile offsets
1f89  22244d    ld      (#4d24),hl	; store into orange ghost tile offsets
1f8c  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
1f8f  fe22      cp      #22		; == #22 ? (check for demo mode, pac-man only, when pac-man is chased by 4 ghosts on title screen)
1f91  c0        ret     nz		; no, return

1f92  221a4d    ld      (#4d1a),hl	; yes, store new direction tile offsets into alternate orange ghost tile changes
1f95  78        ld      a,b		; load A with orange ghost orienation
1f96  322b4d    ld      (#4d2b),a	; store into previous orange ghost direction
1f99  c9        ret     		; return

1f9a  21				; junk

	;; new for INTERRUPT MODE 1
	;; rst 38 continuation  (vblank)
	;; This code not found in original hardware 

1f9b  f5	push	af		; save AF
1f9c  ed57	ld	a,i		; load A with interrupt vector
1f9e  b7        or      a		; check to see if we're in test mode
1f9f  2804      jr      z,#1fa5         ; jp, pop, to 3000 if yes

	; not in test mode

1fa1  f1        pop     af		; restore AF
1fa2  c38d00    jp      #008d		; continue the original handler

	; in test mode

1fa5  f1        pop     af		; restore AF
1fa6  c30030    jp      #3000		; we're in init, continue testing


1F9A:                                00 00 00 00 00 00
1FA0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1FB0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; patch to fix the green-eye ghost
; by don hodges 1/19/2009
; part 2/2 (continuation from #1AB1)
;
; 	1FB0 	3A CB 4D	LD	a,(#4DCB)	; load A with energizer timer
; 	1FB3	FE 01		CP	#01		; is this energizer a "reverse-only" ?
; 	1FB5	CA C1 1A	JP	Z,#1AC1		; yes, jump back without bothering to change the ghost colors
;	1FB8	DD 36 03 11  	LD	(IX+#03),#11	; else set red ghost color to blue
; 	1FBC	C3 B5 1A	JP	#1AB5		; return and change rest of ghosts to blue and continue normally
; 	1FBF    55 80					; checksum fixes
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

1FC0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1FD0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1FE0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1FF0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00

1FFE:  5D E1				; checksum bytes for #1000 to #1FFF

    

	;; fast/invincibilty ; HACK3
	;  Collision detection elimination

	; 1fb0  21a64d    ld      hl,#4da6  
	; 1fb3  5f        ld      e,a       
	; 1fb4  1600      ld      d,#00
	; 1fb6  19        add     hl,de     
	; 1fb7  7e        ld      a,(hl)    
	; 1fb8  a7        and     a
	; 1fb9  cac31f    jp      z,#1fc3
	; 1fbc  78        ld      a,b
	; 1fbd  32a44d    ld      (#4da4),a 
	; 1fc0  c36717    jp      #1767
	; 1fc3  3a4050    ld      a,(#5040)	; IN1
	; 1fc6  e620      and     #20		; Start 1
	; 1fc8  c8        ret     z		; not pressed, return
	; 1fc9  78        ld      a,b      
	; 1fca  32a44d    ld      (#4da4),a
	; 1fcd  c36717    jp      #1767 

	;; fast intermission fix ; HACK8 (2 of 3)

	; 1fc0  3a044e    ld      a, (#4e04)	; load in game mode
	; 1fc3  fe03      cp      #03		; ghost move mode (gameplay)
	; 1fc5  ca4518    jp      z, #1845	; return to the middle of an opcode?
	; 1fc7  3eff      ld      a, #ff	; a = 0xff
	; 1fc9  be        cp      (hl)
	; 1fca  ca1118    jp      z, #1811
	; 1fcd  35        dec     (hl)
	; 1fce  c9        ret


	;; fast/invincibilty ; HACK3
	;  Speedup

	; 1fd0  3a4050    ld      a,(#5040)	; IN1
	; 1fd3  cb77      bit     6,a       	; Start 2
	; 1fd5  ca4518    jp      z,#1845  	; not pressed, jp to 1845
	; 1fd8  3eff      ld      a,#ff     
	; 1fda  be        cp      (hl)     
	; 1fdb  ca1118    jp      z,#1811   
	; 1fde  35        dec     (hl)      
	; 1fdf  c9        ret
     
	; set to 0xbd for fast cheat checksum check hack  ; HACK2 (2 of 2)

	; 1ffd  00        nop     
	; 1ffe  5d e1

	; fast/invincibilty checksum ; HACK3

	; 1ffe bf dc

	;; fast intermission fix ; HACK8 (3 of 3)

	; 1ffe 8A 6D 



	;; this is a common function
	; IY is preloaded with sprite locations
	; IX is preloaded with offset to add
	; result is stored into HL
	; HL := (IX) + (IY)

2000  fd7e00    ld      a,(iy+#00)	; load A with IY value (Y position)
2003  dd8600    add     a,(ix+#00)	; add with destination Y value
2006  6f        ld      l,a		; store result into L
2007  fd7e01    ld      a,(iy+#01)	; load A with IY value (X position)
200a  dd8601    add     a,(ix+#01)	; add with destination X value
200d  67        ld      h,a		; store result into H
200e  c9        ret     		; return

; load A with screen value of position computed in (IX) + (IY)

200f  cd0020    call    #2000		; HL := (IX) + (IY)
2012  cd6500    call    #0065		; convert to screen position
2015  7e        ld      a,(hl)		; load A with the value in this screen position
2016  a7        and     a		; clear flags
2017  c9        ret     		; return

; converts a sprite position into a tile position
; HL is preloaded with sprite position
; at end, HL is loaded with tile position

2018  7d        ld      a,l		; load A with X position
2019  cb3f      srl     a
201b  cb3f      srl     a
201d  cb3f      srl     a		; shift right 3 times
201f  c620      add     a,#20		; add offset
2021  6f        ld      l,a		; store into L
2022  7c        ld      a,h		; load A with Y position
2023  cb3f      srl     a
2025  cb3f      srl     a
2027  cb3f      srl     a		; shift right 3 times
2029  c61e      add     a,#1e		; add offset
202b  67        ld      h,a		; store into H.  HL now has screen location
202c  c9        ret     		; return

; converts pac-mans sprite position into a grid position
; HL has sprite position at start, grid position at end
; 0065 jumps to here. 

202D: F5            push af		; save AF
202E: C5            push bc		; save BC
202F: 7D            ld   a,l		; load A with L.  
2030: D6 20         sub  #20		; subtract #20.  
2032: 6F            ld   l,a		; store back into L. 
2033: 7C            ld   a,h		; load A with H.  
2034: D6 20         sub  #20		; subtract 20.  
2036: 67            ld   h,a		; store back into H. 
2037: 06 00         ld   b,#00		; load B with #00
2039: CB 24         sla  h		; shift left through carry flag.  mult by 2
203B: CB 24         sla  h
203D: CB 24         sla  h
203F: CB 24         sla  h	 
2041: CB 10         rl   b
2043: CB 24         sla  h
2045: CB 10         rl   b
2047: 4C            ld   c,h
2048: 26 00         ld   h,#00
204A: 09            add  hl,bc		; add into HL
204B: 01 40 40      ld   bc,#4040	; load BC with grid offset
204E: 09            add  hl,bc		; add into HL
204F: C1            pop  bc		; restore BC
2050: F1            pop  af		; restore AF
2051: C9            ret			; return    

; converts pac-man or ghost Y,X position in HL to a color screen location

2052  cd6500    call    #0065		; convert Y,X position to screen position
2055  110004    ld      de,#0400	; load DE with color grid offset
2058  19        add     hl,de		; add offset.  HL now has color screen position
2059  c9        ret     		; return

; checks for ghost entering a slowdown area in a tunnel

205a  cd5220    call    #2052		; convert ghost Y,X position in HL to a color screen location
205d  7e        ld      a,(hl)		; load A with the color of the ghost's location
205e  fe1b      cp      #1b		; == #1b ? (code for no change of direction, eg above the ghost home in pac-man)

; OTTOPATCH
;PATCH TO MAKE BIT 6 OF THE COLOR MAP INDICATE SLOW AREAS
ORG 2060H
JP SLOWMAP
NOP
2060  c36f36    jp      #366f		; jump to new patch for ms. pac man.  if no tunnel match, returns to #2066

2063  00        nop     		; junk from ms-pac patch

	; original pac-man code:
	;
	; 2060: 20 04         jr   nz,$2066	; no, skip ahead
	; 2062: 3E 01         ld   a,$01	; else A := #01
	;

2064  02        ld      (bc),a		; store into ghost tunnel slowdown flag (pac-man only)
2065  c9        ret     		; return (pac-man only)

2066  af        xor     a		; A := #00
2067  02        ld      (bc),a		; store into ghost tunnel slowdown flag
2068  c9        ret     		; return

; called from #105C

2069  3aa14d    ld      a,(#4da1)	; load A with pink ghost substate
206c  a7        and     a		; is the pink ghost at home ?
206d  c0        ret     nz		; no, return

206e  3a124e    ld      a,(#4e12)	; load A with flag that is 1 after dying in a level, reset to 0 if ghosts have left home
2071  a7        and     a		; is this flag set ?
2072  ca7e20    jp      z,#207e		; no, skip ahead

2075  3a9f4d    ld      a,(#4d9f)	; yes, load A with eaten pills counter after pacman has died in a level
2078  fe07      cp      #07		; == #07 ?
207a  c0        ret     nz		; no, return

207b  c38620    jp      #2086		; yes, jump ahead and release pink ghost

207e  21b84d    ld      hl,#4db8	; load HL with address of pink ghost counter to go out of home pill limit
2081  3a0f4e    ld      a,(#4e0f)	; load A with counter incremented if orange, blue and pink ghosts are home and pacman is eating pills.
2084  be        cp      (hl)		; has the counter been exceeded?
2085  d8        ret     c		; no, return

; releases pink ghost from the ghost house
; called from #1408

2086  3e02      ld      a,#02		; A := #02
2088  32a14d    ld      (#4da1),a	; store into pink ghost substate to indicate he is leaving the ghost house
208b  c9        ret     		; return

; called from #105F

208c  3aa24d    ld      a,(#4da2)	; load A with blue ghost (inky) substate
208f  a7        and     a		; is inky at home ?
2090  c0        ret     nz		; no, return

2091  3a124e    ld      a,(#4e12)	; yes, load A with flag that is 1 after dying in a level, reset to 0 if ghosts have left home
2094  a7        and     a		; is this flag set ?
2095  caa120    jp      z,#20a1		; no, skip ahead

2098  3a9f4d    ld      a,(#4d9f)	; yes, load A with eaten pills counter after pacman has died in a level 
209b  fe11      cp      #11		; == #11 ?
209d  c0        ret     nz		; no, return

209e  c3a920    jp      #20a9		; yes, skip ahead and release inky

20a1  21b94d    ld      hl,#4db9	; load HL with address of inky counter to go out of home pill limit
20a4  3a104e    ld      a,(#4e10)	; load A with counter incremented if blue ghost and orange ghost is home and pacman is eating pills.
20a7  be        cp      (hl)		; has the counter been exceeded ?
20a8  d8        ret     c		; no, return

; releases blue ghost (inky) from the ghost house
; called from #1412

20a9  3e03      ld      a,#03		; A := #03
20ab  32a24d    ld      (#4da2),a	; store in inky's ghost state
20ae  c9        ret     		; return

; called from #1062

20af  3aa34d    ld      a,(#4da3)	; load A with orange ghost substate
20b2  a7        and     a		; is orange ghost at home ?
20b3  c0        ret     nz		; no, return

20b4  3a124e    ld      a,(#4e12)	; yes, load A with flag that is 1 after dying in a level, reset to 0 if ghosts have left home
20b7  a7        and     a		; is this flag set ?
20b8  cac920    jp      z,#20c9		; no, skip ahead

20bb  3a9f4d    ld      a,(#4d9f)	; yes, load A with eaten pills counter after pacman has died in a level
20be  fe20      cp      #20		; == #20 ?
20c0  c0        ret     nz		; no, return

20c1  af        xor     a		; yes, A := #00
20c2  32124e    ld      (#4e12),a	; clear flag that is 1 after dying in a level, reset to 0 if ghosts have left home
20c5  329f4d    ld      (#4d9f),a	; clear eaten pills counter after pacman has died in a level
20c8  c9        ret     		; return

20c9  21ba4d    ld      hl,#4dba	; load HL with address of orange ghost to go out of home pill limit
20cc  3a114e    ld      a,(#4e11)	; load A with counter incremented if orange ghost is home alone and pacman is eating pills
20cf  be        cp      (hl)		; has the counter been exceeded ?
20d0  d8        ret     c		; no, return
`
; releases orange ghost from the ghost house
; called from #141b

20d1  3e03      ld      a,#03		; A := #03
20d3  32a34d    ld      (#4da3),a	; store into orange ghost state
20d6  c9        ret     		; return

; checks for and sets the difficulty flags based on number of pellets eaten
; called from #1B40

20d7  3aa34d    ld      a,(#4da3)	; load A with orange ghost state
20da  a7        and     a		; is the ghost living in the ghost house?
20db  c8        ret     z		; yes, return

20dc  210e4e    ld      hl,#4e0e	; load HL with number of pellets eaten address
20df  3ab64d    ld      a,(#4db6)	; load A with first difficulty flag
20e2  a7        and     a		; has flag been set ?
20e3  c2f420    jp      nz,#20f4	; yes, skip ahead

20e6  3ef4      ld      a,#f4		; no, A := #F4
20e8  96        sub     (hl)		; subract number of pellets eaten
20e9  47        ld      b,a		; load B with the result
20ea  3abb4d    ld      a,(#4dbb)	; load A with remainder of pills when first diff. flag is set
20ed  90        sub     b		; subtract the result found above.  is it time to set the flag ?
20ee  d8        ret     c		; no, return

20ef  3e01      ld      a,#01		; A := #01
20f1  32b64d    ld      (#4db6),a	; set 1st difficulty flag so red ghost goes for pacman

20f4  3ab74d    ld      a,(#4db7)	; load A with 2nd difficulty flag
20f7  a7        and     a		; 2nd difficulty flag set yet ?
20f8  c0        ret     nz		; no, return

20f9  3ef4      ld      a,#f4		; else A := #F4
20fb  96        sub     (hl)		; subtract number of pellets eaten
20fc  47        ld      b,a		; save result into B
20fd  3abc4d    ld      a,(#4dbc)	; load A with remainder of pills when second diff. flag is set
2100  90        sub     b		; subract result computed above.  is it time to set the 2nd difficulty flag?
2101  d8        ret     c		; no, return

2102  3e01      ld      a,#01		; yes, A := #01
2104  32b74d    ld      (#4db7),a	; set 2nd difficulty flag
2107  c9        ret     		; return

; arrive here from #0A44 when 1st intermission starts

2108  c33534    jp      #3435		; jump to new ms. pac man routine

; Pac-man code:
; 2108  3a064e	ld	a,(#4e06)
; end pac-man code

; junk from pac-man

210B: E7            rst  #20		; jump based on A
210C: 1A 21				; #211A
210E: 40 21				; #2140
2110: 4B 21				; #214B
2112: 0C 00				; #000C
2114: 70 21				; #2170
2116: 7B 21				; #217B
2118: 86 21				; #2186

211A: 3A 3A 4D	ld	a,(#4D3A)
211D: D6 21	sub	#21
211f  200f      jr      nz,#2130

2121  3c        inc     a
2122  32a04d    ld      (#4da0),a
2125  32b74d    ld      (#4db7),a
2128  cd0605    call    #0506

;

212b  21064e    ld      hl,#4e06	; load HL with state in first cutscene
212e  34        inc     (hl)		; increase
212f  c9        ret     		; return

2130  cd0618    call    #1806
2133  cd0618    call    #1806
2136  cd361b    call    #1b36
2139  cd361b    call    #1b36
213c  cd230e    call    #0e23		; change animation of ghosts every 8th frame
213f  c9        ret     

2140  3a3a4d    ld      a,(#4d3a)
2143  d61e      sub     #1e
2145  c23021    jp      nz,#2130
2148  c32b21    jp      #212b

214b  3a324d    ld      a,(#4d32)
214e  d61e      sub     #1e
2150  c23621    jp      nz,#2136

2153  cd701a    call    #1a70
2156: AF	xor	a		; A: = #00
2157: 32 AC 4E	ld	(#4EAC),a	; clear sound channel 2
215A: 32 BC 4E	ld	(#4EBC),a	; clear sound channel 3
215d  cda505    call    #05a5
2160  221c4d    ld      (#4d1c),hl
2163  3a3c4d    ld      a,(#4d3c)
2166  32304d    ld      (#4d30),a
2169  f7        rst     #30		; set timed task to to increase state in 1st cutscene (#4E06)
216a  45 07 00				; task timer=#45, task=7, param=0     
216d  c32b21    jp      #212b

2170  3a324d    ld      a,(#4d32)
2173  d62f      sub     #2f
2175  c23621    jp      nz,#2136

2178  c32b21    jp      #212b

217b  3a324d    ld      a,(#4d32)
217e  d63d      sub     #3d
2180  c23021    jp      nz,#2130

2183  c32b21    jp      #212b

2186  cd0618    call    #1806
2189  cd0618    call    #1806
218c  3a3a4d    ld      a,(#4d3a)
218f  d63d      sub     #3d
2191  c0        ret     nz

2192  32064e    ld      (#4e06),a
2195  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
2196  45 00 00				; task timer = #45, task = 0, parameter = 0     
2199  21044e    ld      hl,#4e04
219c  34        inc     (hl)		; increase main subroutine number
219d  c9        ret     		; return

; arrive here from #0A44 when 2nd intermission begins

219e  3a074e    ld      a,(#4e07)	; load A with 2nd cutscene subroutine number
21a1  c34f34    jp      #344f		; jump to new code for ms. pac-man

;; pac-man code:
; 21a1  fd21d241  ld      iy,#41d2
;; end pac-man code

; junk from pac-man

21a4  41				; junk
21A5: E7            rst  #20		; jump based on A

21A6: C2 21				; #21C2
21A8: 0C 00				; #000C
21AA: E1 21				; #21E1
21AC: F5 21				; #21F5
21AE: 0C 22				; #220C
21B0: 1E 22				; #221E
21B2: 44 22				; #2244
21B4: 5D 22				; #225D
21B6: 0C 00				; #000C
21B8: 6A 22				; #226A
21BA: 0C 00 				; #000C
21BC: 86 22				; #2286
21BE: 0C 00				; #000C
21C0: 8D 22				; #228D

21C2: 3E 01	ld	a,#01		; 
21C4: 32 D2 45	ld	(#45D2),a	;
21c7  32d345    ld      (#45d3),a
21ca  32f245    ld      (#45f2),a
21cd  32f345    ld      (#45f3),a
21d0  cd0605    call    #0506
21d3  fd360060  ld      (iy+#00),#60
21d7  fd360161  ld      (iy+#01),#61
21db  f7        rst     #30		; set timed task to increase state in 2nd cutscene (#4E07)
21dc  43 08 00				; task timer = #43, task = 8, parameter = 0    
21df  180f      jr      #21f0           ; skip ahead

21e1  3a3a4d    ld      a,(#4d3a)
21e4  d62c      sub     #2c
21e6  c23021    jp      nz,#2130
21e9  3c        inc     a
21ea  32a04d    ld      (#4da0),a
21ed  32b74d    ld      (#4db7),a

;

21f0  21074e    ld      hl,#4e07	; load HL with state in second cutscene
21f3  34        inc     (hl)		; increase
21f4  c9        ret     		; return

21f5  3a014d    ld      a,(#4d01)
21f8  fe77      cp      #77
21fa  2805      jr      z,#2201         ; (5)

21fc  fe78      cp      #78
21fe  c23021    jp      nz,#2130

2201  218420    ld      hl,#2084
2204  224e4d    ld      (#4d4e),hl
2207  22504d    ld      (#4d50),hl
220a  18e4      jr      #21f0           ; (-28)

220c  3a014d    ld      a,(#4d01)
220f  d678      sub     #78
2211  c23722    jp      nz,#2237

2214  fd360062  ld      (iy+#00),#62
2218  fd360163  ld      (iy+#01),#63
221c  18d2      jr      #21f0           ; (-46)

221e  3a014d    ld      a,(#4d01)
2221  d67b      sub     #7b
2223  2012      jr      nz,#2237        ; (18)

2225  fd360064  ld      (iy+#00),#64
2229  fd360165  ld      (iy+#01),#65
222d  fd362066  ld      (iy+#20),#66
2231  fd362167  ld      (iy+#21),#67
2235  18b9      jr      #21f0           ; (-71)

2237  cd0618    call    #1806
223a  cd0618    call    #1806
223d  cd361b    call    #1b36
2240  cd230e    call    #0e23		; change animation of ghosts every 8th frame
2243  c9        ret     

2244  3a014d    ld      a,(#4d01)
2247  d67e      sub     #7e
2249  20ec      jr      nz,#2237        ; (-20)

224b  fd360068  ld      (iy+#00),#68
224f  fd360169  ld      (iy+#01),#69
2253  fd36206a  ld      (iy+#20),#6a
2257  fd36216b  ld      (iy+#21),#6b
225b  1893      jr      #21f0           ; (-109)

225d  3a014d    ld      a,(#4d01)
2260  d680      sub     #80
2262  20d3      jr      nz,#2237        ; (-45)

2264  f7        rst     #30		; set timed task to increase state in 2nd cutscene (#4E07)
2265  4f 08 00				; task timer = #4F, task = 8, parameter = 0     
2268  1886      jr      #21f0           ; jump back

226a  21014d    ld      hl,#4d01
226d  34        inc     (hl)
226e  34        inc     (hl)
226f  fd36006c  ld      (iy+#00),#6c
2273  fd36016d  ld      (iy+#01),#6d
2277  fd362040  ld      (iy+#20),#40
227b  fd362140  ld      (iy+#21),#40
227f  f7        rst     #30		; set timed task to increase state in 2nd cutscene (#4E07)
2280  4a 08 00				; task timer = #4A, task = 8, parameter = 0     
2283  c3f021    jp      #21f0		; jump back

2286  f7        rst     #30		; set timed task to increase state in 2nd cutscene (#4E07)
2287  54 08 00				; task timer = #54, task = 8, parameter = 0    
228a  c3f021    jp      #21f0		; jump back

228d  af        xor     a		; A := #00
228e  32074e    ld      (#4e07),a	; store into cutscene subroutine number
2291  21044e    ld      hl,#4e04	; load HL with main subroutine number
2294  34        inc     (hl)
2295  34        inc     (hl)		; add 2 to main subroutine number
2296  c9        ret     		; return

; arrive here from #0A44 for 3rd intermission

2297  3a084e    ld      a,(#4e08)	; load A with 3rd cutscene subroutine number (pac-man only)
229a  c36934    jp      #3469		; jump to new code for ms. pac-man

;; Pac-man code
; 229a  e7        rst     #20		; jump based on A
; 229b  a7 22		; #22A7
;; end pac-man code

; junk from pac-man

229d  be 22		; #22BE
229e  0c 00		; #000C
22a1  dd 22		; #22DD
22a3  f5 22		; #22F5
22a5  fe 22		; #22FE

; pac-man only

22a7  3a3a4d	ld	a,(#4d3a)
22aa  d625	sub 	#25
22ac  c23021    jp      nz,#2130
22af  3c        inc     a
22b0  32a04d    ld      (#4da0),a
22b3  32b74d    ld      (#4db7),a
22b6  cd0605    call    #0506

; 

22b9  21084e    ld      hl,#4e08	; load HL with state in third cutscene
22bc  34        inc     (hl)		; increase
22bd  c9        ret     		; return

; pac-man only
; referenced in #229D

22be  3a014d    ld      a,(#4d01)
22c1  feff      cp      #ff
22c3  2805      jr      z,#22ca         ; (5)
22c5  fefe      cp      #fe
22c7  c23021    jp      nz,#2130
22ca  3c        inc     a
22cb  3c        inc     a
22cc  32014d    ld      (#4d01),a
22cf  3e01      ld      a,#01
22d1  32b14d    ld      (#4db1),a
22d4  cdfe1e    call    #1efe
22d7  f7        rst     #30		; set timed task to increase state in 3rd cutscene (#4E08)
22d8  4a 09 00				; task timer = #4A, task = 9, parameter = 0     
22db  18dc      jr      #22b9           ; jump back and return

; pac-man only 
; referenced in #22A1

22dd  3a324d    ld      a,(#4d32)
22e0  d62d      sub     #2d
22e2  28d5      jr      z,#22b9         ; (-43)

22e4  3a004d    ld      a,(#4d00)
22e7  32d24d    ld      (#4dd2),a
22ea  3a014d    ld      a,(#4d01)
22ed  d608      sub     #08
22ef  32d34d    ld      (#4dd3),a
22f2  c33021    jp      #2130

22f5  3a324d    ld      a,(#4d32)
22f8  d61e      sub     #1e
22fa  28bd      jr      z,#22b9         ; (-67)

22fc  18e6      jr      #22e4           ; (-26)

; pac-man only
; refereneced in line #22A5

22fe  af        xor     a		; A := #00
22ff  32084e    ld      (#4e08),a	; clear state in third cutscene
2302  f7        rst     #30		; set timed task to increase main subroutine number (#4E04)
2303  45 00 00				; task timer = #45, task = #00, parameter = #00     
2306  21044e    ld      hl,#4e04	; load HL with level state subroutine #
2309  34        inc     (hl)		; increment
230a  c9        ret     		; return

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Main program start (reset)
	;; 0 -> 5000 - 5007  (special registers)
	;; irq off, sound off, flip off, etc.
	;; arrive here from #0005 after game has powered on
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


230b  210050    ld      hl,#5000	; load HL with starting memory address
230e  0608      ld      b,#08		; For B = 1 to 8
2310  af        xor     a		; A := #00
2311  77        ld      (hl),a		; clear memory
2312  2c        inc     l		; next memory
2313  10fc      djnz    #2311           ; next B

	;; Clear screen
	;; 40 -> 4000-43ff (Video RAM)

2315  210040    ld      hl,#4000	; load HL with start of Video RAM
2318  0604      ld      b,#04		; For B = 1 to 4

231a  32c050    ld      (#50c0),a	; kick the dog
231d  320750    ld      (#5007),a	; kick coin counter?
2320  3e40      ld      a,#40		; A := #40 (clear character)

2322  77        ld      (hl),a		; clear screen memory
2323  2c        inc     l		; next address (low byte)
2324  20fc      jr      nz,#2322        ; loop #FF times
2326  24        inc     h		; next address (high byte)
2327  10f1      djnz    #231a           ; Next B

	;; 0f -> 4400 - 47ff (Color RAM)

2329  0604      ld      b,#04		; For B = 1 to 4

232b  32c050    ld      (#50c0),a	; kick the dog
232e  af        xor     a		; A := #00
232f  320750    ld      (#5007),a	; kick coin counter?
2332  3e0f      ld      a,#0f		; A := #0F

2334  77        ld      (hl),a		; set color
2335  2c        inc     l		; next address (low byte)
2336  20fc      jr      nz,#2334        ; loop #FF times
2338  24        inc     h		; next high address
2339  10f0      djnz    #232b           ; Next B

	;; test the interrupt hardware now
	; INTERRUPT MODE 1

233b  ed56      im      1		; set interrupt mode 1
	
233d  00        nop 		   	; no other setup is necessary..
233e  00        nop     		; interrupts all go through 0x0038
233f  00        nop     
2340  00        nop     

	; Pac's routine: (Puckman, Pac-Man Plus)
	; INTERRUPT MODE 2
	; 233b  ed5e      im      2		; interrupt mode 2
	; 233d  3efa      ld      a,#fa
	; 233f  d300      out     (#00),a	; interrupt vector -> 0xfa #3ffa vector to #3000
	; see also "INTERRUPT MODE 2" above...


2341  af        xor     a		; A := #00
2342  320750    ld      (#5007),a	; clear coin counter
2345  3c        inc     a		; A := #01    (a++)
2346  320050    ld      (#5000),a	; Enable interrupts (pcb)
2349  fb        ei			; Enable interrupts (cpu)
234a  76        halt			; WAIT for interrupt then jump 0x0038 

		
	;; main program init
	;; perhaps a contiuation from 3295

234b  32c050    ld      (#50c0),a	; kick dog
234e  31c04f    ld      sp,#4fc0	; set stack pointer

	;; reset custom registers.  Set them to 0

2351  af        xor     a		; A := #00
2352  210050    ld      hl,#5000	; load HL with starting address #5000
2355  010808    ld      bc,#0808	; load counters with #08 and #08
2358  cf        rst     #8		; clear #5000 through #5007

	;; clear ram

2359  21004c    ld      hl,#4c00	; load HL with start of RAM
235c  06be      ld      b,#be		; load counter with #BE
235e  cf        rst     #8		; clear #4000 through #40BD
235f  cf        rst     #8		; clear #40BE through #41BD
2360  cf        rst     #8		; clear #41BE through #42BD
2361  cf        rst     #8		; clear #42BE through #43BD

	;; clear sound registers, color ram, screen, task list 

2362  214050    ld      hl,#5040	; load HL with start of sound output
2365  0640      ld      b,#40		; set counter at #40
2367  cf        rst     #8		; clear #5040 through #5079

2368  32c050    ld      (#50c0),a	; kick dog
236b  cd0d24    call    #240d		; clear color ram
236e  32c050    ld      (#50c0),a	; kick dog
2371  0600      ld      b,#00		; set parameter to clear entire screen
2373  cded23    call    #23ed		; clear entire screen
2376  32c050    ld      (#50c0),a	; kick dog
2379  21c04c    ld      hl,#4cc0	; HL := #4CC0
237c  22804c    ld      (#4c80),hl	; store into  pointer to the end of the tasks list
237f  22824c    ld      (#4c82),hl	; store into  pointer to the beginning of the tasks list
2382  3eff      ld      a,#ff		; set data to #FF
2384  0640      ld      b,#40		; set counter to #40
2386  cf        rst     #8		; store data into #4CC0 through #4CFF = clears task list
2387  3e01      ld      a,#01		; A := #01
2389  320050    ld      (#5000),a 	; enable software interrupts
238C: FB	ei			; enable hardware interrupts

; process the task list, a core game loop

238d  2a824c    ld      hl,(#4c82)	; load HL with the pointer to beginning of tasks list
2390  7e        ld      a,(hl)		; load A with the task value
2391  a7        and     a		; examine value
2392  fa8d23    jp      m,#238d		; if sign negative (EG #FF), loop again; nothing to do

2395  36ff      ld      (hl),#ff	; else store #FF into task value
2397  2c        inc     l		; next task parameter
2398  46        ld      b,(hl)		; load B with task parameter
2399  36ff      ld      (hl),#ff	; store #FF into task parameter value
239b  2c        inc     l		; next task
239c  2002      jr      nz,#23a0        ; If HL has not reached #4C00 then skip next step
239e  2ec0      ld      l,#c0		; else load L with #C0 to make HL #4CC0
23a0  22824c    ld      (#4c82),hl	; store result into the task pointer

23A3: 21 8D 23	ld	hl,#238D	; load HL with return address
23A6: E5	push	hl		; push to stack
23A7: E7	rst	#20		; jump based on A

23A8: ED 23				; #23ED	; A=00	; clears the whole screen if parameter == 0, just the maze if parameter == 1
23AA: D7 24				; #24D7	; A=01	; colors the maze depending on parameter. if parameter == 2, then color maze white
23AC: 19 24				; #2419	; A=02	; draws the maze
23AE: 48 24				; #2448	; A=03	; draws the pellets
23B0: 3D 25				; #253D	; A=04	; resets a bunch of memories based on parameter 0 or 1
23B2: 8B 26				; #268B	; A=05	; resets ghost home counter and if parameter = 1, sets red ghost to chase pac man
23B4: 0D 24				; #240D	; A=06	; clears the color RAM
23B6: 98 26				; #2698	; A=07	; set game to demo mode
23B8: 30 27				; #2730	; A=08	; red ghost AI
23BA: 6C 27				; #276C	; A=09	; pink ghost AI
23BC: A9 27				; #27A9	; A=0A	; blue ghost (inky) AI	
23BE: F1 27				; #27F1	; A=0B	; orange ghost AI	
23C0: 3B 28				; #283B	; A=0C	; red ghost movement when power pill active
23C2: 65 28				; #2865	; A=0D	; pink ghost movement when power pill active
23C4: 8F 28				; #288F	; A=0E	; blue ghost (inky) movement when power pill active
23C6: B9 28				; #28B9	; A=0F	; orange ghost movement when power pill active
23C8: 0D 00				; #000D	; A=10	; sets up difficulty
23CA: A2 26				; #26A2	; A=11	; clears memories from #4D00 through #4DFF
23CC: C9 24				; #24C9	; A=12	; sets up coded pills and power pills memories
23CE: 35 2A 				; #2A35	; A=13	; clears the sprites
23D0: D0 26 				; #26D0	; A=14	; checks all dip switches and assigns memories to the settings indicated
23D2: 87 24				; #2487	; A=15	; update the current screen pill config to video ram
23D4: E8 23				; #23E8	; A=16	; increase main subroutine number (#4E04)
23D6: E3 28				; #28E3	; A=17	; controls pac-man AI during demo.  pacman will avoid pink ghost, or chase it when red ghost is edible
23D8: E0 2A				; #2AE0	; A=18	; draws "high score" and scores.  clears player 1 and 2 scores to zero.
23DA: 5A 2A 				; #2A5A	; A=19	; update score.  B has code for items scored, draw score on screen, check for high score and extra lives
23DC: 6A 2B				; #2B6A	; A=1A	; draws remaining lives at bottom of screen
23DE: EA 2B				; #2BEA	; A=1B	; draws fruit at bottom right of screen

; OTTOPATCH
;MISCELLANEOUS HACKS THAT OCCUR WHEN PROMPTS ARE WRITTEN.
!    ORG 23E0H
!    WORD PROMPTHACKS
23E0: E3 95				; #95E3	; A=1C	; used to draw text and some other functions  ; parameter lookup for text found at #36a5
23E2: A1 2B				; #2BA1	; A=1D	; write # of credits on screen
23E4: 75 26				; #2675	; A=1E	; clear fruit, pacman, and all ghosts
23E6: B2 26				; #26B2	; A=1F	; writes points needed for extra life digits to screen

23E8: 21 04 4E	ld	hl,#4E04	; load HL with main subroutine number
23EB: 34	inc	(hl)		; increase
23EC: C9	ret			; return

; task #00, called from #23A7

23ED: 78	ld	a,b		; load A with parameter
23EE: E7	rst	#20		; jump based on A
23EF: F3 23				; #23F3		; clears entire screen
23F1: 00 24				; #2400		; clears the maze

; clears the entire screen

23F3  3E 40	ld	a,#40		; A := #40 (clear character)
23f5  010400    ld	bc,#0004	; set up counters
23f8  210040    ld      hl,#4000	; start of video ram
23fb  cf        rst     #8		; clear the screen
23fc  0d        dec     c		; loop done?
23fd  20fc      jr      nz,#23fb        ; no, loop again
23ff  c9        ret     		; return

; clears the maze only

2400  3e40      ld      a,#40		; A := #40 (clear character)
2402  214040    ld      hl,#4040	; load HL with start of maze area of screen
2405  010480    ld      bc,#8004	; set up counters
2408  cf        rst     #8		; clear screen memory
2409  0d        dec     c		; loop done ?
240a  20fc      jr      nz,#2408        ; no, loop again
240c  c9        ret     		; yes, return

; clears color ram

240d  af        xor     a		; A := #00
240e  010400    ld      bc,#0004	; set up counters
2411  210044    ld      hl,#4400	; load hL with start of color ram
2414  cf        rst     #8		; clear color ram
2415  0d        dec     c		; loop done ?
2416  20fc      jr      nz,#2414        ; no, loop again
2418  c9        ret    			; return

	;; Draw out the maze to the screen

2419  210040    ld      hl,#4000	; load HL with start of video ram

; OTTOPATCH
;PATCH TO USE A MAZE FROM THE NEW MAZE TABLE RATHER THAN THE OLD MAZE
ORG 241CH
CALL WALLADR
241c  cd6a94    call    #946a		; ms. pac patch to retreive map info.  loads BC based on the map

241f  0a        ld      a,(bc)		; get maze data
2420  a7        and     a		; == #00 ?
2421  c8        ret     z		; yes, the end of the level data, return
2422  fa2c24    jp      m,#242c		; if it's < #80, data is an offset.  if not, jump ahead
2425  5f        ld      e,a		; else copy to E
2426  1600      ld      d,#00		; D := #00
2428  19        add     hl,de		; adjust VRAM pointer
2429  2b        dec     hl		; decrease to offset the upcoming increase
242a  03        inc     bc		; point to next data
242b  0a        ld      a,(bc)		; load next data from table

242c  23        inc     hl		; screen location
242d  77        ld      (hl),a		; store maze data to screen
242e  f5        push    af		; save AF
242f  e5        push    hl		; save HL
2430  11e083    ld      de,#83e0	; load DE with mirror position offset
2433  7d        ld      a,l		; load A with L
2434  e61f      and     #1f		; mask bits
2436  87        add     a,a		; A := A * 2
2437  2600      ld      h,#00		; H := #00
2439  6f        ld      l,a		; load L with A
243a  19        add     hl,de		; add offset to HL
243b  d1        pop     de		; restore HL into DE
243c  a7        and     a		; clear carry flag
243d  ed52      sbc     hl,de		; subtract offset
243f  f1        pop     af		; restore AF
2440  ee01      xor     #01		; flip bit 1 of maze data = calculate reflected maze tile
2442  77        ld      (hl),a		; store reflected tile in position
2443  eb        ex      de,hl		; DE <-> HL
2444  03        inc     bc		; next data
2445  c31f24    jp      #241f		; loop again

	; draw out the player pills

2448  210040    ld      hl,#4000	; load HL with start of video ram
; OTTOPATCH
;PATCH TO DO SAME THING FOR DOTS
;NOTE THAT THE DOT TABLE IS USED TWICE, ONCE TO WRITE THE DOTS ONTO
;THE SCREEN THEN AGAIN TO SEE WHICH DOTS HAVE BEEN EATEN.
ORG 244BH
JP DOTSA1

244b  c37c94    jp      #947c		; jump to ms pac patch.  it returns to #2453

244e  4e				; junk
244f  fd21b535  ld      iy,#35b5	; points to pill data (pac-man only)

2453  1600      ld      d,#00		; D := #00
2455  061e      ld      b,#1e		; load B with total # of pill entries

2457  0e08      ld      c,#08		; C := #08
2459  dd7e00    ld      a,(ix+#00)	; load A with pill entry

245c  fd5e00    ld      e,(iy+#00)	; load E with current offset
245f  19        add     hl,de		; adjust vram
2460  07        rlca    		; rotate left.  was there a bit at bit 7 ?
2461  3002      jr      nc,#2465        ; skip pill if no
2463  3610      ld      (hl),#10	; else draw pill onscreen
2465  fd23      inc     iy		; next table data
2467  0d        dec     c		; decrease counter
2468  20f2      jr      nz,#245c        ; loop again if not zero

246a  dd23      inc     ix		; go to next pill entry
246c  05        dec     b		; decrease counter
246d  20e8      jr      nz,#2457        ; loop again if not zero

246f  21344e    ld      hl,#4e34	; load HL with power pills data entries address

; OTTOPATCH
;PATCH TO USE NEW ENERGIZER LOCATIONS
ORG 2472H
JP DRAWEN
2472  c3ec94    jp      #94ec		; jump to ms pac patch for power pellet drawing

	; pac's version:
;2472  116440	ld	de,#4064	; power pellet address (upper right)

	; pac-man only:
2475  eda0      ldi     
2477  117840    ld      de,#4078	; power pellet address (lower right)
247a  eda0      ldi     
247c  118443    ld      de,#4384	; power pellet address (upper left)
247f  eda0      ldi     
2481  119843    ld      de,#4398	; power pellet address (lower left)
2484  eda0      ldi     
2486  c9        ret			; return  

	;; update the current screen pill config to video ram
	; called from #0912
	; called from #23A7 as task #15

2487  210040    ld      hl,#4000	; load HL with start of video ram

; OTTOPATCH
ORG 248AH
JP DOTSA2
248a  c38194    jp      #9481		; jump to Ms Pac Man patch.  returns to #2492.  Loads IY with start of pellet table based on level

248d  4e				; junk
	; pac's version:
;248a  dd21164e  ld      ix,#4e16

248e  fd21b535  ld      iy,#35b5	; load IY with start of pill data table (pac-man only)

2492  1600      ld      d,#00		; D := #00
2494  061e      ld      b,#1e		; B := #1E (used for loop counter)
2496  0e08      ld      c,#08		; C := #08 (used for loop counter)

2498  fd5e00    ld      e,(iy+#00)	; load E with pellet data
249b  19        add     hl,de		; add to video ram counter
249c  7e        ld      a,(hl)		; load A with the value that is already there
249d  fe10      cp      #10		; == #10 ?  (is there a dot on the screen ?)
249f  37        scf     		; set carry flag
24a0  2801      jr      z,#24a3         ; if equal then skip next step
24a2  3f        ccf     		; invert the carry flag
24a3  ddcb0016  rl      (ix+#00)	; rotate left.  sets or clears the bit used for this code
24a7  fd23      inc     iy		; next pellet
24a9  0d        dec     c		; decrease counter.   is this loop done ?
24aa  20ec      jr      nz,#2498        ; no, loop again

24ac  dd23      inc     ix		; next coded address
24ae  05        dec     b		; decrease counter.  is this loop done?
24af  20e5      jr      nz,#2496        ; no, loop again

24b1  216440    ld      hl,#4064	; load HL with power pellet address

; OTTOPATCH
ORG 24B4H
JP READEN
24b4  c30495    jp      #9504		; jump to ms. pac patch for pellet check routine and return

	; pac's version:
; 24b4  11344e    ld      de,#4e34	;  power pellet address
	;

	; this code is pac-man only:

24b7  eda0      ldi     
24b9  217840    ld      hl,#4078	;  power pellet address
24bc  eda0      ldi     
24be  218443    ld      hl,#4384	;  power pellet address
24c1  eda0      ldi     
24c3  219843    ld      hl,#4398	;  power pellet address
24c6  eda0      ldi     
24c8  c9        ret     

; called from #23A7 as task #12
; called from #0880, #0a89, and other places
; sets up the pills and power pills??

24c9  21164e    ld      hl,#4e16	; load HL with pill address start
24cc  3eff      ld      a,#ff		; A := #FF
24ce  061e      ld      b,#1e		; load counter with #1E addresses to fill
24d0  cf        rst     #8		; store #FF into #4E16 through #4E16 + #1E
24d1  3e14      ld      a,#14		; A := #14
24d3  0604      ld      b,#04		; load counter with #04
24d5  cf        rst     #8		; store #14 into next 4 addresses (power pills)
24d6  c9        ret     		; return

; sets up the maze color
; called from #23A7 as task #01

24d7  58        ld      e,b		; save task parameter to E, for use later at #24F3
24d8  78        ld      a,b		; load A with task parameter
24d9  fe02      cp      #02		; == # 02 ?
24db  3e1f      ld      a,#1f		; load A with #1F = white color for flashing at end of level

; OTTOPATCH
;PATCH TO CALL AMAZING NEW COLOR ROUTINE INSTEAD OF USING THE SAME DULL BLUE
ORG 24DDH
24dd  c38095    jp      #9580		; jump to new sub to select screen color (ms pac patch.  returns to #24E1)

;; Pac-man code:
; 24dd  2802      jr      z,#24e1	; was the task parameter set for white ?  Yes, skip next step
; 24df  3e10      ld      a,#10		; no, set color to blue
;; end pac-man code

24e0  10				; junk from pac-man

; arrive back here from ms pac patch

24e1  214044	ld	hl,#4440	; load HL with screen color RAM start addr.
24e4  010480    ld      bc,#8004	; load counters (#80 * #4 = #200 (or 512 decimal) screen locations)

24e7  cf        rst     #8		; color the screen
24e8  0d        dec     c		; decrease counter. are we done?
24e9  20fc      jr      nz,#24e7        ; no, loop again

24eb  3e0f      ld      a,#0f		; else load A with white color
24ed  0640      ld      b,#40		; load counter with #40
24ef  21c047    ld      hl,#47c0	; start address at top left of screen
24f2  cf        rst     #8		; color top bar white
24f3  7b        ld      a,e		; load A with E, this is the task parameter saved at #24D7
24f4  fe01      cp      #01		; == #01 ?
24f6  c0        ret     nz		; no, return

24f7  3e1a      ld      a,#1a		; else A := #1A.  this is the color code to prevent ghosts from changing directions above the ghost house and next to where pacman starts

; OTTOPATCH
;PATCH TO MAKE THE SLOW AREAS OF THE SCREEN DEPENDENT ON THE MAZE
ORG 24F9H
JP SCOLOR
24f9  c3c395    jp      #95c3		; jump to new ms. pac man patch to color the tunnels with invisible slowdown "paint".  returns to #2534

;; Pac-man code:
; 24f9  112000    ld      de,#0020	; load DE with column offset
;; end pac-man code


; pac-man only

24fc  0606      ld      b,#06		; for B = 1 to 6
24fe  dd21a045  ld      ix,#45a0	; load IX with start of color memory (near center right of screen)

2502  dd770c    ld      (ix+#0c),a	; paint area above ghost house with color code to prevent changing directions
2505  dd7718    ld      (ix+#18),a	; paint area above pacman start area with color code to prevent changing directions
2508  dd19      add     ix,de		; add offset for next column
250a  10f6      djnz    #2502           ; loop until done

250c  3e1b      ld      a,#1b		; load A with color code to slow down ghosts in tunnel
250e  0605      ld      b,#05		; for B = 1 to 5
2510  dd214044  ld      ix,#4440	; load IX with start of color memory

2514  dd770e    ld      (ix+#0e),a	; paint tunnel with slowdown color
2517  dd770f    ld      (ix+#0f),a	; paint tunnel with slowdown color
251a  dd7710    ld      (ix+#10),a	; paint tunnel with slowdown color
251d  dd19      add     ix,de		; add offset for next column
251f  10f3      djnz    #2514           ; loop until done

2521  0605      ld      b,#05		; for B = 1 to 5
2523  dd212047  ld      ix,#4720	; load IX with start of color memory for left side of screen
2527  dd770e    ld      (ix+#0e),a	; paint tunnel with slowdown color
252a  dd770f    ld      (ix+#0f),a	; paint tunnel with slowdown color
252d  dd7710    ld      (ix+#10),a	; paint tunnel with slowdown color
2530  dd19      add     ix,de		; add offset for next column
2532  10f3      djnz    #2527           ; loop until done

; ms. pac resumes here

2534  3e18      ld      a,#18		; A := #18 = code for pink color
2536  32ed45    ld      (#45ed),a	; store into ghost house door (right side) color
2539  320d46    ld      (#460d),a	; store into ghost house door (left side) color
253c  c9        ret     		; return

; called from #23A7 for task #04
; resets a bunch of memories to predefined values

253d  dd21004c  ld      ix,#4c00
2541  dd360220  ld      (ix+#02),#20	; set red ghost sprite
2545  dd360420  ld      (ix+#04),#20	; set pink ghost sprite
2549  dd360620  ld      (ix+#06),#20	; set inky sprite
254d  dd360820  ld      (ix+#08),#20	; set orange ghost sprite
2551  dd360a2c  ld      (ix+#0a),#2c	; set ms pac sprite
2555  dd360c3f  ld      (ix+#0c),#3f	; set fruit sprite
2559  dd360301  ld      (ix+#03),#01	; set red ghost color
255d  dd360503  ld      (ix+#05),#03	; set pink ghost color
2561  dd360705  ld      (ix+#07),#05	; set inky color
2565  dd360907  ld      (ix+#09),#07	; set orange ghost color
2569  dd360b09  ld      (ix+#0b),#09	; set ms pac color
256d  dd360d00  ld      (ix+#0d),#00	; set fruit color

2571  78        ld      a,b		; load task parameter
2572  a7        and     a		; == #00 ?
2573  c20f26    jp      nz,#260f	; no, skip ahead

2576  216480    ld      hl,#8064
2579  22004d    ld      (#4d00),hl	; set red ghost position
257c  217c80    ld      hl,#807c
257f  22024d    ld      (#4d02),hl	; set pink ghost position
2582  217c90    ld      hl,#907c
2585  22044d    ld      (#4d04),hl	; set inky position
2588  217c70    ld      hl,#707c
258b  22064d    ld      (#4d06),hl	; set orange ghost position
258e  21c480    ld      hl,#80c4
2591  22084d    ld      (#4d08),hl	; set ms pac position
2594  212c2e    ld      hl,#2e2c
2597  220a4d    ld      (#4d0a),hl	; set red ghost tile position
259a  22314d    ld      (#4d31),hl	; set red ghost tile position 2
259d  212f2e    ld      hl,#2e2f
25a0  220c4d    ld      (#4d0c),hl	; set pink ghost tile position
25a3  22334d    ld      (#4d33),hl	; set pink ghost tile position 2
25a6  212f30    ld      hl,#302f
25a9  220e4d    ld      (#4d0e),hl	; set inky tile position
25ac  22354d    ld      (#4d35),hl	; set inky tile position 2
25af  212f2c    ld      hl,#2c2f
25b2  22104d    ld      (#4d10),hl	; set orange ghost tile position
25b5  22374d    ld      (#4d37),hl	; set orange ghost tile position 2
25b8  21382e    ld      hl,#2e38
25bb  22124d    ld      (#4d12),hl	; set pacman tile position
25be  22394d    ld      (#4d39),hl	; set pacman tile position 2
25c1  210001    ld      hl,#0100
25c4  22144d    ld      (#4d14),hl	; set red ghost tile changes
25c7  221e4d    ld      (#4d1e),hl	; set red ghost tile changes 2
25ca  210100    ld      hl,#0001
25cd  22164d    ld      (#4d16),hl	; set pink ghost tile changes
25d0  22204d    ld      (#4d20),hl	; set pink ghost tile changes 2
25d3  21ff00    ld      hl,#00ff
25d6  22184d    ld      (#4d18),hl	; set inky tile changes
25d9  22224d    ld      (#4d22),hl	; set inky tile changes 2
25dc  21ff00    ld      hl,#00ff
25df  221a4d    ld      (#4d1a),hl	; set orange ghost tile changes
25e2  22244d    ld      (#4d24),hl	; set orange ghost tile changes 2
25e5  210001    ld      hl,#0100
25e8  221c4d    ld      (#4d1c),hl	; set pacman tile changes
25eb  22264d    ld      (#4d26),hl	; set pacman tile changes 2
25ee  210201    ld      hl,#0102
25f1  22284d    ld      (#4d28),hl	; set previous red and pink ghost orientation
25f4  222c4d    ld      (#4d2c),hl	; set red and pink ghost orientation
25f7  210303    ld      hl,#0303
25fa  222a4d    ld      (#4d2a),hl	; set previous blue and orange ghost orientation
25fd  222e4d    ld      (#4d2e),hl	; set blue and orange ghost orientation
2600  3e02      ld      a,#02
2602  32304d    ld      (#4d30),a	; set pacman orientation
2605  323c4d    ld      (#4d3c),a	; set wanted pacman orientation
2608  210000    ld      hl,#0000
260b  22d24d    ld      (#4dd2),hl	; set fruit position
260e  c9        ret     		; return

; pac-man only, sets up sprites for character introduction screen

260f  219400    ld      hl,#0094
2612  22004d    ld      (#4d00),hl
2615  22024d    ld      (#4d02),hl
2618  22044d    ld      (#4d04),hl
261b  22064d    ld      (#4d06),hl
261e  21321e    ld      hl,#1e32
2621  220a4d    ld      (#4d0a),hl
2624  220c4d    ld      (#4d0c),hl
2627  220e4d    ld      (#4d0e),hl
262a  22104d    ld      (#4d10),hl
262d  22314d    ld      (#4d31),hl
2630  22334d    ld      (#4d33),hl
2633  22354d    ld      (#4d35),hl
2636  22374d    ld      (#4d37),hl
2639  210001    ld      hl,#0100
263c  22144d    ld      (#4d14),hl
263f  22164d    ld      (#4d16),hl
2642  22184d    ld      (#4d18),hl
2645  221a4d    ld      (#4d1a),hl
2648  221e4d    ld      (#4d1e),hl
264b  22204d    ld      (#4d20),hl
264e  22224d    ld      (#4d22),hl
2651  22244d    ld      (#4d24),hl
2654  221c4d    ld      (#4d1c),hl
2657  22264d    ld      (#4d26),hl
265a  21284d    ld      hl,#4d28
265d  3e02      ld      a,#02
265f  0609      ld      b,#09
2661  cf        rst     #8
2662  323c4d    ld      (#4d3c),a
2665  219408    ld      hl,#0894
2668  22084d    ld      (#4d08),hl
266b  21321f    ld      hl,#1f32
266e  22124d    ld      (#4d12),hl
2671  22394d    ld      (#4d39),hl
2674  c9        ret			; return

; called from #136E after mspac has died
; called from #23A7 as task #1E

2675  210000    ld      hl,#0000	; HL := #0000
2678  22d24d    ld      (#4dd2),hl	; clear fruit position
267b  22084d    ld      (#4d08),hl	; clear pacman position

; called from #09F6

267e  22004d    ld      (#4d00),hl	; clear red ghost
2681  22024d    ld      (#4d02),hl	; clear pink ghost
2684  22044d    ld      (#4d04),hl	; clear blue ghost (inky)
2687  22064d    ld      (#4d06),hl	; clear orange ghost
268a  c9        ret     		; return

; task #05 called from #23A7

268b  3e55      ld      a,#55
268d  32944d    ld      (#4d94),a	; store #55 into counter related to ghost movement inside home
2690  05        dec     b		; check parameter
2691  c8        ret     z		; return if parameter == #00

2692  3e01      ld      a,#01
2694  32a04d    ld      (#4da0),a	; else store #01 into red ghost substate.  makes red ghost chase pac man.
2697  c9        ret     		; return

; sets demo mode

2698  3e01      ld      a,#01		; A := #01
269a  32004e    ld      (#4e00),a	; store into game mode, selects demo mode is starting
269d  af        xor     a		; A := #00
269e  32034e    ld      (#4e03),a	; store into subroutine #
26a1  c9        ret     		; return

; task #11 called from #23A7

26a2  af        xor     a		; A := #00
26a3  11004d    ld      de,#4d00	; load DE with starting address

26a6  21004e    ld      hl,#4e00	; load HL with ending address
26a9  12        ld      (de),a		; store #00 into memory location
26aa  13        inc     de		; next address
26ab  a7        and     a		; clear carry flag
26ac  ed52      sbc     hl,de		; subtract offset.  are we done ?
26ae  c2a626    jp      nz,#26a6	; no, loop again

26b1  c9        ret     		; return

; called from #23A7 as task #1F
; writes points needed for extra life digits to screen

26b2  dd213641  ld      ix,#4136	; load IX with screen position
26b6  3a714e    ld      a,(#4e71)	; load A with points needed for bonus life (#10, #15, #20 or #FF)
26b9  e60f      and     #0f		; mask out left digit bits
26bb  c630      add     a,#30		; add #30, gives ascii code for this digit
26bd  dd7700    ld      (ix+#00),a	; write digit to screen
26c0  3a714e    ld      a,(#4e71)	; load A with points needed for bonus life (#10, #15, #20 or #FF) 
26c3  0f        rrca    
26c4  0f        rrca    
26c5  0f        rrca    
26c6  0f        rrca    		; rotate right 4 times.  A now has the tens digit
26c7  e60f      and     #0f		; mask out left digit bits
26c9  c8        ret     z		; return if zero (when would this happen?)

26ca  c630      add     a,#30		; add #30, gives ascii code for this digit
26cc  dd7720    ld      (ix+#20),a	; write digit to screen
26cf  c9        ret     		; return

; check dip switches 0 and 1 .  Free play or coins per credit

26d0  3a8050    ld      a,(#5080)	; load A with Dip Switch
26d3  47        ld      b,a		; copy to B
26d4  e603      and     #03		; mask bits 0000 0011 - is free play set in the DIP ?
26d6  c2de26    jp      nz,#26de	; no, skip ahead

26d9  216e4e    ld      hl,#4e6e	; yes, load HL with credit memory address
26dc  36ff      ld      (hl),#ff	; store #FF to indicate free play
26de  4f        ld      c,a		; load C with result computed above
26df  1f        rra     		; roll right = moves bit 0 to the carry bit and carry flag to bit 7
26e0  ce00      adc     a,#00		; A := #00 plus carry bit
26e2  326b4e    ld      (#4e6b),a	; store into coins per credit
26e5  e602      and     #02		; mask bits 0000 0010 
26e7  a9        xor     c		; XOR with original result.  this will toggle bit 1 on or off
26e8  326d4e    ld      (#4e6d),a	; store into number of credits per coin

; check dip switches 2 and 3.  number of starting lives per game

26eb  78        ld      a,b		; load A with Dip Switch original value from #5080
26ec  0f        rrca    		; 
26ed  0f        rrca    		; roll right twice
26ee  e603      and     #03		; mask bits.  how many pacmen per game?
26f0  3c        inc     a		; increment
26f1  fe04      cp      #04		; == #04 ?  (swtich set of 3 which gives 5 pacmen per game)
26f3  2001      jr      nz,#26f6        ; no, skip next step
26f5  3c        inc     a		; increment
26f6  326f4e    ld      (#4e6f),a	; store result into # of pacmen per game

; check dip switches 4 and 5.  points for bonus pac man

26f9  78        ld      a,b		; load A with Dip switch
26fa  0f        rrca    
26fb  0f        rrca    
26fc  0f        rrca    
26fd  0f        rrca 			; roll right four times   
26fe  e603      and     #03		; mask bits - checks score for bonus packman
2700  212827    ld      hl,#2728	; load HL with start of table for this option
2703  d7        rst     #10		; A := (HL + A).  loads A with table value based on dip switch setting
2704  32714e    ld      (#4e71),a	; store result into extra life setting

; check dip switch 7 for ghost names during attract mode

2707  78        ld      a,b		; load A with Dip Switch
2708  07        rlca    		; rotate left with bit 7 moved to bit 0
2709  2f        cpl			; invert A (one's complement)
270a  e601      and     #01		; mask bits
270c  32754e    ld      (#4e75),a	; store result into ghost names mode

; check dip switch 6 for difficulty

270f  78        ld      a,b		; load A with Dip Switch
2710  07        rlca    
2711  07        rlca    		; rotate left twice
2712  2f        cpl     		; invert A
2713  e601      and     #01		; mask bits
2715  47        ld      b,a		; copy result to B
2716  212c27    ld      hl,#272c	; load HL with start address of difficulty table
2719  df        rst     #18		; HL := HL + A
271a  22734e    ld      (#4e73),hl	; store into difficulty table lookup

; check bit 7 on IN1 for upright / cocktail

271d  3a4050    ld      a,(#5040)	; load A with IN1
2720  07        rlca    		; rotatle left
2721  2f        cpl     		; invert A
2722  e601      and     #01		; mask bits
2724  32724e    ld      (#4e72),a	; store result into cocktail/upright setting
2727  c9        ret     		; return

	; data - bonus/life
	; called from #2700

2728  10				; 10,000 points
2729  15				; 15,000 points
272A  20				; 20,000 points
272B  FF				; code for no extra life

	; data - difficulty settings table
	; called from #2716

272C  68 00				; normal at #0068
272E  7D 00				; hard at #007D	

; red ghost logic: (not edible)

2730  3ac14d    ld      a,(#4dc1)	; load A with movement indicator .  0= random movement , 1= normal movement
2733  cb47      bit     0,a		; random movement ?
2735  c25827    jp      nz,#2758	; no, jump to get normal red movement

2738  3ab64d    ld      a,(#4db6)	; yes, load A with red ghost mode 0=normal  1= faster ghost,most dots
273b  a7        and     a		; faster mode ?
273c  201a      jr      nz,#2758        ; yes, get norm red direction

273e  3a044e    ld      a,(#4e04)	; no, load A with game mode (3=ghost move, 2=ghost wait for start) (when is this 2 ???)
2741  fe03      cp      #03		; is this normal game mode ?
2743  2013      jr      nz,#2758        ; no, get normal red direction

; random red ghost directions

2745  2a0a4d    ld      hl,(#4d0a)	; yes, load HL with red ghost location  YY XX
2748  3a2c4d    ld      a,(#4d2c)	; load A with red ghost direction

; OTTPATCH
;PATCH TO MAKE THE MONSTERS MOVE RANDOMLY
ORG 274BH
CALL RCORNER
274b  cd6195    call    #9561		; load DE with a (random ?) quadrant for the destination
274e  cd6629    call    #2966		; get dir. by finding shortest distance
2751  221e4d    ld      (#4d1e),hl	; store red ghost movement offsets
2754  322c4d    ld      (#4d2c),a	; store red ghost direction
2757  c9        ret     		; return

; normal movement get direction for red ghost

2758  2a0a4d    ld      hl,(#4d0a)	; load HL with red ghost location  YY XX
275b  ed5b394d  ld      de,(#4d39)	; load DE with ms pac location YY XX
275f  3a2c4d    ld      a,(#4d2c)	; load A with red ghost current direction
2762  cd6629    call    #2966		; get best new dir. by finding shortest distance
2765  221e4d    ld      (#4d1e),hl	; store red ghost tile changes
2768  322c4d    ld      (#4d2c),a	; store red ghost direction
276b  c9        ret     		; return

; pink ghost AI start

276c  3ac14d    ld      a,(#4dc1)	; load A with movement indicator
276f  cb47      bit     0,a		; random movement ?
2771  c28e27    jp      nz,#278e	; no, skip ahead and do pink ghost AI
2774  3a044e    ld      a,(#4e04)	; yes, load A with level cleared register
2777  fe03      cp      #03		; == # 03 ? (why?  when game is played, this is always 3 ???)
2779  2013      jr      nz,#278e        ; no, skip ahead and do pink ghost AI (never will take this route??)

; pink ghost random movement

277b  2a0c4d    ld      hl,(#4d0c)	; else load HL with pink ghost position
277e  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost direction

; OTTPATCH
;PATCH TO MAKE THE MONSTERS MOVE RANDOMLY
ORG 2781H
CALL RCORNER
2781  cd6195    call    #9561		; call new code to pick a location to move toward ?
2784  cd6629    call    #2966		; get new direction by finding shortest distance
2787  22204d    ld      (#4d20),hl	; store new pink ghost Y and X tile changes
278a  322d4d    ld      (#4d2d),a	; store new pink ghost direction
278d  c9        ret     		; return

; pink ghost normal movement

278e  ed5b394d  ld      de,(#4d39)	; load DE with pac man position
2792  2a1c4d    ld      hl,(#4d1c)	; load HL with pac man direction

	; hard hack: HACK6
	; 2795  00        nop

2795  29        add     hl,hl		; HL := HL * 2
2796  29        add     hl,hl		; HL := HL * 2
2797  19        add     hl,de		; add direction to position
2798  eb        ex      de,hl		; copy to DE
2799  2a0c4d    ld      hl,(#4d0c)	; load HL with pink ghost position
279c  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost direction
279f  cd6629    call    #2966		; compute best new directions
27a2  22204d    ld      (#4d20),hl	; store new ping ghost Y and X tile changes
27a5  322d4d    ld      (#4d2d),a	; store new pink ghost direction
27a8  c9        ret     		; return

; blue ghost (inky) AI

27a9  3ac14d    ld      a,(#4dc1)	; load A with movement indicator
27ac  cb47      bit     0,a		; random movement ?
27ae  c2cb27    jp      nz,#27cb	; no ,skip ahead and do normal inky ghost AI
27b1  3a044e    ld      a,(#4e04)	; yes, load A with level cleared register
27b4  fe03      cp      #03		; == # 03 ?  (this always 3 during a game ... ?)
27b6  2013      jr      nz,#27cb        ; jump if not 3 ahead to do normal AI

; random (?) blue ghost (inky) movement

27b8  2a0e4d    ld      hl,(#4d0e)	; load HL with inky position

; OTTPATCH
;PATCH TO MAKE THE MONSTERS MOVE RANDOMLY
ORG 2781H
CALL RCORNER
27bb  cd5995    call    #9559		; pick a random quadrant (why ??? DE is loaded new in next step)
27be  114020    ld      de,#2040	; load DE with lower right corner destination
27c1  cd6629    call    #2966		; get best new direction
27c4  22224d    ld      (#4d22),hl	; store new direction into inky's tile changes
27c7  322e4d    ld      (#4d2e),a	; store inky's new direction
27ca  c9        ret     		; return

; normal blue ghost (inky) movement

27cb  ed4b0a4d  ld      bc,(#4d0a)	; load BC with red ghost position (X, Y)
27cf  ed5b394d  ld      de,(#4d39)	; load DE with pac man position
27d3  2a1c4d    ld      hl,(#4d1c)	; load HL with pacman direction 
					; H loads with (0 = facing up or down, 01 = facing left, FF = facing right)
					; L loads with (0= facing left or right, 01 = facing down, FF = facing up)
27d6  29        add     hl,hl		; HL := HL * 2
27d7  19        add     hl,de		; add result to pac position.  this now has the position 2 in front of pac
27d8  7d        ld      a,l		; load A with computed Y position
27d9  87        add     a,a		; A := A * 2
27da  91        sub     c		; subtract red ghost Y position
27db  6f        ld      l,a		; save result into L
27dc  7c        ld      a,h		; load A with computed X position
27dd  87        add     a,a		; A := A * 2
27de  90        sub     b		; subract red ghost X position
27df  67        ld      h,a		; save result into H
27e0  eb        ex      de,hl		; save total result into DE
27e1  2a0e4d    ld      hl,(#4d0e)	; load HL with blue ghost (Inky) position
27e4  3a2e4d    ld      a,(#4d2e)	; load A with blue ghost (Inky) direction
27e7  cd6629    call    #2966		; get best new direction
27ea  22224d    ld      (#4d22),hl	; Store blue ghost (inky) y tile changes
27ed  322e4d    ld      (#4d2e),a	; store new blue direction
27f0  c9        ret   			; return  

; orange ghost AI

27f1  3ac14d    ld      a,(#4dc1)	; load A with movement indicator
27f4  cb47      bit     0,a		; random movement ?
27f6  c21328    jp      nz,#2813	; no, skip ahead and normal orange ghost AI
27f9  3a044e    ld      a,(#4e04)	; load A with level cleared register
27fc  fe03      cp      #03		; == #03 ?  ( this is always 3 during game)
27fe  2013      jr      nz,#2813        ; jump if not 3 to normal orange ghost AI

; random orange ghost movement
; not really random, the random quadrant gets overridden with the lower left corner

2800  2a104d    ld      hl,(#4d10)	; load HL with orange ghost position
; OTTPATCH
;PATCH TO MAKE THE MONSTERS MOVE RANDOMLY
ORG 2803H
CALL R2CORNER
2803  cd5e95    call    #955e		; pick a random quadrant (why?  DE is loaded new in next step)
2806  11403b    ld      de,#3b40	; load DE with lower left corner destination
2809  cd6629    call    #2966		; get best new direction
280c  22244d    ld      (#4d24),hl	; store new orange ghost direction tile changes
280f  322f4d    ld      (#4d2f),a	; store new orange ghost direction 
2812  c9        ret     		; return

; normal orange ghost movement

2813  dd21394d  ld      ix,#4d39	; load IX with pacman Y and X tile position
2817  fd21104d  ld      iy,#4d10	; load IY with orange ghost tile future posiiton
281b  cdea29    call    #29ea		; load HL with sum of square of X and Y distances
281e  114000    ld      de,#0040	; load DE with offset. #40 is hex for 64 deciamal, which is 8 squared.

    	; hard hack: HACK6
	; 281e  112400    ld      de,#0024
	;

2821  a7        and     a		; clear carry flag
2822  ed52      sbc     hl,de		; subtract offset from distance.   is orange ghost getting too close to pac-man?  (<8 units)
2824  da0028    jp      c,#2800		; yes, jump back and have ghost move toward lower left corner

2827  2a104d    ld      hl,(#4d10)	; else load HL with orange ghost future position
282a  ed5b394d  ld      de,(#4d39)	; load DE with pac man position
282e  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost direction
2831  cd6629    call    #2966		; get best new direction
2834  22244d    ld      (#4d24),hl	; store orange ghost tile changes
2837  322f4d    ld      (#4d2f),a	; store orange ghost direction
283a  c9        ret     		; return


; called from #23A7 when task = #0C
; check red ghost movement when power pill active

283b  3aac4d    ld      a,(#4dac)	; load A with red ghost state
283e  a7        and     a		; is red ghost alive ?
283f  ca5528    jp      z,#2855		; yes, skip ahead and give random direction

2842  112c2e    ld      de,#2e2c	; no, load DE with the destination 2E, 2C which is right above the ghost house
2845  2a0a4d    ld      hl,(#4d0a)	; load HL with red ghost tile positions
2848  3a2c4d    ld      a,(#4d2c)	; load A with red ghost direction
284b  cd6629    call    #2966		; get best new direction
284e  221e4d    ld      (#4d1e),hl	; store new direction tiles for red ghost
2851  322c4d    ld      (#4d2c),a	; store new ghost direction
2854  c9        ret     		; return

2855  2a0a4d    ld      hl,(#4d0a)	; load HL with red ghost tile positions
2858  3a2c4d    ld      a,(#4d2c)	; load A with red ghost direction
285b  cd1e29    call    #291e		; load A and HL with random direction and tile direction
285e  221e4d    ld      (#4d1e),hl	; store new direction tiles for red ghost
2861  322c4d    ld      (#4d2c),a	; store new red ghost direction
2864  c9        ret     		; return

; check pink ghost

2865  3aad4d    ld      a,(#4dad)	; load A with pink ghost state
2868  a7        and     a		; is pink ghost alive ?
2869  ca7f28    jp      z,#287f		; yes, skip ahead and give random direction

286c  112c2e    ld      de,#2e2c	; no, load DE with the destination 2E, 2C which is right above the ghost house 
286f  2a0c4d    ld      hl,(#4d0c)	; load HL with pink ghost tile positions
2872  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost direction
2875  cd6629    call    #2966		; get best new direction
2878  22204d    ld      (#4d20),hl	; store new direction tiles for pink ghost
287b  322d4d    ld      (#4d2d),a	; store new pink ghost direction
287e  c9        ret     		; return

;

287f  2a0c4d    ld      hl,(#4d0c)	; load HL with pink ghost tile direction
2882  3a2d4d    ld      a,(#4d2d)	; load A with pink ghost orientation
2885  cd1e29    call    #291e		; load A and HL with random direction and tile direction
2888  22204d    ld      (#4d20),hl	; store new direction tiles for pink ghost
288b  322d4d    ld      (#4d2d),a	; store new pink ghost orientation
288e  c9        ret     		; return

; check blue ghost (inky)

288f  3aae4d    ld      a,(#4dae)	; load A with inky state
2892  a7        and     a		; is inky alive ?
2893  caa928    jp      z,#28a9		; yes, skip ahead and give random direction

2896  112c2e    ld      de,#2e2c	; no, load DE with the destination 2E, 2C which is right above the ghost house 
2899  2a0e4d    ld      hl,(#4d0e)	; load HL with inky tile positions
289c  3a2e4d    ld      a,(#4d2e)	; load A with ink direction
289f  cd6629    call    #2966		; get best new direction
28a2  22224d    ld      (#4d22),hl	; store new direction tiles for inky
28a5  322e4d    ld      (#4d2e),a	; store new inky direction
28a8  c9        ret     		; return

28a9  2a0e4d    ld      hl,(#4d0e)	; load HL with inky tile changes
28ac  3a2e4d    ld      a,(#4d2e)	; load A with inky direction
28af  cd1e29    call    #291e		; load A and HL with random direction and tile direction
28b2  22224d    ld      (#4d22),hl	; store inky new tile directions
28b5  322e4d    ld      (#4d2e),a	; store new inky direction
28b8  c9        ret     		; return

; check orange ghost

28b9  3aaf4d    ld      a,(#4daf)	; load A with orange ghost state
28bc  a7        and     a		; is orange ghost alive ?
28bd  cad328    jp      z,#28d3		; yes, skip ahead and assign random direction

28c0  112c2e    ld      de,#2e2c	; no, load DE with the destination 2E, 2C which is right above the ghost house 
28c3  2a104d    ld      hl,(#4d10)	; load HL with orange ghost tile directions
28c6  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost direction
28c9  cd6629    call    #2966		; get best new directions
28cc  22244d    ld      (#4d24),hl	; store new orange ghost tile directions
28cf  322f4d    ld      (#4d2f),a	; store new orange ghost direction
28d2  c9        ret     		; return

28d3  2a104d    ld      hl,(#4d10)	; load HL with orange ghost tile directions
28d6  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost direction
28d9  cd1e29    call    #291e		; load A and HL with random direction and tile direction
28dc  22244d    ld      (#4d24),hl	; store new orange ghost tile directions
28df  322f4d    ld      (#4d2f),a	; store new orange ghost direction
28e2  c9        ret     		; return

; called from #23A7 for task #17
; arrive here only during demo mode ?
; conrtrols pacman AI during demo mode
; pac-man will avoid the pink ghost normally, except after eating a power pill
; pac-man will chase the pink ghost when the red ghost is blue, even if the pink ghost is not

28e3  3aa74d    ld      a,(#4da7)	; load A with red ghost blue flag (0=not blue)
28e6  a7        and     a		; is red ghost blue (edible) ?
28e7  cafe28    jp      z,#28fe		; no, skip ahead
28ea  2a124d    ld      hl,(#4d12)	; yes, load HL with pacman tile pos (Y,X) in demo and cut scenes 
28ed  ed5b0c4d  ld      de,(#4d0c)	; load DE with pink ghost tile pos (Y,X)
28f1  3a3c4d    ld      a,(#4d3c)	; load A with wanted pacman orientation
28f4  cd6629    call    #2966		; get best new direction
28f7  22264d    ld      (#4d26),hl	; store into wanted pacman tile changes
28fa  323c4d    ld      (#4d3c),a	; store into wanted pacman orientation
28fd  c9        ret     		; return

; pacman will run away from pink ghost

28fe  2a394d    ld      hl,(#4d39)	; load HL with pacman (Y,X) tile positions
2901  ed4b0c4d  ld      bc,(#4d0c)	; load BC with pink ghost (Y,X) tile positions
2905  7d        ld      a,l		; load A with pacman X tile position
2906  87        add     a,a		; A := A * 2
2907  91        sub     c		; subtract pink ghost X tile position
2908  6f        ld      l,a		; store result into L
2909  7c        ld      a,h		; load A with pacman Y tile position
290a  87        add     a,a		; A := A * 2
290b  90        sub     b		; subtract pink ghost Y tile position
290c  67        ld      h,a		; store result into H
290d  eb        ex      de,hl		; DE <-> HL.  The new destination is away from pink ghost
290e  2a124d    ld      hl,(#4d12)	; load HL with pacman tile positions
2911  3a3c4d    ld      a,(#4d3c)	; load A with wanted pacman orientation
2914  cd6629    call    #2966		; get best new direction
2917  22264d    ld      (#4d26),hl	; store new tile changes
291a  323c4d    ld      (#4d3c),a	; store new wanted pacman orientation
291d  c9        ret     		; return

; called from routines above with HL loaded with ghost position and A loaded with ghost direction
; used when ghosts are blue (edible)
; load A with new direction, and HL with tile offset for this direction

291e  223e4d    ld      (#4d3e),hl	; store HL into current tile position
2921  ee02      xor     #02		; reverse ghost direction
2923  323d4d    ld      (#4d3d),a	; store into the opposite orientation
2926  cd232a    call    #2a23		; load A with a pseudo random number
2929  e603      and     #03		; mask bits, now between 0 and 3
292b  213b4d    ld      hl,#4d3b	; load HL with best orientation found address
292e  77        ld      (hl),a		; store the random direction
292f  87        add     a,a		; A := A * 2
2930  5f        ld      e,a		; store into E
2931  1600      ld      d,#00		; D := #00.  DE now has #000X where X is 2 * direction
2933  dd21ff32  ld      ix,#32ff	; load IX with data - tile differences tables for movements
2937  dd19      add     ix,de		; IX now has the tile difference address
2939  fd213e4d  ld      iy,#4d3e	; load IY with current tile position

293d  3a3d4d    ld      a,(#4d3d)	; load A with opposite direction
2940  be        cp      (hl)		; is the random direction == opposite direction ?
2941  ca5729    jp      z,#2957		; yes, skip ahead to choose a new direction

2944  cd0f20    call    #200f		; no, load A with the character in the destination screen position
2947  e6c0      and     #c0		; mask bits
2949  d6c0      sub     #c0		; subtract. is there a wall in the way of this direction ?
294b  280a      jr      z,#2957		; yes, choose a new direction and try again

294d  dd6e00    ld      l,(ix+#00)	; no, load L with tile offset low byte
2950  dd6601    ld      h,(ix+#01)	; load H with tile offset high byte
2953  3a3b4d    ld      a,(#4d3b)	; load A with new direction
2956  c9        ret			; return

; arrive here from #2941 when random direction == opposite direction, or a wall is in the way of the direction computed

2957  dd23      inc     ix		; 
2959  dd23      inc     ix		; next direction tile
295b  213b4d    ld      hl,#4d3b	; load HL with best orientation found address
295e  7e        ld      a,(hl)		; load A with the random direction
295f  3c        inc     a		; increase
2960  e603      and     #03		; mask bits to make between #00 and #03, in case #04 was reached it will revert to #00
2962  77        ld      (hl),a		; store into new random direction
2963  c33d29    jp      #293d		; jump back


; distance check - used for ghost logic and for pacman logic in the demo

; this subroutine determines the best direction to take based upon the input.
; DE is preloaded with the destination tile
; HL is preloaded with the current position tile
; A is preloaded with the current direction of the ghost

; the output is the best new direction which is stored into A
; and the best new tile changes stored into HL


2966  223e4d    ld      (#4d3e),hl	; store current position
2969  ed53404d  ld      (#4d40),de	; store destination
296d  323b4d    ld      (#4d3b),a	; store direction
2970  ee02      xor     #02		; flip bit 1 of the direction
2972  323d4d    ld      (#4d3d),a	; store reversed direction, this will never be allowed
2975  21ffff    ld      hl,#ffff	; HL := #FFFF
2978  22444d    ld      (#4d44),hl	; store HL into minimum distance^2 found
297b  dd21ff32  ld      ix,#32ff	; load IX with start of table data - tile differences tables for movements
297f  fd213e4d  ld      iy,#4d3e	; load IY with current position
2983  21c74d    ld      hl,#4dc7	; load HL with address of counter
2986  3600      ld      (hl),#00	; clear counter

2988  3a3d4d    ld      a,(#4d3d)	; load A with reversed direction
298b  be        cp      (hl)		; == counter ?
298c  cac629    jp      z,#29c6		; yes, skip ahead and try next position

298f  cd0020    call    #2000		; no, HL := (IX) + (IY)
2992  22424d    ld      (#4d42),hl	; store into temp position
2995  cd6500    call    #0065		; convert to screen position
2998  7e        ld      a,(hl)		; load A with the character in the new position
2999  e6c0      and     #c0		; mask bits
299b  d6c0      sub     #c0		; is there something blocking the way of this direction?
299d  2827      jr      z,#29c6         ; yes, skip ahead and try next position

299f  dde5      push    ix		; no, save IX
29a1  fde5      push    iy		; save IY
29a3  dd21404d  ld      ix,#4d40	; load IX with destination
29a7  fd21424d  ld      iy,#4d42	; load IY with temp position
29ab  cdea29    call    #29ea		; load HL with sum of the square of the X and Y distances between the 2 positions
29ae  fde1      pop     iy		; restore IY
29b0  dde1      pop     ix		; restore IX
29b2  eb        ex      de,hl		; store result into DE
29b3  2a444d    ld      hl,(#4d44)	; load HL with minimum distance^2 found
29b6  a7        and     a		; clear carry flag
29b7  ed52      sbc     hl,de		; subtract.  Is this distance less than the minimum found so far ?
29b9  dac629    jp      c,#29c6		; no, skip ahead and try next position

29bc  ed53444d  ld      (#4d44),de	; yes, store new minimum distance^2 found
29c0  3ac74d    ld      a,(#4dc7)	; load A with counter
29c3  323b4d    ld      (#4d3b),a	; store counter into direction

29c6  dd23      inc     ix
29c8  dd23      inc     ix		; next direction tile difference
29ca  21c74d    ld      hl,#4dc7	; load HL with counter
29cd  34        inc     (hl)		; increase counter
29ce  3e04      ld      a,#04		; A := #04
29d0  be        cp      (hl)		; have we tried all 4 directions?
29d1  c28829    jp      nz,#2988	; no, loop again and try more

29d4  3a3b4d    ld      a,(#4d3b)	; yes, load A with best direction
29d7  87        add     a,a		; A := A * 2
29d8  5f        ld      e,a		; store into E
29d9  1600      ld      d,#00		; D := #00
29db  dd21ff32  ld      ix,#32ff	; load IX with start of tile differences
29df  dd19      add     ix,de		; add DE, now it has the tile difference for best direction
29e1  dd6e00    ld      l,(ix+#00)	; 
29e4  dd6601    ld      h,(ix+#01)	; store tile difference for best direction into HL
29e7  cb3f      srl     a		; A := A / 2
29e9  c9        ret     		; return

; sub called for orange ghost logic and during distance check
; loads HL with the sum of the square of the X and Y distances between pac and ghost

29ea  dd7e00    ld      a,(ix+#00)	; load A with pacman Y position
29ed  fd4600    ld      b,(iy+#00)	; load B with ghost Y position
29f0  90        sub     b		; subtract.  is A > B ?
29f1  d2f929    jp      nc,#29f9	; yes, skip ahead

29f4  78        ld      a,b		; else load A with B
29f5  dd4600    ld      b,(ix+#00)	; load B with pacman position
29f8  90        sub     b		; subtract from ghost position

29f9  cd122a    call    #2a12		; result should always be a small number.  HL := A * A

29fc  e5        push    hl		; save HL

29fd  dd7e01    ld      a,(ix+#01)	; load A with pacman X position
2a00  fd4601    ld      b,(iy+#01)	; load B with ghost X position
2a03  90        sub     b		; subtract.  is A > B ?
2a04  d20c2a    jp      nc,#2a0c	; yes, skip ahead

2a07  78        ld      a,b		; else load A with B
2a08  dd4601    ld      b,(ix+#01)	; load B with pacman X position
2a0b  90        sub     b		; subtract.

2a0c  cd122a    call    #2a12		; HL = A * A

2a0f  c1        pop     bc		; restore the result found based on Y position
2a10  09        add     hl,bc		; add together into HL (no check for overflow ???)
2a11  c9        ret     		; return

; called from #29F9
; takes the value in A and squares it, places result into HL

2a12  67        ld      h,a		; H := A
2a13  5f        ld      e,a		; E := A
2a14  2e00      ld      l,#00		; L := #00
2a16  55        ld      d,l		; D := #00
2a17  0e08      ld      c,#08		; C := #08 (loop counter)

2a19  29        add     hl,hl		; HL := HL * 2
2a1a  d21e2a    jp      nc,#2a1e	; no carry, skip next step

2a1d  19        add     hl,de		; add result to DE

2a1e  0d        dec     c		; decrease counter
2a1f  c2192a    jp      nz,#2a19	; loop if not done, 8 times
2a22  c9        ret     		; return

    ;; Random number generator

;; #2a23 random number generator, only active when ghosts are blue.    
;; n=(n*5+1) && #1fff.  n is used as an address to read a byte from a rom.
;; #4dc9, #4dca=n  and a=rnd number. n is reset to 0 at #26a9 when you die,
;; start of first level, end of every level.  Later a is anded with 3.

2a23  2ac94d    ld      hl,(#4dc9)
2a26  54        ld      d,h
2a27  5d        ld      e,l
2a28  29        add     hl,hl
2a29  29        add     hl,hl
2a2a  19        add     hl,de
2a2b  23        inc     hl
2a2c  7c        ld      a,h
2a2d  e61f      and     #1f
2a2f  67        ld      h,a
2a30  7e        ld      a,(hl)
2a31  22c94d    ld      (#4dc9),hl
2a34  c9        ret   

;  

2a35  114040    ld      de,#4040

2a38  21c043    ld      hl,#43c0
2a3b  a7        and     a
2a3c  ed52      sbc     hl,de
2a3e  c8        ret     z

2a3f  1a        ld      a,(de)
2a40  fe10      cp      #10
2a42  ca532a    jp      z,#2a53

2a45  fe12      cp      #12
2a47  ca532a    jp      z,#2a53

2a4a  fe14      cp      #14
2a4c  ca532a    jp      z,#2a53

2a4f  13        inc     de
2a50  c3382a    jp      #2a38

2a53  3e40      ld      a,#40
2a55  12        ld      (de),a
2a56  13        inc     de
2a57  c3382a    jp      #2a38

; arrive here from #1780 when a ghost is eaten. 
; B contains the # of ghosts eaten +1 (2-5)

; or arrive from #23A7 for a task
; B is loaded with code of scoring item

2a5a  3a004e    ld      a,(#4e00)	; load A with game mode
2a5d  fe01      cp      #01		; is this the intro mode ?
2a5f  c8        ret     z		; yes, return			; change this to #00 (NOP) to enable scoring in demo mode

	; this updates the score when something is eaten
	; (from the table at 2b17)
	; A is loaded with the code for item eaten

2a60  21172b    ld      hl,#2b17	; load HL with start of scoring table data
2a63  df        rst     #18		; load HL with score based on item eaten stored in A
2a64  eb        ex      de,hl		; copy to DE
2a65  cd0b2b    call    #2b0b		; load HL with score address for current player
2a68  7b        ld      a,e		; load A with low byte of score to add
2a69  86        add     a,(hl)		; add player's score low byte to A
2a6a  27        daa     		; decimal adjust
2a6b  77        ld      (hl),a		; store result into score
2a6c  23        inc     hl		; next memory, for second byte of score
2a6d  7a        ld      a,d		; load A with high byte of score to add
2a6e  8e        adc     a,(hl)		; add with carry players's score second byte to A
2a6f  27        daa     		; decimal adjust
2a70  77        ld      (hl),a		; store result into score second byte
2a71  5f        ld      e,a		; load E with this value as well
2a72  23        inc     hl		; next memory for third byte of score
2a73  3e00      ld      a,#00		; A := #00
2a75  8e        adc     a,(hl)		; add with carry third byte of score into A.  This will only add a carry bit if needed
2a76  27        daa     		; decimal adjust
2a77  77        ld      (hl),a		; store result into third byte of score
2a78  57        ld      d,a		; load D with A.  DE now has third and second bytes of score
2a79  eb        ex      de,hl		; exchange DE with HL
2a7a  29        add     hl,hl		; double HL
2a7b  29        add     hl,hl		; double HL
2a7c  29        add     hl,hl		; double HL
2a7d  29        add     hl,hl		; HL now has 16 times what it had before
2a7e  3a714e    ld      a,(#4e71)	; load A with bonus life code
2a81  3d        dec     a		; decrement
2a82  bc        cp      h		; compare with H.  Is the players score higher than that needed for extra life?
2a83  dc332b    call    c,#2b33		; if yes, call sub to continue check for extra life
2a86  cdaf2a    call    #2aaf		; draw player score onscreen
2a89  13        inc     de		; 
2a8a  13        inc     de
2a8b  13        inc     de		; DE now has msb byte of player's score

	; check for high score change

2a8c  218a4e    ld      hl,#4e8a	; load HL with msb high score ram area
2a8f  0603      ld      b,#03		; For B = 1 to 3 digits to check

2a91  1a        ld      a,(de)		; load a with score digit
2a92  be        cp      (hl)		; compare to high score digit
2a93  d8        ret     c		; return if high score not beat

2a94  2005      jr      nz,#2a9b        ; if they are equal, continue, else update the high score
2a96  1b        dec     de		; next digit
2a97  2b        dec     hl		; next digit
2a98  10f7      djnz    #2a91           ; next B
2a9a  c9        ret     		; return

	; arrive when player score beats the current high score

2a9b  cd0b2b    call    #2b0b		; load HL with score address for current player
2a9e  11884e    ld      de,#4e88	; load DE with lsb high score memory
2aa1  010300    ld      bc,#0003	; counter  = 3 bytes
2aa4  edb0      ldir    		; copy score to high score
2aa6  1b        dec     de		; DE now has high score
2aa7  010403    ld      bc,#0304	; set up counters
2aaa  21f243    ld      hl,#43f2	; load HL with start of screen memory for high score
2aad  180f      jr      #2abe           ; draw high score to screen and return

; called from #2A86

2aaf  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2 
2ab2  010403    ld      bc,#0304	; load counters
2ab5  21fc43    ld      hl,#43fc	; screen pos for player 1 score
2ab8  a7        and     a		; is this player 1 ?
2ab9  2803      jr      z,#2abe         ; yes, skip ahead

2abb  21e943    ld      hl,#43e9	; else load HL with screen pos for player 2 score

	;; draw the score to the screen
	; DE has the address of msb of the score
	; HL has starting screen position
	; B has #03, and C has #04 or #06

2abe  1a        ld      a,(de)		; load A with byte of score
2abf  0f        rrca    
2ac0  0f        rrca    
2ac1  0f        rrca    
2ac2  0f        rrca 			; roll right 4 times through carry flag, result is digits transposed (eg. 82 converts to #28)    
2ac3  cdce2a    call    #2ace		; drawtens digit to screen
2ac6  1a        ld      a,(de)		; load A with byte of score
2ac7  cdce2a    call    #2ace		; draw ones digit to screen
2aca  1b        dec     de		; next score digit
2acb  10f1      djnz    #2abe           ; loop 3 times
2acd  c9        ret     		; return

2ace  e60f      and     #0f		; mask out left 4 bits to zero
2ad0  2804      jr      z,#2ad6         ; result zero?  yes, skip next 2 steps

2ad2  0e00      ld      c,#00		; C := #00
2ad4  1807      jr      #2add           ; skip ahead

2ad6  79        ld      a,c		; load A with C
2ad7  a7        and     a		; == #00 ?
2ad8  2803      jr      z,#2add         ; yes, skip ahead

2ada  3e40      ld      a,#40		; else A := #40
2adc  0d        dec     c		; decrement C

2add  77        ld      (hl),a		; draw score to screen
2ade  2b        dec     hl		; next screen position
2adf  c9        ret     		; return

	; prints "high score", player 1 and player 2 score
	; this is task #18 called from #23A7

2ae0  0600      ld      b,#00		; B := #00
2ae2  cd5e2c    call    #2c5e		; print HIGH SCORE
2ae5  af        xor     a		; A := #00
2ae6  21804e    ld      hl,#4e80	; load HL with player 1 score start address
2ae9  0608      ld      b,#08		; set counter to 8
2aeb  cf        rst     #8		; clear player 1 and player 2 scores to zero
2aec  010403    ld      bc,#0304	; load BC with counters
2aef  11824e    ld      de,#4e82	; load DE with p1 msb of score
2af2  21fc43    ld      hl,#43fc	; load HL with screen pos for p1 current score
2af5  cdbe2a    call    #2abe		; draw score to screen
2af8  010403    ld      bc,#0304	; load BC with counters
2afb  11864e    ld      de,#4e86	; load DE with player 2 address
2afe  21e943    ld      hl,#43e9	; load HL with screen pos for player 2 score
2b01  3a704e    ld      a,(#4e70)	; load A with number of players (0=1 player, 1=2 players)
2b04  a7        and     a		; is this a 1 player game?
2b05  20b7      jr      nz,#2abe        ; no, draw player 2 score and return
2b07  0e06      ld      c,#06		; else C := #06
2b09  18b3      jr      #2abe           ; draw player 2 score and return

; called from #2A65, #2A9B

2b0b  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
2b0e  21804e    ld      hl,#4e80	; load HL with player 1 score start address
2b11  a7        and     a		; is this player 1 ?
2b12  c8        ret     z		; yes, return

2b13  21844e    ld      hl,#4e84	; else load HL with player 2 start address
2b16  c9        ret     		; return

	;; score table
	;; (Spaeth)

2b17  10 00              		; dot        	=   10	0
2b19  50 00              		; power pellet	=   50	1
2b1b  00 02              		; ghost 1    	=  200	2
2b1d  00 04              		; ghost 2    	=  400	3
2b1f  00 08             		; ghost 3    	=  800  4
2b21  00 16              		; ghost 4    	= 1600	5
2b23  00 01             		; Cherry     	=  100	6
2b25  00 02             		; Strawberry 	=  200	7	; 300 in pac-man
2b27  00 05             		; Orange     	=  500	8
2b29  00 07             		; Pretzel    	=  700	9
2b2b  00 10             		; Apple      	= 1000	a
2b2d  00 20              		; Pear       	= 2000	b
2b2f  00 50              		; Banana     	= 5000	c	; 3000 in pac-man
2b31  00 50              		; Junior!    	= 5000	d

	; [The 8th fruit is a legacy thing from pacman, which
	;  used 8 bonus items. it is not used in mspac]

; arrive here from #2A83 when checking for extra life
; DE has the address of the third byte of the player's score

2B33  13	INC	DE		; increment DE, it now points to fourth byte of score.  This is used only for extra life check 
2b34  6b        ld      l,e		; load L with E
2b35  62        ld      h,d		; load H with D.  HL now has a copy of DE, which is the fourth byte of score
2b36  1b        dec     de		; decrement DE, this now points to third byte again
2b37  cb46      bit     0,(hl)		; test bit 0 of this score.  is it already set?
2b39  c0        ret     nz		; no, return.  extra life has already been awarded

	; else start bonus life routine

2b3a  cbc6      set     0,(hl)		; set bit 0 of HL. this will deny any future extra lives
2b3c  219c4e    ld      hl,#4e9c	; set sound 0
2b3f  cbc6      set     0,(hl)		; play bonus life sound
2b41  21144e    ld      hl,#4e14	; load HL with number of lives left
2b44  34        inc     (hl)		; inc lives left
2b45  21154e    ld      hl,#4e15	; load HL with number of lives on the screen
2b48  34        inc     (hl)		; inc lives displayed
2b49  46        ld      b,(hl)		; load B with number of lives on the screen.  This is used for a loop counter at instruction #2B5F

2b4a  211a40    ld      hl,#401a	; load HL with start screen location for extra lives
2b4d  0e05      ld      c,#05		; C := #05.  This counter is used to determine how many blanks to draw
2b4f  78        ld      a,b		; load A with B which has number of lives on the screen
2b50  a7        and     a		; == #00 ?
2b51  280e      jr      z,#2b61         ; yes, skip ahead, nothing to draw

2b53  fe06      cp      #06		; >= #06 ?
2b55  300a      jr      nc,#2b61        ; yes, skip ahead, we can't draw more than 5 extra lives

2b57  3e20      ld      a,#20		; A := #20
2b59  cd8f2b    call    #2b8f		; draw extra life
2b5c  2b        dec     hl		; 
2b5d  2b        dec     hl		; HL is now 2 less than before.  If another life is to be drawn, it will be in correct location.
2b5e  0d        dec     c		; decrement C 
2b5f  10f6      djnz    #2b57           ; Next B

2b61  0d        dec     c		; decrement C.  Are there blank spaces to be drawn next ?
2b62  f8        ret     m		; No, return

2b63  cd7e2b    call    #2b7e		; Yes, draw blank for the next extra life position
2b66  2b        dec     hl		; 
2b67  2b        dec     hl		; HL is now 2 less for next position if needed
2b68  18f7      jr      #2b61           ; loop again

; draw remaining lives at bottom of screen

2b6a  3a004e    ld      a,(#4e00)	; load A with game mode
2b6d  fe01      cp      #01		; == 1 ?  Are we in demo mode?
2b6f  c8        ret     z		; If yes, return

2b70  cdcd2b    call    #2bcd		; colors the bottom two rows of 10 the color 9 (yellow)
2b73  12 44				; #4412 is starting location for above subroutine
2B75  09 0A 02				; data used in above subroutine call.  9 is the color, #0A is the length, #02 is the number of rows
2b78  21154e    ld      hl,#4e15	; load HL with address of number of lives to display
2b7b  46        ld      b,(hl)		; load B with number of lives to display
2b7c  18cc      jr      #2b4a           ; draw extra lives on screen and return

; Draws colors onscreen for a 2x2 grid.
; It requires that A is loaded with the code for the color,
; and HL is loaded with the memory address of the position on screen where the first color is to be drawn.
; If a clear value is to be drawn, the first address is called (#2B7E). 
; If A is preloaded with a color, then the second address is called (#2B80).

2B7E 3E 40 	LD 	A,#40 		; Used to draw clear value
2B80 E5 	PUSH 	HL 		; Save HL
2B81 D5 	PUSH 	DE 		; Save DE
2B82 77 	LD 	(HL),A 		; Draw color into first part
2B83 23 	INC 	HL 		; Set location to second part of fruit
2B84 77 	LD 	(HL),A 		; Draw color into second part
2B85 11 1F 00 	LD 	DE,#001F 	; Offset is used for third part
2B88 19 	ADD 	HL,DE 		; Set location to third part of fruit
2B89 77 	LD 	(HL),A 		; Draw color into third part
2B8A 23 	INC 	HL 		; Set location to fourth part of fruit
2B8B 77 	LD 	(HL),A 		; Draw color into fourth part
2B8C D1 	POP 	DE 		; Restore DE
2B8D E1 	POP 	HL 		; Restore HL
2B8E C9 	RET 			; Return

; Draws the four parts of a fruit onscreen.  Also used to draw extra pac man lives at bottom of screen.
; It requires that A is loaded with the code for the first part of the fruit,
; and HL is loaded with the memory address of the first position on screen where it is to be drawn.

2B8F E5 	PUSH 	HL 		; Save HL
2B90 D5 	PUSH 	DE 		; Save DE
2B91 11 1F 00 	LD 	DE,#001F 	; this offset is added later for third part of fruit 
2B94 77 	LD 	(HL),A 		; Draw first part of fruit code into screen memory
2B95 3C 	INC 	A 		; Point to second part of fruit
2B96 23 	INC 	HL 		; Increment screen memory for second part of fruit
2B97 77 	LD 	(HL),A 		; Draw second part of fruit code into screen memory
2B98 3C 	INC 	A 		; Point to third part of fruit
2B99 19 	ADD 	HL,DE 		; Add offset for third part of fruit
2B9A 77 	LD 	(HL),A 		; Draw third part of fruit code into screen memory
2B9B 3C 	INC 	A 		; Point to fourth part of fruit
2B9C 23 	INC 	HL 		; Increment screen memory for fourth part of fruit
2B9D 77 	LD 	(HL),A 		; Draw fourth part of fruit code into screen memory
2B9E D1 	POP 	DE 		; Restore DE
2B9F E1 	POP 	HL 		; Restore HL
2BA0 C9 	RET 			; Return     

	;; display number of credits

2ba1  3a6e4e    ld      a,(#4e6e)	; load A with number of credits in ram
2ba4  feff      cp      #ff		; set for free play?
2ba6  2005      jr      nz,#2bad        ; no? then skip ahead
2ba8  0602      ld      b,#02		; load code for "FREE PLAY"
2baa  c35e2c    jp      #2c5e		; print FREE PLAY and return from sub

2bad  0601      ld      b,#01		; else load code for "CREDIT"
2baf  cd5e2c    call    #2c5e		; print "CREDIT" on screen
2bb2  3a6e4e    ld      a,(#4e6e)	; load A with number of credits in ram
2bb5  e6f0      and     #f0		; mask bits.  is it bigger than 9?
2bb7  2809      jr      z,#2bc2         ; yes, only draw 1 position
2bb9  0f        rrca  			; else ...  
2bba  0f        rrca    		;
2bbb  0f        rrca    		; 
2bbc  0f        rrca    		; rotate right 4 times, which moves the 10's digit to the 1's digit
2bbd  c630      add     a,#30		; Add #30 to account for ascii code for numbers
2bbf  323440    ld      (#4034),a	; put tens digit for number of credits on screen

2bc2  3a6e4e    ld      a,(#4e6e)	; load A with number of credits in ram
2bc5  e60f      and     #0f		; mask out high bits.  result is between 0 and 9
2bc7  c630      add     a,#30		; Add #30 to account for ascii code for numbers
2bc9  323340    ld      (#4033),a	; put 1's digit number of credits on screen
2bcc  c9        ret     		; return

; this subroutine takes 5 bytes after the call and uses them to copy the 3rd byte into several memories
; first 2 bytes are the initial address to copy into 
; called from #2B70 to color the bottom area yellow where extra lives are drawn

2bcd  e1        pop     hl		; load HL with address of next data byte in code
2bce  5e        ld      e,(hl)		; load E with first byte.  MSB of address to use
2bcf  23        inc     hl		; next adddress
2bd0  56        ld      d,(hl)		; load D with second byte.  LSB of address to use
2bd1  23        inc     hl		; next address
2bd2  4e        ld      c,(hl)		; load C with third byte.  used for data to put into these memories
2bd3  23        inc     hl		; next address
2bd4  46        ld      b,(hl)		; load B with fourth byte ... used for loop counter
2bd5  23        inc     hl		; next address
2bd6  7e        ld      a,(hl)		; load A with fifth byte.  used for secondary loop counter
2bd7  23        inc     hl		; next address
2bd8  e5        push    hl		; push to stack for return address when done
2bd9  eb        ex      de,hl		; move DE into HL
2bda  112000    ld      de,#0020	; load DE with offset value of #20

2bdd  e5        push    hl		; save HL
2bde  c5        push    bc		; save BC

2bdf  71        ld      (hl),c		; store data into memory
2be0  23        inc     hl		; next address
2be1  10fc      djnz    #2bdf           ; Next B

2be3  c1        pop     bc		; restore BC
2be4  e1        pop     hl		; restore HL
2be5  19        add     hl,de		; add offset (#20)
2be6  3d        dec     a		; decrease counter.  are we done ?
2be7  20f4      jr      nz,#2bdd        ; No, loop again
2be9  c9        ret     		; return

; called from #23A7 as task #1B
; called from #0792

2bea  3a004e    ld      a,(#4e00)	; load A with game mode
2bed  fe01      cp      #01		; is this the attract mode ?
2bef  c8        ret     z		; yes, return

	;; draw the fruit

2bf0  3a134e    ld      a,(#4e13)	; else Load A with current board level
2bf3  3c        inc     a		; increment it

; OTTOPATCH
;PATCH TO MAKE FRUIT not SCROLL ACROSS SCREEN BOTTOM WHEN MAXFRUIT IS REACHED.
!    ORG 2BF4H
!    JP MAXFRUIT
2bf4  c39387    jp      #8793		; jump to new ms. pac man sub, returns to #2BF9


;; original pac-man code follows
; 2BF4 FE08 	CP 	#08 		; Is this level < 8 ?
; 2BF6 D22E2C 	JP 	NC,#2C2E 	; No, jump to compute different start for fruit table
;;


2BF9 11083B	LD	DE,#3B08 	; Yes, load DE with address of cherry in fruit table
2BFC 47 	LD	B,A 		; For B = 1 to level number
2BFD 0E07 	LD	C,#07 		; C is 7 = the total number of locations to draw
2BFF 210440 	LD	HL,#4004 	; Load HL with the start of video memory

2C02 1A 	LD	A,(DE) 		; Load A with value from fruit table
2C03 CD8F2B 	CALL	#2B8F 		; Draw fruit subroutine
2C06 3E04 	LD	A,#04 		; 
2C08 84 	ADD	A,H 		; Add 400 to HL
2C09 67 	LD	H,A 		; HL now points to color memory
2C0A 13 	INC	DE 		; DE now points to color code in fruit table
2C0B 1A 	LD	A,(DE) 		; Load A with color code from fruit table
2C0C CD802B 	CALL	#2B80 		; Draw color subroutine
2C0F 3EFC 	LD	A,#FC 		; 
2C11 84 	ADD	A,H 		; Subtract 4 from H
2C12 67 	LD	H,A 		; HL now points back to video memory
2C13 13 	INC	DE 		; Increase pointer to next fruit in table
2C14 23 	INC	HL 		; 
2C15 23 	INC	HL 		; Next starting point is 2 bytes higher
2C16 0D 	DEC	C 		; Count down how many clears to draw
2C17 10E9 	DJNZ	#2C02 		; Next B  loop back and draw next fruit

2C19 0D 	DEC	C 		; Count down C. Did C just turn negative?
2C1A F8 	RET	M 		; Yes, return to game, we are done
2C1B CD7E2B 	CALL	#2B7E 		; No, call subroutine to draw a clear
2C1E 3E04 	LD	A,#04 		; 
2C20 84 	ADD	A,H 		;
2C21 67 	LD	H,A 		; Increase HL by 400 for color value to be cleared
2C22 AF 	XOR	A 		; Load A with 0, the code for black color
2C23 CD802B 	CALL	#2B80 		; Draw color subroutine  draws black color
2C26 3EFC 	LD	A,#FC 		; 
2C28 84 	ADD	A,H 		; Subtract 4 from H
2C29 67 	LD	H,A 		; HL now points back to video memory
2C2A 23 	INC	HL 		;
2C2B 23 	INC	HL 		; Set next starting point to be 2 bytes more
2C2C 18EB 	JR	#2C19 		; Jump back and draw next clear

; Arrive here when the level is 8 or higher
; only used in pac-man, not ms. pac

2C2E FE13 	CP	#13 		; Is the level > #13 (19 decimal, 7th key) ?
2C30 3802 	JR	C,#2C34 	; If not, skip next step
2C32 3E13 	LD	A,#13 		; If yes, treat all levels 19 and up as if they are level 19.
2C34 D607 	SUB	#07 		; Subtract 7 to point to first value to be drawn
2C36 4F 	LD	C,A 		; Copy result to C
2C37 0600 	LD	B,#00 		; Load B with Zero
2C39 21083B 	LD	HL,#3B08 	; Load HL with pointer to start of fruit table
2C3C 09 	ADD	HL,BC 		; 
2C3D 09 	ADD	HL,BC 		; Adjust fruit table pointer, based on current level
2C3E EB 	EX	DE,HL 		; Load DE to point to fruit in table
2C3F 0607 	LD	B,#07 		; Load B counter to draw 7 fruit
2C41 C3FD2B 	JP	#2BFD 		; Jump back up to fruit drawing section

; unknown subroutine [unused ???]
; can't find a call to here

2c44  47        ld      b,a
2c45  e60f      and     #0f
2c47  c600      add     a,#00
2c49  27        daa
2c4a  4f        ld      c,a
2c4b  78        ld      a,b
2c4c  e6f0      and     #f0
2c4e  280b      jr      z,#2c5b

2c50  0f        rrca
2c51  0f        rrca
2c52  0f        rrca
2c53  0f        rrca
2c54  47        ld      b,a
2c55  af        xor     a
2c56  c616      add     a,#16
2c58  27        daa
2c59  10fb      djnz    #2c56

2c5b  81        add     a,c
2c5c  27        daa
2c5d  c9        ret

	;; 	DrawText

        ;;   Renders messages from a table with coordinates and message data
        ;;   B = message # from table
	;;   B & 0x80 indicates to erase characters instead of draw them

	;; other flags:
	;;	top bit of address word & 0x80 -> draw in top or bottom two rows
	;;	first color & 0x80 -> use this color for the entire string 

; format of the table data:
;   .byte (offs l), (offs h)	; so an offset of #0234 would be #34, #02
;	increase L by 0x01 to move it down by 1 row
;	increase L by 0x20 to move it left one column
;	set H|0x80 to indicate top or bottom two rows
;   .ascii "STRING"
;   .byte #2f			; termination with 2f
;   .byte colordata:
;	if the color data byte's high bit (#80) is set, the entire string
;	gets colored with (colordata & 0x7f) 
;		no termination, just the one entry.
;	if the color data byte's high bit is not set, then:
;	.byte 	ncolors		; number of bytes to set color
;	.byte	color1		; first character's color
;	.byte	color2		; second character's color
;		...		; etc
;	 (no termination - just as many entries as there were characters)

DrawText:
	; drawText( b )  ; b is index
2c5e  21a536    ld      hl,#36a5	; load HL with the text string lookup table
2c61  df        rst     #18		; (hl+2*b) -> hl

	; 1. get start offset into vid/color buffer
	; e = (hl++) ; d = (hl)		; load two bytes in as a pointer
	; indexOffset = de
2c62  5e        ld      e,(hl)		; load E with value from table
2c63  23        inc     hl		; next table entry
2c64  56        ld      d,(hl)  	; DE contains start offset

	; 2. use offset for start of color, save to stack
	; ix = 0x4400 + indexOffset
2c65  dd210044  ld      ix,#4400	; load IX with start of color RAM
2c69  dd19      add     ix,de		; add offset to calculate start pos in CRAM
2c6b  dde5      push    ix		; save to stack for use later (#2C93)

	; 3. use offset for start of character ram
	; ix = characterRam + indexOffset
	; offsetPerCharacter = -1	; de
	; if (hl) & 0x80 then offsetPerCharacter = -0x20
2c6d  1100fc    ld      de,#fc00	; load DE with offset for VRAM
2c70  dd19      add     ix,de		; add to calculate start position in VRAM
2c72  11ffff    ld      de,#ffff	; load DE with offset for top & bottom lines (offset equals negative 1)
2c75  cb7e      bit     7,(hl)		; test bit 7 of HL.  Is this text for the top + bottom 2 lines ?

	; it should be noted that since the high bit on the offset address
	; is used to denote that the string goes into the top or bottom
	; two rows, it ends up relying on the unused ram mirroring.
	; that is to say that it actually ends up drawing up around C000
	; instead of 4000.  A patch is below as HACK12

	; (this skips the offsetPerCharacter with -20 if necessary)
2c77  2003      jr      nz,#2c7c        ; yes, skip next step
2c79  11e0ff    ld      de,#ffe0	; no, load DE with offset for normal text (equals negative #20)

	; 4. determine special entry, go to 2cac for that
	; hl++
	; a = stringToDraw * 2
	; if( carry) goto BlankTextDraw	;AKA  if( stringToDraw# & 0x80) then goto BlankTextDraw
BlankTextDrawCheck:
2c7c  23        inc     hl		; next table entry
2c7d  78        ld      a,b		; A := B.  B was preloaded with the code # of the text to display
2c7e  010000    ld      bc,#0000	; clear BC
2c81  87        add     a,a		; A : = A * 2.  Is this a special entry ?
2c82  3828      jr      c,#2cac         ; special draw for entries 80+

textRenderLoop0:
	; ch = current character  	; 'a' = (hl)
	; if ch == 0x2f, goto SingleOrMultiColorCheck:
	; *characterVram = ch		; ram[ix+0] = 'a'
	; characterVram += de		; (+= but it really subtracts 1 or 0x20, contents of 'de')
	; nchars ++  			; 'b'++
	; goto textRenderLoop0
2c84  7e        ld      a,(hl)		; load A with next character
2c85  fe2f      cp      #2f		; == #2F ? (end of text code)
2c87  2809      jr      z,#2c92         ; yes, done with VRAM, skip ahead to color

2c89  dd7700    ld      (ix+#00),a	; write character to screen
2c8c  23        inc     hl		; next character
2c8d  dd19      add     ix,de		; calculate next VRAM pos
2c8f  04        inc     b		; increment counter
2c90  18f2      jr      #2c84           ; loop

SingleOrMultiColorCHeck:
	; ix = startColorRamPos
2c92  23        inc     hl		; next table entry
2c93  dde1      pop     ix		; get CRAM start pos

	; color = *colorToUse
	; if (color) is > 80, goto TextSingleColorRender
2c95  7e        ld      a,(hl)		; load A with color
2c96  a7        and     a		; > #80 ?
2c97  faa42c    jp      m,#2ca4		; yes, skip ahead

TextMultiColorRender:
	; color = *colorToUse
	; colorRam[ix] = color;
	; colorToUse++
	; move ix to the next screen position ( -=1 or -=0x20)
	; b--; if b>0 then goto TextMultiColorRender
	; return
2c9a  7e        ld      a,(hl)		; else load A with color
2c9b  dd7700    ld      (ix+#00),a	; color the screen position Color RAM
2c9e  23        inc     hl		; next color
2c9f  dd19      add     ix,de		; calc next CRAM pos
2ca1  10f7      djnz    #2c9a           ; loop until b==0
2ca3  c9        ret     		; return


	;; same as above, but all the same color
TextSingleColorRender:
	; colorRam[ix] = color
	; move ix to the next screen position( -=1 or -=0x20)
	; b--; if b>0 then goto TextSingleColorRender
	; return
2ca4  dd7700    ld      (ix+#00),a	; drop in CRAM
2ca7  dd19      add     ix,de		; calc next CRAM pos
2ca9  10f9      djnz    #2ca4           ; loop until b==0
2cab  c9        ret     

	;; message # > 80 se 2nd color code
BlankTextDraw:
	; character = *characterToDraw
	; if( color = 0x2f ) goto FinishUpBlankTextDraw
	; characterRam[ix] = 0x40 ("@", which is ' ' in Pac-Man)
	; characterToDraw++
	; b++
2cac  7e        ld      a,(hl)		; read next char
2cad  fe2f      cp      #2f		; are we done ?
2caf  280a      jr      z,#2cbb         ; yes, done with vram

2cb1  dd360040  ld      (ix+#00),#40	; clears the character
2cb5  23        inc     hl		; next char
2cb6  dd19      add     ix,de		; next screen pos
2cb8  04        inc     b		; inc char count
2cb9  18f1      jr      #2cac           ; loop

FinishUpBlankTextDraw:
	; while (*hl != 0x2f) hl++
	; goto SingleOrMultiColorCheck +1
2cbb  23        inc     hl		; next char
2cbc  04        inc     b		; inc char count
2cbd  edb1      cpir    		; loop until [hl] = 2f
2cbf  18d2      jr      #2c93           ; do CRAM

	;; HACK12 - fixes the C000 top/bottom draw mirror issue
	; 2c62  c300d0	jp	hack12

	; hack12:   ;;; up at 0xd000 for this example
	; d000  5e        ld	e, (hl)		; patch (2c62)
	; d001  23        inc	hl		; patch (2c63)
	; d002  7e        ld	a, (hl)		; patch (2c64 almost)
	; d003  e67f      and	#0x7f		; mask off the top/bottom flag
	; d005  57        ld	d, a		; d cleared of that bit now (C000-safe!)
	; d006  7e        ld	a, (hl)		; set aside A for part 2, below
	; d007  c3652c    jp	#2c65		; resume


        ;;
        ;; PROCESS WAVE (all voices) (SOUND)
        ;; called from #01BC
	;;

#if MSPACMAN
2cc1  jp      #9797       		; sprite/cocktail stuff. we don't care for sound.
                          		; The routine ends with "ld hl,#9685", "jp #2cc4"
                          		; so this is a Ms Pacman patch
#else
2cc1  ld      hl,#SONG_TABLE_1
#endif

        ;; channel 1 song

2cc4  ld      ix,#CH1_W_NUM             ; ix = Pointer to Song number
2cc8  ld      iy,#CH1_FREQ0             ; iy = Pointer to Freq/Vol parameters
2ccc  call    #2d44                     ; call process_wave
2ccf  ld      b,a                       ; A is the returned volume (save it in B)
2cd0  ld      a,(#CH1_W_NUM)            ; if we are playing a song
2cd3  and     a
2cd4  jr      z,#2cda
2cd6  ld      a,b                       ; then
2cd7  ld      (#CH1_VOL),a              ; save volume

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
        ;; PROCESS EFFECT (all voices)
        ;;

2d0c  ld      hl,#EFFECT_TABLE_1        ; pointer to sound table
2d0f  ld      ix,#CH1_E_NUM             ; effect number (voice 1)
2d13  ld      iy,#CH1_FREQ0
2d17  call    #2dee                     ; call process effect, returns volume in A
2d1a  ld      (#CH1_VOL),a              ; store volume

2d1d  ld      hl,#EFFECT_TABLE_2        ; same for voice 2
2d20  ld      ix,#CH2_E_NUM
2d24  ld      iy,#CH2_FREQ1
2d28  call    #2dee
2d2b  ld      (#CH2_VOL),a

2d2e  ld      hl,#EFFECT_TABLE_3        ; same for voice 3
2d31  ld      ix,#CH3_E_NUM
2d35  ld      iy,#CH3_FREQ1
2d39  call    #2dee
2d3c  ld      (#CH3_VOL),a

2d3f  xor     a                         ; A = 0
2d40  ld      (#CH1_FREQ4),a            ; freq 4 channel 1 = 0
2d43  ret


        ;;
        ;; Process wave (one voice)
        ;;

2d44  ld      a,(ix+#00)        ; if (W_NUM == 0)
2d47  and     a
2d48  jp      z,#2df4           ; then goto init_param

2d4b  ld      c,a               ; c = W_NUM
2d4c  ld      b,#08             ; b = 0x08
2d4e  ld      e,#80             ; e = 0x80

2d50  ld      a,e               ; find which bit is set in W_NUM
2d51  and     c
2d52  jr      nz,#2d59          ; found one, goto process wave bis
2d54  srl     e
2d56  djnz    #2d50
2d58  ret                       ; return

        ;;
        ;; Process wave bis : process one wave, represented by 1 bit (in E)
        ;;

2d59  ld      a,(ix+#02)        ; A = CUR_BIT
2d5c  and     e
2d5d  jr      nz,#2d66          ; if (CUR_BIT & E != 0) then goto #2d66
2d5f  ld      (ix+#02),e        ; else save E in CUR_BIT
2d62  jp      #364e             ; jump to new ms. pac man routine.  returns to #2D72

2d65  inc     c                 ; junk from pac-man

2d66  dec     (ix+#0c)          ; decrement W_DURATION
2d69  jp      nz,#2dd7          ; if W_DURATION == 0

2d6c  ld      l,(ix+#06)        ; then HL = pointer store in W_OFFSET
2d6f  ld      h,(ix+#07)

        ;; process byte

2d72  ld      a,(hl)            ; A = (HL)
2d73  inc     hl
2d74  ld      (ix+#06),l        ; W_OFFSET = ++HL
2d77  ld      (ix+#07),h
2d7a  cp      #f0               ; if (A < #F0)
2d7c  jr      c,#2da5           ; then process A  (regular byte)
2d7e  ld      hl,#2d6c          ; else process special byte using a jump table.  load HL with return address
2d81  push    hl                ; push return address to stack
2d82  and     #0f               ; mask bits; takes lowest nibble of special byte
2d84  rst     #20               ; and jump based on A (return in HL = 2d6c)

        ;; jump table

2d85  55 2f                     ; #2F55 ; byte is F0
2d87  65 2f                     ; #2F65 ; byte is F1
2d89  77 2f                     ; #2F77 ; byte is F2
2d8b  89 2f                     ; #2F89 ; byte is F3
2d8d  9b 2f                     ; #2F9B ; byte is F4
2d8f  0c 00                     ; #000C ; returns immediately ; byte is F5
2d91  0c 00                     ; #000C ; returns immediately ; byte is F6
2d93  0c 00                     ; #000C ; returns immediately ; byte is F7
2d95  0c 00                     ; #000C ; returns immediately ; byte is F8
2d97  0c 00                     ; #000C ; returns immediately ; byte is F9
2d99  0c 00                     ; #000C ; returns immediately ; byte is FA
2d9b  0c 00                     ; #000C ; returns immediately ; byte is FB
2d9d  0c 00                     ; #000C ; returns immediately ; byte is FC
2d9f  0c 00                     ; #000C ; returns immediately ; byte is FD
2da1  0c 00                     ; #000C ; returns immediately ; byte is FE
2da3  ad 2f                     ; #2FAD ; byte is FF


        ;; process regular byte (A=byte to process, it's not a special byte)

2da5  ld      b,a               ; copy A into B

2da6  and     #1f
2da8  jr      z,#2dad           ; if (A & 0x1f == 0)
2daa  ld      (ix+#0d),b        ; then W_DIR = B
2dad  ld      c,(ix+#09)        ; C = W_9
2db0  ld      a,(ix+#0b)
2db3  and     #08
2db5  jr      z,#2db9           ; if (W_8 & 0x8 == 0)
2db7  ld      c,#00             ; then VOL = 0
2db9  ld      (ix+#0f),c        ; else VOL = W_9

2dbc  ld      a,b               ; restore A
2dbd  rlca
2dbe  rlca
2dbf  rlca
2dc0  and     #07               ; A = (A & 0xE0) >> 5
2dc2  ld      hl,#3bb0
2dc5  rst     #10               ; A = ROM[0x3bb0 + A]
                                ; Note: this is just A = 2**A

2dc6  ld      (ix+#0c),a        ; W_DURATION = A

2dc9  ld      a,b               ; restore A
2dca  and     #1f
2dcc  jr      z,#2dd7           ; if (A & 0x1f == 0) then goto compute_wave_freq
2dce  and     #0f               ; A = A & 0x0F
2dd0  ld      hl,#3bb8          ; lookup table, contains a table a frequencies
2dd3  rst     #10
2dd4  ld      (ix+#0e),a        ; W_BASE_FREQ = ROM[3bb8 + A]

        ;; compute wave frequency

2dd7  ld      l,(ix+#0e)
2dda  ld      h,#00             ; HL = W_BASE_FREQ (on 16 bits)

2ddc  ld      a,(ix+#0d)        ; A = W_DIR
2ddf  and     #10
2de1  jr      z,#2de5           ; if (W_DIR & 0x10 != 0) then
2de3  ld      a,#01             ;       A = 1
2de5  add     a,(ix+#04)        ; A += W_4

2de8  jp      z,#2ee8           ; compute new frequency  FREQ = BASE_FREQ * (1 << A)
2deb  jp      #2ee4


        ;;
        ;; Process effect (one voice)
        ;;

2dee    ld      a,(ix+#00)      ; if (E_NUM != 0)
2df1    and     a               ;
2df2    jr      nz,#2e1b        ; then goto find effect

        ;;
        ;; Init Param
        ;;

2df4    ld      a,(ix+#02)      ; if (CUR_BIT == 0)
2df7    and     a
2df8    ret     z               ; then return


2df9    ld      (ix+#02),#00    ; CUR_BIT = 0
2dfd    ld      (ix+#0d),#00    ; DIR = 0
2e01    ld      (ix+#0e),#00    ; BASE_FREQ = 0
2e05    ld      (ix+#0f),#00    ; VOL = 0
2e09    ld      (iy+#00),#00    ; FREQ0 or 1   (5 freq for channel 1)
2e0d    ld      (iy+#01),#00    ; FREQ1 or 2
2e11    ld      (iy+#02),#00    ; FREQ2 or 3
2e15    ld      (iy+#03),#00    ; FREQ3 or 4
2e19    xor     a               ;
2e1a    ret                     ; return 0

        ;;
        ;; find effect. Effect num is not zero, find which bits are set
        ;;

2e1b  ld      c,a               ; c = E_NUM
2e1c  ld      b,#08             ; b = 0x08
2e1e  ld      e,#80             ; e = 0x80

2e20  ld      a,e               ; find which bit is set in E_NUM
2e21  and     c
2e22  jr      nz,#2e29          ; found one, goto proces effect bis
2e24  srl     e
2e26  djnz    #2e20
2e28  ret


        ;;
        ;; Process effect bis : process one effect, represented by 1 bit (in E)
        ;;

2e29  ld      a,(ix+#02)        ; A = CUR_BIT
2e2c  and     e
2e2d  jr      nz,#2e6e          ; if (CUR_BIT & E != 0) then goto 2e6e
2e2f  ld      (ix+#02),e        ; else save E in CUR_BIT

                                ; locate the 8 bytes for this effect in the rom tables
2e32  dec     b                 ; the address is at HL + (B-1) * 8
2e33  ld      a,b
2e34  rlca
2e35  rlca
2e36  rlca
2e37  ld      c,a               ; C = (B-1)*8
2e38  ld      b,#00             ; B = 0
2e3a  push    hl                ; save HL (pointer to EFFECT_TABLE)
2e3b  add     hl,bc             ; HL = HL + (B-1)*8
2e3c  push    ix
2e3e  pop     de                ; DE = E_NUM
2e3f  inc     de
2e40  inc     de
2e41  inc     de                ; DE = E_TABLE0
2e42  ld      bc,#0008
2e45  ldir                      ; copy 8 bytes from rom
2e47  pop     hl                ; restore HL (pointer to EFFECT_TABLE)

2e48  ld      a,(ix+#06)
2e4b  and     #7f
2e4d  ld      (ix+#0c),a        ; E_DURATION = E_TABLE3 & 0x7F

2e50  ld      a,(ix+#04)
2e53  ld      (ix+#0e),a        ; E_BASE_FREQ = E_TABLE1

2e56  ld      a,(ix+#09)
2e59  ld      b,a               ; B = E_TABLE6
2e5a  rrca
2e5b  rrca
2e5c  rrca
2e5d  rrca
2e5e  and     #0f
2e60  ld      (ix+#0b),a        ; E_TYPE = (E_TABLE6 >> 4) & 0xF

2e63  and     #08
2e65  jr      nz,#2e6e          ; if (E_TYPE & 0x8 == 0) then
2e67  ld      (ix+#0f),b        ;       E_VOL = E_TABLE6
2e6a  ld      (ix+#0d),#00      ;       E_DIR = 0

        ;; compute effect

2e6e  dec     (ix+#0c)          ; E_DURATION--
2e71  jr      nz,#2ecd          ; if (E_DURATION == 0) then
2e73  ld      a,(ix+#08)
2e76  and     a
2e77  jr      z,#2e89           ;       if (E_TABLE5 != 0) then
2e79  dec     (ix+#08)          ;               E_TABLE5--
2e7c  jr      nz,#2e89          ;               if (E_TABLE5 == 0) then
2e7e  ld      a,e
2e7f  cpl
2e80  and     (ix+#00)
2e83  ld      (ix+#00),a        ;                       E_NUM &= ~E_CUR_BIT
2e86  jp      #2dee             ;                       goto process effect (one voice)
2e89  ld      a,(ix+#06)
2e8c  and     #7f
2e8e  ld      (ix+#0c),a        ;       E_DURATION = E_TABLE3 & 0x7F
2e91  bit     7,(ix+#06)
2e95  jr      z,#2ead           ;       if (E_TABLE3 & 0x80 != 0) then
2e97  ld      a,(ix+#05)
2e9a  neg
2e9c  ld      (ix+#05),a        ;               E_TABLE2 = - E_TABLE2
2e9f  bit     0,(ix+#0d)        ;               if (E_DIR & 0x1 == 0) then
2ea3  set     0,(ix+#0d)        ;                       E_DIR |= 0x1
2ea7  jr      z,#2ecd           ;                       goto update_freq
2ea9  res     0,(ix+#0d)        ;               E_DIR &= ~0x1
2ead  ld      a,(ix+#04)
2eb0  add     a,(ix+#07)
2eb3  ld      (ix+#04),a        ;       E_TABLE1 += E_TABLE4
2eb6  ld      (ix+#0e),a        ;       E_BASE_FREQ = E_TABLE1
2eb9  ld      a,(ix+#09)
2ebc  add     a,(ix+#0a)
2ebf  ld      (ix+#09),a        ;       E_TABLE6 += E_TABLE7
2ec2  ld      b,a
2ec3  ld      a,(ix+#0b)
2ec6  and     #08
2ec8  jr      nz,#2ecd          ;       if (E_TYPE & 0x8 == 0) then
2eca  ld      (ix+#0f),b        ;               E_VOL = E_TABLE6


        ;; update freq

2ecd  ld      a,(ix+#0e)
2ed0  add     a,(ix+#05)
2ed3  ld      (ix+#0e),a        ; E_BASE_FREQ += E_TABLE2

2ed6  ld      l,a
2ed7  ld      h,#00             ; HL = E_BASE_FREQ (on 16 bits)

2ed9  ld      a,(ix+#03)        ; compute new frequency
2edc  and     #70               ; FREQ = E_BASE_FREQ * ((1 << E_TABLE0 & 0x70) >> 4)
2ede  jr      z,#2ee8
2ee0  rrca
2ee1  rrca
2ee2  rrca
2ee3  rrca

        ;; compute new frequency

2ee4  ld      b,a               ; B = counter
2ee5  add     hl,hl             ; HL = 2 * HL
2ee6  djnz    #2ee5
                                ; HL = HL * 2**B
                                ; now extract the nibbles from HL

2ee8  ld      (iy+#00),l        ; 1st nibble
2eeb  ld      a,l
2eec  rrca
2eed  rrca
2eee  rrca
2eef  rrca
2ef0  ld      (iy+#01),a        ; 2nd nibble
2ef3  ld      (iy+#02),h        ; 3rd nibble
2ef6  ld      a,h
2ef7  rrca
2ef8  rrca
2ef9  rrca
2efa  rrca
2efb  ld      (iy+#03),a        ; 4th nibble

2efe  ld      a,(ix+#0b)        ; A = W_TYPE
2f01  rst     #20               ; jump table to volume adjust routine

        ; jump table to adjust volume

2f02  22 2f 			; #2F22
2F04  26 2f			; #2F26
2F06  2b 2f			; #2F2B
2F08  3c 2f			; #2F3C
2F0A  43 2f			; #2F43
2F0C  4a 2f			; #2F4A
2F0E  4b 2f			; #2F4B
2F10  4c 2f			; #2F4C
2F12  4d 2f			; #2F4D
2F14  4e 2f			; #2F4E
2F16  4f 2f			; #2F4F
2F18  50 2f			; #2F50
2F1A  51 2f			; #2F51
2F1C  52 2f			; #2F52
2F1E  53 2f			; #2F53
2F20  54 2f			; #2F54

        ;; type 0

2f22  ld      a,(ix+#0f)        ; constant volume
2f25  ret

        ;; type 1

2f26  ld      a,(ix+#0f)        ; decreasing volume
2f29  jr      #2f34

        ;; type 2

2f2b  ld      a,(#4c84)         ; decreasing volume (1/2 rate)
2f2e  and     #01
2f30  ld      a,(ix+#0f)        ; (skip decrease if sound_counter (4c84) is odd)
2f33  ret     nz

2f34  and     #0f               ; decrease routine
2f36  ret     z
2f37  dec     a
2f38  ld      (ix+#0f),a
2f3b  ret

        ;; type 3

2f3c  ld      a,(#4c84)         ; decreasing volume (1/4 rate)
2f3f  and     #03
2f41  jr      #2f30

        ;; type 4

2f43  ld      a,(#4c84)         ; decreasing volume (1/8 rate)
2f46  and     #07
2f48  jr      #2f30

        ;; type 5-15

2f4a  c9        ret     
2f4b  c9        ret     
2f4c  c9        ret     
2f4d  c9        ret     
2f4e  c9        ret     
2f4f  c9        ret     
2f50  c9        ret     
2f51  c9        ret     
2f52  c9        ret     
2f53  c9        ret     
2f54  c9        ret     

        ;;
        ;; Special byte F0 : this is followed by 2 bytes, the new offset (to allow loops)
        ;;

2f55  ld      l,(ix+#06)
2f58  ld      h,(ix+#07)        ; HL = (W_OFFSET)
2f5b  ld      a,(hl)
2f5c  ld      (ix+#06),a
2f5f  inc     hl
2f60  ld      a,(hl)
2f61  ld      (ix+#07),a        ; HL = (HL)
2f64  ret

        ;;
        ;; Special byte F1 : followed by one byte (wave select)
        ;;

2f65  ld      l,(ix+#06)
2f68  ld      h,(ix+#07)
2f6b  ld      a,(hl)            ; A = (++HL)
2f6c  inc     hl
2f6d  ld      (ix+#06),l
2f70  ld      (ix+#07),h
2f73  ld      (ix+#03),a        ; save A in W_WAVE_SEL
2f76  ret

        ;;
        ;; Special byte F2 : followed by one byte (Frequency increment)
        ;;

2f77  ld      l,(ix+#06)
2f7a  ld      h,(ix+#07)
2f7d  ld      a,(hl)            ; A = (++HL)
2f7e  inc     hl
2f7f  ld      (ix+#06),l
2f82  ld      (ix+#07),h
2f85  ld      (ix+#04),a        ; save A in W_A
2f88  ret

        ;;
        ;; Special byte F3 : followed by one byte (Volume)
        ;;

2f89  ld      l,(ix+#06)
2f8c  ld      h,(ix+#07)
2f8f  ld      a,(hl)            ; A = (++HL)
2f90  inc     hl
2f91  ld      (ix+#06),l
2f94  ld      (ix+#07),h
2f97  ld      (ix+#09),a        ; save A in W_VOL
2f9a  ret

        ;;
        ;; Special byte F4 : followed by one byte (Type)
	;;

2f9b  ld      l,(ix+#06)
2f9e  ld      h,(ix+#07)
2fa1  ld      a,(hl)            ; A = (++HL)
2fa2  inc     hl
2fa3  ld      (ix+#06),l
2fa6  ld      (ix+#07),h
2fa9  ld      (ix+#0b),a        ; save A in W_TYPE
2fac  ret

        ;;
        ;; Special byte FF : mark the end of the song
        ;;

2fad  ld      a,(ix+#02)
2fb0  cpl
2fb1  and     (ix+#00)
2fb4  ld      (ix+#00),a        ; W_NUM &= ~W_CUR_BIT
2fb7  jp      #2df4

;

2FBA:  00 00 00 00 00 00
2FC0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2FD0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2FE0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
2FF0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00

2FFE:  83 4C				; checksum bytes for #2000-#2FFF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3000 - 3fff
;; this rom is somehow overlayed from U7 on the aux board.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; rst 38 continuation (initalization routine portion)
	;; the rom checksum routine 

3000  210000    ld      hl,#0000	; clear HL
3003  010010    ld      bc,#1000	; B := #10 (loop counter), C := #00

	; reclaim a lot of romspace by skipping self test ; HACK4
	; 3000  31c04f    ld      sp,#4fc0
	; 3003  c3c130    jp      #30c1
	;

3006  32c050    ld      (#50c0),a	; kick the dog

3009  79        ld      a,c		; A := C
300a  86        add     a,(hl)		; add the value in HL into A
300b  4f        ld      c,a		; copy to C
300c  7d        ld      a,l		; load A with the low byte of HL
300d  c602      add     a,#02		; add 2.  this ensures only checking even or odd bytes
300f  6f        ld      l,a		; store result
3010  fe02      cp      #02		; < #02 ?
3012  d20930    jp      nc,#3009	; no, loop again

3015  24        inc     h		; yes, increase H
3016  10ee      djnz    #3006           ; next B

3018  79        ld      a,c		; load A with the final result
3019  a7        and     a		; == #00 ?  It must be zero for the checksum to work out

301a  00        nop     		;; this is a hack to disregard bad csums
301b  00        nop     		;; this is a hack to disregard bad csums
	
	; PAC and ms pac non-bootleg
	;301a  2015	jr 	nz, #3031	; check for bad checksum
	;

301c  320750    ld      (#5007),a	; clear coin
301f  7c        ld      a,h		; load A with high byte
3020  fe30      cp      #30		; == #30 ?
3022  c20330    jp      nz,#3003	; no, loop back and continue for other roms

3025  2600      ld      h,#00		; else H := #00
3027  2c        inc     l		; increase L.  this will give a check of the odd numbered bytes
3028  7d        ld      a,l		; load A with this value. 
3029  fe02      cp      #02		; are we all done ?
302b  da0330    jp      c,#3003		; no, loop again

302e  c34230    jp      #3042		; yes, skip ahead for RAM test

		;; bad rom checksum  (not called in bootleg, due to above patch)

3031  25        dec     h		; decrease H
3032  7c        ld      a,h		; store into A
3033  e6f0      and     #f0		; mask bits
3035  320750    ld      (#5007),a	; clear Coin counter
3038  0f        rrca
3039  0f        rrca
303a  0f        rrca
303b  0f        rrca			; rotate right 4 times 
303c  5f        ld      e,a		; load E with failed ROM number
303d  0600      ld      b,#00		; load B with code for error
303f  c3bd30    jp      #30bd		; skip ahead

		;; RAM TEST (4c00)

3042  315431    ld      sp,#3154	; set stack pointer to ram test data table
3045  06ff      ld      b,#ff		; B := #FF

3047  e1        pop     hl		; load HL with table data = starting address to test
3048  d1        pop     de		; load DE with table data.  D = loop counter (always #04) , E = mask (either #0F or #F0)
3049  48        ld      c,b		; C := #FF

		; write to RAM

304a  32c050    ld      (#50c0),a	; kick the dog

304d  79        ld      a,c		; A := C
304e  a3        and     e		; mask bits with E
304f  77        ld      (hl),a		; store into memory
3050  c633      add     a,#33		; add #33
3052  4f        ld      c,a		; store into C
3053  2c        inc     l		; next memory
3054  7d        ld      a,l		; A : = L
3055  e60f      and     #0f		; mask bits.  are we done ?
3057  c24d30    jp      nz,#304d	; no, loop again

305a  79        ld      a,c		; yes, A := C
305b  87        add     a,a		; A := A * 2
305c  87        add     a,a		; A := A * 2
305d  81        add     a,c		; A := A + C
305e  c631      add     a,#31		; A := A + #31
3060  4f        ld      c,a		; C := A
3061  7d        ld      a,l		; A := L
3062  a7        and     a		; are we done ?
3063  c24d30    jp      nz,#304d	; no, loop again

3066  24        inc     h		; yes, next high byte
3067  15        dec     d		; decrement counter.  are we done ?
3068  c24a30    jp      nz,#304a	; no, loop again

306b  3b        dec     sp
306c  3b        dec     sp
306d  3b        dec     sp
306e  3b        dec     sp		; yes, set stack pointer back to beginning
306f  e1        pop     hl		; load HL with table data
3070  d1        pop     de		; load DE with table data
3071  48        ld      c,b		; C := B

		; check RAM again

3072  32c050    ld      (#50c0),a	; kick the dog

3075  79        ld      a,c		; A := C
3076  a3        and     e		; mask bits with E
3077  4f        ld      c,a		; C := A
3078  7e        ld      a,(hl)		; load A with memory value
3079  a3        and     e		; mask bits with E
307a  b9        cp      c		; are they the same ?
307b  c2b530    jp      nz,#30b5	; no, RAM test failed, jump ahead for bad RAM

307e  c633      add     a,#33		; yes, A := A + #33
3080  4f        ld      c,a		; C := A
3081  2c        inc     l		; next address
3082  7d        ld      a,l		; A := L
3083  e60f      and     #0f		; mask bits, are we done ?
3085  c27530    jp      nz,#3075	; no, loop again

3088  79        ld      a,c		; yes, A := C
3089  87        add     a,a		; A := A * 2
308a  87        add     a,a		; A := A * 2
308b  81        add     a,c		; A := A + C
308c  c631      add     a,#31		; A := A + #31
308e  4f        ld      c,a		; C := A
308f  7d        ld      a,l		; A := L
3090  a7        and     a		; are we done ?
3091  c27530    jp      nz,#3075	; no, loop again

3094  24        inc     h		; yes, next high byte
3095  15        dec     d		; decrement counter.  are we done ?
3096  c27230    jp      nz,#3072	; no, loop again

3099  3b        dec     sp
309a  3b        dec     sp
309b  3b        dec     sp
309c  3b        dec     sp		; yes, set stack pointer back to beginning
309d  78        ld      a,b		; A := B
309e  d610      sub     #10		; A := A - #10
30a0  47        ld      b,a		; B := A
30a1  10a4      djnz    #3047           ; loop until done


30a3  f1        pop     af		; load AF with table data = address
30a4  d1        pop     de		; load DE with loop counter and mask
30a5  fe44      cp      #44		; was this the last group of addresses ?
30a7  c24530    jp      nz,#3045	; no, loop again

30aa  7b        ld      a,e		; yes, A := E
30ab  eef0      xor     #f0		; was this the very last group with mask #F0 ?
30ad  c24530    jp      nz,#3045	; no, loop again

30b0  0601      ld      b,#01		; load B with code for no errors
30b2  c3bd30    jp      #30bd		; jump ahead


	; bad RAM

30b5  7b        ld      a,e		; A := E
30b6  e601      and     #01		; mask bits
30b8  ee01      xor     #01		; flip bit 0
30ba  5f        ld      e,a		; E := A
30bb  0600      ld      b,#00		; load B with code for error

	; display bad ROM

30bd  31c04f    ld      sp,#4fc0	; set stack pointer
30c0  d9        exx     		; swap register pairs


	; clear all program RAM

30c1  21004c    ld      hl,#4c00	; load HL with start of program RAM
30c4  0604      ld      b,#04		; For B = 1 to 4
30c6  32c050    ld      (#50c0),a	; kick the dog
30c9  3600      ld      (hl),#00	; clear RAM
30cb  2c        inc     l		; next address.  are we done?
30cc  20fb      jr      nz,#30c9        ; no, loop again

30ce  24        inc     h		; next high byte
30cf  10f5      djnz    #30c6           ; next B

	; set all video ram to 0x40 - clear screen

30d1  210040    ld      hl,#4000	; load HL with start of video RAM
30d4  0604      ld      b,#04		; For B = 1 to 4
30d6  32c050    ld      (#50c0),a	; kick the dog
30d9  3e40      ld      a,#40		; A := #40 = clear character

30db  77        ld      (hl),a		; clear the RAM
30dc  2c        inc     l		; next address
30dd  20fc      jr      nz,#30db        ; loop until zero

30df  24        inc     h		; next high byte
30e0  10f4      djnz    #30d6           ; Next B

	;; set all color ram to 0x0f

30e2  0604      ld      b,#04		; For B = 1 to 4
30e4  32c050    ld      (#50c0),a	; kick the dog
30e7  3e0f      ld      a,#0f		; A := #0F

30e9  77        ld      (hl),a		; store
30ea  2c        inc     l		; next address
30eb  20fc      jr      nz,#30e9        ; loop until zero

30ed  24        inc     h		; next high byte
30ee  10f4      djnz    #30e4           ; next B


	;; change 30f0 - 30f2 to "00 nop" to skip checksum check. ; HACK4
	;;  if you do that, 30fb - 3173 can be reclaimed for other code use.
	; 30f0  00	nop
	; 30f1  00	nop
	; 30f2  00	nop
	;;
	;;


30f0  d9        exx     		; reswap register pairs
30f1  1008      djnz    #30fb           ; Decrease B.  was there an error?  Yes, jump ahead

30f3  0623      ld      b,#23		; else load B with code for "MEMORY OK"

	;; eliminate startup tests ; HACK7
	; 30f5  00	nop
	; 30f6  00	nop
	; 30f7  00	nop
	;;

30f5  cd5e2c    call    #2c5e		; print to screen
30f8  c37431    jp      #3174		; jump ahead to test mode

	; skip the checksum test, change 30fb to: ; HACK 0
	; 30fb  c37431    jp      #3174		; run the game!
	;

30fb  7b        ld      a,e		; load A with bad rom #
30fc  c630      add     a,#30		; add offset for ascii code

30fe  328441    ld      (#4184),a	; write to screen
3101  c5        push    bc		; save BC
3102  e5        push    hl		; save HL
3103  0624      ld      b,#24		; load B with code for "BAD R M"
3105  cd5e2c    call    #2c5e		; print to screen
3108  e1        pop     hl		; restore HL
3109  7c        ld      a,h		; A := H
310a  fe40      cp      #40		; <= #40 ?
310c  2a6c31    ld      hl,(#316c)	; load HL with #4F (code for "O"), #40 (code for " ")
310f  3811      jr      c,#3122         ; yes, jump ahead to display

3111  fe4c      cp      #4c		; <= #4C ?
3113  2a6e31    ld      hl,(#316e)	; load HL with #41 (code for "A"), #57 (code for "W")
3116  300a      jr      nc,#3122        ; yes, jump ahead to display

3118  fe44      cp      #44		; <= #44 ?
311a  2a7031    ld      hl,(#3170)	; load HL with #41 (code for "A"), #56 (code for "V")
311d  3803      jr      c,#3122         ; yes, jump ahed to display

311f  2a7231    ld      hl,(#3172)	; else load HL with #41 (code for "A"), #43 (code for "C")

3122  7d        ld      a,l		; A := L
3123  320442    ld      (#4204),a	; display to screen
3126  7c        ld      a,h		; A := H
3127  326442    ld      (#4264),a	; display to screen
312a  3a0050    ld      a,(#5000)	; load A with IN0
312d  47        ld      b,a		; store into B
312e  3a4050    ld      a,(#5040)	; load A with IN1
3131  b0        or      b		; mix with IN0
3132  e601      and     #01		; check for bit 0 .  are both joysticks being pushed up?
3134  2011      jr      nz,#3147        ; no, skip ahead

3136  c1        pop     bc		; yes, restore BC
3137  79        ld      a,c		; A := C
3138  e60f      and     #0f		; mask bits
313a  47        ld      b,a		; B := A
313b  79        ld      a,c		; A := C
313c  e6f0      and     #f0		; mask bits
313e  0f	rrca
313f  0f	rrca
3140  0f	rrca
3141  0f	rrca			; rotate right 4 times
3142  4f	ld      c,a		; C := A
3143  ed438541  ld      (#4185),bc	; display to screen

3147  32c050    ld      (#50c0),a	; kick the dog
314a  3a4050    ld      a,(#5040)	; load A with IN1
314d  e610      and     #10		; is service mode switch on?
314f  28f6      jr      z,#3147         ; no, loop forever

3151  c30b23    jp      #230b		; yes, jump back to program

	; ram test data, used in routine at #3042

3154  00 4c 0f 04			; #4C00, mask = #0F, counter = 4, work ram low nibble
3158  00 4c f0 04			; #4C00, mask = #F0, counter = 4, work ram high nibble
315c  00 40 0f 04			; #4000, mask = #0F, counter = 4, video ram low nibble
3160  00 40 f0 04			; #4000, mask = #F0, counter = 4, video ram high nibble
3164  00 44 0f 04			; #4400, mask = #0F, counter = 4, color ram low nibble
3168  00 44 f0 04			; #4400, mask = #F0, counter = 4, color ram high nibble

	; data used in the error routine for printing, starting at #310C
	; BAD (W/V/CRAM, ROM)

316C  4F 40				; "O", " "
316E  41 57				; "A", "W"
3170  41 56				; "A", "V"
3172  41 43				; "A", "C"


	;; start the main section... (tests first)

3174  210650    ld      hl,#5006	; load HL with coin lockout (not used?)
3177  3e01      ld      a,#01		; A := #01

3179  77        ld      (hl),a		; enable coin lockout, players start lamps, flip screen, sound, and interrupt enable
317a  2d        dec     l		; decrease
317b  20fc      jr      nz,#3179        ; loop until zero

317d  af        xor     a		; A := #00
317e  320350    ld      (#5003),a	; unflip screen
3181  d604      sub     #04		; A := #FC
3183  ed47      ld      i,a		; set interrupt vector to #3FFC.  [This address has the value of #008D]

	; pac:
	; 3183  d300      out     (#00),a         ; set vector TO #8D WHEN INTERRUPT
	;

3185  31c04f    ld      sp,#4fc0	; set stack pointer at #4FC0

3188  32c050    ld      (#50c0),a	; kick the dog
318b  af        xor     a		; A := #00

	; Skip test mode: HACK7
	; 318c  31c04f	ld	sp,#4fc0	; set stack pointer
	; 318f  c39032	jp	#3290		; skip over the test mode
	;

318c  32004e    ld      (#4e00),a	; set main routine number to initialize
318f  3c        inc     a		; A : = #01

3190  32014e    ld      (#4e01),a	; set main routine 0, subroutine # to 1
3193  320050    ld      (#5000),a	; enable hardware interrupts
3196  fb        ei     		 	; enable software interrupts

	;; test mode sound checks
	;; this gets called if the test switch is on at bootup

3197  3a0050    ld      a,(#5000)	; load A with IN0
319a  2f        cpl     		; invert
319b  47        ld      b,a		; copy to B
319c  e6e0      and     #e0		; check all coin/credit inputs
319e  2805      jr      z,#31a5         ; if no credits, skip to next test
31a0  3e02      ld      a,#02		; set credit sound
31a2  329c4e    ld      (#4e9c),a	; play sound

31a5  3a4050    ld      a,(#5040)	; load A with IN1
31a8  2f        cpl     		; invert
31a9  4f        ld      c,a		; copy to C
31aa  e660      and     #60		; check p1/p2 start
31ac  2805      jr      z,#31b3         ; if start buttons not pressed, skip to next test
31ae  3e01      ld      a,#01		; set sound to extra base
31b0  329c4e    ld      (#4e9c),a	; play sound

31b3  78        ld      a,b		; load A with IN0 inverted
31b4  b1        or      c		; or with IN1 inverted
31b5  e601      and     #01		; check up on either IN0 or IN1
31b7  2805      jr      z,#31be         ; if not, skip ahead to next test
31b9  3e08      ld      a,#08		; set sound to ghost eat
31bb  32bc4e    ld      (#4ebc),a	; play sound

31be  78        ld      a,b		; load A with IN0 inverted
31bf  b1        or      c		; or with IN1 inverted
31c0  e602      and     #02		; check left on either IN0 or IN1
31c2  2805      jr      z,#31c9         ; if not, skip to next test
31c4  3e04      ld      a,#04		; set sound to fruit eat
31c6  32bc4e    ld      (#4ebc),a	; play sound

31c9  78        ld      a,b		; load A with IN0 inverted
31ca  b1        or      c		; or with IN1 inverted
31cb  e604      and     #04		; check right on either In0 or In1
31cd  2805      jr      z,#31d4         ; if not, skip to next test
31cf  3e10      ld      a,#10		; set sound to death
31d1  32bc4e    ld      (#4ebc),a	; play sound

31d4  78        ld      a,b		; load A with IN0 inverted
31d5  b1        or      c		; or with IN1 inverted
31d6  e608      and     #08		; check down on either IN0 or IN1
31d8  2805      jr      z,#31df         ; if not, skip to next test
31da  3e20      ld      a,#20		; set sound to fruit bouncing sound
31dc  32bc4e    ld      (#4ebc),a	; play sound

31df  3a8050    ld      a,(#5080)	; load A with DSW1 (dip switches)
31e2  e603      and     #03		; mask bits to only look at coins/credits information
31e4  c625      add     a,#25		; add #25
31e6  47        ld      b,a		; copy to B
31e7  cd5e2c    call    #2c5e		; print "FREE PLAY" or "1 COIN 1 CREDIT" etc, based on what the DIP settings are

31ea  3a8050    ld      a,(#5080)	; load A with DSW1 (dip switches)
31ed  0f        rrca
31ee  0f        rrca
31ef  0f        rrca
31f0  0f        rrca			; roll right 4 times 
31f1  e603      and     #03		; mask bits, now reads the settings for points needed for bonus life
31f3  fe03      cp      #03		; == #03 (no bonus life) ?
31f5  2008      jr      nz,#31ff        ; no, skip ahead

31f7  062a      ld      b,#2a		; load B with code for "BONUS NONE"
31f9  cd5e2c    call    #2c5e		; print
31fc  c31c32    jp      #321c		; skip ahead for next test

31ff  07        rlca			; rotate left  
3200  5f        ld      e,a		; copy to E
3201  d5        push    de		; save to stack
3202  062b      ld      b,#2b		; load B with code for "BONUS"
3204  cd5e2c    call    #2c5e		; print
3207  062e      ld      b,#2e		; load B with code for "000"
3209  cd5e2c    call    #2c5e		; print
320c  d1        pop     de		; restore original value
320d  1600      ld      d,#00		; D := #00
320f  21f932    ld      hl,#32f9	; load HL with bonus table start
3212  19        add     hl,de		; add offset
3213  7e        ld      a,(hl)		; load A with first byte from bonus table
3214  322a42    ld      (#422a),a	; write to screen
3217  23        inc     hl		; next table value
3218  7e        ld      a,(hl)		; load A with second byte from bonus table
3219  324a42    ld      (#424a),a	; write to screen

321c  3a8050    ld      a,(#5080)	; load A with DSW1 (dip switches)
321f  0f        rrca  
3220  0f        rrca			; roll right twice
3221  e603      and     #03		; mask bits.  now shows # of lives per game settings
3223  c631      add     a,#31		; add offset to compute which text to display
3225  fe34      cp      #34		; == #34 (setting for 5 lives per game) ?
3227  2001      jr      nz,#322a        ; no, skip next step
3229  3c        inc     a		; A := A + 1 (A := #35)
322a  32ac41    ld      (#41ac),a	; write this digit to the screen (1, 2, 3, or 5)

	; pac:
; 322a  320c42    ld      (#420c),a
	;

322d  0629      ld      b,#29		; load B with code for "MS PAC-MEN"
322f  cd5e2c    call    #2c5e		; print
3232  3a4050    ld      a,(#5040)	; load A with IN1 (bit 7 has the DIP setting for upright/cocktail)
3235  07        rlca			; rotate left. moves bit 7 into bit 0
3236  e601      and     #01		; mask bits.  is this set for upright or cocktail?
3238  c62c      add     a,#2c		; add #2C to adjust for "TABLE" or "UPRIGHT" message
323a  47        ld      b,a		; set message
323b  cd5e2c    call    #2c5e		; print
323e  3a4050    ld      a,(#5040)	; check in1
3241  e610      and     #10		; mask bits.  is the service mode switch still on ?
3243  ca8831    jp      z,#3188		; yes, loop again

3246  af        xor     a		; no, A := #00
3247  320050    ld      (#5000),a	; disable hardware interrupts
324a  f3        di      		; disable software interrupts
324b  210750    ld      hl,#5007	; load HL with coin counter hardware address
324e  af        xor     a		; A := #00
324f  77        ld      (hl),a		; store, disable coin lockout, players start lamps, flip screen, sound, and interrupts
3250  2d        dec     l		; decrease address
3251  20fc      jr      nz,#324f        ; loop until zero


	; eliminate just the test grid: HACK7 (alternate)
	; 3253  31c04f    ld      sp,#4fc0
	; 3262  c38632    jp      #3286


	; preload the stack with some data for the grid test
	; prep for the test grid


3253  31e23a    ld      sp,#3ae2	; set stack pointer at #3AE2
3256  0603      ld      b,#03		; B := #03

3258  d9        exx			; exchange register pairs BC, DE, and HL with alternates
3259  e1        pop     hl		; load HL with table data - 3 screen region grid data for self test.  first value is #4002
325a  d1        pop     de		; load DE with table data (EG. #3E01)

325b  32c050    ld      (#50c0),a	; kick the dog
325e  c1        pop     bc		; load BC with next value from table.   (EG #103D) 

	;; draw the test grid to the screen

325f  3e3c      ld      a,#3c		; A := #3C (graphic for upper right)
3261  77        ld      (hl),a		; write to screen 
3262  23        inc     hl		; next screen address
3263  72        ld      (hl),d		; write to screen (#3E = graphic for lower right)
3264  23        inc     hl		; next screen address
3265  10f8      djnz    #325f           ; loop until done

3267  3b        dec     sp		
3268  3b        dec     sp		; next table data
3269  c1        pop     bc		; load BC with next value from table

326a  71        ld      (hl),c		; write upper left graphic to screen
326b  23        inc     hl		; next screen address
326c  3e3f      ld      a,#3f		; load A with lower left graphic
326e  77        ld      (hl),a		; write to screen
326f  23        inc     hl		; next address
3270  10f8      djnz    #326a           ; loop until done

3272  3b        dec     sp
3273  3b        dec     sp		; next table address
3274  1d        dec     e		; decrease E, are we done ?
3275  c25b32    jp      nz,#325b	; no, loop again

3278  f1        pop     af		; restore AF
3279  d9        exx			; exchange register pairs BC, DE, and HL with alternates
327a  10dc      djnz    #3258           ; loop until done

327c  31c04f    ld      sp,#4fc0	; set stack pointer to #4FC0

327f  0608      ld      b,#08		; For B = 1 to 8
3281  cded32    call    #32ed		; call the delay routine
3284  10fb      djnz    #3281           ; Next B

	; loop until service switch turned off

3286  32c050    ld      (#50c0),a	; kick the dog
3289  3a4050    ld      a,(#5040)	; load A with IN1
328c  e610      and     #10		; is the service switch off?
328e  28f6      jr      z,#3286         ; no, loop until test switch is off

;; 	check the condition to display the easter egg
;	This piece of code is found in the original Midway Pac-Man ROMs @ #3289.
;	Place the game in the test grid screen (Monitor Convergence screen) by switching test mode on.
;	Then, hold down the player 1 and player 2 buttons and then quickly jiggle the test switch out &
;	back into test. Next move the joystick:
;		Up 4 times 
;		Left 4 times 
;		Right 4 times 
;		Down 4 times
;;				- Widel/Mowerman

3290  3a4050    ld      a,(#5040)	; load A with IN1
3293  e660      and     #60		; apply bitmask 0110 0000.  are player 1 and 2 buttons being pressed ?
3295  c24b23    jp      nz,#234b	; no, jump to main program start

3298  0608      ld      b,#08		; For B = 1 to 8

329a  cded32    call    #32ed		; call the delay routine
329d  10fb      djnz    #329a           ; Next B

329f  3a4050    ld      a,(#5040)	; load A with IN1
32a2  e610      and     #10		; is the service mode switch set ?
32a4  c24b23    jp      nz,#234b	; no, jump to main program start
32a7  1e01      ld      e,#01		; yes, load E with #01, used for checking direction below

32a9  0604      ld      b,#04		; for B = 1 to 4

32ab  32c050    ld      (#50c0),a	; kick the dog
32ae  cded32    call    #32ed		; call the delay routine
32b1  3a0050    ld      a,(#5000)	; load A with IN0 (joystick)
32b4  a3        and     e		; pushing on joystick in proper direction?
32b5  20f4      jr      nz,#32ab        ; no, jump back

32b7  cded32    call    #32ed		; yes, call the delay routine
32ba  32c050    ld      (#50c0),a	; kick the dog
32bd  3a0050    ld      a,(#5000)	; load A with IN0 (joystick)
32c0  eeff      xor     #ff		; joystick has no direction ?
32c2  20f3      jr      nz,#32b7        ; no, loop again
32c4  10e5      djnz    #32ab           ; Next B

32c6  cb03      rlc     e		; rotate left E with carry E becomes 2, 4, 8, and finally 16 (#10 hex)
32c8  7b        ld      a,e		; load into A
32c9  fe10      cp      #10		; result >= #10 ?
32cb  daa932    jp      c,#32a9		; no, loop and try again

	;; draw the "Made By Namco" easter egg
	; clear the screen...

32ce  210040    ld      hl,#4000	; load HL with start of video RAM
32d1  0604      ld      b,#04		; set counter to run 4 times
32d3  3e40      ld      a,#40		; A := #40 (clear character)

32d5  77        ld      (hl),a		; clear the video ram location
32d6  2c        inc     l		; next location
32d7  20fc      jr      nz,#32d5        ; loop until L is zero

32d9  24        inc     h		; next H
32da  10f7      djnz    #32d3           ; next B
32dc  cdf43a    call    #3af4		; draw the easter egg to the screen

	; wait for service switch to be off

32df  32c050    ld      (#50c0),a	; kick the dog
32e2  3a4050    ld      a,(#5040)	; load A with IN1
32e5  e610      and     #10		; is the service switch on?
32e7  cadf32    jp      z,#32df		; yes, loop
32ea  c34b23    jp      #234b		; no, jump to main program

	; delay timer

32ed  32c050    ld      (#50c0),a	; kick the dog
32f0  210028    ld      hl,#2800

32f3  2b        dec     hl
32f4  7c        ld      a,h
32f5  b5        or      l
32f6  20fb      jr      nz,#32f3        ; (-5)
32f8  c9        ret     

	; data - bonus table text
	; referred to at #320F

32f9  30 31				; "10" for 10,000 pts
32fb  35 31				; "15" for 15,000 pts
32fd  30 32				; "20" for 20,000 pts

	; data - tile differences tables for movements

32ff  00 ff				; move right
3301  01 00				; move down
3303  00 01				; move left
3305  ff 00				; move up

	; second copy for speed, or for overflow when blue ghosts random directions aren't allowed

3307  00 ff				; move right
3309  01 00				; move down
330b  00 01				; move left
330d  ff 00				; move up

	; data - table for difficulty
	; 	each entry has 3 sections
	;	0: 0x10 bytes - speed bit patterns
	;	1: 0x0c bytes - ghost data movement bit patterns
	;	2: 0x0e bytes - ghost counters for orientation changes
	;			4dc1-4dc3 related
	;
	; this table is referenced at #0733

330f  2A552A55 55555555 2A552A55 4A5294A5
      25252525 22222222 01010101
      0258 0708 0960 0E10 1068 1770 1914

3339  4A5294A5 2AAA5555 2A552A55 4A5294A5
      24924925 24489122 01010101
      0000 0000 0000 0000 0000 0000 0000

3363  2A552A55 55555555 2AAA5555 2A552A55
      4A5294A5 24489122 44210844
      0258 0834 09D8 0FB4 1158 1608 1734

; pac original continues on here:
        entry 3:
                55555555 6AD56AD5 6AAAD555 55555555
                2AAA5555 24922492 22222222
                01A4 0654 07F8 0CA8 0DD4 1284 13B0

        entry 4:
                6AD56AD5 5AD6B5AD 5AD6B5AD 6AD56AD5
                6AAAD555 24924925 24489122
                01A4 0654 07F8 0CA8 0DD4 FFFE FFFF

        entry 5:
                6D6D6D6D 6D6D6D6D 6DB6DB6D 6D6D6D6D
                5AD6B5AD 25252525 24922492
                012C 05DC 0708 0BB8 0CE4 FFFE FFFF

        entry 6:
                6AD56AD5 6AD56AD5 6DB6DB6D 6D6D6D6D
                5AD6B5AD 24489122 24922492
                012C 05DC 0708 0BB8 0CE4 FFFE FFFF

; end pac original

	;; speed control table

338d  55 55 55 55	;; #338d - 3390 = Pacman normal speed for Board 1 = this will increase exactly every other time

; 55555555 -> AAAAAAAA -> 55555555 = 1/2 = 50% speed = 1010101010101010101010101010101

3391  d5 6a d5 6a	;; #3391 - 3394 = Pacman Blue speed for Board 1 = 11010101011010101101010101101010 = 18/32 =  56.25%
3395  aa 6a 55 d5	;; #3395 - 3398 = 2nd alternate speed for red ghost = 10101010011010100101010111010101 = 17/32 = 53.125% 
3399  55 55 55 55	;; #3399 - 339c = 1st alt. speed for red ghost = 50% speed
339d  aa 2a 55 55	;; #339d - 33a0 = Ghost normal speed for board 1 = 10101010001010100101010101010101 = 15/32 = 46.875%
33a1  92 24 92 24	;; #33a1 - 33a4 = Ghost blue speed for board 1 = 10010010001001001001001000100100 = 10/32 = 31.25%
33a5  22 22 22 22	;; #33a5 - 33a8 = Ghost tunnel speed for board 1 = 1/4 OR 25% speed


; refer to code segment at #0E55
; timer is saved in memory #4DC2

33A9  a4 01		; timer for first reversal #01A4 (start at scatter, 7 seconds until first chase) [1 second = #3C (60 decimal) units]
33AB  54 06 f8 07	; 2nd & 3rd reversals at #0654 and #07F8 (20 seconds of chase, 7 seconds of scatter)
33AF  a8 0c d4 0d	; 4th & 5th reversals at #0CA8 and #0DD4 (20 seconds of chase, 5 seconds of scatter)
33B3  84 12 b0 13	; 6th & 7th reversals at #1284 and #13B0 (20 seconds of chase, 5 seconds of scatter)


; codes for boards 2-4

33b7  d5 6a d5 6a	; Pacman normal speed = 56.25%
33bb  d6 5a ad b5	; Pacman blue speed = 11010110010110101010110110110101 = 19/32 = 59.375%
33bf  d6 5a ad b5	; 2nd alt. speed for red ghost = 59.375%
33c3  d5 6a d5 6a 	; alt. speed for red ghost = 56.25%
33c7  aa 6a 55 d5	; Ghost reg speed = 17/32 = 53.125% 
33cb  92 24 25 49 	; Ghost blue speed = 10010010001001000010010101001001 = 11/32 = 34.375%
33CF  48 24 22 91 	; ghost tunnel speed = 1001000001001000010001010010001 = 9/32 = 28.125%

33D3:  A4 01 54 06	; 1st & 2nd reversal timers #01A4 and #0654 (7 second scatter, chase 20 seconds, then start of 2nd scatter)
33D7:  F8 07 A8 0C	; 3rd & 4th reversal timers #07F8 and #0CA8 (7 second scatter, chase 20 seconds, start of 3rd scatter)
33DB:  D4 0D FE FF	; 5th & 6th reversal timers #0DD4 and #FFFE (5 second scatter, chase 1033 seconds or 17.2 minutes to final reversal)
33DF:  FF FF		; last reversal timer #FFFF

; codes for boards 5 through - 9th key

33E1:  6D 6D 6D 6D	; pacman normal speed

; 6D6D6D6D -> DADADADA ->  B5B5B5B5 -> 6B6B6B6B -> D6D6D6D6 -> ADADADAD -> 5B5B5B5B -> B6B6B6B6 -> 6D6D6D6D (0110 1101 = 5/8 SPEED OR 62.5%)


33E5:  6D 6D 6D 6D	; pacman blue speed (5/8 SPEED) = 0110 1101 = 62.5%
33E9:  B6 6D 6D DB	; 2nd alt. speed for red ghost = 10110110011011010110110111011011 = 21/32 = 65.625%
33ED:  6D 6D 6D 6D	; 1st alt. speed for red ghost (5/8 SPEED) = 62.5%
33F1:  D6 5A AD B5	; ghost normal speed = 19/32 = 59.375%
33F5:  25 25 25 25	; ghost blue speed = 0010 0101 = 3/8 SPEED OR 37.5%
33F9:  92 24 92 24 	; ghost tunnel speed = 1001001000100100 = 5/16 = 31.25%

3FFD:  2C 01 DC 05	; reversal timers #012C and #05DC (start at scatter, 5 seconds to first chase, 20 seconds of chase, start of 2nd scatter)
3401:  08 07 B8 0B 	; reversal timers #0708 and #0BB8 (2nd scatter for 5 seconds, 2nd chase  for 20 seconds, start of 3rd scatter)
3405:  E4 0C FE FF	; reversal timers #0CE4 and #FFFE (3rd scatter for 5 seconds, then chase 1037 seconds or 17.3 minutes to final reversal)
3409:  FF FF		; last reversal timer #FFFF

; codes for boards 9th key and beyond

340B:  D5 6A D5 6A	; pacman normal speed = 18/32 =  56.25%
340F:  D5 6A D5 6A	; pacman blue speed = 18/32 =  56.25% (not used, energizers have no effect here)
3413:  B6 6D 6D DB	; 2nd alt speed for red ghost = 21/32 = 65.625%
3417:  6D 6D 6D 6D	; 1st alt. speed for red ghost = 5/8 = 0110 1101 = 62.5%
341B:  D6 5A AD B5	; ghost normal speed = 19/32 = 59.375%
341F:  48 24 22 91 	; ghost blue speed = 9/32 = 28.125%  (not used, energizers have no effect here, would be very slow)
3423:  92 24 92 24 	; ghost tunnel speed = 5/16 = 31.25%

3427:  2C 01 DC 05 	; reversal timers #012C and #05DC
342B:  08 07 B8 0B	; reversal timers #0708 and #0BB8
342F:  E4 0C FE FF	; reversal timers #0CE4 and #FFFE
3433:  FF FF		; last reversal timer #FFFF




; resume in the middle of original pac, in entry 4. see above.

	; entry 4, 5, etc is here.

; orignal pac rom:
; data - level map information

3435:                40 FC D0-D2 D2 D2 D2 D2 D2 D2 D2
3440: D4 FC FC FC DA 02 DC FC-FC FC D0 D2 D2 D2 D2 D6
3450: D8 D2 D2 D2 D2 D4 FC DA-09 DC FC FC FC DA 02 DC
3460: FC FC FC DA 05 DE E4 05-DC FC DA 02 E6 E8 EA 02
3470: E6 EA 02 DC FC FC FC DA-02 DC FC FC FC DA 02 E6
3480: EA 02 E7 EB 02 E6 EA 02-DC FC DA 02 DE FC E4 02
3490: DE E4 02 DC FC FC FC DA-02 DC FC FC FC DA 02 DE
34A0: E4 05 DE E4 02 DC FC DA-02 DE FC E4 02 DE E4 02
34B0: DC FC FC FC DA 02 DC FC-FC FC DA 02 DE F2 E8 E8
34C0: EA 02 DE E4 02 DC FC DA-02 E7 E9 EB 02 E7 EB 02
34D0: E7 D2 D2 D2 EB 02 E7 D2-D2 D2 EB 02 E7 E9 E9 E9
34E0: EB 02 DE E4 02 DC FC DA-1B DE E4 02 DC FC DA 02
34F0: E6 E8 F8 02 F6 E8 E8 E8-E8 E8 E8 F8 02 F6 E8 E8
3500: E8 EA 02 E6 F8 02 F6 E8-E8 F4 E4 02 DC FC DA 02
3510: DE FC E4 02 F7 E9 E9 F5-F3 E9 E9 F9 02 F7 E9 E9
3520: E9 EB 02 DE E4 02 F7 E9-E9 F5 E4 02 DC FC DA 02
3530: DE FC E4 05 DE E4 0B DE-E4 05 DE E4 02 DC FC DA
3540: 02 DE FC E4 02 E6 EA 02-DE E4 02 EC D3 D3 D3 EE
3550: 02 E6 EA 02 DE E4 02 E6-EA 02 DE E4 02 DC FC DA
3560: 02 E7 E9 EB 02 DE E4 02-E7 EB 02 DC FC FC FC DA
3570: 02 DE E4 02 E7 EB 02 DE-E4 02 E7 EB 02 DC FC DA
3580: 06 DE E4 05 F0 FC FC FC-DA 02 DE E4 05 DE E4 05
3590: DC FC FA E8 E8 E8 EA 02-DE F2 E8 E8 EA 02 CE FC
35A0: FC FC DA 02 DE F2 E8 E8-EA 02 DE F2 E8 E8 EA 02
35B0: DC 00 00 00 00

; original pac rom:
; data - level pill information

35B5:                62 01 02-01 01 01 01 0C 01 01 04
35C0: 01 01 01 04 04 03 0C 03-03 03 04 04 03 0C 03 01
35D0: 01 01 03 04 04 03 0C 06-03 04 04 03 0C 06 03 04
35E0: 01 01 01 01 01 01 01 01-01 01 01 01 01 01 01 01
35F0: 01 01 01 01 01 01 01 01-01 03 04 04 0F 03 06 04
3600: 04 0F 03 06 04 04 01 01-01 0C 03 01 01 01 03 04
3610: 04 03 0C 03 03 03 04 04-03 0C 03 03 03 04 01 01
3620: 01 01 03 0C 01 01 01 03-01 01 01 08 18 08 18 04
3630: 01 01 01 01 03 0C 01 01-01 03 01 01 01 04 04 03
3640: 0C 03 03 03 04 04 03 0C-03 03 03 04 04 01 01 01
3650: 0C 03 01 01 01 03 04 04-0F 03 06 04 04 0F 03 06
3660: 04 01 01 01 01 01 01 01-01 01 01 01 01 01 01 01
3670: 01 01 01 01 01 01 01 01-01 01 03 04 04 03 0C 06
3680: 03 04 04 03 0C 06 03 04-04 03 0C 03 01 01 01 03
3690: 04 04 03 0C 03 03 03 04-01 02 01 01 01 01 0C 01
36A0: 01 04 01 01 01
; end pac-man only


;  the following resumes Ms Pac
;  the whole section from 0x3435-0x36a2 differs from Pac roms.


; arrive here from #2108 when 1st intermission begins

3435  3a004f    ld      a,(#4f00)	; load A with intermission indicator
3438  fe01      cp      #01		; is the intermission already running ?
343a  ca9c34    jp      z,#349c		; yes, skip ahead

343d  ef        rst     #28		; no, insert task to draw text "THEY MEET"
343e  1c 32				; 1c = draw text,  32 = string code
3440  3e01      ld      a,#01		; load A with code for "1"
3442  32ac42    ld      (#42ac),a	; write text "1" to screen
3445  3e16      ld      a,#16		; load A with code for color = white
3447  32ac46    ld      (#46ac),a	; paint the "1" white
344a  0e00      ld      c,#00		; C := #00
344c  c39c34    jp      #349c		; jump ahead

; arrive here from #21A1 when 2nd intermission begins

344f  3a004f    ld      a,(#4f00)	; load A with intermission indicator
3452  fe01      cp      #01		; is the intermission already running ?
3454  ca9c34    jp      z,#349c		; yes, skip ahead

3457  ef        rst     #28		; no, insert task to display text "THE CHASE"
3458  1c 17				; 1c = draw text,  17 = string code
345a  3e02      ld      a,#02		; load A with code for "2"
345c  32ac42    ld      (#42ac),a	; write text "2" to screen
345f  3e16      ld      a,#16		; load A with code for color = white
3461  32ac46    ld      (#46ac),a	; paint the "2" white
3464  0e0c      ld      c,#0c		; C := #0C.  This offset is added later to set up act 2
3466  c39c34    jp      #349c		; jump ahead

; arrive here from #229A when 3rd intermission begins

3469  3a004f    ld      a,(#4f00)	; load A with intermission indicator
346c  fe01      cp      #01		; is the intermission already running ?
346e  ca9c34    jp      z,#349c		; yes, skip ahead

3471  ef        rst     #28		; insert task to display text "JUNIOR"
3472  1c 15				; 1c = draw text,  15 = string code
	; print "ACT **3**"
3474  3e03      ld      a,#03		; load A with code for "3"
3476  32ac42    ld      (#42ac),a	; write text "3" to screen
3479  3e16      ld      a,#16		; load A with code for color = white
347b  32ac46    ld      (#46ac),a	; paint the "3" white
347e  0e18      ld      c,#18		; C := #18.  this offset is added later to set up act 3
3480  c39c34    jp      #349c		; jump ahead

; arrive here from #3E67 after Blinky has been introduced

3483  0e24      ld      c,#24		; load C with offset for moving Blinky
3485  c39c34    jp      #349c		; begin moving Blinky across marquee and up left side

; arrive here from #3E67 after Pinky has been introduced

3488  0e30      ld      c,#30		; load C with offset for moving Pinky
348a  c39c34    jp      #349c		; begin moving Pinky across marquee and up left side

; arrive here from #3E67 after Inky has been introduced

348d  0e3c      ld      c,#3c		; load C with offset for moving Inky
348f  c39c34    jp      #349c		; begin moving Inky across marquee and up left side

; arrive here from #3E67 after Sue has been introduced

3492  0e48      ld      c,#48		; load C with offset for moving Sue
3494  c39c34    jp      #349c		; begin moving Sue across marquee and up left side

; arrive here from #3e67 after Ms. Pac Man has been introduced

3497  0e54      ld      c,#54		; load C with offset for moving MS pac man
3499  c39c34    jp      #349c		; begin moving ms pac man across marquee



; main routine to handle intermissions and attract mode ANIMATIONS


349c  3a004f    ld      a,(#4f00)	; load A with intermission indicator
349f  a7        and     a		; is the intermission running ?
34a0  cc1136    call    z,#3611		; no, call this sub to get it started

34a3  0606      ld      b,#06		; B := #06
34a5  dd210c4f  ld      ix,#4f0c	; load IX with stack.  This holds the list of addresses for the data

; get the next ANIMATION code.. (codes return to here when done)
34a9  dd6e00    ld      l,(ix+#00)
34ac  dd6601    ld      h,(ix+#01)	; load HL with stack data.  this is an address for data
34af  7e        ld      a,(hl)		; load data
34b0  fef0      cp      #f0		; == #F0 ?
34b2  cade34    jp      z,#34de		; handle code #F0 - LOOP
34b5  fef1      cp      #f1
34b7  ca6b35    jp      z,#356b		; handle code #F1 - SETPOS
34ba  fef2      cp      #f2
34bc  ca9735    jp      z,#3597		; handle code #F2 - SETN
34bf  fef3      cp      #f3
34c1  ca7735    jp      z,#3577		; handle code #F3 - SETCHAR
34c4  fef5      cp      #f5
34c6  ca0736    jp      z,#3607		; handle code #F5 - PLAYSOUND
34c9  fef6      cp      #f6
34cb  caa435    jp      z,#35a4		; handle code #F6 - PAUSE
34ce  fef7      cp      #f7
34d0  caf335    jp      z,#35f3		; handle code #F7 - SHOWACT ?
34d3  fef8      cp      #f8
34d5  cafd35    jp      z,#35fd		; handle code #F8 - CLEARACT ?
34d8  feff      cp      #ff
34da  cacb35    jp      z,#35cb		; handle code #FF - END

34dd  76        halt			; wait for interrupt

; for value == #F0 - LOOP
    
34de  e5        push    hl
34df  3e01      ld      a,#01
34e1  d7        rst     #10
34e2  4f        ld      c,a
34e3  212e4f    ld      hl,#4f2e
34e6  df        rst     #18
34e7  79        ld      a,c
34e8  84        add     a,h
34e9  cd5635    call    #3556
34ec  12        ld      (de),a
34ed  cd4136    call    #3641
34f0  df        rst     #18
34f1  7c        ld      a,h
34f2  81        add     a,c
34f3  12        ld      (de),a
34f4  e1        pop     hl
34f5  e5        push    hl
34f6  3e02      ld      a,#02
34f8  d7        rst     #10
34f9  4f        ld      c,a
34fa  212e4f    ld      hl,#4f2e
34fd  df        rst     #18
34fe  79        ld      a,c
34ff  85        add     a,l
3500  cd5635    call    #3556
3503  1b        dec     de
3504  12        ld      (de),a
3505  cd4136    call    #3641
3508  df        rst     #18
3509  7d        ld      a,l
350a  81        add     a,c
350b  1b        dec     de
350c  12        ld      (de),a
350d  210f4f    ld      hl,#4f0f
3510  78        ld      a,b
3511  d7        rst     #10
3512  e5        push    hl
3513  3c        inc     a
3514  4f        ld      c,a

3515  213e4f    ld      hl,#4f3e
3518  df        rst     #18		; load HL with address (EG 8663)
3519  79        ld      a,c		; Copy C to A
351a  cb2f      sra     a		; Shift right (div by 2)
351c  d7        rst     #10		; dereference sprite number for intro.  loads A with value in HL+A
351d  feff      cp      #ff		; are we done ?
351f  c22635    jp      nz,#3526	; no, skip ahead

3522  0e00      ld      c,#00		; else reset counter
3524  18ef      jr      #3515           ; loop again

3526  e1        pop     hl
3527  71        ld      (hl),c
3528  5f        ld      e,a
3529  e1        pop     hl
352a  3e03      ld      a,#03
352c  d7        rst     #10
352d  57        ld      d,a
352e  d5        push    de
352f  214e4f    ld      hl,#4f4e
3532  df        rst     #18
3533  e1        pop     hl
3534  eb        ex      de,hl
3535  72        ld      (hl),d
3536  2b        dec     hl
3537  3a094e    ld      a,(#4e09)
353a  4f        ld      c,a
353b  3a724e    ld      a,(#4e72)
353e  a1        and     c
353f  2804      jr      z,#3545         ; (4)

3541  3ec0      ld      a,#c0
3543  ab        xor     e
3544  5f        ld      e,a

3545  73        ld      (hl),e
3546  21174f    ld      hl,#4f17
3549  78        ld      a,b
354a  d7        rst     #10
354b  3d        dec     a
354c  77        ld      (hl),a
354d  110000    ld      de,#0000
3550  2062      jr      nz,#35b4        ; (98)

3552  1e04      ld      e,#04
3554  185e      jr      #35b4           ; (94)

3556  4f        ld      c,a
3557  cb29      sra     c
3559  cb29      sra     c
355b  cb29      sra     c
355d  cb29      sra     c
355f  a7        and     a
3560  f26835    jp      p,#3568

; arrive here when ghost is moving up the left side of the marquee

3563  f6f0      or      #f0
3565  0c        inc     c
3566  1802      jr      #356a           ; (2)

3568  e60f      and     #0f
356a  c9        ret     

; for value == #F1 - SETPOS

356b  eb        ex      de,hl
356c  cd4136    call    #3641		; load HL with either #4CFE or #4Dc6
356f  eb        ex      de,hl
3570  d5        push    de
3571  23        inc     hl
3572  56        ld      d,(hl)
3573  23        inc     hl
3574  5e        ld      e,(hl)
3575  1813      jr      #358a           ; (19)

; for value == #F3 - SETCHAR

3577  eb        ex      de,hl		; save HL into DE
3578  210f4f    ld      hl,#4f0f	; HL := #4F0F (stack)
357b  78        ld      a,b		; A := B
357c  d7        rst     #10		; load A with the data in HL+A
357d  3600      ld      (hl),#00	; clear this location
357f  eb        ex      de,hl		; restore HL from DE
3580  113e4f    ld      de,#4f3e	; DE := #4F3E (stack)
3583  d5        push    de		; save DE
3584  23        inc     hl		; next location
3585  5e        ld      e,(hl)
3586  23        inc     hl
3587  56        ld      d,(hl)		; DE how has the address word after the code #F3
3588  1800      jr      #358a		; does nothing (?) -- jumps to next instruction

	; It's my gyess that the jr at 3588 and the lack of code #F4 
	; are related.  In fitting with the style of the other F-commands,
	; they all end with a jr to 0x358a, including this one. 
	; I think that in the source code, they removed whatever #F4 
	; was, but forgot to erase the jr just before it, so you end up with
	; a jr to the next instruction.  -scott

; cleanup for return from #F0, #F1, #F3
358a  e1        pop     hl		; restore DE saved earlier into HL
358b  d5        push    de		; save the address
358c  df        rst     #18		; load HL with the data in (HL + 2*B)
358d  eb        ex      de,hl		; DE <-> HL
358e  d1        pop     de		; restore the address
358f  72        ld      (hl),d
3590  2b        dec     hl
3591  73        ld      (hl),e
3592  110300    ld      de,#0003	; 3 bytes used from the code program
3595  181d      jr      #35b4           ; (29)

; for value = #F2 - SETN

3597  23        inc     hl
3598  4e        ld      c,(hl)
3599  21174f    ld      hl,#4f17
359c  78        ld      a,b
359d  d7        rst     #10
359e  71        ld      (hl),c
359f  110200    ld      de,#0002	; 
35a2  1810      jr      #35b4           ; (16)

; for value == #F6 - PAUSE

35a4  21174f    ld      hl,#4f17
35a7  78        ld      a,b
35a8  d7        rst     #10

35a9  3d        dec     a
35aa  77        ld      (hl),a
35ab  110000    ld      de,#0000
35ae  2004      jr      nz,#35b4        ; (4)
35b0  1e01      ld      e,#01		; 1 byte used from the code program
35b2  1800      jr      #35b4           ; (0)

; finish up for the above

35b4  dd6e00    ld      l,(ix+#00)
35b7  dd6601    ld      h,(ix+#01)	; load HL with next value
35ba  19        add     hl,de		; add offset
35bb  dd7500    ld      (ix+#00),l
35be  dd7401    ld      (ix+#01),h
35c1  dd2b      dec     ix
35c3  dd2b      dec     ix
35c5  1001      djnz    #35c8           ; (1)
35c7  c9        ret     

35c8  c3a934    jp      #34a9

; for value == #FF (end code)

35cb  211f4f    ld      hl,#4f1f
35ce  78        ld      a,b
35cf  d7        rst     #10
35d0  3601      ld      (hl),#01
35d2  21204f    ld      hl,#4f20
35d5  7e        ld      a,(hl)
35d6  23        inc     hl
35d7  a6        and     (hl)
35d8  23        inc     hl
35d9  a6        and     (hl)
35da  23        inc     hl
35db  a6        and     (hl)
35dc  23        inc     hl
35dd  a6        and     (hl)
35de  23        inc     hl
35df  a6        and     (hl)
35e0  110000    ld      de,#0000
35e3  28cf      jr      z,#35b4         ; (-49)

35e5  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
35e8  a7        and     a		; == #00 ?
35e9  ca9521    jp      z,#2195		; yes, jump back to program

35ec  af        xor     a		; else A := #00
35ed  32004f    ld      (#4f00),a	; clear the intermission indicator
35f0  c38e05    jp      #058e		; jump back to program

; for value == #F7 - SHOWACT ?

35f3  78        ld      a,b
35f4  ef        rst     #28		; insert task to display text "        "
35f5  1c 30
35f6  47        ld      b,a
35f8  110100    ld      de,#0001
35fb  18b7      jr      #35b4           ; (-73)

; for value == #F8 - CLEARACT

35fd  3e40      ld      a,#40
35ff  32ac42    ld      (#42ac),a	; blank out the character where the 'ACT' # was displayed
3602  110100    ld      de,#0001
3605  18ad      jr      #35b4           ; (-83)

; for value == #F5 - PLAYSOUND

3607  23        inc     hl
3608  7e        ld      a,(hl)
3609  32 BC 4E  ld   	(#4EBC),a	; set sound channel #3.  used when ghosts bump during 1st intermission
360c  11 02 00	ld      de,#0002
360f  18 a3	jr      #35b4           ; (-93)

; arrive here at intermissions and attract mode
; called from above, with C preloaded with an offset depending on which intermission / attract mode we are in

3611  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
3614  a7        and     a		; check for zero.  is a game being played?
3615  2008      jr      nz,#361f        ; no, skip next 3 steps.  no sounds during attract mode

3617  3e02      ld      a,#02		; else A := #02
3619  32cc4e    ld      (#4ecc),a	; store in wave to play
361c  32dc4e    ld      (#4edc),a	; store in wave to play

; this is used to generate the animations with the animation programs stored in the tables
361f  21f081    ld      hl,#81f0	; load HL with start of table data
3622  0600      ld      b,#00		; B:=#00
3624  09        add     hl,bc		; add BC to HL to offset the start of the data
3625  11024f    ld      de,#4f02	; load Destination with #4F02
3628  010c00    ld      bc,#000c	; load byte counter with #0C
362b  edb0      ldir  			; copy data from table into memory
362d  3e01      ld      a,#01		; A := #01
362f  32004f    ld      (#4f00),a	; set intermission indicator
3632  32a44d    ld      (#4da4),a	; set # of ghost killed but no collision for yet to 1
3635  211f4f    ld      hl,#4f1f	; load HL with stack pointer (?)
3638  3e00      ld      a,#00		; A := #00
363a  32a54d    ld      (#4da5),a	; set pacman dead animation state to not dead
363d  0614      ld      b,#14		; B := #14
363f  cf        rst     #8		; 
3640  c9        ret 			; return    

3641  78        ld      a,b
3642  fe06      cp      #06
3644  2004      jr      nz,#364a        ; (4)
3646  21c64d    ld      hl,#4dc6
3649  c9        ret     

364a  21fe4c    ld      hl,#4cfe
364d  c9        ret     

        ; select song
	; arrive here from #2D62

364E: 05	dec	b		; B = current bit of song being played (from loop in #2d50)
					; adapt B to the current level to find out the song number
364F: C5	push	bc		; save BC	
3650: 78	ld	a,b		; load A with B
3651: FE 01	cp	#01		; == #01 ?
3653: 28 04	jr	z,#3659		; yes, skip next 2 steps
3655: 06 00	ld	b,#00		; else B := #00
3657: 18 11	jr	#366A		; jump ahead

3659: 3A 13 4E	ld	a,(#4E13)	; load A with current game level
365C: 06 01	ld	b,#01		; B := #01 (song #1 for 1st intermission)
365E: FE 01	cp	#01		; game level == #01 (level 2) ?
3660: 28 08	jr	z,#366A		; yes, jump ahead
3662: 06 02	ld	b,#02		; B := #02 (song #2 for 2nd intermission)
3664: FE 04	cp	#04		; game level == #04 (level 5) ?
3666: 28 02	jr	z,#366A		; yes, jump ahead
3668: 06 03	ld	b,#03		; else B := #03 (song #3 for 3rd intermission)

366A: DF	rst	#18		; HL = (HL+2B)  [read from table in HL, i.e. SONG_TABLE_x]
366B: C1	pop	bc		; restore BC
366C: C3 72 2D	jp	#2D72		; jump back to main program to "process byte" routine

; arrive here from #2060 
; A is loaded with the color of the tile the ghost is on

366f  cb77      bit     6,a		; test bit 6 of the tile.  is this a slow down zone (tunnel) ?
3671  ca6620    jp      z,#2066		; no, jump back and set the var to zero
3674  3e01      ld      a,#01		; yes, A := #01
3676  02        ld      (bc),a		; store into ghost tunnel slowdown flag
3677  c9        ret     		; return

; arrive here from #100B, continuation of task #05

3678  210000    ld      hl,#0000	; clear HL
367b  22d24d    ld      (#4dd2),hl	; clears the fruit score sprite 
367e  c9        ret    			; return

; can't find a call to here ???

367f  3a084d    ld      a,(#4d08)	; load A with pacman position
3682  e60f      and     #0f		; mask bits
3684  cb3f      srl     a
3686  cb3f      srl     a		; shift right twice
3688  2f        cpl     		; invert
3689  1e1c      ld      e,#1c		; E := #1C
368b  83        add     a,e		; add
368c  fe18      cp      #18		; == #18 ?
368e  2002      jr      nz,#3692        ; no, skip next step

3690  3e36      ld      a,#36		; yes, A := #36
3692  320a4c    ld      (#4c0a),a	; store result into mspac sprite number
3695  c9        ret     		; return


		;; garbage, leftover from patching pac-man rom.
		;; this is the tail end of the pellet table. heh.

3696  03 04 01 02 01 01 01 01 0c 01
36A0  01 04 01 01 01   

        ;; Indirect Lookup table for #2C5E routine  (0x48 entries)
        ;; patched from Pac-Man.  Pac-man items are indented

36a5  1337	; #3713	; 00        HIGH SCORE
36a7  2337	; #3723	; 01        CREDIT   
36a9  3237	; #3732	; 02        FREE PLAY
36ab  4137	; #3741	; 03        PLAYER ONE
36ad  5a37	; #375A	; 04        PLAYER TWO
36af  6a37	; #376A	; 05        GAME  OVER
36b1  7a37	; #377A	; 06        READY!
36b3  8637	; #3786	; 07        PUSH START BUTTON
36b5  9d37	; #379D	; 08        1 PLAYER ONLY 
36b7  b137	; #37B1	; 09        1 OR 2 PLAYERS
36b9  213d	; #3D21	; 0a        "     "
	003d	;			BONUS PAC-MAN FOR  00PTS
36bb  003d	; #3D00	; 0b        ADDITIONAL    AT   000
	213d				@ 1980 Midway Mfg Co
36bd  fd37	; #37FD	; 0c        "MS PAC-MAN"
	    				CHARACTER / NICKNAME
36bf  673d	; #3D67	; 0d        BLINKY
36c1  e33d	; #3DE3	; 0e        WITH
					BBBBBBBB
36c3  863d	; #3d86	; 0f        PINKY  
36c5  023e	; #3E02	; 10        STARRING
					DDDDDDDD
36c7  4c38	; #384C	; 11        . 10 Pts (pac-man only)
36c9  5a38	; #385A	; 12        o 50 Pts (pac-man only)
36cb  3c3d	; #3D3C	; 13        (C) MIDWAY MFG CO
36cd  573d	; #3D57	; 14        MAD DOG
					-SHADOW
36cf  d33d	; #3DD3	; 15        JUNIOR
					AAAAAAAA
36d1  763d	; #3D76	; 16        KILLER
					-SPEEDY
36d3  f23d	; #3DF2	; 17        THE CHASE
					CCCCCCCC
36d5  0100	; #0001	; 18 	    - unused -
36d7  0200	; #0002	; 19	    - unused -
36d9  0300	; #0003	; 1a	    - unused -

36db  bc38	; #38BC	; 1b        100
36dd  c438	; #38C4	; 1c        SUPER PAC-MAN
					300
36df  ce38	; #38CE	; 1d        MAN
					500
36e1  d838	; #38D8	; 1e        AN
					700
36e3  e238	; #38E2	; 1f        - ? -
					1000
36e5  ec38	; #3820	; 20        - ? -
					2000
36e7  f638	; #38F6	; 21        - ? -
					3000
36e9  0039	; #3900	; 22        - ? -
					5000
36eb  0a39	; #390A	; 23        MEMORY  OK
36ed  1a39	; #391A	; 24        BAD    R M
36ef  6f39	; #396F	; 25        FREE  PLAY       
36f1  2a39	; #392A	; 26        1 COIN  1 CREDIT 
36f3  5839	; #3958	; 27        1 COIN  2 CREDITS
36f5  4139	; #3941	; 28        2 COINS 1 CREDIT 
36f7  113e	; #3E11	; 29        MS. PAC-MEN	(service mode screen)
	4f3e				PAC-MAN
36f8  8639	; #3986	; 2a        BONUS  NONE
36fb  9739	; #3997	; 2b        BONUS
36fd  b039	; #39B0	; 2c        TABLE  
36ff  bd39	; #39BD	; 2d        UPRIGHT
3701  ca39	; #39CA	; 2e        000		for test screen
3703  a53d	; #3DA5	; 2f        INKY    
3705  213e	; #3E21	; 30        "        "
					FFFFFFFF
3707  c63d	; #3DC6	; 31        SUE 
					CLYDE
3709  403e	; #3E40	; 32        THEY MEET
					HHHHHHHH
370b  953d	; #3D95	; 33        MS. PAC-MAN  (For "Starring" bit)
					BASHFUL
370d  113e	; #3E11	; 34        MS. PAC-MEN	 (service mode screen)
					EEEEEEEE
370f  b43d	; #3DB4	; 35        1980,1981
					POKEY
3711  303e	; #3E30	; 36        ACT III
					GGGGGGGG

	;; there's another one of these for the text over at 3D00

	;; text string table 1
;offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f    0123456789abcdef
00003710           d4 83 48 49 47  48 40 53 43 4f 52 45 2f  |   ..HIGH@SCORE/|
00003720  8f 2f 80 3b 80 43 52 45  44 49 54 40 40 40 2f 8f  |./.;.CREDIT@@@/.|
00003730  2f 80 3b 80 46 52 45 45  40 50 4c 41 59 2f 8f 2f  |/.;.FREE@PLAY/./|
00003740  80 8c 02 50 4c 41 59 45  52 40 4f 4e 45 2f 85 2f  |...PLAYER@ONE/./|
00003750  10 10 1a 1a 1a 1a 1a 1a  10 10 8c 02 50 4c 41 59  |............PLAY|
00003760  45 52 40 54 57 4f 2f 85  2f 80 92 02 47 41 4d 45  |ER@TWO/./...GAME|
00003770  40 40 4f 56 45 52 2f 81  2f 80 52 02 52 45 41 44  |@@OVER/./.R.READ|
00003780  59 5b 2f 89 2f 90 ed 02  50 55 53 48 40 53 54 41  |Y[/./...PUSH@STA|
00003790  52 54 40 42 55 54 54 4f  4e 2f 87 2f 80 af 02 31  |RT@BUTTON/./...1|
000037a0  40 50 4c 41 59 45 52 40  4f 4e 4c 59 40 2f 87 2f  |@PLAYER@ONLY@/./|
000037b0  80 af 02 31 40 4f 52 40  32 40 50 4c 41 59 45 52  |...1@OR@2@PLAYER|
000037c0  53 2f 87 00 2f 00 80 00  96 03 42 4f 4e 55 53 40  |S/../.....BONUS@|
000037d0  50 55 43 4b 4d 41 4e 40  46 4f 52 40 40 40 30 30  |PUCKMAN@FOR@@@00|
000037e0  30 40 5d 5e 5f 2f 8e 2f  80 ba 02 5c 40 28 29 2a  |0@]^_/./...\@()*|
000037f0  2b 2c 2d 2e 40 31 39 38  30 2f 83 2f 80 65 03 40  |+,-.@1980/./.e.@|

 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f    0123456789abcdef
00003800  40 40 40 40 40 40 40 26  4d 53 40 50 41 43 3b 4d  |@@@@@@@&MS@PAC;M|
00003810  41 4e 27 40 2f 87 2f 80  01 26 41 4b 41 42 45 49  |AN'@/./..&AKABEI|
00003820  26 2f 81 2f 80 45 01 26  4d 41 43 4b 59 26 2f 81  |&/./.E.&MACKY&/.|
00003830  2f 80 48 01 26 50 49 4e  4b 59 26 2f 83 2f 80 48  |/.H.&PINKY&/./.H|
00003840  01 26 4d 49 43 4b 59 26  2f 83 2f 80 76 02 10 40  |.&MICKY&/./.v..@|
00003850  31 30 40 5d 5e 5f 2f 9f  2f 80 78 02 14 40 35 30  |10@]^_/./.x..@50|
00003860  40 5d 5e 5f 2f 9f 2f 80  5d 02 28 29 2a 2b 2c 2d  |@]^_/./.].()*+,-|
00003870  2e 2f 83 2f 80 c5 02 40  4f 49 4b 41 4b 45 3b 3b  |././...@OIKAKE;;|
00003880  3b 3b 2f 81 2f 80 c5 02  40 55 52 43 48 49 4e 3b  |;;/./...@URCHIN;|
00003890  3b 3b 3b 3b 2f 81 2f 80  c8 02 40 4d 41 43 48 49  |;;;;/./...@MACHI|
000038a0  42 55 53 45 3b 3b 2f 83  2f 80 c8 02 40 52 4f 4d  |BUSE;;/./...@ROM|
000038b0  50 3b 3b 3b 3b 3b 3b 3b  2f 83 2f 80 25 80 81 85  |P;;;;;;;/./.%...|
000038c0  2f 81 2f 90 6e 02 53 55  50 45 52 40 50 41 43 3b  |/./.n.SUPER@PAC;|
	;; Note "SUPER PAC-MAN" in the text above.  This was a stepping stone
	;; between Crazy Otto and Ms. Pac-Man.
000038d0  4d 41 4e 2f 89 2f 80 4d  41 4e 2f 89 2f 80 2f 90  |MAN/./.MAN/././.|
000038e0  00 00 2e 80 86 8b 8d 8e  2f 8f 2f 90[30 80 40 40  |.......././.0.@@|
000038f0  40 40 2f 94 2f 90 32 80  89 8a 8d 8e 2f 89 2f 90  |@@/./.2....././.|

 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f    0123456789abcdef
00003900  34 80 89 8a 8d 8e 2f 89  2f 90 04 03 4d 45 4d 4f  |4....././...MEMO|
00003910  52 59 40 40 4f 4b 2f 8f  2f 80 04 03 42 41 44 40  |RY@@OK/./...BAD@|
00003920  40 40 40 52 40 4d 2f 8f  2f 80 08 03 31 40 43 4f  |@@@R@M/./...1@CO|
00003930  49 4e 40 40 31 40 43 52  45 44 49 54 40 2f 8f 2f  |IN@@1@CREDIT@/./|
00003940  80 08 03 32 40 43 4f 49  4e 53 40 31 40 43 52 45  |...2@COINS@1@CRE|
00003950  44 49 54 40 2f 8f 2f 80  08 03 31 40 43 4f 49 4e  |DIT@/./...1@COIN|
00003960  40 40 32 40 43 52 45 44  49 54 53 2f 8f 2f 80 08  |@@2@CREDITS/./..|
00003970  03 46 52 45 45 40 40 50  4c 41 59 40 40 40 40 40  |.FREE@@PLAY@@@@@|
00003980  40 40 2f 8f 2f 80 0a 03  42 4f 4e 55 53 40 40 4e  |@@/./...BONUS@@N|
00003990  4f 4e 45 2f 8f 2f 80 0a  03 42 4f 4e 55 53 40 2f  |ONE/./...BONUS@/|
000039a0  8f 2f 80 0c 03 50 55 43  4b 4d 41 4e 2f 8f 2f 80  |./...PUCKMAN/./.|
000039b0  0e 03 54 41 42 4c 45 40  40 2f 8f 2f 80 0e 03 55  |..TABLE@@/./...U|
000039c0  50 52 49 47 48 54 2f 8f  2f 80 0a 02 30 30 30 2f  |PRIGHT/./...000/|
000039d0  8f 2f 80 6b 01 26 41 4f  53 55 4b 45 26 2f 85 2f  |./.k.&AOSUKE&/./|
000039e0  3d 4f 21 00 4d d7 eb 79  21 f2 39 d7 12 23 13 7e  |=O!.M..y!.9..#.~|
000039f0  12 c9 2a da 42 da 5a da  72 da ef 05 01 ef 10 14  |..*.B.Z.r.......|

 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f    0123456789abcdef
00003a00  3e 01 32 14 4e c9 87 2f  80 cb 02 40 4b 49 4d 41  |>.2.N../...@KIMA|
00003a10  47 55 52 45 3b 3b 2f 85  2f 80 cb 02 40 53 54 59  |GURE;;/./...@STY|
00003a20  4c 49 53 54 3b 3b 3b 3b  2f 85 2f 80 ce 02 40 4f  |LIST;;;;/./...@O|
00003a30  54 4f 42 4f 4b 45 3b 3b  3b 2f 87 2f 80 ce 02 40  |TOBOKE;;;/./...@|
00003a40  43 52 59 42 41 42 59 3b  3b 3b 3b 2f 87 2f 80     |CRYBABY;;;;/./. |

; and here it is in a more readable format

3713      0x83d4, "HIGH@SCORE", 		0x2f, 0x8f, 0x2f, 0x80, 
3723      0x803b, "CREDIT@@@", 			0x2f, 0x8f, 0x2f, 0x80, 
3732      0x803b, "FREE@PLAY", 			0x2f, 0x8f, 0x2f, 0x80, 
3741      0x028c, "PLAYER@ONE", 		0x2f, 0x85, 0x2f, 0x10, 
375a      0x028c, "PLAYER@TWO", 		0x2f, 0x85, 0x2f, 0x80, 
376a      0x0292, "GAME@@OVER", 		0x2f, 0x81, 0x2f, 0x80, 
377a      0x0252, "READY[", 			0x2f, 0x89, 0x2f, 0x90, 
3786      0x02ed, "PUSH@START@BUTTON", 		0x2f, 0x87, 0x2f, 0x80, 
379d      0x02af, "1@PLAYER@ONLY@", 		0x2f, 0x87, 0x2f, 0x80, 
37c8      0x0396, "BONUS@PUCKMAN@FOR@@@000@]^_", 0x2f, 0x8e, 0x2f, 0x80, 
37e9      0x02ba, "\@()*+,-.@1980", 		0x2f, 0x83, 0x2f, 0x80, 
37fd      0x0365, "@@@@@@@@&MS@PAC;MAN'@", 	0x2f, 0x87, 0x2f, 0x80, 
37fd  P   0x02c3, "CHARACTER@:@NICKNAME", 	0x2f, 0x8f, 0x2f, 0x80, 
3817      0x0180, "&AKABEI&", 			0x2f, 0x81, 0x2f, 0x80, 
3825      0x0145, "&MACKY&", 			0x2f, 0x81, 0x2f, 0x80, 
3832      0x0148, "&PINKY&", 			0x2f, 0x83, 0x2f, 0x80, 
383f      0x0148, "&MICKY&", 			0x2f, 0x83, 0x2f, 0x80, 
384d      0x1002, "@10@]^_", 			0x2f, 0x9f, 0x2f, 0x80, 
385b      0x1402, "@50@]^_", 			0x2f, 0x9f, 0x2f, 0x80, 
3868      0x025d, "()*+,-.", 			0x2f, 0x83, 0x2f, 0x80, 
3875      0x02c5, "@OIKAKE;;;;", 		0x2f, 0x81, 0x2f, 0x80, 
3886      0x02c5, "@URCHIN;;;;;", 		0x2f, 0x81, 0x2f, 0x80, 
3898      0x02c8, "@MACHIBUSE;;", 		0x2f, 0x83, 0x2f, 0x80, 
38aa      0x02c8, "@ROMP;;;;;;;", 		0x2f, 0x83, 0x2f, 0x80, 
38be      0x8581, "", 				0x2f, 0x81, 0x2f, 0x90, 
38c4      0x026e, "SUPER@PAC;MAN", 		0x2f, 0x89, 0x2f, 0x80, 
38c7  P   0x8582, "@", 				0x2f, 0x83, 0x2f, 0x90, 
38d1  P   0x8583, "@", 				0x2f, 0x83, 0x2f, 0x90, 
38d5      0x802f, "MAN", 			0x2f, 0x89, 0x2f, 0x80, 
38db  P   0x8584, "@", 				0x2f, 0x83, 0x2f, 0x90, 
38e6      0x8e8d, "", 				0x2f, 0x8f, 0x2f, 0x90, 
38e6  P   0x8e8d, "", 				0x2f, 0x83, 0x2f, 0x90, 
38ec      0x8030, "@@@@", 			0x2f, 0x94, 0x2f, 0x90, 
38f0  P   0x8e8d, "", 				0x2f, 0x83, 0x2f, 0x90, 
38fa      0x8e8d, "", 				0x2f, 0x89, 0x2f, 0x90, 
3904      0x8e8d, "", 				0x2f, 0x89, 0x2f, 0x90, 
390a      0x0304, "MEMORY@@OK", 		0x2f, 0x8f, 0x2f, 0x80, 
391a      0x0304, "BAD@@@@R@M", 		0x2f, 0x8f, 0x2f, 0x80, 
392a      0x0308, "1@COIN@@1@CREDIT@",		0x2f, 0x8f, 0x2f, 0x80, 
3941      0x0308, "2@COINS@1@CREDIT@",	 	0x2f, 0x8f, 0x2f, 0x80, 
3958      0x0308, "1@COIN@@2@CREDITS", 		0x2f, 0x8f, 0x2f, 0x80, 
396f      0x0308, "FREE@@PLAY@@@@@@@", 		0x2f, 0x8f, 0x2f, 0x80, 
3986      0x030a, "BONUS@@NONE", 		0x2f, 0x8f, 0x2f, 0x80, 
3997      0x030a, "BONUS@", 			0x2f, 0x8f, 0x2f, 0x80, 
39a3      0x030c, "PUCKMAN", 			0x2f, 0x8f, 0x2f, 0x80, 
39b0      0x030e, "TABLE@@", 			0x2f, 0x8f, 0x2f, 0x80, 
39bd      0x030e, "UPRIGHT", 			0x2f, 0x8f, 0x2f, 0x80, 
39ca      0x020a, "000", 			0x2f, 0x8f, 0x2f, 0x80, 
39d3      0x016b, "&AOSUKE&", 			0x2f, 0x85, 0x2f, 0x3d, 
39e1  P   0x014b, "&MUCKY&", 			0x2f, 0x85, 0x2f, 0x80, 
39ee  P   0x016e, "&GUZUTA&", 			0x2f, 0x87, 0x2f, 0x80, 
39fc  P   0x014e, "&MOCKY&", 			0x2f, 0x87, 0x2f, 0x80, 
3a09      0x02cb, "@KIMAGURE;;", 		0x2f, 0x85, 0x2f, 0x80, 
3a1a      0x02cb, "@STYLIST;;;;", 		0x2f, 0x85, 0x2f, 0x80, 
3a2c      0x02ce, "@OTOBOKE;;;", 		0x2f, 0x87, 0x2f, 0x80, 
3a3d      0x02ce, "@CRYBABY;;;;", 		0x2f, 0x87, 0x2f, 0x80, 


	;; "Made By Namco" easter egg text

; This is stored the same way as the pellet information.
;  #3af4 routine:
;  1  retrieve the value
;  2  if (value == 0), done.
;  3  draw a pellet (#14)
;  4  increment the position by the value retrieved
;  5  repeat at 1 above

 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f

	; namco
00003a40                                                01
00003a50  01 03 01 01 01 03 02 02  02 01 01 01 01 02 04 04
00003a60  04 06 02 02 02 02 04 02  04 04 04 06 02 02 02 02
00003a70  01 01 01 01 02 04 04 04  06 02 02 02 02 06 04 05
00003a80  01 01 03 01 01 01 04 01  01 01 03 01 01 04 01 01
00003a90  01

	; by
00003a90     6c 05 01 01 01 18 04  04 18 05 01 01 01 17 02
00003aa0  03 04 16 04 03 01 01 01

	; made
00003aa0                           76 01 01 01 01 03 01 01
00003ab0  01 02 04 02 04 0e 02 04  02 04 02 04 0b 01 01 01
00003ac0  02 04 02 01 01 01 01 02  02 02 0e 02 04 02 04 02
00003ad0  01 02 01 0a 01 01 01 01  03 01 01 01 03 01 01 03
00003ae0  04 00                                             


	; data - 3 screen region grid data for self test
	; referenced at #3259

3AE2  02 40				; #4002
3AE4  01 3E				; #3E01
3AE6  3D 10				; #103D
3AE8  40 40				; #4040
3AEA  0E 3D				; #3D0E
3AEC  3E 10				; #103E
3AED  C2 43				; #43C2
3AF0  01 3E				; #3E01
3AF2  3D 10				; #103D


	; Draw the "Made By Namco" text (egg)

3af4  21a240    ld      hl,#40a2	; load HL with video ram start position
3af7  114f3a    ld      de,#3a4f	; load DE with pellet data start

3afa  3614      ld      (hl),#14	; set the screen to pellet (#14)
3afc  1a        ld      a,(de)		; load A with table data
3afd  a7        and     a		; are we done ?
3afe  c8        ret     z		; yes, return

3aff  13        inc     de		; else increase table pointer
3b00  85        add     a,l		; add the value to screen position
3b01  6f        ld      l,a		; store result.  is the carry flag set ?
3b02  d2fa3a    jp      nc,#3afa	; no, loop again
3b05  24        inc     h		; yes, increase H
3b06  18f2      jr      #3afa           ; and loop again


	; data - fruit table, referred in #2BF9
	; the first code is the 1st value of the graphic for the fruit
	; the second code is the color value for the fruit


3B08:  90 14				; cherry
3B0A:  94 0F				; strawberry
3B0C:  98 15				; peach
3B0E:  9C 07				; pretzel
3B10:  A0 14				; apple
3B12:  A4 17				; pear
3B14:  A8 16				; banana
3B16:  AC 16				; key (unused in ms. pac)
3B18:  00 00 00 00 00 00 00 00		; unused
3B20:  00 00 00 00 00 00 00 00		; unused
3B28:  00 00 9C 16 9C 16 9C 16		; unused, pretzels

	; pac-man data follows, fruit table

	;3B08:	90 14   			; cherry
	;3B0A:	94 0F   			; strawberry
	;3B0C:	98 15   			; 1st orange
	;3B0E:	98 15   			; 2nd orange
	;3B10:	A0 14   			; 1st apple
	;3B12:	A0 14   			; 2nd apple
	;3B14:  A4 17   			; 1st pineapple
	;3B16:	A4 17   			; 2nd pineapple
	;3B18:	A8 09   			; 1st galaxian / pretzel
	;3B1A:	A8 09   			; 2nd galaxian / pretzel
	;3B1C:	9C 16   			; 1st bell / banana
	;3B1E:	9C 16   			; 2nd bell / banana
	;3B20:	AC 16   			; 1st key
	;3B22:	AC 16   			; 2nd key
	;3B24:	AC 16   			; 3rd key
	;3B26:	AC 16   			; 4th key
	;3B28:	AC 16   			; 5th key
	;3B2A:	AC 16   			; 6th key
	;3B2C:	AC 16   			; 7th key
	;3B2E:	AC 16   			; 8th key

	; end pac-man data

	;;
	;; MSPACMAN sound tables
	;;

	;; 2 effects for channel 1

3b30  73 20 00 0c 00 0a 1f 00  		; extra life sound
3B38  72 20 fb 87 00 02 0f 00		; credit sound

	;; 8 effects for channel 2

3B40  59 01 06 08 00 00 02 00		; end of energizer
3B48  59 01 06 09 00 00 02 00		; higher frequency when 155 dots eaten
3B50  59 02 06 0a 00 00 02 00  		; higher frequency when 179 dots eaten
3B58  59 03 06 0b 00 00 02 00		; higher frequency when 12 dots left
3B60  59 04 06 0c 00 06 02 00  		; reset higher frequency when 12 or less dots left
3b68  24 00 06 08 02 00 0a 00		; engergizer eaten
3B70  36 07 87 6f 00 00 04 00		; eyes returning sound
3B78  70 04 00 00 00 00 08 00		; unused ???

	;; 6 effects for channel 3

3b80  1c 70 8b 08 00 01 06 00		; dot eating sound 1
3B88  1c 70 8b 08 00 01 06 00		; dot eating sound 2
3b90  56 0c ff 8c 00 02 08 00		; fruit eating sound
3B98  56 00 02 0a 07 03 0c 00		; blue ghost eaten sound
3bA0  36 38 fe 12 f8 04 0f fc 		; ghosts bumping during act 1 sound
3BA8  22 01 01 06 00 01 07 00		; fruit bouncing sound
        
        ;; lookup tables

3BB0  01 02 04 08 10 20 40 80

3BB8  00 57 5C 61 67 6D 74 7B  82 8A 92 9A A3 AD B8 C3
        
        ;; channel 1 : jump table to song data

3BC8  D4 3B				; #3BD4
3BCA  F3 3B				; #3BF3
        
        ;; channel 2 : jump table to song data

3BCC  58 3C 				; #3C58
3BCE  95 3C				; #3C95
        
        ;; channel 3 : jump table to song data

3BD0  DE 3C 				; #3CDE	; data is #00, no sounds on this channel
3BD2  DF 3C				; #3CDF	; data is #00, no sounds on this channel
        
        ;; song data 

; act 2 song

3BD4  F1 02 F2 03 F3 0F F4 01 82 70 69 82 70 69 83 70
3BE4  6A 83 70 6A 82 70 69 82 70 69 89 8B 8D 8E FF

; act 2 song

3BF3  F1 02 F2 03 F3 0F F4 01 67 50 30 47 30 67 50 30
3C03  47 30 67 50 30 47 30 4B 10 4C 10 4D 10 4E 10 67
3C13  50 30 47 30 67 50 30 47 30 67 50 30 47 30 4B 10
3C23  4C 10 4D 10 4E 10 67 50 30 47 30 67 50 30 47 30
3C33  67 50 30 47 30 4B 10 4C 10 4D 10 4E 10 77 20 4E
3C43  10 4D 10 4C 10 4A 10 47 10 46 10 65 30 66 30 67
3C53  40 70 F0 FB 3B

; act 2 song

3C58  F1 00 F2 02 F3 0F F4 00 42 50 4E 50 49 50 46 50
3C68  4E 49 70 66 70 43 50 4F 50 4A 50 47 50 4F 4A 70
3C78  67 70 42 50 4E 50 49 50 46 50 4E 49 70 66 70 45
3C88  46 47 50 47 48 49 50 49 4A 4B 50 6E FF

; act 2 song (2nd half)

3C95  F1 01 F2 01 F3 0F F4 00 26 67 26 67 26 67 23 44
3CA4  42 47 30 67 2A 8B 70 26 67 26 67 26 67 23 44 42
3CB4  47 30 67 23 84 70 26 67 26 67 26 67 23 44 42 47
3CC4  30 67 29 6A 2B 6C 30 2C 6D 40 2B 6C 29 6A 67 20
3CD4  29 6A 40 26 87 70 F0 9D 3C 00 

3CDE  00

3CDF  00

	;; text strings 2  (copyright, ghost names, intermission)

3D00:  96 03 40 41 44 44 49 54 49 4F 4E 41 4C 40 40 40  ..@ADDITIONAL@@@
3D10:  40 41 54 40 40 40 30 30 30 40 5D 5E 5F 2F 95 2F  @AT@@@000@]^_/./
3D20:  80 5A 02 40 40 40 40 40 40 40 2F 07 07 07 01 01  .Z.@@@@@@@/.....
3D30:  01 01 2F 80 50 40 40 40 2F 87 2F 80 5B 02 5C 40  ../.P@@@/./.[.\@
3D40:  4D 49 44 57 41 59 40 4D 46 47 40 43 4F 40 40 40  MIDWAY@MFG@CO@@@
3D50:  40 2F 81 2F 80 2F 80 C5 02 3B 4D 41 44 40 44 4F  @/././...;MAD@DO
3D60:  47 40 40 2F 81 2F 80 6E 02 40 40 40 42 4C 49 4E  G@@/./.n.@@@BLIN
3D70:  4B 59 2F 81 2F 80 C8 02 3B 4B 49 4C 4C 45 52 40  KY/./...;KILLER@
3D80:  40 40 2F 83 2F 80 6E 02 40 40 40 50 49 4E 4B 59  @@/./.n.@@@PINKY
3D90:  40 2F 83 2F 80 6E 02 4D 53 40 50 41 43 3B 4D 41  @/./.n.MS@PAC;MA
3DA0:  4E 2F 89 2F 80 6E 02 40 40 40 49 4E 4B 59 40 40  N/./.n.@@@INKY@@
3DB0:  2F 85 2F 80 3D 02 40 40 31 39 38 30 3A 31 39 38  /./.=.@@1980:198
3DC0:  31 40 2F 81 2F 80 6E 02 40 40 40 40 53 55 45 2F  1@/./.n.@@@@SUE/
3DD0:  87 2F 80 6B 02 4A 55 4E 49 4F 52 40 40 40 40 2F  ./.k.JUNIOR@@@@/
3DE0:  8F 2F 80 6B 02 57 49 54 48 40 40 40 40 40 2F 8F  ./.k.WITH@@@@@/.
3DF0:  2F 80 6B 02 54 48 45 40 43 48 41 53 45 40 2F 8F  /.k.THE@CHASE@/.
3E00:  2F 80 6B 02 53 54 41 52 52 49 4E 47 40 2F 8F 2F  /.k.STARRING@/./
3E10:  80 0C 03 4D 53 40 50 41 43 3B 4D 45 4E 2F 8F 2F  ...MS@PAC;MEN/./
3E20:  80 6B 02 40 40 40 40 40 40 40 40 40 2F 85 2F 80  .k.@@@@@@@@@/./.
3E30:  6B 02 41 43 54 40 49 49 49 26 40 40 2F 87 2F 80  k.ACT@III&@@/./.
3E40:  6B 02 54 48 45 59 40 4D 45 45 54 2F 8F 2F 80 0C  k.THEY@MEET/./..
3E50:  03 4F 54 54 4F 4D 45 4E 2F 8F 2F 80              .OTTOMEN/./.

3d00      0x0396, "@ADDITIONAL@@@@AT@@@000@]^_", 	0x2f, 0x95, 0x2f, 0x80, 
3d00  P   0x0396, "BONUS@PAC;MAN@FOR@@@000@]^_", 	0x2f, 0x8e, 0x2f, 0x80, 
3d21  P   0x033a, "\@1980@MIDWAY@MFG%CO%", 		0x2f, 0x83, 0x2f, 0x80, 
3d32      0x802f, "P@@@", 				0x2f, 0x87, 0x2f, 0x80, 
3d3c      0x025b, "\@MIDWAY@MFG@CO@@@@", 		0x2f, 0x81, 0x2f, 0x80, 
3d3c  P   0x033d, "\@1980@MIDWAY@MFG%CO%", 		0x2f, 0x83, 0x2f, 0x80, 

3d57      0x02c5, ";MAD@DOG@@", 	0x2f, 0x81, 0x2f, 0x80, 
3d57  P   0x02c5, ";SHADOW@@@", 	0x2f, 0x81, 0x2f, 0x80, 
3d67      0x026e, "@@@BLINKY", 		0x2f, 0x81, 0x2f, 0x80, 
3d67  P   0x0165, "&BLINKY&@", 		0x2f, 0x81, 0x2f, 0x80, 
3d76      0x02c8, ";KILLER@@@", 	0x2f, 0x83, 0x2f, 0x80, 
3d76  P   0x02c8, ";SPEEDY@@@", 	0x2f, 0x83, 0x2f, 0x80, 
3d86      0x026e, "@@@PINKY@", 		0x2f, 0x83, 0x2f, 0x80, 
3d86  P   0x0168, "&PINKY&@@", 		0x2f, 0x83, 0x2f, 0x80, 
3d95      0x026e, "MS@PAC;MAN", 	0x2f, 0x89, 0x2f, 0x80, 
3d95  P   0x02cb, ";BASHFUL@@", 	0x2f, 0x85, 0x2f, 0x80, 
3da5      0x026e, "@@@INKY@@", 		0x2f, 0x85, 0x2f, 0x80, 
3da5  P   0x016b, "&INKY&@@@", 		0x2f, 0x85, 0x2f, 0x80, 
3db4      0x023d, "@@1980:1981@", 	0x2f, 0x81, 0x2f, 0x80, 
3db4  P   0x02ce, ";POKEY@@@@", 	0x2f, 0x87, 0x2f, 0x80, 
3dc6      0x026e, "@@@@SUE", 		0x2f, 0x87, 0x2f, 0x80, 
3dc4  P   0x016e, "&CLYDE&@@", 		0x2f, 0x87, 0x2f, 0x80, 
3dd3      0x026b, "JUNIOR@@@@", 	0x2f, 0x8f, 0x2f, 0x80, 
3dd3  P   0x02c5, ";AAAAAAAA;", 	0x2f, 0x81, 0x2f, 0x80, 
3de3      0x026b, "WITH@@@@@", 		0x2f, 0x8f, 0x2f, 0x80, 
3de3  P   0x0165, "&BBBBBBB&", 		0x2f, 0x81, 0x2f, 0x80, 
3df2      0x026b, "THE@CHASE@", 	0x2f, 0x8f, 0x2f, 0x80, 
3df2  P   0x02c8, ";CCCCCCCC;", 	0x2f, 0x83, 0x2f, 0x80, 
3e02      0x026b, "STARRING@", 		0x2f, 0x8f, 0x2f, 0x80, 
3e02  P   0x0168, "&DDDDDDD&", 		0x2f, 0x83, 0x2f, 0x80, 
3e11      0x030c, "MS@PAC;MEN", 	0x2f, 0x8f, 0x2f, 0x80, 
3e11  P   0x02cb, ";EEEEEEEE;", 	0x2f, 0x85, 0x2f, 0x80, 
3e21      0x026b, "@@@@@@@@@", 		0x2f, 0x85, 0x2f, 0x80, 
3e21  P   0x016b, "&FFFFFFF&", 		0x2f, 0x85, 0x2f, 0x80, 
3e30      0x026b, "ACT@III&@@", 	0x2f, 0x87, 0x2f, 0x80, 
3e30  P   0x02ce, ";GGGGGGGG;", 	0x2f, 0x87, 0x2f, 0x80, 
3e40      0x026b, "THEY@MEET", 		0x2f, 0x8f, 0x2f, 0x80, 
3e40  P   0x016e, "&HHHHHHH&", 		0x2f, 0x87, 0x2f, 0x80, 
3e4f      0x030c, "OTTOMEN", 		0x2f, 0x8f, 0x2f, 0x80, 
3e4f  P   0x030c, "PAC;MAN", 		0x2f, 0x8f, 0x2f, 0x80, 

	    ;; new code for ms-pacman.  used during demo mode, when there are no credits

3e5c  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
3e5f  fe10      cp      #10		; == #10 ?  #10 indicates that the maze demo is running, not the marquee
3e61  c4d03e    call    nz,#3ed0	; no, call this sub.  it controls the flashing bulbs around the marquee
3e64  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
3e67  e7        rst     #20		; jump based on A

3e68  5f 04				; #045F		; A == #00	; display "ms. Pac Man"
3e6a  96 3e				; #3E96		; A == #01 	; draw the midway logo and copyright
3e6c  8b 3e				; #3E8B		; A == #02	; display "Ms. Pac Man"
3e6e  0c 00				; #000C  	; A == #03	; returns immediately
3e70  bd 3e				; #3EBD		; A == #04	; display "with"
3e72  9c 3e				; #3E9C		; A == #05	; display "Blinky"
3e74  83 34				; #3483		; A == #06	; move blinky across the marquee and up left side
3e76  a2 3e				; #3EA2		; A == #07	; clear "with" and display "Pinky"
3e78  88 34				; #3488		; A == #08	; move pinky across the marquee and up left side
3e7a  ab 3e				; #3EAB		; A == #09	; display "Inky"
3e7c  8d 34				; #348D		; A == #0A	; move Inky across the marquee and up left side
3e7e  b1 3e				; #3EB1		; A == #0B	; display "Sue"
3e80  92 34				; #3492		; A == #0C	; move Sue across the marquee and up left side
3e82  c3 3e 				; #3EC3		; A == #0D	; display "Starring"
3e84  b7 3e 				; #3EB7		; A == #0E	; display "MS. Pac-Man"
3e86  97 34				; #3497		; A == #0F	; move ms pacman across the marquee
3e88  c9 3e   				; #3EC9		; A == #10	; start demo mode where ms. pac plays herself

; arrive here from #3E67 when sub# == 2

3e8b  ef        rst     #28		; insert task to display text "MS Pac Man"
3e8c  1c 0c				; 

3e8e  3e60      ld      a,#60		; A := #60
3e90  32014f    ld      (#4f01),a	; store into stack ?
3e93  c38e05    jp      #058e		; jumps back, increases sub # and returns

    ; draw the midway logo and cprt for the attract screen

3e96  cd4296    call    #9642		; draws title screen logo and text
3e99  c38e05    jp      #058e

3e9c  ef        rst     #28		; insert task to display text "Blinky"
3e9d  1c 0d				; 
3e9f  c38e05    jp      #058e

3ea2  ef        rst     #28		; insert task to display text "       " [clears "with"]
3ea3  1c 30				; 
3ea4  ef        rst     #28		; insert task to display text "Pinky"
3ea6  1c 0f				; 
3ea8  c38e05    jp      #058e

3eab  ef        rst     #28		; insert task to display text "Inky"
3eac  1c 2f				; 
3eae  c38e05    jp      #058e

3eb1  ef        rst     #28		; insert task to display text "Sue"
3eb2  1c 31				; 
3eb4  c38e05    jp      #058e

3eb7  ef        rst     #28		; insert task to display text "Ms. Pac-Man"
3eb8  1c 33				; 
3eba  c38e05    jp      #058e

3ebd  ef        rst     #28		; insert task to display text "with"
3ebe  1c 0e				; 
3ebf  c38e05    jp      #058e

3ec3  ef        rst     #28		; insert task to display text "starring"
3ec4  1c 10				; 
3ec6  c38e05    jp      #058e

; demo mode when ms pac plays herself in the maze

3ec9  af        xor     a		; A := #00
3eca  32144e    ld      (#4e14),a	; store into number of lives
3ecd  c37c05    jp      #057c		; jump back

; this sub controls the flashing bulbs around the marquee in the attract screen

3ed0  3a014f    ld      a,(#4f01)	; load A with counter
3ed3  3c        inc     a		; increase
3ed4  e60f      and     #0f		; mask bits, now between #00 and #0F
3ed6  32014f    ld      (#4f01),a	; store result
3ed9  4f        ld      c,a		; copy to C
3eda  cb81      res     0,c		; reset bit #0 on C
3edc  0600      ld      b,#00		; B:= #00
3ede  dd21813f  ld      ix,#3f81	; load IX with start of table data
3ee2  cb47      bit     0,a		; test bit 0 of A
3ee4  2833      jr      z,#3f19         ; if zero then jump ahead to do other part of routine
3ee6  dd09      add     ix,bc		; add counter to index of table data
3ee8  dd6e00    ld      l,(ix+#00)
3eeb  dd6601    ld      h,(ix+#01)
3eee  3687      ld      (hl),#87	; moves white spot by one
3ef0  dd6e10    ld      l,(ix+#10)
3ef3  dd6611    ld      h,(ix+#11)
3ef6  3687      ld      (hl),#87	; moves white spot by one
3ef8  dd6e20    ld      l,(ix+#20)
3efb  dd6621    ld      h,(ix+#21)
3efe  368a      ld      (hl),#8a	; moves white spot by one	
3f00  dd6e30    ld      l,(ix+#30)
3f03  dd6631    ld      h,(ix+#31)
3f06  3681      ld      (hl),#81	; moves white spot by one
3f08  dd6e40    ld      l,(ix+#40)
3f0b  dd6641    ld      h,(ix+#41)
3f0e  3681      ld      (hl),#81	; moves white spot by one
3f10  dd6e50    ld      l,(ix+#50)
3f13  dd6651    ld      h,(ix+#51)
3f16  3684      ld      (hl),#84	; moves white spot by one
3f18  c9        ret     		; return

3f19  0d        dec     c		; decrement C
3f1a  af        xor     a		; A := #00
3f1b  b9        cp      c		; compare
3f1c  fa213f    jp      m,#3f21		; if negative, skip next step
3f1f  06ff      ld      b,#ff		; load B with #FF
3f21  0d        dec     c		; decrement C
3f22  dd09      add     ix,bc		; add to index of table data
3f24  dd6e00    ld      l,(ix+#00)
3f27  dd6601    ld      h,(ix+#01)
3f2a  35        dec     (hl)		; color marquee spot red
3f2b  dd6e02    ld      l,(ix+#02)
3f2e  dd6603    ld      h,(ix+#03)
3f31  3688      ld      (hl),#88	; color next spot white
3f33  dd6e10    ld      l,(ix+#10)
3f36  dd6611    ld      h,(ix+#11)
3f39  35        dec     (hl)		; color marquee spot red
3f3a  dd6e12    ld      l,(ix+#12)
3f3d  dd6613    ld      h,(ix+#13)
3f40  3688      ld      (hl),#88	; color next spot white
3f42  dd6e20    ld      l,(ix+#20)
3f45  dd6621    ld      h,(ix+#21)
3f48  35        dec     (hl)		; color marquee spot red
3f49  dd6e22    ld      l,(ix+#22)
3f4c  dd6623    ld      h,(ix+#23)
3f4f  368b      ld      (hl),#8b	; color next spot white
3f51  dd6e30    ld      l,(ix+#30)
3f54  dd6631    ld      h,(ix+#31)
3f57  35        dec     (hl)		; color marquee spot red
3f58  dd6e32    ld      l,(ix+#32)
3f5b  dd6633    ld      h,(ix+#33)
3f5e  3682      ld      (hl),#82	; color next spot white
3f60  dd6e40    ld      l,(ix+#40)
3f63  dd6641    ld      h,(ix+#41)
3f66  35        dec     (hl)		; color marquee spot red
3f67  dd6e42    ld      l,(ix+#42)
3f6a  dd6643    ld      h,(ix+#43)
3f6d  3682      ld      (hl),#82	; color next spot white
3f6f  dd6e50    ld      l,(ix+#50)
3f72  dd6651    ld      h,(ix+#51)
3f75  35        dec     (hl)		; color marquee spot red
3f76  dd6e52    ld      l,(ix+#52)
3f79  dd6653    ld      h,(ix+#53)
3f7c  3683      ld      (hl),#83	; BUG.  Spot stays red.  SHOULD BE #85, not #83, to color spot white

; BUGFIX04 - Marquee left side animation fix - Don Hodges
3f7c 36 85


3f7e  c9        ret     		; return
3f7f  d0        ret     nc		; junk

; data Used above in #3EDE, for the flashing marquee

3F80:  42 B0 42 90 42 70 42 50 42 30 42 10 42 F0 41 D0
3F90:  41 B0 41 90 41 70 41 50 41 30 41 10 41 F0 40 D0
3FA0:  40 B0 40 AF 40 AE 40 AD 40 AC 40 AB 40 AA 40 A9
3FB0:  40 C9 40 E9 40 09 41 29 41 49 41 69 41 89 41 A9
3FC0:  41 C9 41 E9 41 09 42 29 42 49 42 69 42 89 42 A9
3FD0:  42 C9 42 CA 42 CB 42 CC 42 CD 42 CE 42 CF 42 D0
3FE0:  42

; unused ?

3FE1:     C9 42 CA 42 CB 42 CC 42 CD 42 CE 42 CF 42 D0
3FF0:  42 42 CF 42 D0 42 00 4F C9 00

3FFA:  00 30				; #3000 is an interrupt vector (pac-man only, referenced at #233B in pac-man code)
3FFC:  8D 00				; #008D is an interrupt vector.  Referenced at #3183
3FFE:  75 73				; checksum bytes for #3000-#3FFF



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; 8000 through 8800:  U5 on the aux board
;;
;; 8000 through 8200:  U5 on the aux board 
;; 8 byte chunks from here are overlayed down into the pac-man roms
;;

!    GLOBAL ATTRACT,CALCADR,MAZENUM
!    GLOBAL DOFRUIT,EATFRUIT,MAXFRUIT,PROMPTHACKS
!    GLOBAL WALLADR,DOTSA1,DOTSA2,MOREDOTS
!    GLOBAL DRAWEN,READEN,FLASHEN
!    GLOBAL RCORNER,R1CORNER,R2CORNER,SCOLOR,RCOLOR,SLOWMAP
!    GLOBAL ENTRY1,ENTRY2,ENTRY3
!    GLOBAL FRUITPNTS
!    GLOBAL CHOOSETUNE,MELODIES,HARMONIES,AUXILIARY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; - OVERLAY - 0x2418

8000  c9        ret     
8001  210040    ld      hl,#4000
8004  cd6a94    call    #946a
8007  0a        ld      a,(bc)


; sil attack uses: 
;  (there is a second rom with changes, but i can't find how it overlaps.
; 8000  42        ld      b,d
; 8001  ef        rst     #28
; 8002  00 ff     
; 8004  00        nop     
; 8005  ff        rst     #38
; 8006  01ef--    ld      bc,#--ef

; - OVERLAY - 0x0410

8008  4e        ld      c,(hl)
8009  34        inc     (hl)
800a  c9        ret     
800b  c35c3e    jp      #3e5c
800e  e7        rst     #20
800f  5f        ld      e,a

; - OVERLAY - 0x1008

8010  --d24d    ld      (#4dd2),hl
8012  c9        ret
8013  c37836    jp      #3678
8016  3a00

; - OVERLAY - 0x2108

8018  c33534    jp      #3435
801b  e7        rst     #20
801c  1a        ld      a,(de)
801d  214021    ld      hl,#2140

; - OVERLAY - 0x1000

8020  af        xor     a
8021  32d44d    ld      (#4dd4),a
8024  c9        ret     
8025  00        nop     
8026  00        nop     
8027  22----    ld      ----

; - OVERLAY - 0x2800

8028  2a104d    ld      hl,(#4d10)
802b  cd5e95    call    #955e
802e  1140--    ld      de,#--40

; - unused -

8030  ff ff ff ff  ff ff ff ff
8038  ff ff ff ff  ff ff ff ff
8040  ff ff ff ff  ff ff ff ff

; - OVERLAY - 0x3148

8048  ----4e    ld      hl,#4ebc
8049  3600      ld      (hl),#00
804b  3e3e      ld      a,#3e
804d  115901    ld      de,#0159

; - OVERLAY - 0x2748

8050  3a2c4d    ld      a,(#4d2c)
8053  cd6195    call    #9561
8056  cd66--    call    #--66

; - OVERLAY - 0x2448

8058  210040    ld      hl,#4000
805b  c37c94    jp      #947c
805e  4e        ld      c,(hl)
805f  fd

; - unused -

8060  ff ff ff ff  ff ff ff ff
8068  ff ff ff ff  ff ff ff ff
8070  ff ff ff ff  ff ff ff ff
8078  ff ff ff ff  ff ff ff ff

; - OVERLAY - 0x2488

8080  --0040    ld      hl,#4000
8082  c38194    jp      #9481
8085  4e        ld      c,(hl)
8086  fd21

; - OVERLAY - 0x1688

8088  --360d1e  ld      (ix+#0d),#1e
808a  c9        ret     
808c  c39c86    jp      #869c
808f  c9        ret     

; - OVERLAY - 0x274a

2748  ----4d    ld      a,(#4d2c)
8091  cd6195    call    #9561
8094  cd6629    call    #2966
8097  22---	ld      ...

; - OVERLAY - 0x1288

8098  32d14d    ld      (#4dd1),a
809B: 21 AC 4E      ld   hl,#4EAC
809E: CB F6         set  6,(hl)

; - OVERLAY - 0x2298

80a0  --084e    ld      a,(#4e08)
80a2  c36934    jp      #3469
80a5  be        cp      (hl)
80a6  220c	ld	...

; - OVERLAY - 0x19a8

80a8  --084d    ld      hl,(#4d08)
80aa  119480    ld      de,#8094
80ad  c31888    jp      #8818

; - unused

80b0  ff ff ff ff  ff ff ff ff
80b8  ff ff ff ff  ff ff ff ff

; - OVERLAY - 0x24d8

80c0  78        ld      a,b
80c1  fe02      cp      #02
80c3  3e1f      ld      a,#1f
80c5  c38095    jp      #9580

; - OVERLAY - 0x16d8

80c8  ----4d    ld      a,(#4d09)
80c9  c3c586    jp      #86c5
80cc  c9        ret     
80cd  3808      jr      c, +#08
80cf  1e--      ld      e,#--

; - OVERLAY - 0x2bc0

80d0  --d2      jr      #2c93
80d1  c39797    jp      #9797
80d4  dd21cc4e  ld      ix,#4ecc

; - OVERLAY - 0x0bd0

80d8  ----0907  ld      (ix+#09),#07
80da  fd3500    dec     (iy+#00)
80dd  c9        ret     
80de  0619      ld      b,#19

; - OVERLAY - 0x2cd8

80e0  --914e    ld      (#4e91),a   
80e2  217d96    ld      hl,#967d
80e5  dd21dc--  ld      ix,#e3dc

; - OVERLAY - 0x23e0

80e5  ----e3    jp      pe,#e32b
80e9  95        sub     l
80ea  a1        and     c
80eb  2b        dec     hl
80ec  75        ld      (hl),l
80ed  26b2      ld      h,#b2
80ef  26--      ld      h,#--

; - unused -
80f0  ff ff ff ff  ff ff ff ff
80f8  ff ff ff ff  ff ff ff ff

; - OVERLAY - 0x2b20  (scoring table)
8100  --08 
8101  0016
8103  0001
8105  0002
8107  00--

; - unused -
8108  ff ff ff ff  ff ff ff ff

; - OVERLAY - 0x2B30 (scoring table)

8110  50        ld      d,b
8111  00        nop     
8112  50        ld      d,b
8113  13        inc     de
8114  6b        ld      l,e
8115  62        ld      h,d
8116  1b        dec     de
8117  cb--

; - OVERLAY - 0x0a30

8118  32bc4e    ld      (#4ebc),a
811b  1806      jr      #.+06 
811d  32cc4e    ld      (#4ecc),a

; - OVERLAY - 0x0c20

8120  ----44    ld      hl,#4464
8121  c32495    jp      #9524
8124  2002      jr      nz,#.+02 
8126  3e00      ld      a,#00

; - unused -

8128  ff ff ff ff  ff ff ff ff
8130  ff ff ff ff  ff ff ff ff
8138  ff ff ff ff  ff ff ff ff

; - OVERLAY - 0x2470

8140  --344e    ld      hl,#4e34
8142  c3ec94    jp      #94ec
8145  eda0      ldi     
8147  11----    ld      de,#6fc3

; - OVERLAY - 0x2060

8148  c36f36    jp      #366f   
2063  00        nop
814c  02        ld      (bc),a
814d  c9        ret     
814e  af        xor     a
814f  02        ld      (bc),a

; - unused - 

8150  ff ff ff ff  ff ff ff ff
8159  ff ff ff ff  ff ff ff ff

; - OVERLAY - 0x2d60

8160  --7302    ld      (ix+#02),e
8162  c34e36    jp      #364e
8165  0c        inc     c
8166  dd35--    dec     (ix-#59)

; - OVERLAY - 0x0e58

8168  a7        and     a         
8169  ed52      sbc     hl,de
816b  c0        ret     nz
816c  af        xor     a
816d  00        nop     
816e  3c        inc     a
816f  32----    ld      (#ffff),a

; - unused -

8170  ff ff ff ff  ff ff ff ff
8178  ff ff ff ff  ff ff ff ff

; - OVERLAY - 0x24b0

8180  --e5      jr      nz,#2496        ; (-27)
8181  216440    ld      hl,#4064
8184  c30495    jp      #9504
8187  ed--      ldi

; - OVERLAY - 0x16b0

8187  c9        ret
8189  c3b186    jp      #86b1
818c  c9        ret     
818d  07        rlca    
818e  fe06      cp      #06

; - OVERLAY - 0x27b8

8190  2a0e4d    ld      hl,(#4d0e)
8193  cd5995    call    #9559
8196  1140--    ld      de,#--40

; - OVERLAY - 0x0ea8

8198  a6        and     (hl)    
8199  cbc7      set     0,a
819b  77        ld      (hl),a
819c  c9        ret     
819d  c3ee86    jp      #86ee

; - OVERLAY - 0x21a0

81a0  ----4e    ld      a,(#4e07)
81a1  c34f34    jp      #344f
81a4  41        ld      b,c
81a5  e7        rst     #20
81a6  c221--    jp      nz,#--21

; - OVERLAY - 0x19b8

81a8  cd0010    call    #1000
81ab  1807      jr      #19c4
81ad  1c        inc     e       
81ae  cd42--    call    #0042

; - unused -

81b0  ff ff ff ff  ff ff ff ff
81b8  ff ff ff ff  ff ff ff ff

; - OVERLAY - 0x24f8

81c0  --1a      ld      a,#1a
81c1  c3c395    jp      #95c3
81c4  0606      ld      b,#06
81c6  dd21----  ld      ix,#4d08

; - OVERLAY - 0x16f8

81c6  --084d    ld      a,(#4d08)
81ca  c3d986    jp      #86d9
81cd  c9        ret     
81ce  3805      jr      c,#.+5

; - OVERLAY - 0x2bf0

81d0  3a134e    ld      a,(#4e13)
81d3  3c        inc     a
81d4  c39387    jp      #8793
81d7  2e--      ld      l,#4e		; junk

; - OVERLAY - 0x08e0

81d8  ----4e    ld      a,(#4e0e)
81d9  c3a194    jp      #94a1
81dc  00        nop     
81dd  21044e    ld      hl,#4e04

; - OVERLAY - 0x2cf0

81e0  32964e    ld      (#4e96),a
81e3  218d96    ld      hl,#968d
81e6  dd21----  ld      ix,#ffff

; - unused -

81e8  ff ff ff ff  ff ff ff ff

; lookup table.  used in #361F for sprite movement
; these contain pointers to the step program/codes to be run

81f0  51 82	; #8251		; 1st intermission
81f2  a3 82	; #82A3
81f4  12 83	; #8312
81f6  4c 83	; #834C
81f8  69 85	; #8569
81fa  7c 85	; #857C

81fc  95 83	; #8395		; 2nd intermission
81fe  f0 83	; #83F0
8200  2b 85	; #852B
8202  4a 85	; #854A
8204  69 85	; #8569
8206  7c 85	; #857C

8208  51 84	; #8451		; 3rd intermission
820a  6d 84	; #846D
820c  cf 84	; #84CF
820e  fd 84 	; #84FD
8210  89 84	; #8489
8212  7c 85	; #857C

8214  94 85	; #8594		; attract mode 1st ghost
8216  50 82	; #8250
8218  50 82	; #8250
821a  50 82	; #8250
821c  50 82	; #8250
821e  50 82	; #8250

8220  50 82	; #8250		; attract mode 2nd ghost
8222  b0 85	; #85B0
8224  50 82	; #8250
8226  50 82	; #8250
8228  50 82	; #8250
822a  50 82	; #8250

822c  50 82	; #8250		; attract mode 3rd ghost
822e  50 82	; #8250
8230  cc 85	; #85CC
8232  50 82	; #8250
8234  50 82	; #8250
8236  50 82	; #8250

8238  50 82	; #8250		; attract mode 4th ghost
823a  50 82	; #8250
823c  50 82	; #8250
823e  e8 85	; #85E8
8240  50 82	; #8250
8242  50 82	; #8250

8244  50 82	; #8250		; attract mode ms pac man
8246  50 82	; #8250
8248  50 82	; #8250
824a  50 82	; #8250
824c  04 86	; #8604
824e  50 82	; #8250

8250  ff       	; no data


; commands: (functionality TBD)
;	cmd	    opc 	bytes	param fcn	opc fcn
	LOOP      =  F0	; 	3	?		repeat this N times, perhaps?
							A B (color)
	SETPOS	  =  F1	; 	2	position?	
	SETN  	  =  F2	; 	1	value		store for other ops
	SETCHAR   =  F3	; 	2	table ptr	switch to the specified sprite code table?
	-         =  F4
	PLAYSOUND =  F5	;	1	sound code	play a sound (eg 10=ghost bump)
	PAUSE     =  F6	;	-	-		pause for N ticks?
	SHOWACT   =  F7	;	
	CLEARACT  =  F8	; 	-	-		clear the act # from the screen
	END       =  FF

; this appears to work like,  (guesses here)
;	setchar ADDR	to select the caracter array to work with
;	setpos X Y	moves the sprite to that location instantly
;	loop A B C	moves the sprite to a,b, while using color C
;			for previous SETN units/speed
;	PAUSE		wait for SETN units/time
	

; data for 1st intermission, part 1

8251:  F1 00 00 		; SETPOS	00 00	
; set character set 8675 (act sign)
8254:  F3 75 86			; SETCHAR	#8675	; ACT sign
8257:  F2 01 			; SETN		01
8259:  F0 00 00 		; LOOP		00 00
825D:  F1 BD 52			; SETPOS	BD 52
8260:  F2 28			; SETN		28
8262:  F6			; PAUSE
8263:  F2 16			; SETN		16
8265:  F0 00 00 16		; LOOP		00 00 16
	;       ^^ color 16 (white)
8269:  F2 16			; SETN		16
826B:  F6			; PAUSE
826C:  F1 FF 54			; SETPOS	FF 54

826F:  F3 14 86			; SETCHAR	#8614	  ; otto
8272:  F2 7F			; SETN		7F
8274:  F0 F0 00 09		; LOOP		F0 00 09  ; otto
	;       ^^ color 9 (yellow otto)
8278:  F2 7F			; SETN		7F
827A:  F0 F0 00 09		; LOOP		F0 00 09  ; otto
827E:  F1 00 7F			; SETPOS	00 7F

8281:  F3 1D 86			; SETCHAR	#861D	  ; otto to center
8284:  F2 75			; SETN		75
8286:  F0 10 00 09		; LOOP		10 00 09
828A:  F2 04			; SETN		04
828C:  F0 10 F0 09		; LOOP		10 F0 09
8290:  F3 26 86			; SETCHAR	#8626
8293:  F2 30			; SETN		30
8295:  F0 00 F0 09		; LOOP		00 F0 09
8299:  F3 1D 86			; SETCHAR	#861D
829C:  F2 10			; SETN		10
829E:  F0 00 00 09		; LOOP		00 00 09
82A2:  FF			; END 

; data for 1st intermission, part 2

82A3:  F1 00 00
82A6:  F3 7F 86			; #867F
82A9:  F2 01
82AB:  F0 00 00 16		; ACT sign
82AF:  F1 AD 52
82B2:  F2 28
82B4:  F6
82B5:  F2 16
82B7:  F0 00 00 16		; ACT sign
82BB:  F2 16
82BD:  F6
82BE:  F1 FF 54 
82C1:  F3 5C 86			; #865C
82C4:  F2 2F
82C6:  F6
82C7:  F2 70 
82C9:  F0 EF 00 05		; cyan ghost
82CD:  F2 74
82CF:  F0 EC 00 05 		; cyan ghost
82D3:  F1 00 7F 
82D6:  F3 63 86 		; #8663
82D9:  F2 1C
82DB:  F6
82DC:  F2 58
82DE:  F0 16 00 05
82E2:  F5 10			; sound for ghost bump
82E4:  F2 06
82E6:  F0 F8 F8 05
82EA:  F2 06
82EC:  F0 F8 08 05
82F0:  F2 06
82F2:  F0 F8 F8 05
82F6:  F2 06
82F8:  F0 F8 08 05
82FC:  F1 00 00
82FF:  F3 73 86			; #8673
8302:  F2 01
8304:  F0 00 00 03
8308:  F1 7F 3A
830B:  F2 40
830D:  F0 00 00 03
8311:  FF			; end code

; data for 1st intermission, part 3

8312:  F2 5A 
8314:  F6
8315:  F1 00 A4
8318:  F3 41 86			; #8641	 left anna
831B:  F2 7F 
831D:  F0 10 00 09 
8321:  F2 7F
8323:  F0 10 00 09
8327:  F1 FF 7F
832A:  F3 38 86 		; #8638	; right anna
832D:  F2 76
832F:  F0 F0 00 09
8333:  F2 04
8335:  F0 F0 F0 09
8339:  F3 4A 86			; #864a ; up anna (?)
833C:  F2 30
833E:  F0 00 F0 09
8342:  F3 38 86			; #8638	; stopped anna
8345:  F2 10
8347:  F0 00 00 09
834B:  FF			; end code

; data for 1st intermission, part 4

834C:  F2 5F
834E:  F6
834F:  F1 01 A4
8352:  F3 63 86			; #8663
8355:  F2 2F
8357:  F6
8358:  F2 70
835A:  F0 11 00 03
835E:  F2 74
8360:  F0 14 00 03
8364:  F1 FF 7F
8367:  F3 5C 86			; #865C
836A:  F2 1C
836C:  F6
836D:  F2 58
836F:  F0 EA 00 03
8373:  F2 06
8375:  F0 08 F8 03
8379:  F2 06 
837B:  F0 08 08 03
837F:  F2 06
8381:  F0 08 F8 03
8385:  F2 06 
8387:  F0 08 08 03
838B:  F3 71 86			; #8671
838E:  F2 10
8390:  F0 00 00 16
8394:  FF			; end code


; CODE from CRAZY OTTO actual source: (Rosetta Stone) (tidied up)
; 2nd intermission data, part 1
/*
!    BYTE SETPOS,   0FFH,34H
!    BYTE SETCHAR
!    WORD           RIGHT_OTTO
!    BYTE SETN,     7FH,PAUSE
!    BYTE SETN,     24H,PAUSE
!    BYTE SETN,     68H,LOOP,0D8H,00,09
!    BYTE SETN,     7FH,PAUSE
!    BYTE SETN,     18H,PAUSE
!    BYTE SETPOS,   00H,094H
!    BYTE SETCHAR
!    WORD           LEFT_ANNA
!    BYTE SETN,     68H,LOOP,028H,00,09
!    BYTE SETN,     7FH,PAUSE
!    BYTE SETPOS,   0FCH,7FH
!    BYTE SETCHAR
!    WORD           RIGHT_OTTO
!    BYTE SETN,     18H,PAUSE
!    BYTE SETN,     68H,LOOP,0D8H,0,09
!    BYTE SETN,     7FH,PAUSE
!    BYTE SETN,     18H,PAUSE
!    BYTE SETPOS,   00H,054H
!    BYTE SETCHAR
!    WORD           LEFT_ANNA
!    BYTE SETN,     20H,LOOP,070H,00,09
!    BYTE SETPOS,   0FFH,0B4H
!    BYTE SETCHAR
!    WORD           RIGHT_OTTO
!    BYTE SETN,     10H,PAUSE
*/


; commands: (functionality TBD)
;	cmd	    opc 	bytes	param fcn	opc fcn
	LOOP      =  F0	; 	3	?		repeat this N times, perhaps?
	SETPOS	  =  F1	; 	2	position?	TBD
	SETN  	  =  F2	; 	1	value		TBD
	SETCHAR   =  F3	; 	2	table ptr	switch to the specified sprite code table?
	-         =  F4
	PLAYSOUND =  F5	;	1	sound code	play a sound (eg 10=ghost bump)
	PAUSE     =  F6	;	-	-		pause for N ticks?
	SHOWACT   =  F7	;	
	CLEARACT  =  F8	; 	-	-		clear the act # from the screen
	END       =  FF
	
; 2nd intermission data, part 1
;  NOTE: this is the segment that had the above source code published.
;	 That was a rosetta stone for figuring out the animation code system
;	 (work in progress)

	; this is for the pac being chased (red anna)
8395:  F2 5A			; SETN( 5A )
8397:  F6			; PAUSE
8398:  F1 FF 34			; SETPOS, FF, 34
839B:  F3 14 86			; SETCHAR ( RIGHT_OTTO )  (sprite codes)
839E:  F2 7F			; SETN( 7f )
83A0:  F6			; PAUSE
83A1:  F2 24			; SETN( 24 )
83A3:  F6			; PAUSE
83A4:  F2 68			; SETN( 60 )
83A6:  F0 D8 00 09		; LOOP( d8, 00 09 )
83AA:  F2 7F			; SETN( 7f )
83AC:  F6			; PAUSE

83AD:  F2 18			; SETN( 18 )
83AF:  F6			; PAUSE

83B0:  F1 00 94 		; SETCHAR( LEFT_ANNA )
83B3:  F3 41 86			; SETN( 
83B6:  F2 68			; SETN(
83B8:  F0 28 00 09		; LOOP( 28 00 09 )
83BC:  F2 7F			; SETN( 7f )
83BE:  F6			; PAUSE

83BF:  F1 FC 7F			; SETPOS( fc, 7f )
83C2:  F3 14 86			; SETCHAR( RIGHT_OTTO )
83C5:  F2 18			; SETN( 18 )
83C7:  F6			; PAUSE
83C8:  F2 68			; SETN( 68 )
83CA:  F0 D8 00 09		; LOOP ( d8, 0, 09 )
83CE:  F2 7F			; SETN( 7f ) 
83D0:  F6			; PAUSE
83D1:  F2 18			; SETN( 18 )
83D3:  F6			; PAUSE
83D4:  F1 00 54			; SETPOS( 00 54 ) 
83D7:  F3 41 86			; SETCHAR( LEFT_ANNA )
83DA:  F2 20			; SETN( 20 )
83DC:  F0 70 00 09		; LOOP
83E0:  F1 FF B4			; SETPOS( ff, 04 )

83E3:  F3 14 86			; SETCHAR( RIGHT_OTTO )
83E6:  F2 10			; SETN( 10 )
83E8:  F6			; PAUSE
83E9:  F2 24			; SETN( 24 )
	  SPEED?
83EB:  F0 90 00 09		; LOOP( 90 0 09)
          XX YY CC
83EF:  FF			; end code

; data for 2nd intermission, part 2

83F0:  F2 63
83F2:  F6
83F3:  F1 FF 34
83F6:  F3 38 86			; #8638
83F9:  F2 24
83FB:  F6
83FC:  F2 7F
83FE:  F6
83FF:  F2 18
8401:  F6
8402:  F2 57
8404:  F0 D0 00 09
8408:  F2 7F
840A:  F6
840B:  F2 28
840D:  F6
840E:  F1 00 94
8411:  F3 1D 86			; #861D 8414:  F2 58
8416:  F0 30 00 09
841A:  F2 7F
841C:  F6
841D:  F2 24
841F:  F6
8420:  F1 FF 7F
8423:  F3 38 86			; #8638
8426:  F2 58
8428:  F0 D0 00 09
842C:  F2 7F
842E:  F6
842F:  F2 20
8431:  F6
8432:  F1 00 54
8435:  F3 1D 86			; #861D
8438:  F2 20
843A:  F0 70 00 09
843E:  F1 FF B4
8441:  F3 38 86			; #8638
8444:  F2 10
8446:  F6
8447:  F2 24
8449:  F0 90 00 09
844D:  F2 7F
844F:  F6
8450:  FF 			; end code

; 3rd intermission data part 1

8451:  F2 5A
8453:  F6
8454:  F1 00 60
8457:  F3 8D 86			; #868D front of stork
845A:  F2 7F
845C:  F0 0A 00 16
8460:  F2 7F
8462:  F0 10 00 16
8466:  F2 30
8468:  F0 10 00 16
846C:  FF			; end code

; 3rd intermission data part 2

846D:  F2 6F
846F:  F6
8470:  F1 00 60
8473:  F3 8F 86			; #868F flap stork
8476:  F2 6A
8478:  F0 0A 00 16
847C:  F2 7F
847E:  F0 10
8480:  00 16
8482:  F2 3A
8484:  F0 10 00 16
8488:  FF 			; end code

; 3rd intermission data part 5
; sack fall, baby appears

8489:  F3 89 86			; #8689 act
848C:  F2 01
848E:  F0 00 00 16
8492:  F1 BD 62
8495:  F2 5A
8497:  F6
8498:  F1 05 60

849B:  F3 98 86			; #8698 sack
849E:  F2 7F
84A0:  F0 0A 00 16		; color 16 makes the sack blue
84A4:  F2 7F
84A6:  F0 06 0C 16		; this here is the bounce
84AA:  F2 06
84AC:  F0 06 F0 16
84B0:  F2 0C
84B2:  F0 03 09 16
84B6:  F2 05
84B8:  F0 05 F6 16		; final parameter is COLOR
84BC:  F2 0A
84BE:  F0 04 03 16
84C2:  F3 9A 86			; #869A baby
84C5:  F2 01
84C7:  F0 00 00 16		; change baby color here
84CB:  F2 20
84CD:  F6
84CE:  FF 			; end code

; 3rd intermission data part 3

84CF:  F1 00 00
84D2:  F3 75 86			; #8675
84D5:  F2 01
84D7:  F0 00 00 16		; ACT 
84DB:  F1 BD 52
84DE:  F2 28
84E0:  F6
84E1:  F2 16 
84E3:  F0 00 00 16
84E7:  F2 16
84E9:  F6
84EA:  F1 00 00 
84ED:  F3 38 86			; #8638
84F0:  F2 01 
84F2:  F0 00 00 09		; pac in front, closest to baby
84F6:  F1 C0 C0
84F9:  F2 30
84FB:  F6
84FC:  FF 			; end code

; 3rd intermission data part 4

84FD:  F1 00 00
8500:  F3 7F 86			; #867F
8503:  F2 01
8505:  F0 00 00 16
8509:  F1 AD 52
850C:  F2 28
850E:  F6
850F:  F2 16
8511:  F0 00 00 16
8515:  F2 16
8517:  F6
8518:  F1 00 00
851B:  F3 14 86			; #8614
851E:  F2 01
8520:  F0 00 00 09		; pac behind, (red)
8524:  F1 D0 C0
8527:  F2 30
8529:  F6
852A:  FF			; end code

; data for 2nd intermission, part 3

852B:  F1 00 00
852E:  F3 75 86			; #8675
8531:  F2 01
8533:  F0 00 00 16
8537:  F1 BD 52
853A:  F2 28
853C:  F6
853D:  F2 16
853F:  F0 00 00 16
8543:  F2 16
8545:  F6
8546:  F1 00 00
8549:  FF			; end code

; data for 2nd intermission, part 4

854A:  F1 00 00
854D:  F3 7F 86			; #867F
8550:  F2 01
8552:  F0 00 00 16
8556:  F1 AD 52
8559:  F2 28
855B:  F6
855C:  F2 16
855E:  F0 00 00 16
8562:  F2 16 
8564:  F6
8565:  F1 00 00
8568:  FF			; end code

; data for 1st, 2nd intermission, part 5

8569:  F3 89 86			; #8689
856C:  F2 01
856E:  F0 00 00 16
8572:  F1 BD 62
8575:  F2 5A
8577:  F6
8578:  F1 00 00
857B:  FF			; end code

; data for 1st, 2nd, 3rd intermission, part 6

857C:  F3 8B 86			; #868B
857F:  F2 01
8581:  F0 00 00 16
8585:  F1 AD 62
8588:  F2 39			
858A:  F6			; pause
858B:  F7			; display text
858C:  F2 1E
858E:  F6
858F:  F8			; clear act number
8590:  F1 00 00
8593:  FF			; end code

; data for attract mode 1st ghost

8594:  F1 00 94
8597:  F3 63 86			; #8663
859A:  F2 70
859C:  F0 10 00 01
85A0:  F2 50 
85A2:  F0 10 00 01
85A6:  F3 6A 86			; #866A
85A9:  F2 48
85AB:  F0 00
85AD:  F0 01
85AF:  FF			; end code

; data for attract mode 2nd ghost

85B0:  F1 00 94
85B3:  F3 63 86			; #8663
85B6:  F2 70 
85B8:  F0 10 00 03 
85BC:  F2 50
85BE:  F0 10 00 03 
85C2:  F3 6A 86			; #866A
85C5:  F2 38 
85C7:  F0 00
85C9:  F0 03
85CB:  FF			; end code

; data for attract mode 3rd ghost

85CC:  F1 00 94
85CF:  F3 63 86			; #8663
85D2:  F2 70
85D4:  F0 10 00 05 
85D8:  F2 50
85DA:  F0 10 00 05
85DE:  F3 6A 86			; #866A
85E1:  F2 28 
85E3:  F0 00
85E5:  F0 05
85E7:  FF 			; end code

; data for attract mode 4th ghost

85E8:  F1 00 94
85EB:  F3 63 86			; #8663
85EE:  F2 70
85F0:  F0 10 00 07
85F4:  F2 50
85F6:  F0 10 00 07
85FA:  F3 6A 86			; #866A
85FD:  F2 18
85FF:  F0 00
8601:  F0 07
8603:  FF 			; end code

; data for attract mode ms. pac-man

8604:  F1 00 94
8607:  F3 41 86			; #8641
860A:  F2 72
850C:  F0 10 00 09
8610:  F2 7F F6
8613:  FF			; end code

; used in act 1

; Pac:
8614:  1B 1B 19 19 1B 1B 32 32 FF	; msp walking right
861D:  9B 9B 99 99 9B 9B B2 B2 FF	; msp walking left
8626:  6E 6E 5A 5A 6E 6E 72 72 FF	; walking up

862F:  EE EE DA DA EE EE F2 F2 FF 	; left pa
8638:  37 37 2D 2D 37 37 2F 2F FF 	; right pac
;      r  r  R  R  u  u  rc rc

; used in attract mode to control ms pac moving under marquee

; moving left
8641:  B7 B7 AD AD B7 B7 AF AF FF	; pac left

864A:  36 36 F1 F1 36 36 F3 F3 FF	; ms pac man moving up at the end
; moving down?
8653:  34 34 31 31 34 34 33 33 FF	; sprite codes for ms pac man

; used in act 1

865C:  A4 A4 A4 A5 A5 A5 FF		; ghost with eyes looking right sprite

; used in attract mode to control the ghosts moving under marquee

8663:  24 24 24 25 25 25 FF		; ghost moving across (sprites with eyes looking left)
866A:  26 26 26 27 27 27 FF		; ghost moving up left side (sprites with eyes looking up)

8671:  1F FF 				; empty sprite
8673:  1E FF				; sprite code for heart


8675:  10 10 10 14 14 14 16 16 16 FF	; sprite codes for ACT sign
867F:  11 11 11 15 15 15 17 17 17 FF 	; sprite codes for ACT sign

; used in act 1

8689:  12 FF 				; sprite code for ACT sign
868B:  13 FF				; sprite code for ACT sign

868D:  30 FF				; stork sprite
868F:  18 18 18 18 2C 2C 2C 2C FF 	; stork sprites
8698:  07 FF 				; sack that stork carries sprite
869A:  0F FF            		; junior pacman sprite

; end data

; resume program

; arrive from #168C when ms pac is facing right
; MSPAC MOVING EAST
869c  3a094d    ld      a,(#4d09)	; load A with pacman X position
869f  e607      and     #07		; mask bits, now between #00 and #07
86a1  cb3f      srl     a		; shift right, now between #00 and #03
86a3  2f        cpl     		; invert
86a4  1e30      ld      e,#30		; E := #30
86a6  83        add     a,e		; add #30
86a7  cb47      bit     0,a		; test bit 0.  is it on ?
86a9  2002      jr      nz,#86ad        ; yes, skip next step
86ab  3e37      ld      a,#37		; no, A := #37
86ad  320a4c    ld      (#4c0a),a	; store into mspac sprite number
86b0  c9        ret			; return

; arrive from #16B1 when ms pac is facing down
; MSPAC MOVING SOUTH
86b1  3a084d    ld      a,(#4d08)	; load A with pacman Y position
86b4  e607      and     #07		; mask bits, now between #00 and #07
86b6  cb3f      srl     a		; shift right, now between #00 and #03
86b8  1e30      ld      e,#30		; E := #30
86ba  83        add     a,e		; add #30
86bb  cb47      bit     0,a		; test bit 0.  is it on ?
86bd  2002      jr      nz,#86c1        ; yes, skip next step
86bf  3e34      ld      a,#34		; no, A := #34
86c1  320a4c    ld      (#4c0a),a	; store into mspac sprite number
86c4  c9        ret			; return

; arrive from #16D9 when ms pac is facing left
; MSPAC MOVING WEST
86c5  3a094d    ld      a,(#4d09)	; load A with pacman X position
86c8  e607      and     #07		; mask bits, now between #00 and #07
86ca  cb3f      srl     a		; shift right, now between #00 and #03
86cc  1eac      ld      e,#ac		; E := #AC
86ce  83        add     a,e		; add #AC
86cf  cb47      bit     0,a		; test bit 0 , is it on ?
86d1  2002      jr      nz,#86d5        ; yes, skip next step
86d3  3e35      ld      a,#35		; no, A := #35
86d5  320a4c    ld      (#4c0a),a	; store into mspac sprite number
86d8  c9        ret     

; arrive from #16FA when ms pac is facing up
; MSPAC MOVING NORTH
86d9  3a084d    ld      a,(#4d08)	; load A with pacman Y position
86dc  e607      and     #07		; mask bits, now between #00 and #07
86de  cb3f      srl     a		; shift right, now between #00 and #03
86e0  2f        cpl     		; invert
86e1  1ef4      ld      e,#f4		; E := #F4
86e3  83        add     a,e		; add #F4
86e4  cb47      bit     0,a		; test bit 0 .  is it on ?
86e6  2002      jr      nz,#86ea        ; yes, skip next step
86e8  3e36      ld      a,#36		; no, A := #36
86ea  320a4c    ld      (#4c0a),a	; store into mspac sprite number
86ed  c9        ret     

; subroutine called from #0909, per intermediate jump at #0EAD

86EE: 3A A4 4D	ld	a,(#4DA4)	; Load A with # of ghost killed but no collision for yet [0..4]
86F1: A7	and	a		; == #00 ?
86F2: C0	ret	nz		; no, return

86F3: 3A D4 4D	ld	a,(#4DD4)	; load A with entry to fruit points, or 0 if no fruit
86F6: A7	and	a		; == #00 ?
86F7: CA 47 87	jp	z,#8747		; yes, check for fruit release

86FA: 3A D2 4D	ld	a,(#4DD2)	; load A with fruit X position
86FD: A7	and	a		; is a fruit already onscreen?
86FE: CA 47 87	jp	z,#8747		; no, then jump to check for 

8701  3a414c    ld      a,(#4c41)	; load A with fruit position
8704  47        ld      b,a		; copy to B
8705  214188    ld      hl,#8841	; load HL with start of table data
8708  df        rst     #18		; load HL with data at table plus offset in B
8709  ed5bd24d  ld      de,(#4dd2)	; load DE with fruit position
870d  19        add     hl,de		; add result from above
870e  22d24d    ld      (#4dd2),hl	; store result into fruit position
8711  21414c    ld      hl,#4c41	; load HL with fruit position
8714  34        inc     (hl)		; increment that location
8715  7e        ld      a,(hl)		; load A with this value
8716  e60f      and     #0f		; mask bits, now between #00 and #0F
8718  c0        ret     nz		; return if not zero ( returns to #090C)

8719  21404c    ld      hl,#4c40	; else load HL with fruit position counter
871c  35        dec     (hl)		; decrement
871d  fab587    jp      m,#87b5		; if negative, jump out to this subroutine
8720  7e        ld      a,(hl)		; else load A with this value
8721  57        ld      d,a		; copy to D
8722  cb3f      srl     a		; 
8724  cb3f      srl     a		; shift A right twice
8726  21 BC 4E	ld	hl,#4EBC	; load HL with sound channel 3
8729  CB EE	set	5,(hl)		; set bit 5 to turn on fruit bouncing sound
872b  2a424c    ld      hl,(#4c42)	; load HL with address of the fruit path
872e  d7        rst     #10		; load A with table data
872f  4f        ld      c,a		; copy to C
8730  3e03      ld      a,#03		; A := #03
8732  a2        and     d		; mask bits with the fruit position
8733  2807      jr      z,#873c         ; if zero, skip next 4 steps

8735  cb39      srl     c
8737  cb39      srl     c		; shift C right twice
8739  3d        dec     a		; A := A - 1.  is A == #00 ?
873a  20f9      jr      nz,#8735        ; no, loop again

873c  3e03      ld      a,#03		; A := #03
873e  a1        and     c		; mask bits with C
873f  07        rlca
8740  07        rlca
8741  07        rlca
8742  07        rlca			; rotate left 4 times
8743  32414c    ld      (#4c41),a	; store result into fruit position counter
8746  c9        ret     		; return

; arrive here from #86FE
; to check to see if it is time for a new fruit to be released
; only called when a fruit is not already onscreen

8747: 3A 0E 4E	ld	a,(#4E0E)	; load number of dots eaten
874A: FE 40	cp	#40		; == #40 ? (64 decimal)
874C: CA 58 87	jp	z,#8758		; yes, skip ahead and use HL as 4E0C
874F: FE B0	cp	#B0		; == #B0 (176 deciaml) ?
8751: C0	ret	nz		; no, return

8752: 21 0D 4E	ld	hl,#4E0D	; yes, load HL with #4E0D for 2nd fruit
8755: C3 5B 87	jp	#875B		; skip ahead
(
8758: 21 0C 4E	ld	hl,#4E0C	; load HL with 4E0C for first fruit

875B: 7E	ld	a,(hl)		; load A with fruit flag
875C: A7	and	a		; has this fruit already appeared?
875D: C0	ret	nz		; yes, return

875e  34	inc	(hl)

	;; Ms. Pacman Random Fruit Probabilities
	;; (c) 2002 Mark Spaeth
	;; http://rgvac.978.org/files/MsPacFruit.txt

;  A hotly contested issue on rgvac. here's an explanation
;  of how the random fruit selection routine works in Ms.
;  Pacman, and the probabilities associated with the routine:

875f  3a134e    ld      a,(#4e13)       ; Load the board # (cherry = 0)
8762  fe07      cp      #07             ; Compare it to 7
8764  380a      jr      c,#8770         ; If less than 7, use board # as fruit

8766  0607      ld      b,#07   	; else B := #07

        ;; selector for random fruits
        ;; uses r register to get a random number

8768  ed5f      ld      a,r             ; Load the DRAM refresh counter 
876a  e61f      and     #1f             ; Mask off the bottom 5 bits

                ;; Compute ((R % 32) % 7)
876c  90        sub     b               ; Subtract 7
876d  30fd      jr      nc,#876c        ; If >=0 loop
876f  80        add     a,b             ; Add 7 back


8770  219d87    ld      hl,#879d        ; Level / fruit data table      
8773  47        ld      b,a             ; 3 * a -> a
8774  87        add     a,a
8775  80        add     a,b
8776  d7        rst     #10             ; hl + a -> hl, (hl) -> a  [table look]

8777  320c4c    ld      (#4c0c),a       ; Write 3 fruit data bytes (shape code)
877a  23        inc     hl
877b  7e        ld      a,(hl)
877c  320d4c    ld      (#4c0d),a	; Color code
877f  23        inc     hl
8780  7e        ld      a,(hl)
8781  32d44d    ld      (#4dd4),a	; Score table offset


;    So, a little more background...
;
;    The 'R' register is the dram refresh address register
;    that is not initalized on startup, so it has garbage
;    in it.  During every instruction fetch, the counter is
;    incremented.  Assume on average 4 clock cycles per
;    instruction, with the clock running at 3.072 Mhz, this
;    counter is incremented every 1.3us, so if you read it
;    at any time, it's gonna be pretty damn random.  Of
;    course, it doesn't just get read at any time, since
;    the fruit select routine is called during the vertical
;    blank every 1/60sec, but since the instruction
;    counts between reads are not all the say, it's still
;    random to better than 1/60 sec, which is still too fast
;    for any player to count off.
;
;    So, now, assuming that the counter is random, the bottom
;    5 bits are hacked off giving a number 0-31 (each with
;    probability 1/32), and this number modulo 7 is used to
;    determine which fruit appears...
;
;    So...
;
;     0, 7,14,21,28  ->  Cherry         100 pts @ 5/32 = 15.625 % 
;     1, 8,15,22,29  ->  Strawberry     200 pts @ 5/32 = 15.625 %
;     2, 9,16,23,30  ->  Orange         500 pts @ 5/32 = 15.625 %
;     3,10,17,24,31  ->  Pretzel        700 pts @ 5/32 = 15.625 %
;     4,11,18,25     ->  Apple         1000 pts @ 4/32 = 12.5   %
;     5,12,19,26     ->  Pear          2000 pts @ 4/32 = 12.5   %
;     6,13,20,27     ->  Banana        5000 pts @ 4/32 = 12.5   %
;
;    Also interesting to note is that the expected value of
;    the random fruit is 1234.375 points, which is useful
;    in determining a good estimate of what the killscreen
;    score should be.  The standard deviation of this
;    distribution is 1532.891 / sqrt(n), where n is the
;    number of random fruits eaten, so at the level 243 (?)
;    killscreen, (243-7)*2 = 472 fruits have been eaten,
;    and the SD falls to 21.726, so it should be pretty easy
;    to tell if the fruit distribution has been tampered
;    with.  This SD across 472 fruits is +/- 10k from the
;    mean, is approximaely the difference between the top
;    3 players in twin galaxies, but given the game crash
;    issue, the number of levels the game lets you play is
;    probably a more poingant indicator than the fruits
;    given.
;
;
;
;    How to cheat:
;    -------------
;
;    Of course, if you want to be cutesy you can play with
;    the distribution, by say changing 876b to 0x3f, thus
;    doing 0-63 mod 7 to choose the fruit, bumping the
;    average up to 1337.5, but at an extra 100 points a
;    fruit, thats 47,200 points on average, and without a
;    close statistical analysis like the one I've provided
;    (which shows that this is almost 5 standard deviations
;    above the mean), you could probably get away with it
;    in competition.
;
;    If you really wanted to be cheezy, you could change
;    0x876b to 0x06, so that only cherry, orange, apple,
;    and banana come up, and all have equal probability.
;    That would bump your fruit average up to 1650, but the
;    absence of strawberries, pretzels, and pears would be
;    pretty obvious.
;
;    These changes would't require any other changes in the
;    code, but it's also possible to completely rewrite the
;    routine, in a different part of the code space to do
;    something different, but that's an exercise left to
;    the reader.  (Perhaps the simplest would be to add 3
;    after the mod 32 operation, so that Pretzel-Banana are
;    slightly more likely than Cherry-Orange).
;
;    If you really want to be lame, you can edit the scoring
;    table at 0x2b17 (many pacman bootlegs did this).
;    Seriously, you could probably add 10 points to each
;    value, and the 'judges' couldn't tell whether or not
;    you were eating a dot while eating the fruit in many
;    situations, and you could get almost 5000 extra points
;    over the entire game ;)
;
;    One other 'cool' thing to do would be to chage 0x8763
;    to 0x08, which would utilize the 8th fruit on the 8th
;    board, and subsequently would give you even odds on
;    all of the fruit, but since the junior icon and the
;    banana are both 5000, the average skews WAY up to 1812.5
;    points.
;
;    [To keep things fair, though, note that the junior
;    fruit uses color code 0x00, which is to say, all black,
;    so you'd have to find the invisible fruit.  Since the
;    fruit patterns are pretty well known, that's probably
;    not that big of a deal for top players.]


	;; select the proper fruit path from the table at 87f8

8784  21f887    ld      hl,#87f8	; load HL with fruit path entry lookup table
8787  cdcd87    call    #87cd		; set up fruit path
878a  23        inc     hl		; HL := HL + 1
878b  5e        ld      e,(hl)		; load E with table data
878c  23        inc     hl		; next table entry
878d  56        ld      d,(hl)		; load D with table data
878e  ed53d24d  ld      (#4dd2),de	; store into fruit position
8792  c9        ret			; return

; jumped from #2BF4 for fruit drawing subroutine
; A has the level number
; keeps the fruit level at banana after level 7

8793 FE 08 	CP 	#08 		; Is Level >= #08 ?
8795 DA F9 2B 	JP 	C,#2BF9 	; No, return
8798 3E 07 	LD 	A,#07 		; Yes, set A := #07
879A C3 F9 2B 	JP 	#2BF9 		; Return


	;; fruit shape/color/points table

879d  00 14 06				; Cherry     = sprite 0, color 14, score table 06
87a0  01 0f 07				; Strawberry = sprite 1, color 0f, score table 07
87a3  02 15 08				; Orange     = sprite 2, color 15, score table 08
87a6  03 07 09				; Pretzel    = sprite 3, color 07, score table 09
87a9  04 14 0a				; Apple      = sprite 4, color 14, score table 0a
87ac  05 15 0b				; Pear	     = sprite 5, color 15, score table 0b
87af  06 16 0c				; Banana     = sprite 6, color 16, score table 0c
87b2  07 00 0d				; Junior!    = sprite 7, color 00, score table 0d

	; For reference, the score table is at 0x2b17
	; arrive here from #871D

87b5  3ad34d    ld      a,(#4dd3)	; load A with fruit position
87b8  c620      add     a,#20		; add 20
87ba  fe40      cp      #40		; > 40 ?
87bc  3852      jr      c,#8810         ; yes, jump ahead and return
87be  2a424c    ld      hl,(#4c42)	; else load HL with value in #4C42 (EG. #8808, #8B71,)
87c1  110888    ld      de,#8808	; load DE with start of data table
87c4  37        scf     		; Set Carry Flag.
87c5  3f        ccf   			; Invert Carry Flag (cleared in this case)  
87c6  ed52      sbc     hl,de		; subtract DE (value = #8808) from HL
87c8  2023      jr      nz,#87ed        ; If not zero then jump ahead

87ca  210088    ld      hl,#8800	; else if zero then load HL with start of data table for fruit exit

87cd  cdbd94    call    #94bd		; load BC with valued from table based on level
87d0  69        ld      l,c		; 
87d1  60        ld      h,b		; copy BC into HL
87d2  ed5f      ld      a,r		; load A with a random number
87d4  e603      and     #03		; mask bits, now between #00 and #03
87d6  47        ld      b,a		; copy to B		
87d7  87        add     a,a		; A := A*2
87d8  87        add     a,a		; A := A*2
87d9  80        add     a,b		; A := A+B (A is now randomly #00, #05, #0A, or #0F)
87da  d7        rst     #10		; load A with (HL + A), HL := HL + A
87db  5f        ld      e,a		; copy to E
87dc  23        inc     hl		; next table entry
87dd  56        ld      d,(hl)		; load D with next value from table.  DE now has fruit path address from table.
87de  ed53424c  ld      (#4c42),de	; store DE into #4C42
87e2  23        inc     hl		; next table entry
87e3  7e        ld      a,(hl)		; load A with next value from table

87e4  32404c    ld      (#4c40),a	; store into #4C40
87e7  3e1f      ld      a,#1f		; A := #1F
87e9  32414c    ld      (#4c41),a	; store into #4C41
87ec  c9        ret     		; return

; arrive here from #87C8

87ed  210888    ld      hl,#8808	; load HL with start of table data
87f0  22424c    ld      (#4c42),hl	; store 08 88 into the addresses in #4C42 and #4C43
87f3  3e1d      ld      a,#1d		; A := #1D (resets counter)
87f5  c3e487    jp      #87e4		; jump back

	; fruit path entry lookup table.  referenced in #8784

87f8  4f 8b				; #8B4F ; fruit paths for maze 1
87fa  40 8e				; #8E40 ; fruit paths for maze 2
87fc  1a 91				; #911A ; fruit paths for maze 3
87fe  0a 94				; #940A ; fruit paths for maze 4

	; fruit path exit lookup table data used from #87CA

8800  82 8B				; #8B82 ; fruit paths for maze 1
8802  73 8E				; #8E73	; fruit paths for maze 2
8804  42 91				; #9142	; fruit paths for maze 3
8806  3c 94				; #943C	; fruit paths for maze 4

; data used from #87C1 and #87ED

8808  FA FF 55 55 01 80 AA 02		; fruit path ?


; arrive here from #87BC, when fruit exits screen on its own (not eaten)

8810  3e00      ld      a,#00		; A := #00
8812  320d4c    ld      (#4c0d),a	; store into fruit sprite entry (clears fruit)
8815  c30010    jp      #1000		; jump back to program (clears #4DD4 and returns from sub)

; check for fruit being eaten ... jumped from #19AD
; HL has pacman X,Y

8818: F5	push	af		; Save AF
8819: ED5BD24D	ld	de,(#4DD2)	; load fruit X position into D, fruit Y position into E
881D: 7C	ld	a,h		; load A with pacman X position
881E: 92	sub	d		; subtract fruit X position
881F: C6 03	add	a,#03		; add margin of error == #03
8821: FE 06	cp	#06		; X values match within margin ?
8823: 30 18	jr	nc,#883D	; no , jump back to program

8825: 7D	ld	a,l		; else load A with pacman Y values
8826: 93	sub	e		; subtract fruit Y position
8827: C6 03	add	a,#03		; add margin of error
8829: FE 06	cp	#06		; Y values match within margin?
882B: 30 10	jr	nc,#883D	; no, jump back to program

; else a fruit is being eaten

882D: 3E 01	ld	a,#01		; load A with #01
882F: 32 0D 4C	ld	(#4C0D),a	; store into fruit sprite entry
8832: F1	pop	af		; Restore AF
8833: C6 02	add	a,#02		; add 2 to A
8835: 32 0C 4C	ld	(#4C0C),a	; store into fruit sprite number
8838: D6 02	sub	#02		; sub 2 from A, make A the same as it was
883A: C3 B2 19	jp	#19B2		; jump back to program for fruit being eaten

883D: F1	pop	af		; Restore AF
883E: C3 CD 19	jp	#19CD		; jump back to program with no fruit eaten


; data used somehow with the fruit
; called from #8705


8841:     FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  
8850:  FF FF FF 00 00 FF FF 00 00 00 00 01 00 00 00 01 
8860:  00 00 00 FF FE 00 00 00 FF 00 00 FF FE 00 00 00 
8870:  FF 00 00 00 FF 00 00 00 FF 00 00 01 FF 01 FF 00
8880:  00 00 00 00 00 FF 00 00 00 00 01 00 00 FF 00 00
8890:  00 00 01 00 00 00 01 00 00 00 01 00 00 01 01 01
88A0:  01 00 00 01 00 01 00 01 00 01 00 01 00 01 00 01
88B0:  00 01 00 01 00 01 00 01 00 FF FF FF FF 00 00 FF
88C0:  FF

	;; Maze Table 1

88C1:     40 FC D0 D2 D2 D2 D2 D4 FC DA 02 DC FC FC FC
88D0:  FC FC FC DA 02 DC FC FC FC D0 D2 D2 D2 D2 D2 D2
88E0:  D2 D4 FC DA 05 DC FC DA 02 DC FC FC FC FC FC FC
88F0:  DA 02 DC FC FC FC DA 08 DC FC DA 02 E6 EA 02 E7
8900:  D2 EB 02 E7 D2 D2 D2 D2 D2 D2 EB 02 E7 D2 D2 D2
8910:  EB 02 E6 E8 E8 E8 EA 02 DC FC DA 02 DE E4 15 DE
8920:  C0 C0 C0 E4 02 DC FC DA 02 DE E4 02 E6 E8 E8 E8
8930:  E8 EA 02 E6 E8 E8 E8 EA 02 E6 EA 02 E6 EA 02 DE
8940:  C0 C0 C0 E4 02 DC FC DA 02 E7 EB 02 E7 E9 E9 E9
8950:  F5 E4 02 DE F3 E9 E9 EB 02 DE E4 02 DE E4 02 E7
8960:  E9 E9 E9 EB 02 DC FC DA 09 DE E4 02 DE E4 05 DE
8970:  E4 02 DE E4 08 DC FC FA E8 E8 EA 02 E6 E8 EA 02
8980:  DE E4 02 DE E4 02 E6 E8 E8 F4 E4 02 DE E4 02 E6
8990:  E8 E8 E8 EA 02 DC FC FB E9 E9 EB 02 DE C0 E4 02
89A0:  E7 EB 02 E7 EB 02 E7 E9 E9 F5 E4 02 E7 EB 02 DE
89B0:  F3 E9 E9 EB 02 DC FC DA 05 DE C0 E4 0B DE E4 05
89C0:  DE E4 05 DC FC DA 02 E6 EA 02 DE C0 E4 02 E6 EA
89D0:  02 EC D3 D3 D3 EE 02 DE E4 02 E6 EA 02 DE E4 02
89E0:  E6 EA 02 DC FC DA 02 DE E4 02 E7 E9 EB 02 DE E4
89F0:  02 DC FC FC FC DA 02 E7 EB 02 DE E4 02 E7 EB 02
8A00:  DE E4 02 DC FC DA 02 DE E4 06 DE E4 02 F0 FC FC
8A10:  FC DA 05 DE E4 05 DE E4 02 DC FC DA 02 DE E4 02
8A20:  E6 E8 E8 E8 F4 E4 02 CE FC FC FC DA 02 E6 E8 E8
8A30:  F4 E4 02 E6 E8 E8 F4 E4 02 DC 00 

	;; Pellet table for maze 1

8A3B:                                   62 02 01 13 01
8A40:  01 01 02 01 04 03 13 06 04 03 01 01 01 01 01 01
8A50:  01 01 01 01 01 01 01 01 01 01 01 01 01 06 04 03
8A60:  10 03 06 04 03 10 03 06 04 01 01 01 01 01 01 01
8A70:  0C 03 01 01 01 01 01 01 07 04 0C 03 06 07 04 0C
8A80:  03 06 04 01 01 01 04 0C 01 01 01 03 01 01 01 04
8A90:  03 04 0F 03 03 04 03 04 0F 03 03 04 03 01 01 01
8AA0:  01 0F 01 01 01 03 04 03 19 04 03 19 04 03 01 01
8AB0:  01 01 0F 01 01 01 03 04 03 04 0F 03 03 04 03 04
8AC0:  0F 03 03 04 01 01 01 04 0C 01 01 01 03 01 01 01
8AD0:  07 04 0C 03 06 07 04 0C 03 06 04 01 01 01 01 01
8AE0:  01 01 0C 03 01 01 01 01 01 01 04 03 10 03 06 04
8AF0:  03 10 03 06 04 03 01 01 01 01 01 01 01 01 01 01
8B00:  01 01 01 01 01 01 01 01 01 06 04 03 13 06 04 02
8B10:  01 13 01 01 01 02 01 00 00 00 00 00 00 00 00 00
8B20:  00 00 00 00 00 00 00 00 00 00 00 00

	;; number of pellets to eat for maze 1

8b2c  e0				; #E0 = 224 decimal

	;; ghost destination table for maze 1

8B2D  1d 22				; column 22, row 1D (top right)
8B2F  1d 39				; column 39, row 1D (top left)
8B31  40 20				; column 20, row 40 (bottom right)
8B33  40 3b				; column 3B, row 40 (bottom left)


	;; Power Pellet Table for maze 1 (screen locations)

8b35  63 40 				; #4063 = location of upper right power pellet
8b37  7c 40				; #407C = location of lower right power pellet
8b39  83 43				; #4383	= location of upper left power pellet
8b3b  9c 43				; #439C = location of lower left power pellet


; data table used for drawing slow down tunnels on levels 1 and 2

8B3D  49 09 17
8B40  09 17 09 0E E0 E0 E0 29 09 17 09 17 09 00 00 


	;; entrance fruit paths for maze 1:  #8b4f - #8b81

8B4F  63 8B				; #8B63
8B51  13 94 0C
8B54  68 8B				; #8B68
8B56  22 94 F4
8B59  71 8B				; #8B71
8B5B  27 4C F4
8B5E  7B 8B				; #8B7B
8B60  1C 4C 0C
8B63  80 AA AA BF AA
8B68  80 0A 54 55 55 55 FF 5F 55
8B71  EA FF 57 55 F5 57 FF 15 40 55
8B7B  EA AF 02 EA FF FF AA

	;; exit fruit paths for maze 1

8B82  94 8B				; #8B94
8B84  14 00 00
8B87  99 8B				; #8B99
8B89  17 00 00
8B8C  9F 8B				; #8B9F
8B8E  1A 00 00
8B91  A6 8B				; #8BA6
8B93  1D
8B94  55 40 55 55 BF 
8B99  AA 80 AA AA BF AA
8B9F  AA 80 AA 02 80 AA AA 
8BA6  55 00 00 00 55 55 FD AA


	;; Maze 2 Table


8BAE:                                            40 FC
8BB0:  DA 02 DE D8 D2 D2 D2 D2 D2 D2 D2 D6 D8 D2 D2 D2
8BC0:  D2 D4 FC FC FC FC DA 02 DE D8 D2 D2 D2 D2 D4 FC
8BD0:  DA 02 DE E4 08 DE E4 05 DC FC FC FC FC DA 02 DE
8BE0:  E4 05 DC FC DA 02 DE E4 02 E6 E8 E8 E8 EA 02 DE
8BF0:  E4 02 E6 EA 02 E7 D2 D2 D2 D2 EB 02 E7 EB 02 E6
8C00:  EA 02 DC FC DA 02 DE E4 02 DE F3 E9 E9 EB 02 DE
8C10:  E4 02 DE E4 0C DE E4 02 DC FC DA 02 DE E4 02 DE
8C20:  E4 05 DE E4 02 DE F2 E8 E8 E8 EA 02 E6 EA 02 E6
8C30:  E8 E8 F4 E4 02 DC FC DA 02 E7 EB 02 DE E4 02 E6
8C40:  EA 02 E7 EB 02 E7 E9 E9 E9 E9 EB 02 DE E4 02 E7
8C50:  E9 E9 E9 EB 02 DC FC DA 05 DE E4 02 DE E4 0C DE
8C60:  E4 08 DC FC FA E8 E8 EA 02 DE E4 02 DE F2 E8 E8
8C70:  E8 E8 EA 02 E6 E8 E8 EA 02 DE F2 E8 E8 EA 02 E6
8C80:  EA 02 DC FC FB E9 E9 EB 02 E7 EB 02 E7 E9 E9 E9
8C90:  E9 E9 EB 02 E7 E9 F5 E4 02 DE F3 E9 E9 EB 02 DE
8CA0:  E4 02 DC FC DA 12 DE E4 02 DE E4 05 DE E4 02 DC
8CB0:  FC DA 02 E6 EA 02 E6 E8 E8 E8 E8 EA 02 EC D3 D3
8CC0:  D3 EE 02 E7 EB 02 E7 EB 02 E6 EA 02 DE E4 02 DC
8CD0:  FC DA 02 DE E4 02 E7 E9 E9 E9 F5 E4 02 DC FC FC
8CE0:  FC DA 08 DE E4 02 E7 EB 02 DC FC DA 02 DE E4 06
8CF0:  DE E4 02 F0 FC FC FC DA 02 E6 E8 E8 E8 EA 02 DE
8D00:  E4 05 DC FC DA 02 DE F2 E8 E8 E8 EA 02 DE E4 02
8D10:  CE FC FC FC DA 02 DE C0 C0 C0 E4 02 DE F2 E8 E8
8D20:  EA 02 DC 00 00 00 00

	;; Pellet table for maze 2

8D27:                       66 01 01 01 01 01 03 01 01
8D30:  01 0B 01 01 07 06 03 03 0A 03 07 06 03 03 01 01
8D40:  01 01 01 01 01 01 01 01 03 07 03 01 01 01 03 07
8D50:  03 06 07 03 03 03 07 03 06 07 03 03 01 01 01 01
8D60:  01 01 01 01 01 01 03 01 01 01 01 01 01 07 03 0D
8D70:  06 03 07 03 0D 06 03 04 01 01 01 01 01 01 0D 03
8D80:  01 01 01 03 04 03 10 03 03 03 04 03 10 01 01 01
8D90:  03 03 04 03 01 01 01 01 12 01 01 01 04 07 15 04
8DA0:  07 15 04 03 01 01 01 01 12 01 01 01 04 03 10 01
8DB0:  01 01 03 03 04 03 10 03 03 03 04 01 01 01 01 01
8DC0:  01 0D 03 01 01 01 03 07 03 0D 06 03 07 03 0D 06
8DD0:  03 07 03 03 01 01 01 01 01 01 01 01 01 01 03 01
8DE0:  01 01 01 01 01 07 03 03 03 07 03 06 07 03 01 01
8DF0:  01 03 07 03 06 07 06 03 03 01 01 01 01 01 01 01
8E00:  01 01 01 03 07 06 03 03 0A 03 08 01 01 01 01 01
8E10:  03 01 01 01 0B 01 01                            

	;; number of pellets to eat for map 2

8e17  f4				; #F4 = 244 decimal


	;; destination table for maze 2

8e18  1d 22 				; column 22, row 1D (top right)
8e1A  1d 39				; column 39, row 1D (top right)
8e1C  40 20				; column 20, row 40 (bottom right)
8e1E  40 3b				; column 3B, row 40 (bottom left)

	;; Power Pellet Table for maze 2 screen locations

8e20  65 40				; #4065 = power pellet upper right
8e22  7b 40				; #407B = power pellet lower right
8e24  85 43				; #4385 = power pellet upper left
8e26  9b 43				; #439B = power pellet lower left


; data table used for drawing slow down tunnels on level 3

8E28  42 16 0A 16 0A 16 0A 20
8E30  30 20 20 DE E0 22 20 20 20 20 16 0A 16 16 00 00


	;; entrance fruit paths for maze 2:  #8E40-8E72

8E40  54 8E				; #8E54
8E42  13 C4 0C
8E45  59 8E				; #8E59
8E47  1E C4 F4
8E4A  61 8E				; #8E61
8E4C  26 14 F4
8E4F  6B 8E 				; #8E6B
8E51  1D 14 0C
8E54  02 AA AA 80 2A 
8E59  02 40 55 7F 55 15 50 05 
8E61  EA FF 57 55 F5 FF 57 7F 55 05 
8E6B  EA FF FF FF EA AF AA 02 


	;; exit fruit paths for maze 2

8E73  87 8E				; #8E87
8E75  12 00 00
8E78  8C 8E				; #8E8C
8E7A  1D 00 00
8E7D  94 8E				; #8E94
8E7F  21 00 00
8E82  9D 8E				; #8E9D
8E84  2C 00 00 
8E87  55 7F 55 D5 FF 
8E8C  AA BF AA 2A A0 EA FF FF 
8E94  AA 2A A0 02 00 00 A0 AA 02 
8E9D  55 15 A0 2A 00 54 05 00 00 55 FD 


	;; Maze Table 3

8EA8:                          40 FC D0 D2 D2 D2 D2 D2
8EB0:  D2 D6 E4 02 E7 D2 D2 D2 D2 D2 D2 D2 D2 D2 D2 D6
8EC0:  D8 D2 D2 D2 D2 D2 D2 D2 D4 FC DA 07 DE E4 0D DE
8ED0:  E4 08 DC FC DA 02 E6 E8 E8 EA 02 DE E4 02 E6 E8
8EE0:  E8 EA 02 E6 E8 E8 E8 EA 02 E7 EB 02 E6 EA 02 E6
8EF0:  EA 02 DC FC DA 02 DE F3 E9 EB 02 E7 EB 02 E7 E9
8F00:  F5 E4 02 E7 E9 E9 F5 E4 05 DE E4 02 DE E4 02 DC
8F10:  FC DA 02 DE E4 09 DE E4 05 DE E4 02 E6 E8 E8 F4
8F20:  E4 02 DE E4 02 DC FC DA 02 DE E4 02 E6 E8 E8 E8
8F30:  E8 EA 02 E7 EB 02 E6 EA 02 E7 EB 02 E7 E9 E9 E9
8F40:  EB 02 E7 EB 02 DC FC DA 02 DE E4 02 E7 E9 E9 E9
8F50:  F5 E4 05 DE E4 0E DC FC DA 02 DE E4 06 DE E4 02
8F60:  E6 E8 E8 F4 E4 02 E6 E8 E8 E8 EA 02 E6 E8 E8 E8
8F70:  E8 E8 F4 FC DA 02 E7 EB 02 E6 E8 EA 02 E7 EB 02
8F80:  E7 E9 E9 E9 EB 02 DE F3 E9 E9 EB 02 DE F3 E9 E9
8F90:  E9 E9 F5 FC DA 05 DE C0 E4 0B DE E4 05 DE E4 05
8FA0:  DC FC FA E8 E8 EA 02 DE C0 E4 02 E6 EA 02 EC D3
8FB0:  D3 D3 EE 02 DE E4 02 E6 EA 02 DE E4 02 E6 EA 02
8FC0:  DC FC FB E9 E9 EB 02 E7 E9 EB 02 DE E4 02 DC FC
8FD0:  FC FC DA 02 E7 EB 02 DE E4 02 E7 EB 02 DE E4 02
8FE0:  DC FC DA 09 DE E4 02 F0 FC FC FC DA 05 DE E4 05
8FF0:  DE E4 02 DC FC DA 02 E6 E8 E8 E8 E8 EA 02 DE E4
9000:  02 CE FC FC FC DA 02 E6 E8 E8 F4 E4 02 E6 E8 E8
9010:  F4 E4 02 DC 00 00 00 00 

	;; Pellet table for maze 3

9018:                          62 01 02 01 01 03 01 01
9020:  01 01 01 01 01 01 01 01 01 04 01 01 01 01 01 04
9030:  05 03 0B 03 03 03 04 05 03 0B 01 01 01 03 03 04
9040:  03 01 01 01 01 01 0B 06 03 04 03 10 06 03 04 03
9050:  10 01 01 01 01 01 01 01 01 01 04 03 01 01 01 01
9060:  0F 0A 03 04 0F 0A 01 01 01 04 0C 01 01 01 03 01
9070:  01 01 07 04 0C 03 03 03 07 04 0C 03 03 03 04 01
9080:  01 01 01 01 01 01 0C 03 01 01 01 03 04 07 15 04
9090:  07 15 04 01 01 01 01 01 01 01 0C 03 01 01 01 03
90A0:  07 04 0C 03 03 03 07 04 0C 03 03 03 04 01 01 01
90B0:  04 0C 01 01 01 03 01 01 01 04 03 04 0F 0A 03 01
90C0:  01 01 01 0F 0A 03 10 01 01 01 01 01 01 01 01 01
90D0:  04 03 10 06 03 04 03 01 01 01 01 01 0B 06 03 04
90E0:  05 03 0B 01 01 01 03 03 04 05 03 0B 03 03 03 04
90F0:  01 02 01 01 03 01 01 01 01 01 01 01 01 01 01 01
9100:  04 01 01 01 01 01 00 00 00

	;; number of pellets to eat for maze 3

9109  f2				; #F2 = 242 decimal

	;; destination table for maze 3

910A  40 2d				; column 2d, row 40 (bottom center)
910C  1d 22				; column 22, row 1D (top right)
910E  1d 39				; column 39, row 1D (top left)
9110  40 20				; column 20, row 40 (bottom right)

	;; Power Pellet Table 3

9112  64 40				; #4064
9114  78 40				; #4078
9116  84 43				; #4384
9118  98 43				; #4398

	;; entrance fruit paths for maze 3:  #911A-9141

911A  2E 91				; #912E
911C  15 54 0C 
911F  34 91				; #9134
9121  1E 54 F4
9124  34 91				; #9134
9126  1E 54 F4
9129  3C 91				; #913C
912B  15 54 0C

912E  EA FF AB FA AA AA
9134  EA FF 57 55 55 D5 57 55 
913C  AA AA BF FA

	;; exit fruit paths for maze 3

9142  56 91				; #9156
9144  22 00 00
9147  5f 91				; #915F
9149  25 00 00
914C  5f 91				; #915F
914E  25 00 00
9151  6f 91				; #916F
9153  28 00 00

9156  05 00 00 54 05 54 7F F5 0B
915F  0A 00 00 A8 0A A8 BF FA AB AA AA 82 AA 00 A0 AA
916F  55 41 55 00 A0 02 40 F5 57 BF


	;; Maze Table 4

9179:                             40 FC D0 D2 D2 D2 D2
9180:  D2 D2 D2 D2 D4 FC FC DA 02 DE E4 02 DC FC FC FC
9190:  FC D0 D2 D2 D2 D2 D2 D2 D2 D4 FC DA 09 DC FC FC
91A0:  DA 02 DE E4 02 DC FC FC FC FC DA 08 DC FC DA 02
91B0:  E6 E8 E8 E8 E8 EA 02 E7 D2 D2 EB 02 DE E4 02 E7
91C0:  D2 D2 D2 D2 EB 02 E6 E8 E8 E8 EA 02 DC FC DA 02
91D0:  E7 E9 E9 E9 F5 E4 07 DE E4 09 DE F3 E9 E9 EB 02
91E0:  DC FC DA 06 DE E4 02 E6 EA 02 E6 E8 F4 F2 E8 EA
91F0:  02 E6 E8 E8 EA 02 DE E4 05 DC FC DA 02 E6 E8 EA
9200:  02 E7 EB 02 DE E4 02 E7 E9 E9 E9 E9 EB 02 E7 E9
9210:  F5 E4 02 E7 EB 02 E6 EA 02 DC FC DA 02 DE C0 E4
9220:  05 DE E4 0B DE E4 05 DE E4 02 DC FC DA 02 DE C0
9230:  E4 02 E6 E8 E8 F4 F2 E8 E8 EA 02 E6 E8 E8 E8 EA
9240:  02 DE E4 02 E6 E8 E8 F4 E4 02 DC FC DA 02 E7 E9
9250:  EB 02 E7 E9 E9 F5 F3 E9 E9 EB 02 E7 E9 E9 F5 E4
9260:  02 E7 EB 02 E7 E9 E9 F5 E4 02 DC FC DA 09 DE E4
9270:  08 DE E4 08 DE E4 02 DC FC DA 02 E6 E8 E8 E8 E8
9280:  EA 02 DE E4 02 EC D3 D3 D3 EE 02 DE E4 02 E6 E8
9290:  E8 E8 EA 02 DE E4 02 DC FC DA 02 DE F3 E9 E9 E9
92A0:  EB 02 E7 EB 02 DC FC FC FC DA 02 E7 EB 02 E7 E9
92B0:  E9 F5 E4 02 E7 EB 02 DC FC DA 02 DE E4 09 F0 FC
92C0:  FC FC DA 08 DE E4 05 DC FC DA 02 DE E4 02 E6 E8
92D0:  E8 E8 E8 EA 02 CE FC FC FC DA 02 E6 E8 E8 E8 EA
92E0:  02 DE E4 02 E6 E8 E8 F4 00 00 00 00 

	;; Pellet table for maze 4

92EC:                                      62 01 02 01
92F0:  01 01 01 0F 01 01 01 02 01 04 07 0F 06 04 07 01
9300:  01 01 07 01 01 01 01 01 06 04 01 01 01 01 03 03
9310:  07 05 03 01 01 01 04 04 03 03 07 05 03 03 04 04
9320:  01 01 01 03 01 01 01 01 01 01 01 01 01 03 01 01
9330:  01 03 04 04 0F 03 06 04 04 0F 03 06 04 01 01 01
9340:  01 01 01 01 0C 01 01 01 01 01 01 03 04 07 12 03
9350:  04 07 12 03 04 03 01 01 01 01 12 01 01 01 04 03
9360:  16 07 03 16 07 03 01 01 01 01 12 01 01 01 04 07
9370:  12 03 04 07 12 03 04 01 01 01 01 01 01 01 0C 01
9380:  01 01 01 01 01 03 04 04 0F 03 06 04 04 0F 03 06
9390:  04 04 01 01 01 03 01 01 01 01 01 01 01 01 01 03
93A0:  01 01 01 03 04 04 03 03 07 05 03 03 04 01 01 01
93B0:  01 03 03 07 05 03 01 01 01 04 07 01 01 01 07 01
93C0:  01 01 01 01 06 04 07 0F 06 04 01 02 01 01 01 01
93D0:  0F 01 01 01 02 01 00 00 00 00 00 00 00 00 00 00
93E0:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
93F0:  00 00 00 00 00 00 00 00 00

	;; number of pellets to eat for maze 4

93F9  EE				; #EE = 238 decimal

	;; Power Pellet Table for maze 4
  
93fa  64 40				; #4064
93fc  7c 40				; #407C
93fe  84 43				; #4384
9400  9c 43				; #439C

	;; destination table for maze 4

9402  1d 22				; column 22, row 1D (top right)
9404  40 20				; column 20, row 40 (bottom right)
9406  1d 39				; column 39, row 1D (top left)
9408  40 3b				; column 3B, row 40 (bottom left)

	;; entrance fruit paths for maze 4:  #940A - #943B

940A   1E 94				; #941E
940C   14 8C 0C
940F   23 94				; #9423
9411   1D 8C F4
9414   2B 94				; #942B
9416   2A 74 F4
9419   36 94				; #9436
941B   15 74 0C
941E   80 AA BE FA AA
9423   00 50 FD 55 F5 D5 57 55 
942B   EA FF 57 D5 5F FD 15 50 01 50 55
9436   EA AF FE 2A A8 AA


	;; exit fruit paths for maze 4

943c  50 94				; #9450
943e  15 00 00
9441  56 94				; #9456
9443  18 00 00
9446  5C 94				; #945C
9448  19 00 00	
944b  63 94				; #9463
944d  1C 00 00

9450  55 50 41 55 FD AA
9456  AA A0 82 AA FE AA
945C  AA AF 02 2A A0 AA AA
9463  55 5F 01 00 50 55 BF


	; select the proper maze
	; called from #241C
	

946a  217494    ld      hl,#9474	; load HL with address of maze table number
946d  cdbd94    call    #94bd		; load BC based on the maze
9470  210040    ld      hl,#4000	; load HL with start of video RAM
9473  c9        ret     		; return

	; maze reference table

9474  c1 88				; #88C1 for maze 1
9476  ae 8b				; #8BAE for maze 2
9478  a8 8e				; #8EA8 for maze 3
947a  79 91				; #9179 for maze 4


	; pellet crossreference routine patch
	; arrive from #244b

947c  215324    ld      hl,#2453	; load HL with return address
947f  1803      jr      #9484           ; skip next step

	; arrive here from #248A

9481  219224    ld      hl,#2492	; load HL with return address

9484  e5        push    hl		; push HL to stack for return address (either #2453 or #2492)
9485  219994    ld      hl,#9499	; load HL with pellet map lookup table address
9488  cdbd94    call    #94bd		; load BC with value based on the level
948b  fd210000  ld      iy,#0000	; IY = #0000
948f  fd09      add     iy,bc		; add BC into IY
9491  210040    ld      hl,#4000	; load HL with start of video RAM
9494  dd21164e  ld      ix,#4e16	; load IX with pellet entries
9498  c9        ret     		; return (returns to either #2453 or #2492)

	; Pellet map lookup table

9499  3b 8a				; #8A3B	; pellets for maze 1
949c  27 8d				; #8D27	; pellets for maze 2
949d  18 90				; #9018	; pellets for maze 3
949f  ec 92				; #92EC	; pellets for maze 4

	;; check the number of pellets to see if the board is cleared

94a0  c5        push    bc  		; junk ?

94a1  c5	push 	bc		; save BC
94a2  21b594    ld      hl,#94b5	; load HL with pellet count table
94a5  cdbd94    call    #94bd		; load BC based on board #
94a8  0a        ld      a,(bc)		; load A with number of pellets needed to eat
94a9  47        ld      b,a		; copy to B
94aa  3a0e4e    ld      a,(#4e0e)	; load A with # of pellets eaten
94ad  b8        cp      b		; is the board done ?
94ae  c1        pop     bc		; restore BC
94af  c2eb08    jp      nz,#08eb	; if not done, return to the game loop
94b2  c3e508    jp      #08e5		; else return to the program and signal end of level

	; lookup table for pellet count information

94b5  2c 8b 				; #8B2C holds number of pellets for maze 1
94b7  17 8e				; #8E17 holds number of pellets for maze 2
94b8  09 91				; #9109 holds number of pellets for maze 3
94bb  f9 93				; #93F9 holds number of pellets for maze 4

; Used to determine which maze to draw and other things
; load BC with a value based on the level and the value already loaded into HL.
; This keeps the game cycling between the 3rd and 4th mazes, which appear on levels 6 through 14.

94BD 3A 13 4E	LD	A,(#4E13) 	; Load A with level number
94C0 E5 	PUSH	HL 		; Save HL
94C1 FE 0D 	CP	#0D 		; Is level number > #0D (13 decimal) ?
94C3 F2 D4 94 	JP	P,#94D4 	; Yes, jump to subroutine to makes the result in A become between 0 and #0D [Bug, should be JP NC, not JP P]
94C6 21 DF 94 	LD	HL,#94DF 	; No, load HL with map order table
94C9 D7 	RST	#10 		; A now contains the map number
94CA E1 	POP	HL 		; Get HL that was saved earlier 
94CB 87 	ADD	A,A 		; A := A*2
94CC 4F 	LD	C,A 		; Load C with A
94CD 06 00	LD	B,#00 		; Load B with #00
94CF 09 	ADD	HL,BC 		; Add this value into HL
94D0 4E 	LD	C,(HL) 		; Load C with table value from HL
94D1 23 	INC	HL 		; Next table value
94D2 46 	LD	B,(HL) 		; Load B with table value from HL
94D3 C9 	RET 			; Return

94D4 D6 0D 	SUB 	#0D 		; Subtract #0D (13 decimal) from A
94D6 D6 08 	SUB 	#08 		; Subtract #08 from A. Is A > 0 ?
94D8 F2 D6 94 	JP 	P,#94D6 	; Yes, then repeat previous subtraction [Bug, should be JP NC, not JP P]
94DB C6 0D 	ADD 	A,#0D 		; No, add #0D (13 decimal) back into A
94DD 18 E7 	JR 	#94C6 		; Return to program

	;; map order table.  order that boards are played, used in subroutine above at #94C6

94DF  00 00				; 1st & 2nd boards use maze 1
94E1  01 01 01				; 3rd, 4th, 5th boards use maze 2
94E4  02 02 02 02			; boards 6 through 9 use maze 3
94E8  03 03 03 03			; boards 10 through 13 use maze 4

	;; draw routine for the ms-pac power pellets
	; arrive from #2472

94ec  211c95    ld      hl,#951c	; load HL with power pellet lookup table
94ef  cdbd94    call    #94bd		; load BC with value based on level from the table
94f2  11344e    ld      de,#4e34	; load DE with pellet graphic table data
94f5  69        ld      l,c
94f6  60        ld      h,b		; HL now has BC = table start

94f7  4e        ld      c,(hl)		; load C with first data
94f8  23        inc     hl		; next location
94f9  46        ld      b,(hl)		; load B with second data.  BC now has screen location to draw power pellet
94fa  23        inc     hl		; next location
94fb  1a        ld      a,(de)		; load A with pellet graphic data (should always be #14)
94fc  02        ld      (bc),a		; draw the power pellet onscreen
94fd  13        inc     de		; next location
94fe  3e03      ld      a,#03		; A := #03
9500  a3        and     e		; mask with E
9501  20f4      jr      nz,#94f7        ; if not zero, loop again
9503  c9        ret     		; return

	; ms pac man patch for pellet routine
	; jumped from #24b4
	; arrive here after ms. pac has died
	; this sub is identical to subroutine above, except it saves the power pellets instead of drawing them

9504  211c95    ld      hl,#951c	; load HL with power pellet lookup table
9507  cdbd94    call    #94bd		; load BC with value based on level from the table
950a  11344e    ld      de,#4e34	; load DE with pellet graphic table data
950d  69        ld      l,c		; 
950e  60        ld      h,b		; HL now has BC = table start

950f  4e        ld      c,(hl)
9510  23        inc     hl
9511  46        ld      b,(hl)		; BC now has screen loaciton of power pellet
9512  23        inc     hl
9513  0a        ld      a,(bc)		; load A with power pellet from screen
9514  12        ld      (de),a		; save into DE
9515  13        inc     de		; next location
9516  3e03      ld      a,#03		; A := #03
9518  a3        and     e		; mask with E
9519  20f4      jr      nz,#950f        ; if not zero, loop again
951b  c9        ret     		; return (to #0915)

	; power pellet lookup table per map

951c  35 8b				; #8B35	; maze 1 power pellet address table
951e  20 8e				; #8E20	; maze 2 power pellet address table
9520  12 91				; #9112	; maze 3 power pellet address table
9522  fa 93				; #93FA	; maze 4 power pellet address table

; this subroutine flashes the power pellets
; arrive from #0C21

9524  c5        push    bc		; save BC
9525  d5        push    de		; save DE
9526  211c95    ld      hl,#951c	; load HL with power pellet lookup table start
9529  cdbd94    call    #94bd		; load BC with address of power pellet table based on map played
952c  60        ld      h,b
952d  69        ld      l,c		; load HL with BC
952e  5e        ld      e,(hl)		; 
952f  23        inc     hl
9530  56        ld      d,(hl)		; load DE with the screen location of the first power pellet
9531  eb        ex      de,hl		; Copy to HL
9532  cbd4      set     2,h		; convert the screen address to a color address

9534  3a7e44    ld      a,(#447e)	; load A with the graphic for power pellets
9537  be        cp      (hl)		; compare with value in HL
9538  2002      jr      nz,#953c        ; if not zero then skip next step
953a  3e00      ld      a,#00		; else A := #00 (used for clearing the power pellets every other time)

953c  77        ld      (hl),a		; flash the power pellet
953d  eb        ex      de,hl
953e  23        inc     hl
953f  5e        ld      e,(hl)
9540  23        inc     hl
9541  56        ld      d,(hl)
9542  cbd2      set     2,d
9544  12        ld      (de),a		; flash the power pellet
9545  23        inc     hl
9546  5e        ld      e,(hl)
9547  23        inc     hl
9548  56        ld      d,(hl)
9549  cbd2      set     2,d
954b  12        ld      (de),a		; flash the power pellet
954c  23        inc     hl
954d  5e        ld      e,(hl)
954e  23        inc     hl
954f  56        ld      d,(hl)
9550  cbd2      set     2,d
9552  12        ld      (de),a		; flash the power pellet
9553  d1        pop     de		; restore DE
9554  c1        pop     bc		; restore BC
9555  3e10      ld      a,#10		; A := #10
9557  be        cp      (hl)		; 
9558  c9        ret     		; return (to #0906)

; arrive here for blue ghost logic when random mode enabled from #27BB

9559  3a2e4d    ld      a,(#4d2e)	; load A with blue ghost (inky) orientation
955c  1803      jr      #9561           ; skip ahead to pick a destination

; arrive here for orange ghost logic when random mode enabled from #2803

955e  3a2f4d    ld      a,(#4d2f)	; load A with orange ghost direction

	;; pick a quadrant for the destination of a ghost, saved into DE

9561  f5        push    af		; save AF
9562  c5        push    bc		; save BC
9563  e5        push    hl		; save HL
9564  217895    ld      hl,#9578	; load HL with ghost destination table
9567  cdbd94    call    #94bd		; load BC based on level and HL
956a  69        ld      l,c		; 
956b  60        ld      h,b		; load HL with BC
956c  ed5f      ld      a,r		; load A with random number from refresh register
956e  e606      and     #06		; mask bits.  result is either 0,2,4, or 6
9570  d7        rst     #10		; HL := HL + A, A := HL.  loads first value from table
9571  5f        ld      e,a		; store into E
9572  23        inc     hl		; next table entry
9573  56        ld      d,(hl)		; load D with this value
9574  e1        pop     hl		; restore HL
9575  c1        pop     bc		; restore BC
9576  f1        pop     af		; restore AF
9577  c9        ret     		; return

	; ghost destination table

9578  2d 8b				; #8B2D	; 1st maze
957a  18 8e				; #8E18	; 2nd maze
957c  0a 91				; #910A	; 3rd maze
957e  02 94				; #9402	; 4th maze

	; maze color code (jump from 24dd)

9580  cae124    jp      z,#24e1		; if zero then return immediately, used for color white flashing at end of level
9583  3a024e    ld      a,(#4e02)	; load A with main routine 1, subroutine #
9586  a7        and     a		; == #00 ?  
9587  2807      jr      z,#9590         ; yes, skip ahead to select the color to use based on the board number
9589  fe10      cp      #10		; == #10 ?  Is the game in the demo maze ?
958b  3e01      ld      a,#01		; load A with 1.  used to properly color the midway logo
958d  c2e124    jp      nz,#24e1	; no, return to program

; controls the color of the mazes

9590 3A 13 4E 	LD 	A,(#4E13) 	; Load A with board number
9593 FE 15 	CP 	#15 		; Is this board > #15 (21 decimal) ?
9595 F2 A3 95 	JP 	P,#95A3 	; Yes, go and bring it back down to a number between #5 and #15 [Bug.  should JP NC, not JP P]
9598 4F 	LD 	C,A 		; Load C with A
9599 06 00 	LD 	B,#00		; Load B with zero
959B 21 AE 95 	LD 	HL,#95AE 	; load HL with map color table
959E 09 	ADD 	HL,BC		; Add the offset computed from level
959F 7E 	LD 	A,(HL)		; A now contains the maze color
95A0 C3 E1 24 	JP 	#24E1		; Jump back to program

95A3 D6 15 	SUB 	#15 		; Subtract #15 from A
95A5 D6 10 	SUB 	#10 		; Subtract #10 from A
95A7 F2 A5 95 	JP 	P,#95A5 	; Did we just go negative? No, go back and subtract another 10.  [Bug.  should be JP NC, not JP P]
95AA C6 15 	ADD 	A,#15 		; Yes, Add #15 back into A
95AC 18 EA 	JR 	#9598 		; Return


	;; color palette table for the first 21 mazes

95AE  1d 1d				; color code for levels 1 and 2
95B0  16 16 16				; color code for levels 3, 4, 5
95B3  14 14 14 14			; color code for levels 6 - 9
95B7  07 07 07 07			; color code for levels 10 - 13
95BB  18 18 18 18			; color code for levels 14 - 17
95BF  1d 1d 1d 1d 			; color code for levels 18 - 21


; sets bit 6 in the color grid of certain screen locations on the first three levels.
; This color bit is ignored when actually coloring the grid, so it is invisible onscreen.
; When a ghost encounters one of these specially painted areas, he slows down.
; This is used to slow down the ghosts when they use the tunnels on these levels. 
; called from #24F9

95C3 3A 13 4E 	LD 	A,(#4E13) 	; Load A with current level number
95C6 FE 03 	CP 	#03 		; Is A < #03 ?
95C8 F2 34 25 	JP 	P,#2534 	; No, jump back to program [bug.  should be JP NC, not JP P.]
95CB 21 DF 95 	LD 	HL,#95DF 	; Yes, load HL with start of table data address
95CE CD BD 94 	CALL 	#94BD 		; Load BC with either #95DF or #95E1 depending on the level
95D1 21 00 44 	LD 	HL,#4400 	; Load HL with start of color memory
95D4 0A 	LD 	A,(BC) 		; Load A with the table data
95D5 03 	INC 	BC 		; Set BC to next value in table
95D6 A7 	AND 	A 		; Is A == 0 ?
95D7 CA 34 25 	JP 	Z,#2534 	; Yes, jump back to program
95DA D7 	RST 	#10 		; No, load A with table value of (HL + A) and load HL with HL + A
95DB CB F6 	SET 	6,(HL) 		; Sets bit 6 of HL - MAKE tunnel slow for ghosts
95DD 18 F5 	JR 	#95D4 		; Loop back and do again

95DF 3D 8B 				; #83BD Pointer to table for tunnel data for levels 1 and 2
95E1 28 8E 				; #8E28 Pointer to table for tunnel data for level 3


	; called from #23A7 for task = #1C
	; prints text or graphics based on parameter loaded into B

95E3: 78	ld	a,b		; load A with parameter
95E4: FE 0A	cp	#0A		; == #0A ?
95e6  cc0b96    call    z,#960b		; Yes, draw the MS PAC MAN graphic which appears between "ADDITIONAL" and "AT 10,000 pts"
95e9  fe0b      cp      #0b		; == #0B ?
95eb  ccf695    call    z,#95f6		; yes, draw midway logo and copyright text
95ee  fe06      cp      #06		; == #06 ?   ( code for "READY!" )
95f0  cc3c96    call    z,#963c		; yes, clear the intermission indicator
95f3  c35e2c    jp      #2c5e		; jump to print routine

	
95f6  c5        push    bc		; save BC
95f7  e5        push    hl		; save HL
95f8  cd4296    call    #9642		; draw the midway logo and copyright text for the 'press start' screen
95fb  e1        pop     hl		; restore HL
95fc  c1        pop     bc		; resore BC

	; check for dip switch settings if there are extra lives awarded

95fd  3a8050    ld      a,(#5080)	; load A with Dip switches
9600  e630      and     #30		; mask bits
9602  fe30      cp      #30		; are bits 4 and 5 on ?   This happens when there is no bonus life awarded.
9604  78        ld      a,b		; A := B
9605  c0        ret     nz		; no, return

9606  3e20      ld      a,#20		; yes, A := #20
9608  0620      ld      b,#20		; B := #20
960a  c9        ret     		; return (to #95EE)

	; table subroutine

960b  c5        push    bc		; save BC
960c  e5        push    hl		; save HL
960d  211696    ld      hl,#9616	; load HL with start of table data
9610  cd2796    call    #9627		; draws the MS PAC MAN graphic which appears between "ADDITIONAL" and "AT 10,000 pts" 
9613  e1        pop     hl		; restore HL
9614  c1        pop     bc		; restore BC
9615  c9        ret     		; return

	; table data, used in sub below to draw MS PAC graphic
	; first byte is color, 2nd byte is graphic code, third & fourth are screen locations

9616  09 20 f5 41 			; screen location #41F5
961a  09 21 15 42			; screen location #4215
961e  09 22 f6 41 			; screen location #41F6
9622  09 23 16 42 			; screen location #4216
9626  ff

	; subroutine for start button press
	; called from #9610
	; draws the MS PAC MAN which appears between "ADDITIONAL" and "AT 10,000 pts"

9627  7e        ld      a,(hl)		; load A with table data
9628  feff      cp      #ff		; are we done?
962a  280f      jr      z,#963b         ; yes, return
962c  47        ld      b,a		; else load B with this first data byte
962d  23        inc     hl		; next table entry
962e  7e        ld      a,(hl)		; load A with next data
962f  23        inc     hl		; next table entry
9630  5e        ld      e,(hl)		; load E with next data
9631  23        inc     hl		; next table entry
9632  56        ld      d,(hl)		; load D with next data
9633  12        ld      (de),a		; Draws element to screen
9634  78        ld      a,b		; load A with B
9635  cbd2      set     2,d		; set bit 2 of D.  changes DE to color grid
9637  12        ld      (de),a		; store A into color grid
9638  23        inc     hl		; next table entry
9639  18ec      jr      #9627           ; loop again
963b  c9        ret     		; return

	; called from #95F0.  clears intermission indicator

963c  3e00      ld      a,#00		; A := #00
963e  32004f    ld      (#4f00),a	; clear the intermission indicator
9641  c9        ret     		; return

    ; draws title screen logo and text (sets as tasks).  called from #95F8

	; this on pac draws the ghost (logo) and CLYDE" text
9642  ef        rst     #28		; insert task to draw text "(C) MIDWAY MFG CO"	
9643  1c 13				; 

9645  ef        rst     #28		; insert task to draw text "1980/1981"
9646  1c 35				; 

    ; draws vertical strips of the midway logo starting with the rightmost

9648  21 9A 42	LD	HL,#429A	; load HL with start of screen location
964b  3ebf      ld      a,#bf		; A := #BF = 1st code for midway logo graphic
964d  a7        and     a		; clear the carry flag
964e  111d00    ld      de,#001d	; load DE with offset for each strip
9651  010004    ld      bc,#0400	; load BC with offset for color grid

9654  77        ld      (hl),a		; draw first element
9655  09        add     hl,bc		; add color offset
9656  3601      ld      (hl),#01	; color first element
9658  ed42      sbc     hl,bc		; remove color offset
965a  23        inc     hl		; next location
965b  d604      sub     #04		; next element
965d  77        ld      (hl),a		; draw 2nd element
965e  09        add     hl,bc		; add color offset
965f  3601      ld      (hl),#01	; color 2nd element
9661  ed42      sbc     hl,bc		; remove color offset
9663  23        inc     hl		; next location
9664  d604      sub     #04		; next element
9666  77        ld      (hl),a		; draw 3rd element
9667  09        add     hl,bc		; add color offset		
9668  3601      ld      (hl),#01	; color 3rd element
966a  ed42      sbc     hl,bc		; remove color offset
966c  23        inc     hl		; next location
966d  d604      sub     #04		; next element
966f  77        ld      (hl),a		; draw 4th element
9670  09        add     hl,bc		; add color offset
9671  3601      ld      (hl),#01	; color 4th element
9673  ed42      sbc     hl,bc		; remove color offset
9675  19        add     hl,de		; next strip
9676  c60b      add     a,#0b		; add offset
9678  febb      cp      #bb		; are we done?
967a  20d8      jr      nz,#9654        ; No, loop again
967c  c9        ret     		; return

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

967D  95 96				; #9695	; startup song
967F  d6 96				; #96D6	; act 1 song
9681  58 3c				; #3C58	; act 2 song
9683  4f 97				; #974F	; act 3 song

        ;; channel 1 : jump table to song data

9685  B6 96				; #96B6	; startup song
9687  19 97				; #9719	; act 1 song
9689  d4 3b				; #3BD4	; act 2 song
968B  72 97				; #9772	; act 3 song

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


	; something with sprites for cocktail?
	; jump here from #2CC1

9797  3a004f    ld      a,(#4f00)	; load A with intermission indicator
979a  fe00      cp      #00		; is an intermission running ?
979c  280b      jr      z,#97a9         ; no, skip next 4 steps

979e  11024c    ld      de,#4c02	; yes, load destination DE := #4C02
97a1  21504f    ld      hl,#4f50	; load source HL := #4F50
97a4  010c00    ld      bc,#000c	; set byte counter to #0C
97a7  edb0      ldir    		; copy

97a9  3a094e    ld      a,(#4e09)	; load A with current player number:  0=P1, 1=P2
97ac  21724e    ld      hl,#4e72	; load HL with cocktail mode (0=no, 1=yes)
97af  a6        and     (hl)		; mix together.  Is this 2 player and cocktail mode ?
97b0  280c      jr      z,#97be         ; no, skip ahead

97b2  3a0a4c    ld      a,(#4c0a)	; yes, load A with mspac sprite number
97b5  fe3f      cp      #3f		; == #3F ?  - end of death animation?
97b7  2005      jr      nz,#97be        ; no, skip ahead

97b9  3eff      ld      a,#ff		; yes, A := #FF
97bb  320a4c    ld      (#4c0a),a	; store into mspac sprite number

97be  218596    ld      hl,#9685	; HL := #9685
97c1  c3c42c    jp      #2cc4		; jump back to program


	; unused?

97C4:  FF FF FF FF FF FF FF FF FF FF FF FF


; 

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f  0123456789abcdef
000097d0  47 45 4e 45  52 41 4c 20  43 4f 4d 50  55 54 45 52  GENERAL COMPUTER
000097e0  20 20 43 4f  52 50 4f 52  41 54 49 4f  4e 20 20 20    CORPORATION
000097f0  48 65 6c 6c  6f 2c 20 4e  61 6b 61 6d  75 72 61 21  Hello, Nakamura!

; above is the easter egg that GCC put into the rom.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  9800 - 9fff is not used
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;; unknown / unused
	; this seems to be a copy of the code from #8800-8840

9800: 82            add  a,d
9801: 8B            adc  a,e
9802: 73            ld   (hl),e
9803: 8E            adc  a,(hl)
9804: 42            ld   b,d
9805: 91            sub  c
9806: 3C            inc  a
9807: 94            sub  h
9808: FA FF 55      jp   m,#55FF
980B: 55            ld   d,l
980C: 01 80 AA      ld   bc,#AA80
980F: 02            ld   (bc),a
9810: 3E 00         ld   a,#00
9812: 32 0D 4C      ld   (#4C0D),a
9815: C3 00 10      jp   $1000

9818: F5            push af
9819: ED 5B D2 4D   ld   de,(#4DD2)
981D: 7C            ld   a,h
981E: 92            sub  d
981F: C6 03         add  a,#03
9821: FE 06         cp   #06
9823: 30 18         jr   nc,#983D

9825: 7D            ld   a,l
9826: 93            sub  e
9827: C6 03         add  a,#03
9829: FE 06         cp   #06
982B: 30 10         jr   nc,#983D

982D: 3E 01         ld   a,#01
982F: 32 0D 4C      ld   (#4C0D),a
9832: F1            pop  af
9833: C6 02         add  a,#02
9835: 32 0C 4C      ld   (#4C0C),a
9838: D6 02         sub  #02
983A: C3 B2 19      jp   #19B2

983D: F1            pop  af
983E: C3 CD 19      jp   #19CD

	
9841:     FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF  ................
9850:  FF FF FF 00 00 FF FF 00 00 00 00 01 00 00 00 01  ................
9860:  00 00 00 FF FE 00 00 00 FF 00 00 FF FE 00 00 00  ................
9870:  FF 00 00 00 FF 00 00 00 FF 00 00 01 FF 01 FF 00  ................
9880:  00 00 00 00 00 FF 00 00 00 00 01 00 00 FF 00 00  ................
9890:  00 00 01 00 00 00 01 00 00 00 01 00 00 01 01 01  ................
98A0:  01 00 00 01 00 01 00 01 00 01 00 01 00 01 00 01  ................
98B0:  00 01 00 01 00 01 00 01 00 FF FF FF FF 00 00 FF  ................
98C0:  FF 40 FC D0 D2 D2 D2 D2 D4 FC DA 02 DC FC FC FC  .@..............
98D0:  FC FC FC DA 02 DC FC FC FC D0 D2 D2 D2 D2 D2 D2  ................
98E0:  D2 D4 FC DA 05 DC FC DA 02 DC FC FC FC FC FC FC  ................
98F0:  DA 02 DC FC FC FC DA 08 DC FC DA 02 E6 EA 02 E7  ................
9900:  D2 EB 02 E7 D2 D2 D2 D2 D2 D2 EB 02 E7 D2 D2 D2  ................
9910:  EB 02 E6 E8 E8 E8 EA 02 DC FC DA 02 DE E4 15 DE  ................
9920:  C0 C0 C0 E4 02 DC FC DA 02 DE E4 02 E6 E8 E8 E8  ................
9930:  E8 EA 02 E6 E8 E8 E8 EA 02 E6 EA 02 E6 EA 02 DE  ................
9940:  C0 C0 C0 E4 02 DC FC DA 02 E7 EB 02 E7 E9 E9 E9  ................
9950:  F5 E4 02 DE F3 E9 E9 EB 02 DE E4 02 DE E4 02 E7  ................
9960:  E9 E9 E9 EB 02 DC FC DA 09 DE E4 02 DE E4 05 DE  ................
9970:  E4 02 DE E4 08 DC FC FA E8 E8 EA 02 E6 E8 EA 02  ................
9980:  DE E4 02 DE E4 02 E6 E8 E8 F4 E4 02 DE E4 02 E6  ................
9990:  E8 E8 E8 EA 02 DC FC FB E9 E9 EB 02 DE C0 E4 02  ................
99A0:  E7 EB 02 E7 EB 02 E7 E9 E9 F5 E4 02 E7 EB 02 DE  ................
99B0:  F3 E9 E9 EB 02 DC FC DA 05 DE C0 E4 0B DE E4 05  ................
99C0:  DE E4 05 DC FC DA 02 E6 EA 02 DE C0 E4 02 E6 EA  ................
99D0:  02 EC D3 D3 D3 EE 02 DE E4 02 E6 EA 02 DE E4 02  ................
99E0:  E6 EA 02 DC FC DA 02 DE E4 02 E7 E9 EB 02 DE E4  ................
99F0:  02 DC FC FC FC DA 02 E7 EB 02 DE E4 02 E7 EB 02  ................
9A00:  DE E4 02 DC FC DA 02 DE E4 06 DE E4 02 F0 FC FC  ................
9A10:  FC DA 05 DE E4 05 DE E4 02 DC FC DA 02 DE E4 02  ................
9A20:  E6 E8 E8 E8 F4 E4 02 CE FC FC FC DA 02 E6 E8 E8  ................
9A30:  F4 E4 02 E6 E8 E8 F4 E4 02 DC 00 62 02 01 13 01  ...........b....
9A40:  01 01 02 01 04 03 13 06 04 03 01 01 01 01 01 01  ................
9A50:  01 01 01 01 01 01 01 01 01 01 01 01 01 06 04 03  ................
9A60:  10 03 06 04 03 10 03 06 04 01 01 01 01 01 01 01  ................
9A70:  0C 03 01 01 01 01 01 01 07 04 0C 03 06 07 04 0C  ................
9A80:  03 06 04 01 01 01 04 0C 01 01 01 03 01 01 01 04  ................
9A90:  03 04 0F 03 03 04 03 04 0F 03 03 04 03 01 01 01  ................
9AA0:  01 0F 01 01 01 03 04 03 19 04 03 19 04 03 01 01  ................
9AB0:  01 01 0F 01 01 01 03 04 03 04 0F 03 03 04 03 04  ................
9AC0:  0F 03 03 04 01 01 01 04 0C 01 01 01 03 01 01 01  ................
9AD0:  07 04 0C 03 06 07 04 0C 03 06 04 01 01 01 01 01  ................
9AE0:  01 01 0C 03 01 01 01 01 01 01 04 03 10 03 06 04  ................
9AF0:  03 10 03 06 04 03 01 01 01 01 01 01 01 01 01 01  ................
9B00:  01 01 01 01 01 01 01 01 01 06 04 03 13 06 04 02  ................
9B10:  01 13 01 01 01 02 01 00 00 00 00 00 00 00 00 00  ................
9B20:  00 00 00 00 00 00 00 00 00 00 00 00 E0 1D 22 1D  ..............".
9B30:  39 40 20 40 3B 63 40 7C 40 83 43 9C 43 49 09 17  9@ @;c@|@.C.CI..
9B40:  09 17 09 0E E0 E0 E0 29 09 17 09 17 09 00 00 63  .......).......c
9B50:  8B 13 94 0C 68 8B 22 94 F4 71 8B 27 4C F4 7B 8B  ....h."..q.'L.{.
9B60:  1C 4C 0C 80 AA AA BF AA 80 0A 54 55 55 55 FF 5F  .L........TUUU._
9B70:  55 EA FF 57 55 F5 57 FF 15 40 55 EA AF 02 EA FF  U..WU.W..@U.....
9B80:  FF AA 94 8B 14 00 00 99 8B 17 00 00 9F 8B 1A 00  ................
9B90:  00 A6 8B 1D 55 40 55 55 BF AA 80 AA AA BF AA AA  ....U@UU........
9BA0:  80 AA 02 80 AA AA 55 00 00 00 55 55 FD AA 40 FC  ......U...UU..@.
9BB0:  DA 02 DE D8 D2 D2 D2 D2 D2 D2 D2 D6 D8 D2 D2 D2  ................
9BC0:  D2 D4 FC FC FC FC DA 02 DE D8 D2 D2 D2 D2 D4 FC  ................
9BD0:  DA 02 DE E4 08 DE E4 05 DC FC FC FC FC DA 02 DE  ................
9BE0:  E4 05 DC FC DA 02 DE E4 02 E6 E8 E8 E8 EA 02 DE  ................
9BF0:  E4 02 E6 EA 02 E7 D2 D2 D2 D2 EB 02 E7 EB 02 E6  ................
9C00:  EA 02 DC FC DA 02 DE E4 02 DE F3 E9 E9 EB 02 DE  ................
9C10:  E4 02 DE E4 0C DE E4 02 DC FC DA 02 DE E4 02 DE  ................
9C20:  E4 05 DE E4 02 DE F2 E8 E8 E8 EA 02 E6 EA 02 E6  ................
9C30:  E8 E8 F4 E4 02 DC FC DA 02 E7 EB 02 DE E4 02 E6  ................
9C40:  EA 02 E7 EB 02 E7 E9 E9 E9 E9 EB 02 DE E4 02 E7  ................
9C50:  E9 E9 E9 EB 02 DC FC DA 05 DE E4 02 DE E4 0C DE  ................
9C60:  E4 08 DC FC FA E8 E8 EA 02 DE E4 02 DE F2 E8 E8  ................
9C70:  E8 E8 EA 02 E6 E8 E8 EA 02 DE F2 E8 E8 EA 02 E6  ................
9C80:  EA 02 DC FC FB E9 E9 EB 02 E7 EB 02 E7 E9 E9 E9  ................
9C90:  E9 E9 EB 02 E7 E9 F5 E4 02 DE F3 E9 E9 EB 02 DE  ................
9CA0:  E4 02 DC FC DA 12 DE E4 02 DE E4 05 DE E4 02 DC  ................
9CB0:  FC DA 02 E6 EA 02 E6 E8 E8 E8 E8 EA 02 EC D3 D3  ................
9CC0:  D3 EE 02 E7 EB 02 E7 EB 02 E6 EA 02 DE E4 02 DC  ................
9CD0:  FC DA 02 DE E4 02 E7 E9 E9 E9 F5 E4 02 DC FC FC  ................
9CE0:  FC DA 08 DE E4 02 E7 EB 02 DC FC DA 02 DE E4 06  ................
9CF0:  DE E4 02 F0 FC FC FC DA 02 E6 E8 E8 E8 EA 02 DE  ................
9D00:  E4 05 DC FC DA 02 DE F2 E8 E8 E8 EA 02 DE E4 02  ................
9D10:  CE FC FC FC DA 02 DE C0 C0 C0 E4 02 DE F2 E8 E8  ................
9D20:  EA 02 DC 00 00 00 00 66 01 01 01 01 01 03 01 01  .......f........
9D30:  01 0B 01 01 07 06 03 03 0A 03 07 06 03 03 01 01  ................
9D40:  01 01 01 01 01 01 01 01 03 07 03 01 01 01 03 07  ................
9D50:  03 06 07 03 03 03 07 03 06 07 03 03 01 01 01 01  ................
9D60:  01 01 01 01 01 01 03 01 01 01 01 01 01 07 03 0D  ................
9D70:  06 03 07 03 0D 06 03 04 01 01 01 01 01 01 0D 03  ................
9D80:  01 01 01 03 04 03 10 03 03 03 04 03 10 01 01 01  ................
9D90:  03 03 04 03 01 01 01 01 12 01 01 01 04 07 15 04  ................
9DA0:  07 15 04 03 01 01 01 01 12 01 01 01 04 03 10 01  ................
9DB0:  01 01 03 03 04 03 10 03 03 03 04 01 01 01 01 01  ................
9DC0:  01 0D 03 01 01 01 03 07 03 0D 06 03 07 03 0D 06  ................
9DD0:  03 07 03 03 01 01 01 01 01 01 01 01 01 01 03 01  ................
9DE0:  01 01 01 01 01 07 03 03 03 07 03 06 07 03 01 01  ................
9DF0:  01 03 07 03 06 07 06 03 03 01 01 01 01 01 01 01  ................
9E00:  01 01 01 03 07 06 03 03 0A 03 08 01 01 01 01 01  ................
9E10:  03 01 01 01 0B 01 01 F4 1D 22 1D 39 40 20 40 3B  .........".9@ @;
9E20:  65 40 7B 40 85 43 9B 43 42 16 0A 16 0A 16 0A 20  e@{@.C.CB...... 
9E30:  20 20 DE E0 22 20 20 20 20 16 0A 16 0A 16 00 00    .."    .......
9E40:  54 8E 13 C4 0C 59 8E 1E C4 F4 61 8E 26 14 F4 6B  T....Y....a.&..k
9E50:  8E 1D 14 0C 02 AA AA 80 2A 02 40 55 7F 55 15 50  ........*.@UU.P
9E60:  05 EA FF 57 55 F5 FF 57 7F 55 05 EA FF FF FF EA  ...WU..WU......
9E70:  AF AA 02 87 8E 12 00 00 8C 8E 1D 00 00 94 8E 21  ...............!
9E80:  00 00 9D 8E 2C 00 00 55 7F 55 D5 FF AA BF AA 2A  ....,..UU.....*
9E90:  A0 EA FF FF AA 2A A0 02 00 00 A0 AA 02 55 15 A0  .....*.......U..
9EA0:  2A 00 54 05 00 00 55 FD 40 FC D0 D2 D2 D2 D2 D2  *.T...U.@.......
9EB0:  D2 D6 E4 02 E7 D2 D2 D2 D2 D2 D2 D2 D2 D2 D2 D6  ................
9EC0:  D8 D2 D2 D2 D2 D2 D2 D2 D4 FC DA 07 DE E4 0D DE  ................
9ED0:  E4 08 DC FC DA 02 E6 E8 E8 EA 02 DE E4 02 E6 E8  ................
9EE0:  E8 EA 02 E6 E8 E8 E8 EA 02 E7 EB 02 E6 EA 02 E6  ................
9EF0:  EA 02 DC FC DA 02 DE F3 E9 EB 02 E7 EB 02 E7 E9  ................
9F00:  F5 E4 02 E7 E9 E9 F5 E4 05 DE E4 02 DE E4 02 DC  ................
9F10:  FC DA 02 DE E4 09 DE E4 05 DE E4 02 E6 E8 E8 F4  ................
9F20:  E4 02 DE E4 02 DC FC DA 02 DE E4 02 E6 E8 E8 E8  ................
9F30:  E8 EA 02 E7 EB 02 E6 EA 02 E7 EB 02 E7 E9 E9 E9  ................
9F40:  EB 02 E7 EB 02 DC FC DA 02 DE E4 02 E7 E9 E9 E9  ................
9F50:  F5 E4 05 DE E4 0E DC FC DA 02 DE E4 06 DE E4 02  ................
9F60:  E6 E8 E8 F4 E4 02 E6 E8 E8 E8 EA 02 E6 E8 E8 E8  ................
9F70:  E8 E8 F4 FC DA 02 E7 EB 02 E6 E8 EA 02 E7 EB 02  ................
9F80:  E7 E9 E9 E9 EB 02 DE F3 E9 E9 EB 02 DE F3 E9 E9  ................
9F90:  E9 E9 F5 FC DA 05 DE C0 E4 0B DE E4 05 DE E4 05  ................
9FA0:  DC FC FA E8 E8 EA 02 DE C0 E4 02 E6 EA 02 EC D3  ................
9FB0:  D3 D3 EE 02 DE E4 02 E6 EA 02 DE E4 02 E6 EA 02  ................
9FC0:  DC FC FB E9 E9 EB 02 E7 E9 EB 02 DE E4 02 DC FC  ................
9FD0:  FC FC DA 02 E7 EB 02 DE E4 02 E7 EB 02 DE E4 02  ................
9FE0:  DC FC DA 09 DE E4 02 F0 FC FC FC DA 05 DE E4 05  ................
9FF0:  DE E4 02 DC FC DA 02 E6 E8 E8 E8 E8 EA 02 DE E4  ................
