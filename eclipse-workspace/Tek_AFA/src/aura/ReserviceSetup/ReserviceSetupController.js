({
	init : function(component, event, helper) {
		helper.getObjects(component, event);
	},
    
    showPages : function(component, event, helper) {
        var desiredNavigationPage = event.getParam("navigate");
        
        helper.showPages(component, helper, desiredNavigationPage);
    }, 
    
    saveRecord : function(component, event, helper) {
        var record = event.getParam("record");
        helper.save(component, event, record);
        
        var field = event.getParam("fieldName");
        var objectName = event.getParam("sObjectName");
        var value = event.getParam("fieldValue");
        
        if(objectName == 'Opportunity' && field == 'Add_a_DVR__c'){
            helper.updateMarketedProduct(component, event, value);
        }
        
        if(objectName == 'Enrollment_Form__c' && field == 'Reservice_Making_Changes__c'){
            helper.enableSubmitButton(component, event);
        }
    },
    
    validate : function(component, event, helper) {
        helper.validate(component);
    },
    
    disableForms : function(component, event, helper) {
        helper.disableForms(component, event);
    },
    
    handleInFormSubmit: function(component, event, helper){
        var navBar = component.find("navBar");
        navBar.submitFormFromComponent();
    }
})