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
                record.Group_Display_Name__c = record.Opportunity__r.Account.Name;
                this.loadAccount(component, record.Opportunity__r.AccountId);
                this.loadProducts(component, record.Opportunity__c);
                this.createProductList(component, record.Opportunity__c);
                this.createUploadComponent(component, record.Opportunity__c);
                component.set("v.Proposal", record);
                this.validateForm(component);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    createProductList : function(component, recordId) {
        var container = component.find("ProductsContainer");
        $A.createComponent("c:OpportunityProducts",
                           {"recordId" : recordId},
                           function(cmp){
                           container.set("v.body", [cmp]);
                           });
    },
    
    createUploadComponent : function(component, recordId) {
        var container = component.find("UploadContainer");
        var recordIds = [recordId];
        $A.createComponent("c:UploadFiles",
                           {"relatedTo" : component.get("v.recordId"),
                            "additionalRelatedRecords" : recordIds},
                           function(cmp){
                           container.set("v.body", [cmp]);
                           });
    },
    
    loadAccount : function(component, accountId) {
        var getAccount = component.get("c.retrieveAccount");
        getAccount.setParams({
            "accountId" : accountId
        });
        getAccount.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.Account", result.getReturnValue());
                this.validateForm(component);
            }
        });
        
        $A.enqueueAction(getAccount);
    },
    
    saveAccount : function(component){
        var account = component.get("v.Account");
        var action = component.get("c.updateAccount");
        action.setParams({
            "acct" : account
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.Account", result.getReturnValue());
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

    loadProducts : function(component, opportunityId) {
        var getOppProducts = component.get("c.retrieveOpportunityProducts");
        getOppProducts.setParams({
            "opportunityId" : opportunityId
        });
        getOppProducts.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.OpportunityProducts", result.getReturnValue());
                this.validateForm(component);
            }
        });
        
        $A.enqueueAction(getOppProducts);    
    },
    
	loadFieldSets : function(component, record) {
        var fsf = component.find('ProposalInfoFieldSet');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomBenefits');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomRepInfo1');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomBrokerInvolved');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomDelivery1');
        fsf.loadComponent(record);
        
        fsf = component.find('AdditionalNotes');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomLTDDetails');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomLTDPlan');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomSTDPlan');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomSTDDetails');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomBranchOffice');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomBrokerName');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomDeliveryPrint');
        fsf.loadComponent(record);
        
        fsf = component.find('CustomDeliveryShipping');
        fsf.loadComponent(record);
        
        this.toggle(component, event);
	},
    
    validateForm : function(component, record) {
        var LTDPlan = component.find('CustomLTDPlan'),
            LTDDetails = component.find('CustomLTDDetails'),
            STDPlan = component.find('CustomSTDPlan'),
            STDDetails = component.find('CustomSTDDetails'),
            BranchOffice = component.find('CustomBranchOffice'),
            BrokerName = component.find('CustomBrokerName'),
            DeliveryPrint = component.find('CustomDeliveryPrint'),
            DeliveryShipping = component.find('CustomDeliveryShipping'),
        	ShipToMe = component.find('ShipToMe'),
            ShipToGroup = component.find('ShipToGroup'),
            OppProducts = component.get('v.OpportunityProducts'),
            updateAccountFields = component.get('v.updateAccountFields'),
            updateUserFields = component.get('v.updateUserFields'),
            User = component.get('v.LoggedInUser'),
            Account = component.get('v.Account');
        
        
        var record = component.get("v.Proposal");
        var validForm = true;
        
        // Proposal Information
        if(!record.Group_Display_Name__c)
            validForm = false;
        
        if(!record.Effective_Date__c)
            validForm = false;
        
        if(!record.Due_Date__c)
            validForm = false;
        
        //Benefits and Services
        if(this.containsProduct(OppProducts, 'Long-Term Disability')) {
            $A.util.removeClass(LTDPlan, "slds-hide");
            if(!record.LTD_Plan_Selection__c){
                validForm = false;
                $A.util.addClass(LTDDetails, "slds-hide");
            }
            if(record.LTD_Plan_Selection__c == 'Custom Plan')
            {
                $A.util.removeClass(LTDDetails, "slds-hide");
                if(!record.Detail_Custom_LTD_Request__c)
                    validForm = false;
            }
            else
                $A.util.addClass(LTDDetails, 'slds-hide');
        }
        else
        {
            $A.util.addClass(LTDPlan, "slds-hide");
            $A.util.addClass(LTDDetails, 'slds-hide');
        }
        
        if(this.containsProduct(OppProducts, 'Short-Term Disability')) {
        $A.util.removeClass(STDPlan, "slds-hide");
            if(!record.STD_Plan_Selection__c){
                validForm = false;
                $A.util.addClass(STDDetails, "slds-hide");
            }
            if(record.STD_Plan_Selection__c == 'Custom Plan')
            {
                $A.util.removeClass(STDDetails, "slds-hide");
                if(record.Detail_Custom_STD_Request__c == null || record.Detail_Custom_STD_Request__c == '')
                    validForm = false;
            }
            else
                $A.util.addClass(STDDetails, 'slds-hide');
        }
        else
        {
            $A.util.addClass(STDPlan, "slds-hide");
            $A.util.addClass(STDDetails, 'slds-hide');
        }
        
        // Rep Information
        if(!record.Main_Rep__c)
            validForm = false;
        
        if(record.Division__c == 'AFES')
            $A.util.removeClass(BranchOffice, "slds-hide");
        else
            $A.util.addClass(BranchOffice, "slds-hide");
        
        if(record.Broker_Involved__c)
            $A.util.removeClass(BrokerName, "slds-hide");
        else
            $A.util.addClass(BrokerName, "slds-hide");
        
        // Delivery
        if(!record.How_will_the_Proposal_be_fulfilled__c)
        {
            validForm = false;
            $A.util.addClass(DeliveryShipping, "slds-hide");
            $A.util.addClass(DeliveryPrint, "slds-hide");
            $A.util.addClass(ShipToMe, "slds-hide");
            $A.util.addClass(ShipToGroup, "slds-hide");
            updateUserFields = false;
            updateAccountFields = false;
        }
        else if(record.How_will_the_Proposal_be_fulfilled__c == 'Print')
        {
            $A.util.removeClass(DeliveryPrint, "slds-hide");
            
            if(!record.Ship_To__c)
            {
                validForm = false;
                $A.util.addClass(DeliveryShipping, "slds-hide");
            }
            else if(record.Ship_To__c == 'Ship to Other')
            {
                $A.util.removeClass(DeliveryShipping, "slds-hide");
                $A.util.addClass(ShipToMe, "slds-hide");
                $A.util.addClass(ShipToGroup, "slds-hide");
                
                if(!record.Shipping_Address__c)
                    validForm = false;
            }
            else if(record.Ship_To__c == 'Ship to Me')
            {
                $A.util.removeClass(ShipToMe, "slds-hide");
                $A.util.addClass(ShipToGroup, "slds-hide");
                $A.util.addClass(DeliveryShipping, "slds-hide");
                updateUserFields = true;
                
                if(!User || !User.Street || !User.City || !User.State || !User.PostalCode)
                    validForm = false;
            }
            else if(record.Ship_To__c == 'Ship to Group')
            {
                $A.util.removeClass(ShipToGroup, "slds-hide");
                $A.util.addClass(ShipToMe, "slds-hide");
                $A.util.addClass(DeliveryShipping, "slds-hide");
                updateAccountFields = true;
                
                if(!Account || !Account.ShippingStreet || !Account.ShippingCity || !Account.ShippingState || !Account.ShippingPostalCode)
                    validForm = false;
            }
                else
                {
                    $A.util.addClass(DeliveryShipping, "slds-hide");
                    $A.util.addClass(ShipToMe, "slds-hide");
                    $A.util.addClass(ShipToGroup, "slds-hide");
                    updateUserFields = false;
                    updateAccountFields = false;
                }
                    
        }
            else
            {
                $A.util.addClass(DeliveryShipping, "slds-hide");
                $A.util.addClass(DeliveryPrint, "slds-hide");
                $A.util.addClass(ShipToMe, "slds-hide");
                $A.util.addClass(ShipToGroup, "slds-hide");
                updateUserFields = false;
                updateAccountFields = false;
            }
       
        component.set('v.validForm', validForm);
        component.set('v.updateAccountFields', updateAccountFields);
        component.set('v.updateUserFields', updateUserFields);
        
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
            updateAccountFields = component.get('v.updateAccountFields'),
            updateUserFields = component.get('v.updateUserFields'),
            isValid = this.validateForm(component, proposal),
            OppProducts = component.get('v.OpportunityProducts'),
            account = component.get("v.Account");
        
        if(OppProducts.length < 1)
        {
            this.showErrorToast(component, 'Please add at least one Product to the Proposal.');
            this.toggle(component, event);
        }
        else if(isValid)
        {
            if(updateAccountFields)
                this.saveAccount(component);
            if(updateUserFields)
                this.saveUser(component);
            
            proposal.sobjectType = 'Proposal__c';
            proposal.Status__c = 'Request Submitted';
            proposal.Industry__c = account.Industry;
            
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
    
    showErrorToast : function(component, errorMessage) {
        var container = component.find("errorContainer");
        $A.createComponent("c:ErrorToast",
                           {"ErrorMessage" : errorMessage,
                            "CloseAfter" : 4000},
                           function(cmp){
                               container.set("v.body", [cmp]);
                           });
    },
    
    containsProduct : function(array, elem)
    {
        for (var i in array)
        {
            if (array[i].Product2.Name == elem) return true;
        }
        return false;
    },
    
    toggle: function (component, event) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})