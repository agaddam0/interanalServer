public with sharing class AccountPagination 
{
 @AuraEnabled
    public static List<Account> getAccounts()
    {
        return [SELECT Id, Name,phone,Rating,Ownership,Type,Industry FROM Account];
    }
}