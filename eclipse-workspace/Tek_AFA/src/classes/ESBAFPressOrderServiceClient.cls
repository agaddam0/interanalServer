public without sharing class ESBAFPressOrderServiceClient extends ESBServiceBase {
    public static final String ORDER_ID_REQUIRED_MESSAGE = 'The order id is required.';
    public static final String ORDER_SERVICE_PATH = '/afpress-order';
    public static final String AUTH_TOKEN_BLANK_ERROR_MESSAGE = 'The auth token is blank.';
    
    public ESBAFPressOrderServiceClient() {
        super(ESBServiceBase.SANDBOX_AFPRESS_API_MANAGER_NAME, ESBServiceBase.PRODUCTION_AFPRESS_API_MANAGER_NAME);
    }
    
    public SubmitOrderResult submitOrder(Id orderId) {
        HttpRequest request;
        HttpResponse response;
        Exception submitOrderException;
        Order__c order;
        SubmitOrderResult result = new SubmitOrderResult();
        
        try {
            if (orderId == null) {
                throw new ESBAFPressOrderServiceClientException(ORDER_ID_REQUIRED_MESSAGE);
            }
            
            ESBAuthenticator authenticator = new ESBAuthenticator(ESBServiceBase.AFPRESS_INTEGRATION_NAME, ESBServiceBase.SANDBOX_AFPRESS_API_MANAGER_NAME, ESBServiceBase.PRODUCTION_AFPRESS_API_MANAGER_NAME);
            authenticator.InsertLogsWhenComplete = false;
            String authToken = authenticator.authenticate();
            
            if (String.isBlank(authToken)) {
                throw new ESBAFPressOrderServiceClientException(AUTH_TOKEN_BLANK_ERROR_MESSAGE);
            }
            
            order = getOrder(orderId);
            
            request = buildCreateOrderRequest(order, authToken);
            response = new Http().send(request);
            
            if (response.getStatusCode() == 200) {
                result = buildSubmitOrderResult(response);
                
                // Service invoked successfully but it returned an error
                if (result.Success == false) {
                    throw new ESBAFPressOrderServiceClientException(result.Message);
                }
            }
            // Some unexpected error happened
            else {
                throw new ESBAFPressOrderServiceClientException(response.getBody());
            }
        }
        catch(Exception ex) {
            submitOrderException = ex;
            
            result.Success = false;
            result.Message = ex.getMessage();
        }
        finally {
            String contextualInfo = 'Attempting ESB AFPress Order Submit...\n\n';
            
            if (orderId != null) {
                contextualInfo += 'Order Id: ' + orderId + '\n\n';
            }
            
            if (order != null) {
                contextualInfo += 'Order Record: ' + order + '\n\n';

                contextualInfo += 'Number of AFPress Order Line Items: ' + order.Order_Line_Items__r.size() + '\n\n';
                
                for (Order_Line_Item__c afPressOrderLineItem : order.Order_Line_Items__r) {
                    contextualInfo += 'AFPress Order Line Item: ' + afPressOrderLineItem + '\n\n';
                }
            }

            if (result != null) {
                contextualInfo += 'result.Success: ' + result.Success + '\n';
                contextualInfo += 'result.AFPressOrderNumber: ' + result.AFPressOrderNumber + '\n';
                contextualInfo += 'result.Message: ' + result.Message + '\n\n';
            }
            
            IntegrationLogger.Instance.addIntegrationLog(ESBServiceBase.AFPRESS_INTEGRATION_NAME, request, response, submitOrderException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }

        return result;
    }
    
    public SearchOrdersResult getAFPressOrdersByAFPressOrderNumbers(Set<String> afPressOrderNumbers) {
        HttpRequest request;
        HttpResponse response;
        Exception getOrdersException;
        SearchOrdersResult result = new SearchOrdersResult();
        
        try {
            ESBAuthenticator authenticator = new ESBAuthenticator(ESBServiceBase.AFPRESS_INTEGRATION_NAME, ESBServiceBase.SANDBOX_AFPRESS_API_MANAGER_NAME, ESBServiceBase.PRODUCTION_AFPRESS_API_MANAGER_NAME);
            authenticator.InsertLogsWhenComplete = false;
            String authToken = authenticator.authenticate();
            
            if (String.isBlank(authToken)) {
                throw new ESBAFPressOrderServiceClientException(AUTH_TOKEN_BLANK_ERROR_MESSAGE);
            }
            
            request = buildSearchOrderRequestByOrderNumbers(afPressOrderNumbers, authToken);
            response = new Http().send(request);
            
            if (response.getStatusCode() == 200) {
                result = buildSearchOrdersResult(response);
                
                if (result.Success == false) {
                    throw new ESBAFPressOrderServiceClientException(result.Message);
                }
            }
            // Some unexpected error happened
            else {
                throw new ESBAFPressOrderServiceClientException(response.getBody());
            }
        }
        catch(Exception ex) {
            getOrdersException = ex;
            
            result.Success = false;
            result.Message = ex.getMessage();
        }
        finally {
            String contextualInfo = 'Attempting ESB AFPress Search Orders By Order Numbers...\n\n';
            
            if (afPressOrderNumbers != null) {
                contextualInfo += 'Order Numbers...\n\n';
                
                for (String orderNumber : afPressOrderNumbers) {
                    contextualInfo += '  Order Number: ' + orderNumber + '\n';
                }
            }
            
            if (result != null) {
                contextualInfo += '\n   result.Success: ' + result.Success + '\n';
                contextualInfo += '   result.Message: ' + result.Message + '\n\n';
                
                if (result.Orders != null) {
                    if (result.Orders.size() > 0) {
		                contextualInfo += 'Retrieved ' + result.Orders.size() + ' Order(s)...\n\n';
		
		                for (AFPressOrder order : result.Orders) {
		                    contextualInfo += '  order: ' + order;
		                }
                    }
                    else {
                        contextualInfo += 'Retrieved no orders.\n\n';
                    }
                }
            }
            
            IntegrationLogger.Instance.addIntegrationLog(ESBServiceBase.AFPRESS_INTEGRATION_NAME, request, response, getOrdersException, contextualInfo);
            IntegrationLogger.Instance.insertLogs();
        }
        
        return result;
    }
    
    private Order__c getOrder(Id orderId) {
        return
        [SELECT Id,
                Name,
                AFPress_Order__c,
                AFPress_Due_Date__c,
                Status__c,
                Copy_Code__c,
                Charge_Code__c,
                Requested_Delivery_Date__c,
                Mail_Code__c,
                Order_Name__c,
                Shipping_Location__c,
                Shipping_Method__c,
                Shipping_Street__c,
                Shipping_City__c,
                Shipping_State__c,
                Shipping_Zip__c,
                Owner.FirstName,
                Owner.LastName,
                Owner.Name,
                Owner.Email,
                Owner.Phone,
                Colleague__c,
                Colleague__r.Name,
                Colleague__r.Email,
                Colleague__r.Phone,
                (SELECT Id,
                        Name,
                        Quantity__c,
                        Material_Title__c,
                        Material_Number__c,
                        AFPress_Unique_Id__c
                   FROM Order_Line_Items__r
                  WHERE Shippable__c = true
                  AND (Processing_Type__c = 'AFPress' OR Processing_Type__c = 'AFPress & Download'))
           FROM Order__c
          WHERE Id = :orderId];
    }
    
    private HttpRequest buildCreateOrderRequest(Order__c order, String authToken) {
        API_Manager__c api = super.getAPIManager();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + authToken);
        
        request.setTimeout(120000);
        request.setHeader('Content-type', 'text/xml');
        request.setHeader('SOAPAction', 'CreateOrder');
        
        String endpoint = api.Endpoint__c + ORDER_SERVICE_PATH;
        request.setEndpoint(endpoint);
        request.setBody( buildCreateOrderRequestBody(order) );

        return request;
    }
    
    private String buildCreateOrderRequestBody(Order__c order) {
        String body =  '<?xml version="1.0" encoding="UTF-8"?>';
               body += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
               body += '<soapenv:Body>';
               body += '<CreateOrder xmlns="http://www.rocsoft.com/services/order/types" xmlns:rsast="http://www.rocsoft.com/services/types">';
        
        AFPress_Settings__c afPressSettings = AFPress_Settings__c.getInstance();
        
               if (String.isNotBlank(afPressSettings.Shared_Key__c)) {
                   body += '<rsast:SharedKey>' + afPressSettings.Shared_Key__c + '</rsast:SharedKey>';
               }
               body += '<rsa:Order xmlns:rsa="http://www.rocsoft.com/order" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="Order.xsd">';
               body += '    <rsa:OrderName useDefault="true"></rsa:OrderName>';
               body += '    <rsa:OrderPlacer>' + afPressSettings.Order_Placer__c + '</rsa:OrderPlacer>';
               
               body += '    <rsa:Site useDefault="true"></rsa:Site>';
               
               // Set the Due Date to be 2pm, 3pm during Daylight Savings, Central time to ensure the order is in
               // before the 4pm central cut off.
               String dueDateTimeString = String.valueOf(order.AFPress_Due_Date__c) + 'T14:00:00.000-06:00';
               
               body += '    <rsa:DueDateTime>' + dueDateTimeString + '</rsa:DueDateTime>';
               
               String orderPlacerContactInfo = getOrderPlacerContactInfo(order);
               
               body += '    <rsa:Note>' + orderPlacerContactInfo + '</rsa:Note>';
               
               body += '    <rsa:Billing>';
               body += '        <rsa:Address useDefault="true"></rsa:Address>';
               
               if (order.Copy_Code__c != null || 
                   String.isNotBlank(order.Mail_Code__c)) {
                   body += '        <rsa:AccountingFields>';
               
	               if (order.Copy_Code__c != null) {
    	               body += '            <rsa:AccountingField type="Charge code">' + order.Copy_Code__c + '</rsa:AccountingField>';
	               }
	
	               if (String.isNotBlank(order.Mail_Code__c)) {
	                   body += '            <rsa:AccountingField type="Mail Code">' + order.Mail_Code__c + '</rsa:AccountingField>';
	               }
               
                   body += '        </rsa:AccountingFields>';
               }

               body += '    </rsa:Billing>';
               body += '    <rsa:ExternalOrderID>' + order.Id + '</rsa:ExternalOrderID>';
               body += '    <rsa:ExternalInfo>' + order.Order_Name__c + '</rsa:ExternalInfo>';
               body += '    <rsa:Documents>';
               
               for (Integer i = 0; i < order.Order_Line_Items__r.size(); ++i) {
                   Order_Line_Item__c oli = order.Order_Line_Items__r[i];
                   
                   body += '        <rsa:Document referenceNumber="' + i + '" type="archives">';
                   body += '            <rsa:UniqueName>' + oli.AFPress_Unique_Id__c + '</rsa:UniqueName>';
                   body += '        </rsa:Document>';   
               }
               
               
               body += '    </rsa:Documents>';
               body += '    <rsa:Recipients>';
               body += '        <rsa:Recipient>';
               body += '            <rsa:ShippingMethod>' + order.Shipping_Method__c + '</rsa:ShippingMethod>';
               body += '            <rsa:Address>';

               if (String.isNotBlank(order.Shipping_Location__c)) {
                body +='                <rsa:FirstName>' + order.Shipping_Location__c + '</rsa:FirstName>';
               }
               
               String lastName = getShippingLastName(order);
               
               // lastName is always required
               body += '                <rsa:LastName>' + lastName + '</rsa:LastName>';
               body += '                <rsa:StreetAddress1>' + order.Shipping_Street__c + '</rsa:StreetAddress1>';
               body += '                <rsa:City>' + order.Shipping_City__c + '</rsa:City>';
               
               if (String.isNotBlank(order.Shipping_State__c)) {
	               if (order.Shipping_State__c.length() > 2) {
	                   body += '                <rsa:State>' + order.Shipping_State__c + '</rsa:State>';
	               }
	               else {
	                   body += '                <rsa:StateAbbreviation>' + order.Shipping_State__c + '</rsa:StateAbbreviation>';
	               }
               }
               
               
               body += '                <rsa:ZipCode>' + order.Shipping_Zip__c + '</rsa:ZipCode>';
               
               String recipientEmail = getShippingEmail(order);
               
               if (String.isNotBlank(recipientEmail)) {
                   body += '                <rsa:EmailAddress>' + recipientEmail + '</rsa:EmailAddress>';
               }
               
               body += '            </rsa:Address>';
               body += '            <rsa:RecipientDocuments>';
               
               for (Integer i = 0; i < order.Order_Line_Items__r.size(); ++i) {
                   Order_Line_Item__c oli = order.Order_Line_Items__r[i];
                   
                   body += '        <rsa:RecipientDocument documentReferenceNumber="' + i + '" type="archives">';
                   body += '            <rsa:Quantity>' + oli.Quantity__c + '</rsa:Quantity>';
                   body += '        </rsa:RecipientDocument>';
               }
               
               
               body += '            </rsa:RecipientDocuments>';
               
               if (order.Requested_Delivery_Date__c != null) {
                   String inHandsDate = 'Requested In Hands Date: ' + order.Requested_Delivery_Date__c.format();
                   body += '            <rsa:Instructions>' + inHandsDate + '</rsa:Instructions>';
               }
               
               
               
               body += '        </rsa:Recipient>';
               body += '    </rsa:Recipients></rsa:Order>';
               body += '    <SubmitOrder>true</SubmitOrder>';
               body += '    <DeleteOrderOnError>true</DeleteOrderOnError>';
               body += '    </CreateOrder></soapenv:Body></soapenv:Envelope>';
        
        return body;
    }
    
    private String getShippingLastName(Order__c order) {
        String lastName = order.Owner.Name;
        
        if (order.Colleague__c != null) {
            lastName = order.Colleague__r.Name;
        }
        
        return lastName;
    }
    
    private String getShippingEmail(Order__c order) {
        String shippingEmail = order.Owner.Email;
        
        if (order.Colleague__c != null &&
            String.isNotBlank(order.Colleague__r.Email)) {
            shippingEmail = order.Colleague__r.Email;
        }
        
        return shippingEmail;
    }

    private String getOrderPlacerContactInfo(Order__c order) {
        String orderPlacerInfo = 'Order Placer: ' + order.Owner.Name + '\n';

        if (String.isNotBlank(order.Owner.Email)) {
            orderPlacerInfo += 'Email: ' + order.Owner.Email + '\n';
        }

        if (String.isNotBlank(order.Owner.Email)) {
            orderPlacerInfo += 'Phone: ' + order.Owner.Phone + '\n';
        }

        return orderPlacerInfo;
    }

    private SubmitOrderResult buildSubmitOrderResult(HttpResponse response) {
        Dom.Document domDoc = response.getBodyDocument();
		Dom.XmlNode root = domDoc.getRootElement();
		Dom.XmlNode body = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
		Dom.XmlNode createOrderResponse = body.getChildElement('CreateOrderResponse', 'http://www.rocsoft.com/services/order/types');
		
		Dom.XmlNode successNode = createOrderResponse.getChildElement('Success', 'http://www.rocsoft.com/services/types');
		String successValue = successNode.getText();
		
		SubmitOrderResult orderResult = new SubmitOrderResult();
		orderResult.Success = successValue == 'true';
		
		if (orderResult.Success) {
			Dom.XMLNode orderIdNode = createOrderResponse.getChildElement('OrderId', 'http://www.rocsoft.com/services/order/types');
			orderResult.AFPressOrderNumber = orderIdNode.getText();
			
			return orderResult;
		}


		Dom.XMLNode messagesNode = createOrderResponse.getChildElement('Messages', 'http://www.rocsoft.com/services/types');
		
		for (Dom.XmlNode messageNode : messagesNode.getChildElements()) {
		    orderResult.Message += messageNode.getText() + '\n\n';
		}
		
		return orderResult;
/*
		<?xml version='1.0' encoding='UTF-8'?>
		<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
		    <soapenv:Header/>
		    <soapenv:Body>
		        <ns6:CreateOrderResponse xmlns:ns6="http://www.rocsoft.com/services/order/types" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns6:CreateOrderResponse">
		            <s54:Success xmlns:s54="http://www.rocsoft.com/services/types">false</s54:Success>
		            <Messages xmlns="http://www.rocsoft.com/services/types">
		                <Message type="error" code="INVALIDREQ">You are not authorized to use web services.</Message>
		            </Messages>
		            <ns6:OrderId></ns6:OrderId>
		        </ns6:CreateOrderResponse>
		    </soapenv:Body>
		</soapenv:Envelope>
*/        
    }

    private HttpRequest buildSearchOrderRequestByOrderNumbers(Set<String> orderNumbers, String authToken) {
        API_Manager__c api = super.getAPIManager();
        HttpRequest request = new HttpRequest();
        
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + authToken);
        
        request.setTimeout(120000);
        request.setHeader('Content-type', 'text/xml');
        request.setHeader('SOAPAction', 'SearchOrders');
        
        String endpoint = api.Endpoint__c + ORDER_SERVICE_PATH;
        request.setEndpoint(endpoint);
        request.setBody( buildSearchOrdersRequestByOrderNumbers(orderNumbers) );

        return request;
    }
    
    private String buildSearchOrdersRequestByOrderNumbers(Set<String> orderNumbers) {
        String body =  '<?xml version="1.0" encoding="UTF-8"?>';
        body += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
        body += '<soapenv:Body>';
        body += '<SearchOrders xmlns="http://www.rocsoft.com/services/order/types" xmlns:s="http://www.rocsoft.com/services/types">';

        AFPress_Settings__c afPressSettings = AFPress_Settings__c.getInstance();
        
        if (String.isNotBlank(afPressSettings.Shared_Key__c)) {
            body += '<s:SharedKey>' + afPressSettings.Shared_Key__c + '</s:SharedKey>';
        }

        body += '<SearchCriteria><OrderIds>';

        for (String orderNumber : orderNumbers) {
            body += '<s:Value>' + orderNumber + '</s:Value>';
        }

        body += '</OrderIds></SearchCriteria>';
        body += '</SearchOrders></soapenv:Body></soapenv:Envelope>';

        return body;
    }
    
    private SearchOrdersResult buildSearchOrdersResult(HttpResponse response) {
        return buildSearchOrdersResult(response.getBody());
    }
    
    public static SearchOrdersResult buildSearchOrdersResult(String response) {
        // The following parsing code is based on the searchorders_result.xml file
        // provided by the AFPress vendor from version 9 of AFPress.
        
        SearchOrdersResult result = new SearchOrdersResult();

        Dom.Document d = new Dom.Document();
        d.load(response);

		Dom.XmlNode root = d.getRootElement();
		Dom.XmlNode body = root.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
		Dom.XmlNode searchOrderResponse = body.getChildElements()[0];

		Dom.XmlNode successNode = searchOrderResponse.getChildElement('Success', 'http://www.rocsoft.com/services/types');
		result.Success = successNode.getText() == 'true';
		
		Dom.XMLNode messagesNode = searchOrderResponse.getChildElement('Messages', 'http://www.rocsoft.com/services/types');
        
        List<Dom.XmlNode> messageNodes = messagesNode.getChildElements();
        
        if (messageNodes.size() > 0) {
        
            result.Message = messageNodes[0].getText();
        
            for (Integer msgIndex = 1; msgIndex < messageNodes.size(); ++msgIndex) {
                Dom.XmlNode messageNode = messageNodes[msgIndex];
                result.Message += '\n\n' + messageNode.getText();
            }
        }

		Dom.XmlNode ordersNode = searchOrderResponse.getChildElement('Orders', 'http://www.rocsoft.com/services/order/types');

		List<Dom.XmlNode> orderNodes = ordersNode.getChildElements();
		
		for (Dom.XmlNode orderNode : orderNodes) {
		    AFPressOrder order = new AFPressOrder();
		    
		    Dom.XmlNode orderIdNode = orderNode.getChildElement('OrderID', 'http://www.rocsoft.com/order');
		    Dom.XmlNode orderStatusNode = orderNode.getChildElement('OrderStatus', 'http://www.rocsoft.com/order');
		
		    order.OrderNumber = orderIdNode.getText();
		    order.Status = orderStatusNode.getText();
		    
		    result.Orders.add(order);
		}
        
        return result;
    }
    
    public class ESBAFPressOrderServiceClientException extends Exception { }
    
    public class SubmitOrderResult {
        public Boolean Success { get; set; }
        
        public String Message { get; set; }
        
        public String AFPressOrderNumber { get; set; }
        
        public SubmitOrderResult() {
            Message = '';
            AFPressOrderNumber = '';
            Success = true;
        }
    }
    
    public class SearchOrdersResult {
        public List<AFPressOrder> Orders { get; set; }
        
        public Boolean Success { get; set; }
        
        public String Message { get; set; }
        
        public SearchOrdersResult() {
            Success = true;
            Message = '';
            Orders = new List<AFPressOrder>();
        }
    }
    
    public class AFPressOrder {
        public String OrderNumber { get; set; }
        
        public String Status { get; set; }
    }
}