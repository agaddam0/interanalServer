/*
    WARNING: DO NOT LOG ANY CLAIMS DATA RETURNED FROM THE API!
    There's an agreement with Legal that says no Claims data
    should be stored in Salesforce. When in doubt,
    ask Stephania Williams.
    - Luke Freeland, 2/2/2018
*/

public class ClaimCallouts {
    public static final String CLAIMS_CALLOUT_INTEGRATION_NAME = 'Claims Callout';
    public static final Integer MAX_CALLOUT_TIMEOUT = 120000;
    
    public static List<ProductClaim> Claims = new List<ProductClaim>();
    public static List<FlexAccount> FlexAccts = new List<FlexAccount>();
	public static List<FlexClaim> FlexClaims = new List<FlexClaim>();
	public static List<String> ErrorMessages = new List<String>();
	    
    
    private static String CustomerNumber;
    private static Map<String, String> ParsedXML;
    private static string BearerToken = '';
    private static API_Manager__c api;
    private static string Environment = '';
    private static Map<String, String> ClaimNumToProductCode;
    private static Map<String, ProductClaim> TempClaims = new Map<String, ProductClaim>();
    private static List<string> claimNums = new List<string>();
	private static string SNum = '';
	private static List<string> ElectionIds = new List<String>();
    private static List<FlexAccount> TempFlexAccts = new List<FlexAccount>();
    private static List<FlexClaim> TempFlexClaims = new List<FlexClaim>();
    private static String logMessage = '';
    private static Exception caughtException = null;
    
	
    public static void BuildProductClaims(String cNum)
    {
        try {
	        CustomerNumber = cNum;
	        
	        logMessage += 'Building Product Claims for Customer Number: ' + cNum + '\n\n';
	        
	        if(BearerToken == '')
	            BearerToken = getBearerToken();
	        
	        ClaimNumToProductCode = new Map<String, String>();
	        
	        GetDisabilityClaimsByCustomer();
	        GetSupplementalMedClaimsByCustomer();
	        
	        if(TempClaims.size() > 0)
	        {
	            GetEOBDataByClaimNumber();
	        }
        }
        catch(Exception ex) {
            caughtException = ex;
            addExceptionErrorToErrorMessages(ex);
        }
        finally {
            InsertIntegrationLogs();
        }
    }
    
    public static void BuildFlexAccount(String cNum)
    {
        try {
	        logMessage += 'Building Flex Account for Customer Number: ' + cNum + '\n\n';
	        
	        CustomerNumber = cNum;
	        GetElectionByEmployeeSSN();
	        GetProductByElectionId();
			GetClaimsByElectionId();
	        GetClaimDetailsByClaimID();
        }
        catch(Exception ex) {
            caughtException = ex;
            addExceptionErrorToErrorMessages(ex);
        }
        finally {
            InsertIntegrationLogs();
        }
    }
    
    @testVisible
    private static String getBearerToken()
    {
        Boolean isSandbox;
        string errorMsg = '';
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        logMessage += 'Attempting to get bearer token...\n';
        
	    if(Environment == '')
	    {
	        isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
	        if(isSandbox)
	            Environment = 'QA';
	        else
	            Environment = 'Prod';
	    }

        api = [SELECT Name, Consumer_Key__c, Consumer_Secret__c, Endpoint__c, Host__c, Password__c, Username__c FROM API_Manager__c WHERE Name = :Environment];
	        
        logMessage += 'API Manager Id Used: ' + api.Id + '\n';
	        
        Blob headerValue = Blob.valueOf(api.Consumer_Key__c + ':' + api.Consumer_Secret__c);
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        String endpointHeader = api.Endpoint__c + '/token';
        Http http = new Http();

        request.setEndpoint(endpointHeader);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Authorization', authHeader);
        request.setBody('grant_type=password&username=' + EncodingUtil.urlEncode(api.Username__c, 'UTF-8') + '&password='+EncodingUtil.urlEncode(api.Password__c, 'UTF-8'));
        request.setTimeout(MAX_CALLOUT_TIMEOUT);
	        
        response = http.send(request);
        if(response.getStatusCode() == 200)
        {
            logMessage += 'Successfully retrieved bearer token.\n\n';
	            
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            return (string) results.get('access_token');

        }            
	        
        errorMsg = buildErrorMsg(response, '01');
        logMessage += 'Error retrieving bearer token. errorMsg: ' + errorMsg + '\n\n';
	        
        ErrorMessages.add(errorMsg);
        return '';
    }
    
    @testVisible
    private static void GetDisabilityClaimsByCustomer()
    {
        if(BearerToken == '')
            BearerToken = getBearerToken();
     
        logMessage += 'Attempting to get disability claims by customer using customer number ' + CustomerNumber + '...\n';
        
        ParsedXML = new Map<String, String>();
        
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dis="http://www.afadvantage.com/services/v1/Benefits/Disability">' +
   						'<soapenv:Header/>' +
  							'<soapenv:Body>' +
      							'<dis:ListDisabilityClaimsByCustomerRequest>' +
         							'<dis:ListDisabilityClaimsByCustomer>' +
            							'<dis:CustomerNumber>' + CustomerNumber + '</dis:CustomerNumber>' +
         							'</dis:ListDisabilityClaimsByCustomer>' +
      							'</dis:ListDisabilityClaimsByCustomerRequest>' +
   							'</soapenv:Body>' +
						'</soapenv:Envelope>';
        
        string errorMsg = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        string endpointHeader = api.Endpoint__c + '/disabilitybenefits';
        request.setEndpoint(endpointHeader);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + BearerToken);
        request.setHeader('Accept-Encoding', 'gzip,deflate');
        request.setHeader('SOAPAction', 'urn:#ListDisabilityClaimsByCustomer');
        request.setHeader('Content-Length', '440');
        request.setHeader('Host', api.Host__c);
        request.setHeader('Connection', 'Keep-Alive');
        request.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
        request.setTimeout(MAX_CALLOUT_TIMEOUT);
        request.setBody(body);
        HttpResponse response = http.send(request);
        Dom.Document doc;
        Dom.XmlNode xroot;
        ProductClaim pc;
        if(response.getStatusCode() == 200)
        {
            logMessage += 'Successfully retrieved disability claims by customer.\n\n';
            
            doc = response.getBodyDocument();
            for(dom.XmlNode root : doc.getRootElement().getChildElements()){
                for(dom.XmlNode layer1 : root.getChildElements()){
                    for(dom.XmlNode layer2 : layer1.getChildElements()){
                        for(dom.XmlNode layer3 : layer2.getChildElements()){
                            for(dom.XmlNode layer4 : layer3.getChildElements()){
                                pc = new ProductClaim();
                                for(dom.XmlNode layer5 : layer4.getChildElements())
                                {
                                    if(layer5.getName() == 'ClaimNumber')
                                        pc.ClaimNumber = layer5.getText();
                                    if(layer5.getName() == 'ClaimIncurredDate')
                                        pc.ClaimsIncurredDate = layer5.getText();
                                    if(layer5.getName() == 'PolicyNumber')
                                        pc.PolicyNumber = layer5.getText();
                                    if(layer5.getName() == 'ProductCode')
                                        pc.ProductCode = layer5.getText();
                                    if(layer5.getName() == 'SSNTaxId')
                                    {
                                        pc.SSN = layer5.getText(); 
                                        SNum = layer5.getText();
                                    }
                                    if(layer5.getName() == 'ClaimStatusIndicator')
                                        pc.ClaimStatusId = layer5.getText();
                                    if(pc.ClaimStatusId == 'C')
                                        pc.ClaimStatus = 'Closed';
                                    else if(pc.ClaimStatusId == 'O' || pc.ClaimStatusId == '')
                                        pc.ClaimStatus = 'Open';
                                    else if(pc.ClaimStatusId == 'D')
                                        pc.ClaimStatus = 'Denied';
                                    else if(pc.ClaimStatusId == 'P')
                                        pc.ClaimStatus = 'Pending'; 
                                }
                                pc.CustomerNumber = CustomerNumber;
                                if(pc.CustomerNumber != null && pc.ClaimNumber != null && pc.ProductCode != null)
                                	TempClaims.put(pc.ClaimNumber, pc);
                            }
                        }
                    }
                }
            }
        }
        else
        {
            errorMsg = buildErrorMessageWithFaultString(response, '02');
            logMessage += 'Error retrieving disability claims by customer. errorMsg: ' + errorMsg + '\n\n';
            ErrorMessages.add(errorMsg);
        }
    }
    
    @testVisible
    private static void GetEOBDataByClaimNumber()
    {
        if(BearerToken == '')
            BearerToken = getBearerToken();
        
        ParsedXML = new Map<String, String>();        
        string errorMsg = '';
        
        for(ProductClaim p : TempClaims.values())
        {
            errorMsg = '';
            logMessage += 'Attempting GetEOBDataByClaimNumber for customer number:  ' + p.CustomerNumber + ' ...\n';
            
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dis="http://www.afadvantage.com/services/v1/Benefits">' +
                '<soapenv:Header/>' +
                '<soapenv:Body>' +
                '<dis:ListEOBHeadersByClaimNumberRequest>' +
                '<dis:EOBHeadersRequest>' +
                '<dis:CustomerNumber>' + p.CustomerNumber + '</dis:CustomerNumber>' +
                '<dis:ClaimNumber>' + p.ClaimNumber + '</dis:ClaimNumber>' +
                '<dis:ProductCode>' + p.ProductCode + '</dis:ProductCode>' +
                '</dis:EOBHeadersRequest>' +
                '</dis:ListEOBHeadersByClaimNumberRequest>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            string endpointHeader = api.Endpoint__c + '/benefits';
            request.setEndpoint(endpointHeader);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            request.setHeader('Authorization', 'Bearer ' + BearerToken);
            request.setHeader('Accept-Encoding', 'gzip,deflate');
            request.setHeader('SOAPAction', 'urn:#ListEOBHeadersByClaimNumber');
            request.setHeader('Content-Length', '440');
            request.setHeader('Host', api.Host__c);
            request.setHeader('Connection', 'Keep-Alive');
            request.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
            request.setTimeout(MAX_CALLOUT_TIMEOUT);
            request.setBody(body);
            HttpResponse response = http.send(request);
            Dom.Document doc;
            Dom.XmlNode xroot;
            ProductClaim pc;
            if(response.getStatusCode() == 200)
            {
                logMessage += 'Successfully retrieved GetEOBDataByClaimNumber.\n\n';
                
                doc = response.getBodyDocument();
                for(dom.XmlNode root : doc.getRootElement().getChildElements()){
                    for(dom.XmlNode layer1 : root.getChildElements()){
                        for(dom.XmlNode layer2 : layer1.getChildElements()){
                            for(dom.XmlNode layer3 : layer2.getChildElements()){
                                for(dom.XmlNode layer4 : layer3.getChildElements()){
                                    pc = new ProductClaim();
                                    for(dom.XmlNode layer5 : layer4.getChildElements())
                                    {
                                        if(layer5.getName() == 'EOBDate')
                                            pc.EOBDate = layer5.getText().replace('-', '/');
                                        if(layer5.getName() == 'CheckNetAmount')
                                        {
                                            String temp = layer5.getText();
                                            Decimal dec = Decimal.valueOf(temp);
                                            pc.PaidAmount = dec;
                                        }
                                        if(layer5.getName() == 'EOBStatusIndicator')
                                            pc.EOBStatusId = layer5.getText();
                                        if(pc.EOBStatusId == 'O')
                                            pc.EOBStatus = 'Processing';
                                        else if(pc.EOBStatusId == 'C')
                                            pc.EOBStatus = 'Complete';
                                        else if(pc.EOBStatusId == 'S')
                                            pc.EOBStatus = 'Stop Pay';
                                        else if(pc.EOBStatusId == 'V')
                                            pc.EOBStatus = 'Void';
                                        else if(pc.EOBStatusId == 'R')
                                            pc.EOBStatus = 'Reimbursement';
                                        else if(pc.EOBStatusId == 'P')
                                            pc.EOBStatus = 'Pending';

                                        pc.ClaimNumber = p.ClaimNumber;
                                        pc.ClaimsIncurredDate = p.ClaimsIncurredDate.replace('-', '/');
                                        pc.CustomerNumber = p.CustomerNumber;
                                        pc.PolicyNumber = p.PolicyNumber;
                                        pc.ProductCode = p.ProductCode;
                                        pc.ClaimStatus = p.ClaimStatus;
                                        pc.SSN = p.SSN;
                                    }
                                    Claims.add(pc);
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                errorMsg = buildErrorMessageWithFaultString(response, '03');
                logMessage += 'Error retrieving GetEOBDataByClaimNumber. errorMsg: ' + errorMsg + '\n\n';
                ErrorMessages.add(errorMsg);
            }
        } // end for loop
    }
    
    private static void walkThrough(DOM.XMLNode node) 
    {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getText().trim() != '')
                ParsedXML.put(node.getName(), node.getText().trim());
            else
                ParsedXML.put(node.getName(), '');
            
            //recursively get all the element nodes to put them in the Map
            for (Dom.XMLNode child: node.getChildElements()) {
                walkThrough(child);
            }
        }
    }
    
    @testVisible
    private static void GetSupplementalMedClaimsByCustomer()
    {
        if(BearerToken == '')
            BearerToken = getBearerToken();
        
        ParsedXML = new Map<String, String>();
        string errorMsg = '';
        logMessage += 'Attempting GetSupplementalMedClaimsByCustomer for customer number:  ' + CustomerNumber + '...\n';
        
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sup="http://www.afadvantage.com/services/v1/Benefits/SuppMed">' +
   						'<soapenv:Header/>' +
  							'<soapenv:Body>' +
      							'<sup:ListSuppMedClaimsByCustomerRequest>' +
                                     '<sup:ListSuppMedClaimsByCustomer>' +
                                        '<sup:CustomerNumber>' + CustomerNumber + '</sup:CustomerNumber>' +
                                        '<sup:ClaimType></sup:ClaimType>' +
                                        '</sup:ListSuppMedClaimsByCustomer>' +
                                  '</sup:ListSuppMedClaimsByCustomerRequest>' +
   							'</soapenv:Body>' +
						'</soapenv:Envelope>';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        string endpointHeader = api.Endpoint__c + '/suppmedbenefits';
        request.setEndpoint(endpointHeader);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + BearerToken);
        request.setHeader('Accept-Encoding', 'gzip,deflate');
        request.setHeader('SOAPAction', 'urn:#ListSuppMedClaimsByCustomer');
        request.setHeader('Content-Length', '440');
        request.setHeader('Host', api.Host__c);
        request.setHeader('Connection', 'Keep-Alive');
        request.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
        request.setTimeout(MAX_CALLOUT_TIMEOUT);
        request.setBody(body);
        HttpResponse response = http.send(request);
        Dom.Document doc;
        Dom.XmlNode xroot;
        ProductClaim pc;
        
        if(response.getStatusCode() == 200)
        {
            logMessage += 'Successfully retrieved GetSupplementalMedClaimsByCustomer.\n\n';
            
            doc = response.getBodyDocument();
            for(dom.XmlNode root : doc.getRootElement().getChildElements()){
                for(dom.XmlNode layer1 : root.getChildElements()){
                    for(dom.XmlNode layer2 : layer1.getChildElements()){
                        for(dom.XmlNode layer3 : layer2.getChildElements()){
                            for(dom.XmlNode layer4 : layer3.getChildElements()){
                                pc = new ProductClaim();
                                for(dom.XmlNode layer5 : layer4.getChildElements())
                                {
                                    if(layer5.getName() == 'ClaimNumber')
                                        pc.ClaimNumber = layer5.getText();
                                    if(layer5.getName() == 'ClaimsIncurredDate')
                                        pc.ClaimsIncurredDate = layer5.getText();
                                    if(layer5.getName() == 'PolicyNumber')
                                        pc.PolicyNumber = layer5.getText();
                                    if(layer5.getName() == 'ProductCode')
                                        pc.ProductCode = layer5.getText();
                                    if(layer5.getName() == 'SSNTaxId')
                                        pc.SSN = layer5.getText();
                                    if(layer5.getName() == 'ClaimStatusIndicator')
                                        pc.ClaimStatusId = layer5.getText();
                                    if(pc.ClaimStatusId == 'C')
                                        pc.ClaimStatus = 'Closed';
                                    else if(pc.ClaimStatusId == 'O' || pc.ClaimStatusId == '')
                                        pc.ClaimStatus = 'Open';
                                    else if(pc.ClaimStatusId == 'D')
                                        pc.ClaimStatus = 'Denied';
                                    else if(pc.ClaimStatusId == 'P')
                                        pc.ClaimStatus = 'Pending'; 
                                }
                                pc.CustomerNumber = CustomerNumber;
                                if(pc.CustomerNumber != null && pc.ClaimNumber != null && pc.ProductCode != null)
                                	TempClaims.put(pc.ClaimNumber, pc);
                            }
                        }
                    }
                }
            }
        }
        else
        {
            errorMsg = buildErrorMessageWithFaultString(response, '04');
            logMessage += 'Error retrieving GetSupplementalMedClaimsByCustomer. errorMsg: ' + errorMsg + '\n\n';
            ErrorMessages.add(errorMsg);
        }
    }
    
    @testVisible
    private static void GetIndividualCustomerProfile()
    {
        if(BearerToken == '')
            BearerToken = getBearerToken();

        logMessage += 'Attempting GetIndividualCustomerProfile for customer number:  ' + CustomerNumber + '...\n';
        
        //Perform SOAP call to get the Individual Customer Profile via Customer Id
        //This will be used for the Flex Account page
        
        ParsedXML = new Map<String, String>();
        string errorMsg = '';
        
        String body = '<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">' +
    					'<Body>' +
        					'<IndividualCustomerProfileRequest xmlns="http://www.afadvantage.com/services/v1/Entity/Individual/Profile">' +
            					'<CustomerNumber>' + CustomerNumber + '</CustomerNumber>' +
            					'<SSNTaxId></SSNTaxId>' +
            					'<ListRelationshipInsuredFlag>true</ListRelationshipInsuredFlag>' +
            					'<ListRelationshipOwnerFlag>true</ListRelationshipOwnerFlag>' +
            					'<ListRelationshipNobFlag>true</ListRelationshipNobFlag>' +
            					'<ListActiveFlag>true</ListActiveFlag>' +
           		 				'<ListInactiveFlag>true</ListInactiveFlag>' +
            					'<ListInforceOnlyFlag>false</ListInforceOnlyFlag>' +
            					'<ListPositiveBilledFlag>true</ListPositiveBilledFlag>' +
            					'<ListNegativeBilledFlag>true</ListNegativeBilledFlag>' +
        					'</IndividualCustomerProfileRequest>' +
    					'</Body>' +
					'</Envelope>';
        
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        string endpointHeader = api.Endpoint__c + '/individual-profile/1';
        request.setEndpoint(endpointHeader);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer ' + BearerToken);
        request.setHeader('Accept-Encoding', 'gzip,deflate');
        request.setHeader('SOAPAction', 'urn:#GetIndividualCustomerProfile');
        request.setHeader('Content-Length', '440');
        request.setHeader('Host', api.Host__c);
        request.setHeader('Connection', 'Keep-Alive');
        request.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
        request.setTimeout(MAX_CALLOUT_TIMEOUT);
        request.setBody(body);
        HttpResponse response = http.send(request);
        Dom.Document doc;
        Dom.XmlNode xroot;
        if(response.getStatusCode() == 200)
        {
            logMessage += 'Successfully retrieved GetIndividualCustomerProfile.\n\n';
            
            doc = response.getBodyDocument();
            for(dom.XmlNode root : doc.getRootElement().getChildElements()){
                for(dom.XmlNode layer1 : root.getChildElements()){
                    for(dom.XmlNode layer2 : layer1.getChildElements()){
                        for(dom.XmlNode layer3 : layer2.getChildElements()){
                            if(layer3.getName() == 'SSNTaxId')
                                SNum = layer3.getText();
                        }
                    }
                }
            }
        }
        else
        {
            errorMsg = buildErrorMessageWithFaultString(response, '05');
            logMessage += 'Error retrieving GetIndividualCustomerProfile. errorMsg: ' + errorMsg + '\n\n';
            ErrorMessages.add(errorMsg);
        }
    }
    
    @testVisible
    private static void GetElectionByEmployeeSSN()
    {
        if(BearerToken == '')
            BearerToken = getBearerToken();
        
        //Perform call to get the election by Employee using the SSN retrieved from the Customer Profile call
        //This will be used for the Flex Account page and the Claims page.
        
        // Do not add SNum to logMessage ever!
        if(SNum == '')
        	GetIndividualCustomerProfile();
        	
        logMessage += 'Attempting GetElectionByEmployeeSSN for customer number:  ' + CustomerNumber + '. SSN Intentionally omitted..\n';
        	
        string errorMsg = '';
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('@SSN', SNum);
        gen.writeEndObject();
        
        String body = gen.getAsString();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        string endpointHeader = api.Endpoint__c + '/oscflexapi/Web_GetElectionsByEmployee';
        request.setEndpoint(endpointHeader);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + BearerToken);
        request.setHeader('Accept-Encoding', 'gzip,deflate');
        request.setHeader('Content-Length', '440');
        request.setHeader('Host', api.Host__c);
        request.setHeader('Connection', 'Keep-Alive');
        request.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
        request.setHeader('Content-Type', 'application/JSON');
        request.setTimeout(MAX_CALLOUT_TIMEOUT);
        request.setBody(body);
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200)
        {
            logMessage += 'Successfully retrieved GetElectionByEmployeeSSN.\n\n';
            
            List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
            Map<String,Object> acct = new Map<String,Object>();
            
			for(Integer i = 0; i < results.size(); i++)
            {
                String temp;
                Decimal dec;
                acct = (Map<String,Object>) results[i];
                FlexAccount flexA = new FlexAccount();
                flexA.ElectionId = (string)acct.get('Election_ID');
                temp = (string)acct.get('CashBalance');
                dec = Decimal.valueOf(temp);
                flexA.AccountBalance = dec;
                temp = (string)acct.get('AvailableBalance');
                dec = Decimal.valueOf(temp);
                flexA.AvailableBalance = dec;
                temp = (string)acct.get('ElectionAmt');
                dec = Decimal.valueOf(temp);
                flexA.ElectionAmount = dec;
                temp = (string)acct.get('TotalDenials');
                dec = Decimal.valueOf(temp);
                flexA.TotalDenied = dec;
                temp = (string)acct.get('TotalDeposits');
                dec = Decimal.valueOf(temp);
                flexA.TotalDeposits = dec;
                temp = (string)acct.get('TotalPayments');
                dec = Decimal.valueOf(temp);
                flexA.TotalPaid = dec;
                temp = (string)acct.get('TotalPending');
                dec = Decimal.valueOf(temp);
                flexA.TotalPending = dec;
                String d1 = (String)acct.get('EffStartDt');
                String[] str = d1.split(' ');
                String[] dts = str[0].split('/');
                Date EffBegin = Date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
                FlexA.EffStartDate = EffBegin;
                String d2 = (String)acct.get('EffEndDt');
                str = d2.split(' ');
                dts = str[0].split('/');
                Date EffEnd = Date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
                FlexA.EffEndDate = EffEnd;
                
                ElectionIds.add(flexA.ElectionId);
                TempFlexAccts.add(flexA);
            }
        }            
        else
        {
            system.debug(response.getBody());
            errorMsg = buildErrorMsg(response, '06');
            logMessage += 'Error retrieving GetElectionByEmployeeSSN. errorMsg: ' + errorMsg + '\n\n';
            ErrorMessages.add(errorMsg);
        }
    }
    
    @testVisible
    private static void GetProductByElectionId()
    {
        if(BearerToken == '')
            BearerToken = getBearerToken();
        
        string errorMsg = '';
        
        //Perform call to get the products by the Election Ids from the Elections by Employee call
        //This will be used for the Flex Account page
        
        for(Integer i = 0; i < ElectionIds.size(); i++)
        {
            errorMsg = '';
            String electionIdStr = ElectionIds[i];
            logMessage += 'Attempting GetProductByElectionId ...\n';
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('@Election_ID', ElectionIds[i]);
            gen.writeEndObject();
            
            String body = gen.getAsString();
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            string endpointHeader = api.Endpoint__c + '/oscflexapi/Web_GetProductByElectionID';
            request.setEndpoint(endpointHeader);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + BearerToken);
            request.setHeader('Accept-Encoding', 'gzip,deflate');
            request.setHeader('Content-Length', '440');
            request.setHeader('Host', api.Host__c);
            request.setHeader('Connection', 'Keep-Alive');
            request.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
            request.setHeader('Content-Type', 'application/JSON');
            request.setTimeout(MAX_CALLOUT_TIMEOUT);
            request.setBody(body);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200)
            {
                logMessage += 'Successfully retrieved GetProductByElectionId.\n\n';
                
                List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> products = new Map<String, Object>();
                
                for(Integer p = 0; p < results.size(); p++)
                {
                    for(FlexAccount a : TempFlexAccts)
                    {
                        if(a.ElectionId == ElectionIds[i])
                        {
                            FlexAccount FA = new FlexAccount();
                            FA.ElectionId = a.ElectionId;
                            FA.AccountBalance = a.AccountBalance;
                            FA.AvailableBalance = a.AvailableBalance;
                            FA.ElectionAmount = a.ElectionAmount;
                            FA.TotalDenied = a.TotalDenied;
                            FA.TotalDeposits = a.TotalDeposits;
                            FA.TotalPaid = a.TotalPaid;
                            FA.TotalPending = a.TotalPending;
                            FA.EffStartDate = a.EffStartDate;
                            FA.EffEndDate = a.EffEndDate;
                            
                            products = (Map<String,Object>) results[p];
                            FA.GradePeriod = (string)products.get('GraceDays');
                            FA.RunoffDays = (string)products.get('RunOffDays');
                            FA.PlanCode = (string)products.get('PlanCode');
                            FA.PlanDesc = (string)products.get('PlanDesc');
                            
                            if(FA.PlanCode == '3PR')
                                FA.Account = 'Ind Premium Reimbursement';
                            else if(FA.PlanCode == 'DDC')
                                FA.Account = 'Dependent Day Care FSA';
                            else if(FA.PlanCode == 'EPP')
                                FA.Account = 'Employer Paid Prescription Plan';
                            else if(FA.PlanCode == 'HRA' || FA.PlanCode == 'HRAD' || FA.PlanCode == 'HRAE' || FA.PlanCode.contains('HRAP'))
                                FA.Account = 'HRA';
                            else if(FA.PlanCode == 'HSA')
                                FA.Account = 'HSA';
                            else if(FA.PlanCode == 'LPF' || FA.PlanCode == 'OPO' || FA.PlanCode == 'REF' || Fa.PlanCode == 'RES')
                                FA.Account = 'Limited Purpose FSA';
                            else if(FA.PlanCode.contains('URM'))
                                FA.Account = 'Health FSA';                            
                            
                            FlexAccts.add(FA);
                        }
                    }
                }
            }            
            else
            {
                system.debug(response.getBody());
                errorMsg = buildErrorMsg(response, '07');
                logMessage += 'Error retrieving GetProductByElectionId. errorMsg: ' + errorMsg + '\n\n';
                ErrorMessages.add(errorMsg);
            }
        }
    }
    
    @testVisible
    private static void GetClaimsByElectionId()
    {
        if(BearerToken == '')
            BearerToken = getBearerToken();
        
        string errorMsg = '';
        
        //Perform REST call to get Flex Claims by Election Id
        //This will be used for the Flex Claims and Product Claims page
        //Will need to get the Election_Id prior to making this call
        
        for(Integer i = 0; i < ElectionIds.size(); i++)
        {
            errorMsg = '';
            String electionIdStr = ElectionIds[i];
            logMessage += 'Attempting GetClaimsByElectionId ...\n';

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('@Election_ID',ElectionIds[i]);
            gen.writeEndObject();

            String body = gen.getAsString();
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            string endpointHeader = api.Endpoint__c + '/oscflexapi/Web_GetClaimsByElectionID';
            request.setEndpoint(endpointHeader);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + BearerToken);
            request.setHeader('Accept-Encoding', 'gzip,deflate');
            request.setHeader('Content-Length', '440');
            request.setHeader('Host', api.Host__c);
            request.setHeader('Connection', 'Keep-Alive');
            request.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
            request.setHeader('Content-Type', 'application/JSON');
            request.setTimeout(MAX_CALLOUT_TIMEOUT);
            request.setBody(body);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200)
            {
                logMessage += 'Successfully retrieved GetClaimsByElectionId.\n\n';
                
                List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> cl = new Map<String, Object>();
                for(Integer c = 0; c < results.size(); c++)
                {
                    For(FlexAccount f : FlexAccts)
                    {
                        if(f.ElectionId == ElectionIds[i])
                        {
                            String temp;
                            Decimal dec;
                            cl = (Map<String, Object>) results[c];
                            FlexClaim flexC = new FlexClaim();
                            flexC.Account = f.Account;
                            temp = (string)cl.get('ClaimAmt');
                            dec = Decimal.valueOf(temp);
                            flexC.ClaimAmount = dec;
                            flexC.ClaimNumber = (string)cl.get('Claim_ID');
                            flexC.ElectionId = ElectionIds[i];
                            String d1 = (String)cl.get('IncurBeginDt');
                            String d2 = (String)cl.get('IncurEndDt');
                            String[] str = d1.split(' ');
                            String[] dts = str[0].split('/');
                            Date beginDate = Date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
                            str = d2.split(' ');
                            dts = str[0].split('/');
                            Date endDate = Date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
                            flexC.IncurBeginDate = beginDate;
                            flexC.IncurEndDate = endDate;
                            TempFlexClaims.add(flexC);
                        }
                    }
                }
            }            
            else
            {
                system.debug(response.getBody());
                errorMsg = buildErrorMsg(response, '08');
                logMessage += 'Error retrieving GetClaimsByElectionId. errorMsg: ' + errorMsg + '\n\n';
                ErrorMessages.add(errorMsg);
            }
        }
    }
    
    @testVisible
    private static void GetClaimDetailsByClaimID()
    {
        if(BearerToken == '')
            BearerToken = getBearerToken();

        string errorMsg = '';
        
        //Perform REST call to get Flex Claims by Election Id
        //This will be used for the Flex Claims and Product Claims page
        //Will need to get the Election_Id prior to making this call
        
        for(FlexClaim fl : TempFlexClaims)
        {
            errorMsg = '';
            
            logMessage += 'Attempting GetClaimDetailsByClaimID ...\n';
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('@Claim_ID', fl.ClaimNumber);
            gen.writeEndObject();
            
            String body = gen.getAsString();
            
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            string endpointHeader = api.Endpoint__c + '/oscflexapi/Web_GetClaimDetailsByClaimID';
            request.setEndpoint(endpointHeader);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + BearerToken);
            request.setHeader('Accept-Encoding', 'gzip,deflate');
            request.setHeader('Content-Length', '440');
            request.setHeader('Host', api.Host__c);
            request.setHeader('Connection', 'Keep-Alive');
            request.setHeader('User-Agent', 'Apache-HttpClient/4.1.1 (java 1.5)');
            request.setHeader('Content-Type', 'application/JSON');
            request.setTimeout(MAX_CALLOUT_TIMEOUT);
            request.setBody(body);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200)
            {
                logMessage += 'Successfully retrieved GetClaimDetailsByClaimID.\n\n';
                
                List<Object> results = (List<Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> cl = new Map<String, Object>();
                for(Integer c = 0; c < results.size(); c++)
                {
                    string temp;
                    Decimal dec;
                    
                    cl = (Map<String, Object>) results[c];
                    FlexClaim flexC = new FlexClaim();
                    FlexC.Account = fl.Account;
                    flexC.ClaimAmount = fl.ClaimAmount;
                    flexC.ClaimNumber = fl.ClaimNumber;
                    flexC.ElectionId = fl.ElectionId;
                    flexC.IncurBeginDate = fl.IncurBeginDate;
                    flexC.IncurEndDate = fl.IncurEndDate;
                    temp = (string) cl.get('Amount');
                    dec = Decimal.valueOf(temp);
                    flexC.PaidAmount = dec;
                    flexC.CodeDesc = (string) cl.get('CodeDesc');
                    String d1 = (String)cl.get('PayDt');
                    system.debug('d1: ' + d1);
                    if(d1 != '')
                    {
                        String[] str = d1.split(' ');
                        String[] dts = str[0].split('/');
                        Date pDate = Date.newinstance(Integer.valueOf(dts[2]), Integer.valueOf(dts[0]), Integer.valueOf(dts[1]));
                        flexC.PaidDate = pDate;
                    }
                    FlexClaims.add(flexC);
                }
            }            
            else
            {
                system.debug(response.getBody());
                errorMsg = buildErrorMsg(response, '09');
                logMessage += 'Error retrieving GetClaimDetailsByClaimID. errorMsg: ' + errorMsg + '\n\n';
                ErrorMessages.add(errorMsg);
            }
        }
    }
    
    private static void InsertIntegrationLogs() {
        String severity = ErrorMessages != null && ErrorMessages.isEmpty() ? IntegrationLogger.INTEGRATION_LOG_SEVERITY_INFO : IntegrationLogger.INTEGRATION_LOG_SEVERITY_ERROR;
        String emptyContextualInfo = '';
        String stackTrace = '';
        
        if (caughtException != null) {
            stackTrace = caughtException.getStackTraceString();
            
            logMessage += '\n\n Caught Exception Message: ' + caughtException.getMessage();
            logMessage += '\n Caught Exception Type Name: ' + caughtException.getTypeName();
        }
        
        IntegrationLogger.Instance.addIntegrationLog(CLAIMS_CALLOUT_INTEGRATION_NAME, logMessage, severity, emptyContextualInfo, stackTrace);
        IntegrationLogger.Instance.insertLogs();
    }
    
    private static String getResponseFaultString(HttpResponse response) {
        String faultString = '';
        
        if(response == null ||
           String.isEmpty(response.getBody())) {
            return faultString;
        }

        Dom.Document doc = response.getBodyDocument();
        Dom.XmlNode xroot = doc.getRootElement();

        walkThrough(xroot);

        if (ParsedXML != null) {
            faultString = ParsedXML.get('faultstring');
        }

        return faultString;
    }
    
    private static String buildErrorMsg(HttpResponse response, String prefix) {
         String errorMsg = prefix + ' The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus();
         system.debug(errorMsg);
         
         return errorMsg;
    }
    
    private static String buildErrorMessageWithFaultString(HttpResponse response, String prefix) {
        String faultMessage = getResponseFaultString(response);
    
        system.debug('Failure XML: ' + ParsedXML);
        String errorMsg = buildErrorMsg(response, prefix) + '. Fault Message: ' + faultMessage;
        
        return errorMsg;
    }
    
    private static void addExceptionErrorToErrorMessages(Exception ex) {
        ErrorMessages.add(ex.getMessage());
    }
}