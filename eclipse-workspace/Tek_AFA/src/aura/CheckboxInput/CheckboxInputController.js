({  
	focus : function(component, event, helper) {
		var myInput = component.find('myInput');
		myInput.focus();
	},
    
    onValueChange : function(component, event, helper) {
        var value = component.get("v.value");
        var label = component.get("v.label");
        
        var valueChangeEvent = component.getEvent("fieldChange");
        valueChangeEvent.setParams({
            "fieldValue" : value,
            "fieldLabel" : label
        });
        valueChangeEvent.fire();
    }
})