public with sharing class AccountTriggerHandler extends TriggerHandlerBase {
    protected override void beforeUpdate(Map<Id, Sobject> oldRecordsMap, Map<Id, Sobject> newRecordsMap) {
        Map<Id, Account> oldAccountsMap = (Map<Id, Account>) oldRecordsMap;
        Map<Id, Account> newAccountsMap = (Map<Id, Account>) newRecordsMap;
        
        list<Account> accsForCloning = new list<Account>();

        for(Account a : newAccountsMap.values())
        {               
            if(a.Clone_Flag__c == true) accsForCloning.add(a);
        }

        if(accsForCloning.size() > 0)
        {
            standardAccountBLogic.cloneAssetsToChildAcc(accsForCloning);
            standardAccountBLogic.updateParentFlag(accsForCloning);
        }
        
        sendMicrositeUpsertRequestIfNeeded(oldAccountsMap, newAccountsMap);
    }
    
    protected override void afterInsert(List<Sobject> newRecords) {
        List<Account> newAccounts = (List<Account>) newRecords;
    
        list<Account> accsToAgg = new list<Account>();
        for(Account a : newAccounts){ 
            System.debug('+++Flag SET Insert? +++ ' + a.Overall_Participation_Flag__c);
            if(true == a.Overall_Participation_Flag__c) accsToAgg.add(a);
        }
        if(accsToAgg.size() > 0)
            standardAccountBLogic.updateAggregateTotals(accsToAgg);
    }

    protected override void afterUpdate(Map<Id, Sobject> oldRecordsMap, Map<Id, Sobject> newRecordsMap) {
        Map<Id, Account> oldAccountsMap = (Map<Id, Account>) oldRecordsMap;
        Map<Id, Account> newAccountsMap = (Map<Id, Account>) newRecordsMap;

        list<Account> accsToAgg = new list<Account>();
        for(Account a : newAccountsMap.values()){ 
            System.debug('+++Flag SET Update? +++ ' + a.Overall_Participation_Flag__c);
            if(true == a.Overall_Participation_Flag__c) accsToAgg.add(a);
        }
        if(accsToAgg.size() > 0)
            standardAccountBLogic.updateAggregateTotals(accsToAgg);
    }

    protected override void afterDelete(Map<Id, Sobject> deletedRecordsMap) {
        Map<Id, Account> deletedAccountsMap = (Map<Id, Account>) deletedRecordsMap;
        
        standardAccountBLogic.rollupOnDelete(deletedAccountsMap.values());
    }
    
    private void sendMicrositeUpsertRequestIfNeeded(Map<Id, Account> oldAccountsMap, Map<Id, Account> newAccountsMap) {
        List<Async_Request__c> micrositeUpsertRequests = new List<Async_Request__c>();
        
        for (Account oldAccount : oldAccountsMap.values()) {
            Account newAccount = newAccountsMap.get(oldAccount.Id);
            
            if (oldAccount.Enrollment_Site__c == null &&
                String.isNotBlank(newAccount.Enrollment_Site__c) &&
                String.isNotBlank(newAccount.Requested_Microsite_Prenrollment_Form_Id__c)) {

                Async_Request__c micrositeUpsertRequest = new Async_Request__c(
                    Operation_Class__c = 'ESBMicrositeAsyncRequestHandler',
                    Parameters__c = newAccount.Requested_Microsite_Prenrollment_Form_Id__c
                );
                
                micrositeUpsertRequests.add(micrositeUpsertRequest);
            }
        }
        
        if (micrositeUpsertRequests.size() > 0) {
            insert micrositeUpsertRequests;
        }
    }
}