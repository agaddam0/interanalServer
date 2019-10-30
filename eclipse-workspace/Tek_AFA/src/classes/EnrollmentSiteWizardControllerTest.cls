@isTest
public with sharing class EnrollmentSiteWizardControllerTest {
    @isTest
    static void getAccountEnrollmentSitesInfo_accountHasNoEnrollmentSites_expectNoEnrollmentSitesTest() {
        Account noEnrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        EnrollmentSiteWizardController.AccountEnrollmentSitesInfo enrollmentSiteInfo =
            EnrollmentSiteWizardController.getAccountEnrollmentSitesInfo(noEnrollmentSitesAccount.Id, null);

        system.assert(enrollmentSiteInfo != null, 'The enrollment sites info is null.');
        system.assertEquals(0, enrollmentSiteInfo.EnrollmentSites.size(), 'There should be no enrollment sites found.');
        system.assert(enrollmentSiteInfo.Account != null, 'The account should be found.');
    }
    
    @isTest
    static void getAccountEnrollmentSitesInfo_accountHasEnrollmentSites_expectEnrollmentSitesTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();
        
        EnrollmentSiteWizardController.AccountEnrollmentSitesInfo enrollmentSiteInfo =
            EnrollmentSiteWizardController.getAccountEnrollmentSitesInfo(enrollmentSitesAccount.Id, null);

        system.assert(enrollmentSiteInfo != null, 'The enrollment sites info is null.');
        system.assertEquals(1, enrollmentSiteInfo.EnrollmentSites.size(), 'There should be one enrollment site found.');
    }
    
    @isTest
    static void addNewEnrollmentSite_newEnrollmentSiteGiven_expectEnrollmentSiteInsertedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .create();

        Id newEnrollmentSiteId = EnrollmentSiteWizardController.addNewEnrollmentSite(enrollmentSite);
        
        system.assert(newEnrollmentSiteId != null, 'The enrollment site was not inserted.');
    }

    @isTest
    static void addNewEnrollmentSiteDate_newEnrollmentSiteDateGiven_expectEnrollmentSiteDateInsertedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();

        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Enrollment_Site_Date__c enrollmentSiteDate = EnrollmentSiteDateTestData.Instance.withEnrollmentSite(enrollmentSite.Id)
                                                                                        .withEnrollmentOpportunity(enrollmentOpp.Id)
                                                                                        .create();

        Id newEnrollmentSiteDateId = EnrollmentSiteWizardController.addNewEnrollmentSiteDate(enrollmentSiteDate);
        
        system.assert(newEnrollmentSiteDateId != null, 'The enrollment site date was not inserted.');
    }

    @isTest
    static void updateEnrollmentSiteDate_enrollmentSiteDateToUpdateGiven_expectEnrollmentSiteDateUpdatedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();

        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Enrollment_Site_Date__c enrollmentSiteDate = EnrollmentSiteDateTestData.Instance.withEnrollmentSite(enrollmentSite.Id)
                                                                                        .withEnrollmentOpportunity(enrollmentOpp.Id)
                                                                                        .insertEnrollmentSiteDate();
                                                                                        
        enrollmentSiteDate.End_Date__c = enrollmentSiteDate.End_Date__c.addDays(10);

        EnrollmentSiteWizardController.updateEnrollmentSiteDate(enrollmentSiteDate);
        
        Enrollment_Site_Date__c enrollmentSiteDateQueried =
        [SELECT Id,
                End_Date__c
           FROM Enrollment_Site_Date__c
          WHERE Id = :enrollmentSiteDate.Id];
          
        system.assertEquals(enrollmentSiteDate.End_Date__c, enrollmentSiteDateQueried.End_Date__c, 'The end date was not updated.');
    }
    
    @isTest
    static void deleteEnrollmentSiteDate_enrollmentSiteDateToDeleteGiven_expectEnrollmentSiteDateDeletedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();

        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Enrollment_Site_Date__c enrollmentSiteDate = EnrollmentSiteDateTestData.Instance.withEnrollmentSite(enrollmentSite.Id)
                                                                                        .withEnrollmentOpportunity(enrollmentOpp.Id)
                                                                                        .insertEnrollmentSiteDate();
                                                                                        
        EnrollmentSiteWizardController.deleteEnrollmentSiteDate(enrollmentSiteDate.Id);
        
        List<Enrollment_Site_Date__c> enrollmentSiteDatesQueried =
        [SELECT Id,
                End_Date__c
           FROM Enrollment_Site_Date__c
          WHERE Id = :enrollmentSiteDate.Id];

        system.assertEquals(0, enrollmentSiteDatesQueried.size(), 'The enrollment site date was not deleted.');
    }
}