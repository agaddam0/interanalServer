/**
 * @description Builder class for dealing with Colleague Sales Office records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class ColleagueSalesOfficeTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Colleague Sales Office state for ColleagueSalesOfficeTestData.
     * @return A map of Sales Office default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{ };
    }

    /**
     * @description Returns the SObject type for MarketingMaterialTestData builder.
     * @return Marketing_Material__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Colleague_Sales_Office__c.SObjectType;
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Sets the sales office on the colleague sales office.
     * @param salesOffice The id of the sales office that the colleague sales office will have.
     * @return The instance of ColleagueSalesOfficeTestData.
     */
    public ColleagueSalesOfficeTestData withSalesOffice(Id salesOffice) {
        return (ColleagueSalesOfficeTestData) withDynamicData(Colleague_Sales_Office__c.Sales_Office__c, salesOffice);
    }

    /**
     * @description Sets the colleague on the colleague sales office.
     * @param colleague The id of the colleague that the colleague sales office will have.
     * @return The instance of ColleagueSalesOfficeTestData.
     */
    public ColleagueSalesOfficeTestData withColleague(Id colleague) {
        return (ColleagueSalesOfficeTestData) withDynamicData(Colleague_Sales_Office__c.Colleague__c, colleague);
    }
    
    /**
     * @description Builds the Colleague Sales Office object.
     * @return The created Colleague Sales Office object.
     */
    public Colleague_Sales_Office__c create() {
        return (Colleague_Sales_Office__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Colleague Sales Office object.
     * @return The inserted Colleague Sales Office object.
     */
    public Colleague_Sales_Office__c insertColleagueSalesOffice() {
        return (Colleague_Sales_Office__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of ColleagueSalesOfficeTestData.
     * @return ColleagueSalesOfficeTestData instance.
     */
    public static ColleagueSalesOfficeTestData Instance {
        get {
            if (Instance == null) {
                Instance = new ColleagueSalesOfficeTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private ColleagueSalesOfficeTestData() {
        super();
    }
}