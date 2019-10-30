/**
 * @description Builder class for dealing with Customer Setup Form records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public class CustomerSetupFormTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Customer Setup Form state for CustomerSetupFormTestData.
     * @return A map of Customer Setup Form default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Customer_Setup_Form__c.OwnerId => UserInfo.getUserId()
        };
    }

    /**
     * @description Returns the SObject type for CustomerSetupFormTestData builder.
     * @return Customer_Setup_Form__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Customer_Setup_Form__c.SObjectType;
    }
    
    /**
     * @description Sets the enrollment form id on the Customer Setup Form record.
     * @param enrollmentFormId The enrollment form id that the Customer Setup Form record will have.
     * @return The instance of Section125SetupFormTestData.
     */
    public CustomerSetupFormTestData withEnrollmentForm(Id enrollmentFormId) {
        return (CustomerSetupFormTestData) withDynamicData(Customer_Setup_Form__c.Enrollment_Form__c, enrollmentFormId);
    }
    
    /**
     * @description Sets the benefit contact same as admin on the Customer Setup Form record.
     * @param benefitContactSameAsAdminYesNo The benefit contact same as admin that the Customer Setup Form record will have.
     * @return The instance of Section125SetupFormTestData.
     */
    public CustomerSetupFormTestData withBenefitContactSameAsAdmin(String benefitContactSameAsAdminYesNo) {
        return (CustomerSetupFormTestData) withDynamicData(Customer_Setup_Form__c.ContactInfoBenefitContactSame__c, benefitContactSameAsAdminYesNo);
    }

    /**
     * @description Sets the benefit contact id on the Customer Setup Form record.
     * @param benefitContactId The benefit contact id id that the Customer Setup Form record will have.
     * @return The instance of Section125SetupFormTestData.
     */
    public CustomerSetupFormTestData withBenefitContact(Id benefitContactId) {
        return (CustomerSetupFormTestData) withDynamicData(Customer_Setup_Form__c.ContactInfoBenefitContact__c, benefitContactId);
    }
    
    /**
     * @description creates the built Customer Setup Form without inserting it.
     * @return The created Customer Setup Form.
     */
    public Customer_Setup_Form__c createCustomerSetupForm() {
        return (Customer_Setup_Form__c)super.buildWithReset();
    }
    
    /**
     * @description Inserts the built Customer Setup Form.
     * @return The inserted Customer Setup Form.
     */
    public Customer_Setup_Form__c insertCustomerSetupForm() {
        return (Customer_Setup_Form__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of CustomerSetupFormTestData.
     * @return CustomerSetupFormTestData instance.
     */
    public static CustomerSetupFormTestData Instance {
        get {
            if (Instance == null) {
                Instance = new CustomerSetupFormTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private CustomerSetupFormTestData() {
        super();
    }
}