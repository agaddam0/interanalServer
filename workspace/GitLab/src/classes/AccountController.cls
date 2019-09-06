public with sharing class AccountController 
{
    @AuraEnabled
    public static List<Account> GetAccountNames()
    {
        return [select id, Name from Account limit 10];
    }    
    
    @AuraEnabled 
    public static List<Account> GetAccountDetails(String idListJSONStr)
    {
        System.debug('idListJSON = ' + idListJSONStr);
        Type idArrType=Type.forName('List<Id>');
        List<Id> ids=(List<Id>) JSON.deserialize(idListJSONStr, idArrType);
        System.debug('Ids = ' + ids);
        
        return [select id, Name, Industry, Website from Account where id in :ids];
    }
    public with sharing class AccountWrapper
{
    @AuraEnabled
    public Account acc {get; set;}
     
    @AuraEnabled
    public Boolean selected {get; set;}
}
// ashok gaddam changes
}