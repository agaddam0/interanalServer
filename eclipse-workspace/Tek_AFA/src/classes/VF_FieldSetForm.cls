public class VF_FieldSetForm {
    public SObject BoundRecord { get; set; }
    public Integer NumberOfTableLayoutColumns { get; set; }
    
    private String ObjectFieldSetNamePriv = null;
    public String ObjectFieldSetName {
        get {
            return ObjectFieldSetNamePriv;
        }
        set {
            if (ObjectFieldSetNamePriv != value) {
                tablePriv = null;
            }
            
            ObjectFieldSetNamePriv = value;
        }
    }
    
    public Map<String, Schema.DescribeFieldResult> SObjectFields {
        get {
            Map<String, Schema.DescribeFieldResult> myObjectFields = new Map<String, Schema.DescribeFieldResult>();
            
            Schema.DescribeSObjectResult SObjectDescribe = BoundRecord.getSObjectType().getDescribe();
            
            for (Schema.SObjectField f : SObjectDescribe.Fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDesc = f.getDescribe();
                
                myObjectFields.put(fieldDesc.getName(), fieldDesc);
            }
            
            return myObjectFields;
        }
    }
    
    public Schema.FieldSet ObjectFieldSet {
        get {
            Schema.DescribeSObjectResult SObjectDescribe = BoundRecord.getSObjectType().getDescribe();
            
            return SObjectDescribe.fieldSets.getMap().get(ObjectFieldSetName);
        }
    }
    
    private TableFormWrapper tablePriv = null;
    public TableFormWrapper Table {
        get {
            if (tablePriv == null) {
                Integer numberOfColumnsToUse = NumberOfTableLayoutColumns != null ? NumberOfTableLayoutColumns : 1;
                tablePriv = new TableFormWrapper(SObjectFields, numberOfColumnsToUse, ObjectFieldSet);
            }
            
            return tablePriv;
        }
    }
    
    public class TableFormWrapper {
        public List<TableFormWrapperRow> Rows { get; set; }
        
        private Map<String, Schema.SObjectType> globalDescribe { get; set; }
        
        public TableFormWrapper(Map<String, Schema.DescribeFieldResult> objectFieldsMap, Integer numberOfColumns, Schema.FieldSet fieldSet) {
            Rows = new List<TableFormWrapperRow>();
            List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
            
            Decimal fieldSize = fieldSetMembers.size();
            
            Decimal numberOfRows =  Math.Ceil(fieldSize / numberOfColumns);
            
            for (Integer rowNumber = 0; rowNumber < numberOfRows; ++rowNumber) {
                TableFormWrapperRow row = new TableFormWrapperRow();
                Integer rowOffSet = (rowNumber * numberOfColumns);
                
                for (Integer columnNumber = 0; columnNumber < numberOfColumns; ++columnNumber) {
                    Integer columnIndex = rowOffSet + columnNumber;
                    TableFormWrapperColumn column = null;
                    
                    
                    if (columnIndex < fieldSize) {
                        Schema.FieldSetMember fieldSetMember = fieldSetMembers[columnIndex];
                        Schema.DescribeFieldResult fieldDesc = objectFieldsMap.get(fieldSetMember.getFieldPath());
                        
                        if(fieldDesc == null)
                            fieldDesc = getFieldDescribe(fieldSetMember.getFieldPath(), objectFieldsMap);
                        
                        column = new TableFormWrapperColumn(fieldDesc, fieldSetMember);
                        
                        row.Columns.add(column);
                    }
                }
                
                Rows.add(row);
            }
        }
        
        public Schema.DescribeFieldResult getFieldDescribe(String relatedFieldName, Map<String, Schema.DescribeFieldResult> fields)
        {
            
            String relatedField = relatedFieldName.substringBefore('.');
            
            if(relatedField.endsWith('__c') || relatedField.endsWith('__r'))
                relatedField = relatedField.replace('__r', '__c');
            else
                relatedField = relatedField + 'Id';
            
            String fieldName = relatedFieldName.substringAfter('.');
            
            Schema.DescribeFieldResult dr = fields.get(relatedField);
            List<schema.sObjectType> objectTypes = dr.getReferenceTo();
            
            Map<String, Schema.SobjectField> fieldMap = objectTypes[0].getDescribe().fields.getMap();
            
            Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
            
            return fieldDesc;
        }
    }
    
    public class TableFormWrapperRow {
        public List<TableFormWrapperColumn> Columns { get; set; }
        
        public TableFormWrapperRow() {
            Columns = new List<TableFormWrapperColumn>();
        }
    }
    
    public class TableFormWrapperColumn { 
        public String HelpText { get; set; }
        public String Label { get; set; }
        public Boolean Required { get; set; }
        public String APIFieldName { get; set; }
        
        public TableFormWrapperColumn(Schema.DescribeFieldResult fieldDesc, Schema.fieldSetMember fieldSetMember) {
            HelpText = fieldDesc.getInlineHelpText();
            Label = fieldSetMember.getLabel();
            Required = fieldSetMember.getRequired();
            APIFieldName = fieldSetMember.getFieldPath();
        }
    }
}