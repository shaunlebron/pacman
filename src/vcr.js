//////////////////////////////////////////////////////////////////////////////////////
// VCR
// This coordinates the recording, rewinding, and replaying of the game state.
// Inspired by Braid.

var VCR_NONE = -1;
var VCR_RECORD = 0;
var VCR_REWIND = 1;
var VCR_FORWARD = 2;
var VCR_PAUSE = 3;

var vcr = (function() {

    var mode;

    // controls whether to increment the frame before recording.
    var initialized;

    // current time
    var time;

    // tracking speed
    var speedIndex;
    var speeds = [-8,-4,-2,-1,0,1,2,4,8];
    var speedCount = speeds.length;
    var speedColors = [
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
    var speedPrints = [
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
    var speedPrintStep = [
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
    var frame;

    // maximum number of frames to record
    var maxFrames = 15*60;

    // rolling bounds of the recorded frames
    var startFrame; // can't rewind past this
    var stopFrame; // can't replay past this

    // reset the VCR
    var reset = function() {
        time = 0;
        frame = 0;
        startFrame = 0;
        stopFrame = 0;
        states = {};
        startRecording();
    };

    // load the state of the current time
    var load = function() {
        var i;
        for (i=0; i<5; i++) {
            actors[i].load(frame);
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
    var save = function() {
        var i;
        for (i=0; i<5; i++) {
            actors[i].save(frame);
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
    var eraseFuture = function() {
        map.eraseFuture(time);
        stopFrame = frame;
    };

    // increment or decrement the time
    var addTime = function(dt) {
        time += dt;
        frame = (frame+dt)%maxFrames;
        if (frame < 0) {
            frame += maxFrames;
        }
    };

    // measures the modular distance if increasing from x0 to x1 on our circular frame buffer.
    var getForwardDist = function(x0,x1) {
        return (x0 <= x1) ? x1-x0 : x1+maxFrames-x0;
    };

    // caps the time increment or decrement to prevent going over our rolling bounds.
    var capSeekTime = function(dt) {
        if (!initialized || dt == 0) {
            return 0;
        }
        var maxForward = getForwardDist(frame,stopFrame);
        var maxReverse = getForwardDist(startFrame,frame);
        return (dt > 0) ? Math.min(maxForward,dt) : Math.max(-maxReverse,dt);
    };

    var init = function() {
        mode = VCR_NONE;
    };

    // seek to the state at the given relative time difference.
    var seek = function(dt) {
        if (dt == undefined) {
            dt = speeds[speedIndex];
        }
        if (initialized) {
            addTime(capSeekTime(dt));
            load();
        }
    };

    // record a new state.
    var record = function() {
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

    var startRecording = function() {
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

    var refreshSeekDisplay = function() {
        seekToggleBtn.setText(speeds[speedIndex]+"x");
    };

    var startSeeking = function() {
        speedIndex = 3;
        updateMode();
        seekUpBtn.enable();
        seekDownBtn.enable();
        seekToggleBtn.setIcon(undefined);
        refreshSeekDisplay();
    };

    var nextSpeed = function(di) {
        if (speeds[speedIndex+di] != undefined) {
            speedIndex = speedIndex+di;
        }
        updateMode();
        refreshSeekDisplay();
    };

    var x,y,w,h;
    var pad = 5;
    x = mapWidth+1;
    h = 25;
    w = 25;
    y = mapHeight/2-h/2;
    var seekUpBtn = new Button(x,y-h-pad,w,h,
        function() {
            nextSpeed(1);
        });
    seekUpBtn.setIcon(function(ctx,x,y,frame) {
        drawUpSymbol(ctx,x,y,"#FFF");
    });
    var seekDownBtn = new Button(x,y+h+pad,w,h,
        function() {
            nextSpeed(-1);
        });
    seekDownBtn.setIcon(function(ctx,x,y,frame) {
        drawDownSymbol(ctx,x,y,"#FFF");
    });
    var seekToggleBtn = new ToggleButton(x,y,w,h,
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
    var slowBtn = new ToggleButton(-w-pad-1,y,w,h,
        function() {
            return executive.getFramePeriod() == 1000/15;
        },
        function(on) {
            executive.setUpdatesPerSecond(on ? 15 : 60);
        });
    slowBtn.setIcon(function(ctx,x,y) {
        atlas.drawSnail(ctx,x,y,1);
    });

    var onFramePeriodChange = function() {
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

    var onHudEnable = function() {
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

    var onHudDisable = function() {
        if (practiceMode) {
            seekUpBtn.disable();
            seekDownBtn.disable();
            seekToggleBtn.disable();
            slowBtn.disable();
        }
    };

    var isValidState = function() {
        return (
            !inGameMenu.isOpen() && (
            state == playState ||
            state == finishState ||
            state == deadState));
    };

    var draw = function(ctx) {
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

    var updateMode = function() {
        var speed = speeds[speedIndex];
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
            var maxReverse = getForwardDist(startFrame,frame);
            var start = (frame - Math.min(maxReverse,speedPrints[speedIndex])) % maxFrames;
            if (start < 0) {
                start += maxFrames;
            }

            // determine end frame
            var maxForward = getForwardDist(frame,stopFrame);
            var end = (frame + Math.min(maxForward,speedPrints[speedCount-1-speedIndex])) % maxFrames;

            var backupAlpha = ctx.globalAlpha;
            ctx.globalAlpha = 0.2;
            
            var t = start;
            var step = speedPrintStep[speedIndex];
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
