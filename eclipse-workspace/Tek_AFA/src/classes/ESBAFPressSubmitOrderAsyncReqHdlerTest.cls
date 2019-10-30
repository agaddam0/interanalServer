@isTest
public with sharing class ESBAFPressSubmitOrderAsyncReqHdlerTest {
    private static final String DEFAULT_ENDPOINT = 'https://api-qa.americanfidelity.com:443';

    @testSetup
    static void setup() {
        API_Manager__c sandboxAPI = new API_Manager__c();
        sandboxAPI.Name = ESBServiceBase.SANDBOX_AFPRESS_API_MANAGER_NAME;
        sandboxAPI.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        sandboxAPI.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        sandboxAPI.Endpoint__c = DEFAULT_ENDPOINT;
        sandboxAPI.Host__c = 'api-qa.americanfidelity.com:443';
        sandboxAPI.Username__c = 'Username';
        sandboxAPI.Password__c = 'Password';
        insert sandboxAPI;
        
        API_Manager__c productionAPI = sandboxAPI.clone(false, true);
        productionAPI.Name = ESBServiceBase.PRODUCTION_AFPRESS_API_MANAGER_NAME;
        
        insert productionAPI;
        
        AFPress_Settings__c afPressSettings = new AFPress_Settings__c();
        afPressSettings.Shared_Key__c = 'SomeImaginaryKey';
        afPressSettings.Order_Placer__c = 'Salesforce';
        
        insert afPressSettings;
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
    
    static void runSubmitOrderAsyncRequest(Id orderId) {
        Async_Request__c asyncRequest = AsyncRequestTestData.Instance.withOperationClass('ESBAFPressSubmitOrderAsyncRequestHandler')
                                                                     .withParameters(orderId)
                                                                     .insertAsyncRequest();

        Test.startTest();

        ESBAFPressSubmitOrderAsyncRequestHandler handler = new ESBAFPressSubmitOrderAsyncRequestHandler();
        handler.handleRequest(asyncRequest);

        Test.stopTest();
    }
    
    static void assertLastErrorLogWithMessage(String errorMessage) {
        List<Integration_Log__c> integrationLogs = getIntegrationLogs();
        
        for (Integration_Log__c intLog : integrationLogs) {
            system.debug('   assertOneErrorLogWithMessage::intLog ' + intLog);
        }
        
        system.assert(integrationLogs.size() > 0, 'There should be at least one integration log.');
        
        Integration_Log__c lastLog = integrationLogs[integrationLogs.size() - 1];
        
        system.assertEquals('ERROR', lastLog.Severity__c, 'The log should be an error log.');
        
        system.assert(lastLog.Message__c.containsIgnoreCase(errorMessage), 'The expected error was not found. Error: ' + lastLog.Message__c);
    }
    
    static void loadOrderSubmissionTestCalloutMocks(HttpCalloutMock authenticationMock, HttpCalloutMock orderSubmissionMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, authenticationMock);
        
        requests.put(DEFAULT_ENDPOINT + ESBAFPressOrderServiceClient.ORDER_SERVICE_PATH, orderSubmissionMock);
        
        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    static void loadOrderSubmissionTestCalloutMock(HttpCalloutMock orderSubmissionMock) {
        loadOrderSubmissionTestCalloutMocks(new ESBAuthenticatorTest.AuthenticateSuccessfulMock(), orderSubmissionMock);
    }
    
    static void assertAFPressError(Id orderId, String expectedError) {
        Order__c o = getOrderById(orderId);
        
        system.assert(String.isNotBlank(o.AFPress_Error__c), 'The AFPress Error on the order is blank.');
        system.assertEquals(expectedError, o.AFPress_Error__c, 'The AFPress error is not the expected one.');
    }
    
    static void assertOrderNumber(Id orderId, String expectedOrderNumber) {
        Order__c o = getOrderById(orderId);
        
        system.assert(String.isNotBlank(o.AFPress_Order__c), 'The AFPress Order field on the order is blank.');
        system.assertEquals(expectedOrderNumber, o.AFPress_Order__c, 'The AFPress Order Number is not the expected one.');
    }
    
    static Order__c getOrderById(Id orderId) {
        return
        [SELECT ID,
                AFPress_Error__c,
                AFPress_Order__c
           FROM Order__c
          WHERE Id = :orderId];
    }
    
    @isTest
    static void handleRequest_noOrderId_expectOrderIDRequiredValidationMessageTest() {
        Id nullOrderId = null;
        runSubmitOrderAsyncRequest(nullOrderId);
        
        assertLastErrorLogWithMessage(ESBAFPressOrderServiceClient.ORDER_ID_REQUIRED_MESSAGE);
    }
    
    @isTest
    static void handleRequest_orderIdSuppliedButAuthTokenBlank_expectAuthTokenBlankErrorTest() {
        loadOrderSubmissionTestCalloutMocks(new ESBAuthenticatorTest.AuthenticateFailedWithBlankBodyMock(), null);  
        Order__c someOrder = OrderTestData.Instance.withChargeCode('NY-Ofc-12').insertOrder();
        
        runSubmitOrderAsyncRequest(someOrder.Id);
        
        assertLastErrorLogWithMessage(ESBAFPressOrderServiceClient.AUTH_TOKEN_BLANK_ERROR_MESSAGE);
    }
    
    @isTest
    static void handleRequest_orderIdSuppliedButUnauthorizedErrorResponse_expectUnauthorizedErrorMessageTest() {
        loadOrderSubmissionTestCalloutMock(new UnauthorizedOrderSubmissionMock());

        Order__c someOrder = OrderTestData.Instance.insertOrder();

        runSubmitOrderAsyncRequest(someOrder.Id);

        assertLastErrorLogWithMessage('Unauthorized');
    }
    
    @isTest
    static void handleRequest_orderIdSuppliedButInvalidSharedKeyErrorResponse_expectInvalidKeyErrorMessageTest() {
        loadOrderSubmissionTestCalloutMock(new InvalidSharedKeyOrderSubmissionMock());

        Order__c someOrder = OrderTestData.Instance.insertOrder();

        runSubmitOrderAsyncRequest(someOrder.Id);
        
        String expectedError = 'You are not authorized to use web services.';
        
        assertLastErrorLogWithMessage(expectedError);
        assertAFPressError(someOrder.Id, expectedError);
    }
    
    @isTest
    static void handleRequest_orderIdSuppliedWithSuccessResponse_expectOrderNumberPopulatedTest() {
        String orderNumber = '1388';
        loadOrderSubmissionTestCalloutMock(new SuccessfulOrderSubmissionMock(orderNumber));

        Order__c someOrder = OrderTestData.Instance.withChargeCode('NY-NY')
                                                   .withShippingLocation('Some Awesome Dept')
                                                   .insertOrder();
                                                   
        Order_Line_Item__c orderLine = OrderLineItemTestData.Instance.withQuantity(1)
                                                                     .withMaterialNumber('SB-193')
                                                                     .withOrder(someOrder.Id)
                                                                     .withShippable(true)
                                                                     .insertOrderLineItem();

        runSubmitOrderAsyncRequest(someOrder.Id);
        
        assertOrderNumber(someOrder.Id, orderNumber);
    }
    
    private with sharing class UnauthorizedOrderSubmissionMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/text');
            res.setBody('Unauthorized');
            res.setStatusCode(401);
            return res;
        }
    }
    
    private with sharing class InvalidSharedKeyOrderSubmissionMock implements HTTPCalloutMock {
         public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/text');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"> <soapenv:Header/> <soapenv:Body> <ns6:CreateOrderResponse xmlns:ns6="http://www.rocsoft.com/services/order/types" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns6:CreateOrderResponse"> <s54:Success xmlns:s54="http://www.rocsoft.com/services/types">false</s54:Success> <Messages xmlns="http://www.rocsoft.com/services/types"> <Message type="error" code="INVALIDREQ">You are not authorized to use web services.</Message> </Messages> <ns6:OrderId></ns6:OrderId> </ns6:CreateOrderResponse> </soapenv:Body> </soapenv:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private with sharing class SuccessfulOrderSubmissionMock implements HTTPCalloutMock {
        
        private String orderNumber { get; set; }
        
        public SuccessfulOrderSubmissionMock(String orderNumberArg) {
            orderNumber = orderNumberArg;
        }
        
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/text');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"> <soapenv:Header/> <soapenv:Body> <ns6:CreateOrderResponse xmlns:ns6="http://www.rocsoft.com/services/order/types" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns6:CreateOrderResponse"> <s54:Success xmlns:s54="http://www.rocsoft.com/services/types">true</s54:Success> <Messages xmlns="http://www.rocsoft.com/services/types" /> <ns6:OrderId>' + orderNumber + '</ns6:OrderId> </ns6:CreateOrderResponse> </soapenv:Body> </soapenv:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }
}