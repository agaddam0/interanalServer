@isTest
public with sharing class AFEnrollBatchCaseCreatorTest {
    private static final String DEFAULT_ENDPOINT = 'https://api-qa.americanfidelity.com:443';
    private static final Integer DEFAULT_AFENROLL_CASE_LEAD_TIME = 21;
    private static final Date DEFAULT_AFENROLL_CASE_START_DATE = Date.Today();
    private static Integer platformSetupCounter = 1;

    @testSetup
    static void setup() {
        API_Manager__c sandboxAPI = new API_Manager__c();
        sandboxAPI.Name = AFEnrollService.SANDBOX_AFENROLL_API_MANAGER_NAME;
        sandboxAPI.Consumer_Key__c = 'I_WtMI5Y7ojHAzWZDo7IOsEYd8Ya';
        sandboxAPI.Consumer_Secret__c = 'xtikskRSebPOtyvNmiuHnwiE6Xka';
        sandboxAPI.Endpoint__c = DEFAULT_ENDPOINT;
        sandboxAPI.Host__c = 'api-qa.americanfidelity.com:443';
        sandboxAPI.Username__c = 'Username';
        sandboxAPI.Password__c = 'Password';
        insert sandboxAPI;
        
        API_Manager__c productionAPI = sandboxAPI.clone(false, true);
        productionAPI.Name = AFEnrollService.PRODUCTION_AFENROLL_API_MANAGER_NAME;
        
        insert productionAPI;
        
        AFEnroll_Settings__c afEnrollSettings = new AFEnroll_Settings__c();
        afEnrollSettings.AFEnroll_Case_Start_Date__c = DEFAULT_AFENROLL_CASE_START_DATE;
        afEnrollSettings.Create_Case_Batch_Size__c = 99;
        
        insert afEnrollSettings;
    }
    
    @isTest
    static void schedulableExecute_run_ExpectNoErrorsTest() {
        String errorMessage = '';
        try {
            new AFEnrollBatchCaseCreator().execute(null);
        }
        catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        
        system.assertEquals('', errorMessage, 'There should be no error running the schedulable execute.');
    }

    @isTest
    static void run_noPlatformSetupRecords_expectNoErrorsTest() {
        String errorMessage = '';

        try {
            runAFEnrollBatchCaseCreator();
        }
        catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        
        system.assertEquals('', errorMessage, 'There should be no error.');
    }
    
    @isTest
    static void run_onePlatformSetupReadyForAFEnrollCaseCreation_expectAFEnrollCaseIdRecordedTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();
        system.assertEquals(true, afEnrollCasePlatformSetup.Create_AFEnroll_Case__c, 'The platform setup should be AFEnroll Case Create eligible.');

        loadSaveCaseCalloutsMock(new AFEnrollServiceTest.SaveCaseSuccessfulMock());

        runAFEnrollBatchCaseCreator();

        afEnrollCasePlatformSetup = getPlatformSetupById(afEnrollCasePlatformSetup.Id);
        Opportunity enrollmentOpp = afEnrollCasePlatformSetup.Enrollment_Form__r.Enrollment_Opportunity__r;

        system.assert(String.isNotBlank(enrollmentOpp.AFEnroll_Case_Id__c), 'The AFEnroll Case Id should be populated.');
    }
    
    @isTest
    static void run_onePlatformSetupReadyForAFEnrollCaseCreationButErrorOccurs_expectAFEnrollCaseIdBlankAndErrorRecordedTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();
        system.assertEquals(true, afEnrollCasePlatformSetup.Create_AFEnroll_Case__c, 'The platform setup should be AFEnroll Case Create eligible.');

        String mockErrorMessage = 'Some Error';
        loadSaveCaseCalloutsMock(new AFEnrollServiceTest.SaveCaseErrorMock(mockErrorMessage));

        runAFEnrollBatchCaseCreator();

        afEnrollCasePlatformSetup = getPlatformSetupById(afEnrollCasePlatformSetup.Id);
        Opportunity enrollmentOpp = afEnrollCasePlatformSetup.Enrollment_Form__r.Enrollment_Opportunity__r;

        system.assert(String.isBlank(enrollmentOpp.AFEnroll_Case_Id__c), 'The AFEnroll Case Id should be blank.');
        system.assertEquals(mockErrorMessage, enrollmentOpp.AFEnroll_Case_Error__c, 'The AFEnroll Case Error is not the expected one.');
    }

    @isTest
    static void createAFEnrollCaseFormula_AFEnrollCaseIdPopulated_expectFormulaFalseTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();

        afEnrollCasePlatformSetup.Enrollment_Form__r.Enrollment_Opportunity__r.AFEnroll_Case_Id__c = 'abc123';
        update afEnrollCasePlatformSetup.Enrollment_Form__r.Enrollment_Opportunity__r;
        
        assertCreateAFEnrollCaseFormulaFalse(afEnrollCasePlatformSetup.Id);
    }

    @isTest
    static void createAFEnrollCaseFormula_todayBeforeAFEnrollCaseAllowedDate_expectFormulaFalseTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();
        
        afEnrollCasePlatformSetup.Enrollment_Form__r.Enrollment_Opportunity__r.Enrollment_Start_Date__c = Date.Today().addDays(DEFAULT_AFENROLL_CASE_LEAD_TIME + 1);
        update afEnrollCasePlatformSetup.Enrollment_Form__r.Enrollment_Opportunity__r;
        
        assertCreateAFEnrollCaseFormulaFalse(afEnrollCasePlatformSetup.Id);
    }

    @isTest
    static void createAFEnrollCaseFormula_CustomerSetupStatusIsInProgress_expectFormulaFalseTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();
        
        afEnrollCasePlatformSetup.Customer_Setup_Status__c = 'In Progress';
        update afEnrollCasePlatformSetup;
        
        assertCreateAFEnrollCaseFormulaFalse(afEnrollCasePlatformSetup.Id);
    }

    @isTest
    static void createAFEnrollCaseFormula_CustomerSetupCompleteDateBeforeAFEnrollCaseStartDate_expectFormulaFalseTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();
        
        afEnrollCasePlatformSetup.CustomerSetupCompleteDate__c = DEFAULT_AFENROLL_CASE_START_DATE.addDays(-1);
        update afEnrollCasePlatformSetup;
        
        assertCreateAFEnrollCaseFormulaFalse(afEnrollCasePlatformSetup.Id);
    }

    @isTest
    static void createAFEnrollCaseFormula_PlatformSetupOwnedByQueue_expectFormulaFalseTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();
        
        afEnrollCasePlatformSetup.Status__c = 'Submitted';
        update afEnrollCasePlatformSetup;
        
        assertCreateAFEnrollCaseFormulaFalse(afEnrollCasePlatformSetup.Id);
    }

    @isTest
    static void run_twoPlatformSetupsReadyForAFEnrollCaseCreation_expectAFEnrollCaseIdRecordedOnEachTest() {
        Platform_Setup__c afEnrollCasePlatformSetup1 = insertAFEnrollCaseEligiblePlatformSetup();
        system.assertEquals(true, afEnrollCasePlatformSetup1.Create_AFEnroll_Case__c, 'The platform setup should be AFEnroll Case Create eligible.');

        Platform_Setup__c afEnrollCasePlatformSetup2 = insertAFEnrollCaseEligiblePlatformSetup();
        system.assertEquals(true, afEnrollCasePlatformSetup2.Create_AFEnroll_Case__c, 'The platform setup should be AFEnroll Case Create eligible.');

        loadSaveCaseCalloutsMock(new AFEnrollServiceTest.SaveCaseSuccessfulMock());

        runAFEnrollBatchCaseCreator();
        
        assertPlatformSetupHasCaseId(afEnrollCasePlatformSetup1.Id);
        assertPlatformSetupHasCaseId(afEnrollCasePlatformSetup2.Id);
    }

    @isTest
    static void createAFEnrollCaseFormula_AccountMCPNumberBlank_expectFormulaFalseTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();
        
        Account blankMCPNumberAccount = new Account(Id = afEnrollCasePlatformSetup.Enrollment_Form__r.Enrollment_Opportunity__r.AccountId);
        blankMCPNumberAccount.MCP_Number__c = null;
        
        update blankMCPNumberAccount;
        
        assertCreateAFEnrollCaseFormulaFalse(afEnrollCasePlatformSetup.Id);
    }

    @isTest
    static void createAFEnrollCaseFormula_SkipAFEnrollCaseCreate_expectFormulaFalseTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();
        
        afEnrollCasePlatformSetup.Skip_AFEnroll_Case_Create__c = true;
        update afEnrollCasePlatformSetup;
        
        assertCreateAFEnrollCaseFormulaFalse(afEnrollCasePlatformSetup.Id);
    }

    @isTest
    static void createAFEnrollCaseFormula_CustomerSetupStatusIsCompletedNoWork_expectFormulaTrueTest() {
        Platform_Setup__c afEnrollCasePlatformSetup = insertAFEnrollCaseEligiblePlatformSetup();
        
        afEnrollCasePlatformSetup.Customer_Setup_Status__c = 'Closed - No Work';
        update afEnrollCasePlatformSetup;
        
        assertCreateAFEnrollCaseFormulaTrue(afEnrollCasePlatformSetup.Id);
    }

    static void runAFEnrollBatchCaseCreator() {
        Test.startTest();

        // Luke Freeland: There's some weird Salesforce bug where running the job
        // normally in a test where other DML has taken place causes the 
        // "Uncommitted Work Pending" error despite being within Test.startTest
        // and Test.stopTest. To fix this, the job is run manually.
        AFEnrollBatchCaseCreator caseCreator = new AFEnrollBatchCaseCreator();
        Database.QueryLocator ql = caseCreator.start(null);
        
        String query = ql.getQuery();
        List<Platform_Setup__c> platformSetupRecords = Database.query(query);
        
        caseCreator.execute(null, platformSetupRecords);
        caseCreator.finish(null);
        
        Test.stopTest();
    }
    
    static Platform_Setup__c insertAFEnrollCaseEligiblePlatformSetup() {
        Enrollment_Path__c afesLimitedEnrollmentPath = EnrollmentPathTestData.Instance.withAFEnrollCaseLeadTime(DEFAULT_AFENROLL_CASE_LEAD_TIME)
                                                                                      .insertEnrollmentPath();
        
        Opportunity enrollmentOpp = OpportunityTestData.Instance.withAFEnrollCaseId(null)
                                                                .withEnrollmentPath(afesLimitedEnrollmentPath.Id)
                                                                .withEnrollmentStartDate(Date.Today())
                                                                .insertAFESOpportunity();

        Account enrollmentAccount = [SELECT Id, Name
                                       FROM Account
                                      WHERE Id = :enrollmentOpp.AccountId];

        enrollmentAccount.MCP_Number__c = '19381' + platformSetupCounter;
        update enrollmentAccount;

        // Increment the counter so the MCP Number will remain unique.        
        ++platformSetupCounter;

        // There should only be one and it gets automatically generated by the system
        // on enrollment opportunity insertion.
        Platform_Setup__c ps =
        [SELECT Id,
                Name
           FROM Platform_Setup__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c = :enrollmentOpp.Id];
           

        ps.Customer_Setup_Status__c = 'Completed';
        ps.CustomerSetupCompleteDate__c = Date.Today();
        ps.Status__c = 'H.O. Processing';
        ps.OwnerId = UserInfo.getUserId();
        update ps;

        ps = getPlatformSetupById(ps.Id);

        return ps;
    }
    
    static Platform_Setup__c getPlatformSetupById(Id platformSetupId) {
        return
        [SELECT Id,
                Name,
                Create_AFEnroll_Case__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.Id,
                Enrollment_Form__r.Enrollment_Opportunity__r.AFEnroll_Case_Id__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.AFEnroll_Case_Error__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.AFEnroll_Case_Allowed_Date__c,
                Enrollment_Form__r.Enrollment_Opportunity__r.AccountId,
                OwnerId
           FROM Platform_Setup__c
          WHERE Id = :platformSetupId];
    }

    static void loadSaveCaseCalloutsMock(HttpCalloutMock esbAuthMock, HttpCalloutMock saveCaseMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(DEFAULT_ENDPOINT + ESBAuthenticator.ENDPOINT_PATH, esbAuthMock);
        
        requests.put(DEFAULT_ENDPOINT + AFEnrollService.ENROLLMENT_SAVE_API_PATH, saveCaseMock);
        
        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    static void loadSaveCaseCalloutsMock(HttpCalloutMock saveCaseMock) {
        loadSaveCaseCalloutsMock(new ESBAuthenticatorTest.AuthenticateSuccessfulMock(), saveCaseMock);
    }
    
    static void assertCreateAFEnrollCaseFormulaFalse(Id platformSetupId) {
        Platform_Setup__c ps = getPlatformSetupById(platformSetupId);
        
        system.assertEquals(false, ps.Create_AFEnroll_Case__c, 'The platform setup\'s  "Create AFEnroll Case?" should be false.');
    }

    static void assertCreateAFEnrollCaseFormulaTrue(Id platformSetupId) {
        Platform_Setup__c ps = getPlatformSetupById(platformSetupId);
        
        system.assertEquals(true, ps.Create_AFEnroll_Case__c, 'The platform setup\'s  "Create AFEnroll Case?" should be true.');
    }
    
    static void assertPlatformSetupHasCaseId(Id platformSetupId) {
        Platform_Setup__c afEnrollCasePlatformSetup = getPlatformSetupById(platformSetupId);
        Opportunity enrollmentOpp = afEnrollCasePlatformSetup.Enrollment_Form__r.Enrollment_Opportunity__r;

        system.assert(String.isNotBlank(enrollmentOpp.AFEnroll_Case_Id__c), 'The AFEnroll Case Id should be populated. Error: ' + enrollmentOpp.AFEnroll_Case_Error__c);
    }
}