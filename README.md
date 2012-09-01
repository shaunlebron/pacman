Pac-Man
=======

A historical tribute and accurate remake of the original Pac-Man arcade game. (Inspired by [The Pac-Man Dossier](http://home.comcast.net/~jpittman2/pacman/pacmandossier.html))

Objective
---------

To faithfully recreate the original Pac-Man arcade game in a modern language-- so that it may survive to be studied, modified, extended, and accessed on the open web.

Play
----

[Click here to play the current version](http://shaunew.github.com/Pac-Man)

You can play the game on all canvas-enabled browsers.  **Touch controls** are
enabled for mobile browsers.  The game is **resolution-independent** and smoothly scales to
fit the size of any screen.  **Performance** may increase by shrinking the window or zooming in with your browser.

### Main Controls

- **swipe**: steer pacman on mobile browsers
- **arrows**: steer pacman
- **escape**: pause the game

Games
-----

Each of the following games are playable from the main menu.

<a href="http://shaunew.github.com/Pac-Man/shots/montage.png"><img src="http://shaunew.github.com/Pac-Man/shots/montage.png" width="100%"/></a>

- **Pac-Man**: 1980 original arcade by Namco.
- **Ms. Pac-Man**: 1981 Pac-Man modification by GCC/Midway.
- **Crazy Otto**: GCC's unreleased, in-house version of Ms. Pac-Man before it was sold to Midway.
- **Cookie-Man**: a brand new version of Ms. Pac-Man with a sophisticated **procedural map generator**.

### Turbo Mode

Each game has an alternate mode called Turbo (a.k.a. speedy mode).  This is a
popular hardware modification of the game found in many of the original arcade
cabinets.  In this mode, Pac-Man travels as fast as the disembodied eyes of the
ghosts and is not slowed down when eating pellets.

### High Scores

High scores for each game (normal and turbo separately) are stored by your browser.

Learn Mode
----------

This mini mode is playable from the main menu. It allows you to **visualize the behaviors** the ghosts.  (The colored square indicates the ghost bait.)

<a href="http://shaunew.github.com/Pac-Man/shots/learn.png"><img src="http://shaunew.github.com/Pac-Man/shots/learn.png" width="100%"/></a>

Practice Mode
-------------

This mode allows you to practice the game with special features.  You can go
into **slow-motion** or **rewind time** with the special onscreen buttons or the hotkeys listed below.  (The time-manipulation controls and design were borrowed from the game [Braid](http://braid-game.com/)).  You can also turn on **invincibility** or **ghost visualizers** from the menu.

<a href="http://shaunew.github.com/Pac-Man/shots/practice.png"><img src="http://shaunew.github.com/Pac-Man/shots/practice.png" width="100%"/></a>

### Practice Controls

- **shift**: hold down to rewind (a la Braid)
- **1**: hold down to slow down the game to 0.5x
- **2**: hold down to slow down the game to 0.25x
- **o**: toggle pacman turbo mode
- **p**: toggle pacman attract mode (autoplay)
- **i**: toggle pacman invincibility
- **n**: go to next level
- **q,w,e,r,t**: toggle target graphic for blinky, pinky, inky, clyde, and pacman, respectively.
- **a,s,d,f,g**: toggle path graphic for blinky, pinky, inky, clyde, and pacman, respectively.

Accuracy
--------

It is a major goal of this project to stay as closely accurate to the original arcade game as reasonably possible. The current accuracy is due to the work of reverse-engineers Jamey Pittman and Bart Grantham.

Currently, the coordinate space, movement physics, ghost behavior, actor speeds, timers, and update rate match that of the original arcade game.

### Inaccuracies

The **timings** of certain non-critical events such as score display pauses and map-blinking animations are currently approximated until they are closely measured.

Unfortunately, you **cannot use original Pac-Man patterns** in this version because of the nondeterministic pseudo random number generator used to turn the frightened ghosts.

Also, the **collision detection** works a little differently by checking if Pac-Man occupies the same tile as a ghost before and after ghost positions are updated.  This is to prevent pass-through "bugs" of the original, which seemed to happen more in this version than the original.  The collision detection may need fixing.

### Report/Fix Bugs

I'd love to hear any issues you have with any inaccuracies that may detract or simply annoy.  Any reverse-engineers willing to contribute their expertise to this project would be a big help as well!

Future Work
-----------

- Sound
- Cutscenes
- 2 Player switch-off

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
