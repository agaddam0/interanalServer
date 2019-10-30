({
	init : function(component, event, helper) {
		helper.getEnrollmentPaths(component, event);
	},
    
    openDetailsModal : function(component, event, helper) {
        var rowId = event.currentTarget.getAttribute('data-recId');
        var enrollmentPaths = component.get('v.enrollmentPaths');
        
        for(let path of enrollmentPaths){
            if(path.EnrollmentPath.Id == rowId){
                component.set('v.modalEnrollmentPath', path.EnrollmentPath);
                break;
            }
        }
        
        component.set('v.showDetailsModal', true);
    },
    
    closeModal : function(component, event, helper) {
        component.set('v.showDetailsModal', false);
    },
    
    SaveSelection : function(component, event, helper) {
        var opportunity = component.get('v.Opportunity');
        var selectedPathUpdate = event.target.getAttribute('data-recId');
        var enrollmentPaths = component.get('v.enrollmentPaths');
        var platformSetup = component.get('v.PlatformSetup');
        var container = component.find('EnrollmentPathFields');
        var selectedPath;
        
        for(let path of enrollmentPaths) {
            if(path.EnrollmentPath.Id == selectedPathUpdate){
                path.Selected = true;
                selectedPath = path;
            } 
            else
                path.Selected = false;
        }
        
        component.set('v.enrollmentPaths', enrollmentPaths);
        opportunity.Enrollment_Path__c = selectedPathUpdate;
        helper.save(component, event, opportunity);
        helper.createFieldSetForm(component, selectedPath.EnrollmentPath.Platform_Setup_Field_Set__c, platformSetup, container, 'Platform_Setup__c', 'PathFieldsForm');
    },
    
    validateForm : function(component, event, helper){
        return helper.validate(component);
    },
    
    disableForm : function(component, event, helper){
        helper.disableForm(component, event);
    }
})