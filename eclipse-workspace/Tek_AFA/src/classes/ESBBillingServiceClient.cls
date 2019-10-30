public without sharing class ESBBillingServiceClient extends ESBServiceBase {
    public static final String PAYOR_NUMBER_REQUIRED_MESSAGE = 'The payor number is required.';
    public static final String CONSOLIDATED_BILL_ID_REQUIRED_MESSAGE = 'The bill id is required.';
    
    public static final String SANDBOX_BILLING_API_MANAGER_NAME = 'QA Billing';
    public static final String PRODUCTION_BILLING_API_MANAGER_NAME = 'Billing';
    public static final String BILLING_INTEGRATION_NAME = 'Billing';
    public static final String CONSOLIDATED_BILLING_API_PATH = '/marketing/integration-services/billing/bills/';
    public static final String ADMIN_COVERAGE_BILLING_API_PATH = '/marketing/integration-services/billing/bills/details/';
    public static final String NO_BILLS_FOUND_FRIENDLY_MSG = 'No bills found.';
    
    public String AdditionalContextualLogInfo { get; set; }

    public ESBBillingServiceClient() {
        super(SANDBOX_BILLING_API_MANAGER_NAME, PRODUCTION_BILLING_API_MANAGER_NAME);
        AdditionalContextualLogInfo = '';
    }

    public BrowseBillsResponse browseByPayorMaster(String payorNumber, Boolean includeHistoryBills, Boolean includeCurrentBills, String accountId) {
        HttpRequest request;
        HttpResponse response;
        Exception browseException;
        BrowseBillsResponse result = new BrowseBillsResponse();

        try {
            if (String.isBlank(payorNumber)) {
                throw new ESBBillingServiceClientException(PAYOR_NUMBER_REQUIRED_MESSAGE);
            }

            super.authenticate(BILLING_INTEGRATION_NAME);
            
            request = buildBrowseByPayorMasterRequest(payorNumber, includeHistoryBills, includeCurrentBills, authToken);
            response = new Http().send(request);
            
            if (response.getStatusCode() == 200) {
                result = buildBrowseBillsResponseResult(response);
                
                // Service invoked successfully but it returned an error
                if (result.Success == false) {
                    throw new ESBBillingServiceClientException(result.Message);
                }
            }
            // Some unexpected error happened
            else {
                String friendlyErrorMessage = buildFriendlyPayorMasterErrorMessage(response.getBody());
                
                if (friendlyErrorMessage != NO_BILLS_FOUND_FRIENDLY_MSG) {
                    throw new ESBBillingServiceClientException(friendlyErrorMessage);
                }
            }
        }
        catch(Exception ex) {
            browseException = ex;
            
            result.Success = false;
            result.Message = ex.getMessage();
        }
        finally {
            String contextualInfo = 'Attempting ESB Billing Browse By Payor Master...\n\n';
            
            if (String.isNotBlank(payorNumber)) {
                contextualInfo += 'payorNumber: ' + payorNumber + '\n\n';
            }

            if (includeHistoryBills != null) {
                contextualInfo += 'includeHistoryBills: ' + includeHistoryBills + '\n\n';
            }

            if (includeCurrentBills != null) {
                contextualInfo += 'includeCurrentBills: ' + includeCurrentBills + '\n\n';
            }

            if (String.isNotBlank(AdditionalContextualLogInfo)) {
                contextualInfo += AdditionalContextualLogInfo + '\n\n';
            }

            if (result != null) {
                contextualInfo += 'result.Success: ' + result.Success + '\n';
                contextualInfo += 'result.Message: ' + result.Message + '\n\n';
            }

            IntegrationLogger.Instance.addIntegrationLog(Billing_INTEGRATION_NAME, request, response, browseException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }

        return result;
    }
    
    public ConsolidatedBillResponse browseByCBillId(String consolidatedBillId, String accountId) {
        HttpRequest request;
        HttpResponse response;
        Exception browseException;
        ConsolidatedBillResponse result = new ConsolidatedBillResponse();

        try {
            if (String.isBlank(consolidatedBillId)) {
                throw new ESBBillingServiceClientException(CONSOLIDATED_BILL_ID_REQUIRED_MESSAGE);
            }

            super.authenticate(BILLING_INTEGRATION_NAME);
            
            request = buildBrowseByCBillIdRequest(consolidatedBillId, authToken);
            response = new Http().send(request);
            
            Integer statusCode = response.getStatusCode();
            
            if (response.getStatusCode() == 200) {
                result = buildConsolidatedBillResponseResult(response);
                
                // Service invoked successfully but it returned an error
                if (result.Success == false) {
                    throw new ESBBillingServiceClientException(result.Message);
                }
            }
            // Some unexpected error happened
            else {
                throw new ESBBillingServiceClientException(response.getBody());
            }
        }
        catch(Exception ex) {
            browseException = ex;
            
            result.Success = false;
            result.Message = ex.getMessage();
            result.Message += '\n' + ex.getStackTraceString();
        }
        finally {
            String contextualInfo = 'Attempting ESB Billing Browse By Consolidated Bill Id...\n\n';
            
            if (String.isNotBlank(consolidatedBillId)) {
                contextualInfo += 'consolidatedBillId: ' + consolidatedBillId + '\n\n';
            }

            if (String.isNotBlank(AdditionalContextualLogInfo)) {
                contextualInfo += AdditionalContextualLogInfo + '\n\n';
            }

            if (result != null) {
                contextualInfo += 'result.Success: ' + result.Success + '\n';
                contextualInfo += 'result.Message: ' + result.Message + '\n\n';
            }

            IntegrationLogger.Instance.setFilterer(new ESBBillingDetailLogFilter());
            IntegrationLogger.Instance.addIntegrationLog(Billing_INTEGRATION_NAME, request, response, browseException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }

        return result;
    }
    
    private HttpRequest buildBrowseByPayorMasterRequest(String payorNumber, Boolean includeHistoryBills, Boolean includeCurrentBills, String authToken) {
        HttpRequest request = super.buildAuthorizedHttpRequestTemplate(authToken);
        API_Manager__c api = super.getAPIManager();
        
        String endpoint = api.Endpoint__c + CONSOLIDATED_BILLING_API_PATH;
        request.setEndpoint(endpoint);
        request.setBody( buildBrowseByPayorMasterRequestBody(payorNumber, includeHistoryBills, includeCurrentBills));
        request.setTimeout(120000);
        
        return request;
    }
    
    @testVisible
    private String buildBrowseByPayorMasterRequestBody(String payorNumber, Boolean includeHistoryBills, Boolean includeCurrentBills) {
        String body =
            '{' + 
                '"ArchivedBills": ' + includeHistoryBills + ',' + 
                '"CurrentBills": ' + includeCurrentBills + ',' + 
                '"PayorNumber": "' + payorNumber + '",' +
                '"BillHeaderFields": [' +
                    '"BillDeliveryMethodInd",' +
                    '"BillDescriptions",' + 
                    '"BillDueDate",' +
                    '"BillHeaderId",' + 
                    '"BillPaidFlag",' + 
                    '"BillStatusCode",' + 
                    '"BillStatusDate",' +
                    '"BillStatusDesc",' + 
                    '"CBillBilledAmt",' +
                    '"CBillDetailCnt",' +
                    '"CBillHeaderCnt",' + 
                    '"CBillId",' +
                    '"InvoiceNumber",' +
                    '"CBillReconAmt",' +
                    '"HasReBillsFlag",' +
                    '"PayorNumMaster",' +
                    '"PayorServiceTeam",' +
                    '"ReconMethodCode",' +
                    '"ReconMethodDesc",' +
                    '"TotalPaymentAmt",' +
                    '"UpdateTimestamp",' +
                    '"UpdateDateTime",' +
                    '"Bills"],' +
                '"OnBehalfOf": {' + 
                    '"SourceSystem": "Salesforce",' +
                    // SourceKey needs to be the current running user id for API logging purposes.
                    '"SourceKey": "' + UserInfo.getUserId() + '"' + 
                '}' +
            '}';
        
        return body;
    }
    
    private BrowseBillsResponse buildBrowseBillsResponseResult(HttpResponse response) {
        return buildBrowseBillsResponseResultFromJSON(response.getBody());
    }

    public static BrowseBillsResponse buildBrowseBillsResponseResultFromJSON(String jsonResponse) {
        Map<String, Object> rMap = (Map<String, Object>)  JSON.deserializeUntyped(jsonResponse);
        BrowseBillsResponse result = new BrowseBillsResponse();
        
        String status = (String) rMap.get('Status');
                
        if (String.isNotBlank(status) &&
            status != 'Ok') {
            
            Object errors = rMap.get('Errors');
            result.Success = false;
            result.Message = String.valueOf(errors);
            
            return result;
        }
        
        List<Object> billHeaders = (List<Object>) rMap.get('BillHeaders');
        
        for (Object billHeaderObj : billHeaders) {
            Map<String, Object> billHeader = (Map<String, Object>) billHeaderObj;
            List<Object> bills = (List<Object>) billHeader.get('Bills');
            Map<String, Object> billHeaderDetails = (Map<String, Object>) bills[0];
            
            
            ConsolidatedBill cb = new ConsolidatedBill();
            cb.PayorNumber = (String) billHeader.get('PayorNumMaster');
            cb.BillId = (String) billHeader.get('CBillId');
            cb.InvoiceNumber = (String) billHeaderDetails.get('InvoiceNum');
            cb.InvoiceDate = convertToFormattedDate((String) billHeaderDetails.get('InvoiceDate'));
            
            cb.Team = (String) billHeaderDetails.get('DivsnName');
            cb.AccountName = (String) billHeaderDetails.get('CustNameMcp');
            cb.ReconciledAmount = (Decimal) billHeaderDetails.get('BillHeaderReconAmt');
            cb.TotalPaymentAmount = (Decimal) billHeader.get('TotalPaymentAmt');
            cb.BilledAmount = (Decimal) billHeader.get('CBillBilledAmt');
            
            cb.BillPeriodFromDate = convertToFormattedDate((String) billHeaderDetails.get('BillPeriodFromDate'));
            
            cb.BillStatus = (String) billHeaderDetails.get('BillStatusDesc');
            cb.CustomerMCPNumber = (String) billHeaderDetails.get('CustNumMcp');
            cb.CustomerMCPName = (String) billHeaderDetails.get('CustNameMcp');
            cb.BillDescription = (String) billHeaderDetails.get('BillDescription');
            cb.DistributionId = (String) billHeaderDetails.get('DistributionId');
            cb.BillType = (String) billHeaderDetails.get('BillTypeDesc');
            cb.DueDate = convertToFormattedDate((String) billHeader.get('BillDueDate'));
            cb.InvoiceNumberReplaced = (String) billHeaderDetails.get('InvoiceNumReplaced');
            
            String billPeriodToDateString = (String) billHeaderDetails.get('BillPeriodToDate');
            
            if (String.isNotBlank(billPeriodToDateString)) {
                cb.BillPeriodToDate = convertToFormattedDate(billPeriodToDateString);
            }
            
            result.Bills.add(cb);
        }

        return result;
    }
    
    private String buildFriendlyPayorMasterErrorMessage(String response) {
        String friendlyErrorMessage = 'We are unable to retrieve bills at this time.';
        
        if (String.isNotBlank(response) &&
            response.containsIgnoreCase('Payor Master not found.')) {
            friendlyErrorMessage = 'Payor Number not found.';
        }

        if (String.isNotBlank(response) &&
            response.containsIgnoreCase('C-Bills not found.')) {
            friendlyErrorMessage = NO_BILLS_FOUND_FRIENDLY_MSG;
        }
        
        return friendlyErrorMessage;
    }
    
    private HttpRequest buildBrowseByCBillIdRequest(String consolidatedBillId, String authToken) {        
        HttpRequest request = super.buildAuthorizedHttpRequestTemplate(authToken);
        API_Manager__c api = super.getAPIManager();
        
        String endpoint = api.Endpoint__c + ADMIN_COVERAGE_BILLING_API_PATH;
        request.setEndpoint(endpoint);
        request.setBody( buildBrowseByCBillIdRequestBody(consolidatedBillId));
        request.setTimeout(120000);
        
        return request;
    }
    
    @testVisible
    private String buildBrowseByCBillIdRequestBody(String billId) {
        Billing_API_Settings__c billingAPISettings = Billing_API_Settings__c.getInstance();
        
        /*{             
               CBillId:2666071,
               BillDetailFields:"",
               OnBehalfOf:{
                   SourceKey:"SourceKey",
                   SourceSystem:"SourceSystem"
               }
               'FederalIdNum', 'NameFirst', 'NameLast', 'ProductBilledCode', 'CoveredIndsCode', 'FreqInd', 'ReferenceNum', 'BilledAmtUnalloc', 'ReconAmtUnalloc', 'BillDetailRemarks', 'BillChgReasonCode'
        }*/
        
        String body = '{';
        body += '"CBillId": "' + billId + '",';
        body += '"BillDetailFields":["FederalIdNum","NameFirst","NameLast","ProductBilledCode","CoveredIndsCode","FreqInd","ReferenceNum","BilledAmtUnalloc","ReconAmtUnalloc","BillDetailRemarks","BillChgReasonCode"],';
        body += '"OnBehalfOf":{';
        // SourceKey needs to be the current running user id for API logging purposes.
        body +=     '"SourceKey":"' + UserInfo.getUserId() + '",';
        body +=     '"SourceSystem":"Salesforce"}}';

        return body;
    }
    
    public static ConsolidatedBillResponse buildConsolidatedBillResponseFromJSON(String jsonResponse) {
        /*
            {"BillDetailList":"[{
                \"BillChgReasonCode\":\"\",
                \"BillDetailRemarks\":\"\",
                \"BillPeriodFromDate\":\"2018-09-01T00:00:00\",
                \"BilledAmtUnalloc\":100.00,
                \"CoveredIndsCode\":\"\",
                \"FederalIdNum\":\"#########\",
                \"FreqInd\":\"\",
                \"NameFirst\":\"PAMELA\",
                \"NameLast\":\"ALLEN\",
                \"ProductBilledCode\":\"RIRA\",
                \"ReconAmtUnalloc\":100.00,
                \"ReferenceNum\":\"7330382\"}
             ],
             "Success":true,
             "Requester":null,
             "Errors":[],
             "Status":"OK"},
        */
        
        system.debug('  jsonResponse: ' + jsonResponse);
        
        Map<String, Object> rMap = (Map<String, Object>)  JSON.deserializeUntyped(jsonResponse);
        
        
        ConsolidatedBillResponse billResponse = new ConsolidatedBillResponse();
        Map<String, PolicyHolder> policyHoldersBySSN = new Map<String, PolicyHolder>();
        
        String status = (String) rMap.get('Status');
                
        if (String.isNotBlank(status) &&
            status != 'Ok') {
            
            Object errors = rMap.get('Errors');
            billResponse.Success = false;
            billResponse.Message = String.valueOf(errors);
            
            return billResponse;
        }
        
        List<Object> billDetails = null;
        
        if (jsonResponse.contains('"BillDetailList":"[')) {
            String billDetailsString = (String) rMap.get('BillDetailList');
            billDetails = (List<Object>) JSON.deserializeUntyped(billDetailsString);
        }
        else {
            billDetails = (List<Object>) rMap.get('BillDetailList');
        }
		
		for (Object billDetailObj : billDetails) {
		    Map<String, Object> billDetail = (Map<String, Object>) billDetailObj;
		    
		    String ssn = (String) billDetail.get('FederalIdNum');
		    String firstName = (String) billDetail.get('NameFirst');
		    
		    if (String.isNotBlank(firstName)) {
		        firstName = firstName.toUpperCase();
		    }

		    String lastName = (String) billDetail.get('NameLast');

            if (String.isNotBlank(lastName)) {
                lastName = lastName.toUpperCase();
            }

		    String policyHolderKey = ssn + firstName + lastName;

            PolicyHolder ph = policyHoldersBySSN.get(policyHolderKey);

            if (ph == null) {
                ph = new PolicyHolder();
                
                // The SSN may be blank if the Billing department adds
                // a miscellaneous billing fee.
                if (String.isNotBlank(ssn)) {
                    // Show the last 4 digits only
                    ph.SSN = 'XXX-XX-' + ssn.right(4);
                }
                
                ph.FirstName = firstName;
                ph.LastName = lastName;

                ph.PolicyIndex = 0;

                policyHoldersBySSN.put(policyHolderKey, ph);
                billResponse.Bill.PolicyHolders.add(ph);
            }

            Policy p = new Policy();
            p.Product = (String) billDetail.get('ProductBilledCode');
            p.Mode = (String) billDetail.get('FreqInd');
            p.PolicyNumber = (String) billDetail.get('ReferenceNum');
            p.Premium = (Decimal) billDetail.get('BilledAmtUnalloc');
            p.NewPremium = (Decimal) billDetail.get('ReconAmtUnalloc');
            p.Remarks = (String) billDetail.get('BillDetailRemarks');
            p.ChangeReasonCode = (String) billDetail.get('BillChgReasonCode');
            
            ph.PolicyNewPremiumTotal += p.NewPremium;
            p.Index = ph.PolicyIndex;
            
            ph.Policies.add(p);
            ++ph.PolicyIndex;
		
		}
		
		billResponse.Bill.sortPolicyHoldersByName();

        return billResponse;
    }
    
    private ConsolidatedBillResponse buildConsolidatedBillResponseResult(HttpResponse response) {
        return buildConsolidatedBillResponseFromJSON(response.getBody());
    }
    
    private static String convertToFormattedDate(String dateToFormat) {
        if (String.isNotBlank(dateToFormat)) {
            return Date.valueOf(dateToFormat).format();
        }

        return null;
    }
    
    public class ESBBillingServiceClientException extends Exception { }
    
    public class BrowseBillsResponse {
        @AuraEnabled
        public Boolean Success { get; set; }
        
        @AuraEnabled
        public String Message { get; set; }
        
        @AuraEnabled
        public List<ConsolidatedBill> Bills { get; set; }
        
        public BrowseBillsResponse() {
            Bills = new List<ConsolidatedBill>();
            Success = true;
            Message = '';
        }
    }
    
    public class ConsolidatedBillResponse {
        public Boolean Success { get; set; }
        
        public String Message { get; set; }
        
        public ConsolidatedBill Bill { get; set; }
        
        public ConsolidatedBillResponse() {
            Success = true;
            Message = '';
            Bill = new ConsolidatedBill();
        }
    }
    
    public class ConsolidatedBill implements Comparable {
        @AuraEnabled
        public String BillId { get; set; }
        
        @AuraEnabled
        public String CustomerMCPNumber { get; set; }
        
        @AuraEnabled
        public String CustomerMCPName { get; set; }
        
        @AuraEnabled
        public String AccountName { get; set; }
        
        @AuraEnabled
        public String InvoiceNumber { get; set; }
        
        @AuraEnabled
        public String InvoiceDate { get; set; }
        
        @AuraEnabled
        public String DistributionId { get; set; }
        
        @AuraEnabled
        public String Team { get; set; }
        
        @AuraEnabled
        public String PayorNumber { get; set; }
        
        @AuraEnabled
        public String BillDescription { get; set; }
        
        @AuraEnabled
        public String BillType { get; set; }
        
        @AuraEnabled
        public String BillPeriodFromDate { get; set; }
        
        @AuraEnabled
        public String BillPeriodToDate { get; set; }
        
        @AuraEnabled
        public Decimal ReconciledAmount { get; set; }
        
        @AuraEnabled
        public Decimal TotalPaymentAmount { get; set; }
        
        @AuraEnabled
        public Decimal BilledAmount { get; set; }
        
        @AuraEnabled
        public String BillStatus { get; set; }
        
        @AuraEnabled
        public String DueDate { get; set; }
        
        @AuraEnabled
        public String InvoiceNumberReplaced { get; set; }
        
        @AuraEnabled
        public List<PolicyHolder> PolicyHolders { get; set; }
        
        public ConsolidatedBill() {
            PolicyHolders = new List<PolicyHolder>();
        }
        
        public Integer compareTo(Object compareTo) {
            ConsolidatedBill otherBill = (ConsolidatedBill) compareTo;
            
            Date thisInvoiceDate = Date.parse(this.InvoiceDate);
            Date otherInvoiceDate = Date.parse(otherBill.InvoiceDate);
            
            if (thisInvoiceDate == otherInvoiceDate) return 0;
            // sort descending
            if (thisInvoiceDate > otherInvoiceDate) return -1;

            // sort descending
            return 1;
        }

        public void sortPolicyHoldersByName() {
            PolicyHolders.sort();
        }
    }
    
    public class PolicyHolder implements Comparable {
        @AuraEnabled
        public String FirstName { get; set; }
        
        @AuraEnabled
        public String LastName { get; set; }
        
        @AuraEnabled
        public String Name {
            get { 
                return LastName + ', ' + FirstName;
            }
        }
        
        @AuraEnabled
        public String SSN { get; set; }
        
        @AuraEnabled
        public List<Policy> Policies { get; set; }
        
        public Integer PolicyIndex { get; set; }
        
        public Decimal PolicyNewPremiumTotal { get; set; }
        
        public PolicyHolder() {
            Policies = new List<Policy>();
            PolicyNewPremiumTotal = 0;
        }

        public Integer compareTo(Object compareTo) {
            PolicyHolder otherPolicyHolder = (PolicyHolder) compareTo;

            return this.Name.compareTo(otherPolicyHolder.Name);
        }
    }
    
    public class Policy {
        @AuraEnabled
        public String Product { get; set; }
        
        @AuraEnabled
        public String Mode { get; set; }
        
        @AuraEnabled
        public String PolicyNumber { get; set; }
        
        @AuraEnabled
        public Decimal Premium { get; set; }
        
        @AuraEnabled
        public Decimal NewPremium { get; set; }
        
        @AuraEnabled
        public Integer Index { get; set; }
        
        @AuraEnabled
        public String ChangeReasonCode { get; set; }
        
        @AuraEnabled
        public String Remarks { get; set; }
    }
}