/**
 * @description Builder class for dealing with Eligible_Coverage__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class EligibleCoverageTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Eligible_Coverage__c state for EligibleCoverageTestData.
     * @return A map of Eligible_Coverage__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{};
    }

    /**
     * @description Returns the SObject type for EligibleCoverageTestData builder.
     * @return Eligible_Coverage__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Eligible_Coverage__c.SObjectType;
    }
    
    /**
     * @description Sets the benefit code on the coverage.
     * @param Benefit Code The benefit code that the Eligible Coverage will have.
     * @return The instance of EligibleCoverageTestData.
     */
    public EligibleCoverageTestData withBenefitCode(String benefitCode) {
        return (EligibleCoverageTestData) withDynamicData(Eligible_Coverage__c.BenefitCode__c, benefitCode);
    }

    /**
     * @description Sets the Plan Date on the coverage.
     * @param planDateId The id of the Plan Date that the Eligible Coverage will have.
     * @return The instance of EligibleCoverageTestData.
     */
    public EligibleCoverageTestData withPlanDate(Id planDateId) {
        return (EligibleCoverageTestData) withDynamicData(Eligible_Coverage__c.PlanDateRecord__c, planDateId);
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Builds the Eligible_Coverage__c object.
     * @return The created Eligible_Coverage__c object.
     */
    public Eligible_Coverage__c create() {
        return (Eligible_Coverage__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Eligible_Coverage__c object.
     * @return The inserted Eligible_Coverage__c object.
     */
    public Eligible_Coverage__c insertCoverage() {
        return (Eligible_Coverage__c)super.insertRecord();
    }

    protected override void beforeBuild() {
        Object planDateId = currentValueFor(Eligible_Coverage__c.PlanDateRecord__c);
        
        system.debug('   beforeBuild::PlanDateRecord ' + planDateId);
        
        if (planDateId == null) {
            Plan_Date__c planDate = PlanDateTestData.Instance.insertPlanDate();
            
            withPlanDate(planDate.Id);
        }
    }

    /**
     * @description Gets an instance of EligibleCoverageTestData.
     * @return EligibleCoverageTestData instance.
     */
    private static EligibleCoverageTestData instancePriv = null;
    public static EligibleCoverageTestData Instance {
        get {
            if (instancePriv == null) {
                instancePriv = new EligibleCoverageTestData();
            }
            return instancePriv;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private EligibleCoverageTestData() {
        super();
    }
}