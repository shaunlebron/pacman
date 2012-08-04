//////////////////////////////////////////////////////////////////////////////////////
// Entry Point

window.addEventListener("load", function() {
    initRenderer();
    atlas.create();
    initSwipe();
    switchState(homeState);
    executive.init();
});
