@isTest
public with sharing class CurrentBillsBatchUpdaterTest {
    
    @testSetup
    static void setup() {
        ESBBillingServiceClientTest.setup();
    }
    
    @isTest
    static void run_noPayorNumberAccounts_expectNoErrorsTest() {
        String errorMsg = '';
        
        try {
            run();
        }
        catch(Exception ex) {
            errorMsg = ex.getMessage();
        }

        system.assertEquals('', errorMsg, 'There was an error running the job with no payor number accounts.');
    }

    @isTest
    static void getBatchSize_NoCurrentBillsSyncSettings_expectBatchSizeIs99Test() {
        Integer batchSize = CurrentBillsBatchUpdater.getBatchSize();
        Integer expectedBatchSize = CurrentBillsBatchUpdater.DEFAULT_BATCH_SIZE - 1;
        
        system.assertEquals(expectedBatchSize, batchSize, 'The batch size should be one less than the default.');
    }

    @isTest
    static void getBatchSize_settingsHasSmallerBatchSize_expectSmallerBatchSizeUsedTest() {
        Current_Bills_Sync_Settings__c settings = new Current_Bills_Sync_Settings__c();
        settings.Batch_Size__c = 50;
        insert settings;
        
        Integer batchSize = CurrentBillsBatchUpdater.getBatchSize();
        system.assertEquals(settings.Batch_Size__c, batchSize, 'The batch size does not equal the settings\' batch size.');
    }

    @isTest
    static void getBatchSize_settingsBatchSizeExceedsCalloutLimit_expectBatchSizeIsOneLessThanCalloutLimitTest() {
        Current_Bills_Sync_Settings__c settings = new Current_Bills_Sync_Settings__c();
        settings.Batch_Size__c = Limits.getLimitCallouts() + 50;
        insert settings;
        
        Integer onesLessThanCalloutLimit = Limits.getLimitCallouts() - 1;
        Integer batchSize = CurrentBillsBatchUpdater.getBatchSize();
        system.assertEquals(onesLessThanCalloutLimit, batchSize, 'The batch size is not one less than the callout limit.');
    }

    @isTest
    static void run_onePayorNumberAccountWithNoCurrentBills_expectNoCurrentBillsInsertedTest() {
        ESBBillingServiceClientTest.setBrowseBillsResponseMock(new ESBBillingServiceClientTest.BrowseByPayorNoBillsFoundMock());

        Account payorNumberAccount = AccountTestData.Instance.withPayorNumber('193819').insertCustomerAccount();
        
        run();
        
        List<Current_Bill__c> currentBills = getCurrentBills();
        
        system.assertEquals(0, currentBills.size(), 'There should be no bills.');
    }

    @isTest
    static void run_onePayorNumberAccountWithOneCurrentBill_expectOneCurrentBillInsertedTest() {
        ESBBillingServiceClientTest.setBrowseBillsResponseMock(new ESBBillingServiceClientTest.BrowseByPayorOneBillFoundMock());

        Account payorNumberAccount = AccountTestData.Instance.withPayorNumber('193819').insertCustomerAccount();
        
        run();
        
        List<Current_Bill__c> currentBills = getCurrentBills();
        
        system.assertEquals(1, currentBills.size(), 'There should be one bill.');
    }

    @isTest
    static void run_currentBillPaidAndNotReturnedFromAPI_expectCurrentBillDeletedTest() {
        ESBBillingServiceClientTest.setBrowseBillsResponseMock(new ESBBillingServiceClientTest.BrowseByPayorNoBillsFoundMock());

        Account payorNumberAccount = AccountTestData.Instance.withPayorNumber('193819').insertCustomerAccount();
        
        Current_Bill__c existingCurrentBill = CurrentBillTestData.Instance.withAccount(payorNumberAccount.Id)
                                                                          .insertCurrentBill();
        List<Current_Bill__c> currentBills = getCurrentBills();
        system.assertEquals(1, currentBills.size(), 'There should be one bill.');
        
        run();
        
        currentBills = getCurrentBills();
        
        system.assertEquals(0, currentBills.size(), 'There should be no bills.');
    }

    @isTest
    static void run_mcpCurrentBillExistsAndNotPaidSoFoundInAPIResults_expectExistingBillUpdatedAndNoNewCurrentBillsTest() {
        String mcpNumber = '1938173';
        String billId = 'A-19381';

        ESBBillingServiceClientTest.setBrowseBillsResponseMock(new ESBBillingServiceClientTest.BrowseByPayorOneBillFoundMock(mcpNumber, billId));
        
        Account payorNumberAccount = AccountTestData.Instance.withPayorNumber('193819')
                                                             .withMCPNumber(mcpNumber)
                                                             .insertCustomerAccount();
        
        Current_Bill__c existingCurrentBill = CurrentBillTestData.Instance.withAccount(payorNumberAccount.Id)
                                                                          .withMCP(mcpNumber)
                                                                          .withBillId(billId)
                                                                          .insertCurrentBill();
        List<Current_Bill__c> currentBills = getCurrentBills();
        system.assertEquals(1, currentBills.size(), 'There should be one bill.');
        
        run();
        
        currentBills = getCurrentBills();
        
        system.assertEquals(1, currentBills.size(), 'There should be one bill still.');
    }

    static void run() {
        Test.startTest();
        
        new CurrentBillsBatchUpdater().execute(null);
        
        Test.stopTest();
    }
    
    static List<Current_Bill__c> getCurrentBills() {
        return
        [SELECT Id,
                Name
           FROM Current_Bill__c];
    }
}