//////////////////////////////////////////////////////////////////////////////////////
// Entry Point

window.onload = function() {
    atlas.create();
    gui.create();
    switchState(menuState);
    executive.init();
};
