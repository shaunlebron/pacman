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
            var legend = document.createElement('legend');
            legend.appendChild(document.createTextNode(title));
            fieldset.appendChild(legend);
            return fieldset;
        };

        // add a checkbox
        var addCheckbox = function(fieldset, caption, onChange, on, outline, sameline) {
            id++;
            var checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.id = 'check'+id;
            checkbox.checked = on;
            checkbox.onchange = function() { onChange(checkbox.checked); };
            fieldset.appendChild(checkbox);

            if (caption) {
                label = document.createElement('label');
                label.htmlFor = 'check'+id;
                label.appendChild(document.createTextNode(caption));
                fieldset.appendChild(label);
            }

            if (outline) {
                checkbox.style.outline = outline;
                checkbox.style.margin = "5px";
            }
            if (!sameline)
                fieldset.appendChild(document.createElement('br'));
        };

        // add a radio button
        var addRadio = function(fieldset, group, caption, onChange, on, sameline) {
            id++;
            var radio = document.createElement('input');
            radio.type = 'radio';
            radio.name = group;
            radio.id = 'radio'+id;
            radio.checked = on;
            radio.onchange = function() { onChange(radio.checked); };
            fieldset.appendChild(radio);

            if (caption) {
                label = document.createElement('label');
                label.htmlFor = 'radio'+id;
                label.appendChild(document.createTextNode(caption));
                fieldset.appendChild(label);
            }

            if (!sameline)
                fieldset.appendChild(document.createElement('br'));
        };

        var makeLabel = function(caption) {
            var label;
            label = document.createElement('label');
            label.style.padding = "3px";
            label.appendChild(document.createTextNode(caption));
            return label;
        };

        var addSlider = function(fieldset, suffix, value, min, max, step, onChange) {
            id++;
            var slider = document.createElement('input');
            slider.type = 'range';
            slider.id = 'range'+id;
            slider.value = value;
            slider.min = min;
            slider.max = max;
            slider.step = step;
            fieldset.appendChild(slider);
            fieldset.appendChild(document.createElement('br'));
            /*
            var div = document.createElement('div');
            div.innerHTML = '<input id="range' + id +'" type="range" value="' + value + '" min="' + min + '" max="' + max + '" step="' + step + '">';
            fieldset.appendChild(div);
            */

            var label;

            label = makeLabel(''+value+suffix);
            slider.onchange = function() {
                if (onChange)
                    onChange(this.value);
                label.innerHTML = ''+this.value+suffix;
            };
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
        addSlider(fieldset, '%', 100, 0, 200, 20, function(value) {
            if (value == 0)
                game.pause();
            else
                changeRate(60*value/100);
        });
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
        addRadio(fieldset, 'render', 'minimal', makeSwitchRenderer(0), false, true);
        addRadio(fieldset, 'render', 'arcade', makeSwitchRenderer(1),true);
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // draw actor targets group
        fieldset = makeFieldSet('Behavior');
        addCheckbox(fieldset, '', function(on) { blinky.isDrawTarget = on; }, false, '4px solid ' + blinky.color, true);
        addCheckbox(fieldset, '', function(on) { pinky.isDrawTarget = on; },  false, '4px solid ' + pinky.color, true);
        addCheckbox(fieldset, '', function(on) { inky.isDrawTarget = on; },   false, '4px solid ' + inky.color, true);
        addCheckbox(fieldset, '', function(on) { clyde.isDrawTarget = on; },  false, '4px solid ' + clyde.color, true);
        addCheckbox(fieldset, '', function(on) { pacman.isDrawTarget = on; }, false, '4px solid ' + pacman.color, true);
        fieldset.appendChild(makeLabel('Logic '));

        fieldset.appendChild(document.createElement('br'));

        addCheckbox(fieldset, '', function(on) { blinky.isDrawPath = on; }, false, '4px solid ' + blinky.color, true);
        addCheckbox(fieldset, '', function(on) { pinky.isDrawPath = on; },  false, '4px solid ' + pinky.color, true);
        addCheckbox(fieldset, '', function(on) { inky.isDrawPath = on; },   false, '4px solid ' + inky.color, true);
        addCheckbox(fieldset, '', function(on) { clyde.isDrawPath = on; },  false, '4px solid ' + clyde.color, true);
        addCheckbox(fieldset, '', function(on) { pacman.isDrawPath = on; }, false, '4px solid ' + pacman.color, true);
        fieldset.appendChild(makeLabel('Path '));

        fieldset.appendChild(document.createElement('br'));

        addSlider(fieldset, ' tile path', actorPathLength, 8, 64, 8, function(value) {
            actorPathLength = value;
        });

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

