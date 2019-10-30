global with sharing class MyTasksAFController {
    public static final String STD_TASK_STATUS_COMPLETED = 'Completed';
    
    private static Map<String, String> standardTaskFilters = new Map<String, String>{
        'AllOpen' => '',
        'Overdue' => 'ActivityDate < TODAY',
        'Today' => 'ActivityDate = TODAY',
        'TodayAndOverdue' => 'ActivityDate <= TODAY',
        'Tomorrow' => 'ActivityDate = TOMORROW',
        'NextSevenDays' => '(ActivityDate = NEXT_N_DAYS:7 OR ActivityDate = TODAY)',
        'NextSevenDaysOverdue' => 'ActivityDate <= NEXT_N_DAYS:7',
        'ThisMonth' => 'ActivityDate = THIS_MONTH'
    };
    
    private static Map<String, String> customTaskFilters = new Map<String, String>{
        'AllOpen' => '',
        'Overdue' => 'Due_Date__c < TODAY',
        'Today' => 'Due_Date__c = TODAY',
        'TodayAndOverdue' => 'Due_Date__c <= TODAY',
        'Tomorrow' => 'Due_Date__c = TOMORROW',
        'NextSevenDays' => '(Due_Date__c = NEXT_N_DAYS:7 OR Due_Date__c = TODAY)',
        'NextSevenDaysOverdue' => 'Due_Date__c <= NEXT_N_DAYS:7',
        'ThisMonth' => 'Due_Date__c = THIS_MONTH'
    };
    
    @AuraEnabled
    public static List<TaskRecord> getMyTasks(String filterName) {
        List<TaskRecord> standardTasks = getStandardTasks(filterName);
        List<TaskRecord> customTasks = getCustomTasks(filterName);
        
        List<TaskRecord> allTasks = new List<TaskRecord>();
        allTasks.addAll(standardTasks);
        allTasks.addAll(customTasks);
        
        allTasks.sort();
        
        return allTasks;
    }
    
    @AuraEnabled
    public static List<TaskRecord> updateTask(Task__c taskToUpdate, String filter) {
        update taskToUpdate;
        
        return getMyTasks(filter);
    }
    
    @AuraEnabled
    public static List<TaskRecord> completeTask(Id taskIdToComplete, String filter) {
        if (taskIdToComplete.getSObjectType() == Schema.Task__c.SObjectType) {
            completeCustomTask(taskIdToComplete);
        }
        else {
            completeStandardTask(taskIdToComplete);
        }
        
        return getMyTasks(filter);
    }
    
    private static List<TaskRecord> getStandardTasks(String filterName) {
        List<TaskRecord> standardTaskRecords = new List<TaskRecord>();
        
        Id myUserId = UserInfo.getUserId();
        
        String myTasksSOQL = 'SELECT Id, ' + 
                                    'ActivityDate, ' + 
                                    'Description, ' +
                                    'Subject, ' +
                                    'Status, ' +
                                    'WhatId, ' + 
                                    'What.Name ' +
                               'FROM Task' +
                             ' WHERE OwnerId = :myUserId' + 
                             '   AND Status != \'Completed\'';
                             
        String filterToApply = standardTaskFilters.get(filterName);
        
        if (string.isNotBlank(filterToApply)) {
            myTasksSOQL += ' AND ' + filterToApply;
        }
        
        List<Task> standardTasks = Database.query(myTasksSOQL);
        
        for (Task standardTask : standardTasks) {
            TaskRecord standardTaskRecord = new TaskRecord(standardTask);
            
            standardTaskRecords.add(standardTaskRecord);
        }
        
        return standardTaskRecords;
    }
    
    private static List<TaskRecord> getCustomTasks(String filterName) {
        List<TaskRecord> customTaskRecords = new List<TaskRecord>();
        
        Id myUserId = UserInfo.getUserId();
        
        Set<String> allTaskCreatableFields = Util.getObjectCreatableFields('Task__c');
        allTaskCreatableFields.add('Due_Date__c');
        allTaskCreatableFields.add('Description__c');
        allTaskCreatableFields.add('Status__c');
        allTaskCreatableFields.add('Status__r.Name');
        allTaskCreatableFields.add('Edit_Field_Set__c');
        allTaskCreatableFields.add('Project__c');
        allTaskCreatableFields.add('Project__r.Name');
        
        String myCustomTasksSOQL = 'SELECT ' + String.join(new List<String>(allTaskCreatableFields), ',') +
                                   '  FROM Task__c' +
                                   ' WHERE Assignee__c = :myUserId' + 
                                   '   AND Complete__c = false';
                             
        String filterToApply = customTaskFilters.get(filterName);
        
        if (string.isNotBlank(filterToApply)) {
            myCustomTasksSOQL += ' AND ' + filterToApply;
        }
        
        List<Task__c> customTasks = Database.query(myCustomTasksSOQL);
        
        for (Task__c customTask : customTasks) {
            TaskRecord customTaskRecord = new TaskRecord(customTask);
            
            customTaskRecords.add(customTaskRecord);
        }
        
        return customTaskRecords;
    }
    
    private static void completeCustomTask(Id taskIdToComplete) {
        Task_Status__c completedStatus = getCompletedStatus();
        
        Task__c customTaskToComplete = new Task__c(Id = taskIdToComplete);
        customTaskToComplete.Status__c = completedStatus.Id;
        update customTaskToComplete;
    }
    
    private static void completeStandardTask(Id taskIdToComplete) {
        Task task = new Task(Id = taskIdToComplete);
        
        task.Status = STD_TASK_STATUS_COMPLETED;
        update task;
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
    
    global class TaskRecord implements Comparable {
        @AuraEnabled
        public Boolean IsCustom { get; set; }
        
        @AuraEnabled
        public Date DueDate { get; set; }
        
        @AuraEnabled
        public String Name { get; set; }
        
        @AuraEnabled
        public String Status { get; set; }
        
        @AuraEnabled
        public String RelatedTo { get; set; }
        
        @AuraEnabled
        public Boolean IsOverdueOrDueToday { get; set; }
        
        @AuraEnabled
        public SObject Task { get; set; }
        
        global TaskRecord(Task standardTask) {
            IsCustom = false;
            Task = standardTask;
            
            DueDate = standardTask.ActivityDate;
            IsOverdueOrDueToday = DueDate != null && DueDate <= Date.Today();

            Name = standardTask.Subject;
            Status = standardTask.Status;
            
            if (standardTask.WhatId != null) {
                RelatedTo = standardTask.What.Name;
            }
        }
        
        global TaskRecord(Task__c customTask) {
            IsCustom = true;
            Task = customTask;
            
            DueDate = customTask.Due_Date__c;
            IsOverdueOrDueToday = DueDate != null && DueDate <= Date.Today();

            Name = customTask.Name;
            Status = customTask.Status__r.Name;
            RelatedTo = customTask.Project__r.Name;
        }

        global Integer compareTo(Object compareTo) {
            TaskRecord compareToTask = (TaskRecord) compareTo;
            
            // 0 if this instance and objectToCompareTo are equal
            // > 0 if this instance is greater than objectToCompareTo
            // < 0 if this instance is less than objectToCompareTo

            if (this.DueDate < compareToTask.DueDate) {
                return -1;
            }
            else if (this.DueDate > compareToTask.DueDate) {
                return 1;
            }
            
            return 0;
        }
    }
}