//////////////////////////////////////////////////////////////////////////////////////
// Entry Point

window.onload = function() {
    initRenderer();
    atlas.create();
    gui.create();
    switchState(menuState);
    executive.init();
};
