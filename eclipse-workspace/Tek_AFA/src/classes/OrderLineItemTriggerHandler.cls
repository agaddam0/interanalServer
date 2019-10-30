public with sharing class OrderLineItemTriggerHandler extends TriggerHandlerBase {
    private static final String MULTI_SELECT_PICKLIST_DELIMITER = ';';

    @TestVisible
    private static Set<String> preenrollmentTestCustomFields = new Set<String>();

    protected override void beforeInsert(List<Sobject> newRecords) {
        prepopulatePreenrollmentCustomFields(newRecords);
    }
    
    private void prepopulatePreenrollmentCustomFields(List<Order_Line_Item__c> newOrderLineItems) {
        PreenrollmentOrderLineItemsContext context = fetchPreenrollmentOrderLineItemsInfo(newOrderLineItems);
        
        if (context.OrderLineItems.isEmpty()) {
            return;
        }

        Map<Id, Marketing_Material__c> customMarketingMaterialsMap = getMarketingMaterialsMapById(context.MarketingMaterialIds);
        Map<Id, PreenrollmentInfo> preenrollmentInfoMap = getPreenrollmentInfoMapById(context.PreenrollmentMarketingIds);
        Map<String, Schema.FieldSet> orderLineItemFieldSetsMap = Order_Line_Item__c.sObjectType.getDescribe().fieldSets.getMap();
        Map<String, Schema.FieldSet> orderLineItemFieldSetsMapByLabel = indexFieldSetsByLabel(orderLineItemFieldSetsMap);
        
        for (Order_Line_Item__c preenrollmentOrderLineItem : context.OrderLineItems) {
            Marketing_Material__c customMarketingMaterial = customMarketingMaterialsMap.get(preenrollmentOrderLineItem.Marketing_Material__c);
            
            if (customMarketingMaterial == null) {
                continue;
            }

            PreenrollmentInfo preInfo = preenrollmentInfoMap.get(preenrollmentOrderLineItem.Preenrollment_Marketing_Form__c);
            
            Schema.FieldSet oliFieldSet = orderLineItemFieldSetsMap.get(customMarketingMaterial.Customization_Type__c);
            
            // Try fetching the field set by label instead of API Name.
            if (oliFieldSet == null) {
                oliFieldSet = orderLineItemFieldSetsMapByLabel.get(customMarketingMaterial.Customization_Type__c);
            }
            
            populatePreenrollmentCustomFields(preenrollmentOrderLineItem, preInfo, oliFieldSet);
        }
    }
    
    private PreenrollmentOrderLineItemsContext fetchPreenrollmentOrderLineItemsInfo(List<Order_Line_Item__c> newOrderLineItems) {
        PreenrollmentOrderLineItemsContext context = new PreenrollmentOrderLineItemsContext();

        for (Order_Line_Item__c newOrderLineItem : newOrderLineItems) {
            if (newOrderLineItem.Preenrollment_Marketing_Form__c != null) {
                context.OrderLineItems.add(newOrderLineItem);
                context.MarketingMaterialIds.add(newOrderLineItem.Marketing_Material__c);
                context.PreenrollmentMarketingIds.add(newOrderLineItem.Preenrollment_Marketing_Form__c);
            }
        }

        return context;
    }
    
    private Map<Id, Marketing_Material__c> getMarketingMaterialsMapById(Set<Id> marketingMaterialIds) {
        return new Map<Id, Marketing_Material__c>(
            [SELECT Id,
                    Name,
                    Customization_Type__c
               FROM Marketing_Material__c
              WHERE Id in :marketingMaterialIds
                AND Customization_Type__c != null]
        );
    }
    
    private Map<Id, PreenrollmentInfo> getPreenrollmentInfoMapById(Set<Id> preenrollmentMarketingIds) {
        Map<Id, PreenrollmentInfo> preenrollmentInfos = new Map<Id, PreenrollmentInfo>();

        List<Pre_Enrollment_Marketing_Form__c> preenrollmentMarketingForms =
        [SELECT Id,
                Enrollment_Form__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.Marketing_Account_Name__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.Plan_Date__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.AccountId,
                Enrollment_Form__r.Enrollment_Opportunity__r.Plan_Date_New__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_Start_Date__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_End_Date__c,
                Branch_Office__c,
                License_No__c
           FROM Pre_Enrollment_Marketing_Form__c
          WHERE Id in :preenrollmentMarketingIds];

        Set<Id> enrollmentFormIds = CollectionUtil.getLookupIds(preenrollmentMarketingForms, 'Enrollment_Form__c');
        
        List<Marketed_Product__c> marketedProducts =
        [SELECT Id,
                Name,
                Enrollment__c,
                Products__c,
                Products__r.Name,
                Products__r.MarketPlace_Product_Option__c
           FROM Marketed_Product__c
          WHERE Enrollment__c in :enrollmentFormIds
            AND Products__r.Rider__c = false
         ORDER BY Enrollment__c, Products__r.Order__c];

        Map<Id, List<SObject>> marketedProductsByEnrollment = CollectionUtil.groupRecordsByLookupField(marketedProducts, 'Enrollment__c');

        for (Pre_Enrollment_Marketing_Form__c preenrollmentMarketingForm : preenrollmentMarketingForms) {
            PreenrollmentInfo preInfo = new PreenrollmentInfo();

            preInfo.PreenrollmentMarketingForm = preenrollmentMarketingForm;
            preInfo.setMarketedProducts( (List<Marketed_Product__c>) marketedProductsByEnrollment.get(preenrollmentMarketingForm.Enrollment_Form__c));

            preenrollmentInfos.put(preenrollmentMarketingForm.Id, preInfo);
        }

        return preenrollmentInfos;
    }

    private void populatePreenrollmentCustomFields(Order_Line_Item__c preenrollmentOrderLineItem, PreenrollmentInfo preInfo, Schema.FieldSet oliFieldSet) {
        Set<String> fieldNames = Util.getFieldSetFields(oliFieldSet);
        fieldNames.addAll(preenrollmentTestCustomFields);
        
        for (String fieldName : fieldNames) {
            Object fieldValue = preenrollmentOrderLineItem.get(fieldName);
            
            // Don't overwrite any fields with an existing value.
            if (fieldValue != null) {
                continue;
            }
            
            if (fieldName == 'Section_125__c' &&
                preInfo.marketedProductsContainsProduct('Section 125')) {
                preenrollmentOrderLineItem.Section_125__c = 'Yes';
            }
            else if (fieldName == 'Plan_Date__c') {
                preenrollmentOrderLineItem.Plan_Date__c = preInfo.PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Account.Plan_Date__c;
            }
            else if (fieldName == 'Flex__c' &&
                     preInfo.marketedProductsContainsProduct('FSA')) {
                preenrollmentOrderLineItem.Flex__c = 'Yes';
            }
            else if (fieldName == 'Marketing_Account_Name__c') {
                preenrollmentOrderLineItem.Marketing_Account_Name__c = preInfo.PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Account.Marketing_Account_Name__c;
            }
            else if (fieldName == 'Account__c') {
                preenrollmentOrderLineItem.Account__c = preInfo.PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.AccountId;
            }
            else if (fieldName == 'Sales_Office__c') {
                preenrollmentOrderLineItem.Sales_Office__c = preInfo.PreenrollmentMarketingForm.Branch_Office__c;
            }
            else if (fieldName == 'Colleague_License__c') {
                preenrollmentOrderLineItem.Colleague_License__c = preInfo.PreenrollmentMarketingForm.License_No__c;
            }
            else if (fieldName == 'Colleague__c') {
                preenrollmentOrderLineItem.Colleague__c = preInfo.PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__c;
            }
            else if (fieldName == 'Enrollment_Start_Date__c') {
                preenrollmentOrderLineItem.Enrollment_Start_Date__c = preInfo.PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_Start_Date__c;
            }
            else if (fieldName == 'Enrollment_End_Date__c') {
                preenrollmentOrderLineItem.Enrollment_End_Date__c = preInfo.PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_End_Date__c;
            }
            else if (fieldName.containsIgnoreCase('Combo_Product_Option') ||
                     fieldName.containsIgnoreCase('Group_Product_Option') ||
                     fieldName.containsIgnoreCase('Product_Option')) {
                prepopulateProductOptionField(preenrollmentOrderLineItem, fieldName, preInfo);
            }
            else if (fieldName == 'Products__c' ||
                     fieldName == 'Pre_enrollment_Products__c') {
                prepopulateProductsField(preenrollmentOrderLineItem, fieldName, preInfo);
            }
        }
    }

    private void prepopulateProductOptionField(Order_Line_Item__c preenrollmentOrderLineItem, String fieldName, PreenrollmentInfo preInfo) {
        List<String> fieldNameParts = fieldName.split('_');
        Integer productNumber;
        
        for (String fieldNamePart : fieldNameParts) {
            if (fieldNamePart.isNumeric()) {
                productNumber = Integer.valueOf(fieldNamePart);
                break;
            }
        }
        
        if (preInfo.ProductOptionMarketedProducts.size() >= productNumber) {
            Marketed_Product__c enrollmentProduct = preInfo.ProductOptionMarketedProducts[productNumber - 1];
            
            preenrollmentOrderLineItem.put(fieldName, enrollmentProduct.Products__r.MarketPlace_Product_Option__c);
        }
    }

    private void prepopulateProductsField(Order_Line_Item__c preenrollmentOrderLineItem, String fieldName, PreenrollmentInfo preInfo) {
        Set<String> products = new Set<String>();

        for (Marketed_Product__c mp : preInfo.ProductOptionMarketedProducts) {
            products.add(mp.Products__r.MarketPlace_Product_Option__c);
        }

        String productsList = String.join(new List<String>(products), MULTI_SELECT_PICKLIST_DELIMITER);

        preenrollmentOrderLineItem.put(fieldName, productsList);
    }
    
    private Map<String, Schema.FieldSet> indexFieldSetsByLabel(Map<String, Schema.FieldSet> orderLineItemFieldSetsMap) {
        Map<String, Schema.FieldSet> fieldSetsByLabel = new Map<String, Schema.FieldSet>();
        
        for (Schema.FieldSet fs : orderLineItemFieldSetsMap.values()) {
            fieldSetsByLabel.put(fs.getLabel(), fs);
        }
        
        return fieldSetsByLabel;
    }
    
    private class PreenrollmentOrderLineItemsContext {
        public List<Order_Line_Item__c> OrderLineItems { get; set; }
        
        public Set<Id> MarketingMaterialIds { get; set; }
        
        public Set<Id> PreenrollmentMarketingIds { get; set; }
        
        public PreenrollmentOrderLineItemsContext() {
            OrderLineItems = new List<Order_Line_Item__c>();
            MarketingMaterialIds = new Set<Id>();
            PreenrollmentMarketingIds = new Set<Id>();
        }
    }
    
    private class PreenrollmentInfo {
        public Pre_Enrollment_Marketing_Form__c PreenrollmentMarketingForm { get; set; }
        
        public List<Marketed_Product__c> MarketedProducts { get; private set; }
        
        public List<Marketed_Product__c> ProductOptionMarketedProducts { get; private set; }
        
        public PreenrollmentInfo() {
            MarketedProducts = new List<Marketed_Product__c>();
            ProductOptionMarketedProducts = new List<Marketed_Product__c>();
        }
        
        public Boolean marketedProductsContainsProduct(String partialProductName) {
            for (Marketed_Product__c mp : MarketedProducts) {
                if (mp.Products__r.Name.containsIgnoreCase(partialProductName)) {
                    return true;
                }
            }

            return false;
        }
        
        public void setMarketedProducts(List<Marketed_Product__c> marketedProductsArg) {
            this.MarketedProducts = marketedProductsArg;
            this.ProductOptionMarketedProducts = new List<Marketed_Product__c>();

            if (marketedProductsArg == null) {
                return;
            }

            Set<String> productOptionValues = new Set<String>();

            for (Marketed_Product__c mp : marketedProducts) {
                String marketplaceProductOption = mp.Products__r.MarketPlace_Product_Option__c;
                
                if (String.isNotBlank(marketplaceProductOption) &&
                    productOptionValues.contains(marketplaceProductOption) == false) {
                    productOptionValues.add(marketplaceProductOption);
                    this.ProductOptionMarketedProducts.add(mp);
                }
            }
        }
    }
}