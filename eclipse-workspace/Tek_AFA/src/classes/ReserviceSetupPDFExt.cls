public with sharing class ReserviceSetupPDFExt {
    
    public Platform_Setup__c p									{get;set;}
    public Opportunity EnrollmentOpportunity					{get;set;}
    public Account CustomerAccount								{get;set;}
    public List<Group_Plan_Availability__c>	groupProducts		{get;set;}
    public List<Marketed_Product__c> marketedProducts			{get;set;}
    public List<Plan_Date__c> planDates							{get;set;}
    public List<Eligible_Coverage__c> eligibleCoverages			{get;set;}
    public Boolean isSection125Only								{get;set;}
    public List<Account_Billing_Mode__c> billingModes			{get;set;}
    public Schema.FieldSet enrollmentPathPlatformSetupFieldSet	{get;set;}
    public List<Marketed_Product__c> importProducts				{get;set;}
    public List<Marketed_Product__c> individualProducts			{get;set;}
    
    public ReserviceSetupPDFExt(ApexPages.standardController stdCtrl){
        this.p = getFullPlatformSetupRecord(stdCtrl.getId());
        this.EnrollmentOpportunity = getOpportunity();        
        this.CustomerAccount = getAccount();        
        this.GroupProducts = getGroupProducts();
        this.marketedProducts = getMarketedProducts();
        this.eligibleCoverages = getEligibleCoverages();
        this.isSection125Only = s125Check(CustomerAccount.Id);
        this.billingModes = getBillModes();
        this.enrollmentPathPlatformSetupFieldSet = getEnrollmentPathPlatformSetupFieldSet();
        this.importProducts = getImportProducts();
        this.individualProducts = getIndividualProducts();
        this.planDates = getPlanDates();
    }
    
    public Platform_Setup__c getFullPlatformSetupRecord(String platformId)
    {
        String soql = util.getCreatableFields('Platform_Setup__c');
        soql += ', Enrollment_Form__r.Enrollment_Opportunity__c';
        soql += ' FROM Platform_Setup__c';
        soql += ' WHERE Id = :platformId';
        Platform_Setup__c platformSetupForm = Database.query(soql);
        
        return platformSetupForm;
    }
    
    public Opportunity getOpportunity()
    {
        String soql = util.getCreatableFields('Opportunity');
        soql += ', Account.Name, Account.MCP_Number__c, Account.AFenroll_Pay_Groups__c, Owner.Name, Administrative_Contact__r.Name';
        soql += ', Administrative_Contact__r.Phone, Administrative_Contact__r.Email, MCP_Number__c';
        soql += ', Enrollment_Path__r.Platform_Setup_Field_Set__c';
        soql += ' FROM Opportunity';
        soql += ' WHERE Id = \'' + p.Enrollment_Form__r.Enrollment_Opportunity__c + '\'';        
        List<Opportunity> enrollmentOpps = Database.query(soql);
        
        if(!enrollmentOpps.isEmpty())
            return enrollmentOpps[0];
        else
            return null;
    }

    public Account getAccount()
    {
        String soql = util.getCreatableFields('Account');
        soql += ' FROM Account';
        soql += ' WHERE Id = \'' + EnrollmentOpportunity.AccountId + '\'';
        List<Account> accounts = Database.query(soql);
        
        if(!accounts.isEmpty())
            return accounts[0];
        else
            return null;
    }
    
    public List<Group_Plan_Availability__c> getGroupProducts()
    {
        String soql = util.getCreatableFields('Group_Plan_Availability__c');
        soql += ' FROM Group_Plan_Availability__c';
        soql += ' WHERE Account__c = \'' + EnrollmentOpportunity.AccountId + '\'';
        List<Group_Plan_Availability__c> products = Database.query(soql);
        
        return products;
    }
    
    public List<Marketed_Product__c> getMarketedProducts()
    {
        String soql = util.getCreatableFields('Marketed_Product__c');
        soql += ' FROM Marketed_Product__c';
        soql += ' WHERE Enrollment__c = \'' + p.Enrollment_Form__c + '\'';
        List<Marketed_Product__c> products = Database.query(soql);
        
        return products;
    }
    
    public List<Plan_Date__c> getPlanDates()
    {
        String soql = util.getCreatableFields('Plan_Date__c');
        soql += ' FROM Plan_Date__c';
        soql += ' WHERE Account__c = \'' + EnrollmentOpportunity.AccountId + '\'';
        List<Plan_Date__c> planDates = Database.query(soql);
        
        return planDates;
    }
    
    public List<String> benefitCodes = new List<String> {'URM', 'DDC', 'LPF', 'HSA', 'HRA'};
    public List<Eligible_Coverage__c> getEligibleCoverages()
    {
        String soql = util.getCreatableFields('Eligible_Coverage__c');
        soql += ' FROM Eligible_Coverage__c';
        soql += ' WHERE BenefitCode__c IN :benefitCodes AND planDateRecord__r.Account__c = \'' + EnrollmentOpportunity.AccountId + '\'';
        List<Eligible_Coverage__c> coverages = Database.query(soql);
        
        return coverages;
    }
    
    public Boolean s125Check(String accountId) {
        Integer planDateCount = Database.countQuery('SELECT COUNT() FROM Plan_Date__c WHERE Account__c = :accountId');
        
        Integer eligibleCoverageCount = Database.countQuery('SELECT COUNT() FROM Eligible_Coverage__c WHERE planDateRecord__r.Account__c = :accountId AND BenefitCode__c IN :benefitCodes');
        
        if(eligibleCoverageCount < 1 && planDateCount > 0)
            return true;
        
        return false;
    }
    
    public List<Account_Billing_Mode__c> getBillModes()
    {
        String soql = util.getCreatableFields('Account_Billing_Mode__c');
        soql += ', BillMode__c';
        soql += ' FROM Account_Billing_Mode__c';
        soql += ' WHERE Account__c = \'' + EnrollmentOpportunity.AccountId + '\'';
        List<Account_Billing_Mode__c> billModes = Database.query(soql);
        
        return billModes;
    }
    
    public Schema.FieldSet getEnrollmentPathPlatformSetupFieldSet() {
        Map<String, Schema.FieldSet> platformSetupFieldSets =  Schema.SObjectType.Platform_Setup__c.fieldSets.getMap();

        if (EnrollmentOpportunity.Enrollment_Path__r != null &&
            String.isNotBlank(EnrollmentOpportunity.Enrollment_Path__r.Platform_Setup_Field_Set__c) &&
            platformSetupFieldSets.containsKey(EnrollmentOpportunity.Enrollment_Path__r.Platform_Setup_Field_Set__c)) {

            return platformSetupFieldSets.get(EnrollmentOpportunity.Enrollment_Path__r.Platform_Setup_Field_Set__c);
        }
        
        return null;
    }
    
    public List<Marketed_Product__c> getImportProducts()
    {
        List<Marketed_Product__c> products = [Select Id, Tax_Treatment__c, Product_Description__c, Plan_Status__c, Family__c,  Carrier__c, AOR__c, 
                                              products__r.name, products__r.Tax_Treatment__c, products__r.Order__c, products__r.Rider__c,products__r.Type__c,
                                              Include_on_Employer_Benefits_Site__c, Carrier_URL__c, Employer_Paid_Portion__c, products__r.Is_Tax_Treatment_Editable__c, products__r.Product_Family__c,
                                              products__r.Employer_Benefits_Site_Eligible__c, products__r.Product_Description__c
                                              From Marketed_Product__c 
                                              where enrollment__c = :p.Enrollment_Form__c and products__r.Type__c = 'Import'
                                              and products__r.Allowed_To_Be_Added_To_Enrollment__c = true
                                              order by products__r.Order__c];
        
        return products;
    }
    
    public List<Marketed_Product__c> getIndividualProducts()
    {
        List<Marketed_Product__c> products = [Select Id, Tax_Treatment__c, Product_Description__c, Plan_Status__c, Family__c,  Carrier__c, AOR__c, 
                                              products__r.name, products__r.Tax_Treatment__c, products__r.Order__c, products__r.Rider__c,products__r.Type__c,
                                              Include_on_Employer_Benefits_Site__c, Carrier_URL__c, Employer_Paid_Portion__c, products__r.Is_Tax_Treatment_Editable__c, products__r.Product_Family__c,
                                              products__r.Employer_Benefits_Site_Eligible__c
                                              From Marketed_Product__c 
                                              where enrollment__c = :p.Enrollment_Form__c and products__r.Chassis__c = 'Individual'
                                              and products__r.Allowed_To_Be_Added_To_Enrollment__c = true
                                              order by products__r.Order__c];
        
        return products;
    }
}