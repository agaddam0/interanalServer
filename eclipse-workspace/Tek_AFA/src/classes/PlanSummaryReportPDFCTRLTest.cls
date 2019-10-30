@isTest
public with sharing class PlanSummaryReportPDFCTRLTest {
    private static FINAL String accountName = 'Summary Report Test Account';

    @TestSetup
    static void makeData(){
        Account testAccount = AccountTestData.Instance.withName(accountName).insertCustomerAccount();
        Account relatedEmployer = AccountTestData.Instance.insertCustomerAccount();
        Opportunity testOpp = OpportunityTestData.Instance.withAccount(testAccount.Id).insertAWDOpportunity();
        Contact generalContact = ContactTestData.Instance.withAccount(testAccount.Id).withGeneralContact(true).insertContact();
        Contact billingContact = ContactTestData.Instance.withAccount(testAccount.Id).withBillingContact(true).insertContact();
        Plan_Date__c planDate = PlanDateTestData.Instance.withAccount(testAccount.Id).withRelatedEmployer(relatedEmployer.Id).insertPlanDate();
        Eligible_Coverage__c medicalCoverage = EligibleCoverageTestData.Instance.withPlanDate(planDate.Id).withBenefitCode('MEDICAL').insertCoverage();
        Eligible_Coverage__c dentalCoverage = EligibleCoverageTestData.Instance.withPlanDate(planDate.Id).withBenefitCode('DENTAL').insertCoverage();
        Eligible_Coverage__c visionCoverage = EligibleCoverageTestData.Instance.withPlanDate(planDate.Id).withBenefitCode('VISION').insertCoverage();
        Eligible_Coverage__c cancerCoverage = EligibleCoverageTestData.Instance.withPlanDate(planDate.Id).withBenefitCode('CANCER').insertCoverage();
        Eligible_Coverage__c disabilityCoverage = EligibleCoverageTestData.Instance.withPlanDate(planDate.Id).withBenefitCode('DISABILITY').insertCoverage();
        Eligible_Coverage__c groupLifeCoverage = EligibleCoverageTestData.Instance.withPlanDate(planDate.Id).withBenefitCode('GROUPLIFE').insertCoverage();
        Eligible_Coverage__c ddcCoverage = EligibleCoverageTestData.Instance.withPlanDate(planDate.Id).withBenefitCode('DDC').insertCoverage();
        Eligible_Coverage__c hsaCoverage = EligibleCoverageTestData.Instance.withPlanDate(planDate.Id).withBenefitCode('HSA').insertCoverage();
    }

    @isTest
    public static void testPlanSummaryReportPage_allDataLoaded(){
        Account summaryReportTestAccount = [SELECT Id, Name FROM Account WHERE Name =: accountName];
        pageReference planSummaryReportPDFPage = page.PlanSummaryReportPDF;
        test.setCurrentPage(planSummaryReportPDFPage);

        ApexPages.currentPage().getParameters().put('id', summaryReportTestAccount.Id);

        test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(SummaryReportTestAccount);
        PlanSummaryReportPDFCTRL summaryReportController = new PlanSummaryReportPDFCTRL(standardController);

        test.stopTest();

        List<Contact> generalContacts = [SELECT Id, Name, Email FROM Contact WHERE AccountId =: summaryReportTestAccount.Id AND General_Contact__c = true];
        List<Contact> billingContacts = [SELECT Id, Name, Email FROM Contact WHERE AccountId =: summaryReportTestAccount.Id AND Billing_Contact__c = true];

        // Assert contacts
        system.assertEquals(generalContacts, summaryReportController.GeneralContacts, 'There should be at least 1 general contact');
        system.assertEquals(billingContacts, summaryReportController.BillingContacts, 'There should be at least 1 billing contact');

        // assert plan date context
        system.assertNotEquals(null, summaryReportController.planDateInformationContext, 'The context should not be null');
        system.assertEquals(1, summaryReportController.planDateInformationContext[0].RelatedEmployers.size(), 'There should be one related employer');
        system.assertEquals(1, summaryReportController.planDateInformationContext[0].CancerBenefits.size(), 'There should be one cancer benefit eligible coverage');
        system.assertEquals(1, summaryReportController.planDateInformationContext[0].DisabilityBenefits.size(), 'There should be one disability benefit eligible coverage');
        system.assertEquals(1, summaryReportController.planDateInformationContext[0].DentalBenefits.size(), 'There should be one dental benefit eligible coverage');
        system.assertEquals(1, summaryReportController.planDateInformationContext[0].VisionBenefits.size(), 'There should be one vision benefit eligible coverage');
        system.assertEquals(1, summaryReportController.planDateInformationContext[0].GroupLifeBenefits.size(), 'There should be one Group Life benefit eligible coverage');
        system.assertEquals(1, summaryReportController.planDateInformationContext[0].FlexAccountInformation.size(), 'There should be one flex account (DDC) benefit eligible coverage');
        system.assertEquals(1, summaryReportController.planDateInformationContext[0].HSAInformation.size(), 'There should be one HSA benefit eligible coverage');
        system.assertEquals(1, summaryReportController.planDateInformationContext[0].MedicalBenefits.size(), 'There should be one medical benefit eligible coverage');
    }
}