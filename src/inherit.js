//  Apparently, the mutable, non-standard __proto__ property creates a lot of complexity for JS optimizers,
//   so it may be phased out in future JS versions.  It's not even supported in Internet Explorer.
//
//  Object.create does everything that I would use a mutable __proto__ for, but this isn't implemented everywhere yet.
// 
//  So instead of the following:
//
//      var obj = {
//          __proto__: parentObj,
//          hello: function() { return "world"; },
//      };
//
//  You can use this:
//
//      var obj = newChildObject(parentObj, {
//          hello: function() { return "world"; },
//      };

const newChildObject = function(parentObj, newObj) {

    // equivalent to: var resultObj = { __proto__: parentObj };
    const x = function(){};
    x.prototype = parentObj;
    const resultObj = new x();

    // store new members in resultObj
    if (newObj) {
        const hasProp = {}.hasOwnProperty;
        for (const name in newObj) {
            if (hasProp.call(newObj, name)) {
                resultObj[name] = newObj[name];
            }
        }
    }

    return resultObj;
};
