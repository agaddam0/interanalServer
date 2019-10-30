@isTest
public class PurchProductBLogicTest {
/* Commented For Deletion    
    @testSetup
    static void testData()
    {
        Util util = new Util();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='uname@testorg.com.jrsandbox.test');
        
        insert usr;
        
        Account a = new Account();
        System.runAs(usr){
            a = util.createOneAcc('Apex Test Account ', false, Constants.ACCOUNT_CUSTOMER_ACCOUNT);
            a.OwnerId = usr.Id;
            a.Status__c = 'Active';
            insert a;
        }
        
        Policyholder__c h = new Policyholder__c();
        h.Social_Security_Number__c = '4444444444';
        h.Customer_Number__c = '123456789';
        h.First_Name__c = 'Apex';
        h.Last_Name__c = 'Test';
        insert h;
    }
    
    static TestMethod void UpdatePolicyHolderOnPurchProductCreate()
    {
        Account a = [SELECT Id, OwnerId FROM Account WHERE Name like 'Apex Test Account%'];
        Policyholder__c h = [SELECT Id, OwnerId FROM Policyholder__c WHERE Customer_Number__c = '123456789'];
        
        system.debug('Account owner: ' + a.OwnerId);
        system.debug('Policyholder Owner: ' + h.OwnerId);
        
        Purchased_Product__c pp = new Purchased_Product__c();
        pp.Policyholder__c = h.Id;
        pp.Account__c = a.Id;
        
        test.startTest();
        insert pp;
        test.stopTest();
        
        Policyholder__c newph = [SELECT OwnerId, Id FROM Policyholder__c WHERE Id =: h.Id];
        
        system.assertEquals(a.OwnerId, newph.OwnerId);
    }
    
    static TestMethod void UpdatePolicyHoldersOnAccountOwnerChangeTest()
    {
        Account a = [SELECT Id, OwnerId FROM Account WHERE Name like 'Apex Test Account%'];
        
        a.OwnerId = system.UserInfo.getUserId();
        test.startTest();
        update a;
        test.stopTest();
        
        Policyholder__c newph = [SELECT Id, OwnerId FROM Policyholder__c WHERE Customer_Number__c = '123456789']; 
        
        system.assertEquals(system.UserInfo.getUserId(), newph.OwnerId);
    }
*/
}