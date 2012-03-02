var executive = (function(){

    var interval; // used by setInterval and clearInterval to execute the game loop
    var framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)
    var nextFrameTime;

    return {

        // scheduling
        setUpdatesPerSecond: function(ups) {
            framePeriod = 1000/ups;
            nextFrameTime = (new Date).getTime();
        },
        start: function() {
            nextFrameTime = (new Date).getTime();
            var that = this;
            interval = setInterval(function(){that.tick();}, 1000/60);
        },
        stop: function() {
            clearInterval(interval);
        },
        tick: (function(){
            var maxFrameSkip = 5;
            return function() {
                // call update for every frame period that has elapsed
                var frames = 0;
                if (framePeriod != Infinity) {
                    while (frames < maxFrameSkip && (new Date).getTime() > nextFrameTime) {
                        state.update();
                        nextFrameTime += framePeriod;
                        frames++;
                    }
                }
                // draw after updates are caught up
                state.draw();
            };
        })(),

    };
})();
