public virtual with sharing class PreEnrollmentControllerBase {
    public static final String REQUIRED_FIELD_MESSAGE = 'Required Field';
    
    public Enrollment_Form__c EF { get; set; }
    public Opportunity eOppty { get; set; }   //enrollment Opportunity { get; set; }
    public Account Acc { get; set; }
    public Boolean ShowErrorMessages { get; set; }
    public String StatusMsg { get; set; }
    public String FieldName { get; set; }
    public String FieldValue { get; set; }
    public Boolean FormIsSubmitted { get; set; }
    public Boolean ReloadPage { get; set; }
    public String UnlockReason { get; set; }
    public Boolean cameFromReservice { get; set; }

    public PageReference reloadPage() {
        system.debug('    reloadPage::ReloadPage: ' + ReloadPage);
        
        if (ReloadPage != null && ReloadPage) {
            PageReference reloadCurrentPage = new PageReference(ApexPages.currentPage().getUrl());
            
            reloadCurrentPage.getParameters().put('Id', ApexPages.currentPage().getParameters().get('Id'));
            
            reloadPage = false;
            
            reloadCurrentPage.setRedirect(true);
            
            system.debug('    reloadPage::reloadCurrentPage: ' + reloadCurrentPage);
            
            return reloadCurrentPage;
        }
        
        return null;
    }
    
    private transient Boolean IsUnlockedPriv = null;
    public Boolean IsUnlocked {
        get {
            if (IsUnlockedPriv == null) {
                IsUnlockedPriv = UnlockRequestsByUser.containsKey(UserInfo.getUserId());
            }
            
            return IsUnlockedPriv;
        }
    }
    
    public Map<Id, Unlock_Request__c> UnlockRequestsByUser {
        get {
            Map<Id, Unlock_Request__c> UnlockRequestsByUserPriv = new Map<Id, Unlock_Request__c>();
                
            Id enrollmentFormId = EF != null ? EF.Id : null;

            List<Unlock_Request__c> unlockRequestsInProgress = getInProgressUnlockRequests(enrollmentFormId);

            for (Unlock_Request__c inProgressUnlockRequest : unlockRequestsInProgress) {
                UnlockRequestsByUserPriv.put(inProgressUnlockRequest.CreatedById, inProgressUnlockRequest);
            }
            
            return UnlockRequestsByUserPriv;
        }
    }
    
    public void createUnlockRequest() {
        try {
	        Unlock_Request__c unlockRequest = new Unlock_Request__c();
	        unlockRequest.Enrollment_Form__c = EF.Id;
	        unlockRequest.Unlock_Reason__c = UnlockReason;
	        
	        insert unlockRequest;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
            showErrorMessages = true;
            ReloadPage = false;
        }
    }
    
    public void completeUnlockRequest() {
        try {
            Unlock_Request__c unlockRequest = UnlockRequestsByUser.get(UserInfo.getUserId());
            
            if (unlockRequest != null) {
                unlockRequest.Status__c = 'Complete';
                update unlockRequest;
                
                IsUnlockedPriv = null;
            }
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
            showErrorMessages = true;
            ReloadPage = false;
        }
    }
    
    public Boolean getHasErrorMessages() {
        return ApexPages.hasMessages(ApexPages.Severity.ERROR);
    }
    
    protected void updateRecord(SObject record) {
        ShowErrorMessages = false;
        try {
            update record;
            
            checkRequiredFieldsAndDoNotDisplay();
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
            showErrorMessages = true;
        }
    }
    
    @TestVisible
    protected void updateFieldOnRecord(SObject record, String apiFieldName, String newFieldValue) {
        showErrorMessages = false;
        
        system.debug('    updateFieldOnRecord::record ' + record);
        system.debug('    updateFieldOnRecord::apiFieldName ' + apiFieldName);
        system.debug('    updateFieldOnRecord::newFieldValue ' + newFieldValue);

        try
        {
            Schema.SObjectType sObjectType = record.getSObjectType();
            Schema.DescribeSObjectResult sObjectDesc = sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = sObjectDesc.fields.getMap();
            
            Schema.SObjectField field = fieldsMap.get(apiFieldName);
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            Schema.DisplayType fieldDisplayType = fieldDesc.getType();
            
            Object convertedFieldValue = convertFieldValueToStronglyTypedValue(newFieldValue, fieldDisplayType);
            
            system.debug('    updateFieldOnRecord::convertedFieldValue ' + convertedFieldValue);    
            
            record.put(apiFieldName, convertedFieldValue);
            update record;
            
            checkRequiredFieldsAndDoNotDisplay();
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);
            showErrorMessages = true;
        }
    }
    
    protected virtual void checkRequiredFieldsAndDoNotDisplay() {
        
    }
    
    protected Map<String, Schema.FieldSetMember> getRequiredFieldSetMembers(Schema.FieldSet fieldSet) {
        return getRequiredFieldSetMembers(new List<Schema.FieldSet>{ fieldSet });
    }
    
    protected Map<String, Schema.FieldSetMember> getRequiredFieldSetMembers(List<Schema.FieldSet> fieldSets) {
        Map<String, Schema.FieldSetMember> requiredFields = new Map<String, Schema.FieldSetMember>();
        
        for (Schema.FieldSet fieldSetToCheck : fieldSets) {
            for (Schema.FieldSetMember field : fieldSetToCheck.getFields()) {
                if (field.getRequired()) {
                    requiredFields.put(field.getFieldPath(), field);
                }
            }
        }
        
        return requiredFields;
    }
    
    protected Set<String> getFieldSetFields(Schema.FieldSet fieldSet) {
        return getFieldSetFields(new List<Schema.FieldSet>{ fieldSet });
    }
    
    protected Set<String> getFieldSetFields(List<Schema.FieldSet> fieldSets) {
        Set<String> fieldNames = new Set<String>();
        
        for (Schema.FieldSet fieldSet : fieldSets) {
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                fieldNames.add(field.getFieldPath());
            }
        }
        
        return fieldNames;
    }
    
    private List<Unlock_Request__c> getInProgressUnlockRequests(Id enrollmentFormId) {
        List<Unlock_Request__c> unlockRequests = new List<Unlock_Request__c>();
        
        if (enrollmentFormId == null) {
            return unlockRequests;
        }
        
        unlockRequests =
        [SELECT Id,
                Name,
                Unlock_Reason__c,
                Status__c,
                CreatedById
           FROM Unlock_Request__c
          WHERE Enrollment_Form__c = :enrollmentFormId
            AND Status__c  = 'In Progress'
            AND CreatedById = :UserInfo.getUserId()];

        return unlockRequests;
    }
    
    private Object convertFieldValueToStronglyTypedValue(String fieldValue, Schema.DisplayType fieldDisplayType) {
        if (String.isBlank(fieldValue)) {
            return fieldValue;
        }
        
        if (fieldDisplayType == Schema.DisplayType.Boolean) {
            Boolean boolValue = null;
            
            if (fieldValue == '1') {
                boolValue = true;
            }
            else if (fieldValue == '0') {
                boolValue = false;
            }
            else {
                boolValue = Boolean.valueOf(fieldValue);
            }
            
            system.debug('    convertFieldValueToStronglyTypedValue::fieldValue ' + fieldValue);
            system.debug('    convertFieldValueToStronglyTypedValue::boolValue ' + boolValue);
            
            return boolValue;
        }
        
        return fieldValue;
    }
    
    protected void setCameFromReserviceFlag() {
        String isReservice = ApexPages.currentPage().getParameters().get('ReserviceSetup');
        cameFromReservice = isReservice == 'true';
    }
}