public class AccountsListController
{
    @AuraEnabled
    @RemoteAction
    public static List<Account> GetAccounts()
    {
        return [SELECT id, Name, Industry, CreatedDate
                FROM Account
                ORDER BY createdDate DESC];
    }
 }