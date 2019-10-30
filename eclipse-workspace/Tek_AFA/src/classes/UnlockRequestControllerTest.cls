@isTest
public with sharing class UnlockRequestControllerTest {
    
    static void assertEmptyUnlockRequestsByOthers(UnlockRequestController controller) {
        system.assert(controller.UnlockRequestsByOthers != null, 'The unlock requests by others is null.');
        system.assert(controller.UnlockRequestsByOthers.isEmpty(), 'The unlock requests by others should be empty.');
    }
    
    static void assertOtherUnlockRequestFound(UnlockRequestController controller, Id expectedUnlockRequestId) {
        system.assert(controller.UnlockRequestsByOthers != null, 'The unlock requests by others is null.');
        system.assertEquals(1, controller.UnlockRequestsByOthers.size(), 'There should be one unlock request.');
        system.assertEquals(expectedUnlockRequestId, controller.UnlockRequestsByOthers[0].Id, 'The expected other unlock request was not found.');
    }
    
    @isTest
    static void constructor_invokedWithNoEnrollmentFormId_expectEmptyUnlockRequestsByOthersTest() {
        UnlockRequestController controller = new UnlockRequestController();
        
        assertEmptyUnlockRequestsByOthers(controller);
    }
    
    @isTest
    static void EnrollmentFormId_setWithEnrollmentFormIdWithNoOtherUnlockRequests_expectEmptyUnlockRequestsByOthersTest() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
        
        Enrollment_Form__c enrollmentForm =
        [SELECT Id,
                Name
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :opp.Id];

        UnlockRequestController controller = new UnlockRequestController();
        controller.EnrollmentFormId = enrollmentForm.Id;
        
        assertEmptyUnlockRequestsByOthers(controller);
    }
    
    @isTest
    static void EnrollmentFormId_setWithEnrollmentFormIdWithOneOtherUnlockRequest_expectOtherUnlockRequestTest() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
        
        Enrollment_Form__c enrollmentForm =
        [SELECT Id,
                Name
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :opp.Id];
          
        Unlock_Request__c otherUnlockRequest;
        
        User notMeSysAdmin = Util.getAnActiveSystemAdministratorThatsNotMe();

        system.runAs(notMeSysAdmin) {
            otherUnlockRequest = UnlockRequestTestData.Instance.withEnrollmentForm(enrollmentForm.Id)
                                                               .withUnlockReason('other user test')
                                                               .insertUnlockRequest();
        }

        UnlockRequestController controller = new UnlockRequestController();
        UnlockRequestController.hasUnlockSetupFormsPerm = true;
        controller.EnrollmentFormId = enrollmentForm.Id;
        
        assertOtherUnlockRequestFound(controller, otherUnlockRequest.Id);
    }

    @isTest
    static void test_AuraMethod_getUnlocksByOtherUsers(){
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
        
        Enrollment_Form__c enrollmentForm =
        [SELECT Id,
                Name
        FROM Enrollment_Form__c
        WHERE Enrollment_Opportunity__c = :opp.Id];

        Unlock_Request__c otherUnlockRequest;
        
        User notMeSysAdmin = Util.getAnActiveSystemAdministratorThatsNotMe();

        system.runAs(notMeSysAdmin) {
            otherUnlockRequest = UnlockRequestTestData.Instance.withEnrollmentForm(enrollmentForm.Id)
                                                               .withUnlockReason('other user test')
                                                               .insertUnlockRequest();
        }
        test.startTest();
        List<Unlock_Request__c> otherUnlocks = UnlockRequestController.getUnlocksByOtherUsers(enrollmentForm.Id);
        test.stopTest();

        system.assertEquals(1, otherUnlocks.size(), 'No other unlocks were found');
    }

    @isTest
    static void test_AuraMethod_createAndRetrieveUnlockRequest(){
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
        
        Enrollment_Form__c enrollmentForm =
        [SELECT Id,
                Name
        FROM Enrollment_Form__c
        WHERE Enrollment_Opportunity__c = :opp.Id];

        Unlock_Request__c request = new Unlock_Request__c();
        request.Unlock_Reason__c = 'This form is awful, must redo';

        test.startTest();
        UnlockRequestController.createNewUnlockRequest(enrollmentForm.Id, request);
        Unlock_Request__c theNewRequest = UnlockRequestController.getExistingUnlockRequestByUser(enrollmentForm.Id);
        system.assertNotEquals(null, theNewRequest, 'The new request was not created');

        UnlockRequestController.completeUnlockRequest(theNewRequest);
        test.stopTest();

        Unlock_Request__c theCompletedRequest = [SELECT Id, Status__c 
                                                FROM Unlock_Request__c 
                                                WHERE Enrollment_Form__c =: enrollmentForm.Id 
                                                AND CreatedById = :UserInfo.getUserId()];

        system.assertEquals('Complete', theCompletedRequest.Status__c, 'The request was not completed');
    }

    @isTest
    static void test_AuraMethod_hasUnlockPermission(){
        UnlockRequestController.hasUnlockSetupFormsPerm = true;

        test.startTest();
        Boolean hasUnlockPerm = UnlockRequestController.hasUnlockSetupFormsPermission();
        test.stopTest();

        system.assert(hasUnlockPerm, 'The permission should be true');
    }
}