({
	getObjects : function(component, event) {
        var getObjectsAction = component.get('c.getSetupFormData');
        
        getObjectsAction.setParams({
            "opportunityId" : component.get("v.recordId")
        });
        
        getObjectsAction.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                var context = result.getReturnValue();
                component.set('v.Opportunity', context.EnrollmentOpportunity);
                component.set('v.PlatformSetup', context.PlatformSetupForm);
                component.set('v.EnrollmentForm', context.EnrollmentForm);
                component.set("v.Account", context.CustomerAccount);
                
                if(context.PlatformSetupForm.Status__c != 'In Progress')
                    component.set("v.formIsSubmitted", true);
                
                this.setStatusOnNavigation(component, context.PlatformSetupForm);
                this.createReviewComponent(component);
                var navBar = component.find("navBar");
                navBar.setEnrollmentFormId(context.EnrollmentForm.Id);
            }
        });
        
        $A.enqueueAction(getObjectsAction);
    },
    
    showPages : function(component, event, pageName) {        
        if(pageName == 'CurrentSetupReview'){
            component.set('v.showQuickSetup', false);
            window.scrollTo(0, 0);
            component.set('v.showCurrentSetupReview', true);
        }
        
        if(pageName == 'ReserviceChanges'){
            var isChangesCreated = component.get('v.changesCreated');
            if(!isChangesCreated) {
                this.createChangesComponent(component);
                component.set('v.changesCreated', true);
            }
            component.set('v.showReserviceChanges', true);
        }
        
        if(pageName == 'QuickSetup'){
            component.set('v.showCurrentSetupReview', false);
            window.scrollTo(0, 0);
            var isQuickSetupCreated = component.get('v.quickSetupCreated');
            if(!isQuickSetupCreated) {
                this.createQuickSetupComponent(component);
                this.enableSubmitButton(component, event);
                component.set('v.quickSetupCreated', true);
            }
            
            component.set('v.showQuickSetup', true);
        } 
    },
    
    createReviewComponent : function(component){
        var container = component.find("currentSetupReviewContainer");
        $A.createComponent("c:ReserviceCurrentSetupReview",
                           {"Account" : component.get("v.Account"),
                            "Opportunity" : component.get("v.Opportunity"),
                            "EnrollmentForm" : component.get("v.EnrollmentForm")},
                           function(cmp){
                               container.set('v.body', [cmp]);
                           });
        
    },
    
    createChangesComponent : function(component){
        var container = component.find("reserviceChangesContainer");
        $A.createComponent("c:ReserviceChanges",
                           {"Account" : component.get("v.Account"),
                            "Opportunity" : component.get("v.Opportunity"),
                            "aura:id" : 'makingChangesForm',
                            "disableInputFields" : component.get("v.formIsSubmitted")},
                           function(cmp){
                               container.set('v.body', [cmp]);
                           });
        
    },
    
    createQuickSetupComponent : function(component){
        var container = component.find("quickSetupContainer");
        $A.createComponent("c:ReserviceQuickSetup",
                           {"aura:id" : "quickSetupComponent",
                            "opportunity" : component.get("v.Opportunity"),
                            "EnrollmentForm" : component.get("v.EnrollmentForm"),
                            "PlatformSetup" : component.get("v.PlatformSetup"),
                            "Account" : component.get("v.Account"),
                            "disableInputFields" : component.get("v.formIsSubmitted")},
                           function(cmp){
                               container.set('v.body', [cmp]);
                           });
        
    },
    
    enableSubmitButton : function(component, event){
        var navBar = component.find("navBar");
        navBar.displaySubmitButton();
    },
    
    validate : function(component){
        var quickSetup = component.find("quickSetupComponent");
        var isValid = quickSetup.validateChildComponents();
        var navbar = component.find("navBar");
        navbar.canSubmit(isValid);
    },
    
    disableForms : function(component, event){
        var disabled = event.getParam('setDisabled');
        
        component.set("v.formIsSubmitted", disabled);
        
        var quickSetup = component.find("quickSetupComponent");
        if(quickSetup)
            quickSetup.disableForms(disabled);
        
        var makingChangesForm = component.find("makingChangesForm");
        if(makingChangesForm)
            makingChangesForm.disableForm(disabled);
    },
    
    updateMarketedProduct : function(component, event, value)
    {
        var updateMarketedProduct = component.get('c.AddRemoveDVRProduct');
        
        updateMarketedProduct.setParams({
            "addDVR" : value,
            "enrollmentFormId" : component.get("v.EnrollmentForm.Id")
        });
        
        updateMarketedProduct.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                console.log('Save Success');
            }
        });
        
        $A.enqueueAction(updateMarketedProduct);
    },
    
    setStatusOnNavigation : function(component, platformSetupForm){
        var navBar = component.find("navBar");
        navBar.setStatus(platformSetupForm.Status__c, platformSetupForm.Request_Edit__c);
    }
})