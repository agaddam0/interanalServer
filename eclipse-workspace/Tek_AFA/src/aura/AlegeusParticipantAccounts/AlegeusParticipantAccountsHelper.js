({
    loadAccountInfo : function(component, helper) {
        var getEmployerInfoAction = component.get('c.getEmployerInfo');
        var recordId = component.get('v.recordId');

        getEmployerInfoAction.setParams(
            {"accountId": recordId }
        );
        
        helper.showSpinner(component);
        
        getEmployerInfoAction.setCallback(component, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var employerInfo = response.getReturnValue();

                component.set("v.account", employerInfo.Employer);
            }
            else {
                console.log('Problem getting employer info. Response state: ' + state);
            }
            
            helper.hideSpinner(component);
        });
        
        $A.enqueueAction(getEmployerInfoAction);
    },

    loadParticipantAcccounts : function(component, event, helper) {
        var getParticipantAccountsInfoAction = component.get('c.getParticipantAccountsInfo');
        var recordId = component.get('v.recordId');
        var participantId = component.get('v.participantId');
        var planYear = component.get('v.planYear');
        
        getParticipantAccountsInfoAction.setParams(
            {"accountId": recordId,
             "participantId": participantId,
             "planYear": planYear}
        );

        helper.showSpinner(component);
        component.set("v.errorMessage", null);
        component.set("v.participantInfo", null);

        getParticipantAccountsInfoAction.setCallback(component, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var participantAccountInfo = response.getReturnValue();
                
                if (participantAccountInfo.Context.Success) {
                    component.set("v.participantInfo", participantAccountInfo.Context);
                    component.set("v.planYearGroups", participantAccountInfo.PlanYearGroups);
                }
                else {
                    component.set("v.errorMessage", participantAccountInfo.Context.Message);
                }
            }
            else {
                console.log('Problem getting participant accounts. Response state: ' + state);
            }
            
            helper.hideSpinner(component);
        });
        
        $A.enqueueAction(getParticipantAccountsInfoAction);
    },
    
    showSpinner : function(component) {
        component.set('v.showSpinner', true);
    },
    
    hideSpinner : function(component) {
        component.set('v.showSpinner', false);
    }
})