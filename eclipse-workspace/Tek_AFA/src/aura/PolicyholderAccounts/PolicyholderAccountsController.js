({
	doInit : function(component, event, helper) {
		var action = component.get("c.getAccounts");
        action.setParams({
            "policyholderId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") 
            {
            	component.set("v.accounts", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);
	}
})