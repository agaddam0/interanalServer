({
	closeModal : function(component, event, helper) {
		component.set('v.show', false);
		component.set('v.internalShow', false);
	},
	
	handleExceptionChange : function(component, event, helper) {
		// reset so that the next error will show.
		component.set('v.internalShow', true);
	}
})