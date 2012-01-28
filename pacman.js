// Pac-Man
// Thanks to Jamey Pittman for "The Pac-Man Dossier"

//
// =========== TILE MAP ============
//

// number of tiles
var tileCols = 28;
var tileRows = 36;

// ascii map tiles
// used as the initial state for all the levels
var tiles = (
"____________________________" +
"____________________________" +
"____________________________" +
"||||||||||||||||||||||||||||" +
"|............||............|" +
"|.||||.|||||.||.|||||.||||.|" +
"|o|__|.|___|.||.|___|.|__|o|" +
"|.||||.|||||.||.|||||.||||.|" +
"|..........................|" +
"|.||||.||.||||||||.||.||||.|" +
"|.||||.||.||||||||.||.||||.|" +
"|......||....||....||......|" +
"||||||.||||| || |||||.||||||" +
"_____|.||||| || |||||.|_____" +
"_____|.||          ||.|_____" +
"_____|.|| |||--||| ||.|_____" +
"||||||.|| |______| ||.||||||" +
"      .   |______|   .      " +
"||||||.|| |______| ||.||||||" +
"_____|.|| |||||||| ||.|_____" +
"_____|.||          ||.|_____" +
"_____|.|| |||||||| ||.|_____" +
"||||||.|| |||||||| ||.||||||" +
"|............||............|" +
"|.||||.|||||.||.|||||.||||.|" +
"|.||||.|||||.||.|||||.||||.|" +
"|o..||.......  .......||..o|" +
"|||.||.||.||||||||.||.||.|||" +
"|||.||.||.||||||||.||.||.|||" +
"|......||....||....||......|" +
"|.||||||||||.||.||||||||||.|" +
"|.||||||||||.||.||||||||||.|" +
"|..........................|" +
"||||||||||||||||||||||||||||" +
"____________________________" +
"____________________________");

// row for the displayed message
var messageRow = 22;

// tile size and midpoint in pixels
var tileSize = 8;
var midTile = {x:3, y:4};

// actor size
var actorSize = (tileSize-1)*2;

// current tile state
// a copy of the initial state, with edits to represent the eaten dots
var currentTiles;

// reset the dot count and 
// use a fresh copy the initial tile state
var resetTiles = function() {
    game.dotCount = 0;
    currentTiles = tiles.split("");
};

// define which tiles are inside the tunnel
var isTunnelTile = function(x,y) {
    return (y == 17 && (x <= 5 || x >= tileCols-1-5));
};

// represent the offscreen tiles for the tunnel
// which extends two tiles past the end of the map on both sides
var isOffscreenTunnelTile = function(x,y) {
    return (y == 17 && (x<0 || x>tileCols-1));
};
var getTile = function(x,y) {
    if (x>=0 && x<tileCols && y>=0 && y<tileRows) 
        return currentTiles[x+y*tileCols];
    if (isOffscreenTunnelTile(x,y))
        return ' ';
};

// tunnel portal locations
tunnelLeftEndPixel = -2*tileSize;
tunnelRightEndPixel = (tileCols+2)*tileSize-1;

// ghosts cannot go up at these tiles
var ghostCannotGoUpAtTile = function(x,y) {
    return (x == 12 || x == 15) && (y == 14 || y == 26);
}

// locations of the ghost door and home boundaries
// ghosts are steered inside the home using these locations
var ghostDoorTile = {x:13, y:14};
var ghostDoorPixel = {x:(ghostDoorTile.x+1)*tileSize-1, y:ghostDoorTile.y*tileSize + midTile.y};
var ghostHomeLeftPixel = ghostDoorPixel.x - 2*tileSize;
var ghostHomeRightPixel = ghostDoorPixel.x + 2*tileSize;
var ghostHomeTopPixel = 17*tileSize;
var ghostHomeBottomPixel = 18*tileSize;

//
// ========== TILE DRAWING ============
//

// draw background
var drawBackground = function() {
    ctx.fillStyle = "#333";
    ctx.fillRect(0,0,ctx_w,ctx_h);
};

// draw floor tile
var drawFloor = function(x,y,color,pad) {
    ctx.fillStyle = color;
    ctx.fillRect(x*tileSize+pad,y*tileSize+pad,tileSize-2*pad,tileSize-2*pad);
};

// draw actor just as a block
var drawActor = function(px,py,color,size) {
    ctx.fillStyle = color;
    ctx.fillRect(px-size/2, py-size/2, size, size);
};

// draw message
var drawMessage = function(text, color) {
    var w = ctx.measureText(text).width;
    ctx.fillStyle = color;
    ctx.fillText(text, tileCols*tileSize/2 - w/2, messageRow*tileSize);
};

var drawExtraLives = function() {
    var i;
    for (i=0; i<game.extraLives; i++)
        drawActor((2*i+3)*tileSize, (tileRows-2)*tileSize+midTile.y,"rgba(255,255,0,0.6)",actorSize);
};

// floor colors to use when flashing after finishing a level
var normalFloorColor = "#555";
var brightFloorColor = "#999";

// current floor color
var floorColor = normalFloorColor;

// draw functions for each possible tile
var tileDraw = {};
tileDraw['|'] = function(x,y) { }; // wall
tileDraw['.'] = function(x,y) { drawFloor(x,y,"#888",0); }; // pellet
tileDraw['o'] = function(x,y) { }; // energizer
tileDraw[' '] = function(x,y) { drawFloor(x,y,floorColor,0); }; // floor
tileDraw['_'] = function(x,y) { }; // dead space
tileDraw['-'] = function(x,y) { }; // ghost door

// determines if a given tile character is a walkable floor
var isFloorTile = function(t) {
    return t==' ' || t=='.' || t=='o';
};

// parse energizer locations from map
var numEnergizers = 0;
var energizers = [];
(function() {
    var x,y;
    var i=0;
    for (y=0; y<tileRows; y++)
    for (x=0; x<tileCols; x++)
        if (tiles[i++] == 'o') {
            numEnergizers++;
            energizers.push({'x':x,'y':y});
        }
})();

// draw the current tile map
var drawTiles = function () {
    var x,y;
    var i=0;
    for (y=0; y<tileRows; y++)
    for (x=0; x<tileCols; x++)
        tileDraw[currentTiles[i++]](x,y);

    // must draw the energizers last because they are larger than surround tiles
    var e;
    for (i=0; i<numEnergizers; i++) {
        e = energizers[i];
        if (currentTiles[e.x+e.y*tileCols] == 'o')
            drawFloor(e.x,e.y,"#FFF",-1);
    }
};

//
// ============ TILE DIRECTION ============
// 

// We use both enums and vectors to represent actor direction
// because they are both convenient in different cases.

// direction enums (in clockwise order)
var DIR_UP = 0;
var DIR_RIGHT = 1;
var DIR_DOWN = 2;
var DIR_LEFT = 3;

// get direction enum from a direction vector
var getEnumFromDir = function(dir) {
    if (dir.x==-1) return DIR_LEFT;
    if (dir.x==1) return DIR_RIGHT;
    if (dir.y==-1) return DIR_UP;
    if (dir.y==1) return DIR_DOWN;
};

// set direction vector from a direction enum
var setDirFromEnum = function(dir,dirEnum) {
    if (dirEnum == DIR_UP)         { dir.x = 0; dir.y =-1; }
    else if (dirEnum == DIR_RIGHT)  { dir.x =1; dir.y = 0; }
    else if (dirEnum == DIR_DOWN)  { dir.x = 0; dir.y = 1; }
    else if (dirEnum == DIR_LEFT) { dir.x = -1; dir.y = 0; }
};

// get a list of the four surrounding tiles
var getSurroundingTiles = function(tile) {
    return [
        getTile(tile.x, tile.y-1), // DIR_UP
        getTile(tile.x+1, tile.y), // DIR_RIGHT
        getTile(tile.x, tile.y+1), // DIR_DOWN
        getTile(tile.x-1, tile.y)  // DIR_LEFT
    ];
};

// get a tile next to the given tile
var getNextTile = function(tile, dir) {
    return getTile(tile.x+dir.x, tile.y+dir.y);
};

//
// ============ ACTOR SPEEDS ============
//

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

// used as "pattern" parameter in getStepSizeFromTable()
var STEP_PACMAN = 0;
var STEP_GHOST = 1;
var STEP_PACMAN_FRIGHT = 2;
var STEP_GHOST_FRIGHT = 3;
var STEP_GHOST_TUNNEL = 4;
var STEP_ELROY1 = 5;
var STEP_ELROY2 = 6;

// getter function to extract a step size from the table
var getStepSizeFromTable = function(level, pattern, frame) {
    var entry;
    if (level < 1) return;
    else if (level==1)                  entry = 0;
    else if (level >= 2 && level <= 4)  entry = 1;
    else if (level >= 5 && level <= 20) entry = 2;
    else if (level >= 21)               entry = 3;
    return stepSizes[entry*7*16 + pattern*16 + frame%16];
};

//
// ============= COMMON ACTOR ==============
//

// The actor class defines common data functions for the ghosts and pacman
// It provides everything for updating position and direction.

// Actor constructor
var Actor = function() {

    // initial position and direction
    this.startPixel = {};  // x,y pixel starting position (0<=x<tileCols*tileSize, 0<=y<tileRows*tileSize)
    this.startDirEnum = 0; // starting direction enumeration (0<=x,y<=4)

    // current position
    this.tile = {};        // x,y tile position (0<=x<tileCols, 0<=y<tileRows)
    this.pixel = {};       // x,y pixel position (0<=x<tileCols*tileSize, 0<=y<tileRows*tileSize)
    this.tilePixel = {};   // x,y pixel in tile (0<=x,y<tileSize)
    this.distToMid = {};   // x,y pixel distance from center of tile

    // current direction
    this.dir = {};         // x,y direction (-1<=x,y<=1)
    this.dirEnum = 0;      // direction enumeration (0<=x,y<=4)

    // current frame count
    this.frame = 0;        // frame count
};

// reset to initial position and direction
Actor.prototype.reset = function() {
    this.setDir(this.startDirEnum);
    this.setPos(this.startPixel.x, this.startPixel.y);
};

// sets the position and updates its dependent variables
Actor.prototype.setPos = function(px,py) {
    this.pixel.x = px;
    this.pixel.y = py;
    this.commitPos();
};

// updates the position's dependent variables
Actor.prototype.commitPos = function() {

    // Handle Tunneling
    // Teleport position to opposite side of map if past tunnel tiles.
    // (there are two invisible tiles on each side of the tunnel)
    if (isOffscreenTunnelTile(this.tile.x, this.tile.y))
        if (this.pixel.x < tunnelLeftEndPixel)
            this.pixel.x = tunnelRightEndPixel;
        else if (this.pixel.x > tunnelRightEndPixel)
            this.pixel.x = tunnelLeftEndPixel;

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

// updates the actor state
Actor.prototype.update = function() {
    // get number of steps to advance in this frame
    var steps = this.getNumSteps(this.frame);
    var i;
    for (i=0; i<steps; i++) {
        this.step();
        this.steer();
    }
    this.frame++;
};

// draws the actor
Actor.prototype.draw = function() {
    drawActor(this.pixel.x, this.pixel.y, this.color, actorSize);
};

//
// ============== GHOST DATA ==============
//

// modes representing to the ghosts' active target
var ghostTargetMode;
var MODE_GHOST_ATTACK = 0;   // (a.k.a. "chase")
var MODE_GHOST_PATROL = 1;   // (a.k.a. "scatter")

// modes representing the ghost's last home actions
// traveling inside, to, and from the ghost home 
// requires special handling of each state.
var LEFT_HOME = 0;     // left home and being active
var GOING_HOME = 1;    // going back home to be revived
var PACING_HOME = 2;   // pacing back and forth in the home
var LEAVING_HOME = 3;  // leaving home to be active

// time table for when a ghost should be in a targetting mode
// There are 3 tables for level 1, level 2-4, and level 5+.
// Each element represents a targetting mode that the ghost
// should be in that given time.
var ghostTargetModeTimes = [{},{},{}];

// creates the ghost target mode time table
var initGhostTargetModeTimes = function() {
    var t;
    // level 1
    ghostTargetModeTimes[0][t=7*60] = MODE_GHOST_ATTACK;
    ghostTargetModeTimes[0][t+=20*60] = MODE_GHOST_PATROL;
    ghostTargetModeTimes[0][t+=7*60] = MODE_GHOST_ATTACK;
    ghostTargetModeTimes[0][t+=20*60] = MODE_GHOST_PATROL;
    ghostTargetModeTimes[0][t+=5*60] = MODE_GHOST_ATTACK;
    ghostTargetModeTimes[0][t+=20*60] = MODE_GHOST_PATROL;
    ghostTargetModeTimes[0][t+=5*60] = MODE_GHOST_ATTACK;
    // level 2-4
    ghostTargetModeTimes[1][t=7*60] = MODE_GHOST_ATTACK;
    ghostTargetModeTimes[1][t+=20*60] = MODE_GHOST_PATROL;
    ghostTargetModeTimes[1][t+=7*60] = MODE_GHOST_ATTACK;
    ghostTargetModeTimes[1][t+=20*60] = MODE_GHOST_PATROL;
    ghostTargetModeTimes[1][t+=5*60] = MODE_GHOST_ATTACK;
    ghostTargetModeTimes[1][t+=1033*60] = MODE_GHOST_PATROL;
    ghostTargetModeTimes[1][t+=1] = MODE_GHOST_ATTACK;
    // level 5+
    ghostTargetModeTimes[2][t=7*60] = MODE_GHOST_ATTACK;
    ghostTargetModeTimes[2][t+=20*60] = MODE_GHOST_PATROL;
    ghostTargetModeTimes[2][t+=7*60] = MODE_GHOST_ATTACK;
    ghostTargetModeTimes[2][t+=20*60] = MODE_GHOST_PATROL;
    ghostTargetModeTimes[2][t+=5*60] = MODE_GHOST_ATTACK;
    ghostTargetModeTimes[2][t+=1037*60] = MODE_GHOST_PATROL;
    ghostTargetModeTimes[2][t+=1] = MODE_GHOST_ATTACK;
};

// retrieves a target mode if there is one to be triggered at the given frame (time)
var getNewGhostTargetMode = function(t) {
    var i;
    if (game.level == 1)
        i = 0;
    else if (game.level >= 2 && game.level <= 4)
        i = 1;
    else
        i = 2;
    return ghostTargetModeTimes[i][t];
};

// time limits for how long pacman should be energized for each level.
// also the number of times a scared ghost should flash before returning to normal.
var energizedTimeLimits =  [6,5,4,3,2,5,2,2,1,5,2,1,1,3,1,1,0,1];
var scaredGhostFlashes = [5,5,5,5,5,5,5,5,3,5,5,3,3,5,3,3,0,3];

var getEnergizedTimeLimit = function() {
    var i = game.level;
    return (i > 18) ? 0 : 60*energizedTimeLimits[i-1];
};
var getScaredGhostFlashes = function() {
    var i = game.level;
    return (i > 18) ? 0 : 60*scaredGhostFlashes[i-1];
};

var elroy1DotsLeft = [20,30,40,40,40,50,50,50,60,60,60,70,70,70,100,100,100,100,120,120,120];
var elroy2DotsLeft = [10,15,20,20,20,25,25,25,30,30,30,40,40,40, 50, 50, 50, 50, 60, 60, 60];

var getElroy1DotsLeft = function() {
    var i = game.level;
    if (i>21) i = 21;
    return elroy1DotsLeft[i-1];
};

var getElroy2DotsLeft = function() {
    var i = game.level;
    if (i>21) i = 21;
    return elroy2DotsLeft[i-1];
};

//
// ==================== GHOST ACTOR =======================
//

// Ghost constructor
var Ghost = function() {

    // inherit data from Actor
    Actor.apply(this);

    // tiles
    this.targetTile = {x:0,y:0}; // x,y current target tile (0<=x<tileCols, 0<=y<tileRows)
    this.cornerTile = {};        // x,y corner tile to patrol (0<=x<tileCols, 0<=y<tileRows)
    this.reverseTile = {};       // x,y tile to reverse direction after leaving

    // signals (received to indicate changes to be made in the update() function)
    this.sigReverse = false;   // reverse signal
    this.sigGoHome = false;    // go home signal
    this.sigLeaveHome = false; // leave home signal

    // modes
    this.homeMode = 0;    // LEFT_HOME, GOING_HOME, PACING_HOME, or LEAVING_HOME
    this.scared = false;  // currently scared
};

// inherit functions from Actor class
Ghost.prototype.__proto__ = Actor.prototype;

// reset the state of the ghost on new level or level restart
Ghost.prototype.reset = function() {

    // signals
    this.sigReverse = false;
    this.sigGoHome = false;
    this.sigLeaveHome = false;

    // modes
    this.homeMode = (this == blinky) ? LEFT_HOME : PACING_HOME;
    this.scared = false;

    // call Actor's reset function to reset position and direction
    Actor.prototype.reset.apply(this);
};

// gets the number of steps to move in this frame
Ghost.prototype.getNumSteps = function(frame) {

    var pattern = STEP_GHOST;

    if (this.homeMode == GOING_HOME) 
        return 2;
    else if (this.homeMode == LEAVING_HOME || this.homeMode == PACING_HOME || isTunnelTile(this.tile.x, this.tile.y))
        pattern = STEP_GHOST_TUNNEL;
    else if (this.scared)
        pattern = STEP_GHOST_FRIGHT;
    else if (this.elroy == 1)
        pattern = STEP_ELROY1;
    else if (this.elroy == 2)
        pattern = STEP_ELROY2;

    return getStepSizeFromTable(game.level, pattern, frame);
};

// determines if this ghost is inside the ghost home
// (anywhere in the home past the door tile)
Ghost.prototype.isInsideHome = function() {
    return (this.pixel.x >= ghostHomeLeftPixel && this.pixel.x <= ghostHomeRightPixel &&
        this.tile.y > ghostDoorTile.y && this.pixel.y <= ghostHomeBottomPixel);
};

// signal ghost to reverse direction after leaving current tile
Ghost.prototype.reverse = function() {
    this.sigReverse = true;
};

// signal ghost to go home
// It is useful to have this because as soon as the ghost gets eaten,
// we have to freeze all the actors for 3 seconds, except for the
// ones who are already traveling to the ghost home to be revived.
// We use this signal to change homeMode to GOING_HOME, which will be
// set after the update() function is called so that we are still frozen
// for 3 seconds before traveling home uninterrupted.
Ghost.prototype.goHome = function() {
    this.sigGoHome = true; 
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
    if (this.homeMode == LEFT_HOME)
        this.reverse();

    // don't scare me again on the way to home
    if (this.homeMode != GOING_HOME)
        this.scared = true;
};

// function called when this ghost gets eaten
Ghost.prototype.onEaten = function() {
    this.goHome();       // go home
    this.scared = false; // turn off scared
};


// move forward one step
Ghost.prototype.step = function() {
    this.setPos(this.pixel.x+this.dir.x, this.pixel.y+this.dir.y);
};

// determine direction
Ghost.prototype.steer = function() {

    // Normally, only consider a turn if we're at the middle of a tile.
    // This can change later in the function to handle special ghost door case.
    var considerTurning = (this.distToMid.x == 0 && this.distToMid.y == 0);

    // The following if-else chain takes care of the special home mode movement cases

    // going home to be revived
    if (this.homeMode == GOING_HOME) {
        // at the doormat
        if (this.tile.x == ghostDoorTile.x && this.tile.y == ghostDoorTile.y) {
            // walk to the door, or go through if already there
            this.setDir(this.pixel.x == ghostDoorPixel.x ? DIR_DOWN : DIR_RIGHT);
            return;
        }

        // inside
        if (this.isInsideHome()) {
            if (this.pixel.y == ghostHomeBottomPixel) {
                // revive if reached its seat
                if (this.pixel.x == this.startPixel.x) {
                    this.setDir(DIR_UP);
                    this.homeMode = (this == blinky) ? LEAVING_HOME : PACING_HOME;
                }
                // sidestep to its seat
                else {
                    this.setDir(this.startPixel.x < this.pixel.x ? DIR_LEFT : DIR_RIGHT);
                }
            }
            // keep walking down
            return;
        }

        // still outside, so keep looking for the door by proceeding to the rest of this function
    }
    // pacing home
    else if (this.homeMode == PACING_HOME) {
        // head for the door
        if (this.sigLeaveHome) {
            this.sigLeaveHome = false;
            this.homeMode = LEAVING_HOME;
            if (this.pixel.x == ghostDoorPixel.x)
                this.setDir(DIR_UP);
            else
                this.setDir(this.pixel.x < ghostDoorPixel.x ? DIR_RIGHT : DIR_LEFT);
        }
        // pace back and forth
        else {
            if (this.pixel.y == ghostHomeTopPixel)
                this.setDir(DIR_DOWN);
            else if (this.pixel.y == ghostHomeBottomPixel)
                this.setDir(DIR_UP);
        }
        return;
    }
    // leaving home
    else if (this.homeMode == LEAVING_HOME) {
        if (this.pixel.x == ghostDoorPixel.x) {
            // reached door
            if (this.pixel.y == ghostDoorPixel.y) {
                this.homeMode = LEFT_HOME;
                this.setDir(DIR_LEFT); // always turn left at door?
            }
            // keep walking up to the door
            else {
                this.setDir(DIR_UP);
            }
        }
        return;
    }

    var i;                               // loop counter

    var dir = {};                        // temporary direction vector
    var dirEnum;                         // final direction to update to
    var oppDirEnum = (this.dirEnum+2)%4; // current opposite direction enum

    var surroundTiles;                   // list of four surrounding tile characters
    var openTiles;                       // list of four booleans indicating which surrounding tiles are open
    var numOpenTiles;                    // number of open surrounding tiles

    var dx,dy,dist;                      // variables used for euclidean distance
    var minDist = Infinity;              // variable used for finding minimum distance path

    // reverse direction if commanded
    if (this.sigReverse && this.homeMode == LEFT_HOME) {

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

    // exit if not considering turning
    if (!considerTurning)
        return;

    // get open passages
    surroundTiles = getSurroundingTiles(this.tile);
    openTiles = {};
    numOpenTiles = 0;
    for (i=0; i<4; i++)
        if (openTiles[i] = isFloorTile(surroundTiles[i]))
            numOpenTiles++;

    // By design, no mazes should have dead ends,
    // but allow player to turn around if and only if it's necessary.
    // Only close the passage behind the player if there are other openings.
    if (numOpenTiles > 1) {
        openTiles[oppDirEnum] = false;
    }
    // somehow we got stuck
    else if (numOpenTiles == 0) {
        this.dir.x = 0;
        this.dir.y = 0;
        this.dirEnum = -1;
        console.log(this.name,'got stuck');
        return;
    }

    // random turn if scared
    if (this.scared) {
        dirEnum = Math.floor(Math.random()*5);
        while (!openTiles[dirEnum])
            dirEnum = (dirEnum+1)%4;
    }
    else {
        // target ghost door
        if (this.homeMode == GOING_HOME) {
            this.targetTile.x = ghostDoorTile.x;
            this.targetTile.y = ghostDoorTile.y;
        }
        // target corner when patrolling
        else if (!this.elroy && ghostTargetMode == MODE_GHOST_PATROL) {
            this.targetTile.x = this.cornerTile.x;
            this.targetTile.y = this.cornerTile.y;
        }
        // use custom function for each ghost when in attack mode
        else // mode == MODE_GHOST_ATTACK
            this.setTarget();

        // not allowed to go up at these points
        if (ghostCannotGoUpAtTile(this.tile.x, this.tile.y)) 
            openTiles[DIR_UP] = false;

        // choose direction that minimizes distance to target
        for (i=0; i<4; i++) {
            if (openTiles[i]) {
                setDirFromEnum(dir,i);
                dx = dir.x + this.tile.x - this.targetTile.x;
                dy = dir.y + this.tile.y - this.targetTile.y;
                dist = dx*dx+dy*dy;
                if (dist < minDist) {
                    minDist = dist;
                    dirEnum = i;
                }
            }
        }
    }

    // commit the direction
    this.setDir(dirEnum);
};

// update this frame
Ghost.prototype.update = function() {

    var newMode;

    // react to signal to go home
    if (this.sigGoHome) {
        this.sigGoHome = false;
        this.homeMode = GOING_HOME;
    }
    
    // call super function to update position and direction
    Actor.prototype.update.apply(this);
};

// draw ghost differently to reflect modes
Ghost.prototype.draw = function() {
    if (this.scared)
        drawActor(this.pixel.x, this.pixel.y, "#00F", actorSize);
    else if (this.sigGoHome)
        drawActor(this.pixel.x, this.pixel.y, "rgba(255,255,255,0.1)", actorSize);
    else if (this.homeMode == GOING_HOME)
        drawActor(this.pixel.x, this.pixel.y, "rgba(255,255,255,0.2)", actorSize);
    else 
        Actor.prototype.draw.apply(this);

    //if (!this.scared && this.homeMode == LEFT_HOME && game.state == playState && playState.skippedFramesLeft == 0)
        //this.drawSight();
};

// draw a line of sight from the ghost to its active target tile 
// (for debugging and visualization)
Ghost.prototype.drawSight = function() {
    ctx.strokeStyle = this.color;
    ctx.beginPath();
    ctx.moveTo(this.pixel.x, this.pixel.y);
    ctx.lineTo(this.targetTile.x*tileSize+midTile.x, this.targetTile.y*tileSize+midTile.y);
    ctx.closePath();
    ctx.stroke();
    drawFloor(this.targetTile.x,this.targetTile.y, this.color,1);
};

//
// ============== PLAYER ACTOR ==============
//

// This is the player actor for Pac-Man, or potentially Ms. Pac-Man.

// Player constructor
var Player = function() {

    // inherit data from Actor
    Actor.apply(this);

    // energized state
    this.energized = false;        // indicates energized state
    this.energizedCount = 0;       // how long in frames we have been energized

    this.eatPauseFramesLeft = 0;   // current # of frames left to pause after eating

    // next direction to be taken when possible (set by joystick)
    this.nextDir = {};             // x,y direction
    this.nextDirEnum = 0;          // direction enumeration
};

// inherit functions from Actor
Player.prototype.__proto__ = Actor.prototype;

// reset the state of the player on new level or level restart
Player.prototype.reset = function() {

    this.energized = false;
    this.energizedCount = 0;

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
Player.prototype.getNumSteps = function() {
    var pattern = this.energized ? STEP_PACMAN_FRIGHT : STEP_PACMAN;
    return getStepSizeFromTable(game.level, pattern, this.frame);
};

// move forward one step
Player.prototype.step = function() {

    // identify the axes of motion
    var a = (this.dir.x != 0) ? 'x' : 'y'; // axis of motion
    var b = (this.dir.x != 0) ? 'y' : 'x'; // axis perpendicular to motion

    // Don't proceed past the middle of a tile if facing a wall
    var stop = this.distToMid[a] == 0 && !isFloorTile(getNextTile(this.tile, this.dir));
    if (!stop)
        this.pixel[a] += this.dir[a];

    // Drift toward the center of the track (a.k.a. cornering)
    this.pixel[b] += sign(this.distToMid[b]);

    this.commitPos();
};

// determine direction
Player.prototype.steer = function() {
    // head in the desired direction if possible
    if (isFloorTile(getNextTile(this.tile, this.nextDir)))
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
    var i;
    if (this.energizedCount == getEnergizedTimeLimit()) {
        this.energized = false;
        this.energizedCount = 0;
        for (i=0; i<4; i++)
            actors[i].scared = false;
    }
    else
        this.energizedCount++;


    // call super function to update position and direction
    Actor.prototype.update.apply(this);

    // eat something
    var i;
    var t = getTile(this.tile.x, this.tile.y);
    if (t == '.' || t == 'o') {
        counter.addDot();
        currentTiles[this.tile.x+this.tile.y*tileCols] = ' ';
        if (++game.dotCount == game.maxDots)
            return;
        if (t == 'o') {
            this.energized = true;
            this.energizedCount = 0;
            this.eatPauseFramesLeft = 3;
            for (i=0; i<4; i++) 
                actors[i].onEnergized();
        }
        else
            this.eatPauseFramesLeft = 1;
    }
};

//
// ================ ACTOR DEFINITIONS ==============
// 

// create blinky
var blinky = new Ghost();
blinky.name = "blinky";
blinky.color = "#FF0000";
blinky.startDirEnum = DIR_LEFT;
blinky.startPixel.x = 14*tileSize-1;
blinky.startPixel.y = 14*tileSize+midTile.y;
blinky.cornerTile.x = tileCols-1-2;
blinky.cornerTile.y = 0;
blinky.setTarget = function() {
    // directly target pacman
    this.targetTile.x = pacman.tile.x;
    this.targetTile.y = pacman.tile.y;
};

// create pinky
var pinky = new Ghost();
pinky.name = "pinky";
pinky.color = "#FFB8FF";
pinky.startDirEnum = DIR_DOWN;
pinky.startPixel.x = 14*tileSize-1;
pinky.startPixel.y = 17*tileSize+midTile.y;
pinky.cornerTile.x = 2;
pinky.cornerTile.y = 0;
pinky.setTarget = function() {
    // target four tiles ahead of pacman
    this.targetTile.x = pacman.tile.x + 4*pacman.dir.x;
    this.targetTile.y = pacman.tile.y + 4*pacman.dir.y;
    if (pacman.dirEnum == DIR_UP)
        this.targetTile.x -= 4; // arcade overflow bug
};

// create inky
var inky = new Ghost();
inky.name = "inky";
inky.color = "#00FFFF";
inky.startDirEnum = DIR_UP;
inky.startPixel.x = 12*tileSize-1;
inky.startPixel.y = 17*tileSize + midTile.y;
inky.cornerTile.x = tileCols-1;
inky.cornerTile.y = tileRows - 2;
inky.setTarget = function() {
    // target twice the distance from blinky to two tiles ahead of pacman
    var px = pacman.tile.x + 2*pacman.dir.x;
    var py = pacman.tile.y + 2*pacman.dir.y;
    if (pacman.dirEnum == DIR_UP)
        px -= 2; // arcade overflow bug
    this.targetTile.x = blinky.tile.x + 2*(px - blinky.tile.x);
    this.targetTile.y = blinky.tile.y + 2*(py - blinky.tile.y);
};

// create clyde
var clyde = new Ghost();
clyde.name = "clyde";
clyde.color = "#FFB851";
clyde.startDirEnum = DIR_UP;
clyde.startPixel.x = 16*tileSize-1;
clyde.startPixel.y = 17*tileSize + midTile.y;
clyde.cornerTile.x = 0;
clyde.cornerTile.y = tileRows-2;
clyde.setTarget = function() {
    // target pacman if >=8 tiles away, otherwise go home
    var dx = pacman.tile.x - this.tile.x;
    var dy = pacman.tile.y - this.tile.y;
    var dist = dx*dx+dy*dy;
    if (dist >= 64) {
        this.targetTile.x = pacman.tile.x;
        this.targetTile.y = pacman.tile.y;
    }
    else {
        this.targetTile.x = this.cornerTile.x;
        this.targetTile.y = this.cornerTile.y;
    }
};

// create pacman
var pacman = new Player();
pacman.color = "#FFFF00";
pacman.startDirEnum = DIR_LEFT;
pacman.startPixel.x = tileSize*tileCols/2;
pacman.startPixel.y = 26*tileSize + midTile.y;

//
// ============== ACTOR MANAGEMENT ==================
//

// order at which they appear in original arcade memory
// (suggests drawing/update order)
var actors = [blinky, pinky, inky, clyde, pacman];

var drawActors = function() {
    var i;
    // draw such that pacman appears on top
    if (pacman.energized)
        for (i=0; i<=4; i++) 
            actors[i].draw();
    // draw such that pacman appears on bottom
    else
        for (i=4; i>=0; i--) 
            actors[i].draw();
};

//
// ================ COUNTERS =================
//

// This is a counter that decides when a ghost
// can leave its home and when it should change
// targets.

// two separate counter modes
var MODE_COUNTER_PERSONAL = 0;
var MODE_COUNTER_GLOBAL = 1;

// dot limits used in personal mode
// (these are moved from the ACTOR DEFINITIONS section for easy reference)
pinky.getDotLimit = function() {
    return 0;
};
inky.getDotLimit = function() {
    return (game.level==1) ? 30 : 0;
};
clyde.getDotLimit = function() {
    if (game.level == 1) return 60;
    else if (game.level == 2) return 50;
    else return 0;
};

// create counter object
var counter = {};

// when new level starts
counter.onNewLevel = function() {
    this.mode = MODE_COUNTER_PERSONAL;
    this.framesSinceLastDot = 0;
    ghostTargetMode = MODE_GHOST_PATROL;
    this.targetCount = 0;
    pinky.dotCount = 0;
    inky.dotCount = 0;
    clyde.dotCount = 0;
};

// when player dies and level restarts
counter.onRestartLevel = function() {
    ghostTargetMode = MODE_GHOST_PATROL;
    this.targetCount = 0;
    this.mode = MODE_COUNTER_GLOBAL;
    this.dotCount = 0;
    this.framesSinceLastDot = 0;
};

// this is how long it will take to release a ghost after pacman stops eating
counter.getFramesSinceLastDotLimit = function() {
    return (game.level < 5) ? 4*60 : 3*60;
};

// handle the event of an eaten dot
counter.addDot = function() {
    // reset time since last dot
    this.framesSinceLastDot = 0;

    // add dot to the appropriate counter
    var i,g;
    if (this.mode == MODE_COUNTER_PERSONAL) {
        for (i=1;i<4;i++) {
            g = actors[i];
            if (g.homeMode == PACING_HOME) {
                g.dotCount++;
                break;
            }
        }
    }
    else {
        this.dotCount++;
    }
};

// update counter
counter.update = function() {

    var i;

    // use personal dot counter
    if (this.mode == MODE_COUNTER_PERSONAL) {
        for (i=1;i<4;i++) {
            var g = actors[i];
            if (g.homeMode == PACING_HOME) {
                if (g.dotCount >= g.getDotLimit()) {
                    g.leaveHome();
                }
                break;
            }
        }
    }
    // use global dot counter
    else if (this.mode == MODE_COUNTER_GLOBAL) {
        if (this.dotCount == 7 && pinky.homeMode == PACING_HOME)
            pinky.leaveHome();
        else if (this.dotCount == 17 && inky.homeMode == PACING_HOME)
            inky.leaveHome();
        else if (this.dotCount == 32 && clyde.homeMode == PACING_HOME) {
            this.dotCount = 0;
            this.mode = MODE_COUNTER_PERSONAL;
            clyde.leaveHome();
        }
    }

    // also use time since last dot was eaten
    if (this.framesSinceLastDot > this.getFramesSinceLastDotLimit()) {
        this.framesSinceLastDot = 0;
        for (i=1;i<4;i++) {
            var g = actors[i];
            if (g.homeMode == PACING_HOME) {
                g.leaveHome();
                break;
            }
        }
    }
    else
        this.framesSinceLastDot++;

    // change ghost target modes
    var newMode;
    if (!pacman.energized) {
        newMode = getNewGhostTargetMode(this.targetCount);
        if (newMode != undefined) {
            ghostTargetMode = newMode;
            for (i=0; i<4; i++)
                actors[i].reverse();
        }
        this.targetCount++;
    }

    // set elroy modes
    var dotsLeft = game.maxDots - game.dotCount;
    if (dotsLeft <= getElroy2DotsLeft()) {
        blinky.elroy = 2;
    }
    else if (dotsLeft <= getElroy1DotsLeft()) {
        blinky.elroy = 1;
    }
    else {
        blinky.elroy = 0;
    }
};

//
// ================ GAME STATES ===================
//

var game = {};
game.maxDots = 244; // number of dots per level
game.init = function(s) {
    this.extraLives = 3;
    this.level = 1;
    this.switchState(firstState);
};
game.switchState = function(s) {
    s.init();
    this.state = s;
};

//
// ================ start states =================
//

var firstState = {};
firstState.init = function() {
    this.frames = 0;
};
firstState.draw = function() {
    drawBackground();
    drawTiles();
    drawExtraLives();
    drawMessage("READY","#FF0");
};
firstState.update = function() {
    if (this.frames == 60) {
        game.extraLives--;
        game.switchState(startState);
    }
    else 
        this.frames++;
};

// common start state when the all players return to their places
var commonStartState = {};
commonStartState.init = function() {
    var i;
    for (i=0; i<5; i++)
        actors[i].reset();
    this.frame = 0;
};
commonStartState.draw = function() {
    drawBackground();
    drawTiles();
    drawActors();
    drawExtraLives();
    drawMessage("READY","#FF0");
};
commonStartState.update = function() {
    if (this.frame == 2*60)
        game.switchState(playState);
    this.frame++;
};

// start state for new level
var startState = { __proto__:commonStartState };
startState.init = function() {
    resetTiles();
    counter.onNewLevel();
    commonStartState.init.apply(this);
};

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
    drawBackground();
    drawTiles();
    drawActors();
    drawExtraLives();
};
playState.update = function() {

    var i;

    // skip this frame if needed,
    // but update ghosts running home
    if (this.skippedFramesLeft > 0) {
        for (i=0; i<4; i++)
            if (actors[i].homeMode == GOING_HOME)
                actors[i].update();
        this.skippedFramesLeft--;
        return;
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
            if (g.homeMode == LEFT_HOME) {
                // somebody is going to die
                if (!g.scared) {
                    game.switchState(deadState);
                }
                else if (pacman.energized) {
                    g.onEaten();
                    this.skippedFramesLeft = 1*60;
                }
                break;
            }
        }
    }

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
    drawBackground();
    drawTiles();
    drawExtraLives();
    this.scriptFunc(this.frames - this.scriptFuncFrame);
};
scriptState.update = function() {
    if (this.script[this.frames] != undefined) {
        this.scriptFunc = this.script[this.frames];
        this.scriptFuncFrame = this.frames;
    }
    this.frames++;
};

// freeze for a moment, then shrink and explode
var deadState = { __proto__: scriptState };
deadState.script = {
    0 : function(t) { drawActors(); },
    60 : function(t) { pacman.draw(); },
    120 : function(t) { drawActor(pacman.pixel.x, pacman.pixel.y, pacman.color, actorSize*(60-t)/60); },
    180 : function(t) { var p = t/15; drawActor(pacman.pixel.x, pacman.pixel.y, "rgba(255,255,0,"+(1-p)+ ")", actorSize*p); },
    240 : function(t) { this.leave(); } 
};
deadState.leave = function() {
    game.switchState( game.extraLives == 0 ? overState : restartState);
};

// freeze for a moment then flash the tiles four times
var finishState = { __proto__: scriptState };
finishState.script = {
    0 : function(t)  { drawActors(); },
    60: function(t)  { pacman.draw();},
    120: function(t) { pacman.draw(); floorColor = brightFloorColor; },
    135: function(t) { pacman.draw(); floorColor = normalFloorColor; },
    150: function(t) { pacman.draw(); floorColor = brightFloorColor; },
    165: function(t) { pacman.draw(); floorColor = normalFloorColor; },
    180: function(t) { pacman.draw(); floorColor = brightFloorColor; },
    195: function(t) { pacman.draw(); floorColor = normalFloorColor; },
    210: function(t) { pacman.draw(); floorColor = brightFloorColor; },
    225: function(t) { pacman.draw(); floorColor = normalFloorColor; },
    255: function(t) { pacman.draw(); this.leave(); }
};
finishState.leave = function() {
    game.level++;
    game.switchState(startState);
};

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
    drawBackground();
    drawTiles();
    drawMessage("GAME OVER", "#F00");
};
overState.update = function() {};

//
// =============== USER INPUT ==================
//

var initInput = function() {
    // make "focusable" to isolate keypresses when canvas is clicked
    canvas.tabIndex = 0;

    // activate input focus
    canvas.onmousedown = function(e) {
        this.focus();
    };

    // handle key press event
    canvas.onkeydown = function(e) {
        var key = (e||window.event).keyCode;
        switch (key) {
            case 65: case 37: pacman.setNextDir(DIR_LEFT); break; // left
            case 87: case 38: pacman.setNextDir(DIR_UP); break; // up
            case 68: case 39: pacman.setNextDir(DIR_RIGHT); break; // right
            case 83: case 40: pacman.setNextDir(DIR_DOWN); break;// down
        }
    };
};

//
// =========== MAIN SETUP ==========
//

// return sign of a number
var sign = function(x) {
    if (x<0) return -1;
    if (x>0) return 1;
    return 0;
};

var canvas;
var ctx, ctx_w, ctx_h;

window.onload = function() {
    canvas = document.getElementById("canvas");
    ctx = canvas.getContext("2d");
    ctx_w = ctx.canvas.width;
    ctx_h = ctx.canvas.height;
    ctx.font = "bold " + 2*tileSize + "px sans-serif";

    // init various things
    initInput();
    initGhostTargetModeTimes();

    // display maze
    drawBackground();
    resetTiles();
    drawTiles();
    drawMessage("START", "#FFF");

    // begin game when canvas is clicked
    canvas.onmousedown = function() {
        game.init();
        setInterval("game.state.update()", 1000/60); // update at 60Hz (original arcade rate)
        setInterval(function() { 
            game.state.draw(); 
            //stackBlurCanvasRGB('canvas', 0, 0, ctx_w, ctx_h, 1);
        }, 1000/25);   // draw at 25Hz (helps performance)
        canvas.onmousedown = undefined;
    };
};
