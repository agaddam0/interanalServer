global class DeleteExpiredShoppingCartsJob implements Schedulable {
    
	global void execute(SchedulableContext sc)
    {
        List<Order__c> expiredCarts = [SELECT Id FROM Order__c 
                                       WHERE Status__c = 'In Progress' 
                                       AND Cart_Expiration_Date__c <: system.today()];
        
        delete expiredCarts;
    }
}