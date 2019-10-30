trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after delete) {

    
    // perform our rollup actions
    AccountContactRelationBLogic.updateDecisionMakerRollupOnAccount(trigger.new, trigger.oldmap, trigger.old);
    
}