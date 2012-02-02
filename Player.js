// Player is the controllable character (Pac-Man)


// DEPENDENCIES:
// 1. energizedTimer
// 2. playEvents
// 3. game

// Player constructor
var Player = function() {

    // inherit data from Actor
    Actor.apply(this);

    this.eatPauseFramesLeft = 0;   // current # of frames left to pause after eating

    // next direction to be taken when possible (set by joystick)
    this.nextDir = {};             // x,y direction
    this.nextDirEnum = 0;          // direction enumeration

    // determines if this player should be AI controlled
    this.ai = false;
};

// inherit functions from Actor
Player.prototype.__proto__ = Actor.prototype;

// reset the state of the player on new level or level restart
Player.prototype.reset = function() {

    energizedTimer.reset();
    this.eatPauseFramesLeft = 0;
    this.setNextDir(DIR_LEFT);

    // call Actor's reset function to reset to initial position and direction
    Actor.prototype.reset.apply(this);
};

// sets the next direction and updates its dependent variables
Player.prototype.setNextDir = function(nextDirEnum) {
    setDirFromEnum(this.nextDir, nextDirEnum);
    this.nextDirEnum = nextDirEnum;
};

// gets the number of steps to move in this frame
Player.prototype.getNumSteps = function(frame) {
    var pattern = energizer.isActive() ? STEP_PACMAN_FRIGHT : STEP_PACMAN;
    return this.getStepSizeFromTable(game.level, pattern, frame);
};

// move forward one step
Player.prototype.step = function() {

    // identify the axes of motion
    var a = (this.dir.x != 0) ? 'x' : 'y'; // axis of motion
    var b = (this.dir.x != 0) ? 'y' : 'x'; // axis perpendicular to motion

    // Don't proceed past the middle of a tile if facing a wall
    var stop = this.distToMid[a] == 0 && !tileMap.isNextTileFloor(this.tile, this.dir);
    if (!stop)
        this.pixel[a] += this.dir[a];

    // Drift toward the center of the track (a.k.a. cornering)
    this.pixel[b] += sign(this.distToMid[b]);

    this.commitPos();
};

// determine direction
Player.prototype.steer = function() {

    // if AI-controlled, only turn at mid-tile
    if (this.ai) {
        if (this.distToMid.x != 0 || this.distToMid.y != 0)
            return;

        // make turn that is closest to target
        var openTiles = this.getOpenSurroundTiles();
        this.setTarget();
        this.setNextDir(this.getTurnClosestToTarget(openTiles));
    }

    // head in the desired direction if possible
    if (tileMap.isNextTileFloor(this.tile, this.nextDir))
        this.setDir(this.nextDirEnum);
};

// update this frame
Player.prototype.update = function() {

    // skip frames
    if (this.eatPauseFramesLeft > 0) {
        this.eatPauseFramesLeft--;
        return;
    }

    // handle energized timing
    energizedTimer.update();

    // call super function to update position and direction
    Actor.prototype.update.apply(this);

    // eat something
    var t = tileMap.getTile(this.tile.x, this.tile.y);
    if (t == '.' || t == 'o') {
        this.eatPauseFramesLeft = (t=='.') ? 1 : 3;

        playEvents.onDotEat();
        game.addScore((t=='.') ? 10 : 50);
        tileMap.erasePellet(this.tile.x, this.tile.y);

        if (++game.dotCount == tileMap.numDots)
            return;

        if (t == 'o')
            energizer.activate();
    }
};

