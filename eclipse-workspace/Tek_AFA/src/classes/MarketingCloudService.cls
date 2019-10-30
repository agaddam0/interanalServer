public with sharing class MarketingCloudService {
    public static final String AUTHENTICATION_PATH = 'v2/token?Legacy=1';
    public static final String ASSETS_QUERY_PATH = '/asset/v1/content/assets/query';
    public static final String TESTS_REST_INSTANCE_DEFAULT_URL = 'https://someMarketingCloudSubDomain.exacttargetapis.com/';
    public static final String SENT_EMAIL_SUCCESS_MSG = 'The email was successfully sent.';
    
    private static final String MARKETING_CLOUD_INTEGRATION = 'Marketing Cloud';
    
    @testVisible
    private String AccessToken { get; set; }
    private String SOAPInstanceURL { get; set; }
    
    private String RESTInstanceURLPriv = '';
    private String RESTInstanceURL {
        get {
            if (Test.isRunningTest() &&
                String.isBlank(RESTInstanceURLPriv)) {
                RESTInstanceURLPriv = TESTS_REST_INSTANCE_DEFAULT_URL;
            }
            
            return RESTInstanceURLPriv;
        }
        set {
            RESTInstanceURLPriv = value;
        }
    }
    
    private String LegacyAccessToken { get; set; }
    private String LegacyAPIInstanceURL { get; set; }
    
    public void authenticate() {
        if (String.isNotBlank(AccessToken)) {
            return;
        }
        
        HttpRequest authenticationRequest = new HttpRequest();
        HttpResponse response;
        Exception authException;
        
        try {        
	        Email_Builder_Settings__c settings = getEmailBuilderSettings();
	
	        authenticationRequest.setMethod('POST');
	        authenticationRequest.setHeader('Content-Type', 'application/json');
	        authenticationRequest.setTimeout(120000);
	        authenticationRequest.setEndpoint(settings.Authentication_URL__c + AUTHENTICATION_PATH);
	
	        String body = '{ "grant_type": "client_credentials", "client_id": "' + settings.Client_Id__c + '", "client_secret": "' + settings.Client_Secret__c + '" }';
	        authenticationRequest.setBody(body);
	        
	        response = new Http().send(authenticationRequest);
	        
	        String responseBody = response.getBody();
	        
	        system.debug('  authenticate responseBody: ' + responseBody);
	        
	        if(response.getStatusCode() == 200)
	        {
	            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
	            AccessToken = (string) results.get('access_token');
	            SOAPInstanceURL = (string) results.get('soap_instance_url');
	            RESTInstanceURL = (string) results.get('rest_instance_url');
	            LegacyAccessToken = (string) results.get('legacy_token');
	            LegacyAPIInstanceURL = (string) results.get('legacy_api_instance_url');
	        }
	        else {
	            throw new MarketingCloudServiceException(response.getBody());
	        }
        }
        catch (Exception ex) {
            authException = ex;
        }
        finally {
            String contextualInfo = 'Attempting Marketing Cloud Authentication ...\n\n';

            IntegrationLogger.Instance.addIntegrationLog(MARKETING_CLOUD_INTEGRATION, authenticationRequest, response, authException, contextualInfo);
        }
    }

    public EmailTemplatesContext getEmailTemplatesInCategory(String categoryId) {
        HttpRequest request;
        HttpResponse response;
        Exception getEmailTemplatesException;
        EmailTemplatesContext context = new EmailTemplatesContext();
        
        try {
            authenticate();
            
	        request = buildAuthorizedRequest();
	        request.setMethod('POST');
	        request.setEndpoint(RESTInstanceURL + ASSETS_QUERY_PATH);
	        String body = '{ "query": { "leftOperand": {"property": "category.id", "simpleOperator": "equal", "value": "' + categoryId +'" }, "logicalOperator": "AND", "rightOperand": { "property": "assetType.name", "simpleOperator": "equal", "value": "templatebasedemail"  }}}';
	        request.setBody(body);
	        
	        response = new Http().send(request);
	        
	        if (response.getStatusCode() == 200) {
		        String responseBody = response.getBody();
		        
		        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		        Integer emailTemplatesCount = (Integer) results.get('count');
		        
		        if (emailTemplatesCount > 0) {
		            List<Object> emailTemplatesList = (List<Object>) results.get('items');
		            
		            for (Object emailTemplateObj : emailTemplatesList) {
		                Map<String, Object> emailTemplateMap = (Map<String, Object>) emailTemplateObj;
		                EmailTemplate emailTemplate = new EmailTemplate(emailTemplateMap);
		                context.EmailTemplates.add(emailTemplate);
		            }
		        }
	        }
	        else {
	            throw new MarketingCloudServiceException(response.getBody()); 
	        }
        }
        catch (Exception ex) {
            getEmailTemplatesException = ex;
            context.Success = false;
            context.Message = ex.getMessage();
        }
        finally {
            String contextualInfo = 'Attempting getEmailTemplatesInCategory ...\n\n';
            contextualInfo += 'categoryId: ' + categoryId + '\n';

            IntegrationLogger.Instance.addIntegrationLog(MARKETING_CLOUD_INTEGRATION, request, response, getEmailTemplatesException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }
        
        return context;
    }
    
    public EmailPreviewContext getEmailPreviewHTML(String emailId, Map<String, Object> inputValues) {
        String emailContent = '';
        HttpRequest request;
        HttpResponse response;
        Exception getEmailPreviewHTMLException;
        Boolean dataExtensionSuccess;
        EmailPreviewContext context = new EmailPreviewContext();
        
        try {	        
	        if (String.isBlank(emailId)) {
	            return context;
	        }
	        
	        String currentUserSubscriberKeyEmail = buildCurrentUserPreviewSubscriberKey();
	
	        dataExtensionSuccess = insertEmailBuilderPreviewDataExtensionRecord(emailId, currentUserSubscriberKeyEmail, inputValues);
	        
	        if (!dataExtensionSuccess) {
	            return context;
	        }
	        
	        // A preview direction: https://salesforce.stackexchange.com/questions/206323/retrieve-email-preview-using-rest-api
	
	        request = buildAuthorizedRequest();
	        
	        // Has to be a POST and not a GET. Otherwise, you get a 404 NOT FOUND Error.
	        request.setMethod('POST');
	        request.setEndpoint(buildGetPreviewEmailHTMLURL(emailId, currentUserSubscriberKeyEmail));
	
	        response = new Http().send(request);
	        
	        String responseBody = response.getBody();
	        
	        if (response.getStatusCode() == 200) {
		        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		        Map<String, Object> message = (Map<String, Object>) result.get('message');
		        List<Object> views = (List<Object>) message.get('views');
		        Map<String, Object> htmlView = (Map<String, Object>) views[0];
		        
		        context.EmailPreviewHTML = (String) htmlView.get('content');
		        
		        system.debug('   emailContent: ' + context.EmailPreviewHTML);
	        }
	        else {
	            throw new MarketingCloudServiceException(response.getBody()); 
	        }
        }
        catch (Exception ex) {
            context.Success = false;
            context.Message = ex.getMessage();
            getEmailPreviewHTMLException = ex;
        }
        finally {
            String contextualInfo = 'Attempting getEmailPreviewHTML ...\n\n';
            contextualInfo += 'emailId: ' + emailId + '\n';
            contextualInfo += 'inputValues: ' + String.valueOf(inputValues) + '\n';
            contextualInfo += 'preview data extension record upserted successfully: ' + dataExtensionSuccess + '\n';

            IntegrationLogger.Instance.addIntegrationLog(MARKETING_CLOUD_INTEGRATION, request, response, getEmailPreviewHTMLException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }

        return context;
    }
    
    public Boolean insertEmailBuilderPreviewDataExtensionRecord(String emailTemplate, String toEmail, Map<String, Object> dataValues) {
        /*Host: https://YOUR_SUBDOMAIN.rest.marketingcloudapis.com
PUT /hub/v1/dataevents/11954DDF-28A3-4FE8-BF77-646C37506621/rows/Email:someone@exacttarget.com
Content-Type: application/json
Authorization: Bearer YOUR_ACCESS_TOKEN

{
    "values":{
            "LastLogin":"2013-05-23T14:32:00Z",
            "IsActive":true,
            "FirstName":"John",
            "FollowerCount":2,
            "LastName":"Smith"
             }
}*/

        HttpRequest request;
        HttpResponse response;
        Exception insertEmailBuilderPreviewException;

        try {
	        authenticate();
	        
	        request = buildAuthorizedRequest();
	        request.setMethod('PUT');
	        
	        String endpoint = buildInsertPreviewDataExtensionURL(emailTemplate, toEmail);
	        
	        request.setEndpoint(endpoint);
	        
	        Map<String, Object> valuesMap = new Map<String, Object>();
	        valuesMap.put('EmailTemplate', emailTemplate);
	        valuesMap.put('ToEmail', toEmail);
	        
	        if (dataValues != null) {
	            for (String dataValueKey : dataValues.keySet()) {
	                Object dataValue = dataValues.get(dataValueKey);
	                
	                if (dataValue != null &&
	                    dataValue instanceOf List<Object>) {
	                    dataValues.put(dataValueKey, JSON.serialize(dataValue));
	                }
	            }
	            
	            valuesMap.putAll(dataValues);
	        }
	        
	        JSONGenerator generator = JSON.createGenerator(false);
			generator.writeStartObject();
			generator.writeObjectField('values', valuesMap);
			generator.writeEndObject();
			
			String dataExtensionJSON = generator.getAsString();
			
			system.debug('   insertEmailBuilderDataExtensionRecord dataExtensionJSON: ' + dataExtensionJSON);
			
	        request.setBody(dataExtensionJSON);
	        
	        response = new Http().send(request);
	        
	        if (response.getStatusCode() != 200) {
	            throw new MarketingCloudServiceException(response.getBody());
	        }
	        
	        return true;
        }
        catch (Exception ex) {
            insertEmailBuilderPreviewException = ex;
            return false;
        }
        finally {
            String contextualInfo = 'Attempting insertEmailBuilderPreviewDataExtensionRecord ...\n\n';
            contextualInfo += 'emailTemplate: ' + emailTemplate + '\n';
            contextualInfo += 'toEmail: ' + toEmail + '\n';
            contextualInfo += 'dataValues: ' + String.valueOf(dataValues) + '\n';

            IntegrationLogger.Instance.addIntegrationLog(MARKETING_CLOUD_INTEGRATION, request, response, insertEmailBuilderPreviewException, contextualInfo);
        }
    }

    public String fireEmailBuilderAPIEvent(String emailTemplate, String toEmail, Map<String, Object> inputValues, String ccEmail) {
        /*
        Host: https://YOUR_SUBDOMAIN.rest.marketingcloudapis.com
POST /interaction/v1/events
Content-Type: application/json
Authorization: Bearer YOUR_ACCESS_TOKEN

{
    "ContactKey": "ID601",
    "EventDefinitionKey":"AcmeBank-AccountAccessed",
    "Data": {
        "accountNumber":"123456",
        "patronName":"John Smith" }
}
        */

        HttpRequest request;
        HttpResponse response;
        Exception fireEmailBuilderAPIEventException;
        String responseBody = '';

        try {
	        authenticate();
	        
	        request = buildAuthorizedRequest();
	        request.setMethod('POST');
	        request.setEndpoint(buildSendEmailURL());
	        
	        Email_Builder_Settings__c settings = getEmailBuilderSettings();
	
	        String eventDefinitionKey = settings.Send_Email_Event_Definition_Key__c;
	        
	        JSONGenerator generator = JSON.createGenerator(false);
	        generator.writeStartObject();
	        
	        Map<String, Object> dataObjectMap = new Map<String, Object>();
	        dataObjectMap.put('EmailTemplate', emailTemplate);
	        dataObjectMap.put('ToEmail', toEmail);

            if (String.isNotBlank(ccEmail)) {
                dataObjectMap.put('ccEmail', ccEmail);
            }
	        
	        if (inputValues != null && !inputValues.isEmpty()) {
	            // Serialize any arrays into a JSON string so it gets interpreted correctly.
	            
	            for (String inputValueKey : inputValues.keySet()) {
                    Object inputValue = inputValues.get(inputValueKey);
                    
                    if (inputValue != null &&
                        inputValue instanceOf List<Object>) {
                        inputValues.put(inputValueKey, JSON.serialize(inputValue));
                    }
                }
	            
	            dataObjectMap.putAll(inputValues);
	        }
	        
	        generator.writeObjectField('Data', dataObjectMap);
	        generator.writeStringField('ContactKey', toEmail);
	        generator.writeStringField('EventDefinitionKey', eventDefinitionKey);
	        generator.writeEndObject();
	        
	        String dataExtensionJSON = generator.getAsString();
	
	        request.setBody(dataExtensionJSON);
	        
	        response = new Http().send(request);
	        
	        responseBody = response.getBody();

	        if (response.getStatusCode() == 201) {
	            return SENT_EMAIL_SUCCESS_MSG;
	        }
	        else {
	            throw new MarketingCloudServiceException(responseBody);
	        }
        }
        catch (Exception ex) {
            fireEmailBuilderAPIEventException = ex;
        }
        finally {
            String contextualInfo = 'Attempting fireEmailBuilderAPIEvent ...\n\n';
            contextualInfo += 'emailTemplate: ' + emailTemplate + '\n';
            contextualInfo += 'toEmail: ' + toEmail + '\n';
            contextualInfo += 'inputValues: ' + String.valueOf(inputValues) + '\n';

            IntegrationLogger.Instance.addIntegrationLog(MARKETING_CLOUD_INTEGRATION, request, response, fireEmailBuilderAPIEventException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }

        return responseBody;
    }

    public String sendEmail(String emailTemplate, String toEmail, Map<String, Object> inputValues, String ccEmail) {
        return fireEmailBuilderAPIEvent(emailTemplate, toEmail, inputValues, ccEmail);
    }
    
    private HttpRequest buildAuthorizedRequest() {
        HttpRequest request = new HttpRequest();

        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + AccessToken);
        request.setTimeout(120000);
        
        return request;
    }
    
    private Email_Builder_Settings__c getEmailBuilderSettings() {
        return Email_Builder_Settings__c.getOrgDefaults();
    }
    
    @TestVisible
    private String buildCurrentUserPreviewSubscriberKey() {
        String userName = UserInfo.getUserName();
        List<String> usernameParts = userName.split('@');
        
        String currentUserPreviewSubscriberKey = usernameParts[0] + '@example.com';
        
        return currentUserPreviewSubscriberKey;
    }
    
    @TestVisible
    private String buildInsertPreviewDataExtensionURL(String emailId, String toEmail) {
        Email_Builder_Settings__c settings = getEmailBuilderSettings();

        return RESTInstanceURL + '/hub/v1/dataevents/key:' + settings.Preview_Data_Extension_External_Key__c + '/rows/PrimaryKey:' + EncodingUtil.urlEncode(toEmail, 'UTF-8');
    }
    
    @TestVisible
    private String buildGetPreviewEmailHTMLURL(String emailId, String currentUserSubscriberKeyEmail) {
        Email_Builder_Settings__c settings = getEmailBuilderSettings();
            
        String urlEncodedSubscriberKey = EncodingUtil.urlEncode(currentUserSubscriberKeyEmail, 'UTF-8');

        return RESTInstanceURL + 'guide/v1/emails/' + emailId + '/dataExtension/key:' + settings.Preview_Data_Extension_External_Key__c + '/Contacts/key:' + urlEncodedSubscriberKey + '/preview?kind=html';
    }
    
    @TestVisible
    private String buildSendEmailURL() {
        return RESTInstanceURL + '/interaction/v1/events';
    }

    public class EmailTemplate {
        @AuraEnabled
        public String CustomerKey { get; set; }

        @AuraEnabled
        public String Name { get; set; }

        @AuraEnabled
        public String Description { get; set; }

        @AuraEnabled
        public String LegacyId { get; set; }
        
        @AuraEnabled
        public String HTMLSlotsJSON { get; set; }
        
        public EmailTemplate(Map<String, Object> emailTemplateMap) {
            CustomerKey = (String) emailTemplateMap.get('customerKey');
            Name = (String) emailTemplateMap.get('name');
            Description = (String) emailTemplateMap.get('description');

            Map<String, Object> legacyData = (Map<String, Object>) emailTemplateMap.get('legacyData');
            LegacyId = String.valueOf(legacyData.get('legacyId'));
            
            Map<String, Object> views = (Map<String, Object>) emailTemplateMap.get('views');
            Map<String, Object> htmlView = (Map<String, Object>) views.get('html');
            HTMLSlotsJSON = JSON.serialize(htmlView.get('slots'));
        }
    }
    
    public class EmailTemplatesContext {
        @AuraEnabled
        public List<EmailTemplate> EmailTemplates { get; set; }
        
        @AuraEnabled
        public Boolean Success { get; set; }
        
        @AuraEnabled
        public String Message { get; set; }
        
        public EmailTemplatesContext() {
            EmailTemplates = new List<EmailTemplate>();
            Success = true;
            Message = '';
        }
    }
    
    public class EmailPreviewContext {
        @AuraEnabled
        public String EmailPreviewHTML { get; set; }
        
        @AuraEnabled
        public Boolean Success { get; set; }
        
        @AuraEnabled
        public String Message { get; set; }
        
        public EmailPreviewContext() {
            Success = true;
            Message = '';
            EmailPreviewHTML = '';
        }
    }
    
    public class MarketingCloudServiceException extends Exception { }
}