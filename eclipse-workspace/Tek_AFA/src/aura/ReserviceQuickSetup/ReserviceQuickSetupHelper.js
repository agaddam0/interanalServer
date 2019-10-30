({
    validate : function(component, event){
        var formsToValidate = ['generalInfo', 'keyDates', 'platformDetails', 'returnDataInfo', 'setupChanges', 'coreBenefits'];
        var allFormsValid = true;
        
        for(let formName of formsToValidate){
            let form = component.find(formName);
            allFormsValid = allFormsValid && form.validateForm();
        }
        
        return allFormsValid;
    },
    
    disableForms : function(component, event){
        var eventArgs = event.getParam('arguments');
        var disabled = eventArgs.disabled;
        
        component.set("v.disableInputFields", disabled);
        
        var formsToDisable = ['generalInfo', 'keyDates', 'platformDetails', 'returnDataInfo', 'setupChanges', 'coreBenefits'];
        
        for(let formName of formsToDisable){
            let form = component.find(formName);
            form.disableForm(disabled);
        }
    }
})