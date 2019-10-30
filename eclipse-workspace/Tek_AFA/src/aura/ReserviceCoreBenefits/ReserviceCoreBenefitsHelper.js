({
    coreFoldersGridRowActions : [
        {Label: "Edit", ActionName: "Edit", Type: "Link"},
        {Label: " | ", ActionName: "Do Nothing", Type: "Link", Class: "af-core-folder-divider"},
        {Label: "Del", ActionName: "Delete", Type: "Link"}
    ],
    
    showCoreBenefits : function(component, event, value){
        if(value == 'Core Folders')
            component.set("v.showCoreFoldersRecords", true);
        else
            component.set("v.showCoreFoldersRecords", false);
    },

    showRatedDependency : function(component, event, value){
        if(value == 'Rated Folder'){
            component.set("v.showDependencyField", true);
        } else {
            component.set("v.showDependencyField", false);
        }        
    },

    updateFolder : function(component, event){
        var isValid = this.validateModalFieldSets(component);
        var coreFolder = component.get("v.activeRecord");
        var platform = component.get('v.PlatformSetup');

        if(!isValid){
            return;
        }
            

        component.set("v.showNewCoreBenefitModal", false);
        
        coreFolder.Platform_Setup_Form__c = platform.Id;
        var insertCoreFolder = component.get("c.upsertCoreBenefitForm");
        insertCoreFolder.setParams({
            'benefitForm' : coreFolder
        });

        insertCoreFolder.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.activeRecord", component.get("v.newCoreFolder"));
                var coreFoldersGrid = component.find('coreBenefitsGrid');
                coreFoldersGrid.reloadRecords();
            }
            else {
                this.showErrorToast(component, event, 'An unexpected error occurred. Contact your System Administrator');
            }
        });
        
        $A.enqueueAction(insertCoreFolder); 
    },

    deleteFolder : function(component, event){
        var coreFolder = component.get("v.activeRecord");

        var deleteCoreFolder = component.get("c.deleteCoreBenefitForm");
        deleteCoreFolder.setParams({
            'benefitFormId' : coreFolder.Id
        });

        deleteCoreFolder.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.activeRecord", component.get("v.newCoreFolder"));
                var coreFoldersGrid = component.find('coreBenefitsGrid');
                coreFoldersGrid.reloadRecords();
            }
            else {
                this.showErrorToast(component, event, 'An unexpected error occurred. Contact your System Administrator');
            }
        });
        
        $A.enqueueAction(deleteCoreFolder); 
    },

    openEditModal : function(component){
        var mainForm = component.find('newCoreFolderForm');
        var dependencyForm = component.find('newCoreFolderDependencyFields');

        mainForm.clearValidationMessages();
        dependencyForm.clearValidationMessages();
        
        component.set("v.showNewCoreBenefitModal", true);
    },

    validate : function(component, event){
        var formsToValidate = ['coreBenefitFields'];
        var allFormsValid = true;
        
        for(let formName of formsToValidate){
            let form = component.find(formName);
            allFormsValid = allFormsValid && form.validate();
        }
        
        return allFormsValid;
    },
    
    disableForms : function(component, event){
        var eventArgs = event.getParam('arguments');
        var disabled = eventArgs.disabled;
        
        component.set("v.disableInputFields", disabled);
        
        var formsToDisable = ['coreBenefitFields'];
        
        for(let formName of formsToDisable){
            let form = component.find(formName);
            form.disableForm(disabled);
        }
    },

    validateModalFieldSets : function(component){
        var mainForm = component.find('newCoreFolderForm');
        var dependencyForm = component.find('newCoreFolderDependencyFields');
        var dependencyVisible = component.get('v.showDependencyField');
        var isValid = false;
        
        mainForm.clearValidationMessages();
        isValid = mainForm.validate();
        mainForm.showValidationMessages();

        if(dependencyVisible){
            dependencyForm.clearValidationMessages();
            isValid = isValid && dependencyForm.validate();
            dependencyForm.showValidationMessages();
        }

        return isValid;
    },

    showErrorToast : function(component, event, message){
        component.find('notifLib').showNotice({
            "variant" : "error",
            "title" : "Something went wrong!",
            "message" : message,
            "mode" : "pester"
        });
    },
})