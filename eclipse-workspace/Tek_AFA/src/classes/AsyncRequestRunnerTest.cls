@isTest
public with sharing class AsyncRequestRunnerTest {
    
    @testSetup
    static void setup() {
        insertDefaultAsyncRequestRunnerSettings();
    }
    
    static void insertDefaultAsyncRequestRunnerSettings() {
        Async_Request_Runner_Settings__c settings = new Async_Request_Runner_Settings__c(
            Enabled__c = true
        );
        
        insert settings;
    }
    
    static void executeAsyncRequestRunner() {
        Test.startTest();
        
        AsyncRequestRunner.startJob();
        
        Test.stopTest();
    }
    
    static void disableAsyncRunner() {
        Async_Request_Runner_Settings__c settings =
        [SELECT Enabled__c
           FROM Async_Request_Runner_Settings__c];
           
        settings.Enabled__c = false;
        update settings;
    }
    
    static Async_Request__c insertAsyncRequest(String operationClass) {
        return AsyncRequestTestData.Instance.withOperationClass(operationClass).insertAsyncRequest();
    }
    
    static Async_Request__c getAsyncRequestById(Id asyncRequestId) {
        List<Async_Request__c> requests = getAsyncRequestsById(new Set<Id>{ asyncRequestId });
        
        if (requests != null && requests.size() > 0) {
            return requests[0];
        }
        
        return null;
    }
    
    static List<Async_Request__c> getAsyncRequestsById(Set<Id> asyncRequestIds) {
        return
        [SELECT Id,
                Name,
                Operation_Class__c,
                Status__c,
                Error_Message__c
           FROM Async_Request__c
          WHERE Id in :asyncRequestIds];
    }
    
    static void assertAsyncRequestStillPending(Id asyncRequestId) {
        Async_Request__c request = getAsyncRequestById(asyncRequestId);
        
        system.assertEquals('Not Started', request.Status__c, 'The request was processed.');
    }
    
    static void assertAsyncRequestProcessed(Id asyncRequestId) {
        Async_Request__c asyncRequest = getAsyncRequestById(asyncRequestId);
        
        String errorMsg = asyncRequest != null ? asyncRequest.Error_Message__c : '';
        
        system.assert(asyncRequest == null, 'The async request was not processed. Error Message: ' + errorMsg);
    }
    
    static void assertAsyncRequestFinishedWithError(Id asyncRequestId) {
        Async_Request__c asyncRequest = getAsyncRequestById(asyncRequestId);
        
        system.assert(asyncRequest != null, 'The async request was deleted because it completed successfully.');
        
        system.assertEquals('Error', asyncRequest.Status__c, 'The status should be error on the async request.');
        system.assert(String.isNotBlank(asyncRequest.Error_Message__c), 'There should be an error message on the async request.');
    }
    
    @isTest
    static void execute_noAsyncRequestsAndEnabledToRun_expectNoErrorsTest() {
        Exception e = null;
        
        try {
            executeAsyncRequestRunner();
        }
        catch (Exception ex) {
            e = ex;
        }
        
        system.assertEquals(null, e, 'An exception was thrown when there shouldn\'t be. ' + e);
    }
    
    @isTest
    static void execute_AsyncRunnerDisabledWithPendingAsyncRequest_expectPendingAsyncRequestNotExecutedTest() {
        disableAsyncRunner();
        Async_Request__c noopAsyncRequest = insertAsyncRequest('NoOpAsyncRequestHandler');
        
        executeAsyncRequestRunner();
        
        assertAsyncRequestStillPending(noopAsyncRequest.Id);
    }
    
    @isTest
    static void execute_noOpAsyncRequest_expectAsyncRequestProcessedTest() {
        Async_Request__c noopAsyncRequest = insertAsyncRequest('NoOpAsyncRequestHandler');
        
        executeAsyncRequestRunner();
        
        assertAsyncRequestProcessed(noopAsyncRequest.Id);
    }
    
    @isTest
    static void execute_nonExistentOperationAsyncRequest_expectAsyncRequestEndsWithErrorTest() {
        Async_Request__c nonExistentAsyncRequest = insertAsyncRequest('NonExistentAsyncRequestHandler');
        
        executeAsyncRequestRunner();
        
        assertAsyncRequestFinishedWithError(nonExistentAsyncRequest.Id);
    }
    
    @isTest
    static void execute_twoNoOpAsyncRequests_expectAsyncRequestProcessedTest() {
        Async_Request__c noopAsyncRequest1 = AsyncRequestTestData.Instance.withOperationClass('NoOpAsyncRequestHandler').create();
        Async_Request__c noopAsyncRequest2 = AsyncRequestTestData.Instance.withOperationClass('NoOpAsyncRequestHandler').create();
        
        insert new List<Async_Request__c> { noopAsyncRequest1, noopAsyncRequest2 };
        
        executeAsyncRequestRunner();
        
        assertAsyncRequestProcessed(noopAsyncRequest1.Id);
    }
}