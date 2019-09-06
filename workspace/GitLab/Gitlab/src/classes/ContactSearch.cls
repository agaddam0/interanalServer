Public class ContactSearch{
    public static list<Contact> searchForContacts(string lname,string postalcode){
       Account acct = new Account(Name='SFDC Computing', Phone='(415)555-1212', NumberOfEmployees=50,BillingCity='San Francisco');
insert acct;
ID acctID = acct.ID;
list<contact> conList=new List<contact>();
Contact con = new Contact(

    FirstName='Carol',

    LastName=lname,
    MailingPostalCode=postalcode,
    Phone='(415)555-1212',

    Department='Wingo',
    AccountId=acctID);
    conList.add(con);
insert conList;
return conList;
    }
}