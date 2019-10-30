trigger customProductivityData on Productivity_Data__c (before insert) {
    
    if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            ProductivityDataBLogic.beforeInsert(trigger.NEW);
        }
    }

}