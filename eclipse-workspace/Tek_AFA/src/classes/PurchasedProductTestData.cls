/**
 * @description Builder class for dealing with Purchased_Product__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class PurchasedProductTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Purchased_Product__c state for PurchasedProductTestData.
     * @return A map of Purchased_Product__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Purchased_Product__c.Policy_Status__c => 'Active'
        };
    }

    /**
     * @description Returns the SObject type for PurchasedProductTestData builder.
     * @return Purchased_Product__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Purchased_Product__c.SObjectType;
    }

    /**
     * @description Sets the account on the purchased product.
     * @param accountId The id of the account that the purchased product will have.
     * @return The instance of PurchasedProductTestData.
     */
    public PurchasedProductTestData withAccount(Id accountId) {
        return (PurchasedProductTestData) withDynamicData(Purchased_Product__c.Account__c, accountId);
    }

    /**
     * @description Sets the policy holder on the purchased product.
     * @param policyholderId The id of the policy holder that the purchased product will have.
     * @return The instance of PurchasedProductTestData.
     */
    public PurchasedProductTestData withPolicyholder(Id policyholderId) {
        return (PurchasedProductTestData) withDynamicData(Purchased_Product__c.Policyholder__c, policyholderId);
    }

    /**
     * @description Sets the policy status on the purchased product.
     * @param policyStatus The policy status that the purchased product will have.
     * @return The instance of PurchasedProductTestData.
     */
    public PurchasedProductTestData withPolicyStatus(String policyStatus) {
        return (PurchasedProductTestData) withDynamicData(Purchased_Product__c.Policy_Status__c, policyStatus);
    }

    /**
     * @description Builds the Purchased_Product__c object.
     * @return The created Purchased_Product__c object.
     */
    public Purchased_Product__c create() {
        return (Purchased_Product__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Purchased_Product__c object.
     * @return The inserted Purchased_Product__c object.
     */
    public Purchased_Product__c insertPurchasedProduct() {
        return (Purchased_Product__c) super.insertRecord();
    }

    /**
     * @description Gets an instance of PurchasedProductTestData.
     * @return PurchasedProductTestData instance.
     */
    public static PurchasedProductTestData Instance {
        get {
            if (Instance == null) {
                Instance = new PurchasedProductTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private PurchasedProductTestData() {
        super();
    }
}