global with sharing class AFPressBatchOrderUpdater implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    
    global void execute(SchedulableContext SC) {
        AFPress_Settings__c afPressSettings = AFPress_Settings__c.getInstance();
        
        Integer batchSize = afPressSettings != null && afPressSettings.Order_Query_Batch_Limit__c != null
                            ? (Integer) afPressSettings.Order_Query_Batch_Limit__c
                            : 100;

        Database.executeBatch(new AFPressBatchOrderUpdater(), batchSize);
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        String afPressOrdersQuery =
        'SELECT Id, Name, AFPress_Order__c' +
        '  FROM Order__c' +
        ' WHERE AFPress_Order__c != null ' +
        '   AND Status__c != \'Completed\'' +
        '   AND Status__c != \'Canceled\'';
        
        return Database.getQueryLocator(afPressOrdersQuery);
    }

    global void execute(Database.BatchableContext bc, List<Order__c> orders) {
        Map<String, Order__c> ordersByOrderNumber = indexOrdersByAFPressOrderNumber(orders);
        
        ESBAFPressOrderServiceClient.SearchOrdersResult latestOrdersResult =
            new ESBAFPressOrderServiceClient().getAFPressOrdersByAFPressOrderNumbers(ordersByOrderNumber.keyset());
            
        system.debug('  execute::latestOrdersResult ' + latestOrdersResult);

        List<Order__c> ordersToUpdate = new List<Order__c>();

        for (ESBAFPressOrderServiceClient.AFPressOrder latestOrder : latestOrdersResult.Orders) {
            system.debug('  execute::latestOrder ' + latestOrder);
            
            Order__c currentOrder = ordersByOrderNumber.get(latestOrder.OrderNumber);
            
            system.debug('  execute::currentOrder ' + currentOrder);

            if (currentOrder != null) {
                currentOrder.Status__c = latestOrder.Status;

                ordersToUpdate.add(currentOrder);
                
                system.debug('  execute::updated order ' + currentOrder);
            }
        }
        
        if (ordersToUpdate.size() > 0) {
            update ordersToUpdate;
            
            system.debug('  execute::ordersToUpdate ' + ordersToUpdate);
        }
    }
    
    global void finish(Database.BatchableContext bc) { }
    
    private Map<String, Order__c> indexOrdersByAFPressOrderNumber(List<Order__c> orders) {
        Map<String, Order__c> afPressOrdersByOrderNumber = new Map<String, Order__c>();
        
        for (Order__c order : orders) {
            afPressOrdersByOrderNumber.put(order.AFPress_Order__c, order);
        }
        
        return afPressOrdersByOrderNumber;
    }
}