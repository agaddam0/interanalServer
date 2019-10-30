public without sharing class ESBFieldSchedulerTokenServiceClient extends ESBServiceBase {
    public static final String ACCOUNT_ID_REQUIRED_MESSAGE = 'The account id is required.';
    public static final String FIELD_SCHEDULER_TOKEN_PATH = '/marketing/inter-session/store-state/';
    
    private Id AccountId { get; set; }
    
    public ESBFieldSchedulerTokenServiceClient(Id accountIdArg) {
        super(ESBServiceBase.SANDBOX_PREENROLLMENT_MARKETING_API_MANAGER_NAME, ESBServiceBase.PRODUCTION_PREENROLLMENT_MARKETING_API_MANAGER_NAME);
        
        if (accountIdArg == null) {
            throw new ESBFieldSchedulerTokenServiceClientException(ACCOUNT_ID_REQUIRED_MESSAGE);
        }
        
        AccountId = accountIdArg;
    }
    
    public FieldSchedulerTokenResponse GetFieldSchedulerToken() {
        HttpRequest request;
        HttpResponse response;
        Exception e;
        FieldSchedulerTokenResponse tokenResponse = new FieldSchedulerTokenResponse();
        Account employer;
        
        try {
            ESBAuthenticator authenticator = new ESBAuthenticator(ESBServiceBase.PREENROLLMENT_MARKETING_INTEGRATION_NAME, ESBServiceBase.SANDBOX_PREENROLLMENT_MARKETING_API_MANAGER_NAME, ESBServiceBase.PRODUCTION_PREENROLLMENT_MARKETING_API_MANAGER_NAME);
            authenticator.InsertLogsWhenComplete = false;
            String authToken = authenticator.authenticate();
            
            if (String.isBlank(authToken)) {
                tokenResponse.ErrorMessage = 'Failed to authenticate with the Enterprise Service Bus.';
                return tokenResponse;
            }
            
            employer = getAccount();
            
            if (string.isBlank(employer.Marketing_Resource_Id__c)) {
                tokenResponse.ErrorMessage = Label.Appointment_Scheduler_No_Marketing_Resource_Id_Message;
                return tokenResponse;
            }
            
            request = buildTokenRequest(employer, authToken);
            response = new Http().send(request);
            
            if(response == null) {
                tokenResponse.ErrorMessage = 'There was no response from the field scheduler token endpoint.';
                return tokenResponse;
            }
            
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            if (response.getStatusCode() == 200) {
                String status = (String) results.get('Status');
                
                if (String.isNotBlank(status) &&
                    status != 'Ok') {
                    
                    Object errors = results.get('Errors');
                    tokenResponse.ErrorMessage = String.valueOf(errors);
                    throw new ESBFieldSchedulerTokenServiceClientException(tokenResponse.ErrorMessage);
                }
                
                tokenResponse.Token = (String) results.get('Token');
            }
            else {
                Object errors = results.get('Errors');
                tokenResponse.ErrorMessage = String.valueOf(errors);
                throw new ESBFieldSchedulerTokenServiceClientException(tokenResponse.ErrorMessage);
            }
        }
        catch(Exception ex) {
            e = ex;
        }
        finally {
            String contextualInfo = 'Attempting ESB Field Scheduler Token Request...\n\n';

            if (AccountId != null) {
                contextualInfo += 'Account Id: ' + AccountId + '\n\n';
            }

            if (employer != null) {
                contextualInfo += 'employer: ' + employer + '\n\n';
            }

            if (tokenResponse != null) {
                contextualInfo += 'tokenResponse.Token: ' + tokenResponse.Token + '\n';
                contextualInfo += 'tokenResponse.ErrorMessage: ' + tokenResponse.ErrorMessage + '\n\n';
            }
            
            IntegrationLogger.Instance.addIntegrationLog(ESBServiceBase.PREENROLLMENT_MARKETING_INTEGRATION_NAME, request, response, e, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }

        return tokenResponse;
    }
    
    private Account getAccount() {
        return
        [SELECT Id,
                Marketing_Resource_ID__c
           FROM Account
          WHERE Id = :AccountId];
    }
    
    private HttpRequest buildTokenRequest(Account employer, String bearerToken) {
        API_Manager__c api = super.getAPIManager();
        HttpRequest request = super.buildAuthorizedHttpRequestTemplate(bearerToken);
        
        String endpoint = api.Endpoint__c + FIELD_SCHEDULER_TOKEN_PATH;
        request.setEndpoint(endpoint);
        request.setBody( buildFieldSchedulerTokenRequestBody(employer) );
        
        return request;
    }
    
    private String buildFieldSchedulerTokenRequestBody(Account employer) {
        String fieldSchedulerTokenBody = '{';
        
        fieldSchedulerTokenBody += ESBPreenrollmentMarketingIntegrationUtil.buildEmployerKeyJSON(employer) + ', ';
        fieldSchedulerTokenBody += ESBPreenrollmentMarketingIntegrationUtil.buildOnBehalfOfCurrentUserJSON();
        fieldSchedulerTokenBody += '}';
        
        return fieldSchedulerTokenBody;
    }
    
    public class FieldSchedulerTokenResponse {
        public String Token { get; set; }
        
        public String ErrorMessage { get; set; }
        
        public FieldSchedulerTokenResponse() {
            Token = '';
            ErrorMessage = '';
        }
    }
    
    public class ESBFieldSchedulerTokenServiceClientException extends Exception { }
}