@isTest
public with sharing class FieldSetComponentControllerTest {

    @isTest
    static void getDetails_orderLineItemFieldSetUsed_expectDetailsContextPopulatedTest() {
        Order__c someOrder = OrderTestData.Instance.insertCartOrder();
        Marketing_Material__c mm = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        Order_Line_Item__c oli = OrderLineItemTestData.Instance.withMarketingMaterial(mm.Id)
                                                               .withOrder(someOrder.Id)
                                                               .insertOrderLineItem();

        Map<String, Schema.FieldSet> orderLineItemFieldSets = Schema.SObjectType.Order_Line_Item__c.fieldSets.getMap();
        Schema.FieldSet oliFieldSet = orderLineItemFieldSets.values()[0];

        FieldSetComponentController.DetailsContext details = 
                FieldSetComponentController.getDetails('Order_Line_Item__c', oliFieldSet.getName(), oli.Id);

        system.assert(details != null, 'The details context is null.');
        system.assert(details.Fields != null, 'The fields are null.');
        system.assert(details.Record != null, 'The record is null.');
    }
}