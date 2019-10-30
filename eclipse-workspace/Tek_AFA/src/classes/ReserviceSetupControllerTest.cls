@isTest
public class ReserviceSetupControllerTest {
    @TestSetup
    static void makeData(){
        Account customerAccount = AccountTestData.Instance.withName('Awesome Reservice Test Account').insertCustomerAccount();
        Enrollment_Path__c path = EnrollmentPathTestData.Instance.withDivision('AFES').insertEnrollmentPath();
        Opportunity EnrollmentOpportunity = OpportunityTestData.Instance.withAccount(customerAccount.Id)
                                                                        .withEnrollmentPath(path.Id)
                                                                        .insertAFESOpportunity();
        Product_Catalog__c DVRProduct = ProductCatalogTestData.Instance.withName('Dependent Verification Review').insertProductCatalog();
    }

    static Opportunity getWorkingOpportunity(){
        return [SELECT Id,
                Division__c,
                Enrollment_Path__c
                FROM Opportunity];
    }

    static Enrollment_Form__c getEnrollmentFormByOppId(Id opportunityId) {
        return
        [SELECT Id,
                Name,
                Status__c
        FROM Enrollment_Form__c
        WHERE Enrollment_Opportunity__c = :opportunityId];
    }

    static List<Marketed_Product__c> DVRMarketedProducts(Id enrollmentFormId){
        return  [SELECT Id 
                FROM Marketed_Product__c 
                WHERE Enrollment__c =: enrollmentFormId
                AND Products__r.Name =: 'Dependent Verification Review'];
    }

    @isTest
    static void testGetSetupFormContext_shouldReturnForms(){
        test.startTest();
        ReserviceSetupController.SetupFormData context = ReserviceSetupController.getSetupFormData(getWorkingOpportunity().Id);
        test.stopTest();

        system.assertNotEquals(null, context.EnrollmentOpportunity, 'The Opportunity was null');
        system.assertNotEquals(null, context.CustomerAccount, 'The Acount was null');
        system.assertNotEquals(null, context.PlatformSetupForm, 'The Platform Setup Form was null');
        system.assertNotEquals(null, context.EnrollmentForm, 'The Enrollment Form was null');
    }

    @isTest
    static void testGetCurrentEnrollmentForm(){
        system.assertNotEquals(null, ReserviceSetupController.getCurrentEnrollmentForm(getWorkingOpportunity().Id), 'The Enrollment Form was null');
    }

    @isTest
    static void testSaveObject(){
        ReserviceSetupController.SetupFormData context = ReserviceSetupController.getSetupFormData(getWorkingOpportunity().Id);
        context.PlatformSetupForm.Enroll_Info_Upload__c = 'No';

        test.startTest();
        ReserviceSetupController.saveObject(context.PlatformSetupForm);
        test.stopTest();

        Platform_Setup__c updatedPlatform = [SELECT Enroll_Info_Upload__c FROM Platform_Setup__c WHERE Id =: context.PlatformSetupForm.Id];

        system.assertEquals('No', updatedPlatform.Enroll_Info_Upload__c, 'The object was not saved');
    }

    @isTest
    static void testRequestEditFormInSubmittedState_ImmediatelyUpdatesStatus(){
        ReserviceSetupController.SetupFormData context = ReserviceSetupController.getSetupFormData(getWorkingOpportunity().Id);
        context.PlatformSetupForm.Status__c = 'Submitted';
        update context.PlatformSetupForm;

        test.startTest();
        String message = ReserviceSetupController.RequestEdit(context.EnrollmentOpportunity.Id);
        test.stopTest();

        system.assertEquals('', message, 'A message was returned that should not have been');
    }

    @isTest
    static void testRequestEditFormInSubmittedState_SendRequestEditMessage_DoNotUpdateStatus(){
        ReserviceSetupController.SetupFormData context = ReserviceSetupController.getSetupFormData(getWorkingOpportunity().Id);
        context.PlatformSetupForm.Status__c = 'H.O. Processing';
        update context.PlatformSetupForm;

        test.startTest();
        String message = ReserviceSetupController.RequestEdit(context.EnrollmentOpportunity.Id);
        test.stopTest();

        Platform_Setup__c platform = ReserviceSetupController.getPlatformSetupForm(context.EnrollmentOpportunity.Id);

        system.assertEquals(' - Request To Edit Sent', message, 'Request Edit Message was not set');
        system.assertEquals('H.O. Processing', platform.Status__c, 'The status was updated');
    } 

    @isTest
    static void testSection125Check_withNoAffectedEligibleCoverages(){
        ReserviceSetupController.SetupFormData context = ReserviceSetupController.getSetupFormData(getWorkingOpportunity().Id);
        test.startTest();
        Boolean isS125 = ReserviceSetupController.s125Check(context.CustomerAccount.Id);
        test.stopTest();
        system.assertEquals(false, isS125, 'There should be no eligible coverages');
    }  

    @isTest
    static void testGetSignificantChangesFlag(){
        system.assertEquals(false, ReserviceSetupController.checkSignificantChanges(getWorkingOpportunity().Id), 'Significant Changes was set on default');
    }

    @isTest
    static void testgetSetupFormData_FromAccountId(){
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Awesome Reservice Test Account' LIMIT 1];
        test.startTest();
        ReserviceSetupController.SetupFormData context = ReserviceSetupController.getSetupFormDataFromAccountId(testAccount.Id);
        test.stopTest();

        system.assertNotEquals(null, context.EnrollmentOpportunity, 'The Opportunity was null');
        system.assertNotEquals(null, context.CustomerAccount, 'The Acount was null');
        system.assertNotEquals(null, context.PlatformSetupForm, 'The Platform Setup Form was null');
        system.assertNotEquals(null, context.EnrollmentForm, 'The Enrollment Form was null');
    }

    @isTest
    static void testAddRemoveDVRProduct_AddDVR(){
        Enrollment_Form__c eForm = getEnrollmentFormByOppId(getWorkingOpportunity().Id);

        ReserviceSetupController.AddRemoveDVRProduct(true, eForm.Id);

        List<Marketed_Product__c> DVRsInEnrollment = DVRMarketedProducts(eForm.Id);

        system.assertNotEquals(0, DVRsInEnrollment.size(), 'No DVR was added');

        ReserviceSetupController.AddRemoveDVRProduct(false, eForm.Id);

        DVRsInEnrollment = DVRMarketedProducts(eForm.Id);

        system.assertEquals(0, DVRsInEnrollment.size(), 'The DVRs were not removed');
    }

    @isTest
    static void testGetEnrollmentPaths(){
        Opportunity enrollmentOpp = getWorkingOpportunity();

        test.startTest();
        List<ReserviceSetupController.EnrollmentPath> paths = ReserviceSetupController.getEnrollmentPaths(enrollmentOpp.Division__c, enrollmentOpp.Enrollment_Path__c);
        test.stopTest();

        system.assertEquals(1, paths.size(), 'The Enrollment Path was not returned');
    }

    @isTest
    static void testgetCatalogForIndividualProductsVersion2(){
        Enrollment_Form__c eForm = getEnrollmentFormByOppId(getWorkingOpportunity().Id);
        test.startTest();
        List<Product_Catalog__c> products = ReserviceSetupController.getCatalogForIndividualProductsVersion2(eForm.Id, 'AFES');
        test.stopTest();
        system.assertNotEquals(null, products, 'Product Catalog was not set');
    }

    @isTest
    static void testgetCatalogForImportProductsVersion2(){
        Enrollment_Form__c eForm = getEnrollmentFormByOppId(getWorkingOpportunity().Id);
        test.startTest();
        List<Product_Catalog__c> products = ReserviceSetupController.getCatalogForImportProductsVersion2(eForm.Id, 'AFES');
        test.stopTest();
        system.assertNotEquals(null, products, 'Product Catalog was not set');
    }

    @isTest
    static void testretrieveImportProductsVersion2(){
        Enrollment_Form__c eForm = getEnrollmentFormByOppId(getWorkingOpportunity().Id);
        test.startTest();
        List<Marketed_Product__c> products = ReserviceSetupController.retrieveImportProductsVersion2(eForm.Id);
        test.stopTest();
        system.assertNotEquals(null, products, 'Marketed Products are not set');
    }

    @isTest
    static void testretrieveIndividualProductsVersion2(){
        Enrollment_Form__c eForm = getEnrollmentFormByOppId(getWorkingOpportunity().Id);
        test.startTest();
        List<Marketed_Product__c> products = ReserviceSetupController.retrieveIndividualProductsVersion2(eForm.Id);
        test.stopTest();
        system.assertNotEquals(null, products, 'Marketed Products are not set');
    }

    @isTest
    static void testinsertImportProductsVersion2(){
        Product_Catalog__c testProduct = ProductCatalogTestData.Instance.withName('TestProduct')
                                                                        .withType('Import')
                                                                        .withAllowedToBeAddedToEnrollment(true)
                                                                        .withPlanStatus('New')
                                                                        .insertProductCatalog();
        List<Product_Catalog__c> products = new List<Product_Catalog__c>();
        products.add(testProduct);
        Enrollment_Form__c eForm = getEnrollmentFormByOppId(getWorkingOpportunity().Id);

        List<Marketed_Product__c> addedProducts = ReserviceSetupController.insertImportProductsVersion2(eForm.Id, products);
        system.assertEquals(1, addedProducts.size(), 'The product was not added');

        List<Marketed_Product__c> removedProducts = ReserviceSetupController.removeImportProductVersion2(addedProducts[0].Id, eForm.Id);
        system.assertEquals(0, removedProducts.size(), 'The product was not removed');
    }

    @isTest
    static void testinsertIndividualProductsVersion2(){
        Product_Catalog__c testProduct = ProductCatalogTestData.Instance.withName('TestProduct')
                                                                        .withChassis('Individual')
                                                                        .withAllowedToBeAddedToEnrollment(true)
                                                                        .withPlanStatus('New')
                                                                        .insertProductCatalog();
        List<Product_Catalog__c> products = new List<Product_Catalog__c>();
        products.add(testProduct);
        Enrollment_Form__c eForm = getEnrollmentFormByOppId(getWorkingOpportunity().Id);

        List<Marketed_Product__c> addedProducts = ReserviceSetupController.insertIndividualProductsVersion2(eForm.Id, products);
        system.assertEquals(1, addedProducts.size(), 'The product was not added');

        List<Marketed_Product__c> removedProducts = ReserviceSetupController.removeIndividualProductVersion2(addedProducts[0].Id, eForm.Id);
        system.assertEquals(0, removedProducts.size(), 'The product was not removed');
    }

    @isTest
    static void testsubmitReserviceForm(){
        test.startTest();
        ReserviceSetupController.submitReserviceForm(getWorkingOpportunity().Id);
        test.stopTest();

        Enrollment_Form__c eForm = getEnrollmentFormByOppId(getWorkingOpportunity().Id);

        Platform_Setup__c platform = [SELECT Id, Status__c 
                                        FROM Platform_Setup__c 
                                        WHERE Enrollment_Form__c =: eForm.Id];

        system.assertEquals('Confirmed', eForm.Status__c, 'The Enrollment Form was not Confirmed');
        system.assertEquals('Submitted', platform.Status__c, 'The Platform Setup Form was not submitted');
    }

    @isTest
    static void testgetPreEnrollmentMarketingFormId(){
        test.startTest();
        String PEMid = ReserviceSetupController.getPreEnrollmentMarketingFormId(getWorkingOpportunity().Id);
        test.stopTest();

        system.assertNotEquals(null, PEMid, 'No Pre-Enrollment Marketing Form Id found');
    }

    @isTest
    static void upsertCoreBenefitForm_AddCoreBenefit()
    {
        ReserviceSetupController.SetupFormData context = ReserviceSetupController.getSetupFormData(getWorkingOpportunity().Id);
        Core_Benefit_Form__c newCoreBenefit = CoreBenefitsFormTestData.Instance.withPlatformSetupForm(context.PlatformSetupForm.Id).create();

        test.startTest();
        ReserviceSetupController.upsertCoreBenefitForm(newCoreBenefit);
        test.stopTest();

        Integer count = [SELECT Count() FROM Core_Benefit_Form__c WHERE Platform_Setup_Form__c =: context.PlatformSetupForm.Id];

        system.assertEquals(1, count, 'The Core Benefit Form was not inserted');
    }

    @isTest
    static void deleteCoreBenefitForm_RemoveCoreBenefit()
    {
        ReserviceSetupController.SetupFormData context = ReserviceSetupController.getSetupFormData(getWorkingOpportunity().Id);
        Core_Benefit_Form__c newCoreBenefit = CoreBenefitsFormTestData.Instance.withPlatformSetupForm(context.PlatformSetupForm.Id).insertCoreBenefitForm();

        test.startTest();
        ReserviceSetupController.deleteCoreBenefitForm(newCoreBenefit.Id);
        test.stopTest();

        Integer count = [SELECT Count() FROM Core_Benefit_Form__c WHERE Platform_Setup_Form__c =: context.PlatformSetupForm.Id];

        system.assertEquals(0, count, 'The Core Benefit Form was not deleted');
    }
}