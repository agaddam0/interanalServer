public with Sharing class PolicyholderAccountsCompController {

    @AuraEnabled
    public static List<Account> getAccounts(Id policyholderId)
    {        
        AggregateResult[] groupedResults = [SELECT Account__r.Id
                                            FROM Purchased_Product__c
                                           	WHERE Policyholder__c =: policyholderId
                                            GROUP BY Account__r.Id];
        
        List<String> acctIds = new List<string>();
        
        for (AggregateResult ar : groupedResults) 
        {
            acctIds.add((string)ar.get('Id'));
        }
        
        List<Account> accounts = [SELECT Id, Name, MCP_Number__c, Division__c, Industry FROM Account WHERE Id IN :acctIds];
        
        system.debug('Accounts: ' + accounts);
        return accounts;
    }
}