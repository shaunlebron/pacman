//////////////////////////////////////////////////////////////////////////////////////
// Fruit

var fruit = (function(){

    // common attributes
    var pixel = {x:0, y:0};
    var scoreDuration = 2; // number of seconds that the fruit score is on the screen
    var scoreFramesLeft; // frames left until the picked-up fruit score is off the screen
    var savedScoreFramesLeft = {};
    var isScorePresent = function() {
        return scoreFramesLeft > 0;
    };

    var fruitHistory = {};

    // fruit type for the current level
    var currentFruit;

    // ms. pac-man specific
    var mspacFruit = (function() {
        var fruits = [
            {name: 'cherry',     points: 100},
            {name: 'strawberry', points: 200},
            {name: 'orange',     points: 500},
            {name: 'pretzel',    points: 700},
            {name: 'apple',      points: 1000},
            {name: 'pear',       points: 2000},
            {name: 'banana',     points: 5000},
        ];

        var frame; // current frame along animated path
        var numFrames; // the final frame of the path
        var path; // current path list
        var pathMode; // set to one of the the following enums:
        var PATH_ENTER = 0;
        var PATH_PEN = 1;
        var PATH_EXIT = 2;
        var pen_path = "<<<<<<^^^^^^>>>>>>>>>vvvvvv<<"

        var dotLimit1 = 64;
        var dotLimit2 = 176;

        var sprite; // what to draw
        var points; // amount of points the fruit is worth

        var shouldRandomizeFruit = function() {
            return level > 7;
        };

        var getRandomInt = function(min,max) {
            return Math.floor(Math.random() * (max-min+1)) + min;
        };
        var onNewLevel = function() {
            if (!shouldRandomizeFruit()) {
                currentFruit = fruits[level-1];
                fruitHistory[level] = currentFruit;
            }
        };

        var reset = function() {
            frame = 0;
            numFrames = 0;
            path = undefined;
        };

        var initiatePath = function(p) {
            frame = 0;
            numFrames = p.length*16;
            path = p;
        };
        var initiate = function() {
            if (shouldRandomizeFruit()) {
                currentFruit = fruits[getRandomInt(0,6)];
            }
            var entrances = map.fruitPaths.entrances;
            var e = entrances[getRandomInt(0,entrances.length-1)];
            initiatePath(e.path);
            pathMode = PATH_ENTER;
            pixel.x = e.start.x;
            pixel.y = e.start.y;
        };

        var onDotEat = function() {
            if (!isPresent() && (map.dotsEaten == dotLimit1 || map.dotsEaten == dotLimit2)) {
                initiate();
            }
        };

        var move = (function() {
            var bounce_frames = (function(){
                var U = { dx:0, dy:-1 };
                var D = { dx:0, dy:1 };
                var L = { dx:-1, dy:0 };
                var R = { dx:1, dy:0 };
                var UL = { dx:-1, dy:-1 };
                var UR = { dx:1, dy:-1 };
                var DL = { dx:-1, dy:1 };
                var DR = { dx:1, dy:1 };
                var Z = { dx:0, dy:0 };
                return {
                    '^': [U, U, U, U, U, U, U, U, U, Z, U, Z, Z, D, Z, D],
                    '>': [Z, UR,Z, R, Z, UR,Z, R, Z, R, Z, R, Z, DR,DR,Z],
                    '<': [Z, Z, UL,Z, L, Z, UL,Z, L, Z, L, Z, L, Z, DL,DL],
                    'v': [Z, D, D, D, D, D, D, D, D, D, D, D, U, U, Z, U],
                };
            })();

            return function() {
                var p = path[Math.floor(frame/16)]; // get current path frame
                var b = bounce_frames[p][frame%16]; // get current bounce animation frame
                pixel.x += b.dx;
                pixel.y += b.dy;
                frame++;
            };
        })();

        var setNextPath = function() {
            if (pathMode == PATH_ENTER) {
                pathMode = PATH_PEN;
                initiatePath(pen_path);
            }
            else if (pathMode == PATH_PEN) {
                pathMode = PATH_EXIT;
                var exits = map.fruitPaths.exits;
                var e = exits[getRandomInt(0,exits.length-1)];
                initiatePath(e.path);
            }
            else if (pathMode == PATH_EXIT) {
                reset();
            }
        };

        var update = function() {
            if (isPresent()) {
                move();
                if (frame == numFrames) {
                    setNextPath();
                }
            }
        };

        var isPresent = function() {
            return frame < numFrames;
        };

        var savedPixel = {};
        var savedPathMode = {};
        var savedFrame = {};
        var savedNumFrames = {};
        var savedPath = {};
        var save = function(t) {
            savedPixel[t] = {x:pixel.x, y:pixel.y};
            savedPathMode[t] = pathMode;
            savedFrame[t] = frame;
            savedNumFrames[t] = numFrames;
            savedPath[t] = path;
        };
        var load = function(t) {
            pixel.x = savedPixel[t].x;
            pixel.y = savedPixel[t].y;
            pathMode = savedPathMode[t];
            frame = savedFrame[t];
            numFrames = savedNumFrames[t]; 
            path = savedPath[t];
        };

        return {
            save: save,
            load: load,
            isPresent: isPresent,
            reset: reset,
            update: update,
            onDotEat: onDotEat,
            onNewLevel: onNewLevel,
        };
    })();

    // pac-man specific
    var pacFruit = (function() {

        var fruits = [
            {name:'cherry',     points:100},
            {name:'strawberry', points:300},
            {name:'orange',     points:500},
            {name:'apple',      points:700},
            {name:'melon',      points:1000},
            {name:'galaxian',   points:2000},
            {name:'bell',       points:3000},
            {name:'key',        points:5000},
        ];

        var duration = 9; // number of seconds that the fruit is on the screen
        var framesLeft; // frames left until fruit is off the screen

        var dotLimit1 = 70;
        var dotLimit2 = 170;

        var onNewLevel = (function() {
            var order = [
                0,  // level 1
                1,  // level 2 
                2,  // level 3
                2,  // level 4
                3,  // level 5
                3,  // level 6
                4,  // level 7
                4,  // level 8
                5,  // level 9
                5,  // level 10
                6,  // level 11
                6,  // level 12
                7]; // level 13+

            return function() {
                var i = level;
                if (i > 13) {
                    i=13;
                }
                i--;
                currentFruit = fruits[order[i]];
                fruitHistory[level] = currentFruit;
            };
        })();

        var initiate = function() {
            var x = 13;
            var y = 20;
            pixel.x = tileSize*(1+x)-1;
            pixel.y = tileSize*y + midTile.y;
            framesLeft = 60*duration;
        };

        var isPresent = function() {
            return framesLeft > 0;
        };

        var reset = function() {
            framesLeft = 0;
        };

        var update = function() {
            if (framesLeft > 0)
                framesLeft--;
        };

        var onDotEat = function() {
            if (!isPresent() && (map.dotsEaten == dotLimit1 || map.dotsEaten == dotLimit2)) {
                initiate();
            }
        };

        // saving state
        var savedFramesLeft = {};
        var save = function(t) {
            savedFramesLeft[t] = framesLeft;
        };
        var load = function(t) {
            framesLeft = savedFramesLeft[t];
        };

        return {
            save: save,
            load: load,
            isPresent: isPresent,
            reset: reset,
            update: update,
            onDotEat: onDotEat,
            onNewLevel: onNewLevel,
        };
    })();

    // manual polymorphism

    var getInterface = (function() {
        var fruitFromMode = {};
        fruitFromMode[GAME_PACMAN] = pacFruit;
        fruitFromMode[GAME_MSPACMAN] = mspacFruit;
        fruitFromMode[GAME_COOKIE] = mspacFruit; // for now
        return function() {
            return fruitFromMode[gameMode];
        };
    })();

    var save = function(t) {
        savedScoreFramesLeft[t] = scoreFramesLeft;
        getInterface().save(t);
    };

    var load = function(t) {
        scoreFramesLeft = savedScoreFramesLeft[t];
        getInterface().load(t);
    };

    var onNewLevel = function() {
        getInterface().onNewLevel();
    };

    var reset = function() {
        scoreFramesLeft = 0;
        getInterface().reset();
    };

    var getPoints = function() {
        return currentFruit.points;
    };

    var update = function() {
        getInterface().update();
        if (scoreFramesLeft > 0)
            scoreFramesLeft--;
    };
    
    var onDotEat = function() {
        getInterface().onDotEat();
    };

    var getPoints = function() {
        return currentFruit.points;
    };
    
    var testCollide = function() {
        if (isPresent() && Math.abs(pacman.pixel.y - pixel.y) <= midTile.y && Math.abs(pacman.pixel.x - pixel.x) <= midTile.x) {
            addScore(getPoints());
            reset();
            scoreFramesLeft = scoreDuration*60;
        }
    };

    var isPresent = function() {
        return getInterface().isPresent();
    };

    var getCurrentFruit = function() {
        return currentFruit;
    };

    return {
        save: save,
        load: load,
        pixel: pixel,
        reset: reset,
        update: update,
        onDotEat: onDotEat,
        isPresent: isPresent,
        isScorePresent: isScorePresent,
        testCollide: testCollide,
        getPoints: getPoints,
        onNewLevel: onNewLevel,
        getFruitHistory: function() { return fruitHistory; },
        getCurrentFruit: getCurrentFruit,
    };
})();
