public with sharing class ColleagueHelper {
    
    // Set initial values before a colleague record is inserted
    public static void SetColleagueValuesBeforeInsert(List<Colleague__c> newColleagues)
    {
    	SetTeamAndHierarchyLookupToUserValues(newColleagues);
    }
    
    // prior to insert, set the team and heirarchy values from the related users
    // Hierarchy and Team are self lookups to the colleague records
    public static void SetTeamAndHierarchyLookupToUserValues(List<Colleague__c> newColleaguesFromTrigger)
    {
    	List<Id> UserIds = new List<Id>();
    	List<Colleague__c> affectedColleagues = new List<Colleague__c>();
    	Map<Id, String> teamDistrictNames = new Map<Id, String>();
    	Map<Id, Id> userIdtoTeamColId = new Map<Id, Id>();
    	Map<String, Id> teamNameToId = new Map<String, Id>();
    	
    	for(Colleague__c colleague : newColleaguesFromTrigger)
    	{
    		if(colleague.RecordTypeId == Constants.COLLEAGUE_COLLEAGUE)
    		{
    			if(colleague.User__c != null)
    			{
    				userIds.add(colleague.User__c);
    				affectedColleagues.add(colleague);
    			}
    		}
    	}
    	
    	if(userIds.size() < 1)
    	{
            system.debug('No User Ids');
    		// do not process this method further
    		return;
    	}
    	
		// query the team district field off the user    		
		for(User u : [SELECT Team_District__c FROM User WHERE Id IN: userIds])
		{
			if(u.Team_District__c != null)
			{
				teamDistrictNames.put(u.Id, u.Team_District__c);
			}
		}
		
		if(teamDistrictNames.values().size() < 1)
		{
            system.debug('No Team District Names');
			// do not process this method further
			return;
		}
	
		// query for the colleague record that is the team district Name on the user
		for(Colleague__c c : [SELECT Id, Name FROM Colleague__c WHERE Name IN: teamDistrictNames.values()])
		{
			teamNameToId.put(c.Name, c.Id);
		}
		
		if(teamNameToId.values().size() < 1)
		{
            system.debug('No Team Name to Id');
			// do not process this method further
			return;
		}
		
		// set the colleagues called from the trigger values
		for(Colleague__c colleague : affectedColleagues)
    	{
			// teamDistrictNames holds the userId and the associated team district picklist value name
			// teamNameToId holds the team Name and the corresponding colleague Id
			// Thus teamDistrictnames.get(Colleague.User__c) returns the team district name associated to that user
			// Then teamNameToId.get(above) users the team district name to pull the associated colleague id 
			// to populate the lookup value
			
			if( teamNameToId.get(teamDistrictNames.get(colleague.User__c)) != null )
			{
				colleague.Team__c = teamNameToId.get(teamDistrictNames.get(colleague.User__c));
				colleague.Hierarchy__c = teamNameToId.get(teamDistrictNames.get(colleague.User__c));
    		}
		}
    }
    
    public static void SetColleagueTeamAndHierarchyAfterUserUpdate(List<User> newUsers, Map<Id, User> oldMapUsers)
    {
    	Map<Id, String> TeamDistrictNames = new Map<Id, String>();
    	Map<String, Id> TeamColleagues = new Map<String, Id>();
    	List<Colleague__c> colleaguesToUpdate = new List<Colleague__c>();
    	List<Id> userIds = new List<Id>();
    	
    	for(User u : newUsers)
    	{
    		if(u.Team_District__c != oldMapUsers.get(u.Id).Team_District__c)
    		{
    			// The Team or District field changed so we need to update the colleague record
    			TeamDistrictNames.put(u.Id, u.Team_District__c);
    			userIds.add(u.Id);
    		}
    	}
    	
    	if(TeamDistrictNames.values().size() < 1)
    	{
    		// do not process this method further
    		return;
    	}
    	
		for(Colleague__c tColleague :[SELECT Id, Name FROM Colleague__c WHERE Name IN: TeamDistrictNames.values()])
		{
			TeamColleagues.put(tColleague.Name, tColleague.Id);
		}
		
		if(TeamColleagues.values().size() < 1)
		{
			// do not process this method further
			return;
		}
		
		// Put this piece in a future method
		updateColleagueRecords(TeamDistrictNames, TeamColleagues, userIds);		
	} 
    
    @future
    private static void updateColleagueRecords(Map<Id, String> TeamDistrictNames, Map<String, Id> TeamColleagues, List<Id> UserIds)
    {
        List<Colleague__c> colleaguesToUpdate = new List<Colleague__c>();
        
        for(Colleague__c c : [SELECT Id, Name, Team__c, Hierarchy__c, User__c FROM Colleague__c WHERE User__c IN: UserIds])
        {
            c.Team__c = TeamColleagues.get(TeamDistrictNames.get(c.User__c));
            c.Hierarchy__c = TeamColleagues.get(TeamDistrictNames.get(c.User__c));
            colleaguesToUpdate.add(c);
        }
        
        if(colleaguesToUpdate.size() < 1)
        {
            // do not process this method further
            return;
        }
        
        update colleaguesToUpdate;        
    }
}