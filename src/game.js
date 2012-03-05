//////////////////////////////////////////////////////////////////////////////////////
// Game

// game modes
var GAME_PACMAN = 0;
var GAME_MSPACMAN = 1;

// current game mode
var gameMode = GAME_PACMAN;

// current level, lives, and score
var level = 1;
var extraLives = 0;
var highScore = 0;
var score = 0;

// state at the beginning of a level
// (saved so you can change to a different map with the same state at the beginning of the level)
var prevLevel;
var prevExtraLives;
var prevHighScore;
var prevScore;

var addScore = function(p) {
    if (score < 10000 && score+p >= 10000)
        extraLives++;
    score += p;
    if (score > highScore)
        highScore = score;
};

var backupStatus = function() {
    prevLevel = level;
    prevExtraLives = extraLives;
    prevHighScore = highScore;
    prevScore = score;
};

var restoreStatus = function() {
    level = prevLevel;
    extraLives = prevExtraLives;
    highScore = prevHighScore;
    score = prevScore;
};
