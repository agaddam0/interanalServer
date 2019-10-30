@isTest
public with sharing class MySetupFormsControllerTest {
    static void assertSetupFormsHas(String expectedSetupFormName, MySetupFormsController.EnrollmentOpportunity enrollmentOpp) {
        system.assert(enrollmentOpp.SetupForms != null, 'The SetupForms is null.');
        system.assert(enrollmentOpp.SetupForms.size() > 0, 'The SetupForms is empty.');
        
        Boolean setupFormFound = false;
        
        for (MySetupFormsController.SetupForm sf : enrollmentOpp.SetupForms) {
            setupFormFound |= sf.Name == expectedSetupFormName;
        }
        
        system.assertEquals(true, setupFormFound, 'The expected setup form, ' + expectedSetupFormName + ', was not found.');
    }
    
    static Enrollment_Form__c getEnrollmentFormByOppId(Id opportunityId) {
        return
        [SELECT Id,
                Name
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :opportunityId];
    }
    
    @isTest
    static void getMyInProgressEnrollmentOpportunities_noEnrollmentOpportunities_expectNoneInContextTest() {
        MySetupFormsController.Context context = MySetupFormsController.getMyInProgressEnrollmentOpportunities();
        
        system.assert(context != null, 'The context is null.');
        system.assert(context.EnrollmentOpportunities != null, 'The enrollment opportunities is null.');
        system.assertEquals(0, context.EnrollmentOpportunities.size(), 'There should be no enrollment opportunities.');
    }
    
    @isTest
    static void getMyInProgressEnrollmentOpportunities_oneEnrollmentOpportunity_expectOneInContextTest() {
        Opportunity myEnrollmentOpp = OpportunityTestData.Instance.insertAFESOpportunity();
        
        MySetupFormsController.Context context = MySetupFormsController.getMyInProgressEnrollmentOpportunities();
        
        system.assert(context != null, 'The context is null.');
        system.assert(context.EnrollmentOpportunities != null, 'The enrollment opportunities is null.');
        system.assertEquals(1, context.EnrollmentOpportunities.size(), 'There should be one enrollment opportunities.');
        
        MySetupFormsController.EnrollmentOpportunity enrollmentOpp = context.EnrollmentOpportunities[0];
        
        system.assert(enrollmentOpp.Record != null, 'The opportunity record is null.');
        system.assertEquals(myEnrollmentOpp.Id, enrollmentOpp.Record.Id, 'The opportunity record found is not the expected one.');
        
        system.assert(enrollmentOpp.SetupForms != null, 'The SetupForms is null.');
        system.assert(enrollmentOpp.SetupForms.size() > 0, 'The SetupForms is empty.');
    }
    
    @isTest
    static void getEnrollmentOpportunities_preenrollmentMarketingFormInProgress_expectEnrollmentOppInContextTest() {
        Pre_Enrollment_Marketing_Form__c marketingForm = PreenrollmentMarketingFormTestData.Instance.insertPreenrollmentMarketingForm();
        system.assert(marketingForm.Id != null, 'The marketing form was not inserted.');
        
        // Set the pre-enrollment marketing status so it doesn't depend on the process builder to be active.
        Enrollment_Form__c ef = new Enrollment_Form__c(Id = marketingForm.Enrollment_Form__c);
        ef.Preenrollment_Marketing_Form_Status__c = 'In Progress';
        update ef;
        
        MySetupFormsController.Context context = MySetupFormsController.getEnrollmentOpportunities('In Progress', UserInfo.getUserId());
        
        system.assert(context != null, 'The context is null.');
        system.assert(context.EnrollmentOpportunities != null, 'The enrollment opportunities is null.');
        system.assertEquals(1, context.EnrollmentOpportunities.size(), 'There should be one enrollment opportunities.');
        
        MySetupFormsController.EnrollmentOpportunity enrollmentOpp = context.EnrollmentOpportunities[0];
        
        assertSetupFormsHas('Preenrollment Marketing Form', enrollmentOpp);     
    }
    
    @isTest
    static void getEnrollmentOpportunities_customerSetupFormInProgress_expectEnrollmentOppInContextTest() {
        Opportunity myEnrollmentOpp = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOppId(myEnrollmentOpp.Id);
        
        Customer_Setup_Form__c csf = CustomerSetupFormTestData.Instance.withEnrollmentForm(ef.Id).insertCustomerSetupForm();
        
        ef.Customer_Setup_Form_Status__c = 'In Progress';
        update ef;
        
        MySetupFormsController.Context context = MySetupFormsController.getEnrollmentOpportunities('In Progress', UserInfo.getUserId());
        
        system.assert(context != null, 'The context is null.');
        system.assert(context.EnrollmentOpportunities != null, 'The enrollment opportunities is null.');
        system.assertEquals(1, context.EnrollmentOpportunities.size(), 'There should be one enrollment opportunities.');
        
        MySetupFormsController.EnrollmentOpportunity enrollmentOpp = context.EnrollmentOpportunities[0];
        
        assertSetupFormsHas('Customer Setup Form', enrollmentOpp); 
    }
    
    @isTest
    static void getEnrollmentOpportunities_s125SetupFormInProgress_expectEnrollmentOppInContextTest() {
        Opportunity myEnrollmentOpp = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOppId(myEnrollmentOpp.Id);
        
        Section_125_Setup_Form__c s125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id).insertS125SetupForm();
        
        ef.Section_125_Status__c = 'In Progress';
        update ef;
        
        MySetupFormsController.Context context = MySetupFormsController.getEnrollmentOpportunities('In Progress', UserInfo.getUserId());
        
        system.assert(context != null, 'The context is null.');
        system.assert(context.EnrollmentOpportunities != null, 'The enrollment opportunities is null.');
        system.assertEquals(1, context.EnrollmentOpportunities.size(), 'There should be one enrollment opportunities.');
        
        MySetupFormsController.EnrollmentOpportunity enrollmentOpp = context.EnrollmentOpportunities[0];
        
        assertSetupFormsHas('Section 125 Form', enrollmentOpp); 
    }
}