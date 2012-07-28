var Menu = function(x,y,w,h,pad,font,fontcolor) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.pad = pad;
    this.buttons = [];
    this.buttonCount = 0;

    this.font = font;
    this.fontcolor = fontcolor;
};

Menu.prototype = {

    addTextButton: function(msg,onclick) {
        var x = this.pad;
        var y = this.pad + (this.pad + this.h) * this.buttonCount;
        this.buttons.push(new TextButton(x,y,this.w,this.h,onclick,msg,this.font,this.fontcolor));
        this.buttonCount++;
    },

    enable: function() {
        var i;
        for (i=0; i<this.buttonCount; i++) {
            this.buttons[i].enable();
        }
    },

    disable: function() {
        var i;
        for (i=0; i<this.buttonCount; i++) {
            this.buttons[i].disable();
        }
    },

    draw: function(ctx) {
        var i;
        for (i=0; i<this.buttonCount; i++) {
            this.buttons[i].draw(ctx);
        }
    },
};
