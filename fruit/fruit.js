
var fruit = (function(){

    var BOUNCE_UP = 0;
    var BOUNCE_RIGHT = 1;
    var BOUNCE_LEFT = 2;
    var BOUNCE_DOWN = 3;

    var bounce_frames = (function(){
        var U = { dx:0, dy:-1 };
        var D = { dx:0, dy:1 };
        var L = { dx:-1, dy:0 };
        var R = { dx:1, dy:0 };
        var UL = { dx:-1, dy:-1 };
        var UR = { dx:1, dy:-1 };
        var DL = { dx:-1, dy:1 };
        var DR = { dx:1, dy:1 };
        var Z = { dx:0, dy:0 };

        var list = {};
        list[BOUNCE_UP] =    [U, U, U, U, U, U, U, U, U, Z, U, Z, Z, D, Z, D];
        list[BOUNCE_RIGHT] = [Z, UR,Z, R, Z, UR,Z, R, Z, R, Z, R, Z, DR,DR,Z];
        list[BOUNCE_LEFT] =  [Z, Z, UL,Z, L, Z, UL,Z, L, Z, L, Z, L, Z, DL,DL];
        list[BOUNCE_DOWN] =  [Z, D, D, D, D, D, D, D, D, D, D, D, U, U, Z, U];
        return list;
    })();

    var pen_path = 
    var pen_path_segments = [0x1d];

    var paths = (function() {

        var list = {};
        list[0] = {};

    })();
})();
