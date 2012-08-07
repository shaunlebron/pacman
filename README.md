Pac-Man
=======

A historical tribute and accurate remake of the original Pac-Man arcade game.

Play
----

You can play the game on all canvas-enabled browsers.  Touch interface is
enabled for mobile browsers.  The game is resolution-independent and scales to
fit the size of your window.  Performance may increase by shrinking the window.

[Click here to play the current version](http://shaunew.github.com/Pac-Man)

Controls
--------

- **swipe**: steer pacman on mobile browsers
- **arrows**: steer pacman
- **spacebar**: pause/unpause the game

### Practice Mode

- **shift**: hold down to rewind (a la Braid)
- **ctrl**: hold down to slow down the game to 0.5x
- **alt**: hold down to slow down the game to 0.25x

- **o**: toggle pacman turbo mode
- **p**: toggle pacman attract mode (autoplay)
- **i**: toggle pacman invincibility
- **n**: go to next level

- **q,w,e,r,t**: toggle target graphic for blinky, pinky, inky, clyde, and pacman, respectively.
- **a,s,d,f,g**: toggle path graphic for blinky, pinky, inky, clyde, and pacman, respectively.

Features
--------

- same coordinate space, movement physics, ghost behavior, timers, and update rate as the original arcade game
- scalable, resolution-independent graphics
- playable on mobile browsers
- original Pac-Man and Ms. Pac-Man game modes, including the original popular turbo modes.
- new Cookie-Man game with procedural map generator

Navigating the Repository
-------------------------
- all javascript source files are located in the "src/" directory
- "build.sh" file concatenates all the source files into "pacman.js" in the top directory
- "debug.htm" displays the game by using the "src/*.js" files
- "index.htm" displays the game by using the "pacman.js" file only
- the "fruit" directory contains notes and diagrams on Ms. Pac-Man fruit paths
- the "mapgen" directory contains notes, diagrams, and experiments on procedural Pac-Man maze generation
- the "sprites" directory contains references sprite sheets and an atlas viewer "atlas.htm" for viewing the scalable game sprites.
- the "font" directory contains font resources used in the game.

Credits
-------

### Reverse-Engineers

Thanks to **Jamey Pittman** for compiling [The Pac-Man Dossier](http://home.comcast.net/~jpittman2/pacman/pacmandossier.html) from his own research and those of other reverse-engineers, notably 'Dav' and 'JamieVegas' from [this Atari Age forum thread](http://www.atariage.com/forums/topic/68707-pac-man-ghost-ai-question/).  Further thanks to Jamey Pittman for replying to my arcade implementation-specific questions with some very elaborate details to meet the accuracy requirements of this project.

Thanks to **Bart Grantham** for sharing his expert knowledge on Ms. Pac-Man's internals, providing me with an annotated disassembly and notes on how fruit paths work in meticulous detail.

### Original Games

Thanks to the original Pac-Man team at Namco for creating such an enduring game and not suing me.  And thanks to the MAME team for their arcade emulator and very helpful debugger.

Thanks to the Ms. Pac-Man team at GCC for improving Pac-Man with a variety of aesthetic maps that I based the map generator on.

Thanks to Jonathan Blow for introducing the rewind mechanic employed in this remake.

### Art

Thanks to Tang Yongfa and their cookie monster Pac-Man design at [threadless website](http://www.threadless.com/product/2362/Cookies) which I used as the character in the random maze mode.
