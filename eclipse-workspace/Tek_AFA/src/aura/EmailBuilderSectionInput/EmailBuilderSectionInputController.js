({
    onInit : function(component, event, helper) {
        helper.loadDynamicComponents(component);
    },
    
    inputValueChange : function(component, event, helper) {
        helper.loadDependentInputsOnValueSelection(component);
        helper.loadEditExistingDataLink(component, helper);
    },
    
    validate : function(component, event, helper) {
        return helper.validate(component);
    }
})