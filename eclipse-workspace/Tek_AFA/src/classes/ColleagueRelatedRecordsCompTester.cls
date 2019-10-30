@isTest
public class ColleagueRelatedRecordsCompTester {
    
    @testSetup
    static void testData()
    {
        List<Colleague__c> colleaguesToInsert = new List<Colleague__c>();
        
        for(integer i = 0; i < 5; i++)
        {
            Colleague__c c = new Colleague__c();
            c.Name = 'Test Colleague ' + i;
            if(math.mod(i,2) == 0)
            	c.RecordTypeId = Constants.COLLEAGUE_COLLEAGUE;
            else
                c.RecordTypeId = Constants.COLLEAGUE_TEAM_OR_DISTRICT;
            
            colleaguesToInsert.add(c);
        }
        
        insert colleaguesToInsert;
    }
	
    @isTest
    private static void TestGetColleagueRelatedRecords()
    {
        Integer howMany = ColleagueRelatedRecordsCompController.ColleagueRelatedRecords().size();
        system.assertEquals(5, howMany);
    }
    
    @isTest
    private static void TestGetAvailableRecordTypes()
    {
        Integer howMany = ColleagueRelatedRecordsCompController.availableRecordTypes().size();
        system.assert(howMany > 0);
    }
    
    @isTest
    private static void TestGetColleagueRelatedRecordsByRecordType()
    {
        Integer howMany = ColleagueRelatedRecordsCompController.ColleaguesByRecordType('Colleague').size();
        system.assertEquals(3, howMany);
    }
    
    @isTest
    private static void TestGetColleagueRelatedRecordsByRecordTypeBlank()
    {
        Integer howMany = ColleagueRelatedRecordsCompController.ColleaguesByRecordType('').size();
        system.assertEquals(5, howMany);
    }
    
    @isTest
    private static void TestGetColleagueRelatedRecordsByName()
    {
        Integer howMany = ColleagueRelatedRecordsCompController.ColleaguesBySearchName('1').size();
        system.assertEquals(1, howMany);
    }
    
    @isTest
    private static void TestGetColleagueRelatedRecordsByNameBlank()
    {
        Integer howMany = ColleagueRelatedRecordsCompController.ColleaguesBySearchName('').size();
        system.assertEquals(5, howMany);
    }
}