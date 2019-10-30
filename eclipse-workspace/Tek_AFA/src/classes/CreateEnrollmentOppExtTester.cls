@isTest
public class CreateEnrollmentOppExtTester {
    
    @testSetup
    static void testData()
    {
        Util u = new Util(); 
        Account a = u.createOneAcc('Test Account', true, Constants.ACCOUNT_PROSPECT);
        Opportunity o = u.createOneOpp('Test Opp', 'Closed Won', a.Id, true, Constants.OPPORTUNITY_AWD_NEW_GROUP);
        Opportunity oppNotClosed = u.createOneOpp('Test Opp', 'Prospecting', a.Id, true, Constants.OPPORTUNITY_AFES_NEW_GROUP);
    }
    
    public static testMethod void AuraTestForCreateEnrollmentOpp()
    {
        Opportunity o = [SELECT Id, StageName, AccountId, Plan_Date_New__c, Division__c, Estimated_Employees__c, Enrollment_AP_Goal__c,
                         RecordTypeId, Confirm_New_or_Existing_Group__c, CloseDate, Name, isWon
                         FROM Opportunity 
                         WHERE isWon = true];
        
        Opportunity newOpp = CreateEnrollmentOppComponent.createEnrollmentOpportunity(o.Id);
        
        Opportunity newOppQueried = [SELECT Id, RecordTypeId FROM Opportunity WHERE Id =: newOpp.Id Order By CreatedDate desc LIMIT 1];
        system.assertEquals(newOppQueried.Id, newOpp.Id);
        system.assertEquals(Constants.OPPORTUNITY_AWD_ENROLLMENT, newOpp.RecordTypeId);
    }
    
    public static testMethod void AuraTestForCreateEnrollmentOppNotClosedWon()
    {
        Opportunity o = [SELECT Id, StageName, AccountId, Plan_Date_New__c, Division__c, Estimated_Employees__c, Enrollment_AP_Goal__c,
                         RecordTypeId, Confirm_New_or_Existing_Group__c, CloseDate, Name, IsWon
                         FROM Opportunity 
                         WHERE isWon = false];
        
        Opportunity newOpp = CreateEnrollmentOppComponent.createEnrollmentOpportunity(o.Id);
        system.assertEquals(null, newOpp);
    }
    
    public static testMethod void AuraTestForCreateEnrollmentOpp_CoAdminReturnOpportunitySent()
    {
        Opportunity o = [SELECT Id, StageName, AccountId, Plan_Date_New__c, Division__c, Estimated_Employees__c, Enrollment_AP_Goal__c,
                         RecordTypeId, Confirm_New_or_Existing_Group__c, CloseDate, Name, IsWon, Co_Admin_Group__c
                         FROM Opportunity 
                         WHERE isWon = true];
        
        o.Co_Admin_Group__c = true;
        
        update o;
        
        Opportunity updatedOpp = [SELECT Id, StageName, AccountId, Plan_Date_New__c, Division__c, Estimated_Employees__c, Enrollment_AP_Goal__c,
                         RecordTypeId, Confirm_New_or_Existing_Group__c, CloseDate, Name, IsWon, Co_Admin_Group__c
                         FROM Opportunity 
                         WHERE isWon = true];
        
        Opportunity newOpp = CreateEnrollmentOppComponent.createEnrollmentOpportunity(updatedOpp.Id);
        
        system.assertEquals(updatedOpp.Id, newOpp.Id);
    }
    
    public static testMethod void AuraTestForCreateEnrollmentOpp_exceptionThrown()
    {
        try
        {
            Opportunity newOpp = CreateEnrollmentOppComponent.createEnrollmentOpportunity(null);
            system.assert(false, 'An error should have been thrown');
        } 
        catch(AuraHandledException e)
        {
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}