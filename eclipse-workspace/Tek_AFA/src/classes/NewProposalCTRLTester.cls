@isTest
public class NewProposalCTRLTester {
	
    @testSetup
    static void testData()
    {
        Util utility = new Util();
        
        User u = utility.createOneUser(true, 'testProposalUser@test.com', 'Proposal User');
        
        Account account = AccountTestData.Instance.withName('Proposal Account').insertCustomerAccount();
        
        Opportunity opportunity = OpportunityTestData.Instance.withAccount(account.Id).insertAFESOpportunity();
        opportunity.Estimated_Employees__c = 12;
        update opportunity;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 p = utility.createOneProd('Test Product', true);
        PricebookEntry pbe = utility.createPBEntry(true, pricebookId, p.Id, 100);
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Quantity = 1;
        oli.PricebookEntryId = pbe.Id;
        oli.OpportunityId = opportunity.Id;
        oli.UnitPrice = pbe.UnitPrice;
        
        insert oli;
        
        Proposal__c proposal = new Proposal__c();
        proposal.RecordTypeId = Constants.PROPOSAL_GENERIC;
        insert proposal;
    }
    
    static testMethod void test_getRecordTypeObjectsForObject()
    {
        test.startTest();
        List<NewProposalCTRL.RecordTypeObject> recordTypes = NewProposalCTRL.getRecordTypeObjectsForObject('Proposal__c');
        test.stopTest();
        
        system.assert(recordTypes.size() > 0);
    }
    
    static testMethod void test_insertProposal()
    {
        User u = [SELECT Id, AFA_Division__c FROM User WHERE username = 'testProposalUser@test.com'];
        Proposal__c p;
        
        test.startTest();
        system.runAs(u)
        {
            p = NewProposalCTRL.insertProposal(Constants.PROPOSAL_GENERIC, null);
        }
        test.stopTest();
        
        system.assert(p != null);
    }
    
    static testMethod void test_retrieveProposal()
    {
        Proposal__c p = [SELECT Id FROM Proposal__c where RecordTypeId =: Constants.PROPOSAL_GENERIC];
        
        test.startTest();
        Proposal__c retrieved = NewProposalCTRL.retrieveProposal(p.Id);
        test.stopTest();
        
        system.assertEquals(p.Id, retrieved.Id);
    }
    
    static testMethod void test_deleteProposal()
    {
        Proposal__c p = [SELECT Id FROM Proposal__c WHERE RecordTypeId =: Constants.PROPOSAL_GENERIC];
        
        test.startTest();
        NewProposalCTRL.deleteProposal(p.Id);
        test.stopTest();
        
        List<Proposal__c> proposals = [SELECT Id FROM Proposal__c WHERE RecordTypeId =: Constants.PROPOSAL_GENERIC];
        
        system.assertEquals(0, proposals.size());
    }
    
    static testMethod void test_updateProposal()
    {
        Proposal__c p = [SELECT Id FROM Proposal__c where RecordTypeId =: Constants.PROPOSAL_GENERIC];
        
        test.startTest();
        Proposal__c updated = NewProposalCTRL.updateProposal(p);
        test.stopTest();
        
        system.assertEquals(p.Id, updated.Id);
    }
    
    static testMethod void test_retrieveAccount()
    {
        Account account = [SELECT Id FROM Account where Name = 'Proposal Account'];
        
        test.startTest();
        Account retrieved = NewProposalCTRL.retrieveAccount(account.Id);
        test.stopTest();
        
        system.assertEquals(account.Id, retrieved.Id);
    }
    
    static testMethod void test_updateAccount()
    {
        Account account = [SELECT Id FROM Account where Name = 'Proposal Account'];
        
        test.startTest();
        Account updated = NewProposalCTRL.updateAccount(account);
        test.stopTest();
        
        system.assertEquals(account.Id, updated.Id);
    }
    
    static testMethod void test_retrieveUser()
    {
        User u = [SELECT Id, AFA_Division__c FROM User WHERE username = 'testProposalUser@test.com'];
        User retrieved;
        system.runAs(u)
        {
            test.startTest();
            retrieved = NewProposalCTRL.retrieveUser();
            test.stopTest();
        }        
        
        system.assertEquals(u.Id, retrieved.Id);
    }
    
    static testMethod void test_updateUser()
    {
        User u = [SELECT Id, AFA_Division__c FROM User WHERE username = 'testProposalUser@test.com'];
        
        test.startTest();
        User updated = NewProposalCTRL.updateUser(u);
        test.stopTest();
        
        system.assertEquals(u.Id, updated.Id);
    }
    
    static testMethod void test_retrieveOpportunityProducts()
    {
        List<OpportunityLineItem> oli = [SELECT Id, OpportunityId FROM OpportunityLineItem];
        
        test.startTest();
        List<OpportunityLineItem> lineItems = NewProposalCTRL.retrieveOpportunityProducts(oli[0].OpportunityId);
        test.stopTest();
        
        system.assertEquals(oli.size(), lineItems.size());
    }
}