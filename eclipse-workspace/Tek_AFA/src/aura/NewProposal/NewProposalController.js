({
    doInit : function(component, event, helper) {
        $A.createComponent("c:ProposalRecordTypes",
                           {
                               
                           }, 
                           function(newCmp) {
                               if (component.isValid()) {
                                   component.set("v.body", newCmp);
                               }
                           });
    },
    
    NavigateComponent : function(component, event, helper) {
        if(event.getParam("navigate") == "Group Product Only Proposal")
        {
            $A.createComponent("c:GroupProductOnly", 
                               {
                                   "recordId" : event.getParam("recordId")
                               }, 
                               function(newCmp) {
                                   if (component.isValid()) {
                                       component.set("v.body", newCmp);
                                   }
                               });
        }
        
        if(event.getParam("navigate") == "Generic Proposal")
        {
            $A.createComponent("c:GenericProposal", 
                               {
                                   "recordId" : event.getParam("recordId")
                               }, 
                               function(newCmp) {
                                   if (component.isValid()) {
                                       component.set("v.body", newCmp);
                                   }
                               });
        }
        
        if(event.getParam("navigate") == "Custom Proposal")
        {
            $A.createComponent("c:CustomProposal", 
                               {
                                   "recordId" : event.getParam("recordId"),
                                   "opportunityId" : event.getParam("opportunityId")
                               }, 
                               function(newCmp) {
                                   if (component.isValid()) {
                                       component.set("v.body", newCmp);
                                   }
                               });
        }
        
        if(event.getParam("navigate") == "RFP")
        {
            $A.createComponent("c:RFProposal", 
                               {
                                   "recordId" : event.getParam("recordId"),
                                   "opportunityId" : event.getParam("opportunityId")
                               }, 
                               function(newCmp) {
                                   if (component.isValid()) {
                                       component.set("v.body", newCmp);
                                   }
                               });
        }
    }
})