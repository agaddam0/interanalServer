Public class ContactAndLeadSearch{
   Public static List<List< SObject>> searchContactsAndLeads(string str){
       List<List<sObject>> searchList = [FIND 'Smith' IN ALL FIELDS
                   RETURNING lead(Name),Contact(FirstName,LastName,Department)];
                   
                   return searchList ;
   }

}