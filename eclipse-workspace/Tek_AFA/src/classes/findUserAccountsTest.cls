@isTest
public class findUserAccountsTest {
    
    static testMethod void testFindUserAccounts()
    {
        Util u = new Util();
        Id customer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Account a = u.createOneAcc('Test Account', true, customer);
        
        findUserAccounts f = new findUserAccounts();
        f.userId = UserInfo.getUserId();
        system.assertEquals(1, f.accounts.size());
    }
}