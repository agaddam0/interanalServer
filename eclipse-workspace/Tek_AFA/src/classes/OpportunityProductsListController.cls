public class OpportunityProductsListController {
	@AuraEnabled
    public static List<Marketed_Product__c> getProducts(String opportunityId)
    {
        List<Enrollment_Form__c> eForm = [SELECT Id FROM Enrollment_Form__c 
                                          WHERE Enrollment_Opportunity__c =: opportunityId
                                          AND RecordType.Name = 'master'];
        
        if(eForm.isEmpty() == false)
        {
            List<Marketed_Product__c> products = [SELECT Id, Name FROM Marketed_Product__c 
                                                  WHERE Enrollment__c =: eForm[0].Id
                                                  AND Products__r.Excluded_From_Marketplace__c = false
                                                 ORDER By Name];
            
            return products;
        }
        
        return null;
    }
}