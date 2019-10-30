@isTest(SeeAllData=true)
public class RHX_TEST_Policy_History {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Policy_History__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Policy_History__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}