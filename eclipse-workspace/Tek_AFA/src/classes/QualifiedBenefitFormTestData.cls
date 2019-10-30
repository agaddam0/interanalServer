/**
 * @description Builder class for dealing with Qualified Benefit Form records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public without sharing class QualifiedBenefitFormTestData extends SObjectTestData {
    
    /**
     * @description Overridden method to set up the default
     * Account state for AccountTestData.
     * @return A map of Account default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
        };
    }

    /**
     * @description Returns the SObject type for QualifiedBenefitFormTestData builder.
     * @return Qualified_Benefit_Form__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Qualified_Benefit_Form__c.SObjectType;
    }
    
    /**
     * @description Sets the section 125 on the qualified benefit form.
     * @param s125FormId The section 125 that the qualified benefit form will have.
     * @return The instance of QualifiedBenefitFormTestData.
     */
    public QualifiedBenefitFormTestData withSection125SetupForm(Id s125FormId) {
        return (QualifiedBenefitFormTestData) withDynamicData(Qualified_Benefit_Form__c.Customer_Setup_Form__c, s125FormId);
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Builds the qualified benefit form object.
     * @return The created qualified benefit form object.
     */
    public Qualified_Benefit_Form__c create() {
        return (Qualified_Benefit_Form__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built qualified benefit form object.
     * @return The inserted qualified benefit form object.
     */
    public Qualified_Benefit_Form__c insertQualifiedBenefitForm() {
        return (Qualified_Benefit_Form__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of QualifiedBenefitFormTestData.
     * @return QualifiedBenefitFormTestData instance.
     */
    public static QualifiedBenefitFormTestData Instance {
        get {
            if (Instance == null) {
                Instance = new QualifiedBenefitFormTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private QualifiedBenefitFormTestData() {
        super();
    }
}