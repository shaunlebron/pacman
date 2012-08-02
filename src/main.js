//////////////////////////////////////////////////////////////////////////////////////
// Entry Point

window.onload = function() {
    initRenderer();
    atlas.create();
    initSwipe();
    switchState(homeState);
    executive.init();
};
