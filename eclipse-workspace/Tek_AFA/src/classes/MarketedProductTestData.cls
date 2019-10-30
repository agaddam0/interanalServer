/**
 * @description Builder class for dealing with Product Catalog records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class MarketedProductTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Marketed Product state for MarketedProductTestData.
     * @return A map of Marketed Product default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Marketed_Product__c.Name => 'Default Marketed Product',
            Marketed_Product__c.Tax_Treatment__c => 'Pre-Tax'
        };
    }

    /**
     * @description Returns the SObject type for MarketedProductTestData builder.
     * @return Marketed_Product.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Marketed_Product__c.SObjectType;
    }
    
    /**
     * @description Sets the name on the Marketed Product.
     * @param name The name that the Marketed Product will have.
     * @return The instance of MarketedProductTestData.
     */
    public MarketedProductTestData withName(String name) {
        return (MarketedProductTestData) withDynamicData(Marketed_Product__c.Name, name);
    }
    
    /**
     * @description Sets the product catalog on the Marketed Product.
     * @param productCatalogId The id of the product catalog that the Marketed Product will have.
     * @return The instance of MarketedProductTestData.
     */
    public MarketedProductTestData withProductCatalog(Id productCatalogId) {
        return (MarketedProductTestData) withDynamicData(Marketed_Product__c.Products__c, productCatalogId);
    }
    
    /**
     * @description Sets the enrollment form on the Marketed Product.
     * @param enrollmentFormId The id of the enrollment form that the Marketed Product will have.
     * @return The instance of MarketedProductTestData.
     */
    public MarketedProductTestData withEnrollmentForm(Id enrollmentFormId) {
        return (MarketedProductTestData) withDynamicData(Marketed_Product__c.Enrollment__c, enrollmentFormId);
    }
    
    /**
     * @description Sets the plan status on the Marketed Product.
     * @param planStatus The plan status that the Marketed Product will have.
     * @return The instance of MarketedProductTestData.
     */
    public MarketedProductTestData withPlanStatus(String planStatus) {
        return (MarketedProductTestData) withDynamicData(Marketed_Product__c.Plan_Status__c, planStatus);
    }
    
    /**
     * @description Sets the include on employer benefits site on the Marketed Product.
     * @param includeOnEmployerBenefitsSite The include on employer benefits site that the Marketed Product will have.
     * @return The instance of MarketedProductTestData.
     */
    public MarketedProductTestData withIncludeOnEmployerBenefitsSite(Boolean includeOnEmployerBenefitsSite) {
        return (MarketedProductTestData) withDynamicData(Marketed_Product__c.Include_On_Employer_Benefits_Site__c, includeOnEmployerBenefitsSite);
    }
    
    /**
     * @description Sets the carrier on the Marketed Product.
     * @param carrier The carrier that the Marketed Product will have.
     * @return The instance of MarketedProductTestData.
     */
    public MarketedProductTestData withCarrier(String carrier) {
        return (MarketedProductTestData) withDynamicData(Marketed_Product__c.Carrier__c, carrier);
    }
    
    /**
     * @description Sets the carrier url on the Marketed Product.
     * @param carrierURL The carrier url that the Marketed Product will have.
     * @return The instance of MarketedProductTestData.
     */
    public MarketedProductTestData withCarrierURL(String carrierURL) {
        return (MarketedProductTestData) withDynamicData(Marketed_Product__c.Carrier_URL__c, carrierURL);
    }
    
    /**
     * @description Sets the tax treatment on the Marketed Product.
     * @param taxTreatment The tax treatment that the Marketed Product will have.
     * @return The instance of MarketedProductTestData.
     */
    public MarketedProductTestData withTaxTreatment(String taxTreatment) {
        return (MarketedProductTestData) withDynamicData(Marketed_Product__c.Tax_Treatment__c, taxTreatment);
    }
    
    /**
     * @description Sets the chassis on the Marketed Product.
     * @param chassis The chassis that the Marketed Product will have.
     * @return The instance of MarketedProductTestData.
     */
    public MarketedProductTestData withChassis(String chassis) {
        return (MarketedProductTestData) withDynamicData(Marketed_Product__c.Chassis__c, chassis);
    }

    /**
     * @description Builds the Marketed Product object.
     * @return The created Marketed Product object.
     */
    public Marketed_Product__c create() {
        return (Marketed_Product__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Marketed Product object.
     * @return The inserted Marketed Product object.
     */
    public Marketed_Product__c insertMarketedProduct() {
        return (Marketed_Product__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of MarketedProductTestData.
     * @return MarketedProductTestData instance.
     */
    public static MarketedProductTestData Instance {
        get {
            if (Instance == null) {
                Instance = new MarketedProductTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private MarketedProductTestData() {
        super();
    }
}