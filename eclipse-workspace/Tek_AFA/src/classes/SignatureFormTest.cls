@isTest
public class SignatureFormTest {
    
    @testSetup
    static void TestData()
    {
        // Pull Profile
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        // Create a user
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName = 'Test', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = prof.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='Test@etheriosTest.com');
        insert u;
        
        // Get RecordTypeIds
        Id customer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id awdId = Schema.SObjectType.Opportunity.getRecordTYpeInfosByName().get('AWD Enrollment').getRecordTYpeId();
        
        // Create Account
        Account a = new Account(Name='Test');
        a.RecordTypeId = customer;
        insert a;
        
        // Create Contact
        Contact con = new COntact(FirstName='Test',LastName='Test',AccountId=a.id);
        insert con;
        
        // Create Opportunity
        Opportunity o = new Opportunity();
        o.RecordTypeId = awdId;
        o.OwnerId = u.Id;
        o.Name = 'New AWD';
        o.AccountId = a.Id;
        o.Confirm_New_or_Existing_Group__c = 'New';
        o.Estimated_Close_Date__c = Date.today().addDays(-30);
        o.Plan_Date_New__c = Date.today().addDays(30);
        o.Did_you_sell_a_Private_Exchange__c = 'No';
        o.StageName = 'Prospecting';
        o.CloseDate = Date.today().addDays(30);
        o.Are_you_making_any_billing_changes__c	= null;
        o.Requesting_Open_Enrollment__c = null;
        o.administrative_contact__c = con.id;
        o.Has_Section_125_setup_form__c = true;
        insert o;       
        
        /* create product catalog */
        List<Product_Catalog__c> pCatalog = new List<Product_Catalog__c>();
        pCatalog.add(createProduct('Dependent Verification Review','Service'));
        pCatalog.add(createProduct('Health FSA','Service'));
        pCatalog.add(createProduct('Flex Card','Service'));
        pCatalog.add(createProduct('Section 125','Service'));
        pCatalog.add(createProduct('Long-Term Disability','Benefit'));
        insert pCatalog;
        
    }
    
    private static Product_Catalog__c createProduct(string Name, string Type ) {
        Product_Catalog__c pc = new Product_Catalog__c (
            name = name, status__c = 'Active', type__c = type, Tax_Treatment__c = 'Both', Plan_Status__c = 'New',Division_Availability__c='Both');
        
        return pc;
        
    }
    
    private static testMethod void testServiceExchangeAgreementCreated()
    {
        // Retrieve opportunity we created in test setup
        String soql = Util.getCreatableFields('Opportunity');
        soql += 'FROM Opportunity';
        List<Opportunity> opps = database.query(soql);
        
        Opportunity o = opps[0];
        
        Enrollment_Form__c eForm = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c =: o.Id];
        
        Product_Catalog__c pCat = [SELECT Id, Tax_Treatment__c, Plan_Status__c FROM Product_Catalog__c WHERE Name = 'Section 125'];
        
        Marketed_Product__c mp = new Marketed_Product__c();
        mp.Products__c = pCat.Id;
        mp.Plan_Status__c = 'New';
        mp.Tax_Treatment__c = pCat.Tax_Treatment__c;
        mp.Enrollment__c = eForm.Id;
        
        insert mp;
        
        List<Enrollment_Form__c> signatureForms = [SELECT Id, Name, RecordType.Name FROM Enrollment_Form__c WHERE RecordType.Name != 'Master'];
        
        system.assertEquals(1, signatureForms.size());
        system.assertEquals('Service Exchange Agreement', signatureForms[0].RecordType.Name);
    }
    
    private static testMethod void testServiceExchangeAgreementNOTCreated()
    {
        // Retrieve opportunity we created in test setup
        String soql = Util.getCreatableFields('Opportunity');
        soql += 'FROM Opportunity';
        List<Opportunity> opps = database.query(soql);
        
        Opportunity o = opps[0];
        
        Enrollment_Form__c eForm = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c =: o.Id];
        
        Product_Catalog__c pCat = [SELECT Id, Tax_Treatment__c, Plan_Status__c FROM Product_Catalog__c WHERE Name = 'Section 125'];
        
        Marketed_Product__c mp = new Marketed_Product__c();
        mp.Products__c = pCat.Id;
        mp.Plan_Status__c = 'Existing';
        mp.Tax_Treatment__c = pCat.Tax_Treatment__c;
        mp.Enrollment__c = eForm.Id;
        
        insert mp;
        
        List<Enrollment_Form__c> signatureForms = [SELECT Id, Name, RecordType.Name FROM Enrollment_Form__c WHERE RecordType.Name != 'Master'];
        
        system.assertEquals(0, signatureForms.size());
    }
    
    private static testMethod void testSubscriptionAgreementCreated()
    {
        // Retrieve opportunity we created in test setup
        String soql = Util.getCreatableFields('Opportunity');
        soql += 'FROM Opportunity';
        List<Opportunity> opps = database.query(soql);
        
        Opportunity o = opps[0];
        
        Enrollment_Form__c eForm = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c =: o.Id];
        
        Product_Catalog__c pCat = [SELECT Id, Tax_Treatment__c, Plan_Status__c FROM Product_Catalog__c WHERE Name = 'Long-Term Disability'];
        
        Marketed_Product__c mp = new Marketed_Product__c();
        mp.Products__c = pCat.Id;
        mp.Plan_Status__c = 'New';
        mp.Tax_Treatment__c = pCat.Tax_Treatment__c;
        mp.Enrollment__c = eForm.Id;
        
        insert mp;
        
        List<Enrollment_Form__c> signatureForms = [SELECT Id, Name, RecordType.Name FROM Enrollment_Form__c WHERE RecordType.Name != 'Master'];
        
        system.assertEquals(0, signatureForms.size());
        
        Customer_Setup_Form__c cForm = [SELECT Id, GrpProdTrustOrDirect__c
                                        FROM Customer_Setup_Form__c
                                        WHERE Enrollment_Form__c =: eForm.Id];
        cForm.GrpProdTrustOrDirect__c = 'Trust';
        update cForm;
        
        signatureForms = [SELECT Id, Name, RecordType.Name FROM Enrollment_Form__c WHERE RecordType.Name != 'Master'];
        
        system.assertEquals(1, signatureForms.size());
        system.assertEquals('Subscription Agreement', signatureForms[0].RecordType.Name); 
    } 
    
    private static testmethod void TestSignaturePage()
    {
        String soql = Util.getCreatableFields('Opportunity');
        soql += 'FROM Opportunity';
        List<Opportunity> opps = database.query(soql);
        
        Opportunity o = opps[0];
        
        Enrollment_Form__c eForm = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c =: o.Id];
        
        Product_Catalog__c pCat = [SELECT Id, Tax_Treatment__c, Plan_Status__c FROM Product_Catalog__c WHERE Name = 'Section 125'];
        
        Marketed_Product__c mp = new Marketed_Product__c();
        mp.Products__c = pCat.Id;
        mp.Plan_Status__c = 'New';
        mp.Tax_Treatment__c = pCat.Tax_Treatment__c;
        mp.Enrollment__c = eForm.Id;
        
        insert mp;
        
        pCat = [SELECT Id, Tax_Treatment__c, Plan_Status__c FROM Product_Catalog__c WHERE Name = 'Health FSA'];
        
        mp = new Marketed_Product__c();
        mp.Products__c = pCat.Id;
        mp.Plan_Status__c = 'New';
        mp.Tax_Treatment__c = pCat.Tax_Treatment__c;
        mp.Enrollment__c = eForm.Id;
        
        insert mp;
        
        PageReference sigPage = Page.FormSignatureCapture;
        Test.setCurrentPage(sigPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(eForm);
        PDFCreateController ext = new PDFCreateController(sc);
        
        ext.formSelect[0].selected = true;
        ext.generateNewForms();
        
        Enrollment_Form__c sigForm = [SELECT Id FROM Enrollment_Form__c WHERE Auto_Generated__c = false LIMIT 1];
        ext.deleteId = sigForm.Id;
        ext.deleteEnrollmentForm();
    }
    
    private static testMethod void testSignaturePDFController()
    {
        String soql = Util.getCreatableFields('Opportunity');
        soql += 'FROM Opportunity';
        List<Opportunity> opps = database.query(soql);
        
        Opportunity o = opps[0];
        
        Enrollment_Form__c eForm = [SELECT Id FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c =: o.Id];
        
        Product_Catalog__c pCat = [SELECT Id, Tax_Treatment__c, Plan_Status__c FROM Product_Catalog__c WHERE Name = 'Section 125'];
        
        Marketed_Product__c mp = new Marketed_Product__c();
        mp.Products__c = pCat.Id;
        mp.Plan_Status__c = 'New';
        mp.Tax_Treatment__c = pCat.Tax_Treatment__c;
        mp.Enrollment__c = eForm.Id;
        
        insert mp;
        
        PageReference sigPage = Page.InKindTrustSubscriptionPDF;
        Test.setCurrentPage(sigPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(eForm);
        SignatureFormPDFext ext = new SignatureFormPDFext(sc);
    }
}