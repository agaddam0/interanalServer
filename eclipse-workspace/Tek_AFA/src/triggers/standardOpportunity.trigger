trigger standardOpportunity on Opportunity (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    // before stuff here
    if( trigger.isBefore )
    {
        if(trigger.isInsert)
        {
            // form rule
            System.debug('$$$ before Insert Opp Trigger');
            OpportunityBLogic.SetAssignedAccountManagerToAccountOwner(trigger.new);
            OpportunityBLogic.setDateFields(trigger.new);
            OpportunityFormRules.setFormBooleans(trigger.new); 
        }
        
        if(trigger.isUpdate)
        {
            
            System.debug('$$$ before Update Opp Trigger');
            OpportunityBLogic.setDateFields(trigger.new);
            OpportunityFormRules.setFormBooleans(trigger.new); 
            new ProjectTaskRecalculator().recalculateTaskDates(trigger.oldMap, trigger.newMap);
        }
        
        if(trigger.isDelete)
        {
            system.debug('$$$ before Delete Opp Trigger');
            OpportunityBLogic.DeleteRelatedEnrollmentOpportunityRecords(trigger.old);
        }
    }
    // after stuff here
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {   
            System.debug('$$$ After Insert Opp Trigger');
            OpportunityBlogic.enrollmentOpptyFormHandler(trigger.new);
        }
        if(trigger.isUpdate)
        {
            System.debug('$$$ after Update Opp Trigger');
            OpportunityBlogic.enrollmentOpptyFormHandler(trigger.new, trigger.oldMap); 
            setupFormBLogic.UpdatePlatformSetupFormStartAndEndDates(trigger.new, trigger.oldMap);
            opportunityBLogic.CreateAccountAssets(trigger.new, trigger.oldMap);
        }
    }
}