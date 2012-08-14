////////////////////////////////////////////////////
// In-Game Menu
var inGameMenu = (function() {

    var w=tileSize*6,h=tileSize*2;

    var showMenu = function() {
        menu.enable();
    };
    var hideMenu = function() {
        menu.disable();
    };

    var btn = new TextButton(mapWidth/2 - w/2,-1.5*h,w,h,showMenu,"MENU",(tileSize-2)+"px ArcadeR","#FFF");

    var menu = new Menu("PAUSED",2*tileSize,5*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    menu.addTextButton("RESUME", hideMenu);
    menu.addTextButton("QUIT", function() {
        hideMenu();
        quitMenu.enable();
    });

    var quitMenu = new Menu("QUIT GAME?",2*tileSize,5*tileSize,mapWidth-4*tileSize,3*tileSize,tileSize,tileSize+"px ArcadeR", "#EEE");
    quitMenu.addTextButton("YES", function() {
        quitMenu.disable();
        switchState(homeState,60);
    });
    quitMenu.addTextButton("NO", function() {
        quitMenu.disable();
        showMenu();
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
            if (isMenuBtnState() && (!menu.isEnabled() && !quitMenu.isEnabled())) {
                btn.draw(ctx);
            }
        },
        drawMenu: function(ctx) {
            if (menu.isEnabled() || quitMenu.isEnabled()) {
                ctx.fillStyle = "rgba(0,0,0,0.8)";
                ctx.fillRect(-mapPad-1,-mapPad-1,mapWidth+1,mapHeight+1);
                menu.isEnabled() ? menu.draw(ctx) : quitMenu.draw(ctx);
            }
        },
        isAllowed: function() {
            return isMenuBtnState();
        },
        isOpen: function() {
            return menu.isEnabled() || quitMenu.isEnabled();
        },
    };
})();

