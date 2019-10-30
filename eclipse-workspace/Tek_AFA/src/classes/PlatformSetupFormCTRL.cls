/*********************************************************************************************
// Version:             1.0
// Author:              Etherios
// Date Created:        1/13/2015
// Description:         PlatformSetupFormCTRL Apex class 
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
* Controller for the PlatformSetupForm page
* 
* On page load, this class pulls in data from related objects
* Updates Platorm Setup Form fields as well as fields on related objects.
* Also responsible for creating and deleting related objects.
* 
* Handles the submission of the form, and the creation of the form PDF
*
***********************************************************************************************/
public with sharing class PlatformSetupFormCTRL extends PreEnrollmentControllerBase {
    public static final String CORE_BENEFITS_GENERIC_FOLDERS = 'Generic Folders';

    //public variables available to pull/push into form
    public Customer_Setup_Form__c theCustomerSetupForm          {get;set;}
    public Platform_Setup__c p                                  {get;set;}
    public Customer_Setup_Form__c csForm                        {get;set;}
    public Enrollment_Form__c enrollmentForm                    {get;set;}
    public Opportunity enrollmentOpp                            {get;set;}
    public Account acc                                          {get;set;}
    public User acctManager                                     {get;set;}
    public User enrollTeam                                      {get;set;}
    public User primAcctMgr                                     {get;set;}
    public Contact adminContact                                    {get;set;}
    public String acctManagerName                               {get;set;}
    public String enrollTeamName                                {get;set;}
    public String primAcctMgrName                               {get;set;}
    public String formId                                        {get;set;}
    public String fieldName                                     {get;set;}
    public String fieldValue                                    {get;set;}
    /* jhicks 12/16 now using "formIsSubmitted */
    public String retUrl                                        {get;set;}
    public String customerId                                    {get;set;}
    public String planSummaryId                                 {get;set;}
    public Integer section125count                              {get;set;}
    public String status                                        {get;set;}
    public List<String> MarketedProducts                        {get;set;}
    public Id BenefitIDToDelete                                 {get;set;}
    public Id BenefitID                                         {get;set;}
    public String BenefitType                                   {get;set;}
    public Id formToAdd                                         {get;set;}
    public Id accountId                                            {get;set;}
    public List<Core_Benefit_Form__c> coreBenefits                {get;set;}
    public List<OpportunityTeamMember> oppTeam                    {get;set;}
    public boolean showErrorMessages                            {get;set;}
    /* jhicks - needed for all forms */
    public string statusMsg                                        {get; set;}
    public boolean formIsSubmitted                                {get; set;}
    /* jhicks - needed for all forms */    
    public  boolean texasLifeTabComplete                        {get; set;}
    public  boolean dvrInfoTabComplete                            {get; set;}
    public  boolean s125servicesTabComplete                        {get; set;}
    public  boolean coreDetailsTabComplete                      {get; set;}
    public Map<string,string>  hMap                                {get; set;}
    public List<Import_Product__c> importProducts                  {get; set;}
    
    @testVisible
    private Map<String, Schema.FieldSetMember> TestCoreDetailsRequiredFields { get; set; }
     
    //Construtor gathers data from form record and related records
    public PlatformSetupFormCTRL(ApexPages.StandardController stdController) {
        addExtraFieldsToStandardController(stdController);
        
        //Retrieve form record from page
        this.p = (Platform_Setup__c)stdController.getRecord();
        if (p.Status__c != null)
        {
            status = p.Status__c.toUpperCase();
            statusMsg = p.Status__c;
        }
                
        if (ApexPages.currentPage().getParameters().containsKey('id')){
            formId = ApexPages.currentPage().getParameters().get('id');
        }
        
        //Check if form has been submitted
        if (p != null && p.Status__c != 'In Progress')
            formIsSubmitted = true;
        else
            formIsSubmitted = false;
        
        //Url to return to on 'back'
        if (ApexPages.currentPage().getParameters().containsKey('retUrl'))
            retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        //Parent enrollment form
        if (p != null && p.Enrollment_Form__c != null)
            loadEnrollmentForm();
        
        //Enrollment Opportunity Record
        if (enrollmentForm != null && enrollmentForm.Enrollment_Opportunity__c != null)
            this.enrollmentOpp = [SELECT Id, 
                                         Name, 
                                         AccountId, 
                                         Enrollment_Start_Date__c, 
                                         Enrollment_End_Date__c, 
                                         Administrative_Contact__c, 
                                         Group_Name__c, 
                                         Legal_Name__c, 
                                         MCP_Number__c,                                         
                                         Tax_ID__c, 
                                         Additional_MCPs__c, 
                                         Estimated_Employees__c, 
                                         Effective_Date_of_Core_Products__c, 
                                         Effective_Date_of_AFA_Products__c, 
                                         Employee_Eligibility_Waiting_Period__c, 
                                         Residence_State_s__c,
                                         Marketed_Products__c,
                                         Platform__c,
                                         Enrollment_Setup_Notes__c,
                                         Division__c
                                    FROM Opportunity WHERE Id =: enrollmentForm.Enrollment_Opportunity__c];
        
        //Sibling Customer Setup Form
        if (enrollmentForm != null && enrollmentForm.Id != null){
            for (Customer_Setup_Form__c c : [SELECT Id, Name FROM Customer_Setup_Form__c WHERE Enrollment_Form__c =: enrollmentForm.Id])
                customerId = c.Id;
        }
        //Sibling Plan Summary Form
        if (enrollmentForm != null && enrollmentForm.Id != null){
            for (Section_125_Plan_Summary__c plan : [SELECT Id, Name FROM Section_125_Plan_Summary__c WHERE Enrollment_Form__c =: enrollmentForm.Id])
                planSummaryId = plan.Id;
        }
        //Sibling Section 125 Forms
        section125count = 0;
        if (enrollmentForm != null && enrollmentForm.Id != null){
            for (Section_125_Setup_Form__c s125 : [SELECT Id, Name FROM Section_125_Setup_Form__c WHERE Enrollment_Form__c =: enrollmentForm.Id])
                section125count++;
        }
        
        //parent account
        if (enrollmentOpp != null && enrollmentOpp.AccountId != null)
            this.acc = [SELECT Id, Name, Phone, Fax, Eligibile_Employee_Count__c, Payroll_Company__c, Texas_Life_Billing__c FROM Account WHERE Id =: enrollmentOpp.AccountId];
        
        //Account Manager
        if (p != null && p.Tx_Life_Prim_Acct_Mngr_ASAP__c != null){
            this.acctManager = [SELECT Id, Name FROM User WHERE Id =: p.Tx_Life_Prim_Acct_Mngr_ASAP__c];
            acctManagerName = acctManager.Name;
        }
        if (p != null && p.Tx_Life_Visions_SSR_Enroll_Team_Name__c != null){
            this.enrollTeam = [SELECT Id, Name FROM User WHERE Id =: p.Tx_Life_Visions_SSR_Enroll_Team_Name__c];
            enrollTeamName = enrollTeam.Name;
        }
        if (p != null && p.Tx_Life_Agent_Data_Prim_Acct_Mngr_ASAP__c != null){
            this.primAcctMgr = [SELECT Id, Name FROM User WHERE Id =: p.Tx_Life_Agent_Data_Prim_Acct_Mngr_ASAP__c];
            primAcctMgrName = primAcctMgr.Name;
        }
        if (enrollmentOpp != null && enrollmentOpp.Administrative_Contact__c != null){
            this.adminContact = [SELECT Id, Name, Phone, Email, Extension__c FROM Contact WHERE Id =: enrollmentOpp.Administrative_Contact__c];
        }
        if (enrollmentOpp != null && enrollmentOpp.Id != null){
            oppTeam = [SELECT Id, TeamMemberRole, UserId, User.Name, User.Email, User.Phone, OpportunityAccessLevel, User.Network_ID__c FROM OpportunityTeamMember
                        WHERE OpportunityId =: enrollmentOpp.Id];
        }  
             
        
        if(p != null)
        {
            List<Core_Benefit_Form__c> c = new List<Core_Benefit_Form__c>();
            c = [SELECT ID, 
                        Name, 
                        Carrier__c, 
                        Plan_Name__c, 
                        Product_Description__c,
                        Add_Core_Benefit__c,
                        Individual_Employer_Contribution__c, 
                        Individual_Children_Employer_Contribu__c, 
                        Individual_Children_Rate__c, 
                        Individual_Family_Rate__c, 
                        Individual_Family_Employer_Contributi__c, 
                        Individual_Spouse_Employer_Contributi__c, 
                        Individual_Spouse_Rate__c, 
                        Individual_Rate__c, 
                        OtherInformation__c ,
                        Rates__c
                 FROM Core_Benefit_Form__c
                 WHERE Platform_Setup_Form__c =: p.Id];
            if(c != null)
                this.coreBenefits = c;
        }
        
        this.MarketedProducts = getMarketedProducts();
        
        this.importProducts = [
            select
                id, name, plan_description__c, aor__c, new_or_existing__c,
                carrier_name__c, tax_treatment__c, Platform_Setup_Form__c
            from import_product__c
            where platform_setup_form__c =: this.p.id
        ];
        
        setDefaultValues();
        
        // jhicks 12/16
        checkAllRequiredFields();
        getHelpText(); 
    }
    
    public void setDefaultValues()
    {
        // Query for 1 Section 125 form, the first created
        List<Section_125_Setup_Form__c> sec125s = [SELECT Sec125EffDatescurplanyrwillbegin__c, Sec125EffDatescurplanyrwillend__c,
                                              FlexSpendAcctHlthFlexMin__c, FlexSpendAcctHlthFlexMax__c, FlexSpendAcctFSAEffectiveDate__c,
                                              FlexSpendAcctDepDaycareReimbMin__c, FlexSpendAcctDepDaycareReimbMax__c, FlexSpendAcctAdminFeeAdminFeeCost__c,
                                              FlexSpendAcctDebitCardWillEmpl__c, FlexSpendAcctDebitCardFee__c
                                             FROM Section_125_Setup_Form__c
                                             WHERE Enrollment_Form__c =: p.Enrollment_Form__c
                                              ORDER BY CreatedDate DESC LIMIT 1];
        
        // Default fields from the related platform setup form Section 125 tab
        for(Section_125_Setup_Form__c s : sec125s)
        {
            if(p.S125OtherSvcPlanStartDate__c == null)
                p.S125OtherSvcPlanStartDate__c = s.Sec125EffDatescurplanyrwillbegin__c;

            if(p.S125OtherSvcPlanEndDate__c == null)
                p.S125OtherSvcPlanEndDate__c = s.Sec125EffDatescurplanyrwillend__c;

            if(p.S125OtherSvcHealthFSAMin__c == null)
                p.S125OtherSvcHealthFSAMin__c = s.FlexSpendAcctHlthFlexMin__c;

            if(p.S125OtherSvcHealthFSAMax__c == null)
                p.S125OtherSvcHealthFSAMax__c = s.FlexSpendAcctHlthFlexMax__c;

            if(p.S125OtherSvcFlexEffDate__c == null)
                p.S125OtherSvcFlexEffDate__c = s.FlexSpendAcctFSAEffectiveDate__c;

            if(p.S125OtherSvcDDCMin__c == null)
                p.S125OtherSvcDDCMin__c = s.FlexSpendAcctDepDaycareReimbMin__c;

            if(p.S125OtherSvcDDCMax__c == null)
                p.S125OtherSvcDDCMax__c = s.FlexSpendAcctDepDaycareReimbMax__c;

            if(p.S125OtherSvcAdminFee__c == null)
                p.S125OtherSvcAdminFee__c = s.FlexSpendAcctAdminFeeAdminFeeCost__c;

            if(p.S125OtherSvcDebitCard__c == null)
                p.S125OtherSvcDebitCard__c = s.FlexSpendAcctDebitCardWillEmpl__c;

            if(p.S125OtherSvcDebitCardFee__c == null)
                p.S125OtherSvcDebitCardFee__c = s.FlexSpendAcctDebitCardFee__c;
        }
        
        if (String.isBlank(p.Tx_Life_Bill_Type__c) &&
            String.isNotBlank(acc.Texas_Life_Billing__c)) {

            p.Tx_Life_Bill_Type__c = acc.Texas_Life_Billing__c;
        }
        
        if (p.TXLifeFirstDedDate__c == null &&
            p.Enroll_Info_First_Payroll_Deduction_Date__c != null) {
            p.TXLifeFirstDedDate__c = p.Enroll_Info_First_Payroll_Deduction_Date__c;
        }
    }
    
    //Helper function for radio buttons on page
    public void updateField()
    {
        try
        {
            if (p != null && p.Id != null && fieldName != null)
            {
                //Section_125_Setup_Form__c form = [SELECT Id FROM Section_125_Setup_Form__c WHERE Id=: p.Id];
                p.put(fieldName, fieldValue);
                update p;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getMessage()));
            showErrorMessages = true;
        }
        
    }

    //Update field for decimal fields
    public void updateFieldDecimal()
    {
        if (p != null && p.Id != null && fieldName != null)
        {
            //Section_125_Setup_Form__c form = [SELECT Id FROM Section_125_Setup_Form__c WHERE Id=: p.Id];
            p.put(fieldName, Decimal.valueOf(fieldValue));
            update p;
        }
    }

    //update field for boolean fields
    public void updateFieldBoolean()
    {
        try
        {
            if (p != null && p.Id != null && fieldName != null)
            {
                //Section_125_Setup_Form__c form = [SELECT Id FROM Section_125_Setup_Form__c WHERE Id=: p.Id];
                if (fieldValue == '1')
                    p.put(fieldName, true);
                else
                    p.put(fieldName, false);
                
                update p;
            } 
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a radio field. ' + e.getMessage()));
            showErrorMessages = true;
        }
        
    }

    //update field for date fields
    public void updateFieldDate()
    {
        try
        {
            if (p != null && p.Id != null && fieldName != null)
            {
                if (fieldValue != null && fieldValue != ''){
                    List<String> value = fieldValue.split('/');
                    //Date newDate = Date.today();
                    Date newDate = Date.newInstance(Integer.valueOf(value[2]), Integer.valueOf(value[1]), Integer.valueOf(value[0]));
                    p.put(fieldName, String.valueOf(newDate));
                }
                else{
                    p.put(fieldName, null);
                }
                
                update p;
            } 
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a date field. ' + e.getMessage()));
            showErrorMessages = true;
        }
        
    }
    
    public void updateAccountField()
    {
        try
        {
            if (accountId != null && fieldName != null)
            {
                Account acct = [SELECT ID FROM Account WHERE Id =: accountId];
                acct.put(fieldName, fieldValue);
                update acct;
            } 
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating an account field. ' + e.getMessage()));
            showErrorMessages = true;
        }
        
    }
    
    //Submit Form Method
    //Set Form Status to 'Submitted'
    //Set Enrollment Form Owner to Home Office Queue
    //Generate Form PDF and attach onto parent account record
    public void submitForm()
    {
        try
        {           
            System.debug('### Submitting FORM');
            //Group g = [Select g.Name, g.Id, g.DeveloperName From Group g Where DeveloperName = 'Home_Office_New'];
            
            update importProducts;
            
            Platform_Setup__c p = [SELECT ID, Status__c, DVR_Info_WillThereBeDependent_Verif__c, Enroll_Info_Upload__c, EnrollInfoUploadDueDate__c, Payroll_Due_Date_Rush_Reason__c, OwnerId FROM Platform_Setup__c WHERE Id =: formId];
            p.Status__c = 'Submitted';
            update p;
            // jhicks 12/16
            status = p.Status__c.toUpperCase();
            statusMsg = p.Status__c;
            //enrollmentForm.OwnerId = g.Id;
            enrollmentForm.Date_Platform_Submitted__c = Date.today();
            update enrollmentForm;

            if(p.DVR_Info_WillThereBeDependent_Verif__c == 'Yes')
            {
                Id DVRType = Schema.SObjectType.Platform_Setup__c.getRecordTypeInfosByName().get('DVR').getRecordTypeId();
                List<Platform_Setup__c> checkDVRs = [SELECT Id FROM Platform_Setup__c WHERE Enrollment_Form__c =: enrollmentForm.Id AND RecordTypeId =: DVRType];
                if(checkDVRs.size() < 1)
                {
                    Platform_Setup__c dvr = new Platform_Setup__c();
                    dvr.RecordTypeId = DVRType;
                    dvr.Enrollment_Form__c = enrollmentForm.Id;
                    dvr.OwnerId = p.OwnerId;
                    dvr.Status__c = 'Submitted';
                    insert dvr;
                }
            }
            
            if(p.Enroll_Info_Upload__c == 'Yes')
            {
                Id RDFType = Schema.SObjectType.Platform_Setup__c.getRecordTypeInfosByName().get('Return Data File').getRecordTypeId();
                List<Platform_Setup__c> checkRDFs = [SELECT Id FROM Platform_Setup__c WHERE Enrollment_Form__c =: enrollmentForm.Id AND RecordTypeId =: RDFType];
                if(checkRDFs.size() < 1)
                {
                    Platform_Setup__c returnDataFile = new Platform_Setup__c();
                    returnDataFile.RecordTypeId = RDFType;
                    returnDataFile.Enrollment_Form__c = enrollmentForm.Id;
                    returnDataFile.OwnerId = p.OwnerId;
                    returnDataFile.Status__c = 'Submitted';
                    returnDataFile.EnrollInfoUploadDueDate__c = p.EnrollInfoUploadDueDate__c;
                    returnDataFile.Payroll_Due_Date_Rush_Reason__c = p.Payroll_Due_Date_Rush_Reason__c;
                    insert returnDataFile;
                }         
            }
            
            createSalesforceFile();
             
            formIsSubmitted = true;
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error submitting the form. ' + e.getMessage()));
            showErrorMessages = true;
        } 
    }
    
    public void createSalesforceFile()
    {
        List<String> ContentLinkIds = new List<String>();
        
        //ContentLinkIds.add(formId);
        ContentLinkIds.add(enrollmentForm.Id);
        ContentLinkIds.add(enrollmentOpp.Id);
        //ContentLinkIds.add(system.UserInfo.getUserId());
        
        PageReference pagePdf = Page.PlatformSetupFormPDF;
        System.debug('### pagepdf: ' + pagepdf);
        pagepdf.getParameters().put('id', formId);
        
        Blob pdfPageBlob;
        if (Test.isRunningTest())
            pdfPageBlob = Blob.valueof('test');
        else
            pdfPageBlob = pagePdf.getContentAsPDF();
        System.debug('### pdfPageBlob : ' + pdfPageBlob );
        
        // Insert our content version
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = pdfPageBlob;
        cv.title = 'PlatformSetupPDF';
        cv.PathOnClient = 'PlatformSetupPDF.pdf';
        cv.FirstPublishLocationId = formId;
        
        insert cv;
        
        // Once the document is inserted, now we have to query for the contentdocumentid as it is not automatically generated
        // and share it with the objects specified by creating new content document link records.
        String ContentDocumentId = '';
        cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];
        if(cv != null)
            ContentDocumentId = cv.ContentDocumentId;
        
        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        
        
        for(String LinkId : ContentLinkIds)
        {
            ContentDocumentLink documentLink = new ContentDocumentLink();
            documentLink.LinkedEntityId = linkId;
            documentLink.ContentDocumentId = ContentDocumentId;
            documentLink.ShareType = 'V';
            
            linksToInsert.add(documentLink);
        }
        
        if(linksToInsert.size() > 0)
            insert linksToInsert;
    }
    
    public List<String> getMarketedProducts(){
        List<String> products = new List<String>();
        List<String> unorderedProducts = new List<String>();
        List<Schema.PicklistEntry> ple = Opportunity.Marketed_Products__c.getDescribe().getPicklistValues();
        
        try
        {
            if(enrollmentOpp.Marketed_Products__c != null)
            {
                unorderedproducts = enrollmentOpp.Marketed_Products__c.split(';');
            }
            
            for(integer i = 0; i < ple.size(); i++)
            {
                for(integer e = 0; e < unorderedproducts.size(); e++)
                {
                    if(unorderedproducts[e] == ple[i].getValue())
                    {
                        products.add(unorderedproducts[e]); 
                    }
                }
            }
            return products;  
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occured submitting the form. ' + e.getMessage()));
            showErrorMessages = true;
        }
         
        return null;
    }
    
    public void LoadBenefits()
    {
        try
        {
            if(p != null)
                this.coreBenefits = [SELECT ID, 
                                            Name, 
                                            Carrier__c, 
                                            Plan_Name__c, 
                                            Product_Description__c,
                                            Add_Core_Benefit__c,
                                            Individual_Employer_Contribution__c, 
                                            Individual_Children_Employer_Contribu__c, 
                                            Individual_Children_Rate__c, 
                                            Individual_Family_Rate__c, 
                                            Individual_Family_Employer_Contributi__c, 
                                            Individual_Spouse_Employer_Contributi__c, 
                                            Individual_Spouse_Rate__c, 
                                            Individual_Rate__c, 
                                            OtherInformation__c ,
                                            Rates__c
                                       FROM Core_Benefit_Form__c
                                      WHERE Platform_Setup_Form__c =: p.Id
                                     ORDER BY CreatedDate];  
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error loading Benefits. ' + e.getMessage()));
            showErrorMessages = true;
        }   
        system.debug('**** all benefits: ' + coreBenefits);     
    }
    
    //Delete Related Core Benefit
    //ID is passed from the page
    public void deleteBenefit(){
        System.debug('### BenefitID: ' + BenefitIDToDelete);
        try
        {
            if (BenefitIDToDelete != null)
            {
                Core_Benefit_Form__c c = [SELECT ID FROM Core_Benefit_Form__c WHERE Id =: BenefitIDToDelete];
                delete c;
            } 
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error deleting the benefit. ' + e.getMessage()));
            showErrorMessages = true;
        }
        /* jhicks 12/16 */
        loadBenefits();
    }  
    
    //insert Qualified Benefit record
    //Id and Type are passed from the page
    public void AddBenefit()
    {
        System.debug('### formToAdd: ' + formToAdd);
        try
        {
            if (formToAdd != null)
            {
                Core_Benefit_Form__c c = new Core_Benefit_Form__c();
                c.Platform_Setup_Form__c = formToAdd;
                c.Add_Core_Benefit__c = BenefitType;
                insert c;
            }  
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error adding the Benefit. ' + e.getMessage()));
            showErrorMessages = true;
        }
        
    }
    
    
    //update field on a related Qualified Benefit record
    //id fieldName and fieldValue are passed from the page
    public void updateBenefit()
    {
        try
        {
            System.debug('### BenefitID: ' + BenefitID);
            if (BenefitID != null && fieldName != null)
            {
                Core_Benefit_Form__c c = [SELECT Id FROM Core_Benefit_Form__c WHERE Id=: BenefitID];
                c.put(fieldName, fieldValue);
                update c;
            }   
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating the Benefit. ' + e.getMessage()));
            showErrorMessages = true;
        }
    }
    
   

    /* new code for early 2017 release */

    public void checkRequiredFieldsAndDisplay() {
        texasLifeCheckRequiredFields(true);
        dvrInfoCheckRequiredFields(true);
        s125CheckRequiredFields(true);
        coreDetailsRequiredFields(true);
    }
    
    public void checkAllRequiredFields() {
        texasLifeCheckRequiredFields(false);
        dvrInfoCheckRequiredFields(false);
        s125CheckRequiredFields(false);
        coreDetailsRequiredFields(false);
    }
  
    public void save() {
        system.debug('::: saving Platform Setup');
        try
        {     
            update p;
            checkAllRequiredFields();
        }
        catch (system.dmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,  e.getDmlMessage(0)));
            showErrorMessages = true;
        }  
       
        system.debug('::: eOppty after save: ' + p);
    }
      
    public void AddBenefitNew() {
        System.debug('### formToAdd: ' + formToAdd);
        try
        {
            Core_Benefit_Form__c c = new Core_Benefit_Form__c(Platform_Setup_Form__c = p.Id);
            insert c;
            system.debug('**** benefit added: ' + c);
            /* jhicks 12/16 */
            loadBenefits();
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error adding the Benefit. ' + e.getMessage()));
            showErrorMessages = true;
        }
    }
    
    public void texasLifeCheckRequiredFields(boolean showField) {

        texasLifeTabComplete = true;

        if (p.Tx_Life_Will_Tx_Life_be_set_up__c == null) {
            if (showField) {
                p.Tx_Life_Will_Tx_Life_be_set_up__c.addError('Required Field');
            }
            texasLifeTabComplete = false;
        }

        if (p.Tx_Life_Will_Tx_Life_be_set_up__c == 'Yes') {

            if (p.Tx_Life_Is_new_case_of_a_re_enrol__c == null) {
                if (showField) {
                    p.Tx_Life_Is_new_case_of_a_re_enrol__c.addError('Required Field');
                }
                texasLifeTabComplete = false;
            }

            if (p.Tx_Life_Bill_Type__c == null) {
                if (showField) {
                    p.Tx_Life_Bill_Type__c.addError('Required Field');
                }
                texasLifeTabComplete = false;
            }

            if (p.TXLifeFirstDedDate__c == null) {
                if (showField) {
                    p.TXLifeFirstDedDate__c.addError('Required Field');
                }
                texasLifeTabComplete = false;
            }

        }
        system.debug('::: texasLifeTabComplete: ' + texasLifeTabComplete);
    }
    
    public void dvrInfoCheckRequiredFields(boolean showField) {
       
        dvrInfoTabComplete = true;
        
        if (p.DVR_Info_WillThereBeDependent_Verif__c == null) {
            if (showField) {
                p.DVR_Info_WillThereBeDependent_Verif__c.addError('Required Field');
            }
            dvrInfoTabComplete = false;
        }
                   
        if (p.DVR_Info_WillThereBeDependent_Verif__c == 'Yes') {
                          
            if (p.DVR_Info_dependent_SSNs_required__c == null) {
                if (showField) {
                    p.DVR_Info_dependent_SSNs_required__c.addError('Required Field');
                }
                dvrInfoTabComplete = false;
            }
                  
            if (p.DVR_Info_Include__c == null) {
                if (showField) {
                    p.DVR_Info_Include__c.addError('Required Field');
                }
                dvrInfoTabComplete = false;
            }

        }      
        system.debug('::: dvrInfoTabComplete: ' + dvrInfoTabComplete);
    }

    public void s125CheckRequiredFields(boolean showField) {
       
        s125servicesTabComplete = true;
                   
        if (p.S125OtherSvcHaveAFASection125__c == 'Yes') {
                          
            if (p.S125OtherSvcPlanYearDesc__c == null) {
                if (showField) {
                    p.S125OtherSvcPlanYearDesc__c.addError('Required Field');
                }
                s125servicesTabComplete = false;
            }
                  
            if (p.S125OtherSvcPlanStartDate__c == null) {
                if (showField) {
                    p.S125OtherSvcPlanStartDate__c.addError('Required Field');
                }
                s125servicesTabComplete = false;
            }
                  
            if (p.S125OtherSvcPlanEndDate__c == null) {
                if (showField) {
                    p.S125OtherSvcPlanEndDate__c.addError('Required Field');
                }
                s125servicesTabComplete = false;
            }
                
            if (p.S125OtherSvcIsThereFSA__c == null) {
                if (showField) {
                    p.S125OtherSvcIsThereFSA__c.addError('Required Field');
                }
                s125servicesTabComplete = false;
            }
                
            if (p.S125OtherSvcIsThereFSA__c == 'Yes') {  
                if (p.S125OtherSvcHealthFSAMin__c == null) {
                    if (showField) {
                        p.S125OtherSvcHealthFSAMin__c.addError('Required Field');
                    }
                    s125servicesTabComplete = false;
                }
                     
                if (p.S125OtherSvcHealthFSAMax__c == null) {
                    if (showField) {
                        p.S125OtherSvcHealthFSAMax__c.addError('Required Field');
                    }
                    s125servicesTabComplete = false;
                }
                     
                if (p.S125OtherSvcAdminFee__c == null) {
                    if (showField) {
                        p.S125OtherSvcAdminFee__c.addError('Required Field');
                    }
                    s125servicesTabComplete = false;
                }
                
                if (String.isNotBlank(p.S125OtherSvcAdminFee__c) &&
                    (p.S125OtherSvcAdminFee__c == 'Employer' || p.S125OtherSvcAdminFee__c == 'Employee') &&
                    p.S125OtherSvcAmount__c == null) {
                    if (showField) {
                        p.S125OtherSvcAmount__c.addError(REQUIRED_FIELD_MESSAGE);
                    }
                    s125servicesTabComplete = false;
                }

                if (p.S125OtherSvcDebitCard__c == null) {
                    if (showField) {
                        p.S125OtherSvcDebitCard__c.addError('Required Field');
                    }
                    s125servicesTabComplete = false;
                }
                     
                if (p.S125OtherSvcFlexEffDate__c == null) {
                    if (showField) {
                        p.S125OtherSvcFlexEffDate__c.addError('Required Field');
                    }
                    s125servicesTabComplete = false;
                }
            } 
        }  
        else {   // no s125
            if (p.S125OtherSvcHaveSection125WithAnotherCo__c == null) {
                if (showField) {
                    p.S125OtherSvcHaveSection125WithAnotherCo__c.addError('Required Field');
                }
                s125servicesTabComplete = false;
            }
        }    
        system.debug('::: s125servicesTabComplete: ' + s125servicesTabComplete);
    }
    
    public void coreDetailsRequiredFields(Boolean showErrorMessage) {
        coreDetailsTabComplete = true;
        Map<String, Schema.FieldSetMember> requiredFields = getCoreDetailsRequiredFields();
        
        if (requiredFields.containsKey(Platform_Setup__c.What_Core_Benefits_will_show_in_the_case__c.getDescribe().getName()) &&
            p.What_Core_Benefits_will_show_in_the_case__c == null) {
            
            if (showErrorMessage) {
                p.What_Core_Benefits_will_show_in_the_case__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            coreDetailsTabComplete = false;
        }
        
        if (String.isNotBlank(p.What_Core_Benefits_will_show_in_the_case__c) &&
            p.What_Core_Benefits_will_show_in_the_case__c == CORE_BENEFITS_GENERIC_FOLDERS &&
            requiredFields.containsKey(Platform_Setup__c.List_Generic_Folder_Names__c.getDescribe().getName()) &&
            String.isBlank(p.List_Generic_Folder_Names__c)) {
            
            if (showErrorMessage) {
                p.List_Generic_Folder_Names__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            coreDetailsTabComplete = false;
        }
    }
    
    public void getHelpText() {
        // map of all fields in the object
        Map<String, Schema.SObjectField> objectFields =  schema.SObjectType.Platform_Setup__c.fields.getMap();
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
    
    public void updateEnrollmentForm()
    {
        // If request edit is requested and the form is not further than the 'Submitted' state
        // automatically re-open the form.  If the form has entered into a further state,
        // then a true request edit needs to be sent back to Home Office
        if (fieldName == 'Request_Edit__c')
        {
            if(fieldValue == 'true')
            {
                system.debug('Platform status: ' + p.Status__c);
                if(p.Status__c != 'Submitted')
                    p.Request_Edit__c = true;
                else
                    p.Status__c = 'In Progress';
            }
            else
                p.Request_Edit__c = false;
            
            update p;
            
            statusMsg = p.Status__c;
            if(p.Request_Edit__c)
                statusMsg += ' - Request To Edit Sent';
            
            if(statusMsg == 'In Progress')
                formIsSubmitted = false;
            else
                formIsSubmitted = true;
        }
    }
    
    private void loadEnrollmentForm() {
        this.enrollmentForm = [SELECT Id, Name, Enrollment_Opportunity__c, Status__c FROM Enrollment_Form__c WHERE Id =: p.Enrollment_Form__c];
        this.EF = this.enrollmentForm;
    }
    
    private void addExtraFieldsToStandardController(ApexPages.StandardController stdController) {
        Set<String> fieldsToAdd = new Set<String>();
        
        fieldsToAdd.add('Enrollment_Form__c');
        fieldsToAdd.add('Tx_Life_Agent_Data_Prim_Acct_Mngr_ASAP__c');
        fieldsToAdd.add('Tx_Life_Prim_Acct_Mngr_ASAP__c');
        fieldsToAdd.add('Tx_Life_Visions_SSR_Enroll_Team_Name__c');
        fieldsToAdd.add('Tx_Life_Will_Tx_Life_be_set_up__c');
        fieldsToAdd.add('Status__c');
        fieldsToAdd.add('Request_Edit__c');
        fieldsToAdd.add('Tx_Life_Bill_Type__c');
        fieldsToAdd.add('Enroll_Info_First_Payroll_Deduction_Date__c');
        
        List<Schema.FieldSet> fieldSetsToUse = new List<Schema.FieldSet>{
            SObjectType.Platform_Setup__c.FieldSets.Core_Section
        };
        
        fieldsToAdd.addAll(getFieldSetFields(fieldSetsToUse));

        if (!Test.isRunningTest()){
            stdController.addFields(new List<String>(fieldsToAdd));
        }
    }
    
    private Map<String, Schema.FieldSetMember> getCoreDetailsRequiredFields() {
        // Luke Freeland 5/24/2017
        // Allow the list of required fields to be overridable via tests.
        if (TestCoreDetailsRequiredFields != null &&
            !TestCoreDetailsRequiredFields.isEmpty()) {
            return TestCoreDetailsRequiredFields;
        }
        
        List<Schema.FieldSet> requiredFieldSetsToCheck = new List<Schema.FieldSet>{
            SObjectType.Platform_Setup__c.FieldSets.Core_Section
        };
        
        return getRequiredFieldSetMembers(requiredFieldSetsToCheck);
    }
}