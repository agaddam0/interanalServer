public class FlexClaim {
    
    public String 	ElectionId		{get;set;}
    public Decimal 	ClaimAmount		{get;set;}
    public Date		IncurBeginDate	{get;set;}
    public Date		IncurEndDate	{get;set;}
    public String 	ClaimNumber		{get;set;}
    public String 	Account			{get;set;}
    public Decimal 	PaidAmount		{get;set;}
    public Date		PaidDate		{get;set;}
    public String 	CodeDesc		{get;set;}
    public String 	ClaimStatus		{get;set;}
    
    public FlexClaim()
    {
        
    }
}