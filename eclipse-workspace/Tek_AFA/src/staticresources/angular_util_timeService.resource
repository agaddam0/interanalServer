var moment, angular, _;
(function () {
	'use strict';

	angular.module('timeService', [])
			.service('time', ['$q', service]);

	function service ($q) {
		var
			week = getRange(
				moment().startOf('week'),
				moment().endOf('week')),
			month = getRange(
				moment().startOf('month'),
				moment().endOf('month')),
			createNew = function () {
				return _.create({
					_curren: moment(),
					_week: moment(),
					_month: moment(),
					getRange: getRange,
					convertFromLocalToUtc: convertFromLocalToUtc

				}, {
					clone: createNew,
					titleFormat: titleFormat,
					archiveFormat: archiveFormat,
					pagerFormat: pagerFormat,

					next: next,
					previous: previous,

					jumpTo: jumpTo,

					week: week,
					month: month

				});
			};

		return createNew();
		function convertFromLocalToUtc (date) {
			var timeZoneOffset = (new Date().getTimezoneOffset() / 60);
			return moment(moment(date).add(timeZoneOffset, 'hours').toDate());
		}
		function jumpTo (date) {
			if (_.isDate(date) === false) { date = new Date(date); }

			var week, month;
			week =
				month =
				this.__proto__._week =
				this.__proto__._month =
				moment(date);

			this.week = getRange(moment(week.startOf('week')), moment(week
					.endOf('week')));

			this.month = getRange(moment(month.startOf('month')), moment(month
					.endOf('month')));

			return this;
		}

		function next () {
			var week = this.__proto__._week.add(1, 'weeks'), month = this.__proto__._month
					.add(1, 'months');

			this.week = getRange(moment(week.startOf('week')), moment(week
					.endOf('week')));

			this.month = getRange(moment(month.startOf('month')), moment(month
					.endOf('month')));

			return this;
		}

		function previous () {
			var week = this.__proto__._week.subtract(1, 'weeks'), month = this.__proto__._month
					.subtract(1, 'months');

			this.week = getRange(moment(week.startOf('week')), moment(week
					.endOf('week')));

			this.month = getRange(moment(month.startOf('month')), moment(month
					.endOf('month')));

			return this;
		}

		function getRange (dates) {
			var
				range = _(arguments)
				.chain()
				.flatten()
				.filter(function (day) {
					return moment(day).isValid();
				})
				.map(function (d) { return moment(d); })
				.value();

			var min = moment.min(range).startOf('day').valueOf();
			var max = moment.max(range).startOf('day').valueOf();

			if (min === max) { return [new Date(min)]; }

			dates = _.map(_.range(min, max, 86400 * 1000), function (num) {
				return new Date(num);
			});

			if (moment(_.last(dates)).isSame(moment(max), 'day')) {
				return dates;
			}

			dates.push(moment(max).toDate());
			return dates;
		}

		function pagerFormat (date) {
			return moment(date).format('MMM D');
		}

		function titleFormat (date) {
			if (_.isDate(date) === false) { date = new Date(date); }

			var options = {
				weekday: 'short',
				month: 'short',
				day: 'numeric'
			};

			return date.toLocaleDateString('en-US', options);
		}

		function archiveFormat (date) {
			return moment(date).format('YYYYMMDD');
		}
	}
})();