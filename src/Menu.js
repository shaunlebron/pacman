
// REFERENCED GLOBALS:
// import { tileSize } from './Map.js';
// import { ToggleButton, Button } from './Button.js';

const Menu = function(title,x,y,w,h,pad,font,fontcolor) {
    this.title = title;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.pad = pad;
    this.buttons = [];
    this.buttonCount = 0;
    this.currentY = this.y+this.pad;

    if (title) {
        this.currentY += 1*(this.h + this.pad);
    }

    this.font = font;
    this.fontcolor = fontcolor;
    this.enabled = false;

    this.backButton = undefined;
};

Menu.prototype = {

    clickCurrentOption: function() {
        for (let i=0; i<this.buttonCount; i++) {
            if (this.buttons[i].isSelected) {
                this.buttons[i].onclick();
                break;
            }
        }
    },

    selectNextOption: function() {
        let nextBtn;
        for (let i=0; i<this.buttonCount; i++) {
            if (this.buttons[i].isSelected) {
                this.buttons[i].blur();
                nextBtn = this.buttons[(i+1)%this.buttonCount];
                break;
            }
        }
        nextBtn = nextBtn || this.buttons[0];
        nextBtn.focus();
    },

    selectPrevOption: function() {
        let nextBtn;
        for (let i=0; i<this.buttonCount; i++) {
            if (this.buttons[i].isSelected) {
                this.buttons[i].blur();
                nextBtn = this.buttons[i==0?this.buttonCount-1:i-1];
                break;
            }
        }
        nextBtn = nextBtn || this.buttons[this.buttonCount-1];
        nextBtn.focus();
    },

    addToggleButton: function(isOn,setOn) {
        const b = new ToggleButton(this.x+this.pad,this.currentY,this.w-this.pad*2,this.h,isOn,setOn);
        this.buttons.push(b);
        this.buttonCount++;
        this.currentY += this.pad + this.h;
    },

    addToggleTextButton: function(label,isOn,setOn) {
        const b = new ToggleButton(this.x+this.pad,this.currentY,this.w-this.pad*2,this.h,isOn,setOn);
        b.setFont(this.font,this.fontcolor);
        b.setToggleLabel(label);
        this.buttons.push(b);
        this.buttonCount++;
        this.currentY += this.pad + this.h;
    },

    addTextButton: function(msg,onclick) {
        const b = new Button(this.x+this.pad,this.currentY,this.w-this.pad*2,this.h,onclick);
        b.setFont(this.font,this.fontcolor);
        b.setText(msg);
        this.buttons.push(b);
        this.buttonCount++;
        this.currentY += this.pad + this.h;
    },

    addTextIconButton: function(msg,onclick,drawIcon) {
        const b = new Button(this.x+this.pad,this.currentY,this.w-this.pad*2,this.h,onclick);
        b.setFont(this.font,this.fontcolor);
        b.setText(msg);
        b.setIcon(drawIcon);
        this.buttons.push(b);
        this.buttonCount++;
        this.currentY += this.pad + this.h;
    },

    addIconButton: function(drawIcon,onclick) {
        const b = new Button(this.x+this.pad,this.currentY,this.w-this.pad*2,this.h,onclick);
        b.setIcon(drawIcon);
        this.buttons.push(b);
        this.buttonCount++;
        this.currentY += this.pad + this.h;
    },

    addSpacer: function(count) {
        if (count == undefined) {
            count = 1;
        }
        this.currentY += count*(this.pad + this.h);
    },

    enable: function() {
        for (let i=0; i<this.buttonCount; i++) {
            this.buttons[i].enable();
        }
        this.enabled = true;
    },

    disable: function() {
        for (let i=0; i<this.buttonCount; i++) {
            this.buttons[i].disable();
        }
        this.enabled = false;
    },

    isEnabled: function() {
        return this.enabled;
    },

    draw: function(ctx) {
        if (this.title) {
            ctx.font = tileSize+"px ArcadeR";
            ctx.textBaseline = "middle";
            ctx.textAlign = "center";
            ctx.fillStyle = "#FFF";
            ctx.fillText(this.title,this.x + this.w/2, this.y+this.pad + this.h/2);
        }
        for (let i=0; i<this.buttonCount; i++) {
            this.buttons[i].draw(ctx);
        }
    },

    update: function() {
        for (let i=0; i<this.buttonCount; i++) {
            this.buttons[i].update();
        }
    },
};
