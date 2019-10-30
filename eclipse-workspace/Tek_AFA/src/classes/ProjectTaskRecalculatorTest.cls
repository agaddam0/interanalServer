@isTest
private class ProjectTaskRecalculatorTest {
    private static Project_Template__c ProjectTemplate { get; set; }
    private static Task_Template__c TaskTemplate { get; set; }
    private static Opportunity Opp { get; set; }
    private static Project__c Project { get; set; }
    private static Task__c Task { get; set; }
    
    private static Date DefaultEnrollmentStartDate { get; set; }
    
    private static void loadDefaultEnrollmentStartDate() {
        DefaultEnrollmentStartDate = Date.Today().addDays(30);
    }
    
    private static void loadSetupDataIntoProperties() {
        Task = getTask();
        TaskTemplate = Task.Task_Template__r;
        ProjectTemplate = TaskTemplate.Project_Template__r;
        Project = Task.Project__r;
        Opp = Project.Opportunity__r;
    }
    
    private static void deleteExistingRecords() {
        if (Opp != null && Opp.Id != null) {
            delete Opp;
        }

        system.debug('    deleteExistingNonTemplateRecords::Project ' + Project);
        
        if (Project != null && Project.Id != null) {
            delete Project;
        }
        
        if (ProjectTemplate != null && ProjectTemplate.Id != null) {
            delete ProjectTemplate;
        }
    }
    
    private static Task__c getTaskById(Id taskId) {
        List<Task__c> tasks = getTasksByIds(new Set<Id>{ taskId });
        
        if (tasks.size() > 0) {
            return tasks[0];
        }
        
        return null;
    }
    
    private static List<Task__c> getTasksByIds(Set<Id> taskIds) {
        return
        [SELECT Id,
                Name,
                Due_Date__c,
                Projected_Start_Date__c,
                Projected_End_Date__c,
                Project__c,
                Project__r.Id,
                Project__r.Opportunity__c,
                Project__r.Opportunity__r.Id,
                Project__r.Opportunity__r.Enrollment_Start_Date__c,
                Task_Template__c,
                Task_Template__r.Id,
                Task_Template__r.Due_Date_Record_Field__c,
                Task_Template__r.Due_Date_Days_To_Add__c,
                Task_Template__r.Recalculate_Due_Date__c,
                Task_Template__r.Projected_Start_Date_Record_Field__c,
                Task_Template__r.Projected_Start_Date_Days_To_Add__c,
                Task_Template__r.Recalculate_Projected_Start_Date__c,
                Task_Template__r.Projected_End_Date_Record_Field__c,
                Task_Template__r.Projected_End_Date_Days_To_Add__c,
                Task_Template__r.Recalculate_Projected_End_Date__c,
                Task_Template__r.Project_Template__c,
                Task_Template__r.Project_Template__r.Id,
                Task_Template__r.Project_Template__r.Name
           FROM Task__c
          WHERE Id in :taskIds];
    }
    
    private static Task__c getTask() {
        return getTasks()[0];
    }
    
    private static List<Task__c> getTasks() {
        return
        [SELECT Id,
                Name,
                Actual_End_Date__c,
                Actual_Start_Date__c,
                Assignee__c,
                Due_Date__c,
                Notes__c,
                Order__c,
                Predecessor_Task__c,
                Projected_End_Date__c,
                Projected_Start_Date__c,
                Role__c,
                Status__c,
                Task_Template__c,
                Task_Template__r.Id,
                Task_Template__r.Due_Date_Record_Field__c,
                Task_Template__r.Due_Date_Days_To_Add__c,
                Task_Template__r.Recalculate_Due_Date__c,
                Task_Template__r.Projected_Start_Date_Record_Field__c,
                Task_Template__r.Projected_Start_Date_Days_To_Add__c,
                Task_Template__r.Recalculate_Projected_Start_Date__c,
                Task_Template__r.Projected_End_Date_Record_Field__c,
                Task_Template__r.Projected_End_Date_Days_To_Add__c,
                Task_Template__r.Recalculate_Projected_End_Date__c,
                Task_Template__r.Project_Template__c,
                Task_Template__r.Project_Template__r.Id,
                Task_Template__r.Project_Template__r.Name,
                Project__c,
                Project__r.Id,
                Project__r.Opportunity__c,
                Project__r.Opportunity__r.Id,
                Project__r.Opportunity__r.Enrollment_Start_Date__c
           FROM Task__c];
    }
    
    private static void assertTaskDueDateUnchanged(Task__c taskToAssert) {
        assertTaskDateUnchanged(taskToAssert, 'Due_Date__c');
    }
    
    private static void assertTaskDueDateChanged(Task__c taskToAssert) {
        assertTaskDateChanged(taskToAssert, 'Due_Date_Record_Field__c', 'Due_Date_Days_To_Add__c', 'Due_Date__c');
    }
    
    private static void assertTaskProjectedStartDateUnchanged(Task__c taskToAssert) {
        assertTaskDateUnchanged(taskToAssert, 'Projected_Start_Date__c');
    }
    
    private static void assertTaskProjectedStartDateChanged(Task__c taskToAssert) {
        assertTaskDateChanged(taskToAssert, 'Projected_Start_Date_Record_Field__c', 'Projected_Start_Date_Days_To_Add__c', 'Projected_Start_Date__c');
    }
    
    private static void assertTaskProjectedEndDateUnchanged(Task__c taskToAssert) {
        assertTaskDateUnchanged(taskToAssert, 'Projected_End_Date__c');
    }
    
    private static void assertTaskProjectedEndDateChanged(Task__c taskToAssert) {
        assertTaskDateChanged(taskToAssert, 'Projected_End_Date_Record_Field__c', 'Projected_End_Date_Days_To_Add__c', 'Projected_End_Date__c');
    }
    
    private static void assertTaskDateUnchanged(Task__c taskToAssert, String taskDateField) {
        system.assert(taskToAssert != null, 'The task is null.');
        system.assert(taskToAssert.Id != null, 'The task is not inserted.');
        
        Task__c queriedTask = getTaskById(taskToAssert.Id);
        
        system.assert(queriedTask != null, 'The queried task is null.');
        
        Date expectedDate = (Date) task.get(taskDateField);
        
        system.assertEquals(expectedDate, (Date) queriedTask.get(taskDateField), 'The task\'s projected end date was changed.');
    }
    
    private static void assertTaskDateChanged(Task__c taskToAssert, String taskTemplateRecordField, String taskTemplateDaysToAddField, String taskDateField) {
        system.assert(taskToAssert != null, 'The task is null.');
        system.assert(taskToAssert.Id != null, 'The task is not inserted.');
        
        Task__c queriedTask = getTaskById(taskToAssert.Id);
        
        system.assert(queriedTask != null, 'The queried task is null.');
        
        Opportunity newOpp = queriedTask.Project__r.Opportunity__r;
        Task_Template__c taskTemplateQueried = queriedTask.Task_Template__r;
        
        String dateRecordField = (String) taskTemplateQueried.get(taskTemplateRecordField);
        Integer dateDaysToAdd = Integer.valueOf((Decimal) taskTemplateQueried.get(taskTemplateDaysToAddField));
        
        Date expectedNewDate = ProjectTaskUtil.calculateDateFromSourceRecord(newOpp, dateRecordField, dateDaysToAdd);
        
        system.assertEquals(expectedNewDate, (Date) queriedTask.get(taskDateField), 'The task\'s ' + taskDateField + ' was not changed to the expected new projected end date.');
    }
    
    private static void assertTaskDateChangedOnQueriedTask(Task__c queriedTask, String taskTemplateRecordField, String taskTemplateDaysToAddField, String taskDateField) {
        system.assert(queriedTask != null, 'The queried task is null.');
        
        Opportunity newOpp = queriedTask.Project__r.Opportunity__r;
        Task_Template__c taskTemplateQueried = queriedTask.Task_Template__r;
        
        String dateRecordField = (String) taskTemplateQueried.get(taskTemplateRecordField);
        Integer dateDaysToAdd = Integer.valueOf((Decimal) taskTemplateQueried.get(taskTemplateDaysToAddField));
        
        Date expectedNewDate = ProjectTaskUtil.calculateDateFromSourceRecord(newOpp, dateRecordField, dateDaysToAdd);
        
        system.assertEquals(expectedNewDate, (Date) queriedTask.get(taskDateField), 'The task\'s ' + taskDateField + ' was not changed to the expected new projected end date.');
    }
    
    private static void assertTasksProjectedEndDateChanged(List<Task__c> updatedQueriedTasks) {
        for (Task__c updatedQueriedTask : updatedQueriedTasks) {
            assertTaskDateChangedOnQueriedTask(updatedQueriedTask, 'Projected_End_Date_Record_Field__c', 'Projected_End_Date_Days_To_Add__c', 'Projected_End_Date__c');
        }
    }
    
    private static void assertNoErrorsWhenRecalculatingTaskDates(Map<Id, SObject> oldRecords, Map<Id, SObject> newRecords) {
        Exception exceptionThrown = null;
        
        try {
            ProjectTaskRecalculator recalculator = new ProjectTaskRecalculator();
            recalculator.recalculateTaskDates(oldRecords, newRecords);
        }
        catch (Exception ex) {
            exceptionThrown = ex;
        }
        
        system.assertEquals(null, exceptionThrown, 'An unexpected exception was thrown. ' + exceptionThrown);
    }

    @testSetup
    private static void setup() {
        TaskStatusTestData.Instance.insertTaskStatus();
        ProjectTemplate = ProjectTemplateTestData.Instance.insertProjectTemplate();

        TaskTemplate = TaskTemplateTestData.Instance.withProjectTemplate(ProjectTemplate.Id)
                                                    .withDueDateRecordField('Enrollment_Start_Date__c')
                                                    .withDueDateDaysToAdd(10)
                                                    .withProjectedStartDateRecordField('Enrollment_Start_Date__c')
                                                    .withProjectedStartDateDaysToAdd(20)
                                                    .withProjectedEndDateRecordField('Enrollment_Start_Date__c')
                                                    .withProjectedEndDateDaysToAdd(30)
                                                    .insertTaskTemplate();
        
        loadDefaultEnrollmentStartDate();
        
        Opp = OpportunityTestData.Instance.withEnrollmentStartDate(DefaultEnrollmentStartDate)
                                          .withAssignedAccountManager(UserInfo.getUserId())
                                          .insertAFESOpportunity();

        ProjectTaskUtil.generateProjectTasks(Opp.Id, ProjectTemplate.Name);
    }
    
    

    @isTest
    static void recalculateTaskDates_recalculateDueDateFalseAndDueDateSourceFieldChanged_expectTaskDueDateUnchangedTest() {
        loadSetupDataIntoProperties();
        
        Opp.Enrollment_Start_Date__c = Opp.Enrollment_Start_Date__c.addDays(15);
        update Opp;
        
        assertTaskDueDateUnchanged(Task);
    }
    
    @isTest
    static void recalculateTaskDates_recalculateDueDateTrueAndDueDateSourceFieldChangedToDifferentDate_expectTaskDueDateChangedTest() {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Recalculate_Due_Date__c = true;
        update TaskTemplate;
        
        Opp.Enrollment_Start_Date__c = Opp.Enrollment_Start_Date__c.addDays(15);
        update Opp;
        
        assertTaskDueDateChanged(Task);
    }
    
    @isTest
    static void recalculateTaskDates_recalculateDueDateTrueAndDueDateSourceFieldChangedToNull_expectTaskDueDateUnChangedTest() {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Recalculate_Due_Date__c = true;
        update TaskTemplate;
        
        Opp.Enrollment_Start_Date__c = null;
        update Opp;
        
        assertTaskDueDateUnchanged(Task);
    }
    
    @isTest
    static void recalculateTaskDates_recalculateProjectedStartDateFalseAndProjectedStartDateSourceFieldChanged_expectTaskProjectedStartDateUnchangedTest() {
        loadSetupDataIntoProperties();
        
        Opp.Enrollment_Start_Date__c = Opp.Enrollment_Start_Date__c.addDays(15);
        update Opp;
        
        assertTaskProjectedStartDateUnchanged(Task);
    }
    
    @isTest
    static void recalculateTaskDates_recalculateProjectedStartDateTrueAndProjectedStartDateSourceFieldChangedToDifferentDate_expectTaskProjectedStartDateChangedTest() {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Recalculate_Projected_Start_Date__c = true;
        update TaskTemplate;
        
        Opp.Enrollment_Start_Date__c = Opp.Enrollment_Start_Date__c.addDays(15);
        update Opp;
        
        assertTaskProjectedStartDateChanged(Task);
    }
    
    @isTest
    static void recalculateTaskDates_recalculateProjectedStartDateTrueAndProjectedStartDateSourceFieldChangedToNull_expectTaskProjectedStartDateUnChangedTest() {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Recalculate_Projected_Start_Date__c = true;
        update TaskTemplate;
        
        Opp.Enrollment_Start_Date__c = null;
        update Opp;
        
        assertTaskProjectedStartDateUnchanged(Task);
    }
    
    @isTest
    static void recalculateTaskDates_recalculateProjectedEndDateFalseAndProjectedEndDateSourceFieldChanged_expectTaskProjectedEndDateUnchangedTest() {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Recalculate_Projected_End_Date__c = false;
        update TaskTemplate;
        
        Opp.Enrollment_Start_Date__c = Opp.Enrollment_Start_Date__c.addDays(15);
        update Opp;
        
        assertTaskProjectedEndDateUnchanged(Task);
    }
    
    @isTest
    static void recalculateTaskDates_recalculateProjectedEndDateTrueAndProjectedEndDateSourceFieldChangedToDifferentDate_expectTaskProjectedEndDateChangedTest() {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Recalculate_Projected_End_Date__c = true;
        update TaskTemplate;
        
        Opp.Enrollment_Start_Date__c = Opp.Enrollment_Start_Date__c.addDays(15);
        update Opp;
        
        assertTaskProjectedEndDateChanged(Task);
    }
    
    @isTest
    static void recalculateTaskDates_recalculateProjectedEndDateTrueAndProjectedEndDateSourceFieldChangedToNull_expectTaskProjectedEndDateUnChangedTest() {
        loadSetupDataIntoProperties();
        
        TaskTemplate.Recalculate_Projected_End_Date__c = true;
        update TaskTemplate;
        
        Opp.Enrollment_Start_Date__c = null;
        update Opp;
        
        assertTaskProjectedEndDateUnchanged(Task);
    }
    
    @isTest
    static void recalculateTaskDates_MultipleTasksAndRecalculateProjectedEndDateTrueAndProjectedEndDateSourceFieldChangedToDifferentDate_expectAllTasksProjectedEndDateChangedTest() {
        loadSetupDataIntoProperties();
        deleteExistingRecords();
        
        Opportunity originalOpportunity = Opp;
        
        Integer numberOfTasksToInsert = 300;
        
        List<Task__c> tasks = getTasks();
        
        system.assertEquals(0, tasks.size(), 'There should be no existing tasks.');
        
        ProjectTemplate = ProjectTemplateTestData.Instance.insertProjectTemplate();
        List<Task_Template__c> taskTemplates = 
                       TaskTemplateTestData.Instance.withProjectTemplate(ProjectTemplate.Id)
                                                    .withDueDateRecordField('Enrollment_Start_Date__c')
                                                    .withDueDateDaysToAdd(10)
                                                    .withProjectedStartDateRecordField('Enrollment_Start_Date__c')
                                                    .withProjectedStartDateDaysToAdd(20)
                                                    .withProjectedEndDateRecordField('Enrollment_Start_Date__c')
                                                    .withProjectedEndDateDaysToAdd(30)
                                                    .withRecalculateProjectedEndDate(true)
                                                    .insertTaskTemplates(numberOfTasksToInsert);
        
        Opp = OpportunityTestData.Instance.withEnrollmentStartDate(DefaultEnrollmentStartDate)
                                          .withAssignedAccountManager(UserInfo.getUserId())
                                          .insertAFESOpportunity();

        ProjectTaskUtil.generateProjectTasks(Opp.Id, ProjectTemplate.Name);
        
        Test.startTest();
        
        Opp.Enrollment_Start_Date__c = originalOpportunity.Enrollment_Start_Date__c.addDays(55);
        update Opp;
        
        Test.stopTest();
        
        List<Task__c> updatedTasks = getTasks();
        
        system.assertEquals(numberOfTasksToInsert, updatedTasks.size(), 'The number of expected tasks were not found.');
        
        assertTasksProjectedEndDateChanged(updatedTasks);
    }
    
    @isTest
    static void recalculateTaskDates_nullRecords_expectNoExceptionsThrownAndNothingHappensTest() {
        loadSetupDataIntoProperties();
        
        Map<Id, Opportunity> nullOldOpportunityRecords = null;
        Map<Id, Opportunity> nullNewOpportunityRecords = null;
        
        assertNoErrorsWhenRecalculatingTaskDates(nullOldOpportunityRecords, nullNewOpportunityRecords);
    }
    
    @isTest
    static void recalculateTaskDates_accountRecordsButNoProjectLookupToAccount_expectNoExceptionsThrownAndNothingHappensTest() {
        Account account = AccountTestData.Instance.insertAccount();
        
        Map<Id, Account> oldAccounts = new Map<Id, Account>{ account.Id => account };
        Map<Id, Account> newAccounts = new Map<Id, Account>{ account.Id => account };
        
        assertNoErrorsWhenRecalculatingTaskDates(oldAccounts, newAccounts);
    }
}