({
	createRecord : function (component, event, helper) {
    var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({
        "Contact": "Contact"
    });
    createRecordEvent.fire();
}
})