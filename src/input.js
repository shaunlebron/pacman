
var pressLeft = function() {
    pacman.setNextDir(DIR_LEFT);
};

var pressRight = function() {
    pacman.setNextDir(DIR_RIGHT);
};

var pressDown = function() {
    pacman.setNextDir(DIR_DOWN);
    if (vcr.getMode() != VCR_RECORD) {
        vcr.nextSpeed(-1);
    }
};

var pressUp = function() {
    pacman.setNextDir(DIR_UP);
    if (vcr.getMode() != VCR_RECORD) {
        vcr.nextSpeed(1);
    }
};

document.onkeydown = function(e) {
    var key = (e||window.event).keyCode;
    switch (key) {

        // LEFT
        case 37: pressLeft(); break;

        // RIGHT
        case 39: pressRight(); break;

        // UP
        case 38: pressUp(); break;

        // DOWN
        case 40: pressDown(); break;

        // SHIFT
        case 16:
            if (vcr.getMode() == VCR_RECORD) {
                vcr.startSeeking();
            }
            break;
        default: return;

        // CTRL
        case 17: executive.setUpdatesPerSecond(30); break;

        // ALT
        case 18: executive.setUpdatesPerSecond(15); break;
    }
    // prevent default action for arrow keys
    // (don't scroll page with arrow keys)
    e.preventDefault();
};

document.onkeyup = function(e) {
    var key = (e||window.event).keyCode;
    switch (key) {

        // spacebar
        case 32: executive.togglePause(); break;

            break;
        // SHIFT
        case 16:
            vcr.startRecording();
            break;

        // CTRL or ALT
        case 17:
        case 18: executive.setUpdatesPerSecond(60); break;

        // n (next level)
        case 78:
            if (state != homeState) {
                //map.skipSignal = true;
                switchState(readyNewState,60);
            }
            break;

        // q
        case 81: blinky.isDrawTarget = !blinky.isDrawTarget; break;
        // w
        case 87: pinky.isDrawTarget = !pinky.isDrawTarget; break;
        // e
        case 69: inky.isDrawTarget = !inky.isDrawTarget; break;
        // r
        case 82: clyde.isDrawTarget = !clyde.isDrawTarget; break;
        // t 
        case 84: pacman.isDrawTarget = !pacman.isDrawTarget; break;

        // a
        case 65: blinky.isDrawPath = !blinky.isDrawPath; break;
        // s
        case 83: pinky.isDrawPath = !pinky.isDrawPath; break;
        // d
        case 68: inky.isDrawPath = !inky.isDrawPath; break;
        // f
        case 70: clyde.isDrawPath = !clyde.isDrawPath; break;
        // g
        case 71: pacman.isDrawPath = !pacman.isDrawPath; break;

        // i (invincible)
        case 73: pacman.invincible = !pacman.invincible; break;

        // o (turbO)
        case 79: pacman.doubleSpeed = !pacman.doubleSpeed; break;

        // p (auto-Play)
        case 80: pacman.ai = !pacman.ai; break;

        default: return;
    }
    e.preventDefault();
};

var initSwipe = function() {

    // position of anchor
    var x = 0;
    var y = 0;

    // current distance from anchor
    var dx = 0;
    var dy = 0;

    // minimum distance from anchor before direction is registered
    var r = 2;
    
    var touchStart = function(event) {
        event.preventDefault();
        var fingerCount = event.touches.length;
        if (fingerCount == 1) {

            // commit new anchor
            x = event.touches[0].pageX;
            y = event.touches[0].pageY;

        }
        else {
            touchCancel(event);
        }
    };

    var touchMove = function(event) {
        event.preventDefault();
        var fingerCount = event.touches.length;
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
                    (dx > 0) ? pressRight() : pressLeft();
                }
                else {
                    (dy > 0) ? pressDown() : pressUp();
                }
            }
        }
        else {
            touchCancel(event);
        }
    };

    var touchEnd = function(event) {
        event.preventDefault();
    };

    var touchCancel = function(event) {
        event.preventDefault();
        x=y=dx=dy=0;
    };
    
    // register touch events
    document.ontouchstart = touchStart;
    document.ontouchend = touchEnd;
    document.ontouchmove = touchMove;
    document.ontouchcancel = touchCancel;
};
