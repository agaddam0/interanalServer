public class UploadedSignatureHelper {
    
    public static Enrollment_Form__c enrollmentForm;
    
    public static void UpdateSignatureFormStatusOnSignatureUpload(Id enrollmentId)
    {
        if(enrollmentForm == null || enrollmentId != enrollmentForm.Id)
        	enrollmentForm = [SELECT Signature_Form_Name__c, Status__c, RecordTypeId, RecordType.Name, Enrollment_Opportunity__r.AccountId FROM Enrollment_Form__c WHERE Id =: enrollmentId];
        
        if(enrollmentForm != null && enrollmentForm.RecordType.Name != 'Master' && enrollmentForm.Status__c == 'In Progress')
        {
            enrollmentForm.Status__c = 'Submitted via Upload';
            
            update enrollmentForm;
            
            if(enrollmentForm.RecordTypeId == Constants.SIGNATURE_SERVICE_EXCHANGE_AGREEMENT)
                UpdateAccountOnServiceExchangeSubmitted(enrollmentForm.Enrollment_Opportunity__r.AccountId);
        }
    }
    
    public static String ChangeUploadedSignatureFormTitle(Id objectId, String fileName)
    {
        String objectName = objectId.getSobjectType().getDescribe().getName();
        
        system.debug(objectName);
        
        if(objectName == 'Enrollment_Form__c')
        {
            if(enrollmentForm == null || enrollmentForm.Id != objectId)
                enrollmentForm = [SELECT Signature_Form_Name__c, Status__c, RecordTypeId, RecordType.Name, Enrollment_Opportunity__r.AccountId FROM Enrollment_Form__c WHERE Id =: objectId];
            
            if(enrollmentForm.RecordType.Name != 'Master')            
            	fileName = enrollmentForm.Signature_Form_Name__c + '_Signed';            
        }
        
        return fileName;
    }
    
    public static void UpdateSignatureFormStatusOnSignatureDelete(Id enrollmentId)
    {
        if(enrollmentForm == null || enrollmentId != enrollmentForm.Id)
        	enrollmentForm = [SELECT Signature_Form_Name__c, Status__c, RecordTypeId, RecordType.Name, Enrollment_Opportunity__r.AccountId FROM Enrollment_Form__c WHERE Id =: enrollmentId];
        
        if(enrollmentForm != null && enrollmentForm.RecordType.Name != 'Master' && enrollmentForm.Status__c == 'Submitted via Upload')
        {
            enrollmentForm.Status__c = 'In Progress';
            
            update enrollmentForm;            
        }
    }
    
    public static void UpdateAccountOnServiceExchangeSubmitted(Id AccountId)
    {
        Account a = [SELECT Id, In_Kind_Service_Agreement__c FROM Account WHERE Id =: AccountId];
        
        if(!a.In_Kind_Service_Agreement__c)
        {
            a.In_Kind_Service_Agreement__c = true;
            update a;
        }
    }
}