@isTest
public with sharing class ESBBatchStatusCheckerTest {
    private static final String DEFAULT_ENDPOINT = 'https://api-qa.americanfidelity.com:443';
    private static final String SYSTEM_ERROR_MESSAGE = 'Some System Error';

    @testSetup
    static void setup() {
        API_Manager__c sandboxAPI = new API_Manager__c();
        sandboxAPI.Name = ESBStatusCheckClient.SANDBOX_STATUS_CHECKER_API_MANAGER_NAME;
        sandboxAPI.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        sandboxAPI.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        sandboxAPI.Endpoint__c = DEFAULT_ENDPOINT;
        sandboxAPI.Host__c = 'api-qa.americanfidelity.com:443';
        sandboxAPI.Username__c = 'Username';
        sandboxAPI.Password__c = 'Password';
        insert sandboxAPI;
        
        API_Manager__c productionAPI = sandboxAPI.clone(false, true);
        productionAPI.Name = ESBStatusCheckClient.PRODUCTION_STATUS_CHECKER_API_MANAGER_NAME;
        
        insert productionAPI;
    }
    
    @isTest
    static void execute_noCheckStatusURLs_expectNoErrorsTest() {
        String errorMessage = '';
        
        try {
            executeChecker();
        }
        catch(Exception e) {
            errorMessage = e.getMessage();
        }
        
        system.assertEquals('', errorMessage, 'There should be no error. Error: ' + errorMessage);
    }
    
    @isTest
    static void execute_threeStatusCheckURLsToCallAndAllSuccessful_expectAllCalloutsMadeAndLoggedTest() {
        Integer threeEndpointsToExecute = 3;
        List<String> endpoints = generateStatusChecks(threeEndpointsToExecute);
        setCheckStatusMocks(endpoints, new ESBStatusCheckClientTest.CheckStatusSuccessMock());
        insertAPIManagerStatusCheckURLs(endpoints);
        
        executeChecker();

        List<Integration_Log__c> logs = getIntegrationLogs();

        system.assert(logs != null, 'The logs should not be null.');
        
        Integer expectedNumberOfLogs = 4;
        system.assertEquals(4, logs.size(), 'There is not the number of expected logs.');
    }
    
    static List<String> generateStatusChecks(Integer numberStatusChecks) {
        List<String> statusCheckEndpoints = new List<String>();
        
        for (Integer i = 0; i < numberStatusChecks; ++i) {
            String endpoint = 'https://example.com/statusCheck' + i;
            statusCheckEndpoints.add(endpoint);
        }
        
        return statusCheckEndpoints;
    }

    static void setCheckStatusMocks(List<String> endpoints, HttpCalloutMock responseMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        
        for (String endpoint : endpoints) {
            requests.put(endpoint, responseMock);
        }

        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    static void insertAPIManagerStatusCheckURLs(List<String> endpoints) {
        List<API_Manager_Status_Check_URL__c> statusCheckURLs = new List<API_Manager_Status_Check_URL__c>();
        
        Integer i = 1;
        
        for (String endpoint : endpoints) {
            API_Manager_Status_Check_URL__c statusCheckURL = new API_Manager_Status_Check_URL__c();

            statusCheckURL.name = 'Endpoint ' + i;
            statusCheckURL.URL__c = endpoint; 

            statusCheckURLs.add(statusCheckURL);
            ++i;
        }
        
        insert statusCheckURLs;
    }
    
    static void executeChecker() {
        Test.startTest();
        
        ESBBatchStatusChecker checker = new ESBBatchStatusChecker();
        checker.execute(null);
        
        Test.stopTest();
    }
    
    static List<Integration_Log__c> getIntegrationLogs() {
        return
        [SELECT Id,
                Name,
                Request__c,
                Response__c,
                Message__c,
                Contextual_Info__c,
                Endpoint__c
           FROM Integration_Log__c];
    }
}