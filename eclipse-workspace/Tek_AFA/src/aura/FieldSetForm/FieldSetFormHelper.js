({
	/*
     *  Map the Schema.FieldSetMember to the desired component config, including specific attribute values
     *  Source: https://www.salesforce.com/us/developer/docs/apexcode/index_Left.htm#CSHID=apex_class_Schema_FieldSetMember.htm|StartTopic=Content%2Fapex_class_Schema_FieldSetMember.htm|SkinName=webhelp
     *
     *  Change the componentDef and attributes as needed for other components
     */
    configMap: {
        'anytype': { componentDef: 'c:DateInput', attributes: { 'class': 'slds-m-top_small', 'labelClass': 'slds-show_inline-block ' } },
        'base64': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-m-top_small' } },
        'boolean': {componentDef: 'c:CheckboxInput', attributes: { 'class': 'slds-m-top_small' } },
        'combobox': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-m-top_small' } },
        'currency': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-m-top_small', 'type': 'number', 'formatter': 'currency', 'step': '0.01' } },
        'datacategorygroupreference': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-m-top_small' } },
        'date': { componentDef: 'c:DateInput', attributes: { 'class': 'slds-m-top_small' }},
        'datetime': { componentDef: 'ui:inputDateTime', attributes: { 'class': 'slds-p-vertical_xx-small', 'labelClass': 'slds-show_inline-block slds-m-top_small' } },
        'double': { componentDef: 'c:LightningInput', attributes: { 'type': 'number', 'class': 'slds-m-top_small' } },
        'email': { componentDef: 'ui:inputEmail', attributes: { 'class': 'slds-p-vertical_xx-small', 'labelClass': 'slds-show_inline-block slds-m-top_small' } },
        'encryptedstring': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-m-top_small' } },
        'id': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-m-top_small' } },
        'integer': { componentDef: 'c:LightningInput', attributes: { 'type': 'number', 'class': 'slds-m-top_small' } },
        'multipicklist': { componentDef: 'c:PicklistComponent', attributes: { 'class': 'slds-p-vertical_xx-small' } },
        'percent': { componentDef: 'ui:inputNumber', attributes: { 'class': 'slds-p-vertical_xx-small', 'labelClass': 'slds-show_inline-block slds-m-top_small' } },
        'phone': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-p-vertical_xx-small', 'labelClass': 'slds-show_inline-block slds-m-top_small' } },
        'picklist': { componentDef: 'c:PicklistComponent', attributes: { 'containerClass': 'slds-m-top_small' } },
        'reference': {
        	componentDef: 'c:strike_lookup',
        	attributes: {
        		searchField: 'Name',
        		order: 'Name',
        		limit: '10',
        		'class': 'slds-m-top_small',
        		object: '',
        		loadingMessage: "Loading...",
        		errorMessage: "Invalid user input",
        		filter: ''
        	}
        },
        'richtextarea': { componentDef: 'c:RichTextAreaInput', attributes: {'class': 'slds-m-top_small' } },
        'string': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-m-top_small' } },
        'textarea': { componentDef: 'c:LightningTextArea', attributes: {name: '', 'class': 'slds-m-top_small' } },
        'time': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-p-vertical_xx-small', 'labelClass': 'slds-show_inline-block slds-m-top_small', 'type': 'time' } },
        'url': { componentDef: 'c:LightningInput', attributes: { 'class': 'slds-m-top_small' } }
    },

    createForm: function(cmp) {
        console.log('FieldSetFormHelper.createForm');
        var fields = cmp.get('v.fields');
        var record = cmp.get('v.record');
        var inputDesc = [];
        var fieldPaths = [];
        var config = null;
        var customAttributes = cmp.get('v.customAttributes');
        var customFieldInputs = cmp.get('v.customFieldInputs');
        var disabled = cmp.get("v.disableInputFields");
        var useStrikePicklist = cmp.get("v.useStrikePicklist");
        
        if (customFieldInputs &&
            typeof customFieldInputs === "string") {
        	customFieldInputs = JSON.parse(customFieldInputs);
        }
        
        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];
            var fieldType = field.Type.toLowerCase();
            
            var configTemplate = this.configMap[fieldType];
            if (configTemplate) {            
            	if (customFieldInputs &&
            	    customFieldInputs[field.APIName]) {
            		configTemplate = customFieldInputs[field.APIName]
            	}
            
            	// Copy the config, note that this type of copy may not work on all browsers!
            	config = JSON.parse(JSON.stringify(configTemplate));
                
                console.log("Field Label: " + field.Label);
                config.attributes.label = field.Label;
                config.attributes.required = field.Required;
                config.attributes.helptext = field.FieldHelpText;
                config.attributes.disabled = disabled;
                
                var recordFieldReference = cmp.getReference('v.record.' + field.APIName);
                
                config.attributes.value = recordFieldReference;
                
                if (config.attributes.name !== undefined &&
                    config.attributes.name == '') {
                	config.attributes.name = field.APIName;
                }
                
                if (config.attributes.object !== undefined &&
                    config.attributes.object == '') {
                    config.attributes.object = field.ReferenceObjectName;
                }
                
                console.log(record[field.APIName]);
                config.attributes.fieldPath = field.APIName;
                config.attributes['aura:id'] = field.APIName;

                if(fieldType == 'picklist') {
                    console.log("Field Path: " + field.APIName);
                    config.attributes.label = field.Label;
                    config.attributes.labelClass = "slds-form-element__label";
                    config.attributes.fieldName = field.APIName;
                    config.attributes.sObjectName = cmp.get("v.objectName");
                    config.attributes.initialValue = record[field.APIName];
                    config.attributes.recordId = record.Id;
                    config.attributes.recordTypeId = record.RecordTypeId;
                    config.attributes.class = 'slds-m-top_small';
                }
                else if(fieldType == 'multipicklist') {
                    config.attributes.fieldName = field.APIName;
                    config.attributes.sObjectName = cmp.get("v.objectName");
                    config.attributes.multiple = true;
                    config.attributes.initialValue = record[field.APIName];
                    config.attributes.class = 'slds-m-top_small';
                    config.attributes.useStrikePicklist = useStrikePicklist;
                }
                else if(fieldType == 'reference') {
                    config.attributes.recordId = record.Id;
                }
                
            	var fieldCustomAttributes = customAttributes[field.APIName];
            	
            	if (fieldCustomAttributes) {
            		Object.assign(config.attributes, fieldCustomAttributes);
            	}

                inputDesc.push([
                    config.componentDef,
                    config.attributes
                ]);

                console.log(inputDesc);
                fieldPaths.push(field.APIName);
                console.log(fieldPaths);
            } else {
                console.log('Type ' + fieldType + ' not supported');
            }
        }

        $A.createComponents(inputDesc, function(cmps) {
            console.log('createComponents');

            cmp.set('v.body', cmps);
            
            var fieldSetFormLoadedEvent = cmp.getEvent('fieldSetFormLoaded');
            fieldSetFormLoadedEvent.fire();
        });
    },
    
    loadComponent: function(cmp, event) {
    	var helper = this;
		
    	var methodArgs = event.getParam('arguments');
        if(methodArgs && methodArgs.record) {
            var record = methodArgs.record;
            cmp.set('v.record', record);
        }

    	var fieldSetName = cmp.get('v.fieldSetName');
    	var objectName = cmp.get('v.objectName');
    	
    	if (!objectName || !fieldSetName) {
    		return;
    	}
    
    	var action = cmp.get('c.getFields');
    	
        action.setParams({
            fieldSetName: fieldSetName,
            objectName: objectName
        });
        action.setCallback(this, 
            function(response) {
                console.log('FieldSetFormController getFields callback');
                var fields = response.getReturnValue();
                cmp.set('v.fields', fields);
                this.createForm(cmp);
            }
        );

        action.setStorable()

        $A.enqueueAction(action);
    },

    loadComponentUsingQueriedRecord: function(cmp, event, helper) {
        var action = cmp.get('c.getDetails');
    	var methodArgs = event.getParam('arguments');
    	var fieldSetName = cmp.get('v.fieldSetName');
    	var objectName = cmp.get('v.objectName');
    	var recordId;
    	
        if(methodArgs && methodArgs.Id) {
            recordId = methodArgs.Id;
        }
    	
        action.setParams({
            fieldSetName: fieldSetName,
            objectName: objectName,
            recordId: recordId
        });
        action.setCallback(this, 
            function(response) { 
                console.log('FieldSetFormController getDetails callback');
                var context = response.getReturnValue();
                cmp.set('v.fields', context.Fields);
                cmp.set('v.record', context.Record);
                this.createForm(cmp);
            }
        );
        $A.enqueueAction(action);
    },
    
	showErrorsFromResponse : function(component, errorResponse) {
		var helper = this;
		
		var usedFields = component.get('v.fields');
		
		// Set focus to the first input so that one can see the error messages.
		// scrollIntoView doesn't work and window.scrollTo doesn't work from a modal.
		if (usedFields && usedFields.length && usedFields.length > 0) {		
			var firstField = component.find(usedFields[0].APIName);
			
			if (firstField && typeof firstField.focus === 'function') {
				firstField.focus();
			}
		}
		
		component.set('v.pageErrors', []);
		helper.clearErrorsInFields(component);
    	
        var errorList = errorResponse.getError();
        
        if (!errorList.length || errorList.length == 0) {
            return;
        }
        
        var error = errorList[0];
        var fieldErrors = error.fieldErrors;
        
        if (fieldErrors) {
        	var fieldErrorsArray = [];
	        
	        for (let field in fieldErrors) {
	        	let errors = fieldErrors[field];
	        	fieldErrorsArray = fieldErrorsArray.concat(errors);
	        	
	        	let fieldComponent = component.find(field);
	        	
	        	if (fieldComponent) {
	        		fieldComponent.set('v.errors', errors);
	        		fieldComponent.set('v.messageWhenBadInput', errors);
	        		fieldComponent.set('v.validity', 'customError');
	        		
	        		if (typeof fieldComponent.showError === "function") {
	        			fieldComponent.showError(errors[0].message);
	        		}
	        	}
	        }
	        
	        component.set('v.fieldErrors', fieldErrorsArray);
        }
        
        var pageErrors = error.pageErrors;
        
        if (pageErrors && pageErrors.length && pageErrors.length > 0) {
	        component.set('v.pageErrors', pageErrors);
        }
        
        if (error.message) {
        	if (!pageErrors) {
        		pageErrors = [];
        	}
        	
        	pageErrors.push(error);
        	
        	component.set('v.pageErrors', pageErrors);
        }
	},
	
	clearErrorsInFields : function(component) {
		var fields = component.get('v.fields');
		var helper = this;
		
		for (let field of fields) {
			let fieldInput = component.find(field.APIName);
            
            if(Array.isArray(fieldInput))
                fieldInput = fieldInput[0];
			
			if (fieldInput &&
				typeof fieldInput.set === 'function') {
				
				helper.clearErrorsAttribute(fieldInput);
			}
			
			if (fieldInput && fieldInput.isInstanceOf('c:LightningInputContainer')) {
				fieldInput.hideRequiredFieldMessage();
			}
		}
	},

	validateFieldSet : function(component, event){
        var fields = component.get('v.fields');
        var isValid = true;
	
        for (let field of fields) {
            if(field.Required) {
                var fieldComponent = component.find(field.APIName);
                
                if(Array.isArray(fieldComponent))
                    fieldComponent = fieldComponent[0];
                
                var val = fieldComponent.get('v.value');
                
                if((!val && field.Type !== 'CURRENCY') ||
                   (field.Type === 'CURRENCY' && isNaN(val))){
                    isValid = false;
                    break;
                }
            }
        }

        return isValid;
    },

    showValidationMessages : function(component) {
        var fields = component.get('v.fields');

        for (let field of fields) {
        	var fieldComponent = component.find(field.APIName);
            
            if(Array.isArray(fieldComponent))
                fieldComponent = fieldComponent[0];
            
            var val = fieldComponent.get('v.value');

            if(field.Required && 
                ((!val && field.Type !== 'CURRENCY') ||
                 (field.Type === 'CURRENCY' && isNaN(val)))
            ) {
                if (typeof fieldComponent.showRequiredFieldMessage === 'function') {
                	fieldComponent.showRequiredFieldMessage();
                }
            }
        }
    },
	
	showErrorInToast : function(title, message) {
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title || "Error:",
			"message": message,
			"type": "error",
			"mode": "sticky"
		});
		toastEvent.fire();
	},
	
	clearErrorsAttribute : function(uiInputComponent) {
		// For some reason, trying to set the errors attribute on the lightning:textarea
		// is causing an error. To get around it, the error is being ignored.
		try {
			uiInputComponent.set('v.errors', []);
		}
		catch(e) {
			console.log('Error trying to set the errors attribute to an empty array: ' + e);
		}
	},
    
    fireValueChangeEvent : function(component, event) {
        var fieldValue = event.getParam("fieldValue");
        var fieldLabel = event.getParam("fieldLabel");
        var objectName = component.get("v.objectName");
        var record = component.get("v.record");
        var fieldName;
        
        var fields = component.get('v.fields');
        
        for (let field of fields) {
            if(field.Label == fieldLabel){
                fieldName = field.APIName;
            }
        }
        
        var fieldValueChangeEvent = $A.get("e.c:FieldSetFormValueChange");
        
        fieldValueChangeEvent.setParams({
            "sObjectName" : objectName,
            "record" : record,
            "fieldName" : fieldName,
            "fieldValue" : fieldValue
        });
        fieldValueChangeEvent.fire();
    },
    
    disableForm : function(component, event){
        var eventArgs = event.getParam('arguments');
        var disabled = eventArgs.disabled == true;
        
        component.set("v.disableInputFields", disabled);
        this.loadComponent(component, event);
    }
})