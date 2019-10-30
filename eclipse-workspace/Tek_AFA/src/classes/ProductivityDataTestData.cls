/**
 * @description Builder class for dealing with Productivity_Data__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class ProductivityDataTestData extends SObjectTestData{
    /**
     * @description Overridden method to set up the default
     * Productivity_Data__c state for ProductivityDataTestData.
     * @return A map of Productivity_Data__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{ };
    }

    /**
     * @description Returns the SObject type for ProductivityDataTestData builder.
     * @return Productivity_Data__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Productivity_Data__c.SObjectType;
    }

    /**
     * @description Sets the CreatedDate on Productivity Data.
     * @param createdDate The created date that the productivity data will have.
     * @return The instance of ProductivityDataTestData.
     */
    public ProductivityDataTestData withCreatedDate(DateTime createdDate) {
        return (ProductivityDataTestData) withDynamicData(Productivity_Data__c.CreatedDate, createdDate);
    }

    /**
     * @description Sets the Account__c on Productivity Data.
     * @param accountId The account that the productivity data will have.
     * @return The instance of ProductivityDataTestData.
     */
    public ProductivityDataTestData withAccount(String accountId) {
        return (ProductivityDataTestData) withDynamicData(Productivity_Data__c.Account__c, accountId);
    }

    /**
     * @description Builds the Productivity_Data__c object.
     * @return The created Productivity_Data__c object.
     */
    public Productivity_Data__c create() {
        return (Productivity_Data__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Productivity_Data__c object.
     * @return The inserted Productivity_Data__c object.
     */
    public Productivity_Data__c insertProductivityData() {
        return (Productivity_Data__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of ProductivityDataTestData.
     * @return ProductivityDataTestData instance.
     */
    private static ProductivityDataTestData instancePriv = null;
    public static ProductivityDataTestData Instance {
        get {
            if (instancePriv == null) {
                instancePriv = new ProductivityDataTestData();
            }
            return instancePriv;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private ProductivityDataTestData() {
        super();
    }
}