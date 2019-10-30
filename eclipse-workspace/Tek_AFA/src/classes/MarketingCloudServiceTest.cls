@isTest
public with sharing class MarketingCloudServiceTest {
    private static String REST_INSTANCE_DEFAULT_URL = MarketingCloudService.TESTS_REST_INSTANCE_DEFAULT_URL;
    
    @testSetup
    static void setup() {
        EmailBuilderSettingsTestData.Instance.insertEmailBuilderSettings();
    }
    
    @isTest
    static void authenticate_authenticationSuccessful_expectAccessTokenAvailableTest() {
        String accessToken = 'MySuccessfulAuth';

        loadCalloutMocks(new AuthSuccessfulMock(accessToken), null, '');

        MarketingCloudService service = new MarketingCloudService();

        Test.startTest();        

        service.authenticate();
        
        Test.stopTest();
        
        system.assert(String.isNotBlank(service.AccessToken), 'The access token is blank.');
        system.assertEquals(accessToken, service.AccessToken, 'The access token is not the expected one.');
    }

    @isTest
    static void authenticate_authenticationSuccessfulAndAuthenticationInvokedAgain_expectAccessTokenStillTheSameTest() {
        String accessToken = 'MySuccessfulAuth';
        String otherAccessToken = 'MyOtherSuccessfulAuth';

        Test.startTest();
        
        loadCalloutMocks(new AuthSuccessfulMock(accessToken), null, '');

        MarketingCloudService service = new MarketingCloudService();        

        service.authenticate();
        
        loadCalloutMocks(new AuthSuccessfulMock(otherAccessToken), null, '');
        
        service.authenticate();
        
        Test.stopTest();
        
        system.assert(String.isNotBlank(service.AccessToken), 'The access token is blank.');
        system.assertEquals(accessToken, service.AccessToken, 'The access token is not the expected one.');
    }
    
    @isTest
    static void authenticate_authenticationFailed_expectNoAccessTokenAndErrorIntegrationLogTest() {
        loadCalloutMocks(new AuthUnauthorizedErrorMock(), null, '');

        MarketingCloudService service = new MarketingCloudService();

        Test.startTest();        

        service.authenticate();
        
        Test.stopTest();
        
        system.assert(String.isBlank(service.AccessToken), 'The access token should be blank.');
        
        assertErrorIntegrationLogFound();
    }
    
    @isTest
    static void getEmailTemplatesInCategory_noEmailTemplatesFound_expectNoEmailTemplatesFoundTest() {
        loadAfterAuthCalloutMock(new GetEmailTemplatesInCategoryNoEmailTemplatesMock(), MarketingCloudService.ASSETS_QUERY_PATH);
        
        String nonExistentCategoryId = 'ABC123';
        
        Test.startTest();
        
        MarketingCloudService.EmailTemplatesContext context = new MarketingCloudService().getEmailTemplatesInCategory(nonExistentCategoryId);
        
        Test.stopTest();
        
        system.assert(context.EmailTemplates != null, 'The category email templates are null.');
        system.assertEquals(0, context.EmailTemplates.size(), 'There should be no category email templates.');
        
        assertErrorIntegrationLogFound();
    }

    @isTest
    static void getEmailTemplatesInCategory_oneEmailTemplateFound_expectOneEmailTemplateFoundTest() {
        loadAfterAuthCalloutMock(new GetEmailTemplatesInCategoryOneEmailTemplateMock(), MarketingCloudService.ASSETS_QUERY_PATH);
        
        String categoryId = 'ABC123';
        
        Test.startTest();
        
        MarketingCloudService.EmailTemplatesContext context = new MarketingCloudService().getEmailTemplatesInCategory(categoryId);
        
        Test.stopTest();
        
        system.assert(context.EmailTemplates != null, 'The category email templates are null.');
        system.assertEquals(1, context.EmailTemplates.size(), 'There should be one category email template.');
        
        assertNoErrorIntegrationLogsFound();
    }
    
    @isTest
    static void getEmailPreviewHTML_emailIdBlank_expectBlankEmailPreviewHTMLTest() {
        String blankEmailId = '';
        
        MarketingCloudService.EmailPreviewContext context = new MarketingCloudService().getEmailPreviewHTML(blankEmailId, new Map<String, Object>());
        
        system.assert(String.isBlank(context.EmailPreviewHTML), 'There should be no email preview HTML for a blank email id.');
    }
    
    @isTest
    static void getEmailPreviewHTML_emailIdSuppliedAndExistsButInsertPreviewExtensionError_expectNoEmailPreviewHTMLFoundTest() {
        String existsEmailId = '93817';
        
        Test.startTest();
        
        MarketingCloudService mcs = new MarketingCloudService();
        String toEmail = mcs.buildCurrentUserPreviewSubscriberKey();
        String insertPreviewEmailEndpointURL = mcs.buildInsertPreviewDataExtensionURL(existsEmailId, toEmail);
        
        loadAfterAuthCalloutMock(new insertEmailBuilderPreviewBadRequestMock(), insertPreviewEmailEndpointURL);
        
        MarketingCloudService.EmailPreviewContext context = new MarketingCloudService().getEmailPreviewHTML(existsEmailId, new Map<String, Object>());
        
        Test.stopTest();
        
        system.assert(String.isBlank(context.EmailPreviewHTML), 'There should be no email preview HTML.');
        assertErrorIntegrationLogFound();
    }

    @isTest
    static void getEmailPreviewHTML_emailIdSuppliedAndExistsAndEmailPreviewGenerated_expectEmailPreviewHTMLFoundTest() {
        String existsEmailId = '93817';
        
        Test.startTest();
        
        MockMetadata insertEmailPreviewDataExtensionMockData = new MockMetadata();
        MarketingCloudService mcs = new MarketingCloudService();
        String toEmail = mcs.buildCurrentUserPreviewSubscriberKey();
        
        insertEmailPreviewDataExtensionMockData.Endpoint = mcs.buildInsertPreviewDataExtensionURL(existsEmailId, toEmail);
        insertEmailPreviewDataExtensionMockData.Mock = new insertEmailBuilderPreviewSuccessMock();
        
        MockMetadata getPreviewHTMLMockData = new MockMetadata();
        getPreviewHTMLMockData.Endpoint = mcs.buildGetPreviewEmailHTMLURL(existsEmailId, toEmail);
        getPreviewHTMLMockData.Mock = new GetPreviewHTMLSuccessMock();
        
        loadAfterAuthCalloutMocks(new List<MockMetadata>{ insertEmailPreviewDataExtensionMockData, getPreviewHTMLMockData });
        
        MarketingCloudService.EmailPreviewContext context = new MarketingCloudService().getEmailPreviewHTML(existsEmailId, new Map<String, Object>());
        
        Test.stopTest();
        
        system.assert(String.isNotBlank(context.EmailPreviewHTML), 'There should be email preview HTML.');
        assertNoErrorIntegrationLogsFound();
    }

    @isTest
    static void getEmailPreviewHTML_emailIdSuppliedAndExistsAndBadRequestError_expectEmailPreviewHTMLNotFoundTest() {
        String existsEmailId = '93817';
        
        Test.startTest();
        
        MockMetadata insertEmailPreviewDataExtensionMockData = new MockMetadata();
        MarketingCloudService mcs = new MarketingCloudService();
        String toEmail = mcs.buildCurrentUserPreviewSubscriberKey();
        
        insertEmailPreviewDataExtensionMockData.Endpoint = mcs.buildInsertPreviewDataExtensionURL(existsEmailId, toEmail);
        insertEmailPreviewDataExtensionMockData.Mock = new insertEmailBuilderPreviewSuccessMock();
        
        MockMetadata getPreviewHTMLMockData = new MockMetadata();
        getPreviewHTMLMockData.Endpoint = mcs.buildGetPreviewEmailHTMLURL(existsEmailId, toEmail);
        getPreviewHTMLMockData.Mock = new GetPreviewHTMLBadRequestErrorMock();
        
        loadAfterAuthCalloutMocks(new List<MockMetadata>{ insertEmailPreviewDataExtensionMockData, getPreviewHTMLMockData });
        
        MarketingCloudService.EmailPreviewContext context = new MarketingCloudService().getEmailPreviewHTML(existsEmailId, new Map<String, Object>());
        
        Test.stopTest();
        
        system.assert(String.isBlank(context.EmailPreviewHTML), 'There should be no email preview HTML.');
        assertErrorIntegrationLogFound();
    }
    
    @isTest
    static void sendEmail_errorSendingRequest_expectEmailNotSentTest() {
        String existsEmailId = '93817';
        
        Test.startTest();
        
        MarketingCloudService mcs = new MarketingCloudService();
        String toEmail = mcs.buildCurrentUserPreviewSubscriberKey();
        String noCCEmail = '';
        
        MockMetadata sendEmailErrorMockData = new MockMetadata();
        sendEmailErrorMockData.Endpoint = mcs.buildSendEmailURL();
        sendEmailErrorMockData.Mock = new SendEmailBadRequestErrorMock();
        
        loadAfterAuthCalloutMocks(new List<MockMetadata>{ sendEmailErrorMockData });
        
        String sendEmailResult = new MarketingCloudService().sendEmail(existsEmailId, toEmail, new Map<String, Object>(), noCCEmail);
        
        Test.stopTest();
        
        system.assertNotEquals(MarketingCloudService.SENT_EMAIL_SUCCESS_MSG, sendEmailResult, 'The email was sent when it should not be.');
        assertErrorIntegrationLogFound();
    }

    @isTest
    static void sendEmail_emailSentSuccessfully_expectEmailSentSuccessfullyMessageTest() {
        String existsEmailId = '93817';
        String noCCEmail = '';
        
        Test.startTest();
        
        MarketingCloudService mcs = new MarketingCloudService();
        String toEmail = mcs.buildCurrentUserPreviewSubscriberKey();
        
        MockMetadata sendEmailSuccessMockData = new MockMetadata();
        sendEmailSuccessMockData.Endpoint = mcs.buildSendEmailURL();
        sendEmailSuccessMockData.Mock = new SendEmailSuccessMock();
        
        loadAfterAuthCalloutMocks(new List<MockMetadata>{ sendEmailSuccessMockData });
        
        String sendEmailResult = new MarketingCloudService().sendEmail(existsEmailId, toEmail, new Map<String, Object>(), noCCEmail);
        
        Test.stopTest();
        
        system.assertEquals(MarketingCloudService.SENT_EMAIL_SUCCESS_MSG, sendEmailResult, 'The email was not sent when it should be.');
        assertNoErrorIntegrationLogsFound();
    }

    public static void loadCalloutMocks(HttpCalloutMock authMock, HttpCalloutMock otherCalloutMock, String otherCalloutURL) {
        MockMetadata afterAuthCalloutMockData = new MockMetadata();
        afterAuthCalloutMockData.Endpoint = otherCalloutURL;
        afterAuthCalloutMockData.Mock = otherCalloutMock;
        
        loadCalloutMocks(authMock, new List<MockMetadata>{ afterAuthCalloutMockData });
    }

    public static void loadCalloutMocks(HttpCalloutMock authMock, List<MockMetadata> afterAuthMocks) {
        Email_Builder_Settings__c settings = Email_Builder_Settings__c.getOrgDefaults();
        
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(settings.Authentication_URL__c + MarketingCloudService.AUTHENTICATION_PATH, authMock);
        
        for (MockMetadata afterAuthMockData : afterAuthMocks) {
            system.debug('    loadCalloutMocks::afterAuthMockData: ' + afterAuthMockData);
            
            String afterCalloutURLToUse = afterAuthMockData.Endpoint;
        
	        if (afterCalloutURLToUse.startsWith('/') ||
	            afterCalloutURLToUse.startsWith('null')) {
	            afterCalloutURLToUse = REST_INSTANCE_DEFAULT_URL + afterCalloutURLToUse;
	        }
	        
	        requests.put(afterCalloutURLToUse, afterAuthMockData.Mock);
        }
        
        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    public static void loadAfterAuthCalloutMock(HttpCalloutMock afterAuthCalloutMock, String calloutURLPath) {
        MockMetadata afterAuthCalloutMockData = new MockMetadata();
        afterAuthCalloutMockData.Endpoint = calloutURLPath;
        afterAuthCalloutMockData.Mock = afterAuthCalloutMock;
        
        loadCalloutMocks(new AuthSuccessfulMock(), new List<MockMetadata>{ afterAuthCalloutMockData });
    }
    
    public static void loadAfterAuthCalloutMocks(List<MockMetaData> mocks) {
        loadCalloutMocks(new AuthSuccessfulMock(), mocks);
    }
    
    static void assertErrorIntegrationLogFound() {
        List<Integration_Log__c> intLogs = getIntegrationLogs();

        system.assert(intLogs.size() > 0, 'There should be an integration log.');
        
        Boolean errorLogFound = false;
        
        for (Integration_Log__c intLog : intLogs) {
            if (String.isNotBlank(intLog.Severity__c) &&
                intLog.Severity__c == IntegrationLogger.INTEGRATION_LOG_SEVERITY_ERROR) {
                errorLogFound = true;
            }
        }
        
        system.assert(errorLogFound, 'There should be an error log.');
    }
    
    static void assertNoErrorIntegrationLogsFound() {
        List<Integration_Log__c> intLogs = getIntegrationLogs();
        
        system.assert(intLogs.size() > 0, 'There should be an integration log.');
        
        Boolean errorLogFound = false;
        
        for (Integration_Log__c intLog : intLogs) {
            if (String.isNotBlank(intLog.Severity__c) &&
                intLog.Severity__c == IntegrationLogger.INTEGRATION_LOG_SEVERITY_ERROR) {
                errorLogFound = true;
            }
        }
        
        system.assertEquals(false, errorLogFound, 'There should be no error logs.');
    }
    
    static List<Integration_Log__c> getIntegrationLogs() {
        List<Integration_Log__c> intLogs =
        [SELECT Id,
                Name,
                Severity__c
           FROM Integration_Log__c];

        intLogs.addAll(IntegrationLogger.Instance.Logs);
        
        return intLogs;
    }

    public with sharing class AuthSuccessfulMock implements HTTPCalloutMock {
        public String AccessToken { get; set; }
        
        public AuthSuccessfulMock(String accessTokenToUse) {
            AccessToken = accessTokenToUse;
        }
        
        public AuthSuccessfulMock() {
            AccessToken = 'AccessTokenSuccess';
        }
        
        public HTTPResponse respond(HTTPRequest req){
            String body = '{' +
                              '"access_token": "' + AccessToken + '",' +
                              '"legacy_token": "LegacyAccessToken",' +
                              '"token_type": "Bearer",' +
                              '"expires_in": 1079,' +
                              '"scope": "offline documents_and_images_read documents_and_images_write saved_content_read saved_content_write automations_execute automations_read automations_write journeys_execute journeys_read journeys_write email_read email_send email_write push_read push_send push_write sms_read sms_send sms_write social_post social_publish social_read social_write web_publish web_read web_write audiences_read audiences_write list_and_subscribers_read list_and_subscribers_write data_extensions_read data_extensions_write file_locations_read file_locations_write tracking_events_read calendar_read calendar_write campaign_read campaign_write accounts_read users_read webhooks_read webhooks_write workflows_write approvals_write tags_write approvals_read tags_read workflows_read ott_chat_messaging_read ott_chat_messaging_send ott_channels_read marketing_cloud_connect_read marketing_cloud_connect_write marketing_cloud_connect_send event_notification_callback_create event_notification_callback_read event_notification_callback_update event_notification_callback_delete event_notification_subscription_create event_notification_subscription_read event_notification_subscription_update event_notification_subscription_delete",' +
                              '"soap_instance_url": "https://mc4xmnpwj1tc1r7398.soap.marketingcloudapis.com/",' +
                              '"rest_instance_url": "' + REST_INSTANCE_DEFAULT_URL + '",' +
                              '"legacy_api_instance_url": "https://rest.s7.exacttarget.com/"' +
                          '}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(body);
            
            return res;
        }
    }

    public with sharing class AuthUnauthorizedErrorMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '{' +
                              '"error":"invalid_client",' +
                              '"error_description":"Client authentication failed. Make sure that the client ID and client secret are valid.","error_uri":"https://developer.salesforce.com/docs"' +
                           '}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(401);
            res.setBody(body);
            
            return res;
        }
    }
    
    public with sharing class GetEmailTemplatesInCategoryNoEmailTemplatesMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '{' +
                              '"message":"Internal Server Error",' +
                              '"errorcode":0,' +
                              '"documentation":"https://developer.salesforce.com/docs/atlas.en-us.mc-apis.meta/mc-apis/error-handling.htm"' +
                           '}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            res.setBody(body);
            
            return res;
        }
    }

    public with sharing class GetEmailTemplatesInCategoryOneEmailTemplateMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '{' +
                              '"count":1,' +
                              '"page":1,' +
                              '"pageSize":50,' +
                              '"links":{},' +
                              '"items":[{' +
                                  '"customerKey": "CUST123", ' +
                                  '"name": "PEM TTE Prototype", ' +
                                  '"description": "PEM TTE Prototype Description", ' +
                                  '"legacyData": { "legacyId": "938198" }, ' +
                                  '"views": { ' +
                                      '"html": {' +
                                          '"slots": {}' +
                                      '}' +
                                  '}' +
                              '}]' +
                           '}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(body);
            
            return res;
        }
    }
    
    public with sharing class insertEmailBuilderPreviewBadRequestMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '{' +
                              '"message":"Bad Request",' +
                              '"errorcode":0,' +
                              '"documentation":"https://developer.salesforce.com/docs/atlas.en-us.mc-apis.meta/mc-apis/error-handling.htm"' +
                           '}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            res.setBody(body);
            
            return res;
        }
    }

    public with sharing class insertEmailBuilderPreviewSuccessMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = req.getBody();
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(body);
            
            return res;
        }
    }
    
    public with sharing class GetPreviewHTMLSuccessMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '{' +
                              '"message":{' +
                                  '"views": [{ ' +
                                      '"content": "<html>Email Preview</html>"' +
                                  '}]' +
                              '}' +
                           '}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(body);
            
            return res;
        }
    }

    public with sharing class GetPreviewHTMLBadRequestErrorMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '{' +
                              '"message":"Bad Request",' +
                              '"errorcode":0,' +
                              '"documentation":"https://developer.salesforce.com/docs/atlas.en-us.mc-apis.meta/mc-apis/error-handling.htm"' +
                           '}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            res.setBody(body);
            
            return res;
        }
    }
    
    public with sharing class SendEmailBadRequestErrorMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '{' +
                              '"message":"Bad Request",' +
                              '"errorcode":0,' +
                              '"documentation":"https://developer.salesforce.com/docs/atlas.en-us.mc-apis.meta/mc-apis/error-handling.htm"' +
                           '}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            res.setBody(body);
            
            return res;
        }
    }
    
    public with sharing class SendEmailSuccessMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '{"eventInstanceId":"cd1B91k8-b59d-4d8c-87ca-21c221245ff7"}';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(201);
            res.setBody(body);
            
            return res;
        }
    }
    
    public with sharing class MockMetaData {
        public String Endpoint { get; set; }
        
        public HTTPCalloutMock Mock { get; set; }
    }
}