@isTest
public with sharing class IntegrationLogTriggerHandlerTest {
    static Boolean UnableToLockRowError = false;

    @isTest
    static void deleteRelatedLogFiles_noLogFileOnDeletedIntegrationLog_expectNoErrorsTest() {
        Integration_Log__c logToDelete = IntegrationLogTestData.Instance.insertIntegrationLog();
        
        delete logToDelete;
        
        List<Integration_Log__c> logs =
        [SELECT Id
           FROM Integration_Log__c
          WHERE Id = :logToDelete.Id];

        system.assertEquals(0, logs.size(), 'The integration log was not deleted.');
    }
    
    @isTest
    static void deleteRelatedLogFiles_deleteIntegrationLogWithLogResponseFile_expectBothDeletedTest() {
        Integration_Log__c logToDelete = IntegrationLogTestData.Instance.insertIntegrationLog();

        ContentVersion logFile = insertFile(logToDelete.Id, 'Example Log File', logToDelete.Id + ' Response', 'GeneratedInSalesforce.txt');
        
        // Luke: Unable to lock row error occurred so skip running the test.
        if (UnableToLockRowError) {
            return;
        }

        List<ContentVersion> logFiles = getIntegrationLogFiles(logToDelete.Id);
        system.assertEquals(1, logFiles.size(), 'The log file was not inserted and related to the integration log.');
        
        delete logToDelete;
        
        ContentDocument logDocument = getContentDocumentById(logFiles[0].ContentDocumentId);
        
        system.assertEquals(null, logDocument, 'The log file should have been deleted.');
    }

    @isTest
    static void deleteRelatedLogFiles_deleteIntegrationLogWithNonResponseLogFile_expectIntegrationLogRecordOnlyDeletedTest() {
        Integration_Log__c logToDelete = IntegrationLogTestData.Instance.insertIntegrationLog();

        ContentVersion nonResponseFile = insertFile(logToDelete.Id, 'Example File', 'A Request File', 'GeneratedInSalesforce.txt');
        
        // Luke: Unable to lock row error occurred so skip running the test.
        if (UnableToLockRowError) {
            return;
        }

        List<ContentVersion> logFiles = getIntegrationLogFiles(logToDelete.Id);
        system.assertEquals(1, logFiles.size(), 'The non-Response file was not inserted and related to the integration log.');
        
        delete logToDelete;
        
        ContentDocument logDocument = getContentDocumentById(logFiles[0].ContentDocumentId);
        
        system.assertNotEquals(null, logDocument, 'The log file should not have been deleted.');
    }
    
    static ContentVersion insertFile(Id recordId, String fileContents, String title, String pathOnClient) {
        try {
	        ContentVersion file = new ContentVersion(
	            VersionData = Blob.valueOf(fileContents),
	            Title = title,
	            PathOnClient = pathOnClient,
	            FirstPublishLocationId = recordId
	        );
	
	        insert file;
	        
	        return file;
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
            else {
                UnableToLockRowError = true;
            }
        }
        
        return null;
    }
    
    static List<ContentVersion> getIntegrationLogFiles(Id integrationLogId) {
        return
        [SELECT Id,
                ContentDocumentId
           FROM ContentVersion
          WHERE FirstPublishLocationId = :integrationLogId];
    }
    
    static ContentDocument getContentDocumentById(Id contentDocumentId) {
        List<ContentDocument> contentDocuments =
        [SELECT Id
           FROM ContentDocument
          WHERE Id = :contentDocumentId];

        if (contentDocuments.size() > 0) {
            return contentDocuments[0];
        }

        return null;
    }
}