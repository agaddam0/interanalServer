({
	setActiveTabs : function(component, pageName) {
        this.resetTabs(component);
        
		if(pageName == 'CurrentSetupReview' || pageName == 'ReserviceChanges'){
            component.set('v.currentSetupReviewActive', true);
        }
        
        if(pageName == 'QuickSetup'){
            component.set('v.quickSetupActive', true);
        } 
	},
    
    resetTabs : function(component) {
        component.set('v.currentSetupReviewActive', false);
        component.set('v.quickSetupActive', false);
    },
    
    navigateToOpportunity : function(component, event){
        var navigateEvent = $A.get("e.force:navigateToSObject");
        
        navigateEvent.setParams({
            "recordId" : component.get("v.opportunityId")
        });
        
        navigateEvent.fire();
    },
    
    navigateToPreEnrollmentForm : function(component, event) {
        var preEnrollmentFormId = component.get("v.preEnrollmentMarketingFormId");
        var goToPreEnrollmentForm = $A.get("e.force:navigateToURL");
        goToPreEnrollmentForm.setParams({
            "url" : "/apex/PreenrollmentMarketingSetupForm?id=" + preEnrollmentFormId + '&ReserviceSetup=true'
        });
        goToPreEnrollmentForm.fire();
    },
    
    getPreEnrollmentForm : function(component, event) {
        var getPreEnrollmentFormId = component.get("c.getPreEnrollmentMarketingFormId");
        getPreEnrollmentFormId.setParams({
            "opportunityId" : component.get("v.opportunityId")
        });
        
        getPreEnrollmentFormId.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                var preEnrollmentFormId = result.getReturnValue();
                if(preEnrollmentFormId){
                    component.set("v.preEnrollmentMarketingFormId", preEnrollmentFormId);
                    component.set("v.showConfirmModal", true);
                } 
                else
                    this.navigateToOpportunity(component, event);
            }
        });
        
        $A.enqueueAction(getPreEnrollmentFormId);
    },
    
    validate : function(component, event){
        component.set("v.showSpinner", true);
        var validateEvent = component.getEvent("validateFormEvent");
        validateEvent.fire();
    },
    
    canSubmitForm : function(component, event){
        var params = event.getParam('arguments');
        var isValid = false;
        if(params)
            isValid = params.isValid;
        
        if(isValid)
            this.submitForm(component);
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Invalid Form",
                "message": "Please fill out the required fields.",
                "type" : 'error'
            });
            toastEvent.fire();
            component.set("v.showSpinner", false);
        }
    },
    
    submitForm : function(component, event){
        var submitAction = component.get("c.submitReserviceForm");
        
        submitAction.setParams({
            "opportunityId" : component.get("v.opportunityId")
        });
        
        submitAction.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                this.getPreEnrollmentForm(component, event);
                this.disableForms(component, event, true);
                component.set("v.statusMessage", 'Submitted');
                component.set("v.showRequestEdit", true);
                component.set("v.showSubmitButton", false);
                component.set("v.showUnlockRequest", true);
            }
            else
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Something went wrong",
                    "message": "There was an error submitting the form. Please contact your system administrator.",
                    "type" : 'error'
                });
                toastEvent.fire();
            }
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(submitAction);
    },
    
    disableForms : function(component, event, disabled){
        var disableFormsEvent = component.getEvent("disableFormEvent");
        disableFormsEvent.setParams({
            "setDisabled" : disabled
        })
        disableFormsEvent.fire();
    },
    
    sendRequestEdit : function(component, event) {
    	var requestEditAction = component.get("c.RequestEdit");
        
        requestEditAction.setParams({
            "opportunityId" : component.get("v.opportunityId")
        })
        
        requestEditAction.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                var requestEditMessage = result.getReturnValue();
                component.set("v.requestEditMessage", requestEditMessage);
                component.set("v.showRequestEdit", false);
                
                if(!requestEditMessage){
                    component.set("v.statusMessage", 'In Progress');
                    component.set("v.showSubmitButton", true);
                    component.set("v.showUnlockRequest", false);
                }
                
                this.disableForms(component, event, false);
                
                component.set("v.showSpinner", false);
            }
        });
        
        $A.enqueueAction(requestEditAction);
    },
    
    setStatus : function(component, event) {
        var params = event.getParam('arguments');
        var status = params.Status;
        var requestEdit = params.RequestEdit;
        
        if(requestEdit){
            component.set("v.requestEditMessage", ' - Request Edit Sent');
            component.set("v.showRequestEdit", false);
        }
        
        if(status != 'In Progress')
        {
            component.set("v.showRequestEdit", true);
            component.set("v.showSubmitButton", false);
            component.set("v.showUnlockRequest", true);
        }
        else{
            component.set("v.showUnlockRequest", false);
        }
        
        component.set("v.statusMessage", status);
    },

    setEnrollmentId : function(component, event){
        var enrollmentFormId = event.getParam('arguments').enrollmentId;

        var unlockRequest = component.find('unlockRequest');
        unlockRequest.setEnrollmentFormId(enrollmentFormId);
    }        
})