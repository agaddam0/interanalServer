public class dataTablewithDetailRecord {
 
   @AuraEnabled
    public static List<account> getAccList(){
        
        return [SELECT ID,Name,Type,phone,Industry,Rating FROM Account];
    }
}