@isTest
public with sharing class ProductBillReportControllerTest {
    private static ProductBillReportController Controller;
    
    @testSetup
    static void setup() {
        Account acct = AccountTestData.Instance.insertAccount();

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
    static void controllerInstantiated_withBillIdAndAccountId_expectNoErrorsTest() {
        loadDefaultController();
        
        system.assertEquals(true, Controller.ProductsWithFilter, 'The products with filter was not set to true.');
    }

    @isTest
    static void downloadToPDF_Invoke_expectRenderAsSetToPDFTest() {
        setBrowseByCBillIdResponseMock(new ESBBillingServiceClientTest.BrowseByCBillIdSuccessWithOneDetailMock());
        
        loadDefaultController();
        
        Test.startTest();
        
        Controller.downloadToPDF();
        
        Test.stopTest();
        
        system.assertEquals('pdf', Controller.RenderAs, 'The page is not rendering as a pdf.');
    }

    @isTest
    static void getBillDetails_billHasOnePolicyHolder_expectOnePolicyHolderReturnedTest() {
        setBrowseByCBillIdResponseMock(new ESBBillingServiceClientTest.BrowseByCBillIdSuccessWithOneDetailMock());
        
        loadDefaultController();
        
        Test.startTest();
        
        Controller.getBillDetails();
        
        Test.stopTest();
        
        system.assert(String.isBlank(Controller.ErrorMessage), 'The following error occurred: ' + Controller.ErrorMessage);
        system.assert(Controller.Bill != null, 'The bill was not returned.');
        system.assertEquals(1, Controller.Bill.PolicyHolders.size(), 'The bill does not have 1 policy holder.');
        
        system.assertEquals(1, Controller.PolicyHolderLists.size(), 'There should be 1 policy holder list');
        system.assertEquals(1, Controller.PolicyHolderLists[0].size(), 'There should be 1 policy holder in the first policy holder list');
    }

    @isTest
    static void getBillDetails_errorGettingBillInfo_expectErrorMessageHasErrorTest() {
        setBrowseByCBillIdResponseMock(new ESBBillingServiceClientTest.BrowseByCBillIdSystemErrorMock());
        
        loadDefaultController();
        
        Controller.getBillDetails();
        
        system.assertEquals(null, Controller.Bill, 'The bill should not be populated.');
        system.assert(String.isNotBlank(Controller.ErrorMessage), 'The controller\'s error message is not populated.');
    }
    
    @isTest
    static void filter_noFilters_expectNoFilterAppliedTest() {
        loadDefaultController();

        addPolicyHolderToController('FirstName', 'LastName');
        
        Controller.filter();
        
        system.assertEquals(1, Controller.PolicyHolderLists[0].size(), 'There should be 1 policy holder in the first policy holder list');
        system.assertEquals(false, Controller.FilterApplied, 'There should be no filter applied.');
    }
    
    @isTest
    static void filter_oneNameFilterSuppliedWithOneMatchingPolicyHolder_expectOnePolicyHolderShownTest() {
        loadDefaultController();

        String firstName = 'firstName';
        String lastName = 'lastName';

        addPolicyHolderToController(firstName, lastName);
        addPolicyHolderToController(firstName + '2', lastName + '2');
        
        Controller.NamesFilter = firstName + ' ' + LastName;
        Controller.filter();
        
        system.assertEquals(1, Controller.PolicyHolderLists[0].size(), 'There should be 1 policy holder in the first policy holder list');
        system.assertEquals(true, Controller.FilterApplied, 'There should be a filter applied.');
    }

    @isTest
    static void filter_oneNameFilterSuppliedWithNoMatchingPolicyHolder_expectNoPolicyHolderShownTest() {
        loadDefaultController();

        String firstName = 'firstName';
        String lastName = 'lastName';

        addPolicyHolderToController(firstName, lastName);
        addPolicyHolderToController(firstName + '2', lastName + '2');
        
        Controller.NamesFilter = 'non existent Name';
        Controller.filter();
        
        system.assertEquals(0, Controller.PolicyHolderLists.size(), 'There should be no policy holder in the policy holder lists');
        system.assertEquals(true, Controller.FilterApplied, 'There should be a filter applied.');
    }
    
    @isTest
    static void filter_oneProductFilterSuppliedUsingWithProductButNoMatchingProduct_expectNoPolicyHolderShownTest() {
        loadDefaultController();

        String firstName = 'firstName';
        String lastName = 'lastName';

        addPolicyHolderToController(firstName, lastName);
        
        Controller.ProductsFilter = 'nonExistentProduct';
        Controller.filter();
        
        system.assertEquals(0, Controller.PolicyHolderLists.size(), 'There should be no policy holder in the policy holder lists');
        system.assertEquals(true, Controller.FilterApplied, 'There should be a filter applied.');
    }
    
    @isTest
    static void filter_oneProductFilterSuppliedUsingWithProductAndOneMatchingProduct_expectOnePolicyHolderShownTest() {
        loadDefaultController();
        
        String products = 'Cancer';
        
        addPolicyHolderToController('firstName', 'LastName', products);
        
        Controller.ProductsFilter = products;
        Controller.filter();
        
        system.assertEquals(1, Controller.PolicyHolderLists[0].size(), 'There should be 1 policy holder in the first policy holder list');
    }

    @isTest
    static void filter_oneProductFilterSuppliedUsingWithProductAndTwoPolicyHoldersButOneMatchingProduct_expectOnePolicyHolderShownTest() {
        loadDefaultController();
        
        String products = 'Cancer';
        String otherProducts = 'Disab';
        
        addPolicyHolderToController('firstName', 'LastName', products);
        addPolicyHolderToController('firstName2', 'LastName2', otherProducts);
        
        Controller.ProductsFilter = products;
        Controller.filter();
        
        system.assertEquals(1, Controller.PolicyHolderLists[0].size(), 'There should be 1 policy holder in the first policy holder list');
    }

    @isTest
    static void filter_oneProductFilterSuppliedUsingWithoutProductAndTwoPolicyHoldersButNoMatchingProduct_expectTwoPolicyHolderShownTest() {
        loadDefaultController();
        
        String products = 'Cancer';
        String otherProducts = 'Disab';
        
        addPolicyHolderToController('firstName', 'LastName', products);
        addPolicyHolderToController('firstName2', 'LastName2', otherProducts);
        
        Controller.ProductsFilter = 'nonexistentproducts';
        Controller.ProductsWithFilter = false;
        Controller.filter();
        
        system.assertEquals(2, Controller.PolicyHolderLists[0].size(), 'There should be 2 policy holders in the first policy holder list');
    }
    
    @isTest
    static void filter_oneProductAndOneNameSuppliedUsingWithProductAndTwoPolicyHoldersButOneMatchFound_expectOnePolicyHolderTest() {
        loadDefaultController();
        
        String products = 'Cancer';
        String otherProducts = 'Disab';
        
        addPolicyHolderToController('firstName', 'LastName', products);
        addPolicyHolderToController('firstName2', 'LastName2', otherProducts);
        
        Controller.NamesFilter = 'firstName LastName';
        Controller.ProductsFilter = products;
        Controller.filter();

        system.assertEquals(1, Controller.PolicyHolderLists[0].size(), 'There should be 1 policy holder in the first policy holder list');
    }
    
    @isTest
    static void clearFilter_filterAppliedAndThenFilterCleared_expectTwoPolicyHoldersShownTest() {
        loadDefaultController();

        String firstName = 'firstName';
        String lastName = 'lastName';

        addPolicyHolderToController(firstName, lastName);
        addPolicyHolderToController(firstName + '2', lastName + '2');
        
        Controller.NamesFilter = firstName + ' ' + LastName;
        Controller.filter();
        
        system.assertEquals(1, Controller.PolicyHolderLists[0].size(), 'There should be 1 policy holder in the first policy holder list');
        system.assertEquals(true, Controller.FilterApplied, 'There should be a filter applied.');
        
        Controller.clearFilter();
        
        system.assertEquals(2, Controller.PolicyHolderLists[0].size(), 'There should be 2 policy holders in the first policy holder list');
        system.assertEquals(false, Controller.FilterApplied, 'There should be no filter applied.');
        system.assertEquals('', Controller.NamesFilter, 'The names filter should be cleared.');
        system.assertEquals('', Controller.ProductsFilter, 'The products filter should be cleared.');
    }

    static void loadDefaultController() {
        Test.setCurrentPage(Page.ProductBillReport);
        Map<String, String> pageParameters = ApexPages.currentPage().getParameters();
        pageParameters.put('billId', '19381');
        
        Account someAcct =
        [SELECT Id
           FROM Account];
        
        pageParameters.put('accountId', someAcct.Id);
        
        Controller = new ProductBillReportController();
    }

    static void setBrowseByCBillIdResponseMock(HttpCalloutMock responseMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(ESBBillingServiceClientTest.DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        requests.put(ESBBillingServiceClientTest.DEFAULT_ENDPOINT + ESBBillingServiceClient.ADMIN_COVERAGE_BILLING_API_PATH, responseMock);

        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    static void addPolicyHolderToController(String firstName, String lastName) {
        addPolicyHolderToController(firstName, lastName, '');
    }
    
    static void addPolicyHolderToController(String firstName, String lastName, String products) {
        if (Controller.Bill == null) {
            Controller.Bill = new ESBBillingServiceClient.ConsolidatedBill();
        }
        
        ESBBillingServiceClient.PolicyHolder ph = new ESBBillingServiceClient.PolicyHolder();
        ph.FirstName = firstName;
        ph.LastName = lastName;
        
        Controller.Bill.PolicyHolders.add(ph);
        
        List<String> productsList = products.replace(', ', '').split(',');
        
        for (String product : productsList) {
            ESBBillingServiceClient.Policy p = new ESBBillingServiceClient.Policy();
            p.Product = product;
            
            ph.Policies.add(p);
        }
    }
}