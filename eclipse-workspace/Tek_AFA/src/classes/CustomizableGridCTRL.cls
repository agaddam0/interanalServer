public with sharing class CustomizableGridCTRL {
    
    public static Map<String, Schema.SObjectField> field_map;
    
    @auraEnabled
    public static RecordsResponse getRecords(String requestJSON) {
        system.debug('    getRecords::requestJSON: ' + requestJSON);
    
        RecordsRequest request = (RecordsRequest) JSON.deserialize(requestJSON, RecordsRequest.class);
        
        system.debug('    getRecords::request : ' + request );
    
        List<SObject> records = getObjectRecords(request);
        
        system.debug('    getRecords::records ' + records);
        
        RecordsResponse response = new RecordsResponse(records);
        loadResponse(response, request);
        
        system.debug('    getRecords::response : ' + response );
        
        return response;
    }
    
    @AuraEnabled
    public static String getOwnerId()
    {
        String userId = UserInfo.getUserId();
        return userId;
    }
    
    @AuraEnabled
    public static String getProtraxUserId(Id recordId)
    {
        String returnId = '';
        Schema.SObjectType token = recordId.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        
        system.debug(dr.getName());

        if(dr.getName() == 'Colleague__c')
        {
            Colleague__c c = [SELECT Id, User__c FROM Colleague__c WHERE Id =: recordId];
            returnId = c.User__c;
        }
        else
        {
            returnId = UserInfo.getUserId();
        }
        
        return returnId;
    }
    
    
    private static void loadResponse(RecordsResponse response, RecordsRequest request) {
        getObjectDescribe(request.sObjectName);
        
        Schema.FieldSet fs = getFieldSet(request);
        
        Map<String, Schema.DescribeFieldResult> accessibleFieldSetColumns = new Map<String, Schema.DescribeFieldResult>();
        
        if (fs != null) {
	        for (FieldSetMember field : fs.getFields()) {
	            Schema.DescribeFieldResult dfr = Util.getFieldDescribe(field.getFieldPath(), field_map);
	            if(dfr.isAccessible())
	            {
	                accessibleFieldSetColumns.put(field.getFieldPath(), dfr);
	                response.ColumnNames.add(field.getLabel());
	                response.ColumnAPINames.add(field.getFieldPath());
	                
	                Field f = new Field(field);
	                response.Fields.add(f);
	            }
	        }
        }
        
        Map<String, Schema.DescribeFieldResult> accessibleAdditionalColumns = new Map<String, Schema.DescribeFieldResult>();
        
        if (request.AdditionalColumns != null) {
            for (String extraColumn : request.AdditionalColumns) {
                Schema.DescribeFieldResult dfr = Util.getFieldDescribe(extraColumn, field_map);
                if(dfr.isAccessible())
                {
                    response.ColumnNames.add(dfr.getLabel());
                    response.ColumnAPINames.add(dfr.getName());
                    
                    accessibleAdditionalColumns.put(extraColumn, dfr);
                    
                    Field f = new Field(false);
                    f.Label = dfr.getLabel();
                    f.APIName = dfr.getName();
                    f.Type = String.valueOf(dfr.getType());
                    
                    response.Fields.add(f);
                }
            }
        }
        
        if (fs != null) {
	        for (Record r : response.Records) {
	            for(FieldSetMember fsm : fs.getFields()) {
	                String apiFieldName = fsm.getFieldPath();
	                Field f = new Field(fsm);
	                Object fieldValue = Util.getRecordFieldValue(r.Record, apiFieldName);
	                f.FieldValue = fieldValue;
	                
	                //String fieldValueString = fieldValue != null ? String.valueOf(fieldValue) : '';
	        
	                r.fields.add(f);
	            }
	        }
        }
        
        if (!accessibleAdditionalColumns.isEmpty()) {
            for (Record r : response.Records) {
                for(String additionalColumn : accessibleAdditionalColumns.keySet()) {
                    Schema.DescribeFieldResult additionalDFR = accessibleAdditionalColumns.get(additionalColumn);
                    
                    Field f = new Field(false);
                    f.APIName = additionalColumn;
                    f.Label = additionalDFR.getLabel();
                    f.Type = String.valueOf(additionalDFR.getType());
                    Object fieldValue = Util.getRecordFieldValue(r.Record, additionalColumn);
                    f.FieldValue = fieldValue;
                    
                    //String fieldValueString = fieldValue != null ? String.valueOf(fieldValue) : '';
            
                    r.fields.add(f);
                }
            } 
        }
    }
    
    private static Schema.FieldSet getFieldSet(RecordsRequest request) {
        List<String> types = new List<String>{ request.SObjectName };

        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        Schema.DescribeSobjectResult objectResult = results[0];
        
        Map<String, Schema.FieldSet> fsMap = objectResult.fieldSets.getMap();
        
        Schema.FieldSet fs = fsMap.get(request.FieldSet);
        
        return fs;
    }
    
    private static void getObjectDescribe(String sObjectName)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(sObjectName);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        field_map = r.fields.getMap();
    }
    
    private static List<SObject> getObjectRecords(RecordsRequest request) {
        Set<String> fieldNames = new Set<String>();
        String orderBy = request.SortBy;
        
        if (String.isNotBlank(orderBy) &&
            String.isNotBlank(request.SortDirection)) {
            orderBy += ' ' + request.SortDirection;
        }
        
        if (String.isBlank(orderBy)) {
            orderBy = 'Name ASC';
        }
        
        if (String.isNotBlank(request.FieldSet)) {
	        Schema.FieldSet fs = getFieldSet(request);
	        
	        List<FieldSetMember> fields = fs.getFields();
	        
	        getObjectDescribe(request.sObjectName);
	        
	        for (FieldSetMember field : fields) {
	            Schema.DescribeFieldResult dfr = Util.getFieldDescribe(field.getFieldPath(), field_map);
	            if(dfr.isAccessible())
	            	fieldNames.add(field.getFieldPath());
	        }
        }
        
        if (request.AdditionalColumns != null) {
            for (String extraColumn : request.AdditionalColumns) {
                fieldNames.add(extraColumn);
            }
        }
        
        String soqlFieldNames = String.join(new List<String>(fieldNames), ',');

        String soql = 'SELECT ' + soqlFieldNames +
                      '  FROM ' + request.SObjectName;

        if (String.isNotBlank(request.WhereClause)) {
            if (!request.WhereClause.startsWithIgnoreCase('WHERE')) {
                soql += ' WHERE ';
            }
            
            soql += ' ' + request.WhereClause;
        }
        
        soql += ' ORDER BY ' + orderBy;
        
        system.debug(' soql: ' + soql);

        return Database.query(soql);
    }
    
    public class RecordsRequest {
        public String SObjectName { get; set; }
        
        public String FieldSet { get; set; }
        
        public String WhereClause { get; set; }
        
        public String[] AdditionalColumns { get; set; }
        
        public String SortBy { get; set; }
        
        public String SortDirection { get; set; }
        
        public RecordsRequest() {
            SObjectName = '';
            FieldSet = '';
            WhereClause = '';
            SortBy = '';
            SortDirection = '';
            AdditionalColumns = new List<String>();
        }
    }
    
    public class RecordsResponse {
        @AuraEnabled @testVisible
        List<Record> Records { get; set; }
        
        @AuraEnabled
        List<String> ColumnNames { get; set; }
        
        @AuraEnabled
        List<String> ColumnAPINames { get; set; }
        
        @AuraEnabled
        List<Field> Fields { get; set; }
        
        public RecordsResponse(List<SObject> sobjectRecords) {
            Records = new List<Record>();
            ColumnNames = new List<String>();
            ColumnAPINames = new List<String>();
            Fields = new List<Field>();
            
            for (SObject sobjectRecord : sobjectRecords) {
                Record r = new Record(sobjectRecord);
                Records.add(r);
            }
        }
    }
    
    public class Record {
        @AuraEnabled
        public SObject Record { get; set; }
        
        @AuraEnabled
        public Boolean Selected { get; set; }
        
        @AuraEnabled
        public List<Field> fields {get;set;}
        
        public Record(SObject objRecord) {
            fields = new List<Field>();
        
            Selected = false;
            
            Record = objRecord;
        }
    }
    
}