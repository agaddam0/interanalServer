global class UpdatePolicyholderOwnerBatch implements Database.Batchable<sObject>, Schedulable {
    
    global static void scheduleDailyEveryTwoHours() {
        String dailyEveryTwoHourschedule = '0 0 1/2 * * ?';
        UpdatePolicyholderOwnerBatch batchJob = new UpdatePolicyholderOwnerBatch();
        
        system.schedule('Update Policy Holder Owner Every Two Hours', dailyEveryTwoHourschedule,  batchJob);
    }

    global void execute(SchedulableContext SC) {
        String batchSizeConfig = Label.UpdatePolicyholderOwnerBatchBatchSize;
        Integer batchSize = 200;

        if (String.isNotBlank(batchSizeConfig) &&
            batchSizeConfig.isNumeric()) {
            batchSize = Integer.valueOf(batchSizeConfig);
        }

        Database.executeBatch(new UpdatePolicyholderOwnerBatch(), batchSize);
    }

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(
            'SELECT Id, ' +
            '       OwnerId, ' +
            '       (SELECT Id, ' +
            '               Account__r.OwnerId' +
            '          FROM Products__r' +
            '         WHERE PolicyHolder_Owner_Update_Needed__c = true ' +
            '        ORDER BY LastModifiedDate Desc' +
            '        Limit 1)' +
            '  FROM PolicyHolder__c ' +
            'WHERE Id In (Select PolicyHolder__c ' +
            '               from Purchased_Product__c ' +
            '              where PolicyHolder_Owner_Update_Needed__c = true)'
        );
    }
                
    global void execute(Database.BatchableContext bc, List<PolicyHolder__c> policyHolders)
    {
        List<Policyholder__c> policyholdersToUpdate = new List<Policyholder__c>();
        
        for(Policyholder__c policyHolder : policyHolders) {
            if(policyHolder.Products__r.size() > 0) {
                policyholder.OwnerId = policyHolder.Products__r[0].Account__r.OwnerId;
                policyholdersToUpdate.add(policyholder);
            }
        }
        
        if(policyholdersToUpdate.size() > 0)
            update policyholdersToUpdate;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        system.debug('Update Policyholder Owner Batch Complete');
    }
}