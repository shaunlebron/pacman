
// REFERENCED GLOBALS:
/* global inGameMenu -- inGameMenu.js */
/* global hud -- hud.js */
/* global state -- states.js */
/* global renderer -- renderers.js */
/* global vcr -- vcr.js */

const executive = (function(){

    let framePeriod = 1000/60; // length of each frame at 60Hz (updates per second)
    let gameTime; // virtual time of the last game update

    let paused = false; // flag for pausing the state updates, while still drawing
    let running = false; // flag for truly stopping everything

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

        getFramePeriod() {
            return framePeriod;
        },
        setUpdatesPerSecond(ups) {
            framePeriod = 1000/ups;
            //gameTime = undefined;
            vcr.onFramePeriodChange();
        },
        init() {
            const that = this;
            window.addEventListener('focus', function() {that.start();});
            window.addEventListener('blur', function() {that.stop();});
            this.start();
        },
        start() {
            if (!running) {
                reqFrame = requestAnimationFrame(tick);
                running = true;
            }
        },
        stop() {
            if (running) {
                cancelAnimationFrame(reqFrame);
                running = false;
            }
        },
        togglePause() { paused = !paused; },
        isPaused() { return paused; },
        getFps() { return fps; },
    };
})();
