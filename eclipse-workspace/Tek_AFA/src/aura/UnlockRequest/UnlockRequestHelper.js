({
    checkForUnlocksByOtherUser : function(component, event) {
        var enrollmentFormId = component.get("v.enrollmentFormId");
        var getUnlocks = component.get('c.getUnlocksByOtherUsers');

        getUnlocks.setParams({
            "enrollmentFormId" : enrollmentFormId
        });

        getUnlocks.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var activeUnlocks = result.getReturnValue();
                if(activeUnlocks && activeUnlocks.length){
                    component.set("v.activeUnlockRequests", activeUnlocks);
                    component.set("v.showActiveUnlockRequests", true);
                }
            }
            else {
                this.showErrorToast(component, event, "An error occurred while checking for existing Unlock Requests.  Please contact your system administrator");
            }
        });

        $A.enqueueAction(getUnlocks);
    },

    checkForUnlocksByUser : function(component, event){
        var enrollmentFormId = component.get("v.enrollmentFormId");
        var getUnlocks = component.get('c.getExistingUnlockRequestByUser');

        getUnlocks.setParams({
            "enrollmentFormId" : enrollmentFormId
        });

        getUnlocks.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var userUnlock = result.getReturnValue();
                if(userUnlock){
                    component.set('v.currentUnlockRequest', userUnlock);
                    component.set('v.showUnlockedButton', true);
                    this.sendUnlockFormEvent(component, event, true);
                }
            }
            else {
                this.showErrorToast(component, event, "An error occurred checking for Unlock Requests.  Please contact your system administrator");
            }
        });

        $A.enqueueAction(getUnlocks);
    },

    checkUnlockPermission : function(component, event){
        var checkPermission = component.get('c.hasUnlockSetupFormsPermission');

        checkPermission.setCallback(this, function(result) {
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                var hasUnlockPermission = result.getReturnValue();
                component.set('v.hasUnlockPermission', hasUnlockPermission);
            }
            else {
                this.showErrorToast(component, event, "An error occurred.  Please contact your system administrator");
            }
        });

        $A.enqueueAction(checkPermission);
    }, 

    createRequest : function(component, event){
        var enrollmentId = component.get("v.enrollmentFormId");
        var newRequest = component.get("v.newUnlockRequest");

        var unlockAction = component.get("c.createNewUnlockRequest");
        unlockAction.setParams({
            "enrollmentFormId" : enrollmentId,
            "request" : newRequest
        });

        unlockAction.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS"){
                var insertedRequest = result.getReturnValue();
                component.set("v.currentUnlockRequest", insertedRequest);
                component.set("v.showNewUnlockRequest", false);
                component.set("v.showUnlockedButton", true);
                this.sendUnlockFormEvent(component, event, true);
            }
            else {
                this.showErrorToast(component, event, "An error occurred while creating your request.  Please contact your system administrator");
            }
        });

        $A.enqueueAction(unlockAction);
    },

    sendUnlockFormEvent : function(component, event, unlockForm){
        var unlockFormEvent = component.getEvent("unlockTheForm");

        unlockFormEvent.setParams({
            "UnlockForm" : unlockForm
        });
        
        unlockFormEvent.fire();
    },

    completeRequest : function(component, event){
        var currentRequest = component.get("v.currentUnlockRequest");

        var relockAction = component.get("c.completeUnlockRequest");

        relockAction.setParams({
            "request" : currentRequest
        });

        relockAction.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS"){
                component.set("v.currentUnlockRequest", null);
                component.set("v.showUnlockedButton", false);
                this.sendUnlockFormEvent(component, event, false);
            }
            else {
                this.showErrorToast(component, event, "An error occurred while closing your request.  Please contact your system administrator");
            }
        });

        $A.enqueueAction(relockAction);
    },

    showErrorToast : function(component, event, message){
        component.find('notifLib').showNotice({
            "variant" : "error",
            "title" : "Something went wrong!",
            "message" : message,
            "mode" : "pester"
        });
    },

    setColumns : function(component){
        component.set("v.OtherRequestColumns", [
            {label: "Name", fieldName: 'CreatedBy.Name', type: 'text'},
            {label: 'Unlock Reason', fieldName: 'Unlock_Reason__c', type: 'text'}
        ]);
    }
})