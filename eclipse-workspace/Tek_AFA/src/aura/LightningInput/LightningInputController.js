({
    doInit : function(component, event, helper) {
        var inputType = component.get('v.type');
        
        // Times are serialized into JSON as an integer representing
        // the number of milliseconds in a day from the Apex controller
        // so convert it back to the HH:MM:SS.000Z format for proper
        // editing. In Apex, they have the HH:MM:SS.000Z value but 
        // get serialized differently when returned.
        if (inputType && inputType == 'time') {
            var inputValue = component.get('v.value');

            if (inputValue && inputValue.toString().length == 8) {
                var correctedTimeValue = new Date(inputValue).toISOString().slice(11);
                
                component.set('v.value', correctedTimeValue);
            }
        }
    },

	getInputComponent : function(component, event, helper) {
		var myInput = component.find('myInput');
		return myInput;
	}
})