public with sharing class CloneServicesController {
    
    @AuraEnabled
    public static void updateCloneFlag(Id accountId)
    {
        Account a = [SELECT Id, Clone_Flag__c FROM Account WHERE Id =: accountId];
        a.Clone_Flag__c = true;
        update a;
    }
    
    @AuraEnabled
    public static void removeClonedServices(Id accountId)
    {
        List<Id> acctIds = new List<Id>();
        
        // get child accounts
        List<Account> children = [SELECT Id, ParentId FROM Account WHERE ParentId =: accountId];
        
        for(Account a : children)
        {
            acctIds.add(a.Id);
        }
        
        if(acctIds.size() < 1)
            return;
        
        List<Asset> childAssets = [SELECT Id, AccountId, Cloned__c FROM Asset WHERE AccountId IN : acctIds AND Cloned__c = true];
        
        if(childAssets.size() < 1)
            return;
        
        delete childAssets;
    }
}