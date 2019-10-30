public with sharing class GeneralInformationPDFInfoController {
    
    private Id enrollmentFormIdPriv = null;
    public Id enrollmentFormId {
        get {
            return enrollmentFormIdPriv;
        }
        set {
            enrollmentFormIdPriv = value;
            
            loadGeneralInformationData(enrollmentFormIdPriv);
        }
    }
    
    public Enrollment_Form__c enrollmentForm    { get; set; }
    public List<OpportunityTeamMember> oppTeam  { get; set; }
    public Opportunity enrollmentOpp            { get; set; }
    public Account acct                         { get; set; }
    public List <Marketed_Product__c> benefitMarketedProducts { get; set; } 
    public List <Marketed_Product__c> serviceMarketedProducts { get; set; } 
    public List <Marketed_Product__c> importMarketedProducts { get; set; }
    public List<OpportunityTeamMember> oppTeamOwner     { get; set; }
    public Customer_Setup_Form__c csf                   { get; set; }
    public Platform_Setup__c  ps                        { get; set; }
    public Section_125_Setup_Form__c s125 { get; set; }
    public List<EnrollmentContact> enrollmentContacts { get; set; }
    
    public Boolean IsReservice {
        get {
            return enrollmentOpp != null &&
                   enrollmentOpp.Confirm_New_or_Existing_Group__c == 'Existing' &&
                   String.isNotBlank(acct.MCP_Number__c) &&
                   acct.Status__c == 'Active';
        }
    }

    public Boolean IsNewSetup {
        get {
            return enrollmentOpp != null &&
                   enrollmentOpp.Confirm_New_or_Existing_Group__c == 'New' &&
                   String.isBlank(acct.MCP_Number__c);
        }
    }

    public Schema.FieldSet getEnrollmentPathPlatformSetupFieldSet() {
        Map<String, Schema.FieldSet> platformSetupFieldSets =  Schema.SObjectType.Platform_Setup__c.fieldSets.getMap();

        if (enrollmentOpp.Enrollment_Path__r != null &&
            String.isNotBlank(enrollmentOpp.Enrollment_Path__r.Platform_Setup_Field_Set__c) &&
            platformSetupFieldSets.containsKey(enrollmentOpp.Enrollment_Path__r.Platform_Setup_Field_Set__c)) {

            return platformSetupFieldSets.get(enrollmentOpp.Enrollment_Path__r.Platform_Setup_Field_Set__c);
        }
        
        return null;
    }
    
    private void loadGeneralInformationData(Id efId) {
        if (efId == null) {
            return;
        }
        
        csf = getCustomerSetupFormByEnrollmentForm(efId);
        enrollmentForm = getEnrollmentFormById(efId);
        s125 = getPrimarySection125FormByEnrollmentFormId(efId);
        
        if (enrollmentForm.Enrollment_Opportunity__r != null) {
            enrollmentOpp = enrollmentForm.Enrollment_Opportunity__r;
            formatEnrollmentOppFields();

            acct = enrollmentOpp.Account;
            oppTeam = getOpportunityTeamByOpportunityId(enrollmentOpp.Id);
            oppTeamOwner = getOpportunityTeamOwnersByOpportunityId(enrollmentOpp.Id);
        }
        
        loadEnrollmentContacts(enrollmentOpp, csf, s125);
        
        loadMarketedProducts(efId);
        
        ps = getPlatformSetupByEnrollmentFormId(efId);
    }
    
    private Customer_Setup_Form__c getCustomerSetupFormByEnrollmentForm(Id efId) {
        String whereClause = 'Enrollment_Form__c = \'' + efId + '\'';
        Set<String> customSetupFormFields = Util.getObjectCreatableFields('Customer_Setup_Form__c');
        customSetupFormFields.add('Enrollment_Form__r.Enrollment_Opportunity__c');

        String customerSetupFormQuery = 'Select ' + String.join(new List<String>(customSetupFormFields), ',') +
                                        '  from Customer_Setup_Form__c' +
                                        ' where Enrollment_Form__c = \'' + efId + '\'';

        List<Customer_Setup_Form__c> records = Database.query(customerSetupFormQuery);

        if (records.size() > 0) {
            return records[0];
        }

        return null;
    }
    
    private Enrollment_Form__c getEnrollmentFormById(Id efId) {
        return
        [SELECT Id,
                Name,
                Enrollment_Opportunity__c,
                Enrollment_Opportunity__r.Id,
                Enrollment_Opportunity__r.Name, 
                Enrollment_Opportunity__r.AccountId, 
                Enrollment_Opportunity__r.Enrollment_Start_Date__c, 
                Enrollment_Opportunity__r.Enrollment_End_Date__c, 
                Enrollment_Opportunity__r.Administrative_Contact__c, 
                Enrollment_Opportunity__r.Group_Name__c, 
                Enrollment_Opportunity__r.Legal_Name__c, 
                Enrollment_Opportunity__r.MCP_Number__c,                                      
                Enrollment_Opportunity__r.Tax_ID__c, 
                Enrollment_Opportunity__r.Additional_MCPs__c, 
                Enrollment_Opportunity__r.Estimated_Employees__c, 
                Enrollment_Opportunity__r.Effective_Date_of_Core_Products__c, 
                Enrollment_Opportunity__r.Effective_Date_of_AFA_Products__c, 
                Enrollment_Opportunity__r.Employee_Eligibility_Waiting_Period__c,
                Enrollment_Opportunity__r.EE_Eligibility_Waiting_Period__c,
                Enrollment_Opportunity__r.Residence_State_s__c,
                Enrollment_Opportunity__r.Marketed_Products__c,
                Enrollment_Opportunity__r.Platform__c,
                Enrollment_Opportunity__r.Enrollment_Setup_Notes__c,
                Enrollment_Opportunity__r.Legal_Name_is_different_than_Group_Name__c,
                Enrollment_Opportunity__r.Plan_Date_New__c,
                Enrollment_Opportunity__r.Assigned_Account_Manager__r.Name,
                Enrollment_Opportunity__r.Working_Conditions__c,
                Enrollment_Opportunity__r.Division__c, 
                Enrollment_Opportunity__r.Confirm_New_or_Existing_Group__c,
                Enrollment_Opportunity__r.Are_you_adding_new_plans_or_services__c,
                Enrollment_Opportunity__r.Are_you_making_any_billing_changes__c,
                Enrollment_Opportunity__r.Requesting_Open_Enrollment__c,
                Enrollment_Opportunity__r.Waiting_Period_Effective__c,
                Enrollment_Opportunity__r.Other_Eligibility_Waiting_Period__c,
                Enrollment_Opportunity__r.Physical_Address_Same_As_Billing__c,
                Enrollment_Opportunity__r.Account.BillingStreet,
                Enrollment_Opportunity__r.Account.BillingCity,
                Enrollment_Opportunity__r.Account.BillingState,
                Enrollment_Opportunity__r.Account.BillingPostalCode,
                Enrollment_Opportunity__r.Account.ShippingStreet,
                Enrollment_Opportunity__r.Account.ShippingCity,
                Enrollment_Opportunity__r.Account.ShippingState,
                Enrollment_Opportunity__r.Account.ShippingPostalCode,
                Enrollment_Opportunity__r.Account.Owner.Name,
                Enrollment_Opportunity__r.Account.Owner.Title, 
                Enrollment_Opportunity__r.Account.Owner.Phone, 
                Enrollment_Opportunity__r.Account.Owner.EmployeeNumber, 
                Enrollment_Opportunity__r.Account.Owner.Email, 
                Enrollment_Opportunity__r.Account.Owner.Agent_ID__c, 
                Enrollment_Opportunity__r.Account.Owner.Extension,
                Enrollment_Opportunity__r.Account.payroll_company__c,
                Enrollment_Opportunity__r.Account.AFenroll_Pay_Groups__c,
                Enrollment_Opportunity__r.Account.Status__c,
                Enrollment_Opportunity__r.Account.MCP_Number__c,
                Enrollment_Opportunity__r.Enrollment_Rush_Request_Reason__c,
                Enrollment_Opportunity__r.Enrollment_Path__c,
                Enrollment_Opportunity__r.Enrollment_Path__r.Platform_Setup_Field_Set__c,
                Enrollment_Opportunity__r.Are_you_changing_AFenroll_Frequencies__c,
                Enrollment_Opportunity__r.New_AFenroll_Deduction_Frequencies__c
           FROM Enrollment_Form__c
          WHERE Id = :efId];
    }
    
    private void loadEnrollmentContacts(Opportunity enrollmentOpportunity, Customer_Setup_Form__c customerSetupForm, Section_125_Setup_Form__c section125) {
        List<EnrollmentContactMetadata> enrollmentContactMetadatas = new List<EnrollmentContactMetadata> {
            // sourceRecordArg, sourceContactFieldNameArg, sameAsAdminContactFieldNameArg, contactTypeArg
            new EnrollmentContactMetadata(enrollmentOpportunity, 'Administrative_Contact__c', '', 'Administrative Contact'),
            new EnrollmentContactMetadata(customerSetupForm, 'ContactInfoBenefitContact__c', 'ContactInfoBenefitContactSame__c', 'Benefit Contact'),
            new EnrollmentContactMetadata(customerSetupForm, 'ContactInfoBillingContact__c', 'ContactInfoBillingContactSame__c', 'Billing Contact'),
            new EnrollmentContactMetadata(section125, 'ContactInfoS125Contact__c', 'S125S125ContactSameAsAdmin__c', 'Section 125 Contact'),
            new EnrollmentContactMetadata(section125, 'ContactInfoFlexContact__c', 's125FlexContactSameAsAdmin__c', 'Flex Contact'),
            new EnrollmentContactMetadata(customerSetupForm, 'Annuity_Contact__c', 'AnnBeforeTaxContInfoSameAdminContact__c', 'Annuity Contact'),
            new EnrollmentContactMetadata(section125, 'HlthSvgsAcctEligReq__c', 'HlthSvgsAcctIsHSAcontactsameasAdmin__c', 'HSA Contact')
        };
        
        EnrollmentContacts = new List<EnrollmentContact>();
        Set<Id> enrollmentContactIds = new Set<Id>();
        
        for (EnrollmentContactMetadata ecm : enrollmentContactMetadatas) {
            if (ecm.SourceRecord == null) { continue; }
            
            Id sourceContactId = (Id) ecm.SourceRecord.get(ecm.SourceContactFieldName);
            
            if (sourceContactId == null) { continue; }
            
            enrollmentContactIds.add(sourceContactId);
            
            EnrollmentContact enrollmentContact = new EnrollmentContact(ecm.ContactType, sourceContactId);
            
            if (String.isNotBlank(ecm.SameAsAdminContactFieldName)) {
                enrollmentContact.HasSameAsAdminContactField = true;
                enrollmentContact.SameAsAdminContactYesNo = (String) ecm.SourceRecord.get(ecm.SameAsAdminContactFieldName);
            }
            
            EnrollmentContacts.add(enrollmentContact);
        }

        if (enrollmentContactIds.isEmpty()) {
            return;
        }

        Map<Id, Contact> contacts = new Map<Id, Contact>(
        [SELECT Id,
                Name,
                Title,
                Phone,
                Extension__c,
                Email
           FROM Contact
          WHERE Id in :enrollmentContactIds]);

        for (EnrollmentContact ec : EnrollmentContacts) {
            ec.Record = contacts.get(ec.ContactId);
        }
    }

    private void loadMarketedProducts(Id efId) {
        List<Marketed_Product__c> enrollmentMarketedProducts =
        [SELECT Id,
                Tax_Treatment__c,
                Product_Description__c,
                Plan_Status__c,
                Family__c,
                Carrier__c,
                AOR__c, 
                products__r.name,
                products__r.Tax_Treatment__c,
                products__r.Order__c,
                products__r.Rider__c,
                products__r.Type__c,
                Employer_Paid_Portion__c
           FROM Marketed_Product__c 
          WHERE enrollment__c = :efId
            AND products__r.Type__c in ('Benefit', 'Import', 'Service')
            AND products__r.Allowed_To_Be_Added_To_Enrollment__c = true
          ORDER BY products__r.Order__c];

        benefitMarketedProducts = new List<Marketed_Product__c>();
        serviceMarketedProducts = new List<Marketed_Product__c>();
        importMarketedProducts = new List<Marketed_Product__c>();

        for (Marketed_Product__c mp : enrollmentMarketedProducts) {
            if (mp.products__r.Type__c == 'Benefit') {
                benefitMarketedProducts.add(mp);
            }
            else if (mp.products__r.Type__c == 'Service') {
                serviceMarketedProducts.add(mp);
            }
            else if (mp.products__r.Type__c == 'Import') {
                importMarketedProducts.add(mp);
            }
        }
    }
    
    private List<OpportunityTeamMember> getOpportunityTeamByOpportunityId(Id opportunityId) {
        return
        [SELECT Id,
                TeamMemberRole,
                UserId,
                User.Name,
                User.Email,
                User.Phone,
                OpportunityAccessLevel,
                user.Network_Id__c,
                user.Agent_ID__c 
           FROM OpportunityTeamMember 
          WHERE OpportunityId = :opportunityId];
    }
    
    private List<OpportunityTeamMember> getOpportunityTeamOwnersByOpportunityId(Id opportunityId) {
        return
        [SELECT Id,
                TeamMemberRole,
                User.Name,
                User.Email,
                User.Phone,
                OpportunityAccessLevel,
                user.Network_Id__c,
                user.Agent_ID__c 
           FROM OpportunityTeamMember
          WHERE OpportunityId = :opportunityId
            AND TeamMemberRole = 'Opportunity Owner'];
    }
    
    private Platform_Setup__c getPlatformSetupByEnrollmentFormId(Id efId) {
        // There should always be one Platform Setup record for an enrollment.
        Set<String> platformSetupFields = Util.getFieldSetFields( SObjectType.Platform_Setup__c.FieldSets.General_Information_Defaults );
         
        Schema.FieldSet enrollmentPathPlatformSetupFieldSet = getEnrollmentPathPlatformSetupFieldSet();

        if (enrollmentPathPlatformSetupFieldSet != null) {
            platformSetupFields.addAll( Util.getFieldSetFields(enrollmentPathPlatformSetupFieldSet) );
        }

        Id enrollmentFormId = efId;

        String query = 'SELECT Id, ' + String.join(new List<String>(platformSetupFields), ',') +
                        ' FROM Platform_Setup__c ' +
                        'WHERE Enrollment_Form__c = :enrollmentFormId ' +
                        '  AND (recordType.Name=\'AFES Form\' or recordType.Name=\'AWD Form\')' +
                        ' LIMIT 1';

        return Database.query(query);
    }
    
    
    
    private Section_125_Setup_Form__c getPrimarySection125FormByEnrollmentFormId(Id efId) {
        List<Section_125_Setup_Form__c> s125s =
        [SELECT Id,
                ContactInfoS125Contact__c,
                S125S125ContactSameAsAdmin__c,
                ContactInfoFlexContact__c,
                s125FlexContactSameAsAdmin__c,
                HlthSvgsAcctEligReq__c,
                HlthSvgsAcctIsHSAcontactsameasAdmin__c
           FROM Section_125_Setup_Form__c
          WHERE Enrollment_Form__c = :efId
          limit 1];

        if (s125s.size() > 0) {
            return s125s[0];
        }
        
        return null;
    }
    
    private void formatEnrollmentOppFields() {
        if (String.isNotBlank(enrollmentOpp.Additional_MCPs__c)) {
            enrollmentOpp.Additional_MCPs__c = enrollmentOpp.Additional_MCPs__c.replace(',', ', ');
        }
    }
    
    private class EnrollmentContactMetadata {
        public SObject SourceRecord { get; set; }
        
        public String SourceContactFieldName { get; set; }

        public String SameAsAdminContactFieldName { get; set; }

        public String ContactType { get; set; }
        
        public EnrollmentContactMetadata(SObject sourceRecordArg, String sourceContactFieldNameArg, String sameAsAdminContactFieldNameArg, String contactTypeArg) {
            this.SourceRecord = sourceRecordArg;
            this.SourceContactFieldName = sourceContactFieldNameArg;
            this.sameAsAdminContactFieldName = sameAsAdminContactFieldNameArg;
            this.ContactType = contactTypeArg;
        }
    }
    
    public class EnrollmentContact {
        public Id ContactId { get; set; }
        
        public Contact Record { get; set; }
        
        public String ContactType { get; set; }
        
        public Boolean HasSameAsAdminContactField { get; set; }
        
        public String SameAsAdminContactYesNo { get; set; }
        
        public EnrollmentContact(String contactTypeArg, Id contactIdArg) {
            this.ContactType = contactTypeArg;
            this.ContactId = contactIdArg;
            HasSameAsAdminContactField = false;
        }
    }
}