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
//////////////////////////////////////////////////////////////////////////////////////
// Screen

var screen = (function() {

    // html elements
    var divContainer;
    var canvas, ctx;
    var bgCanvas, bgCtx;

    // drawing scale
    var scale = 2;

    var makeCanvas = function() {
        var c = document.createElement("canvas");
        c.width = tileMap.widthPixels*scale;
        c.height = tileMap.heightPixels*scale;
        c.getContext("2d").scale(scale,scale);
        return c;
    };

    var addControls = function() {

        // used for making html elements with unique id's
        var id = 0;

        var makeFieldSet = function(title) {
            var fieldset = document.createElement('fieldset');
            var legend = document.createElement('legend');
            legend.appendChild(document.createTextNode(title));
            fieldset.appendChild(legend);
            return fieldset;
        };

        var addCheckbox = function(fieldset, caption, onChange) {
            id++;
            var checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.id = 'check'+id;
            checkbox.onchange = function() { onChange(checkbox.checked); };
            fieldset.appendChild(checkbox);

            label = document.createElement('label');
            label.htmlFor = 'check'+id;
            label.appendChild(document.createTextNode(caption));
            fieldset.appendChild(label);

            fieldset.appendChild(document.createElement('br'));
        };


        var addRadio = function(fieldset, group, caption, onChange,on) {
            id++;
            var radio = document.createElement('input');
            radio.type = 'radio';
            radio.name = group;
            radio.id = 'radio'+id;
            radio.checked = on;
            radio.onchange = function() { onChange(radio.checked); };
            fieldset.appendChild(radio);

            label = document.createElement('label');
            label.htmlFor = 'radio'+id;
            label.appendChild(document.createTextNode(caption));
            fieldset.appendChild(label);

            fieldset.appendChild(document.createElement('br'));
        };


        var form = document.createElement('form');
        form.style.width = 200;
        form.style.cssFloat = "left";

        var fieldset;

        ///////////////////////////////////////////////////
        // options
        fieldset = makeFieldSet('Options');
        addCheckbox(fieldset, 'autoplay', function(on) { pacman.ai = on; });
        addCheckbox(fieldset, 'invincible', function(on) { pacman.invincible = on; });
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // renderers
        fieldset = makeFieldSet('Renderer');
        addRadio(fieldset, 'render', 'minimal', function(on) { if (on) screen.switchRenderer(0); },true);
        addRadio(fieldset, 'render', 'arcade (w.i.p.)', function(on) { if (on) screen.switchRenderer(1); });
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // maps
        fieldset = makeFieldSet('Maps');
        addRadio(fieldset, 'map', 'Pac-Man', function(on) { game.switchMap(0);},true);
        addRadio(fieldset, 'map', 'Ms. Pac-Man 1', function(on) { game.switchMap(1); });
        addRadio(fieldset, 'map', 'Ms. Pac-Man 2', function(on) { game.switchMap(2); });
        addRadio(fieldset, 'map', 'Ms. Pac-Man 3', function(on) { game.switchMap(3); });
        addRadio(fieldset, 'map', 'Ms. Pac-Man 4', function(on) { game.switchMap(4); });
        form.appendChild(fieldset);

        divContainer.appendChild(form);

        var br = document.createElement('br');
        br.style.clear = "both";
        divContainer.appendChild(br);
    };

    var addInput = function() {
        // handle key press event
        document.onkeydown = function(e) {
            var key = (e||window.event).keyCode;
            switch (key) {
                case 37: pacman.setNextDir(DIR_LEFT); break; // left
                case 38: pacman.setNextDir(DIR_UP); break; // up
                case 39: pacman.setNextDir(DIR_RIGHT); break; // right
                case 40: pacman.setNextDir(DIR_DOWN); break;// down
                default: return;
            }
            e.preventDefault();
        };
    };

    return {
        create: function() {
            canvas = makeCanvas();
            bgCanvas = makeCanvas();
            ctx = canvas.getContext("2d");
            bgCtx = bgCanvas.getContext("2d");
            canvas.style.cssFloat = "left";

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
            this.renderer = this.renderers[0];
        },
        switchRenderer: function(i) {
            this.renderer = this.renderers[i];
            this.renderer.drawMap();
        },

        blitMap: function() {
            ctx.scale(1/scale,1/scale);
            ctx.drawImage(bgCanvas,0,0);
            ctx.scale(scale,scale);
        },
    };
})();

//////////////////////////////////////////////////////////////////////////////////////
// The actor class defines common data functions for the ghosts and pacman
// It provides everything for updating position and direction.

// "Ghost" and "Player" inherit from this "Actor"

// DEPENDENCIES:
// direction utility
// tileMap.teleport()
// tileMap.isTunnelTile()
// tileMap.getSurroundingTiles()

// Actor constructor
var Actor = function() {

    this.dir = {};
    this.pixel = {};
    this.tile = {};
    this.tilePixel = {};
    this.distToMid = {};

    this.targetTile = {};

    // current frame count
    this.frame = 0;        // frame count
};

// reset to initial position and direction
Actor.prototype.reset = function() {
    this.setDir(this.startDirEnum);
    this.setPos(this.startPixel.x, this.startPixel.y);
    this.frame = 0;
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

    return function(level, pattern, frame) {
        var entry;
        if (level < 1) return;
        else if (level==1)                  entry = 0;
        else if (level >= 2 && level <= 4)  entry = 1;
        else if (level >= 5 && level <= 20) entry = 2;
        else if (level >= 21)               entry = 3;
        return stepSizes[entry*7*16 + pattern*16 + frame%16];
    };
})();


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

// retrieve four surrounding tiles and indicate whether they are open
Actor.prototype.getOpenSurroundTiles = function() {

    // get open passages
    var surroundTiles = tileMap.getSurroundingTiles(this.tile);
    var openTiles = {};
    var numOpenTiles = 0;
    var oppDirEnum = (this.dirEnum+2)%4; // current opposite direction enum
    var i;
    for (i=0; i<4; i++)
        if (openTiles[i] = tileMap.isFloorTileChar(surroundTiles[i]))
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
        console.log(this.name,'got stuck');
        return;
    }

    return openTiles;
};

Actor.prototype.getTurnClosestToTarget = function(openTiles) {

    var dx,dy,dist;                      // variables used for euclidean distance
    var minDist = Infinity;              // variable used for finding minimum distance path
    var dir = {};
    var dirEnum = 0;
    var i;
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
    return dirEnum;
};
//////////////////////////////////////////////////////////////////////////////////////
// Ghost class

// DEPENDENCIES:
// 1. tileMap
// 2. game

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

// gets the number of steps to move in this frame
Ghost.prototype.getNumSteps = function(frame) {

    var pattern = STEP_GHOST;

    if (this.mode == GHOST_GOING_HOME || this.mode == GHOST_ENTERING_HOME)
        return 2;
    else if (this.mode == GHOST_LEAVING_HOME || this.mode == GHOST_PACING_HOME || tileMap.isTunnelTile(this.tile.x, this.tile.y))
        pattern = STEP_GHOST_TUNNEL;
    else if (this.scared)
        pattern = STEP_GHOST_FRIGHT;
    else if (this.elroy == 1)
        pattern = STEP_ELROY1;
    else if (this.elroy == 2)
        pattern = STEP_ELROY2;

    return this.getStepSizeFromTable(game.level, pattern, frame);
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
    if (this.mode != GHOST_GOING_HOME && this.mode != GHOST_ENTERING_HOME)
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

// ghost home-specific path steering
Ghost.prototype.homeSteer = (function(){

    // steering functions to execute for each mode
    var steerFuncs = {};

    steerFuncs[GHOST_EATEN] = function() {
        this.mode = GHOST_GOING_HOME;
    };

    steerFuncs[GHOST_GOING_HOME] = function() {
        // at the doormat
        if (this.tile.x == tileMap.doorTile.x && this.tile.y == tileMap.doorTile.y)
            // walk to the door, or go through if already there
            if (this.pixel.x == tileMap.doorPixel.x) {
                this.mode = GHOST_ENTERING_HOME;
                this.setDir(DIR_DOWN);
            }
            else
                this.setDir(DIR_RIGHT);
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


// determine direction
Ghost.prototype.steer = function() {

    var i;                               // loop counter
    var dirEnum;                         // final direction to update to
    var openTiles;                       // list of four booleans indicating which surrounding tiles are open
    var oppDirEnum = (this.dirEnum+2)%4; // current opposite direction enum

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
    if (this.mode != GHOST_OUTSIDE && this.mode != GHOST_GOING_HOME)
        return;

    // don't steer if we're not at the middle of the tile
    if (this.distToMid.x != 0 || this.distToMid.y != 0)
        return;

    // get surrounding tiles and their open indication
    openTiles = this.getOpenSurroundTiles();

    // random turn if scared
    if (this.scared || (ghostCommander.getCommand() == GHOST_CMD_SCATTER && this.randomScatter)) {
        dirEnum = Math.floor(Math.random()*5);
        while (!openTiles[dirEnum])
            dirEnum = (dirEnum+1)%4;
    }
    else {
        // target ghost door
        if (this.mode == GHOST_GOING_HOME) {
            this.targetTile.x = tileMap.doorTile.x;
            this.targetTile.y = tileMap.doorTile.y;
        }
        // target corner when patrolling
        else if (!this.elroy && ghostCommander.getCommand() == GHOST_CMD_SCATTER) {
            this.targetTile.x = this.cornerTile.x;
            this.targetTile.y = this.cornerTile.y;
        }
        // use custom function for each ghost when in attack mode
        else
            this.setTarget();

        // edit openTiles to reflect the current map's special contraints
        if (tileMap.constrainGhostTurns)
            tileMap.constrainGhostTurns(this.tile.x, this.tile.y, openTiles);

        // choose direction that minimizes distance to target
        dirEnum = this.getTurnClosestToTarget(openTiles);
    }

    // commit the direction
    this.setDir(dirEnum);
};
//////////////////////////////////////////////////////////////////////////////////////
// Player is the controllable character (Pac-Man)


// DEPENDENCIES:
// 1. energizer
// 2. playEvents
// 3. game

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

    energizer.reset();
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
Player.prototype.getNumSteps = function(frame) {
    var pattern = energizer.isActive() ? STEP_PACMAN_FRIGHT : STEP_PACMAN;
    return this.getStepSizeFromTable(game.level, pattern, frame);
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
    };
})();

// determine direction
Player.prototype.steer = function() {

    // if AI-controlled, only turn at mid-tile
    if (this.ai) {
        if (this.distToMid.x != 0 || this.distToMid.y != 0)
            return;

        // make turn that is closest to target
        var openTiles = this.getOpenSurroundTiles();
        this.setTarget();
        this.setNextDir(this.getTurnClosestToTarget(openTiles));
    }

    // head in the desired direction if possible
    if (tileMap.isNextTileFloor(this.tile, this.nextDir))
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
    energizer.update();

    // call super function to update position and direction
    Actor.prototype.update.apply(this);

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

var pinky = new Ghost();
pinky.name = "pinky";
pinky.color = "#FFB8FF";

var inky = new Ghost();
inky.name = "inky";
inky.color = "#00FFFF";

var clyde = new Ghost();
clyde.name = "clyde";
clyde.color = "#FFB851";

var pacman = new Player();
pacman.name = "pacman";
pacman.color = "#FFFF00";

// order at which they appear in original arcade memory
// (suggests drawing/update order)
var actors = [blinky, pinky, inky, clyde, pacman];

// targetting schemes

blinky.setTarget = function() {
    // directly target pacman
    this.targetTile.x = pacman.tile.x;
    this.targetTile.y = pacman.tile.y;
};
pinky.setTarget = function() {
    // target four tiles ahead of pacman
    this.targetTile.x = pacman.tile.x + 4*pacman.dir.x;
    this.targetTile.y = pacman.tile.y + 4*pacman.dir.y;
};
inky.setTarget = function() {
    // target twice the distance from blinky to two tiles ahead of pacman
    var px = pacman.tile.x + 2*pacman.dir.x;
    var py = pacman.tile.y + 2*pacman.dir.y;
    this.targetTile.x = blinky.tile.x + 2*(px - blinky.tile.x);
    this.targetTile.y = blinky.tile.y + 2*(py - blinky.tile.y);
};
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
pacman.setTarget = function() {
    // target twice the distance from pinky to pacman or target pinky
    if (blinky.mode == GHOST_GOING_HOME || blinky.scared) {
        this.targetTile.x = pinky.tile.x;
        this.targetTile.y = pinky.tile.y;
    }
    else {
        this.targetTile.x = pinky.tile.x + 2*(pacman.tile.x-pinky.tile.x);
        this.targetTile.y = pinky.tile.y + 2*(pacman.tile.y-pinky.tile.y);
    }
};
//////////////////////////////////////////////////////////////////////////////////////
// Ghost Commander

// Determines when a ghost should be chasing a target

var ghostCommander = (function() {

    // get new ghost command from frame count
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

    var count;   // current frame
    var command; // last command given to ghosts

    return {
        reset: function() { 
            command = GHOST_CMD_SCATTER;
            count = 0;
        },
        update: function() {
            var newCmd;
            if (!energizer.isActive()) {
                newCmd = getNewCommand(count);
                if (newCmd != undefined) {
                    command = newCmd;
                    for (i=0; i<4; i++)
                        actors[i].reverse();
                }
                count++;
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

    var PINKY = 1;
    var INKY = 2;
    var CLYDE = 3;

    // this is how many frames it will take to release a ghost after pacman stops eating
    var getTimeoutLimit = function() {
        return (game.level < 5) ? 4*60 : 3*60;
    };

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

    var mode;
    var framesSinceLastDot;
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
                    if (actors[i].mode == GHOST_PACING_HOME) {
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
                    g = actors[i];
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
                    g = actors[i];
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

// handle how long the energizer lasts
// handle how long the points will display after eating a ghost

var energizer = (function() {

    // how many seconds to display points when ghost is eaten
    var pointsDuration = 1;

    // how long to stay energized
    var getDuration = (function(){
        var seconds = [6,5,4,3,2,5,2,2,1,5,2,1,1,3,1,1,0,1];
        return function() {
            var i = game.level;
            return (i > 18) ? 0 : 60*seconds[i-1];
        };
    })();

    // how many ghost flashes happen near the end of frightened mode
    var getFlashes = (function(){
        var flashes = [5,5,5,5,5,5,5,5,3,5,5,3,3,5,3,3,0,3];
        return function() {
            var i = game.level;
            return (i > 18) ? 0 : flashes[i-1];
        };
    })();

    // "The ghosts change colors every 14 game cycles when they start 'flashing'" -Jamey Pittman
    var flashInterval = 14;

    var count;  // how many frames energizer has been active
    var active; // is energizer active
    var points; // points that the last eaten ghost was worth
    var pointsFramesLeft; // number of frames left to display points earned from eating ghost

    return {
        reset: function() {
            count = 0;
            active = false;
            points = 100;
            pointsFramesLeft = 0;
            for (i=0; i<4; i++)
                actors[i].scared = false;
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
            for (i=0; i<4; i++) 
                actors[i].onEnergized();
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

    // get number of points a fruit is worth at current level

    var dotLimit1 = 70; // first fruit will appear when this number of dots are eaten
    var dotLimit2 = 170; // second fruit will appear when this number of dots are eaten

    var duration = 9; // number of seconds that the fruit is on the screen
    var scoreDuration = 2; // number of seconds that the fruit score is on the screen

    var framesLeft; // frames left until fruit is off the screen
    var scoreFramesLeft; // frames left until the picked-up fruit score is off the screen

    return {
        pixel: {x:0, y:0},
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
        setPosition: function(px,py) {
            this.pixel.x = px;
            this.pixel.y = py;
        },
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

var game = (function(){

    var interval; // used by setInterval and clearInterval to execute the game loop
    var framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)

    return {
        highScore:0,
        restart: function() {
            this.switchState(startupState);
            this.resume();
        },
        pause: function() {
            clearInterval(interval);
        },
        resume: function() {
            interval = setInterval("game.tick()", framePeriod);
        },
        switchMap: function(i) {
            // just restart the map I guess?
            tileMap = maps[i];
            tileMap.onLoad();
            this.switchState(newGameState);
        },
        switchState: function(s) {
            s.init();
            this.state = s;
        },
        addScore: function(p) {
            this.score += p;
            if (this.score > this.highScore)
                this.highScore = this.score;
            if (this.score == 10000)
                this.extraLives++;
        },
        tick: (function(){
            var nextFrameTime = (new Date).getTime();
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
    };
})();
//////////////////////////////////////////////////////////////////////////////////////
// States

var startupState = {
    init: function() {
        tileMap.onLoad();
        screen.renderer.drawMap();
        screen.blitMap();
        screen.renderer.drawEnergizers();
        screen.renderer.drawMessage("start","#FFF");
        clickState.nextState = newGameState;
        game.switchState(clickState);
    },
    draw: function(){},
    update: function(){},
};

////////////////////////////////////////////////////

// state when waiting for the user to click
var clickState = {
    init: function() {
        var that = this;
        screen.onClick = function() {
            game.switchState(that.nextState);
            screen.onClick = undefined;
        }
    },
    draw: function(){},
    update: function(){},
};

////////////////////////////////////////////////////

// state when first starting the game
var newGameState = (function() {
    var frames;
    var duration = 2;

    return {
        init: function() {
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

// common ready state when about to play
var readyState =  (function(){
    var frames;
    var duration = 2;
    
    return {
        init: function() {
            var i;
            for (i=0; i<5; i++)
                actors[i].reset();
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

// ready state for new level
var readyNewState = { 
    __proto__: readyState, 
    init: function() {
        ghostCommander.reset();
        ghostReleaser.onNewLevel();
        fruit.reset();
        elroyTimer.onNewLevel();
        readyState.init.call(this);
    },
};

////////////////////////////////////////////////////

// ready state for restarting level
var readyRestartState = { 
    __proto__: readyState, 
    init: function() {
        game.extraLives--;
        ghostCommander.reset();
        ghostReleaser.onRestartLevel();
        fruit.reset();
        elroyTimer.onRestartLevel();
        readyState.init.call(this);
    },
};

////////////////////////////////////////////////////

// state when playing the game
var playState = {
    init: function() { },
    draw: function() {
        screen.blitMap();
        screen.renderer.drawEnergizers();
        screen.renderer.drawExtraLives();
        screen.renderer.drawLevelIcons();
        screen.renderer.drawScore();
        screen.renderer.drawFruit();
        screen.renderer.drawActors();
    },
    update: function() {
        var i; // loop index
        var g; // loop ghost

        // skip this frame if needed,
        // but update ghosts running home
        if (energizer.showingPoints()) {
            for (i=0; i<4; i++)
                if (actors[i].mode == GHOST_GOING_HOME || actors[i].mode == GHOST_ENTERING_HOME)
                    actors[i].update();
            energizer.updatePointsTimer();
            return;
        }

        // update counters
        ghostReleaser.update();
        ghostCommander.update();
        elroyTimer.update();
        fruit.update();

        // update actors
        for (i = 0; i<5; i++)
            actors[i].update();

        // test collision with fruit
        fruit.testCollide();

        // finish level if all dots have been eaten
        if (tileMap.allDotsEaten()) {
            this.draw();
            game.switchState(finishState);
            return;
        }

        // test pacman collision with each ghost
        for (i = 0; i<4; i++) {
            g = actors[i];
            if (g.tile.x == pacman.tile.x && g.tile.y == pacman.tile.y) {
                if (g.mode == GHOST_OUTSIDE) {
                    // somebody is going to die
                    if (!g.scared) {
                        if (!pacman.invincible)
                            game.switchState(deadState);
                    }
                    else if (energizer.isActive()) {
                        energizer.addPoints();
                        g.onEaten();
                    }
                    break;
                }
            }
        }
    },
};

////////////////////////////////////////////////////

// state when playing the game
var scriptState = {
    init: function() {
        this.frames = 0;
        this.triggerFrame = 0;

        this.drawFunc = undefined;
        this.updateFunc = undefined;
    },
    update: function() {
        var trigger = this.triggers[this.frames];
        if (trigger) {
            if (trigger.init) trigger.init();
            this.drawFunc = trigger.draw;
            this.updateFunc = trigger.update;
            this.triggerFrame = 0;
        }

        if (this.updateFunc) 
            this.updateFunc(this.triggerFrame);

        this.frames++;
        this.triggerFrame++;
    },
    draw: function() {
        if (this.drawFunc) 
            this.drawFunc(this.triggerFrame);
    },
};

////////////////////////////////////////////////////

// state when dying
var deadState = (function() {
    
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

        // freeze for a moment, then shrink and explode
        triggers: {
            60: {
                init: function() { // freeze
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

var finishState = (function(){

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
    
    var flashFloor = function() {
        screen.renderer.toggleLevelFlash();
        commonDraw();
    };

    return {
        __proto__: scriptState,
        triggers: {
            60: { init: commonDraw },
            120: { init: flashFloor },
            135: { init: flashFloor },
            150: { init: flashFloor },
            165: { init: flashFloor },
            180: { init: flashFloor },
            195: { init: flashFloor },
            210: { init: flashFloor },
            225: { init: flashFloor },
            255: { 
                init: function() {
                    game.level++;
                    game.switchState(readyNewState);
                    tileMap.resetCurrent();
                    screen.renderer.drawMap();
                }
            },
        },
    };
})();

////////////////////////////////////////////////////

// display game over
var overState = {
    init: function() {
        screen.renderer.drawMessage("game over", "#F00");
        clickState.nextState = newGameState;
        game.switchState(clickState);
    },
    draw: function() {},
    update: function() {},
};

//////////////////////////////////////////////////////////////////////////////////////
// maps

// available maps
var maps;

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
            x: tileSize*this.numCols/2,
            y: 26*tileSize + midTile.y,
        };
    };


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

    mapPacman.onLoad = onLoad;
    mapPacman.color = "#00C";
    mapPacman.constrainGhostTurns = function(x,y,openTiles) {
        // prevent ghost from turning up at these tiles
        if ((x == 12 || x == 15) && (y == 14 || y == 26)) {
            openTiles[DIR_UP] = false;
        }
    };

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

    mapMsPacman1.onLoad = onLoad;
    mapMsPacman1.color = "#FFB8AE";

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

    mapMsPacman2.onLoad = onLoad;
    mapMsPacman2.color = "#47b8ff";

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
        "|......||.   ||   .||......|" +
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

    mapMsPacman3.onLoad = onLoad;
    mapMsPacman3.color = "#de9751";

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

    mapMsPacman4.onLoad = onLoad;
    mapMsPacman4.color = "#2121ff";

    // create global list of maps
    maps = [
        mapPacman,
        mapMsPacman1,
        mapMsPacman2,
        mapMsPacman3,
        mapMsPacman4,
    ];


})();

// current map defaults to first
var tileMap = maps[0];
//////////////////////////////////////////////////////////////////////////////////////
// Pac-Man
// Thanks to Jamey Pittman for "The Pac-Man Dossier"

//////////////////////////////////////////////////////////////////////////////////////
window.onload = function() {
    screen.create();
    game.restart();
};
