({
	getFiles : function(component, event) {
		var recordId = component.get("v.relatedTo");
		
		if (!recordId) {
		    console.log('UploadFiles.getFiles has no recordId.');
		    return;
		}
		
		var filterByDescription = component.get('v.filterByDescription');
        
        var getFileLinks = component.get("c.getContentDocumentLinks");
        getFileLinks.setParams({
            "recordId" : recordId,
            "filterByDescription": filterByDescription
        });
        getFileLinks.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.FileList", result.getReturnValue());
            }
        });
        
        $A.enqueueAction(getFileLinks);
	},
    
    linkToMoreRecords : function(component, event) {
        var uploadedFiles = event.getParam("files");
        var fileIds = [];
        var fileDescription = component.get('v.fileDescription');
        var additionals = component.get("v.additionalRelatedRecords");
        //debugger;
        if(additionals.length > 0 || fileDescription)
        {
            for(var i = 0; i < uploadedFiles.length; i++)
            {
                fileIds.push(uploadedFiles[i].documentId);
            }
            
            var filterByDescription = component.get('v.filterByDescription');
            
            var afterUploadProcessingAction = component.get("c.afterUploadProcessing");
            afterUploadProcessingAction.setParams({
                "recordId" : component.get("v.relatedTo"),
                "ContentDocumentIds" : fileIds,
                "additionalIds" : additionals,
                "fileDescription": fileDescription,
                "filterByDescription": filterByDescription
            });
            afterUploadProcessingAction.setCallback(this, function(result){
                var state = result.getState();
                if(component.isValid() && state === "SUCCESS") {
                    component.set("v.FileList", result.getReturnValue());
                }
            });
            
            $A.enqueueAction(afterUploadProcessingAction);
        }
        else {
            this.getFiles(component, event);
        }
        
        var uploadFilesFinishedEvent = component.getEvent("fileUploadFinished");
        uploadFilesFinishedEvent.setParams({
            "Files" : uploadedFiles
        });
        uploadFilesFinishedEvent.fire();
    }  
})