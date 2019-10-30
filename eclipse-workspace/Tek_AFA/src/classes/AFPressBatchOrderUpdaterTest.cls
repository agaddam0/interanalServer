@isTest
public with sharing class AFPressBatchOrderUpdaterTest {
    private static final String DEFAULT_ENDPOINT = 'https://api-qa.americanfidelity.com:443';

    static void runAFPressBatchOrderUpdater() {
        Test.startTest();

        AFPressBatchOrderUpdater updater = new AFPressBatchOrderUpdater();
        updater.execute(null);

        Test.stopTest();
    }
    
    static void loadGetOrderTestCalloutsMock(HttpCalloutMock esbAuthMock, HttpCalloutMock getOrderMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, esbAuthMock);
        
        requests.put(DEFAULT_ENDPOINT + ESBAFPressOrderServiceClient.ORDER_SERVICE_PATH, getOrderMock);
        
        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    static void loadGetOrderTestCalloutMock(HttpCalloutMock getOrderMock) {
        loadGetOrderTestCalloutsMock(new ESBAuthenticatorTest.AuthenticateSuccessfulMock(), getOrderMock);
    }
    
    static Order__c getOrderById(Id orderId) {
        return
        [SELECT Id,
                AFPress_Order__c,
                Status__c
           FROM Order__c
          WHERE Id = :orderId];
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
    
    static void assertOrderStatus(Id orderId, String expectedOrderStatus) {
        Order__c order = getOrderById(orderId);
        
        system.assertEquals(expectedOrderStatus, order.Status__c, 'The order\'s status is not the expected one.');
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

    @isTest
    static void run_noOrdersToUpdate_expectNoErrorsTest() {
        runAFPressBatchOrderUpdater();
    }
    
    @isTest
    static void run_oneOrderToUpdateWithInTransitStatus_expectStatusUpdatedTest() {
        String orderNumber = 'ORDER 1918';
        String inTransitOrderStatus = 'In Transit';
        
        Order__c orderToUpdate = OrderTestData.Instance.withAFPressOrder(orderNumber)
                                                       .withStatus('Submitted')
                                                       .insertOrder();
        
        GetOrderResponse response = new GetOrderResponse();
        response.OrderNumber = orderNumber;
        response.OrderStatus = inTransitOrderStatus;
        
        loadGetOrderTestCalloutMock(new GetOrdersMock(new List<GetOrderResponse>{ response }));

        runAFPressBatchOrderUpdater();
        
        assertOrderStatus(orderToUpdate.Id, inTransitOrderStatus);
    }
    
    @isTest
    static void run_oneOrderToUpdateButESBAuthenticationFailed_expectNoOrderStatusChangedTest() {
        String orderNumber = 'ORDER 1918';
        String inTransitOrderStatus = 'In Transit';
        
        Order__c orderToUpdate = OrderTestData.Instance.withAFPressOrder(orderNumber)
                                                       .withStatus('Submitted')
                                                       .insertOrder();
        
        GetOrderResponse response = new GetOrderResponse();
        response.OrderNumber = orderNumber;
        response.OrderStatus = inTransitOrderStatus;
        
        loadGetOrderTestCalloutsMock(new ESBAuthenticatorTest.AuthenticateFailedWithBlankBodyMock(),
                                     new GetOrdersMock(new List<GetOrderResponse>{ response }));

        runAFPressBatchOrderUpdater();
        
        assertOrderStatus(orderToUpdate.Id, orderToUpdate.Status__c);
        assertLastErrorLogWithMessage(ESBAFPressOrderServiceClient.AUTH_TOKEN_BLANK_ERROR_MESSAGE);
    }

    @isTest
    static void run_oneOrderToUpdateButAFPressUnauthenticatedError_expectNoOrderStatusChangedTest() {
        String orderNumber = 'ORDER 1918';
        String inTransitOrderStatus = 'In Transit';
        
        Order__c orderToUpdate = OrderTestData.Instance.withAFPressOrder(orderNumber)
                                                       .withStatus('Submitted')
                                                       .insertOrder();
        
        loadGetOrderTestCalloutMock(new GetOrdersInvalidWebserviceKeyMock());

        runAFPressBatchOrderUpdater();
        
        assertOrderStatus(orderToUpdate.Id, orderToUpdate.Status__c);
        assertLastErrorLogWithMessage('You are not authorized to use web services.');
    }
    
    @isTest
    static void run_oneOrderToUpdateButAPITimeoutError_expectNoOrderStatusChangedTest() {
        String orderNumber = 'ORDER 1918';
        String inTransitOrderStatus = 'In Transit';
        
        Order__c orderToUpdate = OrderTestData.Instance.withAFPressOrder(orderNumber)
                                                       .withStatus('Submitted')
                                                       .insertOrder();
        
        String apiError = 'Read Timeout';
        
        loadGetOrderTestCalloutMock(new GetOrdersAPIErrorMock(apiError));

        runAFPressBatchOrderUpdater();
        
        assertOrderStatus(orderToUpdate.Id, orderToUpdate.Status__c);
        assertLastErrorLogWithMessage(apiError);
    }

    @isTest
    static void run_oneOrderToUpdateWithCanceledStatus_expectStatusNotUpdatedTest() {
        String orderNumber = 'ORDER 1918';
        String inTransitOrderStatus = 'In Transit';
        String canceledOrderStatus = 'Canceled';
        
        Order__c orderToUpdate = OrderTestData.Instance.withAFPressOrder(orderNumber)
                                                       .withStatus(canceledOrderStatus)
                                                       .insertOrder();
        
        GetOrderResponse response = new GetOrderResponse();
        response.OrderNumber = orderNumber;
        response.OrderStatus = inTransitOrderStatus;
        
        loadGetOrderTestCalloutMock(new GetOrdersMock(new List<GetOrderResponse>{ response }));

        runAFPressBatchOrderUpdater();
        
        assertOrderStatus(orderToUpdate.Id, canceledOrderStatus);
    }
    
    private with sharing class GetOrdersMock implements HTTPCalloutMock {
        private List<GetOrderResponse> Responses { get; set; }
        
        public GetOrdersMock(List<GetOrderResponse> responsesArg) {
            Responses = responsesArg;
        }

        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/text');
            res.setStatusCode(200);
            
            String body =  '<?xml version="1.0" encoding="UTF-8"?>';
                   body += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                   body += '  <soapenv:Body>';
                   body += '  <SearchOrdersResponse xmlns="http://www.rocsoft.com/services/order/types">';
                   body += '  <ns1:Success xmlns:ns1="http://www.rocsoft.com/services/types">true</ns1:Success>';
                   body += '  <ns2:Messages xmlns:ns2="http://www.rocsoft.com/services/types"/>';
                   body += '  <Orders>';
                   
            for (GetOrderResponse response : Responses) {
                   body += '  <ns:Order xmlns:ns="http://www.rocsoft.com/order">';
                   
                   body += '  <ns:OrderID>' + response.OrderNumber + '</ns:OrderID>';
                   body += '  <ns:OrderStatus>' + response.OrderStatus + '</ns:OrderStatus>';
                   
                   body += '  </ns:Order>';
            }
                   
                   body += ' </Orders></SearchOrdersResponse></soapenv:Body></soapenv:Envelope>';

/*
<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <soapenv:Body>
    <SearchOrdersResponse xmlns="http://www.rocsoft.com/services/order/types">
      <ns1:Success xmlns:ns1="http://www.rocsoft.com/services/types">true</ns1:Success>
      <ns2:Messages xmlns:ns2="http://www.rocsoft.com/services/types"/>
      <Orders>
*/
            
            res.setBody(body);

            return res;
        }
    }

    private with sharing class GetOrdersInvalidWebserviceKeyMock implements HTTPCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            String body = '<?xml version="1.0" encoding="UTF-8"?> <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <soapenv:Body> <SearchOrdersResponse xmlns="http://www.rocsoft.com/services/order/types"> <ns1:Success xmlns:ns1="http://www.rocsoft.com/services/types">false</ns1:Success> <ns2:Messages xmlns:ns2="http://www.rocsoft.com/services/types"> <Message type="error" code="INVALIDREQ">You are not authorized to use web services.</Message> </ns2:Messages> <Orders></Orders> </SearchOrdersResponse> </soapenv:Body> </soapenv:Envelope>';
            
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/text');
            res.setStatusCode(200);
            res.setBody(body);
            
            return res;
        }
    }

    private with sharing class GetOrdersAPIErrorMock implements HTTPCalloutMock {
        private string APIError { get; set; }
        
        public GetOrdersAPIErrorMock(String apiErrorArg) {
            APIError = apiErrorArg;
        }
        
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/text');
            res.setStatusCode(401);
            res.setBody(APIError);
            
            return res;
        }
    }
    
    private class GetOrderResponse {
        public String OrderNumber { get; set; }
        
        public String OrderStatus { get; set; }
        
        public GetOrderResponse() {
            OrderNumber = '';
            OrderStatus = '';
        }
    }
}