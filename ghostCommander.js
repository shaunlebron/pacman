// Ghost Commander

// Determines when a ghost should be chasing a target

var ghostCommander = (function() {

    // get new ghost command from frame count
    var getNewCommand = (function(){
        var t;
        var times = [{},{},{}];
        // level 1
        times[0][t=7*60] = GHOST_CMD_CHASE;
        times[0][t+=20*60] = GHOST_CMD_SCATTER;
        times[0][t+=7*60] = GHOST_CMD_CHASE;
        times[0][t+=20*60] = GHOST_CMD_SCATTER;
        times[0][t+=5*60] = GHOST_CMD_CHASE;
        times[0][t+=20*60] = GHOST_CMD_SCATTER;
        times[0][t+=5*60] = GHOST_CMD_CHASE;
        // level 2-4
        times[1][t=7*60] = GHOST_CMD_CHASE;
        times[1][t+=20*60] = GHOST_CMD_SCATTER;
        times[1][t+=7*60] = GHOST_CMD_CHASE;
        times[1][t+=20*60] = GHOST_CMD_SCATTER;
        times[1][t+=5*60] = GHOST_CMD_CHASE;
        times[1][t+=1033*60] = GHOST_CMD_SCATTER;
        times[1][t+=1] = GHOST_CMD_CHASE;
        // level 5+
        times[2][t=7*60] = GHOST_CMD_CHASE;
        times[2][t+=20*60] = GHOST_CMD_SCATTER;
        times[2][t+=7*60] = GHOST_CMD_CHASE;
        times[2][t+=20*60] = GHOST_CMD_SCATTER;
        times[2][t+=5*60] = GHOST_CMD_CHASE;
        times[2][t+=1037*60] = GHOST_CMD_SCATTER;
        times[2][t+=1] = GHOST_CMD_CHASE;

        return function(frame) {
            var i;
            if (game.level == 1)
                i = 0;
            else if (game.level >= 2 && game.level <= 4)
                i = 1;
            else
                i = 2;
            return times[i][frame];
        };
    })();

    var count;
    var command;

    return {
        reset: function() { 
            command = GHOST_CMD_CHASE;
            count = 0;
        },
        update: function() {
            var newCmd;
            if (!energizer.isActive()) {
                newCmd = getNewCommand(count);
                if (newCmd != undefined) {
                    command = newCmd;
                    for (i=0; i<4; i++)
                        actors[i].reverse();
                }
                count++;
            }
        },
        getCommand: function() {
            return command; 
        },
    };
})();

