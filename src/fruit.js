//////////////////////////////////////////////////////////////////////////////////////
// Fruit

var BaseFruit = function() {
    // pixel
    this.pixel = {x:0, y:0};

    this.fruitHistory = {};

    this.scoreDuration = 2; // number of seconds that the fruit score is on the screen
    this.scoreFramesLeft; // frames left until the picked-up fruit score is off the screen
    this.savedScoreFramesLeft = {};
};

BaseFruit.prototype = {
    isScorePresent: function() {
        return this.scoreFramesLeft > 0;
    },
    onNewLevel: function() {
    },
    setCurrentFruit: function(i) {
        this.currentFruitIndex = i;
    },
    commitToFruitHistory: function() {
        this.fruitHistory[level] = this.fruits[this.currentFruitIndex];
    },
    onDotEat: function() {
        if (!this.isPresent() && (map.dotsEaten == this.dotLimit1 || map.dotsEaten == this.dotLimit2)) {
            this.initiate();
        }
    },
    save: function(t) {
        this.savedScoreFramesLeft[t] = this.scoreFramesLeft;
    },
    load: function(t) {
        this.scoreFramesLeft = this.savedScoreFramesLeft[t];
    },
    reset: function() {
        this.scoreFramesLeft = 0;
    },
    getCurrentFruit: function() {
        return this.fruits[this.currentFruitIndex];
    },
    getPoints: function() {
        return this.getCurrentFruit().points;
    },
    update: function() {
        if (this.scoreFramesLeft > 0)
            this.scoreFramesLeft--;
    },
    isCollide: function() {
        return Math.abs(pacman.pixel.y - this.pixel.y) <= midTile.y && Math.abs(pacman.pixel.x - this.pixel.x) <= midTile.x;
    },
    testCollide: function() {
        if (this.isPresent() && this.isCollide()) {
            addScore(this.getPoints());
            this.reset();
            this.scoreFramesLeft = this.scoreDuration*60;
        }
    },
};

// PAC-MAN FRUIT

var PacFruit = function() {
    BaseFruit.call(this);
    this.fruits = [
        {name:'cherry',     points:100},
        {name:'strawberry', points:300},
        {name:'orange',     points:500},
        {name:'apple',      points:700},
        {name:'melon',      points:1000},
        {name:'galaxian',   points:2000},
        {name:'bell',       points:3000},
        {name:'key',        points:5000},
    ];

    this.order = [
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

    this.dotLimit1 = 70;
    this.dotLimit2 = 170;

    this.duration = 9; // number of seconds that the fruit is on the screen
    this.framesLeft; // frames left until fruit is off the screen

    this.savedFramesLeft = {};
};

PacFruit.prototype = {

    __proto__: BaseFruit.prototype,

    onNewLevel: function() {
        var i = level;
        if (i > 13) {
            i=13;
        }
        i--;
        this.setCurrentFruit(this.order[i]);
        this.commitToFruitHistory();
    },

    initiate: function() {
        var x = 13;
        var y = 20;
        this.pixel.x = tileSize*(1+x)-1;
        this.pixel.y = tileSize*y + midTile.y;
        this.framesLeft = 60*this.duration;
    },

    isPresent: function() {
        return this.framesLeft > 0;
    },

    reset: function() {
        BaseFruit.prototype.reset.call(this);

        this.framesLeft = 0;
    },

    update: function() {
        BaseFruit.prototype.update.call(this);

        if (this.framesLeft > 0)
            this.framesLeft--;
    },

    save: function(t) {
        BaseFruit.prototype.save.call(this,t);
        this.savedFramesLeft[t] = this.framesLeft;
    },
    load: function(t) {
        BaseFruit.prototype.load.call(this,t);
        this.framesLeft = this.savedFramesLeft[t];
    },
};

// MS. PAC-MAN FRUIT

var PATH_ENTER = 0;
var PATH_PEN = 1;
var PATH_EXIT = 2;

var MsPacFruit = function() {
    BaseFruit.call(this);
    this.fruits = [
        {name: 'cherry',     points: 100},
        {name: 'strawberry', points: 200},
        {name: 'orange',     points: 500},
        {name: 'pretzel',    points: 700},
        {name: 'apple',      points: 1000},
        {name: 'pear',       points: 2000},
        {name: 'banana',     points: 5000},
    ];

    this.dotLimit1 = 64;
    this.dotLimit2 = 176;

    this.pen_path = "<<<<<<^^^^^^>>>>>>>>>vvvvvv<<";

    this.savedIsPresent = {};
    this.savedPixel = {};
    this.savedPathMode = {};
    this.savedFrame = {};
    this.savedNumFrames = {};
    this.savedPath = {};
};

MsPacFruit.prototype = {
    __proto__: BaseFruit.prototype,

    shouldRandomizeFruit: function() {
        return level > 7;
    },

    onNewLevel: function() {
        if (!this.shouldRandomizeFruit()) {
            this.setCurrentFruit(level-1);
            this.commitToFruitHistory();
        }
    },

    reset: function() {
        BaseFruit.prototype.reset.call(this);

        this.frame = 0;
        this.numFrames = 0;
        this.path = undefined;
    },

    initiatePath: function(p) {
        this.frame = 0;
        this.numFrames = p.length*16;
        this.path = p;
    },

    initiate: function() {
        if (this.shouldRandomizeFruit()) {
            this.setCurrentFruit(getRandomInt(0,6));
        }
        var entrances = map.fruitPaths.entrances;
        var e = entrances[getRandomInt(0,entrances.length-1)];
        this.initiatePath(e.path);
        this.pathMode = PATH_ENTER;
        this.pixel.x = e.start.x;
        this.pixel.y = e.start.y;
    },

    isPresent: function() {
        return this.frame < this.numFrames;
    },

    bounceFrames: (function(){
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
    })(),

    move: function() {
        var p = this.path[Math.floor(this.frame/16)]; // get current path frame
        var b = this.bounceFrames[p][this.frame%16]; // get current bounce animation frame
        this.pixel.x += b.dx;
        this.pixel.y += b.dy;
        this.frame++;
    },

    setNextPath: function() {
        if (this.pathMode == PATH_ENTER) {
            this.pathMode = PATH_PEN;
            this.initiatePath(this.pen_path);
        }
        else if (this.pathMode == PATH_PEN) {
            this.pathMode = PATH_EXIT;
            var exits = map.fruitPaths.exits;
            var e = exits[getRandomInt(0,exits.length-1)];
            this.initiatePath(e.path);
        }
        else if (this.pathMode == PATH_EXIT) {
            this.reset();
        }
    },

    update: function() {
        BaseFruit.prototype.update.call(this);

        if (this.isPresent()) {
            this.move();
            if (this.frame == this.numFrames) {
                this.setNextPath();
            }
        }
    },

    save: function(t) {
        BaseFruit.prototype.save.call(this,t);

        this.savedPixel[t] =        this.isPresent() ? {x:this.pixel.x, y:this.pixel.y} : undefined;
        this.savedPathMode[t] =     this.pathMode;
        this.savedFrame[t] =        this.frame;
        this.savedNumFrames[t] =    this.numFrames;
        this.savedPath[t] =         this.path;
    },

    load: function(t) {
        BaseFruit.prototype.load.call(this,t);

        if (this.savedPixel[t]) {
            this.pixel.x =      this.savedPixel[t].x;
            this.pixel.y =      this.savedPixel[t].y;
        }
        this.pathMode =     this.savedPathMode[t];
        this.frame =        this.savedFrame[t];
        this.numFrames =    this.savedNumFrames[t]; 
        this.path =         this.savedPath[t];
    },
};

var fruit;
var setFruitFromGameMode = (function() {
    var pacfruit = new PacFruit();
    var mspacfruit = new MsPacFruit();
    return function() {
        if (gameMode == GAME_PACMAN) {
            fruit = pacfruit;
        }
        else {
            fruit = mspacfruit;
        }
    };
})();
