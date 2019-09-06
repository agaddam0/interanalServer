public class AwesomeProductController {  
    @AuraEnabled
    public static List<Account> getProducts() {
        return [select id, name from Account];
    }

    @AuraEnabled
    public static Account getProductByName(String name) {
        return [select id, name from Account where name = :name];
    }
}