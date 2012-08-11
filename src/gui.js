var getPointerPos = function(evt) {
    var obj = canvas;
    var top = 0;
    var left = 0;
    while (obj.tagName != 'BODY') {
        top += obj.offsetTop;
        left += obj.offsetLeft;
        obj = obj.offsetParent;
    }

    // calculate relative mouse position
    var mouseX = evt.pageX - left;
    var mouseY = evt.pageY - top;

    // make independent of scale
    mouseX /= renderScale;
    mouseY /= renderScale;

    // offset
    mouseX -= mapMargin;
    mouseY -= mapMargin;

    return { x: mouseX, y: mouseY };
};

var ComboBox = function(x,y,w,h,options) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;

    this.options = options;

    this.enable = function() {
    };

    this.disable = function() {
    };
};

ComboBox.prototype = {

    draw: function(ctx) {
    },

};

var Button = function(x,y,w,h,onclick) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.onclick = onclick;

    this.borderBlurColor = "#555";
    this.borderFocusColor = "#EEE";

    this.isHover = false;

    // touch events
    this.startedInside = false;
    var that = this;
    var touchstart = function(evt) {
        evt.preventDefault();
        var fingerCount = evt.touches.length;
        if (fingerCount == 1) {
            var pos = getPointerPos(evt.touches[0]);
            (that.startedInside=that.contains(pos.x,pos.y)) ? that.focus() : that.blur();
        }
        else {
            touchcancel(evt);
        }
    };
    var touchmove = function(evt) {
        evt.preventDefault();
        var fingerCount = evt.touches.length;
        if (fingerCount == 1) {
            if (that.startedInside) {
                var pos = getPointerPos(evt.touches[0]);
                that.contains(pos.x, pos.y) ? that.focus() : that.blur();
            }
        }
        else {
            touchcancel(evt);
        }
    };
    var touchend = function(evt) {
        evt.preventDefault();
        if (that.onclick && that.startedInside && that.isHover) {
            that.onclick();
        }
        touchcancel(evt);
    };
    var touchcancel = function(evt) {
        evt.preventDefault();
        this.startedInside = false;
        that.blur();
    };


    // mouse events
    var click = function(evt) {
        var pos = getPointerPos(evt);
        if (that.onclick && that.contains(pos.x, pos.y)) {
            that.onclick();
        }
    };
    var mousemove = function(evt) {
        var pos = getPointerPos(evt);
        that.contains(pos.x, pos.y) ? that.focus() : that.blur();
    };
    var mouseleave = function(evt) {
        that.blur();
    };

    this.isEnabled = false;
    this.enable = function() {
        canvas.addEventListener('click', click);
        canvas.addEventListener('mousemove', mousemove);
        canvas.addEventListener('mouseleave', mouseleave);
        canvas.addEventListener('touchstart', touchstart);
        canvas.addEventListener('touchmove', touchmove);
        canvas.addEventListener('touchend', touchend);
        canvas.addEventListener('touchcancel', touchcancel);
        this.isEnabled = true;
    };

    this.disable = function() {
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

    focus: function() {
        this.isHover = true;
    },

    blur: function() {
        this.isHover = false;
    },

    draw: function(ctx) {
        ctx.lineWidth = 2;
        ctx.beginPath();
        var x=this.x, y=this.y, w=this.w, h=this.h;
        var r=h/4;
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
        ctx.strokeStyle = this.isHover && this.onclick ? this.borderFocusColor : this.borderBlurColor;
        ctx.stroke();

    },

    update: function() {
    },
};

var TextButton = function(x,y,w,h,onclick,msg,font,fontcolor) {
    Button.call(this,x,y,w,h,onclick);
    this.msg = msg;
    this.font = font;
    this.fontcolor = fontcolor;
    this.pad = tileSize;
};

TextButton.prototype = {

    __proto__: Button.prototype,

    draw: function(ctx) {
        Button.prototype.draw.call(this,ctx);
        ctx.font = this.font;
        ctx.fillStyle = this.isHover && this.onclick ? this.fontcolor : "#777";
        ctx.textBaseline = "middle";
        ctx.textAlign = "center";
        //ctx.fillText(this.msg, 2*tileSize+2*this.pad+this.x, this.y + this.h/2 + 1);
        ctx.fillText(this.msg, this.x + this.w/2, this.y + this.h/2 + 1);

    },
};

var TextIconButton = function(x,y,w,h,onclick,msg,font,fontcolor,drawIcon) {
    TextButton.call(this,x,y,w,h,onclick,msg,font,fontcolor);
    this.drawIcon = drawIcon;
    this.frame = 0;
};

TextIconButton.prototype = {

    __proto__: TextButton.prototype,

    draw: function(ctx) {
        TextButton.prototype.draw.call(this,ctx);
        this.drawIcon(ctx,this.x+this.pad+tileSize,this.y+this.h/2,this.frame);
    },

    update: function() {
        TextButton.prototype.update.call(this);
        this.frame = this.isHover ? this.frame+1 : 0;
    },
};
