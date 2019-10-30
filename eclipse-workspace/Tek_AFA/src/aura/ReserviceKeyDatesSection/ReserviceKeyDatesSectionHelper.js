({
    validateFieldSets : function(component){
        var isValid = true;
        
        var opportunityDates = component.find("opportunityKeyDates");
        if(opportunityDates){
            opportunityDates.clearValidationMessages();
            isValid = opportunityDates.validate();
            opportunityDates.showValidationMessages();
        }
        
        var platformDates = component.find("platformSetupKeyDates");
        if(platformDates){
            platformDates.clearValidationMessages();
            isValid = platformDates.validate();
            platformDates.showValidationMessages();
        }  
        
        return isValid;
    },
    
    disableForm : function(component, event){
        var eventArgs = event.getParam('arguments');
        var disabled = eventArgs.disabled;
        
        component.set("v.disableFormFields", disabled);
        
        var opportunityDates = component.find("opportunityKeyDates");
        if(opportunityDates){
            opportunityDates.disableForm(disabled);
        }
        
        var platformDates = component.find("platformSetupKeyDates");
        if(platformDates){
            platformDates.disableForm(disabled);
        }  
    }
})