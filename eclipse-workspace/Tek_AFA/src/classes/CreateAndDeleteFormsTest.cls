@isTest
public with sharing class CreateAndDeleteFormsTest {

	static testmethod void testNewAWDInsert()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
		
		RecordType customer = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account'];
		
		RecordType awd = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'AWD_Enrollment'];
		
		Account a = new Account(Name='Test');
		a.RecordTypeId = customer.Id;
		insert a;
		
		Opportunity o = new Opportunity();
		o.RecordTypeId = awd.Id;
		o.OwnerId = u.Id;
		o.Name = 'New AWD';
		o.AccountId = a.Id;
		o.Confirm_New_or_Existing_Group__c = 'New';
		o.What_products_are_you__c = 'Disability; Accident; Cancer; AFA Life; Texas Life; GAP; Group CI; Individual CI; Group HI; Section 125; FSA; HSA; HRA; DVR; Annuities; AF Benefits Market';
		o.Estimated_Close_Date__c = Date.today().addDays(-30);
		o.Plan_Date_New__c = Date.today().addDays(30);
		o.Did_you_sell_a_Private_Exchange__c = 'No';
		o.StageName = 'Prospecting';
		o.CloseDate = Date.today().addDays(30);
		
		insert o;
		
		Opportunity testOpp = [SELECT Id, Name, Confirm_New_or_Existing_Group__c, What_products_are_you__c, Has_Customer_Setup_form__c,
                               Has_Section_125_setup_form__c FROM Opportunity WHERE Id =: o.Id];
		System.debug(testOpp);
		
        System.Assert(testOpp.Has_Customer_Setup_form__c == true);
        //System.Assert(testOpp.Has_Section_125_setup_form__c == true);
		
	}
	
    static testmethod void testNewAWDUpdate()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
		
		RecordType customer = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account'];
		
		RecordType awd = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'AWD_Enrollment'];
		
		Account a = new Account(Name='Test');
		a.RecordTypeId = customer.Id;
		insert a;
		
		Opportunity o = new Opportunity();
		o.RecordTypeId = awd.Id;
		o.OwnerId = u.Id;
		o.Name = 'New AWD';
		o.AccountId = a.Id;
		o.Confirm_New_or_Existing_Group__c = 'New';
		o.What_products_are_you__c = null;//'Disability; Accident; Cancer; AFA Life; Texas Life; GAP; Group CI; Individual CI; Group HI; Section 125; FSA; HSA; HRA; DVR; Annuities; AF Benefits Market';
		o.Estimated_Close_Date__c = Date.today().addDays(-30);
		o.Plan_Date_New__c = Date.today().addDays(30);
		o.Did_you_sell_a_Private_Exchange__c = 'No';
		o.StageName = 'Prospecting';
		o.CloseDate = Date.today().addDays(30);
		
		insert o;
		
		Opportunity testOpp = [SELECT Id, Name, Confirm_New_or_Existing_Group__c, What_products_are_you__c, Has_Customer_Setup_form__c,
                               Has_Section_125_setup_form__c FROM Opportunity WHERE Id =: o.Id];
		System.debug(testOpp);
		
        System.Assert(testOpp.Has_Customer_Setup_form__c == true);
        System.Assert(testOpp.Has_Section_125_setup_form__c == false);
		
		o.What_products_are_you__c = 'Disability; Accident; Cancer; AFA Life; Texas Life; GAP; Group CI; Individual CI; Group HI; Section 125; FSA; HSA; HRA; DVR; Annuities; AF Benefits Market';
		update o;
        
		Opportunity testOpp2 = [SELECT Id, Name, Confirm_New_or_Existing_Group__c, What_products_are_you__c, Has_Customer_Setup_form__c,
                               Has_Section_125_setup_form__c FROM Opportunity WHERE Id =: o.Id];
		System.debug(testOpp2);
		
        System.Assert(testOpp2.Has_Customer_Setup_form__c == true);
	}
	
    static testmethod void testNewAWDDelete()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
		
		RecordType customer = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account'];
		
		RecordType awd = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'AWD_Enrollment'];
		
		Account a = new Account(Name='Test');
		a.RecordTypeId = customer.Id;
		insert a;
		
		Opportunity o = new Opportunity();
		o.RecordTypeId = awd.Id;
		o.OwnerId = u.Id;
		o.Name = 'New AWD';
		o.AccountId = a.Id;
		o.Confirm_New_or_Existing_Group__c = 'New';
		o.What_products_are_you__c = 'Disability; Accident; Cancer; AFA Life; Texas Life; GAP; Group CI; Individual CI; Group HI; Section 125; FSA; HSA; HRA; DVR; Annuities; AF Benefits Market';
		o.Estimated_Close_Date__c = Date.today().addDays(-30);
		o.Plan_Date_New__c = Date.today().addDays(30);
		o.Did_you_sell_a_Private_Exchange__c = 'No';
		o.StageName = 'Prospecting';
		o.CloseDate = Date.today().addDays(30);
		
		insert o;
		
		Opportunity testOpp = [SELECT Id, Name, Confirm_New_or_Existing_Group__c, What_products_are_you__c, Has_Customer_Setup_form__c,
                               Has_Section_125_setup_form__c FROM Opportunity WHERE Id =: o.Id];
		System.debug(testOpp);
		
        System.Assert(testOpp.Has_Customer_Setup_form__c == true);
		
		o.What_products_are_you__c = null;
		update o;
		
        Opportunity testOpp2 = [SELECT Id, Name, Confirm_New_or_Existing_Group__c, What_products_are_you__c, Has_Customer_Setup_form__c,
                               Has_Section_125_setup_form__c FROM Opportunity WHERE Id =: o.Id];
		System.debug(testOpp2);
		
        System.Assert(testOpp2.Has_Customer_Setup_form__c == true);
        System.Assert(testOpp2.Has_Section_125_setup_form__c == false);
        
	}
    
	static testmethod void testNewAFES()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
		
		RecordType customer = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account'];
		
		RecordType afes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'AFES_Enrollment'];
		
		Account a = new Account(Name='Test');
		a.RecordTypeId = customer.Id;
		insert a;
		
		Opportunity o = new Opportunity();
		o.RecordTypeId = afes.Id;
		o.OwnerId = u.Id;
		o.Name = 'New AWD';
		o.AccountId = a.Id;
		o.Confirm_New_or_Existing_Group__c = 'New';
		o.What_products_are_you__c = 'Disability; Accident; Cancer; AFA Life; Texas Life; GAP; Group CI; Individual CI; Group HI; Section 125; FSA; HSA; HRA; DVR; Annuities; AF Benefits Market';
		o.Estimated_Close_Date__c = Date.today().addDays(-30);
		o.Plan_Date_New__c = Date.today().addDays(30);
		o.Did_you_sell_a_Private_Exchange__c = 'No';
		o.StageName = 'Prospecting';
		o.CloseDate = Date.today().addDays(30);
		
		insert o;
		
        Opportunity testOpp = [SELECT Id, Name, Confirm_New_or_Existing_Group__c, What_products_are_you__c, Has_Customer_Setup_form__c,
                               Has_Section_125_setup_form__c FROM Opportunity WHERE Id =: o.Id];
		System.debug(testOpp);
		
        System.Assert(testOpp.Has_Customer_Setup_form__c == true);
	}
	
	static testmethod void testExistingAWD()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
		
		RecordType customer = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account'];
		
		RecordType awd = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'AWD_Enrollment'];
		
		Account a = new Account(Name='Test');
		a.RecordTypeId = customer.Id;
		insert a;
		
		Opportunity o = new Opportunity();
		o.RecordTypeId = awd.Id;
		o.OwnerId = u.Id;
		o.Name = 'New AWD';
		o.AccountId = a.Id;
		o.Confirm_New_or_Existing_Group__c = 'Existing';
		o.Are_you_making_any_product_changes__c = 'Yes';
		o.What_products_are_you_changing_or_adding__c = null;
		o.Estimated_Close_Date__c = Date.today().addDays(-30);
		o.Plan_Date_New__c = Date.today().addDays(30);
		o.Did_you_sell_a_Private_Exchange__c = 'No';
		o.StageName = 'Prospecting';
		o.CloseDate = Date.today().addDays(30);
		
		insert o;
		
        Opportunity testOpp = [SELECT Id, Name, Confirm_New_or_Existing_Group__c, What_products_are_you__c, Has_Customer_Setup_form__c,
                               Has_Section_125_setup_form__c FROM Opportunity WHERE Id =: o.Id];
		System.debug(testOpp);
		
        System.Assert(testOpp.Has_Customer_Setup_form__c == false);
        System.Assert(testOpp.Has_Section_125_setup_form__c == false);
	}
	
	static testmethod void testExistingAFES()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
		
		RecordType customer = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account'];
		
		RecordType afes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'AFES_Enrollment'];
		
		Account a = new Account(Name='Test');
		a.RecordTypeId = customer.Id;
		insert a;
		
		Opportunity o = new Opportunity();
		o.RecordTypeId = afes.Id;
		o.OwnerId = u.Id;
		o.Name = 'New AWD';
		o.AccountId = a.Id;
		o.Confirm_New_or_Existing_Group__c = 'Existing';
		o.Are_you_making_any_product_changes__c = 'Yes';
		o.What_products_are_you_changing_or_adding__c = 'Disability; Accident; Cancer; AFA Life; Texas Life; GAP; Group CI; Individual CI; Group HI; Section 125; FSA; HSA; HRA; DVR; Annuities; AF Benefits Market';
		o.Estimated_Close_Date__c = Date.today().addDays(-30);
		o.Plan_Date_New__c = Date.today().addDays(30);
		o.Did_you_sell_a_Private_Exchange__c = 'No';
		o.StageName = 'Prospecting';
		o.CloseDate = Date.today().addDays(30);
        // New form generation requirements 2/8/17
        o.Requesting_Open_Enrollment__c = 'Yes';
        o.Are_you_adding_new_plans_or_services__c = 'New Group Plans';
		
		insert o;
		
        Opportunity testOpp = [SELECT Id, Name, Confirm_New_or_Existing_Group__c, What_products_are_you__c, Has_Customer_Setup_form__c,
                               Has_Section_125_setup_form__c FROM Opportunity WHERE Id =: o.Id];
		System.debug(testOpp);
		
        System.Assert(testOpp.Has_Customer_Setup_form__c == true);
	}
	
	static testmethod void testExistingAFESAddingTexasLife()
	{
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
		
		RecordType customer = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account'];
		
		RecordType afes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity' AND DeveloperName = 'AFES_Enrollment'];
		
		Account a = new Account(Name='Test');
		a.RecordTypeId = customer.Id;
		insert a;
		
		Opportunity o = new Opportunity();
		o.RecordTypeId = afes.Id;
		o.OwnerId = u.Id;
		o.Name = 'New AWD';
		o.AccountId = a.Id;
		o.Confirm_New_or_Existing_Group__c = 'Existing';
		o.Are_you_making_any_product_changes__c = 'Yes';
		o.What_products_are_you_changing_or_adding__c = 'Texas Life';
		o.Estimated_Close_Date__c = Date.today().addDays(-30);
		o.Plan_Date_New__c = Date.today().addDays(30);
		o.Did_you_sell_a_Private_Exchange__c = 'No';
		o.StageName = 'Prospecting';
		o.CloseDate = Date.today().addDays(30);
		
		insert o;
		
        Opportunity testOpp = [SELECT Id, Name, Confirm_New_or_Existing_Group__c, What_products_are_you__c, Has_Customer_Setup_form__c,
                               Has_Section_125_setup_form__c, Has_Platform_Setup_Form__c FROM Opportunity WHERE Id =: o.Id];
		System.debug(testOpp);
		
		System.Assert(testOpp.Has_Platform_Setup_Form__c == true);
        System.Assert(testOpp.Has_Customer_Setup_form__c == false);
        System.Assert(testOpp.Has_Section_125_setup_form__c == false);
	}

}