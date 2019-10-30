/**
 * @description Builder class for dealing with Task Status records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class TaskStatusTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Task Status state for TaskStatusTestData.
     * @return A map of Task Status default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Task_Status__c.Name => 'Not Started',
            Task_Status__c.Order__c => 1
        };
    }

    /**
     * @description Returns the SObject type for TaskStatusTestData builder.
     * @return Task_Status__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Task_Status__c.SObjectType;
    }
    
    /**
     * @description Sets the name on the Task Status.
     * @param name The name that the task status will have.
     * @return The instance of TaskStatusTestData.
     */
    public TaskStatusTestData withName(String name) {
        return (TaskStatusTestData) withDynamicData(Task_Status__c.Name, name);
    }
    
    /**
     * @description Sets the order on the Task Status.
     * @param order The order that the task status will have.
     * @return The instance of TaskStatusTestData.
     */
    public TaskStatusTestData withOrder(Integer order) {
        return (TaskStatusTestData) withDynamicData(Task_Status__c.Order__c, order);
    }
    
    /**
     * @description Sets the display on task board on the Task Status.
     * @param displayOnTaskBoard The display on task board that the task status will have.
     * @return The instance of TaskStatusTestData.
     */
    public TaskStatusTestData withDisplayOnTaskBoard(Boolean displayOnTaskBoard) {
        return (TaskStatusTestData) withDynamicData(Task_Status__c.Display_On_Task_Board__c, displayOnTaskBoard);
    }
    
    /**
     * @description Sets the completed on the Task Status.
     * @param completed The completed that the task status will have.
     * @return The instance of TaskStatusTestData.
     */
    public TaskStatusTestData withCompleted(Boolean completed) {
        return (TaskStatusTestData) withDynamicData(Task_Status__c.Completed__c, completed);
    }
    
    /**
     * @description Builds the Task Status object.
     * @return The created Task Status object.
     */
    public Task_Status__c create() {
        return (Task_Status__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Task Status object.
     * @return The inserted Task Status object.
     */
    public Task_Status__c insertTaskStatus() {
        return (Task_Status__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of TaskStatusTestData.
     * @return TaskStatusTestData instance.
     */
    public static TaskStatusTestData Instance {
        get {
            if (Instance == null) {
                Instance = new TaskStatusTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private TaskStatusTestData() {
        super();
    }
}