/**
 * @description Builder class for dealing with Section 125 Setup Form records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public class Section125SetupFormTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Section 125 Setup Form state for Section125SetupFormTestData.
     * @return A map of Section 125 Setup Form default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Section_125_Setup_Form__c.OwnerId => UserInfo.getUserId()
        };
    }

    /**
     * @description Returns the SObject type for Section125SetupFormTestData builder.
     * @return Section_125_Setup_Form__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Section_125_Setup_Form__c.SObjectType;
    }

    /**
     * @description Sets the enrollment form id on the S125 record.
     * @param enrollmentFormId The enrollment form id that the S125 record will have.
     * @return The instance of Section125SetupFormTestData.
     */
    public Section125SetupFormTestData withEnrollmentForm(Id enrollmentFormId) {
        return (Section125SetupFormTestData) withDynamicData(Section_125_Setup_Form__c.Enrollment_Form__c, enrollmentFormId);
    }
    
    /**
     * @description Inserts the built Section 125 Setup Form.
     * @return The inserted Section 125 Setup Form.
     */
    public Section_125_Setup_Form__c insertS125SetupForm() {
        return (Section_125_Setup_Form__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of Section125SetupFormTestData.
     * @return Section125SetupFormTestData instance.
     */
    public static Section125SetupFormTestData Instance {
        get {
            if (Instance == null) {
                Instance = new Section125SetupFormTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private Section125SetupFormTestData() {
        super();
    }
}