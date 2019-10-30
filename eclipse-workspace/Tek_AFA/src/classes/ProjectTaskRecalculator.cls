public without sharing class ProjectTaskRecalculator {

    public void recalculateTaskDates(Map<Id, SObject> oldRecords, Map<Id, SObject> newRecords) {
        Map<Id, List<Task__c>> potentialTasksToUpdate = getPotentialTasksToUpdate(newRecords);
        
        if (potentialTasksToUpdate == null ||
            potentialTasksToUpdate.isEmpty()) {
            return;
        }
        
        List<Task__c> tasksToUpdate = new List<Task__c>();
        
        for (Id sourceRecordId : potentialTasksToUpdate.keySet()) {
            List<Task__c> sourceRecordPotentialTasksToUpdate = potentialTasksToUpdate.get(sourceRecordId);
            
            for (Task__c potentialTaskToUpdate : sourceRecordPotentialTasksToUpdate) {
                SObject oldRecord = oldRecords.get(sourceRecordId);
                SObject newRecord = newRecords.get(sourceRecordId);
            
	            if (recalculateTaskDates(potentialTaskToUpdate, oldRecord, newRecord)) {
	                tasksToUpdate.add(potentialTaskToUpdate);
	            }
            }
        }
        
        if (tasksToUpdate.size() > 0) {
            update tasksToUpdate;
        }
    }
    
    private Map<Id, List<Task__c>> getPotentialTasksToUpdate(Map<Id, SObject> newRecords) {
        Map<Id, List<Task__c>> potentialTasksToUpdate = new Map<Id, List<Task__c>>();
        
        if (newRecords == null ||
            newRecords.isEmpty()) {
            return potentialTasksToUpdate;
        }
        
        String projectLookupFieldName = ProjectTaskUtil.findProjectRecordLookupFieldName(newRecords.values()[0]);
        
        if (String.isBlank(projectLookupFieldName)) {
            return potentialTasksToUpdate;
        }
        
        Set<Id> recordIds = newRecords.keySet();
        
        String potentialTasksQuery = 'SELECT Id, ' +
                                            'Name, ' +
                                            'Due_Date__c, ' +
                                            'Task_Template__c, ' +
                                            'Task_Template__r.Due_Date_Days_To_Add__c, ' +
                                            'Task_Template__r.Due_Date_Record_Field__c, ' +
                                            'Task_Template__r.Recalculate_Due_Date__c, ' +
                                            'Task_Template__r.Projected_Start_Date_Days_To_Add__c, ' +
                                            'Task_Template__r.Projected_Start_Date_Record_Field__c, ' +
                                            'Task_Template__r.Recalculate_Projected_Start_Date__c, ' +
                                            'Task_Template__r.Projected_End_Date_Days_To_Add__c, ' +
                                            'Task_Template__r.Projected_End_Date_Record_Field__c, ' +
                                            'Task_Template__r.Recalculate_Projected_End_Date__c, ' +
                                            'Project__r.' + projectLookupFieldName +
                                     '  FROM Task__c' +
                                     ' WHERE Project__r.' + projectLookupFieldName + ' in :recordIds' +
                                     '   AND ((Task_Template__r.Due_Date_Record_Field__c != null' +
                                     '         AND Task_Template__r.Recalculate_Due_Date__c = true) OR' +
                                     '       (Task_Template__r.Projected_Start_Date_Record_Field__c != null AND ' +
                                     '        Task_Template__r.Recalculate_Projected_Start_Date__c = true) OR' +
                                     '       (Task_Template__r.Projected_End_Date_Record_Field__c != null AND' +
                                     '        Task_Template__r.Recalculate_Projected_End_Date__c = true))';
                                     
        List<Task__c> potentialTasks = Database.query(potentialTasksQuery);
        
        for (Task__c potentialTask : potentialTasks) {
            Project__c taskProject = potentialTask.Project__r;
            Id sourceRecordId = (Id) taskProject.get(projectLookupFieldName);
            
            List<Task__c> sourceRecordPotentialTasks = potentialTasksToUpdate.get(sourceRecordId);
            
            if (sourceRecordPotentialTasks == null) {
                sourceRecordPotentialTasks = new List<Task__c>();
                potentialTasksToUpdate.put(sourceRecordId, sourceRecordPotentialTasks);
            }
            
            sourceRecordPotentialTasks.add(potentialTask);
        }
                                            
        
        return potentialTasksToUpdate;
    }
    
    private Boolean recalculateTaskDates(Task__c potentialTaskToUpdate, SObject oldRecord, SObject newRecord) {
        Task_Template__c taskTemplate = potentialTaskToUpdate.Task_Template__r;
        
        Boolean taskDatesRecalculated = recalculateTaskDueDate(taskTemplate, potentialTaskToUpdate, oldRecord, newRecord);
        taskDatesRecalculated |= recalculateTaskProjectedStartDate(taskTemplate, potentialTaskToUpdate, oldRecord, newRecord);
        taskDatesRecalculated |= recalculateTaskProjectedEndDate(taskTemplate, potentialTaskToUpdate, oldRecord, newRecord);
        
        return taskDatesRecalculated;
    }
    
    private Boolean recalculateTaskDueDate(Task_Template__c taskTemplate, Task__c task, SObject oldRecord, SObject newRecord) {        
        return recalculateTaskDateHelper('Recalculate_Due_Date__c', 'Due_Date__c', taskTemplate.Due_Date_Record_Field__c, (Integer) taskTemplate.Due_Date_Days_To_Add__c, taskTemplate, task, oldRecord, newRecord);
    }
    
    private Boolean recalculateTaskProjectedStartDate(Task_Template__c taskTemplate, Task__c task, SObject oldRecord, SObject newRecord) {        
        return recalculateTaskDateHelper('Recalculate_Projected_Start_Date__c', 'Projected_Start_Date__c', taskTemplate.Projected_Start_Date_Record_Field__c, (Integer) taskTemplate.Projected_Start_Date_Days_To_Add__c, taskTemplate, task, oldRecord, newRecord);
    }
    
    private Boolean recalculateTaskProjectedEndDate(Task_Template__c taskTemplate, Task__c task, SObject oldRecord, SObject newRecord) {        
        return recalculateTaskDateHelper('Recalculate_Projected_End_Date__c', 'Projected_End_Date__c', taskTemplate.Projected_End_Date_Record_Field__c, (Integer) taskTemplate.Projected_End_Date_Days_To_Add__c, taskTemplate, task, oldRecord, newRecord);
    }
    
    private Boolean recalculateTaskDateHelper(String taskTemplateRecalculateDateFieldName, String taskDateFieldName, String sourceRecordDateField, Integer daysToAdd, Task_Template__c taskTemplate, Task__c task, SObject oldRecord, SObject newRecord) {
        Boolean recalculated = false;
        
        if ((Boolean) taskTemplate.get(taskTemplateRecalculateDateFieldName) == false) {
            return recalculated;
        }
        
        Date oldDueDateSourceDate = (Date) oldRecord.get(sourceRecordDateField);
        Date newDueDateSourceDate = (Date) newRecord.get(sourceRecordDateField);
        
        if (newDueDateSourceDate != null &&
            fieldChanged(oldDueDateSourceDate, newDueDateSourceDate)) {
            
            Date newDateValue = ProjectTaskUtil.calculateDateFromSourceRecord(newRecord, sourceRecordDateField, daysToAdd);

            task.put(taskDateFieldName, newDateValue); 
            recalculated = true;
        }
        
        return recalculated;
    }
    
    private Boolean fieldChanged(Object oldValue, Object newValue) {
        return oldValue != newValue;
    }
}