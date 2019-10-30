@isTest
public with sharing class TaskBoardControllerTest {
    private static Opportunity Opp;
    private static Project_Template__c ProjectTemplate;
    private static Task_Template__c TaskTemplate1;
    private static Task_Template__c TaskTemplate2;
    private static List<Task_Status__c> TaskStatuses;
    private static Task_Status__c NotNeededTaskStatus;
    private static Task_Status__c InProgressTaskStatus;
    private static Task_Status__c CompletedTaskStatus;
    private static Task_Status__c NotStartedTaskStatus;
    private static Task_Status__c WaitingOnHoldTaskStatus;
    
    private static List<Task__c> DefaultTasks;

    @testSetup
    private static void setup() {
        NotNeededTaskStatus = TaskStatusTestData.Instance.withName('Not Needed')
                                                         .withOrder(4)
                                                         .withDisplayOnTaskBoard(false)
                                                         .withCompleted(true)
                                                         .insertTaskStatus();
                                                              
        InProgressTaskStatus = TaskStatusTestData.Instance.withName('In Progress')
                                                          .withOrder(2)
                                                          .withDisplayOnTaskBoard(true)
                                                          .withCompleted(false)
                                                          .insertTaskStatus();
                                                               
        CompletedTaskStatus  = TaskStatusTestData.Instance.withName('Completed')
                                                          .withOrder(5)
                                                          .withDisplayOnTaskBoard(true)
                                                          .withCompleted(true)
                                                          .insertTaskStatus();

        NotStartedTaskStatus = TaskStatusTestData.Instance.withName('Not Started')
                                                          .withOrder(1)
                                                          .withDisplayOnTaskBoard(true)
                                                          .withCompleted(false)
                                                          .insertTaskStatus();
                                                               
        WaitingOnHoldTaskStatus = TaskStatusTestData.Instance.withName('Waiting / On Hold')
                                                             .withOrder(3)
                                                             .withDisplayOnTaskBoard(true)
                                                             .withCompleted(false)
                                                             .insertTaskStatus();

        ProjectTemplate = ProjectTemplateTestData.Instance.insertProjectTemplate();

        TaskTemplate1 = TaskTemplateTestData.Instance.withProjectTemplate(ProjectTemplate.Id)
                                                     .insertTaskTemplate();
                                                     
        TaskTemplate2 = TaskTemplateTestData.Instance.withProjectTemplate(ProjectTemplate.Id)
                                                     .withName('Some Other Task')
                                                     .insertTaskTemplate();
        
        Opp = OpportunityTestData.Instance.insertAFESOpportunity();

        ProjectTaskUtil.generateProjectTasks(Opp.Id, ProjectTemplate.Name);
    }
    
    private static void loadSetupData() {
        Opp = getOpportunity();
        TaskStatuses = getTaskStatuses();
        DefaultTasks = getTasks();
        
        for (Task_Status__c taskStatus : TaskStatuses) {
            if (taskStatus.Name == 'Not Needed') {
                NotNeededTaskStatus = taskStatus;
            }
            else if (taskStatus.Name == 'In Progress') {
                InProgressTaskStatus = taskStatus;
            }
            else if (taskStatus.Name == 'Completed') {
                CompletedTaskStatus = taskStatus;
            }
            else if (taskStatus.Name == 'Not Started') {
                NotStartedTaskStatus = taskStatus;
            }
            else if (taskStatus.Name == 'Waiting / On Hold') {
                WaitingOnHoldTaskStatus = taskStatus;
            }
        }
    }
    
    private static Opportunity getOpportunity() {
        return
        [SELECT Id,
                Name,
                AccountId
           FROM Opportunity
         LIMIT 1];
    }
    
    private static List<Task_Status__c> getTaskStatuses() {
        return
        [SELECT Id,
                Name,
                Order__c,
                Completed__c,
                Display_On_Task_Board__c
           FROM Task_Status__c];
    }
    
    private static List<Task__c> getTasks() {
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
           FROM Task__c];
    }
    
    private static void assertDefaultTaskBoard(TaskBoardController.TaskBoard taskBoard) {
        system.assert(taskBoard != null, 'The task board is null.');
        
        if (TaskStatuses == null) {
            loadSetupData();
        }
        
        system.assert(taskBoard.AvailableTaskStatuses != null, 'The available task statuses is null.');
        system.assertEquals(TaskStatuses.size(), taskBoard.AvailableTaskStatuses.size(), 'The available task statuses returned does not match the number of available ones.');
        system.assert(taskBoard.TaskRoles != null, 'The task roles is null.');
        system.assert(taskBoard.TaskRoles.size() > 0, 'There are no task roles.');
        system.assert(String.isNotBlank(taskBoard.SalesforceBaseURL), 'The salesforce base url is blank or null.');
    }
    
    private static void assertTaskBoardForOpportunity(TaskBoardController.TaskBoard taskBoard, Integer numExpectedTasks) {
        system.assert(taskBoard != null, 'The task board is null.');
        system.assert(numExpectedTasks != null, 'The numExpectedTasks is null.');
        
        assertDefaultTaskBoard(taskBoard);
        
        if (Opp == null) {
            loadSetupData();
        }
        
        system.assert(Opp != null, 'The opp is null.');
        system.assert(taskBoard.ProjectId != null, 'The project id is null on the task board.');
        system.assert(string.isNotBlank(taskBoard.ProjectName), 'The project name is null or blank on the task board.');
        system.assert(string.isNotBlank(taskBoard.ProjectPercentComplete), 'The project percent complete is null or blank on the task board.');
        
        system.assertEquals(numExpectedTasks, taskBoard.NumberTasksOnTheBoard, 'The task board does not have the expected number of tasks.');

        system.assert(taskBoard.TaskLists != null, 'The task lists on the task board are null.');
        
        Integer numExpectedTaskLists = 0;
        
        for (Task_Status__c taskStatus : TaskStatuses) {
            if (taskStatus.Display_On_Task_Board__c) {
                ++numExpectedTaskLists;
            }
        }
        
        system.assertEquals(numExpectedTaskLists, taskBoard.TaskLists.size(), 'The number of tasks lists does not match the list of displayable task statuses.');
    }
    
    private static void assertTaskBoardEmpty(TaskBoardController.TaskBoard taskBoard) {
        system.assert(taskBoard != null, 'The task board is null.');
        
        assertDefaultTaskBoard(taskBoard);
        system.assertEquals(0, taskBoard.ProjectTasksCount, 'There should not be any tasks found.');
    }
    
    private static void unassignAllTasks() {
        setAllTasksFieldWithFieldValue('Assignee__c', null);
    }
    
    private static void assignOneTaskToMe() {
        List<Task__c> allTasks = getTasks();
        
        Task__c taskToAssignToMe = allTasks[0];
        taskToAssignToMe.Assignee__c = UserInfo.getUserId();
        
        update taskToAssignToMe;
    }
    
    private static void assignAllTasksToMe() {
        setAllTasksFieldWithFieldValue('Assignee__c', UserInfo.getUserId());
    }
    
    private static void setAllTasksDueDateToXDaysFromToday(Integer numberOfDaysFromToday) {
        Date newDueDate = Date.today().addDays(numberOfDaysFromToday);
        
        setAllTasksFieldWithFieldValue('Due_Date__c', newDueDate);
    }
    
    private static void setAllTasksWithRole(String newRole) {
        setAllTasksFieldWithFieldValue('Role__c', newRole);
    }
    
    private static void setAllTasksFieldWithFieldValue(String fieldName, Object fieldValue) {
        List<Task__c> allTasks = getTasks();
        
        for (Task__c task : allTasks) {
            task.put(fieldName, fieldValue);
        }
        
        update allTasks;
    }
    
    private static void assertTaskInStatusTaskListOnTaskBoard(TaskBoardController.TaskBoard taskBoard, Task__c task, String taskStatus) {
        system.assert(taskBoard != null, 'The task board is null.');
        system.assert(task != null, 'The task is null.');
        system.assert(task.Id != null, 'The task is not inserted.');
        system.assert(String.isNotBlank(taskStatus), 'The task status is null or blank.');
        
        assertDefaultTaskBoard(taskBoard);
        
        TaskBoardController.TaskList statusTaskList = taskBoard.findTaskListByStatus(taskStatus);
        
        system.assert(statusTaskList != null, 'The status task list is null and was not found for taskStatus: ' + taskStatus);
        
        TaskBoardController.Task taskToFind = statusTaskList.findTaskById(task.Id);
        
        system.assert(taskToFind != null, 'The task was not found in the ' + taskStatus + ' task list on the task board.');
    }
    
    private static void assertTaskSetToStatus(Id taskId, Id expectedTaskStatusId) {
        system.assert(taskId != null, 'The task id is null.');
        system.assert(expectedTaskStatusId != null, 'The task status is null.');
        
        TaskBoardController.Task task = TaskBoardController.getTask(taskId);
        
        system.assert(task != null, 'The task was not found.');
        system.assert(task.Task != null, 'The task record was not included in the task wrapper object.');
        system.assertEquals(expectedTaskStatusId, task.Task.Status__c, 'The task\'s status was not updated to the expected one');
    }
    
    private static void assertTaskNotOnTaskBoard(TaskBoardController.TaskBoard taskBoard, Task__c task) {
        system.assert(taskBoard != null, 'The task board is null.');
        system.assert(task != null, 'The task is null.');
        system.assert(task.Id != null, 'The task is not inserted.');
        system.assert(taskBoard.TaskLists != null && taskBoard.TaskLists.size() > 0, 'The task board has no task lists.');
        
        Boolean taskFound = false;
        
        for (TaskBoardController.TaskList boardTaskList : taskBoard.TaskLists) {
            TaskBoardController.Task taskToFind = boardTaskList.findTaskById(task.Id);
            
            if (taskToFind != null) {
                taskFound = true;
                break;
            }
        }
        
        
        system.assertEquals(false, taskFound, 'The task was found on the task board when it should not have been.');
    }
    
    @isTest
    private static void getTaskBoardForRecord_nullRecordId_expectBlankBoardReturnedTest() {
        Id nullRecordId = null;
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.getTaskBoardForRecord(nullRecordId);
        
        assertDefaultTaskBoard(taskBoard);
        system.assert(taskBoard.TaskLists.isEmpty(), 'No tasks should be returned.');
    }
    
    @isTest
    private static void getTaskBoardForRecord_invokeWithOpportunityRecordThatHasProject_expectBoardWithTasksReturnedTest() {
        loadSetupData();

        TaskBoardController.TaskBoard taskBoard = TaskBoardController.getTaskBoardForRecord(Opp.Id);

        assertTaskBoardForOpportunity(taskBoard, 2);
    }
    
    @isTest
    private static void getTaskBoardForRecord_invokeWithChildRecordThatHasProjectOnParentRecord_expectBoardWithTasksReturnedTest() {
        loadSetupData();
        
        Enrollment_Form__c oppEnrollmentForm = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c = :opp.Id];
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.getTaskBoardForRecord(oppEnrollmentForm.Id);

        assertTaskBoardForOpportunity(taskBoard, 2);
    }
    
    @isTest
    private static void getTaskBoardForRecord_invokeWithRecordIdWithNoProject_expectBoardWithNoTasksReturnedTest() {
        loadSetupData();
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.getTaskBoardForRecord(Opp.AccountId);

        assertTaskBoardEmpty(taskBoard);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndNoFilters_expectBoardWithTasksReturnedTest() {
        loadSetupData();
        
        String emptyTaskFilterName = '';
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, emptyTaskFilterName, emptryRoleFilterName);

        assertTaskBoardForOpportunity(taskBoard, 2);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndAllTasksFilters_expectBoardWithTasksReturnedTest() {
        loadSetupData();
        
        String allTasksTaskFilterName = TaskBoardController.ALL_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, allTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardForOpportunity(taskBoard, 2);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndMyTasksFiltersAndNoTasksAssignedToMe_expectBoardWithNoTasksReturnedTest() {
        loadSetupData();
        
        unassignAllTasks();
        
        String allTasksTaskFilterName = TaskBoardController.MY_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, allTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardEmpty(taskBoard);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndMyTasksFiltersAndOneTaskAssignedToMe_expectBoardOneTaskReturnedTest() {
        loadSetupData();
        
        unassignAllTasks();
        
        List<Task__c> tasks = getTasks();
        system.assert(tasks != null && tasks.size() > 0, 'No tasks found.');
        Task__c firstTask = tasks[0];
        system.assertEquals(null, firstTask.Assignee__c, 'The task is assigned to someone when it should not.');
        
        assignOneTaskToMe();
        
        String myTasksTaskFilterName = TaskBoardController.MY_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, myTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardForOpportunity(taskBoard, 1);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndUnassignedTasksFiltersAndAllTasksAssignedToMe_expectBoardNoTasksReturnedTest() {
        loadSetupData();
        
        assignAllTasksToMe();
        
        String unassignedTasksTaskFilterName = TaskBoardController.UNASSIGNED_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, unassignedTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardEmpty(taskBoard);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndUnassignedTasksFiltersAndAllTasksUnAssigned_expectBoardHasTasksReturnedTest() {
        loadSetupData();
        
        unassignAllTasks();
        
        String unassignedTasksTaskFilterName = TaskBoardController.UNASSIGNED_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, unassignedTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardForOpportunity(taskBoard, 2);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndUpcomingTasksFiltersAndAllTasksMoreThanOneWeekInFuture_expectBoardNoTasksReturnedTest() {
        loadSetupData();
        
        setAllTasksDueDateToXDaysFromToday(8);
        
        String upcomingTasksTaskFilterName = TaskBoardController.UPCOMING_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, upcomingTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardEmpty(taskBoard);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndUpcomingTasksFiltersAndAllTasksMoreThanOneWeekInPast_expectBoardNoTasksReturnedTest() {
        loadSetupData();
        
        setAllTasksDueDateToXDaysFromToday(-8);
        
        String upcomingTasksTaskFilterName = TaskBoardController.UPCOMING_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, upcomingTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardEmpty(taskBoard);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndUpcomingTasksFiltersAndAllTasksDueWithinOneWeek_expectBoardHasTasksReturnedTest() {
        loadSetupData();
        
        setAllTasksDueDateToXDaysFromToday(1);
        
        String upcomingTasksTaskFilterName = TaskBoardController.UPCOMING_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, upcomingTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardForOpportunity(taskBoard, 2);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndOverdueTasksFiltersAndAllTasksDueWithinOneWeek_expectBoardNoTasksReturnedTest() {
        loadSetupData();
        
        setAllTasksDueDateToXDaysFromToday(1);
        
        String overdueTasksTaskFilterName = TaskBoardController.OVERDUE_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, overdueTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardEmpty(taskBoard);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndOverdueTasksFiltersAndAllTasksOverdue_expectBoardHasTasksReturnedTest() {
        loadSetupData();
        
        setAllTasksDueDateToXDaysFromToday(-1);
        
        String overdueTasksTaskFilterName = TaskBoardController.OVERDUE_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, overdueTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardForOpportunity(taskBoard, 2);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndOverdueTasksFiltersAndAllTasksDueToday_expectBoardNoTasksReturnedTest() {
        loadSetupData();
        
        setAllTasksDueDateToXDaysFromToday(0);
        
        String overdueTasksTaskFilterName = TaskBoardController.OVERDUE_TASKS_FILTER;
        String emptryRoleFilterName = '';
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, overdueTasksTaskFilterName, emptryRoleFilterName);

        assertTaskBoardEmpty(taskBoard);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndRoleFilterAndAllTasksWithNoRole_expectBoardNoTasksReturnedTest() {
        loadSetupData();
        
        String fieldRole = 'Field';
        
        setAllTasksWithRole('');
        
        String emptyTaskFilterName = null;
        String roleFilterName = fieldRole;
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, emptyTaskFilterName, roleFilterName);

        assertTaskBoardEmpty(taskBoard);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityAndRoleFilterAndAllTasksWithSameRole_expectBoardHasTasksReturnedTest() {
        loadSetupData();
        
        String fieldRole = Task__c.Role__c.getDescribe().getPicklistValues()[0].getValue();
        
        setAllTasksWithRole(fieldRole);
        
        String emptyTaskFilterName = null;
        String roleFilterName = fieldRole;
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, null, emptyTaskFilterName, roleFilterName);

        assertTaskBoardForOpportunity(taskBoard, 2);
    }
    
    @isTest
    private static void filterTaskBoardForRecord_invokeWithOpportunityWithMultipleProjectButSpecificProjectIdGiven_expectOnlySpecificProjectTasksReturnedTest() {
        loadSetupData();

        Project__c secondOppProject = ProjectTestData.Instance.withOpportunity(Opp.Id).insertProject();
        Task__c secondProjectTask = TaskTestData.Instance.withProject(secondOppProject.Id)
                                                         .withStatus(NotStartedTaskStatus.Id)
                                                         .insertTask();

        String emptyTaskFilterName = '';
        String emptyRole = '';

        TaskBoardController.TaskBoard taskBoard = TaskBoardController.filterTaskBoardForRecord(Opp.Id, secondOppProject.Id, emptyTaskFilterName, emptyRole);

        assertTaskBoardForOpportunity(taskBoard, 1);
        
        TaskBoardController.Task secondProjectTaskOnBoard = taskBoard.findTaskById(secondProjectTask.Id);
        system.assert(secondProjectTaskOnBoard != null, 'The second project task was not found');
    }
    
    @isTest
    private static void updateTaskStatus_setTaskToInProgress_expectTaskStatusSetToInProgressTest() {
        loadSetupData();
        
        Task__c notStartedTask = DefaultTasks[0];
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.updateTaskStatus(notStartedTask.Id, InProgressTaskStatus.Id, Opp.Id);
        
        assertTaskSetToStatus(notStartedTask.Id, InProgressTaskStatus.Id);
        assertTaskInStatusTaskListOnTaskBoard(taskBoard, notStartedTask, InProgressTaskStatus.Name);
    }
    
    @isTest
    private static void updateTaskStatus_setTaskToNotNeeded_expectTaskStatusSetToNotNeededAndNotOnTaskBoardTest() {
        loadSetupData();
        
        Task__c notStartedTask = DefaultTasks[0];
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.updateTaskStatus(notStartedTask.Id, NotNeededTaskStatus.Id, Opp.Id);
        
        assertTaskSetToStatus(notStartedTask.Id, NotNeededTaskStatus.Id);
        assertTaskNotOnTaskBoard(taskBoard, notStartedTask);
    }
    
    @isTest
    private static void findTaskListByStatus_statusNull_expectNullTaskListReturnedTest() {
        List<Task__c> nullTasks = null;
        TaskBoardController.TaskBoard taskBoard = new TaskBoardController.TaskBoard(nullTasks);
        
        system.assert(taskBoard != null, 'The task board was not instantiated with null tasks.');
        
        String emptyTaskStatus = '';
        TaskBoardController.TaskList taskList = taskBoard.findTaskListByStatus(emptyTaskStatus);
        
        system.assertEquals(null, taskList, 'The task list should be null.');
    }
    
    @isTest
    private static void TaskList_findTaskByName_emptyTaskName_expectNullTaskReturnedTest() {
        String emptyTaskName = '';
        
        TaskBoardController.TaskList tl = new TaskBoardController.TaskList();
        
        TaskBoardController.Task foundTask = tl.findTaskByName(emptyTaskName);
        system.assertEquals(null, foundTask, 'The found task should be null.');
    }
    
    @isTest
    private static void TaskBoard_findTaskByName_emptyTaskName_expectNullTaskReturnedTest() {
        String emptyTaskName = '';
        List<Task__c> nullTasks = null;
        
        TaskBoardController.TaskBoard taskBoard = new TaskBoardController.TaskBoard(nullTasks);
        
        TaskBoardController.Task foundTask = taskBoard.findTaskByName(emptyTaskName);
        system.assertEquals(null, foundTask, 'The found task should be null.');
    }
    
    @isTest
    private static void addNewTask_newNotNeededManualTaskAdded_expectTaskAddedToTaskBoardTest() {
        loadSetupData();
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.getTaskBoardForRecord(Opp.Id);
        
        String newTaskName = 'Some manual task';
        
        taskBoard = TaskBoardController.addNewTask(newTaskName, NotStartedTaskStatus.Id, taskBoard.ProjectId, Opp.Id);
        
        assertDefaultTaskBoard(taskBoard);
        
        TaskBoardController.Task newTask = taskBoard.findTaskByName(newTaskName);
        system.assert(newTask != null, 'The new task was not found on the board.');
        system.assert(newTask.Task.Id != null, 'The new task was not inserted.');
    }
    
    @isTest
    private static void addTaskChecklistItem_newManualTaskChecklistItemAdded_expectTaskChecklistItemSavedTest() {
        loadSetupData();
        
        String newTaskChecklistItemLabel = 'Some other checklist item';

        TaskBoardController.Task task = TaskBoardController.addTaskChecklistItem(DefaultTasks[0].Id, newTaskChecklistItemLabel);
        
        system.assert(task != null, 'The task is null.');
        
        Task_Checklist_Item__c addedChecklistItem = task.findTaskChecklistItemByLabel(newTaskChecklistItemLabel);
        
        system.assert(addedChecklistItem != null, 'The new task checklist item was not attached to the task.');
        system.assert(addedChecklistItem.Id != null, 'The new task checklist item was not saved to the database.');
    }
    
    @isTest
    private static void Task_findTaskChecklistItemByLabel_emptyLabelGiven_expectNullTaskChecklistItemReturnedTest() {
        Task__c nullTask = null;
        TaskBoardController.Task task = new TaskBoardController.Task(nullTask);
        
        String emptyLabel = '';
        Task_Checklist_Item__c foundTaskChecklistItem = task.findTaskChecklistItemByLabel(emptyLabel);
        system.assertEquals(null, foundTaskChecklistItem, 'No task checklist item should be found and it should be null.');
    }
    
    @isTest
    private static void updateTaskChecklistItemStatus_setTaskChecklistItemToCompleted_expectTaskChecklistItemStatusIsCompletedTest() {
        loadSetupData();
        
        String newTaskChecklistItemLabel = 'Some other checklist item';

        TaskBoardController.Task task = TaskBoardController.addTaskChecklistItem(DefaultTasks[0].Id, newTaskChecklistItemLabel);
        Task_Checklist_Item__c addedChecklistItem = task.findTaskChecklistItemByLabel(newTaskChecklistItemLabel);
        
        String completedTaskChecklistItemStatus = 'Completed';
        
        system.assertNotEquals(completedTaskChecklistItemStatus, addedChecklistItem.Status__c, 'The status is completed when it should not be.');
        
        Task_Checklist_Item__c updatedTaskChecklistItem = TaskBoardController.updateTaskChecklistItemStatus(addedChecklistItem.Id, completedTaskChecklistItemStatus);
        
        system.assertEquals(addedChecklistItem.Id, updatedTaskChecklistItem.Id, 'A different task checklist item was updated.');
        system.assertEquals(completedTaskChecklistItemStatus, updatedTaskChecklistItem.Status__c, 'A different task checklist item was updated.');
    }
    
    @isTest
    private static void uploadFileToTaskAsChatterFile_insertChatterFileOnTask_expectFileAttachedToTaskTest() {
        try {
	        loadSetupData();
	        
	        String fileName = 'Example.txt';
	        String fileContents = 'Some example text';
	        String base64FileContents = EncodingUtil.base64Encode( Blob.valueOf(fileContents) );
	        Task__c taskToUse = DefaultTasks[0];
	        
	        TaskBoardController.Task task = TaskBoardController.uploadFileToTaskAsChatterFile(taskToUse.Id, fileName, base64FileContents, null);
	        
	        system.assert(task != null, 'The task is null.');
	        system.assert(task.Task != null, 'The task does not have a task record.');
	        system.assertEquals(1, task.Task.ContentDocumentLinks.size(), 'The task does not have one content document link');
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }
    
    @isTest
    private static void completeTask_invokeWithNonCompletedTask_expectTaskSetToCompletedTest() {
        loadSetupData();
        Task__c taskToUse = DefaultTasks[0];
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.completeTask(taskToUse.Id, Opp.Id);
        
        assertTaskInStatusTaskListOnTaskBoard(taskBoard, taskToUse, CompletedTaskStatus.Name);
    }
    
    @isTest
    private static void updateTask_invokeWithTaskToUpdate_expectTaskUpdatedTest() {
        loadSetupData();
        Task__c taskToUpdate = DefaultTasks[0];
        
        taskToUpdate.Name = 'Some other task name';
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.updateTask(taskToUpdate, Opp.Id);
        TaskBoardController.Task task = taskBoard.findTaskByName(taskToUpdate.Name);
        
        system.assert(task != null, 'The updated task was not found.');
        system.assertEquals(taskToUpdate.Name, task.Task.Name, 'The task was not updated.');
    }
    
    @isTest
    private static void TaskChecklistItemsCompletedCount_setTaskChecklistItemToCompleted_expectTaskChecklistItemCountIncrementedTest() {
        loadSetupData();
        
        String newTaskChecklistItemLabel = 'Some other checklist item';

        TaskBoardController.Task task = TaskBoardController.addTaskChecklistItem(DefaultTasks[0].Id, newTaskChecklistItemLabel);
        
        system.assertEquals(0, task.TaskChecklistItemsCompletedCount, 'There should be no completed task checklist items.');
        
        Task_Checklist_Item__c addedChecklistItem = task.findTaskChecklistItemByLabel(newTaskChecklistItemLabel);
        
        String completedTaskChecklistItemStatus = 'Completed';
        
        system.assertNotEquals(completedTaskChecklistItemStatus, addedChecklistItem.Status__c, 'The status is completed when it should not be.');
        
        Task_Checklist_Item__c updatedTaskChecklistItem = TaskBoardController.updateTaskChecklistItemStatus(addedChecklistItem.Id, completedTaskChecklistItemStatus);
        
        task = TaskBoardController.getTask(task.Task.Id);
        system.assertEquals(1, task.TaskChecklistItemsCompletedCount, 'There should be one completed task checklist item.');
    }
    
    @isTest
    private static void getTaskBoardByProjectId_projectIdGiven_expectTaskBoardReturnedTest() {
        loadSetupData();
        
        Task__c firstTask = DefaultTasks[0];
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.getTaskBoardByProjectId(firstTask.Project__c);
        
        system.assert(taskBoard != null, 'The task board is null.');
        system.assert(taskBoard.RecordId != null, 'The task board did not have its record id populated.');
    }

    @isTest
    private static void updateTask_recordHasMultipleProjects_expectTasksProjectTasksOnlyReturnedTest() {
        loadSetupData();

        Project__c secondOppProject = ProjectTestData.Instance.withOpportunity(Opp.Id).insertProject();
        Task__c secondProjectTask = TaskTestData.Instance.withProject(secondOppProject.Id)
                                                         .withStatus(NotStartedTaskStatus.Id)
                                                         .insertTask();
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.updateTaskStatus(secondProjectTask.Id, InProgressTaskStatus.Id, Opp.Id);
        
        assertTaskSetToStatus(secondProjectTask.Id, InProgressTaskStatus.Id);
        assertTaskInStatusTaskListOnTaskBoard(taskBoard, secondProjectTask, InProgressTaskStatus.Name);
        
        system.assertEquals(1, taskBoard.NumberTasksOnTheBoard, 'The first project\'s tasks were included on the task board when they should not be.');
    }
    
    @isTest
    private static void completeTask_recordHasMultipleProjects_expectTasksProjectTasksOnlyReturnedTest() {
        loadSetupData();

        Project__c secondOppProject = ProjectTestData.Instance.withOpportunity(Opp.Id).insertProject();
        Task__c secondProjectTask = TaskTestData.Instance.withProject(secondOppProject.Id)
                                                         .withStatus(NotStartedTaskStatus.Id)
                                                         .insertTask();
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.completeTask(secondProjectTask.Id, Opp.Id);
        
        assertTaskSetToStatus(secondProjectTask.Id, CompletedTaskStatus.Id);
        assertTaskInStatusTaskListOnTaskBoard(taskBoard, secondProjectTask, CompletedTaskStatus.Name);
        
        system.assertEquals(1, taskBoard.NumberTasksOnTheBoard, 'The first project\'s tasks were included on the task board when they should not be.');
    }
    
    @isTest
    private static void addNewTask_recordHasMultipleProjects_expectTasksProjectTasksOnlyReturnedTest() {
        loadSetupData();

        Project__c secondOppProject = ProjectTestData.Instance.withOpportunity(Opp.Id).insertProject();
        Task__c secondProjectTask = TaskTestData.Instance.withProject(secondOppProject.Id)
                                                         .withStatus(NotStartedTaskStatus.Id)
                                                         .insertTask();
        
        String newTaskName = 'Some manual task';
        
        TaskBoardController.TaskBoard taskBoard = TaskBoardController.addNewTask(newTaskName, NotStartedTaskStatus.Id, secondOppProject.Id, Opp.Id);
        
        TaskBoardController.Task newTask = taskBoard.findTaskByName(newTaskName);
        system.assert(newTask != null, 'The new task was not found on the board.');
        
        system.assertEquals(2, taskBoard.NumberTasksOnTheBoard, 'The first project\'s tasks were included on the task board when they should not be.');
    }
}