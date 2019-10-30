public with sharing class MySetupFormsController {
    
    @AuraEnabled
    public static Context getMyInProgressEnrollmentOpportunities() {
        return getEnrollmentOpportunities('In Progress', UserInfo.getUserId());
    }
    
    @AuraEnabled
    public static Context getEnrollmentOpportunities(String status, Id opportunityOwnerId) {
        List<Enrollment_Form__c> enrollmentForms =
        [SELECT Id,
                Name,
                Enrollment_Opportunity__c,
                Enrollment_Opportunity__r.Name,
                Enrollment_Opportunity__r.Enrollment_Start_Date__c,
                Preenrollment_Marketing_Form_Status__c,
                Customer_Setup_Form_Status__c,
                Platform_Setup_Status__c,
                Section_125_Status__c
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__r.OwnerId = :opportunityOwnerId AND
                Enrollment_Opportunity__r.StageName = 'Enrollment' AND
               ( Preenrollment_Marketing_Form_Status__c = :status OR 
                 Customer_Setup_Form_Status__c = :status OR
                 Platform_Setup_Status__c = :status OR
                 Section_125_Status__c = :status )
          ORDER BY Enrollment_Opportunity__r.Enrollment_Start_Date__c Nulls Last];
        
        Context c = new Context(enrollmentForms, status);
        
        c.CurrentStatusFilter = status;
        c.CurrentOppOwnerIdFilter = opportunityOwnerId;
        
        return c;
    }
    
    public class Context {
        @AuraEnabled
        public List<EnrollmentOpportunity> EnrollmentOpportunities { get; set; }
        
        @AuraEnabled
        public List<String> SetupFormStatuses { get; set; }
        
        @AuraEnabled
        public String CurrentStatusFilter { get; set; }
        
        @AuraEnabled
        public String CurrentOppOwnerIdFilter { get; set; }
        
        public Context(List<Enrollment_Form__c> enrollmentForms, String statusFilter) {
            this();
            this.CurrentStatusFilter = statusFilter;
            
            for (Enrollment_Form__c enrollmentForm : enrollmentForms) {
                EnrollmentOpportunity eo = new EnrollmentOpportunity(enrollmentForm, statusFilter);
                
                EnrollmentOpportunities.add(eo);
            }
        }
        
        public Context() {
            EnrollmentOpportunities = new List<EnrollmentOpportunity>();
            
            List<String> platformSetupStatuses = PicklistController.getPicklistOptions('Status__c', 'Platform_Setup__c');
            List<String> customerSetupStatuses = PicklistController.getPicklistOptions('Status__c', 'Customer_Setup_Form__c');
            List<String> s125SetupStatuses = PicklistController.getPicklistOptions('Status__c', 'Section_125_Setup_Form__c');
            List<String> preEnrollmentStatuses = PicklistController.getPicklistOptions('Status__c', 'Pre_Enrollment_Marketing_Form__c');
            
            Set<String> allStatuses = new Set<String>(platformSetupStatuses);
            allStatuses.addAll(customerSetupStatuses);
            allStatuses.addAll(s125SetupStatuses);
            allStatuses.addAll(preEnrollmentStatuses);
            
            SetupFormStatuses = new List<String>(allStatuses);
            SetupFormStatuses.sort();
        }
    }
    
    public class EnrollmentOpportunity {
        @AuraEnabled
        public Opportunity Record { get; set; }
        
        @AuraEnabled
        public List<SetupForm> SetupForms { get; set; }
        
        public EnrollmentOpportunity() {
            SetupForms = new List<SetupForm>();
        }
        
        public EnrollmentOpportunity(Enrollment_Form__c enrollmentForm, String statusFilter) {
            this();
            
            Record = enrollmentForm.Enrollment_Opportunity__r;
            
            if (String.isNotBlank(enrollmentForm.Preenrollment_Marketing_Form_Status__c) &&
                enrollmentForm.Preenrollment_Marketing_Form_Status__c == statusFilter) {
                addSetupForm('Preenrollment Marketing Form');
            }
            
            if (String.isNotBlank(enrollmentForm.Customer_Setup_Form_Status__c) &&
                enrollmentForm.Customer_Setup_Form_Status__c == statusFilter) {
                addSetupForm('Customer Setup Form');
            }
            
            if (String.isNotBlank(enrollmentForm.Platform_Setup_Status__c) &&
                enrollmentForm.Platform_Setup_Status__c == statusFilter) {
                addSetupForm('Platform Setup Form');
            }
            
            if (String.isNotBlank(enrollmentForm.Section_125_Status__c) &&
                enrollmentForm.Section_125_Status__c == statusFilter) {
                addSetupForm('Section 125 Form');
            }
        }
        
        private void addSetupForm(String setupFormName) {
            SetupForm sf = new SetupForm();
            sf.Name = setupFormName;
            SetupForms.add(sf);
        }
    }
    
    public class SetupForm {
        @AuraEnabled
        public String Name { get; set; }
    }
}