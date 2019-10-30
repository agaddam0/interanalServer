@isTest
public with sharing class ShoppingCartControllerTest {
    
    @isTest
    static void getOrderForConfirmation_orderOnlyWithNoDownloadableOrderLines_expectOrderOnlyTest() {
        Order__c someOrder = OrderTestData.Instance.insertOrder();
        
        ShoppingCartController.OrderConfirmation confirmation =
                ShoppingCartController.getOrderForConfirmation(someOrder.Id);

        assertOrderWithNoDownloadableOrderLines(confirmation);
    }
    
    @isTest
    static void getOrderForConfirmation_orderWithOneDownloadableOrderLine_expectOrderWithOneDownloadableOrderLineTest() {
        Order__c someOrder = OrderTestData.Instance.insertOrder();
        String downloadableDocumentId = '069m0000000DzthAAC';
        
        Marketing_Material__c downloadableMarketingMaterial =
                MarketingMaterialTestData.Instance.withProcessingType('Download Only')
                                                  .withDownloadURL('https://americanfidelity--lfreeland.cs20.my.salesforce.com/sfc/servlet.shepherd/document/download/' + downloadableDocumentId)
                                                  .insertMarketingMaterial();

        Order_Line_Item__c downloadableOLI = OrderLineItemTestData.Instance.withOrder(someOrder.Id)
                                                                           .withMarketingMaterial(downloadableMarketingMaterial.Id)
                                                                           .insertOrderLineItem();
        
        ShoppingCartController.OrderConfirmation confirmation =
                ShoppingCartController.getOrderForConfirmation(someOrder.Id);

        assertOrderWithDownloadableOrderLines(confirmation, new List<String>{ downloadableDocumentId });
    }
    
    @isTest
    static void getOrderForConfirmation_orderWithTwoDownloadableOrderLines_expectOrderWithTwoDownloadableOrderLineTest() {
        Order__c someOrder = OrderTestData.Instance.insertOrder();
        String downloadableDocumentId = '069m0000000DzthAAC';
        String downloadableDocumentId2 = '069m0000000DathAAD';
        
        Marketing_Material__c downloadableMarketingMaterial =
                MarketingMaterialTestData.Instance.withProcessingType('Download Only')
                                                  .withDownloadURL('https://americanfidelity--lfreeland.cs20.my.salesforce.com/sfc/servlet.shepherd/document/download/' + downloadableDocumentId)
                                                  .insertMarketingMaterial();

        Marketing_Material__c downloadableMarketingMaterial2 =
                MarketingMaterialTestData.Instance.withProcessingType('Download Only')
                                                  .withMaterialNumber(downloadableMarketingMaterial.Material_Number__c + '123')
                                                  .withDownloadURL('https://americanfidelity--lfreeland.cs20.my.salesforce.com/sfc/servlet.shepherd/document/download/' + downloadableDocumentId2)
                                                  .insertMarketingMaterial();

        Order_Line_Item__c downloadableOLI = OrderLineItemTestData.Instance.withOrder(someOrder.Id)
                                                                           .withMarketingMaterial(downloadableMarketingMaterial.Id)
                                                                           .insertOrderLineItem();

        Order_Line_Item__c downloadableOLI2 = OrderLineItemTestData.Instance.withOrder(someOrder.Id)
                                                                           .withMarketingMaterial(downloadableMarketingMaterial2.Id)
                                                                           .insertOrderLineItem();
        
        ShoppingCartController.OrderConfirmation confirmation =
                ShoppingCartController.getOrderForConfirmation(someOrder.Id);

        assertOrderWithDownloadableOrderLines(confirmation, new List<String>{ downloadableDocumentId, downloadableDocumentId2 });
    }
    
    @isTest
    static void getTagCategories_noTagCategories_expectNoTagCategoriesFoundTest() {
        List<Tag_Category__c> tagCategories = ShoppingCartController.getTagCategories();
        
        system.assertEquals(0, tagCategories.size(), 'There should be no tag categories.');
    }
    
    @isTest
    static void getTagCategories_oneTagCategory_expectOneTagCategoryFoundTest() {
        Tag_Category__c someTagCategory = TagCategoryTestData.Instance.insertTagCategory();
        
        List<Tag_Category__c> tagCategories = ShoppingCartController.getTagCategories();
        
        system.assertEquals(1, tagCategories.size(), 'There should be one tag category.');
        system.assertEquals(someTagCategory.Id, tagCategories[0].Id, 'The expected tag category was not found.');
    }
    
    @isTest
    static void getMarketingMaterials_noMarketingMaterials_expectNoMarketingMaterialsFoundTest() {
        List<ShoppingCartController.MarketingMaterial> marketingMaterials = ShoppingCartController.getMarketingMaterials();
        
        system.assertEquals(0, marketingMaterials.size(), 'There should be no marketing materials.');
    }
    
    @isTest
    static void getMarketingMaterials_oneMarketingMaterial_expectOneMarketingMaterialFoundTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        List<ShoppingCartController.MarketingMaterial> marketingMaterials = ShoppingCartController.getMarketingMaterials();
        
        system.assertEquals(1, marketingMaterials.size(), 'There should be one marketing material.');
        system.assertEquals(someMaterial.Id, marketingMaterials[0].Record.Id, 'The expected marketing material was not found.');
    }
    
    @isTest
    static void getMarketingMaterials_oneMaterialWithNotDisplayInSearchResults_expectNoMarketingMaterialsFoundTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.withDisplayInSearchResults(false)
                                                                      .insertMarketingMaterial();

        List<ShoppingCartController.MarketingMaterial> marketingMaterials = ShoppingCartController.getMarketingMaterials();
        system.assertEquals(0, marketingMaterials.size(), 'There should be no marketing materials.');
    }
    
    @isTest
    static void getFeaturedMaterials_noFeaturedMaterials_expectNoFeaturedMaterialsFoundTest() {
        List<ShoppingCartController.MarketingMaterial> featuredMaterials =
                ShoppingCartController.getFeaturedMaterials();

        system.assertEquals(0, featuredMaterials.size(), 'No featured materials should be found.');
    }
    
    @isTest
    static void getFeaturedMaterials_oneFeaturedMaterial_expectOneFeaturedMaterialFoundTest() {
        User sysAdminUser = Util.getAnActiveSystemAdministrator();
        
        system.runAs(sysAdminUser) {
	        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.withFeature(true)
	                                                                               .withFeatureHeader('Testing Feature')
	            																   .withFeatureVisibility('System Administrator')
	                                                                               .insertMarketingMaterial();
	
	        List<ShoppingCartController.MarketingMaterial> featuredMaterials =
	                ShoppingCartController.getFeaturedMaterials();
	
	        system.assertEquals(1, featuredMaterials.size(), 'One featured material should be found.');
	        system.assertEquals(someMaterial.Id, featuredMaterials[0].Record.Id, 'The featured material was not found.');
        }
    }
    
    @isTest
    static void getOrderForHistoryDetail_noOrderId_expectBlankOrderHistoryDetailTest() {
        ShoppingCartController.OrderHistoryDetail orderDetail =
                ShoppingCartController.getOrderForHistoryDetail(null);

        system.assert(orderDetail != null, 'The order detail is null.');
        system.assertEquals(null, orderDetail.Order, 'The order should be null.');
        system.assertEquals(0, orderDetail.OrderLineItems.size(), 'There should be no order line items.');
    }
    
    @isTest
    static void getOrderForHistoryDetail_orderWithOneOrderLine_expectOrderFoundTest() {
        Marketing_Material__c customMaterial = MarketingMaterialTestData.Instance.withCustomizationType('Combo_Brochure')
                                                                                 .insertMarketingMaterial();

        Order__c order = OrderTestData.Instance.insertOrder();
        
        Order_Line_Item__c customOLI = OrderLineItemTestData.Instance.withOrder(order.Id)
                                                                     .withMarketingMaterial(customMaterial.Id)
                                                                     .insertOrderLineItem();

        ShoppingCartController.OrderHistoryDetail orderDetail =
                ShoppingCartController.getOrderForHistoryDetail(order.Id);

        system.assert(orderDetail != null, 'The order detail is null.');
        system.assert(orderDetail.Order != null, 'The order record should not be null.');
        system.assertEquals(1, orderDetail.OrderLineItems.size(), 'There should be one order line item.');
    }
    
    @isTest
    static void getCart_noCart_expectBlankCartInformationTest() {
        ShoppingCartController.CartInformation cartInfo =
                ShoppingCartController.getCart(true);

        system.assert(cartInfo != null, 'The cart info is null.');
        system.assertEquals(null, cartInfo.Order, 'The order should be null.');
        system.assertEquals(0, cartInfo.OrderLineItems.size(), 'There should be no order line items.');
    }
    
    @isTest
    static void getCart_cartWithOneOrderLine_expectCartFoundTest() {
        Marketing_Material__c customMaterial = MarketingMaterialTestData.Instance.withCustomizationType('Combo_Brochure')
                                                                                 .insertMarketingMaterial();

        Order__c cart = OrderTestData.Instance.insertCartOrder();
        
        Order_Line_Item__c customOLI = OrderLineItemTestData.Instance.withOrder(cart.Id)
                                                                     .withMarketingMaterial(customMaterial.Id)
                                                                     .insertOrderLineItem();

        ShoppingCartController.CartInformation cartInfo =
                ShoppingCartController.getCart(true);

        system.assert(cartInfo != null, 'The cart info is null.');
        system.assert(cartInfo.Order != null, 'The order record should not be null.');
        system.assertEquals(1, cartInfo.OrderLineItems.size(), 'There should be one order line item.');
    }
    
    @isTest
    static void submitOrder_CartGiven_expectOrderSubmittedTest() {
        Order__c cart = OrderTestData.Instance.insertCartOrder();

        ShoppingCartController.submitOrder(cart.Id);
        
        ShoppingCartController.OrderHistoryDetail orderDetail =
                ShoppingCartController.getOrderForHistoryDetail(cart.Id);

        Order__c queriedOrder = orderDetail.Order;

        system.assertEquals(ShoppingCartController.ORDER_STATUS_SUBMITTED, queriedOrder.Status__c, 'The order was not submitted.');
        system.assert(queriedOrder.Date_Submitted__c != null, 'The submitted date should not be blank.');
    }
    
    @isTest
    static void deleteOrder_orderToDeleteGiven_expectOrderDeletedTest() {
        Order__c cart = OrderTestData.Instance.insertCartOrder();

        ShoppingCartController.deleteOrder(cart.Id);

        ShoppingCartController.OrderHistoryDetail orderDetail =
                ShoppingCartController.getOrderForHistoryDetail(cart.Id);

        Order__c queriedOrder = orderDetail.Order;

        system.assertEquals(null, queriedOrder, 'The order was not deleted.');
    }
    
    @isTest
    static void addMarketingMaterialToCart_marketingMaterialGivenWithOneToPurchase_expectOrderLineItemCreatedTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        Decimal quantityToUse = 1;
        
        ShoppingCartController.CartInformation cart =
                ShoppingCartController.addMarketingMaterialToCart(someMaterial, quantityToUse, new Map<String, Object>());

        system.assert(cart.Order != null, 'The cart was not inserted.');
        system.assertEquals(1, cart.OrderLineItems.size(), 'The marketing material was not purchased.');
        
        ShoppingCartController.OrderLine orderLine = cart.OrderLineItems[0];
        Order_Line_Item__c oli = orderLine.Record;
        
        system.assertEquals(quantityToUse, oli.Quantity__c, 'The quantity to purchase was not used.');
        system.assertEquals(someMaterial.Id, oli.Marketing_Material__c, 'The desired marketing material was not used.');
    }

    @isTest
    static void addMarketingMaterialToCart_marketingMaterialGivenWithExistingCart_expectOrderLineItemAddedToExistingCartTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        Order__c existingCart = OrderTestData.Instance.insertCartOrder();
        
        Decimal quantityToUse = 10;
        
        ShoppingCartController.CartInformation cart =
                ShoppingCartController.addMarketingMaterialToCart(someMaterial, quantityToUse, new Map<String, Object>());

        system.assert(cart.Order != null, 'The cart was not inserted.');
        system.assertEquals(1, cart.OrderLineItems.size(), 'The marketing material was not purchased.');
        
        ShoppingCartController.OrderLine orderLine = cart.OrderLineItems[0];
        Order_Line_Item__c oli = orderLine.Record;
        
        system.assertEquals(quantityToUse, oli.Quantity__c, 'The quantity to purchase was not used.');
        system.assertEquals(someMaterial.Id, oli.Marketing_Material__c, 'The desired marketing material was not used.');
        system.assertEquals(existingCart.Id, oli.Order__c, 'The order line item was not added to the existing cart.');
    }
    
    @isTest
    static void saveOrder_orderLineItemQuantityUpdated_expectQuantityUpdatedTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();

        Order__c cart = OrderTestData.Instance.insertCartOrder();
        
        Order_Line_Item__c customOLI = OrderLineItemTestData.Instance.withOrder(cart.Id)
                                                                     .withMarketingMaterial(someMaterial.Id)
                                                                     .insertOrderLineItem();

        customOLI.Quantity__c = 45;

        List<Order_Line_Item__c> orderLinesItemsToSave = new List<Order_Line_Item__c>{ customOLI };
        String olisJSON = JSON.serialize(orderLinesItemsToSave);
        
        ShoppingCartController.saveOrder(olisJSON, cart);
        
        ShoppingCartController.CartInformation cartInfo =
                ShoppingCartController.getCart(false);

        system.assertEquals(1, cartInfo.OrderLineItems.size(), 'There should be one order line item.');
        system.assertEquals(customOLI.Quantity__c, cartInfo.OrderLineItems[0].Record.Quantity__c, 'The order line item\'s quantity was not updated.');
    }
    
    @isTest
    static void saveOrderOnChange_orderNameChanged_expectOrderNameUpdatedTest() {
        Order__c cart = OrderTestData.Instance.insertCartOrder();
        
        cart.Order_Name__c = 'Some Awesome Order';
        
        ShoppingCartController.saveOrderOnChange(cart);
        
        ShoppingCartController.CartInformation cartInfo =
                ShoppingCartController.getCart(false);

        system.assert(cartInfo.Order != null, 'The cart was not found.');
        system.assertEquals(cart.Order_Name__c, cartInfo.Order.Order_Name__c, 'The order name was not updated.');
    }
    
    @isTest
    static void saveOrderOnChange_UserShippingFieldsChanged_expectUserShippingFieldsUpdatedTest() {
        Order__c cart = OrderTestData.Instance.withShipTo('Me').insertCartOrder();
        
        cart.Shipping_Street__c = '123 Test';
        
        ShoppingCartController.saveOrderOnChange(cart);
        
        User u = [SELECT Street FROM User WHERE Id =: UserInfo.getUserId()];
        
        system.assertEquals(cart.Shipping_Street__c, u.Street, 'The logged in user street was not updated.');
    }
    
    @isTest
    static void duplicateLineItem_duplicateItemRequested_expectDuplicateOrderLineItemAddedTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        Order__c existingCart = OrderTestData.Instance.insertCartOrder();
        
        Order_Line_Item__c lineItem = OrderLineItemTestData.Instance
            											   .withMarketingMaterial(someMaterial.Id)
            											   .withOrder(existingCart.Id)
            											   .withQuantity(10)
            											   .insertOrderLineItem();
        
        List<Order_Line_Item__c> lineItems = new List<Order_Line_Item__c>();
        lineItems.add(lineItem);
        
        String OrderLineItems = JSON.serialize(lineItems, true);
        
        Decimal quantityToUse = 10;
        
        ShoppingCartController.CartInformation cart =
                ShoppingCartController.duplicateLineItem(someMaterial.Id, quantityToUse, existingCart.Id, OrderLineItems);

        system.assertEquals(2, cart.OrderLineItems.size(), 'The order line item was not duplicated.');
        
        ShoppingCartController.OrderLine orderLine = cart.OrderLineItems[0];
        Order_Line_Item__c oli = orderLine.Record;
        
        system.assertEquals(quantityToUse, oli.Quantity__c, 'The quantity to purchase was not used.');
        system.assertEquals(someMaterial.Id, oli.Marketing_Material__c, 'The desired marketing material was not used.');
        system.assertEquals(existingCart.Id, oli.Order__c, 'The order line item was not added to the existing cart.');
    }
    
    @isTest
    static void removeLineItemFromOrder_orderLineItemToDeleteGiven_expectOrderLineItemDeletedTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();

        Order__c cart = OrderTestData.Instance.insertCartOrder();

        Order_Line_Item__c oliToRemove = OrderLineItemTestData.Instance.withOrder(cart.Id)
                                                                       .withMarketingMaterial(someMaterial.Id)
                                                                       .insertOrderLineItem();

        ShoppingCartController.removeLineItemFromOrder(oliToRemove.Id);

        ShoppingCartController.CartInformation cartInfo =
                ShoppingCartController.getCart(false);

        system.assertEquals(0, cartInfo.OrderLineItems.size(), 'The order line item was not deleted.');
    }
    
    @isTest
    static void addUserFavorite_marketingMaterialFavorited_expectFavoriteRecordCreatedTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        ShoppingCartController.addUserFavorite(someMaterial.Id);
        
        Set<Id> userFavoriteIds = ShoppingCartController.getUserFavorites();
        
        system.assert(userFavoriteIds.contains(someMaterial.Id), 'The marketing material was not favorited.');
    }
    
    @isTest
    static void addUserFavorite_marketingMaterialFavoritedAgain_expectOnlyOneRecordCreatedTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        ShoppingCartController.addUserFavorite(someMaterial.Id);
        
        Set<Id> userFavoriteIds = ShoppingCartController.getUserFavorites();
        
        system.assert(userFavoriteIds.contains(someMaterial.Id), 'The marketing material was not favorited.');

        ShoppingCartController.addUserFavorite(someMaterial.Id);
        
        userFavoriteIds = ShoppingCartController.getUserFavorites();
        
        system.assertEquals(1, userFavoriteIds.size(), 'A second favorites record was added when it should not have been.');
    }
    
    @isTest
    static void removeUserFavorite_marketingMaterialUnfavorited_expectFavoriteRecordRemovedTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();

        ShoppingCartController.addUserFavorite(someMaterial.Id);

        ShoppingCartController.removeUserFavorite(someMaterial.Id);
        
        Set<Id> userFavoriteIds = ShoppingCartController.getUserFavorites();
        
        system.assert(userFavoriteIds.contains(someMaterial.Id) == false, 'The marketing material was not unfavorited.');
    }
    
    @isTest
    static void getMarketingMaterials_oneMarketingMaterialFavorited_expectItsIsFavoriteIsTrueTest() {
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();

        ShoppingCartController.addUserFavorite(someMaterial.Id);

        List<ShoppingCartController.MarketingMaterial> materials = ShoppingCartController.getMarketingMaterials();
        
        system.assertEquals(1, materials.size(), 'There should only be one marketing material.');
        system.assertEquals(true, materials[0].IsFavorite, 'The marketing material should be favorited.');
    }
    
    @isTest
    static void updateLineItemsFromLookUps_accountLookupChanged_expectLatestAccountInfoCopiedToOrderLineItemTest() {
        Account newAccount = AccountTestData.Instance.withMarketingAccountName('Market Name A')
                                                     .withIndustry('Education')
                                                     .insertAccount();

        Order__c someOrder = OrderTestData.Instance.insertOrder();
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
                                                                   .withOrder(someOrder.Id)
                                                                   .insertOrderLineItem();

        someOLI.Account__c = newAccount.Id;
        
        String lineItemsStringify = JSON.serialize(new List<Order_Line_Item__c>{ someOLI });
        
        ShoppingCartController.updateLineItemsFromLookUps(lineItemsStringify);
        
        Order_Line_Item__c oliQueried = getOrderLineItemById(someOLI.Id);

        system.assertEquals(newAccount.Industry, oliQueried.Industry__c, 'The industry was not copied to the order line item.');
        system.assertEquals(newAccount.Marketing_Account_Name__c, oliQueried.Marketing_Account_Name__c, 'The marketing account name was not copied to the order line item.');
    }

    @isTest
    static void updateLineItemsFromLookUps_opportunityLookupChanged_expectLatestOpportunityInfoCopiedToOrderLineItemTest() {
        Account newAccount = AccountTestData.Instance.insertAccount();
        Opportunity enrollmentOpp = OpportunityTestData.Instance.withEnrollmentStartDate(Date.Today().addDays(25))
                                                                .withEnrollmentEndDate(Date.Today().addDays(105))
                                                                .insertAFESOpportunity();

        Order__c someOrder = OrderTestData.Instance.insertOrder();
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
                                                                   .withOrder(someOrder.Id)
                                                                   .insertOrderLineItem();

        someOLI.Opportunity__c = enrollmentOpp.Id;
        
        String lineItemsStringify = JSON.serialize(new List<Order_Line_Item__c>{ someOLI });
        
        ShoppingCartController.updateLineItemsFromLookUps(lineItemsStringify);
        
        Order_Line_Item__c oliQueried = getOrderLineItemById(someOLI.Id);

        system.assertEquals(enrollmentOpp.Enrollment_Start_Date__c, oliQueried.Enrollment_Start_Date__c, 'The enrollment start date was not copied to the order line item.');
        system.assertEquals(enrollmentOpp.Enrollment_End_Date__c, oliQueried.Enrollment_End_Date__c, 'The enrollment end date was not copied to the order line item.');
    }

    @isTest
    static void updateLineItemsFromLookUps_colleagueLookupChanged_expectLatestColleagueInfoCopiedToOrderLineItemTest() {
        Order__c someOrder = OrderTestData.Instance.insertOrder();
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
                                                                   .withOrder(someOrder.Id)
                                                                   .insertOrderLineItem();

        someOLI.Colleague__c = UserInfo.getUserId();
        
        String lineItemsStringify = JSON.serialize(new List<Order_Line_Item__c>{ someOLI });
        
        ShoppingCartController.updateLineItemsFromLookUps(lineItemsStringify);
        
        Order_Line_Item__c oliQueried = getOrderLineItemById(someOLI.Id);
        
        system.assertEquals(UserInfo.getName(), oliQueried.Colleague_Name__c, 'The colleague name was not copied to the order line item.');
    }

    @isTest
    static void updateLineItemsFromLookUps_accountLookupCleared_expectOrderLineItemAccountFieldsClearedTest() {
        Account newAccount = AccountTestData.Instance.withMarketingAccountName('Market Name A')
                                                     .withIndustry('Education')
                                                     .insertAccount();

        Order__c someOrder = OrderTestData.Instance.insertOrder();
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
                                                                   .withOrder(someOrder.Id)
                                                                   .withAccount(newAccount.Id)
                                                                   .withMarketingAccountName(newAccount.Marketing_Account_Name__c)
                                                                   .insertOrderLineItem();

        someOLI.Account__c = null;
        
        String lineItemsStringify = JSON.serialize(new List<Order_Line_Item__c>{ someOLI });
        
        ShoppingCartController.updateLineItemsFromLookUps(lineItemsStringify);
        
        Order_Line_Item__c oliQueried = getOrderLineItemById(someOLI.Id);
        system.assertEquals(null, oliQueried.Marketing_Account_Name__c, 'The marketing account name was not cleared.');
    }

    @isTest
    static void updateLineItemsFromLookUps_opportunityLookupCleared_expectOrderLineItemOpportunityFieldsClearedTest() {
        Account newAccount = AccountTestData.Instance.insertAccount();
        Opportunity enrollmentOpp = OpportunityTestData.Instance.withEnrollmentStartDate(Date.Today().addDays(25))
                                                                .withEnrollmentEndDate(Date.Today().addDays(105))
                                                                .insertAFESOpportunity();

        Order__c someOrder = OrderTestData.Instance.insertOrder();
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
                                                                   .withOrder(someOrder.Id)
                                                                   .withOpportunity(enrollmentOpp.Id)
                                                                   .withEnrollmentStartDate(enrollmentOpp.Enrollment_Start_Date__c)
                                                                   .insertOrderLineItem();

        someOLI.Opportunity__c = null;
        
        String lineItemsStringify = JSON.serialize(new List<Order_Line_Item__c>{ someOLI });
        
        ShoppingCartController.updateLineItemsFromLookUps(lineItemsStringify);
        
        Order_Line_Item__c oliQueried = getOrderLineItemById(someOLI.Id);

        system.assertEquals(null, oliQueried.Enrollment_Start_Date__c, 'The enrollment start date was not cleared.');
        system.assertEquals(null, oliQueried.Enrollment_End_Date__c, 'The enrollment end date was not cleared.');
    }

    @isTest
    static void updateLineItemsFromLookUps_colleagueLookupCleared_expectOrderLineItemColleagueFieldsClearedTest() {
        Order__c someOrder = OrderTestData.Instance.insertOrder();
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
                                                                   .withOrder(someOrder.Id)
                                                                   .withColleague(UserInfo.getUserId())
                                                                   .withColleagueName(UserInfo.getName())
                                                                   .insertOrderLineItem();

        someOLI.Colleague__c = null;
        
        String lineItemsStringify = JSON.serialize(new List<Order_Line_Item__c>{ someOLI });
        
        ShoppingCartController.updateLineItemsFromLookUps(lineItemsStringify);
        
        Order_Line_Item__c oliQueried = getOrderLineItemById(someOLI.Id);
        
        system.assertEquals(null, oliQueried.Colleague_Name__c, 'The colleague name was not cleared.');
    }
    
    @isTest
    static void ReOrderFromHistory_noCurrentCart_expectOrderCreatedWithLineItemsAdded() {
        Order__c someOrder = orderTestData.Instance.insertOrder();
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.withProcessingType('Download Only').insertMarketingMaterial();
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
            													   .withOrder(someOrder.Id)
            													   .insertOrderLineItem();
        
        ShoppingCartController.submitOrder(someOrder.Id);
        
        Boolean allItemsAdded = ShoppingCartController.ReOrderFromHistory(someOrder.Id);
        Order__c newOrder = ShoppingCartController.getCartForCurrentUser();
        List<Order_Line_Item__c> lineItems = [SELECT Id FROM Order_Line_Item__c WHERE Order__c =: newOrder.Id];
        
        system.assert(allItemsAdded, 'The order lines were not added');
        system.assertNotEquals(someOrder.Id, newOrder.Id, 'A new order was not created');
        system.assertEquals(1, lineItems.size(), 'Only one line item should be added to the new order');
    }
    
    @isTest
    static void ReOrderFromHistory_hasCurrentCart_expectOrderUpdatedWithLineItemsAdded() {
        Order__c someOrder = orderTestData.Instance.insertOrder();
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.withProcessingType('Download Only').insertMarketingMaterial();
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
            													   .withOrder(someOrder.Id)
            													   .insertOrderLineItem();
        
        Boolean allItemsAdded = ShoppingCartController.ReOrderFromHistory(someOrder.Id);
        Order__c newOrder = ShoppingCartController.getCartForCurrentUser();
        List<Order_Line_Item__c> addedLineItems = [SELECT Id FROM Order_Line_Item__c WHERE Order__c =: newOrder.Id];
        
        system.assert(allItemsAdded, 'The order lines were not added');
        system.assertEquals(2, addedLineItems.size(), 'Order line was not added to the current order');
        system.assertEquals(someOrder.Id, newOrder.Id, 'An order was created when it should not have been');
    }
    
    @isTest
    static void ReOrderFromHistory_inactiveMaterial_expectLineItemsNotAdded() {
        Order__c someOrder = orderTestData.Instance.insertOrder();
        Marketing_Material__c someMaterial = MarketingMaterialTestData.Instance.withStatus('Inactive').insertMarketingMaterial();
        Order_Line_Item__c someOLI = OrderLineItemTestData.Instance.withMarketingMaterial(someMaterial.Id)
            													   .withOrder(someOrder.Id)
            													   .insertOrderLineItem();
        
        Boolean allItemsAdded = ShoppingCartController.ReOrderFromHistory(someOrder.Id);
        List<Order_Line_Item__c> lineItems = [SELECT Id FROM Order_Line_Item__c WHERE Order__c =: someOrder.Id];
        
        system.assertEquals(1, lineItems.size(), 'There should only be 1 line item instead of 2 because material is inactive');
        system.assert(!AllItemsAdded, 'The Inactive order lines were added');
    }
    
    @isTest
    static void ReOrderFromHistory_nullOrderId_expectException() {
        try
        {
            Boolean allItemsAdded = ShoppingCartController.ReOrderFromHistory(null);
            system.assert(false, 'An error should have been thrown');
        }
        catch(AuraHandledException e)
        {
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void getEnrollmentOpportunityInformation_enrollmentOpportunityWithEnrollmentPath_expectOpportunityInformationPopulatedTest() {
        Enrollment_Path__c limitedEnrollmentPath = EnrollmentPathTestData.Instance.insertEnrollmentPath();
        Opportunity enrollmentOpp = OpportunityTestData.Instance.withEnrollmentPath(limitedEnrollmentPath.Id)
                                                                .withEnrollmentStartDate(Date.Today().addDays(10))
                                                                .withEnrollmentEndDate(Date.Today().addDays(20))
                                                                .insertAFESOpportunity();

        ShoppingCartController.OpportunityInformation oppInfo = ShoppingCartController.getEnrollmentOpportunityInformation(enrollmentOpp.Id);
        
        system.assert(oppInfo != null, 'The opportunity info is null.');
        system.assert(oppInfo.EnrollmentOpportunity != null, 'The enrollment Opportunity is null.');
        system.assertEquals(enrollmentOpp.Id, oppInfo.EnrollmentOpportunity.Id, 'The enrollment Opportunity is not the given one.');
    }
    
    @isTest
    static void getPreenrollmentMaterials_activePreenrollmentMaterialsExist_expectPreenrollmentMaterialsFoundTest() {
        Marketing_Material__c preenrollmentMaterial = MarketingMaterialTestData.Instance.usePreenrollmentMarketingDefaults()
                                                                                        .insertMarketingMaterial();

        List<ShoppingCartController.MarketingMaterial> preenrollmentMaterials =
            ShoppingCartController.getPreenrollmentMaterials();

        system.assert(preenrollmentMaterials != null, 'The preenrollment materials is null.');
        system.assertEquals(1, preenrollmentMaterials.size(), 'There should be one preenrollment material.');
        system.assertEquals(preenrollmentMaterial.Id, preenrollmentMaterials[0].Record.Id, 'The expected preenrollment material was not found.');
    }
    
    @isTest
    static void getAccountEnrollmentSites_accountHasNoEnrollmentSites_expectNoEnrollmentSitesTest() {
        Account noEnrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        List<ShoppingCartController.EnrollmentSite> enrollmentSites =
            ShoppingCartController.getAccountEnrollmentSites(noEnrollmentSitesAccount.Id, null);

        system.assert(enrollmentSites != null, 'The enrollment sites is null.');
        system.assertEquals(0, enrollmentSites.size(), 'There should be no enrollment sites found.');
    }
    
    @isTest
    static void getAccountEnrollmentSites_accountHasEnrollmentSites_expectEnrollmentSitesTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();
        
        List<ShoppingCartController.EnrollmentSite> enrollmentSites =
            ShoppingCartController.getAccountEnrollmentSites(enrollmentSitesAccount.Id, null);

        system.assert(enrollmentSites != null, 'The enrollment sites is null.');
        system.assertEquals(1, enrollmentSites.size(), 'There should be one enrollment site found.');
    }
    
    @isTest
    static void addNewEnrollmentSite_newEnrollmentSiteGiven_expectEnrollmentSiteInsertedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .create();

        Id newEnrollmentSiteId = ShoppingCartController.addNewEnrollmentSite(enrollmentSite);
        
        system.assert(newEnrollmentSiteId != null, 'The enrollment site was not inserted.');
    }

    @isTest
    static void addNewEnrollmentSiteDate_newEnrollmentSiteDateGiven_expectEnrollmentSiteDateInsertedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();

        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Enrollment_Site_Date__c enrollmentSiteDate = EnrollmentSiteDateTestData.Instance.withEnrollmentSite(enrollmentSite.Id)
                                                                                        .withEnrollmentOpportunity(enrollmentOpp.Id)
                                                                                        .create();

        Id newEnrollmentSiteDateId = ShoppingCartController.addNewEnrollmentSiteDate(enrollmentSiteDate);
        
        system.assert(newEnrollmentSiteDateId != null, 'The enrollment site date was not inserted.');
    }

    @isTest
    static void updateEnrollmentSiteDate_enrollmentSiteDateToUpdateGiven_expectEnrollmentSiteDateUpdatedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();

        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Enrollment_Site_Date__c enrollmentSiteDate = EnrollmentSiteDateTestData.Instance.withEnrollmentSite(enrollmentSite.Id)
                                                                                        .withEnrollmentOpportunity(enrollmentOpp.Id)
                                                                                        .insertEnrollmentSiteDate();
                                                                                        
        enrollmentSiteDate.End_Date__c = enrollmentSiteDate.End_Date__c.addDays(10);

        ShoppingCartController.updateEnrollmentSiteDate(enrollmentSiteDate);
        
        Enrollment_Site_Date__c enrollmentSiteDateQueried =
        [SELECT Id,
                End_Date__c
           FROM Enrollment_Site_Date__c
          WHERE Id = :enrollmentSiteDate.Id];
          
        system.assertEquals(enrollmentSiteDate.End_Date__c, enrollmentSiteDateQueried.End_Date__c, 'The end date was not updated.');
    }
    
    @isTest
    static void deleteEnrollmentSiteDate_enrollmentSiteDateToDeleteGiven_expectEnrollmentSiteDateDeletedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();

        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Enrollment_Site_Date__c enrollmentSiteDate = EnrollmentSiteDateTestData.Instance.withEnrollmentSite(enrollmentSite.Id)
                                                                                        .withEnrollmentOpportunity(enrollmentOpp.Id)
                                                                                        .insertEnrollmentSiteDate();
                                                                                        
        ShoppingCartController.deleteEnrollmentSiteDate(enrollmentSiteDate.Id);
        
        List<Enrollment_Site_Date__c> enrollmentSiteDatesQueried =
        [SELECT Id,
                End_Date__c
           FROM Enrollment_Site_Date__c
          WHERE Id = :enrollmentSiteDate.Id];

        system.assertEquals(0, enrollmentSiteDatesQueried.size(), 'The enrollment site date was not deleted.');
    }

    @isTest
    static void addPreenrollmentInfo_plainPreenrollmentMaterialAdded_expectPreenrollmentMaterialOrderLineInsertedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        
        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Marketing_Material__c preenrollmentMaterial = MarketingMaterialTestData.Instance.usePreenrollmentMarketingDefaults()
                                                                                        .insertMarketingMaterial();

        
        Pre_Enrollment_Marketing_Form__c marketingForm = getMarketingFormByOpportunity(enrollmentOpp.Id);

        Id orderId = ShoppingCartController.addPreenrollmentInfo(enrollmentOpp.Id, new List<String> { preenrollmentMaterial.Id }, '', marketingForm.Id, null);
        
        system.assert(orderId != null, 'The preenrollment order was not created.');
        
        List<Order_Line_Item__c> orderLineItems = getOrderLineItemsByOrder(orderId);
        
        system.assertEquals(1, orderLineItems.size(), 'There should be one order line item');
        
        Order_Line_Item__c oli = orderLineItems[0];
        system.assertEquals(enrollmentOpp.Id, oli.Opportunity__c, 'The order line item was not tied to the opportunity.');
        system.assertEquals(marketingForm.Id, oli.Preenrollment_Marketing_Form__c, 'The order line item was not tied to the marketing form.');
    }

    @isTest
    static void addPreenrollmentInfo_plainPreenrollmentMaterialAddedButAlreadyInCart_expectPreenrollmentMaterialOrderLineNotInsertedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        
        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Pre_Enrollment_Marketing_Form__c marketingForm = getMarketingFormByOpportunity(enrollmentOpp.Id);

        Marketing_Material__c preenrollmentMaterial = MarketingMaterialTestData.Instance.usePreenrollmentMarketingDefaults()
                                                                                        .insertMarketingMaterial();

        Order__c order = OrderTestData.Instance.insertOrder();
        
        Order_Line_Item__c customOLI = OrderLineItemTestData.Instance.withOrder(order.Id)
                                                                     .withMarketingMaterial(preenrollmentMaterial.Id)
                                                                     .insertOrderLineItem();        
        

        Id orderId = ShoppingCartController.addPreenrollmentInfo(enrollmentOpp.Id, new List<String> { preenrollmentMaterial.Id }, '', marketingForm.Id, null);
        
        system.assert(orderId != null, 'The preenrollment order was not created.');
        
        List<Order_Line_Item__c> orderLineItems = getOrderLineItemsByOrder(orderId);
        
        system.assertEquals(1, orderLineItems.size(), 'There should be one order line item');
    }

    @isTest
    static void addPreenrollmentInfo_plainPreenrollmentMaterialNotAddedButAlreadyInCart_expectPreenrollmentMaterialOrderLineDeletedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        
        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Marketing_Material__c preenrollmentMaterial = MarketingMaterialTestData.Instance.usePreenrollmentMarketingDefaults()
                                                                                        .insertMarketingMaterial();

        Order__c order = OrderTestData.Instance.insertOrder();
        
        Order_Line_Item__c customOLI = OrderLineItemTestData.Instance.withOrder(order.Id)
                                                                     .withMarketingMaterial(preenrollmentMaterial.Id)
                                                                     .insertOrderLineItem();  

        
        Pre_Enrollment_Marketing_Form__c marketingForm = getMarketingFormByOpportunity(enrollmentOpp.Id);

        Id orderId = ShoppingCartController.addPreenrollmentInfo(enrollmentOpp.Id, new List<String> { }, '', marketingForm.Id, null);
        
        system.assert(orderId != null, 'The preenrollment order was not created.');
        
        List<Order_Line_Item__c> orderLineItems = getOrderLineItemsByOrder(orderId);
        
        system.assertEquals(0, orderLineItems.size(), 'There should be no order line item.');
    }

    @isTest
    static void addPreenrollmentInfo_plainPreenrollmentMaterialAddedAndNoPreenrollmentIdProvided_expectPreenrollmentMaterialOrderLineInsertedAndLinkedToMarketingFormTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        
        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Marketing_Material__c preenrollmentMaterial = MarketingMaterialTestData.Instance.usePreenrollmentMarketingDefaults()
                                                                                        .insertMarketingMaterial();

        
        Id orderId = ShoppingCartController.addPreenrollmentInfo(enrollmentOpp.Id, new List<String> { preenrollmentMaterial.Id }, '', null, null);
        
        system.assert(orderId != null, 'The preenrollment order was not created.');
        
        List<Order_Line_Item__c> orderLineItems = getOrderLineItemsByOrder(orderId);
        
        system.assertEquals(1, orderLineItems.size(), 'There should be one order line item');
        
        Order_Line_Item__c oli = orderLineItems[0];
        system.assertEquals(enrollmentOpp.Id, oli.Opportunity__c, 'The order line item was not tied to the opportunity.');
        system.assert(oli.Preenrollment_Marketing_Form__c != null, 'The order line item was not tied to the marketing form automatically.');
    }
    
    @isTest
    static void updateBenefitsSiteInfo_benefitsSiteInfoJSONBlank_expectNoErrorsTest() {
        String blankBenefitsSiteInfoJSON = '';
        
        Exception errorException = null;
        
        try {
            ShoppingCartController.updateBenefitsSiteInfo(null, blankBenefitsSiteInfoJSON);
        }
        catch(Exception ex) {
            errorException = ex;
        }
        
        system.assertEquals(null, errorException, 'There was an error: ' + errorException);
    }

    @isTest
    static void updateBenefitsSiteInfo_benefitsSiteInfoJSONHasGroupDisplayName_expectGroupDisplayNameUpdatedTest() {
        Opportunity enrollmentOpp = OpportunityTestData.Instance.insertAFESOpportunity();

        Pre_Enrollment_Marketing_Form__c marketingForm = getMarketingFormByOpportunity(enrollmentOpp.Id);
        
        String newGroupDisplayName = 'Some New Account';
        String benefitsSiteJSON = '{ "GroupDisplayName": "' + newGroupDisplayName + '" }';
        
        ShoppingCartController.updateBenefitsSiteInfo(enrollmentOpp.Id, benefitsSiteJSON);

        Opportunity updatedOpp = getOpportunityById(enrollmentOpp.Id);
        
        system.assertEquals(newGroupDisplayName, updatedOpp.Group_Display_Name__c, 'The group display name was not updated.');
    }

    @isTest
    static void updateBenefitsSiteInfo_benefitsSiteInfoJSONHasBranchOffice_expectBranchOfficeUpdatedTest() {
        Opportunity enrollmentOpp = OpportunityTestData.Instance.insertAFESOpportunity();
        
        Branch_Office__c someBranchOffice = BranchOfficeTestData.Instance.insertBranchOffice();
        String benefitsSiteJSON = '{ "BranchOffice": "' + someBranchOffice.Id + '" }';
        
        ShoppingCartController.updateBenefitsSiteInfo(enrollmentOpp.Id, benefitsSiteJSON);

        Opportunity updatedOpp = getOpportunityById(enrollmentOpp.Id);
        
        system.assertEquals(someBranchOffice.Id, updatedOpp.Branch_Office__c, 'The branch office was not updated.');
    }

    @isTest
    static void updateBenefitsSiteInfo_benefitsSiteInfoJSONHasPreenrollmentUpdates_expectMarketingFormUpdatedTest() {
        Opportunity enrollmentOpp = OpportunityTestData.Instance.insertAFESOpportunity();

        Pre_Enrollment_Marketing_Form__c marketingForm = getMarketingFormByOpportunity(enrollmentOpp.Id);
        
        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
        
        String newTitle = 'Executive Account Manager';
        generator.writeStringField('Title', newTitle);
        
        String licenseNumber = 'CA-1234';
        generator.writeStringField('LicenseNumber', licenseNumber);
        
        Boolean showOneOnOneInfo = false;
        generator.writeBooleanField('ShowOneonOneInformation', showOneOnOneInfo);

        Boolean showSelfServiceInformation = true;
        generator.writeBooleanField('ShowSelfServiceInformation', showSelfServiceInformation);
        
        Date openEnrollmentStartDate =Date.Today().addDays(10);
        generator.writeDateField('OpenEnrollmentStartDate', openEnrollmentStartDate);
        
        Date openEnrollmentEndDate = Date.Today().addDays(20);
        generator.writeDateField('OpenEnrollmentEndDate', openEnrollmentEndDate);
        
        generator.writeEndObject();
        
        String benefitsSiteJSON = generator.getAsString();
        
        ShoppingCartController.updateBenefitsSiteInfo(enrollmentOpp.Id, benefitsSiteJSON);

        marketingForm = getMarketingFormByOpportunity(enrollmentOpp.Id);
        
        system.assertEquals(newTitle, marketingForm.Title__c, 'The title was not updated.');
        system.assertEquals(licenseNumber, marketingForm.License_No__c, 'The license number was not updated.');
        system.assertEquals(Boolean.valueOf(showOneOnOneInfo), marketingForm.Show_One_on_One_Information__c, 'The show one on one information was not updated.');
        system.assertEquals(Boolean.valueOf(showSelfServiceInformation), marketingForm.Show_Self_Service_Information__c, 'The show self service information was not updated.');
        system.assertEquals(Date.valueOf(openEnrollmentStartDate), marketingForm.Open_Enrollment_Sart__c, 'The open enrollment start date was not updated.');
        system.assertEquals(Date.valueOf(openEnrollmentEndDate), marketingForm.Open_Enrollment_End__c, 'The open enrollment start date was not updated.');
    }
    
    @isTest
    static void updateBenefitsSiteInfo_benefitsSiteInfoJSONHasImportProduct_expectImportProductUpdatedTest() {
        Opportunity enrollmentOpp = OpportunityTestData.Instance.insertAFESOpportunity();
        Product_Catalog__c importProduct = ProductCatalogTestData.Instance.withType('Import')
                                                                          .insertProductCatalog();

        Enrollment_Form__c ef =
        [SELECT Id
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :enrollmentOpp.Id];


        Marketed_Product__c importMP = MarketedProductTestData.Instance.withProductCatalog(importProduct.Id)
                                                                       .withEnrollmentForm(ef.Id)
                                                                       .withIncludeOnEmployerBenefitsSite(true)
                                                                       .withCarrier('Texas Life')
                                                                       .withCarrierURL('https://texaslife.com')
                                                                       .insertMarketedProduct();
                                                                       

        importMP.Carrier__c += ' Updated';

        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
        
        generator.writeObjectField('ImportProducts', new List<Object>{ importMP });
        
        generator.writeEndObject();
        
        String benefitsSiteJSON = generator.getAsString();
        
        ShoppingCartController.updateBenefitsSiteInfo(enrollmentOpp.Id, benefitsSiteJSON);

        Marketed_Product__c importMPQueried =
        [SELECT Id,
                Carrier__c,
                Carrier_URL__c
           FROM Marketed_Product__c
          WHERE Id = :importMP.Id];

        system.assertEquals(importMP.Carrier__c, importMPQueried.Carrier__c, 'The carrier was not updated.');
    }

    @isTest
    static void updateAccount_accountWithChangesProvided_expectedAccountUpdatedTest() {
        Account accountToUpdate = AccountTestData.Instance.insertAccount();

        accountToUpdate.Name += ' Test';
        ShoppingCartController.updateAccount(accountToUpdate);

        Account queriedAccount =
        [SELECT Id,
                Name
           FROM Account
          WHERE Id = :accountToUpdate.Id];

        system.assertEquals(accountToUpdate.Name, queriedAccount.Name, 'The account was not updated.');
    }

    @isTest
    static void removeEnrollmentSiteDatesFromTimeToEnrollEmail_otherPreenrollmentInfoNullAndOpportunityHasEnrollmentSiteDates_expectEnrollmentSiteDatesUnchangedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();

        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Enrollment_Site_Date__c enrollmentSiteDate = EnrollmentSiteDateTestData.Instance.withEnrollmentSite(enrollmentSite.Id)
                                                                                        .withEnrollmentOpportunity(enrollmentOpp.Id)
                                                                                        .withShowInBuildTimeToEnrollEmail(true)
                                                                                        .insertEnrollmentSiteDate();

        Map<String, Object> nullOtherPreenrollmentInfo = null;

        ShoppingCartController.removeEnrollmentSiteDatesFromTimeToEnrollEmail(nullOtherPreenrollmentInfo, enrollmentOpp.Id);

        Enrollment_Site_Date__c esdQueried = getEnrollmentSiteDateById(enrollmentSiteDate.Id);

        system.assertEquals(true, esdQueried.Show_In_Build_Time_To_Enroll_Email__c, 'The show in build time to enroll email was unchecked when it should not be.');
    }

    @isTest
    static void removeEnrollmentSiteDatesFromTimeToEnrollEmail_otherPreenrollmentInfoHasTrueAddEnrollmentSitesForBuildYourOwnTimeToEnrollEmailAndOpportunityHasEnrollmentSiteDates_expectEnrollmentSiteDatesUnchangedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();

        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Enrollment_Site_Date__c enrollmentSiteDate = EnrollmentSiteDateTestData.Instance.withEnrollmentSite(enrollmentSite.Id)
                                                                                        .withEnrollmentOpportunity(enrollmentOpp.Id)
                                                                                        .withShowInBuildTimeToEnrollEmail(true)
                                                                                        .insertEnrollmentSiteDate();

        Map<String, Object> otherPreenrollmentInfo = new Map<String, Object>();
        otherPreenrollmentInfo.put('addEnrollmentSitesForBuildYourOwnTimeToEnrollEmail', true);

        ShoppingCartController.removeEnrollmentSiteDatesFromTimeToEnrollEmail(otherPreenrollmentInfo, enrollmentOpp.Id);

        Enrollment_Site_Date__c esdQueried = getEnrollmentSiteDateById(enrollmentSiteDate.Id);

        system.assertEquals(true, esdQueried.Show_In_Build_Time_To_Enroll_Email__c, 'The show in build time to enroll email was unchecked when it should not be.');
    }

    @isTest
    static void removeEnrollmentSiteDatesFromTimeToEnrollEmail_otherPreenrollmentInfoHasFalseAddEnrollmentSitesForBuildYourOwnTimeToEnrollEmailAndOpportunityHasEnrollmentSiteDates_expectEnrollmentSiteDatesUnchangedTest() {
        Account enrollmentSitesAccount = AccountTestData.Instance.insertCustomerAccount();
        
        Enrollment_Site__c enrollmentSite = EnrollmentSiteTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                           .insertEnrollmentSite();

        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAccount(enrollmentSitesAccount.Id)
                                                                .insertAFESOpportunity();

        Enrollment_Site_Date__c enrollmentSiteDate = EnrollmentSiteDateTestData.Instance.withEnrollmentSite(enrollmentSite.Id)
                                                                                        .withEnrollmentOpportunity(enrollmentOpp.Id)
                                                                                        .withShowInBuildTimeToEnrollEmail(true)
                                                                                        .insertEnrollmentSiteDate();

        Map<String, Object> otherPreenrollmentInfo = new Map<String, Object>();
        otherPreenrollmentInfo.put('addEnrollmentSitesForBuildYourOwnTimeToEnrollEmail', false);

        ShoppingCartController.removeEnrollmentSiteDatesFromTimeToEnrollEmail(otherPreenrollmentInfo, enrollmentOpp.Id);

        Enrollment_Site_Date__c esdQueried = getEnrollmentSiteDateById(enrollmentSiteDate.Id);

        system.assertEquals(false, esdQueried.Show_In_Build_Time_To_Enroll_Email__c, 'The show in build time to enroll email was checked when it should not be.');
    }
    
    static void assertOrderWithNoDownloadableOrderLines(ShoppingCartController.OrderConfirmation confirmation) {
        system.assert(confirmation != null, 'The confirmation is null.');
        system.assert(confirmation.Order != null, 'The order is null.');
        system.assertEquals(0, confirmation.DownloadableOrderLines.size(), 'There should be no downloadable order lines');
        system.assert(String.isBlank(confirmation.DownloadAllURL), 'There should not be a download all url.');
    }

    static void assertOrderWithDownloadableOrderLines(ShoppingCartController.OrderConfirmation confirmation, List<String> expectedDownloadDocumentIds) {
        system.assert(confirmation != null, 'The confirmation is null.');
        system.assert(confirmation.Order != null, 'The order is null.');
        system.assertEquals(expectedDownloadDocumentIds.size(), confirmation.DownloadableOrderLines.size(), 'There should be ' + expectedDownloadDocumentIds.size() + ' downloadable order line(s)');
        system.assert(String.isNotBlank(confirmation.DownloadAllURL), 'There should be a download all url.');
        
        for (String expectedDownloadDocumentId : expectedDownloadDocumentIds) {
            system.assert(confirmation.DownloadAllURL.containsIgnoreCase(expectedDownloadDocumentId),
                          'The downloadable all url does not contain the downloadable document id.');
        }
    }
    
    static Order_Line_Item__c getOrderLineItemById(Id orderLineItemId) {
        return
        [SELECT Id,
                Name,
                Marketing_Account_Name__c,
                Industry__c,
                Enrollment_Start_Date__c,
                Enrollment_End_Date__c,
                Colleague_Name__c
           FROM Order_Line_Item__c
          WHERE Id = :orderLineItemId];
    }
    
    static Pre_Enrollment_Marketing_Form__c getMarketingFormByOpportunity(Id opportunityId) {
        return
        [SELECT Id,
                Name,
                Title__c,
                License_No__c,
                Show_One_on_One_Information__c,
                Show_Self_Service_Information__c,
                Open_Enrollment_Sart__c,
                Open_Enrollment_End__c
           FROM Pre_Enrollment_Marketing_Form__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :opportunityId];
    }
    
    static List<Order_Line_Item__c> getOrderLineItemsByOrder(Id orderId) {
        return
        [SELECT Id,
                Name,
                Opportunity__c,
                Preenrollment_Marketing_Form__c
           FROM Order_Line_Item__c
          WHERE Order__c = :orderId];
    }
    
    static Opportunity getOpportunityById(Id opportunityId) {
        return
        [SELECT Id,
                Name,
                Group_Display_Name__c,
                Branch_Office__c
           FROM Opportunity
          WHERE Id = :opportunityId];
    }

    static Enrollment_Site_Date__c getEnrollmentSiteDateById(Id enrollmentSiteDateId) {
        return
        [SELECT Id,
                Name,
                Start_Date__c,
                End_Date__c,
                Show_In_Build_Time_To_Enroll_Email__c
           FROM Enrollment_Site_Date__c
          WHERE Id = :enrollmentSiteDateId];
    }
}