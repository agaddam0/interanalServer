@isTest
public with sharing class PlatformSetupFormCTRLTest {
    private static Opportunity DefaultOpportunity { get; set; }
    private static Platform_Setup__c DefaultPlatformSetup { get; set; }
    private static PlatformSetupFormCTRL Controller { get; set; }
    
    @testSetup
    private static void setup() {
        Opportunity opp = OpportunityTestData.Instance.insertAFESOpportunity();
    }
    
    private static void loadDefaults() {
        Test.setCurrentPage(Page.PlatformSetupForm2);
        
        DefaultPlatformSetup = getDefaultPlatformSetup();
        
        system.assert(DefaultPlatformSetup != null, 'The default platform setup is null.');
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(DefaultPlatformSetup);
        Controller = new PlatformSetupFormCTRL(stdController); 
    }
    
    private static Platform_Setup__c getDefaultPlatformSetup() {
        return [SELECT Id,
                       Enrollment_Form__c,
                       Tx_Life_Agent_Data_Prim_Acct_Mngr_ASAP__c,
                       Tx_Life_Prim_Acct_Mngr_ASAP__c,
                       Tx_Life_Visions_SSR_Enroll_Team_Name__c,
                       Tx_Life_Will_Tx_Life_be_set_up__c,
                       Request_Edit__c,
                       Status__c,
                       DVR_Info_WillThereBeDependent_Verif__c,
                       DVR_Info_Audit_of__c,
                       DVR_Info_Drop_Effective_Date__c,
                       DVR_Info_Include__c,
                       S125OtherSvcHaveAFASection125__c,
                       S125OtherSvcPlanYearDesc__c,
                       S125OtherSvcPlanStartDate__c,
                       S125OtherSvcPlanEndDate__c,
                       S125OtherSvcIsThereFSA__c,
                       S125OtherSvcHealthFSAMin__c,
                       S125OtherSvcHealthFSAMax__c,
                       S125OtherSvcAdminFee__c,
                       S125OtherSvcDebitCard__c,
                       S125OtherSvcFlexEffDate__c,
                       S125OtherSvcHaveSection125WithAnotherCo__c,
                       What_Core_Benefits_will_show_in_the_case__c,
                       List_Generic_Folder_Names__c,
                       S125OtherSvcAmount__c,
                       Tx_Life_Bill_Type__c,
                       Enroll_Info_First_Payroll_Deduction_Date__c,
                       TXLifeFirstDedDate__c
                  FROM Platform_Setup__c];
    }
    
    private static Account getDefaultAccount() {
        return
        [SELECT Id,
                Name,
                Texas_Life_Billing__c
           FROM Account
          LIMIT 1];
    }
    
    private static void testPlatformSetupCoreDetailFieldRequired(String requiredFieldName) {
        loadDefaults();
        Controller.TestCoreDetailsRequiredFields = new Map<String, Schema.FieldSetMember>();
        Controller.TestCoreDetailsRequiredFields.put(requiredFieldName, null);
        Controller.p.put(requiredFieldName, null);
        
        Controller.coreDetailsRequiredFields(true);
        
        system.assertEquals(false, Controller.coreDetailsTabComplete, 'The core details tab is complete when it should not be.');
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    private static void coreDetailsRequiredFields_WhatCoreBenefitsWillShowRequiredAndNull_expectRequiredFieldMessageTest() {
        testPlatformSetupCoreDetailFieldRequired('What_Core_Benefits_will_show_in_the_case__c');
    }
    
    @isTest
    private static void coreDetailsRequiredFields_WhatCoreBenefitsWillShowIsGenericFoldersAndListGenericFolderNamesNull_expectRequiredFieldMessageTest() {
        DefaultPlatformSetup = getDefaultPlatformSetup();
        DefaultPlatformSetup.What_Core_Benefits_will_show_in_the_case__c = PlatformSetupFormCTRL.CORE_BENEFITS_GENERIC_FOLDERS;
        update DefaultPlatformSetup;

        testPlatformSetupCoreDetailFieldRequired('List_Generic_Folder_Names__c');
    }
    
    @isTest
    private static void s125CheckRequiredFields_EmployerFSAAdminFeeAndFSAAdminFeeAmountNull_expectRequiredFieldMessageTest() {
        DefaultPlatformSetup = getDefaultPlatformSetup();
        DefaultPlatformSetup.S125OtherSvcHaveAFASection125__c = 'Yes';
        DefaultPlatformSetup.S125OtherSvcIsThereFSA__c = 'Yes';
        DefaultPlatformSetup.S125OtherSvcAdminFee__c = 'Employer';
        DefaultPlatformSetup.S125OtherSvcAmount__c = null;
        update DefaultPlatformSetup;
        
        loadDefaults();
        
        Controller.s125CheckRequiredFields(true);
        
        system.assertEquals(false, Controller.s125servicesTabComplete, 'The service info tab is complete when it should not be.');
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }

    @isTest
    private static void s125CheckRequiredFields_EmployeeFSAAdminFeeAndFSAAdminFeeAmountNull_expectRequiredFieldMessageTest() {
        DefaultPlatformSetup = getDefaultPlatformSetup();
        DefaultPlatformSetup.S125OtherSvcHaveAFASection125__c = 'Yes';
        DefaultPlatformSetup.S125OtherSvcIsThereFSA__c = 'Yes';
        DefaultPlatformSetup.S125OtherSvcAdminFee__c = 'Employee';
        DefaultPlatformSetup.S125OtherSvcAmount__c = null;
        update DefaultPlatformSetup;
        
        loadDefaults();
        
        Controller.s125CheckRequiredFields(true);
        
        system.assertEquals(false, Controller.s125servicesTabComplete, 'The service info tab is complete when it should not be.');
        TestUtil.assertPageHasMessage(PreEnrollmentControllerBase.REQUIRED_FIELD_MESSAGE);
    }
    
    @isTest
    private static void setDefaultValues_texasBillTypeBlankAndTexasLifeOnAccountNotBlank_expectBillTypeDefaultedToTexasLifeValueTest() {
        DefaultPlatformSetup = getDefaultPlatformSetup();
        DefaultPlatformSetup.Tx_Life_Bill_Type__c = null;

        update DefaultPlatformSetup;
        
        Account account = getDefaultAccount();
        account.Texas_Life_Billing__c = 'Direct';
        
        update account;
        
        loadDefaults();
        
        system.assertEquals(account.Texas_Life_Billing__c, Controller.p.Tx_Life_Bill_Type__c, 'The Texas Bill Type was not defaulted from the account\'s Texas Life Billing field.');
    }
}