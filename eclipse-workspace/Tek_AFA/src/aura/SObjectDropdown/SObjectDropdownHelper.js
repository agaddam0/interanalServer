({
	loadOptions : function(component) {
		var displayField = component.get('v.displayField');
		var sobjectName = component.get('v.sobjectName');
	
		var getSObjectRecordsAction = component.get('c.getSObjectRecords');
		
		getSObjectRecordsAction.setParams({
			"sObjectName": sobjectName,
			"displayField": displayField
		});
		
		getSObjectRecordsAction.setCallback(component, function(response){
			var state = response.getState();
			
			if (component.isValid() && state === "SUCCESS") {
                var currentValue = component.get('v.value');
				var records = response.getReturnValue();
                var blankOptionLabel = component.get('v.blankOptionLabel');
                //
                var options = [{label: blankOptionLabel, value: ''}];
                var currentValue = component.get('v.value');

				for (let record of records) {
					let option = {};
					
					option.value = record.Id;
					option.label = record[displayField];
                    option.selected = option.value == currentValue;
                    
                    options.push(option);
				}

				component.set('v.options', options);
			}
			else {
				console.log('Problem updating the marketing material. Response state: ' + state);
			}
		});
		
		$A.enqueueAction(getSObjectRecordsAction);
	}
})