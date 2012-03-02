var executive = (function(){

    var interval; // used by setInterval and clearInterval to execute the game loop
    var framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)
    var nextFrameTime;
    var running = false;

    return {

        // scheduling
        setUpdatesPerSecond: function(ups) {
            framePeriod = 1000/ups;
            nextFrameTime = (new Date).getTime();
        },
        init: function() {
            var that = this;
            window.addEventListener('focus', function() {that.start();});
            window.addEventListener('blur', function() {that.stop();});
            this.start();
        },
        start: function() {
            if (running) return;
            nextFrameTime = (new Date).getTime();
            var that = this;
            interval = setInterval(function(){that.tick();}, 1000/60);
            running = true;
        },
        stop: function() {
            if (!running) return;
            clearInterval(interval);
            running = false;
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
