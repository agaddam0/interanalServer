global without sharing class ESBBatchStatusChecker implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    global void execute(SchedulableContext SC) {
        Integer calloutLimit = Limits.getLimitCallouts();
        Integer batchSize = calloutLimit - 1;

        Database.executeBatch(new ESBBatchStatusChecker(), batchSize);
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        String checkStatusURLsQuery =
        'SELECT Name, URL__c' +
        '  FROM API_Manager_Status_Check_URL__c';
        
        return Database.getQueryLocator(checkStatusURLsQuery);
    }

    global void execute(Database.BatchableContext bc, List<API_Manager_Status_Check_URL__c> checkStatusURLs) {
        IntegrationLogger.Instance.SkipInsertingLogs = true;
        ESBStatusCheckClient client = new ESBStatusCheckClient();
        
        for (API_Manager_Status_Check_URL__c statusCheckURLConfig : checkStatusURLs) {
            client.checkStatus(statusCheckURLConfig.URL__c);
        }
        
        IntegrationLogger.Instance.SkipInsertingLogs = false;
        IntegrationLogger.Instance.insertLogs();
    }
    
    global void finish(Database.BatchableContext bc) { }
}