({
    doInit : function(component, event, helper) {
        helper.loadDefaultValues(component);
        helper.loadFromExistingOrder(component);
        helper.loadFromEnrollmentOpportunityId(component);
        helper.updateStepsAndStepButtons(component);
    },

    onNextButtonClick : function(component, event, helper) {
        var currentStep = component.get('v.currentStep');
    
        var currentStepConfig = helper.stepsConfig[currentStep];
        
        var isValid = true;
        
        if (currentStepConfig.validateBeforeNextStep) {
            isValid = currentStepConfig.validateBeforeNextStep(component, helper);
        }
        
        if (!isValid) {
            return;
        }

        if (currentStepConfig.afterValidation) {
            currentStepConfig.afterValidation(component, event, helper, helper.openNextStep);
        }
        else {
            helper.openNextStep(component, event, helper);
        }

        helper.scrollToTop();
    },
    
    onPreviousButtonClick : function(component, event, helper) {
        var previousButton = event.getSource();
        var previousStep = previousButton.get('v.value');
        
        component.set('v.currentStep', previousStep);

        helper.scrollToTop();
    },
    
    handleEnrollmentOpportunityChanged : function(component, event, helper) {
        if (event && event.getParam("value")) {
            helper.loadEnrollmentInfo(component, event.getParam("value"));
        }
    },
    
    onNewLocationClick : function(component, event, helper) {
        helper.loadNewEnrollmentSiteModal(component);
    },
    
    saveNewEnrollmentSiteClick : function(component, event, helper) {
        helper.saveNewEnrollmentSite(component);
    },

    onEditEnrollmentSiteClick : function(component, event, helper) {
        var enrollmentSiteId = event.getSource().get('v.value');

        helper.loadEditEnrollmentSiteModal(component, enrollmentSiteId);
    },

    saveEditEnrollmentSiteClick : function(component, event, helper) {
        helper.saveEditedEnrollmentSite(component);
    },
    
    onScheduleEnrollmentSiteDateClick : function(component, event, helper) {
        var enrollmentSiteId = event.getSource().get('v.value');

        helper.loadNewEnrollmentSiteDateModal(component, enrollmentSiteId);
    },
    
    saveNewEnrollmentSiteDateClick : function(component, event, helper) {
        helper.saveNewEnrollmentSiteDate(component);
    },
    
    onEditEnrollmentSiteDateClick : function(component, event, helper) {
        var editLink = event.currentTarget;
        var enrollmentSiteDateId = editLink.getAttribute('data-enrollmentSiteDateId');
        var enrollmentSiteDate = helper.findEnrollmentSiteDate(component, enrollmentSiteDateId);
        
        helper.loadEditEnrollmentSiteDateModal(component, enrollmentSiteDate);
    },
    
    saveEditEnrollmentSiteDateClick : function(component, event, helper) {
        helper.saveEditedEnrollmentSiteDate(component);
    },
    
    onDeleteEnrollmentSiteDateClick : function(component, event, helper) {
        var deleteLink = event.currentTarget;
        var enrollmentSiteDateId = deleteLink.getAttribute('data-enrollmentSiteDateId');
        var enrollmentSiteDate = helper.findEnrollmentSiteDate(component, enrollmentSiteDateId);
        
        helper.showDeleteEnrollmentSiteDateModal(component);
        component.set('v.enrollmentSiteDateToDelete', enrollmentSiteDate);
    },
    
    closeDeleteEnrollmentSiteDateModal : function(component, event, helper) {
        helper.hideDeleteEnrollmentSiteDateModal(component);
    },
    
    onDeleteEnrollmentSiteDate : function(component, event, helper) {
        var enrollmentSiteDateToDelete = component.get('v.enrollmentSiteDateToDelete');
        helper.deleteEnrollmentSiteDate(component, enrollmentSiteDateToDelete);
    },
    
    onSelectedMaterialChange : function(component, event, helper) {
        var materialCheckbox = event.getSource();
        
        helper.updateSelectedMaterialAttributesOnChange(component, materialCheckbox);
        helper.updateStepsAndStepButtons(component);
    },

    requestedStepChange : function(component, event, helper) {
        helper.setCurrentStepFromRequestedStep(component);
    }
})