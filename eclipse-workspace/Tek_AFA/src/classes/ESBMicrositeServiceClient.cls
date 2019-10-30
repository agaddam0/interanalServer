public without sharing class ESBMicrositeServiceClient extends ESBServiceBase {
    public static final String PREENROLLMENT_MARKETING_FORM_ID_REQUIRED_MESSAGE = 'The preenrollment marketing form id is required.';
    public static final String MICROSITE_PATH = '/salesforce/integration/marketing/microsite-upsert/';
    
    private Id PreenrollmentMarketingFormId { get; set; }
    private Integer AttemptNumber { get; set; }
    
    public ESBMicrositeServiceClient(Id preenrollmentMarketingFormIdArg) {
        this(preenrollmentMarketingFormIdArg, 1);
    }

    public ESBMicrositeServiceClient(Id preenrollmentMarketingFormIdArg, Integer attemptNumberArg) {
        super(ESBServiceBase.SANDBOX_PREENROLLMENT_MARKETING_API_MANAGER_NAME, ESBServiceBase.PRODUCTION_PREENROLLMENT_MARKETING_API_MANAGER_NAME);
        
        if (preenrollmentMarketingFormIdArg == null) {
            throw new ESBMicrositeServiceClientException(PREENROLLMENT_MARKETING_FORM_ID_REQUIRED_MESSAGE);
        }
        
        PreenrollmentMarketingFormId = preenrollmentMarketingFormIdArg;
        
        AttemptNumber = attemptNumberArg != null ? attemptNumberArg : 1;
    }    
    
    public ESBMicrositeUpsertResult UpsertMicrosite() {
        HttpRequest request;
        HttpResponse response;
        Exception micrositeException;
        Pre_Enrollment_Marketing_Form__c marketingForm;
        List<Marketed_Product__c> employerBenefitSiteProducts;
        ESBMicrositeUpsertResult upsertResult = new ESBMicrositeUpsertResult();
        
        try {
            ESBAuthenticator authenticator = new ESBAuthenticator(ESBServiceBase.PREENROLLMENT_MARKETING_INTEGRATION_NAME, ESBServiceBase.SANDBOX_PREENROLLMENT_MARKETING_API_MANAGER_NAME, ESBServiceBase.PRODUCTION_PREENROLLMENT_MARKETING_API_MANAGER_NAME);
            authenticator.InsertLogsWhenComplete = false;
            String authToken = authenticator.authenticate();
            
            if (String.isBlank(authToken)) {
                upsertResult.Success = false;
                upsertResult.Message = 'The auth token is blank';
                
                return upsertResult;
            }
            
            marketingForm = getMarketingForm();
            employerBenefitSiteProducts = getEmployerBenefitSiteProducts(marketingForm.Enrollment_Form__c);
            
            request = buildMicrositeRequest(marketingForm, employerBenefitSiteProducts, authToken);
            response = new Http().send(request);
            
            if(response == null) {
                upsertResult.Success = false;
                upsertResult.Message = 'The microsite response is blank';
                
                return upsertResult;
            }
            
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            if (response.getStatusCode() == 200) {
                String status = (String) results.get('Status');
                
                if (String.isNotBlank(status) &&
                    status != 'Ok') {
                    Object errors = results.get('Errors');
                    throw new ESBMicrositeServiceClientException(String.valueOf(errors));
                }
            }
            else {
                Object errors = results.get('Errors');
                throw new ESBMicrositeServiceClientException(String.valueOf(errors));
            }
        }
        catch(Exception ex) {
            micrositeException = ex;
            
            upsertResult.Success = false;
            upsertResult.Message = ex.getMessage();
        }
        finally {
            String contextualInfo = 'Attempting ESB Microsite Upsert...\n\n';
            
            if (PreenrollmentMarketingFormId != null) {
                contextualInfo += 'Preenrollment Marketing Form Id: ' + PreenrollmentMarketingFormId + '\n\n';
            }
            
            if (marketingForm != null) {
                contextualInfo += 'Marketing Form Record: ' + marketingForm + '\n\n';
            }
            
            if (employerBenefitSiteProducts != null) {
                contextualInfo += 'Number of employer benefit site products: ' + employerBenefitSiteProducts.size() + '\n\n';
                
                for (Marketed_Product__c employerBenefitSiteProduct : employerBenefitSiteProducts) {
                    contextualInfo += 'Employer Benefit Site Product: ' + employerBenefitSiteProduct + '\n\n';
                }
            }
            
            if (AttemptNumber != null) {
                contextualInfo += 'Attempt Number: ' + AttemptNumber + '\n\n';
            }
            
            if (upsertResult != null) {
                contextualInfo += 'upsertResult.Success: ' + upsertResult.Success + '\n';
                contextualInfo += 'upsertResult.Message: ' + upsertResult.Message + '\n\n';
            }
            
            IntegrationLogger.Instance.addIntegrationLog(ESBServiceBase.PREENROLLMENT_MARKETING_INTEGRATION_NAME, request, response, micrositeException, contextualInfo, AttemptNumber);
            IntegrationLogger.Instance.insertLogs();
        }

        return upsertResult;
    }
    
    private Pre_Enrollment_Marketing_Form__c getMarketingForm() {
        return
        [SELECT Id,
                Name,
                Enrollment_Form__c,
                Enrollment_Form__r.Enrollment_Opportunity__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Name,
                Enrollment_Form__r.Enrollment_Opportunity__r.AccountId,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.Name,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.BillingState,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.MCP_Number__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.Marketing_Resource_ID__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Group_Display_Name__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.FirstName,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.LastName,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.Street,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.City,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.State,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.PostalCode,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.Email,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.Extension,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.Id,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.Title,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.Agent_Id__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.Job_Title__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Assigned_Account_Manager__r.License_No__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Name,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Address__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Charge_Code__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.City__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Copy_Code__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Extension__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Fax__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Local_Phone__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Mailing_Code__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Resource_ID__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Staffed__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.State__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Toll_Free_Phone__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Branch_Office__r.Zip__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.OwnerId,
                Show_Kiosk_Information__c,
                Show_One_on_One_Information__c,
                Show_Self_Service_Information__c,
                Show_AF_HR_Central_Information__c,
                Open_Enrollment_Sart__c,
                Open_Enrollment_End__c
           FROM Pre_Enrollment_Marketing_Form__c
          WHERE Id = :PreenrollmentMarketingFormId];
    }
    
    private List<Marketed_Product__c> getEmployerBenefitSiteProducts(Id enrollmentFormId) {
        return
        [SELECT Id,
                Name,
                Carrier__c,
                Carrier_URL__c,
                Products__r.Name,
                Products__r.Resource_ID__c
           FROM Marketed_Product__c
          WHERE Enrollment__c = :enrollmentFormId
            AND Include_On_Employer_Benefits_Site__c = true
            AND Enrollment__r.Enrollment_Opportunity__r.Employer_Benefits_Site__c = 'Yes'];
    }
    
    private HttpRequest buildMicrositeRequest(Pre_Enrollment_Marketing_Form__c marketingForm, List<Marketed_Product__c> employerBenefitSiteProducts, String bearerToken) {
        API_Manager__c api = super.getAPIManager();
        HttpRequest request = super.buildAuthorizedHttpRequestTemplate(bearerToken);
        
        String endpoint = api.Endpoint__c + MICROSITE_PATH;
        request.setEndpoint(endpoint);
        request.setBody( buildMicrositeRequestBody(marketingForm, employerBenefitSiteProducts) );
        
        return request;
    }
    
    private String buildMicrositeRequestBody(Pre_Enrollment_Marketing_Form__c marketingForm, List<Marketed_Product__c> employerBenefitSiteProducts) {
        Opportunity enrollmentOpportunity = marketingForm.Enrollment_Form__r.Enrollment_Opportunity__r;
        
        String micrositeBody = '{';
        
        micrositeBody += ESBPreenrollmentMarketingIntegrationUtil.buildAgentJSON(enrollmentOpportunity) + ', ';
        micrositeBody += ESBPreenrollmentMarketingIntegrationUtil.buildEmployerKeyJSON(enrollmentOpportunity) + ', ';
        micrositeBody += ESBPreenrollmentMarketingIntegrationUtil.buildEnrollmentMethodsJSON(marketingForm) + ', ';
        micrositeBody += ESBPreenrollmentMarketingIntegrationUtil.buildMicrositeJSON(marketingForm, employerBenefitSiteProducts) + ', ';
        micrositeBody += ESBPreenrollmentMarketingIntegrationUtil.buildOnBehalfOfJSON(enrollmentOpportunity);
        micrositeBody += '}';
        
        return micrositeBody;
    }
    
    public class ESBMicrositeServiceClientException extends Exception { }

    public class ESBMicrositeUpsertResult {
        public Boolean Success { get; set; }
        public String Message { get; set; }
        
        public ESBMicrositeUpsertResult() {
            Success = true;
            Message = '';
        }
    }
}