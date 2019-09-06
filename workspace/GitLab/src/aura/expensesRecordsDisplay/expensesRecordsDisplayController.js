({
	getOpps : function(component, event, helper) {
		 var action = component.get("c.getExpensesRecords");// calling apex class
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Expenses", response.getReturnValue());
            }
        });
	 $A.enqueueAction(action);
	},
    deleteContact : function(component, event, helper) {
        var event = component.getEvent("deleteContact");
        event.setParams({
            'selectedContact':component.get("v.Expenses")
        });
        event.fire();
    }
})