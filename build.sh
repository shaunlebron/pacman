#!/bin/bash

# 1. build 'pacman.js' by concatenating files specified in js_order
# 2. update time stamp in index.htm
# 3. build debug.htm with individual script includes

output="pacman.js"
debug_includes="\n"

# write header
echo "
// Copyright 2012 Shaun Williams
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License Version 3 as 
//  published by the Free Software Foundation.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

// ==========================================================================
// PAC-MAN
// an accurate remake of the original arcade game

// Based on original works by Namco, GCC, and Midway.
// Research by Jamey Pittman and Bart Grantham
// Developed by Shaun Williams

// ==========================================================================

(function(){
" > $output

for file in \
    inherit.js \
    random.js \
    game.js \
    direction.js \
    Map.js \
    colors.js \
    mapgen.js \
    atlas.js \
    renderers.js  \
    hud.js \
    galagaStars.js \
    Button.js \
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
    vcr.js \
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

# build debug.htm from index.htm adding debug includes
sed "s:.*$output.*:$debug_includes:" index.htm > debug.htm
