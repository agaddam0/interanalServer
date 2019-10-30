var SObjectModel, angular, R, r = R;

(function () {
	'use strict'

	// TODO hard coded role id

	angular.module('userService', 		['jsRemoteService'])
			.service('users', 			['roles', 'jsRemote', users])
			.service('roles', 			['jsRemote', roles]);

	function roles (Remote) {
		return function (parentRoleId) {
			return new Remote(new SObjectModel.Roles().retrieve)
				.retrieve({})
				.then(r.construct(Roles)(r.__, parentRoleId));
		};
	}

	function Roles (roles, currentRoleId) {
		var all = r.map(r.constructN(1, Role), roles);
		this.all = all;
		this.childrenIds = this.flattenChildRoles(currentRoleId);
		this.children = r.map(
			function (id) {
				return r.find(r.propEq('id', id), all);
			}, this.childrenIds);
		this.parentRole = r.find(r.propEq('id', currentRoleId), all);
	}

	Roles.prototype.flattenChildRoles = function (roleId) {
		var roles = this;
		var children = r.compose(
			r.map(function (role) {
				if (r.isNil(role.id)) {
					return [];
				}
				return roles.flattenChildRoles(role.id);
			}),
			r.filter(r.propEq('parentId', roleId)))(roles.all);
		return r.compose(
			r.flatten,
			r.concat(children))(
				[r.find(r.propEq('id', roleId), roles.all).id]);
	}

	Roles.prototype.childRoles = function (roleId) {
		if (roleId === undefined) { return []; }
		var roles = this;
		return {
			role: r.find(
				r.propEq('id', roleId),
				this.all),
			children: r.compose(
				r.map(function (role) {
					return roles.childRoles(role.id);
				}),
				r.filter(
					r.propEq('parentId', roleId))
				)(this.all)
		};
	};

	function Role (role) {
		this.name = role.get('name');
		this.id = role.get('Id');
		this.parentId = role.get('parentRoleId');
	}

	function users (roles, Remote) {
		return function (roleIds) {
			var conditions = {
				where: {
					isActive: {eq: true},
					role: {
						in: roleIds
					}
				}
			};
			return new Remote(new SObjectModel.Users().retrieve)
				.retrieve(conditions)
				.then(r.construct(Users))
				.then(filterInactiveUsers);
		}

		function filterInactiveUsers (users) {
			var userIds = r.map(r.prop('id'), users.all);
			var conditions = {
				where: {
					userId: {in: userIds},
					isFrozen: {eq: false}
				}
			};

			return new Remote(new SObjectModel.Logins().retrieve)
				.retrieve(conditions)
				.then(function (logins) {
					var activeLogins = r.map(function (login) {
						return login.get('userId')
					}, logins);

					users.all = r.filter(r.compose(
						r.contains(r.__, activeLogins),
						r.prop('id')), users.all);

					return users;
				});
		}
	}

	function Users (users) {
		this.all = r.map(r.construct(User), users);
	}

	function User (user) {
		this.id = user.get('Id');
		this.name = user.get('name');
		this.agentIdd = user.get('agentId');
		this.region = user.get('region');
		this.manager = user.get('manager');
		this.team = user.get('team');
		this.superRegion = user.get('superRegion');
		this.workState = user.get('workState');
		this.division = user.get('division');
		this.role = user.get('role');
		this.isActive = user.get('isActive');
	}
})();