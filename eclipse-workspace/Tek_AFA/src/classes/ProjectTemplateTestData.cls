/**
 * @description Builder class for dealing with Project Template records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class ProjectTemplateTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Project Template state for ProjectTemplateTestData.
     * @return A map of Project Template default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Project_Template__c.Name => 'Onboarding Tasks',
            Project_Template__c.Description__c => 'Default Project Description'
        };
    }

    /**
     * @description Returns the SObject type for ProjectTemplateTestData builder.
     * @return Project_Template__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Project_Template__c.SObjectType;
    }

    /**
     * @description Sets the name on the Project Template.
     * @param name The name that the project template will have.
     * @return The instance of ProjectTemplateTestData.
     */
    public ProjectTemplateTestData withName(String name) {
        return (ProjectTemplateTestData) withDynamicData(Project_Template__c.Name, name);
    }
    
    /**
     * @description Builds the Project Template object.
     * @return The created Project Template object.
     */
    public Project_Template__c create() {
        return (Project_Template__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Project Template object.
     * @return The inserted Project Template object.
     */
    public Project_Template__c insertProjectTemplate() {
        return (Project_Template__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of ProjectTemplateTestData.
     * @return ProjectTemplateTestData instance.
     */
    public static ProjectTemplateTestData Instance {
        get {
            if (Instance == null) {
                Instance = new ProjectTemplateTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private ProjectTemplateTestData() {
        super();
    }
}