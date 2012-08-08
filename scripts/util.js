/*jslint vars: true, white: true */
/*global jQuery */

var VISKOSITY = VISKOSITY || {};

(function($) {

"use strict";

// convenience wrapper
// returns a property getter for arbitrary objects
// if multiple arguments are supplied, the respective sub-property is returned
VISKOSITY.getProp = function() { // TODO: memoize
	var args = arguments;
	return function(obj) {
		var res = obj;
		$.each(args, function(i, prop) { // TODO: use `reduce`
			res = res[prop];
		});
		return res;
	};
};

// convenience wrapper for jQuery#each callbacks
// returns a function which appends the given item to the specified array
VISKOSITY.pusher = function(arr) {
	return function(i, item) {
		arr.push(item);
	};
};

}(jQuery));
