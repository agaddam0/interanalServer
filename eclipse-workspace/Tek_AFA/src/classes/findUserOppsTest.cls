@isTest
public class findUserOppsTest {
    
    static testMethod void testFindUserOpps()
    {
        Util u = new Util();
        Id AcctRType = Schema.SObjectType.Account.getRecordTYpeInfosByName().get('Prospect').getRecordTypeId();
        Id rType = Schema.SObjectType.Opportunity.getRecordTYpeInfosByName().get('AWD New Group').getRecordTypeId();
        Account a = u.createOneAcc('Test Account', true, AcctRType);
        Opportunity o = u.createOneOpp('Test Opp', 'Closed Won', a.Id, true, rType);
        Opportunity o2 = u.createOneOpp('Test Opp2', 'Approval Process', a.Id, true, rType);
        
        findUserOpps f = new findUserOpps();
        f.userId = UserInfo.getUserId();
        system.assertEquals(o2.Id, f.opportunities[0].Id);
    }
}