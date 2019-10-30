@isTest
public with sharing class AccountTriggerHandlerTest {
    @isTest
    static void sendMicrositeUpsertRequestIfNeeded_enrollmentSitePopulatedButWithoutRequestedMicrositePreenrollmentForm_expectNoMicrositeUpsertRequestTest() {
        Account someAccount = AccountTestData.Instance.withEnrollmentSite(null)
                                                      .withRequestedMicrositePreenrollmentFormId(null)
                                                      .insertCustomerAccount();
        
        someAccount.Enrollment_Site__c = 'https://www.newBenefitsSite.com';
        update someAccount;
        
        assertNoAsyncRequests();
    }

    @isTest
    static void sendMicrositeUpsertRequestIfNeeded_enrollmentSitePopulatedWithRequestedMicrositePreenrollmentForm_expectMicrositeUpsertRequestTest() {
        Account someAccount = AccountTestData.Instance.withEnrollmentSite(null)
                                                      .withRequestedMicrositePreenrollmentFormId('Preenrollment Id')
                                                      .insertCustomerAccount();
        
        someAccount.Enrollment_Site__c = 'https://www.newBenefitsSite.com';
        update someAccount;
        
        assertMicrositeUpsertRequestInserted();
    }
    
    static void assertNoAsyncRequests() {
        List<Async_Request__c> asyncRequests = getAsyncRequests();
        
        system.assertEquals(0, asyncRequests.size(), 'There should be no async requests.');
    }
    
    static void assertMicrositeUpsertRequestInserted() {
        List<Async_Request__c> requests = getAsyncRequests();
        
        system.assertEquals(1, requests.size(), 'There should be one async request.');
        
        Async_Request__c request = requests[0];

        system.assertEquals('ESBMicrositeAsyncRequestHandler', request.Operation_Class__c, 'The microsite upsert was not the requested operation.');
        system.assert(String.isNotBlank(request.Parameters__c), 'The microsite upsert was requested without a marketing form id.');
    }
    
    static List<Async_Request__c> getAsyncRequests() {
        return
        [SELECT Id,
                Name,
                Operation_Class__c,
                Parameters__c
           FROM Async_Request__c];
    }
}