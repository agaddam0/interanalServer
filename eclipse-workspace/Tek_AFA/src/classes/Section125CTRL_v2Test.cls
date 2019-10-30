@isTest
public with sharing class Section125CTRL_v2Test {
    private static Opportunity DefaultOpportunity = null;
    private static Common_Ownership_Form__c DefaultRelatedEmployer = null;
    private static Enrollment_Form__c DefaultEnrollmentForm = null;
    
    @testSetup
    static void TestData()
    {
        DefaultOpportunity = OpportunityTestData.Instance.withConfirmNewOrExistingGroup('Existing')
                                                         .withAddASection125Plan(true)
                                                         .insertAWDOpportunity();
        
        Enrollment_Form__c ef = getEnrollmentFormByOpportunityId(DefaultOpportunity.Id);
                                                                        
        Section_125_Setup_Form__c primaryS125 = getSection125SetupFormByEnrollmentId(ef.Id);
        DefaultRelatedEmployer = CommonOwnershipFormTestData.Instance.withSection125SetupForm(primaryS125.Id).insertCommonOwnershipForm();
    }
    
    static void loadDefaultTestData() {
        DefaultOpportunity = getOpportunity();
        DefaultEnrollmentForm = getEnrollmentFormByOpportunityId(DefaultOpportunity.Id);
        DefaultRelatedEmployer = getRelatedEmployerByOpportunityId(DefaultOpportunity.Id);
    }
    
    static Opportunity getOpportunity() {
        return
        [SELECT Id,
                Name,
                RecordTypeId,
                RecordType.Name
           FROM Opportunity];
    }
    
    static Enrollment_Form__c getEnrollmentFormByOpportunityId(Id opportunityId) {
        return
        [SELECT Id,
                Name
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :opportunityId];
    }
    
    static Section_125_Setup_Form__c getSection125SetupFormByEnrollmentId(Id enrollmentFormId) {
        return
        [SELECT Id,
                Name
           FROM Section_125_Setup_Form__c
          WHERE Enrollment_Form__c = :enrollmentFormId];
    }
    
    static Common_Ownership_Form__c getRelatedEmployerByOpportunityId(Id opportunityId) {
        return
        [SELECT Id,
                Name
           FROM Common_Ownership_Form__c
          WHERE Section_125_Setup_Form__r.Enrollment_Form__r.Enrollment_Opportunity__c = :opportunityId];
    }
    
    static List<Bill_Mode__c> getS125BillModes(Id s125Id) {
        return
        [SELECT Id,
                Name,
                Benefit_Deduction_Schedule__c,
                Other_Information__c,
                What_Months_No_Deductions_Taken__c,
                RecordTypeId
           FROM Bill_Mode__c
          WHERE Section_125_Setup_Form__c = :s125Id];
    }
    
    static void insertDefaultBillMode(Section125CTRL_v2 controller) {
        Id s125Id = controller.wrapS125s[0].Section125.Id;
        
        controller.formToAdd = s125Id;
        controller.insertBillMode();
    }
    
    static Section125CTRL_v2 loadControllerUsingEnrollmentForm(Id enrollmentFormId) {
        Test.setCurrentPage(Page.Section125_v2);
        ApexPages.currentPage().getParameters().put('Id', enrollmentFormId);
        
        return new Section125CTRL_v2();
    }
    
    static Section125CTRL_v2 loadControllerUsingDefaultEnrollmentForm() {
        loadDefaultTestData();
        
        return loadControllerUsingEnrollmentForm(DefaultEnrollmentForm.Id);
    }
    
    static void assertRelatedEmployerRequiredField(String newOrExistingValue, String relatedEmployerNullFieldName) {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        system.assert(controller.section125s != null, 'The section125s are null.');
        system.assertEquals(1, controller.section125s.size() , 'There should be 1 section125.');
        
        Section_125_Setup_Form__c primaryS125 = controller.section125s[0];

        system.assertEquals(1, primaryS125.Common_Ownership_Forms__r.size(), 'There should be one default related employer.');
        
        Common_Ownership_Form__c relatedEmployer = primaryS125.Common_Ownership_Forms__r[0];
        relatedEmployer.new_Or_Existing__c = newOrExistingValue;
        relatedEmployer.put(relatedEmployerNullFieldName, null);
        
        controller.s125CheckRequiredFields(true);
        
        system.assertEquals(false, controller.s125TabComplete, 'The s125 tab should not be complete.');
        TestUtil.assertPageHasMessage(PreenrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    static void assertQualifiedBenefitRequiredField(String nullQualifiedBenefitFieldName) {
        loadDefaultTestData();
        
        Section_125_Setup_Form__c defaultS125 = getSection125SetupFormByEnrollmentId(DefaultEnrollmentForm.Id);
        
        Qualified_Benefit_Form__c qualifiedBenefitForm =
          QualifiedBenefitFormTestData.Instance.withSection125SetupForm(defaultS125.Id)
                                               .insertQualifiedBenefitForm();
        
        Section125CTRL_v2 controller = loadControllerUsingEnrollmentForm(DefaultEnrollmentForm.Id);
        
        system.assert(controller.section125s != null, 'The section125s are null.');
        system.assertEquals(1, controller.section125s.size() , 'There should be 1 section125.');
        
        Section_125_Setup_Form__c primaryS125 = controller.section125s[0];
        primaryS125.QualBenAnyQualBenOffered__c = 'Yes';

        system.assertEquals(1, primaryS125.Qualitfied_Benefits_Form__r.size(), 'There should be one default qualified benefit form.');
        
        Qualified_Benefit_Form__c qualifiedBenefitFormToUpdate = primaryS125.Qualitfied_Benefits_Form__r[0];
        qualifiedBenefitFormToUpdate.put(nullQualifiedBenefitFieldName, null);
        
        controller.qualifiedBenefitsCheckRequiredFields(true);
        
        system.assertEquals(false, controller.qualBenTabComplete, 'The qualified benefits tab should not be complete.');
        TestUtil.assertPageHasMessage(PreenrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    static void assertPrimarySection125RequiredField(String primaryS125NullFieldName) {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        system.assert(controller.section125s != null, 'The section125s are null.');
        system.assertEquals(1, controller.section125s.size() , 'There should be 1 section125.');
        
        Section_125_Setup_Form__c primaryS125 = controller.section125s[0];

        system.assertEquals(1, primaryS125.Common_Ownership_Forms__r.size(), 'There should be one default related employer.');
        
        primaryS125.put(primaryS125NullFieldName, null);
        
        controller.s125CheckRequiredFields(true);
        
        system.assertEquals(false, controller.s125TabComplete, 'The s125 tab should not be complete.');
        TestUtil.assertPageHasMessage(PreenrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    static void assertFSARequiredField(String fsaNullFieldName) {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        controller.wrapS125s[0].Section125.put(fsaNullFieldName, null);
        
        controller.FSAcheckRequiredFields(true);
        
        system.assertEquals(false, controller.FSATabComplete, 'The flexible spending account tab should not be complete.');
        TestUtil.assertPageHasMessage(PreenrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    static void assertHealthFSAAddedRequiredField(String healthFSANullFieldName) {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        controller.wrapS125s[0].Section125.FlexSpendAcctGroupAddingHealthFSA__c = 'Yes';
        controller.wrapS125s[0].Section125.put(healthFSANullFieldName, null);
        
        controller.FSAcheckRequiredFields(true);
        
        system.assertEquals(false, controller.FSATabComplete, 'The flexible spending account tab should not be complete.');
        TestUtil.assertPageHasMessage(PreenrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    static void assertFSAAddedWithEmployoyerPaidFlexRequiredField(String employerPaidFlexNullFieldName) {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        controller.wrapS125s[0].Section125.Is_there_Employer_Paid_Flex__c = 'Yes';
        controller.wrapS125s[0].Section125.put(employerPaidFlexNullFieldName, null);
        
        controller.FSAcheckRequiredFields(true);
        
        system.assertEquals(false, controller.FSATabComplete, 'The flexible spending account tab should not be complete.');
        TestUtil.assertPageHasMessage(PreenrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    static void assertFSAAddedWithEmployerPaidFlexWithFSAContributionRequiredField(String employerContributionNullField, String employerFSAContributionValue) {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        controller.wrapS125s[0].Section125.Is_there_Employer_Paid_Flex__c = 'Yes';
        controller.wrapS125s[0].Section125.Employer_FSA_Contribution__c = employerFSAContributionValue;
        controller.wrapS125s[0].Section125.put(employerContributionNullField, null);
        
        controller.FSAcheckRequiredFields(true);
        
        system.assertEquals(false, controller.FSATabComplete, 'The flexible spending account tab should not be complete.');
        
        TestUtil.assertPageHasMessage(PreenrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    static void assertFSABillModeRequiredField(String requiredBillModeField) {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        insertDefaultBillMode(controller);
        
        controller = loadControllerUsingDefaultEnrollmentForm();
        
        controller.TestBillModeRequiredFields = new Set<String> { requiredBillModeField };
        
        controller.wrapS125s[0].Section125.Flex_Billing_Same_as_Product_Billing__c = 'No';
        controller.wrapS125s[0].Section125.Bill_Modes__r[0].put(requiredBillModeField, null);
        
        controller.FSAcheckRequiredFields(true);
        
        system.assertEquals(false, controller.FSATabComplete, 'The flexible spending account tab should not be complete.');
        
        TestUtil.assertPageHasMessage(PreenrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    static void assertS125HasNoBillModes(Id s125Id) {
        List<Bill_Mode__c> billModes = getS125BillModes(s125Id);

        system.assertEquals(0, billModes.size(), 'There should be no bill modes for this s125 record id: .' + s125Id);
    }
    
    @isTest
    static void s125CheckRequiredFields_newOrExistingFieldNull_expectRequiredFieldErrorTest() {
        String newOrExistingNullValue = null;
        String relatedEmployerNullFieldName = 'New_Or_Existing__c';
        
        assertRelatedEmployerRequiredField(newOrExistingNullValue, relatedEmployerNullFieldName);
    }
    
    @isTest
    static void s125CheckRequiredFields_newRelatedEmployerAndLegalNameNull_expectRequiredFieldErrorTest() {
        String newOrExistingValue = 'New';
        String relatedEmployerNullFieldName = 'Legal_Name__c';
        
        assertRelatedEmployerRequiredField(newOrExistingValue, relatedEmployerNullFieldName);
    }
    
    @isTest
    static void s125CheckRequiredFields_newRelatedEmployerAndAddressLine1Null_expectRequiredFieldErrorTest() {
        String newOrExistingValue = 'New';
        String relatedEmployerNullFieldName = 'Address_Line_1__c';
        
        assertRelatedEmployerRequiredField(newOrExistingValue, relatedEmployerNullFieldName);
    }
    
    @isTest
    static void s125CheckRequiredFields_newRelatedEmployerAndCityNull_expectRequiredFieldErrorTest() {
        String newOrExistingValue = 'New';
        String relatedEmployerNullFieldName = 'City__c';
        
        assertRelatedEmployerRequiredField(newOrExistingValue, relatedEmployerNullFieldName);
    }
    
    @isTest
    static void s125CheckRequiredFields_newRelatedEmployerAndStateNull_expectRequiredFieldErrorTest() {
        String newOrExistingValue = 'New';
        String relatedEmployerNullFieldName = 'State_Picklist__c';
        
        assertRelatedEmployerRequiredField(newOrExistingValue, relatedEmployerNullFieldName);
    }
    
    @isTest
    static void s125CheckRequiredFields_newRelatedEmployerAndZipNull_expectRequiredFieldErrorTest() {
        String newOrExistingValue = 'New';
        String relatedEmployerNullFieldName = 'ZipCode__c';
        
        assertRelatedEmployerRequiredField(newOrExistingValue, relatedEmployerNullFieldName);
    }
    
    @isTest
    static void s125CheckRequiredFields_existingRelatedEmployerAndMCPNumberNull_expectRequiredFieldErrorTest() {
        String newOrExistingValue = 'Existing';
        String relatedEmployerNullFieldName = 'MCP_Number__c';
        
        assertRelatedEmployerRequiredField(newOrExistingValue, relatedEmployerNullFieldName);
    }
    
    @isTest
    static void s125CheckRequiredFields_NumberOfExistingEligibleHoursNull_expectRequiredFieldErrorTest() {
        assertPrimarySection125RequiredField('Sec125NbrofhrsEligforSec125__c');
    }
    
    @isTest
    static void qualifiedBenefitsCheckRequiredFields_benefitTypeNull_expectRequiredFieldErrorTest() {
        assertQualifiedBenefitRequiredField('Add_Benefit__c');
    }
    
    @isTest
    static void qualifiedBenefitsCheckRequiredFields_carrierNull_expectRequiredFieldErrorTest() {
        assertQualifiedBenefitRequiredField('Carrier__c');
    }
    
    @isTest
    static void FSAcheckRequiredFields_EmployerPaidFlexNull_expectRequiredFieldErrorTest() {
        assertFSARequiredField('Is_there_Employer_Paid_Flex__c');
    }

    @isTest
    static void FSAcheckRequiredFields_FlexBillingSameAsProductBillingNull_expectRequiredFieldErrorTest() {
        assertFSARequiredField('Flex_Billing_Same_as_Product_Billing__c');
    }
    
    @isTest
    static void FSAcheckRequiredFields_healthFSAAddedAndFSAMinPerPlanYearNull_expectRequiredFieldErrorTest() {
        assertHealthFSAAddedRequiredField('FlexSpendAcctHlthFlexMin__c');
    }
    
    @isTest
    static void FSAcheckRequiredFields_healthFSAAddedAndFSAMaxPerPlanYearNull_expectRequiredFieldErrorTest() {
        assertHealthFSAAddedRequiredField('FlexSpendAcctHlthFlexMax__c');
    }
    
    @isTest
    static void FSAcheckRequiredFields_healthFSAAddedAndWhoIsHealthFSARecordKeeperNull_expectRequiredFieldErrorTest() {
        assertHealthFSAAddedRequiredField('FlexSpendAcctHlthFlexWho__c');
    }
    
    @isTest
    static void FSAcheckRequiredFields_healthFSAAddedAndFlexCardOfferedNull_expectRequiredFieldErrorTest() {
        assertHealthFSAAddedRequiredField('FlexSpendAcctDebitCardWillEmpl__c');
    }
    
    @isTest
    static void FSAcheckRequiredFields_FSAAddedWithEmployerPaidFlexAndSameAmountAppliedToEmployeesNull_expectRequiredFieldErrorTest() {
        assertFSAAddedWithEmployoyerPaidFlexRequiredField('Does_the_same_amount_apply_to_employees__c');
    }
    
    @isTest
    static void FSAcheckRequiredFields_FSAAddedWithEmployerPaidFlexAndEmployerMaxContributionAmountNull_expectRequiredFieldErrorTest() {
        assertFSAAddedWithEmployoyerPaidFlexRequiredField('FlexSpendAcctHlthFlexSpendAcctEmp__c');
    }
    
    @isTest
    static void FSAcheckRequiredFields_FSAAddedWithEmployerPaidFlexAndEmployerFSAContributionNull_expectRequiredFieldErrorTest() {
        assertFSAAddedWithEmployoyerPaidFlexRequiredField('Employer_FSA_Contribution__c');
    }

    @isTest
    static void FSAcheckRequiredFields_FSAAddedWithEmployerPaidFlexAndDollarForDollarEmployerFSAContributionAndContributionUpToNull_expectRequiredFieldErrorTest() {
        assertFSAAddedWithEmployerPaidFlexWithFSAContributionRequiredField('Contribution_up_to__c', 'Dollar for Dollar Match');
    }
    
    @isTest
    static void FSAcheckRequiredFields_FSAAddedWithEmployerPaidFlexAndOtherFSAContributionAndContributionUpToNull_expectRequiredFieldErrorTest() {
        assertFSAAddedWithEmployerPaidFlexWithFSAContributionRequiredField('Other_Contribution_Details__c', 'Other');
    }
    
    @isTest
    static void insertBillMode_formToAddGiven_expectBillModeInsertedAndLinkedToS125RecordTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        Id s125Id = controller.wrapS125s[0].Section125.Id;
        
        insertDefaultBillMode(controller);
 
        List<Bill_Mode__c> billModes = getS125BillModes(s125Id);
        
        system.assertEquals(1, billModes.size(), 'The bill mode was not inserted.');
        
        Bill_Mode__c bm = billModes[0];
        
        system.assertEquals(Constants.BILL_MODES_FLEX_BILLING, bm.RecordTypeId, 'The inserted bill mode does not have a Flex Billing record type.');
    }
    
    @isTest
    static void removeBillMode_BillModeIdToRemoveValid_expectBillModeDeletedTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
                
        insertDefaultBillMode(controller);
        
        Id s125Id = controller.wrapS125s[0].Section125.Id;
        
        system.assert(s125Id != null, 'The s125 id is null.');
        
        List<Bill_Mode__c> billModes = getS125BillModes(s125Id);
        
        system.assertEquals(1, billModes.size(), 'The bill mode was not inserted.');

        controller = loadControllerUsingEnrollmentForm(DefaultEnrollmentForm.Id);

        controller.BillModeIdToRemove = billModes[0].Id;
        controller.removeBillMode();
        
        assertS125HasNoBillModes(s125Id);
    }

    @isTest
    static void updateBillMode_BillModeIdToUpdateValid_expectBillModeUpdatedTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
                
        insertDefaultBillMode(controller);
        
        // Reload so the Bill Modes are queried and available
        controller = loadControllerUsingEnrollmentForm(DefaultEnrollmentForm.Id);

        Bill_Mode__c bmToUpdate = controller.wrapS125s[0].Section125.Bill_Modes__r[0];
        bmToUpdate.Other_Information__c = 'some awesome information';

        controller.BillModeIdToUpdate = bmToUpdate.Id;
        controller.updateBillMode();

        List<Bill_Mode__c> billModes = getS125BillModes(controller.wrapS125s[0].Section125.Id);

        system.assertEquals(1, billModes.size(), 'There should be one bill mode.');
        
        system.assertEquals(bmToUpdate.Other_Information__c, billModes[0].Other_Information__c, 'The bill mode was not updated.');
    }
    
    @isTest
    static void FSAcheckRequiredFields_FSAAddedWithFlexBillingAndNoBillModes_expectNoBillModesValidationTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        controller.wrapS125s[0].Section125.Flex_Billing_Same_as_Product_Billing__c = 'No';
        
        controller.FSAcheckRequiredFields(true);
        
        system.assertEquals(false, controller.FSATabComplete, 'The flexible spending account tab should not be complete.');
        
        system.assertEquals(Section125CTRL_v2.NO_BILL_MODES_VAL_MSG, controller.billModesErrorMessage, 'The "No Bill Modes" validation was not displayed.');
    }
    
    @isTest
    static void FSAcheckRequiredFields_BillModeAddedWithoutRequiredBenefitDeductionSchedule_expectFieldRequiredValidationTest() {
        assertFSABillModeRequiredField(Bill_Mode__c.Benefit_Deduction_Schedule__c.getDescribe().getName());
    }

    @isTest
    static void FSAcheckRequiredFields_BillModeAddedWithoutRequiredWhatMonthsAreNoDeductionsTaken_expectFieldRequiredValidationTest() {
        assertFSABillModeRequiredField(Bill_Mode__c.What_Months_No_Deductions_Taken__c.getDescribe().getName());
    }

    @isTest
    static void FSAcheckRequiredFields_BillModeAddedWithoutRequiredOtherInformation_expectFieldRequiredValidationTest() {
        assertFSABillModeRequiredField(Bill_Mode__c.Other_Information__c.getDescribe().getName());
    }

    @isTest
    static void updateFSAProductBilling_flexBillingSameAsProductBillingSetToYesFromNull_expectNoNewBillModeInsertedTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        controller.wrapS125s[0].Section125.Flex_Billing_Same_as_Product_Billing__c = 'Yes';
        
        Id s125Id = controller.wrapS125s[0].Section125.Id;
        
        controller.formToAdd = s125Id;
        controller.updateFSAProductBilling();
        
        assertS125HasNoBillModes(s125Id);
    }

    @isTest
    static void updateFSAProductBilling_flexBillingSameAsProductBillingSetToNoWithNoBillModes_expectNewBillModeInsertedTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        Id s125Id = controller.wrapS125s[0].Section125.Id;
        
        assertS125HasNoBillModes(s125Id);
        
        controller.wrapS125s[0].Section125.Flex_Billing_Same_as_Product_Billing__c = 'No';

        controller.formToAdd = s125Id;
        controller.updateFSAProductBilling();

        List<Bill_Mode__c> billModes = getS125BillModes(s125Id);

        system.assertEquals(1, billModes.size(), 'There should be one bill mode.');
    }
    
    @isTest
    static void IsUnlocked_notUnlockedFromUnlockRequestRecord_expectIsUnlockedToBeFalseTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        system.assertEquals(false, controller.IsUnlocked, 'The form should be locked.');
    }
    
    @isTest
    static void IsUnlocked_lockedFromUnlockRequestRecord_expectIsUnlockedTobeTrueTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        Unlock_Request__c unlockRequest = UnlockRequestTestData.Instance.withEnrollmentForm(controller.enrollmentForm.Id)
                                                                        .withUnlockReason('testing')
                                                                        .insertUnlockRequest();

        system.assertEquals(true, controller.IsUnlocked, 'The form should be unlocked.');
    }
    
    @isTest
    static void createUnlockRequest_UnlockRequestGiven_expectUnlockRequestCreatedTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        controller.UnlockReason = 'Testing';
        controller.createUnlockRequest();
        
        system.assertEquals(true, controller.IsUnlocked, 'The form should be unlocked.');
    }

    @isTest
    static void completeUnlockRequest_noUnlockRequest_expectNoErrorsTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        controller.completeUnlockRequest();
        
        system.assertEquals(false, controller.getHasErrorMessages(), 'There was an error completing the non-existent unlock request.');
    }

    @isTest
    static void completeUnlockRequest_formUnlockedFromUnlockRequest_expectUnlockRequestCompletedAndFormNowLockedTest() {
        Section125CTRL_v2 controller = loadControllerUsingDefaultEnrollmentForm();
        
        Unlock_Request__c unlockRequest = UnlockRequestTestData.Instance.withEnrollmentForm(controller.enrollmentForm.Id)
                                                                        .withUnlockReason('testing')
                                                                        .insertUnlockRequest();

        controller.completeUnlockRequest();
        
        system.assertEquals(false, controller.IsUnlocked, 'The form should be locked.');
    }
}