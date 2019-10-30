public with sharing class ESBBillingDetailLogFilter extends IntegrationLogFilter {

    public override void filter(Integration_Log__c log) {
        /* Remove the entire FederalIdNum so the SSN isn't logged
           String regEx = '<FederalIdNum>(.*?)</FederalIdNum>';
           Pattern ssnPattern = Pattern.compile( regEx );
           Matcher ssnMatcher = ssnPattern.matcher( log.Response__c );
           matcher.replaceAll('') results in Regex too complicated error

           log.Response__c = log.Response__c.replaceAll(regEx, ''); result in Regex too complicated
        
           CPU Timeout Exceeded
           while(ssnMatcher.find()) {
              log.Response__c = log.Response__c.replace(ssnMatcher.group(), '');
           }
        */
        
        // XML
        if (String.isNotBlank(log.Response__c) &&
            log.Response__c.contains('<FederalIdNum>')) {

            Dom.Document domDoc = new Dom.Document();
            
            Integer bodyStartIndex = log.Response__c.indexOf('<?xml version="1.0" encoding="UTF-8"?>');
            String xmlBody = log.Response__c.substring( bodyStartIndex );

            domDoc.load( xmlBody );
            Dom.XmlNode root = domDoc.getRootElement();
            Dom.XmlNode body = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XmlNode billIdResponse = body.getChildElement('BillDetailBrowseByCBillIdResponse', 'http://www.afadvantage.com/services/v1/Billing/AdminBillCoverage');
            Dom.XmlNode resultData = billIdResponse.getChildElement('resultData', null);
            Dom.XmlNode payloadOut = resultData.getChildElement('PayloadOut', null);
            Dom.XmlNode errorOut = resultData.getChildElement('ErrorOut', null);
            Dom.XmlNode billDetailListElement = payloadOut.getChildElement('BillDetailList', null);
            List<Dom.XmlNode> billDetailElements = billDetailListElement.getChildElements();
            
            for (Dom.XmlNode billDetailElement : billDetailElements) {
                Dom.XmlNode ssnNode = billDetailElement.getChildElement('FederalIdNum', null);
                billDetailElement.removeChild(ssnNode);
            }

            // rebuild the response with the new body without the SSN elements
            log.Response__c = log.Response__c.subString(0, bodyStartIndex) + domDoc.toXmlString();
        }
        // JSON
        else if (String.isNotBlank(log.Response__c) &&
                log.Response__c.contains('"FederalIdNum')) {
            
            // Find the JSON Body
            
            Integer bodyStartIndex = log.Response__c.indexOf('{"');
            String jsonBody = log.Response__c.substring( bodyStartIndex );
            
            // Remove the Bill Details and save the filtered output to the Response__c field.
            Map<String, Object> rMap = (Map<String, Object>)  JSON.deserializeUntyped(jsonBody);
            
            rMap.put('BillDetailList', 'Redacted');
            
            log.Response__c = log.Response__c.left(bodyStartIndex) + JSON.serialize(rMap);
        }
    }
    
}