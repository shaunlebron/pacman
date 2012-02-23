//////////////////////////////////////////////////////////////////////////////////////
// Screen
// (controls the display and input)

var screen = (function() {

    // html elements
    var divContainer;
    var canvas, ctx;
    var bgCanvas, bgCtx;

    // drawing scale
    var scale = 1.5;        // scale everything by this amount
    var smoothScale = true; // smooth is a vector scale rather than a pixel scale

    // creates a canvas
    var makeCanvas = function() {
        var c = document.createElement("canvas");

        // use conventional pacman map size
        c.width = 28*tileSize;
        c.height = 36*tileSize;

        // scale 'direct' width and height properties for smooth vector scaling
        if (smoothScale) {
            c.width *= scale;
            c.height *= scale;
        }
        // scale 'style' width and height properties for pixel stretch scaling
        else {
            c.style.width = c.width*scale;
            c.style.height = c.height*scale;
        }

        // transform to scale
        var ctx = c.getContext("2d");
        if (smoothScale)
            ctx.scale(scale,scale);
        return c;
    };

    // add interative options to tune the game
    var addControls = function() {

        var controlDiv = document.getElementById("pacman-controls");
        if (!controlDiv)
            return;

        // used for making html elements with unique id's
        var id = 0;

        // create a form field group with the given title caption
        var makeFieldSet = function(title) {
            var fieldset = document.createElement('fieldset');
            fieldset.width = 200;
            var legend = document.createElement('legend');
            legend.appendChild(document.createTextNode(title));
            fieldset.appendChild(legend);
            return fieldset;
        };

        // add a checkbox
        var addCheckbox = function(fieldset, caption, onChange, on) {
            id++;
            var checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.id = 'check'+id;
            checkbox.checked = on;
            checkbox.onchange = function() { onChange(checkbox.checked); };
            fieldset.appendChild(checkbox);

            label = document.createElement('label');
            label.htmlFor = 'check'+id;
            label.appendChild(document.createTextNode(caption));
            fieldset.appendChild(label);

            fieldset.appendChild(document.createElement('br'));
        };

        // add a radio button
        var addRadio = function(fieldset, group, caption, onChange,on) {
            id++;
            var radio = document.createElement('input');
            radio.type = 'radio';
            radio.name = group;
            radio.id = 'radio'+id;
            radio.checked = on;
            radio.onchange = function() { onChange(radio.checked); };
            fieldset.appendChild(radio);

            label = document.createElement('label');
            label.htmlFor = 'radio'+id;
            label.appendChild(document.createTextNode(caption));
            fieldset.appendChild(label);

            fieldset.appendChild(document.createElement('br'));
        };

        ///////////////////////////////////////////////////
        // create form for our controls
        var form = document.createElement('form');

        var fieldset; // var to receive the constructed field sets

        ///////////////////////////////////////////////////
        // options group
        fieldset = makeFieldSet('Player');
        addCheckbox(fieldset, 'autoplay', function(on) { pacman.ai = on; });
        addCheckbox(fieldset, 'invincible', function(on) { pacman.invincible = on; });
        addCheckbox(fieldset, 'double speed', function(on) { pacman.doubleSpeed = on; });
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // machine speed group
        var changeRate = function(n) {
            game.pause();
            game.setUpdatesPerSecond(n);
            game.resume();
        };
        fieldset = makeFieldSet('Machine Speed');
        addRadio(fieldset, 'playback', 'pause', function(on) { if(on) game.pause(); });
        addRadio(fieldset, 'playback', 'quarter', function(on) { if(on) changeRate(15); });
        addRadio(fieldset, 'playback', 'half', function(on) { if(on) changeRate(30); });
        addRadio(fieldset, 'playback', 'normal', function(on) { if(on) changeRate(60); },true);
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // renderers group
        fieldset = makeFieldSet('Renderer');
        var makeSwitchRenderer = function(renderer) {
            return function(on) {
                if (on) {
                    game.switchState(fadeRendererState(game.state, renderer, 24));
                }
            };
        };
        addRadio(fieldset, 'render', 'minimal',         makeSwitchRenderer(0));
        addRadio(fieldset, 'render', 'arcade', makeSwitchRenderer(1),true);
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // draw target sights group
        fieldset = makeFieldSet('Draw Target Sights');
        addCheckbox(fieldset, 'blinky (red)', function(on) { blinky.isDrawTarget = on; });
        addCheckbox(fieldset, 'pinky (pink)', function(on) { pinky.isDrawTarget = on; });
        addCheckbox(fieldset, 'inky (cyan)', function(on) { inky.isDrawTarget = on; });
        addCheckbox(fieldset, 'clyde (orange)', function(on) { clyde.isDrawTarget = on; });
        addCheckbox(fieldset, 'pacman (yellow)', function(on) { pacman.isDrawTarget = on; });
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // maps group
        fieldset = makeFieldSet('Maps');
        var makeSwitchMap = function(map) {
            return function(on) {
                if (on) {
                    readyNewState.nextMap = map;
                    game.switchState(readyNewState, 60);
                }
            };
        };
        addRadio(fieldset, 'map', 'Pac-Man',       makeSwitchMap(MAP_PACMAN),true);
        addRadio(fieldset, 'map', 'Ms. Pac-Man 1', makeSwitchMap(MAP_MSPACMAN1));
        addRadio(fieldset, 'map', 'Ms. Pac-Man 2', makeSwitchMap(MAP_MSPACMAN2));
        addRadio(fieldset, 'map', 'Ms. Pac-Man 3', makeSwitchMap(MAP_MSPACMAN3));
        addRadio(fieldset, 'map', 'Ms. Pac-Man 4', makeSwitchMap(MAP_MSPACMAN4));
        form.appendChild(fieldset);

        // add control from to our div
        controlDiv.appendChild(form);
    };

    var addInput = function() {
        // handle key press event
        document.onkeydown = function(e) {
            var key = (e||window.event).keyCode;
            switch (key) {
                // steer pac-man
                case 37: pacman.setNextDir(DIR_LEFT); break;
                case 38: pacman.setNextDir(DIR_UP); break;
                case 39: pacman.setNextDir(DIR_RIGHT); break;
                case 40: pacman.setNextDir(DIR_DOWN); break;
                default: return;
            }
            // prevent default action for arrow keys
            // (don't scroll page with arrow keys)
            e.preventDefault();
        };
    };

    return {
        create: function() {
            // create foreground and background canvases
            canvas = makeCanvas();
            bgCanvas = makeCanvas();
            ctx = canvas.getContext("2d");
            bgCtx = bgCanvas.getContext("2d");

            // add canvas and controls to our div
            divContainer = document.getElementById('pacman');
            divContainer.appendChild(canvas);
            addControls();
            addInput();

            // add our screen.onClick event to canvas
            var that = this;
            canvas.onmousedown = function() {
                if (that.onClick)
                    that.onClick();
            };

            // create renderers
            this.renderers = [
                new renderers.Simple(ctx, bgCtx),
                new renderers.Arcade(ctx, bgCtx),
            ];

            // set current renderer
            this.renderer = this.renderers[1];
        },

        // switch to the given renderer index
        switchRenderer: function(i) {
            this.renderer = this.renderers[i];
            this.renderer.drawMap();
        },

        // copy background canvas to the foreground canvas
        blitMap: function() {
            if (smoothScale) ctx.scale(1/scale,1/scale);
            ctx.drawImage(bgCanvas,0,0);
            if (smoothScale) ctx.scale(scale,scale);
        },
    };
})();

