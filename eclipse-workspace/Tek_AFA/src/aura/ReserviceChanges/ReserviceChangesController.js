({
	init : function(component, event, helper) {
        helper.setCustomAttributes(component);
	},
    
    navigateBack : function(component, event, helper) {
        helper.navigateToPage(component, event, 'CurrentSetupReview');
    },
    
    determineNavigation : function(component, event, helper) {
        helper.navigateDecision(component, event, helper);
    },
    
    disableForm : function(component, event, helper){
        helper.disableForm(component, event);
    }
})