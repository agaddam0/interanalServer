/**
 * @description Builder class for dealing with Email_Builder_Settings__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class EmailBuilderSettingsTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Email_Builder_Settings__c state for EmailBuilderSettingsTestData.
     * @return A map of Email_Builder_Settings__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Email_Builder_Settings__c.Authentication_URL__c => 'https://mc4xmnrlpk45345sfsdwj1tc1r7398.auth.marketingcloudapis.com/',
            Email_Builder_Settings__c.Client_Id__c => 'ABC123',
            Email_Builder_Settings__c.Client_Secret__c => 'ClientSecret',
            Email_Builder_Settings__c.Default_Preview_Subscriber_Key__c => 'DefaultPreviewEmail@example.com',
            Email_Builder_Settings__c.Preview_Data_Extension_External_Key__c => 'SFEmailBuilderPrototypePreview',
            Email_Builder_Settings__c.Preview_Data_Extension_External_Key__c => 'SFEmailBuilderPrototype',
            Email_Builder_Settings__c.Send_Email_Event_Definition_Key__c => 'SendEmailDefKey',
            Email_Builder_Settings__c.Email_Templates_Folder_Category_Id__c => '193819'
        };
    }

    /**
     * @description Returns the SObject type for EmailBuilderSettingsTestData builder.
     * @return Email_Builder_Settings__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Email_Builder_Settings__c.SObjectType;
    }

    /**
     * @description Builds the Email_Builder_Settings__c object.
     * @return The created Email_Builder_Settings__c object.
     */
    public Email_Builder_Settings__c create() {
        return (Email_Builder_Settings__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Email_Builder_Settings__c object.
     * @return The inserted Email_Builder_Settings__c object.
     */
    public Email_Builder_Settings__c insertEmailBuilderSettings() {
        return (Email_Builder_Settings__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of EmailBuilderSettingsTestData.
     * @return EmailBuilderSettingsTestData instance.
     */
    public static EmailBuilderSettingsTestData Instance {
        get {
            if (Instance == null) {
                Instance = new EmailBuilderSettingsTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private EmailBuilderSettingsTestData() {
        super();
    }
}