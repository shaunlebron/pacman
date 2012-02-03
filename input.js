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
