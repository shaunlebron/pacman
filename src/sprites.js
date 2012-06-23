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


    return function(ctx,frame,dirEnum,scared,flash,eyes_only,color) {
        if (scared)
            color = energizer.isFlash() ? "#FFF" : "#2121ff";

        if (!eyes_only) {
            // draw body
            ctx.beginPath();
            addHead(ctx);
            if (frame == 0)
                addFeet1(ctx);
            else
                addFeet2(ctx);
            ctx.closePath();
            ctx.fillStyle = color;
            ctx.fill();
        }

        // draw face
        if (scared)
            addScaredFace(ctx, flash);
        else
            addEyes(ctx,dirEnum);
    };
})();

// draw pacman body
var drawPacmanSprite = function(ctx,dirEnum,angle,mouthShift,scale,centerShift,alpha) {

    if (mouthShift == undefined) mouthShift = 0;
    if (centerShift == undefined) centerShift = 0;
    if (scale == undefined) scale = 1;
    if (alpha == undefined) alpha = 1;

    ctx.save();

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

    ctx.fillStyle = "rgba(255,255,0," + alpha + ")";
    ctx.fill();

    ctx.restore();
};

var drawMsPacmanSprite = function(ctx,dirEnum,frame) {
    var angle = 0;

    // draw body
    if (frame == 0) {
        // closed
        drawPacmanSprite(ctx,dirEnum,0);
    }
    else if (frame == 1) {
        // open
        angle = Math.atan(4/5);
        drawPacmanSprite(ctx,dirEnum,angle);
        angle = Math.atan(4/8); // angle for drawing eye
    }
    else if (frame == 2) {
        // wide
        angle = Math.atan(6/3);
        drawPacmanSprite(ctx,dirEnum,angle);
        angle = Math.atan(6/6); // angle for drawing eye
    }
    ctx.fillStyle = pacman.color;
    ctx.fill();

    ctx.save();

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

    return function(ctx,dirEnum,frame,shake) {
        var angle = 0;

        // draw body
        if (frame == 0) {
            // closed
            drawPacmanSprite(ctx,dirEnum,0);
        }
        else if (frame == 1) {
            // open
            angle = Math.atan(4/5);
            drawPacmanSprite(ctx,dirEnum,angle);
            angle = Math.atan(4/8); // angle for drawing eye
        }
        else if (frame == 2) {
            // wide
            angle = Math.atan(6/3);
            drawPacmanSprite(ctx,dirEnum,angle);
            angle = Math.atan(6/6); // angle for drawing eye
        }
        ctx.fillStyle = "#47b8ff";
        ctx.fill();

        ctx.save();

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
        angle *= 0.5; // angle from pivot point
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
