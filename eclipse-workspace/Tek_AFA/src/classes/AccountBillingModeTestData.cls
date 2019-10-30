/**
 * @description Builder class for dealing with Account Billing Mode records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public without sharing class AccountBillingModeTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Branch Office state for BranchOfficeTestData.
     * @return A map of Branch Office default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Account_Billing_Mode__c.Frequency__c => 'M',
            Account_Billing_Mode__c.Billing_Mode_Description__c => 'MONTHLY',
            Account_Billing_Mode__c.Pay_Deductions__c => 'CURRENT'
        };
    }
    
    /**
     * @description Returns the SObject type for AccountBillingModeTestData builder.
     * @return Account_Billing_Mode__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Account_Billing_Mode__c.SObjectType;
    }

    /**
     * @description Sets the account on the Account Billing Mode record.
     * @param accountId The account id that the Account Billing Mode record will have.
     * @return The instance of AccountBillingModeTestData.
     */
    public AccountBillingModeTestData withAccount(Id accountId) {
        return (AccountBillingModeTestData) withDynamicData(Account_Billing_Mode__c.Account__c, accountId);
    }

    /**
     * @description Sets the payor number on the Account Billing Mode record.
     * @param payorNumber The payor number that the Account Billing Mode record will have.
     * @return The instance of AccountBillingModeTestData.
     */
    public AccountBillingModeTestData withPayorNumber(String payorNumber) {
        return (AccountBillingModeTestData) withDynamicData(Account_Billing_Mode__c.Payor_Number__c, payorNumber);
    }

    /**
     * @description Builds the Account Billing Mode object.
     * @return The created Account Billing Mode object.
     */
    public Account_Billing_Mode__c create() {
        return (Account_Billing_Mode__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Account Billing Mode object.
     * @return The inserted Account Billing Mode object.
     */
    public Account_Billing_Mode__c insertAccountBillingMode() {
        return (Account_Billing_Mode__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of AccountBillingModeTestData.
     * @return AccountBillingModeTestData instance.
     */
    public static AccountBillingModeTestData Instance {
        get {
            if (Instance == null) {
                Instance = new AccountBillingModeTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private AccountBillingModeTestData() {
        super();
    }
}