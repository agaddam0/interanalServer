/**
 * @description Builder class for dealing with Product Catalog records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class ProductCatalogTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Product Catalog state for ProductCatalogTestData.
     * @return A map of Product Catalog default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Product_Catalog__c.Name => 'Default Benefit Product',
            Product_Catalog__c.Type__c => 'Benefit',
            Product_Catalog__c.Status__c => 'Active',
            Product_Catalog__c.Order__c => 1,
            Product_Catalog__c.Tax_Treatment__c => 'Pre-Tax',
            Product_Catalog__c.Division_Availability__c => 'Both',
            Product_Catalog__c.Employer_Benefits_Site_Eligible__c => true
        };
    }

    /**
     * @description Returns the SObject type for ProductCatalogTestData builder.
     * @return Product_Catalog__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Product_Catalog__c.SObjectType;
    }
    
    /**
     * @description Sets the name on the Product Catalog.
     * @param name The name that the product catalog will have.
     * @return The instance of ProductCatalogTestData.
     */
    public ProductCatalogTestData withName(String name) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Name, name);
    }
    
    /**
     * @description Sets the order on the Product Catalog.
     * @param order The order that the product catalog will have.
     * @return The instance of ProductCatalogTestData.
     */
    public ProductCatalogTestData withOrder(Integer order) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Order__c, order);
    }
    
    /**
     * @description Sets the type on the Product Catalog.
     * @param type The type that the product catalog will have.
     * @return The instance of ProductCatalogTestData.
     */
    public ProductCatalogTestData withType(String type) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Type__c, type);
    }
    
    /**
     * @description Sets the product family on the Product Catalog.
     * @param productFamily The product family that the product catalog will have.
     * @return The instance of ProductCatalogTestData.
     */
    public ProductCatalogTestData withProductFamily(String productFamily) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Product_Family__c, productFamily);
    }

    /**
     * @description Sets the allowed to be added to enrollment on the Product Catalog.
     * @param allowed The allowed to be added to enrollment that the product catalog will have.
     * @return The instance of ProductCatalogTestData.
     */
    public ProductCatalogTestData withAllowedToBeAddedToEnrollment(Boolean allowed) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Allowed_To_Be_Added_To_Enrollment__c, allowed);
    }
    
    /**
     * @description Sets the is tax treatment editable on the Product Catalog.
     * @param isTaxTreatmentEditable The is tax treatment editable that the product catalog will have.
     * @return The instance of ProductCatalogTestData.
     */
    public ProductCatalogTestData withIsTaxTreatmentEditable(Boolean isTaxTreatmentEditable) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Is_Tax_Treatment_Editable__c, isTaxTreatmentEditable);
    }
    
    /**
     * @description Sets the chassis on the Product Catalog.
     * @param chassis The chassis that the Product Catalog will have.
     * @return The instance of MarketedProductTestData.
     */
    public ProductCatalogTestData withChassis(String chassis) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Chassis__c, chassis);
    }
    
    /**
     * @description Sets the rider on the Product Catalog.
     * @param rider The rider that the Product Catalog will have.
     * @return The instance of MarketedProductTestData.
     */
    public ProductCatalogTestData withRider(Boolean rider) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Rider__c, rider);
    }
    
    /**
     * @description Sets the resource id on the Product Catalog.
     * @param resourceId The resource id that the Product Catalog will have.
     * @return The instance of MarketedProductTestData.
     */
    public ProductCatalogTestData withResourceId(String resourceId) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Resource_ID__c, resourceId);
    }

    /**
     * @description Sets the marketplace production option on the Product Catalog.
     * @param marketplaceProductOption The marketplace production option that the Product Catalog will have.
     * @return The instance of MarketedProductTestData.
     */
    public ProductCatalogTestData withMarketplaceProductOption(String marketplaceProductOption) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Marketplace_Product_Option__c, marketplaceProductOption);
    }

    /**
     * @description Sets the plan status option on the Product Catalog.
     * @param planStatus The plan status that the Product Catalog will have.
     * @return The instance of ProductCatalogTestData.
     */
    public ProductCatalogTestData withPlanStatus(String planStatus) {
        return (ProductCatalogTestData) withDynamicData(Product_Catalog__c.Plan_Status__c, planStatus);
    }
    
    /**
     * @description Builds the Product Catalog object.
     * @return The created Product Catalog object.
     */
    public Product_Catalog__c create() {
        return (Product_Catalog__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Product Catalog object.
     * @return The inserted Product Catalog object.
     */
    public Product_Catalog__c insertProductCatalog() {
        return (Product_Catalog__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of ProductCatalogTestData.
     * @return ProductCatalogTestData instance.
     */
    public static ProductCatalogTestData Instance {
        get {
            if (Instance == null) {
                Instance = new ProductCatalogTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private ProductCatalogTestData() {
        super();
    }
}