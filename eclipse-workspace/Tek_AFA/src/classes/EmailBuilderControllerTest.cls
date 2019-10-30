@isTest
public with sharing class EmailBuilderControllerTest {
    @testSetup
    static void setup() {
        EmailBuilderSettingsTestData.Instance.insertEmailBuilderSettings();
    }
    
    @isTest
    static void loadEmailBuilderContext_noEmailTemplatesFound_expectEmptyEmailTemplatesListTest() {
        MarketingCloudServiceTest.loadAfterAuthCalloutMock(new MarketingCloudServiceTest.GetEmailTemplatesInCategoryNoEmailTemplatesMock(), MarketingCloudService.ASSETS_QUERY_PATH);
        
        Test.startTest();

        EmailBuilderController.EmailBuilderContext context = EmailBuilderController.loadEmailBuilderContext();
        
        Test.stopTest();
        
        system.assert(context != null, 'The context is null.');
        system.assert(context.AvailableEmailTemplates != null, 'The available email templates are null.');
        system.assertEquals(0, context.AvailableEmailTemplates.size(), 'The available email templates are not empty.');
    }
    
    @isTest
    static void getEmailPreviewHTML_noInputValuesAndSuccessfulPreview_expectPreviewHTMLTest() {
        String existsEmailId = '93817';
        
        String emailPreviewHTML = getEmailPreviewHTML(existsEmailId, new Map<String, Object>(), '');
        
        system.assert(String.isNotBlank(emailPreviewHTML), 'There should be email preview HTML.');
    }
    
    @isTest
    static void getEmailPreviewHTML_noInputSuppliedButTextAreaAvailable_expectEmailPreviewHTMLTest() {
        String existsEmailId = '93817';
        String emailJSONMetadata = '[{' +
                                       '"Name": "Test Section",' +
                                       '"Inputs": [{' +
                                           '"Type": "TextArea", ' +
                                           '"TargetField": "Data1",' +
                                           '"Label": "Test"' +
                                       '}]' +
                                   '}]';
        
        String emailPreviewHTML = getEmailPreviewHTML(existsEmailId, new Map<String, Object>(), emailJSONMetadata);
        
        system.assert(String.isNotBlank(emailPreviewHTML), 'There should be email preview HTML.');
    }

    @isTest
    static void getEmailPreviewHTML_accountIdInputSuppliedForAccountRecordsToXML_expectEmailPreviewHTMLTest() {
        String existsEmailId = '93817';
        String emailJSONMetadata = '[{' +
                                       '"Name": "Test Section",' +
                                       '"Inputs": [{' +
                                           '"Type": "TextArea", ' +
                                           '"TargetField": "Data1",' +
                                           '"Label": "Test"' +
                                       '}],' +
                                       '"DataSelectors": [{' +
                                           '"Type": "RecordsToXML",' +
                                           '"SelectFields": "Id, Name",' +
                                           '"Object": "Account",' +
                                           '"Where": "Id = \'<<Data1>>\'",' +
                                           '"TargetField": "Data2"' +
                                       '}]' +
                                   '}]';
        
        Account a = AccountTestData.Instance.insertCustomerAccount();
        
        Map<String, Object> inputValues = new Map<String, Object>();
        inputValues.put('Data1', a.Id);        
        
        String emailPreviewHTML = getEmailPreviewHTML(existsEmailId, inputValues, emailJSONMetadata);
        
        system.assert(String.isNotBlank(emailPreviewHTML), 'There should be email preview HTML.');
    }

    @isTest
    static void getEmailPreviewHTML_accountIdInputSuppliedForAccountCommaSeparatedList_expectEmailPreviewHTMLTest() {
        String existsEmailId = '93817';
        String emailJSONMetadata = '[{' +
                                       '"Name": "Test Section",' +
                                       '"Inputs": [{' +
                                           '"Type": "TextArea", ' +
                                           '"TargetField": "Data1",' +
                                           '"Label": "Test"' +
                                       '},{' +
                                           '"Type": "checkboxgroup",' +
                                           '"Label": "Product Spotlights",' +
                                           '"Options": ["Accident", "Disability", "Cancer"],' +
                                           '"TargetField": "Data2"' +
                                       '}],' +
                                       '"DataSelectors": [{' +
                                           '"Type": "CommaSeparatedList",' +
                                           '"SelectFields": "Name",' +
                                           '"Object": "Account",' +
                                           '"Where": "Id = \'<<Data1>>\'",' +
                                           '"TargetField": "Data3"' +
                                       '}]' +
                                   '}]';
        
        Account a = AccountTestData.Instance.insertCustomerAccount();
        
        Map<String, Object> inputValues = new Map<String, Object>();
        inputValues.put('Data1', a.Id);        
        
        String emailPreviewHTML = getEmailPreviewHTML(existsEmailId, inputValues, emailJSONMetadata);
        
        system.assert(String.isNotBlank(emailPreviewHTML), 'There should be email preview HTML.');
    }
    
    @isTest
    static void sendEmail_noInputsAndNoDataSelectorsAndEmailSentSuccessfully_expectEmailSentSuccessMessageTest() {
        String emailId = '193817';
        String emptyEmailJSONMetadata = '';
        Map<String, Object> emptyInputValues = new Map<String, Object>();
        Contact someContact = ContactTestData.Instance.insertContact();
        
        String emailResultMsg = sendEmail(emailId, someContact.Id, emptyInputValues, emptyEmailJSONMetadata);
        
        system.assert(String.isNotBlank(emailResultMsg), 'There should be an email result message.');
        system.assertEquals(MarketingCloudService.SENT_EMAIL_SUCCESS_MSG, emailResultMsg, 'The email message is not the success message.');
    }
    
    @isTest
    static void getEditExistingDataLinkInfo_selectAccountByIdAndAccountFound_expectAccountIdReturnedTest() {
        Account customerAccount = AccountTestData.Instance.insertCustomerAccount();

        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartObject();
        
        Map<String, Object> queryObject = new Map<String, Object>();
        queryObject.put('SelectFields', 'Id, Name');
        queryObject.put('Object', 'Account');
        queryObject.put('Where', 'Id = \'<<value>>\'');
        

        generator.writeObjectField('Query', queryObject);
        generator.writeStringField('RecordIdField', 'Id');
        
        generator.writeEndObject();
        
        String editExistingDataLinkMetadata = generator.getAsString();
        
        EmailBuilderController.EditExistingDataLinkContext editLinkContext =
            EmailBuilderController.getEditExistingDataLinkInfo(editExistingDataLinkMetadata, customerAccount.Id);

        system.assert(editLinkContext != null, 'The edit link context is null.');
        system.assertEquals(customerAccount.Id, editLinkContext.RecordId, 'The edit link context\'s  record id is not the expected one.');
    }

    @isTest
    static void retrieveRecords_ensureOrderByAscendingWorksWithTwoAccounts_expectAccountsOrderedByNameTest() {
        Account defAcct = AccountTestData.Instance.withName('DEF Account').insertCustomerAccount();
        Account abcAcct = AccountTestData.Instance.withName('ABC Account').insertCustomerAccount();

        EmailBuilderController.DataSelector accountDataSelector = new EmailBuilderController.DataSelector();
        accountDataSelector.ObjectName = 'Account';
        accountDataSelector.SelectFields = 'Name';
        accountDataSelector.OrderBy = 'Name ASC';
        accountDataSelector.WhereClause = 'Name != null';

        Map<String, Object> emptyInputValues = new Map<String, Object>();

        List<Account> accounts = EmailBuilderController.retrieveRecords(accountDataSelector, emptyInputValues);

        system.assert(accounts != null, 'The accounts are null.');
        system.assertEquals(2, accounts.size(), 'There should be two accounts.');
        system.assertEquals(abcAcct.Name, accounts[0].Name, 'The accounts were not ordered by Name ascending.');
    }
    
    static String getEmailPreviewHTML(String emailId, Map<String, Object> inputValues, String emailJSONMetadata) {
        Test.startTest();
        
        MarketingCloudServiceTest.MockMetadata insertEmailPreviewDataExtensionMockData = new MarketingCloudServiceTest.MockMetadata();
        MarketingCloudService mcs = new MarketingCloudService();
        String toEmail = mcs.buildCurrentUserPreviewSubscriberKey();
        
        insertEmailPreviewDataExtensionMockData.Endpoint = mcs.buildInsertPreviewDataExtensionURL(emailId, toEmail);
        insertEmailPreviewDataExtensionMockData.Mock = new MarketingCloudServiceTest.insertEmailBuilderPreviewSuccessMock();
        
        MarketingCloudServiceTest.MockMetadata getPreviewHTMLMockData = new MarketingCloudServiceTest.MockMetadata();
        getPreviewHTMLMockData.Endpoint = mcs.buildGetPreviewEmailHTMLURL(emailId, toEmail);
        getPreviewHTMLMockData.Mock = new MarketingCloudServiceTest.GetPreviewHTMLSuccessMock();
        
        MarketingCloudServiceTest.loadAfterAuthCalloutMocks(new List<MarketingCloudServiceTest.MockMetadata>{ insertEmailPreviewDataExtensionMockData, getPreviewHTMLMockData });
        
        EmailBuilderController.EmailPreviewContext context = EmailBuilderController.getEmailPreviewHTML(emailId, inputValues, emailJSONMetadata);
        
        Test.stopTest();
        
        return context.EmailPreviewHTML;
    }
    
    static String sendEmail(String emailId, String contactId, Map<String, Object> inputValues, String emailJSONMetadata) {
        Test.startTest();
        
        MarketingCloudService mcs = new MarketingCloudService();
        String toEmail = mcs.buildCurrentUserPreviewSubscriberKey();
        
        MarketingCloudServiceTest.MockMetadata sendEmailSuccessMockData = new MarketingCloudServiceTest.MockMetadata();
        sendEmailSuccessMockData.Endpoint = mcs.buildSendEmailURL();
        sendEmailSuccessMockData.Mock = new MarketingCloudServiceTest.SendEmailSuccessMock();
        
        MarketingCloudServiceTest.loadAfterAuthCalloutMocks(new List<MarketingCloudServiceTest.MockMetadata>{ sendEmailSuccessMockData });
        
        EmailBuilderController.SendEmailResult sendEmailResult = EmailBuilderController.sendEmail(emailId, contactId, inputValues, emailJSONMetadata);
        
        Test.stopTest();
        
        return sendEmailResult.Message;
    }
}