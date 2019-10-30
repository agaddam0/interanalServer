public class CopaySummaryCTRL {
    
    @AuraEnabled
    public static List<ContentDocumentLink> getAffectedRecords(List<String> contentDocumentIds) 
    {
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        
        system.debug('Content Document Ids: ' + contentDocumentIds);
        for(ContentDocumentLink documentLink : [SELECT Id, LinkedEntityId, LinkedEntity.Name, ShareType FROM ContentDocumentLink
                                                  WHERE ContentDocumentId IN :contentDocumentIds])
        {
            if(documentLink.ShareType == 'V')
                documentLinks.add(documentLink);
        }
        
        documentLinks.sort();
        
        return documentLinks;
    }
    
    @AuraEnabled 
    public static List<Copay_Information__c> getUpdatedCopays(List<String> copayIds)
    {
        List<Copay_Information__c> copays = [SELECT Id, Name FROM Copay_Information__c WHERE Id IN: copayIds];
        
        copays.sort();
        
        return copays;
    }
}