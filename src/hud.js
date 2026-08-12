
// REFERENCED GLOBALS:
// import { inGameMenu } from './inGameMenu.js';
// import { vcr } from './vcr.js';
// import { state, playState, newGameState, readyNewState, readyRestartState, finishState, deadState, overState } from './states.js';

const hud = (function(){

    let on = false;

    return {

        update: function() {
            const valid = this.isValidState();
            if (valid != on) {
                on = valid;
                if (on) {
                    inGameMenu.onHudEnable();
                    vcr.onHudEnable();
                }
                else {
                    inGameMenu.onHudDisable();
                    vcr.onHudDisable();
                }
            }
        },
        draw: function(ctx) {
            inGameMenu.draw(ctx);
            vcr.draw(ctx);
        },
        isValidState: function() {
            return (
                state == playState ||
                state == newGameState ||
                state == readyNewState ||
                state == readyRestartState ||
                state == finishState ||
                state == deadState ||
                state == overState);
        },
    };

})();
