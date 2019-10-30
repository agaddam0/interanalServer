({
    init : function(component, event, helper) {
        helper.setupComponentsToCreate(component);
    },
    
    validateForm : function(component, event, helper) {
    	return helper.validateVisibleForms(component, event);
    },
    
    disableForm : function(component, event, helper){
        helper.disableForm(component, event);
    }
})