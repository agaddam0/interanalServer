public without sharing class ESBMicrositeAsyncRequestHandler implements IAsyncRequestHandler {
    public static final Integer RETRY_LIMIT = 3;
    
    public void handleRequest(Async_Request__c request) {
        Id marketingFormId = request.Parameters__c;
        
        Decimal numberOfAttempts = request.Attempt_Number__c != null ? request.Attempt_Number__c : 1;
        
        ESBMicrositeServiceClient client = new ESBMicrositeServiceClient(marketingFormId, (Integer) numberOfAttempts);
        ESBMicrositeServiceClient.ESBMicrositeUpsertResult upsertResult = client.UpsertMicrosite();
        
        if (upsertResult.Success == false &&
            numberOfAttempts < RETRY_LIMIT) {

            Async_Request__c retryRequest = request.clone(false, true);
            retryRequest.Attempt_Number__c = numberOfAttempts + 1;

            insert retryRequest;            
        }
    }
}