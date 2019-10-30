@isTest
public class OpportunityProductsCTRLTester {
    
    @testSetup
    static void testData()
    {
        Util u = new Util();
        
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        opportunity.Estimated_Employees__c = 12;
        update opportunity;
        
        Id pricebookId = Test.getStandardPricebookId();
        
		Product2 p = u.createOneProd('Test Product', true);
        PricebookEntry pbe = u.createPBEntry(true, pricebookId, p.Id, 100);
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Quantity = 1;
        oli.PricebookEntryId = pbe.Id;
        oli.OpportunityId = opportunity.Id;
        oli.UnitPrice = pbe.UnitPrice;
        
        insert oli;
    }
    
    static testMethod void test_retrieveOpportunityProducts()
    {
        Opportunity o = [SELECT Id FROM Opportunity Limit 1];
        
        test.startTest();
        List<OpportunityLineItem> lineItems = OpportunityProductsCTRL.retrieveOpportunityProducts(o.Id);
        test.stopTest();
        
        system.assertEquals(1, lineItems.size());
    }
    
    static testMethod void test_insertOpportunityLineItems()
    {
        Opportunity o = [SELECT Id FROM Opportunity Limit 1];
        List<PricebookEntry> pbe = [SELECT Id, Name, Product2.Name, Product2.Description, Pricebook2Id, UnitPrice
                                    FROM PricebookEntry WHERE isActive = true];
        
        test.startTest();
        List<OpportunityLineItem> lineItems = OpportunityProductsCTRL.insertOpportunityLineItems(o.Id, pbe, 12);
        test.stopTest();
        
        system.assertEquals(2, lineItems.size());
    }
    
    static testMethod void test_getPricebookEntries()
    {
        test.startTest();
        List<PricebookEntry> products = OpportunityProductsCTRL.getPricebookEntries();
        test.stopTest();
        
        system.assertEquals(1, products.size());
    }
    
    static testMethod void test_removeOpportunityLineItem()
    {
        Opportunity o = [SELECT Id FROM Opportunity Limit 1];        
        List<OpportunityLineItem> lineItems = OpportunityProductsCTRL.retrieveOpportunityProducts(o.Id);
        
        test.startTest();
        List<OpportunityLineItem> lineItemsAfterDelete = OpportunityProductsCTRL.removeOpportunityLineItem(lineItems[0].Id, o.Id);
        test.stopTest();
        
        system.assertEquals(0, lineItemsAfterDelete.size());
    }
}