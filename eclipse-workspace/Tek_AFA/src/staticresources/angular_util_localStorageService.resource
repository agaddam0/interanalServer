var _, angular, localStorage;

(function () {
	'use strict';

	angular
		.module('dataService', ['logService'])
		.constant('dataConfiguration', {DELAY: 1500000, PERSIST: true})
		.service('storage', ['$log', '$timeout', 'dataConfiguration', _storage])
		.service('remote', ['$q', '$log', 'storage', _remote]);

	function _storage ($log, $timeout, config) {
		var timeout = get('timeout') || {};

		$log.getInstance('Storage Service');

		_.each(
			timeout,
			function (v, k) {
				setTimeout(k, new Date(v).getTime() - _.now());
			});

		return _.create(
			localStorage,
			{
				timeout: timeout,
				config: config,
				has: has,
				get: get,
				set: set,
				remove: remove
			});

		function has (key) {
			return _.has(localStorage, key);
		}

		function remove (key) {
			if (_.isString(key) === false) {
				console.error('Storage Key is not defined ' + key + ' ' + console.trace());
			}

			delete localStorage[key];

			return key;
		}

		function get (key) {
			try {
				if (has(key)) {
					return JSON.parse(localStorage.getItem(key));
				}
			} catch (e) {
				$log.error(e, remove(key));
			}

			return false;
		}

		function set (key, data) {
			_set(key, data)
			setTimeout(key, this.config.DELAY);
			return key;
		}

		function _set (key, data) {
			localStorage.setItem(key, JSON.stringify(data));
		}

		function removeTimeout (key) {
			if (_.has(timeout, key)) {
				delete timeout[key];
			}

			_set('timeout', timeout);

			return key;
		}

		function setTimeout (key, delay) {
			if (key === 'timeout') {
				$log.exception('Endless Timeout setting Timeout Loop ');
			}

			if (_.isUndefined(delay)) {
				$log.exception('Delay in Local Storage is not Defined');
			}

			if (has(key) === false) {
				delay = 0;
			}

			timeout[key] = new Date(_.now() + (delay || config.DELAY));

			_set('timeout', timeout);

			return $timeout(remove, delay, true, key)
				.then(removeTimeout);
		}
	};

	function _remote ($q, $log, storage) {
		$log = $log.getInstance('Data Service');

		return _.create(storage, {visualForce: _.bind(visualForce, storage)});

		function visualForce (key, remote, useRemote) {
			var self;

			$log.debug('Visual Force Key', '\r\n', key);

			if (_(key).isString() === false) {
				return $log.error('Missing Local Storage Key');
			}

			if (_(remote).isFunction() === false) {
				return $log.error('Missing Remote Callback Function');
			}

			self = this;

			return $q(function (resolve, reject) {
				var process;
				process = function (result, event) {
					if (event.status === false) {
						return reject(event);
					}

					$log.debug(
						'Process Remote Request', 	'\r\n',
						result,						'\r\n',
						event, 						'\r\n',
						key,						'\r\n');

					if (!useRemote) {
						self.set(key, result);
					}

					return resolve(result);
				}

				$log.debug(
					'Self', 	self,			'\r\n',
					'Key', 		key,			'\r\n',
					'Has Key', 	self.has(key), 	'\r\n');

				if (self.has(key) && !useRemote) {
					return resolve(self.get(key));
				}

				return remote(process);
			});
		}
	};
})();