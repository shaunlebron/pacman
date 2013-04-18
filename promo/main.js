// from: http://www.colourlovers.com/color/6BABF4/Pale_BluePurple
var backColor = "#6BABF4";

var canvas,ctx;
var w = 1280;
var h = 720;

var last_tick_t = 0;
var time = 0;

function LinearInterp(min,max,duration) {
	this.min = min;
	this.max = max;
	this.duration = duration;
	this.time = 0;
	this.value = min;
}

LinearInterp.prototype = {
	update: function(dt) {
		this.time += dt;
		this.time = Math.min(this.duration, this.time);
		this.value = this.time / this.duration * (this.max-this.min) + this.min;
	},
};

function fillCirc(x,y,r,color) {
	ctx.beginPath();
	ctx.arc(x,y,r,0,Math.PI*2);
	ctx.fillStyle = color;
	ctx.fill();
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// SUNS

var maxr = 240;
var duration = 3000;
var sunSuns = [];
var numSuns = 4;

function createSuns() {
	var i;
	for (i=0; i<numSuns; i++) {
		sunSuns[i] = new LinearInterp(0,maxr,duration);
	}
}
function updateSuns(dt) {
	var timeStep = duration/numSuns;
	var i;
	for (i=0; i<numSuns; i++) {
		if (time > i*timeStep) {
			sunSuns[i].update(dt);
		}
	}
}

function drawSuns() {
	var i;
	for (i=0; i<numSuns; i++) {
		fillCirc(w/2,h/2,sunSuns[i].value,backColor);
		fillCirc(w/2,h/2,sunSuns[i].value,"rgba(255,255,0,"+(i+1)/numSuns+")");
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Clouds

function Cloud() {
	this.angles = [
		Math.random()*Math.PI*2,
		Math.random()*Math.PI*2,
		Math.random()*Math.PI*2,
		Math.random()*Math.PI*2,
		Math.random()*Math.PI*2,
	];
	this.x = 0;
	this.y = 0;
}

Cloud.prototype = {
	update: function(dt) {
		var i;
		for (i=0; i<5; i++) {
			this.angles[i] += Math.PI*2/3000 * dt;
			this.angles[i] %= (Math.PI*2);
		}
	},
	drawCloud: function(x,y,r,i,color) {
		var ar = 3;
		var a = this.angles[i];
		y += Math.sin(a) * ar;
		fillCirc(x,y,r,color);
	},
	setPos: function(x,y) {
		this.x = x;
		this.y = y;
	},
	draw: function() {
		var r = 80;
		var w = r*5;
		var h = 200;
		ctx.save();
		var y = this.y + Math.sin(this.angles[4]) * 3;
		ctx.translate(this.x,y);
		ctx.beginPath();
		var pad = 5;
		ctx.rect(-pad,-pad,w+pad*2,h+pad*2);
		ctx.clip();

		var r2 = r + 8;
		var color = "#DDD";
		this.drawCloud(r,h,r2,0,color)
		this.drawCloud(2*r,h-0.8*r,r2,1,color);
		this.drawCloud(3*r,h-r,r2,2,color);
		this.drawCloud(4*r,h,r2,3,color);

		var r2 = r;
		var color = "#FFF";
		this.drawCloud(r,h,r2,0,color)
		this.drawCloud(2*r,h-0.8*r,r2,1,color);
		this.drawCloud(3*r,h-r,r2,2,color);
		this.drawCloud(4*r,h,r2,3,color);

		fillCirc(2.5*r,h,1.5*r,"#FFF");

		ctx.restore();
	},
};

var clouds = [
	new Cloud(),
	new Cloud(),
	new Cloud(),
];
var cloudTargetX = [
	-100,
	1100,
	800,
];

var numClouds = 3;

function initClouds() {
	clouds[0].setPos(-w,50);
	clouds[1].setPos(w,200);
	clouds[2].setPos(w,500);
}

function updateClouds(dt) {
	var i;
	for (i=0; i<numClouds; i++) {
		clouds[i].update(dt);
	}
	
	var timeStep = 3000/4;
	var timeStart = 3500;
	var k = 0.1;
	if (time > timeStart) {
		clouds[0].x += (cloudTargetX[0] - clouds[0].x) * k;
	}
	if (time > timeStart + timeStep) {
		clouds[1].x += (cloudTargetX[1] - clouds[1].x) * k;
	}
	if (time > timeStart + timeStep*2) {
		clouds[2].x += (cloudTargetX[2] - clouds[2].x) * k;
	}
}

function drawClouds() {
	for (i=0; i<numClouds; i++) {
		clouds[i].draw();
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////

function tick(t) {
	var dt;
	if (!last_tick_t) {
		dt = 0;
	}
	else {
		dt = t - last_tick_t;
	}
	last_tick_t = t;

	ctx.fillStyle = backColor;
	ctx.fillRect(0,0,w,h);

	updateSuns(dt);
	drawSuns();

	updateClouds(dt);
	drawClouds();


	time += dt;
	window.mozRequestAnimationFrame(tick);
}

function playSong() {
	var song = new Audio();
	song.src = "philipp.ogg";
	song.play();
}

window.addEventListener("load", function() {
	canvas = document.getElementById('canvas');
	ctx = canvas.getContext('2d');
	createSuns();
	initClouds();
	playSong();
	window.mozRequestAnimationFrame(tick);
});
