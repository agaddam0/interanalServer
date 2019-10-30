@isTest
public class ProductivityDataBLogicTest {
    
    public static List<Productivity_Data__c> generateTestData(Integer num, Boolean xCommit)
    {
        List<Productivity_Data__c> pData = new List<Productivity_Data__c>();
        
        for(Integer i = 0; i < num; i++)
        {
            Productivity_Data__c p = new Productivity_Data__c();
            pData.add(p);
        }
        
        if(xCommit)
            insert pData;
        
        return pData;
    }
    
    public static User getAgent(Boolean xCommit)
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='AWD Sales'];
        
        User agent = new User();
        agent.Alias = 'standt';
        agent.Email = 'standarduser@testorg.com'; 
        agent.EmailEncodingKey = 'UTF-8';
        agent.LanguageLocaleKey = 'en_US'; 
        agent.LocaleSidKey='en_US';
        agent.TimeZoneSidKey='America/Los_Angeles';
        agent.UserName = 'TestProductivityData@Test.com';
		agent.FirstName = 'Test Agent';
		agent.LastName = 'Integration Test';
		agent.Agent_ID__c = '1234';
        agent.ProfileId = prof.Id;
        
        if(xCommit)
			insert agent;
        return agent;
    }
    
    public static testMethod void Test01TestIntegrationUserChangeToAgent()
    { 
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Integration User'];
        User intUser = [SELECT Id FROM User WHERE ProfileId =: prof.Id LIMIT 1];
        
        User a = getAgent(true);
        
        List<Productivity_Data__c> pData = generateTestData(5, false);
        
        for(Productivity_Data__c p : pData)
        {
            p.Agent__c = a.Id;
            //p.AgentId__c = a.Agent_ID__c;
            p.OwnerId = intUser.Id;
        }
        Test.startTest();
        system.runAs(intUser)
        {
        	insert pData;
        }
        Test.stopTest();
        
        List<Id> pDataIds = New List<Id>();
        for(Integer i = 0; i < pData.size(); i++)
        {
            pDataIds.add(pData[i].Id);
        }
        
        pData = [SELECT Id, OwnerId, Agent__c FROM Productivity_Data__c WHERE Id IN: pDataIds];
        
        system.assertEquals(a.Id, pData[0].OwnerId);
    }

}