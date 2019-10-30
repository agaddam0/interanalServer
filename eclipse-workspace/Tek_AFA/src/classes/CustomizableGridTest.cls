@isTest
public class CustomizableGridTest {
    
    @testSetup
    static void testData()
    {
        Util u = new Util();
        
        u.createAcc('Customizable Grid Accounts', 5, true, Constants.ACCOUNT_CUSTOMER_ACCOUNT);
        
        // Field set for tests is: FieldSetForTestClass
    }
    
    @isTest
    static void testCustomizableGrid()
    {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('SObjectName', 'Account');
        gen.writeStringField('FieldSet', 'FieldSetForTestClass');
        gen.writeStringField('WhereClause', 'WHERE RecordTypeId = \'' + Constants.ACCOUNT_CUSTOMER_ACCOUNT + '\'');
        gen.writeEndObject();
        
        String body = gen.getAsString();
        
        CustomizableGridCTRL.RecordsResponse response = CustomizableGridCTRL.getRecords(body);
        
        system.debug('Response: ' + response.Records.size()); 
        
        system.assertEquals(5, response.Records.size());
    }

}