
var galagaStars = (function() {

    var stars = {};
    var numStars = 200;

    var width = mapWidth;
    var height = Math.floor(mapHeight*1.5);

    var ypos;
    var yspeed=-0.5;

    var t;
    var flickerPeriod = 120;
    var flickerSteps = 4;
    var flickerGap = flickerPeriod / flickerSteps;

    var init = function() {
        t = 0;
        ypos = 0;
        var i;
        for (i=0; i<numStars; i++) {
            stars[i] = {
                x: getRandomInt(0,width-1),
                y: getRandomInt(0,height-1),
                color: getRandomColor(),
                phase: getRandomInt(0,flickerPeriod-1),
            };
        }
    };

    var update = function() {
        t++;
        t %= flickerPeriod;

        ypos += yspeed;
        ypos %= height;
        if (ypos < 0) {
            ypos += height;
        }
    };

    var draw = function(ctx) {
        var i;
        var star;
        var time;
        var y;
        ctx.fillStyle = "#FFF";
        for (i=0; i<numStars; i++) {
            star = stars[i];
            time = (t + star.phase) % flickerPeriod;
            if (time >= flickerGap) {
                y = star.y - ypos;
                if (y < 0) {
                    y += height;
                }
                ctx.fillStyle = star.color;
                ctx.fillRect(star.x, y, 1,1);
            }
        }
    };

    return {
        init: init,
        draw: draw,
        update: update,
    };

})();
