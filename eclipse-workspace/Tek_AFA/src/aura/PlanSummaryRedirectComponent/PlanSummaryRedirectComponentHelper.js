({
    getPlanSummaryIdAndRedirect : function(component) {
        var objectType = component.get("v.sObjectName");

        if(objectType == 'Account'){
            this.redirectInNewTab(component.get("v.recordId"));
        }
        else{
            this.getAccountIdFromOpportunity(component);
        }
    },

    redirectInNewTab : function(accountId){
        window.open("/apex/PlanSummaryReportPDF?id=" + accountId, '_blank');
        $A.get("e.force:closeQuickAction").fire()
    },

    getAccountIdFromOpportunity : function(component){
        var getAccountIdAction = component.get('c.getAccountId');
        var oppId = component.get("v.recordId");

        getAccountIdAction.setParams({
            "opportunityId" : oppId
        });

        getAccountIdAction.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var accountId = response.getReturnValue();
                if(accountId){
                    this.redirectInNewTab(accountId);
                }
                else{
                    component.set("v.redirectMessage", 'ERROR!  Something went wrong getting the Account Information!');
                }
            }
        });

        $A.enqueueAction(getAccountIdAction);
    }
})