
var atlas = (function(){

    var canvas = document.createElement("canvas");
    var ctx = canvas.getContext("2d");
    var size = 20;
    var cols = 12;
    var rows = 12;

    var create = function() {
        var w = size*cols*renderScale;
        var h = size*rows*renderScale;
        canvas.width = w;
        canvas.height = h;

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

    var copyCellTo = function(row, col, destCtx, x, y) {
        var sx = col*size*renderScale;
        var sy = row*size*renderScale;
        var sw = renderScale*size;
        var sh = renderScale*size;

        var dx = x - size/2;
        var dy = y - size/2;
        var dw = size;
        var dh = size;

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
