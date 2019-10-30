public with Sharing class CopayInformationHelper {

    // This class updates the of_attachments__c field on Copay_Information__c object with the 
    // number of Salesforce files attached to it
    
    public static void updateCopayFilesRollupField(List<ContentDocumentLink> links)
    {
        // Determine if the attachment is being attached to the copay object
        
        List<Id> contentDocumentIds = new List<Id>();
        for(ContentDocumentLink cdl : links)
        {
            system.debug('*** Get Name Method *** ' + cdl.LinkedEntityId.getSobjectType().getDescribe().getName());
            if(cdl.LinkedEntityId.getSobjectType().getDescribe().getName() == 'Copay_Information__c')
                contentDocumentIds.add(cdl.LinkedEntityId);
        }
        
        if(contentDocumentIds.size() > 0)
        	updateRollup(contentDocumentIds);
    }
    
    public static void updateCopayFilesRollupField(List<ContentDocument> documents)
    {
        List<Id> contentDocumentIds = new List<Id>();
        
        for(ContentDocument cd : documents)
        {
            contentDocumentIds.add(cd.Id);
        }
        
        List<ContentDocumentLink> links = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN: contentDocumentIds];
        
        updateCopayFilesRollupField(links);
    }
    
    @future
    public static void updateRollup(List<Id> copayIds)
    {
        Map<Id, Integer> CountsMap = New Map<Id, Integer>();
        List<Copay_Information__c> copaysToUpdate = new List<Copay_Information__c>();
        
        AggregateResult[] groupedResults = [SELECT COUNT(Id) Id, LinkedEntityId FROM ContentDocumentLink 
                                            WHERE LinkedEntityId IN :copayIds Group By LinkedEntityId];
        system.debug(groupedResults);
        for(AggregateREsult ar : groupedResults)
        {
            Integer count = (Integer) ar.get('Id');
            Id copayId = (Id) ar.get('LinkedEntityId');
            CountsMap.put(copayId, count);            
        }
        
        List<Copay_Information__c> copayInfoList = [SELECt Id, of_Files__c FROM Copay_Information__c 
                                                   WHERE Id IN: copayIds];
        
        for(Copay_Information__c copay : copayInfoList)
        {
            copay.of_Files__c = CountsMap.get(copay.Id);
            copaysToUpdate.add(copay);
        }
        
        if(copaysToUpdate.size() > 0)
            update copaysToUpdate;
    }
}