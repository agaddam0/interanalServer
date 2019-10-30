({
    viewDetailsGridRowActions : [
	    {Label: "Details", ActionName: "Details", Type: "Link"}
	],
    
    setDisplayOptions : function(component, event, helper){
        var enrollmentForm = component.get("v.EnrollmentForm");
        
        if(enrollmentForm.Reservice_Making_Changes__c == 'Yes'){
            component.set("v.showButtons", false);
            helper.navigateToPage(component, event, 'ReserviceChanges');
        }
        else{
            component.set("v.showButtons", true);
        }
    },
    
    shows125OnlyMessage : function(component) {
        var s125OnlyCheckAction = component.get("c.s125Check");
        var account = component.get("v.Account");
        s125OnlyCheckAction.setParams({
            'accountId' : account.Id
        });
        
        s125OnlyCheckAction.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid && state === "SUCCESS") {
                var showS125Message = result.getReturnValue();
                component.set('v.showS125Message', showS125Message);
            }
        });
        
        $A.enqueueAction(s125OnlyCheckAction);
        
    },
    
    loadCustomGrids : function(component){
        this.setWhereClauses(component);
        
        var groupProductsGrid = component.find("GroupProductsGrid");
        groupProductsGrid.reloadRecords();
        
        var MarketedProductsGrid = component.find("MarketedProductsGrid");
        MarketedProductsGrid.reloadRecords();
        
        var planDatesGrid = component.find('planDatesGrid');
        planDatesGrid.reloadRecords();
        
        var eligibleCoverageGrid = component.find("eligibleCoverageGrid");
        eligibleCoverageGrid.reloadRecords();
        
        var billModesGrid = component.find("billModesGrid");
        billModesGrid.reloadRecords();
        
        var allCoveragesGrid = component.find("allCoveragesGrid");
        allCoveragesGrid.reloadRecords();
    },
    
    setWhereClauses : function(component){
        var account = component.get("v.Account");
        var eForm = component.get("v.EnrollmentForm");
        component.set('v.GroupProductsWhereClause', "WHERE Account__c = '" + account.Id + "'");
        component.set('v.MarketedProductsWhereClause', "WHERE Enrollment__c = '" + eForm.Id + "'" + " AND Products__r.Allowed_To_Be_Added_To_Enrollment__c = true");
        component.set('v.AgencyImportProductsWhereClause', "WHERE Account__c = '" + account.Id + "' AND Policy_Status__c != 'Inactive'");
        component.set('v.PlanDatesWhereClause', "WHERE Account__c = '" + account.Id + "'");
        component.set('v.EligibleCoveragesWhereClause', "WHERE BenefitCode__c IN ('URM', 'DDC', 'LPF', 'HSA', 'HRA') AND planDateRecord__r.Account__c = '" + account.Id + "'");
        component.set('v.BillModesWhereClause', "WHERE Account__c = '" + account.Id + "'");
        component.set('v.AllEligibleCoveragesWhereClause', "WHERE planDateRecord__r.Account__c = '" + account.Id + "'");
        component.set("v.detailsGridRowActions", this.viewDetailsGridRowActions);
    }, 
    
    loadDetailsModal : function(component, recordId) {
        component.set('v.showAdditionalDetailsId', recordId);
        component.set('v.showAdditionalDetails', true);
    },
    
    viewCoveragesModal : function(component, event, helper) {
        component.set("v.showAllEligibleCoverages" , true);
    },
    
    fireMakingChangesFieldEvent : function(component, event, fieldName, value, objectName, record) {
        // mimicking the fieldSetValue change event so follow the same flow process as other field changes
        var fieldValueChangeEvent = $A.get("e.c:FieldSetFormValueChange");
        
        fieldValueChangeEvent.setParams({
            "sObjectName" : objectName,
            "record" : record,
            "fieldName" : fieldName,
            "fieldValue" : value
        });
        fieldValueChangeEvent.fire();
    },
    
    loadCurrentSetupReviewViewOnly : function(component){
        var getObjectsAction = component.get('c.getSetupFormDataFromAccountId');
        
        getObjectsAction.setParams({
            "accountId" : component.get("v.recordId")
        });
        
        getObjectsAction.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                var context = result.getReturnValue();
                component.set('v.Opportunity', context.EnrollmentOpportunity);
                component.set('v.EnrollmentForm', context.EnrollmentForm);
                component.set("v.Account", context.CustomerAccount);
                this.shows125OnlyMessage(component);
                this.loadCustomGrids(component);
            }
        });
        
        $A.enqueueAction(getObjectsAction);
    }
})