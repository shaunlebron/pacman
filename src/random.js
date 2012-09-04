
var getRandomColor = function() {
    return '#'+('00000'+(Math.random()*(1<<24)|0).toString(16)).slice(-6);
};

var getRandomInt = function(min,max) {
    return Math.floor(Math.random() * (max-min+1)) + min;
};

