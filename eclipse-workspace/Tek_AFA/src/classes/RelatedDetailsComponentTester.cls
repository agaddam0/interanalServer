@isTest
public class RelatedDetailsComponentTester {
	
	@testSetup
    static void testData()
    {
        Colleague__c c = new Colleague__c();
        c.Name = 'Related Details Colleague';
        c.RecordTypeId = Constants.COLLEAGUE_COLLEAGUE;
        insert c;
        
        Standing__c stand = new Standing__c();
        stand.Colleague__c = c.Id;
        stand.Latest_Record__c = true;
        stand.RecordTypeId = Constants.STANDING_PRT;
        insert stand;
    }
    
    @isTest
    static void testRelatedDetailsComponentForStandingRecord()
    {
        Colleague__c colleague = [SELECT Id FROM Colleague__c WHERE Name = 'Related Details Colleague'];
        
        String recordId = RelatedDetailsComponentController.getRelatedRecord('Standing__c', colleague.Id, 'Colleague__c', 'PRT Standing', true);
        
        Standing__c checkReturnedStanding = [SELECT Id FROM Standing__c WHERE Colleague__c =: colleague.Id];
        
        system.assertEquals(checkReturnedStanding.Id, recordId);
    }
}