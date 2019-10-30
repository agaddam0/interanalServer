public with sharing class ShoppingCartController {
    public static final String ORDER_STATUS_SUBMITTED = 'Submitted';
    
    @AuraEnabled
    public static List<Tag_Category__c> getTagCategories()
    {
        List<Tag_Category__c> tagCats = [SELECT Name, Display_Order__c, 
                                         (SELECT Name, Status__c 
                                          FROM Tags__r WHERE Display_in_Search_Navigation__c = true
                                          ORDER BY Name) 
                                         FROM Tag_Category__c 
                                         WHERE Display_in_Search_Navigation__c = true 
                                         Order By Display_Order__c, Name];
        
        return tagCats;
    }
    
    @AuraEnabled
    public static List<MarketingMaterial> getMarketingMaterials()
    {
        List<MarketingMaterial> marketingMaterials = new List<MarketingMaterial>();
        
        String soql = util.getCreatableFields('Marketing_Material__c');
        
        soql += ', (SELECT Name, Tag__c, Tag__r.Name FROM Marketing_Material_Tags__r Order By Tag__r.Name)';
        soql += ' FROM Marketing_Material__c';
        soql += ' WHERE Display_in_Search_Results__c = true';
        soql += ' AND Status__c = \'Active\'';
        soql += ' ORDER By Title__c';
        
        List<Marketing_Material__c> materials = Database.query(soql);
        
        Set<Id> faves = getUserFavorites();
        
        for(Marketing_Material__c material : materials)
        {
            MarketingMaterial wMaterial = new MarketingMaterial();
            wMaterial.Record = material;
            wMaterial.IsFavorite = faves.contains(material.Id);
            
            marketingMaterials.add(wMaterial);
        }
        
        system.debug(materials);
        
        return marketingMaterials;
    }
    
    public static Set<Id> getUserFavorites() 
    {
        Set<Id> faveIds = new Set<Id>();
        List<Favorites__c> faves = [SELECT Id, User__c, Marketing_Material__c FROM Favorites__c 
                                    WHERE User__c =: system.UserInfo.getUserId()];
        
        for(Favorites__c fave : faves)
        {
            faveIds.add(fave.Marketing_Material__c);
        }
        
        return faveIds;
    }
    
    @AuraEnabled
    public static void addUserFavorite(String materialId)
    {
        // Check to see if the favorite already exists.  Don't add if it does.
        // Result of a weird bug with them getting added multiple times.
        
        List<Favorites__c> existingFaves = [SELECT Id FROM Favorites__c 
                                            WHERE Marketing_Material__c =: materialId 
                                            AND User__c =: system.UserInfo.getUserId()];
        
        if (existingFaves.isEmpty()) 
        {
            Favorites__c newFave = new Favorites__c();
            newFave.Marketing_Material__c = materialId;
            newFave.User__c = system.UserInfo.getUserId();
            insert newFave;
        }        
    }
    
    @AuraEnabled
    public static void removeUserFavorite(String materialId)
    {
        // Changed to list because it will fail should more than 1 come back
        List<Favorites__c> deleteFave = [SELECT Id FROM Favorites__c 
                                         WHERE User__c =: system.UserInfo.getUserId() 
                                         AND Marketing_Material__c =: materialId];
        
        delete deleteFave;
    }
    
    @AuraEnabled
    public static List<MarketingMaterial> getFeaturedMaterials()
    {
        List<MarketingMaterial> featuredItems = new List<MarketingMaterial>();
        Profile p = [Select Name from Profile where Id =: UserInfo.getProfileId()];
        
        String soql = util.getCreatableFields('Marketing_Material__c');
        
        soql += ', (SELECT Name, Tag__c, Tag__r.Name FROM Marketing_Material_Tags__r Order By Tag__r.Name)';
        soql += ' FROM Marketing_Material__c';
        soql += ' WHERE Feature__c = true';
        soql += ' AND Status__c = \'Active\'';
        soql += ' AND Feature_Visibility__c INCLUDES (\'' + p.Name + '\')';
        soql += ' ORDER By LastModifiedDate Desc';
        
        Integer numberOfFeaturedItemsLimit = 3;
        
        String numberOfFeaturedItemsSettings = Label.Shopping_Cart_Number_of_Featured_Items;
        
        if (String.isNotBlank(numberOfFeaturedItemsSettings)) {
            numberOfFeaturedItemsLimit = Integer.valueOf(numberOfFeaturedItemsSettings);
        }
        
        soql += ' Limit ' + numberOfFeaturedItemsLimit;
        
        List<Marketing_Material__c> featuredMarketingMaterials = Database.query(soql);
        
        Set<Id> faves = getUserFavorites();
        
        for (Marketing_Material__c featuredMarketingMaterial : featuredMarketingMaterials) {
            MarketingMaterial featuredItem = new MarketingMaterial();
            featuredItem.Record = featuredMarketingMaterial;
            featuredItem.IsFavorite = faves.contains(featuredMarketingMaterial.Id);
            
            featuredItems.add(featuredItem);
        }
        
        system.debug(featuredItems);
        
        return featuredItems;
    }

    @AuraEnabled
    public static OrderConfirmation getOrderForConfirmation(Id orderId) {
        OrderConfirmation confirmation = new OrderConfirmation();
        
        Order__c order =
        [SELECT Id,
                Name,
                (SELECT Id,
                        Name,
                        Marketing_Material__c,
                        Marketing_Material__r.Title__c,
                        Marketing_Material__r.Material_Number__c,
                        Marketing_Material__r.Thumbnail_URL__c,
                        Marketing_Material__r.Download_URL__c,
                        Marketing_Material__r.Material_Type__c,
                        Marketing_Material__r.Quantity_Maximum__c,
                        Marketing_Material__r.Quantity_Minimum__c,
                        Marketing_Material__r.Email_To_Build__c,
                        Marketing_Material__r.Website_Type__c,
                        Opportunity__c,
                        Opportunity__r.AccountId
                   FROM Order_Line_Items__r
                 ORDER BY Marketing_Material__r.Title__c)
           FROM Order__c
          WHERE Id = :orderId];

        confirmation.Order = order;
        confirmation.DownloadableOrderLines = getDownloadableOrderLinesByOrderId(orderId);
        confirmation.loadDownloadAllURL();

        return confirmation;
    }
    
    @AuraEnabled
    public static OrderHistoryDetail getOrderForHistoryDetail(Id orderId) {
        OrderHistoryDetail detail = new OrderHistoryDetail( getOrderById(orderId) );
        detail.SalesOffice = getSalesoffice(detail.Order);

        return detail;
    }
    
    @AuraEnabled
    public static CartInformation getCart(Boolean firstLoad) {
        CartInformation cartInfo = new CartInformation(getCartForCurrentUser());
        cartInfo.SalesOffice = getSalesoffice(cartInfo.Order);
        
        if(firstLoad && cartInfo != null)
        {
            if(cartInfo.Order.Requested_Delivery_Date__c < system.today().addDays(5))
            {
                cartInfo.Order.Requested_Delivery_Date__c = system.today().addDays(10);
                update cartInfo.Order;
            }
                
        }

        return cartInfo;
    }
    
    @AuraEnabled
    public static void submitOrder(Id orderId) {
        Order__c orderToSubmit = new Order__c(Id = orderId);

        orderToSubmit.Status__c = ORDER_STATUS_SUBMITTED;
        orderToSubmit.Date_Submitted__c = system.now();

        update orderToSubmit;
    }
    
    @AuraEnabled
    public static void deleteOrder(Id orderId) {
        delete new Order__c(Id = orderId);
    }
    
    @AuraEnabled
    public static CartInformation addMarketingMaterialToCart(Marketing_Material__c marketingMaterial, decimal quantity, Map<String, Object> customOrderLineFields)
    {
        CartInformation cartInfo = getCurrentCartOrCreateOne();
        
        addMaterialToOrder(cartInfo.Order, marketingMaterial, quantity, customOrderLineFields);
        
        return getCart(false);
    }
    
    @AuraEnabled
    public static OpportunityInformation getEnrollmentOpportunityInformation(Id enrollmentOpportunityId) {
        Opportunity enrollmentOpp =
        [SELECT Id,
                Name,
                Enrollment_Start_Date__c,
                Enrollment_End_Date__c,
                Account.Name,
                Account.Owner.Name,
                Account.MCP_Number__c,
                Account.Eligibile_Employee_Count__c,
                Account.Marketing_Resource_ID__c,
                Account.Marketing_Account_Name__c,
                Account.Division__c,
                Assigned_Account_Manager__c,
                Assigned_Account_Manager__r.Name,
                Assigned_Account_Manager__r.Title,
                Enrollment_Path__c,
                Enrollment_Path__r.Name,
                AccountId,
                Confirm_New_or_Existing_Group__c,
                Branch_Office__c
           FROM Opportunity
          WHERE Id = :enrollmentOpportunityId];
          
        // Benefits and Services SOQL
        Set<String> benefitssAndServicesFields = new Set<String>{
            'Name'
        };

        String benefitssAndServiceSOQL = 'SELECT Id, ' + String.join(new List<String>(benefitssAndServicesFields), ',') +
                                        '  FROM Marketed_Product__c ' +
                                        ' WHERE Enrollment__r.Enrollment_Opportunity__c = :enrollmentOpportunityId ' +
                                        '   AND Products__r.Employer_Benefits_Site_Eligible__c = true ' +
                                        '   AND Products__r.Type__c in (\'Benefit\', \'Service\')' +
                                        ' ORDER BY Products__r.Name';

        List<Marketed_Product__c> benefitsAndServicesProducts = Database.query(benefitssAndServiceSOQL);
            
        // Import products SOQL
            
        Set<String> importFields = new Set<String>{
            'Name',
            'Products__r.Type__c',
            'Carrier__c',
            'Carrier_URL__c',
            'Include_on_Employer_Benefits_Site__c'
        };

        String importSOQL = 'SELECT Id, ' + String.join(new List<String>(importFields), ',') +
                            '  FROM Marketed_Product__c ' +
                            ' WHERE Enrollment__r.Enrollment_Opportunity__c = :enrollmentOpportunityId ' +
                            '   AND Products__r.Employer_Benefits_Site_Eligible__c = true ' +
                            '   AND Products__r.Type__c in (\'Import\')' +
                            ' ORDER BY Products__r.Name';

        List<Marketed_Product__c> importProducts = Database.query(importSOQL);
        
        Pre_Enrollment_Marketing_Form__c preenrollmentForm =
        [SELECT Id,
                Name,
                Show_One_on_One_Information__c,
                Show_Self_Service_Information__c,
                Title__c,
                License_No__c,
                License_Number_Required__c,
                Account_Manager_Name__c
           FROM Pre_Enrollment_Marketing_Form__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :enrollmentOpportunityId];

        return new OpportunityInformation(enrollmentOpp, benefitsAndServicesProducts, importProducts, preenrollmentForm);
    }
    
    @AuraEnabled
    public static List<MarketingMaterial> getPreenrollmentMaterials() {
        List<MarketingMaterial> preenrollmentMaterials = new List<MarketingMaterial>();
        
        String soql = 'SELECT ' + util.getFieldsInSOQL('Marketing_Material__c');
        soql += ' FROM Marketing_Material__c' +
                ' WHERE Status__c = \'Active\'' +
                '   AND Available_Packages__c includes (\'Pre-enrollment Marketing\')' +
                ' ORDER By Material_Type__c, Title__c';
        
        List<Marketing_Material__c> preenrollmentMaterialRecords = Database.query(soql);
        
        for (Marketing_Material__c preenrollmentMaterialRecord : preenrollmentMaterialRecords) {
            MarketingMaterial mm = new MarketingMaterial();
            mm.Record = preenrollmentMaterialRecord;
            
            preenrollmentMaterials.add(mm);
        }
        
        return preenrollmentMaterials;
    }

    @AuraEnabled
    public static List<EnrollmentSite> getAccountEnrollmentSites(String accountId, String opportunityId) {
        List<EnrollmentSite> enrollmentSites = new List<EnrollmentSite>();
        
        List<Enrollment_Site__c> enrollmentSiteRecords =
        [SELECT Id,
                Name,
                Physical_Street_Address__c,
                Physical_City__c,
                Physical_State__c,
                Physical_Zip__c,
                (SELECT Id,
                        Name,
                        Start_Date__c,
                        End_Date__c,
                        Start_Time__c,
                        End_Time__c,
                        Show_In_Build_Time_To_Enroll_Email__c
                   FROM Enrollment_Site_Dates__r
                  WHERE Enrollment_Opportunity__c = :opportunityId)
           FROM Enrollment_Site__c
          WHERE Account__c = :accountId
         ORDER BY Name];
        
        for (Enrollment_Site__c enrollmentSiteRecord : enrollmentSiteRecords) {
            EnrollmentSite es = new EnrollmentSite();
            es.Record = enrollmentSiteRecord;
            
            enrollmentSites.add(es);
        }
        
        return enrollmentSites;
    }

    @AuraEnabled
    public static Id addNewEnrollmentSite(Enrollment_Site__c newEnrollmentSite) {
        insert newEnrollmentSite;
        
        return newEnrollmentSite.Id;
    }

    @AuraEnabled
    public static void updateEnrollmentSite(Enrollment_Site__c enrollmentSiteToUpdate) {
        update enrollmentSiteToUpdate;
    }
    
    @AuraEnabled
    public static Id addNewEnrollmentSiteDate(Enrollment_Site_Date__c newEnrollmentSiteDate) {
        insert newEnrollmentSiteDate;
        
        return newEnrollmentSiteDate.Id;
    }

    @AuraEnabled
    public static void updateEnrollmentSiteDate(Enrollment_Site_Date__c updatedEnrollmentSiteDate) {
        update updatedEnrollmentSiteDate;
    }
    
    @AuraEnabled
    public static void deleteEnrollmentSiteDate(Id enrollmentSiteIdToDelete) {
        delete new Enrollment_Site_Date__c(Id = enrollmentSiteIdToDelete);
    }
    
    @AuraEnabled
    public static Id addPreenrollmentInfo(Id opportunityId, List<String> marketingMaterialsIds, String benefitsSiteInfoJSON, String preenrollmentMarketingFormId, Map<String, Object> otherPreenrollmentInfo) {
        CartInformation cartInfo = getCurrentCartOrCreateOne();

        List<Marketing_Material__c> marketingMaterials = getMarketingMaterialsByIds(marketingMaterialsIds);
        List<Order_Line_Item__c> orderLineItemsToInsert = new List<Order_Line_Item__c>();

        if (String.isBlank(preenrollmentMarketingFormId)) {
            preenrollmentMarketingFormId = getPreenrollmentMarketingFormIdByOpportunityId(opportunityId);
        }

        for (Marketing_Material__c mm : marketingMaterials) {
            if (isAlreadyOrdered(mm, cartInfo) == false) {
                Order_Line_Item__c orderLineItemToInsert = buildOrderLineItem(cartInfo.Order.Id, mm, 1, null);
                orderLineItemToInsert.Opportunity__c = opportunityId;
                
                if (String.isNotBlank(preenrollmentMarketingFormId)) {
                    orderLineItemToInsert.Preenrollment_Marketing_Form__c = preenrollmentMarketingFormId;
                }

                orderLineItemsToInsert.add(orderLineItemToInsert);
            }
        }

        insert orderLineItemsToInsert;

        removeUnselectedMaterials(marketingMaterialsIds, cartInfo);
        updateBenefitsSiteInfo(opportunityId, benefitsSiteInfoJSON);
        removeEnrollmentSiteDatesFromTimeToEnrollEmail(otherPreenrollmentInfo, opportunityId);

        return cartInfo.Order.Id;
    }

    @AuraEnabled
    public static void updateAccount(Account accountToUpdate) {
        update accountToUpdate;
    }
    
    private static CartInformation getCurrentCartOrCreateOne() {
        CartInformation cartInfo = new CartInformation(getCartForCurrentUser());
        
        if(cartInfo.Order == null)
        {
            cartInfo.Order = createOrder();
        }
        
        return cartInfo;
    }
    
    private static Order__c createOrder()
    {
        Order__c newOrder = new Order__c();
        newOrder.Status__c = 'In Progress';
        newOrder.Colleague__c = system.UserInfo.getUserId();
        newOrder.Order_Name__c = system.UserInfo.getName() + ' - ' + Datetime.now().format('MM/dd/yyyy');
        newOrder.Requested_Delivery_Date__c = system.today().addDays(10);
        
        insert newOrder;
        
        return newOrder;
    }
    
    @AuraEnabled
    public static void saveOrder(String lineItemsStringify, Order__c order)
    {
        List<Order_Line_Item__c> lineItems = (List<Order_Line_Item__c>)system.JSON.deserializeStrict(lineItemsStringify, List<Order_Line_Item__c>.class);
        
        if(lineItems.size() > 0)
            update lineItems;
        
        if(order != null)
            update order;
    }
    
    @AuraEnabled
    public static void updateLineItemsFromLookUps(String lineItemsStringify)
    {
        List<Order_Line_Item__c> lineItems = (List<Order_Line_Item__c>)system.JSON.deserializeStrict(lineItemsStringify, List<Order_Line_Item__c>.class);
        
        List<Id> orderLineItemIds = new List<Id>();
        List<Id> accountIds = new List<Id>();
        List<Id> oppIds = new List<Id>();
        List<Id> userIds = new List<Id>();
        
        for(Order_Line_Item__c orderLine : lineItems)
        {
            orderLineItemIds.add(orderLine.Id);
            
            if(orderLine.Account__c != null)
                accountIds.add(orderLine.Account__c);
            if(orderLine.Opportunity__c != null)
                oppIds.add(orderLine.Opportunity__c);
            if(orderLine.Colleague__c != null)
                userIds.add(orderLine.Colleague__c);
        }
        
        Map<Id, Account> accountData = new Map<Id, Account>([
            SELECT Id, Marketing_Account_Name__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode,
            Industry, Plan_Date__c, Office_Main_2__c FROM Account Where Id IN: accountIds
        ]);
        
        Map<Id, Opportunity> opportunityData = new Map<Id, Opportunity>([
            SELECT Id, Enrollment_Start_Date__c, Enrollment_End_Date__c FROM Opportunity WHERE Id IN: oppIds
        ]);
        
        Map<Id, User> colleagueData = new Map<Id, User>([
            SELECT Id, Name, Street, City, State, PostalCode, Title, Phone FROM User WHERE Id IN: userIds
        ]);
        
        Map<Id, Order_Line_Item__c> lineItemHistoryData = new Map<Id, Order_Line_Item__c>([
            SELECT Id, Account__c, Opportunity__c, Colleague__c FROM Order_Line_Item__c WHERE Id IN: orderLineItemIds
        ]);
        
        for(Order_Line_Item__c lineItem : lineItems)
        {
            Order_Line_Item__c oldLineItem = lineItemHistoryData.get(lineItem.Id);
            if(lineItem.Account__c != oldLineItem.Account__c)
            {
                Account acct = accountData.get(lineItem.Account__c);

                if (acct != null) {
	                lineItem.Marketing_Account_Name__c = acct.Marketing_Account_Name__c;
	               
	                lineItem.Account_Address__c = acct.ShippingStreet + '\n' +
	                    acct.ShippingCity + ', ' + acct.ShippingState + '  ' + acct.ShippingPostalCode;
	                
	                lineItem.Industry__c = acct.Industry;
	                
	                lineItem.Plan_Date__c = acct.Plan_Date__c;
	                
	                lineItem.Account_Phone__c = acct.Office_Main_2__c;
                }
                else {
                    lineItem.Marketing_Account_Name__c = null;
                   
                    lineItem.Account_Address__c = null;
                    
                    lineItem.Industry__c = null;
                    
                    lineItem.Plan_Date__c = null;
                    
                    lineItem.Account_Phone__c = null;
                }
            }
            
            if(lineItem.Opportunity__c != oldLineItem.Opportunity__c)
            {
                Opportunity opp = opportunityData.get(lineItem.Opportunity__c);
                
                if (opp != null) {
	                lineItem.Enrollment_Start_Date__c = opp.Enrollment_Start_Date__c;
	                
	                lineItem.Enrollment_End_Date__c = opp.Enrollment_End_Date__c;
                }
                else {
                    lineItem.Enrollment_Start_Date__c = null;
                    
                    lineItem.Enrollment_End_Date__c = null;
                }
            }
            
            if(lineItem.Colleague__c != oldLineItem.Colleague__c)
            {
                User colleague = colleagueData.get(lineItem.Colleague__c);
                
                if (colleague != null) {
	                lineItem.Colleague_Name__c = colleague.Name;
	                
	                lineItem.Colleague_Address__c = colleague.Street + '/n' +
	                    colleague.City + ', ' + colleague.State + '  ' + colleague.PostalCode;
	                
	                lineItem.Colleague_Title__c = colleague.Title;
	                
	                lineItem.Colleague_Phone__c = colleague.Phone;
                }
                else {
                    lineItem.Colleague_Name__c = null;
                    lineItem.Colleague_Address__c = null;
                    lineItem.Colleague_Title__c = null;
                    lineItem.Colleague_Phone__c = null;
                }
            }
        }
        
        update lineItems;
    }
    
    @AuraEnabled
    public static void saveOrderOnChange(Order__c order) {
        Order__c oldOrder = [SELECT Ship_To__c FROM Order__c WHERE Id =: order.Id];
        
        // update Shipping Fields based on ShipTo
        // Compare against the older order so we do not update
        // the users shipto fields if they have updated the 
        // line item ship to prior to changing to 'Me'
        if(order.Ship_To__c == 'Me' && oldOrder.Ship_To__c == 'Me')
        {
            updateUserShippingFields(order, UserInfo.getUserId());
        }
        
        update order;
    }
    
    private static void updateUserShippingFields(Order__c order, Id userId)
    {
        User u = [SELECT Street, City, State, PostalCode FROM User WHERE Id =: userId];
        if(u.Street != order.Shipping_Street__c ||
           u.State != order.Shipping_State__c ||
           u.City != order.Shipping_City__c ||
           u.PostalCode != order.Shipping_Zip__c)
        {
            u.Street = order.Shipping_Street__c;
            u.City = order.Shipping_City__c;
            u.State = order.Shipping_State__c;
            u.PostalCode = order.Shipping_Zip__c;
            update u;
        }
    }
    
    private static Order_Line_Item__c addMaterialToOrder(String orderId, Marketing_Material__c material, decimal quantity, Map<String, Object> customOrderLineFields)
    {
        try {
	        Order_Line_Item__c lineItem = buildOrderLineItem(orderId, material, quantity, customOrderLineFields);

	        insert lineItem;
	        
	        return lineItem;
        }
        catch (Exception e) {
            CustomExceptionData data;
            if (e.getMessage().containsIgnoreCase('DUPLICATE_VALUE'))
                data = new CustomExceptionData('Add To Cart Error', 'The marketing material you are attempting to order is already in your cart. Please adjust the quantity in your cart or complete your existing order, then place an additional order.', 407);
            else
               data = new CustomExceptionData('Add To Cart Error', 'An unexpected error happened, please contact your System Administrator', 409); 
            
            throw new AuraHandledException(JSON.serialize(data));
        }
    }

    private static Order_Line_Item__c addMaterialToOrder(Order__c order, Marketing_Material__c material, decimal quantity, Map<String, Object> customOrderLineFields)
    {
        return addMaterialToOrder(order.Id, material, quantity, customOrderLineFields);
    }
    
    private static Order_Line_Item__c buildOrderLineItem(String orderId, Marketing_Material__c material, decimal quantity, Map<String, Object> customOrderLineFields) {
        Order_Line_Item__c lineItem = new Order_Line_Item__c();
            
        Decimal quantityToUse;
        if(quantity == null)
            quantityToUse = material.Quantity_Minimum__c;
        else if(quantity < material.Quantity_Minimum__c)
            quantityToUse = material.Quantity_Minimum__c;
        else if(quantity > material.Quantity_Maximum__c)
            quantityToUse = material.Quantity_Maximum__c;
        else
            quantityToUse = quantity;
        
        lineItem.Order__c = orderId;
        lineItem.Marketing_Material__c = material.Id;
        lineItem.Quantity__c = quantityToUse;
        lineItem.Material_Number__c = material.Material_Number__c;
        lineItem.Material_Title__c = material.Title__c;
        lineItem.Unit_Price__c = material.Price__c;
        
        if (customOrderLineFields != null) {
            for (String customField : customOrderLineFields.keySet()) {
                lineItem.put(customField, customOrderLineFields.get(customField));
            }
        }
        
        return lineItem;
    }

    @AuraEnabled 
    public static CartInformation duplicateLineItem(String marketingMaterialId, decimal quantity, String orderId, String lineItemsStringify)
    {
        // update the current line items in the cart to save additional field info
        List<Order_Line_Item__c> lineItems = (List<Order_Line_Item__c>)system.JSON.deserializeStrict(lineItemsStringify, List<Order_Line_Item__c>.class);
        update lineItems;
        
        String soql = util.getCreatableFields('Marketing_Material__c');
        
        soql += ' FROM Marketing_Material__c';
        soql += ' WHERE Id = \'' + marketingMaterialId + '\'';
        
        Marketing_Material__c material = Database.query(soql);
        
        Order_Line_Item__c lineItem = addMaterialToOrder(orderId, material, quantity, new Map<String, Object>());
        
        return getCart(false);
    }

    @AuraEnabled
    public static void removeLineItemFromOrder(String lineItemId)
    {
        system.debug('Line item id: ' + lineItemId);
        delete new Order_Line_Item__c(Id = lineItemId);
    }
    
    @testVisible
    private static Order__c getCartForCurrentUser() {
        
        String soql = util.getFields('Order__c');
        String innerSoql = util.getFields('Order_Line_Item__c');
        
        soql += ', (' + innerSoql + ', Marketing_Material__r.Thumbnail_URL__c, Marketing_Material__r.Customization_Type__c';
        soql += ', Marketing_Material__r.Additional_Information_Needed__c, Marketing_Material__r.Description__c, Marketing_Material__r.Material_Type__c';
        soql += ', Marketing_Material__r.File_Type__c, Marketing_Material__r.Material_Number__c, Marketing_Material__r.New__c';
        soql += ', Marketing_Material__r.Price__c, Marketing_Material__r.Quantity_Maximum__c, Marketing_Material__r.Quantity_Minimum__c';
        soql += ', Marketing_Material__r.Title__c, Marketing_Material__r.Logo_Option__c, Marketing_Material__r.Processing_Type__c';
        soql += ' FROM Order_Line_Items__r)';
        soql += ' FROM Order__c';
        soql += ' WHERE Status__c = \'In Progress\'';
        soql += ' AND CreatedById = \'' + UserInfo.getUserId() + '\'';
        soql += ' ORDER By CreatedDate DESC LIMIT 1';
        
        system.debug(soql);
        
        List<Order__c> carts = database.query(soql);
        
        if (carts.size() > 0) {
            return carts[0];
        }

        return null;
    }
    
    private static Order__c getOrderById(Id orderId) {
        
        String soql = util.getFields('Order__c');
        
        if (soql.containsIgnoreCase('Colleague__r.Name') == false) {
            soql += ' , Colleague__r.Name ';
        }
        
        String innerSoql = util.getFields('Order_Line_Item__c');
        
        soql += ', (' + innerSoql + ', Marketing_Material__r.Thumbnail_URL__c, Marketing_Material__r.Customization_Type__c';
        soql += ', Marketing_Material__r.Additional_Information_Needed__c, Marketing_Material__r.Description__c, Marketing_Material__r.Material_Type__c';
        soql += ', Marketing_Material__r.File_Type__c, Marketing_Material__r.Material_Number__c, Marketing_Material__r.New__c';
        soql += ', Marketing_Material__r.Price__c, Marketing_Material__r.Quantity_Maximum__c, Marketing_Material__r.Quantity_Minimum__c';
        soql += ', Marketing_Material__r.Title__c, Marketing_Material__r.Logo_Option__c, Marketing_Material__r.Processing_Type__c';
        soql += ', Marketing_Material__r.Email_To_Build__c, Marketing_Material__r.Website_Type__c, Opportunity__r.AccountId';
        soql += ' FROM Order_Line_Items__r)';
        soql += ' FROM Order__c';
        soql += ' WHERE Id = :orderId';
        
        system.debug(soql);
        
        List<Order__c> orders = database.query(soql);
       
        if (orders.size() > 0) {
            return orders[0];
        }

        return null;
    }
    
    private static Branch_Office__c getSalesoffice(Order__c order) {
        if (order == null) {
            return null;
        }
        
        List<Branch_Office__c> branchOffices =
        [SELECT Id,
                Name,
                Charge_Code__c
           FROM Branch_Office__c
          WHERE Id = :order.Sales_Office__c];

        if (branchOffices.size() > 0) {
            return branchOffices[0];
        }

        return null;
    }
    
    private static List<OrderLine> getDownloadableOrderLinesByOrderId(Id orderId) {
        List<OrderLine> downloadableOrderLines = new List<OrderLine>();
        
        List<Order_Line_Item__c> orderLines =
        [SELECT Id,
                Name,
                Marketing_Material__c,
                Marketing_Material__r.Id,
                Marketing_Material__r.Material_Number__c,
                Marketing_Material__r.Thumbnail_URL__c,
                Marketing_Material__r.Download_URL__c,
         		Marketing_Material__r.Material_Type__c,
                Marketing_Material__r.Title__c,
         		Marketing_Material__r.Quantity_Maximum__c,
         		Marketing_Material__r.Quantity_Minimum__c
           FROM Order_Line_Item__c
          WHERE Order__c = :orderId
            AND Marketing_Material__r.Processing_Type__c = 'Download Only'];

        Set<Id> faves = getUserFavorites();
        
        for (Order_Line_Item__c orderLine : orderLines) {
            downloadableOrderLines.add(new OrderLine(orderLine, faves));
        }

        return downloadableOrderLines;
    }
    
    @AuraEnabled
    public static String getObjectFields()
    {
        Map<String, Schema.DescribeFieldResult> orderFields = new Map<String, Schema.DescribeFieldResult>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Order__c.fields.getMap();
        
        for(Schema.SObjectField objectField : fieldMap.values())
        {
            Schema.DescribeFieldResult fieldDescribe = objectField.getDescribe();
            orderFields.put(fieldDescribe.getName(), fieldDescribe);
        }
        
        return JSON.serialize(orderFields, true);
    }
    
    @AuraEnabled
    public static Boolean ReOrderFromHistory(String orderHistoryOrderId)
    {
        try{
            Boolean allItemsAdded = true;
            
            List<Order_Line_Item__c> originals = getOrderLinesForReorder(orderHistoryOrderId);
            
            Order__c currentOrder = getCartForCurrentUser();
            if(currentOrder == null)
                currentOrder = createOrder();
            
            List<Order_Line_Item__c> clonedLineItems = new List<Order_Line_Item__c>();
            
            for(Order_Line_Item__c original : originals)
            {
                Boolean isAvailableForOrdering = original.Marketing_Material__r.Not_Available_For_Order__c == null ||
                                                 original.Marketing_Material__r.Not_Available_For_Order__c == false;
                
                if(original.Marketing_Material__r.Status__c != 'Inactive' && isAvailableForOrdering)
                {
                    Order_Line_Item__c clonedItem = original.clone(false, true);
                    clonedItem.Order__c = currentOrder.Id;
                    clonedLineItems.add(clonedItem);
                }
                else
                    allItemsAdded = false;                
            }
            
            if(clonedLineItems.size() > 0)
            {
                insert clonedLineItems;
                
                currentOrder.Reorder__c = true;
                update currentOrder;
            }
            
            return allItemsAdded;
                
        }
        catch (Exception e) {
            CustomExceptionData data = new CustomExceptionData('Cloning Error', 'The following error occurred while cloning your items: ' + e.getMessage(), 611);
            throw new AuraHandledException(JSON.serialize(data));
        }        
    }
    
    private static List<Order_Line_Item__c> getOrderLinesForReorder(Id orderId) {
        Schema.FieldSet reOrderFieldsToClone = SObjectType.Order_Line_Item__c.FieldSets.ReOrder_Fields;
        
        Set<String> fieldsToQuery = Util.getFieldSetFields(reOrderFieldsToClone);
        String fields = String.join(new List<String>(fieldsToQuery), ',');
        
        String soql = 'SELECT ' + fields;
        soql += ', Marketing_Material__r.Status__c, Marketing_Material__r.Not_Available_For_Order__c';
        soql += ' FROM Order_Line_Item__c';
        soql += ' WHERE Order__c = \'' + orderId + '\'';
        
        List<Order_Line_Item__c> lineItems = (List<Order_Line_Item__c>)Database.query(soql);
        
        system.debug('Original Line Items: ' + lineItems);
        
        return lineItems;
    }
    
    private static List<Marketing_Material__c> getMarketingMaterialsByIds(List<String> marketingMaterialIds) {
        String soql = 'SELECT ' + util.getFieldsInSOQL('Marketing_Material__c');
        soql += ' FROM Marketing_Material__c' +
                ' WHERE Id in :marketingMaterialIds';
        
        List<Marketing_Material__c> marketingMaterials = (List<Marketing_Material__c>) Database.query(soql);
        
        return marketingMaterials;
    }
    
    @testVisible
    private static void updateBenefitsSiteInfo(Id enrollmentOppId, String benefitsSiteInfoJSON) {
        if (String.isBlank(benefitsSiteInfoJSON)) {
            return;
        }
        
        Map<String, Object> benefitsSiteInfoToUpdate = (Map<String, Object>) JSON.deserializeUntyped(benefitsSiteInfoJSON);
        
        if (benefitsSiteInfoToUpdate == null ||
            benefitsSiteInfoToUpdate.isEmpty()) {
            return;
        }

        Pre_Enrollment_Marketing_Form__c preenrollmentForm =
        [SELECT Id
           FROM Pre_Enrollment_Marketing_Form__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :enrollmentOppId
         Limit 1];

        Opportunity oppToUpdate = new Opportunity(Id = enrollmentOppId);
        oppToUpdate.Employer_Benefits_Site__c = 'Yes';
        Boolean updateEnrollmentOpp = false;

        if (benefitsSiteInfoToUpdate.containsKey('GroupDisplayName')) {
	        String groupDisplayName = (String) benefitsSiteInfoToUpdate.get('GroupDisplayName');
	
	        oppToUpdate.Group_Display_Name__c = groupDisplayName;
        }

        if (benefitsSiteInfoToUpdate.containsKey('BranchOffice')) {
	        String branchOfficeId = (String) benefitsSiteInfoToUpdate.get('BranchOffice');
	
	        oppToUpdate.Branch_Office__c = branchOfficeId;
        }
	    
        update oppToUpdate;
        
        preenrollmentForm.Title__c = (String) benefitsSiteInfoToUpdate.get('Title');
        preenrollmentForm.License_No__c = (String) benefitsSiteInfoToUpdate.get('LicenseNumber');
        
        if (benefitsSiteInfoToUpdate.get('ShowOneonOneInformation') != null) {
            preenrollmentForm.Show_One_on_One_Information__c = (Boolean) benefitsSiteInfoToUpdate.get('ShowOneonOneInformation');
        }
        
        if (benefitsSiteInfoToUpdate.get('ShowSelfServiceInformation') != null) {
            preenrollmentForm.Show_Self_Service_Information__c = (Boolean) benefitsSiteInfoToUpdate.get('ShowSelfServiceInformation');
        }
        
        if (String.isNotBlank((String)benefitsSiteInfoToUpdate.get('OpenEnrollmentStartDate'))) {
            preenrollmentForm.Open_Enrollment_Sart__c = Date.valueOf((String) benefitsSiteInfoToUpdate.get('OpenEnrollmentStartDate'));
        }
        
        if (String.isNotBlank((String)benefitsSiteInfoToUpdate.get('OpenEnrollmentEndDate'))) {
            preenrollmentForm.Open_Enrollment_End__c = Date.valueOf((String) benefitsSiteInfoToUpdate.get('OpenEnrollmentEndDate'));
        }
        
        update preenrollmentForm;
        
        List<Object> importProductsObjList = (List<Object>) benefitsSiteInfoToUpdate.get('ImportProducts');
        
        if (importProductsObjList == null || importProductsObjList.size() == 0) {
            return;
        }

        List<Marketed_Product__c> importProductsToUpdate = new List<Marketed_Product__c>();
        
        for (Object importProductObj : importProductsObjList) {
            Map<String, Object> importProductMap = (Map<String, Object>) importProductObj;
            
            Marketed_Product__c importProduct = new Marketed_Product__c(
                Id = (Id) importProductMap.get('Id'),
                Carrier__c = (String) importProductMap.get('Carrier__c'),
                Carrier_URL__c = (String) importProductMap.get('Carrier_URL__c'),
                Include_on_Employer_Benefits_Site__c = (Boolean) importProductMap.get('Include_on_Employer_Benefits_Site__c')
            );
            
            importProductsToUpdate.add(importProduct);
        }
        
        update importProductsToUpdate;
    }

    private static Boolean isAlreadyOrdered(Marketing_Material__c mm, CartInformation cartInfo) {
        for (OrderLine ol : cartInfo.OrderLineItems) {
            if (ol.Record.Marketing_Material__c == mm.Id) {
                return true;
            }
        }

        return false;
    }

    private static void removeUnselectedMaterials(List<String> marketingMaterialsIds, CartInformation cartInfo) {
        List<Order_Line_Item__c> orderLinesToDelete = new List<Order_Line_Item__c>();

        for (OrderLine ol : cartInfo.OrderLineItems) {
            if (marketingMaterialsIds.contains(ol.Record.Marketing_Material__c) == false) {
                orderLinesToDelete.add(ol.Record);
            }
        }

        if (orderLinesToDelete.size() > 0) {
            delete orderLinesToDelete;
        }
	}

    private static Id getPreenrollmentMarketingFormIdByOpportunityId(Id opportunityId) {
        List<Pre_Enrollment_Marketing_Form__c> marketingForms =
        [SELECT Id
           FROM Pre_Enrollment_Marketing_Form__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :opportunityId];

        if (marketingForms.size() > 0) {
            return marketingForms[0].Id;
        }

        return null;
    }

    @testVisible
    private static void removeEnrollmentSiteDatesFromTimeToEnrollEmail(Map<String, Object> otherPreenrollmentInfo, Id opportunityId) {
        if (otherPreenrollmentInfo == null ||
            otherPreenrollmentInfo.containsKey('addEnrollmentSitesForBuildYourOwnTimeToEnrollEmail') == false ||
            otherPreenrollmentInfo.get('addEnrollmentSitesForBuildYourOwnTimeToEnrollEmail') == true) {
            return;
        }

        List<Enrollment_Site_Date__c> oppEnrollmentSiteDates =
        [SELECT Id
           FROM Enrollment_Site_Date__c
          WHERE Enrollment_Opportunity__c = :opportunityId];

        for (Enrollment_Site_Date__c oppEnrollmentSiteDate : oppEnrollmentSiteDates) {
            oppEnrollmentSiteDate.Show_In_Build_Time_To_Enroll_Email__c = false;
        }

        if (oppEnrollmentSiteDates.size() > 0) {
            update oppEnrollmentSiteDates;
        }
    }
    
    public class CartInformation {
        @AuraEnabled
        public Order__c Order { get; set; }
        
        @AuraEnabled
        public List<OrderLine> OrderLineItems { get; set; }
        
        @AuraEnabled
        public Branch_Office__c SalesOffice { get; set; }
        
        public CartInformation(Order__c cart) {
            OrderLineItems = new List<OrderLine>();
            Order = cart;
            
            Set<Id> faves = getUserFavorites();
            
            if (Order != null) {
                Map<String, Schema.FieldSet> orderLineItemFieldSetsMap = Order_Line_Item__c.sObjectType.getDescribe().fieldSets.getMap();
                
                for (Order_Line_Item__c orderLineItem : Order.Order_Line_Items__r) {
                    OrderLine oli = new OrderLine(orderLineItem, faves);

                    String customFieldSet = orderLineItem.Marketing_Material__r.Customization_Type__c;

                    if (String.isNotBlank(customFieldSet)) {

                        Schema.FieldSet orderLineItemFieldSet = orderLineItemFieldSetsMap.get(customFieldSet);
                        
                        if (orderLineItemFieldSet == null) {
                            for (Schema.FieldSet fs : orderLineItemFieldSetsMap.values()) {
                                if (fs.getLabel() == customFieldSet) {
                                    orderLineItemFieldSet = fs;
                                    break;
                                }
                            }
                        }

                        if (orderLineItemFieldSet != null) {
                            oli.CustomFieldSet = orderLineItemFieldSet.getName();
                            
                            for (Schema.FieldSetMember fsm : orderLineItemFieldSet.getFields()) {
                                oli.CustomFields.add( new Field(fsm) );
                            }
                        }
                    }

                    OrderLineItems.add(oli);
                }
            }
        }
    }
    
    public class OrderHistoryDetail {
        @AuraEnabled
        public Order__c Order { get; set; }
        
        @AuraEnabled
        public List<OrderLine> OrderLineItems { get; set; }
        
        @AuraEnabled
        public Branch_Office__c SalesOffice { get; set; }        
        
        public OrderHistoryDetail(Order__c cart) {
            OrderLineItems = new List<OrderLine>();
            Order = cart;
            
            Set<Id> faves = getUserFavorites();
            
            if (Order != null) {
                Map<String, Schema.FieldSet> orderLineItemFieldSetsMap = Order_Line_Item__c.sObjectType.getDescribe().fieldSets.getMap();
                
                for (Order_Line_Item__c orderLineItem : Order.Order_Line_Items__r) {
                    OrderLine oli = new OrderLine(orderLineItem, faves);

                    String customFieldSet = orderLineItem.Marketing_Material__r.Customization_Type__c;

                    if (String.isNotBlank(customFieldSet)) {

                        Schema.FieldSet orderLineItemFieldSet = orderLineItemFieldSetsMap.get(customFieldSet);
                        
                        if (orderLineItemFieldSet == null) {
                            for (Schema.FieldSet fs : orderLineItemFieldSetsMap.values()) {
                                if (fs.getLabel() == customFieldSet) {
                                    orderLineItemFieldSet = fs;
                                    break;
                                }
                            }
                        }

                        if (orderLineItemFieldSet != null) {
                            oli.CustomFieldSet = orderLineItemFieldSet.getName();
                            
	                        for (Schema.FieldSetMember fsm : orderLineItemFieldSet.getFields()) {
	                            oli.CustomFields.add( new Field(fsm) );
	                        }
                        }
                    }

                    OrderLineItems.add(oli);
                }
            }
        }        
    }
    
    public class OrderConfirmation {
        @AuraEnabled
        public Order__c Order { get; set; }
        
        @AuraEnabled
        public List<OrderLine> DownloadableOrderLines { get; set; }
        
        @AuraEnabled
        public String DownloadAllURL { get; set; }
        
        public OrderConfirmation() {
            DownloadableOrderLines = new List<OrderLine>();
        }
        
        public void loadDownloadAllURL() {
            Set<String> contentDocumentIds = new Set<String>();
            String contentDocumentIdPrefix = ContentDocument.sobjecttype.getDescribe().getKeyPrefix();
            
            for (OrderLine downloadableOrderLine : DownloadableOrderLines) {
                if (String.isBlank(downloadableOrderLine.MarketingMaterial.Record.Download_Url__c) ||
                    downloadableOrderLine.MarketingMaterial.Record.Material_Type__c == 'Video') {
                    continue;
                }
                
                String[] downloadURLParts = downloadableOrderLine.MarketingMaterial.Record.Download_Url__c.split('/');
                String contentDocumentIdPossibility = downloadURLParts[downloadURLParts.size() - 1];
                
                if (contentDocumentIdPossibility.startsWithIgnoreCase(contentDocumentIdPrefix)) {
                    contentDocumentIds.add(contentDocumentIdPossibility);
                }
            }
            
            if (contentDocumentIds.isEmpty() == false) {
                String baseURL = System.Url.getSalesforceBaseURL().toExternalForm();
                String downloadBasePath = baseURL + '/sfc/servlet.shepherd/document/download/';
                
                DownloadAllURL = downloadBasePath + String.join(new List<String>(contentDocumentIds), '/');
            }
        }
    }
    
    public class OrderLine {        
        @AuraEnabled
        public MarketingMaterial MarketingMaterial { get; set; }
        
        @AuraEnabled
        public Order_Line_Item__c Record { get; set; }
        
        @AuraEnabled
        public List<Field> CustomFields { get; set; }
        
        @AuraEnabled
        public String CustomFieldSet { get; set; }
        
        public OrderLine(Order_Line_Item__c orderLine, Set<Id> favoritesList) {
            Record = orderLine;
            MarketingMaterial = new MarketingMaterial();
            MarketingMaterial.Record = orderLine.Marketing_Material__r;
            if(favoritesList.contains(orderLine.Marketing_Material__c))
                MarketingMaterial.IsFavorite = true;
            CustomFields = new List<Field>();
            CustomFieldSet = '';
        }
    }
    
    public class MarketingMaterial {
        @AuraEnabled
        public Marketing_Material__c Record { get; set; }
        
        @AuraEnabled
        public List<String> Warnings { get; set; }
        
        @AuraEnabled
        public Boolean IsFavorite { get; set; }
        
        public MarketingMaterial() {
            Warnings = new List<String>();  
            IsFavorite = false;
        }
    }
    
    public class OpportunityInformation {
        @AuraEnabled
        public String AccountId { get; set; }
        
        @AuraEnabled
        public String AccountName { get; set; }
        
        @AuraEnabled
        public String OpportunityName { get; set; }
        
        @AuraEnabled
        public String MCP { get; set; }
        
        @AuraEnabled
        public String EnrollmentStartDateStr { get; set; }
        
        @AuraEnabled
        public String EnrollmentEndDateStr { get; set; }
        
        @AuraEnabled
        public String AccountOwner { get; set; }
        
        @AuraEnabled
        public Integer EligibleEmployeeCount { get; set; }
        
        @AuraEnabled
        public String EnrollmentPath { get; set; }
        
        @AuraEnabled
        public String NewOrExisting { get; set; }
        
        @AuraEnabled
        public Account Account { get; set; }
        
        @AuraEnabled
        public List<Marketed_Product__c> BenefitsAndServiceProducts { get; set; }
        
        @AuraEnabled
        public List<Marketed_Product__c> ImportProducts { get; set; }
        
        @AuraEnabled
        public Pre_Enrollment_Marketing_Form__c PreenrollmentForm { get; set; }
        
        @AuraEnabled
        public Opportunity EnrollmentOpportunity { get; set; }
        
        public OpportunityInformation(
            Opportunity enrollmentOpp,
            List<Marketed_Product__c> benefitsAndServiceProductsArg,
            List<Marketed_Product__c> importProductsArg,
            Pre_Enrollment_Marketing_Form__c preenrollmentFormArg) {

            AccountId = enrollmentOpp.AccountId;
            AccountName = enrollmentOpp.Account.Name;
            Account = enrollmentOpp.Account;
            MCP = enrollmentOpp.Account.MCP_Number__c;
            AccountOwner = enrollmentOpp.Account.Owner.Name;
            OpportunityName = enrollmentOpp.Name;
            EligibleEmployeeCount = (Integer) enrollmentOpp.Account.Eligibile_Employee_Count__c;
            NewOrExisting = enrollmentOpp.Confirm_New_or_Existing_Group__c;
            
            if (enrollmentOpp.Enrollment_Path__c != null) {
                EnrollmentPath = enrollmentOpp.Enrollment_Path__r.Name;
            }
            
            if (enrollmentOpp.Enrollment_Start_Date__c != null) {
                EnrollmentStartDateStr = enrollmentOpp.Enrollment_Start_Date__c.format();
            }

            if (enrollmentOpp.Enrollment_End_Date__c != null) {
                EnrollmentEndDateStr = enrollmentOpp.Enrollment_End_Date__c.format();
            }
            
            BenefitsAndServiceProducts = benefitsAndServiceProductsArg;
            ImportProducts = importProductsArg;
            PreenrollmentForm = preenrollmentFormArg;
            EnrollmentOpportunity = enrollmentOpp;
        }
    }
    
    public class EnrollmentSite {
        @AuraEnabled
        public Enrollment_Site__c Record { get; set; }
    } 
}