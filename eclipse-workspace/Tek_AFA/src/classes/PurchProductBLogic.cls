public with sharing class PurchProductBLogic {
/* Commented for Deletion
    // This method updates the Policy Holder Owner to the Account owner when a Purchased
    // Product is inserted.
    public static void PurchasedProductAfterInsert(List<Purchased_Product__c> pproducts)
    {
        List<Id> accountIds = new List<Id>();
        
        for(Purchased_Product__c p : pproducts)
        {
            accountIds.add(p.Account__c);
        }
        
        if(accountIds.size() > 0) {
            Id batchId = Database.executeBatch(new UpdatePolicyholderOwnerBatch(accountIds));
        }
    }
    
    // This method updates all Policy Holder Owners to the Account Owner when the Account Owner has been changed
    public static void UpdatePolicyHolderOwnersAfterAccountUpdate(Map<Id, Account> AcctOLD, Map<Id, Account> AcctNEW)
    {
        List<Id> changedAccountIds = new List<Id>();

        for(Account a : AcctNEW.values())
        {
            if(a.OwnerId != AcctOLD.get(a.Id).OwnerId)
            {
                if(a.Status__c == 'Active')
                {
                    changedAccountIds.add(a.Id);
                }
            }
        }

        if (changedAccountIds.size() > 0) {
            Id batchId = Database.executeBatch(new UpdatePolicyholderOwnerBatch(changedAccountIds));
        }
    }
*/
}