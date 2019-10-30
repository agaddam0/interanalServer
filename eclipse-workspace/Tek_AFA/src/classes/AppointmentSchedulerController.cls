public with sharing class AppointmentSchedulerController {
    @AuraEnabled
    public static List<Account> getEligibleAccounts() {
        return
        [SELECT Id,
                Name,
                Account_Name_with_Alias__c
           FROM Account
          WHERE (Marketing_Resource_ID__c != null)
            AND Status__c != 'Lapsed'
         ORDER BY Name];
    }
    
    @AuraEnabled
    public static EmployerAppointmentSchedulerResponse getEmployerAppointmentSchedulerURL(Id accountId) {
        EmployerAppointmentSchedulerResponse employerResponse = new EmployerAppointmentSchedulerResponse();
        
        try {            
	        ESBFieldSchedulerTokenServiceClient client = new ESBFieldSchedulerTokenServiceClient(accountId);
	
	        ESBFieldSchedulerTokenServiceClient.FieldSchedulerTokenResponse response = client.GetFieldSchedulerToken();
	        
	        if (String.isNotBlank(response.Token)) {
	            employerResponse.EmployerAppointmentSchedulerURL = ESBPreenrollmentMarketingIntegrationUtil.buildEmployerFieldSchedulerURL(response.Token);
	        }
	        else {
	            employerResponse.ErrorMessage = response.ErrorMessage;
	        }
        }
        catch(Exception ex) {
            employerResponse.ErrorMessage = ex.getMessage();
        }
        
        return employerResponse;
    }

    public class EmployerAppointmentSchedulerResponse {
        @AuraEnabled
        public String EmployerAppointmentSchedulerURL { get; set; }
        
        @AuraEnabled
        public String ErrorMessage { get; set; }
        
        public EmployerAppointmentSchedulerResponse() {
            EmployerAppointmentSchedulerURL = '';
            ErrorMessage = '';
        }
    }
}