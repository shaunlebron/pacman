
// REFERENCED GLOBALS:
// import { vcr, VCR_NONE, VCR_RECORD } from './vcr.js';
// import { state, learnState, newGameState, playState, readyNewState, readyRestartState, switchState, finishState, deadState, overState } from './states.js';
// import { pacman, blinky, pinky, inky, clyde } from './actors.js';
// import { DIR_LEFT, DIR_RIGHT, DIR_UP, DIR_DOWN } from './direction.js';
// import { practiceMode, turboMode, setTurboMode } from './game.js';
// import { executive } from './executive.js';
// import { inGameMenu } from './inGameMenu.js';
// import { hud } from './hud.js';

//////////////////////////////////////////////////////////////////////////////////////
// Input
// (Handles all key presses and touches)

(function(){

    // A Key Listener class (each key maps to an array of callbacks)
    const KeyEventListener = function() {
        this.listeners = {};
    };
    KeyEventListener.prototype = {
        add: function(key, callback, isActive) {
            this.listeners[key] = this.listeners[key] || [];
            this.listeners[key].push({
                isActive: isActive,
                callback: callback,
            });
        },
        exec: function(key, e) {
            const keyListeners = this.listeners[key];
            if (!keyListeners) {
                return;
            }
            const numListeners = keyListeners.length;
            for (let i=0; i<numListeners; i++) {
                const l = keyListeners[i];
                if (!l.isActive || l.isActive()) {
                    e.preventDefault();
                    if (l.callback()) { // do not propagate keys if returns true
                        break;
                    }
                }
            }
        },
    };

    // declare key event listeners
    const keyDownListeners = new KeyEventListener();
    const keyUpListeners = new KeyEventListener();

    // helper functions for adding custom key listeners
    const addKeyDown = function(key,callback,isActive) { keyDownListeners.add(key,callback,isActive); };
    const addKeyUp   = function(key,callback,isActive) { keyUpListeners.add(key,callback,isActive); };

    // boolean states of each key
    const keyStates = {};

    // hook my key listeners to the window's listeners
    window.addEventListener("keydown", function(e) {
        const key = (e||window.event).keyCode;

        // only execute at first press event
        if (!keyStates[key]) {
            keyStates[key] = true;
            keyDownListeners.exec(key, e);
        }
    });
    window.addEventListener("keyup",function(e) {
        const key = (e||window.event).keyCode;

        keyStates[key] = false;
        keyUpListeners.exec(key, e);
    });


    // key enumerations

    const KEY_ENTER = 13;
    const KEY_ESC = 27;

    const KEY_LEFT = 37;
    const KEY_RIGHT = 39;
    const KEY_UP = 38;
    const KEY_DOWN = 40;

    const KEY_SHIFT = 16;
    const KEY_CTRL = 17;
    const KEY_ALT = 18;

    const KEY_SPACE = 32;

    const KEY_M = 77;
    const KEY_N = 78;
    const KEY_Q = 81;
    const KEY_W = 87;
    const KEY_E = 69;
    const KEY_R = 82;
    const KEY_T = 84;

    const KEY_A = 65;
    const KEY_S = 83;
    const KEY_D = 68;
    const KEY_F = 70;
    const KEY_G = 71;

    const KEY_I = 73;
    const KEY_O = 79;
    const KEY_P = 80;

    const KEY_1 = 49;
    const KEY_2 = 50;

    const KEY_END = 35;

    // Custom Key Listeners

    // Menu Navigation Keys
    let menu;
    const isInMenu = function() {
        menu = (state.getMenu && state.getMenu());
        if (!menu && inGameMenu.isOpen()) {
            menu = inGameMenu.getMenu();
        }
        return menu;
    };
    addKeyDown(KEY_ESC,   function(){ menu.backButton ? menu.backButton.onclick():0; return true; }, isInMenu);
    addKeyDown(KEY_ENTER, function(){ menu.clickCurrentOption(); }, isInMenu);
    const isMenuKeysAllowed = function() {
        const menu = isInMenu();
        return menu && !menu.noArrowKeys;
    };
    addKeyDown(KEY_UP,    function(){ menu.selectPrevOption(); }, isMenuKeysAllowed);
    addKeyDown(KEY_DOWN,  function(){ menu.selectNextOption(); }, isMenuKeysAllowed);
    const isInGameMenuButtonClickable = function() {
        return hud.isValidState() && !inGameMenu.isOpen();
    };
    addKeyDown(KEY_ESC, function() { inGameMenu.getMenuButton().onclick(); return true; }, isInGameMenuButtonClickable);

    // Move Pac-Man
    const isPlayState = function() { return !vcr.isSeeking() && (state == learnState || state == newGameState || state == playState || state == readyNewState || state == readyRestartState); };
    addKeyDown(KEY_LEFT,  function() { pacman.setInputDir(DIR_LEFT); },  isPlayState);
    addKeyDown(KEY_RIGHT, function() { pacman.setInputDir(DIR_RIGHT); }, isPlayState);
    addKeyDown(KEY_UP,    function() { pacman.setInputDir(DIR_UP); },    isPlayState);
    addKeyDown(KEY_DOWN,  function() { pacman.setInputDir(DIR_DOWN); },  isPlayState);
    addKeyUp  (KEY_LEFT,  function() { pacman.clearInputDir(DIR_LEFT); },  isPlayState);
    addKeyUp  (KEY_RIGHT, function() { pacman.clearInputDir(DIR_RIGHT); }, isPlayState);
    addKeyUp  (KEY_UP,    function() { pacman.clearInputDir(DIR_UP); },    isPlayState);
    addKeyUp  (KEY_DOWN,  function() { pacman.clearInputDir(DIR_DOWN); },  isPlayState);

    // Slow-Motion
    const isPracticeMode = function() { return isPlayState() && practiceMode; };
    //isPracticeMode = function() { return true; };
    addKeyDown(KEY_1, function() { executive.setUpdatesPerSecond(30); }, isPracticeMode);
    addKeyDown(KEY_2,  function() { executive.setUpdatesPerSecond(15); }, isPracticeMode);
    addKeyUp  (KEY_1, function() { executive.setUpdatesPerSecond(60); }, isPracticeMode);
    addKeyUp  (KEY_2,  function() { executive.setUpdatesPerSecond(60); }, isPracticeMode);

    // Toggle VCR
    const canSeek = function() { return !isInMenu() && vcr.getMode() != VCR_NONE; };
    addKeyDown(KEY_SHIFT, function() { vcr.startSeeking(); },   canSeek);
    addKeyUp  (KEY_SHIFT, function() { vcr.startRecording(); }, canSeek);

    // Adjust VCR seeking
    const isSeekState = function() { return vcr.isSeeking(); };
    addKeyDown(KEY_UP,   function() { vcr.nextSpeed(1); },  isSeekState);
    addKeyDown(KEY_DOWN, function() { vcr.nextSpeed(-1); }, isSeekState);

    // Skip Level
    const canSkip = function() {
        return isPracticeMode() && 
            (state == newGameState ||
            state == readyNewState ||
            state == readyRestartState ||
            state == playState ||
            state == deadState ||
            state == finishState ||
            state == overState);
    };
    addKeyDown(KEY_N, function() { switchState(readyNewState, 60); }, canSkip);
    addKeyDown(KEY_M, function() { switchState(finishState); }, function() { return state == playState; });

    // Draw Actor Targets (fishpoles)
    addKeyDown(KEY_Q, function() { blinky.isDrawTarget = !blinky.isDrawTarget; }, isPracticeMode);
    addKeyDown(KEY_W, function() { pinky.isDrawTarget = !pinky.isDrawTarget; }, isPracticeMode);
    addKeyDown(KEY_E, function() { inky.isDrawTarget = !inky.isDrawTarget; }, isPracticeMode);
    addKeyDown(KEY_R, function() { clyde.isDrawTarget = !clyde.isDrawTarget; }, isPracticeMode);
    addKeyDown(KEY_T, function() { pacman.isDrawTarget = !pacman.isDrawTarget; }, isPracticeMode);

    // Draw Actor Paths
    addKeyDown(KEY_A, function() { blinky.isDrawPath = !blinky.isDrawPath; }, isPracticeMode);
    addKeyDown(KEY_S, function() { pinky.isDrawPath = !pinky.isDrawPath; }, isPracticeMode);
    addKeyDown(KEY_D, function() { inky.isDrawPath = !inky.isDrawPath; }, isPracticeMode);
    addKeyDown(KEY_F, function() { clyde.isDrawPath = !clyde.isDrawPath; }, isPracticeMode);
    addKeyDown(KEY_G, function() { pacman.isDrawPath = !pacman.isDrawPath; }, isPracticeMode);

    // Miscellaneous Cheats
    addKeyDown(KEY_I, function() { pacman.invincible = !pacman.invincible; }, isPracticeMode);
    addKeyDown(KEY_O, function() { setTurboMode(!turboMode); }, isPracticeMode);
    addKeyDown(KEY_P, function() { pacman.ai = !pacman.ai; }, isPracticeMode);

    addKeyDown(KEY_END, function() { executive.togglePause(); });

})();

const initSwipe = function() {

    // position of anchor
    let x = 0;
    let y = 0;

    // current distance from anchor
    let dx = 0;
    let dy = 0;

    // minimum distance from anchor before direction is registered
    const r = 4;
    
    const touchStart = function(event) {
        event.preventDefault();
        const fingerCount = event.touches.length;
        if (fingerCount == 1) {

            // commit new anchor
            x = event.touches[0].pageX;
            y = event.touches[0].pageY;

        }
        else {
            touchCancel(event);
        }
    };

    const touchMove = function(event) {
        event.preventDefault();
        const fingerCount = event.touches.length;
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
                    pacman.setInputDir(dx>0 ? DIR_RIGHT : DIR_LEFT);
                }
                else {
                    pacman.setInputDir(dy>0 ? DIR_DOWN : DIR_UP);
                }
            }
        }
        else {
            touchCancel(event);
        }
    };

    const touchEnd = function(event) {
        event.preventDefault();
    };

    const touchCancel = function(event) {
        event.preventDefault();
        x=y=dx=dy=0;
    };

    const touchTap = function(event) {
        // tap to clear input directions
        pacman.clearInputDir(undefined);
    };
    
    // register touch events
    document.onclick = touchTap;
    document.ontouchstart = touchStart;
    document.ontouchend = touchEnd;
    document.ontouchmove = touchMove;
    document.ontouchcancel = touchCancel;
};
