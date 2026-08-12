
// REFERENCED GLOBALS:
// import { mapWidth, mapHeight } from './renderers.js';
// import { getRandomInt, getRandomColor } from './random.js';

const galagaStars = (function() {

    const stars = {};
    const numStars = 200;

    const width = mapWidth;
    const height = Math.floor(mapHeight*1.5);

    let ypos;
    const yspeed=-0.5;

    let t;
    const flickerPeriod = 120;
    const flickerSteps = 4;
    const flickerGap = flickerPeriod / flickerSteps;

    const init = function() {
        t = 0;
        ypos = 0;
        for (let i=0; i<numStars; i++) {
            stars[i] = {
                x: getRandomInt(0,width-1),
                y: getRandomInt(0,height-1),
                color: getRandomColor(),
                phase: getRandomInt(0,flickerPeriod-1),
            };
        }
    };

    const update = function() {
        t++;
        t %= flickerPeriod;

        ypos += yspeed;
        ypos %= height;
        if (ypos < 0) {
            ypos += height;
        }
    };

    const draw = function(ctx) {
        ctx.fillStyle = "#FFF";
        for (let i=0; i<numStars; i++) {
            const star = stars[i];
            const time = (t + star.phase) % flickerPeriod;
            if (time >= flickerGap) {
                const y = star.y - ypos;
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
