/**
 * @description Builder class for dealing with Task__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class TaskTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Task__c state for ProjectTestData.
     * @return A map of Task__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Task__c.Name => 'First Task',
            Task__c.Assignee__c => UserInfo.getUserId()
        };
    }

    /**
     * @description Returns the SObject type for TaskTestData builder.
     * @return Task__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Task__c.SObjectType;
    }
    
    /**
     * @description Sets the name on the task.
     * @param name The name that the task will have.
     * @return The instance of TaskTestData.
     */
    public TaskTestData withName(String name) {
        return (TaskTestData) withDynamicData(Task__c.Name, name);
    }

    /**
     * @description Sets the task status on the task.
     * @param taskStatusId The id of the task status that the task will have.
     * @return The instance of TaskTestData.
     */
    public TaskTestData withStatus(Id taskStatusId) {
        return (TaskTestData) withDynamicData(Task__c.Status__c, taskStatusId);
    }
    
    /**
     * @description Sets the project on the task.
     * @param projectId The id of the project that the task will have.
     * @return The instance of TaskTestData.
     */
    public TaskTestData withProject(Id projectId) {
        return (TaskTestData) withDynamicData(Task__c.Project__c, projectId);
    }
    
    /**
     * @description Sets the complete on the task.
     * @param complete The complete value that the task will have.
     * @return The instance of TaskTestData.
     */
    public TaskTestData withComplete(Boolean complete) {
        return (TaskTestData) withDynamicData(Task__c.Complete__c, complete);
    }
    
    /**
     * @description Builds the Task__c object.
     * @return The created Task__c object.
     */
    public Task__c create() {
        return (Task__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Task__c object.
     * @return The inserted Task__c object.
     */
    public Task__c insertTask() {
        return (Task__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of TaskTestData.
     * @return TaskTestData instance.
     */
    public static TaskTestData Instance {
        get {
            if (Instance == null) {
                Instance = new TaskTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private TaskTestData() {
        super();
    }
}