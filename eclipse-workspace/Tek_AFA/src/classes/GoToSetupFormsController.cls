public class GoToSetupFormsController {
	
    @AuraEnabled
    public static Opportunity getOpportunity(String opportunityId) {
        List<Opportunity> enrollmentOpps = [SELECT Id, Significant_Setup_Changes__c, Simple_Setup_Changes__c  FROM Opportunity 
                                            WHERE (RecordTypeId =: Constants.OPPORTUNITY_AFES_ENROLLMENT OR RecordTypeId =: Constants.OPPORTUNITY_AWD_ENROLLMENT)
                                            AND Id =: opportunityId
                                            ORDER By CreatedDate DESC];
        
        if(enrollmentOpps.size() > 0)
            return enrollmentOpps[0];
        else
            return null;
    }
}