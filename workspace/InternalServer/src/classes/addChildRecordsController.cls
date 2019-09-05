public class addChildRecordsController {
  /* This class will be add the child records to parent object here example is contact & account*/
    @AuraEnabled
    Public static List<Contact> getContacts(){
        return [SELECT ID,Name,Email FROM Contact limit 15];
    }
    @AuraEnabled
    public static void addParentAccount(String ParentId , List<String> lstOfContactIds){
    list<Contact> lstContacts = new list<Contact>();
    for(string sContactId : lstOfContactIds){
        Contact oContact = new contact();
        oContact.Id = sContactId;
        oContact.AccountId = ParentId;
        lstContacts.add(oContact);
   }
   update lstContacts;
    }
}