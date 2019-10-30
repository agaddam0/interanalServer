public class FieldSetComponentController {
    
    @AuraEnabled
    public static List<Field> getFields(String objectName, String fieldSetName) {
        Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describe = targetObject.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = describe.fieldSets.getMap();
        Schema.FieldSet fs = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSet = fs.getFields();
        
        Map<String, Schema.SObjectField> objectFields = describe.fields.getMap();

        List<Field> fields = new List<Field>();
        for (Schema.FieldSetMember fsm: fieldSet) {
            String fieldPath = fsm.getFieldPath();
            
            system.debug('    fieldPath ' + fieldPath);
            
            Schema.DescribeFieldResult fieldDesc = getFieldDescribe(fieldPath, objectFields);
            
            system.debug('Field: ' + fieldDesc.name + 'Field Accessibility: ' + fieldDesc.isAccessible());
            if(fieldDesc.isAccessible())
            {
                Field f = new Field(fsm);
                f.setFieldsUsingFieldDescribe(fieldDesc);
                
                fields.add(f);
            }
        }
        return fields;
    }
    
    @AuraEnabled
    public static DetailsContext getDetails(String objectName, String fieldSetName, Id recordId) {
        DetailsContext context = new DetailsContext();
        
        context.Fields = getFields(objectName, fieldSetName);
        context.Record = getRecord(objectName, context.Fields, recordId);
        
        return context;
    }
    
    private static Schema.DescribeFieldResult getFieldDescribe(String fieldPath, Map<String, Schema.SObjectField> objectFields) {
        return Util.getFieldDescribe(fieldPath, objectFields);
    }
    
    private static SObject getRecord(String objectName, List<Field> fields, Id recordId) {
        Set<String> fieldsToQuery = Util.getFieldsForQuerying(fields);
        
        String recordSOQL = 'SELECT ' + String.join(new List<String>(fieldsToQuery), ',') +
                            '  FROM ' + objectName + 
                            ' WHERE Id = :recordId';

        return Database.query(recordSOQL);
    }
    
    public class DetailsContext {
        @AuraEnabled
        public List<Field> Fields { get; set; }
        
        @AuraEnabled
        public SObject Record { get; set; }
        
        public DetailsContext() {
            Fields = new List<Field>();
        }
    }
}