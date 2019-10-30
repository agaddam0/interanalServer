({
    init : function(component, event, helper) {
        component.set('v.saveRequest', {});
    },

    submitEnrollmentCase : function(component, event, helper) {
        helper.submitEnrollmentCase(component);
    }
})