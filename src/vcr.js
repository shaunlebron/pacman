
// REFERENCED GLOBALS:
// import { actors } from './actors.js';
// import { elroyTimer } from './elroyTimer.js';
// import { energizer } from './energizer.js';
// import { fruit } from './fruit.js';
// import { ghostCommander } from './ghostCommander.js';
// import { ghostReleaser } from './ghostReleaser.js';
// import { map } from './maps.js';
// import { loadGame, saveGame, practiceMode } from './game.js';
// import { state, deadState, finishState, playState } from './states.js';
// import { inGameMenu } from './inGameMenu.js';
// import { renderer, mapWidth, mapHeight } from './renderers.js';
// import { atlas } from './atlas.js';
// import { Button, ToggleButton } from './Button.js';
// import { drawRewindSymbol, drawUpSymbol, drawDownSymbol } from './sprites.js';
// import { executive } from './executive.js';
// import { tileSize } from './Map.js';

//////////////////////////////////////////////////////////////////////////////////////
// VCR
// This coordinates the recording, rewinding, and replaying of the game state.
// Inspired by Braid.

const VCR_NONE = -1;
const VCR_RECORD = 0;
const VCR_REWIND = 1;
const VCR_FORWARD = 2;
const VCR_PAUSE = 3;

const vcr = (function() {

    let mode;

    // controls whether to increment the frame before recording.
    let initialized;

    // current time
    let time;

    // tracking speed
    let speedIndex;
    const speeds = [-8,-4,-2,-1,0,1,2,4,8];
    const speedCount = speeds.length;
    const speedColors = [
        "rgba(255,255,0,0.25)",
        "rgba(255,255,0,0.20)",
        "rgba(255,255,0,0.15)",
        "rgba(255,255,0,0.10)",
        "rgba(0,0,0,0)",
        "rgba(0,0,255,0.10)",
        "rgba(0,0,255,0.15)",
        "rgba(0,0,255,0.20)",
        "rgba(0,0,255,0.25)",
    ];

    // This is the number of "footprint" frames to display along the seek direction around a player
    // to create the rewind/forward blurring.  
    // This is also inversely used to determine the number of footprint frames to display OPPOSITE the seek direction
    // around a player.
    //
    // For example: 
    //   nextFrames = speedPrints[speedIndex];
    //   prevFrames = speedPrints[speedCount-1-speedIndex];
    const speedPrints = [
        18,// -8x
        13,// -4x
        8, // -2x
        3, // -1x
        3, //  0x
        10,//  1x
        15,//  2x
        20,//  4x
        25,//  8x
    ];

    // The distance between each footprint used in the rewind/forward blurring.
    // Step size grows when seeking speed increases to show emphasize time dilation.
    const speedPrintStep = [
        6,  // -8x
        5,  // -4x
        4,  // -2x
        3,  // -1x
        3,  //  0x
        3,  //  1x
        4,  //  2x
        5,  //  4x
        6,  //  8x
    ];

    // current frame associated with current time
    // (frame == time % maxFrames)
    let frame;

    // maximum number of frames to record
    const maxFrames = 15*60;

    // rolling bounds of the recorded frames
    let startFrame; // can't rewind past this
    let stopFrame; // can't replay past this

    // reset the VCR
    const reset = function() {
        time = 0;
        frame = 0;
        startFrame = 0;
        stopFrame = 0;
        states = {};
        startRecording();
    };

    // load the state of the current time
    const load = function() {
        for (const a of actors) {
            a.load(frame);
        }
        elroyTimer.load(frame);
        energizer.load(frame);
        fruit.load(frame);
        ghostCommander.load(frame);
        ghostReleaser.load(frame);
        map.load(frame,time);
        loadGame(frame);
        if (state == deadState) {
            deadState.load(frame);
        }
        else if (state == finishState) {
            finishState.load(frame);
        }
    };

    // save the state of the current time
    const save = function() {
        for (const a of actors) {
            a.save(frame);
        }
        elroyTimer.save(frame);
        energizer.save(frame);
        fruit.save(frame);
        ghostCommander.save(frame);
        ghostReleaser.save(frame);
        map.save(frame);
        saveGame(frame);
        if (state == deadState) {
            deadState.save(frame);
        }
        else if (state == finishState) {
            finishState.save(frame);
        }
    };

    // erase any states after the current time
    // (only necessary for saves that do interpolation)
    const eraseFuture = function() {
        map.eraseFuture(time);
        stopFrame = frame;
    };

    // increment or decrement the time
    const addTime = function(dt) {
        time += dt;
        frame = (frame+dt)%maxFrames;
        if (frame < 0) {
            frame += maxFrames;
        }
    };

    // measures the modular distance if increasing from x0 to x1 on our circular frame buffer.
    const getForwardDist = function(x0,x1) {
        return (x0 <= x1) ? x1-x0 : x1+maxFrames-x0;
    };

    // caps the time increment or decrement to prevent going over our rolling bounds.
    const capSeekTime = function(dt) {
        if (!initialized || dt == 0) {
            return 0;
        }
        const maxForward = getForwardDist(frame,stopFrame);
        const maxReverse = getForwardDist(startFrame,frame);
        return (dt > 0) ? Math.min(maxForward,dt) : Math.max(-maxReverse,dt);
    };

    const init = function() {
        mode = VCR_NONE;
    };

    // seek to the state at the given relative time difference.
    const seek = function(dt) {
        if (dt == undefined) {
            dt = speeds[speedIndex];
        }
        if (initialized) {
            addTime(capSeekTime(dt));
            load();
        }
    };

    // record a new state.
    const record = function() {
        if (initialized) {
            addTime(1);
            if (frame == startFrame) {
                startFrame = (startFrame+1)%maxFrames;
            }
            stopFrame = frame;
        }
        else {
            initialized = true;
        }
        save();
    };

    const startRecording = function() {
        mode = VCR_RECORD;
        initialized = false;
        eraseFuture();
        seekUpBtn.disable();
        seekDownBtn.disable();
        seekToggleBtn.setIcon(function(ctx,x,y,frame) {
            drawRewindSymbol(ctx,x,y,"#FFF");
        });
        seekToggleBtn.setText();
    };

    const refreshSeekDisplay = function() {
        seekToggleBtn.setText(speeds[speedIndex]+"x");
    };

    const startSeeking = function() {
        speedIndex = 3;
        updateMode();
        seekUpBtn.enable();
        seekDownBtn.enable();
        seekToggleBtn.setIcon(undefined);
        refreshSeekDisplay();
    };

    const nextSpeed = function(di) {
        if (speeds[speedIndex+di] != undefined) {
            speedIndex = speedIndex+di;
        }
        updateMode();
        refreshSeekDisplay();
    };

    const pad = 5;
    const x = mapWidth+1;
    const h = 25;
    const w = 25;
    const y = mapHeight/2-h/2;

    const seekUpBtn = new Button(x,y-h-pad,w,h,
        function() {
            nextSpeed(1);
        });
    seekUpBtn.setIcon(function(ctx,x,y,frame) {
        drawUpSymbol(ctx,x,y,"#FFF");
    });
    const seekDownBtn = new Button(x,y+h+pad,w,h,
        function() {
            nextSpeed(-1);
        });
    seekDownBtn.setIcon(function(ctx,x,y,frame) {
        drawDownSymbol(ctx,x,y,"#FFF");
    });
    const seekToggleBtn = new ToggleButton(x,y,w,h,
        function() {
            return mode != VCR_RECORD;
        },
        function(on) {
            on ? startSeeking() : startRecording();
        });
    seekToggleBtn.setIcon(function(ctx,x,y,frame) {
        drawRewindSymbol(ctx,x,y,"#FFF");
    });
    seekToggleBtn.setFont((tileSize-1)+"px ArcadeR", "#FFF");
    const slowBtn = new ToggleButton(-w-pad-1,y,w,h,
        function() {
            return executive.getFramePeriod() == 1000/15;
        },
        function(on) {
            executive.setUpdatesPerSecond(on ? 15 : 60);
        });
    slowBtn.setIcon(function(ctx,x,y) {
        atlas.drawSnail(ctx,x,y,1);
    });

    const onFramePeriodChange = function() {
        if (slowBtn.isOn()) {
            slowBtn.setIcon(function(ctx,x,y) {
                atlas.drawSnail(ctx,x,y,0);
            });
        }
        else {
            slowBtn.setIcon(function(ctx,x,y) {
                atlas.drawSnail(ctx,x,y,1);
            });
        }
    };

    const onHudEnable = function() {
        if (practiceMode) {
            if (mode == VCR_NONE || mode == VCR_RECORD) {
                seekUpBtn.disable();
                seekDownBtn.disable();
            }
            else {
                seekUpBtn.enable();
                seekDownBtn.enable();
            }
            seekToggleBtn.enable();
            slowBtn.enable();
        }
    };

    const onHudDisable = function() {
        if (practiceMode) {
            seekUpBtn.disable();
            seekDownBtn.disable();
            seekToggleBtn.disable();
            slowBtn.disable();
        }
    };

    const isValidState = function() {
        return (
            !inGameMenu.isOpen() && (
            state == playState ||
            state == finishState ||
            state == deadState));
    };

    const draw = function(ctx) {
        if (practiceMode) {
            if (isValidState() && vcr.getMode() != VCR_RECORD) {
                // change the hue to reflect speed
                renderer.setOverlayColor(speedColors[speedIndex]);
            }

            if (seekUpBtn.isEnabled) {
                seekUpBtn.draw(ctx);
            }
            if (seekDownBtn.isEnabled) {
                seekDownBtn.draw(ctx);
            }
            if (seekToggleBtn.isEnabled) {
                seekToggleBtn.draw(ctx);
            }
            if (slowBtn.isEnabled) {
                slowBtn.draw(ctx);
            }
        }
    };

    const updateMode = function() {
        const speed = speeds[speedIndex];
        if (speed == 0) {
            mode = VCR_PAUSE;
        }
        else if (speed < 0) {
            mode = VCR_REWIND;
        }
        else if (speed > 0) {
            mode = VCR_FORWARD;
        }
    };

    return {
        init: init,
        reset: reset,
        seek: seek,
        record: record,
        draw: draw,
        onFramePeriodChange: onFramePeriodChange,
        onHudEnable: onHudEnable,
        onHudDisable: onHudDisable,
        eraseFuture: eraseFuture,
        startRecording: startRecording,
        startSeeking: startSeeking,
        nextSpeed: nextSpeed,
        isSeeking: function() {
            return (
                mode == VCR_REWIND ||
                mode == VCR_FORWARD ||
                mode == VCR_PAUSE);
        },
        getTime: function() { return time; },
        getFrame: function() { return frame; },
        getMode: function() { return mode; },

        drawHistory: function(ctx,callback) {
            if (!this.isSeeking()) {
                return;
            }

            // determine start frame
            const maxReverse = getForwardDist(startFrame,frame);
            let start = (frame - Math.min(maxReverse,speedPrints[speedIndex])) % maxFrames;
            if (start < 0) {
                start += maxFrames;
            }

            // determine end frame
            const maxForward = getForwardDist(frame,stopFrame);
            const end = (frame + Math.min(maxForward,speedPrints[speedCount-1-speedIndex])) % maxFrames;

            const backupAlpha = ctx.globalAlpha;
            ctx.globalAlpha = 0.2;
            
            let t = start;
            const step = speedPrintStep[speedIndex];
            if (start > end) {
                for (; t<maxFrames; t+=step) {
                    callback(t);
                }
                t %= maxFrames;
            }
            for (; t<end; t+=step) {
                callback(t);
            }

            ctx.globalAlpha = backupAlpha;
        },
    };
})();
