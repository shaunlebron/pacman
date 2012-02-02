
//
// ================ start states =================
//

var firstState = {};
firstState.init = function() {
    this.frames = 0;
    resetTiles();
};
firstState.draw = function() {
    blitBackground();
    drawEnergizers();
    drawExtraLives();
    drawLevelIcons();
    drawScore();
    drawMessage("ready","#FF0");
};
firstState.update = function() {
    if (this.frames == 2*60) {
        game.extraLives--;
        game.switchState(startState);
    }
    else 
        this.frames++;
};

////////////////////////////////////////////////////

// common start state when the all players return to their places
var commonStartState = {};
commonStartState.init = function() {
    var i;
    for (i=0; i<5; i++)
        actors[i].reset();
    this.frame = 0;
};
commonStartState.draw = function() {
    blitBackground();
    drawEnergizers();
    drawActors();
    drawExtraLives();
    drawLevelIcons();
    drawScore();
    drawMessage("ready","#FF0");
};
commonStartState.update = function() {
    if (this.frame == 2*60)
        game.switchState(playState);
    this.frame++;
};

////////////////////////////////////////////////////

// start state for new level
var startState = { __proto__:commonStartState };
startState.init = function() {
    counter.onNewLevel();
    commonStartState.init.apply(this);
};

////////////////////////////////////////////////////

// start state for restarting level
var restartState = { __proto__:commonStartState };
restartState.init = function() {
    game.extraLives--;
    counter.onRestartLevel();
    commonStartState.init.apply(this);
};

//
// ================== play state ======================
//
var playState = {};
playState.init = function() {
    this.skippedFramesLeft = 0;
};
playState.draw = function() {
    blitBackground();
    drawEnergizers();
    drawFruit();
    drawActors();
    drawExtraLives();
    drawLevelIcons();
    drawScore();
};
playState.update = function() {

    var i;

    // skip this frame if needed,
    // but update ghosts running home
    if (energizer.isShowingPoints()) {
        for (i=0; i<4; i++)
            if (actors[i].mode == GHOST_GOING_HOME)
                actors[i].update();
        energizer.updatePointTimer();
    }

    // update counter
    counter.update();

    // update actors
    for (i = 0; i<5; i++)
        actors[i].update();

    // test pacman collision with each ghost
    var g; // temporary ghost variable
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

    // test collision with fruit
    fruit.testCollide();

    // finish level if all dots have been eaten
    if (game.dotCount == game.maxDots) {
        game.switchState(finishState);
    }
};

//
// ============== scripted states ===================
//

// a script state is special state that takes a dictionary
// of functions whose keys contain the time at which they
// are to begin execution.
// The functions are called by draw() and they are passed
// the current frame number starting at 0.
var scriptState = {};
scriptState.init = function() {
    this.frames = 0;
    this.scriptFunc = this.script[0];
    this.scriptFuncFrame = 0;
};
scriptState.draw = function() {
    blitBackground();
    drawEnergizers();
    drawExtraLives();
    drawLevelIcons();
    drawScore();
    this.scriptFunc(this.frames - this.scriptFuncFrame);
};
scriptState.update = function() {
    if (this.script[this.frames] != undefined) {
        this.firstFrame = true;
        this.scriptFunc = this.script[this.frames];
        this.scriptFuncFrame = this.frames;
    }
    this.frames++;
};

////////////////////////////////////////////////////

// freeze for a moment, then shrink and explode
var deadState = { __proto__: scriptState };
deadState.script = {
    0 : function(t) { drawActors(); },
    60 : function(t) { drawPacman(); },
    120 : function(t) { drawActor(pacman.pixel.x, pacman.pixel.y, pacman.color, actorSize*(60-t)/60); },
    180 : function(t) { var p = t/15; drawActor(pacman.pixel.x, pacman.pixel.y, "rgba(255,255,0,"+(1-p)+ ")", actorSize*p); },
    240 : function(t) { this.leave(); } 
};
deadState.leave = function() {
    game.switchState( game.extraLives == 0 ? overState : restartState);
};

////////////////////////////////////////////////////

// freeze for a moment then flash the tiles four times
var finishState = { __proto__: scriptState };
finishState.flashFloor = function(t) {
    if (this.firstFrame) {
        this.firstFrame = false;
        tileMap.toggleFloorFlash();
        drawBackground();
    }
    drawPacman();
};
finishState.leave = function() {
    game.level++;
    game.switchState(startState);
    resetTiles();
};
finishState.script = {
    0 : drawActors,
    60: drawPacman,
    120: finishState.flashFloor,
    135: finishState.flashFloor,
    150: finishState.flashFloor,
    165: finishState.flashFloor,
    180: finishState.flashFloor,
    195: finishState.flashFloor,
    210: finishState.flashFloor,
    225: finishState.flashFloor,
    255: finishState.leave,
};

////////////////////////////////////////////////////

// display game over
var overState = {};
overState.init = function() {
    // restart game when canvas is clicked
    canvas.onmousedown = function() {
        game.init();
        canvas.onmousedown = undefined;
    };
};
overState.draw = function() {
    blitBackground();
    drawEnergizers();
    drawExtraLives();
    drawLevelIcons();
    drawScore();
    drawMessage("game over", "#F00");
};
overState.update = function() {};

