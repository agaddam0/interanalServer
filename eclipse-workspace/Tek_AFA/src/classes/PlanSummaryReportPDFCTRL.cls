public with sharing class PlanSummaryReportPDFCTRL {
    
    public Account Account                                  {get;set;}
    public List<PlanDateContext> planDateInformationContext {get;set;}
    public List<Contact> generalContacts                    {get;set;}
    public List<Contact> billingContacts                    {get;set;}

    private List<Plan_Date__c> planDates                    {get;set;}
    private List<Account> allRelatedEmployers               {get;set;}
    private List<Eligible_Coverage__c> allEligibleCoverages {get;set;}

    public PlanSummaryReportPDFCTRL(ApexPages.StandardController stdController)
    { 
        Id accountId = stdController.getId();
        
        // Get the Account
        String soql = 'SELECT ';
        soql += util.getFieldsInSOQL('Account');
        soql += ', Account.Owner.Name';
        soql += ' FROM Account';
        soql += ' WHERE Id = \'' +  accountId + '\'';
        List<Account> Accounts = Database.query(soql);
        Account = Accounts[0];
        
        // Get the Plan Dates
        soql = 'SELECT ';
        soql += util.getFieldsInSOQL('Plan_Date__c');
        soql += ' FROM Plan_Date__c';
        soql += ' WHERE Account__c = \'' +  Account.Id + '\'';
        planDates = Database.query(soql);
        
        getContactsFromAccount();
        getChildDataFromPlanDates();
        buildPlanDateContext();
    }

    public void getContactsFromAccount(){
        generalContacts = [SELECT Name, Email, Phone FROM Contact WHERE AccountId =: Account.Id AND General_Contact__c = true];
        billingContacts = [SELECT Name, Email, Phone FROM Contact WHERE AccountId =: Account.Id AND Billing_Contact__c = true];
    }

    public void getChildDataFromPlanDates() {
        List<Id> planDateIds = new List<Id>();
        List<Id> relatedEmployerIds = new List<Id>();

        for(Plan_Date__c planDate : planDates){
            planDateIds.add(planDate.Id);
            relatedEmployerIds.add(planDate.Related_Employer__c);
        }
        allRelatedEmployers = getRelatedEmployers(relatedEmployerIds);
        allEligibleCoverages = getAllEligibleCoverages(planDateIds);
    }

    public void buildPlanDateContext() {
        planDateInformationContext = new List<PlanDateContext>();
        for(Plan_Date__c planDate : planDates){

            // get the Related Employers associated to this plan date
            List<Account> relatedEmployersPlanDateList = new List<Account>();
            for(Account employer : allRelatedEmployers){
                if(planDate.Related_Employer__c == employer.Id){
                    relatedEmployersPlanDateList.add(employer);
                }
            }

            // get the Eligible Coverages associated to this plan date
            List<Eligible_Coverage__c> eligibleCoveragesPlanDateList = new List<Eligible_Coverage__c>();
            for(Eligible_Coverage__c coverage : allEligibleCoverages){
                if(planDate.Id == coverage.PlanDateRecord__c){
                    eligibleCoveragesPlanDateList.add(coverage);
                }
            }

            planDateInformationContext.add(new PlanDateContext(planDate, relatedEmployersPlanDateList, eligibleCoveragesPlanDateList));
        }
    }

    public List<Account> getRelatedEmployers(List<Id> relatedEmployerIds){
        if(relatedEmployerIds.size() < 1){
            return null;
        }

        String soql = 'SELECT ';
        soql += util.getFieldsInSOQL('Account');
        soql += ' FROM Account';
        soql += ' WHERE Id IN: relatedEmployerIds';
        system.debug('Related Employers: ' +soql);
        return Database.query(soql);
    }

    public List<Eligible_Coverage__c> getAllEligibleCoverages(List<Id> planDateIds) {
        if(planDateIds.size() < 1){
            return null;
        }

        String soql = 'SELECT ';
        soql += util.getFieldsInSOQL('Eligible_Coverage__c');
        soql += ' FROM Eligible_Coverage__c';
        soql += ' WHERE PlanDateRecord__c IN: planDateIds';
        system.debug('Eligible Coverages: ' +soql);
        return Database.query(soql);
    }

    public class PlanDateContext {
        public Plan_Date__c PlanDate                                   {get;set;}
        public List<Account> RelatedEmployers                          {get;set;}
        public List<Eligible_Coverage__c> MedicalBenefits              {get;set;}
        public List<Eligible_Coverage__c> CancerBenefits               {get;set;}
        public List<Eligible_Coverage__c> DisabilityBenefits           {get;set;}
        public List<Eligible_Coverage__c> DentalBenefits               {get;set;}
        public List<Eligible_Coverage__c> VisionBenefits               {get;set;}
        public List<Eligible_Coverage__c> GroupLifeBenefits            {get;set;}
        public List<Eligible_Coverage__c> FlexAccountInformation       {get;set;}
        public List<Eligible_Coverage__c> HSAInformation               {get;set;}

        public PlanDateContext(Plan_Date__c pDate, List<Account> rEmployers, List<Eligible_Coverage__c> coverages){
            PlanDate = pDate;
            RelatedEmployers = rEmployers;
            MedicalBenefits = new List<Eligible_Coverage__c>();
            CancerBenefits = new List<Eligible_Coverage__c>();
            DisabilityBenefits = new List<Eligible_Coverage__c>();
            DentalBenefits = new List<Eligible_Coverage__c>();
            VisionBenefits = new List<Eligible_Coverage__c>();
            GroupLifeBenefits = new List<Eligible_Coverage__c>();
            FlexAccountInformation = new List<Eligible_Coverage__c>();
            HSAInformation = new List<Eligible_Coverage__c>();

            for(Eligible_Coverage__c coverage : coverages){
                
                switch on coverage.BenefitCode__c {
                    when 'MEDICAL' {
                        MedicalBenefits.add(coverage);
                    }

                    when 'CANCER' {
                        CancerBenefits.add(coverage);
                    }

                    when 'DISABILITY' {
                        DisabilityBenefits.add(coverage);
                    }

                    when 'DENTAL' {
                        DentalBenefits.add(coverage);
                    }

                    when'VISION' {
                        VisionBenefits.add(coverage);
                    }

                    when 'GROUPLIFE' {
                        GroupLifeBenefits.add(coverage);
                    }

                    when 'DDC', 'URM', 'LPF' {
                        FlexAccountInformation.add(coverage);
                    }

                    when 'HSA' {
                        HSAInformation.add(coverage);
                    }
                }
            }
        }
    }
}