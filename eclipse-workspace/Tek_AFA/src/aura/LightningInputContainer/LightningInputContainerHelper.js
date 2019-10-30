({
    valueChange : function(component, event) {
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