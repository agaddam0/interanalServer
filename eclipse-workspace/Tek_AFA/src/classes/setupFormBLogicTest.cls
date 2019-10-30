@isTest
private class setupFormBLogicTest {

    static testMethod void testSetupFormOwnerSetOnInsert() {
        
        Util u = new Util();
        User u1 = u.createOneUser(true, 'TestSetupFormTests1User1@user.com', 'Tester1');
        User u2 = u.createOneUser(true, 'TestSetupFormTests1User2@user.com' , 'Tester2');
        
        Account a = u.createOneAcc('testAccount', true, null);
        //Opportunity o = u.createOneOpp('testOpp', 'In Progress', a.Id, true);
        Enrollment_Form__c ef = u.createOneEnForm(true, u1.Id);
        
        Enrollment_Form__c preTest = [SELECT Id, Section_125_Owner__c, Section_125_Plan_Summary_Owner__c, Platform_Setup_Owner__c, Customer_Setup_Owner__c FROM Enrollment_Form__c WHERE Id = :ef.Id];
        
        System.assertEquals(null, preTest.Section_125_Owner__c);
        System.assertEquals(null, preTest.Platform_Setup_Owner__c);
        System.assertEquals(null, preTest.Customer_Setup_Owner__c);
        System.assertEquals(null, preTest.Section_125_Plan_Summary_Owner__c);
        
        test.startTest();
        
        Customer_Setup_Form__c csf = u.createOneCSF(true, ef.Id, u1.Id);
        Platform_Setup__c ps = u.createOnePS(true, ef.Id, u1.Id);
        Section_125_Setup_Form__c s125 = u.createOneS125(true, ef.Id, u1.Id);
        Section_125_Plan_Summary__c ps125 = u.createOneS125PS(true, ef.Id, u1.Id);
        
        test.stopTest();
        
        Enrollment_Form__c postTest = [SELECT Id, Section_125_Owner__c, Platform_Setup_Owner__c, Customer_Setup_Owner__c, Section_125_Plan_Summary_Owner__c FROM Enrollment_Form__c WHERE Id = :ef.Id];
        User testUser = [SELECT Name FROM User WHERE Id = :u1.Id];
        System.assertEquals(testUser.Name, postTest.Section_125_Owner__c);
        System.assertEquals(testUser.Name, postTest.Platform_Setup_Owner__c);
        System.assertEquals(testUser.Name, postTest.Customer_Setup_Owner__c);
        System.assertEquals(testUser.Name, postTest.Section_125_Plan_Summary_Owner__c);        
    }
    
    static testMethod void testSetupFormOwnerSetOnUpdate() {
        
        Util u = new Util();
        User u1 = u.createOneUser(true, 'TestSetupFormTests1User3@user.com', 'Tester1');
        User u2 = u.createOneUser(true, 'TestSetupFormTests1User4@user.com' , 'Tester2');
        
        Account a = u.createOneAcc('testAccount', true, null);
        //Opportunity o = u.createOneOpp('testOpp', 'In Progress', a.Id, true);
        Enrollment_Form__c ef = u.createOneEnForm(true, u1.Id);
        
        Enrollment_Form__c preTest = [SELECT Id, Section_125_Owner__c, Section_125_Plan_Summary_Owner__c, Platform_Setup_Owner__c, Customer_Setup_Owner__c FROM Enrollment_Form__c WHERE Id = :ef.Id];
        
        System.assertEquals(null, preTest.Section_125_Owner__c);
        System.assertEquals(null, preTest.Platform_Setup_Owner__c);
        System.assertEquals(null, preTest.Customer_Setup_Owner__c);
        System.assertEquals(null, preTest.Section_125_Plan_Summary_Owner__c);
        
        Customer_Setup_Form__c csf = u.createOneCSF(true, ef.Id, u1.Id);
        Platform_Setup__c ps = u.createOnePS(true, ef.Id, u1.Id);
        Section_125_Setup_Form__c s125 = u.createOneS125(true, ef.Id, u1.Id);
        Section_125_Plan_Summary__c ps125 = u.createOneS125PS(true, ef.Id, u1.Id);
        
                
        test.startTest();
        
        csf.OwnerId = u2.Id;
        update csf;
        ps.OwnerId = u2.Id;
        update ps;
        s125.OwnerId = u2.Id;
        update s125;
        ps125.OwnerId = u2.Id;
        update ps125;
        test.stopTest();
        
        Enrollment_Form__c postTest = [SELECT Id, Section_125_Owner__c, Section_125_Plan_Summary_Owner__c, Platform_Setup_Owner__c, Customer_Setup_Owner__c FROM Enrollment_Form__c WHERE Id = :ef.Id];
        User testUser = [SELECT Name FROM User WHERE Id = :u2.Id];
        System.assertEquals(testUser.Name, postTest.Section_125_Owner__c);
        System.assertEquals(testUser.Name, postTest.Platform_Setup_Owner__c);
        System.assertEquals(testUser.Name, postTest.Customer_Setup_Owner__c);   
        System.assertEquals(testUser.Name, postTest.Section_125_Plan_Summary_Owner__c);     
    }    
    
    static testMethod void testSetupFormStatusSetOnUpdate() {
        
        Util u = new Util();
        User u1 = u.createOneUser(true, 'TestSetupFormTests1User5@user.com', 'Tester1');
        System.debug(u1);
        User u2 = u.createOneUser(true, 'TestSetupFormTests1User6@user.com' , 'Tester2');
        
        Account a = u.createOneAcc('testAccount', true, null);
        //Opportunity o = u.createOneOpp('testOpp', 'In Progress', a.Id, true);
        Enrollment_Form__c ef = u.createOneEnForm(true, u1.Id);
        
        Enrollment_Form__c preTest = [SELECT Id, Section_125_Plan_Summary_Status__c, Section_125_Status__c, Platform_Setup_Status__c, Customer_Setup_Form_Status__c FROM Enrollment_Form__c WHERE Id = :ef.Id];
        
        System.assertEquals(null, preTest.Section_125_Status__c);
        System.assertEquals(null, preTest.Platform_Setup_Status__c);
        System.assertEquals(null, preTest.Customer_Setup_Form_Status__c);
        System.assertEquals(null, preTest.Section_125_Plan_Summary_Status__c);
        
        Customer_Setup_Form__c csf = u.createOneCSF(true, ef.Id, u1.Id);
        Platform_Setup__c ps = u.createOnePS(false, ef.Id, u1.Id);
        ps.RecordTypeId = Constants.PLATFORM_SETUP_AFES_FORM;
        
        insert ps;
        
        Section_125_Setup_Form__c s125 = u.createOneS125(true, ef.Id, u1.Id);
        Section_125_Plan_Summary__c ps125 = u.createOneS125PS(true, ef.Id, u1.Id);
                
        test.startTest();
        
        csf.Status__c = 'H.O. Processing';
        update csf;
        ps.Status__c = 'H.O. Processing';
        update ps;
        s125.Status__c = 'H.O. Processing';
        update s125;
        ps125.Status__c = 'H.O. Processing';
        update ps125;
        test.stopTest();
        
        Enrollment_Form__c postTest = [SELECT Id, Section_125_Plan_Summary_Status__c, Section_125_Status__c, Platform_Setup_Status__c, Customer_Setup_Form_Status__c FROM Enrollment_Form__c WHERE Id = :ef.Id];
        System.assertEquals('H.O. Processing', postTest.Section_125_Status__c);
        System.assertEquals('H.O. Processing', postTest.Platform_Setup_Status__c);
        System.assertEquals('H.O. Processing', postTest.Customer_Setup_Form_Status__c);     
        System.assertEquals('H.O. Processing', postTest.Section_125_Plan_Summary_Status__c);    
    }
    
    static testMethod void testPlatformStatusNotSetOnNonAFESandNonAWDPlatformSetupRecords() {
        Util u = new Util();
        User u1 = u.createOneUser(true, 'TestSetupFormTests1User5@user.com', 'Tester1');
        System.debug(u1);
        
        Account a = u.createOneAcc('testAccount', true, null);
        Enrollment_Form__c ef = u.createOneEnForm(true, u1.Id);
        
        Enrollment_Form__c preTest = [SELECT Id, Section_125_Plan_Summary_Status__c, Section_125_Status__c, Platform_Setup_Status__c, Customer_Setup_Form_Status__c FROM Enrollment_Form__c WHERE Id = :ef.Id];
        
        System.assertEquals(null, preTest.Platform_Setup_Status__c);
        
        Platform_Setup__c ps = u.createOnePS(false, ef.Id, u1.Id);
        ps.RecordTypeId = Constants.PLATFORM_SETUP_DVR;
        
        insert ps;
        
        test.startTest();
        
        ps.Status__c = 'H.O. Processing';
        update ps;
        test.stopTest();
        
        Enrollment_Form__c postTest = [SELECT Id, Platform_Setup_Status__c FROM Enrollment_Form__c WHERE Id = :ef.Id];
        
        system.assertNotEquals(ps.Status__c, postTest.Platform_Setup_Status__c, 'The enrollment form\'s platform setup status should not match the platform status for a DVR platform setup form.');
    }
    
    static testMethod void testSection125Sync() {
        
        Util u = new Util();
        User u1 = u.createOneUser(true, 'TestSetupFormTests1User7@user.com', 'Tester1');
        User u2 = u.createOneUser(true, 'TestSetupFormTests1User8@user.com' , 'Tester2');
        
        Account a = u.createOneAcc('testAccount', true, null);
        //Opportunity o = u.createOneOpp('testOpp', 'In Progress', a.Id, true);
        Enrollment_Form__c ef = u.createOneEnForm(true, u1.Id);
        
        Section_125_Setup_Form__c s125 = u.createOneS125(true, ef.Id, u1.Id);
        Section_125_Setup_Form__c s1252 = u.createOneS125(true, ef.Id, u1.Id);
        Section_125_Setup_Form__c s1253 = u.createOneS125(true, ef.Id, u1.Id);
                
        test.startTest();
        
         s125.Status__c = 'H.O. Processing';
         update s125;
        
        test.stopTest();
        
        Enrollment_Form__c postTest = [SELECT Id, (SELECT Id, Status__c, OwnerId FROM Section_125_Setup_Forms__r)  FROM Enrollment_Form__c WHERE Id = :ef.Id];
        
        for (Section_125_Setup_Form__c s125Form : postTest.Section_125_Setup_Forms__r)
        {
            System.assertEquals('H.O. Processing', s125.Status__c);
        }    
    }  

    static testMethod void setSection125PrimaryField_firstSection125Created_expectSection125SetToPrimaryTest() {
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOpportunityId(opportunity.Id);
        
        Section_125_Setup_Form__c s125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id)
                                                                             .insertS125SetupForm();
        
        Section_125_Setup_Form__c s125Queried = getS125ById(s125.Id);
        
        system.assertEquals(true, s125Queried.Primary__c, 'The section 125 form was not made the primary one.');
    }
    
    static testMethod void setSection125PrimaryField_secondSection125Created_expectSection125NotSetToPrimaryTest() {
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOpportunityId(opportunity.Id);
        
        Section_125_Setup_Form__c s125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id)
                                                                             .insertS125SetupForm();
                                                                             
        Section_125_Setup_Form__c secondS125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id)
                                                                                   .insertS125SetupForm();

        Section_125_Setup_Form__c secondS125Queried = getS125ById(secondS125.Id);
        
        system.assertEquals(false, secondS125Queried.Primary__c, 'The second section 125 form was made the primary one.');
    }
    
    static testMethod void linkSection125FormCommonOwnersToCustomerSetupForms_oneExistingCustomerSetupFormCommonOwnerAndPrimaryS125Inserted_expectexistingCommonOwnerLinkedToPrimaryS125Test() {
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOpportunityId(opportunity.Id);
        
        Customer_Setup_Form__c customerSetupForm = CustomerSetupFormTestData.Instance.withEnrollmentForm(ef.Id).insertCustomerSetupForm();
        
        Common_Ownership_Form__c relatedEmployer = CommonOwnershipFormTestData.Instance.withMCPSetupForm(customerSetupForm.Id).insertCommonOwnershipForm();
        
        Section_125_Setup_Form__c s125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id)
                                                                             .insertS125SetupForm();
                                                                             
        Common_Ownership_Form__c relatedEmployerQueried = getCommonOwnershipFormById(relatedEmployer.Id);
        
        system.assertEquals(s125.Id, relatedEmployerQueried.Section_125_Setup_Form__c, 'The common ownership form was not linked to the primary Section 125 setup form.');
    }
    
    static testMethod void linkSection125FormCommonOwnersToCustomerSetupForms_oneExistingCustomerSetupFormCommonOwnerAndPrimaryS125InsertedAndSecondS125Inserted_expectexistingCommonOwnerLinkedToPrimaryS125Test() {
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOpportunityId(opportunity.Id);
        
        Customer_Setup_Form__c customerSetupForm = CustomerSetupFormTestData.Instance.withEnrollmentForm(ef.Id).insertCustomerSetupForm();
        
        Common_Ownership_Form__c relatedEmployer = CommonOwnershipFormTestData.Instance.withMCPSetupForm(customerSetupForm.Id).insertCommonOwnershipForm();
        
        Section_125_Setup_Form__c s125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id)
                                                                             .insertS125SetupForm();
                                                                             
        Section_125_Setup_Form__c secondS125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id)
                                                                                   .insertS125SetupForm();
                                                                             
        Common_Ownership_Form__c relatedEmployerQueried = getCommonOwnershipFormById(relatedEmployer.Id);
        
        system.assertEquals(s125.Id, relatedEmployerQueried.Section_125_Setup_Form__c, 'The common ownership form was not linked to the primary Section 125 setup form.');
    }
    
    static testMethod void linkCustomerSetupFormCommonOwnersToSection125Forms_oneExistingS125CommonOwnerAndCustomerSetupFormInserted_expectExistingCommonOwnerLinkedToCustomerSetupFormTest() {
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOpportunityId(opportunity.Id);
        
        Section_125_Setup_Form__c s125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id)
                                                                             .insertS125SetupForm();
        
        Common_Ownership_Form__c relatedEmployer = CommonOwnershipFormTestData.Instance.withSection125SetupForm(s125.Id).insertCommonOwnershipForm();
        
        Customer_Setup_Form__c customerSetupForm = CustomerSetupFormTestData.Instance.withEnrollmentForm(ef.Id).insertCustomerSetupForm();
                                                                             
        Common_Ownership_Form__c relatedEmployerQueried = getCommonOwnershipFormById(relatedEmployer.Id);
        
        system.assertEquals(customerSetupForm.Id, relatedEmployerQueried.MCP_Setup_Form__c, 'The common ownership form was not linked to the customer setup form.');
    }
    
    static testMethod void linkCommonOwnershipFormToOtherExistingFormAsNeeded_existingS125AndExistingCSFAndCommonOwnerInsertedWithLinkageToS125_expectCommonOwnerLinkedToCustomerSetupFormTest() {
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOpportunityId(opportunity.Id);
        
        Section_125_Setup_Form__c s125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id)
                                                                             .insertS125SetupForm();
                                                                             
        Customer_Setup_Form__c customerSetupForm = CustomerSetupFormTestData.Instance.withEnrollmentForm(ef.Id).insertCustomerSetupForm();
        
        Common_Ownership_Form__c relatedEmployer = CommonOwnershipFormTestData.Instance.withSection125SetupForm(s125.Id).insertCommonOwnershipForm();
                                                                             
        Common_Ownership_Form__c relatedEmployerQueried = getCommonOwnershipFormById(relatedEmployer.Id);
        
        system.assertEquals(customerSetupForm.Id, relatedEmployerQueried.MCP_Setup_Form__c, 'The common ownership form was not linked to the customer setup form on insert.');
    }
    
    static testMethod void linkCommonOwnershipFormToOtherExistingFormAsNeeded_existingS125AndExistingCSFAndCommonOwnerInsertedWithLinkageToCSF_expectCommonOwnerLinkedToS125FormTest() {
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOpportunityId(opportunity.Id);
        
        Section_125_Setup_Form__c s125 = Section125SetupFormTestData.Instance.withEnrollmentForm(ef.Id)
                                                                             .insertS125SetupForm();
                                                                             
        Customer_Setup_Form__c customerSetupForm = CustomerSetupFormTestData.Instance.withEnrollmentForm(ef.Id).insertCustomerSetupForm();
        
        Common_Ownership_Form__c relatedEmployer = CommonOwnershipFormTestData.Instance.withMCPSetupForm(customerSetupForm.Id).insertCommonOwnershipForm();
                                                                             
        Common_Ownership_Form__c relatedEmployerQueried = getCommonOwnershipFormById(relatedEmployer.Id);
        
        system.assertEquals(s125.Id, relatedEmployerQueried.Section_125_Setup_Form__c, 'The common ownership form was not linked to the customer setup form on insert.');
    }
    
    static testMethod void testAutoAssignmentOfFormIfStatusUpdatedAndOwnerIsQueue()
    {
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        Enrollment_Form__c ef = getEnrollmentFormByOpportunityId(opportunity.Id);
                                                                             
        Customer_Setup_Form__c customerSetupForm = CustomerSetupFormTestData.Instance.withEnrollmentForm(ef.Id).insertCustomerSetupForm();
        
        customerSetupForm.Status__c = 'Submitted';
        update CustomerSetupForm;
        
        CustomerSetupForm.Status__c = 'H.O. Processing';
        test.startTest();
        update CustomerSetupForm;
        test.stopTest();
        
        system.assertEquals(system.UserInfo.getUserId(), CustomerSetupForm.OwnerId);
    }
    
    private static Enrollment_Form__c getEnrollmentFormByOpportunityId(Id opportunityId) {
        return [SELECT Id,
                       Name,
                       Status__c
                  FROM Enrollment_Form__c
                 WHERE Enrollment_Opportunity__c = :opportunityId];
    }
    
    private static Section_125_Setup_Form__c getS125ById(Id section125Id) {
        return [SELECT Id,
                       Name,
                       Primary__c
                  FROM Section_125_Setup_Form__c
                 WHERE Id = :section125Id];
    }
    
    private static Common_Ownership_Form__c getCommonOwnershipFormById(Id commonOwnershipFormId) {
        return [SELECT Id,
                       Name,
                       Section_125_Setup_Form__c,
                       MCP_Setup_Form__c
                  FROM Common_Ownership_Form__c
                 WHERE Id = :commonOwnershipFormId];
    }
}