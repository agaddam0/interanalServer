({
    loadEmailPreview : function(component, isInitialLoad) {
        var emailId = component.get('v.selectedEmailTemplate');
        var helper = this;
        var getEmailPreviewHTMLAction = component.get('c.getEmailPreviewHTML');
        var inputValues = helper.getInputValues(component);
        var emailMetadata = helper.getSelectedEmailMetadata(component);
        
        if (isInitialLoad) {
            helper.loadDefaultInputValuesFromQueryParamsIntoDataContainer(component, inputValues, emailMetadata);
        }
        
        var invalidInputs = helper.validate(component, emailMetadata);
        
        var emailMetadataStringified = JSON.stringify(emailMetadata);
        
        getEmailPreviewHTMLAction.setParams(
            {"emailId": emailId,
             "inputValues": inputValues,
             "emailJSONMetadata": emailMetadataStringified }
        );
        
        helper.showSpinner(component);
        
        getEmailPreviewHTMLAction.setCallback(component, function(response){
            var state = response.getState();
            var emailPreviewHTML = '';

            if (component.isValid() && state === "SUCCESS") {
                var emailPreviewContext = response.getReturnValue();
                emailPreviewHTML = emailPreviewContext.EmailPreviewHTML;
                
                if (emailPreviewContext.Success == false) {
                    helper.showErrorToast('Error loading email preview: ' + emailPreviewContext.Message);
                }
                
            }
            
            component.set("v.emailPreviewHTML", emailPreviewHTML);
            
            helper.hideSpinner(component);
        });
        
        $A.enqueueAction(getEmailPreviewHTMLAction);
    },

    loadEmailBuilder : function(component) {
        var loadEmailBuilderContextAction = component.get('c.loadEmailBuilderContext');
        var helper = this;

        helper.showSpinner(component);
        
        loadEmailBuilderContextAction.setCallback(component, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
            
                var context = response.getReturnValue();
                
                if (context.Success) {
                    component.set("v.context", context);
                    helper.initDataContainer(component);
                    
                    var myPageRef = component.get("v.pageReference");
                    
                    if (myPageRef && myPageRef.state && myPageRef.state.c__EmailTemplate) {
                        var emailTemplate = myPageRef.state.c__EmailTemplate;
                        component.set('v.pageState', myPageRef.state);
                        
                        helper.setSelectedEmailTemplateByName(component, emailTemplate);
                        var onEmailTemplateChangeAction = component.get('c.onEmailTemplateChange');
                        $A.enqueueAction(onEmailTemplateChangeAction);
                    }
                }
                else {
	                console.log('Problem getting saving enrollment case. Error: ' + state);
	                
	                helper.showErrorToast('Error loading email builder: ' + context.Message);
                }
            }
            
            helper.hideSpinner(component);
        });
        
        $A.enqueueAction(loadEmailBuilderContextAction);
    },

    sendEmailToRecipient : function(component) {
        var emailId = component.get('v.selectedEmailTemplate');
        var contactId = component.get('v.recipientContactId');
        var helper = this;

        helper.closeSendConfirmation(component);
        
        var inputValues = helper.getInputValues(component);
        var emailMetadata = helper.getSelectedEmailMetadata(component);
        var invalidInputs = helper.validate(component, emailMetadata);
        
        if (invalidInputs.length > 0) {
            helper.showCorrectInvalidFieldsToast();
            return;
        }

        var emailMetadataStringified = JSON.stringify(emailMetadata);
        var sendEmailAction = component.get('c.sendEmail');

        sendEmailAction.setParams(
            {"emailId": emailId,
             "contactId": contactId,
             "inputValues": inputValues,
             "emailJSONMetadata": emailMetadataStringified }
        );
        
        helper.showSpinner(component);
        
        sendEmailAction.setCallback(component, function(response){
            var state = response.getState();
            var emailResult = response.getReturnValue();

            if (component.isValid() && state === "SUCCESS") {
                var emailResult = response.getReturnValue();
            }

            console.log("   Email Result: " + emailResult);
            
            if (emailResult) {
                console.log("   Email Result Message: " + emailResult.Message);
            }
            
            if (emailResult.Message == 'The email was successfully sent.') {
                helper.showSuccessToast(emailResult.Message);
                helper.reset(component);
            }
            else {
                helper.showErrorToast('Error Sending Email: ' + emailResult.Message);
            }
            
            helper.hideSpinner(component);
        });
        
        $A.enqueueAction(sendEmailAction);
    },

    onEmailTemplateChange : function(component) {
        var helper = this;

        helper.initDataContainer(component);
        helper.loadEmailPreview(component, true);
        helper.loadInputComponents(component);
    },

    loadInputComponents : function(component) {
        var emailId = component.get('v.selectedEmailTemplate');
        var helper = this;
        
        if (!emailId) {
            component.set("v.sectionsMetadata", []);
            component.set("v.sectionsComponents", []);
        
            return;
        }
        
        var sectionsMetadata = helper.getSectionsMetadataForTemplate(component, emailId);
        
        console.log('EmailBuilder.loadInputComponents');

        var inputDesc = [];
        var config = null;
        var sectionNumber = 1;
        
        helper.initDataContainer(component, sectionsMetadata);
        helper.loadDefaultInputValuesFromQueryParamsIntoDataContainer(component, component.get('v.dataContainer'), sectionsMetadata);

        for (let section of sectionsMetadata) {
            config = { componentDef: 'c:EmailBuilderInputSection', attributes: {} }
            config.attributes.sectionMetadata = section;
            config.attributes.dataContainer = component.getReference('v.dataContainer');
            config.attributes["aura:id"] = section.Name;
            config.attributes.sectionNumber = sectionNumber;
        
            inputDesc.push([
                    config.componentDef,
                    config.attributes
            ]);
            
            ++sectionNumber;
        }
        
        component.set("v.sectionsMetadata", sectionsMetadata);
        
        if (inputDesc.length == 0) {
            return;
        }
        
        $A.createComponents(inputDesc, function(cmps) {
            console.log('Email Builder createComponents');
            
            component.set("v.sectionsComponents", cmps);
        });
    },

    getSectionsMetadataForTemplate : function(component, emailId) {
        var helper = this;//
    
        var selectedEmailTemplate = helper.findEmailTemplate(component, emailId);
        
        var sectionsMetadata = [];

        if (selectedEmailTemplate) {
            var htmlViewSlots = JSON.parse(selectedEmailTemplate.HTMLSlotsJSON);
            
            for (let rootSlotName in htmlViewSlots) {
                helper.getSectionsMetadataFromTemplateRecursive(htmlViewSlots[rootSlotName], sectionsMetadata, helper);
            }
        }

        return sectionsMetadata;
    },
    
    getSectionsMetadataFromTemplateRecursive : function(contentBlock, sectionsMetadata, helper) {
        if (contentBlock.content) {
            var sectionsMetadataRegex = /%%\[\/\*[\S\s]*({[\S\s]*Sections[\S\s]*})[\S\s]*\]%%/gm;
            var match = sectionsMetadataRegex.exec(contentBlock.content);
            
            if (match && match.length == 2) {
                console.log("  captured group: " + match[0]);
                
                var sectionsMetadataStr = match[0];
                var brRegex = /<br \/>/g;
                var singleQuoteRegex = /\\''/g;

                // switch the <br /> tags to new lines
                sectionsMetadataStr = sectionsMetadataStr.replace(brRegex, "\n");
                
                if (sectionsMetadataStr.startsWith('%%[')) {
                    sectionsMetadataStr = sectionsMetadataStr.replace('%%[', '');
                }
                
                if (sectionsMetadataStr.endsWith(']%%')) {
                    sectionsMetadataStr = sectionsMetadataStr.replace(']%%', '');
                }
                
                sectionsMetadataStr = sectionsMetadataStr.trim();
                
                if (sectionsMetadataStr.startsWith('/*')) {
                    sectionsMetadataStr = sectionsMetadataStr.replace('/*', '');
                }

                if (sectionsMetadataStr.endsWith('*/')) {
                    sectionsMetadataStr = sectionsMetadataStr.replace('*/', '');
                }

                // remove any funky non-printable characters so the JSON.parse
                // doesn't throw any invalid token at position N errors.
                sectionsMetadataStr = 
                    sectionsMetadataStr.replace(/\\n/g, "\\n")  
                    .replace(singleQuoteRegex, "\\'")
                    //.replace(/\\"/g, '\\"')
                    .replace(/\\&/g, "\\&")
                    .replace(/\\r/g, "\\r")
                    .replace(/\\t/g, "\\t")
                    .replace(/\\b/g, "\\b")
                    .replace(/\\f/g, "\\f")
                    .replace(/[^\x20-\x7E]/g, '');
                // remove non-printable and other non-valid JSON chars
                sectionsMetadataStr = sectionsMetadataStr.replace(/[\u0000-\u0019]+/g,"");
                
                var sectionsMetadataObject = JSON.parse(sectionsMetadataStr);
                
                if (sectionsMetadataObject && sectionsMetadataObject.Sections) {
                    for (let section of sectionsMetadataObject.Sections) {
                        sectionsMetadata.push(section);
                    }
                }
            }
        }
        
        if (contentBlock.slots) {
            for (let slotName in contentBlock.slots) {
                helper.getSectionsMetadataFromTemplateRecursive(contentBlock.slots[slotName], sectionsMetadata, helper);
            }
        }

        if (contentBlock.blocks) {
            for (let blockName in contentBlock.blocks) {
                helper.getSectionsMetadataFromTemplateRecursive(contentBlock.blocks[blockName], sectionsMetadata, helper);
            }
        }
    },

    findEmailTemplate : function(component, emailId) {
        var context = component.get('v.context');
        
        for (let availableEmailTemplate of context.AvailableEmailTemplates) {
            if (availableEmailTemplate.LegacyId == emailId) {
                return availableEmailTemplate;
            }
        }
        
        return null;
    },
    
    findEmailTemplateByName : function(component, emailTemplateName) {
        var context = component.get('v.context');
        
        for (let availableEmailTemplate of context.AvailableEmailTemplates) {
            if (availableEmailTemplate.Name == emailTemplateName) {
                return availableEmailTemplate;
            }
        }
        
        return null;
    },
    
    getSelectedEmailMetadata : function(component) {
        var emailId = component.get('v.selectedEmailTemplate');
        var helper = this;
        var otherMetadata = {};
        var sectionsMetadata = helper.getSectionsMetadataForTemplate(component, emailId);

        if (sectionsMetadata) {
            otherMetadata = sectionsMetadata;
        }
        
        return otherMetadata;
    },
    
    initDataContainer : function(component, sectionsMetadata) {
        let dataContainer = {};

        if (!sectionsMetadata) {
            component.set("v.dataContainer", dataContainer);
        
            return;
        }
        
        /* Default the data container fields with inputs that use "Options"
           to have an empty array as their initial default value so that any
           inputs that bind to it won't error out from a missing value.
        */
        
        for (let sectionMetadata of sectionsMetadata) {
            if (!sectionMetadata.Inputs) {
                continue;
            }
            
            for (let sectionInput of sectionMetadata.Inputs) {
                if (sectionInput.Options) {
                    dataContainer[sectionInput.TargetField] = [];
                }
                
                if (!sectionInput.DependentInputs) {
                    continue;
                }
                
                for (let dependentInput of sectionInput.DependentInputs) {
                    if (dependentInput.Options) {
                        dataContainer[dependentInput.TargetField] = [];
                    }
                }
            }
        
        }
        
        component.set("v.dataContainer", dataContainer);
    },

    reset : function(component) {
        var helper = this;
        component.set('v.selectedEmailTemplate', null);

        helper.onEmailTemplateChange(component);
    },

    openSendConfirmation : function(component, event, helper) {
        component.set('v.showSendConfirmation', true);
    },

    closeSendConfirmation : function(component, event, helper) {
        component.set('v.showSendConfirmation', false);
    },
    
    showSpinner : function(component) {
        component.set('v.showSpinner', true);
    },
    
    hideSpinner : function(component) {
        component.set('v.showSpinner', false);
    },

    getInputValues : function(component) {
        var dataContainer = component.get("v.dataContainer");

        return dataContainer;
    },
    
    showCorrectInvalidFieldsToast : function() {
        var helper = this;
        helper.showErrorToast("Please correct the invalid fields before sending the email.");
    },

    showSuccessToast : function(successMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": successMessage,
            "type": 'success'
        });
        toastEvent.fire();
    },
    
    showErrorToast : function(errorMsg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": errorMsg,
            "type": 'error'
        });
        toastEvent.fire();
    },
    
    validate : function(component, emailMetadataSections) {
        var invalidComponents = [];
    
        if (!emailMetadataSections) {
            return invalidComponents;
        }
        
        var helper = this;
        var inputComponentsMap = helper.getloadedInputComponents(component, emailMetadataSections);
        
        for (let inputName in inputComponentsMap) {
            let inputComponent = inputComponentsMap[inputName];
            
            if (!inputComponent) {
                continue;
            }
            
            var isValid = inputComponent.validate();
            if (!isValid) {
                invalidComponents.push(inputComponent);
            }
        }
        
        return invalidComponents;
    },
    
    getloadedInputComponents : function(component, emailMetadataSections) {
        var inputComponentsMap = {};
    
        if (!emailMetadataSections) {
            return inputComponentsMap;
        }
    
        for (let section of emailMetadataSections) {
            if (!section.Inputs) {
                continue;
            }
            
            for (let sectionInput of section.Inputs) {
                let inputSectionComponent = component.find(section.Name);
                
                if (inputSectionComponent && Array.isArray(inputSectionComponent)) {
                    inputSectionComponent = inputSectionComponent[0];
                }
            
                if (inputSectionComponent) {
                    let inputComponent = inputSectionComponent.find(sectionInput.TargetField);
                    
                    if (inputComponent) {
                        inputComponentsMap[sectionInput.TargetField] = inputComponent;
                    }
                }
            }
        }
        
        return inputComponentsMap;
    },
    
    setSelectedEmailTemplateByName : function(component, emailTemplate) {
        var helper = this;
        var emailTemplateToUse = helper.findEmailTemplateByName(component, emailTemplate);
        
        if (emailTemplateToUse) {
            var emailTemplatesSelect = component.find('emailTemplatesSelect');
            emailTemplatesSelect.set('v.value', emailTemplateToUse.LegacyId);
        }
    },

    loadDefaultInputValuesFromQueryParamsIntoDataContainer : function(component, inputValues, emailMetadataSections) {
        var helper = this;
        var pageState = component.get('v.pageState');
        
        if (!emailMetadataSections || !pageState) {
            return;
        }
        
        for (let sectionMetadata of emailMetadataSections) {
            if (!sectionMetadata.Inputs) {
                continue;
            }
            
            for (let sectionInput of sectionMetadata.Inputs) {
                if (sectionInput.QueryParamName &&
                    pageState[sectionInput.QueryParamName]) {
                    inputValues[sectionInput.TargetField] = pageState[sectionInput.QueryParamName];
                }
                
                if (!sectionInput.DependentInputs) {
                    continue;
                }
                
                for (let dependentInput of sectionInput.DependentInputs) {
                    if (dependentInput.QueryParamName &&
	                    pageState[dependentInput.QueryParamName]) {
	                    inputValues[dependentInput.TargetField] = pageState[dependentInput.QueryParamName];
	                }
                }
            }
        }
        
        component.set('v.dataContainer', inputValues);
    }
})