public without sharing class ESBMicrositeUpdateAsyncRequestHandler implements IAsyncRequestHandler {
    public static final String PREENROLLMENT_MARKETING_FORM_STATUS_UPDATED = 'Updated';
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
            
            // LF 1/30/2018: Update the status to updated only if the upsert succeeded
            // or if the maximum number of retry attempts is reached.
            return;
        }

        Pre_Enrollment_Marketing_Form__c marketingForm = new Pre_Enrollment_Marketing_Form__c(Id = marketingFormId);

        marketingForm.Status__c = PREENROLLMENT_MARKETING_FORM_STATUS_UPDATED;
        update marketingForm;
    }
}