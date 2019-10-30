@isTest
public with sharing class UpdatePolicyholderOwnerBatchTest {
    @testSetup
    static void testData()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='uname@testorg.com.jrsandbox.test');
        
        insert usr;
        
        System.runAs(usr){
            AccountTestData.Instance.withCustomerAccount()
                                    .withOwner(usr.Id)
                                    .withStatus('Active')
                                    .insertAccount();
        }
        
        Policyholder__c h = PolicyholderTestData.Instance.insertPolicyholder();
    }
    
    @isTest
    static void executeJob_newPurchasedProductWithDifferentOwner_expectPolicyHolderOwnerNowOwnedByAccountOwnerTest() {
        Account defaultAccount = getDefaultAccount();
        Policyholder__c defaultPolicyholder = getDefaultPolicyholder();
        
        Purchased_Product__c newPurchasedProduct = PurchasedProductTestData.Instance.withAccount(defaultAccount.Id)
                                                                                    .withPolicyholder(defaultPolicyholder.Id)
                                                                                    .insertPurchasedProduct();

        executeJob();
        
        assertDefaultPolicyholderOwnerOwnedBy(defaultAccount.OwnerId);
    }

    @isTest
    static void executeJob_accountOwnerChanges_expectPolicyHolderOwnerNowOwnedByNewAccountOwnerTest() {
        Account defaultAccount = getDefaultAccount();
        Policyholder__c defaultPolicyholder = getDefaultPolicyholder();
        
        defaultAccount.OwnerId = defaultPolicyholder.OwnerId;
        update defaultAccount;
        
        Purchased_Product__c newPurchasedProduct = PurchasedProductTestData.Instance.withAccount(defaultAccount.Id)
                                                                                    .withPolicyholder(defaultPolicyholder.Id)
                                                                                    .insertPurchasedProduct();

        assertDefaultPolicyholderOwnerOwnedBy(defaultPolicyholder.OwnerId);

        defaultAccount.OwnerId = UserInfo.getUserId();

        executeJob();
        
        assertDefaultPolicyholderOwnerOwnedBy(defaultAccount.OwnerId);
    }

    @isTest
    static void executeJob_accountOwnerChangesButAccountInactive_expectPolicyHolderOwnerUnchangedTest() {
        Account defaultAccount = getDefaultAccount();
        Policyholder__c defaultPolicyholder = getDefaultPolicyholder();
        
        defaultAccount.Status__c = 'Inactive';
        update defaultAccount;
        
        Purchased_Product__c newPurchasedProduct = PurchasedProductTestData.Instance.withAccount(defaultAccount.Id)
                                                                                    .withPolicyholder(defaultPolicyholder.Id)
                                                                                    .insertPurchasedProduct();

        executeJob();
        
        assertDefaultPolicyholderOwnerOwnedBy(defaultPolicyholder.OwnerId);
    }

    @isTest
    static void executeJob_accountOwnerChangesButPurchasedProductInactive_expectPolicyHolderOwnerUnchangedTest() {
        Account defaultAccount = getDefaultAccount();
        Policyholder__c defaultPolicyholder = getDefaultPolicyholder();
        
        defaultAccount.Status__c = 'Inactive';
        update defaultAccount;
        
        Purchased_Product__c newPurchasedProduct = PurchasedProductTestData.Instance.withAccount(defaultAccount.Id)
                                                                                    .withPolicyholder(defaultPolicyholder.Id)
                                                                                    .withPolicyStatus('Inactive')
                                                                                    .insertPurchasedProduct();

        executeJob();
        
        assertDefaultPolicyholderOwnerOwnedBy(defaultPolicyholder.OwnerId);
    }
    
    @isTest
    static void scheduleDailyEveryTwoHours_run_codeCoverageTest() {
        try {
            UpdatePolicyholderOwnerBatch.scheduleDailyEveryTwoHours();
        }
        catch(Exception ex) { }
    }
    
    static void executeJob() {
        Test.startTest();
        
        new UpdatePolicyholderOwnerBatch().execute(null);
        
        Test.stopTest();
    }
    
    static Policyholder__c getDefaultPolicyholder() {
        return
        [SELECT Id,
                OwnerId
           FROM Policyholder__c];
    }
    
    static Account getDefaultAccount() {
        return
        [SELECT Id,
                OwnerId
           FROM Account];
    }
    
    static void assertDefaultPolicyholderOwnerOwnedBy(Id expectedOwnerId) {
        Policyholder__c defaultPolicyholder = getDefaultPolicyholder();
        
        system.assertEquals(expectedOwnerId, defaultPolicyholder.OwnerId, 'The policy holder\'s owner is not the expected one.');
    }
}