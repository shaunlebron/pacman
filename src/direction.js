//////////////////////////////////////////////////////////////////////////////////////
// Directions
// (variables and utility functions for representing actor heading direction)

// direction enums (in counter-clockwise order)
// NOTE: changing the order of these enums may effect the enums.
//       I've tried abstracting away the uses by creating functions to rotate them.
// NOTE: This order determines tie-breakers in the shortest distance turn logic.
//       (i.e. higher priority turns have lower enum values)
var DIR_UP = 0;
var DIR_LEFT = 1;
var DIR_DOWN = 2;
var DIR_RIGHT = 3;

var getClockwiseAngleFromTop = function(dirEnum) {
    return -dirEnum*Math.PI/2;
};

var rotateLeft = function(dirEnum) {
    return (dirEnum+1)%4;
};

var rotateRight = function(dirEnum) {
    return (dirEnum+3)%4;
};

var rotateAboutFace = function(dirEnum) {
    return (dirEnum+2)%4;
};

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

// return the direction of the open, surrounding tile closest to our target
var getTurnClosestToTarget = function(tile,targetTile,openTiles) {

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

// retrieve four surrounding tiles and indicate whether they are open
var getOpenTiles = function(tile,dirEnum) {

    // get open passages
    var openTiles = {};
    openTiles[DIR_UP] =    map.isFloorTile(tile.x, tile.y-1);
    openTiles[DIR_RIGHT] = map.isFloorTile(tile.x+1, tile.y);
    openTiles[DIR_DOWN] =  map.isFloorTile(tile.x, tile.y+1);
    openTiles[DIR_LEFT] =  map.isFloorTile(tile.x-1, tile.y);

    var numOpenTiles = 0;
    var i;
    if (dirEnum != undefined) {

        // count number of open tiles
        for (i=0; i<4; i++)
            if (openTiles[i])
                numOpenTiles++;

        // By design, no mazes should have dead ends,
        // but allow player to turn around if and only if it's necessary.
        // Only close the passage behind the player if there are other openings.
        var oppDirEnum = rotateAboutFace(dirEnum); // current opposite direction enum
        if (numOpenTiles > 1)
            openTiles[oppDirEnum] = false;
    }

    return openTiles;
};

// returns if the given tile coordinate plus the given direction vector has a walkable floor tile
var isNextTileFloor = function(tile,dir) {
    return map.isFloorTile(tile.x+dir.x,tile.y+dir.y);
};

