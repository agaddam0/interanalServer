trigger customColleagueTrigger on Colleague__c (before insert) {
	
	if(trigger.isBefore)
	{
		// initialize the team and hierarchy values off the related user record
		ColleagueHelper.SetColleagueValuesBeforeInsert(trigger.new);
	}
}