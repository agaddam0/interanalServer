@isTest
public with sharing class AppointmentSchedulerControllerTest {
    private static final String DEFAULT_ENDPOINT = 'https://api-qa.americanfidelity.com:443';
    
    static void assertNoEligibleAccounts() {
        List<Account> eligibleAccounts = AppointmentSchedulerController.getEligibleAccounts();
        
        system.assert(eligibleAccounts != null, 'The eligible accounts are null.');
        system.assertEquals(0, eligibleAccounts.size(), 'No accounts should be found.');
    }
    
    static void assertEligibleAccountFound(Account expectedEligibleAccount) {
        system.assert(expectedEligibleAccount != null, 'The expectedEligibleAccount is null.');
        
        List<Account> eligibleAccounts = AppointmentSchedulerController.getEligibleAccounts();
        
        system.assert(eligibleAccounts != null, 'The eligible accounts are null.');
        system.assertEquals(1, eligibleAccounts.size(), 'There should be one eligible account.');
        system.assertEquals(expectedEligibleAccount.Id, eligibleAccounts[0].Id, 'The expected account was not returned.');
    }
    
    @testSetup
    private static void setup() {
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
    
    @isTest
    static void getEligibleAccounts_accountHasNoMarketingResourceId_expectNoAccountsReturnedTest() {
        Account noMarketingResourceIdAccount = AccountTestData.Instance.withMarketingResourceId(null).insertCustomerAccount();
        
        assertNoEligibleAccounts();
    }
    
    @isTest
    static void getEligibleAccounts_accountHasMarketingResourceIdButLapsed_expectNoAccountsReturnedTest() {
        Account account = AccountTestData.Instance.withMarketingResourceId('1230a-12lkjasd0-asdf')
                                                  .withStatus('Lapsed')
                                                  .insertCustomerAccount();
        
        assertNoEligibleAccounts();
    }
    
    @isTest
    static void getEligibleAccounts_accountHasEmployerBenefitsSiteRequestDateTimeAndNotLapsed_expectAccountReturnedTest() {
        Account account = AccountTestData.Instance.withEmployerBenefitsSiteRequestDateTime(DateTime.now())
                                                  .withMarketingResourceId(null)
                                                  .withStatus('Active')
                                                  .insertCustomerAccount();
                                                  
        assertNoEligibleAccounts();
    }
    
    @isTest
    static void getEligibleAccounts_accountHasMarketingResourceIdAndNotLapsed_expectAccountReturnedTest() {
        Account account = AccountTestData.Instance.withMarketingResourceId('1230a-12lkjasd0-asdf')
                                                  .withStatus('Active')
                                                  .insertCustomerAccount();
        
        assertEligibleAccountFound(account);
    }
    
    @isTest
    static void getEmployerAppointmentSchedulerURL_nullAccountId_expectNoAccountIdErrorMessageTest() {
        Id nullAccountId = null;
        
        AppointmentSchedulerController.EmployerAppointmentSchedulerResponse response = AppointmentSchedulerController.getEmployerAppointmentSchedulerURL(nullAccountId);
        
        system.assert(response != null, 'The response is null.');
        system.assert(String.isNotBlank(response.ErrorMessage), 'An error message is expected.');
        system.assert(response.ErrorMessage.containsIgnoreCase(ESBFieldSchedulerTokenServiceClient.ACCOUNT_ID_REQUIRED_MESSAGE), 'The expected error message was not found.');
    }
    
    @isTest
    static void getEmployerAppointmentSchedulerURL_eligibleAccountGiven_expectTokenReturnedTest() {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, new ESBAuthenticatorTest.AuthenticateSuccessfulMock());
        requests.put(DEFAULT_ENDPOINT + ESBFieldSchedulerTokenServiceClient.FIELD_SCHEDULER_TOKEN_PATH, new FieldSchedulerTokenSuccessfulMock());
        
        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
        
        Account eligibleAccount = AccountTestData.Instance.withMarketingResourceId('1230a-12lkjasd0-asdf')
                                                          .withStatus('Active')
                                                          .insertCustomerAccount();
        
        Test.startTest();
        
        AppointmentSchedulerController.EmployerAppointmentSchedulerResponse response = AppointmentSchedulerController.getEmployerAppointmentSchedulerURL(eligibleAccount.Id);
        
        Test.stopTest();
        
        system.assert(response != null, 'The response is null.');
        system.assert(String.isBlank(response.ErrorMessage), 'An error message is not expected.');
        system.assert(String.isNotBlank(response.EmployerAppointmentSchedulerURL), 'The employer appointment scheduler url is blank.');
    }
    
    public with sharing class FieldSchedulerTokenSuccessfulMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"Token":"3e2b8485-2b5c-481d-bfee-bef1ef9006bd","Errors":[],"Status":"OK","TimeTaken":0}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public with sharing class FieldSchedulerTokenFailedMock implements HttpCalloutMock {
        private String failureError { get; set; }
        
        public FieldSchedulerTokenFailedMock(String error) {
            failureError = error;
        }
        
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/JSON');
            res.setBody('{"Errors":["' + failureError + '"],"Status":"Error","TimeTaken":0}');
            res.setStatusCode(500);
            return res;
        }
    }
}