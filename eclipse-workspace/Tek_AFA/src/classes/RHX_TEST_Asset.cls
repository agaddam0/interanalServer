@isTest
public class RHX_TEST_Asset {
    static testMethod void RHX_Testmethod() {
        try {
            Util u = new Util();
            Id cRType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
            Account a = u.createOneAcc('Test', true, cRType);
            Id pricebookId = Test.getStandardPricebookId();
            
            list<Product2> p = u.createProd(5, 'Test', true);
            for(Product2 p2: p)
            {
                PricebookEntry pbe = u.createPBEntry(true, pricebookId, p2.Id, 100);
            }
            Asset ass = u.createOneAsset(true, a.Id, p[0].Id, 'Test Asset');
                
            List<sObject> sourceList = [SELECT Id, Name 
                FROM Asset LIMIT 1];
            if(sourceList.size() == 0) {
                sourceList.add(
                    new Asset(Name='Test')
                );
            }
            rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
        }
        catch (Exception ex) {}
    }
}