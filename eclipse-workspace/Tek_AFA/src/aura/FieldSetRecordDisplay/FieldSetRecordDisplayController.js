({
	init : function(component, event, helper) {
		var loadOnInit = component.get('v.loadOnInit');
		
		if (!loadOnInit) {
			return;
		}
		
		helper.loadComponent(component, event, helper);
	},
	
	handleRecordChange : function(component, event, helper) {
	    var isRecordSetFromQuery = component.get('v.recordSetInQuery');

	    if (!isRecordSetFromQuery) {
		    helper.loadComponent(component, event, helper);
		}
	},
	
	handleFieldSetNameChange : function(component, event, helper) {
		helper.loadComponent(component, event, helper);
	},
	
	handleRecordIdChange : function(component, event, helper) {
		helper.loadComponent(component, event, helper);
	},
	
	reload : function(component, event, helper) {
		helper.loadComponent(component, event, helper);
	}
})