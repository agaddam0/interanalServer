trigger customCommonOwnershipForm on Common_Ownership_Form__c (before insert) {
    if(trigger.isBefore) {
        if(trigger.isInsert) {
            setupFormBLogic.linkCommonOwnershipFormToOtherExistingFormAsNeeded(trigger.new);
        }
    }
}