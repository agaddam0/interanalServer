@isTest
public class SignatureFormCompCTRLTest {
    
    private static Enrollment_Form__c DefaultOpportunityEnrollmentForm;
    private static Opportunity DefaultOpportunity                           { get; set; }
    
	@testSetup
    static void testData()
    {
        Opportunity opportunity = OpportunityTestData.Instance.insertAFESOpportunity();
        
        Enrollment_Form__c signatureForm = new Enrollment_Form__c();
        signatureForm.Status__c = 'In Progress';
        signatureForm.Auto_Generated__c = false;
        signatureForm.RecordTypeId = Schema.SObjectType.Enrollment_Form__c.getRecordTypeInfosByName().get('Service Exchange Agreement').getRecordTypeId();
        signatureForm.Enrollment_Opportunity__c = opportunity.Id;
        
        insert signatureForm;
    }
    
    private static void loadDefaults() {
        DefaultOpportunity = getDefaultOpportunity();
        DefaultOpportunityEnrollmentForm = loadDefaultOpportunityEnrollmentForm(DefaultOpportunity.Id); 
    }
    
    private static Enrollment_Form__c loadDefaultOpportunityEnrollmentForm(Id oppId) {
        return
            [SELECT Id,
             Name
             FROM Enrollment_Form__c
             WHERE Enrollment_Opportunity__c = :oppId
             AND RecordType.Name = 'Master'];
    }
    
    private static Opportunity getDefaultOpportunity() {
        return
            [SELECT Id,
             Name
             FROM Opportunity];
    }
    
    @isTest
    static void getSignatureFormsTest_ShouldReturnOneForm()
    {
        loadDefaults();
        
        List<Enrollment_Form__c> sigForms = SignatureFormCompCTRL.getSignatureForms(DefaultOpportunityEnrollmentForm.Id);
        
        system.assertEquals(1, sigForms.size(), 'No Signature Form was returned');
    }
}