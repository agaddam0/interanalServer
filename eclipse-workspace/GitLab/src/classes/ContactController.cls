public class ContactController {
    @AuraEnabled
    public static List<Contact> getContacts() {
        return [Select Id, Name, Birthdate, AccountId, Account.Name, Email, Title, Phone 
                From Contact order by LastModifiedDate desc  ];
    }
    
    // Retrieve all primary contacts
public static List<Contact> getPrimary() {
List<Contact> primaryContacts =[SELECT Id, Name, MailingStreet, Phone, Email, Level__c FROM Contact WHERE Level__c = 'Primary'];
return primaryContacts;
}
}