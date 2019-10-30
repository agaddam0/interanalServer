trigger customPlatformSetup on Platform_Setup__c (after insert, after update, before update) {
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            setupFormBLogic.updateParentEnrollmentForm(trigger.new);
            opportunityFormManagement.cloneCoreBenefits(trigger.new);
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
            setupFormBlogic.BeforeUpdateFormReopenChangePlatformOwnerToOppOwner(trigger.oldMap, trigger.newMap);
        }
    }
}