@isTest
public class SObjectDropdownControllerTest {
    
    @testSetup
    static void testData()
    {
        List<Contact> contacts = new List<Contact>();
        
        for(integer i = 0; i < 5; i++)
        {
            Contact c = ContactTestData.Instance.withFirstName('Jessica ' + i).withLastName('Riffe ' + i). create();
            contacts.add(c);
        }
        
        insert contacts;
    }
    
	@isTest
    static void getSObjectRecordsTest()
    {
        List<SObject> sObjects = SObjectDropdownController.getSObjectRecords('FirstName', 'Contact');
        
        system.assertEquals(5, sObjects.size());
    }
}