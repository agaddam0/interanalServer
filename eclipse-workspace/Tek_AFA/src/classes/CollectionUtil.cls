public with sharing class CollectionUtil {
    public static Set<Id> getLookupIds(List<SObject> records, String lookupField) {
        Set<Id> lookupIds = new Set<Id>();
        
        if (records == null ||
            String.isBlank(lookupField)) {
            return lookupIds;
        }
        
        Integer recordSize = records.size();
        
        String[] lookupParts = lookupField.split('\\.');
        
        IRecordFieldGetter recordFieldGetter;
        
        if (lookupParts.size() > 1) {
            recordFieldGetter = new multiFieldGetter();
        } else {
            recordFieldGetter = new singleFieldGetter();
        }
        
        for (Integer i = 0; i < recordSize; ++i) {
            SObject record = records[i];
            
            Id lookupId = (Id) recordFieldGetter.getFieldValue(record, lookupParts);
            
            if (lookupId != null) {
                lookupIds.add(lookupId);
            }
        }
        
        return lookupIds;
    }
    
    public static Map<Id, List<SObject>> groupRecordsByLookupField(List<SObject> records, String lookupField) {
        Map<Id, List<SObject>> recordsGroupedByLookupField = new Map<Id, List<SObject>>();
        
        if (records == null ||
            String.isBlank(lookupField)) {
            return recordsGroupedByLookupField;
        }
        
        Integer recordSize = records.size();
        
        for (Integer i = 0; i < recordSize; ++i) {
            SObject record = records[i];
            
            Id lookupId = (Id) record.get(lookupField);
            
            List<SObject> groupedRecords = recordsGroupedByLookupField.get(lookupId);
            
            if (groupedRecords == null) {
                groupedRecords = new List<SObject>();
                recordsGroupedByLookupField.put(lookupId, groupedRecords);
            }
            
            groupedRecords.add(record);
        }
        
        return recordsGroupedByLookupField;
    }
    
    public static Map<Object, List<SObject>> groupRecordsByField(List<SObject> records, String field) {
        Map<Object, List<SObject>> recordsGroupedByField = new Map<Object, List<SObject>>();
        
        if (records == null ||
            String.isBlank(field)) {
            return recordsGroupedByField;
        }
        
        Integer recordSize = records.size();
        
        for (Integer i = 0; i < recordSize; ++i) {
            SObject record = records[i];
            
            Object fieldValue = record.get(field);
            
            List<SObject> groupedRecords = recordsGroupedByField.get(fieldValue);
            
            if (groupedRecords == null) {
                groupedRecords = new List<SObject>();
                recordsGroupedByField.put(fieldValue, groupedRecords);
            }
            
            groupedRecords.add(record);
        }
        
        return recordsGroupedByField;
    }
    
    public static List<SObject> filterRecordsByFieldValue(List<SObject> records, String field, Object filterValue) {
        List<SObject> matchingRecords = new List<SObject>();
        
        if (records == null ||
            String.isBlank(field)) {
            return matchingRecords;
        }
        
        Integer recordSize = records.size();
        
        for (Integer i = 0; i < recordSize; ++i) {
            SObject record = records[i];
            
            Object recordFieldValue = record.get(field);
            
            if (recordFieldValue == filterValue) {
                matchingRecords.add(record);
            }
        }
        
        return matchingRecords;
    }
    
    public static SObject findRecordById(List<SObject> records, Id recordId) {
        if (records == null || recordId == null) {
            return null;
        }
        
        return new Map<Id, SObject>(records).get(recordId);
    }
    
    public static Set<Id> getRecordIds(List<Sobject> records) {
        Map<Id, SObject> recordsMap = new Map<Id, SObject>(records);
        
        return recordsMap.keySet();
    }
    
    private interface IRecordFieldGetter {
        Object getFieldValue(SObject record, String[] fields);
    }
    
    private class singleFieldGetter implements IRecordFieldGetter {
        public Object getFieldValue(SObject record, String[] fields) {
            return record.get(fields[0]);
        }
    }
    
    private class multiFieldGetter implements IRecordFieldGetter {
        public Object getFieldValue(SObject record, String[] fields) {
            Integer oneBeforeLast = fields.size() - 2;
            SObject currentLevel = record;
            
            for (Integer i = 0; i <= oneBeforeLast; ++i) {
                String parentField = fields[i];
                currentLevel = currentLevel.getSObject(parentField);
                
                if (currentLevel == null) {
                    return null;
                }
            }
            
            return currentLevel.get(fields[fields.size() -1]);
        }
    }
}