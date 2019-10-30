global without sharing class UpdateProjectsToNotWorked implements Database.Batchable<sObject>, Schedulable {
    public static final String DAILY_SCHEDULE_NAME = 'Daily Project Not Worked Updater';
    public static final Integer DEFAULT_BATCH_SIZE = 2000;    
    
    global static void scheduleDailyAt4AM() {
        system.schedule(DAILY_SCHEDULE_NAME, '0 0 4 * * ?', new UpdateProjectsToNotWorked());
    }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new UpdateProjectsToNotWorked(), DEFAULT_BATCH_SIZE);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {

        date d=system.today().adddays(-30);   

        String untouchedProjectsQuery = 
               'SELECT Id, Name ' +
               '  FROM Project__c ' +
               ' WHERE Opportunity__c != null ' +
               '   AND Opportunity__r.Effective_Date_of_AFA_Products__c <= :d' +
               '   AND Status__c = \'New\'';
        
        return Database.getQueryLocator(untouchedProjectsQuery);
    }

    global void execute(Database.BatchableContext BC, List<Project__c> projects) {
        for (Project__c project : projects) {
            project.Status__c = 'Not Worked';
        }

        update projects;
    }

    global void finish(Database.BatchableContext BC) { }
}