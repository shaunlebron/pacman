savedFrames = [];
numSavedFrames = 0;

function paddy(n, p, c) {
    var pad_char = typeof c !== 'undefined' ? c : '0';
    var pad = new Array(1 + p).join(pad_char);
    return (pad + n).slice(-pad.length);
}

    (function() {
        var lastTime = 0;

		var step = 1000/24;
     
		window.requestAnimationFrame = function(callback) {
			var currTime = lastTime + step;
			var id = window.setTimeout(function() { callback(currTime); },
			  1);
			lastTime = currTime;
			if (time <= spb*48) {
				var uri = canvas.toDataURL();
				var filename = paddy(numSavedFrames, 4)+".png";
				(function(filename){
					$.ajax({
						url: "http://localhost:3000/frames/"+filename,
						type: "POST",
						data: uri,
					}).done(function() {
						console.log("wrote "+filename);
					}).fail(function() {
						console.error("failed "+filename);
					});
				})(filename);
				savedFrames.push(uri);
				numSavedFrames++;
			}
			return id;
		};
     
    }());

    /**********/
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
	this.radius = (radii[0]+1)/6*240;
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
			[0,2,3,4,5,6,7, 8,10,11,12,13,14],
			//[0,2,3,4,5,6,7],
			[5,4,3,2,4,0,2, 5,4,3,2,5,4],
			color),
		new DancingSun(
			[0,1,2,2.5,3,3.5,4,5,6,7,7.5,   8,9,10,10.5,11,11.5,12,13,14],
			//[0,1,2,2.5,3,3.5,4,5,6,7,7.5],
			[-1,5,4,1.5,2,2.5,3,4,5,3,4,5, -1,5,4,1.5,2,2.5,3,5],
			color),
	];
}

function EatingSun (r,r2) {
	this.r = r;
	this.r2 = r2;
	this.nextFaceAngle = 0;
	this.timeSteps = [ 0,0.5,0.6,1 ];
	this.faceAngles = [
		Math.PI + Math.PI,
		Math.PI + Math.PI,
		Math.PI + Math.PI,
		Math.PI + Math.PI,
	];
	this.faceAngle = this.faceAngles[0];

	this.mouthAngle = Math.PI/6;
	this.mouthAngles = [
		Math.PI/3,
		0,
		Math.PI/3,
		0,
	];
	this.time = 0;

	this.stars = [
		{x: w*1.5, y: h/2},
		{x: w*1.5, y: h/2},
	];
	this.starTimes = [ 0.2, 0.6 ];
}

EatingSun.prototype = {
	update: function(dt) {
		var i,len=this.timeSteps.length;
		for (i=0; i<len; i++) {
			if (this.timeSteps[i]*spb <= this.time) {
				this.nextFaceAngle = this.faceAngles[i];
				this.nextMouthAngle = this.mouthAngles[i];
			}
		}
		if (Math.abs(this.faceAngle - this.nextFaceAngle) > 0.001) {
			this.faceAngle += (this.nextFaceAngle - this.faceAngle) * 0.2;
		}
		if (Math.abs(this.mouthAngle - this.nextMouthAngle) > 0.001) {
			this.mouthAngle += (this.nextMouthAngle - this.mouthAngle) * 0.5;
		}
		len=this.starTimes.length;
		var s;
		for (i=0; i<len; i++) {
			s = this.stars[i];
			if (this.starTimes[i]*spb <= this.time) {
				s.x -= 5*dt;
				if (s.x <= w/2) {
					s.x = -w;
				}
			}
		}
		this.time += dt;
	},
	draw: function() {
		var color = "rgba(255,255,0,0.7)";
		var m = this.mouthAngle/2;

		var i,len=this.starTimes.length;
		var s,sr = 32;
		ctx.fillStyle = "#FFF";
		for (i=0; i<len; i++) {
			s = this.stars[i];
			ctx.fillRect(s.x-sr/2,s.y-sr/2,sr,sr);
		}

		ctx.beginPath();
		ctx.arc(w/2,h/2,this.r2, 0, Math.PI*2);
		ctx.fillStyle = color;
		ctx.fill();

		ctx.beginPath();
		ctx.arc(w/2,h/2,this.r, this.faceAngle+m, this.faceAngle-m);
		ctx.lineTo(
			w/2 - Math.cos(this.faceAngle) * this.r/4,
			h/2 - Math.sin(this.faceAngle) * this.r/4
		);
		ctx.closePath();
		ctx.fill();
	},
};

var eatingSun = new EatingSun(5/6*240, 240);

function DyingSun (r,r2) {
	this.r = r;
	this.r2 = r2;

	this.faceAngle = 0;
	this.mouthAngle = 0;

	this.time = 0;
	this.scaleInterp = Ptero.makeHermiteInterp([1, 1, 0.5, 0], [0, spb, spb*2, spb]);
	this.angleInterp = Ptero.makeHermiteInterp([0, Math.PI, Math.PI*3, Math.PI*2.5], [spb, spb, spb, spb]);
	this.alphaInterp = Ptero.makeHermiteInterp([0, 0.5, 0.1], [spb, spb, spb*2]);
	this.mouthAngleInterp = Ptero.makeHermiteInterp([0, Math.PI/2, Math.PI], [spb, spb, spb]);
	this.mouthDistInterp = Ptero.makeHermiteInterp([0.5, 0, -0.5], [spb, spb, spb]);

	this.colors = [
		 "rgba(255,0,0,",
		 "rgba(255,184,255,",
		 "rgba(0,255,255,",
		 "rgba(255,184,81,",
	];
}

DyingSun.prototype = {
	update: function(dt) {
		this.scale = this.scaleInterp(this.time);
		this.angle = this.angleInterp(this.time);
		this.alpha = this.alphaInterp(this.time);
		this.mouthAngle = this.mouthAngleInterp(this.time);
		this.mouthDist = this.mouthDistInterp(this.time);
		this.time += dt;
	},
	draw: function() {

		if (this.angle != undefined && this.alpha != undefined) {
			ctx.save();
			ctx.translate(w/2,h/2);
			ctx.rotate(this.angle);

			var i;
			var pad = Math.PI/20;
			for (i=0; i<4; i++) {
				ctx.beginPath();
				ctx.arc(0,0,h,i*Math.PI/2+pad,(i+1)*Math.PI/2-pad);
				ctx.lineTo(0,0);
				ctx.closePath();
				ctx.fillStyle = this.colors[i]+this.alpha+")";
				ctx.fill();
			}

			ctx.restore();
		}

		var color = "rgba(255,255,0,0.7)";
		var m = this.mouthAngle/2;

		if (time <= spb*47) {
			ctx.beginPath();
			ctx.arc(w/2,h/2,this.r2*this.scale, 0, Math.PI*2);
			ctx.fillStyle = color;
			ctx.fill();

			ctx.fillStyle = "#FF0";
			if (!this.mouthAngle) {
				ctx.beginPath();
				ctx.arc(w/2,h/2,this.r*this.scale, 0, Math.PI*2);
				ctx.closePath();
				ctx.fill();
			}
			else {
				ctx.beginPath();
				var a = this.mouthAngle;
				ctx.arc(w/2,h/2,this.r*this.scale, -Math.PI/2+a, 3*Math.PI/2-a);
				ctx.lineTo(w/2,h/2+this.r*this.scale*this.mouthDist);
				ctx.closePath();
				ctx.fill();
			}
		}
	},
};

var dyingSun = new DyingSun(200,240);

function makeSunBurst() {

	var rings = [];
	var i,len=20;
	for (i=0; i<len; i++) {
		rings[i] = 0;
	}
	var t=0;
	var period = 15;
	var speed = 2;

	function update(dt) {
		for (i=0; i<len; i++) {
			if (i*20 <= t) {
				rings[i] += dt*speed;
			}
		}
		t += dt;
	}

	function draw() {
		ctx.strokeStyle = "rgba(255,255,0,0.1)";
		ctx.lineWidth = 20;
		for (i=0; i<len; i++) {
			ctx.beginPath();
			ctx.arc(w/2,h/2,rings[i],0,Math.PI*2);
			ctx.stroke();
		}

		var color = "rgba(255,255,0,0.7)";
		ctx.fillStyle = color;
		ctx.beginPath();
		ctx.arc(w/2,h/2,5/6*240,0,Math.PI*2);
		ctx.fill();
		ctx.beginPath();
		ctx.arc(w/2,h/2,240,0,Math.PI*2);
		ctx.fill();

		var alpha = Math.min(1,t/(1*spb));
		ctx.fillStyle = "rgba(255,255,255,"+alpha+")";
		ctx.fillRect(0,0,w,h);
	}

	return {
		update: update,
		draw: draw,
	};
};

function makeSunBurst2() {

	var rings = [];
	var i,len=20;
	for (i=0; i<len; i++) {
		rings[i] = 0;
	}
	var t=0;
	var period = 15;
	var speed = 2;

	function update(dt) {
		for (i=0; i<len; i++) {
			if (i*20 <= t) {
				rings[i] += dt*speed;
			}
		}
		t += dt;
	}

	function draw() {
		ctx.strokeStyle = "rgba(255,255,0,0.1)";
		ctx.lineWidth = 20;
		for (i=0; i<len; i++) {
			ctx.beginPath();
			ctx.arc(w/2,h/2,rings[i],0,Math.PI*2);
			ctx.stroke();
		}

	}

	return {
		update: update,
		draw: draw,
	};
};

var sunBurst = makeSunBurst();
var sunBurst2 = makeSunBurst2();

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
		/*
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
		*/
	}
	else if (time < spb*30.5) {
		dancingSuns[0].update(dt);
		dancingSuns[1].update(dt);
	}
	else if (time < spb*32) {
		eatingSun.update(dt);
		eatingSun.draw();
	}
	else if (time < spb*33) {
		sunBurst.update(dt);
		sunBurst.draw();
	}
	else if (time >= spb*44) {
		dyingSun.update(dt);
		dyingSun.draw();
		if (time >= spb*47) {
			sunBurst2.update(dt);
			sunBurst2.draw();
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Clouds

function CloudBubble(x,y,r,r2,color,color2,color3,color4) {
	this.x = x;
	this.y = y;
	this.lift = 0;
	this.r = r;
	this.r2 = r2;
	this.color = color;
	this.color2 = color2;
	this.color3 = color3;
	this.color4 = color4;
	this.angle = Math.random()*Math.PI*2;
}

CloudBubble.prototype = {
	update: function(dt) {
		this.angle += Math.PI*2/3000 * dt;
		this.angle %= (Math.PI*2);
		var ar = 3;
		this.lift = Math.sin(this.angle) * ar;
	},
	getY: function() {
		return this.y + this.lift;
	},
	draw: function() {

		var y = this.getY();
		ctx.save();
		ctx.translate(this.x,y);
		ctx.rotate(this.rotAngle || 0);

		ctx.beginPath();
		ctx.arc(0,0, this.r, Math.PI, Math.PI*2);
		ctx.lineTo(this.r, this.r);
		ctx.lineTo(-this.r, this.r);
		ctx.closePath();
		if (this.alpha != undefined) {
			ctx.fillStyle = this.color3;
			ctx.fill();
			ctx.fillStyle = "rgba(255,255,255,"+this.alpha+")";
		}
		else {
			ctx.fillStyle = this.color;
		}
		ctx.fill();
		ctx.strokeStyle = ctx.fillStyle;
		ctx.lineWidth = pad;
		ctx.lineJoin = "round";
		ctx.stroke();
		ctx.restore();
	},
	drawBorder: function() {
		var y = this.getY();
		ctx.save();
		ctx.translate(this.x,y);
		ctx.rotate(this.rotAngle || 0);

		ctx.beginPath();
		ctx.arc(0,0, this.r, Math.PI, Math.PI*2);
		ctx.lineTo(this.r, this.r);
		ctx.lineTo(-this.r, this.r);
		ctx.closePath();
		ctx.strokeStyle = this.color2;
		ctx.lineWidth = pad*2;
		ctx.lineJoin = "round";
		ctx.stroke();

		ctx.restore();
	},
};

function Cloud() {
	this.angle = Math.random()*Math.PI*2;
	this.x = 0;
	this.y = 0;
	this.lift = 0;
	this.r = 80;
	this.r2 = this.r + pad;
	this.w = this.r*5;
	this.h = 200;

	var color = "#FFF";
	var color2 = "rgba(255,255,255,0.2)";
	var r = this.r;
	var r2 = this.r2;
	var h = this.h;

	var blinkyColor = "#FF0000";
	var blinkyPathColor = "rgba(255,0,0,0.5)";

	var pinkyColor = "#FFB8FF";
	var pinkyPathColor = "rgba(255,184,255,0.5)";

	var inkyColor = "#00FFFF";
	var inkyPathColor = "rgba(0,255,255,0.5)";

	var clydeColor = "#FFB851";
	var clydePathColor = "rgba(255,184,81,0.5)";

	this.bubbles = [
		new CloudBubble(r,   h,       r, r2, color, color2, clydeColor, clydePathColor),
		new CloudBubble(2*r, h-0.8*r, r, r2, color, color2, inkyColor, inkyPathColor),
		new CloudBubble(3*r, h-r,     r, r2, color, color2, blinkyColor, blinkyPathColor),
		new CloudBubble(4*r, h,       r, r2, color, color2, pinkyColor, pinkyPathColor),
	];
	this.disconnect = false;
}


Cloud.prototype = {
	update: function(dt) {
		this.angle += Math.PI*2/3000 * dt;
		this.angle %= (Math.PI*2);
		this.lift = Math.sin(this.angle) * 3;

		if (!this.disconnect) {
			var i,len=this.bubbles.length;
			for (i=0; i<len; i++ ) {
				this.bubbles[i].update(dt);
			}
		}
	},
	getY: function() {
		return this.y + this.lift;
	},
	setPos: function(x,y) {
		this.x = x;
		this.y = y;
	},
	draw: function() {
		var y = this.getY();
		ctx.save();
		ctx.translate(this.x,y);
		ctx.beginPath();
		ctx.rect(-pad,-pad,this.w+pad*2,this.h+pad*2);
		ctx.clip();

		if (!this.disconnect) {
			var i,len=this.bubbles.length;
			for (i=0; i<len; i++ ) {
				this.bubbles[i].drawBorder();
			}
			for (i=0; i<len; i++ ) {
				this.bubbles[i].draw();
			}
		}

		fillCirc(2.5*this.r,this.h,1.5*this.r,"#FFF");

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
// SHOOTING STARS

function StarParticle(totalTime, pos, dir, speed) {
	this.time = 0;
	this.totalTime = totalTime;
	this.pos = pos;
	this.dir = dir;
	this.speed = speed;
};

StarParticle.prototype = {
	update: function(dt) {
		this.time += dt;
		this.pos.x += this.dir.x * this.speed * dt;
		this.pos.y += this.dir.y * this.speed * dt;
	},
	isDone: function() {
		return this.time >= this.totalTime;
	},
	draw: function() {
		var alpha = Math.max(0,1.0-this.time/this.totalTime);
		ctx.save();
		ctx.translate(this.pos.x, this.pos.y);
		ctx.rotate(Math.PI*2 * this.time);
		ctx.fillStyle = "rgba(255,255,255,"+alpha+")";
		var r = 15;
		ctx.fillRect(-r/2, -r/2, r, r);
		ctx.restore();
	},
};

function StarParticleJet(period, pos, dir, speed) {
	this.pos = pos;
	this.dir = dir;
	this.speed = speed;
	this.time = 0;
	this.period = period;
	this.particles = [];
};

StarParticleJet.prototype = {
	makeParticle: function() {
		var angle = Math.random() * Math.PI/2;
		var c = Math.cos(angle);
		var s = Math.sin(angle);
		// (a+bi)(c+di) = (ac - bd) + (ad + bc)i
		var vx = c*this.dir.x - s*this.dir.y;
		var vy = c*this.dir.y + s*this.dir.x;
		vx = -vx;
		vy = -vy;
		this.particles.push(
			new StarParticle(
				1.0,
				{x:this.pos.x,y:this.pos.y},
				{x:vx, y:vy},
				this.speed*Math.random()));
	},
	update: function(dt) {
		this.time += dt;
		var i=0,p;
		while (this.particles[i]) {
			p = this.particles[i];
			p.update(dt);
			if (p.isDone()) {
				this.particles.splice(i,1);
			}
			else {
				i++;
			}
		}
		if (this.time > this.period) {
			this.time = 0;
			this.makeParticle();
			this.makeParticle();
		}
	},
	draw: function() {
		var i;
		for (i=0; this.particles[i]; i++) {
			this.particles[i].draw();
		}
	},
};

function ShootingStar(pos, dir, speed) {
	this.pos = pos;
	this.dir = dir;
	this.speed = speed;
	//this.jet = new StarParticleJet(1/40, pos, dir, speed*0.5);
};

ShootingStar.prototype = {
	update: function(dt) {
		this.pos.x += this.dir.x*this.speed*dt;
		this.pos.y += this.dir.y*this.speed*dt;
		//this.jet.update(dt);
	},
	bounce: function() {
		if (this.pos.x < 0) {
			this.pos.x = 0;
			this.dir.x *= -1;
		}
		if (this.pos.x >= w) {
			this.pos.x = w-1;
			this.dir.x *= -1;
		}
		if (this.pos.y < 0) {
			this.pos.y = 0;
			this.dir.y *= -1;
		}
		if (this.pos.y >= h) {
			this.pos.y = h-1;
			this.dir.y *= -1;
		}
	},
	draw: function() {
		var alpha = Math.min(1,Math.max(0,(this.pos.x+w/3)/(2*w)));
		ctx.strokeStyle = "rgba(255,255,255,"+alpha+")";
		ctx.lineWidth = 20;
		ctx.beginPath();
		ctx.moveTo(this.pos.x, this.pos.y);
		var length = 500;
		ctx.lineTo(
			this.pos.x + -this.dir.x*length,
			this.pos.y + -this.dir.y*length);
		ctx.stroke();
		ctx.fillStyle = "#FFF";
		var r = 20;
		ctx.fillRect(this.pos.x - r/2, this.pos.y - r/2, r, r);
		//this.jet.draw();
	},
};

var makeShootingStar = function() {
	var angle = Math.PI;
	return new ShootingStar(
		{x: w, y: Math.random()*h},
		{x: Math.cos(angle), y: Math.sin(angle)},
		5
	);
};

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
];
var starTime = 0;

var shootingStars = [];
function initShootingStars() {
	var i,len=starTimeSteps.length;
	for (i=0; i<len; i++) {
		shootingStars[i] = makeShootingStar();
	}
}

function updateShootingStars(dt) {
	var i,len=starTimeSteps.length;
	if (time >= spb * 24) {
		for (i=0; i<len; i++) {
			if (starTime >= starTimeSteps[i]*spb) {
				shootingStars[i].update(dt);
				shootingStars[i].draw();
			}
		}
		starTime += dt;
	}
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
var numStars = stars.length;

function updateStars(dt) {
	var i,p;
	if ((time >= spb * 16 && time <= spb * 32) || time >= spb*44) {
		for(i=0; i<numStars; i++) {
			//if (starTime >= starTimeSteps[i]*spb) {
				stars[i].update(dt);
				stars[i].draw();
			//}
			//else {
				//break;
			//}
		}
	}
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////

var skyFallTime=0;
var skyFallRays = [0,0,0,0,0];
var skyFallSteps = [
	1,1.5,2,2.5,2.75
];
function updateSkyFall(dt) {
	if (time <= spb*33) {
		return;
	}

	if (skyFallTime < spb*1) {
		var alpha = 1-skyFallTime/spb;
		ctx.fillStyle = "rgba(255,255,255,"+alpha+")";
		ctx.fillRect(0,0,w,h);
	}
	else {
		ctx.lineWidth = 20;
		var i,len=skyFallSteps.length;
		for (i=0; i<len; i++) {
			if (skyFallTime >= skyFallSteps[i]*spb) {
				skyFallRays[i] += dt*2;
				var y = skyFallRays[i];
				var j,jlen=5;
				for (j=0; j<jlen; j++) {
					alpha = (jlen-1-j)/(jlen);
					ctx.strokeStyle = "rgba(255,255,0,"+alpha+")";
					var jy=y-j*20;
					ctx.beginPath();
					ctx.moveTo(0,jy);
					ctx.lineTo(w,jy);
					ctx.stroke();
				}
			}
		}
	}
	skyFallTime += dt;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////


var updateGhostCloud = (function(){
	var t = 0;
	var c = new Cloud();
	c.setPos(w/3+20,h/2);
	var bows = [
		0,0,0,0,
	];
	var bowTimes = [
		3,4,5,6
	];

	var bowCenterX = -w/4;
	var bottomY;

	var interpMade = false;
	var interpMade2 = false;
	var interps = [];

	return function(dt) {
		if (time <= spb*33) {
			return;
		}

		if (time <= spb*40) {
			c.update(dt);

			bottomY = c.getY() + c.h;
			var i,len=bowTimes.length;
			for (i=0; i<len; i++) {
				if (t >= bowTimes[i]*spb) {
					bows[i] += Math.PI * (dt/1000);

					var b = c.bubbles[i];
					var x = c.x + b.x;
					var y = c.getY() + b.getY();
					var dx = x-bowCenterX;
					var dy = bottomY - y;
					var r = Math.sqrt(dx*dx+dy*dy);
					//var startAngle = Math.atan(dy/dx);
					var startAngle = 0;
					var endAngle = Math.min(Math.PI/2, bows[i]);
					endAngle = Math.max(startAngle, endAngle);

					ctx.beginPath();
					//ctx.arc(bowCenterX, bottomY, r, 0, Math.PI*2);
					ctx.arc(bowCenterX, bottomY, r, -endAngle, -startAngle);
					ctx.strokeStyle = b.color3;
					ctx.lineWidth = b.r*1.25;
					ctx.stroke();
				}
			}

			c.draw();
		}
		else if (time <= spb*44) {
			if (!interpMade) {
				c.disconnect = true;
				t = 0;
				interpMade = true;
				var points = [];
				for (i=0; i<4; i++) {
					points.push({
							alpha: 1,
							angle: Math.random()*Math.PI*2,
							x: c.x + c.bubbles[i].x,
							y: c.getY() + c.bubbles[i].getY()});
				}
				var points3 = [
					{angle: 2*Math.PI*3, alpha: 0, x:w/5,   y:h/2},
					{angle: 2*Math.PI*3, alpha: 0, x:2*w/5, y:h/2},
					{angle: 2*Math.PI*3, alpha: 0, x:3*w/5, y:h/2},
					{angle: 2*Math.PI*3, alpha: 0, x:4*w/5, y:h/2},
				];
				var points4 = [
					{angle: 2*Math.PI*3, alpha: 0, x:w/5,   y:-h/2},
					{angle: 2*Math.PI*3, alpha: 0, x:2*w/5, y:-h/2},
					{angle: 2*Math.PI*3, alpha: 0, x:3*w/5, y:-h/2},
					{angle: 2*Math.PI*3, alpha: 0, x:4*w/5, y:-h/2},
				];
				var points2 = [
					{angle: 2*Math.PI*3*Math.random(), alpha: 0.9, x:w/5,   y:h/3*Math.random()},
					{angle: 2*Math.PI*3*Math.random(), alpha: 0.9, x:2*w/5, y:h/3*Math.random()},
					{angle: 2*Math.PI*3*Math.random(), alpha: 0.9, x:3*w/5, y:h/3*Math.random()},
					{angle: 2*Math.PI*3*Math.random(), alpha: 0.9, x:4*w/5, y:h/3*Math.random()},
				];
				for (i=0; i<4; i++) {
					points2[i].x = points[i].x + (points3[i].x - points[i].x)/2;
				}
				var delta_times = [ 0,spb,2*spb,0.5*spb ];
				var keys = ['angle', 'alpha','x','y'];

				interps = [];
				for (i=0; i<4; i++) {
					interps.push(Ptero.makeHermiteInterpForObjs([points[i], points2[i], points3[i], points4[i]],keys,delta_times));
				};
			}
			ctx.save();
			if (t < spb) {
				ctx.beginPath();
				ctx.rect(0,0,w,bottomY);
				ctx.clip();
			}
			for (i=0; i<4; i++) {
				var b = c.bubbles[i];
				var o = interps[i](t);
				if (o) {
					b.x = o.x;
					b.y = o.y;
					b.rotAngle = o.angle;
					b.alpha = o.alpha;
				}
				b.drawBorder();
			}
			for (i=0; i<4; i++) {
				var b = c.bubbles[i];
				b.draw();
			}
			ctx.restore();
			if (time >= spb*43) {
				for (i=0; i<4; i++) {
					var b = c.bubbles[i];
					ctx.fillStyle = b.color4;
					var r = 30;
					ctx.fillRect(
						b.x-r,
						b.y+2*r,
						2*r,2*h
					);
				}

				if (time >= spb*43.5) {
					ctx.fillStyle = "rgba(0,0,0," + (1-(44*spb-time)/(spb*0.5)) + ")";
					ctx.fillRect(0,0,w,h);
				}
			}
		}
		else {
			if (!interpMade2) {
				c.disconnect = true;
				t = 0;
				interpMade2 = true;
				var points = [];
				for (i=0; i<4; i++) {
					points.push({
							alpha: 0,
							angle: 0,
							x: w/2,
							y: h*1.2,
					});
				}
				var points2 = [
					{angle: 0, alpha: 0, x:w/2, y:h/2},
					{angle: 0, alpha: 0, x:w/2, y:h/2},
					{angle: 0, alpha: 0, x:w/2, y:h/2},
					{angle: 0, alpha: 0, x:w/2, y:h/2},
				];
				var delta_times = [
					[0,spb*0.2 ],
					[spb*0.2,spb*0.2 ],
					[spb*0.4,spb*0.2 ],
					[spb*0.6,spb*0.2 ],
				];
				var keys = ['angle', 'alpha','x','y'];

				interps = [];
				for (i=0; i<4; i++) {
					interps.push(Ptero.makeHermiteInterpForObjs([points[i], points2[i] ],keys,delta_times[i]));
				};
			}
			if (t < spb*1) {
				for (i=0; i<4; i++) {
					var b = c.bubbles[i];
					var o = interps[i](t);
					if (o) {
						b.x = o.x;
						b.y = o.y;
						b.rotAngle = o.angle;
						b.alpha = o.alpha;
					}
					b.drawBorder();
				}
				for (i=0; i<4; i++) {
					var b = c.bubbles[i];
					b.draw();
				}
			}

		}

		t += dt;
	};
})();

///////////////////////////////////////////////////////////////////////////////////////////////////////////

function updateFinalFade(dt) {
	var start = 44*spb;
	var end = 48*spb;
	var len = spb*0.5;
	
	if (time >= start && time <= start+len) {
		var alpha = 1-(time-start)/len;
		ctx.fillStyle = "rgba(0,0,0,"+alpha+")";
		ctx.fillRect(0,0,w,h);
	}

	if (time >= end-len) {
		var alpha = Math.max(0,1-(end-time)/len);
		ctx.fillStyle = "rgba(0,0,0,"+alpha+")";
		ctx.fillRect(0,0,w,h);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////

function updateSky(dt) {
	if (time < spb*16) {
		ctx.fillStyle = backColor;
	}
	else if (time < spb*33) {
		ctx.fillStyle = "#000";
	}
	else if (time < spb*44) {
		ctx.fillStyle = backColor;
	}
	else {
		ctx.fillStyle = "#000";
	}
	ctx.fillRect(0,0,w,h);
};

function tick(t) {
	var dt;
	if (!last_tick_t) {
		dt = 0;
	}
	else {
		dt = t - last_tick_t;
	}
	last_tick_t = t;

	updateSky();
	updateGhostCloud(dt);
	updateStars(dt);
	updateSuns(dt);
	updateClouds(dt);
	updateShootingStars(dt);
	updateSkyFall(dt);

	updateFinalFade(dt);

	time += dt;
	window.requestAnimationFrame(tick);
}

function playSong() {
	var song = new Audio();
	var first = false;
	song.onloadeddata = function() {
		if (!first) {
			song.currentTime = time / 1000;
			//song.play();
			song.currentTime = time / 1000;
			window.requestAnimationFrame(tick);
		}
		first = true;
	};
	song.src = "philipp.ogg";
}

window.addEventListener("load", function() {
	canvas = document.getElementById('canvas');
	ctx = canvas.getContext('2d');
	createSuns();
	initClouds();
	initShootingStars();
	playSong();
});
