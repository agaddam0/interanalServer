public without sharing class CurrentBillsSyncher {

    private Set<Id> AccountIds { get; set; }

    public CurrentBillsSyncher(Set<Id> accountIdsArg) {
        AccountIds = accountIdsArg;
    }
    
    public void Sync() {
        List<Account> accountsToSync = getAccountsToSync();
        List<Current_Bill__c> currentBillsToUpsert = new List<Current_Bill__c>();
        List<Current_Bill__c> currentBillsToDelete = new List<Current_Bill__c>();
        ESBBillingServiceClient billingClient = new ESBBillingServiceClient();
        
        IntegrationLogger.Instance.SkipInsertingLogs = true;
        
        for (Account acctToSync : accountsToSync) {
            billingClient.AdditionalContextualLogInfo = getAdditionalContextualInfo(acctToSync);
            
            ESBBillingServiceClient.BrowseBillsResponse billsResponse =
                billingClient.browseByPayorMaster(acctToSync.PayorNumber__c, false, true, acctToSync.Id);

            if (billsResponse.Success == false) { continue; }

            List<Current_Bill__c> acctCurrentBills = buildCurrentBillsForUpsert(billsResponse.Bills);
            currentBillsToUpsert.addAll(acctCurrentBills);

            List<Current_Bill__c> acctCurrentBillsToDelete = findCurrentBillsToDelete(billsResponse.Bills, acctToSync);
            currentBillsToDelete.addAll(acctCurrentBillsToDelete);
        }

        if (currentBillsToUpsert.size() > 0) {
            linkCurrentBillsToUpsertToTheirMCPAccounts(currentBillsToUpsert);
            
            upsert currentBillsToUpsert Bill_Id__c;
        }
        
        if (currentBillsToDelete.size() > 0) {
            system.debug('   currentBillsToDelete: ' + currentBillsToDelete);
            
            delete currentBillsToDelete;
        }
        
        IntegrationLogger.Instance.SkipInsertingLogs = false;
        IntegrationLogger.Instance.insertLogs();
    }
    
    private List<Account> getAccountsToSync() {
        Map<String, Account> accountsByPayorNumber = new Map<String, Account>();
        
        List<Account> potentialAccountsToSync =
        [SELECT Id,
                Name,
                MCP_Number__c,
                PayorNumber__c,
                (SELECT Id,
                        Bill_Id__c
                   FROM Current_Bills__r)
           FROM Account
          WHERE Id in :AccountIds];

        for (Account potentialAccountToSync : potentialAccountsToSync) {
            // Only let one account be used for each payor number so that a duplicate value doesn't
            // occur on upsert if there are at least two accounts with the same payor number in this dataset.
            accountsByPayorNumber.put(potentialAccountToSync.PayorNumber__c, potentialAccountToSync);
        }

        return accountsByPayorNumber.values();
    }
    
    private List<Current_Bill__c> buildCurrentBillsForUpsert(List<ESBBillingServiceClient.ConsolidatedBill> bills) {
        List<Current_Bill__c> currentBillsForUpsert = new List<Current_Bill__c>();
        
        Id ownerId = UserInfo.getUserId();

        Current_Bills_Sync_Settings__c settings = Current_Bills_Sync_Settings__c.getInstance();

        if (settings != null &&
            String.isNotBlank(settings.Current_Bill_Owner_Id__c)) {
            ownerId = settings.Current_Bill_Owner_Id__c;
        }

        for (ESBBillingServiceClient.ConsolidatedBill bill : bills) {
            Current_Bill__c cb = new Current_Bill__c();
            cb.Bill_Id__c = bill.BillId;
            cb.Bill_Type__c = bill.BillType;
            cb.Billed_Amount__c = bill.BilledAmount;
            cb.Description__c = bill.BillDescription;
            cb.Due_Date__c = Date.parse(bill.DueDate);
            cb.Name = bill.InvoiceNumber;
            cb.MCP__c = bill.CustomerMCPNumber;
            cb.MCP_Customer_Name__c = bill.CustomerMCPName;
            cb.Payor_Number__c = bill.PayorNumber;
            cb.Reconciled_Amount__c = bill.ReconciledAmount;
            cb.Status__c = bill.BillStatus;
            cb.Distribution_Id__c = bill.DistributionId;
            cb.Invoice_Date__c = Date.parse(bill.InvoiceDate);
            cb.Bill_Period_From__c = Date.parse(bill.BillPeriodFromDate);
            cb.Invoice_Number_Replaced__c = bill.InvoiceNumberReplaced;
            cb.OwnerId = ownerId;

            if (String.isNotBlank(bill.BillPeriodToDate)) {
                cb.Bill_Period_To__c = Date.parse(bill.BillPeriodToDate);
            }

            currentBillsForUpsert.add(cb);
        }

        return currentBillsForUpsert;
    }

    private List<Current_Bill__c> findCurrentBillsToDelete(List<ESBBillingServiceClient.ConsolidatedBill> bills, Account acctToSync) {
        List<Current_Bill__c> billsToDelete = new List<Current_Bill__c>();
        
        for (Current_Bill__c existingBill : acctToSync.Current_Bills__r) {
            Boolean billFound = false;
            
            for (ESBBillingServiceClient.ConsolidatedBill latestBill : bills) {
                if (latestBill.BillId == existingBill.Bill_Id__c) {
                    billFound = true;
                    break;
                }
            }
            
            if (billFound == false) {
                billsToDelete.add(existingBill);
            }
        }
        
        return billsToDelete;
    }

    private void linkCurrentBillsToUpsertToTheirMCPAccounts(List<Current_Bill__c> currentBillsToUpsert) {
        Set<String> mcps = new Set<String>();
        
        for (Current_Bill__c billToUpsert : currentBillsToUpsert) {
            mcps.add(billToUpsert.MCP__c);
        }
        
        List<Account> mcpAccounts =
        [SELECT Id,
                Name,
                MCP_Number__c
           FROM Account
          WHERE MCP_Number__c in :mcps];

        Map<String, Account> accountsByMCP = new Map<String, Account>();

        for (Account mcpAccount : mcpAccounts) {
            accountsByMCP.put(mcpAccount.MCP_Number__c, mcpAccount);
        }

        for (Current_Bill__c billToUpsert : currentBillsToUpsert) {
            Account mcpAccount = accountsByMCP.get(billToUpsert.MCP__c);
            
            if (mcpAccount != null) {
                billToUpsert.Account__c = mcpAccount.Id;
            }
        }
    }

    private static String getAdditionalContextualInfo(Account acct) {
        String additionalContextualInfo = 'Fetching Current Bills from Current Bills Syncer. Account Id: ' + acct.Id + '\n\n';
        additionalContextualInfo += 'MCP: ' + acct.MCP_Number__c;

        return additionalContextualInfo;
    }
}