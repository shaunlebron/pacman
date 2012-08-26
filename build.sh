#!/bin/bash

# 1. build 'pacman.js' by concatenating files specified in js_order
# 2. update time stamp in index.htm
# 3. build debug.htm with individual script includes

output="pacman.js"
debug_includes="\n"

# write header
echo "
// PAC-MAN
// an accurate remake of the original arcade game

// original by Namco
// research from 'The Pacman Dossier' compiled by Jamey Pittman
// remake by Shaun Williams

// Project Page: http://github.com/shaunew/Pac-Man

(function(){
" > $output

for file in \
    game.js \
    vcr.js \
    direction.js \
    Map.js \
    colors.js \
    mapgen.js \
    atlas.js \
    renderers.js  \
    hud.js \
    galagaStars.js \
    gui.js \
    Menu.js \
    inGameMenu.js \
    sprites.js \
    Actor.js \
    Ghost.js \
    Player.js \
    actors.js \
    targets.js \
    ghostCommander.js \
    ghostReleaser.js \
    elroyTimer.js \
    energizer.js \
    fruit.js \
    executive.js \
    states.js \
    input.js \
    cutscenes.js \
    maps.js \
    main.js
do
    # points firebug to correct file (or so I hoped)
    # if JSOPTION_ATLINE is set, this should work in firefox (but I don't know how to set it)
    echo "//@line 1 \"src/$file\"" >> $output 

    # concatenate file to output
    cat src/$file >> $output

    # add this file to debug includes
    debug_includes="$debug_includes<script src=\"src/$file\"></script>\n"
done

# end anonymous function wrapper
echo "})();" >> $output

# update time stamp
sed -i "s/last updated:[^<]*/last updated: $(date)/" index.htm

# build debug.htm from index.htm adding debug includes
sed "s:.*$output.*:$debug_includes:" index.htm > debug.htm
