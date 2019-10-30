public with sharing class ProductBillingBillsController {
    
    @AuraEnabled
    public static BillsResponse getBills(Id accountId, Boolean includeCurrentBills, Boolean includeHistoricalBills) {
        BillsResponse response = new BillsResponse();
        
        response.Account = getAccountById(accountId);
        response.PayorNumbers = getPayorNumbers(response.Account);

        if (response.PayorNumbers.size() > 0) {
            response.PayorNumberUsed = response.PayorNumbers[0];
            response = getBillsByPayorNumber(accountId, response.PayorNumberUsed, includeCurrentBills, includeHistoricalBills);
        }

        return response;
    }

    @AuraEnabled
    public static BillsResponse getBillsByPayorNumber(Id accountId, String payorNumber, Boolean includeCurrentBills, Boolean includeHistoricalBills) {
        BillsResponse response = new BillsResponse();

        response.Account = getAccountById(accountId);
        response.PayorNumbers = getPayorNumbers(response.Account);
        response.PayorNumberUsed = payorNumber;
        
        ESBBillingServiceClient client = new ESBBillingServiceClient();
        client.AdditionalContextualLogInfo = getAdditionalContextualInfo(response.Account);
        response.BrowseBillResponse = client.browseByPayorMaster(payorNumber, includeHistoricalBills, includeCurrentBills, accountId);
        groupBillsByMCP(response);
        sortGroupsByMCP(response);
        sortMCPGroupsBillsByInvoiceDateDescending(response);

        return response;
    }
    
    private static Account getAccountById(Id accountId) {
        return
        [SELECT Id,
                Name,
                PayorNumber__c,
                PayorName__c,
                MCP_Number__c,
                (SELECT Id,
                        Payor_Number__c
                   FROM Billings_Information__r)
           FROM Account
          WHERE Id = :accountId];
    }
    
    private static void sortMCPGroupsBillsByInvoiceDateDescending(BillsResponse response) {
        for (MCPBillsGrouping mcpGrouping : response.BillsByMCP) {
            mcpGrouping.Bills.sort();
        }
    }
    
    private static String getAdditionalContextualInfo(Account acct) {
        String additionalContextualInfo = 'Fetching Bills from ProductBillingBillsController. Account Id: ' + acct.Id + '\n\n';
        additionalContextualInfo += 'MCP: ' + acct.MCP_Number__c;

        return additionalContextualInfo;
    }
    
    @testVisible
    private static void groupBillsByMCP(BillsResponse response) {
        Map<String, MCPBillsGrouping> mcpGroupings = new Map<String, MCPBillsGrouping>();
        Account acct = response.Account;
        
        for (ESBBillingServiceClient.ConsolidatedBill bill : response.BrowseBillResponse.Bills) {
            MCPBillsGrouping mcpGrouping = mcpGroupings.get(bill.CustomerMCPNumber);

            if (mcpGrouping == null) {
                mcpGrouping = new MCPBillsGrouping();
                mcpGrouping.MCP = bill.CustomerMCPNumber;
                mcpGrouping.CustomerName = bill.CustomerMCPName;
                mcpGrouping.AccountMCP = acct.MCP_Number__c;
                mcpGroupings.put(bill.CustomerMCPNumber, mcpGrouping);
            }

            mcpGrouping.Bills.add(bill);
        }

        response.BillsByMCP = mcpGroupings.values();
    }
    
    @testVisible
    private static void sortGroupsByMCP(BillsResponse response) {
        response.BillsByMCP.sort();
    }
    
    private static List<String> getPayorNumbers(Account acct) {
        Set<String> payorNumbers = new Set<String>();

        if (acct != null && acct.Billings_Information__r != null) {
            for (Account_Billing_Mode__c billingMode : acct.Billings_Information__r) {
                if (String.isNotBlank(billingMode.Payor_Number__c)) {
                    payorNumbers.add(billingMode.Payor_Number__c);
                }
            }
        }
        
        if (acct != null && String.isNotBlank(acct.PayorNumber__c)) {
            payorNumbers.add(acct.PayorNumber__c);
        }

        return new List<String>(payorNumbers);
    }
    
    public class BillsResponse {
        @AuraEnabled
        public ESBBillingServiceClient.BrowseBillsResponse BrowseBillResponse { get; set; }
        
        @AuraEnabled
        public List<MCPBillsGrouping> BillsByMCP { get; set; }
        
        @AuraEnabled
        public List<String> PayorNumbers { get; set; }
        
        @AuraEnabled
        public String PayorNumberUsed { get; set; }
        
        @AuraEnabled
        public Account Account { get; set; }
        
        public BillsResponse() {
            BillsByMCP = new List<MCPBillsGrouping>();
            PayorNumbers = new List<String>();
        }
    }
    
    public class MCPBillsGrouping implements Comparable {
        @AuraEnabled
        public String MCP { get; set; }
        
        @AuraEnabled
        public String CustomerName { get; set; }
        
        @AuraEnabled
        public String AccountMCP { get; set; }

        @AuraEnabled
        public List<ESBBillingServiceClient.ConsolidatedBill> Bills { get; set; }
        
        public MCPBillsGrouping() {
            Bills = new List<ESBBillingServiceClient.ConsolidatedBill>();
        }
        
        public Integer compareTo(Object compareTo) {
            MCPBillsGrouping otherGrouping = (MCPBillsGrouping) compareTo;
            
            system.debug('  group compare to. this: ' + this + ' compare to: ' + otherGrouping);
            
            if (string.isNotBlank(AccountMCP) &&
                string.isNotBlank(MCP) &&
                AccountMCP == MCP) {
                return -1;
            }
            else if (string.isNotBlank(otherGrouping.AccountMCP) &&
                     string.isNotBlank(otherGrouping.MCP) &&
                     otherGrouping.AccountMCP == otherGrouping.MCP) {
                return 1;
            }

            return CustomerName.compareTo(otherGrouping.CustomerName);
        }
    }
}