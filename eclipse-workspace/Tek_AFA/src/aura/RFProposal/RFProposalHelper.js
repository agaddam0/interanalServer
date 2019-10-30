({
    loadRecords : function(component, record) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.retrieveProposal");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var record = result.getReturnValue();                
                // Set Defaults
                record.Group_Display_Name__c = record.Opportunity__r.Account.Name;
                record.How_will_the_Proposal_be_fulfilled__c = 'See RFP';
                
                this.loadFieldSets(component, record);
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
    
	loadFieldSets : function(component, record) {
        var fsf = component.find('ProposalInfoFieldSet');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPBenefits');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPStrategy');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPRepInfo1');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPRepInfo2');
        fsf.loadComponent(record);
        
        fsf = component.find('AdditionalNotes');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPLTDDetails');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPLTDPlan');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPSTDPlan');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPSTDDetails');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPBranchOffice');
        fsf.loadComponent(record);
        
        fsf = component.find('RFPBrokerName');
        fsf.loadComponent(record);
        
        this.toggle(component, event);
	},
    
    validateForm : function(component, record) {
        var LTDPlan = component.find('RFPLTDPlan'),
            LTDDetails = component.find('RFPLTDDetails'),
            STDPlan = component.find('RFPSTDPlan'),
            STDDetails = component.find('RFPSTDDetails'),
            BranchOffice = component.find('RFPBranchOffice'),
            BrokerName = component.find('RFPBrokerName'),
            OppProducts = component.get('v.OpportunityProducts');
            
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
                if(!record.Detail_Custom_STD_Request__c)
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
        
        // RFP Strategy
        if(!record.Have_you_met_with_the_Decision_Maker__c)
            validForm = false;
        
        if(!record.Main_drivers_for_decision__c)
            validForm = false;
        
        if(!record.What_is_the_enrollment_strategy__c)
            validForm = false;
        
        if(!record.Why_is_the_group_out_to_bid__c)
            validForm = false;
        
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
                
        //debugger;
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
            isValid = this.validateForm(component, proposal),
            account = component.get("v.Account"),
            OppProducts = component.get('v.OpportunityProducts');
        
        if(OppProducts.length < 1)
        {
            this.showErrorToast(component, 'Please add at least one Product to the Proposal.');
            this.toggle(component, event);
        }
        else if(isValid)
        {            
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