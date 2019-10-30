({
    loadAppointmentScheduler : function(component) {
        var getEligibleAccountsAction = component.get('c.getEligibleAccounts');
        var helper = this;

        getEligibleAccountsAction.setCallback(component, function(response){
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var eligibleAccountsResponse = response.getReturnValue();
                component.set("v.Accounts", eligibleAccountsResponse);
                
                // Call the chosen code a little later so that the select list has time to finish being updated
                // before chosen is applied. Otherwise, it creates an empty select.
                setTimeout(function(){
                    $(".chosen-select").chosen({
                        search_contains: true
                    });
                    
                    // Registering onchange in the select markup doesn't work for some reason but this does.
                    $('.chosen-select').on('change', { "component": component, "helper": helper }, function(event, params) {
                        var component = event.data.component;
                        var helper = event.data.helper;

                        helper.onEmployerSelected(component, params.selected);
                    });
                    
                    helper.hideSpinner(component);

                }, 500);
                
                var pageReference = component.get('v.pageReference');
                
                if (pageReference && pageReference.state && pageReference.state.c__AccountId) {
                    component.set('v.preselectedAccountId', pageReference.state.c__AccountId);
                
                    helper.onEmployerSelected(component, pageReference.state.c__AccountId);
                }
            }
            else {
                console.log('Problem getting eligible accounts. Response state: ' + state);
            }
            
            helper.hideSpinner(component);
        });
        
        $A.enqueueAction(getEligibleAccountsAction);
    },
    
    onEmployerSelected : function(component, selectedEmployer) {
        var helper = this;

        if (!selectedEmployer) {
            helper.clearAppointmentScheduler(component);
        
            return;
        }
        
        helper.showSpinner(component);
        
        var getEmployerAppointmentSchedulerURLAction = component.get('c.getEmployerAppointmentSchedulerURL');
        getEmployerAppointmentSchedulerURLAction.setParams({"accountId": selectedEmployer});
        
        getEmployerAppointmentSchedulerURLAction.setCallback(component, function(response){
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var employerAppointmentSchedulerURLResponse = response.getReturnValue();
                
                if (employerAppointmentSchedulerURLResponse &&
                    employerAppointmentSchedulerURLResponse.EmployerAppointmentSchedulerURL) {
                    component.set('v.EmployerAppointmentSchedulerURL', employerAppointmentSchedulerURLResponse.EmployerAppointmentSchedulerURL)
                }
                else {
                    component.set('v.EmployerAppointmentSchedulerErrorMessage', employerAppointmentSchedulerURLResponse.ErrorMessage);
                }
            }
            else {
                console.log('Problem getting employer appointment scheduler url. Response state: ' + state);
            }
            
            helper.hideSpinner(component);
        });

        $A.enqueueAction(getEmployerAppointmentSchedulerURLAction);
    },
    
    clearAppointmentScheduler : function (component) {
        component.set('v.EmployerAppointmentSchedulerURL', '');
        component.set('v.EmployerAppointmentSchedulerErrorMessage', '');
    },
    
    showSpinner : function(component) {
        component.set('v.showSpinner', true);
    },
    
    hideSpinner : function(component) {
        component.set('v.showSpinner', false);
    }
})