public without sharing class AlegeusService {
    public static final String PARTICIPANT_ACCOUNT_URL_PATH = '/services/participant/accounts/summary/0716/';
    public static final String ALEGEUS_INTEGRATION_NAME = 'Alegeus';
    
    public static final String ACCOUNT_ID_REQUIRED_MSG = 'The account id is required.';
    public static final String PARTICIPANT_ID_REQUIRED_MSG = 'The participant id is required.';
    public static final String EMPLOYER_CODE_MISSING_MSG = 'The employer code is missing on the account.';
    public static final Map<Integer, String> PLAN_YEAR_CODE_LOOKUP = new Map<Integer, String>{
        -1 => 'None',
         0 => 'All',
         1 => 'Current',
         2 => 'Previous',
         3 => 'Future',
         4 => 'Active'
    };

    public ParticipantAccountsResponse getParticipantAccounts(Id accountId, String participantId, String planYear) {
        HttpRequest request;
        HttpResponse response;
        Exception participantAccountsException;
        ParticipantAccountsResponse serviceResponse = new ParticipantAccountsResponse();
        String employerId = '';
        Account employer;

        try {
            if (String.isBlank(accountId)) {
                throw new AlegeusServiceException(ACCOUNT_ID_REQUIRED_MSG);
            }
            
            employer = getAccountById(accountId);
            
            if (String.isBlank(employer.Employer_Code__c)) {
                throw new AlegeusServiceException(EMPLOYER_CODE_MISSING_MSG);
            }
            
            employerId = employer.Employer_Code__c;
            
            if (String.isBlank(participantId)) {
                throw new AlegeusServiceException(PARTICIPANT_ID_REQUIRED_MSG);
            }

            
            AlegeusLogFilter alegeusFilter = new AlegeusLogFilter(participantId);
            IntegrationLogger.Instance.setFilterer(alegeusFilter);
            
            String participantAccountEndpoint = buildGetParticipantAccountsURL(employerId, participantId, planYear);

            request = buildAuthorizedHttpRequestTemplate();
            request.setEndpoint(participantAccountEndpoint);
            
            response = new Http().send(request);
            
            if (response.getStatusCode() == 200) {
                serviceResponse = buildParticipantCurrentAccountsResponse(response);
                serviceResponse.Employer = employer;
            }
            // Some error happened
            else {
                String errorMessage = response.getBody();
                
                if (String.isNotBlank(errorMessage) &&
                    errorMessage.containsIgnoreCase('"Description":')) {

                    Map<String, Object> errorResponse = (Map<String, Object>)  JSON.deserializeUntyped(errorMessage);
                    errorMessage = (String) errorResponse.get('Description');
                }
                
                throw new AlegeusServiceException(errorMessage);
            }
        }
        catch(Exception ex) {
            participantAccountsException = ex;
            
            serviceResponse.Success = false;
            serviceResponse.Message = ex.getMessage();
        }
        finally {
            String contextualInfo = 'Attempting Alegeus Get Participant Accounts ...\n\n';
            
            contextualInfo += 'Account Id: ' + accountId + '\n';
            contextualInfo += 'Employer Id: ' + employerId + '\n';
            
            if (employer != null) {
                contextualInfo += 'MCP #: ' + employer.MCP_Number__c + '\n';
                contextualInfo += 'Account Name: ' + employer.Name + '\n';
            }
            
            if (String.isNotBlank(participantId)) {
                contextualInfo += 'Participant Id Last Four: ' + participantId.right(4) + '\n';
            }
            
            if (serviceResponse != null) {
                contextualInfo += '\nServiceResponse.Success: ' + serviceResponse.Success + '\n';
                contextualInfo += 'ServiceResponse.Message: ' + serviceResponse.Message + '\n';
            }
            
            IntegrationLogger.Instance.addIntegrationLog(ALEGEUS_INTEGRATION_NAME, request, response, participantAccountsException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }

        return serviceResponse;
    }

    public static String generateJWTToken() {
        Alegeus_Settings__c settings = Alegeus_Settings__c.getInstance();
        String secretKey = settings.Secret_Key__c;
        
        DateTime issued = DateTime.now();
        DateTime expire = issued.AddHours(1);
        
        String header = '{"typ" : "JWT", "alg" : "HS256"}';
        String headerBase64URLEncoded = base64URLEncode( header );
        
        Long expirationEpoch = expire.getTime() / 1000;
        
        String claims =  '{"exp" : "' + expirationEpoch + '",';
               claims += ' "tpaid" : "' + settings.TPA_Id__c + '",';
               claims += ' "iss" : "WCP",';
               claims += ' "aud" : "' + settings.Audience__c + '"}';

        String claimsBase64URLEncoded = base64URLEncode( claims );
        String headerDotClaims = headerBase64URLEncoded + '.' + claimsBase64URLEncoded;
        
        String base64URLSecretKey = secretKey;
        Blob secretKeyDecoded = base64URLDecode(base64URLSecretKey);
        
        Blob signature = Crypto.generateMAC('HmacSHA256', Blob.valueOf(headerDotClaims), secretKeyDecoded);
        String signatureBase64URLEncoded = base64URLEncodeBlob( signature );
        
        return headerDotClaims + '.' + signatureBase64URLEncoded;
    }
    
    public static String buildGetParticipantAccountsURL(String employerId, String participantId, String planYear) {
        Alegeus_Settings__c settings = Alegeus_Settings__c.getInstance();
        String participantAccountEndpoint = settings.API_Base_URL__c + PARTICIPANT_ACCOUNT_URL_PATH;
        participantAccountEndpoint += '/' + settings.TPA_Id__c + '/' + employerId + 
                                      '/' + participantId + '?planyear=' + planYear + '&accountdetail=1';

        return participantAccountEndpoint;
    }
    
    private ParticipantAccountsResponse buildParticipantCurrentAccountsResponse(HttpResponse webResponse) {
        return buildParticipantCurrentAccountsResponse(webResponse.getBody());
    }
    
    public ParticipantAccountsResponse buildParticipantCurrentAccountsResponse(String jsonResponse) {
        ParticipantAccountsResponse result = new ParticipantAccountsResponse();
        
        List<Object> accounts = (List<Object>)  JSON.deserializeUntyped(jsonResponse);
        
        for (Object accountObj : accounts) {
            ParticipantAccount pa = new ParticipantAccount();
            
            Map<String, Object> accountMap = (Map<String, Object>) accountObj;
            
            pa.Type = (String) accountMap.get('AccountType');
            pa.AccountDisplayHeader = (String) accountMap.get('AccountDisplayHeader');
            pa.AcctTypeClassDescription = (String) accountMap.get('AcctTypeClassDescription');
            pa.AdditionalDeposits = (Decimal) accountMap.get('AdditionalDeposits');
            pa.AnnualElection = (Decimal) accountMap.get('AnnualElection');
            pa.AvailBalance = (Decimal) accountMap.get('AvailBalance');
            pa.Balance = (Decimal) accountMap.get('Balance');
            pa.BalanceDue = (Decimal) accountMap.get('BalanceDue');
            pa.FlexAcctId = (String) accountMap.get('FlexAcctId');
            pa.PreauthBalance = (Decimal) accountMap.get('PreauthBalance');
            pa.PlanYear = getPlanYearString((Integer) accountMap.get('PlanYear'));
            
            String gracePeriodEndDateString = (String) accountMap.get('GracePeriodEndDte');
            pa.GracePeriodEndDte = convertToDateFromYYYYMMDDString(gracePeriodEndDateString);
            pa.GracePeriodEndDateString = pa.GracePeriodEndDte != null ? pa.GracePeriodEndDte.format() : '';
            
            String planEndDateString = (String) accountMap.get('PlanEndDate');
            pa.PlanEndDate = convertToDateFromYYYYMMDDString(planEndDateString);
            pa.PlanEndDateString = pa.PlanEndDate != null ? pa.PlanEndDate.format() : '';
            
            String planStartDateString = (String) accountMap.get('PlanStartDate');
            pa.PlanStartDate = convertToDateFromYYYYMMDDString(planStartDateString);
            pa.PlanStartDateString = pa.PlanStartDate != null ? pa.PlanStartDate.format() : '';
            
            pa.Payments = (Decimal) accountMap.get('Payments');
            pa.TotalContributions = (Decimal) accountMap.get('TotalContributions');
            
            Map<String, Object> accountDetailInfoMap = (Map<String, Object>) accountMap.get('AccountDetailInfo');
            
            pa.EmprPlanAllowFundRollover = (Boolean) accountDetailInfoMap.get('EmprPlanAllowFundRollover');
            pa.EmployerPlanAllowFundRollerYesNo = pa.EmprPlanAllowFundRollover ? 'Yes' : 'No';
            
            if (pa.EmprPlanAllowFundRollover) {
                List<Object> fundRollOverInfoList = (List<Object>) accountDetailInfoMap.get('FundRolloverInfo');
                
                if (fundRollOverInfoList != null && fundRollOverInfoList.size() > 0) {
	                Map<String, Object> fundRollOverInfo = (Map<String, Object>) fundRollOverInfoList[0];
	
	                pa.RolloverCoverageTierId = (String) fundRollOverInfo.get('CoverageTierID');
	                pa.RolloverPrimaryFundRolloverAmount = (Decimal) fundRollOverInfo.get('PrimaryFundRolloverAmount');
	                pa.RolloverPrimaryFundRolloverRate = (Decimal) fundRollOverInfo.get('PrimaryFundRolloverRate');
                }
            }
            
            String submitClaimsLastDateString = (String) accountMap.get('SubmitClaimsLastDate');
            pa.SubmitClaimsLastDate = convertToDateFromEpochTimeOffset(submitClaimsLastDateString);
            pa.SubmitClaimsLastDateString = pa.SubmitClaimsLastDate != null ? pa.SubmitClaimsLastDate.format() : '';
            
            Map<String, Object> accountPayrollInfoMap = (Map<String, Object>) accountDetailInfoMap.get('AccountPayRollInfo');
            if (accountPayrollInfoMap != null) {
                pa.RemainingContributions = (Decimal) accountPayrollInfoMap.get('RemainingContributions');
                pa.EmployeePPPContribution = (Decimal) accountPayrollInfoMap.get('EmployeePPPContribution');
            }
            
            String spendingLastDateRawString = (String) accountDetailInfoMap.get('SpendingLastDate');
            pa.SpendingLastDate = convertToDateFromEpochTimeOffset(spendingLastDateRawString);
            pa.SpendingLastDateString = pa.SpendingLastDate != null ? pa.SpendingLastDate.format() : '';
            
            if (String.isBlank(result.FirstName)) {
                List<Object> accountInfoList = (List<Object>) accountDetailInfoMap.get('AccountInfo');
                
                for (Object accountInfoObj : accountInfoList) {
                    Map<String, Object> accountInfo = (Map<String, Object>) accountInfoObj;
                    Boolean IsDep = (Boolean) accountInfo.get('IsDep');
                    
                    if (IsDep != null &&
                        IsDep == false) {
                        result.FirstName = (String) accountInfo.get('FirstName');
                        result.LastName = (String) accountInfo.get('LastName');
                        
                        break;
                    }
                }
            }
            
            result.Accounts.add(pa);
        }
        
        return result;
    }
    
    private HttpRequest buildAuthorizedHttpRequestTemplate() {
        HttpRequest authorizedRequest = new HttpRequest();
        
        String jwtToken = generateJWTToken();

        authorizedRequest.setMethod('GET');
        authorizedRequest.setHeader('Content-Type', 'application/json');
        authorizedRequest.setHeader('Authorization', 'Bearer ' + jwtToken);
        authorizedRequest.setTimeout(120000);
        
        return authorizedRequest;
    }
    
    private static Account getAccountById(Id accountId) {
        return
        [SELECT Id,
                Name,
                Employer_Code__c,
                MCP_Number__c
           FROM Account
          WHERE Id = :accountId];
    }

    private static String base64URLEncode(String valueToEncode) {
        return base64URLEncodeBlob( Blob.valueOf(valueToEncode) );
    }
    
    private static String base64URLEncodeBlob(Blob blobToEncode) {
        String valueBase64URLEncoded = EncodingUtil.base64Encode( blobToEncode );
        valueBase64URLEncoded = valueBase64URLEncoded.split('=')[0];
        valueBase64URLEncoded = valueBase64URLEncoded.replace('+', '-');
        valueBase64URLEncoded = valueBase64URLEncoded.replace('/', '_');
        
        return valueBase64URLEncoded;
    }
    
    private static Blob base64URLDecode(String valueToDecode) {
        // from JWT spec
        String output = valueToDecode;
        output = output.Replace('-', '+'); // 62nd char of encoding
        output = output.Replace('_', '/'); // 63rd char of encoding
        
        Integer lengthMod4 = Math.mod(output.length(), 4);
        
        if (lengthMod4 == 0) {
            // No pad chars in this case
        }
        else if (lengthMod4 == 2) {
            output += '=='; //Two pad chars
        }
        else if (lengthMod4 == 3) {
            output += '=';  // One pad char
        }
        else {
            throw new AlegeusServiceException('Illegal base64url string!');
        }

        return EncodingUtil.base64Decode(output); // Standard base64 decoder
    }
    
    private Date convertToDateFromYYYYMMDDString(String yyyymmddString) {
        Integer year = Integer.valueOf( yyyymmddString.left(4) );
        Integer month = Integer.valueOf( yyyymmddString.substring(4, 6) );
        Integer day = Integer.valueOf( yyyymmddString.right(2) );
        
        return Date.newInstance(year, month, day);
    }
    
    private DateTime convertToDateTimeFromEpochTimeOffset(String epochTimeOffsetRaw) {
        String epochTimeOffset = epochTimeOffsetRaw.replace('/', '').replace('Date(', '');
        List<String> parts = epochTimeOffset.split('-');
        Long epochInMilliseconds = Long.valueOf(parts[0]);
        String timezoneOffset = parts[1];
        
        system.debug('  epochInMilliseconds: ' + epochInMilliseconds);
        system.debug('  timezoneOffset: ' + timezoneOffset);
        
        return DateTime.newInstance(epochInMilliseconds);
    }
    
    private Date convertToDateFromEpochTimeOffset(String epochTimeOffsetRaw) {
        DateTime dt = convertToDateTimeFromEpochTimeOffset(epochTimeOffsetRaw);
        
        return dt.date();
    }
    
    @testVisible
    private String getPlanYearString(Integer planYearCode) {
        String planYear = '';
        
        if (planYearCode == null) {
            return planYear;
        }
        
        return PLAN_YEAR_CODE_LOOKUP.get(planYearCode);
    }
    
    public class ParticipantAccountsResponse {
        @AuraEnabled
        public Boolean Success { get; set; }

        @AuraEnabled
        public String Message { get; set; }

        @AuraEnabled
        public String FirstName { get; set; }

        @AuraEnabled
        public String LastName { get; set; }
        
        @AuraEnabled
        public Account Employer { get; set; }
        
        @AuraEnabled
        public List<ParticipantAccount> Accounts { get; set; }
        
        @AuraEnabled
        public Boolean HasHRAAccount {
            get {
                if (Accounts != null) {
                    for (ParticipantAccount acct : Accounts) {
                        if (acct.AcctTypeClassDescription == 'HRA') {
                            return true;
                        }
                    }
                }
                
                return false;
            }
        }

        public ParticipantAccountsResponse() {
            Success = true;
            Message = '';
            Accounts = new List<ParticipantAccount>();
        }
    }
    
    public class ParticipantAccount {
        @AuraEnabled
        public String Type { get; set; }
        
        @AuraEnabled
        public String AccountDisplayHeader { get; set; }

        @AuraEnabled
        public String AcctTypeClassDescription { get; set; }
        
        @AuraEnabled
        public Decimal AdditionalDeposits { get; set; }

        @AuraEnabled
        public Decimal AnnualElection { get; set; }

        @AuraEnabled
        public Decimal AvailBalance { get; set; }
        
        @AuraEnabled
        public Decimal Balance { get; set; }

        @AuraEnabled
        public Decimal BalanceDue { get; set; }
        
        @AuraEnabled
        public String FlexAcctId { get; set; }
        
        @AuraEnabled
        public Date GracePeriodEndDte { get; set; }
        
        @AuraEnabled
        public String GracePeriodEndDateString { get; set; }

        @AuraEnabled
        public Decimal Payments { get; set; }

        @AuraEnabled
        public Date PlanEndDate { get; set; }
        
        @AuraEnabled
        public String PlanEndDateString { get; set; }
        
        @AuraEnabled
        public Date PlanStartDate { get; set; }
        
        @AuraEnabled
        public String PlanStartDateString { get; set; }
        
        @AuraEnabled
        public Decimal TotalContributions { get; set; }
        
        @AuraEnabled
        public Date SubmitClaimsLastDate { get; set; }
        
        @AuraEnabled
        public String SubmitClaimsLastDateString { get; set; }
        
        @AuraEnabled
        public Decimal PreauthBalance { get; set; }
        
        @AuraEnabled
        public Boolean EmprPlanAllowFundRollover { get; set; }
        
        @AuraEnabled
        public String EmployerPlanAllowFundRollerYesNo { get; set; }
        
        @AuraEnabled
        public String RolloverCoverageTierId { get; set; }
        
        @AuraEnabled
        public Decimal RolloverPrimaryFundRolloverAmount { get; set; }
        
        @AuraEnabled
        public Decimal RolloverPrimaryFundRolloverRate { get; set; }
        
        @AuraEnabled
        public Decimal RemainingContributions { get; set; }
        
        @AuraEnabled
        public Date SpendingLastDate { get; set; }
        
        @AuraEnabled
        public String SpendingLastDateString { get; set; }

        @AuraEnabled
        public Decimal EmployeePPPContribution { get; set; }
        
        @AuraEnabled
        public String PlanYear { get; set; }
    }
    
    public class AlegeusServiceException extends Exception { }
}