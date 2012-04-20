//////////////////////////////////////////////////////////////////////////////////////
// Map
// (an ascii map of tiles representing a level maze)

// size of a square tile in pixels
var tileSize = 8;

// the center pixel of a tile
var midTile = {x:3, y:4};

// constructor
var Map = function(numCols, numRows, tiles) {

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
    this.parseWalls();
};

// reset current tiles
Map.prototype.resetCurrent = function() {
    this.currentTiles = this.tiles.split(""); // create a mutable list copy of an immutable string
    this.dotsEaten = 0;
};

Map.prototype.parseWalls = function() {

    // creates a list of drawable canvas paths to render the map walls
    this.paths = [];

    // a map of which wall tiles already belong to a built path
    var visited = {};

    // a map of which wall tiles that are not completely surrounded by other wall tiles
    var edges = {};
    var i=0,x,y;
    for (y=0;y<this.numRows;y++)
        for (x=0;x<this.numCols;x++,i++)
            if (this.getTile(x,y) == '|' &&
                (this.getTile(x-1,y) != '|' ||
                this.getTile(x+1,y) != '|' ||
                this.getTile(x,y-1) != '|' ||
                this.getTile(x,y+1) != '|' ||
                this.getTile(x-1,y-1) != '|' ||
                this.getTile(x-1,y+1) != '|' ||
                this.getTile(x+1,y-1) != '|' ||
                this.getTile(x+1,y+1) != '|'))
                edges[i] = true;

    // walks along edge wall tiles starting at the given index to build a canvas path
    var that = this;
    var makePath = function(i) {

        visited[i] = true;

        // determine initial tile location
        var tx = i%that.numCols;
        var ty = Math.floor(i/that.numCols);

        // get initial direction
        var dir = {};
        var dirEnum;
        if (that.posToIndex(tx+1,ty) in edges)
            dirEnum = DIR_RIGHT;
        else if (that.posToIndex(tx,ty+1) in edges)
            dirEnum = DIR_DOWN;
        else
            throw "tile shouldn't be 1x1";
        setDirFromEnum(dir,dirEnum);

        // increment to next tile
        tx += dir.x;
        ty += dir.y;

        // backup initial location and direction
        var init_tx = tx;
        var init_ty = ty;
        var init_dirEnum = dirEnum;

        var path = [];
        var pad;
        var cx,cy; // center of tile
        var px,py,rpx,rpy; // point and rotated point (path control point)
        console.log("starting path");
        var k;
        for (k=0;;k++) {
            //console.log(tx,ty,dir);
            visited[that.posToIndex(tx,ty)] = true;

            // get center of tile
            cx = (tx+0.5)*tileSize;
            cy = (ty+0.5)*tileSize;

            // plot point
            if (!(that.posToIndex(tx+dir.y,ty-dir.x) in edges))
                pad = that.isFloorTile(tx+dir.y,ty-dir.x) ? 5 : 0;
            px = -tileSize/2+pad;
            py = tileSize/2;
            if (dirEnum == DIR_UP) {
                rpx = px;
                rpy = py;
            }
            else if (dirEnum == DIR_RIGHT) {
                rpx = -py;
                rpy = px;
            }
            else if (dirEnum == DIR_DOWN) {
                rpx = -px;
                rpy = -py;
            }
            else if (dirEnum == DIR_LEFT) {
                rpx = py;
                rpy = -px;
            }
            path.push({x:cx+rpx, y:cy+rpy});

            // change direction
            var j;
            if ((j=that.posToIndex(tx+dir.y,ty-dir.x)) in edges) { // turn left
                dirEnum = (dirEnum+3)%4;
            }
            else if ((j=that.posToIndex(tx+dir.x,ty+dir.y)) in edges) { // continue straight
                // keep dirEnum
            }
            else if ((j=that.posToIndex(tx-dir.y,ty+dir.x)) in edges) { // turn right
                dirEnum = (dirEnum+1)%4;
            }
            else { // turn around
                dirEnum = (dirEnum+2)%4;
            }
            setDirFromEnum(dir,dirEnum);

            // advance to the next wall
            tx += dir.x;
            ty += dir.y;

            // exit at full cycle
            if (tx==init_tx && ty==init_ty && dirEnum == init_dirEnum) {
                that.paths.push(path);
                break;
            }
        }
        console.log("finished path");
        //throw "finish for now";
    };

    // iterate through all edges, making a new path after hitting an unvisited wall edge
    for (i=0;i<this.tiles.length;i++)
        if (i in edges && !(i in visited))
            makePath(i);
};

// count pellets and store energizer locations
Map.prototype.parseDots = function() {

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

// get remaining dots left
Map.prototype.dotsLeft = function() {
    return this.numDots - this.dotsEaten;
};

// determine if all dots have been eaten
Map.prototype.allDotsEaten = function() {
    return this.dotsLeft() == 0;
};

// create a record of tunnel locations
Map.prototype.parseTunnels = (function(){
    
    // starting from x,y and increment x by dx...
    // determine where the tunnel entrance begins
    var getTunnelEntrance = function(x,y,dx) {
        while (!this.isFloorTile(x,y-1) && !this.isFloorTile(x,y+1) && this.isFloorTile(x,y))
            x += dx;
        return x;
    };

    // the number of margin tiles outside of the map on one side of a tunnel
    // There are (2*marginTiles) tiles outside of the map per tunnel.
    var marginTiles = 2;

    return function() {
        this.tunnelRows = {};
        var y;
        var i;
        var left,right;
        for (y=0;y<this.numRows;y++)
            // a map row is a tunnel if opposite ends are both walkable tiles
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
Map.prototype.teleport = function(actor){
    var i;
    var t = this.tunnelRows[actor.tile.y];
    if (t) {
        if (actor.pixel.x < t.leftExit)       actor.pixel.x = t.rightExit;
        else if (actor.pixel.x > t.rightExit) actor.pixel.x = t.leftExit;
    }
};

Map.prototype.posToIndex = function(x,y) {
    if (x>=0 && x<this.numCols && y>=0 && y<this.numRows) 
        return x+y*this.numCols;
};

// define which tiles are inside the tunnel
Map.prototype.isTunnelTile = function(x,y) {
    var tunnel = this.tunnelRows[y];
    return tunnel && (x < tunnel.leftEntrance || x > tunnel.rightEntrance);
};

// retrieves tile character at given coordinate
// extended to include offscreen tunnel space
Map.prototype.getTile = function(x,y) {
    if (x>=0 && x<this.numCols && y>=0 && y<this.numRows) 
        return this.currentTiles[this.posToIndex(x,y)];
    if (this.isTunnelTile(x,y))
        return ' ';
};

// determines if the given character is a walkable floor tile
Map.prototype.isFloorTileChar = function(tile) {
    return tile==' ' || tile=='.' || tile=='o';
};

// determines if the given tile coordinate has a walkable floor tile
Map.prototype.isFloorTile = function(x,y) {
    return this.isFloorTileChar(this.getTile(x,y));
};

// mark the dot at the given coordinate eaten
Map.prototype.onDotEat = function(x,y) {
    this.dotsEaten++;
    this.currentTiles[this.posToIndex(x,y)] = ' ';
    renderer.erasePellet(x,y);
};
