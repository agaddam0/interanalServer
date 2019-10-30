@isTest
public with sharing class ProductBillingBillsControllerTest {

    @testSetup
    static void setup() {
        API_Manager__c sandboxAPI = new API_Manager__c();
        sandboxAPI.Name = ESBBillingServiceClient.SANDBOX_BILLING_API_MANAGER_NAME;
        sandboxAPI.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        sandboxAPI.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        sandboxAPI.Endpoint__c = ESBBillingServiceClientTest.DEFAULT_ENDPOINT;
        sandboxAPI.Host__c = 'api-qa.americanfidelity.com:443';
        sandboxAPI.Username__c = 'Username';
        sandboxAPI.Password__c = 'Password';
        insert sandboxAPI;
        
        API_Manager__c productionAPI = sandboxAPI.clone(false, true);
        productionAPI.Name = ESBBillingServiceClient.PRODUCTION_BILLING_API_MANAGER_NAME;
        
        insert productionAPI;
    }

    @isTest
    static void getBills_oneBillForPayorNumber_expectOneBillReturnedTest() {
        setBrowseBillsResponseMock(new ESBBillingServiceClientTest.BrowseByPayorOneBillFoundMock());

        Account acct = AccountTestData.Instance.withPayorNumber('P13918').insertCustomerAccount();

        ProductBillingBillsController.BillsResponse response = getBills(acct.Id, true, false);
        
        system.assert(response != null, 'The bills response is null.');
        system.assert(response.Account != null, 'The account is null.');
        system.assertEquals(acct.Id, response.Account.Id, 'A different account was returned.');
        system.assert(response.BrowseBillResponse != null, 'The BrowseBillResponse is null.');
        system.assertEquals(1, response.BrowseBillResponse.Bills.size(), 'One bill should be found.');
    }

    @isTest
    static void getBills_oneBillForPayorNumberFromAccountBillingMode_expectOneBillReturnedTest() {
        setBrowseBillsResponseMock(new ESBBillingServiceClientTest.BrowseByPayorOneBillFoundMock());

        Account acct = AccountTestData.Instance.withPayorNumber(null).insertCustomerAccount();
        Account_Billing_Mode__c acctBillingMode = AccountBillingModeTestData.Instance.withPayorNumber('P13918')
                                                                                     .withAccount(acct.Id)
                                                                                     .insertAccountBillingMode();

        ProductBillingBillsController.BillsResponse response = getBills(acct.Id, true, false);
        
        system.assert(response != null, 'The bills response is null.');
        system.assert(response.Account != null, 'The account is null.');
        system.assertEquals(acct.Id, response.Account.Id, 'A different account was returned.');
        system.assert(response.BrowseBillResponse != null, 'The BrowseBillResponse is null.');
        system.assertEquals(1, response.BrowseBillResponse.Bills.size(), 'One bill should be found.');
    }
    
    @isTest
    static void groupBillsByMCP_noBills_expectNoErrorsTest() {
        ProductBillingBillsController.BillsResponse billsResponse = instantiateBillsResponse();
        
        ProductBillingBillsController.groupBillsByMCP(billsResponse);
    }
    
    @isTest
    static void groupBillsByMCP_twoBillsWithSameMCP_expectOneMCPBillsGroupingTest() {
        ProductBillingBillsController.BillsResponse billsResponse = instantiateBillsResponse();
        addBill(billsResponse, 'MCP', 'Customer 1');
        addBill(billsResponse, 'MCP', 'Customer 1');

        ProductBillingBillsController.groupBillsByMCP(billsResponse);
        
        system.assertEquals(1, billsResponse.BillsByMCP.size(), 'There should be 1 mcp bills grouping.');
        system.assertEquals(2, billsResponse.BillsByMCP[0].Bills.size(), 'The mcp group should have 2 bills.');
    }
    
    @isTest
    static void groupBillsByMCP_twoBillsWithDifferentMCPs_expectTwoMCPBillsGroupingsTest() {
        ProductBillingBillsController.BillsResponse billsResponse = instantiateBillsResponse();
        addBill(billsResponse, 'MCP', 'Customer 1');
        addBill(billsResponse, 'MCP2', 'Customer 2');

        ProductBillingBillsController.groupBillsByMCP(billsResponse);
        
        system.assertEquals(2, billsResponse.BillsByMCP.size(), 'There should be 2 mcp bills groupings.');
    }

    @isTest
    static void sortGroupsByMCP_twoMCPGroupingsWithAccountMCPInFirstGrouping_expectAccountMCPGroupingFirstTest() {
        ProductBillingBillsController.BillsResponse billsResponse = instantiateBillsResponse();
        ProductBillingBillsController.MCPBillsGrouping firstGrouping = 
            addMCPBillsGrouping(billsResponse, billsResponse.Account.MCP_Number__c);

        addMCPBillsGrouping(billsResponse, billsResponse.Account.MCP_Number__c + 'otherMCP');
        
        ProductBillingBillsController.sortGroupsByMCP(billsResponse);
        
        system.assertEquals(firstGrouping, billsResponse.BillsByMCP[0], 'The account mcp is not the first one.');
    }

    @isTest
    static void sortGroupsByMCP_twoMCPGroupingsWithAccountMCPInSecondGrouping_expectAccountMCPGroupingFirstTest() {
        ProductBillingBillsController.BillsResponse billsResponse = instantiateBillsResponse();
        addMCPBillsGrouping(billsResponse, billsResponse.Account.MCP_Number__c + 'otherMCP');

        ProductBillingBillsController.MCPBillsGrouping secondGrouping = 
            addMCPBillsGrouping(billsResponse, billsResponse.Account.MCP_Number__c);
        
        ProductBillingBillsController.sortGroupsByMCP(billsResponse);
        
        system.assertEquals(secondGrouping, billsResponse.BillsByMCP[0], 'The account mcp is not the first one.');
    }

    @isTest
    static void sortGroupsByMCP_twoMCPGroupingsWithNoAccountMCP_expectSortedByCustomerNameAscendingTest() {
        ProductBillingBillsController.BillsResponse billsResponse = instantiateBillsResponse();
        String notAccountMCP = billsResponse.Account.MCP_Number__c + 'otherMCP';
        
        ProductBillingBillsController.MCPBillsGrouping firstGrouping = 
            addMCPBillsGrouping(billsResponse, notAccountMCP);
        firstGrouping.CustomerName = 'Customer B';

        ProductBillingBillsController.MCPBillsGrouping secondGrouping = 
            addMCPBillsGrouping(billsResponse, notAccountMCP);
        secondGrouping.CustomerName = 'Customer A';
        
        ProductBillingBillsController.sortGroupsByMCP(billsResponse);
        
        system.assertEquals(secondGrouping, billsResponse.BillsByMCP[0], 'The mcp groupings were not sorted by customer name.');
    }
    
    static ProductBillingBillsController.BillsResponse getBills(Id accountId, Boolean includeCurrent, Boolean includeHistorical) {
        Test.startTest();
        
        ProductBillingBillsController.BillsResponse response = ProductBillingBillsController.getBills(accountId, includeCurrent, includeHistorical);
        
        Test.stopTest();
        
        return response;
    }

    static void setBrowseBillsResponseMock(HttpCalloutMock responseMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(ESBBillingServiceClientTest.DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        requests.put(ESBBillingServiceClientTest.DEFAULT_ENDPOINT + ESBBillingServiceClient.CONSOLIDATED_BILLING_API_PATH, responseMock);

        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    static ProductBillingBillsController.BillsResponse instantiateBillsResponse() {
        ProductBillingBillsController.BillsResponse billsResponse =
            new ProductBillingBillsController.BillsResponse();

        Account acct = AccountTestData.Instance.withMCPNumber('P13918').create();
        billsResponse.Account = acct;
        
        billsResponse.BrowseBillResponse = new ESBBillingServiceClient.BrowseBillsResponse();
        
        return billsResponse;
    }
    
    static ProductBillingBillsController.MCPBillsGrouping addMCPBillsGrouping(ProductBillingBillsController.BillsResponse billsResponse, String mcpNumber) {
        ProductBillingBillsController.MCPBillsGrouping mcpGrouping = new ProductBillingBillsController.MCPBillsGrouping();
        mcpGrouping.MCP = mcpNumber;
        mcpGrouping.AccountMCP = billsResponse.Account.MCP_Number__c;
        
        billsResponse.BillsByMCP.add(mcpGrouping);
        
        return mcpGrouping;
    }
    
    static void addBill(ProductBillingBillsController.BillsResponse billsResponse, String mcpNumber, String customerName) {
        ESBBillingServiceClient.ConsolidatedBill bill = new ESBBillingServiceClient.ConsolidatedBill();
        bill.CustomerMCPNumber = mcpNumber;
        bill.CustomerMCPName = customerName;
        
        billsResponse.BrowseBillResponse.Bills.add(bill);
    }
}