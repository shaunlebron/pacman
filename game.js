//////////////////////////////////////////////////////////////////////////////////////
// Game

var game = (function(){

    var interval; // used by setInterval and clearInterval to execute the game loop
    var framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)

    return {
        highScore:0,
        restart: function() {
            this.switchState(startupState);
            this.resume();
        },
        pause: function() {
            clearInterval(interval);
        },
        resume: function() {
            interval = setInterval("game.tick()", framePeriod);
        },
        switchMap: function(i) {
            // just restart the map I guess?
            tileMap = maps[i];
            tileMap.onLoad();
            this.switchState(newGameState);
        },
        switchState: function(s) {
            s.init();
            this.state = s;
        },
        addScore: function(p) {
            this.score += p;
            if (this.score > this.highScore)
                this.highScore = this.score;
            if (this.score == 10000)
                this.extraLives++;
        },
        tick: (function(){
            var nextFrameTime = (new Date).getTime();
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
