public with sharing class SObjectDropdownController {
    
    @AuraEnabled
    public static List<SObject> getSObjectRecords(String displayField, String sObjectName) {
        String soql = 'SELECT Id, ' + displayField +
                      '  FROM ' + sObjectName +
                      ' ORDER BY ' + displayField;

        return Database.query(soql);
    }    
}