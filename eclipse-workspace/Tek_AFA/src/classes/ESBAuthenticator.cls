public class ESBAuthenticator extends ESBServiceBase {
    public static final String INTEGRATION_NAME_REQUIRED_MESSAGE = 'The integration name is required.';
    public static final String ENDPOINT_PATH = '/token';
        
    private String IntegrationName { get; set; }
    
    public ESBAuthenticator(String integrationNameArg, String sandboxAPIManagerNameArg, String productionAPIManagerNameArg) {
        super(sandboxAPIManagerNameArg, productionAPIManagerNameArg);
        
        setIntegrationName(integrationNameArg);
    }

    public String authenticate() {
        HttpRequest request;
        HttpResponse response;
        Exception authException;
        
        try {
	        Http http = new Http();
	        request = buildAuthenticationRequest();
	        response = http.send(request);
	        
	        if(response.getStatusCode() == 200)
	        {
	            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
	            return (string) results.get('access_token');
	        }
        }
        catch(Exception ex) {
            authException = ex;
        }
        finally {
            IntegrationLogger.Instance.addIntegrationLog(IntegrationName, request, response, authException);
            
            if (InsertLogsWhenComplete) {
                IntegrationLogger.Instance.insertLogs();
            }
        }

        return '';
    }
    
    private void setIntegrationName(String integrationNameArg) {
        if (String.isBlank(integrationNameArg)) {
            throw new ESBAuthenticatorException(INTEGRATION_NAME_REQUIRED_MESSAGE);
        }
        
        this.IntegrationName = integrationNameArg;
    }
    
    private HttpRequest buildAuthenticationRequest() {
        API_Manager__c api = super.getAPIManager();
        
        Blob headerValue = Blob.valueOf(api.Consumer_Key__c + ':' + api.Consumer_Secret__c);
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String endpointHeader = api.Endpoint__c + ENDPOINT_PATH;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointHeader);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization', authHeader);
        
        String urlEncodedUsername = EncodingUtil.urlEncode(api.Username__c, 'UTF-8');
        String urlEncodedPassword = EncodingUtil.urlEncode(api.Password__c, 'UTF-8');
        
        request.setBody( 'grant_type=password&username=' + urlEncodedUsername + '&password='+urlEncodedPassword );
        request.setTimeout(20000);
        
        return request;
    }
    
    public class ESBAuthenticatorException extends Exception { }
}