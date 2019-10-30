({
    doInit : function(component, event, helper) {
        var action = component.get("c.getProducts");
        action.setParams({
            "opportunityId" : component.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.OpportunityProducts", result.getReturnValue()); 
            }
        });
        
        $A.enqueueAction(action);   
    }
})