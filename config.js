// Config

// sets map, fruit position, actor starting positions for a given configuration

var config = {

    // set configuration to original arcade Pac-Man
    setOriginal: function() {

        tileMap = new TileMap(28, 36, (
            "____________________________" +
            "____________________________" +
            "____________________________" +
            "||||||||||||||||||||||||||||" +
            "|............||............|" +
            "|.||||.|||||.||.|||||.||||.|" +
            "|o|__|.|___|.||.|___|.|__|o|" +
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

        // apply ghost turning constraints to this map
        tileMap.constrainGhostTurns = function(x,y,openTiles) {
            // prevent ghost from turning up at these tiles
            if ((x == 12 || x == 15) && (y == 14 || y == 26)) {
                openTiles[DIR_UP] = false;
            }
        };

        // row for the displayed message
        tileMap.messageRow = 22;

        // location of the fruit
        var fruitTile = {x:13, y:20};
        fruit.setPosition(tileSize*(1+fruitTile.x)-1, tileSize*fruitTile.y + midTile.y);

        // actor starting states

        blinky.startDirEnum = DIR_LEFT;
        blinky.startPixel.x = 14*tileSize-1;
        blinky.startPixel.y = 14*tileSize+midTile.y;
        blinky.cornerTile.x = tileCols-1-2;
        blinky.cornerTile.y = 0;

        pinky.startDirEnum = DIR_DOWN;
        pinky.startPixel.x = 14*tileSize-1;
        pinky.startPixel.y = 17*tileSize+midTile.y;
        pinky.cornerTile.x = 2;
        pinky.cornerTile.y = 0;

        inky.startDirEnum = DIR_UP;
        inky.startPixel.x = 12*tileSize-1;
        inky.startPixel.y = 17*tileSize + midTile.y;
        inky.cornerTile.x = tileCols-1;
        inky.cornerTile.y = tileRows - 2;

        clyde.startDirEnum = DIR_UP;
        clyde.startPixel.x = 16*tileSize-1;
        clyde.startPixel.y = 17*tileSize + midTile.y;
        clyde.cornerTile.x = 0;
        clyde.cornerTile.y = tileRows-2;

        pacman.startDirEnum = DIR_LEFT;
        pacman.startPixel.x = tileSize*tileCols/2;
        pacman.startPixel.y = 26*tileSize + midTile.y;

        // ghost home location
        tileMap.doorTile = {x:13, y:14};
        tileMap.doorPixel = {
            x:(tileMap.doorTile.x+1)*tileSize-1, 
            y:tileMap.doorTile.y*tileSize + midTile.y
        };
        tileMap.homeTopPixel = 17*tileSize;
        tileMap.homeBottomPixel = 18*tileSize;

    };

};
