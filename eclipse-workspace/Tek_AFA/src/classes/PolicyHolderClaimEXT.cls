public class PolicyHolderClaimEXT {
    
    public List<ProductClaim> PClaims               {get;set;}
    public List<FlexAccount> FAccounts              {get;set;}
    public List<FlexClaim> FClaims                  {get;set;}
    public static PolicyHolder__c holder            {get;set;}
    public static List<ApexPages.Message> Errors    {get;set;}
    public static String PageName                   {get;set;}
    public static Boolean showTable                 {get;set;}
    public String CustomerNo                        {get;set;}
    
    public PolicyHolderClaimEXT(ApexPages.StandardController stdController) {
        String id = stdController.getId();
        showTable = false;
        
        holder = [SELECT Id, Customer_Number__c FROM Policyholder__c WHERE Id =: id];
    }
    
    public Boolean getHasErrorMessages() {
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }
    
    public void getFlexInfo()
    {
        ClaimCallouts.BuildFlexAccount(CustomerNo);
        
        if(ClaimCallouts.ErrorMessages.size() > 0)
        {
            addClaimsErrorsToPage(ClaimCallouts.ErrorMessages);
        }
        else
        {
            FClaims = ClaimCallouts.FlexClaims;
            FAccounts = ClaimCallouts.FlexAccts;
            FAccounts.sort();
        }
        showTable = true;
    }
    
    public void getProductClaims()
    {
        ClaimCallouts.BuildProductClaims(CustomerNo);
        
        if(ClaimCallouts.ErrorMessages.size() > 0)
        {
            addClaimsErrorsToPage(ClaimCallouts.ErrorMessages);
        }
        else
        {
            PClaims = ClaimCallouts.Claims;            
        }
        showTable = true;
    }
    
    private void addClaimsErrorsToPage(List<String> claimErrors) {
        for(String m : claimErrors)
        {
            ApexPages.Message errorM = new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error retrieving data. Error Detail: ' + m);
            system.debug(m);
            ApexPages.addMessage(errorM);
        }
    }
}