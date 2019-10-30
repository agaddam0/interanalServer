/**
 * @description Builder class for dealing with Sales Office records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class SalesOfficeTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Sales Office state for SalesOfficeTestData.
     * @return A map of Sales Office default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Branch_Office__c.Name => 'An Office',
            Branch_Office__c.Status__c => 'Open'
        };
    }

    /**
     * @description Returns the SObject type for MarketingMaterialTestData builder.
     * @return Marketing_Material__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Branch_Office__c.SObjectType;
    }
    
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Sets the charge code on the sales office.
     * @param chargeCode The charge code that the sales office will have.
     * @return The instance of SalesOfficeTestData.
     */
    public SalesOfficeTestData withChargeCode(String chargeCode) {
        return (SalesOfficeTestData) withDynamicData(Branch_Office__c.Charge_Code__c, chargeCode);
    }

    /**
     * @description Sets the name on the sales office.
     * @param name The name that the sales office will have.
     * @return The instance of SalesOfficeTestData.
     */
    public SalesOfficeTestData withName(String name) {
        return (SalesOfficeTestData) withDynamicData(Branch_Office__c.Name, name);
    }

    /**
     * @description Builds the Sales Office object.
     * @return The created Sales Office object.
     */
    public Branch_Office__c create() {
        return (Branch_Office__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Sales Office object.
     * @return The inserted Sales Office object.
     */
    public Branch_Office__c insertSalesOffice() {
        return (Branch_Office__c)super.insertRecord();
    }
    
    /**
     * @description Insert the specified number of sales offices.
     * @param numberOfSalesOfficesToInsert The number of sales offices to insert.
     * @return The sales offices that were inserted.
     */
    public List<Branch_Office__c> insertSalesOffices(Integer numberOfSalesOfficesToInsert) {
        return (List<Branch_Office__c>) insertRecords(numberOfSalesOfficesToInsert);
    }

    /**
     * @description Gets an instance of SalesOfficeTestData.
     * @return SalesOfficeTestData instance.
     */
    public static SalesOfficeTestData Instance {
        get {
            if (Instance == null) {
                Instance = new SalesOfficeTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private SalesOfficeTestData() {
        super();
    }
}