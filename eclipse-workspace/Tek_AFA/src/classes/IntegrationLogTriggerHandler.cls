public class IntegrationLogTriggerHandler extends TriggerHandlerBase {

    public override void beforeDelete(Map<Id, Sobject> deletedRecordsMap) {
        system.debug('   IntegrationLogTriggerHandler::beforeDelete');
        
        deleteRelatedLogFiles(deletedRecordsMap);
    }
    
    private void deleteRelatedLogFiles(Map<Id, Sobject> deletedRecordsMap) {
        List<ContentDocument> logFilesToDelete = getLogFilesToDelete(deletedRecordsMap.keySet());
        
        system.debug('   deleteRelatedLogFiles::logFilesToDelete ' + logFilesToDelete);
        
        if (logFilesToDelete.isEmpty() == false) {
            delete logFilesToDelete;
        }
    }
    
    private List<ContentDocument> getLogFilesToDelete(Set<Id> deletedIntegrationLogIds) {
        List<ContentDocumentLink> logFileLinks =
        [SELECT ContentDocumentId
           FROM ContentDocumentLink
          WHERE LinkedEntityId in :deletedIntegrationLogIds
            AND ContentDocument.Title like '% Response%'];

        system.debug('   getLogFilesToDelete::logFileLinks ' + logFileLinks);

        Map<Id, ContentDocument> logFilesToDelete = new Map<Id, ContentDocument>();
        
        for (ContentDocumentLink logFileLink : logFileLinks) {
            system.debug('   getLogFilesToDelete::logFileLink ' + logFileLink);
            
            if (logFilesToDelete.containsKey(logFileLink.ContentDocumentId) == false) {
                ContentDocument logFileToDelete = new ContentDocument(Id = logFileLink.ContentDocumentId);
                logFilesToDelete.put(logFileLink.ContentDocumentId, logFileToDelete);
            }
        }
        
        return logFilesToDelete.values();
    }
}