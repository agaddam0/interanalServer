trigger ContentDocumentTrigger on ContentDocument (before delete) {
    
    if(trigger.isBefore)
    {
        if(trigger.isDelete)
        {
            CopayInformationHelper.updateCopayFilesRollupField(trigger.old);
        }
    }

}