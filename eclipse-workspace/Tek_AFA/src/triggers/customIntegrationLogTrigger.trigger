trigger customIntegrationLogTrigger on Integration_Log__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    new IntegrationLogTriggerHandler().run();
}