({
	doInit : function(component, event, helper) {
        var action = component.get("c.newConservationRequest");
        action.setParams({
            "policyholderId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.ChangeRequest", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
        
        component.set("v.validForm", helper.validateForm(component));
    },
    
    handleEvent : function(component, event, helper) {
		var value = event.getParam("values");
        var item = event.getSource();
        item.set("v.value", value);
        component.set("v.validForm", helper.validateForm(component));
	}, 
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleSubmit : function(component, event, helper) {
        var action = component.get("c.SaveandSubmitConservation"),
            req = component.get("v.ChangeRequest");
        req.sobjectType='Change_Request__c';
        
        action.setParams({
            "cRequest" : req
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": 'success',
                    "title": "Success",
                    "message": "Your request has been submitted."
                });
                resultsToast.fire();
                
                $A.get("e.force:closeQuickAction").fire();
                // maybe trigger page refresh
            }
            else
            {
                var errors = result.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": 'error',
                            "title": "Save Error",
                            "message": "There was a problem submitting this request: " + errors[0].message +                            
                            ". Please contact your system administrator."
                        });
                        resultsToast.fire();
                    }
                }
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(action);
    }
})