var SObjectModel, angular, R, r;
r = R;

(function () {
	'use strict'

	angular.module('accountService', 	['jsRemoteService'])
			.service('accounts', 		['$q', 'jsRemote', accounts])

	var parse = r.curry(function (resolve, reject, err, data) {
		if (err) { reject(err); }
		resolve(data);
	});

	function accounts ($q, jsRemote) {
		return {
			get: r.curryN(2, get)(jsRemote),
			find: find,
			typeAhead: typeAhead
		};

		function find (id) {
			return $q(function (resolve, reject) {
				return new SObjectModel
				.Accounts()
				.retrieve({where: {Id: {eq: id}}}, parse(resolve, reject));
			}).then(createAccounts).then(r.head);
		}

		function get (Remote, conditions) {
			return new Remote(new SObjectModel.Accounts().retrieve)
				.retrieve(conditions)
				.then(createAccounts);
		}

		function typeAhead (str) {
			return $q(function (resolve, reject) {
				return new SObjectModel
				.Accounts()
				.retrieve({where: {name: {like: '%' + str + '%'}}}, parse(resolve, reject));
			}).then(createAccounts);
		}
	}
	function createAccounts (accounts) {
		return r.map(r.constructN(1, Account), accounts);
	}
	function Account (account) {
		this.id = account.get('Id');
		this.name = account.get('name');
	}
})();