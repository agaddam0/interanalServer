trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after delete) {
    
    if(trigger.isAfter)
    {
        if(trigger.isInsert)
        {
            CopayInformationHelper.updateCopayFilesRollupField(trigger.new);
        }
    }

}