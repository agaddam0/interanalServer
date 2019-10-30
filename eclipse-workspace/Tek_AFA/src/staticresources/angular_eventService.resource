var angular, SObjectModel, moment, r, R;
r = R;

(function () {
	'use strict';

	angular.module('eventService', 	['opportunityService', 'accountService', 'jsRemoteService', 'timeService'])
		.constant('eventRecordTypes',	['Reservice', 'New Hire Pick-up', 'New Group Enrollment'])
		.service('calendar', 			['time', '$q', 'opportunities', 'accounts', 'eventRecordTypes', 'jsRemote', calendar])
		.service('assignments', 		['time', '$q', 'calendar', 'jsRemote', assignments])

	function calendar (time, $q, opportunities, accounts, subTypes, Remote) {
		/* ***********************  Calendar Event Object ******************************* */
		CalendarEvent.prototype = Object.create(Event.prototype);
		CalendarEvents.prototype = Object.create(Object.prototype);

		CalendarEvents.prototype.find = function (date, userid) {
			return r.filter(function (event) {
				return r.and(
					event.getDate().isSame(date),
					userid === event.userId);
			}, this.events);
		};
		return function (range, userIds) {
		    // timeRange is an array of all the days in the month in order from the first
		    // of the month until the end of the month.
            var timeRange = time.getRange(range);
            var startDateTime = timeRange[0];
            var endDateTime = timeRange[timeRange.length - 1];
            
            // Calculate the next day after the end date because trying to use less than or equal to the end date
            // will only include all day events for the last day of the month. Doing less than the next day will include
            // any events on the last day of the month.
            var firstOfNextMonth = new Date(endDateTime.getFullYear(), endDateTime.getMonth(), endDateTime.getDate() + 1);
            
			var conditions = {
				where: {
                    assignedUserId: {in: userIds},
                    subType: {in: subTypes},
                    startDate: {gte: startDateTime},
                    endDate: {lt: firstOfNextMonth}
				}
			};
			
			return new Remote(new SObjectModel.Events().retrieve)
				.retrieve(conditions)
				.then(function (events) {
					var whatIds = r.compose(
						r.filter(r.complement(r.isNil)),
						r.uniq,
						r.map(r.invoker(1, 'get')('whatId')))(events);
					var promises = [
						accounts.get({where: {Id: {in: whatIds}}}),
						opportunities.byIds(whatIds)
					];

					return $q.all(promises)
						.then(function (owners) {
							return new CalendarEvents(events, r.flatten(owners));
						});
				});
		};
		function CalendarEvents (events, owners) {
			Object.defineProperties(this, {
				events: {
					value: getEvents(),
					writable: true
				}
			});
			function getEvents () {
				return r.compose(
					r.flatten,
					r.map(function (event) {
						var owner = r.find(r.propEq('id', event.get('whatId')), owners);
						var constructor = r.constructN(3, CalendarEvent)(event, owner);
						return r.map(
							constructor,
							time.getRange([
								constructor(null).startDate,
								constructor(null).endDate
							]));
					}))(events);
			}
		}
		function CalendarEvent (event, owner, date) {
			var isAllDay = event.get('isAllDay');
			var adjustDate = function (date) {
				return isAllDay ? time.convertFromLocalToUtc(date) : date;
			}

			Object.defineProperties(this, {
				id: { get: function () { return event.get('Id'); } },
				userid: {
					get: function () { return event.get('assignedUserId'); }
				},
				date: {
					get: function () {
						return adjustDate(date);
					}
				},
				isAllDay: function () {
					return isAllDay;
				},
				subject: { get: function () { return event.get('subType'); } },
				startDate: {
					get: function () { return adjustDate(event.get('startDate')); }
				},
				endDate: {
					get: function () { return adjustDate(event.get('endDate')); }
				},
				owner: {
					get: function () {
						return owner || {name: 'No Account Listed'};
					}
				}
			});
		}
	}
	function assignments (time, $q, Calendar, Remote) {
		/****************************************************************************************/
		AssignmentEvent.prototype = Object.create(Event.prototype);
		AssignmentEvent.prototype.finalize = function (date) {
			this.event.set('finalizedDate', date);
			this.event.set('status', 'Finalized');
			return this.event.upsert();
		};
		AssignmentEvent.prototype.upsert = function () {
			if (this.isEmpty()) { return; }
			this.event.upsert();
		};
		AssignmentEvent.prototype.isEmpty = function () {
			return r.anyPass([r.isNil, r.isEmpty])(this.subject);
		};
		AssignmentEvent.prototype.delete = function () {
			var assignment = new SObjectModel.Assignments();
			assignment.set('status', 'Draft');
			assignment.set('subject', '');
			assignment.set('activityDate', this.date.toDate());
			assignment.set('assignedUserId', this.userid);
			this.event.del();
			this.event = assignment;
			this.subject = '';
		};

		/****************************************************************************************/
		AssignmentEvents.prototype = Object.create(Object.prototype);
		AssignmentEvents.prototype.getDateKey = r.compose(
			r.invoker(1, 'format')('YYYYMMDD'),
			moment);
		AssignmentEvents.prototype.find = function (userid, date) {
			var groupByDate = r.groupBy(r.compose(this.getDateKey, r.prop('date')))(this.events);
			var groupByUserid = r.groupBy(r.prop('userid'))(this.events);
			var defaultData = r.defaultTo([]);

			var find = r.both(
				r.invoker(1, 'isSameDate')(date),
				r.invoker(1, 'isSameUser')(userid));

			var assignment = r.find(find, this.assignments);
			var events = r.intersectionWith(
				r.eqBy(r.prop('id')),
				r.compose(defaultData, r.prop(this.getDateKey(date)))(groupByDate),
				r.compose(defaultData, r.prop(userid))(groupByUserid));

			if (r.isNil(assignment)) {
				assignment = new AssignmentEvent(assignment);
				assignment.date = date;
				assignment.userid = userid;
				assignment.subject = '';
				this.assignments.push(assignment);
			}

			assignment.events = events;

			return assignment;
		}

		return function (range, userids) {
			var conditions = {
				where: {
					assignedUserId: {in: userids},
					activityDate: {in: time.getRange(range)}
				}
			};

			return $q.all([
				new Remote(new SObjectModel.Assignments().retrieve).retrieve(conditions),
				new Calendar(range, userids)
			]).then(function (data) {
				return new AssignmentEvents(r.last(data).events, r.head(data));
			});
		}

		/* ***********************  Assignment Event Object ******************************* */

		function AssignmentEvents (events, assignments) {
			Object.defineProperties(this, {
				events: {
					value: events,
					writable: false
				}
			});
			this.assignments = r.compose(
				r.map(r.constructN(1, AssignmentEvent)),
				r.defaultTo([]))(assignments);
		}

		function AssignmentEvent (event) {
			this.event = event = r.defaultTo(new SObjectModel.Assignments())(event);
			Object.defineProperties(this, {
				date: {
					get: function () {
						return moment(event.get('activityDate'));
					},
					set: function (date) {
						event.set('activityDate', moment(date).toDate());
					}
				},
				subject: {
					get: function () { return event.get('subject'); },
					set: function (subject) { event.set('subject', subject); }
				},
				userid: {
					get: function () { return event.get('assignedUserId'); },
					set: function (userid) { event.set('assignedUserId', userid); }
				},
				status: {
					get: function () {
						return r.defaultTo(AssignmentEvent.prototype.status)(event.get('status'));
					},
					set: function (status) {
						event.set('status', status);
					}
				},
				events: {
					value: [],
					writable: true
				}

			});
		}
	}

	/* ***********************  Event Object ******************************* */
	function Event () { }
	Event.prototype.isSameDate = function (date) {
		return r.compose(
			r.invoker(2, 'isSame')(moment(date), 'day'),
			r.prop('date'))(this);
	};
	Event.prototype.isSameUser = function (userid) {
		return r.compose(
			r.equals(userid),
			r.prop('userid'))(this);
	};
})();