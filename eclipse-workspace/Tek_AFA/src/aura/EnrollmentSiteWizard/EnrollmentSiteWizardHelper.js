({
    loadEnrollmentSiteInfo : function(component) {
        var pageReference = component.get("v.pageReference");
        var opportunityId = pageReference.state.c__OpportunityId;
        var accountId = pageReference.state.c__AccountId;

        if (!opportunityId || !accountId) {
            return;
        }

        component.set('v.accountId', accountId);
        component.set('v.opportunityId', opportunityId);

        var action = component.get("c.getAccountEnrollmentSitesInfo");
        var helper = this;
        
        action.setParams({
            "accountId" : accountId,
            "opportunityId": opportunityId
        });
        
        action.setCallback(this, function(result){
            var state = result.getState();

            if(component.isValid() && state === "SUCCESS") {
                var enrollmentSiteInfo = result.getReturnValue();
                var enrollmentSites = enrollmentSiteInfo.EnrollmentSites;
                component.set('v.enrollmentSites', enrollmentSites);
                component.set('v.account', enrollmentSiteInfo.Account);
            }
        });
        $A.enqueueAction(action);
    },

    openEnrollmentSites : function(component) {
        component.set('v.currentStep', 'ChooseEnrollmentSites');
    },

    loadNewEnrollmentSiteModal : function(component) {
        var accountId = component.get('v.accountId');
        var newEnrollmentSiteRecord = { "sobjectType": 'Enrollment_Site__c', "Account__c": accountId };
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

    loadEditEnrollmentSiteDateModal : function(component, enrollmentSiteDate) {
        component.set('v.EditEnrollmentSiteDateRecord', enrollmentSiteDate);
        
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSiteToSchedule = enrollmentSites.find((enrollmentSite) => { return enrollmentSite.Id == enrollmentSiteDate.Enrollment_Site__c });
        component.set('v.selectedEnrollmentSiteToSchedule', selectedEnrollmentSiteToSchedule);
        
        var editEnrollmentSiteDateModal = component.find('editEnrollmentSiteDateModal');
        editEnrollmentSiteDateModal.showModalUsingRecord();
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

    loadNewLocationIntoExistingLocations : function(component, helper, newEnrollmentSiteRecord) {
        var enrollmentSites = component.get('v.enrollmentSites');
        enrollmentSites.push(newEnrollmentSiteRecord);
        
        enrollmentSites.sort(function (es1, es2) {
		    return ('' + es1.Name).localeCompare(es2.Name);
		});
		
		component.set('v.enrollmentSites', enrollmentSites);
    },

    loadEditedEnrollmentSiteDateIntoExistingOnes : function(component, updatedEnrollmentSiteDate) {
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSite = enrollmentSites.find((enrollmentSite) => { return enrollmentSite.Id == updatedEnrollmentSiteDate.Enrollment_Site__c });
        
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

    showDeleteEnrollmentSiteDateModal : function(component) {
        component.set('v.showDeleteEnrollmentSiteDateModal', true);
    },

    hideDeleteEnrollmentSiteDateModal : function(component) {
        component.set('v.showDeleteEnrollmentSiteDateModal', false);
    },

    loadNewEnrollmentSiteDateModal : function(component, enrollmentSiteId) {
        var enrollmentOpportunityId = component.get('v.opportunityId');
        var newEnrollmentSiteDateRecord = { "sobjectType": 'Enrollment_Site_Date__c', "Enrollment_Opportunity__c": enrollmentOpportunityId, "Enrollment_Site__c": enrollmentSiteId, "Show_In_Build_Time_To_Enroll_Email__c": true };
        component.set('v.NewEnrollmentSiteDateRecord', newEnrollmentSiteDateRecord);
        
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSiteToSchedule = enrollmentSites.find((enrollmentSite) => { return enrollmentSite.Id == enrollmentSiteId });
        component.set('v.selectedEnrollmentSiteToSchedule', selectedEnrollmentSiteToSchedule);
        
        var newEnrollmentSiteDateModal = component.find('newEnrollmentSiteDateModal');
        newEnrollmentSiteDateModal.showModalUsingRecord();
    },

    saveNewEnrollmentSiteDate : function(component) {
        helper = this;
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

    loadNewEnrollmentSiteDateIntoExistingOnesForEnrollmentSite : function(component, helper, newEnrollmentSiteDateRecord) {
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSite = enrollmentSites.find((enrollmentSite) => { return enrollmentSite.Id == newEnrollmentSiteDateRecord.Enrollment_Site__c });
        
        if (!selectedEnrollmentSite.Enrollment_Site_Dates__r) {
            selectedEnrollmentSite.Enrollment_Site_Dates__r = [];
        }
        
        selectedEnrollmentSite.Enrollment_Site_Dates__r.push(newEnrollmentSiteDateRecord);
        
        component.set('v.enrollmentSites', enrollmentSites);
    },

    loadEditEnrollmentSiteModal : function(component, enrollmentSiteId) {
        var enrollmentSites = component.get('v.enrollmentSites');
        var enrollmentSiteToEdit = enrollmentSites.find(es => { return es.Id == enrollmentSiteId });

        component.set('v.EditEnrollmentSiteRecord', enrollmentSiteToEdit);

        var editEnrollmentSiteModal = component.find('editEnrollmentSiteModal');
        editEnrollmentSiteModal.showModalUsingRecord();
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

    loadEditedSiteIntoExistingSites : function(component, helper, editEnrollmentSiteRecord) {
        var enrollmentSites = component.get('v.enrollmentSites');

        for (let es of enrollmentSites) {
            if (es.Id == editEnrollmentSiteRecord) {
                es = editEnrollmentSiteRecord;
                break;
            }
        }

        component.set('v.enrollmentSites', enrollmentSites);
    },

    removeDeletedEnrollmentSiteDateFromExistingOnes : function(component, deletedEnrollmentSiteDate) {
        var enrollmentSites = component.get('v.enrollmentSites');
        var selectedEnrollmentSite = enrollmentSites.find((enrollmentSite) => { return enrollmentSite.Id == deletedEnrollmentSiteDate.Enrollment_Site__c });
        
        for (var i = 0; i < selectedEnrollmentSite.Enrollment_Site_Dates__r.length; ++i) {
            let enrollmentSiteDate = selectedEnrollmentSite.Enrollment_Site_Dates__r[i];
            
            if (enrollmentSiteDate.Id == deletedEnrollmentSiteDate.Id) {
                selectedEnrollmentSite.Enrollment_Site_Dates__r.splice(i, 1);
                break;
            }
        }
        
        component.set('v.enrollmentSites', enrollmentSites);
    },
    
    findEnrollmentSiteDate : function(component, enrollmentSiteDateId) {
        var enrollmentSites = component.get('v.enrollmentSites');

        for (let es of enrollmentSites) {
            if (!es.Enrollment_Site_Dates__r) {
                continue;
            }

            for (let esd of es.Enrollment_Site_Dates__r) {
                if (esd.Id == enrollmentSiteDateId) {
                    return esd;
                }
            }
        }

        return null;
    },

    showSuccessToast : function(successMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": successMessage,
            "type": 'success'
        });
        toastEvent.fire();
    }
})