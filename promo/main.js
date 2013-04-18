// milli-seconds per beat
var spb = 3000/4;

var pad = 20;

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

function fillSqDot(x,y,r,color) {
	if (r < 0.001) {
		return;
	}
	ctx.fillStyle = color;
	ctx.fillRect(x-r,y-r,r*2,r*2);
};

function fillCirc(x,y,r,color) {
	if (r < 0.001) {
		return;
	}
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

var dancingSuns;

function DancingSun(timesteps,radii,color) {
	this.numsteps = timesteps.length;
	this.timesteps = timesteps;
	this.radii = radii;
	this.radius = radii[0];
	this.color = color;
	this.time = 0;
};

DancingSun.prototype = {
	update: function(dt) {
		var i,tr;
		for (i=0; i<this.numsteps; i++) {
			if (this.timesteps[i] * spb > this.time) {
				break;
			}
			tr = (this.radii[i]+1)/6*240;
		}
		this.radius += (tr - this.radius) * 0.2;
		this.time += dt;
		fillCirc(w/2,h/2,this.radius,this.color);
	},
};

function createSuns() {
	var i;
	var r = maxr;
	for (i=0; i<numSuns; i++) {
		sunSuns[i] = new LinearInterp(0,i==0?(maxr+20):maxr,duration);
	}

	var color = "rgba(255,255,0,0.7)";
	dancingSuns = [
		new DancingSun(
			//[0,2,3,4,5,6,7, 8,10,11,12,13,14,15],
			[0,2,3,4,5,6,7],
			[5,4,3,2,4,0,2, 5,4,3,2,4,0,2],
			color),
		new DancingSun(
			//[0,1,2,2.5,3,3.5,4,5,6,7,7.5,   8,9,10,10.5,11,11.5,12,13,14,15,15.5],
			[0,1,2,2.5,3,3.5,4,5,6,7,7.5],
			[-1,5,4,1.5,2,2.5,3,4,5,3,4,5, -1,5,4,1.5,2,2.5,3,4,5,3,4,5],
			color),
	];
}
function updateSuns(dt) {
	if (time < spb*16) {
		var timeStep = duration/numSuns;
		var i;
		for (i=0; i<numSuns; i++) {
			if (time > i*timeStep) {
				sunSuns[i].update(dt);
			}
			fillCirc(w/2,h/2,sunSuns[i].value,backColor);
			fillCirc(w/2,h/2,sunSuns[i].value,"rgba(255,255,0,"+(i+1)/numSuns+")");
		}
		var smileStart = spb*13.5;
		var smileEnd = spb*16;
		if (time > smileStart) {
			ctx.beginPath();
			var a = Math.PI/8;
			ctx.arc(w/2,h/2,100,a,Math.PI-a);
			ctx.globalAlpha = (time - smileStart) / (smileEnd-smileStart);
			ctx.strokeStyle = "#888";
			ctx.lineWidth = 10;
			ctx.stroke();
			ctx.globalAlpha = 1;
		}
	}
	else {
		
		dancingSuns[0].update(dt);
		dancingSuns[1].update(dt);
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
		ctx.rect(-pad,-pad,w+pad*2,h+pad*2);
		ctx.clip();

		var r2 = r + pad;
		var color = "rgba(255,255,255,0.2)";
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
	clouds[1].setPos(2*w,200);
	clouds[2].setPos(2*w,500);
}

cloudAccel = h/100/1000;
cloudVelocity = 0;
cloudMaxVel = h/400;
overCastAlpha = 0;

function updateClouds(dt) {
	var i;
	for (i=0; i<numClouds; i++) {
		clouds[i].update(dt);
	}
	
	var timeStart = spb * 5;
	var k = 0.3;
	if (time < 6000) {
		if (time > timeStart) {
			clouds[0].x += (cloudTargetX[0] - clouds[0].x) * k;
		}
		if (time > timeStart + spb) {
			clouds[1].x += (cloudTargetX[1] - clouds[1].x) * k;
		}
		if (time > timeStart + spb*2) {
			clouds[2].x += (cloudTargetX[2] - clouds[2].x) * k;
		}

		for (i=0; i<numClouds; i++) {
			ctx.globalAlpha = 1 - Math.min(1,Math.abs(cloudTargetX[i] - clouds[i].x)/50);
			clouds[i].draw();
		}
	}
	else if (time < spb*16) {
		for (i=0; i<3; i++) {
			clouds[i].y += cloudVelocity*dt;
			if (clouds[i].y > h) {
				clouds[i].setPos(Math.random()*(w+600)-300, -Math.random()*300-200);
			}
		}
		cloudVelocity += cloudAccel*dt;
		cloudVelocity = Math.min(cloudMaxVel, cloudVelocity);

		for (i=0; i<numClouds; i++) {
			clouds[i].draw();
		}

		timeStart = spb * 13;
		if (time > timeStart) {
			var targetAlpha = Math.min(1,(1+Math.floor((time - timeStart)/spb))/3)*0.95;
			overCastAlpha += (targetAlpha - overCastAlpha) * 0.1;
			ctx.fillStyle = "rgba(255,255,255,"+overCastAlpha+")";
			ctx.fillRect(0,0,w,h);
		}
	}
	else {
		targetAlpha = 0;
		overCastAlpha += (targetAlpha - overCastAlpha) * 0.1;
		if (overCastAlpha > 0.001) {
			ctx.fillStyle = "rgba(255,255,255,"+overCastAlpha+")";
			ctx.fillRect(0,0,w,h);
		}
	}

	ctx.globalAlpha = 1;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// STARS

function Star(x,y) {
	this.maxRadius = 12;
	this.radius = 0;
	this.x = x;
	this.y = y;
	this.angle = Math.PI*2*Math.random();
	this.angleSpeed = 2*Math.PI/(Math.random()*500+3300);
};

Star.prototype = {
	update: function(dt) {
		this.angle += this.angleSpeed*dt;
	},
	draw: function() {
		var r = Math.abs(Math.sin(this.angle) * this.maxRadius);
		ctx.globalAlpha = r / this.maxRadius;
		//fillSqDot(this.x, this.y,r+6,"#222");
		fillSqDot(this.x, this.y,r,"#777");
		ctx.globalAlpha = 1;
	},
};

var stars = [
	new Star(316,100),
	new Star(500,20),
	new Star(730,100),
	new Star(1024,64),
	new Star(966,210),
	new Star(1205,250),
	new Star(1083,545),
	new Star(895,539),
	new Star(520,675),
	new Star(382,480),
	new Star(123,594),
	new Star(133,252),
];
var starTimeSteps = [
	2,
	2.5,
	3,
	3.5,
	3.75,
	5,
	5.25,
	5.5,
	5.75,
	6,
	6.25,
	7,
];
var numStars = stars.length;
var starTime = 0;

function updateStars(dt) {
	var i,p;
	if (time >= spb * 16) {
		for(i=0; i<numStars; i++) {
			//if (starTime >= starTimeSteps[i]*spb) {
				stars[i].update(dt);
				stars[i].draw();
			//}
			//else {
				//break;
			//}
		}
		starTime += dt;
	}
};


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

	if (time < spb*16) {
		ctx.fillStyle = backColor;
	}
	else {
		ctx.fillStyle = "#000";
	}
	ctx.fillRect(0,0,w,h);

	updateStars(dt);
	updateSuns(dt);
	updateClouds(dt);


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
