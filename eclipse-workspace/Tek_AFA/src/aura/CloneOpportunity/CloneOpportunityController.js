({
    doInit : function(component, event, helper) {
        helper.toggle(component, event);
        helper.getInitialContext(component, event);
    },
    
    submitForm : function(component, event, helper) {
        helper.insertOpportunity(component, event);
    },
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    createEnrollmentOpportunity : function(component, event, helper) {
        helper.showEnrollmentForm(component);
    }
})