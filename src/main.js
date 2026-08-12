
// REFERENCED GLOBALS:
// import { loadHighScores, gameMode, setGameMode, GAME_PACMAN, GAME_MSPACMAN, setPracticeMode } from './game.js';
// import { initRenderer } from './renderers.js';
// import { atlas } from './atlas.js';
// import { initSwipe } from './input.js';
// import { switchState, learnState, homeState, newGameState } from './states.js';
// import { ghosts } from './actors.js';
// import { executive } from './executive.js';

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
