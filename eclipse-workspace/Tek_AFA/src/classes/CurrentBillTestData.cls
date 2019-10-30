/**
 * @description Builder class for dealing with Current_Bill__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class CurrentBillTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Current_Bill__c state for CurrentBillTestData.
     * @return A map of Current_Bill__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Current_Bill__c.Bill_Id__c => '193819'
        };
    }
    
    /**
     * @description Returns the SObject type for CurrentBillTestData builder.
     * @return Current_Bill__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Current_Bill__c.SObjectType;
    }

    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Sets the account on the current bill.
     * @param accountId The account that the current bill will have.
     * @return The instance of CurrentBillTestData.
     */
    public CurrentBillTestData withAccount(Id accountId) {
        return (CurrentBillTestData) withDynamicData(Current_Bill__c.Account__c, accountId);
    }

    /**
     * @description Sets the mcp on the current bill.
     * @param mcp The mcp that the current bill will have.
     * @return The instance of CurrentBillTestData.
     */
    public CurrentBillTestData withMCP(String mcp) {
        return (CurrentBillTestData) withDynamicData(Current_Bill__c.MCP__c, mcp);
    }

    /**
     * @description Sets the bill id on the current bill.
     * @param billId The bill id that the current bill will have.
     * @return The instance of CurrentBillTestData.
     */
    public CurrentBillTestData withBillId(String billId) {
        return (CurrentBillTestData) withDynamicData(Current_Bill__c.Bill_Id__c, billId);
    }
    

    /**
     * @description Builds the Current_Bill__c object.
     * @return The created Current_Bill__c object.
     */
    public Current_Bill__c create() {
        return (Current_Bill__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Current_Bill__c object.
     * @return The inserted Current_Bill__c object.
     */
    public Current_Bill__c insertCurrentBill() {
        return (Current_Bill__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of CurrentBillTestData.
     * @return CurrentBillTestData instance.
     */
    public static CurrentBillTestData Instance {
        get {
            if (Instance == null) {
                Instance = new CurrentBillTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private CurrentBillTestData() {
        super();
    }
}