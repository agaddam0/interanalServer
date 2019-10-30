@isTest
private class EnrollmentSectionFormControllerTest {

    @isTest
    static void SObjectFields_BoundRecordProvided_expectSObjectFieldsReturnedTest() {
        EnrollmentSectionFormController controller = instantiateDefaultController();
        
        Map<String, Schema.DescribeFieldResult> fields = controller.SObjectFields;
        
        system.assert(fields != null, 'The fields are null.');
        system.assert(fields.size() > 0, 'No fields found for the object.');
    }
    
    @isTest
    static void ObjectFieldSet_PreenrollmentMarketingFormContact_InformationFieldSetGiven_expectContact_InformationFieldSetReturnedTest() {
        EnrollmentSectionFormController controller = instantiateDefaultController();
        controller.ObjectFieldSetName = 'Contact_Information';
        
        Schema.FieldSet fieldSet = controller.ObjectFieldSet;
        
        system.assert(fieldSet != null, 'The field set is null');
        system.assertEquals(controller.ObjectFieldSetName, fieldSet.getName(), 'The wrong field set was returned');
    }
    
    @isTest
    static void Table_fieldSetAndBoundRecordAndOneFieldPerRowGiven_expectTablePopulatedWithRowsAndColumnsTest() {
        EnrollmentSectionFormController controller = instantiateDefaultController();
        controller.NumberOfTableLayoutColumns = 1;
        
        EnrollmentSectionFormController.TableFormWrapper table = controller.Table;
        
        system.assert(table != null, 'The table form wrapper is null.');
        system.assert(table.Rows != null, 'The table\'s rows are null.');
        
        List<Schema.FieldSetMember> fieldSetMembers = controller.ObjectFieldSet.getFields();
        
        system.assertEquals(fieldSetMembers.size(), table.Rows.size(), 'When one field is shown per row, the number of total rows should match the number of fields in the field set.');
        
        for (EnrollmentSectionFormController.TableFormWrapperRow row : table.Rows) {
            system.assert(row.Columns != null, 'The row\'s columns are null.');
            system.assertEquals(controller.NumberOfTableLayoutColumns, row.columns.size(), 'There should be 1 column per row.');

            EnrollmentSectionFormController.TableFormWrapperColumn column = row.Columns[0];

            system.assert(String.isNotBlank(column.Label), 'The column\'s label should not be blank.');
            system.assert(String.isNotBlank(column.APIFieldName), 'The column\'s APIFieldName should not be blank.');
            system.assert(column.Required != null, 'The column\'s Required property should not be null.');
            
            // Luke Freeland 4/24/2017: Some fields have helptext and some don't so that's why column.HelpText
            // isn't asserted. 
        }
    }

    private static EnrollmentSectionFormController instantiateDefaultController() {
        Pre_Enrollment_Marketing_Form__c record = new Pre_Enrollment_Marketing_Form__c();
        
        EnrollmentSectionFormController controller = new EnrollmentSectionFormController();
        controller.BoundRecord = record;
        controller.ObjectFieldSetName = 'Contact_Information';        
        
        return controller;
    }
}