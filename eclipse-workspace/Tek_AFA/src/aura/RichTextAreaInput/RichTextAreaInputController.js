({
	getInputComponent : function(component, event, helper) {
		var myInput = component.find('myInput');
		return myInput;
	},
    
    onValueChange : function(component, event, helper){
        var value = component.get("v.value");
        if(value)
            component.set("v.validity", true);
        
        helper.valueChange(component, event);
    }
})