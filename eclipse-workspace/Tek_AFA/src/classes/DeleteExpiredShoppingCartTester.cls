@isTest
public class DeleteExpiredShoppingCartTester {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @testSetup
    static void testSetup()
    {
        Marketing_Material__c customMaterial = MarketingMaterialTestData.Instance.withCustomizationType('Combo_Brochure')
                                                                                 .insertMarketingMaterial();

        Order__c cart = OrderTestData.Instance.withStatus('In Progress')
            								  .withCreatedDate(system.today().addDays(-61))
            								  .insertCartOrder();
        system.debug(cart);
        system.debug('Cart Expire Date: ' + cart.Cart_Expiration_Date__c);
        
        Order_Line_Item__c customOLI = OrderLineItemTestData.Instance.withOrder(cart.Id)
                                                                     .withMarketingMaterial(customMaterial.Id)
                                                                     .insertOrderLineItem();
    }
    
    static testMethod void testDeleteExpiredShoppingCartJob()
    {
        test.startTest();
        
        String jobId = system.schedule('DeleteExpiredCartsJob', CRON_EXP, new DeleteExpiredShoppingCartsJob());
        
        List<Order__c> order = [SELECT Id, Cart_Expiration_Date__c FROM Order__c WHERE Status__c = 'In Progress' AND Cart_Expiration_Date__c <: system.today()];
        system.debug(order);
        system.assertEquals(1, order.size());
        
        test.stopTest();
        
        order = [SELECT Id FROM Order__c WHERE Status__c = 'In Progress' AND Cart_Expiration_Date__c <: system.today()];
        
        system.assertEquals(0, order.size());
    }
}