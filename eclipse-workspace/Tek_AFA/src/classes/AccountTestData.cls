/**
 * @description Builder class for dealing with Account records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public class AccountTestData extends SObjectTestData {
// Testing Admin CSM Webhook


    /**
     * @description Overridden method to set up the default
     * Account state for AccountTestData.
     * @return A map of Account default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Account.Name => 'Metillium, Inc.',
            Account.Marketing_Resource_Id__c => '3fb1581a-312b-4aa3-a3ea-023d35f67a5d',
            Account.Annualized_Premium__c => 10000
        };
    }

    /**
     * @description Returns the SObject type for AccountTestData builder.
     * @return Account.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    /**
     * @description Sets the name on the account.
     * @param name The name that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withName(String name) {
        return (AccountTestData) withDynamicData(Account.Name, name);
    }
    
    /**
     * @description Sets the record type on the account.
     * @param recordTypeId The record type that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withRecordTypeId(Id recordTypeId) {
        return (AccountTestData) withDynamicData(Account.RecordTypeId, recordTypeId);
    }
    
    /**
     * @description Sets the billing state on the account.
     * @param billingState The billing state that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withBillingState(String billingState) {
        return (AccountTestData) withDynamicData(Account.BillingState, billingState);
    }

    /**
     * @description Sets the marketing account name on the account.
     * @param marketingAccountName The marketing account name that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withMarketingAccountName(String marketingAccountName) {
        return (AccountTestData) withDynamicData(Account.Marketing_Account_Name__c, marketingAccountName);
    }

    /**
     * @description Sets the industry on the account.
     * @param industry The industry that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withIndustry(String industry) {
        return (AccountTestData) withDynamicData(Account.Industry, industry);
    }
    
    /**
     * @description Sets the marketing resource id on the account.
     * @param marketingResourceId The marketing resource id that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withMarketingResourceId(String marketingResourceId) {
        return (AccountTestData) withDynamicData(Account.Marketing_Resource_Id__c, marketingResourceId);
    }

    /**
     * @description Sets the payor number on the account.
     * @param payorNumber The payor number that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withPayorNumber(String payorNumber) {
        return (AccountTestData) withDynamicData(Account.PayorNumber__c, payorNumber);
    }
    
    /**
     * @description Sets the mcp number on the account.
     * @param mcpNumber The mcp number that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withMCPNumber(String mcpNumber) {
        return (AccountTestData) withDynamicData(Account.MCP_Number__c, mcpNumber);
    }
    
    /**
     * @description Sets the status on the account.
     * @param status The status that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withStatus(String status) {
        return (AccountTestData) withDynamicData(Account.Status__c, status);
    }
    
    /**
     * @description Sets the employer benefits site request datetime on the account.
     * @param employerBenefitsSiteRequestDatetime The employer benefits site request datetime that the account will have.
     * @return The instance of AccountTestData.
     */
    public AccountTestData withEmployerBenefitsSiteRequestDateTime(DateTime employerBenefitsSiteRequestDatetime) {
        return (AccountTestData) withDynamicData(Account.Employer_Benefits_Site_Request_DateTime__c, employerBenefitsSiteRequestDatetime);
    }
    
    /**
	* @description Sets the employer code on the account.
	* @param employerCode The employer code that the account will have.
	* @return The instance of AccountTestData.
	*/
    public AccountTestData withEmployerCode(String employerCode) {
        return (AccountTestData) withDynamicData(Account.Employer_Code__c, employerCode);
    }
        
    /**
    * @description Sets the Shipping City on the account.
    * @param city The city that the account will have.
    * @return The instance of AccountTestData.
    */
    public AccountTestData withShippingCity(String city) {
        return (AccountTestData) withDynamicData(Account.ShippingCity, city);
    }
    
    /**
    * @description Sets the ShippingState on the account.
    * @param state The status that the account will have.
    * @return The instance of AccountTestData.
    */
    public AccountTestData withShippingState(String state) {
        return (AccountTestData) withDynamicData(Account.ShippingState, state);
    }
    
    /**
    * @description Sets the record type to customer on the account.
    * @return The instance of AccountTestData.
    */
    public AccountTestData withCustomerAccount() {
        return (AccountTestData) withDynamicData(Account.RecordTypeId, Constants.ACCOUNT_CUSTOMER_ACCOUNT);
    }

    /**
    * @description Sets the owner on the account.
    * @param ownerId The owner that the account will have.
    * @return The instance of AccountTestData.
    */
    public AccountTestData withOwner(Id ownerId) {
        return (AccountTestData) withDynamicData(Account.OwnerId, ownerId);
    }

    /**
    * @description Sets the enrollment site on the account.
    * @param enrollmentSite The enrollment site that the account will have.
    * @return The instance of AccountTestData.
    */
    public AccountTestData withEnrollmentSite(String enrollmentSite) {
        return (AccountTestData) withDynamicData(Account.Enrollment_Site__c, enrollmentSite);
    }

    /**
    * @description Sets the requested microsite preenrollment form id on the account.
    * @param requestedMicrositePreenrollmentFormId The requested microsite preenrollment form id that the account will have.
    * @return The instance of AccountTestData.
    */
    public AccountTestData withRequestedMicrositePreenrollmentFormId(String requestedMicrositePreenrollmentFormId) {
        return (AccountTestData) withDynamicData(Account.Requested_Microsite_Prenrollment_Form_Id__c, requestedMicrositePreenrollmentFormId);
    }

    /**
    * @description Sets the Current_Enrollment_Coordinator__c on the account.
    * @param userId The user that the account will have for Current Enrollment Coordinator.
    * @return The instance of AccountTestData.
    */
    public AccountTestData withCurrentEnrollmentCoordinator(String userId) {
        return (AccountTestData) withDynamicData(Account.Current_Enrollment_Coordinator__c, userId);
    }

    /**
    * @description Sets the Additional_Enrollment_Coordinator__c on the account.
    * @param userId The user that the account will have for Additional Enrollment Coordinator.
    * @return The instance of AccountTestData.
    */
    public AccountTestData withAdditionalEnrollmentCoordinator(String userId) {
        return (AccountTestData) withDynamicData(Account.Additional_Enrollment_Coordinator__c, userId);
    }

    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Builds the Account object.
     * @return The created Account object.
     */
    public Account create() {
        return (Account)super.buildWithReset();
    }

    /**
     * @description Inserts the built Account object.
     * @return The inserted Account object.
     */
    public Account insertAccount() {
        return (Account)super.insertRecord();
    }
    
    /**
     * @description Inserts an account using only the default values.
     * @return The inserted account.
     */
    public Account insertDefaultAccount() {
        return (Account) insertDefaultRecord();
    }
    
    /**
     * @description Insert the specified number of accounts.
     * @param numberOfAccountsToInsert The number of accounts to insert.
     * @return The accounts that were inserted.
     */
    public List<Account> insertAccounts(Integer numberOfAccountsToInsert) {
        return (List<Account>) insertRecords(numberOfAccountsToInsert);
    }
    
    /**
     * @description Inserts the built Account with a Customer Account record type.
     * @return The inserted Account.
     */
    public Account insertCustomerAccount() {
        Map<String,Schema.RecordTypeInfo> accountRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Schema.RecordTypeInfo customAccountRTI = accountRecordTypes.get('Customer Account');
        withRecordTypeId(customAccountRTI.getRecordTypeId());
        
        return insertAccount();
    }

    /**
     * @description Gets an instance of AccountTestData.
     * @return AccountTestData instance.
     */
    public static AccountTestData Instance {
        get {
            if (Instance == null) {
                Instance = new AccountTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private AccountTestData() {
        super();
    }
}