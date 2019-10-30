({
    RedirectToNextComponent : function(cmp) {
        var recordType = cmp.get("v.SelectedType");
        var oppId = cmp.get("v.opportunityId");
        
        if(!recordType){
            this.showErrorToast(cmp, "Please selecte a Proposal type.");
        }
        else {
            
            if(!oppId && (recordType.Name == 'Custom Proposal' || recordType.Name == 'RFP'))
            {
                if(!oppId) {
                    this.showErrorToast(cmp, "You must select an Opportunity for this Proposal.");
                }
            } else {
                var insertProposalAction = cmp.get("c.insertProposal");
                insertProposalAction.setParams({
                    "RecordTypeId" : recordType.RecordTypeId,
                    "OpportunityId" : oppId
                });
                
                insertProposalAction.setCallback(this, function(result) {
                    var state = result.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                        var prpsl = result.getReturnValue();
                        console.log(prpsl);
                        var newEvent = $A.get("e.c:navigateToCmp");
                        newEvent.setParams({
                            "navigate" : recordType.Name,
                            "recordId" : prpsl.Id,
                            "opportunityId" : oppId
                        });
                        newEvent.fire();     
                    }
                    else {
                        this.showErrorToast(cmp, "Something went wrong, contact your Administrator.");
                    }
                });
                
                $A.enqueueAction(insertProposalAction);
            }  
        }
        
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
    },
})