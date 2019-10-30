@isTest
public class RHX_TEST_HRIS_Form {
	static testMethod void RHX_Testmethod() {
	    try {
            Util u = new Util();
	        Id cRType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
	        Account a = u.createOneAcc('Test', true, cRType);
	        HRIS_Form__c hForm = new HRIS_Form__c(Name = 'Test', Account__c = a.Id);
	        insert hForm;
	        
	        List<sObject> sourceList = [SELECT Id 
	            FROM HRIS_Form__c LIMIT 1];
	        if(sourceList.size() == 0) {
	            sourceList.add(
	                    new HRIS_Form__c()
	            );
	        }
	        rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
        }
        catch (Exception ex) {}
    }
}