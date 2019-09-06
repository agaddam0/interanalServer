({
	 doInit : function(component, event, helper) {
        var action = component.get("c.getContacts");
        action.setCallback(this, function(data) {
            console.log(data.getReturnValue());
            component.set("v.contacts", data.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})