public class OpportunityProductsCTRL {

    @AuraEnabled
    public static List<OpportunityLineItem> retrieveOpportunityProducts(string opportunityId)
    {
        return getLineItems(opportunityId);
    }
    
    @AuraEnabled
    public static List<PricebookEntry> getPricebookEntries()
    {
        List<PricebookEntry> entries = [SELECT Id, Name, Product2.Name, Product2.Description, Pricebook2Id, UnitPrice
                                        FROM PricebookEntry WHERE isActive = true];
        
        return entries;
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> insertOpportunityLineItems(string opportunityId, List<PricebookEntry> products, Integer employeeCount)
    {
        Opportunity o = [SELECT Id, Estimated_Employees__c FROM Opportunity WHERE Id =: opportunityId];
        List<OpportunityLineItem> lineItemsToInsert = new List<OpportunityLineItem>();
        for(PricebookEntry pbe : products)
        {
            OpportunityLineItem oli = new OpportunityLineItem();
            if(o.Estimated_Employees__c < 1 || o.Estimated_Employees__c == null)
                oli.Quantity = 1;
            else
                oli.Quantity = o.Estimated_Employees__c;
            oli.PricebookEntryId = pbe.Id;
            oli.OpportunityId = opportunityId;
            oli.UnitPrice = pbe.UnitPrice;
            lineItemsToInsert.add(oli);
        }
        
        if(lineItemsToInsert.size() > 0)
        {
            insert lineItemsToInsert;
        }
        
        return getLineItems(opportunityId);
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> removeOpportunityLineItem(String lineItemId, String opportunityId)
    {
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE Id =: lineItemId];
        
        delete oli;        
        
        return getLineItems(opportunityId);
    }
    
    public static List<OpportunityLineItem> getLineItems(string opportunityId)
    {
        List<OpportunityLineItem> oppProducts = [SELECT Product2.Name, Product2.Description, Opportunity.Eligible_Employees__c
                                                FROM OpportunityLineItem
                                                WHERE OpportunityId =: opportunityId];
        
        return oppProducts;
    }
}