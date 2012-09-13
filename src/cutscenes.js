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

var cutscenes = [
    [pacmanCutscene1], // GAME_PACMAN
    [], // GAME_MSPACMAN
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
