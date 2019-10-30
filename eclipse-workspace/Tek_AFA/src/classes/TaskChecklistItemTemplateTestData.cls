/**
 * @description Builder class for dealing with Task Checklist Item Template records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public class TaskChecklistItemTemplateTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Task Checklist Item state for TaskChecklistItemTemplateTestData.
     * @return A map of Task Checklist Item Template default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Task_Checklist_Item_Template__c.Label__c => 'Default Task',
            Task_Checklist_Item_Template__c.Order__c => 1
        };
    }

    /**
     * @description Returns the SObject type for TaskChecklistItemTemplateTestData builder.
     * @return Task_Checklist_Item_Template__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Task_Checklist_Item_Template__c.SObjectType;
    }
    
    /**
     * @description Sets the label on the Task Checklist Item Template.
     * @param label The label that the task checklist item template will have.
     * @return The instance of TaskChecklistItemTemplateTestData.
     */
    public TaskChecklistItemTemplateTestData withLabel(String label) {
        return (TaskChecklistItemTemplateTestData) withDynamicData(Task_Checklist_Item_Template__c.Label__c, label);
    }
    
    /**
     * @description Sets the task template on the Task Checklist Item Template.
     * @param taskTemplateId The id of the task template that the task checklist item template will have.
     * @return The instance of TaskChecklistItemTemplateTestData.
     */
    public TaskChecklistItemTemplateTestData withTaskTemplate(Id taskTemplateId) {
        return (TaskChecklistItemTemplateTestData) withDynamicData(Task_Checklist_Item_Template__c.Task_Template__c, taskTemplateId);
    }
    
    /**
     * @description Sets the order on the Task Checklist Item Template.
     * @param order The order that the task checklist item template will have.
     * @return The instance of TaskChecklistItemTemplateTestData.
     */
    public TaskChecklistItemTemplateTestData withOrder(Integer order) {
        return (TaskChecklistItemTemplateTestData) withDynamicData(Task_Checklist_Item_Template__c.Order__c, order);
    }
    
    /**
     * @description Builds the Task Checklist Item Template object.
     * @return The created Task Checklist Item Template object.
     */
    public Task_Checklist_Item_Template__c create() {
        return (Task_Checklist_Item_Template__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Task Checklist Item Template object.
     * @return The inserted Task Checklist Item Template object.
     */
    public Task_Checklist_Item_Template__c insertTaskChecklistItemTemplate() {
        return (Task_Checklist_Item_Template__c)super.insertRecord();
    }
    
    protected override void beforeBuild() {
        Object taskTemplateId = currentValueFor(Task_Checklist_Item_Template__c.Task_Template__c);
        
        if (taskTemplateId == null) {
            Task_Template__c taskTemplate = TaskTemplateTestData.Instance.insertTaskTemplate();
            
            withTaskTemplate(taskTemplate.Id);
        }
    }
    
    /**
     * @description Gets an instance of TaskChecklistItemTemplateTestData.
     * @return TaskChecklistItemTemplateTestData instance.
     */
    public static TaskChecklistItemTemplateTestData Instance {
        get {
            if (Instance == null) {
                Instance = new TaskChecklistItemTemplateTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private TaskChecklistItemTemplateTestData() {
        super();
    }
}