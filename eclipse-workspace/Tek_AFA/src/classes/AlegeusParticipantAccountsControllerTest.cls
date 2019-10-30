@isTest
public with sharing class AlegeusParticipantAccountsControllerTest {
    private static final String DEFAULT_ENDPOINT = 'https://alegeus.example.com';
    private static final String NOT_AUTHORIZED_MSG = 'Not Authorized';
    private static final String PARTICIPANT_DOESNT_EXIST_MSG = 'Participant doesn\'t exist.';
    
    @testsetup
    static void setup() {
        Alegeus_Settings__c settings = new Alegeus_Settings__c();
        settings.API_Base_URL__c = DEFAULT_ENDPOINT;
        settings.TPA_Id__c = 'TPA1234';
        settings.Secret_Key__c = 'YWJjMTIzNA==';
        settings.Audience__c = 'SomeAudience';
        
        insert settings;
    }
    
    @isTest
    static void getEmployerInfo_accountIdSupplied_expectAccountInfoReturnedTest() {
        Account someEmployer = AccountTestData.Instance.insertCustomerAccount();
        
        AlegeusParticipantAccountsController.EmployerInfo empInfo =
            AlegeusParticipantAccountsController.getEmployerInfo(someEmployer.Id);

        system.assert(empInfo != null, 'The employer info is null.');
        system.assert(empInfo.Employer != null, 'The employer is null.');
    }
    
    @isTest
    static void getParticipantAccounts_noAccountIdGiven_expectAccountIdRequiredMessageTest() {
        Id nullAccountId = null;
        String participantId = 'ABC123';
        String planYear = '1';
        
        AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo = 
            getParticipantAccounts(participantId, nullAccountId, planYear);

        system.assert(acctInfo != null, 'The participant accounts info is null.');
        system.assert(acctInfo.Context != null, 'The context is null.');
        system.assertEquals(false, acctInfo.Context.Success, 'The context should not be successful.');
        system.assertEquals(AlegeusService.ACCOUNT_ID_REQUIRED_MSG, acctInfo.Context.Message,
                            'The account id required message was not found.');
    }

    @isTest
    static void getParticipantAccounts_noParticipantIdGiven_expectParticipantIdRequiredMessageTest() {
        Id accountId = AccountTestData.Instance.withEmployerCode('bca313').insertCustomerAccount().Id;
        String emptyParticipantId = '';
        String planYear = '1';
        
        AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo = 
            getParticipantAccounts(emptyParticipantId, accountId, planYear);

        system.assert(acctInfo != null, 'The participant accounts info is null.');
        system.assert(acctInfo.Context != null, 'The context is null.');
        system.assertEquals(false, acctInfo.Context.Success, 'The context should not be successful.');
        system.assertEquals(AlegeusService.PARTICIPANT_ID_REQUIRED_MSG, acctInfo.Context.Message,
                            'The participant id required message was not found.');
    }

    @isTest
    static void getParticipantAccounts_accountWithoutEmployerCodeGiven_expectEmployerCodeRequiredMessageTest() {
        Id accountIdWithoutEmployerCode = AccountTestData.Instance.withEmployerCode(null).insertCustomerAccount().Id;
        String participantId = 'ABC123';
        String planYear = '1';
        
        AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo = 
            getParticipantAccounts(participantId, accountIdWithoutEmployerCode, planYear);

        system.assert(acctInfo != null, 'The participant accounts info is null.');
        system.assert(acctInfo.Context != null, 'The context is null.');
        system.assertEquals(false, acctInfo.Context.Success, 'The context should not be successful.');
        system.assertEquals(AlegeusService.EMPLOYER_CODE_MISSING_MSG, acctInfo.Context.Message,
                            'The employer code required message was not found.');
    }

    @isTest
    static void getParticipantAccounts_necessaryInputSuppliedButNoAccountsFound_expectResponseSuccessfulWithNoAccountsTest() {
        String employerId = 'ABC413';
        String participantId = 'ABC123';
        String planYear = '1';
        String endpoint = AlegeusService.buildGetParticipantAccountsURL(employerId, participantId, planYear);
        
        setParticipantAccountsResponseMock(endpoint, new ParticipantAccountsWithNoAccountsMock());
        
        Id accountId = AccountTestData.Instance.withEmployerCode(employerId).insertCustomerAccount().Id;

        
        AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo =
            getParticipantAccounts(participantId, accountId, planYear);
            
        assertSuccessResponse(acctInfo, 0);
    }

    @isTest
    static void getParticipantAccounts_participantNotFound_expectErrorResponseWithNoAccountsTest() {
        String employerId = 'ABC413';
        String participantId = 'ABC123';
        String planYear = '1';
        String endpoint = AlegeusService.buildGetParticipantAccountsURL(employerId, participantId, planYear);
        
        setParticipantAccountsResponseMock(endpoint, new ParticipantAccountsParticipantNotFoundMock());
        
        Id accountId = AccountTestData.Instance.withEmployerCode(employerId).insertCustomerAccount().Id;

        
        AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo =
            getParticipantAccounts(participantId, accountId, planYear);

        assertErrorResponse(acctInfo, PARTICIPANT_DOESNT_EXIST_MSG);
    }

    @isTest
    static void getParticipantAccounts_notAuthorized_expectErrorResponseWithNoAccountsTest() {
        String employerId = 'ABC413';
        String participantId = 'ABC123';
        String planYear = '1';
        String endpoint = AlegeusService.buildGetParticipantAccountsURL(employerId, participantId, planYear);
        
        setParticipantAccountsResponseMock(endpoint, new ParticipantAccountsNotAuthorizedMock());
        
        Id accountId = AccountTestData.Instance.withEmployerCode(employerId).insertCustomerAccount().Id;

        
        AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo =
            getParticipantAccounts(participantId, accountId, planYear);

        assertErrorResponse(acctInfo, NOT_AUTHORIZED_MSG);
    }
    
    @isTest
    static void getParticipantAccounts_participantFoundWithOneAccount_expectSuccessResponseWithOneAccountTest() {
        String employerId = 'ABC413';
        String participantId = 'ABC123';
        String planYear = '1';
        String endpoint = AlegeusService.buildGetParticipantAccountsURL(employerId, participantId, planYear);
        
        setParticipantAccountsResponseMock(endpoint, new ParticipantAccountsHasOneAccountWithEmployerRolloverMock());
        
        Id accountId = AccountTestData.Instance.withEmployerCode(employerId).insertCustomerAccount().Id;

        
        AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo =
            getParticipantAccounts(participantId, accountId, planYear);

        assertSuccessResponse(acctInfo, 1);
    }

    @isTest
    static void getParticipantAccounts_participantAccountsInfoWithOneHRAAccount_expectHasHRAAccountToBeTrueTest() {
        AlegeusService.ParticipantAccountsResponse acctInfo = new AlegeusService.ParticipantAccountsResponse();
        AlegeusService.ParticipantAccount hraAccount = new AlegeusService.ParticipantAccount();
        hraAccount.AcctTypeClassDescription = 'HRA';
        acctInfo.Accounts.add(hraAccount);
        
        system.assertEquals(true, acctInfo.hasHRAAccount, 'hasHRAAccount should be true');
    }
    
    @isTest
    static void getParticipantAccounts_participantAccountsInfoWithoutHRAAccount_expectHasHRAAccountToBeFalseTest() {
        AlegeusService.ParticipantAccountsResponse acctInfo = new AlegeusService.ParticipantAccountsResponse();
        AlegeusService.ParticipantAccount hraAccount = new AlegeusService.ParticipantAccount();
        hraAccount.AcctTypeClassDescription = 'FSA';
        acctInfo.Accounts.add(hraAccount);
        
        system.assertEquals(false, acctInfo.hasHRAAccount, 'hasHRAAccount should be false');
    }

    @isTest
    static void getPlanYear_blankPlanYearCode_expectBlankPlanYearStringTest() {
        AlegeusService service = new AlegeusService();
        
        Integer blankPlanYearCode = null;
        String planYear = service.getPlanYearString(blankPlanYearCode);
        
        system.assertEquals('', planYear, 'The plan year should be blank.');
    }
    
    @isTest
    static void getPlanYear_planYearCodeIsNegativeOne_expectPlanYearToBeNoneTest() {
        assertExpectedPlanYearFromPlanYearCode(-1, 'None');
    }
    
    @isTest
    static void getPlanYear_planYearCodeIsZero_expectPlanYearToBeAllTest() {
        assertExpectedPlanYearFromPlanYearCode(0, 'All');
    }

    @isTest
    static void getPlanYear_planYearCodeIsOne_expectPlanYearToBeCurrentTest() {
        assertExpectedPlanYearFromPlanYearCode(1, 'Current');
    }

    @isTest
    static void getPlanYear_planYearCodeIsTwo_expectPlanYearToBePreviousTest() {
        assertExpectedPlanYearFromPlanYearCode(2, 'Previous');
    }

    @isTest
    static void getPlanYear_planYearCodeIsThree_expectPlanYearToBeFutureTest() {
        assertExpectedPlanYearFromPlanYearCode(3, 'Future');
    }

    @isTest
    static void getPlanYear_planYearCodeIsFour_expectPlanYearToBeActiveTest() {
        assertExpectedPlanYearFromPlanYearCode(4, 'Active');
    }

    @isTest
    static void buildPlanYearGroups_oneAccountWithCurrentPlanYear_expectOneActivePlanYearGroupTest() {
        AlegeusParticipantAccountsController.ParticipantAccountsInfo info = new AlegeusParticipantAccountsController.ParticipantAccountsInfo();
        AlegeusService.ParticipantAccountsResponse context = new AlegeusService.ParticipantAccountsResponse();
        info.Context = context;
        
        AlegeusService.ParticipantAccount currentAccount = new AlegeusService.ParticipantAccount();
        currentAccount.PlanYear = 'Current';
        context.Accounts.add(currentAccount);

        info.buildPlanYearGroups();

        system.assertEquals(1, info.PlanYearGroups.size(), 'There should be one plan year group.');
        system.assertEquals(currentAccount.PlanYear, info.PlanYearGroups[0].PlanYear, 'The group\'s plan year should be current.');
    }

    @isTest
    static void buildPlanYearGroups_twoAccountsWithCurrentPlanYear_expectOneActivePlanYearGroupTest() {
        AlegeusParticipantAccountsController.ParticipantAccountsInfo info = new AlegeusParticipantAccountsController.ParticipantAccountsInfo();
        AlegeusService.ParticipantAccountsResponse context = new AlegeusService.ParticipantAccountsResponse();
        info.Context = context;
        
        AlegeusService.ParticipantAccount currentAccount1 = new AlegeusService.ParticipantAccount();
        currentAccount1.PlanYear = 'Current';
        context.Accounts.add(currentAccount1);

        AlegeusService.ParticipantAccount currentAccount2 = new AlegeusService.ParticipantAccount();
        currentAccount2.PlanYear = 'Current';
        context.Accounts.add(currentAccount2);

        info.buildPlanYearGroups();

        system.assertEquals(1, info.PlanYearGroups.size(), 'There should be one plan year group.');
        system.assertEquals(currentAccount1.PlanYear, info.PlanYearGroups[0].PlanYear, 'The group\'s plan year should be current.');
        system.assertEquals(2, info.PlanYearGroups[0].Accounts.size(), 'The current plan year group should have 2 accounts.');
    }

    @isTest
    static void buildPlanYearGroups_oneCurrentPlanYearAccountAndOneFuturePlanYearAccount_expectTwoPlanYearGroupsTest() {
        AlegeusParticipantAccountsController.ParticipantAccountsInfo info = new AlegeusParticipantAccountsController.ParticipantAccountsInfo();
        AlegeusService.ParticipantAccountsResponse context = new AlegeusService.ParticipantAccountsResponse();
        info.Context = context;
        
        AlegeusService.ParticipantAccount currentAccount1 = new AlegeusService.ParticipantAccount();
        currentAccount1.PlanYear = 'Current';
        context.Accounts.add(currentAccount1);

        AlegeusService.ParticipantAccount futureAccount1 = new AlegeusService.ParticipantAccount();
        futureAccount1.PlanYear = 'Future';
        context.Accounts.add(futureAccount1);

        info.buildPlanYearGroups();

        system.assertEquals(2, info.PlanYearGroups.size(), 'There should be 2 plan year groups.');
    }

    @isTest
    static void buildPlanYearGroups_OneAllPlanYearAccountAndThenOneCurrentPlanYearAccount_expectCurrentPlanYearGroupFirstTest() {
        AlegeusParticipantAccountsController.ParticipantAccountsInfo info = new AlegeusParticipantAccountsController.ParticipantAccountsInfo();
        AlegeusService.ParticipantAccountsResponse context = new AlegeusService.ParticipantAccountsResponse();
        info.Context = context;
        

        AlegeusService.ParticipantAccount allAccount1 = new AlegeusService.ParticipantAccount();
        allAccount1.PlanYear = 'All';
        context.Accounts.add(allAccount1);

        AlegeusService.ParticipantAccount currentAccount1 = new AlegeusService.ParticipantAccount();
        currentAccount1.PlanYear = 'Current';
        context.Accounts.add(currentAccount1);

        info.buildPlanYearGroups();

        system.assertEquals(2, info.PlanYearGroups.size(), 'There should be 2 plan year groups.');
        system.assertEquals(currentAccount1.PlanYear, info.PlanYearGroups[0].PlanYear, 'The current plan year should be first.');
    }

    @isTest
    static void buildPlanYearGroups_OneCurrentPlanYearAccountAndThenOneAllPlanYearAccount_expectCurrentPlanYearGroupFirstTest() {
        AlegeusParticipantAccountsController.ParticipantAccountsInfo info = new AlegeusParticipantAccountsController.ParticipantAccountsInfo();
        AlegeusService.ParticipantAccountsResponse context = new AlegeusService.ParticipantAccountsResponse();
        info.Context = context;

        AlegeusService.ParticipantAccount currentAccount1 = new AlegeusService.ParticipantAccount();
        currentAccount1.PlanYear = 'Current';
        context.Accounts.add(currentAccount1);

        AlegeusService.ParticipantAccount allAccount1 = new AlegeusService.ParticipantAccount();
        allAccount1.PlanYear = 'All';
        context.Accounts.add(allAccount1);

        info.buildPlanYearGroups();

        system.assertEquals(2, info.PlanYearGroups.size(), 'There should be 2 plan year groups.');
        system.assertEquals(currentAccount1.PlanYear, info.PlanYearGroups[0].PlanYear, 'The current plan year should be first.');
    }

    @isTest
    static void buildPlanYearGroups_OneFuturePlanYearAccountAndThenOneAllPlanYearAccount_expectAllPlanYearGroupFirstTest() {
        AlegeusParticipantAccountsController.ParticipantAccountsInfo info = new AlegeusParticipantAccountsController.ParticipantAccountsInfo();
        AlegeusService.ParticipantAccountsResponse context = new AlegeusService.ParticipantAccountsResponse();
        info.Context = context;

        AlegeusService.ParticipantAccount futureAccount1 = new AlegeusService.ParticipantAccount();
        futureAccount1.PlanYear = 'future';
        context.Accounts.add(futureAccount1);

        AlegeusService.ParticipantAccount allAccount1 = new AlegeusService.ParticipantAccount();
        allAccount1.PlanYear = 'All';
        context.Accounts.add(allAccount1);

        info.buildPlanYearGroups();

        system.assertEquals(2, info.PlanYearGroups.size(), 'There should be 2 plan year groups.');
        system.assertEquals(allAccount1.PlanYear, info.PlanYearGroups[0].PlanYear, 'The all plan year should be first.');
    }

    static AlegeusParticipantAccountsController.ParticipantAccountsInfo getParticipantAccounts(
        String participantId,
        Id accountId,
        String planYear) {
        
        Test.startTest();
        
        AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo = 
            AlegeusParticipantAccountsController.getParticipantAccountsInfo(participantId, accountId, planYear);
        
        Test.stopTest();
        
        return acctInfo;
    }

    static void setParticipantAccountsResponseMock(String endpoint, HttpCalloutMock responseMock) {
        Map<String, HttpCalloutMock> requests = new Map<String, HttpCalloutMock>();
        requests.put(endpoint, responseMock);

        MultipleHttpRequestsMock mocker = new MultipleHttpRequestsMock(requests);
        Test.setMock(HttpCalloutMock.class, mocker);
    }
    
    static void assertErrorResponse(AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo, String expectedError) {
        system.assert(acctInfo != null, 'The participant accounts info is null.');
        system.assert(acctInfo.Context != null, 'The context is null.');
        system.assertEquals(false, acctInfo.Context.Success, 'The context should not be successful. Message: ' + acctInfo.Context.Message);
        system.assertNotEquals('', acctInfo.Context.Message,
                            'There should be an error message.');
        system.assert(acctInfo.Context.Message.containsIgnoreCase(expectedError), 'The expected error message was not found. Found: ' + acctInfo.Context.Message + ' instead of ' + expectedError);
        system.assert(acctInfo.Context.Accounts != null, 'The accounts list should not be null.');
        system.assertEquals(0, acctInfo.Context.Accounts.size(), 'The accounts list should be empty.');
    }
    
    static void assertSuccessResponse(AlegeusParticipantAccountsController.ParticipantAccountsInfo acctInfo, Integer numberExpectedAccounts) {
        system.assert(acctInfo != null, 'The participant accounts info is null.');
        system.assert(acctInfo.Context != null, 'The context is null.');
        system.assertEquals(true, acctInfo.Context.Success, 'The context should be successful. Error: ' + acctInfo.Context.Message);
        system.assertEquals('', acctInfo.Context.Message,
                            'The message should be blank.');
        system.assert(acctInfo.Context.Accounts != null, 'The accounts list should not be null.');
        system.assertEquals(numberExpectedAccounts, acctInfo.Context.Accounts.size(), 'The expected number of accounts was not found.');
    }
    
    static void assertExpectedPlanYearFromPlanYearCode(Integer planYearCode, String expectedPlanYear) {
        system.assert(planYearCode != null, 'The plan year code is null.');
        system.assert(String.isNotBlank(expectedPlanYear), 'The expected plan year code is blank.');

        AlegeusService service = new AlegeusService();
        String planYear = service.getPlanYearString(planYearCode);
        
        system.assertEquals(expectedPlanYear, planYear, 'The plan year is not the expected one for the plan year code: ' + planYearCode);
    }
    
    public with sharing class ParticipantAccountsWithNoAccountsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[]');
            res.setStatusCode(200);
            return res;
        }
    }

    public with sharing class ParticipantAccountsParticipantNotFoundMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Code": 400, "Description": "' + PARTICIPANT_DOESNT_EXIST_MSG + '", "Id": -1, "Module": "services/participant/accounts"}');
            res.setStatusCode(400);
            return res;
        }
    }

    public with sharing class ParticipantAccountsNotAuthorizedMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(NOT_AUTHORIZED_MSG);
            res.setStatusCode(401);
            return res;
        }
    }
    
    public with sharing class ParticipantAccountsHasOneAccountWithEmployerRolloverMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String accountJSON =
            '[' +  
                 '{' +
                      '"AccountDetailInfo":{' +  
	                      '"AccountDisplayOptions":142606335,' +
	                      '"AccountEndDate":"/Date(1483164000000-0600)/",' +
	                      '"AccountInfo":[' +  
	                          '{' +  
	                               '"AdditionalDeposits":901,' +
	                               '"Balance":1469,' +
	                               '"DepFlexAcctStatus":0,' +
	                               '"DepStatus":0,' +
	                               '"EmpeFlexAcctStatus":1,' +
	                               '"EmpeRelation":0,' +
						           '"FirstName":"John",' +
						           '"FlexAcctKey":637,' +
						           '"IndividualAmount":0,' +
						           '"Initial":"",' +
						           '"IsDep":false,' +
						           '"LastName":"Tester",' +
						           '"Payments":55,' +
						           '"Status":2' +
	                          '}' +
	                       '],' +
				          '"AccountPayRollInfo":{' +  
				              '"AutoDepositCalendarKey":0,' +
				              '"ContributionsYTD":31.25,' +
				              '"EmployeePPPContribution":0,' +
				              '"EmployerPPPContributionsAmount":0,' +
				              '"PayrollCycle":1,' +
				              '"PlanEndDate":"/Date(1483164000000-0600)/",' +
				              '"PlanStartDate":"/Date(1451628000000-0600)/",' +
				              '"RemainingContributions":591.75' +
				           '},' +
				           '"AccountStartDate":"/Date(1451628000000-0600)/",' +
				           '"AccountType":"HRA",' +
				           '"AccountTypeOptions":196608,' +
				           '"BalanceDue":0,' +
				           '"CurrentDate":"/Date(-62135575200000-0600)/",' +
				           '"DPAccAllowManualClaims":null,' +
  				           '"Deductible":0,' +
	    			       '"DeductibleApplied":0,' +
				           '"DeductibleRemaining":0,' +
				           '"EligDte":"/Date(1459486800000-0500)/",' +
				           '"EmprPlanAllowFundRollover":true,' +
				           '"EmprPlanDeductmanagerEnabled":false,' +
				           '"FundRolloverInfo":[' +  
				              '{' +  
				                 '"CoverageTierID":"Husband and Wife",' +
				                 '"CoverageTierKey":5,' +
				                 '"FundRolloverRule":8,' +
				                 '"PrimaryFundRolloverAmount":1000,' +
				                 '"PrimaryFundRolloverRate":50,' +
				                 '"SecondaryFundRolloverAmount":0,' +
				                 '"SecondaryFundRolloverRate":0' +
				              '}' +
				           '],' +
				           '"InternalFlexAcctOptions":9,' +
				           '"IsEmprPlanMonthlyLimit":false,' +
				           '"IsHRA":false,' +
				           '"IsPrimaryRollover":true,' +
				           '"IsSecondaryRollover":false,' +
				           '"MccFlags":0,' +
				           '"MonthlyDepositLimit":-1,' +
				           '"MonthlySpendingLimit":-1,' +
				           '"OnHoldAmount":0,' +
				           '"PlanDefaultAcctCrossover":false,' +
				           '"PlanExtOptions":24576,' +
				           '"PlanMccFlags":2,' +
				           '"PrimaryFundRolloverAmount":0,' +
				           '"PrimaryFundRolloverDate":"/Date(1483164000000-0600)/",' +
				           '"PrimaryFundRolloverRate":0,' +
				           '"PrimaryFundRolloverRule":8,' +
				           '"PrimaryFundsRolloverAccount":"HRA",' +
				           '"PrimaryFundsRolloverAccountPlanEndDate":"/Date(-62135575200000-0600)/",' +
				           '"PrimaryFundsRolloverAccountPlanStartDate":"/Date(-62135575200000-0600)/",' +
				           '"PyFundsRolloverAccountPlanEndDate":"/Date(1483164000000-0600)/",' +
				           '"PyFundsRolloverAccountPlanStartDate":"/Date(1451628000000-0600)/",' +
				           '"PyIndividualRolloverAmount":0,' +
				           '"PyIndividualRolloverRate":0,' +
				           '"RemainingBalance":1469,' +
				           '"SdFundsRolloverAccountPlanEndDate":"/Date(-62135575200000-0600)/",' +
				           '"SdFundsRolloverAccountPlanStartDate":"/Date(-62135575200000-0600)/",' +
				           '"SdIndividualRolloverAmount":0,' +
				           '"SdIndividualRolloverRate":0,' +
				           '"SecondaryFundRolloverAmount":0,' +
				           '"SecondaryFundRolloverDate":"/Date(-62135575200000-0600)/",' +
				           '"SecondaryFundRolloverRate":0,' +
				           '"SecondaryFundRolloverRule":0,' +
				           '"SecondaryFundsRolloverAccount":null,' +
				           '"SecondaryIndividualRolloverAmount":0,' +
				           '"SecondaryIndividualRolloverRate":0,' +
				           '"SpendingLastDate":"/Date(1483164000000-0600)/",' +
				           '"Spent":55,' +
				           '"SubmitClaimsLastDate":"/Date(1483164000000-0600)/",' +
				           '"AcctTypeClassCde":2,' +
				           '"AcctTypeClassDescription":"HRA",' +
				           '"AvailBalance":1469,' +
				           '"PreauthBalance":0' +
                      '},' +
				      '"AccountDisplayHeader":"Health Reimbursement - HRA",' +
				      '"AccountDisplayOptions":142606335,' +
				      '"AccountType":"HRA",' +
				      '"AccountTypeOptions":196608,' +
				      '"AcctStatusCde":1,' +
				      '"AcctTypeClassCde":2,' +
				      '"AcctTypeClassDescription":"HRA",' +
				      '"AdditionalDeposits":901,' +
				      '"AnnualElection":623,' +
				      '"AvailBalance":1469,' +
				      '"Balance":1469,' +
				      '"BalanceDue":0,' +
				      '"DataPartnerOptions":0,' +
				      '"DisplayableFields":[' +  
				         '{' +
				            '"AlternativeFieldName":"Account Description",' +
				            '"DisplayOptions":2,' +
				            '"DisplaySpecifications":0,' +
				            '"OriginalFieldName":"AccountDisplayHeader"' +
				         '},' +
				         '{' +
				            '"AlternativeFieldName":"Annual Election",' +
				            '"DisplayOptions":2,' +
				            '"DisplaySpecifications":0,' +
				            '"OriginalFieldName":"AnnualElection"' +
				         '},' +
				         '{' +  
				            '"AlternativeFieldName":"Contributions YTD",' +
				            '"DisplayOptions":2,' +
				            '"DisplaySpecifications":0,' +
				            '"OriginalFieldName":"TotalContributions"' +
				         '},' +
				         '{' +
				            '"AlternativeFieldName":"Paid YTD",' +
				            '"DisplayOptions":2,' +
				            '"DisplaySpecifications":0,' +
				            '"OriginalFieldName":"Payments"' +
				         '},' +
				         '{' +  
				            '"AlternativeFieldName":"Additional Deposits",' +
				            '"DisplayOptions":2,' +
				            '"DisplaySpecifications":0,' +
				            '"OriginalFieldName":"AdditionalDeposits"' +
				         '},' +
				         '{' +  
				            '"AlternativeFieldName":"Plan Start",' +
				            '"DisplayOptions":2,' +
				            '"DisplaySpecifications":0,' +
				            '"OriginalFieldName":"PlanStartDate"' +
				         '},' +
				         '{' +  
				            '"AlternativeFieldName":"Plan End",' +
				            '"DisplayOptions":2,' +
				            '"DisplaySpecifications":0,' +
				            '"OriginalFieldName":"PlanEndDate"' +
				         '},' +
				         '{' +  
				            '"AlternativeFieldName":"Last Day to Submit Claims",' +
				            '"DisplayOptions":2,' +
				            '"DisplaySpecifications":0,' +
				            '"OriginalFieldName":"SubmitClaimsLastDate"' +
				         '},' +
				         '{' +  
				            '"AlternativeFieldName":"Balance",' +
				            '"DisplayOptions":2,' +
				            '"DisplaySpecifications":0,' +
				            '"OriginalFieldName":"Balance"' +
				         '}' + '],' +
				      '"ExternalBankAccounts":null,' +
				      '"ExternalFunded":null,' +
				      '"FlexAccountKey":637,' +
				      '"FlexAcctId":"0000000637",' +
				      '"GracePeriodEndDte":"20161231",' +
				      '"HSABalance":1469,' +
				      '"HraAcct":false,' +
				      '"IsWCABank":null,' +
				      '"OptInStatus":null,' +
				      '"OtherDeposits":0,' +
				      '"Payments":55,' +
				      '"PlanEndDate":"20161231",' +
				      '"PlanId":"HRA",' +
				      '"PlanOptions2":0,' +
				      '"PlanStartDate":"20160101",' +
				      '"PlanYear":1,' +
				      '"PortfolioBalance":0,' +
				      '"PreauthBalance":0,' +
				      '"Priority":4,' +
				      '"ProductPartnerId":"",' +
				      '"RolloverDeposits":901,' +
				      '"SubmitClaimsLastDate":"/Date(1483164000000-0600)/",' +
				      '"TotalContributions":31.25,' +
				      '"TotalHSABalance":1469' +
                 '}' +
              ']';
            res.setBody(accountJSON);
            res.setStatusCode(200);
            return res;
        }
    }
}