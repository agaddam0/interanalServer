/**
 * @description Builder class for dealing with Enrollment Site records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class EnrollmentSiteTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Enrollment Site state for EnrollmentSiteTestData.
     * @return A map of Enrollment Site default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Enrollment_Site__c.Physical_Street_Address__c => '123 Somewhere Ave',
            Enrollment_Site__c.Physical_City__c => 'Oklahoma City',
            Enrollment_Site__c.Physical_State__c => 'OK',
            Enrollment_Site__c.Physical_Zip__c => '12354'
        };
    }

    /**
     * @description Returns the SObject type for EnrollmentSiteTestData builder.
     * @return Enrollment_Site__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Enrollment_Site__c.SObjectType;
    }
    
    /**
     * @description Sets the account on the enrollment site.
     * @param accountId The id of the account that the enrollment site will have.
     * @return The instance of EnrollmentSiteTestData.
     */
    public EnrollmentSiteTestData withAccount(String accountId) {
        return (EnrollmentSiteTestData) withDynamicData(Enrollment_Site__c.Account__c, accountId);
    }

    /* Create a "with" method for each property that can be set */

    /**
     * @description Builds the Enrollment_Site__c object.
     * @return The created Enrollment_Site__c object.
     */
    public Enrollment_Site__c create() {
        return (Enrollment_Site__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Enrollment_Site__c object.
     * @return The inserted Enrollment_Site__c object.
     */
    public Enrollment_Site__c insertEnrollmentSite() {
        return (Enrollment_Site__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of EnrollmentSiteTestData.
     * @return EnrollmentSiteTestData instance.
     */
    public static EnrollmentSiteTestData Instance {
        get {
            if (Instance == null) {
                Instance = new EnrollmentSiteTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private EnrollmentSiteTestData() {
        super();
    }
}