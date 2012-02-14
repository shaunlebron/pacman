//////////////////////////////////////////////////////////////////////////////////////
// Elroy Timer

// Determines when to put blinky into faster elroy modes

var elroyTimer = (function(){

    // get the number of dots left that should trigger elroy stage #1 or #2
    var getDotsLeftLimit = (function(){
        var dotsLeft = [
            [20,30,40,40,40,50,50,50,60,60,60,70,70,70,100,100,100,100,120,120,120], // elroy1
            [10,15,20,20,20,25,25,25,30,30,30,40,40,40, 50, 50, 50, 50, 60, 60, 60]]; // elroy2
        return function(stage) {
            var i = game.level;
            if (i>21) i = 21;
            return dotsLeft[stage-1][i-1];
        };
    })();

    // when level restarts, blinky must wait for clyde to leave home before resuming elroy mode
    var waitForClyde;

    return {
        onNewLevel: function() {
            waitForClyde = false;
        },
        onRestartLevel: function() {
            waitForClyde = true;
        },
        update: function() {
            var dotsLeft = tileMap.dotsLeft();

            // stop waiting for clyde when clyde leaves home
            if (waitForClyde && clyde.mode != GHOST_PACING_HOME)
                waitForClyde = false;

            if (waitForClyde)
                blinky.elroy = 0;
            else
                if (dotsLeft <= getDotsLeftLimit(2))
                    blinky.elroy = 2;
                else if (dotsLeft <= getDotsLeftLimit(1))
                    blinky.elroy = 1;
                else
                    blinky.elroy = 0;
        },
    };
})();
