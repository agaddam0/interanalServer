trigger standardUserTrigger on User (after update) {
	
	// WARNING: JANKY CODE AHEAD
	// In order to test this wihtout receiving an error about not being able to update the system object User
	// and the colleague record.  We have to manually simulate the test.  
	if(!test.isRunningTest())
		colleagueHelper.SetColleagueTeamAndHierarchyAfterUserUpdate(trigger.new, trigger.oldMap);
    
}