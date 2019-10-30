@isTest(SeeAllData=true)
public class FormStatusTest {
    
    
    static testMethod void FormStatusTester()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; //'Security/Exec Mgmnt' profile is the one who will be transferring ownership of Setup Form records.  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = prof.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
        
        Id customer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        Id awd = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('AWD Enrollment').getRecordTypeId();
        
        Account a = new Account(Name='Test');
        a.RecordTypeId = customer;
        insert a;
        
        Opportunity o = new Opportunity();
        o.RecordTypeId = awd;
        o.OwnerId = u.Id;
        o.Name = 'New AWD';
        o.AccountId = a.Id;
        o.Confirm_New_or_Existing_Group__c = 'New';
        o.What_products_are_you__c = 'Disability; Accident; Cancer; AFA Life; Texas Life; GAP; Group CI; Individual CI; Group HI; Section 125; FSA; HSA; HRA; DVR; Annuities; AF Benefits Market';
        o.Estimated_Close_Date__c = Date.today().addDays(-30);
        o.Plan_Date_New__c = Date.today().addDays(30);
        o.Did_you_sell_a_Private_Exchange__c = 'No';
        o.StageName = 'Enrollment';
        o.CloseDate = Date.today().addDays(30);
        o.Has_Section_125_setup_form__c = true;
        o.Agent_Completing_Vision_Setup__c = true;
        o.Generate_a_Section_125_One_page_summary__c = true;
        
        insert o;
        
        
        PageReference pr = Page.FormStatus;
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        FormStatusCTRL ctrl = new FormStatusCTRL(sc);
        
        system.debug('FormTest: ' + ctrl.fStatus);
    }

}