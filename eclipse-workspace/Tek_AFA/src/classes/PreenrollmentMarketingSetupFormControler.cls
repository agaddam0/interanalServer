public with sharing class PreenrollmentMarketingSetupFormControler extends PreEnrollmentControllerBase {
    public static final String PRINTED_MATERIAL_MAILING_ADDRESS_REQUIRED_VAL_MSG = 'The printed materials mailing address is required when printed materials are ordered.';
    public static final String PRINTED_MATERIAL_DUE_DATE_REQUIRED_VAL_MSG = 'The printed materials due date is required when printed materials are ordered.';
    public static final String ONE_WAY_TO_ENROLL_REQUIRED_VAL_MSG = 'At least one way to enroll must be selected.';
    public static final String CARRIER_REQUIRED_ON_IMPORT_PRODUCT_VAL_MSG = 'The carrier is required when it is to be included on the employer benefits site.';
    public static final String CARRIER_URL_REQUIRED_ON_IMPORT_PRODUCT_VAL_MSG = 'The carrier url is required when it is to be included on the employer benefits site.';
    public static final String PRE_ENROLLMENT_MARKETING_FORM_STATUS_SUBMITTED = 'Submitted';
    public static final String PRE_ENROLLMENT_MARKETING_FORM_STATUS_COMPLETE = 'Complete';
    public static final String PRE_ENROLLMENT_MARKETING_FORM_STATUS_PENDING_UPDATE = 'Pending Update';
    public static final String PRE_ENROLLMENT_MARKETING_FORM_STATUS_UPDATED = 'Updated';
    public static final String PRE_ENROLLMENT_MARKETING_FORM_STATUS_DECLINED = 'Declined';
    public static final String PRE_ENROLLMENT_MARKETING_FORM_STATUS_IN_PROGRESS = 'In Progress';
    public static final String GROUP_DISPLAY_NAME_REQUIRED_VAL_MSG = 'The group display name is required when either the employer benefits site is requested or the online appointment scheduler is requested.';
    public static final String BRANCH_OFFICE_REQUIRED_VAL_MSG = 'The branch office is required when either the employer benefits site is requested or the online appointment scheduler is requested for an AFES enrollment.';
    
    public Pre_Enrollment_Marketing_Form__c PreenrollmentMarketingForm { get; set; }
    public Platform_Setup__c PlatformSetup { get; set; }
    
    public Date S125PlanYearStartDate { get; set; }
    public String S125PlanYearStartDateFormatted {
        get {
            return S125PlanYearStartDate != null ? S125PlanYearStartDate.format() : '';
        }
    }
    public Date S125PlanYearEndDate { get; set; }
    public String S125PlanYearEndDateFormatted {
        get {
            return S125PlanYearEndDate != null ? S125PlanYearEndDate.format() : '';
        }
    }

    public Boolean MarketingInformationTabComplete { get; set; }
    public Boolean EmployerBenefitsSiteTabComplete { get; set; }
    public Boolean GroupMeetingsTabComplete { get; set; }
    public Boolean PrintedMaterialFieldsRequired { get; set; }
    public Boolean GroupDisplayNameRequired { get; set; }
    public Boolean BranchOfficeRequired { get; set; }

    public Boolean ShowGroupMeetings { get; set; }
    public Group_Meeting__c GroupMeetingToAdd { get; set; }
    public List<Group_Meeting__c> ExistingGroupMeetings { get; set; }
    public Id GroupMeetingIdToDelete { get; set; }
    public Id GroupMeetingIdToUpdate { get; set; }
    
    public String EmployerLogoFileName { get; set; }
    public Blob EmployerLogoFileContents { get; set; }
    public Id EmployerLogoIdToDelete { get; set; }
    public List<ContentDocumentLink> EmployerLogoContentDocumentLinks { get; set; }
    public List<Marketed_Product__c> EmployerSiteEligibleBenefitAndServicesMarketedProducts { get; set; }
    public List<Marketed_Product__c> EmployerSiteEligibleImportMarketedProducts { get; set; }
    public Id MarketedProductIdToUpdate { get; set; }
    public String AppointmentSchedulerURL { get; set; }
    public String AppointmentSchedulerError { get; set; }
    public Boolean EmployerLogoUploaded { get; set; }
    public Boolean EmployerLogoDeleted { get; set; }
    public Boolean AccountHasMarketingResourceId { get; set; }
    public Boolean FormNowSubmitted { get; set; }
    public Boolean SendUpdateQueuedSuccessfully { get; set; }
    public String MarketPlaceURL { get; set; }
    
    @testVisible
    private String DefaultEmployerBenefitsSiteForTesting { get; set; }
    
    @testVisible
    private Map<String, Schema.FieldSetMember> TestEmployerBenefitSiteRequiredFields { get; set; }

    @testVisible
    private Map<String, Schema.FieldSetMember> TestGroupMeetingRequiredFields { get; set; }
    
    @testVisible
    private Map<String, Schema.FieldSetMember> TestMarketingInformationRequiredFields { get; set; }
    
    public PreenrollmentMarketingSetupFormControler(ApexPages.StandardController stdController) {
        addExtraFieldsToStandardController(stdController);
        
        PreenrollmentMarketingForm = (Pre_Enrollment_Marketing_Form__c) stdController.getRecord();
        
        instantiateNewGroupMeetingToAdd();
        LoadExistingGroupMeetings();
        setFormIsSubmitted();
        setShowGroupMeetings();
        LoadPlatformSetupRecord();
        LoadEmployerLogoContentDocumentLinks();
        LoadEmployerSiteEligibleMarketedProducts();
        LoadOpportunity();
        PrepopulateMarketingForm();
        LoadMarketplaceURL();
        
        checkRequiredFieldsAndDoNotDisplay();
        
        EmployerLogoUploaded = false;
        EmployerLogoDeleted = false;
        FormNowSubmitted = false;
        AccountHasMarketingResourceId = true;
    }
    
    public String getMarketingMaterialsSectionLabel() {
        return SObjectType.Pre_Enrollment_Marketing_Form__c.FieldSets.Marketing_Materials.getLabel();
    }
    
    public String getSpecialInstructionsSectionLabel() {
        return SObjectType.Pre_Enrollment_Marketing_Form__c.FieldSets.Special_Instructions.getLabel();
    }
    
    public String getMarketingInformationSectionLabel() {
        return SObjectType.Opportunity.FieldSets.Marketing_Information.getLabel();
    }
    
    public String getBenefitsSiteCustomizationSectionLabel() {
        return SObjectType.Pre_Enrollment_Marketing_Form__c.FieldSets.Benefit_Site_Customization.getLabel();
    }
    
    public void updatePreenrollmentMarketingForm() {
        updateRecord(PreenrollmentMarketingForm);
    }
    
    public void saveNewGroupMeeting() {
        try {
            insert GroupMeetingToAdd;
            
            instantiateNewGroupMeetingToAdd();
            loadExistingGroupMeetings();
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }
    
    public void updateGroupMeeting() {
        Map<Id, Group_Meeting__c> existingGroupMeetingsMap = new Map<Id, Group_Meeting__c>(ExistingGroupMeetings);
        
        Group_Meeting__c groupMeetingToUpdate = existingGroupMeetingsMap.get(GroupMeetingIdToUpdate);
        
        updateRecord(groupMeetingToUpdate);
    }
    
    public void deleteGroupMeeting() {
        try {
            Group_Meeting__c groupMeetingToDelete = new Group_Meeting__c(Id = GroupMeetingIdToDelete);
            
            delete groupMeetingToDelete;
            
            loadExistingGroupMeetings();
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
    }
    
    public void checkRequiredFieldsAndDisplay() {
        marketingInformationCheckRequiredFields(true);
        employerBenefitsSiteCheckRequiredFields(true);
        groupMeetingsCheckRequiredFields(true);
    }
    
    public override void checkRequiredFieldsAndDoNotDisplay() {
        marketingInformationCheckRequiredFields(false);
        employerBenefitsSiteCheckRequiredFields(false);
        groupMeetingsCheckRequiredFields(false);
    }
    
    public void submitForm() {
        updateFormToStatus(PRE_ENROLLMENT_MARKETING_FORM_STATUS_SUBMITTED);
    }
    
    public void updateFormToStatus(String status) {
        ShowErrorMessages = true;

        try {
            PreenrollmentMarketingForm.Status__c = status;
            
            update PreenrollmentMarketingForm;
            
            setFormIsSubmitted();
            
            FormNowSubmitted = true;
        }
        catch(Exception ex) {
            ApexPages.AddMessages(ex);
        }
    }
    
    public void UploadEmployerLogo() {
        if (String.isBlank(EmployerLogoFileName) ||
            EmployerLogoFileContents == null) {
            return;
        }
        
        ContentVersion cv = new ContentVersion(
            versionData = EmployerLogoFileContents,
            title = EmployerLogoFileName,
            description = 'Employer Logo',
            pathOnClient = '/' + EmployerLogoFileName,
            OwnerId = UserInfo.getUserId()
        );
        
        insert cv;
        
        ContentVersion cvQueried = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            linkedEntityId = PreenrollmentMarketingForm.Id,
            contentDocumentId = cvQueried.contentDocumentId,
            shareType = 'I'
        );
        
        insert cdl;
        
        Account employer = PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Account;
        employer.Logo_On_File__c = 'Yes';
        update employer;
        
        LoadEmployerLogoContentDocumentLinks();
        
        EmployerLogoUploaded = true;
    }
    
    public void DeleteEmployerLogo() {
        system.debug('  DeleteEmployerLogo::EmployerLogoIdToDelete ' + EmployerLogoIdToDelete);
        
        if (EmployerLogoIdToDelete == null) {
            return;
        }
        
        ContentDocument fileToDelete = new ContentDocument(Id = EmployerLogoIdToDelete);
        delete fileToDelete;
        
        LoadEmployerLogoContentDocumentLinks();
        
        EmployerLogoDeleted = true;
    }
    
    public void updateMarketedProduct()
    {
        showErrorMessages = false;

        Marketed_Product__c mp = null;
        
        List<Marketed_Product__c> allMPs = new List<Marketed_Product__c>();
        allMPs.addAll(EmployerSiteEligibleImportMarketedProducts);
        allMPs.addAll(EmployerSiteEligibleBenefitAndServicesMarketedProducts);
        
        for (Marketed_Product__c potentialMP : allMPs) {
            if (potentialMP.Id == MarketedProductIdToUpdate) {
                mp = potentialMP;
                break;
            }
        }

        updateFieldOnRecord(mp, FieldName, FieldValue);
    }
    
    public void sendUpdate() {
        ShowErrorMessages = true;
        SendUpdateQueuedSuccessfully = false;

        try {
            PreenrollmentMarketingForm.Status__c = PRE_ENROLLMENT_MARKETING_FORM_STATUS_PENDING_UPDATE;
            
            update PreenrollmentMarketingForm;
            
            setFormIsSubmitted();
            
            SendUpdateQueuedSuccessfully = true;
        }
        catch(Exception ex) {
            ApexPages.AddMessages(ex);
        }
    }
    
    public void loadAppointmentScheduler() {
        AppointmentSchedulerURL = '';
        AppointmentSchedulerError = '';
        AccountHasMarketingResourceId = true;
        
        //AppointmentSchedulerURL = 'https://benefits-qa.americanfidelity.com/field/scheduler/inter-session/c4d1f90c-ac75-4aec-a27c-cc3daf6c9a00/';
        try {
	        ESBFieldSchedulerTokenServiceClient client = new ESBFieldSchedulerTokenServiceClient(PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.AccountId);
	
	        ESBFieldSchedulerTokenServiceClient.FieldSchedulerTokenResponse response = client.GetFieldSchedulerToken();
	        
	        if (String.isNotBlank(response.Token)) {
	            AppointmentSchedulerURL = ESBPreenrollmentMarketingIntegrationUtil.buildEmployerFieldSchedulerURL(response.Token);
	        }
	        else if (response.ErrorMessage == Label.Appointment_Scheduler_No_Marketing_Resource_Id_Message) {
	            AccountHasMarketingResourceId = false;
	        }
	        else {
	            AppointmentSchedulerError = response.ErrorMessage;
	        }
        }
        catch (Exception ex) {
            AppointmentSchedulerError = ex.getMessage();
        }
    }
    
    public void updateEnrollmentOpportunity() {
        try
        {
            System.debug('### updateEnrollmentOpportunity::eOppty: ' + eOppty);

            update eOppty;
            
            if (eOppty.Online_Appointment_Scheduler__c == 'No' &&
                eOppty.Employer_Benefits_Site__c == 'No') {
                updateFormToStatus(PRE_ENROLLMENT_MARKETING_FORM_STATUS_DECLINED);
            }
            
            if (PreenrollmentMarketingForm.Status__c == PRE_ENROLLMENT_MARKETING_FORM_STATUS_DECLINED &&
                (eOppty.Online_Appointment_Scheduler__c == 'Yes' ||
                 eOppty.Employer_Benefits_Site__c == 'Yes')) {
                updateFormToStatus(PRE_ENROLLMENT_MARKETING_FORM_STATUS_IN_PROGRESS);
            }
            
            checkRequiredFieldsAndDoNotDisplay();
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
            showErrorMessages = true;
        }
    }
    
    public void requestEmployerUpsert() {
        PreenrollmentMarketingForm.Send_Employer_Upsert_Request__c = true;
        update PreenrollmentMarketingForm;
    }
    
    private void addExtraFieldsToStandardController(ApexPages.StandardController stdController) {
        Set<string> fieldnames = new Set<string>();
        
        fieldnames.add('Enrollment_Form__c');
        fieldnames.add('Status__c');
        fieldnames.add('Enrollment_Form__r.Enrollment_Opportunity__r.Account.Name');
        fieldnames.add('Enrollment_Form__r.Enrollment_Opportunity__r.Account.Marketing_Resource_ID__c');
        fieldnames.add('Enrollment_Form__r.Enrollment_Opportunity__r.Account.Enrollment_Site__c');
        fieldnames.add('Enrollment_Form__r.Enrollment_Opportunity__r.Account.Logo_on_File__c');
        fieldnames.add('Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_Start_Date__c');
        fieldnames.add('Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_End_Date__c');
        fieldnames.add('License_Number_Required__c');
        fieldnames.add('Show_HR_Contact__c');
        fieldnames.add('Show_Broker_Contact__c');
        fieldnames.add('Show_Kiosk_Information__c');
        fieldnames.add('Show_One_on_One_Information__c');
        fieldnames.add('Show_Self_Service_Information__c');
        fieldnames.add('Show_AF_HR_Central_Information__c');
        
        
        List<Schema.FieldSet> fieldSetsToUse = new List<Schema.FieldSet>{
            SObjectType.Pre_Enrollment_Marketing_Form__c.FieldSets.Marketing_Materials,
            SObjectType.Pre_Enrollment_Marketing_Form__c.FieldSets.Special_Instructions,
            SObjectType.Pre_Enrollment_Marketing_Form__c.FieldSets.Benefit_Site_Customization
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
    
    private void instantiateNewGroupMeetingToAdd() {
        GroupMeetingToAdd = new Group_Meeting__c(
            Pre_Enrollment_Marketing_Form__c = PreenrollmentMarketingForm.Id
        );
    }
    
    private void loadExistingGroupMeetings() {
        String existingGroupMeetingsSOQL = 'SELECT Id ';
        
        for (Schema.FieldSetMember editGroupMeetingField : SObjectType.Group_Meeting__c.FieldSets.EditGroupMeetingFields.getFields()) {
            existingGroupMeetingsSOQL += ', ' + editGroupMeetingField.getFieldPath();
        }
        
        Id PreEnrollmentMarketingFormId = PreenrollmentMarketingForm.Id;
        
        existingGroupMeetingsSOQL += ' FROM Group_Meeting__c WHERE Pre_Enrollment_Marketing_Form__c = :PreEnrollmentMarketingFormId';
        
        ExistingGroupMeetings = Database.query(existingGroupMeetingsSOQL);
    }
    
    private void setFormIsSubmitted() {
        FormIsSubmitted = PreenrollmentMarketingForm != null &&
                          (PreenrollmentMarketingForm.Status__c == PRE_ENROLLMENT_MARKETING_FORM_STATUS_SUBMITTED ||
                           PreenrollmentMarketingForm.Status__c == PRE_ENROLLMENT_MARKETING_FORM_STATUS_COMPLETE ||
                           PreenrollmentMarketingForm.Status__c == PRE_ENROLLMENT_MARKETING_FORM_STATUS_PENDING_UPDATE ||
                           PreenrollmentMarketingForm.Status__c == PRE_ENROLLMENT_MARKETING_FORM_STATUS_UPDATED ||
                           PreenrollmentMarketingForm.Status__c == PRE_ENROLLMENT_MARKETING_FORM_STATUS_DECLINED);
    }
    
    private void setShowGroupMeetings() {
        ShowGroupMeetings = Label.Group_Meeting_Setting == 'True';
    }
    
    private void LoadPlatformSetupRecord() {
        List<Platform_Setup__c> platformSetupRecords =
        [SELECT Id,
                Name,
                Enrollment_Form__c,
                S125OtherSvcPlanStartDate__c,
                S125OtherSvcPlanEndDate__c
           FROM Platform_Setup__c
          WHERE Enrollment_Form__c = :PreenrollmentMarketingForm.Enrollment_Form__c
            and (recordType.Name='AFES Form' or recordType.Name='AWD Form')];

        if (platformSetupRecords.size() > 0) {
            PlatformSetup = platformSetupRecords[0];
            
            S125PlanYearStartDate = PlatformSetup.S125OtherSvcPlanStartDate__c;
            S125PlanYearEndDate = PlatformSetup.S125OtherSvcPlanEndDate__c;
        }
    }
    
    private void LoadEmployerLogoContentDocumentLinks() {
        List<ContentDocumentLink> marketingFiles = new List<ContentDocumentLink>();
        
        if (PreenrollmentMarketingForm != null &&
            PreenrollmentMarketingForm.Id != null) {
            marketingFiles =
	        [SELECT Id,
	                ContentDocumentId,
	                ContentDocument.Title,
	                ContentDocument.LatestPublishedVersionId,
	                ContentDocument.Description
	           FROM ContentDocumentLink
	          WHERE linkedEntityId = :PreenrollmentMarketingForm.Id];
        }
          
        
        EmployerLogoContentDocumentLinks = new List<ContentDocumentLink>();
        
        for (ContentDocumentLink marketingFile : marketingFiles) {
            if (marketingFile.ContentDocument.Description == 'Employer Logo') {
                EmployerLogoContentDocumentLinks.add(marketingFile);
            }
        }
    }
    
    private void LoadEmployerSiteEligibleMarketedProducts() {
        EmployerSiteEligibleBenefitAndServicesMarketedProducts = new List<Marketed_Product__c>();
        EmployerSiteEligibleImportMarketedProducts = new List<Marketed_Product__c>();
        
        if (PreenrollmentMarketingForm != null &&
            PreenrollmentMarketingForm.Enrollment_Form__c != null) {
                
            Id enrollmentFormId = PreenrollmentMarketingForm.Enrollment_Form__c;
            
            // Benefits and Services SOQL
            Set<String> benefitssAndServicesFields = getFieldSetFields(new List<Schema.FieldSet>{ SObjectType.Marketed_Product__c.FieldSets.Benefits_Services });
            benefitssAndServicesFields.add('Name');
            benefitssAndServicesFields.add('Products__r.Type__c');
            
            String benefitssAndServiceSOQL = 'SELECT Id, ' + String.join(new List<String>(benefitssAndServicesFields), ',') +
                                            '  FROM Marketed_Product__c ' +
                                            ' WHERE Enrollment__c = :enrollmentFormId ' +
                                            '   AND Products__r.Employer_Benefits_Site_Eligible__c = true ' +
                                            '   AND Products__r.Type__c in (\'Benefit\', \'Service\')' +
                                            ' ORDER BY Products__r.Name';

            EmployerSiteEligibleBenefitAndServicesMarketedProducts = Database.query(benefitssAndServiceSOQL);
            
            // Import products SOQL
            
            Set<String> importFields = getFieldSetFields(new List<Schema.FieldSet>{ SObjectType.Marketed_Product__c.FieldSets.Imported_Products });
            importFields.add('Name');
            importFields.add('Products__r.Type__c');
            importFields.add('Carrier__c');
            importFields.add('Carrier_URL__c');
            importFields.add('Include_on_Employer_Benefits_Site__c');
            
            String importSOQL = 'SELECT Id, ' + String.join(new List<String>(importFields), ',') +
                                            '  FROM Marketed_Product__c ' +
                                            ' WHERE Enrollment__c = :enrollmentFormId ' +
                                            '   AND Products__r.Employer_Benefits_Site_Eligible__c = true ' +
                                            '   AND Products__r.Type__c in (\'Import\')' +
                                            ' ORDER BY Products__r.Name';

            EmployerSiteEligibleImportMarketedProducts = Database.query(importSOQL);
        }
    }
    
    private void LoadOpportunity() {
        Set<String> opportunityMarketingFields = getFieldSetFields(new List<Schema.FieldSet>{ SObjectType.Opportunity.FieldSets.Marketing_Information });
        opportunityMarketingFields.add('RecordType.Name');
        opportunityMarketingFields.add('Account.Employer_Benefits_Site_Request_DateTime__c');
        
        Id oppId = PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__c;
        
        String opportunitySOQL = 'SELECT ' + String.join(new List<String>(opportunityMarketingFields), ',') +
                                  ' FROM Opportunity' +
                                 ' WHERE Id = :oppId';

        List<Opportunity> opps = Database.query(opportunitySOQL);
        
        if (opps.size() > 0) {
            eOppty = opps[0];
        }
        // This is done for unit tests.
        else {
            eOppty = new Opportunity();
            eOppty.Employer_Benefits_Site__c = DefaultEmployerBenefitsSiteForTesting;
        }
    }
    
    private void marketingInformationCheckRequiredFields(boolean showErrorMessage) {
        ShowErrorMessages = false;
        MarketingInformationTabComplete = true;
        GroupDisplayNameRequired = false;
        BranchOfficeRequired = false;
        
        // LF 1/2018: Make sure validation occurs against the latest data in case
        // stuff wasn't saved to the database because one didn't have edit access
        // to the opportunity. Talked to Steph and she mentioned we shouldn't have to do 
        // this anywhere else at this time. 
        LoadOpportunity();
        
        if (eOppty.Online_Appointment_Scheduler__c == 'Yes' ||
            eOppty.Employer_Benefits_Site__c == 'Yes') {
            GroupDisplayNameRequired = true;
            BranchOfficeRequired = true;
        }
        
        Map<String, Schema.FieldSetMember> requiredMarketingInformationFields = getMarketingInformationRequiredFields();
           
        if (requiredMarketingInformationFields.containsKey(Opportunity.Employer_Benefits_Site__c.getDescribe().getName()) &&
            String.isBlank(eOppty.Employer_Benefits_Site__c)) {
            
            if (showErrorMessage) {
                eOppty.Employer_Benefits_Site__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            MarketingInformationTabComplete = false;
        }
        
        if (requiredMarketingInformationFields.containsKey(Opportunity.Online_Appointment_Scheduler__c.getDescribe().getName()) &&
            String.isBlank(eOppty.Online_Appointment_Scheduler__c)) {
            
            if (showErrorMessage) {
                eOppty.Online_Appointment_Scheduler__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            MarketingInformationTabComplete = false;
        }
        
        if (requiredMarketingInformationFields.containsKey(Opportunity.Group_Display_Name__c.getDescribe().getName()) &&
            String.isBlank(eOppty.Group_Display_Name__c) &&
            PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Account.Marketing_Resource_ID__c == null) {
            
            if (showErrorMessage) {
                eOppty.Group_Display_Name__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            MarketingInformationTabComplete = false;
        }
        
        if (String.isBlank(eOppty.Group_Display_Name__c) &&
            PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Account.Marketing_Resource_ID__c == null &&
            (eOppty.Online_Appointment_Scheduler__c == 'Yes' ||
            eOppty.Employer_Benefits_Site__c == 'Yes')) {

            if (showErrorMessage) {
                eOppty.Group_Display_Name__c.addError(GROUP_DISPLAY_NAME_REQUIRED_VAL_MSG);
            }
            
            MarketingInformationTabComplete = false;
        }
        
        if (String.isBlank(eOppty.Branch_Office__c) &&
            (eOppty.Online_Appointment_Scheduler__c == 'Yes' ||
            eOppty.Employer_Benefits_Site__c == 'Yes') &&
            eOppty.RecordType != null &&
            eOppty.RecordType.Name.containsIgnoreCase('AFES')) {

            if (showErrorMessage) {
                eOppty.Branch_Office__c.addError(BRANCH_OFFICE_REQUIRED_VAL_MSG);
            }
            
            MarketingInformationTabComplete = false;
        }
    }
    
    private void employerBenefitsSiteCheckRequiredFields(boolean showErrorMessage){
        ShowErrorMessages = false;
        EmployerBenefitsSiteTabComplete = true;
        
        // Employer Benefits Site not needed so don't validate.
        if (String.isBlank(eOppty.Employer_Benefits_Site__c) ||
            eOppty.Employer_Benefits_Site__c != 'Yes') {
            return;
        }

        Map<String, Schema.FieldSetMember> requiredFields = getEmployerBenefitSiteRequiredFields();

        // Luke Freeland 4/19/2017: Tried to genericize this code by looking at the field set member's "Required"
        // value and if it's required, dynamically add the REQUIRED_FIELD_MESSAGE to the field. However, Salesforce
        // doesn't allow sObject.addError('field_name', <error_message>); so there's no way currently to dynamically
        // add an error to a specific field at run-time. The next best thing was to hard-code the required fields being checked
        // but only require them if the field is required in the field set.
        
        if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.Due_Date__c.getDescribe().getName()) &&
            PreenrollmentMarketingForm.Due_Date__c == null) {
            
            if (showErrorMessage) {
                PreenrollmentMarketingForm.Due_Date__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            EmployerBenefitsSiteTabComplete = false;
        }
        
        if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.Open_Enrollment_End__c.getDescribe().getName()) &&
            PreenrollmentMarketingForm.Open_Enrollment_End__c == null) {
            
            if (showErrorMessage) {
                PreenrollmentMarketingForm.Open_Enrollment_End__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            EmployerBenefitsSiteTabComplete = false;
        }
        
        if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.Open_Enrollment_Sart__c.getDescribe().getName()) &&
            PreenrollmentMarketingForm.Open_Enrollment_Sart__c == null) {
            
            if (showErrorMessage) {
                PreenrollmentMarketingForm.Open_Enrollment_Sart__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            EmployerBenefitsSiteTabComplete = false;
        }
        
        if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.Title__c.getDescribe().getName()) &&
            PreenrollmentMarketingForm.Title__c == null) {
            
            if (showErrorMessage) {
                PreenrollmentMarketingForm.Title__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            EmployerBenefitsSiteTabComplete = false;
        }
        
        
        // If Show HR Contact is checked, check the corresponding HR fields being required if they're marked as required in the field set.
        if (PreenrollmentMarketingForm.Show_HR_Contact__c) {
            if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.HR_Name__c.getDescribe().getName()) &&
                String.isBlank(PreenrollmentMarketingForm.HR_Name__c)) {
                
                if (showErrorMessage) {
                    PreenrollmentMarketingForm.HR_Name__c.addError(REQUIRED_FIELD_MESSAGE);
                }
                
                EmployerBenefitsSiteTabComplete = false;
            }
            
            if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.HR_Phone__c.getDescribe().getName()) &&
                String.isBlank(PreenrollmentMarketingForm.HR_Phone__c)) {
                
                if (showErrorMessage) {
                    PreenrollmentMarketingForm.HR_Phone__c.addError(REQUIRED_FIELD_MESSAGE);
                }
                
                EmployerBenefitsSiteTabComplete = false;
            }
            
            if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.HR_Email__c.getDescribe().getName()) &&
                String.isBlank(PreenrollmentMarketingForm.HR_Email__c)) {
                
                if (showErrorMessage) {
                    PreenrollmentMarketingForm.HR_Email__c.addError(REQUIRED_FIELD_MESSAGE);
                }
                
                EmployerBenefitsSiteTabComplete = false;
            }
        }
        
        // If Show Broker Contact is checked, check the corresponding Broker fields being required if they're marked as required in the field set.
        if (PreenrollmentMarketingForm.Show_Broker_Contact__c) {
            if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.Broker_Name__c.getDescribe().getName()) &&
                String.isBlank(PreenrollmentMarketingForm.Broker_Name__c)) {
                
                if (showErrorMessage) {
                    PreenrollmentMarketingForm.Broker_Name__c.addError(REQUIRED_FIELD_MESSAGE);
                }
                
                EmployerBenefitsSiteTabComplete = false;
            }
            
            if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.Broker_Phone__c.getDescribe().getName()) &&
                String.isBlank(PreenrollmentMarketingForm.Broker_Phone__c)) {
                
                if (showErrorMessage) {
                    PreenrollmentMarketingForm.Broker_Phone__c.addError(REQUIRED_FIELD_MESSAGE);
                }
                
                EmployerBenefitsSiteTabComplete = false;
            }
            
            if (requiredFields.containsKey(Pre_Enrollment_Marketing_Form__c.Broker_Email__c.getDescribe().getName()) &&
                String.isBlank(PreenrollmentMarketingForm.Broker_Email__c)) {
                
                if (showErrorMessage) {
                    PreenrollmentMarketingForm.Broker_Email__c.addError(REQUIRED_FIELD_MESSAGE);
                }
                
                EmployerBenefitsSiteTabComplete = false;
            }
        }
        
        if (PreenrollmentMarketingForm.License_Number_Required__c &&
            PreenrollmentMarketingForm.License_No__c == null) {
            if (showErrorMessage) {
                PreenrollmentMarketingForm.License_No__c.addError(REQUIRED_FIELD_MESSAGE);
            }
            
            EmployerBenefitsSiteTabComplete = false;
        }
        
        if ((PreenrollmentMarketingForm.Show_AF_HR_Central_Information__c == null || PreenrollmentMarketingForm.Show_AF_HR_Central_Information__c == false) &&
            (PreenrollmentMarketingForm.Show_Kiosk_Information__c == null || PreenrollmentMarketingForm.Show_AF_HR_Central_Information__c == false) &&
            (PreenrollmentMarketingForm.Show_One_on_One_Information__c == null || PreenrollmentMarketingForm.Show_One_on_One_Information__c == false) &&
            (PreenrollmentMarketingForm.Show_Self_Service_Information__c == null || PreenrollmentMarketingForm.Show_Self_Service_Information__c == false)) {
            if (showErrorMessage) {
                PreenrollmentMarketingForm.Show_One_on_One_Information__c.addError(ONE_WAY_TO_ENROLL_REQUIRED_VAL_MSG);
            }
            
            EmployerBenefitsSiteTabComplete = false;
        }
        
        for (Marketed_Product__c importProduct : EmployerSiteEligibleImportMarketedProducts) {
            if (!importProduct.Include_on_Employer_Benefits_Site__c) { continue; }
            
            if (String.isBlank(importProduct.Carrier__c)) {
                
                if (showErrorMessage) {
                    importProduct.Carrier__c.addError(CARRIER_REQUIRED_ON_IMPORT_PRODUCT_VAL_MSG);
                }

                EmployerBenefitsSiteTabComplete = false;
            }
            
            if (String.isBlank(importProduct.Carrier_URL__c)) {
                if (showErrorMessage) {
                    importProduct.Carrier_URL__c.addError(CARRIER_URL_REQUIRED_ON_IMPORT_PRODUCT_VAL_MSG);
                }

                EmployerBenefitsSiteTabComplete = false;
            }
        }
    }
    
    private void groupMeetingsCheckRequiredFields(Boolean showErrorMessage) {
        ShowErrorMessages = false;
        GroupMeetingsTabComplete = true;
        
        // The group meetings feature is not enabled so don't check any required field on any group meeting records.
        if (ShowGroupMeetings == false) {
            return;
        }
        
        Map<String, Schema.FieldSetMember> requiredFields = getGroupMeetingRequiredFields();
        
        for (Group_Meeting__c groupMeeting : ExistingGroupMeetings) {
            if (requiredFields.containsKey(Group_Meeting__c.Site_Name__c.getDescribe().getName()) &&
                String.isBlank(groupMeeting.Site_Name__c)) {
                
                if (showErrorMessage) {
                    groupMeeting.Site_Name__c.addError(REQUIRED_FIELD_MESSAGE);
                }
                
                GroupMeetingsTabComplete = false;
            }
            
            if (requiredFields.containsKey(Group_Meeting__c.Date_Start_Time__c.getDescribe().getName()) &&
                groupMeeting.Date_Start_Time__c == null) {
                
                if (showErrorMessage) {
                    groupMeeting.Date_Start_Time__c.addError(REQUIRED_FIELD_MESSAGE);
                }
                
                GroupMeetingsTabComplete = false;
            }
            
            if (requiredFields.containsKey(Group_Meeting__c.Location__c.getDescribe().getName()) &&
                groupMeeting.Location__c == null) {
                
                if (showErrorMessage) {
                    groupMeeting.Location__c.addError(REQUIRED_FIELD_MESSAGE);
                }
                
                GroupMeetingsTabComplete = false;
            }
        }
    }
    
    private Map<String, Schema.FieldSetMember> getEmployerBenefitSiteRequiredFields() {
        // Luke Freeland 4/21/2017
        // Allow the list of required fields to be overridable via tests.
        if (TestEmployerBenefitSiteRequiredFields != null &&
            !TestEmployerBenefitSiteRequiredFields.isEmpty()) {
            return TestEmployerBenefitSiteRequiredFields;
        }
        
        List<Schema.FieldSet> requiredFieldSetsToCheck = new List<Schema.FieldSet>{
            SObjectType.Pre_Enrollment_Marketing_Form__c.FieldSets.Marketing_Materials,
            SObjectType.Pre_Enrollment_Marketing_Form__c.FieldSets.Benefit_Site_Customization
        };
        
        return getRequiredFieldSetMembers(requiredFieldSetsToCheck);
    }
    
    private Map<String, Schema.FieldSetMember> getGroupMeetingRequiredFields() {
        // Luke Freeland 4/21/2017
        // Allow the list of required fields to be overridable via tests.
        if (TestGroupMeetingRequiredFields != null &&
            !TestGroupMeetingRequiredFields.isEmpty()) {
            return TestGroupMeetingRequiredFields;
        }
        
        List<Schema.FieldSet> requiredFieldSetsToCheck = new List<Schema.FieldSet>{
            SObjectType.Group_Meeting__c.FieldSets.EditGroupMeetingFields
        };
        
        return getRequiredFieldSetMembers(requiredFieldSetsToCheck);
    }
    
    private Map<String, Schema.FieldSetMember> getMarketingInformationRequiredFields() {
        if (TestMarketingInformationRequiredFields != null &&
            !TestMarketingInformationRequiredFields.isEmpty()) {
            return TestMarketingInformationRequiredFields;
        }
        
        List<Schema.FieldSet> requiredFieldSetsToCheck = new List<Schema.FieldSet>{
            SObjectType.Opportunity.FieldSets.Marketing_Information
        };
        
        return getRequiredFieldSetMembers(requiredFieldSetsToCheck);
    }
    
    private void PrepopulateMarketingForm() {
        if (PreenrollmentMarketingForm == null ||
            PreenrollmentMarketingForm.Enrollment_Form__c == null ||
            PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__c == null) {
            return;
        }
        
        Date enrollmentStartDate = PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_Start_Date__c;
        
        if (enrollmentStartDate != null &&
            PreenrollmentMarketingForm.Open_Enrollment_Sart__c == null) {
            PreenrollmentMarketingForm.Open_Enrollment_Sart__c = enrollmentStartDate;
        }
        
        Date enrollmentEndDate = PreenrollmentMarketingForm.Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_End_Date__c;
        
        if (enrollmentEndDate != null &&
            PreenrollmentMarketingForm.Open_Enrollment_End__c == null) {
            PreenrollmentMarketingForm.Open_Enrollment_End__c = enrollmentEndDate;
        }
    }
    
    private void LoadMarketplaceURL() {
        MarketPlaceURL = '/lightning/n/Shopping_Cart?c__PreenrollmentMarketingFormId=' + PreenrollmentMarketingForm.Id
                         + '&c__EnrollmentOpportunityId=' + eOppty.Id;
    }
}