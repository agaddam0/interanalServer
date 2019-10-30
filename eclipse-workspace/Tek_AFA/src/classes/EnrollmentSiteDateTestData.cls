/**
 * @description Builder class for dealing with Enrollment Site Date records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class EnrollmentSiteDateTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Enrollment Site Date state for EnrollmentSiteDateTestData.
     * @return A map of Enrollment Site Date default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Enrollment_Site_Date__c.Start_Date__c => Date.Today().addDays(10),
            Enrollment_Site_Date__c.End_Date__c => Date.Today().addDays(10),
            Enrollment_Site_Date__c.Start_Time__c => Time.NewInstance(10, 0, 0, 0),
            Enrollment_Site_Date__c.End_Time__c => Time.NewInstance(11, 0, 0, 0)
        };
    }

    /**
     * @description Returns the SObject type for EnrollmentSiteDateTestData builder.
     * @return Enrollment_Site_Date__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Enrollment_Site_Date__c.SObjectType;
    }

    /**
     * @description Sets the enrollment site on the enrollment site date.
     * @param enrollmentSiteId The id of the enrollment site that the enrollment site date will have.
     * @return The instance of EnrollmentSiteTestData.
     */
    public EnrollmentSiteDateTestData withEnrollmentSite(Id enrollmentSiteId) {
        return (EnrollmentSiteDateTestData) withDynamicData(Enrollment_Site_Date__c.Enrollment_Site__c, enrollmentSiteId);
    }

    /**
     * @description Sets the enrollment opportunity on the enrollment site date.
     * @param enrollmentOpportunityId The id of the enrollment opportunity that the enrollment site date will have.
     * @return The instance of EnrollmentSiteTestData.
     */
    public EnrollmentSiteDateTestData withEnrollmentOpportunity(Id enrollmentOpportunityId) {
        return (EnrollmentSiteDateTestData) withDynamicData(Enrollment_Site_Date__c.Enrollment_Opportunity__c, enrollmentOpportunityId);
    }

    /**
     * @description Sets the show in build time to enroll email on the enrollment site date.
     * @param showInBuildTimeToEnrollEmail The show in build time to enroll email that the enrollment site date will have.
     * @return The instance of EnrollmentSiteTestData.
     */
    public EnrollmentSiteDateTestData withShowInBuildTimeToEnrollEmail(Boolean showInBuildTimeToEnrollEmail) {
        return (EnrollmentSiteDateTestData) withDynamicData(Enrollment_Site_Date__c.Show_In_Build_Time_To_Enroll_Email__c, showInBuildTimeToEnrollEmail);
    }

    /* Create a "with" method for each property that can be set */

    /**
     * @description Builds the Enrollment_Site_Date__c object.
     * @return The created Enrollment_Site_Date__c object.
     */
    public Enrollment_Site_Date__c create() {
        return (Enrollment_Site_Date__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Enrollment_Site_Date__c object.
     * @return The inserted Enrollment_Site_Date__c object.
     */
    public Enrollment_Site_Date__c insertEnrollmentSiteDate() {
        return (Enrollment_Site_Date__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of EnrollmentSiteDateTestData.
     * @return EnrollmentSiteDateTestData instance.
     */
    public static EnrollmentSiteDateTestData Instance {
        get {
            if (Instance == null) {
                Instance = new EnrollmentSiteDateTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private EnrollmentSiteDateTestData() {
        super();
    }
}