//////////////////////////////////////////////////////////////////////////////////////
// Fade state

var fadeNextState = function (prevState, nextState, frameDuration) {
    var frames;
    return {
        init: function() {
            frames = 0;
        },
        draw: function() {
            var t;
            if (frames < frameDuration/2) {
                t = frames/frameDuration*2;
                if (prevState) {
                    prevState.draw();
                    screen.renderer.drawFadeIn(1-t);
                }
            }
            else {
                t = frames/frameDuration*2 - 1;
                nextState.draw();
                screen.renderer.drawFadeIn(t);
            }
        },
        update: function() {
            if (frames == frameDuration)
                game.state = nextState;
            else {
                if (frames == frameDuration/2)
                    nextState.init();
                frames++;
            }
        },
    }
};

var fadeRendererState = function (currState, nextRenderer, frameDuration) {
    var frames;
    return {
        init: function() {
            frames = 0;
        },
        draw: function() {
            var t;
            currState.draw();
            if (frames < frameDuration/2) {
                t = frames/frameDuration*2;
                screen.renderer.drawFadeIn(1-t);
            }
            else {
                t = frames/frameDuration*2 - 1;
                screen.renderer.drawFadeIn(t);
            }
        },
        update: function() {
            if (frames == frameDuration)
                game.state = currState;
            else {
                if (frames == frameDuration/2)
                    screen.switchRenderer(nextRenderer);
                frames++;
            }
        },
    }
};

//////////////////////////////////////////////////////////////////////////////////////
// Menu State

var menuState = (function() {
    var frames;
    var fadeFrames = 120;
    return {
        init: function() {
            game.switchMap(MAP_MENU);
            for (i=0; i<5; i++)
                actors[i].reset();
            screen.renderer.drawMap();
            screen.onClick = function() {

                // if we have already left this state by other means
                // cancel this action
                if (game.state != menuState) {
                    screen.onClick = undefined;
                    return;
                }

                newGameState.nextMap = MAP_PACMAN;
                game.switchState(newGameState,60);
                screen.onClick = undefined;
            };
            frames = 0;
        },
        draw: function() {
            screen.blitMap();
            screen.renderer.drawScore();
            screen.renderer.drawMessage("A Pac-Man Remake","#FFF");
            screen.renderer.drawActors();
        },
        update: function() {
            var i;
            for (i = 0; i<4; i++)
                actors[i].update();
        },
    };
})();

////////////////////////////////////////////////////

// state when first starting the game
var newGameState = (function() {
    var frames;
    var duration = 2;

    return {
        init: function() {
            if (this.nextMap != undefined) {
                game.switchMap(this.nextMap);
                this.nextMap = undefined;
            }
            frames = 0;
            tileMap.resetCurrent();
            screen.renderer.drawMap();
            game.extraLives = 3;
            game.level = 1;
            game.score = 0;
        },
        draw: function() {
            screen.blitMap();
            screen.renderer.drawEnergizers();
            screen.renderer.drawExtraLives();
            screen.renderer.drawLevelIcons();
            screen.renderer.drawScore();
            screen.renderer.drawMessage("ready","#FF0");
        },
        update: function() {
            if (frames == duration*60) {
                game.extraLives--;
                game.switchState(readyNewState);
            }
            else 
                frames++;
        },
    };
})();

////////////////////////////////////////////////////

// common ready state when about to play
var readyState =  (function(){
    var frames;
    var duration = 2;
    
    return {
        init: function() {
            var i;
            for (i=0; i<5; i++)
                actors[i].reset();
            frames = 0;
        },
        draw: function() {
            newGameState.draw();
            screen.renderer.drawActors();
        },
        update: function() {
            if (frames == duration*60)
                game.switchState(playState);
            else
                frames++;
        },
    };
})();

////////////////////////////////////////////////////

// ready state for new level
var readyNewState = { 
    __proto__: readyState, 
    init: function() {
        // kludge: redirect to new game state
        //   if user clicks map without game being initialized
        if (game.score == undefined) {
            newGameState.nextMap = this.nextMap;
            game.switchState(newGameState);
            return;
        }

        if (this.nextMap != undefined) {
            game.switchMap(this.nextMap);
            this.nextMap = undefined;

            tileMap.resetCurrent();
            screen.renderer.drawMap();
        }
        ghostCommander.reset();
        ghostReleaser.onNewLevel();
        fruit.reset();
        elroyTimer.onNewLevel();
        readyState.init.call(this);
    },
};

////////////////////////////////////////////////////

// ready state for restarting level
var readyRestartState = { 
    __proto__: readyState, 
    init: function() {
        game.extraLives--;
        ghostCommander.reset();
        ghostReleaser.onRestartLevel();
        fruit.reset();
        elroyTimer.onRestartLevel();
        readyState.init.call(this);
    },
};

////////////////////////////////////////////////////

// state when playing the game
var playState = {
    init: function() { },
    draw: function() {
        screen.blitMap();
        screen.renderer.drawEnergizers();
        screen.renderer.drawExtraLives();
        screen.renderer.drawLevelIcons();
        screen.renderer.drawScore();
        screen.renderer.drawFruit();
        screen.renderer.drawActors();
    },
    isPacmanCollide: function() {
        // test pacman's tile collision against each ghost
        var i,g;
        for (i = 0; i<4; i++) {
            g = actors[i];
            if (g.tile.x == pacman.tile.x && g.tile.y == pacman.tile.y && g.mode == GHOST_OUTSIDE) {
                if (g.scared) { // eat ghost
                    energizer.addPoints();
                    g.onEaten();
                }
                else if (pacman.invincible) // pass through ghost
                    continue;
                else // killed by ghost
                    game.switchState(deadState);
                return true;
            }
        }
        return false;
    },
    update: function() {
        var i; // loop index
        var j;
        var maxSteps = 2;

        // skip this frame if needed,
        // but update ghosts running home
        if (energizer.showingPoints()) {
            for (j=0; j<maxSteps; j++)
                for (i=0; i<4; i++)
                    if (actors[i].mode == GHOST_GOING_HOME || actors[i].mode == GHOST_ENTERING_HOME)
                        actors[i].update(j);
            energizer.updatePointsTimer();
            return;
        }

        // update counters
        ghostReleaser.update();
        ghostCommander.update();
        elroyTimer.update();
        fruit.update();
        energizer.update();


        // update actors one step at a time
        for (j=0; j<maxSteps; j++) {

            // advance pacman
            pacman.update(j);

            // test collision with fruit
            fruit.testCollide();

            // finish level if all dots have been eaten
            if (tileMap.allDotsEaten()) {
                this.draw();
                game.switchState(finishState);
                return;
            }

            // test pacman collision before and after updating ghosts
            // (redundant to prevent pass-throughs)
            // (if collision happens, stop immediately.)
            if (this.isPacmanCollide()) break;
            for (i=0;i<4;i++) actors[i].update(j);
            if (this.isPacmanCollide()) break;
        }

        // update frame counts
        for (i=0; i<5; i++)
            actors[i].frames++;
    },
};

////////////////////////////////////////////////////

// state when playing the game
var scriptState = {
    init: function() {
        this.frames = 0;
        this.triggerFrame = 0;

        this.drawFunc = undefined;
        this.updateFunc = undefined;
    },
    update: function() {
        var trigger = this.triggers[this.frames];
        if (trigger) {
            if (trigger.init) trigger.init();
            this.drawFunc = trigger.draw;
            this.updateFunc = trigger.update;
            this.triggerFrame = 0;
        }

        if (this.updateFunc) 
            this.updateFunc(this.triggerFrame);

        this.frames++;
        this.triggerFrame++;
    },
    draw: function() {
        if (this.drawFunc) 
            this.drawFunc(this.triggerFrame);
    },
};

////////////////////////////////////////////////////

// state when dying
var deadState = (function() {
    
    var commonDraw = function() {
        screen.blitMap();
        screen.renderer.drawEnergizers();
        screen.renderer.drawExtraLives();
        screen.renderer.drawLevelIcons();
        screen.renderer.drawScore();
        screen.renderer.drawFruit();
    };

    return {
        // inherit script state functions
        __proto__: scriptState,

        // freeze for a moment, then shrink and explode
        triggers: {
            0: {
                init: function() { // pause
                    commonDraw();
                    screen.renderer.drawActors();
                },
            },
            60: {
                init: function() { // isolate pacman
                    commonDraw();
                    screen.renderer.drawPacman();
                },
            },
            120: {
                draw: function(t) { // shrink
                    commonDraw();
                    screen.renderer.drawDyingPacman(t/60);
                },
            },
            180: {
                draw: function(t) { // explode
                    commonDraw();
                    screen.renderer.drawExplodingPacman(t/15);
                },
            },
            195: {
                draw: function(){}, // pause
            },
            240: {
                init: function() { // leave
                    game.switchState( game.extraLives == 0 ? overState : readyRestartState);
                }
            },
        },
    };
})();

////////////////////////////////////////////////////

var finishState = (function(){

    var commonDraw = function() {
        screen.renderer.drawMap();
        screen.blitMap();
        screen.renderer.drawEnergizers();
        screen.renderer.drawExtraLives();
        screen.renderer.drawLevelIcons();
        screen.renderer.drawScore();
        screen.renderer.drawFruit();
        screen.renderer.drawPacman();
    };
    
    var flashFloor = function() {
        screen.renderer.toggleLevelFlash();
        commonDraw();
    };

    return {
        __proto__: scriptState,
        triggers: {
            60: { init: commonDraw },
            120: { init: flashFloor },
            135: { init: flashFloor },
            150: { init: flashFloor },
            165: { init: flashFloor },
            180: { init: flashFloor },
            195: { init: flashFloor },
            210: { init: flashFloor },
            225: { init: flashFloor },
            255: { 
                init: function() {
                    game.level++;
                    game.switchState(readyNewState,60);
                    tileMap.resetCurrent();
                    screen.renderer.drawMap();
                }
            },
        },
    };
})();

////////////////////////////////////////////////////

// display game over
var overState = {
    init: function() {
        screen.renderer.drawMessage("game over", "#F00");
        screen.onClick = function() {
            game.switchState(menuState,60);
            screen.onClick = undefined;
        }
    },
    draw: function() {},
    update: function() {},
};

