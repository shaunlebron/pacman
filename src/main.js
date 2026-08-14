
// REFERENCED GLOBALS:
/* global loadHighScores, gameMode, setGameMode, GAME_PACMAN, GAME_MSPACMAN, setPracticeMode -- game.js */
/* global initRenderer -- renderers.js */
/* global atlas -- atlas.js */
/* global initSwipe -- input.js */
/* global switchState, learnState, homeState, newGameState -- states.js */
/* global ghosts -- actors.js */
/* global executive -- executive.js */

//////////////////////////////////////////////////////////////////////////////////////
// Entry Point

window.addEventListener("load", function() {
    loadHighScores();
    initRenderer();
    atlas.create();
    initSwipe();
    const anchor = window.location.hash.substring(1);
    if (anchor == "learn") {
        switchState(learnState);
    }
    else if (anchor == "cheat_pac" || anchor == "cheat_mspac") {
        setGameMode((anchor == "cheat_pac") ? GAME_PACMAN : GAME_MSPACMAN);
        setPracticeMode(true);
        switchState(newGameState);
        for (const g of ghosts) {
            g.isDrawTarget = true;
            g.isDrawPath = true;
        }
    }
    else {
        switchState(homeState);
    }
    executive.init();
});
