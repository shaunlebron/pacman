//////////////////////////////////////////////////////////////////////////////////////
// create all the actors

var blinky = new Ghost();
blinky.name = "blinky";
blinky.color = "#FF0000";

var pinky = new Ghost();
pinky.name = "pinky";
pinky.color = "#FFB8FF";

var inky = new Ghost();
inky.name = "inky";
inky.color = "#00FFFF";

var clyde = new Ghost();
clyde.name = "clyde";
clyde.color = "#FFB851";

var pacman = new Player();
pacman.name = "pacman";
pacman.color = "#FFFF00";

// order at which they appear in original arcade memory
// (suggests drawing/update order)
var actors = [blinky, pinky, inky, clyde, pacman];
