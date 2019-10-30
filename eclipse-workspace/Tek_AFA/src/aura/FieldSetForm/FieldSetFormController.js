({
	init: function(cmp, event, helper) {
		var loadOnInit = cmp.get('v.loadOnInit');
		
		if (!loadOnInit) {
			return;
		}

        console.log('FieldSetFormController.init');
		
		helper.loadComponent(cmp, event);
    },
    
    loadComponent: function(cmp, event, helper) {
        helper.loadComponent(cmp, event);
    },
    
    loadComponentUsingQueriedRecord: function(cmp, event, helper) {
    	helper.loadComponentUsingQueriedRecord(cmp, event, helper);
    },
    
    onErrorResponseChange : function(cmp, event, helper) {
    	var errorResponse = event.getParam("value");
    	
    	if (errorResponse) {
    		helper.showErrorsFromResponse(cmp, errorResponse);
    	}
    },

    validate : function(cmp, event, helper) {
        return helper.validateFieldSet(cmp, event);
    },
    
    showValidationMessages : function(cmp, event, helper) {
    	helper.showValidationMessages(cmp);
    },
    
    clearValidationMessages : function(cmp, event, helper) {
    	helper.clearErrorsInFields(cmp);
    },
    
    fieldSetFieldValueChange : function(component, event, helper) {
        helper.fireValueChangeEvent(component, event);
    },
    
    disableForm : function(component, event, helper){
        helper.disableForm(component, event);        
    }
})