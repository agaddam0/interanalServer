({
	goToRecord : function(component, event, helper) {
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId" : component.get("v.account.Id"),
            "slideDevName" : 'related'
        });
        sObjectEvent.fire();
	}
})