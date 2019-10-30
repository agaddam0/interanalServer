({
	getOpportunityId : function(component, event) {
		var getOpportunityAction = component.get('c.getOpportunity');
        
        getOpportunityAction.setParams({
            'opportunityId' : component.get('v.recordId')
        });
        
        getOpportunityAction.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var opportunity = result.getReturnValue();
                if(opportunity) {
                    console.log(opportunity.Significant_Setup_Changes__c);
                console.log(opportunity.Simple_Setup_Changes__c);
                    component.set('v.opportunity', opportunity);}
                else {
                    component.set('v.showEmptyMessage', true);
                    component.set('v.emptyMessage', 'No Enrollment Opportunities created for this Account');
                }
                    
            }
        });
        $A.enqueueAction(getOpportunityAction);
	},
    
    navigateToComponent : function(component, event, componentName) {
        var navToComponentEvent = $A.get("e.force:navigateToComponent");
        navToComponentEvent.setParams({
            componentDef : "c:" + componentName,
            componentAttributes: {
                recordId : component.get("v.opportunity.Id")
            }
        });
        navToComponentEvent.fire();
    },
    
    navigateToSetupForms : function(component, event) {
        var navToVFPageEvent = $A.get("e.force:navigateToURL");
        navToVFPageEvent.setParams({
            "url" : "/apex/GeneralInformation?id=" + component.get("v.opportunity.Id")
        });
        
        navToVFPageEvent.fire();
    }
})