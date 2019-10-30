/**
 * @description Builder class for dealing with Order records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class OrderTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Order state for OrderTestData.
     * @return A map of Order default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Order__c.Order_Name__c => 'Some Order 1',
            Order__c.Status__c => 'In Progress',
            Order__c.Requested_Delivery_Date__c => system.today().addDays(10)
        };
    }

    /**
     * @description Returns the SObject type for OrderTestData builder.
     * @return Order__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Order__c.SObjectType;
    }

    /* Create a "with" method for each property that can be set */

    /**
     * @description Sets the order name on the order.
     * @param orderName The order name that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withOrderName(String orderName) {
        return (OrderTestData) withDynamicData(Order__c.Order_Name__c, orderName);
    }
    
    /**
     * @description Sets the status on the order.
     * @param status The status that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withStatus(String status) {
        return (OrderTestData) withDynamicData(Order__c.Status__c, status);
    }
    
    /**
     * @description Sets the Created Date which drives the Expiration Date on the order.
     * @param createdDate The CreatedDate that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withCreatedDate(Date createdDate) {
        return (OrderTestData) withDynamicData(Order__c.CreatedDate, createdDate);
    }
    
    /**
     * @description Sets the requested delivery date on the order.
     * @param requestedDeliveryDate The requested delivery date that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withRequestedDeliveryDate(Date requestedDeliveryDate) {
        return (OrderTestData) withDynamicData(Order__c.Requested_Delivery_Date__c, requestedDeliveryDate);
    }
    
    /**
     * @description Sets the colleague on the order.
     * @param colleagueUserId The id of the colleague that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withColleague(Id colleagueUserId) {
        return (OrderTestData) withDynamicData(Order__c.Colleague__c, colleagueUserId);
    }
    
    /**
     * @description Sets the additional notes on the order.
     * @param additionalNotes The additional notes that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withAdditionalNotes(String additionalNotes) {
        return (OrderTestData) withDynamicData(Order__c.Additional_Notes__c, additionalNotes);
    }
    
    /**
     * @description Sets the af press order on the order.
     * @param afPressOrder The af press order that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withAFPressOrder(String afPressOrder) {
        return (OrderTestData) withDynamicData(Order__c.AFPress_Order__c, afPressOrder);
    }

    /**
     * @description Sets the charge code on the order.
     * @param chargeCode The charge code that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withChargeCode(String chargeCode) {
        return (OrderTestData) withDynamicData(Order__c.Charge_Code__c, chargeCode);
    }

    /**
     * @description Sets the date fulfilled on the order.
     * @param fulfilledDate The fulfilled date that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withDateFulfilled(Date fulfilledDate) {
        return (OrderTestData) withDynamicData(Order__c.Date_Fulfilled__c, fulfilledDate);
    }
    
    /**
     * @description Sets the date submitted on the order.
     * @param submittedDate The date submitted that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withDateSubmitted(DateTime submittedDate) {
        return (OrderTestData) withDynamicData(Order__c.Date_Submitted__c, submittedDate);
    }
    
    /**
     * @description Sets the rush order on the order.
     * @param rushOrder The rush order that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withRushOrder(Boolean rushOrder) {
        return (OrderTestData) withDynamicData(Order__c.Rush_Order__c, rushOrder);
    }
    
    /**
     * @description Sets the mail code on the order.
     * @param mailCode The mail code that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withMailCode(String mailCode) {
        return (OrderTestData) withDynamicData(Order__c.Mail_Code__c, mailCode);
    }
    
    /**
     * @description Sets the Ship To on the order.
     * @param shipTo The ship to value the order will have
     * @return The instance of OrderTestData.
     */
    public OrderTestData withShipTo(String shipTo) {
        return (OrderTestData) withDynamicData(Order__c.Ship_To__c, shipTo);
    }   
    
    /**
     * @description Sets the shipping location on the order.
     * @param mailCode The shipping location that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withShippingLocation(String shippingLocation) {
        return (OrderTestData) withDynamicData(Order__c.Shipping_Location__c, shippingLocation);
    }   
    
    /**
     * @description Sets the shipping street on the order.
     * @param shippingStreet The shipping street that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withShippingStreet(String shippingStreet) {
        return (OrderTestData) withDynamicData(Order__c.Shipping_Street__c, shippingStreet);
    }
    
    /**
     * @description Sets the shipping city on the order.
     * @param shippingCity The shipping city that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withShippingCity(String shippingCity) {
        return (OrderTestData) withDynamicData(Order__c.Shipping_City__c, shippingCity);
    }
    
    /**
     * @description Sets the shipping state on the order.
     * @param shippingState The shipping state that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withShippingState(String shippingState) {
        return (OrderTestData) withDynamicData(Order__c.Shipping_State__c, shippingState);
    }
    
    /**
     * @description Sets the shipping zip on the order.
     * @param shippingZip The shipping zip that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withShippingZip(String shippingZip) {
        return (OrderTestData) withDynamicData(Order__c.Shipping_Zip__c, shippingZip);
    }
    
    /**
     * @description Sets the shipping tracking on the order.
     * @param shippingTracking The shipping tracking that the order will have.
     * @return The instance of OrderTestData.
     */
    public OrderTestData withShippingTracking(String shippingTracking) {
        return (OrderTestData) withDynamicData(Order__c.Shipping_Tracking__c, shippingTracking);
    }

    /**
     * @description Builds the Order__c object.
     * @return The created Order__c object.
     */
    public Order__c create() {
        return (Order__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Order__c object.
     * @return The inserted Order__c object.
     */
    public Order__c insertOrder() {
        return (Order__c)super.insertRecord();
    }
    
    /**
     * @description Inserts the built Order__c object with a status of In Progress.
     * @return The inserted Order__c object.
     */
    public Order__c insertCartOrder() {
        return withStatus('In Progress').insertOrder();
    }

    /**
     * @description Gets an instance of OrderTestData.
     * @return OrderTestData instance.
     */
    public static OrderTestData Instance {
        get {
            if (Instance == null) {
                Instance = new OrderTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private OrderTestData() {
        super();
    }
}