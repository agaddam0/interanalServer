var angular, R, r = R;

(function () {
	'use strict';

	angular.module('jsRemoteService', 	[])
		.service('jsRemote', 			remoting);

	function remoting () {
		return Remote
	}

	function Remote (func) {
		this.retrieve = Remote.prototype.retrieve(func);
	}

	Remote.prototype.retrieve = r.curry(function (func, conditions) {
		conditions.limit = 100;
		var rtnData = [];
		var parse = r.curry(function (resolve, reject, err, data) {
			if (err) { return reject(err, data); }
			rtnData = r.concat(rtnData, data);
			if (data.length === 100) {
				conditions.offset = rtnData.length;
				return func(conditions, parse(resolve, reject));
			}
			return resolve(rtnData);
		});
		return new Promise(function (resolve, reject) {
			if (validConditions(conditions) === true) {
				return func(conditions, parse(resolve, reject));
			}
			console.error(conditions, 'Caused an error in the request');
			return resolve(rtnData);
		});
	});

	function validConditions (conditions) {
		return r.both(
			validate(validWhere, 'where'),
			validate(validLimit, 'limit'))(conditions);
	}
	function validate (func, propName) {
		return r.compose(r.equals(true), func, r.prop(propName));
	}
	function validLimit (limit) {
		return r.equals(100, limit);
	}
	function validWhere (where) {
		return r.cond([
			[r.isNil, r.T],
			[r.T, validWhereProperty]
		])(where);
	}
	function validWhereProperty (where) {
		return r.compose(
			r.isEmpty,
			r.filter(hasEmptyIn),
			r.toPairs)(where);
	}

	function hasEmptyIn (pair) {
		return r.compose(
			r.cond([
				[r.isNil, r.F],
				[r.T, filterInForEmpty]
			]),
			r.prop('in'),
			r.find(r.is(Object)))(pair);
	}
	function filterInForEmpty (inArray) {
		return r.either(
			r.isEmpty,
			r.any(r.isNil)
		)(inArray);
	}
})();