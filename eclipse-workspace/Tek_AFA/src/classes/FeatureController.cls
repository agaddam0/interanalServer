public with sharing class FeatureController {

    @AuraEnabled(Cacheable=true)
    public static List<Feature_Release__c> getAllFeatures() {
        return [SELECT Id, Name, Type__c, Description__c, Release_Team__c, Release_Year__c, Release_Quarter__c, Status__c, Teir_1_Feature__c, Release_Date__c, Users_Impacted__c 
            FROM Feature_Release__c ORDER BY Status__c DESC ];
    }

    
}