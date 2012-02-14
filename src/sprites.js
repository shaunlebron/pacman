//////////////////////////////////////////////////////////////////////////////////////
// Sprites
// (sprites are created using canvas paths)

// add top of the ghost head to the current canvas path
var addGhostHead = (function() {

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

        // draw lines between pixel coordinates
        ctx.moveTo(coords[0],coords[1]);
        for (i=2; i<coords.length; i+=2)
            ctx.lineTo(coords[i],coords[i+1]);

        ctx.restore();
    };
})();

// add first ghost animation frame feet to the current canvas path
var addGhostFeet1 = (function(){

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
var addGhostFeet2 = (function(){

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
var addGhostEyes = function(ctx,dirEnum){
    var i;

    ctx.save();
    ctx.translate(2,3);

    // translate eye balls to correct position
    if (dirEnum == DIR_LEFT) ctx.translate(-1,0);
    else if (dirEnum == DIR_RIGHT) ctx.translate(1,0);
    else if (dirEnum == DIR_UP) ctx.translate(0,-1);
    else if (dirEnum == DIR_DOWN) ctx.translate(0,1);

    // draw eye balls
    ctx.fillStyle = "#FFF";
    ctx.fillRect(1,0,2,5); // left
    ctx.fillRect(0,1,4,3);
    ctx.translate(6,0);
    ctx.fillRect(1,0,2,5); // right
    ctx.fillRect(0,1,4,3);

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
var addScaredGhostFace = function(ctx,flash){
    ctx.fillStyle = flash ? "#F00" : "#FF0";

    // eyes
    ctx.fillRect(4,5,2,2);
    ctx.fillRect(8,5,2,2);

    // mouth
    ctx.fillRect(1,10,1,1);
    ctx.fillRect(12,10,1,1);
    ctx.fillRect(2,9,2,1);
    ctx.fillRect(6,9,2,1);
    ctx.fillRect(10,9,2,1);
    ctx.fillRect(4,10,2,1);
    ctx.fillRect(8,10,2,1);
};

// draw pacman body
var addPacmanBody = function(ctx,dirEnum,angle,mouthShift,scale,centerShift) {

    if (mouthShift == undefined) mouthShift = 0;
    if (centerShift == undefined) centerShift = 0;
    if (scale == undefined) scale = 1;

    ctx.save();

    // rotate to current heading direction
    var d90 = Math.PI/2;
    if (dirEnum == DIR_UP) ctx.rotate(3*d90);
    else if (dirEnum == DIR_RIGHT) ctx.rotate(0);
    else if (dirEnum == DIR_DOWN) ctx.rotate(d90);
    else if (dirEnum == DIR_LEFT) ctx.rotate(2*d90);

    // plant corner of mouth
    ctx.moveTo(-3+mouthShift,0);

    // draw head outline
    ctx.arc(centerShift,0,6.5*scale,angle,2*Math.PI-angle);

    ctx.restore();
};
