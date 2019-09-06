public class Tek_ContactList {

    @AuraEnabled
    public static List<contact> getconList(string accountId){
        
        return [SELECT id,Name,Phone,Email,Account.Name FROM contact where AccountId=:accountId];
    }
    
    
    @AuraEnabled
    public static List<Account> getaccList1() {  
       return [SELECT id,Name From Account limit 15];
    }
    @AuraENabled
    public static List<contact> getconList1(){
        
        return [SELECT id,Name,Phone,Email,Account.Name FROM contact limit 15];
    }
    
    @AuraEnabled
    public static List<Opportunity> getOppList(){
        
        return [SELECT id,Name,Account.Name FROM opportunity limit 15];
    }
    @AuraEnabled
    public static List<Lead> getLeadList(){
        
        return [SELECT id,Name FROM Lead limit 15];
    }
}