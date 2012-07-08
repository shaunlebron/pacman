//////////////////////////////////////////////////////////////////////////////////////
// Fruit

var fruit = (function(){

    var dotLimit1 = 70; // first fruit will appear when this number of dots are eaten
    var dotLimit2 = 170; // second fruit will appear when this number of dots are eaten

    var duration = 9; // number of seconds that the fruit is on the screen
    var scoreDuration = 2; // number of seconds that the fruit score is on the screen

    var framesLeft; // frames left until fruit is off the screen
    var scoreFramesLeft; // frames left until the picked-up fruit score is off the screen

    var savedFramesLeft = {};
    var savedScoreFramesLeft = {};

    // save state at time t
    var save = function(t) {
        savedFramesLeft[t] = framesLeft;
        savedScoreFramesLeft[t] = scoreFramesLeft;
    };

    // load state at time t
    var load = function(t) {
        framesLeft = savedFramesLeft[t];
        scoreFramesLeft = savedScoreFramesLeft[t];
    };

    return {
        save: save,
        load: load,
        pixel: {x:0, y:0}, // pixel location
        setPosition: function(px,py) {
            this.pixel.x = px;
            this.pixel.y = py;
        },
        reset: function() {
            framesLeft = 0;
            scoreFramesLeft = 0;
        },
        update: function() {
            if (framesLeft > 0)
                framesLeft--;
            else if (scoreFramesLeft > 0)
                scoreFramesLeft--;
        },
        onDotEat: function() {
            if (map.dotsEaten == dotLimit1 || map.dotsEaten == dotLimit2)
                framesLeft = 60*duration;
        },
        isPresent: function() { return framesLeft > 0; },
        isScorePresent: function() { return scoreFramesLeft > 0; },
        testCollide: function() {
            if (framesLeft > 0 && pacman.pixel.y == this.pixel.y && Math.abs(pacman.pixel.x - this.pixel.x) <= midTile.x) {
                addScore(this.getPoints());
                framesLeft = 0;
                scoreFramesLeft = scoreDuration*60;
            }
        },
        // get number of points a fruit is worth based on the current level
        getPoints: (function() {
            var points = [100,300,500,500,700,700,1000,1000,2000,2000,3000,3000,5000];
            return function() {
                var i = level;
                if (i > 13) i = 13;
                return points[i-1];
            };
        })(),
    };

})();
