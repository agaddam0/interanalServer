({
	validateForm : function(component) {
        var validForm = true;
        var theField;
        // This seemed to need to be here before it would read values off the opp
        theField = component.get("v.ChangeRequest");
        
        theField = component.get("v.ChangeRequest.Last_Month_Paid_by_Group__c");
        if(theField == null)
            validForm = false;
        
        theField = component.get("v.ChangeRequest.Reason_for_Leaving_Employment__c");
        if(theField == null)
            validForm = false;
        
        return(validForm);
    },
})