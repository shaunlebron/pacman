
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
    // TOUCH-EVENTS SINGLE-FINGER SWIPE-SENSING JAVASCRIPT
    // Courtesy of PADILICIOUS.COM and MACOSXAUTOMATION.COM
    
    // this script can be used with one or more page elements to perform actions based on them being swiped with a single finger

    var fingerCount = 0;
    var startX = 0;
    var startY = 0;
    var curX = 0;
    var curY = 0;
    var deltaX = 0;
    var deltaY = 0;
    var horzDiff = 0;
    var vertDiff = 0;
    var minLength = 72; // the shortest distance the user may swipe
    var swipeLength = 0;
    var swipeAngle = null;
    var swipeDirection = null;
    
    // The 4 Touch Event Handlers
    
    // NOTE: the touchStart handler should also receive the ID of the triggering element
    // make sure its ID is passed in the event call placed in the element declaration, like:
    // <div id="picture-frame" ontouchstart="touchStart(event,'picture-frame');"  ontouchend="touchEnd(event);" ontouchmove="touchMove(event);" ontouchcancel="touchCancel(event);">

    function touchStart(event) {
            // disable the standard ability to select the touched object
            event.preventDefault();
            // get the total number of fingers touching the screen
            fingerCount = event.touches.length;
            // since we're looking for a swipe (single finger) and not a gesture (multiple fingers),
            // check that only one finger was used
            if ( fingerCount == 1 ) {
                    // get the coordinates of the touch
                    startX = event.touches[0].pageX;
                    startY = event.touches[0].pageY;
            } else {
                    // more than one finger touched so cancel
                    touchCancel(event);
            }
    }

    function touchMove(event) {
            event.preventDefault();
            if ( event.touches.length == 1 ) {
                    curX = event.touches[0].pageX;
                    curY = event.touches[0].pageY;
            } else {
                    touchCancel(event);
            }
    }
    
    function touchEnd(event) {
            event.preventDefault();
            // check to see if more than one finger was used and that there is an ending coordinate
            if ( fingerCount == 1 && curX != 0 ) {
                    // use the Distance Formula to determine the length of the swipe
                    swipeLength = Math.round(Math.sqrt(Math.pow(curX - startX,2) + Math.pow(curY - startY,2)));
                    // if the user swiped more than the minimum length, perform the appropriate action
                    if ( swipeLength >= minLength ) {
                            calculateAngle();
                            determineSwipeDirection();
                            processingRoutine();
                            touchCancel(event); // reset the variables
                    } else {
                            touchCancel(event);
                    }       
            } else {
                    touchCancel(event);
            }
    }

    function touchCancel(event) {
            // reset the variables back to default values
            fingerCount = 0;
            startX = 0;
            startY = 0;
            curX = 0;
            curY = 0;
            deltaX = 0;
            deltaY = 0;
            horzDiff = 0;
            vertDiff = 0;
            swipeLength = 0;
            swipeAngle = null;
            swipeDirection = null;
    }
    
    function calculateAngle() {
            var X = startX-curX;
            var Y = curY-startY;
            var Z = Math.round(Math.sqrt(Math.pow(X,2)+Math.pow(Y,2))); //the distance - rounded - in pixels
            var r = Math.atan2(Y,X); //angle in radians (Cartesian system)
            swipeAngle = Math.round(r*180/Math.PI); //angle in degrees
            if ( swipeAngle < 0 ) { swipeAngle =  360 - Math.abs(swipeAngle); }
    }
    
    function determineSwipeDirection() {
            if ( (swipeAngle <= 45) && (swipeAngle >= 0) ) {
                    swipeDirection = 'left';
            } else if ( (swipeAngle <= 360) && (swipeAngle >= 315) ) {
                    swipeDirection = 'left';
            } else if ( (swipeAngle >= 135) && (swipeAngle <= 225) ) {
                    swipeDirection = 'right';
            } else if ( (swipeAngle > 45) && (swipeAngle < 135) ) {
                    swipeDirection = 'down';
            } else {
                    swipeDirection = 'up';
            }
    }
    
    function processingRoutine() {
            if ( swipeDirection == 'left' ) {
                pressLeft();
            } else if ( swipeDirection == 'right' ) {
                pressRight();
            } else if ( swipeDirection == 'up' ) {
                pressUp();
            } else if ( swipeDirection == 'down' ) {
                pressDown();
            }
    }

    // register touch events with canvas
    var element = document.getElementById('canvas');
    element.ontouchstart = touchStart;
    element.ontouchend = touchEnd;
    element.ontouchmove = touchMove;
    element.ontouchcancel = touchCancel;
};
