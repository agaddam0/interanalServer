({
	doInit : function(component, event, helper) {
        helper.waiting(component, event, helper);
		var action = component.get("c.getRelatedRecord");
        action.setParams({
            "sObjectName" : component.get("v.ObjectName"),
            "mainRecordId" : component.get("v.recordId"),
            "mainRecordObjectName" : component.get("v.sObjectName"),
            "RecordTypeName" : component.get("v.RecordType"),
            "latestRecord" : component.get("v.LatestRecord")
        });
        action.setCallback(this, function(response) {
           var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                if(response.getReturnValue() !== '')
                    component.set("v.RelatedRecordId", response.getReturnValue());
            }
            helper.doneWaiting(component,event,helper);
        });
        $A.enqueueAction(action);
	}
})