/**
 * @description Builder class for dealing with Plan_Date__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class PlanDateTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Plan_Date__c state for PlanDateTestData.
     * @return A map of Plan_Date__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Plan_Date__c.Name => 'Plan Number'
        };
    }

    /**
     * @description Returns the SObject type for PlanDateTestData builder.
     * @return Plan_Date__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Plan_Date__c.SObjectType;
    }
    
    /**
     * @description Sets the name on the plan date.
     * @param name The name that the plan date will have.
     * @return The instance of PlanDateTestData.
     */
    public PlanDateTestData withName(String name) {
        return (PlanDateTestData) withDynamicData(Plan_Date__c.Name, name);
    }

    /**
     * @description Sets the opportunity on the plan date.
     * @param opportunityId The id of the opportunity that the plan date will have.
     * @return The instance of PlanDateTestData.
     */
    public PlanDateTestData withAccount(Id accountId) {
        return (PlanDateTestData) withDynamicData(Plan_Date__c.Account__c, accountId);
    }
    
    /**
     * @description Sets the status on the plan date.
     * @param status The status that the plan date will have.
     * @return The instance of PlanDateTestData.
     */
    public PlanDateTestData withPlanStatus(String status) {
        return (PlanDateTestData) withDynamicData(Plan_Date__c.PlanStatus__c, status);
    }

    /**
     * @description Sets the related employer on the plan date.
     * @param accountId The related employer (account) that the plan date will have.
     * @return The instance of PlanDateTestData.
     */
    public PlanDateTestData withRelatedEmployer(String accountId) {
        return (PlanDateTestData) withDynamicData(Plan_Date__c.Related_Employer__c, accountId);
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Builds the Plan_Date__c object.
     * @return The created Plan_Date__c object.
     */
    public Plan_Date__c create() {
        return (Plan_Date__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Plan_Date__c object.
     * @return The inserted Plan_Date__c object.
     */
    public Plan_Date__c insertPlanDate() {
        return (Plan_Date__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of PlanDateTestData.
     * @return PlanDateTestData instance.
     */
    private static PlanDateTestData instancePriv = null;
    public static PlanDateTestData Instance {
        get {
            if (instancePriv == null) {
                instancePriv = new PlanDateTestData();
            }
            return instancePriv;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private PlanDateTestData() {
        super();
    }
}