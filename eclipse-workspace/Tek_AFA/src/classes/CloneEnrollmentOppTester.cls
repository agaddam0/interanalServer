@isTest
public class CloneEnrollmentOppTester {
    private static Enrollment_Form__c DefaultOpportunityEnrollmentForm;
    private static Opportunity DefaultOpportunity                           { get; set; }
    private static Pre_Enrollment_Marketing_Form__c DefaultMarketingForm    { get; set; }
    
    private static void loadDefaultOpportunityEnrollmentForm() {
        Opportunity defaultOpp = getDefaultOpportunity();
        
        DefaultOpportunityEnrollmentForm =
        [SELECT Id,
                Name
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :defaultOpp.Id];
    }
    
    private static void loadDefaultMarketingForm() {
        Opportunity defaultOpp = getDefaultOpportunity();
        
        DefaultMarketingForm = getMarketingFormByOpportunity(defaultOpp.Id);
    }
    
    private static Pre_Enrollment_Marketing_Form__c getMarketingFormByOpportunity(Id opportunityId) {
        return
        [SELECT Id,
                Name,
                Special_Instructions__c,
                Title__c,
                Status__c,
                Enrollment_Form__c,
                OwnerId
           FROM Pre_Enrollment_Marketing_Form__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :opportunityId];
    }
    
    private static void loadDefaults() {
        
        DefaultOpportunity = getDefaultOpportunity();
    }
    
    @testSetup
    private static void setup() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
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
                isCloned__c,
                Opportunity_Cloned_Source__c,
                RecordType.Name
           FROM Opportunity];
    }
    
    private static List<Marketed_Product__c> getOpportunityMarketedProducts(Id opportunityId) {
        String soql = Util.getCreatableFieldsAndFieldSetSOQL('Marketed_Product__c', 'Enrollment__r.Enrollment_Opportunity__c =\'' + opportunityId + '\'', SObjectType.Marketed_Product__c.FieldSets.Enrollment_Fields_To_Clone);
        return Database.query(soql);
    }
    
    private static Platform_Setup__c getPlatformSetupForOpportunity(Id opportunityId) {
        return [SELECT Id,
                       Name,
                       What_Core_Benefits_will_show_in_the_case__c,
                       List_Generic_Folder_Names__c
                  FROM Platform_Setup__c
                 WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :opportunityId];
    }
    
    private static List<Core_Benefit_Form__c> getCoreBenefitFormByOpportunity(Id opportunityId) {
        String soql = Util.getCreatableFieldsAndFieldSetSOQL('Core_Benefit_Form__c', 'Platform_Setup_Form__r.Enrollment_Form__r.Enrollment_Opportunity__c =\'' + opportunityId + '\'', SObjectType.Core_Benefit_Form__c.FieldSets.Enrollment_Fields_To_Clone);
        return Database.query(soql);
    }
    
    private static testMethod void cloneOpportunity_cloneUsingFieldSet_expectSameFieldsClonedTest() {
        Contact administrativeContact = ContactTestData.Instance.insertContact();
        Opportunity originalOpportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        originalOpportunity.Legal_Name_is_different_than_Group_Name__c = true;
        originalOpportunity.Legal_Name__c = 'Some other legal name';
        originalOpportunity.Estimated_Employees__c = 75;
        originalOpportunity.Employee_Eligibility_Waiting_Period__c = '30';
        originalOpportunity.Additional_MCPs__c = 'None';
        originalOpportunity.Residence_State_s__c = 'New York';
        
        originalOpportunity.Working_Conditions__c = 'Voluntary One on One';
        originalOpportunity.Enrollment_Setup_Notes__c = 'Enrollment Setup Notes';
        originalOpportunity.Administrative_Contact__c = administrativeContact.Id;
        originalOpportunity.Division__c = 'AFES';
        
        update originalOpportunity;
        
        Opportunity clonedOpportunity = CloneEnrollmentOpportunityComponentCTRL.cloneOpportunity(originalOpportunity.Id);
        
        system.assert(clonedOpportunity != null, 'The cloned opportunity is null.');
        system.assertEquals(null, clonedOpportunity.Id, 'The cloned opportunity should not have been inserted.');
        system.assertNotEquals(originalOpportunity.Id, clonedOpportunity.Id, 'The cloned opportunity should have the same id as the source oppportunity.');
        
        system.assertEquals(originalOpportunity.Legal_Name_is_different_than_Group_Name__c, clonedOpportunity.Legal_Name_is_different_than_Group_Name__c,
                'The legal name is different than group name was not cloned.');
                
        system.assertEquals(originalOpportunity.Legal_Name__c, clonedOpportunity.Legal_Name__c,
                'The legal name was not cloned.');
                
        system.assertEquals(originalOpportunity.Estimated_Employees__c, clonedOpportunity.Estimated_Employees__c,
                'The estimated employees was not cloned.');
                
        system.assertEquals(originalOpportunity.Employee_Eligibility_Waiting_Period__c, clonedOpportunity.Employee_Eligibility_Waiting_Period__c,
                'The employee eligibility waiting period was not cloned.');
                
        system.assertEquals(originalOpportunity.Additional_MCPs__c, clonedOpportunity.Additional_MCPs__c,
                'The additional mcps was not cloned.');
                
        system.assertEquals(originalOpportunity.Residence_State_s__c, clonedOpportunity.Residence_State_s__c,
                'The residence states was not cloned.');

        system.assertEquals(originalOpportunity.Working_Conditions__c, clonedOpportunity.Working_Conditions__c,
                'The working conditions was not cloned.');

        system.assertEquals(originalOpportunity.Enrollment_Setup_Notes__c, clonedOpportunity.Enrollment_Setup_Notes__c,
                'The enrollment setup notes was not cloned.');

        system.assertEquals(originalOpportunity.Administrative_Contact__c, clonedOpportunity.Administrative_Contact__c,
                'The administrative contact was not cloned.');
                
        system.assertEquals(originalOpportunity.Division__c, clonedOpportunity.Division__c,
                'The division was not cloned.');
    }
    
    private static testMethod void insertClonedOpportunity_hasMarketedProductsToClone_expectNewMarketedProductsClonedAndInsertedTest() {
        Product_Catalog__c annuityProduct = ProductCatalogTestData.Instance.withType('Benefit').withName('403B Annuity').insertProductCatalog();
        
        loadDefaultOpportunityEnrollmentForm();
        
        Marketed_Product__c importLifeProduct1MarketedProduct = MarketedProductTestData.Instance.withProductCatalog(annuityProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).withPlanStatus('New').insertMarketedProduct();
        
        loadDefaults();
        Opportunity clonedOpportunity = CloneEnrollmentOpportunityComponentCTRL.cloneOpportunity(DefaultOpportunity.Id);
        
        clonedOpportunity = CloneEnrollmentOpportunityComponentCTRL.insertClonedOpportunity(clonedOpportunity, DefaultOpportunity.Id);
        
        system.assert(clonedOpportunity.Id != null, 'The cloned opportunity was not inserted.');
        system.assertNotEquals(DefaultOpportunity.Id, clonedOpportunity.Id, 'The cloned opportunity was not actually cloned.');
        
        List<Marketed_Product__c> clonedMarketedProducts = getOpportunityMarketedProducts(clonedOpportunity.Id);
        
        system.assert(clonedMarketedProducts != null, 'The clonedMarketedProducts is null.');
        system.assertEquals(1, clonedMarketedProducts.size(), 'There should be one cloned marketed product.');
    }
    
    private static testMethod void insertClonedOpportunity_opportunityToCloneWithPlatformSetupToClone_expectPlatformSetupClonedAndInsertedTest() {
        loadDefaults();
        
        Platform_Setup__c originalPlatformSetup = getPlatformSetupForOpportunity(DefaultOpportunity.Id);
        originalPlatformSetup.What_Core_Benefits_will_show_in_the_case__c = 'Generic Folders';
        originalPlatformSetup.List_Generic_Folder_Names__c = 'Generic Folder 1';

        update originalPlatformSetup;
        
        Opportunity clonedOpportunity = CloneEnrollmentOpportunityComponentCTRL.cloneOpportunity(DefaultOpportunity.Id);
        
        clonedOpportunity = CloneEnrollmentOpportunityComponentCTRL.insertClonedOpportunity(clonedOpportunity, DefaultOpportunity.Id);
        
        Platform_Setup__c clonedPlatformSetup = getPlatformSetupForOpportunity(clonedOpportunity.Id);
        
        system.assert(clonedPlatformSetup != null, 'The clonedPlatformSetup is null.');
        system.assertEquals(originalPlatformSetup.What_Core_Benefits_will_show_in_the_case__c, clonedPlatformSetup.What_Core_Benefits_will_show_in_the_case__c, 'The what core benefits will in the case was not cloned.');
        system.assertEquals(originalPlatformSetup.List_Generic_Folder_Names__c, clonedPlatformSetup.List_Generic_Folder_Names__c, 'The list generic folder names was not cloned.');
    }
    
    /*
    private static testMethod void insertClonedOpportunity_opportunityToCloneWithPreenrollmentMarketingFormToClone_expectPreenrollmentMarketingFormClonedAndInsertedTest() {
        loadDefaults();
        loadDefaultOpportunityEnrollmentForm();
        
        DefaultOpportunity.Employer_Benefits_Site__c = 'Yes';
        update DefaultOpportunity;
        
        DefaultOpportunityEnrollmentForm.Status__c = 'Confirmed';
        update DefaultOpportunityEnrollmentForm;
        
        loadDefaultMarketingForm();
        
        system.assert(DefaultMarketingForm != null, 'The default marketing form was not created.');
        
        DefaultMarketingForm.Special_Instructions__c = 'Some special instructions.';
        DefaultMarketingForm.Title__c = 'Managing Director';

        update DefaultMarketingForm;
        
        Test.startTest();
        
        Opportunity clonedOpp = CloneEnrollmentOpportunityComponentCTRL.cloneOpportunity(DefaultOpportunity.Id);
        
        clonedOpp = CloneEnrollmentOpportunityComponentCTRL.insertClonedOpportunity(clonedOpp);
        
        Test.stopTest();
        
        Pre_Enrollment_Marketing_Form__c clonedMarketingForm = getMarketingFormByOpportunity(clonedOpp.Id);
        
        system.assert(clonedMarketingForm != null, 'The marketing form was not cloned.');
        
        system.assertEquals(DefaultMarketingForm.Special_Instructions__c, clonedMarketingForm.Special_Instructions__c, 'The special instructions were not cloned.');
        system.assertEquals(DefaultMarketingForm.Title__c, clonedMarketingForm.Title__c, 'The special instructions were not cloned.');
        system.assert(clonedMarketingForm.Enrollment_Form__c != null, 'The cloned marketing form is not tied to an enrollment form.');
        system.assertNotEquals(DefaultMarketingForm.Enrollment_Form__c, clonedMarketingForm.Enrollment_Form__c, 'The cloned marketing form is tied to the original enrollment form.');
        system.assertEquals('In Progress', clonedMarketingForm.Status__c, 'The cloned marketing form is not in progress.');
    } */
    
    private static testMethod void insertClonedOpportunity_opportunityToCloneWithCoreBenefitsFormsToClone_expectCoreBenefitsFormClonedAndInsertedTest() {
        loadDefaults();
        loadDefaultOpportunityEnrollmentForm();
        
        Platform_Setup__c defaultPlatformSetup = getPlatformSetupForOpportunity(DefaultOpportunity.Id);
        
        defaultPlatformSetup.What_Core_Benefits_will_show_in_the_case__c = 'Detailed Core Benefits';
        update defaultPlatformSetup;
        
        Core_Benefit_Form__c sourceCoreBenefit = CoreBenefitsFormTestData.Instance.withPlatformSetupForm(defaultPlatformSetup.Id).insertCoreBenefitForm();
        
        system.assert(sourceCoreBenefit.Id != null, 'The source core benefit was not inserted.');
        
        Test.startTest();
        
        Opportunity clonedOpp = CloneEnrollmentOpportunityComponentCTRL.cloneOpportunity(DefaultOpportunity.Id);
        
        clonedOpp = CloneEnrollmentOpportunityComponentCTRL.insertClonedOpportunity(clonedOpp, DefaultOpportunity.Id);
        
        Test.stopTest();
        
        Platform_Setup__c clonedPlatformSetup = getPlatformSetupForOpportunity(clonedOpp.Id);
        
        List<Core_Benefit_Form__c> clonedCoreBenefitForms = getCoreBenefitFormByOpportunity(clonedOpp.Id);
        
        system.assertEquals(1, clonedCoreBenefitForms.size(), 'There should be one cloned core benefit form.');        
    }
    
    @isTest
    private static void component_cloneOppWithOppId()
    {
        loadDefaults();
        
        Opportunity newOpp = CloneEnrollmentOpportunityComponentCTRL.cloneOpportunity(DefaultOpportunity.Id);
        
        newOpp = CloneEnrollmentOpportunityComponentCTRL.insertClonedOpportunity(newOpp, DefaultOpportunity.Id);
        
        system.assertNotEquals(null, newOpp.Id);
    }
    
    @isTest
    private static void component_cloneOppWithAccountId()
    {
        Util u = new Util();
        Account a = u.createOneAcc('Component Test Account', false, Constants.ACCOUNT_CUSTOMER_ACCOUNT);
        a.Division__c = 'AWD';
        insert a;
        
        test.startTest();
        
        Opportunity newOpp = CloneEnrollmentOpportunityComponentCTRL.cloneOpportunity(a.Id);
        newOpp = CloneEnrollmentOpportunityComponentCTRL.insertClonedOpportunity(newOpp, null);
        
        test.stopTest();
        
        system.assertNotEquals(null, newOpp.Id);
    }

    @isTest
    static void getInitialCloneEnrollmentOpportunityContext_noOpenEnrollments_expectClonedOpportunityWithNoOpenEnrollmentsTest() {
        loadDefaults();

        DefaultOpportunity.StageName = 'Enrollment Closed';
        update DefaultOpportunity;

        CloneEnrollmentOpportunityComponentCTRL.CloneEnrollmentContext context = CloneEnrollmentOpportunityComponentCTRL.getInitialCloneEnrollmentOpportunityContext(DefaultOpportunity.Id);

        system.assert(context != null, 'The context is null.');
        system.assert(context.ClonedOpportunity != null, 'The context\'s cloned opportunity is null.');
        system.assert(context.ClonedOpportunity != null, 'The context\'s cloned opportunity is null.');
        system.assert(context.OpenEnrollmentOpportunities != null, 'The context\'s open enrollment opportunities is null.');
        system.assert(context.OpenEnrollmentOpportunities.isEmpty(), 'The context\'s open enrollment opportunities should be empty.');
    }

    @isTest
    static void getInitialCloneEnrollmentOpportunityContext_openEnrollmentFrom7MonthsAgo_expectNoOpenEnrollmentsTest() {
        loadDefaults();

        DefaultOpportunity.StageName = 'Enrollment Closed';
        update DefaultOpportunity;
        
        DateTime sevenMonthsAgo = DateTime.Now().addMonths(-7);
        
        Opportunity opp = OpportunityTestData.Instance.withAccount(DefaultOpportunity.AccountId)
                                                      .withCreatedDate(sevenMonthsAgo)
                                                      .insertAFESOpportunity();

        CloneEnrollmentOpportunityComponentCTRL.CloneEnrollmentContext context = CloneEnrollmentOpportunityComponentCTRL.getInitialCloneEnrollmentOpportunityContext(DefaultOpportunity.Id);

        system.assert(context.OpenEnrollmentOpportunities != null, 'The context\'s open enrollment opportunities is null.');
        system.assert(context.OpenEnrollmentOpportunities.isEmpty(), 'The context\'s open enrollment opportunities should be empty.');
    }

    @isTest
    static void getInitialCloneEnrollmentOpportunityContext_openEnrollmentFrom6MonthsAgo_expectOneOpenEnrollmentTest() {
        loadDefaults();

        DefaultOpportunity.StageName = 'Enrollment Closed';
        update DefaultOpportunity;
        
        DateTime sevenMonthsAgo = DateTime.Now().addMonths(-6);
        
        Opportunity opp = OpportunityTestData.Instance.withAccount(DefaultOpportunity.AccountId)
                                                      .withCreatedDate(sevenMonthsAgo)
                                                      .insertAFESOpportunity();

        CloneEnrollmentOpportunityComponentCTRL.CloneEnrollmentContext context = CloneEnrollmentOpportunityComponentCTRL.getInitialCloneEnrollmentOpportunityContext(DefaultOpportunity.Id);

        system.assertEquals(1, context.OpenEnrollmentOpportunities.size(), 'There should be one open enrollment opportunity.');
        system.assertEquals(opp.Id, context.OpenEnrollmentOpportunities[0].Id, 'The expected open enrollment opportunity was not returned.');
    }
}