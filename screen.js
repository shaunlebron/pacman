//////////////////////////////////////////////////////////////////////////////////////
// Screen

var screen = (function() {

    // html elements
    var divContainer;
    var canvas, ctx;
    var bgCanvas, bgCtx;

    // drawing scale
    var scale = 2;

    var makeCanvas = function() {
        var c = document.createElement("canvas");

        // use conventional pacman map size
        c.width = 28*tileSize*scale;
        c.height = 36*tileSize*scale;

        c.getContext("2d").scale(scale,scale);
        return c;
    };

    var addControls = function() {

        // used for making html elements with unique id's
        var id = 0;

        var makeFieldSet = function(title) {
            var fieldset = document.createElement('fieldset');
            var legend = document.createElement('legend');
            legend.appendChild(document.createTextNode(title));
            fieldset.appendChild(legend);
            return fieldset;
        };

        var addCheckbox = function(fieldset, caption, onChange) {
            id++;
            var checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.id = 'check'+id;
            checkbox.onchange = function() { onChange(checkbox.checked); };
            fieldset.appendChild(checkbox);

            label = document.createElement('label');
            label.htmlFor = 'check'+id;
            label.appendChild(document.createTextNode(caption));
            fieldset.appendChild(label);

            fieldset.appendChild(document.createElement('br'));
        };


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


        var form = document.createElement('form');
        form.style.width = 200;
        form.style.cssFloat = "left";

        var fieldset;

        ///////////////////////////////////////////////////
        // options
        fieldset = makeFieldSet('Options');
        addCheckbox(fieldset, 'autoplay', function(on) { pacman.ai = on; });
        addCheckbox(fieldset, 'invincible', function(on) { pacman.invincible = on; });
        addCheckbox(fieldset, 'speed hack', function(on) { pacman.speedHack = on; });
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // renderers
        fieldset = makeFieldSet('Renderer');
        var makeSwitchRenderer = function(renderer) {
            return function(on) {
                if (on) {
                    game.switchState(fadeRendererState(game.state, renderer, 24));
                }
            };
        };
        addRadio(fieldset, 'render', 'minimal',         makeSwitchRenderer(0), true);
        addRadio(fieldset, 'render', 'arcade (w.i.p.)', makeSwitchRenderer(1));
        form.appendChild(fieldset);

        ///////////////////////////////////////////////////
        // maps
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

        divContainer.appendChild(form);

        var br = document.createElement('br');
        br.style.clear = "both";
        divContainer.appendChild(br);
    };

    var addInput = function() {
        // handle key press event
        document.onkeydown = function(e) {
            var key = (e||window.event).keyCode;
            switch (key) {
                case 37: pacman.setNextDir(DIR_LEFT); break; // left
                case 38: pacman.setNextDir(DIR_UP); break; // up
                case 39: pacman.setNextDir(DIR_RIGHT); break; // right
                case 40: pacman.setNextDir(DIR_DOWN); break;// down
                default: return;
            }
            e.preventDefault();
        };
    };

    return {
        create: function() {
            canvas = makeCanvas();
            bgCanvas = makeCanvas();
            ctx = canvas.getContext("2d");
            bgCtx = bgCanvas.getContext("2d");
            canvas.style.cssFloat = "left";

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
            this.renderer = this.renderers[0];
        },
        switchRenderer: function(i) {
            this.renderer = this.renderers[i];
            this.renderer.drawMap();
        },

        blitMap: function() {
            ctx.scale(1/scale,1/scale);
            ctx.drawImage(bgCanvas,0,0);
            ctx.scale(scale,scale);
        },
    };
})();

