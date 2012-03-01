//////////////////////////////////////////////////////////////////////////////////////
// Game

var GAME_PACMAN = 0;
var GAME_MSPACMAN = 1;

var game = (function(){

    var interval; // used by setInterval and clearInterval to execute the game loop
    var framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)
    var nextFrameTime;

    return {

        mode:GAME_PACMAN,

        // scoring
        highScore:0,
        score:0,
        addScore: function(p) {
            if (this.score < 10000 && this.score+p >= 10000)
                this.extraLives++;
            this.score += p;
            if (this.score > this.highScore)
                this.highScore = this.score;
        },

        // current level and lives left
        level:1,
        extraLives:0,

        // scheduling
        setUpdatesPerSecond: function(ups) {
            framePeriod = 1000/ups;
            nextFrameTime = (new Date).getTime();
        },
        restart: function() {
            this.switchState(menuState);
            this.resume();
        },
        pause: function() {
            clearInterval(interval);
        },
        resume: function() {
            nextFrameTime = (new Date).getTime();
            interval = setInterval(function(){game.tick();}, 1000/60);
        },
        tick: (function(){
            var maxFrameSkip = 5;
            return function() {
                // call update for every frame period that has elapsed
                var frames = 0;
                if (framePeriod != Infinity) {
                    while (frames < maxFrameSkip && (new Date).getTime() > nextFrameTime) {
                        this.state.update();
                        nextFrameTime += framePeriod;
                        frames++;
                    }
                }
                // draw after updates are caught up
                this.state.draw();
            };
        })(),

        // switches to another game state
        switchState: function(nextState,fadeDuration, continueUpdate1, continueUpdate2) {
            this.state = (fadeDuration) ? fadeNextState(this.state,nextState,fadeDuration, continueUpdate1, continueUpdate2) : nextState;
            this.state.init();
        },

        // switches to another map
        switchMap: function(map) {
            tileMap = maps[map];
            tileMap.onLoad();
        },

    };
})();
