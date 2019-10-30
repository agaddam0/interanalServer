global with sharing class CurrentBillsBatchUpdater implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    global static final Integer DEFAULT_BATCH_SIZE = 100;
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CurrentBillsBatchUpdater(), getBatchSize());
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String billingAccountsQuery =
        'SELECT Id, Name, PayorNumber__c' +
        '  FROM Account' +
        ' WHERE PayorNumber__c != null';

        return Database.getQueryLocator(billingAccountsQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accounts) {
        Set<Id> billingAccountIds = CollectionUtil.getRecordIds(accounts);
        
        CurrentBillsSyncher syncher = new CurrentBillsSyncher(billingAccountIds);
        syncher.Sync();
    }
    
    global void finish(Database.BatchableContext bc) { }
    
    @testVisible
    private static Integer getBatchSize() {
        Current_Bills_Sync_Settings__c settings = Current_Bills_Sync_Settings__c.getInstance();
        
        Integer batchSize = settings != null && settings.Batch_Size__c != null
                            ? (Integer) settings.Batch_Size__c : DEFAULT_BATCH_SIZE;

        // Subtract 1 for the authentication callout.
        Integer calloutLimit = Limits.getLimitCallouts() - 1;
        
        // Limit the batch size to the largest number of allowed callouts to avoid
        // the Too Many Callouts Error.
        if (batchSize > calloutLimit) {
            batchSize = calloutLimit;
        }
        
        return batchSize;
    }
}