public class Tek_Poc1 {

    @AuraEnabled
    public static list<Account> getAccRecrods(){
        
        return [SELECT ID,Name,Type From Account where type!=null limit 5];
    }
    @AuraEnabled
    public static list<contact> getcontactRecords(){
        return [Select id,Name,account.name from contact limit 5];
    }
    @AuraEnabled
    public static list<Lead> getLeadRecords(){
        return [Select id,Name,Status from Lead limit 5];
    }
}