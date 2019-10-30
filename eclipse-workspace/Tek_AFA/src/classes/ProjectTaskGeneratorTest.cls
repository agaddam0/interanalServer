/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ProjectTaskGeneratorTest {
    private static Project_Template__c ProjectTemplate { get; set; }
    private static Task_Template__c TaskTemplate { get; set; }
    private static Task_Template__c SubTaskTemplate { get; set; }
    private static Task_Checklist_Item_Template__c TaskChecklistItemTemplate { get; set; }
    private static Opportunity Opp { get; set; }
    private static Task_Status__c DefaultTaskStatus { get; set; }
    
    private static Map<Id, Project__c> ProjectsByProjectTemplate { get; set; }
    
    private static void generateProjectTasks(Id recordId, String projectTemplateName) {
        ProjectTaskUtil.generateProjectTasks(recordId, projectTemplateName);
    }
    
    private static void generateProjectTasks(Id recordId, List<Project_Template__c> projectTemplates) {
        ProjectTaskUtil.generateProjectTasks(recordId, projectTemplates);
    }
    
    private static Project__c getProject() {
        return getProjects()[0];
    }
    
    private static List<Project__c> getProjects() {
        return
        [SELECT Id,
                Name,
                Project_Template__c,
                Opportunity__c,
                Description__c,
                Task_Display_Field_Set__c,
                Task_Edit_Field_Set__c
           FROM Project__c];
    }
    
    private static Project__c getProjectByProjectTemplateId(Id projectTemplateId) {
        if (ProjectsByProjectTemplate == null) {
            ProjectsByProjectTemplate = new Map<Id, Project__c>();
            
            List<Project__c> projects = getProjects();
            
            for (Project__c project : projects) {
                ProjectsByProjectTemplate.put(project.Project_Template__c, project);
            }
        }
        
        return ProjectsByProjectTemplate.get(projectTemplateId);
    }
    
    private static List<Task__c> getTasks() {
        return
        [SELECT Id,
                Name,
                Actual_End_Date__c,
                Actual_Start_Date__c,
                Assignee__c,
                Due_Date__c,
                Description__c,
                Notes__c,
                Order__c,
                Predecessor_Task__c,
                Project__c,
                Projected_End_Date__c,
                Projected_Start_Date__c,
                Role__c,
                Status__c,
                Task_Template__c
           FROM Task__c];
    }
    
    private static Map<Id, Task__c> getTasksIndexedByTaskTemplate() {
        List<Task__c> tasks = getTasks();
        
        return indexTasksByTaskTemplate(tasks);
    }
    
    private static Map<Id, Task__c> indexTasksByTaskTemplate(List<Task__c> tasks) {
        Map<Id, Task__c> tasksByTaskTemplate = new Map<Id, Task__c>();
        
        for (Task__c task : tasks) {
            tasksByTaskTemplate.put(task.Task_Template__c, task);
        }
        
        return tasksByTaskTemplate;
    }
    
    private static Map<Id, Task_Checklist_Item__c> indexTaskChecklistItemsByTaskChecklistItemTemplate(List<Task_Checklist_Item__c> taskChecklistItems) {
        Map<Id, Task_Checklist_Item__c> taskChecklistItemsByTaskChecklistItemTemplate = new Map<Id, Task_Checklist_Item__c>();
        
        for (Task_Checklist_Item__c taskChecklistItem : taskChecklistItems) {
            taskChecklistItemsByTaskChecklistItemTemplate.put(taskChecklistItem.Task_Checklist_Item_Template__c, taskChecklistItem);
        }
        
        return taskChecklistItemsByTaskChecklistItemTemplate;
    }
    
    private static void assertTaskRecordsGenerated(Project_Template__c projTemplate, Task_Template__c taskTemp, Opportunity oppArg, Task_Status__c taskStatus) {
        assertTaskRecordsGenerated(projTemplate, new List<Task_Template__c>{ taskTemp }, oppArg, taskStatus);
    }
    
    private static void assertTaskRecordsGenerated(List<Project_Template__c> projectTemplates, Opportunity OppArg, Task_Status__c taskStatus) {
        Map<Id, List<Task_Template__c>> taskTemplatesByProjectTemplate = getTaskTemplatesByProjectTemplate(projectTemplates);
        
        for (Project_Template__c projTemplate : projectTemplates) {
            List<Task_Template__c> projectTaskTemplates = taskTemplatesByProjectTemplate.get(projTemplate.Id);
            
            assertTaskRecordsGenerated(projTemplate, projectTaskTemplates, OppArg, taskStatus);
        }
    }
    
    private static void assertTaskRecordsGenerated(Project_Template__c projectTemplateArg, List<Task_Template__c> taskTemplates, Opportunity oppArg, Task_Status__c taskStatus) {
        assertProjectGenerated(projectTemplateArg, opp);
        Map<Id, Task__c> tasksByTaskTemplate = getTasksIndexedByTaskTemplate();
        Map<Id, Task_Template__c> taskTemplatesById = new Map<Id, Task_Template__c>(taskTemplates);
        
        for (Task_Template__c taskTemp : taskTemplates) {
            Task__c generatedTask = tasksByTaskTemplate.get(taskTemp.Id);
            Task_Template__c predecessorTaskTemplate = taskTemplatesById.get(taskTemp.Predecessor_Task_Template__c);
            Task__c predecessorTask = tasksByTaskTemplate.get(taskTemp.Predecessor_Task_Template__c);
            
            assertTaskGenerated(taskTemp, generatedTask, oppArg, taskStatus, predecessorTaskTemplate, predecessorTask);
        }
    }
    
    private static void assertTaskGenerated(Task_Template__c taskTemplateArg, Task__c task, Opportunity oppArg, Task_Status__c taskStatus, Task_Template__c predecessorTaskTemplate, Task__c predecessorTask) {
        system.assert(taskTemplateArg != null, 'The task template is null.');
        system.assert(taskTemplateArg.Id != null, 'The task template was not inserted.');
        system.assert(task != null, 'The task is null.');
        system.assert(task.Id != null, 'The task was not inserted.');
        system.assert(oppArg != null, 'The opp is null.');
        system.assert(oppArg.Id != null, 'The opp was not inserted.');
        system.assert(defaultTaskStatus != null, 'The defaultTaskStatus is null.');
        system.assert(defaultTaskStatus.Id != null, 'The defaultTaskStatus was not inserted.');
        
        system.assertEquals(taskTemplateArg.Name, task.Name, 'The task was not named after the task template.');
        system.assertEquals(taskTemplateArg.Id, task.Task_Template__c, 'The task was not linked to the task template.');
        system.assertEquals(taskTemplateArg.Role__c, task.Role__c, 'The task\'s role was not set using the task template\'s role.');
        system.assertEquals(taskTemplateArg.Order__c, task.Order__c, 'The task\'s order was not set using the task template\'s order.');
        system.assertEquals(taskTemplateArg.Description__c, task.Description__c, 'The task\'s description was not set using the task template\'s description.');
        system.assertEquals(taskStatus.Id, task.Status__c, 'The task\'s status was not set using the default task status.');
        
        if (predecessorTaskTemplate != null) {
            system.assert(predecessorTask != null, 'No predecessor task found attached to the predecessor task template.');
            system.assert(predecessorTask.Id != null, 'The predecessor task was not inserted.');
            system.assertEquals(predecessorTask.Id, task.Predecessor_Task__c, 'The sub task was not linked to the predecessor task.');
        }
        
        assertDueDateCalculatedCorrectly(taskTemplateArg, task, oppArg);
        assertProjectedStartDateCalculatedCorrectly(taskTemplateArg, task, oppArg);
        assertProjectedEndDateCalculatedCorrectly(taskTemplateArg, task, oppArg);
        assertAssigneeCalculatedCorrectly(taskTemplateArg, task, oppArg);
        
        assertTaskChecklistItemsGenerated(taskTemplateArg, task);
    }
    
    private static void assertDueDateCalculatedCorrectly(Task_Template__c taskTemplateArg, Task__c task, SObject sourceRecord) {
        if (String.isBlank(taskTemplateArg.Due_Date_Record_Field__c) ||
            taskTemplateArg.Due_Date_Days_To_Add__c == null) {
            return;
        }
        
        Date expectedDueDate = ProjectTaskUtil.calculateDateFromSourceRecord(sourceRecord, taskTemplateArg.Due_Date_Record_Field__c, (Integer) taskTemplateArg.Due_Date_Days_To_Add__c);
        
        system.assertEquals(expectedDueDate, task.Due_Date__c, 'The task due date is not the expected one.');
    }
    
    private static void assertProjectedStartDateCalculatedCorrectly(Task_Template__c taskTemplateArg, Task__c task, SObject sourceRecord) {
        if (String.isBlank(taskTemplateArg.Projected_Start_Date_Record_Field__c) ||
            taskTemplateArg.Projected_Start_Date_Days_To_Add__c == null) {
            return;
        }
        
        Date expectedProjectedStartDate = ProjectTaskUtil.calculateDateFromSourceRecord(sourceRecord, taskTemplateArg.Projected_Start_Date_Record_Field__c, (Integer) taskTemplateArg.Projected_Start_Date_Days_To_Add__c);
        
        system.assertEquals(expectedProjectedStartDate, task.Projected_Start_Date__c, 'The task\'s projected start date is not the expected one.');
    }
    
    private static void assertProjectedEndDateCalculatedCorrectly(Task_Template__c taskTemplateArg, Task__c task, SObject sourceRecord) {
        if (String.isBlank(taskTemplateArg.Projected_End_Date_Record_Field__c) ||
            taskTemplateArg.Projected_End_Date_Days_To_Add__c == null) {
            return;
        }
        
        Date expectedProjectedEndDate = ProjectTaskUtil.calculateDateFromSourceRecord(sourceRecord, taskTemplateArg.Projected_End_Date_Record_Field__c, (Integer) taskTemplateArg.Projected_End_Date_Days_To_Add__c);
        
        system.assertEquals(expectedProjectedEndDate, task.Projected_End_Date__c, 'The task\'s projected end date is not the expected one.');
    }
    
    private static void assertAssigneeCalculatedCorrectly(Task_Template__c taskTemplateArg, Task__c task, SObject sourceRecord) {
        if (String.isBlank(taskTemplateArg.Auto_Assignment_Record_User_Field__c)) {
            return;
        }
        
        Id expectedAssigneeId = (Id) sourceRecord.get(taskTemplateArg.Auto_Assignment_Record_User_Field__c);
        
        system.assertEquals(expectedAssigneeId, task.Assignee__c, 'The task\'s assignee is not the expected one.');
    }
    
    private static void assertProjectGenerated(Project_Template__c projectTemplateArg, Opportunity oppArg) {
        system.assert(projectTemplateArg != null, 'The project template is null.');
        system.assert(oppArg != null, 'The opportunity is null.');
        system.assert(oppArg.Id != null, 'The opportunity is not inserted.');
        
        Project__c project = getProjectByProjectTemplateId(projectTemplateArg.Id);
        
        system.assertEquals(projectTemplateArg.Name, project.Name, 'The project was not named after the project template.');
        system.assertEquals(projectTemplateArg.Description__c, project.Description__c, 'The project\'s description was not named after the project template\'s description.');
        system.assertEquals(oppArg.Id, project.Opportunity__c, 'The project is not linked to the opportunity.');
        system.assertEquals(projectTemplateArg.Id, project.Project_Template__c, 'The project is not linked to the project template.');
        system.assertEquals(projectTemplateArg.Task_Edit_Field_Set__c, project.Task_Edit_Field_Set__c, 'The project task edit field set is not the expected one.');
        system.assertEquals(projectTemplateArg.Task_Display_Field_Set__c, project.Task_Display_Field_Set__c, 'The project task display field set is not the expected one.');
    }
    
    private static void assertTaskChecklistItemsGenerated(Task_Template__c taskTemplateArg, Task__c task) {
        if (taskTemplateArg.Task_Checklist_Item_Templates__r == null ||
            taskTemplateArg.Task_Checklist_Item_Templates__r.size() == 0) {
            return;
        }
        
        Map<Id, Task_Checklist_Item__c> taskChecklistItemsByTemplate = indexTaskChecklistItemsByTaskChecklistItemTemplate(task.Task_Checklist_Items__r);
        
        for (Task_Checklist_Item_Template__c template : taskTemplateArg.Task_Checklist_Item_Templates__r) {
            Task_Checklist_Item__c taskChecklistItem = taskChecklistItemsByTemplate.get(template.Id);
            
            assertTaskChecklistItemGenerated(template, taskChecklistItem);
        }
    }
    
    private static void assertTaskChecklistItemGenerated(Task_Checklist_Item_Template__c template, Task_Checklist_Item__c taskChecklistItem) {
        system.assert(template != null, 'The template is null.');
        system.assert(template.Id != null, 'The template was not inserted.');
        system.assert(taskChecklistItem != null, 'The task checklist item was not inserted.');
        system.assert(taskChecklistItem.Id != null, 'The task checklist item was not inserted.');
        
        system.assertEquals(template.Name, taskChecklistItem.Name, 'The task checklist item name was not from the template\'s name.');
        system.assertEquals(template.Order__c, taskChecklistItem.Order__c, 'The task checklist item\'s order was not set from the template\'s order.');
        system.assertEquals(template.Label__c, taskChecklistItem.Label__c, 'The task checklist item\'s label was not set from the template\'s label.');
        system.assertEquals(ProjectTaskGenerator.TASK_CHECKLIST_ITEM_DEFAULT_STATUS, taskChecklistItem.Status__c, 'The task checklist item\'s status was not set to the default status of ' + ProjectTaskGenerator.TASK_CHECKLIST_ITEM_DEFAULT_STATUS + '.');
    }
    
    private static void loadSetupDataIntoProperties() {
        ProjectTemplate = getProjectTemplate();
        TaskTemplate = getTaskTemplate();
        Opp = getOpportunity();
        DefaultTaskStatus = getDefaultTaskStatus();
    }
    
    private static Project_Template__c getProjectTemplate() {
        return
        [SELECT Id,
                Name,
                Description__c,
                Task_Display_Field_Set__c,
                Task_Edit_Field_Set__c
           FROM Project_Template__c];
    }
    
    private static Task_Template__c getTaskTemplate() {
        return getTaskTemplates()[0];
    }
    
    private static List<Task_Template__c> getTaskTemplates() {
        return
        [SELECT Id,
                Name,
                Auto_Assignment_Record_User_Field__c,
                Project_Template__c,
                Project_Template__r.Name,
                Project_Template__r.Id,
                Project_Template__r.Task_Edit_Field_Set__c,
                Project_Template__r.Task_Display_Field_Set__c,
                Due_Date_Days_To_Add__c,
                Due_Date_Record_Field__c,
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
                   FROM Task_Checklist_Item_Templates__r)
           FROM Task_Template__c];
    }
    
    private static Map<Id, List<Task_Template__c>> getTaskTemplatesByProjectTemplate(List<Project_Template__c> projectTemplates) {
        List<Task_Template__c> projectsTaskTemplates =
        [SELECT Id,
                Name,
                Auto_Assignment_Record_User_Field__c,
                Project_Template__c,
                Project_Template__r.Name,
                Project_Template__r.Id,
                Due_Date_Days_To_Add__c,
                Due_Date_Record_Field__c,
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
                   FROM Task_Checklist_Item_Templates__r)
           FROM Task_Template__c
          WHERE Project_Template__c in :projectTemplates];

        Map<Id, List<Task_Template__c>> taskTemplatesByProjectTemplate = new Map<Id, List<Task_Template__c>>();
        
        for (Task_Template__c template : projectsTaskTemplates) {
            List<Task_Template__c> projectTaskTemplates = taskTemplatesByProjectTemplate.get(template.Project_Template__c);
            
            if (projectTaskTemplates == null) {
                projectTaskTemplates = new List<Task_Template__c>();
                taskTemplatesByProjectTemplate.put(template.Project_Template__c, projectTaskTemplates);
            }
            
            projectTaskTemplates.add(template);
        }
        
        return taskTemplatesByProjectTemplate;
    }
    
    private static Opportunity getOpportunity() {
        return
        [SELECT Id,
                Name,
                Enrollment_Start_Date__c,
                Assigned_Account_Manager__c,
                AccountId,
                Account.Name,
                Account.CreatedBy.Name
           FROM Opportunity];
    }
    
    private static Task_Status__c getDefaultTaskStatus() {
        return
        [SELECT Id,
                Name,
                Order__c
           FROM Task_Status__c
         ORDER BY Order__c
         Limit 1];
    }
    
    private static void testGenerateWithDueDateSettings(String dueDateRecordField, Integer dueDateDaysToAdd) {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Due_Date_Record_Field__c = dueDateRecordField;
        TaskTemplate.Due_Date_Days_To_Add__c = dueDateDaysToAdd;
        update TaskTemplate;
        
        loadSetupDataIntoProperties();
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        assertTaskRecordsGenerated(ProjectTemplate, TaskTemplate, Opp, DefaultTaskStatus);
    }
    
    private static void testGenerateWithProjectedStartDateSettings(String projectedStartDateRecordField, Integer projectedStartDateDaysToAdd) {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Projected_Start_Date_Record_Field__c = projectedStartDateRecordField;
        TaskTemplate.Projected_Start_Date_Days_To_Add__c = projectedStartDateDaysToAdd;
        update TaskTemplate;
        
        loadSetupDataIntoProperties();
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        assertTaskRecordsGenerated(ProjectTemplate, TaskTemplate, Opp, DefaultTaskStatus);
    }
    
    private static void testGenerateWithProjectedEndDateSettings(String projectedEndDateRecordField, Integer projectedEndDateDaysToAdd) {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Projected_End_Date_Record_Field__c = projectedEndDateRecordField;
        TaskTemplate.Projected_End_Date_Days_To_Add__c = projectedEndDateDaysToAdd;
        update TaskTemplate;
        
        loadSetupDataIntoProperties();
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        assertTaskRecordsGenerated(ProjectTemplate, TaskTemplate, Opp, DefaultTaskStatus);
    }
    
    private static void testGenerateWithMultipleTasks(Integer numberOfTasksToCreate) {
        loadSetupDataIntoProperties();
        
        List<Task_Template__c> taskTemplatesToInsert = new List<Task_Template__c>();
        
        for (Integer i = 0; i < numberOfTasksToCreate; ++i) {
            Task_Template__c taskTemplateToInsert = TaskTemplateTestData.Instance.withProjectTemplate(ProjectTemplate.Id)
                                                                                 .withProjectedEndDateRecordField('Enrollment_Start_Date__c')
                                                                                 .withProjectedEndDateDaysToAdd(10)
                                                                                 .create();
            taskTemplatesToInsert.add(taskTemplateToInsert);
        }
        
        insert taskTemplatesToInsert;
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        List<Task_Template__c> taskTemplates = getTaskTemplates();
        
        assertTaskRecordsGenerated(ProjectTemplate, taskTemplates, Opp, DefaultTaskStatus);
    }
    
    private static void testGenerateWithMultipleProjectsAndMultipleTasks(Integer numberOfProjectsToCreate, Integer numberOfTasksToCreate) {
        loadSetupDataIntoProperties();
        
        List<Project_Template__c> projectTemplatesToInsert = new List<Project_Template__c>();
        
        for (Integer i = 0; i < numberOfProjectsToCreate; ++i) {
            Project_Template__c projectTemplateToInsert = ProjectTemplateTestData.Instance.withName('Project' + i).create();
            projectTemplatesToInsert.add(projectTemplateToInsert);
        }
        
        insert projectTemplatesToInsert;
        
        List<Task_Template__c> taskTemplatesToInsert = new List<Task_Template__c>();
        
        for (Project_Template__c insertedProjectTemplate : projectTemplatesToInsert) {
	        for (Integer i = 0; i < numberOfTasksToCreate; ++i) {
	            Task_Template__c taskTemplateToInsert = TaskTemplateTestData.Instance.withProjectTemplate(insertedProjectTemplate.Id)
	                                                                                 .withName('Task ' + i)
	                                                                                 .create();
	            taskTemplatesToInsert.add(taskTemplateToInsert);
	        }
        }
        
        insert taskTemplatesToInsert;
        
        generateProjectTasks(Opp.Id, projectTemplatesToInsert);
        
        assertTaskRecordsGenerated(projectTemplatesToInsert, Opp, DefaultTaskStatus);
    }
    
    @testSetup
    private static void setup() {
        DefaultTaskStatus = TaskStatusTestData.Instance.insertTaskStatus();
        ProjectTemplate = ProjectTemplateTestData.Instance.insertProjectTemplate();
        TaskTemplate = TaskTemplateTestData.Instance.withProjectTemplate(ProjectTemplate.Id).insertTaskTemplate();
        
        Opp = OpportunityTestData.Instance.withEnrollmentStartDate(Date.Today().addDays(-10))
                                          .withAssignedAccountManager(UserInfo.getUserId())
                                          .insertAFESOpportunity();
    }
    
    @isTest
    static void generate_withOneProjectAndOneSimpleTaskTemplate_expectProjectGeneratedAndTaskGeneratedTest() {
        loadSetupDataIntoProperties();
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        assertTaskRecordsGenerated(ProjectTemplate, TaskTemplate, Opp, DefaultTaskStatus);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithDueDateFutureSettings_expectProjectGeneratedAndTaskGeneratedWithFutureDueDateTest() {
        testGenerateWithDueDateSettings('Enrollment_Start_Date__c', 10);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithDueDatePastSettings_expectProjectGeneratedAndTaskGeneratedWithPastDueDateTest() {
        testGenerateWithDueDateSettings('Enrollment_Start_Date__c', -10);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithDueDateSameAsSourceDateSettings_expectProjectGeneratedAndTaskGeneratedWithSourceDateTest() {
        testGenerateWithDueDateSettings('Enrollment_Start_Date__c', 0);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithProjectedStartDateFutureSettings_expectProjectGeneratedAndTaskGeneratedWithFutureProjectedStartDateTest() {
        testGenerateWithProjectedStartDateSettings('Enrollment_Start_Date__c', 10);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithProjectedStartPastSettings_expectProjectGeneratedAndTaskGeneratedWithPastProjectedStartDateTest() {
        testGenerateWithProjectedStartDateSettings('Enrollment_Start_Date__c', -10);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithProjectedStartDateSameAsSourceDateSettings_expectProjectGeneratedAndTaskGeneratedWithSourceDateTest() {
        testGenerateWithProjectedStartDateSettings('Enrollment_Start_Date__c', 0);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithProjectedEndDateFutureSettings_expectProjectGeneratedAndTaskGeneratedWithFutureProjectedEndDateTest() {
        testGenerateWithProjectedEndDateSettings('Enrollment_Start_Date__c', 10);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithProjectedEndPastSettings_expectProjectGeneratedAndTaskGeneratedWithPastProjectedEndDateTest() {
        testGenerateWithProjectedEndDateSettings('Enrollment_Start_Date__c', -10);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithProjectedEndDateSameAsSourceDateSettings_expectProjectGeneratedAndTaskGeneratedWithSourceDateTest() {
        testGenerateWithProjectedEndDateSettings('Enrollment_Start_Date__c', 0);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskTemplateWithAutoAssignmentSetting_expectProjectGeneratedAndTaskGeneratedWithAssigneeSetTest() {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Auto_Assignment_Record_User_Field__c = 'Assigned_Account_Manager__c';
        update TaskTemplate;
        
        loadSetupDataIntoProperties();
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        assertTaskRecordsGenerated(ProjectTemplate, TaskTemplate, Opp, DefaultTaskStatus);
    }
    
    @isTest
    static void generate_withOneProjectAndOneSimpleTaskTemplateAndOneTaskChecklistItem_expectOneProjectGeneratedAndOneTaskGeneratedAndOneTaskChecklistItemGeneratedTest() {
        loadSetupDataIntoProperties();
        
        TaskChecklistItemTemplate = TaskChecklistItemTemplateTestData.Instance.withTaskTemplate(TaskTemplate.Id).insertTaskChecklistItemTemplate();
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        assertTaskRecordsGenerated(ProjectTemplate, TaskTemplate, Opp, DefaultTaskStatus);
    }
    
    @isTest
    static void generate_withOneProjectAndTwoTaskTemplates_expectOneProjectGeneratedAndTwoTasksGeneratedTest() {
        testGenerateWithMultipleTasks(2);
    }
    
    @isTest
    static void generate_withOneProjectAndTwoHundredTaskTemplates_expectOneProjectGeneratedAndTwoHundredTasksGeneratedTest() {
        testGenerateWithMultipleTasks(200);
    }
    
    @isTest
    static void generate_WithTwoProjectsAndTwoHundredTaskTemplatesPerProject_expectTwoProjectsCreatedAndTwoHundredTasksGeneratedPerProjectTest() {
        testGenerateWithMultipleProjectsAndMultipleTasks(2, 200);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskWithOneSubTask_expectOneProjectCreatedAndOneTaskCreatedAndOneSubTaskCreatedTest() {
        loadSetupDataIntoProperties();
        
        SubTaskTemplate = TaskTemplateTestData.Instance.withPredecessorTaskTemplate(TaskTemplate.Id)
                                                       .withProjectTemplate(TaskTemplate.Project_Template__c)
                                                       .insertTaskTemplate();
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        assertTaskRecordsGenerated(ProjectTemplate, new List<Task_Template__c> { TaskTemplate, SubTaskTemplate }, Opp, DefaultTaskStatus);
    }
    
    @isTest
    static void generate_withOneProjectAndOneTaskWithOneSubTaskAndOneSubSubTask_expectOneProjectCreatedAndOneTaskCreatedAndOneSubTaskCreatedAndOneSubSubTaskCreatedTest() {
        loadSetupDataIntoProperties();
        
        SubTaskTemplate = TaskTemplateTestData.Instance.withPredecessorTaskTemplate(TaskTemplate.Id)
                                                       .withProjectTemplate(TaskTemplate.Project_Template__c)
                                                       .insertTaskTemplate();
                                                       
        Task_Template__c SubSubTaskTemplate = TaskTemplateTestData.Instance.withPredecessorTaskTemplate(SubTaskTemplate.Id)
                                                                           .withProjectTemplate(TaskTemplate.Project_Template__c)
                                                                           .insertTaskTemplate();
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        assertTaskRecordsGenerated(ProjectTemplate, new List<Task_Template__c> { TaskTemplate, SubTaskTemplate, SubSubTaskTemplate }, Opp, DefaultTaskStatus);
    }
    
    @isTest
    static void generate_ProjectTemplateNotFound_expectNoExceptionsThrownTest() {
        loadSetupDataIntoProperties();
        
        String nonExistentProjectName = ProjectTemplate.Name + 'non existent';
        Exception exceptionThrown = null;
        
        try {
            generateProjectTasks(Opp.Id, nonExistentProjectName);
        }
        catch(Exception ex) {
            exceptionThrown = ex;
        }
        
        system.assertEquals(null, exceptionThrown, 'An unexpected exception was thrown. ' + exceptionThrown);
    }
    
    @isTest
    static void generate_ProjectTemplateNameWithAccountFieldToMerge_expectProjectNameHasAccountNameInItTest() {
        loadSetupDataIntoProperties();
        
        ProjectTemplate.Name = '{Account.Name}-Onboarding Tasks';
        update ProjectTemplate;
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        Project__c project = getProjectByProjectTemplateId(ProjectTemplate.Id);
        
        system.assert(project.Name.containsIgnoreCase(Opp.Account.Name), 'The project name does not have the account name in it. Project Name: ' + project.Name);
    }
    
    @isTest
    static void generate_ProjectTemplateNameWithTwoMergeFieldsToMerge_expectProjectNameHasBothFieldValuesInItTest() {
        loadSetupDataIntoProperties();
        
        ProjectTemplate.Name = '{Account.Name}-{Account.CreatedBy.Name}Onboarding Tasks';
        update ProjectTemplate;
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        Project__c project = getProjectByProjectTemplateId(ProjectTemplate.Id);
        
        system.assert(project.Name.containsIgnoreCase(Opp.Account.Name), 'The project name does not have the account name in it. Project Name: ' + project.Name);
        system.assert(project.Name.containsIgnoreCase(Opp.Account.CreatedBy.Name), 'The project name does not have the account\'s created by name in it. Project Name: ' + project.Name);
    }
    
    @isTest
    static void generate_ProjectTemplateNameWithOneNonParentMergeFieldToMerge_expectProjectNameHasFieldValuesInItTest() {
        loadSetupDataIntoProperties();
        
        ProjectTemplate.Name = '{Id}-Onboarding Tasks';
        update ProjectTemplate;
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        Project__c project = getProjectByProjectTemplateId(ProjectTemplate.Id);
        
        system.assert(project.Name.containsIgnoreCase(Opp.Id), 'The project name does not have the opportunity id in it. Project Name: ' + project.Name);
    }
    
    @isTest
    static void generate_ProjectTemplateTaskDisplayFieldSetFieldPopulatedAndTaskEditFieldSetFieldFieldToMerge_expectProjectFieldSetValuesInItTest() {
        loadSetupDataIntoProperties();
        
        ProjectTemplate.Task_Display_Field_Set__c = 'Other Task Display Field Set';
        ProjectTemplate.Task_Edit_Field_Set__c = 'Other Task Edit Field Set';
        update ProjectTemplate;
        
        generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        Project__c project = getProjectByProjectTemplateId(ProjectTemplate.Id);
        
        system.assertEquals(ProjectTemplate.Task_Display_Field_Set__c, project.Task_Display_Field_Set__c, 'The project task display field set is not the expected one.');
        system.assertEquals(ProjectTemplate.Task_Edit_Field_Set__c, project.Task_Edit_Field_Set__c, 'The project task display field set is not the expected one.');
    }
}