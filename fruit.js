// Fruit

var fruit = (function(){

    var getPoints = (function() {
        var points = [100,300,500,500,700,700,1000,1000,2000,2000,3000,3000,5000];
        return function() {
            var i = game.level;
            if (i > 13) i = 13;
            return points[i-1];
        };
    })();

    var duration = 2;

    var framesLeft;
    var scoreFramesLeft;
    var pixel = {x:0,y:0};

    return {
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
            if (game.dotCount == 70 || game.dotCount == 170)
                framesLeft = 60*duration;
        },
        isPresent: function() { return framesLeft > 0; },
        isScorePresent: function() { return scoreFramesLeft > 0; },
        testCollide: function() {
            if (framesLeft > 0 && pacman.pixel.y == pixel.y && Math.abs(pacman.pixel.x - pixel.x) <= midTile.x) {
                this.reset();
                game.addScore(getPoints());
            }
        },
        setPosition: function(px,py) {
            pixel.x = px;
            pixel.y = py;
        }
    };

})();

