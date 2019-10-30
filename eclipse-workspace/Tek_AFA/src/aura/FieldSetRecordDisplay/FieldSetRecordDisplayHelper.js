({
	loadComponent: function(component, event, helper) {
	    var loadRecordFromServer = component.get('v.loadRecordFromServer');
	    
	    if (loadRecordFromServer) {
	        helper.loadComponentUsingQuery(component, event, helper);
	    
	        return;
	    }
	    
	    var fieldsToUse = component.get('v.fieldsToUse');
	    
	    if (Array.isArray(fieldsToUse) && fieldsToUse.length > 0) {
	    	// copy the fields so that there's no weird circular dependency
	    	// which causes the form to reload multiple times and then causes the record
	    	// to be tied to the wrong object.
	    	var fieldsToUseCopy = JSON.parse(JSON.stringify(fieldsToUse));
	    
	    	helper.loadFieldsUsingSuppliedFields(component, fieldsToUseCopy);
	    	return;
	    }
	    
	    helper.loadFieldsFromServer(component);
	},
	
	loadFieldsUsingSuppliedFields : function(component, fields) {
        var customAttributes = component.get('v.customAttributes');
        
        for (field of fields) {
        	field.FieldValue = component.get('v.record.' + field.APIName);
            
            if (field.Type && field.Type.toLowerCase() == "reference") {
                var parentNameFieldReference;
                
                if(field.APIName.endsWith('__c')) {
                    parentNameFieldReference = field.APIName.replace('__c', '__r.Name');
                }
                else if(field.APIName.endsWith('Id')){
                    parentNameFieldReference = field.APIName.replace('Id', '.Name');
                    field.Label = field.Label.replace(' ID', '');
                }
                
                var parentNameReference = component.getReference('v.record.' + parentNameFieldReference);
                
                if (parentNameReference) {
                    field.FieldValue = parentNameReference;
                }
            }
        	
        	if (customAttributes) {
            	var customFieldAttributes = customAttributes[field.APIName];
            	
            	if (customFieldAttributes) {
            		Object.assign(field, customFieldAttributes);
            	}
        	}
        }

        component.set('v.fields', fields);
	},
	
	loadFieldsFromServer : function(component) {
		var action = component.get('c.getFields');
		var helper = this;
		
		var fieldSetName = component.get('v.fieldSetName');
		var objectName = component.get('v.objectName');
		
		if (!fieldSetName || !objectName) {
			return;
		}
    	
        action.setParams({
            fieldSetName: fieldSetName,
            objectName: objectName
        });
        
        action.setStorable();
        
        action.setCallback(this,
            function(response) { 
                console.log('FieldSetRecordDisplay getFields callback');
                var fields = response.getReturnValue();
                var customAttributes = component.get('v.customAttributes');
                
                for (field of fields) {
                	field.FieldValue = component.getReference('v.record.' + field.APIName);
                    
                    if (field.Type && field.Type.toLowerCase() == "reference") {
                        var parentNameFieldReference;
                        
                        if(field.APIName.endsWith('__c')) {
                            parentNameFieldReference = field.APIName.replace('__c', '__r.Name');
                        }
                        else if(field.APIName.endsWith('Id')){
                            parentNameFieldReference = field.APIName.replace('Id', '.Name');
                            field.Label = field.Label.replace(' ID', '');
                        }
                        
                        var parentNameReference = component.getReference('v.record.' + parentNameFieldReference);
                        
                        if (parentNameReference) {
                            field.FieldValue = parentNameReference;
                        }
                    }
                	
                	if (customAttributes) {
	                	var customFieldAttributes = customAttributes[field.APIName];
	                	
	                	if (customFieldAttributes) {
	                		Object.assign(field, customFieldAttributes);
	                	}
                	}
                }

                component.set('v.fields', fields);
            }
        );
        $A.enqueueAction(action);
	},
	
	loadComponentUsingQuery: function(component, event, helper) {
		var action = component.get('c.getDetails');
		var recordId = component.get('v.recordId');
		
		if (!recordId) {
			return;
		}
    	
        action.setParams({
            fieldSetName: component.get('v.fieldSetName'),
            objectName: component.get('v.objectName'),
            recordId: component.get('v.recordId')
        });
        
        action.setCallback(this,
            function(response) { 
                console.log('FieldSetRecordDisplay getDetails callback');

                var detailsContext = response.getReturnValue();
                var fields = detailsContext.Fields;

                // Prevent Infinite loop from record onchange handler
                component.set('v.recordSetInQuery', true);
                component.set('v.record', detailsContext.Record);
                component.set('v.recordSetInQuery', false);
                
                var customAttributes = component.get('v.customAttributes');
                
                for (field of fields) {
                	field.FieldValue = component.getReference('v.record.' + field.APIName);
                    
                    if (field.Type && field.Type.toLowerCase() == "reference") {
                        var parentNameFieldReference;
                        var label;
                        
                        if(field.APIName.endsWith('__c')) {
                            parentNameFieldReference = field.APIName.replace('__c', '__r.Name');
                        }
                        else if(field.APIName.endsWith('Id')){
                            parentNameFieldReference = field.APIName.replace('Id', '.Name');
                            field.Label = field.Label.replace(' ID', '');
                        }
                        
                        var parentNameReference = component.getReference('v.record.' + parentNameFieldReference);
                        
                        if (parentNameReference) {
                            field.FieldValue = parentNameReference;
                        }
                    }
                	
                	if (customAttributes) {
	                	var customFieldAttributes = customAttributes[field.APIName];
	                	
	                	if (customFieldAttributes) {
	                		Object.assign(field, customFieldAttributes);
	                	}
                	}
                }

                component.set('v.fields', fields);
            }
        );
        $A.enqueueAction(action);
	}
})