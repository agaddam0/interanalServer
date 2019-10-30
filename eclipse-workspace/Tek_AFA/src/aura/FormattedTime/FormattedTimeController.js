({
	doInit : function(component, event, helper) {
		var isMilliseconds = false;
		var value = component.get('v.value');
		
		// When time values are serialized from Apex back into JSON, they're converted
		// into the number of milliseconds in a day for some reason so detect that
		// and handle accordingly.
		if (value) {
		    var valueStr = value.toString();
		    isMilliseconds = valueStr.indexOf(':') == -1;
		    
		    // After a time is edited via lightning:input, it lacks the Z so 
		    // reappend it to ensure proper formatting.
		    if (!isMilliseconds && !valueStr.endsWith('Z')) {
		        valueStr += 'Z';
		        component.set('v.value', valueStr);
		    }
		}
		// Handle midnight as a special case
		else if (value === 0) {
		    isMilliseconds = true;
		    component.set('v.value', '00:00:00Z');
		}
		
		component.set('v.isMillisecondsTimeValue', isMilliseconds);
	}
})