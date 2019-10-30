({
	updateAccountCloneFlag : function(component) {
        component.set("v.message", 'Cloning services...');
        var action = component.get("c.updateCloneFlag");
        action.setParams({
            "accountId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
            	component.set("v.message", 'Services cloned successfully!');
            }
            else
            {
                component.set("v.message", 'There was an error cloning services.  Please contact your administrator');
            }
        });
		$A.enqueueAction(action);
	}
})