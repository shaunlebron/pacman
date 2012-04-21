//////////////////////////////////////////////////////////////////////////////////////
// Maps

// Definitions of playable maps along with respective actor configurations

// list of available maps
var map_list;

// current map
var map;

// switches to another map
var switchMap = function(i) {
    map = map_list[i];
    map.onLoad();
};

// create maps
(function() {

    // default onLoad function for a map
    // contains potentially map-specific locations
    var onLoad = function() {

        // ghost home location
        this.doorTile = {x:13, y:14};
        this.doorPixel = {
            x:(this.doorTile.x+1)*tileSize-1, 
            y:this.doorTile.y*tileSize + midTile.y
        };
        this.homeTopPixel = 17*tileSize;
        this.homeBottomPixel = 18*tileSize;

        // location of the fruit
        var fruitTile = {x:13, y:20};
        fruit.setPosition(tileSize*(1+fruitTile.x)-1, tileSize*fruitTile.y + midTile.y);

        // actor starting states

        blinky.startDirEnum = DIR_LEFT;
        blinky.startPixel = {
            x: 14*tileSize-1,
            y: 14*tileSize+midTile.y
        };
        blinky.cornerTile = {
            x: this.numCols-1-2,
            y: 0
        };
        blinky.startMode = GHOST_OUTSIDE;
        blinky.arriveHomeMode = GHOST_LEAVING_HOME;

        pinky.startDirEnum = DIR_DOWN;
        pinky.startPixel = {
            x: 14*tileSize-1,
            y: 17*tileSize+midTile.y,
        };
        pinky.cornerTile = {
            x: 2,
            y: 0
        };
        pinky.startMode = GHOST_PACING_HOME;
        pinky.arriveHomeMode = GHOST_PACING_HOME;

        inky.startDirEnum = DIR_UP;
        inky.startPixel = {
            x: 12*tileSize-1,
            y: 17*tileSize + midTile.y,
        };
        inky.cornerTile = {
            x: this.numCols-1,
            y: this.numRows - 2,
        };
        inky.startMode = GHOST_PACING_HOME;
        inky.arriveHomeMode = GHOST_PACING_HOME;

        clyde.startDirEnum = DIR_UP;
        clyde.startPixel = {
            x: 16*tileSize-1,
            y: 17*tileSize + midTile.y,
        };
        clyde.cornerTile = {
            x: 0,
            y: this.numRows-2,
        };
        clyde.startMode = GHOST_PACING_HOME;
        clyde.arriveHomeMode = GHOST_PACING_HOME;

        pacman.startDirEnum = DIR_LEFT;
        pacman.startPixel = {
            x: 14*tileSize-1,
            y: 26*tileSize + midTile.y,
        };
    };

    var onLoadPacman = function() {
        onLoad.call(this);
        gameMode = GAME_PACMAN;
    };

    var onLoadMsPacman = function() {
        onLoad.call(this);
        gameMode = GAME_MSPACMAN;
    };

    // Original Pac-Man map
    var mapPacman = new Map(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "|............||............|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|o||||.|||||.||.|||||.||||o|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|..........................|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|......||....||....||......|" +
        "||||||.||||| || |||||.||||||" +
        "_____|.||||| || |||||.|_____" +
        "_____|.||          ||.|_____" +
        "_____|.|| |||--||| ||.|_____" +
        "||||||.|| |______| ||.||||||" +
        "      .   |______|   .      " +
        "||||||.|| |______| ||.||||||" +
        "_____|.|| |||||||| ||.|_____" +
        "_____|.||          ||.|_____" +
        "_____|.|| |||||||| ||.|_____" +
        "||||||.|| |||||||| ||.||||||" +
        "|............||............|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|o..||.......  .......||..o|" +
        "|||.||.||.||||||||.||.||.|||" +
        "|||.||.||.||||||||.||.||.|||" +
        "|......||....||....||......|" +
        "|.||||||||||.||.||||||||||.|" +
        "|.||||||||||.||.||||||||||.|" +
        "|..........................|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));

    mapPacman.name = "Pac-Man";
    mapPacman.onLoad = onLoadPacman;
    //mapPacman.wallStrokeColor = "#47b897"; // from Pac-Man Plus
    mapPacman.wallStrokeColor = "#2121ff"; // from original
    mapPacman.wallFillColor = "#000";
    mapPacman.pelletColor = "#ffb8ae";
    mapPacman.constrainGhostTurns = function(tile,openTiles) {
        // prevent ghost from turning up at these tiles
        if ((tile.x == 12 || tile.x == 15) && (tile.y == 14 || tile.y == 26)) {
            openTiles[DIR_UP] = false;
        }
    };

    // Ms. Pac-Man map 1

    var mapMsPacman1 = new Map(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "|......||..........||......|" +
        "|o||||.||.||||||||.||.||||o|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|..........................|" +
        "|||.||.|||||.||.|||||.||.|||" +
        "__|.||.|||||.||.|||||.||.|__" +
        "|||.||.|||||.||.|||||.||.|||" +
        "   .||.......||.......||.   " +
        "|||.||||| |||||||| |||||.|||" +
        "__|.||||| |||||||| |||||.|__" +
        "__|.                    .|__" +
        "__|.||||| |||--||| |||||.|__" +
        "__|.||||| |______| |||||.|__" +
        "__|.||    |______|    ||.|__" +
        "__|.|| || |______| || ||.|__" +
        "|||.|| || |||||||| || ||.|||" +
        "   .   ||          ||   .   " +
        "|||.|||||||| || ||||||||.|||" +
        "__|.|||||||| || ||||||||.|__" +
        "__|.......   ||   .......|__" +
        "__|.|||||.||||||||.|||||.|__" +
        "|||.|||||.||||||||.|||||.|||" +
        "|............  ............|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|.||||.||....||....||.||||.|" +
        "|o||||.||.||||||||.||.||||o|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|..........................|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));

    mapMsPacman1.name = "Ms. Pac-Man 1";
    mapMsPacman1.onLoad = onLoadMsPacman;
    mapMsPacman1.wallFillColor = "#FFB8AE";
    mapMsPacman1.wallStrokeColor = "#FF0000";
    mapMsPacman1.pelletColor = "#dedeff";

    // Ms. Pac-Man map 2

    var mapMsPacman2 = new Map(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "       ||..........||       " +
        "|||||| ||.||||||||.|| ||||||" +
        "|||||| ||.||||||||.|| ||||||" +
        "|o...........||...........o|" +
        "|.|||||||.||.||.||.|||||||.|" +
        "|.|||||||.||.||.||.|||||||.|" +
        "|.||......||.||.||......||.|" +
        "|.||.|||| ||....|| ||||.||.|" +
        "|.||.|||| |||||||| ||||.||.|" +
        "|......|| |||||||| ||......|" +
        "||||||.||          ||.||||||" +
        "||||||.|| |||--||| ||.||||||" +
        "|......|| |______| ||......|" +
        "|.||||.|| |______| ||.||||.|" +
        "|.||||.   |______|   .||||.|" +
        "|...||.|| |||||||| ||.||...|" +
        "|||.||.||          ||.||.|||" +
        "__|.||.|||| |||| ||||.||.|__" +
        "__|.||.|||| |||| ||||.||.|__" +
        "__|.........||||.........|__" +
        "__|.|||||||.||||.|||||||.|__" +
        "|||.|||||||.||||.|||||||.|||" +
        "   ....||...    ...||....   " +
        "|||.||.||.||||||||.||.||.|||" +
        "|||.||.||.||||||||.||.||.|||" +
        "|o..||.......||.......||..o|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|..........................|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));

    mapMsPacman2.name = "Ms. Pac-Man 2";
    mapMsPacman2.onLoad = onLoadMsPacman;
    mapMsPacman2.wallFillColor = "#47b8ff";
    mapMsPacman2.wallStrokeColor = "#dedeff";
    mapMsPacman2.pelletColor = "#ffff00";

    // Ms. Pac-Man map 3

    var mapMsPacman3 = new Map(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "|.........||....||.........|" +
        "|o|||||||.||.||.||.|||||||o|" +
        "|.|||||||.||.||.||.|||||||.|" +
        "|.||.........||.........||.|" +
        "|.||.||.||||.||.||||.||.||.|" +
        "|....||.||||.||.||||.||....|" +
        "||||.||.||||.||.||||.||.||||" +
        "||||.||..............||.||||" +
        " ....|||| |||||||| ||||.... " +
        "|.|| |||| |||||||| |||| ||.|" +
        "|.||                    ||.|" +
        "|.|||| || |||--||| || ||||.|" +
        "|.|||| || |______| || ||||.|" +
        "|.     || |______| ||     .|" +
        "|.|| |||| |______| |||| ||.|" +
        "|.|| |||| |||||||| |||| ||.|" +
        "|.||                    ||.|" +
        "|.|||| ||||| || ||||| ||||.|" +
        "|.|||| ||||| || ||||| ||||.|" +
        "|......||....||....||......|" +
        "|||.||.||.||||||||.||.||.|||" +
        "|||.||.||.||||||||.||.||.|||" +
        "|o..||.......  .......||..o|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|.||||.|||||.||.|||||.||||.|" +
        "|......||....||....||......|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|......||..........||......|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));

    mapMsPacman3.name = "Ms. Pac-Man 3";
    mapMsPacman3.onLoad = onLoadMsPacman;
    mapMsPacman3.wallFillColor = "#de9751";
    mapMsPacman3.wallStrokeColor = "#dedeff";
    mapMsPacman3.pelletColor = "#ff0000";

    // Ms. Pac-Man map 4

    var mapMsPacman4 = new Map(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "|..........................|" +
        "|.||.||||.||||||||.||||.||.|" +
        "|o||.||||.||||||||.||||.||o|" +
        "|.||.||||.||....||.||||.||.|" +
        "|.||......||.||.||......||.|" +
        "|.||||.||.||.||.||.||.||||.|" +
        "|.||||.||.||.||.||.||.||||.|" +
        "|......||....||....||......|" +
        "|||.|||||||| || ||||||||.|||" +
        "__|.|||||||| || ||||||||.|__" +
        "__|....||          ||....|__" +
        "||| ||.|| |||--||| ||.|| |||" +
        "    ||.|| |______| ||.||    " +
        "||||||.   |______|   .||||||" +
        "||||||.|| |______| ||.||||||" +
        "    ||.|| |||||||| ||.||    " +
        "||| ||.||          ||.|| |||" +
        "__|....||||| || |||||....|__" +
        "__|.||.||||| || |||||.||.|__" +
        "__|.||....   ||   ....||.|__" +
        "__|.|||||.|| || ||.|||||.|__" +
        "|||.|||||.|| || ||.|||||.|||" +
        "|.........||    ||.........|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|.||...||..........||...||.|" +
        "|o||.|||||||.||.|||||||.||o|" +
        "|.||.|||||||.||.|||||||.||.|" +
        "|............||............|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));

    mapMsPacman4.name = "Ms. Pac-Man 4";
    mapMsPacman4.onLoad = onLoadMsPacman;
    mapMsPacman4.wallFillColor = "#2121ff";
    mapMsPacman4.wallStrokeColor = "#ffb851";
    mapMsPacman4.pelletColor = "#dedeff";

    // Empty Map

    var mapSketch = new Map(28, 36, (
        "____________________________" +
        "____________________________" +
        "______||||||||||||||||______" +
        "______|..............|______" +
        "______|.||.||||||.||.|______" +
        "______|.||.||||||.||.|______" +
        "______|.||...||...||.|______" +
        "______|.||||.||.||||.|______" +
        "|||||||.||||.||.||||.|||||||" +
        "|.......||........||.......|" +
        "|||.||||||.||||||.||||||.|||" +
        "|||.||||||.||||||.||||||.|||" +
        "|.......||...||...||.......|" +
        "|.|||||.||||.||.||||.|||||.|" +
        "|.|||||.||||.||.||||.|||||.|" +
        "|....||..............||....|" +
        "||||.||||.|||--|||.||||.||||" +
        "||||.||||.|______|.||||.||||" +
        "..||......|______|......||.." +
        "|.||.||||.|______|.||||.||.|" +
        "|....||||.||||||||.||||....|" +
        "|.||.||..............||.||.|" +
        "|.||.||.||||||||||||.||.||.|" +
        "|.||.||.||||||||||||.||.||.|" +
        "..||.||......||......||.||.." +
        "||||.|||||||.||.|||||||.||||" +
        "||||.|||||||.||.|||||||.||||" +
        "|..........................|" +
        "|.||.||||||||||||||||||.||.|" +
        "|.||.|________________|.||.|" +
        "|.||.|________________|.||.|" +
        "|.||.|________________|.||.|" +
        "|....|________________|....|" +
        "||||||________________||||||" +
        "____________________________"));

    mapSketch.name = "Iwatani's Sketch";
    mapSketch.onLoad = function() {
        // ghost home location
        this.doorTile = {x:13, y:15};
        this.doorPixel = {
            x:(this.doorTile.x+1)*tileSize-1, 
            y:this.doorTile.y*tileSize + midTile.y
        };
        this.homeTopPixel = 18*tileSize;
        this.homeBottomPixel = 19*tileSize;

        // location of the fruit (just hide it)
        var fruitTile = {x:-13, y:21};
        fruit.setPosition(tileSize*(1+fruitTile.x)-1, tileSize*fruitTile.y + midTile.y);

        // actor starting states

        blinky.startDirEnum = DIR_LEFT;
        blinky.startPixel = {
            x: 14*tileSize-1,
            y: 15*tileSize+midTile.y
        };
        blinky.cornerTile = {
            x: this.numCols-1-2,
            y: 0
        };
        blinky.startMode = GHOST_OUTSIDE;
        blinky.arriveHomeMode = GHOST_LEAVING_HOME;

        pinky.startDirEnum = DIR_DOWN;
        pinky.startPixel = {
            x: 14*tileSize-1,
            y: 18*tileSize+midTile.y,
        };
        pinky.cornerTile = {
            x: 2,
            y: 0
        };
        pinky.startMode = GHOST_PACING_HOME;
        pinky.arriveHomeMode = GHOST_PACING_HOME;

        inky.startDirEnum = DIR_UP;
        inky.startPixel = {
            x: 12*tileSize-1,
            y: 18*tileSize + midTile.y,
        };
        inky.cornerTile = {
            x: this.numCols-1,
            y: this.numRows - 2,
        };
        inky.startMode = GHOST_PACING_HOME;
        inky.arriveHomeMode = GHOST_PACING_HOME;

        clyde.startDirEnum = DIR_UP;
        clyde.startPixel = {
            x: 16*tileSize-1,
            y: 18*tileSize + midTile.y,
        };
        clyde.cornerTile = {
            x: 0,
            y: this.numRows-2,
        };
        clyde.startMode = GHOST_PACING_HOME;
        clyde.arriveHomeMode = GHOST_PACING_HOME;

        pacman.startDirEnum = DIR_LEFT;
        pacman.startPixel = {
            x: 14*tileSize-1,
            y: 27*tileSize + midTile.y,
        };

        gameMode = GAME_PACMAN;
    };
    mapSketch.wallFillColor = "#555";
    mapSketch.wallStrokeColor = "#fff";
    mapSketch.pelletColor = "#dedeff";

    // Generated Maps

    var mapGen1 = new Map(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "|.........||....||.........|" +
        "|.||.||||.||.||.||.||||.||.|" +
        "|.||.||||....||....||||.||.|" +
        "|.||...||.||||||||.||...||.|" +
        "|.||||.||.||||||||.||.||||.|" +
        "|.||||.||.||....||.||.||||.|" +
        "|.........||.||.||.........|" +
        "||||.||||.||.||.||.||||.||||" +
        "||||.|__|.||.||.||.|__|.||||" +
        "..||.||||.||.||.||.||||.||.." +
        "|.||....................||.|" +
        "|.||.||||.|||--|||.||||.||.|" +
        "|.||.||||.|______|.||||.||.|" +
        "|.........|______|.........|" +
        "|||||||||.|______|.|||||||||" +
        "|||||||||.||||||||.|||||||||" +
        "..||....................||.." +
        "|.||.||.||||.||.||||.||.||.|" +
        "|.||.||.||||.||.||||.||.||.|" +
        "|....||...||.||.||...||....|" +
        "|||||||||.||.||.||.|||||||||" +
        "|||||||||.||.||.||.|||||||||" +
        "|.........||....||.........|" +
        "|.|||||.||||.||.||||.|||||.|" +
        "|.|___|.||||.||.||||.|___|.|" +
        "|.|___|......||......|___|.|" +
        "|.|___|.||||||||||||.|___|.|" +
        "|.|||||.||||||||||||.|||||.|" +
        "|..........................|" +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________"));
    mapGen1.name = "Generated 1";
    mapGen1.onLoad = onLoadMsPacman;
    mapGen1.wallFillColor = "#AAA";
    mapGen1.wallStrokeColor = "#fff";
    mapGen1.pelletColor = "#DDD";

    // Menu Map

    var menuMap = new Map(28, 36, (
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "||||||||||||||||||||||||||||" +
        "                            " +
        "||||||||||||||||||||||||||||" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________" +
        "____________________________"));

    menuMap.onLoad = function() {

        var row = 12;

        ghostCommander.reset();
        blinky.startDirEnum = DIR_LEFT;
        blinky.startPixel = {
            x: 19*tileSize,
            y: row*tileSize+midTile.y
        };
        blinky.cornerTile = {
            x: this.numCols-1-2,
            y: 0
        };
        blinky.startMode = GHOST_OUTSIDE;

        pinky.startDirEnum = DIR_LEFT;
        pinky.startPixel = {
            x: 21*tileSize,
            y: row*tileSize + midTile.y,
        };
        pinky.cornerTile = {
            x: 2,
            y: 0
        };
        pinky.startMode = GHOST_OUTSIDE;

        clyde.startDirEnum = DIR_LEFT;
        clyde.startPixel = {
            x: 25*tileSize,
            y: row*tileSize+midTile.y,
        };
        clyde.cornerTile = {
            x: 8,
            y: 14,
        };
        clyde.startMode = GHOST_OUTSIDE;

        inky.startDirEnum = DIR_LEFT;
        inky.startPixel = {
            x: 23*tileSize,
            y: row*tileSize + midTile.y,
        };
        inky.cornerTile = {
            x: this.numCols-1,
            y: this.numRows - 2,
        };
        inky.startMode = GHOST_OUTSIDE;

        pacman.startPixel = { 
            x:14*tileSize+midTile.x, 
            y:-26*tileSize+midTile.y }; // offscreen
    };
    menuMap.wallFillColor = "#777";
    menuMap.wallStrokeColor = "#FFF";
    menuMap.pelletColor = "#FFF";

    // create list of maps
    map_list = [
        menuMap,
        mapPacman,
        mapMsPacman1,
        mapMsPacman2,
        mapMsPacman3,
        mapMsPacman4,
        mapSketch,
        mapGen1,
    ];

})();
