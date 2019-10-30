public class UploadFileCTRL {
    
    public Id ObjectId								{get;set;}
    public List<ContentDocumentLink> files 			{get;set;}
    public List<ContentDocumentLink> linksToInsert 	{get;set;}
    public List<Id> ContentLinkIdList				{get;set;}
    public String ContentLinkIds					{get;set;}
    public Id ContentDocumentId						{get;set;}
    public String fileName							{get;set;}
    public transient Blob fileBody					{get;set;}
    public boolean refreshPage						{get;set;}
    
    public UploadFileCTRL()
    {
        objectId = ApexPages.currentPage().getParameters().get('id');
        ContentDocumentId = ApexPages.currentPage().getParameters().get('ContentDocumentId');
        ContentLinkIds = ApexPages.currentPage().getParameters().get('ContentLinkIds');
        refreshPage = false;
        
        getFiles();
    }
    
    public pageReference Upload()
    {
        if(fileName != null)
        {
            linksToInsert = new List<ContentDocumentLink>();
            
            // Insert our content version
            ContentVersion cv = new ContentVersion();
            cv.VersionData = fileBody;
            cv.title = UploadedSignatureHelper.ChangeUploadedSignatureFormTitle(ObjectId, fileName);
            cv.PathOnClient = fileName;
            cv.FirstPublishLocationId = ObjectId;
            if(ContentDocumentId != null)
                cv.ContentDocumentId = ContentDocumentId;
            
            insert cv;
            
            // Once the document is inserted, now we have to query for the contentdocumentid as it is not automatically generated
            // and share it with the objects specified by creating new content document link records.
            
            if(ContentDocumentId == null)
            {
                cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];
                if(cv != null)
                    ContentDocumentId = cv.ContentDocumentId;
            }
            
            if(ContentLinkIds != null && ContentLinkIds != '')
            {
                
                ContentLinkIdList = ContentLinkIds.split(',');
                system.debug('### Content Link Id List: ' + ContentLinkIdList);
                
                for(String LinkId : ContentLinkIdList)
                {
                    ContentDocumentLink documentLink = new ContentDocumentLink();
                    documentLink.LinkedEntityId = linkId;
                    documentLink.ContentDocumentId = ContentDocumentId;
                    documentLink.ShareType = 'V';
                    
                    linksToInsert.add(documentLink);
                }
            }
        }
       
        if(linksToInsert.size() > 0)
            insert linksToInsert;
        
        if(ObjectId.getSobjectType().getDescribe().getName() == 'Enrollment_Form__c')
        {
            UploadedSignatureHelper.UpdateSignatureFormStatusOnSignatureUpload(ObjectId);
            refreshPage = true;
        }
        	
        
        getFiles();
        return null;
    }
    
    public pageReference DeleteFile()
    {
        string deleteId = ApexPages.CurrentPage().getParameters().get('fileToDelete');
        
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: deleteId];
        delete cd;
        
        if(ObjectId.getSobjectType().getDescribe().getName() == 'Enrollment_Form__c')
        {
            UploadedSignatureHelper.UpdateSignatureFormStatusOnSignatureDelete(ObjectId);
            refreshPage = true;
        }
        
        getFiles();
        return null;
    }
    
    public void getFiles()
    {
        files = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: objectId];
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> getContentDocumentLinks(string recordId, string filterByDescription)
    {
        List<ContentDocumentLink> documentLinks = [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.Description
                                                   FROM ContentDocumentLink 
                                                   WHERE LinkedEntityId =: recordId];
        
        if (String.isNotBlank(filterByDescription)) {
            List<ContentDocumentLink> filteredFilesByDescription = new List<ContentDocumentLink>();
            
            for (ContentDocumentLink recordFileLink : documentLinks) {
                if (recordFileLink.ContentDocument.Description == filterByDescription) {
                    filteredFilesByDescription.add(recordFileLink);
                }
            }
            
            documentLinks = filteredFilesByDescription;
        }
        
        system.debug(documentLinks);
        return documentLinks;
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> DeleteFile(string fileToDeleteId, string relatedRecordId, String filterByDescription)
    {        
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: fileToDeleteId];
        delete cd; 
        
        return getContentDocumentLinks(relatedRecordId, filterByDescription);
    }
    
    @AuraEnabled
    public static List<ContentDocumentLink> afterUploadProcessing(String recordId, List<String> ContentDocumentIds, List<String> additionalIds, String fileDescription, String filterByDescription)
    {
        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        
        if (additionalIds == null) {
            additionalIds = new List<String>();
        }
        
        for(String ContentDocumentId : ContentDocumentIds)
        {
            for(String LinkId : additionalIds)
            {
                ContentDocumentLink documentLink = new ContentDocumentLink();
                documentLink.LinkedEntityId = linkId;
                documentLink.ContentDocumentId = ContentDocumentId;
                documentLink.ShareType = 'V';
                
                linksToInsert.add(documentLink);
            }
        }
        
        if(linksToInsert.size() > 0)
            insert linksToInsert;

        if (String.isNotBlank(fileDescription)) {
            List<ContentDocument> contentDocumentsToUpdate = new List<ContentDocument>();
            
            for (String contentDocumentId : ContentDocumentIds) {
                ContentDocument cd = new ContentDocument(
                    Id = contentDocumentId,
                    Description = fileDescription
                );
                
                contentDocumentsToUpdate.add(cd);
            }
            
            if (contentDocumentsToUpdate.size() > 0) {
                update contentDocumentsToUpdate;
            }
        }

        return getContentDocumentLinks(recordId, filterByDescription);
    }
}