public class EmailComponentGetLineItems {
    public Id order_Id 				{ get ; set; }
    public String processing_Type 	{ get ; set; }
    
    public List<OrderLineItemWrapper> OrderLineItems {
        get {
            List<Order_Line_Item__c> lineItems = new List<Order_Line_Item__c>();
            List<OrderLineItemWrapper> wrapper = new List<OrderLineItemWrapper>();
            
            Set<String> fields = new Set<String>();
            
            Set<String> customFields = util.getObjectFields('Order_Line_Item__c');
            Set<String> AccountFields = util.getRelatedFields('Account', 'Account__r');
            Set<String> OppFields = util.getRelatedFields('Opportunity', 'Opportunity__r');
            Set<String> SalesFields = util.getRelatedFields('Branch_Office__c', 'Sales_Office__r');
            Set<String> ColleagueFields = util.getRelatedFields('User', 'Colleague__r');
            
            fields.addAll(customFields);
            fields.addAll(AccountFields);
            fields.addAll(OppFields);
            fields.addAll(SalesFields);
            fields.addAll(ColleagueFields);
            
            String soql = 'SELECT ';
            soql += String.join(new List<String>(fields), ',');
            soql += ', Marketing_Material__r.Customization_Type__c, Marketing_Material__r.Thumbnail_URL__c';
            soql += ' FROM Order_Line_Item__c';
            soql += ' WHERE Order__c =: order_Id';
            if(processing_Type != null)
                soql += ' AND Processing_Type__c =: processing_Type';
			
            lineItems = (List<Order_Line_Item__c>)Database.query(soql);
            system.debug(lineItems);
            
            Map<String, Schema.FieldSet> orderLineItemFieldSetsMap = Order_Line_Item__c.sObjectType.getDescribe().fieldSets.getMap();
            
            for(Order_Line_Item__c item : lineItems)
            {
                Schema.FieldSet orderLineItemFieldSet;
                if(String.isNotBlank(item.Marketing_Material__r.Customization_Type__c))
                {                        
                    orderLineItemFieldSet = orderLineItemFieldSetsMap.get(item.Marketing_Material__r.Customization_Type__c);
                    
                    if (orderLineItemFieldSet == null) {
                        for (Schema.FieldSet fs : orderLineItemFieldSetsMap.values()) {
                            if (fs.getLabel() == item.Marketing_Material__r.Customization_Type__c) {
                                orderLineItemFieldSet = fs;
                                break;
                            }
                        }
                    }
                    
                }
                wrapper.add(new OrderLineItemWrapper(item, orderLineItemFieldSet));
                
            }
            system.debug(wrapper);
            return wrapper;
        }
        
        set;
        
    }
    
	public EmailComponentGetLineItems()
    {
        
    }
    
    public class OrderLineItemWrapper {
        public Order_Line_Item__c OrderLineItem { get; set; }
        public Schema.FieldSet CustomizationFieldSet { get; set; }
        public List<Field> CustomFields { get; set; }
        public List<Field> AccountFields { get; set; }
        public List<Marketed_Product__c> MarketedProducts { get; set; }
        public List<Field> UserFields { get; set; }
        public List<Field> SalesOfficeFields { get; set; }
        
        public OrderLineItemWrapper(Order_Line_Item__c lineItem, Schema.FieldSet customType) {
            OrderLineItem = lineItem;
            CustomizationFieldSet = customType;
            CustomFields = new List<Field>();
            AccountFields = new List<Field>();
            MarketedProducts = new List<Marketed_Product__c>();
            UserFields = new List<Field>();
            SalesOfficeFields = new List<Field>();
            
            if(CustomizationFieldSet != null)
            {
                CustomFields = buildFieldsCollection(lineItem, CustomizationFieldSet, null);
            }
            
            if(lineItem.Account__c != null)
            {
                Schema.FieldSet AccountFieldSet = Schema.SObjectType.Account.fieldSets.Marketplace_Fields;
                AccountFields = buildFieldsCollection(lineItem, AccountFieldSet, 'Account__r');
            }
            
            if(lineItem.Opportunity__c != null)
            {
                MarketedProducts = new List<Marketed_Product__c>();
                List<Enrollment_Form__c> eForm = [SELECT Id FROM Enrollment_Form__c 
                                                  WHERE Enrollment_Opportunity__c =: lineItem.Opportunity__c
                                                  AND RecordType.Name = 'master'];
                
                if(eForm.isEmpty() == false)
                {
                    List<Marketed_Product__c> products = [SELECT Id, Name FROM Marketed_Product__c WHERE Enrollment__c =: eForm[0].Id
                                                          ORDER By Name];
                    MarketedProducts = products;
                }
            }
            
            if(lineItem.Colleague__c != null)
            {
                Schema.FieldSet UserFieldSet = Schema.SObjectType.User.fieldSets.Marketplace_Fields;
                UserFields = buildFieldsCollection(lineItem, UserFieldSet, 'Colleague__r');
            }
            
            if(lineItem.Sales_Office__c != null)
            {
                Schema.FieldSet SalesOfficeFieldSet = Schema.SObjectType.Branch_Office__c.fieldSets.Marketplace_Fields;
                SalesOfficeFields = buildFieldsCollection(lineItem, SalesOfficeFieldSet, 'Sales_Office__r');
            }
        }
        
        private List<Field> buildFieldsCollection(Order_Line_Item__c lineItem, Schema.FieldSet fieldSet, String RelatedFieldAPIName)
        {
            List<Field> fieldCollection = new List<Field>();
            
            for(FieldSetMember fsm : fieldSet.getFields()) 
            {
                String apiFieldName = '';
                if(RelatedFieldAPIName != null)
                	apiFieldName = RelatedFieldAPIName + '.' + fsm.getFieldPath();
                else
                    apiFieldName = fsm.getFieldPath();
                
                Field f = new Field(fsm);
                if(f.Type == 'Reference')
                {
                    SObject lookupRecord = lineItem.getSObject(apiFieldName.Replace('__c', '__r'));
                    if(lookupRecord != null)
                        f.Fieldvalue = lookupRecord.get('Name');
                }
                else if(f.Type == 'Datetime')
                {
                    Object fieldValue = Util.getRecordFieldValue(lineItem, apiFieldName);
                    if(fieldValue != null)
                    {
                        DateTime newDate = (DateTime)fieldValue;
                        String formattedDate = newDate.format('MM/dd/YYYY');
                        f.FieldValue = (Object)formattedDate;
                    }
                }
                else if(f.type == 'Date')
                {
                    Object fieldValue = Util.getRecordFieldValue(lineItem, apiFieldName);
                    if(fieldValue != null)
                    {
                        Date theDate = (Date)fieldValue;
                        String formattedDate = theDate.format();
                        f.FieldValue = (Object)formattedDate;
                    }
                }
                else {
                    Object fieldValue = Util.getRecordFieldValue(lineItem, apiFieldName);
                    f.FieldValue = fieldValue;
                }
                
                fieldCollection.add(f);
            }
            
            return fieldCollection;
        }
    }
}