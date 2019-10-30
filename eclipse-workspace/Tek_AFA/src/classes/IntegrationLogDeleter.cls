global with sharing class IntegrationLogDeleter implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public static final String DAILY_SCHEDULE_NAME = 'Daily Integration Log Deletion';
    public static final Integer DEFAULT_NUMBER_OF_RETENTION_MONTHS = 6;
    public static final Integer DEFAULT_BATCH_SIZE = 2000;
    
    private Date todaysDate { get; set; }
    
    global static void scheduleDailyAt3AM() {
        String dailyAt3AMSchedule = '0 0 3 * * ?';
        IntegrationLogDeleter deleter = new IntegrationLogDeleter();
        
        system.schedule(DAILY_SCHEDULE_NAME, dailyAt3AMSchedule,  deleter);
    }
    
    global IntegrationLogDeleter() {
        this(Date.Today());
    }
    
    global IntegrationLogDeleter (Date todaysDateArg) {
        todaysDate = todaysDateArg;
    }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new IntegrationLogDeleter(), DEFAULT_BATCH_SIZE); 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        Date sixMonthsFromTodaysDate = todaysDate.addMonths(DEFAULT_NUMBER_OF_RETENTION_MONTHS * -1);
        
        String deleteQuery = 'SELECT Id ' + 
                             '  FROM Integration_Log__c' +
                             ' WHERE CreatedDate <= :sixMonthsFromTodaysDate' +
                             '   AND ' + Label.Integration_Log_Deletion_Job_Where_Clause;
        
        return Database.getQueryLocator(deleteQuery);
    }

    global void execute(Database.BatchableContext BC, List<Integration_Log__c> logsToDelete){
        delete logsToDelete;
    }

    global void finish(Database.BatchableContext BC) { }
}