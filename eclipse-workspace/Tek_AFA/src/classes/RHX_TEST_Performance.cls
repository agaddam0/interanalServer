@isTest
public class RHX_TEST_Performance {
    static testMethod void RHX_Testmethod() {
        try {
            Colleague__c c = new Colleague__c();
            c.Name = 'Test Colleague';
            c.RecordTypeId = Constants.COLLEAGUE_COLLEAGUE;
            insert c;
            
            Performance__c p = new Performance__c();
            p.Colleague__c = c.Id;
            insert p;
            
            List<sObject> sourceList = [SELECT Id 
                FROM Performance__c LIMIT 1];
            if(sourceList.size() == 0) {
                sourceList.add(
                        new Performance__c()
                );
            }
            rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
        }
        catch (Exception ex) {}
    }
}