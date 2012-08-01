var getmousepos = function(evt) {
    var obj = canvas;
    var top = 0;
    var left = 0;
    while (obj.tagName != 'BODY') {
        top += obj.offsetTop;
        left += obj.offsetLeft;
        obj = obj.offsetParent;
    }

    // calculate relative mouse position
    var mouseX = evt.clientX - left + window.pageXOffset;
    var mouseY = evt.clientY - top + window.pageYOffset;

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
    this.borderColor = this.borderBlurColor;

    var that = this;
    var click = function(evt) {
        var pos = getmousepos(evt);
        if (that.onclick && that.contains(pos.x, pos.y)) {
            that.onclick();
        }
    };
    var mousemove = function(evt) {
        var pos = getmousepos(evt);
        that.contains(pos.x, pos.y) ? that.focus() : that.blur();
    };
    var mouseleave = function(evt) {
        that.blur();
    };

    this.enable = function() {
        canvas.addEventListener('click', click);
        canvas.addEventListener('mousemove', mousemove);
        canvas.addEventListener('mouseleave', mouseleave);
    };

    this.disable = function() {
        canvas.removeEventListener('click', click);
        canvas.removeEventListener('mousemove', mousemove);
        canvas.removeEventListener('mouseleave', mouseleave);
    };
};

Button.prototype = {

    contains: function(x,y) {
        return x >= this.x && x <= this.x+this.w &&
               y >= this.y && y <= this.y+this.h;
    },

    focus: function() {
        this.borderColor = this.borderFocusColor;
    },

    blur: function() {
        this.borderColor = this.borderBlurColor;
    },

    draw: function(ctx) {
        ctx.fillStyle = "#000";
        ctx.fillRect(this.x,this.y,this.w,this.h);
        ctx.strokeStyle = this.borderColor;
        ctx.strokeRect(this.x,this.y,this.w,this.h);
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
        ctx.fillStyle = this.fontcolor;
        ctx.textBaseline = "middle";
        ctx.fillText(this.msg, this.pad+this.x, this.y + this.h/2);
    },
};
