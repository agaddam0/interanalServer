/**
 * @description Builder class for dealing with Unlock Request records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class UnlockRequestTestData extends SObjectTestData  {
    /**
     * @description Overridden method to set up the default
     * Unlock Request state for UnlockRequestTestData.
     * @return A map of Unlock Request default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{ };
    }
    
    /**
     * @description Returns the SObject type for UnlockRequestTestData builder.
     * @return Unlock_Request__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Unlock_Request__c.SObjectType;
    }
    
    /**
     * @description Sets the enrollment form on the unlock request.
     * @param enrollmentFormId The enrollment form id that the unlock request will have.
     * @return The instance of UnlockRequestTestData.
     */
    public UnlockRequestTestData withEnrollmentForm(Id enrollmentFormId) {
        return (UnlockRequestTestData) withDynamicData(Unlock_Request__c.Enrollment_Form__c, enrollmentFormId);
    }
    
    /* Create a "with" method for each property that can be set */

    /**
     * @description Builds the Unlock Request object.
     * @return The created Unlock Request object.
     */
    public Unlock_Request__c create() {
        return (Unlock_Request__c) super.buildWithReset();
    }

    /**
     * @description Inserts the built Unlock Request object.
     * @return The inserted Unlock Request object.
     */
    public Unlock_Request__c insertUnlockRequest() {
        return (Unlock_Request__c) super.insertRecord();
    }

    /**
     * @description Sets the unlock reason on the unlock request.
     * @param unlockReason The unlock reason that the unlock request will have.
     * @return The instance of UnlockRequestTestData.
     */
    public UnlockRequestTestData withUnlockReason(String unlockReason) {
        return (UnlockRequestTestData) withDynamicData(Unlock_Request__c.Unlock_Reason__c, unlockReason);
    }

    /**
     * @description Gets an instance of UnlockRequestTestData.
     * @return UnlockRequestTestData instance.
     */
    public static UnlockRequestTestData Instance {
        get {
            if (Instance == null) {
                Instance = new UnlockRequestTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private UnlockRequestTestData() {
        super();
    }
}