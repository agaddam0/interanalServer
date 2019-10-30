trigger standardLeadTrigger on Lead (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	if(trigger.isBefore)
	{
		//do stuff
	}
	
	if(trigger.isAfter)
	{
		
		if(trigger.isUpdate)
		{
			// call apex class
			standardLeadBLogic.createBPRecord(trigger.New);
		}
	}

}