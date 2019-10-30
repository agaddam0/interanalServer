({
	createEnrollmentOpportunity : function(cmp) {
		var action = cmp.get("c.createEnrollmentOpportunity");
        
        action.setParams({
            "newGroupOppId" : cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            this.toggleSpinner(cmp);
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS") {
                var opportunity = response.getReturnValue();
                if(opportunity) {
                    if(opportunity.Co_Admin_Group__c) {
                        this.startCoAdminFlow(cmp, opportunity.Id);
                    }
                    else {
                        this.navigateToGeneralInformation(cmp, opportunity.Id);
                    }
                }
                else {
                    cmp.set("v.messageTitle", 'Unable to Onboard');
                    cmp.set("v.message", 'You can only begin onboarding when the Opportunity has been won!');
                    cmp.set("v.showMessageScreen", true);
                }
            }
            else {
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0)
                {
                    let errorData = JSON.parse(errors[0].message);
                    cmp.set("v.showMessageScreen", true);
                    cmp.set("v.messageTitle", errorData.name);
                    cmp.set("v.message", errorData.message);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    startCoAdminFlow : function(component, opportunityId) {
        component.set("v.showMessageScreen", false);
        var flow = component.find("flow");
        var inputVariables =[
            {
                name : 'recordId',
                type : 'String',
                value : opportunityId
            }
        ];
        flow.startFlow("Co_Admin_Submission_to_Operations", inputVariables);
    },
    
    navigateToGeneralInformation : function(component, opportunityId) {
        component.set("v.showMessageScreen", true);
        component.set("v.message", 'Starting to Onboard...');
        var navigateToGeneralInfo = $A.get("e.force:navigateToURL");        
        navigateToGeneralInfo.setParams({
            "url" : "/apex/GeneralInformation?id=" + opportunityId
        });
        navigateToGeneralInfo.fire();
    },
    
    toggleSpinner: function (cmp, event) {
        var spinner = cmp.find("onboardingSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})