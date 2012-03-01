#!/bin/bash

# build 'pacman.js' by concatenating from src/ directory and adding a header
cat \
    <(echo "// PAC-MAN") \
    <(echo "// an accurate remake of the original arcade game") \
    <(echo "") \
    <(echo "// original by Namco") \
    <(echo "// research from 'The Pacman Dossier' compiled by Jamey Pittman") \
    <(echo "// remake by Shaun Williams") \
    <(echo "") \
    <(echo "// Project Page: http://github.com/shaunew/Pac-Man") \
    <(echo "") \
    <(echo "(function(){") \
    src/TileMap.js \
    src/renderers.js \
    src/sprites.js \
    src/screen.js \
    src/Actor.js \
    src/Ghost.js \
    src/Player.js \
    src/actors.js \
    src/targets.js \
    src/ghostCommander.js \
    src/ghostReleaser.js \
    src/elroyTimer.js \
    src/energizer.js \
    src/fruit.js \
    src/game.js \
    src/states.js \
    src/maps.js \
    src/main.js \
    <(echo "})();") \
    > pacman.js

sed -i "s/last updated:[^<]*/last updated: $(date)/" index.htm
sed -i "s/last updated:[^<]*/last updated: $(date)/" debug.htm
