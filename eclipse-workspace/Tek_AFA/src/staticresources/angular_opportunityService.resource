var SObjectModel, angular, R, r = R;

(function () {
	'use strict';

	angular.module('opportunityService', 	['jsRemoteService'])
		.service('opportunities', 			['jsRemote', opportunity]);

	function opportunity (Remote) {
		return {
			byIds: function (ids) { return get({where: {Id: {in: ids}}}); }
		};

		function get (conditions) {
			return new Remote(new SObjectModel.Opportunities().retrieve)
				.retrieve(conditions)
				.then(r.map(r.construct(Opportunity)));
		}
	}

	function Opportunity (opportunity) {
		this.id = opportunity.get('Id');
		this.name = opportunity.get('name');
	}
})();