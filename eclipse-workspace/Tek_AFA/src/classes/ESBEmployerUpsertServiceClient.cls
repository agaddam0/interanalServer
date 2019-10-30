public without sharing class ESBEmployerUpsertServiceClient extends ESBServiceBase {
    public static final String ENROLLMENT_OPPORTUNITY_ID_REQUIRED_MESSAGE = 'The enrollment opportunity id is required.';
    public static final String EMPLOYER_UPSERT_PATH = '/salesforce/integration/marketing/employer-upsert/';

    private Id EnrollmentOpportunityId { get; set; }
    private Boolean authTokenIsBlank = false;

    public ESBEmployerUpsertServiceClient(Id enrollmentOpportunityIdArg) {
        super(ESBServiceBase.SANDBOX_PREENROLLMENT_MARKETING_API_MANAGER_NAME, ESBServiceBase.PRODUCTION_PREENROLLMENT_MARKETING_API_MANAGER_NAME);
        
        if (enrollmentOpportunityIdArg == null) {
            throw new ESBEmployerUpsertServiceClientException(ENROLLMENT_OPPORTUNITY_ID_REQUIRED_MESSAGE);
        }
        
        EnrollmentOpportunityId = enrollmentOpportunityIdArg;
    }

    public void UpsertEmployer() {
        HttpRequest request;
        HttpResponse response;
        Exception upsertEmployerException;
        Opportunity enrollmentOpportunity;
        
        try {
            ESBAuthenticator authenticator = new ESBAuthenticator(ESBServiceBase.PREENROLLMENT_MARKETING_INTEGRATION_NAME, ESBServiceBase.SANDBOX_PREENROLLMENT_MARKETING_API_MANAGER_NAME, ESBServiceBase.PRODUCTION_PREENROLLMENT_MARKETING_API_MANAGER_NAME);
            authenticator.InsertLogsWhenComplete = false;
            String authToken = authenticator.authenticate();
            authTokenIsBlank = String.isBlank(authToken);
            
            if (authTokenIsBlank) {
                return;
            }
            
            enrollmentOpportunity = getEnrollmentOpportunity();
            
            request = buildEmployerAgentRequest(enrollmentOpportunity, authToken);
            response = new Http().send(request);
            
            if(response == null) {
                return;
            }
            
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            if (response.getStatusCode() == 200) {
                String status = (String) results.get('Status');
                
                if (String.isNotBlank(status) &&
                    status != 'Ok') {
                    Object errors = results.get('Errors');
                    throw new ESBEmployerUpsertServiceClientException(String.valueOf(errors));
                }
            }
            else {
                Object errors = results.get('Errors');
                throw new ESBEmployerUpsertServiceClientException(String.valueOf(errors));
            }
        }
        catch(Exception ex) {
            upsertEmployerException = ex;
        }
        finally {
            String contextualInfo = 'Attempting ESB Employer Upsert...\n\n';

            if (EnrollmentOpportunityId != null) {
                contextualInfo += 'Enrollment Opportunity Id: ' + EnrollmentOpportunityId + '\n\n';
            }

            if (authTokenIsBlank) {
                contextualInfo += 'No authentication token was returned from the ESB token API.\n\n';
            }

            if (enrollmentOpportunity != null) {
                contextualInfo += 'Enrollment Opportunity: ' + enrollmentOpportunity + '\n\n';
            }

            IntegrationLogger.Instance.addIntegrationLog(ESBServiceBase.PREENROLLMENT_MARKETING_INTEGRATION_NAME, request, response, upsertEmployerException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }
    }
    
    private Opportunity getEnrollmentOpportunity() {
        return
        [SELECT Id,
                Name,
                AccountId,
                Account.Name,
                Account.BillingState,
                Account.MCP_Number__c,
                Account.Marketing_Resource_ID__c,
                Group_Display_Name__c,
                Assigned_Account_Manager__c,
                Assigned_Account_Manager__r.FirstName,
                Assigned_Account_Manager__r.LastName,
                Assigned_Account_Manager__r.Street,
                Assigned_Account_Manager__r.City,
                Assigned_Account_Manager__r.State,
                Assigned_Account_Manager__r.PostalCode,
                Assigned_Account_Manager__r.Email,
                Assigned_Account_Manager__r.Extension,
                Assigned_Account_Manager__r.Id,
                Assigned_Account_Manager__r.Title,
                Assigned_Account_Manager__r.Agent_Id__c,
                Assigned_Account_Manager__r.Job_Title__c,
                Assigned_Account_Manager__r.License_No__c,
                Branch_Office__c,
                Branch_Office__r.Name,
                Branch_Office__r.Address__c,
                Branch_Office__r.Charge_Code__c,
                Branch_Office__r.City__c,
                Branch_Office__r.Copy_Code__c,
                Branch_Office__r.Extension__c,
                Branch_Office__r.Fax__c,
                Branch_Office__r.Local_Phone__c,
                Branch_Office__r.Mailing_Code__c,
                Branch_Office__r.Resource_ID__c,
                Branch_Office__r.Staffed__c,
                Branch_Office__r.State__c,
                Branch_Office__r.Toll_Free_Phone__c,
                Branch_Office__r.Zip__c,
                OwnerId
           FROM Opportunity
          WHERE Id = :EnrollmentOpportunityId];
    }
    
    private HttpRequest buildEmployerAgentRequest(Opportunity enrollmentOpportunity, String bearerToken) {
        API_Manager__c api = super.getAPIManager();
        
        HttpRequest request = super.buildAuthorizedHttpRequestTemplate(bearerToken);
        
        string endpointHeader = api.Endpoint__c + EMPLOYER_UPSERT_PATH;
        request.setEndpoint(endpointHeader);
        
        request.setBody( buildEmployerAgentRequestBody(enrollmentOpportunity) );
        
        return request;
    }
    
    private String buildEmployerAgentRequestBody(Opportunity enrollmentOpportunity) {
        String employerAgentBody = '{';
        
        system.debug('    buildEmployerAgentRequestBody::enrollmentOpportunity ' + enrollmentOpportunity);
        
        employerAgentBody += '"Employer":{' +
                               buildPropertyJSONWithComma('MasterContractParticipantNumber', enrollmentOpportunity.Account.MCP_Number__c) +
                               buildPropertyJSONWithComma('Name', enrollmentOpportunity.Group_Display_Name__c) +
                               ESBPreenrollmentMarketingIntegrationUtil.buildEmployerRecordKeyJSON(enrollmentOpportunity) + ', ' +
                               buildPropertyJSON('StateCode', enrollmentOpportunity.Account.BillingState) +
                            '}, ';
        
        employerAgentBody += buildAgentJSON(enrollmentOpportunity) + ', ';
        employerAgentBody += buildOnBehalfOfJSON(enrollmentOpportunity);
        employerAgentBody += '}';
        
        return employerAgentBody;
    }
    
    private String buildAgentJSON(Opportunity enrollmentOpportunity) {
        return ESBPreenrollmentMarketingIntegrationUtil.buildAgentJSON(enrollmentOpportunity);
    }
    
    private String buildBranchJSON(Opportunity enrollmentOpportunity) {
        return ESBPreenrollmentMarketingIntegrationUtil.buildBranchJSON(enrollmentOpportunity);
    }
    
    private String buildRecordKeyJSON(String sourceSystem, String sourceKey) {
        return ESBPreenrollmentMarketingIntegrationUtil.buildRecordKeyJSON(sourceSystem, sourceKey);
    }
    
    private String buildOnBehalfOfJSON(Opportunity enrollmentOpportunity) {
        return ESBPreenrollmentMarketingIntegrationUtil.buildOnBehalfOfJSON(enrollmentOpportunity);
    }
    
    private String buildPropertyJSONWithComma(String propertyName, Object propertyValue) {
        return ESBPreenrollmentMarketingIntegrationUtil.buildPropertyJSONWithComma(propertyName, propertyValue);
    }
    
    private String buildPropertyJSON(String propertyName, Object propertyValue) {
        return ESBPreenrollmentMarketingIntegrationUtil.buildPropertyJSON(propertyName, propertyValue);
    }
    
    public class ESBEmployerUpsertServiceClientException extends Exception { }
}