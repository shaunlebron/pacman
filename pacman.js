// Pac-Man
// Thanks to Jamey Pittman for "The Pac-Man Dossier"



//
// =============== USER INPUT ==================
//

var initInput = function() {
    // make "focusable" to isolate keypresses when canvas is clicked
    canvas.tabIndex = 0;

    // handle key press event
    document.onkeydown = function(e) {
        var key = (e||window.event).keyCode;
        switch (key) {
            case 37: pacman.setNextDir(DIR_LEFT); break; // left
            case 38: pacman.setNextDir(DIR_UP); break; // up
            case 39: pacman.setNextDir(DIR_RIGHT); break; // right
            case 40: pacman.setNextDir(DIR_DOWN); break;// down
            default: return;
        }
        e.preventDefault();
    };
};

//
// =========== MAIN SETUP ==========
//

// return sign of a number
var sign = function(x) {
    if (x<0) return -1;
    if (x>0) return 1;
    return 0;
};

window.onload = function() {

    // init various things
    initInput();

    // display maze
    resetTiles();
    blitBackground();
    drawEnergizers();
    drawMessage("start", "#FFF");

    // begin game when canvas is clicked
    canvas.onmousedown = function() {
        game.init();
        startTime = (new Date).getTime();
        nextFrameTime = (new Date).getTime();
        setInterval(tick, framePeriod);
        canvas.onmousedown = undefined;
    };
};
