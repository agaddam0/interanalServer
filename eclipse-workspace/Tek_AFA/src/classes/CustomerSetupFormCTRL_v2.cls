// Version:             1.0
// Author:              Etherios
// Date Created:        1/13/2015
// Description:         CustomerSetupFormCTRL Apex class 
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
* Controller for the CustomerSetupForm page
* 
* On page load, this class pulls in data from related objects
* Updates Platorm Setup Form fields as well as fields on related objects.
* Also responsible for creating and deleting related objects.
* 
* Handles the submission of the form, and the creation of the form PDF
*
***********************************************************************************************/
public class CustomerSetupFormCTRL_v2 extends PreenrollmentControllerBase {
    public static final String LTD_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG = 'You cannot select the account related to this enrollment. You must select a different Account.';
    public static final String STD_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG = 'You cannot select the account related to this enrollment. You must select a different Account.';
    public static final String CI_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG = 'You cannot select the account related to this enrollment. You must select a different Account.';
    public static final String GAP_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG = 'You cannot select the account related to this enrollment. You must select a different Account.';
    public static final String NO_BILL_MODES_VAL_MSG = 'At least one bill mode is needed.';

    //public variables available to pull/push into form
    public Customer_Setup_Form__c CSF                           {get;set;}  // jhicks 01/17 shortened name
    public Customer_Setup_Form__c theCustomerSetupForm          {get;set;}  // jhicks 01/17
    public Customer_Setup_Form__c csfMatchingMCP                {get;set;}  // to display matching mcp.  needed if fields are updated
    
    public Customer_Setup_Form__c csForm                        {get;set;}
    public Enrollment_Form__c enrollmentForm                    {get;set;}
    public Opportunity enrollmentOpp                            {get;set;}
    public Account acc                                          {get;set;}
    public User mainAgent                                       {get;set;}
    public User userPerformingEnrollment                        {get;set;}
    public Contact adminContact                                 {get;set;}
    public Contact contactLookup                                {get;set;}
    public String commonOwnershipId                             {get;set;}
    public Common_Ownership_Form__c co                          {get;set;}
    public String locationId                                    {get;set;}
    public String commonId                                      {get;set;}
    public Location_Form__c lo                                  {get;set;}
    public String managerId                                     {get;set;}
    public OpportunityTeamMember otm                            {get;set;}
    public String formId                                        {get;set;}
    public String adminContactName                              {get;set;}
    public String userName                                      {get;set;}
    public String fieldName                                     {get;set;}
    public String fieldValue                                    {get;set;}
    public List<Common_Ownership_Form__c> commons               {get;set;}
    public List<OpportunityTeamMember> oppTeam                  {get;set;}
    public List<OpportunityTeamMember> oppTeamOwner             {get;set;}
    public List<Location_Form__c> locations                     {get;set;}
    public List<Account> commonLocations                        {get;set;}
    public Id CommonOwnershipIdToDelete                         {get;set;}
    public Id LocationIdToDelete                                {get;set;}
    public Id productId                                         {get;set;}
    public String formType                                      {get;set;}
    public List<Group_Products_Form__c> products                {get;set;}
    public String retUrl                                        {get;set;}
    public String platformId                                    {get;set;}
    public String planSummaryId                                 {get;set;}
    public Id otmId                                             {get;set;}
    public Integer section125count                              {get;set;}
    public String status                                        {get;set;}
    public User runningUser                                     {get;set;}
    public String accountId                                     {get;set;}
    public User ACM                                             {get;set;}
    public List<String> MarketedProducts                        {get;set;}
    public boolean showErrorMessages                            {get;set;}
    public string mainFillingForm                               {get;set;}
    public User AccountOwner                                    {get;set;}
    public Contact benefitContact                               {get;set;}
    public String benContactSame                                {get;set;}
    public String billContactSame                               {get;set;}
    public Contact billingContact                               {get;set;}
    /* jhicks - 12/16  */
    public string statusMsg                                     {get; set;}
    public boolean formIsSubmitted                              {get; set;}
    public boolean onboardingTabComplete                        {get; set;}
    public boolean productBillingTabComplete                    {get; set;}
    public boolean groupPlansTabComplete                        {get; set;}
    public boolean openEnrollmentTabComplete                    {get; set;}
    public boolean AnnuitiesTabComplete                         {get; set;}
    public boolean onboardingTabDisplayed                       {get; set;}
    public boolean productBillingTabDisplayed                   {get; set;}
    public boolean groupPlansTabDisplayed                       {get; set;}
    public boolean openEnrollmentTabDisplayed                   {get; set;}
    public boolean AnnuitiesTabDisplayed                        {get; set;}
    public Map<string,string>  hMap                             {get; set;}
    public Platform_Setup__c ps                                 {get; set;}
    public Set<string> mkProducts                               {get;set;}
    public List<Customer_Setup_Form__c> CSFs ;  // mainly for test class
    public List<Marketed_Product__c> enrollmentMarketedProducts {get; set;}
    public List<Bill_Mode__c> BillModes { get; set; }
    public Id BillModeIdToRemove { get; set; }
    public Id BillModeIdToUpdate { get; set; }
    
    @testVisible
    private set<String> TestBillModeRequiredFields { get; set; }
    
    public Boolean hasLongTermDisabilityMarketedProduct { get; set; }
    public Boolean hasShortTermDisabilityMarketedProduct { get; set; }
    public Boolean hasGroupCriticalIllnessMarketedProduct { get; set; }
    public Boolean hasHospitalGapMarketedProduct { get; set; }
    public Boolean hasGroupCancerMarketedProduct { get; set; }
    
    public String numberRequiredGroupProductsMessage { get; set; }
    public String billModesErrorMessage { get; set; }
    
    public String getCoverageEffectiveDate() {
        if (CSF != null) {
            Platform_Setup__c coverageEffectDatePS =
            [Select Id,
                    Coverage_Effective_Date__c
               from Platform_Setup__c
              where Id = :ps.Id];
            
            if (coverageEffectDatePS.Coverage_Effective_Date__c != null) {
                return coverageEffectDatePS.Coverage_Effective_Date__c.format();
            }
        }
        
        return '';
    }
    
    //Construtor gathers data from form record and related records
    public CustomerSetupFormCTRL_v2(ApexPages.StandardController stdController) {
        
        List<String> fieldsToAdd = new List<String>();
        fieldsToAdd.add('EmployerInfoEffectiveDate__c');
        fieldsToAdd.add('EmployerInfoIsDBANamethesame__c');
        fieldsToAdd.add('DetailsCommonownershipwithanotherGr__c');
        fieldsToAdd.add('DetailsDoesGrpparticipateinAFAS125__c');
        fieldsToAdd.add('AgtInfoMainAgtName__c');
        fieldsToAdd.add('EmployerInfoMailaddsameasphysadd__c');
        fieldsToAdd.add('AgtInfoMainAgtfillingoutthisform__c');
        fieldsToAdd.add('AgtInfoIsthisanEDirectEnrollment__c');
        fieldsToAdd.add('AgtInfoIsthereabrokerinvolved__c');
        fieldsToAdd.add('AgtInfoAORBrokersameforAFAProd__c');
        fieldsToAdd.add('AgtInfoBrokerstandardcontractapply__c');
        fieldsToAdd.add('BillInfoPayrollDeductions__c');
        fieldsToAdd.add('GrpDisWillGrpDisabbeSetforMCP__c');
        fieldsToAdd.add('GrpDisDoesGrphaveDIcovanothercarrier__c');
        fieldsToAdd.add('AgtInfoWilltherebeaSingleCase__c');
        fieldsToAdd.add('AnnAfterTaxAcctInfoBillAddSame__c');
        fieldsToAdd.add('AnnAfterTaxAcctMgrInfRothIRA__c');
        fieldsToAdd.add('AnnAfterTaxAcctMgrInfNonQual__c');
        fieldsToAdd.add('Status__c');
        fieldsToAdd.add('Request_Edit__c');
        fieldsToAdd.add('What_date_does_the_employer_need_to_key__c');
        //fieldsToAdd.add('CntctInfoAdminCntctEnrollTmCntctAcct__c');
        if (!Test.isRunningTest()){ 
           stdController.addFields(fieldsToAdd);
        }
        this.CSF = (Customer_Setup_Form__c)stdController.getRecord();
        theCustomerSetupForm = csf;   // for backward compatibility
        formId = CSF.Id;
        
        //User using the page
        runningUser = [SELECT Id, Name, Email, Phone, Extension, EmployeeNumber FROM User WHERE Id =: UserInfo.getUserId()];

        init();
    }
    
    public void getMatchingMCP() {
        csfMatchingMCP = [select GrpProdLTDplansmatchingMCP__c,GrpProdSTDplansmatchingMCP__c,GrpProdGroupCIplansmatchingMCP__c,GrpProdGAPplansmatchingMCP__c
                           from Customer_Setup_Form__c where Id =: formId];
    }

    public void init() {

        enrollmentOpp = new Opportunity();
        acc = new Account();
        // Not being used?
        // contactLookup = [SELECT id, Name FROM Contact LIMIT 1];
        adminContact = new Contact();
        
        RecordType awdRT = [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Customer_Setup_Form__c' AND DeveloperName = 'AWD_Form'];
        
        //Gather the setup form record
        CSFs = [Select RecordTypeId, c.Status__c, c.SystemModstamp, c.OwnerId, c.Name, c.LastModifiedDate, 
                                             c.LastModifiedById, c.IsDeleted, c.Id, c.HospitalGapInfoHospGapPlanQuestion__c, c.HospitalGapInfoHospGapPlanAmount__c, 
                                             c.HospitalGapInfoEmployerContribution__c, c.GrpHospitalIndemnity__c, c.GrpDisWillGrpDisabbeSetforMCP__c, 
                                             c.GrpDisTakeoveOfAnotherGrpDisPlan__c, c.GrpDisSeriesIVG120__c, c.GrpDisSeriesIII__c, c.GrpDisIfYespleaseexplain__c, 
                                             c.GrpDisEmployerContributionIfAny__c, c.GrpDisDoesGrphaveDIcovanothercarrier__c, c.GrpDisDisEliminationPeriod__c, 
                                             c.GrpDisDisEligibilityPeriod__c, c.GrpCIGrpCritIllMCH7268Tier2__c, c.GrpCIGrpCritIllMCH7268Tier1__c, c.GrpCIGrpCritIllBeSetupforMCP__c, 
                                             c.Enrollment_Form__c, c.EmployerInfoTotalNumberofEligible__c, c.EmployerInfoPhysicalAddressZip__c, c.EmployerInfoPhysicalAddressState__c, 
                                             c.EmployerInfoPhysicalAddressLine2__c, c.EmployerInfoPhysicalAddressLine1__c, c.EmployerInfoPhysicalAddressCity__c, 
                                             c.EmployerInfoPhoneNumber__c, c.EmployerInfoMailingAddressZip__c, c.EmployerInfoMailingAddressState__c, c.EmployerInfoMailingAddressLine2__c, 
                                             c.EmployerInfoMailingAddressLine1__c, c.EmployerInfoMailingAddressCity__c, c.EmployerInfoMailaddsameasphysadd__c, c.EmployerInfoLegalName__c, 
                                             c.EmployerInfoIsthisanewMCP__c, c.EmployerInfoIsDBANamethesame__c, c.EmployerInfoIsDBACommonNamethesam__c, c.EmployerInfoFaxNumber__c, 
                                             c.EmployerInfoEmployerTaxIDNumber__c, c.EmployerInfoEffectiveDate__c, c.EmployerInfoDBAName__c, c.DistrictPdImptSTDEliminationPeriod__c, 
                                             c.DistrictPdImptSTDBenefitAmount__c, c.DistrictPdImptLTDEliminationPeriod__c, c.DistrictPdImptLTDBenefitAmount__c, 
                                             c.DistrictPdImptDistrictPayShortTermDis__c, c.DistrictPdImptDistrictPayForLTD__c, c.DistrictPdImptAFAOfferAgencyImpts__c, 
                                             c.DetailsSICTypeofIndustry__c, c.DetailsPleasecheckifanyemployeeres__c, c.DetailsNameofassociation__c, c.DetailsIsGrpmemberofanassociation__c, 
                                             c.DetailsDoesGrpparticipateinAFAS125__c, c.DetailsCommonownershipwithanotherGr__c, c.CreatedDate, c.CreatedById, c.ContactInfoSec125ContactTitle__c, 
                                             c.ContactInfoSec125ContactPhoneNumbe__c, c.ContactInfoSec125ContactName__c, c.ContactInfoSec125ContactExtension__c, 
                                             c.ContactInfoSec125ContactEmail__c, c.ContactInfoFlexContactTitle__c, c.ContactInfoFlexContactPhoneNumber__c, c.ContactInfoFlexContactName__c, 
                                             c.ContactInfoFlexContactExtension__c, c.ContactInfoFlexContactEmail__c, c.ContactInfoAdminContact__c, c.CntctInfoAdminCntctEnrollTmCntctAcct__c, 
                                             c.BillInfoZip__c, c.BillInfoState__c, c.BillInfoPayrollInfoSkipMonths__c, c.BillInfoPayrollInfoPayrollDist__c, 
                                             c.BillInfoPayrollInfoPayDistOtherExp__c, c.BillInfoPayrollInfoNbrofPayPds__c, c.BillInfoPayrollInfoEmpSendTaxStat__c, 
                                             c.BillInfoPayrollInfoDisTax__c, c.BillInfoPayrollInfoCancerTax__c, c.BillInfoPayrollInfoCancerIndTax__c, c.BillInfoPayrollInfoBillModeOtherExp__c, 
                                             c.BillInfoPayrollInfoAnyEmployeesPd__c, c.BillInfoPayrollInfo1stOcc__c, c.BillInfoPayrollDeductions__c, c.BillInfoPayrollDeductionFrequency__c, 
                                             c.BillInfoIsBillnameandaddresssame__c, c.BillInfoIfOtherpleaseexplain__c, c.BillInfoIfMultipleBillsPlsExpln__c, c.BillInfoCity__c, 
                                             c.BillInfoBillSpecialRequirements__c, c.BillInfoBillName__c, c.BillInfoBillMode__c, c.BillInfoBillMethod__c, c.BillInfoAddressLine2__c, 
                                             c.BillInfoAddressLine1__c, c.AnnBeforeTaxZip__c, c.AnnBeforeTaxTPA__c, c.AnnBeforeTaxState__c, c.AnnBeforeTaxPhoneNumber__c, 
                                             c.AnnBeforeTaxNameofTPA__c, c.AnnBeforeTaxMethodofPayment__c, c.AnnBeforeTaxFaxNumber__c, c.AnnBeforeTaxEmployer__c, 
                                             c.AnnBeforeTaxContactName__c, c.AnnBeforeTaxContInfoSameAdminContact__c, c.AnnBeforeTaxCity__c, c.AnnBeforeTaxBranchOfficeNumber__c, 
                                             c.AnnBeforeTaxBillModesStatus__c, c.AnnBeforeTaxBillModesSpecialInstr__c, c.AnnBeforeTaxBillModesAnnual__c, c.AnnBeforeTaxBillModeWhatMonths__c, 
                                             c.AnnBeforeTaxBillModeSkipMonths__c, c.AnnBeforeTaxBillModeSemiMonthly__c, c.AnnBeforeTaxBillModePayDed__c, c.AnnBeforeTaxBillModeMonthly__c, 
                                             c.AnnBeforeTaxBillModeMethodPaytTPA__c, c.AnnBeforeTaxBillModeBiWeekly__c, c.AnnBeforeTaxAddressLine2__c, c.AnnBeforeTaxAddressLine1__c, 
                                             c.AnnBeforeTaxAddressInfothesame__c, c.AnnAfterTaxBillModeSpecialInstr__c, c.AnnAfterTaxBillModePickvalues__c, 
                                             c.AnnAfterTaxBillModePayrollDeds__c, c.AnnAfterTaxBillModeMonths__c, c.AnnAfterTaxBillModeAnnual__c, c.AnnAfterTaxAcctMgrInfTrdIRA__c, 
                                             c.AnnAfterTaxAcctMgrInfTrdIRANbr__c, c.AnnAfterTaxAcctMgrInfRothIRA__c, c.AnnAfterTaxAcctMgrInfRothIRANbr__c, c.AnnAfterTaxAcctMgrInfPhNbr__c, 
                                             c.AnnAfterTaxAcctMgrInfNonQual__c, c.AnnAfterTaxAcctMgrInfNonQualNr__c, c.AnnAfterTaxAcctMgrInfBrchOfNbr__c, c.AnnAfterTaxAcctMgrInfAcctMgr__c, 
                                             c.AnnAfterTaxAcctMgrInfAccMgrNbr__c, c.AnnAfterTaxAcctInfoZip__c, c.AnnAfterTaxAcctInfoState__c, c.AnnAfterTaxAcctInfoSchoolName__c, 
                                             c.AnnAfterTaxAcctInfoPhNbr__c, c.AnnAfterTaxAcctInfoContactName__c, c.AnnAfterTaxAcctInfoCity__c, c.AnnAfterTaxAcctInfoBillZip__c, 
                                             c.AnnAfterTaxAcctInfoBillCity__c, c.AnnAfterTaxAcctInfoBillAddressLine2__c, c.AnnAfterTaxAcctInfoBillAddressLine1__c, 
                                             c.AnnAfterTaxAcctInfoBillAddSame__c, c.AnnAfterTaxAcctInfoAddressLine2__c, c.AnnAfterTaxAcctInfoAddressLine1__c, c.AnnAddanAfterTaxAnnuity__c, 
                                             c.AnnAddaBeforeTaxAnnuity__c, c.AgtInfoWilltherebeaSingleCase__c, c.AgtInfoWhatisthebrokerlegalname__c, c.AgtInfoTakeover__c, 
                                             c.AgtInfoRemotewaresetupto__c, c.AgtInfoNoAcctMngrsinenrollment__c, c.AgtInfoNameofagency__c, c.AgtInfoMainAgtfillingoutthisform__c, 
                                             c.AgtInfoMainAgtNameperformingenroll__c, c.AgtInfoMainAgtName__c, c.AgtInfoMainAgtName__r.Agent_ID__c, c.AgtInfoIsthisatakeover__c, c.AgtInfoIsthisanEDirectEnrollment__c, 
                                             c.AgtInfoIsthereabrokerinvolved__c, c.AgtInfoBrokerstandardcontractapply__c, c.AgtInfoBrokerNumber__c, c.AgtInfoBrokerAffiliatedWithAnAgency__c, 
                                             c.AgtInfoBestmethodofcontact__c, c.AgtInfoAcctMngrAcctMngrName__c, c.AgtInfoAORBrokersameforAFAProd__c, c.ContactInfoBenefitContactSame__c,  
                                             c.ContactInfoBenefitContact__c, c.ContactInfoBillingContactSame__c, c.ContactInfoBillingContact__c,  GrpProdTakeoverOfGroupPlan__c,GrpProdHowwouldyouliketoselectDisplans__c,
                                             GrpProdHowwouldyouliketoselectGrpCIplans__c,GrpProdHowwouldyouliketoselectGAPplans__c,GrpProdLTDEliminationPeriod__c,
                                             GrpProdLTDBenefitPlan__c,GrpProdSTDEliminationPeriod__c,GrpProdSTDBenefitPlan__c,HospitalGAPInfoPlanOption__c,
                                             BillInfoPayrollDedFileDueDate__c,OpnEnrollReasonforRequest__c,OpnEnrollExpectationofOpenEnrollment__c,OpnEnrollPlanCodes__c,GrpProdTrustOrDirect__c,
                                             GrpProdSelectProductsTakingOver__c,GrpProdProvideCarriersofTakeoverProducts__c,GrpProdLTDplanstomatchAccount__c,GrpProdSTDplanstomatchAccount__c,
                                             GrpProdGroupCIplanstomatchAccount__c,GrpProdGAPplanstomatchAccount__c,GrpProdLTDOtherElimination__c,GrpCIGrpCritIllMCH7268PlanCode__c,
                                             GrpProdLTDCustomBenefitPlan__c,GrpProdSTDOtherElimination__c,GrpProdSpouseBenefitAmount__c,
                                             GrpProdSTDCustomBenefitPlan__c,GrpCIGrpCritIll_MCH_7268__c,Request_Edit__c,What_date_does_the_employer_need_to_key__c
                                             
                                             
                                             From Customer_Setup_Form__c c 
                                             WHERE c.Id =: formId];
        if (CSFs.size() > 0){
            csForm = CSFs[0];
            if (csForm.Status__c != null)
                status = csForm.Status__c.toUpperCase();
            setStatusMsg(csForm.Status__c, csForm.Request_Edit__c);
        }
        
        if (csForm != null) {
            loadBillModes();
        }
        
        //Determine whether form is AWD or AFES
        if (csForm != null && csForm.RecordTypeId == awdRT.Id)
            formType = 'AWD';
        else
            formType = 'AFES';
        
        //Determine whether form has been submitted
        if (csForm != null && csForm.Status__c != 'In Progress')
            formIsSubmitted = true;
        else
            formIsSubmitted = false;
        
        //URL from where the form was accessed
        if (ApexPages.currentPage().getParameters().containsKey('retUrl'))
            retUrl = ApexPages.currentPage().getParameters().get('retUrl');

        //Parent Enrollment Form Record
        if (csForm != null && csForm.Enrollment_Form__c != null) {
            this.enrollmentForm = [SELECT Id, Name, Enrollment_Opportunity__c, Status__c FROM Enrollment_Form__c WHERE Id =: csForm.Enrollment_Form__c];
            this.EF = this.enrollmentForm;
        }
        
        //Parent Enrollment Opportunity Record
        if (enrollmentForm != null && enrollmentForm.Enrollment_Opportunity__c != null)
            this.enrollmentOpp = [SELECT Id, Name, AccountId, Administrative_Contact__c, Enrollment_Start_Date__c, Enrollment_End_Date__c, Group_Name__c, Legal_Name__c, 
                                         MCP_Number__c, Tax_ID__c, Additional_MCPs__c, Estimated_Employees__c, Effective_Date_of_Core_Products__c, Effective_Date_of_AFA_Products__c, Employee_Eligibility_Waiting_Period__c, 
                                         Residence_State_s__c, Assigned_Account_Manager__c, Marketed_Products__c,
                                         // jhicks 01/17 - added
                                         Confirm_New_or_Existing_Group__c,Are_you_adding_new_plans_or_services__c,Are_you_making_any_billing_changes__c,Requesting_Open_Enrollment__c
                                   FROM Opportunity WHERE Id =: enrollmentForm.Enrollment_Opportunity__c];
        
        //Sibling Platform Setup Form
        if (enrollmentForm != null && enrollmentForm.Id != null){
            //jhicks 01/17 - added skip month fields  {not sure why there is a loop here}
            for (Platform_Setup__c p : [SELECT Id, Name, PayrollInfo11MoCheck__c,PayrollInfo10MoCheck__c,PayrollInfo9MoCheck__c,PayrollInfoSkipMonths11__c,PayrollInfoSkipMonths10__c,PayrollInfoSkipMonths9__c, Enroll_Info_First_Payroll_Deduction_Date__c,
                                               EnrollInfoPayrollDeductFrequenc__c,Enroll_Info_Payroll_Deduction_Begins__c
                                          FROM Platform_Setup__c WHERE Enrollment_Form__c =: enrollmentForm.Id]){
                platformId = p.Id;
                ps = p;
            }
        }

        //Sibling Section 125 records
        section125count = 0;
        if (enrollmentForm != null && enrollmentForm.Id != null){
            for (Section_125_Setup_Form__c s125 : [SELECT Id, Name FROM Section_125_Setup_Form__c WHERE Enrollment_Form__c =: enrollmentForm.Id])
                section125count++;
        }
        //Sibling Plan Summary form
        if (enrollmentForm != null && enrollmentForm.Id != null){
            for (Section_125_Plan_Summary__c plan : [SELECT Id, Name FROM Section_125_Plan_Summary__c WHERE Enrollment_Form__c =: enrollmentForm.Id])
                planSummaryId = plan.Id;
        }
        
        //Parent Account
        if (enrollmentOpp != null && enrollmentOpp.AccountId != null)
            this.acc = [SELECT Id, Name, Phone, Fax, Eligibile_Employee_Count__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, OwnerId FROM Account WHERE Id =: enrollmentOpp.AccountId];
        
        //Admin Contact pulled from related Opportunity
        if (enrollmentOpp != null && enrollmentOpp.Administrative_Contact__c != null){
            this.adminContact = [SELECT Id, Name, Phone, Email, AccountId, Title, Extension__c FROM Contact WHERE Id =: enrollmentOpp.Administrative_Contact__c];
        }
        
        //Assigned Account Manager pulled from related Opportunity
        if( enrollmentOpp != null && enrollmentOpp.Assigned_Account_Manager__c != null){
            this.ACM = [SELECT Id, Name, Title, Phone, EmployeeNumber, Email, Agent_ID__c, Extension FROM User WHERE Id =: enrollmentOpp.Assigned_Account_Manager__c];
        }

        //Main Agent
        if (csForm != null && csForm.AgtInfoMainAgtName__c != null)
            loadMainAgent(csForm.AgtInfoMainAgtName__c);
        
        System.debug('!!! mainAgent: ' + mainAgent);
        
        if (csForm != null && csForm.AgtInfoMainAgtNameperformingenroll__c != null)
            this.userPerformingEnrollment = [SELECT Id, Name, Title, Phone, EmployeeNumber, Email, Extension FROM User WHERE Id =: csForm.AgtInfoMainAgtNameperformingenroll__c];

        //Related Common Ownership records
        // jhicks 12/16 - moved to separate method
        getCommonRecords();

        //Related Location records
        if (csForm != null && csForm.Id != null){
            locations = [SELECT Id, Name, Legal_Name__c, Location__c, Location__r.Name, Customer_Setup_Form__c,
                                Address_Line_1__c, Adress_Line_2__c, City__c, Employer_Tax_ID_Number__c, State__c, ZipCode__c
                                FROM Location_Form__c WHERE Customer_Setup_Form__c =: CSF.Id];
        }
        //Opportunity Team
        if (csForm != null && csForm.Id != null){
            oppTeam = [SELECT Id, TeamMemberRole, User.Name, User.Network_Id__c FROM OpportunityTeamMember
                        WHERE OpportunityId =: enrollmentOpp.Id AND TeamMemberRole != 'Opportunity Owner'];
        }
        if (csForm != null && csForm.Id != null){
            oppTeamOwner = [SELECT Id, TeamMemberRole, User.Name, User.Network_Id__c FROM OpportunityTeamMember
                        WHERE OpportunityId =: enrollmentOpp.Id AND TeamMemberRole = 'Opportunity Owner'];
        }
        
        System.debug('### Opp Team: ' + oppTeam);
        //jhicks 01/17
        getProducts();
        
        if (products != null)
        {
            System.debug('### Products: ' + products);
        }
        
        if(this.acc != null)
            AccountOwner = [SELECT Id, Name, Title, Phone, EmployeeNumber, Email, Agent_ID__c, Extension FROM User WHERE Id =: acc.OwnerId];
        
        if(csForm.ContactInfoBenefitContactSame__c == 'No' && csForm.ContactInfoBenefitContact__c != null)
            benefitContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: csForm.ContactInfoBenefitContact__c];
        else if(csForm.ContactInfoBenefitContactSame__c == 'Yes' && enrollmentOpp.Administrative_Contact__c != null)
            benefitContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: enrollmentOpp.Administrative_Contact__c];
        
        if(csForm.ContactInfoBillingContactSame__c == 'No' && csForm.ContactInfoBillingContact__c != null)
            billingContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: csForm.ContactInfoBillingContact__c];
        else if(csForm.ContactInfoBillingContactSame__c == 'Yes' && enrollmentOpp.Administrative_Contact__c != null)
            billingContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: enrollmentOpp.Administrative_Contact__c];
        
        system.debug('### benefit contact: ' + benefitContact);
        
        lo = new Location_Form__c();
        lo.Customer_Setup_Form__c = formId;

        otm = new OpportunityTeamMember();
        otm.OpportunityId = enrollmentOpp.Id;
        otm.TeamMemberRole = 'Account Manager';
        
        this.MarketedProducts = getMarketedProducts();
        
        enrollmentMarketedProducts =
            [select Id, Name, products__r.name, products__r.Chassis__c, plan_status__c, products__r.product_family__c
               from Marketed_Product__c
              where enrollment__c = :enrollmentForm.Id];
        
        if(mkProducts == null)
        {            
            mkProducts = new Set<String>();
            for (Marketed_Product__c mp2 : enrollmentMarketedProducts) {
                if (mp2.plan_status__c == 'New') {
                    mkProducts.add(mp2.products__r.name);
                }
            }
        }
        
        // set some default fields
        if(mkProducts.contains('403(b) AFadvantage') || mkProducts.contains('403(b) Fixed') || mkProducts.contains('403(b) AFPrime'))
        {
            CSF.AnnAddaBeforeTaxAnnuity__c = 'Yes';
        }
        else
            CSF.AnnAddaBeforeTaxAnnuity__c = 'No';
        if(mkProducts.contains('457(b) AFmaxx'))
        {
            CSF.AnnAddanAfterTaxAnnuity__c = 'Yes';
        }
        else
            CSF.AnnAddanAfterTaxAnnuity__c = 'No';

        if(mkProducts.contains('Group Cancer')){
            CSF.Adding_Group_Cancer__c = 'Yes';
            hasGroupCancerMarketedProduct = true;
        }

        hasLongTermDisabilityMarketedProduct = mkProducts.contains('Long-Term Disability');
        hasShortTermDisabilityMarketedProduct = mkProducts.contains('Short-Term Disability');
        hasGroupCriticalIllnessMarketedProduct = mkProducts.contains('Group Critical Illness');
        hasHospitalGapMarketedProduct = mkProducts.contains('Hospital GAP');
        
        
        // jhicks 01/17
        getMatchingMCP();
        
        try {
            setDefaultValues();
            setupTabs();
            //setFieldsToDisplay();     
            checkAllRequiredFields();
            getHelpText();
            //setStatusMsg();
        }
        catch(exception e){
            system.debug('    IGNORED EXCEPTION: ' + e);
        }
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
                Marketed_Product__c mp = [select Id from Marketed_Product__c where (products__r.name like '%403(b)%' OR products__r.name like '%457(b)%') and plan_status__c = 'New' and enrollment__c = :enrollmentForm.Id limit 1 ];
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
    
    public void setDefaultValues()
    {
        if(formType == 'AFES')
        {
            if(CSF.DetailsSICTypeofIndustry__c == null)
                CSF.DetailsSICTypeofIndustry__c = 'Education';
        }
    }

    private void loadMainAgent(Id userId) {
        this.mainAgent = [SELECT Id, Name, Title, Phone, EmployeeNumber, Email, Agent_ID__c, Extension FROM User WHERE Id = :userId];
    }
    
    public void performDefaultDMLActions() {
        setMainAgent();
        addDefaultBillMode();
    }

    // jhicks 01/17 - if CS Form Agent is null, assign Account Owner
    public void setMainAgent() {
        if (CSF.AgtInfoMainAgtName__c == null){
            CSF.AgtInfoMainAgtName__c = accountOwner.Id;
            update CSF;
            
            loadMainAgent(CSF.AgtInfoMainAgtName__c);
        }
    }

    public void getCommonRecords() {
       
        if (csForm != null && csForm.Id != null){
            commons = [SELECT Id, Name, Legal_Name__c, DBA_Name__c, Location__c, Location__r.Name, MCP_Setup_Form__c, MCP_Number__c, New_Or_Existing__c,
                       Address_Line_1__c, Address_Line_2__c, City__c, State__c, State_Picklist__c, ZipCode__c, Employer_Tax_ID_Number__c, Related_Employer_under_S125_Plan__c,
                       Contact_Name__c, Contact_Phone_Number__c, Contact_Email__c, Is_the_broker_the_same_as_the_Parent_Acc__c, Broker_Involved__c, Broker_Legal_Name__c,
                       Broker_Number__c, Does_the_Standard_Broker_Contract_Apply__c, Is_the_Broker_Affiliated_with_an_Agency__c, Is_the_Broker_AOR_for_AFA_Products__c,
                       Will_there_be_a_Single_Case_Agreement__c, Name_of_Agency__c
                       FROM Common_Ownership_Form__c WHERE MCP_Setup_Form__c =: CSF.Id Order By CreatedDate];
        }
    }

    public void getProducts() {        
        if (csForm != null && csForm.Id != null){
            products = [SELECT Id, Name, Before_or_After_Tax__c, Customer_Setup_Form__c, Group_Products__c, MCH_Company__c, Plan_Codes_Benefits__c, ProductName__c 
                       FROM Group_Products_Form__c WHERE Customer_Setup_Form__c =: CSF.Id];
        }
    }

    public List<String> getMarketedProducts(){
        List<String> products = new List<String>();
        if(enrollmentOpp.Marketed_Products__c != null)
        {
            products = enrollmentOpp.Marketed_Products__c.split(';');
        }
        return products;        
    }
    
    public void updateCustomerSetupForm()
    {
        showErrorMessages = true;
        try
        {
            //System.debug('### Value: ' + value);
            System.debug('### CSF: ' + CSF);
            if (CSF.Id != null)
                update CSF;
            //else
            //insert smartForm; 
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getMessage()));
        }
    }
    
    public void updatecsForm()
    {
        showErrorMessages = true;
        try
        {
            //System.debug('### Value: ' + value);
            System.debug('### csForm: ' + csForm);
            if (csForm.Id != null)
                update csForm;
            //else
            //insert smartForm;
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getMessage()));
        }        
    }

    public void save() {
        showErrorMessages = true;
        try{
	        update CSF;
	        //setFieldsToDisplay();
	        checkAllRequiredFields();
        }
        catch (dmlexception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getDmlMessage(0)));
        }
    }
    
    public void updatePlatformSetup() {
        showErrorMessages = false;
        try {
            update ps;
            checkAllRequiredFields();
        }
        catch (dmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getDmlMessage(0)));
        }
    }
    
    
    //Update parent account
    public void saveAccount()
    {
        showErrorMessages = true;
        try
        {
            System.debug('### updating Account');
            if (acc != null && acc.Id != null)
                update acc;
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getMessage()));
        }
    }

    //Update Admin Contact record
    public void saveAdminContact()
    {
        showErrorMessages = true;
        try
        {
            System.debug('### updating Admin Contact');
            if (adminContact != null && adminContact.Id != null){
                System.debug('### Admin Contact Phone: ' + adminContact.Phone);
                System.debug('### Admin Contact Email: ' + adminContact.Email);
                
                if (fieldName == 'Extension__c')
                    adminContact.put(fieldName, Decimal.valueOf(fieldValue));
                else
                    adminContact.put(fieldName, fieldValue);
                
                update adminContact;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the Admin Contact. ' + e.getMessage()));
        }
    }

    //Update Main Agent
    public void saveMainAgent()
    {
        showErrorMessages = true;
        try
        {
            System.debug('### updating Main Agent');
            if (mainAgent != null && mainAgent.Id != null){
                System.debug('### fieldName: ' + fieldName);
                System.debug('### fieldValue: ' + fieldValue);
                
                mainAgent.put(fieldName, fieldValue);
                
                update mainAgent;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the Main Agent. ' + e.getMessage()));
        }
    }

    public pageReference SetMainAccountManager()
    {
        showErrorMessages = true;
        try
        {
            if(mainFillingForm == 'Yes')
            {
                this.mainAgent = [SELECT Id, Name, Title, Phone, EmployeeNumber, Email, Agent_ID__c, Extension FROM User WHERE Id =: enrollmentOpp.Assigned_Account_Manager__c];
            }
            else
            {
                this.mainAgent = [SELECT Id, Name, Title, Phone, EmployeeNumber, Email, Agent_ID__c, Extension FROM User WHERE Id =: csForm.AgtInfoMainAgtName__c];
                //csForm.AgtInfoMainAgtName__c = fieldValue;
                update csForm;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the Main Agent. ' + e.getMessage()));
        }
        return null;
    }
    
    public pageReference SetBenefitContact()
    {
        showErrorMessages = true;
        system.debug('### benefit contact: ' + benefitContact);
        system.debug('### benefit Contact Same: ' + benContactSame);
        try
        {
            if(benContactSame == 'No')
            {
                if(csForm.ContactInfoBenefitContact__c != null)
                    this.benefitContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: csForm.ContactInfoBenefitContact__c];    
            }
            else if(benContactSame == 'Yes')
            {
                if(enrollmentOpp.Administrative_Contact__c != null)
                {
                    this.benefitContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: enrollmentOpp.Administrative_Contact__c];
                    csForm.ContactInfoBenefitContact__c = enrollmentOpp.Administrative_Contact__c;
                } 
            }
            csForm.ContactInfoBenefitContactSame__c = benContactSame;
            update csForm;
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the benefit contact. ' + e.getMessage()));
        }
        return null;
    }

    public void saveBenefitContact()
    {
        showErrorMessages = true;
        try
        {
            if (benefitContact != null)
            {                
                if (fieldName == 'Extension__c')
                    benefitContact.put(fieldName, Decimal.valueOf(fieldValue));
                else
                    benefitContact.put(fieldName, fieldValue);
                
                update benefitContact;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the benefit contact. ' + e.getMessage()));
        }
    }

    public pageReference SetBillingContact()
    {
        showErrorMessages = true;
        system.debug('### billing contact: ' + billingContact);
        system.debug('### billing Contact Same: ' + billContactSame);
        try
        {
            if(billContactSame == 'No')
            {
                if(csForm.ContactInfoBenefitContact__c != null)
                    this.billingContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: csForm.ContactInfoBillingContact__c];    
            }
            else if(billContactSame == 'Yes')
            {
                if(enrollmentOpp.Administrative_Contact__c != null)
                {
                    this.billingContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: enrollmentOpp.Administrative_Contact__c];
                    csForm.ContactInfoBillingContact__c = enrollmentOpp.Administrative_Contact__c;
                }    
            }
            csForm.ContactInfoBillingContactSame__c = billContactSame;
            update csForm;
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the benefit contact. ' + e.getMessage()));
        }
        return null;
    }
    
    public void saveBillingContact()
    {
        showErrorMessages = true;
        try
        {
            if (billingContact != null)
            {                
                if (fieldName == 'Extension__c')
                    billingContact.put(fieldName, Decimal.valueOf(fieldValue));
                else
                    billingContact.put(fieldName, fieldValue);
                
                update billingContact;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the billing contact. ' + e.getMessage()));
        }
    }
    
    //Insert new child common ownership record
    //Pull in data from chosen account
    //Account Id is passed from the page
    public void insertCO()
    {
        showErrorMessages = true;
        try
        {
            co = new Common_Ownership_Form__c();
            co.MCP_Setup_Form__c = formId;
            co.New_Or_Existing__c = 'New';
            
            insert co;  
            
            // jhicks 12/16 added this
            getCommonRecords();
            checkAllRequiredFields();
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error inserting Common Ownership. ' + e.getMessage()));
        }
    }

    //Insert new Location record
    public void insertLO()
    {
        showErrorMessages = true;
        try
        {
            //lo.Location__c = locationId;
            insert lo;  
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error inserting a Location. ' + e.getMessage()));
        }
    }

    //insert new Opportunity Team Member record
    //Create new OpportunityShare record so that the new team member will have edit rights on the opp
    public void insertOTM()
    {
        showErrorMessages = true;
        try
        {
            OpportunityTeamMember teamMember = otm;
            teamMember.UserId = managerId;
            insert teamMember;  
            
            // get all of the team members' sharing records
            List<OpportunityShare> shares = [select Id, OpportunityAccessLevel, RowCause from OpportunityShare where OpportunityId =: enrollmentOpp.Id AND RowCause = 'Team Member'];
            
            // set all team members access to read/write
            for (OpportunityShare share : shares){
                share.OpportunityAccessLevel = 'Edit';
            }
            update shares;
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error inserting the Opportunity Team Member. ' + e.getMessage()));
        }    
    }

    //Delete Common Ownership record from the form
    //Id is passed from the form
    public void deleteCommonOwnership()
    {
        showErrorMessages = true;
        try
        {
            if (CommonOwnershipIdToDelete != null)
            {
                Common_Ownership_Form__c coToDelete = [SELECT Id FROM Common_Ownership_Form__c WHERE ID =: CommonOwnershipIdToDelete];
                delete coToDelete;
                
                // jhicks 12/16 added this
                getCommonRecords();
                checkAllRequiredFields();
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error deleting Common Ownership. ' + e.getMessage()));
            System.debug('### ERROR deleting record: ' + e.getMessage());
        }
    }

    //Delete related Location record
    //Id is passed from the page
    public void deleteLocation()
    {
        showErrorMessages = true;
        try
        {
            if (LocationIdToDelete != null)
            {
                Location_Form__c lfToDelete = [SELECT Id FROM Location_Form__c WHERE ID =: LocationIdToDelete];
                delete lfToDelete;
            } 
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error deleting Location. ' + e.getMessage()));
            System.debug('### ERROR deleting record: ' + e.getMessage());
        }
    }

    //Delete Opportunity Team Member Record
    //id is passed from the page
    public void deleteOTM()
    {
        showErrorMessages = true;
        try
        {
            System.debug('### deleting OTM: ' + otmId);
            
            if (otmId != null)
            {
                OpportunityTeamMember oppTeamMember = [SELECT Id, UserId FROM OpportunityTeamMember WHERE ID =: otmId];
                List<OpportunityShare> shares = [SELECT Id FROM OpportunityShare WHERE UserOrGroupId =: oppTeamMember.UserId AND OpportunityId =: enrollmentForm.Id];
                delete oppTeamMember;
                delete shares;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error deleting Opportunity Team Member. ' + e.getMessage()));
            System.debug('### ERROR deleting record: ' + e.getMessage());
        }
    }

    public void saveCommons()
    {
        showErrorMessages = true;
        try
        {
            if (commons != null && commons.size() > 0)
            {
                update commons;
                checkAllRequiredFields();
            } 
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving Common Ownership. ' + e.getMessage()));
        }
    }

    public void saveLocations()
    {
        showErrorMessages = true;
        try
        {
            if (locations != null && locations.size() > 0)
            {
                update locations;
            } 
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating Locations. ' + e.getMessage()));
        }
    }

    //Update field on the form record
    //fieldName and fieldValue are passed from the page
    public void updateField()
    {
        showErrorMessages = true;
        try
        {
            System.debug('### Updating Field... fieldName: ' + fieldName + ' fieldValue: ' + fieldValue);
            if (CSF != null && fieldName != null)
            {
                CSF.put(fieldName, fieldValue);
                update CSF;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating field.' + e.getMessage()));
        }
    }

    //Update field on a group product record
    //Id, Name, and value are passed from the page
    public void updateProductField()
    {
        showErrorMessages = true;
        try
        {
            if (productId != null && fieldName != null)
            {
                Group_Products_Form__c gp = [SELECT ID FROM Group_Products_Form__c WHERE Id =: productId];
                gp.put(fieldName, fieldValue);
                update gp;
                getProducts();
                checkAllRequiredFields();
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating Group Products field.' + e.getMessage()));
        }
    }

    //Update field on a common ownership record
    //Id, Name, and value are passed from the page
    public void updateCommonField()
    {
        showErrorMessages = true;
        try
        {
            if (commonId != null && fieldName != null)
            {
                Common_Ownership_Form__c c = [SELECT ID FROM Common_Ownership_Form__c WHERE Id =: commonId];
                c.put(fieldName, fieldValue);
                update c;
                checkAllRequiredFields();
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating Common Ownership field.' + e.getMessage()));
        }
    }

    //Insert new group product related to the form
    public void newProduct()
    {
        showErrorMessages = true;
        System.debug('### INSERTING new product');
        try{
            Group_Products_Form__c gp = new Group_Products_Form__c();
            gp.Customer_Setup_Form__c = formId;
            insert gp;
            getProducts();
            checkAllRequiredFields();
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error inserting new Group Product.' + e.getMessage()));
            System.debug('### ERROR INSERTING: ' + e.getMessage());
        }
    }

    //Delete Product from the form
    public void deleteProduct()
    {
        showErrorMessages = true;
        try
        {
            System.debug('### productId: ' + productId);
            if (productId != null)
            {
                Group_Products_Form__c gp = [SELECT ID FROM Group_Products_Form__c WHERE Id =: productId];
                delete gp;
                getProducts();
                checkAllRequiredFields();
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error deleting Group Product.' + e.getMessage()));
        }       
    }

    public void updateAccountField()
    {
        showErrorMessages = true;
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating Account field.' + e.getMessage()));
        }
    }

    //Submit Form Method
    //Set Form Status to 'Submitted'
    //Set Enrollment Form Owner to Home Office Queue
    //Generate Form PDF and attach onto parent account record
    public void submitForm()
    {
        showErrorMessages = true;
        try
        {
            System.debug('### Submitting FORM');
            
            Customer_Setup_Form__c cs = [SELECT ID, Status__c FROM Customer_Setup_Form__c WHERE Id =: formId];
            cs.Status__c = 'Submitted';
            
            update cs;
            status = cs.Status__c;
            statusMsg = cs.Status__c;
            formIsSubmitted = true;
            
            update enrollmentForm;
            
            createSalesforceFile();
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error submitting the form.' + e.getMessage()));
        }
    }
    
    public void createSalesforceFile()
    {
        List<String> ContentLinkIds = new List<String>();
        
        ContentLinkIds.add(enrollmentForm.Id);
        ContentLinkIds.add(enrollmentOpp.Id);
        
        PageReference pagePdf = Page.CustomerSetupFormPDF;
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
        cv.title = 'CustomerSetupPDF';
        cv.PathOnClient = 'CustomerSetupPDF.pdf';
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
        
        /*
        Attachment a = new Attachment();
        a.Body = pdfPageBlob;
        // JRR 4/6/15 Save to Opportunity instead of account
        //a.ParentID = acc.Id;        
        a.ParentId = enrollmentOpp.Id;
        a.Name = 'CustomerSetupPDF.pdf';
        a.Description = 'CustomerSetupPDF';
        insert a;
        System.debug('### Attachment: ' + a);
		*/
    }

    public void checkRequiredFieldsAndDisplay() {
        onboardingCheckRequiredFields(true);
        productBillingCheckRequiredFields(true);
        groupPlansRequiredFields(true);
        openEnrollmentCheckRequiredFields(true);
        annuitiesCheckRequiredFields(true);
    }
    
    public void checkAllRequiredFields() {
        onboardingCheckRequiredFields(false);
        productBillingCheckRequiredFields(false);
        groupPlansRequiredFields(false);
        openEnrollmentCheckRequiredFields(false);
        annuitiesCheckRequiredFields(false);
        
        system.debug('::: onboardingTabComplete: ' + onboardingTabComplete);
        system.debug('::: productBillingTabComplete: ' + productBillingTabComplete);
        system.debug('::: groupPlansTabComplete: ' + groupPlansTabComplete);
        system.debug('::: openEnrollmentTabComplete: ' + openEnrollmentTabComplete);
        system.debug('::: annuitiesTabComplete: ' + annuitiesTabComplete);
    }
    
    public void onboardingCheckRequiredFields(boolean showField){
        showErrorMessages = false;
        onboardingTabComplete = true;
        //if tab not displayed, we are done.
        if (!onboardingTabDisplayed)
            return;
            
        // check fields
    
        if (csf.DetailsSICTypeofIndustry__c == null) {
            if (showField) {
                csf.DetailsSICTypeofIndustry__c.addError('Required Field');
            }
            onboardingTabComplete = false;
        }
        
        if (csf.DetailsIsGrpmemberofanassociation__c == null) {
            if (showField) {
                csf.DetailsIsGrpmemberofanassociation__c.addError('Required Field');
            }
            onboardingTabComplete = false;
        }
        
        if(csf.DetailsIsGrpmemberofanassociation__c == 'Yes')
            if (csf.DetailsNameofassociation__c == null) {
                if (showField) {
                    csf.DetailsNameofassociation__c.addError('Required Field');
                }
                onboardingTabComplete = false;
            }
        
        if (csf.AgtInfoMainAgtName__c == null) {
            if (showField) {
                csf.AgtInfoMainAgtName__c.addError('Required Field');
            }
            onboardingTabComplete = false;
        }
        
        if (csf.AgtInfoIsthereabrokerinvolved__c == null) {
            if (showField) {
                csf.AgtInfoIsthereabrokerinvolved__c.addError('Required Field');
            }
            onboardingTabComplete = false;
        }
        
        if (csf.AgtInfoIsthereabrokerinvolved__c == 'Yes') {
            if (csf.AgtInfoWhatisthebrokerlegalname__c == null) {
                if (showField) {
                    csf.AgtInfoWhatisthebrokerlegalname__c.addError('Required Field');
                }
                onboardingTabComplete = false;
            }
            
            if (csf.AgtInfoBrokerAffiliatedWithAnAgency__c == null) {
                if (showField) {
                    csf.AgtInfoBrokerAffiliatedWithAnAgency__c.addError('Required Field');
                }
                onboardingTabComplete = false;
            }
            
            if (csf.AgtInfoAORBrokersameforAFAProd__c == null) {
                if (showField) {
                    csf.AgtInfoAORBrokersameforAFAProd__c.addError('Required Field');
                }
                onboardingTabComplete = false;
            }
            
            if (csf.AgtInfoBrokerstandardcontractapply__c == null) {
                if (showField) {
                    csf.AgtInfoBrokerstandardcontractapply__c.addError('Required Field');
                }
                onboardingTabComplete = false;
            }
            
        }
        system.debug('::: CSF: ' + csf);
        
        /*Luke Freeland 8/8/2017: Steph requested that the related employers between the Section 125 and Customer Setup form have the same required fields
          and behave the same. If any changes need to be made below, it's likely it has to be done in the Section 125 form too. Check with Steph
          or the project manager to confirm.
        */
        // check Common Ownership
        for (Common_Ownership_Form__c co : commons) {

            if (co.New_Or_Existing__c == null) {
                if (showField) {
                    co.New_Or_Existing__c.addError('Required Field');
                }
                onboardingTabComplete = false;
            }
            if (co.New_Or_Existing__c == 'New') {
                if (co.Legal_Name__c == null) {
                    if (showField) {
                        co.Legal_Name__c.addError('Required Field');
                    }
                    onboardingTabComplete = false;
                }
                if (co.Address_Line_1__c == null) {
                    if (showField) {
                        co.Address_Line_1__c.addError('Required Field');
                    }
                    onboardingTabComplete = false;
                }   
                if (co.City__c == null) {
                    if (showField) {
                        co.City__c.addError('Required Field');
                    }
                    onboardingTabComplete = false;
                }
                if (co.State_Picklist__c == null) {
                    if (showField) {
                        co.State_Picklist__c.addError('Required Field');
                    }
                    onboardingTabComplete = false;
                }
                if (co.ZipCode__c == null) {
                    if (showField) {
                        co.ZipCode__c.addError('Required Field');
                    }
                    onboardingTabComplete = false;
                }
                
                // Broker Fields
                
                if(co.Is_the_broker_the_same_as_the_Parent_Acc__c == null) {
                    if(showField) {
                        co.Is_the_broker_the_same_as_the_Parent_Acc__c.addError('Required Field');
                    }
                    onboardingTabComplete = false;
                }
                
                if(co.Is_the_broker_the_same_as_the_Parent_Acc__c == 'No') {
                    
                    if(co.Broker_Involved__c == null) {
                        if(showField) {
                            co.Broker_Involved__c.addError('Required Field');
                        }
                        onboardingTabComplete = false;
                    }
                    
                    if(co.Broker_Involved__c == 'Yes') {
                        
                        if(co.Broker_Legal_Name__c == null) {
                            if(showField) {
                                co.Broker_Legal_Name__c.addError('Required Field');
                            }
                            onboardingTabComplete = false;
                        }
                        
                        if(co.Broker_Number__c == null) {
                            if(showField) {
                                co.Broker_Number__c.addError('Required Field');
                            }
                            onboardingTabComplete = false;
                        }
                        
                        if(co.Is_the_Broker_Affiliated_with_an_Agency__c == null) {
                            if(showField) {
                                co.Is_the_Broker_Affiliated_with_an_Agency__c.addError('Required Field');
                            }
                            onboardingTabComplete = false;
                        }
                        
                        if(co.Is_the_Broker_AOR_for_AFA_Products__c == null) {
                            if(showField) {
                                co.Is_the_Broker_AOR_for_AFA_Products__c.addError('Required Field');
                            }
                            onboardingTabComplete = false;
                        }
                        
                        if(co.Does_the_Standard_Broker_Contract_Apply__c == null) {
                            if(showField) {
                                co.Does_the_Standard_Broker_Contract_Apply__c.addError('Required Field');
                            }
                            onboardingTabComplete = false;
                        }
                    }
                }
            }
            else { 
                if (co.MCP_Number__c == null) {
                    if (showField) {
                        co.MCP_Number__c.addError('Required Field');
                    }
                    onboardingTabComplete = false;
                }
            }
        }
    }

    public void productBillingCheckRequiredFields(boolean showField){
        showErrorMessages = false;
        productBillingTabComplete  = true;
        billModesErrorMessage = '';

        //if tab not displayed, we are done.
        if (!productBillingTabDisplayed)
            return;

        if (csf.What_date_does_the_employer_need_to_key__c == null) {
            if (showField) {
                csf.What_date_does_the_employer_need_to_key__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            productBillingTabComplete = false;
        }  
    
        if (ps.Enroll_Info_First_Payroll_Deduction_Date__c == null) {
            if (showField) {
                ps.Enroll_Info_First_Payroll_Deduction_Date__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            productBillingTabComplete = false;
        }
        
        set<String> requiredFields = getBillModeRequiredFields();
        
        if (BillModes.isEmpty()) {
            if (showField) {
                billModesErrorMessage = NO_BILL_MODES_VAL_MSG;
            }

            productBillingTabComplete = false;
        }
        
        for (Bill_Mode__c bm : BillModes) {
            if (requiredFields.contains(Bill_Mode__c.Benefit_Deduction_Schedule__c.getDescribe().getName()) &&
                bm.Benefit_Deduction_Schedule__c == null) {

                if (showField) {
                    bm.Benefit_Deduction_Schedule__c.addError(REQUIRED_FIELD_MESSAGE);
                }
            
                productBillingTabComplete = false;
            }
            
            if (requiredFields.contains(Bill_Mode__c.What_Months_No_Deductions_Taken__c.getDescribe().getName()) &&
                bm.What_Months_No_Deductions_Taken__c == null) {

                if (showField) {
                    bm.What_Months_No_Deductions_Taken__c.addError(REQUIRED_FIELD_MESSAGE);
                }
            
                productBillingTabComplete = false;
            }

            if (requiredFields.contains(Bill_Mode__c.Other_Information__c.getDescribe().getName()) &&
                bm.Other_Information__c == null) {

                if (showField) {
                    bm.Other_Information__c.addError(REQUIRED_FIELD_MESSAGE);
                }
            
                productBillingTabComplete = false;
            }
        }
    }

    public void openEnrollmentCheckRequiredFields(boolean showField){
        showErrorMessages = false;
        openEnrollmentTabComplete  = true;
        //if tab not displayed, we are done.
        if (!openEnrollmentTabDisplayed)
            return;
       
        if (csf.OpnEnrollReasonforRequest__c == null) {
            if (showField) {
                csf.OpnEnrollReasonforRequest__c.addError('Required Field');
            }
            openEnrollmentTabComplete = false;
        }    
    
        if (csf.OpnEnrollExpectationofOpenEnrollment__c == null) {
            if (showField) {
                csf.OpnEnrollExpectationofOpenEnrollment__c.addError('Required Field');
            }
            openEnrollmentTabComplete = false;
        }    
    
        if (csf.OpnEnrollPlanCodes__c == null) {
            if (showField) {
                csf.OpnEnrollPlanCodes__c.addError('Required Field');
            }
            openEnrollmentTabComplete = false;
        }    
    }
    
    public void annuitiesCheckRequiredFields(boolean showField){
        showErrorMessages = false;
        annuitiesTabComplete  = true;
        //if tab not displayed, we are done.
        if (!annuitiesTabDisplayed)
            return;
     
        if (csf.AnnBeforeTaxAddressInfothesame__c == null) {
            if (showField) {
                csf.AnnBeforeTaxAddressInfothesame__c.addError('Required Field');
            }
            annuitiesTabComplete = false;
        }    
        
        if (csf.AnnBeforeTaxAddressInfothesame__c == 'No'){
            
            if (csf.AnnBeforeTaxAddressLine1__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxAddressLine1__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
            
            if (csf.AnnBeforeTaxCity__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxCity__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
            if (csf.AnnBeforeTaxState__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxState__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
            
            if (csf.AnnBeforeTaxZip__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxZip__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }            
        }
        
        if (csf.AnnAddaBeforeTaxAnnuity__c == null) {
            if (showField) {
                csf.AnnAddaBeforeTaxAnnuity__c.addError('Required Field');
            }
            annuitiesTabComplete = false;
        }    
        
        if (csf.AnnAddaBeforeTaxAnnuity__c == 'Yes')    {

            if (csf.AnnBeforeTaxBillingModes__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxBillingModes__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
            if (csf.AnnBeforeTaxBillModesStatus__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxBillModesStatus__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
                    
            
            if (csf.AnnBeforeTaxBillModePayDed__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxBillModePayDed__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
                    
            
            if (csf.AnnBeforeTaxBillModeSkipMonths__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxBillModeSkipMonths__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }
            
            if(csf.AnnBeforeTaxBillModeSkipMonths__c == 'Yes')
            {
                if (csf.AnnBeforeTaxBillModeWhatMonths__c == null) {
                    if (showField) {
                        csf.AnnBeforeTaxBillModeWhatMonths__c.addError('Required Field');
                    }
                    annuitiesTabComplete = false;
                }    
            }                    
            
            if (csf.AnnBeforeTaxMethodofPayment__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxMethodofPayment__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
                                        
            if (csf.AnnBeforeTaxWhowillsubmitpremiums__c == null) {
                if (showField) {
                    csf.AnnBeforeTaxWhowillsubmitpremiums__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
                                        
            if (csf.AnnBeforeTaxNameofTPA__c == null && csf.AnnBeforeTaxWhowillsubmitpremiums__c == 'TPA') {
                if (showField) {
                    csf.AnnBeforeTaxNameofTPA__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
        }    
        
        if (csf.AnnAddanAfterTaxAnnuity__c == null) {
            if (showField) {
                csf.AnnAddanAfterTaxAnnuity__c.addError('Required Field');
            }
            annuitiesTabComplete = false;
        }
        
        if(csf.AnnAddanAfterTaxAnnuity__c == 'Yes') 
        {            
            if (csf.AnnAfterTaxBilllingMode__c == null) {
                if (showField) {
                    csf.AnnAfterTaxBilllingMode__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
            if (csf.AnnAfterTaxBillModesStatus__c == null) {
                if (showField) {
                    csf.AnnAfterTaxBillModesStatus__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
            if (csf.AnnAfterTaxBillModePayrollDeds__c == null) {
                if (showField) {
                    csf.AnnAfterTaxBillModePayrollDeds__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
            if (csf.AnnAfterTaxBillModeSkipMonths__c == null) {
                if (showField) {
                    csf.AnnAfterTaxBillModeSkipMonths__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }
            
            if(csf.AnnAfterTaxBillModeSkipMonths__c == 'Yes')
            {
                if (csf.AnnAfterTaxBillModeMonths__c == null) {
                    if (showField) {
                        csf.AnnAfterTaxBillModeMonths__c.addError('Required Field');
                    }
                    annuitiesTabComplete = false;
                }                    
            }            
            
            if (csf.AnnAfterTaxMethodofPayment__c == null) {
                if (showField) {
                    csf.AnnAfterTaxMethodofPayment__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
            if (csf.AnnAfterTaxWhowillsubmitpremiums__c == null) {
                if (showField) {
                    csf.AnnAfterTaxWhowillsubmitpremiums__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
            
            if (csf.AnnAfterTaxTPAName__c == null && csf.AnnAfterTaxWhowillsubmitpremiums__c == 'TPA') {
                if (showField) {
                    csf.AnnAfterTaxTPAName__c.addError('Required Field');
                }
                annuitiesTabComplete = false;
            }    
            
        }    
    }
 
    
    public void groupPlansRequiredFields(boolean showField)
    {
        showErrorMessages = false;
        numberRequiredGroupProductsMessage = '';
        groupPlansTabComplete  = true;
        //if tab not displayed, we are done.
        if (!groupPlansTabDisplayed)
            return;
        
        if (csf.GrpProdTakeoverOfGroupPlan__c == null) {
            if (showField) {
                csf.GrpProdTakeoverOfGroupPlan__c.addError('Required Field');
            }
            groupPlansTabComplete = false;
        }    
        
        if(csf.GrpProdTakeoverOfGroupPlan__c == 'Yes')
        {
            if (csf.GrpProdSelectProductsTakingOver__c == null)
            {
                if (showField) {
                    csf.GrpProdSelectProductsTakingOver__c.addError('Required Field');
                }
                groupPlansTabComplete = false;
            }    
            
            
            if (csf.GrpProdProvideCarriersofTakeoverProducts__c == null)
            {
                if (showField) {
                    csf.GrpProdProvideCarriersofTakeoverProducts__c.addError('Required Field');
                }
                groupPlansTabComplete = false;
            }    
        }
        
        // Long term disability required fields
        if(mkProducts.contains('Long-Term Disability'))
        {
            if (csf.GrpProdHowwouldyouliketoselectDisplans__c == null) 
            {
                if (showField) {
                    csf.GrpProdHowwouldyouliketoselectDisplans__c.addError('Required Field');
                }
                groupPlansTabComplete = false;
            }
            
            // Match to existing MCP
            if(csf.GrpProdHowwouldyouliketoselectDisplans__c == 'Match plans to an existing MCP')
            {
                if (csf.GrpProdLTDplanstomatchAccount__c == null)
                {
                    if (showField) {
                        csf.GrpProdLTDplanstomatchAccount__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }
                else if (enrollmentOpp.AccountId != null &&
                         csf.GrpProdLTDplanstomatchAccount__c == enrollmentOpp.AccountId) {
                    if (showField) {
                        csf.GrpProdLTDplanstomatchAccount__c.addError(LTD_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG);
                    }
                    groupPlansTabComplete = false;
                }
            }

            if(csf.GrpProdHowwouldyouliketoselectDisplans__c == 'Provide plan information' && formType == 'AWD')
            {
                if (csf.GrpProdLTDEliminationPeriod__c == null) {
                    if (showField) {
                        csf.GrpProdLTDEliminationPeriod__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }
                
                if (csf.GrpProdLTDEliminationPeriod__c != null && csf.GrpProdLTDEliminationPeriod__c.contains('Other'))
                {
                    if (csf.GrpProdLTDOtherElimination__c == null) {
                        if (showField) {
                            csf.GrpProdLTDOtherElimination__c.addError('Required Field');
                        }
                        groupPlansTabComplete = false;
                    }    
                } 
                
                if (csf.GrpProdLTDBenefitPlan__c == null) {
                    if (showField) {
                        csf.GrpProdLTDBenefitPlan__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }
                
                if (csf.GrpProdLTDBenefitPlan__c != null && csf.GrpProdLTDBenefitPlan__c.contains('Custom'))
                {
                    if (csf.GrpProdLTDCustomBenefitPlan__c == null) {
                        if (showField) {
                            csf.GrpProdLTDCustomBenefitPlan__c.addError('Required Field');
                        }
                        groupPlansTabComplete = false;
                    }    
                }
            }
        }
        
        if(mkProducts.contains('Short-Term Disability'))
        {
            if (csf.GrpProdHowwouldyouliketoselectDisplans__c == null) 
            {
                if (showField) {
                    csf.GrpProdHowwouldyouliketoselectDisplans__c.addError('Required Field');
                }
                groupPlansTabComplete = false;
            }
            
            if(csf.GrpProdHowwouldyouliketoselectDisplans__c == 'Match plans to an existing MCP')
            {
                if (csf.GrpProdSTDplanstomatchAccount__c == null) {
                    if (showField) {
                        csf.GrpProdSTDplanstomatchAccount__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }
                else if (enrollmentOpp.AccountId != null &&
                         csf.GrpProdSTDplanstomatchAccount__c == enrollmentOpp.AccountId) {
                    if (showField) {
                        csf.GrpProdSTDplanstomatchAccount__c.addError(STD_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG);
                    }
                    groupPlansTabComplete = false;
                }
            }
            
            if(csf.GrpProdHowwouldyouliketoselectDisplans__c == 'Provide plan information' && formType == 'AWD')
            {
                if (csf.GrpProdSTDEliminationPeriod__c == null) {
                    if (showField) {
                        csf.GrpProdSTDEliminationPeriod__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }    
                
                if (csf.GrpProdSTDEliminationPeriod__c == 'Other')
                {
                    if (csf.GrpProdSTDOtherElimination__c == null) {
                        if (showField) {
                            csf.GrpProdSTDOtherElimination__c.addError('Required Field');
                        }
                        groupPlansTabComplete = false;
                    }    
                }
                
                if (csf.GrpProdSTDBenefitPlan__c == null) {
                    if (showField) {
                        csf.GrpProdSTDBenefitPlan__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }    
                
                if (csf.GrpProdSTDBenefitPlan__c == 'Custom')
                {
                    if (csf.GrpProdSTDCustomBenefitPlan__c == null) {
                        if (showField) {
                            csf.GrpProdSTDCustomBenefitPlan__c.addError('Required Field');
                        }
                        groupPlansTabComplete = false;
                    }    
                }
            }
        }
        
        // Critical Illness 
        if(mkProducts.contains('Group Critical Illness'))
        {
            if (csf.GrpProdHowwouldyouliketoselectGrpCIplans__c == null) 
            {
                if (showField) {
                    csf.GrpProdHowwouldyouliketoselectGrpCIplans__c.addError('Required Field');
                }
                groupPlansTabComplete = false;
            }
            
            if (csf.GrpProdHowwouldyouliketoselectGrpCIplans__c == 'Match plans to an existing MCP')
            {
                if (csf.GrpProdGroupCIplanstomatchAccount__c == null) {
                    if (showField) {
                        csf.GrpProdGroupCIplanstomatchAccount__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }
                else if (enrollmentOpp.AccountId != null &&
                         csf.GrpProdGroupCIplanstomatchAccount__c == enrollmentOpp.AccountId) {
                    if (showField) {
                        csf.GrpProdGroupCIplanstomatchAccount__c.addError(CI_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG);
                    }
                    groupPlansTabComplete = false;
                }
            }
            
            if (csf.GrpProdHowwouldyouliketoselectGrpCIplans__c == 'Provide plan information' && formType == 'AWD')
            {
                if (csf.GrpCIGrpCritIll_MCH_7268__c == null) {
                    if (showField) {
                        csf.GrpCIGrpCritIll_MCH_7268__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }    
                
                
                if (csf.GrpProdSpouseBenefitAmount__c == null) {
                    if (showField) {
                        csf.GrpProdSpouseBenefitAmount__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }    
                
                
                if (csf.GrpCIGrpCritIllMCH7268PlanCode__c == null) {
                    if (showField) {
                        csf.GrpCIGrpCritIllMCH7268PlanCode__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }    
            }
        }
        
        if(mkProducts.contains('Hospital GAP'))
        {
            if (csf.GrpProdHowwouldyouliketoselectGAPplans__c == null)
            {
                if (showField) {
                    csf.GrpProdHowwouldyouliketoselectGAPplans__c.addError('Required Field');
                }
                groupPlansTabComplete = false;
            }
            
            if (csf.GrpProdHowwouldyouliketoselectGAPplans__c == 'Match plans to an existing MCP')
            {
                if (csf.GrpProdGAPplanstomatchAccount__c == null) {
                    if (showField) {
                        csf.GrpProdGAPplanstomatchAccount__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }
                else if (enrollmentOpp.AccountId != null &&
                         csf.GrpProdGAPplanstomatchAccount__c == enrollmentOpp.AccountId) {
                    if (showField) {
                        csf.GrpProdGAPplanstomatchAccount__c.addError(GAP_MATCH_ACCOUNT_CANT_BE_SAME_AS_ENROLLMENT_ACCT_MSG);
                    }
                    groupPlansTabComplete = false;
                }
            }
            
            if (csf.GrpProdHowwouldyouliketoselectGAPplans__c == 'Provide plan information' && formType == 'AWD')
            {
                if (csf.HospitalGAPInfoPlanOption__c == null) {
                    if (showField) {
                        csf.HospitalGAPInfoPlanOption__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }    
                
                
                if (csf.HospitalGapInfoHospGapPlanAmount__c == null) {
                    if (showField) {
                        csf.HospitalGapInfoHospGapPlanAmount__c.addError('Required Field');
                    }
                    groupPlansTabComplete = false;
                }    
            }
        }
        
        if (formType == 'AFES') {
            Integer numberOfRequiredGroupProducts = 0;

            if (csf.GrpProdHowwouldyouliketoselectDisplans__c == 'Provide product plan codes') {
                ++numberOfRequiredGroupProducts;
            }

            if (csf.GrpProdHowwouldyouliketoselectGrpCIplans__c == 'Provide product plan codes') {
                ++numberOfRequiredGroupProducts;
            }

            if (csf.GrpProdHowwouldyouliketoselectGAPplans__c == 'Provide product plan codes') {
                ++numberOfRequiredGroupProducts;
            }
            
            if (products.size() < numberOfRequiredGroupProducts) {
                if (showField) {
                    String verb = numberOfRequiredGroupProducts == 1 ? 'is ' : 'are ';
                    numberRequiredGroupProductsMessage = 'At least ' + numberOfRequiredGroupProducts + ' plan code(s) ' + verb + 'required. One for each plan detail with "Provide product plan codes".';
                } 
                
                groupPlansTabComplete = false;
            }
            
            if (numberOfRequiredGroupProducts > 0) {
	            for (Group_Products_Form__c p : products) {
	                if (p.Group_Products__c == null ) {
	                    if (showField) {
	                        p.Group_Products__c.addError('Required Field');
	                    }
	                    groupPlansTabComplete = false;
	                }    
	                if (p.ProductName__c == null) {
	                    if (showField) {
	                        p.ProductName__c.addError('Required Field');
	                    }
	                    groupPlansTabComplete = false;
	                }    
	                if (p.MCH_Company__c == null) {
	                    if (showField) {
	                        p.MCH_Company__c.addError('Required Field');
	                    }
	                    groupPlansTabComplete = false;
	                }    
	                if (p.Plan_Codes_Benefits__c == null) {
	                    if (showField) {
	                        p.Plan_Codes_Benefits__c.addError('Required Field');
	                    }
	                    groupPlansTabComplete = false;
	                }
	            }
            }
        }
        
        
    }
    
    public void getHelpText() {
        // map of all fields in the object
        Map<String, Schema.SObjectField> objectFields =  schema.SObjectType.Customer_Setup_Form__c.fields.getMap();
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
        
        // Platform Setup Form fields
        objectFields =  schema.SObjectType.Platform_Setup__c.fields.getMap();
        fields = objectFields.keyset();
        for(String field : fields){
            Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
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
                system.debug('CSF status: ' + csf.Status__c);
                if(csf.Status__c != 'Submitted' && csf.Status__c != 'In Progress')
                    csf.Request_Edit__c = true;
                else
                    csf.Status__c = 'In Progress';
            }
            else
                csf.Request_Edit__c = false;
            
            update csf;
            
            setStatusMsg(csf.Status__c, csf.Request_Edit__c);
        }
    }
    
    public void insertBillMode() {
        Bill_Mode__c billModeToAdd = new Bill_Mode__c(
            RecordTypeId = Constants.BILL_MODES_PRODUCT_BILLING,
            Customer_Setup_Form__c = formId
        );
        
        insert billModeToAdd;
        
        BillModes.add(billModeToAdd);
        
        checkAllRequiredFields();
    }
    
    public void removeBillMode() {
        if (BillModeIdToRemove != null) {
            delete new Bill_Mode__c(Id = BillModeIdToRemove);
            loadBillModes();
            checkAllRequiredFields();
        }
    }
    
    public void updateBillMode() {
        if (BillModeIdToUpdate != null) {
            for (Bill_Mode__c bm : BillModes) {
                if (bm.Id == BillModeIdToUpdate) {
                    update bm;
                    checkAllRequiredFields();
                    break;
                }
            }
        }
    }
    
    private void setStatusMsg() {
        
        statusMsg = csf.status__c;
        if (csf.Request_Edit__c)
            statusMsg += ' - Request To Edit Sent';
    }
    
    private void setStatusMsg(String s, boolean r) {
        
        statusMsg = s;
        if (r)
            statusMsg += ' - Request To Edit Sent';
        
        if(s == 'In Progress')
            formIsSubmitted = false;
        else
            formIsSubmitted = true;
    }
    
    private void loadBillModes() {
        Set<String> billModeFields = Util.getFieldSetFields(SObjectType.Bill_Mode__c.FieldSets.Product_Billing);
        Id csfId = CSF.Id;
        
        String billModesSOQL = 'SELECT Id, ' + String.join(new List<String>(billModeFields), ',') +
                               '  FROM Bill_Mode__c ' +
                               ' WHERE Customer_Setup_Form__c = :csfId';

        BillModes = Database.query(billModesSOQL);
    }

    private set<String> getBillModeRequiredFields() {
        // Luke Freeland 4/21/2017
        // Allow the list of required fields to be overridable via tests.
        if (TestBillModeRequiredFields != null &&
            !TestBillModeRequiredFields.isEmpty()) {
            return TestBillModeRequiredFields;
        }
        
        List<Schema.FieldSet> requiredFieldSetsToCheck = new List<Schema.FieldSet>{
            SObjectType.Bill_Mode__c.FieldSets.Product_Billing
        };
        
        Map<String, Schema.FieldSetMember> requiredFSMs = getRequiredFieldSetMembers(requiredFieldSetsToCheck);
        
        return requiredFSMs.keySet();
    }
    
    private void addDefaultBillMode() {
        if (productBillingTabDisplayed &&
            BillModes.isEmpty()) {
            insertBillMode();
        }
    }
}