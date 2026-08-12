
// REFERENCED GLOBALS:
// import { Ghost, GHOST_OUTSIDE, GHOST_PACING_HOME, GHOST_LEAVING_HOME } from './Ghost.js';
// import { Player } from './Player.js';
// import { tileSize, midTile } from './Map.js';
// import { DIR_LEFT, DIR_DOWN, DIR_UP } from './direction.js';

//////////////////////////////////////////////////////////////////////////////////////
// create all the actors

const blinky = new Ghost();
blinky.name = "blinky";
blinky.color = "#FF0000";
blinky.pathColor = "rgba(255,0,0,0.8)";
blinky.isVisible = true;

const pinky = new Ghost();
pinky.name = "pinky";
pinky.color = "#FFB8FF";
pinky.pathColor = "rgba(255,184,255,0.8)";
pinky.isVisible = true;

const inky = new Ghost();
inky.name = "inky";
inky.color = "#00FFFF";
inky.pathColor = "rgba(0,255,255,0.8)";
inky.isVisible = true;

const clyde = new Ghost();
clyde.name = "clyde";
clyde.color = "#FFB851";
clyde.pathColor = "rgba(255,184,81,0.8)";
clyde.isVisible = true;

const pacman = new Player();
pacman.name = "pacman";
pacman.color = "#FFFF00";
pacman.pathColor = "rgba(255,255,0,0.8)";

// order at which they appear in original arcade memory
// (suggests drawing/update order)
const actors = [blinky, pinky, inky, clyde, pacman];
const ghosts = [blinky, pinky, inky, clyde];
