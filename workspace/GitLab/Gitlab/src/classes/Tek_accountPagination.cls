public class Tek_accountPagination {
  @AuraEnabled
  public static List<Account> getaccounts()
  {
      return [SELECT Id, Name,Type,Rating FROM Account ];
  }
// This method used for reterived  the list of opportunity records based on the search string
  @AuraEnabled
  public static List<Account> getByName(String searchKey) {
           String name = '%' + searchKey + '%';
           return [SELECT id, Name,Type, Rating FROM Account WHERE name LIKE :name];
   }
}