public class findUserAccounts {
    public Id userId {get;set;}
    public List<Account> accounts {
        get {
            accounts = [select Name, Status__c, Type from Account WHERE OwnerId =: userId];
            return accounts;
        }
        set;
    }
    
    public findUserAccounts() {
               
    }
}