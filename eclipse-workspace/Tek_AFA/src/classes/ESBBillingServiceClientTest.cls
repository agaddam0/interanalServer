@isTest
public with sharing class ESBBillingServiceClientTest {
    public static final String DEFAULT_ENDPOINT = 'https://api-qa.americanfidelity.com:443';

    @testSetup
    public static void setup() {
        API_Manager__c sandboxAPI = new API_Manager__c();
        sandboxAPI.Name = ESBBillingServiceClient.SANDBOX_BILLING_API_MANAGER_NAME;
        sandboxAPI.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        sandboxAPI.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        sandboxAPI.Endpoint__c = DEFAULT_ENDPOINT;
        sandboxAPI.Host__c = 'api-qa.americanfidelity.com:443';
        sandboxAPI.Username__c = 'Username';
        sandboxAPI.Password__c = 'Password';
        insert sandboxAPI;
        
        API_Manager__c productionAPI = sandboxAPI.clone(false, true);
        productionAPI.Name = ESBBillingServiceClient.PRODUCTION_BILLING_API_MANAGER_NAME;
        
        insert productionAPI;
    }

    @isTest
    static void browseByPayorMaster_payorNumberNull_expectPayorNumberRequiredMessageTest() {
        String nullPayorNumber = null;
        String nullAccountId = null;
        
        ESBBillingServiceClient client = new ESBBillingServiceClient();
        ESBBillingServiceClient.BrowseBillsResponse response = client.browseByPayorMaster(nullPayorNumber, true, false, nullAccountId);
        
        assertFailedResponse(response, ESBBillingServiceClient.PAYOR_NUMBER_REQUIRED_MESSAGE);
    }
    
    @isTest
    static void browseByPayorMaster_authenticationFailed_expectAuthTokenBlankErrorMessageTest() {
        String somePayorNumber = '1938aa';
        String nullAccountId = null;
        
        ESBBillingServiceClient client = new ESBBillingServiceClient();
        ESBBillingServiceClient.BrowseBillsResponse response = client.browseByPayorMaster(somePayorNumber, true, false, nullAccountId);
        
        assertFailedResponse(response, ESBServiceBase.AUTH_TOKEN_BLANK_ERROR_MESSAGE);
    }

    @isTest
    static void browseByPayorMaster_payorNumberSuppliedNoBillsFound_expectNoErrorsTest() {
        setBrowseBillsResponseMock(new BrowseByPayorNoBillsFoundMock());
        
        String somePayorNumber = '1938aa';
        String nullAccountId = null;
        
        ESBBillingServiceClient.BrowseBillsResponse response = browseByPayorMaster(somePayorNumber, true, false, nullAccountId);
        
        assertNoBills(response);
    }

    @isTest
    static void browseByPayorMaster_payorNumberSuppliedOneBillFound_expectNoErrorsTest() {
        setBrowseBillsResponseMock(new BrowseByPayorOneBillFoundMock());
        
        String somePayorNumber = '1938BB';
        String nullAccountId = null;
        
        ESBBillingServiceClient.BrowseBillsResponse response = browseByPayorMaster(somePayorNumber, true, true, nullAccountId);
        
        assertBills(response, 1);
    }
    
    @isTest
    static void browseByPayorMaster_payorNumberSuppliedButSystemErrorInResponse_expectMessageHasErrorMessageInResponseTest() {
        setBrowseBillsResponseMock(new BrowseByPayorSystemErrorMock());

        String somePayorNumber = '1938BB';
        String nullAccountId = null;
        
        ESBBillingServiceClient.BrowseBillsResponse response = browseByPayorMaster(somePayorNumber, true, true, nullAccountId);
        
        assertErrorResponse(response);
    }

    @isTest
    static void browseByPayorMaster_payorNumberSuppliedButResponseHasErrorMessage_expectMessageHasErrorMessageInResponseTest() {
        setBrowseBillsResponseMock(new BrowseByPayorOperationErrorMock());

        String somePayorNumber = '1938BB';
        String nullAccountId = null;
        
        ESBBillingServiceClient.BrowseBillsResponse response = browseByPayorMaster(somePayorNumber, true, true, nullAccountId);
        
        assertErrorResponse(response);
    }
    
    @isTest
    static void browseByCBillId_consolidatedBillIdBlank_expectConslidatedBillIdRequiredMessageTest() {
        String nullConsolidatedBillId = null;
        
        ESBBillingServiceClient.ConsolidatedBillResponse response = browseByCBillId(nullConsolidatedBillId);
        
        assertBrowseByCBillIdFailedResponse(response, ESBBillingServiceClient.CONSOLIDATED_BILL_ID_REQUIRED_MESSAGE);
    }
    
    @isTest
    static void browseByCBillId_authenticationFailed_expectAuthTokenBlankErrorMessageTest() {
        String someBillId = '1938aa';
        
        ESBBillingServiceClient.ConsolidatedBillResponse response = browseByCBillId(someBillId);
        
        assertBrowseByCBillIdFailedResponse(response, ESBServiceBase.AUTH_TOKEN_BLANK_ERROR_MESSAGE);
    }
    
    @isTest
    static void browseByCBillId_billIdSuppliedWithOnePolicyHolder_expectResponseSuccessfulWithOnePolicyAndOnePolicyHolderTest() {
        setBrowseByCBillIdResponseMock(new BrowseByCBillIdSuccessWithOneDetailMock());
        
        ESBBillingServiceClient.ConsolidatedBillResponse response = browseByCBillId('sdfsdfs');
        
        assertBrowseByCBillIdHasNumberofPolicyHolders(response, 1);
    }
    
    @isTest
    static void browseByCBillId_billIdSuppliedButSystemErrorOccurred_expectResponseHasErrorTest() {
        setBrowseByCBillIdResponseMock(new BrowseByCBillIdSystemErrorMock());
        
        ESBBillingServiceClient.ConsolidatedBillResponse response = browseByCBillId('sdfsdfs');
        
        assertBrowseByCBillIdResponseHasError(response);
    }

    @isTest
    static void browseByCBillId_billIdSuppliedButOperationErrorOccurred_expectResponseHasErrorTest() {
        setBrowseByCBillIdResponseMock(new BrowseByCBillIdOperationErrorMock());
        
        ESBBillingServiceClient.ConsolidatedBillResponse response = browseByCBillId('sdfsdfs');
        
        assertBrowseByCBillIdResponseHasError(response);
    }
    
    @isTest
    static void browseByCBillId_billIdSuppliedAndBillFeeLineWithoutSSNReturned_expectResponseSuccessfulWithOnePolicyAndOnePolicyHolderTest() {
        setBrowseByCBillIdResponseMock(new BrowseByCBillIdSuccessWithOneDetailAndOneFeeMock());
        
        ESBBillingServiceClient.ConsolidatedBillResponse response = browseByCBillId('sdfsdfs');
        
        assertBrowseByCBillIdHasNumberofPolicyHolders(response, 2);
    }

    @isTest
    static void buildBrowseByPayorMasterRequestBody_withBlankParameters_expectCurrentUserIdInRequestTest() {
        ESBBillingServiceClient client = new ESBBillingServiceClient();
        String browseByPayorMasterRequestBody = client.buildBrowseByPayorMasterRequestBody('', true, true);

        assertRequestHasCurrentUserId(browseByPayorMasterRequestBody);
    }

    @isTest
    static void buildBrowseByCBillIdRequestBody_withBlankParameters_expectCurrentUserIdInRequestTest() {
        ESBBillingServiceClient client = new ESBBillingServiceClient();
        String browseByPayorMasterRequestBody = client.buildBrowseByCBillIdRequestBody('');

        assertRequestHasCurrentUserId(browseByPayorMasterRequestBody);
    }
    
    static ESBBillingServiceClient.BrowseBillsResponse browseByPayorMaster(String payorNumber, Boolean includeHistorical, Boolean includeCurrent, String accountId) {
        Test.startTest();
        
        ESBBillingServiceClient client = new ESBBillingServiceClient();
        ESBBillingServiceClient.BrowseBillsResponse response = client.browseByPayorMaster(payorNumber, includeHistorical, includeCurrent, accountId);
        
        Test.stopTest();
        
        return response;
    }
    
    static ESBBillingServiceClient.ConsolidatedBillResponse browseByCBillId(String consolidatedBillId) {
        Test.startTest();
        
        Id nullAccountId = null;
        
        ESBBillingServiceClient client = new ESBBillingServiceClient();
        ESBBillingServiceClient.ConsolidatedBillResponse response = client.browseByCBillId(consolidatedBillId, nullAccountId);
        
        Test.stopTest();
        
        return response;
    }
    
    public static void setBrowseBillsResponseMock(HttpCalloutMock responseMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        requests.put(DEFAULT_ENDPOINT + ESBBillingServiceClient.CONSOLIDATED_BILLING_API_PATH, responseMock);

        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }

    static void setBrowseByCBillIdResponseMock(HttpCalloutMock responseMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        requests.put(DEFAULT_ENDPOINT + ESBBillingServiceClient.ADMIN_COVERAGE_BILLING_API_PATH, responseMock);

        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    static void assertFailedResponse(ESBBillingServiceClient.BrowseBillsResponse response, String expectedMsg) {
        system.assert(response != null, 'The response is null.');
        system.assertEquals(false, response.Success, 'The response is successful when it should not be.');
        system.assertEquals(expectedMsg, response.Message, 'The response message is not the expected one.');
    }
    
    static void assertBrowseByCBillIdFailedResponse(ESBBillingServiceClient.ConsolidatedBillResponse response, String expectedMsg) {
        system.assert(response != null, 'The response is null.');
        system.assertEquals(false, response.Success, 'The response is successful when it should not be.');
        
        system.debug('  responseMessage: ' + response.Message);
        system.debug('  expectedMsg: ' + expectedMsg);
        
        system.assert(response.Message.containsIgnoreCase(expectedMsg), 'The response message is not the expected one.');
    }
    
    static void assertErrorResponse(ESBBillingServiceClient.BrowseBillsResponse response) {
        system.assert(response != null, 'The response is null.');
        system.assertEquals(false, response.Success, 'The response is successful when it should not be.');
        system.assert(String.isNotBlank(response.Message), 'The response message should not be blank.');
    }
    
    static void assertBrowseByCBillIdResponseHasError(ESBBillingServiceClient.ConsolidatedBillResponse response) {
        system.assert(response != null, 'The response is null.');
        system.assertEquals(false, response.Success, 'The response is successful when it should not be.');
        system.assert(String.isNotBlank(response.Message), 'The response message should not be blank.');
    }
    
    static void assertNoBills(ESBBillingServiceClient.BrowseBillsResponse response) {
        system.assert(response != null, 'The response is null.');
        
        assertBrowseBillsSuccessful(response);

        system.assertEquals(0, response.Bills.size(), 'No bills should be found.');
    }
    
    static void assertBills(ESBBillingServiceClient.BrowseBillsResponse response, Integer expectedNumberOfBills) {
        assertBrowseBillsSuccessful(response);
        
        system.assertEquals(expectedNumberOfBills, response.Bills.size(), 'The expected number of bills was not found.');
    }
    
    static void assertBrowseBillsSuccessful(ESBBillingServiceClient.BrowseBillsResponse response) {
        system.assertEquals(true, response.Success, 'The response was not successful. Message: ' + response.Message);
        system.assertEquals('', response.Message, 'The response message is not blank.');
        system.assert(response.Bills != null, 'The bills are null in the response.');        
    }
    
    static void assertBrowseByCBillIdHasNumberofPolicyHolders(ESBBillingServiceClient.ConsolidatedBillResponse response, Integer numExpectedPolicyHolders) {
        assertBrowseByCBillIdSuccessful(response);
        
        system.assert(response.Bill != null, 'The bill is null');
        system.assertEquals(numExpectedPolicyHolders, response.Bill.PolicyHolders.size(), 'The bill does not have the expected number of policy holders.');
    }
    
    static void assertBrowseByCBillIdSuccessful(ESBBillingServiceClient.ConsolidatedBillResponse response) {
        system.assert(response != null, 'The response is null.');
        system.assertEquals(true, response.Success, 'The response is not successful. Message: ' + response.Message);
        system.assertEquals('', response.Message, 'The response should be blank.');
    }

    static void assertRequestHasCurrentUserId(String requestBody) {
        String currentUserId = UserInfo.getUserId();

        system.assert(String.isNotBlank(requestBody), 'The request body is blank.');
        system.assert(requestBody.contains(currentUserId), 'The request body does not contain the current user id.');
    }

    public with sharing class BrowseByPayorNoBillsFoundMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"BillHeaders": [], "Errors": [],"Status": "OK","TimeTaken": 0}');
            res.setStatusCode(200);
            return res;
        }
    }

    public with sharing class BrowseByPayorOneBillFoundMock implements HttpCalloutMock {
        private String MCP { get; set; }
        
        private String BillId { get; set; }
        
        public BrowseByPayorOneBillFoundMock() {
            MCP = '1938198718';
            BillId = 'A-193818';
        }
        
        public BrowseByPayorOneBillFoundMock(String MCPArg, String BillIdArg) {
            MCP = MCPArg;
            BillId = BillIdArg;
        }
        
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/XML');
            res.setBody('{' +
						  '"BillHeaders": [' +
						    '{' +
						      '"BillDeliveryMethodInd": "O",' +
						      '"BillDescriptions": "PRODUCT ",' +
						      '"BillDueDate": "2018-12-01T00:00:00",' +
						      '"BillPaidFlag": false,' +
						      '"Bills": [' +
						        '{' +
						          '"AdminSystemCode": "BARS",' +
						          '"BankAccountIdDeposit": 87,' +
						          '"BillActiveFlag": true,' +
						          '"BillDescription": "PRODUCT",' +
						          '"BillHeaderBilledAmt": 313.34,' +
						          '"BillHeaderDetailCnt": 4,' +
						          '"BillHeaderId": "2851568",' +
						          '"BillHeaderReconAmt": 313.34,' +
						          '"BillPeriodFromDate": "2017-12-01T00:00:00",' +
						          '"BillPeriodFromDateSpecified": true,' +
						          '"BillPeriodToDate": "2017-12-31T00:00:00",' +
						          '"BillPeriodToDateSpecified": true,' +
						          '"BillRemarks": [],' +
						          '"BillStatusCode": "R",' +
						          '"BillStatusDesc": "READY FOR CUSTOMER",' +
						          '"BillTypeDesc": "ORIGINAL BILL",' +
						          '"BillTypeInd": "O",' +
						          '"CBillId": "1938174",' +
						          '"CompanyCode": "11",' +
						          '"CompanyName": "AMERICAN FIDELITY ASSURANCE COMPANY",' +
						          '"CustNameMcp": "Metillium PLUMBING",' +
						          '"CustNamePayor": "Metillium PLUMBING",' +
						          '"CustNumExternalPayor": "",' +
						          '"CustNumMcp": "47127",' +
						          '"CustNumPayor": "47127",' +
						          '"DistributionId": "STND",' +
						          '"DivsnCode": "2",' +
						          '"DivsnName": "AWD",' +
						          '"HasCommentsFlag": false,' +
						          '"InvoiceDate": "2017-11-26T00:00:00",' +
						          '"InvoiceDateSpecified": true,' +
						          '"InvoiceNum": "B830283",' +
						          '"InvoiceNumReplaced": "",' +
						          '"OrigDateTime": "2017-11-26T00:00:00",' +
						          '"OrigUserId": "",' +
						          '"PlanDateEndSpecified": false,' +
						          '"RebillFlag": false,' +
						          '"RemarkId": 0,' +
						          '"ServiceTeam": "AGDWEST",' +
						          '"StateCodeMcp": "NY",' +
						          '"TaxYear": "",' +
						          '"UpdateTimestamp": null,' +
						          '"UpdateDateTime": "2017-11-26T22:19:50",' +
						          '"UpdateDateTimeSpecified": true,' +
						          '"UpdateUserId": "ABCD1234",' +
						          '"VersionToken": "6373983735906"' +
						        '}' +
						      '],' +
						      '"BillStatusCode": "R",' +
						      '"BillStatusDate": "2017-11-26T00:00:00",' +
						      '"BillStatusDesc": "READY FOR CUSTOMER",' +
						      '"CBillBilledAmt": 313.34,' +
						      '"CBillDetailCnt": 4,' +
						      '"CBillHeaderCnt": 1,' +
						      '"CBillId": "2765195",' +
						      '"InvoiceNumber": "2765195",' +
						      '"CBillReconAmt": 313.34,' +
						      '"HasReBillsFlag": false,' +
						      '"PayorNumMaster": "47127",' +
						      '"PayorServiceTeam": "AGDWEST",' +
						      '"TotalPaymentAmt": 0,' +
						      '"UpdateDateTime": "2017-11-26T22:19:50"' +
						    '}' +
						  '],' +
						  '"Errors": [],' +
						  '"Status": "OK",' +
						  '"TimeTaken": 0' +
						'}');
            res.setStatusCode(200);
            return res;
        }
    }

    private with sharing class BrowseByPayorSystemErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/XML');
            res.setBody('System Timed Out');
            res.setStatusCode(500);
            return res;
        }
    }

    private with sharing class BrowseByPayorOperationErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/XML');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?> <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> <SOAP-ENV:Header xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"></SOAP-ENV:Header><SOAP-ENV:Body> <tns:CBillBrowseByPayorMasterResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tns="http://www.afadvantage.com/services/v1/Billing/CBill"> <resultData> <PayloadOut> <CBills> </CBills> <PayorNameMaster>HAMBLEN COUNTY BOARD</PayorNameMaster> <PayorNumMaster>23338</PayorNumMaster> </PayloadOut> <ErrorOut> <ReturnCode></ReturnCode> <ErrorNum></ErrorNum> <ErrorLine></ErrorLine> <ErrorField></ErrorField> <MsgShort>Some Error Message</MsgShort> <MsgLong></MsgLong> <ErrorLocation></ErrorLocation> </ErrorOut> </resultData> </tns:CBillBrowseByPayorMasterResponse> </SOAP-ENV:Body> </SOAP-ENV:Envelope>');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public with sharing class BrowseByCBillIdSuccessWithOneDetailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"BillDetailList":[{"BillChgReasonCode":"","BillDetailRemarks":"","BillPeriodFromDate":"2018-09-01T00:00:00","BilledAmtUnalloc":100.00,"CoveredIndsCode":"","FederalIdNum":"1888","FreqInd":"","NameFirst":"PAMELA","NameLast":"ALLEN","ProductBilledCode":"RIRA","ReconAmtUnalloc":100.00,"ReferenceNum":"7330382"}],"Success":true,"Requester":null,"Errors":[],"Status":"OK","TimeTaken":425}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public with sharing class BrowseByCBillIdSystemErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('System Timed Out');
            res.setStatusCode(500);
            return res;
        }
    }

    private with sharing class BrowseByCBillIdOperationErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"BillDetailList":"[]","Success":false,"Requester":null,"Errors":["Some Awful Error"],"Status":"ERROR","TimeTaken":264}');
            res.setStatusCode(200);
            return res;
        }
    }

    private with sharing class BrowseByCBillIdSuccessWithOneDetailAndOneFeeMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"BillDetailList":[{"ReferenceNum":"16378BF","ProductBilledCode":"FEES","BilledAmtUnalloc":10.00,"ReconAmtUnalloc":10.00,"BillDetailRemarks":"BILLING FEE"},{"BillChgReasonCode":"","BillDetailRemarks":"","BillPeriodFromDate":"2018-09-01T00:00:00","BilledAmtUnalloc":100.00,"CoveredIndsCode":"","FederalIdNum":"1888","FreqInd":"","NameFirst":"PAMELA","NameLast":"ALLEN","ProductBilledCode":"RIRA","ReconAmtUnalloc":100.00,"ReferenceNum":"7330382"}],"Success":true,"Requester":null,"Errors":[],"Status":"OK","TimeTaken":425}');
            res.setStatusCode(200);
            return res;
        }
    }
}