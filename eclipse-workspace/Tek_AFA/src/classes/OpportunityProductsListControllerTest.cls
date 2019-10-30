@isTest
public class OpportunityProductsListControllerTest {
    
    private static Enrollment_Form__c DefaultOpportunityEnrollmentForm;
    private static Opportunity DefaultOpportunity                           { get; set; }
    
    @testSetup
    static void testData() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
        loadDefaults();
        Product_Catalog__c benefitProduct = ProductCatalogTestData.Instance.withType('Benefit').insertProductCatalog();
        Marketed_Product__c benefitMarketedProduct = MarketedProductTestData.Instance.withProductCatalog(benefitProduct.Id)
                                                                                     .withEnrollmentForm(DefaultOpportunityEnrollmentForm.Id)
                                                                                     .insertMarketedProduct();
    }
    
    private static void loadDefaults() {
        DefaultOpportunity = getDefaultOpportunity();
        DefaultOpportunityEnrollmentForm = loadDefaultOpportunityEnrollmentForm(DefaultOpportunity.Id); 
    }
    
    private static Enrollment_Form__c loadDefaultOpportunityEnrollmentForm(Id oppId) {
        return
            [SELECT Id,
             Name
             FROM Enrollment_Form__c
             WHERE Enrollment_Opportunity__c = :oppId];
    }
    
    private static Opportunity getDefaultOpportunity() {
        return
            [SELECT Id,
             Name
             FROM Opportunity];
    }
    
    @isTest
    public static void getProductsTest_shouldReturnNull()
    {
        Opportunity opp = OpportunityTestData.Instance.withRecordTypeId(Constants.OPPORTUNITY_AFAS).insertOpportunity();
        
        List<Marketed_Product__c> products = OpportunityProductsListController.getProducts(opp.Id);
        
        system.assertEquals(null, products, 'The enrollment form was not null');
        
    }
    
    @isTest
    public static void getProductsTest_shouldReturnOneProduct()
    {
        DefaultOpportunity = getDefaultOpportunity();
        
        List<Marketed_Product__c> products = OpportunityProductsListController.getProducts(DefaultOpportunity.Id);
        
        system.assertEquals(1, products.size(), 'Query did not return the product');
    }
}