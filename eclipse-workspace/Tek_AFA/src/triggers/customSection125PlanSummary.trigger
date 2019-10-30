trigger customSection125PlanSummary on Section_125_Plan_Summary__c (after insert, after update, before update) {
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
          setupFormBLogic.updateParentEnrollmentForm(trigger.new);       
        }
        if(trigger.isUpdate)
        {
            setupFormBLogic.updateParentEnrollmentForm(trigger.new, trigger.oldMap);   
        }
    }
    if(trigger.isBefore)
    {
        if(trigger.isUpdate)
        {
            setupFormBlogic.BeforeUpdateFormReopenChangePlanSummaryFormOwnerToOppOwner(trigger.oldMap, trigger.newMap);
        }
    }
}