/**
 * @description Builder class for dealing with Contact records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public without sharing class ContactTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Contact state for ContactTestData.
     * @return A map of Contact default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Contact.FirstName => 'FirstName',
            Contact.LastName => 'LastName',
            Contact.Email => 'someone@example.com'
        };
    }

    /**
     * @description Returns the SObject type for ContactTestData builder.
     * @return Contact.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }
    
    /**
     * @description Sets the first name on the contact
     * @param firstName The first name that the contact will have.
     * @return The instance of ContactTestData.
     */
    public ContactTestData withFirstName(String firstName) {
        return (ContactTestData) withDynamicData(Contact.FirstName, firstName);
    }
    
    /**
     * @description Sets the last name on the contact
     * @param lastName The last name that the contact will have.
     * @return The instance of ContactTestData.
     */
    public ContactTestData withLastName(String lastName) {
        return (ContactTestData) withDynamicData(Contact.LastName, lastName);
    }

    /**
     * @description Sets the accountId on the contact
     * @param accountId The Account that the contact will have.
     * @return The instance of ContactTestData.
     */
    public ContactTestData withAccount(String accountId) {
        return (ContactTestData) withDynamicData(Contact.AccountId, accountId);
    }

    /**
     * @description Sets the General_Contact__c on the contact
     * @param generalContact The flag  that the denotes if a contact is a general contact.
     * @return The instance of ContactTestData.
     */
    public ContactTestData withGeneralContact(Boolean generalContact) {
        return (ContactTestData) withDynamicData(Contact.General_Contact__c, generalContact);
    }

    /**
     * @description Sets the Billing_Contact__c on the contact
     * @param billingContact The flag  that the denotes if a contact is a billing contact.
     * @return The instance of ContactTestData.
     */
    public ContactTestData withBillingContact(Boolean billingContact) {
        return (ContactTestData) withDynamicData(Contact.Billing_Contact__c, billingContact);
    }

    /**
     * @description Builds the Contact object.
     * @return The created Contact object.
     */
    public Contact create() {
        return (Contact)super.buildWithReset();
    }

    /**
     * @description Inserts the built Contact object.
     * @return The inserted Contact object.
     */
    public Contact insertContact() {
        return (Contact) super.insertRecord();
    }

    /**
     * @description Gets an instance of ContactTestData.
     * @return ContactTestData instance.
     */
    public static ContactTestData Instance {
        get {
            if (Instance == null) {
                Instance = new ContactTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private ContactTestData() {
        super();
    }
}