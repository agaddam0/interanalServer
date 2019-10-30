/*********************************************************************************************
// Version:             1.0
// Author:              Etherios
// Date Created:        1/13/2015
// Description:         PlanSummaryFormCTRL Apex class 
//   
// Copyright 2015 Etherios. All rights reserved. Customer confidential. Do not distribute.
//
// Revision History
// DATE               AUTHOR                    REQUIREMENT#          DETAILS
// 1/13/2015         Gavin Winkel                                  See Class header notes
//
// *********************************************************************************************
// ********************************************************************************************/


/***********************************************************************************************
* Class Header Notes
* Controller for the PlanSummaryForm page
* 
* On page load, this class pulls in data from the form
* Updates Platorm Setup Form fields
* 
* Handles the submission of the form, and the creation of the form PDF
*
***********************************************************************************************/
public with sharing class PlanSummaryFormCTRL_v2 {

    //public variables available to pull/push into form
    public Section_125_Plan_Summary__c s                {get;set;}
    public Account acc                                  {get;set;}
    public List<Plan_Date__c> planDates                 {get;set;}
    public Enrollment_Form__c enrollmentForm            {get;set;}
    public Opportunity enrollmentOpp                    {get;set;}
    public String retUrl                                {get;set;}
    public string statusMsg                             {get;set;}
    public boolean showErrorMessages                    {get;set;}
    public boolean summaryTabComplete                   {get;set;}
    public string fieldValue                            {get;set;}
    public string fieldName                             {get;set;}
    public Map<string,string>  hMap                     {get;set;}
    public List<PlanDateContext> planDateInformationContext {get;set;}
    public List<Contact> generalContacts                    {get;set;}
    public List<Contact> billingContacts                    {get;set;}

    private List<Account> allRelatedEmployers               {get;set;}
    private List<Eligible_Coverage__c> allEligibleCoverages {get;set;}

    //Construtor gathers data from form record and related records
    public PlanSummaryFormCTRL_v2(ApexPages.StandardController stdController)
    {  
        List<string> fieldnames = new List<string>();
        if (!Test.isRunningTest()) 
        {
            fieldnames.add('Enrollment_Form__c');
            fieldnames.add('Status__c');
            fieldnames.add('Request_Edit__c');
            
            stdController.addFields(fieldnames);
        }
        
        this.s = (Section_125_Plan_Summary__c)stdController.getRecord();
    }
    
    public void init()
    {
        getSummaryData();
        setTabColors();
        setStatusMsg();
        getHelpText();
        getContactsFromAccount();
        getChildDataFromPlanDates();
        buildPlanDateContext();
        
        // Get the return url
        if (ApexPages.currentPage().getParameters().containsKey('retUrl'))
            retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        showErrorMessages = true;
    }
    
    public void setTabColors() 
    {
        summaryCheckRequiredFields(false);
        
        system.debug(':::setTabColors() called');
        system.debug(':::summaryTabComplete ' + summaryTabComplete);
    }
    
    private void getSummaryData()
    {
        // Get the Enrollment Form
        enrollmentForm = [SELECT Id, Enrollment_Opportunity__c, Status__c FROM Enrollment_Form__c WHERE Id =: s.Enrollment_Form__c];
        
        // Get the Opportunity
        enrollmentOpp = [SELECT Id, AccountId, MCP_Number__c, Tax_Id__c, Additional_MCPs__c FROM Opportunity WHERE Id =: enrollmentForm.Enrollment_Opportunity__c];
        
        // Get the Account
        String soql = util.getCreatableFields('Account');
        soql += ', Account.Owner.Name, Account.Owner.Agent_ID__c';
        soql += ' FROM Account';
        soql += ' WHERE Id = \'' +  enrollmentOpp.AccountId + '\'';
        system.debug('Account: ' +soql);
        List<Account> Accounts = Database.query(soql);
        acc = Accounts[0];
        
        // Get the Plan Dates
        soql = util.getCreatableFields('Plan_Date__c');
        soql += ' FROM Plan_Date__c';
        soql += ' WHERE Account__c = \'' +  acc.Id + '\'';
        system.debug('Plan Date: ' +soql);
        planDates = Database.query(soql);
    }
    
    public void save() 
    {
        system.debug('::: saving Summary Form');
        
        try
        {   
            update s;
            summaryCheckRequiredFields(false);
        }
        
        catch (system.dmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  e.getDmlMessage(0)));
            showErrorMessages = true;
        }  
        
        system.debug('::: Summary Form after save: ' + s);
    }
    
    private void setStatusMsg() {
        
        statusMsg = s.status__c;
        if (s.Request_Edit__c)
            statusMsg += ' - Request To Edit Sent';
    }
    
    public void checkRequiredFieldsAndDisplay() 
    {
        summaryCheckRequiredFields(true);
        system.debug('::: ran checkRequiredFieldsAndDisplay on server ');
    }
    
    public void summaryCheckRequiredFields(boolean showField) 
    {
        summaryTabComplete = true;
        
        if(s.Changes__c == null)
        {
            if(showField)
                s.Changes__c.addError('Required Field');
            summaryTabComplete = false;
        }
            
    }
    
    public void updateEnrollmentForm()
    {
        // If request edit is requested and the form is not further than the 'Submitted' state
        // automatically re-open the form.  If the form has entered into a further state,
        // then a true request edit needs to be sent back to Home Office
        if (fieldName == 'Request_Edit__c')
        {
            if(fieldValue == 'true')
            {
                if(s.Status__c != 'Submitted')
                    s.Request_Edit__c = true;
                else
                    s.Status__c = 'In Progress';
            }
            else
                s.Request_Edit__c = false;
            
            update s;
            
            setStatusMsg();
        }
    }
    
    //Submit Form Method
    //Set Form Status to 'Submitted'
    //Set Enrollment Form Owner to Home Office Queue
    //Generate Form PDF and attach onto parent account record
    public void submitForm()
    {
        System.debug('### Submitting Summary form');
        
        s.Status__c = 'Submitted';
        update s;
        
        setStatusMsg();
               
        System.debug('### Account: ' + acc);
        
        PageReference pagePdf = Page.PlanSummaryFormPDF;
        System.debug('### pagepdf: ' + pagepdf);
        pagepdf.getParameters().put('id', s.Id);
        
        Blob pdfPageBlob;
        if (Test.isRunningTest())
            pdfPageBlob = Blob.valueof('test');
        else
            pdfPageBlob = pagePdf.getContentAsPDF();
        System.debug('### pdfPageBlob : ' + pdfPageBlob );
                     
        Attachment a = new Attachment();
        a.Body = pdfPageBlob;     
        a.ParentId = enrollmentOpp.Id;
        a.Name = 'PlanSummaryFormPDF.pdf';
        a.Description = 'PlanSummaryFormPDF';
        insert a;
        System.debug('### Attachment: ' + a);
    }
    
    public void getHelpText() {
        // map of all fields in the object
        Map<String, Schema.SObjectField> objectFields =  schema.SObjectType.Section_125_Plan_Summary__c.fields.getMap();
        Set<string> fields = objectFields.keyset();
        hMap = new Map<string,string>();
        // iterate over the requested fields and get the describe info for each one. 
        // add it to a map with field name as key
        for(String field : fields){
            Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
            // add the results to the map to be returned
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText()); 
        }
    }

    public void getContactsFromAccount(){
        generalContacts = [SELECT Name, Email, Phone FROM Contact WHERE AccountId =: acc.Id AND General_Contact__c = true];
        billingContacts = [SELECT Name, Email, Phone FROM Contact WHERE AccountId =: acc.Id AND Billing_Contact__c = true];
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

        String soql = util.getCreatableFields('Account');
        soql += ' FROM Account';
        soql += ' WHERE Id IN: relatedEmployerIds';
        system.debug('Related Employers: ' +soql);
        return Database.query(soql);
    }

    public List<Eligible_Coverage__c> getAllEligibleCoverages(List<Id> planDateIds) {
        if(planDateIds.size() < 1){
            return null;
        }

        String soql = util.getCreatableFields('Eligible_Coverage__c');
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