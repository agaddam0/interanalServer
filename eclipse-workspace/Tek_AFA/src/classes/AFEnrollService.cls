public with sharing class AFEnrollService extends ESBServiceBase {
    public static final String SANDBOX_AFENROLL_API_MANAGER_NAME = 'Dev AFEnroll';
    public static final String PRODUCTION_AFENROLL_API_MANAGER_NAME = 'AFEnroll';
    public static final String AFENROLL_INTEGRATION_NAME = 'AFEnroll';
    public static final String ENROLLMENT_SAVE_API_PATH = AFEnroll_Settings__c.getInstance().Save_Case_API_Path__c;
    public static final String REQUEST_CONTEXT_NULL_MSG = 'The request context can not be null.';
    public static final String MAX_MCPS_EXCEEDED_ERROR = 'Enrollment has more then the max MCPs';

    public AFEnrollService() {
        super(SANDBOX_AFENROLL_API_MANAGER_NAME, PRODUCTION_AFENROLL_API_MANAGER_NAME);
    }
    
    public SaveEnrollmentCaseResponse saveEnrollmentCase(SaveEnrollmentCaseRequest requestContext) {
        HttpRequest request;
        HttpResponse response;
        Exception saveException;
        SaveEnrollmentCaseResponse result = new SaveEnrollmentCaseResponse();

        try {
            if (requestContext == null) {
                throw new AFEnrollServiceException(REQUEST_CONTEXT_NULL_MSG);
            }
            
            super.authenticate(AFENROLL_INTEGRATION_NAME);
            request = buildSaveEnrollmentCaseRequest(requestContext);
            
            response = new Http().send(request);
            
            if (response.getStatusCode() == 200) {
                result = buildSaveEnrollmentResult(response);
            }
            // Some unexpected error happened
            else {
                throw new AFEnrollServiceException(response.getBody());
            }
        }
        catch(Exception ex) {
            // A bug came through where if there's more than 10 MCPs, AFEnroll doesn't allow the case to be created.
            // Charlotte Loveland said that's expected and those will be handled manually and no error notification is
            // needed. Don't mark the Max MCPs Exceeded Error as an error. Luke Freeland 3/12/2019
            
            if (ex.getMessage().containsIgnoreCase(MAX_MCPS_EXCEEDED_ERROR) == false) {
                system.debug('  SaveCase  Doesn\'t contain MAX MCPS');
                
                saveException = ex;
                
                result.Success = false;
                result.Message = ex.getMessage();
            }
        }
        finally {
            String contextualInfo = 'Attempting AFEnroll Case Creation...\n\n';
            contextualInfo += requestContext + '\n\n';
            contextualInfo += 'New AFEnroll Case Id: ' + result.AFEnrollCaseId;

            IntegrationLogger.Instance.addIntegrationLog(AFENROLL_INTEGRATION_NAME, request, response, saveException, contextualInfo);

            if (super.InsertLogsWhenComplete) {
                IntegrationLogger.Instance.insertLogs();
            }
        }
        
        return result;
    }
    
    private HttpRequest buildSaveEnrollmentCaseRequest(SaveEnrollmentCaseRequest saveRequest) {
        HttpRequest request = super.buildAuthorizedHttpRequestTemplate(this.AuthToken);
        
        API_Manager__c api = super.getAPIManager();
        String endpoint = api.Endpoint__c + ENROLLMENT_SAVE_API_PATH;
        request.setEndpoint(endpoint);
        request.setTimeout(120000);
        request.setBody( buildSaveEnrollmentCaseRequestBody(saveRequest) );
        
        return request;
    }
    
    @testVisible
    private String buildSaveEnrollmentCaseRequestBody(SaveEnrollmentCaseRequest saveRequest) {
        String enrollmentStartDateString = saveRequest.EnrollmentStartDate != null ? saveRequest.EnrollmentStartDate.format() : '';
        String enrollmentEndDateString = saveRequest.EnrollmentEndDate != null ? saveRequest.EnrollmentEndDate.format() : '';
        String effectiveDateString = saveRequest.EffectiveDateOfAFAProducts != null ? saveRequest.EffectiveDateOfAFAProducts.format() : '';

        String planStartDateString = saveRequest.PlanStartDate != null ? saveRequest.PlanStartDate.format() : '';
        String planEndDateString = saveRequest.PlanEndDate != null ? saveRequest.PlanEndDate.format() : '';

        String body = '{';
        body += '"Id":"",';
        body += '"Name":"' + saveRequest.AccountName + '",';
        body += '"EffectiveDate":"' + effectiveDateString + '",';
        body += '"StartDate":"' + enrollmentStartDateString + '",';
        body += '"EndDate":"' + enrollmentEndDateString + '",';
        body += '"EnrollmentPath":"' + saveRequest.EnrollmentPath + '",';
        body += '"AgentID":"' + saveRequest.AgentId + '",';
        body += '"PrimaryMcp":"' + saveRequest.MCPNumber + '",';

        body += '"PlanYearStartDate":"' + planStartDateString + '",';
        body += '"PlanYearEndDate":"' + planEndDateString + '",';
        body += '"AdditionalMcpsList":[';

        if (String.isNotBlank(saveRequest.AdditionalMCPsCommaSeparated)) {
            String additionalMCPsCleaned = saveRequest.AdditionalMCPsCommaSeparated.replace(', ',',');
            List<String> additionalMCPs = additionalMCPsCleaned.split(',');
            
            if (saveRequest.DedupeAdditionalMCPs != null && saveRequest.DedupeAdditionalMCPs) {
                // Inserting the mcps into a set will dedupe any that are in the list.
                Set<String> dedupedAdditionalMCPs = new Set<String>(additionalMCPs);
                
                // The API service doesn't like the "Primary MCP" being in the list of additional mcps
                // so remove it if present.
                if (dedupedAdditionalMCPs.contains(saveRequest.MCPNumber)) {
                    dedupedAdditionalMCPs.remove(saveRequest.MCPNumber);
                }

                additionalMCPs = new List<String>(dedupedAdditionalMCPs);
            }
            
            if (additionalMCPs != null && additionalMCPs.size() > 0) {
                body += '{"AdditionalMcps": "' + additionalMCPs[0] + '"';
    
                for (Integer i = 1; i < additionalMCPs.size(); ++i) {
                    body += ', "AdditionalMcps": "' + additionalMCPs[i] + '"';
                }
                
                body += '}';
            }
        }

        body += '],';
        body += '"Owner":"' + saveRequest.PlatformOwnerName + '"}';

        return body;

        /*
        {
            "Id": "",
            "Name": "Testing Salesforce",
            "EffectiveDate": "11/15/2018",
            "StartDate": "11/01/2018",
            "EndDate": "11/14/2018",
            "EnrollmentPath":"Full Benefit",
            "AgentID":"1234A",
            "PrimaryMcp":"00179",
            "AdditionalMcps": ["63404","83665"],
            "Owner":"Luke Freeland"
        }
        */
    }
    
    private SaveEnrollmentCaseResponse buildSaveEnrollmentResult(HttpResponse serviceResponse) {
        SaveEnrollmentCaseResponse result = new SaveEnrollmentCaseResponse();
        
        String responseBody = serviceResponse.getBody();
        Map<String, Object> responseMap = (Map<String, Object>)  JSON.deserializeUntyped(responseBody);
        
        result.AFEnrollCaseId = (String) responseMap.get('Id');
        
        return result;
    }
    
    public class SaveEnrollmentCaseRequest {
        @AuraEnabled
        public String MCPNumber { get; set; }
        
        @AuraEnabled
        public String AdditionalMCPsCommaSeparated { get; set; }

        @AuraEnabled
        public String AccountName { get; set; }

        @AuraEnabled
        public String EnrollmentPath { get; set; }

        @AuraEnabled
        public Date EffectiveDateOfAFAProducts { get; set; }

        @AuraEnabled
        public Date EnrollmentStartDate { get; set; }

        @AuraEnabled
        public Date EnrollmentEndDate { get; set; }

        @AuraEnabled
        public Date PlanStartDate { get; set; }

        @AuraEnabled
        public Date PlanEndDate { get; set; }

        @AuraEnabled
        public String AgentId { get; set; }

        @AuraEnabled
        public String PlatformOwnerName { get; set; }
        
        public Boolean DedupeAdditionalMCPs { get; set; }
        
        public SaveEnrollmentCaseRequest() {
            DedupeAdditionalMCPs = false;
        }
    }

    public class SaveEnrollmentCaseResponse {
        @AuraEnabled
        public Boolean Success { get; set; }

        @AuraEnabled
        public String Message { get; set; }

        @AuraEnabled
        public String AFEnrollCaseId { get; set; }

        public SaveEnrollmentCaseResponse() {
            Success = true;
            Message = '';
            AFEnrollCaseId = '';
        }
    }

    public class AFEnrollServiceException extends Exception { }
}