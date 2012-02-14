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
        for (i=0;i<5;i++)
            if (actors[i].isDrawTarget)
                actors[i].drawTarget(this.ctx);
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
