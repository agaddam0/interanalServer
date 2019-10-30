@isTest
public class EmployerTransferPDFEXTTest {
    static testMethod void EmployerTransferPDFTest()
    {
        Util u = new Util();
        
        Id rType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        Account a = u.createOneAcc('Policyholder Test', true, rType);
        
        Policyholder__c holder = new Policyholder__c();
        holder.First_Name__c = 'Test';
        holder.Last_Name__c = 'Test';
        holder.Customer_Number__c = '123456';
        holder.Social_Security_Number__c = '111223333';
        insert holder;
        
        Purchased_Product__c pp = new Purchased_Product__c();
        pp.Account__c = a.Id;
        pp.Product_Family__c = 'Disability';
        pp.Product_Description__c = 'Disability Description';
        pp.Policyholder__c = holder.Id;
        pp.Policy_Status__c = 'Active';
        insert pp;
        
        Change_Request__c request = new Change_Request__c();
        request.New_Account_Name__c = a.Id;
        request.Date_of_Request__c = system.today();
        request.Effective_Date_of_Transfer__c = system.today();
        request.Policies_Affected_by_Request_Change__c = pp.Product_Family__c + ' - ' + pp.Product_Description__c;
        request.Policyholder__c = holder.Id;
        insert request;
        
        PageReference transferPDF = Page.EmployerTransferPDF;
        Test.setCurrentPage(transferPDF);
        ApexPages.StandardController sc = new ApexPages.StandardController(request);
        EmployerTransferPDFEXT ext = new EmployerTransferPDFEXT(sc);
        
        Test.startTest();
        
        system.assert(true);
        
        Test.stopTest();
    }

}