////////////////////////////////////////////////
// Cutscenes
//

var triggerCutsceneAtEndLevel = function() {
    if (gameMode == GAME_PACMAN) {
        if (level == 2) {
            playCutScene(pacmanCutscene1, readyNewState);
            return true;
        }
        /*
        else if (level == 5) {
            playCutScene(pacmanCutscene2, readyNewState);
            return true;
        }
        else if (level >= 9 && (level-9)%4 == 0) {
            playCutScene(pacmanCutscene3, readyNewState);
            return true;
        }
        */
    }
    else if (gameMode == GAME_MSPACMAN) {
        if (level == 2) {
            playCutScene(mspacmanCutscene1, readyNewState);
            return true;
        }
    }

    // no cutscene triggered
    return false;
};

var playCutScene = function(cutScene, nextState) {

    // redraw map buffer with fruit list but no map structure
    map = undefined;
    renderer.drawMap(true);

    cutScene.nextState = nextState;
    switchState(cutScene, 60);
};

var pacmanCutscene1 = (function() {
    return {
        __proto__: scriptState,
        init: function() {
            scriptState.init.call(this);

            // initialize actor positions
            pacman.setPos(232, 164);
            blinky.setPos(257, 164);

            // initialize actor directions
            blinky.setDir(DIR_LEFT);
            blinky.faceDirEnum = DIR_LEFT;
            pacman.setDir(DIR_LEFT);

            // initialize misc actor properties
            blinky.scared = false;

            // clear other states
            clearCheats();
            energizer.reset();

            // temporarily override actor step sizes
            pacman.getNumSteps = function() {
                return Actor.prototype.getStepSizeFromTable.call(this, 5, STEP_PACMAN);
            };
            blinky.getNumSteps = function() {
                return Actor.prototype.getStepSizeFromTable.call(this, 5, STEP_ELROY2);
            };

            // temporarily override steering functions
            pacman.steer = blinky.steer = function(){};
        },
        triggers: {

            // Blinky chases Pac-Man
            0: {
                update: function() {
                    var j;
                    for (j=0; j<2; j++) {
                        pacman.update(j);
                        blinky.update(j);
                    }
                    pacman.frames++;
                    blinky.frames++;
                },
                draw: function() {
                    renderer.blitMap();
                    renderer.beginMapClip();
                    renderer.drawPlayer();
                    renderer.drawGhost(blinky);
                    renderer.endMapClip();
                },
            },

            // Pac-Man chases Blinky
            260: {
                init: function() {
                    pacman.setPos(-193, 155);
                    blinky.setPos(-8, 164);

                    // initialize actor directions
                    blinky.setDir(DIR_RIGHT);
                    blinky.faceDirEnum = DIR_RIGHT;
                    pacman.setDir(DIR_RIGHT);

                    // initialize misc actor properties
                    blinky.scared = true;

                    // temporarily override step sizes
                    pacman.getNumSteps = function() {
                        return Actor.prototype.getStepSizeFromTable.call(this, 5, STEP_PACMAN_FRIGHT);
                    };
                    blinky.getNumSteps = function() {
                        return Actor.prototype.getStepSizeFromTable.call(this, 5, STEP_GHOST_FRIGHT);
                    };
                },
                update: function() {
                    var j;
                    for (j=0; j<2; j++) {
                        pacman.update(j);
                        blinky.update(j);
                    }
                    pacman.frames++;
                    blinky.frames++;
                },
                draw: function() {
                    renderer.blitMap();
                    renderer.beginMapClip();
                    renderer.drawGhost(blinky);
                    renderer.renderFunc(function(ctx) {
                        var frame = Math.floor(pacman.steps/4) % 4; // slower to switch animation frame when giant
                        if (frame == 3) {
                            frame = 1;
                        }
                        drawGiantPacmanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum, frame);
                    });
                    renderer.endMapClip();
                },
            },

            // end
            640: {
                init: function() {
                    // disable custom steps
                    delete pacman.getNumSteps;
                    delete blinky.getNumSteps;

                    // disable custom steering
                    delete pacman.steer;
                    delete blinky.steer;

                    // exit to next level
                    switchState(pacmanCutscene1.nextState, 60);
                },
            },
        },
    };
})();

var mspacmanCutscene1 = (function() {

    var pac = new Player();
    var mspac = new Player();

    var drawPlayer = function(ctx,player) {
        var frame = player.getAnimFrame();
        var func;
        if (player == pac) {
            func = atlas.drawPacmanSprite;
        }
        else if (player == mspac) {
            func = atlas.drawMsPacmanSprite;
        }
        func(ctx, player.pixel.x, player.pixel.y, player.dirEnum, frame);
    };

    return {
        __proto__: scriptState,
        init: function() {
            scriptState.init.call(this);

            // initialize actor states
            pac.setPos(-10, 99);
            pac.setDir(DIR_RIGHT);
            mspac.setPos(232, 180);
            mspac.setDir(DIR_LEFT);
            
            // initial ghost states
            inky.frames = 0;
            inky.scared = false;
            inky.setPos(pac.pixel.x-42, 99);
            inky.setDir(DIR_RIGHT);
            inky.faceDirEnum = DIR_RIGHT;
            pinky.frames = 3;
            pinky.scared = false;
            pinky.setPos(mspac.pixel.x+49, 180);
            pinky.setDir(DIR_LEFT);
            pinky.faceDirEnum = DIR_LEFT;

            // clear other states
            clearCheats();
            energizer.reset();

            // step player animation every four frames
            pac.getStepFrame = function() { return Math.floor(this.frames/4)%4; };
            mspac.getStepFrame = function() { return Math.floor(this.frames/4)%4; };

            // step ghost animation every six frames
            inky.getAnimFrame = function() { return Math.floor(this.frames/8)%2; };
            pinky.getAnimFrame = function() { return Math.floor(this.frames/8)%2; };

            // set actor step sizes
            pac.getNumSteps = function() { return 1; };
            mspac.getNumSteps = function() { return 1; };
            inky.getNumSteps = function() { return 1; };
            pinky.getNumSteps = function() { return 1; };

            // set steering functions
            pac.steer = function(){};
            mspac.steer = function(){};
            inky.steer = function(){};
            pinky.steer = function(){};
        },
        triggers: {

            // Inky chases Pac, Pinky chases Mspac
            0: {
                update: function() {
                    var j;
                    for (j=0; j<2; j++) {
                        pac.update(j);
                        mspac.update(j);
                        inky.update(j);
                        pinky.update(j);
                    }
                    if (inky.pixel.x == 105) {
                        // speed up the ghosts
                        inky.getNumSteps = function() {
                            return Actor.prototype.getStepSizeFromTable.call(this, 5, STEP_ELROY2);
                        };
                        pinky.getNumSteps = function() {
                            return Actor.prototype.getStepSizeFromTable.call(this, 5, STEP_ELROY2);
                        };
                    }
                    pac.frames++;
                    mspac.frames++;
                    inky.frames++;
                    pinky.frames++;
                },
                draw: function() {
                    renderer.blitMap();
                    renderer.beginMapClip();
                    renderer.renderFunc(function(ctx) {
                        drawPlayer(ctx,pac);
                        drawPlayer(ctx,mspac);
                    });
                    renderer.drawGhost(inky);
                    renderer.drawGhost(pinky);
                    renderer.endMapClip();
                },
            },

            // end
            300: {
                init: function() {
                    // disable custom steps
                    delete inky.getNumSteps;
                    delete pinky.getNumSteps;

                    // disable custom steering
                    delete inky.steer;
                    delete pinky.steer;

                    // disable custom animation steps
                    delete inky.getAnimFrame;
                    delete pinky.getAnimFrame;

                    // exit to next level
                    switchState(mspacmanCutscene1.nextState, 60);
                },
            },
        },
    };
})();

var cutscenes = [
    [pacmanCutscene1], // GAME_PACMAN
    [mspacmanCutscene1], // GAME_MSPACMAN
    [], // GAME_COOKIE
    [], // GAME_OTTO
];

var isInCutScene = function() {
    var scenes = cutscenes[gameMode];
    var i,len = scenes.length;
    for (i=0; i<len; i++) {
        if (state == scenes[i]) {
            return true;
        }
    }
    return false;
};
