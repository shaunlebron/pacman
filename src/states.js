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
    if (executive.isPaused()) {
        executive.togglePause();
    }
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
                if (frames == frameDuration/2) {
                    nextState.init();
                }
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
        switchState(s);
        menu.disable();
    };

    var menu = new Menu("ARCADE",2*tileSize,-2*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    var getIconAnimFrame = function(frame) {
        frame = Math.floor(frame/3)+1;
        frame %= 4;
        if (frame == 3) {
            frame = 1;
        }
        return frame;
    };
    var getOttoAnimFrame = function(frame) {
        frame = Math.floor(frame/3);
        frame %= 4;
        return frame;
    };
    menu.addTextIconButton(getGameName(GAME_PACMAN),
        function() {
            gameMode = GAME_PACMAN;
            exitTo(preNewGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawPacmanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame));
        });
    menu.addTextIconButton(getGameName(GAME_MSPACMAN),
        function() {
            gameMode = GAME_MSPACMAN;
            exitTo(preNewGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawMsPacmanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame));
        });
    menu.addTextIconButton(getGameName(GAME_OTTO),
        function() {
            gameMode = GAME_OTTO;
            exitTo(preNewGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawOttoSprite(ctx,x,y,DIR_RIGHT,getOttoAnimFrame(frame));
        });
    menu.addTextIconButton(getGameName(GAME_COOKIE),
        function() {
            gameMode = GAME_COOKIE;
            exitTo(preNewGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawCookiemanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame));
        });

    menu.addSpacer(0.5);
    menu.addTextIconButton("LEARN",
        function() {
            exitTo(learnState);
        },
        function(ctx,x,y,frame) {
            atlas.drawGhostSprite(ctx,x,y,Math.floor(frame/8)%2,DIR_RIGHT,false,false,false,blinky.color);
        });

    menu.addSpacer(0.5);
    menu.addTextButton("SCORES",
        function() {
            exitTo(scoreState);
        });
    menu.addTextButton("CREDITS",
        function() {
            exitTo(aboutState);
        });

    return {
        init: function() {
            menu.enable();
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.beginMapClip();
            renderer.renderFunc(menu.draw,menu);
            renderer.endMapClip();
        },
        update: function() {
            menu.update();
        },
        getMenu: function() {
            return menu;
        },
    };

})();

//////////////////////////////////////////////////////////////////////////////////////
// Learn State

var learnState = (function(){

    var exitTo = function(s) {
        switchState(s);
        menu.disable();
        forEachCharBtn(function (btn) {
            btn.disable();
        });
        setAllVisibility(true);
        clearCheats();
    };

    var menu = new Menu("LEARN", 2*tileSize,-tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    menu.addSpacer(7);
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];
    menu.noArrowKeys = true;

    var pad = tileSize;
    var w = 30;
    var h = 30;
    var x = mapWidth/2 - 2*(w) - 1.5*pad;
    var y = 4*tileSize;
    var redBtn = new Button(x,y,w,h,function(){
        setAllVisibility(false);
        blinky.isVisible = true;
        setVisibility(blinky,true);
    });
    redBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_DOWN,undefined,undefined,undefined,blinky.color);
    });
    x += w+pad;
    var pinkBtn = new Button(x,y,w,h,function(){
        setAllVisibility(false);
        setVisibility(pinky,true);
    });
    pinkBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_DOWN,undefined,undefined,undefined,pinky.color);
    });
    x += w+pad;
    var cyanBtn = new Button(x,y,w,h,function(){
        setAllVisibility(false);
        setVisibility(inky,true);
    });
    cyanBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_DOWN,undefined,undefined,undefined,inky.color);
    });
    x += w+pad;
    var orangeBtn = new Button(x,y,w,h,function(){
        setAllVisibility(false);
        setVisibility(clyde,true);
    });
    orangeBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_DOWN,undefined,undefined,undefined,clyde.color);
    });
    var forEachCharBtn = function(callback) {
        callback(redBtn);
        callback(pinkBtn);
        callback(cyanBtn);
        callback(orangeBtn);
    };

    var setVisibility = function(g,visible) {
        g.isVisible = g.isDrawTarget = g.isDrawPath = visible;
    };

    var setAllVisibility = function(visible) {
        setVisibility(blinky,visible);
        setVisibility(pinky,visible);
        setVisibility(inky,visible);
        setVisibility(clyde,visible);
    };

    return {
        init: function() {

            menu.enable();
            forEachCharBtn(function (btn) {
                btn.enable();
            });

            // set map
            map = mapLearn;
            renderer.drawMap();

            // set game parameters
            level = 1;
            practiceMode = false;
            turboMode = false;
            gameMode = GAME_PACMAN;

            // reset relevant game state
            ghostCommander.reset();
            energizer.reset();
            ghostCommander.setCommand(GHOST_CMD_CHASE);
            ghostReleaser.onNewLevel();
            elroyTimer.onNewLevel();

            // set ghost states
            for (i=0; i<4; i++) {
                var a = actors[i];
                a.reset();
                a.mode = GHOST_OUTSIDE;
            }
            blinky.setPos(14*tileSize-1, 13*tileSize+midTile.y);
            pinky.setPos(15*tileSize+midTile.x, 13*tileSize+midTile.y);
            inky.setPos(9*tileSize+midTile.x, 16*tileSize+midTile.y);
            clyde.setPos(18*tileSize+midTile.x, 16*tileSize+midTile.y);

            // set pacman state
            pacman.reset();
            pacman.setPos(14*tileSize-1,22*tileSize+midTile.y);

            // start with red ghost
            redBtn.onclick();

        },
        draw: function() {
            renderer.blitMap();
            renderer.renderFunc(menu.draw,menu);
            forEachCharBtn(function (btn) {
                renderer.renderFunc(btn.draw,btn);
            });
            renderer.beginMapClip();
            renderer.drawPaths();
            renderer.drawActors();
            renderer.drawTargets();
            renderer.endMapClip();
        },
        update: function() {
            menu.update();
            forEachCharBtn(function (btn) {
                btn.update();
            });
            for (j=0; j<2; j++) {
                pacman.update(j);
                for (i=0;i<4;i++) {
                    actors[i].update(j);
                }
            }
            for (i=0; i<5; i++)
                actors[i].frames++;
        },
        getMenu: function() {
            return menu;
        },
    };

})();

//////////////////////////////////////////////////////////////////////////////////////
// Pre New Game State
// (the screen shown to select final options before starting a game)

var preNewGameState = (function() {

    var exitTo = function(s,fade) {
        switchState(s,fade);
        menu.disable();
        forEachCharBtn(function (btn) {
            btn.disable();
        });
    };

    var menu = new Menu("",2*tileSize,0,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");

    menu.addSpacer(3);
    menu.addTextButton("PLAY",
        function() { 
            practiceMode = false;
            turboMode = false;
            exitTo(newGameState, 60);
        });
    menu.addTextButton("PLAY TURBO",
        function() { 
            practiceMode = false;
            turboMode = true;
            exitTo(newGameState, 60);
        });
    menu.addTextButton("PRACTICE",
        function() { 
            practiceMode = true;
            turboMode = false;
            exitTo(newGameState, 60);
        });
    menu.addSpacer();
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];

    var name,nameColor;

    var w = 20;
    var h = 30;
    var x = mapWidth/2 - 3*w;
    var y = 8*tileSize;
    var yellowBtn = new Button(x,y,w,h,function(){
        name = getGameName();
        nameColor = pacman.color;
    });
    yellowBtn.setIcon(function (ctx,x,y,frame) {
        getPlayerDrawFunc()(ctx,x,y,DIR_RIGHT,pacman.getAnimFrame(pacman.getStepFrame(Math.floor(frame/1.5))));
    });
    x += 2*w;
    var redBtn = new Button(x,y,w,h,function(){
        name = getGhostNames()[0];
        nameColor = blinky.color;
    });
    redBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_LEFT,undefined,undefined,undefined,blinky.color);
    });
    x += w;
    var pinkBtn = new Button(x,y,w,h,function(){
        name = getGhostNames()[1];
        nameColor = pinky.color;
    });
    pinkBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_LEFT,undefined,undefined,undefined,pinky.color);
    });
    x += w;
    var cyanBtn = new Button(x,y,w,h,function(){
        name = getGhostNames()[2];
        nameColor = inky.color;
    });
    cyanBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_LEFT,undefined,undefined,undefined,inky.color);
    });
    x += w;
    var orangeBtn = new Button(x,y,w,h,function(){
        name = getGhostNames()[3];
        nameColor = clyde.color;
    });
    orangeBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_LEFT,undefined,undefined,undefined,clyde.color);
    });
    
    var forEachCharBtn = function(callback) {
        callback(yellowBtn);
        callback(redBtn);
        callback(pinkBtn);
        callback(cyanBtn);
        callback(orangeBtn);
    };
    forEachCharBtn(function(btn) {
        btn.borderBlurColor = btn.borderFocusColor = "#000";
    });

    return {
        init: function() {
            name = getGameName();
            nameColor = "#FFF";
            //menu.title = getGameName();
            menu.enable();
            forEachCharBtn(function (btn) {
                btn.enable();
            });
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.renderFunc(menu.draw,menu);

            forEachCharBtn(function (btn) {
                renderer.renderFunc(btn.draw,btn);
            });

            renderer.renderFunc(function(ctx){
                ctx.font = tileSize+"px ArcadeR";
                ctx.fillStyle = nameColor;
                ctx.textAlign = "center";
                ctx.textBaseline = "top";
                ctx.fillText(name, mapWidth/2, 6*tileSize);
            });
        },
        update: function() {
            forEachCharBtn(function (btn) {
                btn.update();
                if (btn.isSelected) {
                    btn.onclick();
                }
            });
        },
        getMenu: function() {
            return menu;
        },
    };
})();

//////////////////////////////////////////////////////////////////////////////////////
// Score State
// (the high score screen state)

var scoreState = (function(){

    var exitTo = function(s) {
        switchState(s);
        menu.disable();
    };

    var menu = new Menu("", 2*tileSize,mapHeight-6*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];

    var frame = 0;

    var bulbs = {};
    var numBulbs;
    (function(){
        var x = -1.5*tileSize;
        var y = -1*tileSize;
        var w = 18*tileSize;
        var h = 29*tileSize;
        var s = 3;

        var i=0;
        var x0 = x;
        var y0 = y;
        var addBulb = function(x,y) { bulbs[i++] = { x:x, y:y }; };
        for (; y0<y+h; y0+=s) { addBulb(x0,y0); }
        for (; x0<x+w; x0+=s) { addBulb(x0,y0); }
        for (; y0>y; y0-=s) { addBulb(x0,y0); }
        for (; x0>x; x0-=s) { addBulb(x0,y0); }

        numBulbs = i;
    })();

    var drawScoreBox = function(ctx) {

        // draw chaser lights around the marquee
        ctx.fillStyle = "#555";
        var i,b,s=2;
        for (i=0; i<numBulbs; i++) {
            b = bulbs[i];
            ctx.fillRect(b.x, b.y, s, s);
        }
        ctx.fillStyle = "#FFF";
        for (i=0; i<63; i++) {
            b = bulbs[(i*4+Math.floor(frame/2))%numBulbs];
            ctx.fillRect(b.x, b.y, s, s);
        }

        ctx.font = tileSize+"px ArcadeR";
        ctx.textBaseline = "top";
        ctx.textAlign = "right";
        var scoreColor = "#AAA";
        var captionColor = "#444";

        var x,y;
        x = 9*tileSize;
        y = 0;
        ctx.fillStyle = "#FFF"; ctx.fillText("HIGH SCORES", x+4*tileSize,y);
        y += tileSize*4;

        var drawContrails = function(x,y) {
            ctx.lineWidth = 1.0;
            ctx.lineCap = "round";
            ctx.strokeStyle = "rgba(255,255,255,0.5)";

            ctx.save();
            ctx.translate(-2.5,0);

            var dy;
            for (dy=-4; dy<=4; dy+=2) {
                ctx.beginPath();
                ctx.moveTo(x+tileSize,y+dy);
                ctx.lineTo(x+tileSize*(Math.random()*0.5+1.5),y+dy);
                ctx.stroke();
            }
            ctx.restore();

        };

        ctx.fillStyle = scoreColor; ctx.fillText(highScores[0], x,y);
        atlas.drawPacmanSprite(ctx,x+2*tileSize,y+tileSize/2,DIR_LEFT,1);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[1], x,y);
        drawContrails(x+2*tileSize,y+tileSize/2);
        atlas.drawPacmanSprite(ctx,x+2*tileSize,y+tileSize/2,DIR_LEFT,1);

        y += tileSize*3;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[2], x,y);
        atlas.drawMsPacmanSprite(ctx,x+2*tileSize,y+tileSize/2,DIR_LEFT,1);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[3], x,y);
        drawContrails(x+2*tileSize,y+tileSize/2);
        atlas.drawMsPacmanSprite(ctx,x+2*tileSize,y+tileSize/2,DIR_LEFT,1);

        y += tileSize*3;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[6], x,y);
        atlas.drawOttoSprite(ctx,x+2*tileSize,y+tileSize/2,DIR_LEFT,0);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[7], x,y);
        drawContrails(x+2*tileSize,y+tileSize/2);
        atlas.drawOttoSprite(ctx,x+2*tileSize,y+tileSize/2,DIR_LEFT,0);

        y += tileSize*3;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[4], x,y);
        atlas.drawCookiemanSprite(ctx,x+2*tileSize,y+tileSize/2,DIR_LEFT,1);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[5], x,y);
        drawContrails(x+2*tileSize,y+tileSize/2);
        atlas.drawCookiemanSprite(ctx,x+2*tileSize,y+tileSize/2,DIR_LEFT,1);
    };

    var drawFood = function(ctx) {
        ctx.globalAlpha = 0.5;
        ctx.font = tileSize + "px sans-serif";
        ctx.textBaseline = "middle";
        ctx.textAlign = "left";

        var x = 20*tileSize;
        var y = 0;

        ctx.fillStyle = "#ffb8ae";
        ctx.fillRect(x-1,y-1.5,2,2);
        ctx.fillStyle = "#FFF";
        ctx.fillText("10",x+tileSize,y);
        y += 1.5*tileSize;

        ctx.fillStyle = "#ffb8ae";
        ctx.beginPath();
        ctx.arc(x,y-0.5,tileSize/2,0,Math.PI*2);
        ctx.fill();
        ctx.fillStyle = "#FFF";
        ctx.fillText("50",x+tileSize,y);

        y += 3*tileSize;
        atlas.drawGhostSprite(ctx,x,y,0,DIR_RIGHT,true);
        atlas.drawGhostPoints(ctx,x+2*tileSize,y,200);

        var alpha = ctx.globalAlpha;

        y += 2*tileSize;
        ctx.globalAlpha = alpha*0.5;
        atlas.drawGhostSprite(ctx,x,y,0,DIR_RIGHT,true);
        ctx.globalAlpha = alpha;
        atlas.drawGhostSprite(ctx,x+2*tileSize,y,0,DIR_RIGHT,true);
        atlas.drawGhostPoints(ctx,x+4*tileSize,y,400);

        y += 2*tileSize;
        ctx.globalAlpha = alpha*0.5;
        atlas.drawGhostSprite(ctx,x,y,0,DIR_RIGHT,true);
        atlas.drawGhostSprite(ctx,x+2*tileSize,y,0,DIR_RIGHT,true);
        ctx.globalAlpha = alpha;
        atlas.drawGhostSprite(ctx,x+4*tileSize,y,0,DIR_RIGHT,true);
        atlas.drawGhostPoints(ctx,x+6*tileSize,y,800);

        y += 2*tileSize;
        ctx.globalAlpha = alpha*0.5;
        atlas.drawGhostSprite(ctx,x,y,0,DIR_RIGHT,true);
        atlas.drawGhostSprite(ctx,x+2*tileSize,y,0,DIR_RIGHT,true);
        atlas.drawGhostSprite(ctx,x+4*tileSize,y,0,DIR_RIGHT,true);
        ctx.globalAlpha = alpha;
        atlas.drawGhostSprite(ctx,x+6*tileSize,y,0,DIR_RIGHT,true);
        atlas.drawGhostPoints(ctx,x+8*tileSize,y,1600);

        var mspac_fruits = [
            {name: 'cherry',     points: 100},
            {name: 'strawberry', points: 200},
            {name: 'orange',     points: 500},
            {name: 'pretzel',    points: 700},
            {name: 'apple',      points: 1000},
            {name: 'pear',       points: 2000},
            {name: 'banana',     points: 5000},
        ];

        var pac_fruits = [
            {name:'cherry',     points:100},
            {name:'strawberry', points:300},
            {name:'orange',     points:500},
            {name:'apple',      points:700},
            {name:'melon',      points:1000},
            {name:'galaxian',   points:2000},
            {name:'bell',       points:3000},
            {name:'key',        points:5000},
        ];

        var i,f;
        y += 3*tileSize;
        for (i=0; i<pac_fruits.length; i++) {
            f = pac_fruits[i];
            atlas.drawFruitSprite(ctx,x,y,f.name);
            atlas.drawPacFruitPoints(ctx,x+2*tileSize,y,f.points);
            y += 2*tileSize;
        }
        x += 6*tileSize;
        y = 13.5*tileSize;
        for (i=0; i<mspac_fruits.length; i++) {
            f = mspac_fruits[i];
            atlas.drawFruitSprite(ctx,x,y,f.name);
            atlas.drawMsPacFruitPoints(ctx,x+2*tileSize,y,f.points);
            y += 2*tileSize;
        }
        ctx.globalAlpha = 1;
    };

    return {
        init: function() {
            menu.enable();
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.renderFunc(drawScoreBox);
            renderer.renderFunc(drawFood);
            renderer.renderFunc(menu.draw,menu);
        },
        update: function() {
            menu.update();
            frame++;
        },
        getMenu: function() {
            return menu;
        },
    };

})();

//////////////////////////////////////////////////////////////////////////////////////
// About State
// (the about screen state)

var aboutState = (function(){

    var exitTo = function(s) {
        switchState(s);
        menu.disable();
    };

    var menu = new Menu("", 2*tileSize,mapHeight-11*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    menu.addTextButton("GO TO PROJECT PAGE",
        function() {
            window.open("https://github.com/shaunew/Pac-Man");
        });
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];

    var drawBody = function(ctx) {
        ctx.font = tileSize+"px ArcadeR";
        ctx.textBaseline = "top";
        ctx.textAlign = "left";

        var x,y;
        x = 2*tileSize;
        y = 0*tileSize;
        ctx.fillStyle = "#0FF";
        ctx.fillText("DEVELOPER", x,y);
        y += tileSize*2;
        ctx.fillStyle = "#777";
        ctx.fillText("SHAUN WILLIAMS", x,y);

        y += tileSize*4;
        ctx.fillStyle = "#0FF";
        ctx.fillText("REVERSE-ENGINEERS",x,y);
        y += tileSize*2;
        ctx.fillStyle = "#777";
        ctx.fillText("JAMEY PITTMAN",x,y);
        y += tileSize*2;
        ctx.fillText("BART GRANTHAM",x,y);

        y += tileSize*4;
        ctx.fillStyle = "#FF0";
        ctx.fillText("PAC-MAN",x,y);
        y += tileSize*2;
        ctx.fillStyle = "#777";
        ctx.fillText("NAMCO",x,y);

        y += tileSize*4;
        ctx.fillStyle = "#FF0";
        ctx.fillText("MS. PAC-MAN / CRAZY OTTO",x,y);
        y += tileSize*2;
        ctx.fillStyle = "#777";
        ctx.fillText("GENERAL COMPUTING",x,y);
    };

    return {
        init: function() {
            menu.enable();
            galagaStars.init();
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.beginMapClip();
            renderer.renderFunc(galagaStars.draw);
            renderer.renderFunc(drawBody);
            renderer.renderFunc(menu.draw,menu);
            renderer.endMapClip();
        },
        update: function() {
            galagaStars.update();
            menu.update();
        },
        getMenu: function() {
            return menu;
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
            extraLives = practiceMode ? Infinity : 3;
            setScore(0);
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
            vcr.init();
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
        else if (gameMode == GAME_MSPACMAN || gameMode == GAME_OTTO) {
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
    init: function() { 
        if (practiceMode) {
            vcr.reset();
        }
    },
    draw: function() {
        renderer.blitMap();
        renderer.drawScore();
        renderer.beginMapClip();
        renderer.drawFruit();
        renderer.drawPaths();
        renderer.drawActors();
        renderer.drawTargets();
        renderer.endMapClip();
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
        
        if (vcr.isSeeking()) {
            vcr.seek();
        }
        else {
            // record current state
            if (vcr.getMode() == VCR_RECORD) {
                vcr.record();
            }

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
            if (vcr.isSeeking()) {
                vcr.seek();
            }
            else {
                if (vcr.getMode() == VCR_RECORD) {
                    vcr.record();
                }
                scriptState.update.call(this);
            }
        },
        draw: function() {
            if (this.drawFunc) {
                scriptState.draw.call(this);
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
            renderer.drawMessage("GAME  OVER", "#F00");
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
