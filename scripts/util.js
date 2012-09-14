/*jslint vars: true, white: true */
/*global jQuery */

var VISKOSITY = VISKOSITY || {};

(function($, ns) {

"use strict";

// polyfills
if(!Object.create) {
	Object.create = function(obj) {
		if(arguments.length > 1) {
			throw new Error("properties parameter is not supported");
		}
		var F = function() {};
		F.prototype = obj;
		return new F();
	};
}
if(!Object.keys) {
	Object.keys = function(obj) {
		var prop;
		var keys = [];
		for(prop in obj) {
			if(Object.prototype.hasOwnProperty.call(obj, prop)) {
				keys.push(prop);
			}
		}
		return keys;
	};
}
if(!Array.prototype.indexOf) {
	Array.prototype.indexOf = function(searchElement, fromIndex) {
		return $.inArray(searchElement, this, fromIndex);
	};
}

ns.setContext = function(fn, ctx) {
	return function() {
		var context = $.extend({ context: this }, ctx);
		fn.apply(context, arguments);
	};
};

// convenience wrapper
// returns a property getter for arbitrary objects
// if multiple arguments are supplied, the respective sub-property is returned
ns.getProp = function() { // TODO: memoize
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
ns.pusher = function(arr) {
	return function(i, item) {
		arr.push(item);
	};
};

}(jQuery, VISKOSITY));
