@isTest
private class GeneralInformationControllerTest {
    private static Opportunity DefaultOpportunity { get; set; }
    private static Enrollment_Form__c DefaultOpportunityEnrollmentForm { get; set; }
    private static GeneralInformationController Controller { get; set; }

    @testSetup
    private static void setup() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
    }
    
    private static void loadDefaults() {
        Test.setCurrentPage(Page.GeneralInformation);
        
        DefaultOpportunity = getDefaultOpportunity();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(DefaultOpportunity);
        Controller = new GeneralInformationController(stdController);
    }
    
    private static void loadDefaultOpportunityEnrollmentForm() {
        Opportunity defaultOpp = getDefaultOpportunity();
        
        DefaultOpportunityEnrollmentForm =
        [SELECT Id,
                Name
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :defaultOpp.Id];
    }
    
    private static Opportunity getDefaultOpportunity() {
        return
        [SELECT Id,
                Name,
                AccountId,
                Account.Id,
                Account.Eligibile_Employee_Count__c,
                Account.MCP_Number__c,
                Account.Status__c,
                Administrative_Contact__c,
                Confirm_New_or_Existing_Group__c,
                Are_you_adding_new_plans_or_services__c,
                Group_Name__c,
                Employee_Eligibility_Waiting_Period__c,
                EE_Eligibility_Waiting_Period__c,
                Tax_ID__c,
                Assigned_Account_Manager__c,
                Residence_State_s__c,
                Estimated_Employees__c,
                Enrollment_Start_Date__c,
                Enrollment_End_Date__c,
                Effective_Date_of_AFA_Products__c,
                Platform__c,
                Employer_Benefits_Site__c,
                Online_Appointment_Scheduler__c,
                Group_Display_Name__c,
                Are_you_making_any_product_changes__c,
                Are_you_making_any_billing_changes__c,
                Physical_Address_Same_As_Billing__c,
                Waiting_Period_Effective__c,
                RecordTypeId,
                Other_Eligibility_Waiting_Period__c,
                RecordType.Name,
                Branch_Office__c,
                Division__c,
                Enrollment_Path__c,
                Enrollment_Rush_Request_Reason__c,
                Are_you_changing_AFenroll_Frequencies__c,
                New_AFenroll_Deduction_Frequencies__c,
                Additional_MCPs__c
           FROM Opportunity];
    }
    
    private static Opportunity getOpportunityById(Id opportunityId) {
        return
        [SELECT Id,
                Name,
                AccountId,
                Account.Eligibile_Employee_Count__c,
                Administrative_Contact__c,
                Confirm_New_or_Existing_Group__c,
                Are_you_adding_new_plans_or_services__c,
                Group_Name__c,
                Employee_Eligibility_Waiting_Period__c,
                EE_Eligibility_Waiting_Period__c,
                Tax_ID__c,
                Assigned_Account_Manager__c,
                Residence_State_s__c,
                Estimated_Employees__c,
                Enrollment_Start_Date__c,
                Enrollment_End_Date__c,
                Effective_Date_of_AFA_Products__c,
                Platform__c,
                Employer_Benefits_Site__c,
                Online_Appointment_Scheduler__c,
                Group_Display_Name__c,
                Are_you_making_any_product_changes__c,
                Are_you_making_any_billing_changes__c,
                Physical_Address_Same_As_Billing__c,
                Waiting_Period_Effective__c,
                RecordTypeId,
                Other_Eligibility_Waiting_Period__c,
                RecordType.Name,
                Branch_Office__c,
                Enrollment_Path__c,
                Additional_MCPs__c
           FROM Opportunity
          WHERE Id = :opportunityId];
    }
    
    private static void testOpportunityFieldRequired(String requiredFieldName) {
        loadDefaults();

        Controller.init();
        Controller.eOppty.put(requiredFieldName, null);
        
        Controller.detailsCheckRequiredFields(true);
        
        system.assertEquals(false, Controller.detailsTabComplete, 'The details tab is complete when it should not be.');
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    private static void enrollmentHasAnnuityProductWithNewPlanStatusTest(String annuityProductName) {
        Product_Catalog__c annuityProduct = ProductCatalogTestData.Instance.withType('Benefit').withName(annuityProductName).insertProductCatalog();
        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c importLifeProduct1MarketedProduct = MarketedProductTestData.Instance.withProductCatalog(annuityProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).withPlanStatus('New').insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        
        system.assert(String.isNotBlank(Controller.requiredContacts), 'There are no required contacts when there should be.');
        system.assert(Controller.requiredContacts.contains('annuity'), 'The annuity contact should be required.');
    }
    
    private static void enrollmentHasAnnuityProductWithExistingPlanStatusTest(String annuityProductName) {
        Product_Catalog__c annuityProduct = ProductCatalogTestData.Instance.withType('Benefit').withName(annuityProductName).insertProductCatalog();
        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c importLifeProduct1MarketedProduct = MarketedProductTestData.Instance.withProductCatalog(annuityProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).withPlanStatus('Existing').insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        
        system.assert(String.isNotBlank(Controller.requiredContacts), 'There are no required contacts when there should be.');
        system.assert(Controller.requiredContacts.contains('annuity') == false, 'The annuity contact should not be required.');
    }
    
    private static void disallowedProductNotFoundTest(Id disallowedProductCatalogId) {
        loadDefaults();
        
        Controller.init();
        
        for (GeneralInformationController.catalogWrapper benefitWrapper : Controller.catalogWrapper_ben) {
            system.assertNotEquals(benefitWrapper.pCatalog.Id, disallowedProductCatalogId, 'The disallowed product was found in the benefit products.');
        }
        
        for (GeneralInformationController.catalogWrapper serviceWrapper : Controller.catalogWrapper_svc) {
            system.assertNotEquals(serviceWrapper.pCatalog.Id, disallowedProductCatalogId, 'The disallowed product was found in the service products.');
        }
        
        for (GeneralInformationController.catalogWrapper importWrapper : Controller.catalogWrapper_imp) {
            system.assertNotEquals(importWrapper.pCatalog.Id, disallowedProductCatalogId, 'The disallowed product was found in the import products.');
        }
    }
    
    private static void disallowedMarketedProductNotShownTest(Id disallowedProductCatalogId) {
        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c disallowedMarketedProductAddedBySystem = MarketedProductTestData.Instance.withProductCatalog(disallowedProductCatalogId).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).withPlanStatus('Existing').insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        
        for (Marketed_Product__c benefitMP : Controller.mProducts_ben) {
            system.assertNotEquals(benefitMP.Id, disallowedMarketedProductAddedBySystem.Id, 'The disallowed marketed product is shown in the benefit products.');
        }
        
        for (Marketed_Product__c serviceMP : Controller.mProducts_svc) {
            system.assertNotEquals(serviceMP.Id, disallowedMarketedProductAddedBySystem.Id, 'The disallowed marketed product is shown in the service products.');
        }
        
        for (Marketed_Product__c importMP : Controller.mProducts_imp) {
            system.assertNotEquals(importMP.Id, disallowedMarketedProductAddedBySystem.Id, 'The disallowed marketed product is shown in the import products.');
        }
    }
    
    private static void testEnrollmentPathEnabledWithNullField(String nullField) {
        loadDefaults();
        Controller.init();
        
        Controller.testRequiredPlatformSetupFields = new Set<String>{ nullField };
        Controller.ps.put(nullField, null);
        
        Controller.detailsCheckRequiredFields(true);

        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }

    @isTest
    static void getMarketingInformationSectionLabel_invoke_expectLabelReturnedTest() {
        loadDefaults();
        
        String marketingInformationSectionLabel = Controller.getMarketingInformationSectionLabel();
    }
    
    @isTest
    static void init_invokeWithEnrollmentOpportunity_expectNoErrorsTest() {
        loadDefaults();
        Controller.init();
    }
    
    @isTest
    static void updateEnrollmentOpportunity_EmployerBenefitsSiteSetToYes_expectOpportunityUpdatedTest() {
        loadDefaults();
        
        Controller.eOppty.Employer_Benefits_Site__c = 'Yes';
        Controller.updateEnrollmentOpportunity();
        
        Opportunity oppQueried = getOpportunityById(Controller.eOppty.Id);
        system.assertEquals(Controller.eOppty.Employer_Benefits_Site__c, oppQueried.Employer_Benefits_Site__c, 'The employer benefits site is not the expected one.');
    }
    
    @isTest
    static void updateEnrollmentOpportunity_setEOpptyToNull_expectPageHasErrorMessageTest() {
        loadDefaults();
        
        Controller.eOppty = null;
        Controller.updateEnrollmentOpportunity();
        
        TestUtil.assertPageHasErrorMessage();
        system.assertEquals(true, Controller.ShowErrorMessages, 'No error messages will be shown.');
    }
    
    @isTest
    static void detailsCheckRequiredFields_GroupDisplayNameFieldRequiredAndGroupDisplayNameNull_expectRequiredFieldMessageTest() {
        testOpportunityFieldRequired('Group_Display_Name__c');
    }
    
    @isTest
    static void detailCheckRequiredFields_EEEligibilityWaitingPeriodRequiredAndNull_expectRequiredFieldMessageTest() {
        testOpportunityFieldRequired('EE_Eligibility_Waiting_Period__c');
    }
    
    @isTest
    static void detailCheckRequiredFields_WaitingPeriodEffectiveRequiredAndNull_expectRequiredFieldMessageTest() {
        testOpportunityFieldRequired('Waiting_Period_Effective__c');
    }

    @isTest
    static void detailCheckRequiredFields_PhysicalAddressSameAsBillingRequiredAndNull_expectRequiredFieldMessageTest() {
        testOpportunityFieldRequired('Physical_Address_Same_As_Billing__c');
    }
    
    @isTest
    static void detailCheckRequiredFields_OtherEmployeeEligibilityWaitingPeriodRequiredAndNullAndEmployeeEligibilityWaitingPeriodIsOther_expectRequiredFieldMessageTest() {
        loadDefaults();
        
        DefaultOpportunity.EE_Eligibility_Waiting_Period__c = 'Other';
        update DefaultOpportunity;
        
        testOpportunityFieldRequired('Other_Eligibility_Waiting_Period__c');
    }
    
    @isTest
    static void detailCheckRequiredField_taxIdBlankAndNewGroup_expectRequiredFieldMessageTest() {
        loadDefaults();
        
        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'New';
        update DefaultOpportunity;
        
        testOpportunityFieldRequired('Tax_ID__c');
    }
    
    @isTest
    static void detailCheckRequiredField_taxIdBlankAndExistingGroup_expectNoRequiredFieldMessageTest() {
        Opportunity opp = getDefaultOpportunity();
        
        Enrollment_Path__c divisionalEnrollmentPath = EnrollmentPathTestData.Instance.withDivision(opp.Division__c)
                                                                                     .insertEnrollmentPath();
        
        loadDefaults();
        
        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        DefaultOpportunity.Enrollment_Path__c = divisionalEnrollmentPath.Id;
        
        update DefaultOpportunity;
        
        loadDefaults();
        Controller.init();
        
        Account acct = new Account(Id = Controller.eOppty.AccountId);
        acct.BillingStreet = 'Existing';
        acct.BillingCity = 'Existing';
        acct.BillingState = 'Existing';
        acct.BillingPostalCode = 'Existing';
        acct.Payroll_Company__c = 'Existing';
        
        update acct;

        Controller.enrollmentRushRequested = false;

        Controller.eOppty.Tax_ID__c = null;
        
        Controller.eOppty.Group_Name__c = 'Existing';
        Controller.eOppty.EE_Eligibility_Waiting_Period__c = 'Existing';
        Controller.eOppty.Waiting_Period_Effective__c = 'Existing';
        Controller.eOppty.Residence_State_s__c = 'NY';
        Controller.eOppty.Estimated_Employees__c = 25;
        Controller.eOppty.Enrollment_Start_Date__c = Date.Today();
        Controller.eOppty.Enrollment_End_Date__c = Date.Today();
        Controller.eOppty.Effective_Date_of_AFA_Products__c = Date.Today();
        Controller.eOppty.Physical_Address_Same_As_Billing__c = 'Yes';
        Controller.eOppty.Platform__c = 'Existing';
        
        Platform_Setup__c ps = [SELECT Id
                                  FROM Platform_Setup__c
                                 where Enrollment_Form__r.Enrollment_Opportunity__c = :Controller.eOppty.Id];

        ps.Enroll_Info_GrpToCcontactForData__c = 'Existing';
        ps.Enroll_Info_First_Payroll_Deduction_Date__c = Date.Today();
        ps.Enroll_Info_Payroll_Deduction_Begins__c = 'Existing';
        ps.EnrollInfoPayrollDeductFrequenc__c = 'Existing';
        ps.Enrollment_Setup__c = 'Open Enrollment';
        ps.Enroll_Info_Service_Process__c = 'Hybrid';
        
        update ps;
        
        Controller.detailsCheckRequiredFields(true);
        
        system.assertEquals(true, Controller.detailsTabComplete, 'The details tab is not complete when it should be.');
    }
    
    @isTest
    static void detailCheckRequiredField_taxIdSuppliedWithIncorrectFormat_expectInvalidTaxIdFormatMessageTest() {
        loadDefaults();
        
        Controller.init();
        Controller.eOppty.Tax_ID__c = 'Some Tax Id';
        
        Controller.detailsCheckRequiredFields(true);
        
        system.assertEquals(false, Controller.detailsTabComplete, 'The details tab is complete when it should not be.');
        TestUtil.assertPageHasMessage(GeneralInformationController.INVALID_EIN_FORMAT_VAL_MSG);
    }

    @isTest
    static void detailCheckRequiredField_additionalMCPsSuppliedWithSemiColonDelimiter_expectInvalidAdditionalMCPsMessageTest() {
        loadDefaults();
        
        Controller.init();
        Controller.eOppty.Additional_MCPs__c = '19381;19380;17361';
        
        Controller.detailsCheckRequiredFields(true);
        
        system.assertEquals(false, Controller.detailsTabComplete, 'The details tab is complete when it should not be.');
        TestUtil.assertPageHasMessage(Label.General_Information_Additional_MCPs_Validation_Message);
    }

    @isTest
    static void detailCheckRequiredField_noAdditionalMCPsSupplied_expectNoInvalidAdditionalMCPsMessageTest() {
        loadDefaults();
        
        Controller.init();
        Controller.eOppty.Additional_MCPs__c = '';
        
        Controller.detailsCheckRequiredFields(true);

        TestUtil.assertPageDoesNotHaveMessage(Label.General_Information_Additional_MCPs_Validation_Message);
    }

    @isTest
    static void detailCheckRequiredField_oneAdditionalMCPSupplied_expectNoInvalidAdditionalMCPsMessageTest() {
        loadDefaults();
        
        Controller.init();
        Controller.eOppty.Additional_MCPs__c = '19371';
        
        Controller.detailsCheckRequiredFields(true);

        TestUtil.assertPageDoesNotHaveMessage(Label.General_Information_Additional_MCPs_Validation_Message);
    }

    @isTest
    static void detailCheckRequiredField_twoAdditionalMCPSuppliedAndAreCommaSeparated_expectNoInvalidAdditionalMCPsMessageTest() {
        loadDefaults();
        
        Controller.init();
        Controller.eOppty.Additional_MCPs__c = '19371,69281';
        
        Controller.detailsCheckRequiredFields(true);

        TestUtil.assertPageDoesNotHaveMessage(Label.General_Information_Additional_MCPs_Validation_Message);
    }
    
    @isTest
    static void addSelectedProducts_oneImportVisionProductToAdd_expectVisionProductAddedTest() {
        Product_Catalog__c importVisionProduct = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Vision').insertProductCatalog();
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(1, Controller.catalogWrapper_imp.size(), 'There are no import product catalogs');
        
        GeneralInformationController.catalogWrapper importVisionCatalogWrapper = Controller.catalogWrapper_imp[0];
        importVisionCatalogWrapper.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(false, Controller.addProductError, 'There should be no add product errors. ');
    }
    
    @isTest
    static void addSelectedProducts_twoImportVisionProductsToAdd_expectOnly1ImportVisionProductAllowedValidationTest() {
        Product_Catalog__c importVisionProduct1 = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Vision').insertProductCatalog();
        Product_Catalog__c importVisionProduct2 = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Vision').insertProductCatalog();
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(2, Controller.catalogWrapper_imp.size(), 'There are no import product catalogs');
        
        GeneralInformationController.catalogWrapper importVisionCatalogWrapper1 = Controller.catalogWrapper_imp[0];
        importVisionCatalogWrapper1.addProduct = true;
        
        GeneralInformationController.catalogWrapper importVisionCatalogWrapper2 = Controller.catalogWrapper_imp[1];
        importVisionCatalogWrapper2.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(true, Controller.addProductError, 'There should be add product errors.');
        system.assert(Controller.addProductErrorMessage.containsIgnoreCase(GeneralInformationController.ONLY_1_VISION_IMPORT_PRODUCT_ALLOWED_VAL_MSG), 'The expected error message was not found.');
    }
    
    @isTest
    static void addSelectedProducts_oneLifeImportProductToAdd_expectLifeImportProductAddedTest() {
        Product_Catalog__c importLifeProduct = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Life').insertProductCatalog();
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(1, Controller.catalogWrapper_imp.size(), 'There are no import product catalogs');
        
        GeneralInformationController.catalogWrapper importLifeCatalogWrapper = Controller.catalogWrapper_imp[0];
        importLifeCatalogWrapper.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(false, Controller.addProductError, 'There should be no add product errors. ');
    }
    
    @isTest
    static void addSelectedProducts_twoImportLifeProductsToAdd_expectOnly1ImportLifeProductAllowedValidationTest() {
        Product_Catalog__c importLifeProduct1 = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Life').insertProductCatalog();
        Product_Catalog__c importLifeProduct2 = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Life').insertProductCatalog();
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(2, Controller.catalogWrapper_imp.size(), 'There are no import product catalogs');
        
        GeneralInformationController.catalogWrapper importLifeCatalogWrapper1 = Controller.catalogWrapper_imp[0];
        importLifeCatalogWrapper1.addProduct = true;
        
        GeneralInformationController.catalogWrapper importLifeCatalogWrapper2 = Controller.catalogWrapper_imp[1];
        importLifeCatalogWrapper2.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(true, Controller.addProductError, 'There should be add product errors.');
        system.assert(Controller.addProductErrorMessage.containsIgnoreCase(GeneralInformationController.ONLY_1_LIFE_IMPORT_PRODUCT_ALLOWED_VAL_MSG), 'The expected error message was not found.');
    }
    
    @isTest
    static void addSelectedProducts_oneLifeImportProductToAddWithOneLifeImportExistingMarketedProduct_expectOnly1ImportLifeProductAllowedValidationTest() {
        Product_Catalog__c importLifeProduct1 = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Life').insertProductCatalog();
        Product_Catalog__c importLifeProduct2 = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Life').insertProductCatalog();
        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c importLifeProduct1MarketedProduct = MarketedProductTestData.Instance.withProductCatalog(importLifeProduct1.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(1, Controller.catalogWrapper_imp.size(), 'There are no import product catalogs');
        
        GeneralInformationController.catalogWrapper importLifeCatalogWrapper1 = Controller.catalogWrapper_imp[0];
        importLifeCatalogWrapper1.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(true, Controller.addProductError, 'There should be add product errors.');
        system.assert(Controller.addProductErrorMessage.containsIgnoreCase(GeneralInformationController.ONLY_1_LIFE_IMPORT_PRODUCT_ALLOWED_VAL_MSG), 'The expected error message was not found.');
    }
    
    @isTest
    static void addSelectedProducts_oneVisionImportProductToAddWithOneVisionImportExistingMarketedProduct_expectOnly1ImportVisionProductAllowedValidationTest() {
        Product_Catalog__c importVisionProduct1 = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Vision').insertProductCatalog();
        Product_Catalog__c importVisionProduct2 = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Vision').insertProductCatalog();
        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c importLifeProduct1MarketedProduct = MarketedProductTestData.Instance.withProductCatalog(importVisionProduct1.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(1, Controller.catalogWrapper_imp.size(), 'There are no import product catalogs');
        
        GeneralInformationController.catalogWrapper importVisionCatalogWrapper1 = Controller.catalogWrapper_imp[0];
        importVisionCatalogWrapper1.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(true, Controller.addProductError, 'There should be add product errors.');
        system.assert(Controller.addProductErrorMessage.containsIgnoreCase(GeneralInformationController.ONLY_1_VISION_IMPORT_PRODUCT_ALLOWED_VAL_MSG), 'The expected error message was not found.');
    }

    @isTest
    static void addSelectedProducts_oneAccidentProductToAdd_expectAccidentProductAddedTest() {
        Product_Catalog__c serviceAccidentProduct = ProductCatalogTestData.Instance.withType('Service').withProductFamily('Accident').insertProductCatalog();
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(1, Controller.catalogWrapper_svc.size(), 'There are no service product catalogs');
        
        GeneralInformationController.catalogWrapper serviceAccidentCatalogWrapper = Controller.catalogWrapper_svc[0];
        serviceAccidentCatalogWrapper.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(false, Controller.addProductError, 'There should be no add product errors.');
    }
    
    @isTest
    static void addSelectedProducts_twoServiceAccidentProductsToAdd_expectOnly1AccidentProductAllowedValidationTest() {
        Product_Catalog__c serviceAccidentProduct1 = ProductCatalogTestData.Instance.withType('Service').withProductFamily('Accident').insertProductCatalog();
        Product_Catalog__c serviceAccidentProduct2 = ProductCatalogTestData.Instance.withType('Service').withProductFamily('Accident').insertProductCatalog();
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(2, Controller.catalogWrapper_svc.size(), 'There are no service product catalogs');
        
        GeneralInformationController.catalogWrapper serviceAccidentCatalogWrapper1 = Controller.catalogWrapper_svc[0];
        serviceAccidentCatalogWrapper1.addProduct = true;
        
        GeneralInformationController.catalogWrapper serviceAccidentCatalogWrapper2 = Controller.catalogWrapper_svc[1];
        serviceAccidentCatalogWrapper2.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(true, Controller.addProductError, 'There should be add product errors.');
        system.assert(Controller.addProductErrorMessage.containsIgnoreCase(GeneralInformationController.ONLY_1_ACCIDENT_PRODUCT_ALLOWED_VAL_MSG), 'The expected error message was not found.');
    }

    @isTest
    static void addSelectedProducts_twoServiceAccidentProductsToAddButOneIsARider_expectNoOnly1AccidentProductAllowedValidationTest() {
        Product_Catalog__c serviceAccidentProduct1 = ProductCatalogTestData.Instance.withType('Service').withProductFamily('Accident').insertProductCatalog();
        Product_Catalog__c serviceAccidentProductWithRider = ProductCatalogTestData.Instance.withType('Service').withProductFamily('Accident').withRider(true).insertProductCatalog();
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(2, Controller.catalogWrapper_svc.size(), 'There are no service product catalogs');
        
        GeneralInformationController.catalogWrapper serviceAccidentCatalogWrapper1 = Controller.catalogWrapper_svc[0];
        serviceAccidentCatalogWrapper1.addProduct = true;
        
        GeneralInformationController.catalogWrapper serviceAccidentCatalogWrapper2 = Controller.catalogWrapper_svc[1];
        serviceAccidentCatalogWrapper2.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(false, Controller.addProductError, 'There should be no add product errors.');
        system.assert(Controller.addProductErrorMessage.containsIgnoreCase(GeneralInformationController.ONLY_1_ACCIDENT_PRODUCT_ALLOWED_VAL_MSG) == false, 'The expected error message was not found.');
    }
    
    @isTest
    static void addSelectedProducts_twoServiceAccidentProductsWithOneRiderAlreadyAddedButAddingANonAccidentProduct_expectNonAccidentProductAddedTest() {
        Product_Catalog__c serviceAccidentProduct1 = ProductCatalogTestData.Instance.withType('Service').withProductFamily('Accident').insertProductCatalog();
        Product_Catalog__c serviceAccidentProductWithRider = ProductCatalogTestData.Instance.withType('Service').withProductFamily('Accident').withRider(true).insertProductCatalog();
        Product_Catalog__c serviceDisabilityProduct = ProductCatalogTestData.Instance.withType('Service').withProductFamily('Disability').insertProductCatalog();
        
        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c accidentProductMP = MarketedProductTestData.Instance.withProductCatalog(serviceAccidentProduct1.Id)
                                                                       .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                       .withPlanStatus('New')
                                                                       .insertMarketedProduct();

        Marketed_Product__c accidentProductRiderMP = MarketedProductTestData.Instance.withProductCatalog(serviceAccidentProductWithRider.Id)
                                                                       .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                       .withPlanStatus('New')
                                                                       .insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(1, Controller.catalogWrapper_svc.size(), 'There are no service product catalogs');
        
        GeneralInformationController.catalogWrapper serviceDisabilityCatalogWrapper = Controller.catalogWrapper_svc[0];
        
        system.assertEquals(serviceDisabilityProduct.Id, serviceDisabilityCatalogWrapper.pCatalog.Id, 'The disability product was not selected.');
        
        serviceDisabilityCatalogWrapper.addProduct = true;
        
        Controller.addSelectedProducts();
        
        system.assertEquals(false, Controller.addProductError, 'There should be no add product errors.');
        system.assert(Controller.addProductErrorMessage.containsIgnoreCase(GeneralInformationController.ONLY_1_ACCIDENT_PRODUCT_ALLOWED_VAL_MSG) == false, 'The expected error message was not found.');
    }
    
    @isTest
    static void setRequiredContacts_enrollmentHas403BAFAdvantageProductWithNewPlanStatus_expectAnnuityContactRequiredTest() {
        enrollmentHasAnnuityProductWithNewPlanStatusTest('403(b) AFadvantage');
    }
    
    @isTest
    static void setRequiredContacts_enrollmentHas403BAFPrimeProductWithNewPlanStatus_expectAnnuityContactRequiredTest() {
        enrollmentHasAnnuityProductWithNewPlanStatusTest('403(b) AFPrime');
    }
    
    @isTest
    static void setRequiredContacts_enrollmentHas403BFixedAnnuityProductWithNewPlanStatus_expectAnnuityContactRequiredTest() {
        enrollmentHasAnnuityProductWithNewPlanStatusTest('403(b) Fixed Annuity');
    }
    
    @isTest
    static void setRequiredContacts_enrollmentHas457BAFMaxProductWithNewPlanStatus_expectAnnuityContactRequiredTest() {
        enrollmentHasAnnuityProductWithNewPlanStatusTest('457(b) AFmaxx');
    }
    
    @isTest
    static void setRequiredContacts_enrollmentHas403BAFAdvantageProductWithExistingPlanStatus_expectAnnuityContactNotRequiredTest() {
        enrollmentHasAnnuityProductWithExistingPlanStatusTest('403(b) AFadvantage');
    }
    
    @isTest
    static void setRequiredContacts_enrollmentHas403BAFPrimeProductWithExistingPlanStatus_expectAnnuityContactNotRequiredTest() {
        enrollmentHasAnnuityProductWithExistingPlanStatusTest('403(b) AFPrime');
    }
    
    @isTest
    static void setRequiredContacts_enrollmentHas403BFixedAnnuityProductWithExistingPlanStatus_expectAnnuityContactNotRequiredTest() {
        enrollmentHasAnnuityProductWithExistingPlanStatusTest('403(b) Fixed Annuity');
    }
    
    @isTest
    static void setRequiredContacts_enrollmentHas457BAFMaxProductWithExistingPlanStatus_expectAnnuityContactNotRequiredTest() {
        enrollmentHasAnnuityProductWithExistingPlanStatusTest('457(b) AFmaxx');
    }
    
    @isTest
    static void getProductCatalog_DisallowedBenefitProductCreated_expectProductNotAvailableTest() {
        Product_Catalog__c disallowedBenefit = ProductCatalogTestData.Instance.withAllowedToBeAddedToEnrollment(false)
                                                                              .withType('Benefit')
                                                                              .insertProductCatalog();
        
        disallowedProductNotFoundTest(disallowedBenefit.Id);
    }
    
    @isTest
    static void getProductCatalog_DisallowedServiceProductCreated_expectProductNotAvailableTest() {
        Product_Catalog__c disallowedService = ProductCatalogTestData.Instance.withAllowedToBeAddedToEnrollment(false)
                                                                              .withType('Service')
                                                                              .insertProductCatalog();
        
        disallowedProductNotFoundTest(disallowedService.Id);
    }
    
    @isTest
    static void getProductCatalog_DisallowedImportProductCreated_expectProductNotAvailableTest() {
        Product_Catalog__c disallowedImport = ProductCatalogTestData.Instance.withAllowedToBeAddedToEnrollment(false)
                                                                              .withType('Import')
                                                                              .insertProductCatalog();
        
        disallowedProductNotFoundTest(disallowedImport.Id);
    }
    
    @isTest
    static void getProductData_disallowedBenefitProductAddedToEnrollmentBySystem_expectProductNotShownTest() {
        Product_Catalog__c disallowedBenefit = ProductCatalogTestData.Instance.withAllowedToBeAddedToEnrollment(false)
                                                                              .withType('Benefit')
                                                                              .insertProductCatalog();
        
        disallowedMarketedProductNotShownTest(disallowedBenefit.Id);
    }
    
    @isTest
    static void getProductData_disallowedServiceProductAddedToEnrollmentBySystem_expectProductNotShownTest() {
        Product_Catalog__c disallowedService = ProductCatalogTestData.Instance.withAllowedToBeAddedToEnrollment(false)
                                                                              .withType('Service')
                                                                              .insertProductCatalog();
        
        disallowedMarketedProductNotShownTest(disallowedService.Id);
    }
    
    @isTest
    static void getProductData_disallowedImportProductAddedToEnrollmentBySystem_expectProductNotShownTest() {
        Product_Catalog__c importService = ProductCatalogTestData.Instance.withAllowedToBeAddedToEnrollment(false)
                                                                              .withType('Import')
                                                                              .insertProductCatalog();
        
        disallowedMarketedProductNotShownTest(importService.Id);
    }
    
    @isTest
    static void productCheckRequiredFields_productCatalogIsTaxTreatmentEditableIsFalseAndMarketedProductTaxTreatmentBlank_expectNoRequiredFieldMessageTest() {
        Product_Catalog__c noTaxTreatmentEditableProduct = ProductCatalogTestData.Instance.withIsTaxTreatmentEditable(false)
                                                                                          .insertProductCatalog();

        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c noTaxTreatmentMP = MarketedProductTestData.Instance.withProductCatalog(noTaxTreatmentEditableProduct.Id)
                                                                               .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                               .withTaxTreatment(null)
                                                                               .withPlanStatus('New')
                                                                               .insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        Controller.productCheckRequiredFields(true);
        
        system.assertEquals(true, Controller.productTabComplete, 'The product tab is not complete when it should be.');
        TestUtil.assertPageDoesNotHaveMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    static void productCheckRequiredFields_productCatalogIsTaxTreatmentEditableIsTrueAndMarketedProductTaxTreatmentBlank_expectRequiredFieldMessageTest() {
        Product_Catalog__c taxTreatmentEditableProduct = ProductCatalogTestData.Instance.withIsTaxTreatmentEditable(true)
                                                                                          .insertProductCatalog();

        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c noTaxTreatmentMP = MarketedProductTestData.Instance.withProductCatalog(taxTreatmentEditableProduct.Id)
                                                                               .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                               .withTaxTreatment(null)
                                                                               .withPlanStatus('New')
                                                                               .insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        Controller.productCheckRequiredFields(true);
        
        system.assertEquals(false, Controller.productTabComplete, 'The product tab is not complete when it should be.');
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    static void productCheckRequiredFields_productCatalogIsTaxTreatmentEditableIsTrueAndMarketedProductTaxTreatmentNotBlank_expectNoRequiredFieldMessageTest() {
        Product_Catalog__c taxTreatmentEditableProduct = ProductCatalogTestData.Instance.withIsTaxTreatmentEditable(true)
                                                                                          .insertProductCatalog();

        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c noTaxTreatmentMP = MarketedProductTestData.Instance.withProductCatalog(taxTreatmentEditableProduct.Id)
                                                                               .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                               .withTaxTreatment('Pre-Tax')
                                                                               .withPlanStatus('New')
                                                                               .insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        Controller.productCheckRequiredFields(true);
        
        system.assertEquals(true, Controller.productTabComplete, 'The product tab is not complete when it should be.');
        TestUtil.assertPageDoesNotHaveMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    static void productCheckRequiredFields_MarketedProductPlanStatusBlank_expectRequiredFieldMessageTest() {
        Product_Catalog__c noTaxTreatmentEditableProduct = ProductCatalogTestData.Instance.withIsTaxTreatmentEditable(false)
                                                                                          .insertProductCatalog();

        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c noTaxTreatmentMP = MarketedProductTestData.Instance.withProductCatalog(noTaxTreatmentEditableProduct.Id)
                                                                               .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                               .withTaxTreatment('Pre-Tax')
                                                                               .withPlanStatus('')
                                                                               .insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        Controller.productCheckRequiredFields(true);
        
        system.assertEquals(false, Controller.productTabComplete, 'The product tab is not complete when it should be.');
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    static void productCheckRequiredFields_MarketedProductPlanStatusNotBlank_expectNoRequiredFieldMessageTest() {
        Product_Catalog__c taxTreatmentEditableProduct = ProductCatalogTestData.Instance.withIsTaxTreatmentEditable(false)
                                                                                          .insertProductCatalog();

        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c noTaxTreatmentMP = MarketedProductTestData.Instance.withProductCatalog(taxTreatmentEditableProduct.Id)
                                                                               .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                               .withTaxTreatment('Pre-Tax')
                                                                               .withPlanStatus('New')
                                                                               .insertMarketedProduct();
        
        loadDefaults();
        
        Controller.init();
        Controller.productCheckRequiredFields(true);
        
        system.assertEquals(true, Controller.productTabComplete, 'The product tab is not complete when it should be.');
        TestUtil.assertPageDoesNotHaveMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    static void loadEnrollmentPaths_oneActiveDivisionalEnrollmentPath_expectEnrollmentPathLoadedTest() {
        Opportunity opp = getDefaultOpportunity();
        
        Enrollment_Path__c divisionalEnrollmentPath = EnrollmentPathTestData.Instance.withDivision(opp.Division__c)
                                                                                     .insertEnrollmentPath();

        loadDefaults();
        
        Controller.init();
        
        system.assert(Controller.EnrollmentPaths != null, 'The enrollments paths are null.');
        system.assertEquals(1, Controller.EnrollmentPaths.size(), 'There should be one enrollment path.');
        system.assertEquals(divisionalEnrollmentPath.Id, Controller.EnrollmentPaths[0].Id, 'The divisional enrollment path was not loaded.');
    }
    
    @isTest
    static void loadEnrollmentPaths_oneInactiveDivisionalEnrollmentPath_expectEnrollmentPathNotLoadedTest() {
        Opportunity opp = getDefaultOpportunity();
        
        Enrollment_Path__c inactiveEnrollmentPath = EnrollmentPathTestData.Instance.withDivision(opp.Division__c)
                                                                                   .withStatus('Inactive')
                                                                                   .insertEnrollmentPath();

        loadDefaults();
        
        Controller.init();
        
        system.assert(Controller.EnrollmentPaths != null, 'The enrollments paths are null.');
        system.assertEquals(0, Controller.EnrollmentPaths.size(), 'There should be no enrollment paths.');
    }
    
    @isTest
    static void updateEnrollmentPath_enrollmentPathSelected_expectEnrollmentPathFieldUpdatedTest() {
        Opportunity opp = getDefaultOpportunity();
        
        Enrollment_Path__c divisionalEnrollmentPath = EnrollmentPathTestData.Instance.withDivision(opp.Division__c)
                                                                                     .insertEnrollmentPath();

        loadDefaults();
        
        Controller.init();
        Controller.selectedEnrollmentPathId = divisionalEnrollmentPath.Id;
        Controller.updateEnrollmentPath();
        
        opp = getDefaultOpportunity();
        
        system.assertEquals(divisionalEnrollmentPath.Id, opp.Enrollment_Path__c, 'The opportunity\'s enrollment path was not updated to the expected one.');
    }

    @isTest
    static void isEnrollmentRushRequested_enrollmentPathSelectedWithNotEnoughLeadTime_expectEnrollmentRushRequestedIsTrueTest() {
        Opportunity opp = getDefaultOpportunity();

        Integer leadTime = 21;

        Enrollment_Path__c divisionalEnrollmentPath = EnrollmentPathTestData.Instance.withDivision(opp.Division__c)
                                                                                     .withLeadTime(leadTime)
                                                                                     .insertEnrollmentPath();

        opp.Enrollment_Start_Date__c = Date.Today().addDays(leadTime - 1);
        opp.Enrollment_Path__c = divisionalEnrollmentPath.Id;
        update opp;

        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(true, Controller.enrollmentRushRequested, 'The enrollment rush requested should be true.');
    }

    @isTest
    static void isEnrollmentRushRequested_enrollmentPathSelectedWithEnoughLeadTime_expectEnrollmentRushRequestedIsFalseTest() {
        Opportunity opp = getDefaultOpportunity();

        Integer leadTime = 21;

        Enrollment_Path__c divisionalEnrollmentPath = EnrollmentPathTestData.Instance.withDivision(opp.Division__c)
                                                                                     .withLeadTime(leadTime)
                                                                                     .insertEnrollmentPath();

        opp.Enrollment_Start_Date__c = Date.Today().addDays(leadTime + 1);
        opp.Enrollment_Path__c = divisionalEnrollmentPath.Id;
        update opp;

        loadDefaults();
        
        Controller.init();
        
        system.assertEquals(false, Controller.enrollmentRushRequested, 'The enrollment rush requested should be false.');
    }
    
    @isTest
    static void detailCheckRequiredFields_AFEnrollPlatformWithoutEnrollmentType_expectRequiredFieldMessageTest() {
        loadDefaults();
        Controller.init();
        
        Controller.eOppty.Platform__c = 'AFenroll';
        Controller.ps.Enroll_Info_Enrollment_Type__c = null;
        
        Controller.detailsCheckRequiredFields(true);
        
        system.assertEquals(false, Controller.detailsTabComplete, 'The details tab is complete when it should not be.');
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    static void detailCheckRequiredFields_EnrollmentPathEnabledAndEnrollmentSetupNull_expectRequiredFieldMessageTest() {
        loadDefaults();
        Controller.init();
        
        Controller.ps.Enrollment_Setup__c = null;
        
        Controller.detailsCheckRequiredFields(true);
        
        system.assertEquals(false, Controller.detailsTabComplete, 'The details tab is complete when it should not be.');
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    static void detailCheckRequiredFields_EnrollmentPathEnabledAndRushRequestedAndRushReasonNull_expectRequiredFieldMessageTest() {
        loadDefaults();
        Controller.init();
        
        Controller.enrollmentRushRequested = true;
        Controller.eOppty.Enrollment_Rush_Request_Reason__c = null;
        
        Controller.detailsCheckRequiredFields(true);
        
        system.assertEquals(false, Controller.detailsTabComplete, 'The details tab is complete when it should not be.');
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }

    @isTest
    static void detailCheckRequiredFields_EnrollmentPathEnabledAndEnrollmentPathNull_expectEnrollmentPathRequiredMessageTest() {
        loadDefaults();
        Controller.init();
        
        Controller.eOppty.Enrollment_Path__c = null;
        
        Controller.detailsCheckRequiredFields(true);
        
        system.assertEquals(GeneralInformationController.ENROLLMENT_PATH_REQUIRED_VAL_MSG, Controller.enrollmentPathRequiredMessage, 'The enrollment path required message was not shown.');
    }

    @isTest
    static void detailCheckRequiredFields_EnrollmentStartDateAfterEnrollmentEndDate_expectEnrollmentStartDateAfterEndDateMessageTest() {
        loadDefaults();
        Controller.init();

        Controller.eOppty.Enrollment_Start_Date__c = Date.Today();
        Controller.eOppty.Enrollment_End_Date__c = Controller.eOppty.Enrollment_Start_Date__c.addDays(-1);

        Controller.detailsCheckRequiredFields(true);

        TestUtil.assertPageHasMessage(GeneralInformationController.ENROLLMENT_END_DATE_AFTER_START_DATE_VAL_MSG);
    }
    
    @isTest
    static void detailsCheckRequiredFields_enrollmentPathEnabledAndGroupContactForDataRequiredAndNull_expectRequiredFieldMessageTest() {
        testEnrollmentPathEnabledWithNullField('Enroll_Info_GrpToCcontactForData__c');
    }
    
    @isTest
    static void detailsCheckRequiredFields_enrollmentPathEnabledAndServiceProcessRequiredAndNull_expectRequiredFieldMessageTest() {
        testEnrollmentPathEnabledWithNullField('Enroll_Info_Service_Process__c');
    }
    
    @isTest
    static void detailsCheckRequiredFields_enrollmentPathEnabledAndEnrollmentSetupRequiredAndNull_expectRequiredFieldMessageTest() {
        testEnrollmentPathEnabledWithNullField('Enrollment_Setup__c');
    }
    
    @isTest
    static void detailsCheckRequiredFields_enrollmentPathEnabledAndRequestingDataRequiredAndNull_expectRequiredFieldMessageTest() {
        testEnrollmentPathEnabledWithNullField('Requesting_Data__c');
    }
    
    @isTest
    static void detailsCheckRequiredFields_enrollmentPathEnabledAndProvidingDependentDataRequiredAndNull_expectRequiredFieldMessageTest() {
        testEnrollmentPathEnabledWithNullField('Providing_Dependent_Data__c');
    }
    
    @isTest
    static void detailsCheckRequiredFields_enrollmentPathEnabledAndEnrollmentEmployeeThesholdShortAndThresholdReasonRequiredAndNull_expectRequiredFieldMessageTest() {
        loadDefaults();
        Controller.init();
        
        Controller.enrollmentEmployeeThresholdShort = true;
        Controller.ps.Below_Eligible_Employee_Threshold_Reason__c = null;
        
        Controller.detailsCheckRequiredFields(true);

        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    static void EnrollmentPathPlatformSetupFieldSet_enrollmentPathNullOnOpportunity_expectEmptyFieldSetTest() {
        loadDefaults();
        Controller.init();
        
        Controller.eOppty.Enrollment_Path__c = null;
        
        String platformSetupFieldSet = Controller.EnrollmentPathPlatformSetupFieldSet;
        
        system.assert(String.isBlank(platformSetupFieldSet), 'The platform setup field set should be blank.');
    }

    @isTest
    static void EnrollmentPathPlatformSetupFieldSet_enrollmentPathSetOnOpportunityButHasNoPlatformSetupFieldSet_expectEmptyFieldSetTest() {
        Enrollment_Path__c ep = EnrollmentPathTestData.Instance.withPlatformSetupFieldSet('').insertEnrollmentPath();
        
        loadDefaults();
        Controller.init();
        
        Controller.eOppty.Enrollment_Path__c = ep.Id;
        
        String platformSetupFieldSet = Controller.EnrollmentPathPlatformSetupFieldSet;
        
        system.assertEquals(ep.Platform_Setup_Field_Set__c, platformSetupFieldSet, 'The platform setup field set should be blank.');
    }

    @isTest
    static void EnrollmentPathPlatformSetupFieldSet_enrollmentPathSetOnOpportunityWithPlatformSetupFieldSet_expectSpecifiedFieldSetTest() {
        Opportunity opp = getDefaultOpportunity();
        
        Enrollment_Path__c ep = EnrollmentPathTestData.Instance.withPlatformSetupFieldSet('Some_Field_Set')
                                                               .withDivision(opp.Division__c)
                                                               .insertEnrollmentPath();
        
        loadDefaults();
        Controller.init();
        
        Controller.eOppty.Enrollment_Path__c = ep.Id;
        
        String platformSetupFieldSet = Controller.EnrollmentPathPlatformSetupFieldSet;
        
        system.assertEquals(ep.Platform_Setup_Field_Set__c, platformSetupFieldSet, 'The platform setup field set should not be blank and be the same as the one specified.');
    }
    
    @isTest
    static void updatePlatformSetupForEnrollmentPath_belowEmployeeEligibleThresholdReasonSpecified_expectFieldUpdatedTest() {
        loadDefaults();
        Controller.init();
        
        String belowEmployeeThresholdReason = 'Some reason.';
        
        Controller.ps.Below_Eligible_Employee_Threshold_Reason__c = belowEmployeeThresholdReason;
        Controller.updatePlatformSetupForEnrollmentPath();
        
        // requery the data
        Controller.init();
        
        system.assertEquals(belowEmployeeThresholdReason, Controller.ps.Below_Eligible_Employee_Threshold_Reason__c, 'The employee eligible threshold reason was not updated.');
    }
    
    @isTest
    static void setDefaultEnrollmentPath_defaultWhenLessThanEmployeeMinimumIsTrueAndEligibleEmployeeCountLessThanEmployeeMinimum_expectOpportunityEnrollmentPathDefaultedToGivenEnrollmentPathTest() {
        Opportunity opp = getDefaultOpportunity();

        Integer employeeMinimum = 100;
        
        opp.Estimated_Employees__c = employeeMinimum - 1;
        update opp;
        
        Enrollment_Path__c ep = EnrollmentPathTestData.Instance.withDefaultWhenLessThanEmployeeMinimum(true)
                                                               .withEmployeeMinimum(employeeMinimum)
                                                               .withDivision(opp.Division__c)
                                                               .insertEnrollmentPath();
        
        loadDefaults();
        Controller.init();
        
        system.assertEquals(ep.Id, Controller.eOppty.Enrollment_Path__c, 'The enrollment path on the opportunity was not defaulted to the expected one.');
    }
    
    @isTest
    static void setEnrollmentEmployeeThresholdInfo_EligibleEmployeeCountLessThanEmployeeMinimumAndBelowEmployeeMinimumReasonRequiredWithBelowMinimumEmployeeMessage_expectBelowMinimumEmployeeMessageUsedTest() {
        Opportunity opp = getDefaultOpportunity();

        Integer employeeMinimum = 100;
        String belowEmployeeMinMsg = 'Some below employee minimum message';
        Enrollment_Path__c ep = EnrollmentPathTestData.Instance.withBelowEmployeeMinimumReasonRequired(true)
                                                               .withEmployeeMinimum(employeeMinimum)
                                                               .withDivision(opp.Division__c)
                                                               .withBelowMinimumEmployeeMessage(belowEmployeeMinMsg)
                                                               .insertEnrollmentPath();
        
        opp.Estimated_Employees__c = employeeMinimum - 1;
        opp.Enrollment_Path__c = ep.Id;
        update opp;
        
        loadDefaults();
        Controller.init();
        
        system.assertEquals(belowEmployeeMinMsg, Controller.enrollmentEmployeeShortMessage, 'The enrollment path\'s below minimum employee message was not used.');
    }
}