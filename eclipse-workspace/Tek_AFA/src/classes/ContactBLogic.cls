public class ContactBLogic {
    
    public static list<Id> contactIds = new List<Id>();
    public static list<Id> accountIds = new List<Id>();
    public static Boolean isUpdate = false;
    
    public static void checkDecisionMakerUpdate(List<Contact> NEWcontacts, List<Contact> OLDcontacts, Map<Id, Contact> OLDMAPcontacts)
    {
        // We want to call these methods in after update and after delete
        // NEWcontacts will be null in a delete trigger
         
        if(NEWcontacts != null)
        {
            // this is an after update on contact
            // compare old field values with new field values to determine further processing
            
            for(Contact c : NEWcontacts)
            {
                system.debug('JJJ Update Contacts');
                if(c.Decision_Maker__c != OLDMAPcontacts.get(c.Id).Decision_Maker__c
                   || c.Inactive__c != OLDMAPcontacts.get(c.Id).Inactive__c
                   || c.Duplicate__c != OLDMAPcontacts.get(c.Id).Duplicate__c)
                {
                    // something changed with the decision maker
                    system.debug('JJJ Update Contacts');
                    ContactIds.add(c.Id);
                    AccountIds.add(c.AccountId);
                    isUpdate = true;
                }
            }
        }
        else
        {
            // new contacts is null, so this is a delete trigger
            for(Contact c : OLDcontacts)
            {
                if(c.Decision_Maker__c && !c.Inactive__c && !c.Duplicate__c)
                {
                    // a decision maker is being deleted
                    ContactIds.add(c.Id);
                    AccountIds.add(c.AccountId);
                }
            }
        }
        
        system.debug('Calling From Contact B Logic');
        AccountContactRelationBLogic.getRollupResults(contactIds, accountIds, true);
        system.debug('Calling From Contact B Logic');
        AccountContactRelationBLogic.updateAccounts();
    }
}