({
	removeClonedServices : function(component) {
        component.set("v.message", 'Removing services...');
        var action = component.get("c.removeClonedServices");
        action.setParams({
            "accountId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
            	component.set("v.message", 'Services removed successfully!');
            }
            else
            {
                component.set("v.message", 'There was an error removing services.  Please contact your administrator');
            }
        });
		$A.enqueueAction(action);
	}
})