public with sharing class ESBStatusCheckClient extends ESBServiceBase {
    public static final String CHECK_STATUS_URL_REQUIRED_MESSAGE = 'The check status url is required.';
    
    public static final String SANDBOX_STATUS_CHECKER_API_MANAGER_NAME = 'QA Status Checker';
    public static final String PRODUCTION_STATUS_CHECKER_API_MANAGER_NAME = 'Status Checker';
    public static final String STATUS_CHECKER_INTEGRATION_NAME = 'Status Checker';

    public ESBStatusCheckClient() {
        super(SANDBOX_STATUS_CHECKER_API_MANAGER_NAME, PRODUCTION_STATUS_CHECKER_API_MANAGER_NAME);
    }

    public APICheckStatusResult checkStatus(String esbCheckStatusURL) {
        HttpRequest request;
        HttpResponse response;
        Exception checkStatusException;
        APICheckStatusResult result = new APICheckStatusResult();

        try {
            if (String.isBlank(esbCheckStatusURL)) {
                throw new ESBStatusCheckClientException(CHECK_STATUS_URL_REQUIRED_MESSAGE);
            }

            super.authenticate(STATUS_CHECKER_INTEGRATION_NAME);

            request = buildCheckStatusRequest(esbCheckStatusURL);
            response = new Http().send(request);

            result = buildCheckStatusResult(response);
            
            if (result.Success == false) {
                throw new ESBStatusCheckClientException(result.Message);
            }
        }
        catch(Exception ex) {
            checkStatusException = ex;
            
            result.Success = false;
            result.Message = ex.getMessage();
        }
        finally {
            String contextualInfo = 'Attempting ESB Status Check...\n\n';
            
            if (String.isNotBlank(esbCheckStatusURL)) {
                contextualInfo += 'esbCheckStatusURL: ' + esbCheckStatusURL + '\n\n';
            }

            if (result != null) {
                contextualInfo += 'result.Success: ' + result.Success + '\n';
                contextualInfo += 'result.Message: ' + result.Message + '\n\n';
            }
            
            IntegrationLogger.Instance.addIntegrationLog(STATUS_CHECKER_INTEGRATION_NAME, request, response, checkStatusException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }

        return result;
    }
    
    private HttpRequest buildCheckStatusRequest(String esbCheckStatusURL) {
        HttpRequest request = super.buildAuthorizedHttpRequestTemplate();
        request.setMethod('GET');
        
        API_Manager__c api = super.getAPIManager();

        String endpoint = esbCheckStatusURL;
        
        if (esbCheckStatusURL.startsWith('https://') == false) {
            endpoint = api.Endpoint__c + '/' + esbCheckStatusURL;
        }

        request.setEndpoint(endpoint);
        
        return request;
    }

    private APICheckStatusResult buildCheckStatusResult(HttpResponse response) {
        APICheckStatusResult result = new APICheckStatusResult();

        if (response.getStatusCode() != 200) {
            result.Success = false;
            result.Message = response.getBody();
        }

        return result;
    }
    
    public class APICheckStatusResult {
        public Boolean Success { get; set; }
        
        public String Message { get; set; }
        
        public APICheckStatusResult() {
            Success = true;
            Message = '';
        }
    }
    
    public class ESBStatusCheckClientException extends Exception { }
}