public abstract with sharing class ESBServiceBase {
    public static final String SANDBOX_API_MANAGER_NAME_REQUIRED_MESSAGE = 'The sandbox API Manager Name is required.';
    public static final String PRODUCTION_API_MANAGER_NAME_REQUIRED_MESSAGE = 'The production API Manager Name is required.';
    public static final String AUTH_TOKEN_BLANK_ERROR_MESSAGE = 'The auth token is blank.';
    
    public static final String SANDBOX_PREENROLLMENT_MARKETING_API_MANAGER_NAME = 'QA Preenrollment Marketing';
    public static final String PRODUCTION_PREENROLLMENT_MARKETING_API_MANAGER_NAME = 'Preenrollment Marketing';
    public static final String PREENROLLMENT_MARKETING_INTEGRATION_NAME = 'Preenrollment Marketing';
    public static final String SANDBOX_AFPRESS_API_MANAGER_NAME = 'QA AFPress';
    public static final String PRODUCTION_AFPRESS_API_MANAGER_NAME = 'AFPress';
    public static final String AFPRESS_INTEGRATION_NAME = 'AFPress';
    
    public static Organization Organization {
        get {
            return ESBPreenrollmentMarketingIntegrationUtil.Organization;
        }
    }
    
    private String Environment = '';
    private String SandboxAPIManagerName = 'QA Preenrollment Marketing';
    private String ProductionAPIManagerName = 'Prod Preenrollment Marketing';
    
    protected String AuthToken { get; set; }

    public Boolean InsertLogsWhenComplete { get; set; }

    public ESBServiceBase() {
        InsertLogsWhenComplete = true;
    }
    
    public ESBServiceBase(String sandboxAPIManagerNameArg, String productionAPIManagerNameArg) {
        if (String.isBlank(sandboxAPIManagerNameArg)) {
            throw new ESBServiceException(SANDBOX_API_MANAGER_NAME_REQUIRED_MESSAGE);
        }
        
        if (String.isBlank(productionAPIManagerNameArg)) {
            throw new ESBServiceException(PRODUCTION_API_MANAGER_NAME_REQUIRED_MESSAGE);
        }
        
        SandboxAPIManagerName = sandboxAPIManagerNameArg;
        ProductionAPIManagerName = productionAPIManagerNameArg;
        InsertLogsWhenComplete = true;
    }
    
    private API_Manager__c apiManagerPriv = null;
    protected API_Manager__c getAPIManager() {
        if (apiManagerPriv == null) {
            String apiManagerEnvironment = getEnvironment();
            apiManagerPriv = [SELECT Name, Consumer_Key__c, Consumer_Secret__c, Endpoint__c, Host__c, Password__c, Username__c, X_Marketing_Auth__c FROM API_Manager__c WHERE Name = :apiManagerEnvironment];
        }

        return apiManagerPriv;
    }
    
    protected HttpRequest buildAuthorizedHttpRequestTemplate() {
        return buildAuthorizedHttpRequestTemplate(this.AuthToken);
    }
    
    protected HttpRequest buildAuthorizedHttpRequestTemplate(String bearerToken) {
        API_Manager__c api = getAPIManager();
        HttpRequest authorizedRequest = new HttpRequest();
        
        authorizedRequest.setMethod('POST');
        authorizedRequest.setHeader('Content-Type', 'application/json');
        authorizedRequest.setHeader('Authorization', 'Bearer ' + bearerToken);
        authorizedRequest.setTimeout(20000);
        
        if (String.isNotBlank(api.X_Marketing_Auth__c)) {
            authorizedRequest.setHeader('X-Marketing-Auth', api.X_Marketing_Auth__c);
        }
        
        return authorizedRequest;
    }
    
    protected HttpRequest buildAuthorizedSOAPHttpRequestTemplate(String bearerToken, String soapAction) {
        API_Manager__c api = getAPIManager();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + authToken);
        
        request.setTimeout(120000);
        request.setHeader('Content-type', 'text/xml');
        request.setHeader('SOAPAction', soapAction);

        return request;
    }
    
    protected void authenticate(String integrationName) {
        if (String.isBlank(AuthToken)) {
	        ESBAuthenticator authenticator = new ESBAuthenticator(integrationName, SandboxAPIManagerName, ProductionAPIManagerName);
	        authenticator.InsertLogsWhenComplete = false;
	        AuthToken = authenticator.authenticate();
	        
	        if (String.isBlank(AuthToken)) {
	            throw new ESBServiceException(AUTH_TOKEN_BLANK_ERROR_MESSAGE);
	        }
        }
    }
    
    private String getEnvironment() {
        if(String.isBlank(Environment))
        {
            if(Organization.isSandbox)
                Environment = SandboxAPIManagerName;
            else
                Environment = ProductionAPIManagerName;
        }
        
        return Environment;
    }
    
    public class ESBServiceException extends Exception { }
}