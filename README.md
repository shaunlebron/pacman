Pac-Man
=======

This is an accurate re-implementation of the original Pac-Man arcade game.

[Click here to play the current version](http://shaunew.github.com/Pac-Man)

![Preview](https://github.com/shaunew/Pac-Man/raw/gh-pages/preview.png)

Features
--------

- same coordinate space, movement physics, ghost behavior, timers, and update rate as the original arcade game
- extra sandbox controls for visualizing ghost behavior, slowing down the game, and other adjustments
- included maps from Pac-Man and Ms. Pac-Man
- easy to create custom ascii-based level maze maps
- separate rendering themes

Code
----
- implemented in Javascript using HTML Canvas
- all javascript source files are located in the `src/` directory
- `build.sh` file concatenates all the source files into a closure in `pacman.js` in the top directory
- `debug.htm` displays the game by including the `src/*.js` files
- `index.htm` displays the game by including the `pacman.js` file only.

Future
------

- allow live editing of ghost targetting functions
- allow A.I. agent to control Pac-Man

Thanks
------

Special thanks to Jamey Pittman for compiling [The Pac-Man Dossier](http://home.comcast.net/~jpittman2/pacman/pacmandossier.html) from his own research and those of other reverse-engineers, notably 'Dav' and 'JamieVegas' from [this Atari Age forum thread](http://www.atariage.com/forums/topic/68707-pac-man-ghost-ai-question/).  Further thanks to Jamey Pittman for replying to my arcade implementation-specific questions with some very elaborate details to meet the accuracy requirements of this project.

Thanks to the original Pac-Man team at Namco for creating such an enduring game and not suing me.  And thanks to the MAME team for their arcade emulator and very helpful debugger.

-Shaun Williams
