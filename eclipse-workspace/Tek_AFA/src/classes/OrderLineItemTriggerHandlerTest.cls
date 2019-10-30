@isTest
public with sharing class OrderLineItemTriggerHandlerTest {
    private static Opportunity DefaultEnrollmentOpportunity { get; set; }
    private static Enrollment_Form__c DefaultEnrollmentForm { get; set; }
    private static Pre_Enrollment_Marketing_Form__c DefaultPreenrollmentMarketingForm { get; set; }
    private static Marketing_Material__c DefaultMarketingMaterial { get; set; }
    private static Account DefaultAccount { get; set; }

    @testSetup
    static void setup() {
        OpportunityTestData.Instance.insertAFESOpportunity();
        MarketingMaterialTestData.Instance.withCustomizationType('someNonExistentFieldSet').insertMarketingMaterial();
    }

    @isTest
    static void orderItemLineInsert_noPreenrollmentMarketingFormSet_expectNoErrorsTest() {
        String errorMsg = '';

        try {
            OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(null).insertOrderLineItem();
        }
        catch(Exception ex) {
            errorMsg = ex.getMessage();
        }

        system.assertEquals('', errorMsg, 'No error should have occurred.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndPlanDateExistsOnOpportunityAndPlanDateIsBlankCustomField_expectPlanDatePopulatedTest() {
        loadDefaults();
        
        Date planDate = Date.Today();
        DefaultEnrollmentOpportunity.Plan_Date_New__c = planDate;
        update DefaultEnrollmentOpportunity;

        DefaultAccount.Plan_Date__c = planDate;
        update DefaultAccount;

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Plan_Date__c');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withPlanDate(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(planDate, preenrollmentOLIQueried.Plan_Date__c, 'The plan date was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndAccountExistsOnOpportunityAndAccountIsBlankCustomField_expectAccountPopulatedTest() {
        loadDefaults();
        
        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Account__c');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withAccount(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(DefaultEnrollmentOpportunity.AccountId, preenrollmentOLIQueried.Account__c, 'The account was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndAccountExistsWithMarketingAccountNameAndMarketingAccountNameIsBlankCustomField_expectMarketingAccountNamePopulatedTest() {
        loadDefaults();
        
        DefaultAccount.Marketing_Account_Name__c = 'Some Marketing Name';
        update DefaultAccount;
        
        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Marketing_Account_Name__c');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withMarketingAccountName(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(DefaultAccount.Marketing_Account_Name__c, preenrollmentOLIQueried.Marketing_Account_Name__c, 'The marketing account name was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndEnrollmentHasSection125MarketedProductAndSection125IsBlankCustomField_expectSection125PopulatedWithYesTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Section_125__c');

        insertMarketedProduct('Section 125');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withSection125(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals('Yes', preenrollmentOLIQueried.Section_125__c, 'The section 125 was not prepopulated with "Yes".');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndEnrollmentHasFSAMarketedProductAndFlexIsBlankCustomField_expectFlexPopulatedWithYesTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Flex__c');

        insertMarketedProduct('Health FSA');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withFlex(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals('Yes', preenrollmentOLIQueried.Flex__c, 'The Flex was not prepopulated with "Yes".');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndPreEnrollmentHasBranchOfficeAndSalesOfficeIsBlankCustomField_expectSalesOfficePopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Sales_Office__c');
        Branch_Office__c salesOffice = SalesOfficeTestData.Instance.insertSalesOffice();
        DefaultPreenrollmentMarketingForm.Branch_Office__c = salesOffice.Id;
        update DefaultPreenrollmentMarketingForm;

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withSalesOffice(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(salesOffice.Id, preenrollmentOLIQueried.Sales_Office__c, 'The sales office was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndPreEnrollmentHasLicenseNumberAndColleagueLicenseIsBlankCustomField_expectColleagueLicensePopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Colleague_License__c');
        DefaultPreenrollmentMarketingForm.License_No__c = 'Some License';
        update DefaultPreenrollmentMarketingForm;

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withColleagueLicense(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(DefaultPreenrollmentMarketingForm.License_No__c, preenrollmentOLIQueried.Colleague_License__c, 'The colleague license was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndAccountManagerAssignedAndColleagueIsBlankCustomField_expectColleaguePopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Colleague__c');
        DefaultEnrollmentOpportunity.Assigned_Account_Manager__c = UserInfo.getUserId();
        update DefaultEnrollmentOpportunity;

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withColleague(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(DefaultEnrollmentOpportunity.Assigned_Account_Manager__c, preenrollmentOLIQueried.Colleague__c, 'The colleague was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithPlanDateAndPlanDateIsCustomField_expectPlanDateNotPopulatedTest() {
        loadDefaults();
        
        Date opportunityPlanDate = Date.Today();
        Date orderLineItemPlanDate = opportunityPlanDate.addDays(3);
        DefaultEnrollmentOpportunity.Plan_Date_New__c = opportunityPlanDate;
        update DefaultEnrollmentOpportunity;

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Plan_Date__c');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withPlanDate(orderLineItemPlanDate)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertNotEquals(opportunityPlanDate, orderLineItemPlanDate, 'The plan dates should be different.');
        system.assertEquals(orderLineItemPlanDate, preenrollmentOLIQueried.Plan_Date__c, 'The plan date was prepopulated with the enrollment opportunity when it should not be.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductsAndProductOption1IsBlankCustomField_expectProductOption1PopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Product_Option_1__c');
        String fsaMarketplaceProductOption = 'Flexible Spending Accounts';
        insertMarketedProduct('fsa', fsaMarketplaceProductOption);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withProductOption1(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(fsaMarketplaceProductOption, preenrollmentOLIQueried.Product_Option_1__c, 'The product option 1 was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductsAndProductOption1IsBlankAndProductOption2IsBlankCustomField_expectProductOption1AndProductOption2PopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Product_Option_1__c');
        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Product_Option_2__c');
        String fsaMarketplaceProductOption = 'Flexible Spending Accounts';
        insertMarketedProduct('fsa', fsaMarketplaceProductOption);
        
        String hospitalGapProductOption = 'Hospital GAP Insurance';
        insertMarketedProduct('Hospital GAP', hospitalGapProductOption, 2);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withProductOption1(null)
                                                                            .withProductOption2(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(fsaMarketplaceProductOption, preenrollmentOLIQueried.Product_Option_1__c, 'The product option 1 was not prepopulated.');
        system.assertEquals(hospitalGapProductOption, preenrollmentOLIQueried.Product_Option_2__c, 'The product option 2 was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductsAndGroupProductOption1IsBlankCustomField_expectGroupProductOption1PopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Group_Product_Option_1__c');
        String fsaMarketplaceProductOption = 'Flexible Spending Accounts';
        insertMarketedProduct('fsa', fsaMarketplaceProductOption);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withGroupProductOption1(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(fsaMarketplaceProductOption, preenrollmentOLIQueried.Group_Product_Option_1__c, 'The group product option 1 was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductsAndGroupProductOption1IsBlankAndGroupProductOption2IsBlankCustomField_expectGroupProductOption1AndGroupProductOption2PopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Group_Product_Option_1__c');
        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Group_Product_Option_2__c');
        String fsaMarketplaceProductOption = 'Flexible Spending Accounts';
        insertMarketedProduct('fsa', fsaMarketplaceProductOption);
        
        String hospitalGapProductOption = 'Hospital GAP Insurance';
        insertMarketedProduct('Hospital GAP', hospitalGapProductOption, 2);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withGroupProductOption1(null)
                                                                            .withGroupProductOption2(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(fsaMarketplaceProductOption, preenrollmentOLIQueried.Group_Product_Option_1__c, 'The group product option 1 was not prepopulated.');
        system.assertEquals(hospitalGapProductOption, preenrollmentOLIQueried.Group_Product_Option_2__c, 'The group product option 2 was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductsAndComboProductOption1IsBlankCustomField_expectComboProductOption1PopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Combo_Product_Option_1__c');
        String fsaMarketplaceProductOption = 'Flexible Spending Accounts';
        insertMarketedProduct('fsa', fsaMarketplaceProductOption);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withComboProductOption1(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(fsaMarketplaceProductOption, preenrollmentOLIQueried.Combo_Product_Option_1__c, 'The combo product option 1 was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductsAndComboProductOption1IsBlankAndComboProductOption2IsBlankCustomField_expectComboProductOption1AndProductOption2PopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Combo_Product_Option_1__c');
        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Combo_Product_Option_2__c');
        String fsaMarketplaceProductOption = 'Flexible Spending Accounts';
        insertMarketedProduct('fsa', fsaMarketplaceProductOption);
        
        String hospitalGapProductOption = 'Hospital GAP Insurance';
        insertMarketedProduct('Hospital GAP', hospitalGapProductOption, 2);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withComboProductOption1(null)
                                                                            .withComboProductOption2(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(fsaMarketplaceProductOption, preenrollmentOLIQueried.Combo_Product_Option_1__c, 'The combo product option 1 was not prepopulated.');
        system.assertEquals(hospitalGapProductOption, preenrollmentOLIQueried.Combo_Product_Option_2__c, 'The combo product option 2 was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWith2CancerMarketedProductsAndComboProductOption1IsBlankAndComboProductOption2IsBlankCustomField_expectComboProductOption1PopulatedAndComboProductOption2NotPopulatedTest() {
        // Confirm that if multiple marketed products will use same marketplace product option,
        // the option is only used once to avoid duplicate products from being selected.
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Combo_Product_Option_1__c');
        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Combo_Product_Option_2__c');
        String cancerMarketplaceProductOption = 'Flexible Spending Accounts';
        insertMarketedProduct('Cancer C-11', cancerMarketplaceProductOption);
        insertMarketedProduct('Cancer C-12', cancerMarketplaceProductOption, 2);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withComboProductOption1(null)
                                                                            .withComboProductOption2(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(cancerMarketplaceProductOption, preenrollmentOLIQueried.Combo_Product_Option_1__c, 'The combo product option 1 was not prepopulated.');
        system.assertEquals(null, preenrollmentOLIQueried.Combo_Product_Option_2__c, 'The combo product option 2 was prepopulated when it should not be.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithCancerRiderMarketedProductsAndComboProductOption1IsBlankCustomField_expectComboProductOption1NotPopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Combo_Product_Option_1__c');
        String cancerMarketplaceProductOption = 'Cancer';

        Product_Catalog__c cancerRiderPC = ProductCatalogTestData.Instance.withName('Cancer')
                                                               .withMarketplaceProductOption(cancerMarketplaceProductOption)
                                                               .withRider(true)
                                                               .insertProductCatalog();
                                                               
        Marketed_Product__c mp = MarketedProductTestData.Instance.withProductCatalog(cancerRiderPC.Id)
                                                                 .withEnrollmentForm(DefaultEnrollmentForm.Id)
                                                                 .insertMarketedProduct();


        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withComboProductOption1(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(null, preenrollmentOLIQueried.Combo_Product_Option_1__c, 'The combo product option 2 was prepopulated when it should not be.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndEnrollmentStartDateExistsOnOpportunityAndEnrollmentStartDateIsBlankCustomField_expectEnrollmentStartDatePopulatedTest() {
        loadDefaults();
        
        Date enrollmentStartDate = Date.Today();
        DefaultEnrollmentOpportunity.Enrollment_Start_Date__c = enrollmentStartDate;
        update DefaultEnrollmentOpportunity;

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Enrollment_Start_Date__c');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withEnrollmentStartDate(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(enrollmentStartDate, preenrollmentOLIQueried.Enrollment_Start_Date__c, 'The enrollment start date was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndEnrollmentStartDateExistsOnOpportunityAndEnrollmentStartDateIsNotBlankCustomField_expectEnrollmentStartDateNotPopulatedTest() {
        loadDefaults();
        
        Date opportunityEnrollmentStartDate = Date.Today();
        Date orderLineItemEnrollmentstartDate = opportunityEnrollmentStartDate.addDays(10);
        DefaultEnrollmentOpportunity.Enrollment_Start_Date__c = opportunityEnrollmentStartDate;
        update DefaultEnrollmentOpportunity;

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Enrollment_Start_Date__c');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withEnrollmentStartDate(orderLineItemEnrollmentstartDate)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(orderLineItemEnrollmentstartDate, preenrollmentOLIQueried.Enrollment_Start_Date__c, 'The enrollment start date was prepopulated when it should not be.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndEnrollmentEndDateExistsOnOpportunityAndEnrollmentEndDateIsBlankCustomField_expectEnrollmentEndDatePopulatedTest() {
        loadDefaults();
        
        Date enrollmentEndDate = Date.Today();
        DefaultEnrollmentOpportunity.Enrollment_End_Date__c = enrollmentEndDate;
        update DefaultEnrollmentOpportunity;

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Enrollment_End_Date__c');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withEnrollmentEndDate(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(enrollmentEndDate, preenrollmentOLIQueried.Enrollment_End_Date__c, 'The enrollment end date was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedAndEnrollmentEndDateExistsOnOpportunityAndEnrollmentEndDateIsNotBlankCustomField_expectEnrollmentEndDateNotPopulatedTest() {
        loadDefaults();

        Date opportunityEnrollmentEndDate = Date.Today();
        Date orderLineItemEnrollmentEndDate = opportunityEnrollmentEndDate.addDays(10);
        DefaultEnrollmentOpportunity.Enrollment_End_Date__c = opportunityEnrollmentEndDate;
        update DefaultEnrollmentOpportunity;

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Enrollment_End_Date__c');

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withEnrollmentEndDate(orderLineItemEnrollmentEndDate)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(orderLineItemEnrollmentEndDate, preenrollmentOLIQueried.Enrollment_End_Date__c, 'The enrollment end date was prepopulated when it should not be.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductAndProductsIsBlankCustomField_expectProductsPopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Products__c');
        String marketplaceProductOption = 'Long-Term Disability';
        insertMarketedProduct('Long-Term Disability', marketplaceProductOption);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withProducts(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(marketplaceProductOption, preenrollmentOLIQueried.Products__c, 'The products (products__c) was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductAndProductsIsNotBlankCustomField_expectProductsPopulatedTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Products__c');
        String marketplaceProductOption = 'Long-Term Disability';
        String userProvidedPreenrollmentProducts = 'Accident Only Insurance';
        insertMarketedProduct('Long-Term Disability', marketplaceProductOption);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withProducts(userProvidedPreenrollmentProducts)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(userProvidedPreenrollmentProducts, preenrollmentOLIQueried.Products__c, 'The products (products__c) was overridden by the trigger.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductAndPreenrollmentProductsIsBlankCustomField_expectProductsNotOverriddenTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Pre_enrollment_Products__c');
        String marketplaceProductOption = 'Long-Term Disability';
        insertMarketedProduct('Long-Term Disability', marketplaceProductOption);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withPreenrollmentProducts(null)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(marketplaceProductOption, preenrollmentOLIQueried.Pre_enrollment_Products__c, 'The preenrollment products was not prepopulated.');
    }

    @isTest
    static void prepopulatePreenrollmentCustomFields_preenrollmentOrderLineInsertedWithMarketedProductAndPreenrollmentProductsIsNotBlankCustomField_expectPreenrollmentProductsNotOverriddenTest() {
        loadDefaults();

        OrderLineItemTriggerHandler.preenrollmentTestCustomFields.add('Pre_enrollment_Products__c');
        String userProvidedPreenrollmentProducts = 'Accident Only Insurance';
        String marketplaceProductOption = 'Long-Term Disability';

        insertMarketedProduct('Long-Term Disability', marketplaceProductOption);

        Order_Line_Item__c preenrollmentOLI = OrderLineItemTestData.Instance.withPreenrollmentMarketingForm(DefaultPreenrollmentMarketingForm.Id)
                                                                            .withMarketingMaterial(DefaultMarketingMaterial.Id)
                                                                            .withPreenrollmentProducts(userProvidedPreenrollmentProducts)
                                                                            .insertOrderLineItem();

        Order_Line_Item__c preenrollmentOLIQueried = getOrderLineItemById(preenrollmentOLI.Id);

        system.assertEquals(userProvidedPreenrollmentProducts, preenrollmentOLIQueried.Pre_enrollment_Products__c, 'The preenrollment products was overridden when it should have kept the user provided value.');
    }

    static void loadDefaults() {
        DefaultPreenrollmentMarketingForm =
        [SELECT Id,
                Name,
                Enrollment_Form__c,
                Enrollment_Form__r.Id,
                Enrollment_Form__r.Enrollment_Opportunity__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Id,
                Enrollment_Form__r.Enrollment_Opportunity__r.OwnerId,
                Enrollment_Form__r.Enrollment_Opportunity__r.AccountId,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.Id,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.Marketing_Account_Name__c
           FROM Pre_Enrollment_Marketing_Form__c];

        DefaultEnrollmentForm = DefaultPreenrollmentMarketingForm.Enrollment_Form__r;
        DefaultEnrollmentOpportunity = DefaultEnrollmentForm.Enrollment_Opportunity__r;
        DefaultAccount = DefaultEnrollmentForm.Enrollment_Opportunity__r.Account;
        
        DefaultMarketingMaterial =
        [SELECT Id,
                Name
           FROM Marketing_Material__c];
    }

    static Order_Line_Item__c getOrderLineItemById(Id orderLineItemId) {
        return
        [SELECT Id,
                Name,
                Plan_Date__c,
                Account__c,
                Marketing_Account_Name__c,
                Section_125__c,
                Flex__c,
                Sales_Office__c,
                Colleague_License__c,
                Colleague__c,
                Product_Option_1__c,
                Product_Option_2__c,
                Group_Product_Option_1__c,
                Group_Product_Option_2__c,
                Combo_Product_Option_1__c,
                Combo_Product_Option_2__c,
                Enrollment_Start_Date__c,
                Enrollment_End_Date__c,
                Products__c,
                Pre_enrollment_Products__c
           FROM Order_Line_Item__c
          WHERE Id = :orderLineItemId];
    }

    static void insertMarketedProduct(String marketedProductName) {
        insertMarketedProduct(marketedProductName, null);
    }

    static void insertMarketedProduct(String marketedProductName, String marketplaceProductOption) {
        insertMarketedProduct(marketedProductName, marketplaceProductOption, null);
    }

    static void insertMarketedProduct(String marketedProductName, String marketplaceProductOption, Integer productCatalogOrder) {
        Product_Catalog__c pc = ProductCatalogTestData.Instance.withName(marketedProductName)
                                                               .withMarketplaceProductOption(marketplaceProductOption)
                                                               .withOrder(productCatalogOrder)
                                                               .insertProductCatalog();
        Marketed_Product__c mp = MarketedProductTestData.Instance.withProductCatalog(pc.Id)
                                                                 .withEnrollmentForm(DefaultEnrollmentForm.Id)
                                                                 .insertMarketedProduct();
    }
}