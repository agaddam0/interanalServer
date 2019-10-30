trigger customOrderLineItemTrigger on Order_Line_Item__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new OrderLineItemTriggerHandler().run();
}