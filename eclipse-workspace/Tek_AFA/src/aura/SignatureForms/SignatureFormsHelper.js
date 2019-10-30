({
    getSignatures : function(component, event) {
        var action = component.get("c.getSignatureForms");
        
        action.setParams({
            'recordId' : component.get('v.recordId') 
        });
        
        action.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.SignatureForms", result.getReturnValue());
            }
            this.toggle(component, event);
        });
        $A.enqueueAction(action);
    },    
    
	toggle: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})