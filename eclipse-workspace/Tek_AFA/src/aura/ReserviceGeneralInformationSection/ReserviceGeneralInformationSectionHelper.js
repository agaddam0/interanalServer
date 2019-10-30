({
    setDefaults : function(component) {
        var opportunity = component.get("v.Opportunity");
        
        if(!opportunity.EE_Eligibility_Waiting_Period__c) {
            component.set('v.showEligibilityWaitingPeriod', true);
            
            this.EligibilityWaitingPeriodChange(component, opportunity.EE_Eligibility_Waiting_Period__c);
        }
        
        if(!opportunity.Waiting_Period_Effective__c){
            component.set('v.showWaitingPeriodEffective', true);
        } 
    },
    
    EligibilityWaitingPeriodChange : function(component, value){
        var showField = value == 'Other';
        component.set('v.showOtherEligibilityWaitingPeriod', showField);
    },
    
    validateForms : function(component){
        var opportunity = component.get("v.Opportunity");
        var isValid = true;
        
        var generalInfoForm = component.find("opportunityGeneralInfo");
        generalInfoForm.clearValidationMessages();
        if(!generalInfoForm.validate()){
            isValid = false;
            generalInfoForm.showValidationMessages();
        }
        
        if(component.get("v.showEligibilityWaitingPeriod")){
            var opportunityGenInfoWaiting = component.find("opportunityGenInfoWaiting");
            opportunityGenInfoWaiting.clearValidationMessages();
            if(!opportunityGenInfoWaiting.validate()){
                isValid = false;
                opportunityGenInfoWaiting.showValidationMessages();
            }
        }
        
        if(component.get("v.showOtherEligibilityWaitingPeriod")){
            var opportunityGenInfoOther = component.find("opportunityGenInfoOther");
            opportunityGenInfoOther.clearValidationMessages();
            if(!opportunityGenInfoOther.validate()){
                isValid = false;
                opportunityGenInfoOther.showValidationMessages();
            }
        }
        
        if(component.get("v.showWaitingPeriodEffective")){
            var opportunityGenInfoEffective = component.find("opportunityGenInfoEffective");
            opportunityGenInfoEffective.clearValidationMessages();
            if(!opportunityGenInfoEffective.validate()){
                isValid = false;
                opportunityGenInfoEffective.showValidationMessages();
            }
        }
        
        component.set("v.isValid", isValid);
        return isValid;
    },
    
    disableForms : function(component, event){
        var eventArgs = event.getParam('arguments');
        var disabled = eventArgs.disabled;
        
        component.set("v.disableFormFields", disabled);
        
        var generalInfoForm = component.find("opportunityGeneralInfo");
        generalInfoForm.clearValidationMessages();
        generalInfoForm.disableForm(disabled);
        
        if(component.get("v.showEligibilityWaitingPeriod")){
            var opportunityGenInfoWaiting = component.find("opportunityGenInfoWaiting");
            opportunityGenInfoWaiting.disableForm(disabled);
        }
        
        if(component.get("v.showOtherEligibilityWaitingPeriod")){
            var opportunityGenInfoOther = component.find("opportunityGenInfoOther");
            opportunityGenInfoOther.disableForm(disabled);
        }
        
        if(component.get("v.showWaitingPeriodEffective")){
            var opportunityGenInfoEffective = component.find("opportunityGenInfoEffective");
            opportunityGenInfoEffective.disableForm(disabled);
        }
    }
})