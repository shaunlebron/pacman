
// REFERENCED GLOBALS:
// import { renderScale } from './renderers.js';
// import { DIR_UP, DIR_RIGHT, DIR_DOWN, DIR_LEFT } from './direction.js';
// import { blinky, pinky, inky, clyde } from './actors.js';
// import { drawGhostSprite, drawMonsterSprite, drawOttoSprite, drawMsOttoSprite, drawPacmanSprite, drawMsPacmanSprite, drawCookiemanSprite, drawCherry, drawStrawberry, drawOrange, drawApple, drawMelon, drawGalaxian, drawBell, drawKey, drawPretzel, drawPear, drawBanana, drawCookie, drawCookieFlash, drawSnail, drawPacPoints, drawMsPacPoints } from './sprites.js';

const atlas = (function(){

    let canvas,ctx;
    const size = 22;
    const cols = 14; // has to be ONE MORE than intended to fix some sort of CHROME BUG (last cell always blank?)
    const rows = 22;

    let creates = 0;

    const drawGrid = function() {
        // draw grid overlay
        const canvas = document.getElementById('gridcanvas');
        if (!canvas) {
            return;
        }
        const w = size*cols*renderScale;
        const h = size*rows*renderScale;
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');
        ctx.clearRect(0,0,w,h);
        const step = size*renderScale;
        ctx.beginPath();
        for (let x=0; x<=w; x+=step) {
            ctx.moveTo(x,0);
            ctx.lineTo(x,h);
        }
        for (let y=0; y<=h; y+=step) {
            ctx.moveTo(0,y);
            ctx.lineTo(w,y);
        }
        ctx.lineWidth = "1px";
        ctx.lineCap = "square";
        ctx.strokeStyle="rgba(255,255,255,0.5)";
        ctx.stroke();
    };

    const create = function() {
        drawGrid();
        canvas = document.getElementById('atlas');
        ctx = canvas.getContext("2d");
        /*
        canvas.style.left = 0;
        canvas.style.top = 0;
        canvas.style.position = "absolute";
        */

        const w = size*cols*renderScale;
        const h = size*rows*renderScale;
        canvas.width = w;
        canvas.height = h;

        if (creates > 0) {
            ctx.restore();
        }
        creates++;

        ctx.save();
        ctx.clearRect(0,0,w,h);
        ctx.scale(renderScale,renderScale);

        const drawAtCell = function(f,row,col) {
            const x = col*size + size/2;
            const y = row*size + size/2;
            f(x,y);
        };

        let row = 0;
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
        drawAtCell(function(x,y) { drawCookieFlash(ctx,x,y); },      row,12);

        const drawGhostCells = function(row,color) {
            for (let col=0, i=0; i<4; i++) { // dirEnum
                for (let f=0; f<2; f++, col++) { // frame
                    drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, f, i, false, false, false, color); },   row,col);
                }
            }
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
        // draw disembodied eyes
        (function(){
            for (let col=0, i=0; i<4; i++, col++) { // dirEnum
                drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, i, false, false, true, "#fff"); },     row,col);
            }
        })();

        // draw ghosts scared
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_UP, true, false, false, "#fff"); }, row,4);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 1, DIR_UP, true, false, false, "#fff"); }, row,5);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 0, DIR_UP, true, true, false, "#fff"); },  row,6);
        drawAtCell(function(x,y) { drawGhostSprite(ctx, x,y, 1, DIR_UP, true, true, false, "#fff"); },  row,7);

        const drawPacCells = function(row,col,dir) {
            drawAtCell(function(x,y) { drawPacmanSprite(ctx, x,y, dir, Math.PI/6); }, row, col);
            drawAtCell(function(x,y) { drawPacmanSprite(ctx, x,y, dir, Math.PI/3); }, row, col+1);
        };
        row++;

        // draw pacman mouth closed
        drawAtCell(function(x,y) { drawPacmanSprite(ctx, x,y, DIR_RIGHT, 0); }, row, 0);

        // draw pacman directions
        (function(){
            for (let col=1, i=0; i<4; i++, col+=2) {
                drawPacCells(row,col,i);
            }
        })();

        const drawMsPacCells = function(row,col,dir) {
            drawAtCell(function(x,y) { drawMsPacmanSprite(ctx, x,y, dir, 0); }, row, col);
            drawAtCell(function(x,y) { drawMsPacmanSprite(ctx, x,y, dir, 1); }, row, col+1);
            drawAtCell(function(x,y) { drawMsPacmanSprite(ctx, x,y, dir, 2); }, row, col+2);
        };
        row++;
        (function(){
            for (let col=0, i=0; i<4; i++, col+=3) {
                drawMsPacCells(row,col,i);
            }
        })();

        const drawCookieCells = function(row,col,dir) {
            drawAtCell(function(x,y) { drawCookiemanSprite(ctx, x,y, dir, 0, true); }, row, col);
            drawAtCell(function(x,y) { drawCookiemanSprite(ctx, x,y, dir, 1, true); }, row, col+1);
            drawAtCell(function(x,y) { drawCookiemanSprite(ctx, x,y, dir, 2, true); }, row, col+2);
        };
        row++;
        (function(){
            for (let col=0, i=0; i<4; i++, col+=3) {
                drawCookieCells(row,col,i);
            }
        })();

        const drawMonsterCells = function(row,color) {
            for (let col=0, i=0; i<4; i++) { // dirEnum
                for (let f=0; f<2; f++, col++) { // frame
                    drawAtCell(function(x,y) { drawMonsterSprite(ctx, x,y, f, i, false, false, false, color); },   row,col);
                }
            }
        };

        row++;
        drawMonsterCells(row, "#FF0000");
        row++;
        drawMonsterCells(row, "#FFB8FF");
        row++;
        drawMonsterCells(row, "#00FFFF");
        row++;
        drawMonsterCells(row, "#FFB851");

        row++;
        (function(){
            for (let col=0, i=0; i<4; i++, col++) { // dirEnum
                drawAtCell(function(x,y) { drawMonsterSprite(ctx, x,y, 0, i, false, false, true, "#fff"); },     row,col);
            }
        })();
        drawAtCell(function(x,y) { drawMonsterSprite(ctx, x,y, 0, DIR_UP, true, false, false, "#fff"); }, row,4);
        drawAtCell(function(x,y) { drawMonsterSprite(ctx, x,y, 1, DIR_UP, true, false, false, "#fff"); }, row,5);
        drawAtCell(function(x,y) { drawMonsterSprite(ctx, x,y, 0, DIR_UP, true, true, false, "#fff"); },  row,6);
        drawAtCell(function(x,y) { drawMonsterSprite(ctx, x,y, 1, DIR_UP, true, true, false, "#fff"); },  row,7);

        const drawOttoCells = function(row,col,dir) {
            for (let i=0; i<4; i++, col++) { // frame
                drawAtCell(function(x,y) { drawOttoSprite(ctx, x,y, dir, i); }, row, col);
            }
        };
        row++;
        drawOttoCells(row,0, DIR_UP);
        drawOttoCells(row,4, DIR_RIGHT);
        row++;
        drawOttoCells(row,0, DIR_DOWN);
        drawOttoCells(row,4, DIR_LEFT);

        row++;
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 200, "#33ffff"); }, row, 0);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 400, "#33ffff"); }, row, 1);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 800, "#33ffff"); }, row, 2);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 1600, "#33ffff");}, row, 3);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 100, "#ffb8ff"); }, row, 4);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 300, "#ffb8ff"); }, row, 5);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 500, "#ffb8ff"); }, row, 6);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 700, "#ffb8ff"); }, row, 7);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 1000, "#ffb8ff"); }, row, 8);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 2000, "#ffb8ff"); }, row, 9);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 3000, "#ffb8ff"); }, row, 10);
        drawAtCell(function(x,y) { drawPacPoints(ctx, x,y, 5000, "#ffb8ff"); }, row, 11);
        row++;
        drawAtCell(function(x,y) { drawMsPacPoints(ctx, x,y, 100, "#fff"); }, row, 0);
        drawAtCell(function(x,y) { drawMsPacPoints(ctx, x,y, 200, "#fff"); }, row, 1);
        drawAtCell(function(x,y) { drawMsPacPoints(ctx, x,y, 500, "#fff"); }, row, 2);
        drawAtCell(function(x,y) { drawMsPacPoints(ctx, x,y, 700, "#fff"); }, row, 3);
        drawAtCell(function(x,y) { drawMsPacPoints(ctx, x,y, 1000, "#fff"); }, row, 4);
        drawAtCell(function(x,y) { drawMsPacPoints(ctx, x,y, 2000, "#fff"); }, row, 5);
        drawAtCell(function(x,y) { drawMsPacPoints(ctx, x,y, 5000, "#fff"); }, row, 6);

        row++;
        drawAtCell(function(x,y) {
            drawSnail(ctx,x,y, "#0ff");
        }, row, 0);
        drawAtCell(function(x,y) {
            drawSnail(ctx,x,y, "#FFF");
        }, row, 1);

        const drawMsOttoCells = function(row,col,dir) {
            for (let i=0; i<4; i++, col++) { // frame
                drawAtCell(function(x,y) { drawMsOttoSprite(ctx, x,y, dir, i); }, row, col);
            }
        };
        row++;
        drawMsOttoCells(row,0, DIR_UP);
        drawMsOttoCells(row,4, DIR_RIGHT);
        row++;
        drawMsOttoCells(row,0, DIR_DOWN);
        drawMsOttoCells(row,4, DIR_LEFT);

    };

    const copyCellTo = function(row, col, destCtx, x, y,display) {
        const sx = col*size*renderScale;
        const sy = row*size*renderScale;
        const sw = renderScale*size;
        const sh = renderScale*size;

        const dx = x - size/2;
        const dy = y - size/2;
        const dw = size;
        const dh = size;

        if (display) {
            console.log(sx,sy,sw,sh,dw,dy,dw,dh);
        }

        destCtx.drawImage(canvas,sx,sy,sw,sh,dx,dy,dw,dh);
    };

    const copyGhostPoints = function(destCtx,x,y,points) {
        const row = 16;
        const col = {
            200: 0,
            400: 1,
            800: 2,
            1600: 3,
        }[points];
        if (col != undefined) {
            copyCellTo(row, col, destCtx, x, y);
        }
    };

    const copyPacFruitPoints = function(destCtx,x,y,points) {
        const row = 16;
        const col = {
            100: 4,
            300: 5,
            500: 6,
            700: 7,
            1000: 8,
            2000: 9,
            3000: 10,
            5000: 11,
        }[points];
        if (col != undefined) {
            copyCellTo(row, col, destCtx, x, y);
        }
    };

    const copyMsPacFruitPoints = function(destCtx,x,y,points) {
        const row = 17;
        const col = {
            100: 0,
            200: 1,
            500: 2,
            700: 3,
            1000: 4,
            2000: 5,
            5000: 6,
        }[points];
        if (col != undefined) {
            copyCellTo(row, col, destCtx, x, y);
        }
    };

    const copyGhostSprite = function(destCtx,x,y,frame,dirEnum,scared,flash,eyes_only,color) {
        let row,col;
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

    const copyMuppetSprite = function(destCtx,x,y,frame,dirEnum,scared,flash,eyes_only,color) {
        if (scared) {
            if (flash) {
                copyFruitSprite(destCtx,x,y,"cookieface");
            }
            else {
                copyFruitSprite(destCtx,x,y,"cookie");
            }
        }
        else {
            copyGhostSprite(destCtx,x,y,frame,dirEnum,scared,flash,eyes_only,color);
        }
    };

    const copyMonsterSprite = function(destCtx,x,y,frame,dirEnum,scared,flash,eyes_only,color) {
        let row,col;
        if (eyes_only) {
            row = 13;
            col = dirEnum;
        }
        else if (scared) {
            row = 13;
            col = flash ? 6 : 4;
            col += frame;
        }
        else {
            col = dirEnum*2 + frame;
            if (color == blinky.color) {
                row = 9;
            }
            else if (color == pinky.color) {
                row = 10;
            }
            else if (color == inky.color) {
                row = 11;
            }
            else if (color == clyde.color) {
                row = 12;
            }
            else {
                row = 13;
            }
        }

        copyCellTo(row, col, destCtx, x, y);
    };

    const copyOttoSprite = function(destCtx,x,y,dirEnum,frame) {
        let col,row;
        if (dirEnum == DIR_UP) {
            col = frame;
            row = 14;
        }
        else if (dirEnum == DIR_RIGHT) {
            col = frame+4;
            row = 14;
        }
        else if (dirEnum == DIR_DOWN) {
            col = frame;
            row = 15;
        }
        else if (dirEnum == DIR_LEFT) {
            col = frame+4;
            row = 15;
        }
        copyCellTo(row,col,destCtx,x,y);
    };

    const copyMsOttoSprite = function(destCtx,x,y,dirEnum,frame) {
        let col,row;
        if (dirEnum == DIR_UP) {
            col = frame;
            row = 19;
        }
        else if (dirEnum == DIR_RIGHT) {
            col = frame+4;
            row = 19;
        }
        else if (dirEnum == DIR_DOWN) {
            col = frame;
            row = 20;
        }
        else if (dirEnum == DIR_LEFT) {
            col = frame+4;
            row = 20;
        }
        copyCellTo(row,col,destCtx,x,y);
    };

    const copySnail = function(destCtx,x,y,frame) {
        const row = 18;
        const col = frame;
        copyCellTo(row,col,destCtx,x,y);
    };

    const copyPacmanSprite = function(destCtx,x,y,dirEnum,frame) {
        const row = 6;
        let col;
        if (frame == 0) {
            col = 0;
        }
        else {
           col = dirEnum*2+1+(frame-1);
        }
        copyCellTo(row,col,destCtx,x,y);
    };

    const copyMsPacmanSprite = function(destCtx,x,y,dirEnum,frame) {
        // TODO: determine row, col
        //copyCellTo(row,col,destCtx,x,y);
        const row = 7;
        const col = dirEnum*3+frame;
        copyCellTo(row,col,destCtx,x,y);
    };

    const copyCookiemanSprite = function(destCtx,x,y,dirEnum,frame) {
        const row = 8;
        const col = dirEnum*3+frame;
        copyCellTo(row,col,destCtx,x,y);
    };

    const copyFruitSprite = function(destCtx,x,y,name) {
        const row = 0;
        const col = {
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
            "cookieface": 12,
        }[name];

        copyCellTo(row,col,destCtx,x,y);
    };

    return {
        create: create,
        getCanvas: function() { return canvas; },
        drawGhostSprite: copyGhostSprite,
        drawMonsterSprite: copyMonsterSprite,
        drawMuppetSprite: copyMuppetSprite,
        drawOttoSprite: copyOttoSprite,
        drawMsOttoSprite: copyMsOttoSprite,
        drawPacmanSprite: copyPacmanSprite,
        drawMsPacmanSprite: copyMsPacmanSprite,
        drawCookiemanSprite: copyCookiemanSprite,
        drawFruitSprite: copyFruitSprite,
        drawGhostPoints: copyGhostPoints,
        drawPacFruitPoints: copyPacFruitPoints,
        drawMsPacFruitPoints: copyMsPacFruitPoints,
        drawSnail: copySnail,
    };
})();
