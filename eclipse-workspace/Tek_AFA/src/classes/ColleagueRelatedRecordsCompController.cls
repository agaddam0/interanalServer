public with sharing class ColleagueRelatedRecordsCompController {
    
    @AuraEnabled
    public static List<Colleague__c> ColleagueRelatedRecords()
    {
        // This should only be pulling the colleagues that the logged-in user has access to
        return [SELECT Name, RecordType.Name FROM Colleague__c Order By Name ASC];
    }
    
    @AuraEnabled
    public static List<String> availableRecordTypes()
    {
        List<String> AvailableRecordTypeNames = new List<String>();
        List<Schema.RecordTypeInfo> rti = Schema.SObjectType.Colleague__c.getRecordTypeInfos();
        
        for(Schema.RecordTypeInfo rt : rti)
        {
            if(rt.isAvailable() && rt.getName() != 'Master')
                AvailableRecordTypeNames.add(rt.getName());
        } 
        
        system.debug('Record Type Names: ' + AvailableRecordTypeNames);
        return AvailableRecordTypeNames;
    }
    
    @AuraEnabled
    public static List<Colleague__c> ColleaguesBySearchName(string keyword)
    {
        List<Colleague__c> colleagues = new List<Colleague__c>();
        if(keyword != '')
        {
            String soql = 'SELECT Name, RecordType.Name FROM Colleague__c WHERE Name LIKE \'%' + keyword + '%\'';
            colleagues = (List<Colleague__c>)Database.query(soql);
            
        }
        else
           colleagues = [SELECT Name, RecordType.Name FROM Colleague__c Order By Name ASC]; 
        
        return colleagues;        
    }
    
    @AuraEnabled
    public static List<Colleague__c> ColleaguesByRecordType(string searchType)
    {
        if(searchType != '')
        	return [SELECT Name, RecordType.Name FROM Colleague__c WHERE RecordType.Name =: searchType Order By Name ASC];
        else
            return [SELECT Name, RecordType.Name FROM Colleague__c Order By Name ASC];
    }
}