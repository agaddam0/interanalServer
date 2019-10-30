({
    getInitialContext : function(cmp) {
        var action = cmp.get("c.getInitialCloneEnrollmentOpportunityContext");
        action.setParams({
            'recordId' : cmp.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(cmp.isValid() && state === "SUCCESS") {
                var context = result.getReturnValue();
                cmp.set("v.newOpportunity", context.ClonedOpportunity);
                var newOpportunityForm = cmp.find("cloneOpportunityFields");
                newOpportunityForm.loadComponent(context.ClonedOpportunity);
                cmp.set("v.openEnrollmentOpportunities", context.OpenEnrollmentOpportunities);
                this.toggle(cmp, event);
            }
        });
        $A.enqueueAction(action);
    },

    getClonedOpportunity : function(cmp, event) {
        var action = cmp.get("c.cloneOpportunity");
        action.setParams({
            'recordId' : cmp.get("v.recordId")
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.newOpportunity", result.getReturnValue());
                this.toggle(cmp, event);
            }
        });
        $A.enqueueAction(action);
    },
    
    insertOpportunity : function(cmp, event) {
        this.toggle(cmp, event)
        var newOpportunityForm = cmp.find("cloneOpportunityFields");
        var isValid = newOpportunityForm.validate();
        var oppId = cmp.get("v.recordId");
        if(!isValid)
        {
            this.toggle(cmp, event);
            newOpportunityForm.showValidationMessages();
        }
        else{
            
            newOpportunityForm.clearValidationMessages();
            
            var cloneAction = cmp.get("c.insertClonedOpportunity");
            var opp = cmp.get("v.newOpportunity");
            opp.sobjectType = 'Opportunity';
            cloneAction.setParams({
                'opp' : opp,
                'originalOppId' : oppId
            });
            cloneAction.setCallback(this, function(result){
                var state = result.getState();
                if(cmp.isValid() && state === "SUCCESS") {
                    
                    // Navigate To Reservice Setup Component
                    cmp.set("v.newOpportunity", result.getReturnValue());
                    var goToReserviceComponent = $A.get("e.force:navigateToComponent");
                    goToReserviceComponent.setParams({
                        componentDef : "c:ReserviceSetup",
                        componentAttributes : {
                            recordId : cmp.get("v.newOpportunity.Id")
                        }
                    });
                    goToReserviceComponent.fire();
                }
                else {
                    this.toggle(cmp, event);
                    var errors = result.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                "title": "Save Error",
                                "message": "There was a problem creating the opportunity. " + errors[0].message +                            
                                " Please contact your system administrator."
                            });
                            resultsToast.fire();
                        }
                    } else {
                        var unknresultsToast = $A.get("e.force:showToast");
                        unknresultsToast.setParams({
                            "title": "Save Error",
                            "message": "There was an unknown error when saving the opportunity. " +                           
                            " Please contact your system administrator."
                        });
                        unknresultsToast.fire();
                    }
                }
            });
            
            $A.enqueueAction(cloneAction);
        }       
        
    },

    showEnrollmentForm : function(component) {
        component.set('v.showEnrollmentForm', true);
    },

    toggle: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})