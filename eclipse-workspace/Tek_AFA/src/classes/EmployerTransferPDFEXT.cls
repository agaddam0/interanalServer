public class EmployerTransferPDFEXT {
    
    public List<String> AffectedProducts		            {get;set;}
    public Policyholder__c holder							{get;set;}
    public Change_Request__c request						{get;set;}
    
    public EmployerTransferPDFEXT(ApexPages.StandardController ctrl)
    {
        Change_Request__c r = (Change_Request__c)ctrl.getRecord();
        
        request = [SELECT Id,
                       Date_of_Request__c,
                       Effective_Date_of_Transfer__c,
                   	   Group_Policy_Transfer__c,
                       New_Account_Name__c,
                   	   New_Account_Name__r.Name,
                       New_Account_Name__r.MCP_Number__c,
                       Policies_Affected_by_Request_Change__c,
                       Policyholder__c,
                       Policyholder_Customer_Number__c
                   FROM Change_Request__c 
                   WHERE Id =: r.Id];
        
        holder = [SELECT Id,
                      First_Name__c, 
                      Last_Name__c, 
                      Customer_Number__c, 
                      Social_Security_Number__c,
                      Primary_Phone__c,
                      Secondary_Phone__c
                  FROM Policyholder__c
                  WHERE Id =: request.Policyholder__c];        
        
        if(request.Policies_Affected_by_Request_Change__c != null)
        {
            AffectedProducts = request.Policies_Affected_by_Request_Change__c.split(', \n');
        }  
    }
}