({
    simpleChangesCustomAttributes : {
        'Change_Flex_Amount__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Change_AFenroll_Frequencies__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Add_Individual_Plan_s__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Add_Import_Plan_s__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Change_Administrative_Contact__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'} ,
        'Add_a_DVR__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Add_Texas_Life__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'}
    },
    
    significantChangesCustomAttributes : {
        'Add_a_New_Group_Plan_s__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Add_a_Section_125_Plan__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Add_a_FSA__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Add_a_HSA__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Add_a_HRA__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Add_a_New_Billing_Mode__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'},
        'Add_an_Annuity__c' : { showLabelFirst : 'true', 'class' : 'af-large-checkbox'}
    },
    
    setCustomAttributes : function(component) {        
        component.set('v.SimpleCustomAttributes', this.simpleChangesCustomAttributes);        
        component.set('v.SignificantCustomAttributes', this.significantChangesCustomAttributes);
    },
    
    disableForm : function(component, event){
        var eventArgs = event.getParam('arguments');
        var disabled = eventArgs.disabled;
        
        component.set("v.disableInputFields", disabled);
        
        var simpleForm = component.find("simpleChangesForm");
        if(simpleForm){
            simpleForm.disableForm(disabled);
        }
            
        
        var significantForm = component.find("significantChangesForm");
        if(significantForm)
            significantForm.disableForm(disabled);
    },
    
    navigateDecision : function(component, event, helper){
        //TODO: get current opportunity formula values from the server
        
        var checkSignificantChangesAction = component.get('c.checkSignificantChanges');
        var opportunity = component.get("v.Opportunity")
        
        checkSignificantChangesAction.setParams({
            "opportunityId" : opportunity.Id
        });
        
        checkSignificantChangesAction.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                var isSignificantChanges = result.getReturnValue();
                var opportunity = component.get("v.Opportunity");
                if(isSignificantChanges)
                    this.navigateToFullSetupForms(component, event, opportunity.Id);
                else {
                    this.reload(component, event);
                    helper.navigateToPage(component, event, 'QuickSetup');
                }
                    
            }
        });
        
        $A.enqueueAction(checkSignificantChangesAction);
    },
    
    navigateToFullSetupForms : function(component, event, opportunityId) {
        var toToSetupForms = $A.get("e.force:navigateToURL");
        toToSetupForms.setParams({
            "url" : "/apex/GeneralInformation?id=" + opportunityId + '&ReserviceSetup=true'
        });
        toToSetupForms.fire();
    },
    
    reload : function(component, event){
        var reloadReserviceEvent = $A.get("e.c:ReloadReserviceSetup");
		reloadReserviceEvent.fire();
    }
})