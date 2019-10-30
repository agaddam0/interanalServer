({
	doInit : function(component, event, helper) {
        var action = component.get("c.getPicklistOptions");
        console.log(component.get('v.fieldName'));
        action.setParams({
            'fieldName' : component.get('v.fieldName'),
            'sObjectName' : component.get('v.sObjectName')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS")
            {
                var opts = response.getReturnValue();
                var newSelectOpts = [];
                
                var allowNoneOption = component.get('v.allowNoneOption');
                
                if (allowNoneOption) {
                	newSelectOpts.push({class: 'optionClass', label: '-- None --', value: '', selected: true });
                }

                for (var i = 0; i < opts.length; i++) 
                { 
                    newSelectOpts.push({class: 'optionClass', label: opts[i], value: opts[i] });
                }
                
                if(component.get("v.multiple")){
                    component.set("v.options", newSelectOpts);

                    var multiPicklistFieldCmp = component.find("multiPicklistField");

                    if (multiPicklistFieldCmp) {
                        multiPicklistFieldCmp.setValues();
                    }
                }

                var picklistFieldCmp = component.find('picklistField');

                if (picklistFieldCmp) {
                    picklistFieldCmp.set('v.options', newSelectOpts);
                }
                
                var initialValue = component.get('v.initialValue');
                var currentValue = component.get('v.value');
                
                if (initialValue != currentValue) {
                	component.set('v.value', initialValue);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    handleChangeEvent : function(component, event) {
        var eventSource = event.getSource();
        var values = eventSource.get("v.value");
        var cmpEvent = component.getEvent("valueChange");
        var fieldName = component.get('v.fieldName');
        var label = component.get("v.label");
        cmpEvent.setParams({
            "values" : values,
            "fieldName" : fieldName
        });
        cmpEvent.fire();
        
        // new event for detecting changes
        var valueChangeEvent = component.getEvent("fieldChange");
        valueChangeEvent.setParams({
            "fieldValue" : values,
            "fieldLabel" : label
        });
        valueChangeEvent.fire();
    },
    
    getInputComponent : function(component, event, helper) {
    	var inputCmp = component.find('picklistField');
    	return inputCmp;
    }
})