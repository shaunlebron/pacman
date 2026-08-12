
// REFERENCED GLOBALS:
// import { tileSize } from './Map.js';
// import { newChildObject } from './inherit.js';
// import { canvas, renderScale, getDevicePixelRatio, mapMargin } from './renderers.js';

const getPointerPos = function(evt) {
    let obj = canvas;
    let top = 0;
    let left = 0;
    while (obj.tagName != 'BODY') {
        top += obj.offsetTop;
        left += obj.offsetLeft;
        obj = obj.offsetParent;
    }

    // calculate relative mouse position
    let mouseX = evt.pageX - left;
    let mouseY = evt.pageY - top;

    // make independent of scale
    const ratio = getDevicePixelRatio();
    mouseX /= (renderScale / ratio);
    mouseY /= (renderScale / ratio);

    // offset
    mouseX -= mapMargin;
    mouseY -= mapMargin;

    return { x: mouseX, y: mouseY };
};

const Button = function(x,y,w,h,onclick) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.onclick = onclick;

    // text and icon padding
    this.pad = tileSize;



    // icon attributes
    this.frame = 0;

    this.borderBlurColor = "#333";
    this.borderFocusColor = "#EEE";

    this.isSelected = false;

    // touch events
    this.startedInside = false;
    const that = this;
    const touchstart = function(evt) {
        evt.preventDefault();
        const fingerCount = evt.touches.length;
        if (fingerCount == 1) {
            const pos = getPointerPos(evt.touches[0]);
            (that.startedInside=that.contains(pos.x,pos.y)) ? that.focus() : that.blur();
        }
        else {
            touchcancel(evt);
        }
    };
    const touchmove = function(evt) {
        evt.preventDefault();
        const fingerCount = evt.touches.length;
        if (fingerCount == 1) {
            if (that.startedInside) {
                const pos = getPointerPos(evt.touches[0]);
                that.contains(pos.x, pos.y) ? that.focus() : that.blur();
            }
        }
        else {
            touchcancel(evt);
        }
    };
    const touchend = function(evt) {
        evt.preventDefault();
        const registerClick = (that.startedInside && that.isSelected);
        if (registerClick) {
            that.click();
        }
        touchcancel(evt);
        if (registerClick) {
            // focus the button to keep it highlighted after successful click
            that.focus();
        }
    };
    const touchcancel = function(evt) {
        evt.preventDefault();
        this.startedInside = false;
        that.blur();
    };


    // mouse events
    const click = function(evt) {
        const pos = getPointerPos(evt);
        if (that.contains(pos.x, pos.y)) {
            that.click();
        }
    };
    const mousemove = function(evt) {
        const pos = getPointerPos(evt);
        that.contains(pos.x, pos.y) ? that.focus() : that.blur();
    };
    const mouseleave = function(evt) {
        that.blur();
    };

    this.isEnabled = false;
    this.onEnable = function() {
        canvas.addEventListener('click', click);
        canvas.addEventListener('mousemove', mousemove);
        canvas.addEventListener('mouseleave', mouseleave);
        canvas.addEventListener('touchstart', touchstart);
        canvas.addEventListener('touchmove', touchmove);
        canvas.addEventListener('touchend', touchend);
        canvas.addEventListener('touchcancel', touchcancel);
        this.isEnabled = true;
    };

    this.onDisable = function() {
        canvas.removeEventListener('click', click);
        canvas.removeEventListener('mousemove', mousemove);
        canvas.removeEventListener('mouseleave', mouseleave);
        canvas.removeEventListener('touchstart', touchstart);
        canvas.removeEventListener('touchmove', touchmove);
        canvas.removeEventListener('touchend', touchend);
        canvas.removeEventListener('touchcancel', touchcancel);
        that.blur();
        this.isEnabled = false;
    };
};

Button.prototype = {

    contains: function(x,y) {
        return x >= this.x && x <= this.x+this.w &&
               y >= this.y && y <= this.y+this.h;
    },

    click: function() {
        // disable current click timeout (to prevent double clicks on some devices)
        clearTimeout(this.clickTimeout);

        // set a click delay
        const that = this;
        if (that.onclick) {
            this.clickTimeout = setTimeout(function() { that.onclick(); }, 200);
        }
    },

    enable: function() {
        this.frame = 0;
        this.onEnable();
    },

    disable: function() {
        this.onDisable();
    },

    focus: function() {
        this.isSelected = true;
        this.onfocus && this.onfocus();
    },

    blur: function() {
        this.isSelected = false;
        this.onblur && this.onblur();
    },

    setText: function(msg) {
        this.msg = msg;
    },

    setFont: function(font,fontcolor) {
        this.font = font;
        this.fontcolor = fontcolor;
    },

    setIcon: function(drawIcon) {
        this.drawIcon = drawIcon;
    },

    draw: function(ctx) {

        // draw border
        ctx.lineWidth = 2;
        ctx.beginPath();
        const {x,y,w,h} = this;
        const r=h/4;
        ctx.moveTo(x,y+r);
        ctx.quadraticCurveTo(x,y,x+r,y);
        ctx.lineTo(x+w-r,y);
        ctx.quadraticCurveTo(x+w,y,x+w,y+r);
        ctx.lineTo(x+w,y+h-r);
        ctx.quadraticCurveTo(x+w,y+h,x+w-r,y+h);
        ctx.lineTo(x+r,y+h);
        ctx.quadraticCurveTo(x,y+h,x,y+h-r);
        ctx.closePath();
        ctx.fillStyle = "rgba(0,0,0,0.5)";
        ctx.fill();
        ctx.strokeStyle = this.isSelected && this.onclick ? this.borderFocusColor : this.borderBlurColor;
        ctx.stroke();

        // draw icon
        if (this.drawIcon) {
            if (!this.msg) {
                this.drawIcon(ctx,this.x+this.w/2,this.y+this.h/2,this.frame);
            }
            else {
                this.drawIcon(ctx,this.x+this.pad+tileSize,this.y+this.h/2,this.frame);
            }
        }

        // draw text
        if (this.msg) {
            ctx.font = this.font;
            ctx.fillStyle = this.isSelected && this.onclick ? this.fontcolor : "#777";
            ctx.textBaseline = "middle";
            ctx.textAlign = "center";
            //ctx.fillText(this.msg, 2*tileSize+2*this.pad+this.x, this.y + this.h/2 + 1);
            ctx.fillText(this.msg, this.x + this.w/2, this.y + this.h/2 + 1);
        }
    },

    update: function() {
        if (this.drawIcon) {
            this.frame = this.isSelected ? this.frame+1 : 0;
        }
    },
};

const ToggleButton = function(x,y,w,h,isOn,setOn) {
    const that = this;
    const onclick = function() {
        setOn(!isOn());
        that.refreshMsg();
    };
    this.isOn = isOn;
    this.setOn = setOn;
    Button.call(this,x,y,w,h,onclick);
};

ToggleButton.prototype = newChildObject(Button.prototype, {

    enable: function() {
        Button.prototype.enable.call(this);
        this.refreshMsg();
    },
    setToggleLabel: function(label) {
        this.label = label;
    },
    refreshMsg: function() {
        if (this.label) {
            this.msg = this.label + ": " + (this.isOn() ? "ON" : "OFF");
        }
    },
    refreshOnState: function() {
        this.setOn(this.isOn());
    },

});
