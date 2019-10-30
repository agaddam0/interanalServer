@isTest
public class RHX_TEST_Goal {
    static testMethod void RHX_Testmethod() {
        try {
            Colleague__c c = new Colleague__c();
            c.Name = 'Test Colleague';
            c.RecordTypeId = Constants.COLLEAGUE_COLLEAGUE;
            insert c;
            
            Goal__c g = new Goal__c();
            g.Colleague__c = c.Id;
            insert g;
            
            List<sObject> sourceList = [SELECT Id 
                FROM Goal__c LIMIT 1];
            if(sourceList.size() == 0) {
                sourceList.add(
                        new Goal__c()
                );
            }
            rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
        }
        catch (Exception ex) {}
    }
}