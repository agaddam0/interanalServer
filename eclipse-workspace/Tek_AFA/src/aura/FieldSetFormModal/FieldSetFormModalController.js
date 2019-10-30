({
	showModalUsingRecord : function(component, event, helper) {
		helper.showModal(component, event, helper, false);
	},
	
	showModalUsingQuery : function(component, event, helper) {
		helper.showModal(component, event, helper, true);
	},

	hideFieldSetFormOverlayLibrary : function(component, event, helper) {
		helper.hideModal(component);
	},
	
	validate : function(component, event, helper) {
		return helper.validate(component);
	},
	
	showValidationMessages : function(component, event, helper) {
		helper.showValidationMessages(component);
	},
	
	clearValidationMessages : function(component, event, helper) {
		helper.clearValidationMessages(component);
	}
})