({
	getUpdatedCopays : function(component, copayIds) {
        var action = component.get('c.getUpdatedCopays');
        action.setParams({
            "copayIds" : copayIds
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.copayList", result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    getAffectedRecords : function(component, documents) {
        var action = component.get('c.getAffectedRecords');
        action.setParams({
            "contentDocumentIds" : documents
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.recordList", result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})