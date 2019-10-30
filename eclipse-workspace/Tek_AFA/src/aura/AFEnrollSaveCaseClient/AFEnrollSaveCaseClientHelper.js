({
    submitEnrollmentCase : function(component) {
        var saveEnrollmentCaseAction = component.get('c.saveEnrollmentCase');
        var saveRequest = component.get('v.saveRequest');
        var helper = this;

        saveEnrollmentCaseAction.setParams(
            {"requestJSON": JSON.stringify(saveRequest) }
        );
        
        helper.showSpinner(component);
        
        saveEnrollmentCaseAction.setCallback(component, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var saveResult = response.getReturnValue();

                component.set("v.saveResult", saveResult);
            }
            else {
                console.log('Problem getting saving enrollment case. Error: ' + state);
            }
            
            helper.hideSpinner(component);
        });
        
        $A.enqueueAction(saveEnrollmentCaseAction);
    },

    showSpinner : function(component) {
        component.set('v.showSpinner', true);
    },
    
    hideSpinner : function(component) {
        component.set('v.showSpinner', false);
    }
})