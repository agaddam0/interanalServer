public class AccountAura {
   @AuraEnabled
   public static List<Account> get10COntacts()
    {
      return [SELECT Id, NAME,phone,type FROM Account ] ;
   }
   // internal server checking
}