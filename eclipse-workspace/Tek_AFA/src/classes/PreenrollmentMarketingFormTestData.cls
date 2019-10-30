/**
 * @description Builder class for dealing with Preenrollment Marketing Form records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public class PreenrollmentMarketingFormTestData extends SObjectTestData {
    
    /**
     * @description Overridden method to set up the default
     * Preenrollment Marketing Form state for PreenrollmentMarketingFormTestData.
     * @return A map of Pre_Enrollment_Marketing_Form__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{

        };
    }
    
    /**
     * @description Returns the SObject type for PreenrollmentMarketingFormTestData builder.
     * @return PreenrollmentMarketingFormTestData.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Pre_Enrollment_Marketing_Form__c.SObjectType;
    }
    
    protected override void beforeBuild() {
        Object enrollmentFormId = currentValueFor(Pre_Enrollment_Marketing_Form__c.Enrollment_Form__c);
        
        system.debug('   beforeBuild::enrollmentFormId ' + enrollmentFormId);
        
        if (enrollmentFormId == null) {
            Opportunity testOpportunity = OpportunityTestData.Instance.withEmployerBenefitsSite('Yes').insertAFESOpportunity();
            
            Enrollment_Form__c generatedEnrollmentForm =
            [SELECT Id
               FROM Enrollment_Form__c
              WHERE Enrollment_Opportunity__c = :testOpportunity.Id];
            
            
            withEnrollmentForm(generatedEnrollmentForm.Id);
        }
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Sets the enrollment form using the given enrollment form id
     * @param enrollmentFormId The id of the enrollment form to use.
     * @return The instance of PreenrollmentMarketingFormTestData.
     */
    public PreenrollmentMarketingFormTestData withEnrollmentForm(Id enrollmentFormId) {
        return (PreenrollmentMarketingFormTestData) withDynamicData(Pre_Enrollment_Marketing_Form__c.Enrollment_Form__c, enrollmentFormId);
    }
    
    /**
     * @description Sets the enrollment form using the enrollment form attached to the given opportunity.
     * @param opportunityId The id of the opportunity to query the enrollment form from.
     * @return The instance of PreenrollmentMarketingFormTestData.
     */
    public PreenrollmentMarketingFormTestData withEnrollmentFormFromOpportunity(Id opportunityId) {
        Enrollment_Form__c enrollmentForm =
        [SELECT Id
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :opportunityId];
        
        return (PreenrollmentMarketingFormTestData) withDynamicData(Pre_Enrollment_Marketing_Form__c.Enrollment_Form__c, enrollmentForm.Id);
    }
    
    /**
     * @description Builds the Pre_Enrollment_Marketing_Form__c object.
     * @return The created Pre_Enrollment_Marketing_Form__c object.
     */
    public Pre_Enrollment_Marketing_Form__c create() {
        return (Pre_Enrollment_Marketing_Form__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Pre_Enrollment_Marketing_Form__c object.
     * @return The inserted Pre_Enrollment_Marketing_Form__c object.
     */
    public Pre_Enrollment_Marketing_Form__c insertPreenrollmentMarketingForm() {
        return (Pre_Enrollment_Marketing_Form__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of PreenrollmentMarketingFormTestData.
     * @return PreenrollmentMarketingFormTestData instance.
     */
    public static PreenrollmentMarketingFormTestData Instance {
        get {
            if (Instance == null) {
                Instance = new PreenrollmentMarketingFormTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private PreenrollmentMarketingFormTestData() {
        super();
    }
}