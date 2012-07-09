
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

        // SHIFT
        case 16:
            vcr.startRecording();
            break;

        default: return;
    }
    e.preventDefault();
};
