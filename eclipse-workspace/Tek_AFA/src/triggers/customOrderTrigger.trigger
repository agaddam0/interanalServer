trigger customOrderTrigger on Order__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new OrderTriggerHandler().run();    
}