@isTest
public class PolicyholderListCompTester {
    
    @testSetup
    static void testData()
    {
         Util u = new Util();
        
        Account a = u.createOneAcc('Policyholder List Account', true, null);
        
        Policyholder__c h = new Policyholder__c();
        h.First_Name__c = 'Policyholder Account';
        h.Last_Name__c = 'Test';
        h.Customer_Number__c = '2233445566';
        h.Social_Security_Number__c = '111-22-3333';
        h.Birthdate__c = Date.newInstance(1983, 10, 15);
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
    static void PolicyholderListComponentControllerTest()
    {
        Account a = [SELECT Id FROM Account WHERE Name =: 'Policyholder List Account'];
        
        List<Policyholder__c> policyholders = PolicyholderListCompController.getPolicyholders(a.Id, '', '', null, false);
        
        system.assertEquals(1, policyholders.size());
    }
    
    @isTest
    static void PolicyholderListComponentControllerTestKeywordSearch()
    {
        Account a = [SELECT Id FROM Account WHERE Name =: 'Policyholder List Account'];
        Boolean ascending;
        List<Policyholder__c> policyholders = PolicyholderListCompController.getPolicyholders(a.Id, 'Other', 'Test', '1983-10-15', ascending);
        
        system.assertEquals(1, policyholders.size());
    }
    
    @isTest
    static void PolicyholderListComponentControllerTestAll()
    {
        Account a = [SELECT Id FROM Account WHERE Name =: 'Policyholder List Account'];
        Boolean ascending;
        List<Policyholder__c> policyholders = PolicyholderListCompController.getPolicyholders(a.Id, 'All', '', '', true);
        
        system.assertEquals(1, policyholders.size());
    }
    
    @isTest
    static void PolicyholderListComponentControllerTestAlphaFilter()
    {
        Account a = [SELECT Id FROM Account WHERE Name =: 'Policyholder List Account'];
        Boolean ascending;
        List<Policyholder__c> policyholders = PolicyholderListCompController.getPolicyholders(a.Id, 'T', '', '', true);
        
        system.assertEquals(1, policyholders.size());
    }
}