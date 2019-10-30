/**
 * @description Builder class for dealing with Core Benefits Form records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public without sharing class CoreBenefitsFormTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Core Benefits Form state for CoreBenefitsFormTestData.
     * @return A map of Core Benefits Form default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Core_Benefit_Form__c.Add_Core_Benefit__c => 'Medical',
            Core_Benefit_Form__c.Plan_Name__c => 'MVP Core Silver'
        };
    }
    
    /**
     * @description Returns the SObject type for CoreBenefitsFormTestData builder.
     * @return Contact.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Core_Benefit_Form__c.SObjectType;
    }
    
    /**
     * @description Sets the platform setup form on the core benefit form.
     * @param platformSetupId The id of the platform setup form that the core benefit form will have.
     * @return The instance of CoreBenefitsFormTestData.
     */
    public CoreBenefitsFormTestData withPlatformSetupForm(Id platformSetupId) {
        return (CoreBenefitsFormTestData) withDynamicData(Core_Benefit_Form__c.Platform_Setup_Form__c, platformSetupId);
    }
    
    /**
     * @description Builds the Core Benefit Form object.
     * @return The created Contact object.
     */
    public Core_Benefit_Form__c create() {
        return (Core_Benefit_Form__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Core Benefit Form object.
     * @return The inserted Contact object.
     */
    public Core_Benefit_Form__c insertCoreBenefitForm() {
        return (Core_Benefit_Form__c) super.insertRecord();
    }
    
    /**
     * @description Gets an instance of CoreBenefitsFormTestData.
     * @return CoreBenefitsFormTestData instance.
     */
    public static CoreBenefitsFormTestData Instance {
        get {
            if (Instance == null) {
                Instance = new CoreBenefitsFormTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private CoreBenefitsFormTestData() {
        super();
    }
}