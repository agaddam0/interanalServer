({
	navigateToQuickSetup : function(component, event, helper) {
		helper.navigateToPage(component, event, "QuickSetup");
	},
    
    navigateToChanges : function(component, event, helper) {
		helper.navigateToPage(component, event, "ReserviceChanges");
	},
 
    navigateToSummary : function(component, event, helper) {
        var canNavigate = component.get("v.showSubmitButton");
        var status = component.get("v.statusMessage");
        if(canNavigate || status != 'In Progress')
            helper.navigateToPage(component, event, "CurrentSetupReview");
	},
    
    setActiveTabs : function(component, event, helper) {
        var pageName = event.getParam("navigate");
        
        helper.setActiveTabs(component, pageName);
    },
    
    navigateToOpportunity : function(component, event, helper) {
        helper.navigateToOpportunity(component, event);
    },
    
    submitForm : function(component, event, helper) {
        helper.validate(component);
    },
    
    canSubmit : function(component, event, helper){
        helper.canSubmitForm(component, event);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.showConfirmModal" , false);
    },
    
    navigateToPreEnrollment : function(component, event, helper) {
        helper.navigateToPreEnrollmentForm(component, event);
    },
    
    displaySubmitButton : function(component, event, helper) {
        var status = component.get("v.statusMessage");
        if(status == 'In Progress'){
            component.set("v.disableSubmitButton", false);
            component.set("v.showSubmitButton", true);
            component.set("v.showUnlockRequest", false);
        }        
    },
    
    requestEdit : function(component, event, helper){
        component.set("v.showSpinner", true);
        helper.sendRequestEdit(component, event);
    },
    
    setStatus : function(component, event, helper){
        helper.setStatus(component, event);
    },
    
    submitFormFromComponent : function(component, event, helper){
        helper.validate(component);
    },

    setEnrollmentFormId : function(component, event, helper){
        helper.setEnrollmentId(component, event);
    },

    unlockForm : function(component, event, helper){
        var unlockForm = event.getParams('arguments').UnlockForm;
        helper.disableForms(component, event, !unlockForm);
    }
})