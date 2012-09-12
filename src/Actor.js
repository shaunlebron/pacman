//////////////////////////////////////////////////////////////////////////////////////
// The actor class defines common data functions for the ghosts and pacman
// It provides everything for updating position and direction.

// "Ghost" and "Player" inherit from this "Actor"

// Actor constructor
var Actor = function() {

    this.dir = {};          // facing direction vector
    this.pixel = {};        // pixel position
    this.tile = {};         // tile position
    this.tilePixel = {};    // pixel location inside tile
    this.distToMid = {};    // pixel distance to mid-tile

    this.targetTile = {};   // tile position used for targeting

    this.frames = 0;        // frame count
    this.steps = 0;         // step count

    this.isDrawTarget = false;
    this.isDrawPath = false;

    this.savedSteps = {};
    this.savedFrames = {};
    this.savedDirEnum = {};
    this.savedPixel = {};
    this.savedTargetting = {};
    this.savedTargetTile = {};
};

// save state at time t
Actor.prototype.save = function(t) {
    this.savedSteps[t] = this.steps;
    this.savedFrames[t] = this.frames;
    this.savedDirEnum[t] = this.dirEnum;
    this.savedPixel[t] = { x:this.pixel.x, y:this.pixel.y };
    this.savedTargetting[t] = this.targetting;
    this.savedTargetTile[t] = { x: this.targetTile.x, y: this.targetTile.y };
};

// load state at time t
Actor.prototype.load = function(t) {
    this.steps = this.savedSteps[t];
    this.frames = this.savedFrames[t];
    this.setDir(this.savedDirEnum[t]);
    this.setPos(this.savedPixel[t].x, this.savedPixel[t].y);
    this.targetting = this.savedTargetting[t];
    this.targetTile.x = this.savedTargetTile[t].x;
    this.targetTile.y = this.savedTargetTile[t].y;
};


// reset to initial position and direction
Actor.prototype.reset = function() {
    this.setDir(this.startDirEnum);
    this.setPos(this.startPixel.x, this.startPixel.y);
    this.frames = 0;
    this.steps = 0;
    this.targetting = false;
};

// sets the position and updates its dependent variables
Actor.prototype.setPos = function(px,py) {
    this.pixel.x = px;
    this.pixel.y = py;
    this.commitPos();
};

// returns the relative pixel inside a tile given a map pixel
Actor.prototype.getTilePixel = function(pixel,tilePixel) {
    if (pixel == undefined) {
        pixel = this.pixel;
    }
    if (tilePixel == undefined) {
        tilePixel = {};
    }
    tilePixel.x = pixel.x % tileSize;
    tilePixel.y = pixel.y % tileSize;
    if (tilePixel.x < 0) {
        tilePixel.x += tileSize;
    }
    if (tilePixel.y < 0) {
        tilePixel.y += tileSize;
    }
    return tilePixel;
};

// updates the position's dependent variables
Actor.prototype.commitPos = function() {

    // use map-specific tunnel teleport
    if (map) {
        map.teleport(this);
    }

    this.tile.x = Math.floor(this.pixel.x / tileSize);
    this.tile.y = Math.floor(this.pixel.y / tileSize);
    this.getTilePixel(this.pixel,this.tilePixel);
    this.distToMid.x = midTile.x - this.tilePixel.x;
    this.distToMid.y = midTile.y - this.tilePixel.y;
};

// sets the direction and updates its dependent variables
Actor.prototype.setDir = function(dirEnum) {
    setDirFromEnum(this.dir, dirEnum);
    this.dirEnum = dirEnum;
};

// used as "pattern" parameter in getStepSizeFromTable()
var STEP_PACMAN = 0;
var STEP_GHOST = 1;
var STEP_PACMAN_FRIGHT = 2;
var STEP_GHOST_FRIGHT = 3;
var STEP_GHOST_TUNNEL = 4;
var STEP_ELROY1 = 5;
var STEP_ELROY2 = 6;

// getter function to extract a step size from speed control table
Actor.prototype.getStepSizeFromTable = (function(){

    // Actor speed is controlled by a list of 16 values.
    // Each value is the number of steps to take in a specific frame.
    // Once the end of the list is reached, we cycle to the beginning.
    // This method allows us to represent different speeds in a low-resolution space.

    // speed control table (from Jamey Pittman)
    var stepSizes = (
                         // LEVEL 1
    "1111111111111111" + // pac-man (normal)
    "0111111111111111" + // ghosts (normal)
    "1111211111112111" + // pac-man (fright)
    "0110110101101101" + // ghosts (fright)
    "0101010101010101" + // ghosts (tunnel)
    "1111111111111111" + // elroy 1
    "1111111121111111" + // elroy 2

                         // LEVELS 2-4
    "1111211111112111" + // pac-man (normal)
    "1111111121111111" + // ghosts (normal)
    "1111211112111121" + // pac-man (fright)
    "0110110110110111" + // ghosts (fright)
    "0110101011010101" + // ghosts (tunnel)
    "1111211111112111" + // elroy 1
    "1111211112111121" + // elroy 2

                         // LEVELS 5-20
    "1121112111211121" + // pac-man (normal)
    "1111211112111121" + // ghosts (normal)
    "1121112111211121" + // pac-man (fright) (N/A for levels 17, 19 & 20)
    "0111011101110111" + // ghosts (fright)  (N/A for levels 17, 19 & 20)
    "0110110101101101" + // ghosts (tunnel)
    "1121112111211121" + // elroy 1
    "1121121121121121" + // elroy 2

                         // LEVELS 21+
    "1111211111112111" + // pac-man (normal)
    "1111211112111121" + // ghosts (normal)
    "0000000000000000" + // pac-man (fright) N/A
    "0000000000000000" + // ghosts (fright)  N/A
    "0110110101101101" + // ghosts (tunnel)
    "1121112111211121" + // elroy 1
    "1121121121121121"); // elroy 2

    return function(level, pattern) {
        var entry;
        if (level < 1) return;
        else if (level==1)                  entry = 0;
        else if (level >= 2 && level <= 4)  entry = 1;
        else if (level >= 5 && level <= 20) entry = 2;
        else if (level >= 21)               entry = 3;
        return stepSizes[entry*7*16 + pattern*16 + this.frames%16];
    };
})();

// updates the actor state
Actor.prototype.update = function(j) {

    // get number of steps to advance in this frame
    var numSteps = this.getNumSteps();
    if (j >= numSteps) 
        return;

    // request to advance one step, and increment count if step taken
    this.steps += this.step();

    // update head direction
    this.steer();
};
