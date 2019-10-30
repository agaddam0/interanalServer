({
    loadRecords : function(component, event) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.retrieveProposal");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var record = result.getReturnValue();
                this.loadFieldSets(component, record);
                component.set("v.Proposal", record);
                this.validateForm(component);
                this.toggle(component, event);
            }
        });
        
        $A.enqueueAction(action);
    }, 
    
    loadFieldSets : function(component, record) {
        var fsf = component.find('ProposalInfoFieldSet');
        fsf.loadComponent(record);
        
        fsf = component.find('GroupProductOnlyBenefits');
        fsf.loadComponent(record);
        
        fsf = component.find('AdditionalNotes');
        fsf.loadComponent(record);
        
        fsf = component.find('GroupProductOnlySTD');
        fsf.loadComponent(record);
        
        fsf = component.find('GroupProductOnlyLTD');
        fsf.loadComponent(record);
	},
    
	validateForm : function(component) {
        
        var shortTerm = component.find('GroupProductOnlySTD');
        var longTerm = component.find('GroupProductOnlyLTD');
        var record = component.get("v.Proposal");
        var validForm = true;
        
        if(!record.Select_Group_Products__c)
        {
            validForm = false;
            $A.util.addClass(longTerm, "slds-hide");
            $A.util.addClass(shortTerm, "slds-hide");
        }
        else
        {
            if(record.Select_Group_Products__c.includes('Long-Term Disability'))
            {
                $A.util.removeClass(longTerm, "slds-hide");
                
                if(!record.LTD_Plan_Selection__c)
                {
                    validForm = false;
                }
            }
            else
                $A.util.addClass(longTerm, "slds-hide");
            
            if(record.Select_Group_Products__c.includes('Short-Term Disability'))
            {
                $A.util.removeClass(shortTerm, "slds-hide");
                
                if(!record.STD_Plan_Selection__c)
                {
                    validForm = false;
                }
            }
            else
                $A.util.addClass(shortTerm, "slds-hide");
        }
        
        if(!record.Group_Display_Name__c)
            validForm = false;
        
        if(!record.Industry__c)
            validForm = false;
        
        if(!record.States__c)
            validForm = false;
        
        if(!record.Due_Date__c)
            validForm = false;
        
        component.set('v.validForm', validForm);
        return validForm;
    },
    
    deleteProposal : function(component, event) {
        var deleteAction = component.get("c.deleteProposal");
        deleteAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        deleteAction.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS"){
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(deleteAction);
    },
    
    submitProposal : function(component, event){
        this.toggle(component, event);
        var proposal = component.get("v.Proposal"),
            isValid = this.validateForm(component, proposal);
        
        if(isValid)
        {
            proposal.sobjectType = 'Proposal__c';
            proposal.Status__c = 'Request Submitted';
            
            var saveAction = component.get("c.updateProposal");
            saveAction.setParams({
                "proposal" : proposal
            });
            saveAction.setCallback(this, function(result){
                var state = result.getState();
                if(component.isValid() && state === "SUCCESS") {
                    this.showSuccessToast('The proposal was successfully submitted.');
                    $A.get("e.force:closeQuickAction").fire();
                    this.toggle(component, event);
                }
            });
            
            $A.enqueueAction(saveAction);
        }
        else {
            this.showErrorToast(component, 'Please complete the required fields');
            this.toggle(component, event);
        }
    },
    
    showSuccessToast : function(successMessage) {
	    var toastEvent = $A.get("e.force:showToast");
	    toastEvent.setParams({
	        "message": successMessage,
	        "type": 'success'
	    });
	    toastEvent.fire();
	},
    
    toggle: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    showErrorToast : function(component, errorMessage) {
        var container = component.find("errorContainer");
        $A.createComponent("c:ErrorToast",
                           {"ErrorMessage" : errorMessage,
                            "CloseAfter" : 4000},
                           function(cmp){
                               container.set("v.body", [cmp]);
                           });
    }
})