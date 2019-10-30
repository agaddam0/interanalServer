public with sharing class IntegrationLogger {
    public static final String INTEGRATION_LOG_SEVERITY_ERROR = 'Error';
    public static final String INTEGRATION_LOG_SEVERITY_INFO = 'INFO';
    private static final String NEWLINE = '\n'; 
    
    @TestVisible
    private List<Integration_Log__c> Logs = new List<Integration_Log__c>();
    private IntegrationLogFilter Filterer = new IntegrationLogFilter();
    
    public Boolean SkipInsertingLogs = false;
    
    public void addIntegrationLog(String integrationName, HttpRequest request, HttpResponse response, Exception ex) {
        addIntegrationLog(integrationName, request, response, ex, '');
    }
    
    public void addIntegrationLog(String integrationName, HttpRequest request, HttpResponse response, Exception ex, String contextualInfo) {
        addIntegrationLog(integrationName, request, response, ex, contextualInfo, 1);
    }

    public void addIntegrationLog(String integrationName, HttpRequest request, HttpResponse response, Exception ex, String contextualInfo, Integer attemptNumber) {
        Integration_Log__c log = new Integration_Log__c();

        log.Integration__c = integrationName;
        log.Request__c = getFormattedRequest(request);
        log.Response__c = getFormattedResponse(response);
        log.Message__c = getFormattedExceptionMessage(ex);

        if (ex != null) {
            log.Severity__c = INTEGRATION_LOG_SEVERITY_ERROR;
        }

        if (String.isNotBlank(contextualInfo)) {
            log.Contextual_Info__c = contextualInfo;
        }

        log.Attempt_Number__c = attemptNumber;

        if (request != null) {
            log.Endpoint__c = getEndpoint(request);
        }
        
        // If an error occurs in a test, output the error to the debug log
        // so it can easily be found.
        if (Test.isRunningTest() &&
            ex != null) {
            system.debug('    integration log error being logged: ' + log.Message__c);
        }

        Logs.add(log);
    }

    public void addIntegrationLog(String integrationName, String message, String severity, String contextualInfo, String stackTrace) {
        Integration_Log__c log = new Integration_Log__c();
        
        log.Integration__c = integrationName;
        log.Message__c = message;
        log.Severity__c = severity;
        
        if (String.isNotBlank(contextualInfo)) {
            log.Contextual_Info__c = contextualInfo;
        }
        
        if (String.isNotBlank(stackTrace)) {
            log.Stack_Trace__c = stackTrace;
        }

        Logs.add(log);
    }
    
    public void insertLogs() {
        if (Logs.isEmpty() || SkipInsertingLogs) {
            return;
        }
        
        // If the response is too big to log in the "Response" field, log it in an attached
        // file instead.
        Integer maxResponseLength = Integration_Log__c.Response__c.getDescribe().getLength();
        List<Integration_Log__c> tooLargeLogs = new List<Integration_Log__c>();
        List<Integration_Log__c> regularSizeLogs = new List<Integration_Log__c>();

        // Luke: If any other log files are created and attached to the integration log,
        // ensure they also get deleted in the IntegrationLogTriggerHandler when the integration log
        // is deleted and unit tests are written for it.
        
        for (Integration_Log__c log : logs) {
            if (String.isNotBlank(log.Response__c) &&
                log.Response__c.length() > maxResponseLength) {

                tooLargeLogs.add(log);
            }
            // Do the filtering only on smaller logs
            else {
                Filterer.filter(log);
                regularSizeLogs.add(log);
            }
        }

        if (regularSizeLogs.isEmpty() == false) {
            insert regularSizeLogs;
        }

        if (tooLargeLogs.isEmpty() == false) {
            System.enqueueJob(new LogFileInserter(tooLargeLogs, Filterer));
        }
        
        Logs.clear();
    }
    
    public void setFilterer(IntegrationLogFilter filtererArg) {
        if (filtererArg != null) {
            Filterer = filtererArg;
        }
        else {
            Filterer = new IntegrationLogFilter();
        }
    }
    
    private String getFormattedRequest(HttpRequest request) {
        String formattedRequest = '';
        
        if (request == null) {
            return formattedRequest;
        }
        
        formattedRequest =  'Endpoint: ' + request.getEndpoint() + NEWLINE + NEWLINE;
        formattedRequest += 'Method: ' + request.getMethod() + NEWLINE + NEWLINE;
        formattedRequest += 'Content-Type: ' + request.getHeader('Content-Type') + NEWLINE + NEWLINE;
        formattedRequest += 'Authorization: ' + request.getHeader('Authorization') + NEWLINE + NEWLINE;
        formattedRequest += 'X-Marketing-Auth: ' + request.getHeader('X-Marketing-Auth') + NEWLINE + NEWLINE;
        formattedRequest += 'SOAPAction: ' + request.getHeader('SOAPAction') + NEWLINE + NEWLINE;
        formattedRequest += 'Body: ' + request.getBody();
        
        return formattedRequest;
    }

    private String getFormattedResponse(HttpResponse response) {
        String formattedResponse = '';
        
        if (response == null) {
            return formattedResponse;
        }
        
        formattedResponse = 'Status Code: ' + response.getStatusCode() + NEWLINE + NEWLINE;
        formattedResponse += 'Status: ' + response.getStatus() + NEWLINE + NEWLINE;
        
        for (String headerKey : response.getHeaderKeys()) {
            formattedResponse += headerKey + ': ' + response.getHeader(headerKey) + NEWLINE + NEWLINE; 
        }
        
        formattedResponse += 'Body: ' + response.getBody() + NEWLINE + NEWLINE;
        
        
        return formattedResponse;
    }
    
    private String getFormattedExceptionMessage(Exception ex) {
        String formattedException = '';
        
        if (ex == null) {
            return formattedException;
        }
        
        formattedException =  'Error Message: ' + ex.getMessage() + NEWLINE + NEWLINE;
        formattedException += 'Stack Trace: ' + ex.getStackTraceString() + NEWLINE + NEWLINE;
        formattedException += 'Line Number: ' + ex.getLineNumber() + NEWLINE + NEWLINE;
        formattedException += 'Type Name: ' + ex.getTypeName() + NEWLINE + NEWLINE;
        
        return formattedException;
    }
    
    private String getEndpoint(HttpRequest request) {
        Integer maxEndpointLength = Integration_Log__c.Endpoint__c.getDescribe().getLength();
        
        String endpoint = request.getEndpoint().left(maxEndpointLength);
        
        return endpoint;
    }
    
    private IntegrationLogger() { }
    
    public static IntegrationLogger Instance {
        get {
            if (Instance == null) {
                Instance = new IntegrationLogger();
            }
            
            return Instance;
        }
    }
}