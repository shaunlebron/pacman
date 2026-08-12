
// REFERENCED GLOBALS:
// import { newChildObject } from './inherit.js';
// import { renderer, mapWidth, mapHeight } from './renderers.js';
// import { executive } from './executive.js';
// import { map, setMap, mapLearn, mapPacman, setNextMsPacMap, setNextCookieMap, getLevelAct, getActColor, getActRange, getMsPacActColor, getCookieActColor, mapMsPacman1, mapMsPacman2, mapMsPacman3, mapMsPacman4 } from './maps.js';
// import { tileSize, midTile } from './Map.js';
// import { actors, ghosts, pacman, blinky, pinky, inky, clyde } from './actors.js';
// import { ghostCommander, GHOST_CMD_CHASE } from './ghostCommander.js';
// import { ghostReleaser } from './ghostReleaser.js';
// import { elroyTimer } from './elroyTimer.js';
// import { energizer } from './energizer.js';
// import { fruit, setFruitFromGameMode } from './fruit.js';
// import { vcr, VCR_NONE, VCR_RECORD } from './vcr.js';
// import { galagaStars } from './galagaStars.js';
// import { gameMode, setGameMode, GAME_PACMAN, GAME_MSPACMAN, GAME_COOKIE, GAME_OTTO, level, setLevel, extraLives, setExtraLives, practiceMode, setPracticeMode, turboMode, setTurboMode, getScore, getHighScore, setScore, addScore, getGameName, getGameDescription, getGhostNames, getGhostDrawFunc, getPlayerDrawFunc, clearCheats, backupCheats, restoreCheats, saveGame, loadGame } from './game.js';
// import { GHOST_EATEN, GHOST_GOING_HOME, GHOST_ENTERING_HOME, GHOST_PACING_HOME, GHOST_LEAVING_HOME, GHOST_OUTSIDE } from './Ghost.js';
// import { DIR_LEFT, DIR_RIGHT, DIR_UP, DIR_DOWN } from './direction.js';
// import { cutscenes } from './cutscenes.js';
// import { Button } from './Button.js';
// import { Menu } from './Menu.js';
// import { atlas } from './atlas.js';
// import { getSpriteFuncFromFruitName, drawHeartSprite, drawPacmanSprite, drawMsPacmanSprite, drawCookiemanSprite, drawOttoSprite, drawMsOttoSprite, drawDeadOttoSprite, drawExclamationPoint } from './sprites.js';
// import { STEP_PACMAN, STEP_GHOST } from './Actor.js';

//////////////////////////////////////////////////////////////////////////////////////
// States
// (main loops for each state of the game)
// state is set to any of these states, each containing an init(), draw(), and update()

// current game state
let state;
const setState = function(s) { state = s; };

// switches to another game state
const switchState = function(nextState,fadeDuration, continueUpdate1, continueUpdate2) {
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
const fadeNextState = function (prevState, nextState, frameDuration, continueUpdate1, continueUpdate2) {
    let frames;
    const midFrame = Math.floor(frameDuration/2);
    const inFirstState = function() { return frames < midFrame; };
    const getStateTime = function() { return frames/frameDuration*2 + (inFirstState() ? 0 : -1); };
    let initialized = false;

    return {
        init: function() {
            frames = 0;
            initialized = true;
        },
        draw: function() {
            if (!initialized) return;
            const t = getStateTime();
            if (frames < midFrame) {
                if (prevState) {
                    prevState.draw();
                    renderer.setOverlayColor("rgba(0,0,0,"+t+")");
                }
            }
            else if (frames > midFrame) {
                nextState.draw();
                renderer.setOverlayColor("rgba(0,0,0,"+(1-t)+")");
            }
        },
        update: function() {

            // update prevState
            if (frames < midFrame) {
                if (continueUpdate1) {
                    prevState.update();
                }
            }
            // change to nextState
            else if (frames == midFrame) {
                nextState.init();
            }
            // update nextState
            else if (frames < frameDuration) {
                if (continueUpdate2) {
                    nextState.update();
                }
            }
            // hand over state to nextState
            else {
                state = nextState;
                initialized = false;
            }

            frames++;
        },
    }
};

//////////////////////////////////////////////////////////////////////////////////////
// Home State
// (the home title screen state)

const homeState = (function(){

    const exitTo = function(s) {
        switchState(s);
        menu.disable();
    };

    const menu = new Menu("CHOOSE A GAME",2*tileSize,0*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    const getIconAnimFrame = function(frame) {
        frame = Math.floor(frame/3)+1;
        frame %= 4;
        if (frame == 3) {
            frame = 1;
        }
        return frame;
    };
    const getOttoAnimFrame = function(frame) {
        frame = Math.floor(frame/3);
        frame %= 4;
        return frame;
    };
    menu.addTextIconButton(getGameName(GAME_PACMAN),
        function() {
            setGameMode(GAME_PACMAN);
            exitTo(preNewGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawPacmanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame));
        });
    menu.addTextIconButton(getGameName(GAME_MSPACMAN),
        function() {
            setGameMode(GAME_MSPACMAN);
            exitTo(preNewGameState);
        },
        function(ctx,x,y,frame) {
            atlas.drawMsPacmanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame));
        });
    menu.addTextIconButton(getGameName(GAME_COOKIE),
        function() {
            setGameMode(GAME_COOKIE);
            exitTo(preNewGameState);
        },
        function(ctx,x,y,frame) {
            drawCookiemanSprite(ctx,x,y,DIR_RIGHT,getIconAnimFrame(frame), true);
        });

    menu.addSpacer(0.5);
    menu.addTextIconButton("LEARN",
        function() {
            exitTo(learnState);
        },
        function(ctx,x,y,frame) {
            atlas.drawGhostSprite(ctx,x,y,Math.floor(frame/8)%2,DIR_RIGHT,false,false,false,blinky.color);
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

const learnState = (function(){

    const exitTo = function(s) {
        switchState(s);
        menu.disable();
        forEachCharBtn(function (btn) {
            btn.disable();
        });
        setAllVisibility(true);
        clearCheats();
    };

    const menu = new Menu("LEARN", 2*tileSize,-tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    menu.addSpacer(7);
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];
    menu.noArrowKeys = true;

    const pad = tileSize;
    const w = 30;
    const h = 30;
    let x = mapWidth/2 - 2*(w) - 1.5*pad;
    let y = 4*tileSize;
    const redBtn = new Button(x,y,w,h,function(){
        setAllVisibility(false);
        blinky.isVisible = true;
        setVisibility(blinky,true);
    });
    redBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_DOWN,undefined,undefined,undefined,blinky.color);
    });
    x += w+pad;
    const pinkBtn = new Button(x,y,w,h,function(){
        setAllVisibility(false);
        setVisibility(pinky,true);
    });
    pinkBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_DOWN,undefined,undefined,undefined,pinky.color);
    });
    x += w+pad;
    const cyanBtn = new Button(x,y,w,h,function(){
        setAllVisibility(false);
        setVisibility(inky,true);
    });
    cyanBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_DOWN,undefined,undefined,undefined,inky.color);
    });
    x += w+pad;
    const orangeBtn = new Button(x,y,w,h,function(){
        setAllVisibility(false);
        setVisibility(clyde,true);
    });
    orangeBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_DOWN,undefined,undefined,undefined,clyde.color);
    });
    const forEachCharBtn = function(callback) {
        callback(redBtn);
        callback(pinkBtn);
        callback(cyanBtn);
        callback(orangeBtn);
    };

    const setVisibility = function(g,visible) {
        g.isVisible = g.isDrawTarget = g.isDrawPath = visible;
    };

    const setAllVisibility = function(visible) {
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
            setMap(mapLearn);
            renderer.drawMap();

            // set game parameters
            setLevel(1);
            setPracticeMode(false);
            setTurboMode(false);
            setGameMode(GAME_PACMAN);

            // reset relevant game state
            ghostCommander.reset();
            energizer.reset();
            ghostCommander.setCommand(GHOST_CMD_CHASE);
            ghostReleaser.onNewLevel();
            elroyTimer.onNewLevel();

            // set ghost states
            for (const g of ghosts) {
                g.reset();
                g.mode = GHOST_OUTSIDE;
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
            for (let j=0; j<2; j++) {
                pacman.update(j);
                for (const g of ghosts) {
                    g.update(j);
                }
            }
            for (const a of actors)
                a.frames++;
        },
        getMenu: function() {
            return menu;
        },
    };

})();

//////////////////////////////////////////////////////////////////////////////////////
// Game Title
// (provides functions for managing the game title with clickable player and enemies below it)

const gameTitleState = (function() {

    let name,nameColor;

    const resetTitle = function() {
        if (yellowBtn.isSelected) {
            name = getGameName();
            nameColor = gameMode == GAME_COOKIE ? "#47b8ff" : pacman.color;
        }
        else if (redBtn.isSelected) {
            name = getGhostNames()[0];
            nameColor = blinky.color;
        }
        else if (pinkBtn.isSelected) {
            name = getGhostNames()[1];
            nameColor = pinky.color;
        }
        else if (cyanBtn.isSelected) {
            name = getGhostNames()[2];
            nameColor = inky.color;
        }
        else if (orangeBtn.isSelected) {
            name = getGhostNames()[3];
            nameColor = clyde.color;
        }
        else {
            name = getGameName();
            nameColor = "#FFF";
        }
    };

    const w = 20;
    const h = 30;
    let x = mapWidth/2 - 3*w;
    let y = 3*tileSize;
    const yellowBtn = new Button(x,y,w,h,function() {
        if (gameMode == GAME_MSPACMAN) {
            setGameMode(GAME_OTTO);
        }
        else if (gameMode == GAME_OTTO) {
            setGameMode(GAME_MSPACMAN);
        }
    });
    yellowBtn.setIcon(function (ctx,x,y,frame) {
        getPlayerDrawFunc()(ctx,x,y,DIR_RIGHT,pacman.getAnimFrame(pacman.getStepFrame(Math.floor((gameMode==GAME_PACMAN?frame+4:frame)/1.5))),true);
    });

    x += 2*w;
    const redBtn = new Button(x,y,w,h);
    redBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_LEFT,undefined,undefined,undefined,blinky.color);
    });

    x += w;
    const pinkBtn = new Button(x,y,w,h);
    pinkBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_LEFT,undefined,undefined,undefined,pinky.color);
    });

    x += w;
    const cyanBtn = new Button(x,y,w,h)
    cyanBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_LEFT,undefined,undefined,undefined,inky.color);
    });

    x += w;
    const orangeBtn = new Button(x,y,w,h);
    orangeBtn.setIcon(function (ctx,x,y,frame) {
        getGhostDrawFunc()(ctx,x,y,Math.floor(frame/6)%2,DIR_LEFT,undefined,undefined,undefined,clyde.color);
    });
    
    const forEachCharBtn = function(callback) {
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
            resetTitle();
            forEachCharBtn(function (btn) {
                btn.enable();
            });
        },
        shutdown: function() {
            forEachCharBtn(function (btn) {
                btn.disable();
            });
        },
        draw: function() {
            forEachCharBtn(function (btn) {
                renderer.renderFunc(btn.draw,btn);
            });

            resetTitle();
            renderer.renderFunc(function(ctx){
                ctx.font = tileSize+"px ArcadeR";
                ctx.fillStyle = nameColor;
                ctx.textAlign = "center";
                ctx.textBaseline = "top";
                ctx.fillText(name, mapWidth/2, tileSize);
            });
        },
        update: function() {
            forEachCharBtn(function (btn) {
                btn.update();
            });
        },
        getYellowBtn: function() {
            return yellowBtn;
        },
    };

})();

//////////////////////////////////////////////////////////////////////////////////////
// Pre New Game State
// (the main menu for the currently selected game)

const preNewGameState = (function() {

    const exitTo = function(s,fade) {
        gameTitleState.shutdown();
        menu.disable();
        switchState(s,fade);
    };

    const menu = new Menu("",2*tileSize,0,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");

    menu.addSpacer(2);
    menu.addTextButton("PLAY",
        function() { 
            setPracticeMode(false);
            setTurboMode(false);
            newGameState.setStartLevel(1);
            exitTo(newGameState, 60);
        });
    menu.addTextButton("PLAY TURBO",
        function() { 
            setPracticeMode(false);
            setTurboMode(true);
            newGameState.setStartLevel(1);
            exitTo(newGameState, 60);
        });
    menu.addTextButton("PRACTICE",
        function() { 
            setPracticeMode(true);
            setTurboMode(false);
            exitTo(selectActState);
        });
    menu.addSpacer(0.5);
    menu.addTextButton("CUTSCENES",
        function() { 
            exitTo(cutSceneMenuState);
        });
    menu.addTextButton("ABOUT",
        function() { 
            exitTo(aboutGameState);
        });
    menu.addSpacer(0.5);
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];

    return {
        init: function() {
            menu.enable();
            gameTitleState.init();
            setMap(undefined);
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.renderFunc(menu.draw,menu);
            gameTitleState.draw();
        },
        update: function() {
            gameTitleState.update();
        },
        getMenu: function() {
            return menu;
        },
    };
})();

//////////////////////////////////////////////////////////////////////////////////////
// Select Act State

const selectActState = (function() {

    // TODO: create ingame menu option to return to this menu (with last act played present)

    let menu;
    const numActs = 4;
    const defaultStartAct = 1;
    let startAct = defaultStartAct;

    const exitTo = function(state,fade) {
        gameTitleState.shutdown();
        menu.disable();
        switchState(state,fade);
    };

    const chooseLevelFromAct = function(act) {
        selectLevelState.setAct(act);
        exitTo(selectLevelState);
    };

    const scrollToAct = function(act) {
        // just rebuild the menu
        selectActState.setStartAct(act);
        exitTo(selectActState);
    };

    const drawArrow = function(ctx,x,y,dir) {
        ctx.save();
        ctx.translate(x,y);
        ctx.scale(1,dir);
        ctx.beginPath();
        ctx.moveTo(0,-tileSize/2);
        ctx.lineTo(tileSize,tileSize/2);
        ctx.lineTo(-tileSize,tileSize/2);
        ctx.closePath();
        ctx.fillStyle = "#FFF";
        ctx.fill();
        ctx.restore();
    };

    const buildMenu = function(act) {
        // set buttons starting at the given act
        startAct = act;

        menu = new Menu("",2*tileSize,0,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
        menu.addSpacer(2);
        menu.addIconButton(
            function(ctx,x,y) {
                drawArrow(ctx,x,y,1);
            },
            function() {
                scrollToAct(Math.max(1,act-numActs));
            });
        for (let i=0; i<numActs; i++) {
            const range = getActRange(act+i);
            menu.addTextIconButton("LEVELS "+range[0]+"-"+range[1],
                (function(j){
                    return function() { 
                        chooseLevelFromAct(act+j);
                    };
                })(i),
                (function(j){
                    return function(ctx,x,y) {
                        const s = tileSize/3*2;
                        const r = tileSize/6;
                        ctx.save();
                        ctx.translate(x,y);
                        ctx.beginPath();
                        ctx.moveTo(-s,0);
                        ctx.lineTo(-s,-r);
                        ctx.quadraticCurveTo(-s,-s,-r,-s);
                        ctx.lineTo(r,-s);
                        ctx.quadraticCurveTo(s,-s,s,-r);
                        ctx.lineTo(s,r);
                        ctx.quadraticCurveTo(s,s,r,s);
                        ctx.lineTo(-r,s);
                        ctx.quadraticCurveTo(-s,s,-s,r);
                        ctx.closePath();
                        const colors = getActColor(act+j);
                        ctx.fillStyle = colors.wallFillColor;
                        ctx.strokeStyle = colors.wallStrokeColor;
                        ctx.fill();
                        ctx.stroke();
                        ctx.restore();
                    };
                })(i));
        }
        menu.addIconButton(
            function(ctx,x,y) {
                drawArrow(ctx,x,y,-1);
            },
            function() {
                scrollToAct(act+numActs);
            });
        menu.addTextButton("BACK",
            function() {
                exitTo(preNewGameState);
            });
        menu.backButton = menu.buttons[menu.buttonCount-1];
        menu.enable();
    };

    return {
        init: function() {
            buildMenu(startAct);
            gameTitleState.init();
        },
        setStartAct: function(act) {
            startAct = act;
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.renderFunc(menu.draw,menu);
            gameTitleState.draw();
        },
        update: function() {
            gameTitleState.update();
        },
        getMenu: function() {
            return menu;
        },
    };
})();

//////////////////////////////////////////////////////////////////////////////////////
// Select Level State

const selectLevelState = (function() {

    let menu;
    let act = 1;

    const exitTo = function(state,fade) {
        gameTitleState.shutdown();
        menu.disable();
        switchState(state,fade);
    };

    const playLevel = function(i) {
        // TODO: set level (will have to set up fruit history correctly)
        newGameState.setStartLevel(i);
        exitTo(newGameState, 60);
    };

    const buildMenu = function(act) {
        const range = getActRange(act);

        menu = new Menu("",2*tileSize,0,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
        menu.addSpacer(2);
        if (range[0] < range[1]) {
            for (let i=range[0]; i<=range[1]; i++) {
                menu.addTextIconButton("LEVEL "+i,
                    (function(j){
                        return function() { 
                            playLevel(j);
                        };
                    })(i),
                    (function(j){
                        return function(ctx,x,y) {
                            const f = fruit.getFruitFromLevel(j);
                            if (f) {
                                atlas.drawFruitSprite(ctx,x,y,f.name);
                            }
                        };
                    })(i));
            }
        }
        menu.addSpacer(0.5);
        menu.addTextButton("BACK",
            function() {
                exitTo(selectActState);
            });
        menu.backButton = menu.buttons[menu.buttonCount-1];
        menu.enable();
    };

    return {
        init: function() {
            setFruitFromGameMode();
            buildMenu(act);
            gameTitleState.init();
        },
        setAct: function(a) {
            act = a;
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.renderFunc(menu.draw,menu);
            gameTitleState.draw();
        },
        update: function() {
            gameTitleState.update();
        },
        getMenu: function() {
            return menu;
        },
    };
})();

//////////////////////////////////////////////////////////////////////////////////////
// About Game State
// (the screen shows some information about the game)

const aboutGameState = (function() {

    const exitTo = function(s,fade) {
        gameTitleState.shutdown();
        menu.disable();
        switchState(s,fade);
    };

    const menu = new Menu("",2*tileSize,0,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");

    menu.addSpacer(8);
    menu.addTextButton("BACK",
        function() {
            exitTo(preNewGameState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];

    let desc;
    let numDescLines;

    const drawDesc = function(ctx){
        ctx.font = tileSize+"px ArcadeR";
        ctx.fillStyle = "#FFF";
        ctx.textBaseline = "top";
        ctx.textAlign = "center";
        const y = 12*tileSize;
        for (let i=0; i<numDescLines; i++) {
            ctx.fillText(desc[i],14*tileSize,y+i*2*tileSize);
        }
    };

    return {
        init: function() {
            menu.enable();
            gameTitleState.init();
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.renderFunc(menu.draw,menu);
            gameTitleState.draw();
            desc = getGameDescription();
            numDescLines = desc.length;
            renderer.renderFunc(drawDesc);
        },
        update: function() {
            gameTitleState.update();
        },
        getMenu: function() {
            return menu;
        },
    };
})();

//////////////////////////////////////////////////////////////////////////////////////
// Cut Scene Menu State
// (the screen that shows a list of the available cutscenes for the current game)

const cutSceneMenuState = (function() {

    const exitTo = function(s,fade) {
        gameTitleState.shutdown();
        menu.disable();
        switchState(s,fade);
    };

    const exitToCutscene = function(s) {
        if (s) {
            gameTitleState.shutdown();
            menu.disable();
            playCutScene(s,cutSceneMenuState);
        }
    };

    const menu = new Menu("",2*tileSize,0,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");

    menu.addSpacer(2);
    menu.addTextButton("CUTSCENE 1",
        function() { 
            exitToCutscene(cutscenes[gameMode][0]);
        });
    menu.addTextButton("CUTSCENE 2",
        function() { 
            exitToCutscene(cutscenes[gameMode][1]);
        });
    menu.addTextButton("CUTSCENE 3",
        function() { 
            exitToCutscene(cutscenes[gameMode][2]);
        });
    menu.addSpacer();
    menu.addTextButton("BACK",
        function() {
            exitTo(preNewGameState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];

    return {
        init: function() {
            menu.enable();
            gameTitleState.init();
            setLevel(0);
        },
        draw: function() {
            renderer.clearMapFrame();
            renderer.renderFunc(menu.draw,menu);
            gameTitleState.draw();
        },
        update: function() {
            gameTitleState.update();
        },
        getMenu: function() {
            return menu;
        },
    };
})();

//////////////////////////////////////////////////////////////////////////////////////
// Score State
// (the high score screen state)

const scoreState = (function(){

    const exitTo = function(s) {
        switchState(s);
        menu.disable();
    };

    const menu = new Menu("", 2*tileSize,mapHeight-6*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];

    let frame = 0;

    const bulbs = {};
    let numBulbs;
    (function(){
        const x = -1.5*tileSize;
        const y = -1*tileSize;
        const w = 18*tileSize;
        const h = 29*tileSize;
        const s = 3;

        let i=0;
        let x0 = x;
        let y0 = y;
        const addBulb = function(x,y) { bulbs[i++] = { x:x, y:y }; };
        for (; y0<y+h; y0+=s) { addBulb(x0,y0); }
        for (; x0<x+w; x0+=s) { addBulb(x0,y0); }
        for (; y0>y; y0-=s) { addBulb(x0,y0); }
        for (; x0>x; x0-=s) { addBulb(x0,y0); }

        numBulbs = i;
    })();

    const drawScoreBox = function(ctx) {

        // draw chaser lights around the marquee
        ctx.fillStyle = "#555";
        const s=2;
        for (let i=0; i<numBulbs; i++) {
            const b = bulbs[i];
            ctx.fillRect(b.x, b.y, s, s);
        }
        ctx.fillStyle = "#FFF";
        for (let i=0; i<63; i++) {
            const b = bulbs[(i*4+Math.floor(frame/2))%numBulbs];
            ctx.fillRect(b.x, b.y, s, s);
        }

        ctx.font = tileSize+"px ArcadeR";
        ctx.textBaseline = "top";
        ctx.textAlign = "right";
        const scoreColor = "#AAA";
        const captionColor = "#444";

        const x = 9*tileSize;
        let y = 0;
        ctx.fillStyle = "#FFF"; ctx.fillText("HIGH SCORES", x+4*tileSize,y);
        y += tileSize*4;

        const drawContrails = function(x,y) {
            ctx.lineWidth = 1.0;
            ctx.lineCap = "round";
            ctx.strokeStyle = "rgba(255,255,255,0.5)";

            ctx.save();
            ctx.translate(-2.5,0);

            for (let dy=-4; dy<=4; dy+=2) {
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

    const drawFood = function(ctx) {
        ctx.globalAlpha = 0.5;
        ctx.font = tileSize + "px sans-serif";
        ctx.textBaseline = "middle";
        ctx.textAlign = "left";

        let x = 20*tileSize;
        let y = 0;

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

        const alpha = ctx.globalAlpha;

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

        const mspac_fruits = [
            {name: 'cherry',     points: 100},
            {name: 'strawberry', points: 200},
            {name: 'orange',     points: 500},
            {name: 'pretzel',    points: 700},
            {name: 'apple',      points: 1000},
            {name: 'pear',       points: 2000},
            {name: 'banana',     points: 5000},
        ];

        const pac_fruits = [
            {name:'cherry',     points:100},
            {name:'strawberry', points:300},
            {name:'orange',     points:500},
            {name:'apple',      points:700},
            {name:'melon',      points:1000},
            {name:'galaxian',   points:2000},
            {name:'bell',       points:3000},
            {name:'key',        points:5000},
        ];

        y += 3*tileSize;
        for (let i=0; i<pac_fruits.length; i++) {
            const f = pac_fruits[i];
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

const aboutState = (function(){

    const exitTo = function(s) {
        switchState(s);
        menu.disable();
    };

    const menu = new Menu("", 2*tileSize,mapHeight-11*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    menu.addTextButton("GO TO PROJECT PAGE",
        function() {
            window.open("https://github.com/shaunew/Pac-Man");
        });
    menu.addTextButton("BACK",
        function() {
            exitTo(homeState);
        });
    menu.backButton = menu.buttons[menu.buttonCount-1];

    const drawBody = function(ctx) {
        ctx.font = tileSize+"px ArcadeR";
        ctx.textBaseline = "top";
        ctx.textAlign = "left";

        let x,y;
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

const newGameState = (function() {
    let frames;
    const duration = 2;
    let startLevel = 1;

    return {
        init: function() {
            clearCheats();
            frames = 0;
            setLevel(startLevel-1);
            setExtraLives(practiceMode ? Infinity : 3);
            setScore(0);
            setFruitFromGameMode();
            readyNewState.init();
        },
        setStartLevel: function(i) {
            startLevel = i;
        },
        draw: function() {
            if (!map)
                return;
            renderer.blitMap();
            renderer.drawScore();
            renderer.drawMessage("PLAYER ONE", "#0FF", 9, 14);
            renderer.drawReadyMessage();
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

const readyState =  (function(){
    let frames;
    const duration = 2;
    
    return {
        init: function() {
            for (const a of actors)
                a.reset();
            ghostCommander.reset();
            fruit.reset();
            energizer.reset();
            map.resetTimeEaten();
            frames = 0;
            vcr.init();
        },
        draw: function() {
            if (!map)
                return;
            renderer.blitMap();
            renderer.drawScore();
            renderer.drawActors();
            renderer.drawReadyMessage();
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

const readyNewState = newChildObject(readyState, {

    init: function() {

        // increment level and ready the next map
        setLevel(level+1);
        if (gameMode == GAME_PACMAN) {
            setMap(mapPacman);
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
});

////////////////////////////////////////////////////
// Ready Restart Level state
// (ready state when pausing before restarted level)

const readyRestartState = newChildObject(readyState, {

    init: function() {
        extraLives--;
        ghostReleaser.onRestartLevel();
        elroyTimer.onRestartLevel();
        renderer.drawMap();

        // inherit attributes from readyState
        readyState.init.call(this);
    },
});

////////////////////////////////////////////////////
// Play state
// (state when playing the game)

const playState = {
    init: function() { 
        if (practiceMode) {
            vcr.reset();
        }
    },
    draw: function() {
        renderer.setLevelFlash(false);
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
        for (const g of ghosts) {
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

            const maxSteps = 2;
            let skip = false;

            // skip this frame if needed,
            // but update ghosts running home
            if (energizer.showingPoints()) {
                for (let j=0; j<maxSteps; j++)
                    for (const g of ghosts)
                        if (g.mode == GHOST_GOING_HOME || g.mode == GHOST_ENTERING_HOME)
                            g.update(j);
                energizer.updatePointsTimer();
                skip = true;
            }
            else { // make ghosts go home immediately after points disappear
                for (const g of ghosts)
                    if (g.mode == GHOST_EATEN) {
                        g.mode = GHOST_GOING_HOME;
                        g.targetting = 'door';
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
                for (let j=0; j<maxSteps; j++) {

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
                    for (const g of ghosts) g.update(j);
                    if (this.isPacmanCollide()) break;
                }

                // update frame counts
                for (const a of actors)
                    a.frames++;
            }
        }
    },
};

////////////////////////////////////////////////////
// Script state
// (a state that triggers functions at certain times)

const scriptState = (function(){

    return {
        init: function() {
            this.frames = 0;        // frames since state began
            this.triggerFrame = 0;  // frames since last trigger

            const trigger = this.triggers[0];
            this.drawFunc = trigger ? trigger.draw : undefined;   // current draw function
            this.updateFunc = trigger ? trigger.update : undefined; // current update function
        },
        update: function() {

            // if trigger is found for current time,
            // call its init() function
            // and store its draw() and update() functions
            const trigger = this.triggers[this.frames];
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

const seekableScriptState = newChildObject(scriptState, {

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
});

////////////////////////////////////////////////////
// Dead state
// (state when player has lost a life)

const deadState = (function() {
    
    // this state will always have these drawn
    const commonDraw = function() {
        renderer.blitMap();
        renderer.drawScore();
    };

    return newChildObject(seekableScriptState, {

        // script functions for each time
        triggers: {
            0: { // freeze
                update: function() {
                    for (const g of ghosts) 
                        g.frames++; // keep animating ghosts
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
    });
})();

////////////////////////////////////////////////////
// Finish state
// (state when player has completed a level)

const finishState = (function(){

    // this state will always have these drawn
    const commonDraw = function() {
        renderer.blitMap();
        renderer.drawScore();

        renderer.beginMapClip();
        renderer.drawPlayer();
        renderer.endMapClip();
    };
    
    // flash the floor and draw
    const flashFloorAndDraw = function(on) {
        renderer.setLevelFlash(on);
        commonDraw();
    };

    return newChildObject(seekableScriptState, {

        // script functions for each time
        triggers: {
            0:   { draw: function() {
                    renderer.setLevelFlash(false);
                    renderer.blitMap();
                    renderer.drawScore();
                    renderer.beginMapClip();
                    renderer.drawFruit();
                    renderer.drawActors();
                    renderer.drawTargets();
                    renderer.endMapClip();
            } },
            120:  { draw: function() { flashFloorAndDraw(true); } },
            132: { draw: function() { flashFloorAndDraw(false); } },
            144: { draw: function() { flashFloorAndDraw(true); } },
            156: { draw: function() { flashFloorAndDraw(false); } },
            168: { draw: function() { flashFloorAndDraw(true); } },
            180: { draw: function() { flashFloorAndDraw(false); } },
            192: { draw: function() { flashFloorAndDraw(true); } },
            204: { draw: function() { flashFloorAndDraw(false); } },
            216: {
                init: function() {
                    if (!triggerCutsceneAtEndLevel()) {
                        switchState(readyNewState,60);
                    }
                }
            },
        },
    });
})();

////////////////////////////////////////////////////
// Game Over state
// (state when player has lost last life)

const overState = (function() {
    let frames;
    return {
        init: function() {
            frames = 0;
        },
        draw: function() {
            renderer.blitMap();
            renderer.drawScore();
            renderer.drawMessage("GAME  OVER", "#F00", 9, 20);
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

