({
    doInit : function(component, event, helper) {
        helper.setColumns(component);
        helper.checkUnlockPermission(component, event);
    },

    closeActiveUnlockRequests : function(component, event, helper){
        component.set('v.showActiveUnlockRequests', false);
    },

    closeNewUnlockRequest : function(component, event, helper){
        component.set('v.showNewUnlockRequest', false);
    },

    setEnrollmentFormId : function(component, event, helper){
        var enrollmentFormId = event.getParam('arguments').enrollmentId;
        component.set('v.enrollmentFormId', enrollmentFormId);
        helper.checkForUnlocksByUser(component, event);
        helper.checkForUnlocksByOtherUser(component, event);
    },

    openUnlockRequestModal : function(component, event, helper){
        component.set("v.showNewUnlockRequest", true);
    },

    createUnlockRequest : function(component, event, helper){
        helper.createRequest(component, event);
    }, 

    closeUnlockRequest : function(component, event, helper){
        helper.completeRequest(component, event);
    }
})