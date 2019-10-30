@isTest
public class EmailComponentGetLineItemsTest {

    @testSetup
    static void testSetup()
    {
        Account newAccount = AccountTestData.Instance.withMarketingAccountName('Market Name A')
                                                     .withIndustry('Education')
                                                     .insertAccount();
        
        Opportunity enrollmentOpp = OpportunityTestData.Instance.withEnrollmentStartDate(Date.Today().addDays(25))
                                                                .withEnrollmentEndDate(Date.Today().addDays(105))
                                                                .insertAFESOpportunity();

        Order__c someOrder = OrderTestData.Instance.insertOrder();
        
        Map<String, Schema.FieldSet> CustomizationTypeFieldSet = Schema.SObjectType.Marketing_Material__c.fieldSets.getMap(); 
        Schema.FieldSet materialFieldSet = CustomizationTypeFieldSet.values()[0];
        
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.withCustomizationType(materialFieldSet.getName())
            																   .insertMarketingMaterial();
        
        Branch_Office__c anOffice = BranchOfficeTestData.Instance.insertBranchOffice();
        
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
                                                                   .withOrder(someOrder.Id)
                                                                   .withAccount(newAccount.Id)
                                                                   .withMarketingAccountName(newAccount.Marketing_Account_Name__c)
            													   .withOpportunity(enrollmentOpp.Id)
            													   .withColleague(UserInfo.getUserId())
            													   .withSalesOffice(anOffice.Id)
                                                                   .insertOrderLineItem();
    }
    
    static testMethod void testEmailComponentGetLineItems()
    {
        String soql = util.getCreatableFields('Order__c');
        soql += ' FROM Order__c';
        
        List<Order__c> orders = (List<Order__c>)database.query(soql);
        
        EmailComponentGetLineItems emailController = new EmailComponentGetLineItems();
        emailController.order_Id = orders[0].Id;
        emailController.processing_Type = '';
        
        system.assertNotEquals(null, emailController.OrderLineItems);
    }
}