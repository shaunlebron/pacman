#!/bin/bash

cat \
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
