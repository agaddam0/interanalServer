@isTest
public with sharing class MyTasksAFControllerTest {
    private static Task_Status__c NotNeededTaskStatus;
    private static Task_Status__c InProgressTaskStatus;
    private static Task_Status__c CompletedTaskStatus;
    private static Task_Status__c NotStartedTaskStatus;
    private static Task_Status__c WaitingOnHoldTaskStatus;
    private static List<Task_Status__c> TaskStatuses;
    
    static void assertNoTaskRecords(List<MyTasksAFController.TaskRecord> taskRecords) {
        system.assert(taskRecords != null, 'The task records list is null.');
        system.assertEquals(0, taskRecords.size(), 'There should be no task records.');
    }
    
    static void assertExpectedRecordsCount(List<MyTasksAFController.TaskRecord> taskRecords, Integer expectedCount) {
        system.assert(taskRecords != null, 'The task records list is null.');
        system.assertEquals(expectedCount, taskRecords.size(), 'There should be ' + expectedCount + ' task records.');
    }
    
    static List<Task_Status__c> getTaskStatuses() {
        return
        [SELECT Id,
                Name,
                Order__c,
                Completed__c,
                Display_On_Task_Board__c
           FROM Task_Status__c];
    }
    
    static void loadSetupData() {
        TaskStatuses = getTaskStatuses();
        
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
    
    static Task__c getCustomTaskById(Id taskId) {
        return
        [SELECT Id,
                Name,
                Status__c,
                Status__r.Name,
                Due_Date__c
           FROM Task__c
          WHERE Id = :taskId];
    }
    
    static Task getStandardTaskById(Id taskId) {
        return
        [SELECT Id,
                Subject,
                Status,
                ActivityDate
           FROM Task
          WHERE Id = :taskId];
    }
    
    @testSetup
    static void setup() {
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
    }
    
    @isTest
    static void getMyTasks_allOpenNoTasks_expectNothingReturnedTest() {
        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('AllOpen');
        
        assertNoTaskRecords(taskRecords);
    }
    
    @isTest
    static void getMyTasks_allOpenWithOneStandardTask_expectOneTaskReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('AllOpen');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_overdueFilterAndOneStandardOverdueTask_expectOneTaskReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(-1)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('Overdue');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_overdueFilterAndOneStandardDueTodayTask_expectNoTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today()).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('Overdue');
        
        assertNoTaskRecords(taskRecords);
    }
    
    @isTest
    static void getMyTasks_todayFilterAndOneStandardOverdueTask_expectNoTaskReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(-1)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('Today');
        
        assertNoTaskRecords(taskRecords);
    }
    
    @isTest
    static void getMyTasks_todayFilterAndOneStandardDueTodayTask_expectNoTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today()).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('Today');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_todayAndOverdueFilterAndOneStandardOverdueTask_expectOneTaskReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(-1)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('TodayAndOverdue');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_todayAndOverdueFilterAndOneStandardDueTodayTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today()).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('TodayAndOverdue');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_tomorrowFilterAndOneStandardOverdueTask_expectNoTaskReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(-1)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('Tomorrow');
        
        assertNoTaskRecords(taskRecords);
    }
    
    @isTest
    static void getMyTasks_tomorrowFilterAndOneStandardDueTomorrowTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(1)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('Tomorrow');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_nextSevenDaysFilterAndOneStandardDueTomorrowTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(1)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('NextSevenDays');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_nextSevenDaysFilterAndOneStandardDueTodayTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today()).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('NextSevenDays');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_nextSevenDaysFilterAndOneStandardDueSevenDaysFromTodayTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(7)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('NextSevenDays');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_nextSevenDaysFilterAndOneStandardDueEightDaysFromTodayTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(8)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('NextSevenDays');
        
        assertNoTaskRecords(taskRecords);
    }
    
    @isTest
    static void getMyTasks_nextSevenDaysAndOverdueFilterAndOneStandardDueTomorrowTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(1)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('NextSevenDaysOverdue');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_nextSevenDaysAndOverdueFilterAndOneStandardDueTodayTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today()).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('NextSevenDaysOverdue');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_nextSevenDaysAndOverdueFilterAndOneStandardDueSevenDaysFromTodayTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(7)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('NextSevenDaysOverdue');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void getMyTasks_nextSevenDaysAndOverdueFilterAndOneStandardDueEightDaysFromTodayTask_expectOneTasksReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.withActivityDate(Date.Today().addDays(8)).insertTask();

        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.getMyTasks('NextSevenDaysOverdue');
        
        assertNoTaskRecords(taskRecords);
    }
    
    @isTest
    static void updateTask_dueDateChangedToTodayAndTodayFilter_expectTaskUpdatedAndReturnedTest() {
        loadSetupData();
        Project__c someProject = ProjectTestData.Instance.insertProject();
        Task__c taskToUpdate = TaskTestData.Instance.withProject(someProject.Id).withStatus(InProgressTaskStatus.Id).insertTask();
        
        taskToUpdate.Due_Date__c = Date.Today();
        
        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.updateTask(taskToUpdate, 'Today');
        
        Task__c queriedTask = getCustomTaskById(taskToUpdate.Id);
        
        system.assertEquals(taskToUpdate.Due_Date__c, queriedTask.Due_Date__c, 'The due date was not updated.');
        
        assertExpectedRecordsCount(taskRecords, 1);
    }
    
    @isTest
    static void updateTask_dueDateChangedToTodayAndTomorrowFilter_expectTaskUpdatedAndNotReturnedTest() {
        loadSetupData();
        Project__c someProject = ProjectTestData.Instance.insertProject();
        Task__c taskToUpdate = TaskTestData.Instance.withProject(someProject.Id).withStatus(InProgressTaskStatus.Id).insertTask();
        
        taskToUpdate.Due_Date__c = Date.Today();
        
        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.updateTask(taskToUpdate, 'Tomorrow');
        
        Task__c queriedTask = getCustomTaskById(taskToUpdate.Id);
        
        system.assertEquals(taskToUpdate.Due_Date__c, queriedTask.Due_Date__c, 'The due date was not updated.');
        
        assertNoTaskRecords(taskRecords);
    }
    
    @isTest
    static void completeTask_standardTaskCompletedWithAllOpenFilter_expectTaskCompletedAndNotReturnedTest() {
        Task someTask = StandardTaskTestData.Instance.insertTask();
        
        List<MyTasksAFController.TaskRecord> taskRecords = MyTasksAFController.completeTask(someTask.Id, 'AllOpen');
        
        Task queriedTask = getStandardTaskById(someTask.Id);
        system.assertEquals('Completed', queriedTask.Status, 'The task was not completed.');
        
        assertNoTaskRecords(taskRecords);
    }
}