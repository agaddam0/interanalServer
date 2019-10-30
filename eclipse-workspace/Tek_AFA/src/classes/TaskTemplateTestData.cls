/**
 * @description Builder class for dealing with Task Template records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class TaskTemplateTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Task Template state for TaskTemplateTestData.
     * @return A map of Task Template default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Task_Template__c.Name => 'Default Task',
            Task_Template__c.Order__c => 1,
            Task_Template__c.Description__c => 'Default Description'
        };
    }

    /**
     * @description Returns the SObject type for TaskTemplateTestData builder.
     * @return Task_Template__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Task_Template__c.SObjectType;
    }

    /**
     * @description Sets the auto assignment record user field on the Task Template.
     * @param autoAssignmentRecordUserField The auto assignment record user field that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withAutoAssignmentRecordUserField(String autoAssignmentRecordUserField) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Auto_Assignment_Record_User_Field__c, autoAssignmentRecordUserField);
    }
    
    /**
     * @description Sets the due date days to add on the Task Template.
     * @param dueDateDaysToAdd The due date days to add that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withDueDateDaysToAdd(Integer dueDateDaysToAdd) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Due_Date_Days_To_Add__c, dueDateDaysToAdd);
    }
    
    /**
     * @description Sets the due date record field on the Task Template.
     * @param dueDateRecordField The due date record field that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withDueDateRecordField(String dueDateRecordField) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Due_Date_Record_Field__c, dueDateRecordField);
    }
    
    /**
     * @description Sets the recalculate due date on the Task Template.
     * @param recalculateDueDate The recalculate due date that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withRecalculateDueDate(Boolean recalculateDueDate) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Recalculate_Due_Date__c, recalculateDueDate);
    }
    
    /**
     * @description Sets the order on the Task Template.
     * @param order The order that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withOrder(Integer order) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Order__c, order);
    }
    
    /**
     * @description Sets the predecessor task template on the Task Template.
     * @param predecessorTaskTemplateId The predecessor task template that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withPredecessorTaskTemplate(Id predecessorTaskTemplateId) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Predecessor_Task_Template__c, predecessorTaskTemplateId);
    }
    
    /**
     * @description Sets the projected end date days to add on the Task Template.
     * @param projectedEndDateDaysToAdd The projected end date days to add that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withProjectedEndDateDaysToAdd(Integer projectedEndDateDaysToAdd) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Projected_End_Date_Days_To_Add__c, projectedEndDateDaysToAdd);
    }
    
    /**
     * @description Sets the projected end date record field on the Task Template.
     * @param projectedEndDateRecordField The projected end date record field that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withProjectedEndDateRecordField(String projectedEndDateRecordField) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Projected_End_Date_Record_Field__c, projectedEndDateRecordField);
    }
    
    /**
     * @description Sets the recalculate projected end date on the Task Template.
     * @param recalculateProjectedEndDate The recalculate projected end date that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withRecalculateProjectedEndDate(Boolean recalculateProjectedEndDate) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Recalculate_Projected_End_Date__c, recalculateProjectedEndDate);
    }
    
    /**
     * @description Sets the projected start date days to add on the Task Template.
     * @param projectedEndDateDaysToAdd The projected start date days to add that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withProjectedStartDateDaysToAdd(Integer projectedStartDateDaysToAdd) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Projected_Start_Date_Days_To_Add__c, projectedStartDateDaysToAdd);
    }
    
    /**
     * @description Sets the projected start date record field on the Task Template.
     * @param projectedStartDateRecordField The projected start date record field that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withProjectedStartDateRecordField(String projectedStartDateRecordField) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Projected_Start_Date_Record_Field__c, projectedStartDateRecordField);
    }
    
    /**
     * @description Sets the recalculate projected start date on the Task Template.
     * @param recalculateProjectedStartDate The recalculate projected start date that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withRecalculateProjectedStartDate(Boolean recalculateProjectedStartDate) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Recalculate_Projected_Start_Date__c, recalculateProjectedStartDate);
    }

    /**
     * @description Sets the project template on the Task Template.
     * @param projectTemplateId The project template that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withProjectTemplate(Id projectTemplateId) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Project_Template__c, projectTemplateId);
    }
    
    /**
     * @description Sets the role on the Task Template.
     * @param role The role that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withRole(String role) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Role__c, role);
    }
    
    /**
     * @description Sets the name on the Task Template.
     * @param name The name that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withName(String name) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Name, name);
    }
    
    /**
     * @description Sets the description on the Task Template.
     * @param description The description that the task template will have.
     * @return The instance of TaskTemplateTestData.
     */
    public TaskTemplateTestData withDescription(String description) {
        return (TaskTemplateTestData) withDynamicData(Task_Template__c.Description__c, description);
    }
    
    /**
     * @description Builds the Task Template object.
     * @return The created Task Template object.
     */
    public Task_Template__c create() {
        return (Task_Template__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Task Template object.
     * @return The inserted Task Template object.
     */
    public Task_Template__c insertTaskTemplate() {
        return (Task_Template__c)super.insertRecord();
    }
    
    /**
     * @description Inserts the desired number of task templates.
     * @param numberToInsert The number of task templates to insert.
     * @return The inserted task templates.
     */
    public List<Task_Template__c> insertTaskTemplates(Integer numberToInsert) {
        return (List<Task_Template__c>) super.insertRecords(numberToInsert);
    }
    
    protected override void beforeBuild() {
        Object projectTemplateId = currentValueFor(Task_Template__c.Project_Template__c);
        
        if (projectTemplateId == null) {
            Project_Template__c projectTemplate = ProjectTemplateTestData.Instance.insertProjectTemplate();
            
            withProjectTemplate(projectTemplate.Id);
        }
    }

    /**
     * @description Gets an instance of TaskTemplateTestData.
     * @return TaskTemplateTestData instance.
     */
    public static TaskTemplateTestData Instance {
        get {
            if (Instance == null) {
                Instance = new TaskTemplateTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private TaskTemplateTestData() {
        super();
    }
}