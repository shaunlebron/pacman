
// REFERENCED GLOBALS:
// import { level, addScore } from './game.js';
// import { ghosts } from './actors.js';

//////////////////////////////////////////////////////////////////////////////////////
// Energizer

// This handles how long the energizer lasts as well as how long the
// points will display after eating a ghost.

const energizer = (function() {

    // how many seconds to display points when ghost is eaten
    const pointsDuration = 1;

    // how long to stay energized based on current level
    const getDuration = (function(){
        const seconds = [6,5,4,3,2,5,2,2,1,5,2,1,1,3,1,1,0,1];
        return function() {
            const i = level;
            return (i > 18) ? 0 : 60*seconds[i-1];
        };
    })();

    // how many ghost flashes happen near the end of frightened mode based on current level
    const getFlashes = (function(){
        const flashes = [5,5,5,5,5,5,5,5,3,5,5,3,3,5,3,3,0,3];
        return function() {
            const i = level;
            return (i > 18) ? 0 : flashes[i-1];
        };
    })();

    // "The ghosts change colors every 14 game cycles when they start 'flashing'" -Jamey Pittman
    const flashInterval = 14;

    let count;  // how long in frames energizer has been active
    let active; // indicates if energizer is currently active
    let points; // points that the last eaten ghost was worth
    let pointsFramesLeft; // number of frames left to display points earned from eating ghost

    const savedCount = {};
    const savedActive = {};
    const savedPoints = {};
    const savedPointsFramesLeft = {};

    // save state at time t
    const save = function(t) {
        savedCount[t] = count;
        savedActive[t] = active;
        savedPoints[t] = points;
        savedPointsFramesLeft[t] = pointsFramesLeft;
    };

    // load state at time t
    const load = function(t) {
        count = savedCount[t];
        active = savedActive[t];
        points = savedPoints[t];
        pointsFramesLeft = savedPointsFramesLeft[t];
    };

    return {
        save: save,
        load: load,
        reset: function() {
            count = 0;
            active = false;
            points = 100;
            pointsFramesLeft = 0;
            for (const g of ghosts)
                g.scared = false;
        },
        update: function() {
            if (active) {
                if (count == getDuration())
                    this.reset();
                else
                    count++;
            }
        },
        activate: function() { 
            active = true;
            count = 0;
            points = 100;
            for (const g of ghosts) {
                g.onEnergized();
            }
            if (getDuration() == 0) { // if no duration, then immediately reset
                this.reset();
            }
        },
        isActive: function() { return active; },
        isFlash: function() { 
            const i = Math.floor((getDuration()-count)/flashInterval);
            return (i<=2*getFlashes()-1) ? (i%2==0) : false;
        },

        getPoints: function() {
            return points;
        },
        addPoints: function() {
            addScore(points*=2);
            pointsFramesLeft = pointsDuration*60;
        },
        showingPoints: function() { return pointsFramesLeft > 0; },
        updatePointsTimer: function() { if (pointsFramesLeft > 0) pointsFramesLeft--; },
    };
})();
