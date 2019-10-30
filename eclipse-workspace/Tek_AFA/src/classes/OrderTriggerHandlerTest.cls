@isTest
public with sharing class OrderTriggerHandlerTest {
    private static Account enrollmentAccount { get; set; }
    private static Opportunity enrollmentOpp { get; set; }
    private static Order__c benefitsSiteOrder { get; set; }
    

    @isTest
    static void assignSalesOffices_newOrderWithoutColleagueAndCreatorHasNoSalesOffice_expectBlankSalesOfficeTest() {
        Order__c newOrder = OrderTestData.Instance.insertOrder();

        assertOrderHasNoSalesOffice(newOrder.Id);
    }
    
    @isTest
    static void assignSalesOffices_newOrderWithoutColleagueAndCreatorHasSalesOffice_expectSalesOfficeAssignedTest() {
        Branch_Office__c anOffice = SalesOfficeTestData.Instance.insertSalesOffice();
        
        Colleague_Sales_Office__c creatorBranchOffice =
                ColleagueSalesOfficeTestData.Instance.withColleague(UserInfo.getUserId())
                                                     .withSalesOffice(anOffice.Id)
                                                     .insertColleagueSalesOffice();

        Order__c newOrder = OrderTestData.Instance.insertOrder();
        
        assertOrderHasSalesOffice(newOrder.Id, anOffice.Id);        
    }

    @isTest
    static void assignSalesOffices_newOrderWithColleagueWithSalesOffice_expectColleaguesSalesOfficeAssignedTest() {
        Branch_Office__c anOffice = SalesOfficeTestData.Instance.insertSalesOffice();
        
        User someActiveUser = getSomeActiveAdminUser();
        
        Colleague_Sales_Office__c creatorBranchOffice =
                ColleagueSalesOfficeTestData.Instance.withColleague(someActiveUser.Id)
                                                     .withSalesOffice(anOffice.Id)
                                                     .insertColleagueSalesOffice();

        Order__c newOrder = OrderTestData.Instance.withColleague(someActiveUser.Id)
                                                  .insertOrder();
        
        assertOrderHasSalesOffice(newOrder.Id, anOffice.Id);        
    }

    @isTest
    static void assignSalesOffices_updateOrderToWithoutColleagueAndCreatorHasSalesOffice_expectCreatorsSalesOfficeAssignedTest() {
        Branch_Office__c colleagueOffice = SalesOfficeTestData.Instance.insertSalesOffice();
        Branch_Office__c creatorOffice = SalesOfficeTestData.Instance.insertSalesOffice();
        
        User someActiveUser = getSomeActiveAdminUser();
        
        Colleague_Sales_Office__c colleagueBranchOffice =
                ColleagueSalesOfficeTestData.Instance.withColleague(someActiveUser.Id)
                                                     .withSalesOffice(colleagueOffice.Id)
                                                     .insertColleagueSalesOffice();

        Colleague_Sales_Office__c creatorBranchOffice =
                ColleagueSalesOfficeTestData.Instance.withColleague(UserInfo.getUserId())
                                                     .withSalesOffice(creatorOffice.Id)
                                                     .insertColleagueSalesOffice();

        Order__c newOrder = OrderTestData.Instance.withColleague(someActiveUser.Id)
                                                  .insertOrder();
        
        assertOrderHasSalesOffice(newOrder.Id, colleagueOffice.Id);

        newOrder.Colleague__c = null;
        update newOrder;
        
        assertOrderHasSalesOffice(newOrder.Id, creatorOffice.Id);
    }
    
    @isTest
    static void assignSalesOffices_updateOrderToColleagueWithSalesOffice_expectColleaguesSalesOfficeAssignedTest() {
        Branch_Office__c colleagueOffice = SalesOfficeTestData.Instance.insertSalesOffice();
        
        User colleague = getSomeActiveAdminUser();
        
        Colleague_Sales_Office__c colleagueBranchOffice =
                ColleagueSalesOfficeTestData.Instance.withColleague(colleague.Id)
                                                     .withSalesOffice(colleagueOffice.Id)
                                                     .insertColleagueSalesOffice();

        Order__c newOrder = OrderTestData.Instance.insertOrder();
        
        assertOrderHasNoSalesOffice(newOrder.Id);

        newOrder.Colleague__c = colleague.Id;
        update newOrder;
        
        assertOrderHasSalesOffice(newOrder.Id, colleagueOffice.Id);
    }
    
    @isTest
    static void assignSalesOffices_updateOrderToWithoutColleagueAndCreatorHasNoSalesOffice_expectNoSalesOfficeAssignedTest() {
        Branch_Office__c colleagueOffice = SalesOfficeTestData.Instance.insertSalesOffice();
        
        User colleague = getSomeActiveAdminUser();
        
        Colleague_Sales_Office__c colleagueBranchOffice =
                ColleagueSalesOfficeTestData.Instance.withColleague(colleague.Id)
                                                     .withSalesOffice(colleagueOffice.Id)
                                                     .insertColleagueSalesOffice();

        Order__c newOrder = OrderTestData.Instance.withColleague(colleague.Id)
                                                  .insertOrder();
        
        assertOrderHasSalesOffice(newOrder.Id, colleagueOffice.Id);

        newOrder.Colleague__c = null;
        update newOrder;
        
        assertOrderHasNoSalesOffice(newOrder.Id);
    }
    
    @isTest
    static void provisionWebsitesOnOrderSubmission_orderSubmittedWithoutWebsites_expectNoErrorsTest() {
        Exception nullException = null;
        
        try {
	        Order__c inProgressOrder = OrderTestData.Instance.insertOrder();
	        
	        submitOrder(inProgressOrder);
        }
        catch (Exception ex) {
            nullException = ex;
        }
        
        system.assertEquals(null, nullException, 'An error occurred submitting the order. Error: ' + nullException);
    }

    @isTest
    static void provisionWebsitesOnOrderSubmission_orderSubmittedWithBenefitsSiteOnNewEmployer_expectEmployerUpsertRequestInsertedTest() {
        setupBenefitsSiteTest();
            
        submitOrder(benefitsSiteOrder);
        
        assertEmployerUpsertRequestInserted();
        assertAccountUpdatedWithEmployerUpsertInfo(enrollmentOpp.AccountId);
    }

    @isTest
    static void provisionWebsitesOnOrderSubmission_orderSubmittedWithBenefitsSiteOnExistingEmployerWithBenefitsSite_expectMicrositeUpsertRequestInsertedTest() {
        setupBenefitsSiteTest();
        
        enrollmentAccount.Marketing_Resource_Id__c = '3fb1581a-312b-4aa3-a3ea-023d35f67a5d';
        enrollmentAccount.Employer_Benefits_Site_Request_DateTime__c = DateTime.Now().addDays(-1);
        enrollmentAccount.Enrollment_Site__c = 'https://www.example.com';
        update enrollmentAccount;
            
        submitOrder(benefitsSiteOrder);
        
        assertMicrositeUpsertRequestInserted();
    }

    @isTest
    static void provisionWebsitesOnOrderSubmission_orderSubmittedWithAppointmentSchedulerOnNewEmployerWithoutBenefitsSite_expectEmployerUpsertRequestInsertedTest() {
        setupAppointmentSchedulerTest();
        
        submitOrder(benefitsSiteOrder);
        
        assertEmployerUpsertRequestInserted();
    }

    @isTest
    static void provisionWebsitesOnOrderSubmission_orderSubmittedWithAppointmentSchedulerAndBenefitsSiteOnExistingEmployer_expectMicrositeUpsertRequestInsertedTest() {
        setupBenefitsSiteTest();

        enrollmentAccount.Marketing_Resource_Id__c = 'Some Resource Id';
        update enrollmentAccount;

        Marketing_Material__c apptSchedulerMaterial = MarketingMaterialTestData.Instance.withTitle('Appointment Scheduler')
                                                                                        .withMaterialType('Website')
                                                                                        .withWebsiteType('Appointment Scheduler')
                                                                                        .insertMarketingMaterial();

        Order_Line_Item__c apptSchedulerOrderLine = OrderLineItemTestData.Instance.withMarketingMaterial(apptSchedulerMaterial.Id)
                                                                                  .withOpportunity(enrollmentOpp.Id)
                                                                                  .withOrder(benefitsSiteOrder.Id)
                                                                                  .insertOrderLineItem();

        submitOrder(benefitsSiteOrder);
        
        assertMicrositeUpsertRequestInserted();
    }

    @isTest
    static void provisionWebsitesOnOrderSubmission_orderSubmittedWithAppointmentSchedulerAndBenefitsSiteOnNewEmployer_expectEmployerUpsertRequestInsertedTest() {
        setupBenefitsSiteTest();

        enrollmentAccount.Marketing_Resource_Id__c = null;
        update enrollmentAccount;

        Marketing_Material__c apptSchedulerMaterial = MarketingMaterialTestData.Instance.withTitle('Appointment Scheduler')
                                                                                        .withMaterialType('Website')
                                                                                        .withWebsiteType('Appointment Scheduler')
                                                                                        .insertMarketingMaterial();

        Order_Line_Item__c apptSchedulerOrderLine = OrderLineItemTestData.Instance.withMarketingMaterial(apptSchedulerMaterial.Id)
                                                                                  .withOpportunity(enrollmentOpp.Id)
                                                                                  .withOrder(benefitsSiteOrder.Id)
                                                                                  .insertOrderLineItem();

        submitOrder(benefitsSiteOrder);
        
        assertEmployerUpsertRequestInserted();
    }
    
    static void submitOrder(Order__c orderToSubmit) {
        orderToSubmit.Status__c = 'Submitted';
        update orderToSubmit;
    }
    
    static void setupBenefitsSiteTest() {
        benefitsSiteOrder = OrderTestData.Instance.insertOrder();
        
        Marketing_Material__c benefitsSiteMaterial = MarketingMaterialTestData.Instance.withTitle('Benefits Site')
                                                                                       .withMaterialType('Website')
                                                                                       .withWebsiteType('Benefits Site')
                                                                                       .insertMarketingMaterial();

        enrollmentAccount = AccountTestData.Instance.withMarketingResourceId(null)
                                                    .insertCustomerAccount();
        enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentAccount.Id)
                                                    .insertAFESOpportunity();

        Order_Line_Item__c benefitsSiteOrderLine = OrderLineItemTestData.Instance.withMarketingMaterial(benefitsSiteMaterial.Id)
                                                                                 .withOpportunity(enrollmentOpp.Id)
                                                                                 .withOrder(benefitsSiteOrder.Id)
                                                                                 .insertOrderLineItem();
    }

    static void setupAppointmentSchedulerTest() {
        benefitsSiteOrder = OrderTestData.Instance.insertOrder();
        
        Marketing_Material__c apptSchedulerMaterial = MarketingMaterialTestData.Instance.withTitle('Appointment Scheduler')
                                                                                        .withMaterialType('Website')
                                                                                        .withWebsiteType('Appointment Scheduler')
                                                                                        .insertMarketingMaterial();

        enrollmentAccount = AccountTestData.Instance.withMarketingResourceId(null)
                                                    .insertCustomerAccount();
        enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentAccount.Id)
                                                    .insertAFESOpportunity();

        Order_Line_Item__c apptSchedulerOrderLine = OrderLineItemTestData.Instance.withMarketingMaterial(apptSchedulerMaterial.Id)
                                                                                  .withOpportunity(enrollmentOpp.Id)
                                                                                  .withOrder(benefitsSiteOrder.Id)
                                                                                  .insertOrderLineItem();
    }
    
    static Order__c getOrderById(Id orderId) {
        return
        [SELECT Id,
                Name,
                Sales_Office__c
           FROM Order__c
          WHERE Id = :orderId];
    }
    
    static User getSomeActiveAdminUser() {
        return
        [SELECT Id
           FROM User
          WHERE IsActive = true
            AND Id != :UserInfo.getUserId()
            AND Profile.Name = 'System Administrator'
         LIMIT 1];
    }
    
    static void assertOrderHasNoSalesOffice(Id orderId) {
        Order__c order = getOrderById(orderId);

        system.assertEquals(null, order.Sales_Office__c, 'The order should not have an assigned sales office');
    }
    
    static void assertOrderHasSalesOffice(Id orderId, Id expectedSalesOfficeId) {
        Order__c order = getOrderById(orderId);

        system.assertEquals(expectedSalesOfficeId, order.Sales_Office__c, 'The order is not assigned the expected sales office.');
    }
    
    static void assertEmployerUpsertRequestInserted() {
        Async_Request__c request = getAsyncRequest();
        
        system.assertEquals('ESBEmployerUpsertAsyncRequestHandler', request.Operation_Class__c, 'The employer upsert was not the requested operation.');
        system.assert(String.isNotBlank(request.Parameters__c), 'The employer upsert was requested without a marketing form id.');
    }
    
    static void assertMicrositeUpsertRequestInserted() {
        Async_Request__c request = getAsyncRequest();
        
        system.assertEquals('ESBMicrositeUpdateAsyncRequestHandler', request.Operation_Class__c, 'The microsite upsert was not the requested operation.');
        system.assert(String.isNotBlank(request.Parameters__c), 'The microsite upsert was requested without a marketing form id.');
    }
    
    static void assertAccountUpdatedWithEmployerUpsertInfo(Id accountId) {
        Account acct =
        [SELECT Id,
                Name,
                Employer_Benefits_Site_Request_DateTime__c,
                Requested_Microsite_Prenrollment_Form_Id__c
           FROM Account
          WHERE Id = :accountId];

        system.assert(acct.Employer_Benefits_Site_Request_DateTime__c != null, 'The employer benefits site requested date time is empty.');
        system.assert(String.isNotBlank(acct.Requested_Microsite_Prenrollment_Form_Id__c), 'The requested microsite preenrollment form id is empty.');
    }
    
    static Async_Request__c getAsyncRequest() {
        return
        [SELECT Id,
                Name,
                Operation_Class__c,
                Parameters__c
           FROM Async_Request__c];
    }
}