
// REFERENCED GLOBALS:
/* global Actor -- Actor.js */
/* global map -- maps.js */
/* global setDirFromEnum, isNextTileFloor, getOpenTiles, getTurnClosestToTarget -- direction.js */
/* global turboMode, level, gameMode, GAME_MSPACMAN, GAME_COOKIE, GAME_OTTO, addScore -- game.js */
/* global energizer -- energizer.js */
/* global STEP_PACMAN_FRIGHT, STEP_PACMAN -- Actor.js */
/* global state, deadState -- states.js */
/* global ghostReleaser -- ghostReleaser.js */
/* global fruit -- fruit.js */

//////////////////////////////////////////////////////////////////////////////////////
// Player is the controllable character (Pac-Man)

// Player constructor
class Player extends Actor {
    constructor() {

        // inherit data from Actor
        super();
        if (gameMode == GAME_MSPACMAN || gameMode == GAME_COOKIE) {
            this.frames = 1; // start with mouth open
        }

        this.nextDir = {};

        // determines if this player should be AI controlled
        this.ai = false;
        this.invincible = false;

        this.savedNextDirEnum = {};
        this.savedStopped = {};
        this.savedEatPauseFramesLeft = {};
    }

    save(t) {
        this.savedEatPauseFramesLeft[t] = this.eatPauseFramesLeft;
        this.savedNextDirEnum[t] = this.nextDirEnum;
        this.savedStopped[t] = this.stopped;
        super.save(t);
    }

    load(t) {
        this.eatPauseFramesLeft = this.savedEatPauseFramesLeft[t];
        this.setNextDir(this.savedNextDirEnum[t]);
        this.stopped = this.savedStopped[t];
        this.inputDirEnum = undefined;
        super.load(t);
    }

    // reset the state of the player on new level or level restart
    reset() {
        this.setNextDir(this.startDirEnum);
        this.stopped = false;
        this.inputDirEnum = undefined;

        this.eatPauseFramesLeft = 0;   // current # of frames left to pause after eating

        // call Actor's reset function to reset to initial position and direction
        super.reset();

    }

    // sets the next direction and updates its dependent variables
    setNextDir(nextDirEnum) {
        setDirFromEnum(this.nextDir, nextDirEnum);
        this.nextDirEnum = nextDirEnum;
    }

    // gets the number of steps to move in this frame
    getNumSteps() {
        if (turboMode)
            return 2;

        const pattern = energizer.isActive() ? STEP_PACMAN_FRIGHT : STEP_PACMAN;
        return this.getStepSizeFromTable(level, pattern);
    }

    getStepFrame(steps) {
        if (steps == undefined) {
            steps = this.steps;
        }
        return Math.floor(steps/2)%4;
    }

    getAnimFrame(frame) {
        if (frame == undefined) {
            frame = this.getStepFrame();
        }
        if (gameMode == GAME_MSPACMAN || gameMode == GAME_COOKIE) { // ms. pacman starts with mouth open
            frame = (frame+1)%4;
            if (state == deadState)
                frame = 1; // hack to force this frame when dead
        }
        if (gameMode != GAME_OTTO) {
            if (frame == 3) 
                frame = 1;
        }
        return frame;
    }

    setInputDir(dirEnum) {
        this.inputDirEnum = dirEnum;
    }

    clearInputDir(dirEnum) {
        if (dirEnum == undefined || this.inputDirEnum == dirEnum) {
            this.inputDirEnum = undefined;
        }
    }

    // move forward one step
    step() {

        // just increment if we're not in a map
        if (!map) {
            this.setPos(this.pixel.x+this.dir.x, this.pixel.y+this.dir.y);
            return 1;
        }

        // identify the axes of motion
        const a = (this.dir.x != 0) ? 'x' : 'y'; // axis of motion
        const b = (this.dir.x != 0) ? 'y' : 'x'; // axis perpendicular to motion

        // Don't proceed past the middle of a tile if facing a wall
        this.stopped = this.stopped || (this.distToMid[a] == 0 && !isNextTileFloor(this.tile, this.dir));
        if (!this.stopped) {
            // Move in the direction of travel.
            this.pixel[a] += this.dir[a];

            // Drift toward the center of the track (a.k.a. cornering)
            this.pixel[b] += Math.sign(this.distToMid[b]);
        }

        this.commitPos();
        return this.stopped ? 0 : 1;
    };

    // determine direction
    steer() {

        // if AI-controlled, only turn at mid-tile
        if (this.ai) {
            if (this.distToMid.x != 0 || this.distToMid.y != 0)
                return;

            // make turn that is closest to target
            const openTiles = getOpenTiles(this.tile, this.dirEnum);
            this.setTarget();
            this.setNextDir(getTurnClosestToTarget(this.tile, this.targetTile, openTiles));
        }
        else {
            this.targetting = undefined;
        }

        if (this.inputDirEnum == undefined) {
            if (this.stopped) {
                this.setDir(this.nextDirEnum);
            }
        }
        else {
            // Determine if input direction is open.
            const inputDir = {};
            setDirFromEnum(inputDir, this.inputDirEnum);
            const inputDirOpen = isNextTileFloor(this.tile, inputDir);

            if (inputDirOpen) {
                this.setDir(this.inputDirEnum);
                this.setNextDir(this.inputDirEnum);
                this.stopped = false;
            }
            else {
                if (!this.stopped) {
                    this.setNextDir(this.inputDirEnum);
                }
            }
        }
    }

    // update this frame
    update(j) {

        const numSteps = this.getNumSteps();
        if (j >= numSteps)
            return;

        // skip frames
        if (this.eatPauseFramesLeft > 0) {
            if (j == numSteps-1)
                this.eatPauseFramesLeft--;
            return;
        }

        // call super function to update position and direction
        super.update(j);

        // eat something
        if (map) {
            const t = map.getTile(this.tile.x, this.tile.y);
            if (t == '.' || t == 'o') {

                // apply eating drag (unless in turbo mode)
                if (!turboMode) {
                    this.eatPauseFramesLeft = (t=='.') ? 1 : 3;
                }

                map.onDotEat(this.tile.x, this.tile.y);
                ghostReleaser.onDotEat();
                fruit.onDotEat();
                addScore((t=='.') ? 10 : 50);

                if (t=='o')
                    energizer.activate();
            }
        }
    }
}
