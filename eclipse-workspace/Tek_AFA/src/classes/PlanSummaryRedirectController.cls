public with sharing class PlanSummaryRedirectController {

    @AuraEnabled
    public static String getAccountId(String opportunityId) {

        List<Opportunity> opportunities = [SELECT AccountId FROM Opportunity WHERE Id =: opportunityId];

        if(opportunities.size() > 0){
            return opportunities[0].AccountId;
        }

        return null;
    }
}