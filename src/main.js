//////////////////////////////////////////////////////////////////////////////////////
// Entry Point

window.onload = function() {
    initRenderer();
    atlas.create();
    switchState(homeState);
    executive.init();
};
