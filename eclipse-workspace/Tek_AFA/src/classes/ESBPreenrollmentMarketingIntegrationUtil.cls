public without sharing class ESBPreenrollmentMarketingIntegrationUtil {

    private static Organization orgPriv = null;
    public static Organization Organization {
        get {
            if (orgPriv == null) {
                orgPriv = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
            }
            
            return orgPriv;
        }
    }
    
    public static String buildEmployerFieldSchedulerURL(String token) {
        Field_Scheduler_UI_Settings__c fieldSchedulerUISettings = Field_Scheduler_UI_Settings__c.getInstance();
        
        String baseURL = fieldSchedulerUISettings.Production_URL__c;
        
        if (Organization.IsSandbox) {
            baseURL = fieldSchedulerUISettings.Sandbox_URL__c;
        }
        
        return baseURL + '/' + token + '/';
    }
    
    
    public static String buildMicrositeJSON(Pre_Enrollment_Marketing_Form__c marketingForm, List<Marketed_Product__c> employerBenefitSiteProducts) {
        String micrositeJSON = '"Microsite": { ';
        
        // core products
        micrositeJSON += '  "CoreProducts": [';
        
        List<String> productJSONs = new List<String>();
        List<String> productResourceIds = new List<String>();
        for (Marketed_Product__c product : employerBenefitSiteProducts) {
            String productJSON = '{';
            
            productJSON += buildPropertyJSONWithComma('CarrierName', product.Carrier__c);
            productJSON += buildPropertyJSONWithComma('ProductName', product.Products__r.Name);
            productJSON += buildPropertyJSONWithComma('ResourceId', product.Products__r.Resource_ID__c);
            productJSON += buildPropertyJSON('Url', product.Carrier_URL__c);
            
            productJSON += '}';
            
            productJSONS.add(productJSON);
            productResourceIds.add(product.Products__r.Resource_ID__c);
        }

        micrositeJSON += String.join(productJSONs, ',');

        micrositeJSON += '], ';

        micrositeJSON += buildPropertyJSONWithComma('OpenEnrollmentDateEnd', formatDateTime(marketingForm.Open_Enrollment_End__c));
        micrositeJSON += buildPropertyJSONWithComma('OpenEnrollmentDateStart', formatDateTime(marketingForm.Open_Enrollment_Sart__c));
        
        micrositeJSON += buildPropertyArrayJSON('PageContentResourceIds', productResourceIds);

        micrositeJSON += '}';

        return micrositeJSON;
    }
    
    public static String buildEmployerRecordKeyJSON(Opportunity enrollmentOpportunity) {
        String sourceSystem = 'Salesforce';
        String sourceKey = enrollmentOpportunity.AccountId;
        
        system.debug('    buildEmployerRecordKeyJSON::enrollmentOpportunity ' + enrollmentOpportunity);
        
        if (string.isNotBlank(enrollmentOpportunity.Account.Marketing_Resource_ID__c)) {
            sourceSystem = 'Marketing';
            sourceKey = enrollmentOpportunity.Account.Marketing_Resource_ID__c;
        }
        
        return buildRecordKeyJSON(sourceSystem, sourceKey);
    }
    
    public static String buildEmployerKeyJSON(Account employer) {
        String sourceSystem = 'Salesforce';
        String sourceKey = employer.Id;
        
        system.debug('    buildEmployerKeyJSON::employer ' + employer);
        
        if (string.isNotBlank(employer.Marketing_Resource_ID__c)) {
            sourceSystem = 'Marketing';
            sourceKey = employer.Marketing_Resource_ID__c;
        }
        
        return buildEmployerKeyJSON(sourceSystem, sourceKey);
    }
    
    public static String buildEmployerKeyJSON(Opportunity enrollmentOpportunity) {
        return buildEmployerKeyJSON('Salesforce', enrollmentOpportunity.AccountId);
    }
    
    public static String buildEmployerKeyJSON(String sourceSystem, String employerSourceKey) {
        return '"EmployerKey":{ "SourceSystem": "' + sourceSystem + '", ' +
                   ' "SourceKey": "' + employerSourceKey + '" }';
    }
    
    public static String buildEnrollmentMethodsJSON(Pre_Enrollment_Marketing_Form__c marketingForm) {
        List<String> enrollmentMethods = new List<String>();
        
        if (marketingForm.Show_Kiosk_Information__c) {
            enrollmentMethods.add('"Show_Kiosk_Information__c"');
        }
        
        if (marketingForm.Show_One_on_One_Information__c) {
            enrollmentMethods.add('"Show_One_on_One_Information__c"');
        }
        
        if (marketingForm.Show_Self_Service_Information__c) {
            enrollmentMethods.add('"Show_Self_Service_Information__c"');
        }
        
        if (marketingForm.Show_AF_HR_Central_Information__c) {
            enrollmentMethods.add('"Show_AF_HR_Central_Information__c"');
        }
        
        return '"EnrollmentMethods": [' +
                   String.join(enrollmentMethods, ',') +
               ']';
    }
    
    public static String buildAgentJSON(Opportunity enrollmentOpportunity) {
        system.debug('    buildAgentJSON::enrollmentOpportunity.Branch_Office__c ' + enrollmentOpportunity.Branch_Office__c);
        String branchJSON = enrollmentOpportunity.Branch_Office__c != null ? buildBranchJSON(enrollmentOpportunity) + ', ' : '"Branch": null, ';
        
        system.debug('    buildAgentJSON::branchJSON ' + branchJSON);
        
        String agentJSON = '"Agent": {' +
                           '  "AgentLicenses": [], ' +
                              buildPropertyJSONWithComma('AgentNumber', enrollmentOpportunity.Assigned_Account_Manager__r.Agent_Id__c) +
                           branchJSON;
                              
              agentJSON += buildPropertyJSONWithComma('EmailAddress', enrollmentOpportunity.Assigned_Account_Manager__r.Email) +
                           buildPropertyJSONWithComma('Extension', enrollmentOpportunity.Assigned_Account_Manager__r.Extension) +
                           buildPropertyJSONWithComma('FirstName', enrollmentOpportunity.Assigned_Account_Manager__r.FirstName) +
                           buildPropertyJSONWithComma('LastName', enrollmentOpportunity.Assigned_Account_Manager__r.LastName) +
                           buildRecordKeyJSON('Salesforce', enrollmentOpportunity.Assigned_Account_Manager__c) + ', ' +
                           buildPropertyJSON('Title', enrollmentOpportunity.Assigned_Account_Manager__r.Title) +
                           '}';
        
        return agentJSON;
    }
    
    public static String buildBranchJSON(Opportunity enrollmentOpportunity) {
        String branchJSON = '"Branch": { ' +
                               buildPropertyJSONWithComma('AddressLine', enrollmentOpportunity.Branch_Office__r.Address__c) +
                               buildPropertyJSONWithComma('CityName', enrollmentOpportunity.Branch_Office__r.City__c) +
                               buildPropertyJSONWithComma('DisplayName', enrollmentOpportunity.Branch_Office__r.Name) +
                               buildPropertyJSONWithComma('LocalNumber', enrollmentOpportunity.Branch_Office__r.Local_Phone__c) +
                               buildPropertyJSONWithComma('PostalCode', enrollmentOpportunity.Branch_Office__r.Zip__c) +
                               buildRecordKeyJSON('Marketing', enrollmentOpportunity.Branch_Office__r.Resource_ID__c) + ', ' +
                               buildPropertyJSONWithComma('StateCode', enrollmentOpportunity.Branch_Office__r.State__c) +
                               buildPropertyJSON('TollFreeNumber', enrollmentOpportunity.Branch_Office__r.Toll_Free_Phone__c) +
                            '}';
        
        return branchJSON;
    }
    
    public static String buildRecordKeyJSON(String sourceSystem, String sourceKey) {
        return '  "RecordKey": { ' +
               buildPropertyJSONWithComma('SourceSystem', sourceSystem) +
               buildPropertyJSON('SourceKey', sourceKey) +
               '  } ';
    }
    
    public static String buildOnBehalfOfJSON(Opportunity enrollmentOpportunity) {
        return buildOnBehalfOfJSON(enrollmentOpportunity.OwnerId);
    }
    
    public static String buildOnBehalfOfCurrentUserJSON() {
        return buildOnBehalfOfJSON(UserInfo.getUserId());
    }
    
    public static String buildOnBehalfOfJSON(Id onBehalfOfId) {
        String onBehalfOfJSON = '"OnBehalfOf": { ' +
                            '  "SourceSystem": "Salesforce", ' +
                            '  "SourceKey": "' + onBehalfOfId + '" ' + 
                            '}';
        
        return onBehalfOfJSON;
    }
    
    public static String buildPropertyJSONWithComma(String propertyName, Object propertyValue) {
        return buildPropertyJSON(propertyName, propertyValue) + ', ';
    }
    
    public static String buildPropertyJSON(String propertyName, Object propertyValue) {
        String propertyValueJSON = propertyValue != null ? '"' + String.valueOf(propertyValue) + '"' : 'null';
        
        return '  "' + propertyName + '": ' + propertyValueJSON;
    }
    
    public static String buildPropertyArrayJSON(String propertyName, List<String> arrayValues) {
        List<String> formattedArrayValues = new List<String>();
        
        for (String arrayValue : arrayValues) {
            formattedArrayValues.add('"' + arrayValue + '"');
        }
        
        String formattedArrayValuesJSON = String.join(formattedArrayValues, ',');
        
        return '  "' + propertyName + '": [' +
               '  ' + formattedArrayValuesJSON + ' ]';
    }
    
    public static String formatDateTime(Date dateToFormat) {
        if (dateToFormat == null) {
            return null;
        }
        
        DateTime dt = dateToFormat;

        return dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
    }
}