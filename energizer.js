//////////////////////////////////////////////////////////////////////////////////////
// Energizer

// handle how long the energizer lasts
// handle how long the points will display after eating a ghost

var energizer = (function() {

    // how many seconds to display points when ghost is eaten
    var pointsDuration = 1;

    // how long to stay energized
    var getDuration = (function(){
        var seconds = [6,5,4,3,2,5,2,2,1,5,2,1,1,3,1,1,0,1];
        return function() {
            var i = game.level;
            return (i > 18) ? 0 : 60*seconds[i-1];
        };
    })();

    // how many ghost flashes happen near the end of frightened mode
    var getFlashes = (function(){
        var flashes = [5,5,5,5,5,5,5,5,3,5,5,3,3,5,3,3,0,3];
        return function() {
            var i = game.level;
            return (i > 18) ? 0 : flashes[i-1];
        };
    })();

    // "The ghosts change colors every 14 game cycles when they start 'flashing'" -Jamey Pittman
    var flashInterval = 14;

    var count;  // how many frames energizer has been active
    var active; // is energizer active
    var points; // points that the last eaten ghost was worth
    var pointsFramesLeft; // number of frames left to display points earned from eating ghost

    return {
        reset: function() {
            count = 0;
            active = false;
            points = 100;
            pointsFramesLeft = 0;
            for (i=0; i<4; i++)
                actors[i].scared = false;
        },
        update: function() {
            var i;
            if (active) {
                if (count == getDuration())
                    this.reset();
                else
                    count++;
            }
        },
        activate: function() { 
            active = true;
            count = 0;
            points = 100;
            for (i=0; i<4; i++) 
                actors[i].onEnergized();
        },
        isActive: function() { return active; },
        isFlash: function() { 
            var i = Math.floor((getDuration()-count)/flashInterval);
            return (i<=2*getFlashes()-1) ? (i%2==0) : false;
        },

        getPoints: function() {
            return points;
        },
        addPoints: function() {
            game.addScore(points*=2);
            pointsFramesLeft = pointsDuration*60;
        },
        showingPoints: function() { return pointsFramesLeft > 0; },
        updatePointsTimer: function() { if (pointsFramesLeft > 0) pointsFramesLeft--; },
    };
})();
