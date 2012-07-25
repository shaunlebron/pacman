var executive = (function(){

    var interval; // used by setInterval and clearInterval to execute the game loop
    var timeout;
    var framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)
    var nextFrameTime;
    var running = false;

    /**********/
    // http://paulirish.com/2011/requestanimationframe-for-smart-animating/
    // http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating

    // requestAnimationFrame polyfill by Erik Möller
    // fixes from Paul Irish and Tino Zijdel

    (function() {
        var lastTime = 0;
        var vendors = ['ms', 'moz', 'webkit', 'o'];
        for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
            window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
            window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame']
                                       || window[vendors[x]+'CancelRequestAnimationFrame'];
        }
     
        if (!window.requestAnimationFrame)
            window.requestAnimationFrame = function(callback, element) {
                var currTime = new Date().getTime();
                var timeToCall = Math.max(0, 16 - (currTime - lastTime));
                var id = window.setTimeout(function() { callback(currTime + timeToCall); },
                  timeToCall);
                lastTime = currTime + timeToCall;
                return id;
            };
     
        if (!window.cancelAnimationFrame)
            window.cancelAnimationFrame = function(id) {
                clearTimeout(id);
            };
    }());
    /**********/
    var reqFrame;
    var fps;
    var updateFps = (function(){
        var length = 60;
        var times = [];
        var startIndex = 0;
        var endIndex = -1;
        var filled = false;

        return function(now) {
            if (filled) {
                startIndex = (startIndex+1) % length;
            }
            endIndex = (endIndex+1) % length;
            if (endIndex == length-1) {
                filled = true;
            }

            times[endIndex] = now;

            var seconds = (now - times[startIndex]) / 1000;
            var frames = endIndex - startIndex;
            if (frames < 0) {
                frames += length;
            }
            fps = frames / seconds;
            
            if (state == finishState) {
                //console.log(fps);
            }
        };
    })();
        

    var tick = function(now) {
        updateFps(now);

        // call update for every frame period that has elapsed
        var maxFrameSkip = 5;
        var frames = 0;
        if (framePeriod != Infinity) {
            while (frames < maxFrameSkip && (now > nextFrameTime)) {
                state.update();
                nextFrameTime += framePeriod;
                frames++;
            }
        }
        // draw after updates are caught up
        renderer.beginFrame();
        state.draw();
        renderer.endFrame();
        reqFrame = requestAnimationFrame(tick);
    };

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
            reqFrame = requestAnimationFrame(tick);
            running = true;
        },
        stop: function() {
            if (!running) return;
            cancelAnimationFrame(reqFrame);
            running = false;
        },
        getFps: function() { return fps; },
    };
})();
