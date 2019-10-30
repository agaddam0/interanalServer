trigger customMarketedProduct on Marketed_Product__c (after insert, after update, before delete) {
    
    if(trigger.isInsert)
    {
        setupFormManagement.CreateFormsFromMarketedProductsAfterInsert(trigger.new);
    }
    if(trigger.isUpdate)
    {
        // call helper method update signature
        if (trigger.isAfter) {
            setupFormManagement.SetGroupHIAddingFromMarketedProductsAfterUpdate(Trigger.OldMap, Trigger.NewMap);
        }
    }
    else if (trigger.isDelete) {
        if (trigger.isBefore) {
            setupFormManagement.SetGroupHIAddingFromMarketedProductsBeforeDelete(Trigger.old);
        }
    }

}