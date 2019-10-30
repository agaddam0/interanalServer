({
    doInit : function(component, event, helper) {
        helper.loadAccountInfo(component, helper);
    },

    viewParticipantAccountsClicked : function(component, event, helper) {
        helper.loadParticipantAcccounts(component, event, helper);
    },

    onStatusFilterChanged : function(component, event, helper) {
        helper.loadParticipantAcccounts(component, event, helper);
    },

    closeQuickAction : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})