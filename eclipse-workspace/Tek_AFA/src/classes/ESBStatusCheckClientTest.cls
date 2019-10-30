@isTest
public with sharing class ESBStatusCheckClientTest {
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
    static void checkStatus_esbCheckStatusURLBlank_expectCheckStatusURLRequiredMessageTest() {
        String emptyESBCheckStatusURL = '';
        
        ESBStatusCheckClient client = new ESBStatusCheckClient();
        ESBStatusCheckClient.APICheckStatusResult result = client.checkStatus(emptyESBCheckStatusURL);
        
        assertCheckStatusFailedWithMessage(result, ESBStatusCheckClient.CHECK_STATUS_URL_REQUIRED_MESSAGE);
    }

    @isTest
    static void checkStatus_authenticationFailed_expectAuthTokenBlankErrorMessageTest() {
        String someESBCheckStatusURL = '/something/status';
        
        ESBStatusCheckClient client = new ESBStatusCheckClient();
        ESBStatusCheckClient.APICheckStatusResult result = client.checkStatus(someESBCheckStatusURL);
        
        assertCheckStatusFailedWithMessage(result, ESBServiceBase.AUTH_TOKEN_BLANK_ERROR_MESSAGE);
    }
    
    @isTest
    static void checkStatus_responseReturned500Error_expectFailedResultWithErrorMessageTest() {
        String esbCheckStatusURL = 'https://example.com/someStatus';
        setCheckStatusMock(esbCheckStatusURL, new CheckStatusSystemErrorMock());

        ESBStatusCheckClient.APICheckStatusResult result = checkStatus(esbCheckStatusURL);

        assertCheckStatusFailedWithMessage(result, SYSTEM_ERROR_MESSAGE);
    }
    
    @isTest
    static void checkStatus_responseSuccessful_expectSuccessfulResultTest() {
        String esbCheckStatusURL = 'https://example.com/someStatus';
        setCheckStatusMock(esbCheckStatusURL, new CheckStatusSuccessMock());
        
        ESBStatusCheckClient.APICheckStatusResult result = checkStatus(esbCheckStatusURL);
        
        assertCheckStatusSuccessful(result);
    }

    @isTest
    static void checkStatus_responseSuccessfulWithRelativePath_expectSuccessfulResultTest() {
        String esbCheckStatusURL = '/example.com/someStatus';
        setCheckStatusMock(DEFAULT_ENDPOINT + '/' + esbCheckStatusURL, new CheckStatusSuccessMock());
        
        ESBStatusCheckClient.APICheckStatusResult result = checkStatus(esbCheckStatusURL);
        
        assertCheckStatusSuccessful(result);
    }
    
    static ESBStatusCheckClient.APICheckStatusResult checkStatus(String esbCheckStatusURL) {
        Test.startTest();
        
        ESBStatusCheckClient client = new ESBStatusCheckClient();
        ESBStatusCheckClient.APICheckStatusResult result = client.checkStatus(esbCheckStatusURL);

        Test.stopTest();

        return result;
    }

    static void assertCheckStatusFailedWithMessage(ESBStatusCheckClient.APICheckStatusResult result, String expectedMessage) {
        system.assert(result != null, 'The api check status result is null.');
        system.assertEquals(false, result.Success, 'The success should be false.');
        system.assertEquals(expectedMessage, result.Message, 'The expected failure message was not found.');
    }

    static void assertCheckStatusSuccessful(ESBStatusCheckClient.APICheckStatusResult result) {
        system.assert(result != null, 'The api check status result is null.');
        system.assertEquals(true, result.Success, 'The success should be true.');
        system.assert(String.isBlank(result.Message), 'The message should be blank.');
    }
    
    static void setCheckStatusMock(String endpoint, HttpCalloutMock responseMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        requests.put(endpoint, responseMock);

        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    public class CheckStatusSystemErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(SYSTEM_ERROR_MESSAGE);
            res.setStatusCode(500);
            return res;
        }
    }

    public class CheckStatusSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Succcess": true}');
            res.setStatusCode(200);
            return res;
        }
    }
}