var angular, R, r = R, moment;

(function () {
	'use strict';

	angular.module('logService', [])
		.config(['$provide', provide])
		.service('log', ['$log', log]);

	function provide ($provide) {
		return $provide.decorator(
			'$log', ['$delegate', provider]);
	}

	function provider ($delegate) {
		$delegate.getInstance = function () {
			return $delegate;
		};

		return $delegate;
	}

	function log ($log) {
		return $log;
	}

	var providers = [
		'ngAnimate',
		'ngTouch',
		'ngMaterial',
		'eventService',
		'userService',
		'accountService',
		'timeService'
	];

	angular
		.module('assignmentEventCalendarGrid', 	providers)
		.service('data',			['users', 'assignments', 'roles', data])
		.service('columns', 		['$timeout', '$mdPanel', '$mdToast', columns])
		.service('rows',			['time', rows])
		.service('grid',			['$q', 'time', 'columns', 'rows', 'data', grid]);

	function data (users, assignments, roles) {
		return function (range, parentRoleId) {
			var data = {};
			return roles(parentRoleId).then(function (results) {
				return users(results.childrenIds);
			}).then(function (users) {
				data.users = r.sortBy(r.prop('name'), users.all);
				return assignments(
					range,
					r.map(r.prop('id'), users.all));
			})
			.then(function (assignments) {
				data.assignments = assignments;
				return data;
			});
		};
	}

	function columns ($timeout, $mdPanel, $mdToast) {
		return function (users) {
			var compose = r.compose(
				r.concat([ dateColumn() ]),
				r.map(userColumn));
			return compose(users);
		};

		function dateColumn () {
			return {
				enableCellEdit: false,
				enableSorting: false,
				enableFiltering: false,
				name: 'Date',
				field: 'dateName',
				pinnedLeft: true,
				width: 150,
				enableHiding: false,
				enableColumnMenu: false,
				cellClass: function (grid, row, col) {
					var day = moment(row.entity.date).day();
					var cls = 'cell';
					cls += ((day < 6 && day > 0) ? ' weekday' : ' weekend');

					return cls;
				}
			};
		}

		function userColumn (user) {
			return {
				name: user.name.replace('&#39;', '\''),
				field: user.id,
				type: 'string',
				minWidth: 150,
				enableCellEdit: false,
				enableColumnMenu: false,
				cellClass: cellClass,

				// custom functions
				eventModal: eventModal,
				additionalEvents: additionalEvents,
				getDisplay: getDisplay,
				query: query,
				keyPress: keyPress,
				update: update,
				cancel: cancel,
				clear: clear,
				showIcons: showIcons,
				showInput: showInput,
				hideInput: hideInput,
				showDelete: showDelete,
				hideDelete: hideDelete,

				cellTemplate: 'cell.tmpl.html'
			};
		}
		function showDelete (row, col) {
			if (getAppScope(row).isEditible === false) {
				return false;
			}
			var assignment = row.entity.assignments[col.field];
			var states = getViewStates(row, col);
			states.isDeleteVisible = assignment.isEmpty() === false;
		}
		function showInput (row, col) {
			if (getAppScope(row).isEditible === false) {
				return false;
			}
			var states = getViewStates(row, col);
			states.isInputVisible = true;
			$timeout(function () {
				states.isInputVisible = states.isIconsVisible;
			}, 3000);
		}
		function showIcons (row, col) {
			getViewStates(row, col).isIconsVisible = true;
		}
		function hideDelete (row, col) {
			var states = getViewStates(row, col);
			states.isDeleteVisible = false;
		}
		function hideInput (row, col) {
			$timeout(function () {
				update(row, col);
			});
		}
		function clear (row, col) {
			var assignment = row.entity.assignments[col.field]
			assignment.delete();
			row.entity[col.field] = assignment.subject;
			getViewStates(row, col).isUpserted = false;
			row.grid.processRowBuilders(row);
		}
		function cancel (row, col) {
			getViewStates(row, col).isInputVisible = false;
			getViewStates(row, col).isIconsVisible = false;
			row.grid.processRowBuilders(row);
		}
		function update (row, col) {
			var assignment = row.entity.assignments[col.field]
			assignment.subject = row.entity[col.field];
			assignment.status = 'Draft';
			assignment.upsert();
			getViewStates(row, col).isInputVisible = false;
			getViewStates(row, col).isIconsVisible = false;
			getViewStates(row, col).isUpserted = true;
			row.grid.processRowBuilders(row);
		}
		function keyPress (event, row, col) {
			if (event.key === 'Enter') {
				col.colDef.update(row, col);
				row.grid.processRowBuilders(row);
			}
		}
		function query (row, col) {
			return r.compose(
				r.invoker(1, 'query', row.entity[col.field]),
				getAppScope)(row);
		}
		function additionalEvents (row, col) {
			var assignment = row.entity.assignments[col.field];
			return r.compose(
				r.length,
				r.filter(r.is(Object)),
				r.append(
					assignment.isEmpty() ? null : assignment))(assignment.events);
		}
		// TODO remove grid, its not used
		function cellClass (grid, row, col) {
			var assignment = row.entity.assignments[col.field];
			var events = assignment.events.length + (assignment.isEmpty() ? 0 : 1);
			var day = assignment.date.day();
			var cls = [];

			cls.push(events > 1 ? 'dialog-background ' : '');
			cls.push((assignment.isEmpty() && events > 0) ? 'event-data' : '');
			cls.push((day < 6 && day > 0) ? ' weekday' : ' weekend');

			return r.join(' ', cls);
		}
		function eventModal (row, col) {
			var assignment = row.entity.assignments[col.field];
			if (additionalEvents(row, col) < 2) {
				return;
			}

			var position = $mdPanel
				.newPanelPosition()
				.absolute()
				.center();

			var config = {
				attachTo: angular.element(document.body),
				locals: {
					assignment: assignment
				},
				controller: DialogCtrl,
				controllerAs: 'ctrl',
				templateUrl: 'panel.tmpl.html',
				position: position,
				trapFocus: false,
				zIndex: 500,
				clickOutsideToClose: true,
				clickEscapeToClose: true,
				hasBackdrop: true
			};

			$mdPanel.open(config);
		}
		function getDisplay (row, col) {
			var hasEvents = r.compose(r.gt(r.__, 0), r.length, r.prop('events'));
			var getOwnerName = r.compose(
				r.prop('name'),
				r.prop('owner'),
				r.head,
				r.prop('events'));
			return r.cond([
				[r.complement(r.invoker(0, 'isEmpty')), r.prop('subject')],
				[hasEvents, getOwnerName],
				[r.T, r.always('')]
			])(row.entity.assignments[col.field]);
		}
		function getAppScope (row) {
			return r.path(['grid', 'appScope', 'ctrl'])(row);
		}
		function getViewStates (row, col) {
			return row.entity.states[col.field];
		}
	}

	function rows (time) {
		var createRow = r.curry(function (day, assignments, users) {
			var row, cell;

			cell = r.curry(
				function (assignments, day, row, user) {
					return createCell(row, user.id, assignments, day);
				})(assignments, day);
			var baseObj = {assignments: {}, states: {}};
			row = r.reduce(cell, baseObj, users);
			row.dateName = time.titleFormat(day);
			row.date = day;

			return row;
		});

		return function (users, assignments, range) {
			return r.map(
				createRow(r.__, assignments, users),
				range);
		}

		function createCell (row, userId, assignments, day) {
			var assignment = assignments.find(userId, day);
			row[userId] = assignment.subject;
			row.assignments[userId] = assignment;
			row.states[userId] = {isInputVisible: false, isIconsVisible: false, isUpserted: false};
			return row;
		}
	}

	function grid ($q, time, columns, rows, data) {
		var grid = {
			enableGridMenu: false,
			enableCellEditOnFocus: true,
			minRowsToShow: 20,
			enableFiltering: false,
			enableSorting: false,
			columnDefs: [],
			data: [],
			onRegisterApi: function (gridApi) {
				console.log(gridApi);
				grid.api = gridApi;
			}
		};

		return {
			grid: grid,
			getData: getData,
			finalize: finalize
		};
		function getData (range, parentRoleId) {
			grid.data = [];
			return createGrid(grid, range, parentRoleId)
				.then(function (data) {
					grid.data = rows(data.users, data.assignments, range);
					grid.api.core.refresh();
					return grid;
				})
		}
		function createGrid (grid, range, parentRoleId) {
			return data(range, parentRoleId)
				.then(function (data) {
					grid.columnDefs = columns(data.users);
					return data;
				});
		}
		function finalize () {
			return r.compose(
				$q.all,
				r.map(function (assignment) {
					return assignment.finalize();
				}),
				r.filter(function (assignment) {
					return assignment.status === 'Draft';
				}),
				r.filter(function (assignment) {
					return assignment.isEmpty() === false;
				}),
				r.flatten,
				r.map(r.values),
				r.flatten,
				r.map(r.prop('assignments')))(grid.data);
		}
	}

	function DialogCtrl (mdPanelRef, assignment, $location) {
		this._mdPanelRef = mdPanelRef;
		this.assignment = assignment;
		this.url = $location.protocol() + '://' + $location.host() + '/';
	}

	DialogCtrl.prototype.closeDialog = function () {
		this._mdPanelRef && this._mdPanelRef.close();
	};
})();