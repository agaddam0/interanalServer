public with sharing class EmailBuilderController {
    @AuraEnabled
    public static EmailPreviewContext getEmailPreviewHTML(String emailId, Map<String, Object> inputValues, String emailJSONMetadata) {
        system.debug(' getEmailPreviewHTML::emailJSONMetadata: ' + emailJSONMetadata);
        
        EmailPreviewContext context = new EmailPreviewContext();
        
        EmailMetadata myEmailMetadata = new EmailMetadata(emailJSONMetadata);
        
        loadSelectedData(inputValues, myEmailMetadata);
        setUnsuppliedInputValuesToNull(inputValues, myEmailMetadata);
        
        MarketingCloudService.EmailPreviewContext emailPreviewContext = new MarketingCloudService().getEmailPreviewHTML(emailId, inputValues);
        
        context.EmailPreviewHTML = emailPreviewContext.EmailPreviewHTML;
        context.Success = emailPreviewContext.Success;
        context.Message = emailPreviewContext.Message;
        
        return context;
    }

    @AuraEnabled
    public static EmailBuilderContext loadEmailBuilderContext() {
        EmailBuilderContext context = new EmailBuilderContext();
        
        MarketingCloudService.EmailTemplatesContext emailTemplatesContext = getAvailableEmailTemplates();
        
        context.AvailableEmailTemplates = emailTemplatesContext.EmailTemplates;
        context.Success = emailTemplatesContext.Success;
        context.Message = emailTemplatesContext.Message;
        
        return context;
    }

    @AuraEnabled
    public static SendEmailResult sendEmail(String emailId, String contactId, Map<String, Object> inputValues, String emailJSONMetadata) {
        // If contactId is blank, send to the current user.
        String recipientEmail = UserInfo.getUserEmail();
        String ccEmail = '';
        
        if (contactId != null) {
            ccEmail = UserInfo.getUserEmail();

            Contact c = [SELECT Id, Email
                           FROM Contact
                          WHERE Id = :contactId];

            recipientEmail = c.Email;

            inputValues.put('ContactId', contactId);
        }
        
        EmailMetadata myEmailMetadata = new EmailMetadata(emailJSONMetadata);
        
        loadSelectedData(inputValues, myEmailMetadata);
        setUnsuppliedInputValuesToNull(inputValues, myEmailMetadata);
        
        SendEmailResult result = new SendEmailResult();
        result.Message = new MarketingCloudService().sendEmail(emailId, recipientEmail, inputValues, ccEmail);
        
        return result;
    }
    
    @AuraEnabled
    public static EditExistingDataLinkContext getEditExistingDataLinkInfo(String editExistingDataLinkMetadataJSON, String inputValue) {
        EditExistingDataLinkContext context = new EditExistingDataLinkContext();
        EditExistingDataMetadata metadata = new EditExistingDataMetadata(editExistingDataLinkMetadataJSON);
        
        String whereClause = metadata.WhereClause.replace('<<value>>', inputValue);
        
        String soql = 'SELECT ' + metadata.SelectFields +
                      '  FROM ' + metadata.ObjectName +
                      ' WHERE ' + whereClause;

        List<SObject> records = Database.query(soql);
        
        if (records.size() > 0) {
            SObject record = records[0];
            
            context.RecordId = (String) record.get(metadata.RecordIdField);
        }
        
        return context;
    }

    private static MarketingCloudService.EmailTemplatesContext getAvailableEmailTemplates() {
        Email_Builder_Settings__c settings = Email_Builder_Settings__c.getOrgDefaults();
        
        return new MarketingCloudService().getEmailTemplatesInCategory(settings.Email_Templates_Folder_Category_Id__c);
    }
    
    private static void loadSelectedData(Map<String, Object> inputValues, EmailMetadata myEmailMetadata) {
        if (myEmailMetadata == null ||
            myEmailMetadata.DataSelectors.isEmpty() ||
            inputValues == null) {
            return;
        }

        for (DataSelector ds : myEmailMetadata.DataSelectors) {
            List<Sobject> records = retrieveRecords(ds, inputValues);

            String targetFieldValue = '';

            if (ds.Type == 'CommaSeparatedList') {
                targetFieldValue = generateTargetFieldCommaSeparatedValues(records, ds.SelectFields);
            }
            else if (ds.Type == 'RecordsToXML') {
                targetFieldValue = generateTargetFieldRecordsXML(records, ds);
            }

            system.debug('  setting ' + ds.TargetField + ' to ' + targetFieldValue);

            inputValues.put(ds.TargetField, targetFieldValue);
        }
    }
    
    @TestVisible
    private static List<SObject> retrieveRecords(DataSelector ds, Map<String, Object> inputValues) {
        String whereClause = ds.WhereClause;
        
        String startingDelimiter = '<<';
		String endingDelimiter = '>>';
		Integer startingDelimiterLength = startingDelimiter.length();
		
		Integer startingDelimiterPosition = whereClause.indexOf('<<');
		
		while (startingDelimiterPosition > -1) {
		    Integer endingDelimiterPosition = whereClause.indexOf(endingDelimiter, startingDelimiterPosition);
		
		    String inputFieldName = whereClause.subString(startingDelimiterPosition + startingDelimiterLength, endingDelimiterPosition);
		
		    system.debug('   inputFieldName: ' + inputFieldName);
		    
		    String inputValue = (String) inputValues.get(inputFieldName);
		    
		    // In case the key doesn't match the inputField Name exactly,
		    // do a case insensitive search.
		    
		    if (String.isBlank(inputValue)) {
			    for (String inputKey : inputValues.keySet()) {
			        if (inputKey == inputFieldName) {
			            inputValue = (String) inputValues.get(inputKey);
			        }
			    }
		    }
		    
		    if (inputValue == null) {
    		    inputValue = '';
		    }
		    
		    whereClause = whereClause.replace(startingDelimiter + inputFieldName + endingDelimiter, inputValue);
		
		    startingDelimiterPosition = whereClause.indexOf(startingDelimiter, endingDelimiterPosition);
		}

		String query = 'SELECT ' + ds.SelectFields +
		               '  FROM ' + ds.ObjectName +
		               ' WHERE ' + whereClause;

        if (String.isNotBlank(ds.OrderBy)) {
            query += ' ORDER BY ' + ds.OrderBy;
        }

        system.debug('   query: ' + query);

        List<Sobject> records = Database.query(query);
        
        return records;
    }
    
    private static String generateTargetFieldCommaSeparatedValues(List<SObject> records, String fieldName) {
        String commaSeparatedValues = '';
        List<String> values = new List<String>();

        for (SObject record : records) {
            String value = (String) record.get(fieldName);
            values.add(value);
        }

        commaSeparatedValues = String.join(values, ',');

        return commaSeparatedValues;
    }
    
    private static String generateTargetFieldRecordsXML(List<SObject> records, DataSelector ds) {
        String recordsXML = '';
        
        if (records == null ||
            records.isEmpty()) {
            return recordsXML;
        }
        
        
        recordsXML = '<root>';
        List<String> selectedFields = new List<String>();

        String[] fieldsParts = ds.SelectFields.split(',');
        
        for (String fieldPart : fieldsParts) {
            String selectedFieldName = fieldPart.trim();
            
            selectedFields.add(selectedFieldName);
        }
        
        Schema.SObjectType objectType = records[0].getSObjectType();
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        Map<String, Schema.DescribeFieldResult> lowerCaseFieldMap = new Map<String, Schema.DescribeFieldResult>();
        
        for (Schema.SObjectField objectField : fieldMap.values()) {
            Schema.DescribeFieldResult fieldDesc = objectField.getDescribe();
            
            lowerCaseFieldMap.put(fieldDesc.getLocalName().toLowerCase(), fieldDesc);
        }

        for (SObject record : records) {
            recordsXML += '<record ';

            for (String selectedField : selectedFields) {
                Schema.DescribeFieldResult fieldDesc = lowerCaseFieldMap.get(selectedField.toLowerCase());
                
                Object fieldValue = record.get(selectedField);
                
                String fieldValueStr = '';
                
                if (fieldValue != null) {
                    fieldValueStr = String.valueOf(fieldValue);
                    
                    // For time fields, translate the value to a formatted value so that Marketing Cloud
                    // only has to show it and not do any formatting. If the time value is sent over,
                    // Marketing Cloud has trouble displaying it as is because it tries to manipulate it.
                    if (fieldDesc.getType() == Schema.DisplayType.Time) {
                        Time timeValue = (Time) fieldValue;
                        
                        DateTime tempDT = DateTime.newInstance(2019, 4, 1, timeValue.hour(), timeValue.minute(), timeValue.millisecond());
                        fieldValueStr = tempDT.format('h:mm a');
                    }
                    
                    // Marketing Cloud doesn't like special characters such as & so HTML encode them.
                    fieldValueStr = fieldValueStr.escapeHtml4();
                }
                
                recordsXML += selectedField + '="' + fieldValueStr + '" ';
            }            
            
            recordsXML += ' />';
        }

        recordsXML += '</root>';

        return recordsXML;
    }
    
    private static void setUnsuppliedInputValuesToNull(Map<String, Object> inputValues, EmailMetadata myEmailMetadata) {
        if (myEmailMetadata == null ||
            myEmailMetadata.Inputs == null ||
            inputValues == null) {
            return;
        }

        for (InputContext ic : myEmailMetadata.Inputs) {
            if (inputValues.containsKey(ic.TargetField) == false ||
                inputValues.get(ic.TargetField) == '[]') {
                inputValues.put(ic.TargetField, '');
            }
        }
    }

    public class EmailBuilderContext {
        @AuraEnabled
        public List<MarketingCloudService.EmailTemplate> AvailableEmailTemplates { get; set; }
        
        @AuraEnabled
        public Boolean Success { get; set; }
        
        @AuraEnabled
        public String Message { get; set; }
        
        public EmailBuilderContext() {
            AvailableEmailTemplates = new List<MarketingCloudService.EmailTemplate>();
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

    public class SendEmailResult {
        @AuraEnabled
        public String Message { get; set; }
    }
    
    public class EmailMetadata {
        public List<DataSelector> DataSelectors = new List<DataSelector>();
        public List<InputContext> Inputs = new List<InputContext>();
        
        public EmailMetadata(String emailMetadataJSON) {
            if (string.isBlank(emailMetadataJSON)) {
	            return;
	        }
	
	        List<Object> sectionsMetadata = (List<Object>) JSON.deserializeUntyped(emailMetadataJSON);
	        
	        system.debug('   EmailMetadata Constructor::sectionsMetadata: ' + sectionsMetadata);
	        
	        for (Object sectionMetadata : sectionsMetadata) {
	            system.debug('  EmailMetadata::sectionMetadata: ' + sectionMetadata);
	            Map<String, Object> sectionMetadataMap = (Map<String, Object>) sectionMetadata;
	            
	            if (sectionMetadataMap.containsKey('DataSelectors')) {
	                loadDataSelectors(sectionMetadataMap);
	            }
	            
	            if (sectionMetadataMap.containsKey('Inputs')) {
	                loadInputs(sectionMetadataMap);
	            }
	        }
        }
        
        private void loadDataSelectors(Map<String, Object> sectionMetadataMap) {
            List<Object> dataSelectorsList = (List<Object>) sectionMetadataMap.get('DataSelectors');
            
            for (Object dataSelectorObj : dataSelectorsList) {
                Map<String, Object> dataSelectorMap = (Map<String, Object>) dataSelectorObj;

                DataSelector ds = new DataSelector();
                ds.Type = (String) dataSelectorMap.get('Type');
                ds.TargetField = (String) dataSelectorMap.get('TargetField');
                ds.SelectFields = (String) dataSelectorMap.get('SelectFields');
                ds.ObjectName = (String) dataSelectorMap.get('Object');
                ds.WhereClause = (String) dataSelectorMap.get('Where');
                ds.OrderBy = (String) dataSelectorMap.get('OrderBy');
                
                DataSelectors.add(ds);
            }
        }
        
        private void loadInputs(Map<String, Object> sectionMetadataMap) {
            List<Object> inputsList = (List<Object>) sectionMetadataMap.get('Inputs');
            
            for (Object inputObj : inputsList) {
                Map<String, Object> inputMap = (Map<String, Object>) inputObj;

                InputContext ic = new InputContext(inputMap);
                Inputs.add(ic);
                
                if (!inputMap.containsKey('DependentInputs')) {
                    continue;
                }
                
                List<Object> dependentInputsList = (List<Object>) inputMap.get('DependentInputs');
                
                for (Object dependentInputObj : dependentInputsList) {
                    Map<String, Object> dependentInputMap = (Map<String, Object>) dependentInputObj;

                    InputContext dependentIC = new InputContext(dependentInputMap);
                    Inputs.add(dependentIC);
                }
            }
        }
    }
    
    public class DataSelector {
        public String Type { get; set; }
        public String TargetField { get; set; }
        public String SelectFields { get; set; }
        public String WhereClause { get; set; }
        public String OrderBy { get; set; }
        public String ObjectName { get; set; }
    }
    
    public class InputContext {
        public String Type { get; set; }
        public String TargetField { get; set; }
        public String SelectField { get; set; }
        public String Label { get; set; }
        public String ObjectName { get; set; }
        public String SearchField { get; set; }
        public String Filter { get; set; }
        public String HelpText { get; set; }
        public List<String> Options { get; set; }
        
        public InputContext(Map<String, Object> inputMap) {
            Options = new List<String>();
            
            Type = (String) inputMap.get('Type');
            TargetField = (String) inputMap.get('TargetField');
            SelectField = (String) inputMap.get('SelectField');
            Label = (String) inputMap.get('Label');
            ObjectName = (String) inputMap.get('Object');
            SearchField = (String) inputMap.get('SearchField');
            Filter = (String) inputMap.get('Filter');
            HelpText = (String) inputMap.get('HelpText');
                
            if (inputMap.containsKey('Options') &&
                inputMap.get('Options') != null) {

                for (Object optionObj : (List<Object>) inputMap.get('Options')) {
                    Options.add((String) optionObj);
                }
            }
        }
    }
    
    public class EditExistingDataLinkContext {
        @AuraEnabled
        public String RecordId { get; set; }
    }
    
    private class EditExistingDataMetadata {
        public String SelectFields { get; set; }
        
        public String ObjectName { get; set; }
        
        public String WhereClause { get; set; }
        
        public String RecordIdField { get; set; }
        
        public EditExistingDataMetadata(String jsonMetadata) {
            Map<String, Object> metadataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonMetadata);
            
            Map<String, Object> queryMap = (Map<String, Object>) metadataMap.get('Query');
            
            SelectFields = (String) queryMap.get('SelectFields');
            ObjectName = (String) queryMap.get('Object');
            WhereClause = (String) queryMap.get('Where');
            
            RecordIdField = (String) metadataMap.get('RecordIdField');
        }
    }
}