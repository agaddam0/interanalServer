({
	focus : function(component, event, helper) {
		var inputCmp = component.getInputComponent();
		
		if (inputCmp &&
		    typeof inputCmp.focus === "function") {
		    inputCmp.focus();
		}
	},
	
	showRequiredFieldMessage : function(component, event, helper) {
		var inputCmp = component.getInputComponent();
		
		if (!inputCmp) {
			return;
		}
		
		if (typeof inputCmp.showHelpMessageIfInvalid === "function") {
		    inputCmp.showHelpMessageIfInvalid();
		}
		
		if (inputCmp.isInstanceOf('ui:input')) {
			var requiredFieldError = {message: 'Complete this field.'};
			
			inputCmp.set('v.errors', [requiredFieldError]);
		}
        
        if(inputCmp.isInstanceOf('lightning:inputRichText')){
            component.set("v.validity" , false);
        }
	},
	
	hideRequiredFieldMessage : function(component, event, helper) {
		var inputCmp = component.getInputComponent();
		
		if (inputCmp && inputCmp.isInstanceOf('ui:input')) {
			inputCmp.set('v.errors', []);
		}
        
        if(inputCmp && inputCmp.isInstanceOf('lightning:inputRichText')){
            component.set("v.validity" , true);
        }
	},
    
    onValueChange : function(component, event, helper) {
        helper.valueChange(component, event);
    }
})