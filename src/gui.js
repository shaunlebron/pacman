//////////////////////////////////////////////////////////////////////////////////////
// GUI
// (controls the display and input)

var gui = (function() {

    // html elements
    var divContainer;

    // add interative options to tune the game
    var addControls = (function() {

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

        // create a text label
        var makeLabel = function(caption) {
            var label;
            label = document.createElement('label');
            label.style.padding = "3px";
            label.appendChild(document.createTextNode(caption));
            return label;
        };

        // add a range slider
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

            var label = makeLabel(''+value+suffix);
            slider.onchange = function() {
                if (onChange)
                    onChange(this.value);
                label.innerHTML = ''+this.value+suffix;
            };
            fieldset.appendChild(label);
            fieldset.appendChild(document.createElement('br'));
        };

        var makeDropDownOption = function(caption) {
            var option = document.createElement('option');
            option.appendChild(document.createTextNode(caption));
            return option;
        };

        return function() {
            var controlDiv = document.getElementById("pacman-controls");
            if (!controlDiv)
                return;

            // create form for our controls
            var form = document.createElement('form');

            // options group
            var fieldset = makeFieldSet('Player');
            addCheckbox(fieldset, 'autoplay', function(on) { pacman.ai = on; }, pacman.ai);
            addCheckbox(fieldset, 'invincible', function(on) { pacman.invincible = on; }, pacman.invincible);
            addCheckbox(fieldset, 'turbo', function(on) { pacman.doubleSpeed = on; }, pacman.doubleSpeed);
            form.appendChild(fieldset);

            // machine speed group
            fieldset = makeFieldSet('Machine Speed');
            addSlider(fieldset, '%', 100, 0, 200, 5, function(value) { executive.setUpdatesPerSecond(60*value/100); });
            form.appendChild(fieldset);

            // renderers group
            fieldset = makeFieldSet('Renderer');
            var makeSwitchRenderer = function(i) { return function(on) { if (on) switchRenderer(i); }; };
            var i,r;
            for (i=0; i<renderer_list.length; i++) {
                r = renderer_list[i];
                addRadio(fieldset, 'render', r.name, makeSwitchRenderer(i), r == renderer, true);
            }
            form.appendChild(fieldset);

            // draw actor behavior
            fieldset = makeFieldSet('Behavior');

            // logic
            var makeToggleTarget = function(a) { return function(on) { a.isDrawTarget = on; }; };
            var a;
            for (i=0; i<actors.length; i++) {
                a = actors[i];
                addCheckbox(fieldset, '', makeToggleTarget(a), a.isDrawTarget, '4px solid ' + a.color, true);
            }
            fieldset.appendChild(makeLabel('Logic '));
            fieldset.appendChild(document.createElement('br'));

            // path
            var makeTogglePath = function(a) { return function(on) { a.isDrawPath = on; }; };
            for (i=0; i<actors.length; i++) {
                a = actors[i];
                addCheckbox(fieldset, '', makeTogglePath(a), a.isDrawPath, '4px solid ' + a.color, true);
            }
            fieldset.appendChild(makeLabel('Path '));
            fieldset.appendChild(document.createElement('br'));

            // path length
            addSlider(fieldset, ' tile path', actorPathLength, 1, 50, 1, function(x) { actorPathLength = x; });
            form.appendChild(fieldset);

            // add control from to our div
            controlDiv.appendChild(form);
        };
    })();

    return {
        create: function() {

            // add canvas and controls to our div
            divContainer = document.getElementById('pacman');
            divContainer.appendChild(canvas);
            addControls();
            //var atlasCanvas = atlas.getCanvas();
            //atlasCanvas.style.background = "#000";
            //divContainer.appendChild(atlasCanvas);
        },
    };
})();

