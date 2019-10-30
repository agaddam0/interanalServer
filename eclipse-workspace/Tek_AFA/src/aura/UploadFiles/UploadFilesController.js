({
    doInit : function(component, event, helper) {
        helper.getFiles(component, event);
    },
    
    handleUploadFinished: function (component, event, helper) {
        helper.linkToMoreRecords(component, event);       
    },
    
    deleteFile : function (component, event, helper) {
        var deleteId = event.currentTarget.getAttribute("data-recId");
        var relatedTo = component.get("v.relatedTo");
        var filterByDescription = component.get("v.filterByDescription");
        
        var removeFile = component.get("c.DeleteFile");
        removeFile.setParams({
            "fileToDeleteId" : deleteId,
            "relatedRecordId" : relatedTo,
            "filterByDescription" : filterByDescription
        });
        removeFile.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.FileList", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(removeFile);
    },
    
    reloadFiles : function(component, event, helper) {
    	helper.getFiles(component, event);
    }
})