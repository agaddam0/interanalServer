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
            }
        });
        
        $A.enqueueAction(action);
    },
    
    loadUser : function(component) {
        var getUser = component.get("c.retrieveUser");
        
        getUser.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.LoggedInUser", result.getReturnValue());
                this.validateForm(component);
            }
        });
        $A.enqueueAction(getUser);
    },        
        
    saveUser : function(component){
        var user = component.get("v.LoggedInUser");
        var action = component.get("c.updateUser");
        action.setParams({
            "usr" : user
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.LoggedInUser", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
	loadFieldSets : function(component, record) {
        var fsf = component.find('ProposalInfoFieldSet');
        fsf.loadComponent(record);
        
        fsf = component.find('RepInfoRight');
        fsf.loadComponent(record);
        
        fsf = component.find('RepInfoLeft');
        fsf.loadComponent(record);
        
        fsf = component.find('DeliveryFieldSet');
        fsf.loadComponent(record);
        
        fsf = component.find('AdditionalNotes');
        fsf.loadComponent(record);
        
        fsf = component.find('RepInfoBranchOffice');
        fsf.loadComponent(record);
        
        fsf = component.find('DeliveryShipTo');
        fsf.loadComponent(record);
        
        fsf = component.find('GenericDeliveryShipping');
        fsf.loadComponent(record);
        
        this.toggle(component, event);
	},
    
    validateForm : function(component, record) {
        var branchOfficeFS = component.find('RepInfoBranchOffice');
        var DeliveryShipTo = component.find('DeliveryShipTo');
        var DeliveryShipping = component.find('GenericDeliveryShipping');
        var ShipToMe = component.find('ShipToMe');
        var updateUserFields = component.get('v.updateUserFields');
        var User = component.get('v.LoggedInUser');
        var record = component.get("v.Proposal");
        var validForm = true;
        
        // Proposal Information        
        if(!record.Group_Display_Name__c)
            validForm = false;
        
        if(!record.Industry__c)
            validForm = false;
        
        if(!record.States__c)
            validForm = false;
        
        if(!record.Due_Date__c)
            validForm = false;
        
        // Rep Information
        if(!record.Main_Rep__c)
            validForm = false;
        
        if(!record.Division__c)
        {
            validForm = false;
            $A.util.addClass(branchOfficeFS, "slds-hide");
        }
        
        if(record.Division__c == 'AFES')
            $A.util.removeClass(branchOfficeFS, "slds-hide");
        else
            $A.util.addClass(branchOfficeFS, "slds-hide");
        
        // Delivery
        if(!record.How_will_the_Proposal_be_fulfilled__c)
        {
            validForm = false;
            $A.util.addClass(DeliveryShipping, "slds-hide");
            $A.util.addClass(DeliveryShipTo, "slds-hide");
            $A.util.addClass(ShipToMe, "slds-hide");
            updateUserFields = false;
        }
        else if(record.How_will_the_Proposal_be_fulfilled__c == 'Print')
        {
            $A.util.removeClass(DeliveryShipTo, "slds-hide");
            
            if(!record.Ship_To__c)
            {
                validForm = false;
                $A.util.addClass(DeliveryShipping, "slds-hide");
                $A.util.addClass(ShipToMe, "slds-hide");
            }
            else if(record.Ship_To__c == 'Ship to Me')
            {
                $A.util.removeClass(ShipToMe, "slds-hide");
                $A.util.addClass(DeliveryShipping, "slds-hide");
                updateUserFields = true;
                
                if(!User || !User.Street || !User.City || !User.State || !User.PostalCode)
                    validForm = false;
            }
                else {
                    $A.util.removeClass(DeliveryShipping, "slds-hide");
                    $A.util.addClass(ShipToMe, "slds-hide");
                    
                    if(!record.Shipping_Address__c)
                        validForm = false;
                }
        }
            else {
                $A.util.addClass(DeliveryShipTo, "slds-hide");
                $A.util.addClass(DeliveryShipping, "slds-hide");
                $A.util.addClass(ShipToMe, "slds-hide");
                updateUserFields = false;
            }
        
        component.set('v.updateUserFields', updateUserFields);
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
            updateUserFields = component.get('v.updateUserFields'),
            isValid = this.validateForm(component, proposal);
        
        if(isValid)
        {
            if(updateUserFields)
                this.saveUser(component);
            
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