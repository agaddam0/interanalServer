({
    init : function(component, event, helper){
        helper.setDefaults(component);
    },
    
    handleEvent : function(component, event, helper) {
		var value = event.getParam("values");
        var field = event.getParam("fieldName");
        var item = event.getSource();
        item.set("v.value", value);
        
        if(field == 'Enroll_Info_Upload__c'){
            if(value == 'Yes')
                component.set("v.showPayrollDetails", true);
            else
                component.set("v.showPayrollDetails", false);
            
        }
	},
    
    validateForm : function(component, event, helper){
        return helper.validateFieldSets(component);
    },
    
    disableForm : function(component, event, helper){
        helper.disableForm(component, event);
    },

    checkBusinessDays : function(component, event, helper){
        var field = event.getParam("fieldName");
        var value = event.getParam("fieldValue");

        if(field == 'EnrollInfoUploadDueDate__c'){
            helper.checkPayrollRush(component, value);
        }
    }
})