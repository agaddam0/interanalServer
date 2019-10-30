({
	doInit : function(component, event, helper) {
		helper.loadOptions(component);
	},
    
    getInputComponent : function(component, event, helper) {
        var myInput = component.find('myInput');
		return myInput;
    }
})