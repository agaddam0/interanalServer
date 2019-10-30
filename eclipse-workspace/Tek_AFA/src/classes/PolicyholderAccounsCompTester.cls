@isTest
public class PolicyholderAccounsCompTester {
	@testSetup
    static void testData()
    {
         Util u = new Util();
        
        Account a = u.createOneAcc('Test Account', true, null);
        
        Policyholder__c h = new Policyholder__c();
        h.First_Name__c = 'Policyholder Account';
        h.Last_Name__c = 'Test';
        h.Customer_Number__c = '1122334455';
        h.Social_Security_Number__c = '111-22-3333';
        insert h;
        
        Purchased_Product__c p = new Purchased_Product__c();
        p.Account__c = a.Id;
        p.Policyholder__c = h.Id;
        p.Policy_Status__c = 'Active';
        p.Product_Family__c = 'Disability';
        p.Product_Description__c = 'Disability Description';
        insert p;
    }
    
    @isTest
    static void testPolicyholderAccountsComponentController()
    {
        Policyholder__c holder = [SELECT Id FROM Policyholder__c WHERE Customer_Number__c = '1122334455'];
        
        List<Account> results = PolicyholderAccountsCompController.getAccounts(holder.Id);
        
        system.assertEquals(1, results.size());
    }
}