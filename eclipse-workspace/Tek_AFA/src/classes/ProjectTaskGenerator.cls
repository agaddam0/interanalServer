public without sharing class ProjectTaskGenerator {
    public static final String TASK_CHECKLIST_ITEM_DEFAULT_STATUS = 'Not Started';
    private static final String PROJECT_NAME_STARTING_TEMPLATE_DELIMITER = '{';
    private static final String PROJECT_NAME_ENDING_TEMPLATE_DELIMITER = '}';
    private static final String PROJECT_NAME_MERGE_FIELD_REGEX = '\\' + PROJECT_NAME_STARTING_TEMPLATE_DELIMITER + '([a-zA-Z0-9_\\.]*)\\' + PROJECT_NAME_ENDING_TEMPLATE_DELIMITER;
    private static final Integer NAME_MAX_LENGTH = 80;
    
    
    private static Set<String> ProjectTemplateNames { get; set; }
    private static Set<Id> RecordIds { get; set; }
    private static Map<String, String> ProjectLookupAPINamesByObject { get; set; }

    private static Id DefaultTaskStatusIdPriv;
    private static Id DefaultTaskStatusId { 
        get {
            if (DefaultTaskStatusIdPriv != null) {
                return DefaultTaskStatusIdPriv;
            }
        
            Task_Status__c defaultTaskStatus =
            [SELECT Id
               FROM Task_Status__c
             ORDER BY Order__c
             Limit 1];
        
            DefaultTaskStatusIdPriv = defaultTaskStatus.Id;
            return DefaultTaskStatusIdPriv;
        }
    }

    @InvocableMethod(label='Generate Project Tasks')
    public static void generate(List<ProjectTaskGeneratorRequest> requests) {
        loadBulkVariables(requests);
        Map<String, List<Task_Template__c>> taskTemplatesByProject = getTaskTemplatesByProject(ProjectTemplateNames);
        Map<Id, SObject> recordsById = getRecords(RecordIds, taskTemplatesByProject);
        
        List<ProjectInsertionContext> projectsToInsert = new List<ProjectInsertionContext>();

        for (ProjectTaskGeneratorRequest request : requests) {
            ProjectInsertionContext projectInsertionContext = generateProjectRecordsToInsert(request, recordsById, taskTemplatesByProject);
            
            if (projectInsertionContext != null) {
                projectsToInsert.add(projectInsertionContext);
            }
        }
        
        if (projectsToInsert.size() > 0) {
            insertProjectRecords(projectsToInsert);
        }
    }
    
    private static ProjectInsertionContext generateProjectRecordsToInsert(ProjectTaskGeneratorRequest request, Map<Id, SObject> recordsById, Map<String, List<Task_Template__c>> taskTemplatesByProject) {
        SObject record = recordsById.get(request.RecordId);
        List<Task_Template__c> projectTaskTemplates = taskTemplatesByProject.get(request.projectTemplateName);
        
        if (projectTaskTemplates == null ||
            projectTaskTemplates.isEmpty()) {
            return null;
        }
        
        ProjectInsertionContext projectInsertionContext = new ProjectInsertionContext();
        projectInsertionContext.ProjectToInsert = buildProject(record, projectTaskTemplates[0].Project_Template__r);
        projectInsertionContext.TasksToInsert = buildTaskInsertionContexts(record, projectTaskTemplates);
        
        return projectInsertionContext;
    }
    
    private static void loadBulkVariables(List<ProjectTaskGeneratorRequest> requests) {
        ProjectTemplateNames = new Set<String>();
        RecordIds = new Set<Id>();
        ProjectLookupAPINamesByObject = new Map<String, String>();
        
        for (ProjectTaskGeneratorRequest request : requests) {
            ProjectTemplateNames.add(request.projectTemplateName);
            RecordIds.add(request.RecordId);
        }
    }
    
    private static Map<String, List<Task_Template__c>> getTaskTemplatesByProject(set<String> projectTemplateNamesArg) {
        Map<String, List<Task_Template__c>> taskTemplatesByProject = new Map<String, List<Task_Template__c>>();
        
        List<Task_Template__c> projectsTaskTemplates =
        [SELECT Id,
                Name,
                Auto_Assignment_Record_User_Field__c,
                Project_Template__c,
                Project_Template__r.Name,
                Project_Template__r.Id,
                Project_Template__r.Description__c,
                Project_Template__r.Task_Display_Field_Set__c,
                Project_Template__r.Task_Edit_Field_Set__c,
                Project_Template__r.Assigned_Owner__c,
                Due_Date_Days_To_Add__c,
                Due_Date_Record_Field__c,
                Milestone__c,
                Order__c,
                Predecessor_Task_Template__c,
                Projected_End_Date_Days_To_Add__c,
                Projected_End_Date_Record_Field__c,
                Projected_Start_Date_Days_To_Add__c,
                Projected_Start_Date_Record_Field__c,
                Role__c,
                Description__c,
                (SELECT Id,
                        Name,
                        Order__c,
                        Label__c
                   FROM Task_Checklist_Item_Templates__r),
                (SELECT Id,
                        Name
                   FROM Predecessor_Task_Templates__r)
           FROM Task_Template__c
          WHERE Project_Template__r.Name in :projectTemplateNamesArg];
        
        for (Task_Template__c taskTemplate : projectsTaskTemplates) {
            String projectName = taskTemplate.Project_Template__r.Name;
            List<Task_Template__c> projectTaskTemplates = taskTemplatesByProject.get(projectName);
            
            if (projectTaskTemplates == null) {
                projectTaskTemplates = new List<Task_Template__c>();
                taskTemplatesByProject.put(projectName, projectTaskTemplates);
            }
            
            projectTaskTemplates.add(taskTemplate);
        }
        
        return taskTemplatesByProject;
    }
    
    private static Map<Id, SObject> getRecords(Set<Id> recordIdsArg, Map<String, List<Task_Template__c>> taskTemplatesByProject) {
        Map<Id, SObject> recordsMap = new Map<Id, SObject>();
        Map<Schema.DescribeSObjectResult, Set<Id>> recordIdsByObject = getRecordIdsByObject(recordIdsArg);
        Map<Schema.DescribeSObjectResult, Set<String>> fieldsToQueryByObject = getFieldsToQueryByObject(recordIdsByObject.keySet(), taskTemplatesByProject);
        
        for (Schema.DescribeSObjectResult sobjectDesc : recordIdsByObject.keyset()) {
            Set<String> objectFieldsToQuery = fieldsToQueryByObject.get(sobjectDesc);
            Set<Id> objectRecordIds = recordIdsByObject.get(sobjectDesc);

            String query = 'SELECT ' + String.join(new List<String>(objectFieldsToQuery), ',');
            query += ' FROM ' + sobjectDesc.getName();
            query += ' WHERE Id in :objectRecordIds';
            
            List<SObject> objectRecords = Database.query(query);
            
            recordsMap.putAll(objectRecords);
        }
        
        return recordsMap;
    }
    
    private static Map<Schema.DescribeSObjectResult, Set<Id>> getRecordIdsByObject(Set<Id> recordIdsArg) {
        Map<Schema.DescribeSObjectResult, Set<Id>> recordIdsByObject = new Map<Schema.DescribeSObjectResult, Set<Id>>();
        
        for (Id recordId : recordIdsArg) {
            Schema.DescribeSObjectResult objectDesc = recordId.getSObjectType().getDescribe();
            Set<Id> objectRecordIds = recordIdsByObject.get(objectDesc);
            
            if (objectRecordIds == null) {
                objectRecordIds = new Set<Id>();
                recordIdsByObject.put(objectDesc, objectRecordIds);
            }
            
            objectRecordIds.add(recordId);
        }
        
        return recordIdsByObject;
    }
    
    private static Map<Schema.DescribeSObjectResult, Set<String>> getFieldsToQueryByObject(Set<Schema.DescribeSObjectResult> sobjectDescribes, Map<String, List<Task_Template__c>> taskTemplatesByProject) {
        Map<Schema.DescribeSObjectResult, Set<String>> fieldsToQueryByObject = new Map<Schema.DescribeSObjectResult, Set<String>>();
        
        for (Schema.DescribeSObjectResult sobjectDescribe : sobjectDescribes) {
            Map<String, Schema.SObjectField> objectFields = sobjectDescribe.fields.getMap();
            Set<String> objectFieldsToQuery = new set<String>{ 'Id' };
            fieldsToQueryByObject.put(sobjectDescribe, objectFieldsToQuery);
            
            for (List<Task_Template__c> taskTemplates : taskTemplatesByProject.values()) {
                objectFieldsToQuery.addAll(ProjectTaskUtil.getObjectFieldsToQuery(sobjectDescribe, taskTemplates));
                
                Set<String> projectTemplateFieldsToAdd = getFieldsToQueryFromProjectName(taskTemplates[0].Project_Template__r.Name);
                
                objectFieldsToQuery.addAll(projectTemplateFieldsToAdd);
            }
        }        
        
        return fieldsToQueryByObject;
    }
    
    private static Set<String> getFieldsToQueryFromProjectName(String projectTemplateName) {
        Set<String> projectFieldsToQuery = new Set<String>();
        
        if (projectTemplateName.containsIgnoreCase(PROJECT_NAME_STARTING_TEMPLATE_DELIMITER) == false) {
            return projectFieldsToQuery;
        }
        
        Pattern mergeFieldPattern = Pattern.compile(PROJECT_NAME_MERGE_FIELD_REGEX); 
        Matcher mergeFieldMatcher = mergeFieldPattern.matcher(projectTemplateName);
        
        while(mergeFieldMatcher.find()) {
            String matchedField = mergeFieldMatcher.group().replace(PROJECT_NAME_STARTING_TEMPLATE_DELIMITER, '')
                                        .replace(PROJECT_NAME_ENDING_TEMPLATE_DELIMITER, '');

            projectFieldsToQuery.add(matchedField);
        }
        
        return projectFieldsToQuery;
    }
    
    private static Project__c buildProject(SObject sourceRecord, Project_Template__c projectTemplate) {
        String projectNameToUse = buildProjectNameToUse(sourceRecord, projectTemplate);
        
        Project__c project = new Project__c(
            Name = projectNameToUse,
            Project_Template__c = projectTemplate.Id,
            Description__c = projectTemplate.Description__c,
            Task_Display_Field_Set__c = projectTemplate.Task_Display_Field_Set__c,
            Task_Edit_Field_Set__c = projectTemplate.Task_Edit_Field_Set__c
        );
        
        if (String.isNotBlank(projectTemplate.Assigned_Owner__c)) {
            project.OwnerId = projectTemplate.Assigned_Owner__c;
        }
        
        String projectRecordLookupAPIName = findProjectRecordLookupName(sourceRecord);
        project.put(projectRecordLookupAPIName, sourceRecord.Id);
        
        return project;
    }
    
    private static String buildProjectNameToUse(SObject sourceRecord, Project_Template__c projectTemplate) {
        String projectNameToUse = projectTemplate.Name;
        
        if (!projectTemplate.Name.containsIgnoreCase(PROJECT_NAME_STARTING_TEMPLATE_DELIMITER)) {
            return projectNameToUse;
        }
        
        Set<String> fieldsToReplace = getFieldsToQueryFromProjectName(projectTemplate.Name);
        
        for (String fieldToReplace : fieldsToReplace) {
            String fieldValue = getFieldValue(sourceRecord, fieldToReplace);
            
            if (fieldValue == null) {
                fieldValue = '';
            }
            
            projectNameToUse = projectNameToUse.replace(fieldToReplace, fieldValue);
        }
        
        projectNameToUse = projectNameToUse.replace(PROJECT_NAME_STARTING_TEMPLATE_DELIMITER, '')
                                           .replace(PROJECT_NAME_ENDING_TEMPLATE_DELIMITER, '');
                                           
        if (projectNameToUse.length() > NAME_MAX_LENGTH) {
            projectNameToUse = projectNameToUse.substring(0, NAME_MAX_LENGTH);
        }
        
        return projectNameToUse;
    }
    
    private static String getFieldValue(SObject sourceRecord, String soqlField) {
        if (soqlField.containsIgnoreCase('.') == false) {
            return (String) sourceRecord.get(soqlField);
        }
        
        // Split uses a regular expression so have to escape the period to make it a literal period
        // and not any character.
        List<String> fieldParts = soqlField.split('\\.');
        
        SObject parentRecord = sourceRecord;
        Integer lastFieldPartIndex = fieldParts.size() - 1;
        
        for (Integer i = 0; i < lastFieldPartIndex; ++i) {
            String reference = fieldParts[i];
            parentRecord = parentRecord.getSObject(reference);
        }
        
        String lastFieldPart = fieldParts[lastFieldPartIndex];
        
        String fieldValue = (String) parentRecord.get(lastFieldPart);
        
        return fieldValue;
    }
    
    private static List<TaskInsertionContext> buildTaskInsertionContexts(SObject record, List<Task_Template__c> projectTaskTemplates) {
        List<TaskInsertionContext> taskInsertionContexts = new List<TaskInsertionContext>();
        Map<Id, Task_Template__c> taskTemplatesById = new Map<Id, Task_Template__c>(projectTaskTemplates);
        List<Task_Template__c> currentLevelTaskTemplates = getRootTaskTemplates(projectTaskTemplates);
        Map<Id, TaskInsertionContext> taskInsertionContextsByTemplate = new Map<Id, TaskInsertionContext>();
        
        while (currentLevelTaskTemplates != null && currentLevelTaskTemplates.size() > 0) {
        
	        for (Task_Template__c taskTemplate : currentLevelTaskTemplates) {
	            TaskInsertionContext taskInsertionContext = new TaskInsertionContext();
	            taskInsertionContext.TaskToInsert = buildTask(record, taskTemplate);
	            taskInsertionContext.CheckListItemsToInsert = buildChecklistItems(taskTemplate);
	            
	            if (taskTemplate.Predecessor_Task_Template__c != null) {
	                taskInsertionContext.PredecessorTask = taskInsertionContextsByTemplate.get(taskTemplate.Predecessor_Task_Template__c).TaskToInsert;
	            }
	            
	            taskInsertionContexts.add(taskInsertionContext);
	            taskInsertionContextsByTemplate.put(taskTemplate.Id, taskInsertionContext);
	        }
	        
	        currentLevelTaskTemplates = getNextLevelTasks(currentLevelTaskTemplates, taskTemplatesById);
        }
        
        return taskInsertionContexts;
    }
    
    private static List<Task_Template__c> getRootTaskTemplates(List<Task_Template__c> projectTaskTemplates) {
        List<Task_Template__c> rootTaskTemplates = new List<Task_Template__c>();
        
        for (Task_Template__c taskTemp : projectTaskTemplates) {
            if (taskTemp.Predecessor_Task_Template__c == null) {
                rootTaskTemplates.add(taskTemp);
            }
        }
        
        return rootTaskTemplates;
    }
    
    private static List<Task_Template__c> getNextLevelTasks(List<Task_Template__c> currentLevelTaskTemplates, Map<Id, Task_Template__c> allTaskTemplatesById) {
        List<Task_Template__c> nextLevelTasks = new List<Task_Template__c>();
        
        for (Task_Template__c currentLevelTaskTemplate : currentLevelTaskTemplates) {            
            for (Task_Template__c subTask : currentLevelTaskTemplate.Predecessor_Task_Templates__r) {
                // Use the sub task from allTaskTemplatesById since it'll have subtasks on it for any
                // sub task templates it may have. The sub task here won't have any because Salesforce doesn't
                // allow for recursive child record traversal in one relationship through a SOQL query.
                
                Task_Template__c nextLevelTask = allTaskTemplatesById.get(subTask.Id);
                nextLevelTasks.add(nextLevelTask);
            }
        }
        
        return nextLevelTasks;
    }
    
    private static Task__c buildTask(SObject sourceRecord, Task_Template__c taskTemplate) {
        Task__c task = new Task__c(
            Role__c = taskTemplate.Role__c,
            Task_Template__c = taskTemplate.Id,
            Order__c = taskTemplate.Order__c,
            Name = taskTemplate.Name,
            Status__c = DefaultTaskStatusId,
            Description__c = taskTemplate.Description__c,
            Milestone__c = taskTemplate.Milestone__c
        );
        
        if (String.isNotBlank(taskTemplate.Due_Date_Record_Field__c) &&
            taskTemplate.Due_Date_Days_To_Add__c != null) {
            
            task.Due_Date__c = ProjectTaskUtil.calculateDateFromSourceRecord(sourceRecord, taskTemplate.Due_Date_Record_Field__c, (Integer) taskTemplate.Due_Date_Days_To_Add__c);
        }
        
        if (String.isNotBlank(taskTemplate.Projected_End_Date_Record_Field__c) &&
            taskTemplate.Projected_End_Date_Days_To_Add__c != null) {
            
            task.Projected_End_Date__c = ProjectTaskUtil.calculateDateFromSourceRecord(sourceRecord, taskTemplate.Projected_End_Date_Record_Field__c, (Integer) taskTemplate.Projected_End_Date_Days_To_Add__c);
        }
        
        if (String.isNotBlank(taskTemplate.Projected_Start_Date_Record_Field__c) &&
            taskTemplate.Projected_Start_Date_Days_To_Add__c != null) {
            
            task.Projected_Start_Date__c = ProjectTaskUtil.calculateDateFromSourceRecord(sourceRecord, taskTemplate.Projected_Start_Date_Record_Field__c, (Integer) taskTemplate.Projected_Start_Date_Days_To_Add__c);
        }
        
        if (String.isNotBlank(taskTemplate.Auto_Assignment_Record_User_Field__c)) {
            task.Assignee__c = (Id) sourceRecord.get(taskTemplate.Auto_Assignment_Record_User_Field__c);
        }
        
        return task;
    }
    
    private static List<Task_Checklist_Item__c> buildChecklistItems(Task_Template__c taskTemplate) {
        List<Task_Checklist_Item__c> checklistItems = new List<Task_Checklist_Item__c>();
        
        for (Task_Checklist_Item_Template__c checklistItemTemplate : taskTemplate.Task_Checklist_Item_Templates__r) {
            Task_Checklist_Item__c taskChecklistItem = new Task_Checklist_Item__c(
                Label__c = checklistItemTemplate.Label__c,
                Order__c = checklistItemTemplate.Order__c,
                Status__c = TASK_CHECKLIST_ITEM_DEFAULT_STATUS
            );
            
            checklistItems.add(taskChecklistItem);
        }
        
        return checklistItems;
    }
    
    private static String findProjectRecordLookupName(SObject sourceRecord) {
        String objectName = sourceRecord.getSObjectType().getDescribe().getName();
        
        String projectRecordLookupName = ProjectLookupAPINamesByObject.get(objectName);
        
        if (String.isNotBlank(projectRecordLookupName)) {
            return projectRecordLookupName;
        }
        
        projectRecordLookupName = ProjectTaskUtil.findProjectRecordLookupFieldName(sourceRecord);
        
        ProjectLookupAPINamesByObject.put(objectName, projectRecordLookupName);
        
        return projectRecordLookupName;
    }
    
    private static void insertProjectRecords(List<ProjectInsertionContext> projectInsertionContexts) {
        List<Project__c> projectsToInsert = new List<Project__c>();
        
        for (ProjectInsertionContext projInsertionContext : projectInsertionContexts) {
            projectsToInsert.add(projInsertionContext.ProjectToInsert);
        }
        
        insert projectsToInsert;
        
        List<Task__c> tasksToInsert = new List<Task__c>();
        
        for (ProjectInsertionContext projInsertionContext : projectInsertionContexts) {
            for (TaskInsertionContext taskInsertionContext : projInsertionContext.TasksToInsert) {
                taskInsertionContext.TaskToInsert.Project__c = projInsertionContext.ProjectToInsert.Id;
                
                tasksToInsert.add(taskInsertionContext.TaskToInsert);
            }
        }
        
        insert tasksToInsert;
        
        List<Task_Checklist_Item__c> taskChecklistItemsToInsert = new List<Task_Checklist_Item__c>();
        
        for (ProjectInsertionContext projInsertionContext : projectInsertionContexts) {
            for (TaskInsertionContext taskInsertionContext : projInsertionContext.TasksToInsert) {
                for (Task_Checklist_Item__c taskChecklistItem : taskInsertionContext.ChecklistItemsToInsert) {
                    taskChecklistItem.Task__c = taskInsertionContext.TaskToInsert.Id;
                
                    taskChecklistItemsToInsert.add(taskChecklistItem);
                }
            }
        }
        
        if (taskChecklistItemsToInsert.size() > 0) {
            insert taskChecklistItemsToInsert;
        }
        
        // Link Tasks to their predecessor tasks.
        List<Task__c> tasksToUpdate = new List<Task__c>();
        
        for (ProjectInsertionContext projInsertionContext : projectInsertionContexts) {
            for (TaskInsertionContext taskInsertionContext : projInsertionContext.TasksToInsert) {
                if (taskInsertionContext.TaskToInsert != null &&
                    taskInsertionContext.PredecessorTask != null) {

                    taskInsertionContext.TaskToInsert.Predecessor_Task__c = taskInsertionContext.PredecessorTask.Id;
                    tasksToUpdate.add(taskInsertionContext.TaskToInsert);
                }
            }
        }

        if (tasksToUpdate.size() > 0) {
            update tasksToUpdate;
        }
    }
    
    private class ProjectInsertionContext {
        public Project__c ProjectToInsert { get; set; }
        
        public List<TaskInsertionContext> TasksToInsert { get; set; }
        
        public ProjectInsertionContext() {
            TasksToInsert = new List<TaskInsertionContext>();
        }
    }
    
    private class TaskInsertionContext {
        public Task__c TaskToInsert { get; set; }
        public Task__c PredecessorTask { get; set; }
        public List<Task_Checklist_Item__c> CheckListItemsToInsert { get; set; }
        
        public TaskInsertionContext() {
            CheckListItemsToInsert = new List<Task_Checklist_Item__c>();
        }
    }
}