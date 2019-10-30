public with sharing class ProjectTaskUtil {
    
    public static String findProjectRecordLookupFieldName(Id recordId) {
        String objectAPIName = recordId.getSObjectType().getDescribe().getName();
        
        return findProjectRecordLookupFieldName(objectAPIName);
    }

    public static String findProjectRecordLookupFieldName(SObject sourceRecord) {
        String objectAPIName = sourceRecord.getSObjectType().getDescribe().getName();
        
        return findProjectRecordLookupFieldName(objectAPIName);
    }
    
    public static String findProjectRecordLookupFieldName(String objectAPIName) {
        String projectRecordLookupName = '';
        List<Schema.SObjectField> projectRelationshipFields = new List<Schema.SObjectField>();
        
        for (Schema.SObjectField projectField : Schema.SObjectType.Project__c.Fields.getMap().values()) {
            Schema.DescribeFieldResult projectFieldDesc = projectField.getDescribe();
            List<Schema.SObjectType> parentSObjectTypes = projectFieldDesc.getReferenceTo();
            
            if (projectFieldDesc.isCustom() &&
                parentSObjectTypes != null &&
                parentSObjectTypes.size() > 0) {
                Schema.SObjectType parentSObjectType = parentSObjectTypes[0];
                String parentObjectName = parentSObjectType.getDescribe().getName();
                
                if (parentObjectName == objectAPIName) {
                    projectRecordLookupName = projectFieldDesc.getName();
                    break;
                }
                
                projectRelationshipFields.add(projectField);
            }
        }
        
        return projectRecordLookupName;
    }
    
    public static Set<String> findProjectLookupFields() {
        Set<String> projectLookupFields = new Set<String>();
        
        for (Schema.SObjectField projectField : Schema.SObjectType.Project__c.Fields.getMap().values()) {
            Schema.DescribeFieldResult projectFieldDesc = projectField.getDescribe();
            List<Schema.SObjectType> parentSObjectTypes = projectFieldDesc.getReferenceTo();
            
            if (projectFieldDesc.isCustom() &&
                parentSObjectTypes != null &&
                parentSObjectTypes.size() > 0) {
                Schema.SObjectType parentSObjectType = parentSObjectTypes[0];
                String parentObjectName = parentSObjectType.getDescribe().getName();
                

                if (projectFieldDesc.getLocalName() != 'Project_Template__c') {
                    projectLookupFields.add(projectFieldDesc.getLocalName());
                }
            }
        }
        
        return projectLookupFields;
    }
    
    public static FindProjectLookupFieldByParentResult findProjectRecordLookupFieldNameFromObjectParent(Id recordId) {
        String objectAPIName = recordId.getSObjectType().getDescribe().getName();
        
        return findProjectRecordLookupFieldNameFromObjectParent(objectAPIName);
    }
    
    public static FindProjectLookupFieldByParentResult findProjectRecordLookupFieldNameFromObjectParent(String objectAPIName) {
        FindProjectLookupFieldByParentResult result = new FindProjectLookupFieldByParentResult(); 
        
        //system.debug('   projectRecordLookupName: ' + projectRecordLookupName);
        //system.debug('   projectRelationshipFields: ' + projectRelationshipFields);
        
        List<String> objects = new List<String>{ objectAPIName };

        // Make the describe call
        List<Schema.DescribeSObjectResult> results = Schema.describeSObjects(objects);
        
        Schema.DescribeSObjectResult objectResult = results[0];
        
        //system.debug('   result: ' + result);
        
        for (Schema.SObjectField projectField : Schema.SObjectType.Project__c.Fields.getMap().values()) {
            Schema.DescribeFieldResult projectFieldDesc = projectField.getDescribe();
            List<Schema.SObjectType> parentSObjectTypes = projectFieldDesc.getReferenceTo();

            if (projectFieldDesc.isCustom() &&
                parentSObjectTypes != null &&
                parentSObjectTypes.size() > 0) {

                String projectParentObjectName = parentSObjectTypes[0].getDescribe().getName();

                for (Schema.SObjectField recordObjectField : objectResult.Fields.getMap().values()) {
		            Schema.DescribeFieldResult recordObjectFieldDesc = recordObjectField.getDescribe();
		            List<Schema.SObjectType> recordObjectParentSObjectTypes = recordObjectFieldDesc.getReferenceTo();

		            if (recordObjectParentSObjectTypes == null || recordObjectParentSObjectTypes.isEmpty()) {
		                continue;
		            }

		            String recordObjectParentName = recordObjectParentSObjectTypes[0].getDescribe().getName();

	                if (projectParentObjectName == recordObjectParentName) {
	                    result.ProjectLookupFieldName = projectFieldDesc.getName();
	                    result.RecordLookupFieldName = recordObjectFieldDesc.getName();

	                    return result;
	                }
		        }
            }
        }

        return result;
    }
    
    public static Date calculateDateFromSourceRecord(SObject sourceRecord, String sourceDateField, Integer numberOfDays) {
        Date sourceDate = (Date) sourceRecord.get(sourceDateField);

        Date calculatedDate = null;

        if (sourceDate != null) {
            calculatedDate = sourceDate.addDays(numberOfDays);
        }
        
        return calculatedDate;
    }
    
    public static void generateProjectTasks(Id recordId, String projectTemplateName) {
        ProjectTaskGeneratorRequest generateRequest = new ProjectTaskGeneratorRequest();
        generateRequest.RecordId = recordId;
        generateRequest.ProjectTemplateName = projectTemplateName;
        
        ProjectTaskGenerator.generate(new List<ProjectTaskGeneratorRequest> { generateRequest });
    }
    
    public static void generateProjectTasks(Id recordId, List<Project_Template__c> projectTemplates) {
        List<ProjectTaskGeneratorRequest> requests = new List<ProjectTaskGeneratorRequest>();
        
        for (Project_Template__c template : projectTemplates) {
            ProjectTaskGeneratorRequest generateRequest = new ProjectTaskGeneratorRequest();
            generateRequest.RecordId = recordId;
            generateRequest.ProjectTemplateName = template.Name;
            
            requests.add(generateRequest);
        }
        
        ProjectTaskGenerator.generate(requests);
    }
    
    public static Set<String> getObjectFieldsToQuery(Schema.DescribeSObjectResult sobjectDescribe, List<Task_Template__c> taskTemplates) {
        Map<String, Schema.SObjectField> objectFields = sobjectDescribe.fields.getMap();
        Set<String> objectFieldsToQuery = new set<String>{ 'Id' };

        for (Task_Template__c taskTemplate : taskTemplates) {
            if (String.isNotBlank(taskTemplate.Due_Date_Record_Field__c) &&
                objectFields.get(taskTemplate.Due_Date_Record_Field__c) != null) {
                    
                objectFieldsToQuery.add(taskTemplate.Due_Date_Record_Field__c);
            }

            if (String.isNotBlank(taskTemplate.Projected_End_Date_Record_Field__c) &&
                objectFields.get(taskTemplate.Projected_End_Date_Record_Field__c) != null) {

                objectFieldsToQuery.add(taskTemplate.Projected_End_Date_Record_Field__c);
            }

            if (String.isNotBlank(taskTemplate.Projected_Start_Date_Record_Field__c) &&
                objectFields.get(taskTemplate.Projected_Start_Date_Record_Field__c) != null) {

                objectFieldsToQuery.add(taskTemplate.Projected_Start_Date_Record_Field__c);
            }

            if (String.isNotBlank(taskTemplate.Auto_Assignment_Record_User_Field__c) &&
                objectFields.get(taskTemplate.Auto_Assignment_Record_User_Field__c) != null) {

                objectFieldsToQuery.add(taskTemplate.Auto_Assignment_Record_User_Field__c);
            }
        }
        
        return objectFieldsToQuery;
    }
    
    public class FindProjectLookupFieldByParentResult { 
        public String ProjectLookupFieldName { get; set; }
        
        public String RecordLookupFieldName { get; set; }
    }
}