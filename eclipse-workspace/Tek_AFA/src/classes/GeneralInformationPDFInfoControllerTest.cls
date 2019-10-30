@isTest
public with sharing class GeneralInformationPDFInfoControllerTest {
    
    static Opportunity DefaultOpportunity = null;
    static Enrollment_Form__c DefaultOpportunityEnrollmentForm = null;
    
    @testSetup
    static void setup() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
    }
    
    private static void loadDefaults() {
        DefaultOpportunity = getDefaultOpportunity();
        
        loadDefaultOpportunityEnrollmentForm(DefaultOpportunity.Id); 
    }
    
    private static void loadDefaultOpportunityEnrollmentForm(Id oppId) {
        DefaultOpportunityEnrollmentForm =
        [SELECT Id,
                Name
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :oppId];
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
                Branch_Office__c,
                Division__c,
                Enrollment_Path__c
           FROM Opportunity];
    }
    
    static GeneralInformationPDFInfoController loadControllerWithEnrollmentFormId(Id enrollmentFormId) {
        GeneralInformationPDFInfoController controller = new GeneralInformationPDFInfoController();
        
        controller.enrollmentFormId = enrollmentFormId;
        
        return controller;
    }
    
    static void assertEnrollmentContactLoaded(GeneralInformationPDFInfoController controller, Id contactId) {
        system.assert(controller != null, 'The controller is null.');
        system.assert(contactId != null, 'The contact id is null.');
        system.assert(controller.enrollmentContacts != null, 'The enrollmentContacts is null.');
        system.assert(controller.enrollmentContacts.size() > 0, 'There are no enrollment contacts.');
        
        Boolean isContactFound = false;
        
        for (GeneralInformationPDFInfoController.EnrollmentContact ec : controller.enrollmentContacts) {
            if (ec.ContactId == contactId) {
                isContactFound = true;
                break;
            }
        }

        system.assert(isContactFound, 'The contact was not loaded.');
    }
    
    static void assertMarketedProductLoaded(List<Marketed_Product__c> marketedProducts, Id marketedProductIdToFind) {
        system.assert(marketedProducts != null, 'The marketed products are null.');
        system.assert(marketedProducts.size() > 0, 'There are no marketed products to search.');

        system.assert(marketedProductIdToFind != null, 'The marketed product id to find is null.');
        
        Map<Id, Marketed_Product__c> marketedProductsMap = new Map<Id, Marketed_Product__c>(marketedProducts);
        
        system.assert(marketedProductsMap.containsKey(marketedProductIdToFind), 'The marketed product was not found.');
    }
    
    @isTest
    static void enrollmentFormId_setWithNullId_expectNoErrorsTest() {
        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(null);
    }
    
    @isTest
    static void enrollmentFormId_setWithEnrollmentIdWithPlatformSetupOnly_expectEnrollmentFormLoadedTest() {
        loadDefaults();
        
        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(DefaultOpportunityEnrollmentForm.Id);
        
        system.assertEquals(DefaultOpportunityEnrollmentForm.Id, controller.enrollmentFormId, 'The enrollmentFormId was not set to the given one.');
        system.assert(controller.enrollmentForm != null, 'The enrollment form is null.');
        system.assertEquals(DefaultOpportunityEnrollmentForm.Id, controller.enrollmentForm.Id, 'The expected enrollment form was not loaded.');
        
        system.assert(controller.enrollmentOpp != null, 'The enrollment opportunity is null.');
        system.assert(controller.acct != null, 'The account is null.');
        system.assert(controller.ps != null, 'The platform setup is null.');
    }

    @isTest
    static void enrollmentFormId_setWithEnrollmentIdWithCustomerSetupForm_expectCustomerSetupFormLoadedTest() {
        loadDefaults();
        
        Customer_Setup_Form__c customerSetupForm = CustomerSetupFormTestData.Instance.withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).insertCustomerSetupForm();        

        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(DefaultOpportunityEnrollmentForm.Id);
        
        system.assert(controller.csf != null, 'The customer setup form is null.');
        
        system.assertEquals(customerSetupForm.Id, controller.csf.Id, 'The expected customer setup form was not loaded.');
    }

    @isTest
    static void enrollmentFormId_setWithEnrollmentIdWithAdministrativeContact_expectAdministrativeContactLoadedTest() {
        loadDefaults();
        
        Contact adminContact = ContactTestData.Instance.insertContact();

        DefaultOpportunity.Administrative_Contact__c = adminContact.Id;
        update DefaultOpportunity;
        
        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(DefaultOpportunityEnrollmentForm.Id);
        
        assertEnrollmentContactLoaded(controller, adminContact.Id);
    }

    @isTest
    static void enrollmentFormId_setWithEnrollmentIdWithSection125SetupForm_expectSection125SetupFormLoadedTest() {
        loadDefaults();
        
        Section_125_Setup_Form__c s125 = Section125SetupFormTestData.Instance.withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).insertS125SetupForm();
        
        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(DefaultOpportunityEnrollmentForm.Id);
        
        system.assert(controller.s125 != null, 'The s125 is null.');
        system.assertEquals(s125.Id, controller.s125.Id, 'The expected s125 was not loaded.');
    }

    @isTest
    static void enrollmentFormId_setWithEnrollmentIdWithBenefitContact_expectBenefitContactLoadedTest() {
        loadDefaults();
        
        Contact benefitContact = ContactTestData.Instance.insertContact();
        
        Customer_Setup_Form__c customerSetupForm =
            CustomerSetupFormTestData.Instance.withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                              .withBenefitContact(benefitContact.Id)
                                              .withBenefitContactSameAsAdmin('No')
                                              .insertCustomerSetupForm();
        
        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(DefaultOpportunityEnrollmentForm.Id);
        
        assertEnrollmentContactLoaded(controller, benefitContact.Id);
    }
    
    @isTest
    static void enrollmentFormId_setWithEnrollmentIdWithBenefitMarketingProduct_expectBenefitMarketingProductLoadedTest() {
        loadDefaults();
        
        Product_Catalog__c benefitProduct = ProductCatalogTestData.Instance.withType('Benefit').insertProductCatalog();
        
        Marketed_Product__c benefitMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(benefitProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).insertMarketedProduct();
        
        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(DefaultOpportunityEnrollmentForm.Id);
        
        assertMarketedProductLoaded(controller.benefitMarketedProducts, benefitMarketedProduct.Id);
    }
    
    @isTest
    static void enrollmentFormId_setWithEnrollmentIdWithServiceMarketingProduct_expectServiceMarketingProductLoadedTest() {
        loadDefaults();
        
        Product_Catalog__c serviceProduct = ProductCatalogTestData.Instance.withType('Service').insertProductCatalog();
        
        Marketed_Product__c serviceMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(serviceProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).insertMarketedProduct();
        
        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(DefaultOpportunityEnrollmentForm.Id);
        
        assertMarketedProductLoaded(controller.serviceMarketedProducts, serviceMarketedProduct.Id);
    }

    @isTest
    static void enrollmentFormId_setWithEnrollmentIdWithImportMarketingProduct_expectImportMarketingProductLoadedTest() {
        loadDefaults();
        
        Product_Catalog__c importProduct = ProductCatalogTestData.Instance.withType('Import').insertProductCatalog();
        
        Marketed_Product__c importMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(importProduct.Id).withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id).insertMarketedProduct();
        
        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(DefaultOpportunityEnrollmentForm.Id);
        
        assertMarketedProductLoaded(controller.importMarketedProducts, importMarketedProduct.Id);
    }
    
    @isTest
    static void getEnrollmentPathPlatformSetupFieldSet_fieldSetSpecifiedOnSelectedEnrollmentPath_expectFieldSetFoundTest() {
        Map<String, Schema.FieldSet> platformSetupFieldSets =  Schema.SObjectType.Platform_Setup__c.fieldSets.getMap();

        if (platformSetupFieldSets.isEmpty()) {
            return;
        }

        Opportunity opp = getDefaultOpportunity();
        
        String platformSetupFieldSet = new List<String>(platformSetupFieldSets.keySet())[0];
        Enrollment_Path__c ep = EnrollmentPathTestData.Instance.withPlatformSetupFieldSet(platformSetupFieldSet)
                                                               .withDivision(opp.Division__c)
                                                               .insertEnrollmentPath();

        opp.Enrollment_Path__c = ep.Id;
        update opp;

        loadDefaults();

        GeneralInformationPDFInfoController controller = loadControllerWithEnrollmentFormId(DefaultOpportunityEnrollmentForm.Id);
        Schema.FieldSet fs = controller.getEnrollmentPathPlatformSetupFieldSet();
        
        system.assert(fs != null, 'The enrollment path platform setup field set is null.');
        system.assert(platformSetupFieldSet == fs.getName(), 'The field set provided was not the one specified. Expected: ' + platformSetupFieldSet + ' but received: ' + fs.getName());
    }
}