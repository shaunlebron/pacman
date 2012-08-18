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

    var menu = new Menu("ARCADE",2*tileSize,0,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    var getIconAnimFrame = function(frame) {
        frame = Math.floor(frame/3)+1;
        frame %= 4;
        if (frame == 3) {
            frame = 1;
        }
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
    menu.addTextIconButton(getGameName(GAME_COOKIE),
        function() {
            gameMode = GAME_COOKIE;
            exitTo(preNewGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawCookiemanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame));
        });
    /*
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
    */
    menu.addSpacer(1.5);
    menu.addTextButton("HIGH SCORES",
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
    };

})();

//////////////////////////////////////////////////////////////////////////////////////
// Pre New Game State
// (the screen shown to select final options before starting a game)

var preNewGameState = (function() {

    var exitTo = function(s,fade) {
        switchState(s,fade);
        menu.disable();
    };

    var menu = new Menu("GAMENAME",2*tileSize,0,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");

    menu.addTextButton("PLAY",
        function() { 
            clearCheats();
            practiceMode = false;
            turboMode = false;
            exitTo(newGameState, 60);
        });
    menu.addTextButton("PLAY TURBO",
        function() { 
            clearCheats();
            practiceMode = false;
            turboMode = true;
            exitTo(newGameState, 60);
        });
    menu.addTextButton("PRACTICE",
        function() { 
            clearCheats();
            practiceMode = true;
            turboMode = false;
            exitTo(newGameState, 60);
        });
    menu.addSpacer();
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });

    return {
        init: function() {
            menu.title = getGameName();
            menu.enable();
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.renderFunc(menu.draw,menu);
        },
        update: function() {
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
        x = 7*tileSize;
        y = 0;
        ctx.fillStyle = "#FFF"; ctx.fillText("HIGH SCORES", x+6*tileSize,y);
        y += tileSize*4;

        ctx.fillStyle = "#FF0"; ctx.fillText(getGameName(GAME_PACMAN), x+4*tileSize,y);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[0], x,y);
        ctx.fillStyle = captionColor; ctx.fillText("NORMAL", x+7*tileSize,y);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[1], x,y);
        ctx.fillStyle = captionColor; ctx.fillText("TURBO", x+6*tileSize,y);

        y += tileSize*4;
        ctx.fillStyle = "#FFB8AE"; ctx.fillText(getGameName(GAME_MSPACMAN), x+4*tileSize,y);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[2], x,y);
        ctx.fillStyle = captionColor; ctx.fillText("NORMAL", x+7*tileSize,y);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[3], x,y);
        ctx.fillStyle = captionColor; ctx.fillText("TURBO", x+6*tileSize,y);

        y += tileSize*4;
        ctx.fillStyle = "#359c9c"; ctx.fillText(getGameName(GAME_COOKIE), x+4*tileSize,y);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[4], x,y);
        ctx.fillStyle = captionColor; ctx.fillText("NORMAL", x+7*tileSize,y);
        y += tileSize*2;
        ctx.fillStyle = scoreColor; ctx.fillText(highScores[5], x,y);
        ctx.fillStyle = captionColor; ctx.fillText("TURBO", x+6*tileSize,y);
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
        ctx.fillText("200",x+tileSize,y);

        var alpha = ctx.globalAlpha;

        y += 2*tileSize;
        ctx.globalAlpha = alpha*0.5;
        atlas.drawGhostSprite(ctx,x,y,0,DIR_RIGHT,true);
        ctx.globalAlpha = alpha;
        atlas.drawGhostSprite(ctx,x+2*tileSize,y,0,DIR_RIGHT,true);
        ctx.fillText("400",x+3*tileSize,y);

        y += 2*tileSize;
        ctx.globalAlpha = alpha*0.5;
        atlas.drawGhostSprite(ctx,x,y,0,DIR_RIGHT,true);
        atlas.drawGhostSprite(ctx,x+2*tileSize,y,0,DIR_RIGHT,true);
        ctx.globalAlpha = alpha;
        atlas.drawGhostSprite(ctx,x+4*tileSize,y,0,DIR_RIGHT,true);
        ctx.fillText("800",x+5*tileSize,y);

        y += 2*tileSize;
        ctx.globalAlpha = alpha*0.5;
        atlas.drawGhostSprite(ctx,x,y,0,DIR_RIGHT,true);
        atlas.drawGhostSprite(ctx,x+2*tileSize,y,0,DIR_RIGHT,true);
        atlas.drawGhostSprite(ctx,x+4*tileSize,y,0,DIR_RIGHT,true);
        ctx.globalAlpha = alpha;
        atlas.drawGhostSprite(ctx,x+6*tileSize,y,0,DIR_RIGHT,true);
        ctx.fillText("1600",x+7*tileSize,y);

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
        ctx.fillStyle = "#FFF";
        for (i=0; i<pac_fruits.length; i++) {
            f = pac_fruits[i];
            atlas.drawFruitSprite(ctx,x,y,f.name);
            ctx.fillText(f.points,x+tileSize,y);
            y += 2*tileSize;
        }
        x += 6*tileSize;
        y = 13.5*tileSize;
        for (i=0; i<mspac_fruits.length; i++) {
            f = mspac_fruits[i];
            atlas.drawFruitSprite(ctx,x,y,f.name);
            ctx.fillText(f.points,x+tileSize,y);
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

    var menu = new Menu("", 2*tileSize,mapHeight-6*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });

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
        ctx.fillText("ORIGINAL PAC-MAN",x,y);
        y += tileSize*2;
        ctx.fillStyle = "#777";
        ctx.fillText("NAMCO",x,y);

        y += tileSize*4;
        ctx.fillStyle = "#FF0";
        ctx.fillText("ORIGINAL MS. PAC-MAN",x,y);
        y += tileSize*2;
        ctx.fillStyle = "#777";
        ctx.fillText("GENERAL COMPUTING",x,y);

        y += tileSize*4;
        ctx.fillStyle = "#0F0";
        ctx.fillText("PROJECT SITE",x,y);
        y += tileSize*2;
        ctx.fillStyle = "#777";
        ctx.fillText("GITHUB.COM/SHAUNEW/PAC-MAN",x,y);
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
