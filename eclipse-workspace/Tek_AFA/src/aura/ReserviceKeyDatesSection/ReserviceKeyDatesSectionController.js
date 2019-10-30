({    
    validateForm : function(component, event, helper){
        return helper.validateFieldSets(component);
    },
    
    disableForm : function(component, event, helper){
        helper.disableForm(component, event);
    }
})