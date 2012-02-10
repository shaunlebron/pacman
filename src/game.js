//////////////////////////////////////////////////////////////////////////////////////
// Game

var game = (function(){

    var interval; // used by setInterval and clearInterval to execute the game loop
    var framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)
    var nextFrameTime;

    return {
        highScore:0,
        score:0,
        extraLives:0,
        level:1,
        setUpdatesPerSecond: function(ups) {
            framePeriod = 1000/ups;
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
        switchMap: function(map) {
            tileMap = maps[map];
            tileMap.onLoad();
        },
        switchState: function(nextState,fadeDuration) {
            this.state = (fadeDuration) ? fadeNextState(this.state,nextState,fadeDuration) : nextState;
            this.state.init();
        },
        addScore: function(p) {
            if (this.score < 10000 && this.score+p >= 10000)
                this.extraLives++;
            this.score += p;
            if (this.score > this.highScore)
                this.highScore = this.score;
        },
        tick: (function(){
            var maxFrameSkip = 5;
            return function() {
                // call update for every frame period that has elapsed
                var frames = 0;
                while (frames < maxFrameSkip && (new Date).getTime() > nextFrameTime) {
                    this.state.update();
                    nextFrameTime += framePeriod;
                    frames++;
                }
                // draw after updates are caught up
                this.state.draw();
            };
        })(),
    };
})();
