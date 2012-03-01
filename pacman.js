// PAC-MAN
// an accurate remake of the original arcade game

// original by Namco
// research from 'The Pacman Dossier' compiled by Jamey Pittman
// remake by Shaun Williams

// Project Page: http://github.com/shaunew/Pac-Man

(function(){
//////////////////////////////////////////////////////////////////////////////////////
// Directions
// (variables and utility functions for representing actor heading direction)

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
// TileMap
// (an ascii map of tiles representing a level maze)

// size of a square tile in pixels
var tileSize = 8;

// the center pixel of a tile
var midTile = {x:3, y:4};

// constructor
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
    this.parseIntersections();
};

// reset current tiles
TileMap.prototype.resetCurrent = function() {
    this.currentTiles = this.tiles.split(""); // create a mutable list copy of an immutable string
    this.dotsEaten = 0;
};

TileMap.prototype.parseIntersections = function() {
    this.intersections = [];
    var i = 0;
    var x,y;
    for (y=0; y<this.numRows; y++) for (x=0; x<this.numCols; x++) {
        this.intersections[i++] = this.getOpenTiles({x:x,y:y});
    }
};

// count pellets and store energizer locations
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

// get remaining dots left
TileMap.prototype.dotsLeft = function() {
    return this.numDots - this.dotsEaten;
};

// determine if all dots have been eaten
TileMap.prototype.allDotsEaten = function() {
    return this.dotsLeft() == 0;
};

// create a record of tunnel locations
TileMap.prototype.parseTunnels = (function(){
    
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

// determines if the given character is a walkable floor tile
TileMap.prototype.isFloorTileChar = function(tile) {
    return tile==' ' || tile=='.' || tile=='o';
};

// determines if the given tile coordinate has a walkable floor tile
TileMap.prototype.isFloorTile = function(x,y) {
    return this.isFloorTileChar(this.getTile(x,y));
};

// get a list of the four surrounding tiles
TileMap.prototype.getSurroundingTiles = function(tile) {
    var result = [];
    result[DIR_UP] = this.getTile(tile.x, tile.y-1);
    result[DIR_RIGHT] = this.getTile(tile.x+1, tile.y);
    result[DIR_DOWN] = this.getTile(tile.x, tile.y+1);
    result[DIR_LEFT] = this.getTile(tile.x-1, tile.y);
    return result;
};

TileMap.prototype.getOpenTiles = function(tile) {
    var surroundTiles = this.getSurroundingTiles(tile);
    var i;
    for (i=0; i<4; i++)
        surroundTiles[i] = this.isFloorTileChar(surroundTiles[i]);
    return surroundTiles;
};

// returns if the given tile coordinate plus the given direction vector has a walkable floor tile
TileMap.prototype.isNextTileFloor = function(tile,dir) {
    return this.isFloorTile(tile.x+dir.x,tile.y+dir.y);
};

// mark the dot at the given coordinate eaten
TileMap.prototype.onDotEat = function(x,y) {
    this.dotsEaten++;
    this.currentTiles[x+y*this.numCols] = ' ';
    screen.renderer.erasePellet(x,y);
};
//////////////////////////////////////////////////////////////
// Renderers

// Draws everything in the game using swappable renderers
// to enable to different front-end displays for Pac-Man.

// list of available renderers
var renderers = {};

//////////////////////////////////////////////////////////////
// Common Renderer
// (attributes and functionality that are currently common to all renderers)

// constructor
renderers.Common = function(ctx, bgCtx) {
    this.ctx = ctx;
    this.bgCtx = bgCtx;

    this.actorSize = (tileSize-1)*2;
    this.energizerSize = tileSize+2;
    this.pointsEarnedTextSize = tileSize;

    this.energizerColor = "#FFF";
    this.pelletColor = "#888";
    this.scaredGhostColor = "#2121ff";

    this.flashLevel = false;
};

renderers.Common.prototype = {

    // scaling the canvas can incur floating point roundoff errors
    // which manifest as "grout" between tiles that are otherwise adjacent in integer-space
    // This function extends the width and height of the tile if it is adjacent to equivalent tiles
    // that are to the bottom or right of the given tile
    drawNoGroutTile: function(ctx,x,y,w) {
        var tileChar = tileMap.getTile(x,y);
        this.drawCenterTileSq(ctx,x,y,tileSize,
                tileMap.getTile(x+1,y) == tileChar,
                tileMap.getTile(x,y+1) == tileChar,
                tileMap.getTile(x+1,y+1) == tileChar);
    },

    // draw square centered at the given tile with optional "floating point grout" filling
    drawCenterTileSq: function (ctx,tx,ty,w, rightGrout, downGrout, downRightGrout) {
        this.drawCenterPixelSq(ctx, tx*tileSize+midTile.x, ty*tileSize+midTile.y,w,
                rightGrout, downGrout, downRightGrout);
    },

    // draw square centered at the given pixel
    drawCenterPixelSq: function (ctx,px,py,w,rightGrout, downGrout, downRightGrout) {
        ctx.fillRect(px-w/2, py-w/2,w,w);

        // fill "floating point grout" gaps between tiles
        var gap = 1;
        if (rightGrout) ctx.fillRect(px-w/2, py-w/2,w+gap,w);
        if (downGrout) ctx.fillRect(px-w/2, py-w/2,w,w+gap);
        //if (rightGrout && downGrout && downRightGrout) ctx.fillRect(px-w/2, py-w/2,w+gap,w+gap);
    },

    // this flag is used to flash the level upon its successful completion
    toggleLevelFlash: function () {
        this.flashLevel = !this.flashLevel;
    },

    // draw the target visualizers for each actor
    drawTargets: function() {
        var i;
        this.ctx.strokeStyle = "rgba(255,255,255,0.5)";
        this.ctx.lineWidth = "2.0";
        this.ctx.lineCap = "round";
        this.ctx.lineJoin = "round";
        for (i=0;i<5;i++)
            if (actors[i].isDrawTarget)
                actors[i].drawTarget(this.ctx);
    },

    drawPaths: function() {
        var i;
        for (i=0;i<5;i++)
            if (actors[i].isDrawPath)
                this.drawPath(actors[i]);
    },

    // draw a predicted path for the actor if it continues pursuing current target
    drawPath: function(actor) {
        if (!actor.targetting) return;

        // current state of the predicted path
        var tile = { x: actor.tile.x, y: actor.tile.y};
        var target = actor.targetTile;
        var dir = { x: actor.dir.x, y: actor.dir.y };
        var dirEnum = actor.dirEnum;
        var openTiles;

        // exit if we're already on the target
        if (tile.x == target.x && tile.y == target.y) {
            return;
        }

        // if we are past the center of the tile, we cannot turn here anymore, so jump to next tile
        if ((dirEnum == DIR_UP && actor.tilePixel.y <= midTile.y) ||
            (dirEnum == DIR_DOWN && actor.tilePixel.y >= midTile.y) ||
            (dirEnum == DIR_LEFT && actor.tilePixel.x <= midTile.x) ||
            (dirEnum == DIR_RIGHT & actor.tilePixel.x >= midTile.x)) {
            tile.x += dir.x;
            tile.y += dir.y;
        }
        var pixel = { x:tile.x*tileSize+midTile.x, y:tile.y*tileSize+midTile.y };
        
        // dist keeps track of how far we're going along this path, stopping at maxDist
        // distLeft determines how long the last line should be
        var dist = Math.abs(tile.x*tileSize+midTile.x - actor.pixel.x + tile.y*tileSize+midTile.y - actor.pixel.y);
        var maxDist = actorPathLength*tileSize;
        var distLeft;
        
        // add the first line
        this.ctx.strokeStyle = actor.pathColor;
        this.ctx.lineWidth = "2.0";
        this.ctx.lineCap = "round";
        this.ctx.lineJoin = "round";
        this.ctx.beginPath();
        this.ctx.moveTo(
                actor.pixel.x+actor.pathCenter.x,
                actor.pixel.y+actor.pathCenter.y);
        this.ctx.lineTo(
                pixel.x+actor.pathCenter.x,
                pixel.y+actor.pathCenter.y);

        if (tile.x == target.x && tile.y == target.y) {
            // adjust the distance left to create a smoothly interpolated path end
            distLeft = actor.getPathDistLeft(pixel, dirEnum);
        }
        else while (true) {

            // predict next turn from current tile
            openTiles = getOpenSurroundTiles(tile, dirEnum);
            if (actor != pacman && tileMap.constrainGhostTurns)
                tileMap.constrainGhostTurns(tile, openTiles);
            dirEnum = getTurnClosestToTarget(tile, target, openTiles);
            setDirFromEnum(dir,dirEnum);
            
            // if the next tile is our target, determine how mush distance is left and break loop
            if (tile.x+dir.x == target.x && tile.y+dir.y == target.y) {
            
                // adjust the distance left to create a smoothly interpolated path end
                distLeft = actor.getPathDistLeft(pixel, dirEnum);

                // cap distance left
                distLeft = Math.min(maxDist-dist, distLeft);

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
            pixel.x += tileSize*dir.x;
            pixel.y += tileSize*dir.y;
            dist += tileSize;
            this.ctx.lineTo(
                    tile.x*tileSize+midTile.x+actor.pathCenter.x,
                    tile.y*tileSize+midTile.y+actor.pathCenter.y);
        }

        // calculate final endpoint
        var px = pixel.x+actor.pathCenter.x+distLeft*dir.x;
        var py = pixel.y+actor.pathCenter.y+distLeft*dir.y;

        // add an arrow head
        this.ctx.lineTo(px,py);
        var s = 3;
        if (dirEnum == DIR_LEFT || dirEnum == DIR_RIGHT) {
            this.ctx.lineTo(px-s*dir.x,py+s*dir.x);
            this.ctx.moveTo(px,py);
            this.ctx.lineTo(px-s*dir.x,py-s*dir.x);
        }
        else {
            this.ctx.lineTo(px+s*dir.y,py-s*dir.y);
            this.ctx.moveTo(px,py);
            this.ctx.lineTo(px-s*dir.y,py-s*dir.y);
        }

        // draw path    
        this.ctx.stroke();
    },

    // draw a fade filter for 0<=t<=1
    drawFadeIn: function(t) {
        this.ctx.fillStyle = "rgba(0,0,0,"+(1-t)+")";
        this.ctx.fillRect(0,0,tileMap.widthPixels, tileMap.heightPixels);
    },

    // erase pellet from background
    erasePellet: function(x,y) {
        this.bgCtx.fillStyle = this.floorColor;
        this.drawNoGroutTile(this.bgCtx,x,y,tileSize);

        // fill in adjacent floor tiles
        if (tileMap.getTile(x+1,y)==' ') this.drawNoGroutTile(this.bgCtx,x+1,y,tileSize);
        if (tileMap.getTile(x-1,y)==' ') this.drawNoGroutTile(this.bgCtx,x-1,y,tileSize);
        if (tileMap.getTile(x,y+1)==' ') this.drawNoGroutTile(this.bgCtx,x,y+1,tileSize);
        if (tileMap.getTile(x,y-1)==' ') this.drawNoGroutTile(this.bgCtx,x,y-1,tileSize);

        // fill in adjacent wall tiles?
    },

    // draw a center screen message (e.g. "start", "ready", "game over")
    drawMessage: function(text, color) {
        this.ctx.font = "bold " + 2*tileSize + "px sans-serif";
        this.ctx.textBaseline = "middle";
        this.ctx.textAlign = "center";
        this.ctx.fillStyle = color;
        this.ctx.fillText(text, tileMap.numCols*tileSize/2, this.messageRow*tileSize+midTile.y);
    },

    // draw the points earned from the most recently eaten ghost
    drawEatenPoints: function() {
        var text = energizer.getPoints();
        this.ctx.font = this.pointsEarnedTextSize + "px sans-serif";
        this.ctx.textBaseline = "middle";
        this.ctx.textAlign = "center";
        this.ctx.fillStyle = "#0FF";
        this.ctx.fillText(text, pacman.pixel.x, pacman.pixel.y);
    },

    // draw each actor (ghosts and pacman)
    drawActors: function() {
        var i;
        // draw such that pacman appears on top
        if (energizer.isActive()) {
            for (i=0; i<4; i++)
                this.drawGhost(ghosts[i]);
            if (!energizer.showingPoints())
                this.drawPacman();
            else
                this.drawEatenPoints();
        }
        // draw such that pacman appears on bottom
        else {
            this.drawPacman();
            for (i=3; i>=0; i--) 
                this.drawGhost(ghosts[i]);
        }
    },

    // draw fruit
    drawFruit: function() {
        if (fruit.isPresent()) {
            this.ctx.fillStyle = "#0F0";
            this.drawCenterPixelSq(this.ctx, fruit.pixel.x, fruit.pixel.y, tileSize+2);
        }
        else if (fruit.isScorePresent()) {
            this.ctx.font = this.pointsEarnedTextSize + "px sans-serif";
            this.ctx.textBaseline = "middle";
            this.ctx.textAlign = "center";
            this.ctx.fillStyle = "#FFF";
            this.ctx.fillText(fruit.getPoints(), fruit.pixel.x, fruit.pixel.y);
        }
    },
};

//////////////////////////////////////////////////////////////
// Simple Renderer
// (render a minimal Pac-Man display using nothing but squares)

// constructor
renderers.Simple = function(ctx,bgCtx) {

    // inherit attributes from Common Renderer
    renderers.Common.call(this,ctx,bgCtx);

    this.messageRow = 21.7;
    this.pointsEarnedTextSize = 1.5*tileSize;

    this.backColor = "#222";
    this.floorColor = "#444";
    this.flashFloorColor = "#999";
};

renderers.Simple.prototype = {

    // inherit functions from Common Renderer
    __proto__: renderers.Common.prototype,

    drawMap: function() {

        // fill background
        this.bgCtx.fillStyle = this.backColor;
        this.bgCtx.fillRect(0,0,tileMap.widthPixels, tileMap.heightPixels);

        var x,y;
        var i;
        var tile;

        // draw floor tiles
        this.bgCtx.fillStyle = (this.flashLevel ? this.flashFloorColor : this.floorColor);
        i=0;
        for (y=0; y<tileMap.numRows; y++)
        for (x=0; x<tileMap.numCols; x++) {
            tile = tileMap.currentTiles[i++];
            if (tile == ' ')
                this.drawNoGroutTile(this.bgCtx,x,y,tileSize);
        }

        // draw pellet tiles
        this.bgCtx.fillStyle = this.pelletColor;
        i=0;
        for (y=0; y<tileMap.numRows; y++)
        for (x=0; x<tileMap.numCols; x++) {
            tile = tileMap.currentTiles[i++];
            if (tile == '.')
                this.drawNoGroutTile(this.bgCtx,x,y,tileSize);
        }
    },

    // draw the current score and high score
    drawScore: function() {
        this.ctx.font = 1.5*tileSize + "px sans-serif";
        this.ctx.textBaseline = "top";
        this.ctx.textAlign = "left";
        this.ctx.fillStyle = "#FFF";
        this.ctx.fillText(game.score, tileSize, tileSize*2);

        this.ctx.font = "bold " + 1.5*tileSize + "px sans-serif";
        this.ctx.textBaseline = "top";
        this.ctx.textAlign = "center";
        this.ctx.fillText("high score", tileSize*tileMap.numCols/2, 3);
        this.ctx.fillText(game.highScore, tileSize*tileMap.numCols/2, tileSize*2);
    },

    // draw the extra lives indicator
    drawExtraLives: function() {
        var i;
        this.ctx.fillStyle = "rgba(255,255,0,0.6)";
        for (i=0; i<game.extraLives; i++)
            this.drawCenterPixelSq(this.ctx, (2*i+3)*tileSize, (tileMap.numRows-2)*tileSize+midTile.y,this.actorSize);
    },

    // draw the current level indicator
    drawLevelIcons: function() {
        var i;
        this.ctx.fillStyle = "rgba(255,255,255,0.5)";
        var w = 2;
        var h = this.actorSize;
        for (i=0; i<game.level; i++)
            this.ctx.fillRect((tileMap.numCols-2)*tileSize - i*2*w, (tileMap.numRows-2)*tileSize+midTile.y-h/2, w, h);
    },

    // draw energizer items on foreground
    drawEnergizers: function() {
        this.ctx.fillStyle = this.energizerColor;
        var e;
        var i;
        for (i=0; i<tileMap.numEnergizers; i++) {
            e = tileMap.energizers[i];
            if (tileMap.currentTiles[e.x+e.y*tileMap.numCols] == 'o')
                this.drawCenterTileSq(this.ctx,e.x,e.y,this.energizerSize);
        }
    },

    // draw pacman
    drawPacman: function(scale, opacity) {
        if (scale == undefined) scale = 1;
        if (opacity == undefined) opacity = 1;
        this.ctx.fillStyle = "rgba(255,255,0,"+opacity+")";
        this.drawCenterPixelSq(this.ctx, pacman.pixel.x, pacman.pixel.y, this.actorSize*scale);
    },

    // draw dying pacman animation (with 0<=t<=1)
    drawDyingPacman: function(t) {
        this.drawPacman(1-t);
    },

    // draw exploding pacman animation (with 0<=t<=1)
    drawExplodingPacman: function(t) {
        this.drawPacman(t,1-t);
    },

    // draw ghost
    drawGhost: function(g) {
        if (g.mode == GHOST_EATEN)
            return;
        var color = g.color;
        if (g.scared)
            color = energizer.isFlash() ? "#FFF" : this.scaredGhostColor;
        else if (g.mode == GHOST_GOING_HOME || g.mode == GHOST_ENTERING_HOME)
            color = "rgba(255,255,255,0.3)";
        this.ctx.fillStyle = color;
        this.drawCenterPixelSq(this.ctx, g.pixel.x, g.pixel.y, this.actorSize);
    },

};


//////////////////////////////////////////////////////////////
// Arcade Renderer
// (render a display close to the original arcade)

// constructor
renderers.Arcade = function(ctx,bgCtx) {

    // inherit attributes from Common Renderer
    renderers.Common.call(this,ctx,bgCtx);

    this.messageRow = 20;
    this.pelletSize = 2;
    this.energizerSize = tileSize;

    this.backColor = "#000";
    this.floorColor = "#000";
    this.flashWallColor = "#FFF";
};

renderers.Arcade.prototype = {

    // inherit functions from Common Renderer
    __proto__: renderers.Common.prototype,

    drawMap: function() {

        // fill background
        this.bgCtx.fillStyle = this.backColor;
        this.bgCtx.fillRect(0,0,tileMap.widthPixels, tileMap.heightPixels);

        var x,y;
        var i;
        var tile;

        // draw wall tiles
        this.bgCtx.fillStyle = (this.flashLevel ? this.flashWallColor : tileMap.wallColor);
        i=0;
        for (y=0; y<tileMap.numRows; y++)
        for (x=0; x<tileMap.numCols; x++) {
            tile = tileMap.currentTiles[i++];
            if (tile == '|')
                this.drawNoGroutTile(this.bgCtx,x,y,tileSize);
        }

        // draw floor tiles
        this.bgCtx.fillStyle = this.floorColor;
        i=0;
        for (y=0; y<tileMap.numRows; y++)
        for (x=0; x<tileMap.numCols; x++) {
            tile = tileMap.currentTiles[i++];
            if (tile == '_')
                this.drawNoGroutTile(this.bgCtx,x,y,tileSize);
            else if (tile != '|')
                this.drawCenterTileSq(this.bgCtx,x,y,this.actorSize+4);
        }

        // draw pellet tiles
        this.bgCtx.fillStyle = tileMap.pelletColor;
        i=0;
        for (y=0; y<tileMap.numRows; y++)
        for (x=0; x<tileMap.numCols; x++) {
            tile = tileMap.currentTiles[i++];
            if (tile == '.')
                this.drawCenterTileSq(this.bgCtx,x,y,this.pelletSize);
        }
    },

    // draw the current score and high score
    drawScore: function() {
        this.ctx.font = 1.25*tileSize + "px sans-serif";
        this.ctx.textBaseline = "top";
        this.ctx.textAlign = "left";
        this.ctx.fillStyle = "#FFF";
        this.ctx.fillText(game.score, tileSize, tileSize*1.5);

        this.ctx.font = "bold " + 1.25*tileSize + "px sans-serif";
        this.ctx.textBaseline = "top";
        this.ctx.textAlign = "center";
        this.ctx.fillText("high score", tileSize*tileMap.numCols/2, 1.5);
        this.ctx.fillText(game.highScore, tileSize*tileMap.numCols/2, tileSize*1.5);
    },

    // draw the extra lives indicator
    drawExtraLives: function() {
        var i;
        this.ctx.fillStyle = pacman.color;

        this.ctx.save();
        this.ctx.translate(3*tileSize, (tileMap.numRows-1)*tileSize);
        this.ctx.beginPath();
        for (i=0; i<game.extraLives; i++) {
            addPacmanBody(this.ctx, DIR_RIGHT, Math.PI/6);
            this.ctx.translate(2*tileSize,0);
        }
        this.ctx.closePath();
        this.ctx.fill();
        this.ctx.restore();
    },

    // draw the current level indicator
    drawLevelIcons: function() {
        var i;
        this.ctx.fillStyle = "rgba(255,255,255,0.5)";
        var w = 2;
        var h = this.actorSize;
        for (i=0; i<game.level; i++)
            this.ctx.fillRect((tileMap.numCols-2)*tileSize - i*2*w, (tileMap.numRows-1)*tileSize-h/2, w, h);
    },

    // draw ghost
    drawGhost: function(g) {
        if (g.mode == GHOST_EATEN)
            return;
        var color = g.color;
        if (g.scared)
            color = energizer.isFlash() ? "#FFF" : this.scaredGhostColor;
        else if (g.mode == GHOST_GOING_HOME || g.mode == GHOST_ENTERING_HOME)
            color = "rgba(255,255,255,0)";

        this.ctx.save();
        this.ctx.translate(g.pixel.x-this.actorSize/2, g.pixel.y-this.actorSize/2);

        // draw body
        this.ctx.beginPath();
        addGhostHead(this.ctx);
        if (Math.floor(g.frames/6) % 2 == 0) // change animation frame every 6 ticks
            addGhostFeet1(this.ctx);
        else
            addGhostFeet2(this.ctx);
        this.ctx.closePath();
        this.ctx.fillStyle = color;
        this.ctx.fill();

        // draw face
        if (g.scared)
            addScaredGhostFace(this.ctx, energizer.isFlash());
        else
            addGhostEyes(this.ctx,g.dirEnum);

        this.ctx.restore();
    },

    // draw pacman
    drawPacman: function() {
        this.ctx.save();
        this.ctx.translate(pacman.pixel.x, pacman.pixel.y);

        this.ctx.beginPath();
        var frame = Math.floor(pacman.steps/2)%4; // change animation frame every 2 steps
        if (frame == 3) 
            frame = 1;
        addPacmanBody(this.ctx, pacman.dirEnum, frame*Math.PI/6);
        this.ctx.closePath();
        this.ctx.fillStyle = pacman.color;
        this.ctx.fill();

        this.ctx.restore();
    },

    // draw dying pacman animation (with 0<=t<=1)
    // open mouth all the way while shifting corner of mouth forward
    drawDyingPacman: function(t) {
        this.ctx.save();
        this.ctx.translate(pacman.pixel.x, pacman.pixel.y);
        this.ctx.beginPath();
        var frame = Math.floor(pacman.steps/2)%4;
        if (frame == 3) 
            frame = 1;
        var a = frame*Math.PI/6;
        addPacmanBody(this.ctx, pacman.dirEnum, a + t*(Math.PI-a),4*t);
        this.ctx.closePath();
        this.ctx.fillStyle = pacman.color;
        this.ctx.fill();
        this.ctx.restore();
    },

    // draw exploding pacman animation (with 0<=t<=1)
    drawExplodingPacman: function(t) {
        this.ctx.save();
        this.ctx.translate(pacman.pixel.x, pacman.pixel.y);
        this.ctx.beginPath();
        addPacmanBody(this.ctx, pacman.dirEnum, 0, 0, t,-3);
        this.ctx.closePath();
        this.ctx.fillStyle = "rgba(255,255,0," + (1-t) + ")";
        this.ctx.fill();
        this.ctx.restore();
    },

    // draw energizer items on foreground
    drawEnergizers: function() {
        var e;
        var i;
        this.ctx.beginPath();
        for (i=0; i<tileMap.numEnergizers; i++) {
            e = tileMap.energizers[i];
            if (tileMap.currentTiles[e.x+e.y*tileMap.numCols] == 'o') {
                this.ctx.moveTo(e.x,e.y);
                this.ctx.arc(e.x*tileSize+midTile.x,e.y*tileSize+midTile.y,this.energizerSize/2,0,Math.PI*2);
            }
        }
        this.ctx.closePath();
        this.ctx.fillStyle = this.energizerColor;
        this.ctx.fill();
    },

};
//////////////////////////////////////////////////////////////////////////////////////
// Sprites
// (sprites are created using canvas paths)

// add top of the ghost head to the current canvas path
var addGhostHead = (function() {

    // pixel coordinates for the top of the head
    // on the original arcade ghost sprite
    var coords = [
        0,6,
        1,3,
        2,2,
        3,1,
        4,1,
        5,0,
        8,0,
        9,1,
        10,1,
        11,2,
        12,3,
        13,6,
    ];

    return function(ctx) {
        var i;
        ctx.save();

        // translate by half a pixel to the right
        // to try to force centering
        ctx.translate(0.5,0);

        // draw lines between pixel coordinates
        ctx.moveTo(coords[0],coords[1]);
        for (i=2; i<coords.length; i+=2)
            ctx.lineTo(coords[i],coords[i+1]);

        ctx.restore();
    };
})();

// add first ghost animation frame feet to the current canvas path
var addGhostFeet1 = (function(){

    // pixel coordinates for the first feet animation
    // on the original arcade ghost sprite
    var coords = [
        13,13,
        11,11,
        9,13,
        8,13,
        8,11,
        5,11,
        5,13,
        4,13,
        2,11,
        0,13,
    ];

    return function(ctx) {
        var i;
        ctx.save();

        // translate half a pixel right and down
        // to try to force centering and proper height
        ctx.translate(0.5,0.5);

        // continue previous path (assuming ghost head)
        // by drawing lines to each of the pixel coordinates
        for (i=0; i<coords.length; i+=2)
            ctx.lineTo(coords[i],coords[i+1]);

        ctx.restore();
    };

})();

// add second ghost animation frame feet to the current canvas path
var addGhostFeet2 = (function(){

    // pixel coordinates for the second feet animation
    // on the original arcade ghost sprite
    var coords = [
        13,12,
        12,13,
        11,13,
        9,11,
        7,13,
        6,13,
        4,11,
        2,13,
        1,13,
        0,12,
    ];

    return function(ctx) {
        var i;
        ctx.save();

        // translate half a pixel right and down
        // to try to force centering and proper height
        ctx.translate(0.5,0.5);

        // continue previous path (assuming ghost head)
        // by drawing lines to each of the pixel coordinates
        for (i=0; i<coords.length; i+=2)
            ctx.lineTo(coords[i],coords[i+1]);

        ctx.restore();
    };

})();

// draw regular ghost eyes
var addGhostEyes = function(ctx,dirEnum){
    var i;

    ctx.save();
    ctx.translate(2,3);

    // translate eye balls to correct position
    if (dirEnum == DIR_LEFT) ctx.translate(-1,0);
    else if (dirEnum == DIR_RIGHT) ctx.translate(1,0);
    else if (dirEnum == DIR_UP) ctx.translate(0,-1);
    else if (dirEnum == DIR_DOWN) ctx.translate(0,1);

    // draw eye balls
    ctx.fillStyle = "#FFF";
    ctx.fillRect(1,0,2,5); // left
    ctx.fillRect(0,1,4,3);
    ctx.translate(6,0);
    ctx.fillRect(1,0,2,5); // right
    ctx.fillRect(0,1,4,3);

    // translate pupils to correct position
    if (dirEnum == DIR_LEFT) ctx.translate(0,2);
    else if (dirEnum == DIR_RIGHT) ctx.translate(2,2);
    else if (dirEnum == DIR_UP) ctx.translate(1,0);
    else if (dirEnum == DIR_DOWN) ctx.translate(1,3);

    // draw pupils
    ctx.fillStyle = "#00F";
    ctx.fillRect(0,0,2,2); // right
    ctx.translate(-6,0);
    ctx.fillRect(0,0,2,2); // left

    ctx.restore();
};

// draw scared ghost face
var addScaredGhostFace = function(ctx,flash){
    ctx.fillStyle = flash ? "#F00" : "#FF0";

    // eyes
    ctx.fillRect(4,5,2,2);
    ctx.fillRect(8,5,2,2);

    // mouth
    ctx.fillRect(1,10,1,1);
    ctx.fillRect(12,10,1,1);
    ctx.fillRect(2,9,2,1);
    ctx.fillRect(6,9,2,1);
    ctx.fillRect(10,9,2,1);
    ctx.fillRect(4,10,2,1);
    ctx.fillRect(8,10,2,1);
};

// draw pacman body
var addPacmanBody = function(ctx,dirEnum,angle,mouthShift,scale,centerShift) {

    if (mouthShift == undefined) mouthShift = 0;
    if (centerShift == undefined) centerShift = 0;
    if (scale == undefined) scale = 1;

    ctx.save();

    // rotate to current heading direction
    var d90 = Math.PI/2;
    if (dirEnum == DIR_UP) ctx.rotate(3*d90);
    else if (dirEnum == DIR_RIGHT) ctx.rotate(0);
    else if (dirEnum == DIR_DOWN) ctx.rotate(d90);
    else if (dirEnum == DIR_LEFT) ctx.rotate(2*d90);

    // plant corner of mouth
    ctx.moveTo(-3+mouthShift,0);

    // draw head outline
    ctx.arc(centerShift,0,6.5*scale,angle,2*Math.PI-angle);

    ctx.restore();
};
//////////////////////////////////////////////////////////////////////////////////////
// Screen
// (controls the display and input)

var screen = (function() {

    // html elements
    var divContainer;
    var canvas, ctx;
    var bgCanvas, bgCtx;

    // drawing scale
    var scale = 1.5;        // scale everything by this amount
    var smoothScale = true; // smooth is a vector scale rather than a pixel scale

    // creates a canvas
    var makeCanvas = function() {
        var c = document.createElement("canvas");

        // use conventional pacman map size
        c.width = 28*tileSize;
        c.height = 36*tileSize;

        // scale 'direct' width and height properties for smooth vector scaling
        if (smoothScale) {
            c.width *= scale;
            c.height *= scale;
        }
        // scale 'style' width and height properties for pixel stretch scaling
        else {
            c.style.width = c.width*scale;
            c.style.height = c.height*scale;
        }

        // transform to scale
        var ctx = c.getContext("2d");
        if (smoothScale)
            ctx.scale(scale,scale);
        return c;
    };

    // add interative options to tune the game
    var addControls = function() {

        var controlDiv = document.getElementById("pacman-controls");
        if (!controlDiv)
            return;

        // used for making html elements with unique id's
        var id = 0;

        // create a form field group with the given title caption
        var makeFieldSet = function(title) {
            var fieldset = document.createElement('fieldset');
            var legend = document.createElement('legend');
            legend.appendChild(document.createTextNode(title));
            fieldset.appendChild(legend);
            return fieldset;
        };

        // add a checkbox
        var addCheckbox = function(fieldset, caption, onChange, on, outline, sameline) {
            id++;
            var checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.id = 'check'+id;
            checkbox.checked = on;
            checkbox.onchange = function() { onChange(checkbox.checked); };
            fieldset.appendChild(checkbox);

            if (caption) {
                label = document.createElement('label');
                label.htmlFor = 'check'+id;
                label.appendChild(document.createTextNode(caption));
                fieldset.appendChild(label);
            }

            if (outline) {
                checkbox.style.outline = outline;
                checkbox.style.margin = "5px";
            }
            if (!sameline)
                fieldset.appendChild(document.createElement('br'));
        };

        // add a radio button
        var addRadio = function(fieldset, group, caption, onChange, on, sameline) {
            id++;
            var radio = document.createElement('input');
            radio.type = 'radio';
            radio.name = group;
            radio.id = 'radio'+id;
            radio.checked = on;
            radio.onchange = function() { onChange(radio.checked); };
            fieldset.appendChild(radio);

            if (caption) {
                label = document.createElement('label');
                label.htmlFor = 'radio'+id;
                label.appendChild(document.createTextNode(caption));
                fieldset.appendChild(label);
            }

            if (!sameline)
                fieldset.appendChild(document.createElement('br'));
        };

        var makeLabel = function(caption) {
            var label;
            label = document.createElement('label');
            label.style.padding = "3px";
            label.appendChild(document.createTextNode(caption));
            return label;
        };

        var addSlider = function(fieldset, suffix, value, min, max, step, onChange) {
            id++;
            var slider = document.createElement('input');
            slider.type = 'range';
            slider.id = 'range'+id;
            slider.value = value;
            slider.min = min;
            slider.max = max;
            slider.step = step;
            fieldset.appendChild(slider);
            fieldset.appendChild(document.createElement('br'));
            /*
            var div = document.createElement('div');
            div.innerHTML = '<input id="range' + id +'" type="range" value="' + value + '" min="' + min + '" max="' + max + '" step="' + step + '">';
            fieldset.appendChild(div);
            */

            var label;

            label = makeLabel(''+value+suffix);
            slider.onchange = function() {
                if (onChange)
                    onChange(this.value);
                label.innerHTML = ''+this.value+suffix;
            };
            fieldset.appendChild(label);
            fieldset.appendChild(document.createElement('br'));
        };

        ///////////////////////////////////////////////////
        // create form for our controls
        var form = document.createElement('form');

        var fieldset; // var to receive the constructed field sets

        ///////////////////////////////////////////////////
        // options group
        fieldset = makeFieldSet('Player');
        addCheckbox(fieldset, 'autoplay', function(on) { pacman.ai = on; });
        addCheckbox(fieldset, 'invincible', function(on) { pacman.invincible = on; });
        addCheckbox(fieldset, 'double speed', function(on) { pacman.doubleSpeed = on; });
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // machine speed group
        var changeRate = function(n) {
            game.pause();
            game.setUpdatesPerSecond(n);
            game.resume();
        };
        fieldset = makeFieldSet('Machine Speed');
        addSlider(fieldset, '%', 100, 0, 200, 20, function(value) {
            if (value == 0)
                game.pause();
            else
                changeRate(60*value/100);
        });
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // renderers group
        fieldset = makeFieldSet('Renderer');
        var makeSwitchRenderer = function(renderer) {
            return function(on) {
                if (on) {
                    game.switchState(fadeRendererState(game.state, renderer, 24));
                }
            };
        };
        addRadio(fieldset, 'render', 'minimal', makeSwitchRenderer(0), false, true);
        addRadio(fieldset, 'render', 'arcade', makeSwitchRenderer(1),true);
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // draw actor targets group
        fieldset = makeFieldSet('Behavior');
        addCheckbox(fieldset, '', function(on) { blinky.isDrawTarget = on; }, false, '4px solid ' + blinky.color, true);
        addCheckbox(fieldset, '', function(on) { pinky.isDrawTarget = on; },  false, '4px solid ' + pinky.color, true);
        addCheckbox(fieldset, '', function(on) { inky.isDrawTarget = on; },   false, '4px solid ' + inky.color, true);
        addCheckbox(fieldset, '', function(on) { clyde.isDrawTarget = on; },  false, '4px solid ' + clyde.color, true);
        addCheckbox(fieldset, '', function(on) { pacman.isDrawTarget = on; }, false, '4px solid ' + pacman.color, true);
        fieldset.appendChild(makeLabel('Logic '));

        fieldset.appendChild(document.createElement('br'));

        addCheckbox(fieldset, '', function(on) { blinky.isDrawPath = on; }, false, '4px solid ' + blinky.color, true);
        addCheckbox(fieldset, '', function(on) { pinky.isDrawPath = on; },  false, '4px solid ' + pinky.color, true);
        addCheckbox(fieldset, '', function(on) { inky.isDrawPath = on; },   false, '4px solid ' + inky.color, true);
        addCheckbox(fieldset, '', function(on) { clyde.isDrawPath = on; },  false, '4px solid ' + clyde.color, true);
        addCheckbox(fieldset, '', function(on) { pacman.isDrawPath = on; }, false, '4px solid ' + pacman.color, true);
        fieldset.appendChild(makeLabel('Path '));

        fieldset.appendChild(document.createElement('br'));

        addSlider(fieldset, ' tile path', actorPathLength, 8, 64, 8, function(value) {
            actorPathLength = value;
        });

        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // maps group
        fieldset = makeFieldSet('Maps');
        var makeSwitchMap = function(map) {
            return function(on) {
                if (on) {
                    readyNewState.nextMap = map;
                    game.switchState(readyNewState, 60);
                }
            };
        };
        addRadio(fieldset, 'map', 'Pac-Man',       makeSwitchMap(MAP_PACMAN),true);
        addRadio(fieldset, 'map', 'Ms. Pac-Man 1', makeSwitchMap(MAP_MSPACMAN1));
        addRadio(fieldset, 'map', 'Ms. Pac-Man 2', makeSwitchMap(MAP_MSPACMAN2));
        addRadio(fieldset, 'map', 'Ms. Pac-Man 3', makeSwitchMap(MAP_MSPACMAN3));
        addRadio(fieldset, 'map', 'Ms. Pac-Man 4', makeSwitchMap(MAP_MSPACMAN4));
        form.appendChild(fieldset);

        // add control from to our div
        controlDiv.appendChild(form);
    };

    var addInput = function() {
        // handle key press event
        document.onkeydown = function(e) {
            var key = (e||window.event).keyCode;
            switch (key) {
                // steer pac-man
                case 37: pacman.setNextDir(DIR_LEFT); break;
                case 38: pacman.setNextDir(DIR_UP); break;
                case 39: pacman.setNextDir(DIR_RIGHT); break;
                case 40: pacman.setNextDir(DIR_DOWN); break;
                default: return;
            }
            // prevent default action for arrow keys
            // (don't scroll page with arrow keys)
            e.preventDefault();
        };
    };

    return {
        create: function() {
            // create foreground and background canvases
            canvas = makeCanvas();
            bgCanvas = makeCanvas();
            ctx = canvas.getContext("2d");
            bgCtx = bgCanvas.getContext("2d");

            // add canvas and controls to our div
            divContainer = document.getElementById('pacman');
            divContainer.appendChild(canvas);
            addControls();
            addInput();

            // add our screen.onClick event to canvas
            var that = this;
            canvas.onmousedown = function() {
                if (that.onClick)
                    that.onClick();
            };

            // create renderers
            this.renderers = [
                new renderers.Simple(ctx, bgCtx),
                new renderers.Arcade(ctx, bgCtx),
            ];

            // set current renderer
            this.renderer = this.renderers[1];
        },

        // switch to the given renderer index
        switchRenderer: function(i) {
            this.renderer = this.renderers[i];
            this.renderer.drawMap();
        },

        // copy background canvas to the foreground canvas
        blitMap: function() {
            if (smoothScale) ctx.scale(1/scale,1/scale);
            ctx.drawImage(bgCanvas,0,0);
            if (smoothScale) ctx.scale(scale,scale);
        },
    };
})();

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
//////////////////////////////////////////////////////////////////////////////////////
// Ghost class

// modes representing the ghosts' current command
var GHOST_CMD_CHASE = 0;
var GHOST_CMD_SCATTER = 1;

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

    // call Actor's reset function to reset position and direction
    Actor.prototype.reset.apply(this);
};

// indicates if we slow down in the tunnel
Ghost.prototype.isSlowInTunnel = function() {
    // special case for Ms. Pac-Man (slow down only for the first three levels)
    if (game.mode == GAME_MSPACMAN)
        return game.level <= 3;
    else
        return true;
};

// gets the number of steps to move in this frame
Ghost.prototype.getNumSteps = function() {

    var pattern = STEP_GHOST;

    if (game.state == menuState)
        pattern = STEP_GHOST;
    else if (this.mode == GHOST_GOING_HOME || this.mode == GHOST_ENTERING_HOME)
        return 2;
    else if (this.mode == GHOST_LEAVING_HOME || this.mode == GHOST_PACING_HOME)
        pattern = STEP_GHOST_TUNNEL;
    else if (tileMap.isTunnelTile(this.tile.x, this.tile.y) && this.isSlowInTunnel())
        pattern = STEP_GHOST_TUNNEL;
    else if (this.scared)
        pattern = STEP_GHOST_FRIGHT;
    else if (this.elroy == 1)
        pattern = STEP_ELROY1;
    else if (this.elroy == 2)
        pattern = STEP_ELROY2;

    return this.getStepSizeFromTable(game.level ? game.level : 1, pattern);
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
        if (this.tile.x == tileMap.doorTile.x && this.tile.y == tileMap.doorTile.y) {
            this.targetting = false;
            // walk to the door, or go through if already there
            if (this.pixel.x == tileMap.doorPixel.x) {
                this.mode = GHOST_ENTERING_HOME;
                this.setDir(DIR_DOWN);
            }
            else
                this.setDir(DIR_RIGHT);
        }
    };

    steerFuncs[GHOST_ENTERING_HOME] = function() {
        if (this.pixel.y == tileMap.homeBottomPixel)
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
            if (this.pixel.x == tileMap.doorPixel.x)
                this.setDir(DIR_UP);
            else
                this.setDir(this.pixel.x < tileMap.doorPixel.x ? DIR_RIGHT : DIR_LEFT);
        }
        // pace back and forth
        else {
            if (this.pixel.y == tileMap.homeTopPixel)
                this.setDir(DIR_DOWN);
            else if (this.pixel.y == tileMap.homeBottomPixel)
                this.setDir(DIR_UP);
        }
    };

    steerFuncs[GHOST_LEAVING_HOME] = function() {
        if (this.pixel.x == tileMap.doorPixel.x)
            // reached door
            if (this.pixel.y == tileMap.doorPixel.y) {
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
        game.mode == GAME_MSPACMAN && 
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
    openTiles = getOpenSurroundTiles(this.tile, this.dirEnum);

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
            this.targetTile.x = tileMap.doorTile.x;
            this.targetTile.y = tileMap.doorTile.y;
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
        if (tileMap.constrainGhostTurns)
            tileMap.constrainGhostTurns(this.tile, openTiles);

        // choose direction that minimizes distance to target
        dirEnum = getTurnClosestToTarget(this.tile, this.targetTile, openTiles);
    }

    // commit the direction
    this.setDir(dirEnum);
};

//////////////////////////////////////////////////////////////////////////////////////
// Player is the controllable character (Pac-Man)

// Player constructor
var Player = function() {

    // inherit data from Actor
    Actor.apply(this);

    this.nextDir = {};

    // determines if this player should be AI controlled
    this.ai = false;
};

// inherit functions from Actor
Player.prototype.__proto__ = Actor.prototype;

// reset the state of the player on new level or level restart
Player.prototype.reset = function() {

    this.setNextDir(DIR_LEFT);

    this.eatPauseFramesLeft = 0;   // current # of frames left to pause after eating

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
    if (this.doubleSpeed)
        return 2;

    var pattern = energizer.isActive() ? STEP_PACMAN_FRIGHT : STEP_PACMAN;
    return this.getStepSizeFromTable(game.level, pattern);
};

// move forward one step
Player.prototype.step = (function(){

    // return sign of a number
    var sign = function(x) {
        if (x<0) return -1;
        if (x>0) return 1;
        return 0;
    };

    return function() {

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
        return stop ? 0 : 1;
    };
})();

// determine direction
Player.prototype.steer = function() {

    // if AI-controlled, only turn at mid-tile
    if (this.ai) {
        if (this.distToMid.x != 0 || this.distToMid.y != 0)
            return;

        // make turn that is closest to target
        var openTiles = getOpenSurroundTiles(this.tile, this.dirEnum);
        this.setTarget();
        this.setNextDir(getTurnClosestToTarget(this.tile, this.targetTile, openTiles));
    }
    else
        this.targetting = undefined;

    // head in the desired direction if possible
    if (tileMap.isNextTileFloor(this.tile, this.nextDir))
        this.setDir(this.nextDirEnum);
};


// update this frame
Player.prototype.update = function(j) {

    var numSteps = this.getNumSteps();
    if (j >= numSteps)
        return;

    // skip frames
    if (this.eatPauseFramesLeft > 0) {
        if (j == numSteps-1)
            this.eatPauseFramesLeft--;
        return;
    }

    // call super function to update position and direction
    Actor.prototype.update.call(this,j);

    // eat something
    var t = tileMap.getTile(this.tile.x, this.tile.y);
    if (t == '.' || t == 'o') {
        this.eatPauseFramesLeft = (t=='.') ? 1 : 3;

        tileMap.onDotEat(this.tile.x, this.tile.y);
        ghostReleaser.onDotEat();
        fruit.onDotEat();
        game.addScore((t=='.') ? 10 : 50);

        if (!tileMap.allDotsEaten() && t=='o')
            energizer.activate();
    }
};
//////////////////////////////////////////////////////////////////////////////////////
// create all the actors

var blinky = new Ghost();
blinky.name = "blinky";
blinky.color = "#FF0000";
blinky.pathColor = "rgba(255,0,0,0.8)";

var pinky = new Ghost();
pinky.name = "pinky";
pinky.color = "#FFB8FF";
pinky.pathColor = "rgba(255,184,255,0.8)";

var inky = new Ghost();
inky.name = "inky";
inky.color = "#00FFFF";
inky.pathColor = "rgba(0,255,255,0.8)";

var clyde = new Ghost();
clyde.name = "clyde";
clyde.color = "#FFB851";
clyde.pathColor = "rgba(255,184,81,0.8)";

var pacman = new Player();
pacman.name = "pacman";
pacman.color = "#FFFF00";
pacman.pathColor = "rgba(255,255,0,0.8)";

// order at which they appear in original arcade memory
// (suggests drawing/update order)
var actors = [blinky, pinky, inky, clyde, pacman];
var ghosts = [blinky, pinky, inky, clyde];
/////////////////////////////////////////////////////////////////
// Targetting
// (a definition for each actor's targetting algorithm and a draw function to visualize it)

// the tile length of the path drawn toward the target
var actorPathLength = 16;

(function() {

// the size of the square rendered over a target tile (just half a tile)
var targetSize = midTile.y;

// when drawing paths, use these offsets so they don't completely overlap each other
pacman.pathCenter = { x:0, y:0};
blinky.pathCenter = { x:-2, y:-2 };
pinky.pathCenter = { x:-1, y:-1 };
inky.pathCenter = { x:1, y:1 };
clyde.pathCenter = { x:2, y:2 };

/////////////////////////////////////////////////////////////////
// blinky directly targets pacman

blinky.setTarget = function() {
    this.targetTile.x = pacman.tile.x;
    this.targetTile.y = pacman.tile.y;
    this.targetting = 'pacman';
};
blinky.drawTarget = function(ctx) {
    if (!this.targetting) return;
    ctx.fillStyle = this.color;
    if (this.targetting == 'pacman')
        screen.renderer.drawCenterPixelSq(ctx, pacman.pixel.x, pacman.pixel.y, targetSize);
    else
        screen.renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
};
blinky.getPathDistLeft = function(fromPixel, dirEnum) {
    var distLeft = tileSize;
    if (this.targetting == 'pacman') {
        if (dirEnum == DIR_UP || dirEnum == DIR_DOWN)
            distLeft = Math.abs(fromPixel.y - pacman.pixel.y);
        else
            distLeft = Math.abs(fromPixel.x - pacman.pixel.x);
    }
    return distLeft;
};

/////////////////////////////////////////////////////////////////
// pinky targets four tiles ahead of pacman

pinky.setTarget = function() {
    this.targetTile.x = pacman.tile.x + 4*pacman.dir.x;
    this.targetTile.y = pacman.tile.y + 4*pacman.dir.y;
    this.targetting = 'pacman';
};
pinky.drawTarget = function(ctx) {
    if (!this.targetting) return;
    ctx.fillStyle = this.color;

    var px = pacman.pixel.x + 4*pacman.dir.x*tileSize;
    var py = pacman.pixel.y + 4*pacman.dir.y*tileSize;

    if (this.targetting == 'pacman') {
        ctx.beginPath();
        ctx.moveTo(pacman.pixel.x, pacman.pixel.y);
        ctx.lineTo(px, py);
        ctx.closePath();
        ctx.stroke();
        screen.renderer.drawCenterPixelSq(ctx, px,py, targetSize);
    }
    else
        screen.renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
};
pinky.getPathDistLeft = function(fromPixel, dirEnum) {
    var distLeft = tileSize;
    if (this.targetting == 'pacman') {
        if (dirEnum == DIR_UP || dirEnum == DIR_DOWN)
            distLeft = Math.abs(fromPixel.y - (pacman.pixel.y + pacman.dir.y*tileSize*4));
        else
            distLeft = Math.abs(fromPixel.x - (pacman.pixel.x + pacman.dir.x*tileSize*4));
    }
    return distLeft;
};

/////////////////////////////////////////////////////////////////
// inky targets twice the distance from blinky to two tiles ahead of pacman
inky.getTargetTile = function() {
    var px = pacman.tile.x + 2*pacman.dir.x;
    var py = pacman.tile.y + 2*pacman.dir.y;
    return {
        x : blinky.tile.x + 2*(px - blinky.tile.x),
        y : blinky.tile.y + 2*(py - blinky.tile.y),
    };
};
inky.getTargetPixel = function() {
    var px = pacman.pixel.x + 2*pacman.dir.x*tileSize;
    var py = pacman.pixel.y + 2*pacman.dir.y*tileSize;
    return {
        x : blinky.pixel.x + 2*(px-blinky.pixel.x),
        y : blinky.pixel.y + 2*(py-blinky.pixel.y),
    };
};
inky.setTarget = function() {
    this.targetTile = this.getTargetTile();
    this.targetting = 'pacman';
};
inky.drawTarget = function(ctx) {
    if (!this.targetting) return;
    ctx.fillStyle = this.color;
    var pixel;

    if (this.targetting == 'pacman') {
        pixel = this.getTargetPixel();
        ctx.beginPath();
        ctx.moveTo(blinky.pixel.x, blinky.pixel.y);
        ctx.lineTo(pixel.x, pixel.y);
        ctx.closePath();
        ctx.stroke();
        screen.renderer.drawCenterPixelSq(ctx, pixel.x, pixel.y, targetSize);
    }
    else
        screen.renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
};
inky.getPathDistLeft = function(fromPixel, dirEnum) {
    var distLeft = tileSize;
    var toPixel;
    if (this.targetting == 'pacman') {
        toPixel = this.getTargetPixel();
        if (dirEnum == DIR_UP || dirEnum == DIR_DOWN)
            distLeft = Math.abs(toPixel.y - fromPixel.y);
        else
            distLeft = Math.abs(toPixel.x - fromPixel.x);
    }
    return distLeft;
};

/////////////////////////////////////////////////////////////////
// clyde targets pacman if >=8 tiles away, otherwise targets home

clyde.setTarget = function() {
    var dx = pacman.tile.x - this.tile.x;
    var dy = pacman.tile.y - this.tile.y;
    var dist = dx*dx+dy*dy;
    if (dist >= 64) {
        this.targetTile.x = pacman.tile.x;
        this.targetTile.y = pacman.tile.y;
        this.targetting = 'pacman';
    }
    else {
        this.targetTile.x = this.cornerTile.x;
        this.targetTile.y = this.cornerTile.y;
        this.targetting = 'corner';
    }
};
clyde.drawTarget = function(ctx) {
    if (!this.targetting) return;
    ctx.fillStyle = this.color;

    if (this.targetting == 'pacman') {
        ctx.beginPath();
        ctx.arc(pacman.pixel.x, pacman.pixel.y, tileSize*8,0, 2*Math.PI);
        ctx.closePath();
        ctx.stroke();
        screen.renderer.drawCenterPixelSq(ctx, pacman.pixel.x, pacman.pixel.y, targetSize);
    }
    else
        screen.renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
};
clyde.getPathDistLeft = function(fromPixel, dirEnum) {
    var distLeft = tileSize;
    if (this.targetting == 'pacman') {
        if (dirEnum == DIR_UP || dirEnum == DIR_DOWN)
            distLeft = Math.abs(fromPixel.y - pacman.pixel.y);
        else
            distLeft = Math.abs(fromPixel.x - pacman.pixel.x);
    }
    return distLeft;
};


/////////////////////////////////////////////////////////////////
// pacman targets twice the distance from pinky to pacman or target pinky

pacman.setTarget = function() {
    if (blinky.mode == GHOST_GOING_HOME || blinky.scared) {
        this.targetTile.x = pinky.tile.x;
        this.targetTile.y = pinky.tile.y;
        this.targetting = 'pinky';
    }
    else {
        this.targetTile.x = pinky.tile.x + 2*(pacman.tile.x-pinky.tile.x);
        this.targetTile.y = pinky.tile.y + 2*(pacman.tile.y-pinky.tile.y);
        this.targetting = 'flee';
    }
};
pacman.drawTarget = function(ctx) {
    if (!this.ai) return;
    ctx.fillStyle = this.color;
    var px,py;

    if (this.targetting == 'flee') {
        px = pacman.pixel.x - pinky.pixel.x;
        py = pacman.pixel.y - pinky.pixel.y;
        px = pinky.pixel.x + 2*px;
        py = pinky.pixel.y + 2*py;
        ctx.beginPath();
        ctx.moveTo(pinky.pixel.x, pinky.pixel.y);
        ctx.lineTo(px,py);
        ctx.closePath();
        ctx.stroke();
        screen.renderer.drawCenterPixelSq(ctx, px, py, targetSize);
    }
    else {
        screen.renderer.drawCenterPixelSq(ctx, pinky.pixel.x, pinky.pixel.y, targetSize);
    };

};
pacman.getPathDistLeft = function(fromPixel, dirEnum) {
    var distLeft = tileSize;
    var px,py;
    if (this.targetting == 'pinky') {
        if (dirEnum == DIR_UP || dirEnum == DIR_DOWN)
            distLeft = Math.abs(fromPixel.y - pinky.pixel.y);
        else
            distLeft = Math.abs(fromPixel.x - pinky.pixel.x);
    }
    else { // 'flee'
        px = pacman.pixel.x - pinky.pixel.x;
        py = pacman.pixel.y - pinky.pixel.y;
        px = pinky.pixel.x + 2*px;
        py = pinky.pixel.y + 2*py;
        if (dirEnum == DIR_UP || dirEnum == DIR_DOWN)
            distLeft = Math.abs(py - fromPixel.y);
        else
            distLeft = Math.abs(px - fromPixel.x);
    }
    return distLeft;
};

})();
//////////////////////////////////////////////////////////////////////////////////////
// Ghost Commander

// Determines when a ghost should be chasing a target

var ghostCommander = (function() {

    // determine if there is to be a new command issued at the given time
    var getNewCommand = (function(){
        var t;
        var times = [{},{},{}];
        // level 1
        times[0][t=7*60] = GHOST_CMD_CHASE;
        times[0][t+=20*60] = GHOST_CMD_SCATTER;
        times[0][t+=7*60] = GHOST_CMD_CHASE;
        times[0][t+=20*60] = GHOST_CMD_SCATTER;
        times[0][t+=5*60] = GHOST_CMD_CHASE;
        times[0][t+=20*60] = GHOST_CMD_SCATTER;
        times[0][t+=5*60] = GHOST_CMD_CHASE;
        // level 2-4
        times[1][t=7*60] = GHOST_CMD_CHASE;
        times[1][t+=20*60] = GHOST_CMD_SCATTER;
        times[1][t+=7*60] = GHOST_CMD_CHASE;
        times[1][t+=20*60] = GHOST_CMD_SCATTER;
        times[1][t+=5*60] = GHOST_CMD_CHASE;
        times[1][t+=1033*60] = GHOST_CMD_SCATTER;
        times[1][t+=1] = GHOST_CMD_CHASE;
        // level 5+
        times[2][t=7*60] = GHOST_CMD_CHASE;
        times[2][t+=20*60] = GHOST_CMD_SCATTER;
        times[2][t+=7*60] = GHOST_CMD_CHASE;
        times[2][t+=20*60] = GHOST_CMD_SCATTER;
        times[2][t+=5*60] = GHOST_CMD_CHASE;
        times[2][t+=1037*60] = GHOST_CMD_SCATTER;
        times[2][t+=1] = GHOST_CMD_CHASE;

        return function(frame) {
            var i;
            if (game.level == 1)
                i = 0;
            else if (game.level >= 2 && game.level <= 4)
                i = 1;
            else
                i = 2;
            return times[i][frame];
        };
    })();

    var frame;   // current frame
    var command; // last command given to ghosts

    return {
        reset: function() { 
            command = GHOST_CMD_SCATTER;
            frame = 0;
        },
        update: function() {
            var newCmd;
            if (!energizer.isActive()) {
                newCmd = getNewCommand(frame);
                if (newCmd != undefined) {
                    // new command is always "chase" when in Ms. Pac-Man mode
                    command = (game.mode == GAME_MSPACMAN) ? GHOST_CMD_CHASE : newCmd;

                    for (i=0; i<4; i++)
                        ghosts[i].reverse();
                }
                frame++;
            }
        },
        getCommand: function() {
            return command; 
        },
    };
})();
//////////////////////////////////////////////////////////////////////////////////////
// Ghost Releaser

// Determines when to release ghosts from home

var ghostReleaser = (function(){
    // two separate counter modes for releasing the ghosts from home
    var MODE_PERSONAL = 0;
    var MODE_GLOBAL = 1;

    // ghost enumerations
    var PINKY = 1;
    var INKY = 2;
    var CLYDE = 3;

    // this is how many frames it will take to release a ghost after pacman stops eating
    var getTimeoutLimit = function() { return (game.level < 5) ? 4*60 : 3*60; };

    // dot limits used in personal mode to release ghost after # of dots have been eaten
    var personalDotLimit = {};
    personalDotLimit[PINKY] = function() { return 0; };
    personalDotLimit[INKY] = function() { return (game.level==1) ? 30 : 0; };
    personalDotLimit[CLYDE] = function() {
        if (game.level == 1) return 60;
        if (game.level == 2) return 50;
        return 0;
    };

    // dot limits used in global mode to release ghost after # of dots have been eaten
    var globalDotLimit = {};
    globalDotLimit[PINKY] = 7;
    globalDotLimit[INKY] = 17;
    globalDotLimit[CLYDE] = 32;

    var framesSinceLastDot; // frames elapsed since last dot was eaten
    var mode;               // personal or global dot counter mode
    var ghostCounts = {};   // personal dot counts for each ghost
    var globalCount;        // global dot count

    return {
        onNewLevel: function() {
            mode = MODE_PERSONAL;
            framesSinceLastDot = 0;
            ghostCounts[PINKY] = 0;
            ghostCounts[INKY] = 0;
            ghostCounts[CLYDE] = 0;
        },
        onRestartLevel: function() {
            mode = MODE_GLOBAL;
            globalCount = 0;
            framesSinceLastDot = 0;
        },
        onDotEat: function() {
            var i;

            framesSinceLastDot = 0;

            if (mode == MODE_GLOBAL) {
                globalCount++;
            }
            else {
                for (i=1;i<4;i++) {
                    if (ghosts[i].mode == GHOST_PACING_HOME) {
                        ghostCounts[i]++;
                        break;
                    }
                }
            }

        },
        update: function() {
            var g;

            // use personal dot counter
            if (mode == MODE_PERSONAL) {
                for (i=1;i<4;i++) {
                    g = ghosts[i];
                    if (g.mode == GHOST_PACING_HOME) {
                        if (ghostCounts[i] >= personalDotLimit[i]()) {
                            g.leaveHome();
                            return;
                        }
                        break;
                    }
                }
            }
            // use global dot counter
            else if (mode == MODE_GLOBAL) {
                if (globalCount == globalDotLimit[PINKY] && pinky.mode == GHOST_PACING_HOME) {
                    pinky.leaveHome();
                    return;
                }
                else if (globalCount == globalDotLimit[INKY] && inky.mode == GHOST_PACING_HOME) {
                    inky.leaveHome();
                    return;
                }
                else if (globalCount == globalDotLimit[CLYDE] && clyde.mode == GHOST_PACING_HOME) {
                    globalCount = 0;
                    mode = MODE_PERSONAL;
                    clyde.leaveHome();
                    return;
                }
            }

            // also use time since last dot was eaten
            if (framesSinceLastDot > getTimeoutLimit()) {
                framesSinceLastDot = 0;
                for (i=1;i<4;i++) {
                    g = ghosts[i];
                    if (g.mode == GHOST_PACING_HOME) {
                        g.leaveHome();
                        break;
                    }
                }
            }
            else
                framesSinceLastDot++;
        },
    };
})();
//////////////////////////////////////////////////////////////////////////////////////
// Elroy Timer

// Determines when to put blinky into faster elroy modes

var elroyTimer = (function(){

    // get the number of dots left that should trigger elroy stage #1 or #2
    var getDotsLeftLimit = (function(){
        var dotsLeft = [
            [20,30,40,40,40,50,50,50,60,60,60,70,70,70,100,100,100,100,120,120,120], // elroy1
            [10,15,20,20,20,25,25,25,30,30,30,40,40,40, 50, 50, 50, 50, 60, 60, 60]]; // elroy2
        return function(stage) {
            var i = game.level;
            if (i>21) i = 21;
            return dotsLeft[stage-1][i-1];
        };
    })();

    // when level restarts, blinky must wait for clyde to leave home before resuming elroy mode
    var waitForClyde;

    return {
        onNewLevel: function() {
            waitForClyde = false;
        },
        onRestartLevel: function() {
            waitForClyde = true;
        },
        update: function() {
            var dotsLeft = tileMap.dotsLeft();

            // stop waiting for clyde when clyde leaves home
            if (waitForClyde && clyde.mode != GHOST_PACING_HOME)
                waitForClyde = false;

            if (waitForClyde)
                blinky.elroy = 0;
            else
                if (dotsLeft <= getDotsLeftLimit(2))
                    blinky.elroy = 2;
                else if (dotsLeft <= getDotsLeftLimit(1))
                    blinky.elroy = 1;
                else
                    blinky.elroy = 0;
        },
    };
})();
//////////////////////////////////////////////////////////////////////////////////////
// Energizer

// This handles how long the energizer lasts as well as how long the
// points will display after eating a ghost.

var energizer = (function() {

    // how many seconds to display points when ghost is eaten
    var pointsDuration = 1;

    // how long to stay energized based on current level
    var getDuration = (function(){
        var seconds = [6,5,4,3,2,5,2,2,1,5,2,1,1,3,1,1,0,1];
        return function() {
            var i = game.level;
            return (i > 18) ? 0 : 60*seconds[i-1];
        };
    })();

    // how many ghost flashes happen near the end of frightened mode based on current level
    var getFlashes = (function(){
        var flashes = [5,5,5,5,5,5,5,5,3,5,5,3,3,5,3,3,0,3];
        return function() {
            var i = game.level;
            return (i > 18) ? 0 : flashes[i-1];
        };
    })();

    // "The ghosts change colors every 14 game cycles when they start 'flashing'" -Jamey Pittman
    var flashInterval = 14;

    var count;  // how long in frames energizer has been active
    var active; // indicates if energizer is currently active
    var points; // points that the last eaten ghost was worth
    var pointsFramesLeft; // number of frames left to display points earned from eating ghost

    return {
        reset: function() {
            count = 0;
            active = false;
            points = 100;
            pointsFramesLeft = 0;
            for (i=0; i<4; i++)
                ghosts[i].scared = false;
        },
        update: function() {
            var i;
            if (active) {
                if (count == getDuration())
                    this.reset();
                else
                    count++;
            }
        },
        activate: function() { 
            active = true;
            count = 0;
            points = 100;
            for (i=0; i<4; i++)
                ghosts[i].onEnergized();
        },
        isActive: function() { return active; },
        isFlash: function() { 
            var i = Math.floor((getDuration()-count)/flashInterval);
            return (i<=2*getFlashes()-1) ? (i%2==0) : false;
        },

        getPoints: function() {
            return points;
        },
        addPoints: function() {
            game.addScore(points*=2);
            pointsFramesLeft = pointsDuration*60;
        },
        showingPoints: function() { return pointsFramesLeft > 0; },
        updatePointsTimer: function() { if (pointsFramesLeft > 0) pointsFramesLeft--; },
    };
})();
//////////////////////////////////////////////////////////////////////////////////////
// Fruit

var fruit = (function(){

    var dotLimit1 = 70; // first fruit will appear when this number of dots are eaten
    var dotLimit2 = 170; // second fruit will appear when this number of dots are eaten

    var duration = 9; // number of seconds that the fruit is on the screen
    var scoreDuration = 2; // number of seconds that the fruit score is on the screen

    var framesLeft; // frames left until fruit is off the screen
    var scoreFramesLeft; // frames left until the picked-up fruit score is off the screen

    return {
        pixel: {x:0, y:0}, // pixel location
        setPosition: function(px,py) {
            this.pixel.x = px;
            this.pixel.y = py;
        },
        reset: function() {
            framesLeft = 0;
            scoreFramesLeft = 0;
        },
        update: function() {
            if (framesLeft > 0)
                framesLeft--;
            else if (scoreFramesLeft > 0)
                scoreFramesLeft--;
        },
        onDotEat: function() {
            if (tileMap.dotsEaten == dotLimit1 || tileMap.dotsEaten == dotLimit2)
                framesLeft = 60*duration;
        },
        isPresent: function() { return framesLeft > 0; },
        isScorePresent: function() { return scoreFramesLeft > 0; },
        testCollide: function() {
            if (framesLeft > 0 && pacman.pixel.y == this.pixel.y && Math.abs(pacman.pixel.x - this.pixel.x) <= midTile.x) {
                game.addScore(this.getPoints());
                framesLeft = 0;
                scoreFramesLeft = scoreDuration*60;
            }
        },
        // get number of points a fruit is worth based on the current level
        getPoints: (function() {
            var points = [100,300,500,500,700,700,1000,1000,2000,2000,3000,3000,5000];
            return function() {
                var i = game.level;
                if (i > 13) i = 13;
                return points[i-1];
            };
        })(),
    };

})();
//////////////////////////////////////////////////////////////////////////////////////
// Game

var GAME_PACMAN = 0;
var GAME_MSPACMAN = 1;

var game = (function(){

    var interval; // used by setInterval and clearInterval to execute the game loop
    var framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)
    var nextFrameTime;

    return {

        mode:GAME_PACMAN,

        // scoring
        highScore:0,
        score:0,
        addScore: function(p) {
            if (this.score < 10000 && this.score+p >= 10000)
                this.extraLives++;
            this.score += p;
            if (this.score > this.highScore)
                this.highScore = this.score;
        },

        // current level and lives left
        level:1,
        extraLives:0,

        // scheduling
        setUpdatesPerSecond: function(ups) {
            framePeriod = 1000/ups;
        },
        restart: function() {
            this.switchState(menuState);
            this.resume();
        },
        pause: function() {
            clearInterval(interval);
        },
        resume: function() {
            nextFrameTime = (new Date).getTime();
            interval = setInterval(function(){game.tick();}, 1000/60);
        },
        tick: (function(){
            var maxFrameSkip = 5;
            return function() {
                // call update for every frame period that has elapsed
                var frames = 0;
                while (frames < maxFrameSkip && (new Date).getTime() > nextFrameTime) {
                    this.state.update();
                    nextFrameTime += framePeriod;
                    frames++;
                }
                // draw after updates are caught up
                this.state.draw();
            };
        })(),

        // switches to another game state
        switchState: function(nextState,fadeDuration, continueUpdate1, continueUpdate2) {
            this.state = (fadeDuration) ? fadeNextState(this.state,nextState,fadeDuration, continueUpdate1, continueUpdate2) : nextState;
            this.state.init();
        },

        // switches to another map
        switchMap: function(map) {
            tileMap = maps[map];
            tileMap.onLoad();
        },

    };
})();
//////////////////////////////////////////////////////////////////////////////////////
// States
// (main loops for each state of the game)
// game.state is set to any of these states, each containing an init(), draw(), and update()

//////////////////////////////////////////////////////////////////////////////////////
// Fade state

// Creates a state that will fade from a given state to another in the given amount of time.
// if continueUpdate1 is true, then prevState.update will be called while fading out
// if continueUpdate2 is true, then nextState.update will be called while fading in
var fadeNextState = function (prevState, nextState, frameDuration, continueUpdate1, continueUpdate2) {
    var frames;
    var inFirstState = function() { return frames < frameDuration/2; };
    var getStateTime = function() { return inFirstState() ? frames/frameDuration*2 : frames/frameDuration*2-1; };
    return {
        init: function() {
            frames = 0;
            screen.onClick = undefined; // remove all click events from previous state
        },
        draw: function() {
            var t = getStateTime();
            if (inFirstState()) {
                if (prevState) {
                    prevState.draw();
                    screen.renderer.drawFadeIn(1-t);
                }
            }
            else {
                nextState.draw();
                screen.renderer.drawFadeIn(t);
            }
        },
        update: function() {
            if (inFirstState()) {
                if (continueUpdate1) prevState.update();
            }
            else {
                if (continueUpdate2) nextState.update();
            }

            if (frames == frameDuration)
                game.state = nextState; // hand over state
            else {
                if (frames == frameDuration/2)
                    nextState.init();
                frames++;
            }
        },
    }
};

//////////////////////////////////////////////////////////////////////////////////////
// Fade Renderer state

// creates a state that will pause the current state and fade to the given renderer in a given amount of time
var fadeRendererState = function (currState, nextRenderer, frameDuration) {
    var frames;
    return {
        init: function() {
            frames = 0;
        },
        draw: function() {
            var t;
            currState.draw();
            if (frames < frameDuration/2) {
                t = frames/frameDuration*2;
                screen.renderer.drawFadeIn(1-t);
            }
            else {
                t = frames/frameDuration*2 - 1;
                screen.renderer.drawFadeIn(t);
            }
        },
        update: function() {
            if (frames == frameDuration)
                game.state = currState; // hand over state
            else {
                if (frames == frameDuration/2)
                    screen.switchRenderer(nextRenderer);
                frames++;
            }
        },
    }
};

//////////////////////////////////////////////////////////////////////////////////////
// Menu State
// (the home title screen state)

var menuState = {
    init: function() {
        game.switchMap(MAP_MENU);
        for (i=0; i<5; i++)
            actors[i].reset();
        screen.renderer.drawMap();
        screen.onClick = function() {
            newGameState.nextMap = MAP_PACMAN;
            game.switchState(newGameState,60,true,false);
            screen.onClick = undefined;
        };
    },
    draw: function() {
        screen.blitMap();
        if (game.score != 0 && game.highScore != 0)
            screen.renderer.drawScore();
        screen.renderer.drawMessage("click to play","#FF0");
        screen.renderer.drawActors();
    },
    update: function() {
        var i,j;
        for (j=0; j<2; j++) {
            for (i = 0; i<4; i++)
                ghosts[i].update(j);
        }
        for (i = 0; i<4; i++)
            ghosts[i].frames++;
    },
};

////////////////////////////////////////////////////
// New Game state
// (state when first starting a new game)

var newGameState = (function() {
    var frames;
    var duration = 2;

    return {
        init: function() {
            if (this.nextMap != undefined) {
                game.switchMap(this.nextMap);
                this.nextMap = undefined;
            }
            frames = 0;
            tileMap.resetCurrent();
            screen.renderer.drawMap();
            game.extraLives = 3;
            game.level = 1;
            game.score = 0;
        },
        draw: function() {
            screen.blitMap();
            screen.renderer.drawEnergizers();
            screen.renderer.drawExtraLives();
            screen.renderer.drawLevelIcons();
            screen.renderer.drawScore();
            screen.renderer.drawMessage("ready","#FF0");
        },
        update: function() {
            if (frames == duration*60) {
                game.extraLives--;
                game.switchState(readyNewState);
            }
            else 
                frames++;
        },
    };
})();

////////////////////////////////////////////////////
// Ready state
// (state when map is displayed and pausing before play)

var readyState =  (function(){
    var frames;
    var duration = 2;
    
    return {
        init: function() {
            var i;
            for (i=0; i<5; i++)
                actors[i].reset();
            ghostCommander.reset();
            fruit.reset();
            energizer.reset();
            frames = 0;
        },
        draw: function() {
            newGameState.draw();
            screen.renderer.drawActors();
        },
        update: function() {
            if (frames == duration*60)
                game.switchState(playState);
            else
                frames++;
        },
    };
})();

////////////////////////////////////////////////////
// Ready New Level state
// (ready state when pausing before new level)

var readyNewState = { 

    // inherit functions from readyState
    __proto__: readyState, 

    init: function() {
        // switch to next map if given
        if (this.nextMap != undefined) {
            game.switchMap(this.nextMap);
            this.nextMap = undefined;
            tileMap.resetCurrent();
            screen.renderer.drawMap();
        }
        ghostReleaser.onNewLevel();
        elroyTimer.onNewLevel();

        // inherit attributes from readyState
        readyState.init.call(this);
    },
};

////////////////////////////////////////////////////
// Ready Restart Level state
// (ready state when pausing before restarted level)

var readyRestartState = { 

    // inherit functions from readyState
    __proto__: readyState, 

    init: function() {
        game.extraLives--;
        ghostReleaser.onRestartLevel();
        elroyTimer.onRestartLevel();

        // inherit attributes from readyState
        readyState.init.call(this);
    },
};

////////////////////////////////////////////////////
// Play state
// (state when playing the game)

var playState = {
    init: function() { },
    draw: function() {
        screen.blitMap();
        screen.renderer.drawEnergizers();
        screen.renderer.drawExtraLives();
        screen.renderer.drawLevelIcons();
        screen.renderer.drawScore();
        screen.renderer.drawFruit();
        screen.renderer.drawPaths();
        screen.renderer.drawActors();
        screen.renderer.drawTargets();
    },

    // handles collision between pac-man and ghosts
    // returns true if collision happened
    isPacmanCollide: function() {
        var i,g;
        for (i = 0; i<4; i++) {
            g = ghosts[i];
            if (g.tile.x == pacman.tile.x && g.tile.y == pacman.tile.y && g.mode == GHOST_OUTSIDE) {
                if (g.scared) { // eat ghost
                    energizer.addPoints();
                    g.onEaten();
                }
                else if (pacman.invincible) // pass through ghost
                    continue;
                else // killed by ghost
                    game.switchState(deadState);
                return true;
            }
        }
        return false;
    },
    update: function() {
        var i,j; // loop index
        var maxSteps = 2;

        // skip this frame if needed,
        // but update ghosts running home
        if (energizer.showingPoints()) {
            for (j=0; j<maxSteps; j++)
                for (i=0; i<4; i++)
                    if (ghosts[i].mode == GHOST_GOING_HOME || ghosts[i].mode == GHOST_ENTERING_HOME)
                        ghosts[i].update(j);
            energizer.updatePointsTimer();
            return;
        }
        else { // make ghosts go home immediately after points disappear
            for (i=0; i<4; i++)
                if (ghosts[i].mode == GHOST_EATEN) {
                    ghosts[i].mode = GHOST_GOING_HOME;
                    ghosts[i].targetting = 'door';
                }
        }

        // update counters
        ghostReleaser.update();
        ghostCommander.update();
        elroyTimer.update();
        fruit.update();
        energizer.update();

        // update actors one step at a time
        for (j=0; j<maxSteps; j++) {

            // advance pacman
            pacman.update(j);

            // test collision with fruit
            fruit.testCollide();

            // finish level if all dots have been eaten
            if (tileMap.allDotsEaten()) {
                this.draw();
                game.switchState(finishState);
                break;
            }

            // test pacman collision before and after updating ghosts
            // (redundant to prevent pass-throughs)
            // (if collision happens, stop immediately.)
            if (this.isPacmanCollide()) break;
            for (i=0;i<4;i++) actors[i].update(j);
            if (this.isPacmanCollide()) break;
        }

        // update frame counts
        for (i=0; i<5; i++)
            actors[i].frames++;
    },
};

////////////////////////////////////////////////////
// Script state
// (a state that triggers functions at certain times)

var scriptState = {
    init: function() {
        this.frames = 0;        // frames since state began
        this.triggerFrame = 0;  // frames since last trigger

        this.drawFunc = undefined;   // current draw function
        this.updateFunc = undefined; // current update function
    },
    update: function() {

        // if trigger is found for current time,
        // call its init() function
        // and store its draw() and update() functions
        var trigger = this.triggers[this.frames];
        if (trigger) {
            if (trigger.init) trigger.init();
            this.drawFunc = trigger.draw;
            this.updateFunc = trigger.update;
            this.triggerFrame = 0;
        }

        // call the last trigger's update function
        if (this.updateFunc) 
            this.updateFunc(this.triggerFrame);

        this.frames++;
        this.triggerFrame++;
    },
    draw: function() {
        // call the last trigger's draw function
        if (this.drawFunc) 
            this.drawFunc(this.triggerFrame);
    },
};

////////////////////////////////////////////////////
// Dead state
// (state when player has lost a life)

var deadState = (function() {
    
    // this state will always have these drawn
    var commonDraw = function() {
        screen.blitMap();
        screen.renderer.drawEnergizers();
        screen.renderer.drawExtraLives();
        screen.renderer.drawLevelIcons();
        screen.renderer.drawScore();
        screen.renderer.drawFruit();
    };

    return {

        // inherit script state functions
        __proto__: scriptState,

        // script functions for each time
        triggers: {
            0: { // freeze
                update: function() {
                    var i;
                    for (i=0; i<4; i++) 
                        actors[i].frames++; // keep animating ghosts
                },
                draw: function() {
                    commonDraw();
                    screen.renderer.drawActors();
                }
            },
            60: {
                init: function() { // isolate pacman
                    commonDraw();
                    screen.renderer.drawPacman();
                },
            },
            120: {
                draw: function(t) { // shrink
                    commonDraw();
                    screen.renderer.drawDyingPacman(t/60);
                },
            },
            180: {
                draw: function(t) { // explode
                    commonDraw();
                    screen.renderer.drawExplodingPacman(t/15);
                },
            },
            195: {
                draw: function(){}, // pause
            },
            240: {
                init: function() { // leave
                    game.switchState( game.extraLives == 0 ? overState : readyRestartState);
                }
            },
        },
    };
})();

////////////////////////////////////////////////////
// Finish state
// (state when player has completed a level)

var finishState = (function(){

    // this state will always have these drawn
    var commonDraw = function() {
        screen.renderer.drawMap();
        screen.blitMap();
        screen.renderer.drawEnergizers();
        screen.renderer.drawExtraLives();
        screen.renderer.drawLevelIcons();
        screen.renderer.drawScore();
        screen.renderer.drawFruit();
        screen.renderer.drawPacman();
    };
    
    // flash the floor and draw
    var flashFloorAndDraw = function() {
        screen.renderer.toggleLevelFlash();
        commonDraw();
    };

    return {

        // inherit script state functions
        __proto__: scriptState,

        // script functions for each time
        triggers: {
            60: { init: commonDraw },
            120: { init: flashFloorAndDraw },
            135: { init: flashFloorAndDraw },
            150: { init: flashFloorAndDraw },
            165: { init: flashFloorAndDraw },
            180: { init: flashFloorAndDraw },
            195: { init: flashFloorAndDraw },
            210: { init: flashFloorAndDraw },
            225: { init: flashFloorAndDraw },
            255: { 
                init: function() {
                    game.level++;
                    game.switchState(readyNewState,60);
                    tileMap.resetCurrent();
                    screen.renderer.drawMap();
                }
            },
        },
    };
})();

////////////////////////////////////////////////////
// Game Over state
// (state when player has lost last life)

var overState = (function() {
    var frames;
    return {
        init: function() {
            screen.renderer.drawMessage("game over", "#F00");
            frames = 0;
        },
        draw: function() {},
        update: function() {
            if (frames == 120) {
                game.switchState(menuState);
            }
            else
                frames++;
        },
    };
})();
//////////////////////////////////////////////////////////////////////////////////////
// Maps

// Definitions of playable maps along with respective actor configurations

// current map
var tileMap;
var maps;

// enumerations for each map
var MAP_MENU = 0;
var MAP_PACMAN = 1;
var MAP_MSPACMAN1 = 2;
var MAP_MSPACMAN2 = 3;
var MAP_MSPACMAN3 = 4;
var MAP_MSPACMAN4 = 5;

// create maps
(function() {

    // default onLoad function for TileMaps
    // contains potentially map-specific locations
    var onLoad = function() {

        // ghost home location
        this.doorTile = {x:13, y:14};
        this.doorPixel = {
            x:(this.doorTile.x+1)*tileSize-1, 
            y:this.doorTile.y*tileSize + midTile.y
        };
        this.homeTopPixel = 17*tileSize;
        this.homeBottomPixel = 18*tileSize;

        // location of the fruit
        var fruitTile = {x:13, y:20};
        fruit.setPosition(tileSize*(1+fruitTile.x)-1, tileSize*fruitTile.y + midTile.y);

        // actor starting states

        blinky.startDirEnum = DIR_LEFT;
        blinky.startPixel = {
            x: 14*tileSize-1,
            y: 14*tileSize+midTile.y
        };
        blinky.cornerTile = {
            x: this.numCols-1-2,
            y: 0
        };
        blinky.startMode = GHOST_OUTSIDE;
        blinky.arriveHomeMode = GHOST_LEAVING_HOME;

        pinky.startDirEnum = DIR_DOWN;
        pinky.startPixel = {
            x: 14*tileSize-1,
            y: 17*tileSize+midTile.y,
        };
        pinky.cornerTile = {
            x: 2,
            y: 0
        };
        pinky.startMode = GHOST_PACING_HOME;
        pinky.arriveHomeMode = GHOST_PACING_HOME;

        inky.startDirEnum = DIR_UP;
        inky.startPixel = {
            x: 12*tileSize-1,
            y: 17*tileSize + midTile.y,
        };
        inky.cornerTile = {
            x: this.numCols-1,
            y: this.numRows - 2,
        };
        inky.startMode = GHOST_PACING_HOME;
        inky.arriveHomeMode = GHOST_PACING_HOME;

        clyde.startDirEnum = DIR_UP;
        clyde.startPixel = {
            x: 16*tileSize-1,
            y: 17*tileSize + midTile.y,
        };
        clyde.cornerTile = {
            x: 0,
            y: this.numRows-2,
        };
        clyde.startMode = GHOST_PACING_HOME;
        clyde.arriveHomeMode = GHOST_PACING_HOME;

        pacman.startDirEnum = DIR_LEFT;
        pacman.startPixel = {
            x: 14*tileSize-1,
            y: 26*tileSize + midTile.y,
        };
    };

    var onLoadPacman = function() {
        onLoad.call(this);
        game.mode = GAME_PACMAN;
    };

    var onLoadMsPacman = function() {
        onLoad.call(this);
        game.mode = GAME_MSPACMAN;
    };

    // Original Pac-Man map
    var mapPacman = new TileMap(28, 36, (
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
        "____________________________"));

    mapPacman.onLoad = onLoadPacman;
    //mapPacman.wallColor = "#2121ff"; // from original
    mapPacman.wallColor = "#47b897"; // from Pac-Man Plus
    mapPacman.pelletColor = "#ffb8ae";
    mapPacman.constrainGhostTurns = function(tile,openTiles) {
        // prevent ghost from turning up at these tiles
        if ((tile.x == 12 || tile.x == 15) && (tile.y == 14 || tile.y == 26)) {
            openTiles[DIR_UP] = false;
        }
    };

    // Ms. Pac-Man map 1

    var mapMsPacman1 = new TileMap(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "|......||..........||......|" +
        "|o||||.||.||||||||.||.||||o|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|..........................|" +
        "|||.||.|||||.||.|||||.||.|||" +
        "__|.||.|||||.||.|||||.||.|__" +
        "|||.||.|||||.||.|||||.||.|||" +
        "   .||.......||.......||.   " +
        "|||.||||| |||||||| |||||.|||" +
        "__|.||||| |||||||| |||||.|__" +
        "__|.                    .|__" +
        "__|.||||| |||--||| |||||.|__" +
        "__|.||||| |______| |||||.|__" +
        "__|.||    |______|    ||.|__" +
        "__|.|| || |______| || ||.|__" +
        "|||.|| || |||||||| || ||.|||" +
        "   .   ||          ||   .   " +
        "|||.|||||||| || ||||||||.|||" +
        "__|.|||||||| || ||||||||.|__" +
        "__|.......   ||   .......|__" +
        "__|.|||||.||||||||.|||||.|__" +
        "|||.|||||.||||||||.|||||.|||" +
        "|..........................|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|.||||.||....||....||.||||.|" +
        "|o||||.||.||||||||.||.||||o|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|..........................|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));

    mapMsPacman1.onLoad = onLoadMsPacman;
    mapMsPacman1.wallColor = "#FFB8AE";
    mapMsPacman1.pelletColor = "#dedeff";

    // Ms. Pac-Man map 2

    var mapMsPacman2 = new TileMap(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "       ||..........||       " +
        "|||||| ||.||||||||.|| ||||||" +
        "|||||| ||.||||||||.|| ||||||" +
        "|o...........||...........o|" +
        "|.|||||||.||.||.||.|||||||.|" +
        "|.|||||||.||.||.||.|||||||.|" +
        "|.||......||.||.||......||.|" +
        "|.||.|||| ||....|| ||||.||.|" +
        "|.||.|||| |||||||| ||||.||.|" +
        "|......|| |||||||| ||......|" +
        "||||||.||          ||.||||||" +
        "||||||.|| |||--||| ||.||||||" +
        "|......|| |______| ||......|" +
        "|.||||.|| |______| ||.||||.|" +
        "|.||||.   |______|   .||||.|" +
        "|...||.|| |||||||| ||.||...|" +
        "|||.||.||          ||.||.|||" +
        "__|.||.|||| |||| ||||.||.|__" +
        "__|.||.|||| |||| ||||.||.|__" +
        "__|.........||||.........|__" +
        "__|.|||||||.||||.|||||||.|__" +
        "|||.|||||||.||||.|||||||.|||" +
        "   ....||...    ...||....   " +
        "|||.||.||.||||||||.||.||.|||" +
        "|||.||.||.||||||||.||.||.|||" +
        "|o..||.......||.......||..o|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|..........................|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));

    mapMsPacman2.onLoad = onLoadMsPacman;
    mapMsPacman2.wallColor = "#47b8ff";
    mapMsPacman2.pelletColor = "#ffff00";

    // Ms. Pac-Man map 3

    var mapMsPacman3 = new TileMap(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "|.........||....||.........|" +
        "|o|||||||.||.||.||.|||||||o|" +
        "|.|||||||.||.||.||.|||||||.|" +
        "|.||.........||.........||.|" +
        "|.||.||.||||.||.||||.||.||.|" +
        "|....||.||||.||.||||.||....|" +
        "||||.||.||||.||.||||.||.||||" +
        "||||.||..............||.||||" +
        " ....|||| |||||||| ||||.... " +
        "|.|| |||| |||||||| |||| ||.|" +
        "|.||                    ||.|" +
        "|.|||| || |||--||| || ||||.|" +
        "|.|||| || |______| || ||||.|" +
        "|.     || |______| ||     .|" +
        "|.|| |||| |______| |||| ||.|" +
        "|.|| |||| |||||||| |||| ||.|" +
        "|.||                    ||.|" +
        "|.|||| ||||| || ||||| ||||.|" +
        "|.|||| ||||| || ||||| ||||.|" +
        "|......||....||....||......|" +
        "|||.||.||.||||||||.||.||.|||" +
        "|||.||.||.||||||||.||.||.|||" +
        "|o..||.......  .......||..o|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|......||....||....||......|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|......||..........||......|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));

    mapMsPacman3.onLoad = onLoadMsPacman;
    mapMsPacman3.wallColor = "#de9751";
    mapMsPacman3.pelletColor = "#ff0000";

    // Ms. Pac-Man map 4

    var mapMsPacman4 = new TileMap(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "|..........................|" +
        "|.||.||||.||||||||.||||.||.|" +
        "|o||.||||.||||||||.||||.||o|" +
        "|.||.||||.||....||.||||.||.|" +
        "|.||......||.||.||......||.|" +
        "|.||||.||.||.||.||.||.||||.|" +
        "|.||||.||.||.||.||.||.||||.|" +
        "|......||....||....||......|" +
        "|||.|||||||| || ||||||||.|||" +
        "__|.|||||||| || ||||||||.|__" +
        "__|....||          ||....|__" +
        "||| ||.|| |||--||| ||.|| |||" +
        "    ||.|| |______| ||.||    " +
        "||||||.   |______|   .||||||" +
        "||||||.|| |______| ||.||||||" +
        "    ||.|| |||||||| ||.||    " +
        "||| ||.||          ||.|| |||" +
        "__|....||||| || |||||....|__" +
        "__|.||.||||| || |||||.||.|__" +
        "__|.||....   ||   ....||.|__" +
        "__|.|||||.|| || ||.|||||.|__" +
        "|||.|||||.|| || ||.|||||.|||" +
        "|.........||    ||.........|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|.||...||..........||...||.|" +
        "|o||.|||||||.||.|||||||.||o|" +
        "|.||.|||||||.||.|||||||.||.|" +
        "|............||............|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));

    mapMsPacman4.onLoad = onLoadMsPacman;
    mapMsPacman4.wallColor = "#2121ff";
    mapMsPacman4.pelletColor = "#dedeff";

    // Menu Map

    var menuMap = new TileMap(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "                            " +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________"));

    menuMap.onLoad = function() {

        var row = 12;

        ghostCommander.reset();
        blinky.startDirEnum = DIR_LEFT;
        blinky.startPixel = {
            x: 19*tileSize,
            y: row*tileSize+midTile.y
        };
        blinky.cornerTile = {
            x: this.numCols-1-2,
            y: 0
        };
        blinky.startMode = GHOST_OUTSIDE;

        pinky.startDirEnum = DIR_LEFT;
        pinky.startPixel = {
            x: 21*tileSize,
            y: row*tileSize + midTile.y,
        };
        pinky.cornerTile = {
            x: 2,
            y: 0
        };
        pinky.startMode = GHOST_OUTSIDE;

        clyde.startDirEnum = DIR_LEFT;
        clyde.startPixel = {
            x: 25*tileSize,
            y: row*tileSize+midTile.y,
        };
        clyde.cornerTile = {
            x: 8,
            y: 14,
        };
        clyde.startMode = GHOST_OUTSIDE;

        inky.startDirEnum = DIR_LEFT;
        inky.startPixel = {
            x: 23*tileSize,
            y: row*tileSize + midTile.y,
        };
        inky.cornerTile = {
            x: this.numCols-1,
            y: this.numRows - 2,
        };
        inky.startMode = GHOST_OUTSIDE;

        pacman.startPixel = { 
            x:14*tileSize+midTile.x, 
            y:-26*tileSize+midTile.y }; // offscreen
    };
    menuMap.wallColor = "#777";
    menuMap.pelletColor = "#FFF";

    // create list of maps
    maps = [
        menuMap,
        mapPacman,
        mapMsPacman1,
        mapMsPacman2,
        mapMsPacman3,
        mapMsPacman4
    ];

})();
//////////////////////////////////////////////////////////////////////////////////////
// Entry Point

window.onload = function() {
    screen.create();
    game.restart();
};
})();
