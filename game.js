
var game = (function() {

    var framePeriod = 1000/60;
    var nextFrameTime;

    return {
        highScore:0,
        reset: function() {
            this.extraLives = 3;
            this.level = 1;
            this.score = 0;
            this.switchState(firstState);
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
        tick = function() {
            // call update for every frame period that has elapsed
            while ((new Date).getTime() > nextFrameTime) {
                this.state.update();
                nextFrameTime += framePeriod;
            }
            // draw after updates are caught up
            this.state.draw();
        };
    };
})();

