//////////////////////////////////////////////////////////////////////////////////////
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

//////////////////////////////////////////////////////////////////////////////////////
// size of a tile in play space (not necessarily draw space)
var tileSize = 8;

// the center pixel of a tile
var midTile = {x:3, y:4};

// Tile Map Constructor
var TileMap = function(numCols, numRows, tiles) {

    // sizes
    this.numCols = numCols;
    this.numRows = numRows;
    this.numTiles = numCols*numRows;
    this.widthPixels = numCols*tileSize;
    this.heightPixels = numRows*tileSize;

    // ascii map
    this.tiles = tiles;

    this.resetCurrent();
    this.parseDots();
    this.parseTunnels();
};

// reset current tiles
TileMap.prototype.resetCurrent = function() {
    this.currentTiles = this.tiles.split("");
    this.dotsEaten = 0;
};

// count pellets and energizers
TileMap.prototype.parseDots = function() {

    this.numDots = 0;
    this.numEnergizers = 0;
    this.energizers = [];

    var x,y;
    var i = 0;
    var tile;
    for (y=0; y<this.numRows; y++) for (x=0; x<this.numCols; x++) {
        tile = this.tiles[i++];
        if (tile == '.') {
            this.numDots++;
        }
        else if (tile == 'o') {
            this.numDots++;
            this.numEnergizers++;
            this.energizers.push({'x':x,'y':y});
        }
    }
};

TileMap.prototype.dotsLeft = function() {
    return this.numDots - this.dotsEaten;
};

TileMap.prototype.allDotsEaten = function() {
    return this.dotsLeft() == 0;
};

// parse tunnels
TileMap.prototype.parseTunnels = (function(){
    
    var getTunnelEntrance = function(x,y,dx) {
        while (!this.isFloorTile(x,y-1) && !this.isFloorTile(x,y+1) && this.isFloorTile(x,y))
            x += dx;
        return x;
    };

    var marginTiles = 2;

    return function() {
        this.tunnelRows = {};
        var y;
        var i;
        var left,right;
        for (y=0;y<this.numRows;y++)
            // walkable tiles at opposite horizontal ends of the map
            if (this.isFloorTile(0,y) && this.isFloorTile(this.numCols-1,y))
                this.tunnelRows[y] = {
                    'leftEntrance': getTunnelEntrance.call(this,0,y,1),
                    'rightEntrance':getTunnelEntrance.call(this,this.numCols-1,y,-1),
                    'leftExit': -marginTiles*tileSize,
                    'rightExit': (this.numCols+marginTiles)*tileSize-1,
                };
    };
})();

// teleport actor to other side of tunnel if necessary
TileMap.prototype.teleport = function(actor){
    var i;
    var t = this.tunnelRows[actor.tile.y];
    if (t) {
        if (actor.pixel.x < t.leftExit)       actor.pixel.x = t.rightExit;
        else if (actor.pixel.x > t.rightExit) actor.pixel.x = t.leftExit;
    }
};

// define which tiles are inside the tunnel
TileMap.prototype.isTunnelTile = function(x,y) {
    var tunnel = this.tunnelRows[y];
    return tunnel && (x < tunnel.leftEntrance || x > tunnel.rightEntrance);
};

// retrieves tile character at given coordinate
// extended to include offscreen tunnel space
TileMap.prototype.getTile = function(x,y) {
    if (x>=0 && x<this.numCols && y>=0 && y<this.numRows) 
        return this.currentTiles[x+y*this.numCols];
    if (this.isTunnelTile(x,y))
        return ' ';
};

TileMap.prototype.isFloorTileChar = function(tile) {
    return tile==' ' || tile=='.' || tile=='o';
};

TileMap.prototype.isFloorTile = function(x,y) {
    return this.isFloorTileChar(this.getTile(x,y));
};

// get a list of the four surrounding tiles
TileMap.prototype.getSurroundingTiles = function(tile) {
    return [
        this.getTile(tile.x, tile.y-1), // DIR_UP
        this.getTile(tile.x+1, tile.y), // DIR_RIGHT
        this.getTile(tile.x, tile.y+1), // DIR_DOWN
        this.getTile(tile.x-1, tile.y)  // DIR_LEFT
    ];
};

TileMap.prototype.isNextTileFloor = function(tile,dir) {
    return this.isFloorTile(tile.x+dir.x,tile.y+dir.y);
};

// erase pellet from background
TileMap.prototype.onDotEat = function(x,y) {
    this.dotsEaten++;
    this.currentTiles[x+y*this.numCols] = ' ';
    screen.renderer.erasePellet(x,y);
};
