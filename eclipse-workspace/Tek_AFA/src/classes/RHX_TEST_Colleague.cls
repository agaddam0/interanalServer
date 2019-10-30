@isTest
public class RHX_TEST_Colleague {
    static testMethod void RHX_Testmethod() {
        try {
            Colleague__c c = new Colleague__c();
            c.Name = 'Test Colleague';
            c.RecordTypeId = Constants.COLLEAGUE_COLLEAGUE;
            insert c;
            
            List<sObject> sourceList = [SELECT Id 
                FROM Colleague__c LIMIT 1];
            if(sourceList.size() == 0) {
                sourceList.add(
                        new Colleague__c()
                );
            }
            rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
        }
        catch (Exception ex) {}
    }
}