/**
 * @description Builder class for dealing with Order Line Item records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class OrderLineItemTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Order Line Item state for OrderLineItemTestData.
     * @return A map of Order default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Order_Line_Item__c.Quantity__c => 1,
            Order_Line_Item__c.Status__c => 'In Progress',
            Order_Line_Item__c.Unit_Price__c => 25
        };
    }

    /**
     * @description Returns the SObject type for OrderLineItemTestData builder.
     * @return Order_Line_Item__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Order_Line_Item__c.SObjectType;
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Sets the account on the order line item.
     * @param accountId The account id that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withAccount(Id accountId) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Account__c, accountId);
    }
    
    /**
     * @description Sets the account name on the order line item.
     * @param accountName The account name that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withAccountName(String accountName) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Account_Name__c, accountName);
    }

    /**
     * @description Sets the colleague on the order line item.
     * @param colleagueId The colleague that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withColleague(Id colleagueId) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Colleague__c, colleagueId);
    }


    /**
     * @description Sets the colleague name on the order line item.
     * @param colleagueName The colleague name that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withColleagueName(String colleagueName) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Colleague_Name__c, colleagueName);
    }

    /**
     * @description Sets the enrollment start date on the order line item.
     * @param enrollmentStartDate The enrollment start date that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withEnrollmentStartDate(Date enrollmentStartDate) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Enrollment_Start_Date__c, enrollmentStartDate);
    }

    /**
     * @description Sets the enrollment end date on the order line item.
     * @param enrollmentEndDate The enrollment end date that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withEnrollmentEndDate(Date enrollmentEndDate) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Enrollment_End_Date__c, enrollmentEndDate);
    }

    /**
     * @description Sets the marketing account name on the order line item.
     * @param marketingAccountName The marketing account name that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withMarketingAccountName(String marketingAccountName) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Marketing_Account_Name__c, marketingAccountName);
    }
    
    /**
     * @description Sets the marketing material on the order line item.
     * @param marketingMaterialId The marketing material that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withMarketingMaterial(Id marketingMaterialId) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Marketing_Material__c, marketingMaterialId);
    }

    /**
     * @description Sets the material number on the order line item.
     * @param materialNumber The material number that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withMaterialNumber(String materialNumber) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Material_Number__c, materialNumber);
    }
    
    /**
     * @description Sets the opportunity on the order line item.
     * @param opportunityId The opportunity that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withOpportunity(Id opportunityId) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Opportunity__c, opportunityId);
    }
    
    /**
     * @description Sets the Sales Office on the order line item.
     * @param salesOfficeId of The Branch Office that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withSalesOffice(Id salesOfficeId) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Sales_Office__c, salesOfficeId);
    }
    
    /**
     * @description Sets the order on the order line item.
     * @param orderId The id of the order that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withOrder(Id orderId) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Order__c, orderId);
    }
    
    /**
     * @description Sets the quantity on the order line item.
     * @param quantity The quantity that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withQuantity(Integer quantity) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Quantity__c, quantity);
    }

    /**
     * @description Sets the shippable on the order line item.
     * @param shippable The shippable that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withShippable(Boolean shippable) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Shippable__c, shippable);
    }
    
    /**
     * @description Sets the state on the order line item.
     * @param state The state that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withState(String state) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.State__c, state);
    }
    
    /**
     * @description Sets the status on the order line item.
     * @param status The status that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withStatus(String status) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Status__c, status);
    }
    
    /**
     * @description Sets the unit price on the order line item.
     * @param unitPrice The unit price that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withUnitPrice(Decimal unitPrice) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Unit_Price__c, unitPrice);
    }

    /**
     * @description Sets the preenrollment marketing form on the order line item.
     * @param preenrollmentMarketingFormId The preenrollment marketing form that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withPreenrollmentMarketingForm(Id preenrollmentMarketingFormId) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Preenrollment_Marketing_Form__c, preenrollmentMarketingFormId);
    }

    /**
     * @description Sets the plan date on the order line item.
     * @param planDate The plan date that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withPlanDate(Date planDate) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Plan_Date__c, planDate);
    }

    /**
     * @description Sets the section 125 on the order line item.
     * @param section125 The section 125 that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withSection125(String section125) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Section_125__c, section125);
    }

    /**
     * @description Sets the flex on the order line item.
     * @param flex The flex that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withFlex(String flex) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Flex__c, flex);
    }

    /**
     * @description Sets the colleague license on the order line item.
     * @param colleagueLicense The colleague license that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withColleagueLicense(String colleagueLicense) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Colleague_License__c, colleagueLicense);
    }

    /**
     * @description Sets the product option 1 on the order line item.
     * @param productOption1 The product option 1 that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withProductOption1(String productOption1) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Product_Option_1__c, productOption1);
    }

    /**
     * @description Sets the product option 2 on the order line item.
     * @param productOption2 The product option 2 that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withProductOption2(String productOption2) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Product_Option_2__c, productOption2);
    }

    /**
     * @description Sets the group product option 1 on the order line item.
     * @param groupProductOption1 The group product option 1 that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withGroupProductOption1(String groupProductOption1) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Group_Product_Option_1__c, groupProductOption1);
    }

    /**
     * @description Sets the group product option 2 on the order line item.
     * @param groupProductOption2 The group product option 2 that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withGroupProductOption2(String groupProductOption2) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Group_Product_Option_2__c, groupProductOption2);
    }

    /**
     * @description Sets the combo product option 1 on the order line item.
     * @param comboProductOption1 The combo product option 1 that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withComboProductOption1(String comboProductOption1) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Combo_Product_Option_1__c, comboProductOption1);
    }

    /**
     * @description Sets the combo product option 2 on the order line item.
     * @param comboProductOption2 The combo product option 2 that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withComboProductOption2(String comboProductOption2) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Combo_Product_Option_2__c, comboProductOption2);
    }

    /**
     * @description Sets the products on the order line item.
     * @param products The products that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withProducts(String products) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Products__c, products);
    }

    /**
     * @description Sets the preenrollment products on the order line item.
     * @param preenrollmentProducts The preenrollment products that the order line item will have.
     * @return The instance of OrderTestData.
     */
    public OrderLineItemTestData withPreenrollmentProducts(String preenrollmentProducts) {
        return (OrderLineItemTestData) withDynamicData(Order_Line_Item__c.Pre_enrollment_Products__c, preenrollmentProducts);
    }

    protected override void beforeBuild() {
        Object orderId = currentValueFor(Order_Line_Item__c.Order__c);
        
        if (orderId == null) {
            Order__c order = OrderTestData.Instance.insertOrder();
            
            withOrder(order.Id);
        }
    }

    /**
     * @description Builds the Order_Line_Item__c object.
     * @return The created Order_Line_Item__c object.
     */
    public Order_Line_Item__c create() {
        return (Order_Line_Item__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Order_Line_Item__c object.
     * @return The inserted Order_Line_Item__c object.
     */
    public Order_Line_Item__c insertOrderLineItem() {
        return (Order_Line_Item__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of OrderLineItemTestData.
     * @return OrderLineItemTestData instance.
     */
    public static OrderLineItemTestData Instance {
        get {
            if (Instance == null) {
                Instance = new OrderLineItemTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private OrderLineItemTestData() {
        super();
    }
}