;; Ms. Pac-Man documented disassembly
;;
;;  The copyright holders for the core program
;;  included within this file are:
;;	(c) 1980 NAMCO
;;	(c) 1980 Bally/Midway
;;	(c) 1981 General Computer Corporation (GCC)
;;
;;  Research and compilation of the documentation by
;;	Scott 'Jerry' Lawrence
;;	pacman@umlautllama.com
;;
;;  Documentation and Hack Contributors:
;;      David Caldwell			http://www.porkrind.org
;;      Frederic Vecoven                http://www.vecoven.com (Music, Sound)
;;	Fred K "Juice"
;;      Marcel "The Sil" Silvius	http://home.kabelfoon.nl/~msilvius/
;;	Mark Spaeth 			http://rgvac.978.org/asm
;;	Dave Widel			http://www.widel.com/
;;	M.A.B. from Vigasoco

;;
;; $Id: mspac.asm,v 1.47 2008/06/21 05:43:48 sdl Exp $
;;

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
;;	HACK11: Dave Widel's coin light blink with power pellets
;;
;; 2004-02-18
;;	HACK8: Mark Spaeth's "20 byte" level 255 Pac-Man rom fix
;;	HACK9: Mark Spaeth's Ms. Pac-Man level fix
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

	HACK8
		Mark Spaeth's level 255 Pac-Man fix
		Mspac never gets to 255, so this fix is pac-only

	HACK9
		Mark Spaeth's level 141 Ms. Pac-Man fix
		http://www.funspotnh.com/discus/messages/10/508.html?1077146991
		This fix is Ms. Pac only, but will work for pac as well.

	HACK10
		Dave Widel's faster intermission fix
		Based on Dock Cutlip's code
		Pac moves at normal speeds in intermissions

	HACK11
		Dave Widel's coin light blink with power pellets
		Coin lights blink when power pellets blink now


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Known Ms. Pac variants:
;   (updated to come to this soon...)
;
;	Ms. Pac-Man		Original GCC/Midway w/ aux board
;	Ms. Pac-Man		Bootleg (various) decoded aux board
;	Ms. Pac-Man Attack	(code/map changes?)
;	Miss Pac Plus		(code/map changes?) (same as Attack, reversed)
; and of course, the "fast" and "cheat" versions of those above.

; similarly, Pac variants:
;	Puckman			Namco "original"
;	Hanglyman		Maze disappears sometimes, vertical tunnel?
;	Pac-Man			Namco/Midway
;	Pac-Man Hard		(table changes)
;	Pac-Man Plus		Midway upgrade


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JUNK REGIONS OF ROMSPACE
;

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
	943c - 9469      2d bytes	Untested, unknown - garbage bytes?
	97c4 - 97cf	  c bytes	Untested, FF's
	97d0 - 97f0	 30 bytes	Untested, message
	9800 - 9fff     400 bytes	not available on "pure" mspac.

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
;;; ram:
;	4c00	unused/unknown
;	4c01	unused/unknown
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
;	   4c3f
;	4c22-4c2f sprite positions for spriteram2
;	4c32-4c3f sprite number and color for spriteram
;
;	4c40-4c7f unused/unknown
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
;		16 entries, 16 bytes per entry
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
;
;	4cc0-4ccf tasks to execute outside of IRQ
;		0xFF fill for empty task
;		16 entries, 2 bytes per entry
;		Format:
;		byte 0: routine number
;		byte 1: parameter
;
; Game variables
;
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
;	4d3b	best orientation found 
;	4d3d	saves the opposite orientation
;	4d3e-4d3f saves the current tile position
;	4d40-4d41 saves the destination tile position
;	4d42-4d43 temp resulting position
;	4d44-4d45 minimum distance^2 found
;
;	4dc7	current orientation we're trying
;	4d46-4d85 movement bit patterns (difficulty dependant)
;	4D46-4D49       movement bit patterns for pacman in normal state
;	4D4A-4D4D       movement bit patterns for pacman in big pill state
;	4D4E-4D51       movement bit patterns for second difficulty flag
;	4D52-4D55       movement bit patterns for first difficulty flag
;	4D56-4D59       movement bit patterns for red ghost normal state
;	4D5A-4D5D       movement bit patterns for red ghost blue state
;	4D5E-4D61       movement bit patterns for red ghost tunnel areas
;	4D62-4D65       movement bit patterns for pink ghost normal state
;	4D66-4D69       movement bit patterns for pink ghost blue state
;	4D6A-4D6D       movement bit patterns for pink ghost tunnel areas
;	4D6E-4D71       movement bit patterns for blue ghost normal state
;	4D72-4D75       movement bit patterns for blue ghost blue state
;	4D76-4D79       movement bit patterns for blue ghost tunnel areas
;	4D7A-4D7D       movement bit patterns for orange ghost normal state
;	4D7E-4D81       movement bit patterns for orange ghost blue state
;	4D82-4D83       movement bit patterns for orange ghost tunnel areas
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
;	4da0	red ghost substate (if alive)
;	4da1	pink ghost substate (if alive)
;	4da2	blue ghost substate (if alive)
;	4da3	orange ghost substate (if alive)
;	4da4	# of ghost killed but no collision for yet [0..4]
;	4da5	pacman dead animation state (0 if not dead)
;	4da6	pill effect (1=active, 0=no effect)
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
;	4db0	related to difficulty
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
;	4db6	1st difficulty flag (rel 4dbb)
;		0: red ghost sometimes goes to upper right corner
;		1: red goes for pacman
;		1  - faster ghosts, more dots
;	4db7	2nd difficulty flag (rel 4dbc)
;		when set, red uses another bit movement pattern
;		0: random ghost movement, 1: normal movement (?)
;	4db8	pink ghost counter to go out of home limit (rel 4e0f)
;	4db9	blue ghost counter to go out of home limit (rel 4e10)
;	4dba	orange ghost counter to go out of home limit (rel 4e11)
;	4dbb	remainder of pills when first diff. flag is set
;	4dbc	remainder of pills when second diff. flag is set
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
;	4dc8	counter used to change ghost colors under big pill effects
;
;	4dc9-4dca pointer to pick a random value from the ROM (routine 2a23)
;
;	4dcb-4dcc counter while ghosts are blue. effect ceases at 0
;	4dce	counter started after insert coin (LED and 1UP/2UP blink)
;	4dcf	counter to handle pill changes
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
;	4ee0	main routine number
;		0: init
;		1: demo
;		2: coin inserted
;		3: playing
;	4e01	main routine 0, subroutine #
;	4e02	main routine 1, subroutine # (causes blue maze bug)
;	4e03	main routine 2, subroutine #
;	4e04	level state subroutine #
;		3=ghost move, 2=ghost wait for start
;		(set to 2 to pause game)
;
;	4e06	state in first cutscene
;	4e07	state in second cutscene
;	4e08	state in third cutscene
;
;	4e09	current player number:  0=P1, 1=P2
;
;	4e0a-4e0b pointer to current difficulty settings
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
;	4e34-4e37 big pills data entries
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
;	4e84-4e86 score P1	84=CC 85=BB 86=CC
;	4e87	P1 got bonus life?  1=yes
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

; 4EDC repeats the above for channel 2
; 4EEC repeats the above for channel 3


; Runtime
;
;	4F00-4FBF	Stack
;	4FC0-4FEF	Unused
;	4FF0-4FFF	Sprite RAM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;       PACMAN SPRITE CODES
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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; rst 0 - initialization
	;; init
0000  f3        di			; Disable interrupts
0001  3e00      ld      a,#00		; 0 -> a  
0003  ed47      ld      i,a		; Clear interrupt status register 
0005  c30b23    jp      #230b		; startup test 

;; PAC
;0001  3e3f      ld      a,#3f

	
	;; rst 8 - memset()
	;; Fill "hl" to "hl+b" with "a"
0008  77        ld      (hl),a
0009  23        inc     hl
000a  10fc      djnz    #0008           ; (-4)
000c  c9        ret     
000d  c30e07    jp      #070e		; junk

	;; rst 10  (for dereferencing pointers to bytes)
        ;; hl = hl + a, (hl) -> a
	; HL = base address of table
	; A  = index
	; after the call, A gets the data in HL+A
0010  85        add     a,l
0011  6f        ld      l,a
0012  3e00      ld      a,#00
0014  8c        adc     a,h
0015  67        ld      h,a
0016  7e        ld      a,(hl)
0017  c9        ret     

	;; rst 18 (for dereferencing pointers to words)
        ;; hl = hl + 2*b,  (hl) -> e, (++hl) -> d, de -> hl
        ; HL = base address of table
	; B  = index
	; after the call, DE gets the data in HL+(2*B)
	; modified: DE, A
0018  78        ld      a,b
0019  87        add     a,a
001a  d7        rst     #10
001b  5f        ld      e,a		; E = (HL+2B)
001c  23        inc     hl
001d  56        ld      d,(hl)		; D = (HL+2B+1)
001e  eb        ex      de,hl		; HL = (HL+2B)
001f  c9        ret     


        ;; rst 20 (jump table)
        ;;
        ;; jump to (HL+2*A)
0020  pop     hl                ; get HL from stack
0021  add     a,a
0022  rst     #10               ; HL += 2A   A = (HL)
0023  ld      e,a               ; E = A = (HL)
0024  inc     hl                ;
0025  ld      d,(hl)            ; D = (HL+1)  so  DE = 16-bits at HL+2A
0026  ex      de,hl             ; DE <-> HL
0027  jp      (hl)              ; goto HL


	;; rst 28
	; this is completely baffling me
0028  e1        pop     hl		; next byte after call
0029  46        ld      b,(hl)
002a  23        inc     hl
002b  4e        ld      c,(hl)
002c  23        inc     hl		; bc gets the word after the call
002d  e5        push    hl		; adjust return value
002e  1812      jr      #0042           ; (18)

	;; rst 30
0030  11904c    ld      de,#4c90
0033  0610      ld      b,#10
0035  c35100    jp      #0051


	;; rst 38 (vblank)
	;; INTERRUPT MODE 1 handler
0038  c39b1f    jp      #1f9b		;; patched jump from pacman.
003b  ----50 				;; junk
003c  320750    ld      (#5007),a	;; junk
003f  c33800    jp      #0038		;; junk

;; INTERRUPT MODE 2 (original hardware, non-bootlegs, puckman, pac plus)
;0038  af        xor     a
;0039  320050    ld      (#5000),a
;003c  320750    ld      (#5007),a   
;003f  c33800    jp      #0038


	;; continuation of rst 28 
					; bc has the word after the call (above)
0042  2a804c    ld      hl,(#4c80)	; hl = (4c80)
0045  70        ld      (hl),b
0046  2c        inc     l
0047  71        ld      (hl),c
0048  2c        inc     l		; ((4c80), (4c81)) = bc
0049  2002      jr      nz,#004d
004b  2ec0      ld      l,#c0		; if( c==00 ) l = c0  (spins c0-ff)
004d  22804c    ld      (#4c80),hl	; (4c80, 4c81) = hl
0050  c9        ret     

	;; rst 30 continuation
0051  1a        ld      a,(de)
0052  a7        and     a
0053  2806      jr      z,#005b         ; (6)
0055  1c        inc     e
0056  1c        inc     e
0057  1c        inc     e
0058  10f7      djnz    #0051           ; (-9)
005a  c9        ret     

005b  e1        pop     hl
005c  0603      ld      b,#03
005e  7e        ld      a,(hl)
005f  12        ld      (de),a
0060  23        inc     hl
0061  1c        inc     e
0062  10fa      djnz    #005e           ; (-6)
0064  e9        jp      (hl)

	;; this is a common call
0065  c32d20    jp      #202d

	;; difficulty settings - normal 0068
 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f
00000060                           00 01 02 03 04 05 06 07
00000070  08 09 0a 0b 0c 0d 0e 0f  10 11 12 13 14 


	;; difficulty settings - hard 007d
 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f
00000070                                          01 03 04
00000080  06 07 08 09 0a 0b 0c 0d  0e 0f 10 11 14 

	;; part of the interrupt routine (non-test)
	;; continuation of RST 38 partially...  (vblank)
	;; (gets called from the 1f9b patch, from 0038)
008d  f5        push    af
008e  32c050    ld      (#50c0),a	; kick the dog
0091  af        xor     a		; 0 -> a
0092  320050    ld      (#5000),a	; disable hardware interrupts
0095  f3        di			; disable cpu interrupts
0096  c5        push    bc
0097  d5        push    de
0098  e5        push    hl
0099  dde5      push    ix
009b  fde5      push    iy

        ;;
        ;; VBLANK - 1 (SOUND)
        ;;
        ;; load the sound into the hardware
	;;
009d  ld      hl,#CH1_FREQ0             ; pointer to frequencies and volumes of 
the 3 voices
00a0  ld      de,#5050                  ; hardware address
00a3  ld      bc,#0010                  ; 16 bytes
00a6  ldir                              ; copy !

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
00d5  21024c    ld      hl,#4c02
00d8  11224c    ld      de,#4c22
00db  011c00    ld      bc,#001c
00de  edb0      ldir    

	; update sprite data, adjusting to hardware
00e0  dd21204c  ld      ix,#4c20	
00e4  dd7e02    ld      a,(ix+#02) ; move up for flip hardware
00e7  07        rlca    
00e8  07        rlca    
00e9  dd7702    ld      (ix+#02),a
00ec  dd7e04    ld      a,(ix+#04)	; move sprite number 2 bits up
00ef  07        rlca    
00f0  07        rlca    
00f1  dd7704    ld      (ix+#04),a
00f4  dd7e06    ld      a,(ix+#06)	; move sprite number 2 bits up
00f7  07        rlca    
00f8  07        rlca    
00f9  dd7706    ld      (ix+#06),a
00fc  dd7e08    ld      a,(ix+#08)	; move sprite number 2 bits up
00ff  07        rlca    
0100  07        rlca    
0101  dd7708    ld      (ix+#08),a
0104  dd7e0a    ld      a,(ix+#0a)	; move sprite number 2 bits up
0107  07        rlca    
0108  07        rlca    
0109  dd770a    ld      (ix+#0a),a
010c  dd7e0c    ld      a,(ix+#0c)	; move sprite number 2 bits up
010f  07        rlca    
0110  07        rlca    
0111  dd770c    ld      (ix+#0c),a

0114  3ad14d    ld      a,(#4dd1)	; ghost being killed?
0117  fe01      cp      #01
0119  2038      jr      nz,#0153        ; (56)

011b  dd21204c  ld      ix,#4c20	; IX is sprite data
011f  3aa44d    ld      a,(#4da4)	; gets the unhandled killed character
0122  87        add     a,a
0123  5f        ld      e,a
0124  1600      ld      d,#00
0126  dd19      add     ix,de
0128  2a244c    ld      hl,(#4c24)	; swap sprite with 4c24/4c25
012b  ed5b344c  ld      de,(#4c34)	; make it first displayed
012f  dd7e00    ld      a,(ix+#00)
0132  32244c    ld      (#4c24),a
0135  dd7e01    ld      a,(ix+#01)
0138  32254c    ld      (#4c25),a
013b  dd7e10    ld      a,(ix+#10)
013e  32344c    ld      (#4c34),a
0141  dd7e11    ld      a,(ix+#11)
0144  32354c    ld      (#4c35),a
0147  dd7500    ld      (ix+#00),l
014a  dd7401    ld      (ix+#01),h
014d  dd7310    ld      (ix+#10),e
0150  dd7211    ld      (ix+#11),d

0153  3aa64d    ld      a,(#4da6)	; skip if no big pill yet
0156  a7        and     a
0157  ca7601    jp      z,#0176		; swap pac for first ghost
015a  ed4b224c  ld      bc,(#4c22)	; highest priority sprite
015e  ed5b324c  ld      de,(#4c32)
0162  2a2a4c    ld      hl,(#4c2a)
0165  22224c    ld      (#4c22),hl
0168  2a3a4c    ld      hl,(#4c3a)	; swap with first ghost
016b  22324c    ld      (#4c32),hl
016e  ed432a4c  ld      (#4c2a),bc
0172  ed533a4c  ld      (#4c3a),de

0176  21224c    ld      hl,#4c22	; copy data
0179  11f24f    ld      de,#4ff2	; copy sprite pos to spriteram2
017c  010c00    ld      bc,#000c
017f  edb0      ldir    

0181  21324c    ld      hl,#4c32	; write updated sprite to spriteram
0184  116250    ld      de,#5062
0187  010c00    ld      bc,#000c
018a  edb0      ldir

	; core game loop
018c  cddc01    call    #01dc		; controls the game play -
					;  stops on game screen when disabled
018f  cd2102    call    #0221		; controls the moving sprites
0192  cdc803    call    #03c8		; enable sound out and other stuff -
					;  blank screen if disabled
0195  3a004e    ld      a,(#4e00)	; check game mode
0198  a7        and     a		; set flags
0199  2812      jr      z,#01ad         ; skip over next calls if no players

019b  cd9d03    call    #039d		; displays "READY!"
					; pauses between plrs and men or levels
019e  cd9014    call    #1490		; display sprites in intro and game
01a1  cd1f14    call    #141f		; ?
01a4  cd6702    call    #0267		; debounce rack input / add credits
01a7  cdad02    call    #02ad		; debounce coin input / add credits
01aa  cdfd02    call    #02fd		; blink coin lights
					; print player 1 and player two
					; check for game mode 3
					; draw cprt stuff

01ad  3a004e    ld      a,(#4e00)	; nplayers
01b0  3d        dec     a
01b1  2006      jr      nz,#01b9        ; skip if intro mode
01b3  32ac4e    ld      (#4eac),a
01b6  32bc4e    ld      (#4ebc),a

        ;;
        ;; VBLANK - 2 (SOUND)
        ;;
        ;; Process sound
01b9    call    #2d0c                   ; process effects
01bc    call    #2cc1                   ; process waves


01bf  fde1      pop     iy
01c1  dde1      pop     ix
01c3  e1        pop     hl
01c4  d1        pop     de
01c5  c1        pop     bc
01c6  3a004e    ld      a,(#4e00)	; check players
01c9  a7        and     a		; set flags
01ca  2808      jr      z,#01d4         ; (8)
01cc  3a4050    ld      a,(#5040)	; IN1
01cf  e610      and     #10		; rack TEST

; elimiate test mode ; HACK7
;01d1  00        nop
;01d2  00        nop
;01d3  00        nop

01d1  ca0000    jp      z,#0000		; reset if TEST is set
01d4  3e01      ld      a,#01		; a=1
01d6  320050    ld      (#5000),a	; reenable hardware interrupts
01d9  fb        ei      		; enable cpu interrupts
01da  f1        pop     af
01db  c9        ret     		; end

	;; controls the game play
	; (stops on game screen when disabled)
01dc  21844c    ld      hl,#4c84
01df  34        inc     (hl)
01e0  23        inc     hl
01e1  35        dec     (hl)
01e2  23        inc     hl
01e3  111902    ld      de,#0219
01e6  010104    ld      bc,#0401
01e9  34        inc     (hl)
01ea  7e        ld      a,(hl)
01eb  e60f      and     #0f
01ed  eb        ex      de,hl
01ee  be        cp      (hl)
01ef  2013      jr      nz,#0204        ; (19)
01f1  0c        inc     c
01f2  1a        ld      a,(de)
01f3  c610      add     a,#10
01f5  e6f0      and     #f0
01f7  12        ld      (de),a
01f8  23        inc     hl
01f9  be        cp      (hl)
01fa  2008      jr      nz,#0204        ; (8)
01fc  0c        inc     c
01fd  eb        ex      de,hl
01fe  3600      ld      (hl),#00
0200  23        inc     hl
0201  13        inc     de
0202  10e5      djnz    #01e9           ; (-27)
0204  218a4c    ld      hl,#4c8a
0207  71        ld      (hl),c
0208  2c        inc     l
0209  7e        ld      a,(hl)
020a  87        add     a,a
020b  87        add     a,a
020c  86        add     a,(hl)
020d  3c        inc     a
020e  77        ld      (hl),a
020f  2c        inc     l
0210  7e        ld      a,(hl)
0211  87        add     a,a
0212  86        add     a,(hl)
0213  87        add     a,a
0214  87        add     a,a
0215  86        add     a,(hl)
0216  3c        inc     a
0217  77        ld      (hl),a
0218  c9        ret     

0219  06a0      ld      b,#a0
021b  0a        ld      a,(bc)
021c  60        ld      h,b
021d  0a        ld      a,(bc)
021e  60        ld      h,b
021f  0a        ld      a,(bc)
0220  a0        and     b

	;; controls the moving sprites
;; PAC -------
0221  21904c    ld      hl,#4c90
0224  3a8a4c    ld      a,(#4c8a)
0227  4f        ld      c,a
0228  0610      ld      b,#10
022a  7e        ld      a,(hl)
022b  a7        and     a
022c  282f      jr      z,#025d         ; (47)
022e  e6c0      and     #c0
0230  07        rlca    
0231  07        rlca    
0232  b9        cp      c
0233  3028      jr      nc,#025d        ; (40)
0235  35        dec     (hl)
0236  7e        ld      a,(hl)
0237  e63f      and     #3f
0239  2022      jr      nz,#025d        ; (34)
023b  77        ld      (hl),a
023c  c5        push    bc
023d  e5        push    hl
023e  2c        inc     l
023f  7e        ld      a,(hl)
0240  2c        inc     l
0241  46        ld      b,(hl)
0242  215b02    ld      hl,#025b
0245  e5        push    hl
0246  e7        rst     #20
0247  94        sub     h
0248  08        ex      af,af'
0249  a3        and     e
024a  068e      ld      b,#8e
024c  05        dec     b
024d  72        ld      (hl),d
024e  12        ld      (de),a
024f  00        nop     
0250  100b      djnz    #025d           ; (11)
0252  1063      djnz    #02b7           ; (99)
0254  02        ld      (bc),a
0255  2b        dec     hl
0256  21f021    ld      hl,#21f0
0259  b9        cp      c
025a  22e1c1    ld      (#c1e1),hl
025d  2c        inc     l
025e  2c        inc     l
025f  2c        inc     l
0260  10c8      djnz    #022a           ; (-56)
0262  c9        ret     

	; clear ready message
0263  ef        rst     #28		; add new current taks 1c 86
0264  1c86
0266  c9        ret     

    ;; debounce rack input / add credits (if 99 or over, return)
0267  3a6e4e    ld      a,(#4e6e)	; number of  current credits
026a  fe99      cp      #99		; max coins
026c  17        rla     		; then lockout
026d  320650    ld      (#5006),a	; coin lockout
0270  1f        rra     
0271  d0        ret     nc		; return if 99 credits

0272  3a0050    ld      a,(#5000)	; check IN0 input
0275  47        ld      b,a		; b=a
0276  cb00      rlc     b		; rotate left
0278  3a664e    ld      a,(#4e66)	; ?
027b  17        rla     		; rotate left with carry
027c  e60f      and     #0f		; and it with 0f
027e  32664e    ld      (#4e66),a	; put it back
0281  d60c      sub     #0c		; a=a-$C
0283  ccdf02    call    z,#02df		; call $2df if a==0 ; add coin
0286  cb00      rlc     b
0288  3a674e    ld      a,(#4e67)
028b  17        rla     
028c  e60f      and     #0f
028e  32674e    ld      (#4e67),a
0291  d60c      sub     #0c
0293  c29a02    jp      nz,#029a
0296  21694e    ld      hl,#4e69	; increment credits
0299  34        inc     (hl)
029a  cb00      rlc     b
029c  3a684e    ld      a,(#4e68)
029f  17        rla     
02a0  e60f      and     #0f
02a2  32684e    ld      (#4e68),a
02a5  d60c      sub     #0c
02a7  c0        ret     nz

02a8  21694e    ld      hl,#4e69
02ab  34        inc     (hl)
02ac  c9        ret     

	;; debounce coin input / add credits
02ad  3a694e    ld      a,(#4e69)	; increment credits
02b0  a7        and     a
02b1  c8        ret     z		; if it's zero, return

02b2  47        ld      b,a
02b3  3a6a4e    ld      a,(#4e6a)	; 
02b6  5f        ld      e,a
02b7  fe00      cp      #00
02b9  c2c402    jp      nz,#02c4
02bc  3e01      ld      a,#01
02be  320750    ld      (#5007),a
02c1  cddf02    call    #02df
02c4  7b        ld      a,e
02c5  fe08      cp      #08
02c7  c2ce02    jp      nz,#02ce
02ca  af        xor     a
02cb  320750    ld      (#5007),a	; coin counter
02ce  1c        inc     e
02cf  7b        ld      a,e
02d0  326a4e    ld      (#4e6a),a	; credit memory = a
02d3  d610      sub     #10
02d5  c0        ret     nz

02d6  326a4e    ld      (#4e6a),a
02d9  05        dec     b
02da  78        ld      a,b
02db  32694e    ld      (#4e69),a
02de  c9        ret     

	;; coins -> credits routine
02df  3a6b4e    ld      a,(#4e6b)	; #coins per #credits
02e2  216c4e    ld      hl,#4e6c	; leftover coins
02e5  34        inc     (hl)		; add 1
02e6  96        sub     (hl)
02e7  c0        ret     nz		; not enough coins for credits

02e8  77        ld      (hl),a		; store leftover coins
02e9  3a6d4e    ld      a,(#4e6d)	; #credits per #coins
02ec  216e4e    ld      hl,#4e6e	; #credits
02ef  86        add     a,(hl)		; add # credits
02f0  27        daa     
02f1  d2f602    jp      nc,#02f6
02f4  3e99      ld      a,#99
02f6  77        ld      (hl),a		; store #credits, max 99
02f7  219c4e    ld      hl,#4e9c
02fa  cbce      set     1,(hl)		; set bit 1 of 4e9c	(play a sound)
02fc  c9        ret     

	;; blink coin lights, print player 1 and player 2, check for mode 3
02fd  21ce4d    ld      hl,#4dce
0300  34        inc     (hl)		; increment whats in $4dce
0301  7e        ld      a,(hl)		; a = alue in 4cf
0302  e60f      and     #0f		; and with $0f
0304  201f      jr      nz,#0325        ; (31)	 if not 0, jump
0306  7e        ld      a,(hl)		; shift right
0307  0f        rrca    
0308  0f        rrca    
0309  0f        rrca    
030a  0f        rrca    
030b  47        ld      b,a		; b=a

    ;; blink coin lights to pellets ; HACK11
;030c  3aa74d    ld      a,(#4da7) 
;030f  4f        ld      c,a
;0310  180b      jr      #0317

030c  3ad64d    ld      a,(#4dd6)	 
030f  2f        cpl     		; compliment
0310  b0        or      b		; or b
0311  4f        ld      c,a		; c=a
0312  3a6e4e    ld      a,(#4e6e)	; a = number of credits
0315  d601      sub     #01		; subtract one from it.

0317  3002      jr      nc,#031b        ; (2)	if carry not 0 then jump
0319  af        xor     a
031a  4f        ld      c,a
031b  2801      jr      z,#031e         ; (1)
031d  79        ld      a,c
031e  320550    ld      (#5005),a	; player 2 start lamp
0321  79        ld      a,c
0322  320450    ld      (#5004),a	; player 1 start lamp
0325  dd21d843  ld      ix,#43d8
0329  fd21c543  ld      iy,#43c5

	;; determine 1p or 2p
032d  3a004e    ld      a,(#4e00)	; game mode?
0330  fe03      cp      #03
0332  ca4403    jp      z,#0344		; Jump if 1 or 2 players
0335  3a034e    ld      a,(#4e03)
0338  fe02      cp      #02
033a  d24403    jp      nc,#0344
033d  cd6903    call    #0369		; draw "1UP"
0340  cd7603    call    #0376		; draw "1UP"
0343  c9        ret     

	;; display and blink 1UP/2UP depending on player up
0344  3a094e    ld      a,(#4e09)
0347  a7        and     a
0348  3ace4d    ld      a,(#4dce)
034b  c25903    jp      nz,#0359
034e  cb67      bit     4,a
0350  cc6903    call    z,#0369		; draw  "1UP"
0353  c48303    call    nz,#0383	; clear "1UP"
0356  c36103    jp      #0361
0359  cb67      bit     4,a
035b  cc7603    call    z,#0376		; draw  "1UP"
035e  c49003    call    nz,#0390	; clear "2UP"
0361  3a704e    ld      a,(#4e70)	; players 0=1 1=2
0364  a7        and     a
0365  cc9003    call    z,#0390		; clear "2UP"
0368  c9        ret     

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

	;draws big pacman in intermission
039d  3a064e    ld      a,(#4e06)		; if 4e06 is <5, normal pac
03a0  d605      sub     #05
03a2  d8        ret     c

	; draw big pac
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
03c8  3a004e    ld      a,(#4e00)	; game mode
03cb  e7        rst     #20		; stack = program counter @ rst 20

03cc  d403    ;$03D4          ;$4E00 = 0
03ce  fe03    ;$03FE          ;$4E00 = 1      ;ALL ATTRACT MODES
03d0  e505    ;$05E5          ;$4E00 = 2      ;PLAYER 1 OR 2 SCRN
03d2  be06    ;$06BE          ;$4E00 = 3      ;PLAYER 1OR2PLAYING

03d4  3a014e	ld	a,(#4e01)
03d5  e7        rst     #20
03d8  dc030c    call    c,#0c03
03db  00        nop     
03dc  ef        rst     #28
03dd  0000
03df  ef        rst     #28
03e0  0600

	;; this seems to execute oddly. 
03e2  ef        rst     #28
03e3  0100
03e5  ef        rst     #28
03e6  1400
03e8  ef        rst     #28
03e9  1800
03eb  ef        rst     #28
03ec  0400
03ee  ef        rst     #28
03ef  1e00
03f1  ef        rst     #28
03f2  0700
03f4  21014e    ld      hl,#4e01
03f7  34        inc     (hl)
03f8  210150    ld      hl,#5001	; enable sound
03fb  3601      ld      (hl),#01	; output
03fd  c9        ret     

	; demo mode
03fe  cda12b    call    #2ba1		; write #credits on screen
0401  3a6e4e    ld      a,(#4e6e)	; get credits
0404  a7        and     a		; set flags
0405  280c      jr      z,#0413         ; no credits -> 0x13
0407  af        xor     a
0408  32044e    ld      (#4e04),a	; level complete register
040b  32024e    ld      (#4e02),a
040e  21004e    ld      hl,#4e00
0411  34        inc     (hl)		; start game mode
0412  c9        ret     

	; table lookup	(mspac patch)
0413  c35c3e    jp      #3e5c		; no credits?
0416  e7        rst     #20

;; PAC 
;0413  3a024e    ld      a,(#4e02)


	; another address table of based off of 4e02
	; task routine to draw out the attract screen
0417  5f04    ;$045F  ;($4e02)=0              
0419  0c00    ;$000C        ;($4e02)=1  RETURN
041b  7104    ;$0471  ;($4e02)=2
041d  0c00    ;$000C  ;($4e02)=3  RETURN
041f  7f04    ;$047F  ;($4e02)=4  
0421  0C00    ;$000C  ;($4e02)=5  RETURN
0423  8504    ;$0485  ;($4e02)=6
0425  0c00    ;$000C  ;($4e02)=7  RETURN
0427  8b04    ;$048B  ;($4e02)=8
0429  0c00    ;$000C  ;($4e02)=9  RETURN
042b  9904    ;$0499  ;($4e02)=$0A
042d  0c00    ;$000C  ;($4e02)=$0B  RETURN
042f  9f04    ;$049F  ;($4e02)=$0C
0431  0c00    ;$000C  ;($4e02)=$0D  RETURN
0433  a504    ;$04A5  ;($4e02)=$0E
0435  0c00    ;$000C  ;($4e02)=$0F  RETURN
0437  b304    ;$04B3  ;($4E02)=$10


0438  04        inc     b
0439  0c        inc     c
043a  00        nop     
043b  b9        cp      c
043c  04        inc     b
043d  0c        inc     c
043e  00        nop     
043f  bf        cp      a
0440  04        inc     b
0441  0c        inc     c
0442  00        nop     
0443  cd040c    call    #0c04
0446  00        nop     
0447  d304      out     (#04),a
0449  0c        inc     c
044a  00        nop     
044b  d8        ret     c

044c  04        inc     b
044d  0c        inc     c
044e  00        nop     
044f  e0        ret     po

0450  04        inc     b
0451  0c        inc     c
0452  00        nop     
0453  1c        inc     e
0454  05        dec     b
0455  4b        ld      c,e
0456  05        dec     b
0457  56        ld      d,(hl)
0458  05        dec     b
0459  61        ld      h,c
045a  05        dec     b
045b  6c        ld      l,h
045c  05        dec     b
045d  7c        ld      a,h
045e  05        dec     b

	; code resumes here
045f  ef        rst     #28
0460  0001
0462  ef        rst     #28
0464  0100
0465  ef        rst     #28
0466  0400
0468  ef        rst     #28
0469  1e00
046b  0e0c      ld      c,#0c
046d  cd8505    call    #0585
0470  c9        ret     

0471  210443    ld      hl,#4304
0474  3e01      ld      a,#01
0476  cdbf05    call    #05bf
0479  0e0c      ld      c,#0c
047b  cd8505    call    #0585
047e  c9        ret     

047f  0e14      ld      c,#14
0481  cd9305    call    #0593
0484  c9        ret     

0485  0e0d      ld      c,#0d
0487  cd9305    call    #0593
048a  c9        ret     

048b  210743    ld      hl,#4307
048e  3e03      ld      a,#03
0490  cdbf05    call    #05bf
0493  0e0c      ld      c,#0c
0495  cd8505    call    #0585
0498  c9        ret     

0499  0e16      ld      c,#16
049b  cd9305    call    #0593
049e  c9        ret     

049f  0e0f      ld      c,#0f
04a1  cd9305    call    #0593
04a4  c9        ret     

04a5  210a43    ld      hl,#430a
04a8  3e05      ld      a,#05
04aa  cdbf05    call    #05bf
04ad  0e0c      ld      c,#0c
04af  cd8505    call    #0585
04b2  c9        ret     

04b3  0e33      ld      c,#33
04b5  cd9305    call    #0593
04b8  c9        ret     

04b9  0e2f      ld      c,#2f
04bb  cd9305    call    #0593
04be  c9        ret     

04bf  210d43    ld      hl,#430d
04c2  3e07      ld      a,#07
04c4  cdbf05    call    #05bf
04c7  0e0c      ld      c,#0c
04c9  cd8505    call    #0585
04cc  c9        ret     

04cd  0e35      ld      c,#35
04cf  cd9305    call    #0593
04d2  c9        ret     

04d3  0e31      ld      c,#31
04d5  c38005    jp      #0580
04d8  ef        rst     #28
04d9  1c11
04da  0e12      ld      c,#12
04dd  c38505    jp      #0585
04e0  0e13      ld      c,#13
04e2  cd8505    call    #0585
04e5  cd7908    call    #0879
04e8  35        dec     (hl)
04e9  ef        rst     #28
04ea  1100
04ec  ef        rst     #28
04ed  05        dec     b
04ee  01ef10    ld      bc,#10ef
04f1  14        inc     d
04f2  ef        rst     #28
04f3  0401
04f4  3e01      ld      a,#01
04f7  32144e    ld      (#4e14),a	; number of lives left 
04fa  af        xor     a
04fb  32704e    ld      (#4e70),a	; number of players 0=1 1=2
04fe  32154e    ld      (#4e15),a	; number of lives displayed
0501  213243    ld      hl,#4332
0504  3614      ld      (hl),#14
0506  3efc      ld      a,#fc
0508  112000    ld      de,#0020
050b  061c      ld      b,#1c
050d  dd214040  ld      ix,#4040
0511  dd7711    ld      (ix+#11),a
0514  dd7713    ld      (ix+#13),a
0517  dd19      add     ix,de
0519  10f6      djnz    #0511           ; (-10)
051b  c9        ret     

	; check for moving through a tunnel?
051c  21a04d    ld      hl,#4da0
051f  0621      ld      b,#21
0521  3a3a4d    ld      a,(#4d3a)
0524  90        sub     b		; pac going through a tunnel?
0525  2005      jr      nz,#052c        ; (5)
0527  3601      ld      (hl),#01
0529  c38e05    jp      #058e

	; another core game loop?
052c  cd1710    call    #1017
052f  cd1710    call    #1017
0532  cd230e    call    #0e23
0535  cd0d0c    call    #0c0d
0538  cdd60b    call    #0bd6
053b  cda505    call    #05a5
053e  cdfe1e    call    #1efe
0541  cd251f    call    #1f25
0544  cd4c1f    call    #1f4c
0547  cd731f    call    #1f73
054a  c9        ret     

054b  21a14d    ld      hl,#4da1
054e  0620      ld      b,#20
0550  3a324d    ld      a,(#4d32)
0553  c32405    jp      #0524
0556  21a24d    ld      hl,#4da2
0559  0622      ld      b,#22
055b  3a324d    ld      a,(#4d32)
055e  c32405    jp      #0524
0561  21a34d    ld      hl,#4da3
0564  0624      ld      b,#24
0566  3a324d    ld      a,(#4d32)
0569  c32405    jp      #0524
056c  3ad04d    ld      a,(#4dd0)
056f  47        ld      b,a
0570  3ad14d    ld      a,(#4dd1)
0573  80        add     a,b
0574  fe06      cp      #06
0576  ca8e05    jp      z,#058e
0579  c32c05    jp      #052c
057c  cdbe06    call    #06be
057f  c9        ret     

0580  3a754e    ld      a,(#4e75)
0583  81        add     a,c
0584  4f        ld      c,a
0585  061c      ld      b,#1c
0587  cd4200    call    #0042
058a  f7        rst     #30
058b  4a        ld      c,d
058c  02        ld      (bc),a
058d  00        nop     

058e  21024e    ld      hl,#4e02
0591  34        inc     (hl)
0592  c9        ret     

0593  3a754e    ld      a,(#4e75)
0596  81        add     a,c
0597  4f        ld      c,a
0598  061c      ld      b,#1c
059a  cd4200    call    #0042
059d  f7        rst     #30
059e  45        ld      b,l
059f  02        ld      (bc),a
05a0  00        nop     
05a1  cd8e05    call    #058e
05a4  c9        ret     

05a5  3ab54d    ld      a,(#4db5)
05a8  a7        and     a
05a9  c8        ret     z

05aa  af        xor     a
05ab  32b54d    ld      (#4db5),a
05ae  3a304d    ld      a,(#4d30)
05b1  ee02      xor     #02
05b3  323c4d    ld      (#4d3c),a
05b6  47        ld      b,a
05b7  21ff32    ld      hl,#32ff
05ba  df        rst     #18
05bb  22264d    ld      (#4d26),hl
05be  c9        ret     

05bf  36b1      ld      (hl),#b1
05c1  2c        inc     l
05c2  36b3      ld      (hl),#b3
05c4  2c        inc     l
05c5  36b5      ld      (hl),#b5
05c7  011e00    ld      bc,#001e
05ca  09        add     hl,bc
05cb  36b0      ld      (hl),#b0
05cd  2c        inc     l
05ce  36b2      ld      (hl),#b2
05d0  2c        inc     l
05d1  36b4      ld      (hl),#b4
05d3  110004    ld      de,#0400
05d6  19        add     hl,de
05d7  77        ld      (hl),a
05d8  2d        dec     l
05d9  77        ld      (hl),a
05da  2d        dec     l
05db  77        ld      (hl),a
05dc  a7        and     a
05dd  ed42      sbc     hl,bc
05df  77        ld      (hl),a
05e0  2d        dec     l
05e1  77        ld      (hl),a
05e2  2d        dec     l
05e3  77        ld      (hl),a
05e4  c9        ret     

05e5  3a034e    ld      a,(#4e03)
05e8  e7        rst     #20
05e9  f3        di      
05ea  05        dec     b
05eb  1b        dec     de
05ec  0674      ld      b,#74
05ee  060c      ld      b,#0c
05f0  00        nop     
05f1  a8        xor     b
05f2  06cd      ld      b,#cd
05f4  a1        and     c
05f5  2b        dec     hl
05f6  ef        rst     #28
05f7  0001
05f9  ef        rst     #28
05f8  0100
05fc  ef        rst     #28
05fd  1c07
05ff  ef        rst     #28
0600  1c0b
0602  ef        rst     #28
0603  1e0
0605  21034e    ld      hl,#4e03
0608  34        inc     (hl)
0609  3e01      ld      a,#01
060b  32d64d    ld      (#4dd6),a
060e  3a714e    ld      a,(#4e71)
0611  feff      cp      #ff
0613  c8        ret     z

0614  ef        rst     #28
0615  1c0a
0617  ef        rst     #28
0618  1f00
061a  c9        ret     

		; can't find a jump to here
		;; display 1/2 player and check start buttons
061b  cda12b    call    #2ba1
061e  3a6e4e    ld      a,(#4e6e)	; credits
0621  fe01      cp      #01		; is it 1?
0623  0609      ld      b,#09		; msg #9:  1 OR 2 PLAYERS
0625  2002      jr      nz,#0629        ; (2)	 >2 credits
0627  0608      ld      b,#08		; msg #8:  1 PLAYER ONLY
0629  cd5e2c    call    #2c5e		; print message
062c  3a6e4e    ld      a,(#4e6e)	; get credits
062f  fe01      cp      #01		; 1 credit
0631  3a4050    ld      a,(#5040)	;; check in1
0634  280c      jr      z,#0642         ; (12) don't check p2 with 1 credit
0636  cb77      bit     6,a
0638  2008      jr      nz,#0642        ; (8)
063a  3e01      ld      a,#01		; set 2 players
063c  32704e    ld      (#4e70),a	; players 0=1 1=2 players
063f  c34906    jp      #0649
0642  cb6f      bit     5,a
0644  c0        ret     nz

0645  af        xor     a
0646  32704e    ld      (#4e70),a
0649  3a6b4e    ld      a,(#4e6b)
064c  a7        and     a
064d  2815      jr      z,#0664         ; (21)
064f  3a704e    ld      a,(#4e70)
0652  a7        and     a
0653  3a6e4e    ld      a,(#4e6e)	; number of credits
0656  2803      jr      z,#065b         ; (3)
0658  c699      add     a,#99
065a  27        daa     
065b  c699      add     a,#99
065d  27        daa     
065e  326e4e    ld      (#4e6e),a	; resave credits
0661  cda12b    call    #2ba1
0664  21034e    ld      hl,#4e03
0667  34        inc     (hl)
0668  af        xor     a
0669  32d64d    ld      (#4dd6),a
066c  3c        inc     a
066d  32cc4e    ld      (#4ecc),a
0670  32dc4e    ld      (#4edc),a
0673  c9        ret     

0674  ef        rst     #28
0675  0001
0677  ef        rst     #28
0678  0101
067a  ef        rst     #28
067b  0200
067d  ef        rst     #28
067e  1200
0680  ef        rst     #28
0681  0300
0683  ef        rst     #28
0684  1c03
0686  ef        rst     #28
0687  1c06
0689  ef        rst     #28
068a  1800
068c  ef        rst     #28
068d  1b00
068f  af        xor     a

0690  32134e    ld      (#4e13),a	; current board level = 0
0693  3a6f4e    ld      a,(#4e6f)	; number of lives to start
0696  32144e    ld      (#4e14),a	; number of lives
0699  32154e    ld      (#4e15),a	; number of lives displayed
069c  ef        rst     #28
069d  1a00
069f  f7        rst     #30
06a0  57        ld      d,a
06a1  010021    ld      bc,#2100
06a4  03        inc     bc
06a5  4e        ld      c,(hl)
06a6  34        inc     (hl)
06a7  c9        ret     

	;; draw lives displayed onto the screen
06a8  21154e    ld      hl,#4e15	; hl= lives displayed on screen loc
06ab  35        dec     (hl)
06ac  cd6a2b    call    #2b6a
06af  af        xor     a
06b0  32034e    ld      (#4e03),a
06b3  32024e    ld      (#4e02),a
06b6  32044e    ld      (#4e04),a	; level complete register
06b9  21004e    ld      hl,#4e00	; inc game mode
06bc  34        inc     (hl)
06bd  c9        ret     

06be  3a044e    ld      a,(#4e04)
06c1  e7        rst     #20
06c2  79        ld      a,c
06c3  08        ex      af,af'
06c4  99        sbc     a,c
06c5  08        ex      af,af'
06c6  0c        inc     c
06c7  00        nop     
06c8  cd080d    call    #0d08
06cb  09        add     hl,bc
06cc  0c        inc     c
06cd  00        nop     
06ce  40        ld      b,b
06cf  09        add     hl,bc
06d0  0c        inc     c
06d1  00        nop     
06d2  72        ld      (hl),d
06d3  09        add     hl,bc
06d4  88        adc     a,b
06d5  09        add     hl,bc
06d6  0c        inc     c
06d7  00        nop     
06d8  d209d8    jp      nc,#d809
06db  09        add     hl,bc
06dc  0c        inc     c
06dd  00        nop     
06de  e8        ret     pe

06df  09        add     hl,bc
06e0  0c        inc     c
06e1  00        nop     
06e2  fe09      cp      #09
06e4  0c        inc     c
06e5  00        nop     
06e6  02        ld      (bc),a
06e7  0a        ld      a,(bc)
06e8  0c        inc     c
06e9  00        nop     
06ea  04        inc     b
06eb  0a        ld      a,(bc)
06ec  0c        inc     c
06ed  00        nop     
06ee  060a      ld      b,#0a
06f0  0c        inc     c
06f1  00        nop     
06f2  08        ex      af,af'
06f3  0a        ld      a,(bc)
06f4  0c        inc     c
06f5  00        nop     
06f6  0a        ld      a,(bc)
06f7  0a        ld      a,(bc)
06f8  0c        inc     c
06f9  00        nop     
06fa  0c        inc     c
06fb  0a        ld      a,(bc)
06fc  0c        inc     c
06fd  00        nop     
06fe  0e0a      ld      c,#0a
0700  0c        inc     c
0701  00        nop     
0702  2c        inc     l
0703  0a        ld      a,(bc)
0704  0c        inc     c
0705  00        nop     
0706  7c        ld      a,h
0707  0a        ld      a,(bc)
0708  a0        and     b
0709  0a        ld      a,(bc)
070a  0c        inc     c
070b  00        nop     
070c  a3        and     e
070d  0a        ld      a,(bc)

070e  78        ld      a,b
070f  a7        and     a
0710  2004      jr      nz,#0716        ; (4)
0712  2a0a4e    ld      hl,(#4e0a)
0715  7e        ld      a,(hl)
0716  dd219607  ld      ix,#0796
071a  47        ld      b,a
071b  87        add     a,a
071c  87        add     a,a
071d  80        add     a,b
071e  80        add     a,b
071f  5f        ld      e,a
0720  1600      ld      d,#00
0722  dd19      add     ix,de
0724  dd7e00    ld      a,(ix+#00)
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
0733  210f33    ld      hl,#330f
0736  19        add     hl,de
0737  cd1408    call    #0814
073a  dd7e01    ld      a,(ix+#01)
073d  32b04d    ld      (#4db0),a
0740  dd7e02    ld      a,(ix+#02)
0743  47        ld      b,a
0744  87        add     a,a
0745  80        add     a,b
0746  5f        ld      e,a
0747  1600      ld      d,#00
0749  214308    ld      hl,#0843	; hard/easy data table check 
074c  19        add     hl,de
074d  cd3a08    call    #083a
0750  dd7e03    ld      a,(ix+#03)
0753  87        add     a,a
0754  5f        ld      e,a
0755  1600      ld      d,#00
0757  fd214f08  ld      iy,#084f	; another data table check
075b  fd19      add     iy,de
075d  fd6e00    ld      l,(iy+#00)
0760  fd6601    ld      h,(iy+#01)
0763  22bb4d    ld      (#4dbb),hl
0766  dd7e04    ld      a,(ix+#04)
0769  87        add     a,a
076a  5f        ld      e,a
076b  1600      ld      d,#00
076d  fd216108  ld      iy,#0861
0771  fd19      add     iy,de
0773  fd6e00    ld      l,(iy+#00)
0776  fd6601    ld      h,(iy+#01)
0779  22bd4d    ld      (#4dbd),hl
077c  dd7e05    ld      a,(ix+#05)
077f  87        add     a,a
0780  5f        ld      e,a
0781  1600      ld      d,#00
0783  fd217308  ld      iy,#0873
0787  fd19      add     iy,de
0789  fd6e00    ld      l,(iy+#00)
078c  fd6601    ld      h,(iy+#01)
078f  22954d    ld      (#4d95),hl
0792  cdea2b    call    #2bea
0795  c9        ret     

;	-- difficulty related table
;    each entry is 6 bytes
;	byte 0: (0..6) movement bit patterns and orientation changes (table at 330F)
;	byte 1: (00, 01, 02) stored at 4DB0 - seems to be unused
;	byte 2: (0..3) ghost counter table to exit home (table at 0843)
;	byte 3: (0..7) remaining number of pills to set difficulty flags (table at 084F)
;	byte 4: (0..8) ghost time to stay blue when pacman eats the big pill (table at 0861)
;	byte 5: (0..2) number of units before a ghost goes out of home (table at 0873)

	
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


0814  11464d    ld      de,#4d46
0817  011c00    ld      bc,#001c
081a  edb0      ldir    
081c  010c00    ld      bc,#000c
081f  a7        and     a
0820  ed42      sbc     hl,bc
0822  edb0      ldir    
0824  010c00    ld      bc,#000c
0827  a7        and     a
0828  ed42      sbc     hl,bc
082a  edb0      ldir    
082c  010c00    ld      bc,#000c
082f  a7        and     a
0830  ed42      sbc     hl,bc
0832  edb0      ldir    
0834  010e00    ld      bc,#000e
0837  edb0      ldir    
0839  c9        ret     

083a  11b84d    ld      de,#4db8
083d  010300    ld      bc,#0003
0840  edb0      ldir    
0842  c9        ret     

;-- table related to difficulty - each entry is 3 bytes
; b0: when counter at 4E0F reaches this value, pink ghost goes out of home
; b1: when counter at 4E10 reaches this value, blue ghost goes out of home
; b2: when counter at 4E11 reaches this value, orange ghost goes out of home

    ; these don't seem to be used in ms-pac at all.
0843  14 1e 46   00 1e 3c   00 00 32   00 00 00

    ; hard hack: HACK6
; 0843  0f 14 37 04  18 34 02 06  28 00 04 08

;-- difficulty table - each entry is 2 bytes
; b0: remaining number of pills when second difficulty flag is set
; b1: remaining number of pills when first difficulty flag is set

084f  14 0a  1e 0f  28 14  32 19  3c 1e  50 28  64 32  78 3c

085f  8c 46


;difficulty table - Time the ghosts stay blue when pacman eats a big pill
0861  c0 03		03c0 (960)
0863  48 03		0348 (840)
0865  d0 02		02d0 (720)
0867  58 02		0258 (600)
0869  e0 01		01e0 (480)
086b  68 01		0168 (360)
086d  f0 00		00f0 (240)
086f  78 00		0078 (120)
0871  01 00		0001 (1)

; difficulty table - numberof units before ghosts leaves home
0873  f0 00		00f0 (240)
0875  f0 00		00f0 (240)
0877  b4 00		00b4 (180)

; main routine #3 (playing)
0879  21094e    ld      hl,#4e09
087c  af        xor     a
087d  060b      ld      b,#0b
087f  cf        rst     #8
0880  cdc924    call    #24c9
0883  2a734e    ld      hl,(#4e73)	; difficulty
0886  220a4e    ld      (#4e0a),hl
0889  210a4e    ld      hl,#4e0a
088c  11384e    ld      de,#4e38
088f  012e00    ld      bc,#002e
0892  edb0      ldir    

0894  21044e    ld      hl,#4e04	; inc level complete register
0897  34        inc     (hl)
0898  c9        ret     

0899  3a004e    ld      a,(#4e00)	; game mode
089c  3d        dec     a		; check mode
089d  2006      jr      nz,#08a5        ; jump if not in intro mode
089f  3e09      ld      a,#09
08a1  32044e    ld      (#4e04),a	; set intro mode?
08a4  c9        ret     

08a5  ef        rst     #28
08a6  1100
08a8  ef        rst     #28
08a9  1c83
08ab  ef        rst     #28
08ac  0400
08ae  ef        rst     #28
08af  0500
08b1  ef        rst     #28
08b2  1000
08b4  ef        rst     #28
08b5  1a00
08b7  f7        rst     #30
08b8  54        ld      d,h
08b9  00        nop     
08ba  00        nop     
08bb  f7        rst     #30
08bc  54        ld      d,h
08bd  0600      ld      b,#00
08bf  3a724e    ld      a,(#4e72)	; cocktail or upright
08c2  47        ld      b,a
08c3  3a094e    ld      a,(#4e09)
08c6  a0        and     b
08c7  320350    ld      (#5003),a	; flip screen
08ca  c39408    jp      #0894
08cd  3a0050    ld      a,(#5000)
08d0  cb67      bit     4,a		; rack test
08d2  c2de08    jp      nz,#08de	; not on then continue game
08d5  21044e    ld      hl,#4e04	; rack switch on, so advance
08d8  360e      ld      (hl),#0e	; level complete register gets $0E??
08da  ef        rst     #28
08db  1300
08dd  c9        ret     

	;; routine to determine the number of pellets must be eaten
08de  3a0e4e    ld      a,(#4e0e)	; number of pellets eaten
08e1  c3a194    jp      #94a1		; jump to check routine
08e4  00        nop     
	; returns here
08e5  21044e    ld      hl,#4e04
08e8  360c      ld      (hl),#0c
08ea  c9        ret     

;; pacman original:
; 08de  3a0e4e    ld      a,(#4e0e)       ;NUMBER OF PELLETS EATEN
; 08e1  fef4      cp      #f4             ;COMPARE TO 244
; 08e3  2006      jr      nz,#08eb        ;JUMP IF NOT 244
; 08e5  21044e    ld      hl,#4e04        ;IF SO THEN $C->$4E04
; 08e8  360c      ld      (hl),#0c
; 08ea  c9        ret


	; another core game loop?
08eb  cd1710    call    #1017
08ee  cd1710    call    #1017
08f1  cddd13    call    #13dd
08f4  cd420c    call    #0c42
08f7  cd230e    call    #0e23
08fa  cd360e    call    #0e36
08fd  cdc30a    call    #0ac3
0900  cdd60b    call    #0bd6
0903  cd0d0c    call    #0c0d
0906  cd6c0e    call    #0e6c
0909  cdad0e    call    #0ead
090c  c9        ret     

090d  3e01      ld      a,#01
090f  32124e    ld      (#4e12),a
0912  cd8724    call    #2487
0915  21044e    ld      hl,#4e04
0918  34        inc     (hl)
0919  3a144e    ld      a,(#4e14)	; number of lives left
091c  a7        and     a
091d  201f      jr      nz,#093e        ; (31)
091f  3a704e    ld      a,(#4e70)
0922  a7        and     a
0923  2819      jr      z,#093e         ; (25)
0925  3a424e    ld      a,(#4e42)
0928  a7        and     a
0929  2813      jr      z,#093e         ; (19)
092b  3a094e    ld      a,(#4e09)
092e  c603      add     a,#03
0930  4f        ld      c,a
0931  061c      ld      b,#1c
0933  cd4200    call    #0042
0936  ef        rst     #28
0937  1c05
0939  f7        rst     #30
093a  54        ld      d,h
093b  00        nop     
093c  00        nop     
093d  c9        ret     

093e  34        inc     (hl)
093f  c9        ret     

0940  3a704e    ld      a,(#4e70)	; number of players
0943  a7        and     a
0944  2806      jr      z,#094c         ; jump if 1 player
0946  3a424e    ld      a,(#4e42)
0949  a7        and     a
094a  2015      jr      nz,#0961        ; (21)
094c  3a144e    ld      a,(#4e14)	; number of lives left
094f  a7        and     a
	; change 0950 to 
; c36c09	jp 096c 
	; for never-ending pac goodness
0950  201a      jr      nz,#096c        ; jump if lives left
0952  cda12b    call    #2ba1		; draw # credits or free play 
					; on bottom of screen
0955  ef        rst     #28
0956  1c05
0958  f7        rst     #30
0959  54        ld      d,h
095a  00        nop     
095b  00        nop     
095c  21044e    ld      hl,#4e04
095f  34        inc     (hl)		; increment level cleared
0960  c9        ret     

0961  cda60a    call    #0aa6
0964  3a094e    ld      a,(#4e09)
0967  ee01      xor     #01
0969  32094e    ld      (#4e09),a
096c  3e09      ld      a,#09
096e  32044e    ld      (#4e04),a
0971  c9        ret     

	;; zero some important variables
0972  af        xor     a
0973  32024e    ld      (#4e02),a
0976  32044e    ld      (#4e04),a
0979  32704e    ld      (#4e70),a
097c  32094e    ld      (#4e09),a
097f  320350    ld      (#5003),a	; flip screen
0982  3e01      ld      a,#01
0984  32004e    ld      (#4e00),a
0987  c9        ret     

0988  ef        rst     #28
0989  0001
098b  ef        rst     #28
098c  0101
098e  ef        rst     #28
098f  0200
0991  ef        rst     #28
0992  1100
0994  ef        rst     #28
0995  1300
0997  ef        rst     #28
0998  0300
099a  ef        rst     #28
099b  0400
099d  ef        rst     #28
099e  0500
09a0  ef        rst     #28
09a1  1000
09a3  ef        rst     #28
09a4  1a00
09a6  ef        rst     #28
09a7  1c06
09a8  3a004e    ld      a,(#4e00)
09ac  fe03      cp      #03
09ae  2806      jr      z,#09b6         ; (6)
09b0  ef        rst     #28
09b1  1c05
09b3  ef        rst     #28
09b4  1d00
09b6  f7        rst     #30
09b7  54        ld      d,h
09b8  00        nop     
09b9  00        nop     
09ba  3a004e    ld      a,(#4e00)
09bd  3d        dec     a
09be  2804      jr      z,#09c4         ; (4)
09c0  f7        rst     #30
09c1  54        ld      d,h
09c2  0600      ld      b,#00
09c4  3a724e    ld      a,(#4e72)
09c7  47        ld      b,a
09c8  3a094e    ld      a,(#4e09)
09cb  a0        and     b
09cc  320350    ld      (#5003),a	; flip screen
09cf  c39408    jp      #0894
09d2  3e03      ld      a,#03
09d4  32044e    ld      (#4e04),a
09d7  c9        ret     

09d8  f7        rst     #30
09d9  54        ld      d,h
09da  00        nop     
09db  00        nop     
09dc  21044e    ld      hl,#4e04
09df  34        inc     (hl)
09e0  af        xor     a
09e1  32ac4e    ld      (#4eac),a
09e4  32bc4e    ld      (#4ebc),a
09e7  c9        ret     

09e8  0e02      ld      c,#02
09ea  0601      ld      b,#01
09ec  cd4200    call    #0042
09ef  f7        rst     #30
09f0  42        ld      b,d
09f1  00        nop     
09f2  00        nop     
09f3  210000    ld      hl,#0000
09f6  cd7e26    call    #267e
09f9  21044e    ld      hl,#4e04
09fc  34        inc     (hl)
09fd  c9        ret     

09fe  0e00      ld      c,#00
0a00  18e8      jr      #09ea           ; (-24)
0a02  18e4      jr      #09e8           ; (-28)
0a04  18f8      jr      #09fe           ; (-8)
0a06  18e0      jr      #09e8           ; (-32)
0a08  18f4      jr      #09fe           ; (-12)
0a0a  18dc      jr      #09e8           ; (-36)
0a0c  18f0      jr      #09fe           ; (-16)
0a0e  ef        rst     #28
0a0f  0001
0a11  ef        rst     #28
0a12  0600
0a14  ef        rst     #28
0a15  1100
0a17  ef        rst     #28
0a18  1300
0a1a  ef        rst     #28
0a1b  0401
0a1d  ef        rst     #28
0a1e  0501
0a20  ef        rst     #28
0a21  1013
0a23  f7        rst     #30
0a24  43        ld      b,e
0a25  00        nop     
0a26  00        nop     
0a27  21044e    ld      hl,#4e04
0a2a  34        inc     (hl)
0a2b  c9        ret     

0a2c  af        xor     a
0a2d  32ac4e    ld      (#4eac),a
0a30  32bc4e    ld      (#4ebc),a
0a33  1806      jr      #0a3b           ; (6)
0a35  32cc4e    ld      (#4ecc),a
0a38  32dc4e    ld      (#4edc),a
0a3b  3a134e    ld      a,(#4e13)	; current board level
0a3e  fe14      cp      #14
0a40  3802      jr      c,#0a44         ; (2)
0a42  3e14      ld      a,#14
0a44  e7        rst     #20

	; jump table
0a45  6f 0a		; increment level state and stop sound
0a47  08 21		; cut scene 1
0a49  6f 0a		; increment level state and stop sound
0a4b  6f 0a		; increment level state and stop sound
0a4d  9e 21		; cut scene 2
0a4f  6f 0a		; increment level state and stop sound
0a51  6f 0a		; increment level state and stop sound
0a53  6f 0a		; increment level state and stop sound
0a55  97 22		; cut scene 3
0a57  6f 0a		; increment level state and stop sound
0a59  6f 0a		; increment level state and stop sound
0a5b  6f 0a		; increment level state and stop sound
0a5d  97 22		; cut scene 3
0a5f  6f 0a		; increment level state and stop sound
0a61  6f 0a		; increment level state and stop sound
0a63  6f 0a		; increment level state and stop sound
0a65  97 22		; cut scene 3
0a67  6f 0a		; increment level state and stop sound
0a69  6f 0a		; increment level state and stop sound
0a6b  6f 0a		; increment level state and stop sound
0a6d  6f 0a		; increment level state and stop sound

	; increment level state and stop sound
0a6f  21044e    ld      hl,#4e04
0a72  34        inc     (hl)
0a73  34        inc     (hl)
0a74  af        xor     a
0a75  32cc4e    ld      (#4ecc),a
0a78  32dc4e    ld      (#4edc),a
0a7b  c9        ret     

	;; we're about to start the next board, (it's about to be drawn)
0a7c  af        xor     a
0a7d  32cc4e    ld      (#4ecc),a
0a80  32dc4e    ld      (#4edc),a
0a83  0607      ld      b,#07
0a85  210c4e    ld      hl,#4e0c
0a88  cf        rst     #8
0a89  cdc924    call    #24c9
0a8c  21044e    ld      hl,#4e04
0a8f  34        inc     (hl)

	; level 255 pac fix ; HACK8
;0a90  c3800f    jp      #0f88      
;0a93  00        nop

	; level 141 mspac fix ; HACK9
;0a90  c3960f    jp      #0f96
;0a93  00        nop

0a90  21134e    ld      hl,#4e13	;; current board level
0a93  34        inc     (hl)		; increment board level
0a94  2a0a4e    ld      hl,(#4e0a)
0a97  7e        ld      a,(hl)
0a98  fe14      cp      #14
0a9a  c8        ret     z

0a9b  23        inc     hl
0a9c  220a4e    ld      (#4e0a),hl
0a9f  c9        ret     

0aa0  c38809    jp      #0988
0aa3  c3d209    jp      #09d2
0aa6  062e      ld      b,#2e
0aa8  dd210a4e  ld      ix,#4e0a
0aac  fd21384e  ld      iy,#4e38
0ab0  dd5600    ld      d,(ix+#00)
0ab3  fd5e00    ld      e,(iy+#00)
0ab6  fd7200    ld      (iy+#00),d
0ab9  dd7300    ld      (ix+#00),e
0abc  dd23      inc     ix
0abe  fd23      inc     iy
0ac0  10ee      djnz    #0ab0           ; (-18)
0ac2  c9        ret     

0ac3  3aa44d    ld      a,(#4da4)
0ac6  a7        and     a
0ac7  c0        ret     nz

0ac8  dd21004c  ld      ix,#4c00
0acc  fd21c84d  ld      iy,#4dc8
0ad0  110001    ld      de,#0100
0ad3  fdbe00    cp      (iy+#00)
0ad6  c2d20b    jp      nz,#0bd2
0ad9  fd36000e  ld      (iy+#00),#0e
0add  3aa64d    ld      a,(#4da6)
0ae0  a7        and     a
0ae1  281b      jr      z,#0afe         ; (27)
0ae3  2acb4d    ld      hl,(#4dcb)
0ae6  a7        and     a
0ae7  ed52      sbc     hl,de
0ae9  3013      jr      nc,#0afe        ; (19)
0aeb  21ac4e    ld      hl,#4eac
0aee  cbfe      set     7,(hl)
0af0  3e09      ld      a,#09
0af2  ddbe0b    cp      (ix+#0b)
0af5  2004      jr      nz,#0afb        ; (4)
0af7  cbbe      res     7,(hl)
0af9  3e09      ld      a,#09
0afb  320b4c    ld      (#4c0b),a
0afe  3aa74d    ld      a,(#4da7)
0b01  a7        and     a
0b02  281d      jr      z,#0b21         ; (29)
0b04  2acb4d    ld      hl,(#4dcb)
0b07  a7        and     a
0b08  ed52      sbc     hl,de
0b0a  3027      jr      nc,#0b33        ; (39)
0b0c  3e11      ld      a,#11
0b0e  ddbe03    cp      (ix+#03)
0b11  2807      jr      z,#0b1a         ; (7)
0b13  dd360311  ld      (ix+#03),#11
0b17  c3330b    jp      #0b33
0b1a  dd360312  ld      (ix+#03),#12
0b1e  c3330b    jp      #0b33
0b21  3e01      ld      a,#01
0b23  ddbe03    cp      (ix+#03)
0b26  2807      jr      z,#0b2f         ; (7)
0b28  dd360301  ld      (ix+#03),#01
0b2c  c3330b    jp      #0b33
0b2f  dd360301  ld      (ix+#03),#01
0b33  3aa84d    ld      a,(#4da8)
0b36  a7        and     a
0b37  281d      jr      z,#0b56         ; (29)
0b39  2acb4d    ld      hl,(#4dcb)
0b3c  a7        and     a
0b3d  ed52      sbc     hl,de
0b3f  3027      jr      nc,#0b68        ; (39)
0b41  3e11      ld      a,#11
0b43  ddbe05    cp      (ix+#05)
0b46  2807      jr      z,#0b4f         ; (7)
0b48  dd360511  ld      (ix+#05),#11
0b4c  c3680b    jp      #0b68
0b4f  dd360512  ld      (ix+#05),#12
0b53  c3680b    jp      #0b68
0b56  3e03      ld      a,#03
0b58  ddbe05    cp      (ix+#05)
0b5b  2807      jr      z,#0b64         ; (7)
0b5d  dd360503  ld      (ix+#05),#03
0b61  c3680b    jp      #0b68
0b64  dd360503  ld      (ix+#05),#03
0b68  3aa94d    ld      a,(#4da9)
0b6b  a7        and     a
0b6c  281d      jr      z,#0b8b         ; (29)
0b6e  2acb4d    ld      hl,(#4dcb)
0b71  a7        and     a
0b72  ed52      sbc     hl,de
0b74  3027      jr      nc,#0b9d        ; (39)
0b76  3e11      ld      a,#11
0b78  ddbe07    cp      (ix+#07)
0b7b  2807      jr      z,#0b84         ; (7)
0b7d  dd360711  ld      (ix+#07),#11
0b81  c39d0b    jp      #0b9d
0b84  dd360712  ld      (ix+#07),#12
0b88  c39d0b    jp      #0b9d
0b8b  3e05      ld      a,#05
0b8d  ddbe07    cp      (ix+#07)
0b90  2807      jr      z,#0b99         ; (7)
0b92  dd360705  ld      (ix+#07),#05
0b96  c39d0b    jp      #0b9d
0b99  dd360705  ld      (ix+#07),#05
0b9d  3aaa4d    ld      a,(#4daa)
0ba0  a7        and     a
0ba1  281d      jr      z,#0bc0         ; (29)
0ba3  2acb4d    ld      hl,(#4dcb)
0ba6  a7        and     a
0ba7  ed52      sbc     hl,de
0ba9  3027      jr      nc,#0bd2        ; (39)
0bab  3e11      ld      a,#11
0bad  ddbe09    cp      (ix+#09)
0bb0  2807      jr      z,#0bb9         ; (7)
0bb2  dd360911  ld      (ix+#09),#11
0bb6  c3d20b    jp      #0bd2
0bb9  dd360912  ld      (ix+#09),#12
0bbd  c3d20b    jp      #0bd2
0bc0  3e07      ld      a,#07
0bc2  ddbe09    cp      (ix+#09)
0bc5  2807      jr      z,#0bce         ; (7)
0bc7  dd360907  ld      (ix+#09),#07
0bcb  c3d20b    jp      #0bd2
0bce  dd360907  ld      (ix+#09),#07
0bd2  fd3500    dec     (iy+#00)
0bd5  c9        ret     

0bd6  0619      ld      b,#19
0bd8  3a024e    ld      a,(#4e02)
0bdb  fe22      cp      #22
0bdd  c2e20b    jp      nz,#0be2
0be0  0600      ld      b,#00
0be2  dd21004c  ld      ix,#4c00
0be6  3aac4d    ld      a,(#4dac)
0be9  a7        and     a
0bea  caf00b    jp      z,#0bf0
0bed  dd7003    ld      (ix+#03),b
0bf0  3aad4d    ld      a,(#4dad)
0bf3  a7        and     a
0bf4  cafa0b    jp      z,#0bfa
0bf7  dd7005    ld      (ix+#05),b
0bfa  3aae4d    ld      a,(#4dae)
0bfd  a7        and     a
0bfe  ca040c    jp      z,#0c04
0c01  dd7007    ld      (ix+#07),b
0c04  3aaf4d    ld      a,(#4daf)
0c07  a7        and     a
0c08  c8        ret     z

0c09  dd7009    ld      (ix+#09),b
0c0c  c9        ret     

0c0d  21cf4d    ld      hl,#4dcf
0c10  34        inc     (hl)
0c11  3e0a      ld      a,#0a
0c13  be        cp      (hl)
0c14  c0        ret     nz

0c15  3600      ld      (hl),#00
0c17  3a044e    ld      a,(#4e04)
0c1a  fe03      cp      #03
0c1c  2015      jr      nz,#0c33        ; (21)
0c1e  216444    ld      hl,#4464
0c21  c32495    jp      #9524
0c24  2002      jr      nz,#0c28        ; (2)
0c26  3e00      ld      a,#00
0c28  77        ld      (hl),a
0c29  327844    ld      (#4478),a
0c2c  328447    ld      (#4784),a
0c2f  329847    ld      (#4798),a
0c32  c9        ret     

0c33  213247    ld      hl,#4732
0c36  3e10      ld      a,#10
0c38  be        cp      (hl)
0c39  2002      jr      nz,#0c3d        ; (2)
0c3b  3e00      ld      a,#00
0c3d  77        ld      (hl),a
0c3e  327846    ld      (#4678),a
0c41  c9        ret     

0c42  3aa44d    ld      a,(#4da4)
0c45  a7        and     a
0c46  c0        ret     nz

0c47  3a944d    ld      a,(#4d94)
0c4a  07        rlca    
0c4b  32944d    ld      (#4d94),a
0c4e  d0        ret     nc

0c4f  3aa04d    ld      a,(#4da0)
0c52  a7        and     a
0c53  c2900c    jp      nz,#0c90
0c56  dd210533  ld      ix,#3305
0c5a  fd21004d  ld      iy,#4d00
0c5e  cd0020    call    #2000
0c61  22004d    ld      (#4d00),hl
0c64  3e03      ld      a,#03
0c66  32284d    ld      (#4d28),a
0c69  322c4d    ld      (#4d2c),a
0c6c  3a004d    ld      a,(#4d00)
0c6f  fe64      cp      #64
0c71  c2900c    jp      nz,#0c90
0c74  212c2e    ld      hl,#2e2c
0c77  220a4d    ld      (#4d0a),hl
0c7a  210001    ld      hl,#0100
0c7d  22144d    ld      (#4d14),hl
0c80  221e4d    ld      (#4d1e),hl
0c83  3e02      ld      a,#02
0c85  32284d    ld      (#4d28),a
0c88  322c4d    ld      (#4d2c),a
0c8b  3e01      ld      a,#01
0c8d  32a04d    ld      (#4da0),a
0c90  3aa14d    ld      a,(#4da1)
0c93  fe01      cp      #01
0c95  cafb0c    jp      z,#0cfb
0c98  fe00      cp      #00
0c9a  c2c10c    jp      nz,#0cc1
0c9d  3a024d    ld      a,(#4d02)
0ca0  fe78      cp      #78
0ca2  cc2e1f    call    z,#1f2e
0ca5  fe80      cp      #80
0ca7  cc2e1f    call    z,#1f2e
0caa  3a2d4d    ld      a,(#4d2d)
0cad  32294d    ld      (#4d29),a
0cb0  dd21204d  ld      ix,#4d20
0cb4  fd21024d  ld      iy,#4d02
0cb8  cd0020    call    #2000
0cbb  22024d    ld      (#4d02),hl
0cbe  c3fb0c    jp      #0cfb
0cc1  dd210533  ld      ix,#3305
0cc5  fd21024d  ld      iy,#4d02
0cc9  cd0020    call    #2000
0ccc  22024d    ld      (#4d02),hl
0ccf  3e03      ld      a,#03
0cd1  322d4d    ld      (#4d2d),a
0cd4  32294d    ld      (#4d29),a
0cd7  3a024d    ld      a,(#4d02)
0cda  fe64      cp      #64
0cdc  c2fb0c    jp      nz,#0cfb
0cdf  212c2e    ld      hl,#2e2c
0ce2  220c4d    ld      (#4d0c),hl
0ce5  210001    ld      hl,#0100
0ce8  22164d    ld      (#4d16),hl
0ceb  22204d    ld      (#4d20),hl
0cee  3e02      ld      a,#02
0cf0  32294d    ld      (#4d29),a
0cf3  322d4d    ld      (#4d2d),a
0cf6  3e01      ld      a,#01
0cf8  32a14d    ld      (#4da1),a
0cfb  3aa24d    ld      a,(#4da2)
0cfe  fe01      cp      #01
0d00  ca930d    jp      z,#0d93
0d03  fe00      cp      #00
0d05  c22c0d    jp      nz,#0d2c
0d08  3a044d    ld      a,(#4d04)
0d0b  fe78      cp      #78
0d0d  cc551f    call    z,#1f55
0d10  fe80      cp      #80
0d12  cc551f    call    z,#1f55
0d15  3a2e4d    ld      a,(#4d2e)
0d18  322a4d    ld      (#4d2a),a
0d1b  dd21224d  ld      ix,#4d22
0d1f  fd21044d  ld      iy,#4d04
0d23  cd0020    call    #2000
0d26  22044d    ld      (#4d04),hl
0d29  c3930d    jp      #0d93
0d2c  3aa24d    ld      a,(#4da2)
0d2f  fe03      cp      #03
0d31  c2590d    jp      nz,#0d59
0d34  dd21ff32  ld      ix,#32ff
0d38  fd21044d  ld      iy,#4d04
0d3c  cd0020    call    #2000
0d3f  22044d    ld      (#4d04),hl
0d42  af        xor     a
0d43  322a4d    ld      (#4d2a),a
0d46  322e4d    ld      (#4d2e),a
0d49  3a054d    ld      a,(#4d05)
0d4c  fe80      cp      #80
0d4e  c2930d    jp      nz,#0d93
0d51  3e02      ld      a,#02
0d53  32a24d    ld      (#4da2),a
0d56  c3930d    jp      #0d93
0d59  dd210533  ld      ix,#3305
0d5d  fd21044d  ld      iy,#4d04
0d61  cd0020    call    #2000
0d64  22044d    ld      (#4d04),hl
0d67  3e03      ld      a,#03
0d69  322a4d    ld      (#4d2a),a
0d6c  322e4d    ld      (#4d2e),a
0d6f  3a044d    ld      a,(#4d04)
0d72  fe64      cp      #64
0d74  c2930d    jp      nz,#0d93
0d77  212c2e    ld      hl,#2e2c
0d7a  220e4d    ld      (#4d0e),hl
0d7d  210001    ld      hl,#0100
0d80  22184d    ld      (#4d18),hl
0d83  22224d    ld      (#4d22),hl
0d86  3e02      ld      a,#02
0d88  322a4d    ld      (#4d2a),a
0d8b  322e4d    ld      (#4d2e),a
0d8e  3e01      ld      a,#01
0d90  32a24d    ld      (#4da2),a
0d93  3aa34d    ld      a,(#4da3)
0d96  fe01      cp      #01
0d98  c8        ret     z

0d99  fe00      cp      #00
0d9b  c2c00d    jp      nz,#0dc0
0d9e  3a064d    ld      a,(#4d06)
0da1  fe78      cp      #78
0da3  cc7c1f    call    z,#1f7c
0da6  fe80      cp      #80
0da8  cc7c1f    call    z,#1f7c
0dab  3a2f4d    ld      a,(#4d2f)
0dae  322b4d    ld      (#4d2b),a
0db1  dd21244d  ld      ix,#4d24
0db5  fd21064d  ld      iy,#4d06
0db9  cd0020    call    #2000
0dbc  22064d    ld      (#4d06),hl
0dbf  c9        ret     

0dc0  3aa34d    ld      a,(#4da3)
0dc3  fe03      cp      #03
0dc5  c2ea0d    jp      nz,#0dea
0dc8  dd210333  ld      ix,#3303
0dcc  fd21064d  ld      iy,#4d06
0dd0  cd0020    call    #2000
0dd3  22064d    ld      (#4d06),hl
0dd6  3e02      ld      a,#02
0dd8  322b4d    ld      (#4d2b),a
0ddb  322f4d    ld      (#4d2f),a
0dde  3a074d    ld      a,(#4d07)
0de1  fe80      cp      #80
0de3  c0        ret     nz

0de4  3e02      ld      a,#02
0de6  32a34d    ld      (#4da3),a
0de9  c9        ret     

0dea  dd210533  ld      ix,#3305
0dee  fd21064d  ld      iy,#4d06
0df2  cd0020    call    #2000
0df5  22064d    ld      (#4d06),hl
0df8  3e03      ld      a,#03
0dfa  322b4d    ld      (#4d2b),a
0dfd  322f4d    ld      (#4d2f),a
0e00  3a064d    ld      a,(#4d06)
0e03  fe64      cp      #64
0e05  c0        ret     nz

0e06  212c2e    ld      hl,#2e2c
0e09  22104d    ld      (#4d10),hl
0e0c  210001    ld      hl,#0100
0e0f  221a4d    ld      (#4d1a),hl
0e12  22244d    ld      (#4d24),hl
0e15  3e02      ld      a,#02
0e17  322b4d    ld      (#4d2b),a
0e1a  322f4d    ld      (#4d2f),a
0e1d  3e01      ld      a,#01
0e1f  32a34d    ld      (#4da3),a
0e22  c9        ret     

0e23  21c44d    ld      hl,#4dc4
0e26  34        inc     (hl)
0e27  3e08      ld      a,#08
0e29  be        cp      (hl)
0e2a  c0        ret     nz

0e2b  3600      ld      (hl),#00
0e2d  3ac04d    ld      a,(#4dc0)
0e30  ee01      xor     #01
0e32  32c04d    ld      (#4dc0),a
0e35  c9        ret     

0e36  3aa64d    ld      a,(#4da6)
0e39  a7        and     a
0e3a  c0        ret     nz

0e3b  3ac14d    ld      a,(#4dc1)
0e3e  fe07      cp      #07
0e40  c8        ret     z

0e41  87        add     a,a
0e42  2ac24d    ld      hl,(#4dc2)
0e45  23        inc     hl
0e46  22c24d    ld      (#4dc2),hl
0e49  5f        ld      e,a
0e4a  1600      ld      d,#00
0e4c  dd21864d  ld      ix,#4d86
0e50  dd19      add     ix,de
0e52  dd5e00    ld      e,(ix+#00)
0e55  dd5601    ld      d,(ix+#01)
0e58  a7        and     a
0e59  ed52      sbc     hl,de
0e5b  c0        ret     nz

0e5c  af        xor     a
0e5d  00        nop     
0e5e  3c        inc     a
0e5f  32c14d    ld      (#4dc1),a
0e62  210101    ld      hl,#0101
0e65  22b14d    ld      (#4db1),hl
0e68  22b34d    ld      (#4db3),hl
0e6b  c9        ret     

0e6c  3aa54d    ld      a,(#4da5)
0e6f  a7        and     a
0e70  2805      jr      z,#0e77         ; (5)
0e72  af        xor     a
0e73  32ac4e    ld      (#4eac),a
0e76  c9        ret     

0e77  21ac4e    ld      hl,#4eac
0e7a  06e0      ld      b,#e0
0e7c  3a0e4e    ld      a,(#4e0e)
0e7f  fee4      cp      #e4
0e81  3806      jr      c,#0e89         ; (6)
0e83  78        ld      a,b
0e84  a6        and     (hl)
0e85  cbe7      set     4,a
0e87  77        ld      (hl),a
0e88  c9        ret     

0e89  fed4      cp      #d4
0e8b  3806      jr      c,#0e93         ; (6)
0e8d  78        ld      a,b
0e8e  a6        and     (hl)
0e8f  cbdf      set     3,a
0e91  77        ld      (hl),a
0e92  c9        ret     

0e93  feb4      cp      #b4
0e95  3806      jr      c,#0e9d         ; (6)
0e97  78        ld      a,b
0e98  a6        and     (hl)
0e99  cbd7      set     2,a
0e9b  77        ld      (hl),a
0e9c  c9        ret     

0e9d  fe74      cp      #74
0e9f  3806      jr      c,#0ea7         ; (6)
0ea1  78        ld      a,b
0ea2  a6        and     (hl)
0ea3  cbcf      set     1,a
0ea5  77        ld      (hl),a
0ea6  c9        ret     

0ea7  78        ld      a,b
0ea8  a6        and     (hl)
0ea9  cbc7      set     0,a
0eab  77        ld      (hl),a
0eac  c9        ret     

0ead  c3ee86    jp      #86ee
0eb0  a7        and     a
0eb1  c0        ret     nz

0eb2  3ad44d    ld      a,(#4dd4)
0eb5  a7        and     a
0eb6  c0        ret     nz

0eb7  3a0e4e    ld      a,(#4e0e)
0eba  fe46      cp      #46
0ebc  280e      jr      z,#0ecc         ; (14)
0ebe  feaa      cp      #aa
0ec0  c0        ret     nz

0ec1  3a0d4e    ld      a,(#4e0d)
0ec4  a7        and     a
0ec5  c0        ret     nz

0ec6  210d4e    ld      hl,#4e0d
0ec9  34        inc     (hl)
0eca  1809      jr      #0ed5           ; (9)
0ecc  3a0c4e    ld      a,(#4e0c)
0ecf  a7        and     a
0ed0  c0        ret     nz

0ed1  210c4e    ld      hl,#4e0c
0ed4  34        inc     (hl)
0ed5  219480    ld      hl,#8094
0ed8  22d24d    ld      (#4dd2),hl
0edb  21fd0e    ld      hl,#0efd
0ede  3a134e    ld      a,(#4e13)	; compare board level with
0ee1  fe14      cp      #14		; 14
0ee3  3802      jr      c,#0ee7         ; (2)
0ee5  3e14      ld      a,#14
0ee7  47        ld      b,a
0ee8  87        add     a,a
0ee9  80        add     a,b
0eea  d7        rst     #10
0eeb  320c4c    ld      (#4c0c),a
0eee  23        inc     hl
0eef  7e        ld      a,(hl)
0ef0  320d4c    ld      (#4c0d),a
0ef3  23        inc     hl
0ef4  7e        ld      a,(hl)
0ef5  32d44d    ld      (#4dd4),a
0ef8  f7        rst     #30
0ef9  8a        adc     a,d
0efa  04        inc     b
0efb  00        nop     
0efc  c9        ret     

	;; $0efd - 0f3b = table for fruit shapes, colors, point value.
	;; (the 3 bytes are stored in the above order)

 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f

00000ef0                                          00 14 06  |             ...|
00000f00  01 0f 07 02 15 08 02 15  08 04 14 09 04 14 09 05  |................|
00000f10  17 0a 05 17 0a 06 09 0b  06 09 0b 03 16 0c 03 16  |................|
00000f20  0c 07 16 0d 07 16 0d 07  16 0d 07 16 0d 07 16 0d  |................|
00000f30  07 16 0d 07 16 0d 07 16  0d 07 16 0d              |............    |

;; shape 00   color 14   points 06 
;; shape 01   color 0f   points 07
;;  etc...

0f3c  00        nop     
0f3d  00        nop     
0f3e  00        nop     
0f3f  00        nop     
0f40  00        nop     
0f41  00        nop     
0f42  00        nop     
0f43  00        nop     
0f44  00        nop     
0f45  00        nop     
0f46  00        nop     
0f47  00        nop     
0f48  00        nop     
0f49  00        nop     
0f4a  00        nop     
0f4b  00        nop     
0f4c  00        nop     
0f4d  00        nop     
0f4e  00        nop     
0f4f  00        nop     
0f50  00        nop     
0f51  00        nop     
0f52  00        nop     
0f53  00        nop     
0f54  00        nop     
0f55  00        nop     
0f56  00        nop     
0f57  00        nop     
0f58  00        nop     
0f59  00        nop     
0f5a  00        nop     
0f5b  00        nop     

; start at 0f5c since 0f3c-0f5b is used in other romsets.

	;; Pause toggle ; HACK5

        ; start 1 enters pause, start 2 leaves pause
;0f5c  3a4050    ld      a,(#5040)       ; IN1
;0f5f  e620      and     #20             ; start 1
;0f61  c2db1f    jp      nz,#1fdb        ; nope. jump away
	;1fd0 for HACK3

        ; pause    
;0f64  f5        push    af
;0f65  af        xor     a               ; a=0
;0f66  320150    ld      (#5001),a       ; disable sound
;0f69  32c050    ld      (#50c0),a       ; kick dog
;0f6c  320050    ld      (#5000),a       ; disable interrupts
;0f6f  f3        di                      ; disable interrupts
;0f70  af        xor     a               ; a=0
;0f71  32c050    ld      (#50c0),a       ; kick dog
;0f74  3a4050    ld      a,(#5040)       ; IN1
;0f77  cb77      bit     6,a             ; start 2
;0f79  20f5      jr      nz,#0f70        ; not pressed, loop back

        ; turn it back on
;0f7b  3e01      ld      a,#01           ; a=1
;0f7d  320050    ld      (#5000),a       ; enable interrupts
;0f80  320150    ld      (#5001),a       ; enable sound
;0f83  fb        ei                      ; enable interrupts
;0f84  f1        pop     af              ; retore a
;0f85  c3db1f    jp      #1fdb           ; jump back


	; level 255 pac fix ; HACK8
;0f88  3a134e    ld      a,(#4e13)  	; board number
;0f8b  3c        inc     a
;0f8c  feff      cp      #ff
;0f8e  2803      jr      z,#0f93	; don't store level if == 255
;0f90  32134e    ld      (#4e13),a	; store new board number
;0f93  c3940a    jp      #0a94		; jump back

	; level 141 mspac fix ; HACK9
;0f96  3a134e    ld      a,(#4e13)	; board number
;0f99  3c        inc     a
;0f9a  f37b      cp      #7b		; compare to bad board point
;0f9c  2002      jr      nz,#0fa0	; don't store if out of range
;0f9e  d608      sub     #08		; loop around for all 8 boards
;0fa0  32134e    ld      (#4e13),a	; store the level number
;0fa3  c3940a    jp      #0a94		; return


0f5c  00        nop     
0f5d  00        nop     
0f5e  00        nop     
0f5f  00        nop     

0F60: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
0F70: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
0F80: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
0F90: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
0FA0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
0FB0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
0FC0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
0FD0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
0FE0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 00 00 ................
0FF0: 00 00 00 00 00 00 00 00-00 00 00 00 00 00 81 CE ................

0ff7  0a        ld      a,(bc)
0ff8  ed0c      tst     c
0ffa  14        inc     d
0ffb  0a        ld      a,(bc)
0ffc  00        nop     
0ffd  08        ex      af,af'
0ffe  48        ld      c,b
0fff  36

    ;; blink coin lights to pellets ; HACK11
0ffe  e089				; checksum patch

	; clear fruit
1000  af        xor     a
1001  32d44d    ld      (#4dd4),a
1004  c9        ret     

1005  00        nop     
1006  00        nop     
1007  22d24d    ld      (#4dd2),hl
100a  c9        ret     

100b  c37836    jp      #3678
100e  3a004e    ld      a,(#4e00)
1011  3d        dec     a
1012  c8        ret     z

1013  ef        rst     #28
1014  1ca2
1016  c9        ret     

1017  cd9112    call    #1291
101a  3aa54d    ld      a,(#4da5)
101d  a7        and     a
101e  c0        ret     nz

101f  cd6610    call    #1066
1022  cd9410    call    #1094
1025  cd9e10    call    #109e
1028  cda810    call    #10a8
102b  cdb410    call    #10b4
102e  3aa44d    ld      a,(#4da4)
1031  a7        and     a
1032  ca3910    jp      z,#1039
1035  cd3512    call    #1235
1038  c9        ret     

1039  cd1d17    call    #171d
103c  cd8917    call    #1789		; check for collision with blue ghost
103f  3aa44d    ld      a,(#4da4)
1042  a7        and     a
1043  c0        ret     nz

1044  cd0618    call    #1806
1047  cd361b    call    #1b36
104a  cd4b1c    call    #1c4b
104d  cd221d    call    #1d22
1050  cdf91d    call    #1df9
1053  3a044e    ld      a,(#4e04)
1056  fe03      cp      #03
1058  c0        ret     nz

1059  cd7613    call    #1376		; control blue time
105c  cd6920    call    #2069
105f  cd8c20    call    #208c
1062  cdaf20    call    #20af
1065  c9        ret     

1066  3aab4d    ld      a,(#4dab)
1069  a7        and     a
106a  c8        ret     z

106b  3d        dec     a
106c  2008      jr      nz,#1076        ; (8)
106e  32ab4d    ld      (#4dab),a
1071  3c        inc     a
1072  32ac4d    ld      (#4dac),a
1075  c9        ret     

1076  3d        dec     a
1077  2008      jr      nz,#1081        ; (8)
1079  32ab4d    ld      (#4dab),a
107c  3c        inc     a
107d  32ad4d    ld      (#4dad),a
1080  c9        ret     

1081  3d        dec     a
1082  2008      jr      nz,#108c        ; (8)
1084  32ab4d    ld      (#4dab),a
1087  3c        inc     a
1088  32ae4d    ld      (#4dae),a
108b  c9        ret     

108c  32af4d    ld      (#4daf),a
108f  3d        dec     a
1090  32ab4d    ld      (#4dab),a
1093  c9        ret     

1094  3aac4d    ld      a,(#4dac)
1097  e7        rst     #20
1098  0c        inc     c
1099  00        nop     
109a  c0        ret     nz

109b  10d2      djnz    #106f           ; (-46)
109d  103a      djnz    #10d9           ; (58)
109f  ad        xor     l
10a0  4d        ld      c,l
10a1  e7        rst     #20
10a2  0c        inc     c
10a3  00        nop     
10a4  1811      jr      #10b7           ; (17)
10a6  2a113a    ld      hl,(#3a11)
10a9  ae        xor     (hl)
10aa  4d        ld      c,l
10ab  e7        rst     #20
10ac  0c        inc     c
10ad  00        nop     
10ae  5c        ld      e,h
10af  116e11    ld      de,#116e
10b2  8f        adc     a,a
10b3  113aaf    ld      de,#af3a
10b6  4d        ld      c,l
10b7  e7        rst     #20
10b8  0c        inc     c
10b9  00        nop     
10ba  c9        ret     

10bb  11db11    ld      de,#11db
10be  fc11cd    call    m,#cd11
10c1  d8        ret     c

10c2  1b        dec     de
10c3  2a004d    ld      hl,(#4d00)
10c6  116480    ld      de,#8064
10c9  a7        and     a
10ca  ed52      sbc     hl,de
10cc  c0        ret     nz

10cd  21ac4d    ld      hl,#4dac
10d0  34        inc     (hl)
10d1  c9        ret     

10d2  dd210133  ld      ix,#3301
10d6  fd21004d  ld      iy,#4d00
10da  cd0020    call    #2000
10dd  22004d    ld      (#4d00),hl
10e0  3e01      ld      a,#01
10e2  32284d    ld      (#4d28),a
10e5  322c4d    ld      (#4d2c),a
10e8  3a004d    ld      a,(#4d00)
10eb  fe80      cp      #80
10ed  c0        ret     nz

10ee  212f2e    ld      hl,#2e2f
10f1  220a4d    ld      (#4d0a),hl
10f4  22314d    ld      (#4d31),hl
10f7  af        xor     a
10f8  32a04d    ld      (#4da0),a
10fb  32ac4d    ld      (#4dac),a
10fe  32a74d    ld      (#4da7),a
1101  dd21ac4d  ld      ix,#4dac
1105  ddb600    or      (ix+#00)
1108  ddb601    or      (ix+#01)
110b  ddb602    or      (ix+#02)
110e  ddb603    or      (ix+#03)
1111  c0        ret     nz

1112  21ac4e    ld      hl,#4eac
1115  cbb6      res     6,(hl)
1117  c9        ret     

1118  cdaf1c    call    #1caf
111b  2a024d    ld      hl,(#4d02)
111e  116480    ld      de,#8064
1121  a7        and     a
1122  ed52      sbc     hl,de
1124  c0        ret     nz

1125  21ad4d    ld      hl,#4dad
1128  34        inc     (hl)
1129  c9        ret     

112a  dd210133  ld      ix,#3301
112e  fd21024d  ld      iy,#4d02
1132  cd0020    call    #2000
1135  22024d    ld      (#4d02),hl
1138  3e01      ld      a,#01
113a  32294d    ld      (#4d29),a
113d  322d4d    ld      (#4d2d),a
1140  3a024d    ld      a,(#4d02)
1143  fe80      cp      #80
1145  c0        ret     nz

1146  212f2e    ld      hl,#2e2f
1149  220c4d    ld      (#4d0c),hl
114c  22334d    ld      (#4d33),hl
114f  af        xor     a
1150  32a14d    ld      (#4da1),a
1153  32ad4d    ld      (#4dad),a
1156  32a84d    ld      (#4da8),a
1159  c30111    jp      #1101
115c  cd861d    call    #1d86
115f  2a044d    ld      hl,(#4d04)
1162  116480    ld      de,#8064
1165  a7        and     a
1166  ed52      sbc     hl,de
1168  c0        ret     nz

1169  21ae4d    ld      hl,#4dae
116c  34        inc     (hl)
116d  c9        ret     

116e  dd210133  ld      ix,#3301
1172  fd21044d  ld      iy,#4d04
1176  cd0020    call    #2000
1179  22044d    ld      (#4d04),hl
117c  3e01      ld      a,#01
117e  322a4d    ld      (#4d2a),a
1181  322e4d    ld      (#4d2e),a
1184  3a044d    ld      a,(#4d04)
1187  fe80      cp      #80
1189  c0        ret     nz

118a  21ae4d    ld      hl,#4dae
118d  34        inc     (hl)
118e  c9        ret     

118f  dd210333  ld      ix,#3303
1193  fd21044d  ld      iy,#4d04
1197  cd0020    call    #2000
119a  22044d    ld      (#4d04),hl
119d  3e02      ld      a,#02
119f  322a4d    ld      (#4d2a),a
11a2  322e4d    ld      (#4d2e),a
11a5  3a054d    ld      a,(#4d05)
11a8  fe90      cp      #90
11aa  c0        ret     nz

11ab  212f30    ld      hl,#302f
11ae  220e4d    ld      (#4d0e),hl
11b1  22354d    ld      (#4d35),hl
11b4  3e01      ld      a,#01
11b6  322a4d    ld      (#4d2a),a
11b9  322e4d    ld      (#4d2e),a
11bc  af        xor     a
11bd  32a24d    ld      (#4da2),a
11c0  32ae4d    ld      (#4dae),a
11c3  32a94d    ld      (#4da9),a
11c6  c30111    jp      #1101
11c9  cd5d1e    call    #1e5d
11cc  2a064d    ld      hl,(#4d06)
11cf  116480    ld      de,#8064
11d2  a7        and     a
11d3  ed52      sbc     hl,de
11d5  c0        ret     nz

11d6  21af4d    ld      hl,#4daf
11d9  34        inc     (hl)
11da  c9        ret     

11db  dd210133  ld      ix,#3301
11df  fd21064d  ld      iy,#4d06
11e3  cd0020    call    #2000
11e6  22064d    ld      (#4d06),hl
11e9  3e01      ld      a,#01
11eb  322b4d    ld      (#4d2b),a
11ee  322f4d    ld      (#4d2f),a
11f1  3a064d    ld      a,(#4d06)
11f4  fe80      cp      #80
11f6  c0        ret     nz

11f7  21af4d    ld      hl,#4daf
11fa  34        inc     (hl)
11fb  c9        ret     

11fc  dd21ff32  ld      ix,#32ff
1200  fd21064d  ld      iy,#4d06
1204  cd0020    call    #2000
1207  22064d    ld      (#4d06),hl
120a  af        xor     a
120b  322b4d    ld      (#4d2b),a
120e  322f4d    ld      (#4d2f),a
1211  3a074d    ld      a,(#4d07)
1214  fe70      cp      #70
1216  c0        ret     nz

1217  212f2c    ld      hl,#2c2f
121a  22104d    ld      (#4d10),hl
121d  22374d    ld      (#4d37),hl
1220  3e01      ld      a,#01
1222  322b4d    ld      (#4d2b),a
1225  322f4d    ld      (#4d2f),a
1228  af        xor     a
1229  32a34d    ld      (#4da3),a
122c  32af4d    ld      (#4daf),a
122f  32aa4d    ld      (#4daa),a
1232  c30111    jp      #1101
1235  3ad14d    ld      a,(#4dd1)
1238  e7        rst     #20
1239  3f        ccf     
123a  12        ld      (de),a
123b  0c        inc     c
123c  00        nop     
123d  3f        ccf     
123e  12        ld      (de),a
123f  21004c    ld      hl,#4c00
1242  3aa44d    ld      a,(#4da4)
1245  87        add     a,a
1246  5f        ld      e,a
1247  1600      ld      d,#00
1249  19        add     hl,de
124a  3ad14d    ld      a,(#4dd1)
124d  a7        and     a
124e  2027      jr      nz,#1277        ; (39)
1250  3ad04d    ld      a,(#4dd0)
1253  0627      ld      b,#27
1255  80        add     a,b
1256  47        ld      b,a
1257  3a724e    ld      a,(#4e72)
125a  4f        ld      c,a
125b  3a094e    ld      a,(#4e09)
125e  a1        and     c
125f  2804      jr      z,#1265         ; (4)
1261  cbf0      set     6,b
1263  cbf8      set     7,b
1265  70        ld      (hl),b
1266  23        inc     hl
1267  3618      ld      (hl),#18
1269  3e00      ld      a,#00
126b  320b4c    ld      (#4c0b),a
126e  f7        rst     #30
126f  4a        ld      c,d
1270  03        inc     bc
1271  00        nop     
1272  21d14d    ld      hl,#4dd1
1275  34        inc     (hl)
1276  c9        ret     

1277  3620      ld      (hl),#20
1279  3e09      ld      a,#09
127b  320b4c    ld      (#4c0b),a
127e  3aa44d    ld      a,(#4da4)
1281  32ab4d    ld      (#4dab),a
1284  af        xor     a
1285  32a44d    ld      (#4da4),a
1288  32d14d    ld      (#4dd1),a
128b  21ac4e    ld      hl,#4eac
128e  cbf6      set     6,(hl)
1290  c9        ret     

1291  3aa54d    ld      a,(#4da5)
1294  e7        rst     #20

	; dereferencing table of some kind
	00c0
	12b7
	12b7
	12b7
	12b7
	12bc
	12f9
	1306
	etc...
	
1295  0c        inc     c	
1296  00        nop     
1297  b7        or      a
1298  12        ld      (de),a
1299  b7        or      a
129a  12        ld      (de),a
129b  b7        or      a
129c  12        ld      (de),a
129d  b7        or      a
129e  12        ld      (de),a
129f  cb12      rl      d
12a1  f9        ld      sp,hl
12a2  12        ld      (de),a
12a3  0613      ld      b,#13
12a5  0e13      ld      c,#13
12a7  1613      ld      d,#13
12a9  1e13      ld      e,#13
12ab  2613      ld      h,#13
12ad  2e13      ld      l,#13
12af  3613      ld      (hl),#13
12b1  3e13      ld      a,#13
12b3  46        ld      b,(hl)
12b4  13        inc     de
12b5  53        ld      d,e
12b6  13        inc     de
12b7  2ac54d    ld      hl,(#4dc5)
12ba  23        inc     hl
12bb  22c54d    ld      (#4dc5),hl
12be  117800    ld      de,#0078
12c1  a7        and     a
12c2  ed52      sbc     hl,de
12c4  c0        ret     nz

12c5  3e05      ld      a,#05
12c7  32a54d    ld      (#4da5),a
12ca  c9        ret     

	; adjust mspac sprite animation?
12cb  210000    ld      hl,#0000
12ce  cd7e26    call    #267e
12d1  3e34      ld      a,#34
12d3  11b400    ld      de,#00b4
12d6  4f        ld      c,a
12d7  3a724e    ld      a,(#4e72)
12da  47        ld      b,a
12db  3a094e    ld      a,(#4e09)
12de  a0        and     b
12df  2804      jr      z,#12e5         ; (4)
12e1  3ec0      ld      a,#c0
12e3  b1        or      c
12e4  4f        ld      c,a
12e5  79        ld      a,c
12e6  320a4c    ld      (#4c0a),a	; mspac sprite number
12e9  2ac54d    ld      hl,(#4dc5)
12ec  23        inc     hl
12ed  22c54d    ld      (#4dc5),hl
12f0  a7        and     a
12f1  ed52      sbc     hl,de
12f3  c0        ret     nz

12f4  21a54d    ld      hl,#4da5
12f7  34        inc     (hl)
12f8  c9        ret     

12f9  21bc4e    ld      hl,#4ebc
12fc  cbe6      set     4,(hl)
12fe  3e35      ld      a,#35
1300  11c300    ld      de,#00c3
1303  c3d612    jp      #12d6
1306  3e36      ld      a,#36
1308  11d200    ld      de,#00d2
130b  c3d612    jp      #12d6
130e  3e37      ld      a,#37
1310  11e100    ld      de,#00e1
1313  c3d612    jp      #12d6
1316  3e38      ld      a,#38
1318  11f000    ld      de,#00f0
131b  c3d612    jp      #12d6
131e  3e39      ld      a,#39
1320  11ff00    ld      de,#00ff
1323  c3d612    jp      #12d6
1326  3e3a      ld      a,#3a
1328  110e01    ld      de,#010e
132b  c3d612    jp      #12d6
132e  3e3b      ld      a,#3b
1330  111d01    ld      de,#011d
1333  c3d612    jp      #12d6
1336  3e3c      ld      a,#3c
1338  112c01    ld      de,#012c
133b  c3d612    jp      #12d6
133e  3e3d      ld      a,#3d
1340  113b01    ld      de,#013b
1343  c3d612    jp      #12d6
1346  21bc4e    ld      hl,#4ebc
1349  3600      ld      (hl),#00
134b  3e3e      ld      a,#3e
134d  115901    ld      de,#0159
1350  c3d612    jp      #12d6


	; game end tests?
1353  3e3f      ld      a,#3f
1355  320a4c    ld      (#4c0a),a	; mspac sprite number
1358  2ac54d    ld      hl,(#4dc5)
135b  23        inc     hl
135c  22c54d    ld      (#4dc5),hl
135f  11b801    ld      de,#01b8
1362  a7        and     a
1363  ed52      sbc     hl,de
1365  c0        ret     nz

	;; decrement lives  
	;   this gets called after the death animation, but before the
	;   screen gets redrawn.
	;  -- probably a good hook point for 'insert coin to contunue' --

1366  21144e    ld      hl,#4e14	; hl = number of lives left
1369  35        dec     (hl)		; subtract 1
136a  21154e    ld      hl,#4e15	; hl = number of lives on screen
136d  35        dec     (hl)		; subtract 1
136e  cd7526    call    #2675
1371  21044e    ld      hl,#4e04	; 3=ghost move  2=ghost wait
1374  34        inc     (hl)
1375  c9        ret     


	;; routine to control blue time
	;; ret immediately to make ghosts stay blue till eaten 

1376  3aa64d    ld      a,(#4da6)
1379  a7        and     a
137a  c8        ret     z

137b  dd21a74d  ld      ix,#4da7
137f  dd7e00    ld      a,(ix+#00)
1382  ddb601    or      (ix+#01)
1385  ddb602    or      (ix+#02)
1388  ddb603    or      (ix+#03)
138b  ca9813    jp      z,#1398
138e  2acb4d    ld      hl,(#4dcb)
1391  2b        dec     hl
1392  22cb4d    ld      (#4dcb),hl
1395  7c        ld      a,h
1396  b5        or      l
1397  c0        ret     nz

1398  210b4c    ld      hl,#4c0b
139b  3609      ld      (hl),#09
139d  3aac4d    ld      a,(#4dac)
13a0  a7        and     a
13a1  c2a713    jp      nz,#13a7
13a4  32a74d    ld      (#4da7),a
13a7  3aad4d    ld      a,(#4dad)
13aa  a7        and     a
13ab  c2b113    jp      nz,#13b1
13ae  32a84d    ld      (#4da8),a
13b1  3aae4d    ld      a,(#4dae)
13b4  a7        and     a
13b5  c2bb13    jp      nz,#13bb
13b8  32a94d    ld      (#4da9),a
13bb  3aaf4d    ld      a,(#4daf)
13be  a7        and     a
13bf  c2c513    jp      nz,#13c5
13c2  32aa4d    ld      (#4daa),a
13c5  af        xor     a
13c6  32cb4d    ld      (#4dcb),a
13c9  32cc4d    ld      (#4dcc),a
13cc  32a64d    ld      (#4da6),a
13cf  32c84d    ld      (#4dc8),a
13d2  32d04d    ld      (#4dd0),a
13d5  21ac4e    ld      hl,#4eac
13d8  cbae      res     5,(hl)
13da  cbbe      res     7,(hl)
13dc  c9        ret     

13dd  219e4d    ld      hl,#4d9e
13e0  3a0e4e    ld      a,(#4e0e)
13e3  be        cp      (hl)
13e4  caee13    jp      z,#13ee
13e7  210000    ld      hl,#0000
13ea  22974d    ld      (#4d97),hl
13ed  c9        ret     

13ee  2a974d    ld      hl,(#4d97)
13f1  23        inc     hl
13f2  22974d    ld      (#4d97),hl
13f5  ed5b954d  ld      de,(#4d95)
13f9  a7        and     a
13fa  ed52      sbc     hl,de
13fc  c0        ret     nz

13fd  210000    ld      hl,#0000
1400  22974d    ld      (#4d97),hl
1403  3aa14d    ld      a,(#4da1)
1406  a7        and     a
1407  f5        push    af
1408  cc8620    call    z,#2086
140b  f1        pop     af
140c  c8        ret     z

140d  3aa24d    ld      a,(#4da2)
1410  a7        and     a
1411  f5        push    af
1412  cca920    call    z,#20a9
1415  f1        pop     af
1416  c8        ret     z

1417  3aa34d    ld      a,(#4da3)
141a  a7        and     a
141b  ccd120    call    z,#20d1
141e  c9        ret     

141f  3a724e    ld      a,(#4e72)
1422  47        ld      b,a
1423  3a094e    ld      a,(#4e09)
1426  a0        and     b
1427  c8        ret     z

1428  47        ld      b,a
1429  dd21004c  ld      ix,#4c00
142d  1e08      ld      e,#08
142f  0e08      ld      c,#08
1431  1607      ld      d,#07

	;; this looks to be some kind of data?  it's ver repetitions till 1500
1433  3a004d    ld      a,(#4d00)
1436  83        add     a,e
1437  dd7713    ld      (ix+#13),a
143a  3a014d    ld      a,(#4d01)
143d  2f        cpl     
143e  82        add     a,d
143f  dd7712    ld      (ix+#12),a
1442  3a024d    ld      a,(#4d02)
1445  83        add     a,e
1446  dd7715    ld      (ix+#15),a
1449  3a034d    ld      a,(#4d03)
144c  2f        cpl     
144d  82        add     a,d
144e  dd7714    ld      (ix+#14),a
1451  3a044d    ld      a,(#4d04)
1454  83        add     a,e
1455  dd7717    ld      (ix+#17),a
1458  3a054d    ld      a,(#4d05)
145b  2f        cpl     
145c  81        add     a,c
145d  dd7716    ld      (ix+#16),a
1460  3a064d    ld      a,(#4d06)
1463  83        add     a,e
1464  dd7719    ld      (ix+#19),a
1467  3a074d    ld      a,(#4d07)
146a  2f        cpl     
146b  81        add     a,c
146c  dd7718    ld      (ix+#18),a
146f  3a084d    ld      a,(#4d08)
1472  83        add     a,e
1473  dd771b    ld      (ix+#1b),a
1476  3a094d    ld      a,(#4d09)
1479  2f        cpl     
147a  81        add     a,c
147b  dd771a    ld      (ix+#1a),a
147e  3ad24d    ld      a,(#4dd2)
1481  83        add     a,e
1482  dd771d    ld      (ix+#1d),a
1485  3ad34d    ld      a,(#4dd3)
1488  2f        cpl     
1489  81        add     a,c
148a  dd771c    ld      (ix+#1c),a
148d  c3fe14    jp      #14fe


	;; display the sprites in the intro and game
1490  3a724e    ld      a,(#4e72)
1493  47        ld      b,a
1494  3a094e    ld      a,(#4e09)
1497  a0        and     b
1498  c0        ret     nz

1499  47        ld      b,a
149a  1e09      ld      e,#09
149c  0e07      ld      c,#07
149e  1606      ld      d,#06
14a0  dd21004c  ld      ix,#4c00
14a4  3a004d    ld      a,(#4d00)
14a7  2f        cpl     
14a8  83        add     a,e
14a9  dd7713    ld      (ix+#13),a
14ac  3a014d    ld      a,(#4d01)
14af  82        add     a,d
14b0  dd7712    ld      (ix+#12),a
14b3  3a024d    ld      a,(#4d02)
14b6  2f        cpl     
14b7  83        add     a,e
14b8  dd7715    ld      (ix+#15),a
14bb  3a034d    ld      a,(#4d03)
14be  82        add     a,d
14bf  dd7714    ld      (ix+#14),a
14c2  3a044d    ld      a,(#4d04)
14c5  2f        cpl     
14c6  83        add     a,e
14c7  dd7717    ld      (ix+#17),a
14ca  3a054d    ld      a,(#4d05)
14cd  81        add     a,c
14ce  dd7716    ld      (ix+#16),a
14d1  3a064d    ld      a,(#4d06)
14d4  2f        cpl     
14d5  83        add     a,e
14d6  dd7719    ld      (ix+#19),a
14d9  3a074d    ld      a,(#4d07)
14dc  81        add     a,c
14dd  dd7718    ld      (ix+#18),a
14e0  3a084d    ld      a,(#4d08)
14e3  2f        cpl     
14e4  83        add     a,e
14e5  dd771b    ld      (ix+#1b),a
14e8  3a094d    ld      a,(#4d09)
14eb  81        add     a,c
14ec  dd771a    ld      (ix+#1a),a
14ef  3ad24d    ld      a,(#4dd2)
14f2  2f        cpl     
14f3  83        add     a,e
14f4  dd771d    ld      (ix+#1d),a
14f7  3ad34d    ld      a,(#4dd3)
14fa  81        add     a,c
14fb  dd771c    ld      (ix+#1c),a
14fe  3aa54d    ld      a,(#4da5)
1501  a7        and     a
1502  c24b15    jp      nz,#154b
1505  3aa44d    ld      a,(#4da4)
1508  a7        and     a
1509  c2b415    jp      nz,#15b4
150c  211c15    ld      hl,#151c
150f  e5        push    hl
1510  3a304d    ld      a,(#4d30)
1513  e7        rst     #20
1514  8c        adc     a,h
1515  16b1      ld      d,#b1
1517  16d6      ld      d,#d6
1519  16f7      ld      d,#f7
151b  1678      ld      d,#78
151d  a7        and     a
151e  282b      jr      z,#154b         ; (43)
1520  0ec0      ld      c,#c0
1522  3a0a4c    ld      a,(#4c0a)	; mspac sprite number
1525  57        ld      d,a
1526  a1        and     c
1527  2005      jr      nz,#152e        ; (5)
1529  7a        ld      a,d
152a  b1        or      c
152b  c34815    jp      #1548
152e  3a304d    ld      a,(#4d30)
1531  fe02      cp      #02
1533  2009      jr      nz,#153e        ; (9)
1535  cb7a      bit     7,d
1537  2812      jr      z,#154b         ; (18)
1539  7a        ld      a,d
153a  a9        xor     c
153b  c34815    jp      #1548
153e  fe03      cp      #03
1540  2009      jr      nz,#154b        ; (9)
1542  cb72      bit     6,d
1544  2805      jr      z,#154b         ; (5)
1546  7a        ld      a,d
1547  a9        xor     c
1548  320a4c    ld      (#4c0a),a	; mspac sprite number
154b  21c04d    ld      hl,#4dc0
154e  56        ld      d,(hl)
154f  3e1c      ld      a,#1c
1551  82        add     a,d
1552  dd7702    ld      (ix+#02),a
1555  dd7704    ld      (ix+#04),a
1558  dd7706    ld      (ix+#06),a
155b  dd7708    ld      (ix+#08),a
155e  0e20      ld      c,#20
1560  3aac4d    ld      a,(#4dac)
1563  a7        and     a
1564  2006      jr      nz,#156c        ; (6)
1566  3aa74d    ld      a,(#4da7)
1569  a7        and     a
156a  2009      jr      nz,#1575        ; (9)
156c  3a2c4d    ld      a,(#4d2c)
156f  87        add     a,a
1570  82        add     a,d
1571  81        add     a,c
1572  dd7702    ld      (ix+#02),a
1575  3aad4d    ld      a,(#4dad)
1578  a7        and     a
1579  2006      jr      nz,#1581        ; (6)
157b  3aa84d    ld      a,(#4da8)
157e  a7        and     a
157f  2009      jr      nz,#158a        ; (9)
1581  3a2d4d    ld      a,(#4d2d)
1584  87        add     a,a
1585  82        add     a,d
1586  81        add     a,c
1587  dd7704    ld      (ix+#04),a
158a  3aae4d    ld      a,(#4dae)
158d  a7        and     a
158e  2006      jr      nz,#1596        ; (6)
1590  3aa94d    ld      a,(#4da9)
1593  a7        and     a
1594  2009      jr      nz,#159f        ; (9)
1596  3a2e4d    ld      a,(#4d2e)
1599  87        add     a,a
159a  82        add     a,d
159b  81        add     a,c
159c  dd7706    ld      (ix+#06),a
159f  3aaf4d    ld      a,(#4daf)
15a2  a7        and     a
15a3  2006      jr      nz,#15ab        ; (6)
15a5  3aaa4d    ld      a,(#4daa)
15a8  a7        and     a
15a9  2009      jr      nz,#15b4        ; (9)
15ab  3a2f4d    ld      a,(#4d2f)
15ae  87        add     a,a
15af  82        add     a,d
15b0  81        add     a,c
15b1  dd7708    ld      (ix+#08),a
15b4  cde615    call    #15e6
15b7  cd2d16    call    #162d
15ba  cd5216    call    #1652
15bd  78        ld      a,b
15be  a7        and     a
15bf  c8        ret     z

15c0  0ec0      ld      c,#c0
15c2  3a024c    ld      a,(#4c02)
15c5  b1        or      c
15c6  32024c    ld      (#4c02),a
15c9  3a044c    ld      a,(#4c04)
15cc  b1        or      c
15cd  32044c    ld      (#4c04),a
15d0  3a064c    ld      a,(#4c06)
15d3  b1        or      c
15d4  32064c    ld      (#4c06),a
15d7  3a084c    ld      a,(#4c08)
15da  b1        or      c
15db  32084c    ld      (#4c08),a
15de  3a0c4c    ld      a,(#4c0c)
15e1  b1        or      c
15e2  320c4c    ld      (#4c0c),a
15e5  c9        ret     

15e6  3a064e    ld      a,(#4e06)
15e9  d605      sub     #05
15eb  d8        ret     c

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

162d  3a074e    ld      a,(#4e07)
1630  a7        and     a
1631  c8        ret     z

	; check for pac moving though the other tunnel?
1632  57        ld      d,a
1633  3a3a4d    ld      a,(#4d3a)
1636  d63d      sub     #3d
1638  2004      jr      nz,#163e        ; (4)
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

1652  3a084e    ld      a,(#4e08)	; partial difficulty?
1655  a7        and     a
1656  c8        ret     z

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

168c  c39c86    jp      #869c
168f  c9        ret     

1690  07        rlca    
1691  fe06      cp      #06
1693  3805      jr      c,#169a         ; (5)
1695  dd360a30  ld      (ix+#0a),#30
1699  c9        ret     

169a  fe04      cp      #04
169c  3805      jr      c,#16a3         ; (5)
169e  dd360a2e  ld      (ix+#0a),#2e
16a2  c9        ret     

16a3  fe02      cp      #02
16a5  3805      jr      c,#16ac         ; (5)
16a7  dd360a2c  ld      (ix+#0a),#2c
16ab  c9        ret     

16ac  dd360a2e  ld      (ix+#0a),#2e
16b0  c9        ret     

16b1  c3b186    jp      #86b1
16b4  c9        ret     

16b5  07        rlca    
16b6  fe06      cp      #06
16b8  3805      jr      c,#16bf         ; (5)
16ba  dd360a2f  ld      (ix+#0a),#2f
16be  c9        ret     

16bf  fe04      cp      #04
16c1  3805      jr      c,#16c8         ; (5)
16c3  dd360a2d  ld      (ix+#0a),#2d
16c7  c9        ret     

16c8  fe02      cp      #02
16ca  3805      jr      c,#16d1         ; (5)
16cc  dd360a2f  ld      (ix+#0a),#2f
16d0  c9        ret     

16d1  dd360a30  ld      (ix+#0a),#30
16d5  c9        ret     

16d6  3a094d    ld      a,(#4d09)
16d9  c3c586    jp      #86c5
16dc  c9        ret     

16dd  3808      jr      c,#16e7         ; (8)
16df  1e2e      ld      e,#2e
16e1  cbfb      set     7,e
16e3  dd730a    ld      (ix+#0a),e
16e6  c9        ret     

16e7  fe04      cp      #04
16e9  3804      jr      c,#16ef         ; (4)
16eb  1e2c      ld      e,#2c
16ed  18f2      jr      #16e1           ; (-14)
16ef  fe02      cp      #02
16f1  30ec      jr      nc,#16df        ; (-20)
16f3  1e30      ld      e,#30
16f5  18ea      jr      #16e1           ; (-22)
16f7  3a084d    ld      a,(#4d08)
16fa  c3d986    jp      #86d9
16fd  c9        ret     

16fe  3805      jr      c,#1705         ; (5)
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

171d  0604      ld      b,#04
171f  ed5b394d  ld      de,(#4d39)
1723  3aaf4d    ld      a,(#4daf)
1726  a7        and     a
1727  2009      jr      nz,#1732        ; (9)
1729  2a374d    ld      hl,(#4d37)
172c  a7        and     a
172d  ed52      sbc     hl,de
172f  ca6317    jp      z,#1763		; check for collision with ghost
1732  05        dec     b
1733  3aae4d    ld      a,(#4dae)
1736  a7        and     a
1737  2009      jr      nz,#1742        ; (9)
1739  2a354d    ld      hl,(#4d35)
173c  a7        and     a
173d  ed52      sbc     hl,de
173f  ca6317    jp      z,#1763
1742  05        dec     b
1743  3aad4d    ld      a,(#4dad)
1746  a7        and     a
1747  2009      jr      nz,#1752        ; (9)
1749  2a334d    ld      hl,(#4d33)
174c  a7        and     a
174d  ed52      sbc     hl,de
174f  ca6317    jp      z,#1763
1752  05        dec     b
1753  3aac4d    ld      a,(#4dac)
1756  a7        and     a
1757  2009      jr      nz,#1762        ; (9)
1759  2a314d    ld      hl,(#4d31)
175c  a7        and     a
175d  ed52      sbc     hl,de
175f  ca6317    jp      z,#1763
1762  05        dec     b
1763  78        ld      a,b		; collision detection routine
1764  32a44d    ld      (#4da4),a
	; invincibility check ; HACK3
;1764 c3b01f    jp      #1fb0

1767  32a54d    ld      (#4da5),a
176a  a7        and     a
176b  c8        ret     z

176c  21a64d    ld      hl,#4da6	; check
176f  5f        ld      e,a
1770  1600      ld      d,#00
1772  19        add     hl,de
1773  7e        ld      a,(hl)
1774  a7        and     a
1775  c8        ret     z

1776  af        xor     a
1777  32a54d    ld      (#4da5),a
177a  21d04d    ld      hl,#4dd0
177d  34        inc     (hl)
177e  46        ld      b,(hl)
177f  04        inc     b
1780  cd5a2a    call    #2a5a
1783  21bc4e    ld      hl,#4ebc
1786  cbde      set     3,(hl)
1788  c9        ret     
	;; end normal ghost collision detect


	;; blue ghost collision detect

1789  3aa44d    ld      a,(#4da4)
178c  a7        and     a
178d  c0        ret     nz

178e  3aa64d    ld      a,(#4da6)
1791  a7        and     a
1792  c8        ret     z

1793  0e04      ld      c,#04
1795  0604      ld      b,#04
1797  dd21084d  ld      ix,#4d08
179b  3aaf4d    ld      a,(#4daf)
179e  a7        and     a
179f  2013      jr      nz,#17b4        ; (19)
17a1  3a064d    ld      a,(#4d06)
17a4  dd9600    sub     (ix+#00)
17a7  b9        cp      c
17a8  300a      jr      nc,#17b4        ; (10)
17aa  3a074d    ld      a,(#4d07)
17ad  dd9601    sub     (ix+#01)
17b0  b9        cp      c
17b1  da6317    jp      c,#1763		; collision detection routine
17b4  05        dec     b
17b5  3aae4d    ld      a,(#4dae)
17b8  a7        and     a
17b9  2013      jr      nz,#17ce        ; (19)
17bb  3a044d    ld      a,(#4d04)
17be  dd9600    sub     (ix+#00)
17c1  b9        cp      c
17c2  300a      jr      nc,#17ce        ; (10)
17c4  3a054d    ld      a,(#4d05)
17c7  dd9601    sub     (ix+#01)
17ca  b9        cp      c
17cb  da6317    jp      c,#1763		; collision detection routine
17ce  05        dec     b
17cf  3aad4d    ld      a,(#4dad)
17d2  a7        and     a
17d3  2013      jr      nz,#17e8        ; (19)
17d5  3a024d    ld      a,(#4d02)
17d8  dd9600    sub     (ix+#00)
17db  b9        cp      c
17dc  300a      jr      nc,#17e8        ; (10)
17de  3a034d    ld      a,(#4d03)
17e1  dd9601    sub     (ix+#01)
17e4  b9        cp      c
17e5  da6317    jp      c,#1763		; check for collision with ghost
17e8  05        dec     b
17e9  3aac4d    ld      a,(#4dac)
17ec  a7        and     a
17ed  2013      jr      nz,#1802        ; (19)
17ef  3a004d    ld      a,(#4d00)
17f2  dd9600    sub     (ix+#00)
17f5  b9        cp      c
17f6  300a      jr      nc,#1802        ; (10)
17f8  3a014d    ld      a,(#4d01)
17fb  dd9601    sub     (ix+#01)
17fe  b9        cp      c
17ff  da6317    jp      c,#1763		; check for collision with ghost
1802  05        dec     b
1803  c36317    jp      #1763		; check for collision with ghost
1806  219d4d    ld      hl,#4d9d

1809  3eff      ld      a,#ff
;1809  c3c01f    jp      #1fc0		; Intermission fast fix ; HACK10
;1809  c3d01f    jp      #1fd0		; P1P2 cheat  ; HACK3
;1809  c34c0f    jp      #0f4c		; pause cheat ; HACK5

180b  be        cp      (hl)
	; set 0xbe to 0x01 for fast cheat.	; HACK2
; 180b  01

180c  ca1118    jp      z,#1811
180f  35        dec     (hl)
1810  c9        ret     

1811  3aa64d    ld      a,(#4da6)
1814  a7        and     a
1815  ca2f18    jp      z,#182f
1818  2a4c4d    ld      hl,(#4d4c)
181b  29        add     hl,hl
181c  224c4d    ld      (#4d4c),hl
181f  2a4a4d    ld      hl,(#4d4a)
1822  ed6a      adc     hl,hl
1824  224a4d    ld      (#4d4a),hl
1827  d0        ret     nc

1828  214c4d    ld      hl,#4d4c
182b  34        inc     (hl)
182c  c34318    jp      #1843
182f  2a484d    ld      hl,(#4d48)
1832  29        add     hl,hl
1833  22484d    ld      (#4d48),hl
1836  2a464d    ld      hl,(#4d46)
1839  ed6a      adc     hl,hl
183b  22464d    ld      (#4d46),hl
183e  d0        ret     nc

183f  21484d    ld      hl,#4d48
1842  34        inc     (hl)
1843  3a0e4e    ld      a,(#4e0e)
1846  329e4d    ld      (#4d9e),a
1849  3a724e    ld      a,(#4e72)
184c  4f        ld      c,a
184d  3a094e    ld      a,(#4e09)
1850  a1        and     c
1851  4f        ld      c,a
1852  213a4d    ld      hl,#4d3a
1855  7e        ld      a,(hl)
1856  0621      ld      b,#21
1858  90        sub     b
1859  3809      jr      c,#1864         ; (9)
185b  7e        ld      a,(hl)
185c  063b      ld      b,#3b
185e  90        sub     b
185f  3003      jr      nc,#1864        ; (3)
1861  c3ab18    jp      #18ab
1864  3e01      ld      a,#01
1866  32bf4d    ld      (#4dbf),a
1869  3a004e    ld      a,(#4e00)
186c  fe01      cp      #01
186e  ca191a    jp      z,#1a19
1871  3a044e    ld      a,(#4e04)
1874  fe10      cp      #10
1876  d2191a    jp      nc,#1a19
1879  79        ld      a,c
187a  a7        and     a
187b  2806      jr      z,#1883         ; (6)

    ; check player 1 or player 2 depending on who is playing

; this seems like the hardware will jump to one of two locations to check
; player input based on whether it's player 1 or player 2 currently playing.
; if player 1 is playing, 187b will fall through to 187d.
; if player 2 is playing, 187b will jump to 1883 

187d  3a4050    ld      a,(#5040)	;; check in1 (p2)
1880  c38618    jp      #1886
1883  3a0050    ld      a,(#5000)	;; check in0 (p1)

1886  cb4f      bit     1,a		;; left
1888  c29918    jp      nz,#1899
188b  2a0333    ld      hl,(#3303)
188e  3e02      ld      a,#02
1890  32304d    ld      (#4d30),a
1893  221c4d    ld      (#4d1c),hl
1896  c35019    jp      #1950

1899  cb57      bit     2,a		;; right
189b  c25019    jp      nz,#1950
189e  2aff32    ld      hl,(#32ff)
18a1  af        xor     a
18a2  32304d    ld      (#4d30),a
18a5  221c4d    ld      (#4d1c),hl
18a8  c35019    jp      #1950


18ab  3a004e    ld      a,(#4e00)
18ae  fe01      cp      #01
18b0  ca191a    jp      z,#1a19

18b3  3a044e    ld      a,(#4e04)
18b6  fe10      cp      #10
18b8  d2191a    jp      nc,#1a19

18bb  79        ld      a,c
18bc  a7        and     a
18bd  2806      jr      z,#18c5         ; (6)

; p1/p2 check.  see 187b above for info.

	; p2 movement check
18bf  3a4050    ld      a,(#5040)	;; check in1
18c2  c3c818    jp      #18c8

	; p1 movement check
18c5  3a0050    ld      a,(#5000)	; a = IN0
18c8  cb4f      bit     1,a		; left
18ca  cac91a    jp      z,#1ac9
18cd  cb57      bit     2,a		; right
18cf  cad91a    jp      z,#1ad9
18d2  cb47      bit     0,a		; up
18d4  cae81a    jp      z,#1ae8
18d7  cb5f      bit     3,a		; down
18d9  caf81a    jp      z,#1af8
	; no movement
18dc  2a1c4d    ld      hl,(#4d1c)
18df  22264d    ld      (#4d26),hl
18e2  0601      ld      b,#01

	; movement checks return to here
18e4  dd21264d  ld      ix,#4d26
18e8  fd21394d  ld      iy,#4d39
18ec  cd0f20    call    #200f
18ef  e6c0      and     #c0
18f1  d6c0      sub     #c0
18f3  204b      jr      nz,#1940        ; (75)
18f5  05        dec     b
18f6  c21619    jp      nz,#1916
18f9  3a304d    ld      a,(#4d30)
18fc  0f        rrca    
18fd  da0b19    jp      c,#190b
1900  3a094d    ld      a,(#4d09)
1903  e607      and     #07
1905  fe04      cp      #04
1907  c8        ret     z

1908  c34019    jp      #1940
190b  3a084d    ld      a,(#4d08)
190e  e607      and     #07
1910  fe04      cp      #04
1912  c8        ret     z

1913  c34019    jp      #1940
1916  dd211c4d  ld      ix,#4d1c
191a  cd0f20    call    #200f		;; calls 2000 and 0065
191d  e6c0      and     #c0
191f  d6c0      sub     #c0
1921  202d      jr      nz,#1950        ; (45)
1923  3a304d    ld      a,(#4d30)
1926  0f        rrca    
1927  da3519    jp      c,#1935
192a  3a094d    ld      a,(#4d09)
192d  e607      and     #07
192f  fe04      cp      #04
1931  c8        ret     z

1932  c35019    jp      #1950
1935  3a084d    ld      a,(#4d08)
1938  e607      and     #07
193a  fe04      cp      #04
193c  c8        ret     z

193d  c35019    jp      #1950
1940  2a264d    ld      hl,(#4d26)
1943  221c4d    ld      (#4d1c),hl
1946  05        dec     b
1947  ca5019    jp      z,#1950
194a  3a3c4d    ld      a,(#4d3c)
194d  32304d    ld      (#4d30),a
1950  dd211c4d  ld      ix,#4d1c
1954  fd21084d  ld      iy,#4d08
1958  cd0020    call    #2000
195b  3a304d    ld      a,(#4d30)
195e  0f        rrca    
195f  da7519    jp      c,#1975

1962  7d        ld      a,l
1963  e607      and     #07
1965  fe04      cp      #04
1967  ca8519    jp      z,#1985
196a  da7119    jp      c,#1971
196d  2d        dec     l
196e  c38519    jp      #1985
1971  2c        inc     l
1972  c38519    jp      #1985
1975  7c        ld      a,h
1976  e607      and     #07
1978  fe04      cp      #04
197a  ca8519    jp      z,#1985
197d  da8419    jp      c,#1984
1980  25        dec     h
1981  c38519    jp      #1985
1984  24        inc     h
1985  22084d    ld      (#4d08),hl
1988  cd1820    call    #2018
198b  22394d    ld      (#4d39),hl
198e  dd21bf4d  ld      ix,#4dbf
1992  dd7e00    ld      a,(ix+#00)
1995  dd360000  ld      (ix+#00),#00
1999  a7        and     a
199a  c0        ret     nz

199b  3ad24d    ld      a,(#4dd2)
199e  a7        and     a
199f  282c      jr      z,#19cd         ; (44)
19a1  3ad44d    ld      a,(#4dd4)
19a4  a7        and     a
19a5  2826      jr      z,#19cd         ; (38)
19a7  2a084d    ld      hl,(#4d08)
19aa  119480    ld      de,#8094
19ad  c31888    jp      #8818
19b0  201b      jr      nz,#19cd        ; (27)
19b2  0619      ld      b,#19
19b4  4f        ld      c,a
19b5  cd4200    call    #0042
19b8  cd0010    call    #1000
19bb  1807      jr      #19c4           ; (7)
19bd  1c        inc     e
19be  cd4200    call    #0042
19c1  cd0410    call    #1004
19c4  f7        rst     #30
19c5  54        ld      d,h
19c6  05        dec     b
19c7  00        nop     
19c8  21bc4e    ld      hl,#4ebc
19cb  cbd6      set     2,(hl)
19cd  3eff      ld      a,#ff
19cf  329d4d    ld      (#4d9d),a
19d2  2a394d    ld      hl,(#4d39)
19d5  cd6500    call    #0065
19d8  7e        ld      a,(hl)
19d9  fe10      cp      #10
19db  2803      jr      z,#19e0         ; (3)
19dd  fe14      cp      #14
19df  c0        ret     nz

19e0  dd210e4e  ld      ix,#4e0e
19e4  dd3400    inc     (ix+#00)
19e7  e60f      and     #0f
19e9  cb3f      srl     a
19eb  0640      ld      b,#40
19ed  70        ld      (hl),b
19ee  0619      ld      b,#19
19f0  4f        ld      c,a
19f1  cb39      srl     c
19f3  cd4200    call    #0042
19f6  3c        inc     a
19f7  fe01      cp      #01
19f9  cafd19    jp      z,#19fd
19fc  87        add     a,a
19fd  329d4d    ld      (#4d9d),a
1a00  cd081b    call    #1b08
1a03  cd6a1a    call    #1a6a
1a06  21bc4e    ld      hl,#4ebc
1a09  3a0e4e    ld      a,(#4e0e)
1a0c  0f        rrca    
1a0d  3805      jr      c,#1a14         ; (5)
1a0f  cbc6      set     0,(hl)
1a11  cb8e      res     1,(hl)
1a13  c9        ret     

1a14  cb86      res     0,(hl)
1a16  cbce      set     1,(hl)
1a18  c9        ret     

1a19  211c4d    ld      hl,#4d1c
1a1c  7e        ld      a,(hl)
1a1d  a7        and     a
1a1e  ca2e1a    jp      z,#1a2e
1a21  3a084d    ld      a,(#4d08)
1a24  e607      and     #07
1a26  fe04      cp      #04
1a28  ca381a    jp      z,#1a38
1a2b  c35c1a    jp      #1a5c
1a2e  3a094d    ld      a,(#4d09)
1a31  e607      and     #07
1a33  fe04      cp      #04
1a35  c25c1a    jp      nz,#1a5c
1a38  3e05      ld      a,#05
1a3a  cdd01e    call    #1ed0
1a3d  3803      jr      c,#1a42         ; (3)
1a3f  ef        rst     #28
1a40  1700
1a42  dd21264d  ld      ix,#4d26
1a46  fd21124d  ld      iy,#4d12
1a4a  cd0020    call    #2000
1a4d  22124d    ld      (#4d12),hl
1a50  2a264d    ld      hl,(#4d26)
1a53  221c4d    ld      (#4d1c),hl
1a56  3a3c4d    ld      a,(#4d3c)
1a59  32304d    ld      (#4d30),a
1a5c  dd211c4d  ld      ix,#4d1c
1a60  fd21084d  ld      iy,#4d08
1a64  cd0020    call    #2000
1a67  c38519    jp      #1985
1a6a  3a9d4d    ld      a,(#4d9d)
1a6d  fe06      cp      #06
1a6f  c0        ret     nz

1a70  2abd4d    ld      hl,(#4dbd)
1a73  22cb4d    ld      (#4dcb),hl
1a76  3e01      ld      a,#01
1a78  32a64d    ld      (#4da6),a
1a7b  32a74d    ld      (#4da7),a
1a7e  32a84d    ld      (#4da8),a
1a81  32a94d    ld      (#4da9),a
1a84  32aa4d    ld      (#4daa),a
1a87  32b14d    ld      (#4db1),a
1a8a  32b24d    ld      (#4db2),a
1a8d  32b34d    ld      (#4db3),a
1a90  32b44d    ld      (#4db4),a
1a93  32b54d    ld      (#4db5),a
1a96  af        xor     a
1a97  32c84d    ld      (#4dc8),a
1a9a  32d04d    ld      (#4dd0),a
1a9d  dd21004c  ld      ix,#4c00
1aa1  dd36021c  ld      (ix+#02),#1c
1aa5  dd36041c  ld      (ix+#04),#1c
1aa9  dd36061c  ld      (ix+#06),#1c
1aad  dd36081c  ld      (ix+#08),#1c
1ab1  dd360311  ld      (ix+#03),#11
1ab5  dd360511  ld      (ix+#05),#11
1ab9  dd360711  ld      (ix+#07),#11
1abd  dd360911  ld      (ix+#09),#11
1ac1  21ac4e    ld      hl,#4eac
1ac4  cbee      set     5,(hl)
1ac6  cbbe      res     7,(hl)
1ac8  c9        ret     

	; Player move Left
1ac9  2a0333    ld      hl,(#3303)
1acc  3e02      ld      a,#02
1ace  323c4d    ld      (#4d3c),a
1ad1  22264d    ld      (#4d26),hl
1ad4  0600      ld      b,#00
1ad6  c3e418    jp      #18e4

	; player move Right
1ad9  2aff32    ld      hl,(#32ff)
1adc  af        xor     a
1add  323c4d    ld      (#4d3c),a
1ae0  22264d    ld      (#4d26),hl
1ae3  0600      ld      b,#00
1ae5  c3e418    jp      #18e4

	; player move Up
1ae8  2a0533    ld      hl,(#3305)
1aeb  3e03      ld      a,#03
1aed  323c4d    ld      (#4d3c),a
1af0  22264d    ld      (#4d26),hl
1af3  0600      ld      b,#00
1af5  c3e418    jp      #18e4

	; player move Down
1af8  2a0133    ld      hl,(#3301)
1afb  3e01      ld      a,#01
1afd  323c4d    ld      (#4d3c),a
1b00  22264d    ld      (#4d26),hl
1b03  0600      ld      b,#00
1b05  c3e418    jp      #18e4

1b08  3a124e    ld      a,(#4e12)
1b0b  a7        and     a
1b0c  ca141b    jp      z,#1b14
1b0f  219f4d    ld      hl,#4d9f
1b12  34        inc     (hl)
1b13  c9        ret     

1b14  3aa34d    ld      a,(#4da3)
1b17  a7        and     a
1b18  c0        ret     nz

1b19  3aa24d    ld      a,(#4da2)
1b1c  a7        and     a
1b1d  ca251b    jp      z,#1b25
1b20  21114e    ld      hl,#4e11
1b23  34        inc     (hl)
1b24  c9        ret     

1b25  3aa14d    ld      a,(#4da1)
1b28  a7        and     a
1b29  ca311b    jp      z,#1b31
1b2c  21104e    ld      hl,#4e10
1b2f  34        inc     (hl)
1b30  c9        ret     

1b31  210f4e    ld      hl,#4e0f
1b34  34        inc     (hl)
1b35  c9        ret     

1b36  3aa04d    ld      a,(#4da0)
1b39  a7        and     a
1b3a  c8        ret     z

1b3b  3aac4d    ld      a,(#4dac)
1b3e  a7        and     a
1b3f  c0        ret     nz

1b40  cdd720    call    #20d7
1b43  2a314d    ld      hl,(#4d31)
1b46  01994d    ld      bc,#4d99
1b49  cd5a20    call    #205a
1b4c  3a994d    ld      a,(#4d99)
1b4f  a7        and     a
1b50  ca6a1b    jp      z,#1b6a
1b53  2a604d    ld      hl,(#4d60)
1b56  29        add     hl,hl
1b57  22604d    ld      (#4d60),hl
1b5a  2a5e4d    ld      hl,(#4d5e)
1b5d  ed6a      adc     hl,hl
1b5f  225e4d    ld      (#4d5e),hl
1b62  d0        ret     nc

1b63  21604d    ld      hl,#4d60
1b66  34        inc     (hl)
1b67  c3d81b    jp      #1bd8
1b6a  3aa74d    ld      a,(#4da7)
1b6d  a7        and     a
1b6e  ca881b    jp      z,#1b88
1b71  2a5c4d    ld      hl,(#4d5c)
1b74  29        add     hl,hl
1b75  225c4d    ld      (#4d5c),hl
1b78  2a5a4d    ld      hl,(#4d5a)
1b7b  ed6a      adc     hl,hl
1b7d  225a4d    ld      (#4d5a),hl
1b80  d0        ret     nc

1b81  215c4d    ld      hl,#4d5c
1b84  34        inc     (hl)
1b85  c3d81b    jp      #1bd8
1b88  3ab74d    ld      a,(#4db7)
1b8b  a7        and     a
1b8c  caa61b    jp      z,#1ba6
1b8f  2a504d    ld      hl,(#4d50)
1b92  29        add     hl,hl
1b93  22504d    ld      (#4d50),hl
1b96  2a4e4d    ld      hl,(#4d4e)
1b99  ed6a      adc     hl,hl
1b9b  224e4d    ld      (#4d4e),hl
1b9e  d0        ret     nc

1b9f  21504d    ld      hl,#4d50
1ba2  34        inc     (hl)
1ba3  c3d81b    jp      #1bd8
1ba6  3ab64d    ld      a,(#4db6)
1ba9  a7        and     a
1baa  cac41b    jp      z,#1bc4
1bad  2a544d    ld      hl,(#4d54)
1bb0  29        add     hl,hl
1bb1  22544d    ld      (#4d54),hl
1bb4  2a524d    ld      hl,(#4d52)
1bb7  ed6a      adc     hl,hl
1bb9  22524d    ld      (#4d52),hl
1bbc  d0        ret     nc

1bbd  21544d    ld      hl,#4d54
1bc0  34        inc     (hl)
1bc1  c3d81b    jp      #1bd8
1bc4  2a584d    ld      hl,(#4d58)
1bc7  29        add     hl,hl
1bc8  22584d    ld      (#4d58),hl
1bcb  2a564d    ld      hl,(#4d56)
1bce  ed6a      adc     hl,hl
1bd0  22564d    ld      (#4d56),hl
1bd3  d0        ret     nc

1bd4  21584d    ld      hl,#4d58
1bd7  34        inc     (hl)
1bd8  21144d    ld      hl,#4d14
1bdb  7e        ld      a,(hl)
1bdc  a7        and     a
1bdd  caed1b    jp      z,#1bed
1be0  3a004d    ld      a,(#4d00)
1be3  e607      and     #07
1be5  fe04      cp      #04
1be7  caf71b    jp      z,#1bf7
1bea  c3361c    jp      #1c36
1bed  3a014d    ld      a,(#4d01)
1bf0  e607      and     #07
1bf2  fe04      cp      #04
1bf4  c2361c    jp      nz,#1c36
1bf7  3e01      ld      a,#01
1bf9  cdd01e    call    #1ed0
1bfc  381b      jr      c,#1c19         ; (27)
1bfe  3aa74d    ld      a,(#4da7)
1c01  a7        and     a
1c02  ca0b1c    jp      z,#1c0b
1c05  ef        rst     #28
1c06  0c00
1c08  c3191c    jp      #1c19
1c0b  2a0a4d    ld      hl,(#4d0a)
1c0e  cd5220    call    #2052
1c11  7e        ld      a,(hl)
1c12  fe1a      cp      #1a
1c14  2803      jr      z,#1c19         ; (3)
1c16  ef        rst     #28
1c17  0800
1c19  cdfe1e    call    #1efe
1c1c  dd211e4d  ld      ix,#4d1e
1c20  fd210a4d  ld      iy,#4d0a
1c24  cd0020    call    #2000
1c27  220a4d    ld      (#4d0a),hl
1c2a  2a1e4d    ld      hl,(#4d1e)
1c2d  22144d    ld      (#4d14),hl
1c30  3a2c4d    ld      a,(#4d2c)
1c33  32284d    ld      (#4d28),a
1c36  dd21144d  ld      ix,#4d14
1c3a  fd21004d  ld      iy,#4d00
1c3e  cd0020    call    #2000
1c41  22004d    ld      (#4d00),hl
1c44  cd1820    call    #2018
1c47  22314d    ld      (#4d31),hl
1c4a  c9        ret     

1c4b  3aa14d    ld      a,(#4da1)
1c4e  fe01      cp      #01
1c50  c0        ret     nz

1c51  3aad4d    ld      a,(#4dad)
1c54  a7        and     a
1c55  c0        ret     nz

1c56  2a334d    ld      hl,(#4d33)
1c59  019a4d    ld      bc,#4d9a
1c5c  cd5a20    call    #205a
1c5f  3a9a4d    ld      a,(#4d9a)
1c62  a7        and     a
1c63  ca7d1c    jp      z,#1c7d
1c66  2a6c4d    ld      hl,(#4d6c)
1c69  29        add     hl,hl
1c6a  226c4d    ld      (#4d6c),hl
1c6d  2a6a4d    ld      hl,(#4d6a)
1c70  ed6a      adc     hl,hl
1c72  226a4d    ld      (#4d6a),hl
1c75  d0        ret     nc

1c76  216c4d    ld      hl,#4d6c
1c79  34        inc     (hl)
1c7a  c3af1c    jp      #1caf
1c7d  3aa84d    ld      a,(#4da8)
1c80  a7        and     a
1c81  ca9b1c    jp      z,#1c9b
1c84  2a684d    ld      hl,(#4d68)
1c87  29        add     hl,hl
1c88  22684d    ld      (#4d68),hl
1c8b  2a664d    ld      hl,(#4d66)
1c8e  ed6a      adc     hl,hl
1c90  22664d    ld      (#4d66),hl
1c93  d0        ret     nc

1c94  21684d    ld      hl,#4d68
1c97  34        inc     (hl)
1c98  c3af1c    jp      #1caf
1c9b  2a644d    ld      hl,(#4d64)
1c9e  29        add     hl,hl
1c9f  22644d    ld      (#4d64),hl
1ca2  2a624d    ld      hl,(#4d62)
1ca5  ed6a      adc     hl,hl
1ca7  22624d    ld      (#4d62),hl
1caa  d0        ret     nc

1cab  21644d    ld      hl,#4d64
1cae  34        inc     (hl)
1caf  21164d    ld      hl,#4d16
1cb2  7e        ld      a,(hl)
1cb3  a7        and     a
1cb4  cac41c    jp      z,#1cc4
1cb7  3a024d    ld      a,(#4d02)
1cba  e607      and     #07
1cbc  fe04      cp      #04
1cbe  cace1c    jp      z,#1cce
1cc1  c30d1d    jp      #1d0d
1cc4  3a034d    ld      a,(#4d03)
1cc7  e607      and     #07
1cc9  fe04      cp      #04
1ccb  c20d1d    jp      nz,#1d0d
1cce  3e02      ld      a,#02
1cd0  cdd01e    call    #1ed0
1cd3  381b      jr      c,#1cf0         ; (27)
1cd5  3aa84d    ld      a,(#4da8)
1cd8  a7        and     a
1cd9  cae21c    jp      z,#1ce2
1cdc  ef        rst     #28
1cdd  0d00
1cdf  c3f01c    jp      #1cf0
1ce2  2a0c4d    ld      hl,(#4d0c)
1ce5  cd5220    call    #2052
1ce8  7e        ld      a,(hl)
1ce9  fe1a      cp      #1a
1ceb  2803      jr      z,#1cf0         ; (3)
1ced  ef        rst     #28
1cee  0900
1cf0  cd251f    call    #1f25
1cf3  dd21204d  ld      ix,#4d20
1cf7  fd210c4d  ld      iy,#4d0c
1cfb  cd0020    call    #2000
1cfe  220c4d    ld      (#4d0c),hl
1d01  2a204d    ld      hl,(#4d20)
1d04  22164d    ld      (#4d16),hl
1d07  3a2d4d    ld      a,(#4d2d)
1d0a  32294d    ld      (#4d29),a
1d0d  dd21164d  ld      ix,#4d16
1d11  fd21024d  ld      iy,#4d02
1d15  cd0020    call    #2000
1d18  22024d    ld      (#4d02),hl
1d1b  cd1820    call    #2018
1d1e  22334d    ld      (#4d33),hl
1d21  c9        ret     

1d22  3aa24d    ld      a,(#4da2)
1d25  fe01      cp      #01
1d27  c0        ret     nz

1d28  3aae4d    ld      a,(#4dae)
1d2b  a7        and     a
1d2c  c0        ret     nz

1d2d  2a354d    ld      hl,(#4d35)
1d30  019b4d    ld      bc,#4d9b
1d33  cd5a20    call    #205a
1d36  3a9b4d    ld      a,(#4d9b)
1d39  a7        and     a
1d3a  ca541d    jp      z,#1d54
1d3d  2a784d    ld      hl,(#4d78)
1d40  29        add     hl,hl
1d41  22784d    ld      (#4d78),hl
1d44  2a764d    ld      hl,(#4d76)
1d47  ed6a      adc     hl,hl
1d49  22764d    ld      (#4d76),hl
1d4c  d0        ret     nc

1d4d  21784d    ld      hl,#4d78
1d50  34        inc     (hl)
1d51  c3861d    jp      #1d86
1d54  3aa94d    ld      a,(#4da9)
1d57  a7        and     a
1d58  ca721d    jp      z,#1d72
1d5b  2a744d    ld      hl,(#4d74)
1d5e  29        add     hl,hl
1d5f  22744d    ld      (#4d74),hl
1d62  2a724d    ld      hl,(#4d72)
1d65  ed6a      adc     hl,hl
1d67  22724d    ld      (#4d72),hl
1d6a  d0        ret     nc

1d6b  21744d    ld      hl,#4d74
1d6e  34        inc     (hl)
1d6f  c3861d    jp      #1d86
1d72  2a704d    ld      hl,(#4d70)
1d75  29        add     hl,hl
1d76  22704d    ld      (#4d70),hl
1d79  2a6e4d    ld      hl,(#4d6e)
1d7c  ed6a      adc     hl,hl
1d7e  226e4d    ld      (#4d6e),hl
1d81  d0        ret     nc

1d82  21704d    ld      hl,#4d70
1d85  34        inc     (hl)
1d86  21184d    ld      hl,#4d18
1d89  7e        ld      a,(hl)
1d8a  a7        and     a
1d8b  ca9b1d    jp      z,#1d9b
1d8e  3a044d    ld      a,(#4d04)
1d91  e607      and     #07
1d93  fe04      cp      #04
1d95  caa51d    jp      z,#1da5
1d98  c3e41d    jp      #1de4
1d9b  3a054d    ld      a,(#4d05)
1d9e  e607      and     #07
1da0  fe04      cp      #04
1da2  c2e41d    jp      nz,#1de4
1da5  3e03      ld      a,#03
1da7  cdd01e    call    #1ed0
1daa  381b      jr      c,#1dc7         ; (27)
1dac  3aa94d    ld      a,(#4da9)
1daf  a7        and     a
1db0  cab91d    jp      z,#1db9
1db3  ef        rst     #28
1db4  0e00
1db6  c3c71d    jp      #1dc7
1db9  2a0e4d    ld      hl,(#4d0e)
1dbc  cd5220    call    #2052
1dbf  7e        ld      a,(hl)
1dc0  fe1a      cp      #1a
1dc2  2803      jr      z,#1dc7         ; (3)
1dc4  ef        rst     #28
1dc5  0a00
1dc7  cd4c1f    call    #1f4c
1dca  dd21224d  ld      ix,#4d22
1dce  fd210e4d  ld      iy,#4d0e
1dd2  cd0020    call    #2000
1dd5  220e4d    ld      (#4d0e),hl
1dd8  2a224d    ld      hl,(#4d22)
1ddb  22184d    ld      (#4d18),hl
1dde  3a2e4d    ld      a,(#4d2e)
1de1  322a4d    ld      (#4d2a),a
1de4  dd21184d  ld      ix,#4d18
1de8  fd21044d  ld      iy,#4d04
1dec  cd0020    call    #2000
1def  22044d    ld      (#4d04),hl
1df2  cd1820    call    #2018
1df5  22354d    ld      (#4d35),hl
1df8  c9        ret     

1df9  3aa34d    ld      a,(#4da3)
1dfc  fe01      cp      #01
1dfe  c0        ret     nz

1dff  3aaf4d    ld      a,(#4daf)
1e02  a7        and     a
1e03  c0        ret     nz

1e04  2a374d    ld      hl,(#4d37)
1e07  019c4d    ld      bc,#4d9c
1e0a  cd5a20    call    #205a
1e0d  3a9c4d    ld      a,(#4d9c)
1e10  a7        and     a
1e11  ca2b1e    jp      z,#1e2b
1e14  2a844d    ld      hl,(#4d84)
1e17  29        add     hl,hl
1e18  22844d    ld      (#4d84),hl
1e1b  2a824d    ld      hl,(#4d82)
1e1e  ed6a      adc     hl,hl
1e20  22824d    ld      (#4d82),hl
1e23  d0        ret     nc

1e24  21844d    ld      hl,#4d84
1e27  34        inc     (hl)
1e28  c35d1e    jp      #1e5d
1e2b  3aaa4d    ld      a,(#4daa)
1e2e  a7        and     a
1e2f  ca491e    jp      z,#1e49
1e32  2a804d    ld      hl,(#4d80)
1e35  29        add     hl,hl
1e36  22804d    ld      (#4d80),hl
1e39  2a7e4d    ld      hl,(#4d7e)
1e3c  ed6a      adc     hl,hl
1e3e  227e4d    ld      (#4d7e),hl
1e41  d0        ret     nc

1e42  21804d    ld      hl,#4d80
1e45  34        inc     (hl)
1e46  c35d1e    jp      #1e5d
1e49  2a7c4d    ld      hl,(#4d7c)
1e4c  29        add     hl,hl
1e4d  227c4d    ld      (#4d7c),hl
1e50  2a7a4d    ld      hl,(#4d7a)
1e53  ed6a      adc     hl,hl
1e55  227a4d    ld      (#4d7a),hl
1e58  d0        ret     nc

1e59  217c4d    ld      hl,#4d7c
1e5c  34        inc     (hl)
1e5d  211a4d    ld      hl,#4d1a
1e60  7e        ld      a,(hl)
1e61  a7        and     a
1e62  ca721e    jp      z,#1e72
1e65  3a064d    ld      a,(#4d06)
1e68  e607      and     #07
1e6a  fe04      cp      #04
1e6c  ca7c1e    jp      z,#1e7c
1e6f  c3bb1e    jp      #1ebb
1e72  3a074d    ld      a,(#4d07)
1e75  e607      and     #07
1e77  fe04      cp      #04
1e79  c2bb1e    jp      nz,#1ebb
1e7c  3e04      ld      a,#04
1e7e  cdd01e    call    #1ed0
1e81  381b      jr      c,#1e9e         ; (27)
1e83  3aaa4d    ld      a,(#4daa)
1e86  a7        and     a
1e87  ca901e    jp      z,#1e90
1e8a  ef        rst     #28
1e8b  0f00
1e8d  c39e1e    jp      #1e9e
1e90  2a104d    ld      hl,(#4d10)
1e93  cd5220    call    #2052
1e96  7e        ld      a,(hl)
1e97  fe1a      cp      #1a
1e99  2803      jr      z,#1e9e         ; (3)
1e9b  ef        rst     #28
1e9c  0b00
1e9e  cd731f    call    #1f73
1ea1  dd21244d  ld      ix,#4d24
1ea5  fd21104d  ld      iy,#4d10
1ea9  cd0020    call    #2000
1eac  22104d    ld      (#4d10),hl
1eaf  2a244d    ld      hl,(#4d24)
1eb2  221a4d    ld      (#4d1a),hl
1eb5  3a2f4d    ld      a,(#4d2f)
1eb8  322b4d    ld      (#4d2b),a
1ebb  dd211a4d  ld      ix,#4d1a
1ebf  fd21064d  ld      iy,#4d06
1ec3  cd0020    call    #2000
1ec6  22064d    ld      (#4d06),hl
1ec9  cd1820    call    #2018
1ecc  22374d    ld      (#4d37),hl
1ecf  c9        ret     

1ed0  87        add     a,a
1ed1  4f        ld      c,a
1ed2  0600      ld      b,#00
1ed4  21094d    ld      hl,#4d09
1ed7  09        add     hl,bc
1ed8  7e        ld      a,(hl)
1ed9  fe1d      cp      #1d
1edb  c2e31e    jp      nz,#1ee3
1ede  363d      ld      (hl),#3d
1ee0  c3fc1e    jp      #1efc
1ee3  fe3e      cp      #3e
1ee5  c2ed1e    jp      nz,#1eed
1ee8  361e      ld      (hl),#1e
1eea  c3fc1e    jp      #1efc
1eed  0621      ld      b,#21
1eef  90        sub     b
1ef0  dafc1e    jp      c,#1efc
1ef3  7e        ld      a,(hl)
1ef4  063b      ld      b,#3b
1ef6  90        sub     b
1ef7  d2fc1e    jp      nc,#1efc
1efa  a7        and     a
1efb  c9        ret     

1efc  37        scf     
1efd  c9        ret     

1efe  3ab14d    ld      a,(#4db1)
1f01  a7        and     a
1f02  c8        ret     z

1f03  af        xor     a
1f04  32b14d    ld      (#4db1),a
1f07  21ff32    ld      hl,#32ff
1f0a  3a284d    ld      a,(#4d28)
1f0d  ee02      xor     #02
1f0f  322c4d    ld      (#4d2c),a
1f12  47        ld      b,a
1f13  df        rst     #18
1f14  221e4d    ld      (#4d1e),hl
1f17  3a024e    ld      a,(#4e02)
1f1a  fe22      cp      #22
1f1c  c0        ret     nz

1f1d  22144d    ld      (#4d14),hl
1f20  78        ld      a,b
1f21  32284d    ld      (#4d28),a
1f24  c9        ret     

1f25  3ab24d    ld      a,(#4db2)
1f28  a7        and     a
1f29  c8        ret     z

1f2a  af        xor     a
1f2b  32b24d    ld      (#4db2),a
1f2e  21ff32    ld      hl,#32ff
1f31  3a294d    ld      a,(#4d29)
1f34  ee02      xor     #02
1f36  322d4d    ld      (#4d2d),a
1f39  47        ld      b,a
1f3a  df        rst     #18
1f3b  22204d    ld      (#4d20),hl
1f3e  3a024e    ld      a,(#4e02)
1f41  fe22      cp      #22
1f43  c0        ret     nz

1f44  22164d    ld      (#4d16),hl
1f47  78        ld      a,b
1f48  32294d    ld      (#4d29),a
1f4b  c9        ret     

1f4c  3ab34d    ld      a,(#4db3)
1f4f  a7        and     a
1f50  c8        ret     z

1f51  af        xor     a
1f52  32b34d    ld      (#4db3),a
1f55  21ff32    ld      hl,#32ff
1f58  3a2a4d    ld      a,(#4d2a)
1f5b  ee02      xor     #02
1f5d  322e4d    ld      (#4d2e),a
1f60  47        ld      b,a
1f61  df        rst     #18
1f62  22224d    ld      (#4d22),hl
1f65  3a024e    ld      a,(#4e02)
1f68  fe22      cp      #22
1f6a  c0        ret     nz

1f6b  22184d    ld      (#4d18),hl
1f6e  78        ld      a,b
1f6f  322a4d    ld      (#4d2a),a
1f72  c9        ret     

1f73  3ab44d    ld      a,(#4db4)
1f76  a7        and     a
1f77  c8        ret     z

1f78  af        xor     a
1f79  32b44d    ld      (#4db4),a
1f7c  21ff32    ld      hl,#32ff
1f7f  3a2b4d    ld      a,(#4d2b)
1f82  ee02      xor     #02
1f84  322f4d    ld      (#4d2f),a
1f87  47        ld      b,a
1f88  df        rst     #18
1f89  22244d    ld      (#4d24),hl
1f8c  3a024e    ld      a,(#4e02)
1f8f  fe22      cp      #22
1f91  c0        ret     nz

1f92  221a4d    ld      (#4d1a),hl
1f95  78        ld      a,b
1f96  322b4d    ld      (#4d2b),a
1f99  c9        ret     

1f9a  21				; junk

	;; new for INTERRUPT MODE 1
	;; rst 38 continuation  (vblank) 
1f9b  f5	push	af
1f9c  ed57	ld	a,i
1f9e  b7        or      a		;;; check to see if we're in test mode
1f9f  2804      jr      z,#1fa5         ; (4)  jp, pop, to 3000 if yes
	; not in test mode
1fa1  f1        pop     af
1fa2  c38d00    jp      #008d		;; continue the original handler
	; in test mode
1fa5  f1        pop     af
1fa6  c30030    jp      #3000		;; we're in init, continue testing


1fa9  00        nop     		; unused space
1faa  00        nop     
1fab  00        nop     
1fac  00        nop     
1fad  00        nop     
1fae  00        nop     
1faf  00        nop     

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

    ;; fast intermission fix ; HACK10
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

1fb0  00        nop     
...
1fdf  00        nop     
1fe0  00        nop     
1fe1  00        nop     
1fe2  00        nop     
1fe3  00        nop     
1fe4  00        nop     
1fe5  00        nop     
1fe6  00        nop     
1fe7  00        nop     
1fe8  00        nop     
1fe9  00        nop     
1fea  00        nop     
1feb  00        nop     
1fec  00        nop     
1fed  00        nop     
1fee  00        nop     
1fef  00        nop     
1ff0  00        nop     
1ff1  00        nop     
1ff2  00        nop     
1ff3  00        nop     
1ff4  00        nop     
1ff5  00        nop     
1ff6  00        nop     
1ff7  00        nop     
1ff8  00        nop     
1ff9  00        nop     
1ffa  00        nop     
1ffb  00        nop     
1ffc  00        nop     
	; set to 0xbd for fast cheat checksum check hack  ; HACK2
1ffd  00        nop     
1ffe  5d e1
    ; fast/invincibilty checksum ; HACK3
;1ffe bf dc

    ;; fast intermission fix ; HACK10
;1ffe 8A 6D 



	;; this is a common function as well.
2000  fd7e00    ld      a,(iy+#00)
2003  dd8600    add     a,(ix+#00)
2006  6f        ld      l,a
2007  fd7e01    ld      a,(iy+#01)
200a  dd8601    add     a,(ix+#01)
200d  67        ld      h,a
200e  c9        ret     

200f  cd0020    call    #2000
2012  cd6500    call    #0065
2015  7e        ld      a,(hl)
2016  a7        and     a
2017  c9        ret     

2018  7d        ld      a,l
2019  cb3f      srl     a
201b  cb3f      srl     a
201d  cb3f      srl     a
201f  c620      add     a,#20
2021  6f        ld      l,a
2022  7c        ld      a,h
2023  cb3f      srl     a
2025  cb3f      srl     a
2027  cb3f      srl     a
2029  c61e      add     a,#1e
202b  67        ld      h,a
202c  c9        ret     

	;; this does something that happens often.
	;; same as "call $0065"
202d  f5        push    af
202e  c5        push    bc
202f  7d        ld      a,l
2030  d620      sub     #20
2032  6f        ld      l,a
2033  7c        ld      a,h
2034  d620      sub     #20
2036  67        ld      h,a
2037  0600      ld      b,#00
2039  cb24      sla     h
203b  cb24      sla     h
203d  cb24      sla     h
203f  cb24      sla     h
2041  cb10      rl      b
2043  cb24      sla     h
2045  cb10      rl      b
2047  4c        ld      c,h
2048  2600      ld      h,#00
204a  09        add     hl,bc
204b  014040    ld      bc,#4040
204e  09        add     hl,bc
204f  c1        pop     bc
2050  f1        pop     af
2051  c9        ret     

2052  cd6500    call    #0065
2055  110004    ld      de,#0400
2058  19        add     hl,de
2059  c9        ret     

205a  cd5220    call    #2052
205d  7e        ld      a,(hl)
205e  fe1b      cp      #1b
2060  c36f36    jp      #366f
2063  00        nop     
2064  02        ld      (bc),a
2065  c9        ret     

2066  af        xor     a
2067  02        ld      (bc),a
2068  c9        ret     

2069  3aa14d    ld      a,(#4da1)
206c  a7        and     a
206d  c0        ret     nz

206e  3a124e    ld      a,(#4e12)
2071  a7        and     a
2072  ca7e20    jp      z,#207e
2075  3a9f4d    ld      a,(#4d9f)
2078  fe07      cp      #07
207a  c0        ret     nz

207b  c38620    jp      #2086
207e  21b84d    ld      hl,#4db8
2081  3a0f4e    ld      a,(#4e0f)
2084  be        cp      (hl)
2085  d8        ret     c

2086  3e02      ld      a,#02
2088  32a14d    ld      (#4da1),a
208b  c9        ret     

208c  3aa24d    ld      a,(#4da2)
208f  a7        and     a
2090  c0        ret     nz

2091  3a124e    ld      a,(#4e12)
2094  a7        and     a
2095  caa120    jp      z,#20a1
2098  3a9f4d    ld      a,(#4d9f)
209b  fe11      cp      #11
209d  c0        ret     nz

209e  c3a920    jp      #20a9
20a1  21b94d    ld      hl,#4db9
20a4  3a104e    ld      a,(#4e10)
20a7  be        cp      (hl)
20a8  d8        ret     c

20a9  3e03      ld      a,#03
20ab  32a24d    ld      (#4da2),a
20ae  c9        ret     

20af  3aa34d    ld      a,(#4da3)
20b2  a7        and     a
20b3  c0        ret     nz

20b4  3a124e    ld      a,(#4e12)
20b7  a7        and     a
20b8  cac920    jp      z,#20c9
20bb  3a9f4d    ld      a,(#4d9f)
20be  fe20      cp      #20
20c0  c0        ret     nz

20c1  af        xor     a
20c2  32124e    ld      (#4e12),a
20c5  329f4d    ld      (#4d9f),a
20c8  c9        ret     

20c9  21ba4d    ld      hl,#4dba
20cc  3a114e    ld      a,(#4e11)
20cf  be        cp      (hl)
20d0  d8        ret     c

20d1  3e03      ld      a,#03
20d3  32a34d    ld      (#4da3),a
20d6  c9        ret     

20d7  3aa34d    ld      a,(#4da3)
20da  a7        and     a
20db  c8        ret     z

20dc  210e4e    ld      hl,#4e0e	; number of pellets eaten
20df  3ab64d    ld      a,(#4db6)
20e2  a7        and     a
20e3  c2f420    jp      nz,#20f4
20e6  3ef4      ld      a,#f4
20e8  96        sub     (hl)
20e9  47        ld      b,a
20ea  3abb4d    ld      a,(#4dbb)
20ed  90        sub     b
20ee  d8        ret     c

20ef  3e01      ld      a,#01
20f1  32b64d    ld      (#4db6),a
20f4  3ab74d    ld      a,(#4db7)
20f7  a7        and     a
20f8  c0        ret     nz

20f9  3ef4      ld      a,#f4
20fb  96        sub     (hl)
20fc  47        ld      b,a
20fd  3abc4d    ld      a,(#4dbc)
2100  90        sub     b
2101  d8        ret     c

2102  3e01      ld      a,#01
2104  32b74d    ld      (#4db7),a
2107  c9        ret     

2108  c33534    jp      #3435
210b  e7        rst     #20
210c  1a        ld      a,(de)
210d  214021    ld      hl,#2140
2110  4b        ld      c,e
2111  210c00    ld      hl,#000c
2114  70        ld      (hl),b
2115  217b21    ld      hl,#217b
2118  86        add     a,(hl)
2119  213a3a    ld      hl,#3a3a
211c  4d        ld      c,l
211d  d621      sub     #21
211f  200f      jr      nz,#2130        ; (15)
2121  3c        inc     a
2122  32a04d    ld      (#4da0),a
2125  32b74d    ld      (#4db7),a
2128  cd0605    call    #0506
212b  21064e    ld      hl,#4e06
212e  34        inc     (hl)
212f  c9        ret     

2130  cd0618    call    #1806
2133  cd0618    call    #1806
2136  cd361b    call    #1b36
2139  cd361b    call    #1b36
213c  cd230e    call    #0e23
213f  c9        ret     

2140  3a3a4d    ld      a,(#4d3a)
2143  d61e      sub     #1e
2145  c23021    jp      nz,#2130
2148  c32b21    jp      #212b
214b  3a324d    ld      a,(#4d32)
214e  d61e      sub     #1e
2150  c23621    jp      nz,#2136
2153  cd701a    call    #1a70
2156  af        xor     a
2157  32ac4e    ld      (#4eac),a
215a  32bc4e    ld      (#4ebc),a
215d  cda505    call    #05a5
2160  221c4d    ld      (#4d1c),hl
2163  3a3c4d    ld      a,(#4d3c)


	;; text lookup table?

2166  32304d    ld      (#4d30),a
2169  f7        rst     #30
216a  45        ld      b,l
216b  07        rlca    
216c  00        nop     
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
2195  f7        rst     #30
2196  45        ld      b,l
2197  00        nop     
2198  00        nop     
2199  21044e    ld      hl,#4e04
219c  34        inc     (hl)		; add one to level cleared register?
219d  c9        ret     

219e  3a074e    ld      a,(#4e07)
21a1  c34f34    jp      #344f
21a4  41        ld      b,c
21a5  e7        rst     #20
21a6  c2210c    jp      nz,#0c21
21a9  00        nop     
21aa  e1        pop     hl
21ab  21f521    ld      hl,#21f5
21ae  0c        inc     c
21af  221e22    ld      (#221e),hl
21b2  44        ld      b,h
21b3  225d22    ld      (#225d),hl
21b6  0c        inc     c
21b7  00        nop     
21b8  6a        ld      l,d
21b9  220c00    ld      (#000c),hl
21bc  86        add     a,(hl)
21bd  220c00    ld      (#000c),hl
21c0  8d        adc     a,l
21c1  223e01    ld      (#013e),hl
21c4  32d245    ld      (#45d2),a
21c7  32d345    ld      (#45d3),a
21ca  32f245    ld      (#45f2),a
21cd  32f345    ld      (#45f3),a
21d0  cd0605    call    #0506
21d3  fd360060  ld      (iy+#00),#60
21d7  fd360161  ld      (iy+#01),#61
21db  f7        rst     #30
21dc  43        ld      b,e
21dd  08        ex      af,af'
21de  00        nop     
21df  180f      jr      #21f0           ; (15)
21e1  3a3a4d    ld      a,(#4d3a)
21e4  d62c      sub     #2c
21e6  c23021    jp      nz,#2130
21e9  3c        inc     a
21ea  32a04d    ld      (#4da0),a
21ed  32b74d    ld      (#4db7),a
21f0  21074e    ld      hl,#4e07
21f3  34        inc     (hl)
21f4  c9        ret     

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
2240  cd230e    call    #0e23
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
2264  f7        rst     #30
2265  4f        ld      c,a
2266  08        ex      af,af'
2267  00        nop     
2268  1886      jr      #21f0           ; (-122)
226a  21014d    ld      hl,#4d01
226d  34        inc     (hl)
226e  34        inc     (hl)
226f  fd36006c  ld      (iy+#00),#6c
2273  fd36016d  ld      (iy+#01),#6d
2277  fd362040  ld      (iy+#20),#40
227b  fd362140  ld      (iy+#21),#40
227f  f7        rst     #30
2280  4a        ld      c,d
2281  08        ex      af,af'
2282  00        nop     
2283  c3f021    jp      #21f0
2286  f7        rst     #30
2287  54        ld      d,h
2288  08        ex      af,af'
2289  00        nop     
228a  c3f021    jp      #21f0
228d  af        xor     a
228e  32074e    ld      (#4e07),a
2291  21044e    ld      hl,#4e04
2294  34        inc     (hl)
2295  34        inc     (hl)		; add 2 to level cleared register?
2296  c9        ret     

2297  3a084e    ld      a,(#4e08)
229a  c36934    jp      #3469
229d  be        cp      (hl)
229e  220c00    ld      (#000c),hl
22a1  dd22f522  ld      (#22f5),ix
22a5  fe22      cp      #22
22a7  3a3a4d    ld      a,(#4d3a)
22aa  d625      sub     #25
22ac  c23021    jp      nz,#2130
22af  3c        inc     a
22b0  32a04d    ld      (#4da0),a
22b3  32b74d    ld      (#4db7),a
22b6  cd0605    call    #0506
22b9  21084e    ld      hl,#4e08
22bc  34        inc     (hl)
22bd  c9        ret     

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
22d7  f7        rst     #30
22d8  4a        ld      c,d
22d9  09        add     hl,bc
22da  00        nop     
22db  18dc      jr      #22b9           ; (-36)
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
22fe  af        xor     a
22ff  32084e    ld      (#4e08),a
2302  f7        rst     #30
2303  45        ld      b,l
2304  00        nop     
2305  00        nop     
2306  21044e    ld      hl,#4e04
2309  34        inc     (hl)		; add 1 to level clared register
230a  c9        ret     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; Main program start (reset)
	;; 0 -> 5000 - 5007  (special registers)
	;; irq off, sound off, flip off, etc.
230b  210050    ld      hl,#5000
230e  0608      ld      b,#08
2310  af        xor     a		; 0 -> a
2311  77        ld      (hl),a
2312  2c        inc     l
2313  10fc      djnz    #2311           ; (-4)

	;; Clear screen
	;; 40 -> 4000-43ff (Video RAM)
2315  210040    ld      hl,#4000
2318  0604      ld      b,#04
231a  32c050    ld      (#50c0),a	; kick the dog
231d  320750    ld      (#5007),a	; kick coin counter?
2320  3e40      ld      a,#40
2322  77        ld      (hl),a
2323  2c        inc     l
2324  20fc      jr      nz,#2322        ; loop
2326  24        inc     h
2327  10f1      djnz    #231a           ; loop

	;; 0f -> 4400 - 47ff (Color RAM)
2329  0604      ld      b,#04
232b  32c050    ld      (#50c0),a	; kick the dog
232e  af        xor     a		; 0 -> a
232f  320750    ld      (#5007),a	; kick coin counter?
2332  3e0f      ld      a,#0f
2334  77        ld      (hl),a
2335  2c        inc     l
2336  20fc      jr      nz,#2334        ; loop
2338  24        inc     h
2339  10f0      djnz    #232b           ; loop

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
; 233f  d300      out     (#00),a	; interrupt vector -> 0xfa $3ffa vector to $3000
	; see also "INTERRUPT MODE 2" above...


2341  af        xor     a		; a = 0
2342  320750    ld      (#5007),a	;  clear coin counter
2345  3c        inc     a		; a = 1    (a++)
2346  320050    ld      (#5000),a	; Enable interrupts (pcb)
2349  fb        ei			; Enable interrupts (cpu)
234a  76        halt			; WAIT for interrupt then jump 0x0038 

		
	;; main program init
	;; perhaps a contiuation from 3295
234b  32c050    ld      (#50c0),a	; kick dog
234e  31c04f    ld      sp,#4fc0	; set stack pointer

	;; reset custom registers.  Set them to 0
2351  af        xor     a
2352  210050    ld      hl,#5000	; from $5000
2355  010808    ld      bc,#0808	; for $0808 bytes
2358  cf        rst     #8		; disable all

	;; clear ram
2359  21004c    ld      hl,#4c00
235c  06be      ld      b,#be
235e  cf        rst     #8
235f  cf        rst     #8
2360  cf        rst     #8
2361  cf        rst     #8

	;; clear sound registers, sprite positions 
2362  214050    ld      hl,#5040
2365  0640      ld      b,#40
2367  cf        rst     #8

2368  32c050    ld      (#50c0),a	; kick dog
236b  cd0d24    call    #240d		; clear color ram
236e  32c050    ld      (#50c0),a	; kick dog
2371  0600      ld      b,#00
2373  cded23    call    #23ed
2376  32c050    ld      (#50c0),a	; kick dog
2379  21c04c    ld      hl,#4cc0
237c  22804c    ld      (#4c80),hl
237f  22824c    ld      (#4c82),hl

	;; 0xff -> 4cc0-4cff
2382  3eff      ld      a,#ff
2384  0640      ld      b,#40
2386  cf        rst     #8
2387  3e01      ld      a,#01
2389  320050    ld      (#5000),a 	; enable interrupts
238c  fb        ei      		; enable interrupts
238d  2a824c    ld      hl,(#4c82)
2390  7e        ld      a,(hl)
2391  a7        and     a
2392  fa8d23    jp      m,#238d
2395  36ff      ld      (hl),#ff
2397  2c        inc     l
2398  46        ld      b,(hl)
2399  36ff      ld      (hl),#ff
239b  2c        inc     l
239c  2002      jr      nz,#23a0        ; (2)
239e  2ec0      ld      l,#c0
23a0  22824c    ld      (#4c82),hl
23a3  218d23    ld      hl,#238d
23a6  e5        push    hl
23a7  e7        rst     #20		; where does it jmp from here?

	; data table?
23a8  ed23      db      #ed, #23        ; Undocumented 8 T-State NOP
23aa  d7        rst     #10
23ab  24        inc     h
23ac  19        add     hl,de
23ad  24        inc     h
23ae  48        ld      c,b
23af  24        inc     h
23b0  3d        dec     a
23b1  25        dec     h
23b2  8b        adc     a,e
23b3  260d      ld      h,#0d
23b5  24        inc     h
23b6  98        sbc     a,b
23b7  2630      ld      h,#30
23b9  27        daa     
23ba  6c        ld      l,h
23bb  27        daa     
23bc  a9        xor     c
23bd  27        daa     
23be  f1        pop     af
23bf  27        daa     
23c0  3b        dec     sp
23c1  2865      jr      z,#2428         ; (101)
23c3  288f      jr      z,#2354         ; (-113)
23c5  28b9      jr      z,#2380         ; (-71)
23c7  280d      jr      z,#23d6         ; (13)
23c9  00        nop     
23ca  a2        and     d
23cb  26c9      ld      h,#c9
23cd  24        inc     h
23ce  35        dec     (hl)
23cf  2ad026    ld      hl,(#26d0)
23d2  87        add     a,a
23d3  24        inc     h
23d4  e8        ret     pe

	;; subroutine
23d5  23        inc     hl
23d6  e3        ex      (sp),hl
23d7  28e0      jr      z,#23b9         ; (-32)
23d9  2a5a2a    ld      hl,(#2a5a)
23dc  6a        ld      l,d
23dd  2b        dec     hl
23de  ea2be3    jp      pe,#e32b
23e1  95        sub     l
23e2  a1        and     c
23e3  2b        dec     hl
23e4  75        ld      (hl),l
23e5  26b2      ld      h,#b2
23e7  2621      ld      h,#21
23e9  04        inc     b
23ea  4e        ld      c,(hl)
23eb  34        inc     (hl)
23ec  c9        ret     

	;; subroutine
23ed  78        ld      a,b
23ee  e7        rst     #20
23ef  f3        di      		; disable interrupts
23f0  23        inc     hl
23f1  00        nop     
23f2  24        inc     h
23f3  3e40      ld      a,#40
23f5  010400    ld      bc,#0004
23f8  210040    ld      hl,#4000	; start of video ram
23fb  cf        rst     #8
23fc  0d        dec     c
23fd  20fc      jr      nz,#23fb        ; (-4)
23ff  c9        ret     

	;; set video ram to 0x40 	; just before boxes
2400  3e40      ld      a,#40
2402  214040    ld      hl,#4040
2405  010480    ld      bc,#8004
2408  cf        rst     #8
2409  0d        dec     c
240a  20fc      jr      nz,#2408        ; (-4)
240c  c9        ret     

	;; set color ram to 0x00
240d  af        xor     a
240e  010400    ld      bc,#0004
2411  210044    ld      hl,#4400	; start of color ram
2414  cf        rst     #8
2415  0d        dec     c
2416  20fc      jr      nz,#2414        ; (-4)
2418  c9        ret     
	;; this is probably the routine that draws the power pellets on
	;; the screen.  It calls 94ec, which probably draws the pellets
	;; in the proper locations according to the ms-pac mazes.

	;; Draw out the maze to the screen
2419  210040    ld      hl,#4000	; start of video ram
241c  cd6a94    call    #946a		; patch to retreive map info
241f  0a        ld      a,(bc)		; get data
2420  a7        and     a
2421  c8        ret     z		; 0 is the end of the level data
2422  fa2c24    jp      m,#242c		; if it's < 0x80, data is an offset
2425  5f        ld      e,a
2426  1600      ld      d,#00
2428  19        add     hl,de		; adjust VRAM pointer
2429  2b        dec     hl
242a  03        inc     bc		; point to next data
242b  0a        ld      a,(bc)		; load data and store in VRAM
242c  23        inc     hl
242d  77        ld      (hl),a
242e  f5        push    af
242f  e5        push    hl
2430  11e083    ld      de,#83e0	; calculate mirror position
2433  7d        ld      a,l
2434  e61f      and     #1f
2436  87        add     a,a
2437  2600      ld      h,#00
2439  6f        ld      l,a
243a  19        add     hl,de
243b  d1        pop     de
243c  a7        and     a
243d  ed52      sbc     hl,de
243f  f1        pop     af
2440  ee01      xor     #01		; calculate reflected title
2442  77        ld      (hl),a		; store reflected title in position
2443  eb        ex      de,hl
2444  03        inc     bc		; next data
2445  c31f24    jp      #241f		; keep going

	; draw out the player pills
2448  210040    ld      hl,#4000	; start of video ram
244b  c37c94    jp      #947c		; patch
244e  4e        ld      c,(hl)		; junk
244f  fd21b535  ld      iy,#35b5	; points to pill data
2453  1600      ld      d,#00
2455  061e      ld      b,#1e		; total # pills entries
2457  0e08      ld      c,#08		; 8x
2459  dd7e00    ld      a,(ix+#00)	; get current pill entry
245c  fd5e00    ld      e,(iy+#00)	; get current offset
245f  19        add     hl,de		; adjust vram
2460  07        rlca    		; get current byte
2461  3002      jr      nc,#2465        ; skip pill if no carry
2463  3610      ld      (hl),#10	;  draw pill
2465  fd23      inc     iy		; next entry
2467  0d        dec     c
2468  20f2      jr      nz,#245c        ; keep testing all the bits
246a  dd23      inc     ix		; go to next pill entry
246c  05        dec     b
246d  20e8      jr      nz,#2457        ; keep drawing pills
246f  21344e    ld      hl,#4e34	; copy big pill
2472  c3ec94    jp      #94ec		; pellet check routine
	; pac's version:
; 2472  116440    ld      de,#4064        ;  power pellet address (upper right)

	; junk:
2475  eda0      ldi     
2477  117840    ld      de,#4078	;  power pellet address (lower right)
247a  eda0      ldi     
247c  118443    ld      de,#4384	;  power pellet address (upper left)
247f  eda0      ldi     
2481  119843    ld      de,#4398	;  power pellet address (lower left)
2484  eda0      ldi     
2486  c9        ret     

	;; update the current screen pill config to work ram
2487  210040    ld      hl,#4000	; start of work ram
248a  c38194    jp      #9481
248d  4e        ld      c,(hl)
	; pac's version:
;248a  dd21164e  ld      ix,#4e16

248e  fd21b535  ld      iy,#35b5	; start of some data

2492  1600      ld      d,#00
2494  061e      ld      b,#1e
2496  0e08      ld      c,#08
2498  fd5e00    ld      e,(iy+#00)
249b  19        add     hl,de
249c  7e        ld      a,(hl)
249d  fe10      cp      #10
249f  37        scf     
24a0  2801      jr      z,#24a3         ; (1)
24a2  3f        ccf     
24a3  ddcb0016  rl      (ix+#00)
24a7  fd23      inc     iy
24a9  0d        dec     c
24aa  20ec      jr      nz,#2498        ; (-20)
24ac  dd23      inc     ix
24ae  05        dec     b
24af  20e5      jr      nz,#2496        ; (-27)
24b1  216440    ld      hl,#4064	;;  power pellet address
24b4  c30495    jp      #9504		; pellet check routine
	; pac's version:
; 24b4  11344e    ld      de,#4e34	;  power pellet address

	; junk:
24b7  eda0      ldi     
24b9  217840    ld      hl,#4078	;  power pellet address
24bc  eda0      ldi     
24be  218443    ld      hl,#4384	;  power pellet address
24c1  eda0      ldi     
24c3  219843    ld      hl,#4398	;  power pellet address
24c6  eda0      ldi     
24c8  c9        ret     

24c9  21164e    ld      hl,#4e16
24cc  3eff      ld      a,#ff
24ce  061e      ld      b,#1e
24d0  cf        rst     #8
24d1  3e14      ld      a,#14
24d3  0604      ld      b,#04
24d5  cf        rst     #8
24d6  c9        ret     

	; sets up the maze color
24d7  58        ld      e,b
24d8  78        ld      a,b
24d9  fe02      cp      #02
24db  3e1f      ld      a,#1f
24dd  c38095    jp      #9580
24e0  10				; junk

24e1  214044	ld	hl, #4440	; draw color to screen
24e4  010480    ld      bc,#8004
24e7  cf        rst     #8
24e8  0d        dec     c
24e9  20fc      jr      nz,#24e7        ; (-4)
24eb  3e0f      ld      a,#0f
24ed  0640      ld      b,#40
24ef  21c047    ld      hl,#47c0
24f2  cf        rst     #8
24f3  7b        ld      a,e
24f4  fe01      cp      #01
24f6  c0        ret     nz

24f7  3e1a      ld      a,#1a
24f9  c3c395    jp      #95c3
24fc  0606      ld      b,#06
24fe  dd21a045  ld      ix,#45a0
2502  dd770c    ld      (ix+#0c),a
2505  dd7718    ld      (ix+#18),a
2508  dd19      add     ix,de
250a  10f6      djnz    #2502           ; (-10)
250c  3e1b      ld      a,#1b
250e  0605      ld      b,#05
2510  dd214044  ld      ix,#4440
2514  dd770e    ld      (ix+#0e),a
2517  dd770f    ld      (ix+#0f),a
251a  dd7710    ld      (ix+#10),a
251d  dd19      add     ix,de
251f  10f3      djnz    #2514           ; (-13)
2521  0605      ld      b,#05
2523  dd212047  ld      ix,#4720
2527  dd770e    ld      (ix+#0e),a
252a  dd770f    ld      (ix+#0f),a
252d  dd7710    ld      (ix+#10),a
2530  dd19      add     ix,de
2532  10f3      djnz    #2527           ; (-13)
2534  3e18      ld      a,#18
2536  32ed45    ld      (#45ed),a
2539  320d46    ld      (#460d),a
253c  c9        ret     

	;; this is strange...  possibly data of some kind?
253d  dd21004c  ld      ix,#4c00
2541  dd360220  ld      (ix+#02),#20
2545  dd360420  ld      (ix+#04),#20
2549  dd360620  ld      (ix+#06),#20
254d  dd360820  ld      (ix+#08),#20
2551  dd360a2c  ld      (ix+#0a),#2c
2555  dd360c3f  ld      (ix+#0c),#3f
2559  dd360301  ld      (ix+#03),#01
255d  dd360503  ld      (ix+#05),#03
2561  dd360705  ld      (ix+#07),#05
2565  dd360907  ld      (ix+#09),#07
2569  dd360b09  ld      (ix+#0b),#09
256d  dd360d00  ld      (ix+#0d),#00
2571  78        ld      a,b
2572  a7        and     a
2573  c20f26    jp      nz,#260f
2576  216480    ld      hl,#8064
2579  22004d    ld      (#4d00),hl
257c  217c80    ld      hl,#807c
257f  22024d    ld      (#4d02),hl
2582  217c90    ld      hl,#907c
2585  22044d    ld      (#4d04),hl
2588  217c70    ld      hl,#707c
258b  22064d    ld      (#4d06),hl
258e  21c480    ld      hl,#80c4
2591  22084d    ld      (#4d08),hl
2594  212c2e    ld      hl,#2e2c
2597  220a4d    ld      (#4d0a),hl
259a  22314d    ld      (#4d31),hl
259d  212f2e    ld      hl,#2e2f
25a0  220c4d    ld      (#4d0c),hl
25a3  22334d    ld      (#4d33),hl
25a6  212f30    ld      hl,#302f
25a9  220e4d    ld      (#4d0e),hl
25ac  22354d    ld      (#4d35),hl
25af  212f2c    ld      hl,#2c2f
25b2  22104d    ld      (#4d10),hl
25b5  22374d    ld      (#4d37),hl
25b8  21382e    ld      hl,#2e38
25bb  22124d    ld      (#4d12),hl
25be  22394d    ld      (#4d39),hl
25c1  210001    ld      hl,#0100
25c4  22144d    ld      (#4d14),hl
25c7  221e4d    ld      (#4d1e),hl
25ca  210100    ld      hl,#0001
25cd  22164d    ld      (#4d16),hl
25d0  22204d    ld      (#4d20),hl
25d3  21ff00    ld      hl,#00ff
25d6  22184d    ld      (#4d18),hl
25d9  22224d    ld      (#4d22),hl
25dc  21ff00    ld      hl,#00ff
25df  221a4d    ld      (#4d1a),hl
25e2  22244d    ld      (#4d24),hl
25e5  210001    ld      hl,#0100
25e8  221c4d    ld      (#4d1c),hl
25eb  22264d    ld      (#4d26),hl
25ee  210201    ld      hl,#0102
25f1  22284d    ld      (#4d28),hl
25f4  222c4d    ld      (#4d2c),hl
25f7  210303    ld      hl,#0303
25fa  222a4d    ld      (#4d2a),hl
25fd  222e4d    ld      (#4d2e),hl
2600  3e02      ld      a,#02
2602  32304d    ld      (#4d30),a
2605  323c4d    ld      (#4d3c),a
2608  210000    ld      hl,#0000
260b  22d24d    ld      (#4dd2),hl
260e  c9        ret     

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
2674  c9        ret     

2675  210000    ld      hl,#0000
2678  22d24d    ld      (#4dd2),hl
267b  22084d    ld      (#4d08),hl
267e  22004d    ld      (#4d00),hl
2681  22024d    ld      (#4d02),hl
2684  22044d    ld      (#4d04),hl
2687  22064d    ld      (#4d06),hl
268a  c9        ret     

268b  3e55      ld      a,#55
268d  32944d    ld      (#4d94),a
2690  05        dec     b
2691  c8        ret     z

2692  3e01      ld      a,#01
2694  32a04d    ld      (#4da0),a
2697  c9        ret     

2698  3e01      ld      a,#01		; set intro mode
269a  32004e    ld      (#4e00),a
269d  af        xor     a
269e  32034e    ld      (#4e03),a
26a1  c9        ret     

26a2  af        xor     a
26a3  11004d    ld      de,#4d00
26a6  21004e    ld      hl,#4e00	; game mode
26a9  12        ld      (de),a
26aa  13        inc     de
26ab  a7        and     a
26ac  ed52      sbc     hl,de
26ae  c2a626    jp      nz,#26a6
26b1  c9        ret     

26b2  dd213641  ld      ix,#4136
26b6  3a714e    ld      a,(#4e71)
26b9  e60f      and     #0f
26bb  c630      add     a,#30
26bd  dd7700    ld      (ix+#00),a
26c0  3a714e    ld      a,(#4e71)
26c3  0f        rrca    
26c4  0f        rrca    
26c5  0f        rrca    
26c6  0f        rrca    
26c7  e60f      and     #0f
26c9  c8        ret     z

26ca  c630      add     a,#30
26cc  dd7720    ld      (ix+#20),a
26cf  c9        ret     

26d0  3a8050    ld      a,(#5080)	; check in0 for free play
26d3  47        ld      b,a
26d4  e603      and     #03		; free play switch
26d6  c2de26    jp      nz,#26de
26d9  216e4e    ld      hl,#4e6e	; credit memory
26dc  36ff      ld      (hl),#ff	; store $FF for free play
26de  4f        ld      c,a
26df  1f        rra     
26e0  ce00      adc     a,#00
26e2  326b4e    ld      (#4e6b),a
26e5  e602      and     #02
26e7  a9        xor     c
26e8  326d4e    ld      (#4e6d),a
26eb  78        ld      a,b
26ec  0f        rrca    
26ed  0f        rrca    
26ee  e603      and     #03
26f0  3c        inc     a
26f1  fe04      cp      #04
26f3  2001      jr      nz,#26f6        ; (1)
26f5  3c        inc     a
26f6  326f4e    ld      (#4e6f),a
26f9  78        ld      a,b
26fa  0f        rrca    
26fb  0f        rrca    
26fc  0f        rrca    
26fd  0f        rrca    
26fe  e603      and     #03
2700  212827    ld      hl,#2728
2703  d7        rst     #10
2704  32714e    ld      (#4e71),a
2707  78        ld      a,b
2708  07        rlca    
2709  2f        cpl     
270a  e601      and     #01
270c  32754e    ld      (#4e75),a
270f  78        ld      a,b
2710  07        rlca    
2711  07        rlca    
2712  2f        cpl     
2713  e601      and     #01
2715  47        ld      b,a
2716  212c27    ld      hl,#272c	; difficulty tables
2719  df        rst     #18
271a  22734e    ld      (#4e73),hl	; difficulty
271d  3a4050    ld      a,(#5040)	;; check in1
2720  07        rlca    
2721  2f        cpl     
2722  e601      and     #01
2724  32724e    ld      (#4e72),a
2727  c9        ret     

	; data - bonus/life
2728  10 15 20 ff

	; data - difficulty settings table
272c  68 00 7d 00
	; normal at 0068
	; hard at 007d

    ;; red ghost logic: (not blue)
2730  3ac14d    ld      a,(#4dc1)	;; 0= random movement 1= normal movement
2733  cb47      bit     0,a
2735  c25827    jp      nz,#2758	;; get norm red movement
2738  3ab64d    ld      a,(#4db6)	;; 0=normal  1= faster ghost,most dots
273b  a7        and     a
273c  201a      jr      nz,#2758        ;; get norm red direction (below)
273e  3a044e    ld      a,(#4e04)	;; 3=ghost move, 2=ghost wait for start
2741  fe03      cp      #03
2743  2013      jr      nz,#2758        ;; get norm red direction (below)
2745  2a0a4d    ld      hl,(#4d0a)	;; read red ghost location  YY XX
2748  3a2c4d    ld      a,(#4d2c)	;; read direction
274b  cd6195    call    #9561		;; pick a quadrant for the destination
274e  cd6629    call    #2966		;; get dir. by finding shortest distance
2751  221e4d    ld      (#4d1e),hl	;; store offset
2754  322c4d    ld      (#4d2c),a	;; store direction
2757  c9        ret     

    ;; normal movement get direction for red ghost
2758  2a0a4d    ld      hl,(#4d0a)	;; red ghost location  YY XX
275b  ed5b394d  ld      de,(#4d39)	;; ms pac location YY XX
275f  3a2c4d    ld      a,(#4d2c)	;; current direction
2762  cd6629    call    #2966		;; get dir. by finding shortest distance
2765  221e4d    ld      (#4d1e),hl
2768  322c4d    ld      (#4d2c),a
276b  c9        ret     		;; HL= offset for direction, a= dir.

276c  3ac14d    ld      a,(#4dc1)
276f  cb47      bit     0,a
2771  c28e27    jp      nz,#278e
2774  3a044e    ld      a,(#4e04)	; level cleared register
2777  fe03      cp      #03
2779  2013      jr      nz,#278e        ; jump if not 3
277b  2a0c4d    ld      hl,(#4d0c)
277e  3a2d4d    ld      a,(#4d2d)
2781  cd6195    call    #9561
2784  cd6629    call    #2966
2787  22204d    ld      (#4d20),hl
278a  322d4d    ld      (#4d2d),a
278d  c9        ret     

278e  ed5b394d  ld      de,(#4d39)
2792  2a1c4d    ld      hl,(#4d1c)

    ; hard hack: HACK6
; 2795  00        nop

2795  29        add     hl,hl
2796  29        add     hl,hl
2797  19        add     hl,de
2798  eb        ex      de,hl
2799  2a0c4d    ld      hl,(#4d0c)
279c  3a2d4d    ld      a,(#4d2d)
279f  cd6629    call    #2966
27a2  22204d    ld      (#4d20),hl
27a5  322d4d    ld      (#4d2d),a
27a8  c9        ret     

27a9  3ac14d    ld      a,(#4dc1)
27ac  cb47      bit     0,a
27ae  c2cb27    jp      nz,#27cb
27b1  3a044e    ld      a,(#4e04)	; level cleared register
27b4  fe03      cp      #03
27b6  2013      jr      nz,#27cb        ; jump if not 3
27b8  2a0e4d    ld      hl,(#4d0e)
27bb  cd5995    call    #9559
27be  114020    ld      de,#2040
27c1  cd6629    call    #2966
27c4  22224d    ld      (#4d22),hl
27c7  322e4d    ld      (#4d2e),a
27ca  c9        ret     

27cb  ed4b0a4d  ld      bc,(#4d0a)
27cf  ed5b394d  ld      de,(#4d39)
27d3  2a1c4d    ld      hl,(#4d1c)
27d6  29        add     hl,hl
27d7  19        add     hl,de
27d8  7d        ld      a,l
27d9  87        add     a,a
27da  91        sub     c
27db  6f        ld      l,a
27dc  7c        ld      a,h
27dd  87        add     a,a
27de  90        sub     b
27df  67        ld      h,a
27e0  eb        ex      de,hl
27e1  2a0e4d    ld      hl,(#4d0e)
27e4  3a2e4d    ld      a,(#4d2e)
27e7  cd6629    call    #2966
27ea  22224d    ld      (#4d22),hl
27ed  322e4d    ld      (#4d2e),a
27f0  c9        ret     

27f1  3ac14d    ld      a,(#4dc1)
27f4  cb47      bit     0,a
27f6  c21328    jp      nz,#2813
27f9  3a044e    ld      a,(#4e04)	; level cleared register
27fc  fe03      cp      #03
27fe  2013      jr      nz,#2813        ; jump if not 3
2800  2a104d    ld      hl,(#4d10)
2803  cd5e95    call    #955e
2806  11403b    ld      de,#3b40
2809  cd6629    call    #2966
280c  22244d    ld      (#4d24),hl
280f  322f4d    ld      (#4d2f),a
2812  c9        ret     

2813  dd21394d  ld      ix,#4d39
2817  fd21104d  ld      iy,#4d10
281b  cdea29    call    #29ea

281e  114000    ld      de,#0040
    ; hard hack: HACK6
; 281e  112400    ld      de,#0024

2821  a7        and     a
2822  ed52      sbc     hl,de
2824  da0028    jp      c,#2800
2827  2a104d    ld      hl,(#4d10)
282a  ed5b394d  ld      de,(#4d39)
282e  3a2f4d    ld      a,(#4d2f)
2831  cd6629    call    #2966
2834  22244d    ld      (#4d24),hl
2837  322f4d    ld      (#4d2f),a
283a  c9        ret     

283b  3aac4d    ld      a,(#4dac)
283e  a7        and     a
283f  ca5528    jp      z,#2855
2842  112c2e    ld      de,#2e2c
2845  2a0a4d    ld      hl,(#4d0a)
2848  3a2c4d    ld      a,(#4d2c)
284b  cd6629    call    #2966
284e  221e4d    ld      (#4d1e),hl
2851  322c4d    ld      (#4d2c),a
2854  c9        ret     

2855  2a0a4d    ld      hl,(#4d0a)
2858  3a2c4d    ld      a,(#4d2c)
285b  cd1e29    call    #291e
285e  221e4d    ld      (#4d1e),hl
2861  322c4d    ld      (#4d2c),a
2864  c9        ret     

2865  3aad4d    ld      a,(#4dad)
2868  a7        and     a
2869  ca7f28    jp      z,#287f
286c  112c2e    ld      de,#2e2c
286f  2a0c4d    ld      hl,(#4d0c)
2872  3a2d4d    ld      a,(#4d2d)
2875  cd6629    call    #2966
2878  22204d    ld      (#4d20),hl
287b  322d4d    ld      (#4d2d),a
287e  c9        ret     

287f  2a0c4d    ld      hl,(#4d0c)
2882  3a2d4d    ld      a,(#4d2d)
2885  cd1e29    call    #291e
2888  22204d    ld      (#4d20),hl
288b  322d4d    ld      (#4d2d),a
288e  c9        ret     

288f  3aae4d    ld      a,(#4dae)
2892  a7        and     a
2893  caa928    jp      z,#28a9
2896  112c2e    ld      de,#2e2c
2899  2a0e4d    ld      hl,(#4d0e)
289c  3a2e4d    ld      a,(#4d2e)
289f  cd6629    call    #2966
28a2  22224d    ld      (#4d22),hl
28a5  322e4d    ld      (#4d2e),a
28a8  c9        ret     

28a9  2a0e4d    ld      hl,(#4d0e)
28ac  3a2e4d    ld      a,(#4d2e)
28af  cd1e29    call    #291e
28b2  22224d    ld      (#4d22),hl
28b5  322e4d    ld      (#4d2e),a
28b8  c9        ret     

28b9  3aaf4d    ld      a,(#4daf)
28bc  a7        and     a
28bd  cad328    jp      z,#28d3
28c0  112c2e    ld      de,#2e2c
28c3  2a104d    ld      hl,(#4d10)
28c6  3a2f4d    ld      a,(#4d2f)
28c9  cd6629    call    #2966
28cc  22244d    ld      (#4d24),hl
28cf  322f4d    ld      (#4d2f),a
28d2  c9        ret     

28d3  2a104d    ld      hl,(#4d10)
28d6  3a2f4d    ld      a,(#4d2f)
28d9  cd1e29    call    #291e
28dc  22244d    ld      (#4d24),hl
28df  322f4d    ld      (#4d2f),a
28e2  c9        ret     

28e3  3aa74d    ld      a,(#4da7)
28e6  a7        and     a
28e7  cafe28    jp      z,#28fe
28ea  2a124d    ld      hl,(#4d12)
28ed  ed5b0c4d  ld      de,(#4d0c)
28f1  3a3c4d    ld      a,(#4d3c)
28f4  cd6629    call    #2966
28f7  22264d    ld      (#4d26),hl
28fa  323c4d    ld      (#4d3c),a
28fd  c9        ret     

28fe  2a394d    ld      hl,(#4d39)
2901  ed4b0c4d  ld      bc,(#4d0c)
2905  7d        ld      a,l
2906  87        add     a,a
2907  91        sub     c
2908  6f        ld      l,a
2909  7c        ld      a,h
290a  87        add     a,a
290b  90        sub     b
290c  67        ld      h,a
290d  eb        ex      de,hl
290e  2a124d    ld      hl,(#4d12)
2911  3a3c4d    ld      a,(#4d3c)
2914  cd6629    call    #2966
2917  22264d    ld      (#4d26),hl
291a  323c4d    ld      (#4d3c),a
291d  c9        ret     

291e  223e4d    ld      (#4d3e),hl
2921  ee02      xor     #02
2923  323d4d    ld      (#4d3d),a
2926  cd232a    call    #2a23		; get a random number
2929  e603      and     #03
292b  213b4d    ld      hl,#4d3b
292e  77        ld      (hl),a
292f  87        add     a,a
2930  5f        ld      e,a
2931  1600      ld      d,#00
2933  dd21ff32  ld      ix,#32ff
2937  dd19      add     ix,de
2939  fd213e4d  ld      iy,#4d3e
293d  3a3d4d    ld      a,(#4d3d)
2940  be        cp      (hl)
2941  ca5729    jp      z,#2957
2944  cd0f20    call    #200f
2947  e6c0      and     #c0
2949  d6c0      sub     #c0
294b  280a      jr      z,#2957         ; (10)
294d  dd6e00    ld      l,(ix+#00)
2950  dd6601    ld      h,(ix+#01)
2953  3a3b4d    ld      a,(#4d3b)
2956  c9        ret     

2957  dd23      inc     ix
2959  dd23      inc     ix
295b  213b4d    ld      hl,#4d3b
295e  7e        ld      a,(hl)
295f  3c        inc     a
2960  e603      and     #03
2962  77        ld      (hl),a
2963  c33d29    jp      #293d


	;; distance check.  (used for ghost logic)
2966  223e4d    ld      (#4d3e),hl
2969  ed53404d  ld      (#4d40),de
296d  323b4d    ld      (#4d3b),a
2970  ee02      xor     #02
2972  323d4d    ld      (#4d3d),a
2975  21ffff    ld      hl,#ffff
2978  22444d    ld      (#4d44),hl
297b  dd21ff32  ld      ix,#32ff
297f  fd213e4d  ld      iy,#4d3e
2983  21c74d    ld      hl,#4dc7
2986  3600      ld      (hl),#00
2988  3a3d4d    ld      a,(#4d3d)
298b  be        cp      (hl)
298c  cac629    jp      z,#29c6
298f  cd0020    call    #2000
2992  22424d    ld      (#4d42),hl
2995  cd6500    call    #0065
2998  7e        ld      a,(hl)
2999  e6c0      and     #c0
299b  d6c0      sub     #c0
299d  2827      jr      z,#29c6         ; (39)
299f  dde5      push    ix
29a1  fde5      push    iy
29a3  dd21404d  ld      ix,#4d40
29a7  fd21424d  ld      iy,#4d42
29ab  cdea29    call    #29ea
29ae  fde1      pop     iy
29b0  dde1      pop     ix
29b2  eb        ex      de,hl
29b3  2a444d    ld      hl,(#4d44)
29b6  a7        and     a
29b7  ed52      sbc     hl,de
29b9  dac629    jp      c,#29c6
29bc  ed53444d  ld      (#4d44),de
29c0  3ac74d    ld      a,(#4dc7)
29c3  323b4d    ld      (#4d3b),a
29c6  dd23      inc     ix
29c8  dd23      inc     ix
29ca  21c74d    ld      hl,#4dc7
29cd  34        inc     (hl)
29ce  3e04      ld      a,#04
29d0  be        cp      (hl)
29d1  c28829    jp      nz,#2988
29d4  3a3b4d    ld      a,(#4d3b)
29d7  87        add     a,a
29d8  5f        ld      e,a
29d9  1600      ld      d,#00
29db  dd21ff32  ld      ix,#32ff
29df  dd19      add     ix,de
29e1  dd6e00    ld      l,(ix+#00)
29e4  dd6601    ld      h,(ix+#01)
29e7  cb3f      srl     a
29e9  c9        ret     


29ea  dd7e00    ld      a,(ix+#00)
29ed  fd4600    ld      b,(iy+#00)
29f0  90        sub     b
29f1  d2f929    jp      nc,#29f9
29f4  78        ld      a,b
29f5  dd4600    ld      b,(ix+#00)
29f8  90        sub     b
29f9  cd122a    call    #2a12
29fc  e5        push    hl
29fd  dd7e01    ld      a,(ix+#01)
2a00  fd4601    ld      b,(iy+#01)
2a03  90        sub     b
2a04  d20c2a    jp      nc,#2a0c
2a07  78        ld      a,b
2a08  dd4601    ld      b,(ix+#01)
2a0b  90        sub     b
2a0c  cd122a    call    #2a12
2a0f  c1        pop     bc
2a10  09        add     hl,bc
2a11  c9        ret     

2a12  67        ld      h,a
2a13  5f        ld      e,a
2a14  2e00      ld      l,#00
2a16  55        ld      d,l
2a17  0e08      ld      c,#08
2a19  29        add     hl,hl
2a1a  d21e2a    jp      nc,#2a1e
2a1d  19        add     hl,de
2a1e  0d        dec     c
2a1f  c2192a    jp      nz,#2a19
2a22  c9        ret     

    ;; Random number generator

;; $2a23 random number generator, only active when ghosts are blue.    
;; n=(n*5+1)&&$1fff.  n is used as an address to read a byte from a rom.
;; $4dc9,$4dca=n  and a=rnd number. n is reset to 0 at $26a9 when you die,
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
2a5a  3a004e    ld      a,(#4e00)	; game mode
2a5d  fe01      cp      #01
2a5f  c8        ret     z		; return if intro mode

    ; this updates the score when something is eaten
    ; (from the above table at 2b17)
    ; load a with the item eaten
2a60  21172b    ld      hl,#2b17
2a63  df        rst     #18
2a64  eb        ex      de,hl
2a65  cd0b2b    call    #2b0b
2a68  7b        ld      a,e
2a69  86        add     a,(hl)
2a6a  27        daa     
2a6b  77        ld      (hl),a
2a6c  23        inc     hl
2a6d  7a        ld      a,d
2a6e  8e        adc     a,(hl)
2a6f  27        daa     
2a70  77        ld      (hl),a
2a71  5f        ld      e,a
2a72  23        inc     hl
2a73  3e00      ld      a,#00
2a75  8e        adc     a,(hl)
2a76  27        daa     
2a77  77        ld      (hl),a
2a78  57        ld      d,a
2a79  eb        ex      de,hl
2a7a  29        add     hl,hl
2a7b  29        add     hl,hl
2a7c  29        add     hl,hl
2a7d  29        add     hl,hl
2a7e  3a714e    ld      a,(#4e71)	; bonus life
2a81  3d        dec     a
2a82  bc        cp      h
2a83  dc332b    call    c,#2b33
2a86  cdaf2a    call    #2aaf
2a89  13        inc     de
2a8a  13        inc     de
2a8b  13        inc     de
2a8c  218a4e    ld      hl,#4e8a	; msb high score ram area
2a8f  0603      ld      b,#03
2a91  1a        ld      a,(de)
2a92  be        cp      (hl)
2a93  d8        ret     c		; return if high score not beat?

	;; perhaps this part draws the new high score atop the screen
	;  if it is higher than the current high score?  
2a94  2005      jr      nz,#2a9b        ; jump if not even
2a96  1b        dec     de
2a97  2b        dec     hl
2a98  10f7      djnz    #2a91           ; (-9)
2a9a  c9        ret     

	;; possibly checking the high score?
2a9b  cd0b2b    call    #2b0b
2a9e  11884e    ld      de,#4e88	; lsb high score memory
2aa1  010300    ld      bc,#0003
2aa4  edb0      ldir    
2aa6  1b        dec     de
2aa7  010403    ld      bc,#0304
2aaa  21f243    ld      hl,#43f2
2aad  180f      jr      #2abe           ; (15)
2aaf  3a094e    ld      a,(#4e09)
2ab2  010403    ld      bc,#0304
2ab5  21fc43    ld      hl,#43fc	; screen pos for current score
2ab8  a7        and     a
2ab9  2803      jr      z,#2abe         ; (3)
2abb  21e943    ld      hl,#43e9	; screen pos for high score

	;; draw the score to the screen?
2abe  1a        ld      a,(de)
2abf  0f        rrca    
2ac0  0f        rrca    
2ac1  0f        rrca    
2ac2  0f        rrca    
2ac3  cdce2a    call    #2ace
2ac6  1a        ld      a,(de)
2ac7  cdce2a    call    #2ace
2aca  1b        dec     de
2acb  10f1      djnz    #2abe           ; (-15)
2acd  c9        ret     

2ace  e60f      and     #0f
2ad0  2804      jr      z,#2ad6         ; (4)
2ad2  0e00      ld      c,#00
2ad4  1807      jr      #2add           ; (7)
2ad6  79        ld      a,c
2ad7  a7        and     a
2ad8  2803      jr      z,#2add         ; (3)
2ada  3e40      ld      a,#40
2adc  0d        dec     c
2add  77        ld      (hl),a
2ade  2b        dec     hl
2adf  c9        ret     

	;; something with the player 1 score
2ae0  0600      ld      b,#00
2ae2  cd5e2c    call    #2c5e		; print HIGH SCORE
2ae5  af        xor     a
2ae6  21804e    ld      hl,#4e80
2ae9  0608      ld      b,#08
2aeb  cf        rst     #8
2aec  010403    ld      bc,#0304
2aef  11824e    ld      de,#4e82	; p1 msb of score
2af2  21fc43    ld      hl,#43fc	; screen pos for p1 current score
2af5  cdbe2a    call    #2abe
2af8  010403    ld      bc,#0304
2afb  11864e    ld      de,#4e86	; high score
2afe  21e943    ld      hl,#43e9	; screen pos for high score
2b01  3a704e    ld      a,(#4e70)
2b04  a7        and     a
2b05  20b7      jr      nz,#2abe        ; (-73)
2b07  0e06      ld      c,#06
2b09  18b3      jr      #2abe           ; (-77)
2b0b  3a094e    ld      a,(#4e09)
2b0e  21804e    ld      hl,#4e80
2b11  a7        and     a
2b12  c8        ret     z

2b13  21844e    ld      hl,#4e84
2b16  c9        ret     

	;; score table
	;; (Spaeth)
2b17  10 00              ; dot        =   10	0
2b19  50 00              ; pellet     =   50	1
2b1b  00 02              ; ghost 1    =  200	2
2b1d  00 04              ; ghost 2    =  400	3
2b1f  00 08              ; ghost 3    =  800    4
2b21  00 16              ; ghost 4    = 1600	5
2b23  00 01              ; Cherry     =  100	6
2b25  00 02              ; Strawberry =  200	7	300
2b27  00 05              ; Orange     =  500	8
2b29  00 07              ; Pretzel    =  700	9
2b2b  00 10              ; Apple      = 1000	a
2b2d  00 20              ; Pear       = 2000	b
2b2f  00 50              ; Banana     = 5000	c	3000
2b31  00 50              ; Junior!    = 5000	d
    ; [The 8th fruit is a legacy thing from pacman, which 
    ;  used 8 bonus items. it is not used in mspac]


2b34  6b        ld      l,e
2b35  62        ld      h,d
2b36  1b        dec     de
2b37  cb46      bit     0,(hl)
2b39  c0        ret     nz

	; bonus life routine
2b3a  cbc6      set     0,(hl)
2b3c  219c4e    ld      hl,#4e9c	; set sound 0
2b3f  cbc6      set     0,(hl)
2b41  21144e    ld      hl,#4e14	; number of lives left
2b44  34        inc     (hl)		; inc lives left
2b45  21154e    ld      hl,#4e15	; number of lives on the screen
2b48  34        inc     (hl)		; inc lives displayed
2b49  46        ld      b,(hl)		; number of lives on the screen
2b4a  211a40    ld      hl,#401a	; screen location
2b4d  0e05      ld      c,#05
2b4f  78        ld      a,b
2b50  a7        and     a
2b51  280e      jr      z,#2b61         ; (14)
2b53  fe06      cp      #06
2b55  300a      jr      nc,#2b61        ; (10)

    ; draw the pacs on the screen (or another 4 character string)       
2b57  3e20      ld      a,#20
2b59  cd8f2b    call    #2b8f
2b5c  2b        dec     hl
2b5d  2b        dec     hl
2b5e  0d        dec     c
2b5f  10f6      djnz    #2b57           ; (-10)

	;; perhaps display the number of lives left on the screen?
2b61  0d        dec     c
2b62  f8        ret     m

2b63  cd7e2b    call    #2b7e
2b66  2b        dec     hl
2b67  2b        dec     hl
2b68  18f7      jr      #2b61           ; (-9)
2b6a  3a004e    ld      a,(#4e00)	; game mode
2b6d  fe01      cp      #01
2b6f  c8        ret     z		; return if intro mode

2b70  cdcd2b    call    #2bcd
2b73  12        ld      (de),a
2b74  44        ld      b,h
2b75  09        add     hl,bc
2b76  0a        ld      a,(bc)
2b77  02        ld      (bc),a
2b78  21154e    ld      hl,#4e15	; number of lives to display
2b7b  46        ld      b,(hl)
2b7c  18cc      jr      #2b4a           ; (-52)
2b7e  3e40      ld      a,#40
	; draw [a] to 2x2 char square
2b80  e5        push    hl
2b81  d5        push    de
2b82  77        ld      (hl),a
2b83  23        inc     hl
2b84  77        ld      (hl),a
2b85  111f00    ld      de,#001f
2b88  19        add     hl,de
2b89  77        ld      (hl),a
2b8a  23        inc     hl
2b8b  77        ld      (hl),a
2b8c  d1        pop     de
2b8d  e1        pop     hl
2b8e  c9        ret     

	; draw fruit
2b8f  e5        push    hl
2b90  d5        push    de
2b91  111f00    ld      de,#001f
2b94  77        ld      (hl),a
2b95  3c        inc     a
2b96  23        inc     hl
2b97  77        ld      (hl),a
2b98  3c        inc     a
2b99  19        add     hl,de
2b9a  77        ld      (hl),a
2b9b  3c        inc     a
2b9c  23        inc     hl
2b9d  77        ld      (hl),a
2b9e  d1        pop     de
2b9f  e1        pop     hl
2ba0  c9        ret     

	;; display number of credits
2ba1  3a6e4e    ld      a,(#4e6e)	; number of credits in ram
2ba4  feff      cp      #ff		; set for free play?
2ba6  2005      jr      nz,#2bad        ; (5) no? then jump
2ba8  0602      ld      b,#02		; "FREE PLAY"
2baa  c35e2c    jp      #2c5e		; print FREE PLAY
2bad  0601      ld      b,#01
2baf  cd5e2c    call    #2c5e		; print CREDIT
2bb2  3a6e4e    ld      a,(#4e6e)	; number of credits in ram
2bb5  e6f0      and     #f0		; bigger than 9?
2bb7  2809      jr      z,#2bc2         ; (9) yes, only inc 1 position
2bb9  0f        rrca    
2bba  0f        rrca    
2bbb  0f        rrca    		; increment tens
2bbc  0f        rrca    		
2bbd  c630      add     a,#30
2bbf  323440    ld      (#4034),a	; put number of credits on screen
2bc2  3a6e4e    ld      a,(#4e6e)	; number of credits in ram
2bc5  e60f      and     #0f		; strip
2bc7  c630      add     a,#30
2bc9  323340    ld      (#4033),a	; put number of credits on screen
2bcc  c9        ret     

2bcd  e1        pop     hl
2bce  5e        ld      e,(hl)
2bcf  23        inc     hl
2bd0  56        ld      d,(hl)
2bd1  23        inc     hl
2bd2  4e        ld      c,(hl)
2bd3  23        inc     hl
2bd4  46        ld      b,(hl)
2bd5  23        inc     hl
2bd6  7e        ld      a,(hl)
2bd7  23        inc     hl
2bd8  e5        push    hl
2bd9  eb        ex      de,hl
2bda  112000    ld      de,#0020
2bdd  e5        push    hl
2bde  c5        push    bc
2bdf  71        ld      (hl),c
2be0  23        inc     hl
2be1  10fc      djnz    #2bdf           ; (-4)
2be3  c1        pop     bc
2be4  e1        pop     hl
2be5  19        add     hl,de
2be6  3d        dec     a
2be7  20f4      jr      nz,#2bdd        ; (-12)
2be9  c9        ret     

2bea  3a004e    ld      a,(#4e00)	; game mode
2bed  fe01      cp      #01
2bef  c8        ret     z		; return if intro mode


	;; new board, increment?
2bf0  3a134e    ld      a,(#4e13)	; current board level
2bf3  3c        inc     a		; increment it
2bf4  c39387    jp      #8793		; pac compares to 8 here... do

	; pac
;2bf4  fe08      cp      #08             ; >= 8?
	; junk...
2bf7  2e2c      ld      l,#2c		

	; returns here from 8793...
2bf9  11083b    ld      de,#3b08	; fruit table?
2bfc  47        ld      b,a
2bfd  0e07      ld      c,#07		; fruit count
2bff  210440    ld      hl,#4004	; starting loc
2c02  1a        ld      a,(de)
2c03  cd8f2b    call    #2b8f		; draw fruit

2c06  3e04      ld      a,#04		; v
2c08  84        add     a,h		; v
2c09  67        ld      h,a		; v
2c0a  13        inc     de		; v
2c0b  1a        ld      a,(de)		; v
2c0c  cd802b    call    #2b80		; erase next fruit
2c0f  3efc      ld      a,#fc
2c11  84        add     a,h
2c12  67        ld      h,a
2c13  13        inc     de
2c14  23        inc     hl
2c15  23        inc     hl
2c16  0d        dec     c
2c17  10e9      djnz    #2c02           ; (-23)
2c19  0d        dec     c
2c1a  f8        ret     m

2c1b  cd7e2b    call    #2b7e
2c1e  3e04      ld      a,#04
2c20  84        add     a,h
2c21  67        ld      h,a
2c22  af        xor     a
2c23  cd802b    call    #2b80
2c26  3efc      ld      a,#fc
2c28  84        add     a,h
2c29  67        ld      h,a
2c2a  23        inc     hl
2c2b  23        inc     hl
2c2c  18eb      jr      #2c19           ; (-21)
2c2e  fe13      cp      #13
2c30  3802      jr      c,#2c34         ; (2)
2c32  3e13      ld      a,#13
2c34  d607      sub     #07
2c36  4f        ld      c,a
2c37  0600      ld      b,#00
2c39  21083b    ld      hl,#3b08
2c3c  09        add     hl,bc
2c3d  09        add     hl,bc
2c3e  eb        ex      de,hl
2c3f  0607      ld      b,#07
2c41  c3fd2b    jp      #2bfd
2c44  47        ld      b,a
2c45  e60f      and     #0f
2c47  c600      add     a,#00
2c49  27        daa     
2c4a  4f        ld      c,a
2c4b  78        ld      a,b
2c4c  e6f0      and     #f0
2c4e  280b      jr      z,#2c5b         ; (11)
2c50  0f        rrca    
2c51  0f        rrca    
2c52  0f        rrca    
2c53  0f        rrca    
2c54  47        ld      b,a
2c55  af        xor     a
2c56  c616      add     a,#16
2c58  27        daa     
2c59  10fb      djnz    #2c56           ; (-5)
2c5b  81        add     a,c
2c5c  27        daa     
2c5d  c9        ret     


        ;; Renders messages from a table with
        ;;   coordinates and message data
        ;;   b=message # in table
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
;	if the color data byte's high bit is not set, then:
;	.byte 	ncolors		; number of bytes to set color
;	.byte	color1		; first character's color
;	.byte	color2		; second character's color
;		...		; etc
2c5e  21a536    ld      hl,#36a5	; 36a5 is the text string lookup table
2c61  df        rst     #18		; (hl+2*b) -> hl
2c62  5e        ld      e,(hl)
2c63  23        inc     hl
2c64  56        ld      d,(hl)  	; de contains start offset
2c65  dd210044  ld      ix,#4400	; start of color RAM
2c69  dd19      add     ix,de		; calculate start pos in CRAM
2c6b  dde5      push    ix		; 4400 + (hl) -> stack
2c6d  1100fc    ld      de,#fc00
2c70  dd19      add     ix,de		; calc start pos in VRAM
2c72  11ffff    ld      de,#ffff	; offset for normal text
2c75  cb7e      bit     7,(hl)
	; it should be noted that since the high bit on the offset address
	; is used to denote that the string goes into the top or bottom
	; two rows, it ends up relying on the unused ram mirroring.
	; that is to say that it actually ends up drawing up around C000
	; instead of 4000.  A patch is below as HACK12
2c77  2003      jr      nz,#2c7c        ; (3)
2c79  11e0ff    ld      de,#ffe0	; offset for top + bot 2 lines
2c7c  23        inc     hl
2c7d  78        ld      a,b		; b -> a
2c7e  010000    ld      bc,#0000	; 0 -> b,c
2c81  87        add     a,a		; 2*a -> a
2c82  3828      jr      c,#2cac         ; special draw for entries 80+
2c84  7e        ld      a,(hl)		; read next char
2c85  fe2f      cp      #2f		; #2f is end of text
2c87  2809      jr      z,#2c92         ; done with VRAM
2c89  dd7700    ld      (ix+#00),a	; write char to screen
2c8c  23        inc     hl		; next char
2c8d  dd19      add     ix,de		; calc next VRAM pos
2c8f  04        inc     b		; inc char count
2c90  18f2      jr      #2c84           ; loop
2c92  23        inc     hl
2c93  dde1      pop     ix		; get CRAM start pos
2c95  7e        ld      a,(hl)		; get color
2c96  a7        and     a
2c97  faa42c    jp      m,#2ca4		; jump if > #80
2c9a  7e        ld      a,(hl)		; get color
2c9b  dd7700    ld      (ix+#00),a	; drop in CRAM
2c9e  23        inc     hl		; next color
2c9f  dd19      add     ix,de		; calc next CRAM pos
2ca1  10f7      djnz    #2c9a           ; loop until b=0
2ca3  c9        ret     

	;; same as above, but all the same color
2ca4  dd7700    ld      (ix+#00),a	; drop in CRAM
2ca7  dd19      add     ix,de		; calc next CRAM pos
2ca9  10f9      djnz    #2ca4           ; loop until b=0
2cab  c9        ret     

	;; message # > 80 (erase prev message?) use 2nd color code
2cac  7e        ld      a,(hl)		; read next char
2cad  fe2f      cp      #2f
2caf  280a      jr      z,#2cbb         ; done with vram
2cb1  dd360040  ld      (ix+#00),#40	; write 40 to vram
2cb5  23        inc     hl		; next char
2cb6  dd19      add     ix,de		; next screen pos
2cb8  04        inc     b		; inc char count
2cb9  18f1      jr      #2cac           ; loop
2cbb  23        inc     hl		; next char
2cbc  04        inc     b		; inc char count
2cbd  edb1      cpir    		; loop until [hl] = 2f
2cbf  18d2      jr      #2c93           ; do CRAM

	;; HACK12 - fixes the C000 top/bottom draw mirror issue
2c62  c300d0	jp	hack12

hack12:   ;;; up at 0xd000 for this example
d000  5e        ld      e, (hl)         ; patch (2c62)
d001  23        inc     hl              ; patch (2c63)
d002  7e        ld      a, (hl)         ; patch (2c64 almost)
d003  e67f      and     #0x7f           ; mask off the top/bottom flag
d005  57        ld      d, a            ; d cleared of that bit now (C000-safe!)
d006  7e        ld      a, (hl)         ; set aside A for part 2, below
d007  c3652c    jp	#2c65		; resume

27f4  cb7f      bit     7, a		; test the full instead of masked now


        ;;
        ;; PROCESS WAVE (all voices) (SOUND)
        ;;
#if MSPACMAN
2cc1  jp      #9797       ; sprite/cocktail stuff. we don't care for sound.
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
2cd7  ld      (#CH1_VOL),a              ;      save volume

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
2d5d  jr      nz,#2d66          ; if (CUR_BIT & E != 0) then goto #ed66
2d5f  ld      (ix+#02),e        ; else save E in CUR_BIT
2d62  jp      #364e             ; and goto #36e4

2d65  inc     c                 ; junk

2d66  dec     (ix+#0c)          ; decrement W_DURATION
2d69  jp      nz,#2dd7          ; if W_DURATION == 0
2d6c  ld      l,(ix+#06)        ; then HL = pointer store in W_OFFSET
2d6f  ld      h,(ix+#07)

        ;; process byte
2d72  ld      a,(hl)            ; A = (HL)
2d73  inc     hl
2d74  ld      (ix+#06),l        ; W_OFFSET = ++HL
2d77  ld      (ix+#07),h
2d7a  cp      #f0               ; if (A < 0xF)
2d7c  jr      c,#2da5           ; then process A  (regular byte)
2d7e  ld      hl,#2d6c          ; else process special byte using a jump table
2d81  push    hl                ;
2d82  and     #0f               ; take lowest nibble of special byte
2d84  rst     #20               ; and jump (return in HL = 2d6c)

        ;; jump table
2d85  55 2f                     ; byte is F0
2d87  65 2f                     ; byte is F1
2d89  77 2f                     ; byte is F2
2d8b  89 2f                     ; byte is F3
2d8d  9b 2f                     ; byte is F4
2d8f  0c 00                     ;
2d91  0c 00                     ;
2d93  0c 00                     ;
2d95  0c 00                     ;
2d97  0c 00                     ;
2d99  0c 00                     ;
2d9b  0c 00                     ;
2d9d  0c 00                     ;
2d9f  0c 00                     ;
2da1  0c 00                     ;
2da3  ad 2f                     ; byte is FF


        ;; process regular byte (A=byte to process, it's not a special byte)
2da5  ld      b,a               ; copy A in B

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
2f02  22 2f 26 2f 2b 2f 3c 2f 43 2f 4a 2f 4b 2f 4c 2f
2f12  4d 2f 4e 2f 4f 2f 50 2f 51 2f 52 2f 53 2f 54 2f

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


2fba  00        nop     
2fbb  00        nop     
2fbc  00        nop     
2fbd  00        nop     
2fbe  00        nop     
2fbf  00        nop     
2fc0  00        nop     
2fc1  00        nop     
2fc2  00        nop     
2fc3  00        nop     
2fc4  00        nop     
2fc5  00        nop     
2fc6  00        nop     
2fc7  00        nop     
2fc8  00        nop     
2fc9  00        nop     
2fca  00        nop     
2fcb  00        nop     
2fcc  00        nop     
2fcd  00        nop     
2fce  00        nop     
2fcf  00        nop     
2fd0  00        nop     
2fd1  00        nop     
2fd2  00        nop     
2fd3  00        nop     
2fd4  00        nop     
2fd5  00        nop     
2fd6  00        nop     
2fd7  00        nop     
2fd8  00        nop     
2fd9  00        nop     
2fda  00        nop     
2fdb  00        nop     
2fdc  00        nop     
2fdd  00        nop     
2fde  00        nop     
2fdf  00        nop     
2fe0  00        nop     
2fe1  00        nop     
2fe2  00        nop     
2fe3  00        nop     
2fe4  00        nop     
2fe5  00        nop     
2fe6  00        nop     
2fe7  00        nop     
2fe8  00        nop     
2fe9  00        nop     
2fea  00        nop     
2feb  00        nop     
2fec  00        nop     
2fed  00        nop     
2fee  00        nop     
2fef  00        nop     
2ff0  00        nop     
2ff1  00        nop     
2ff2  00        nop     
2ff3  00        nop     
2ff4  00        nop     
2ff5  00        nop     
2ff6  00        nop     
2ff7  00        nop     
2ff8  00        nop     
2ff9  00        nop     
2ffa  00        nop     
2ffb  00        nop     
2ffc  00        nop     
2ffd  00        nop     
2ffe  83        add     a,e
2fff  4c        ld      c,h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3000 - 3fff
;; this rom is somehow overlayed from U7 on the aux board.

	;; rst 38 continuation (initalization routine portion)
	;; the rom checksum routine 
3000  210000    ld      hl,#0000
3003  010010    ld      bc,#1000
    ; reclaim a lot of romspace by skipping self test ; HACK4
; 3000  31c04f    ld      sp,#4fc0
; 3003  c3c130    jp      #30c1

3006  32c050    ld      (#50c0),a	; kick the dog
3009  79        ld      a,c		; a=0
300a  86        add     a,(hl)
300b  4f        ld      c,a
300c  7d        ld      a,l
300d  c602      add     a,#02
300f  6f        ld      l,a
3010  fe02      cp      #02
3012  d20930    jp      nc,#3009
3015  24        inc     h
3016  10ee      djnz    #3006           ; (-18)
3018  79        ld      a,c
3019  a7        and     a

301a  00        nop     		;; this is a hack to disregard bad csums
301b  00        nop     		;; this is a hack to disregard bad csums
; PAC
;301a  2015	jr 	nz, #3031	; check for bad checksum

301c  320750    ld      (#5007),a	; clear coin
301f  7c        ld      a,h
3020  fe30      cp      #30
3022  c20330    jp      nz,#3003	; continue for other roms
3025  2600      ld      h,#00
3027  2c        inc     l
3028  7d        ld      a,l
3029  fe02      cp      #02
302b  da0330    jp      c,#3003
302e  c34230    jp      #3042

		;; bad rom checksum  (never called, due to above patch)
3031  25        dec     h
3032  7c        ld      a,h
3033  e6f0      and     #f0
3035  320750    ld      (#5007),a	; clear coin
3038  0f        rrca    
3039  0f        rrca    
303a  0f        rrca    
303b  0f        rrca    
303c  5f        ld      e,a		; failed rom -> e
303d  0600      ld      b,#00
303f  c3bd30    jp      #30bd

		;; RAM TEST (4c00)
3042  315431    ld      sp,#3154
3045  06ff      ld      b,#ff
3047  e1        pop     hl		; 4c00 (first time)
3048  d1        pop     de		; 040f (first time)
3049  48        ld      c,b		; 0xff -> c

		;; write stuff to ram
304a  32c050    ld      (#50c0),a	; kick the dog
304d  79        ld      a,c		; 0xff -> a
304e  a3        and     e		; e -> a
304f  77        ld      (hl),a
3050  c633      add     a,#33
3052  4f        ld      c,a
3053  2c        inc     l
3054  7d        ld      a,l
3055  e60f      and     #0f
3057  c24d30    jp      nz,#304d
305a  79        ld      a,c
305b  87        add     a,a
305c  87        add     a,a
305d  81        add     a,c
305e  c631      add     a,#31
3060  4f        ld      c,a
3061  7d        ld      a,l
3062  a7        and     a
3063  c24d30    jp      nz,#304d
3066  24        inc     h
3067  15        dec     d
3068  c24a30    jp      nz,#304a
306b  3b        dec     sp
306c  3b        dec     sp
306d  3b        dec     sp
306e  3b        dec     sp
306f  e1        pop     hl
3070  d1        pop     de		; 4c00
3071  48        ld      c,b		; 040f

		;; check ram again
3072  32c050    ld      (#50c0),a	; kick the dog
3075  79        ld      a,c
3076  a3        and     e
3077  4f        ld      c,a
3078  7e        ld      a,(hl)
3079  a3        and     e
307a  b9        cp      c
307b  c2b530    jp      nz,#30b5	; ram test failed
307e  c633      add     a,#33
3080  4f        ld      c,a
3081  2c        inc     l
3082  7d        ld      a,l
3083  e60f      and     #0f
3085  c27530    jp      nz,#3075
3088  79        ld      a,c
3089  87        add     a,a
308a  87        add     a,a
308b  81        add     a,c
308c  c631      add     a,#31
308e  4f        ld      c,a
308f  7d        ld      a,l
3090  a7        and     a
3091  c27530    jp      nz,#3075
3094  24        inc     h
3095  15        dec     d
3096  c27230    jp      nz,#3072
3099  3b        dec     sp
309a  3b        dec     sp
309b  3b        dec     sp
309c  3b        dec     sp
309d  78        ld      a,b
309e  d610      sub     #10
30a0  47        ld      b,a
30a1  10a4      djnz    #3047           ; (-92)


30a3  f1        pop     af		; 4c00
30a4  d1        pop     de
30a5  fe44      cp      #44
30a7  c24530    jp      nz,#3045	; check if 0x44xx done
30aa  7b        ld      a,e
30ab  eef0      xor     #f0
30ad  c24530    jp      nz,#3045	; check if totally done
30b0  0601      ld      b,#01
30b2  c3bd30    jp      #30bd


	;; display bad ram
30b5  7b        ld      a,e
30b6  e601      and     #01
30b8  ee01      xor     #01
30ba  5f        ld      e,a
30bb  0600      ld      b,#00

	;; display bad rom
30bd  31c04f    ld      sp,#4fc0
30c0  d9        exx     		; swap register pairs


	;; clear all program ram
30c1  21004c    ld      hl,#4c00
30c4  0604      ld      b,#04
30c6  32c050    ld      (#50c0),a	; kick the dog
30c9  3600      ld      (hl),#00
30cb  2c        inc     l
30cc  20fb      jr      nz,#30c9        ; (-5)
30ce  24        inc     h
30cf  10f5      djnz    #30c6           ; (-11)

	;; set all video ram to 0x40 - clear screen
30d1  210040    ld      hl,#4000
30d4  0604      ld      b,#04
30d6  32c050    ld      (#50c0),a	; kick the dog
30d9  3e40      ld      a,#40
30db  77        ld      (hl),a
30dc  2c        inc     l
30dd  20fc      jr      nz,#30db        ; (-4)
30df  24        inc     h
30e0  10f4      djnz    #30d6           ; (-12)

	;; set all color ram to 0x0f
30e2  0604      ld      b,#04
30e4  32c050    ld      (#50c0),a	; kick the dog
30e7  3e0f      ld      a,#0f
30e9  77        ld      (hl),a
30ea  2c        inc     l
30eb  20fc      jr      nz,#30e9        ; (-4)
30ed  24        inc     h
30ee  10f4      djnz    #30e4           ; (-12)


;; change 30f0 - 30f2 to "00 nop" to skip checksum check. ; HACK4
;;  if you do that, 30fb - 3173 can be reclaimed for other code use.
;30f0  00	nop
;30f1  00	nop
;30f2  00	nop

30f0  d9        exx     		; reswap register pairs
30f1  1008      djnz    #30fb           ; (8) b=1 -> no errors

30f3  0623      ld      b,#23
    ; eliminate startup tests ; HACK7
;30f5  00	nop
;30f6  00	nop
;30f7  00	nop
30f5  cd5e2c    call    #2c5e		; print MEMORY OK
30f8  c37431    jp      #3174		; run the game!

; skip the checksum test, change 30fb to: ; HACK 0
; 30fb  c37431    jp      #3174		; run the game!
30fb  7b        ld      a,e		; bad rom # => a
30fc  c630      add     a,#30

30fe  328441    ld      (#4184),a	; write to screen
3101  c5        push    bc		; ff0f
3102  e5        push    hl		; 4c00
3103  0624      ld      b,#24		; "BAD R M"
3105  cd5e2c    call    #2c5e		; print 
3108  e1        pop     hl
3109  7c        ld      a,h
310a  fe40      cp      #40
310c  2a6c31    ld      hl,(#316c)
310f  3811      jr      c,#3122         ; (17)
3111  fe4c      cp      #4c
3113  2a6e31    ld      hl,(#316e)
3116  300a      jr      nc,#3122        ; (10)
3118  fe44      cp      #44
311a  2a7031    ld      hl,(#3170)
311d  3803      jr      c,#3122         ; (3)
311f  2a7231    ld      hl,(#3172)
3122  7d        ld      a,l
3123  320442    ld      (#4204),a
3126  7c        ld      a,h
3127  326442    ld      (#4264),a

	; check player 1
312a  3a0050    ld      a,(#5000)	;; in0
312d  47        ld      b,a

	; check player 2
312e  3a4050    ld      a,(#5040)	;; in1
3131  b0        or      b		; check for both sticks up?
3132  e601      and     #01
3134  2011      jr      nz,#3147        ; (17)
3136  c1        pop     bc
3137  79        ld      a,c
3138  e60f      and     #0f
313a  47        ld      b,a
313b  79        ld      a,c
313c  e6f0      and     #f0
313e  0f        rrca    
313f  0f        rrca    
3140  0f        rrca    
3141  0f        rrca    
3142  4f        ld      c,a
3143  ed438541  ld      (#4185),bc

3147  32c050    ld      (#50c0),a	; kick the dog
314a  3a4050    ld      a,(#5040)	;; check in1
314d  e610      and     #10
314f  28f6      jr      z,#3147         ; (-10)
3151  c30b23    jp      #230b

	; ram test data
3154  00 4c 0f 04	; work ram low nibble
3158  00 4c f0 04	; work ram high nibble
315c  00 40 0f 04	; video ram low nibble
3160  00 40 f0 04	; video ram high nibble
3164  00 44 0f 04	; color ram low nibble
3168  00 44 f0 04	; color ram high nibble

	; data sed in the error routine for printing
	; BAD (W/V/CRAM, ROM)
316c  4f 40 41 57 41 56 41 43


	;; start the main section... (tests first)
3174  210650    ld      hl,#5006
3177  3e01      ld      a,#01
3179  77        ld      (hl),a		; enable all
317a  2d        dec     l
317b  20fc      jr      nz,#3179        ; (-4)
317d  af        xor     a		; 0x00->a
317e  320350    ld      (#5003),a	; unflip screen
3181  d604      sub     #04		; 0xfc->a
3183  ed47      ld      i,a		; set vector
	; pac:
;3183  d300      out     (#00),a         ; set vector TO $8D WHEN INTERUPT

3185  31c04f    ld      sp,#4fc0
3188  32c050    ld      (#50c0),a	; kick the dog
318b  af        xor     a		; 0x00->a

    ; Skip test mode: HACK7
;318c  31c04f    ld      sp,#4fc0
;318f  c39032    jp      #3290		; skip over the test mode

318c  32004e    ld      (#4e00),a	; set service mode
318f  3c        inc     a		; 0x01->a

3190  32014e    ld      (#4e01),a
3193  320050    ld      (#5000),a	; enable interrupts
3196  fb        ei     		 	; enable interrupts

	;; test mode sound checks
	;; this gets called if the test switch is on at bootup
3197  3a0050    ld      a,(#5000)
319a  2f        cpl     
319b  47        ld      b,a
319c  e6e0      and     #e0		; check coin/credit inputs
319e  2805      jr      z,#31a5         ; (5)
31a0  3e02      ld      a,#02		; SOUND: pellet eat
31a2  329c4e    ld      (#4e9c),a	; choose sound 2

31a5  3a4050    ld      a,(#5040)	;; check in1
31a8  2f        cpl     
31a9  4f        ld      c,a
31aa  e660      and     #60		; check p1/p2 start
31ac  2805      jr      z,#31b3         ; (5)
31ae  3e01      ld      a,#01		; SOUND: extra base
31b0  329c4e    ld      (#4e9c),a	; choose sound 1

31b3  78        ld      a,b
31b4  b1        or      c
31b5  e601      and     #01		; check up
31b7  2805      jr      z,#31be         ; (5)
31b9  3e08      ld      a,#08		; SOUND: fruit eat
31bb  32bc4e    ld      (#4ebc),a	; choose sound 8

31be  78        ld      a,b
31bf  b1        or      c
31c0  e602      and     #02		; check left
31c2  2805      jr      z,#31c9         ; (5)
31c4  3e04      ld      a,#04		; SOUND: Pellet eat
31c6  32bc4e    ld      (#4ebc),a	; choose sound 4

31c9  78        ld      a,b
31ca  b1        or      c
31cb  e604      and     #04		; check right
31cd  2805      jr      z,#31d4         ; (5)
31cf  3e10      ld      a,#10		; SOUND: death
31d1  32bc4e    ld      (#4ebc),a	; choose sound 16

31d4  78        ld      a,b
31d5  b1        or      c
31d6  e608      and     #08		; check down
31d8  2805      jr      z,#31df         ; (5)
31da  3e20      ld      a,#20		; SOUND: bassy noise
31dc  32bc4e    ld      (#4ebc),a	; choose sound 32

31df  3a8050    ld      a,(#5080)	; read dips
31e2  e603      and     #03		; mask coin info
31e4  c625      add     a,#25
31e6  47        ld      b,a
31e7  cd5e2c    call    #2c5e		; print FREE PLAY

31ea  3a8050    ld      a,(#5080)	;; read dips
31ed  0f        rrca    
31ee  0f        rrca    
31ef  0f        rrca    
31f0  0f        rrca    
31f1  e603      and     #03		; mask extras
31f3  fe03      cp      #03
31f5  2008      jr      nz,#31ff        ; (8)
31f7  062a      ld      b,#2a		; "BONUS NONE"
31f9  cd5e2c    call    #2c5e		; print
31fc  c31c32    jp      #321c
31ff  07        rlca    
3200  5f        ld      e,a
3201  d5        push    de
3202  062b      ld      b,#2b		; "BONUS"
3204  cd5e2c    call    #2c5e		; print
3207  062e      ld      b,#2e		; "000"
3209  cd5e2c    call    #2c5e		; print
320c  d1        pop     de
320d  1600      ld      d,#00
320f  21f932    ld      hl,#32f9
3212  19        add     hl,de
3213  7e        ld      a,(hl)
3214  322a42    ld      (#422a),a
3217  23        inc     hl
3218  7e        ld      a,(hl)
3219  324a42    ld      (#424a),a
321c  3a8050    ld      a,(#5080)	;; check in0
321f  0f        rrca    
3220  0f        rrca    
3221  e603      and     #03
3223  c631      add     a,#31
3225  fe34      cp      #34
3227  2001      jr      nz,#322a        ; (1)
3229  3c        inc     a
322a  32ac41    ld      (#41ac),a
	; pac:
;322a  320c42    ld      (#420c),a
322d  0629      ld      b,#29		; "MS. PAC-MEN"
322f  cd5e2c    call    #2c5e		; print
3232  3a4050    ld      a,(#5040)	;; check dips
3235  07        rlca    
3236  e601      and     #01		; upright or cocktail
3238  c62c      add     a,#2c
323a  47        ld      b,a		; "TABLE"/"UPRIGHT"
323b  cd5e2c    call    #2c5e		; print 
323e  3a4050    ld      a,(#5040)	;; check in1
3241  e610      and     #10
3243  ca8831    jp      z,#3188
3246  af        xor     a
3247  320050    ld      (#5000),a
324a  f3        di      		; disable interrupts
324b  210750    ld      hl,#5007
324e  af        xor     a
324f  77        ld      (hl),a
3250  2d        dec     l
3251  20fc      jr      nz,#324f        ; (-4)

    ; eliminate just the test grid: HACK7 (alternate)
;3253  31c04f    ld      sp,#4fc0
;3262  c38632    jp      #3286


	; preload the stack with some data for the grid test
	; prep for the test grid
3253  31e23a    ld      sp,#3ae2
3256  0603      ld      b,#03
3258  d9        exx     
3259  e1        pop     hl		; $3ae2 goes into HL
325a  d1        pop     de		; $3ae2-2 into de
325b  32c050    ld      (#50c0),a	; kick the dog
325e  c1        pop     bc		; $3ae2-4 into bc?

	;; draw the test grid to the screen
325f  3e3c      ld      a,#3c		; upper right
3261  77        ld      (hl),a
3262  23        inc     hl
3263  72        ld      (hl),d		; lower right
3264  23        inc     hl
3265  10f8      djnz    #325f           ; (-8)
3267  3b        dec     sp
3268  3b        dec     sp
3269  c1        pop     bc
326a  71        ld      (hl),c		; upper right
326b  23        inc     hl
326c  3e3f      ld      a,#3f		; lower left
326e  77        ld      (hl),a
326f  23        inc     hl
3270  10f8      djnz    #326a           ; (-8)
3272  3b        dec     sp
3273  3b        dec     sp
3274  1d        dec     e
3275  c25b32    jp      nz,#325b
3278  f1        pop     af
3279  d9        exx     
327a  10dc      djnz    #3258           ; (-36)
327c  31c04f    ld      sp,#4fc0

327f  0608      ld      b,#08		; delay for 8 times
3281  cded32    call    #32ed		; call the delay routine
3284  10fb      djnz    #3281           ; decrement B, delay again if B not 0

	;; loop until service switch turned off.
3286  32c050    ld      (#50c0),a	; kick the dog
3289  3a4050    ld      a,(#5040)	;; check in1
328c  e610      and     #10		; check service switch
328e  28f6      jr      z,#3286         ; (-10) loop until test switch is off

    ;; check the condition to display the easter egg
;	This piece of code is found in the original Midway
;	Pac-Man ROMs @ $3289. Place the game in the test grid
;	screen (Monitor Convergence screen) by switching test
;	mode on then quickly jiggling the test switch out &
;	back into test. Next move the joystick:
;	    Up 4 times 
;	    Left 4 times 
;	    Right 4 times 
;	    Down 4 times
;				- Widel/Mowerman
3290  3a4050    ld      a,(#5040)	;; check in1
3293  e660      and     #60
3295  c24b23    jp      nz,#234b	; main
3298  0608      ld      b,#08
329a  cded32    call    #32ed
329d  10fb      djnz    #329a           ; (-5)
329f  3a4050    ld      a,(#5040)	;; check in1
32a2  e610      and     #10
32a4  c24b23    jp      nz,#234b	; main
32a7  1e01      ld      e,#01
32a9  0604      ld      b,#04
32ab  32c050    ld      (#50c0),a	; kick the dog
32ae  cded32    call    #32ed
32b1  3a0050    ld      a,(#5000)
32b4  a3        and     e
32b5  20f4      jr      nz,#32ab        ; (-12)
32b7  cded32    call    #32ed
32ba  32c050    ld      (#50c0),a	; kick the dog
32bd  3a0050    ld      a,(#5000)	; IN0
32c0  eeff      xor     #ff
32c2  20f3      jr      nz,#32b7        ; (-13)
32c4  10e5      djnz    #32ab           ; (-27)
32c6  cb03      rlc     e
32c8  7b        ld      a,e
32c9  fe10      cp      #10
32cb  daa932    jp      c,#32a9

	;; draw the "Made By Namco" easter egg
	; clear the screen...
32ce  210040    ld      hl,#4000
32d1  0604      ld      b,#04
32d3  3e40      ld      a,#40
32d5  77        ld      (hl),a
32d6  2c        inc     l
32d7  20fc      jr      nz,#32d5        ; (-4)
32d9  24        inc     h
32da  10f7      djnz    #32d3           ; (-9)
	; draw the egg to the screen
32dc  cdf43a    call    #3af4

	; wait for service switch to be off
32df  32c050    ld      (#50c0),a	; kick the dog
32e2  3a4050    ld      a,(#5040)	;; check in1
32e5  e610      and     #10		; service
32e7  cadf32    jp      z,#32df		
32ea  c34b23    jp      #234b		; main program run

	; delay timer
32ed  32c050    ld      (#50c0),a	; kick the dog
32f0  210028    ld      hl,#2800
32f3  2b        dec     hl
32f4  7c        ld      a,h
32f5  b5        or      l
32f6  20fb      jr      nz,#32f3        ; (-5)
32f8  c9        ret     

	; data - bonus table
32f9  30 31	; 10
32fb  35 31	; 15
32fd  30 32	; 20

	; data - tile differences tables for movements
32ff  00 ff	; move right
3301  01 00	; move down
3303  00 01	; move left
3305  ff 00	; move up
	; second copy for speed
3307  00 ff	; move right
3309  01 00	; move down
330b  00 01	; move left
330d  ff 00	; move up

	; data - table for difficulty
	; 	each entry has 3 sections
	;	0: 0x10 bytes - movement bit patterns
	;	1: 0x0c bytes - ghost data movement bit patterns
	;	2: 0x0e bytes - ghost counters for orientation changes
	;			4dc1-4dc3 related

330f 2A552A55 55555555 2A552A55 4A5294A5
     25252525 22222222 01010101
     0258 0708 0960 0E10 1068 1770 1914

3339 4A5294A5 2AAA5555 2A552A55 4A5294A5
     24924925 24489122 01010101
     0000 0000 0000 0000 0000 0000 0000

3363 2A552A55 55555555 2AAA5555 2A552A55
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

338d  55 55 55 55	;; $338d - 3390 = Pacman normal speed for Board 1
3391  d5 6a d5 6a	;; $3391 - 3394 = Pacman Blue speed for Board 1
3395  aa 6a 55 d5	;; $3395 - 3398 = 2nd alternate speed for red ghost
3399  55 55 55 55	;; $3399 - 339c = 1st alt. speed for red ghost
339d  aa 2a 55 55	;; $339d - 33a0 = Ghost normal speed for board 1
33a1  92 24 92 24	;; $33a1 - 33a4 = Ghost blue speed for board 1
33a5  22 22 22 22	;; $33a5 - 33a8 = Ghost tunnel speed for board 1

33a9  a4 01 54 06	;; $33a9 - 33b6 = unknown 
33ad  f8 07 a8 0c 	;; ( made changes to this section but noticed
33b1  d4 0d 84 12	;;                no difference in game play)
33b5  b0 13

33b7  d5 6a d5 6a	;; $33b7 - 33ba = Pacman normal speed for Boards 2-4
33bb  d6 5a ad b5	;; $33bb - 33be = Pacman blue speed for boards 2-4
33bf  d6 5a ad b5	;; $33bf - 33c6 = ?? (possible alt. speed for red ghost)
33c3  d5 6a d5 6a 
33c7  aa 6a 55 d5	;; $33c7 - 33ca = Ghost reg speed for boards 2-4
33cb  92 24 25 49 	;; $33cb - 33ce = Ghost blue speed for boards 2-4

; resume in the middle of original pac, in entry 4. see above.
	; entry 4, 5, etc is here.

; orignal pac rom:
; data - level map information
3435:                40 FC D0-D2 D2 D2 D2 D2 D2 D2 D2      @..........
3440: D4 FC FC FC DA 02 DC FC-FC FC D0 D2 D2 D2 D2 D6 ................
3450: D8 D2 D2 D2 D2 D4 FC DA-09 DC FC FC FC DA 02 DC ................
3460: FC FC FC DA 05 DE E4 05-DC FC DA 02 E6 E8 EA 02 ................
3470: E6 EA 02 DC FC FC FC DA-02 DC FC FC FC DA 02 E6 ................
3480: EA 02 E7 EB 02 E6 EA 02-DC FC DA 02 DE FC E4 02 ................
3490: DE E4 02 DC FC FC FC DA-02 DC FC FC FC DA 02 DE ................
34A0: E4 05 DE E4 02 DC FC DA-02 DE FC E4 02 DE E4 02 ................
34B0: DC FC FC FC DA 02 DC FC-FC FC DA 02 DE F2 E8 E8 ................
34C0: EA 02 DE E4 02 DC FC DA-02 E7 E9 EB 02 E7 EB 02 ................
34D0: E7 D2 D2 D2 EB 02 E7 D2-D2 D2 EB 02 E7 E9 E9 E9 ................
34E0: EB 02 DE E4 02 DC FC DA-1B DE E4 02 DC FC DA 02 ................
34F0: E6 E8 F8 02 F6 E8 E8 E8-E8 E8 E8 F8 02 F6 E8 E8 ................
3500: E8 EA 02 E6 F8 02 F6 E8-E8 F4 E4 02 DC FC DA 02 ................
3510: DE FC E4 02 F7 E9 E9 F5-F3 E9 E9 F9 02 F7 E9 E9 ................
3520: E9 EB 02 DE E4 02 F7 E9-E9 F5 E4 02 DC FC DA 02 ................
3530: DE FC E4 05 DE E4 0B DE-E4 05 DE E4 02 DC FC DA ................
3540: 02 DE FC E4 02 E6 EA 02-DE E4 02 EC D3 D3 D3 EE ................
3550: 02 E6 EA 02 DE E4 02 E6-EA 02 DE E4 02 DC FC DA ................
3560: 02 E7 E9 EB 02 DE E4 02-E7 EB 02 DC FC FC FC DA ................
3570: 02 DE E4 02 E7 EB 02 DE-E4 02 E7 EB 02 DC FC DA ................
3580: 06 DE E4 05 F0 FC FC FC-DA 02 DE E4 05 DE E4 05 ................
3590: DC FC FA E8 E8 E8 EA 02-DE F2 E8 E8 EA 02 CE FC ................
35A0: FC FC DA 02 DE F2 E8 E8-EA 02 DE F2 E8 E8 EA 02 ................
35B0: DC 00 00 00 00

; original pac rom:
; data - level pill information
35B5:                62 01 02-01 01 01 01 0C 01 01 04      b..........
35C0: 01 01 01 04 04 03 0C 03-03 03 04 04 03 0C 03 01 ................
35D0: 01 01 03 04 04 03 0C 06-03 04 04 03 0C 06 03 04 ................
35E0: 01 01 01 01 01 01 01 01-01 01 01 01 01 01 01 01 ................
35F0: 01 01 01 01 01 01 01 01-01 03 04 04 0F 03 06 04 ................
3600: 04 0F 03 06 04 04 01 01-01 0C 03 01 01 01 03 04 ................
3610: 04 03 0C 03 03 03 04 04-03 0C 03 03 03 04 01 01 ................
3620: 01 01 03 0C 01 01 01 03-01 01 01 08 18 08 18 04 ................
3630: 01 01 01 01 03 0C 01 01-01 03 01 01 01 04 04 03 ................
3640: 0C 03 03 03 04 04 03 0C-03 03 03 04 04 01 01 01 ................
3650: 0C 03 01 01 01 03 04 04-0F 03 06 04 04 0F 03 06 ................
3660: 04 01 01 01 01 01 01 01-01 01 01 01 01 01 01 01 ................
3670: 01 01 01 01 01 01 01 01-01 01 03 04 04 03 0C 06 ................
3680: 03 04 04 03 0C 06 03 04-04 03 0C 03 01 01 01 03 ................
3690: 04 04 03 0C 03 03 03 04-01 02 01 01 01 01 0C 01 ................
36A0: 01 04 01 01 01                                  ......


; PAC - the following resumes MsPac
;  the whole section from 0x3435-0x36a2 differs from Pac roms.
	;; Maze information...  0x3436  (it is for pac-man...)
3435  3a004f    ld      a,(#4f00)
3438  fe01      cp      #01
343a  ca9c34    jp      z,#349c
343d  ef        rst     #28
343e  1c32
3440  3e01      ld      a,#01
3442  32ac42    ld      (#42ac),a
3445  3e16      ld      a,#16
3447  32ac46    ld      (#46ac),a
344a  0e00      ld      c,#00
344c  c39c34    jp      #349c
344f  3a004f    ld      a,(#4f00)
3452  fe01      cp      #01
3454  ca9c34    jp      z,#349c
3457  ef        rst     #28
3458  1c17
345a  3e02      ld      a,#02
345c  32ac42    ld      (#42ac),a
345f  3e16      ld      a,#16
3461  32ac46    ld      (#46ac),a
3464  0e0c      ld      c,#0c
3466  c39c34    jp      #349c
3469  3a004f    ld      a,(#4f00)
346c  fe01      cp      #01
346e  ca9c34    jp      z,#349c
3471  ef        rst     #28
3472  1c15
3474  3e03      ld      a,#03
3476  32ac42    ld      (#42ac),a
3479  3e16      ld      a,#16
347b  32ac46    ld      (#46ac),a
347e  0e18      ld      c,#18
3480  c39c34    jp      #349c
3483  0e24      ld      c,#24
3485  c39c34    jp      #349c
3488  0e30      ld      c,#30
348a  c39c34    jp      #349c
348d  0e3c      ld      c,#3c
348f  c39c34    jp      #349c
3492  0e48      ld      c,#48
3494  c39c34    jp      #349c
3497  0e54      ld      c,#54
3499  c39c34    jp      #349c
349c  3a004f    ld      a,(#4f00)
349f  a7        and     a
34a0  cc1136    call    z,#3611
34a3  0606      ld      b,#06
34a5  dd210c4f  ld      ix,#4f0c
34a9  dd6e00    ld      l,(ix+#00)
34ac  dd6601    ld      h,(ix+#01)
34af  7e        ld      a,(hl)
34b0  fef0      cp      #f0
34b2  cade34    jp      z,#34de
34b5  fef1      cp      #f1
34b7  ca6b35    jp      z,#356b
34ba  fef2      cp      #f2
34bc  ca9735    jp      z,#3597
34bf  fef3      cp      #f3
34c1  ca7735    jp      z,#3577
34c4  fef5      cp      #f5
34c6  ca0736    jp      z,#3607
34c9  fef6      cp      #f6
34cb  caa435    jp      z,#35a4
34ce  fef7      cp      #f7
34d0  caf335    jp      z,#35f3
34d3  fef8      cp      #f8
34d5  cafd35    jp      z,#35fd
34d8  feff      cp      #ff
34da  cacb35    jp      z,#35cb
34dd  76        halt    
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
3518  df        rst     #18
3519  79        ld      a,c
351a  cb2f      sra     a
351c  d7        rst     #10		; dereference sprite number for intro
351d  feff      cp      #ff
351f  c22635    jp      nz,#3526
3522  0e00      ld      c,#00
3524  18ef      jr      #3515           ; (-17)
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
3563  f6f0      or      #f0
3565  0c        inc     c
3566  1802      jr      #356a           ; (2)
3568  e60f      and     #0f
356a  c9        ret     

356b  eb        ex      de,hl
356c  cd4136    call    #3641
356f  eb        ex      de,hl
3570  d5        push    de
3571  23        inc     hl
3572  56        ld      d,(hl)
3573  23        inc     hl
3574  5e        ld      e,(hl)
3575  1813      jr      #358a           ; (19)
3577  eb        ex      de,hl
3578  210f4f    ld      hl,#4f0f
357b  78        ld      a,b
357c  d7        rst     #10
357d  3600      ld      (hl),#00
357f  eb        ex      de,hl
3580  113e4f    ld      de,#4f3e
3583  d5        push    de
3584  23        inc     hl
3585  5e        ld      e,(hl)
3586  23        inc     hl
3587  56        ld      d,(hl)
3588  1800      jr      #358a           ; (0)
358a  e1        pop     hl
358b  d5        push    de
358c  df        rst     #18
358d  eb        ex      de,hl
358e  d1        pop     de
358f  72        ld      (hl),d
3590  2b        dec     hl
3591  73        ld      (hl),e
3592  110300    ld      de,#0003
3595  181d      jr      #35b4           ; (29)
3597  23        inc     hl
3598  4e        ld      c,(hl)
3599  21174f    ld      hl,#4f17
359c  78        ld      a,b
359d  d7        rst     #10
359e  71        ld      (hl),c
359f  110200    ld      de,#0002
35a2  1810      jr      #35b4           ; (16)
35a4  21174f    ld      hl,#4f17
35a7  78        ld      a,b
35a8  d7        rst     #10
35a9  3d        dec     a
35aa  77        ld      (hl),a
35ab  110000    ld      de,#0000
35ae  2004      jr      nz,#35b4        ; (4)
35b0  1e01      ld      e,#01
35b2  1800      jr      #35b4           ; (0)


	;; 35b5 overlay for pac-man
35b4  dd6e00    ld      l,(ix+#00)
35b7  dd6601    ld      h,(ix+#01)
35ba  19        add     hl,de
35bb  dd7500    ld      (ix+#00),l
35be  dd7401    ld      (ix+#01),h
35c1  dd2b      dec     ix
35c3  dd2b      dec     ix
35c5  1001      djnz    #35c8           ; (1)
35c7  c9        ret     

35c8  c3a934    jp      #34a9
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
35e5  3a024e    ld      a,(#4e02)
35e8  a7        and     a
35e9  ca9521    jp      z,#2195
35ec  af        xor     a
35ed  32004f    ld      (#4f00),a
35f0  c38e05    jp      #058e
35f3  78        ld      a,b
35f4  ef        rst     #28
35f5  1c30
35f6  47        ld      b,a
35f8  110100    ld      de,#0001
35fb  18b7      jr      #35b4           ; (-73)
35fd  3e40      ld      a,#40
35ff  32ac42    ld      (#42ac),a
3602  110100    ld      de,#0001
3605  18ad      jr      #35b4           ; (-83)
3607  23        inc     hl
3608  7e        ld      a,(hl)
3609  32bc4e    ld      (#4ebc),a
360c  110200    ld      de,#0002
360f  18a3      jr      #35b4           ; (-93)
3611  3a024e    ld      a,(#4e02)
3614  a7        and     a
3615  2008      jr      nz,#361f        ; (8)
3617  3e02      ld      a,#02
3619  32cc4e    ld      (#4ecc),a
361c  32dc4e    ld      (#4edc),a
361f  21f081    ld      hl,#81f0	; map table?
3622  0600      ld      b,#00
3624  09        add     hl,bc
3625  11024f    ld      de,#4f02
3628  010c00    ld      bc,#000c
362b  edb0      ldir    
362d  3e01      ld      a,#01
362f  32004f    ld      (#4f00),a
3632  32a44d    ld      (#4da4),a
3635  211f4f    ld      hl,#4f1f
3638  3e00      ld      a,#00
363a  32a54d    ld      (#4da5),a
363d  0614      ld      b,#14
363f  cf        rst     #8
3640  c9        ret     

3641  78        ld      a,b
3642  fe06      cp      #06
3644  2004      jr      nz,#364a        ; (4)
3646  21c64d    ld      hl,#4dc6
3649  c9        ret     

364a  21fe4c    ld      hl,#4cfe
364d  c9        ret     

        ;; select song
364e  dec     b                 ; B = current bit of song being played (from loop in 2d50)
364f  push    bc                ; adapt B to the current level to find out the song number
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
3668  ld      b,#03             ; now B is adapted, and hold the song number
366a  rst     #18               ; HL = (HL+2B)  [read from table in HL, i.e. SONG_TABLE_x]
366b  pop     bc
366c  jp      #2d72             ; jump to "process byte" routine





366f  cb77      bit     6,a
3671  ca6620    jp      z,#2066
3674  3e01      ld      a,#01
3676  02        ld      (bc),a
3677  c9        ret     

3678  210000    ld      hl,#0000
367b  22d24d    ld      (#4dd2),hl
367e  c9        ret     

367f  3a084d    ld      a,(#4d08)
3682  e60f      and     #0f
3684  cb3f      srl     a
3686  cb3f      srl     a
3688  2f        cpl     
3689  1e1c      ld      e,#1c
368b  83        add     a,e
368c  fe18      cp      #18
368e  2002      jr      nz,#3692        ; (2)
3690  3e36      ld      a,#36
3692  320a4c    ld      (#4c0a),a	; mspac sprite number
3695  c9        ret     


		;; garbage, leftover from patching pac-man rom.
		;; this is the tail end of the pellet table. heh.
3696  03        inc     bc
3697  04        inc     b
3698  010201    ld      bc,#0102
369b  010101    ld      bc,#0101
369e  0c        inc     c
369f  010104    ld      bc,#0401
36a2  010101    ld      bc,#0101


        ;; Indirect Lookup table for 2c5e routine  (0x48 entries) 
	;; not entirely sure how these work yet.
	;; the comments on the right half refer to pac-man, not ms-pacman
	;; 1337 is the address '3713'
36a5  1337                      ; 00        HIGH SCORE
36a7  2337                      ; 01        CREDIT   
36a9  3237                      ; 02        FREE PLAY
36ab  4137                      ; 03        PLAYER ONE
36ad  5a37                      ; 04        PLAYER TWO
36af  6a37                      ; 05        GAME  OVER
36b1  7a37                      ; 06        READY?
36b3  8637                      ; 07        PUSH START BUTTON
36b5  9d37                      ; 08        1 PLAYER ONLY 
36b7  b137                      ; 09        1 OR 2 PLAYERS
36b9  213d                      ; 0a        
36bb  003d                      ; 0b        ADDITIONAL  AT   000
36bd  fd37                      ; 0c        "MS PAC-MAN"
36bf  673d                      ; 0d        "BLINKY"
36c1  e33d                      ; 0e        WITH
36c3  863d                      ; 0f        "PINKY"  
36c5  023e                      ; 10        STARRING
36c7  4c38                      ; 11        . 10 Pts
36c9  5a38                      ; 12        o 50 Pts
36cb  3c3d                      ; 13        @ MIDWAY MFG.CO.
36cd  573d                      ; 14        "MAD DOG"
36cf  d33d                      ; 15        JUNIOR
36d1  763d                      ; 16        "KILLER"
36d3  f23d                      ; 17        THE CHASE
36d5  0100                      ; 18 	    - unused -
36d7  0200                      ; 19	    - unused -
36d9  0300                      ; 1a	    - unused -
36db  bc38                      ; 1b        100
36dd  c438                      ; 1c        SUPER PAC-MAN
36df  ce38                      ; 1d        MAN
36e1  d838                      ; 1e        AN
36e3  e238                      ; 1f        - ? -
36e5  ec38                      ; 20        - ? -
36e7  f638                      ; 21        - ? -
36e9  0039                      ; 22        - ? -
36eb  0a39                      ; 23        MEMORY  OK
36ed  1a39                      ; 24        BAD    R M
36ef  6f39                      ; 25        FREE  PLAY       
36f1  2a39                      ; 26        1 COIN  1 CREDIT 
36f3  5839                      ; 27        1 COIN  2 CREDITS
36f5  4139                      ; 28        2 COINS 1 CREDIT 
36f7  113e                      ; 29        MS. PAC-MEN	(test screen)
36f8  8639                      ; 2a        BONUS  NONE
36fb  9739                      ; 2b        BONUS
36fd  b039                      ; 2c        TABLE  
36ff  bd39                      ; 2d        UPRIGHT
3701  ca39                      ; 2e        000
3703  a53d                      ; 2f        "INKY"    
3705  213e                      ; 30        "        "
3707  c63d                      ; 31        "SUE"  
3709  403e                      ; 32        THEY MEET
370b  953d                      ; 33        MS. PAC-MAN  (For "Starring" bit)
370d  113e                      ; 34        MS. PAC-MEN	 (?? screen)
370f  b43d                      ; 35        1980,1981
3711  303e                      ; 36        ACT III

	;; there's another one of these for the text over at 3D00

	;; text strings 1
 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f    0123456789abcdef

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
000038d0  4d 41 4e 2f 89 2f 80 4d  41 4e 2f 89 2f 80 2f 90  |MAN/./.MAN/././.|
000038e0  00 00[2e 80 86 8b 8d 8e  2f 8f 2f 90[30 80 40 40  |.......././.0.@@|
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



	;; "Made By Namco" easter egg text

; This is stored the same way as the pellet information.
;  #3af4 routine:
;  1  retrieve the value
;  2  if (value == 0), done.
;  3  draw a pellet (#14)
;  4  increment the position by the value retrieved
;  5  repeat at 1 above

 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f    0123456789abcdef
	; namco
00003a40                                                01  |               .|
00003a50  01 03 01 01 01 03 02 02  02 01 01 01 01 02 04 04  |................|
00003a60  04 06 02 02 02 02 04 02  04 04 04 06 02 02 02 02  |................|
00003a70  01 01 01 01 02 04 04 04  06 02 02 02 02 06 04 05  |................|
00003a80  01 01 03 01 01 01 04 01  01 01 03 01 01 04 01 01  |................|
00003a90  01                                                |.               |
	; by
00003a90     6c 05 01 01 01 18 04  04 18 05 01 01 01 17 02  | l..............|
00003aa0  03 04 16 04 03 01 01 01                           |........        |
	; made
00003aa0                           76 01 01 01 01 03 01 01  |        v.......|
00003ab0  01 02 04 02 04 0e 02 04  02 04 02 04 0b 01 01 01  |................|
00003ac0  02 04 02 01 01 01 01 02  02 02 0e 02 04 02 04 02  |................|
00003ad0  01 02 01 0a 01 01 01 01  03 01 01 01 03 01 01 03  |................|
00003ae0  04 00                                             |..              |


	; data - 3 screen region grid data for self test
3AE2:   4002 3E01 103D
        4040 3D0E 103E
        43C2 3E01 103D

	; Draw the "Made By Namco" text (egg)
3af4  21a240    ld      hl,#40a2	; video ram start position
3af7  114f3a    ld      de,#3a4f	; pellet data start

3afa  3614      ld      (hl),#14	; set the screen to pellet (14)
3afc  1a        ld      a,(de)		; a = value to use
3afd  a7        and     a		; bit test
3afe  c8        ret     z		; if 0, we're done...

3aff  13        inc     de		; get the next pellet
3b00  85        add     a,l
3b01  6f        ld      l,a
3b02  d2fa3a    jp      nc,#3afa	; next byte if some condition
3b05  24        inc     h
3b06  18f2      jr      #3afa           ; (-14)

	; data - fruit data for levels 0..7
3B08:   90 14   ; cherry
        94 0F   ; strawberry
        98 15   ; 1st orange
        98 15   ; 2nd orange
        
        A0 14   ; 1st apple
        A0 14   ; 2nd apple
        
3B14:   A4 17   ; 1st pineapple
        A4 17   ; 2nd pineapple

        A8 09   ; 1st galaxian
        A8 09   ; 2nd galaxian
        9C 16   ; 1st bell
        9C 16   ; 2nd bell

        AC 16   ; 1st key

        AC 16   ; 2nd key
        AC 16   ; 3rd key
        AC 16   ; 4th key

        AC 16   ; 5th key
        AC 16   ; 6th key
        AC 16   ; 7th key
        AC 16   ; 8th key

        ;; 
        ;; PACMAN sound tables
        ;;
        
        ;; channel 1 effects  
3B30 73 20 00 0C 00 0A 1F 00  72 20 FB 87 00 02 0F 00
        
        ;; channel 2 effects
3B40  36 20 04 8C 00 00 06 00  36 28 05 8B 00 00 06 00
3B50  36 30 06 8A 00 00 06 00  36 3C 07 89 00 00 06 00
3B60  36 48 08 88 00 00 06 00  24 00 06 08 00 00 0A 00
3B70  40 70 FA 10 00 00 0A 00  70 04 00 00 00 00 08 00
        
        ;; channel 3 effects
3B80  42 18 FD 06 00 01 0C 00  42 04 03 06 00 01 0C 00
3B90  56 0C FF 8C 00 02 0F 00  05 00 02 20 00 01 0C 00
3BA0  41 20 FF 86 FE 1C 0F FF  70 00 01 0C 00 01 08 00
        
        ;; lookup tables
3BB0  01 02 04 08 10 20 40 80

3BB8  00 57 5C 61 67 6D 74 7B  82 8A 92 9A A3 AD B8 C3
        
        ;; channel 1 : jump table to song data
3BC8  D4 3B F3 3B
        
        ;; channel 2 : jump table to song data
3BCC  58 3C 95 3C
        
        ;; channel 3 : jump table to song data
3BD0  DE 3C DF 3C
        
        ;; song data 
3BD4  F1 02 F2 03 F3 0F F4 01  82 70 69 82 70 69 83 70
3BE4  6A 83 70 6A 82 70 69 82  70 69 89 8B 8D 8E FF

3BF3  F1 02 F2 03 F3 0F F4 01  67 50 30 47 30 67 50 30
3C03  47 30 67 50 30 47 30 4B  10 4C 10 4D 10 4E 10 67
3C13  50 30 47 30 67 50 30 47  30 67 50 30 47 30 4B 10
3C23  4C 10 4D 10 4E 10 67 50  30 47 30 67 50 30 47 30
3C33  67 50 30 47 30 4B 10 4C  10 4D 10 4E 10 77 20 4E
3C43  10 4D 10 4C 10 4A 10 47  10 46 10 65 30 66 30 67
3C53  40 70 F0 FB 3B

3C58  F1 00 F2 02 F3 0F F4 00  42 50 4E 50 49 50 46 50
3C68  4E 49 70 66 70 43 50 4F  50 4A 50 47 50 4F 4A 70
3C78  67 70 42 50 4E 50 49 50  46 50 4E 49 70 66 70 45
3C88  46 47 50 47 48 49 50 49  4A 4B 50 6E FF

3C95  F1 01 F2 01 F3 0F F4 00  26 67 26 67 26 67 23 44
3CA4  42 47 30 67 2A 8B 70 26  67 26 67 26 67 23 44 42
3CB4  47 30 67 23 84 70 26 67  26 67 26 67 23 44 42 47
3CC4  30 67 29 6A 2B 6C 30 2C  6D 40 2B 6C 29 6A 67 20
3CD4  29 6A 40 26 87 70 F0 9D  3C
3CDD  00 00 00

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



	;; hangly man basic map (pellet info)
3ce0  00        nop     
3ce1  00        nop     
3ce2  00        nop     
3ce3  00        nop     
3ce4  00        nop     
3ce5  00        nop     
3ce6  00        nop     
3ce7  00        nop     
3ce8  00        nop     
3ce9  00        nop     
3cea  00        nop     
3ceb  00        nop     
3cec  00        nop     
3ced  00        nop     
3cee  00        nop     
3cef  00        nop     
3cf0  00        nop     
3cf1  00        nop     
3cf2  00        nop     
3cf3  00        nop     
3cf4  00        nop     
3cf5  00        nop     
3cf6  00        nop     
3cf7  00        nop     
3cf8  00        nop     
3cf9  00        nop     
3cfa  00        nop     
3cfb  00        nop     
3cfc  00        nop     
3cfd  00        nop     
3cfe  00        nop     
3cff  00        nop     

	;; text strings 2  (copyright, ghost names, intermission)
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f  01234567 89abcdef
00003d00  96 03 40 41  44 44 49 54  49 4f 4e 41  4c 40 40 40    @ADDIT IONAL@@@
00003d10  40 41 54 40  40 40 30 30  30 40 5d 5e  5f 2f 95 2f  @AT@@@00 0@]^_/./
00003d20  80 5a 02 40  40 40 40 40  40 40 2f 07  07 07 01 01  .Z.@@@@@ @@/.....
00003d30  01 01 2f 80  50 40 40 40  2f 87 2f 80  5b 02 5c 40  ../.P@@@ /./.[.\@
00003d40  4d 49 44 57  41 59 40 4d  46 47 40 43  4f 40 40 40  MIDWAY@M FG@CO@@@
00003d50  40 2f 81 2f  80 2f 80 c5  02 3b 4d 41  44 40 44 4f  @/././.. .;MAD@DO
00003d60  47 40 40 2f  81 2f 80 6e  02 40 40 40  42 4c 49 4e  G@@/./.n .@@@BLIN
00003d70  4b 59 2f 81  2f 80 c8 02  3b 4b 49 4c  4c 45 52 40  KY/./... ;KILLER@
00003d80  40 40 2f 83  2f 80 6e 02  40 40 40 50  49 4e 4b 59  @@/./.n. @@@PINKY
00003d90  40 2f 83 2f  80 6e 02 4d  53 40 50 41  43 3b 4d 41  @/./.n.M S@PAC;MA
00003da0  4e 2f 89 2f  80 6e 02 40  40 40 49 4e  4b 59 40 40  N/./.n.@ @@INKY@@
00003db0  2f 85 2f 80  3d 02 40 40  31 39 38 30  3a 31 39 38  /./.=.@@ 1980:198
00003dc0  31 40 2f 81  2f 80 6e 02  40 40 40 40  53 55 45 2f  1@/./.n. @@@@SUE/
00003dd0  87 2f 80 6b  02 4a 55 4e  49 4f 52 40  40 40 40 2f  ./.k.JUN IOR@@@@/
00003de0  8f 2f 80 6b  02 57 49 54  48 40 40 40  40 40 2f 8f  ./.k.WIT H@@@@@/.
00003df0  2f 80 6b 02  54 48 45 40  43 48 41 53  45 40 2f 8f  /.k.THE@ CHASE@/.

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f  01234567 89abcdef
00003e00  2f 80 6b 02  53 54 41 52  52 49 4e 47  40 2f 8f 2f  /.k.STAR RING@/./
00003e10  80 0c 03 4d  53 40 50 41  43 3b 4d 45  4e 2f 8f 2f  ...MS@PA C;MEN/./
00003e20  80 6b 02 40  40 40 40 40  40 40 40 40  2f 85 2f 80  .k.@@@@@ @@@@/./.
00003e30  6b 02 41 43  54 40 49 49  49 26 40 40  2f 87 2f 80  k.ACT@II I&@@/./.
00003e40  6b 02 54 48  45 59 40 4d  45 45 54 2f  8f 2f 80 0c  k.THEY@M EET/./..
00003e50  03 4f 54 54  4f 4d 45 4e  2f 8f 2f 80               .OTTOMEN /./.


	    ;; new code for ms-pacman
3e5c  3a024e    ld      a,(#4e02)
3e5f  fe10      cp      #10
3e61  c4d03e    call    nz,#3ed0
3e64  3a024e    ld      a,(#4e02)
3e67  e7        rst     #20
	; data table
3e68  5f        ld      e,a
3e69  04        inc     b
3e6a  96        sub     (hl)
3e6b  3e8b      ld      a,#8b
3e6d  3e0c      ld      a,#0c
3e6f  00        nop     
3e70  bd        cp      l
3e71  3e9c      ld      a,#9c
3e73  3e83      ld      a,#83
3e75  34        inc     (hl)
3e76  a2        and     d
3e77  3e88      ld      a,#88
3e79  34        inc     (hl)
3e7a  ab        xor     e
3e7b  3e8d      ld      a,#8d
3e7d  34        inc     (hl)
3e7e  b1        or      c
3e7f  3e92      ld      a,#92
3e81  34        inc     (hl)
3e82  c33eb7    jp      #b73e
3e85  3e97      ld      a,#97
3e87  34        inc     (hl)
3e88  c9        ret     

3e89  3ec9      ld      a,#c9
3e8b  ef        rst     #28
3e8c  1c0c
3e8e  3e60      ld      a,#60
3e90  32014f    ld      (#4f01),a
3e93  c38e05    jp      #058e

    ; draw the midway logo and cprt for the attract screen
3e96  cd4296    call    #9642

3e99  c38e05    jp      #058e
3e9c  ef        rst     #28
3e9d  1c0d
3e9f  c38e05    jp      #058e
3ea2  ef        rst     #28
3ea3  1c30
3ea4  ef        rst     #28
3ea6  1c0f
3ea8  c38e05    jp      #058e
3eab  ef        rst     #28
3eac  1c2f
3eae  c38e05    jp      #058e
3eb1  ef        rst     #28
3eb2  1c31
3eb3  c38e05    jp      #058e     
3eb6  05        dec     b
3eb7  ef        rst     #28
3eb8  1c33
3eba  c38e05    jp      #058e
3ebd  ef        rst     #28
3ebe  1c0e
3ebf  c38e05    jp      #058e
3ec3  ef        rst     #28
3ec4  1c10
3ec6  c38e05    jp      #058e
3ec9  af        xor     a
3eca  32144e    ld      (#4e14),a
3ecd  c37c05    jp      #057c
3ed0  3a014f    ld      a,(#4f01)
3ed3  3c        inc     a
3ed4  e60f      and     #0f
3ed6  32014f    ld      (#4f01),a
3ed9  4f        ld      c,a
3eda  cb81      res     0,c
3edc  0600      ld      b,#00
3ede  dd21813f  ld      ix,#3f81
3ee2  cb47      bit     0,a
3ee4  2833      jr      z,#3f19         ; (51)
3ee6  dd09      add     ix,bc
3ee8  dd6e00    ld      l,(ix+#00)
3eeb  dd6601    ld      h,(ix+#01)
3eee  3687      ld      (hl),#87
3ef0  dd6e10    ld      l,(ix+#10)
3ef3  dd6611    ld      h,(ix+#11)
3ef6  3687      ld      (hl),#87
3ef8  dd6e20    ld      l,(ix+#20)
3efb  dd6621    ld      h,(ix+#21)
3efe  368a      ld      (hl),#8a
3f00  dd6e30    ld      l,(ix+#30)
3f03  dd6631    ld      h,(ix+#31)
3f06  3681      ld      (hl),#81
3f08  dd6e40    ld      l,(ix+#40)
3f0b  dd6641    ld      h,(ix+#41)
3f0e  3681      ld      (hl),#81
3f10  dd6e50    ld      l,(ix+#50)
3f13  dd6651    ld      h,(ix+#51)
3f16  3684      ld      (hl),#84
3f18  c9        ret     

3f19  0d        dec     c
3f1a  af        xor     a
3f1b  b9        cp      c
3f1c  fa213f    jp      m,#3f21
3f1f  06ff      ld      b,#ff
3f21  0d        dec     c
3f22  dd09      add     ix,bc
3f24  dd6e00    ld      l,(ix+#00)
3f27  dd6601    ld      h,(ix+#01)
3f2a  35        dec     (hl)
3f2b  dd6e02    ld      l,(ix+#02)
3f2e  dd6603    ld      h,(ix+#03)
3f31  3688      ld      (hl),#88
3f33  dd6e10    ld      l,(ix+#10)
3f36  dd6611    ld      h,(ix+#11)
3f39  35        dec     (hl)
3f3a  dd6e12    ld      l,(ix+#12)
3f3d  dd6613    ld      h,(ix+#13)
3f40  3688      ld      (hl),#88
3f42  dd6e20    ld      l,(ix+#20)
3f45  dd6621    ld      h,(ix+#21)
3f48  35        dec     (hl)
3f49  dd6e22    ld      l,(ix+#22)
3f4c  dd6623    ld      h,(ix+#23)
3f4f  368b      ld      (hl),#8b
3f51  dd6e30    ld      l,(ix+#30)
3f54  dd6631    ld      h,(ix+#31)
3f57  35        dec     (hl)
3f58  dd6e32    ld      l,(ix+#32)
3f5b  dd6633    ld      h,(ix+#33)
3f5e  3682      ld      (hl),#82
3f60  dd6e40    ld      l,(ix+#40)
3f63  dd6641    ld      h,(ix+#41)
3f66  35        dec     (hl)
3f67  dd6e42    ld      l,(ix+#42)
3f6a  dd6643    ld      h,(ix+#43)
3f6d  3682      ld      (hl),#82
3f6f  dd6e50    ld      l,(ix+#50)
3f72  dd6651    ld      h,(ix+#51)
3f75  35        dec     (hl)
3f76  dd6e52    ld      l,(ix+#52)
3f79  dd6653    ld      h,(ix+#53)
3f7c  3683      ld      (hl),#83
3f7e  c9        ret     

3f7f  d0        ret     nc

3f80  42        ld      b,d
3f81  b0        or      b
3f82  42        ld      b,d
3f83  90        sub     b
3f84  42        ld      b,d
3f85  70        ld      (hl),b
3f86  42        ld      b,d
3f87  50        ld      d,b
3f88  42        ld      b,d
3f89  3042      jr      nc,#3fcd        ; (66)
3f8b  1042      djnz    #3fcf           ; (66)
3f8d  f0        ret     p

3f8e  41        ld      b,c
3f8f  d0        ret     nc

3f90  41        ld      b,c
3f91  b0        or      b
3f92  41        ld      b,c
3f93  90        sub     b
3f94  41        ld      b,c
3f95  70        ld      (hl),b
3f96  41        ld      b,c
3f97  50        ld      d,b
3f98  41        ld      b,c
3f99  3041      jr      nc,#3fdc        ; (65)
3f9b  1041      djnz    #3fde           ; (65)
3f9d  f0        ret     p

3f9e  40        ld      b,b
3f9f  d0        ret     nc

3fa0  40        ld      b,b
3fa1  b0        or      b
3fa2  40        ld      b,b
3fa3  af        xor     a
3fa4  40        ld      b,b
3fa5  ae        xor     (hl)
3fa6  40        ld      b,b
3fa7  ad        xor     l
3fa8  40        ld      b,b
3fa9  ac        xor     h
3faa  40        ld      b,b
3fab  ab        xor     e
3fac  40        ld      b,b
3fad  aa        xor     d
3fae  40        ld      b,b
3faf  a9        xor     c
3fb0  40        ld      b,b
3fb1  c9        ret     

3fb2  40        ld      b,b
3fb3  e9        jp      (hl)
3fb4  40        ld      b,b
3fb5  09        add     hl,bc
3fb6  41        ld      b,c
3fb7  29        add     hl,hl
3fb8  41        ld      b,c
3fb9  49        ld      c,c
3fba  41        ld      b,c
3fbb  69        ld      l,c
3fbc  41        ld      b,c
3fbd  89        adc     a,c
3fbe  41        ld      b,c
3fbf  a9        xor     c
3fc0  41        ld      b,c
3fc1  c9        ret     

3fc2  41        ld      b,c
3fc3  e9        jp      (hl)
3fc4  41        ld      b,c
3fc5  09        add     hl,bc
3fc6  42        ld      b,d
3fc7  29        add     hl,hl
3fc8  42        ld      b,d
3fc9  49        ld      c,c
3fca  42        ld      b,d
3fcb  69        ld      l,c
3fcc  42        ld      b,d
3fcd  89        adc     a,c
3fce  42        ld      b,d
3fcf  a9        xor     c
3fd0  42        ld      b,d
3fd1  c9        ret     

3fd2  42        ld      b,d
3fd3  ca42cb    jp      z,#cb42
3fd6  42        ld      b,d
3fd7  cc42cd    call    z,#cd42
3fda  42        ld      b,d
3fdb  ce42      adc     a,#42
3fdd  cf        rst     #8
3fde  42        ld      b,d
3fdf  d0        ret     nc

3fe0  42        ld      b,d
3fe1  c9        ret     

3fe2  42        ld      b,d
3fe3  ca42cb    jp      z,#cb42
3fe6  42        ld      b,d
3fe7  cc42cd    call    z,#cd42
3fea  42        ld      b,d
3feb  ce42      adc     a,#42
3fed  cf        rst     #8
3fee  42        ld      b,d
3fef  d0        ret     nc

3ff0  42        ld      b,d
3ff1  42        ld      b,d
3ff2  cf        rst     #8
3ff3  42        ld      b,d
3ff4  d0        ret     nc

3ff5  42        ld      b,d
3ff6  00        nop     
3ff7  4f        ld      c,a
3ff8  c9        ret     

3ff9  00        nop     
3ffa  00        nop     
3ffb  308d      jr      nc,#3f8a        ; (-115)
3ffd  00        nop     
3ffe  75        ld      (hl),l
3fff  73        ld      (hl),e


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 8000 through 8800:  U5 on the aux board
;;
;; 8000 through 8200:  U5 on the aux board 
;; 8 byte chunks from here are overlayed down into the pac-man roms
;;


; - OVERLAY - 0x2418
8000  c9        ret     
8001  210040    ld      hl,#4000
8004  cd6a94    call    #946a
8007  0a        ld      a,(bc)


; sil attack uses: 
;  (there is a second rom with changes, but i can't find how it overlaps.
; 8000  42        ld      b,d
; 8001  ef        rst     #28
; 8002  00        nop     
; 8003  ff        rst     #38
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
809b  21ac4e    ld      hl,#4eac
809e  cbf6      set     6,(hl)

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
80cd  3808      jr      c,#80cd+#08
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

; - OVERLAY - 0x????  (Can't find this one!)
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
81ab  1807      jr      #19c4           ; (7) 
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

; lookup table...  8251, 82a3, 8312, ...
81f0  51 82
81f2  a3 82
81f4  12 83
81f6  4c 83
81f8  69 85
81fa  7c 85
81fc  95 83
81fe  f0 83

8200  2b        dec     hl
8201  85        add     a,l
8202  4a        ld      c,d
8203  85        add     a,l
8204  69        ld      l,c
8205  85        add     a,l
8206  7c        ld      a,h
8207  85        add     a,l
8208  51        ld      d,c
8209  84        add     a,h
820a  6d        ld      l,l
820b  84        add     a,h
820c  cf        rst     #8
820d  84        add     a,h
820e  fd84      add     a,iyh
8210  89        adc     a,c
8211  84        add     a,h
8212  7c        ld      a,h
8213  85        add     a,l
8214  94        sub     h
8215  85        add     a,l
8216  50        ld      d,b
8217  82        add     a,d
8218  50        ld      d,b
8219  82        add     a,d
821a  50        ld      d,b
821b  82        add     a,d
821c  50        ld      d,b
821d  82        add     a,d
821e  50        ld      d,b
821f  82        add     a,d
8220  50        ld      d,b
8221  82        add     a,d
8222  b0        or      b
8223  85        add     a,l
8224  50        ld      d,b
8225  82        add     a,d
8226  50        ld      d,b
8227  82        add     a,d
8228  50        ld      d,b
8229  82        add     a,d
822a  50        ld      d,b
822b  82        add     a,d
822c  50        ld      d,b
822d  82        add     a,d
822e  50        ld      d,b
822f  82        add     a,d
8230  cc8550    call    z,#5085
8233  82        add     a,d
8234  50        ld      d,b
8235  82        add     a,d
8236  50        ld      d,b
8237  82        add     a,d
8238  50        ld      d,b
8239  82        add     a,d
823a  50        ld      d,b
823b  82        add     a,d
823c  50        ld      d,b
823d  82        add     a,d
823e  e8        ret     pe

823f  85        add     a,l
8240  50        ld      d,b
8241  82        add     a,d
8242  50        ld      d,b
8243  82        add     a,d
8244  50        ld      d,b
8245  82        add     a,d
8246  50        ld      d,b
8247  82        add     a,d
8248  50        ld      d,b
8249  82        add     a,d
824a  50        ld      d,b
824b  82        add     a,d
824c  04        inc     b
824d  86        add     a,(hl)
824e  50        ld      d,b
824f  82        add     a,d
8250  ff        rst     #38

	; table of some sort?
8251  f1        pop     af
8252  00        nop     
8253  00        nop     
8254  f3        di      
8255  75        ld      (hl),l
8256  86        add     a,(hl)
8257  f201f0    jp      p,#f001
825a  00        nop     
825b  00        nop     
825c  16f1      ld      d,#f1
825e  bd        cp      l
825f  52        ld      d,d
8260  f228f6    jp      p,#f628
8263  f216f0    jp      p,#f016
8266  00        nop     
8267  00        nop     
8268  16f2      ld      d,#f2
826a  16f6      ld      d,#f6
826c  f1        pop     af
826d  ff        rst     #38
826e  54        ld      d,h
826f  f3        di      
8270  14        inc     d
8271  86        add     a,(hl)
8272  f27ff0    jp      p,#f07f
8275  f0        ret     p

8276  00        nop     
8277  09        add     hl,bc
8278  f27ff0    jp      p,#f07f
827b  f0        ret     p

827c  00        nop     
827d  09        add     hl,bc
827e  f1        pop     af
827f  00        nop     
8280  7f        ld      a,a
8281  f3        di      
8282  1d        dec     e
8283  86        add     a,(hl)
8284  f275f0    jp      p,#f075
8287  1000      djnz    #8289           ; (0)
8289  09        add     hl,bc
828a  f204f0    jp      p,#f004
828d  10f0      djnz    #827f           ; (-16)
828f  09        add     hl,bc
8290  f3        di      
8291  2686      ld      h,#86
8293  f230f0    jp      p,#f030
8296  00        nop     
8297  f0        ret     p

8298  09        add     hl,bc
8299  f3        di      
829a  1d        dec     e
829b  86        add     a,(hl)
829c  f210f0    jp      p,#f010
829f  00        nop     
82a0  00        nop     
82a1  09        add     hl,bc
82a2  ff        rst     #38

	    ; table?
82a3  f1        pop     af
82a4  00        nop     
82a5  00        nop     
82a6  f3        di      
82a7  7f        ld      a,a
82a8  86        add     a,(hl)
82a9  f201f0    jp      p,#f001
82ac  00        nop     
82ad  00        nop     
82ae  16f1      ld      d,#f1
82b0  ad        xor     l
82b1  52        ld      d,d
82b2  f228f6    jp      p,#f628
82b5  f216f0    jp      p,#f016
82b8  00        nop     
82b9  00        nop     
82ba  16f2      ld      d,#f2
82bc  16f6      ld      d,#f6
82be  f1        pop     af
82bf  ff        rst     #38
82c0  54        ld      d,h
82c1  f3        di      
82c2  5c        ld      e,h
82c3  86        add     a,(hl)
82c4  f22ff6    jp      p,#f62f
82c7  f270f0    jp      p,#f070
82ca  ef        rst     #28
82cb  0005
82cd  f274f0    jp      p,#f074
82d0  ec0005    call    pe,#0500
82d3  f1        pop     af
82d4  00        nop     
82d5  7f        ld      a,a
82d6  f3        di      
82d7  63        ld      h,e
82d8  86        add     a,(hl)
82d9  f21cf6    jp      p,#f61c
82dc  f258f0    jp      p,#f058
82df  1600      ld      d,#00
82e1  05        dec     b
82e2  f5        push    af
82e3  10f2      djnz    #82d7           ; (-14)
82e5  06f0      ld      b,#f0
82e7  f8        ret     m

82e8  f8        ret     m

82e9  05        dec     b
82ea  f206f0    jp      p,#f006
82ed  f8        ret     m

82ee  08        ex      af,af'
82ef  05        dec     b
82f0  f206f0    jp      p,#f006
82f3  f8        ret     m

82f4  f8        ret     m

82f5  05        dec     b
82f6  f206f0    jp      p,#f006
82f9  f8        ret     m

82fa  08        ex      af,af'
82fb  05        dec     b
82fc  f1        pop     af
82fd  00        nop     
82fe  00        nop     
82ff  f3        di      
8300  73        ld      (hl),e
8301  86        add     a,(hl)
8302  f201f0    jp      p,#f001
8305  00        nop     
8306  00        nop     
8307  03        inc     bc
8308  f1        pop     af
8309  7f        ld      a,a
830a  3af240    ld      a,(#40f2)
830d  f0        ret     p

830e  00        nop     
830f  00        nop     
8310  03        inc     bc
8311  ff        rst     #38
8312  f25af6    jp      p,#f65a
8315  f1        pop     af
8316  00        nop     
8317  a4        and     h
8318  f3        di      
8319  41        ld      b,c
831a  86        add     a,(hl)
831b  f27ff0    jp      p,#f07f
831e  1000      djnz    #8320           ; (0)
8320  09        add     hl,bc
8321  f27ff0    jp      p,#f07f
8324  1000      djnz    #8326           ; (0)
8326  09        add     hl,bc
8327  f1        pop     af
8328  ff        rst     #38
8329  7f        ld      a,a
832a  f3        di      
832b  3886      jr      c,#82b3         ; (-122)
832d  f276f0    jp      p,#f076
8330  f0        ret     p

8331  00        nop     
8332  09        add     hl,bc
8333  f204f0    jp      p,#f004
8336  f0        ret     p

8337  f0        ret     p

8338  09        add     hl,bc
8339  f3        di      
833a  4a        ld      c,d
833b  86        add     a,(hl)
833c  f230f0    jp      p,#f030
833f  00        nop     
8340  f0        ret     p

8341  09        add     hl,bc
8342  f3        di      
8343  3886      jr      c,#82cb         ; (-122)
8345  f210f0    jp      p,#f010
8348  00        nop     
8349  00        nop     
834a  09        add     hl,bc
834b  ff        rst     #38
834c  f25ff6    jp      p,#f65f
834f  f1        pop     af
8350  01a4f3    ld      bc,#f3a4
8353  63        ld      h,e
8354  86        add     a,(hl)
8355  f22ff6    jp      p,#f62f
8358  f270f0    jp      p,#f070
835b  110003    ld      de,#0300
835e  f274f0    jp      p,#f074
8361  14        inc     d
8362  00        nop     
8363  03        inc     bc
8364  f1        pop     af
8365  ff        rst     #38
8366  7f        ld      a,a
8367  f3        di      
8368  5c        ld      e,h
8369  86        add     a,(hl)
836a  f21cf6    jp      p,#f61c
836d  f258f0    jp      p,#f058
8370  ea0003    jp      pe,#0300
8373  f206f0    jp      p,#f006
8376  08        ex      af,af'
8377  f8        ret     m

8378  03        inc     bc
8379  f206f0    jp      p,#f006
837c  08        ex      af,af'
837d  08        ex      af,af'
837e  03        inc     bc
837f  f206f0    jp      p,#f006
8382  08        ex      af,af'
8383  f8        ret     m

8384  03        inc     bc
8385  f206f0    jp      p,#f006
8388  08        ex      af,af'
8389  08        ex      af,af'
838a  03        inc     bc
838b  f3        di      
838c  71        ld      (hl),c
838d  86        add     a,(hl)
838e  f210f0    jp      p,#f010
8391  00        nop     
8392  00        nop     
8393  16ff      ld      d,#ff
8395  f25af6    jp      p,#f65a
8398  f1        pop     af
8399  ff        rst     #38
839a  34        inc     (hl)
839b  f3        di      
839c  14        inc     d
839d  86        add     a,(hl)
839e  f27ff6    jp      p,#f67f
83a1  f224f6    jp      p,#f624
83a4  f268f0    jp      p,#f068
83a7  d8        ret     c

83a8  00        nop     
83a9  09        add     hl,bc
83aa  f27ff6    jp      p,#f67f
83ad  f218f6    jp      p,#f618
83b0  f1        pop     af
83b1  00        nop     
83b2  94        sub     h
83b3  f3        di      
83b4  41        ld      b,c
83b5  86        add     a,(hl)
83b6  f268f0    jp      p,#f068
83b9  2800      jr      z,#83bb         ; (0)
83bb  09        add     hl,bc
83bc  f27ff6    jp      p,#f67f
83bf  f1        pop     af
83c0  fc7ff3    call    m,#f37f
83c3  14        inc     d
83c4  86        add     a,(hl)
83c5  f218f6    jp      p,#f618
83c8  f268f0    jp      p,#f068
83cb  d8        ret     c

83cc  00        nop     
83cd  09        add     hl,bc
83ce  f27ff6    jp      p,#f67f
83d1  f218f6    jp      p,#f618
83d4  f1        pop     af
83d5  00        nop     
83d6  54        ld      d,h
83d7  f3        di      
83d8  41        ld      b,c
83d9  86        add     a,(hl)
83da  f220f0    jp      p,#f020
83dd  70        ld      (hl),b
83de  00        nop     
83df  09        add     hl,bc
83e0  f1        pop     af
83e1  ff        rst     #38
83e2  b4        or      h
83e3  f3        di      
83e4  14        inc     d
83e5  86        add     a,(hl)
83e6  f210f6    jp      p,#f610
83e9  f224f0    jp      p,#f024
83ec  90        sub     b
83ed  00        nop     
83ee  09        add     hl,bc
83ef  ff        rst     #38
83f0  f263f6    jp      p,#f663
83f3  f1        pop     af
83f4  ff        rst     #38
83f5  34        inc     (hl)
83f6  f3        di      
83f7  3886      jr      c,#837f         ; (-122)
83f9  f224f6    jp      p,#f624
83fc  f27ff6    jp      p,#f67f
83ff  f218f6    jp      p,#f618
8402  f257f0    jp      p,#f057
8405  d0        ret     nc

8406  00        nop     
8407  09        add     hl,bc
8408  f27ff6    jp      p,#f67f
840b  f228f6    jp      p,#f628
840e  f1        pop     af
840f  00        nop     
8410  94        sub     h
8411  f3        di      
8412  1d        dec     e
8413  86        add     a,(hl)
8414  f258f0    jp      p,#f058
8417  3000      jr      nc,#8419        ; (0)
8419  09        add     hl,bc
841a  f27ff6    jp      p,#f67f
841d  f224f6    jp      p,#f624
8420  f1        pop     af
8421  ff        rst     #38
8422  7f        ld      a,a
8423  f3        di      
8424  3886      jr      c,#83ac         ; (-122)
8426  f258f0    jp      p,#f058
8429  d0        ret     nc

842a  00        nop     
842b  09        add     hl,bc
842c  f27ff6    jp      p,#f67f
842f  f220f6    jp      p,#f620
8432  f1        pop     af
8433  00        nop     
8434  54        ld      d,h
8435  f3        di      
8436  1d        dec     e
8437  86        add     a,(hl)
8438  f220f0    jp      p,#f020
843b  70        ld      (hl),b
843c  00        nop     
843d  09        add     hl,bc
843e  f1        pop     af
843f  ff        rst     #38
8440  b4        or      h
8441  f3        di      
8442  3886      jr      c,#83ca         ; (-122)
8444  f210f6    jp      p,#f610
8447  f224f0    jp      p,#f024
844a  90        sub     b
844b  00        nop     
844c  09        add     hl,bc
844d  f27ff6    jp      p,#f67f
8450  ff        rst     #38
8451  f25af6    jp      p,#f65a
8454  f1        pop     af
8455  00        nop     
8456  60        ld      h,b
8457  f3        di      
8458  8d        adc     a,l
8459  86        add     a,(hl)
845a  f27ff0    jp      p,#f07f
845d  0a        ld      a,(bc)
845e  00        nop     
845f  16f2      ld      d,#f2
8461  7f        ld      a,a
8462  f0        ret     p

8463  1000      djnz    #8465           ; (0)
8465  16f2      ld      d,#f2
8467  30f0      jr      nc,#8459        ; (-16)
8469  1000      djnz    #846b           ; (0)
846b  16ff      ld      d,#ff
846d  f26ff6    jp      p,#f66f
8470  f1        pop     af
8471  00        nop     
8472  60        ld      h,b
8473  f3        di      
8474  8f        adc     a,a
8475  86        add     a,(hl)
8476  f26af0    jp      p,#f06a
8479  0a        ld      a,(bc)
847a  00        nop     
847b  16f2      ld      d,#f2
847d  7f        ld      a,a
847e  f0        ret     p

847f  1000      djnz    #8481           ; (0)
8481  16f2      ld      d,#f2
8483  3af010    ld      a,(#10f0)
8486  00        nop     
8487  16ff      ld      d,#ff
8489  f3        di      
848a  89        adc     a,c
848b  86        add     a,(hl)
848c  f201f0    jp      p,#f001
848f  00        nop     
8490  00        nop     
8491  16f1      ld      d,#f1
8493  bd        cp      l
8494  62        ld      h,d
8495  f25af6    jp      p,#f65a
8498  f1        pop     af
8499  05        dec     b
849a  60        ld      h,b
849b  f3        di      
849c  98        sbc     a,b
849d  86        add     a,(hl)
849e  f27ff0    jp      p,#f07f
84a1  0a        ld      a,(bc)
84a2  00        nop     
84a3  16f2      ld      d,#f2
84a5  7f        ld      a,a
84a6  f0        ret     p

84a7  060c      ld      b,#0c
84a9  16f2      ld      d,#f2
84ab  06f0      ld      b,#f0
84ad  06f0      ld      b,#f0
84af  16f2      ld      d,#f2
84b1  0c        inc     c
84b2  f0        ret     p

84b3  03        inc     bc
84b4  09        add     hl,bc
84b5  16f2      ld      d,#f2
84b7  05        dec     b
84b8  f0        ret     p

84b9  05        dec     b
84ba  f616      or      #16
84bc  f20af0    jp      p,#f00a
84bf  04        inc     b
84c0  03        inc     bc
84c1  16f3      ld      d,#f3
84c3  9a        sbc     a,d
84c4  86        add     a,(hl)
84c5  f201f0    jp      p,#f001
84c8  00        nop     
84c9  00        nop     
84ca  16f2      ld      d,#f2
84cc  20f6      jr      nz,#84c4        ; (-10)
84ce  ff        rst     #38
84cf  f1        pop     af
84d0  00        nop     
84d1  00        nop     
84d2  f3        di      
84d3  75        ld      (hl),l
84d4  86        add     a,(hl)
84d5  f201f0    jp      p,#f001
84d8  00        nop     
84d9  00        nop     
84da  16f1      ld      d,#f1
84dc  bd        cp      l
84dd  52        ld      d,d
84de  f228f6    jp      p,#f628
84e1  f216f0    jp      p,#f016
84e4  00        nop     
84e5  00        nop     
84e6  16f2      ld      d,#f2
84e8  16f6      ld      d,#f6
84ea  f1        pop     af
84eb  00        nop     
84ec  00        nop     
84ed  f3        di      
84ee  3886      jr      c,#8476         ; (-122)
84f0  f201f0    jp      p,#f001
84f3  00        nop     
84f4  00        nop     
84f5  09        add     hl,bc
84f6  f1        pop     af
84f7  c0        ret     nz

84f8  c0        ret     nz

84f9  f230f6    jp      p,#f630
84fc  ff        rst     #38
84fd  f1        pop     af
84fe  00        nop     
84ff  00        nop     
8500  f3        di      
8501  7f        ld      a,a
8502  86        add     a,(hl)
8503  f201f0    jp      p,#f001
8506  00        nop     
8507  00        nop     
8508  16f1      ld      d,#f1
850a  ad        xor     l
850b  52        ld      d,d
850c  f228f6    jp      p,#f628
850f  f216f0    jp      p,#f016
8512  00        nop     
8513  00        nop     
8514  16f2      ld      d,#f2
8516  16f6      ld      d,#f6
8518  f1        pop     af
8519  00        nop     
851a  00        nop     
851b  f3        di      
851c  14        inc     d
851d  86        add     a,(hl)
851e  f201f0    jp      p,#f001
8521  00        nop     
8522  00        nop     
8523  09        add     hl,bc
8524  f1        pop     af
8525  d0        ret     nc

8526  c0        ret     nz

8527  f230f6    jp      p,#f630
852a  ff        rst     #38
852b  f1        pop     af
852c  00        nop     
852d  00        nop     
852e  f3        di      
852f  75        ld      (hl),l
8530  86        add     a,(hl)
8531  f201f0    jp      p,#f001
8534  00        nop     
8535  00        nop     
8536  16f1      ld      d,#f1
8538  bd        cp      l
8539  52        ld      d,d
853a  f228f6    jp      p,#f628
853d  f216f0    jp      p,#f016
8540  00        nop     
8541  00        nop     
8542  16f2      ld      d,#f2
8544  16f6      ld      d,#f6
8546  f1        pop     af
8547  00        nop     
8548  00        nop     
8549  ff        rst     #38
854a  f1        pop     af
854b  00        nop     
854c  00        nop     
854d  f3        di      
854e  7f        ld      a,a
854f  86        add     a,(hl)
8550  f201f0    jp      p,#f001
8553  00        nop     
8554  00        nop     
8555  16f1      ld      d,#f1
8557  ad        xor     l
8558  52        ld      d,d
8559  f228f6    jp      p,#f628
855c  f216f0    jp      p,#f016
855f  00        nop     
8560  00        nop     
8561  16f2      ld      d,#f2
8563  16f6      ld      d,#f6
8565  f1        pop     af
8566  00        nop     
8567  00        nop     
8568  ff        rst     #38
8569  f3        di      
856a  89        adc     a,c
856b  86        add     a,(hl)
856c  f201f0    jp      p,#f001
856f  00        nop     
8570  00        nop     
8571  16f1      ld      d,#f1
8573  bd        cp      l
8574  62        ld      h,d
8575  f25af6    jp      p,#f65a
8578  f1        pop     af
8579  00        nop     
857a  00        nop     
857b  ff        rst     #38
857c  f3        di      
857d  8b        adc     a,e
857e  86        add     a,(hl)
857f  f201f0    jp      p,#f001
8582  00        nop     
8583  00        nop     
8584  16f1      ld      d,#f1
8586  ad        xor     l
8587  62        ld      h,d
8588  f239f6    jp      p,#f639
858b  f7        rst     #30
858c  f21ef6    jp      p,#f61e
858f  f8        ret     m

8590  f1        pop     af
8591  00        nop     
8592  00        nop     
8593  ff        rst     #38
8594  f1        pop     af
8595  00        nop     
8596  94        sub     h
8597  f3        di      
8598  63        ld      h,e
8599  86        add     a,(hl)
859a  f270f0    jp      p,#f070
859d  1000      djnz    #859f           ; (0)
859f  01f250    ld      bc,#50f2
85a2  f0        ret     p

85a3  1000      djnz    #85a5           ; (0)
85a5  01f36a    ld      bc,#6af3
85a8  86        add     a,(hl)
85a9  f248f0    jp      p,#f048
85ac  00        nop     
85ad  f0        ret     p

85ae  01fff1    ld      bc,#f1ff
85b1  00        nop     
85b2  94        sub     h
85b3  f3        di      
85b4  63        ld      h,e
85b5  86        add     a,(hl)
85b6  f270f0    jp      p,#f070
85b9  1000      djnz    #85bb           ; (0)
85bb  03        inc     bc
85bc  f250f0    jp      p,#f050
85bf  1000      djnz    #85c1           ; (0)
85c1  03        inc     bc
85c2  f3        di      
85c3  6a        ld      l,d
85c4  86        add     a,(hl)
85c5  f238f0    jp      p,#f038
85c8  00        nop     
85c9  f0        ret     p

85ca  03        inc     bc
85cb  ff        rst     #38
85cc  f1        pop     af
85cd  00        nop     
85ce  94        sub     h
85cf  f3        di      
85d0  63        ld      h,e
85d1  86        add     a,(hl)
85d2  f270f0    jp      p,#f070
85d5  1000      djnz    #85d7           ; (0)
85d7  05        dec     b
85d8  f250f0    jp      p,#f050
85db  1000      djnz    #85dd           ; (0)
85dd  05        dec     b
85de  f3        di      
85df  6a        ld      l,d
85e0  86        add     a,(hl)
85e1  f228f0    jp      p,#f028
85e4  00        nop     
85e5  f0        ret     p

85e6  05        dec     b
85e7  ff        rst     #38
85e8  f1        pop     af
85e9  00        nop     
85ea  94        sub     h
85eb  f3        di      
85ec  63        ld      h,e
85ed  86        add     a,(hl)
85ee  f270f0    jp      p,#f070
85f1  1000      djnz    #85f3           ; (0)
85f3  07        rlca    
85f4  f250f0    jp      p,#f050
85f7  1000      djnz    #85f9           ; (0)
85f9  07        rlca    
85fa  f3        di      
85fb  6a        ld      l,d
85fc  86        add     a,(hl)
85fd  f218f0    jp      p,#f018
8600  00        nop     
8601  f0        ret     p

8602  07        rlca    
8603  ff        rst     #38
8604  f1        pop     af
8605  00        nop     
8606  94        sub     h
8607  f3        di      
8608  41        ld      b,c
8609  86        add     a,(hl)
860a  f272f0    jp      p,#f072
860d  1000      djnz    #860f           ; (0)
860f  09        add     hl,bc
8610  f27ff6    jp      p,#f67f
8613  ff        rst     #38
8614  1b        dec     de
8615  1b        dec     de
8616  19        add     hl,de
8617  19        add     hl,de
8618  1b        dec     de
8619  1b        dec     de
861a  3232ff    ld      (#ff32),a
861d  9b        sbc     a,e
861e  9b        sbc     a,e
861f  99        sbc     a,c
8620  99        sbc     a,c
8621  9b        sbc     a,e
8622  9b        sbc     a,e
8623  b2        or      d
8624  b2        or      d
8625  ff        rst     #38
8626  6e        ld      l,(hl)
8627  6e        ld      l,(hl)
8628  5a        ld      e,d
8629  5a        ld      e,d
862a  6e        ld      l,(hl)
862b  6e        ld      l,(hl)
862c  72        ld      (hl),d
862d  72        ld      (hl),d
862e  ff        rst     #38
862f  eeee      xor     #ee
8631  dadaee    jp      c,#eeda
8634  eef2      xor     #f2
8636  f2ff37    jp      p,#37ff
8639  37        scf     
863a  2d        dec     l
863b  2d        dec     l
863c  37        scf     
863d  37        scf     
863e  2f        cpl     
863f  2f        cpl     
8640  ff        rst     #38
8641  b7        or      a
8642  b7        or      a
8643  ad        xor     l
8644  ad        xor     l
8645  b7        or      a
8646  b7        or      a
8647  af        xor     a
8648  af        xor     a
8649  ff        rst     #38
864a  3636      ld      (hl),#36
864c  f1        pop     af
864d  f1        pop     af
864e  3636      ld      (hl),#36
8650  f3        di      
8651  f3        di      
8652  ff        rst     #38
8653  34        inc     (hl)
8654  34        inc     (hl)
8655  313134    ld      sp,#3431
8658  34        inc     (hl)
8659  33        inc     sp
865a  33        inc     sp
865b  ff        rst     #38
865c  a4        and     h
865d  a4        and     h
865e  a4        and     h
865f  a5        and     l
8660  a5        and     l
8661  a5        and     l
8662  ff        rst     #38
8663  24        inc     h
8664  24        inc     h
8665  24        inc     h
8666  25        dec     h
8667  25        dec     h
8668  25        dec     h
8669  ff        rst     #38
866a  2626      ld      h,#26
866c  2627      ld      h,#27
866e  27        daa     
866f  27        daa     
8670  ff        rst     #38
8671  1f        rra     
8672  ff        rst     #38
8673  1eff      ld      e,#ff
8675  1010      djnz    #8687           ; (16)
8677  1014      djnz    #868d           ; (20)
8679  14        inc     d
867a  14        inc     d
867b  1616      ld      d,#16
867d  16ff      ld      d,#ff
867f  111111    ld      de,#1111
8682  15        dec     d
8683  15        dec     d
8684  15        dec     d
8685  17        rla     
8686  17        rla     
8687  17        rla     
8688  ff        rst     #38
8689  12        ld      (de),a
868a  ff        rst     #38
868b  13        inc     de
868c  ff        rst     #38
868d  30ff      jr      nc,#868e        ; (-1)
868f  1818      jr      #86a9           ; (24)
8691  1818      jr      #86ab           ; (24)
8693  2c        inc     l
8694  2c        inc     l
8695  2c        inc     l
8696  2c        inc     l
8697  ff        rst     #38
8698  07        rlca    
8699  ff        rst     #38
869a  0f        rrca    
869b  ff        rst     #38


869c  3a094d    ld      a,(#4d09)
869f  e607      and     #07
86a1  cb3f      srl     a
86a3  2f        cpl     
86a4  1e30      ld      e,#30
86a6  83        add     a,e
86a7  cb47      bit     0,a		; 
86a9  2002      jr      nz,#86ad        ; (2)
86ab  3e37      ld      a,#37
86ad  320a4c    ld      (#4c0a),a	; mspac sprite number
86b0  c9        ret     

86b1  3a084d    ld      a,(#4d08)
86b4  e607      and     #07		; 
86b6  cb3f      srl     a
86b8  1e30      ld      e,#30
86ba  83        add     a,e
86bb  cb47      bit     0,a		; 
86bd  2002      jr      nz,#86c1        ; (2)
86bf  3e34      ld      a,#34
86c1  320a4c    ld      (#4c0a),a	; mspac sprite number
86c4  c9        ret     

86c5  3a094d    ld      a,(#4d09)
86c8  e607      and     #07
86ca  cb3f      srl     a
86cc  1eac      ld      e,#ac
86ce  83        add     a,e
86cf  cb47      bit     0,a		; 
86d1  2002      jr      nz,#86d5        ; (2)
86d3  3e35      ld      a,#35
86d5  320a4c    ld      (#4c0a),a	; mspac sprite number
86d8  c9        ret     

86d9  3a084d    ld      a,(#4d08)
86dc  e607      and     #07		; 
86de  cb3f      srl     a
86e0  2f        cpl     
86e1  1ef4      ld      e,#f4		; 
86e3  83        add     a,e
86e4  cb47      bit     0,a		; 
86e6  2002      jr      nz,#86ea        ; (2)
86e8  3e36      ld      a,#36
86ea  320a4c    ld      (#4c0a),a	; mspac sprite number
86ed  c9        ret     

86ee  3aa44d    ld      a,(#4da4)
86f1  a7        and     a
86f2  c0        ret     nz

86f3  3ad44d    ld      a,(#4dd4)
86f6  a7        and     a
86f7  ca4787    jp      z,#8747
86fa  3ad24d    ld      a,(#4dd2)
86fd  a7        and     a
86fe  ca4787    jp      z,#8747
8701  3a414c    ld      a,(#4c41)
8704  47        ld      b,a
8705  214188    ld      hl,#8841
8708  df        rst     #18
8709  ed5bd24d  ld      de,(#4dd2)
870d  19        add     hl,de
870e  22d24d    ld      (#4dd2),hl
8711  21414c    ld      hl,#4c41
8714  34        inc     (hl)
8715  7e        ld      a,(hl)
8716  e60f      and     #0f
8718  c0        ret     nz

8719  21404c    ld      hl,#4c40
871c  35        dec     (hl)
871d  fab587    jp      m,#87b5
8720  7e        ld      a,(hl)
8721  57        ld      d,a
8722  cb3f      srl     a
8724  cb3f      srl     a
8726  21bc4e    ld      hl,#4ebc
8729  cbee      set     5,(hl)
872b  2a424c    ld      hl,(#4c42)
872e  d7        rst     #10
872f  4f        ld      c,a
8730  3e03      ld      a,#03
8732  a2        and     d
8733  2807      jr      z,#873c         ; (7)
8735  cb39      srl     c
8737  cb39      srl     c
8739  3d        dec     a
873a  20f9      jr      nz,#8735        ; (-7)
873c  3e03      ld      a,#03
873e  a1        and     c
873f  07        rlca    
8740  07        rlca    
8741  07        rlca    
8742  07        rlca    
8743  32414c    ld      (#4c41),a
8746  c9        ret     

8747  3a0e4e    ld      a,(#4e0e)
874a  fe40      cp      #40
874c  ca5887    jp      z,#8758
874f  feb0      cp      #b0
8751  c0        ret     nz

8752  210d4e    ld      hl,#4e0d
8755  c35b87    jp      #875b
8758  210c4e    ld      hl,#4e0c
875b  7e        ld      a,(hl)
875c  a7        and     a
875d  c0        ret     nz

875e  34        inc     (hl)

	;; Ms. Pacman Random Fruit Probabilities
	;; (c) 2002 Mark Spaeth
	;; http://rgvac.978.org/files/MsPacFruit.txt

;  A hotly contested issue on rgvac. here's an explanation
;  of how the random fruit selection routine works in Ms.
;  Pacman, and the probabilities associated with the routine:

875f  3a134e    ld      a,(#4e13)       ; Load the board # (cherry = 0)
8762  fe07      cp      #07             ; Compare it to 7
8764  380a      jr      c,#8770         ; If less than 7, use board # as fruit

8766  0607      ld      b,#07   
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
;    blank every 1/60sec, but since the the instruction
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
8784  21f887    ld      hl,#87f8
8787  cdcd87    call    #87cd
878a  23        inc     hl
878b  5e        ld      e,(hl)
878c  23        inc     hl
878d  56        ld      d,(hl)
878e  ed53d24d  ld      (#4dd2),de
8792  c9        ret     

	; new board increment routine
8793  fe08      cp      #08		; if <= 8
8795  daf92b    jp      c,#2bf9		; return
8798  3e07      ld      a,#07		; set to 7
879a  c3f92b    jp      #2bf9		; return


	;; fruit shape/color/points table

 offset   0  1  2  3  4  5  6  7   8  9  a  b  c  d  e  f

00008790                                          00 14 06  |             ...|
000087a0  01 0f 07 02 15 08 03 07  09 04 14 0a 05 15 0b 06  |................|
000087b0  16 0c 07 00 0d                                    |.....           |


879d  001406		; Cherry     = sprite 0, color 14, score table 06
87a0  010f07		; Strawberry = sprite 1, color 0f, score table 07
87a3  021508		; Orange     = sprite 2, color 15, score table 08
87a6  030709		; Pretzel    = sprite 3, color 07, score table 09
87a9  04140a		; Apple      = sprite 4, color 14, score table 0a
87ac  05150b		; Pear	     = sprite 5, color 15, score table 0b
87af  06160c		; Banana     = sprite 6, color 16, score table 0c
87b2  07000d		; Junior!    = sprite 7, color 00, score table 0d

	; For reference, the score table is at 0x2b17

87b5  3ad34d    ld      a,(#4dd3)
87b8  c620      add     a,#20
87ba  fe40      cp      #40
87bc  3852      jr      c,#8810         ; (82)
87be  2a424c    ld      hl,(#4c42)
87c1  110888    ld      de,#8808
87c4  37        scf     
87c5  3f        ccf     
87c6  ed52      sbc     hl,de
87c8  2023      jr      nz,#87ed        ; (35)
87ca  210088    ld      hl,#8800

87cd  cdbd94    call    #94bd
87d0  69        ld      l,c
87d1  60        ld      h,b
87d2  ed5f      ld      a,r
87d4  e603      and     #03
87d6  47        ld      b,a
87d7  87        add     a,a
87d8  87        add     a,a
87d9  80        add     a,b
87da  d7        rst     #10
87db  5f        ld      e,a
87dc  23        inc     hl
87dd  56        ld      d,(hl)
87de  ed53424c  ld      (#4c42),de
87e2  23        inc     hl
87e3  7e        ld      a,(hl)
87e4  32404c    ld      (#4c40),a
87e7  3e1f      ld      a,#1f
87e9  32414c    ld      (#4c41),a
87ec  c9        ret     

87ed  210888    ld      hl,#8808
87f0  22424c    ld      (#4c42),hl
87f3  3e1d      ld      a,#1d
87f5  c3e487    jp      #87e4

	; fruit path lookup table
87f8  4f 8b
87fa  40 8e
87fc  1a 91
87fe  0a 94

	;; 8800 thru 8fff is invalid rom space. (???)
8800  82        add     a,d
8801  8b        adc     a,e
8802  73        ld      (hl),e
8803  8e        adc     a,(hl)
8804  42        ld      b,d
8805  91        sub     c
8806  3c        inc     a
8807  94        sub     h
8808  faff55    jp      m,#55ff
880b  55        ld      d,l
880c  0180aa    ld      bc,#aa80
880f  02        ld      (bc),a
8810  3e00      ld      a,#00
8812  320d4c    ld      (#4c0d),a
8815  c30010    jp      #1000
8818  f5        push    af
8819  ed5bd24d  ld      de,(#4dd2)
881d  7c        ld      a,h
881e  92        sub     d
881f  c603      add     a,#03
8821  fe06      cp      #06
8823  3018      jr      nc,#883d        ; (24)
8825  7d        ld      a,l
8826  93        sub     e
8827  c603      add     a,#03
8829  fe06      cp      #06
882b  3010      jr      nc,#883d        ; (16)
882d  3e01      ld      a,#01
882f  320d4c    ld      (#4c0d),a
8832  f1        pop     af
8833  c602      add     a,#02
8835  320c4c    ld      (#4c0c),a
8838  d602      sub     #02
883a  c3b219    jp      #19b2
883d  f1        pop     af
883e  c3cd19    jp      #19cd
8841  ff        rst     #38
8842  ff        rst     #38
8843  ff        rst     #38
8844  ff        rst     #38
8845  ff        rst     #38
8846  ff        rst     #38
8847  ff        rst     #38
8848  ff        rst     #38
8849  ff        rst     #38
884a  ff        rst     #38
884b  ff        rst     #38
884c  ff        rst     #38
884d  ff        rst     #38
884e  ff        rst     #38
884f  ff        rst     #38
8850  ff        rst     #38
8851  ff        rst     #38
8852  ff        rst     #38
8853  00        nop     
8854  00        nop     
8855  ff        rst     #38
8856  ff        rst     #38
8857  00        nop     
8858  00        nop     
8859  00        nop     
885a  00        nop     
885b  010000    ld      bc,#0000
885e  00        nop     
885f  010000    ld      bc,#0000
8862  00        nop     
8863  ff        rst     #38
8864  fe00      cp      #00
8866  00        nop     
8867  00        nop     
8868  ff        rst     #38
8869  00        nop     
886a  00        nop     
886b  ff        rst     #38
886c  fe00      cp      #00
886e  00        nop     
886f  00        nop     
8870  ff        rst     #38
8871  00        nop     
8872  00        nop     
8873  00        nop     
8874  ff        rst     #38
8875  00        nop     
8876  00        nop     
8877  00        nop     
8878  ff        rst     #38
8879  00        nop     
887a  00        nop     
887b  01ff01    ld      bc,#01ff
887e  ff        rst     #38
887f  00        nop     
8880  00        nop     
8881  00        nop     
8882  00        nop     
8883  00        nop     
8884  00        nop     
8885  ff        rst     #38
8886  00        nop     
8887  00        nop     
8888  00        nop     
8889  00        nop     
888a  010000    ld      bc,#0000
888d  ff        rst     #38
888e  00        nop     
888f  00        nop     
8890  00        nop     
8891  00        nop     
8892  010000    ld      bc,#0000
8895  00        nop     
8896  010000    ld      bc,#0000
8899  00        nop     
889a  010000    ld      bc,#0000
889d  010101    ld      bc,#0101
88a0  010000    ld      bc,#0000
88a3  010001    ld      bc,#0100
88a6  00        nop     
88a7  010001    ld      bc,#0100
88aa  00        nop     
88ab  010001    ld      bc,#0100
88ae  00        nop     
88af  010001    ld      bc,#0100
88b2  00        nop     
88b3  010001    ld      bc,#0100
88b6  00        nop     
88b7  0100ff    ld      bc,#ff00
88ba  ff        rst     #38
88bb  ff        rst     #38
88bc  ff        rst     #38
88bd  00        nop     
88be  00        nop     
88bf  ff        rst     #38
88c0  ff        rst     #38


	;; Maze Table 1
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
000088c0     40 fc d0  d2 d2 d2 d2  d4 fc da 02  dc fc fc fc
000088d0  fc fc fc da  02 dc fc fc  fc d0 d2 d2  d2 d2 d2 d2
000088e0  d2 d4 fc da  05 dc fc da  02 dc fc fc  fc fc fc fc
000088f0  da 02 dc fc  fc fc da 08  dc fc da 02  e6 ea 02 e7

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008900  d2 eb 02 e7  d2 d2 d2 d2  d2 d2 eb 02  e7 d2 d2 d2
00008910  eb 02 e6 e8  e8 e8 ea 02  dc fc da 02  de e4 15 de
00008920  c0 c0 c0 e4  02 dc fc da  02 de e4 02  e6 e8 e8 e8
00008930  e8 ea 02 e6  e8 e8 e8 ea  02 e6 ea 02  e6 ea 02 de
00008940  c0 c0 c0 e4  02 dc fc da  02 e7 eb 02  e7 e9 e9 e9
00008950  f5 e4 02 de  f3 e9 e9 eb  02 de e4 02  de e4 02 e7
00008960  e9 e9 e9 eb  02 dc fc da  09 de e4 02  de e4 05 de
00008970  e4 02 de e4  08 dc fc fa  e8 e8 ea 02  e6 e8 ea 02
00008980  de e4 02 de  e4 02 e6 e8  e8 f4 e4 02  de e4 02 e6
00008990  e8 e8 e8 ea  02 dc fc fb  e9 e9 eb 02  de c0 e4 02
000089a0  e7 eb 02 e7  eb 02 e7 e9  e9 f5 e4 02  e7 eb 02 de
000089b0  f3 e9 e9 eb  02 dc fc da  05 de c0 e4  0b de e4 05
000089c0  de e4 05 dc  fc da 02 e6  ea 02 de c0  e4 02 e6 ea
000089d0  02 ec d3 d3  d3 ee 02 de  e4 02 e6 ea  02 de e4 02
000089e0  e6 ea 02 dc  fc da 02 de  e4 02 e7 e9  eb 02 de e4
000089f0  02 dc fc fc  fc da 02 e7  eb 02 de e4  02 e7 eb 02

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008a00  de e4 02 dc  fc da 02 de  e4 06 de e4  02 f0 fc fc
00008a10  fc da 05 de  e4 05 de e4  02 dc fc da  02 de e4 02
00008a20  e6 e8 e8 e8  f4 e4 02 ce  fc fc fc da  02 e6 e8 e8
00008a30  f4 e4 02 e6  e8 e8 f4 e4  02 dc 00                


	;; Pellet table 1
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008a30                                     62  02 01 13 01
00008a40  01 01 02 01  04 03 13 06  04 03 01 01  01 01 01 01
00008a50  01 01 01 01  01 01 01 01  01 01 01 01  01 06 04 03
00008a60  10 03 06 04  03 10 03 06  04 01 01 01  01 01 01 01
00008a70  0c 03 01 01  01 01 01 01  07 04 0c 03  06 07 04 0c
00008a80  03 06 04 01  01 01 04 0c  01 01 01 03  01 01 01 04
00008a90  03 04 0f 03  03 04 03 04  0f 03 03 04  03 01 01 01
00008aa0  01 0f 01 01  01 03 04 03  19 04 03 19  04 03 01 01
00008ab0  01 01 0f 01  01 01 03 04  03 04 0f 03  03 04 03 04
00008ac0  0f 03 03 04  01 01 01 04  0c 01 01 01  03 01 01 01
00008ad0  07 04 0c 03  06 07 04 0c  03 06 04 01  01 01 01 01
00008ae0  01 01 0c 03  01 01 01 01  01 01 04 03  10 03 06 04
00008af0  03 10 03 06  04 03 01 01  01 01 01 01  01 01 01 01

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008b00  01 01 01 01  01 01 01 01  01 06 04 03  13 06 04 02
00008b10  01 13 01 01  01 02 01 00  00 00 00 00  00 00 00 00
00008b20  00 00 00 00  00 00 00 00  00 00 00 00


	;; number of pellets to eat for map 1
8b2c  e0

	;; destination table?
8b2d  1d 22 1d 39
8b31  40 20 40 3b


	;; Power Pellet Table 1 (locations)
	;; 4063, 407c, 4383, 439c
8b35  63 40 
8b37  7c 40
8b39  83 43
8b3b  9c 43


	;; unknown Table A
8b3d  49 09 17 09 
8b41  17 09 0e e0
8b45  e0 e0 29 09
8b49  17 09 17 09
8b4d  00 00 


	;; fruit paths for map 1:  $8b4f-$8b81
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008b40                                                  63
00008b50  8b 13 94 0c  68 8b 22 94  f4 71 8b 27  4c f4 7b 8b
00008b60  1c 4c 0c 80  aa aa bf aa  80 0a 54 55  55 55 ff 5f
00008b70  55 ea ff 57  55 f5 57 ff  15 40 55 ea  af 02 ea ff
00008b80  ff aa 

	;; unknown
8b82  94        sub     h		; 8b94?
8b83  8b        adc     a,e
8b84  14        inc     d
8b85  00        nop     
8b86  00        nop     
8b87  99        sbc     a,c
8b88  8b        adc     a,e
8b89  17        rla     
8b8a  00        nop     
8b8b  00        nop     
8b8c  9f        sbc     a,a
8b8d  8b        adc     a,e
8b8e  1a        ld      a,(de)
8b8f  00        nop     
8b90  00        nop     
8b91  a6        and     (hl)
8b92  8b        adc     a,e
8b93  1d        dec     e

8b94  55        ld      d,l
8b95  40        ld      b,b
8b96  55        ld      d,l
8b97  55        ld      d,l
8b98  bf        cp      a
8b99  aa        xor     d
8b9a  80        add     a,b
8b9b  aa        xor     d
8b9c  aa        xor     d
8b9d  bf        cp      a
8b9e  aa        xor     d
8b9f  aa        xor     d
8ba0  80        add     a,b
8ba1  aa        xor     d
8ba2  02        ld      (bc),a
8ba3  80        add     a,b
8ba4  aa        xor     d
8ba5  aa        xor     d
8ba6  55        ld      d,l
8ba7  00        nop     
8ba8  00        nop     
8ba9  00        nop     
8baa  55        ld      d,l
8bab  55        ld      d,l
8bac  fdaa      xor     d


	;; Maze Table 2
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008ba0                                               40 fc
00008bb0  da 02 de d8  d2 d2 d2 d2  d2 d2 d2 d6  d8 d2 d2 d2
00008bc0  d2 d4 fc fc  fc fc da 02  de d8 d2 d2  d2 d2 d4 fc
00008bd0  da 02 de e4  08 de e4 05  dc fc fc fc  fc da 02 de
00008be0  e4 05 dc fc  da 02 de e4  02 e6 e8 e8  e8 ea 02 de
00008bf0  e4 02 e6 ea  02 e7 d2 d2  d2 d2 eb 02  e7 eb 02 e6

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008c00  ea 02 dc fc  da 02 de e4  02 de f3 e9  e9 eb 02 de
00008c10  e4 02 de e4  0c de e4 02  dc fc da 02  de e4 02 de
00008c20  e4 05 de e4  02 de f2 e8  e8 e8 ea 02  e6 ea 02 e6
00008c30  e8 e8 f4 e4  02 dc fc da  02 e7 eb 02  de e4 02 e6
00008c40  ea 02 e7 eb  02 e7 e9 e9  e9 e9 eb 02  de e4 02 e7
00008c50  e9 e9 e9 eb  02 dc fc da  05 de e4 02  de e4 0c de
00008c60  e4 08 dc fc  fa e8 e8 ea  02 de e4 02  de f2 e8 e8
00008c70  e8 e8 ea 02  e6 e8 e8 ea  02 de f2 e8  e8 ea 02 e6
00008c80  ea 02 dc fc  fb e9 e9 eb  02 e7 eb 02  e7 e9 e9 e9
00008c90  e9 e9 eb 02  e7 e9 f5 e4  02 de f3 e9  e9 eb 02 de
00008ca0  e4 02 dc fc  da 12 de e4  02 de e4 05  de e4 02 dc
00008cb0  fc da 02 e6  ea 02 e6 e8  e8 e8 e8 ea  02 ec d3 d3
00008cc0  d3 ee 02 e7  eb 02 e7 eb  02 e6 ea 02  de e4 02 dc
00008cd0  fc da 02 de  e4 02 e7 e9  e9 e9 f5 e4  02 dc fc fc
00008ce0  fc da 08 de  e4 02 e7 eb  02 dc fc da  02 de e4 06
00008cf0  de e4 02 f0  fc fc fc da  02 e6 e8 e8  e8 ea 02 de

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008d00  e4 05 dc fc  da 02 de f2  e8 e8 e8 ea  02 de e4 02
00008d10  ce fc fc fc  da 02 de c0  c0 c0 e4 02  de f2 e8 e8
00008d20  ea 02 dc 00  00 00 00 66                          


	;; Pellet table 2
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008d20                            01 01 01 01  01 03 01 01
00008d30  01 0b 01 01  07 06 03 03  0a 03 07 06  03 03 01 01
00008d40  01 01 01 01  01 01 01 01  03 07 03 01  01 01 03 07
00008d50  03 06 07 03  03 03 07 03  06 07 03 03  01 01 01 01
00008d60  01 01 01 01  01 01 03 01  01 01 01 01  01 07 03 0d
00008d70  06 03 07 03  0d 06 03 04  01 01 01 01  01 01 0d 03
00008d80  01 01 01 03  04 03 10 03  03 03 04 03  10 01 01 01
00008d90  03 03 04 03  01 01 01 01  12 01 01 01  04 07 15 04
00008da0  07 15 04 03  01 01 01 01  12 01 01 01  04 03 10 01
00008db0  01 01 03 03  04 03 10 03  03 03 04 01  01 01 01 01
00008dc0  01 0d 03 01  01 01 03 07  03 0d 06 03  07 03 0d 06
00008dd0  03 07 03 03  01 01 01 01  01 01 01 01  01 01 03 01
00008de0  01 01 01 01  01 07 03 03  03 07 03 06  07 03 01 01
00008df0  01 03 07 03  06 07 06 03  03 01 01 01  01 01 01 01

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008e00  01 01 01 03  07 06 03 03  0a 03 08 01  01 01 01 01
00008e10  03 01 01 01  0b 01 01                             

	;; number of pellets to eat for map 2
8e17  f4


	;; destination table for map 2
8e18  1d 22 1d 39
8e1c  40 20 40 3b

	;; Power Pellet Table 2
	;; 4065, 407b, 4385, 439b
8e20  65 40
8e22  7b 40
8e24  85 43
8e26  9b 43


	;; unknown Table B
8e28  42 16 0a 16
8e2c  0a 16 0a 20
8e30  20 20 de e0 


	;; fruit paths for map 2:  $8E40-8E72 for map2
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008e30               22 20 20 20  20 16 0a 16  0a 16 00 00

00008e40  54 8e 13 c4  0c 59 8e 1e  c4 f4 61 8e  26 14 f4 6b
00008e50  8e 1d 14 0c  02 aa aa 80  2a 02 40 55  7f 55 15 50
00008e60  05 ea ff 57  55 f5 ff 57  7f 55 05 ea  ff ff ff ea
00008e70  af aa 02 

	;; unknown
8e73  87        add     a,a
8e74  8e        adc     a,(hl)
8e75  12        ld      (de),a
8e76  00        nop     
8e77  00        nop     
8e78  8c        adc     a,h
8e79  8e        adc     a,(hl)
8e7a  1d        dec     e
8e7b  00        nop     
8e7c  00        nop     
8e7d  94        sub     h
8e7e  8e        adc     a,(hl)
8e7f  210000    ld      hl,#0000
8e82  9d        sbc     a,l
8e83  8e        adc     a,(hl)
8e84  2c        inc     l
8e85  00        nop     
8e86  00        nop     
8e87  55        ld      d,l
8e88  7f        ld      a,a
8e89  55        ld      d,l
8e8a  d5        push    de
8e8b  ff        rst     #38
8e8c  aa        xor     d
8e8d  bf        cp      a
8e8e  aa        xor     d
8e8f  2aa0ea    ld      hl,(#eaa0)
8e92  ff        rst     #38
8e93  ff        rst     #38
8e94  aa        xor     d
8e95  2aa002    ld      hl,(#02a0)
8e98  00        nop     
8e99  00        nop     
8e9a  a0        and     b
8e9b  aa        xor     d
8e9c  02        ld      (bc),a
8e9d  55        ld      d,l
8e9e  15        dec     d
8e9f  a0        and     b
8ea0  2a0054    ld      hl,(#5400)
8ea3  05        dec     b
8ea4  00        nop     
8ea5  00        nop     
8ea6  55        ld      d,l
8ea7  fd	; garbage


	;; Maze Table 3
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008ea0                            40 fc d0 d2  d2 d2 d2 d2
00008eb0  d2 d6 e4 02  e7 d2 d2 d2  d2 d2 d2 d2  d2 d2 d2 d6
00008ec0  d8 d2 d2 d2  d2 d2 d2 d2  d4 fc da 07  de e4 0d de
00008ed0  e4 08 dc fc  da 02 e6 e8  e8 ea 02 de  e4 02 e6 e8
00008ee0  e8 ea 02 e6  e8 e8 e8 ea  02 e7 eb 02  e6 ea 02 e6
00008ef0  ea 02 dc fc  da 02 de f3  e9 eb 02 e7  eb 02 e7 e9

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00008f00  f5 e4 02 e7  e9 e9 f5 e4  05 de e4 02  de e4 02 dc
00008f10  fc da 02 de  e4 09 de e4  05 de e4 02  e6 e8 e8 f4
00008f20  e4 02 de e4  02 dc fc da  02 de e4 02  e6 e8 e8 e8
00008f30  e8 ea 02 e7  eb 02 e6 ea  02 e7 eb 02  e7 e9 e9 e9
00008f40  eb 02 e7 eb  02 dc fc da  02 de e4 02  e7 e9 e9 e9
00008f50  f5 e4 05 de  e4 0e dc fc  da 02 de e4  06 de e4 02
00008f60  e6 e8 e8 f4  e4 02 e6 e8  e8 e8 ea 02  e6 e8 e8 e8
00008f70  e8 e8 f4 fc  da 02 e7 eb  02 e6 e8 ea  02 e7 eb 02
00008f80  e7 e9 e9 e9  eb 02 de f3  e9 e9 eb 02  de f3 e9 e9
00008f90  e9 e9 f5 fc  da 05 de c0  e4 0b de e4  05 de e4 05
00008fa0  dc fc fa e8  e8 ea 02 de  c0 e4 02 e6  ea 02 ec d3
00008fb0  d3 d3 ee 02  de e4 02 e6  ea 02 de e4  02 e6 ea 02
00008fc0  dc fc fb e9  e9 eb 02 e7  e9 eb 02 de  e4 02 dc fc
00008fd0  fc fc da 02  e7 eb 02 de  e4 02 e7 eb  02 de e4 02
00008fe0  dc fc da 09  de e4 02 f0  fc fc fc da  05 de e4 05
00008ff0  de e4 02 dc  fc da 02 e6  e8 e8 e8 e8  ea 02 de e4

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00009000  02 ce fc fc  fc da 02 e6  e8 e8 f4 e4  02 e6 e8 e8
00009010  f4 e4 02 dc  00 00 00 00


	;; Pellet table 3
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00009000                            e8 e8 f4 e4  02 e6 e8 e8
00009010  f4 e4 02 dc  00 00 00 00  62 01 02 01  01 03 01 01
00009020  01 01 01 01  01 01 01 01  01 04 01 01  01 01 01 04
00009030  05 03 0b 03  03 03 04 05  03 0b 01 01  01 03 03 04
00009040  03 01 01 01  01 01 0b 06  03 04 03 10  06 03 04 03
00009050  10 01 01 01  01 01 01 01  01 01 04 03  01 01 01 01
00009060  0f 0a 03 04  0f 0a 01 01  01 04 0c 01  01 01 03 01
00009070  01 01 07 04  0c 03 03 03  07 04 0c 03  03 03 04 01
00009080  01 01 01 01  01 01 0c 03  01 01 01 03  04 07 15 04
00009090  07 15 04 01  01 01 01 01  01 01 0c 03  01 01 01 03
000090a0  07 04 0c 03  03 03 07 04  0c 03 03 03  04 01 01 01
000090b0  04 0c 01 01  01 03 01 01  01 04 03 04  0f 0a 03 01
000090c0  01 01 01 0f  0a 03 10 01  01 01 01 01  01 01 01 01
000090d0  04 03 10 06  03 04 03 01  01 01 01 01  0b 06 03 04
000090e0  05 03 0b 01  01 01 03 03  04 05 03 0b  03 03 03 04
000090f0  01 02 01 01  03 01 01 01  01 01 01 01  01 01 01 01

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00009100  04 01 01 01  01 01 00 00  00 


	;; number of pellets to eat for map 3
9109  f2


	;; destination table for map 3
910a  40 2d 1d 22
910e  1d 39 40 20

	;; Power Pellet Table 3
	;; 4064, 4078, 4384, 4398
9112  64 40
9114  78 40
9116  84 43
9118  98 43


	;; fruit paths for map 3:  $911A-9141 for map3

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00009110                                  2e 91  15 54 0c 34
00009120  91 1e 54 f4  34 91 1e 54  f4 3c 91 15  54 0c ea ff
00009130  ab fa aa aa  ea ff 57 55  55 d5 57 55  aa aa bf fa
00009140  bf aa


	;; unknown
9142  56        ld      d,(hl)
9143  91        sub     c
9144  220000    ld      (#0000),hl
9147  5f        ld      e,a
9148  91        sub     c
9149  25        dec     h
914a  00        nop     
914b  00        nop     
914c  5f        ld      e,a
914d  91        sub     c
914e  25        dec     h
914f  00        nop     
9150  00        nop     
9151  6f        ld      l,a
9152  91        sub     c
9153  2800      jr      z,#9155         ; (0)
9155  00        nop     
9156  05        dec     b
9157  00        nop     
9158  00        nop     
9159  54        ld      d,h
915a  05        dec     b
915b  54        ld      d,h
915c  7f        ld      a,a
915d  f5        push    af
915e  0b        dec     bc
915f  0a        ld      a,(bc)
9160  00        nop     
9161  00        nop     
9162  a8        xor     b
9163  0a        ld      a,(bc)
9164  a8        xor     b
9165  bf        cp      a
9166  faabaa    jp      m,#aaab
9169  aa        xor     d
916a  82        add     a,d
916b  aa        xor     d
916c  00        nop     
916d  a0        and     b
916e  aa        xor     d
916f  55        ld      d,l
9170  41        ld      b,c
9171  55        ld      d,l
9172  00        nop     
9173  a0        and     b
9174  02        ld      (bc),a
9175  40        ld      b,b
9176  f5        push    af
9177  57        ld      d,a
9178  bf        cp      a


	;; Maze Table 4
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00009170                               40 fc d0  d2 d2 d2 d2
00009180  d2 d2 d2 d2  d4 fc fc da  02 de e4 02  dc fc fc fc
00009190  fc d0 d2 d2  d2 d2 d2 d2  d2 d4 fc da  09 dc fc fc
000091a0  da 02 de e4  02 dc fc fc  fc fc da 08  dc fc da 02
000091b0  e6 e8 e8 e8  e8 ea 02 e7  d2 d2 eb 02  de e4 02 e7
000091c0  d2 d2 d2 d2  eb 02 e6 e8  e8 e8 ea 02  dc fc da 02
000091d0  e7 e9 e9 e9  f5 e4 07 de  e4 09 de f3  e9 e9 eb 02
000091e0  dc fc da 06  de e4 02 e6  ea 02 e6 e8  f4 f2 e8 ea
000091f0  02 e6 e8 e8  ea 02 de e4  05 dc fc da  02 e6 e8 ea

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00009200  02 e7 eb 02  de e4 02 e7  e9 e9 e9 e9  eb 02 e7 e9
00009210  f5 e4 02 e7  eb 02 e6 ea  02 dc fc da  02 de c0 e4
00009220  05 de e4 0b  de e4 05 de  e4 02 dc fc  da 02 de c0
00009230  e4 02 e6 e8  e8 f4 f2 e8  e8 ea 02 e6  e8 e8 e8 ea
00009240  02 de e4 02  e6 e8 e8 f4  e4 02 dc fc  da 02 e7 e9
00009250  eb 02 e7 e9  e9 f5 f3 e9  e9 eb 02 e7  e9 e9 f5 e4
00009260  02 e7 eb 02  e7 e9 e9 f5  e4 02 dc fc  da 09 de e4
00009270  08 de e4 08  de e4 02 dc  fc da 02 e6  e8 e8 e8 e8
00009280  ea 02 de e4  02 ec d3 d3  d3 ee 02 de  e4 02 e6 e8
00009290  e8 e8 ea 02  de e4 02 dc  fc da 02 de  f3 e9 e9 e9
000092a0  eb 02 e7 eb  02 dc fc fc  fc da 02 e7  eb 02 e7 e9
000092b0  e9 f5 e4 02  e7 eb 02 dc  fc da 02 de  e4 09 f0 fc
000092c0  fc fc da 08  de e4 05 dc  fc da 02 de  e4 02 e6 e8
000092d0  e8 e8 e8 ea  02 ce fc fc  fc da 02 e6  e8 e8 e8 ea
000092e0  02 de e4 02  e6 e8 e8 f4  00 00 00 00  


	;; Pellet table 4
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
000092e0                                         62 01 02 01
000092f0  01 01 01 0f  01 01 01 02  01 04 07 0f  06 04 07 01

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00009300  01 01 07 01  01 01 01 01  06 04 01 01  01 01 03 03
00009310  07 05 03 01  01 01 04 04  03 03 07 05  03 03 04 04
00009320  01 01 01 03  01 01 01 01  01 01 01 01  01 03 01 01
00009330  01 03 04 04  0f 03 06 04  04 0f 03 06  04 01 01 01
00009340  01 01 01 01  0c 01 01 01  01 01 01 03  04 07 12 03
00009350  04 07 12 03  04 03 01 01  01 01 12 01  01 01 04 03
00009360  16 07 03 16  07 03 01 01  01 01 12 01  01 01 04 07
00009370  12 03 04 07  12 03 04 01  01 01 01 01  01 01 0c 01
00009380  01 01 01 01  01 03 04 04  0f 03 06 04  04 0f 03 06
00009390  04 04 01 01  01 03 01 01  01 01 01 01  01 01 01 03
000093a0  01 01 01 03  04 04 03 03  07 05 03 03  04 01 01 01
000093b0  01 03 03 07  05 03 01 01  01 04 07 01  01 01 07 01
000093c0  01 01 01 01  06 04 07 0f  06 04 01 02  01 01 01 01
000093d0  0f 01 01 01  02 01 00 00  00 00 00 00  00 00 00 00
000093e0  00 00 00 00  00 00 00 00  00 00 00 00  00 00 00 00
000093f0  00 00 00 00  00 00 00 00  00


	;; number of pellets to eat for map 4
93f9  ee

	;; Power Pellet Table 4 ?
	;; 4064, 407c, 4384, 439c  
93fa  64 40
93fc  7c 40
93fe  84 43
9400  9c 43

	;; destination table for map 4 ?
9402  1d 22 40 20
9406  1d 39 40 3b

	;; fruit paths for map 4:  $940A-943B for map4
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
00009400                                  1e 94  14 8c 0c 23
00009410  94 1d 8c f4  2b 94 2a 74  f4 36 94 15  74 0c 80 aa
00009420  be fa aa 00  50 fd 55 f5  d5 57 55 ea  ff 57 d5 5f
00009430  fd 15 50 01  50 55 ea af  fe 2a a8 aa 


	;; unknown - unused?
943c  50        ld      d,b
943d  94        sub     h
943e  15        dec     d
943f  00        nop     
9440  00        nop     

9441  56        ld      d,(hl)
9442  94        sub     h
9443  1800      jr      #9445           ; (0)
9445  00        nop     

9446  5c        ld      e,h
9447  94        sub     h
9448  19        add     hl,de
9449  00        nop     
944a  00        nop     

944b  63        ld      h,e
944c  94        sub     h
944d  1c        inc     e
944e  00        nop     
944f  00        nop     

9450  55        ld      d,l
9451  50        ld      d,b
9452  41        ld      b,c
9453  55        ld      d,l
9454  fdaa      xor     d
9456  aa        xor     d
9457  a0        and     b
9458  82        add     a,d
9459  aa        xor     d
945a  feaa      cp      #aa
945c  aa        xor     d
945d  af        xor     a
945e  02        ld      (bc),a
945f  2aa0aa    ld      hl,(#aaa0)
9462  aa        xor     d
9463  55        ld      d,l
9464  5f        ld      e,a
9465  010050    ld      bc,#5000
9468  55        ld      d,l
9469  bf        cp      a

    ;; select the proper maze
946a  217494    ld      hl,#9474	; maze table number
946d  cdbd94    call    #94bd
9470  210040    ld      hl,#4000
9473  c9        ret     

	; maze reference table
9474  c1 88		; maze for map 0
9476  ae 8b		; maze for map 1
9478  a8 8e		; maze for map 2
947a  79 91		; maze for map 3


	; pellet crossreference routine patch
947c  215324    ld      hl,#2453
947f  1803      jr      #9484           ; (3)
9481  219224    ld      hl,#2492
9484  e5        push    hl
9485  219994    ld      hl,#9499	; select pellet map based on map
9488  cdbd94    call    #94bd
948b  fd210000  ld      iy,#0000
948f  fd09      add     iy,bc
9491  210040    ld      hl,#4000
9494  dd21164e  ld      ix,#4e16
9498  c9        ret     

		; Pellet map lookup table
9499  3b 8a		; pellets for map 0
949c  27 8d		; pellets for map 1
949d  18 90		; pellets for map 2
949f  ec 92		; pellets for map 3


	;; check the number of pellets to see if the board is cleared
94a0  c5        push    bc  
94a1  c5	push 	bc
94a2  21b594    ld      hl,#94b5	; pellet count table
94a5  cdbd94    call    #94bd
94a8  0a        ld      a,(bc)
94a9  47        ld      b,a
94aa  3a0e4e    ld      a,(#4e0e)
94ad  b8        cp      b
94ae  c1        pop     bc
94af  c2eb08    jp      nz,#08eb	; return to the game loop? 
94b2  c3e508    jp      #08e5		; return to the clear pellet check

	; data for pellet count information
94b5  2c 8b 		; number of pellets for board 0
94b7  17 8e		; number of pellets for board 1
94b8  09 91		; number of pellets for board 2
94bb  f9 93		; number of pellets for board 3

	;; perhaps a routine to calculate variables according
	;; to the current ms-pac maze number?
94bd  3a134e    ld      a,(#4e13)	; board number
94c0  e5        push    hl
94c1  fe0d      cp      #0d
94c3  f2d494    jp      p,#94d4
94c6  21df94    ld      hl,#94df	; map order table
94c9  d7        rst     #10		; a now contains the map number
94ca  e1        pop     hl		
94cb  87        add     a,a
94cc  4f        ld      c,a
94cd  0600      ld      b,#00
94cf  09        add     hl,bc
94d0  4e        ld      c,(hl)
94d1  23        inc     hl
94d2  46        ld      b,(hl)
94d3  c9        ret     


94d4  d60d      sub     #0d
94d6  d608      sub     #08
94d8  f2d694    jp      p,#94d6
94db  c60d      add     a,#0d
94dd  18e7      jr      #94c6           ; (-25)


	;; map order table... (order that boards are played)
 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
000094d0                                                  00
000094e0  00 01 01 01  02 02 02 02  03 03 03 03



	;; draw routine for the ms-pac power pellets
94ec  211c95    ld      hl,#951c
94ef  cdbd94    call    #94bd		; retrieve values
94f2  11344e    ld      de,#4e34
94f5  69        ld      l,c
94f6  60        ld      h,b		; hl = table offset

94f7  4e        ld      c,(hl)
94f8  23        inc     hl
94f9  46        ld      b,(hl)
94fa  23        inc     hl		; bc = table loc
94fb  1a        ld      a,(de)
94fc  02        ld      (bc),a
94fd  13        inc     de
94fe  3e03      ld      a,#03
9500  a3        and     e
9501  20f4      jr      nz,#94f7        ; (-12)
9503  c9        ret     

	; pellet routine?
9504  211c95    ld      hl,#951c	; pellet lookup table per map
9507  cdbd94    call    #94bd
950a  11344e    ld      de,#4e34
950d  69        ld      l,c
950e  60        ld      h,b
950f  4e        ld      c,(hl)
9510  23        inc     hl
9511  46        ld      b,(hl)
9512  23        inc     hl
9513  0a        ld      a,(bc)
9514  12        ld      (de),a
9515  13        inc     de
9516  3e03      ld      a,#03
9518  a3        and     e
9519  20f4      jr      nz,#950f        ; (-12)
951b  c9        ret     

	; pellet lookup table per map
951c  35 8b				; map 0 pellet address table
951e  20 8e				; map 1 pellet address table
9520  12 91				; map 2 pellet address table
9522  fa 93				; map 3 pellet address table


9524  c5        push    bc
9525  d5        push    de
9526  211c95    ld      hl,#951c	; pellet lookup table
9529  cdbd94    call    #94bd
952c  60        ld      h,b
952d  69        ld      l,c
952e  5e        ld      e,(hl)
952f  23        inc     hl
9530  56        ld      d,(hl)
9531  eb        ex      de,hl
9532  cbd4      set     2,h

9534  3a7e44    ld      a,(#447e)
9537  be        cp      (hl)
9538  2002      jr      nz,#953c        ; (2)
953a  3e00      ld      a,#00
953c  77        ld      (hl),a
953d  eb        ex      de,hl
953e  23        inc     hl
953f  5e        ld      e,(hl)
9540  23        inc     hl
9541  56        ld      d,(hl)
9542  cbd2      set     2,d
9544  12        ld      (de),a
9545  23        inc     hl
9546  5e        ld      e,(hl)
9547  23        inc     hl
9548  56        ld      d,(hl)
9549  cbd2      set     2,d
954b  12        ld      (de),a
954c  23        inc     hl
954d  5e        ld      e,(hl)
954e  23        inc     hl
954f  56        ld      d,(hl)
9550  cbd2      set     2,d
9552  12        ld      (de),a
9553  d1        pop     de
9554  c1        pop     bc
9555  3e10      ld      a,#10
9557  be        cp      (hl)
9558  c9        ret     

9559  3a2e4d    ld      a,(#4d2e)
955c  1803      jr      #9561           ; (3)
955e  3a2f4d    ld      a,(#4d2f)


	;; pick a quadrant for the destination of a ghost
9561  f5        push    af
9562  c5        push    bc
9563  e5        push    hl
9564  217895    ld      hl,#9578	; ghost destination table
9567  cdbd94    call    #94bd
956a  69        ld      l,c
956b  60        ld      h,b
956c  ed5f      ld      a,r
956e  e606      and     #06
9570  d7        rst     #10
9571  5f        ld      e,a
9572  23        inc     hl
9573  56        ld      d,(hl)
9574  e1        pop     hl
9575  c1        pop     bc
9576  f1        pop     af
9577  c9        ret     

	; ghost destination table
9578  2d 8b
957a  18 8e
957c  0a 91
957e  02 94

	; maze color code (jp from 24dd)
9580  cae124    jp      z,#24e1
9583  3a024e    ld      a,(#4e02)
9586  a7        and     a
9587  2807      jr      z,#9590         ; (7)
9589  fe10      cp      #10
958b  3e01      ld      a,#01
958d  c2e124    jp      nz,#24e1
9590  3a134e    ld      a,(#4e13)
9593  fe15      cp      #15
9595  f2a395    jp      p,#95a3

9598  4f        ld      c,a
9599  0600      ld      b,#00
959b  21ae95    ld      hl,#95ae	; map color table
959e  09        add     hl,bc
959f  7e        ld      a,(hl)		; a contains the maze color
95a0  c3e124    jp      #24e1

95a3  d615      sub     #15
95a5  d610      sub     #10
95a7  f2a595    jp      p,#95a5
95aa  c615      add     a,#15
95ac  18ea      jr      #9598           ; (-22)


	;; color palette table for the first 21 mazes

 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f
000095a0                                               1d 1d
000095b0  16 16 16 14  14 14 14 07  07 07 07 18  18 18 18 1d
000095c0  1d 1d 1d 


95c3  3a134e    ld      a,(#4e13)	; current board number
95c6  fe03      cp      #03
95c8  f23425    jp      p,#2534
95cb  21df95    ld      hl,#95df	; Unknown table A/B
95ce  cdbd94    call    #94bd
95d1  210044    ld      hl,#4400
95d4  0a        ld      a,(bc)
95d5  03        inc     bc
95d6  a7        and     a
95d7  ca3425    jp      z,#2534
95da  d7        rst     #10
95db  cbf6      set     6,(hl)
95dd  18f5      jr      #95d4           ; (-11)


	; table
95df  3d 8b		; unknown Table A
95e1  28 8e		; unknown Table B

	; Uncalled? - possible original patch unused
95e3  78        ld      a,b
95e4  fe0a      cp      #0a
95e6  cc0b96    call    z,#960b
95e9  fe0b      cp      #0b
95eb  ccf695    call    z,#95f6
95ee  fe06      cp      #06
95f0  cc3c96    call    z,#963c
95f3  c35e2c    jp      #2c5e		; print

	; draw the midway logo and text for the 'press start' screen
95f6  c5        push    bc
95f7  e5        push    hl
95f8  cd4296    call    #9642
95fb  e1        pop     hl
95fc  c1        pop     bc

	; check for start button press
95fd  3a8050    ld      a,(#5080)	;; check in0
9600  e630      and     #30
9602  fe30      cp      #30
9604  78        ld      a,b
9605  c0        ret     nz

9606  3e20      ld      a,#20
9608  0620      ld      b,#20
960a  c9        ret     

	; table subroutine
960b  c5        push    bc
960c  e5        push    hl
960d  211696    ld      hl,#9616
9610  cd2796    call    #9627
9613  e1        pop     hl
9614  c1        pop     bc
9615  c9        ret     

	; table of some kind
9616  09        add     hl,bc
9617  20f5      jr      nz,#960e        ; (-11)
9619  41        ld      b,c

961a  09        add     hl,bc
961b  211542    ld      hl,#4215

961e  09        add     hl,bc
961f  22f641    ld      (#41f6),hl

9622  09        add     hl,bc
9623  23        inc     hl
9624  1642      ld      d,#42
9626  ff        rst     #38

	; subroutine for start button press?
9627  7e        ld      a,(hl)
9628  feff      cp      #ff
962a  280f      jr      z,#963b         ; (15)
962c  47        ld      b,a
962d  23        inc     hl
962e  7e        ld      a,(hl)
962f  23        inc     hl
9630  5e        ld      e,(hl)
9631  23        inc     hl
9632  56        ld      d,(hl)
9633  12        ld      (de),a
9634  78        ld      a,b
9635  cbd2      set     2,d
9637  12        ld      (de),a
9638  23        inc     hl
9639  18ec      jr      #9627           ; (-20)
963b  c9        ret     

	; subroutine
963c  3e00      ld      a,#00
963e  32004f    ld      (#4f00),a
9641  c9        ret     

    ; dereferencing for title screen logo and text
9642  ef        rst     #28		; Midway mfg co
9643  1c13
9645  ef        rst     #28		; 1980/1981
9646  1c35
9648  c9        ret     		; somehow, this also calls the below

	; draw the Midway logo out to the screen
9649  9a        sbc     a,d		; ret from here, and it draws, but wrong
964a  42        ld      b,d		; ret from here, and it doesn't draw

    ; this draws vertical strips, starting with the rightmost
964b  3ebf      ld      a,#bf
964d  a7        and     a
964e  111d00    ld      de,#001d
9651  010004    ld      bc,#0400
9654  77        ld      (hl),a
9655  09        add     hl,bc
9656  3601      ld      (hl),#01
9658  ed42      sbc     hl,bc
965a  23        inc     hl
965b  d604      sub     #04
965d  77        ld      (hl),a
965e  09        add     hl,bc
965f  3601      ld      (hl),#01
9661  ed42      sbc     hl,bc
9663  23        inc     hl
9664  d604      sub     #04
9666  77        ld      (hl),a
9667  09        add     hl,bc
9668  3601      ld      (hl),#01
966a  ed42      sbc     hl,bc
966c  23        inc     hl
966d  d604      sub     #04
966f  77        ld      (hl),a
9670  09        add     hl,bc
9671  3601      ld      (hl),#01
9673  ed42      sbc     hl,bc
9675  19        add     hl,de
9676  c60b      add     a,#0b
9678  febb      cp      #bb
967a  20d8      jr      nz,#9654        ; (-40)
967c  c9        ret     

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


	; something with sprites for cocktail?
9797  3a004f    ld      a,(#4f00)
979a  fe00      cp      #00
979c  280b      jr      z,#97a9         ; (11)
979e  11024c    ld      de,#4c02
97a1  21504f    ld      hl,#4f50
97a4  010c00    ld      bc,#000c
97a7  edb0      ldir    
97a9  3a094e    ld      a,(#4e09)
97ac  21724e    ld      hl,#4e72
97af  a6        and     (hl)
97b0  280c      jr      z,#97be         ; (12)
97b2  3a0a4c    ld      a,(#4c0a)	; mspac sprite number
97b5  fe3f      cp      #3f
97b7  2005      jr      nz,#97be        ; (5)
97b9  3eff      ld      a,#ff
97bb  320a4c    ld      (#4c0a),a	; mspac sprite number
97be  218596    ld      hl,#9685
97c1  c3c42c    jp      #2cc4

	; unused?
97c4  ff        rst     #38
97c5  ff        rst     #38
97c6  ff        rst     #38
97c7  ff        rst     #38
97c8  ff        rst     #38
97c9  ff        rst     #38
97ca  ff        rst     #38
97cb  ff        rst     #38
97cc  ff        rst     #38
97cd  ff        rst     #38
97ce  ff        rst     #38
97cf  ff        rst     #38



 offset    0  1  2  3   4  5  6  7   8  9  a  b   c  d  e  f  0123456789abcdef
000097d0  47 45 4e 45  52 41 4c 20  43 4f 4d 50  55 54 45 52  GENERAL COMPUTER
000097e0  20 20 43 4f  52 50 4f 52  41 54 49 4f  4e 20 20 20    CORPORATION
000097f0  48 65 6c 6c  6f 2c 20 4e  61 6b 61 6d  75 72 61 21  Hello, Nakamura!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  9800 - 9fff is not used  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;; unknown
9800  828b 
9802  73        ld      (hl),e
9803  8e        adc     a,(hl)
9804  42        ld      b,d
9805  91        sub     c
9806  3c        inc     a
9807  94        sub     h
9808  faff55    jp      m,#55ff
980b  55        ld      d,l
980c  0180aa    ld      bc,#aa80
980f  02        ld      (bc),a
9810  3e00      ld      a,#00
9812  320d4c    ld      (#4c0d),a
9815  c30010    jp      #1000
9818  f5        push    af
9819  ed5bd24d  ld      de,(#4dd2)
981d  7c        ld      a,h
981e  92        sub     d
981f  c603      add     a,#03
9821  fe06      cp      #06
9823  3018      jr      nc,#083d        ; (24)
9825  7d        ld      a,l
9826  93        sub     e
9827  c603      add     a,#03
9829  fe06      cp      #06
982b  3010      jr      nc,#083d        ; (16)
982d  3e01      ld      a,#01
982f  320d4c    ld      (#4c0d),a
9832  f1        pop     af
9833  c602      add     a,#02
9835  320c4c    ld      (#4c0c),a
9838  d602      sub     #02
983a  c3b219    jp      #19b2
983d  f1        pop     af
983e  c3cd19    jp      #19cd
9841  ff        rst     #38
9842  ff        rst     #38
9843  ff        rst     #38
9844  ff        rst     #38
9845  ff        rst     #38
9846  ff        rst     #38
9847  ff        rst     #38
9848  ff        rst     #38
9849  ff        rst     #38
984a  ff        rst     #38
984b  ff        rst     #38
984c  ff        rst     #38
984d  ff        rst     #38
984e  ff        rst     #38
984f  ff        rst     #38
9850  ff        rst     #38
9851  ff        rst     #38
9852  ff        rst     #38
9853  00        nop     
9854  00        nop     
9855  ff        rst     #38
9856  ff        rst     #38
9857  00        nop     
9858  00        nop     
9859  00        nop     
985a  00        nop     
985b  010000    ld      bc,#0000
985e  00        nop     
985f  010000    ld      bc,#0000
9862  00        nop     
9863  ff        rst     #38
9864  fe00      cp      #00
9866  00        nop     
9867  00        nop     
9868  ff        rst     #38
9869  00        nop     
986a  00        nop     
986b  ff        rst     #38
986c  fe00      cp      #00
986e  00        nop     
986f  00        nop     
9870  ff        rst     #38
9871  00        nop     
9872  00        nop     
9873  00        nop     
9874  ff        rst     #38
9875  00        nop     
9876  00        nop     
9877  00        nop     
9878  ff        rst     #38
9879  00        nop     
987a  00        nop     
987b  01ff01    ld      bc,#01ff
987e  ff        rst     #38
987f  00        nop     
9880  00        nop     
9881  00        nop     
9882  00        nop     
9883  00        nop     
9884  00        nop     
9885  ff        rst     #38
9886  00        nop     
9887  00        nop     
9888  00        nop     
9889  00        nop     
988a  010000    ld      bc,#0000
988d  ff        rst     #38
988e  00        nop     
988f  00        nop     
9890  00        nop     
9891  00        nop     
9892  010000    ld      bc,#0000
9895  00        nop     
9896  010000    ld      bc,#0000
9899  00        nop     
989a  010000    ld      bc,#0000
989d  010101    ld      bc,#0101
98a0  010000    ld      bc,#0000
98a3  010001    ld      bc,#0100
98a6  00        nop     
98a7  010001    ld      bc,#0100
98aa  00        nop     
98ab  010001    ld      bc,#0100
98ae  00        nop     
98af  010001    ld      bc,#0100
98b2  00        nop     
98b3  010001    ld      bc,#0100
98b6  00        nop     
98b7  0100ff    ld      bc,#ff00
98ba  ff        rst     #38
98bb  ff        rst     #38
98bc  ff        rst     #38
98bd  00        nop     
98be  00        nop     
98bf  ff        rst     #38
98c0  ff        rst     #38
98c1  40        ld      b,b
98c2  fcd0d2    call    m,#d2d0
98c5  d2d2d2    jp      nc,#d2d2
98c8  d4fcda    call    nc,#dafc
98cb  02        ld      (bc),a
98cc  dcfcfc    call    c,#fcfc
98cf  fcfcfc    call    m,#fcfc
98d2  fcda02    call    m,#02da
98d5  dcfcfc    call    c,#fcfc
98d8  fcd0d2    call    m,#d2d0
98db  d2d2d2    jp      nc,#d2d2
98de  d2d2d2    jp      nc,#d2d2
98e1  d4fcda    call    nc,#dafc
98e4  05        dec     b
98e5  dcfcda    call    c,#dafc
98e8  02        ld      (bc),a
98e9  dcfcfc    call    c,#fcfc
98ec  fcfcfc    call    m,#fcfc
98ef  fcda02    call    m,#02da
98f2  dcfcfc    call    c,#fcfc
98f5  fcda08    call    m,#08da
98f8  dcfcda    call    c,#dafc
98fb  02        ld      (bc),a
98fc  e6ea      and     #ea
98fe  02        ld      (bc),a
98ff  e7        rst     #20
9900  d2eb02    jp      nc,#02eb
9903  e7        rst     #20
9904  d2d2d2    jp      nc,#d2d2
9907  d2d2d2    jp      nc,#d2d2
990a  eb        ex      de,hl
990b  02        ld      (bc),a
990c  e7        rst     #20
990d  d2d2d2    jp      nc,#d2d2
9910  eb        ex      de,hl
9911  02        ld      (bc),a
9912  e6e8      and     #e8
9914  e8        ret     pe

9915  e8        ret     pe

9916  ea02dc    jp      pe,#dc02
9919  fcda02    call    m,#02da
991c  dee4      sbc     a,#e4
991e  15        dec     d
991f  dec0      sbc     a,#c0
9921  c0        ret     nz

9922  c0        ret     nz

9923  e402dc    call    po,#dc02
9926  fcda02    call    m,#02da
9929  dee4      sbc     a,#e4
992b  02        ld      (bc),a
992c  e6e8      and     #e8
992e  e8        ret     pe

992f  e8        ret     pe

9930  e8        ret     pe

9931  ea02e6    jp      pe,#e602
9934  e8        ret     pe

9935  e8        ret     pe

9936  e8        ret     pe

9937  ea02e6    jp      pe,#e602
993a  ea02e6    jp      pe,#e602
993d  ea02de    jp      pe,#de02
9940  c0        ret     nz

9941  c0        ret     nz

9942  c0        ret     nz

9943  e402dc    call    po,#dc02
9946  fcda02    call    m,#02da
9949  e7        rst     #20
994a  eb        ex      de,hl
994b  02        ld      (bc),a
994c  e7        rst     #20
994d  e9        jp      (hl)
994e  e9        jp      (hl)
994f  e9        jp      (hl)
9950  f5        push    af
9951  e402de    call    po,#de02
9954  f3        di      
9955  e9        jp      (hl)
9956  e9        jp      (hl)
9957  eb        ex      de,hl
9958  02        ld      (bc),a
9959  dee4      sbc     a,#e4
995b  02        ld      (bc),a
995c  dee4      sbc     a,#e4
995e  02        ld      (bc),a
995f  e7        rst     #20
9960  e9        jp      (hl)
9961  e9        jp      (hl)
9962  e9        jp      (hl)
9963  eb        ex      de,hl
9964  02        ld      (bc),a
9965  dcfcda    call    c,#dafc
9968  09        add     hl,bc
9969  dee4      sbc     a,#e4
996b  02        ld      (bc),a
996c  dee4      sbc     a,#e4
996e  05        dec     b
996f  dee4      sbc     a,#e4
9971  02        ld      (bc),a
9972  dee4      sbc     a,#e4
9974  08        ex      af,af'
9975  dcfcfa    call    c,#fafc
9978  e8        ret     pe

9979  e8        ret     pe

997a  ea02e6    jp      pe,#e602
997d  e8        ret     pe

997e  ea02de    jp      pe,#de02
9981  e402de    call    po,#de02
9984  e402e6    call    po,#e602
9987  e8        ret     pe

9988  e8        ret     pe

9989  f4e402    call    p,#02e4
998c  dee4      sbc     a,#e4
998e  02        ld      (bc),a
998f  e6e8      and     #e8
9991  e8        ret     pe

9992  e8        ret     pe

9993  ea02dc    jp      pe,#dc02
9996  fcfbe9    call    m,#e9fb
9999  e9        jp      (hl)
999a  eb        ex      de,hl
999b  02        ld      (bc),a
999c  dec0      sbc     a,#c0
999e  e402e7    call    po,#e702
99a1  eb        ex      de,hl
99a2  02        ld      (bc),a
99a3  e7        rst     #20
99a4  eb        ex      de,hl
99a5  02        ld      (bc),a
99a6  e7        rst     #20
99a7  e9        jp      (hl)
99a8  e9        jp      (hl)
99a9  f5        push    af
99aa  e402e7    call    po,#e702
99ad  eb        ex      de,hl
99ae  02        ld      (bc),a
99af  def3      sbc     a,#f3
99b1  e9        jp      (hl)
99b2  e9        jp      (hl)
99b3  eb        ex      de,hl
99b4  02        ld      (bc),a
99b5  dcfcda    call    c,#dafc
99b8  05        dec     b
99b9  dec0      sbc     a,#c0
99bb  e40bde    call    po,#de0b
99be  e405de    call    po,#de05
99c1  e405dc    call    po,#dc05
99c4  fcda02    call    m,#02da
99c7  e6ea      and     #ea
99c9  02        ld      (bc),a
99ca  dec0      sbc     a,#c0
99cc  e402e6    call    po,#e602
99cf  ea02ec    jp      pe,#ec02
99d2  d3d3      out     (#d3),a
99d4  d3ee      out     (#ee),a
99d6  02        ld      (bc),a
99d7  dee4      sbc     a,#e4
99d9  02        ld      (bc),a
99da  e6ea      and     #ea
99dc  02        ld      (bc),a
99dd  dee4      sbc     a,#e4
99df  02        ld      (bc),a
99e0  e6ea      and     #ea
99e2  02        ld      (bc),a
99e3  dcfcda    call    c,#dafc
99e6  02        ld      (bc),a
99e7  dee4      sbc     a,#e4
99e9  02        ld      (bc),a
99ea  e7        rst     #20
99eb  e9        jp      (hl)
99ec  eb        ex      de,hl
99ed  02        ld      (bc),a
99ee  dee4      sbc     a,#e4
99f0  02        ld      (bc),a
99f1  dcfcfc    call    c,#fcfc
99f4  fcda02    call    m,#02da
99f7  e7        rst     #20
99f8  eb        ex      de,hl
99f9  02        ld      (bc),a
99fa  dee4      sbc     a,#e4
99fc  02        ld      (bc),a
99fd  e7        rst     #20
99fe  eb        ex      de,hl
99ff  02        ld      (bc),a
9a00  dee4      sbc     a,#e4
9a02  02        ld      (bc),a
9a03  dcfcda    call    c,#dafc
9a06  02        ld      (bc),a
9a07  dee4      sbc     a,#e4
9a09  06de      ld      b,#de
9a0b  e402f0    call    po,#f002
9a0e  fcfcfc    call    m,#fcfc
9a11  da05de    jp      c,#de05
9a14  e405de    call    po,#de05
9a17  e402dc    call    po,#dc02
9a1a  fcda02    call    m,#02da
9a1d  dee4      sbc     a,#e4
9a1f  02        ld      (bc),a
9a20  e6e8      and     #e8
9a22  e8        ret     pe

9a23  e8        ret     pe

9a24  f4e402    call    p,#02e4
9a27  cefc      adc     a,#fc
9a29  fcfcda    call    m,#dafc
9a2c  02        ld      (bc),a
9a2d  e6e8      and     #e8
9a2f  e8        ret     pe

9a30  f4e402    call    p,#02e4
9a33  e6e8      and     #e8
9a35  e8        ret     pe

9a36  f4e402    call    p,#02e4
9a39  dc0062    call    c,#6200
9a3c  02        ld      (bc),a
9a3d  011301    ld      bc,#0113
9a40  010102    ld      bc,#0201
9a43  010403    ld      bc,#0304
9a46  13        inc     de
9a47  0604      ld      b,#04
9a49  03        inc     bc
9a4a  010101    ld      bc,#0101
9a4d  010101    ld      bc,#0101
9a50  010101    ld      bc,#0101
9a53  010101    ld      bc,#0101
9a56  010101    ld      bc,#0101
9a59  010101    ld      bc,#0101
9a5c  010604    ld      bc,#0406
9a5f  03        inc     bc
9a60  1003      djnz    #0a65           ; (3)
9a62  0604      ld      b,#04
9a64  03        inc     bc
9a65  1003      djnz    #0a6a           ; (3)
9a67  0604      ld      b,#04
9a69  010101    ld      bc,#0101
9a6c  010101    ld      bc,#0101
9a6f  010c03    ld      bc,#030c
9a72  010101    ld      bc,#0101
9a75  010101    ld      bc,#0101
9a78  07        rlca    
9a79  04        inc     b
9a7a  0c        inc     c
9a7b  03        inc     bc
9a7c  0607      ld      b,#07
9a7e  04        inc     b
9a7f  0c        inc     c
9a80  03        inc     bc
9a81  0604      ld      b,#04
9a83  010101    ld      bc,#0101
9a86  04        inc     b
9a87  0c        inc     c
9a88  010101    ld      bc,#0101
9a8b  03        inc     bc
9a8c  010101    ld      bc,#0101
9a8f  04        inc     b
9a90  03        inc     bc
9a91  04        inc     b
9a92  0f        rrca    
9a93  03        inc     bc
9a94  03        inc     bc
9a95  04        inc     b
9a96  03        inc     bc
9a97  04        inc     b
9a98  0f        rrca    
9a99  03        inc     bc
9a9a  03        inc     bc
9a9b  04        inc     b
9a9c  03        inc     bc
9a9d  010101    ld      bc,#0101
9aa0  010f01    ld      bc,#010f
9aa3  010103    ld      bc,#0301
9aa6  04        inc     b
9aa7  03        inc     bc
9aa8  19        add     hl,de
9aa9  04        inc     b
9aaa  03        inc     bc
9aab  19        add     hl,de
9aac  04        inc     b
9aad  03        inc     bc
9aae  010101    ld      bc,#0101
9ab1  010f01    ld      bc,#010f
9ab4  010103    ld      bc,#0301
9ab7  04        inc     b
9ab8  03        inc     bc
9ab9  04        inc     b
9aba  0f        rrca    
9abb  03        inc     bc
9abc  03        inc     bc
9abd  04        inc     b
9abe  03        inc     bc
9abf  04        inc     b
9ac0  0f        rrca    
9ac1  03        inc     bc
9ac2  03        inc     bc
9ac3  04        inc     b
9ac4  010101    ld      bc,#0101
9ac7  04        inc     b
9ac8  0c        inc     c
9ac9  010101    ld      bc,#0101
9acc  03        inc     bc
9acd  010101    ld      bc,#0101
9ad0  07        rlca    
9ad1  04        inc     b
9ad2  0c        inc     c
9ad3  03        inc     bc
9ad4  0607      ld      b,#07
9ad6  04        inc     b
9ad7  0c        inc     c
9ad8  03        inc     bc
9ad9  0604      ld      b,#04
9adb  010101    ld      bc,#0101
9ade  010101    ld      bc,#0101
9ae1  010c03    ld      bc,#030c
9ae4  010101    ld      bc,#0101
9ae7  010101    ld      bc,#0101
9aea  04        inc     b
9aeb  03        inc     bc
9aec  1003      djnz    #0af1           ; (3)
9aee  0604      ld      b,#04
9af0  03        inc     bc
9af1  1003      djnz    #0af6           ; (3)
9af3  0604      ld      b,#04
9af5  03        inc     bc
9af6  010101    ld      bc,#0101
9af9  010101    ld      bc,#0101
9afc  010101    ld      bc,#0101
9aff  010101    ld      bc,#0101
9b02  010101    ld      bc,#0101
9b05  010101    ld      bc,#0101
9b08  010604    ld      bc,#0406
9b0b  03        inc     bc
9b0c  13        inc     de
9b0d  0604      ld      b,#04
9b0f  02        ld      (bc),a
9b10  011301    ld      bc,#0113
9b13  010102    ld      bc,#0201
9b16  010000    ld      bc,#0000
9b19  00        nop     
9b1a  00        nop     
9b1b  00        nop     
9b1c  00        nop     
9b1d  00        nop     
9b1e  00        nop     
9b1f  00        nop     
9b20  00        nop     
9b21  00        nop     
9b22  00        nop     
9b23  00        nop     
9b24  00        nop     
9b25  00        nop     
9b26  00        nop     
9b27  00        nop     
9b28  00        nop     
9b29  00        nop     
9b2a  00        nop     
9b2b  00        nop     
9b2c  e0        ret     po

9b2d  1d        dec     e
9b2e  221d39    ld      (#391d),hl
9b31  40        ld      b,b
9b32  2040      jr      nz,#0b74        ; (64)
9b34  3b        dec     sp
9b35  63        ld      h,e
9b36  40        ld      b,b
9b37  7c        ld      a,h
9b38  40        ld      b,b
9b39  83        add     a,e
9b3a  43        ld      b,e
9b3b  9c        sbc     a,h
9b3c  43        ld      b,e
9b3d  49        ld      c,c
9b3e  09        add     hl,bc
9b3f  17        rla     
9b40  09        add     hl,bc
9b41  17        rla     
9b42  09        add     hl,bc
9b43  0ee0      ld      c,#e0
9b45  e0        ret     po

9b46  e0        ret     po

9b47  29        add     hl,hl
9b48  09        add     hl,bc
9b49  17        rla     
9b4a  09        add     hl,bc
9b4b  17        rla     
9b4c  09        add     hl,bc
9b4d  00        nop     
9b4e  00        nop     
9b4f  63        ld      h,e
9b50  8b        adc     a,e
9b51  13        inc     de
9b52  94        sub     h
9b53  0c        inc     c
9b54  68        ld      l,b
9b55  8b        adc     a,e
9b56  2294f4    ld      (#f494),hl
9b59  71        ld      (hl),c
9b5a  8b        adc     a,e
9b5b  27        daa     
9b5c  4c        ld      c,h
9b5d  f47b8b    call    p,#8b7b
9b60  1c        inc     e
9b61  4c        ld      c,h
9b62  0c        inc     c
9b63  80        add     a,b
9b64  aa        xor     d
9b65  aa        xor     d
9b66  bf        cp      a
9b67  aa        xor     d
9b68  80        add     a,b
9b69  0a        ld      a,(bc)
9b6a  54        ld      d,h
9b6b  55        ld      d,l
9b6c  55        ld      d,l
9b6d  55        ld      d,l
9b6e  ff        rst     #38
9b6f  5f        ld      e,a
9b70  55        ld      d,l
9b71  eaff57    jp      pe,#57ff
9b74  55        ld      d,l
9b75  f5        push    af
9b76  57        ld      d,a
9b77  ff        rst     #38
9b78  15        dec     d
9b79  40        ld      b,b
9b7a  55        ld      d,l
9b7b  eaaf02    jp      pe,#02af
9b7e  eaffff    jp      pe,#ffff
9b81  aa        xor     d
9b82  94        sub     h
9b83  8b        adc     a,e
9b84  14        inc     d
9b85  00        nop     
9b86  00        nop     
9b87  99        sbc     a,c
9b88  8b        adc     a,e
9b89  17        rla     
9b8a  00        nop     
9b8b  00        nop     
9b8c  9f        sbc     a,a
9b8d  8b        adc     a,e
9b8e  1a        ld      a,(de)
9b8f  00        nop     
9b90  00        nop     
9b91  a6        and     (hl)
9b92  8b        adc     a,e
9b93  1d        dec     e
9b94  55        ld      d,l
9b95  40        ld      b,b
9b96  55        ld      d,l
9b97  55        ld      d,l
9b98  bf        cp      a
9b99  aa        xor     d
9b9a  80        add     a,b
9b9b  aa        xor     d
9b9c  aa        xor     d
9b9d  bf        cp      a
9b9e  aa        xor     d
9b9f  aa        xor     d
9ba0  80        add     a,b
9ba1  aa        xor     d
9ba2  02        ld      (bc),a
9ba3  80        add     a,b
9ba4  aa        xor     d
9ba5  aa        xor     d
9ba6  55        ld      d,l
9ba7  00        nop     
9ba8  00        nop     
9ba9  00        nop     
9baa  55        ld      d,l
9bab  55        ld      d,l
9bac  fdaa      xor     d
9bae  40        ld      b,b
9baf  fcda02    call    m,#02da
9bb2  ded8      sbc     a,#d8
9bb4  d2d2d2    jp      nc,#d2d2
9bb7  d2d2d2    jp      nc,#d2d2
9bba  d2d6d8    jp      nc,#d8d6
9bbd  d2d2d2    jp      nc,#d2d2
9bc0  d2d4fc    jp      nc,#fcd4
9bc3  fcfcfc    call    m,#fcfc
9bc6  da02de    jp      c,#de02
9bc9  d8        ret     c

9bca  d2d2d2    jp      nc,#d2d2
9bcd  d2d4fc    jp      nc,#fcd4
9bd0  da02de    jp      c,#de02
9bd3  e408de    call    po,#de08
9bd6  e405dc    call    po,#dc05
9bd9  fcfcfc    call    m,#fcfc
9bdc  fcda02    call    m,#02da
9bdf  dee4      sbc     a,#e4
9be1  05        dec     b
9be2  dcfcda    call    c,#dafc
9be5  02        ld      (bc),a
9be6  dee4      sbc     a,#e4
9be8  02        ld      (bc),a
9be9  e6e8      and     #e8
9beb  e8        ret     pe

9bec  e8        ret     pe

9bed  ea02de    jp      pe,#de02
9bf0  e402e6    call    po,#e602
9bf3  ea02e7    jp      pe,#e702
9bf6  d2d2d2    jp      nc,#d2d2
9bf9  d2eb02    jp      nc,#02eb
9bfc  e7        rst     #20
9bfd  eb        ex      de,hl
9bfe  02        ld      (bc),a
9bff  e6ea      and     #ea
9c01  02        ld      (bc),a
9c02  dcfcda    call    c,#dafc
9c05  02        ld      (bc),a
9c06  dee4      sbc     a,#e4
9c08  02        ld      (bc),a
9c09  def3      sbc     a,#f3
9c0b  e9        jp      (hl)
9c0c  e9        jp      (hl)
9c0d  eb        ex      de,hl
9c0e  02        ld      (bc),a
9c0f  dee4      sbc     a,#e4
9c11  02        ld      (bc),a
9c12  dee4      sbc     a,#e4
9c14  0c        inc     c
9c15  dee4      sbc     a,#e4
9c17  02        ld      (bc),a
9c18  dcfcda    call    c,#dafc
9c1b  02        ld      (bc),a
9c1c  dee4      sbc     a,#e4
9c1e  02        ld      (bc),a
9c1f  dee4      sbc     a,#e4
9c21  05        dec     b
9c22  dee4      sbc     a,#e4
9c24  02        ld      (bc),a
9c25  def2      sbc     a,#f2
9c27  e8        ret     pe

9c28  e8        ret     pe

9c29  e8        ret     pe

9c2a  ea02e6    jp      pe,#e602
9c2d  ea02e6    jp      pe,#e602
9c30  e8        ret     pe

9c31  e8        ret     pe

9c32  f4e402    call    p,#02e4
9c35  dcfcda    call    c,#dafc
9c38  02        ld      (bc),a
9c39  e7        rst     #20
9c3a  eb        ex      de,hl
9c3b  02        ld      (bc),a
9c3c  dee4      sbc     a,#e4
9c3e  02        ld      (bc),a
9c3f  e6ea      and     #ea
9c41  02        ld      (bc),a
9c42  e7        rst     #20
9c43  eb        ex      de,hl
9c44  02        ld      (bc),a
9c45  e7        rst     #20
9c46  e9        jp      (hl)
9c47  e9        jp      (hl)
9c48  e9        jp      (hl)
9c49  e9        jp      (hl)
9c4a  eb        ex      de,hl
9c4b  02        ld      (bc),a
9c4c  dee4      sbc     a,#e4
9c4e  02        ld      (bc),a
9c4f  e7        rst     #20
9c50  e9        jp      (hl)
9c51  e9        jp      (hl)
9c52  e9        jp      (hl)
9c53  eb        ex      de,hl
9c54  02        ld      (bc),a
9c55  dcfcda    call    c,#dafc
9c58  05        dec     b
9c59  dee4      sbc     a,#e4
9c5b  02        ld      (bc),a
9c5c  dee4      sbc     a,#e4
9c5e  0c        inc     c
9c5f  dee4      sbc     a,#e4
9c61  08        ex      af,af'
9c62  dcfcfa    call    c,#fafc
9c65  e8        ret     pe

9c66  e8        ret     pe

9c67  ea02de    jp      pe,#de02
9c6a  e402de    call    po,#de02
9c6d  f2e8e8    jp      p,#e8e8
9c70  e8        ret     pe

9c71  e8        ret     pe

9c72  ea02e6    jp      pe,#e602
9c75  e8        ret     pe

9c76  e8        ret     pe

9c77  ea02de    jp      pe,#de02
9c7a  f2e8e8    jp      p,#e8e8
9c7d  ea02e6    jp      pe,#e602
9c80  ea02dc    jp      pe,#dc02
9c83  fcfbe9    call    m,#e9fb
9c86  e9        jp      (hl)
9c87  eb        ex      de,hl
9c88  02        ld      (bc),a
9c89  e7        rst     #20
9c8a  eb        ex      de,hl
9c8b  02        ld      (bc),a
9c8c  e7        rst     #20
9c8d  e9        jp      (hl)
9c8e  e9        jp      (hl)
9c8f  e9        jp      (hl)
9c90  e9        jp      (hl)
9c91  e9        jp      (hl)
9c92  eb        ex      de,hl
9c93  02        ld      (bc),a
9c94  e7        rst     #20
9c95  e9        jp      (hl)
9c96  f5        push    af
9c97  e402de    call    po,#de02
9c9a  f3        di      
9c9b  e9        jp      (hl)
9c9c  e9        jp      (hl)
9c9d  eb        ex      de,hl
9c9e  02        ld      (bc),a
9c9f  dee4      sbc     a,#e4
9ca1  02        ld      (bc),a
9ca2  dcfcda    call    c,#dafc
9ca5  12        ld      (de),a
9ca6  dee4      sbc     a,#e4
9ca8  02        ld      (bc),a
9ca9  dee4      sbc     a,#e4
9cab  05        dec     b
9cac  dee4      sbc     a,#e4
9cae  02        ld      (bc),a
9caf  dcfcda    call    c,#dafc
9cb2  02        ld      (bc),a
9cb3  e6ea      and     #ea
9cb5  02        ld      (bc),a
9cb6  e6e8      and     #e8
9cb8  e8        ret     pe

9cb9  e8        ret     pe

9cba  e8        ret     pe

9cbb  ea02ec    jp      pe,#ec02
9cbe  d3d3      out     (#d3),a
9cc0  d3ee      out     (#ee),a
9cc2  02        ld      (bc),a
9cc3  e7        rst     #20
9cc4  eb        ex      de,hl
9cc5  02        ld      (bc),a
9cc6  e7        rst     #20
9cc7  eb        ex      de,hl
9cc8  02        ld      (bc),a
9cc9  e6ea      and     #ea
9ccb  02        ld      (bc),a
9ccc  dee4      sbc     a,#e4
9cce  02        ld      (bc),a
9ccf  dcfcda    call    c,#dafc
9cd2  02        ld      (bc),a
9cd3  dee4      sbc     a,#e4
9cd5  02        ld      (bc),a
9cd6  e7        rst     #20
9cd7  e9        jp      (hl)
9cd8  e9        jp      (hl)
9cd9  e9        jp      (hl)
9cda  f5        push    af
9cdb  e402dc    call    po,#dc02
9cde  fcfcfc    call    m,#fcfc
9ce1  da08de    jp      c,#de08
9ce4  e402e7    call    po,#e702
9ce7  eb        ex      de,hl
9ce8  02        ld      (bc),a
9ce9  dcfcda    call    c,#dafc
9cec  02        ld      (bc),a
9ced  dee4      sbc     a,#e4
9cef  06de      ld      b,#de
9cf1  e402f0    call    po,#f002
9cf4  fcfcfc    call    m,#fcfc
9cf7  da02e6    jp      c,#e602
9cfa  e8        ret     pe

9cfb  e8        ret     pe

9cfc  e8        ret     pe

9cfd  ea02de    jp      pe,#de02
9d00  e405dc    call    po,#dc05
9d03  fcda02    call    m,#02da
9d06  def2      sbc     a,#f2
9d08  e8        ret     pe

9d09  e8        ret     pe

9d0a  e8        ret     pe

9d0b  ea02de    jp      pe,#de02
9d0e  e402ce    call    po,#ce02
9d11  fcfcfc    call    m,#fcfc
9d14  da02de    jp      c,#de02
9d17  c0        ret     nz

9d18  c0        ret     nz

9d19  c0        ret     nz

9d1a  e402de    call    po,#de02
9d1d  f2e8e8    jp      p,#e8e8
9d20  ea02dc    jp      pe,#dc02
9d23  00        nop     
9d24  00        nop     
9d25  00        nop     
9d26  00        nop     
9d27  66        ld      h,(hl)
9d28  010101    ld      bc,#0101
9d2b  010103    ld      bc,#0301
9d2e  010101    ld      bc,#0101
9d31  0b        dec     bc
9d32  010107    ld      bc,#0701
9d35  0603      ld      b,#03
9d37  03        inc     bc
9d38  0a        ld      a,(bc)
9d39  03        inc     bc
9d3a  07        rlca    
9d3b  0603      ld      b,#03
9d3d  03        inc     bc
9d3e  010101    ld      bc,#0101
9d41  010101    ld      bc,#0101
9d44  010101    ld      bc,#0101
9d47  010307    ld      bc,#0703
9d4a  03        inc     bc
9d4b  010101    ld      bc,#0101
9d4e  03        inc     bc
9d4f  07        rlca    
9d50  03        inc     bc
9d51  0607      ld      b,#07
9d53  03        inc     bc
9d54  03        inc     bc
9d55  03        inc     bc
9d56  07        rlca    
9d57  03        inc     bc
9d58  0607      ld      b,#07
9d5a  03        inc     bc
9d5b  03        inc     bc
9d5c  010101    ld      bc,#0101
9d5f  010101    ld      bc,#0101
9d62  010101    ld      bc,#0101
9d65  010301    ld      bc,#0103
9d68  010101    ld      bc,#0101
9d6b  010107    ld      bc,#0701
9d6e  03        inc     bc
9d6f  0d        dec     c
9d70  0603      ld      b,#03
9d72  07        rlca    
9d73  03        inc     bc
9d74  0d        dec     c
9d75  0603      ld      b,#03
9d77  04        inc     b
9d78  010101    ld      bc,#0101
9d7b  010101    ld      bc,#0101
9d7e  0d        dec     c
9d7f  03        inc     bc
9d80  010101    ld      bc,#0101
9d83  03        inc     bc
9d84  04        inc     b
9d85  03        inc     bc
9d86  1003      djnz    #0d8b           ; (3)
9d88  03        inc     bc
9d89  03        inc     bc
9d8a  04        inc     b
9d8b  03        inc     bc
9d8c  1001      djnz    #0d8f           ; (1)
9d8e  010103    ld      bc,#0301
9d91  03        inc     bc
9d92  04        inc     b
9d93  03        inc     bc
9d94  010101    ld      bc,#0101
9d97  011201    ld      bc,#0112
9d9a  010104    ld      bc,#0401
9d9d  07        rlca    
9d9e  15        dec     d
9d9f  04        inc     b
9da0  07        rlca    
9da1  15        dec     d
9da2  04        inc     b
9da3  03        inc     bc
9da4  010101    ld      bc,#0101
9da7  011201    ld      bc,#0112
9daa  010104    ld      bc,#0401
9dad  03        inc     bc
9dae  1001      djnz    #0db1           ; (1)
9db0  010103    ld      bc,#0301
9db3  03        inc     bc
9db4  04        inc     b
9db5  03        inc     bc
9db6  1003      djnz    #0dbb           ; (3)
9db8  03        inc     bc
9db9  03        inc     bc
9dba  04        inc     b
9dbb  010101    ld      bc,#0101
9dbe  010101    ld      bc,#0101
9dc1  0d        dec     c
9dc2  03        inc     bc
9dc3  010101    ld      bc,#0101
9dc6  03        inc     bc
9dc7  07        rlca    
9dc8  03        inc     bc
9dc9  0d        dec     c
9dca  0603      ld      b,#03
9dcc  07        rlca    
9dcd  03        inc     bc
9dce  0d        dec     c
9dcf  0603      ld      b,#03
9dd1  07        rlca    
9dd2  03        inc     bc
9dd3  03        inc     bc
9dd4  010101    ld      bc,#0101
9dd7  010101    ld      bc,#0101
9dda  010101    ld      bc,#0101
9ddd  010301    ld      bc,#0103
9de0  010101    ld      bc,#0101
9de3  010107    ld      bc,#0701
9de6  03        inc     bc
9de7  03        inc     bc
9de8  03        inc     bc
9de9  07        rlca    
9dea  03        inc     bc
9deb  0607      ld      b,#07
9ded  03        inc     bc
9dee  010101    ld      bc,#0101
9df1  03        inc     bc
9df2  07        rlca    
9df3  03        inc     bc
9df4  0607      ld      b,#07
9df6  0603      ld      b,#03
9df8  03        inc     bc
9df9  010101    ld      bc,#0101
9dfc  010101    ld      bc,#0101
9dff  010101    ld      bc,#0101
9e02  010307    ld      bc,#0703
9e05  0603      ld      b,#03
9e07  03        inc     bc
9e08  0a        ld      a,(bc)
9e09  03        inc     bc
9e0a  08        ex      af,af'
9e0b  010101    ld      bc,#0101
9e0e  010103    ld      bc,#0301
9e11  010101    ld      bc,#0101
9e14  0b        dec     bc
9e15  0101f4    ld      bc,#f401
9e18  1d        dec     e
9e19  221d39    ld      (#391d),hl
9e1c  40        ld      b,b
9e1d  2040      jr      nz,#0e5f        ; (64)
9e1f  3b        dec     sp
9e20  65        ld      h,l
9e21  40        ld      b,b
9e22  7b        ld      a,e
9e23  40        ld      b,b
9e24  85        add     a,l
9e25  43        ld      b,e
9e26  9b        sbc     a,e
9e27  43        ld      b,e
9e28  42        ld      b,d
9e29  160a      ld      d,#0a
9e2b  160a      ld      d,#0a
9e2d  160a      ld      d,#0a
9e2f  2020      jr      nz,#0e51        ; (32)
9e31  20de      jr      nz,#0e11        ; (-34)
9e33  e0        ret     po

9e34  222020    ld      (#2020),hl
9e37  2020      jr      nz,#0e59        ; (32)
9e39  160a      ld      d,#0a
9e3b  160a      ld      d,#0a
9e3d  1600      ld      d,#00
9e3f  00        nop     
9e40  54        ld      d,h
9e41  8e        adc     a,(hl)
9e42  13        inc     de
9e43  c40c59    call    nz,#590c
9e46  8e        adc     a,(hl)
9e47  1ec4      ld      e,#c4
9e49  f4618e    call    p,#8e61
9e4c  2614      ld      h,#14
9e4e  f46b8e    call    p,#8e6b
9e51  1d        dec     e
9e52  14        inc     d
9e53  0c        inc     c
9e54  02        ld      (bc),a
9e55  aa        xor     d
9e56  aa        xor     d
9e57  80        add     a,b
9e58  2a0240    ld      hl,(#4002)
9e5b  55        ld      d,l
9e5c  7f        ld      a,a
9e5d  55        ld      d,l
9e5e  15        dec     d
9e5f  50        ld      d,b
9e60  05        dec     b
9e61  eaff57    jp      pe,#57ff
9e64  55        ld      d,l
9e65  f5        push    af
9e66  ff        rst     #38
9e67  57        ld      d,a
9e68  7f        ld      a,a
9e69  55        ld      d,l
9e6a  05        dec     b
9e6b  eaffff    jp      pe,#ffff
9e6e  ff        rst     #38
9e6f  eaafaa    jp      pe,#aaaf
9e72  02        ld      (bc),a
9e73  87        add     a,a
9e74  8e        adc     a,(hl)
9e75  12        ld      (de),a
9e76  00        nop     
9e77  00        nop     
9e78  8c        adc     a,h
9e79  8e        adc     a,(hl)
9e7a  1d        dec     e
9e7b  00        nop     
9e7c  00        nop     
9e7d  94        sub     h
9e7e  8e        adc     a,(hl)
9e7f  210000    ld      hl,#0000
9e82  9d        sbc     a,l
9e83  8e        adc     a,(hl)
9e84  2c        inc     l
9e85  00        nop     
9e86  00        nop     
9e87  55        ld      d,l
9e88  7f        ld      a,a
9e89  55        ld      d,l
9e8a  d5        push    de
9e8b  ff        rst     #38
9e8c  aa        xor     d
9e8d  bf        cp      a
9e8e  aa        xor     d
9e8f  2aa0ea    ld      hl,(#eaa0)
9e92  ff        rst     #38
9e93  ff        rst     #38
9e94  aa        xor     d
9e95  2aa002    ld      hl,(#02a0)
9e98  00        nop     
9e99  00        nop     
9e9a  a0        and     b
9e9b  aa        xor     d
9e9c  02        ld      (bc),a
9e9d  55        ld      d,l
9e9e  15        dec     d
9e9f  a0        and     b
9ea0  2a0054    ld      hl,(#5400)
9ea3  05        dec     b
9ea4  00        nop     
9ea5  00        nop     
9ea6  55        ld      d,l
9ea7  fd40      ld      b,b
9ea9  fcd0d2    call    m,#d2d0
9eac  d2d2d2    jp      nc,#d2d2
9eaf  d2d2d6    jp      nc,#d6d2
9eb2  e402e7    call    po,#e702
9eb5  d2d2d2    jp      nc,#d2d2
9eb8  d2d2d2    jp      nc,#d2d2
9ebb  d2d2d2    jp      nc,#d2d2
9ebe  d2d6d8    jp      nc,#d8d6
9ec1  d2d2d2    jp      nc,#d2d2
9ec4  d2d2d2    jp      nc,#d2d2
9ec7  d2d4fc    jp      nc,#fcd4
9eca  da07de    jp      c,#de07
9ecd  e40dde    call    po,#de0d
9ed0  e408dc    call    po,#dc08
9ed3  fcda02    call    m,#02da
9ed6  e6e8      and     #e8
9ed8  e8        ret     pe

9ed9  ea02de    jp      pe,#de02
9edc  e402e6    call    po,#e602
9edf  e8        ret     pe

9ee0  e8        ret     pe

9ee1  ea02e6    jp      pe,#e602
9ee4  e8        ret     pe

9ee5  e8        ret     pe

9ee6  e8        ret     pe

9ee7  ea02e7    jp      pe,#e702
9eea  eb        ex      de,hl
9eeb  02        ld      (bc),a
9eec  e6ea      and     #ea
9eee  02        ld      (bc),a
9eef  e6ea      and     #ea
9ef1  02        ld      (bc),a
9ef2  dcfcda    call    c,#dafc
9ef5  02        ld      (bc),a
9ef6  def3      sbc     a,#f3
9ef8  e9        jp      (hl)
9ef9  eb        ex      de,hl
9efa  02        ld      (bc),a
9efb  e7        rst     #20
9efc  eb        ex      de,hl
9efd  02        ld      (bc),a
9efe  e7        rst     #20
9eff  e9        jp      (hl)
9f00  f5        push    af
9f01  e402e7    call    po,#e702
9f04  e9        jp      (hl)
9f05  e9        jp      (hl)
9f06  f5        push    af
9f07  e405de    call    po,#de05
9f0a  e402de    call    po,#de02
9f0d  e402dc    call    po,#dc02
9f10  fcda02    call    m,#02da
9f13  dee4      sbc     a,#e4
9f15  09        add     hl,bc
9f16  dee4      sbc     a,#e4
9f18  05        dec     b
9f19  dee4      sbc     a,#e4
9f1b  02        ld      (bc),a
9f1c  e6e8      and     #e8
9f1e  e8        ret     pe

9f1f  f4e402    call    p,#02e4
9f22  dee4      sbc     a,#e4
9f24  02        ld      (bc),a
9f25  dcfcda    call    c,#dafc
9f28  02        ld      (bc),a
9f29  dee4      sbc     a,#e4
9f2b  02        ld      (bc),a
9f2c  e6e8      and     #e8
9f2e  e8        ret     pe

9f2f  e8        ret     pe

9f30  e8        ret     pe

9f31  ea02e7    jp      pe,#e702
9f34  eb        ex      de,hl
9f35  02        ld      (bc),a
9f36  e6ea      and     #ea
9f38  02        ld      (bc),a
9f39  e7        rst     #20
9f3a  eb        ex      de,hl
9f3b  02        ld      (bc),a
9f3c  e7        rst     #20
9f3d  e9        jp      (hl)
9f3e  e9        jp      (hl)
9f3f  e9        jp      (hl)
9f40  eb        ex      de,hl
9f41  02        ld      (bc),a
9f42  e7        rst     #20
9f43  eb        ex      de,hl
9f44  02        ld      (bc),a
9f45  dcfcda    call    c,#dafc
9f48  02        ld      (bc),a
9f49  dee4      sbc     a,#e4
9f4b  02        ld      (bc),a
9f4c  e7        rst     #20
9f4d  e9        jp      (hl)
9f4e  e9        jp      (hl)
9f4f  e9        jp      (hl)
9f50  f5        push    af
9f51  e405de    call    po,#de05
9f54  e40edc    call    po,#dc0e
9f57  fcda02    call    m,#02da
9f5a  dee4      sbc     a,#e4
9f5c  06de      ld      b,#de
9f5e  e402e6    call    po,#e602
9f61  e8        ret     pe

9f62  e8        ret     pe

9f63  f4e402    call    p,#02e4
9f66  e6e8      and     #e8
9f68  e8        ret     pe

9f69  e8        ret     pe

9f6a  ea02e6    jp      pe,#e602
9f6d  e8        ret     pe

9f6e  e8        ret     pe

9f6f  e8        ret     pe

9f70  e8        ret     pe

9f71  e8        ret     pe

9f72  f4fcda    call    p,#dafc
9f75  02        ld      (bc),a
9f76  e7        rst     #20
9f77  eb        ex      de,hl
9f78  02        ld      (bc),a
9f79  e6e8      and     #e8
9f7b  ea02e7    jp      pe,#e702
9f7e  eb        ex      de,hl
9f7f  02        ld      (bc),a
9f80  e7        rst     #20
9f81  e9        jp      (hl)
9f82  e9        jp      (hl)
9f83  e9        jp      (hl)
9f84  eb        ex      de,hl
9f85  02        ld      (bc),a
9f86  def3      sbc     a,#f3
9f88  e9        jp      (hl)
9f89  e9        jp      (hl)
9f8a  eb        ex      de,hl
9f8b  02        ld      (bc),a
9f8c  def3      sbc     a,#f3
9f8e  e9        jp      (hl)
9f8f  e9        jp      (hl)
9f90  e9        jp      (hl)
9f91  e9        jp      (hl)
9f92  f5        push    af
9f93  fcda05    call    m,#05da
9f96  dec0      sbc     a,#c0
9f98  e40bde    call    po,#de0b
9f9b  e405de    call    po,#de05
9f9e  e405dc    call    po,#dc05
9fa1  fcfae8    call    m,#e8fa
9fa4  e8        ret     pe

9fa5  ea02de    jp      pe,#de02
9fa8  c0        ret     nz

9fa9  e402e6    call    po,#e602
9fac  ea02ec    jp      pe,#ec02
9faf  d3d3      out     (#d3),a
9fb1  d3ee      out     (#ee),a
9fb3  02        ld      (bc),a
9fb4  dee4      sbc     a,#e4
9fb6  02        ld      (bc),a
9fb7  e6ea      and     #ea
9fb9  02        ld      (bc),a
9fba  dee4      sbc     a,#e4
9fbc  02        ld      (bc),a
9fbd  e6ea      and     #ea
9fbf  02        ld      (bc),a
9fc0  dcfcfb    call    c,#fbfc
9fc3  e9        jp      (hl)
9fc4  e9        jp      (hl)
9fc5  eb        ex      de,hl
9fc6  02        ld      (bc),a
9fc7  e7        rst     #20
9fc8  e9        jp      (hl)
9fc9  eb        ex      de,hl
9fca  02        ld      (bc),a
9fcb  dee4      sbc     a,#e4
9fcd  02        ld      (bc),a
9fce  dcfcfc    call    c,#fcfc
9fd1  fcda02    call    m,#02da
9fd4  e7        rst     #20
9fd5  eb        ex      de,hl
9fd6  02        ld      (bc),a
9fd7  dee4      sbc     a,#e4
9fd9  02        ld      (bc),a
9fda  e7        rst     #20
9fdb  eb        ex      de,hl
9fdc  02        ld      (bc),a
9fdd  dee4      sbc     a,#e4
9fdf  02        ld      (bc),a
9fe0  dcfcda    call    c,#dafc
9fe3  09        add     hl,bc
9fe4  dee4      sbc     a,#e4
9fe6  02        ld      (bc),a
9fe7  f0        ret     p

9fe8  fcfcfc    call    m,#fcfc
9feb  da05de    jp      c,#de05
9fee  e405de    call    po,#de05
9ff1  e402dc    call    po,#dc02
9ff4  fcda02    call    m,#02da
9ff7  e6e8      and     #e8
9ff9  e8        ret     pe

9ffa  e8        ret     pe

9ffb  e8        ret     pe

9ffc  ea02de    jp      pe,#de02
9fff  e40000    call    po,#0000
