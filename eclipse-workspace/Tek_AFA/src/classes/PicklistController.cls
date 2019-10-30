public class PicklistController {

    @AuraEnabled
    public static List<String> getPicklistOptions(String fieldName, String sObjectName)
    {
        List<String> options = new List<String>();
        
        // Get describe of all the objects
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        // Get the SObject Type from the specific object name that is passed in
        Schema.SObjectType sobjType = gd.get(sObjectName);
        // Get the describe result of the passed in object
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        // Get the fields of the passed in object
        Map<String,Schema.SObjectField> field_map = r.fields.getMap();
        // get the pick list values of the field that was passed in from the field map of the object passed in
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry f : pick_list_values) 
        {
            options.add(f.getLabel());
        }
        
        system.debug('Options: ' + options);
        return options;
    }
}