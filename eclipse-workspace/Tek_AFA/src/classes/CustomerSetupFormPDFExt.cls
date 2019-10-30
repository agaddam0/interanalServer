public class CustomerSetupFormPDFExt
{
    public Opportunity enrollmentOpp			{get;set;}
    public Account acct							{get;set;}
    public List<String> MarketedProducts		{get;set;}
    public String formType						{get;set;}
    public Customer_Setup_Form__c c						{get;set;}
    public Customer_Setup_Form__c csf						{get;set;}
    public Platform_Setup__c  ps						{get;set;}
    private Id enrollmentFormId;
    public List<Common_Ownership_Form__c> commons               {get;set;}
    public Customer_Setup_Form__c csfMatchingMCP               {get;set;}
    public List<Group_Products_Form__c> products                {get;set;}
    public boolean	onboardingTabDisplayed			{get; set;}
    public boolean  productBillingTabDisplayed  	{get; set;}
    public boolean	groupPlansTabDisplayed			{get; set;}
    public boolean	openEnrollmentTabDisplayed			{get; set;}
    public boolean	AnnuitiesTabDisplayed			{get; set;}
    public List<Marketed_Product__c> enrollmentMarketedProducts {get; set;}
    public List<Bill_Mode__c> BillModes { get; set; }

    public CustomerSetupFormPDFExt(ApexPages.StandardController stdController) {
        c = [SELECT Id, 
				    Enrollment_Form__c,
				    Enrollment_Form__r.Enrollment_Opportunity__c, 
				    ContactInfoAdminContact__c, 
				    ContactInfoBenefitContact__c, 
				    ContactInfoBillingContact__c,
				    ContactInfoBenefitContactSame__c,
				    ContactInfoBillingContactSame__c,
				    Date_Customer_Setup_Submitted__c,
				    RecordTypeId
               FROM Customer_Setup_Form__c 
              WHERE Id =: stdController.getId()];

        this.CSF = (Customer_Setup_Form__c)stdController.getRecord();
        enrollmentFormId = c.Enrollment_Form__c;

        enrollmentMarketedProducts =
            [select Id,
                    Name,
                    products__r.name,
                    products__r.Chassis__c,
                    plan_status__c,
                    products__r.product_family__c
               from Marketed_Product__c
              where enrollment__c = :enrollmentFormId];

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
                                     EE_Eligibility_Waiting_Period__c,
                                     Residence_State_s__c,
                                     Marketed_Products__c,
                                     Platform__c,
                                     Enrollment_Setup_Notes__c,
                                     Legal_Name_is_different_than_Group_Name__c,
                                     Plan_Date_New__c,
                                     Assigned_Account_Manager__r.Name,
                                     Working_Conditions__c,
                                     Division__c, 
                                     Confirm_New_or_Existing_Group__c,
                                     Are_you_adding_new_plans_or_services__c,
                                     Are_you_making_any_billing_changes__c,
                                     Requesting_Open_Enrollment__c,
                                     Waiting_Period_Effective__c,
                                     Other_Eligibility_Waiting_Period__c
						        FROM Opportunity 
						       WHERE Id =: c.Enrollment_Form__r.Enrollment_Opportunity__c];
						       
        this.ps = [SELECT Id, Enroll_Info_GrpToCcontactForData__c, Enroll_Info_Enrollment_Type__c,Enroll_Info_Upload__c,Enroll_Info_Electronic_Consent__c,Enroll_Info_Send_Time_To_Enroll_Email__c,
							Enroll_Info_Service_Process__c,Enroll_Info_First_Payroll_Deduction_Date__c,EnrollInfoPayrollDeductFrequenc__c,Enroll_Info_Payroll_Deduction_Begins__c,Enroll_Info_Skip_Months__c,
                            Enroll_Info_Product_Only__c,Enroll_Info_Returning_Electronic_Data__c,Enroll_Info_Full_Benefit__c,EnrollInfoUploadDueDate__c, Coverage_Effective_Date__c,
                            PayrollInfo11MoCheck__c,PayrollInfo10MoCheck__c,PayrollInfo9MoCheck__c,PayrollInfoSkipMonths11__c,PayrollInfoSkipMonths10__c,PayrollInfoSkipMonths9__c
                     FROM Platform_Setup__c
                    WHERE Enrollment_Form__c = :enrollmentFormId
                      AND (recordType.Name='AFES Form' or recordType.Name='AWD Form')
                     limit 1];
        
        this.acct = [SELECT Id,
                            BillingStreet,
                            BillingCity,
                            BillingState,
                            BillingPostalCode,
                            ShippingStreet,
                            ShippingCity,
                            ShippingState,
                            ShippingPostalCode,
                            Owner.Name,
                            Owner.Title, 
                            Owner.Phone, 
                            Owner.EmployeeNumber, 
                            Owner.Email, 
                            Owner.Agent_ID__c, 
                            Owner.Extension,
                            payroll_company__c
                       FROM Account 
                      WHERE Id =: enrollmentOpp.AccountID];

        Id AWDid = Schema.SObjectType.Customer_Setup_Form__c.getRecordTypeInfosByName().get('AWD Form').getRecordTypeId();

        if(c.RecordTypeId == AWDid)
            formType = 'AWD';
        else
            formType = 'AFES';

            commons = [SELECT Id, Name, Legal_Name__c, Location__c, Location__r.Name, MCP_Setup_Form__c, MCP_Number__c, New_Or_Existing__c,
                              Address_Line_1__c, Address_Line_2__c, City__c, State__c, State_Picklist__c, ZipCode__c, Employer_Tax_ID_Number__c,
                              Related_Employer_under_S125_Plan__c, DBA_Name__c, Contact_Name__c, Contact_Phone_Number__c, Contact_Email__c,
                       		  Is_the_broker_the_same_as_the_Parent_Acc__c, Broker_Involved__c, Broker_Legal_Name__c,
                       		  Broker_Number__c, Does_the_Standard_Broker_Contract_Apply__c, Is_the_Broker_Affiliated_with_an_Agency__c, 
                       		  Is_the_Broker_AOR_for_AFA_Products__c, Will_there_be_a_Single_Case_Agreement__c, Name_of_Agency__c
                         FROM Common_Ownership_Form__c WHERE MCP_Setup_Form__c =: c.Id Order By CreatedDate];

        csfMatchingMCP = [select GrpProdLTDplansmatchingMCP__c,GrpProdSTDplansmatchingMCP__c,GrpProdGroupCIplansmatchingMCP__c,GrpProdGAPplansmatchingMCP__c
                            from Customer_Setup_Form__c
                           where Id =:c.Id];

        products = [SELECT Id, Name, Before_or_After_Tax__c, Customer_Setup_Form__c, Group_Products__c, MCH_Company__c, Plan_Codes_Benefits__c, ProductName__c 
                      FROM Group_Products_Form__c
                     WHERE Customer_Setup_Form__c =: CSF.Id];

        loadBillModes();

        setFieldsToDisplay();
        setupTabs();
	}

/* jhicks 01/17 - define attributes used for showing/hiding fields 
       If the variable is true, the related field will be displayed
       Need individual fields due to the nature of the requirements 
       The variable names match the api names of the fields minus the '__c' */
    public boolean 	GrpProdSelectProductsTakingOver   {get;set;}
    public boolean GrpProdTakeoverOfGroupPlan {get;set;}
    public boolean 	GrpProdProvideCarriersofTakeoverProducts	{get;set;}
    public boolean 	GrpProdHowwouldyouliketoselectGAPplans		{get;set;}
    public boolean 	GrpProdHowwouldyouliketoselectDisplans		{get;set;}
    public boolean 	GrpProdHowwouldyouliketoselectGrpCIplans	{get;set;}
    public boolean 	GrpProdLTDplanstomatchAccount				{get;set;}
    public boolean 	GrpProdSTDplanstomatchAccount				{get;set;}
    public boolean 	GrpProdGroupCIplanstomatchAccount			{get;set;}
    public boolean 	GrpProdGAPplanstomatchAccount				{get;set;}
    public boolean 	GrpProdLTDplansmatchingMCP					{get;set;}
    public boolean 	GrpProdSTDplansmatchingMCP					{get;set;}
    public boolean 	GrpProdGroupCIplansmatchingMCP				{get;set;}
    public boolean 	GrpProdGAPplansmatchingMCP					{get;set;}
    public boolean 	GrpProdLTDEliminationPeriod					{get;set;}
    public boolean 	GrpProdLTDOtherElimination					{get;set;}
    public boolean 	GrpProdLTDBenefitPlan						{get;set;}
    public boolean 	GrpProdLTDCustomBenefitPlan					{get;set;}
    public boolean 	GrpProdSTDEliminationPeriod					{get;set;}
    public boolean 	GrpProdSTDOtherElimination					{get;set;}
    public boolean 	GrpProdSTDBenefitPlan						{get;set;}
    public boolean 	GrpProdSTDCustomBenefitPlan					{get;set;}
    public boolean 	GrpCIGrpCritIll_MCH_7268					{get;set;}
    public boolean 	GrpProdSpouseBenefitAmount					{get;set;}
    public boolean 	GrpCIGrpCritIllMCH7268PlanCode				{get;set;}
    public boolean 	HospitalGAPInfoPlanOption					{get;set;}
    public boolean 	HospitalGapInfoEmployerContribution			{get;set;}
    public boolean 	HospitalGapInfoHospGapPlanAmount			{get;set;}
    public boolean 	showMatchPanel								{get;set;}
    public boolean 	showPlanInfo								{get;set;}
    public boolean  showGroupCancer                             {get;set;}

    public void setFieldsToDisplay() {
        Set<string> marketedProducts = new Set<string>();
        String MP = 'Match plans to an existing MCP';
        String PPCodes = 'Provide product plan codes';
        String PP = 'Provide plan information';
        String LTD = 'Long-Term Disability';
        string STD = 'Short-Term Disability';
        string GroupCancer = 'Group Cancer';
        // marketedProducts.contains()
        for (Marketed_Product__c mp2 : enrollmentMarketedProducts) {
            if (mp2.plan_status__c == 'New') {
                marketedProducts.add(mp2.products__r.name);
            }
        }
        system.debug('::: marketedProducts: '+ marketedProducts);

        // this is going to be painful, but....
        GrpProdSelectProductsTakingOver = 					CSF.GrpProdTakeoverOfGroupPlan__c == 'Yes';
        GrpProdProvideCarriersofTakeoverProducts = 			CSF.GrpProdTakeoverOfGroupPlan__c == 'Yes';
        GrpProdHowwouldyouliketoselectGAPplans = 			marketedProducts.contains('Hospital GAP');
        GrpProdHowwouldyouliketoselectDisplans = 			marketedProducts.contains(STD) || marketedProducts.contains(LTD);
        GrpProdHowwouldyouliketoselectGrpCIplans = 			marketedProducts.contains('Group Critical Illness');

        GrpProdLTDplanstomatchAccount = 					CSF.GrpProdHowwouldyouliketoselectDisplans__c == MP && marketedProducts.contains(LTD);
        GrpProdSTDplanstomatchAccount = 					CSF.GrpProdHowwouldyouliketoselectDisplans__c == MP && marketedProducts.contains(STD);
        GrpProdGroupCIplanstomatchAccount = 				CSF.GrpProdHowwouldyouliketoselectGrpCIplans__c == MP;
        GrpProdGAPplanstomatchAccount = 					CSF.GrpProdHowwouldyouliketoselectGAPplans__c == MP;

        GrpProdLTDEliminationPeriod = 						CSF.GrpProdHowwouldyouliketoselectDisplans__c == PP && marketedProducts.contains(LTD);
        GrpProdLTDOtherElimination = 						CSF.GrpProdLTDEliminationPeriod__c==null ? false : CSF.GrpProdLTDEliminationPeriod__c.containsIgnoreCase('Other') 
                                                                    && GrpProdLTDEliminationPeriod;
        GrpProdLTDBenefitPlan = 							CSF.GrpProdHowwouldyouliketoselectDisplans__c == PP && marketedProducts.contains(LTD);
        GrpProdLTDCustomBenefitPlan = 						CSF.GrpProdLTDBenefitPlan__c==null ? false : CSF.GrpProdLTDBenefitPlan__c.containsIgnoreCase('Custom')
                                                                    && GrpProdLTDBenefitPlan;
        GrpProdSTDEliminationPeriod = 						CSF.GrpProdHowwouldyouliketoselectDisplans__c == PP & marketedProducts.contains(STD);
        GrpProdSTDOtherElimination = 						CSF.GrpProdSTDEliminationPeriod__c==null ? false : CSF.GrpProdSTDEliminationPeriod__c.containsIgnoreCase('Other')
                                                                    && GrpProdSTDEliminationPeriod;
        GrpProdSTDBenefitPlan = 							CSF.GrpProdHowwouldyouliketoselectDisplans__c == PP && marketedProducts.contains(STD);
        GrpProdSTDCustomBenefitPlan = 						CSF.GrpProdSTDBenefitPlan__c==null ? false : CSF.GrpProdSTDBenefitPlan__c.containsIgnoreCase('Custom')
                                                                    && GrpProdSTDBenefitPlan;
        GrpCIGrpCritIll_MCH_7268 = 							CSF.GrpProdHowwouldyouliketoselectGrpCIplans__c == PP;
        GrpProdSpouseBenefitAmount = 						CSF.GrpProdHowwouldyouliketoselectGrpCIplans__c == PP;
        GrpCIGrpCritIllMCH7268PlanCode = 					CSF.GrpProdHowwouldyouliketoselectGrpCIplans__c == PP;
        HospitalGAPInfoPlanOption = 						CSF.GrpProdHowwouldyouliketoselectGAPplans__c == PP;
        if (CSF.HospitalGAPInfoPlanOption__c != null)
            HospitalGapInfoEmployerContribution = 				'GAP Plan Choice - Voluntary;GAP Plan - Voluntary'.contains(CSF.HospitalGAPInfoPlanOption__c);
        else
            HospitalGapInfoEmployerContribution = false;

        HospitalGapInfoHospGapPlanAmount = 					CSF.GrpProdHowwouldyouliketoselectGAPplans__c == PP;

        showGroupCancer =                                   marketedProducts.contains(GroupCancer);

        showMatchPanel = GrpProdLTDplanstomatchAccount ||	GrpProdSTDplanstomatchAccount||	GrpProdGroupCIplanstomatchAccount||	GrpProdGAPplanstomatchAccount;	
        showPlanInfo = csf.GrpProdHowwouldyouliketoselectDisplans__c  == PP || csf.GrpProdHowwouldyouliketoselectGrpCIplans__c==PP ||csf.GrpProdHowwouldyouliketoselectGAPplans__c==PP ||
        csf.GrpProdHowwouldyouliketoselectDisplans__c  == PPCodes || csf.GrpProdHowwouldyouliketoselectGrpCIplans__c==PPCodes ||csf.GrpProdHowwouldyouliketoselectGAPplans__c==PPCodes;
   	
        // investigate moving TabsToDisplay here
    } 

    private void setupTabs() {
        onboardingTabDisplayed = false;
        productBillingTabDisplayed = false;
        groupPlansTabDisplayed = false;
        openEnrollmentTabDisplayed = false;
        AnnuitiesTabDisplayed = false;

        // set flags to indicate which tabs are shown
        if (enrollmentOpp.Confirm_New_or_Existing_Group__c == 'New') {
            onboardingTabDisplayed = true;
            productBillingTabDisplayed = true;
            groupPlansTabDisplayed = true;

            try {
                Marketed_Product__c mp = [select Id from Marketed_Product__c where products__r.name like '%Annuity%' and plan_status__c = 'New' and enrollment__c = :enrollmentFormId limit 1 ];
                AnnuitiesTabDisplayed = true;
            }
            catch(exception e){}     // no record found
        }
        else {   //existing plans
            if (enrollmentOpp.Are_you_adding_new_plans_or_services__c != null){
                if(enrollmentOpp.Are_you_adding_new_plans_or_services__c.containsIgnoreCase('New Group Plans')) {
                    groupPlansTabDisplayed = true;
                    onboardingTabDisplayed = true;
                }
            }
            if (enrollmentOpp.Are_you_adding_new_plans_or_services__c != null){
                if(enrollmentOpp.Are_you_adding_new_plans_or_services__c.containsIgnoreCase('New Annuity Plans'))
                AnnuitiesTabDisplayed = true;
            }
            if (enrollmentOpp.Are_you_making_any_billing_changes__c == 'Yes')
                productBillingTabDisplayed = true;

            if (enrollmentOpp.Requesting_Open_Enrollment__c == 'Yes')
                openEnrollmentTabDisplayed = true;

            for (Marketed_Product__c enrollmentMP : enrollmentMarketedProducts) {
                if (enrollmentMP.Products__r.Chassis__c == 'Group' &&
                    enrollmentMP.Plan_Status__c == 'New') {

                    groupPlansTabDisplayed = true;
                    onboardingTabDisplayed = true;
                }

                if ((enrollmentMP.Products__r.Product_Family__c == 'Fixed Annuity' ||
                    enrollmentMP.Products__r.Product_Family__c == 'Variable Annuity') &&
                    enrollmentMP.Plan_Status__c == 'New') {
                    AnnuitiesTabDisplayed = true;
                }
            }
        }
    }

    private void loadBillModes() {
        Set<String> billModeFields = Util.getFieldSetFields(new List<Schema.FieldSet>{ SObjectType.Bill_Mode__c.FieldSets.Product_Billing });
        Id csfId = CSF.Id;
        
        String billModesSOQL = 'SELECT Id, ' + String.join(new List<String>(billModeFields), ',') +
                               '  FROM Bill_Mode__c ' +
                               ' WHERE Customer_Setup_Form__c = :csfId';

        BillModes = Database.query(billModesSOQL);
    }
}