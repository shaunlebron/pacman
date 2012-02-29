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

// updates the position's dependent variables
Actor.prototype.commitPos = function() {

    // use map-specific tunnel teleport
    tileMap.teleport(this);

    this.tile.x = Math.floor(this.pixel.x / tileSize);
    this.tile.y = Math.floor(this.pixel.y / tileSize);
    this.tilePixel.x = this.pixel.x % tileSize;
    this.tilePixel.y = this.pixel.y % tileSize;
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

// retrieve four surrounding tiles and indicate whether they are open
getOpenSurroundTiles = function(tile,dirEnum) {

    // get open passages
    var openTiles = tileMap.getOpenTiles(tile).slice();
    var numOpenTiles = 0;
    var i;
    for (i=0; i<4; i++)
        if (openTiles[i])
            numOpenTiles++;

    // By design, no mazes should have dead ends,
    // but allow player to turn around if and only if it's necessary.
    // Only close the passage behind the player if there are other openings.
    var oppDirEnum = (dirEnum+2)%4; // current opposite direction enum
    if (numOpenTiles > 1)
        openTiles[oppDirEnum] = false;

    return openTiles;
};

// return the direction of the open, surrounding tile closest to our target
getTurnClosestToTarget = function(tile,targetTile,openTiles) {

    var dx,dy,dist;                      // variables used for euclidean distance
    var minDist = Infinity;              // variable used for finding minimum distance path
    var dir = {};
    var dirEnum = 0;
    var i;
    for (i=0; i<4; i++) {
        if (openTiles[i]) {
            setDirFromEnum(dir,i);
            dx = dir.x + tile.x - targetTile.x;
            dy = dir.y + tile.y - targetTile.y;
            dist = dx*dx+dy*dy;
            if (dist < minDist) {
                minDist = dist;
                dirEnum = i;
            }
        }
    }
    return dirEnum;
};

// draw a predicted path for the actor if it continues pursuing current target
var actorPathLength = 16;
Actor.prototype.drawPath = function(ctx) {
    if (!this.targetting) return;

    // current state of the predicted path
    var tile = { x: this.tile.x, y: this.tile.y};
    var target = this.targetTile;
    var dir = { x: this.dir.x, y: this.dir.y };
    var dirEnum = this.dirEnum;
    var openTiles;

    // if we are past the center of the tile, then we already know which direction to head for the next tile
    // so increment to next tile
    if ((dirEnum == DIR_UP && this.tilePixel.y <= midTile.y) ||
        (dirEnum == DIR_DOWN && this.tilePixel.y >= midTile.y) ||
        (dirEnum == DIR_LEFT && this.tilePixel.x <= midTile.x) ||
        (dirEnum == DIR_RIGHT & this.tilePixel.x >= midTile.x)) {
        tile.x += dir.x;
        tile.y += dir.y;
    }
    
    // dist keeps track of how far we're going along this path
    // we will stop at maxDist
    // distLeft determines how long the last line should be
    var dist = Math.abs(tile.x*tileSize+midTile.x - this.pixel.x + tile.y*tileSize+midTile.y - this.pixel.y);
    var maxDist = actorPathLength*tileSize;
    var distLeft;
    
    // add the first line
    ctx.strokeStyle = this.pathColor;
    ctx.beginPath();
    ctx.moveTo(
            this.pixel.x+this.pathCenter.x,
            this.pixel.y+this.pathCenter.y);
    ctx.lineTo(
            tile.x*tileSize+midTile.x+this.pathCenter.x,
            tile.y*tileSize+midTile.y+this.pathCenter.y);

    while (tile.x!=target.x || tile.y!=target.y) {

        // predict the next direction to turn at current tile
        openTiles = getOpenSurroundTiles(tile, dirEnum);
        if (this != pacman && tileMap.constrainGhostTurns)
            tileMap.constrainGhostTurns(tile, openTiles);
        dirEnum = getTurnClosestToTarget(tile, target, openTiles);
        setDirFromEnum(dir,dirEnum);
        
        // if the next tile is our target, determine how mush distance is left and break loop
        if (tile.x+dir.x == target.x && tile.y+dir.y == target.y) {
        
            distLeft = tileSize;
            
            // use pixel positions rather than tile positions for the target when possible
            // (for aesthetics)
            if (this.targetting=='pinky') {
                if (dirEnum == DIR_UP || dirEnum == DIR_DOWN)
                    distLeft = Math.abs(tile.y*tileSize + midTile.y - pinky.pixel.y);
                else
                    distLeft = Math.abs(tile.x*tileSize + midTile.x - pinky.pixel.x);
            }
            else if (this.targetting=='pacman') {
                if (this == blinky || this == clyde) {
                    if (dirEnum == DIR_UP || dirEnum == DIR_DOWN)
                        distLeft = Math.abs(tile.y*tileSize + midTile.y - pacman.pixel.y);
                    else
                        distLeft = Math.abs(tile.x*tileSize + midTile.x - pacman.pixel.x);
                }
                else if (this == pinky) {
                    if (dirEnum == DIR_UP || dirEnum == DIR_DOWN)
                        distLeft = Math.abs(tile.y*tileSize + midTile.y - (pacman.pixel.y + pacman.dir.y*tileSize*4));
                    else
                        distLeft = Math.abs(tile.x*tileSize + midTile.x - (pacman.pixel.x + pacman.dir.x*tileSize*4));
                }
            }
            if (dist + distLeft > maxDist)
                distLeft = maxDist - dist;
            break;
        }
        
        // exit if we're going past the max distance
        if (dist + tileSize > maxDist) {
            distLeft = maxDist - dist;
            break;
        }

        // move to next tile and add a line to its center
        tile.x += dir.x;
        tile.y += dir.y;
        dist += tileSize;
        ctx.lineTo(
                tile.x*tileSize+midTile.x+this.pathCenter.x,
                tile.y*tileSize+midTile.y+this.pathCenter.y);
    }

    // calculate final endpoint
    var px = tile.x*tileSize+midTile.x+this.pathCenter.x+distLeft*dir.x;
    var py = tile.y*tileSize+midTile.y+this.pathCenter.y+distLeft*dir.y;

    // add an arrow head
    ctx.lineTo(px,py);
    var s = 3;
    if (dirEnum == DIR_LEFT || dirEnum == DIR_RIGHT) {
        ctx.lineTo(px-s*dir.x,py+s*dir.x);
        ctx.moveTo(px,py);
        ctx.lineTo(px-s*dir.x,py-s*dir.x);
    }
    else {
        ctx.lineTo(px+s*dir.y,py-s*dir.y);
        ctx.moveTo(px,py);
        ctx.lineTo(px-s*dir.y,py-s*dir.y);
    }

    // draw path    
    ctx.stroke();
};
