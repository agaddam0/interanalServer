@isTest
public with sharing class SetupFormManagementTest {
    private static Opportunity DefaultOpportunity { get; set; }
    private static Enrollment_Form__c DefaultOpportunityEnrollmentForm { get; set; }
    private static GeneralInformationController Controller { get; set; }
    private static Customer_Setup_Form__c DefaultCustomerSetupForm { get; set; }

    @testSetup
    private static void setup() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
    }
    
    private static void loadDefaults() {
        Test.setCurrentPage(Page.GeneralInformation);
        
        DefaultOpportunity = getDefaultOpportunity();
        loadDefaultOpportunityEnrollmentForm();
    }
    
    private static void loadDefaultsWithCustomerSetupForm() {
        loadDefaults();
        
        DefaultOpportunity.Are_you_adding_new_plans_or_services__c = 'No Changes';
        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        
        update DefaultOpportunity;
        
        Product_Catalog__c importProduct = ProductCatalogTestData.Instance.withType('Import').withChassis('Group').insertProductCatalog();
        Marketed_Product__c newGroupMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(importProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                  .withPlanStatus('New')
                  .insertMarketedProduct();
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
                Branch_Office__c
           FROM Opportunity];
    }
    
    private static void loadDefaultCustomerSetupForm() {
        DefaultCustomerSetupForm =
        [SELECT Id,
                Name,
                GrpHospitalIndemnity__c
           FROM Customer_Setup_Form__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :DefaultOpportunity.Id];
    }
    
    private static void assertOpportunityHasNoCustomerSetupForm(Id opportunityId) {
        List<Customer_Setup_Form__c> oppCSFs = getCustomerSetupFormByOppId(opportunityId);
        
        system.assertEquals(0, oppCSFs.size(), 'The opportunity should not have any customer setup forms.');
    }
    
    private static void assertOpportunityHasCustomerSetupForm(Id opportunityId) {
        List<Customer_Setup_Form__c> oppCSFs = getCustomerSetupFormByOppId(opportunityId);
        
        system.assertEquals(1, oppCSFs.size(), 'The opportunity should have one customer setup form.');
    }

    private static void assertOpportunityHasNoSection125SetupForm(Id opportunityId) {
        List<Section_125_Setup_Form__c> oppS125s = getSection125SetupFormByOppId(opportunityId);
        
        system.assertEquals(0, oppS125s.size(), 'The opportunity should not have any Section 125 setup forms.');
    }
    
    private static void assertOpportunityHasSection125SetupForm(Id opportunityId) {
        List<Section_125_Setup_Form__c> oppS125s = getSection125SetupFormByOppId(opportunityId);
        
        system.assertEquals(1, oppS125s.size(), 'The opportunity should have one Section 125 setup form.');
    }

    private static void assertDefaultCustomerSetupFormAddingGroupHIIsNo() {
        loadDefaultCustomerSetupForm();

        system.assertEquals('No', DefaultCustomerSetupForm.GrpHospitalIndemnity__c, 'The Adding Group HI should be No.');
    }

    private static void assertDefaultCustomerSetupFormAddingGroupHIIsYes() {
        loadDefaultCustomerSetupForm();

        system.assertEquals('Yes', DefaultCustomerSetupForm.GrpHospitalIndemnity__c, 'The Adding Group HI should be Yes.');
    }
    
    private static List<Customer_Setup_Form__c> getCustomerSetupFormByOppId(Id opportunityId) {
        return
        [SELECT Id,
                Name,
                Enrollment_Form__c
           FROM Customer_Setup_Form__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :opportunityId];
    }

    private static List<Section_125_Setup_Form__c> getSection125SetupFormByOppId(Id opportunityId) {
        return
        [SELECT Id,
                Name,
                Enrollment_Form__c
           FROM Section_125_Setup_Form__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :opportunityId];
    }
    
    private static Opportunity getOpportunityById(Id opportunityId) {
        return
        [SELECT Id,
                Name,
                AccountId,
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
                Branch_Office__c
           FROM Opportunity
          WHERE Id = :opportunityId];
    }
    
    @isTest
    static void determineFormsToCreate_newGroupMarketedProductOnExisingOpportunity_expectCustomerSetupFormCreatedTest() {
        loadDefaults();
        
        DefaultOpportunity.Are_you_adding_new_plans_or_services__c = 'No Changes';
        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        
        update DefaultOpportunity;
        
        assertOpportunityHasNoCustomerSetupForm(DefaultOpportunity.Id);
        
        Product_Catalog__c importProduct = ProductCatalogTestData.Instance.withType('Import').withChassis('Group').insertProductCatalog();
        Marketed_Product__c newGroupMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(importProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                  .withPlanStatus('New')
                  .insertMarketedProduct();
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);
    }
    
    @isTest
    static void determineFormsToCreate_newFixedAnnuityMarketedProductOnExisingOpportunity_expectCustomerSetupFormCreatedTest() {
        loadDefaults();
        
        DefaultOpportunity.Are_you_adding_new_plans_or_services__c = 'No Changes';
        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        
        update DefaultOpportunity;
        
        assertOpportunityHasNoCustomerSetupForm(DefaultOpportunity.Id);
        
        Product_Catalog__c fixedAnnuityProduct = ProductCatalogTestData.Instance.withType('Import')
                  .withProductFamily('Fixed Annuity')
                  .insertProductCatalog();

        Marketed_Product__c newFixedAnnuityMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(fixedAnnuityProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                  .withPlanStatus('New')
                  .insertMarketedProduct();
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);
    }
    
    @isTest
    static void determineFormsToCreate_newVariableAnnuityMarketedProductOnExisingOpportunity_expectCustomerSetupFormCreatedTest() {
        loadDefaults();
        
        DefaultOpportunity.Are_you_adding_new_plans_or_services__c = 'No Changes';
        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        
        update DefaultOpportunity;
        
        assertOpportunityHasNoCustomerSetupForm(DefaultOpportunity.Id);
        
        Product_Catalog__c variableAnnuityProduct = ProductCatalogTestData.Instance.withType('Import')
                  .withProductFamily('Variable Annuity')
                  .insertProductCatalog();

        Marketed_Product__c newVariableAnnuityMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(variableAnnuityProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                  .withPlanStatus('New')
                  .insertMarketedProduct();
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);
    }
    
    @isTest
    static void determineFormsToCreate_newVariableAndFixedAnnuityMarketedProductsOnExisingOpportunity_expectOneCustomerSetupFormCreatedTest() {
        loadDefaults();
        
        DefaultOpportunity.Are_you_adding_new_plans_or_services__c = 'No Changes';
        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        
        update DefaultOpportunity;
        
        assertOpportunityHasNoCustomerSetupForm(DefaultOpportunity.Id);
        
        Product_Catalog__c variableAnnuityProduct = ProductCatalogTestData.Instance.withType('Import')
                  .withProductFamily('Variable Annuity')
                  .insertProductCatalog();
                  
        Product_Catalog__c fixedAnnuityProduct = ProductCatalogTestData.Instance.withType('Import')
                  .withProductFamily('Fixed Annuity')
                  .insertProductCatalog();

        Marketed_Product__c newVariableAnnuityMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(variableAnnuityProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                  .withPlanStatus('New')
                  .create();
        
        Marketed_Product__c newFixedAnnuityMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(fixedAnnuityProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                  .withPlanStatus('New')
                  .create();
                  
        insert new List<Marketed_Product__c>{ newVariableAnnuityMarketedProduct, newFixedAnnuityMarketedProduct };
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);
    }
    
    @isTest
    static void determineFormsToCreate_newVariableAnnuityMarketedProductInsertedAndThenFixedAnnuityMarketedProductInsertedOnExisingOpportunity_expectOneCustomerSetupFormCreatedTest() {
        loadDefaults();
        
        DefaultOpportunity.Are_you_adding_new_plans_or_services__c = 'No Changes';
        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        
        update DefaultOpportunity;
        
        assertOpportunityHasNoCustomerSetupForm(DefaultOpportunity.Id);
        
        Product_Catalog__c variableAnnuityProduct = ProductCatalogTestData.Instance.withType('Import')
                  .withProductFamily('Variable Annuity')
                  .insertProductCatalog();
                  
        Product_Catalog__c fixedAnnuityProduct = ProductCatalogTestData.Instance.withType('Import')
                  .withProductFamily('Fixed Annuity')
                  .insertProductCatalog();

        Marketed_Product__c newVariableAnnuityMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(variableAnnuityProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                  .withPlanStatus('New')
                  .insertMarketedProduct();
                  
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);
        
        Marketed_Product__c newFixedAnnuityMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(fixedAnnuityProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                  .withPlanStatus('New')
                  .insertMarketedProduct();
                  
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);
    }

    @isTest
    static void SetGroupHIAddingFromMarketedProductsAfterInsert_existingGroupHIMarketedProductAdded_expectGroupHIAddedIsNoOnCustomerSetupFormTest() {
        loadDefaultsWithCustomerSetupForm();
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);

        Product_Catalog__c groupHI = ProductCatalogTestData.Instance.withName(SetupFormManagement.GROUP_HI_PRODUCT_NAME)
                                                                    .insertProductCatalog();

        Marketed_Product__c existingGroupHIMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(groupHI.Id)
                                                                                             .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                                             .withPlanStatus('Existing')
                                                                                             .insertMarketedProduct();

        assertDefaultCustomerSetupFormAddingGroupHIIsNo();
    }

    @isTest
    static void SetGroupHIAddingFromMarketedProductsAfterInsert_newGroupHIMarketedProductAdded_expectGroupHIAddedIsYesOnCustomerSetupFormTest() {
        loadDefaultsWithCustomerSetupForm();
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);

        Product_Catalog__c groupHI = ProductCatalogTestData.Instance.withName(SetupFormManagement.GROUP_HI_PRODUCT_NAME)
                                                                    .insertProductCatalog();

        Marketed_Product__c newGroupHIMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(groupHI.Id)
                                                                                             .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                                             .withPlanStatus('New')
                                                                                             .insertMarketedProduct();

        assertDefaultCustomerSetupFormAddingGroupHIIsYes();
    }

    @isTest
    static void SetGroupHIAddingFromMarketedProductsAfterUpdate_newGroupHIMarketedProductUpdatedToExisting_expectGroupHIAddedIsNoOnCustomerSetupFormTest() {
        loadDefaultsWithCustomerSetupForm();
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);

        Product_Catalog__c groupHI = ProductCatalogTestData.Instance.withName(SetupFormManagement.GROUP_HI_PRODUCT_NAME)
                                                                    .insertProductCatalog();

        Marketed_Product__c newGroupHIMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(groupHI.Id)
                                                                                             .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                                             .withPlanStatus('New')
                                                                                             .insertMarketedProduct();

        assertDefaultCustomerSetupFormAddingGroupHIIsYes();
        
        // Have to reinstantiate the Marketed Product, because the name was set to Group HI in the background,
        // so the trigger will fire.
        newGroupHIMarketedProduct = new Marketed_Product__c(Id = newGroupHIMarketedProduct.Id);
        newGroupHIMarketedProduct.Plan_Status__c = 'Existing';
        update newGroupHIMarketedProduct;
        
        assertDefaultCustomerSetupFormAddingGroupHIIsNo();
    }

    @isTest
    static void SetGroupHIAddingFromMarketedProductsAfterUpdate_existingGroupHIMarketedProductUpdatedToNew_expectGroupHIAddedIsYesOnCustomerSetupFormTest() {
        loadDefaultsWithCustomerSetupForm();
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);

        Product_Catalog__c groupHI = ProductCatalogTestData.Instance.withName(SetupFormManagement.GROUP_HI_PRODUCT_NAME)
                                                                    .insertProductCatalog();

        Marketed_Product__c existingGroupHIMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(groupHI.Id)
                                                                                             .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                                             .withPlanStatus('Existing')
                                                                                             .insertMarketedProduct();

        assertDefaultCustomerSetupFormAddingGroupHIIsNo();
        
        // Have to reinstantiate the Marketed Product, because the name was set to Group HI in the background,
        // so the trigger will fire.
        existingGroupHIMarketedProduct = new Marketed_Product__c(Id = existingGroupHIMarketedProduct.Id);
        existingGroupHIMarketedProduct.Plan_Status__c = 'New';
        update existingGroupHIMarketedProduct;
        
        assertDefaultCustomerSetupFormAddingGroupHIIsYes();
    }

    @isTest
    static void SetGroupHIAddingFromMarketedProductsAfterDelete_existingGroupHIMarketedProductDeleted_expectGroupHIAddedIsNoOnCustomerSetupFormTest() {
        loadDefaultsWithCustomerSetupForm();
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);

        Product_Catalog__c groupHI = ProductCatalogTestData.Instance.withName(SetupFormManagement.GROUP_HI_PRODUCT_NAME)
                                                                    .insertProductCatalog();

        Marketed_Product__c existingGroupHIMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(groupHI.Id)
                                                                                             .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                                             .withPlanStatus('Existing')
                                                                                             .insertMarketedProduct();

        assertDefaultCustomerSetupFormAddingGroupHIIsNo();
        
        delete existingGroupHIMarketedProduct;
        
        assertDefaultCustomerSetupFormAddingGroupHIIsNo();
    }

    @isTest
    static void SetGroupHIAddingFromMarketedProductsAfterDelete_newGroupHIMarketedProductDeleted_expectGroupHIAddedIsNoOnCustomerSetupFormTest() {
        loadDefaultsWithCustomerSetupForm();
        
        assertOpportunityHasCustomerSetupForm(DefaultOpportunity.Id);

        Product_Catalog__c groupHI = ProductCatalogTestData.Instance.withName(SetupFormManagement.GROUP_HI_PRODUCT_NAME)
                                                                    .insertProductCatalog();

        Marketed_Product__c newGroupHIMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(groupHI.Id)
                                                                                             .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                                             .withPlanStatus('New')
                                                                                             .insertMarketedProduct();

        assertDefaultCustomerSetupFormAddingGroupHIIsYes();
        
        delete newGroupHIMarketedProduct;
        
        assertDefaultCustomerSetupFormAddingGroupHIIsNo();
    }

    @isTest
    static void determineFormsToCreate_ReserviceSection125Checked(){
        loadDefaults();

        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        DefaultOpportunity.Add_a_Section_125_Plan__c = true;

        update DefaultOpportunity;
        assertOpportunityHasSection125SetupForm(DefaultOpportunity.Id);

        DefaultOpportunity.Add_a_Section_125_Plan__c = false;

        update DefaultOpportunity;
        assertOpportunityHasNoSection125SetupForm(DefaultOpportunity.Id);
    }

    @isTest
    static void determineFormsToCreate_ReserviceFSAChecked(){
        loadDefaults();

        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        DefaultOpportunity.Add_a_FSA__c = true;

        update DefaultOpportunity;
        assertOpportunityHasSection125SetupForm(DefaultOpportunity.Id);

        DefaultOpportunity.Add_a_FSA__c = false;

        update DefaultOpportunity;
        assertOpportunityHasNoSection125SetupForm(DefaultOpportunity.Id);
    }

    @isTest
    static void determineFormsToCreate_ReserviceHSAChecked(){
        loadDefaults();

        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        DefaultOpportunity.Add_a_HSA__c = true;

        update DefaultOpportunity;
        assertOpportunityHasSection125SetupForm(DefaultOpportunity.Id);

        DefaultOpportunity.Add_a_HSA__c = false;

        update DefaultOpportunity;
        assertOpportunityHasNoSection125SetupForm(DefaultOpportunity.Id);
    }

    @isTest
    static void determineFormsToCreate_ReserviceHRAChecked(){
        loadDefaults();

        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        DefaultOpportunity.Add_a_HRA__c = true;

        update DefaultOpportunity;
        assertOpportunityHasSection125SetupForm(DefaultOpportunity.Id);

        DefaultOpportunity.Add_a_HRA__c = false;

        update DefaultOpportunity;
        assertOpportunityHasNoSection125SetupForm(DefaultOpportunity.Id);
    }
}