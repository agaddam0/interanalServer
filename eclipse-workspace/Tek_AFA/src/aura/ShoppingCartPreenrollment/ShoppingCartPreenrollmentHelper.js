({
    stepsConfig : {
        "ChooseOpportunity": {
            nextButtonId: "chooseOpportunityNextButton",
            buttonLabel: "Choose Opportunity",
            isPreenrollmentStep: true,
            
            validateBeforeNextStep : function(component, helper) {
                return helper.validateChooseOpportunityStep(component, helper);
            },
            
            openAction : function(component, helper) {
                helper.openPreenrollmentProducts(component, helper);
            }
        },
    
        "ChooseMaterials": {
            nextButtonId: "chooseMaterialsNextButton",
            previousButtonId: "chooseMaterialsPreviousButton",
            buttonLabel: "Select Materials",
            isPreenrollmentStep: true,

            validateBeforeNextStep : function(component, helper) {
                return helper.validateChooseMaterials(component, helper);
            },

            openAction : function(component, helper) {
                helper.openPreenrollmentProducts(component, helper);
            }
        },

        "EnterGroupInformation": {
            buttonLabel: "Enter Group Information",
            previousButtonId: "enterGroupInformationPreviousButton",
            nextButtonId: "enterGroupInformationNextButton",
            isPreenrollmentStep: true,
            
            validateBeforeNextStep : function(component, helper) {
                return helper.validateGroupInformation(component, helper);
            },

            afterValidation : function(component, event, helper, onSuccessCallback) {
                helper.saveGroupInformation(component, event, helper, onSuccessCallback);
            }
        },

        "SetupEnrollmentSites": {
            buttonLabel: "Setup Enrollment Sites & Schedules",
            previousButtonId: "setupEnrollmentSitesAndSchedulesPreviousButton",
            nextButtonId: "setupEnrollmentSitesAndSchedulesNextButton",
            isPreenrollmentStep: true,
            
            validateBeforeNextStep : function(component, helper) {
                return helper.validateEnrollmentSites(component, helper);
            },
            
            openAction : function(component, helper) {
                helper.openEnrollmentSites(component);
            }
        },
        
        "SetupBenefitsSite": {
            buttonLabel: "Setup Benefits Site",
            previousButtonId: "setupBenefitsSitePreviousButton",
            nextButtonId: "setupBenefitsSiteNextButton",
            isPreenrollmentStep: true,
            
            validateBeforeNextStep : function(component, helper) {
                return helper.validateBenefitsSite(component, helper);
            }
        },

        "SetupAppointmentScheduler": {
            buttonLabel: "Setup Appointment Scheduler",
            previousButtonId: "setupApptSchedulerPreviousButton",
            nextButtonId: "setupApptSchedulerNextButton",
            isPreenrollmentStep: true,

            validateBeforeNextStep : function(component, helper) {
                return helper.validateAppointmentScheduler(component, helper);
            }
        },
        
        "Cart": {
            buttonLabel: "Cart",
            isPreenrollmentStep: false,
            
            openAction : function(component, helper) {
                helper.addMaterialsAndOpenCart(component, helper);
            }
        }
    },
    
    loadDefaultValues : function(component) {
        component.set('v.benefitsSiteInput', {});
    },
    
    loadFromExistingOrder : function(component) {
        var helper = this;
        var cart = component.get('v.cart');
        var cartLines = component.get('v.lineItems');
        
        if (!cartLines) {
            return;
        }
        
        for (let cartLine of cartLines) {
            if (cartLine.Record.Opportunity__c) {
                component.set('v.enrollmentOpportunityId', cartLine.Record.Opportunity__c);
                helper.loadEnrollmentInfo(component, cartLine.Record.Opportunity__c);
                return;
            }
        }
    },
    
    loadFromEnrollmentOpportunityId : function(component) {
        var helper = this;
        var enrollmentOpportunityId = component.get("v.enrollmentOpportunityId");
        
        if (enrollmentOpportunityId) {
            helper.loadEnrollmentInfo(component, enrollmentOpportunityId);
        }
    },

    validateChooseOpportunityStep : function(component, helper) {
        var helper = this;
        var enrollmentOppId = component.get('v.enrollmentOpportunityId');

        var enrollmentOpportunityLookupCmp = component.find('enrollmentOpportunityLookup');
        enrollmentOpportunityLookupCmp.set('v.error', false);

        if (!enrollmentOppId) {
            enrollmentOpportunityLookupCmp.set('v.error', true);
            return false;
        }
        
        return true;
    },

    openPreenrollmentProducts : function(component, helper) {

        var action = component.get("c.getPreenrollmentMaterials");
        
        action.setCallback(this, function(result){
            var state = result.getState();

            if(component.isValid() && state === "SUCCESS") {
                var preenrollmentMaterials = result.getReturnValue();
                var preenrollmentMaterialsOptions = [];
                var enrollmentOppInfo = component.get('v.enrollmentOpportunityInfo');
                var digitalMaterials = [];
                var printMaterials = [];
                
                for (let pm of preenrollmentMaterials) {
                    var existingPurchaseCartLine = helper.findCartLineItemByMarketingMaterial(component, pm);

                    pm.isInCart = existingPurchaseCartLine != null;
                    pm.isDisabled = false;
                    
                    if ((pm.Record.Group_Type__c &&
                         enrollmentOppInfo.NewOrExisting &&
                         pm.Record.Group_Type__c.includes(enrollmentOppInfo.NewOrExisting) == false) ||
                         (pm.Record.Group_Type__c &&
                          !enrollmentOppInfo.NewOrExisting)) {
                        pm.isDisabled = true;
                    }
                    
                    if ((pm.Record.Minimum_Eligibles__c &&
                         enrollmentOppInfo.EligibleEmployeeCount &&
                         enrollmentOppInfo.EligibleEmployeeCount < pm.Record.Minimum_Eligibles__c) ||
                        (pm.Record.Minimum_Eligibles__c &&
                         !enrollmentOppInfo.EligibleEmployeeCount) 
                       ) {
                        pm.isDisabled = true;
                    }
                    
                    if ((pm.Record.Enrollment_Path__c &&
                         enrollmentOppInfo.EnrollmentPath &&
                         pm.Record.Enrollment_Path__c.includes(enrollmentOppInfo.EnrollmentPath) == false) ||
                        (pm.Record.Enrollment_Path__c &&
                         !enrollmentOppInfo.EnrollmentPath)
                       ) {
                        pm.isDisabled = true;
                    }
                
                    if (pm.Record.Pre_enrollment_Segment__c == 'Digital') {
                        digitalMaterials.push(pm);
                    }
                    else if (pm.Record.Pre_enrollment_Segment__c == 'Print') {
                        printMaterials.push(pm);
                    }
                }
                
                component.set('v.printMaterials', printMaterials);
                component.set('v.digitalMaterials', digitalMaterials);
                component.set("v.preenrollmentMaterials", preenrollmentMaterials);

                helper.loadSpecialMarketingMaterialAttributesFromExistingCart(component);
                helper.updateStepsAndStepButtons(component);
            }
            else {
                helper.showErrorToastFromErrorResponse(result);
            }

        });
        
        $A.enqueueAction(action);
    },

    findCartLineItemByMarketingMaterial : function(component, marketingMaterial) {
        var cartLines = component.get('v.lineItems');
        
        if (!cartLines) {
            return;
        }
        
        for (let cartLine of cartLines) {
            if (cartLine.Record.Marketing_Material__c == marketingMaterial.Record.Id) {
                return cartLine;
            }
        }

        return null;
    },

    validateChooseMaterials : function(component, helper) {
        var selectedMaterialIds = helper.getSelectedMarketingMaterialIds(component);
        
        if (selectedMaterialIds.length == 0) {
            helper.showErrorToast('At least one material needs to be selected.');
            return false;
        }
        
        return true;
    },

    validateGroupInformation : function(component, helper) {
        var opportunityInfo = component.get('v.enrollmentOpportunityInfo');
        var marketingAccountName = opportunityInfo.Account.Marketing_Account_Name__c;

        if (!marketingAccountName) {
            return false;
        }

        return true;
    },

    saveGroupInformation : function(component, event, helper, onSuccessCallback) {
        var opportunityInfo = component.get('v.enrollmentOpportunityInfo');
        var newMarketingAccountName = opportunityInfo.Account.Marketing_Account_Name__c;
        var lastMarketingAccountName = component.get('v.lastMarketingAccountName');

        if (newMarketingAccountName === lastMarketingAccountName) {
            onSuccessCallback(component, event, helper);
            return;
        }

        var accountToUpdate = {
            "sobjectType": "Account",
            "Id": opportunityInfo.AccountId,
            "Marketing_Account_Name__c": newMarketingAccountName
        };
        
        var action = component.get('c.updateAccount');
        action.setParams({
            "accountToUpdate": accountToUpdate
        });
        
        action.setCallback(component, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                component.set('v.lastMarketingAccountName', newMarketingAccountName);
                onSuccessCallback(component, event, helper);
            }
            else {
                console.log('Problem updating the account. Response error: ' + JSON.stringify(response.getError()));
            }
        });
        
        $A.enqueueAction(action);
    },
    
    openEnrollmentSites : function(component) {
        var helper = this;
        
        var action = component.get("c.getAccountEnrollmentSites");
        var enrollmentOppInfo = component.get('v.enrollmentOpportunityInfo');
        
        action.setParams({
            "accountId" : enrollmentOppInfo.AccountId,
            "opportunityId" : enrollmentOppInfo.EnrollmentOpportunity.Id
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();

            if(component.isValid() && state === "SUCCESS") {
                var enrollmentSites = result.getReturnValue();
                
                component.set('v.enrollmentSites', enrollmentSites);
            }
            else {
                helper.showErrorToastFromErrorResponse(result);
            }

        });
        
        $A.enqueueAction(action);
    },
    
    validateEnrollmentSites : function(component, helper) {
        var enrollmentSites = component.get('v.enrollmentSites');
        var addEnrollmentSites = component.get('v.addEnrollmentSites');

        if (!addEnrollmentSites) {
            return true;
        }

        if (!enrollmentSites || enrollmentSites.length == 0) {
            helper.showErrorToast('At least one site is required.');

            return false;
        }

        var numEnrollmentSchedules = 0;

        for (let enrollmentSite of enrollmentSites) {
            if (enrollmentSite.Record.Enrollment_Site_Dates__r) {
                numEnrollmentSchedules += enrollmentSite.Record.Enrollment_Site_Dates__r.length;
            }
        }

        if (numEnrollmentSchedules == 0) {
            helper.showErrorToast('At least one schedule at an enrollment site is required.');

            return false;
        }

        return true;
    },
    
    validateBenefitsSite : function(component, helper) {
        var isValid = true;
        var groupDisplayNameInput = component.find('groupDisplayName');
        
        if (groupDisplayNameInput)  {
            if (!groupDisplayNameInput.checkValidity()) {
                isValid = false;
                groupDisplayNameInput.reportValidity();
            }
        }

        var branchOfficeInput = component.find('branchOffice');

        if (branchOfficeInput) {
            if (branchOfficeInput.get('v.value')) {
                branchOfficeInput.set('v.error', false);
            }
            else {
                branchOfficeInput.set('v.error', true);
            }
        }
        
        var benefitsSiteInput = component.get('v.benefitsSiteInput');
        
        for (let importProduct of benefitsSiteInput.ImportProducts) {
            var carrierInput = helper.findImportProductInputByName(component, importProduct, 'carrier');
            var carrierURLInput = helper.findImportProductInputByName(component, importProduct, 'carrierurl');
            
            carrierInput.reportValidity();
            carrierURLInput.reportValidity();
        
            if (!importProduct.Include_on_Employer_Benefits_Site__c) {
                continue;
            }
            
            if (!importProduct.Carrier__c) {
                carrierInput.reportValidity();
                isValid = false;
            }
            
            if (!importProduct.Carrier_URL__c) {
                carrierURLInput.reportValidity();
                isValid = false;
            }
        }
        
        var licenseNumberInput = component.find('licenseNumber')
        
        if (licenseNumberInput.get('v.required')) {
            licenseNumberInput.reportValidity();
            
            if (!benefitsSiteInput.LicenseNumber) {
                licenseNumberInput.reportValidity();
                isValid = false;
            }
        }
        
        var openEnrollmentStartDateInput = component.find('openEnrollmentStartDate');
        openEnrollmentStartDateInput.hideRequiredFieldMessage();
        
        if (!benefitsSiteInput.OpenEnrollmentStartDate) {
            openEnrollmentStartDateInput.showRequiredFieldMessage();
        }
        
        var openEnrollmentEndDateInput = component.find('openEnrollmentEndDate');
        openEnrollmentEndDateInput.hideRequiredFieldMessage();
        
        if (!benefitsSiteInput.OpenEnrollmentEndDate) {
            openEnrollmentEndDateInput.showRequiredFieldMessage();
        }
        
        var showOneonOneInformationInput = component.find('showOneOnOneInformation');
        showOneonOneInformationInput.setCustomValidity('');
        showOneonOneInformationInput.reportValidity();
        
        if (!benefitsSiteInput.ShowOneonOneInformation &&
            !benefitsSiteInput.ShowSelfServiceInformation) {
            showOneonOneInformationInput.setCustomValidity("Either Show One-on-One Information or Show Self-Service Information must be checked so there's at least one way to enroll.");
            showOneonOneInformationInput.reportValidity();
        }
        
        component.set('v.benefitsSiteInput', benefitsSiteInput);
    
        return isValid;
    },

    validateAppointmentScheduler : function(component, helper) {
        var isValid = true;
        var groupDisplayNameInput = component.find('apptSchedulerGroupDisplayName');
        
        if (groupDisplayNameInput)  {
            if (!groupDisplayNameInput.checkValidity()) {
                isValid = false;
                groupDisplayNameInput.reportValidity();
            }
        }

        var branchOfficeInput = component.find('apptSchedulerBranchOffice');

        if (branchOfficeInput) {
            if (branchOfficeInput.get('v.value')) {
                branchOfficeInput.set('v.error', false);
            }
            else {
                branchOfficeInput.set('v.error', true);
            }
        }

        return isValid;
    },

    findImportProductInputByName : function(component, importProd, inputName) {
        var importProdInputs = component.find(inputName);
        
        // Only 1 import product so only one import input created.
        if (importProdInputs && !Array.isArray(importProdInputs)) {
            return importProdInputs;
        }
        
        for (let importProdInput of importProdInputs) {
            let inputName = importProdInput.get('v.name');
            
            if (inputName == importProd.Id) {
                return importProdInput;
            }
        }
        
        return null;
    },
    
     loadEnrollmentInfo : function(component, enrollmentOpportunityId) {
        var helper = this;
        var action = component.get("c.getEnrollmentOpportunityInformation");
        
        action.setParams({
            "enrollmentOpportunityId" : enrollmentOpportunityId
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();

            if(component.isValid() && state === "SUCCESS") {
                var opportunityInfo = result.getReturnValue();
                
                component.set("v.enrollmentOpportunityInfo", opportunityInfo);
                var benefitsSiteInput = component.get('v.benefitsSiteInput');
                benefitsSiteInput.ImportProducts = opportunityInfo.ImportProducts;
                component.set('v.lastMarketingAccountName', opportunityInfo.Account.Marketing_Account_Name__c);
                
                // Set the sObjectType on the import product so it can be deserialized properly
                // back to Salesforce.
                if (benefitsSiteInput.ImportProducts && Array.isArray(benefitsSiteInput.ImportProducts)) {
                    for (let importProduct of benefitsSiteInput.ImportProducts) {
                        importProduct.sobjectType = 'Marketed_Product__c';
                    }
                }
                
                benefitsSiteInput.ShowOneonOneInformation = opportunityInfo.PreenrollmentForm.Show_One_on_One_Information__c;
                benefitsSiteInput.ShowSelfServiceInformation = opportunityInfo.PreenrollmentForm.Show_Self_Service_Information__c;
                benefitsSiteInput.Title = opportunityInfo.EnrollmentOpportunity.Assigned_Account_Manager__r.Title;
                benefitsSiteInput.OpenEnrollmentStartDate = opportunityInfo.EnrollmentOpportunity.Enrollment_Start_Date__c;
                benefitsSiteInput.OpenEnrollmentEndDate = opportunityInfo.EnrollmentOpportunity.Enrollment_End_Date__c;
                
                component.set('v.benefitsSiteInput', benefitsSiteInput);
            }
            else {
                helper.showErrorToastFromErrorResponse(result);
            }

        });
        
        $A.enqueueAction(action);
    },
    
    loadNewEnrollmentSiteModal : function(component) {
        var enrollmentOppInfo = component.get('v.enrollmentOpportunityInfo');
        var newEnrollmentSiteRecord = { "sobjectType": 'Enrollment_Site__c', "Account__c": enrollmentOppInfo.AccountId };
        component.set('v.NewEnrollmentSiteRecord', newEnrollmentSiteRecord);
        
        var newEnrollmentSiteModal = component.find('newEnrollmentSiteModal');
        newEnrollmentSiteModal.showModalUsingRecord();
    },
    
    saveNewEnrollmentSite : function(component) {
        var helper = this;
        var newEnrollmentSiteModal = component.find('newEnrollmentSiteModal');
        newEnrollmentSiteModal.clearValidationMessages();

        var isValid = newEnrollmentSiteModal.validate();

        if (!isValid) {
            newEnrollmentSiteModal.showValidationMessages();
            return;
        }
    
        var newEnrollmentSiteRecord = component.get('v.NewEnrollmentSiteRecord');
        
        var action = component.get('c.addNewEnrollmentSite');
        action.setParams({
            "newEnrollmentSite": newEnrollmentSiteRecord
        });
        
        action.setCallback(component, function(response){
            var state = response.getState();
            var newEnrollmentSiteModal = component.find('newEnrollmentSiteModal');

            if (component.isValid() && state === "SUCCESS") {
                newEnrollmentSiteRecord.Id = response.getReturnValue();
                newEnrollmentSiteModal.hideModal();
                
                helper.loadNewLocationIntoExistingLocations(component, helper, newEnrollmentSiteRecord);
                helper.showSuccessToast('The new enrollment location was saved successfully.');
            }
            else {
                newEnrollmentSiteModal.set('v.errorResponse', response);
                console.log('Problem saving the new enrollment site. Response state: ' + state);
            }
        });
        
        $A.enqueueAction(action);
    },

    saveEditedEnrollmentSite : function(component) {
        var helper = this;
        var editEnrollmentSiteModal = component.find('editEnrollmentSiteModal');
        editEnrollmentSiteModal.clearValidationMessages();

        var isValid = editEnrollmentSiteModal.validate();

        if (!isValid) {
            editEnrollmentSiteModal.showValidationMessages();
            return;
        }
    
        var editEnrollmentSiteRecord = component.get('v.EditEnrollmentSiteRecord');
        
        var action = component.get('c.updateEnrollmentSite');
        action.setParams({
            "enrollmentSiteToUpdate": editEnrollmentSiteRecord
        });
        
        action.setCallback(component, function(response){
            var state = response.getState();
            var editEnrollmentSiteModal = component.find('editEnrollmentSiteModal');

            if (component.isValid() && state === "SUCCESS") {
                editEnrollmentSiteModal.hideModal();
                
                helper.loadEditedSiteIntoExistingSites(component, helper, editEnrollmentSiteRecord);
                helper.showSuccessToast('The enrollment site was saved successfully.');
            }
            else {
                editEnrollmentSiteModal.set('v.errorResponse', response);
                console.log('Problem saving the updated enrollment site. Response state: ' + state);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    saveNewEnrollmentSiteDate : function(component) {
        var helper = this;
        var newEnrollmentSiteDateModal = component.find('newEnrollmentSiteDateModal');
        newEnrollmentSiteDateModal.clearValidationMessages();

        var isValid = newEnrollmentSiteDateModal.validate();

        if (!isValid) {
            newEnrollmentSiteDateModal.showValidationMessages();
            return;
        }
    
        var newEnrollmentSiteDateRecord = component.get('v.NewEnrollmentSiteDateRecord');
        
        var action = component.get('c.addNewEnrollmentSiteDate');
        action.setParams({
            "newEnrollmentSiteDate": newEnrollmentSiteDateRecord
        });
        
        action.setCallback(component, function(response){
            var state = response.getState();
            var newEnrollmentSiteDateModal = component.find('newEnrollmentSiteDateModal');
            
            if (component.isValid() && state === "SUCCESS") {
                newEnrollmentSiteDateModal.hideModal();
                newEnrollmentSiteDateRecord.Id = response.getReturnValue();
                
                helper.loadNewEnrollmentSiteDateIntoExistingOnesForEnrollmentSite(component, helper, newEnrollmentSiteDateRecord);
                component.set('v.NewEnrollmentSiteDateRecord', null);
                helper.showSuccessToast('The new enrollment schedule was saved successfully.');
            }
            else {
                newEnrollmentSiteDateModal.set('v.errorResponse', response);
                console.log('Problem saving the new enrollment site. Response state: ' + state);
            }
        });
        
        $A.enqueueAction(action);
    },

    saveEditedEnrollmentSiteDate : function(component) {
        var helper = this;
        var editEnrollmentSiteDateModal = component.find('editEnrollmentSiteDateModal');
        editEnrollmentSiteDateModal.clearValidationMessages();

        var isValid = editEnrollmentSiteDateModal.validate();

        if (!isValid) {
            editEnrollmentSiteDateModal.showValidationMessages();
            return;
        }
    
        var editedEnrollmentSiteDateRecord = component.get('v.EditEnrollmentSiteDateRecord');
        
        var action = component.get('c.updateEnrollmentSiteDate');
        action.setParams({
            "updatedEnrollmentSiteDate": editedEnrollmentSiteDateRecord
        });
        
        action.setCallback(component, function(response){
            var state = response.getState();
            var editEnrollmentSiteDateModal = component.find('editEnrollmentSiteDateModal');
            
            if (component.isValid() && state === "SUCCESS") {
                editEnrollmentSiteDateModal.hideModal();
                
                helper.loadEditedEnrollmentSiteDateIntoExistingOnes(component, editedEnrollmentSiteDateRecord);
                
                component.set('v.EditEnrollmentSiteDateRecord', null);
                helper.showSuccessToast('The updated enrollment schedule was saved successfully.');
            }
            else {
                editEnrollmentSiteDateModal.set('v.errorResponse', response);
                console.log('Problem saving the updated enrollment site. Response state: ' + state);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    deleteEnrollmentSiteDate : function(component, enrollmentSiteDate) {
        var helper = this;
        
        var action = component.get('c.deleteEnrollmentSiteDate');
        action.setParams({
            "enrollmentSiteIdToDelete": enrollmentSiteDate.Id
        });
        
        action.setCallback(component, function(response){
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                
                helper.removeDeletedEnrollmentSiteDateFromExistingOnes(component, enrollmentSiteDate);
                
                helper.hideDeleteEnrollmentSiteDateModal(component);
                helper.showSuccessToast('The enrollment schedule was deleted successfully.');
            }
            else {
                editEnrollmentSiteDateModal.set('v.errorResponse', response);
                console.log('Problem deleting the enrollment site. Response state: ' + state);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showDeleteEnrollmentSiteDateModal : function(component) {
        component.set('v.showDeleteEnrollmentSiteDateModal', true);
    },
    
    hideDeleteEnrollmentSiteDateModal : function(component) {
        component.set('v.showDeleteEnrollmentSiteDateModal', false);
    },
    
    addMaterialsAndOpenCart : function(component, helper) {
        helper.showSpinner(component);

        var enrollmentOpportunityId = component.get('v.enrollmentOpportunityId');
        var selectedMaterialIds = helper.getSelectedMarketingMaterialIds(component);
        var benefitsSiteInfo = component.get('v.benefitsSiteInput');
        var preenrollmentMarketingFormId = component.get('v.preenrollmentMarketingFormId');
        
        // Import Products don't deserialize back properly on Salesforce
        // so make it a string and deserialize it manually.
        var benefitsSiteInfoJSON = JSON.stringify(benefitsSiteInfo);
        var otherPreenrollmentInfo = {};
        otherPreenrollmentInfo.addEnrollmentSitesForBuildYourOwnTimeToEnrollEmail = component.get('v.addEnrollmentSites');
        
        var action = component.get('c.addPreenrollmentInfo');
        action.setParams({
            "opportunityId": enrollmentOpportunityId,
            "marketingMaterialsIds": selectedMaterialIds,
            "benefitsSiteInfoJSON": benefitsSiteInfoJSON,
            "preenrollmentMarketingFormId": preenrollmentMarketingFormId,
            "otherPreenrollmentInfo": otherPreenrollmentInfo
        });
        
        action.setCallback(component, function(response){
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var orderId = response.getReturnValue();
            
                helper.showSuccessToast('The preenrollment materials were added to the cart.');
                
                var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
		        newEvent.setParams({
		            "navigate" : "CartReviewView",
		            "OrderId": orderId,
		            "ReturnLocation": "PreenrollmentView"
		        });

		        newEvent.fire();
            }
            else {
                helper.showErrorToastFromErrorResponse(response);
            }

            helper.hideSpinner(component);
        });
        
        $A.enqueueAction(action);
    },
    
    loadNewLocationIntoExistingLocations : function(component, helper, newEnrollmentSiteRecord) {
        var enrollmentSites = component.get('v.enrollmentSites');
        enrollmentSites.push({ "Record": newEnrollmentSiteRecord });
        
        enrollmentSites.sort(function (es1, es2) {
		    return ('' + es1.Record.Name).localeCompare(es2.Record.Name);
		});
		
		component.set('v.enrollmentSites', enrollmentSites);
    },

    loadEditedSiteIntoExistingSites : function(component, helper, editEnrollmentSiteRecord) {
        var enrollmentSites = component.get('v.enrollmentSites');

        for (let es of enrollmentSites) {
            if (es.Record.Id == editEnrollmentSiteRecord) {
                es.Record = editEnrollmentSiteRecord;
                break;
            }
        }

        component.set('v.enrollmentSites', enrollmentSites);
    },
    
    loadNewEnrollmentSiteDateIntoExistingOnesForEnrollmentSite : function(component, helper, newEnrollmentSiteDateRecord) {
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSite = enrollmentSites.find((es) => { return es.Record.Id == newEnrollmentSiteDateRecord.Enrollment_Site__c });
        
        if (!selectedEnrollmentSite.Record.Enrollment_Site_Dates__r) {
            selectedEnrollmentSite.Record.Enrollment_Site_Dates__r = [];
        }
        
        selectedEnrollmentSite.Record.Enrollment_Site_Dates__r.push(newEnrollmentSiteDateRecord);
        
        component.set('v.enrollmentSites', enrollmentSites);
    },
    
    loadEditedEnrollmentSiteDateIntoExistingOnes : function(component, updatedEnrollmentSiteDate) {
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSite = enrollmentSites.find((es) => { return es.Record.Id == updatedEnrollmentSiteDate.Enrollment_Site__c });
        
        if (!selectedEnrollmentSite.Enrollment_Site_Dates__r) {
            selectedEnrollmentSite.Enrollment_Site_Dates__r = [];
        }
        
        for (var i = 0; i < selectedEnrollmentSite.Enrollment_Site_Dates__r.length; ++i) {
            let enrollmentSiteDate = selectedEnrollmentSite.Enrollment_Site_Dates__r[i];
            
            if (enrollmentSiteDate.Id == updatedEnrollmentSiteDate.Id) {
                selectedEnrollmentSite.Enrollment_Site_Dates__r[i] = updatedEnrollmentSiteDate;
                break;
            }
        }
        
        component.set('v.enrollmentSites', enrollmentSites);
    },
    
    removeDeletedEnrollmentSiteDateFromExistingOnes : function(component, deletedEnrollmentSiteDate) {
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSite = enrollmentSites.find((es) => { return es.Record.Id == deletedEnrollmentSiteDate.Enrollment_Site__c });
        
        for (var i = 0; i < selectedEnrollmentSite.Record.Enrollment_Site_Dates__r.length; ++i) {
            let enrollmentSiteDate = selectedEnrollmentSite.Record.Enrollment_Site_Dates__r[i];
            
            if (enrollmentSiteDate.Id == deletedEnrollmentSiteDate.Id) {
                selectedEnrollmentSite.Record.Enrollment_Site_Dates__r.splice(i, 1);
                break;
            }
        }
        
        component.set('v.enrollmentSites', enrollmentSites);
    },
    
    loadNewEnrollmentSiteDateModal : function(component, enrollmentSiteId) {
        var enrollmentOpportunityId = component.get('v.enrollmentOpportunityId');
        var newEnrollmentSiteDateRecord = { "sobjectType": 'Enrollment_Site_Date__c', "Enrollment_Opportunity__c": enrollmentOpportunityId, "Enrollment_Site__c": enrollmentSiteId, "Show_In_Build_Time_To_Enroll_Email__c": true };
        component.set('v.NewEnrollmentSiteDateRecord', newEnrollmentSiteDateRecord);
        
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSiteToSchedule = enrollmentSites.find((es) => { return es.Record.Id == enrollmentSiteId });
        component.set('v.selectedEnrollmentSiteToSchedule', selectedEnrollmentSiteToSchedule.Record);
        
        var newEnrollmentSiteDateModal = component.find('newEnrollmentSiteDateModal');
        newEnrollmentSiteDateModal.showModalUsingRecord();
    },

    loadEditEnrollmentSiteModal : function(component, enrollmentSiteId) {
        var enrollmentSites = component.get('v.enrollmentSites');
        var enrollmentSiteToEdit = enrollmentSites.find(es => { return es.Record.Id == enrollmentSiteId });

        component.set('v.EditEnrollmentSiteRecord', enrollmentSiteToEdit.Record);

        var editEnrollmentSiteModal = component.find('editEnrollmentSiteModal');
        editEnrollmentSiteModal.showModalUsingRecord();
    },
    
    loadEditEnrollmentSiteDateModal : function(component, enrollmentSiteDate) {
        component.set('v.EditEnrollmentSiteDateRecord', enrollmentSiteDate);
        
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSite = enrollmentSites.find((es) => { return es.Record.Id == enrollmentSiteDate.Enrollment_Site__c });
        component.set('v.selectedEnrollmentSiteToSchedule', selectedEnrollmentSite.Record);
        
        var editEnrollmentSiteDateModal = component.find('editEnrollmentSiteDateModal');
        editEnrollmentSiteDateModal.showModalUsingRecord();
    },
    
    getSelectedMarketingMaterialIds : function(component) {
        var helper = this;
        var printMaterialCheckboxes = component.find('printMaterialCheckbox');
        var digitalMaterialCheckboxes = component.find('digitalMaterialCheckbox');
        var digitalMaterialCheckboxesArray = helper.buildMaterialCheckboxesArray(digitalMaterialCheckboxes);
        var printMaterialCheckboxesArray = helper.buildMaterialCheckboxesArray(printMaterialCheckboxes);
        
        var selectedMaterialIds = helper.getSelectedMaterialIdsFromCheckboxes(digitalMaterialCheckboxesArray);
        var selectedPrintMaterialIds = helper.getSelectedMaterialIdsFromCheckboxes(printMaterialCheckboxesArray);
        selectedMaterialIds = selectedMaterialIds.concat(selectedPrintMaterialIds);
        
        return selectedMaterialIds;
    },
    
    buildMaterialCheckboxesArray : function(materialCheckboxesFindResult) {
        var materialCheckboxesArray = [];
        
        if (!materialCheckboxesFindResult) {
            return materialCheckboxesArray;
        }
        
        if (materialCheckboxesFindResult && Array.isArray(materialCheckboxesFindResult)) {
            materialCheckboxesArray = materialCheckboxesFindResult;
        }
        else if (materialCheckboxesFindResult) {
            materialCheckboxesArray.push(materialCheckboxesFindResult);
        }
        
        return materialCheckboxesArray;
    },
    
    getSelectedMaterialIdsFromCheckboxes : function(materialCheckboxComponents) {
        var selectedMaterialIds = [];
        
        for (let materialCheckbox of materialCheckboxComponents) {
            let material = materialCheckbox.get('v.value');
            let checked = materialCheckbox.get('v.checked');
            
            if (checked) {
                selectedMaterialIds.push(material.Id);
            }
        }
        
        return selectedMaterialIds;
    },

    loadSpecialMarketingMaterialAttributesFromExistingCart : function(component) {
        // LF: For some reason adding the print materials to the digital materials actually updates
        // the UI so the print materials are shown in the digital materials too. To prevent that,
        // deep clone the materials and then use them.
        var preenrollmentMaterials = JSON.parse(JSON.stringify(component.get('v.digitalMaterials')));
        var printMaterialsCopy = JSON.parse(JSON.stringify(component.get('v.printMaterials')));

        for (let pm of printMaterialsCopy) {
            preenrollmentMaterials.push(pm);
        }

        var hasBenefitsSite = false;
        var hasAppointmentScheduler = false;
        var hasTimeToEnrollBuildYourOwnEmail = false;

        for (let preenrollmentMaterial of preenrollmentMaterials) {
            if (preenrollmentMaterial.isInCart) {
                if (preenrollmentMaterial.Record.Website_Type__c == 'Benefits Site') {
                    hasBenefitsSite = true;
                }
                else if (preenrollmentMaterial.Record.Website_Type__c == 'Appointment Scheduler') {
                    hasAppointmentScheduler = true;
                }

                // Case Insensitive Compare
                if (preenrollmentMaterial.Record.Email_To_Build__c &&
                    preenrollmentMaterial.Record.Email_To_Build__c.localeCompare('Time To Enroll', 'en', {sensitivity: 'base'}) == 0) {
                    hasTimeToEnrollBuildYourOwnEmail = true;
                }
            }
        }

        component.set('v.hasBenefitsSite', hasBenefitsSite);
        component.set('v.hasAppointmentScheduler', hasAppointmentScheduler);
        component.set('v.hasTimeToEnrollBuildYourOwnEmail', hasTimeToEnrollBuildYourOwnEmail);
    },
    
    updateSelectedMaterialAttributesOnChange : function(component, materialCheckbox) {
        var marketingMaterial = materialCheckbox.get('v.value');
        var checked = materialCheckbox.get('v.checked');
        
        if (marketingMaterial.Website_Type__c == 'Benefits Site') {
            component.set('v.hasBenefitsSite', checked);
        }
        
        if (marketingMaterial.Website_Type__c == 'Appointment Scheduler') {
            component.set('v.hasAppointmentScheduler', checked);
        }
        
        if (marketingMaterial.Email_To_Build__c &&
            marketingMaterial.Email_To_Build__c.localeCompare('Time To Enroll', 'en', {sensitivity: 'base'}) == 0) {
            component.set('v.hasTimeToEnrollBuildYourOwnEmail', checked);
        }
    },
    
    updateStepsAndStepButtons : function(component) {
        var helper = this;

        // Start at step 1, "ChooseOpportunity"
        var steps = ["ChooseOpportunity", "ChooseMaterials"];
        
        var hasBenefitsSite = component.get('v.hasBenefitsSite');
        var hasTimeToEnrollBuildYourOwnEmail = component.get('v.hasTimeToEnrollBuildYourOwnEmail');
        var hasAppointmentScheduler = component.get('v.hasAppointmentScheduler');
        var enrollmentInfo = component.get('v.enrollmentOpportunityInfo');
        var isNewEmployerForApptScheduler = enrollmentInfo && enrollmentInfo.Account && !enrollmentInfo.Account.Marketing_Resource_ID__c;

        if (hasBenefitsSite) {
            steps.push('SetupBenefitsSite');
        }
        else if (hasAppointmentScheduler && isNewEmployerForApptScheduler) {
            steps.push('SetupAppointmentScheduler');
        }
        
        if (hasTimeToEnrollBuildYourOwnEmail) {
            steps.push('EnterGroupInformation');
            steps.push('SetupEnrollmentSites');
        }
        
        steps.push('Cart');
        
        component.set('v.intermediateSteps', steps);
        
        // There should always be at least two steps, ChooseMaterials and Cart        
        for (var i = 0; i < steps.length - 1; ++i) {
            let thisStep = steps[i];
            let nextStep = steps[i + 1];
            
            let thisStepConfig = helper.stepsConfig[thisStep];
            let nextStepConfig = helper.stepsConfig[nextStep];
            
            let thisStepNextButton = component.find(thisStepConfig.nextButtonId);
            
            thisStepNextButton.set('v.label', 'Next: ' + nextStepConfig.buttonLabel);
            thisStepNextButton.set('v.value', nextStep);
            
            if (nextStepConfig.previousButtonId) {
                let nextStepPreviousButton = component.find(nextStepConfig.previousButtonId);
                nextStepPreviousButton.set('v.label', 'Previous: ' + thisStepConfig.buttonLabel);
                nextStepPreviousButton.set('v.value', thisStep);
            }
        }
    },

    openNextStep : function(component, event, helper) {
        var nextButton = event.getSource();
        var nextStep = nextButton.get('v.value');
        var nextStepConfig = helper.stepsConfig[nextStep];
        
        if (nextStepConfig.openAction) {
            nextStepConfig.openAction(component, helper);
        }
        
        if (nextStepConfig.isPreenrollmentStep) {
            component.set('v.currentStep', nextStep);
        }
    },

    setCurrentStepFromRequestedStep : function(component) {
        var helper = this;
        var requestedStep = component.get('v.requestedStep');
        var requestedStepConfig = helper.stepsConfig[requestedStep];

        if (requestedStepConfig) {
            component.set('v.currentStep', requestedStep);

            if (requestedStepConfig.openAction) {
                requestedStepConfig.openAction(component, helper);
            }
        }
    },

    findEnrollmentSiteDate : function(component, enrollmentSiteDateId) {
        var enrollmentSites = component.get('v.enrollmentSites');

        for (let es of enrollmentSites) {
            if (!es.Record.Enrollment_Site_Dates__r) {
                continue;
            }

            for (let esd of es.Record.Enrollment_Site_Dates__r) {
                if (esd.Id == enrollmentSiteDateId) {
                    return esd;
                }
            }
        }

        return null;
    },
    
    setCurrentStepToChooseMaterials : function(component) {
        component.set('v.currentStep', 'ChooseMaterials');
    },
    
    setCurrentStepToChooseOpportunity : function(component) {
        component.set('v.currentStep', 'ChooseOpportunity');
    },
    
    showSuccessToast : function(successMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": successMessage,
            "type": 'success'
        });
        toastEvent.fire();
    },
    
    showErrorToastFromErrorResponse : function(response) {
        var errors = response.getError();
        var helper = this;

        if (errors) {
            if (errors[0] && errors[0].message) {
                let errorMessage = errors[0].message;
                
                helper.showErrorToast(errorMessage);
                console.log("Error: " + errorMessage);
            }
        } else {
            console.log("Unknown error");
        }
    },
    
    showErrorToast : function(errorMessage) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "message": errorMessage,
	        "type": 'error'
	    });
	    toastEvent.fire();
    },
    
    scrollToTop : function() {
        window.scrollTo(0, 0);
    },

    showSpinner : function(component) {
        component.set('v.showSpinner', true);
    },

    hideSpinner : function(component) {
        component.set('v.showSpinner', false);
    },
})