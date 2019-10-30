public class LogFileInserter implements Queueable {
    public static final String NO_LOGS_TO_INSERT_MSG = 'The logs to insert are null or empty.';
    public static final String NULL_FILTERER_MSG = 'The filterer is null.';
    
    private List<Integration_Log__c> Logs { get; set; }
    private IntegrationLogFilter Filterer = new IntegrationLogFilter();
    
    public LogFileInserter(List<Integration_Log__c> logsToInsert) {
        if (logsToInsert == null ||
            logsToInsert.isEmpty()) {
            throw new LogFileInserterException(NO_LOGS_TO_INSERT_MSG);
        }
        
        Logs = logsToInsert;
    }
    
    public LogFileInserter(List<Integration_Log__c> logsToInsert, IntegrationLogFilter filtererArg) {
        this(logsToInsert);
        
        if (filtererArg == null) {
            throw new LogFileInserterException(NULL_FILTERER_MSG);
        }
        
        Filterer = filtererArg;
    }
    
    public void execute(QueueableContext context) {
        List<LogFileContainer> containers = new List<LogFileContainer>();
        
        for (Integration_Log__c log : Logs) {
            Filterer.filter(log);
            
            LogFileContainer container = new LogFileContainer();
            container.File = buildResponseFile(log);
            container.Log = log;
            
            containers.add(container);
            
            log.Response__c = 'The response was too big to fit in the field. Please see the attached response file.';
        }
        
        insert Logs;
        
        List<ContentVersion> filesToInsert = new List<ContentVersion>();
        
        // Set the owner to a designated system user so that regular users
        // don't see these files in their Files.
        Id ownerId = getSystemOwnerId();
        
        for (LogFileContainer container : containers) {
            container.File.FirstPublishLocationId = container.Log.Id;
            container.File.Title = container.Log.Id + ' Response';
            container.File.OwnerId = ownerId;
            
            filesToInsert.add(container.File);
        }
        
        insert filesToInsert;
    }

    private ContentVersion buildResponseFile(Integration_Log__c log) {
        return new ContentVersion(
            VersionData = Blob.valueOf(log.Response__c),
            Title = 'Response',
            PathOnClient = 'GeneratedInSalesforce.txt'
        );
    }
    
    private Id getSystemOwnerId() {
        Id integrationLogOwnerId = Label.Integration_Log_System_Owner_Id;

        return integrationLogOwnerId;
    }
    
    public class LogFileInserterException extends Exception { }
    
    private class LogFileContainer {
        public Integration_Log__c Log { get; set; }
        
        public ContentVersion File { get; set; }
    }
}