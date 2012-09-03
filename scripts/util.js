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

ns.cappedStack = function(maxItems) {
	var arr = [];
	return {
		push: function(item) {
			arr.push(item);
			if(arr.length > maxItems) {
				arr.shift();
			}
		},
		pop: function() { return arr.pop(); }
	};
};

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

// remove element(s) from array
// NB: nested arrays not supported
ns.evict = function(items, arr) {
	if(!items.length) {
		items = [items];
	}
	var res = $.map(items, function(item) {
		var index = arr.indexOf(item);
		return index === -1 ? false : arr.splice(index, 1);
	});
	return res.length === 1 ? res[0] : res;
};

// invoke `fn` without the first `count` arguments
// `count` defaults to 1
ns.dropArgs = function(fn, count) {
	return function() {
		var args = Array.prototype.slice.call(arguments, count || 1);
		return fn.apply(this, args);
	};
};

}(jQuery, VISKOSITY));
