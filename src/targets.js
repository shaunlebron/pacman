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
    var pixel;

    var px = pacman.pixel.x + 2*pacman.dir.x*tileSize;
    var py = pacman.pixel.y + 2*pacman.dir.y*tileSize;

    if (this.targetting == 'pacman') {
        pixel = this.getTargetPixel();
        ctx.beginPath();
        ctx.moveTo(pacman.pixel.x, pacman.pixel.y);
        ctx.lineTo(px, py);
        ctx.moveTo(blinky.pixel.x, blinky.pixel.y);
        ctx.lineTo(pixel.x, pixel.y);
        ctx.closePath();
        ctx.stroke();

        // draw seesaw joint
        ctx.beginPath();
        ctx.arc(px,py,2,0,Math.PI*2);
        ctx.fillStyle = ctx.strokeStyle;
        ctx.fill();

        ctx.fillStyle = this.color;
        renderer.drawCenterPixelSq(ctx, pixel.x, pixel.y, targetSize);
    }
    else {
        ctx.fillStyle = this.color;
        renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
    }
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
    else {
        // draw a radius
        if (ghostCommander.getCommand() == GHOST_CMD_CHASE) {
            ctx.beginPath();
            ctx.arc(pacman.pixel.x, pacman.pixel.y, tileSize*8,0, 2*Math.PI);
            ctx.strokeStyle = "rgba(255,255,255,0.25)";
            ctx.stroke();
        }
        renderer.drawCenterTileSq(ctx, this.targetTile.x, this.targetTile.y, targetSize);
    }
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
