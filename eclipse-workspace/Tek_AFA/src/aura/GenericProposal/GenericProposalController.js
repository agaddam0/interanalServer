({
	doInit : function(component, event, helper) {
        helper.toggle(component, event);
        helper.loadRecords(component, event);
        helper.loadUser(component);
	},
    
    handleEvent : function(component, event, helper) {
		var value = event.getParam("values");
        var field = event.getParam("fieldName");
        var item = event.getSource();
        item.set("v.value", value);
        helper.validateForm(component);
	},
    
    handleCancel : function(component, event, helper) {
        helper.deleteProposal(component, event);
    },
    
    handleSave : function(component, event, helper) {
        helper.saveProposal(component, event);
    },
    
    handleSubmit : function(component, event, helper) {
        helper.submitProposal(component, event);
    },
    
    handleChange : function(component, event, helper) {
        
    }
})