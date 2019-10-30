@isTest
public with sharing class ESBMicrositeAsyncRequestHandlerTest {
    private static final String DEFAULT_ENDPOINT = 'https://api-qa.americanfidelity.com:443';
    
    @testSetup
    static void setup() {
        API_Manager__c sandboxAPI = new API_Manager__c();
        sandboxAPI.Name = ESBServiceBase.SANDBOX_PREENROLLMENT_MARKETING_API_MANAGER_NAME;
        sandboxAPI.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        sandboxAPI.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        sandboxAPI.Endpoint__c = DEFAULT_ENDPOINT;
        sandboxAPI.Host__c = 'api-qa.americanfidelity.com:443';
        sandboxAPI.Username__c = 'Username';
        sandboxAPI.Password__c = 'Password';
        insert sandboxAPI;
        
        API_Manager__c productionAPI = sandboxAPI.clone(false, true);
        productionAPI.Name = ESBServiceBase.PRODUCTION_PREENROLLMENT_MARKETING_API_MANAGER_NAME;
        
        insert productionAPI;
    }
    
    static List<Integration_Log__c> getIntegrationLogs() {
        return
        [SELECT Id,
                Name,
                Request__c,
                Response__c,
                Message__c,
                Severity__c
           FROM Integration_Log__c
          Order By CreatedDate];
    }
    
    static Integration_Log__c getMicrositeLog(List<Integration_Log__c> integrationLogs) {
        for (Integration_Log__c integrationLog : integrationLogs) {
            system.debug('    getEmployerUpsertLog::integrationLog ' + integrationLog);
            
            if (string.isNotBlank(integrationLog.Request__c) &&
                integrationLog.Request__c.containsIgnoreCase(ESBMicrositeServiceClient.MICROSITE_PATH)) {
                return integrationLog;
            }
        }
        
        return null;
    }
    
    @isTest
    static void handleRequest_noPreenrollmentMarketingFormIdId_expectPreenrollmentMarketingFormIdRequiredValidationMessageTest() {
        Async_Request__c asyncRequest = AsyncRequestTestData.Instance.withOperationClass('ESBMicrositeAsyncRequestHandler').insertAsyncRequest();
        Exception ex = null;
        
        try {
            ESBMicrositeAsyncRequestHandler handler = new ESBMicrositeAsyncRequestHandler();
            handler.handleRequest(asyncRequest);
        }
        catch(Exception e) {
            ex = e;
        }
        
        system.assert(ex != null, 'An error should have been thrown.');
        system.assert(ex.getMessage().containsIgnoreCase(ESBMicrositeServiceClient.PREENROLLMENT_MARKETING_FORM_ID_REQUIRED_MESSAGE), 'The expected error was not found. Error found: ' + ex.getMessage());
    }
    
    @isTest
    static void handleRequest_MarketingFormIdSupplied_expectMicrositeQueuedTest() {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        requests.put(DEFAULT_ENDPOINT + ESBMicrositeServiceClient.MICROSITE_PATH, new MicrositeUpsertSuccessfulMock());
        
        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
        
        Pre_Enrollment_Marketing_Form__c marketingForm = PreenrollmentMarketingFormTestData.Instance.insertPreenrollmentMarketingForm();
        system.assert(marketingForm.Id != null, 'The marketing form was not inserted.');     
        
        Async_Request__c asyncRequest = AsyncRequestTestData.Instance.withOperationClass('ESBMicrositeAsyncRequestHandler')
                                                                     .withParameters(marketingForm.Id).insertAsyncRequest();

        system.assertEquals(marketingForm.Id, asyncRequest.Parameters__c, 'The async parameters is not the marketing form id.');

        Test.startTest();
        ESBMicrositeAsyncRequestHandler handler = new ESBMicrositeAsyncRequestHandler();
        handler.handleRequest(asyncRequest);
        Test.stopTest();
        
        List<Integration_Log__c> integrationLogs = getIntegrationLogs();
        
        system.assertEquals(2, integrationLogs.size(), '2 integration logs should be queried.');
        
        Integration_Log__c micrositeUpsertLog = getMicrositeLog(integrationLogs);
        
        system.assert(micrositeUpsertLog != null, 'The microsite upsert log was not found.');
        
        system.assert(String.isNotBlank(micrositeUpsertLog.Response__c), 'There was no response from the server. Message: ' + micrositeUpsertLog.Message__c);
        system.assert(micrositeUpsertLog.Response__c.containsIgnoreCase('"RequestQueued":true'), 'The request was not queued successfully.');
    }
    
    @isTest
    static void handleRequest_enrollmentOpportunityWithErrors_expectEmployerUpsertNotQueuedAndErrorsLoggedTest() {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        
        String micrositeUpsertError = 'Some validation error';
        
        requests.put(DEFAULT_ENDPOINT + ESBMicrositeServiceClient.MICROSITE_PATH, new MicrositeUpsertFailedMock(micrositeUpsertError));
        
        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
        
        Pre_Enrollment_Marketing_Form__c marketingForm = PreenrollmentMarketingFormTestData.Instance.insertPreenrollmentMarketingForm();
        
        Async_Request__c asyncRequest = AsyncRequestTestData.Instance.withOperationClass('ESBMicrositeAsyncRequestHandler')
                                                                     .withParameters(marketingForm.Id).insertAsyncRequest();

        Test.startTest();
        ESBMicrositeAsyncRequestHandler handler = new ESBMicrositeAsyncRequestHandler();
        handler.handleRequest(asyncRequest);
        Test.stopTest();
        
        List<Integration_Log__c> integrationLogs = getIntegrationLogs();
        
        system.assertEquals(2, integrationLogs.size(), '2 integration logs should be queried.');
        
        Integration_Log__c micrositeUpsertLog = getMicrositeLog(integrationLogs);
        
        system.assert(micrositeUpsertLog != null, 'The microsite upsert log was not found.');
        
        system.assert(String.isNotBlank(micrositeUpsertLog.Response__c), 'There was no response from the server. Message: ' + micrositeUpsertLog.Message__c);
        system.assert(micrositeUpsertLog.Response__c.containsIgnoreCase('"RequestQueued":false'), 'The request was queued successfully.');
        system.assert(micrositeUpsertLog.Response__c.containsIgnoreCase(micrositeUpsertError), 'The error was not logged.');
        system.assertEquals('ERROR', micrositeUpsertLog.Severity__c, 'The severity should be error on the log.');
    }
    
    @isTest
    static void handleRequest_MarketingFormIdSuppliedAndEmployerBenefitsSiteNo_expectMicrositeQueuedAndNoMarketedProductsSentTest() {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        requests.put(DEFAULT_ENDPOINT + ESBMicrositeServiceClient.MICROSITE_PATH, new MicrositeUpsertSuccessfulMock());
        
        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
        
        Pre_Enrollment_Marketing_Form__c marketingForm = PreenrollmentMarketingFormTestData.Instance.insertPreenrollmentMarketingForm();
        system.assert(marketingForm.Id != null, 'The marketing form was not inserted.');
        system.assert(marketingForm.Enrollment_Form__c != null, 'The enrollment form is blank.');
        
        String productResourceId = '32f5d925-295c-4913-b34d-36ecbb83bc1f';
        
        Product_Catalog__c someProduct = ProductCatalogTestData.Instance.withResourceId(productResourceId).insertProductCatalog();
        Marketed_Product__c someMP = MarketedProductTestData.Instance.withProductCatalog(someProduct.Id)
                                                                     .withEnrollmentForm(marketingForm.Enrollment_Form__c)
                                                                     .withIncludeOnEmployerBenefitsSite(true)
                                                                     .insertMarketedProduct();
                                                                     
        Marketed_Product__c someMPQueried = [SELECT Include_On_Employer_Benefits_Site__c
                                               FROM Marketed_Product__c
                                              WHERE Id = :someMP.Id];
        system.assertEquals(true, someMPQueried.Include_On_Employer_Benefits_Site__c, 'The include on employer benefits site should be true');

        Opportunity enrollmentOpp =
        [SELECT Id,
                Employer_Benefits_Site__c
           FROM Opportunity
          WHERE Id in (SELECT Enrollment_Opportunity__c
                         FROM Enrollment_Form__c
                        WHERE Id = :marketingForm.Enrollment_Form__c)];

        enrollmentOpp.Employer_Benefits_Site__c = 'No';
        update enrollmentOpp;

        
        Async_Request__c asyncRequest = AsyncRequestTestData.Instance.withOperationClass('ESBMicrositeAsyncRequestHandler')
                                                                     .withParameters(marketingForm.Id).insertAsyncRequest();

        system.assertEquals(marketingForm.Id, asyncRequest.Parameters__c, 'The async parameters is not the marketing form id.');

        Test.startTest();
        ESBMicrositeAsyncRequestHandler handler = new ESBMicrositeAsyncRequestHandler();
        handler.handleRequest(asyncRequest);
        Test.stopTest();
        
        List<Integration_Log__c> integrationLogs = getIntegrationLogs();
        
        system.assertEquals(2, integrationLogs.size(), '2 integration logs should be queried.');
        
        Integration_Log__c micrositeUpsertLog = getMicrositeLog(integrationLogs);
        
        system.assert(micrositeUpsertLog != null, 'The microsite upsert log was not found.');
        system.assertEquals('INFO', micrositeUpsertLog.Severity__c, 'The microsite upsert errored with message: ' + micrositeUpsertLog.Message__c);
        system.assert(String.isNotBlank(micrositeUpsertLog.Request__c), 'The request is blank');
        system.assertEquals(false, micrositeUpsertLog.Request__c.containsIgnoreCase(productResourceId), 'The marketed product was sent when it should not have been.');
    }
    
    public with sharing class MicrositeUpsertSuccessfulMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"RequestQueued":true,"Errors":[],"Status":"OK","TimeTaken":0}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public with sharing class MicrositeUpsertFailedMock implements HttpCalloutMock {
        private String failureError { get; set; }
        
        public MicrositeUpsertFailedMock(String error) {
            failureError = error;
        }
        
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"RequestQueued":false,"Errors":["' + failureError + '"],"Status":"Error","TimeTaken":0}');
            res.setStatusCode(500);
            return res;
        }
    }
}