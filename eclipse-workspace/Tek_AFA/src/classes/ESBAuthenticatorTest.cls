@isTest
public with sharing class ESBAuthenticatorTest {
    private static final String DEFAULT_API_MANAGER_NAME = 'Auth';
    
    @testSetup
    static void setup() {
        API_Manager__c api = new API_Manager__c();
        api.Name = DEFAULT_API_MANAGER_NAME;
        api.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        api.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        api.Endpoint__c = 'https://api-qa.americanfidelity.com:443';
        api.Host__c = 'api-qa.americanfidelity.com:443';
        api.Username__c = 'Username';
        api.Password__c = 'Password';
        insert api;
    }
    
    static void testInstantiationValidation(String integrationName, String sandboxAPIManager, String productionAPIManager, String expectedValidationMessage) {
        Exception ex = null;
        
        try {
            ESBAuthenticator auth = new ESBAuthenticator(integrationName, sandboxAPIManager, productionAPIManager);
        }
        catch (Exception e) {
            ex = e;
        }
        
        system.assert(ex != null, 'No validation error was thrown.');
        system.assert(ex.getMessage().containsIgnoreCase(expectedValidationMessage), 'The expected validation message was not found.');
    }
    
    static ESBAuthenticator instantiateDefaultAuthenticator() {
        return new ESBAuthenticator('Some integration', DEFAULT_API_MANAGER_NAME, DEFAULT_API_MANAGER_NAME);
    }
    
    static Integration_Log__c getFirstLog() {
        return
        [SELECT Id,
                Name,
                Request__c,
                Response__c,
                Message__c,
                Severity__c
           FROM Integration_Log__c
          Order By CreatedDate
         Limit 1];
    }
    
    @isTest
    static void instantiate_WithNoSandboxAPIManagerName_expectSandboxAPIManagerNameRequiredValidationMessageTest() {
        testInstantiationValidation('Some Integration', '', 'prodAPI', ESBServiceBase.SANDBOX_API_MANAGER_NAME_REQUIRED_MESSAGE);
    }
    
    @isTest
    static void instantiate_WithNoProductionAPIManagerName_expectProductionAPIManagerNameRequiredValidationMessageTest() {
        testInstantiationValidation('Some Integration', 'sandboxAPI', '', ESBServiceBase.PRODUCTION_API_MANAGER_NAME_REQUIRED_MESSAGE);
    }
    
    @isTest
    static void instantiate_WithNoIntegrationName_expectIntegrationNameRequiredValidationMessageTest() {
        testInstantiationValidation('', 'sandboxAPI', 'prodAPI', ESBAuthenticator.INTEGRATION_NAME_REQUIRED_MESSAGE);
    }
    
    @isTest
    static void authenticate_withAPIManager_expectAuthenticationSuccessfulTest() {
        Test.setMock(HttpCalloutMock.class, new AuthenticateSuccessfulMock());
        
        ESBAuthenticator auth = instantiateDefaultAuthenticator();
        
        Test.startTest();
        
        String authToken = auth.authenticate();
        
        Test.stopTest();
        
        Integration_Log__c log = getFirstLog();

        system.assert(String.isNotBlank(authToken), 'The authentication was not successful. Error Message: ' + log.Message__c);
        system.assert(String.isNotBlank(log.Request__c), 'The request was not logged.');
        system.assert(String.isNotBlank(log.Response__c), 'The response was not logged.');
    }
    
    @isTest
    static void authenticate_withAPIManagerAndFailedAuthentication_expectAuthenticationFailedTest() {
        Test.setMock(HttpCalloutMock.class, new AuthenticateFailedMock());
        
        ESBAuthenticator auth = instantiateDefaultAuthenticator();
        
        Test.startTest();
        
        String authToken = auth.authenticate();
        
        Test.stopTest();
        
        Integration_Log__c log = getFirstLog();

        system.assert(String.isBlank(authToken), 'The authentication was successful when it should have failed. Error Message: ' + log.Message__c);
        system.assert(String.isNotBlank(log.Request__c), 'The request was not logged.');
        system.assert(String.isNotBlank(log.Response__c), 'The response was not logged.');
    }
    
    @isTest
    static void authenticate_withNoAPIManagerFound_expectAuthenticationFailedTest() {
        Test.setMock(HttpCalloutMock.class, new AuthenticateSuccessfulMock());
        
        ESBAuthenticator auth = new ESBAuthenticator('Some integration', 'NonExistentAPIManager', 'NonExistentAPIManager');
        
        Test.startTest();
        
        String authToken = auth.authenticate();
        
        Test.stopTest();
        
        Integration_Log__c log = getFirstLog();

        system.assert(String.isBlank(authToken), 'The authentication was successful when it should have failed. Error Message: ' + log.Message__c);
        system.assert(String.isNotBlank(log.Message__c), 'The error message was not logged.');
        system.assertEquals('ERROR', log.Severity__c, 'The severity should be error on the log.');
    }
    
    public with sharing class AuthenticateSuccessfulMock implements HTTPCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
	        HttpResponse res = new HTTPResponse();
	        res.setHeader('Content-Type', 'application/JSON');
	        res.setBody('{"access_token":"2282def0c5a117cd6bb4702afa867","refresh_token":"2bb21b671d482547447f5894bf647","scope":"default","token_type":"Bearer","expires_in":2921}');
	        res.setStatusCode(200);
	        return res;
        }
    }
    
    public with sharing class AuthenticateFailedMock implements HTTPCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"Error": "Unauthorized"}');
            res.setStatusCode(401);
            return res;
        }
    }
    
    public with sharing class AuthenticateFailedWithBlankBodyMock implements HTTPCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('');
            res.setStatusCode(401);
            return res;
        }
    }
}