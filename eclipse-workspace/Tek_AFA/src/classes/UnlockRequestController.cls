public with sharing class UnlockRequestController {
    public Id EnrollmentFormId {
        get;
        set {
            EnrollmentFormId = value;
            if (value != null) {
                loadUnlockRequestsByOthers();
            }
        }
    }
    
    public List<Unlock_Request__c> UnlockRequestsByOthers { get; set; }
    
    public static Boolean hasUnlockSetupFormsPerm { get; set; }
    
    static {
        hasUnlockSetupFormsPerm = FeatureManagement.checkPermission('Unlock_Setup_Forms');
    }
    
    public UnlockRequestController() {
        loadUnlockRequestsByOthers();
    }
    
    private void loadUnlockRequestsByOthers() {
        UnlockRequestsByOthers = new List<Unlock_Request__c>();

        if (EnrollmentFormId == null ||
            hasUnlockSetupFormsPerm == false) {
            return;
        }

        UnlockRequestsByOthers =
        [SELECT Id,
                Name,
                Unlock_Reason__c,
                Status__c,
                CreatedById,
                CreatedBy.Name
        FROM Unlock_Request__c
        WHERE Enrollment_Form__c = :EnrollmentFormId
        AND Status__c  = 'In Progress'
        AND CreatedById != :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static List<Unlock_Request__c> getUnlocksByOtherUsers(String enrollmentFormId){
        if(!hasUnlockSetupFormsPerm) 
            return null;

        List<Unlock_Request__c> activeUnlocks = 
        [SELECT Id,
                Name,
                Unlock_Reason__c,
                Status__c,
                CreatedById,
                CreatedBy.Name
        FROM Unlock_Request__c
        WHERE Enrollment_Form__c = :enrollmentFormId
            AND Status__c  = 'In Progress'
            AND CreatedById != :UserInfo.getUserId()];

        return activeUnlocks;
    }

    @AuraEnabled
    public static Unlock_Request__c getExistingUnlockRequestByUser(String enrollmentFormId){
        if(!hasUnlockSetupFormsPerm) 
            return null;

        try
        {
            Unlock_Request__c activeUserUnlock = 
            [SELECT Id,
                    Name,
                    Unlock_Reason__c,
                    Status__c,
                    CreatedById,
                    CreatedBy.Name
            FROM Unlock_Request__c
            WHERE Enrollment_Form__c = :enrollmentFormId
                AND Status__c  = 'In Progress'
                AND CreatedById = :UserInfo.getUserId() LIMIT 1];

                return activeUserUnlock;
        }
        catch (System.QueryException queryException){
            // No record found
            return null;
        } 
    }

    @AuraEnabled
    public static Boolean hasUnlockSetupFormsPermission(){
        return hasUnlockSetupFormsPerm;
    }

    @AuraEnabled
    public static Unlock_Request__c createNewUnlockRequest(String enrollmentFormId, Unlock_Request__c request){

        request.Enrollment_Form__c = enrollmentFormId;
        request.Status__c = 'In Progress';
        request.Unlock_Datetime__c = system.now();

        insert request;

        return request;
    }

    @AuraEnabled
    public static void completeUnlockRequest(Unlock_Request__c request){
        request.Status__c = 'Complete';
        request.Lock_Datetime__c = system.now();
        
        update request;
    }
}