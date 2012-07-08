//////////////////////////////////////////////////////////////////////////////////////
// Ghost class

// modes representing the ghost's current state
var GHOST_OUTSIDE = 0;
var GHOST_EATEN = 1;
var GHOST_GOING_HOME = 2;
var GHOST_ENTERING_HOME = 3;
var GHOST_PACING_HOME = 4;
var GHOST_LEAVING_HOME = 5;

// Ghost constructor
var Ghost = function() {
    // inherit data from Actor
    Actor.apply(this);
    this.randomScatter = false;
};

// inherit functions from Actor class
Ghost.prototype.__proto__ = Actor.prototype;

// reset the state of the ghost on new level or level restart
Ghost.prototype.reset = function() {

    // signals
    this.sigReverse = false;
    this.sigLeaveHome = false;

    // modes
    this.mode = this.startMode;
    this.scared = false;

    this.savedSigReverse = {};
    this.savedSigLeaveHome = {};
    this.savedMode = {};
    this.savedScared = {};
    this.savedElroy = {};

    // call Actor's reset function to reset position and direction
    Actor.prototype.reset.apply(this);
};

Ghost.prototype.save = function(t) {
    this.savedSigReverse[t] = this.sigReverse;
    this.savedSigLeaveHome[t] = this.sigLeaveHome;
    this.savedMode[t] = this.mode;
    this.savedScared[t] = this.scared;
    if (this == blinky) {
        this.savedElroy[t] = this.elroy;
    }
    Actor.prototype.save.call(this,t);
};

Ghost.prototype.load = function(t) {
    this.sigReverse = this.savedSigReverse[t];
    this.sigLeaveHome = this.savedSigLeaveHome[t];
    this.mode = this.savedMode[t];
    this.scared = this.savedScared[t];
    if (this == blinky) {
        this.elroy = this.savedElroy[t];
    }
    Actor.prototype.load.call(this,t);
};

// indicates if we slow down in the tunnel
Ghost.prototype.isSlowInTunnel = function() {
    // special case for Ms. Pac-Man (slow down only for the first three levels)
    if (gameMode == GAME_MSPACMAN)
        return level <= 3;
    else
        return true;
};

// gets the number of steps to move in this frame
Ghost.prototype.getNumSteps = function() {

    var pattern = STEP_GHOST;

    if (state == menuState)
        pattern = STEP_GHOST;
    else if (this.mode == GHOST_GOING_HOME || this.mode == GHOST_ENTERING_HOME)
        return 2;
    else if (this.mode == GHOST_LEAVING_HOME || this.mode == GHOST_PACING_HOME)
        pattern = STEP_GHOST_TUNNEL;
    else if (map.isTunnelTile(this.tile.x, this.tile.y) && this.isSlowInTunnel())
        pattern = STEP_GHOST_TUNNEL;
    else if (this.scared)
        pattern = STEP_GHOST_FRIGHT;
    else if (this.elroy == 1)
        pattern = STEP_ELROY1;
    else if (this.elroy == 2)
        pattern = STEP_ELROY2;

    return this.getStepSizeFromTable(level ? level : 1, pattern);
};

// signal ghost to reverse direction after leaving current tile
Ghost.prototype.reverse = function() {
    this.sigReverse = true;
};

// signal ghost to go home
// It is useful to have this because as soon as the ghost gets eaten,
// we have to freeze all the actors for 3 seconds, except for the
// ones who are already traveling to the ghost home to be revived.
// We use this signal to change mode to GHOST_GOING_HOME, which will be
// set after the update() function is called so that we are still frozen
// for 3 seconds before traveling home uninterrupted.
Ghost.prototype.goHome = function() {
    this.mode = GHOST_EATEN;
};

// Following the pattern that state changes be made via signaling (e.g. reversing, going home)
// the ghost is commanded to leave home similarly.
// (not sure if this is correct yet)
Ghost.prototype.leaveHome = function() {
    this.sigLeaveHome = true;
};

// function called when pacman eats an energizer
Ghost.prototype.onEnergized = function() {
    // only reverse if we are in an active targetting mode
    if (this.mode == GHOST_OUTSIDE)
        this.reverse();

    // only scare me if not already going home
    if (this.mode != GHOST_GOING_HOME && this.mode != GHOST_ENTERING_HOME) {
        this.scared = true;
        this.targetting = undefined;
    }
};

// function called when this ghost gets eaten
Ghost.prototype.onEaten = function() {
    this.goHome();       // go home
    this.scared = false; // turn off scared
};

// move forward one step
Ghost.prototype.step = function() {
    this.setPos(this.pixel.x+this.dir.x, this.pixel.y+this.dir.y);
    return 1;
};

// ghost home-specific path steering
Ghost.prototype.homeSteer = (function(){

    // steering functions to execute for each mode
    var steerFuncs = {};

    steerFuncs[GHOST_GOING_HOME] = function() {
        // at the doormat
        if (this.tile.x == map.doorTile.x && this.tile.y == map.doorTile.y) {
            this.targetting = false;
            // walk to the door, or go through if already there
            if (this.pixel.x == map.doorPixel.x) {
                this.mode = GHOST_ENTERING_HOME;
                this.setDir(DIR_DOWN);
            }
            else
                this.setDir(DIR_RIGHT);
        }
    };

    steerFuncs[GHOST_ENTERING_HOME] = function() {
        if (this.pixel.y == map.homeBottomPixel)
            // revive if reached its seat
            if (this.pixel.x == this.startPixel.x) {
                this.setDir(DIR_UP);
                this.mode = this.arriveHomeMode;
            }
            // sidestep to its seat
            else
                this.setDir(this.startPixel.x < this.pixel.x ? DIR_LEFT : DIR_RIGHT);
    };

    steerFuncs[GHOST_PACING_HOME] = function() {
        // head for the door
        if (this.sigLeaveHome) {
            this.sigLeaveHome = false;
            this.mode = GHOST_LEAVING_HOME;
            if (this.pixel.x == map.doorPixel.x)
                this.setDir(DIR_UP);
            else
                this.setDir(this.pixel.x < map.doorPixel.x ? DIR_RIGHT : DIR_LEFT);
        }
        // pace back and forth
        else {
            if (this.pixel.y == map.homeTopPixel)
                this.setDir(DIR_DOWN);
            else if (this.pixel.y == map.homeBottomPixel)
                this.setDir(DIR_UP);
        }
    };

    steerFuncs[GHOST_LEAVING_HOME] = function() {
        if (this.pixel.x == map.doorPixel.x)
            // reached door
            if (this.pixel.y == map.doorPixel.y) {
                this.mode = GHOST_OUTSIDE;
                this.setDir(DIR_LEFT); // always turn left at door?
            }
            // keep walking up to the door
            else
                this.setDir(DIR_UP);
    };

    // return a function to execute appropriate steering function for a given ghost
    return function() { 
        var f = steerFuncs[this.mode];
        if (f)
            f.apply(this);
    };

})();

// special case for Ms. Pac-Man game that randomly chooses a corner for blinky and pinky when scattering
Ghost.prototype.isScatterBrain = function() {
    return (
        (gameMode == GAME_MSPACMAN || gameMode == GAME_COOKIE) &&
        ghostCommander.getCommand() == GHOST_CMD_SCATTER &&
        (this == blinky || this == pinky));
};

// determine direction
Ghost.prototype.steer = function() {

    var dirEnum;                         // final direction to update to
    var openTiles;                       // list of four booleans indicating which surrounding tiles are open
    var oppDirEnum = (this.dirEnum+2)%4; // current opposite direction enum
    var actor;                           // actor whose corner we will target

    // reverse direction if commanded
    if (this.sigReverse && this.mode == GHOST_OUTSIDE) {
        // reverse direction only if we've reached a new tile
        if ((this.dirEnum == DIR_UP && this.tilePixel.y == tileSize-1) ||
            (this.dirEnum == DIR_DOWN && this.tilePixel.y == 0) ||
            (this.dirEnum == DIR_LEFT && this.tilePixel.x == tileSize-1) ||
            (this.dirEnum == DIR_RIGHT && this.tilePixel.x == 0)) {
                this.sigReverse = false;
                this.setDir(oppDirEnum);
                return;
        }
    }

    // special map-specific steering when going to, entering, pacing inside, or leaving home
    this.homeSteer();

    oppDirEnum = (this.dirEnum+2)%4; // current opposite direction enum

    // only execute rest of the steering logic if we're pursuing a target tile
    if (this.mode != GHOST_OUTSIDE && this.mode != GHOST_GOING_HOME) {
        this.targetting = false;
        return;
    }

    // don't steer if we're not at the middle of the tile
    if (this.distToMid.x != 0 || this.distToMid.y != 0)
        return;

    // get surrounding tiles and their open indication
    openTiles = getOpenTiles(this.tile, this.dirEnum);

    if (this.scared) {
        // choose a random turn
        dirEnum = Math.floor(Math.random()*4);
        while (!openTiles[dirEnum])
            dirEnum = (dirEnum+1)%4;
        this.targetting = false;
    }
    else {
        // target ghost door
        if (this.mode == GHOST_GOING_HOME) {
            this.targetTile.x = map.doorTile.x;
            this.targetTile.y = map.doorTile.y;
        }
        // target corner when scattering
        else if (!this.elroy && ghostCommander.getCommand() == GHOST_CMD_SCATTER) {

            actor = this.isScatterBrain() ? actors[Math.floor(Math.random()*4)] : this;

            this.targetTile.x = actor.cornerTile.x;
            this.targetTile.y = actor.cornerTile.y;
            this.targetting = 'corner';
        }
        // use custom function for each ghost when in attack mode
        else
            this.setTarget();

        // edit openTiles to reflect the current map's special contraints
        if (map.constrainGhostTurns)
            map.constrainGhostTurns(this.tile, openTiles);

        // choose direction that minimizes distance to target
        dirEnum = getTurnClosestToTarget(this.tile, this.targetTile, openTiles);
    }

    // commit the direction
    this.setDir(dirEnum);
};

