({
    deleteContact : function(component, event, helper) {
        var event = component.getEvent("deleteContact");
        event.setParams({
            'selectedContact':component.get("v.contactRec")
        });
        event.fire();
    }
})