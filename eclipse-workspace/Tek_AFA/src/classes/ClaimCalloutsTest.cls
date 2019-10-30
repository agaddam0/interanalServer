@isTest
public class ClaimCalloutsTest {
    
    public static void Init()
    {
        API_Manager__c api = new API_Manager__c();
        api.Name = 'QA';
        api.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        api.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        api.Endpoint__c = 'https://api-qa.americanfidelity.com:443';
        api.Host__c = 'api-qa.americanfidelity.com:443';
        api.Password__c = 'MyFakeQAPW';
        api.Username__c = 'MyFakeQAUN';
        insert api;
        
        api = new API_Manager__c();
        api.Name = 'Prod';
        api.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        api.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        api.Endpoint__c = 'https://api-qa.americanfidelity.com:443';
        api.Host__c = 'api-qa.americanfidelity.com:443';
        api.Password__c = 'MyFakeProdPW';
        api.Username__c = 'MyFakeProdUN';
        insert api;
    }
    
    public static testMethod void testGetBearerToken()
    {
        Init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        String token = ClaimCallouts.getBearerToken();
        system.assertEquals('e5f7d671d2e108aca1c5063df635c96d', token);
        Test.stopTest();
    }
    
    public static testMethod void testGetDisabilityClaimsByCustomer()
    {
        Init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        ClaimCallouts.GetDisabilityClaimsByCustomer();
        ClaimCallouts.GetEOBDataByClaimNumber();
        Test.stopTest();
    }
    
    public static testMethod void testGetSupplementalMedClaimsByCustomer()
    {
        Init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        ClaimCallouts.GetSupplementalMedClaimsByCustomer();
        Test.stopTest();
    }
    
    public static testMethod void testGetIndividualCustomerProfile()
    {
        Init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        ClaimCallouts.GetIndividualCustomerProfile();
        Test.stopTest();
    }
    
    public static testMethod void testGetElectionByEmployeeSSN()
    {
        Init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        ClaimCallouts.GetElectionByEmployeeSSN();
        ClaimCallouts.GetProductByElectionId();
        ClaimCallouts.GetClaimsByElectionId();
        ClaimCallouts.GetClaimDetailsByClaimID();
        Test.stopTest();
    }
    
    public static testMethod void testBuildClaims()
    {
        Init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        ClaimCallouts.BuildProductClaims('123456');
        Test.stopTest();
    }
    
    public static testMethod void testBuildFlexAccount()
    {
        Init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        ClaimCallouts.BuildFlexAccount('123456');
        Test.stopTest();
    }
    
    public static testMethod void testPolicyHolderClaimEXT()
    {
        Init();
        
        Util u = new Util();
        
        Account a = u.createOneAcc('Test Account', true, null);
        
        Policyholder__c h = new Policyholder__c();
        h.First_Name__c = 'Test';
        h.Last_Name__c = 'Test';
        h.Customer_Number__c = '123456';
        h.Social_Security_Number__c = '111-22-3333';
        insert h;
        
        // Flex Claims
        PageReference pageRef = Page.PolicyHolderFlexClaims;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', h.Id);
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        
        ApexPages.StandardController sc = new ApexPages.StandardController(h);
        PolicyHolderClaimEXT ext = new PolicyHolderClaimEXT(sc);
       
        // Product Claims
        pageRef = Page.PolicyHolderProductClaims;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', h.Id);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        
        sc = new ApexPages.StandardController(h);
        ext = new PolicyHolderClaimEXT(sc);
        
        // Causes Error on Page
        pageRef = Page.PolicyHolderProductClaims;
        Test.setCurrentPage(pageRef);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockGenerator());
        
        sc = new ApexPages.StandardController(h);
        ext = new PolicyHolderClaimEXT(sc);
        
        Test.stopTest();
    }
}