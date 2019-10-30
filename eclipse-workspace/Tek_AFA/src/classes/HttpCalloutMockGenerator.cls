@isTest
global class HttpCalloutMockGenerator implements HttpCalloutMock {
    
    global HttpResponse respond(HttpRequest request)
    {
        system.debug(request);
        
        HttpResponse response = new HttpResponse();
        //Create a fake response
        if(request.getEndpoint().contains('/token'))
        {
            response.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            response.setBody('{"access_token":"e5f7d671d2e108aca1c5063df635c96d","refresh_token":"26560c1896b11c4b3e2b16afbe9fdf96","scope":"default","token_type":"Bearer","expires_in":3600}');
            response.setStatusCode(200);
        }
        else if(request.getEndpoint().contains('/disabilitybenefits'))
        {
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                            '<soapenv:Body>' +
                            '<tns:ListDisabilityClaimsByCustomerResponse xmlns:tns="http://www.afadvantage.com/services/v1/Benefits/Disability">' +
                            '<tns:DisabilityClaimByCustomer>' +
                            '<tns:CustomerNumber>1534862</tns:CustomerNumber>' +
                             '<tns:DisabilityClaimList>' +
                             '<tns:DisabilityClaim>' +
                            '<tns:ClaimNumber>7726551202</tns:ClaimNumber>' +
                            '<tns:CustomerName>HERNANDEZ, DIANE</tns:CustomerName>' +
                            '<tns:SSNTaxId>556026988</tns:SSNTaxId>' +
                            '<tns:SSNTaxIdLast4>*****6988</tns:SSNTaxIdLast4>' +
                            '<tns:SexCode>F</tns:SexCode>' +
                            '<tns:BirthDate>1958-06-26</tns:BirthDate>' +
                            '<tns:ClaimStatusIndicator>O</tns:ClaimStatusIndicator>' +
                            '<tns:ProductCode>DISAB</tns:ProductCode>' +
                            '<tns:PolicyNumber>153486211</tns:PolicyNumber>' +
                            '<tns:PlanCode>014708-R1</tns:PlanCode>' +
                            '<tns:MasterContractParticipant>03126</tns:MasterContractParticipant>' +
                            '<tns:ClaimIncurredDate>2015-08-12</tns:ClaimIncurredDate>' +
                             '</tns:DisabilityClaim>' +
                             '</tns:DisabilityClaimList>' +
                             '</tns:DisabilityClaimByCustomer>' +
                            '</tns:ListDisabilityClaimsByCustomerResponse>' +
                            '</soapenv:Body>' +
                            '</soapenv:Envelope>';
            response.setBody(body);
            response.setStatusCode(200);
        }
        else if(request.getEndpoint().contains('/benefits'))
        {
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                          '<soapenv:Body>' +
                              '<tns:ListEOBHeadersByClaimNumberResponse xmlns:tns="http://www.afadvantage.com/services/v1/Benefits">' +
                                 '<tns:EOBHeadersByClaimNumber>' +
                                    '<tns:CustomerNumber/>' +
                                    '<tns:ClaimNumber/>' +
                                    '<tns:EOBHeadersList>' +
                                       '<tns:EOBHeaders>' +
                                          '<tns:EOBDate>2015-08-14</tns:EOBDate>' +
                                          '<tns:EOBDateComplement>79849185</tns:EOBDateComplement>' +
                                          '<tns:PolicyNumber>153486201</tns:PolicyNumber>' +
                                          '<tns:ClaimDocumentNumber>1</tns:ClaimDocumentNumber>' +
                                          '<tns:EOBStatusIndicator>C</tns:EOBStatusIndicator>' +
                                          '<tns:EOBFromDate>2014-01-02</tns:EOBFromDate>' +
                                          '<tns:EOBThruDate>2014-07-09</tns:EOBThruDate>' +
                                          '<tns:IncomingMailDate>2015-06-09</tns:IncomingMailDate>' +
                                          '<tns:ProductCode>DISAB</tns:ProductCode>' +
                                          '<tns:PlanCode>014410-4</tns:PlanCode>' +
                                          '<tns:ClaimCheckNumber>000000000</tns:ClaimCheckNumber>' +
                                          '<tns:CheckNetAmount>3770.00</tns:CheckNetAmount>' +
                                          '<tns:PayeeName>DIANE HERNANDEZ</tns:PayeeName>' +
                                          '<tns:SSNTaxId>556026988</tns:SSNTaxId>' +
                                          '<tns:SSNTaxIdLast4>*****6988</tns:SSNTaxIdLast4>' +
                                          '<tns:AddressLine1>PO BOX 60269</tns:AddressLine1>' +
                                          '<tns:AddressLine2/>' +
                                          '<tns:City>OKLAHOMA CITY</tns:City>' +
                                          '<tns:State>OK</tns:State>' +
                                          '<tns:PostalCode>73106</tns:PostalCode>' +
                                          '<tns:DifferentPayeeFlag>true</tns:DifferentPayeeFlag>' +
                                          '<tns:DifferentPayeeComment/>' +
                                          '<tns:EOBSequenceComplement>0</tns:EOBSequenceComplement>' +
                                          '<tns:Adjuster>SD9</tns:Adjuster>' +
                                          '<tns:EOBPendingFlag>false</tns:EOBPendingFlag>' +
                                       '</tns:EOBHeaders>' +
                                    '</tns:EOBHeadersList>' +
                                 '</tns:EOBHeadersByClaimNumber>' +
                              '</tns:ListEOBHeadersByClaimNumberResponse>' +
                           '</soapenv:Body>' +
                        '</soapenv:Envelope>';
            
            response.setBody(body);
            response.setStatusCode(200);
        }
        else if(request.getEndpoint().contains('/suppmedbenefits'))
        {
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                               '<soapenv:Body>' +
                                  '<tns:ListSuppMedClaimsByCustomerResponse xmlns:tns="http://www.afadvantage.com/services/v1/Benefits/SuppMed">' +
                                     '<tns:SuppMedClaimsByCustomer>' +
                                        '<tns:CustomerNumber>1534862</tns:CustomerNumber>' +
                                        '<tns:SuppMedClaimList>' +
                                           '<tns:SuppMedClaim>' +
                                              '<tns:CustomerNumberInsured>1534862</tns:CustomerNumberInsured>' +
                                              '<tns:CustomerNumberDependent>1534862</tns:CustomerNumberDependent>' +
                                              '<tns:ClaimsIncurredDate>2013-12-12</tns:ClaimsIncurredDate>' +
                                              '<tns:ClaimNumber>6837161568</tns:ClaimNumber>' +
                                              '<tns:CustomerName>HERNANDEZ, DIANE</tns:CustomerName>' +
                                              '<tns:SSNTaxId>556026988</tns:SSNTaxId>' +
                                              '<tns:SSNTaxIdLast4>*****6988</tns:SSNTaxIdLast4>' +
                                              '<tns:ClaimStatusIndicator>O</tns:ClaimStatusIndicator>' +
                                              '<tns:ProductCode>CANCR</tns:ProductCode>' +
                                              '<tns:PolicyNumber>153486202</tns:PolicyNumber>' +
                                              '<tns:PlanCode>013-755</tns:PlanCode>' +
                                              '<tns:MasterContractParticipant>03126</tns:MasterContractParticipant>' +
                                           '</tns:SuppMedClaim>' +
                                        '</tns:SuppMedClaimList>' +
                                     '</tns:SuppMedClaimsByCustomer>' +
                                  '</tns:ListSuppMedClaimsByCustomerResponse>' +
                               '</soapenv:Body>' +
                            '</soapenv:Envelope>';
            
            response.setBody(body);
            response.setStatusCode(200);
        }
        else if(request.getEndpoint().contains('/individual-profile/1'))
        {
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://www.afadvantage.com/services/v1/Benefits">' +
                            '<soapenv:Body>' +
                            '<tns:IndividualCustomerProfileResponse>' +
                            '<tns:IndividualCustomerProfile>' +
                            '<tns:CustomerNumber>1534862</tns:CustomerNumber>' +
                            '<tns:CustomerName>HERNANDEZ, DIANE</tns:CustomerName>' +
                            '<tns:SSNTaxId>556026988</tns:SSNTaxId>' +
                            '<tns:SSNTaxIdL4>*****6988</tns:SSNTaxIdL4>' +
                            '<tns:LimitAccessFlag>false</tns:LimitAccessFlag>' +
                            '<tns:CustomerStatus>A</tns:CustomerStatus>' +
                            '<tns:BirthDate>1958-06-26</tns:BirthDate>' +
                            '<tns:AddressList>' +
                            '<Address>' +
                            '<Type>StreetAddress</Type>' +
                            '<IsActive>false</IsActive>' +
                            '<Status />' +
                            '<ChangeReasonCode>CC</ChangeReasonCode>' +
                            '<Attention />' +
                            '<Line1>987 THIS WAY</Line1>' +
                            '<Line2 />' +
                            '<City>ZAMORA</City>' +
                            '<StateCode>CA</StateCode>' +
                            '<PostalCode>95698</PostalCode>' +
                            '<CountryCode>USA</CountryCode>' +
                            '<IsMailingAddr>true</IsMailingAddr>' +
                            '</Address>' +
                            '<Address>' +
                            '<Type>StreetAddress</Type>' +
                            '<IsActive>false</IsActive>' +
                            '<Status />' +
                            '<ChangeReasonCode>CC</ChangeReasonCode>' +
                            '<Attention />' +
                            '<Line1>987 THIS WAY</Line1>' +
                            '<Line2 />' +
                            '<City>ZAMORA</City>' +
                            '<StateCode>CA</StateCode>' +
                            '<PostalCode>95698</PostalCode>' +
                            '<CountryCode>USA</CountryCode>' +
                            '<IsMailingAddr>false</IsMailingAddr>' +
                            '</Address>' +
                            '</tns:AddressList>' +
                            '<tns:PhoneNumber>2084794939</tns:PhoneNumber>' +
                            '<tns:EmailList>' +
                            '<Email>' +
                            '<Type>EMAIL</Type>' +
                            '<Sequence>1</Sequence>' +
                            '<IsActive>true</IsActive>' +
                            '<Location />' +
                            '<Address>VPOW98@YAHOO.COMX</Address>' +
                            '<Comments />' +
                            '</Email>' +
                            '</tns:EmailList>' +
                            '<tns:EmailCount>1</tns:EmailCount>' +
                            '<tns:PolicyList>' +
                            '<tns:Policy>' +
                            '<tns:PolicyNumber>153486206</tns:PolicyNumber>' +
                            '<tns:InsuredCustNbr>1534862</tns:InsuredCustNbr>' +
                            '<tns:RelationshipType>ION</tns:RelationshipType>' +
                            '<tns:PolicyStatusCode>AP</tns:PolicyStatusCode>' +
                            '<tns:ProductCode>ANNTY</tns:ProductCode>' +
                            '<tns:Division>ESD</tns:Division>' +
                            '<tns:Region>WESTERN</tns:Region>' +
                            '<tns:Territory>ID</tns:Territory>' +
                            '<tns:Branch>01</tns:Branch>' +
                            '<tns:DivisionCode>1</tns:DivisionCode>' +
                            '<tns:ServiceTeam>AFESW</tns:ServiceTeam>' +
                            '</tns:Policy>' +
                            '</tns:PolicyList>' +
                            '<tns:PolicyCount>11</tns:PolicyCount>' +
                            '<tns:AFAAccount>true</tns:AFAAccount>' +
                            '<tns:FlexAccount>true</tns:FlexAccount>' +
                            '<tns:FlexDivision>AFES</tns:FlexDivision>' +
                            '<tns:AnnuityPolicy>true</tns:AnnuityPolicy>' +
                            '</tns:IndividualCustomerProfile>' +
                            '</tns:IndividualCustomerProfileResponse>' +
                            '</soapenv:Body>' +
                            '</soapenv:Envelope>';
            
            response.setBody(body);
            response.setStatusCode(200);
            
        }
        else if(request.getEndpoint().contains('Web_GetElectionsByEmployee'))
        {
            String body = '[{"DivisionName":"AFES","Election_ID":"1595952","EffStartDt":"10/15/2014 12:00:00 AM","EffEndDt":"10/14/2015 12:00:00 AM","ElectionAmt":"1200.0000","GroupAmt":"0.0000","ParticipantAmt":"60.0000","Product_ID":"94396","TotalDeposits":"1200.0000","TotalPayments":"1200.0000","TotalPending":"0.0000","TotalDenials":"136.0000","PlanYear_ID":"46467","PayClaimTo":"E","AvailableBalance":"0.0000","CashBalance":"0.0000"},{"DivisionName":"AFES","Election_ID":"1737463","EffStartDt":"10/15/2015 12:00:00 AM","EffEndDt":"10/14/2016 12:00:00 AM","ElectionAmt":"720.0000","GroupAmt":"0.0000","ParticipantAmt":"60.0000","Product_ID":"105339","TotalDeposits":"0.0000","TotalPayments":"0.0000","TotalPending":"0.0000","TotalDenials":"0.0000","PlanYear_ID":"51279","PayClaimTo":"E","AvailableBalance":"720.0000","CashBalance":"720.0000"}]';
			response.setBody(body);
            response.setStatusCode(200);
        }
        else if(request.getEndpoint().contains('Web_GetProductByElectionID'))
        {
            String body = '[{"PlanYear_ID":"51279","Product_ID":"105339","MinElectionAmt":"0.0000","MaxElectionAmt":"2550.0000","RiskAmt":"2550.0000","GraceDays":"0","MaxGraceAmt":"0.00","DepositRequired":"False","DebitCardInd":"False","FundingType":" ","RolloverAmt":"500.00","EligibleExpenses":"CARRYOVER","PlanCode":"URM","PlanDesc":"UNREIMBURSED MEDICAL","RunOffDays":"92"}]';
            response.setBody(body);
            response.setStatusCode(200);
        }
        else if(request.getEndpoint().contains('Web_GetClaimsByElectionID'))
        {
            String body = '[{"Claim_ID":"14560447","CreatedDt":"5/13/2015 1:39:33 PM","IncurBeginDt":"1/22/2015 12:00:00 AM","IncurEndDt":"1/27/2015 12:00:00 AM","ClaimAmt":"1336.0000","CodeDesc":"Active"}]';
            response.setBody(body);
            response.setStatusCode(200);
        }
        else if(request.getEndpoint().contains('Web_GetClaimDetailsByClaimID'))
        {
            String body = '[{"Pay_ID":"11570977","Amount":"44.0300","CodeDesc":"Paid","PayMethod":"2","PayNbr":"4292921","PayDt":"9/9/2016 12:00:00 AM","PayAmt":"44.0300","VoidDt":"","ReasonDesc":""}]';
            response.setBody(body);
            response.setStatusCode(200);
        }
        
        return response;
    }

}