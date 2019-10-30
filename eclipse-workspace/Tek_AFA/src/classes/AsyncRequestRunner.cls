public without sharing class AsyncRequestRunner implements queueable, Database.AllowsCallouts {
    private static String NEWLINE = '\n';
    private static Boolean AlreadyStarted = false;
    
    public static void startJob() {
        // LF 1/27/2018: If an operation inserts another async request,
        // another job will be started and then this job will try to start one too,
        // which is not allowed because a queueable job can only have one child queueable.
        // This code was added to only allow one async request runner job started per context.
        
        if (AlreadyStarted == false) {
	        System.enqueueJob(new AsyncRequestRunner());
	        AlreadyStarted = true;
        }
    }

    public void execute(QueueableContext context) {
        // Don't run if an admin has disabled the runner. Also,
        // only allow one runner to run at a time to avoid
        // concurrency issues.
        if(isAsyncRequestRunnerEnabled() == false ||
           alreadyRunning(context)) {
            return;
        }
        
        List<Async_Request__c> requests = getAsyncRequests();
        
        if (requests.isEmpty()) {
            return;
        }
        
        Async_Request__c currentRequest = requests[0];

        executeAsyncRequest(currentRequest);

        enqueueNextRunner(currentRequest.Id);
    }
    
    private void executeAsyncRequest(Async_Request__c currentRequest) {
        try {
            Type requestHandlerType = Type.forName(currentRequest.Operation_Class__c);
            
            IAsyncRequestHandler requestHandler = (IAsyncRequestHandler) requestHandlerType.newInstance();
            
            requestHandler.handleRequest(currentRequest);
            
            delete currentRequest;
        }
        catch (Exception ex) {
            currentRequest.Status__c = 'Error';
            currentRequest.Error_Message__c = getErrorMessage(ex);
            update currentRequest;
        }
    }
    
    private Boolean isAsyncRequestRunnerEnabled() {
        Async_Request_Runner_Settings__c settings = Async_Request_Runner_Settings__c.getOrgDefaults();
        
        system.debug('    isAsyncRequestRunnerEnabled::settings ' + settings);
        
        return settings != null && settings.Enabled__c == true;
    }

    private Boolean alreadyRunning(QueueableContext context) {
        Id jobId = context.getJobId();
        
        List<AsyncApexJob> runningAsyncRunners =
        [SELECT Id
           FROM AsyncApexJob
          WHERE Id <> :jobID
            AND Status in ('Preparing', 'Processing')
            AND ApexClass.Name = 'AsyncRequestRunner'];
        
        return runningAsyncRunners.size() > 0;
    }
    
    private List<Async_Request__c> getAsyncRequests() {
        return
        [Select Id,
                Operation_Class__c,
                Parameters__c,
                Status__c,
                Error_Message__c,
                Attempt_Number__c
           from Async_Request__c 
          where Status__c = 'Not Started'
          Limit 1 for update];
    }
    
    private String getErrorMessage(Exception ex) {
        String formattedException = '';
        
        formattedException =  'Error Message: ' + ex.getMessage() + NEWLINE + NEWLINE;
        formattedException += 'Stack Trace: ' + ex.getStackTraceString() + NEWLINE + NEWLINE;
        formattedException += 'Line Number: ' + ex.getLineNumber() + NEWLINE + NEWLINE;
        formattedException += 'Type Name: ' + ex.getTypeName() + NEWLINE + NEWLINE;
        
        return formattedException;
    }
    
    private void enqueueNextRunner(Id currentRequestId) {
        List<Async_Request__c> moreRequests = getMoreAsyncRequests(currentRequestId);
        
        if (moreRequests.isEmpty()) {
            return;
        }
        
        try {
            startJob();
        }
        catch(Exception ex) {
            enqueueNewRunnerFuture();
        }
    }
    
    @Future
    private static void enqueueNewRunnerFuture() {
        startJob();
    }
    
    private List<Async_Request__c> getMoreAsyncRequests(Id currentRequestId) {
        return
        [Select Id
           from Async_Request__c 
          where Status__c = 'Not Started'
            AND Id <> :currentRequestId
          Limit 1];
    }
}