trigger customPurchasedProductTrigger on Purchased_Product__c (after insert) {
/* Commented For Deletion
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            // update associated Policy Holder Owner to associated Account Owner
            PurchProductBLogic.PurchasedProductAfterInsert(trigger.new);
        }
    }
*/
}