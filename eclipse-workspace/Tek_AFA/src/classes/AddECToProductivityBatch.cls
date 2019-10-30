global with sharing class AddECToProductivityBatch implements Database.Batchable<SObject>, Schedulable{
    public static final String DAILY_SCHEDULE_NAME = 'Stamp EC onto Productivity Data Records Daily Batch';
    public static final Integer DEFAULT_BATCH_SIZE = 2000;

    global static void scheduleDailyAt2AM() {
        String dailyAt2AMSchedule = '0 0 2 * * ?';
        AddECToProductivityBatch AddECjob = new AddECToProductivityBatch();
        
        system.schedule(DAILY_SCHEDULE_NAME, dailyAt2AMSchedule,  AddECjob);
    }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new AddECToProductivityBatch(), DEFAULT_BATCH_SIZE); 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String ProductivityDataQuery = 'SELECT Id ' + 
        ', Current_Enrollment_Coordinator__c' +
        ', Additional_Enrollment_Coordinator__c' +
        ', Account__r.Current_Enrollment_Coordinator__c' +
        ', Account__r.Additional_Enrollment_Coordinator__c' +
        ' FROM Productivity_Data__c ' +
        ' WHERE (Account__r.Current_Enrollment_Coordinator__c != null ' +
        ' OR Account__r.Additional_Enrollment_Coordinator__c != null)' + 
        ' AND CreatedDate = YESTERDAY';

        return Database.getQueryLocator(ProductivityDataQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Productivity_Data__c> records){
        for(Productivity_Data__c pData : records){
            if(pData.Account__r.Current_Enrollment_Coordinator__c != null)
                pData.Current_Enrollment_Coordinator__c = pData.Account__r.Current_Enrollment_Coordinator__c;

            if(pData.Account__r.Additional_Enrollment_Coordinator__c != null)
                pData.Additional_Enrollment_Coordinator__c = pData.Account__r.Additional_Enrollment_Coordinator__c;
        }

        // All records should be affected and updated
        update records;
    }

    global void finish(Database.BatchableContext bc){ }  
}