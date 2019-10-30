console.error('this static resource is not used')

var userRoleId, angular, R, r = R, moment, SObjectModel;

(function () {
	'use strict';

	var providers = [
		'ngAnimate',
		'ngTouch',
		'ngMaterial',
		'ui.grid',
		'ui.grid.edit',
		'ui.grid.pinning',
		'ui.grid.moveColumns',
		'ui.grid.resizeColumns',
		'logService',
		'dataService',
		'userService',
		'timeService',
		'assignmentEventCalendarGrid'
	];

	var injectPageCtrl = [
		'$scope',
		'$filter',
		'$timeout',
		'$mdToast',
		'$mdDialog',
		'grid',
		'time',
		'roles',
		'currentRoleId',
		pageCtrl
	];

	angular
		.module('assignmentEventCalendarApp', 	providers)
		.value('currentRoleId', 				userRoleId)
		.filter('lookAhead', 					['$q', '$timeout', lookAhead])
		.controller('pageCtrl',					injectPageCtrl);

	function pageCtrl ($scope, $filter, $timeout, $mdToast, $mdDialog, grid, time, drafts, roles, currentRoleId) {
		var vm = this;
		vm.done = true;
		vm.parentRole = null;
		vm.gridOptions = grid.grid;
		vm.title = 'No Selection';
		vm.range = time.month;
		vm.search = '';
		vm.team = '';
		vm.year = moment(r.head(vm.range)).year();
		vm.disabled = true;
		vm.isEditible = false;
		var assignment = new SObjectModel.Assignments();
		assignment.describe(function (err, description) {
			if (err) { console.error('error in getting description'); }
			vm.isEditible = description.creatable;
		})
		roles(currentRoleId).then(function (roles) {
			vm.districts = r.compose(
				r.map(function (role) {
					role.name = r.compose(
					r.trim,
					r.replace('District', ''),
					r.replace('Manager', ''),
					r.replace(/[A-Z]{2,}/, ''))(role.name);
					return role;
				}),
				r.sortBy(r.prop('name')),
				r.filter(
					r.compose(
						r.test(/District/),
						r.prop('name'))))(roles.children);
		});

		vm.filter = filter;
		vm.save = drafts.save;
		vm.saveAs = drafts.saveAs;
		vm.open = drafts.open;
		vm.drafts = drafts.drafts;
		vm.finalize = function () {
			grid.finalize().then(function () {
				createToast('Finished the Finalization')
			}, r.curryN(2, createToast)('That didn\'t go well at all'));
		}
		vm.dateRange = dateRange;
		vm.selectMonth = selectMonth;
		vm.updateUsers = updateUsers;
		vm.clearFilter = clearFilter;
		vm.query = r.curry(query)(r.__, vm.gridOptions);
		$scope.vm = vm;
		$scope.$watch('vm.done', function (value) {
			if (r.isNil(value)) {
				return;
			}
			if (!value) {
				$timeout(function () {
					if (vm.done) {
						return;
					}
					createToast('Something went wrong, please recalibrate the flux capacitor');
					vm.done = true;
					console.error('Something is wrong');
				}, 20000);
			}
		});
		return vm;
		function createToast (text) {
			var toast = $mdToast
				.simple()
				.textContent(text)
				.position('top right')
				.hideDelay(15000)
			$mdToast.show(toast);
		}
		function query (filter, grid) {
			return r.compose(
				$filter('lookAhead')(r.__, filter),
				r.filter(r.cond([
					[r.is(Date), r.F], // remove complication
					[r.is(Object), r.F], // remove complication
					[r.T, r.T]
				])),
				r.flatten,
				r.map(r.values))(grid.data);
		}
		function clearFilter () {
			r.forEach(function (row) {
				vm.gridOptions.api.core.clearRowInvisible(row);
			}, vm.gridOptions.api.grid.rows);
			vm.gridOptions.api.core.refresh();
		}
		function updateUsers (role) {
			vm.done = false;
			vm.parentRole = role;
			vm.title = formatDate(vm.range, vm.parentRole.name);
			return grid.getData(vm.range, role.id).then(updateGrid);
		}
		function updateRange (range) {
			vm.done = false;
			vm.range = range = time.getRange(range);
			vm.title = formatDate(range, vm.parentRole.name);
			return grid.getData(range, vm.parentRole.id)
					.then(updateGrid);
		}
		function updateGrid (gridOptions) {
			vm.done = true;
			vm.disabled = false;
			vm.gridOptions = gridOptions;
		}
		function formatDate (range, team) {
			var format = function (date) {
				return moment(date).format('MM/DD/YYYY');
			}
			return format(r.head(range)) + ' - ' + format(r.last(range)) + ' ' + team;
		}
		function selectMonth () {
			$mdDialog.show({
				controller: selectMonthModalCtrl,
				templateUrl: 'select.month.panel.tmpl.html',
				parent: angular.element(document.body),
				clickOutsideToClose: false,
				fullscreen: false,
				locals: {
					month: moment(r.head(vm.range)).month(),
					year: moment(r.head(vm.range)).year()
				}

			})
			.then(updateRange, console.info);
		}
		function dateRange () {
			$mdDialog.show({
				controller: dateRangeModalCtrl,
				templateUrl: 'date.range.panel.tmpl.html',
				parent: angular.element(document.body),
				clickOutsideToClose: false,
				fullscreen: false,
				locals: {
					minDate: r.head(vm.range),
					maxDate: r.last(vm.range)
				}
			})
			.then(updateRange);
		}

		function filter () {
			$mdDialog.show({
				controller: filterModalController,
				templateUrl: 'filter.tmpl.html',
				parent: angular.element(document.body),
				clickOutsideToClose: true,
				fullscreen: false,
				locals: {
					data: vm.gridOptions.data
				}
			})
			.then(function (matches) {
				var rows = vm.gridOptions.api.grid.rows;
				var x = rows.length;

				while (x-- > 0) {
					var index = r.findIndex(
						r.equals(rows[x].entity.$$hashKey),
						r.map(r.prop('$$hashKey'), matches));

					vm.gridOptions.api.core.clearRowInvisible(rows[x]);

					if (index === -1) {
						vm.gridOptions.api.core.setRowInvisible(rows[x]);
					}
				}
				vm.gridOptions.api.core.refresh();
			}, function () {
				console.info('Dialog was canceled');
			});
		}
	}

	function lookAhead ($q, $timeout) {
		var inString = r.curry(function (str, filter) {
			return str.includes(filter);
		});

		var inNumber = r.curry(function (num, filter) {
			return num.toString().includes(filter);
		});

		var inDate = r.curry(function (date, filter) {
			return moment(date)
				.format('MMMM dddd MM DD YYYY')
				.toString()
				.includes(filter);
		});

		return function (rows, filter) {
			var isObject, matchingLineFn, matchingFn, isArray;

			matchingLineFn = r.curry(function (row, filter) {
				return r.cond([
					[r.isEmpty, r.F],
					[r.isNil, r.F],
					[r.is(String), inString(r.__, filter)],
					[r.is(Number), inNumber(r.__, filter)],
					[r.is(Date), inDate(r.__, filter)],
					[r.is(Array), isArray(r.__, filter)],
					[r.is(Object), isObject(r.__, filter)],
					[r.T, r.F]
				])(row);
			});

			isArray = r.curry(function (ary, filter) {
				return r.any(matchingLineFn(r.__, filter), ary);
			});

			isObject = r.curry(function (obj, filter) {
				return r.any(
					matchingLineFn(r.__, filter),
					r.values(obj));
			});

			matchingFn = r.curry(function (row, filters) {
				return r.any(matchingLineFn(row), filters);
			});

			return r.filter(matchingFn(r.__, splitFilter(filter)), rows);
		};

		function splitFilter (filter) {
			return filter.split(/\s/);
		}
	}

	function filterModalController ($q, $timeout, $scope, $mdDialog, $filter, data) {
		$scope.selectedSearchItems = [];
		$scope.filter = $scope.selectedItem = '';

		var filterFn = r.curry(function (rows, filter) {
			return $filter('lookAhead')(rows, filter);
		});

		$scope.query = function (filter) {
			var deferred = $q.defer();

			$timeout(function () {
				var matches = r.compose(
					filterFn(r.__, filter),
					r.filter(r.cond([
						[r.is(Date), r.F], // remove complication
						[r.is(Object), r.F], // remove complication
						[r.T, r.T]
					])),
					r.flatten,
					r.map(r.values))(data);
				deferred.resolve(matches);
			}, false);

			return deferred.promise;
		}

		$scope.cancel = function () {
			$mdDialog.hide(data);
		};

		$scope.update = function (filter) {
			$mdDialog.hide(filterFn(data, filter));
		};
	}

	function selectMonthModalCtrl ($scope, $mdDialog, time, month, year) {
		$scope.years = r.range(year - 5, year + 6);
		$scope.months = r.map(function (n) {
			return {
				id: n,
				name: moment()
					.month(n)
					.format('MMMM')
			};
		}, r.range(0, 12));

		$scope.month = month;
		$scope.year = year;

		$scope.cancel = function () {
			$mdDialog.hide();
		};

		$scope.submit = function () {
			time.jumpTo(moment().year($scope.year).month($scope.month));
			$mdDialog.hide(time.month);
		};
	}

	function dateRangeModalCtrl ($scope, $mdDialog, time, minDate, maxDate) {
		$scope.minDate = minDate;
		$scope.maxDate = maxDate;
		$scope.cancel = function () {
			$mdDialog.cancel();
		};

		$scope.submit = function () {
			$mdDialog.hide(time.getRange([$scope.minDate, $scope.maxDate]));
		};
	}
})();