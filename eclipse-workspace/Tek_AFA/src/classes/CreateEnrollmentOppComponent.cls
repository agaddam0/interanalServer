public with sharing class CreateEnrollmentOppComponent {
    
    @AuraEnabled
    public static Opportunity createEnrollmentOpportunity(Id newGroupOppId)
    {
        try {
            Opportunity newGroupOppLtng = [SELECT Id, IsWon, 
                                           StageName, 
                                           Plan_Date_New__c, 
                                           Estimated_Employees__c, 
                                           AccountId, Division__c, 
                                           Estimated_Premium__c,
                                           Co_Admin_Group__c
                                           FROM Opportunity 
                                           WHERE Id =: newGroupOppId];
            
            if(newGroupOppLtng.IsWon)
            {
                // just return the New Group Opportunity, do not create a enw Enrollment Opp
                if(newGroupOppLtng.Co_Admin_Group__c)
                    return newGroupOppLtng;
                
                // this creates the Enrollment Opportunity
                Opportunity newEnrollOpp = new Opportunity();
                newEnrollOpp.AccountId = newGroupOppLtng.AccountId;
                newEnrollOpp.Plan_Date_New__c = newGroupOppLtng.Plan_Date_New__c;
                newEnrollOpp.Division__c = newGroupOppLtng.Division__c;
                newEnrollOpp.Estimated_Employees__c = newGroupOppLtng.Estimated_Employees__c;
                newEnrollOpp.Enrollment_AP_Goal__c = newGroupOppLtng.Estimated_Premium__c;
                newEnrollOpp.Co_Admin_Group__c = newGroupOppLtng.Co_Admin_Group__c;
                
                if(newGroupOppLtng.Division__c == 'AWD')
                    newEnrollOpp.RecordTypeId = Constants.OPPORTUNITY_AWD_ENROLLMENT;
                if(newGroupOppLtng.Division__c == 'AFES')
                    newEnrollOpp.RecordTypeId = Constants.OPPORTUNITY_AFES_ENROLLMENT;
                
                newEnrollOpp.Confirm_New_or_Existing_Group__c = 'New';
                newEnrollOpp.Name = 'New Enrollment Opportunity';
                newEnrollOpp.StageName = 'Enrollment';
                newEnrollOpp.CloseDate = system.today().addDays(30);
                
                insert newEnrollOpp;
                
                return newEnrollOpp;
            }
            else
            {
                return null;
            }
        }
        catch (Exception e) {
            system.debug('ERROR: ' + e.getMessage());
            
            CustomExceptionData data;
            data = new CustomExceptionData('Unable to Onboard', 'An unexpected error happened, please contact your System Administrator', 050);
            throw new AuraHandledException(JSON.serialize(data));
        }
    }
}