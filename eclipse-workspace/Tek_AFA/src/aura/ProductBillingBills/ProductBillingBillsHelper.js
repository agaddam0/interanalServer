({
    billFilterSettings : {
        'Current': { includeHistoricalBills: false, includeCurrentBills: true },
        'Historical': { includeHistoricalBills: true, includeCurrentBills: false },
        'All': { includeHistoricalBills: true, includeCurrentBills: true }
    },

    loadBills : function(component) {
        var getBillsAction = component.get('c.getBills');
        var recordId = component.get('v.recordId');
        var helper = this;
        var billFilter = component.get('v.billFilter');
        var billFilterSettingsToUse = helper.billFilterSettings[billFilter];
        var nextPayorNumber = "";
        
        getBillsAction.setParams(
            {"accountId": recordId,
             "includeCurrentBills": billFilterSettingsToUse.includeCurrentBills,
             "includeHistoricalBills": billFilterSettingsToUse.includeHistoricalBills}
        );

        helper.showSpinner(component);

        getBillsAction.setCallback(component, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var billsResponse = response.getReturnValue();
                
                if (billsResponse.BrowseBillResponse.Success) {
                    helper.setBillDetailURLOnGroupedBills(billsResponse.BillsByMCP, billsResponse.Account.Id);
                    component.set("v.browseBillsResponse", billsResponse.BrowseBillResponse);
                    component.set('v.billsByMCP', billsResponse.BillsByMCP);
                    component.set('v.account', billsResponse.Account);
                    
                    helper.incrementBillsCount(component, billsResponse.BrowseBillResponse);
                    nextPayorNumber = helper.getNextPayorNumber(component, billsResponse);
                    
                    if (nextPayorNumber) {
                        helper.getNextPayorNumbersBills(component, nextPayorNumber);
                    }
                }
                else {
                    component.set("v.browseBillsResponse", []);
                    component.set("v.errorMessage", billsResponse.BrowseBillResponse.Message);
                }
                
                var loadingOnInit = component.get('v.loadingOnInit');
                var billsByMCP = component.get('v.billsByMCP');
                
                // If there's no Current bills for all payor numbers when the component is initially opened,
                // load the historical bills instead. If there are neither Current nor
                // Historical bills, show no bills.
                if (loadingOnInit &&
                    billFilter == 'Current' &&
                    !nextPayorNumber &&
                    billsResponse.BrowseBillResponse.Message == 'No bills found.' &&
                    !billsByMCP) {

                    component.set('v.loadingOnInit', false);
                    component.set('v.billFilter', 'Historical');
                    component.set('v.errorMessage', null);
                    helper.loadBills(component);
                }

                // Set to false so it doesn't run again.
                component.set('v.loadingOnInit', false);
            }
            else {
                console.log('Problem getting bills. Response state: ' + state);
            }
            
            if (!nextPayorNumber) {
                helper.hideSpinner(component);
            }
        });
        
        $A.enqueueAction(getBillsAction);
    },

    getNextPayorNumbersBills : function(component, nextPayorNumber) {
        var getBillsByPayorNumberAction = component.get('c.getBillsByPayorNumber');
        var recordId = component.get('v.recordId');
        var helper = this;
        var billFilter = component.get('v.billFilter');
        var billFilterSettingsToUse = helper.billFilterSettings[billFilter];
        
        getBillsByPayorNumberAction.setParams(
            {"accountId": recordId,
             "payorNumber": nextPayorNumber,
             "includeCurrentBills": billFilterSettingsToUse.includeCurrentBills,
             "includeHistoricalBills": billFilterSettingsToUse.includeHistoricalBills}
        );

        helper.showSpinner(component);

        getBillsByPayorNumberAction.setCallback(component, function(response){
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var billsResponse = response.getReturnValue();
                
                if (billsResponse.BrowseBillResponse.Success) {
                    helper.setBillDetailURLOnGroupedBills(billsResponse.BillsByMCP, billsResponse.Account.Id);
                    component.set("v.browseBillsResponse", billsResponse.BrowseBillResponse);
                    
                    var billsByMCP = component.get('v.billsByMCP');
                    
                    for (let mcpBillingGroup of billsResponse.BillsByMCP) {
                        billsByMCP.push(mcpBillingGroup);
                    }

                    component.set('v.billsByMCP', billsByMCP);
                    component.set('v.account', billsResponse.Account);
                    
                    helper.incrementBillsCount(component, billsResponse.BrowseBillResponse);
                    nextPayorNumber = helper.getNextPayorNumber(component, billsResponse);
                    
                    if (nextPayorNumber) {
                        helper.getNextPayorNumbersBills(component, nextPayorNumber);
                    }
                    else {
                        // All done fetching bills.
                        helper.sortBillsByMCP(component);
                    }
                }
                else {
                    component.set("v.browseBillsResponse", []);
                    component.set("v.errorMessage", billsResponse.BrowseBillResponse.Message);
                }
            }
            else {
                console.log('Problem getting bills. Response state: ' + state);
            }
            
            if (!nextPayorNumber) {
                helper.hideSpinner(component);
            }
        });
        
        $A.enqueueAction(getBillsByPayorNumberAction);
    },

    showSpinner : function(component) {
        component.set('v.loading', true);
    },
    
    hideSpinner : function(component) {
        component.set('v.loading', false);
    },

    setBillDetailURLOnGroupedBills : function(BillsByMCP, accountId) {
        for (let mcpGrouping of BillsByMCP) {
            for (let bill of mcpGrouping.Bills) {
                bill.billDetailURL = '/apex/ProductBillReport?billId=' + bill.BillId + '&accountId=' + accountId
                                     + '&invoiceNumber=' + bill.InvoiceNumber + '&invoiceDate=' + bill.InvoiceDate
                                     + '&billPeriodFrom=' + bill.BillPeriodFromDate + '&billPeriodTo=' + bill.BillPeriodToDate
                                     + '&billedAmount=' + bill.BilledAmount + '&reconciledAmt=' + bill.ReconciledAmount
                                     + '&paidAmt=' + bill.TotalPaymentAmount + '&customerName=' + bill.CustomerMCPName
                                     + '&customerMCP=' + bill.CustomerMCPNumber + '&billDesc=' + bill.BillDescription;
            }
        }
    },

    getNextPayorNumber : function(component, billsResponse) {
        var loadedPayorNumbers = component.get('v.loadedPayorNumbers');
        loadedPayorNumbers.push(billsResponse.PayorNumberUsed);
        component.set('v.loadedPayorNumbers', loadedPayorNumbers);
        
        for (let payorNumber of billsResponse.PayorNumbers) {
            if (loadedPayorNumbers.includes(payorNumber) == false) {
                return payorNumber;
            }
        }

        return "";
    },
    
    incrementBillsCount : function(component, browseBillsResponse) {
        var billsCount = component.get('v.billsCount');
        billsCount += browseBillsResponse.Bills.length;
        
        component.set('v.billsCount', billsCount);
    },

    reset : function(component) {
        var helper = this;
        helper.clearLoadedPayorNumbers(component);
        component.set('v.billsCount', 0);
    },

    clearLoadedPayorNumbers : function(component) {
        component.set('v.loadedPayorNumbers', []);
    },

    sortBillsByMCP : function(component) {
        var billsByMCP = component.get('v.billsByMCP');
        
        // Sort the mcp groupings the same as they are in Apex. This is needed
        // because this component does one callout to the API per Payor Number
        // to avoid Apex Limits so we need to do the sorting client side
        // when there are multiple payor numbers.
        billsByMCP.sort(function(mcpGroup1, mcpGroup2){
            
            if (mcpGroup1.AccountMCP &&
                mcpGroup1.MCP &&
                mcpGroup1.AccountMCP == mcpGroup1.MCP) {
                return -1;
            }
            else if (mcpGroup2.AccountMCP &&
                     mcpGroup2.MCP &&
                     mcpGroup2.AccountMCP == mcpGroup2.MCP) {
                return 1;
            }

            return mcpGroup1.CustomerName.localeCompare(mcpGroup2.CustomerName);
        });

        component.set('v.billsByMCP', billsByMCP);
    }
})