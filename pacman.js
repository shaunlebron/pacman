
// PAC-MAN
// an accurate remake of the original arcade game

// original by Namco
// research from 'The Pacman Dossier' compiled by Jamey Pittman
// remake by Shaun Williams

// Project Page: http://github.com/shaunew/Pac-Man

(function(){

//@line 1 "src/input.js"

var pressLeft = function() {
    pacman.setNextDir(DIR_LEFT);
};

var pressRight = function() {
    pacman.setNextDir(DIR_RIGHT);
};

var pressDown = function() {
    pacman.setNextDir(DIR_DOWN);
    if (vcr.getMode() != VCR_RECORD) {
        vcr.nextSpeed(-1);
    }
};

var pressUp = function() {
    pacman.setNextDir(DIR_UP);
    if (vcr.getMode() != VCR_RECORD) {
        vcr.nextSpeed(1);
    }
};

document.onkeydown = function(e) {
    var key = (e||window.event).keyCode;
    switch (key) {

        // LEFT
        case 37: pressLeft(); break;

        // RIGHT
        case 39: pressRight(); break;

        // UP
        case 38: pressUp(); break;

        // DOWN
        case 40: pressDown(); break;

        // SHIFT
        case 16:
            if (vcr.getMode() == VCR_RECORD) {
                vcr.startSeeking();
            }
            break;
        default: return;

        // CTRL
        case 17: executive.setUpdatesPerSecond(30); break;

        // ALT
        case 18: executive.setUpdatesPerSecond(15); break;
    }
    // prevent default action for arrow keys
    // (don't scroll page with arrow keys)
    e.preventDefault();
};

document.onkeyup = function(e) {
    var key = (e||window.event).keyCode;
    switch (key) {

        // spacebar
        case 32: executive.togglePause(); break;

            break;
        // SHIFT
        case 16:
            vcr.startRecording();
            break;

        // CTRL or ALT
        case 17:
        case 18: executive.setUpdatesPerSecond(60); break;

        // n (next level)
        case 78:
            if (state != homeState) {
                //map.skipSignal = true;
                switchState(readyNewState,60);
            }
            break;

        // q
        case 81: blinky.isDrawTarget = !blinky.isDrawTarget; break;
        // w
        case 87: pinky.isDrawTarget = !pinky.isDrawTarget; break;
        // e
        case 69: inky.isDrawTarget = !inky.isDrawTarget; break;
        // r
        case 82: clyde.isDrawTarget = !clyde.isDrawTarget; break;
        // t 
        case 84: pacman.isDrawTarget = !pacman.isDrawTarget; break;

        // a
        case 65: blinky.isDrawPath = !blinky.isDrawPath; break;
        // s
        case 83: pinky.isDrawPath = !pinky.isDrawPath; break;
        // d
        case 68: inky.isDrawPath = !inky.isDrawPath; break;
        // f
        case 70: clyde.isDrawPath = !clyde.isDrawPath; break;
        // g
        case 71: pacman.isDrawPath = !pacman.isDrawPath; break;

        // i (invincible)
        case 73: pacman.invincible = !pacman.invincible; break;

        // o (turbO)
        case 79: pacman.doubleSpeed = !pacman.doubleSpeed; break;

        // p (auto-Play)
        case 80: pacman.ai = !pacman.ai; break;

        default: return;
    }
    e.preventDefault();
};

var initSwipe = function() {

    // position of anchor
    var x = 0;
    var y = 0;

    // current distance from anchor
    var dx = 0;
    var dy = 0;

    // minimum distance from anchor before direction is registered
    var r = tileSize;
    
    var touchStart = function(event) {
        var fingerCount = event.touches.length;
        if (fingerCount == 1) {

            // commit new anchor
            x = event.touches[0].pageX;
            y = event.touches[0].pageY;

        }
        else {
            touchCancel(event);
        }
    };

    var touchMove = function(event) {
        var fingerCount = event.touches.length;
        if (fingerCount == 1) {

            // get current distance from anchor
            dx = event.touches[0].pageX - x;
            dy = event.touches[0].pageY - y;

            // if minimum move distance is reached
            if (dx*dx+dy*dy >= r*r) {

                // commit new anchor
                x += dx;
                y += dy;

                // register direction
                if (Math.abs(dx) >= Math.abs(dy)) {
                    (dx > 0) ? pressRight() : pressLeft();
                }
                else {
                    (dy > 0) ? pressDown() : pressUp();
                }
            }
        }
        else {
            touchCancel(event);
        }
    };

    var touchEnd = function(event) {
    };

    var touchCancel = function(event) {
        x=y=dx=dy=0;
    };
    
    // register touch events
    document.ontouchstart = touchStart;
    document.ontouchend = touchEnd;
    document.ontouchmove = touchMove;
    document.ontouchcancel = touchCancel;
};
//@line 1 "src/game.js"
//////////////////////////////////////////////////////////////////////////////////////
// Game

// game modes
var GAME_PACMAN = 0;
var GAME_MSPACMAN = 1;
var GAME_COOKIE = 2;

var practiceMode = false;

// current game mode
var gameMode = GAME_PACMAN;

// current level, lives, and score
var level = 1;
var extraLives = 0;
var highScore = 0;
var score = 0;

var savedLevel = {};
var savedExtraLives = {};
var savedHighScore = {};
var savedScore = {};
var savedState = {};

var saveGame = function(t) {
    savedLevel[t] = level;
    savedExtraLives[t] = extraLives;
    savedHighScore[t] = highScore;
    savedScore[t] = score;
    savedState[t] = state;
};

var loadGame = function(t) {
    level = savedLevel[t];
    if (extraLives != savedExtraLives[t]) {
        extraLives = savedExtraLives[t];
        renderer.drawMap();
    }
    highScore = savedHighScore[t];
    score = savedScore[t];
    state = savedState[t];
};

// TODO: have a high score for each game type

var addScore = function(p) {
    if (score < 10000 && score+p >= 10000) {
        extraLives++;
        renderer.drawMap();
    }
    score += p;
    if (score > highScore)
        highScore = score;
};
//@line 1 "src/vcr.js"
//////////////////////////////////////////////////////////////////////////////////////
// VCR
// This coordinates the recording, rewinding, and replaying of the game state.
// Inspired by Braid.

var VCR_RECORD = 0;
var VCR_REWIND = 1;
var VCR_FORWARD = 2;
var VCR_PAUSE = 3;

var vcr = (function() {

    var mode;

    // controls whether to increment the frame before recording.
    var initialized;

    // current time
    var time;

    // tracking speed
    var speedIndex;
    var speeds = [-8,-4,-2,-1,0,1,2,4,8];
    var speedColors = [
        "rgba(255,255,0,0.25)",
        "rgba(255,255,0,0.20)",
        "rgba(255,255,0,0.15)",
        "rgba(255,255,0,0.10)",
        "rgba(0,0,0,0)",
        "rgba(0,0,255,0.10)",
        "rgba(0,0,255,0.15)",
        "rgba(0,0,255,0.20)",
        "rgba(0,0,255,0.25)",
    ];

    // current frame associated with current time
    // (frame == time % maxFrames)
    var frame;

    // maximum number of frames to record
    var maxFrames = 15*60;

    // rolling bounds of the recorded frames
    var startFrame; // can't rewind past this
    var stopFrame; // can't replay past this

    // reset the VCR
    var reset = function() {
        time = 0;
        frame = 0;
        startFrame = 0;
        stopFrame = 0;
        states = {};
        startRecording();
    };

    // load the state of the current time
    var load = function() {
        var i;
        for (i=0; i<5; i++) {
            actors[i].load(frame);
        }
        elroyTimer.load(frame);
        energizer.load(frame);
        fruit.load(frame);
        ghostCommander.load(frame);
        ghostReleaser.load(frame);
        map.load(frame,time);
        loadGame(frame);
        if (state == deadState) {
            deadState.load(frame);
        }
        else if (state == finishState) {
            finishState.load(frame);
        }
    };

    // save the state of the current time
    var save = function() {
        var i;
        for (i=0; i<5; i++) {
            actors[i].save(frame);
        }
        elroyTimer.save(frame);
        energizer.save(frame);
        fruit.save(frame);
        ghostCommander.save(frame);
        ghostReleaser.save(frame);
        map.save(frame);
        saveGame(frame);
        if (state == deadState) {
            deadState.save(frame);
        }
        else if (state == finishState) {
            finishState.save(frame);
        }
    };

    // erase any states after the current time
    // (only necessary for saves that do interpolation)
    var eraseFuture = function() {
        map.eraseFuture(time);
        stopFrame = frame;
    };

    // increment or decrement the time
    var addTime = function(dt) {
        time += dt;
        frame = (frame+dt)%maxFrames;
        if (frame < 0) {
            frame += maxFrames;
        }
    };

    // measures the modular distance if increasing from x0 to x1 on our circular frame buffer.
    var getForwardDist = function(x0,x1) {
        return (x0 <= x1) ? x1-x0 : x1+maxFrames-x0;
    };

    // caps the time increment or decrement to prevent going over our rolling bounds.
    var capSeekTime = function(dt) {
        if (!initialized || dt == 0) {
            return 0;
        }
        var maxForward = getForwardDist(frame,stopFrame);
        var maxReverse = getForwardDist(startFrame,frame);
        return (dt > 0) ? Math.min(maxForward,dt) : Math.max(-maxReverse,dt);
    };

    // seek to the state at the given relative time difference.
    var seek = function(dt) {
        if (dt == undefined) {
            dt = speeds[speedIndex];
        }
        if (initialized) {
            addTime(capSeekTime(dt));
            load();
        }
    };

    // record a new state.
    var record = function() {
        if (initialized) {
            addTime(1);
            if (frame == startFrame) {
                startFrame = (startFrame+1)%maxFrames;
            }
            stopFrame = frame;
        }
        else {
            initialized = true;
        }
        save();
    };

    var startRecording = function() {
        mode = VCR_RECORD;
        initialized = false;
        eraseFuture();
    };

    var startSeeking = function() {
        speedIndex = 3;
        updateMode();
    };

    var nextSpeed = function(di) {
        if (speeds[speedIndex+di] != undefined) {
            speedIndex = speedIndex+di;
        }
        updateMode();
    };

    var renderHud = function(ctx) {
        if (vcr.getMode() != VCR_RECORD) {

            // change the hue to reflect speed
            renderer.setOverlayColor(speedColors[speedIndex]);

            // draw the speed
            ctx.font = (tileSize-1) + "px ArcadeR";
            ctx.textBaseline = "top";
            ctx.textAlign = "right";
            ctx.fillStyle = "#FFF";
            ctx.fillText("TIME", mapWidth-tileSize, 0);
            ctx.fillText(speeds[speedIndex]+"x", mapWidth-2*tileSize, tileSize);

            // draw up/down arrows
            var s = tileSize/2;
            ctx.fillStyle = "#AAA";
            ctx.save();

            ctx.translate(mapWidth-1.65*tileSize, tileSize-2);
            ctx.beginPath();
            ctx.moveTo(0,s);
            ctx.lineTo(s/2,0);
            ctx.lineTo(s,s);
            ctx.closePath();
            ctx.fill();

            ctx.translate(0,s+s/2);
            ctx.beginPath();
            ctx.moveTo(0,0);
            ctx.lineTo(s/2,s);
            ctx.lineTo(s,0);
            ctx.closePath();
            ctx.fill();

            ctx.restore();
        }

    };

    var updateMode = function() {
        var speed = speeds[speedIndex];
        if (speed == 0) {
            mode = VCR_PAUSE;
        }
        else if (speed < 0) {
            mode = VCR_REWIND;
        }
        else if (speed > 0) {
            mode = VCR_FORWARD;
        }
    };

    return {
        reset: reset,
        seek: seek,
        record: record,
        eraseFuture: eraseFuture,
        startRecording: startRecording,
        startSeeking: startSeeking,
        nextSpeed: nextSpeed,
        renderHud: renderHud,
        getTime: function() { return time; },
        getMode: function() { return mode; },
    };
})();
//@line 1 "src/direction.js"
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
        var oppDirEnum = (dirEnum+2)%4; // current opposite direction enum
        if (numOpenTiles > 1)
            openTiles[oppDirEnum] = false;
    }

    return openTiles;
};

// returns if the given tile coordinate plus the given direction vector has a walkable floor tile
var isNextTileFloor = function(tile,dir) {
    return map.isFloorTile(tile.x+dir.x,tile.y+dir.y);
};

//@line 1 "src/Map.js"
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

    // ghost home location
    this.doorTile = {x:13, y:14};
    this.doorPixel = {
        x:(this.doorTile.x+1)*tileSize-1, 
        y:this.doorTile.y*tileSize + midTile.y
    };
    this.homeTopPixel = 17*tileSize;
    this.homeBottomPixel = 18*tileSize;

    this.timeEaten = {};

    this.resetCurrent();
    this.parseDots();
    this.parseTunnels();
    this.parseWalls();
};

Map.prototype.save = function(t) {
};

Map.prototype.eraseFuture = function(t) {
    // current state at t.
    // erase all states after t.
    var i;
    for (i=0; i<this.numTiles; i++) {
        if (t <= this.timeEaten[i]) {
            delete this.timeEaten[i];
        }
    }
};

Map.prototype.load = function(t,abs_t) {
    var firstTile,curTile;
    var refresh = function(i) {
        var x,y;
        x = i%this.numCols;
        y = Math.floor(i/this.numCols);
        renderer.refreshPellet(x,y);
    };
    var i;
    for (i=0; i<this.numTiles; i++) {
        firstTile = this.startTiles[i];
        if (firstTile == '.' || firstTile == 'o') {
            if (abs_t <= this.timeEaten[i]) { // dot should be present
                if (this.currentTiles[i] != firstTile) {
                    this.dotsEaten--;
                    this.currentTiles[i] = firstTile;
                    refresh.call(this,i);
                }
            }
            else if (abs_t > this.timeEaten[i]) { // dot should be missing
                if (this.currentTiles[i] != ' ') {
                    this.dotsEaten++;
                    this.currentTiles[i] = ' ';
                    refresh.call(this,i);
                }
            }
        }
    }
};

Map.prototype.resetTimeEaten = function()
{
    this.startTiles = this.currentTiles.slice(0);
    this.timeEaten = {};
};

// reset current tiles
Map.prototype.resetCurrent = function() {
    this.currentTiles = this.tiles.split(""); // create a mutable list copy of an immutable string
    this.dotsEaten = 0;
};

// This is a procedural way to generate original-looking maps from a simple ascii tile
// map without a spritesheet.
Map.prototype.parseWalls = function() {

    var that = this;

    // creates a list of drawable canvas paths to render the map walls
    this.paths = [];

    // a map of wall tiles that already belong to a built path
    var visited = {};

    // we extend the x range to suggest the continuation of the tunnels
    var toIndex = function(x,y) {
        if (x>=-2 && x<that.numCols+2 && y>=0 && y<that.numRows)
            return (x+2)+y*(that.numCols+4);
    };

    // a map of which wall tiles that are not completely surrounded by other wall tiles
    var edges = {};
    var i=0,x,y;
    for (y=0;y<this.numRows;y++) {
        for (x=-2;x<this.numCols+2;x++,i++) {
            if (this.getTile(x,y) == '|' &&
                (this.getTile(x-1,y) != '|' ||
                this.getTile(x+1,y) != '|' ||
                this.getTile(x,y-1) != '|' ||
                this.getTile(x,y+1) != '|' ||
                this.getTile(x-1,y-1) != '|' ||
                this.getTile(x-1,y+1) != '|' ||
                this.getTile(x+1,y-1) != '|' ||
                this.getTile(x+1,y+1) != '|')) {
                edges[i] = true;
            }
        }
    }

    // walks along edge wall tiles starting at the given index to build a canvas path
    var makePath = function(tx,ty) {

        // get initial direction
        var dir = {};
        var dirEnum;
        if (toIndex(tx+1,ty) in edges)
            dirEnum = DIR_RIGHT;
        else if (toIndex(tx, ty+1) in edges)
            dirEnum = DIR_DOWN;
        else
            throw "tile shouldn't be 1x1 at "+tx+","+ty;
        setDirFromEnum(dir,dirEnum);

        // increment to next tile
        tx += dir.x;
        ty += dir.y;

        // backup initial location and direction
        var init_tx = tx;
        var init_ty = ty;
        var init_dirEnum = dirEnum;

        var path = [];
        var pad; // (persists for each call to getStartPoint)
        var point;
        var lastPoint;

        var turn,turnAround;

        /*

           We employ the 'right-hand rule' by keeping our right hand in contact
           with the wall to outline an individual wall piece.

           Since we parse the tiles in row major order, we will always start
           walking along the wall at the leftmost tile of its topmost row.  We
           then proceed walking to the right.  

           When facing the direction of the walk at each tile, the outline will
           hug the left side of the tile unless there is a walkable tile to the
           left.  In that case, there will be a padding distance applied.
           
        */
        var getStartPoint = function(tx,ty,dirEnum) {
            var dir = {};
            setDirFromEnum(dir, dirEnum);
            if (!(toIndex(tx+dir.y,ty-dir.x) in edges))
                pad = that.isFloorTile(tx+dir.y,ty-dir.x) ? 5 : 0;
            var px = -tileSize/2+pad;
            var py = tileSize/2;
            var a = dirEnum*Math.PI/2;
            var c = Math.cos(a);
            var s = Math.sin(a);
            return {
                // the first expression is the rotated point centered at origin
                // the second expression is to translate it to the tile
                x:(px*c - py*s) + (tx+0.5)*tileSize,
                y:(px*s + py*c) + (ty+0.5)*tileSize,
            };
        };
        while (true) {
            
            visited[toIndex(tx,ty)] = true;

            // determine start point
            point = getStartPoint(tx,ty,dirEnum);

            if (turn) {
                // if we're turning into this tile, create a control point for the curve
                //
                // >---+  <- control point
                //     |
                //     V
                lastPoint = path[path.length-1];
                if (dir.x == 0) {
                    point.cx = point.x;
                    point.cy = lastPoint.y;
                }
                else {
                    point.cx = lastPoint.x;
                    point.cy = point.y;
                }
            }

            // update direction
            turn = false;
            turnAround = false;
            if (toIndex(tx+dir.y, ty-dir.x) in edges) { // turn left
                dirEnum = (dirEnum+3)%4;
                turn = true;
            }
            else if (toIndex(tx+dir.x, ty+dir.y) in edges) { // continue straight
            }
            else if (toIndex(tx-dir.y, ty+dir.x) in edges) { // turn right
                dirEnum = (dirEnum+1)%4;
                turn = true;
            }
            else { // turn around
                dirEnum = (dirEnum+2)%4;
                turnAround = true;
            }
            setDirFromEnum(dir,dirEnum);

            // commit path point
            path.push(point);

            // special case for turning around (have to connect more dots manually)
            if (turnAround) {
                path.push(getStartPoint(tx-dir.x, ty-dir.y, (dirEnum+2)%4));
                path.push(getStartPoint(tx, ty, dirEnum));
            }

            // advance to the next wall
            tx += dir.x;
            ty += dir.y;

            // exit at full cycle
            if (tx==init_tx && ty==init_ty && dirEnum == init_dirEnum) {
                that.paths.push(path);
                break;
            }
        }
    };

    // iterate through all edges, making a new path after hitting an unvisited wall edge
    i=0;
    for (y=0;y<this.numRows;y++)
        for (x=-2;x<this.numCols+2;x++,i++)
            if (i in edges && !(i in visited)) {
                visited[i] = true;
                makePath(x,y);
            }
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
        tile = this.tiles[i];
        if (tile == '.') {
            this.numDots++;
        }
        else if (tile == 'o') {
            this.numDots++;
            this.numEnergizers++;
            this.energizers.push({'x':x,'y':y});
        }
        i++;
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
    if ((x<0 || x>=this.numCols) && (this.isTunnelTile(x,y-1) || this.isTunnelTile(x,y+1)))
        return '|';
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
    var i = this.posToIndex(x,y);
    this.currentTiles[i] = ' ';
    this.timeEaten[i] = vcr.getTime();
    renderer.erasePellet(x,y);
};
//@line 1 "src/colors.js"
// source: http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript

/**
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
 */
function rgbToHsl(r, g, b){
    r /= 255, g /= 255, b /= 255;
    var max = Math.max(r, g, b), min = Math.min(r, g, b);
    var h, s, l = (max + min) / 2;

    if(max == min){
        h = s = 0; // achromatic
    }else{
        var d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        switch(max){
            case r: h = (g - b) / d + (g < b ? 6 : 0); break;
            case g: h = (b - r) / d + 2; break;
            case b: h = (r - g) / d + 4; break;
        }
        h /= 6;
    }

    return [h, s, l];
}

/**
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  l       The lightness
 * @return  Array           The RGB representation
 */
function hslToRgb(h, s, l){
    var r, g, b;

    if(s == 0){
        r = g = b = l; // achromatic
    }else{
        function hue2rgb(p, q, t){
            if(t < 0) t += 1;
            if(t > 1) t -= 1;
            if(t < 1/6) return p + (q - p) * 6 * t;
            if(t < 1/2) return q;
            if(t < 2/3) return p + (q - p) * (2/3 - t) * 6;
            return p;
        }

        var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        var p = 2 * l - q;
        r = hue2rgb(p, q, h + 1/3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1/3);
    }

    r *= 255;
    g *= 255;
    b *= 255;

    return [r,g,b];
}

/**
 * Converts an RGB color value to HSV. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and v in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSV representation
 */
function rgbToHsv(r, g, b){
    r = r/255, g = g/255, b = b/255;
    var max = Math.max(r, g, b), min = Math.min(r, g, b);
    var h, s, v = max;

    var d = max - min;
    s = max == 0 ? 0 : d / max;

    if(max == min){
        h = 0; // achromatic
    }else{
        switch(max){
            case r: h = (g - b) / d + (g < b ? 6 : 0); break;
            case g: h = (b - r) / d + 2; break;
            case b: h = (r - g) / d + 4; break;
        }
        h /= 6;
    }

    return [h, s, v];
}

/**
 * Converts an HSV color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  v       The value
 * @return  Array           The RGB representation
 */
function hsvToRgb(h, s, v){
    var r, g, b;

    var i = Math.floor(h * 6);
    var f = h * 6 - i;
    var p = v * (1 - s);
    var q = v * (1 - f * s);
    var t = v * (1 - (1 - f) * s);

    switch(i % 6){
        case 0: r = v, g = t, b = p; break;
        case 1: r = q, g = v, b = p; break;
        case 2: r = p, g = v, b = t; break;
        case 3: r = p, g = q, b = v; break;
        case 4: r = t, g = p, b = v; break;
        case 5: r = v, g = p, b = q; break;
    }

    r *= 255;
    g *= 255;
    b *= 255;

    return [r,g,b];
}

function rgbString(rgb) {
    var r = Math.floor(rgb[0]);
    var g = Math.floor(rgb[1]);
    var b = Math.floor(rgb[2]);
    return 'rgb('+r+','+g+','+b+')';
}
//@line 1 "src/mapgen.js"
var mapgen = (function(){

    var getRandomInt = function(min,max) {
        return Math.floor(Math.random() * (max-min+1)) + min;
    };

    var shuffle = function(list) {
        var len = list.length;
        var i,j;
        var temp;
        for (i=0; i<len; i++) {
            j = getRandomInt(0,len-1);
            temp = list[i];
            list[i] = list[j];
            list[j] = temp;
        }
    };

    var randomElement = function(list) {
        var len = list.length;
        if (len > 0) {
            return list[getRandomInt(0,len-1)];
        }
    };

    var UP = 0;
    var RIGHT = 1;
    var DOWN = 2;
    var LEFT = 3;

    var cells = [];
    var tallRows = [];
    var narrowCols = [];

    var rows = 9;
    var cols = 5;

    var reset = function() {
        var i;
        var c;

        // initialize cells
        for (i=0; i<rows*cols; i++) {
            cells[i] = {
                x: i%cols,
                y: Math.floor(i/cols),
                filled: false,
                connect: [false, false, false, false],
                next: [],
                no: undefined,
                group: undefined,
            };
        }

        // allow each cell to refer to surround cells by direction
        for (i=0; i<rows*cols; i++) {
            var c = cells[i];
            if (c.x > 0)
                c.next[LEFT] = cells[i-1];
            if (c.x < cols - 1)
                c.next[RIGHT] = cells[i+1];
            if (c.y > 0)
                c.next[UP] = cells[i-cols];
            if (c.y < rows - 1)
                c.next[DOWN] = cells[i+cols];
        }

        // define the ghost home square

        i = 3*cols;
        c = cells[i];
        c.filled=true;
        c.connect[LEFT] = c.connect[RIGHT] = c.connect[DOWN] = true;

        i++;
        c = cells[i];
        c.filled=true;
        c.connect[LEFT] = c.connect[DOWN] = true;

        i+=cols-1;
        c = cells[i];
        c.filled=true;
        c.connect[LEFT] = c.connect[UP] = c.connect[RIGHT] = true;

        i++;
        c = cells[i];
        c.filled=true;
        c.connect[UP] = c.connect[LEFT] = true;
    };

    var genRandom = function() {

        var getLeftMostEmptyCells = function() {
            var x;
            var leftCells = [];
            for (x=0; x<cols; x++) {
                for (y=0; y<rows; y++) {
                    var c = cells[x+y*cols];
                    if (!c.filled) {
                        leftCells.push(c);
                    }
                }

                if (leftCells.length > 0) {
                    break;
                }
            }
            return leftCells;
        };
        var isOpenCell = function(cell,i,prevDir,size) {

            // prevent wall from going through starting position
            if (cell.y == 6 && cell.x == 0 && i == DOWN ||
                cell.y == 7 && cell.x == 0 && i == UP) {
                return false;
            }

            // prevent long straight pieces of length 3
            if (size == 2 && (i==prevDir || (i+2)%4==prevDir)) {
                return false;
            }

            // examine an adjacent empty cell
            if (cell.next[i] && !cell.next[i].filled) {
                
                // only open if the cell to the left of it is filled
                if (cell.next[i].next[LEFT] && !cell.next[i].next[LEFT].filled) {
                }
                else {
                    return true;
                }
            }

            return false;
        };
        var getOpenCells = function(cell,prevDir,size) {
            var openCells = [];
            var numOpenCells = 0;
            for (i=0; i<4; i++) {
                if (isOpenCell(cell,i,prevDir,size)) {
                    openCells.push(i);
                    numOpenCells++;
                }
            }
            return { openCells: openCells, numOpenCells: numOpenCells };
        };
        var connectCell = function(cell,dir) {
            cell.connect[dir] = true;
            cell.next[dir].connect[(dir+2)%4] = true;
            if (cell.x == 0 && dir == RIGHT) {
                cell.connect[LEFT] = true;
            }
        };

        var gen = function() {
        
            var cell;      // cell at the center of growth (open cells are chosen around this cell)
            var newCell;   // most recent cell filled
            var firstCell; // the starting cell of the current group

            var openCells;    // list of open cells around the center cell
            var numOpenCells; // size of openCells

            var dir; // the most recent direction of growth relative to the center cell
            var i;   // loop control variable used for iterating directions

            var numFilled = 0;  // current count of total cells filled
            var numGroups;      // current count of cell groups created
            var size;           // current number of cells in the current group
            var probStopGrowingAtSize = [ // probability of stopping growth at sizes...
                    0,     // size 0
                    0,     // size 1
                    0.10,  // size 2
                    0.5,   // size 3
                    0.75,  // size 4
                    1];    // size 5

            // A single cell group of size 1 is allowed at each row at y=0 and y=rows-1,
            // so keep count of those created.
            var singleCount = {};
            singleCount[0] = singleCount[rows-1] = 0;
            var probTopAndBotSingleCellJoin = 0.35;

            // A count and limit of the number long pieces (i.e. an "L" of size 4 or "T" of size 5)
            var longPieces = 0;
            var maxLongPieces = 1;
            var probExtendAtSize2 = 1;
            var probExtendAtSize3or4 = 0.5;

            var fillCell = function(cell) {
                cell.filled = true;
                cell.no = numFilled++;
                cell.group = numGroups;
            };

            for (numGroups=0; ; numGroups++) {

                // find all the leftmost empty cells
                openCells = getLeftMostEmptyCells();

                // stop add pieces if there are no more empty cells.
                numOpenCells = openCells.length;
                if (numOpenCells == 0) {
                    break;
                }

                // choose the center cell to be a random open cell, and fill it.
                firstCell = cell = openCells[getRandomInt(0,numOpenCells-1)];
                fillCell(cell);

                // randomly allow one single-cell piece on the top or bottom of the map.
                if (cell.x < cols-1 && (cell.y in singleCount) && Math.random() <= probTopAndBotSingleCellJoin) {
                    if (singleCount[cell.y] == 0) {
                        cell.connect[cell.y == 0 ? UP : DOWN] = true;
                        singleCount[cell.y]++;
                        continue;
                    }
                }

                // number of cells in this contiguous group
                size = 1;

                if (cell.x == cols-1) {
                    // if the first cell is at the right edge, then don't grow it.
                    cell.connect[RIGHT] = true;
                    cell.isRaiseHeightCandidate = true;
                }
                else {
                    // only allow the piece to grow to 5 cells at most.
                    while (size < 5) {

                        var stop = false;

                        if (size == 2) {
                            // With a horizontal 2-cell group, try to turn it into a 4-cell "L" group.
                            // This is done here because this case cannot be reached when a piece has already grown to size 3.
                            var c = firstCell;
                            if (c.x > 0 && c.connect[RIGHT] && c.next[RIGHT] && c.next[RIGHT].next[RIGHT]) {
                                if (longPieces < maxLongPieces && Math.random() <= probExtendAtSize2) {

                                    c = c.next[RIGHT].next[RIGHT];
                                    var dirs = {};
                                    if (isOpenCell(c,UP)) {
                                        dirs[UP] = true;
                                    }
                                    if (isOpenCell(c,DOWN)) {
                                        dirs[DOWN] = true;
                                    }

                                    if (dirs[UP] && dirs[DOWN]) {
                                        i = [UP,DOWN][getRandomInt(0,1)];
                                    }
                                    else if (dirs[UP]) {
                                        i = UP;
                                    }
                                    else if (dirs[DOWN]) {
                                        i = DOWN;
                                    }
                                    else {
                                        i = undefined;
                                    }

                                    if (i != undefined) {
                                        connectCell(c,LEFT);
                                        fillCell(c);
                                        connectCell(c,i);
                                        fillCell(c.next[i]);
                                        longPieces++;
                                        size+=2;
                                        stop = true;
                                    }
                                }
                            }
                        }

                        if (!stop) {
                            // find available open adjacent cells.
                            var result = getOpenCells(cell,dir,size);
                            openCells = result['openCells'];
                            numOpenCells = result['numOpenCells'];

                            // if no open cells found from center point, then use the last cell as the new center
                            // but only do this if we are of length 2 to prevent numerous short pieces.
                            // then recalculate the open adjacent cells.
                            if (numOpenCells == 0 && size == 2) {
                                cell = newCell;
                                result = getOpenCells(cell,dir,size);
                                openCells = result['openCells'];
                                numOpenCells = result['numOpenCells'];
                            }

                            // no more adjacent cells, so stop growing this piece.
                            if (numOpenCells == 0) {
                                stop = true;
                            }
                            else {
                                // choose a random valid direction to grow.
                                dir = openCells[getRandomInt(0,numOpenCells-1)];
                                newCell = cell.next[dir];

                                // connect the cell to the new cell.
                                connectCell(cell,dir);

                                // fill the cell
                                fillCell(newCell);

                                // increase the size count of this piece.
                                size++;

                                // don't let center pieces grow past 3 cells
                                if (firstCell.x == 0 && size == 3) {
                                    stop = true;
                                }

                                // Use a probability to determine when to stop growing the piece.
                                if (Math.random() <= probStopGrowingAtSize[size]) {
                                    stop = true;
                                }
                            }
                        }

                        // Close the piece.
                        if (stop) {

                            if (size == 1) {
                                // This is provably impossible because this loop is never entered with size==1.
                            }
                            else if (size == 2) {

                                // With a vertical 2-cell group, attach to the right wall if adjacent.
                                var c = firstCell;
                                if (c.x == cols-1) {

                                    // select the top cell
                                    if (c.connect[UP]) {
                                        c = c.next[UP];
                                    }
                                    c.connect[RIGHT] = c.next[DOWN].connect[RIGHT] = true;
                                }
                                
                            }
                            else if (size == 3 || size == 4) {

                                // Try to extend group to have a long leg
                                if (longPieces < maxLongPieces && firstCell.x > 0 && Math.random() <= probExtendAtSize3or4) {
                                    var dirs = [];
                                    var dirsLength = 0;
                                    for (i=0; i<4; i++) {
                                        if (cell.connect[i] && isOpenCell(cell.next[i],i)) {
                                            dirs.push(i);
                                            dirsLength++;
                                        }
                                    }
                                    if (dirsLength > 0) {
                                        i = dirs[getRandomInt(0,dirsLength-1)];
                                        c = cell.next[i];
                                        connectCell(c,i);
                                        fillCell(c.next[i]);
                                        longPieces++;
                                    }
                                }
                            }

                            break;
                        }
                    }
                }
            }
            setResizeCandidates();
        };


        var setResizeCandidates = function() {
            var i;
            var c,q,c2,q2;
            var x,y;
            for (i=0; i<rows*cols; i++) {
                c = cells[i];
                x = i % cols;
                y = Math.floor(i/cols);

                // determine if it has flexible height

                //
                // |_|
                //
                // or
                //  _
                // | |
                //
                q = c.connect;
                if ((c.x == 0 || !q[LEFT]) &&
                    (c.x == cols-1 || !q[RIGHT]) &&
                    q[UP] != q[DOWN]) {
                    c.isRaiseHeightCandidate = true;
                }

                //  _ _
                // |_ _|
                //
                c2 = c.next[RIGHT];
                if (c2 != undefined) {
                    q2 = c2.connect;
                    if (((c.x == 0 || !q[LEFT]) && !q[UP] && !q[DOWN]) &&
                        ((c2.x == cols-1 || !q2[RIGHT]) && !q2[UP] && !q2[DOWN])
                        ) {
                        c.isRaiseHeightCandidate = c2.isRaiseHeightCandidate = true;
                    }
                }

                // determine if it has flexible width

                // if cell is on the right edge with an opening to the right
                if (c.x == cols-1 && q[RIGHT]) {
                    c.isShrinkWidthCandidate = true;
                }

                //  _
                // |_
                // 
                // or
                //  _
                //  _|
                //
                if ((c.y == 0 || !q[UP]) &&
                    (c.y == rows-1 || !q[DOWN]) &&
                    q[LEFT] != q[RIGHT]) {
                    c.isShrinkWidthCandidate = true;
                }

            }
        };

        // Identify if a cell is the center of a cross.
        var cellIsCrossCenter = function(c) {
            return c.connect[UP] && c.connect[RIGHT] && c.connect[DOWN] && c.connect[LEFT];
        };

        var chooseNarrowCols = function() {

            var canShrinkWidth = function(x,y) {

                // Can cause no more tight turns.
                if (y==rows-1) {
                    return true;
                }

                // get the right-hand-side bound
                var x0;
                var c,c2;
                for (x0=x; x0<cols; x0++) {
                    c = cells[x0+y*cols];
                    c2 = c.next[DOWN]
                    if ((!c.connect[RIGHT] || cellIsCrossCenter(c)) &&
                        (!c2.connect[RIGHT] || cellIsCrossCenter(c2))) {
                        break;
                    }
                }

                // build candidate list
                var candidates = [];
                var numCandidates = 0;
                for (; c2; c2=c2.next[LEFT]) {
                    if (c2.isShrinkWidthCandidate) {
                        candidates.push(c2);
                        numCandidates++;
                    }

                    // cannot proceed further without causing irreconcilable tight turns
                    if ((!c2.connect[LEFT] || cellIsCrossCenter(c2)) &&
                        (!c2.next[UP].connect[LEFT] || cellIsCrossCenter(c2.next[UP]))) {
                        break;
                    }
                }
                shuffle(candidates);

                var i;
                for (i=0; i<numCandidates; i++) {
                    c2 = candidates[i];
                    if (canShrinkWidth(c2.x,c2.y)) {
                        c2.shrinkWidth = true;
                        narrowCols[c2.y] = c2.x;
                        return true;
                    }
                }

                return false;
            };

            var x;
            var c;
            for (x=cols-1; x>=0; x--) {
                c = cells[x];
                if (c.isShrinkWidthCandidate && canShrinkWidth(x,0)) {
                    c.shrinkWidth = true;
                    narrowCols[c.y] = c.x;
                    return true;
                }
            }

            return false;
        };

        var chooseTallRows = function() {

            var canRaiseHeight = function(x,y) {

                // Can cause no more tight turns.
                if (x==cols-1) {
                    return true;
                }

                // find the first cell below that will create too tight a turn on the right
                var y0;
                var c;
                var c2;
                for (y0=y; y0>=0; y0--) {
                    c = cells[x+y0*cols];
                    c2 = c.next[RIGHT]
                    if ((!c.connect[UP] || cellIsCrossCenter(c)) && 
                        (!c2.connect[UP] || cellIsCrossCenter(c2))) {
                        break;
                    }
                }

                // Proceed from the right cell upwards, looking for a cell that can be raised.
                var candidates = [];
                var numCandidates = 0;
                for (; c2; c2=c2.next[DOWN]) {
                    if (c2.isRaiseHeightCandidate) {
                        candidates.push(c2);
                        numCandidates++;
                    }

                    // cannot proceed further without causing irreconcilable tight turns
                    if ((!c2.connect[DOWN] || cellIsCrossCenter(c2)) &&
                        (!c2.next[LEFT].connect[DOWN] || cellIsCrossCenter(c2.next[LEFT]))) {
                        break;
                    }
                }
                shuffle(candidates);

                var i;
                for (i=0; i<numCandidates; i++) {
                    c2 = candidates[i];
                    if (canRaiseHeight(c2.x,c2.y)) {
                        c2.raiseHeight = true;
                        tallRows[c2.x] = c2.y;
                        return true;
                    }
                }

                return false;
            };

            // From the top left, examine cells below until hitting top of ghost house.
            // A raisable cell must be found before the ghost house.
            var y;
            var c;
            for (y=0; y<3; y++) {
                c = cells[y*cols];
                if (c.isRaiseHeightCandidate && canRaiseHeight(0,y)) {
                    c.raiseHeight = true;
                    tallRows[c.x] = c.y;
                    return true;
                }
            }

            return false;
        };

        // This is a function to detect impurities in the map that have no heuristic implemented to avoid it yet in gen().
        var isDesirable = function() {

            // ensure a solid top right corner
            var c = cells[4];
            if (c.connect[UP] || c.connect[RIGHT]) {
                return false;
            }

            // ensure a solid bottom right corner
            c = cells[rows*cols-1];
            if (c.connect[DOWN] || c.connect[RIGHT]) {
                return false;
            }

            // ensure there are no two stacked/side-by-side 2-cell pieces.
            var isHori = function(x,y) {
                var q1 = cells[x+y*cols].connect;
                var q2 = cells[x+1+y*cols].connect;
                return !q1[UP] && !q1[DOWN] && (x==0 || !q1[LEFT]) && q1[RIGHT] && 
                       !q2[UP] && !q2[DOWN] && q2[LEFT] && !q2[RIGHT];
            };
            var isVert = function(x,y) {
                var q1 = cells[x+y*cols].connect;
                var q2 = cells[x+(y+1)*cols].connect;
                if (x==cols-1) {
                    // special case (we can consider two single cells as vertical at the right edge)
                    return !q1[LEFT] && !q1[UP] && !q1[DOWN] &&
                           !q2[LEFT] && !q2[UP] && !q2[DOWN];
                }
                return !q1[LEFT] && !q1[RIGHT] && !q1[UP] && q1[DOWN] && 
                       !q2[LEFT] && !q2[RIGHT] && q2[UP] && !q2[DOWN];
            };
            var x,y;
            var g;
            for (y=0; y<rows-1; y++) {
                for (x=0; x<cols-1; x++) {
                    if (isHori(x,y) && isHori(x,y+1) ||
                        isVert(x,y) && isVert(x+1,y)) {

                        // don't allow them in the middle because they'll be two large when reflected.
                        if (x==0) {
                            return false;
                        }

                        // Join the four cells to create a square.
                        cells[x+y*cols].connect[DOWN] = true;
                        cells[x+y*cols].connect[RIGHT] = true;
                        g = cells[x+y*cols].group;

                        cells[x+1+y*cols].connect[DOWN] = true;
                        cells[x+1+y*cols].connect[LEFT] = true;
                        cells[x+1+y*cols].group = g;

                        cells[x+(y+1)*cols].connect[UP] = true;
                        cells[x+(y+1)*cols].connect[RIGHT] = true;
                        cells[x+(y+1)*cols].group = g;

                        cells[x+1+(y+1)*cols].connect[UP] = true;
                        cells[x+1+(y+1)*cols].connect[LEFT] = true;
                        cells[x+1+(y+1)*cols].group = g;
                    }
                }
            }

            if (!chooseTallRows()) {
                return false;
            }

            if (!chooseNarrowCols()) {
                return false;
            }

            return true;
        };

        // set the final position and size of each cell when upscaling the simple model to actual size
        var setUpScaleCoords = function() {
            var i,c;
            for (i=0; i<rows*cols; i++) {
                c = cells[i];
                c.final_x = c.x*3;
                if (narrowCols[c.y] < c.x) {
                    c.final_x--;
                }
                c.final_y = c.y*3;
                if (tallRows[c.x] < c.y) {
                    c.final_y++;
                }
                c.final_w = c.shrinkWidth ? 2 : 3;
                c.final_h = c.raiseHeight ? 4 : 3;
            }
        };

        var reassignGroup = function(oldg,newg) {
            var i;
            var c;
            for (i=0; i<rows*cols; i++) {
                c = cells[i];
                if (c.group == oldg) {
                    c.group = newg;
                }
            }
        };

        var createTunnels = function() {

            // declare candidates
            var singleDeadEndCells = [];
            var topSingleDeadEndCells = [];
            var botSingleDeadEndCells = [];

            var voidTunnelCells = [];
            var topVoidTunnelCells = [];
            var botVoidTunnelCells = [];

            var edgeTunnelCells = [];
            var topEdgeTunnelCells = [];
            var botEdgeTunnelCells = [];

            var doubleDeadEndCells = [];

            var numTunnelsCreated = 0;

            // prepare candidates
            var y;
            var c;
            var upDead;
            var downDead;
            for (y=0; y<rows; y++) {
                c = cells[cols-1+y*cols];
                if (c.connect[UP]) {
                    continue;
                }
                if (c.y > 1 && c.y < rows-2) {
                    c.isEdgeTunnelCandidate = true;
                    edgeTunnelCells.push(c);
                    if (c.y <= 2) {
                        topEdgeTunnelCells.push(c);
                    }
                    else if (c.y >= 5) {
                        botEdgeTunnelCells.push(c);
                    }
                }
                upDead = (!c.next[UP] || c.next[UP].connect[RIGHT]);
                downDead = (!c.next[DOWN] || c.next[DOWN].connect[RIGHT]);
                if (c.connect[RIGHT]) {
                    if (upDead) {
                        c.isVoidTunnelCandidate = true;
                        voidTunnelCells.push(c);
                        if (c.y <= 2) {
                            topVoidTunnelCells.push(c);
                        }
                        else if (c.y >= 6) {
                            botVoidTunnelCells.push(c);
                        }
                    }
                }
                else {
                    if (c.connect[DOWN]) {
                        continue;
                    }
                    if (upDead != downDead) {
                        if (!c.raiseHeight && y < rows-1 && !c.next[LEFT].connect[LEFT]) {
                            singleDeadEndCells.push(c);
                            c.isSingleDeadEndCandidate = true;
                            c.singleDeadEndDir = upDead ? UP : DOWN;
                            var offset = upDead ? 1 : 0;
                            if (c.y <= 1+offset) {
                                topSingleDeadEndCells.push(c);
                            }
                            else if (c.y >= 5+offset) {
                                botSingleDeadEndCells.push(c);
                            }
                        }
                    }
                    else if (upDead && downDead) {
                        if (y > 0 && y < rows-1) {
                            if (c.next[LEFT].connect[UP] && c.next[LEFT].connect[DOWN]) {
                                c.isDoubleDeadEndCandidate = true;
                                if (c.y >= 2 && c.y <= 5) {
                                    doubleDeadEndCells.push(c);
                                }
                            }
                        }
                    }
                }
            }

            // choose tunnels from candidates
            var numTunnelsDesired = Math.random() <= 0.45 ? 2 : 1;
            var c;
            var selectSingleDeadEnd = function(c) {
                c.connect[RIGHT] = true;
                if (c.singleDeadEndDir == UP) {
                    c.topTunnel = true;
                }
                else {
                    c.next[DOWN].topTunnel = true;
                }
            };
            if (numTunnelsDesired == 1) {
                if (c = randomElement(voidTunnelCells)) {
                    c.topTunnel = true;
                }
                else if (c = randomElement(singleDeadEndCells)) {
                    selectSingleDeadEnd(c);
                }
                else if (c = randomElement(edgeTunnelCells)) {
                    c.topTunnel = true;
                }
                else {
                    return false;
                }
            }
            else if (numTunnelsDesired == 2) {
                if (c = randomElement(doubleDeadEndCells)) {
                    c.connect[RIGHT] = true;
                    c.topTunnel = true;
                    c.next[DOWN].topTunnel = true;
                }
                else {
                    numTunnelsCreated = 1;
                    if (c = randomElement(topVoidTunnelCells)) {
                        c.topTunnel = true;
                    }
                    else if (c = randomElement(topSingleDeadEndCells)) {
                        selectSingleDeadEnd(c);
                    }
                    else if (c = randomElement(topEdgeTunnelCells)) {
                        c.topTunnel = true;
                    }
                    else {
                        // could not find a top tunnel opening
                        numTunnelsCreated = 0;
                    }

                    if (c = randomElement(botVoidTunnelCells)) {
                        c.topTunnel = true;
                    }
                    else if (c = randomElement(botSingleDeadEndCells)) {
                        selectSingleDeadEnd(c);
                    }
                    else if (c = randomElement(botEdgeTunnelCells)) {
                        c.topTunnel = true;
                    }
                    else {
                        // could not find a bottom tunnel opening
                        if (numTunnelsCreated == 0) {
                            return false;
                        }
                    }
                }
            }

            // don't allow a horizontal path to cut straight through a map (through tunnels)
            var exit,topy;
            for (y=0; y<rows; y++) {
                c = cells[cols-1+y*cols];
                if (c.topTunnel) {
                    exit = true;
                    topy = c.final_y;
                    while (c.next[LEFT]) {
                        c = c.next[LEFT];
                        if (!c.connect[UP] && c.final_y == topy) {
                            continue;
                        }
                        else {
                            exit = false;
                            break;
                        }
                    }
                    if (exit) {
                        return false;
                    }
                }
            }

            // clear unused void tunnels (dead ends)
            var len = voidTunnelCells.length;
            var i;

            var replaceGroup = function(oldg,newg) {
                var i,c;
                for (i=0; i<rows*cols; i++) {
                    c = cells[i];
                    if (c.group == oldg) {
                        c.group = newg;
                    }
                }
            };
            for (i=0; i<len; i++) {
                c = voidTunnelCells[i];
                if (!c.topTunnel) {
                    replaceGroup(c.group, c.next[UP].group);
                    c.connect[UP] = true;
                    c.next[UP].connect[DOWN] = true;
                }
            }

            return true;
        };

        var joinWalls = function() {

            // randomly join wall pieces to the boundary to increase difficulty

            var x,y;
            var c;

            // join cells to the top boundary
            for (x=0; x<cols; x++) {
                c = cells[x];
                if (!c.connect[LEFT] && !c.connect[RIGHT] && !c.connect[UP] &&
                    (!c.connect[DOWN] || !c.next[DOWN].connect[DOWN])) {

                    // ensure it will not create a dead-end
                    if ((!c.next[LEFT] || !c.next[LEFT].connect[UP]) &&
                        (c.next[RIGHT] && !c.next[RIGHT].connect[UP])) {

                        // prevent connecting very large piece
                        if (!(c.next[DOWN] && c.next[DOWN].connect[RIGHT] && c.next[DOWN].next[RIGHT].connect[RIGHT])) {
                            c.isJoinCandidate = true;
                            if (Math.random() <= 0.25) {
                                c.connect[UP] = true;
                            }
                        }
                    }
                }
            }

            // join cells to the bottom boundary
            for (x=0; x<cols; x++) {
                c = cells[x+(rows-1)*cols];
                if (!c.connect[LEFT] && !c.connect[RIGHT] && !c.connect[DOWN] &&
                    (!c.connect[UP] || !c.next[UP].connect[UP])) {

                    // ensure it will not creat a dead-end
                    if ((!c.next[LEFT] || !c.next[LEFT].connect[DOWN]) &&
                        (c.next[RIGHT] && !c.next[RIGHT].connect[DOWN])) {

                        // prevent connecting very large piece
                        if (!(c.next[UP] && c.next[UP].connect[RIGHT] && c.next[UP].next[RIGHT].connect[RIGHT])) {
                            c.isJoinCandidate = true;
                            if (Math.random() <= 0.25) {
                                c.connect[DOWN] = true;
                            }
                        }
                    }
                }
            }

            // join cells to the right boundary
            var c2;
            for (y=1; y<rows-1; y++) {
                c = cells[cols-1+y*cols];
                if (c.raiseHeight) {
                    continue;
                }
                if (!c.connect[RIGHT] && !c.connect[UP] && !c.connect[DOWN] &&
                    !c.next[UP].connect[RIGHT] && !c.next[DOWN].connect[RIGHT]) {
                    if (c.connect[LEFT]) {
                        c2 = c.next[LEFT];
                        if (!c2.connect[UP] && !c2.connect[DOWN] && !c2.connect[LEFT]) {
                            c.isJoinCandidate = true;
                            if (Math.random() <= 0.5) {
                                c.connect[RIGHT] = true;
                            }
                        }
                    }
                }
            }
        };

        // try to generate a valid map, and keep count of tries.
        var genCount = 0;
        while (true) {
            reset();
            gen();
            genCount++;
            if (!isDesirable()) {
                continue;
            }

            setUpScaleCoords();
            joinWalls();
            if (!createTunnels()) {
                continue;
            }

            break;
        }

    };

    // Transform the simple cells to a tile array used for creating the map.
    var getTiles = function() {

        var tiles = []; // each is a character indicating a wall(|), path(.), or blank(_).
        var tileCells = []; // maps each tile to a specific cell of our simple map
        var subrows = rows*3+1+3;
        var subcols = cols*3-1+2;

        var midcols = subcols-2;
        var fullcols = (subcols-2)*2;

        // getter and setter for tiles (ensures vertical symmetry axis)
        var setTile = function(x,y,v) {
            if (x<0 || x>subcols-1 || y<0 || y>subrows-1) {
                return;
            }
            x -= 2;
            tiles[midcols+x+y*fullcols] = v;
            tiles[midcols-1-x+y*fullcols] = v;
        };
        var getTile = function(x,y) {
            if (x<0 || x>subcols-1 || y<0 || y>subrows-1) {
                return undefined;
            }
            x -= 2;
            return tiles[midcols+x+y*fullcols];
        };

        // getter and setter for tile cells
        var setTileCell = function(x,y,cell) {
            if (x<0 || x>subcols-1 || y<0 || y>subrows-1) {
                return;
            }
            x -= 2;
            tileCells[x+y*subcols] = cell;
        };
        var getTileCell = function(x,y) {
            if (x<0 || x>subcols-1 || y<0 || y>subrows-1) {
                return undefined;
            }
            x -= 2;
            return tileCells[x+y*subcols];
        };

        // initialize tiles
        var i;
        for (i=0; i<subrows*fullcols; i++) {
            tiles.push('_');
        }
        for (i=0; i<subrows*subcols; i++) {
            tileCells.push(undefined);
        }

        // set tile cells
        var c;
        var x,y,w,h;
        var x0,y0;
        for (i=0; i<rows*cols; i++) {
            c = cells[i];
            for (x0=0; x0<c.final_w; x0++) {
                for (y0=0; y0<c.final_h; y0++) {
                    setTileCell(c.final_x+x0,c.final_y+1+y0,c);
                }
            }
        }

        // set path tiles
        var cl, cu;
        for (y=0; y<subrows; y++) {
            for (x=0; x<subcols; x++) {
                c = getTileCell(x,y); // cell
                cl = getTileCell(x-1,y); // left cell
                cu = getTileCell(x,y-1); // up cell

                if (c) {
                    // inside map
                    if (cl && c.group != cl.group || // at vertical boundary
                        cu && c.group != cu.group || // at horizontal boundary
                        !cu && !c.connect[UP]) { // at top boundary
                        setTile(x,y,'.');
                    }
                }
                else {
                    // outside map
                    if (cl && (!cl.connect[RIGHT] || getTile(x-1,y) == '.') || // at right boundary
                        cu && (!cu.connect[DOWN] || getTile(x,y-1) == '.')) { // at bottom boundary
                        setTile(x,y,'.');
                    }
                }

                // at corner connecting two paths
                if (getTile(x-1,y) == '.' && getTile(x,y-1) == '.' && getTile(x-1,y-1) == '_') {
                    setTile(x,y,'.');
                }
            }
        }

        // extend tunnels
        var y;
        for (c=cells[cols-1]; c; c = c.next[DOWN]) {
            if (c.topTunnel) {
                y = c.final_y+1;
                setTile(subcols-1, y,'.');
                setTile(subcols-2, y,'.');
            }
        }

        // fill in walls
        for (y=0; y<subrows; y++) {
            for (x=0; x<subcols; x++) {
                // any blank tile that shares a vertex with a path tile should be a wall tile
                if (getTile(x,y) != '.' && (getTile(x-1,y) == '.' || getTile(x,y-1) == '.' || getTile(x+1,y) == '.' || getTile(x,y+1) == '.' ||
                    getTile(x-1,y-1) == '.' || getTile(x+1,y-1) == '.' || getTile(x+1,y+1) == '.' || getTile(x-1,y+1) == '.')) {
                    setTile(x,y,'|');
                }
            }
        }

        // create the ghost door
        setTile(2,12,'-');

        // set energizers
        var getTopEnergizerRange = function() {
            var miny;
            var maxy = subrows/2;
            var x = subcols-2;
            var y;
            for (y=2; y<maxy; y++) {
                if (getTile(x,y) == '.' && getTile(x,y+1) == '.') {
                    miny = y+1;
                    break;
                }
            }
            maxy = Math.min(maxy,miny+7);
            for (y=miny+1; y<maxy; y++) {
                if (getTile(x-1,y) == '.') {
                    maxy = y-1;
                    break;
                }
            }
            return {miny:miny, maxy:maxy};
        };
        var getBotEnergizerRange = function() {
            var miny = subrows/2;
            var maxy;
            var x = subcols-2;
            var y;
            for (y=subrows-3; y>=miny; y--) {
                if (getTile(x,y) == '.' && getTile(x,y+1) == '.') {
                    maxy = y;
                    break;
                }
            }
            miny = Math.max(miny,maxy-7);
            for (y=maxy-1; y>miny; y--) {
                if (getTile(x-1,y) == '.') {
                    miny = y+1;
                    break;
                }
            }
            return {miny:miny, maxy:maxy};
        };
        var x = subcols-2;
        var y;
        var range;
        if (range = getTopEnergizerRange()) {
            y = getRandomInt(range.miny, range.maxy);
            setTile(x,y,'o');
        }
        if (range = getBotEnergizerRange()) {
            y = getRandomInt(range.miny, range.maxy);
            setTile(x,y,'o');
        }

        // erase pellets in the tunnels
        var eraseUntilIntersection = function(x,y) {
            var adj;
            while (true) {
                adj = [];
                if (getTile(x-1,y) == '.') {
                    adj.push({x:x-1,y:y});
                }
                if (getTile(x+1,y) == '.') {
                    adj.push({x:x+1,y:y});
                }
                if (getTile(x,y-1) == '.') {
                    adj.push({x:x,y:y-1});
                }
                if (getTile(x,y+1) == '.') {
                    adj.push({x:x,y:y+1});
                }
                if (adj.length == 1) {
                    setTile(x,y,' ');
                    x = adj[0].x;
                    y = adj[0].y;
                }
                else {
                    break;
                }
            }
        };
        x = subcols-1;
        for (y=0; y<subrows; y++) {
            if (getTile(x,y) == '.') {
                eraseUntilIntersection(x,y);
            }
        }

        // erase pellets on starting position
        setTile(1,subrows-8,' ');

        // erase pellets around the ghost house
        var i,j;
        var y;
        for (i=0; i<7; i++) {

            // erase pellets from bottom of the ghost house proceeding down until
            // reaching a pellet tile that isn't surround by walls
            // on the left and right
            y = subrows-14;
            setTile(i, y, ' ');
            j = 1;
            while (getTile(i,y+j) == '.' &&
                    getTile(i-1,y+j) == '|' &&
                    getTile(i+1,y+j) == '|') {
                setTile(i,y+j,' ');
                j++;
            }

            // erase pellets from top of the ghost house proceeding up until
            // reaching a pellet tile that isn't surround by walls
            // on the left and right
            y = subrows-20;
            setTile(i, y, ' ');
            j = 1;
            while (getTile(i,y-j) == '.' &&
                    getTile(i-1,y-j) == '|' &&
                    getTile(i+1,y-j) == '|') {
                setTile(i,y-j,' ');
                j++;
            }
        }
        // erase pellets on the side of the ghost house
        for (i=0; i<7; i++) {

            // erase pellets from side of the ghost house proceeding right until
            // reaching a pellet tile that isn't surround by walls
            // on the top and bottom.
            x = 6;
            y = subrows-14-i;
            setTile(x, y, ' ');
            j = 1;
            while (getTile(x+j,y) == '.' &&
                    getTile(x+j,y-1) == '|' &&
                    getTile(x+j,y+1) == '|') {
                setTile(x+j,y,' ');
                j++;
            }
        }

        // return a tile string (3 empty lines on top and 2 on bottom)
        return (
            "____________________________" +
            "____________________________" +
            "____________________________" +
            tiles.join("") +
            "____________________________" +
            "____________________________");
    };

    var randomColor = function() {
        return '#'+('00000'+(Math.random()*(1<<24)|0).toString(16)).slice(-6);
    };

    // dijkstra's algorithm to find shortest path to all tiles from (x0,y0)
    // we also remove (destroyX,destroyY) from the map to try to constrain the path
    // from going a certain way from the start.
    // (We created this because the ghost's minimum distance direction is not always sufficient in procedural maps)
    var getShortestDistGraph = function(map,x0,y0,isNodeTile) {

        // build graph
        var graph = {};
        var x,y,i,j;
        for (y=0; y<36; y++) {
            for (x=0; x<28; x++) {
                if (isNodeTile(x,y)) {
                    i = x+y*28;
                    graph[i] = {'x':x, 'y':y, 'dist':Infinity, 'penult':undefined, 'neighbors':[], 'completed':false};
                    if (isNodeTile(x-1,y)) {
                        j = i-1;
                        graph[i].neighbors.push(graph[j]);
                        graph[j].neighbors.push(graph[i]);
                    }
                    if (isNodeTile(x,y-1)) {
                        j = i-28;
                        graph[i].neighbors.push(graph[j]);
                        graph[j].neighbors.push(graph[i]);
                    }
                }
            }
        }

        var node = graph[x0+y0*28];
        node.completed = true;
        node.dist = 0;
        var d;
        var next_node,min_dist,dist;
        while (true) {

            // update distances of current node's neighbors
            for (i=0; i<4; i++) {
                d = node.neighbors[i];
                if (d && !d.completed) {
                    dist = node.dist+1;
                    if (dist == d.dist) {
                        if (Math.random() < 0.5) {
                            d.penult = node;
                        }
                    }
                    else if (dist < d.dist) {
                        d.dist = dist;
                        d.penult = node;
                    }
                }
            }

            // find next node to process (closest fringe node)
            next_node = undefined;
            min_dist = Infinity;
            for (i=0; i<28*36; i++) {
                d = graph[i];
                if (d && !d.completed) {
                    if (d.dist < min_dist) { 
                        next_node = d;
                        min_dist = d.dist;
                    }
                }
            }

            if (!next_node) {
                break;
            }

            node = next_node;
            node.completed = true;
        }

        return graph;
    };

    // retrieves the direction enum from a node's penultimate node to itself.
    var getDirFromPenult = function(node) {
        if (!node.penult) {
            return undefined;
        }
        var dx = node.x - node.penult.x;
        var dy = node.y - node.penult.y;
        if (dy == -1) {
            return DIR_UP;
        }
        else if (dy == 1) {
            return DIR_DOWN;
        }
        else if (dx == -1) {
            return DIR_LEFT;
        }
        else if (dx == 1) {
            return DIR_RIGHT;
        }
    };

    // sometimes the ghosts can get stuck in loops when trying to return home
    // so we build a path from all tiles to the ghost door tile
    var makeExitPaths = function(map) {
        var isNodeTile = function(x,y) {
            if (x<0 || x>=28 || y<0 || y>=36) {
                return false;
            }
            return map.isFloorTile(x,y);
        };
        var graph = getShortestDistGraph(map,map.doorTile.x,map.doorTile.y,isNodeTile);

        // give the map a function that tells the ghost which direction to go to return home
        map.getExitDir = function(x,y) {
            if (x<0 || x>=28 || y<0 || y>=36) {
                return undefined;
            }
            var node = graph[x+y*28];
            var dirEnum = getDirFromPenult(node);
            if (dirEnum != undefined) {
                return (dirEnum+2)%4; // reverse direction (door->ghost to door<-ghost)
            }
        };
    };

    // add fruit paths to a map
    var makeFruitPaths = (function(){
        var reversed = {
            'v':'^',
            '^':'v',
            '<':'>',
            '>':'<',
        };
        var reversePath = function(path) {
            var rpath = "";
            var i;
            for (i=path.length-1; i>=0; i--) {
                rpath += reversed[path[i]];
            }
            return rpath;
        };

        var dirChars = {};
        dirChars[DIR_UP] = '^';
        dirChars[DIR_DOWN] = 'v';
        dirChars[DIR_LEFT] = '<';
        dirChars[DIR_RIGHT] = '>';

        var getPathFromGraph = function(graph,x0,y0,x1,y1,reverse) {
            // from (x0,y0) to (x1,y1)
            var start_node = graph[x0+y0*28];
            var dx,dy;
            var path = "";
            var node;
            for (node=graph[x1+y1*28]; node!=start_node; node=node.penult) {
                path = dirChars[getDirFromPenult(node)] + path;
            }
            return reverse ? reversePath(path) : path;
        }

        return function(map) {

            paths = {entrances:[], exits:[]};

            var isFloorTile = function(x,y) {
                if (x<0 || x>=28 || y<0 || y>=36) {
                    return false
                }
                return map.isFloorTile(x,y);
            };

            enter_graph = getShortestDistGraph(map,15,20, function(x,y) { return (x==14 && y==20) ? false : isFloorTile(x,y); });
            exit_graph =  getShortestDistGraph(map,16,20, function(x,y) { return (x==17 && y==20) ? false : isFloorTile(x,y); });

            // start at (15,20)
            for (y=0; y<36; y++) {
                if (map.isFloorTile(-1,y)) {

                    // left entrance
                    paths.entrances.push({
                        'start': {'y':y*8+4, 'x': -4},
                        'path': '>'+getPathFromGraph(enter_graph, 15,20, 0,y, true)});

                    // right entrance
                    paths.entrances.push({
                        'start': {'y':y*8+4, 'x': 28*8+4},
                        'path': '<'+getPathFromGraph(enter_graph, 15,20, 27,y, true)});

                    // left exit
                    paths.exits.push({
                        'start': {'y':y*8+4, 'x': -4},
                        'path': getPathFromGraph(exit_graph, 16,20, 0,y, false)+'<'});

                    // right exit
                    paths.exits.push({
                        'start': {'y':y*8+4, 'x': 28*8+4},
                        'path': getPathFromGraph(exit_graph, 16,20, 27,y, false)+'>'});
                }
            }

            map.fruitPaths = paths;
        };
    })();

    return function() {
        genRandom();
        var map = new Map(28,36,getTiles());

        makeFruitPaths(map);
        makeExitPaths(map);

        map.name = "Random Map";
        map.wallFillColor = randomColor();
        map.wallStrokeColor = rgbString(hslToRgb(Math.random(), Math.random(), Math.random() * 0.4 + 0.6));
        map.pelletColor = "#ffb8ae";

        return map;
    };
})();
//@line 1 "src/atlas.js"

var atlas = (function(){

    var canvas,ctx;
    var size = 20;
    var cols = 13; // has to be ONE MORE than intended to fix some sort of CHROME BUG (last cell always blank?)
    var rows = 13; // one more for good measure like cols

    var creates = 0;

    var create = function() {
        canvas = document.getElementById('atlas');
        ctx = canvas.getContext("2d");
        canvas.style.left = 0;
        canvas.style.top = 0;
        canvas.style.position = "absolute";

        var w = size*cols*renderScale;
        var h = size*rows*renderScale;
        canvas.width = w;
        canvas.height = h;

        if (creates > 0) {
            ctx.restore();
        }
        creates++;

        ctx.save();
        ctx.clearRect(0,0,w,h);
        ctx.scale(renderScale,renderScale);

        var drawAtCell = function(f,row,col) {
            var x = col*size + size/2;
            var y = row*size + size/2;
            f(x,y);
        };

        var row = 0;
        drawAtCell(function(x,y) { drawCherry(ctx,x,y); },      row,0);
        drawAtCell(function(x,y) { drawStrawberry(ctx,x,y); },  row,1);
        drawAtCell(function(x,y) { drawOrange(ctx,x,y); },      row,2);
        drawAtCell(function(x,y) { drawApple(ctx,x,y); },       row,3);
        drawAtCell(function(x,y) { drawMelon(ctx,x,y); },       row,4);
        drawAtCell(function(x,y) { drawGalaxian(ctx,x,y); },    row,5);
        drawAtCell(function(x,y) { drawBell(ctx,x,y); },        row,6);
        drawAtCell(function(x,y) { drawKey(ctx,x,y); },         row,7);
        drawAtCell(function(x,y) { drawPretzel(ctx,x,y); },     row,8);
        drawAtCell(function(x,y) { drawPear(ctx,x,y); },        row,9);
        drawAtCell(function(x,y) { drawBanana(ctx,x,y); },      row,10);
        drawAtCell(function(x,y) { drawCookie(ctx,x,y); },      row,11);

        var drawGhostCells = function(row,color) {
            drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_UP, false, false, false, color); },   row,0);
            drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 1, DIR_UP, false, false, false, color); },   row,1);
            drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_RIGHT, false, false, false, color) },  row,2);
            drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 1, DIR_RIGHT, false, false, false, color) },  row,3);
            drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_DOWN, false, false, false, color) },  row,4);
            drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 1, DIR_DOWN, false, false, false, color) },  row,5);
            drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_LEFT, false, false, false, color) }, row,6);
            drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 1, DIR_LEFT, false, false, false, color) }, row,7);
        };

        row++;
        drawGhostCells(row, "#FF0000");
        row++;
        drawGhostCells(row, "#FFB8FF");
        row++;
        drawGhostCells(row, "#00FFFF");
        row++;
        drawGhostCells(row, "#FFB851");

        row++;
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_UP, false, false, true, "#fff"); },     row,0);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_RIGHT, false, false, true, "#fff"); },  row,1);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_DOWN, false, false, true, "#fff"); },   row,2);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_LEFT, false, false, true, "#fff"); },   row,3);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_UP, true, false, false, "#fff"); }, row,4);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 1, DIR_UP, true, false, false, "#fff"); }, row,5);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_UP, true, true, false, "#fff"); },  row,6);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 1, DIR_UP, true, true, false, "#fff"); },  row,7);

        var drawPacCells = function(row,col,dir) {
            drawAtCell(function(x,y) { drawPacmanSprite(ctx, x,y, dir, Math.PI/6); }, row, col);
            drawAtCell(function(x,y) { drawPacmanSprite(ctx, x,y, dir, Math.PI/3); }, row, col+1);
        };
        row++;
        drawAtCell(function(x,y) { drawPacmanSprite(ctx, x,y, DIR_RIGHT, 0); }, row, 0);
        drawPacCells(row,1,DIR_UP);
        drawPacCells(row,3,DIR_RIGHT);
        drawPacCells(row,5,DIR_DOWN);
        drawPacCells(row,7,DIR_LEFT);

        var drawMsPacCells = function(row,col,dir) {
            drawAtCell(function(x,y) { drawMsPacmanSprite(ctx, x,y, dir, 0); }, row, col);
            drawAtCell(function(x,y) { drawMsPacmanSprite(ctx, x,y, dir, 1); }, row, col+1);
            drawAtCell(function(x,y) { drawMsPacmanSprite(ctx, x,y, dir, 2); }, row, col+2);
        };
        row++;
        drawMsPacCells(row,0, DIR_UP);
        drawMsPacCells(row,3, DIR_RIGHT);
        drawMsPacCells(row,6, DIR_DOWN);
        drawMsPacCells(row,9, DIR_LEFT);

        var drawCookieCells = function(row,col,dir) {
            drawAtCell(function(x,y) { drawCookiemanSprite(ctx, x,y, dir, 0, true); }, row, col);
            drawAtCell(function(x,y) { drawCookiemanSprite(ctx, x,y, dir, 1, true); }, row, col+1);
            drawAtCell(function(x,y) { drawCookiemanSprite(ctx, x,y, dir, 2, true); }, row, col+2);
        };
        row++;
        drawCookieCells(row,0, DIR_UP);
        drawCookieCells(row,3, DIR_RIGHT);
        drawCookieCells(row,6, DIR_DOWN);
        drawCookieCells(row,9, DIR_LEFT);
    };

    var copyCellTo = function(row, col, destCtx, x, y,display) {
        var sx = col*size*renderScale;
        var sy = row*size*renderScale;
        var sw = renderScale*size;
        var sh = renderScale*size;

        var dx = x - size/2;
        var dy = y - size/2;
        var dw = size;
        var dh = size;

        if (display) {
            console.log(sx,sy,sw,sh,dw,dy,dw,dh);
        }

        destCtx.drawImage(canvas,sx,sy,sw,sh,dx,dy,dw,dh);
    };

    var copyGhostSprite = function(destCtx,x,y,frame,dirEnum,scared,flash,eyes_only,color) {
        var row,col;
        if (eyes_only) {
            row = 5;
            col = dirEnum;
        }
        else if (scared) {
            row = 5;
            col = flash ? 6 : 4;
            col += frame;
        }
        else {
            col = dirEnum*2 + frame;
            if (color == blinky.color) {
                row = 1;
            }
            else if (color == pinky.color) {
                row = 2;
            }
            else if (color == inky.color) {
                row = 3;
            }
            else if (color == clyde.color) {
                row = 4;
            }
            else {
                row = 5;
            }
        }


        copyCellTo(row, col, destCtx, x, y);
    };

    var copyPacmanSprite = function(destCtx,x,y,dirEnum,frame) {
        var row = 6;
        var col;
        if (frame == 0) {
            col = 0;
        }
        else {
           col = dirEnum*2+1+(frame-1);
        }
        copyCellTo(row,col,destCtx,x,y);
    };

    var copyMsPacmanSprite = function(destCtx,x,y,dirEnum,frame) {
        // TODO: determine row, col
        //copyCellTo(row,col,destCtx,x,y);
        var row = 7;
        var col = dirEnum*3+frame;
        copyCellTo(row,col,destCtx,x,y);
    };

    var copyCookiemanSprite = function(destCtx,x,y,dirEnum,frame) {
        var row = 8;
        var col = dirEnum*3+frame;
        copyCellTo(row,col,destCtx,x,y);
    };

    var copyFruitSprite = function(destCtx,x,y,name) {
        var row = 0;
        var col = {
            "cherry": 0,
            "strawberry": 1,
            "orange": 2,
            "apple": 3,
            "melon": 4,
            "galaxian": 5,
            "bell": 6,
            "key": 7,
            "pretzel": 8,
            "pear": 9,
            "banana": 10,
            "cookie": 11,
        }[name];

        copyCellTo(row,col,destCtx,x,y);
    };

    return {
        create: create,
        getCanvas: function() { return canvas; },
        drawGhostSprite: copyGhostSprite,
        drawPacmanSprite: copyPacmanSprite,
        drawMsPacmanSprite: copyMsPacmanSprite,
        drawCookiemanSprite: copyCookiemanSprite,
        drawFruitSprite: copyFruitSprite,
    };
})();
//@line 1 "src/renderers.js"
//////////////////////////////////////////////////////////////
// Renderers

// Draws everything in the game using swappable renderers
// to enable to different front-end displays for Pac-Man.

// list of available renderers
var renderer_list;

// current renderer
var renderer;

var renderScale;

var mapMargin = 4*tileSize; // margin between the map and the screen
var mapPad = tileSize/8; // padding between the map and its clipping

var mapWidth = 28*tileSize+mapPad*2;
var mapHeight = 36*tileSize+mapPad*2;

var screenWidth = mapWidth+mapMargin*2;
var screenHeight = mapHeight+mapMargin*2;

// all rendering will be shown on this canvas
var canvas;

// switch to the given renderer index
var switchRenderer = function(i) {
    renderer = renderer_list[i];
    renderer.drawMap();
};

var initRenderer = function(){

    var bgCanvas;
    var ctx, bgCtx;

    // drawing scale
    var scale = 2;        // scale everything by this amount

    // (temporary global version of scale just to get things quickly working)
    renderScale = scale; 

    var resets = 0;

    // rescale the canvases
    var resetCanvasSizes = function() {
        canvas.width = screenWidth * scale;
        canvas.height = screenHeight * scale;
        if (resets > 0) {
            ctx.restore();
        }
        ctx.save();
        ctx.scale(scale,scale);

        bgCanvas.width = mapWidth * scale;
        bgCanvas.height = mapHeight * scale;
        if (resets > 0) {
            bgCtx.restore();
        }
        bgCtx.save();
        bgCtx.scale(scale,scale);

        resets++;
    };

    // get the target scale that will cause the canvas to fit the window
    var getTargetScale = function() {
        var sx = (window.innerWidth - 10) / screenWidth;
        var sy = (window.innerHeight - 10) / screenHeight;
        return Math.min(sx,sy);
    };

    // maximize the scale to fit the window
    var fullscreen = function() {
        // NOTE: css-scaling alternative at https://gist.github.com/1184900
        renderScale = scale = getTargetScale();
        resetCanvasSizes();
        atlas.create();
        if (renderer) {
            renderer.drawMap();
        }
        center();
    };

    // center the canvas in the window
    var center = function() {
        var s = getTargetScale();
        var w = screenWidth*s;
        var x = Math.max(0,(window.innerWidth-10)/2 - w/2);
        var y = 0;
        canvas.style.left = x;
        canvas.style.top = y;
        canvas.style.position = "absolute";
    };

    // create foreground and background canvases
    canvas = document.getElementById('canvas');
    bgCanvas = document.createElement('canvas');
    ctx = canvas.getContext("2d");
    bgCtx = bgCanvas.getContext("2d");

    // initialize placement and size
    fullscreen();

    // adapt placement and size to window resizes
    var resizeTimeout;
    window.addEventListener('resize', function () {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(fullscreen, 100);
    }, false);

    //////////////////////

    var beginMapFrame = function() {
        bgCtx.fillStyle = "#000";
        bgCtx.fillRect(0,0,mapWidth,mapHeight);
        bgCtx.translate(mapPad, mapPad);
    };

    var endMapFrame = function() {
        bgCtx.translate(-mapPad, -mapPad);
    };

    //////////////////////////////////////////////////////////////
    // Common Renderer
    // (attributes and functionality that are currently common to all renderers)

    // constructor
    var CommonRenderer = function() {
        this.actorSize = (tileSize-1)*2;
        this.energizerSize = tileSize+2;
        this.pointsEarnedTextSize = tileSize;

        this.energizerColor = "#FFF";
        this.pelletColor = "#888";

        this.flashLevel = false;
    };

    CommonRenderer.prototype = {

        setOverlayColor: function(color) {
            this.overlayColor = color;
        },

        beginMapClip: function() {
            ctx.save();
            ctx.beginPath();

            // subtract one from size due to shift done for sprite realignment?
            // (this fixes a bug that leaves unerased artifacts after actors use right-side tunnel
            ctx.rect(-mapPad,-mapPad,mapWidth-1,mapHeight-1); 

            ctx.clip();
        },

        endMapClip: function() {
            ctx.restore();
        },

        beginFrame: function() {
            this.setOverlayColor(executive.isPaused() ? "rgba(0,0,0,0.5)" : undefined);
            ctx.save();

            // clear margin area
            ctx.fillStyle = "#000";
            ctx.fillRect(0,0,screenWidth,mapMargin);
            ctx.fillRect(0,mapMargin,mapMargin,screenHeight-2*mapMargin);
            ctx.fillRect(screenWidth-mapMargin-1,mapMargin,mapMargin+1,screenHeight-2*mapMargin);
            ctx.fillRect(0,screenHeight-1-mapMargin,screenWidth,mapMargin+1);


            // draw fps
            ctx.font = (tileSize-2) + "px ArcadeR";
            ctx.textBaseline = "top";
            ctx.textAlign = "left";
            ctx.fillStyle = "#777";
            ctx.fillText(executive.getFps().toFixed(2)+" FPS", 2, 2);

            // translate to map space
            ctx.translate(mapMargin+mapPad, mapMargin+mapPad);
        },

        endFrame: function() {
            if (executive.isPaused()) {
                renderer.drawMessage("PAUSED", "#fff");
            }
            ctx.restore();
            if (this.overlayColor != undefined) {
                ctx.fillStyle = this.overlayColor;
                ctx.fillRect(0,0,screenWidth,screenHeight);
            }
        },

        renderFunc: function(f,that) {
            if (that) {
                f.call(that,ctx);
            }
            else {
                f(ctx);
            }
        },

        // scaling the canvas can incur floating point roundoff errors
        // which manifest as "grout" between tiles that are otherwise adjacent in integer-space
        // This function extends the width and height of the tile if it is adjacent to equivalent tiles
        // that are to the bottom or right of the given tile
        drawNoGroutTile: function(ctx,x,y,w) {
            var tileChar = map.getTile(x,y);
            this.drawCenterTileSq(ctx,x,y,tileSize,
                    map.getTile(x+1,y) == tileChar,
                    map.getTile(x,y+1) == tileChar,
                    map.getTile(x+1,y+1) == tileChar);
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

        setLevelFlash: function(on) {
            if (on != this.flashLevel) {
                this.flashLevel = on;
                this.drawMap();
            }
        },

        // draw the target visualizers for each actor
        drawTargets: function() {
            var i;
            ctx.strokeStyle = "rgba(255,255,255,0.5)";
            ctx.lineWidth = "1.5";
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            for (i=0;i<5;i++)
                if (actors[i].isDrawTarget)
                    actors[i].drawTarget(ctx);
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
            ctx.strokeStyle = actor.pathColor;
            ctx.lineWidth = "2.0";
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.beginPath();
            ctx.moveTo(
                    actor.pixel.x+actor.pathCenter.x,
                    actor.pixel.y+actor.pathCenter.y);
            ctx.lineTo(
                    pixel.x+actor.pathCenter.x,
                    pixel.y+actor.pathCenter.y);

            if (tile.x == target.x && tile.y == target.y) {
                // adjust the distance left to create a smoothly interpolated path end
                distLeft = actor.getPathDistLeft(pixel, dirEnum);
            }
            else while (true) {

                // predict next turn from current tile
                openTiles = getOpenTiles(tile, dirEnum);
                if (actor != pacman && map.constrainGhostTurns)
                    map.constrainGhostTurns(tile, openTiles);
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
                ctx.lineTo(
                        tile.x*tileSize+midTile.x+actor.pathCenter.x,
                        tile.y*tileSize+midTile.y+actor.pathCenter.y);
            }

            // calculate final endpoint
            var px = pixel.x+actor.pathCenter.x+distLeft*dir.x;
            var py = pixel.y+actor.pathCenter.y+distLeft*dir.y;

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
        },

        // erase pellet from background
        erasePellet: function(x,y) {
            bgCtx.translate(mapPad,mapPad);
            bgCtx.fillStyle = this.floorColor;
            this.drawNoGroutTile(bgCtx,x,y,tileSize);

            // fill in adjacent floor tiles
            if (map.getTile(x+1,y)==' ') this.drawNoGroutTile(bgCtx,x+1,y,tileSize);
            if (map.getTile(x-1,y)==' ') this.drawNoGroutTile(bgCtx,x-1,y,tileSize);
            if (map.getTile(x,y+1)==' ') this.drawNoGroutTile(bgCtx,x,y+1,tileSize);
            if (map.getTile(x,y-1)==' ') this.drawNoGroutTile(bgCtx,x,y-1,tileSize);

            // TODO: fill in adjacent wall tiles?

            bgCtx.translate(-mapPad,-mapPad);
        },

        // draw a center screen message (e.g. "start", "ready", "game over")
        drawMessage: function(text, color) {
            ctx.font = tileSize + "px ArcadeR";
            ctx.textBaseline = "middle";
            ctx.textAlign = "center";
            ctx.strokeStyle = "#000";
            ctx.lineWidth = 2;
            ctx.strokeText(text, map.numCols*tileSize/2, this.messageRow*tileSize+midTile.y);
            ctx.fillStyle = color;
            ctx.fillText(text, map.numCols*tileSize/2, this.messageRow*tileSize+midTile.y);
        },

        // draw the points earned from the most recently eaten ghost
        drawEatenPoints: function() {
            var text = energizer.getPoints();
            ctx.font = this.pointsEarnedTextSize + "px sans-serif";
            ctx.textBaseline = "middle";
            ctx.textAlign = "center";
            ctx.fillStyle = "#0FF";
            ctx.fillText(text, pacman.pixel.x, pacman.pixel.y);
        },

        // draw each actor (ghosts and pacman)
        drawActors: function() {
            var i;
            // draw such that pacman appears on top
            if (energizer.isActive()) {
                for (i=0; i<4; i++)
                    this.drawGhost(ghosts[i]);
                if (!energizer.showingPoints())
                    this.drawPlayer();
                else
                    this.drawEatenPoints();
            }
            // draw such that pacman appears on bottom
            else {
                this.drawPlayer();
                for (i=3; i>=0; i--) 
                    this.drawGhost(ghosts[i]);
            }
        },

    };

    //////////////////////////////////////////////////////////////
    // Simple Renderer
    // (render a minimal Pac-Man display using nothing but squares)

    // constructor
    var SimpleRenderer = function() {

        // inherit attributes from Common Renderer
        CommonRenderer.call(this,ctx,bgCtx);

        this.messageRow = 21.7;
        this.pointsEarnedTextSize = 1.5*tileSize;

        this.backColor = "#222";
        this.floorColor = "#444";
        this.flashFloorColor = "#999";

        this.name = "Minimal";
    };

    SimpleRenderer.prototype = {

        // inherit functions from Common Renderer
        __proto__: CommonRenderer.prototype,

        drawMap: function() {

            beginMapFrame();

            var x,y;
            var i;
            var tile;

            // draw floor tiles
            bgCtx.fillStyle = (this.flashLevel ? this.flashFloorColor : this.floorColor);
            i=0;
            for (y=0; y<map.numRows; y++)
            for (x=0; x<map.numCols; x++) {
                tile = map.currentTiles[i++];
                if (tile == ' ')
                    this.drawNoGroutTile(bgCtx,x,y,tileSize);
            }

            // draw pellet tiles
            bgCtx.fillStyle = this.pelletColor;
            i=0;
            for (y=0; y<map.numRows; y++)
            for (x=0; x<map.numCols; x++) {
                tile = map.currentTiles[i++];
                if (tile == '.')
                    this.drawNoGroutTile(bgCtx,x,y,tileSize);
            }

            endMapFrame();
        },

        refreshPellet: function(x,y) {
            var i = map.posToIndex(x,y);
            var tile = map.currentTiles[i];
            if (tile == ' ') {
                this.erasePellet(x,y);
            }
            else if (tile == '.') {
                bgCtx.fillStyle = this.pelletColor;
                this.drawNoGroutTile(bgCtx,x,y,tileSize);
            }
        },


        // draw the current score and high score
        drawScore: function() {
            ctx.font = 1.5*tileSize + "px sans-serif";
            ctx.textBaseline = "top";
            ctx.textAlign = "left";
            ctx.fillStyle = "#FFF";
            ctx.fillText(score, tileSize, tileSize*2);

            ctx.font = "bold " + 1.5*tileSize + "px sans-serif";
            ctx.textBaseline = "top";
            ctx.textAlign = "center";
            ctx.fillText("high score", tileSize*map.numCols/2, 3);
            ctx.fillText(highScore, tileSize*map.numCols/2, tileSize*2);
        },

        // draw the extra lives indicator
        drawExtraLives: function() {
            var i;
            ctx.fillStyle = "rgba(255,255,0,0.6)";
            for (i=0; i<extraLives; i++)
                this.drawCenterPixelSq(ctx, (2*i+3)*tileSize, (map.numRows-2)*tileSize+midTile.y,this.actorSize);
        },

        // draw the current level indicator
        drawLevelIcons: function() {
            var i;
            ctx.fillStyle = "rgba(255,255,255,0.5)";
            var w = 2;
            var h = this.actorSize;
            for (i=0; i<level; i++)
                ctx.fillRect((map.numCols-2)*tileSize - i*2*w, (map.numRows-2)*tileSize+midTile.y-h/2, w, h);
        },

        // draw energizer items on foreground
        drawEnergizers: function() {
            ctx.fillStyle = this.energizerColor;
            var e;
            var i;
            for (i=0; i<map.numEnergizers; i++) {
                e = map.energizers[i];
                if (map.currentTiles[e.x+e.y*map.numCols] == 'o')
                    this.drawCenterTileSq(ctx,e.x,e.y,this.energizerSize);
            }
        },

        // draw pacman
        drawPlayer: function(scale, opacity) {
            if (scale == undefined) scale = 1;
            if (opacity == undefined) opacity = 1;
            ctx.fillStyle = "rgba(255,255,0,"+opacity+")";
            this.drawCenterPixelSq(ctx, pacman.pixel.x, pacman.pixel.y, this.actorSize*scale);
        },

        // draw dying pacman animation (with 0<=t<=1)
        drawDyingPlayer: function(t) {
            var f = t*85;
            if (f <= 60) {
                t = f/60;
                this.drawPlayer(1-t);
            }
            else {
                f -= 60;
                t = f/15;
                this.drawPlayer(t,1-t);
            }
        },

        // draw ghost
        drawGhost: function(g) {
            if (g.mode == GHOST_EATEN)
                return;
            var color = g.color;
            if (g.scared)
                color = energizer.isFlash() ? "#FFF" : "#2121ff";
            else if (g.mode == GHOST_GOING_HOME || g.mode == GHOST_ENTERING_HOME)
                color = "rgba(255,255,255,0.3)";
            ctx.fillStyle = color;
            this.drawCenterPixelSq(ctx, g.pixel.x, g.pixel.y, this.actorSize);
        },

        drawFruit: function() {
            if (fruit.isPresent()) {
                ctx.fillStyle = "#0F0";
                this.drawCenterPixelSq(ctx, fruit.pixel.x, fruit.pixel.y, tileSize+2);
            }
            else if (fruit.isScorePresent()) {
                ctx.font = this.pointsEarnedTextSize + "px sans-serif";
                ctx.textBaseline = "middle";
                ctx.textAlign = "center";
                ctx.fillStyle = "#FFF";
                ctx.fillText(fruit.getPoints(), fruit.pixel.x, fruit.pixel.y);
            }
        },

    };


    //////////////////////////////////////////////////////////////
    // Arcade Renderer
    // (render a display close to the original arcade)

    // constructor
    var ArcadeRenderer = function(ctx,bgCtx) {

        // inherit attributes from Common Renderer
        CommonRenderer.call(this,ctx,bgCtx);

        this.messageRow = 20;
        this.pelletSize = 2;
        this.energizerSize = tileSize;

        this.backColor = "#000";
        this.floorColor = "#000";
        this.flashWallColor = "#FFF";

        this.name = "Arcade";
    };

    ArcadeRenderer.prototype = {

        // inherit functions from Common Renderer
        __proto__: CommonRenderer.prototype,

        // copy background canvas to the foreground canvas
        blitMap: function() {
            ctx.scale(1/scale,1/scale);
            ctx.drawImage(bgCanvas,-1-mapPad*scale,-1-mapPad*scale); // offset map to compenstate for misalignment
            ctx.scale(scale,scale);
            //ctx.clearRect(-mapPad,-mapPad,mapWidth,mapHeight);
        },

        drawMap: function() {

            if (!map) {
                return;
            }

            // fill background
            beginMapFrame();

            var x,y;
            var i,j;
            var tile;

            // ghost house door
            i=0;
            for (y=0; y<map.numRows; y++)
            for (x=0; x<map.numCols; x++) {
                if (map.currentTiles[i] == '-' && map.currentTiles[i+1] == '-') {
                    bgCtx.fillStyle = "#ffb8de";
                    bgCtx.fillRect(x*tileSize,y*tileSize+tileSize-2,tileSize*2,2);
                }
                i++;
            }

            if (this.flashLevel) {
                bgCtx.fillStyle = "#000";
                bgCtx.strokeStyle = "#fff";
            }
            else {
                bgCtx.fillStyle = map.wallFillColor;
                bgCtx.strokeStyle = map.wallStrokeColor;
            }
            for (i=0; i<map.paths.length; i++) {
                var path = map.paths[i];
                bgCtx.beginPath();
                bgCtx.moveTo(path[0].x, path[0].y);
                for (j=1; j<path.length; j++) {
                    if (path[j].cx != undefined)
                        bgCtx.quadraticCurveTo(path[j].cx, path[j].cy, path[j].x, path[j].y);
                    else
                        bgCtx.lineTo(path[j].x, path[j].y);
                }
                bgCtx.quadraticCurveTo(path[j-1].x, path[0].y, path[0].x, path[0].y);
                bgCtx.fill();
                bgCtx.stroke();
            }

            // draw pellet tiles
            bgCtx.fillStyle = map.pelletColor;
            i=0;
            for (y=0; y<map.numRows; y++)
            for (x=0; x<map.numCols; x++) {
                this.refreshPellet(x,y,true);
            }

            // draw level fruit
            var fruits = fruit.getFruitHistory();
            var i,j;
            var f,drawFunc;
            var numFruit = 7;
            var startLevel = Math.max(numFruit,level);
            if (gameMode != GAME_PACMAN) {
                // for the Pac-Man game, display the last 7 fruit
                // for the Ms Pac-Man game, display stop after the 7th fruit
                startLevel = Math.min(numFruit,startLevel);
            }
            var scale = 0.85;
            for (i=0, j=startLevel-numFruit+1; i<numFruit && j<=level; j++, i++) {
                f = fruits[j];
                if (f) {
                    drawFunc = getSpriteFuncFromFruitName(f.name);
                    if (drawFunc) {
                        bgCtx.save();
                        bgCtx.translate((map.numCols-3)*tileSize - i*16*scale, (map.numRows-1)*tileSize);
                        bgCtx.scale(scale,scale);
                        drawFunc(bgCtx,0,0);
                        bgCtx.restore();
                    }
                }
            }
            bgCtx.font = (tileSize-1) + "px ArcadeR";
            bgCtx.textBaseline = "middle";
            bgCtx.fillStyle = "#777";
            bgCtx.textAlign = "left";
            bgCtx.fillText(level,(map.numCols-2)*tileSize, (map.numRows-1)*tileSize);

            // draw extra lives
            var i;
            bgCtx.fillStyle = pacman.color;

            bgCtx.save();
            bgCtx.translate(3*tileSize, (map.numRows-1)*tileSize);
            bgCtx.scale(0.85, 0.85);
            if (gameMode == GAME_PACMAN) {
                for (i=0; i<extraLives; i++) {
                    drawPacmanSprite(bgCtx, 0,0, DIR_LEFT, Math.PI/6);
                    bgCtx.translate(2*tileSize,0);
                }
            }
            else if (gameMode == GAME_MSPACMAN) {
                for (i=0; i<extraLives; i++) {
                    drawMsPacmanSprite(bgCtx, 0,0, DIR_RIGHT, 1);
                    bgCtx.translate(2*tileSize,0);
                }
            }
            else if (gameMode == GAME_COOKIE) {
                for (i=0; i<extraLives; i++) {
                    drawCookiemanSprite(bgCtx, 0,0, DIR_RIGHT, 1, false);
                    bgCtx.translate(2*tileSize,0);
                }
            }
            bgCtx.restore();

            // draw text
            bgCtx.font = (tileSize-1) + "px ArcadeR";
            bgCtx.textBaseline = "top";
            bgCtx.fillStyle = "#FFF";

            bgCtx.textAlign = "left";
            bgCtx.fillText("1UP", 3*tileSize, 0);
            bgCtx.fillText("HIGH SCORE", 9*tileSize, 0);

            endMapFrame();
        },

        erasePellet: function(x,y,isTranslated) {
            if (!isTranslated) {
                bgCtx.translate(mapPad,mapPad);
            }
            bgCtx.fillStyle = "#000";
            var i = map.posToIndex(x,y);
            var size = map.tiles[i] == 'o' ? this.energizerSize : this.pelletSize;
            this.drawCenterTileSq(bgCtx,x,y,size+2);
            if (!isTranslated) {
                bgCtx.translate(-mapPad,-mapPad);
            }
        },

        refreshPellet: function(x,y,isTranslated) {
            if (!isTranslated) {
                bgCtx.translate(mapPad,mapPad);
            }
            var i = map.posToIndex(x,y);
            var tile = map.currentTiles[i];
            if (tile == ' ') {
                this.erasePellet(x,y,isTranslated);
            }
            else if (tile == '.') {
                bgCtx.fillStyle = map.pelletColor;
                bgCtx.translate(0.5, 0.5);
                this.drawCenterTileSq(bgCtx,x,y,this.pelletSize);
                bgCtx.translate(-0.5, -0.5);
            }
            else if (tile == 'o') {
                bgCtx.fillStyle = map.pelletColor;
                bgCtx.beginPath();
                bgCtx.arc(x*tileSize+midTile.x+0.5,y*tileSize+midTile.y,this.energizerSize/2,0,Math.PI*2);
                bgCtx.fill();
            }
            if (!isTranslated) {
                bgCtx.translate(-mapPad,-mapPad);
            }
        },

        // draw the current score and high score
        drawScore: function() {
            ctx.font = (tileSize-1) + "px ArcadeR";
            ctx.textBaseline = "top";
            ctx.fillStyle = "#FFF";

            ctx.textAlign = "right";
            ctx.fillText(score, 7*tileSize, tileSize);
            ctx.fillText(highScore, 17*tileSize, tileSize);
        },

        // draw ghost
        drawGhost: function(g) {
            if (g.mode == GHOST_EATEN)
                return;
            var frame = Math.floor(g.frames/8)%2; // toggle frame every 8 ticks
            var eyes = (g.mode == GHOST_GOING_HOME || g.mode == GHOST_ENTERING_HOME);
            //drawGhostSprite(ctx,g.pixel.x,g.pixel.y,frame,g.dirEnum,g.scared,energizer.isFlash(),eyes,g.color);
            atlas.drawGhostSprite(ctx,g.pixel.x,g.pixel.y,frame,g.faceDirEnum,g.scared,energizer.isFlash(),eyes,g.color);
        },

        // get animation frame for player
        getPlayerAnimFrame: function() {
            var frame = Math.floor(pacman.steps/2)%4; // change animation frame every 2 steps
            if (gameMode == GAME_MSPACMAN || gameMode == GAME_COOKIE) { // ms. pacman starts with mouth open
                frame = (frame+1)%4;
                if (state == deadState)
                    frame = 1; // hack to force this frame when dead
            }
            if (frame == 3) 
                frame = 1;
            return frame;
        },

        // draw pacman
        drawPlayer: function() {
            var frame = this.getPlayerAnimFrame();
            if (pacman.invincible) {
                ctx.globalAlpha = 0.6;
            }
            if (gameMode == GAME_PACMAN) {
                //drawPacmanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum, frame*Math.PI/6);
                atlas.drawPacmanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum, frame);
            }
            else if (gameMode == GAME_MSPACMAN) {
                //drawMsPacmanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum,frame);
                atlas.drawMsPacmanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum,frame);
            }
            else if (gameMode == GAME_COOKIE) {
                //drawCookiemanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum,frame,true);
                atlas.drawCookiemanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum,frame);
            }
            if (pacman.invincible) {
                ctx.globalAlpha = 1;
            }
        },

        // draw dying pacman animation (with 0<=t<=1)
        drawDyingPlayer: function(t) {
            var frame = this.getPlayerAnimFrame();

            if (gameMode == GAME_PACMAN) {
                // 60 frames dying
                // 15 frames exploding
                var f = t*75;
                if (f <= 60) {
                    // open mouth all the way while shifting corner of mouth forward
                    t = f/60;
                    var a = frame*Math.PI/6;
                    drawPacmanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum, a + t*(Math.PI-a),4*t);
                }
                else {
                    // explode
                    f -= 60;
                    this.drawExplodingPlayer(f/15);
                }
            }
            else if (gameMode == GAME_MSPACMAN) {
                // spin 540 degrees
                var maxAngle = Math.PI*5;
                var step = (Math.PI/4) / maxAngle; // 45 degree steps
                var angle = Math.floor(t/step)*step*maxAngle;
                drawMsPacmanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum, frame, angle);
            }
            else if (gameMode == GAME_COOKIE) {
                // spin 540 degrees
                var maxAngle = Math.PI*5;
                var step = (Math.PI/4) / maxAngle; // 45 degree steps
                var angle = Math.floor(t/step)*step*maxAngle;
                drawCookiemanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum, frame, false, angle);
            }
        },

        // draw exploding pacman animation (with 0<=t<=1)
        drawExplodingPlayer: function(t) {
            var frame = this.getPlayerAnimFrame();
            drawPacmanSprite(ctx, pacman.pixel.x, pacman.pixel.y, pacman.dirEnum, 0, 0, t,-3,1-t);
        },

        // draw fruit
        drawFruit: function() {
            if (fruit.isPresent()) {
                var name = fruit.getCurrentFruit().name;
                var drawFunc = getSpriteFuncFromFruitName(name);
                //drawFunc(ctx,fruit.pixel.x, fruit.pixel.y);
                atlas.drawFruitSprite(ctx,fruit.pixel.x, fruit.pixel.y, name);
            }
            else if (fruit.isScorePresent()) {
                ctx.font = this.pointsEarnedTextSize + "px sans-serif";
                ctx.textBaseline = "middle";
                ctx.textAlign = "center";
                ctx.fillStyle = "#FFF";
                ctx.fillText(fruit.getPoints(), fruit.pixel.x, fruit.pixel.y);
            }
        },

    };

    //
    // Create list of available renderers
    //
    renderer_list = [
        new SimpleRenderer(),
        new ArcadeRenderer(),
    ];
    renderer = renderer_list[1];
};
//@line 1 "src/gui.js"
var getmousepos = function(evt) {
    var obj = canvas;
    var top = 0;
    var left = 0;
    while (obj.tagName != 'BODY') {
        top += obj.offsetTop;
        left += obj.offsetLeft;
        obj = obj.offsetParent;
    }

    // calculate relative mouse position
    var mouseX = evt.clientX - left + window.pageXOffset;
    var mouseY = evt.clientY - top + window.pageYOffset;

    // make independent of scale
    mouseX /= renderScale;
    mouseY /= renderScale;

    // offset
    mouseX -= mapMargin;
    mouseY -= mapMargin;

    return { x: mouseX, y: mouseY };
};

var ComboBox = function(x,y,w,h,options) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;

    this.options = options;

    this.enable = function() {
    };

    this.disable = function() {
    };
};

ComboBox.prototype = {

    draw: function(ctx) {
    },

};

var Button = function(x,y,w,h,onclick) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.onclick = onclick;

    this.borderBlurColor = "#555";
    this.borderFocusColor = "#EEE";

    this.isHover = false;

    var that = this;
    var click = function(evt) {
        var pos = getmousepos(evt);
        if (that.onclick && that.contains(pos.x, pos.y)) {
            that.onclick();
        }
    };
    var mousemove = function(evt) {
        var pos = getmousepos(evt);
        that.contains(pos.x, pos.y) ? that.focus() : that.blur();
    };
    var mouseleave = function(evt) {
        that.blur();
    };

    this.enable = function() {
        canvas.addEventListener('click', click);
        canvas.addEventListener('mousemove', mousemove);
        canvas.addEventListener('mouseleave', mouseleave);
    };

    this.disable = function() {
        canvas.removeEventListener('click', click);
        canvas.removeEventListener('mousemove', mousemove);
        canvas.removeEventListener('mouseleave', mouseleave);
    };
};

Button.prototype = {

    contains: function(x,y) {
        return x >= this.x && x <= this.x+this.w &&
               y >= this.y && y <= this.y+this.h;
    },

    focus: function() {
        this.isHover = true;
    },

    blur: function() {
        this.isHover = false;
    },

    draw: function(ctx) {
        ctx.fillStyle = "#000";
        ctx.strokeStyle = "#000";
        ctx.fillRect(this.x,this.y,this.w,this.h);
        ctx.strokeRect(this.x,this.y,this.w,this.h);

        ctx.strokeStyle = this.isHover ? this.borderFocusColor : this.borderBlurColor;
        //ctx.strokeRect(this.x,this.y,this.w,this.h);
        ctx.beginPath();
        var x=this.x, y=this.y, w=this.w, h=this.h;
        var r=h/4;
        ctx.moveTo(x,y+r);
        ctx.quadraticCurveTo(x,y,x+r,y);
        ctx.lineTo(x+w-r,y);
        ctx.quadraticCurveTo(x+w,y,x+w,y+r);
        ctx.lineTo(x+w,y+h-r);
        ctx.quadraticCurveTo(x+w,y+h,x+w-r,y+h);
        ctx.lineTo(x+r,y+h);
        ctx.quadraticCurveTo(x,y+h,x,y+h-r);
        ctx.closePath();
        ctx.stroke();
    },

    update: function() {
    },
};

var TextButton = function(x,y,w,h,onclick,msg,font,fontcolor) {
    Button.call(this,x,y,w,h,onclick);
    this.msg = msg;
    this.font = font;
    this.fontcolor = fontcolor;
    this.pad = tileSize;
};

TextButton.prototype = {

    __proto__: Button.prototype,

    draw: function(ctx) {
        Button.prototype.draw.call(this,ctx);
        ctx.font = this.font;
        ctx.fillStyle = this.isHover ? this.fontcolor : "#777";
        ctx.textBaseline = "middle";
        ctx.textAlign = "center";
        //ctx.fillText(this.msg, 2*tileSize+2*this.pad+this.x, this.y + this.h/2 + 1);
        ctx.fillText(this.msg, this.x + this.w/2, this.y + this.h/2 + 1);

    },
};

var TextIconButton = function(x,y,w,h,onclick,msg,font,fontcolor,drawIcon) {
    TextButton.call(this,x,y,w,h,onclick,msg,font,fontcolor);
    this.drawIcon = drawIcon;
    this.frame = 0;
};

TextIconButton.prototype = {

    __proto__: TextButton.prototype,

    draw: function(ctx) {
        TextButton.prototype.draw.call(this,ctx);
        this.drawIcon(ctx,this.x+this.pad+tileSize,this.y+this.h/2,this.frame);
    },

    update: function() {
        TextButton.prototype.update.call(this);
        this.frame = this.isHover ? this.frame+1 : 0;
    },
};
//@line 1 "src/Menu.js"
var Menu = function(x,y,w,h,pad,font,fontcolor) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.pad = pad;
    this.buttons = [];
    this.buttonCount = 0;

    this.font = font;
    this.fontcolor = fontcolor;
};

Menu.prototype = {

    addTextButton: function(msg,onclick) {
        var x = this.x + this.pad;
        var y = this.y + this.pad + (this.pad + this.h) * this.buttonCount;
        this.buttons.push(new TextButton(x,y,this.w,this.h,onclick,msg,this.font,this.fontcolor));
        this.buttonCount++;
    },

    addTextIconButton: function(msg,onclick,drawIcon) {
        var x = this.x + this.pad;
        var y = this.y + this.pad + (this.pad + this.h) * this.buttonCount;
        this.buttons.push(new TextIconButton(x,y,this.w,this.h,onclick,msg,this.font,this.fontcolor,drawIcon));
        this.buttonCount++;
    },

    enable: function() {
        var i;
        for (i=0; i<this.buttonCount; i++) {
            this.buttons[i].enable();
        }
    },

    disable: function() {
        var i;
        for (i=0; i<this.buttonCount; i++) {
            this.buttons[i].disable();
        }
    },

    draw: function(ctx) {
        var i;
        for (i=0; i<this.buttonCount; i++) {
            this.buttons[i].draw(ctx);
        }
    },

    update: function() {
        var i;
        for (i=0; i<this.buttonCount; i++) {
            this.buttons[i].update();
        }
    },
};
//@line 1 "src/sprites.js"
//////////////////////////////////////////////////////////////////////////////////////
// Sprites
// (sprites are created using canvas paths)

var drawGhostSprite = (function(){

    // add top of the ghost head to the current canvas path
    var addHead = (function() {

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

            ctx.moveTo(0,6);
            ctx.quadraticCurveTo(1.5,0,6.5,0);
            ctx.quadraticCurveTo(11.5,0,13,6);

            // draw lines between pixel coordinates
            /*
            ctx.moveTo(coords[0],coords[1]);
            for (i=2; i<coords.length; i+=2)
                ctx.lineTo(coords[i],coords[i+1]);
            */

            ctx.restore();
        };
    })();

    // add first ghost animation frame feet to the current canvas path
    var addFeet1 = (function(){

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
    var addFeet2 = (function(){

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
    var addEyes = function(ctx,dirEnum){
        var i;

        ctx.save();
        ctx.translate(2,3);

        var coords = [
            0,1,
            1,0,
            2,0,
            3,1,
            3,3,
            2,4,
            1,4,
            0,3
        ];

        var drawEyeball = function() {
            ctx.translate(0.5,0.5);
            ctx.beginPath();
            ctx.moveTo(coords[0],coords[1]);
            for (i=2; i<coords.length; i+=2)
                ctx.lineTo(coords[i],coords[i+1]);
            ctx.closePath();
            ctx.fill();
            ctx.lineJoin = 'round';
            ctx.stroke();
            ctx.translate(-0.5,-0.5);
            //ctx.fillRect(1,0,2,5); // left
            //ctx.fillRect(0,1,4,3);
        };

        // translate eye balls to correct position
        if (dirEnum == DIR_LEFT) ctx.translate(-1,0);
        else if (dirEnum == DIR_RIGHT) ctx.translate(1,0);
        else if (dirEnum == DIR_UP) ctx.translate(0,-1);
        else if (dirEnum == DIR_DOWN) ctx.translate(0,1);

        // draw eye balls
        ctx.fillStyle = "#FFF";
        ctx.strokeStyle = "#FFF";
        ctx.lineWidth = 1.0;
        ctx.lineJoin = 'round';
        drawEyeball();
        ctx.translate(6,0);
        drawEyeball();

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
    var addScaredFace = function(ctx,flash){
        ctx.strokeStyle = ctx.fillStyle = flash ? "#F00" : "#FF0";

        // eyes
        ctx.fillRect(4,5,2,2);
        ctx.fillRect(8,5,2,2);

        // mouth
        var coords = [
            1,10,
            2,9,
            3,9,
            4,10,
            5,10,
            6,9,
            7,9,
            8,10,
            9,10,
            10,9,
            11,9,
            12,10,
        ];
        ctx.translate(0.5,0.5);
        ctx.beginPath();
        ctx.moveTo(coords[0],coords[1]);
        for (i=2; i<coords.length; i+=2)
            ctx.lineTo(coords[i],coords[i+1]);
        ctx.lineWidth = 1.0;
        ctx.stroke();
        ctx.translate(-0.5,-0.5);
        /*
        ctx.fillRect(1,10,1,1);
        ctx.fillRect(12,10,1,1);
        ctx.fillRect(2,9,2,1);
        ctx.fillRect(6,9,2,1);
        ctx.fillRect(10,9,2,1);
        ctx.fillRect(4,10,2,1);
        ctx.fillRect(8,10,2,1);
        */
    };


    return function(ctx,x,y,frame,dirEnum,scared,flash,eyes_only,color) {
        ctx.save();
        ctx.translate(x-7,y-7);

        if (scared)
            color = flash ? "#FFF" : "#2121ff";

        if (!eyes_only) {
            // draw body
            ctx.beginPath();
            addHead(ctx);
            if (frame == 0)
                addFeet1(ctx);
            else
                addFeet2(ctx);
            ctx.closePath();
            ctx.lineJoin = 'round';
            ctx.lineCap = 'round';
            ctx.lineWidth = 0.5;
            ctx.strokeStyle = color;
            ctx.stroke();
            ctx.lineWidth = 1;
            ctx.fillStyle = color;
            ctx.fill();
        }

        // draw face
        if (scared)
            addScaredFace(ctx, flash);
        else
            addEyes(ctx,dirEnum);

        ctx.restore();
    };
})();

// draw pacman body
var drawPacmanSprite = function(ctx,x,y,dirEnum,angle,mouthShift,scale,centerShift,alpha,color,rot_angle) {

    if (mouthShift == undefined) mouthShift = 0;
    if (centerShift == undefined) centerShift = 0;
    if (scale == undefined) scale = 1;
    if (alpha == undefined) alpha = 1;

    if (color == undefined) {
        color = "rgba(255,255,0," + alpha + ")";
    }

    ctx.save();
    ctx.translate(x,y);
    if (rot_angle) {
        ctx.rotate(rot_angle);
    }

    // rotate to current heading direction
    var d90 = Math.PI/2;
    if (dirEnum == DIR_UP) ctx.rotate(3*d90);
    else if (dirEnum == DIR_RIGHT) ctx.rotate(0);
    else if (dirEnum == DIR_DOWN) ctx.rotate(d90);
    else if (dirEnum == DIR_LEFT) ctx.rotate(2*d90);

    // plant corner of mouth
    ctx.beginPath();
    ctx.moveTo(-3+mouthShift,0);

    // draw head outline
    ctx.arc(centerShift,0,6.5*scale,angle,2*Math.PI-angle);
    ctx.closePath();

    //ctx.strokeStyle = color;
    //ctx.stroke();
    ctx.fillStyle = color;
    ctx.fill();

    ctx.restore();
};

var drawMsPacmanSprite = function(ctx,x,y,dirEnum,frame,rot_angle) {
    var angle = 0;

    // draw body
    if (frame == 0) {
        // closed
        drawPacmanSprite(ctx,x,y,dirEnum,0,undefined,undefined,undefined,undefined,undefined,rot_angle);
    }
    else if (frame == 1) {
        // open
        angle = Math.atan(4/5);
        drawPacmanSprite(ctx,x,y,dirEnum,angle,undefined,undefined,undefined,undefined,undefined,rot_angle);
        angle = Math.atan(4/8); // angle for drawing eye
    }
    else if (frame == 2) {
        // wide
        angle = Math.atan(6/3);
        drawPacmanSprite(ctx,x,y,dirEnum,angle,undefined,undefined,undefined,undefined,undefined,rot_angle);
        angle = Math.atan(6/6); // angle for drawing eye
    }

    ctx.save();
    ctx.translate(x,y);
    if (rot_angle) {
        ctx.rotate(rot_angle);
    }

    // reflect or rotate sprite according to current direction
    var d90 = Math.PI/2;
    if (dirEnum == DIR_UP)
        ctx.rotate(-d90);
    else if (dirEnum == DIR_DOWN)
        ctx.rotate(d90);
    else if (dirEnum == DIR_LEFT)
        ctx.scale(-1,1);

    // bow
    var x=-7.5,y=-7.5;
    ctx.beginPath();
    ctx.arc(x+1,y+4,1.25,0,Math.PI*2);
    ctx.arc(x+2,y+5,1.25,0,Math.PI*2);
    ctx.arc(x+3,y+3,1.25,0,Math.PI*2);
    ctx.arc(x+4,y+1,1.25,0,Math.PI*2);
    ctx.arc(x+5,y+2,1.25,0,Math.PI*2);
    ctx.fillStyle = "#F00";
    ctx.fill();
    ctx.beginPath();
    ctx.arc(x+2.5,y+3.5,0.5,0,Math.PI*2);
    ctx.arc(x+3.5,y+2.5,0.5,0,Math.PI*2);
    ctx.fillStyle = "#0031FF";
    ctx.fill();

    // lips
    ctx.strokeStyle = "#F00";
    ctx.lineWidth = 1.25;
    ctx.lineCap = "butt";
    ctx.beginPath();
    if (frame == 0) {
        ctx.moveTo(5,0);
        ctx.lineTo(7,0);
        ctx.moveTo(6.5,-2);
        ctx.lineTo(6.5,2);
    }
    else {
        var r1 = 7;
        var r2 = 9;
        var c = Math.cos(angle);
        var s = Math.sin(angle);
        ctx.moveTo(-3+r1*c,r1*s);
        ctx.lineTo(-3+r2*c,r2*s);
        ctx.moveTo(-3+r1*c,-r1*s);
        ctx.lineTo(-3+r2*c,-r2*s);
    }
    ctx.stroke();

    // mole
    ctx.beginPath();
    ctx.arc(-3,2,0.5,0,Math.PI*2);
    ctx.fillStyle = "#000";
    ctx.fill();

    // eye
    ctx.strokeStyle = "#000";
    ctx.beginPath();
    if (frame == 0) {
        ctx.moveTo(-3,-2);
        ctx.lineTo(0,-2);
    }
    else {
        var r1 = 0;
        var r2 = 3;
        var c = Math.cos(angle);
        var s = Math.sin(angle);
        ctx.moveTo(-3+r1*c,-2-r1*s);
        ctx.lineTo(-3+r2*c,-2-r2*s);
    }
    ctx.stroke();

    ctx.restore();
};

var drawCookiemanSprite = (function(){

    var prevFrame = undefined;
    var sx1 = 0; // shift x for first pupil
    var sy1 = 0; // shift y for first pupil
    var sx2 = 0; // shift x for second pupil
    var sy2 = 0; // shift y for second pupil

    var er = 2.1; // eye radius
    var pr = 1; // pupil radius

    var movePupils = function() {
        var a1 = Math.random()*Math.PI*2;
        var a2 = Math.random()*Math.PI*2;
        var r1 = Math.random()*pr;
        var r2 = Math.random()*pr;

        sx1 = Math.cos(a1)*r1;
        sy1 = Math.sin(a1)*r1;
        sx2 = Math.cos(a2)*r2;
        sy2 = Math.sin(a2)*r2;
    };

    return function(ctx,x,y,dirEnum,frame,shake,rot_angle) {
        var angle = 0;

        // draw body
        var draw = function(angle) {
            //angle = Math.PI/6*frame;
            drawPacmanSprite(ctx,x,y,dirEnum,angle,undefined,undefined,undefined,undefined,"#47b8ff",rot_angle);
        };
        if (frame == 0) {
            // closed
            draw(0);
        }
        else if (frame == 1) {
            // open
            angle = Math.atan(4/5);
            draw(angle);
            angle = Math.atan(4/8); // angle for drawing eye
        }
        else if (frame == 2) {
            // wide
            angle = Math.atan(6/3);
            draw(angle);
            angle = Math.atan(6/6); // angle for drawing eye
        }

        ctx.save();
        ctx.translate(x,y);
        if (rot_angle) {
            ctx.rotate(rot_angle);
        }

        // reflect or rotate sprite according to current direction
        var d90 = Math.PI/2;
        if (dirEnum == DIR_UP)
            ctx.rotate(-d90);
        else if (dirEnum == DIR_DOWN)
            ctx.rotate(d90);
        else if (dirEnum == DIR_LEFT)
            ctx.scale(-1,1);

        var x = -4; // pivot point
        var y = -3.5;
        var r1 = 3;   // distance from pivot of first eye
        var r2 = 6; // distance from pivot of second eye
        angle /= 3; // angle from pivot point
        angle += Math.PI/8;
        var c = Math.cos(angle);
        var s = Math.sin(angle);

        if (shake) {
            if (frame != prevFrame) {
                movePupils();
            }
            prevFrame = frame;
        }

        // second eyeball
        ctx.beginPath();
        ctx.arc(x+r2*c, y-r2*s, er, 0, Math.PI*2);
        ctx.fillStyle = "#FFF";
        ctx.fill();
        // second pupil
        ctx.beginPath();
        ctx.arc(x+r2*c+sx2, y-r2*s+sy2, pr, 0, Math.PI*2);
        ctx.fillStyle = "#000";
        ctx.fill();

        // first eyeball
        ctx.beginPath();
        ctx.arc(x+r1*c, y-r1*s, er, 0, Math.PI*2);
        ctx.fillStyle = "#FFF";
        ctx.fill();
        // first pupil
        ctx.beginPath();
        ctx.arc(x+r1*c+sx1, y-r1*s+sy1, pr, 0, Math.PI*2);
        ctx.fillStyle = "#000";
        ctx.fill();

        ctx.restore();

    };
})();

////////////////////////////////////////////////////////////////////
// FRUIT SPRITES

var drawCherry = function(ctx,x,y) {

    // cherry
    var cherry = function(x,y) {
        ctx.save();
        ctx.translate(x,y);

        // red fruit
        ctx.beginPath();
        ctx.arc(2.5,2.5,3,0,Math.PI*2);
        ctx.lineWidth = 1.0;
        ctx.strokeStyle = "#000";
        ctx.stroke();
        ctx.fillStyle = "#ff0000";
        ctx.fill();

        // white shine
        ctx.lineCap = 'round';
        ctx.beginPath();
        ctx.moveTo(1,3);
        ctx.lineTo(2,4);
        ctx.strokeStyle = "#fff";
        ctx.stroke();
        ctx.restore();
    };

    ctx.save();
    ctx.translate(x,y);

    // draw both cherries
    cherry(-6,-1);
    cherry(-1,1);

    // draw stems
    ctx.beginPath();
    ctx.moveTo(-3,0);
    ctx.bezierCurveTo(-1,-2, 2,-4, 5,-5);
    ctx.lineTo(5,-4);
    ctx.bezierCurveTo(3,-4, 1,0, 1,2);
    ctx.strokeStyle = "#ff9900";
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';
    ctx.stroke();

    ctx.restore();
};

var drawStrawberry = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // red body
    ctx.beginPath();
    ctx.moveTo(-1,-4);
    ctx.bezierCurveTo(-3,-4,-5,-3, -5,-1);
    ctx.bezierCurveTo(-5,3,-2,5, 0,6);
    ctx.bezierCurveTo(3,5, 5,2, 5,0);
    ctx.bezierCurveTo(5,-3, 3,-4, 0,-4);
    ctx.fillStyle = "#f00";
    ctx.fill();
    ctx.strokeStyle = "#f00";
    ctx.stroke();

    // white spots
    var spots = [
        {x:-4,y:-1},
        {x:-3,y:2 },
        {x:-2,y:0 },
        {x:-1,y:4 },
        {x:0, y:2 },
        {x:0, y:0 },
        {x:2, y:4 },
        {x:2, y:-1 },
        {x:3, y:1 },
        {x:4, y:-2 } ];

    ctx.fillStyle = "#fff";
    var i,len;
    for (i=0, len=spots.length; i<len; i++) {
        var s = spots[i];
        ctx.beginPath();
        ctx.arc(s.x,s.y,0.75,0,2*Math.PI);
        ctx.fill();
    }

    // green leaf
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.lineTo(-3,-4);
    ctx.lineTo(0,-4);
    ctx.lineTo(-2,-3);
    ctx.lineTo(-1,-3);
    ctx.lineTo(0,-4);
    ctx.lineTo(0,-2);
    ctx.lineTo(0,-4);
    ctx.lineTo(1,-3);
    ctx.lineTo(2,-3);
    ctx.lineTo(0,-4);
    ctx.lineTo(3,-4);
    ctx.closePath();
    ctx.strokeStyle = "#00ff00";
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke();

    // stem
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.lineTo(0,-5);
    ctx.lineCap = 'round';
    ctx.strokeStyle = "#fff";
    ctx.stroke();
    ctx.restore();
};

var drawOrange = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // orange body
    ctx.beginPath();
    ctx.moveTo(-2,-2);
    ctx.bezierCurveTo(-3,-2, -5,-1, -5,1);
    ctx.bezierCurveTo(-5,4, -3,6, 0,6);
    ctx.bezierCurveTo(3,6, 5,4, 5,1);
    ctx.bezierCurveTo(5,-1, 3,-2, 2,-2);
    ctx.closePath();
    ctx.fillStyle="#ffcc33";
    ctx.fill();
    ctx.strokeStyle = "#ffcc33";
    ctx.stroke();

    // stem
    ctx.beginPath();
    ctx.moveTo(-1,-1);
    ctx.quadraticCurveTo(-1,-2,-2,-2);
    ctx.quadraticCurveTo(-1,-2,-1,-4);
    ctx.quadraticCurveTo(-1,-2,0,-2);
    ctx.quadraticCurveTo(-1,-2,-1,-1);
    ctx.strokeStyle = "#ff9900";
    ctx.lineJoin = 'round';
    ctx.stroke();

    // green leaf
    ctx.beginPath();
    ctx.moveTo(-0.5,-4);
    ctx.quadraticCurveTo(0,-5,1,-5);
    ctx.bezierCurveTo(2,-5, 3,-4,4,-4);
    ctx.bezierCurveTo(3,-4, 3,-3, 2,-3);
    ctx.bezierCurveTo(1,-3,1,-4,-0.5,-4);
    ctx.strokeStyle = "#00ff00";
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke();
    ctx.fillStyle = "#00ff00";
    ctx.fill();

    ctx.restore();
};

var drawApple = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // red fruit
    ctx.beginPath();
    ctx.moveTo(-2,-3);
    ctx.bezierCurveTo(-2,-4,-3,-4,-4,-4);
    ctx.bezierCurveTo(-5,-4,-6,-3,-6,0);
    ctx.bezierCurveTo(-6,3,-4,6,-2.5,6);
    ctx.quadraticCurveTo(-1,6,-1,5);
    ctx.bezierCurveTo(-1,6,0,6,1,6);
    ctx.bezierCurveTo(3,6, 5,3, 5,0);
    ctx.bezierCurveTo(5,-3, 3,-4, 2,-4);
    ctx.quadraticCurveTo(0,-4,0,-3);
    ctx.closePath();
    ctx.fillStyle = "#ff0000";
    ctx.fill();

    // stem
    ctx.beginPath();
    ctx.moveTo(-1,-3);
    ctx.quadraticCurveTo(-1,-5, 0,-5);
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#ff9900';
    ctx.stroke();

    // shine
    ctx.beginPath();
    ctx.moveTo(2,3);
    ctx.quadraticCurveTo(3,3, 3,1);
    ctx.lineCap = 'round';
    ctx.strokeStyle = "#fff";
    ctx.stroke();

    ctx.restore();
};

var drawMelon = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // draw body
    ctx.beginPath();
    ctx.arc(0,2,5.5,0,Math.PI*2);
    ctx.fillStyle = "#7bf331";
    ctx.fill();

    // draw stem
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.lineTo(0,-5);
    ctx.moveTo(2,-5);
    ctx.quadraticCurveTo(-3,-5,-3,-6);
    ctx.strokeStyle="#69b4af";
    ctx.lineCap = "round";
    ctx.stroke();

    // dark lines
    /*
    ctx.beginPath();
    ctx.moveTo(0,-2);
    ctx.lineTo(-4,2);
    ctx.lineTo(-1,5);
    ctx.moveTo(-3,-1);
    ctx.lineTo(-2,0);
    ctx.moveTo(-2,6);
    ctx.lineTo(1,3);
    ctx.moveTo(1,7);
    ctx.lineTo(3,5);
    ctx.lineTo(0,2);
    ctx.lineTo(3,-1);
    ctx.moveTo(2,0);
    ctx.lineTo(4,2);
    ctx.strokeStyle="#69b4af";
    ctx.lineCap = "round";
    ctx.lineJoin = 'round';
    ctx.stroke();
    */
    // dark spots
    var spots = [
        0,-2,
        -1,-1,
        -2,0,
        -3,1,
        -4,2,
        -3,3,
        -2,4,
        -1,5,
        -2,6,
        -3,-1,
        1,7,
        2,6,
        3,5,
        2,4,
        1,3,
        0,2,
        1,1,
        2,0,
        3,-1,
        3,1,
        4,2,
         ];

    ctx.fillStyle="#69b4af";
    var i,len;
    for (i=0, len=spots.length; i<len; i+=2) {
        var x = spots[i];
        var y = spots[i+1];
        ctx.beginPath();
        ctx.arc(x,y,0.65,0,2*Math.PI);
        ctx.fill();
    }

    // white spots
    var spots = [
        {x: 0,y:-3},
        {x:-2,y:-1},
        {x:-4,y: 1},
        {x:-3,y: 3},
        {x: 1,y: 0},
        {x:-1,y: 2},
        {x:-1,y: 4},
        {x: 3,y: 2},
        {x: 1,y: 4},
         ];

    ctx.fillStyle = "#fff";
    var i,len;
    for (i=0, len=spots.length; i<len; i++) {
        var s = spots[i];
        ctx.beginPath();
        ctx.arc(s.x,s.y,0.65,0,2*Math.PI);
        ctx.fill();
    }

    ctx.restore();
};

var drawGalaxian = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // draw yellow body
    ctx.beginPath();
    ctx.moveTo(-4,-2);
    ctx.lineTo(4,-2);
    ctx.lineTo(4,-1);
    ctx.lineTo(2,1);
    ctx.lineTo(1,0);
    ctx.lineTo(0,0);
    ctx.lineTo(0,5);
    ctx.lineTo(0,0);
    ctx.lineTo(-1,0);
    ctx.lineTo(-2,1);
    ctx.lineTo(-4,-1);
    ctx.closePath();
    ctx.lineJoin = 'round';
    ctx.strokeStyle = ctx.fillStyle = '#fffa36';
    ctx.fill();
    ctx.stroke();

    // draw red arrow head
    ctx.beginPath();
    ctx.moveTo(0,-5);
    ctx.lineTo(-3,-2);
    ctx.lineTo(-2,-2);
    ctx.lineTo(-1,-3);
    ctx.lineTo(0,-3);
    ctx.lineTo(0,-1);
    ctx.lineTo(0,-3);
    ctx.lineTo(1,-3);
    ctx.lineTo(2,-2);
    ctx.lineTo(3,-2);
    ctx.closePath();
    ctx.lineJoin = 'round';
    ctx.strokeStyle = ctx.fillStyle = "#f00";
    ctx.fill();
    ctx.stroke();

    // draw blue wings
    ctx.beginPath();
    ctx.moveTo(-5,-4);
    ctx.lineTo(-5,-1);
    ctx.lineTo(-2,2);
    ctx.moveTo(5,-4);
    ctx.lineTo(5,-1);
    ctx.lineTo(2,2);
    ctx.strokeStyle = "#00f";
    ctx.lineJoin = 'round';
    ctx.stroke();

    ctx.restore();
};

var drawBell = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // bell body
    ctx.beginPath();
    ctx.moveTo(-1,-5);
    ctx.bezierCurveTo(-4,-5,-6,1,-6,6);
    ctx.lineTo(5,6);
    ctx.bezierCurveTo(5,1,3,-5,0,-5);
    ctx.closePath();
    ctx.fillStyle = ctx.strokeStyle = "#fffa37";
    ctx.stroke();
    ctx.fill();

    // marks
    ctx.beginPath();
    ctx.moveTo(-4,4);
    ctx.lineTo(-4,3);
    ctx.moveTo(-3,1);
    ctx.quadraticCurveTo(-3,-2,-2,-2);
    ctx.moveTo(-1,-4);
    ctx.lineTo(0,-4);
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#000';
    ctx.stroke();

    // bell bottom
    ctx.beginPath();
    ctx.rect(-5.5,6,10,2);
    ctx.fillStyle = "#68b9fc";
    ctx.fill();
    ctx.beginPath();
    ctx.rect(-0.5,6,2,2);
    ctx.fillStyle = '#fff';
    ctx.fill();

    ctx.restore();
};

var drawKey = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // draw key metal
    ctx.beginPath();
    ctx.moveTo(-1,-2);
    ctx.lineTo(-1,5);
    ctx.moveTo(0,6);
    ctx.quadraticCurveTo(1,6,1,3);
    ctx.moveTo(1,4);
    ctx.lineTo(2,4);
    ctx.moveTo(1,1);
    ctx.lineTo(1,-2);
    ctx.moveTo(1,0);
    ctx.lineTo(2,0);
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#fff';
    ctx.stroke();

    // draw key top
    ctx.beginPath();
    ctx.moveTo(0,-6);
    ctx.quadraticCurveTo(-3,-6,-3,-4);
    ctx.lineTo(-3,-2);
    ctx.lineTo(3,-2);
    ctx.lineTo(3,-4);
    ctx.quadraticCurveTo(3,-6, 0,-6);
    ctx.strokeStyle = ctx.fillStyle = "#68b9fc";
    ctx.fill();
    ctx.lineJoin = 'round';
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(1,-5);
    ctx.lineTo(-1,-5);
    ctx.lineCap = 'round';
    ctx.strokeStyle = "#000";
    ctx.stroke();

    ctx.restore();
};

var drawPretzel = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // bread
    ctx.beginPath();
    ctx.moveTo(-2,-5);
    ctx.quadraticCurveTo(-4,-6,-6,-4);
    ctx.quadraticCurveTo(-7,-2,-5,1);
    ctx.quadraticCurveTo(-3,4,0,5);
    ctx.quadraticCurveTo(5,5,5,-1);
    ctx.quadraticCurveTo(6,-5,3,-5);
    ctx.quadraticCurveTo(1,-5,0,-2);
    ctx.quadraticCurveTo(-2,3,-5,5);
    ctx.moveTo(1,1);
    ctx.quadraticCurveTo(3,4,4,6);
    ctx.lineWidth = 2.0;
    ctx.lineCap = 'round';
    ctx.strokeStyle = "#ffcc33";
    ctx.stroke();

    // salt
    var spots = [
        -5,-6,
        1,-6,
        4,-4,
        -5,0,
        -2,0,
        6,1,
        -4,6,
        5,5,
         ];

    ctx.fillStyle = "#fff";
    var i,len;
    for (i=0, len=spots.length; i<len; i+=2) {
        var x = spots[i];
        var y = spots[i+1];
        ctx.beginPath();
        ctx.arc(x,y,0.65,0,2*Math.PI);
        ctx.fill();
    }

    ctx.restore();
};

var drawPear = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // body
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.bezierCurveTo(-1,-4,-2,-3,-2,-1);
    ctx.bezierCurveTo(-2,1,-4,2,-4,4);
    ctx.bezierCurveTo(-4,6,-2,7,0,7);
    ctx.bezierCurveTo(2,7,4,6,4,4);
    ctx.bezierCurveTo(4,2,2,1,2,-1);
    ctx.bezierCurveTo(2,-3,1,-4,0,-4);
    ctx.fillStyle = ctx.strokeStyle = "#00ff00";
    ctx.stroke();
    ctx.fill();

    // blue shine
    ctx.beginPath();
    ctx.moveTo(-2,3);
    ctx.quadraticCurveTo(-2,5,-1,5);
    ctx.strokeStyle = "#0033ff";
    ctx.lineCap = 'round';
    ctx.stroke();

    // white stem
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.quadraticCurveTo(0,-6,2,-6);
    ctx.strokeStyle = "#fff";
    ctx.lineCap = 'round';
    ctx.stroke();

    ctx.restore();
};

var drawBanana = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // body
    ctx.beginPath();
    ctx.moveTo(-5,5);
    ctx.quadraticCurveTo(-4,5,-2,6);
    ctx.bezierCurveTo(2,6,6,2,6,-4);
    ctx.lineTo(3,-3);
    ctx.lineTo(3,-2);
    ctx.lineTo(-4,5);
    ctx.closePath();
    ctx.fillStyle = ctx.strokeStyle = "#ffff00";
    ctx.stroke();
    ctx.fill();

    // stem
    ctx.beginPath();
    ctx.moveTo(4,-5);
    ctx.lineTo(5,-6);
    ctx.strokeStyle="#ffff00";
    ctx.lineCap='round';
    ctx.stroke();

    // black mark
    ctx.beginPath();
    ctx.moveTo(3,-1);
    ctx.lineTo(-2,4);
    ctx.strokeStyle = "#000";
    ctx.lineCap='round';
    ctx.stroke();

    // shine
    ctx.beginPath();
    ctx.moveTo(2,3);
    ctx.lineTo(0,5);
    ctx.strokeStyle = "#fff";
    ctx.lineCap='round';
    ctx.stroke();

    ctx.restore();
};

var drawCookie = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // body
    ctx.beginPath();
    ctx.arc(0,0,6,0,Math.PI*2);
    ctx.fillStyle = "#f9bd6d";
    //ctx.fillStyle = "#dfab68";
    ctx.fill();

    // chocolate chips
    var spots = [
        0,-3,
        -4,-1,
        0,2,
        3,0,
        3,3,
         ];

    ctx.fillStyle = "#000";
    var i,len;
    for (i=0, len=spots.length; i<len; i+=2) {
        var x = spots[i];
        var y = spots[i+1];
        ctx.beginPath();
        ctx.arc(x,y,0.75,0,2*Math.PI);
        ctx.fill();
    }

    ctx.restore();
};

var getSpriteFuncFromFruitName = function(name) {
    var funcs = {
        'cherry': drawCherry,
        'strawberry': drawStrawberry,
        'orange': drawOrange,
        'apple': drawApple,
        'melon': drawMelon,
        'galaxian': drawGalaxian,
        'bell': drawBell,
        'key': drawKey,
        'pretzel': drawPretzel,
        'pear': drawPear,
        'banana': drawBanana,
        'cookie': drawCookie,
    };

    return funcs[name];
};

//@line 1 "src/Actor.js"
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

    this.isDrawTarget = false;
    this.isDrawPath = false;

    this.savedSteps = {};
    this.savedFrames = {};
    this.savedDirEnum = {};
    this.savedPixel = {};
    this.savedTargetting = {};
    this.savedTargetTile = {};
};

// save state at time t
Actor.prototype.save = function(t) {
    this.savedSteps[t] = this.steps;
    this.savedFrames[t] = this.frames;
    this.savedDirEnum[t] = this.dirEnum;
    this.savedPixel[t] = { x:this.pixel.x, y:this.pixel.y };
    this.savedTargetting[t] = this.targetting;
    this.savedTargetTile[t] = { x: this.targetTile.x, y: this.targetTile.y };
};

// load state at time t
Actor.prototype.load = function(t) {
    this.steps = this.savedSteps[t];
    this.frames = this.savedFrames[t];
    this.setDir(this.savedDirEnum[t]);
    this.setPos(this.savedPixel[t].x, this.savedPixel[t].y);
    this.targetting = this.savedTargetting[t];
    this.targetTile.x = this.savedTargetTile[t].x;
    this.targetTile.y = this.savedTargetTile[t].y;
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
    map.teleport(this);

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
//@line 1 "src/Ghost.js"
//////////////////////////////////////////////////////////////////////////////////////
// Ghost class

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
    this.faceDirEnum = this.dirEnum;
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

    this.savedSigReverse = {};
    this.savedSigLeaveHome = {};
    this.savedMode = {};
    this.savedScared = {};
    this.savedElroy = {};
    this.savedFaceDirEnum = {};

    // call Actor's reset function to reset position and direction
    Actor.prototype.reset.apply(this);

    // faceDirEnum  = direction the ghost is facing
    // dirEnum      = direction the ghost is moving
    // (faceDirEnum represents what dirEnum will be once the ghost reaches the middle of the tile)
    this.faceDirEnum = this.dirEnum;
};

Ghost.prototype.save = function(t) {
    this.savedSigReverse[t] = this.sigReverse;
    this.savedSigLeaveHome[t] = this.sigLeaveHome;
    this.savedMode[t] = this.mode;
    this.savedScared[t] = this.scared;
    if (this == blinky) {
        this.savedElroy[t] = this.elroy;
    }
    this.savedFaceDirEnum[t] = this.faceDirEnum;
    Actor.prototype.save.call(this,t);
};

Ghost.prototype.load = function(t) {
    this.sigReverse = this.savedSigReverse[t];
    this.sigLeaveHome = this.savedSigLeaveHome[t];
    this.mode = this.savedMode[t];
    this.scared = this.savedScared[t];
    if (this == blinky) {
        this.elroy = this.savedElroy[t];
    }
    this.faceDirEnum = this.savedFaceDirEnum[t];
    Actor.prototype.load.call(this,t);
};

// indicates if we slow down in the tunnel
Ghost.prototype.isSlowInTunnel = function() {
    // special case for Ms. Pac-Man (slow down only for the first three levels)
    if (gameMode == GAME_MSPACMAN || gameMode == GAME_COOKIE)
        return level <= 3;
    else
        return true;
};

// gets the number of steps to move in this frame
Ghost.prototype.getNumSteps = function() {

    var pattern = STEP_GHOST;

    if (this.mode == GHOST_GOING_HOME || this.mode == GHOST_ENTERING_HOME)
        return 2;
    else if (this.mode == GHOST_LEAVING_HOME || this.mode == GHOST_PACING_HOME)
        pattern = STEP_GHOST_TUNNEL;
    else if (map.isTunnelTile(this.tile.x, this.tile.y) && this.isSlowInTunnel())
        pattern = STEP_GHOST_TUNNEL;
    else if (this.scared)
        pattern = STEP_GHOST_FRIGHT;
    else if (this.elroy == 1)
        pattern = STEP_ELROY1;
    else if (this.elroy == 2)
        pattern = STEP_ELROY2;

    return this.getStepSizeFromTable(level ? level : 1, pattern);
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
    // only reverse if we are in an active targetting mode or going home
    if (this.mode == GHOST_OUTSIDE || this.mode == GHOST_GOING_HOME)
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
        if (this.tile.x == map.doorTile.x && this.tile.y == map.doorTile.y) {
            this.faceDirEnum = DIR_DOWN;
            this.targetting = false;
            // walk to the door, or go through if already there
            if (this.pixel.x == map.doorPixel.x) {
                this.mode = GHOST_ENTERING_HOME;
                this.setDir(DIR_DOWN);
                this.faceDirEnum = this.dirEnum;
            }
            else {
                this.setDir(DIR_RIGHT);
                this.faceDirEnum = this.dirEnum;
            }
        }
    };

    steerFuncs[GHOST_ENTERING_HOME] = function() {
        if (this.pixel.y == map.homeBottomPixel) {
            // revive if reached its seat
            if (this.pixel.x == this.startPixel.x) {
                this.setDir(DIR_UP);
                this.mode = this.arriveHomeMode;
            }
            // sidestep to its seat
            else {
                this.setDir(this.startPixel.x < this.pixel.x ? DIR_LEFT : DIR_RIGHT);
            }
            this.faceDirEnum = this.dirEnum;
        }
    };

    steerFuncs[GHOST_PACING_HOME] = function() {
        // head for the door
        if (this.sigLeaveHome) {
            this.sigLeaveHome = false;
            this.mode = GHOST_LEAVING_HOME;
            if (this.pixel.x == map.doorPixel.x)
                this.setDir(DIR_UP);
            else
                this.setDir(this.pixel.x < map.doorPixel.x ? DIR_RIGHT : DIR_LEFT);
        }
        // pace back and forth
        else {
            if (this.pixel.y == map.homeTopPixel)
                this.setDir(DIR_DOWN);
            else if (this.pixel.y == map.homeBottomPixel)
                this.setDir(DIR_UP);
        }
        this.faceDirEnum = this.dirEnum;
    };

    steerFuncs[GHOST_LEAVING_HOME] = function() {
        if (this.pixel.x == map.doorPixel.x) {
            // reached door
            if (this.pixel.y == map.doorPixel.y) {
                this.mode = GHOST_OUTSIDE;
                this.setDir(DIR_LEFT); // always turn left at door?
            }
            // keep walking up to the door
            else {
                this.setDir(DIR_UP);
            }
            this.faceDirEnum = this.dirEnum;
        }
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
        (gameMode == GAME_MSPACMAN || gameMode == GAME_COOKIE) &&
        ghostCommander.getCommand() == GHOST_CMD_SCATTER &&
        (this == blinky || this == pinky));
};

// determine direction
Ghost.prototype.steer = function() {

    var dirEnum;                         // final direction to update to
    var openTiles;                       // list of four booleans indicating which surrounding tiles are open
    var oppDirEnum = (this.dirEnum+2)%4; // current opposite direction enum
    var actor;                           // actor whose corner we will target

    var isOnNewTile = ((this.dirEnum == DIR_UP && this.tilePixel.y == tileSize-1) ||
                (this.dirEnum == DIR_DOWN && this.tilePixel.y == 0) ||
                (this.dirEnum == DIR_LEFT && this.tilePixel.x == tileSize-1) ||
                (this.dirEnum == DIR_RIGHT && this.tilePixel.x == 0));

    // reverse direction if commanded
    if (this.sigReverse && (this.mode == GHOST_OUTSIDE || this.mode == GHOST_GOING_HOME)) {
        // reverse direction only if we've reached a new tile
        if (isOnNewTile) {
                this.sigReverse = false;
                this.setDir(oppDirEnum);
                this.faceDirEnum = this.dirEnum;
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

    // If we have just reached a new tile, then update the next direction.
    if (isOnNewTile) {

        // get surrounding tiles and their open indication
        openTiles = getOpenTiles(this.tile, this.dirEnum);

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
                this.targetTile.x = map.doorTile.x;
                this.targetTile.y = map.doorTile.y;
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

            if (this.mode == GHOST_GOING_HOME &&
                map.getExitDir && 
                (dirEnum=map.getExitDir(this.tile.x,this.tile.y)) != undefined &&
                dirEnum != oppDirEnum) {
                // if the map has a 'getExitDir' function, then we are using
                // a custom algorithm to choose the next direction.
                // Currently, procedurally-generated maps use this function
                // to ensure that ghosts can return home without looping forever.
            }
            else {
                // edit openTiles to reflect the current map's special contraints
                if (map.constrainGhostTurns)
                    map.constrainGhostTurns(this.tile, openTiles);

                // choose direction that minimizes distance to target
                dirEnum = getTurnClosestToTarget(this.tile, this.targetTile, openTiles);
            }
        }

        // Point eyeballs to the determined direction.
        this.faceDirEnum = dirEnum;
    }
    else if (this.distToMid.x == 0 && this.distToMid.y == 0) {
        // Once we have reached the middle of the tile, then we start travelling in the direction that we are looking.
        this.setDir(this.faceDirEnum);
    }

};

//@line 1 "src/Player.js"
//////////////////////////////////////////////////////////////////////////////////////
// Player is the controllable character (Pac-Man)

// Player constructor
var Player = function() {

    // inherit data from Actor
    Actor.apply(this);
    if (gameMode == GAME_MSPACMAN || gameMode == GAME_COOKIE) {
        this.frames = 1; // start with mouth open
    }

    this.nextDir = {};

    // determines if this player should be AI controlled
    this.ai = false;

    this.invincible = false;

    this.savedNextDirEnum = {};
    this.savedEatPauseFramesLeft = {};
};

Player.prototype.save = function(t) {
    this.savedEatPauseFramesLeft[t] = this.eatPauseFramesLeft;
    this.savedNextDirEnum[t] = this.nextDirEnum;

    Actor.prototype.save.call(this,t);
};

Player.prototype.load = function(t) {
    this.setNextDir(this.savedNextDirEnum[t]);
    this.eatPauseFramesLeft = this.savedEatPauseFramesLeft[t];

    Actor.prototype.load.call(this,t);
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
    return this.getStepSizeFromTable(level, pattern);
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
        var stop = this.distToMid[a] == 0 && !isNextTileFloor(this.tile, this.dir);
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
        var openTiles = getOpenTiles(this.tile, this.dirEnum);
        this.setTarget();
        this.setNextDir(getTurnClosestToTarget(this.tile, this.targetTile, openTiles));
    }
    else
        this.targetting = undefined;

    // head in the desired direction if possible
    if (isNextTileFloor(this.tile, this.nextDir))
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
    var t = map.getTile(this.tile.x, this.tile.y);
    if (t == '.' || t == 'o') {
        this.eatPauseFramesLeft = (t=='.') ? 1 : 3;

        map.onDotEat(this.tile.x, this.tile.y);
        ghostReleaser.onDotEat();
        fruit.onDotEat();
        addScore((t=='.') ? 10 : 50);

        if (t=='o')
            energizer.activate();
    }
};
//@line 1 "src/actors.js"
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
//@line 1 "src/targets.js"
/////////////////////////////////////////////////////////////////
// Targetting
// (a definition for each actor's targetting algorithm and a draw function to visualize it)
// (getPathDistLeft is used to obtain a smoothly interpolated path endpoint)

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
        renderer.drawCenterPixelSq(ctx, pacman.pixel.x, pacman.pixel.y, targetSize);
    else
        renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
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
        renderer.drawCenterPixelSq(ctx, px,py, targetSize);
    }
    else
        renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
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
        renderer.drawCenterPixelSq(ctx, pixel.x, pixel.y, targetSize);
    }
    else
        renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
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
        if (true) {
            // draw a radius
            ctx.arc(pacman.pixel.x, pacman.pixel.y, tileSize*8,0, 2*Math.PI);
            ctx.closePath();
        }
        else {
            // draw a distance stick
            ctx.moveTo(pacman.pixel.x, pacman.pixel.y);
            var dx = clyde.pixel.x - pacman.pixel.x;
            var dy = clyde.pixel.y - pacman.pixel.y;
            var dist = Math.sqrt(dx*dx+dy*dy);
            dx = dx/dist*tileSize*8;
            dy = dy/dist*tileSize*8;
            ctx.lineTo(pacman.pixel.x + dx, pacman.pixel.y + dy);
        }
        ctx.stroke();
        renderer.drawCenterPixelSq(ctx, pacman.pixel.x, pacman.pixel.y, targetSize);
    }
    else
        renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
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
        renderer.drawCenterPixelSq(ctx, px, py, targetSize);
    }
    else {
        renderer.drawCenterPixelSq(ctx, pinky.pixel.x, pinky.pixel.y, targetSize);
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
//@line 1 "src/ghostCommander.js"
//////////////////////////////////////////////////////////////////////////////////////
// Ghost Commander
// Determines when a ghost should be chasing a target

// modes representing the ghosts' current command
var GHOST_CMD_CHASE = 0;
var GHOST_CMD_SCATTER = 1;

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
            if (level == 1)
                i = 0;
            else if (level >= 2 && level <= 4)
                i = 1;
            else
                i = 2;
            return times[i][frame];
        };
    })();

    var frame;   // current frame
    var command; // last command given to ghosts

    var savedFrame = {};
    var savedCommand = {};

    // save state at time t
    var save = function(t) {
        savedFrame[t] = frame;
        savedCommand[t] = command;
    };

    // load state at time t
    var load = function(t) {
        frame = savedFrame[t];
        command = savedCommand[t];
    };

    return {
        save: save,
        load: load,
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
                    command = (gameMode == GAME_MSPACMAN || gameMode == GAME_COOKIE) ? GHOST_CMD_CHASE : newCmd;

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
//@line 1 "src/ghostReleaser.js"
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
    var getTimeoutLimit = function() { return (level < 5) ? 4*60 : 3*60; };

    // dot limits used in personal mode to release ghost after # of dots have been eaten
    var personalDotLimit = {};
    personalDotLimit[PINKY] = function() { return 0; };
    personalDotLimit[INKY] = function() { return (level==1) ? 30 : 0; };
    personalDotLimit[CLYDE] = function() {
        if (level == 1) return 60;
        if (level == 2) return 50;
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

    var savedGlobalCount = {};
    var savedFramesSinceLastDot = {};
    var savedGhostCounts = {};

    // save state at time t
    var save = function(t) {
        savedFramesSinceLastDot[t] = framesSinceLastDot;
        if (mode == MODE_GLOBAL) {
            savedGlobalCount[t] = globalCount;
        }
        else if (mode == MODE_PERSONAL) {
            savedGhostCounts[t] = {};
            savedGhostCounts[t][PINKY] = ghostCounts[PINKY];
            savedGhostCounts[t][INKY] = ghostCounts[INKY];
            savedGhostCounts[t][CLYDE] = ghostCounts[CLYDE];
        }
    };

    // load state at time t
    var load = function(t) {
        framesSinceLastDot = savedFramesSinceLastDot[t];
        if (mode == MODE_GLOBAL) {
            globalCount = savedGlobalCount[t];
        }
        else if (mode == MODE_PERSONAL) {
            ghostCounts[PINKY] = savedGhostCounts[t][PINKY];
            ghostCounts[INKY] = savedGhostCounts[t][INKY];
            ghostCounts[CLYDE] = savedGhostCounts[t][CLYDE];
        }
    };

    return {
        save: save,
        load: load,
        onNewLevel: function() {
            mode = MODE_PERSONAL;
            framesSinceLastDot = 0;
            ghostCounts[PINKY] = 0;
            ghostCounts[INKY] = 0;
            ghostCounts[CLYDE] = 0;
        },
        onRestartLevel: function() {
            mode = MODE_GLOBAL;
            framesSinceLastDot = 0;
            globalCount = 0;
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
//@line 1 "src/elroyTimer.js"
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
            var i = level;
            if (i>21) i = 21;
            return dotsLeft[stage-1][i-1];
        };
    })();

    // when level restarts, blinky must wait for clyde to leave home before resuming elroy mode
    var waitForClyde;

    var savedWaitForClyde = {};

    // save state at time t
    var save = function(t) {
        savedWaitForClyde[t] = waitForClyde;
    };

    // load state at time t
    var load = function(t) {
        waitForClyde = savedWaitForClyde[t];
    };

    return {
        onNewLevel: function() {
            waitForClyde = false;
        },
        onRestartLevel: function() {
            waitForClyde = true;
        },
        update: function() {
            var dotsLeft = map.dotsLeft();

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
        save: save,
        load: load,
    };
})();
//@line 1 "src/energizer.js"
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
            var i = level;
            return (i > 18) ? 0 : 60*seconds[i-1];
        };
    })();

    // how many ghost flashes happen near the end of frightened mode based on current level
    var getFlashes = (function(){
        var flashes = [5,5,5,5,5,5,5,5,3,5,5,3,3,5,3,3,0,3];
        return function() {
            var i = level;
            return (i > 18) ? 0 : flashes[i-1];
        };
    })();

    // "The ghosts change colors every 14 game cycles when they start 'flashing'" -Jamey Pittman
    var flashInterval = 14;

    var count;  // how long in frames energizer has been active
    var active; // indicates if energizer is currently active
    var points; // points that the last eaten ghost was worth
    var pointsFramesLeft; // number of frames left to display points earned from eating ghost

    var savedCount = {};
    var savedActive = {};
    var savedPoints = {};
    var savedPointsFramesLeft = {};

    // save state at time t
    var save = function(t) {
        savedCount[t] = count;
        savedActive[t] = active;
        savedPoints[t] = points;
        savedPointsFramesLeft[t] = pointsFramesLeft;
    };

    // load state at time t
    var load = function(t) {
        count = savedCount[t];
        active = savedActive[t];
        points = savedPoints[t];
        pointsFramesLeft = savedPointsFramesLeft[t];
    };

    return {
        save: save,
        load: load,
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
            addScore(points*=2);
            pointsFramesLeft = pointsDuration*60;
        },
        showingPoints: function() { return pointsFramesLeft > 0; },
        updatePointsTimer: function() { if (pointsFramesLeft > 0) pointsFramesLeft--; },
    };
})();
//@line 1 "src/fruit.js"
//////////////////////////////////////////////////////////////////////////////////////
// Fruit

var fruit = (function(){

    // common attributes
    var pixel = {x:0, y:0};
    var scoreDuration = 2; // number of seconds that the fruit score is on the screen
    var scoreFramesLeft; // frames left until the picked-up fruit score is off the screen
    var savedScoreFramesLeft = {};
    var isScorePresent = function() {
        return scoreFramesLeft > 0;
    };

    var fruitHistory = {};

    // fruit type for the current level
    var currentFruit;

    // ms. pac-man specific
    var mspacFruit = (function() {
        var fruits = [
            {name: 'cherry',     points: 100},
            {name: 'strawberry', points: 200},
            {name: 'orange',     points: 500},
            {name: 'pretzel',    points: 700},
            {name: 'apple',      points: 1000},
            {name: 'pear',       points: 2000},
            {name: 'banana',     points: 5000},
        ];

        var frame; // current frame along animated path
        var numFrames; // the final frame of the path
        var path; // current path list
        var pathMode; // set to one of the the following enums:
        var PATH_ENTER = 0;
        var PATH_PEN = 1;
        var PATH_EXIT = 2;
        var pen_path = "<<<<<<^^^^^^>>>>>>>>>vvvvvv<<"

        var dotLimit1 = 64;
        var dotLimit2 = 176;

        var sprite; // what to draw
        var points; // amount of points the fruit is worth

        var shouldRandomizeFruit = function() {
            return level > 7;
        };

        var getRandomInt = function(min,max) {
            return Math.floor(Math.random() * (max-min+1)) + min;
        };
        var onNewLevel = function() {
            if (!shouldRandomizeFruit()) {
                currentFruit = fruits[level-1];
                fruitHistory[level] = currentFruit;
            }
        };

        var reset = function() {
            frame = 0;
            numFrames = 0;
            path = undefined;
        };

        var initiatePath = function(p) {
            frame = 0;
            numFrames = p.length*16;
            path = p;
        };
        var initiate = function() {
            if (shouldRandomizeFruit()) {
                currentFruit = fruits[getRandomInt(0,6)];
            }
            var entrances = map.fruitPaths.entrances;
            var e = entrances[getRandomInt(0,entrances.length-1)];
            initiatePath(e.path);
            pathMode = PATH_ENTER;
            pixel.x = e.start.x;
            pixel.y = e.start.y;
        };

        var onDotEat = function() {
            if (!isPresent() && (map.dotsEaten == dotLimit1 || map.dotsEaten == dotLimit2)) {
                initiate();
            }
        };

        var move = (function() {
            var bounce_frames = (function(){
                var U = { dx:0, dy:-1 };
                var D = { dx:0, dy:1 };
                var L = { dx:-1, dy:0 };
                var R = { dx:1, dy:0 };
                var UL = { dx:-1, dy:-1 };
                var UR = { dx:1, dy:-1 };
                var DL = { dx:-1, dy:1 };
                var DR = { dx:1, dy:1 };
                var Z = { dx:0, dy:0 };
                return {
                    '^': [U, U, U, U, U, U, U, U, U, Z, U, Z, Z, D, Z, D],
                    '>': [Z, UR,Z, R, Z, UR,Z, R, Z, R, Z, R, Z, DR,DR,Z],
                    '<': [Z, Z, UL,Z, L, Z, UL,Z, L, Z, L, Z, L, Z, DL,DL],
                    'v': [Z, D, D, D, D, D, D, D, D, D, D, D, U, U, Z, U],
                };
            })();

            return function() {
                var p = path[Math.floor(frame/16)]; // get current path frame
                var b = bounce_frames[p][frame%16]; // get current bounce animation frame
                pixel.x += b.dx;
                pixel.y += b.dy;
                frame++;
            };
        })();

        var setNextPath = function() {
            if (pathMode == PATH_ENTER) {
                pathMode = PATH_PEN;
                initiatePath(pen_path);
            }
            else if (pathMode == PATH_PEN) {
                pathMode = PATH_EXIT;
                var exits = map.fruitPaths.exits;
                var e = exits[getRandomInt(0,exits.length-1)];
                initiatePath(e.path);
            }
            else if (pathMode == PATH_EXIT) {
                reset();
            }
        };

        var update = function() {
            if (isPresent()) {
                move();
                if (frame == numFrames) {
                    setNextPath();
                }
            }
        };

        var isPresent = function() {
            return frame < numFrames;
        };

        var savedPixel = {};
        var savedPathMode = {};
        var savedFrame = {};
        var savedNumFrames = {};
        var savedPath = {};
        var save = function(t) {
            savedPixel[t] = {x:pixel.x, y:pixel.y};
            savedPathMode[t] = pathMode;
            savedFrame[t] = frame;
            savedNumFrames[t] = numFrames;
            savedPath[t] = path;
        };
        var load = function(t) {
            pixel.x = savedPixel[t].x;
            pixel.y = savedPixel[t].y;
            pathMode = savedPathMode[t];
            frame = savedFrame[t];
            numFrames = savedNumFrames[t]; 
            path = savedPath[t];
        };

        return {
            save: save,
            load: load,
            isPresent: isPresent,
            reset: reset,
            update: update,
            onDotEat: onDotEat,
            onNewLevel: onNewLevel,
        };
    })();

    // pac-man specific
    var pacFruit = (function() {

        var fruits = [
            {name:'cherry',     points:100},
            {name:'strawberry', points:300},
            {name:'orange',     points:500},
            {name:'apple',      points:700},
            {name:'melon',      points:1000},
            {name:'galaxian',   points:2000},
            {name:'bell',       points:3000},
            {name:'key',        points:5000},
        ];

        var duration = 9; // number of seconds that the fruit is on the screen
        var framesLeft; // frames left until fruit is off the screen

        var dotLimit1 = 70;
        var dotLimit2 = 170;

        var onNewLevel = (function() {
            var order = [
                0,  // level 1
                1,  // level 2 
                2,  // level 3
                2,  // level 4
                3,  // level 5
                3,  // level 6
                4,  // level 7
                4,  // level 8
                5,  // level 9
                5,  // level 10
                6,  // level 11
                6,  // level 12
                7]; // level 13+

            return function() {
                var i = level;
                if (i > 13) {
                    i=13;
                }
                i--;
                currentFruit = fruits[order[i]];
                fruitHistory[level] = currentFruit;
            };
        })();

        var initiate = function() {
            var x = 13;
            var y = 20;
            pixel.x = tileSize*(1+x)-1;
            pixel.y = tileSize*y + midTile.y;
            framesLeft = 60*duration;
        };

        var isPresent = function() {
            return framesLeft > 0;
        };

        var reset = function() {
            framesLeft = 0;
        };

        var update = function() {
            if (framesLeft > 0)
                framesLeft--;
        };

        var onDotEat = function() {
            if (!isPresent() && (map.dotsEaten == dotLimit1 || map.dotsEaten == dotLimit2)) {
                initiate();
            }
        };

        // saving state
        var savedFramesLeft = {};
        var save = function(t) {
            savedFramesLeft[t] = framesLeft;
        };
        var load = function(t) {
            framesLeft = savedFramesLeft[t];
        };

        return {
            save: save,
            load: load,
            isPresent: isPresent,
            reset: reset,
            update: update,
            onDotEat: onDotEat,
            onNewLevel: onNewLevel,
        };
    })();

    // manual polymorphism

    var getInterface = (function() {
        var fruitFromMode = {};
        fruitFromMode[GAME_PACMAN] = pacFruit;
        fruitFromMode[GAME_MSPACMAN] = mspacFruit;
        fruitFromMode[GAME_COOKIE] = mspacFruit; // for now
        return function() {
            return fruitFromMode[gameMode];
        };
    })();

    var save = function(t) {
        savedScoreFramesLeft[t] = scoreFramesLeft;
        getInterface().save(t);
    };

    var load = function(t) {
        scoreFramesLeft = savedScoreFramesLeft[t];
        getInterface().load(t);
    };

    var onNewLevel = function() {
        getInterface().onNewLevel();
    };

    var reset = function() {
        scoreFramesLeft = 0;
        getInterface().reset();
    };

    var getPoints = function() {
        return currentFruit.points;
    };

    var update = function() {
        getInterface().update();
        if (scoreFramesLeft > 0)
            scoreFramesLeft--;
    };
    
    var onDotEat = function() {
        getInterface().onDotEat();
    };

    var getPoints = function() {
        return currentFruit.points;
    };
    
    var testCollide = function() {
        if (isPresent() && Math.abs(pacman.pixel.y - pixel.y) <= midTile.y && Math.abs(pacman.pixel.x - pixel.x) <= midTile.x) {
            addScore(getPoints());
            reset();
            scoreFramesLeft = scoreDuration*60;
        }
    };

    var isPresent = function() {
        return getInterface().isPresent();
    };

    var getCurrentFruit = function() {
        return currentFruit;
    };

    return {
        save: save,
        load: load,
        pixel: pixel,
        reset: reset,
        update: update,
        onDotEat: onDotEat,
        isPresent: isPresent,
        isScorePresent: isScorePresent,
        testCollide: testCollide,
        getPoints: getPoints,
        onNewLevel: onNewLevel,
        getFruitHistory: function() { return fruitHistory; },
        getCurrentFruit: getCurrentFruit,
    };
})();
//@line 1 "src/executive.js"
var executive = (function(){

    var interval; // used by setInterval and clearInterval to execute the game loop
    var timeout;
    var framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)
    var nextFrameTime;
    var running = false;

    /**********/
    // http://paulirish.com/2011/requestanimationframe-for-smart-animating/
    // http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating

    // requestAnimationFrame polyfill by Erik Möller
    // fixes from Paul Irish and Tino Zijdel

    (function() {
        var lastTime = 0;
        var vendors = ['ms', 'moz', 'webkit', 'o'];
        for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
            window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
            window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame']
                                       || window[vendors[x]+'CancelRequestAnimationFrame'];
        }
     
        if (!window.requestAnimationFrame)
            window.requestAnimationFrame = function(callback, element) {
                var currTime = new Date().getTime();
                var timeToCall = Math.max(0, 16 - (currTime - lastTime));
                var id = window.setTimeout(function() { callback(currTime + timeToCall); },
                  timeToCall);
                lastTime = currTime + timeToCall;
                return id;
            };
     
        if (!window.cancelAnimationFrame)
            window.cancelAnimationFrame = function(id) {
                clearTimeout(id);
            };
    }());
    /**********/
    var reqFrame;
    var fps;
    var updateFps = (function(){
        var length = 60;
        var times = [];
        var startIndex = 0;
        var endIndex = -1;
        var filled = false;

        return function(now) {
            if (filled) {
                startIndex = (startIndex+1) % length;
            }
            endIndex = (endIndex+1) % length;
            if (endIndex == length-1) {
                filled = true;
            }

            times[endIndex] = now;

            var seconds = (now - times[startIndex]) / 1000;
            var frames = endIndex - startIndex;
            if (frames < 0) {
                frames += length;
            }
            fps = frames / seconds;
            
            if (state == finishState) {
                //console.log(fps);
            }
        };
    })();
        

    var paused = false;
    var tick = function(now) {
        updateFps(now);

        // call update for every frame period that has elapsed
        var maxFrameSkip = 5;
        var frames = 0;

        if (paused) {
            nextFrameTime = now;
        }
        if (framePeriod != Infinity) {
            while (frames < maxFrameSkip && (now > nextFrameTime)) {
                state.update();
                nextFrameTime += framePeriod;
                frames++;
            }
        }
        // draw after updates are caught up
        renderer.beginFrame();
        state.draw();
        renderer.endFrame();
        reqFrame = requestAnimationFrame(tick);
    };

    return {

        // scheduling
        setUpdatesPerSecond: function(ups) {
            framePeriod = 1000/ups;
            nextFrameTime = (new Date).getTime();
        },
        init: function() {
            var that = this;
            window.addEventListener('focus', function() {that.start();});
            window.addEventListener('blur', function() {that.stop();});
            this.start();
        },
        start: function() {
            if (running) return;
            nextFrameTime = (new Date).getTime();
            reqFrame = requestAnimationFrame(tick);
            running = true;
        },
        stop: function() {
            if (!running) return;
            cancelAnimationFrame(reqFrame);
            running = false;
        },
        togglePause: function() { paused = !paused; },
        isPaused: function() { return paused; },
        getFps: function() { return fps; },
    };
})();
//@line 1 "src/states.js"
//////////////////////////////////////////////////////////////////////////////////////
// States
// (main loops for each state of the game)
// state is set to any of these states, each containing an init(), draw(), and update()

// current game state
var state;

// switches to another game state
var switchState = function(nextState,fadeDuration, continueUpdate1, continueUpdate2) {
    state = (fadeDuration) ? fadeNextState(state,nextState,fadeDuration,continueUpdate1, continueUpdate2) : nextState;
    state.init();
};

//////////////////////////////////////////////////////////////////////////////////////
// Fade state

// Creates a state that will fade from a given state to another in the given amount of time.
// if continueUpdate1 is true, then prevState.update will be called while fading out
// if continueUpdate2 is true, then nextState.update will be called while fading in
var fadeNextState = function (prevState, nextState, frameDuration, continueUpdate1, continueUpdate2) {
    var frames;
    var inFirstState = function() { return frames < frameDuration/2; };
    var getStateTime = function() { return inFirstState() ? frames/frameDuration*2 : frames/frameDuration*2-1; };
    var initialized = false;

    return {
        init: function() {
            frames = 0;
            initialized = true;
        },
        draw: function() {
            if (!initialized) return;
            var t = getStateTime();
            if (inFirstState()) {
                if (prevState) {
                    prevState.draw();
                    renderer.setOverlayColor("rgba(0,0,0,"+t+")");
                }
            }
            else {
                nextState.draw();
                renderer.setOverlayColor("rgba(0,0,0,"+(1-t)+")");
            }
        },
        update: function() {
            if (inFirstState()) {
                if (continueUpdate1) prevState.update();
            }
            else {
                if (continueUpdate2) nextState.update();
            }

            if (frames == frameDuration) {
                state = nextState; // hand over state
                initialized = false;
            }
            else {
                if (frames == frameDuration/2)
                    nextState.init();
                frames++;
            }
        },
    }
};

//////////////////////////////////////////////////////////////////////////////////////
// Home State
// (the home title screen state)

var homeState = (function(){

    var exitTo = function(s) {
        switchState(s,60);
        menu.disable();
    };

    var menu = new Menu(2*tileSize,0,mapWidth-4*tileSize,4*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    var getIconAnimFrame = function(frame) {
        frame = Math.floor(frame/3)+1;
        frame %= 4;
        if (frame == 3) {
            frame = 1;
        }
        return frame;
    };
    menu.addTextIconButton("PAC-MAN",
        function() {
            gameMode = GAME_PACMAN;
            exitTo(newGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawPacmanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame));
        });
    menu.addTextIconButton("MS. PAC-MAN", 
        function() {
            gameMode = GAME_MSPACMAN;
            exitTo(newGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawMsPacmanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame));
        });
    menu.addTextIconButton("COOKIE-MAN",
        function() {
            gameMode = GAME_COOKIE;
            exitTo(newGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawCookiemanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame));
        });
    menu.addTextIconButton("CHALLENGES",
        function() {
        },
        function(ctx,x,y,frame) {
            atlas.drawGhostSprite(ctx,x,y,Math.floor(frame/8)%2,DIR_RIGHT,false,false,false,blinky.color);
        });
    menu.addTextIconButton("HELP",
        function() {
        },
        function(ctx,x,y,frame) {
            var animFrame = Math.floor(frame/8)%2;
            var flash = Math.floor(frame/24)%2;
            atlas.drawGhostSprite(ctx,x,y,animFrame,DIR_RIGHT,true,flash,false,blinky.color);
        });
    menu.addTextButton("ABOUT",
        function() {
        });

    return {
        init: function() {
            menu.enable();
        },
        draw: function() {
            renderer.renderFunc(menu.draw,menu);
        },
        update: function() {
            menu.update();
        },
    };

})();

////////////////////////////////////////////////////
// New Game state
// (state when first starting a new game)

var newGameState = (function() {
    var frames;
    var duration = 2;

    return {
        init: function() {
            frames = 0;
            level = 0;
            extraLives = 3;
            score = 0;
            readyNewState.init();
        },
        draw: function() {
            if (!map)
                return;
            renderer.blitMap();
            renderer.drawScore();
            renderer.drawMessage("READY!","#FF0");
        },
        update: function() {
            if (frames == duration*60) {
                extraLives--;
                state = readyNewState;
                renderer.drawMap();
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
            map.resetTimeEaten();
            frames = 0;
        },
        draw: function() {
            newGameState.draw();
            renderer.drawActors();
        },
        update: function() {
            if (frames == duration*60)
                switchState(playState);
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

        // increment level and ready the next map
        level++;
        if (gameMode == GAME_PACMAN) {
            map = mapPacman;
        }
        else if (gameMode == GAME_MSPACMAN) {
            setNextMsPacMap();
        }
        else if (gameMode == GAME_COOKIE) {
            setNextCookieMap();
        }
        map.resetCurrent();
        fruit.onNewLevel();
        renderer.drawMap();

        // notify other objects of new level
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
        extraLives--;
        ghostReleaser.onRestartLevel();
        elroyTimer.onRestartLevel();
        renderer.drawMap();

        // inherit attributes from readyState
        readyState.init.call(this);
    },
};

////////////////////////////////////////////////////
// Play state
// (state when playing the game)

var playState = {
    init: function() { vcr.reset(); },
    draw: function() {
        renderer.blitMap();
        renderer.drawScore();

        renderer.beginMapClip();
        renderer.drawFruit();
        renderer.drawPaths();
        renderer.drawActors();
        renderer.drawTargets();
        renderer.endMapClip();

        renderer.renderFunc(vcr.renderHud);
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
                    switchState(deadState);
                return true;
            }
        }
        return false;
    },
    update: function() {
        
        if (vcr.getMode() == VCR_RECORD) {

            // record current state
            vcr.record();

            var i,j; // loop index
            var maxSteps = 2;
            var skip = false;

            // skip this frame if needed,
            // but update ghosts running home
            if (energizer.showingPoints()) {
                for (j=0; j<maxSteps; j++)
                    for (i=0; i<4; i++)
                        if (ghosts[i].mode == GHOST_GOING_HOME || ghosts[i].mode == GHOST_ENTERING_HOME)
                            ghosts[i].update(j);
                energizer.updatePointsTimer();
                skip = true;
            }
            else { // make ghosts go home immediately after points disappear
                for (i=0; i<4; i++)
                    if (ghosts[i].mode == GHOST_EATEN) {
                        ghosts[i].mode = GHOST_GOING_HOME;
                        ghosts[i].targetting = 'door';
                    }
            }
            
            if (!skip) {

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
                    if (map.allDotsEaten()) {
                        //this.draw();
                        switchState(finishState);
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
            }
        }
        else {
            vcr.seek();
        }
    },
};

////////////////////////////////////////////////////
// Script state
// (a state that triggers functions at certain times)

var scriptState = (function(){

    return {
        init: function() {
            this.frames = 0;        // frames since state began
            this.triggerFrame = 0;  // frames since last trigger

            this.drawFunc = this.triggers[0].draw;   // current draw function
            this.updateFunc = this.triggers[0].update; // current update function
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
})();

////////////////////////////////////////////////////
// Seekable Script state
// (a script state that can be controled by the VCR)

var seekableScriptState = (function(){
    return {

        __proto__: scriptState,

        init: function() {
            scriptState.init.call(this);
            this.savedFrames = {};
            this.savedTriggerFrame = {};
            this.savedDrawFunc = {};
            this.savedUpdateFunc = {};
        },

        save: function(t) {
            this.savedFrames[t] = this.frames;
            this.savedTriggerFrame[t] = this.triggerFrame;
            this.savedDrawFunc[t] = this.drawFunc;
            this.savedUpdateFunc[t] = this.updateFunc;
        },
        load: function(t) {
            this.frames = this.savedFrames[t];
            this.triggerFrame = this.savedTriggerFrame[t];
            this.drawFunc = this.savedDrawFunc[t];
            this.updateFunc = this.savedUpdateFunc[t];
        },
        update: function() {
            if (vcr.getMode() == VCR_RECORD) {
                vcr.record();
                scriptState.update.call(this);
            }
            else {
                vcr.seek();
            }
        },
        draw: function() {
            if (this.drawFunc) {
                scriptState.draw.call(this);
                renderer.renderFunc(vcr.renderHud);
            }
        },
    };
})();

////////////////////////////////////////////////////
// Dead state
// (state when player has lost a life)

var deadState = (function() {
    
    // this state will always have these drawn
    var commonDraw = function() {
        renderer.blitMap();
        renderer.drawScore();
    };

    return {

        // inherit script state functions
        __proto__: seekableScriptState,

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
                    renderer.beginMapClip();
                    renderer.drawFruit();
                    renderer.drawActors();
                    renderer.endMapClip();
                }
            },
            60: {
                draw: function() { // isolate pacman
                    commonDraw();
                    renderer.beginMapClip();
                    renderer.drawPlayer();
                    renderer.endMapClip();
                },
            },
            120: {
                draw: function(t) { // dying animation
                    commonDraw();
                    renderer.beginMapClip();
                    renderer.drawDyingPlayer(t/75);
                    renderer.endMapClip();
                },
            },
            195: {
                draw: function() {
                    commonDraw();
                    renderer.beginMapClip();
                    renderer.drawDyingPlayer(1);
                    renderer.endMapClip();
                },
            },
            240: {
                draw: function() {
                    commonDraw();
                    renderer.beginMapClip();
                    renderer.drawDyingPlayer(1);
                    renderer.endMapClip();
                },
                init: function() { // leave
                    switchState( extraLives == 0 ? overState : readyRestartState);
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
        renderer.blitMap();
        renderer.drawScore();

        renderer.beginMapClip();
        renderer.drawPlayer();
        renderer.endMapClip();
    };
    
    // flash the floor and draw
    var flashFloorAndDraw = function(on) {
        renderer.setLevelFlash(on);
        commonDraw();
    };

    return {

        // inherit script state functions
        __proto__: seekableScriptState,

        // script functions for each time
        triggers: {
            0:   { draw: function() {
                    renderer.blitMap();
                    renderer.drawScore();
                    renderer.beginMapClip();
                    renderer.drawFruit();
                    renderer.drawActors();
                    renderer.drawTargets();
                    renderer.endMapClip();
            } },
            60:  { draw: function() { flashFloorAndDraw(false); } },
            120: { draw: function() { flashFloorAndDraw(true); } },
            132: { draw: function() { flashFloorAndDraw(false); } },
            144: { draw: function() { flashFloorAndDraw(true); } },
            156: { draw: function() { flashFloorAndDraw(false); } },
            168: { draw: function() { flashFloorAndDraw(true); } },
            180: { draw: function() { flashFloorAndDraw(false); } },
            192: { draw: function() { flashFloorAndDraw(true); } },
            204: { draw: function() { flashFloorAndDraw(false); } },
            234: {
                draw: function() { flashFloorAndDraw(false); },
                init: function() {
                    if (!triggerCutsceneAtEndLevel()) {
                        switchState(readyNewState,60);
                    }
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
            frames = 0;
        },
        draw: function() {
            renderer.blitMap();
            renderer.drawScore();
            renderer.drawMessage("GAME OVER", "#F00");
        },
        update: function() {
            if (frames == 120) {
                switchState(homeState,60);
            }
            else
                frames++;
        },
    };
})();
//@line 1 "src/cutscenes.js"
////////////////////////////////////////////////
// Cutscenes
//

var triggerCutsceneAtEndLevel = function() {
    if (gameMode == GAME_PACMAN) {
        // TODO: trigger cutscene 1,2,or 3
        // TODO: return true;
    }
    else if (gameMode == GAME_MSPACMAN) {
        // TODO: trigger cutscene 1,2,or 3
        // TODO: return true;
    }
    else if (gameMode == GAME_MSPACMAN) {
        // TODO: trigger cutscene 1,2,or 3
        // TODO: return true;
    }

    // NOTE: no cutscene triggered yet
    return false;
};

var pacman_cutscene_1 = function() {
};
var pacman_cutscene_2 = function() {
};
var pacman_cutscene_3 = function() {
};
var mspacman_cutscene_1 = function() {
};
var mspacman_cutscene_2 = function() {
};
var mspacman_cutscene_3 = function() {
};
var cookieman_cutscene_1 = function() {
};
var cookieman_cutscene_2 = function() {
};
var cookieman_cutscene_3 = function() {
};
//@line 1 "src/maps.js"
//////////////////////////////////////////////////////////////////////////////////////
// Maps

// Definitions of playable maps

// current map
var map;

// actor starting states

blinky.startDirEnum = DIR_LEFT;
blinky.startPixel = {
    x: 14*tileSize-1,
    y: 14*tileSize+midTile.y
};
blinky.cornerTile = {
    x: 28-1-2,
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
    x: 28-1,
    y: 36 - 2,
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
    y: 36-2,
};
clyde.startMode = GHOST_PACING_HOME;
clyde.arriveHomeMode = GHOST_PACING_HOME;

pacman.startDirEnum = DIR_LEFT;
pacman.startPixel = {
    x: 14*tileSize-1,
    y: 26*tileSize + midTile.y,
};

// Original Pac-Man map
var mapPacman = new Map(28, 36, (
    "____________________________" +
    "____________________________" +
    "____________________________" +
    "||||||||||||||||||||||||||||" +
    "|............||............|" +
    "|.||||.|||||.||.|||||.||||.|" +
    "|o||||.|||||.||.|||||.||||o|" +
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

mapPacman.name = "Pac-Man";
//mapPacman.wallStrokeColor = "#47b897"; // from Pac-Man Plus
mapPacman.wallStrokeColor = "#2121ff"; // from original
mapPacman.wallFillColor = "#000";
mapPacman.pelletColor = "#ffb8ae";
mapPacman.constrainGhostTurns = function(tile,openTiles) {
    // prevent ghost from turning up at these tiles
    if ((tile.x == 12 || tile.x == 15) && (tile.y == 14 || tile.y == 26)) {
        openTiles[DIR_UP] = false;
    }
};

// Levels are grouped into "acts."
// In Ms. Pac-Man (and Cookie-Man) a map only changes after the end of an act.
// The levels within an act progress in difficulty.
// But the beginning of an act is generally easier than the end of the previous act to stave frustration.
// Completing an act results in a cutscene.
var getLevelAct = function(level) {
    // Act 1: (levels 1,2)
    // Act 2: (levels 3,4,5)
    // Act 3: (levels 6,7,8,9)
    // Act 4: (levels 10,11,12,13)
    // Act 5: (levels 14,15,16,17)
    // ...
    if (level <= 2) {
        return 1;
    }
    else if (level <= 5) {
        return 2;
    }
    else {
        return 3 + Math.floor((level - 6)/4);
    }
};

var setNextCookieMap = function() {
    // cycle the colors
    var colors = [
        "#359c9c", "#80d8fc", // turqoise
        "#c2b853", "#e6f1e7", // yellow
        "#86669c", "#f2c1db", // purple
        "#ed0a04", "#e8b4cd", // red
        "#2067c1", "#63e0b6", // blue
        "#c55994", "#fd61c3", // pink
        "#12bc76", "#b4e671", // green
        "#5036d9", "#618dd4", // violet
        "#939473", "#fdfdf4", // grey
    ];
    var i;
    var act = getLevelAct(level);
    if (level == 1 || act != getLevelAct(level-1)) {
        map = mapgen();
        i = ((act-1)*2) % colors.length;
        map.wallFillColor = colors[i];
        map.wallStrokeColor = colors[i+1];
    }
};

// Ms. Pac-Man map 1

var setNextMsPacMap = function() {
    var maps = [mapMsPacman1, mapMsPacman2, mapMsPacman3, mapMsPacman4];

    // The third and fourth maps repeat indefinitely after the second map.
    // (i.e. act1=map1, act2=map2, act3=map3, act4=map4, act5=map3, act6=map4, ...)
    var i = getLevelAct(level)-1;
    if (i > 1) {
        i = (i%2)+2;
    }
    map = maps[i];
    // TODO: add random color bug from arcade?
};

var mapMsPacman1 = new Map(28, 36, (
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
    "|............  ............|" +
    "|.||||.|||||.||.|||||.||||.|" +
    "|.||||.|||||.||.|||||.||||.|" +
    "|.||||.||....||....||.||||.|" +
    "|o||||.||.||||||||.||.||||o|" +
    "|.||||.||.||||||||.||.||||.|" +
    "|..........................|" +
    "||||||||||||||||||||||||||||" +
    "____________________________" +
    "____________________________"));

mapMsPacman1.name = "Ms. Pac-Man 1";
mapMsPacman1.wallFillColor = "#FFB8AE";
mapMsPacman1.wallStrokeColor = "#FF0000";
mapMsPacman1.pelletColor = "#dedeff";
mapMsPacman1.fruitPaths = {
             "entrances": [
                 { "start": { "y": 164, "x": 228 }, "path": "<<<<vvv<<<<<<<<<^^^" }, 
                 { "start": { "y": 164, "x": -4 }, "path": ">>>>vvvvvv>>>>>>>>>>>>>>>^^^<<<^^^" }, 
                 { "start": { "y": 92, "x": -4 }, "path": ">>>>^^^^>>>vvvv>>>vvv>>>>>>>>>vvvvvv<<<" }, 
                 { "start": { "y": 92, "x": 228 }, "path": "<<<<vvvvvvvvv<<<^^^<<<vvv<<<" }
             ], 
             "exits": [
                 { "path": "<vvv>>>>>>>>>^^^>>>>" }, 
                 { "path": "<<<<vvv<<<<<<<<<^^^<<<<" }, 
                 { "path": "<<<<<<<^^^^^^<<<<<<^^^<<<<" }, 
                 { "path": "<vvv>>>>>>>>>^^^^^^^^^^^^>>>>" }
             ]
         };

// Ms. Pac-Man map 2

var mapMsPacman2 = new Map(28, 36, (
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

mapMsPacman2.name = "Ms. Pac-Man 2";
mapMsPacman2.wallFillColor = "#47b8ff";
mapMsPacman2.wallStrokeColor = "#dedeff";
mapMsPacman2.pelletColor = "#ffff00";
mapMsPacman2.fruitPaths = {
             "entrances": [
                 { "start": { "y": 212, "x": 228 }, "path": "<<<<^^^<<<<<<<<^^^<" }, 
                 { "start": { "y": 212, "x": -4 }, "path": ">>>>^^^>>>>>>>>vvv>>>>>^^^^^^<" }, 
                 { "start": { "y": 36, "x": -4 }, "path": ">>>>>>>vvv>>>vvvvvvv>>>>>>>>>vvvvvv<<<" }, 
                 { "start": { "y": 36, "x": 228 }, "path": "<<<<<<<vvv<<<vvvvvvvvvvvvv<<<" }
             ], 
             "exits": [
                 { "path": "vvv>>>>>>>>vvv>>>>" }, 
                 { "path": "vvvvvv<<<<<^^^<<<<<<<<vvv<<<<" }, 
                 { "path": "<<<<<<<^^^^^^^^^^^^^<<<^^^<<<<<<<" }, 
                 { "path": "vvv>>>>>^^^^^^^^^^>>>>>^^^^^^<<<<<^^^>>>>>>>" }
             ]
         };

// Ms. Pac-Man map 3

var mapMsPacman3 = new Map(28, 36, (
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

mapMsPacman3.name = "Ms. Pac-Man 3";
mapMsPacman3.wallFillColor = "#de9751";
mapMsPacman3.wallStrokeColor = "#dedeff";
mapMsPacman3.pelletColor = "#ff0000";
mapMsPacman3.fruitPaths = {
             "entrances": [
                 { "start": { "y": 100, "x": 228 }, "path": "<<<<<vv<<<<<vvvvvv<<<" }, 
                 { "start": { "y": 100, "x": -4 }, "path": ">>>>>vv>>>>>>>>>>>>>>vvvvvv<<<" }, 
                 { "start": { "y": 100, "x": -4 }, "path": ">>>>>vv>>>>>>>>>>>>>>vvvvvv<<<" }, 
                 { "start": { "y": 100, "x": 228 }, "path": "<<vvvvv<<<vvv<<<<<<<<" }
             ], 
             "exits": [
                 { "path": "<vvv>>>vvv>>>^^^>>>>>^^^^^^^^^^^>>" }, 
                 { "path": "<<<<vvv<<<vvv<<<^^^<<<<<^^^^^^^^^^^<<" }, 
                 { "path": "<<<<vvv<<<vvv<<<^^^<<<<<^^^^^^^^^^^<<" }, 
                 { "path": "<vvv>>>vvv>>>^^^^^^<<<^^^^^^>>>>>^^>>>>>" }
             ]
         };

// Ms. Pac-Man map 4

var mapMsPacman4 = new Map(28, 36, (
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

mapMsPacman4.name = "Ms. Pac-Man 4";
mapMsPacman4.wallFillColor = "#2121ff";
mapMsPacman4.wallStrokeColor = "#ffb851";
mapMsPacman4.pelletColor = "#dedeff";
mapMsPacman4.fruitPaths = {
             "entrances": [
                 { "start": { "y": 156, "x": 228 }, "path": "<<<<vv<<<vv<<<<<<^^^" }, 
                 { "start": { "y": 156, "x": -4 }, "path": ">>>>vv>>>vv>>>>>>vvv>>>^^^^^^" }, 
                 { "start": { "y": 132, "x": -4 }, "path": ">>>>^^^^^>>>^^^>>>vvv>>>vvv>>>>>>vvvvvv<<<" }, 
                 { "start": { "y": 132, "x": 228 }, "path": "<<<<^^<<<vvv<<<vvv<<<" }
             ], 
             "exits": [
                 { "path": "<vvv>>>>>>^^>>>^^>>>>" }, 
                 { "path": "<<<<vvv<<<<<<^^<<<^^<<<<" }, 
                 { "path": "<<<<<<<^^^<<<^^^<<<vv<<<<" }, 
                 { "path": "<vvv>>>>>>^^^^^^^^^>>>vv>>>>" }
             ]
         };
//@line 1 "src/main.js"
//////////////////////////////////////////////////////////////////////////////////////
// Entry Point

window.onload = function() {
    initRenderer();
    atlas.create();
    initSwipe();
    switchState(homeState);
    executive.init();
};
})();
