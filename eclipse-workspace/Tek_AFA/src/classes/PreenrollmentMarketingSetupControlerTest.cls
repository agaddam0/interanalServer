@isTest
private class PreenrollmentMarketingSetupControlerTest {
    private static final String DEFAULT_ENDPOINT = 'https://api-qa.americanfidelity.com:443';
    
    private static Pre_Enrollment_Marketing_Form__c DefaultMarketingForm { get; set; }
    private static PreenrollmentMarketingSetupFormControler Controller { get; set; }
    
    private static void loadDefaultController() {
        loadDefaultController(new Pre_Enrollment_Marketing_Form__c());
    }
    
    private static void loadDefaultController(Pre_Enrollment_Marketing_Form__c defaultMarketingFormToUse) {
        Test.setCurrentPage(Page.PreenrollmentMarketingSetupForm);
        
        DefaultMarketingForm = defaultMarketingFormToUse;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(DefaultMarketingForm);
        Controller = new PreenrollmentMarketingSetupFormControler(standardController);
        Controller.eOppty.Employer_Benefits_Site__c = 'Yes';
    }
    
    private static Pre_Enrollment_Marketing_Form__c getPreenrollmentMarketingFormById(Id marketingFormId) {
        return 
        [SELECT Id,
                Name,
                Status__c,
                License_No__c,
                License_Number_Required__c,
                Enrollment_Form__c,
                Show_HR_Contact__c,
                Show_Broker_Contact__c,
                Combo_Brochure_Quantity__c,
                Time_to_Enroll_Flyer_Quantity__c,
                Time_to_Enroll_Poster_Quantity__c,
                Last_Chance_Flyer_Quantity__c,
                Show_AF_HR_Central_Information__c,
                Show_Kiosk_Information__c,
                Show_One_on_One_Information__c,
                Show_Self_Service_Information__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.Id,
                Enrollment_Form__r.Enrollment_Opportunity__r.AccountId,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.Logo_On_File__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_Start_Date__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_End_Date__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Account.Marketing_Resource_ID__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.RecordType.Name,
                Send_Employer_Upsert_Request__c,
                Time_to_Enroll_Email__c,
                Open_Enrollment_Sart__c,
                Open_Enrollment_End__c
           FROM Pre_Enrollment_Marketing_Form__c
          WHERE Id = :marketingFormId];
    }
    
    private static Opportunity getOpportunityById(Id opportunityId) {
        return
        [SELECT Id,
                Name,
                Employer_Benefits_Site__c,
                RecordType.Name
           FROM Opportunity
          WHERE Id = :opportunityId];
    }
    
    @isTest
    static void eOppty_setAndGet_expectPropertySavesOpportunityTest() {
        loadDefaultController();
        Opportunity someOpportunity = new Opportunity();
        
        Controller.eOppty = someOpportunity;
        
        system.assertEquals(someOpportunity, Controller.eOppty, 'The given opportunity is not used by Controller.eOppty.');
    }
}