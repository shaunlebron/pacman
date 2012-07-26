
document.onkeydown = function(e) {
    var key = (e||window.event).keyCode;
    switch (key) {

        // LEFT
        case 37: 
            pacman.setNextDir(DIR_LEFT);
            break;

        // RIGHT
        case 39:
            pacman.setNextDir(DIR_RIGHT);
            break;

        // UP
        case 38:
            pacman.setNextDir(DIR_UP);
            if (vcr.getMode() != VCR_RECORD) {
                vcr.nextSpeed(1);
            }
            break;

        // DOWN
        case 40:
            pacman.setNextDir(DIR_DOWN);
            if (vcr.getMode() != VCR_RECORD) {
                vcr.nextSpeed(-1);
            }
            break;

        // SHIFT
        case 16:
            if (vcr.getMode() == VCR_RECORD) {
                vcr.startSeeking();
            }
            break;
        default: return;
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

        // n (next level)
        case 78:
            if (state != menuState) {
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
