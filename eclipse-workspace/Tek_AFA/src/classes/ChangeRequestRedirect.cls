public class ChangeRequestRedirect {
    
    public Change_Request__c request	{get;set;}
    
    public ChangeRequestRedirect(ApexPages.StandardController controller)
    {
        request = (Change_Request__c)controller.getRecord();
    }
    
    public pageReference redirect()
    {
        PageReference newPage;
        
        Id ConservationId = Schema.SObjectType.Change_Request__c.getRecordTypeInfosByName().get('Conservation').getRecordTypeId();
        
		if(request.RecordTypeId != ConservationId)
        {
            newPage = new PageReference('/apex/ChangeRequestForm?id=' + request.Policyholder__c + '&ReqNum=' + request.Request_Number__c);
        }
        else
        {
            newPage = new PageReference('/apex/ChangeRequestForm?id=' + request.Policyholder__c + '&ReqNum=' + request.Request_Number__c + '&RType=' + ConservationId);
        }
        
        return newPage;
    }

}