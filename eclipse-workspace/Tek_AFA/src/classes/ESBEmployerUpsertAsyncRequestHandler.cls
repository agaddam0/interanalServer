public without sharing class ESBEmployerUpsertAsyncRequestHandler implements IAsyncRequestHandler {
    public void handleRequest(Async_Request__c request) {
        system.debug('    handleRequest::request ' + request);
        
        Id enrollmentOpportunityId = request.Parameters__c;
        
        ESBEmployerUpsertServiceClient employerUpserter = new ESBEmployerUpsertServiceClient(enrollmentOpportunityId);
        employerUpserter.UpsertEmployer();
    }
}