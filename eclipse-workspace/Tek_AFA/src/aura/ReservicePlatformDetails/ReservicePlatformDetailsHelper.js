({
    getEnrollmentPaths : function(component) {
    	var getObjectsAction = component.get('c.getEnrollmentPaths');
        var opportunity = component.get("v.Opportunity");
        
        getObjectsAction.setParams({
            "division" : opportunity.Division__c,
            "pathValue" : opportunity.Enrollment_Path__c
        });
        
        getObjectsAction.setCallback(this, function(result){
            var state = result.getState();
            
            if(component.isValid() && state === "SUCCESS") {
                var enrollmentPaths = result.getReturnValue();
                component.set('v.enrollmentPaths', enrollmentPaths);
                
                for(let path of enrollmentPaths){
                    if(path.Selected){
                        var platformSetup = component.get('v.PlatformSetup');
                        var opportunity = component.get('v.Opportunity');
                        var pathContainer = component.find("EnrollmentPathFields");
                        this.createFieldSetForm(component, path.EnrollmentPath.Platform_Setup_Field_Set__c, platformSetup, pathContainer, 'Platform_Setup__c', 'PathFieldsForm');
                        this.loadDefaults(component, opportunity, platformSetup, path);
                        break;
                    }
                }
                
            }
        });
        
        $A.enqueueAction(getObjectsAction);
    },
    
    createFieldSetForm : function(component, fieldSetName, record, container, objectName, componentId) {
        $A.createComponent("c:FieldSetForm",
                           {"record" : record,
                            "fieldSetName" : fieldSetName,
                            "objectName" : objectName,
                            "aura:id": componentId,
                            "disableInputFields" : component.get("v.disableInputFields")},
                           function(cmp){
                           container.set("v.body", [cmp]);
                           });
    },
    
    loadDefaults : function(component, opportunity, platformSetup, path) {
        var RushReason = this.showRushReason(opportunity, path.EnrollmentPath);
        if(RushReason) {
            var container = component.find('RushRequested');
            this.createFieldSetForm(component, 'Quick_Setup_Rush_Reques', opportunity, container, 'Opportunity', 'RushForm');
        }
        
        var EmployeeThreshold = this.showEmployeeThreshold(opportunity, platformSetup, path.EnrollmentPath);
        if(EmployeeThreshold) {
            component.set("v.ThresholdMessage", path.Below_Minimum_Employee_Message__c);
            var container = component.find('BelowThreshold');
            this.createFieldSetForm(component, 'Quick_Setup_Below_Threshold', platformSetup, container, 'Platform_Setup__c', 'BelowThresholdForm');
            component.set("v.showUnderEmployeeThreshold", true);
        }
            
    },
    
    showRushReason : function(opportunity, path){
        if(opportunity.Enrollment_Start_Date__c == null || path.Lead_Time__c == null )
            return false;
        
        var leadDate = new Date(opportunity.Enrollment_Start_Date__c);
        leadDate.setDate(leadDate.getDate() + path.Lead_Time__c);
        
        var today = new Date();
        today.setHours(0,0,0,0);

        var isRushed = today >= leadDate;

        return isRushed;
    },
    
    showEmployeeThreshold : function(opportuntiy, platformSetup, path){
    	if(path.Employee_Minimum__c == null || !path.Below_Employee_Minimum_Reason_Required__c ||
          opportuntiy.Estimated_Employees__c == null)
            return false;
        
        if(path.Below_Employee_Minimum_Reason_Required__c &&
          opportunity.Estimated_Employees__c < path.Employee_Minimum__c)
            return true;
        else
            return false;
    },
    
    validate : function(component){
        var opportunity = component.get("v.Opportunity");
        var enrollmentPaths = component.get("v.enrollmentPaths");
        var platformSetup = component.get("v.PlatformSetup");
        
        var pathSelected = false;
        var rushFormValid = true;
        var thresholdValid = true;
        var pathFieldsValid = true;
        
        for(let path of enrollmentPaths){
            if(path.Selected){
                pathSelected = true;
                
                var pathFields = component.find("PathFieldsForm");
                if(pathFields){
                    pathFields.clearValidationMessages();
                    pathFieldsValid = pathFields.validate();
                    pathFields.showValidationMessages();
                }                    
                
                if(this.showRushReason(opportunity, path)){
                    var rushForm = component.find("RushForm");
                    if(rushForm){
                        rushForm.clearValidationMessages();
                        rushFormValid = rushForm.validate();
                        rushForm.showValidationMessages();
                    }                        
                }
                
                if(this.showEmployeeThreshold(opportunity, platformSetup, path)){
                    var thresholdForm = component.find("BelowThresholdForm");
                    if(thresholdForm){
                        thresholdForm.clearValidationMessages();
                        thresholdValid = thresholdForm.validate();
                        thresholdForm.showValidationMessages();
                    }
                }
            }
        }
        
        if(pathSelected && pathFieldsValid && rushFormValid && thresholdValid)
            return true;
        else
            return false;
    },
    
    disableForm : function(component, event){
        var eventArgs = event.getParam('arguments');
        var disabled = eventArgs.disabled;
        
        component.set("v.disableInputFields", disabled);
        
        var pathFields = component.find("PathFieldsForm");
        if(pathFields){
            pathFields.disableForm(disabled);
        } 
        
        var rushForm = component.find("RushForm");
        if(rushForm){
            rushForm.disableForm(disabled);
        }
        
        var thresholdForm = component.find("BelowThresholdForm");
        if(thresholdForm){
            thresholdForm.disableForm(disabled);
        }
    }
})