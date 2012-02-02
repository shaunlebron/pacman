//
// ==================== EVENT DISPATCH  =====================
//

var playEvents = {
    // when new level starts
    onNewLevel: function() {
        ghostCommander.reset();
        ghostReleaser.onNewLevel();
        fruit.reset();
        elroyTimer.onNewLevel();
    },

    // when player dies and level restarts
    onRestartLevel: function() {
        ghostCommander.reset();
        ghostReleaser.onRestartLevel();
        fruit.reset();
        elroyTimer.onRestartLevel();
    },

    // when a dot is eaten
    onDotEat: function() {
        ghostReleaser.onDotEat();
        fruit.onDotEat();
    },

    // update events
    update: function() {
        ghostReleaser.update();
        ghostCommander.update();
        elroyTimer.update();
        fruit.update();
    },
};

