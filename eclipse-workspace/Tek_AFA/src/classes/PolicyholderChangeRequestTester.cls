@isTest
public class PolicyholderChangeRequestTester {
    
    @testSetup
    static void testData()
    {
        Util utility = new Util();
		User u = utility.createOneUser(false, 'ChangeRequestUser@americanfidelity.com', 'Change Request User');
		u.AFA_Division__c = 'AFES';
		insert u;
    }
    
    static testMethod void TestChangeRequestSaves()
    {
        Util u = new Util();
        
        Id rType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        Account a = u.createOneAcc('Policyholder Test', true, rType);
        
        Policyholder__c holder = new Policyholder__c();
        holder.First_Name__c = 'Test';
        holder.Last_Name__c = 'Test';
        holder.Customer_Number__c = '123456';
        holder.Social_Security_Number__c = '111223333';
        insert holder;
        
        Purchased_Product__c pp = new Purchased_Product__c();
        pp.Account__c = a.Id;
        pp.Product_Family__c = 'Disability';
        pp.Product_Description__c = 'Disability Description';
        pp.Policyholder__c = holder.Id;
        pp.Policy_Status__c = 'Active';
        insert pp;
        
        List<String> types = RecordTypeComponentController.getRecordTypesForObject('Change_Request__c');
        String combTypes = '';
        for(String t : types)
        {
            combTypes = combTypes + ',' + t;
        }
        ApexPages.currentPage().getParameters().put('RecordTypeNames', combTypes);
        ApexPages.StandardController sc = new ApexPages.StandardController(holder);
        PolicyholderChangeRequestEXT ext = new PolicyholderChangeRequestEXT(sc);
        
        Test.startTest();
        system.assert(true);
        
        system.assertNotEquals(null, ext.AddressChange);
        system.assertNotEquals(null, ext.EmployerTransfer);
        system.assertNotEquals(null, ext.ContactChange);
        
        ext.saveAll();
        ext.SubmitAll();        
        
        ext.AddressChange.Physical_Street__c = '123 Test';
        ext.AddressChange.Physical_State__c = 'OK';
        ext.AddressChange.Physical_City__c = 'Test';
        ext.AddressChange.Physical_Zip__c = '12345';
        ext.SaveAddressChange();
        ext.SaveAndSubmitAddressChange();
        
        system.assertEquals(true, ext.AddressChangeSubmitted);
        
        ext.ContactChange.New_Primary_Phone__c = '1112223333';
        ext.ContactChange.New_Secondary_Phone__c = '4445557777';
        ext.saveContactChange();
        ext.SaveAndSubmitContactChange();
        
        system.assertEquals(true, ext.ContactChangeSubmitted);
        
        ext.SaveAndSubmitEmployerTransfer();
        system.assertEquals(null, ext.EmployerTransferSubmitted);
        
        ext.purchProducts = ext.getPurchasedProducts();
        ext.EmployerTransfer.New_Account_Name__c = a.Id;
        ext.EmployerTransfer.Last_Deduction_Date__c = system.today();
        ext.EmployerTransfer.First_Deduction_Date__c = system.today();
        ext.EmployerTransfer.Group_Policy_Transfer__c = 'No Group Policies Being Transferred';
        ext.EmployerTransfer.Effective_Date_of_Transfer__c = system.today();
        ext.purchProducts[0].selected = true;
        ext.SaveAndSubmitEmployerTransfer();
        ext.SubmitAll();
        
        system.assertEquals(true, ext.EmployerTransferSubmitted);
        
        PageReference pageRedirect = Page.ChangeRequestRedirect;
        Test.setCurrentPage(pageRedirect);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ext.EmployerTransfer);
        ChangeRequestRedirect redirect = new ChangeRequestRedirect(ctrl);
        
        String nextPage = redirect.redirect().getUrl();
        system.assertEquals('/apex/ChangeRequestForm?id=' + redirect.request.Policyholder__c + '&ReqNum=' + redirect.request.Request_Number__c, nextPage);
        
        PageReference  viewRequests = Page.ChangeRequestForm;
        Test.setCurrentPage(viewRequests);
        System.currentPageReference().getParameters().put('ReqNum', string.valueOf(redirect.request.Request_Number__c));
        sc = new ApexPages.StandardController(holder);
        ext = new PolicyholderChangeRequestEXT(sc);
        
        Test.stopTest();
    }
    
    static testMethod void TestConservationRequest()
    {
        Util u = new Util();
        
        Id rType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        Account a = u.createOneAcc('Policyholder Test', true, rType);
        
        Policyholder__c holder = new Policyholder__c();
        holder.First_Name__c = 'Test';
        holder.Last_Name__c = 'Test';
        holder.Customer_Number__c = '123456';
        holder.Social_Security_Number__c = '111223333';
        insert holder;
        
        Purchased_Product__c pp = new Purchased_Product__c();
        pp.Account__c = a.Id;
        pp.Product_Family__c = 'Disability';
        pp.Product_Description__c = 'Disability Description';
        pp.Policyholder__c = holder.Id;
        pp.Policy_Status__c = 'Active';
        insert pp;
        
        Id ConservationId = Schema.SObjectType.Change_Request__c.getRecordTypeInfosByName().get('Conservation').getRecordTypeId();
        
        PageReference conservation = Page.ChangeRequestForm;
        Test.setCurrentPage(conservation);
        System.currentPageReference().getParameters().put('ReqNum', 'new');
        System.currentPageReference().getParameters().put('RType', ConservationId);
        ApexPages.StandardController sc = new ApexPages.StandardController(holder);
        PolicyholderChangeRequestEXT ext = new PolicyholderChangeRequestEXT(sc);
        
        Test.startTest();
        
        system.assertNotEquals(null, ext.ConservationRequest);
        
        ext.SaveAndSubmitConservation();
        system.assertEquals(null, ext.ConservationRequestSubmitted);
        
        ext.ConservationRequest.Last_Month_Paid_by_Group__c = 'January';
        ext.ConservationRequest.Reason_For_Leaving_Employment__c = 'Termination';
        ext.SaveConservation();
        ext.SaveAll();
        ext.SubmitAll();
        ext.SaveAndSubmitConservation();
        
        system.assertEquals(true, ext.ConservationRequestSubmitted);
        
        PageReference pageRedirect = Page.ChangeRequestRedirect;
        Test.setCurrentPage(pageRedirect);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(ext.ConservationRequest);
        ChangeRequestRedirect redirect = new ChangeRequestRedirect(ctrl);
        
        String nextPage = redirect.redirect().getUrl();
        system.assertEquals('/apex/ChangeRequestForm?id=' + redirect.request.Policyholder__c + '&ReqNum=' + redirect.request.Request_Number__c + '&RType=' + ConservationId, nextPage);
        
        PageReference  viewRequests = Page.ChangeRequestForm;
        Test.setCurrentPage(viewRequests);
        System.currentPageReference().getParameters().put('ReqNum', string.valueOf(redirect.request.Request_Number__c));
        System.currentPageReference().getParameters().put('RType', ConservationId);
        sc = new ApexPages.StandardController(holder);
        ext = new PolicyholderChangeRequestEXT(sc);
        
        Test.stopTest();
    }
    
    static testMethod void testConservationComponentGetMethod()
    {
        Util u = new Util();
        
        Id rType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        Account a = u.createOneAcc('Policyholder Test', true, rType);
        
        Policyholder__c holder = new Policyholder__c();
        holder.First_Name__c = 'Test';
        holder.Last_Name__c = 'Test';
        holder.Customer_Number__c = '123456';
        holder.Social_Security_Number__c = '111223333';
        insert holder;
        
        Change_Request__c conservation = PolicyholderChangeRequestEXT.newConservationRequest(holder.Id);
        
        system.assertNotEquals(null, conservation);
        
        conservation.Last_Month_Paid_by_Group__c = 'February';
        conservation.Reason_for_Leaving_Employment__c = 'Termination';
        
        PolicyholderChangeRequestEXT.SaveConservation(conservation);
        PolicyholderChangeRequestEXT.SaveandSubmitConservation(conservation);
        system.assertNotEquals(null, conservation.Id);
    }
    
    static testMethod void addUserToPublicGroupTest()
    {
        User u = [SELECT Id, AFA_Division__c FROM User WHERE Username = 'ChangeRequestUser@americanfidelity.com' LIMIT 1];
        
        Test.startTest();
        
        system.runAs(u)
        {
            String jobId = PolicyholderChangeRequestEXT.addUserToPublicGroup();
        }
        
        Test.stopTest();
        
        Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName =: 'AFES_Employer_Transfer' LIMIT 1];
        List<GroupMember> members = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId =: publicGroup.Id AND UserOrGroupId =: u.Id];
        system.assert(members.size() > 0);
        system.assertEquals(u.Id, members[0].UserOrGroupId);
    }
    
    static testMethod void removePermissionsTest()
    {
       	User u = [SELECT Id, AFA_Division__c FROM User WHERE Username = 'ChangeRequestUser@americanfidelity.com' LIMIT 1];
        
        system.runAs(u)
        {
            Test.startTest();
            String jobId = PolicyholderChangeRequestEXT.addUserToPublicGroup();
            PolicyholderChangeRequestEXT.removePermissions(jobId);
            Test.stopTest();
        }
        
        Group publicGroup = [SELECT Id FROM Group WHERE DeveloperName =: 'AFES_Employer_Transfer' LIMIT 1];
        List<GroupMember> members = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId =: publicGroup.Id AND UserOrGroupId =: u.Id];
        system.assert(members.size() == 0);
    }

}