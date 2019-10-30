/**
 * @description Builder class for dealing with Opportunity records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public without sharing class OpportunityTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Opportunity state for OpportunityTestData.
     * @return A map of Opportunity default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Opportunity.Name => 'Metillium, Inc.',
            Opportunity.StageName => 'Enrollment',
            Opportunity.CloseDate =>  Date.today().addDays(30),
            Opportunity.Are_you_changing_AFenroll_Frequencies__c => 'No'
        };
    }
    
    /**
     * @description Returns the SObject type for OpportunityTestData builder.
     * @return Opportunity.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Opportunity.SObjectType;
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Sets the account id on the oppportunity
     * @param accountId The id of the account the opportunity will be linked to.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withAccount(Id accountId) {
        return (OpportunityTestData) withDynamicData(Opportunity.AccountId, accountId);
    }
    
    /**
     * @description Sets the branch office on the oppportunity
     * @param branchOfficeId The id of the branch office the opportunity will be linked to.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withBranchOffice(Id branchOfficeId) {
        return (OpportunityTestData) withDynamicData(Opportunity.Branch_Office__c, branchOfficeId);
    }

    /**
     * @description Sets the record type on the opportunity.
     * @param recordTypeId The record type that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withRecordTypeId(Id recordTypeId) {
        return (OpportunityTestData) withDynamicData(Opportunity.RecordTypeId, recordTypeId);
    }
    
    /**
     * @description Sets the online appointment scheduler on the opportunity.
     * @param onlineAppointmentScheduler The online appointment scheduler that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withOnlineAppointmentScheduler(String onlineAppointmentScheduler) {
        return (OpportunityTestData) withDynamicData(Opportunity.Online_Appointment_Scheduler__c, onlineAppointmentScheduler);
    }
    
    /**
     * @description Sets the enrollment start date on the opportunity.
     * @param enrollmentStartDate The enrollment start date that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withEnrollmentStartDate(Date enrollmentStartDate) {
        return (OpportunityTestData) withDynamicData(Opportunity.Enrollment_Start_Date__c, enrollmentStartDate);
    }

    /**
     * @description Sets the enrollment end date on the opportunity.
     * @param enrollmentEndDate The enrollment end date that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withEnrollmentEndDate(Date enrollmentEndDate) {
        return (OpportunityTestData) withDynamicData(Opportunity.Enrollment_End_Date__c, enrollmentEndDate);
    }
    
    /**
     * @description Sets the effective date of AFA products on the opportunity.
     * @param effectiveDateOfAFAProducts The effective date of AFA products that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withEffectiveDateOfAFAProducts(Date effectiveDateOfAFAProducts) {
        return (OpportunityTestData) withDynamicData(Opportunity.Effective_Date_of_AFA_Products__c, effectiveDateOfAFAProducts);
    }

    /**
     * @description Sets the assigned account manager on the opportunity.
     * @param assignedAccountManagerId The id of the assigned account manager that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withAssignedAccountManager(Id assignedAccountManagerId) {
        return (OpportunityTestData) withDynamicData(Opportunity.Assigned_Account_Manager__c, assignedAccountManagerId);
    }
    
    /**
     * @description Sets the employer benefits site on the opportunity.
     * @param employerBenefitsSite The employer benefits site that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withEmployerBenefitsSite(String employerBenefitsSite) {
        return (OpportunityTestData) withDynamicData(Opportunity.Employer_Benefits_Site__c, employerBenefitsSite);
    }
    
    /**
     * @description Sets the has section 125 setup form on the opportunity.
     * @param hasSection125SetupForm The has section 125 setup form that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withHasSection125SetupForm(Boolean hasSection125SetupForm) {
        return (OpportunityTestData) withDynamicData(Opportunity.Has_Section_125_setup_form__c, hasSection125SetupForm);
    }

    /**
     * @description Sets new or existing group on the opportunity.
     * @param newOrExistingGroup The new or existing group that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withConfirmNewOrExistingGroup(String newOrExistingGroup) {
        return (OpportunityTestData) withDynamicData(Opportunity.Confirm_New_or_Existing_Group__c, newOrExistingGroup);
    }

    /**
     * @description Sets division on the opportunity.
     * @param division The division that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withDivision(String division) {
        return (OpportunityTestData) withDynamicData(Opportunity.Division__c, division);
    }

    /**
     * @description Sets the AFEnroll Case Id on the opportunity.
     * @param afEnrollCaseId The AFEnroll Case Id that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withAFEnrollCaseId(String afEnrollCaseId) {
        return (OpportunityTestData) withDynamicData(Opportunity.AFEnroll_Case_Id__c, afEnrollCaseId);
    }

    /**
     * @description Sets the enrollment path on the opportunity.
     * @param enrollmentPathId The enrollment path that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withEnrollmentPath(Id enrollmentPathId) {
        return (OpportunityTestData) withDynamicData(Opportunity.Enrollment_Path__c, enrollmentPathId);
    }

    /**
     * @description Sets the created date on the opportunity.
     * @param createdDate The created date that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withCreatedDate(DateTime createdDate) {
        return (OpportunityTestData) withDynamicData(Opportunity.CreatedDate, createdDate);
    }

    /**
     * @description Sets the add a section 125 plan on the opportunity.
     * @param addASection125Plan The add a section 125 plan that the opportunity will have.
     * @return The instance of OpportunityTestData.
     */
    public OpportunityTestData withAddASection125Plan(Boolean addASection125Plan) {
        return (OpportunityTestData) withDynamicData(Opportunity.Add_a_Section_125_Plan__c, addASection125Plan);
    }    

    /**
     * @description Builds the Opportunity object.
     * @return The created Opportunity object.
     */
    public Opportunity create() {
        return (Opportunity)super.buildWithReset();
    }

    /**
     * @description Inserts the built Opportunity object.
     * @return The inserted Opportunity object.
     */
    public Opportunity insertOpportunity() {
        return (Opportunity)super.insertRecord();
    }
    
    /**
     * @description Sets the record type to 'AFES Enrollment'.
     * @return This instance of the OpportunityTestData.
     */
    public OpportunityTestData useAFESEnrollmentRecordType() {
        Map<String,Schema.RecordTypeInfo> opportunityRecordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        Schema.RecordTypeInfo afesEnrollmentRTI = opportunityRecordTypes.get('AFES Enrollment');
        withRecordTypeId(afesEnrollmentRTI.getRecordTypeId());
        withDivision('AFES');
        
        return this;
    }
    
    /**
     * @description Sets the record type to 'AWD Enrollment'.
     * @return This instance of the OpportunityTestData.
     */
    public OpportunityTestData useAWDEnrollmentRecordType() {
        Map<String,Schema.RecordTypeInfo> opportunityRecordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        Schema.RecordTypeInfo awdEnrollmentRTI = opportunityRecordTypes.get('AWD Enrollment');
        withRecordTypeId(awdEnrollmentRTI.getRecordTypeId());
        
        return this;
    }
    
    /**
     * @description Inserts the build Opportunity object with an AFES record type.
     * @return The inserted Opportunity.
     */
    public Opportunity insertAFESOpportunity() {
        useAFESEnrollmentRecordType();

        return insertOpportunity();
    }
    
    /*
     * @description Inserts the opportunity with an AFES record type and with Employer Benefits Site
     *              set to 'Yes'.
     * @return The inserted Opportunity.
     */
    public Opportunity insertAFESWithEmployerBenefitsSiteOpportunity() {
        useAFESEnrollmentRecordType();
        
        withEmployerBenefitsSite('Yes');
        
        return insertOpportunity();
    }

    /**
     * @description Inserts the build Opportunity object with an AWD record type.
     * @return The inserted Opportunity.
     */    
    public Opportunity insertAWDOpportunity() {
        useAWDEnrollmentRecordType();
        
        return insertOpportunity();
    }
    
    /**
     * @description Inserts the specified number of opportunities.
     * @param numToInsert The number of opportunities to insert.
     * @return The inserted Opportunities.
     */ 
    public List<Opportunity> insertOpportunities(Integer numToInsert) {
        return (List<Opportunity>) super.insertRecords(numToInsert);
    }
    
    protected override void beforeBuild() {
        Object accountId = currentValueFor(Opportunity.AccountId);
        
        system.debug('   beforeBuild::accountId ' + accountId);
        
        if (accountId == null) {
            Account customerAccount = AccountTestData.Instance.insertCustomerAccount();
            
            system.debug('   beforeBuild::customerAccount.RecordTypeId ' + customerAccount.RecordTypeId);
            
            withAccount(customerAccount.Id);
        }
    }
    
    /**
     * @description Gets an instance of OpportunityTestData.
     * @return OpportunityTestData instance.
     */
    public static OpportunityTestData Instance {
        get {
            if (Instance == null) {
                Instance = new OpportunityTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private OpportunityTestData() {
        super();
    }
}