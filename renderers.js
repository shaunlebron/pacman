
var renderers = {};

//////////////////////////////////////////////////////////////
// Common Renderer

renderers.Common = function(ctx, bgCtx) {
    this.ctx = ctx;
    this.bgCtx = bgCtx;

    this.actorSize = (tileSize-1)*2;
    this.energizerSize = tileSize+2;
    this.pointsEarnedTextSize = tileSize;

    this.energizerColor = "#FFF";
    this.pelletColor = "#888";

    this.flashLevel = false;
};

renderers.Common.prototype = {

    // draw square centered at the given tile
    drawCenterTileSq: function (ctx,tx,ty,w) {
        this.drawCenterPixelSq(ctx, tx*tileSize+midTile.x, ty*tileSize+midTile.y,w);
    },

    // draw square centered at the given pixel
    drawCenterPixelSq: function (ctx,px,py,w) {
        ctx.fillRect(px-w/2, py-w/2,w,w);
    },

    toggleLevelFlash: function () {
        this.flashLevel = !this.flashLevel;
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

    // erase pellet from background
    erasePellet: function(x,y) {
        this.bgCtx.fillStyle = this.floorColor;
        this.drawCenterTileSq(this.bgCtx,x,y,tileSize);
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
                this.drawGhost(actors[i]);
            if (!energizer.showingPoints())
                this.drawPacman();
            else
                this.drawEatenPoints();
        }
        // draw such that pacman appears on bottom
        else {
            this.drawPacman();
            for (i=3; i>=0; i--) 
                this.drawGhost(actors[i]);
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
            color = energizer.isFlash() ? "#FFF" : "#00F";
        else if (g.mode == GHOST_GOING_HOME || g.mode == GHOST_ENTERING_HOME)
            color = "rgba(255,255,255,0.2)";
        this.ctx.fillStyle = color;
        this.drawCenterPixelSq(this.ctx, g.pixel.x, g.pixel.y, this.actorSize);
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

renderers.Simple = function(ctx,bgCtx) {

    renderers.Common.call(this,ctx,bgCtx);

    this.messageRow = 21.7;
    this.pointsEarnedTextSize = 1.5*tileSize;

    this.backColor = "#222";
    this.floorColor = "#444";
    this.flashFloorColor = "#999";
};

renderers.Simple.prototype = {
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
                this.drawCenterTileSq(this.bgCtx,x,y,tileSize);
        }

        // draw pellet tiles
        this.bgCtx.fillStyle = this.pelletColor;
        i=0;
        for (y=0; y<tileMap.numRows; y++)
        for (x=0; x<tileMap.numCols; x++) {
            tile = tileMap.currentTiles[i++];
            if (tile == '.')
                this.drawCenterTileSq(this.bgCtx,x,y,tileSize);
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

};


//////////////////////////////////////////////////////////////
// Arcade Renderer

renderers.Arcade = function(ctx,bgCtx) {
    renderers.Common.call(this,ctx,bgCtx);

    this.messageRow = 20;
    this.pelletSize = midTile.x;
    this.energizerSize = tileSize;

    this.backColor = "#000";
    this.floorColor = "#000";
    this.flashWallColor = "#FFF";
};

renderers.Arcade.prototype = {
    __proto__: renderers.Common.prototype,

    drawMap: function() {

        // fill background
        this.bgCtx.fillStyle = this.backColor;
        this.bgCtx.fillRect(0,0,tileMap.widthPixels, tileMap.heightPixels);

        var x,y;
        var i;
        var tile;

        // draw wall tiles
        this.bgCtx.fillStyle = (this.flashLevel ? this.flashWallColor : tileMap.color);
        i=0;
        for (y=0; y<tileMap.numRows; y++)
        for (x=0; x<tileMap.numCols; x++) {
            tile = tileMap.currentTiles[i++];
            if (tile == '|')
                this.drawCenterTileSq(this.bgCtx,x,y,tileSize);
        }

        // draw floor tiles
        this.bgCtx.fillStyle = this.floorColor;
        i=0;
        for (y=0; y<tileMap.numRows; y++)
        for (x=0; x<tileMap.numCols; x++) {
            tile = tileMap.currentTiles[i++];
            if (tile == '_')
                this.drawCenterTileSq(this.bgCtx,x,y,tileSize);
            else if (tile != '|')
                this.drawCenterTileSq(this.bgCtx,x,y,this.actorSize+4);
        }

        // draw pellet tiles
        this.bgCtx.fillStyle = this.pelletColor;
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
        this.ctx.fillText("high score", tileSize*tileMap.numCols/2, 3);
        this.ctx.fillText(game.highScore, tileSize*tileMap.numCols/2, tileSize*1.5);
    },

    // draw the extra lives indicator
    drawExtraLives: function() {
        var i;
        this.ctx.fillStyle = "rgba(255,255,0,0.6)";
        for (i=0; i<game.extraLives; i++)
            this.drawCenterPixelSq(this.ctx, (2*i+3)*tileSize, (tileMap.numRows-1)*tileSize,this.actorSize);
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

};
