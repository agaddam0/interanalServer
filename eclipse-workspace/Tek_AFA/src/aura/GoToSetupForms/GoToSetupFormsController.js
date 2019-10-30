({
	init : function(component, event, helper) {
		helper.getOpportunityId(component, event);
	},
    
    openReserviceForm : function(component, event, helper) {
        helper.navigateToComponent(component, event, 'ReserviceSetup');
    },
    
    openFullSetupForms : function(component, event, helper) {
        helper.navigateToSetupForms(component, event);
    }
})