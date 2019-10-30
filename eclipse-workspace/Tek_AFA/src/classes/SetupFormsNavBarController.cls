public without sharing class SetupFormsNavBarController {
    
    public boolean  showCustomerSetupForm               {get; set;}
    public boolean  showSection125Form                  {get; set;}
    public boolean  showOnePageSummaryForm              {get; set;}
    public boolean  showSignatureForm                   {get; set;}
    public boolean  enableNavBar                        {get; set;}
     
    public boolean  CustomerSetupFormSubmitted              {get; set;}
    public boolean  Section125FormSubmitted                 {get; set;}
    public boolean  OnePageSummaryFormSubmitted             {get; set;}
    public boolean  SignatureFormSubmitted                  {get; set;}
    public boolean  GeneralInfoFormSubmitted                {get; set;}
    public boolean  PlatformSetupFormSubmitted              {get; set;}
    public boolean  PreenrollmentMarketingFormSubmitted     {get; set;}
    
    public Enrollment_Form__c ef                            {get;set;}
    public Platform_Setup__c  ps                            {get;set;}
    public Customer_Setup_Form__c  cs                       {get;set;}
    public Section_125_Setup_Form__c  s125                  {get;set;}
    public Section_125_Plan_Summary__c s125PlanSummary      {get;set;}
    public List<Enrollment_Form__c> signatures              {get;set;}  // not sure how to set this one
    public Id opptyId                                       {get;set;}
    public Pre_Enrollment_Marketing_Form__c PreEnrollmentMarketingForm { get; set; }
    public Boolean isReserviceSetup							{get;set;}
 
    public String enrollmentFormId { 
        get;
        set {
            enrollmentFormId = value;
            system.debug('+++ enrollmentFormId: ' + enrollmentFormId);

            init();
        }
    }
    
    private static Boolean hasPreenrollmentSetupFormAccessPriv = null;
    public static Boolean HasPreenrollmentSetupFormAccess {
        get {
            if (hasPreenrollmentSetupFormAccessPriv == null) {
                SetupEntityAccess[] preenrollmentAccessSettings =
                [SELECT Id
                   FROM SetupEntityAccess
                  WHERE SetupEntityId IN (SELECT Id
                                            FROM ApexPage
                                           WHERE NamespacePrefix = '' AND Name = 'PreenrollmentMarketingSetupForm')
                    AND ParentId IN (SELECT PermissionSetId
                                       FROM PermissionSetAssignment
                                       WHERE AssigneeId = :UserInfo.getUserId())
                 LIMIT 1];

                hasPreenrollmentSetupFormAccessPriv = preenrollmentAccessSettings.size() > 0;
            }
            
            return hasPreenrollmentSetupFormAccessPriv;
        }
    }
      
    private void init() {
          /* General Information Form */
        
          ef = [select Id,status__c, Enrollment_Opportunity__c from Enrollment_Form__c  where  Id = :enrollmentFormId limit 1];
          if (ef.status__c != null && ef.Status__c != 'In Progress')
              GeneralInfoFormSubmitted = true;
          
         try {
             /* Customer Setup Form */
             cs = [select Id,status__c from Customer_Setup_Form__c where  Enrollment_Form__c = :enrollmentFormId limit 1];
             showCustomerSetupForm = true;
             if (cs.status__c != null && cs.Status__c != 'In Progress')
                CustomerSetupFormSubmitted = true;
             
             if(isReserviceSetup)
                 showCustomerSetupForm = false;
          }
         catch(exception e) {showCustomerSetupForm = false;}
     
            /* Services Form (S125) */
         try {
            s125 = [select Id,status__c from Section_125_Setup_Form__c  where  Enrollment_Form__c = :enrollmentFormId limit 1];
            showSection125Form = true;
             if (s125.status__c != null && s125.Status__c != 'In Progress')
                Section125FormSubmitted = true;
             
             if(isReserviceSetup)
                 showSection125Form = false;
         }
         catch(exception e) {showSection125Form = false;}
      
            /* One Page Summary */
         try {
            s125PlanSummary = [select Id,status__c from Section_125_Plan_Summary__c  where  Enrollment_Form__c = :enrollmentFormId limit 1];
            showOnePageSummaryForm = true;
             if (s125PlanSummary.status__c != null && s125PlanSummary.Status__c != 'In Progress')
                OnePageSummaryFormSubmitted = true;
             
             if(isReserviceSetup)
                 showOnePageSummaryForm = false;
         }
         catch(exception e) {showOnePageSummaryForm = false;}
            
            /* Signature Form(s)  This tab is always shown */
         try {  
             signatures = [select Id,status__c from Enrollment_Form__c  where  Enrollment_Opportunity__c =: ef.Enrollment_Opportunity__c and recordType.name != 'Master'];
             
             SignatureFormSubmitted = true;
             for(Enrollment_Form__c signature : signatures)
             {
                 if (signature.status__c == null || signature.Status__c == 'In Progress')
                     SignatureFormSubmitted = false;
             }
             
             if(isReserviceSetup)
                 showSignatureForm = false;
         }
         catch(exception e) {showSignatureForm = false;}
       
            /* Platform Setup Form */
        ps = [select Id,status__c 
              from Platform_Setup__c  
              where  Enrollment_Form__c = :enrollmentFormId
              and (recordType.Name='AFES Form' or recordType.Name='AWD Form')
              limit 1];
        if (ps.status__c != null && ps.Status__c != 'In Progress')
                PlatformSetupFormSubmitted = true;
    
          /* enable the navbar if there are any marketed products */
          try {
                Marketed_Product__c mp = [select Id from Marketed_Product__c where enrollment__c = :enrollmentFormId limit 1];
                enableNavBar = true;
          }
          catch(exception e){enableNavBar = false;}
          
        /* Pre-Enrollment Form Setup */
        List<Pre_Enrollment_Marketing_Form__c> preenrollmentMarketingForms = getPreEnrollmentMarketingForms();
        
        if (preenrollmentMarketingForms.size() > 0) {
            PreEnrollmentMarketingForm = preenrollmentMarketingForms[0];
        }
        
        PreenrollmentMarketingFormSubmitted = PreEnrollmentMarketingForm != null && PreEnrollmentMarketingForm.Status__c != 'In Progress';
    }

    private List<Pre_Enrollment_Marketing_Form__c> getPreEnrollmentMarketingForms() {
        return [SELECT Id,
                       Name,
                       Status__c
                  FROM Pre_Enrollment_Marketing_Form__c
                 WHERE Enrollment_Form__c = :EF.Id];
    }
}