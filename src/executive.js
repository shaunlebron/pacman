
// REFERENCED GLOBALS:
// import { inGameMenu } from './inGameMenu.js';
// import { hud } from './hud.js';
// import { state } from './states.js';
// import { renderer } from './renderers.js';
// import { vcr } from './vcr.js';

const executive = (function(){

    let framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)
    let gameTime; // virtual time of the last game update

    let paused = false; // flag for pausing the state updates, while still drawing
    let running = false; // flag for truly stopping everything

    /**********/
    // http://paulirish.com/2011/requestanimationframe-for-smart-animating/
    // http://my.opera.com/emoller/blog/2011/12/20/requestanimationframe-for-smart-er-animating

    // requestAnimationFrame polyfill by Erik Möller
    // fixes from Paul Irish and Tino Zijdel

    (function() {
        let lastTime = 0;
        const vendors = ['ms', 'moz', 'webkit', 'o'];
        for(let x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
            window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
            window.cancelAnimationFrame = window[vendors[x]+'CancelAnimationFrame']
                                       || window[vendors[x]+'CancelRequestAnimationFrame'];
        }
     
        if (!window.requestAnimationFrame)
            window.requestAnimationFrame = function(callback, element) {
                const currTime = new Date().getTime();
                const timeToCall = Math.max(0, 16 - (currTime - lastTime));
                const id = window.setTimeout(function() { callback(currTime + timeToCall); },
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

    let fps;
    const updateFps = (function(){
        // TODO: fix this to reflect the average rate of the last n frames, where 0 < n < 60
        const length = 60;
        const times = [];
        let startIndex = 0;
        let endIndex = -1;
        let filled = false;

        return function(now) {
            if (filled) {
                startIndex = (startIndex+1) % length;
            }
            endIndex = (endIndex+1) % length;
            if (endIndex == length-1) {
                filled = true;
            }

            times[endIndex] = now;

            const seconds = (now - times[startIndex]) / 1000;
            let frames = endIndex - startIndex;
            if (frames < 0) {
                frames += length;
            }
            fps = frames / seconds;
        };
    })();
        

    let reqFrame; // id of requestAnimationFrame object
    const tick = function(now) {
        if (gameTime == undefined) {
            gameTime = now;
        }

        // Update fps counter.
        updateFps(now);

        // Control frame-skipping by only allowing gameTime to lag behind the current time by some amount.
        const maxFrameSkip = 3;
        gameTime = Math.max(gameTime, now-maxFrameSkip*framePeriod);

        // Prevent any updates from being called when paused.
        if (paused || inGameMenu.isOpen()) {
            gameTime = now;
        }

        hud.update();

        // Update the game until the gameTime surpasses the current time.
        while (gameTime < now) {
            state.update();
            gameTime += framePeriod;
        }

        // Draw.
        renderer.beginFrame();
        state.draw();
        if (hud.isValidState()) {
            renderer.renderFunc(hud.draw);
        }
        renderer.endFrame();

        // Schedule the next tick.
        reqFrame = requestAnimationFrame(tick);
    };

    return {

        getFramePeriod: function() {
            return framePeriod;
        },
        setUpdatesPerSecond: function(ups) {
            framePeriod = 1000/ups;
            //gameTime = undefined;
            vcr.onFramePeriodChange();
        },
        init: function() {
            const that = this;
            window.addEventListener('focus', function() {that.start();});
            window.addEventListener('blur', function() {that.stop();});
            this.start();
        },
        start: function() {
            if (!running) {
                reqFrame = requestAnimationFrame(tick);
                running = true;
            }
        },
        stop: function() {
            if (running) {
                cancelAnimationFrame(reqFrame);
                running = false;
            }
        },
        togglePause: function() { paused = !paused; },
        isPaused: function() { return paused; },
        getFps: function() { return fps; },
    };
})();
