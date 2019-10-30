@isTest
public with sharing class SObjectTestDataTest {

    @isTest
    static void insertDefaultAccount_invoke_expectInsertedDefaultAccountReturnedTest() {
        Account defaultAccount = AccountTestData.Instance.insertDefaultAccount();
        
        system.assert(defaultAccount != null, 'The default account is null.');
        system.assert(defaultAccount.Id != null, 'The default account was not inserted.');
    }
    
    @isTest
    static void insertAccounts_request10AccountsInserted_expect10AccountsInsertedTest() {
        Integer numberOfAccountsToInsert = 10;
        List<Account> accounts = AccountTestData.Instance.insertAccounts(numberOfAccountsToInsert);
        
        system.assert(accounts != null, 'accounts is null.');
        system.assertEquals(numberOfAccountsToInsert, accounts.size(), 'The number of expected accounts was not returned.');
        
        for (Account insertedAccount : accounts) {
            system.assert(insertedAccount != null, 'A null account was returned from insertAccounts.');
            system.assert(insertedAccount.Id != null, 'The account was not inserted.');
        }
    }
}