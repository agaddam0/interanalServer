({
    init : function(component, event, helper) {
        helper.setDefaults(component);
    },
    
    handleEvent : function(component, event, helper) {
		var value = event.getParam("values");
        var field = event.getParam("fieldName");
        var item = event.getSource();
        item.set("v.value", value);
        
        if(field == 'EE_Eligibility_Waiting_Period__c')
        	helper.EligibilityWaitingPeriodChange(component, value);
	},
    
    validateForm : function(component, event, helper) {
        return helper.validateForms(component);
    },
    
    disableForm : function(component, event, helper) {
        helper.disableForms(component, event);
    }
})