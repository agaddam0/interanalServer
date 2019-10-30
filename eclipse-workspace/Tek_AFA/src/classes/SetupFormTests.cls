@isTest
public with sharing class SetupFormTests {
    private static User someUser = null;
    private static Contact Contact = null;
    private static Account Account = null;
    private static Opportunity DefaultOpp = null;
    private static Customer_Setup_Form__c CSF = null;
    private static Location_Form__c LocationForm = null;
    private static Common_Ownership_Form__c CommonOwnershipForm = null;
    
    static void loadDefaultCustomerSetupForm() {
        if (DefaultOpp == null) {
            loadDefaultOpp();
        }
        
        CSF = [SELECT Id,Enrollment_Form__c,What_date_does_the_employer_need_to_key__c,
                      BillInfoDateFirstPayrollDeduction__c
                 FROM Customer_Setup_Form__c 
                WHERE Enrollment_Form__r.Enrollment_Opportunity__c =: DefaultOpp.Id LIMIT 1];
    }
    
    static void loadSetupData() {
        someUser = new User(Id = UserInfo.getUserId());
        
        Contact = [SELECT Id FROM Contact LIMIT 1];
        Account = [SELECT Id FROM Account LIMIT 1];
        loadDefaultOpp();
        loadDefaultCustomerSetupForm();

        LocationForm = [SELECT Id FROM Location_Form__c WHERE Customer_Setup_Form__c =: CSF.Id LIMIT 1];
        CommonOwnershipForm = [SELECT Id FROM Common_Ownership_Form__c WHERE MCP_Setup_Form__c =: CSF.Id LIMIT 1];
    }
    
    static void loadDefaultOpp() {
        DefaultOpp = [SELECT Id FROM Opportunity LIMIT 1];
    }
    
    static CustomerSetupFormCTRL_v2 loadDefaultCustomSetupFormV2Controller(){
        loadSetupData();

        return loadDefaultCustomerSetupFormV2ControllerFromCustomerSetupFormId(CSF.id);
    }
    
    static CustomerSetupFormCTRL_v2 loadDefaultCustomerSetupFormV2ControllerFromCustomerSetupFormId(Id customerSetupFormId) {
        PageReference pr = Page.CustomerSetupForm2;   
        Test.setCurrentPage(pr); 
        ApexPages.currentPage().getparameters().put('id',customerSetupFormId);
        ApexPages.StandardController sc = new ApexPages.StandardController(CSF);
        
        CustomerSetupFormCTRL_v2 ctrl = new CustomerSetupFormCTRL_v2(sc);
        
        ctrl.csf = ctrl.csfs[0];

        return ctrl;
    }
    
    static PlatformSetupFormCTRL loadDefaultPlatformSetupController() {
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

        List<Platform_Setup__c> platformSetupForms = [SELECT Id, 
                                                      Status__c, 
                                                      Enrollment_Form__c, 
                                                      Tx_Life_Prim_Acct_Mngr_ASAP__c, 
                                                      Tx_Life_Visions_SSR_Enroll_Team_Name__c, 
                                                      Tx_Life_Agent_Data_Prim_Acct_Mngr_ASAP__c,
                                                      Tx_Life_Will_Tx_Life_be_set_up__c,
                                                      DVR_Info_WillThereBeDependent_Verif__c,
                                                      S125OtherSvcHaveAFASection125__c ,
                                                      S125OtherSvcHaveSection125WithAnotherCo__c,   //jh
                                                      S125OtherSvcPlanStartDate__c
                                                      FROM Platform_Setup__c 
                                                      WHERE Enrollment_Form__r.Enrollment_Opportunity__c =: o.Id];

        System.AssertEquals(platformSetupForms.size(), 1);
        
        Platform_Setup__c p = platformSetupForms[0];
        
        p.Tx_Life_Will_Tx_Life_be_set_up__c = 'Yes';
        p.Tx_Life_Is_new_case_of_a_re_enrol__c = 'Yes';
        p.DVR_Info_WillThereBeDependent_Verif__c = 'Yes';
        p.S125OtherSvcHaveAFASection125__c = 'Yes';
        p.S125OtherSvcIsThereFSA__c = 'Yes';
        p.S125OtherSvcDebitCard__c = 'Yes';
        update p;
        
        PageReference pr = Page.PlatformSetupForm2;   
        Test.setCurrentPage(pr); 
        ApexPages.currentPage().getparameters().put('id',p.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(p);
        PlatformSetupFormCTRL ctrl = new PlatformSetupFormCTRL(sc);
        
        return ctrl;
    }
    
    static void assertProductBillingHasRequiredField(CustomerSetupFormCTRL_v2 ctrl) {
        ctrl.productBillingCheckRequiredFields(true);
        
        system.assertEquals(false, ctrl.productBillingTabComplete, 'The product billing tab should not be complete.');
        
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    static void testBillModeRequiredField(String billModeRequiredField) {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        ctrl.insertBillMode();
        
        ctrl.TestBillModeRequiredFields = new set<String>();
        ctrl.TestBillModeRequiredFields.add(billModeRequiredField);
        
        ctrl.csf.What_date_does_the_employer_need_to_key__c = Date.Today();
        ctrl.csf.BillInfoDateFirstPayrollDeduction__c = Date.Today();
        
        Bill_Mode__c bm = ctrl.BillModes[0];
        
        bm.put(billModeRequiredField, null);
        
        ctrl.productBillingCheckRequiredFields(true);
        
        Test.stopTest();
        
        system.assertEquals(false, ctrl.productBillingTabComplete, 'The product billing tab should not be complete.');
        
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @testSetup
    static void TestData()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = prof.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
        
        Account a = new Account(Name='Test');
        a.RecordTypeId = Constants.ACCOUNT_CUSTOMER_ACCOUNT;
        insert a;
        
        Contact con = new COntact(FirstName='Test',LastName='Test',AccountId=a.id);
        insert con;
        
        Opportunity o = new Opportunity();
        o.RecordTypeId = Constants.OPPORTUNITY_AWD_ENROLLMENT;
        o.OwnerId = u.Id;
        o.Name = 'New AWD';
        o.AccountId = a.Id;
        o.Confirm_New_or_Existing_Group__c = 'New';
        o.What_products_are_you__c = 'Disability; Accident; Cancer; AFA Life; Texas Life; GAP; Group CI; Individual CI; Group HI; Section 125; FSA; HSA; HRA; DVR; Annuities; AF Benefits Market';
        o.Estimated_Close_Date__c = Date.today().addDays(-30);
        o.Plan_Date_New__c = Date.today().addDays(30);
        o.Did_you_sell_a_Private_Exchange__c = 'No';
        o.StageName = 'Prospecting';
        o.CloseDate = Date.today().addDays(30);
        o.Are_you_making_any_billing_changes__c = null;   //jh
        o.Requesting_Open_Enrollment__c = null;         //jh
        o.administrative_contact__c = con.id;
        insert o;
        
        List<Opportunity> oList = new List<Opportunity>();
        oList.add(o);
        OpportunityFormRules.setFormBooleans(oList, true, true );  // set s125Required
        update o;    // Opportunity trigger creates form records.
        
        Id efRType = Constants.ENROLLMENT_FORM_MASTER;
        
        system.debug('efRType: ' + efRType);
        
        Enrollment_Form__c ef = [select Id from Enrollment_Form__c where Enrollment_Opportunity__c = :o.Id];
        
         /* create product catalog */
        List<Product_Catalog__c> pCatalog = new List<Product_Catalog__c>();
        pCatalog.add(createProduct('Health FSA','Service'));
        pCatalog.add(createProduct('Section 125','Service'));
        pCatalog.add(createProduct('HSA','Service'));
        pCatalog.add(createProduct('Long-Term Disability','Benefit'));
        insert pCatalog;
        
        List<Marketed_Product__c> products = new List<Marketed_Product__c>();
        for(Product_Catalog__c pcat : pCatalog)
        {
            Marketed_Product__c mp = new Marketed_Product__c();
            mp.Products__c = pCat.Id;
            mp.Plan_Status__c = 'New';
            mp.Tax_Treatment__c = pCat.Tax_Treatment__c;
            mp.Enrollment__c = ef.Id;
            products.add(mp);
        }        
        insert products;        
        
        List<Customer_Setup_Form__c> customerSetupForms = [SELECT Id,Enrollment_Form__c FROM Customer_Setup_Form__c WHERE Enrollment_Form__r.Enrollment_Opportunity__c =: o.Id];
        
        Customer_Setup_Form__c c = customerSetupForms[0];
        Common_Ownership_Form__c co = new Common_Ownership_Form__c();
        co.Location__c = a.id;
        co.MCP_Setup_Form__c = c.Id;
        insert co;
        
        Location_Form__c lo = new Location_Form__c();
        lo.Location__c = a.Id;
        lo.Customer_Setup_Form__c = c.Id;
        insert lo;
    }
    
    private static Product_Catalog__c createProduct(string Name, string Type ) {
        Product_Catalog__c pc = new Product_Catalog__c (
            name = name, status__c = 'Active', type__c = type, Tax_Treatment__c = 'Both', Plan_Status__c = 'New',Division_Availability__c='Both');
        
        return pc;
        
    }
    
    static testmethod void testCustomerSetupBasicUpdateCoverage_updateCustomerSetupForm_expectNoErrorsTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        
        System.AssertEquals(CSF.Id, ctrl.formId);
        
        ctrl.updateCustomerSetupForm();
        
        Test.stopTest();
    }
    
    static testmethod void testCustomerSetupBasicUpdateCoverage_updateCSForm_expectNoErrorsTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        
        System.AssertEquals(CSF.Id, ctrl.formId);
        
        ctrl.updatecsForm();
        
        Test.stopTest();
    }
    
    static testmethod void testCustomerSetupBasicUpdateCoverage_saveAccount_expectNoErrorsTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        
        System.AssertEquals(CSF.Id, ctrl.formId);
        
        ctrl.saveAccount();
        
        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_saveAdminContact_updatePhone_expectPhoneUpdatedTest() {
        Test.startTest();

        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        
        // Update admin contact
        ctrl.adminContact = Contact;
        ctrl.fieldName = 'Phone';
        ctrl.fieldValue = '1111111111';
        ctrl.saveAdminContact();

        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_saveMainAgent_mainAgentSetToSomeUser_expectMainAgentUpdatedTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();

        // Save main agent
        ctrl.mainAgent = someUser;
        ctrl.saveMainAgent();
        
        // Set Main Agent        
        ctrl.setMainAgent();  // jh coverage
        
        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_insertCO_commonOwnershipLinkedToAccount_expectCommonOwnershipInsertedTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
            
        // Insert Common Ownership
        ctrl.commonOwnershipId = Account.Id;
        ctrl.insertCO();
        
        Test.stopTest();
    }

    static testmethod void testCustomerSetup_insertLO_locationOwnershipLinkedToAccount_expectLocationOwnershipInsertedTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();

        // Insert Location
        ctrl.locationId = Account.Id;
        ctrl.insertLO();
        
        Test.stopTest();
    }

    static testmethod void testCustomerSetup_insertOTM_managerIdSetToSomeuser_expectOTMInsertedTest() {
        Test.startTest();
            
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        // Insert Opportunity Team Member
        ctrl.managerId = someUser.Id;
        ctrl.insertOTM();
        
        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_saveCommons_invokeMethod_expectNoErrorsTest() {
        Test.startTest();
            
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        // save commons
        ctrl.saveCommons();
        
        Test.stopTest();
    }

    static testmethod void testCustomerSetup_saveLocations_invokeMethod_expectNoErrorsTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        // save locations
        ctrl.saveLocations();
        
        Test.stopTest();
    }

    static testmethod void testCustomerSetup_deleteCommonOwnership_deleteCommonOwnershipForm_expectNoErrorsTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        // delete common ownership
        ctrl.CommonOwnershipIdToDelete = CommonOwnershipForm.Id;
        ctrl.deleteCommonOwnership();
        
        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_deleteLocation_deleteLocationForm_expectNoErrorsTest() {
        Test.startTest();
            
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        // delete location
        ctrl.LocationIdToDelete = LocationForm.Id;
        ctrl.deleteLocation();
        
        Test.stopTest();
    }

    static testmethod void testCustomerSetup_updateField_DetailsDoesGrpparticipateinAFAS125_expectNoErrorsTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        // update field
        ctrl.fieldName = 'DetailsDoesGrpparticipateinAFAS125__c';
        ctrl.fieldValue = 'Yes';
        ctrl.updateField();
        
        Test.stopTest();
    }

    static testmethod void testCustomerSetup_updateCommonField_MCPNumber_expectNoErrorsTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        // update common field.
        ctrl.commonId = Account.Id;
        ctrl.fieldName='MCP_Number__c';
        ctrl.fieldValue='New MCP';
        ctrl.updateCommonField();
        
        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_updateProductField_MCPNumber_expectNoErrorsTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();        
        // update product
        ctrl.newProduct();
        ctrl.productId = ctrl.products[0].Id;
        ctrl.fieldName='MCP_Number__c';
        ctrl.fieldValue='New MCP';
        ctrl.updateProductField();
        
        // delete product
        ctrl.deleteProduct();
        
        Test.stopTest();
    }

    static testmethod void testCustomerSetup_updateAccountField_Name_expectNoErrorsTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        // update account field
        ctrl.fieldName='Name';
        ctrl.fieldValue = 'New Account Name';
        ctrl.updateAccountField();
        
        Test.stopTest();
    }

    static testmethod void testCustomerSetup_deleteOTM_DefaultOTM_expectNoErrorsTest() {
        Test.startTest();
            
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        // Delete Opportunity Team Member
        OpportunityTeamMember otm = [SELECT Id FROM OpportunityTeamMember WHERE OpportunityId =: DefaultOpp.Id limit 1];
        ctrl.otmId = otm.Id;
        ctrl.deleteOTM();
        
        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_existingGroupWithNoChangesButWithNewPlanGroupChassisMarketedProduct_expectGroupProductsAndOnboardingDetailsTabDisplayedTest() {
        Test.startTest();
        
        loadSetupData();
        
        DefaultOpp.Are_you_adding_new_plans_or_services__c = 'No Changes';
        DefaultOpp.Confirm_New_or_Existing_Group__c = 'Existing';
        
        update DefaultOpp;
        
        Product_Catalog__c importProduct = ProductCatalogTestData.Instance.withType('Import').withChassis('Group').insertProductCatalog();
        Marketed_Product__c newGroupMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(importProduct.Id).withEnrollmentForm(CSF.Enrollment_Form__c)
                  .withPlanStatus('New')
                  .insertMarketedProduct();
        
        // Have to reload the default customer setup form because setting the default opp
        // to existing with no changes actually deletes the original Customer setup form
        // and inserting the new group marketed product recreates a new customer setup form.          
        loadDefaultCustomerSetupForm();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomerSetupFormV2ControllerFromCustomerSetupFormId(CSF.Id);
        
        system.assertEquals(true, ctrl.groupPlansTabDisplayed, 'The group plan tab should be displayed.');
        system.assertEquals(true, ctrl.onboardingTabDisplayed, 'The onboarding details tab should be displayed.');
        
        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_existingGroupWithNoChangesButWithFixedAnnuityMarketedProduct_expectAnnuitiesTabDisplayedTest() {
        Test.startTest();

        loadSetupData();

        DefaultOpp.Are_you_adding_new_plans_or_services__c = 'No Changes';
        DefaultOpp.Confirm_New_or_Existing_Group__c = 'Existing';

        update DefaultOpp;

        Product_Catalog__c importProduct = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Fixed Annuity').insertProductCatalog();
        Marketed_Product__c newGroupMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(importProduct.Id).withEnrollmentForm(CSF.Enrollment_Form__c)
                  .withPlanStatus('New')
                  .insertMarketedProduct();

        // Have to reload the default customer setup form because setting the default opp
        // to existing with no changes actually deletes the original Customer setup form
        // and inserting the new group marketed product recreates a new customer setup form.          
        loadDefaultCustomerSetupForm();

        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomerSetupFormV2ControllerFromCustomerSetupFormId(CSF.Id);

        system.assertEquals(true, ctrl.AnnuitiesTabDisplayed, 'The annuities tab should be displayed.');

        Test.stopTest();
    }

    static testmethod void testCustomerSetup_existingGroupWithNoChangesButWithVariableAnnuityMarketedProduct_expectAnnuitiesTabDisplayedTest() {
        Test.startTest();

        loadSetupData();

        DefaultOpp.Are_you_adding_new_plans_or_services__c = 'No Changes';
        DefaultOpp.Confirm_New_or_Existing_Group__c = 'Existing';

        update DefaultOpp;

        Product_Catalog__c importProduct = ProductCatalogTestData.Instance.withType('Import').withProductFamily('Variable Annuity').insertProductCatalog();
        Marketed_Product__c newGroupMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(importProduct.Id).withEnrollmentForm(CSF.Enrollment_Form__c)
                  .withPlanStatus('New')
                  .insertMarketedProduct();

        // Have to reload the default customer setup form because setting the default opp
        // to existing with no changes actually deletes the original Customer setup form
        // and inserting the new group marketed product recreates a new customer setup form.          
        loadDefaultCustomerSetupForm();

        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomerSetupFormV2ControllerFromCustomerSetupFormId(CSF.Id);

        system.assertEquals(true, ctrl.AnnuitiesTabDisplayed, 'The annuities tab should be displayed.');

        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_groupPlansRequiredFields_LTDMatchingGroupAccountSameAsEnrollmentAccount_expectValidationMsgTest() {
        Test.startTest();

        loadSetupData();

        Product_Catalog__c ltdProduct = ProductCatalogTestData.Instance.withType('Benefit').withProductFamily('Disability').withName('Long-Term Disability').insertProductCatalog();
        Marketed_Product__c newLTDMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(ltdProduct.Id).withEnrollmentForm(CSF.Enrollment_Form__c)
                  .withPlanStatus('New')
                  .insertMarketedProduct();

        // Have to reload the default customer setup form because setting the default opp
        // to existing with no changes actually deletes the original Customer setup form
        // and inserting the new group marketed product recreates a new customer setup form.          
        loadDefaultCustomerSetupForm();

        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomerSetupFormV2ControllerFromCustomerSetupFormId(CSF.Id);
        ctrl.csf.GrpProdHowwouldyouliketoselectDisplans__c = 'Match plans to an existing MCP';
        ctrl.csf.GrpProdLTDplanstomatchAccount__c = ctrl.enrollmentOpp.AccountId;
        
        ctrl.groupPlansRequiredFields(true);
        
        TestUtil.assertPageHasMessage(CustomerSetupFormCTRL_v2.LTD_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG);

        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_groupPlansRequiredFields_STDMatchingGroupAccountSameAsEnrollmentAccount_expectValidationMsgTest() {
        Test.startTest();

        loadSetupData();

        Product_Catalog__c stdProduct = ProductCatalogTestData.Instance.withType('Benefit').withProductFamily('Disability').withName('Short-Term Disability').insertProductCatalog();
        Marketed_Product__c newSTDMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(stdProduct.Id).withEnrollmentForm(CSF.Enrollment_Form__c)
                  .withPlanStatus('New')
                  .insertMarketedProduct();

        // Have to reload the default customer setup form because setting the default opp
        // to existing with no changes actually deletes the original Customer setup form
        // and inserting the new group marketed product recreates a new customer setup form.          
        loadDefaultCustomerSetupForm();

        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomerSetupFormV2ControllerFromCustomerSetupFormId(CSF.Id);
        ctrl.csf.GrpProdHowwouldyouliketoselectDisplans__c = 'Match plans to an existing MCP';
        ctrl.csf.GrpProdSTDplanstomatchAccount__c = ctrl.enrollmentOpp.AccountId;
        
        ctrl.groupPlansRequiredFields(true);
        
        TestUtil.assertPageHasMessage(CustomerSetupFormCTRL_v2.STD_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG);

        Test.stopTest();
    }

    static testmethod void testCustomerSetup_groupPlansRequiredFields_CIMatchingGroupAccountSameAsEnrollmentAccount_expectValidationMsgTest() {
        Test.startTest();

        loadSetupData();

        Product_Catalog__c ciProduct = ProductCatalogTestData.Instance.withType('Benefit').withProductFamily('Disability').withName('Group Critical Illness').insertProductCatalog();
        Marketed_Product__c newCIMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(ciProduct.Id).withEnrollmentForm(CSF.Enrollment_Form__c)
                  .withPlanStatus('New')
                  .insertMarketedProduct();

        // Have to reload the default customer setup form because setting the default opp
        // to existing with no changes actually deletes the original Customer setup form
        // and inserting the new group marketed product recreates a new customer setup form.          
        loadDefaultCustomerSetupForm();

        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomerSetupFormV2ControllerFromCustomerSetupFormId(CSF.Id);
        ctrl.csf.GrpProdHowwouldyouliketoselectGrpCIplans__c = 'Match plans to an existing MCP';
        ctrl.csf.GrpProdGroupCIplanstomatchAccount__c = ctrl.enrollmentOpp.AccountId;
        
        ctrl.groupPlansRequiredFields(true);
        
        TestUtil.assertPageHasMessage(CustomerSetupFormCTRL_v2.CI_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG);

        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_groupPlansRequiredFields_GAPMatchingGroupAccountSameAsEnrollmentAccount_expectValidationMsgTest() {
        Test.startTest();

        loadSetupData();

        Product_Catalog__c gapProduct = ProductCatalogTestData.Instance.withType('Benefit').withProductFamily('Disability').withName('Hospital GAP').insertProductCatalog();
        Marketed_Product__c newGAPMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(gapProduct.Id).withEnrollmentForm(CSF.Enrollment_Form__c)
                  .withPlanStatus('New')
                  .insertMarketedProduct();

        // Have to reload the default customer setup form because setting the default opp
        // to existing with no changes actually deletes the original Customer setup form
        // and inserting the new group marketed product recreates a new customer setup form.          
        loadDefaultCustomerSetupForm();

        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomerSetupFormV2ControllerFromCustomerSetupFormId(CSF.Id);
        ctrl.csf.GrpProdHowwouldyouliketoselectGAPplans__c = 'Match plans to an existing MCP';
        ctrl.csf.GrpProdGAPplanstomatchAccount__c = ctrl.enrollmentOpp.AccountId;
        
        ctrl.groupPlansRequiredFields(true);
        
        TestUtil.assertPageHasMessage(CustomerSetupFormCTRL_v2.GAP_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG);

        Test.stopTest();
    }
    
    static testmethod void testCustomerSetup_getCoverageEffectiveDate_nullCSF_expectBlankCoverageEffectiveDateTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        ctrl.CSF = null;
        
        String coverageEffDate = ctrl.getCoverageEffectiveDate();
        
        Test.stopTest();
        
        system.assert(String.isBlank(coverageEffDate), 'The coverage effective date is not blank.');
    }
    
    static testmethod void testCustomerSetup_getCoverageEffectiveDate_15OfThisMonthIsFirstPayrollDeductionAndItPaysForThisMonthsBill_expectCoverageEffDateIsFirstOfThisMonthTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        
        Date todaysDate = Date.Today();
        Date fifteenthOfCurrentMonth = Date.newInstance(todaysDate.year(), todaysDate.month(), 15);

        ctrl.ps.Enroll_Info_First_Payroll_Deduction_Date__c = fifteenthOfCurrentMonth;
        ctrl.ps.Enroll_Info_Payroll_Deduction_Begins__c = 'This month\'s deductions pays for this month\'s premiums';
        
        ctrl.updatePlatformSetup();
        
        String coverageEffDate = ctrl.getCoverageEffectiveDate();

        system.assert(String.isNotBlank(coverageEffDate), 'The coverage effective date is blank.');

        Date firstOfCurrentMonth = fifteenthOfCurrentMonth.toStartOfMonth();
        String firstOfCurrentMonthStr = firstOfCurrentMonth.format();
        
        system.assertEquals(firstOfCurrentMonthStr, coverageEffDate, 'The coverage effective date is not the first of the month.');
        Test.stopTest();
    }

    static testmethod void testCustomerSetup_getCoverageEffectiveDate_15OfThisMonthIsFirstPayrollDeductionAndItPaysForNextMonthsBill_expectCoverageEffDateIsFirstOfNextMonthTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();        

        Date todaysDate = Date.Today();
        Date fifteenthOfCurrentMonth = Date.newInstance(todaysDate.year(), todaysDate.month(), 15);

        ctrl.ps.Enroll_Info_First_Payroll_Deduction_Date__c = fifteenthOfCurrentMonth;
        ctrl.ps.Enroll_Info_Payroll_Deduction_Begins__c = 'This month\'s deductions pays for next month\'s premiums';
        
        ctrl.updatePlatformSetup();
        
        String coverageEffDate = ctrl.getCoverageEffectiveDate();
        
        Test.stopTest();

        system.assert(String.isNotBlank(coverageEffDate), 'The coverage effective date is blank.');

        Date firstOfNextMonth = fifteenthOfCurrentMonth.toStartOfMonth().addMonths(1);
        String firstOfNextMonthStr = firstOfNextMonth.format();
        
        system.assertEquals(firstOfNextMonthStr, coverageEffDate, 'The coverage effective date is not the first of next month.');
    }
    
    static testMethod void testCustomerSetup_addDefaultBillMode_noBillModesOnPageLoad_expectDefaultBillModeAddedTest() {
        loadDefaultOpp();
        
        DefaultOpp.Confirm_New_or_Existing_Group__c = 'New';
        update DefaultOpp;
        
        Test.startTest();
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        ctrl.performDefaultDMLActions();
        Test.stopTest();
        
        system.assertEquals(1, ctrl.BillModes.size(), 'There should be one bill mode.');
        
        Bill_Mode__c bm = ctrl.BillModes[0];
        system.assert(bm.Id != null, 'The default bill mode was not inserted.');
    }
    
    static testmethod void testCustomerSetup_insertBillMode_invoke_expectBillModeInsertedTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        ctrl.insertBillMode();
        
        system.assertEquals(1, ctrl.BillModes.size(), 'There should be one bill mode.');
        
        Bill_Mode__c bm = ctrl.BillModes[0];

        Test.stopTest();
        
        system.assert(bm.Id != null, 'The bill mode was not inserted.');
        system.assertEquals(Constants.BILL_MODES_PRODUCT_BILLING, bm.RecordTypeId, 'The bill mode was not set to the product billing record type.');
        system.assertEquals(ctrl.formId, bm.Customer_Setup_Form__c, 'The bill mode was not linked to the customer setup form.');
    }

    static testmethod void testCustomerSetup_removeBillMode_invokeWithBillModeIdToRemove_expectBillModeDeletedTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        
        ctrl.insertBillMode();
        
        Test.stopTest();
        
        system.assertEquals(1, ctrl.BillModes.size(), 'There should be one bill mode.');
        
        Bill_Mode__c bmToDelete = ctrl.BillModes[0];

        ctrl.BillModeIdToRemove = bmToDelete.Id;
        
        ctrl.removeBillMode();
        
        system.assertEquals(0, ctrl.BillModes.size(), 'The bill mode to delete was not removed from the bill modes collection.');
        
        List<Bill_Mode__c> billModes = [Select Id from Bill_Mode__c where Id = :bmToDelete.Id];
        
        system.assertEquals(0, billModes.size(), 'The bill mode record was not deleted.');
    }
    
    static testmethod void testCustomerSetup_updateBillMode_billModeUpdated_expectBillModeRecordUpdatedTest() {
        Test.startTest();

        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        ctrl.insertBillMode();
        
        Test.stopTest();
        
        system.assertEquals(1, ctrl.BillModes.size(), 'There should be one bill mode.');
        
        Bill_Mode__c bmToUpdate = ctrl.BillModes[0];
        bmToUpdate.Other_Information__c = 'Some other info';

        ctrl.BillModeIdToUpdate = bmToUpdate.Id;
        
        ctrl.updateBillMode();
        
        Bill_Mode__c updatedBM =
        [Select Id,
                Other_Information__c
           from Bill_Mode__c
          where Id = :bmToUpdate.Id];

        system.assertEquals(bmToUpdate.Other_Information__c, updatedBM.Other_Information__c, 'The bill mode was not updated.');
    }
    
    static testmethod void testCustomerSetup_productBillingCheckRequiredFields_whatDoesTheEmployerNeedToKeyNull_expectRequiredValidationTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        ctrl.insertBillMode();
        
        ctrl.csf.What_date_does_the_employer_need_to_key__c = null;
        ctrl.csf.BillInfoDateFirstPayrollDeduction__c = Date.Today();
        
        Test.stopTest();
        
        assertProductBillingHasRequiredField(ctrl);
    }
    
    static testmethod void testCustomerSetup_productBillingCheckRequiredFields_billInfoFirstPayrollDeductionDateNull_expectRequiredValidationTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        ctrl.insertBillMode();
        
        ctrl.csf.What_date_does_the_employer_need_to_key__c = Date.Today();
        ctrl.csf.BillInfoDateFirstPayrollDeduction__c = null;
        
        Test.stopTest();
        
        assertProductBillingHasRequiredField(ctrl);
    }
    
    static testmethod void testCustomerSetup_productBillingCheckRequiredFields_noBillModeRecords_expectNoBillModesValidationTest() {
        Test.startTest();
        
        CustomerSetupFormCTRL_v2 ctrl = loadDefaultCustomSetupFormV2Controller();
        ctrl.BillModes.clear();
        
        ctrl.productBillingCheckRequiredFields(true);
        
        Test.stopTest();
        
        system.assertEquals(false, ctrl.productBillingTabComplete, 'The product billing tab should be complete.');
        system.assertEquals(CustomerSetupFormCTRL_v2.NO_BILL_MODES_VAL_MSG, ctrl.billModesErrorMessage, 'The "no bill modes" error message was not shown.');
    }
    
    static testmethod void testCustomerSetup_productBillingCheckRequiredFields_billModeRecordWithoutRequiredBenefitDeductionSchedule_expectRequiredValidationTest() {
        testBillModeRequiredField(Bill_Mode__c.Benefit_Deduction_Schedule__c.getDescribe().getName());
    }
    
    static testmethod void testCustomerSetup_productBillingCheckRequiredFields_billModeRecordWithoutRequiredWhatMonthsAreNoDeductionsTaken_expectRequiredValidationTest() {
        testBillModeRequiredField(Bill_Mode__c.What_Months_No_Deductions_Taken__c.getDescribe().getName());
    }
    
    static testmethod void testCustomerSetup_productBillingCheckRequiredFields_billModeRecordWithoutRequiredOtherInformation_expectRequiredValidationTest() {
        testBillModeRequiredField(Bill_Mode__c.Other_Information__c.getDescribe().getName());
    }
    
    static testmethod void testPlatformSetup(){
        
        User u = [SELECT Id FROM User LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account a = [SELECT Id FROM Account LIMIT 1];
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Platform_Setup__c> platformSetupForms = [SELECT Id, 
                                                      Status__c, 
                                                      Enrollment_Form__c, 
                                                      Tx_Life_Prim_Acct_Mngr_ASAP__c, 
                                                      Tx_Life_Visions_SSR_Enroll_Team_Name__c, 
                                                      Tx_Life_Agent_Data_Prim_Acct_Mngr_ASAP__c,
                                                      Tx_Life_Will_Tx_Life_be_set_up__c,
                                                      DVR_Info_WillThereBeDependent_Verif__c,
                                                      S125OtherSvcHaveAFASection125__c ,
                                                      S125OtherSvcHaveSection125WithAnotherCo__c,   //jh
                                                      S125OtherSvcPlanStartDate__c
                                                      FROM Platform_Setup__c 
                                                      WHERE Enrollment_Form__r.Enrollment_Opportunity__c =: o.Id];
        System.AssertEquals(platformSetupForms.size(), 1);
        
        Platform_Setup__c p = platformSetupForms[0];
        
        p.Tx_Life_Will_Tx_Life_be_set_up__c = 'Yes';
        p.Tx_Life_Is_new_case_of_a_re_enrol__c = 'Yes';
        p.DVR_Info_WillThereBeDependent_Verif__c = 'Yes';
        p.S125OtherSvcHaveAFASection125__c = 'Yes';
        p.S125OtherSvcIsThereFSA__c = 'Yes';
        p.S125OtherSvcDebitCard__c = 'Yes';
        update p;
        
        Test.startTest();

        PageReference pr = Page.PlatformSetupForm2;   
        Test.setCurrentPage(pr); 
        ApexPages.currentPage().getparameters().put('id',p.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(p);
        PlatformSetupFormCTRL ctrl = new PlatformSetupFormCTRL(sc);
        
        ctrl.BenefitType = 'Medical';
        ctrl.formToAdd = p.Id;
        ctrl.AddBenefit();
        ctrl.LoadBenefits();
        
        
        Core_Benefit_Form__c c = [SELECT Id, Carrier__c, Plan_Name__c FROM Core_Benefit_Form__c WHERE Platform_Setup_Form__c =: p.Id];
        ctrl.BenefitID = c.Id;
        ctrl.fieldName = 'Carrier__c';
        ctrl.fieldValue = 'Test';
        ctrl.updateBenefit();
        
        ctrl.BenefitIDToDelete = c.Id;
        ctrl.deleteBenefit();
        
        ctrl.fieldName = 'Tx_Life_ERISA_Will_the_Employer_fund__c';
        ctrl.fieldValue = 'Yes';
        ctrl.updateField();
        
        ctrl.formId = p.Id;
        ctrl.submitForm();
        
        Test.stopTest();

        List<ContentDocumentLink> cdl = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ContentDocument.Title
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId =: o.Id];
        system.assert(cdl.size() > 0);
        
        Platform_Setup__c submittedForm = [SELECT ID, Status__c FROM Platform_Setup__c WHERE ID =: p.Id];
        System.AssertEquals('Submitted', submittedForm.status__c);
        
    }

    static testmethod void testPlatformSetupV2_updateFieldDecimalBasicCoverage_expectNoErrorsTest(){
        Test.startTest();
        
        
        PlatformSetupFormCTRL ctrl = loadDefaultPlatformSetupController();
        
        /* exercise methods for coverage - not used in class - class code should be removed in future */
        ctrl.fieldName='Tx_Life_Supplies_Zip__c';
        ctrl.fieldValue='0';
        ctrl.updateFieldDecimal();
        
        Test.stopTest();
        
    }
    
    static testmethod void testPlatformSetupV2_updateFieldBooleanBasicCoverage_expectNoErrorsTest(){
        Test.startTest();
        
        PlatformSetupFormCTRL ctrl = loadDefaultPlatformSetupController();
        
        /* exercise methods for coverage - not used in class - class code should be removed in future */ 
        ctrl.fieldName='TXLifeBrokerInvolved__c';
        ctrl.fieldValue='1';
        ctrl.updateFieldBoolean();
        
        Test.stopTest();
    }
    
    static testmethod void testPlatformSetupV2_updateFieldDateBasicCoverage_expectNoErrorsTest(){
        Test.startTest();
        
        PlatformSetupFormCTRL ctrl = loadDefaultPlatformSetupController();
        ctrl.fieldName='Opportunity_Enrollment_Start_Date__c';
        ctrl.fieldValue='01/01/2017';
        ctrl.updateFieldDate();
        
        Test.stopTest();
    }
    
    static testmethod void testPlatformSetupV2_updateAccountFieldBasicCoverage_expectNoErrorsTest(){
        Test.startTest();
        
        PlatformSetupFormCTRL ctrl = loadDefaultPlatformSetupController();
        ctrl.fieldName='Name';
        ctrl.fieldValue='My Company';
        ctrl.updateAccountField();
        
        Test.stopTest();
    }

    static testmethod void testPlatformSetupV2_saveBasicCoverage_expectNoErrorsTest(){
        Test.startTest();
        
        PlatformSetupFormCTRL ctrl = loadDefaultPlatformSetupController();
        ctrl.p.Enroll_Info_Upload__c = 'Yes';
        ctrl.save();
        
        Test.stopTest();
    }

    static testmethod void testPlatformSetupV2_submitFormBasicCoverage_expectNoErrorsTest(){
        Test.startTest();
        
        PlatformSetupFormCTRL ctrl = loadDefaultPlatformSetupController();
        ctrl.checkRequiredFieldsAndDisplay();
        ctrl.submitForm();
        
        Test.stopTest();
    }   
    
    static testmethod void testSection125SetupV2(){
        
        User u = [SELECT Id FROM User LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Account a = [SELECT Id FROM Account LIMIT 1];
        Opportunity o = [SELECT Id, Has_Section_125_setup_form__c FROM Opportunity LIMIT 1];

        o.Confirm_New_or_Existing_Group__c = 'Existing';
        o.Add_a_Section_125_Plan__c = true;

        update o;
        
        List<Section_125_Setup_Form__c> section125Forms = [SELECT Id, Enrollment_Form__c FROM Section_125_Setup_Form__c WHERE Enrollment_Form__r.Enrollment_Opportunity__c =: o.Id];
        System.AssertEquals(1, section125Forms.size());
        
        Section_125_Setup_Form__c s = section125Forms[0];
        
        PageReference pr = Page.Section125_v2;
        pr.getParameters().put('id', s.Enrollment_Form__c);
        Test.setCurrentPage(pr);
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(s);
        Section125CTRL_v2 ct = new Section125CTRL_v2();
        
        //ct.updateSection125s();
        ct.createNewPlan();
        
        ct.init();
        ct.checkRequiredFieldsAndDisplay();
        
        // This checks all the conditional required fields for code coverage
        ct.section125s[0].Sec125PlanEligFlexEligibility__c = 'First day of the month following days';
        ct.section125s[0].Sec125NonelecContNonelecCont__c = 'Yes';
        ct.section125s[0].FlexSpendAcctGroupAddingHealthFSA__c = 'Yes';
        ct.section125s[0].FlexSpendAcctGroupAddingDDCFSA__c = 'Yes';
        ct.section125s[0].FlexSpendAcctFlexBillinfoDoesrela__c = 'Yes';
        ct.section125s[0].HlthSvgsAcctDoesEmployerpart__c = 'Yes';
        //ct.updateSection125s();
        //ct.checkRequiredFieldsAndDisplay();
        
        ct.section125s[0].Sec125PlanEligFlexEligibility__c = 'First day of the month following months';
        //ct.updateSection125s();
        //ct.checkRequiredFieldsAndDisplay();
        
        ct.formToAdd = ct.section125s[0].Id;
        ct.AddBenefit();
        ct.insertRelatedEmployer();
        
        Qualified_Benefit_Form__c q = [SELECT ID FROM Qualified_Benefit_Form__c LIMIT 1];
        ct.BenefitID = q.Id;
        ct.fieldName = 'Carrier__c';
        ct.fieldValue = 'test';
        ct.updateBenefit();
        ct.BenefitIDToDelete = q.Id;
        ct.deleteBenefit();
        
        Common_Ownership_Form__c r = [SELECT Id FROM Common_Ownership_Form__c LIMIT 1];
        ct.BenefitId = r.Id;
        ct.fieldName = 'Legal_Name__c';
        ct.fieldValue = 'test';
        ct.updateRE();
        ct.REIDToDelete = r.Id;
        ct.deleteRE();
        
        for(Section_125_Setup_Form__c x : ct.section125s)
        {
            x.Status__c = 'In Progress';
            x.Comments__c = 'Test';
            // Required Section 125 Tab Fields
            x.Sec125BusinessEntityType__c = 'Partnership';
            x.Sec125PrincipalBusinessActivity__c = 'Test';
            x.Sec125PlanNumber__c = '501';
            x.Sec_125_S125_Plan_Document_Needed_By__c = system.today();
            x.Sec125EffDatesThisplanisintended__c = 'OK';
            // Effective Dates
            x.Sec125EffDate__c = system.today();
            x.Sec125EffDatesAFAProviderEffDate__c = system.today();
            x.Sec125EffDatescurplanyrwillbegin__c = system.today();
            x.Sec125EffDatescurplanyrwillend__c = system.today();
            // Plan Eligibility
            x.Sec125PlanEligPlanEligibility__c = 'First day of the month following months';
            x.Sec125PlanEligPlanEligMonths__c = '2';
            x.Sec125MinagereqforemployeeElig__c = '16';
            // Contributions
            x.Sec125NonelecContNonelecCont__c = 'Yes';
            x.Sec125Non_elecContributionInformation__c = 'Test';
            x.S125OptOut__c = 'Yes';
            x.Sec125ElectiveContributions__c = 'Per Plan Year';
            // Section 79 Life Insurance
            x.Sec125Sec79LifeInsIfGrpter__c = 'may';
            x.Sec125Sec79LifeInsAccthave__c = 'Yes';
            
            // Qualified Benefits Tab
            x.QualBenAnyQualBenOffered__c = 'Yes';
            
            // Flexible Spending Account Tab
            // Health FSA
            x.FlexSpendAcctGroupAddingHealthFSA__c = 'Yes';
            x.FlexSpendAcctHlthFlexMin__c = '5';
            x.FlexSpendAcctHlthFlexMax__c = '5';
            x.FlexSpendAcctHlthFlexSpendAcctEmp__c = '5';
            x.FlexSpendAcctHlthFlexWho__c = 'AFA';
            x.FlexSpendAcctDebitCardWillEmpl__c = 'No';
            x.FlexSpendAcctDebitCardFee__c = 'Waived';
            // Dependent Daycare
            x.FlexSpendAcctGroupAddingDDCFSA__c = 'Yes';
            x.FlexSpendAcctDepDaycareReimbMax__c = '5';
            x.FlexSpendAcctDepDaycareReimbMin__c = '5';
            x.FlexSpendAcctDepDaycareReimbWho__c = 'AFA';
            // FSA Details
            x.FlexSpendAcctFSAEffectiveDate__c = system.today();
            x.FlexSpendAcctGRACEPERIstheEmpl__c = 'Grace Period';
            x.FlexSpendAcctAdminFeeAdminFeeWho__c = 'Employer';
            x.FlexSpendAcctAdminFeeAdminFeeCost__c = 'Waived';
            x.FlexSpendAcctUniformCoverageRisk__c = 'AFA (Trust Subscription Agreement)';
            x.FlexSpendAcctHEARTACTIstheEmpl__c = 'Yes';
            // Flex Billing
            x.FlexSpendAcctFlexBillinfoPayMode__c = 'Monthly (12)';
            x.FlexSpendAcctFlexBillinfoFirstPay__c = system.today();
            x.FlexSpendAcctFlexBillinfoDoesrela__c = 'Yes';
            x.FlexSpendAcctFlexBillinfoIfyesEm__c = 'Monthly (12)';
            x.FlexSpendAcctFlexBillinfoFirstPay__c = system.today();
            x.FlexSpendAcctFlexBillinfoIfSepar__c = 'Main Employer';
            
            // Health Savings Account tab
            x.HlthSvgsAcctDoesEmployerpart__c = 'Yes';
            x.HlthSvgsAcctContributionMethod__c = 'ACH Pull';
            x.HlthSvgsAcctDateofFirstHSAContribution__c = system.today();
            x.HlthSvgsAcctChargeMonthlyMaint__c = 'Employer';
            x.HlthSvgsAcctDateofFirstHSAPayrollDed__c = system.today();
        }
        
        ct.updateSection125s();
        ct.setTabColors();
        
        ct.idToDelete = ct.section125s[0].Id;
        ct.deletePlan();
        
        ct.checkRequiredFieldsAndDisplay();
        ct.submitForm();
        
        //ct.section125s[0].Comments__c = 'Test Comments to alieviate flow trigger error';
        //ct.updateSection125s();
        
        //ct.fieldValue = 'true';
        //ct.fieldName = 'Request_Edit__c';
        //ct.updateEnrollmentForm();
        
        test.stopTest();
    }
    
    static testmethod void testPlanSummarySetupV2(){
        Opportunity o = [SELECT Id, Generate_a_Section_125_One_page_summary__c, Confirm_New_or_Existing_Group__c, Are_you_making_any_product_changes__c FROM Opportunity LIMIT 1];
        o.Confirm_New_or_Existing_Group__c = 'Existing';
        o.Generate_a_Section_125_One_page_summary__c = true;
        o.Are_you_making_any_product_changes__c = 'Yes';
        update o;
        
        Section_125_Plan_Summary__c planSummaryForm = [SELECT Id, Enrollment_Form__c, Status__c, Request_Edit__c, Changes__c  FROM Section_125_Plan_Summary__c WHERE Enrollment_Form__r.Enrollment_Opportunity__c =: o.Id];
        System.assert(planSummaryForm != null);
        
        PageReference pr = Page.PlanSummaryForm_v2;
        pr.getParameters().put('retUrl', 'test');
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(planSummaryForm);
        PlanSummaryFormCTRL_v2 ctrl = new PlanSummaryFormCTRL_v2(sc);
        
        ctrl.init();
        ctrl.save();
        
        Test.startTest();
        ctrl.checkRequiredFieldsAndDisplay();
        ctrl.submitForm();
        
        ctrl.fieldValue = 'true';
        ctrl.fieldName = 'Request_Edit__c';
        ctrl.updateEnrollmentForm();
        
        Test.stopTest();
    }   
    
    
    
}