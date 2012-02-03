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
    if (pacman.dirEnum == DIR_UP)
        this.targetTile.x -= 4; // arcade overflow bug
};
inky.setTarget = function() {
    // target twice the distance from blinky to two tiles ahead of pacman
    var px = pacman.tile.x + 2*pacman.dir.x;
    var py = pacman.tile.y + 2*pacman.dir.y;
    if (pacman.dirEnum == DIR_UP)
        px -= 2; // arcade overflow bug
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
