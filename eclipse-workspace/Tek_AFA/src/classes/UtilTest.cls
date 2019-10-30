@isTest
private class UtilTest {

    static testMethod void myUnitTest() {
        Util u = new Util();
        User u1 = u.createOneUser(true, 'uniqueusernametest@test.com', 'tester'); 
        Enrollment_Form__c ef = u.createOneEnForm(true, u1.Id);
        Id customerAccountRecordTypeId = Constants.ACCOUNT_CUSTOMER_ACCOUNT;

        RecordType assocRT = [SELECT ID FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Association'];
        Account a = u.createOneAcc('name', true, customerAccountRecordTypeId);
        Account AssociationAcct = u.createOneAcc('name', false, assocRT.Id);
        
        AssociationAcct.ShippingCity = 'Oklahoma City';
        AssociationAcct.ShippingState = 'Oklahoma';
        
        insert AssociationAcct;
        
        List<Account> accs = u.createAcc('name', 10, true, customerAccountRecordTypeId);
        
        Test.startTest();
        
        String oppRType = Schema.SObjectType.Opportunity.getRecordTYpeInfosByName().get('AWD New Group').getRecordTypeId();
        Opportunity o = u.createOneOpp('name', 'Prospecting', a.Id, true, oppRType);
        List<Opportunity> opps = u.createOpp('name', 'Prospecting', 10, a.Id, true, oppRType);
        Contact c = u.createOneCont('name','name',a.Id,true);
        List<contact> cons = u.createCont('name',10,a.Id,true);
        OpportunityContactRole ocr = u.createOneOCR('role', c.Id, o.Id, true,true);
        list<OpportunityContactRole> ocrs = u.createOCR(10,o.id, c.Id, 'role',true,true);
        Product2 p = u.createOneProd('name', true);
        List<Product2> prods = u.createProd(10,'name',true);

        Asset ass = u.createOneAsset(true, a.Id, p.Id, 'name');
        list<Asset> assets  = u.createAsset(10, true, 'name', a.id, p.id);
        
        Lead l = u.createOneLead(true,'name','company', AssociationAcct.Id);
        list<Lead> leads =  u.createLeads(10, true, 'name','company', AssociationAcct.Id);
        
        Business_Partner__c bp = u.createOneBP(true, 'name', a.id, a.id);
        
        Test.stopTest();
        
        //OpportunityLineItem oli =  u.createOneOLI(o.Id, Id pbeId,true);
        //Section_125_Setup_Form__c s125 = u.createOneS125(true, ef.Id, u1.Id);
        Section_125_Plan_Summary__c s125PS = u.createOneS125PS(true, ef.Id, u1.Id);
        //Section_125_Plan_Summary__c test = [SELECT Id, OwnerId, Owner.Name FROM Section_125_Plan_Summary__c where id = :s125PS.Id ];
        
        Customer_Setup_Form__c csf = u.createOneCSF(true, ef.Id, u1.Id);
        //Customer_Setup_Form__c testcsf = [SELECT Id, OwnerId, Owner.Name FROM Customer_Setup_Form__c where id = :csf.Id ];
        
        Platform_Setup__c psf = u.createOnePS(true, ef.Id, u1.Id);
        //Platform_Setup__c testpsf = [SELECT Id, OwnerId, Owner.Name FROM Platform_Setup__c where id = :csf.Id ];
        
        
        
    }
}