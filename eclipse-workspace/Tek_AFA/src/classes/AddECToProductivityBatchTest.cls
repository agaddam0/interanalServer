@isTest
public with sharing class AddECToProductivityBatchTest {
    Private Static FINAL DateTime YESTERDAY = System.now().addDays(-1); 

    static void runAddECToProductivityBatch() {
        Test.startTest();
        
        AddECToProductivityBatch batchJob = new AddECToProductivityBatch();
        Database.executeBatch(batchJob);
        
        Test.stopTest();
    }

    public static User getAgent(String userName, Boolean xCommit)
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='AWD Sales'];
        
        User agent = new User();
        agent.Alias = 'standt';
        agent.Email = 'standarduser@testorg.com'; 
        agent.EmailEncodingKey = 'UTF-8';
        agent.LanguageLocaleKey = 'en_US'; 
        agent.LocaleSidKey='en_US';
        agent.TimeZoneSidKey='America/Los_Angeles';
        agent.UserName = userName;
		agent.FirstName = 'Test Agent';
		agent.LastName = 'Integration Test';
		agent.Agent_ID__c = '1234';
        agent.ProfileId = prof.Id;
        
        if(xCommit)
			insert agent;
        return agent;
    }

    public static Account getAccount(String accountName){
        Account a = [SELECT Name, Current_Enrollment_Coordinator__c, Additional_Enrollment_Coordinator__c 
                     FROM Account
                     WHERE Name =: accountName LIMIT 1];
        
        return a;
    }

    @TestSetup
    static void makeData(){
        
        Account accountWithNoCoordinator = AccountTestData.Instance.withName('NO Coordinator').insertCustomerAccount();

        Account accountWithCurrentCoordinator = AccountTestData.Instance.withName('CURRENT Coordinator')
                                                                        .withCurrentEnrollmentCoordinator(getAgent('TestAddECToProductivityData0@Test.com', true).Id)
                                                                        .insertCustomerAccount();

        Account accountWithCurrentAndAdditionalCoordinator = AccountTestData.Instance.withName('ADDITIONAL Coordinator')
                                                                                     .withCurrentEnrollmentCoordinator(getAgent('TestAddECToProductivityData1@Test.com', true).Id)
                                                                                     .withAdditionalEnrollmentCoordinator(getAgent('TestAddECToProductivityData2@Test.com', true).Id)
                                                                                     .insertCustomerAccount();
        
    }

    static void assertProductivityDataNoECPopulated(String ProductivityId){
        Productivity_Data__c pData = [SELECT Current_Enrollment_Coordinator__c FROM Productivity_Data__c WHERE Id =: ProductivityId];
        
        system.assert(pData.Current_Enrollment_Coordinator__c == null, 'The Current Enrollment Coordinator was populated.');
    }

    static void assertProductivityDataCurrentECPopulated(String ProductivityDataId){
        Productivity_Data__c pData = [SELECT Id, CreatedDate, Current_Enrollment_Coordinator__c FROM Productivity_Data__c WHERE Id =: ProductivityDataId];
        
        system.assert(pData.Current_Enrollment_Coordinator__c != null, 'The Current Enrollment Coordinator was not populated.');
    }

    static void assertProductivityDataAdditionalECPopulated(String ProductivityDataId){
        Productivity_Data__c pData = [SELECT Id, CreatedDate, Additional_Enrollment_Coordinator__c FROM Productivity_Data__c WHERE Id =: ProductivityDataId];
        
        system.assert(pData.Additional_Enrollment_Coordinator__c != null, 'The Additional Enrollment Coordinator was not populated.');
    }

    @isTest
    static void testAddECToProductivityData_NoEConAccount(){
        Productivity_Data__c pData = ProductivityDataTestData.Instance.withAccount(getAccount('NO Coordinator').Id)
                                                                      .withCreatedDate(YESTERDAY)
                                                                      .insertProductivityData();

        runAddECToProductivityBatch();

        assertProductivityDataNoECPopulated(pData.Id);
    }
    
    @isTest
    static void testAddECToProductivityData_CurrentEConAccount(){
        Productivity_Data__c pData = ProductivityDataTestData.Instance.withAccount(getAccount('CURRENT Coordinator').Id)
            														  .withCreatedDate(YESTERDAY)
                                                                      .insertProductivityData();

        runAddECToProductivityBatch();

        assertProductivityDataCurrentECPopulated(pData.Id);
    }
    
    @isTest
    static void testAddECToProductivityData_AdditionalEConAccount(){
        Productivity_Data__c pData = ProductivityDataTestData.Instance.withAccount(getAccount('ADDITIONAL Coordinator').Id)
            														  .withCreatedDate(YESTERDAY)
            														  .insertProductivityData();

        runAddECToProductivityBatch();

        assertProductivityDataCurrentECPopulated(pData.Id);
        assertProductivityDataAdditionalECPopulated(pData.Id);
    }

    @isTest
    static void scheduleDailyAt2AM_invoke_expectRunsFineTest() {
        try {
            AddECToProductivityBatch.scheduleDailyAt2AM();
        }
        catch (system.AsyncException asyncEx) {
            String exMessage = asyncEx.getMessage();
            
            if (!exMessage.containsIgnoreCase(AddECToProductivityBatch.DAILY_SCHEDULE_NAME)) {
                throw asyncEx;
            }
        }
    }
}