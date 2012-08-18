////////////////////////////////////////////////////
// In-Game Menu
var inGameMenu = (function() {

    var w=tileSize*6,h=tileSize*2;

    var getMenu = function() {
        return practiceMode ? practiceMenu : menu;
    };
    var showMenu = function() {
        getMenu().enable();
    };
    var hideMenu = function() {
        getMenu().disable();
    };

    // button to enable in-game menu
    var btn = new TextButton(mapWidth/2 - w/2,-1.5*h,w,h, showMenu, "MENU",(tileSize-2)+"px ArcadeR","#FFF");

    // confirms a menu action
    var confirmMenu = new Menu("<WHAT AM I CONFIRMING?>",2*tileSize,5*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    confirmMenu.addTextButton("YES", function() {
        confirmMenu.disable();
        confirmMenu.onConfirm();
    });
    confirmMenu.addTextButton("NO", function() {
        confirmMenu.disable();
        showMenu();
    });
    confirmMenu.addTextButton("CANCEL", function() {
        confirmMenu.disable();
        showMenu();
    });
    var showConfirm = function(title,onConfirm) {
        hideMenu();
        confirmMenu.title = title;
        confirmMenu.onConfirm = onConfirm;
        confirmMenu.enable();
    };

    // regular menu
    var menu = new Menu("PAUSED",2*tileSize,5*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    menu.addTextButton("RESUME", function() {
        menu.disable();
    });
    menu.addTextButton("QUIT", function() {
        showConfirm("QUIT GAME?", function() {
            switchState(homeState, 60);
        });
    });

    // practice menu
    var practiceMenu = new Menu("PAUSED",2*tileSize,5*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    practiceMenu.addTextButton("RESUME", hideMenu);
    practiceMenu.addTextButton("RESTART LEVEL", function() {
        showConfirm("RESTART LEVEL?", function() {
            level--;
            switchState(readyNewState, 60);
        });
    });
    practiceMenu.addTextButton("SKIP LEVEL", function() {
        showConfirm("SKIP LEVEL?", function() {
            switchState(readyNewState, 60);
        });
    });
    practiceMenu.addTextButton("QUIT", function() {
        showConfirm("QUIT GAME?", function() {
            switchState(homeState, 60);
        });
    });

    // returns true if menu button should be available in the current state
    var isMenuBtnState = function() {
        return state == playState || state == newGameState || state == readyNewState || state == readyRestartState || state == finishState || state == deadState || state == overState;
    };

    return {
        update: function() {

            // enable or disable menu activation button
            if (btn.isEnabled) {
                if (!isMenuBtnState()) {
                    btn.disable();
                }
            }
            else {
                if (isMenuBtnState()) {
                    btn.enable();
                }
            }
            if (btn.isEnabled) {
                btn.update();
            }

        },
        drawButton: function(ctx) {
            if (isMenuBtnState() && (!getMenu().isEnabled() && !confirmMenu.isEnabled())) {
                btn.draw(ctx);
            }
        },
        drawMenu: function(ctx) {
            if (getMenu().isEnabled() || confirmMenu.isEnabled()) {
                ctx.fillStyle = "rgba(0,0,0,0.8)";
                ctx.fillRect(-mapPad-1,-mapPad-1,mapWidth+1,mapHeight+1);
                getMenu().isEnabled() ? getMenu().draw(ctx) : confirmMenu.draw(ctx);
            }
        },
        isAllowed: function() {
            return isMenuBtnState();
        },
        isOpen: function() {
            return getMenu().isEnabled() || confirmMenu.isEnabled();
        },
    };
})();

