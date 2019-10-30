@isTest
private class standardLeadBLogicTest {
    
    @testSetup
    private static void testSetup()
    {
        Util u = new Util();
        // Create a customer account to simulate a business partner already tied to one.
        Account customerAccount = AccountTestData.Instance.withRecordTypeId(Constants.ACCOUNT_CUSTOMER_ACCOUNT).insertAccount();
        Account associationAccount = AccountTestData.Instance.withRecordTypeId(Constants.ACCOUNT_ASSOCIATION).withShippingCity('Oklahoma City').withShippingState('OK').insertAccount();
        system.debug('Record Type: ' + customerAccount.Record_Type__c);
        // Create the business partner to simulate an existing business partner
        Business_Partner__c bp = u.createOneBP(true, 'Test Existing Business Partner', customerAccount.Id, associationAccount.Id);
        // Not entirely sure this is needed.. 
        Contact contact = u.createOneCont('Test Existing Contact FirstName', 'Test Existing Contact LastName', customerAccount.Id, true);
    }
    
    // No existing BP record
    static testMethod void positiveMatchOne()
    {
        Util u = new Util();
        
        Account customerAccount = AccountTestData.Instance.withRecordTypeId(Constants.ACCOUNT_CUSTOMER_ACCOUNT).insertAccount();
        Account associationAccount = AccountTestData.Instance.withRecordTypeId(Constants.ACCOUNT_ASSOCIATION).withShippingCity('Edmond').withShippingState('OK').insertAccount();
        
        
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        
        list<Lead> leadsToConvert = new list<Lead>();
        leadsToConvert = u.CreateLeads(1, false, 'Test Apex lName', 'Test Apex companyName', associationAccount.Id);
        
        for(Lead l : leadsToConvert)
        {
            l.Industry = 'Education';
            l.State = 'OK';
            l.City = 'Edmond';
        }
        
        insert leadsToConvert;
        
        for(Lead l : leadsToConvert)
        {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setAccountId(customerAccount.Id);
            lc.setContactId(c.Id);
            lc.setLeadId(l.id);
            
            test.startTest();
            
            list<LeadStatus> convertStatus = [Select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true];
            for(LeadStatus ls : convertStatus)
            {
                lc.setConvertedStatus(ls.MasterLabel);  
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                System.assert(lcr.isSuccess());
            }   
            test.stopTest();
        }   
        
        list<Business_Partner__c> bpTest = [SELECT Id, Name FROM Business_Partner__c WHERE Account__c =: customerAccount.Id];
        System.debug('TEST BPs ---> ' + bpTest);
        System.assertEquals(1, bpTest.size());
    }
    
    // BP record already existst
    static testMethod void negativeMatchOne()
    {
        Util u = new Util();
        
        Account assoc = [SELECT Id FROM Account WHERE RecordTypeId =: Constants.ACCOUNT_ASSOCIATION LIMIT 1];
        Account existing = [SELECT Id FROM Account WHERE RecordTypeId =: Constants.ACCOUNT_CUSTOMER_ACCOUNT LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        
        list<Lead> leadsToConvert = new list<Lead>();
        leadsToConvert = u.CreateLeads(1, false, 'Test Apex lName', 'Test Apex companyName', assoc.Id);        
        
        for(Lead l : leadsToConvert)
        {
            l.Industry = 'Education';
            l.State = 'OK';
            l.City = 'Oklahoma City';
        }
        
        insert leadsToConvert;
        
        
        for(Lead l : leadsToConvert)
        {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setAccountId(existing.Id);
            lc.setContactId(c.Id);
            lc.setLeadId(l.id);
            
            test.startTest();
            
            list<LeadStatus> convertStatus = [Select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true];
            for(LeadStatus ls : convertStatus)
            {
                lc.setConvertedStatus(ls.MasterLabel);  
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                System.assert(lcr.isSuccess());
            }  
            
            test.stopTest();
        }   
        
        list<Business_Partner__c> bpTest = [SELECT Id, Name FROM Business_Partner__c where Account__c =: existing.Id];
        System.debug('TEST BPs ---> ' + bpTest);
        System.assertEquals(1, bpTest.size());
    }
}