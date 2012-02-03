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

    this.parseDots();
    this.parseTunnels();
    this.resetCurrent();

    this.backColor = "#333";
    this.pelletColor = "#888";
    this.energizerColor = "#FFF";
    
    // floor colors to use when flashing after finishing a level
    this.normalFloorColor = "#555";
    this.brightFloorColor = "#999";

    // current floor color
    var floorColor = normalFloorColor;
};

// reset current tiles
TileMap.prototype.resetCurrent = function() {
    this.currentTiles = this.tiles.split("");
    this.dotsEaten = 0;
    screen.drawMap();
};

// count pellets and energizers
TileMap.prototype.parseDots = function() {

    this.numDots = 0;
    this.numEnergizers = 0;
    this.energizers = [];

    var x,y;
    var i = 0;
    var tile;
    for (x=0; x<this.numCols; x++) for (y=0; y<this.numRows; y++) {
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

// parse tunnels
TileMap.prototype.parseTunnels = (function(){
    
    var getTunnelEntrance = function(x,y,dx) {
        while (!this.isFloorTile(x,y-1) && !this.isFloorTile(x,y+1) && this.isFloorTile(x,y))
            x += dx;
        return x;
    };

    return function() {
        this.tunnelRows = {};
        var y;
        var i;
        var left,right;
        for (y=0;y<this.numRows;y++)
            // walkable tiles at opposite horizontal ends of the map
            if (this.isFloorTile(0,y) && this.isFloorTile(this.numCols-1,y))
                this.tunnelRows[y] = {
                    'leftEntrance': getTunnelEntrance.call(this,0,y,1);
                    'rightEntrance':getTunnelEntrance.call(this,this.numCols-1,y,-1);
                };
    };
})();

// teleport actor to other side of tunnel if necessary
TileMap.prototype.teleport = (function(){

    // tunnel portal locations
    var marginTiles = 2;
    var leftExit = -marginTiles*tileSize;
    var rightExit = (tileCols+marginTiles)*tileSize-1;

    return function(actor) {
        var i;
        if (this.tunnelRows[actor.tile.y]) {
            if (actor.pixel.x < leftEnd)       actor.pixel.x = rightEnd;
            else if (actor.pixel.x > rightEnd) actor.pixel.x = leftEnd;
        }
    };
})();

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

TileMap.prototype.isNextTileFloor(tile,dir) {
    return this.isFloorTile(tile.x+dir.x,tile.y+dir.y);
};

// draw the map tiles
TileMap.prototype.draw = function(ctx) {

    // fill background
    ctx.fillStyle = this.backColor;
    ctx.fillRect(0,0,this.widthPixels, this.heightPixels);

    var x,y;
    var i;
    var tile;

    // draw pellet tiles
    ctx.fillStyle = this.pelletColor;
    i=0;
    for (y=0; y<this.numRows; y++)
    for (x=0; x<this.numCols; x++) {
        tile = this.currentTiles[i++];
        if (tile == '.')
            this.drawFloor(ctx,x,y,0);
    }

    // draw floor tiles
    ctx.fillStyle = this.floorColor;
    i=0;
    for (y=0; y<numRows; y++)
    for (x=0; x<numCols; x++) {
        tile = this.currentTiles[i++];
        if (tile == ' ' || tile == 'o')
            this.drawFloor(ctx,x,y,0);
    }
};

// draw energizers
TileMap.prototype.drawEnergizers = function(ctx) {
    ctx.fillStyle = this.energizerColor;
    var e;
    var i;
    for (i=0; i<this.numEnergizers; i++) {
        e = this.energizers[i];
        if (this.currentTiles[e.x+e.y*tileCols] == 'o')
            this.drawFloor(ctx,e.x,e.y,-1);
    }
};

// erase pellet from background
TileMap.prototype.onDotEat = function(x,y) {
    this.dotsEaten--;
    screen.erasePellet(x,y);
};

TileMap.prototype.erasePellet = function(ctx,x,y) {
    ctx.fillStyle = this.floorColor;
    this.drawFloor(ctx,x,y,0);
};

// draw floor tile
TileMap.prototype.drawFloor = function(ctx,x,y,pad) {
    ctx.fillRect(x*tileSize+pad,y*tileSize+pad,tileSize-2*pad,tileSize-2*pad);
};

// switch floor color to flash
TileMap.prototype.toggleFloorFlash = function() {
    this.floorColor = (this.floorColor == this.brightFloorColor) ? this.normalFloorColor : this.brightFloorColor;
};

