public with sharing class RelatedDetailsComponentController {

    @AuraEnabled
    public static String getRelatedRecord(String sObjectName, String mainRecordId, String mainRecordObjectName, String RecordTypeName, Boolean latestRecord )
    {
        if(isNull(mainRecordId) || isNull(mainRecordObjectName) || isNull(sObjectName))
            return '';
                       
        String soql = 'SELECT Id FROM ' + sObjectName;
        
        soql += ' WHERE ' + mainRecordObjectName + '=\'' + mainRecordId + '\'';
        
        if(!isNull(RecordTypeName))
        {
            String rTypeId = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
            soql += ' AND RecordTypeId = \'' + rTypeId + '\'';
        }
        
        if(latestRecord)
        {
            soql += ' AND Latest_Record__c = ' + latestRecord;
        }
        
        List<sObject> results = Database.query(soql);
        
        if(results.size() > 1)
            return '';
        else
            return results[0].Id;
    }
    
    private static Boolean isNull(String variable)
    {
        if(variable == '' || variable == null)
            return true;
        else
            return false;
    }
    
}