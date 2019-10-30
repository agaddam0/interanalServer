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
public with sharing class GeneralInformationController extends PreEnrollmentControllerBase {
    public static final String ONLY_1_VISION_IMPORT_PRODUCT_ALLOWED_VAL_MSG = 'Only 1 vision imported product can be selected.';
    public static final String ONLY_1_LIFE_IMPORT_PRODUCT_ALLOWED_VAL_MSG = 'Only 1 life imported product can be selected.';
    public static final String INVALID_EIN_FORMAT_VAL_MSG = 'The tax id (EIN) must be 9 digits long or 2 digits followed by a dash followed by 7 more digits. For example, 12-1918761 or 121918761.';
    public static final String ONLY_1_ACCIDENT_PRODUCT_ALLOWED_VAL_MSG = 'Only 1 accident product can be selected.';
    public static final String ENROLLMENT_PATH_REQUIRED_VAL_MSG = 'An enrollment path is required.';
    public static final String ENROLLMENT_END_DATE_AFTER_START_DATE_VAL_MSG = 'The enrollment end date must be on or after the enrollment start date.';
  
    //public variables available to pull/push into form
    public Opportunity eOppty                                   {get;set;}   //enrollment Opportunity
    public Account acc                                          {get;set;}
    public Platform_Setup__c  ps                                {get;set;}
    public Customer_Setup_Form__c  cs                           {get;set;}
    public Section_125_Setup_Form__c  s125                      {get;set;}
    public String formType                                      {get;set;} 
    public string clickProductsTab                              {get;set;}
    public String fieldName                                     {get;set;}
    public String fieldValue                                    {get;set;}
    public String accountId                                     {get;set;}
    public boolean showErrorMessages                            {get;set;}
    public List <Marketed_Product__c> mProducts_ben             {get;set;}    // Benefits Marketed Product List
    public List <Marketed_Product__c> mProducts_svc             {get;set;}    // Service Marketed Product List
    public List <Marketed_Product__c> mProducts_imp             {get;set;}    // Import Marketed Product List
    private List <Product_Catalog__c>  pCatalog_ben;                          // Product Catalog for benefits
    private List <Product_Catalog__c>  pCatalog_svc;                          // Product Catalog forservices
    public List <catalogWrapper>       catalogWrapper_ben       {get;set;}    // Product Catalog for benefit products
    public List <catalogWrapper>       catalogWrapper_svc       {get;set;}    // Product Catalog for service products
    private List <Product_Catalog__c>  pCatalog_imp;                               // Product Catalog for Import
    public List <catalogWrapper>  catalogWrapper_imp            {get;set;}    // Product Catalog for Import
    public string productId                                     {get;set;}    // for deletion of product
    public boolean detailsTabComplete                           {get;set;}    // indicates that all required fields on tab are complete
    public boolean productTabComplete                           {get;set;}    // indicates that all required fields on tab are complete
    public boolean enrollmentTabComplete                        {get;set;}    // indicates that all required fields on tab are complete
    public boolean addProductError                              {get;set;}    // indicates an error while adding products
    public string addProductErrorMessage                        {get;set;}
    
    public Contact adminContact                                 {get;set;}
    public Contact benefitContact                               {get;set;}
    public Contact billingContact                               {get;set;}
    public Contact annuityContact                               {get;set;}
    public Contact s125Contact                                  {get;set;}
    public Contact flexContact                                  {get;set;}
    public Contact hsaContact                                   {get;set;}
    public List<OpportunityTeamMember> oppTeam                  {get;set;}
    public List<OpportunityTeamMember> oppTeamOwner             {get;set;}
    public String managerId                                     {get;set;}
    public OpportunityTeamMember otm                            {get;set;}
    public Id otmId                                             {get;set;}
    public string requiredContacts                              {get;set;}
    public string newContactFirstName                           {get;set;}    
    public string newContactLastName                            {get;set;}
    public string newContactTitle                               {get;set;}
    public string newContactEmail                               {get;set;}    
    public string newContactPhone                               {get;set;}    
    public string newContactExt                                 {get;set;}    
    
    public string contactId                                     {get;set;}
    public string contactType                                   {get;set;}
    public boolean confirmSuccessful                            {get; set;}
    public Event enrollmentEvent                                {get; set;}  // event template
    public string evId                                          {get; set;}  // actual event Id
    public string enrollmentStart                               {get; set;}
    public string enrollmentEnd                                 {get; set;}
    public string navToEnrollment                               {get; set;}
    
    public List<Enrollment_Path__c> enrollmentPaths             {get; set;}
    public Id selectedEnrollmentPathId                          {get; set;}
    public Boolean enrollmentRushRequested                      {get; set;}
    public String enrollmentPathRequiredMessage                 {get; set;}
    public Boolean enrollmentEmployeeThresholdShort             {get; set;}
    public String enrollmentEmployeeShortMessage                {get; set;}
    public Boolean wasPreviouslySubmitted                       {get; set;}
    public Boolean payrollDueDateRushed                         {get; set;}  
    
    @testVisible
    private Set<String> testRequiredPlatformSetupFields         {get; set;}
    
    /* jhicks - needed for all forms */
    public string statusMsg                                     {get; set;}
    public boolean formIsSubmitted                              {get; set;}
    public boolean formRequestToEdit                            {get; set;}
    /* jhicks - needed for all forms */

    
    public Map<string,string>  hMap                             {get; set;}
    
    // older way of determining reservice: Not an indication it CAME from the
    // reservice form with significant changes.  That variable is in the
    // base class
    public Boolean IsReservice {
        get {
            return eOppty != null &&
                   eOppty.Confirm_New_or_Existing_Group__c == 'Existing' &&
                   String.isNotBlank(eOppty.Account.MCP_Number__c) &&
                   eOppty.Account.Status__c == 'Active';
        }
    }
    
    public Boolean IsNewSetup {
        get {
            return eOppty != null &&
                   eOppty.Confirm_New_or_Existing_Group__c == 'New' &&
                   String.isBlank(eOppty.Account.MCP_Number__c);
        }
    }
    
    public Integer NumberExistingMarketedProducts {
        get {
            Integer existingMarketedProductsCount = 0;

            if (mProducts_ben != null) {
                existingMarketedProductsCount += mProducts_ben.size();
            }

            if (mProducts_svc != null) {
                existingMarketedProductsCount += mProducts_svc.size();
            }

            if (mProducts_imp != null) {
                existingMarketedProductsCount += mProducts_imp.size();
            }

            return existingMarketedProductsCount;
        }
    }
    
    public String EnrollmentPathPlatformSetupFieldSet {
        get {
            String platformSetupFieldSet = '';
            
            if (eOppty == null ||
                String.isBlank(eOppty.Enrollment_Path__c)) {
                return platformSetupFieldSet;
            }
            
            if (enrollmentPaths == null ||
                enrollmentPaths.isEmpty()) {
                loadEnrollmentPaths();
            }

            Enrollment_Path__c enrollmentPath = (Enrollment_Path__c) CollectionUtil.findRecordById(enrollmentPaths, eOppty.Enrollment_Path__c);
            
            if (enrollmentPath != null &&
                String.isNotBlank(enrollmentPath.Platform_Setup_Field_Set__c)) {
                platformSetupFieldSet = enrollmentPath.Platform_Setup_Field_Set__c;
            }
            
            return platformSetupFieldSet;
        }
    }

    //Construtor gathers data from form record and related records
    
    public GeneralInformationController(ApexPages.StandardController stdController) {
        addExtraFieldsToStandardController(stdController);

        this.eOppty = (Opportunity)stdController.getRecord();
            
        system.debug(eOppty);
        getHelpText();
    }

    public String getMarketingInformationSectionLabel() {
        return SObjectType.Opportunity.FieldSets.Marketing_Information.getLabel();
    }
    
    public void doNothing() {
        system.debug(':::doNothing called');
    }

    public void init() {

        getDetailsData();
        getProductData();
        getProductCatalog();
        getContactData();
        getOpptyTeam();
        setRequiredContacts();
        loadEnrollmentPaths();
        setEnrollmentRushRequested();
        setEnrollmentEmployeeThresholdInfo();
        setPayRollUploadRushed();
        setDefaultEnrollmentPath();
        setTabColors();
        setStatusMsg();
        setupEnrollmentEvent();
        setDefaults();
        setCameFromReserviceFlag();

        clickProductsTab = ApexPages.currentPage().getParameters().containsKey('clickProductsTab') ? ApexPages.currentPage().getParameters().get('clickProductsTab') : '0';
        ApexPages.currentPage().getParameters().put('clickProductsTab','0'); // clear it out
        showErrorMessages = true;
        confirmSuccessful = false;
    }
    
    public void setupEnrollmentEvent() {
        enrollmentEvent = new Event (
            whatId = eOppty.Id,
            subject = 'Enrollment - ' + acc.name,
            showas = 'Busy',
            type__c = 'Meeting'     // sets up sub-type picklist
        );

    }

    public pageReference createEnrollmentEvent() {
        Event ev = enrollmentEvent.clone();   // get defaults plus bound fields from dialog
        
        string startdatetime = enrollmentStart.replace('T',' ');
        startdatetime = startdatetime+':00';
        
        string enddatetime = enrollmentEnd.replace('T',' ');
        enddatetime = enddatetime+':00';
        
        ev.STARTdatetime = datetime.valueOf(startdatetime);
        ev.ENDdatetime = datetime.valueOf(enddatetime);
          system.debug('::: enrollmentEvent: ' + ev);
        
        try {
            insert ev;
            evId = ev.Id;
            if(navToEnrollment == 'Yes')
                return new pageReference('/' + evId + '/e?retURL=/apex/GeneralInformation?id=' + eOppty.Id);
            else
                return null;
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
            showErrorMessages = true;
        }
        
        return null;
    }
    
    /* jhicks - this function should be in all forms */
    private void setStatusMsg() {
        
        statusMsg = ef.status__c;
        if (ef.Request_Edit__c){
            statusMsg += ' - Request To Edit Sent';
            formRequestToEdit = true;
        }
         
        if (ef.status__c == 'Confirmed' || ef.status__c == 'Completed')
            formIsSubmitted = true;
    }
 
    private void setRequiredContacts() {
        
        // determine which Contacts are required
        requiredContacts = 'admin;';

        if (eOppty.Confirm_New_or_Existing_Group__c == 'New' || eOppty.Are_you_making_any_billing_changes__c == 'Yes')
            requiredContacts += 'billing;';
             
        if (eOppty.Confirm_New_or_Existing_Group__c == 'New')
            requiredContacts += 'benefit;';
            
        for (Marketed_Product__c mp : mProducts_svc){
            if(mp.products__r.name == 'Section 125' && mp.plan_status__c == 'New')  {
                requiredContacts += 's125;';
            }
            if(mp.products__r.name.containsIgnoreCase('FSA') && mp.plan_status__c == 'New'){  
                requiredContacts += 'flex;';
            }
            if(mp.products__r.name.containsIgnoreCase('HSA') && mp.plan_status__c == 'New'){  
                requiredContacts += 'hsa;';
            }
        }
         
        for (Marketed_Product__c mp : mProducts_ben){
             
            if((mp.products__r.name == '403(b) AFadvantage' || mp.products__r.name == '403(b) AFPrime'
               || mp.Products__r.Name == '403(b) Fixed Annuity' || mp.Products__r.Name == '457(b) AFmaxx') && mp.plan_status__c == 'New'){  
                requiredContacts += 'annuity;';
            }
        }
 
        system.debug('::: Required Contacts: ' + requiredContacts);
        
    }
    
 
    
    // save enrollment opportunity
    public void save() {
        system.debug('::: saving eOppty');
        try
        {     
            update eOppty;
            detailsCheckRequiredFields(false);
            setEnrollmentRushRequested();
            setPayRollUploadRushed();
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
            showErrorMessages = true;
        }

        system.debug('::: eOppty after save: ' + eOppty);
    }
   
    public void updateSkipMonths() {
        // method to update Skip Months checkboxes
         
        try
        {
            update ps;
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getMessage()));
             showErrorMessages = true;
        }
    }
    
    public void updatePlatformSetupForEnrollmentPath() {
        try
        {
            update ps;
            detailsCheckRequiredFields(false);
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getMessage()));
             showErrorMessages = true;
        }
    }

    // get data from other tables 
    private void getDetailsData() {
        
        // Get enrollment record
        Id efRType = [SELECT Id FROM RecordType WHERE sObjectType = 'Enrollment_Form__c' AND DeveloperName = 'Master'].Id; 
        ef = [select Id, Enrollment_Opportunity__c,  Division__c, status__c, request_edit__c, Platform_Setup_Status__c, Customer_Setup_Form_Status__c, Section_125_Status__c, General_Information_First_Submitted_Date__c from Enrollment_Form__c where Enrollment_Opportunity__c = :eOppty.Id AND RecordTypeId =: efRType];
 
        wasPreviouslySubmitted = ef.General_Information_First_Submitted_Date__c != null;
 
        // for legacy records
        if (ef.status__c == null){
            ef.status__c = 'In Progress';
            update ef;
        }
        
        // Get Account Info
        this.acc = [SELECT Id, Name,  Phone, Fax, Eligibile_Employee_Count__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Payroll_Company__c,
                    Physical_Address_Same_As_Billing__c FROM Account WHERE Id =: eOppty.AccountId];

        // Get Platform Info
        try {
            this.ps = getPlatformSetup();
 
        }
        catch(exception e) {
            ps = new Platform_Setup__c();   //placeholder
        }

        try {
            this.cs = [SELECT Id, ContactInfoBenefitContactSame__c, ContactInfoBillingContactSame__c, ContactInfoBenefitContact__c, ContactInfoBillingContact__c,
                    Annuity_Contact__c, AnnBeforeTaxContInfoSameAdminContact__c
                    from Customer_Setup_Form__c where Enrollment_Form__c = :ef.Id limit 1];
        }
        catch(exception e) {
            cs = new Customer_Setup_Form__c();
        }
                    
        // S125
        try {
            this.s125 = [select Id, s125S125ContactSameAsAdmin__c, ContactInfoS125Contact__c, s125FlexContactSameAsAdmin__c,ContactInfoFlexContact__c, HlthSvgsAcctIsHSAcontactsameasAdmin__c, HlthSvgsAcctEligReq__c
                    from Section_125_Setup_Form__c where Enrollment_Form__c = :ef.Id  limit 1];
        }
        catch (exception e) {
            this.s125 = new Section_125_Setup_Form__c();
        }
    }

    private void getProductData() {
        mProducts_ben = [Select Id,Tax_Treatment__c, Product_Description__c, Plan_Status__c, Family__c,  Carrier__c, AOR__c, 
                               products__r.name, products__r.Tax_Treatment__c, products__r.Order__c, products__r.Rider__c,products__r.Type__c,
                               Include_on_Employer_Benefits_Site__c, Carrier_URL__c, Employer_Paid_Portion__c, products__r.Is_Tax_Treatment_Editable__c, products__r.Product_Family__c,
                               products__r.Employer_Benefits_Site_Eligible__c
                          From Marketed_Product__c 
                         where enrollment__c = :ef.Id and products__r.Type__c = 'Benefit'
                           and products__r.Allowed_To_Be_Added_To_Enrollment__c = true
                         order by products__r.Order__c];
 
        mProducts_svc = [Select Id, Tax_Treatment__c, Product_Description__c, Plan_Status__c, Family__c,  Carrier__c, AOR__c, 
                               products__r.name, products__r.Tax_Treatment__c, products__r.Order__c, products__r.Rider__c,products__r.Type__c,
                               Include_on_Employer_Benefits_Site__c, Carrier_URL__c, Employer_Paid_Portion__c, products__r.Is_Tax_Treatment_Editable__c, products__r.Product_Family__c,
                               products__r.Employer_Benefits_Site_Eligible__c
                          From Marketed_Product__c 
                         where enrollment__c = :ef.Id and products__r.Type__c = 'Service'
                           and products__r.Allowed_To_Be_Added_To_Enrollment__c = true
                         order by products__r.Order__c];
 
        mProducts_imp = [Select Id, Tax_Treatment__c, Product_Description__c, Plan_Status__c, Family__c,  Carrier__c, AOR__c, 
                               products__r.name, products__r.Tax_Treatment__c, products__r.Order__c, products__r.Rider__c,products__r.Type__c,
                               Include_on_Employer_Benefits_Site__c, Carrier_URL__c, Employer_Paid_Portion__c, products__r.Is_Tax_Treatment_Editable__c, products__r.Product_Family__c,
                               products__r.Employer_Benefits_Site_Eligible__c
                          From Marketed_Product__c 
                         where enrollment__c = :ef.Id and products__r.Type__c = 'Import'
                           and products__r.Allowed_To_Be_Added_To_Enrollment__c = true
                         order by products__r.Order__c];
                             
        setRequiredContacts();
        productCheckRequiredFields();
        system.debug('::: no. marketed products: ' + (mproducts_ben.size()+mproducts_svc.size()+mproducts_imp.size())); 
         
    }
    
    private void getContactData() {

        //Admin Contact pulled from related Opportunity
        if (eOppty != null && eOppty.Administrative_Contact__c != null){
            this.adminContact = [SELECT Id, Name, Phone, Email, AccountId, Title, Extension__c FROM Contact WHERE Id =: eOppty.Administrative_Contact__c limit 1];
        }
        if (this.adminContact == null)
            this.adminContact = new Contact();
        
        if(cs.ContactInfoBillingContact__c != null)
            this.billingContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: cs.ContactInfoBillingContact__c limit 1];

        if (this.billingContact == null)
            this.billingContact = new Contact();
 
        if(cs.Annuity_Contact__c != null)
            this.annuityContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: cs.Annuity_Contact__c limit 1];

        if (this.annuityContact == null)
            this.annuityContact = new Contact();
 
        if(cs.ContactInfoBenefitContact__c != null)
            this.benefitContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: cs.ContactInfoBenefitContact__c limit 1];

        if (this.benefitContact == null)
            this.benefitContact = new Contact();
 
        if(s125.ContactInfoS125Contact__c != null)
            this.s125Contact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: s125.ContactInfoS125Contact__c limit 1];

        if (this.s125Contact == null) {
            system.debug('::: s125Contact was null and so new was created');
            this.s125Contact = new Contact();
        }

        if(s125.ContactInfoFlexContact__c != null)
            this.flexContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: s125.ContactInfoFlexContact__c limit 1];

        if (this.flexContact == null)
            this.flexContact = new Contact();
            
        if(s125.HlthSvgsAcctEligReq__c != null)
            this.hsaContact = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id =: s125.HlthSvgsAcctEligReq__c limit 1];

        if (this.hsaContact == null)
            this.hsaContact = new Contact(); 
    }

    private void getOpptyTeam() {

        oppTeam = [SELECT Id, TeamMemberRole, UserId, User.Name, User.Email, User.Phone,OpportunityAccessLevel,user.Network_Id__c,user.Agent_ID__c  FROM OpportunityTeamMember
                        WHERE OpportunityId =: eOppty.Id AND TeamMemberRole != 'Opportunity Owner'];
        if (oppTeam == null)
            oppTeam = new List<OpportunityTeamMember>();

        oppTeamOwner = [SELECT Id, TeamMemberRole, User.Name, User.Email, User.Phone, OpportunityAccessLevel,user.Network_Id__c,user.Agent_ID__c FROM OpportunityTeamMember
                        WHERE OpportunityId =: eOppty.Id AND TeamMemberRole = 'Opportunity Owner'];
        if (oppTeamOwner == null)
            oppTeamOwner = new List<OpportunityTeamMember>();
 
        // from old CustomerSetupForm
          
        otm = new OpportunityTeamMember();
        otm.OpportunityId = eOppty.Id;
        otm.TeamMemberRole = 'Account Manager';
    }
   
    private void getProductCatalog() {
   
        pCatalog_ben = [Select Id, Tax_Treatment__c, Plan_Status__c, Name, Is_Tax_Treatment_Editable__c, Product_Family__c, Employer_Benefits_Site_Eligible__c, Rider__c
                          from Product_Catalog__c
                         where Status__c = 'Active'
                           and (Division_Availability__c = 'Both' or Division_Availability__c = :ef.Division__c)
                           and Type__c = 'Benefit'
                           and Id not in (select products__c from Marketed_Product__c where Enrollment__c = :ef.Id)
                           and Allowed_To_Be_Added_To_Enrollment__c = true
                           and States_Available__c INCLUDES(:acc.BillingState)
                        order by order__c];
 
        pCatalog_svc = [Select Id, Tax_Treatment__c, Plan_Status__c, Name, Is_Tax_Treatment_Editable__c, Product_Family__c, Employer_Benefits_Site_Eligible__c, Rider__c
                          from Product_Catalog__c
                         where Status__c = 'Active'
                           and (Division_Availability__c = 'Both' or Division_Availability__c = :ef.Division__c)
                           and Type__c = 'Service'
                           and Id not in (select products__c from Marketed_Product__c where Enrollment__c = :ef.Id)
                           and Allowed_To_Be_Added_To_Enrollment__c = true
                           and States_Available__c INCLUDES(:acc.BillingState)
                        order by order__c];
           
           
        catalogWrapper_ben = new List<catalogWrapper>();
       
       // Set the value for the plan status
       
        String defImportStatus;
        String defServiceStatus;
        String defBenefitStatus;

        if(eOppty.Confirm_New_or_Existing_Group__c == 'Existing') {
            defImportStatus = 'Existing';
            defServiceStatus = 'Existing';
            defBenefitStatus = 'Existing';

            if(eOppty.Are_you_adding_new_plans_or_services__c != null)
            {
                if(eOppty.Are_you_adding_new_plans_or_services__c.contains('No Changes')) {
                    defImportStatus = 'Existing';
                    defServiceStatus = 'Existing';
                    defBenefitStatus = 'Existing';
                }

                if(eOppty.Are_you_adding_new_plans_or_services__c.contains('New Individual Plans') ||
                   eOppty.Are_you_adding_new_plans_or_services__c.contains('New Group Plans') ||
                   eOppty.Are_you_adding_new_plans_or_services__c.contains('New Annuity Plans')) {

                    defBenefitStatus = '';
                }

                if(eOppty.Are_you_adding_new_plans_or_services__c.contains('New Service Plans')) {
                    defServiceStatus = '';
                }
            }
        }
        else {
            defImportStatus = 'New';
            defServiceStatus = 'New';
            defBenefitStatus = 'New';
        }
       
        for (Product_Catalog__c p : pCatalog_ben )    {
            p.Plan_Status__c = defBenefitStatus;
            catalogWrapper_ben.add(new catalogWrapper(p));
        }            
           
        catalogWrapper_svc = new List<catalogWrapper>();    
        for (Product_Catalog__c p : pCatalog_svc )    {
            p.Plan_Status__c = defServiceStatus;
            catalogWrapper_svc.add(new catalogWrapper(p));
        }  

        pCatalog_imp = [Select Id, Tax_Treatment__c, Plan_Status__c, Name, aor__c,Carrier__c,Product_Description__c, Is_Tax_Treatment_Editable__c, Product_Family__c, Employer_Benefits_Site_Eligible__c, Rider__c
                          from Product_Catalog__c
                         where Status__c = 'Active' and (Division_Availability__c = 'Both' or Division_Availability__c = :ef.Division__c)
                           and Type__c = 'Import'
                           and Id not in (select products__c from Marketed_Product__c where Enrollment__c = :ef.Id)
                           and Allowed_To_Be_Added_To_Enrollment__c = true
                           and States_Available__c INCLUDES(:acc.BillingState)
                        order by order__c];
                               
        catalogWrapper_imp = new List<catalogWrapper>();    
        for (Product_Catalog__c p : pCatalog_imp )    {
            p.Plan_Status__c = defImportStatus;
            catalogWrapper_imp.add(new catalogWrapper(p));
        }        
    } 
   
    // add selected products from Catalog to Marketed Products
    public void addSelectedProducts() {
        List<Marketed_Product__c> newProducts = new List<Marketed_Product__c>();
        addProductError = false;
        addProductErrorMessage = '';
        Integer numberOfAccidentProductsToAdd = 0;
         
        for (catalogWrapper  c : catalogWrapper_ben) {
            if (c.addProduct) {
                newProducts.add( new Marketed_Product__c(
                    enrollment__c = ef.Id,
                    Products__c = c.pCatalog.Id,
                    Tax_Treatment__c = c.pCatalog.Tax_Treatment__c,
                    Plan_Status__c = c.pCatalog.Plan_Status__c,
                    Include_on_Employer_Benefits_Site__c = c.pCatalog.Employer_Benefits_Site_Eligible__c == true
                ));

                if (c.pCatalog.Product_Family__c == 'Accident' &&
                    c.pCatalog.Rider__c == false) {
                    ++numberOfAccidentProductsToAdd;
                }
            }
        }
             
        for (catalogWrapper  c : catalogWrapper_svc) {
            if (c.addProduct) {
                newProducts.add( new Marketed_Product__c(
                    enrollment__c = ef.Id,
                    Products__c = c.pCatalog.Id,
                    Tax_Treatment__c = c.pCatalog.Tax_Treatment__c,
                    Plan_Status__c = c.pCatalog.Plan_Status__c,
                    Include_on_Employer_Benefits_Site__c = c.pCatalog.Employer_Benefits_Site_Eligible__c == true
                ));
                
                if (c.pCatalog.Product_Family__c == 'Accident' &&
                    c.pCatalog.Rider__c == false) {
                    ++numberOfAccidentProductsToAdd;
                }
            }
        }
        
        Integer numberOfVisionProductsToAdd = 0;
        Integer numberOfLifeProductsToAdd = 0;
                   
        for (catalogWrapper  c : catalogWrapper_imp) {
            if (c.addProduct) {
                system.debug('::: added: ' + c.pCatalog.name);
                newProducts.add( new Marketed_Product__c(
                    enrollment__c = ef.Id,
                    Products__c = c.pCatalog.Id,
                    Tax_Treatment__c = c.pCatalog.Tax_Treatment__c,
                    Plan_Status__c = c.pCatalog.Plan_Status__c,
                    AOR__c = c.pCatalog.AOR__c,
                    Carrier__c = c.pCatalog.Carrier__c,
                    Product_Description__c = c.pCatalog.Product_Description__c,
                    Include_on_Employer_Benefits_Site__c = c.pCatalog.Employer_Benefits_Site_Eligible__c == true
                ));
                
                if (c.pCatalog.Product_Family__c == 'Vision') {
                    ++numberOfVisionProductsToAdd;
                }
                
                if (c.pCatalog.Product_Family__c == 'Life') {
                    ++numberOfLifeProductsToAdd;
                }
                
                if (c.pCatalog.Product_Family__c == 'Accident' &&
                    c.pCatalog.Rider__c == false) {
                    ++numberOfAccidentProductsToAdd;
                }
            }
        }
        
        Integer numberOfExistingVisionProducts = getExistingImportedMarketingProductsCountByProductFamily('Vision');
        Integer numberOfExistingLifeProducts = getExistingImportedMarketingProductsCountByProductFamily('Life');
        Integer numberOfExistingAccidentProducts = getExistingAccidentMarketingProductsWithoutRiders();
        
        Integer totalVisionProducts = numberOfExistingVisionProducts + numberOfVisionProductsToAdd;
        Integer totalLifeProducts = numberOfExistingLifeProducts + numberOfLifeProductsToAdd;
        Integer totalAccidentProducts = numberOfExistingAccidentProducts + numberOfAccidentProductsToAdd;
        
        if (totalVisionProducts > 1) {
            addProductErrorMessage = ONLY_1_VISION_IMPORT_PRODUCT_ALLOWED_VAL_MSG;
            addProductError = true;
        }
        
        if (totalLifeProducts > 1) {
            addProductErrorMessage += ' ' + ONLY_1_LIFE_IMPORT_PRODUCT_ALLOWED_VAL_MSG;
            
            addProductError = true;
        }
        
        if (totalAccidentProducts > 1) {
            addProductErrorMessage += ' ' + ONLY_1_ACCIDENT_PRODUCT_ALLOWED_VAL_MSG;
            
            addProductError = true;
        }
        
        system.debug('::: newProducts: ' + newProducts);
        system.debug('::: addProductError: ' + addProductError);
  
        if (addProductError == true){
            system.debug('::: setting page message');    
            showErrorMessages = false;
            addProductError = true;          
            return;
        }
               
        try {
            insert newProducts;
            getProductData();
            getProductCatalog();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, newProducts.size() + ' Product(s) Added'));
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            addProductError = true;          
        }

        generateForms();
    }
    
    public void updateAccountField()
    {
          
        system.debug('*** Account Update ');
        system.debug('**** field name/value: ' + fieldname + ' / ' +fieldvalue);
        try
        {
            if (accountId != null && fieldName != null)
            {
                Account acct = [SELECT ID FROM Account WHERE Id =: accountId];
                acct.put(fieldName, fieldValue);
                system.debug('*** Account: ' + acct);
                update acct;
                detailsCheckRequiredFields(false);
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating Account field.' + e.getMessage()));
            showErrorMessages = true;
        }
    }  
  
    public void updateEnrollmentForm()
    {
        Boolean requestEditMade = false;
        system.debug('::: reached updateEnrollmentForm');   
        try
        {   
            if (fieldName == 'Request_Edit__c'){
                if (fieldValue == 'true') {
                    ef.put(fieldName, true);
                    requestEditMade = true;
                }
                else
                    ef.put(fieldName, false);
            }
            
            else if (fieldName != null) {
                ef.put(fieldName, fieldValue);
                detailsCheckRequiredFields(false);
            }
            
            update ef;  

            getDetailsData();
            setStatusMsg();
            
            // form automatically reopened so refresh the page.
            if (requestEditMade &&
                ef.Status__c == 'In Progress') {
                ReloadPage = true;
            }
            
            system.debug('::: fieldname: ' + fieldName);    
            system.debug('::: fieldvalue ' +fieldValue); 
        }
        catch (dmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getDmlMessage(0)));
            showErrorMessages = true;
        }
    }

    public void updateCustomerSetupForm()
    {
          
        fieldValue = fieldValue == '' ? null : fieldValue;
        system.debug('::: csForm fieldname: ' + fieldName);    
        system.debug('::: csForm fieldvalue ' +fieldValue);
        
        try
        {
 
            System.debug('### theCustomerSetupForm: ' + cs);
            if (fieldName != null) {
                cs.put(fieldName, fieldValue);
                upsert cs;
                detailsCheckRequiredFields(false);
                enrollmentCheckRequiredFields(false);
            }
            
            if(fieldName=='ContactInfoBenefitContact__c') {  // benefit contact lookup
                if(fieldValue != '000000000000000')
                {
                    this.contactId = fieldValue;
                    setContact();
                }
                else
                    cs.ContactInfoBenefitContact__c.addError('No matches found.');
            }
            
            if(fieldName=='ContactInfoBillingContact__c') {  // billing contact lookup
                if(fieldValue != '000000000000000')
                {
                    this.contactId = fieldValue;
                    setContact();
                }
                else
                    cs.ContactInfoBillingContact__c.addError('No matches found.');
            }
            if(fieldName=='Annuity_Contact__c') {  // annuity contact lookup
                if(fieldValue != '000000000000000')
                {
                    this.contactId = fieldValue;
                    setContact();
                }
                else
                    cs.Annuity_Contact__c.addError('No matches found.');
            }
        }
        catch (DMLexception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getDmlMessage(0)));
            showErrorMessages = true;
        }
    }
    
    public void updateSection125Form()
    {
        fieldValue = fieldValue == '' ? null : fieldValue;
        system.debug('::: s125Form fieldname: ' + fieldName);    
        system.debug('::: s125Form fieldvalue ' +fieldValue);
        
        try
        {
 
            System.debug('::: section125Form: ' + s125);
            if (fieldName != null) {
                s125.put(fieldName, fieldValue);
                upsert s125;
                detailsCheckRequiredFields(false); 
                enrollmentCheckRequiredFields(false);
            }
            
            if(fieldName=='ContactInfoS125Contact__c') {  // S125 contact lookup
                if(fieldValue != '000000000000000')
                {
                    this.contactId = fieldValue;
                    setContact();
                }
                else
                    s125.ContactInfoS125Contact__c.addError('No matches found.');
            }
            
            if(fieldName=='ContactInfoFlexContact__c') {  // FLEX contact lookup
                if(fieldValue != '000000000000000')
                {
                    this.contactId = fieldValue;
                    setContact();
                }
                else
                    s125.ContactInfoFlexContact__c.addError('No matches found.');
            }
            
            if(fieldName=='HlthSvgsAcctEligReq__c') {  // FLEX contact lookup
                if(fieldValue != '000000000000000')
                {
                    this.contactId = fieldValue;
                    setContact();
                }
                else
                    s125.HlthSvgsAcctEligReq__c.addError('No matches found.');
            }
            
        }
        catch (DMLexception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' + e.getDmlMessage(0)));
            showErrorMessages = true;
        }
    }
  
   
   
    public void updatePlatformSetup()
    {
        fieldValue = fieldValue == '' ? null : fieldValue;
        boolean updateEnrollmentType = false;
      
        system.debug('::: before update ps: ' + ps);       
        // When Returning Elect Data is set to no, set value to null and set Enrollment Type to Product Only
        if (fieldName=='Enroll_Info_Returning_Electronic_Data__c' && fieldValue == 'No') { 
            fieldValue = null;
            updateEnrollmentType = true;
        }
          
        try
        {   
            if (fieldName=='Enroll_Info_First_Payroll_Deduction_Date__c'){
                if (fieldValue == null){
                    ps.put(fieldName,null);
                }
                else {
                    ps.put(fieldName, date.parse(fieldValue));
                }
            }
            else if(fieldName == 'EnrollInfoUploadDueDate__c')
            {
                
                if(fieldValue == null)
                    ps.put(fieldName, null);
                else
                    ps.put(fieldName, date.parse(fieldValue));
            }
            
            else if (fieldName != null) {
                ps.put(fieldName, fieldValue);
            
            }
            upsert ps;
            setPayRollUploadRushed();
            detailsCheckRequiredFields(false);
            
            system.debug('::: after update ps: ' + ps);   
            
            system.debug('::: fieldname: ' + fieldName);    
            system.debug('::: fieldvalue ' +fieldValue);
            
            if (updateEnrollmentType) {
                fieldName = 'Enroll_Info_Enrollment_Type__c';
                fieldValue = 'Product Only';
                updatePlatformSetup();
            }  
        }
        catch (DMLexception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error updating a field. ' +e.getDmlMessage(0)));
            showErrorMessages = true;
        }
    }  
     
  

    public void updateProduct()
    {
        showErrorMessages = false;
        
        Marketed_Product__c mp = new Marketed_Product__c(Id = productId);
          
        updateFieldOnRecord(mp, FieldName, FieldValue);
        
        setRequiredContacts();      // in case Plan Status is updated
        generateForms();
        productCheckRequiredFields(false);
    }
    
    public void setTabColors() {
        detailsCheckRequiredFields(false);
        productCheckRequiredFields(false);
        enrollmentCheckRequiredFields(false);
         
        // system.debug(':::setTabColors() called');
        // system.debug(':::detailsTabComplete ' + detailsTabComplete);
        // system.debug(':::productTabComplete ' + productTabComplete);
        // system.debug(':::enrollmentTabComplete ' + enrollmentTabComplete);
    }
  
//
//  write createNewContact routine.  Method needs to create a new contact, then call setContact() method
//  use setContactToAdminContact() as a model.  Also remove "update" statements in setContact()
//
 
    public void createNewContact() {
    
        system.debug('::: CREATING NEW ' + contactType);
        system.debug('::: first name ' + newContactFirstName);
        system.debug('::: last name ' + newContactLastName);
        system.debug('::: title ' + newContactTitle);
        system.debug('::: email ' + newContactEmail);
        system.debug('::: phone ' + newContactPhone);
        system.debug('::: ext ' + newContactExt);
        
        decimal extension = newContactExt == null || newContactExt == '' ? null : Decimal.valueOf(newContactExt) ;       
        Contact c = new Contact(accountId=eOppty.AccountId, firstName=newContactFirstName, lastName=newContactLastName, title=newContactTitle, Email=newContactEmail, Phone=newContactPhone, Extension__c = extension);
        try {
            insert c;
            
            if (contactType == 'adminContact'){
                eOppty.Administrative_Contact__c = c.Id;
                update eOppty;
                this.contactId = c.Id;
                setContact();
            }
       
        
            if (contactType == 'benefitContact'){
                cs.ContactInfoBenefitContact__c = c.Id;
                update cs;
                this.contactId = c.Id;
                setContact();
            }
       
            if (contactType == 'billingContact'){
                cs.ContactInfoBillingContact__c = c.Id;
                update cs;
                this.contactId = c.Id;
                setContact();
            }
                 
            if (contactType == 'annuityContact'){
                cs.Annuity_Contact__c = c.Id;
                update cs;
                this.contactId = c.Id;
                setContact();
            }
                 
            if (contactType == 's125Contact'){
                s125.ContactInfoS125Contact__c = c.Id;
                update s125;
                this.contactId = c.Id;
                setContact();
            }
                
            if (contactType == 'flexContact'){
                s125.ContactInfoFlexContact__c = c.Id;
                update s125;
                this.contactId = c.Id;
                setContact();
            }
            
            if (contactType == 'hsaContact'){
                s125.HlthSvgsAcctEligReq__c = c.Id;
                update s125;
                this.contactId = c.Id;
                setContact();
            }
        }
        catch(dmlexception e) {    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the contact. ' + e.getDMLMessage(0)));
            showErrorMessages = true;
        }
    }
 
 
 
    public void setContactToAdminContact() {
    
        system.debug('::: setting ' + contactType +' to Admin');
        
        if (contactType == 'benefitContact'){
            cs.ContactInfoBenefitContact__c = eOppty.Administrative_Contact__c;
            update cs;
            this.contactId = eOppty.Administrative_Contact__c;
            setContact();
        }
   
        if (contactType == 'annuityContact'){
            cs.Annuity_Contact__c = eOppty.Administrative_Contact__c;
            update cs;
            this.contactId = eOppty.Administrative_Contact__c;
            setContact();
        }
             
        if (contactType == 'billingContact'){
            cs.ContactInfoBillingContact__c = eOppty.Administrative_Contact__c;
            update cs;
            this.contactId = eOppty.Administrative_Contact__c;
            setContact();
        }
        
        if (contactType == 's125Contact'){
            s125.ContactInfoS125Contact__c = eOppty.Administrative_Contact__c;
            update s125;
            this.contactId = eOppty.Administrative_Contact__c;
            setContact();
        }
            
        if (contactType == 'flexContact'){
            s125.ContactInfoFlexContact__c = eOppty.Administrative_Contact__c;
            update s125;
            this.contactId = eOppty.Administrative_Contact__c;
            setContact();
        }
        
        if (contactType == 'hsaContact'){
            s125.HlthSvgsAcctEligReq__c = eOppty.Administrative_Contact__c;
            update s125;
            this.contactId = eOppty.Administrative_Contact__c;
            setContact();
        }
    }
    
    
    // update the controller to display the updated contact info
    public void setContact()
    {
        // get contact info and assign to proper object.  Also update table from which Lookup is defined..
        // called when contact lookup is performed
        try
        {   
            system.debug('::: SETTING ' + contactType + ' to ' + contactId);    
            Contact c;
            if (!string.isEmpty(this.contactId)) {
                c = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id = :this.contactId limit 1];
            }
            else {
                c = new Contact();
            }
            system.debug('::: selected Contact: ' + c);
            
            if (contactType=='adminContact') {
                this.adminContact = c;
                system.debug('::: new adminContact: ' + this.adminContact.name);
                // when adminContact is changed, also update contacts that are set to "same as admin contact"
                if(cs.ContactInfoBenefitContactSame__c == 'Yes'){
                    contactType='benefitContact';
                    setContactToAdminContact();
                }
            
                if(cs.ContactInfoBillingContactSame__c == 'Yes'){
                    contactType='billingContact';
                    setContactToAdminContact();
                }

                if(cs.AnnBeforeTaxContInfoSameAdminContact__c == 'Yes'){
                    contactType='annuityContact';
                    setContactToAdminContact();
                }
            
                if(s125.S125S125ContactSameAsAdmin__c == 'Yes'){
                    contactType='s125Contact';
                    setContactToAdminContact();
                }
            
                if(s125.S125FlexContactSameAsAdmin__c == 'Yes'){
                    contactType='flexContact';
                    setContactToAdminContact();
                }
                
                if(s125.HlthSvgsAcctIsHSAcontactsameasAdmin__c == 'Yes'){
                    contactType='hsaContact';
                    setContactToAdminContact();
                }
            }
        
            else if (contactType == 'benefitContact') {
                this.benefitContact = c;
            }
            else if (contactType == 'billingContact') {
                this.billingContact = c;
            }
            else if (contactType == 'annuityContact') {
                this.annuityContact = c;
            }
            else if (contactType == 's125Contact') {
                this.s125Contact = c;
            }
            else if (contactType == 'flexContact') {
                this.flexContact = c;
            }
            else if (contactType == 'hsaContact') {
                this.hsaContact = c;
            }
 
            system.debug(':::adminContact: ' + adminContact);
            system.debug(':::billingContact: ' + billingContact);
            system.debug(':::annuityContact: ' + annuityContact);
            system.debug(':::benefitContact: ' + benefitContact);
            system.debug(':::s125Contact: ' + s125Contact);
            system.debug(':::flexContact: ' + flexContact);
            system.debug(':::hsaContact: ' + hsaContact);
        }
        catch (dmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the contact. ' + e.getDMLMessage(0)));
            showErrorMessages = true;
        }
        
        enrollmentCheckRequiredFields(false);
        return;
    }
    

    public void updateContact()
    {
        fieldValue = fieldValue == '' ? null : fieldValue;
        try
        { 
            system.debug('::: updateContact - contactId: ' + contactId);
            system.debug('::: setting ' + fieldName + ' to ' + fieldValue);    
            
            Contact c;
            c = [SELECT Id, Name, Title, Phone, Email, Extension__c FROM Contact WHERE Id = :this.contactId limit 1];  //this cannot fail
          
            
            if (fieldName == 'Extension__c'){
                decimal extension = fieldValue=='' ? null : Decimal.valueOf(fieldValue);
                c.put(fieldName, extension);
            }
            else{
                c.put(fieldName, fieldValue);
            }
            update c;
        
        
            
            if (contactType=='adminContact') {
                this.adminContact = c;
                // when adminContact is changed, also update contacts that are set to "same as admin contact"
                if(cs.ContactInfoBenefitContactSame__c == 'Yes'){
                    this.benefitContact = c;
                    system.debug(':::benefitContact changed: ' + benefitContact);
                }
            
                if(cs.ContactInfoBillingContactSame__c == 'Yes'){
                    this.billingContact = c;
                    system.debug(':::billingContact changed: ' + billingContact);
                }
            
                if(cs.AnnBeforeTaxContInfoSameAdminContact__c == 'Yes'){
                    this.annuityContact = c;
                    system.debug(':::annuityContact changed: ' + annuityContact);
                }
            
                if(s125.S125S125ContactSameAsAdmin__c == 'Yes'){
                    this.s125Contact = c;
                    system.debug(':::s125Contact changed: ' + s125Contact);
                }
            
                if(s125.S125FlexContactSameAsAdmin__c == 'Yes'){
                    this.flexContact = c;
                    system.debug(':::flexContact changed: ' + flexContact);
                }
                
                if(s125.HlthSvgsAcctIsHSAcontactsameasAdmin__c == 'Yes'){
                    this.hsaContact = c;
                    system.debug(':::hsaContact changed: ' + hsaContact);
                }
            }
        
            else if (contactType == 'benefitContact') {
                this.benefitContact = c;
            }
            else if (contactType == 'billingContact') {
                this.billingContact = c;
            }
            else if (contactType == 'annuityContact') {
                this.annuityContact = c;
            }
            else if (contactType == 's125Contact') {
                this.s125Contact = c;
            }
            else if (contactType == 'flexContact') {
                this.flexContact = c;
            }
            else if (contactType == 'hsaContact') {
                this.hsaContact = c;
            }
  
        }
        catch (dmlException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving the contact. ' + e.getDMLMessage(0)));
            showErrorMessages = true;
        }
        
        enrollmentCheckRequiredFields(false);
    }
      
    //insert new Opportunity Team Member record
    //Create new OpportunityShare record so that the new team member will have edit rights on the opp
    public void insertOTM()
    {
        //otm.UserId = managerId;
        try
        {
            
            OpportunityTeamMember teamMember = otm;
            teamMember.UserId = managerId;
            insert teamMember;  
            
            // get all of the team members' sharing records
            List<OpportunityShare> shares = [select Id, OpportunityAccessLevel, RowCause from OpportunityShare where OpportunityId =: eOppty.Id AND RowCause = 'Team Member'];
            
            // set all team members access to read/write
            for (OpportunityShare share : shares){
                share.OpportunityAccessLevel = 'Edit';
            }
            update shares;
            
            getOpptyTeam();
            
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error inserting the Opportunity Team Member. ' + e.getMessage()));
            showErrorMessages = true;
        }
    
    }

    //Delete Opportunity Team Member Record
    //id is passed from the page
    public void deleteOTM()
    {
        try
        {
            System.debug('### deleting OTM: ' + otmId);   //jh assuming this variable is assigned via action Function
            
            if (otmId != null)
            {
                OpportunityTeamMember oppTeamMember = [SELECT Id, UserId FROM OpportunityTeamMember WHERE ID =: otmId];
                List<OpportunityShare> shares = [SELECT Id FROM OpportunityShare WHERE UserOrGroupId =: oppTeamMember.UserId AND OpportunityId =: ef.Id];
                delete oppTeamMember;
                delete shares;
                getOpptyTeam();
          
            }
        }
        catch (exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error deleting Opportunity Team Member. ' + e.getMessage()));
            System.debug('### ERROR deleting record: ' + e.getMessage());
            showErrorMessages = true;
        }
        
    }
        
    public void getHelpText() 
    {
        hMap = new Map<string,string>();
        Set<string> fields = new Set<string>();
        Map<String, Schema.SObjectField> objectFields = new Map<String, Schema.SObjectField>();
        Schema.DescribeFieldResult dr;
        
        // Enrollment Form Object
        objectFields =  schema.SObjectType.Enrollment_Form__c.fields.getMap();
        fields = objectFields.keyset();
        
        for(String field : fields){
            dr = objectFields.get(field).getDescribe();
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText()); 
        }
            
        // Customer Setup Form
        objectFields =  schema.SObjectType.Customer_Setup_Form__c.fields.getMap();
        fields = objectFields.keyset();
        for(String field : fields){
            dr = objectFields.get(field).getDescribe();
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText());  
        }
        
        // Platform Setup Form fields
        objectFields =  schema.SObjectType.Platform_Setup__c.fields.getMap();
        fields = objectFields.keyset();
        for(String field : fields){
            dr = objectFields.get(field).getDescribe();
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText());
        }
        
        // Opportunity Fields
        objectFields =  schema.SObjectType.Opportunity.fields.getMap();
        fields = objectFields.keyset();
        for(String field : fields){
            dr = objectFields.get(field).getDescribe();
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText());  
        }
        
        // Account Fields
        objectFields =  schema.SObjectType.Account.fields.getMap();
        fields = objectFields.keyset();
        for(String field : fields){
            dr = objectFields.get(field).getDescribe();
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText());  
        }
        
        // Opportunity Team Member Fields
        objectFields =  schema.SObjectType.OpportunityTeamMember.fields.getMap();
        fields = objectFields.keyset();
        for(String field : fields){
            dr = objectFields.get(field).getDescribe();
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText());  
        }
        
        // Contact Fields
        objectFields =  schema.SObjectType.Contact.fields.getMap();
        fields = objectFields.keyset();
        for(String field : fields){
            dr = objectFields.get(field).getDescribe();
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText());  
        }
        
        // Section 125 Fields
        objectFields =  schema.SObjectType.Section_125_Setup_Form__c.fields.getMap();
        fields = objectFields.keyset();
        for(String field : fields){
            dr = objectFields.get(field).getDescribe();
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText());  
        }
        
        // Event Fields
        objectFields =  schema.SObjectType.Event.fields.getMap();
        fields = objectFields.keyset();
        for(String field : fields){
            dr = objectFields.get(field).getDescribe();
            if(dr.getInlineHelpText() == null)
                hMap.put(field, '');
            else
                hMap.put(field, dr.getInlineHelpText());  
        }
    }
    
    
    public void checkRequiredFieldsAndDisplay() {
       
        detailsCheckRequiredFields(true);
        productCheckRequiredFields(true);
        enrollmentCheckRequiredFields(true);
        system.debug('::: ran checkRequiredFieldsAndDisplay on server ');
    }
   
    private void generateForms(){
        // In reality, the only form that could be added is the S125.  Other forms
        // are based on info in the Oppty before the General Info form is created.
        // This routine also updates fields on some Forms records.
  
        boolean s125FormRequired = false;
        try {
            // Look for S125 product - only exist in Service
            Set<string> newProducts = new Set<string>();
            for (Marketed_Product__c mp : mProducts_svc) {
                if(mp.Plan_Status__c=='New' &&
                  (mp.products__r.name.containsIgnoreCase('Section 125') || mp.products__r.name.containsIgnoreCase('FSA')||
                   mp.products__r.name.containsIgnoreCase('HRA')||  mp.products__r.name.containsIgnoreCase('HSA')))
                    s125FormRequired = true;
            }

            // create forms (or delete)
            List<Opportunity> oppty = new List<Opportunity>();
            oppty.add(eOppty);
            OpportunityFormRules.setFormBooleans(oppty, true, s125FormRequired );
            update eOppty;    // Opportunity trigger creates form records.
            
            //if a new s125 form was created, copy any data from the controller to this record
            if (this.s125.Id == null && s125FormRequired) {
                this.s125 = 
                       [select Id, s125S125ContactSameAsAdmin__c, ContactInfoS125Contact__c, s125FlexContactSameAsAdmin__c,ContactInfoFlexContact__c, HlthSvgsAcctIsHSAcontactsameasAdmin__c, HlthSvgsAcctEligReq__c 
                        from Section_125_Setup_Form__c where Enrollment_Form__c = :ef.Id  limit 1];  
                system.debug('::: generateForms(controller) s125 created:' + s125);    
            }
            
            
            //set product related flags on Platform Setup
            Platform_Setup__c p = [select Id, 
                                          Tx_Life_Will_Tx_Life_be_set_up__c,
                                          Tx_Life_Is_new_case_of_a_re_enrol__c, 
                                          DVR_Info_WillThereBeDependent_Verif__c,
                                          S125OtherSvcHaveAFASection125__c,
                                          S125OtherSvcIsThereFSA__c,
                                          S125OtherSvcDebitCard__c,
                                          S125OtherSvcHealthFSAMax__c,
                                          S125OtherSvcHealthFSAMin__c
                                     FROM Platform_Setup__c where Enrollment_Form__c = :ef.Id limit 1];
                                     
            p.Tx_Life_Will_Tx_Life_be_set_up__c = 'No';
            p.S125OtherSvcHaveAFASection125__c = 'No';    // will be set to yes if S125 product found;
            p.S125OtherSvcIsThereFSA__c = 'No';
            p.DVR_Info_WillThereBeDependent_Verif__c = 'No';
               
                                     
            for (Marketed_Product__c mp : mProducts_ben) {
                if (mp.products__r.name=='Texas Life') {
                    p.Tx_Life_Will_Tx_Life_be_set_up__c = 'Yes';
                    p.Tx_Life_Is_new_case_of_a_re_enrol__c = mp.plan_status__c == 'New' ? 'New' : 'Re-enrollment';
                    continue;
                }
            }
                 
                
            for (Marketed_Product__c mp : mProducts_svc) {
                if (mp.products__r.name=='Dependent Verification Review') {
                    p.DVR_Info_WillThereBeDependent_Verif__c = 'Yes';
                }
                if (mp.products__r.name=='Health FSA' || mp.products__r.name=='Dependent Daycare FSA') {
                    p.S125OtherSvcIsThereFSA__c = 'Yes';
                }
                if (mp.products__r.name=='Section 125' ) {
                    p.S125OtherSvcHaveAFASection125__c = 'Yes';
                }
                if (mp.products__r.name=='Flex Card') {
                    p.S125OtherSvcDebitCard__c = 'Yes';
                }
            }
            
            // Look for FSA Asset record and set default values on PS Form
            try {
                Asset a = [select Health_FSA_Minimum__c,Health_FSA_Maximum__c from Asset where AccountId = :eOppty.AccountId and Status = 'Active' and 
                            Name= 'Flexible Spending Account' limit 1];

                // Only override the max if it doesn't have a value.
                if (a.Health_FSA_Maximum__c != null &&
                    p.S125OtherSvcHealthFSAMax__c == null)
                    p.S125OtherSvcHealthFSAMax__c = string.valueOf(a.Health_FSA_Maximum__c);

                // Only override the min if it doesn't have a value.
                if (a.Health_FSA_Minimum__c != null &&
                    p.S125OtherSvcHealthFSAMin__c == null)
                    p.S125OtherSvcHealthFSAMin__c = string.valueOf(a.Health_FSA_Minimum__c);
            }
            catch(exception e){}
                 
            update p;
            system.debug('::: Platform Setup: ' + p);
        
             
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            showErrorMessages = true;
        }
        return;     
    }
   
   
   
    public void submitForm()
    {
        system.debug('::: reached controller submitForm()');
        boolean s125FormRequired = false;
        try {
            generateForms();
            
            ef.status__c = 'Confirmed';
            update ef;
            confirmSuccessful = true;
            setStatusMsg();
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            showErrorMessages = true;
        }
        return;
    }
    
    public void productCheckRequiredFields() {
        productCheckRequiredFields(false);
    }
    
    public void productCheckRequiredFields(Boolean showErrors) {
        productTabComplete = true;

        if (mproducts_ben.size()+mproducts_svc.size()+mproducts_imp.size() == 0) {
            productTabComplete = false;
        }
        
        system.debug('  before validateMarketedProducts    productCheckRequiredFields::productTabComplete ' + productTabComplete);
        
        productTabComplete &= validateMarketedProducts(showErrors);
        
        system.debug('  after validateMarketedProducts  productCheckRequiredFields::productTabComplete ' + productTabComplete);
    }
    
    public void detailsCheckRequiredFields(boolean showField) {

        detailsTabComplete = true;
        enrollmentPathRequiredMessage = '';
           
        // get updated data
        getDetailsData();
    
        // check each field on details tab   
        if (IsReservice == false &&
            eOppty.Group_Name__c == null) {
            if (showField){
                eOppty.Group_Name__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
           
           
        if (eOppty.EE_Eligibility_Waiting_Period__c == null) {
            if (showField){
                eOppty.EE_Eligibility_Waiting_Period__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
        
        if (eOppty.Waiting_Period_Effective__c == null) {
            if (showField){
                eOppty.Waiting_Period_Effective__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
     
        if (eOppty.Tax_ID__c == null &&
            String.isNotBlank(eOppty.Confirm_New_or_Existing_Group__c) &&
            eOppty.Confirm_New_or_Existing_Group__c != 'Existing') {
            if (showField){
                eOppty.Tax_ID__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
        
        // If a tax id is given, it must be in the format ##-####### such as
        // 12-1817181.
        if (String.isNotBlank(eOppty.Tax_ID__c) &&
            eOppty.Confirm_New_or_Existing_Group__c != 'Existing' &&
            Pattern.matches('^\\d{2}-\\d{7}$', eOppty.Tax_ID__c) == false &&
            Pattern.matches('^\\d{9}$', eOppty.Tax_ID__c) == false) {
            
            if (showField){
                eOppty.Tax_ID__c.addError(INVALID_EIN_FORMAT_VAL_MSG);
            }

            detailsTabComplete = false;
        }
     
        if (eOppty.Assigned_Account_Manager__c == null) {
            if (showField){
                eOppty.Assigned_Account_Manager__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
     
        if (eOppty.Residence_State_s__c  == null) {
            if (showField){
                eOppty.Residence_State_s__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
     
        if (eOppty.Estimated_Employees__c == null) {
            if (showField){
                eOppty.Estimated_Employees__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
     
        if (eOppty.Enrollment_Start_Date__c == null) {
            if (showField){
                eOppty.Enrollment_Start_Date__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
     
        if (eOppty.Enrollment_End_Date__c == null) {
            if (showField){
                eOppty.Enrollment_End_Date__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
        
        if (eOppty.Enrollment_Start_Date__c != null &&
            eOppty.Enrollment_End_Date__c != null &&
            eOppty.Enrollment_Start_Date__c > eOppty.Enrollment_End_Date__c) {

            if (showField) {
                eOppty.Enrollment_End_Date__c.addError(ENROLLMENT_END_DATE_AFTER_START_DATE_VAL_MSG);
            }
            
            detailsTabComplete = false;
        }
     
        if (eOppty.Effective_Date_of_AFA_Products__c == null) {
            if (showField){
                eOppty.Effective_Date_of_AFA_Products__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
        
        if (ps.Enroll_Info_Service_Process__c == null) {
            if (showField){
                ps.Enroll_Info_Service_Process__c.addError('Required Field');
            }
            detailsTabComplete = false;
        }

        if (eOppty.Physical_Address_Same_As_Billing__c == null) {
            if (showField){
                eOppty.Physical_Address_Same_As_Billing__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
     
        if (acc.BillingStreet == null) {
            if (showField){
                acc.BillingStreet.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
     
        if (acc.BillingCity == null) {
            if (showField){
                acc.BillingCity.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
     
        if (acc.BillingState == null) {
            if (showField){
                acc.BillingState.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
     
        if (acc.BillingPostalCode == null) {
            if (showField){
                acc.BillingPostalCode.addError('Required Field');
            }    
            detailsTabComplete = false;
        }

        if (ps.Enroll_Info_First_Payroll_Deduction_Date__c == null) {
            if (showField){
                ps.Enroll_Info_First_Payroll_Deduction_Date__c.addError('Required Field');
            }    
            detailsTabComplete = false;
        }
        
        if (eOppty.EE_Eligibility_Waiting_Period__c == 'Other' &&
            String.isBlank(eOppty.Other_Eligibility_Waiting_Period__c)) {
            if (showField){
                eOppty.Other_Eligibility_Waiting_Period__c.addError('Required Field');
            }
            detailsTabComplete = false;
        }
        
        if (String.isBlank(eOppty.Enrollment_Path__c)) {
            if (showField) {
                enrollmentPathRequiredMessage = ENROLLMENT_PATH_REQUIRED_VAL_MSG;
            }
            detailsTabComplete = false;
        }
        
        if (enrollmentRushRequested &&
            String.isBlank(eOppty.Enrollment_Rush_Request_Reason__c)) {
            if (showField) {
                eOppty.Enrollment_Rush_Request_Reason__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            detailsTabComplete = false;
        }

        if (payrollDueDateRushed && String.isBlank(ps.Payroll_Due_Date_Rush_Reason__c)) {
            if (showField) {
                ps.Payroll_Due_Date_Rush_Reason__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            detailsTabComplete = false;
        }
        
        Set<String> requiredPlatformSetupFields = getEnrollmentPathPlatformSetupRequiredFields();
            
        if (requiredPlatformSetupFields.contains(Platform_Setup__c.Enroll_Info_GrpToCcontactForData__c.getDescribe().getName()) &&
            ps.Enroll_Info_GrpToCcontactForData__c == null) {
            if (showField){
                ps.Enroll_Info_GrpToCcontactForData__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            detailsTabComplete = false;
        }
	        
        if (requiredPlatformSetupFields.contains(Platform_Setup__c.Enroll_Info_Service_Process__c.getDescribe().getName()) &&
            ps.Enroll_Info_Service_Process__c == null) {
            if (showField){
                ps.Enroll_Info_Service_Process__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            detailsTabComplete = false;
        }

        if (requiredPlatformSetupFields.contains(Platform_Setup__c.Enrollment_Setup__c.getDescribe().getName()) &&
            ps.Enrollment_Setup__c == null) {
            if (showField){
                ps.Enrollment_Setup__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            detailsTabComplete = false;
        }

        if (requiredPlatformSetupFields.contains(Platform_Setup__c.Requesting_Data__c.getDescribe().getName()) &&
            ps.Requesting_Data__c == null) {
            if (showField){
                ps.Requesting_Data__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            detailsTabComplete = false;
        }
        
        if (requiredPlatformSetupFields.contains(Platform_Setup__c.Providing_Dependent_Data__c.getDescribe().getName()) &&
            ps.Providing_Dependent_Data__c == null) {
            if (showField){
                ps.Providing_Dependent_Data__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            detailsTabComplete = false;
        }
            
        if (enrollmentEmployeeThresholdShort &&
            String.isBlank(ps.Below_Eligible_Employee_Threshold_Reason__c)) {
            if (showField){
                ps.Below_Eligible_Employee_Threshold_Reason__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            detailsTabComplete = false;
        }
        
        if (eOppty.Confirm_New_or_Existing_Group__c == 'Existing' &&
            String.isBlank(eOppty.Are_you_changing_AFenroll_Frequencies__c)) {

            if (showField){
                eOppty.Are_you_changing_AFenroll_Frequencies__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            detailsTabComplete = false;
        }
        
        if (eOppty.Confirm_New_or_Existing_Group__c == 'Existing' &&
            String.isNotBlank(eOppty.Are_you_changing_AFenroll_Frequencies__c) &&
            eOppty.Are_you_changing_AFenroll_Frequencies__c == 'Yes' &&
            String.isBlank(eOppty.New_AFenroll_Deduction_Frequencies__c)) {
            
            if (showField){
                eOppty.New_AFenroll_Deduction_Frequencies__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            detailsTabComplete = false;
        }

        // Luke Freeland: If Additional MCPs are entered, ensure that they're numbers and comma separated
        // if more than one. Spaces are allowed too. This is to ensure that the MCPs are supplied correctly
        // to the AFEnroll system later.
        if (String.isNotBlank(eOppty.Additional_MCPs__c) &&
            Pattern.matches('[\\d,\\s]*', eOppty.Additional_MCPs__c) == false) {
            
            if (showField){
                eOppty.Additional_MCPs__c.addError(Label.General_Information_Additional_MCPs_Validation_Message);
            }
            detailsTabComplete = false;
        }

        system.debug('::: detailsTabComplete: ' + detailsTabComplete);
    }


    public void enrollmentCheckRequiredFields(boolean showField) {
       
        enrollmentTabComplete = true;
        
        system.debug('enrollmentCheckRequiredFields::adminContact: ' + adminContact);
        system.debug('enrollmentCheckRequiredFields::benefitContact: ' + benefitContact);
        system.debug('enrollmentCheckRequiredFields::billingContact: ' + billingContact);
        system.debug('enrollmentCheckRequiredFields::annuityContact: ' + annuityContact);
        system.debug('enrollmentCheckRequiredFields::s125Contact: ' + s125Contact);
        system.debug('enrollmentCheckRequiredFields::flexContact: ' + flexContact);
        system.debug('enrollmentCheckRequiredFields::hsaContact: ' + hsaContact);
        
        Boolean benefitContactRequired = requiredContacts.contains('benefit');
        Boolean billingContactRequired = requiredContacts.contains('billing');
        Boolean annuityContactRequired = requiredContacts.contains('annuity');
        Boolean s125ContactRequired = requiredContacts.contains('s125');
        Boolean flexContactRequired = requiredContacts.contains('flex');
        Boolean hsaContactRequired = requiredContacts.contains('hsa');
 
        if (adminContact.Name == null) {
            if (showField){
                eOppty.Administrative_Contact__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
     
        if (adminContact.email == null) {
            if (showField){
                adminContact.email.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
           
        if (adminContact.phone == null) {
            if (showField){
                adminContact.phone.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
        
        
        
        if (benefitContactRequired && cs.ContactInfoBenefitContactSame__c == null) {
            if (showField){
                cs.ContactInfoBenefitContactSame__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            enrollmentTabComplete = false;
        }
    
        if (benefitContact.Name == null && benefitContactRequired) {
            if (showField){
                cs.ContactInfoBenefitContact__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
     
        if (benefitContact.email == null && benefitContactRequired) {
            if (showField){
                benefitContact.email.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
           
        if (benefitContact.phone == null && benefitContactRequired) {
            if (showField){
                benefitContact.phone.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }

        if (billingContactRequired && cs.ContactInfoBillingContactSame__c == null) {
            if (showField){
                cs.ContactInfoBillingContactSame__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            enrollmentTabComplete = false;
        }

        if (billingContact.Name == null && billingContactRequired) {
            if (showField){
                cs.ContactInfoBillingContact__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
     
        if (billingContact.email == null && billingContactRequired) {
            if (showField){
                billingContact.email.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
           
        if (billingContact.phone == null && billingContactRequired) {
            if (showField){
                billingContact.phone.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
        

        if (annuityContactRequired && cs.AnnBeforeTaxContInfoSameAdminContact__c == null) {
            if (showField){
                cs.AnnBeforeTaxContInfoSameAdminContact__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            enrollmentTabComplete = false;
        }
        
        if (annuityContact.Name == null && annuityContactRequired) {
            if (showField){
                cs.Annuity_Contact__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
     
        if (annuityContact.email == null && annuityContactRequired) {
            if (showField){
                annuityContact.email.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
           
        if (annuityContact.phone == null && annuityContactRequired) {
            if (showField){
                annuityContact.phone.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }


        if (s125ContactRequired && s125.S125S125ContactSameAsAdmin__c == null) {
            if (showField){
                s125.S125S125ContactSameAsAdmin__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            enrollmentTabComplete = false;
        }

        if (s125Contact.Name == null && s125ContactRequired) {
            if (showField){
                s125.ContactInfoS125Contact__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
     
        if (s125Contact.email == null && s125ContactRequired) {
            if (showField){
                s125Contact.email.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
           
        if (s125Contact.phone == null && s125ContactRequired) {
            if (showField){
                s125Contact.phone.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
        
        
        if (flexContactRequired && s125.S125FlexContactSameAsAdmin__c == null) {
            if (showField){
                s125.S125FlexContactSameAsAdmin__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            enrollmentTabComplete = false;
        }
    
        if (flexContact.Name == null && flexContactRequired) {
            if (showField){
                s125.ContactInfoFlexContact__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
     
        if (flexContact.email == null && flexContactRequired) {
            if (showField){
                flexContact.email.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
           
        if (flexContact.phone == null && flexContactRequired) {
            if (showField){
                flexContact.phone.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }


        if (hsaContactRequired && s125.HlthSvgsAcctIsHSAcontactsameasAdmin__c == null) {
            if (showField){
                s125.HlthSvgsAcctIsHSAcontactsameasAdmin__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            enrollmentTabComplete = false;
        }        
        
        if (hsaContact.Name == null && hsaContactRequired) {
            if (showField){
                s125.HlthSvgsAcctEligReq__c.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
     
        if (hsaContact.email == null && hsaContactRequired) {
            if (showField){
                hsaContact.email.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
           
        if (hsaContact.phone == null && hsaContactRequired) {
            if (showField){
                hsaContact.phone.addError(REQUIRED_FIELD_MESSAGE);
            }    
            enrollmentTabComplete = false;
        }
        system.debug(':::enrollmentTabComplete: ' + enrollmentTabComplete);   
    }

    public void deleteProduct() {
        addProductError = false;
        if (this.productId != null) {
            Marketed_Product__c mp = [Select Id from Marketed_Product__c where id = :this.productId limit 1];
            try {
                delete mp;
            }
            catch (Exception e) {
                ApexPages.addMessages(e);
                showErrorMessages = true;
            }
            getProductData();
            getProductCatalog();
            generateForms();
        }
            
    }
    
    public void updateEnrollmentOpportunity() {
        try
        {
            System.debug('### updateEnrollmentOpportunity::eOppty: ' + eOppty);

            update eOppty;
            detailsCheckRequiredFields(false);
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
            showErrorMessages = true;
        }
    }
    
    public void updateEnrollmentPath() {
        eOppty.Enrollment_Path__c = selectedEnrollmentPathId;

        setEnrollmentRushRequested();
        setEnrollmentEmployeeThresholdInfo();

        updateEnrollmentOpportunity();
    }
    
    private Boolean isEnrollmentRushRequested(Id enrollmentPathId) {
        Enrollment_Path__c enrollmentPath = (Enrollment_Path__c) CollectionUtil.findRecordById(enrollmentPaths, enrollmentPathId);

        if (enrollmentPath == null ||
            eOppty.Enrollment_Start_Date__c == null ||
            enrollmentPath.Lead_Time__c == null ||
            wasPreviouslySubmitted) {
            return false;
        }

        Date leadDate = eOppty.Enrollment_Start_Date__c.addDays((Integer) enrollmentPath.Lead_Time__c * -1);

        Boolean isRushed = Date.Today() >= leadDate;

        return isRushed;
    }

    private Boolean isPayrollRushed(){
        Boolean isRushed = false;

        if(eOppty.Enrollment_End_Date__c == null || ps.EnrollInfoUploadDueDate__c == null){
            return isRushed;
        }

        if(ps.EnrollInfoUploadDueDate__c < eOppty.Enrollment_End_Date__c){
            Integer workingDays = Util.calculateWorkingDays(ps.EnrollInfoUploadDueDate__c, eOppty.Enrollment_End_Date__c);
            isRushed = workingDays <= Integer.valueOf(Label.Payroll_Due_Date_Threshold);
        }
        else {
            isRushed = true;
        }

        return isRushed;
    }
    
    private void addExtraFieldsToStandardController(ApexPages.StandardController stdController) {
        Set<string> fieldnames = new Set<string>();
        
        fieldnames.add('AccountId');
        fieldnames.add('Account.AFenroll_Pay_Groups__c');
        fieldnames.add('Account.Eligibile_Employee_Count__c');
        fieldnames.add('Account.Status__c');
        fieldnames.add('Account.MCP_Number__c');
        fieldnames.add('Division__c');
        fieldnames.add('Confirm_New_or_Existing_Group__c');
        fieldnames.add('Administrative_Contact__c');
        fieldnames.add('Are_you_making_any_product_changes__c');
        fieldnames.add('Has_Section_125_setup_form__c');
        fieldnames.add('Has_Private_Exchange_form__c');
        fieldnames.add('Has_Customer_Setup_form__c');
        fieldnames.add('Has_Section_125_Plan_Summary_form__c');
        fieldnames.add('Has_Platform_Setup_Form__c');
        fieldnames.add('Has_Subscription_Agreement__c');
        fieldnames.add('Are_you_adding_new_plans_or_services__c');
        fieldnames.add('Are_you_making_any_billing_changes__c');
        fieldnames.add('Generate_a_Section_125_One_page_summary__c');
        fieldnames.add('RecordType.Name');
        fieldnames.add('Enrollment_Path__c');
        fieldnames.add('Estimated_Employees__c');

        for (Schema.FieldSetMember marketingInformationField : SObjectType.Opportunity.FieldSets.Marketing_Information.getFields()) {
            fieldnames.add(marketingInformationField.getFieldPath());
        }

        List<Schema.FieldSet> fieldSetsToUse = new List<Schema.FieldSet>{
            SObjectType.Opportunity.FieldSets.Marketing_Information
        };

        for (Schema.FieldSet fieldSet : fieldSetsToUse) {
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                fieldnames.add(field.getFieldPath());
            }
        }
        
        if (!Test.isRunningTest()) {    
            stdController.addFields(new List<String>(fieldnames));
        }
    }
    
    private Integer getExistingImportedMarketingProductsCountByProductFamily(String productFamily) {
        Integer count = 0;
        
        for (Marketed_Product__c mpi : mProducts_imp) {
            if (mpi.Products__r.Product_Family__c == productFamily) {
                ++count;
            }
        }
        
        return count;
    }
    
    private Integer getExistingMarketingProductsCountsByProductFamily(String productFamily) {
        Integer count = 0;
        
        List<Marketed_Product__c> allExistingProducts = new List<Marketed_Product__c>();
        allExistingProducts.addAll(mProducts_ben);
        allExistingProducts.addAll(mProducts_svc);
        allExistingProducts.addAll(mProducts_imp);
        
        for (Marketed_Product__c mpi : allExistingProducts) {
            if (mpi.Products__r.Product_Family__c == productFamily) {
                ++count;
            }
        }
        
        return count;
    }
    
    private Integer getExistingAccidentMarketingProductsWithoutRiders() {
        Integer count = 0;
        
        List<Marketed_Product__c> allExistingProducts = new List<Marketed_Product__c>();
        allExistingProducts.addAll(mProducts_ben);
        allExistingProducts.addAll(mProducts_svc);
        allExistingProducts.addAll(mProducts_imp);
        
        for (Marketed_Product__c mpi : allExistingProducts) {
            if (mpi.Products__r.Product_Family__c == 'Accident' &&
                mpi.Products__r.Rider__c == false) {
                ++count;
            }
        }
        
        return count;
    }
    
    private Boolean validateMarketedProducts(Boolean showErrors) {
        Boolean valid = true;
        
        List<Marketed_Product__c> allExistingProducts = new List<Marketed_Product__c>();
        allExistingProducts.addAll(mProducts_ben);
        allExistingProducts.addAll(mProducts_svc);
        allExistingProducts.addAll(mProducts_imp);
        
        for (Marketed_Product__c existingMP : allExistingProducts) {
            if (existingMP.products__r.Is_Tax_Treatment_Editable__c &&
                String.isBlank(existingMP.Tax_Treatment__c)) {
                
                valid = false;
                
                if (showErrors) {
                    existingMP.Tax_Treatment__c.addError(REQUIRED_FIELD_MESSAGE);
                }
            }
            
            if (String.isBlank(existingMP.Plan_Status__c)) {
                valid = false;
                
                if (showErrors) {
                    existingMP.Plan_Status__c.addError(REQUIRED_FIELD_MESSAGE);
                }
            }
        }
        
        return valid;
    }
    
    private void loadEnrollmentPaths() {
        enrollmentPaths =
        [SELECT Id,
                Name,
                Below_Minimum_Employee_Message__c,
                Below_Employee_Minimum_Reason_Required__c,
                Default_When_Less_Than_Employee_Minimum__c,
                Description__c,
                Employee_Minimum__c,
                Lead_Time__c,
                Level__c,
                Recommended__c,
                Recommended_Text__c,
                Status__c,
                Sub_Name__c,
                Summary__c,
                Platform_Setup_Field_Set__c
           FROM Enrollment_Path__c
          WHERE Division__c = :eOppty.Division__c
            AND Status__c = 'Active'
         ORDER BY Display_Order__c];
    }
    
    private void setEnrollmentRushRequested() {
        enrollmentRushRequested = isEnrollmentRushRequested(eOppty.Enrollment_Path__c);
    }

    private void setPayRollUploadRushed() {
        payrollDueDateRushed = isPayrollRushed();
    }
    
    private void setDefaultEnrollmentPath() {
        for (Enrollment_Path__c ep : EnrollmentPaths) {
            
            if (ep.Default_When_Less_Than_Employee_Minimum__c == true &&
                eOppty.Enrollment_Path__c == null &&
                ep.Employee_Minimum__c != null &&
                eOppty.Estimated_Employees__c != null &&
                eOppty.Estimated_Employees__c < ep.Employee_Minimum__c) {
                eOppty.Enrollment_Path__c = ep.Id;
                break;
            }
        }
    }
    
    private void setEnrollmentEmployeeThresholdInfo() {
        enrollmentEmployeeThresholdShort = false;
        enrollmentEmployeeShortMessage = '';
        
        Enrollment_Path__c selectedEnrollmentPath = getSelectedEnrollmentPath();
        
        if (selectedEnrollmentPath == null ||
            selectedEnrollmentPath.Employee_Minimum__c == null ||
            selectedEnrollmentPath.Below_Employee_Minimum_Reason_Required__c == null ||
            eOppty == null ||
            eOppty.Estimated_Employees__c == null) {
            return;
        }
        
        if (selectedEnrollmentPath.Below_Employee_Minimum_Reason_Required__c == true &&
            eOppty.Estimated_Employees__c < selectedEnrollmentPath.Employee_Minimum__c) {
            enrollmentEmployeeThresholdShort = true;
            enrollmentEmployeeShortMessage = selectedEnrollmentPath.Below_Minimum_Employee_Message__c;
        }
    }
    
    private Platform_Setup__c getPlatformSetup() {
         Set<String> platformSetupFields = getFieldSetFields( SObjectType.Platform_Setup__c.FieldSets.General_Information_Defaults );
         
         platformSetupFields.add(Platform_Setup__c.Enroll_Info_GrpToCcontactForData__c.getDescribe().getName());
         platformSetupFields.add(Platform_Setup__c.Enroll_Info_Service_Process__c.getDescribe().getName());
         platformSetupFields.add(Platform_Setup__c.Enrollment_Setup__c.getDescribe().getName());
         platformSetupFields.add(Platform_Setup__c.Requesting_Data__c.getDescribe().getName());
         platformSetupFields.add(Platform_Setup__c.Providing_Dependent_Data__c.getDescribe().getName());
         platformSetupFields.add(Platform_Setup__c.Below_Eligible_Employee_Threshold_Reason__c.getDescribe().getName());
         platformSetupFields.add(Platform_Setup__c.Payroll_Due_Date_Rush_Reason__c .getDescribe().getName());
            
         if (enrollmentPaths == null) {
             loadEnrollmentPaths();
         }
         
         List<Schema.FieldSet> enrollmentPathFieldSets = new List<Schema.FieldSet>();
         Map<String, Schema.FieldSet> platformSetupFieldSets =  Schema.SObjectType.Platform_Setup__c.fieldSets.getMap();
         
         for (Enrollment_Path__c ep : EnrollmentPaths) {
             if (String.isNotBlank(ep.Platform_Setup_Field_Set__c) &&
                 platformSetupFieldSets.containsKey(ep.Platform_Setup_Field_Set__c)) {
                 enrollmentPathFieldSets.add(platformSetupFieldSets.get(ep.Platform_Setup_Field_Set__c));
             }
         }
         
         platformSetupFields.addAll( getFieldSetFields(enrollmentPathFieldSets) );
         
         Id enrollmentFormId = ef.Id;
         
         String query = 'SELECT Id, ' + String.join(new List<String>(platformSetupFields), ',') +
                         ' FROM Platform_Setup__c ' +
                         'WHERE Enrollment_Form__c = :enrollmentFormId ' +
                         '  AND (recordType.Name=\'AFES Form\' or recordType.Name=\'AWD Form\')' +
                         ' LIMIT 1';

        return Database.query(query);
    }
    
    private Enrollment_Path__c getSelectedEnrollmentPath() {
        if (EnrollmentPaths == null ||
            eOppty.Enrollment_Path__c == null) {
            return null;
        }
        
        for (Enrollment_Path__c ep : EnrollmentPaths) {
            if (ep.Id == eOppty.Enrollment_Path__c) {
                return ep;
            }
        }
        
        return null;
    }
    
    private Set<String> getEnrollmentPathPlatformSetupRequiredFields() {
        if (testRequiredPlatformSetupFields != null &&
            testRequiredPlatformSetupFields.isEmpty() == false) {
            return testRequiredPlatformSetupFields;
        }
        
        Set<String> requiredPlatformSetupFields = new Set<String>(); 

        Enrollment_Path__c selectedEnrollmentPath = getSelectedEnrollmentPath();
        
        if (selectedEnrollmentPath == null ||
            String.isBlank(selectedEnrollmentPath.Platform_Setup_Field_Set__c)) {
            return requiredPlatformSetupFields;
        }

        Schema.FieldSet platformSetupFieldSet = 
            Schema.SObjectType.Platform_Setup__c.fieldSets.getMap().get(selectedEnrollmentPath.Platform_Setup_Field_Set__c);

        return getRequiredFieldSetMembers(platformSetupFieldSet).keySet();
    }
    
    private void setDefaults() {
        if (eOppty != null &&
            eOppty.Are_you_changing_AFenroll_Frequencies__c == null) {
            eOppty.Are_you_changing_AFenroll_Frequencies__c = 'No';
        }
    }
   
    public class catalogWrapper {
         public boolean addProduct          {get; set;}
         public Product_Catalog__c pCatalog {get; set;}
          
         public catalogWrapper(Product_Catalog__c pc) {
             this.addProduct = false;
             this.pCatalog = pc;
         }
    }
}