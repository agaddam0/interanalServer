/*********************************************************************************************
// Version:             1.0
// Author:              Etherios
// Date Created:        1/13/2015
// Description:         Utility class used for Test classes in creating Object Records
//                      Objects include:
//                                      Account, Contact, Opportunity, & OpportunityContactRole
//   
// Copyright 2015 Etherios. All rights reserved. Customer confidential. Do not distribute.
//
// Revision History
// DATE               AUTHOR                    REQUIREMENT#          DETAILS
// 1/13/2015         Brian Knowlton                                   Utility class that allows easy and 
//                                                                    fast creation of object records.
//
// *********************************************************************************************
// ********************************************************************************************/
global without sharing class Util {

    /* Create one Opportunity */
    public Opportunity createOneOpp(String name, String stageName, Id AccountId, Boolean doInsert, Id recTypeId)
    {
        Opportunity o = new Opportunity();
        o.Name = name;
        o.CloseDate = Date.today().addDays(30);
        o.StageName = stageName;

        if(StageName == 'Closed Won') {
            // Required fields from Validation Rule AFES_New_Group_Closed_Won_Required_Field
            o.Estimated_Employees__c = 100;
            o.Estimated_Premium__c = 10.00;
            o.Why_did_the_Employer_choose_AFA__c = 'Test';
            o.New_Products_to_the_Employer__c = 'Test';
            o.What_s_the_Employer_s_3_5_year_strategy__c = 'Test';
            o.How_will_we_help_achieve_this_strategy__c = 'Test';
            o.Dynamics_of_Roles_at_the_Employer__c = 'Test';
        }
        
        o.AccountId = AccountId;
        o.Enrollment_Month__c = 'February';
        if(recTypeId != null){
             o.RecordTypeId = recTypeId;
        }
        if(doInsert) insert o;
        return o;
    }
    
    /* Create a list of Opportunity Records to be inserted */
    
    public list<Opportunity> createOpp(String prefix, String stageName, Integer count, Id AccountId, Boolean doInsert, Id recTypeId)
    {
        list<Opportunity> newOpp = new list<Opportunity>();
        for(Integer i = 0; i < count; i++)
        {
            newOpp.add(createOneOpp(prefix + ' ' + i, stageName, AccountId, false, recTypeId));         
        }
        if(doInsert) insert newOpp;
        
        return newOpp;
    }
    
    /* Create one Account */
    public Account createOneAcc(String name, Boolean doInsert, Id recTypeId)
    {
        Account a = new Account();
        a.Name = name;
        if(null != recTypeId)
        	a.RecordTypeId = recTypeId;
        if(doInsert) insert a;
        return a;
    }
    
    /* Create a list of Accounts to be inserted */
    public list<Account> createAcc(String prefix, Integer count, Boolean doInsert, Id recTypeId)
    {
        list<Account> newAcc = new list<Account>();
        
        for(Integer i = 0; i < count; i++)
        {
            newAcc.add( createOneAcc(prefix + ' ' + i, false, recTypeId) );
        }
        
        if(doInsert) insert newAcc;
        return newAcc;
    }
    
    
    /* Create one Contact */
    public Contact createOneCont(String fname, String lname, Id AccountId, Boolean doInsert)
    {
        Contact c = new Contact();
        c.FirstName = fname;
        c.LastName = lname;
        c.AccountId = AccountId;
        c.Phone = '(111) 111-1111';
        c.Fax = '(111) 111-1111';
        c.OtherPhone = '(111) 111-1111';
        c.HomePhone = '(111) 111-1111';
        c.MobilePhone = '(111) 111-1111';
        c.OtherPhone = '(111) 111-1111';
        c.AssistantPhone = '(111) 111-1111';

        if(doInsert) insert c;
        return c;
    }
    /* Create a list of Contacts to be inserted */
    public list<Contact> createCont(String prefix, Integer count, Id AccountId, Boolean doInsert)
    {
        list<Contact> newCont = new list<Contact>();
        
        for(Integer i=0; i<count; i++)
        {
            newCont.add( createOneCont(string.valueOf(i), prefix + ' ' + i, AccountId, false) );
        }

        if(doInsert) insert newCont;
        return newCont;
    }
    
    /* Create One Opp Contact Role */
    public OpportunityContactRole createOneOCR(String Role, Id ContactId, Id OpportunityId, Boolean isPrimary, Boolean doInsert)
    {
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.Role = Role;
        ocr.ContactId = ContactId;
        ocr.OpportunityId = OpportunityId;
        ocr.IsPrimary = isPrimary;
        
        if(doInsert) insert ocr;
        return ocr;
    }
    
    /* Create a list of Opportunity Contact Roles to be inserted */
    public list<OpportunityContactRole> createOCR(Integer count, Id OpportunityId, Id ContactId, String role, Boolean isPrimary, Boolean doInsert)
    {
        list<OpportunityContactRole> ocr = new list<OpportunityContactRole>();
        
        for(Integer i = 0;i<count;i++)
        {
            ocr.add( createOneOCR(role, ContactId, OpportunityId, isPrimary, false) );
        }
        
        if(doInsert) insert ocr;
        return ocr;
    }
    
    /* Create One OLI */
    public OpportunityLineItem createOneOLI(Id oppId, Id pbeId, Boolean doInsert)
    {
        OpportunityLineItem oli = new OpportunityLineItem( );
        oli.OpportunityId = oppId;
        oli.Quantity = 2;
        oli.UnitPrice = 100;
        oli.PricebookEntryId = pbeId;
        if(doInsert) insert oli;
        return oli;
    }
    
    /* Create MultipleOli */
    public list<OpportunityLineItem> createOLI(Integer count, Id oppId, Id pbeId, Boolean doInsert)
    {
        list<OpportunityLineItem> oli = new list<OpportunityLineItem>();
        
        for(Integer i = 0; i < count; i++)
        {
            oli.add( createOneOLI( oppId, pbeId, false) );
        }
        
        if(doInsert) insert oli;
        return oli;
    }
    
    /* Create One Product2 */
    public Product2 createOneProd(String name, Boolean doInsert)
    {
        Product2 p = new Product2();
        p.Name = name;
        p.IsActive = true;
        
        if(doInsert) insert p;
        return p;
    }
    
    /* Create list Prod2 */
    public list<Product2> createProd(Integer count, String prefix, Boolean doInsert)
    {
        list<Product2> p = new list<Product2>();
        
        for(Integer i = 0; i < count; i++)
        {
            p.add( createOneProd(prefix + ' ' + i, false) );
        }
        if(doInsert) insert p;
        return p;
    }
    
    /* Create standard price book */
    public PricebookEntry createPBEntry(Boolean doInsert, Id pbId, Id prodId, Integer unitPrice)
    {
        PricebookEntry pb = new PricebookEntry(
                                                Pricebook2Id = pbId,
                                                Product2Id = prodId,
                                                UnitPrice = unitPrice,
                                                isActive = true);
        if(doInsert) insert pb;
        return pb;
    }
    
    /* Create One Asset */
    public Asset createOneAsset(Boolean doInsert, Id accId, Id prodId, String name)
    {
        Asset a = new Asset(Name = name, AccountId = accId, Product2Id = prodId);
        
        if(doInsert) insert a;
        return a;
    }
    
    /* List of Assets */
    public list<Asset> createAsset(Integer howMany, Boolean doInsert, String prefix, Id accId, Id prodId)
    {
        list<Asset> asset = new list<Asset>();
        for(Integer i = 0; i < howMany; i++)
        {
            asset.add( createOneAsset(false, accId, prodId, prefix + ' ' + i) );
        }
        if(doInsert) insert asset;
        return asset;
    }
    
    /* Create One Asset overloaded method to specify record type */
    public Asset createOneAsset(Boolean doInsert, Id accId, Id prodId, String name, Id rType)
    {
        Asset a = new Asset(Name = name, AccountId = accId, Product2Id = prodId, RecordTypeId = rType);
        
        if(doInsert) insert a;
        return a;
    }
    
    /* List of Assets overloaded method to specify record type */
    public list<Asset> createAsset(Integer howMany, Boolean doInsert, String prefix, Id accId, Id prodId, Id rType)
    {
        list<Asset> asset = new list<Asset>();
        for(Integer i = 0; i < howMany; i++)
        {
            asset.add( createOneAsset(false, accId, prodId, prefix + ' ' + i, rType) );
        }
        if(doInsert) insert asset;
        return asset;
    }
    
    /* Create One Lead */
    public Lead createOneLead(Boolean doInsert, String lName, String company, Id assId)
    {
        Lead l = new Lead(LastName = lName, Company = company, Association__c = assId);
        
        l.Phone = '(111) 111-1111';
        l.Fax = '(111) 111-1111';
        //l.OtherPhone = '(111) 111-1111';
        //l.HomePhone = '(111) 111-1111';
        l.MobilePhone = '(111) 111-1111';
        //l.OtherPhone = '(111) 111-1111';
        //l.AssistantPhone = '(111) 111-1111';
        
        if(doInsert) insert l;
        return l;
    }
    
    /* create multiple leads */
    public list<Lead> createLeads(Integer howMany, Boolean doInsert, String lName, String company, Id assId)
    {
        list<Lead> lead = new list<Lead>();
        for (Integer i = 0;i<howMany; i++)
        {
            lead.add( createOneLead(false, lName + ' ' + i, company + ' ' + i, assId) );
        }
        if(doInsert) insert lead;
        return lead;
    }
    
    public Business_Partner__c createOneBP(Boolean doInsert, String name, Id accId, Id assId)
    {
        Business_Partner__c bp = new Business_Partner__c();
        //bp.Name = name;
        bp.Account__c = accId;
        bp.Business_Partner__c = assId;
        
        if(doInsert) insert bp;
        return bp;
    }
    
    public Enrollment_Form__c createOneEnForm(Boolean doInsert,  Id userId)
    {
        Enrollment_Form__c ef = new Enrollment_Form__c();
        //ef.Enrollment_Opportunity__c = opptyId;
        ef.OwnerId = userId;
        //ef.Customer_Setup_Owner__c = userId; 
        //ef.Platform_Setup_Owner__c = userId;
        //ef.Section_125_Owner__c = userId;
        
        if(doInsert) insert ef;
        return ef;
    }
    
    public User createOneUser(Boolean doInsert, String userName, String name) 
    {
        system.debug('### userName = ' + userName);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName = name, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=userName);
            
        if(doInsert) insert u;
        return u;    
    }
    
    public Customer_Setup_Form__c createOneCSF(Boolean doInsert, Id enFormId, Id ownerId) 
    {
        Customer_Setup_Form__c csf = new Customer_Setup_Form__c();
        csf.Enrollment_Form__c = enFormId;
        csf.OwnerId = ownerId;
        csf.Status__c = 'Completed';
        
        if(doInsert) insert csf;
        return csf;
    }
    
    public Platform_Setup__c createOnePS(Boolean doInsert, Id enFormId, Id ownerId) 
    {
        Platform_Setup__c ps = new Platform_Setup__c();
        ps.OwnerId = ownerId;
        ps.Enrollment_Form__c = enFormId;
        ps.Status__c = 'Completed';
        ps.Type_of_Update__c = 'Admin';
        if(doInsert) insert ps;
        return ps;
    }
    
    public Section_125_Setup_Form__c createOneS125(Boolean doInsert, Id enFormId, Id ownerId) 
    {
        Section_125_Setup_Form__c s125 = new Section_125_Setup_Form__c();
        s125.OwnerId = ownerId;
        s125.Enrollment_Form__c = enFormId;
        s125.Status__c = 'Completed';
        if(doInsert) insert s125;
        return s125;
    }   
    
    public Section_125_Plan_Summary__c createOneS125PS(Boolean doInsert, Id enFormId, Id ownerId) 
    {
        Section_125_Plan_Summary__c s125PS = new Section_125_Plan_Summary__c();
        s125PS.OwnerId = ownerId;
        s125PS.Enrollment_Form__c = enFormId;
        s125PS.Status__c = 'Completed';
        if(doInsert) insert s125PS;
        return s125PS;
    }
    
    public List<Colleague__c> createColleagues(Id RecordTypeId, Boolean doInsert, Integer num)
    {
        List<Colleague__c> colleagues = new List<Colleague__c>();
        
        for(Integer i = 0; i < num; i++)
        {
            Colleague__c c = new Colleague__c();
            c.Name = 'Test Colleague ' + i;
            c.RecordTypeId = RecordTypeId;
            colleagues.add(c);
        }
        
        if(doInsert && colleagues.size() > 0)
            insert colleagues;
            
        return colleagues;
    }
    
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){

        if (whereClause == null || whereClause == ''){ return null; }
        
        String selects = getCreatableFieldsInSOQL(objectName);
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
    }
    
    public static string getCreatableFieldsAndFieldSetSOQL(String objectName, String whereClause, Schema.FieldSet fieldSet) {
        Set<String> fieldsToUse = getObjectCreatableFields(objectName);
        fieldsToUse.addAll( getFieldSetFields(fieldSet) );
        
        String selects = string.join(new List<String>(fieldsToUse), ',');
        
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
    }
    
    public static string getCreatableFields(String objectName){
         
        String selects = getCreatableFieldsInSOQL(objectName);
         
        return 'SELECT ' + selects + ' ';
    }
    
    public static string getCreatableFieldsInSOQL(String objectName) {
        Set<string> creatableFields = getObjectCreatableFields(objectName);
        
        return String.join(new List<String>(creatableFields), ',');
    }
    
    public static Set<String> getObjectCreatableFields(String objectName) {
        Set<String> creatableFields = new Set<String>();
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        
        if (fieldMap == null) {
            return creatableFields;
        }
         
        for (Schema.SObjectField ft : fieldMap.values()){
            Schema.DescribeFieldResult fd = ft.getDescribe();
            if (fd.isCreateable()){
                if(fd.getName() != 'BillingGeocodeAccuracy' && fd.getName() != 'ShippingGeocodeAccuracy' && fd.getName() != 'OtherGeocodeAccuracy'
                && fd.getName() != 'MailingGeocodeAccuracy'){
                    creatableFields.add(fd.getName());
                }
            }
        }
        
        return creatableFields;
    }
    
    public static string getFields(String objectName) {
        String selects = getFieldsInSOQL(objectName);
         
        return 'SELECT ' + selects + ' ';
    }
    
    public static string getFieldsInSOQL(String objectName) {
        Set<String> objectFields = getObjectFields(objectName);
        
        return String.join(new List<String>(objectFields), ',');
    }
    
    public static Set<String> getObjectFields(String objectName) {
        Set<String> fields = new Set<String>();
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        
        if (fieldMap == null) {
            return fields;
        }
         
        for (Schema.SObjectField ft : fieldMap.values()){
            Schema.DescribeFieldResult fd = ft.getDescribe();
            String fieldName = fd.getName();
            
            fields.add(fieldName);
            
            List<Schema.sObjectType> referenceTos = fd.getReferenceTo();
            
            if (fd.isCustom() && referenceTos != null && referenceTos.size() > 0) {
                fields.add(fieldName.replace('__c', '__r.Name'));
            }
        }
        
        return fields;
    }
    
    public static Set<String> getRelatedFields(String ObjectName, String relatedField) {
        Set<String> relatedFields = new Set<String>();
        Set<String> fields = getObjectFields(ObjectName);
        
        for(string fieldName : fields)
        {
            String relatedName = relatedField + '.' + fieldName;
            relatedFields.add(relatedName);
        }
        
        return relatedFields;
    }
    
    public static Set<String> getFieldSetFields(Schema.FieldSet fieldSet) {
        if (fieldSet == null) {
            return new Set<String>();
        }
        
        return getFieldSetFields(new List<Schema.FieldSet>{ fieldSet });
    }
    
    public static Set<String> getFieldSetFields(List<Schema.FieldSet> fieldSets) {
        Set<String> fieldNames = new Set<String>();
        
        if (fieldSets == null) {
            return fieldNames;
        }
        
        for (Schema.FieldSet fieldSet : fieldSets) {
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                fieldNames.add(field.getFieldPath());
            }
        }
        
        return fieldNames;
    }
    
    public static set<String> getFieldsForQuerying(List<Field> fields) {
        Set<String> selectFields = new Set<String>();
        
        for (Field f : fields) {
            selectFields.add(f.APIName);
        }
        
        return selectFields;
    }
    
    public static Schema.DescribeFieldResult getFieldDescribe(String fieldPath, Map<String, Schema.SObjectField> objectFields) {
        if (fieldPath.contains('.')) {
            List<String> fieldParts = fieldPath.split('\\.');
            
            String lookupField = fieldParts[0];
            
            if (lookupField.endsWith('__r')) {
                lookupField = lookupField.replace('__r', '__c');
            }
            else {
                lookupField += 'Id';
            }
            
            Schema.DescribeFieldResult lookupFieldDesc = objectFields.get(lookupField).getDescribe();
            
            List<Schema.sObjectType> referenceTos = lookupFieldDesc.getReferenceTo();
            
            Schema.sObjectType parentReference = referenceTos[0];
            Schema.DescribeSObjectResult describe = parentReference.getDescribe();
            Map<String, Schema.SObjectField> referenceObjectFields = describe.fields.getMap();
            
            String parentField = fieldParts[1];
            
            return referenceObjectFields.get(parentField).getDescribe();
        }
        
        return objectFields.get(fieldPath).getDescribe();
    }
    
    public static Object getRecordFieldValue(SObject sourceRecord, String soqlField) {
        if (soqlField.containsIgnoreCase('.') == false) {
            return sourceRecord.get(soqlField);
        }
        
        // Split uses a regular expression so have to escape the period to make it a literal period
        // and not any character.
        List<String> fieldParts = soqlField.split('\\.');
        
        SObject parentRecord = sourceRecord;
        Integer lastFieldPartIndex = fieldParts.size() - 1;
        
        for (Integer i = 0; i < lastFieldPartIndex; ++i) {
            String reference = fieldParts[i];
            parentRecord = parentRecord.getSObject(reference);
        }
        
        String lastFieldPart = fieldParts[lastFieldPartIndex];
        
        Object fieldValue = parentRecord.get(lastFieldPart);
        
        if (soqlField == 'CreatedDate') {
            Date createdDate = (Date) fieldValue;
            fieldValue = createdDate.format();
        }
        
        return fieldValue;
    }

    public static User getAnActiveSystemAdministrator() {
        return
        [SELECT Id,
                Name
           FROM User
          WHERE Profile.Name = 'System Administrator'
            AND IsActive = true
          LIMIT 1];
    }

    public static User getAnActiveSystemAdministratorThatsNotMe() {
        return
        [SELECT Id,
                Name
           FROM User
          WHERE Profile.Name = 'System Administrator'
            AND IsActive = true
            AND Id != :UserInfo.getUserId()
          LIMIT 1];
    }

    public static Integer calculateWorkingDays(Date startDate, Date endDate){
        Integer workingDays = 0;

        for(integer i = 0; i <= startDate.daysBetween(endDate - 1); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday') {  
                workingDays = workingDays + 1;  
            }  
        }
        
        return workingDays;
    }
}