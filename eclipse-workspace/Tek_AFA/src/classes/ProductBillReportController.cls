/*
    The Bill and PolicyHolderLists are transient because very large bills cause
    the viewstate size to exceed the 135KB limit which prevents the report from rendering.
    As a result, the Bill has to be refetched when filtering, clearing, or downloaded.
*/
public with sharing class ProductBillReportController {
    private static final Integer MAX_VF_LIST_SIZE = 1000;
    
    public String BillId { get; set; }
    public Id AccountId { get; set; }
    public Account Acct { get; set; }
    public String BillPeriodFrom { get; set; }
    public String BillPeriodTo { get; set; }
    public String InvoiceNumber { get; set; }
    public String InvoiceDate { get; set; }
    public Decimal BilledAmount { get; set; }
    public Decimal ReconciledAmount { get; set; }
    public Decimal PaidAmount { get; set; }
    public String CustomerName { get; set; }
    public String CustomerMCP { get; set; }
    public transient ESBBillingServiceClient.ConsolidatedBill Bill { get; set; }
    public String BillDesc { get; set; }
    
    public String NamesFilter { get; set; }
    public String ProductsFilter { get; set; }
    public Boolean ProductsWithFilter { get; set; }
    public Boolean FilterApplied { get; set; }
    public Integer FilteredPolicyHoldersCount { get; set; }
    public String RenderAs { get; set; }
    public Boolean LoadingBills { get; set; }
    public String ErrorMessage { get; set; }
    public String BillingContactInfo { get; set; }
    public String DownloadToPDFURL { get; set; }
    
    public transient List<List<ESBBillingServiceClient.PolicyHolder>> PolicyHolderLists { get; set; }
    
    public ProductBillReportController() {
        Map<String, String> pageParameters = ApexPages.currentPage().getParameters();

        BillId = pageParameters.get('billId');
        AccountId = pageParameters.get('accountId');
        BillPeriodFrom = pageParameters.get('billPeriodFrom');
        BillPeriodTo = pageParameters.get('billPeriodTo');
        InvoiceNumber = pageParameters.get('invoiceNumber');
        InvoiceDate = pageParameters.get('invoiceDate');
        CustomerName = pageParameters.get('customerName');
        CustomerMCP = pageParameters.get('customerMCP');
        BillDesc = pageParameters.get('billDesc');
        
        BilledAmount = convertToDecimal( pageParameters.get('billedAmount') );
        ReconciledAmount = convertToDecimal( pageParameters.get('reconciledAmt') );
        PaidAmount = convertToDecimal( pageParameters.get('paidAmt') );
        PolicyHolderLists = new List<List<ESBBillingServiceClient.PolicyHolder>>();
        Acct = getAccountById(AccountId);
        
        ProductsWithFilter = true;
        FilterApplied = false;
        FilteredPolicyHoldersCount = 0;
        LoadingBills = true;
        RenderAs = '';
        
        DownloadToPDFURL = ApexPages.currentPage().getUrl() + '&downloadtopdf=true';
        
        loadBillingContactInfo();
    }
    
    public void getBillDetails() {
        ESBBillingServiceClient billingClient = new ESBBillingServiceClient();
        billingClient.AdditionalContextualLogInfo = getAdditionalContextualLoggingInfo();
        ESBBillingServiceClient.ConsolidatedBillResponse response = billingClient.browseByCBillId(BillId, AccountId);
        
        system.debug('  getBillDetails::response ' + response);
        
        if (response.Success) {
            Bill = response.Bill;

            loadPolicyHoldersIntoPolicyHolderLists(Bill.PolicyHolders);
        }
        else {
            ErrorMessage = response.Message;
        }
        
        LoadingBills = false;
    }
    
    public void downloadToPDFIfRequested() {
        String downloadToPDFParam = ApexPages.currentPage().getParameters().get('downloadtopdf');
        
        if (String.isNotBlank(downloadToPDFParam) && downloadToPDFParam == 'true') {
            NamesFilter = ApexPages.currentPage().getParameters().get('namesFilter');
            ProductsFilter = ApexPages.currentPage().getParameters().get('productsFilter');
            ProductsWithFilter = Boolean.valueOf(ApexPages.currentPage().getParameters().get('productsWithFilter'));
            
            downloadToPDF();
        }
    }
    
    public PageReference downloadToPDF() {
        RenderAs = 'pdf';

        filter();
        
        String filename = CustomerMCP + '_BillReport_' + InvoiceNumber + '.pdf';
        
        system.debug('  filename: ' + filename);
        
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + filename);

        return null;
    }
    
    public void filter() {
        if (Bill == null) {
            getBillDetails();
        }
        
        if (String.isBlank(NamesFilter) &&
            String.isBlank(ProductsFilter)) {
            
            if (Bill != null) {
                loadPolicyHoldersIntoPolicyHolderLists(Bill.PolicyHolders);
            }

            FilterApplied = false;
            FilteredPolicyHoldersCount = 0;
            return;
        }

        FilterApplied = true;

        PolicyPredicate policyPred = getPolicyPredicate();
        
        List<ESBBillingServiceClient.PolicyHolder> filteredPolicyHolders =
            new List<ESBBillingServiceClient.PolicyHolder>();

        if (Bill != null) {
	        for (ESBBillingServiceClient.PolicyHolder ph : Bill.PolicyHolders) {
	            if (policyPred.isSatisfiedBy(ph)) {
	                filteredPolicyHolders.add(ph);
	            }
	        }
        }
        
        FilteredPolicyHoldersCount = filteredPolicyHolders.size();

        loadPolicyHoldersIntoPolicyHolderLists(filteredPolicyHolders);
    }
    
    public void clearFilter() {
        NamesFilter = '';
        ProductsFilter = '';
        ProductsWithFilter = true;

        filter();
    }
    
    private Decimal convertToDecimal(String d) {
        if (String.isNotBlank(d)) {
            return Decimal.valueOf(d);
        }

        return null;
    }
    
    private PolicyPredicate getPolicyPredicate() {
        if (String.isNotBlank(NamesFilter) &&
            String.isNotBlank(ProductsFilter)) {
            return new NameAndProductPredicate(NamesFilter, ProductsFilter, ProductsWithFilter);
        }
        else if (String.isNotBlank(NamesFilter)) {
            return new NamePredicate(NamesFilter);
        }
        else {
            return new ProductPredicate(ProductsFilter, ProductsWithFilter);
        }
    }
    
    private Account getAccountById(Id acctId) {
        return
        [SELECT Id,
                Name,
                MCP_Number__c
           FROM Account
          WHERE Id = :acctId];
    }
    
    private void loadPolicyHoldersIntoPolicyHolderLists(List<ESBBillingServiceClient.PolicyHolder> policyHoldersSource) {
        Integer policyHoldersCount = policyHoldersSource.size();
        PolicyHolderLists = new List<List<ESBBillingServiceClient.PolicyHolder>>();
        
        Integer index = 0;
        
        while(index < policyHoldersCount) {
            List<ESBBillingServiceClient.PolicyHolder> policyHoldersList = new List<ESBBillingServiceClient.PolicyHolder>();
            PolicyHolderLists.add(policyHoldersList);
            Integer innerLoopMax = index + MAX_VF_LIST_SIZE;
            
            if (innerLoopMax > policyHoldersCount) {
                innerLoopMax = policyHoldersCount;
            }
            
            for (Integer i = index; i < innerLoopMax; ++i) {
                policyHoldersList.add(policyHoldersSource[i]);
            }
            
            index += MAX_VF_LIST_SIZE;
        }
    }
    
    private void loadBillingContactInfo() {
        if (String.isBlank(customerMCP) ||
            String.isBlank(BillDesc)) {
            return;
        }
        
        List<Account> accountsByMCP =
        [SELECT Id,
                Name,
                Annuity_Billing_Colleague__c,
                FSA_HSA_HRA_Billing_Colleague__c,
                Product_Billing_Colleague__c
           FROM Account
          WHERE MCP_Number__c = :customerMCP];

        if (accountsByMCP.size() != 1) {
            return;
        }
        
        Account mcpAccount = accountsByMCP[0];
        
        if (BillDesc.containsIgnoreCase('Flex')) {
            BillingContactInfo = mcpAccount.FSA_HSA_HRA_Billing_Colleague__c;
        }
        else if (BillDesc.containsIgnoreCase('Product')) {
            BillingContactInfo = mcpAccount.Product_Billing_Colleague__c;
        }
        else {
            BillingContactInfo = mcpAccount.Annuity_Billing_Colleague__c;
        }
        
        if (String.isNotBlank(BillingContactInfo)) {
            BillingContactInfo = BillingContactInfo.replace('\n', '<br/>').replace('\r\n', '<br/>');
        }
    }
    
    private abstract class PolicyPredicate {
        public abstract Boolean isSatisfiedBy(ESBBillingServiceClient.PolicyHolder ph);
    }
    
    private class NamePredicate extends PolicyPredicate {
        private List<String> FilterNames = new List<String>();
        
        public NamePredicate(String nameFilter) {
            FilterNames = nameFilter.replace(', ', ',').split(',');
        }
        
        public override Boolean isSatisfiedBy(ESBBillingServiceClient.PolicyHolder ph) {
            String policyHolderName = ph.FirstName + ' ' + ph.LastName;
            
            for (String filterName : FilterNames) {
                if (policyHolderName.containsIgnoreCase(filterName)) {
                    return true;
                }
            }
            
            return false;
        }
    }

    private class ProductPredicate extends PolicyPredicate {
        private List<String> FilteredProducts { get; set; }
        private Boolean Contains = null;

        public ProductPredicate(String productFilter, Boolean containsArg) {
            FilteredProducts = productFilter.replace(', ', ',').split(',');
            Contains = containsArg;
        }

        public override Boolean isSatisfiedBy(ESBBillingServiceClient.PolicyHolder ph) {
            if (Contains) {
                return policyHolderHasAllProducts(ph);
            }
            
            return policyHasNoneOfTheProducts(ph);
        }
        
        private Boolean policyHolderHasAllProducts(ESBBillingServiceClient.PolicyHolder ph) {
            Integer numFoundProducts = 0;
            
            for (String filteredProduct : filteredProducts) {
	            for (ESBBillingServiceClient.Policy policy : ph.Policies) {
	                if (policy.Product == filteredProduct) {
	                    ++numFoundProducts;
	                    break;
	                }
	            }
            }
            
            return numFoundProducts == filteredProducts.size();
        }
        
        private Boolean policyHasNoneOfTheProducts(ESBBillingServiceClient.PolicyHolder ph) {
            for (String filteredProduct : filteredProducts) {
                for (ESBBillingServiceClient.Policy policy : ph.Policies) {
                    if (policy.Product == filteredProduct) {
                        return false;
                    }
                }
            }

            return true;
        }
    }

    private String getAdditionalContextualLoggingInfo() {
        String additionalContextualInfo = 'Account Id: ' + AccountId + '\n\n';
        additionalContextualInfo += 'MCP: ' + CustomerMCP;

        return additionalContextualInfo;
    }

    private class NameAndProductPredicate extends PolicyPredicate {
        private NamePredicate NamePred; 
        private ProductPredicate ProdPred;
        
        public NameAndProductPredicate(String nameFilterArg, String productFilterArg, Boolean containsProduct) {
            NamePred = new NamePredicate(nameFilterArg);
            ProdPred  = new ProductPredicate(productFilterArg, containsProduct);
        }
        
        public override Boolean isSatisfiedBy(ESBBillingServiceClient.PolicyHolder ph) {
            return NamePred.isSatisfiedBy(ph) && ProdPred.isSatisfiedBy(ph);
        }
    }
}