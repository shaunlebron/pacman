//////////////////////////////////////////////////////////////////////////////////////
// Game

// game modes
var GAME_PACMAN = 0;
var GAME_MSPACMAN = 1;

// current game mode
var gameMode = GAME_PACMAN;

// current level and lives left
var level = 1;
var extraLives = 0;

// scoring
var highScore = 0;
var score = 0;
var addScore = function(p) {
    if (score < 10000 && score+p >= 10000)
        extraLives++;
    score += p;
    if (score > highScore)
        highScore = score;
};
