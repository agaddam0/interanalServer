/**
 * @description Builder class for dealing with Project__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class ProjectTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Project__c state for ProjectTestData.
     * @return A map of Project__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Project__c.Name => 'Reservice Project'
        };
    }

    /**
     * @description Returns the SObject type for ProjectTestData builder.
     * @return Project__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Project__c.SObjectType;
    }
    
    /**
     * @description Sets the name on the project.
     * @param name The name that the project will have.
     * @return The instance of ProjectTestData.
     */
    public ProjectTestData withName(String name) {
        return (ProjectTestData) withDynamicData(Project__c.Name, name);
    }
    
    /**
     * @description Sets the description on the project.
     * @param description The description that the project will have.
     * @return The instance of ProjectTestData.
     */
    public ProjectTestData withDescription(String description) {
        return (ProjectTestData) withDynamicData(Project__c.Description__c, description);
    }

    /**
     * @description Sets the opportunity on the project.
     * @param opportunityId The id of the opportunity that the project will have.
     * @return The instance of ProjectTestData.
     */
    public ProjectTestData withOpportunity(Id opportunityId) {
        return (ProjectTestData) withDynamicData(Project__c.Opportunity__c, opportunityId);
    }

    /**
     * @description Sets the project tempalte on the project.
     * @param projectTemplateId The id of the project template that the project will have.
     * @return The instance of ProjectTestData.
     */
    public ProjectTestData withProjectTemplate(Id projectTemplateId) {
        return (ProjectTestData) withDynamicData(Project__c.Project_Template__c, projectTemplateId);
    }

    /**
     * @description Sets the task display field set on the project.
     * @param taskDisplayFieldSet The task display field set that the project will have.
     * @return The instance of ProjectTestData.
     */
    public ProjectTestData withTaskDisplayFieldSet(String taskDisplayFieldSet) {
        return (ProjectTestData) withDynamicData(Project__c.Task_Display_Field_Set__c, taskDisplayFieldSet);
    }
    
    /**
     * @description Sets the task edit field set on the project.
     * @param taskEditFieldSet The task edit field set that the project will have.
     * @return The instance of ProjectTestData.
     */
    public ProjectTestData withTaskEditFieldSet(String taskEditFieldSet) {
        return (ProjectTestData) withDynamicData(Project__c.Task_Edit_Field_Set__c, taskEditFieldSet);
    }
    
    /**
     * @description Sets the status on the project.
     * @param status The status that the project will have.
     * @return The instance of ProjectTestData.
     */
    public ProjectTestData withStatus(String status) {
        return (ProjectTestData) withDynamicData(Project__c.Status__c, status);
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Builds the Project__c object.
     * @return The created Project__c object.
     */
    public Project__c create() {
        return (Project__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Project__c object.
     * @return The inserted Project__c object.
     */
    public Project__c insertProject() {
        return (Project__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of ProjectTestData.
     * @return ProjectTestData instance.
     */
    public static ProjectTestData Instance {
        get {
            if (Instance == null) {
                Instance = new ProjectTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private ProjectTestData() {
        super();
    }
}