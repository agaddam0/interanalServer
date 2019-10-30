({    
    save : function(component, event, helper) {
        var opportunity = component.get("v.opportunity");
        helper.save(component, event, opportunity);
    },
    
    validateChildComponents : function(component, event, helper) {
        return helper.validate(component, event);
    },
    
    navigateBack : function(component, event, helper) {
        helper.navigateToPage(component, event, 'CurrentSetupReview');
    },
    
    submitForm : function(component, event, helper) {
    	var submitEvent = component.getEvent("submitForms");
        submitEvent.fire();
    },
    
    disableForms : function(component, event, helper){
        helper.disableForms(component, event);
    }
})