@isTest
public with sharing class AFEnrollServiceTest {
    private static final String DEFAULT_ENDPOINT = 'https://api-qa.americanfidelity.com:443';

    @testSetup
    static void setup() {
        API_Manager__c sandboxAPI = new API_Manager__c();
        sandboxAPI.Name = AFEnrollService.SANDBOX_AFENROLL_API_MANAGER_NAME;
        sandboxAPI.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        sandboxAPI.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        sandboxAPI.Endpoint__c = DEFAULT_ENDPOINT;
        sandboxAPI.Host__c = 'api-qa.americanfidelity.com:443';
        sandboxAPI.Username__c = 'Username';
        sandboxAPI.Password__c = 'Password';
        insert sandboxAPI;
        
        API_Manager__c productionAPI = sandboxAPI.clone(false, true);
        productionAPI.Name = AFEnrollService.PRODUCTION_AFENROLL_API_MANAGER_NAME;
        
        insert productionAPI;
        
        AFEnroll_Settings__c afEnrollSettings = new AFEnroll_Settings__c();
        afEnrollSettings.AFEnroll_Case_Start_Date__c = Date.Today();
        afEnrollSettings.Create_Case_Batch_Size__c = 99;
        
        insert afEnrollSettings;
    }

    @isTest
    static void saveEnrollmentCase_nullRequestContext_expectNullRequestContextErrorMessageTest() {
        AFEnrollService.SaveEnrollmentCaseRequest nullRequest = null;

        AFEnrollService.SaveEnrollmentCaseResponse response = saveEnrollmentCase(nullRequest);
        
        assertErrorMessage(response, AFEnrollService.REQUEST_CONTEXT_NULL_MSG);
    }

    @isTest
    static void saveEnrollmentCase_authFailed_expectAuthFailedErrorMessageTest() {
        loadSaveCaseCalloutsMock(new ESBAuthenticatorTest.AuthenticateFailedMock(), null);
        
        AFEnrollService.SaveEnrollmentCaseRequest emptyRequest = new AFEnrollService.SaveEnrollmentCaseRequest();

        AFEnrollService.SaveEnrollmentCaseResponse response = saveEnrollmentCase(emptyRequest);
        
        assertErrorMessage(response, ESBServiceBase.AUTH_TOKEN_BLANK_ERROR_MESSAGE);
    }
    
    @isTest
    static void saveEnrollmentCase_saveSucceeded_expectAFEnrollCaseIdTest() {
        loadSaveCaseCalloutsMock(new SaveCaseSuccessfulMock());

        AFEnrollService.SaveEnrollmentCaseRequest request = new AFEnrollService.SaveEnrollmentCaseRequest();
        request.AccountName = 'Some Account';
        request.MCPNumber = '19388';

        AFEnrollService.SaveEnrollmentCaseResponse response = saveEnrollmentCase(request);
        
        assertSaveCaseSuccessful(response);
    }

    @isTest
    static void saveEnrollmentCase_saveSucceededWithMultipleAdditionalMCPs_expectAFEnrollCaseIdTest() {
        loadSaveCaseCalloutsMock(new SaveCaseSuccessfulMock());

        AFEnrollService.SaveEnrollmentCaseRequest request = new AFEnrollService.SaveEnrollmentCaseRequest();
        request.AccountName = 'Some Account';
        request.MCPNumber = '19388';
        request.AdditionalMCPsCommaSeparated = '19387,18199';

        AFEnrollService.SaveEnrollmentCaseResponse response = saveEnrollmentCase(request);
        
        assertSaveCaseSuccessful(response);
    }

    @isTest
    static void saveEnrollmentCase_saveFailed_expectErrorResponseWithErrorMessageTest() {
        String errorMsg = 'Some Validation Message';
        loadSaveCaseCalloutsMock(new SaveCaseErrorMock(errorMsg));

        AFEnrollService.SaveEnrollmentCaseRequest request = new AFEnrollService.SaveEnrollmentCaseRequest();
        request.AccountName = 'Some Account';
        request.MCPNumber = '19388';
        request.AdditionalMCPsCommaSeparated = '19387,18199';

        AFEnrollService.SaveEnrollmentCaseResponse response = saveEnrollmentCase(request);
        
        assertErrorMessage(response, errorMsg);
    }

    @isTest
    static void saveEnrollmentCase_saveFailedFromTooManyMCPsError_expectNonErrorResponseWithMessageTest() {
        // A bug came through where if there's more than 10 MCPs, AFEnroll doesn't allow the case to be created.
        // Charlotte Loveland said that's expected and those will be handled manually and no error notification is
        // needed. This test is supposed to confirm that if that error comes back then the code doesn't mark it as
        // an error so no notification is sent. Luke Freeland 3/12/2019

        String maxMCPsExceededError = AFEnrollService.MAX_MCPS_EXCEEDED_ERROR;
        loadSaveCaseCalloutsMock(new SaveCaseErrorMock(maxMCPsExceededError));

        AFEnrollService.SaveEnrollmentCaseRequest request = new AFEnrollService.SaveEnrollmentCaseRequest();
        request.AccountName = 'Some Account';
        request.MCPNumber = '19388';
        request.AdditionalMCPsCommaSeparated = '19387,18199,18200,18201,18202,18203,18204,18205,18206,18207';

        AFEnrollService.SaveEnrollmentCaseResponse response = saveEnrollmentCase(request);
        
        system.assert(response.Success, 'The response should be successful despite the max number of MCPs exceeded error. Message: ' + response.Message);
        
        List<Integration_Log__c> logs =
        [SELECT Id,
                Severity__c
           FROM Integration_Log__c];

        system.assert(logs.size() > 0, 'There should be some integration logs.');
        
        for (Integration_Log__c log : logs) {
            system.assertEquals('INFO', log.Severity__c, 'The log should have an INFO severity.');
        }
    }

    @isTest
    static void buildSaveEnrollmentCaseRequest_dedupeAdditionalMCPsAndAdditionalMCPsHasDupes_expectDuplicateMCPsRemovedTest() {
        String duplicateAdditionalMCP = '19387';

        AFEnrollService.SaveEnrollmentCaseRequest request = new AFEnrollService.SaveEnrollmentCaseRequest();
        request.AccountName = 'Some Account';
        request.MCPNumber = '19388';
        request.AdditionalMCPsCommaSeparated = duplicateAdditionalMCP + ',' + duplicateAdditionalMCP;
        request.DedupeAdditionalMCPs = true;

        String jsonRequest = new AFEnrollService().buildSaveEnrollmentCaseRequestBody(request);
        List<Object> additionalMCPs = parseAdditionalMCPsFromJSONRequest(jsonRequest);

        system.assert(additionalMCPs != null, 'The list of additional mcps is null.');
        system.assertEquals(1, additionalMCPs.size(), 'There should only be one additional MCP.');
        system.assertEquals(duplicateAdditionalMCP, additionalMCPs[0], 'The additional mcp is not the expected one.');
    }

    @isTest
    static void buildSaveEnrollmentCaseRequest_dontDedupeAdditionalMCPsAndAdditionalMCPsHasDupes_expectDuplicateMCPsKeptTest() {
        String duplicateAdditionalMCP = '19387';

        AFEnrollService.SaveEnrollmentCaseRequest request = new AFEnrollService.SaveEnrollmentCaseRequest();
        request.AccountName = 'Some Account';
        request.MCPNumber = '19388';
        request.AdditionalMCPsCommaSeparated = duplicateAdditionalMCP + ',' + duplicateAdditionalMCP;
        request.DedupeAdditionalMCPs = false;

        String jsonRequest = new AFEnrollService().buildSaveEnrollmentCaseRequestBody(request);
        List<Object> additionalMCPs = parseAdditionalMCPsFromJSONRequest(jsonRequest);

        system.assert(additionalMCPs != null, 'The list of additional mcps is null.');
        system.assertEquals(2, additionalMCPs.size(), 'There should only be two additional MCPs.');
        system.assertEquals(duplicateAdditionalMCP, additionalMCPs[0], 'The additional mcp is not the expected one.');
    }

    @isTest
    static void buildSaveEnrollmentCaseRequest_dedupeAdditionalMCPsAndAdditionalMCPsHasPrimaryMCP_expectPrimaryMCPRemovedTest() {
        String additionalMCP = '19387';
        String primaryMCP = '22198';

        AFEnrollService.SaveEnrollmentCaseRequest request = new AFEnrollService.SaveEnrollmentCaseRequest();
        request.AccountName = 'Some Account';
        request.MCPNumber = primaryMCP;
        request.AdditionalMCPsCommaSeparated = additionalMCP + ',' + primaryMCP;
        request.DedupeAdditionalMCPs = true;

        String jsonRequest = new AFEnrollService().buildSaveEnrollmentCaseRequestBody(request);
        List<Object> additionalMCPs = parseAdditionalMCPsFromJSONRequest(jsonRequest);

        system.assert(additionalMCPs != null, 'The list of additional mcps is null.');
        system.assertEquals(1, additionalMCPs.size(), 'There should only be one additional MCPs.');
        system.assertEquals(additionalMCP, additionalMCPs[0], 'The additional mcp is not the expected one since the primary MCP was not removed.');
    }

    @isTest
    static void buildSaveEnrollmentCaseRequest_dedupeAdditionalMCPsAndAdditionalMCPsHasOnlyPrimaryMCP_expectPrimaryMCPRemovedTest() {
        String additionalMCP = '19387';
        String primaryMCP = '22198';

        AFEnrollService.SaveEnrollmentCaseRequest request = new AFEnrollService.SaveEnrollmentCaseRequest();
        request.AccountName = 'Some Account';
        request.MCPNumber = primaryMCP;
        request.AdditionalMCPsCommaSeparated = primaryMCP;
        request.DedupeAdditionalMCPs = true;

        String jsonRequest = new AFEnrollService().buildSaveEnrollmentCaseRequestBody(request);
        List<Object> additionalMCPs = parseAdditionalMCPsFromJSONRequest(jsonRequest);

        system.assert(additionalMCPs != null, 'The list of additional mcps is null.');
        system.assertEquals(0, additionalMCPs.size(), 'There should only be no additional MCPs.');
    }
    
    static AFEnrollService.SaveEnrollmentCaseResponse saveEnrollmentCase(AFEnrollService.SaveEnrollmentCaseRequest request) {
        Test.startTest();
        AFEnrollService.SaveEnrollmentCaseResponse response =
            new AFEnrollService().saveEnrollmentCase(request);
        Test.stopTest();
        
        return response;
    }
    
    static void assertErrorMessage(AFEnrollService.SaveEnrollmentCaseResponse response, String expectedErrorMsg) {
        system.assert(response != null, 'The save enrollment case response is null.');
        system.assertEquals(false, response.Success, 'The response is successful when it should not be.');
        system.assertEquals(expectedErrorMsg, response.Message, 'The response is successful when it should not be.');
    }

    static void assertSaveCaseSuccessful(AFEnrollService.SaveEnrollmentCaseResponse response) {
        system.assert(response != null, 'The save enrollment case response is null.');
        system.assertEquals(true, response.Success, 'The response is not successful when it should be. Error: ' + response.Message);
        system.assert(String.isNotBlank(response.AFEnrollCaseId), 'There should be an AFEnroll Case Id.');
    }

    static void loadSaveCaseCalloutsMock(HttpCalloutMock esbAuthMock, HttpCalloutMock saveCaseMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, esbAuthMock);
        
        requests.put(DEFAULT_ENDPOINT + AFEnrollService.ENROLLMENT_SAVE_API_PATH, saveCaseMock);
        
        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    static void loadSaveCaseCalloutsMock(HttpCalloutMock saveCaseMock) {
        loadSaveCaseCalloutsMock(new ESBAuthenticatorTest.AuthenticateSuccessfulMock(), saveCaseMock);
    }
    
    public static List<Object> parseAdditionalMCPsFromJSONRequest(String jsonRequest) {
        List<String> additionalMCPs = new List<String>();
		Integer additionalMCPsListIndex = jsonRequest.indexOf('"AdditionalMCPsList"');
		Integer leftBraceIndex = jsonRequest.indexOf('[', additionalMCPsListIndex);
		Integer rightBraceIndex = jsonRequest.indexOf(']', additionalMCPsListIndex);
		
		String additionalMCPsArrayString = jsonRequest.substring(leftBraceIndex + 1, rightBraceIndex);
		
		if (String.isNotBlank(additionalMCPsArrayString)) {
		    String additionalMCPsArrayNoWhiteSpace = additionalMCPsArrayString.deleteWhitespace().remove('{').remove('}');
		
		    String[] additionalMCPsParts = additionalMCPsArrayNoWhiteSpace.split(',');
		
		    for (String additionalMCPPart : additionalMCPsParts) {
		        String additionalMCP = additionalMCPPart.remove('"AdditionalMcps":').remove('"');
		        
		        additionalMCPs.add(additionalMCP);
		    }
		}
        
        return additionalMCPs;
    }

    public with sharing class SaveCaseSuccessfulMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '{"Id":"bb42491d-7558-4228-80d2-abc8883ebe28"}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(body);
            
            return res;
        }
    }

    public with sharing class SaveCaseErrorMock implements HTTPCalloutMock {
        private String ErrorMsg { get; set; }
        
        public SaveCaseErrorMock(String error) {
            ErrorMsg = error;
        }
        
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            res.setBody(ErrorMsg);
            
            return res;
        }
    }
}