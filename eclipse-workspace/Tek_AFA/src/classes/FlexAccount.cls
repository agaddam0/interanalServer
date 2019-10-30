public class FlexAccount implements Comparable {
    
    public String  ElectionId		{get;set;}
    public String  Account			{get;set;}
    public Decimal ElectionAmount	{get;set;}
    public Decimal TotalDeposits	{get;set;}
    public Decimal TotalPaid		{get;set;}
    public Decimal TotalPending		{get;set;}
    public Decimal TotalDenied		{get;set;}
    public Decimal AvailableBalance	{get;set;}
    public Decimal AccountBalance	{get;set;}
    public String  RunoffDays		{get;set;}
    public String  GradePeriod		{get;set;}
    public String  PlanCode			{get;set;}
    public String  PlanDesc			{get;set;}
    public Date    EffStartDate		{get;set;}
    public Date    EffEndDate		{get;set;}
    
    public FlexAccount()
    {
        
    }
    
    public Integer compareTo(Object compareTo)
    {
        FlexAccount flexAccounts = (FlexAccount) compareTo;
        if(EffEndDate == flexAccounts.EffEndDate) return 0;
        if(EffEndDate < flexAccounts.EffEndDate) return 1;
        return -1;
    }

}