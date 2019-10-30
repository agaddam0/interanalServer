trigger customSection125SetupForm on Section_125_Setup_Form__c (after insert, after update, before update, before insert) {
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            setupFormBLogic.updateParentEnrollmentForm(trigger.new);
            setupFormBlogic.linkSection125FormCommonOwnersToCustomerSetupForms(trigger.new);       
        }
        if(trigger.isUpdate)
        {
            setupFormBLogic.updateParentEnrollmentForm(trigger.new, trigger.oldMap);
            setupFormBLogic.syncSection125(trigger.new, trigger.oldMap);
            SetupFormManagement.CreateFormsFromSection125AfterUpdate(trigger.new, trigger.oldMap);
        }
    }
    if(trigger.isBefore)
    {
        if(trigger.isUpdate)
        {
            setupFormBlogic.BeforeUpdateFormReopenChangeSection125OwnerToOppOwner(trigger.oldMap, trigger.newMap);
            setupFormBLogic.UpdateFormOwnerToHomeOfficeLoggedInUser(trigger.new, trigger.oldMap);
        }
        if(trigger.isInsert)
        {
            setupFormBlogic.setSection125PrimaryField(trigger.new);
        }
    }
}