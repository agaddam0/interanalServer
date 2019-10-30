public with sharing class TaskBoardController {
    public static final String OVERDUE_TASKS_FILTER = 'Overdue Tasks';
    public static final String UPCOMING_TASKS_FILTER = 'Upcoming Tasks';
    public static final String UNASSIGNED_TASKS_FILTER = 'Unassigned Tasks';
    public static final String MY_TASKS_FILTER = 'My Tasks';
    public static final String ALL_TASKS_FILTER = 'All Tasks';
    
    private static final Map<String, String> PRIMARY_FILTERS = new Map<String, String>{
        MY_TASKS_FILTER => 'Assignee__c = \'' + UserInfo.getUserId() + '\'',
        
        UNASSIGNED_TASKS_FILTER => 'Assignee__c = null',
        
        UPCOMING_TASKS_FILTER => 'Due_Date__c <= NEXT_N_DAYS:7 AND Due_Date__c >= TODAY',
        
        OVERDUE_TASKS_FILTER => 'Overdue__c = true'
    };
    
    
    @AuraEnabled
    public static TaskBoard getTaskBoardForRecord(Id recordId) {        
        List<Task__c> recordTasks = getRecordTasks(recordId);
        
        TaskBoard board = new TaskBoard(recordTasks);
        board.RecordId = recordId;
        
        return board;
    }
    
    public static TaskBoard getTaskBoardByTask(Id taskId) {
        Task__c task = getTaskById(taskId);
        
        return getTaskBoardByProjectId(task.Project__c);
    }
    
    @AuraEnabled
    public static TaskBoard filterTaskBoardForRecord(Id recordId, Id projectId, String taskFilterName, String roleFilterName) {
        List<Task__c> recordTasks = getRecordTasksAndFilter(recordId, projectId, taskFilterName, roleFilterName);
        
        TaskBoard board = new TaskBoard(recordTasks);
        board.RecordId = recordId;
        
        return board;
    }
    
    @AuraEnabled
    public static TaskBoard updateTaskStatus(Id taskId, Id newTaskStatusId, Id recordId) {
        Task__c taskToUpdate = new Task__c(
            Id = taskId,
            Status__c = newTaskStatusId
        );
        
        update taskToUpdate;
        
        return getTaskBoardByTask(taskId);
    }
    
    @AuraEnabled
    public static TaskBoard addNewTask(String newTaskName, Id newTaskStatusId, Id projectId, Id recordId) {
        Task__c taskToAdd = new Task__c(
            Project__c = projectId,
            Status__c = newTaskStatusId,
            Name = newTaskName,
            Assignee__c = UserInfo.getUserId()
        );
        
        insert taskToAdd;
        
        return getTaskBoardByTask(taskToAdd.Id);
    }
    
    @AuraEnabled
    public static Task getTask(Id taskId) {
        Task__c requestedTask = getTaskById(taskId);
        
        return new Task(requestedTask);
    }
    
    @AuraEnabled
    public static Task addTaskChecklistItem(Id taskId, String checklistItemName) {
        Task_Checklist_Item__c tasChecklistItemToAdd = new Task_Checklist_Item__c(
            Task__c = taskId,
            Label__c = checklistItemName
        );
        
        insert tasChecklistItemToAdd;
        
        return getTask(taskId);
    }
    
    @AuraEnabled
    public static Task_Checklist_Item__c updateTaskChecklistItemStatus(Id taskChecklistItemId, String newStatus) {
        Task_Checklist_Item__c taskChecklistItemToUpdate = new Task_Checklist_Item__c(Id = taskChecklistItemId);
        taskChecklistItemToUpdate.Status__c = newStatus;
        
        update taskChecklistItemToUpdate;
        
        Task_Checklist_Item__c updatedTaskChecklistItem = getTaskChecklistItemById(taskChecklistItemId);
        
        return updatedTaskChecklistItem;
    }
    
    @AuraEnabled
    public static Task uploadFileToTaskAsChatterFile(Id taskId, String fileName, String base64Data, String contentType) {
        ContentVersion cv = new ContentVersion(
	        versionData = EncodingUtil.base64Decode(base64Data),
	        title = fileName,
	        //description = att.description,
	        pathOnClient = '/' + fileName,
	        OwnerId = UserInfo.getUserId()
        );
        
        insert cv;
        
        ContentVersion cvQueried = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            linkedEntityId = taskId,
            contentDocumentId = cvQueried.contentDocumentId,
            shareType = 'I'
        );
        
        insert cdl;
        
        
        return getTask(taskId);
    }
    
    @AuraEnabled
    public static Task deleteTaskChatterFile(Id taskId, Id taskFileIdToDelete) {
        ContentDocument fileToDelete = new ContentDocument(Id = taskFileIdToDelete);
        delete fileToDelete;
        
        return getTask(taskId);
    }
    
    @AuraEnabled
    public static TaskBoard completeTask(Id taskId, Id recordId) {
        Task_Status__c completedStatus = getCompletedStatus();
        
        Task__c taskToComplete = new Task__c(Id = taskId);
        taskToComplete.Status__c = completedStatus.Id;
        update taskToComplete;
        
        return getTaskBoardByTask(taskId);
    }
    
    @AuraEnabled
    public static TaskBoard updateTask(Task__c taskToUpdate, Id recordId) {
        update taskToUpdate;
        
        return getTaskBoardByTask(taskToUpdate.Id);
    }
    
    @AuraEnabled
    public static TaskBoard getTaskBoardByProjectId(Id projectId) {
        List<Task__c> projectTasks = getTasksForProject(projectId);
        
        TaskBoard board = new TaskBoard(projectTasks);
        board.RecordId = findProjectLookupRecordId(projectId);
        
        return board;
    }
    
    private static List<Task__c> getRecordTasks(Id recordId) {
        return getRecordTasksHelper(recordId, null);
    }

    private static List<Task__c> getRecordTasksAndFilter(Id recordId, Id projectId, String taskFilterName, String roleFilterName) {
        List<String> whereClauses = new List<String>();
        
        if (String.isNotBlank(taskFilterName)) {

            for (String filter : PRIMARY_FILTERS.keySet()) {
                if (filter == taskFilterName) {
                    whereClauses.add( PRIMARY_FILTERS.get(filter) );
                    break;        
                }
            }
        }
        
        if (String.isNotBlank(roleFilterName)) {
            whereClauses.add('Role__c = \'' + roleFilterName + '\'');
        }
        
        if (projectId != null) {
            whereClauses.add('Project__c = \'' + projectId + '\'');
        }
        
        return getRecordTasksHelper(recordId, whereClauses);
    }
    
    private static List<Task__c> getRecordTasksHelper(Id recordId, List<String> whereClauses) {
        List<Task__c> recordTasks = new List<Task__c>();
        
        system.debug('    getRecordTasksHelper::recordId: ' + recordId);
        system.debug('    getRecordTasksHelper::whereClauses: ' + whereClauses);
        
        if (recordId == null) {
            return recordTasks;
        }
        
        String projectLookupFieldName = ProjectTaskUtil.findProjectRecordLookupFieldName(recordId);
        Id recordIdToUse = recordId;
        
        if (String.isBlank(projectLookupFieldName)) {
            ProjectTaskUtil.FindProjectLookupFieldByParentResult parentLookupResult = ProjectTaskUtil.findProjectRecordLookupFieldNameFromObjectParent(recordId);
            
            if (String.isNotBlank(parentLookupResult.ProjectLookupFieldName) &&
                String.isNotBlank(parentLookupResult.RecordLookupFieldName)) {
                projectLookupFieldName = parentLookupResult.ProjectLookupFieldName;
                
                recordIdToUse = getRecordParentId(recordId, parentLookupResult.RecordLookupFieldName);
                
            }
            else {
                return recordTasks;
            }
        }
        
        Set<String> taskFields = getTaskFieldsToQuery();
        taskFields.add('Project__r.' + projectLookupFieldName);
        
        String recordTasksQuery =    'SELECT ' + String.join(new List<String>(taskFields), ',') + ', ' +
                                            '( SELECT Id, Name, Label__c, Order__c, Status__c ' +
                                            '    FROM Task_Checklist_Items__r  ' +
                                            '  ORDER BY Order__c NULLS Last, CreatedDate ), ' +
                                            '(SELECT Id, Name ' +
                                            '   FROM Attachments ' +
                                            ' ORDER BY Name), ' +
                                            '(SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId ' +
                                            '   FROM ContentDocumentLinks)' +
                                     '  FROM Task__c' +
                                     ' WHERE Project__r.' + projectLookupFieldName + ' = :recordIdToUse' +
                                     '   AND Status__r.Display_on_Task_Board__c = true ';
                 
        if (whereClauses != null) {
            for (String whereClause : whereClauses) {
                recordTasksQuery += ' AND ' + whereClause + ' ';
            }
        }                    
                                     
                                     
        recordTasksQuery += ' ORDER BY Status__r.Order__c, Order__c NULLS Last, CreatedDate';
        
        system.debug('    getRecordTasksHelper::recordTasksQuery: ' + recordTasksQuery);
                                     
        recordTasks = Database.query(recordTasksQuery);
        
        return recordTasks;
    }
    
    private static List<Task__c> getTasksForProject(Id projectId) {
        List<Task__c> projectTasks = new List<Task__c>();
        
        system.debug('    getTasksForProject::projectId: ' + projectId);
        
        if (projectId == null) {
            return projectTasks;
        }
        
        Set<String> taskFields = getTaskFieldsToQuery();
        
        String projectTasksQuery =    'SELECT ' + String.join(new List<String>(taskFields), ',') + ', ' +
                                            '( SELECT Id, Name, Label__c, Order__c, Status__c ' +
                                            '    FROM Task_Checklist_Items__r  ' +
                                            '  ORDER BY Order__c NULLS Last, CreatedDate ), ' +
                                            '(SELECT Id, Name ' +
                                            '   FROM Attachments ' +
                                            ' ORDER BY Name), ' +
                                            '(SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId ' +
                                            '   FROM ContentDocumentLinks)' +
                                     '  FROM Task__c' +
                                     ' WHERE Project__c = :projectId' +
                                     '   AND Status__r.Display_on_Task_Board__c = true ' +
                                     ' ORDER BY Status__r.Order__c, Order__c NULLS Last, CreatedDate';
        
        system.debug('    getTasksForProject::projectTasksQuery: ' + projectTasksQuery);
                                     
        projectTasks = Database.query(projectTasksQuery);
        
        return projectTasks;
    }
    
    private static List<Task_Status__c> getTaskStatuses() {
        return [SELECT Id,
                       Name,
                       Order__c,
                       Completed__c,
                       Overdue_Task_Color__c,
                       Display_on_Task_Board__c
                  FROM Task_Status__c
                 ORDER BY Order__c];
    }
    
    private static Task_Status__c getCompletedStatus() {
        return [SELECT Id,
                       Name
                  FROM Task_Status__c
                 WHERE Completed__c = true
                   AND Display_on_Task_Board__c = true
                 ORDER BY Order__c desc
                 LIMIT 1];
    }
    
    private static Task__c getTaskById(Id taskId) {
        return
        [Select Name,
                Projected_Start_Date__c,
                Projected_End_Date__c,
                Actual_Start_Date__c,
                Actual_End_Date__c,
                Assignee__c,
                Assignee__r.Name,
                Assignee_Display_Name__c,
                Description__c,
                Notes__c,
                Order__c,
                Predecessor_Task__c,
                Project__c,
                Project__r.Name,
                Project__r.Completed_Tasks_Count__c,
                Project__r.Task_Count__c,
                Project__r.Percent_Complete__c,
                Role__c,
                Status__c,
                Status__r.Name,
                Status__r.Completed__c,
                Due_Date__c,
                Overdue__c,
                Task_Template__c,
                (SELECT Id, Name, Label__c, Order__c, Status__c
                   FROM Task_Checklist_Items__r
                   ORDER BY Order__c NULLS Last, CreatedDate ),
                (SELECT Id, Name
                   FROM Attachments
                   ORDER BY Name),
                (SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersionId
                   FROM ContentDocumentLinks)
           FROM Task__c
          WHERE Id = :taskId];
    }
    
    private static Task_Checklist_Item__c getTaskChecklistItemById(Id taskChecklistItemId) {
        return
        [SELECT Id,
                Name,
                Label__c,
                Order__c,
                Status__c
           FROM Task_Checklist_Item__c
          WHERE Id = :taskChecklistItemId];
    }
    
    private static Id getRecordParentId(Id recordId, String parentFieldName) {
        String objectAPIName = recordId.getSObjectType().getDescribe().getName();
        
        String recordSOQL = 'SELECT Id, ' + parentFieldName + ' FROM ' + objectAPIName + ' WHERE Id = :recordId';
        SObject record = Database.query(recordSOQL);
        
        return (Id) record.get(parentFieldName);
    }
    
    private static Set<String> getTaskFieldsToQuery() {
        Set<String> taskFieldsToQuery = new Set<String>{
            'Id',
            'Name',
            'Projected_Start_Date__c',
            'Projected_End_Date__c',
            'Actual_Start_Date__c',
            'Actual_End_Date__c',
            'Assignee__c',
            'Assignee__r.Name',
            'Assignee_Display_Name__c',
            'Description__c',
            'Notes__c',
            'Order__c',
            'Predecessor_Task__c',
            'Project__c',
            'Project__r.Name',
            'Project__r.Completed_Tasks_Count__c',
            'Project__r.Task_Count__c',
            'Project__r.Percent_Complete__c',
            'Project__r.Opportunity__c',
            'Project__r.Opportunity__r.Id',
            'Project__r.Opportunity__r.Enrollment_Start_Date__c',
            'Project__r.Opportunity__r.Enrollment_End_Date__c',
            'Project__r.Opportunity__r.Effective_Date_of_AFA_Products__c',
            'Role__c',
            'Status__c',
            'Status__r.Name',
            'Status__r.Completed__c',
            'Due_Date__c',
            'Overdue__c',
            'Task_Template__c',
            'Display_Field_Set__c',
            'Edit_Field_Set__c'
        };
        
        Map<String, Schema.FieldSet> taskFieldSets = Schema.SObjectType.Task__c.fieldSets.getMap();

        Set<String> fieldSetsFields = Util.getFieldSetFields(taskFieldSets.values());
        taskFieldsToQuery.addAll(fieldSetsFields);
        
        return taskFieldsToQuery;
    }
    
    public static Id findProjectLookupRecordId(Id projectId) {
        Id recordId = null;
        
        Set<String> projectLookupFields = ProjectTaskUtil.findProjectLookupFields();
        
        String projectQuery = 'SELECT Id, ' + String.join(new List<String>(projectLookupFields), ',') +
                              '  FROM Project__c ' +
                              ' WHERE Id = :projectId';
        
        Project__c projectRecord = Database.query(projectQuery);
        
        for (String projectLookupField : projectLookupFields) {
            recordId = (Id) projectRecord.get(projectLookupField);
            
            if (recordId != null) {
                break;
            }
        }
        
        return recordId;
    }
    
    public class TaskBoard {
        @AuraEnabled
        public Id RecordId { get; set; }
        
        @AuraEnabled
        public Id ProjectId { get; set; }
        
        @AuraEnabled
        public String ProjectName { get; set; }
        
        @AuraEnabled
        public String ProjectPercentComplete { get; set; }
        
        @AuraEnabled
        public Integer ProjectTasksCount { get; set; }
        
        @AuraEnabled
        public List<TaskList> TaskLists { get; set; }
        
        @AuraEnabled
        public String SalesforceBaseURL { get; set; }
        
        @AuraEnabled
        public List<Task_Status__c> AvailableTaskStatuses { get; set; }
        
        @AuraEnabled
        public List<String> TaskRoles { get; set; }
        
        @AuraEnabled
        public Integer NumberTasksOnTheBoard { get; set; }
        
        @AuraEnabled
        public Id EnrollmentOpportunityId { get; set; }
        
        @AuraEnabled
        public Id EnrollmentFormId { get; set; }
        
        @AuraEnabled
        public SObject LinkedRecord { get; set; }
        
        public TaskBoard(List<Task__c> tasks) {
            TaskLists = new List<TaskList>();
            this.SalesforceBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            this.TaskRoles = getTaskRoles();
            this.ProjectTasksCount = 0;
            this.AvailableTaskStatuses = getTaskStatuses();
            this.NumberTasksOnTheBoard = 0;
            
            if (tasks == null ||
                tasks.isEmpty()) {
                return;
            }
            
            Map<Id, TaskList> taskListsById = new Map<Id, TaskList>();
            for (Task_Status__c taskStatus : availableTaskStatuses) {
                if (taskStatus.Display_on_Task_Board__c == false) {
                    continue;
                }
                
                TaskList statusTaskList = new TaskList();
                statusTaskList.Status = taskStatus.Name;
                statusTaskList.TaskStatusId = taskStatus.Id;
                statusTaskList.CompletedStatus = taskStatus.Completed__c;
                statusTaskList.OverdueTaskColor = taskStatus.Overdue_Task_Color__c;
                
                TaskLists.add(statusTaskList);
                taskListsById.put(taskStatus.Id, statusTaskList);
            }
            
            for (Task__c task : tasks) {
                TaskList statusTaskList = taskListsById.get(task.Status__c);
                
                Task t = new Task(task);
                
                statusTaskList.Tasks.add(t);
                ++NumberTasksOnTheBoard;
            }
            
            this.ProjectId = tasks[0].Project__c;
            
            Project__c project = tasks[0].Project__r;
            
            this.ProjectName =project.Name;
            this.ProjectTasksCount = (Integer) project.Task_Count__c;
            this.ProjectPercentComplete = project.Percent_Complete__c + '%';
            this.EnrollmentOpportunityId = project.Opportunity__c;
            
            if (this.EnrollmentOpportunityId != null) {
                this.EnrollmentFormId = getEnrollmentFormId(this.EnrollmentOpportunityId);
                LinkedRecord = project.Opportunity__r;
            }
        }
        
        public TaskList findTaskListByStatus(String status) {
            TaskList foundTaskList = null;
            
            if (String.isBlank(status) || TaskLists == null || TaskLists.isEmpty()) {
                return foundTaskList;
            }
            
            for (TaskList taskList : TaskLists) {
                if (taskList.Status == status) {
                    foundTaskList = taskList;
                    break;
                }
            }
            
            return foundTaskList;
        }
        
        public Task findTaskById(Id taskId) {
            Task foundTask = null;

            if (String.isNotBlank(taskId) && TaskLists != null) {
                for (TaskList taskList : TaskLists) {
                    foundTask = taskList.findTaskById(taskId);

                    if (foundTask != null) {
                        break;
                    }
                }
            }

            return foundTask;
        }
        
        public Task findTaskByName(String taskName) {
            Task foundTask = null;
            
            if (String.isBlank(taskName) || TaskLists == null || TaskLists.isEmpty()) {
                return foundTask;
            }
            
            for (TaskList taskList : TaskLists) {
                foundTask = taskList.findTaskByName(taskName);
                
                if (foundTask != null) {
                    break;
                }
            }
            
            return foundTask;
        }
        
        private List<String> getTaskRoles() {
            List<String> taskRoles = new List<String>();
            
            Schema.DescribeFieldResult taskRoleFieldResult = Task__c.Role__c.getDescribe();
            List<Schema.PicklistEntry> ples = taskRoleFieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry ple : ples) {
                taskRoles.add(ple.getValue());
            }
            
            return taskRoles;
        }
        
        private Id getEnrollmentFormId(Id enrollmentOpportunityId) {
            Id efId = null;
            
            List<Enrollment_Form__c> enrollmentForms =
            [SELECT Id
               FROM Enrollment_Form__c
              WHERE Enrollment_Opportunity__c = :enrollmentOpportunityId
             LIMIT 1];
              
            if (enrollmentForms.size() > 0) {
                efId = enrollmentForms[0].Id;
            }
              
            return efId;
        }
    }
    
    public class TaskList {
        @AuraEnabled
        public String Status { get; set; }
        
        @AuraEnabled
        public Boolean CompletedStatus { get; set; }
        
        @AuraEnabled
        public Id TaskStatusId { get; set; }
        
        @AuraEnabled
        public String OverdueTaskColor { get; set; }
        
        @AuraEnabled
        public List<Task> Tasks { get; set; }
        
        public TaskList() {
            Tasks = new List<Task>();
            CompletedStatus = false;
        }
        
        public Task findTaskById(Id taskId) {
            Task foundTask = null;
            
            if (taskId == null || Tasks == null || Tasks.isEmpty()) {
                return foundTask;
            }
            
            for (Task task : Tasks) {
                if (task.Task.Id == taskId) {
                    foundTask = task;
                    break;
                }
            }
            
            return foundTask;
        }
        
        public Task findTaskByName(String taskName) {
            Task foundTask = null;
            
            if (String.isBlank(taskName) || Tasks == null || Tasks.isEmpty()) {
                return foundTask;
            }
            
            for (Task task : Tasks) {
                if (task.Task.Name == taskName) {
                    foundTask = task;
                    break;
                }
            }
            
            return foundTask;
        }
    }
    
    public class Task {
        @AuraEnabled
        public Task__c Task { get; set; }
        
        @AuraEnabled
        public Integer TaskChecklistItemsCount { get; set; }
        
        @AuraEnabled
        public Integer TaskChecklistItemsCompletedCount { get; set; }
        
        public Task(Task__c taskToUse) {
            TaskChecklistItemsCount = 0;
            TaskChecklistItemsCompletedCount = 0;

            this.Task = taskToUse;
            
            if (taskToUse != null && taskToUse.Task_Checklist_Items__r  != null) {
                TaskChecklistItemsCount = taskToUse.Task_Checklist_Items__r.size();
                
                for (Task_Checklist_Item__c taskChecklistItem : taskToUse.Task_Checklist_Items__r) {
                    if (taskChecklistItem.Status__c == 'Completed') {
                        ++TaskChecklistItemsCompletedCount;
                    }
                }
            }
        }
        
        public Task_Checklist_Item__c findTaskChecklistItemByLabel(String label) {
            Task_Checklist_Item__c foundTaskChecklistItem = null;
            
            if (String.isBlank(label) || Task == null || Task.Task_Checklist_Items__r == null) {
                return foundTaskChecklistItem;
            }
            
            for (Task_Checklist_Item__c checklistItem : Task.Task_Checklist_Items__r) {
                if (checklistItem.Label__c == label) {
                    foundTaskChecklistItem = checklistItem;
                    break;
                }
            }
            
            return foundTaskChecklistItem;
        }
    }
}