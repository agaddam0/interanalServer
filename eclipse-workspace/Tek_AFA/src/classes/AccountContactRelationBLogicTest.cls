@isTest
public class AccountContactRelationBLogicTest {
    
    @testSetup static void testData()
    {
        Account a1 = AccountTestData.Instance.withName('Contact Test Account ONE').insertCustomerAccount();
        Account a2 = AccountTestData.Instance.withName('Contact Test Account TWO').insertCustomerAccount();
        Account a3 = AccountTestData.Instance.withName('Contact Test Account THREE').insertCustomerAccount();
        
        Contact c = new Contact();
        c.AccountId = a1.Id;
        c.FirstName = 'Contact1 Test';
        c.LastName = 'Contact1 Test';
        c.email = 'Contact1Contact1@test.com';
        c.Decision_Maker__c = true;
        c.Duplicate__c = false;
        c.Inactive__c = false;
        
        insert c;
        
        AccountContactRelation ACR = new AccountContactRelation();
        ACR.ContactId = c.Id;
        ACR.AccountId = a3.Id;
        
        insert ACR;
    }
    
    @isTest
    static void insertAccountContactRelationDecisionMakerTest()
    {
        Account a2 = [SELECT Id, Number_Decision_Maker_Contacts__c FROM Account WHERE Name = 'Contact Test Account TWO'];
        Contact c = [SELECT Id FROM Contact WHERE email = 'Contact1Contact1@test.com'];
        
        AccountContactRelation ACR = new AccountContactRelation();
        ACR.ContactId = c.Id;
        ACR.AccountId = a2.Id;
        
        test.startTest();
        insert ACR;
        test.stopTest();
        
        a2 = [SELECT Id, Number_Decision_Maker_Contacts__c FROM Account WHERE Name = 'Contact Test Account TWO'];
        
        system.assertEquals(1, a2.Number_Decision_Maker_Contacts__c);
    }
    
    @isTest
    static void deleteAccountContactRelationDecisionMakerTest()
    {
        Account a3 = [SELECT Id, Number_Decision_Maker_Contacts__c FROM Account WHERE Name = 'Contact Test Account THREE'];
        
        AccountContactRelation ACR = [SELECT Id FROM AccountContactRelation WHERE AccountId =: a3.Id];
        
        test.startTest();
        delete ACR;
        test.stopTest();
        
        a3 = [SELECT Id, Number_Decision_Maker_Contacts__c FROM Account WHERE Name = 'Contact Test Account THREE'];
        system.assertEquals(0, a3.Number_Decision_Maker_Contacts__c);
    }
    
    @isTest
    static void deleteContactDecisionMakerRollup()
    {
        Contact c = [SELECT Id, Decision_Maker__c, Inactive__c, Duplicate__c FROM Contact WHERE email = 'Contact1Contact1@test.com'];
        
        test.startTest();
        delete c;
        test.stopTest();
        
        Account a1 = [SELECT Id, Number_Decision_Maker_Contacts__c FROM Account WHERE Name = 'Contact Test Account ONE'];
        system.assertEquals(0, a1.Number_Decision_Maker_Contacts__c);
    }
}