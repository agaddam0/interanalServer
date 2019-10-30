({
    doInit : function(component, event, helper){
        var platform = component.get("v.PlatformSetup");
        component.set("v.coreBenefitsWhereClause", "where Platform_Setup_Form__c ='" + platform.Id + "'");
        component.set("v.activeRecord", component.get("v.newCoreFolder"));
        component.set("v.coreFoldersGridRowActions", helper.coreFoldersGridRowActions);
        var coreFoldersGrid = component.find('coreBenefitsGrid');
        coreFoldersGrid.reloadRecords();
        helper.showCoreBenefits(component, event, platform.What_Core_Benefits_will_show_in_the_case__c);
    },

    checkToShowCoreBenefits : function(component, event, helper) {
        var value = event.getParam("values");
        var field = event.getParam("fieldName");
        var item = event.getSource();
        item.set("v.value", value);
        
        if(field == 'What_Core_Benefits_will_show_in_the_case__c'){
            helper.showCoreBenefits(component, event, value);         
        }

        if(field == 'Rate_Folder__c'){
            helper.showRatedDependency(component, event, value);
        }
    },

    handleGridRowAction : function(component, event, helper){
        var eventSourceGrid = event.getSource();
        var gridId = eventSourceGrid.getLocalId();
        var actionName = event.getParam("actionName");
        var record = event.getParam("record");
        
        if (gridId == "coreBenefitsGrid") {
            component.set("v.activeRecord", record);
            if (actionName == "Edit") {
                helper.openEditModal(component);
            }
            else if (actionName == "Delete"){
                helper.deleteFolder(component, event);
            }
            
        }
    },

    addNewCoreFolder : function(component, event, helper){
        component.set("v.activeRecord", component.get("v.newCoreFolder"));
        helper.updateFolder(component, event);
    },

    openModal : function(component, event, helper){
        helper.openEditModal(component);
    },

    closeNewCoreBenefitModal : function(component, event, helper){
        component.set("v.showNewCoreBenefitModal", false);
    },

    validateForm : function(component, event, helper){
        return helper.validate(component);
    },
    
    disableForm : function(component, event, helper){
        helper.disableForms(component, event);
    }
})