//////////////////////////////////////////////////////////////////////////////////////
// Sprites
// (sprites are created using canvas paths)

var drawGhostSprite = (function(){

    // add top of the ghost head to the current canvas path
    var addHead = (function() {

        // pixel coordinates for the top of the head
        // on the original arcade ghost sprite
        var coords = [
            0,6,
            1,3,
            2,2,
            3,1,
            4,1,
            5,0,
            8,0,
            9,1,
            10,1,
            11,2,
            12,3,
            13,6,
        ];

        return function(ctx) {
            var i;
            ctx.save();

            // translate by half a pixel to the right
            // to try to force centering
            ctx.translate(0.5,0);

            ctx.moveTo(0,6);
            ctx.quadraticCurveTo(1.5,0,6.5,0);
            ctx.quadraticCurveTo(11.5,0,13,6);

            // draw lines between pixel coordinates
            /*
            ctx.moveTo(coords[0],coords[1]);
            for (i=2; i<coords.length; i+=2)
                ctx.lineTo(coords[i],coords[i+1]);
            */

            ctx.restore();
        };
    })();

    // add first ghost animation frame feet to the current canvas path
    var addFeet1 = (function(){

        // pixel coordinates for the first feet animation
        // on the original arcade ghost sprite
        var coords = [
            13,13,
            11,11,
            9,13,
            8,13,
            8,11,
            5,11,
            5,13,
            4,13,
            2,11,
            0,13,
        ];

        return function(ctx) {
            var i;
            ctx.save();

            // translate half a pixel right and down
            // to try to force centering and proper height
            ctx.translate(0.5,0.5);

            // continue previous path (assuming ghost head)
            // by drawing lines to each of the pixel coordinates
            for (i=0; i<coords.length; i+=2)
                ctx.lineTo(coords[i],coords[i+1]);

            ctx.restore();
        };

    })();

    // add second ghost animation frame feet to the current canvas path
    var addFeet2 = (function(){

        // pixel coordinates for the second feet animation
        // on the original arcade ghost sprite
        var coords = [
            13,12,
            12,13,
            11,13,
            9,11,
            7,13,
            6,13,
            4,11,
            2,13,
            1,13,
            0,12,
        ];

        return function(ctx) {
            var i;
            ctx.save();

            // translate half a pixel right and down
            // to try to force centering and proper height
            ctx.translate(0.5,0.5);

            // continue previous path (assuming ghost head)
            // by drawing lines to each of the pixel coordinates
            for (i=0; i<coords.length; i+=2)
                ctx.lineTo(coords[i],coords[i+1]);

            ctx.restore();
        };

    })();

    // draw regular ghost eyes
    var addEyes = function(ctx,dirEnum){
        var i;

        ctx.save();
        ctx.translate(2,3);

        var coords = [
            0,1,
            1,0,
            2,0,
            3,1,
            3,3,
            2,4,
            1,4,
            0,3
        ];

        var drawEyeball = function() {
            ctx.translate(0.5,0.5);
            ctx.beginPath();
            ctx.moveTo(coords[0],coords[1]);
            for (i=2; i<coords.length; i+=2)
                ctx.lineTo(coords[i],coords[i+1]);
            ctx.closePath();
            ctx.fill();
            ctx.lineJoin = 'round';
            ctx.stroke();
            ctx.translate(-0.5,-0.5);
            //ctx.fillRect(1,0,2,5); // left
            //ctx.fillRect(0,1,4,3);
        };

        // translate eye balls to correct position
        if (dirEnum == DIR_LEFT) ctx.translate(-1,0);
        else if (dirEnum == DIR_RIGHT) ctx.translate(1,0);
        else if (dirEnum == DIR_UP) ctx.translate(0,-1);
        else if (dirEnum == DIR_DOWN) ctx.translate(0,1);

        // draw eye balls
        ctx.fillStyle = "#FFF";
        ctx.strokeStyle = "#FFF";
        ctx.lineWidth = 1.0;
        ctx.lineJoin = 'round';
        drawEyeball();
        ctx.translate(6,0);
        drawEyeball();

        // translate pupils to correct position
        if (dirEnum == DIR_LEFT) ctx.translate(0,2);
        else if (dirEnum == DIR_RIGHT) ctx.translate(2,2);
        else if (dirEnum == DIR_UP) ctx.translate(1,0);
        else if (dirEnum == DIR_DOWN) ctx.translate(1,3);

        // draw pupils
        ctx.fillStyle = "#00F";
        ctx.fillRect(0,0,2,2); // right
        ctx.translate(-6,0);
        ctx.fillRect(0,0,2,2); // left

        ctx.restore();
    };

    // draw scared ghost face
    var addScaredFace = function(ctx,flash){
        ctx.strokeStyle = ctx.fillStyle = flash ? "#F00" : "#FF0";

        // eyes
        ctx.fillRect(4,5,2,2);
        ctx.fillRect(8,5,2,2);

        // mouth
        var coords = [
            1,10,
            2,9,
            3,9,
            4,10,
            5,10,
            6,9,
            7,9,
            8,10,
            9,10,
            10,9,
            11,9,
            12,10,
        ];
        ctx.translate(0.5,0.5);
        ctx.beginPath();
        ctx.moveTo(coords[0],coords[1]);
        for (i=2; i<coords.length; i+=2)
            ctx.lineTo(coords[i],coords[i+1]);
        ctx.lineWidth = 1.0;
        ctx.stroke();
        ctx.translate(-0.5,-0.5);
        /*
        ctx.fillRect(1,10,1,1);
        ctx.fillRect(12,10,1,1);
        ctx.fillRect(2,9,2,1);
        ctx.fillRect(6,9,2,1);
        ctx.fillRect(10,9,2,1);
        ctx.fillRect(4,10,2,1);
        ctx.fillRect(8,10,2,1);
        */
    };


    return function(ctx,x,y,frame,dirEnum,scared,flash,eyes_only,color) {
        ctx.save();
        ctx.translate(x-7,y-7);

        if (scared)
            color = flash ? "#FFF" : "#2121ff";

        if (!eyes_only) {
            // draw body
            ctx.beginPath();
            addHead(ctx);
            if (frame == 0)
                addFeet1(ctx);
            else
                addFeet2(ctx);
            ctx.closePath();
            ctx.lineJoin = 'round';
            ctx.lineCap = 'round';
            ctx.lineWidth = 0.5;
            ctx.strokeStyle = color;
            ctx.stroke();
            ctx.lineWidth = 1;
            ctx.fillStyle = color;
            ctx.fill();
        }

        // draw face
        if (scared)
            addScaredFace(ctx, flash);
        else
            addEyes(ctx,dirEnum);

        ctx.restore();
    };
})();

// draw pacman body
var drawPacmanSprite = function(ctx,x,y,dirEnum,angle,mouthShift,scale,centerShift,alpha,color) {

    if (mouthShift == undefined) mouthShift = 0;
    if (centerShift == undefined) centerShift = 0;
    if (scale == undefined) scale = 1;
    if (alpha == undefined) alpha = 1;

    if (color == undefined) {
        color = "rgba(255,255,0," + alpha + ")";
    }

    ctx.save();
    ctx.translate(x,y);

    // rotate to current heading direction
    var d90 = Math.PI/2;
    if (dirEnum == DIR_UP) ctx.rotate(3*d90);
    else if (dirEnum == DIR_RIGHT) ctx.rotate(0);
    else if (dirEnum == DIR_DOWN) ctx.rotate(d90);
    else if (dirEnum == DIR_LEFT) ctx.rotate(2*d90);

    // plant corner of mouth
    ctx.beginPath();
    ctx.moveTo(-3+mouthShift,0);

    // draw head outline
    ctx.arc(centerShift,0,6.5*scale,angle,2*Math.PI-angle);
    ctx.closePath();

    //ctx.strokeStyle = color;
    //ctx.stroke();
    ctx.fillStyle = color;
    ctx.fill();

    ctx.restore();
};

var drawMsPacmanSprite = function(ctx,x,y,dirEnum,frame) {
    var angle = 0;

    // draw body
    if (frame == 0) {
        // closed
        drawPacmanSprite(ctx,x,y,dirEnum,0);
    }
    else if (frame == 1) {
        // open
        angle = Math.atan(4/5);
        drawPacmanSprite(ctx,x,y,dirEnum,angle);
        angle = Math.atan(4/8); // angle for drawing eye
    }
    else if (frame == 2) {
        // wide
        angle = Math.atan(6/3);
        drawPacmanSprite(ctx,x,y,dirEnum,angle);
        angle = Math.atan(6/6); // angle for drawing eye
    }

    ctx.save();
    ctx.translate(x,y);

    // reflect or rotate sprite according to current direction
    var d90 = Math.PI/2;
    if (dirEnum == DIR_UP)
        ctx.rotate(-d90);
    else if (dirEnum == DIR_DOWN)
        ctx.rotate(d90);
    else if (dirEnum == DIR_LEFT)
        ctx.scale(-1,1);

    // bow
    var x=-7.5,y=-7.5;
    ctx.beginPath();
    ctx.arc(x+1,y+4,1.25,0,Math.PI*2);
    ctx.arc(x+2,y+5,1.25,0,Math.PI*2);
    ctx.arc(x+3,y+3,1.25,0,Math.PI*2);
    ctx.arc(x+4,y+1,1.25,0,Math.PI*2);
    ctx.arc(x+5,y+2,1.25,0,Math.PI*2);
    ctx.fillStyle = "#F00";
    ctx.fill();
    ctx.beginPath();
    ctx.arc(x+2.5,y+3.5,0.5,0,Math.PI*2);
    ctx.arc(x+3.5,y+2.5,0.5,0,Math.PI*2);
    ctx.fillStyle = "#0031FF";
    ctx.fill();

    // lips
    ctx.strokeStyle = "#F00";
    ctx.lineWidth = 1.25;
    ctx.lineCap = "butt";
    ctx.beginPath();
    if (frame == 0) {
        ctx.moveTo(5,0);
        ctx.lineTo(7,0);
        ctx.moveTo(6.5,-2);
        ctx.lineTo(6.5,2);
    }
    else {
        var r1 = 7;
        var r2 = 9;
        var c = Math.cos(angle);
        var s = Math.sin(angle);
        ctx.moveTo(-3+r1*c,r1*s);
        ctx.lineTo(-3+r2*c,r2*s);
        ctx.moveTo(-3+r1*c,-r1*s);
        ctx.lineTo(-3+r2*c,-r2*s);
    }
    ctx.stroke();

    // mole
    ctx.beginPath();
    ctx.arc(-3,2,0.5,0,Math.PI*2);
    ctx.fillStyle = "#000";
    ctx.fill();

    // eye
    ctx.strokeStyle = "#000";
    ctx.beginPath();
    if (frame == 0) {
        ctx.moveTo(-3,-2);
        ctx.lineTo(0,-2);
    }
    else {
        var r1 = 0;
        var r2 = 3;
        var c = Math.cos(angle);
        var s = Math.sin(angle);
        ctx.moveTo(-3+r1*c,-2-r1*s);
        ctx.lineTo(-3+r2*c,-2-r2*s);
    }
    ctx.stroke();

    ctx.restore();
};

var drawCookiemanSprite = (function(){

    var prevFrame = undefined;
    var sx1 = 0; // shift x for first pupil
    var sy1 = 0; // shift y for first pupil
    var sx2 = 0; // shift x for second pupil
    var sy2 = 0; // shift y for second pupil

    var er = 2.1; // eye radius
    var pr = 1; // pupil radius

    var movePupils = function() {
        var a1 = Math.random()*Math.PI*2;
        var a2 = Math.random()*Math.PI*2;
        var r1 = Math.random()*pr;
        var r2 = Math.random()*pr;

        sx1 = Math.cos(a1)*r1;
        sy1 = Math.sin(a1)*r1;
        sx2 = Math.cos(a2)*r2;
        sy2 = Math.sin(a2)*r2;
    };

    return function(ctx,x,y,dirEnum,frame,shake) {
        var angle = 0;

        // draw body
        var draw = function(angle) {
            //angle = Math.PI/6*frame;
            drawPacmanSprite(ctx,x,y,dirEnum,angle,undefined,undefined,undefined,undefined,"#47b8ff");
        };
        if (frame == 0) {
            // closed
            draw(0);
        }
        else if (frame == 1) {
            // open
            angle = Math.atan(4/5);
            draw(angle);
            angle = Math.atan(4/8); // angle for drawing eye
        }
        else if (frame == 2) {
            // wide
            angle = Math.atan(6/3);
            draw(angle);
            angle = Math.atan(6/6); // angle for drawing eye
        }

        ctx.save();
        ctx.translate(x,y);

        // reflect or rotate sprite according to current direction
        var d90 = Math.PI/2;
        if (dirEnum == DIR_UP)
            ctx.rotate(-d90);
        else if (dirEnum == DIR_DOWN)
            ctx.rotate(d90);
        else if (dirEnum == DIR_LEFT)
            ctx.scale(-1,1);

        var x = -4; // pivot point
        var y = -3.5;
        var r1 = 3;   // distance from pivot of first eye
        var r2 = 6; // distance from pivot of second eye
        angle /= 3; // angle from pivot point
        angle += Math.PI/8;
        var c = Math.cos(angle);
        var s = Math.sin(angle);

        if (shake) {
            if (frame != prevFrame) {
                movePupils();
            }
            prevFrame = frame;
        }

        // second eyeball
        ctx.beginPath();
        ctx.arc(x+r2*c, y-r2*s, er, 0, Math.PI*2);
        ctx.fillStyle = "#FFF";
        ctx.fill();
        // second pupil
        ctx.beginPath();
        ctx.arc(x+r2*c+sx2, y-r2*s+sy2, pr, 0, Math.PI*2);
        ctx.fillStyle = "#000";
        ctx.fill();

        // first eyeball
        ctx.beginPath();
        ctx.arc(x+r1*c, y-r1*s, er, 0, Math.PI*2);
        ctx.fillStyle = "#FFF";
        ctx.fill();
        // first pupil
        ctx.beginPath();
        ctx.arc(x+r1*c+sx1, y-r1*s+sy1, pr, 0, Math.PI*2);
        ctx.fillStyle = "#000";
        ctx.fill();

        ctx.restore();

    };
})();

////////////////////////////////////////////////////////////////////
// FRUIT SPRITES

var drawCherry = function(ctx,x,y) {

    // cherry
    var cherry = function(x,y) {
        ctx.save();
        ctx.translate(x,y);

        // red fruit
        ctx.beginPath();
        ctx.arc(2.5,2.5,3,0,Math.PI*2);
        ctx.lineWidth = 1.0;
        ctx.strokeStyle = "#000";
        ctx.stroke();
        ctx.fillStyle = "#ff0000";
        ctx.fill();

        // white shine
        ctx.lineCap = 'round';
        ctx.beginPath();
        ctx.moveTo(1,3);
        ctx.lineTo(2,4);
        ctx.strokeStyle = "#fff";
        ctx.stroke();
        ctx.restore();
    };

    ctx.save();
    ctx.translate(x,y);

    // draw both cherries
    cherry(-6,-1);
    cherry(-1,1);

    // draw stems
    ctx.beginPath();
    ctx.moveTo(-3,0);
    ctx.bezierCurveTo(-1,-2, 2,-4, 5,-5);
    ctx.lineTo(5,-4);
    ctx.bezierCurveTo(3,-4, 1,0, 1,2);
    ctx.strokeStyle = "#ff9900";
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';
    ctx.stroke();

    ctx.restore();
};

var drawStrawberry = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // red body
    ctx.beginPath();
    ctx.moveTo(-1,-4);
    ctx.bezierCurveTo(-3,-4,-5,-3, -5,-1);
    ctx.bezierCurveTo(-5,3,-2,5, 0,6);
    ctx.bezierCurveTo(3,5, 5,2, 5,0);
    ctx.bezierCurveTo(5,-3, 3,-4, 0,-4);
    ctx.fillStyle = "#f00";
    ctx.fill();
    ctx.strokeStyle = "#f00";
    ctx.stroke();

    // white spots
    var spots = [
        {x:-4,y:-1},
        {x:-3,y:2 },
        {x:-2,y:0 },
        {x:-1,y:4 },
        {x:0, y:2 },
        {x:0, y:0 },
        {x:2, y:4 },
        {x:2, y:-1 },
        {x:3, y:1 },
        {x:4, y:-2 } ];

    ctx.fillStyle = "#fff";
    var i,len;
    for (i=0, len=spots.length; i<len; i++) {
        var s = spots[i];
        ctx.beginPath();
        ctx.arc(s.x,s.y,0.75,0,2*Math.PI);
        ctx.fill();
    }

    // green leaf
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.lineTo(-3,-4);
    ctx.lineTo(0,-4);
    ctx.lineTo(-2,-3);
    ctx.lineTo(-1,-3);
    ctx.lineTo(0,-4);
    ctx.lineTo(0,-2);
    ctx.lineTo(0,-4);
    ctx.lineTo(1,-3);
    ctx.lineTo(2,-3);
    ctx.lineTo(0,-4);
    ctx.lineTo(3,-4);
    ctx.closePath();
    ctx.strokeStyle = "#00ff00";
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke();

    // stem
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.lineTo(0,-5);
    ctx.lineCap = 'round';
    ctx.strokeStyle = "#fff";
    ctx.stroke();
    ctx.restore();
};

var drawOrange = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // orange body
    ctx.beginPath();
    ctx.moveTo(-2,-2);
    ctx.bezierCurveTo(-3,-2, -5,-1, -5,1);
    ctx.bezierCurveTo(-5,4, -3,6, 0,6);
    ctx.bezierCurveTo(3,6, 5,4, 5,1);
    ctx.bezierCurveTo(5,-1, 3,-2, 2,-2);
    ctx.closePath();
    ctx.fillStyle="#ffcc33";
    ctx.fill();
    ctx.strokeStyle = "#ffcc33";
    ctx.stroke();

    // stem
    ctx.beginPath();
    ctx.moveTo(-1,-1);
    ctx.quadraticCurveTo(-1,-2,-2,-2);
    ctx.quadraticCurveTo(-1,-2,-1,-4);
    ctx.quadraticCurveTo(-1,-2,0,-2);
    ctx.quadraticCurveTo(-1,-2,-1,-1);
    ctx.strokeStyle = "#ff9900";
    ctx.lineJoin = 'round';
    ctx.stroke();

    // green leaf
    ctx.beginPath();
    ctx.moveTo(-0.5,-4);
    ctx.quadraticCurveTo(0,-5,1,-5);
    ctx.bezierCurveTo(2,-5, 3,-4,4,-4);
    ctx.bezierCurveTo(3,-4, 3,-3, 2,-3);
    ctx.bezierCurveTo(1,-3,1,-4,-0.5,-4);
    ctx.strokeStyle = "#00ff00";
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke();
    ctx.fillStyle = "#00ff00";
    ctx.fill();

    ctx.restore();
};

var drawApple = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // red fruit
    ctx.beginPath();
    ctx.moveTo(-2,-3);
    ctx.bezierCurveTo(-2,-4,-3,-4,-4,-4);
    ctx.bezierCurveTo(-5,-4,-6,-3,-6,0);
    ctx.bezierCurveTo(-6,3,-4,6,-2.5,6);
    ctx.quadraticCurveTo(-1,6,-1,5);
    ctx.bezierCurveTo(-1,6,0,6,1,6);
    ctx.bezierCurveTo(3,6, 5,3, 5,0);
    ctx.bezierCurveTo(5,-3, 3,-4, 2,-4);
    ctx.quadraticCurveTo(0,-4,0,-3);
    ctx.closePath();
    ctx.fillStyle = "#ff0000";
    ctx.fill();

    // stem
    ctx.beginPath();
    ctx.moveTo(-1,-3);
    ctx.quadraticCurveTo(-1,-5, 0,-5);
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#ff9900';
    ctx.stroke();

    // shine
    ctx.beginPath();
    ctx.moveTo(2,3);
    ctx.quadraticCurveTo(3,3, 3,1);
    ctx.lineCap = 'round';
    ctx.strokeStyle = "#fff";
    ctx.stroke();

    ctx.restore();
};

var drawMelon = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // draw body
    ctx.beginPath();
    ctx.arc(0,2,5.5,0,Math.PI*2);
    ctx.fillStyle = "#7bf331";
    ctx.fill();

    // draw stem
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.lineTo(0,-5);
    ctx.moveTo(2,-5);
    ctx.quadraticCurveTo(-3,-5,-3,-6);
    ctx.strokeStyle="#69b4af";
    ctx.lineCap = "round";
    ctx.stroke();

    // dark lines
    /*
    ctx.beginPath();
    ctx.moveTo(0,-2);
    ctx.lineTo(-4,2);
    ctx.lineTo(-1,5);
    ctx.moveTo(-3,-1);
    ctx.lineTo(-2,0);
    ctx.moveTo(-2,6);
    ctx.lineTo(1,3);
    ctx.moveTo(1,7);
    ctx.lineTo(3,5);
    ctx.lineTo(0,2);
    ctx.lineTo(3,-1);
    ctx.moveTo(2,0);
    ctx.lineTo(4,2);
    ctx.strokeStyle="#69b4af";
    ctx.lineCap = "round";
    ctx.lineJoin = 'round';
    ctx.stroke();
    */
    // dark spots
    var spots = [
        0,-2,
        -1,-1,
        -2,0,
        -3,1,
        -4,2,
        -3,3,
        -2,4,
        -1,5,
        -2,6,
        -3,-1,
        1,7,
        2,6,
        3,5,
        2,4,
        1,3,
        0,2,
        1,1,
        2,0,
        3,-1,
        3,1,
        4,2,
         ];

    ctx.fillStyle="#69b4af";
    var i,len;
    for (i=0, len=spots.length; i<len; i+=2) {
        var x = spots[i];
        var y = spots[i+1];
        ctx.beginPath();
        ctx.arc(x,y,0.65,0,2*Math.PI);
        ctx.fill();
    }

    // white spots
    var spots = [
        {x: 0,y:-3},
        {x:-2,y:-1},
        {x:-4,y: 1},
        {x:-3,y: 3},
        {x: 1,y: 0},
        {x:-1,y: 2},
        {x:-1,y: 4},
        {x: 3,y: 2},
        {x: 1,y: 4},
         ];

    ctx.fillStyle = "#fff";
    var i,len;
    for (i=0, len=spots.length; i<len; i++) {
        var s = spots[i];
        ctx.beginPath();
        ctx.arc(s.x,s.y,0.65,0,2*Math.PI);
        ctx.fill();
    }

    ctx.restore();
};

var drawGalaxian = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // draw yellow body
    ctx.beginPath();
    ctx.moveTo(-4,-2);
    ctx.lineTo(4,-2);
    ctx.lineTo(4,-1);
    ctx.lineTo(2,1);
    ctx.lineTo(1,0);
    ctx.lineTo(0,0);
    ctx.lineTo(0,5);
    ctx.lineTo(0,0);
    ctx.lineTo(-1,0);
    ctx.lineTo(-2,1);
    ctx.lineTo(-4,-1);
    ctx.closePath();
    ctx.lineJoin = 'round';
    ctx.strokeStyle = ctx.fillStyle = '#fffa36';
    ctx.fill();
    ctx.stroke();

    // draw red arrow head
    ctx.beginPath();
    ctx.moveTo(0,-5);
    ctx.lineTo(-3,-2);
    ctx.lineTo(-2,-2);
    ctx.lineTo(-1,-3);
    ctx.lineTo(0,-3);
    ctx.lineTo(0,-1);
    ctx.lineTo(0,-3);
    ctx.lineTo(1,-3);
    ctx.lineTo(2,-2);
    ctx.lineTo(3,-2);
    ctx.closePath();
    ctx.lineJoin = 'round';
    ctx.strokeStyle = ctx.fillStyle = "#f00";
    ctx.fill();
    ctx.stroke();

    // draw blue wings
    ctx.beginPath();
    ctx.moveTo(-5,-4);
    ctx.lineTo(-5,-1);
    ctx.lineTo(-2,2);
    ctx.moveTo(5,-4);
    ctx.lineTo(5,-1);
    ctx.lineTo(2,2);
    ctx.strokeStyle = "#00f";
    ctx.lineJoin = 'round';
    ctx.stroke();

    ctx.restore();
};

var drawBell = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // bell body
    ctx.beginPath();
    ctx.moveTo(-1,-5);
    ctx.bezierCurveTo(-4,-5,-6,1,-6,6);
    ctx.lineTo(5,6);
    ctx.bezierCurveTo(5,1,3,-5,0,-5);
    ctx.closePath();
    ctx.fillStyle = ctx.strokeStyle = "#fffa37";
    ctx.stroke();
    ctx.fill();

    // marks
    ctx.beginPath();
    ctx.moveTo(-4,4);
    ctx.lineTo(-4,3);
    ctx.moveTo(-3,1);
    ctx.quadraticCurveTo(-3,-2,-2,-2);
    ctx.moveTo(-1,-4);
    ctx.lineTo(0,-4);
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#000';
    ctx.stroke();

    // bell bottom
    ctx.beginPath();
    ctx.rect(-5.5,6,10,2);
    ctx.fillStyle = "#68b9fc";
    ctx.fill();
    ctx.beginPath();
    ctx.rect(-0.5,6,2,2);
    ctx.fillStyle = '#fff';
    ctx.fill();

    ctx.restore();
};

var drawKey = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // draw key metal
    ctx.beginPath();
    ctx.moveTo(-1,-2);
    ctx.lineTo(-1,5);
    ctx.moveTo(0,6);
    ctx.quadraticCurveTo(1,6,1,3);
    ctx.moveTo(1,4);
    ctx.lineTo(2,4);
    ctx.moveTo(1,1);
    ctx.lineTo(1,-2);
    ctx.moveTo(1,0);
    ctx.lineTo(2,0);
    ctx.lineCap = 'round';
    ctx.strokeStyle = '#fff';
    ctx.stroke();

    // draw key top
    ctx.beginPath();
    ctx.moveTo(0,-6);
    ctx.quadraticCurveTo(-3,-6,-3,-4);
    ctx.lineTo(-3,-2);
    ctx.lineTo(3,-2);
    ctx.lineTo(3,-4);
    ctx.quadraticCurveTo(3,-6, 0,-6);
    ctx.strokeStyle = ctx.fillStyle = "#68b9fc";
    ctx.fill();
    ctx.lineJoin = 'round';
    ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(1,-5);
    ctx.lineTo(-1,-5);
    ctx.lineCap = 'round';
    ctx.strokeStyle = "#000";
    ctx.stroke();

    ctx.restore();
};

var drawPretzel = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // bread
    ctx.beginPath();
    ctx.moveTo(-2,-5);
    ctx.quadraticCurveTo(-4,-6,-6,-4);
    ctx.quadraticCurveTo(-7,-2,-5,1);
    ctx.quadraticCurveTo(-3,4,0,5);
    ctx.quadraticCurveTo(5,5,5,-1);
    ctx.quadraticCurveTo(6,-5,3,-5);
    ctx.quadraticCurveTo(1,-5,0,-2);
    ctx.quadraticCurveTo(-2,3,-5,5);
    ctx.moveTo(1,1);
    ctx.quadraticCurveTo(3,4,4,6);
    ctx.lineWidth = 2.0;
    ctx.lineCap = 'round';
    ctx.strokeStyle = "#ffcc33";
    ctx.stroke();

    // salt
    var spots = [
        -5,-6,
        1,-6,
        4,-4,
        -5,0,
        -2,0,
        6,1,
        -4,6,
        5,5,
         ];

    ctx.fillStyle = "#fff";
    var i,len;
    for (i=0, len=spots.length; i<len; i+=2) {
        var x = spots[i];
        var y = spots[i+1];
        ctx.beginPath();
        ctx.arc(x,y,0.65,0,2*Math.PI);
        ctx.fill();
    }

    ctx.restore();
};

var drawPear = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // body
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.bezierCurveTo(-1,-4,-2,-3,-2,-1);
    ctx.bezierCurveTo(-2,1,-4,2,-4,4);
    ctx.bezierCurveTo(-4,6,-2,7,0,7);
    ctx.bezierCurveTo(2,7,4,6,4,4);
    ctx.bezierCurveTo(4,2,2,1,2,-1);
    ctx.bezierCurveTo(2,-3,1,-4,0,-4);
    ctx.fillStyle = ctx.strokeStyle = "#00ff00";
    ctx.stroke();
    ctx.fill();

    // blue shine
    ctx.beginPath();
    ctx.moveTo(-2,3);
    ctx.quadraticCurveTo(-2,5,-1,5);
    ctx.strokeStyle = "#0033ff";
    ctx.lineCap = 'round';
    ctx.stroke();

    // white stem
    ctx.beginPath();
    ctx.moveTo(0,-4);
    ctx.quadraticCurveTo(0,-6,2,-6);
    ctx.strokeStyle = "#fff";
    ctx.lineCap = 'round';
    ctx.stroke();

    ctx.restore();
};

var drawBanana = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // body
    ctx.beginPath();
    ctx.moveTo(-5,5);
    ctx.quadraticCurveTo(-4,5,-2,6);
    ctx.bezierCurveTo(2,6,6,2,6,-4);
    ctx.lineTo(3,-3);
    ctx.lineTo(3,-2);
    ctx.lineTo(-4,5);
    ctx.closePath();
    ctx.fillStyle = ctx.strokeStyle = "#ffff00";
    ctx.stroke();
    ctx.fill();

    // stem
    ctx.beginPath();
    ctx.moveTo(4,-5);
    ctx.lineTo(5,-6);
    ctx.strokeStyle="#ffff00";
    ctx.lineCap='round';
    ctx.stroke();

    // black mark
    ctx.beginPath();
    ctx.moveTo(3,-1);
    ctx.lineTo(-2,4);
    ctx.strokeStyle = "#000";
    ctx.lineCap='round';
    ctx.stroke();

    // shine
    ctx.beginPath();
    ctx.moveTo(2,3);
    ctx.lineTo(0,5);
    ctx.strokeStyle = "#fff";
    ctx.lineCap='round';
    ctx.stroke();

    ctx.restore();
};

var drawCookie = function(ctx,x,y) {
    ctx.save();
    ctx.translate(x,y);

    // body
    ctx.beginPath();
    ctx.arc(0,0,6,0,Math.PI*2);
    ctx.fillStyle = "#f9bd6d";
    //ctx.fillStyle = "#dfab68";
    ctx.fill();

    // chocolate chips
    var spots = [
        0,-3,
        -4,-1,
        0,2,
        3,0,
        3,3,
         ];

    ctx.fillStyle = "#000";
    var i,len;
    for (i=0, len=spots.length; i<len; i+=2) {
        var x = spots[i];
        var y = spots[i+1];
        ctx.beginPath();
        ctx.arc(x,y,0.75,0,2*Math.PI);
        ctx.fill();
    }

    ctx.restore();
};

var getSpriteFuncFromFruitName = function(name) {
    var funcs = {
        'cherry': drawCherry,
        'strawberry': drawStrawberry,
        'orange': drawOrange,
        'apple': drawApple,
        'melon': drawMelon,
        'galaxian': drawGalaxian,
        'bell': drawBell,
        'key': drawKey,
        'pretzel': drawPretzel,
        'pear': drawPear,
        'banana': drawBanana,
        'cookie': drawCookie,
    };

    return funcs[name];
};

