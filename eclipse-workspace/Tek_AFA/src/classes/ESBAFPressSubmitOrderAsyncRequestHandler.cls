public without sharing class ESBAFPressSubmitOrderAsyncRequestHandler implements IAsyncRequestHandler {
    public void handleRequest(Async_Request__c request) {
        system.debug('    handleRequest::request ' + request);
        
        Id orderId = request.Parameters__c;
        
        ESBAFPressOrderServiceClient afPressOrderClient = new ESBAFPressOrderServiceClient();
        ESBAFPressOrderServiceClient.SubmitOrderResult result = afPressOrderClient.submitOrder(orderId);

        if (orderId != null) {
	        Order__c orderToUpdate = new Order__c(Id = orderId);
	        
	        if (result.Success) {
	            orderToUpdate.AFPress_Order__c = result.AFPressOrderNumber;
	        }
	        else {
	            orderToUpdate.AFPress_Error__c = result.Message;
	        }
	        
	        update orderToUpdate;
        }
    }
}