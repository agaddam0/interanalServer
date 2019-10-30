trigger ContactTrigger on Contact (after update, after delete) {
    ContactBLogic.checkDecisionMakerUpdate(trigger.new, trigger.old, trigger.oldmap);
}