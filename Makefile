files = TileMap.js renderers.js screen.js Actor.js Ghost.js Player.js actors.js ghostCommander.js ghostReleaser.js elroyTimer.js energizer.js fruit.js game.js states.js maps.js main.js

.PHONY: build

build: $(files)
	cat $(files) > pacman.js
