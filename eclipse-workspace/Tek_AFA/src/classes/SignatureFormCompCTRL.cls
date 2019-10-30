public with sharing class SignatureFormCompCTRL {
        
    @AuraEnabled
    public static List<Enrollment_Form__c> getSignatureForms(Id recordId)
    {
        List<Enrollment_Form__c> forms = new List<Enrollment_Form__c>();
        Enrollment_Form__c masterForm = [SELECT Id, Enrollment_Opportunity__c FROM Enrollment_Form__c WHERE Id =: recordId];
                
        forms = [SELECT Id, Status__c, Signature_Form_Name__c, RecordType.Name FROM Enrollment_Form__c 
                 WHERE Enrollment_Opportunity__c =: masterForm.Enrollment_Opportunity__c
                 AND RecordType.Name != 'Master'];
        
        return forms;
    }

}