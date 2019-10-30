({
	doInit : function(component, event, helper) {
        helper.createEnrollmentOpportunity(component);
        helper.toggleSpinner(component);
	},
    
    statusChange : function(component, event, helper) {
        if (event.getParam('status') === "FINISHED") {
            $A.get("e.force:closeQuickAction").fire()
        }
    }
})