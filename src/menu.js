menu = (function() {

    var w = 20*tileSize;
    var h = 7*tileSize;

    var pacmanRect =   {x:mapWidth/2-w/2,y:mapHeight/2-h/2-h,w:w,h:h};
    var mspacmanRect = {x:mapWidth/2-w/2,y:mapHeight/2-h/2,w:w,h:h};
    var cookieRect =   {x:mapWidth/2-w/2,y:mapHeight/2+h/2,w:w,h:h};

    var drawButton = function(ctx,rect,title,color) {

        // draw button outline
        //ctx.strokeStyle = "#FFF";
        //ctx.strokeRect(rect.x,rect.y,rect.w,rect.h);

        // draw caption
        ctx.fillStyle = color;
        ctx.fillText(title, rect.x + rect.w/2, rect.y + rect.h/2);
    };

    var inRect = function(pos, rect) {
        return pos.x >= rect.x && pos.x <= rect.x+rect.w &&
               pos.y >= rect.y && pos.y <= rect.y+rect.h;
    };

    var onmousedown = function(evt) {

        var pos = getmousepos(evt);
        if (inRect(pos,pacmanRect)) {
            gameMode = GAME_PACMAN;
        }
        else if (inRect(pos,mspacmanRect)) {
            gameMode = GAME_MSPACMAN;
        }
        else if (inRect(pos,cookieRect)) {
            gameMode = GAME_COOKIE;
        }
        else {
            return;
        }
        switchState(newGameState,60,true,false);
        canvas.removeEventListener('mousedown', onmousedown);
    };

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

    return {
        setInput: function() {
            canvas.addEventListener('mousedown', onmousedown);
        },
        draw: function(ctx) {
            // clear screen
            ctx.fillStyle = "#000";
            ctx.fillRect(0,0,mapWidth,mapHeight);

            // set text size and alignment
            ctx.font = (tileSize-1) + "px ArcadeR";
            ctx.textBaseline = "middle";
            ctx.textAlign = "center";

            drawButton(ctx, pacmanRect, "PAC-MAN (1980)", "#FF0");
            drawButton(ctx, mspacmanRect, "MS. PAC-MAN (1981)", "#FFB8AE");
            drawButton(ctx, cookieRect, "COOKIE-MAN (2012)", "#47b8ff");

            // TODO: draw previous and high score next to each game type.
            /*
            if (score != 0 && highScore != 0)
                this.drawScore();
            */
        },
    };

})();
