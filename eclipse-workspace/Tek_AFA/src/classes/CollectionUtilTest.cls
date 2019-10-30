@isTest
public class CollectionUtilTest {
    @isTest
    static void getLookupIds_singleRecordSingleLookup_expectOneIdReturnedTest() {
        Account acct = AccountTestData.Instance.insertAccount();
        Contact contact = new Contact(AccountId = acct.Id);
        
        Set<Id> acctIds = CollectionUtil.getLookupIds(new List<Contact>{ contact }, 'AccountId');
        
        system.assert(acctIds.size() > 0, 'There are no account ids.');
        system.assert(acctIds.contains(acct.Id), 'The account id was not found on the contact.');
    }
    
    @isTest
    static void getLookupIds_singleRecordSingleLookupAndLookupFieldNull_expectNoIdReturnedTest() {
        Contact contact = new Contact(AccountId = null);
        
        Set<Id> acctIds = CollectionUtil.getLookupIds(new List<Contact>{ contact }, 'AccountId');
        
        system.assertEquals(0, acctIds.size(), 'There is an account id when there should be none.');
    }
    
    @isTest
    static void getLookupIds_singleRecordMultipleLookups_expectIdReturnedTest() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
        
        Enrollment_Form__c ef = 
        [SELECT Enrollment_Opportunity__r.AccountId
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :opp.Id];

        Set<Id> acctIds = CollectionUtil.getLookupIds(new List<Enrollment_Form__c>{ ef }, 'Enrollment_Opportunity__r.AccountId');
        
        system.assert(acctIds.size() > 0, 'There are no account ids.');
        system.assert(acctIds.contains(ef.Enrollment_Opportunity__r.AccountId), 'The account id was not found on the contact.');
    }
    
    @isTest
    static void getLookupIds_nullRecord_expectEmptyIdSetReturnedTest() {
        List<Contact> nullRecords = null;
        Set<Id> lookupIds = CollectionUtil.getLookupIds(nullRecords, 'AccountId');
        
        system.assert(lookupIds != null, 'The lookup ids is null.');
        system.assertEquals(0, lookupIds.size(), 'The lookup ids should be empty.');
    }

    @isTest
    static void groupRecordsByLookupField_nullRecord_expectEmptyMapReturnedTest() {
        List<Contact> nullRecords = null;
        Map<Id, List<Contact>> groupedRecords = CollectionUtil.groupRecordsByLookupField(nullRecords, 'AccountId');
        
        system.assert(groupedRecords.isEmpty(), 'The grouped records should be empty.');
    }
    
    @isTest
    static void groupRecordsByField_nullRecord_expectEmptyMapReturnedTest() {
        List<Contact> nullRecords = null;
        Map<Object, List<SObject>> groupedRecords = CollectionUtil.groupRecordsByField(nullRecords, 'AccountId');
        
        system.assert(groupedRecords.isEmpty(), 'The grouped records should be empty.');
    }

    @isTest
    static void filterRecordsByFieldValue_nullRecord_expectEmptyListReturnedTest() {
        List<Contact> nullRecords = null;
        List<Contact> filteredRecords = CollectionUtil.filterRecordsByFieldValue(nullRecords, 'AccountId', null);
        
        system.assert(filteredRecords.isEmpty(), 'The filtered records should be empty.');
    }
}