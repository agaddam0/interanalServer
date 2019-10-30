public class RecordTypeComponentController {
	@AuraEnabled
    public static List<String> getRecordTypesForObject(string sObjectName)
    {
        List<String> AvailableRecordTypeNames = new List<String>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(sObjectName);
        List<Schema.RecordTypeInfo> rti = sobjType.getDescribe().getRecordTypeInfos();
        system.debug('RTI: ' + rti);
        for(Schema.RecordTypeInfo rt : rti)
        {
            if(rt.isAvailable() && !rt.isMaster())
            {
                if(sObjectName == 'Change_Request__c' && rt.getName() != 'Conservation')
                	AvailableRecordTypeNames.add(rt.getName());
            }
        } 
        
        system.debug('Record Type Names: ' + AvailableRecordTypeNames);
        return AvailableRecordTypeNames;
    }
}