Pac-Man
=======

A historical tribute and accurate remake of the original Pac-Man arcade game.  Includes the remakes of Pac-Man and Ms. Pac-Man.

<img src="http://shaunew.github.com/Pac-Man/shots/preview.png" width="100%"/>

A new game mode 'Cookie-Man' generates a random maze for every level, allowing for extended play.

<img src="http://shaunew.github.com/Pac-Man/shots/preview2.png" width="100%"/>

Play
----
[Click here to play the current version](http://shaunew.github.com/Pac-Man)

Features
--------

- same coordinate space, movement physics, ghost behavior, timers, and update rate as the original arcade game
- extra sandbox controls for visualizing ghost behavior, slowing down the game, and other adjustments
- Pac-Man, Ms. Pac-Man game modes
- new Cookie-Man mode, with random map generator
- hold **shift** in-game to rewind/replay the game, a la Braid.

Navigating the Repository
-------------------------
- all javascript source files are located in the "src/" directory
- "build.sh" file concatenates all the source files into "pacman.js" in the top directory
- "debug.htm" displays the game by using the "src/*.js" files
- "index.htm" displays the game by using the "pacman.js" file only.

Credits
-------

### Reverse-Engineers

Thanks to **Jamey Pittman** for compiling [The Pac-Man Dossier](http://home.comcast.net/~jpittman2/pacman/pacmandossier.html) from his own research and those of other reverse-engineers, notably 'Dav' and 'JamieVegas' from [this Atari Age forum thread](http://www.atariage.com/forums/topic/68707-pac-man-ghost-ai-question/).  Further thanks to Jamey Pittman for replying to my arcade implementation-specific questions with some very elaborate details to meet the accuracy requirements of this project.

Thanks to **Bart Grantham** for providing me with his annotated Ms. Pac-Man disassembly and notes on how fruit paths work in meticulous detail.

### Original Games

Thanks to the original Pac-Man team at Namco for creating such an enduring game and not suing me.  And thanks to the MAME team for their arcade emulator and very helpful debugger.

Thanks to the Ms. Pac-Man team at GCC for improving Pac-Man with a variety of aesthetic maps that I based the map generator on.

Thanks to Jonathan Blow for introducing the rewind mechanic employed in this remake.

### Art

Thanks to Tang Yongfa and their cookie monster Pac-Man design at [threadless website](http://www.threadless.com/product/2362/Cookies) which I used as the character in the random maze mode.
