public class AccountContactRelationBLogic {
    
    public static List<Id> ContactIds;
    public static Map<Id, Integer> accountContactMap;
    public static List<Id> accountIds;
    public static List<Account> accountsToUpdate;
    public static Boolean isUpdate;
    
    public static void updateDecisionMakerRollupOnAccount(List<AccountContactRelation> NEWcontactRelations, 
                                                   Map<Id, AccountContactRelation> OLDMAPcontactRelations,
                                                   List<AccountContactRelation> OLDcontactRelations)
    {    
        isUpdate = false;
        ContactIds = new List<Id>();
        AccountIds = new List<Id>();
        system.debug('JJJ Get Contacts');
        GetContactIds(NEWcontactRelations, OLDcontactRelations, OLDMAPcontactRelations);
        
        if(ContactIds.size() == 0)
            return;
        
        if(isUpdate)
            getIndirectAccounts();
        
        system.debug('JJJ Get Rollup Results ');
        getRollupResults(); 
        
        if(accountContactMap.size() == 0)
            return;
        
        system.debug('JJJ update Accounts');
        updateAccounts();
        
    }
    
    public static void GetContactIds(List<AccountContactRelation> NEWcontactRelations, 
                              List<AccountContactRelation> OLDcontactRelations,
                              Map<Id, AccountContactRelation> OLDMAPcontactRelations)
    {
        system.debug('JJJ Get Contacts 1');
        if(OLDMAPcontactRelations == null)
        {
            system.debug('JJJ Get Contacts 2');
            // after insert, loop through all of them
            for(AccountContactRelation ACR : NEWcontactRelations)
            {
                if(ACR.Decision_Maker__c && !ACR.Inactive__c && !ACR.Duplicate__c)
                {
                    system.debug('JJJ Get Contacts 3');
                    // save contact id
                    ContactIds.add(ACR.ContactId);
                    accountIds.add(ACR.AccountId);
                }
            }
        }
        else if(NEWcontactRelations == null)
        {
            system.debug('JJJ Get Contacts 4');
            // after delete
            for(AccountContactRelation ACR : OLDcontactRelations)
            {
                system.debug('JJJ Get Contacts 5');
                if(ACR.Decision_Maker__c && !ACR.Inactive__c && !ACR.Duplicate__c)
                {
                    system.debug('JJJ Get Contacts 6');
                    // save contact id
                    ContactIds.add(ACR.ContactId);
                    accountIds.add(ACR.AccountId);
                }
            }
        }
    }
    
    public static void getRollupResults()
    {
        accountContactMap = new Map<Id, Integer>();
        AggregateResult[] groupedResults = [SELECT COUNT(ContactId)contacts, AccountId
                                            FROM AccountContactRelation
                                            WHERE Decision_Maker__c = true AND Inactive__c = false AND Duplicate__c = false
                                            AND (AccountId IN: AccountIds OR ContactId IN: ContactIds)
                                            GROUP By AccountId];
        
        
        for(AggregateResult ar : groupedResults)
        {
            accountContactMap.put((Id)ar.get('AccountId'), (Integer)ar.get('contacts'));
        }
        
        system.debug(accountContactMap);
    }
    
    public static void getRollupResults(List<Id> contacts, List<Id> accounts, boolean contactUpdate)
    {
        ContactIds = new List<Id>(contacts);
        AccountIds = new List<Id>(accounts);
        
        if(contactUpdate)
            getIndirectAccounts();
        
        getRollupResults();
    }
    
    public static void updateAccounts()
    {
        accountsToUpdate = new List<Account>();
        for(Account a : [SELECT Id, Number_Decision_Maker_Contacts__c FROM Account WHERE Id IN : accountIds])
        {
            if(accountContactMap.get(a.Id) != null)
            {
                if(a.Number_Decision_Maker_Contacts__c != accountContactMap.get(a.Id))
                {
                    a.Number_Decision_Maker_Contacts__c = accountContactMap.get(a.Id);
                    accountsToUpdate.add(a);
                }
            }
            else
            {
                a.Number_Decision_Maker_Contacts__c = 0;
                accountsToUpdate.add(a);
            } 
        }
        
        system.debug('JJJ Accounts To Update: ' + accountsToUpdate);
        
        if(accountsToUpdate.size() > 0)
            update accountsToUpdate;
    }
    
    public static void getIndirectAccounts()
    {
        for(AccountContactRelation ACR : [SELECT AccountId FROM AccountContactRelation WHERE ContactId IN: ContactIds])
        {
            AccountIds.add(ACR.AccountId);
        }
    }
}