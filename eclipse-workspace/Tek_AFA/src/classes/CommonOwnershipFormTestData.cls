/**
 * @description Builder class for dealing with Common Ownership Form records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public class CommonOwnershipFormTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Common Ownership Form state for CommonOwnershipFormTestData.
     * @return A map of Common Ownership Form default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Common_Ownership_Form__c.OwnerId => UserInfo.getUserId()
        };
    }

    /**
     * @description Returns the SObject type for CommonOwnershipFormTestData builder.
     * @return Common_Ownership_Form__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Common_Ownership_Form__c.SObjectType;
    }

    /**
     * @description Sets the mcp setup form on the record.
     * @param mcpSetupFormId The id of the mcp setup form that the record will have.
     * @return The instance of CommonOwnershipFormTestData.
     */
    public CommonOwnershipFormTestData withMCPSetupForm(Id mcpSetupFormId) {
         return (CommonOwnershipFormTestData) withDynamicData(Common_Ownership_Form__c.MCP_Setup_Form__c, mcpSetupFormId);
    }
    
    /**
     * @description Sets the Section 125 Setup form on the record.
     * @param s125SetupFormId The id of the Section 125 Setup form that the record will have.
     * @return The instance of CommonOwnershipFormTestData.
     */
    public CommonOwnershipFormTestData withSection125SetupForm(Id s125SetupFormId) {
         return (CommonOwnershipFormTestData) withDynamicData(Common_Ownership_Form__c.Section_125_Setup_Form__c, s125SetupFormId);
    }
    
    /**
     * @description Inserts the built Common Ownership Form.
     * @return The inserted Common Ownership Form.
     */
    public Common_Ownership_Form__c insertCommonOwnershipForm() {
        return (Common_Ownership_Form__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of CommonOwnershipFormTestData.
     * @return CommonOwnershipFormTestData instance.
     */
    public static CommonOwnershipFormTestData Instance {
        get {
            if (Instance == null) {
                Instance = new CommonOwnershipFormTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private CommonOwnershipFormTestData() {
        super();
    }
}