//////////////////////////////////////////////////////////////////////////////////////
// Entry Point

window.onload = function() {
    initRenderer();
    atlas.create();
    switchState(menuState);
    executive.init();
};
