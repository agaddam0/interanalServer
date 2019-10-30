/**
 * @description Builder class for dealing with Task records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class StandardTaskTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Task state for StandardTaskTestData.
     * @return A map of Task default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Task.Subject => 'Test Task',
            Task.OwnerId => UserInfo.getUserId(),
            Task.Status => 'Not Started'
        };
    }

    /**
     * @description Returns the SObject type for StandardTaskTestData builder.
     * @return Task.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Task.SObjectType;
    }
    
    /**
     * @description Sets the subject on the task.
     * @param subject The subject that the task will have.
     * @return The instance of StandardTaskTestData.
     */
    public StandardTaskTestData withSubject(String subject) {
        return (StandardTaskTestData) withDynamicData(Task.Subject, subject);
    }
    
    /**
     * @description Sets the activity date on the task.
     * @param activityDate The activity date that the task will have.
     * @return The instance of StandardTaskTestData.
     */
    public StandardTaskTestData withActivityDate(Date activityDate) {
        return (StandardTaskTestData) withDynamicData(Task.ActivityDate, activityDate);
    }

    /**
     * @description Sets the status on the task.
     * @param status The status that the task will have.
     * @return The instance of TaskTestData.
     */
    public TaskTestData withStatus(String status) {
        return (TaskTestData) withDynamicData(Task.Status, status);
    }

    /**
     * @description Builds the Task object.
     * @return The created Task object.
     */
    public Task create() {
        return (Task)super.buildWithReset();
    }

    /**
     * @description Inserts the built Task object.
     * @return The inserted Task object.
     */
    public Task insertTask() {
        return (Task)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of StandardTaskTestData.
     * @return StandardTaskTestData instance.
     */
    public static StandardTaskTestData Instance {
        get {
            if (Instance == null) {
                Instance = new StandardTaskTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private StandardTaskTestData() {
        super();
    }
}