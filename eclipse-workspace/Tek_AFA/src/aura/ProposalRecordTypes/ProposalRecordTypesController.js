({
	doInit : function(component, event, helper) {
        helper.toggle(component,event);
		var action = component.get("c.getRecordTypeObjectsForObject");
        var recordId = component.get("v.recordId");
        if(recordId && recordId.substring(0,3) == "006")
        {
            component.set("v.opportunityId", recordId);
        }
        
        action.setParams({
            'sObjectName' : 'Proposal__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") 
            {
                console.log(response.getReturnValue());
            	component.set("v.RecordTypes", response.getReturnValue());
                helper.toggle(component, event);
            }            
        });
        $A.enqueueAction(action);
	},
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleNext : function(component, event, helper) {
        helper.RedirectToNextComponent(component);
    },
    
    radioSelect : function(component, event, helper) {
        
        var selectedName = event.getSource().get("v.text");
        var recordTypes = component.get("v.RecordTypes");
        var recordType;
        var RFPdiv = document.getElementById('RFP');
        var Customdiv = document.getElementById('Custom_Proposal');
        
        for(var i = 0; i < recordTypes.length; i++)
        {
            if(recordTypes[i].Name == selectedName)
            {
                recordType = recordTypes[i];
                break;
            }
        }
        
        if(recordType.Name == 'RFP')
        {
            $A.util.removeClass(RFPdiv, 'slds-hide');
            $A.util.addClass(Customdiv, 'slds-hide');
        }
        else if(recordType.Name == 'Custom Proposal')
        {
            $A.util.addClass(RFPdiv, 'slds-hide');
            $A.util.removeClass(Customdiv, 'slds-hide');
        }
        else
        {
            $A.util.addClass(RFPdiv, 'slds-hide');
            $A.util.addClass(Customdiv, 'slds-hide');
        }
        
        component.set("v.SelectedType", recordType);
    }
})