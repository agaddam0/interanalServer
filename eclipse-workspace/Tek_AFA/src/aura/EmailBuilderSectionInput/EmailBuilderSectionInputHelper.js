({
    configMap: {
        'richtextarea': { componentDef: 'c:RichTextAreaInput', attributes: {'class': 'slds-m-top_small' } },
        'textarea': { componentDef: 'c:LightningTextArea', attributes: {name: '', 'class': 'slds-m-top_small' } },
        'textbox': { componentDef: 'c:LightningInput', attributes: {name: '', 'class': 'slds-m-top_small' } },
        'radiogroup': { componentDef: 'c:RadioGroup', attributes: { "options": [], 'class': 'slds-m-top_small', "messageWhenValueMissing": "Complete this field." }},
        'checkboxgroup': { componentDef: 'lightning:checkboxGroup', attributes: { "options": [], 'class': 'slds-m-top_small' } },
        'recordlookup': {
            componentDef: 'c:strike_lookup',
            attributes: {
                searchField: 'Name',
                order: 'Name',
                limit: '10',
                'class': 'slds-m-top_small',
                object: '',
                loadingMessage: "Loading...",
                filter: '',
                errorMessage: 'Complete this field.'
            }
        }
    },

    loadDynamicComponents : function(component) {
        var helper = this;
        var sectionInput = component.get("v.sectionInput");
        
        console.log('EmailBuilder.loadDynamicComponents');

        var inputDesc = [];
        var config = null;
        
        config = helper.buildMainInputConfig(component, sectionInput, helper);
            
        if (config) {
            inputDesc.push([
                config.componentDef,
                config.attributes
            ]);
        }
        
        $A.createComponents(inputDesc, function(cmps) {
            console.log('Email Builder Section Input (individual) createComponents');
            
            var inputComponent = cmps[0];
            component.set("v.inputComponent", cmps[0]);
        });
    },
    
    loadDependentInputsOnValueSelection : function(component) {
        var sectionInput = component.get("v.sectionInput");
        
        if (!sectionInput || !sectionInput.DependentInputs) {
            return;
        }

        var helper = this;
        
        var inputValue = component.get('v.inputValue');
        
        var dependentInputDesc = [];
        var dependentInputComponents = [];
        var loadedDependentInputComponents = component.get('v.dependentInputComponents');
        
        if (!inputValue || (Array.isArray(inputValue) && inputValue.length == 0)) {
            component.set("v.dependentInputComponents", dependentInputComponents);
            helper.clearNolongerNeededDependentFields(component, loadedDependentInputComponents, dependentInputComponents);
            return;
        }
        
        for (let dependentInput of sectionInput.DependentInputs) {
            var config = null;
            
            if ((Array.isArray(inputValue) && inputValue.includes(dependentInput.ShowWithOption)) ||
                inputValue == dependentInput.ShowWithOption ||
                dependentInput.ShowWithAnyOption) {
                config = helper.buildInputConfig(component, dependentInput, helper);
            }
        
            if (config) {
                dependentInputDesc.push([
                    config.componentDef,
                    config.attributes
                ]);
            }
        }
        
        if (dependentInputDesc.length == 0) {
            component.set("v.dependentInputComponents", dependentInputComponents);
            helper.clearNolongerNeededDependentFields(component, loadedDependentInputComponents, dependentInputComponents);
            return;
        }
        
        $A.createComponents(dependentInputDesc, function(cmps) {
            console.log('Email Builder Section Input (individual) createComponents');
            component.set("v.dependentInputComponents", cmps);
            helper.clearNolongerNeededDependentFields(component, loadedDependentInputComponents, cmps);
        });
    },
    
    loadEditExistingDataLink : function(component, helper) {
        var sectionInput = component.get("v.sectionInput");
        var inputValue = component.get('v.inputValue');

        if (!sectionInput || !sectionInput.EditExistingDataLink || !inputValue) {
            component.set('v.editLinkInfo', null);
            return;
        }

        var action = component.get('c.getEditExistingDataLinkInfo');
        
        action.setParams(
            {"editExistingDataLinkMetadataJSON": JSON.stringify(sectionInput.EditExistingDataLink),
             "inputValue": inputValue }
        );
        
        action.setCallback(component, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var editExistingDataLinkContext = response.getReturnValue();
                var editLinkInfo = {};
                
                editLinkInfo.LinkTitle = sectionInput.EditExistingDataLink.LinkTitle;
                
                var navService = component.find('navService');
                var pageReference = {
                    "type": "standard__recordRelationshipPage",
                    "attributes": {
                        "recordId": editExistingDataLinkContext.RecordId,
                        "objectApiName": sectionInput.EditExistingDataLink.Object,
                        "relationshipApiName": sectionInput.EditExistingDataLink.RelationshipAPIName,
                        "actionName": "view"
                    }
                };

                if (sectionInput.EditExistingDataLink.LightningComponentName) {
                    pageReference = {    
                        "type": "standard__component",
                        "attributes": {
                            "componentName": sectionInput.EditExistingDataLink.LightningComponentName    
                        },    
                        "state": {
                               
                        }
                    };

                    if (sectionInput.EditExistingDataLink.RecordParamName) {
                        pageReference.state[sectionInput.EditExistingDataLink.RecordParamName] = editExistingDataLinkContext.RecordId;
                    }

                    if (sectionInput.EditExistingDataLink.OtherParameters) {
                        for (let otherParam of sectionInput.EditExistingDataLink.OtherParameters) {
                            if (otherParam.Source == 'inputValue') {
                                pageReference.state[otherParam.ParameterName] = inputValue;
                            }
                        }
                    }
                }
                
                navService.generateUrl(pageReference)
                .then($A.getCallback(function(url) {
                    editLinkInfo.EditURL = url;
                    component.set('v.editLinkInfo', editLinkInfo);
                }));
            }
        });
        
        $A.enqueueAction(action);
    },
    
    buildMainInputConfig : function(component, sectionInput, helper) {
        var config = helper.buildInputConfig(component, sectionInput, helper);
        
        if (config) {
            component.set("v.inputValue", config.attributes.value);
        }
    
        return config;
    },
    
    buildInputConfig : function(component, sectionInput, helper) {
        var config = null;
        
        let configTemplate = helper.configMap[sectionInput.Type.toLowerCase()];
            
        if (!configTemplate) {
            console.log('Type ' + sectionInput.Type + ' not supported');
            return config;
        }
        
        config = JSON.parse(JSON.stringify(configTemplate));
        config.attributes.label = sectionInput.Label;
        
        var recordFieldReference = component.getReference('v.dataContainer.' + sectionInput.TargetField);
        config.attributes.value = recordFieldReference;
        config.attributes['aura:id'] = sectionInput.TargetField;
        
        if (sectionInput.Options) {
            config.attributes.options = helper.buildOptionsList(sectionInput.Options);
            
            /* Do not set the options to blank in here because it causes
               an infinite loop due to the input value on change handler.
               The defaulting is done in the EmailBuilder.
            */
        }

        if (config.attributes.object !== undefined &&
            config.attributes.object == '') {
            config.attributes.object = sectionInput.Object;
        }

        if (sectionInput.SearchField) {
            config.attributes.searchField = sectionInput.SearchField;
        }
        
        if (sectionInput.Filter) {
            config.attributes.filter = sectionInput.Filter;
        }

        if (sectionInput.HelpText) {
            config.attributes.helptext = sectionInput.HelpText;
        }
        
        if (sectionInput.Required) {
            config.attributes.required = sectionInput.Required;
            
            if (sectionInput.RequiredMessage) {
                config.attributes.messageWhenValueMissing = sectionInput.RequiredMessage;
                config.attributes.errorMessage = sectionInput.RequiredMessage;
            }
        }

        return config;
    },
    
    buildOptionsList : function(availableOptions) {
        var inputOptionsList = [];
        
        for (let availableOption of availableOptions) {
            inputOptionsList.push({ label: availableOption, value: availableOption });
        }
        
        return inputOptionsList;
    },
    
    validate : function(component) {
        var helper = this;
        var inputMetadata = component.get('v.sectionInput');
        var isValid = true;
        
        helper.clearAllErrorMessages(component);
        
        var allInputsWithMetadata = helper.getAllInputsWithMetadata(component);
        var requiredInputsWithMetadata = allInputsWithMetadata.filter((cmpWithMetadata) => { return cmpWithMetadata.InputMetadata.Required; });
        
        for (let requiredInputWithMetadata of requiredInputsWithMetadata) {
            if (!helper.inputHasAValue(requiredInputWithMetadata.Input)) {
                isValid = false;

                helper.showRequiredFieldMessage(requiredInputWithMetadata.Input);
            }
        }
        
        var maxSelectionsAllowedInputsWithMetadata = allInputsWithMetadata.filter((cmpWithMetadata) => { return cmpWithMetadata.InputMetadata.MaxSelectionsAllowed; });
        
        for (let maxSelectionAllowedInputWithMetadata of maxSelectionsAllowedInputsWithMetadata) {
            let inputValue = maxSelectionAllowedInputWithMetadata.Input.get('v.value')
        
            let numberOfSelections = inputValue && Array.isArray(inputValue) ? inputValue.length : 0;
        
            if (numberOfSelections > maxSelectionAllowedInputWithMetadata.InputMetadata.MaxSelectionsAllowed) {
                isValid = false;
                helper.showMaxNumberOfSelectionsExceededMessage(maxSelectionAllowedInputWithMetadata.Input, maxSelectionAllowedInputWithMetadata.InputMetadata.MaxSelectionsAllowed);
            }
        }
        
        
        return isValid;
    },
    
    getAllInputsWithMetadata : function(component) {
        var helper = this;
        var inputMetadata = component.get('v.sectionInput');
        var allInputs = [];
        
        if (inputMetadata) {
            var mainInput = component.get('v.inputComponent');
            
            var inputWithMetadata = {
                "InputMetadata": inputMetadata,
                "Input": mainInput
            };
        
            allInputs.push(inputWithMetadata);
        }
        
        var dependentInputComponents = component.get('v.dependentInputComponents');
        
        if (!dependentInputComponents) {
            return allInputs;
        }
        
        for (let dependentInputComponent of dependentInputComponents) {
            let dependentInputId = dependentInputComponent.getLocalId();
            let dependentMetadata = helper.getDependentMetadataByTargetField(component, dependentInputId);
            
            if (dependentMetadata) {
                var dependentInputWithMetadata = {
                    "InputMetadata": dependentMetadata,
                    "Input": dependentInputComponent
                };
            
                allInputs.push(dependentInputWithMetadata);
            }
        }
        
        return allInputs;
    },
    
    getDependentMetadataByTargetField : function(component, targetField) {
        var sectionInput = component.get('v.sectionInput');
        var nullDependentMetadata = null;
        
        if (!sectionInput || !sectionInput.DependentInputs) {
            return nullDependentMetadata;
        }
        
        for (let dependentInput of sectionInput.DependentInputs) {
            if (dependentInput.TargetField == targetField) {
                return dependentInput;
            }
        }
        
        return nullDependentMetadata;
    },
    
    inputHasAValue : function(inputComponent) {
        var inputValue = inputComponent.get('v.value');
        
        var hasAnyValues = (inputValue && !Array.isArray(inputValue)) ||
                                  (Array.isArray(inputValue) && inputValue.length > 0);
        
        return hasAnyValues;
    },
    
    clearAllErrorMessages : function(component) {
        var helper = this;
        var allInputsWithMetadata = helper.getAllInputsWithMetadata(component);
        
        for (let inputCmpWithMetadata of allInputsWithMetadata) {
            helper.clearErrorMessages(inputCmpWithMetadata.Input);
        }
    },
    
    clearErrorMessages : function(inputComponent) {
        if (typeof inputComponent.hideRequiredFieldMessage === 'function') {
            inputComponent.hideRequiredFieldMessage();
        }
        else if (inputComponent.isInstanceOf('lightning:radioGroup') ||
                 inputComponent.isInstanceOf('lightning:checkboxGroup')) {
            // For some reason calling reportValidity doesn't hide the error message since it thinks it's valid
            // so manually set it.
        
            inputComponent.setCustomValidity("");
            inputComponent.reportValidity();
        }
        else if (typeof inputComponent.reportValidity === 'function') {
            inputComponent.reportValidity();
        }
        else if (typeof inputComponent.showError === 'function') {
            inputComponent.set('v.error', false);
        }
    },
    
    showRequiredFieldMessage : function(inputComponent) {
        if (typeof inputComponent.showRequiredFieldMessage === 'function') {
            inputComponent.showRequiredFieldMessage();
        }
        else if (inputComponent.isInstanceOf('lightning:radioGroup')) {
            // For some reason calling reportValidity doesn't show the error message since it thinks it's valid
            // so manually set it.
        
            let requiredMessage = inputComponent.get('v.messageWhenValueMissing');

            inputComponent.setCustomValidity(requiredMessage);
            inputComponent.reportValidity();
        }
        else if (typeof inputComponent.reportValidity === 'function') {
            inputComponent.reportValidity();
        }
        else if (typeof inputComponent.showError === 'function') {
            inputComponent.set('v.error', true);
        }
    },
    
    clearNolongerNeededDependentFields : function(component, loadedDependentInputComponents, newDependentInputComponents) {
        // If the primary value is no longer chosen, clear out the dependent input values
        // so they aren't sent to Marketing Cloud.
    
        if (!loadedDependentInputComponents || loadedDependentInputComponents.length == 0) {
            return;
        }
        
        if (!newDependentInputComponents) {
            newDependentInputComponents = [];
        }
        
        for (let loadedDependentInputComponent of loadedDependentInputComponents) {
            let newDependentInput = newDependentInputComponents.find((cmp) => { return cmp.getLocalId() == loadedDependentInputComponent.getLocalId(); });
            
            if (!newDependentInput) {
                let emptyValue = null;
                
                if (loadedDependentInputComponent.get('v.options')) {
                    emptyValue = [];
                }
            
                loadedDependentInputComponent.set('v.value', emptyValue);
            }
        }
    },
    
    showMaxNumberOfSelectionsExceededMessage : function(inputComponent, numMaxSelectionsAllowed) {
        if (typeof inputComponent.setCustomValidity === 'function') {
            inputComponent.setCustomValidity('Only ' + numMaxSelectionsAllowed + ' selection(s) are allowed.');
            inputComponent.reportValidity();
        }
    }
})