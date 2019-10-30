@isTest
public with sharing class PlanSummaryRedirectControllerTest {

    @isTest
    public static void getAccountIdTest_returnsAccountId(){
        Account testAccount = AccountTestData.Instance.insertCustomerAccount();
        Opportunity testOpportunity = OpportunityTestData.Instance.withAccount(testAccount.Id).insertAWDOpportunity();

        Test.startTest();

        String accountId = PlanSummaryRedirectController.getAccountId(testOpportunity.Id);

        test.stopTest();

        system.assertEquals(testAccount.Id, accountId, 'The account id was not returned');
    }

    @isTest
    public static void getAccoutnIdTest_returnsNull(){

        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opp With No Account';
        testOpportunity.StageName = 'Prospecting';
        testOpportunity.CloseDate = system.today();
        insert testOpportunity;

        Test.startTest();

        String accountId = PlanSummaryRedirectController.getAccountId(testOpportunity.Id);

        test.stopTest();

        system.assertEquals(null, accountId, 'An account is was returned but should be null');
    }
}