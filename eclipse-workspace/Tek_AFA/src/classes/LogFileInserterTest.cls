@isTest
public with sharing class LogFileInserterTest {
    static Boolean UnableToLockRowError = false;

    @isTest
    static void execute_noLogsToInsert_expectNoLogsToInsertErrorMessageTest() {
        List<Integration_Log__c> nullLogs = null;
        IntegrationLogFilter nullFilter = null;
        Exception expectedEx = null;
        
        try {
            insertLogs(nullLogs, nullFilter);
        }
        catch(Exception ex) {
            expectedEx = ex;
        }
        
        system.assert(expectedEx != null, 'No error was thrown when it should have been.');
        system.assertEquals(LogFileInserter.NO_LOGS_TO_INSERT_MSG, expectedEx.getMessage(), 'The no logs to insert message was not found.');
    }

    @isTest
    static void execute_oneLogToInsertWithNullFilterer_expectNullFiltererErrorMessageTest() {
        Integration_Log__c log = new Integration_Log__c();
        List<Integration_Log__c> logs = new List<Integration_Log__c>{ log };
        IntegrationLogFilter nullFilter = null;
        Exception expectedEx = null;
        
        try {
            insertLogs(logs, nullFilter);
        }
        catch(Exception ex) {
            expectedEx = ex;
        }
        
        system.assert(expectedEx != null, 'No error was thrown when it should have been.');
        system.assertEquals(LogFileInserter.NULL_FILTERER_MSG, expectedEx.getMessage(), 'The no logs to insert message was not found.');
    }
    
    @isTest
    static void execute_oneResponseLogToInsert_expectResponseFileInsertedTest() {
        String response = 'Some awesome response';
        Integration_Log__c log = new Integration_Log__c(Response__c = response);
        List<Integration_Log__c> logs = new List<Integration_Log__c>{ log };

        insertLogs(logs);
        
        // Luke: Unable to lock row error occurred so skip running the test.
        if (UnableToLockRowError) {
            return;
        }
        
        Integration_Log__c responseLog =
        [SELECT Id,
                Name
           FROM Integration_Log__c];

        List<ContentDocumentLink> documentLinks =
        [SELECT Id
           FROM ContentDocumentLink
          WHERE LinkedEntityId = :responseLog.Id];

        system.assertEquals(1, documentLinks.size(), 'There should be one linked file.');
    }
    
    static void insertLogs(List<Integration_Log__c> logsToInsert) {
        insertLogs(logsToInsert, new IntegrationLogFilter());
    }

    static void insertLogs(List<Integration_Log__c> logsToInsert, IntegrationLogFilter filter) {
        try {
	        Test.startTest();
	        
	        System.enqueueJob(new LogFileInserter(logsToInsert, filter));
	        
	        Test.stopTest();
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
            else {
                UnableToLockRowError = true;
            }
        }
    }
}