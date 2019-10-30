({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRecordTypesForObject");
        action.setParams({
            'sObjectName' : 'Change_Request__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") 
            {
                console.log(response.getReturnValue());
            	component.set("v.RecordTypes", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);
	},
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleNext : function(component, event, helper) {
        helper.getValuesAndRedirect(component);
    }
})