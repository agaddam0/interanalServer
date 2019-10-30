trigger customCustomerSetupForm on Customer_Setup_Form__c (after insert, after update, before update) {

    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            setupFormBLogic.updateParentEnrollmentForm(trigger.new);
            setupFormBLogic.linkCustomerSetupFormCommonOwnersToSection125Forms(trigger.new);
        }
        if(trigger.isUpdate)
        {
            setupFormBLogic.updateParentEnrollmentForm(trigger.new, trigger.oldMap);
            setupFormManagement.CreateFormsFromCustomerSetupAfterUpdate(trigger.new, trigger.oldMap);
        }
    }
    if(trigger.isBefore)
    {
        if(trigger.isUpdate)
        {
            setupFormBlogic.BeforeUpdateFormReopenChangeCustomerFormOwnerToOppOwner(trigger.oldMap, trigger.newMap);
            setupFormBLogic.UpdateFormOwnerToHomeOfficeLoggedInUser(trigger.new, trigger.oldMap);
        }
    }
}