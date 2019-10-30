@isTest
public with sharing class ColleagueHelperTest {
	
	@testSetup
	static void testData()
	{
	    User sysAdminUser = Util.getAnActiveSystemAdministrator();
	    
	    system.runAs(sysAdminUser) {
			Util utility = new Util();
			User u = utility.createOneUser(false, 'colleagueTestUser1@americanfidelity.com', 'Colleague Test With District');
			
			u.Team_District__c = 'Test District';
			insert u;
			
			User u2 = utility.createOneUser(true, 'colleagueTestUser2@americanfidelity.com', 'Colleague Test Without District');
			
			List<Colleague__c> teams = utility.createColleagues(Constants.COLLEAGUE_TEAM_OR_DISTRICT, false, 2);
			teams[0].Name = 'Test District';
			teams[1].Name = 'Test Hierarchy';
			insert teams;
			
			List<Colleague__c> colleagues = utility.createColleagues(Constants.COLLEAGUE_COLLEAGUE, false, 1);
			colleagues[0].User__c = u.Id;
			insert colleagues;
	    }
	}
	
	@isTest
	static void test_Colleague_Team_Heirarchy_Lookups_Populate_With_User_Team_District()
	{
		User u = [SELECT Id FROM User WHERE username = 'colleagueTestUser1@americanfidelity.com' LIMIT 1];
		Colleague__c c = new Colleague__c();
		c.User__c = u.Id;
		c.RecordTypeId = Constants.COLLEAGUE_COLLEAGUE;
		
		test.startTest();
		
		insert c;
		
		test.stopTest();
		
		Colleague__c teamColleague = [SELECT Id FROM Colleague__c where Name = 'Test District'];
		Colleague__c userColleague = [SELECT Id, Team__c FROM Colleague__c WHERE Id =: c.Id];
		
		system.assertEquals(teamColleague.Id, userColleague.Team__c);
	}
	
	@isTest
	static void test_User_Team_Update_Updates_Colleague_Team_Heirarchy()
	{
		// simulate the trigger call in order to avoid below error that only happens during testing
		// ERROR:  MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have 
		// updated a non-setup object (or vice versa): Colleague__c, original object: User: []
		
		User u = [SELECT Id, Team_District__c FROM User WHERE UserName = 'colleagueTestUser1@americanfidelity.com' LIMIT 1];
		User clonedUser = u.clone(true, true, true);
		u.Team_District__c = 'Test Hierarchy';
		
		List<User> triggerList = new List<User>();
		Map<Id, User> triggerMap = new Map<Id, User>();
		
		triggerList.add(u);
		triggerMap.put(clonedUser.Id, clonedUser);
		
		test.startTest();
		
		ColleagueHelper.SetColleagueTeamAndHierarchyAfterUserUpdate(triggerList, triggerMap);
		
		test.stopTest();
		
		Colleague__c updatedColleague = [SELECT Id, Team__r.Name, Hierarchy__r.Name, User__c FROM Colleague__c where User__c =: u.Id LIMIT 1];
		
		system.assertEquals('Test Hierarchy', updatedColleague.Team__r.Name);
		
	}
	
	@isTest
	static void test_ProTrax_Landing_Page_With_Colleague_Record()
	{
		PageReference pageRef = Page.ProTraxRedirectLandingPage;
		Test.setCurrentPage(pageRef);
		
		PageReference landing;
		
		User u = [SELECT Id, Team_District__c FROM User WHERE UserName = 'colleagueTestUser1@americanfidelity.com' LIMIT 1];
		
		Colleague__c c = new Colleague__c();
				
		ApexPages.StandardController ctrl = new ApexPages.StandardController(c);
		ProTraxRedirectLandingPage ProTrax = new ProTraxRedirectLandingPage(ctrl);
		
		test.startTest();
		
			system.runAs(u)
			{
				landing = ProTrax.redirect();
			}
			
			test.stopTest();
		
		system.assertNotEquals(null, landing);	
	
	}
	
	@isTest
	static void test_ProTrax_Landing_Page_WithOUT_Colleague_Record()
	{
		PageReference pageRef = Page.ProTraxRedirectLandingPage;
		Test.setCurrentPage(pageRef);
		
		PageReference landing;
		
		User u = [SELECT Id, Team_District__c FROM User WHERE UserName = 'colleagueTestUser2@americanfidelity.com' LIMIT 1];
		
		Colleague__c c = new Colleague__c();
				
		ApexPages.StandardController ctrl = new ApexPages.StandardController(c);
		ProTraxRedirectLandingPage ProTrax = new ProTraxRedirectLandingPage(ctrl);
		
		test.startTest();
		
			system.runAs(u)
			{
				landing = ProTrax.redirect();
			}
			
			test.stopTest();
		
		system.assertEquals(null, landing);	
	
	}
    
}