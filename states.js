
////////////////////////////////////////////////////
var startupState = {
    init: function() {
        screen.drawMap();
        screen.blitMap();
        screen.drawMessage("start","#FFF");
        clickState.nextState = newGameState;
        game.switchState(clickState);
    },
    draw: function(){},
    update: function(){},
};

////////////////////////////////////////////////////

// state when waiting for the user to click
var clickState = {
    init: function() {
        screen.onClick = function() {
            game.switchState(this.nextState);
            screen.onClick = undefined;
        }
    },
    draw: function(){},
    update: function(){},
};

////////////////////////////////////////////////////

// state when first starting the game
var newGameState = (function() {
    var frames;
    var duration = 2;

    return {
        init: function() {
            frames = 0;
            tileMap.resetCurrent();
            game.extraLives = 3;
            game.level = 1;
            game.score = 0;
        },
        draw: function() {
            screen.blitMap();
            screen.drawEnergizers();
            screen.drawExtraLives();
            screen.drawLevelIcons();
            screen.drawScore();
            screen.drawMessage("ready","#FF0");
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
            screen.drawActors();
        },
        update: function() {
            if (frames == duration*60)
                game.switchState(playState);
            else
                frames++;
        },
    };
});

////////////////////////////////////////////////////

// ready state for new level
var readyNewState = { 
    __proto__: readyState, 
    init: function() {
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
        screen.drawEnergizers();
        screen.drawExtraLives();
        screen.drawLevelIcons();
        screen.drawScore();
        screen.drawFruit();
        screen.drawActors();
    },
    update: function() {
        var i; // loop index
        var g; // loop ghost

        // skip this frame if needed,
        // but update ghosts running home
        if (energizer.isShowingPoints()) {
            for (i=0; i<4; i++)
                if (actors[i].mode == GHOST_GOING_HOME)
                    actors[i].update();
            energizer.updatePointTimer();
        }

        // update counters
        ghostReleaser.update();
        ghostCommander.update();
        elroyTimer.update();
        fruit.update();

        // update actors
        for (i = 0; i<5; i++)
            actors[i].update();

        // test collision with fruit
        fruit.testCollide();

        // finish level if all dots have been eaten
        if (tileMap.allDotsEaten())
            game.switchState(finishState);
            return;
        }

        // test pacman collision with each ghost
        for (i = 0; i<4; i++) {
            g = actors[i];
            if (g.tile.x == pacman.tile.x && g.tile.y == pacman.tile.y) {
                if (g.mode == GHOST_OUTSIDE) {
                    // somebody is going to die
                    if (!g.scared) {
                        game.switchState(deadState);
                    }
                    else if (energizer.isActive()) {
                        energizer.addPoints();
                        g.onEaten();
                    }
                    break;
                }
            }
        }
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
        screen.drawEnergizers();
        screen.drawExtraLives();
        screen.drawLevelIcons();
        screen.drawScore();
        screen.drawFruit();
    };

    return {
        // inherit script state functions
        __proto__: scriptState,

        // freeze for a moment, then shrink and explode
        triggers: {
            60: {
                init: function() { // freeze
                    commonDraw();
                    screen.drawPacman();
                },
            },
            120: {
                draw: function(t) { // shrink
                    commonDraw();
                    screen.drawCenteredSquare(pacman.pixel.x, pacman.pixel.y, pacman.color, actorSize*(60-t)/60);
                },
            },
            180: {
                draw: function(t) { // explode
                    commonDraw();
                    var p = t/15;
                    screen.drawCenteredSquare(pacman.pixel.x, pacman.pixel.y, "rgba(255,255,0,"+(1-p)+")", actorSize*p);
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
        screen.drawMap();
        screen.blitMap();
        screen.drawEnergizers();
        screen.drawExtraLives();
        screen.drawLevelIcons();
        screen.drawScore();
        screen.drawFruit();
        screen.drawPacman();
    };
    
    var flashFloor = function() {
        tileMap.toggleFloorFlash();
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
                    game.switchState(readyNewState);
                    tileMap.resetCurrent();
                }
            },
        },
    };
})();

////////////////////////////////////////////////////

// display game over
var overState = {
    init: function() {
        screen.drawMessage("game over", "#F00");
        clickState.nextState = newGameState;
        game.switchState(clickState);
    },
    draw: function() {},
    update: function() {},
};
