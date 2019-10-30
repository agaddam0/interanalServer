/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Test Class for OpportunityBLogic Class
 *
 * 
 *
 *
 */
@isTest
private class OpportunityBLogicTest {
    private static Opportunity DefaultOpportunity { get; set; }
    private static Enrollment_Form__c DefaultOpportunityEnrollmentForm { get; set; }
    
    @testSetup
    private static void setup() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
    }
    
    private static void loadDefaults() {
        Test.setCurrentPage(Page.GeneralInformation);
        
        DefaultOpportunity = getDefaultOpportunity();
        loadDefaultOpportunityEnrollmentForm();
    }
    
    private static void loadDefaultOpportunityEnrollmentForm() {
        Opportunity defaultOpp = getDefaultOpportunity();
        
        DefaultOpportunityEnrollmentForm =
        [SELECT Id,
                Name
           FROM Enrollment_Form__c
          WHERE Enrollment_Opportunity__c = :defaultOpp.Id];
    }
    
    private static Opportunity getDefaultOpportunity() {
        return
        [SELECT Id,
                Name,
                AccountId,
                Administrative_Contact__c,
                Confirm_New_or_Existing_Group__c,
                Are_you_adding_new_plans_or_services__c,
                Group_Name__c,
                Employee_Eligibility_Waiting_Period__c,
                EE_Eligibility_Waiting_Period__c,
                Tax_ID__c,
                Assigned_Account_Manager__c,
                Residence_State_s__c,
                Estimated_Employees__c,
                Enrollment_Start_Date__c,
                Enrollment_End_Date__c,
                Effective_Date_of_AFA_Products__c,
                Platform__c,
                Employer_Benefits_Site__c,
                Online_Appointment_Scheduler__c,
                Group_Display_Name__c,
                Are_you_making_any_product_changes__c,
                Are_you_making_any_billing_changes__c,
                Physical_Address_Same_As_Billing__c,
                Waiting_Period_Effective__c,
                RecordTypeId,
                Other_Eligibility_Waiting_Period__c,
                RecordType.Name,
                Branch_Office__c
           FROM Opportunity];
    }
    
    private static List<Opportunity> getOpportunitiesByIds(Set<Id> opportunityIds) {
        return
        [SELECT Id,
                Name,
                AccountId,
                Administrative_Contact__c,
                Confirm_New_or_Existing_Group__c,
                Are_you_adding_new_plans_or_services__c,
                Group_Name__c,
                Employee_Eligibility_Waiting_Period__c,
                EE_Eligibility_Waiting_Period__c,
                Tax_ID__c,
                Assigned_Account_Manager__c,
                Residence_State_s__c,
                Estimated_Employees__c,
                Enrollment_Start_Date__c,
                Enrollment_End_Date__c,
                Effective_Date_of_AFA_Products__c,
                Platform__c,
                Employer_Benefits_Site__c,
                Online_Appointment_Scheduler__c,
                Group_Display_Name__c,
                Are_you_making_any_product_changes__c,
                Are_you_making_any_billing_changes__c,
                Physical_Address_Same_As_Billing__c,
                Waiting_Period_Effective__c,
                RecordTypeId,
                Other_Eligibility_Waiting_Period__c,
                RecordType.Name,
                Branch_Office__c,
                Pricebook2Id
           FROM Opportunity
          WHERE Id in :opportunityIds];
    }
    
    static testMethod void positiveEnrollmentAwd()
    {
    	Util u = new Util();
    	Integer howMany = 1;
    	Boolean doInsert = true;
    	Integer numForms = 2;
    	Integer numEnrollmentForms = 5;
    	
    	Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      	User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
      	EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      	LocaleSidKey='en_US', ProfileId = p.Id, 
      	TimeZoneSidKey='America/Los_Angeles', UserName='uname@testorg.com.etherios.test');
      	
      	System.runAs(usr){
      		
      	
	    	OpportunityStage oName= [SELECT IsClosed, IsWon, MasterLabel FROM OpportunityStage WHERE IsClosed =:false AND IsWon =:false LIMIT 1];
	    	
	    	Account a = u.createOneAcc('Test Apex Account', doInsert, Constants.ACCOUNT_CUSTOMER_ACCOUNT);
	    	Contact c = u.createOneCont('Cont', 'Act', a.Id, doInsert);
	    	Opportunity o = u.createOneOpp('Test Apex Opp', oName.MasterLabel, a.Id, !doInsert, Constants.OPPORTUNITY_AWD_ENROLLMENT);
	    	
	    	o.Division__c = 'AWD';
	    	o.Confirm_New_or_Existing_Group__c = 'New';
	    	o.Did_you_sell_a_Private_Exchange__c = 'Yes';
	    	o.StageName = 'Enrollment';
	    	System.debug('***TEST OWNER ID ---> '+ o.OwnerId + ' OWNER NAME --> '+ o.Owner.Name);
	    	insert o;
      	
	    	list<Enrollment_Form__c> eForm = [SELECT Id, RecordType.Name, RecordType.DeveloperName FROM Enrollment_Form__c WHERE Enrollment_Opportunity__c = :o.Id];
	    		    	
	    	System.assertEquals(1, eForm.size(), 'Inconclusive eForms ---> ' + eForm.size() + '\t' + eForm);
      	}
    }
    
    static testmethod void TestAutoAssetCreation()
    {
        Util u = new Util();
        Integer numberOfOppsToCreate = 5;
        
        List<Account> acct = u.createAcc('Test Account', 1, true, Constants.ACCOUNT_CUSTOMER_ACCOUNT);
        List<Opportunity> opps = u.createOpp('Test Opp', 'Prospecting', numberOfOppsToCreate, acct[0].Id, true, Constants.OPPORTUNITY_AFAS);
        
        Set<Id> newOppIds = CollectionUtil.getRecordIds(opps);
        List<Opportunity> queriedOpps = getOpportunitiesByIds(newOppIds);
        
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        Id pbIdToUse = queriedOpps[0].Pricebook2Id != null ? queriedOpps[0].Pricebook2Id : standardPriceBookId;
        
        List<Product2> prod = u.createProd(1, 'Test Product', true);
		PriceBookEntry pbe = u.createPBEntry(false, pbIdToUse, prod[0].Id, 0);
        pbe.UseStandardPrice = false;
        
        if (standardPriceBookId != pbIdToUse) {
            PriceBookEntry standardPriceBookEntry = pbe.clone(false, true);
            standardPriceBookEntry.Pricebook2Id = standardPriceBookId;
            insert standardPriceBookEntry;
        }
        
        insert pbe;
        
        for(Opportunity o : queriedOpps)
        {
            List<OpportunityLineItem> OLI = u.createOLI(1, o.Id, pbe.Id, true);
            o.StageName = 'Closed Won';
        }
        
        update queriedOpps;
        
        List<Asset> assets = [SELECT Id, Name, AccountId FROM Asset WHERE AccountId IN: acct];
        
        system.assertequals(numberOfOppsToCreate, assets.size(), 'The number of new expected assets were not created.');        
    }
    
    static testmethod void deleteRelatedEnrollmentOpportunitesRecordsTest()
    {
        loadDefaults();
        
        DefaultOpportunity.Has_Section_125_setup_form__c = true;
        DefaultOpportunity.Confirm_New_or_Existing_Group__c = 'Existing';
        DefaultOpportunity.Requesting_Open_Enrollment__c = 'Yes';
        
        update DefaultOpportunity;
        
        String EnrollmentFormId = DefaultOpportunityEnrollmentForm.Id;        

		test.startTest();        
        delete DefaultOpportunity;
        test.stopTest();
        
        List<Platform_Setup__c> pforms = [SELECT Id FROM Platform_Setup__c WHERE Enrollment_Form__c =: EnrollmentFormId];
		system.assertEquals(0, pforms.size());
        
        List<Customer_Setup_Form__c> cforms = [SELECT Id FROM Customer_Setup_Form__c WHERE Enrollment_Form__c =: EnrollmentFormId];
        system.assertEquals(0, cforms.size());
        
        List<Section_125_Setup_Form__c> s125forms = [SELECT Id FROM Section_125_Setup_Form__c WHERE Enrollment_Form__c =: EnrollmentFormId];
        system.assertEquals(0, s125forms.size());
        
        List<Enrollment_Form__c> eForms = [SELECT Id FROM Enrollment_Form__c WHERE Id =: EnrollmentFormId];
        system.assertEquals(0, eForms.size());
    }
}