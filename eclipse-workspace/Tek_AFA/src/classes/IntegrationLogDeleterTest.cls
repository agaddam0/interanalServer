@isTest
public with sharing class IntegrationLogDeleterTest {
    static void runIntegrationLogDeleter(Date todaysDate) {
        Test.startTest();
        
        IntegrationLogDeleter deleter = new IntegrationLogDeleter(todaysDate);
        Database.executeBatch(deleter);
        
        Test.stopTest();
    }
    
    static void runIntegrationLogDeleterFromScheduledJob() {
        Test.startTest();
        
        IntegrationLogDeleter deleter = new IntegrationLogDeleter();
        deleter.execute(null);
        
        Test.stopTest();
    }
    
    static Integration_Log__c getIntegrationLogById(Id integrationLogId) {
        List<Integration_Log__c> integrationLogs = getIntegrationLogsByIds(new Set<Id>{ integrationLogId });
        
        if (integrationLogs.size() > 0) {
            return integrationLogs[0];
        }
        
        return null;
    }
    
    static List<Integration_Log__c> getIntegrationLogsByIds(Set<Id> integrationLogIds) {
        return [SELECT Id
                  FROM Integration_Log__c
                 WHERE Id in :integrationLogIds];
    }
    
    static void assertIntegrationLogExists(Id integrationLogId) {
        Integration_Log__c integrationLogQueried = getIntegrationLogById(integrationLogId);
        
        system.assert(integrationLogQueried != null, 'The integration log was deleted.');
    }
    
    static void assertIntegrationLogDeleted(Id integrationLogId) {
        Integration_Log__c integrationLogQueried = getIntegrationLogById(integrationLogId);
        
        system.assert(integrationLogQueried == null, 'The integration log was not deleted.');
    }
    
    static void integrationNotWithRetentionExpectLogDeletedTest(String integrationName) {
        Integration_Log__c integrationLog = IntegrationLogTestData.Instance.withIntegration(integrationName).insertIntegrationLog();
        
        Date notWithinRetentionDate = Date.Today().addMonths(IntegrationLogDeleter.DEFAULT_NUMBER_OF_RETENTION_MONTHS + 1);
        
        runIntegrationLogDeleter(notWithinRetentionDate);
        
        assertIntegrationLogDeleted(integrationLog.Id);
    }

    static void customerintegrationNotWithRetentionExpectLogNotDeletedTest(String integrationName) {
        Integration_Log__c integrationLog = IntegrationLogTestData.Instance.withIntegration(integrationName).insertIntegrationLog();
        
        Date notWithinRetentionDate = Date.Today().addMonths(IntegrationLogDeleter.DEFAULT_NUMBER_OF_RETENTION_MONTHS + 1);
        
        runIntegrationLogDeleter(notWithinRetentionDate);
        
        assertIntegrationLogExists(integrationLog.Id);
    }
    
    @isTest
    static void runIntegrationLogDeleter_noIntegrationLogs_expectNoErrorsTest() {
        Exception exceptionThrown = null;
        
        try {
            runIntegrationLogDeleter(Date.today());
        }
        catch(Exception ex) {
            exceptionThrown = ex;
        }
        
        system.assertEquals(null, exceptionThrown, 'An error was thrown: ' + exceptionThrown);
    }
    
    @isTest
    static void runIntegrationLogDeleter_oneIntegrationStillInRetentionPeriod_expectIntegrationLogNotDeletedTest() {
        Integration_Log__c integrationLog = IntegrationLogTestData.Instance.insertIntegrationLog();
        
        Date withinRetentionDate = Date.Today().addMonths(IntegrationLogDeleter.DEFAULT_NUMBER_OF_RETENTION_MONTHS - 1);
        
        runIntegrationLogDeleter(withinRetentionDate);
        
        assertIntegrationLogExists(integrationLog.Id);
    }
    
    @isTest
    static void runIntegrationLogDeleter_onePreenrollmentMarketingIntegrationNotWithinRetentionPeriod_expectIntegrationLogDeletedTest() {
        integrationNotWithRetentionExpectLogDeletedTest('Preenrollment Marketing');
    }

    @isTest
    static void runIntegrationLogDeleter_oneAFEnrollIntegrationNotWithinRetentionPeriod_expectIntegrationLogDeletedTest() {
        integrationNotWithRetentionExpectLogDeletedTest('AFEnroll');
    }

    @isTest
    static void runIntegrationLogDeleter_oneAFPressIntegrationNotWithinRetentionPeriod_expectIntegrationLogDeletedTest() {
        integrationNotWithRetentionExpectLogDeletedTest('AFPress');
    }

    @isTest
    static void runIntegrationLogDeleter_oneStatusCheckerIntegrationNotWithinRetentionPeriod_expectIntegrationLogDeletedTest() {
        integrationNotWithRetentionExpectLogDeletedTest('Status Checker');
    }

    @isTest
    static void runIntegrationLogDeleter_oneAlegeusIntegrationNotWithinRetentionPeriod_expectIntegrationLogNotDeletedTest() {
        customerintegrationNotWithRetentionExpectLogNotDeletedTest('Alegeus');
    }

    @isTest
    static void runIntegrationLogDeleter_oneClaimsCalloutIntegrationNotWithinRetentionPeriod_expectIntegrationLogNotDeletedTest() {
        customerintegrationNotWithRetentionExpectLogNotDeletedTest('Claims Callout');
    }

    @isTest
    static void runIntegrationLogDeleter_oneBillingCalloutIntegrationNotWithinRetentionPeriod_expectIntegrationLogNotDeletedTest() {
        customerintegrationNotWithRetentionExpectLogNotDeletedTest('Billing');
    }
    
    @isTest
    static void runFromSchedule_noLogsToDelete_expectIntegrationLogNotDeletedTest() {
        Integration_Log__c integrationLog = IntegrationLogTestData.Instance.insertIntegrationLog();
        
        runIntegrationLogDeleterFromScheduledJob();
        
        assertIntegrationLogExists(integrationLog.Id);
    }
    
    @isTest
    static void scheduleDailyAt3AM_invoke_expectRunsFineTest() {
        try {
            IntegrationLogDeleter.scheduleDailyAt3AM();
        }
        catch (system.AsyncException asyncEx) {
            String exMessage = asyncEx.getMessage();
            
            if (!exMessage.containsIgnoreCase(IntegrationLogDeleter.DAILY_SCHEDULE_NAME)) {
                throw asyncEx;
            }
        }
    }
}