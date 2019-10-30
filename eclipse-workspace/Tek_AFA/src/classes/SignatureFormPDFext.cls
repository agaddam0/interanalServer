public class SignatureFormPDFext {

    public Enrollment_Form__c eForm {get;set;}
    public Attachment signature		{get;set;}
    
    public SignatureFormPDFext(ApexPages.StandardController ctrl)
    {
        Id formId = ctrl.getId();
        
        eForm = [SELECT Id,
					Status__c,
					Name,
					Enrollment_Opportunity__c,
					Other__c,
					Title__c,
					Printed_Signature__c,
					Day__c,
					Month__c,
					Year__c,
					Physical_Address_Street__c,
					Physical_Address_State__c,
					Physical_Address_City__c,
					Effective_Date_of_AFA_Products__c ,
					Physical_Address_Zip_Code__c,
					Legal_Name_Text__c,
					Digital_Signature__c,
					RecordType.DeveloperName,
             		Signature_Form_Name__c,
                 	Enrollment_Opportunity__r.Account.Name,
                 	Enrollment_Opportunity__r.Account.MCP_Number__c,
             		Enrollment_Opportunity__r.Account.BillingStreet,
             		Enrollment_Opportunity__r.Account.BillingCity,
             		Enrollment_Opportunity__r.Account.BillingState,
             		Enrollment_Opportunity__r.Account.BillingPostalCode,
                 	Enrollment_Opportunity__r.Division__c,
                 	Enrollment_Opportunity__r.Effective_Date_of_AFA_Products__c,
             		Common_Ownership__c
                FROM Enrollment_Form__c
                WHERE Id =: formId];
        
        List<Attachment> atts = [SELECT Id FROM Attachment WHERE ParentId =: formId AND Name= 'SignaturePDF.png'];
        if(atts.size() > 0)
        	signature = atts[0];
        
    }
}