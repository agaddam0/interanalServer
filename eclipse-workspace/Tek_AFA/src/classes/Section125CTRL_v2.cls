/*********************************************************************************************
// Version:             1.0
// Author:              American Fidelity
// Date Created:        1/17/2017
// Description:         Section125CTRL Apex class 
// 
// Revision History
// DATE               AUTHOR                    REQUIREMENT#          DETAILS
//
// *********************************************************************************************
// ********************************************************************************************/

public with sharing class Section125CTRL_v2 extends PreenrollmentControllerBase  {
    public static final String NO_BILL_MODES_VAL_MSG = 'At least one bill mode is needed.';

    //public variables available to pull/push into form
    public List<Section_125_Setup_Form__c> section125s          {get;set;}
    public Enrollment_Form__c enrollmentForm                    {get;set;}
    public String formId                                        {get;set;}
    public String formType                                      {get;set;}
    public Id formToUpdate                                      {get;set;}
    public Id formToAdd                                         {get;set;}
    public Integer count                                        {get;set;}
    public Id idToDelete                                        {get;set;}
    public Id REIDToDelete                                      {get;set;}
    public Id BenefitIDToDelete                                 {get;set;}
    public Id BenefitID                                         {get;set;}
    public String retUrl                                        {get;set;}
    public boolean s125TabComplete								{get;set;}
    public boolean qualBenTabComplete							{get;set;}
    public boolean FSATabComplete								{get;set;}
    public boolean HSATabComplete								{get;set;}
    public boolean AllTabsComplete								{get;set;}
    public boolean requestEdit									{get;set;}
    public List<Section125Wrapper> wrapS125s					{get;set;}
    public string tabParam										{get;set;}
    public string topTabParam									{get;set;}
    public boolean showFSAtab									{get;set;}
    public boolean showHSAtab									{get;set;}
    public boolean showS125tab									{get;set;}
    public Map<string,string>  hMap								{get; set;}

    public Id BillModeIdToRemove { get; set; }
    public Id BillModeIdToUpdate { get; set; }
    public String billModesErrorMessage { get; set; }
    
    @testVisible
    private set<String> TestBillModeRequiredFields { get; set; }
    
    
    //Construtor calls init method which gathers data from form record and related records
    public Section125CTRL_v2() {
        
        init();
        
    }
    
    public void init()
    {
        if (ApexPages.currentPage().getParameters().containsKey('id')){
            formId = ApexPages.currentPage().getParameters().get('id');
        }
        
        //Parent Enrollment Form
        if (formId != null)
        {
            enrollmentForm = [SELECT Id, Name, OwnerId, Enrollment_Opportunity__c, Enrollment_Opportunity__r.AccountId, 
                              Enrollment_Opportunity__r.Division__c, Enrollment_Opportunity__r.OwnerID, Status__c,
                              Enrollment_Opportunity__r.What_products_are_you__c, Enrollment_Opportunity__r.Confirm_New_or_Existing_Group__c
                              FROM Enrollment_Form__c WHERE Id =: formId];

            this.EF = enrollmentForm;
        }
        
        /*********  New Stuff *********/
        
        wrapS125s = new List<Section125Wrapper>();
        setTabColors();
        //getSetupData();
        setStatusMsg();
        getHelpText();
        
        // Get the return url
        if (ApexPages.currentPage().getParameters().containsKey('retUrl'))
            retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        showErrorMessages = true;
        
    }
    
    public void getSection125Forms()
    {
        // Gets the set of Section 125 Setup Forms
        Set<String> s125Fields = Util.getObjectCreatableFields('Section_125_Setup_Form__c');
        s125Fields.add('Primary__c');
        
        String soql = 'SELECT ' + String.join(new List<String>(s125Fields), ',');

        // Qualified Benefits
        soql += ', (SELECT ID, Name, Carrier__c, Plan_Name__c, Product_Description__c, Eligibility__c, Add_Benefit__c' +
            ' FROM Qualitfied_Benefits_Form__r ORDER BY CreatedDate)';


        // LF 7/2017: New Related Employers uses the Common Ownership Forms instead.
        soql += ', (SELECT Id, Name, Legal_Name__c, Address_Line_1__c, Address_Line_2__c, City__c, DBA_Name__c, New_Or_Existing__c, MCP_Number__c, Related_Employer_under_S125_Plan__c, ' + 
            ' State__c, State_Picklist__c, ZipCode__c, Contact_Name__c, Contact_Email__c, Contact_Phone_Extension__c, Contact_Phone_Number__c, Employer_Tax_ID_Number__c ' +
            ' FROM Common_Ownership_Forms__r ORDER BY CreatedDate)';

        // Bill Modes
        Set<String> billModeFields = Util.getFieldSetFields(SObjectType.Bill_Mode__c.FieldSets.Flex_Billing);

        soql += ', (SELECT Id, ' + String.join(new List<String>(billModeFields), ',') +
                ' FROM Bill_Modes__r)';

        // FROM Clause
        soql += ' FROM Section_125_Setup_Form__c ';
        // WHERE Clause
        soql += ' WHERE Enrollment_Form__c = \'' + enrollmentForm.Id + '\' ORDER BY CreatedDate';
        
        system.debug('soql: ' + soql);
        section125s = (List<Section_125_Setup_Form__c>)Database.query(soql);
        
        // Get Parent Account
        if(acc == null)
        	this.acc = [SELECT Id, Name, BillingState FROM Account WHERE Id =: enrollmentForm.Enrollment_Opportunity__r.AccountID];
        
        // Get Form Type to show/hide fields based on Division
        formType = enrollmentForm.Enrollment_Opportunity__r.Division__c;
        
        count = section125s.size();
        
        for(Section_125_Setup_Form__c s : section125s)
        {
            wrapS125s.add(new Section125Wrapper(s));
        }
    }
    
    public void setDefaultValues()
    {
        // This method sets the default values, but due to not being able to do a DML statement on load
        // the value actually gets saved when they edit anohter field that triggers the save of the 
        // section 125 forms.
         
        showFSAtab = false;
        showHSAtab = false;
        showS125tab = false;
        
        List<Marketed_Product__c> MPS = [SELECT Id, Plan_Status__c, Products__r.Name 
                                         FROM Marketed_Product__c 
                                         WHERE Enrollment__c =: formId ];

        for(Section_125_Setup_Form__c s : section125s)
        {
            if(s.Sec125EffDatesThisplanisintended__c == null)
                s.Sec125EffDatesThisplanisintended__c = acc.BillingState;
            
            s.HlthSvgsAcctDoesEmployerpart__c = 'No';
            s.FlexSpendAcctGroupAddingHealthFSA__c = 'No';
            s.FlexSpendAcctGroupAddingDDCFSA__c = 'No'; 
            
            for(Marketed_Product__c mp : MPS)
            {
                if(mp.Products__r.Name == 'Section 125' && mp.Plan_Status__c == 'New')
                {
                    showS125tab = true;
                }  
                
                if(mp.Products__r.Name == 'HSA' && mp.Plan_Status__c == 'New')
                {
                    s.HlthSvgsAcctDoesEmployerpart__c = 'Yes';
                    showHSAtab = true;
                }                    
                
                if(mp.Products__r.Name == 'Health FSA' && mp.Plan_Status__c == 'New')
                {
                    s.FlexSpendAcctGroupAddingHealthFSA__c = 'Yes';
                    showFSAtab = true;
                }
                
                if(mp.Products__r.Name == 'Limited Purpose FSA' && mp.Plan_Status__c == 'New')
                {
                    s.FlexSpendAcctDebitCardlimPurpose__c = 'Yes';
                    showFSAtab = true;
                }
                
                if(mp.Products__r.Name == 'Dependent Daycare FSA' && mp.Plan_Status__c == 'New')
                {
                    s.FlexSpendAcctGroupAddingDDCFSA__c = 'Yes';
                    showFSAtab = true;
                }                 
            }
        }
    }
    
    public void setTabColors() 
    { 
        // Clear anything in the wrapper as we will re-populate it
        wrapS125s.clear();
        
        // get the updated data
        getSection125Forms();
        setDefaultValues();
        
        // The boolean value sets whether or not you display the field error.  Ideally on submit
        if(showS125tab)
        {
            s125CheckRequiredFields(false);
            qualifiedBenefitsCheckRequiredFields(false);
        }
        if(showFSAtab)
        	FSAcheckRequiredFields(false);
        if(showHSAtab)
            HSAcheckRequiredFields(false);        
        
        system.debug(':::setTabColors() called');
        //system.debug(':::summaryTabComplete ' + summaryTabComplete);
    }
    
    private void setStatusMsg() 
    { 
        boolean complete = false;
        boolean waitingOnInfo = false;
        boolean processing = false;
        boolean inProgress = false;
        boolean submitted = false;
        requestEdit = false;
        
        for(Section_125_Setup_Form__c s : section125s)
        {
            if(s.Status__c == 'Completed')
                complete = true;
            else if(s.Status__c == 'Waiting on Information')
                waitingOnInfo = true;
            else if(s.Status__c == 'H.O. Processing')
                processing = true;
            else if(s.Status__c == 'Submitted')
                submitted = true;
            else
                inProgress = true;
            
            if(s.Request_Edit__c)
                requestEdit = true;
        }
        
        if(inProgress)
        {
            statusMsg = 'In Progress';
            formIsSubmitted = false;
        }
        else if(processing)
        {
            statusMsg = 'H.O. Processing';
            formIsSubmitted = true;
        }
        else if(waitingOnInfo)
        {
            statusMsg = 'Waiting on Information';
            formIsSubmitted = true;
        }
        else if(submitted)
        {
            statusMsg = 'Submitted';
            formIsSubmitted = true;
        }
        else if(complete)
        {
            statusMsg = 'Completed';
            formIsSubmitted = true;
        }
        
        if (requestEdit)
            statusMsg += ' - Request To Edit Sent';
    }
    
    public void checkRequiredFieldsAndDisplay() 
    {
        // The boolean value sets whether or not you display the field error.  Ideally on submit
        
        setDefaultValues();
        
        if(showS125tab)
        {
            s125CheckRequiredFields(true);
            qualifiedBenefitsCheckRequiredFields(true);
        }
        if(showFSAtab)
            FSAcheckRequiredFields(true);
        if(showHSAtab)
            HSAcheckRequiredFields(true);
        
        AllTabsComplete = true;
        
        if(showS125tab && (!s125TabComplete || !qualBenTabComplete))
            AllTabsComplete = false;
        if(showFSAtab && !FSATabComplete)
            AllTabsComplete = false;
        if(showHSAtab && !HSATabComplete)
            AllTabsComplete = false;
        
        system.debug('::: ran checkRequiredFieldsAndDisplay on server ');
    }
    
    public void s125CheckRequiredFields(boolean showField)
    { 
        s125TabComplete = true;
        
        for(Section125Wrapper sw : wrapS125s)
        {
            sw.Section125TabComplete = true;
            
            if(sw.Section125.Sec125BusinessEntityType__c == null)
            {
                if(showField)
                    sw.Section125.Sec125BusinessEntityType__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec_125_S125_Plan_Document_Needed_By__c == null)
            {
                if(showField)
                    sw.Section125.Sec_125_S125_Plan_Document_Needed_By__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125PrincipalBusinessActivity__c == null)
            {
                if(showField)
                    sw.Section125.Sec125PrincipalBusinessActivity__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125EffDatesThisplanisintended__c == null)
            {
                if(showField)
                    sw.Section125.Sec125EffDatesThisplanisintended__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125PlanNumber__c == null)
            {
                if(showField)
                    sw.Section125.Sec125PlanNumber__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125EffDate__c == null)
            {
                if(showField)
                    sw.Section125.Sec125EffDate__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125EffDatesAFAProviderEffDate__c == null)
            {
                if(showField)
                    sw.Section125.Sec125EffDatesAFAProviderEffDate__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125EffDatescurplanyrwillbegin__c == null)
            {
                if(showField)
                    sw.Section125.Sec125EffDatescurplanyrwillbegin__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125EffDatescurplanyrwillend__c == null)
            {
                if(showField)
                    sw.Section125.Sec125EffDatescurplanyrwillend__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125PlanEligPlanEligibility__c == null)
            {
                if(showField)
                    sw.Section125.Sec125PlanEligPlanEligibility__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125PlanEligFlexEligibility__c == 'First day of the month following days')
            {
                if(sw.Section125.Sec125PlanEligPlanEligDays__c == null)
                {
                    if(showField)
                        sw.Section125.Sec125PlanEligPlanEligDays__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.Section125TabComplete = false;
                    sw.AllTabsComplete = false;
                    s125TabComplete = false;
                }
            }
            
            if(sw.Section125.Sec125PlanEligFlexEligibility__c == 'First day of the month following months')
            {
                if(sw.Section125.Sec125PlanEligPlanEligMonths__c == null)
                {
                    if(showField)
                        sw.Section125.Sec125PlanEligPlanEligMonths__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.Section125TabComplete = false;
                    s125TabComplete = false;
                    sw.AllTabsComplete = false;
                }
            }
            
            if(sw.Section125.Sec125MinagereqforemployeeElig__c == null)
            {
                if(showField)
                    sw.Section125.Sec125MinagereqforemployeeElig__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125NonelecContNonelecCont__c == null)
            {
                if(showField)
                    sw.Section125.Sec125NonelecContNonelecCont__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125ElectiveContributions__c == null)
            {
                if(showField)
                    sw.Section125.Sec125ElectiveContributions__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125NonelecContNonelecCont__c == 'Yes')
            {
                if(sw.Section125.Sec125Non_elecContributionInformation__c == null)
                {
                    if(showField)
                        sw.Section125.Sec125Non_elecContributionInformation__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.Section125TabComplete = false;
                    sw.AllTabsComplete = false;
                    s125TabComplete = false;
                }
            }
            
            if(sw.Section125.S125OptOut__c == null)
            {
                if(showField)
                    sw.Section125.S125OptOut__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125Sec79LifeInsIfGrpter__c == null)
            {
                if(showField)
                    sw.Section125.Sec125Sec79LifeInsIfGrpter__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125Sec79LifeInsAccthave__c == null)
            {
                if(showField)
                    sw.Section125.Sec125Sec79LifeInsAccthave__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            if(sw.Section125.Sec125NbrofhrsEligforSec125__c == null)
            {
                if(showField)
                    sw.Section125.Sec125NbrofhrsEligforSec125__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.Section125TabComplete = false;
                sw.AllTabsComplete = false;
                s125TabComplete = false;
            }
            
            /*Luke Freeland 8/8/2017: Steph requested that the related employers between the Section 125 and Customer Setup form have the same required fields
              and behave the same. If any changes need to be made below, it's likely it has to be done in the Customer Setup form too. Check with Steph
              or the project manager to confirm.
            */
            for (Common_Ownership_Form__c co : sw.Section125.Common_Ownership_Forms__r) {

                if (co.New_Or_Existing__c == null) {
                    if (showField) {
                        co.New_Or_Existing__c.addError(REQUIRED_FIELD_MESSAGE);
                    }
                    sw.Section125TabComplete = false;
                    sw.AllTabsComplete = false;
                    s125TabComplete = false;
                }
                if (co.New_Or_Existing__c == 'New') {
                    if (co.Legal_Name__c == null) {
                        if (showField) {
                            co.Legal_Name__c.addError(REQUIRED_FIELD_MESSAGE);
                        }
                        sw.Section125TabComplete = false;
                        sw.AllTabsComplete = false;
                        s125TabComplete = false;
                    }
                    if (co.Address_Line_1__c == null) {
                        if (showField) {
                            co.Address_Line_1__c.addError(REQUIRED_FIELD_MESSAGE);
                        }
                        sw.Section125TabComplete = false;
                        sw.AllTabsComplete = false;
                        s125TabComplete = false;
                    }   
                     if (co.City__c == null) {
                        if (showField) {
                            co.City__c.addError(REQUIRED_FIELD_MESSAGE);
                        }
                        sw.Section125TabComplete = false;
                        sw.AllTabsComplete = false;
                        s125TabComplete = false;
                    }
                    if (co.State_Picklist__c == null) {
                        if (showField) {
                            co.State_Picklist__c.addError(REQUIRED_FIELD_MESSAGE);
                        }
                        sw.Section125TabComplete = false;
                        sw.AllTabsComplete = false;
                        s125TabComplete = false;
                    }
                    if (co.ZipCode__c == null) {
                        if (showField) {
                            co.ZipCode__c.addError(REQUIRED_FIELD_MESSAGE);
                        }
                        sw.Section125TabComplete = false;
                        sw.AllTabsComplete = false;
                        s125TabComplete = false;
                    }  
                }
                else if (co.New_Or_Existing__c == 'Existing') { 
                    if (co.MCP_Number__c == null) {
                        if (showField) {
                            co.MCP_Number__c.addError(REQUIRED_FIELD_MESSAGE);
                        }
                        sw.Section125TabComplete = false;
                        sw.AllTabsComplete = false;
                        s125TabComplete = false;
                    }
                }
            }
            
        }
    }
    
    public void qualifiedBenefitsCheckRequiredFields(boolean showField)
    {  
        qualBenTabComplete = true;
        
        for(Section125Wrapper sw : wrapS125s)
        {
            sw.QualifiedBenefitsTabComplete = true;
            
            if(sw.Section125.QualBenAnyQualBenOffered__c == null)
            {
                if(showField)
                    sw.Section125.QualBenAnyQualBenOffered__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.QualifiedBenefitsTabComplete = false;
                sw.AllTabsComplete = false;
                qualBenTabComplete = false;
            }
            
            if(sw.Section125.QualBenAnyQualBenOffered__c == 'Yes')
            {
                if(sw.Section125.Qualitfied_Benefits_Form__r.size() < 1)
                {
                    sw.QualifiedBenefitsTabComplete = false;
                    sw.AllTabsComplete = false;
                    qualBenTabComplete = false;
                }
                else {
                    for (Qualified_Benefit_Form__c qbf : sw.Section125.Qualitfied_Benefits_Form__r) {
                        if (qbf.Add_Benefit__c == null) {
		                    if(showField) {
		                        qbf.Add_Benefit__c.addError(REQUIRED_FIELD_MESSAGE);
		                    }

                            sw.QualifiedBenefitsTabComplete = false;
	                        sw.AllTabsComplete = false;
	                        qualBenTabComplete = false;
	                    }
		                    
	                    if (qbf.Carrier__c == null) {
	                        if(showField) {
                                qbf.Carrier__c.addError(REQUIRED_FIELD_MESSAGE);
                            }

                            sw.QualifiedBenefitsTabComplete = false;
                            sw.AllTabsComplete = false;
                            qualBenTabComplete = false;
	                    }
	                }
                }
            }
        }
    }
    
    public void FSAcheckRequiredFields(boolean showField)
    {
        FSATabComplete = true;
        billModesErrorMessage = '';
        
        for(Section125Wrapper sw : wrapS125s)
        {
            sw.FlexibleSpendingTabComplete = true;
            
            // Health FSA Tab //
            if(sw.Section125.FlexSpendAcctGroupAddingHealthFSA__c == null)
            {
                if(showField)
                    sw.Section125.FlexSpendAcctGroupAddingHealthFSA__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            
            if(sw.Section125.FlexSpendAcctGroupAddingHealthFSA__c == 'Yes')
            {
                if(sw.Section125.FlexSpendAcctHlthFlexMin__c == null)
                {
                    if(showField)
                        sw.Section125.FlexSpendAcctHlthFlexMin__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
                
                if(sw.Section125.FlexSpendAcctHlthFlexMax__c == null)
                {
                    if(showField)
                        sw.Section125.FlexSpendAcctHlthFlexMax__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }

                if(sw.Section125.FlexSpendAcctHlthFlexWho__c == null)
                {
                    if(showField)
                        sw.Section125.FlexSpendAcctHlthFlexWho__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
                
                if(sw.Section125.FlexSpendAcctDebitCardWillEmpl__c == null)
                {
                    if(showField)
                        sw.Section125.FlexSpendAcctDebitCardWillEmpl__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
                
                if(sw.Section125.FlexSpendAcctDebitCardWillEmpl__c == 'Yes')
                {
                    if(sw.Section125.FlexSpendAcctDebitCardFee__c == null)
                    {
                        if(showField)
                            sw.Section125.FlexSpendAcctDebitCardFee__c.addError(REQUIRED_FIELD_MESSAGE);
                        sw.FlexibleSpendingTabComplete = false;
                        sw.AllTabsComplete = false;
                        FSATabComplete = false;
                    }
                }
            }            
            
            ///// Dependent Daycare /////
            
            if(sw.Section125.FlexSpendAcctGroupAddingDDCFSA__c == null)
            {
                if(showField)
                    sw.Section125.FlexSpendAcctGroupAddingDDCFSA__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            
            if(sw.Section125.FlexSpendAcctGroupAddingDDCFSA__c == 'Yes')
            {
                if(sw.Section125.FlexSpendAcctDepDaycareReimbMin__c == null)
                {
                    if(showField)
                        sw.Section125.FlexSpendAcctDepDaycareReimbMin__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
                
                if(sw.Section125.FlexSpendAcctDepDaycareReimbMax__c == null)
                {
                    if(showField)
                        sw.Section125.FlexSpendAcctDepDaycareReimbMax__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
                
                if(sw.Section125.FlexSpendAcctDepDaycareReimbWho__c == null)
                {
                    if(showField)
                        sw.Section125.FlexSpendAcctDepDaycareReimbWho__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
            }
            
            ///// FSA Details /////
            
            if(sw.Section125.FlexSpendAcctFSAEffectiveDate__c == null)
            {
                if(showField)
                    sw.Section125.FlexSpendAcctFSAEffectiveDate__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            
            if(sw.Section125.FlexSpendAcctGRACEPERIstheEmpl__c == null)
            {
                if(showField)
                    sw.Section125.FlexSpendAcctGRACEPERIstheEmpl__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            
            if(sw.Section125.FlexSpendAcctAdminFeeAdminFeeWho__c == null)
            {
                if(showField)
                    sw.Section125.FlexSpendAcctAdminFeeAdminFeeWho__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            
            if(sw.Section125.FlexSpendAcctAdminFeeAdminFeeCost__c == null)
            {
                if(showField)
                    sw.Section125.FlexSpendAcctAdminFeeAdminFeeCost__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            
            if(sw.Section125.FlexSpendAcctUniformCoverageRisk__c == null)
            {
                if(showField)
                    sw.Section125.FlexSpendAcctUniformCoverageRisk__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            
            if(sw.Section125.FlexSpendAcctHEARTACTIstheEmpl__c == null)
            {
                if(showField)
                    sw.Section125.FlexSpendAcctHEARTACTIstheEmpl__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            
            if (sw.Section125.Is_there_Employer_Paid_Flex__c == null) {
                if(showField)
                    sw.Section125.Is_there_Employer_Paid_Flex__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
                
            if (sw.Section125.Is_there_Employer_Paid_Flex__c == 'Yes') {
                if(sw.Section125.Does_the_same_amount_apply_to_employees__c == null) {
                    if(showField)
                        sw.Section125.Does_the_same_amount_apply_to_employees__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }

                if(sw.Section125.FlexSpendAcctHlthFlexSpendAcctEmp__c == null) {
                    if(showField)
                        sw.Section125.FlexSpendAcctHlthFlexSpendAcctEmp__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
                
                if(sw.Section125.Employer_FSA_Contribution__c == null) {
                    if(showField)
                        sw.Section125.Employer_FSA_Contribution__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
                else if(sw.Section125.Employer_FSA_Contribution__c == 'Dollar for Dollar Match' &&
                        sw.Section125.Contribution_up_to__c == null) {
                    if(showField)
                        sw.Section125.Contribution_up_to__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
                else if(sw.Section125.Employer_FSA_Contribution__c == 'Other' &&
                        sw.Section125.Other_Contribution_Details__c == null) {
                    if(showField)
                        sw.Section125.Other_Contribution_Details__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
            }
            
            ///// Flex Billing /////
            
            if(sw.Section125.FlexSpendAcctFlexBillinfoFirstFSARed__c == null)
            {
                if(showField)
                    sw.Section125.FlexSpendAcctFlexBillinfoFirstFSARed__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            
            if(formType == 'AWD')
            {
                if(sw.Section125.FlexSpendAcctFlexBillinfoDoesrela__c == null)
                {
                    if(showField)
                        sw.Section125.FlexSpendAcctFlexBillinfoDoesrela__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.FlexibleSpendingTabComplete = false;
                    sw.AllTabsComplete = false;
                    FSATabComplete = false;
                }
                
                if(sw.Section125.FlexSpendAcctFlexBillinfoDoesrela__c == 'Yes')
                {
                    if(sw.Section125.FlexSpendAcctFlexBillinfoIfyesEm__c == null)
                    {
                        if(showField)
                            sw.Section125.FlexSpendAcctFlexBillinfoIfyesEm__c.addError(REQUIRED_FIELD_MESSAGE);
                        sw.FlexibleSpendingTabComplete = false;
                        sw.AllTabsComplete = false;
                        FSATabComplete = false;
                    }
                    
                    if(sw.Section125.FlexSpendAcctFlexBillinfoFirstPay__c == null)
                    {
                        if(showField)
                            sw.Section125.FlexSpendAcctFlexBillinfoFirstPay__c.addError(REQUIRED_FIELD_MESSAGE);
                        sw.FlexibleSpendingTabComplete = false;
                        sw.AllTabsComplete = false;
                        FSATabComplete = false;
                    }
                    
                    if(sw.Section125.FlexSpendAcctFlexBillinfoIfSepar__c == null)
                    {
                        if(showField)
                            sw.Section125.FlexSpendAcctFlexBillinfoIfSepar__c.addError(REQUIRED_FIELD_MESSAGE);
                        sw.FlexibleSpendingTabComplete = false;
                        sw.AllTabsComplete = false;
                        FSATabComplete = false;
                    } 
                }
            }
            
            if (sw.Section125.Flex_Billing_Same_as_Product_Billing__c == null) {
                if (showField) {
                    sw.Section125.Flex_Billing_Same_as_Product_Billing__c.addError(REQUIRED_FIELD_MESSAGE);
                }

                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
            else if (sw.Section125.Flex_Billing_Same_as_Product_Billing__c == 'No') {
                validateBillModes(sw, showField);
            }
        }
    }
    
    public void HSAcheckRequiredFields(boolean showField)
    { 
        HSATabComplete = true;
        
        for(Section125Wrapper sw : wrapS125s)
        {
            sw.HealthSavingsTabComplete = true;
            
            if(sw.Section125.HlthSvgsAcctDoesEmployerpart__c == null)
            {
                if(showField)
                    sw.Section125.HlthSvgsAcctDoesEmployerpart__c.addError(REQUIRED_FIELD_MESSAGE);
                sw.HealthSavingsTabComplete = false;
                sw.AllTabsComplete = false;
                HSATabComplete = false;
            }
            
            if(sw.Section125.HlthSvgsAcctDoesEmployerpart__c == 'Yes')
            {
                if(sw.Section125.HlthSvgsAcctContributionMethod__c == null)
                {
                    if(showField)
                        sw.Section125.HlthSvgsAcctContributionMethod__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.HealthSavingsTabComplete = false;
                    sw.AllTabsComplete = false;
                    HSATabComplete = false;
                }
                
                if(sw.Section125.HlthSvgsAcctDateofFirstHSAContribution__c == null)
                {
                    if(showField)
                        sw.Section125.HlthSvgsAcctDateofFirstHSAContribution__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.HealthSavingsTabComplete = false;
                    sw.AllTabsComplete = false;
                    HSATabComplete = false;
                }
                
                if(sw.Section125.HlthSvgsAcctChargeMonthlyMaint__c == null)
                {
                    if(showField)
                        sw.Section125.HlthSvgsAcctChargeMonthlyMaint__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.HealthSavingsTabComplete = false;
                    sw.AllTabsComplete = false;
                    HSATabComplete = false;
                }
                
                if(sw.Section125.HlthSvgsAcctDateofFirstHSAPayrollDed__c == null)
                {
                    if(showField)
                        sw.Section125.HlthSvgsAcctDateofFirstHSAPayrollDed__c.addError(REQUIRED_FIELD_MESSAGE);
                    sw.HealthSavingsTabComplete = false;
                    sw.AllTabsComplete = false;
                    HSATabComplete = false;
                }
            }
        }
    }
    
    public void updateSection125s()
    {
        try
        {
            if (section125s != null && section125s.size() > 0)
                update section125s;
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getMessage()));
        }
    }
    //Generates a new form looking up to the Enrollment Form
    public pageReference createNewPlan()
    {
        try
        {
            if (enrollmentForm != null){
                count++;
                Section_125_Setup_Form__c newForm = new Section_125_Setup_Form__c();
                newForm.Enrollment_Form__c = enrollmentForm.Id;
                newForm.OwnerId = enrollmentForm.Enrollment_Opportunity__r.OwnerId;
                newForm.Sec125PlanNumber__c = String.valueOf(count);
                
                // Copy Contact Information that gets generated in the General Setup Form
                // that way, if the initial form gets removed, you won't lose that data
                newForm.ContactInfoSec125ContactName__c = Section125s[0].ContactInfoSec125ContactName__c;
                newForm.ContactInfoSec125ContactTitle__c = Section125s[0].ContactInfoSec125ContactTitle__c;
                newForm.ContactInfoSec125ContactEmail__c = Section125s[0].ContactInfoSec125ContactEmail__c;
                newForm.ContactInfoSec125ContactPhoneNumbe__c = Section125s[0].ContactInfoSec125ContactPhoneNumbe__c;
                newForm.ContactInfoSec125ContactExtension__c = Section125s[0].ContactInfoSec125ContactExtension__c;
                newForm.S125S125ContactSameAsAdmin__c = Section125s[0].S125S125ContactSameAsAdmin__c;
                newForm.ContactInfoFlexContactName__c = Section125s[0].ContactInfoFlexContactName__c;
                newForm.ContactInfoFlexContactTitle__c = Section125s[0].ContactInfoFlexContactTitle__c;
                newForm.ContactInfoFlexContactEmail__c = Section125s[0].ContactInfoFlexContactEmail__c;
                newForm.ContactInfoFlexContactPhoneNumber__c = Section125s[0].ContactInfoFlexContactPhoneNumber__c;
                newForm.ContactInfoFlexContactExtension__c = Section125s[0].ContactInfoFlexContactExtension__c;
                newForm.S125FlexContactSameAsAdmin__c = Section125s[0].S125FlexContactSameAsAdmin__c;
                newForm.FlexSpendAcctGroupAddingHealthFSA__c = Section125s[0].FlexSpendAcctGroupAddingHealthFSA__c;
                newForm.FlexSpendAcctGroupAddingDDCFSA__c = Section125s[0].FlexSpendAcctGroupAddingDDCFSA__c;
                newForm.HlthSvgsAcctDoesEmployerpart__c = Section125s[0].HlthSvgsAcctDoesEmployerpart__c;
                
                insert newForm;
                
                setTabColors();
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error adding a new plan. ' + e.getMessage()));
        }
        init();
        return null;
    }
    //Deletes one child Section 125 Form
    public pageReference deletePlan()
    {
        try
        {
            System.debug('Delete Plan');
            System.debug('idToDelete: ' + idToDelete);
            if (idToDelete != null)
            {
                System.debug('Deleting Plan');
                Section_125_Setup_Form__c form = [SELECT Id FROM Section_125_Setup_Form__c WHERE Id=: idToDelete];
                delete form;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error deleting the plan. ' + e.getMessage()));
        }
        init();
        return null;        
    }
    
    //Delete Related Employer Record
    //Id is passed from the page
    public void deleteRE(){
        try
        {
            if (REIDToDelete != null)
            {
                Common_Ownership_Form__c re = new Common_Ownership_Form__c(Id = REIDToDelete);
                delete re;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error deleting the related employer. ' + e.getMessage()));
        }
        
    }
    
    //Delete Related Qualified Benefit
    //ID is passed from the page
    public void deleteBenefit(){
        try
        {
            if (BenefitIDToDelete != null)
            {
                Qualified_Benefit_Form__c q = [SELECT ID FROM Qualified_Benefit_Form__c WHERE Id =: BenefitIDToDelete];
                delete q;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error deleting the benefit. ' + e.getMessage()));
        }
        
    }
    
    //insert Related Employer record
    //Id passed from the page
    public void insertRelatedEmployer()
    {
        try
        {
            System.debug('$$$ Inserting Related Employer: (' + formToAdd + ')');
            if (formToAdd != null)
            {
                Common_Ownership_Form__c re = new Common_Ownership_Form__c();
                re.Section_125_Setup_Form__c = formToAdd;
                re.New_Or_Existing__c = 'New';
                //re.Related_Employer__c = accountId;
                insert re;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error adding the related employer. ' + e.getMessage()));
        }
    }
    //insert Qualified Benefit record
    //Id is passed from the page
    public void AddBenefit()
    {
        try
        {
            System.debug('### formToAdd: ' + formToAdd);
            if (formToAdd != null)
            {
                Qualified_Benefit_Form__c q = new Qualified_Benefit_Form__c();
                q.Customer_Setup_Form__c = formToAdd;
                //q.Add_Benefit__c = BenefitType;
                insert q;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error adding the qualified benefit. ' + e.getMessage()));
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
                Qualified_Benefit_Form__c q = [SELECT Id FROM Qualified_Benefit_Form__c WHERE Id=: BenefitID];
                q.put(fieldName, fieldValue);
                update q;           
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a benefit field. ' + e.getMessage()));
        }
    }
    
    //update field on a Related Employers record
    //id fieldName and fieldValue are passed from the page
    public void updateRE()
    {
        try
        {
            System.debug('### BenefitID: ' + BenefitID);
            System.debug('### fieldName: ' + fieldName);
            System.debug('### fieldValue: ' + fieldValue);
            
            if (BenefitID != null && fieldName != null)
            {
                Common_Ownership_Form__c re = new Common_Ownership_Form__c(Id = BenefitID);
                re.put(fieldName, fieldValue);
                update re;
                
                setTabColors();
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a related employer field. ' + e.getMessage()));
        }
    }
    
    public void updateRENewOrExisting() {
        try
        {
            System.debug('### BenefitID: ' + BenefitID);
            
            if (BenefitID != null)
            {
                Section_125_Setup_Form__c primaryS125 = section125s[0];
                Common_Ownership_Form__c relatedEmployerToUpdate = null;
                
                for (Common_Ownership_Form__c relatedEmployer : primaryS125.Common_Ownership_Forms__r) {
                    if (relatedEmployer.Id == BenefitId) {
                        relatedEmployerToUpdate = relatedEmployer;
                    }
                }
                
                system.debug('    relatedEmployerToUpdate: ' + relatedEmployerToUpdate);
                
                if (relatedEmployerToUpdate == null) {
                    return;
                }
                
                Common_Ownership_Form__c re = new Common_Ownership_Form__c(Id = BenefitID);
                re.New_Or_Existing__c = relatedEmployerToUpdate.New_Or_Existing__c;
                update re;
                
                setTabColors();
                
                system.debug('    re: ' + re);
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a related employer field. ' + e.getMessage()));
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
            checkRequiredFieldsAndDisplay();
            
            if(AllTabsComplete)
            {
                System.debug('### Submitting FORM');
                
                List<Section_125_Setup_Form__c> forms = section125s;
                for (Section_125_Setup_Form__c s : forms){
                    s.Status__c = 'Submitted';
                }
                update forms;

                createSalesforceFile();
            }
            
            setStatusMsg();
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error submitting the form. ' + e.getMessage()));
        }
    }
    
    public void createSalesforceFile()
    {
        List<String> ContentLinkIds = new List<String>();
        
        for(Section_125_Setup_Form__c sForm : section125s)
        {
        	ContentLinkIds.add(sForm.Id);    
        }
        
        ContentLinkIds.add(enrollmentForm.Enrollment_Opportunity__c);
        
        PageReference pagePdf = Page.Section125PDF;
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
        cv.VersionData = pdfPageBlob;
        cv.title = 'Section125PDF';
        cv.PathOnClient = 'Section125PDF.pdf';
        cv.FirstPublishLocationId = formId;  //formId here is the enrollmentForm
        
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
    
    public void updateEnrollmentForm()
    {
        // If request edit is requested and the form is not further than the 'Submitted' state
        // automatically re-open the form.  If the form has entered into a further state,
        // then a true request edit needs to be sent back to Home Office
        if (fieldName == 'Request_Edit__c')
        {
            boolean setRequestEdit = false;
            
            if(fieldValue == 'true')
            {
                if(statusMsg == 'Submitted')
                    setRequestEdit = true;
            }
            
            for(Section_125_Setup_Form__c s : section125s)
            {
                if(setRequestEdit)
                {
                    s.Request_Edit__c = false;
                    s.Status__c = 'In Progress';
                }
                else
                    s.Request_Edit__c = true;
            }
            
            update section125s;
            
            setStatusMsg();
        }
        
    }
    
    public void getHelpText() {
        // map of all fields in the object
        Map<String, Schema.SObjectField> objectFields =  schema.SObjectType.Section_125_Setup_Form__c.fields.getMap();
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
    
    public void insertBillMode() {
        Bill_Mode__c billModeToAdd = new Bill_Mode__c(
            RecordTypeId = Constants.BILL_MODES_FLEX_BILLING,
            Section_125_Setup_Form__c = formToAdd
        );
        
        insert billModeToAdd;
        
        setTabColors();
    }
    
    public void removeBillMode() {
        Bill_Mode__c bmToDelete = findExistingBillMode(BillModeIdToRemove);
        
        if (bmToDelete != null) {
            delete bmToDelete;
            setTabColors();
        }
    }
    
    public void updateBillMode() {
        Bill_Mode__c bmToUpdate = findExistingBillMode(BillModeIdToUpdate);

        if (bmToUpdate != null) {
            update bmToUpdate;
            setTabColors();
        }
    }
    
    public void updateFSAProductBilling() {
        updateSection125s();
        
        Section125Wrapper s125Wrapper = findS125WrapperById(formToAdd);
        
        if (s125Wrapper != null &&
            s125Wrapper.section125.Flex_Billing_Same_as_Product_Billing__c == 'No' &&
            s125Wrapper.Section125.Bill_Modes__r.isEmpty()) {
            insertBillMode();
        }
        
        setTabColors();
    }

    private Bill_Mode__c findExistingBillMode(Id billModeId) {
        for (Section125Wrapper s125Wrapper : wrapS125s) {
            for (Bill_Mode__c bm : s125Wrapper.Section125.Bill_Modes__r) {
                if (bm.Id == billModeId) {
                    return bm;
                }
            }
        }
        
        return null;
    }
    
    private Section125Wrapper findS125WrapperById(Id s125Id) {
        for (Section125Wrapper s125Wrapper : wrapS125s) {
            if (s125Wrapper.Section125.Id == s125Id) {
                return s125Wrapper;
            }
        }
        
        return null;
    }

    private set<String> getBillModeRequiredFields() {
        // Allow the list of required fields to be overridable via tests.
        if (TestBillModeRequiredFields != null &&
            !TestBillModeRequiredFields.isEmpty()) {
            return TestBillModeRequiredFields;
        }
        
        List<Schema.FieldSet> requiredFieldSetsToCheck = new List<Schema.FieldSet>{
            SObjectType.Bill_Mode__c.FieldSets.Flex_Billing
        };
        
        Map<String, Schema.FieldSetMember> requiredFSMs = getRequiredFieldSetMembers(requiredFieldSetsToCheck);
        
        return requiredFSMs.keySet();
    }
    
    private void validateBillModes(Section125Wrapper sw, Boolean showField) {
        set<String> requiredFields = getBillModeRequiredFields();
        
        if (sw.Section125.Bill_Modes__r.isEmpty()) {
            if (showField) {
                billModesErrorMessage = NO_BILL_MODES_VAL_MSG;
            }

            sw.FlexibleSpendingTabComplete = false;
            sw.AllTabsComplete = false;
            FSATabComplete = false;
        }

        for (Bill_Mode__c bm : sw.Section125.Bill_Modes__r) {
            if (requiredFields.contains(Bill_Mode__c.Benefit_Deduction_Schedule__c.getDescribe().getName()) &&
                bm.Benefit_Deduction_Schedule__c == null) {

                if (showField) {
                    bm.Benefit_Deduction_Schedule__c.addError(REQUIRED_FIELD_MESSAGE);
                }

                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }

            if (requiredFields.contains(Bill_Mode__c.What_Months_No_Deductions_Taken__c.getDescribe().getName()) &&
                bm.What_Months_No_Deductions_Taken__c == null) {

                if (showField) {
                    bm.What_Months_No_Deductions_Taken__c.addError(REQUIRED_FIELD_MESSAGE);
                }

                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }

            if (requiredFields.contains(Bill_Mode__c.Other_Information__c.getDescribe().getName()) &&
                bm.Other_Information__c == null) {

                if (showField) {
                    bm.Other_Information__c.addError(REQUIRED_FIELD_MESSAGE);
                }

                sw.FlexibleSpendingTabComplete = false;
                sw.AllTabsComplete = false;
                FSATabComplete = false;
            }
        }
    }
    
    // This class is intended to set tab colors for each Section125 tab
    public class Section125Wrapper
    {
        public Section_125_Setup_Form__c Section125		{get;set;}
        public boolean Section125TabComplete			{get;set;}
        public boolean QualifiedBenefitsTabComplete		{get;set;}
        public boolean FlexibleSpendingTabComplete		{get;set;}
        public boolean HealthSavingsTabComplete			{get;set;}
        public boolean AllTabsComplete					{get;set;}
        
        public Section125Wrapper(Section_125_Setup_Form__c s)
        {
            Section125 = s;
            Section125TabComplete = false;
            QualifiedBenefitsTabComplete = false;
            FlexibleSpendingTabComplete = false;
            HealthSavingsTabComplete = false;
            AllTabsComplete = true;
        }
    }
}