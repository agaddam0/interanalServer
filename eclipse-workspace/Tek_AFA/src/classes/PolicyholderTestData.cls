/**
 * @description Builder class for dealing with Policyholder__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class PolicyholderTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Policyholder__c state for PolicyholderTestData.
     * @return A map of Policyholder__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Policyholder__c.Social_Security_Number__c => '4444444444',
            Policyholder__c.Customer_Number__c => '123456789',
            Policyholder__c.First_Name__c => 'Apex',
            Policyholder__c.Last_Name__c => 'Test'
        };
    }

    /**
     * @description Returns the SObject type for PolicyholderTestData builder.
     * @return Policyholder__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Policyholder__c.SObjectType;
    }
    
    /**
     * @description Sets the social security number on the policy holder.
     * @param ssn The social security number that the policy holder will have.
     * @return The instance of PolicyholderTestData.
     */
    public PolicyholderTestData withSocialSecurityNumber(String ssn) {
        return (PolicyholderTestData) withDynamicData(Policyholder__c.Social_Security_Number__c, ssn);
    }
    
    /**
     * @description Sets the customer number on the policy holder.
     * @param customerNumber The customer number that the policy holder will have.
     * @return The instance of PolicyholderTestData.
     */
    public PolicyholderTestData withCustomerNumber(String customerNumber) {
        return (PolicyholderTestData) withDynamicData(Policyholder__c.Customer_Number__c, customerNumber);
    }

    /**
     * @description Sets the first name on the policy holder.
     * @param firstName The first name that the policy holder will have.
     * @return The instance of PolicyholderTestData.
     */
    public PolicyholderTestData withFirstName(String firstName) {
        return (PolicyholderTestData) withDynamicData(Policyholder__c.First_Name__c, firstName);
    }

    /**
     * @description Sets the last name on the policy holder.
     * @param lastName The last name that the policy holder will have.
     * @return The instance of PolicyholderTestData.
     */
    public PolicyholderTestData withLastName(String lastName) {
        return (PolicyholderTestData) withDynamicData(Policyholder__c.Last_Name__c, lastName);
    }

    /**
     * @description Sets the owner on the policy holder.
     * @param ownerId The owner that the policy holder will have.
     * @return The instance of PolicyholderTestData.
     */
    public PolicyholderTestData withOwner(Id ownerId) {
        return (PolicyholderTestData) withDynamicData(Policyholder__c.OwnerId, ownerId);
    }
    
    /**
     * @description Builds the Policyholder__c object.
     * @return The created Policyholder__c object.
     */
    public Policyholder__c create() {
        return (Policyholder__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Policyholder__c object.
     * @return The inserted Policyholder__c object.
     */
    public Policyholder__c insertPolicyHolder() {
        return (Policyholder__c) super.insertRecord();
    }

    /**
     * @description Gets an instance of PolicyholderTestData.
     * @return PolicyholderTestData instance.
     */
    public static PolicyholderTestData Instance {
        get {
            if (Instance == null) {
                Instance = new PolicyholderTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private PolicyholderTestData() {
        super();
    }
}