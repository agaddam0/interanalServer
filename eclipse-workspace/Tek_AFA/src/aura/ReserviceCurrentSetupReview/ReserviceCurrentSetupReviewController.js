({
	init : function(component, event, helper) {
        var AccountId = component.get("v.recordId");
        if(AccountId){
            component.set("v.showButtons", false);
            helper.loadCurrentSetupReviewViewOnly(component);
        }
        else {
            helper.shows125OnlyMessage(component);
            helper.loadCustomGrids(component);
            helper.setDisplayOptions(component, event, helper);
        }
	},
    
    handleGridRowAction : function(component, event, helper) {
		var eventSourceGrid = event.getSource();
		var gridId = eventSourceGrid.getLocalId();
		var actionName = event.getParam("actionName");
		var record = event.getParam("record");
		
		if (gridId == "planDatesGrid" || gridId == "eligibleCoverageGrid") {
		    if (actionName == "Details") {
		        helper.loadDetailsModal(component, record.Id);
		    }
		}
	},
    
    closeModal : function(component, event, helper) {
        component.set("v.showAdditionalDetails", false);
    },
    
    closeEligibleCoveragesModal : function(component, event, helper) {
        component.set("v.showAllEligibleCoverages", false);
    },
    
    viewAllEligibleCoverages : function(component, event, helper) {
        helper.viewCoveragesModal(component, event, helper);
    },
    
    navigateToChanges : function(component, event, helper) {
        var enrollmentForm = component.get("v.EnrollmentForm");
        enrollmentForm.Reservice_Making_Changes__c = 'Yes';
        helper.fireMakingChangesFieldEvent(component, event, 'Reservice_Making_Changes__c', 'Yes', 'Enrollment_Form__c', enrollmentForm);
        helper.navigateToPage(component, event, 'ReserviceChanges');
        component.set("v.showButtons", false);
    },
    
    navigateToQuickSetup : function(component, event, helper) {
        var enrollmentForm = component.get("v.EnrollmentForm");
        enrollmentForm.Reservice_Making_Changes__c = 'No';
        helper.fireMakingChangesFieldEvent(component, event, 'Reservice_Making_Changes__c', 'No', 'Enrollment_Form__c', enrollmentForm);
    	helper.navigateToPage(component, event, 'QuickSetup');
    }
})