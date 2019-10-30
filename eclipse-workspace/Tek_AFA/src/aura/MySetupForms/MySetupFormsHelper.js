({
	init : function(component, event, helper) {
		var getMyInProgressEnrollmentOppsAction = component.get('c.getMyInProgressEnrollmentOpportunities');
		var displayLimit = component.get('v.DisplayLimit');
		
		getMyInProgressEnrollmentOppsAction.setParams({
			"numberToQuery": displayLimit
		});

		getMyInProgressEnrollmentOppsAction.setCallback(component, function(response){
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
				var getMyInProgressEnrollmentOppsActionResponse = response.getReturnValue();
				
				component.set('v.Context', getMyInProgressEnrollmentOppsActionResponse);
				component.set('v.AllEnrollmentOpps', getMyInProgressEnrollmentOppsActionResponse.EnrollmentOpportunities);
				
				component.set('v.StatusFilter', getMyInProgressEnrollmentOppsActionResponse.CurrentStatusFilter);
				component.set('v.OppOwnerIdFilter', getMyInProgressEnrollmentOppsActionResponse.CurrentOppOwnerIdFilter);
				helper.renderPage(component, event, helper);
			}
			else {
				console.log('Problem getting my in progress enrollment opportunities. Response state: ' + state);
			}
			
			component.set('v.initialLoading', false);
		});
		
		component.set('v.initialLoading', true);
		helper.setAvailableStatuses(component, event, helper);
		
		$A.enqueueAction(getMyInProgressEnrollmentOppsAction);
	},
	
	getEnrollmentOpps : function(component, event, helper) {
		var initialLoading = component.get('v.initialLoading');
		
		// Since init changes the status filter and OppOwnerIdFilter which have onchange events,
		// only load getEnrollmentOpps when needed.
		if (initialLoading) {
			return;
		}
		
		var getEnrollmentOppsAction = component.get('c.getEnrollmentOpportunities');
		var statusFilter = component.get('v.StatusFilter');
		var oppOwnerIdFilter = component.get('v.OppOwnerIdFilter');
		
		if (!statusFilter || !oppOwnerIdFilter) {
			return;
		}
		
		var displayLimit = component.get('v.DisplayLimit');
		
		getEnrollmentOppsAction.setParams({
			"numberToQuery": displayLimit,
			"status": statusFilter,
			"opportunityOwnerId": oppOwnerIdFilter
		});

		getEnrollmentOppsAction.setCallback(component, function(response){
			var state = response.getState();

			if (component.isValid() && state === "SUCCESS") {
				var getMyInProgressEnrollmentOppsActionResponse = response.getReturnValue();
				
				component.set('v.Context', getMyInProgressEnrollmentOppsActionResponse);
				component.set('v.AllEnrollmentOpps', getMyInProgressEnrollmentOppsActionResponse.EnrollmentOpportunities);
				helper.renderPage(component, event, helper);
			}
			else {
				console.log('Problem getting my in progress enrollment opportunities. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(getEnrollmentOppsAction);
	},
	
	setAvailableStatuses : function(component, event, helper) {
		var statuses = component.get('v.Statuses');
		
		if (!statuses) {
			return;
		}
		
		var splitStatuses = statuses.split(',');
		var trimmedStatuses = splitStatuses.map(s => s.trim());
		
		component.set('v.AvailableStatuses', trimmedStatuses);
	},
	
	renderPage: function(component, event, helper) {
		var paginator = component.find('paginator');
		paginator.reload();
    },
})