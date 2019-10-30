@isTest
private class AccountDashboardControllerTest {
	private static Account createAccount () {
		return new Account(Status__c = 'A');
	}
	static testMethod void products_should_call_service()
	{
		integer x;
		AccountAssessmentService.ConditionDisplay controller;
		AccountAssessmentService.ConditionDisplay service;

		List<Asset> assets = new List<Asset>();
		Asset asset = new Asset(
			RecordType = new RecordType( Name = 'Benefits' ),
			Status = 'Active',
			Name = 'Test'
		);
		assets.add(asset);

		controller = AccountDashboardController.StarRatingAccountProducts(createAccount(), assets);
		service = AccountAssessmentService.StarRatingAccountProducts(createAccount(), assets);

		System.assertEquals(controller.starRating, service.starRating);
		System.assertEquals(controller.displayInfo.size(), service.displayInfo.size());

		x = controller.displayInfo.size();
		while(x-- > 0)
		{
			System.assertEquals(
				controller.displayInfo.get(x),
				service.displayInfo.get(x));
		}

	}

	static testMethod void services_should_call_service()
	{
		integer x;
		AccountAssessmentService.ConditionDisplay controller;
		AccountAssessmentService.ConditionDisplay service;

		List<Asset> assets = new List<Asset>();
		Asset asset = new Asset(
			RecordType = new RecordType( Name = 'Benefits' ),
			Status = 'Active',
			Carrier__c = 'AFA',
			Name = 'Test'
		);
		assets.add(asset);

		controller = AccountDashboardController.StarRatingAccountServices(createAccount(), assets);
		service = AccountAssessmentService.StarRatingAccountServices(createAccount(), assets);

		System.assertEquals(controller.starRating, service.starRating);
		System.assertEquals(controller.displayInfo.size(), service.displayInfo.size());

		x = controller.displayInfo.size();
		while(x-- > 0)
		{
			System.assertEquals(
				controller.displayInfo.get(x),
				service.displayInfo.get(x));
		}
	}

	static testMethod void premium_should_call_service()
	{
		integer x;
		AccountAssessmentService.ConditionDisplay controller;
		AccountAssessmentService.ConditionDisplay service;

		Account account = new Account(
			Annualized_Premium__c = 50000,
			AP_Percent_of_Change__c = 5,
			Status__c = 'A'
		);

		controller = AccountDashboardController.StarRatingAccountPremium(account);
		service = AccountAssessmentService.StarRatingAccountPremium(account);

		System.assertEquals(controller.starRating, service.starRating);
		System.assertEquals(controller.displayInfo.size(), service.displayInfo.size());

		x = controller.displayInfo.size();
		while(x-- > 0)
		{
			System.assertEquals(
				controller.displayInfo.get(x),
				service.displayInfo.get(x));
		}
	}


	static testMethod void policies_should_call_service()
	{
		integer x;
		AccountAssessmentService.ConditionDisplay controller;
		AccountAssessmentService.ConditionDisplay service;

		Account account = createAccount();

		controller = AccountDashboardController.StarRatingAccountPolicies(account);
		service = AccountAssessmentService.StarRatingAccountPolicies(account);

		System.assertEquals(controller.starRating, service.starRating);
		System.assertEquals(controller.displayInfo.size(), service.displayInfo.size());

		x = controller.displayInfo.size();
		while(x-- > 0)
		{
			System.assertEquals(
				controller.displayInfo.get(x),
				service.displayInfo.get(x));
		}
	}

	static testMethod void activities_should_call_service()
	{
		integer x;
		AccountAssessmentService.ConditionDisplay controller;
		AccountAssessmentService.ConditionDisplay service;

		List<Event> events = new List<Event>();

		controller = AccountDashboardController.StarRatingAccountActivity(createAccount(), events);
		service = AccountAssessmentService.StarRatingAccountActivity(createAccount(), events);

		System.assertEquals(controller.starRating, service.starRating);
		System.assertEquals(controller.displayInfo.size(), service.displayInfo.size());

		x = controller.displayInfo.size();
		while(x-- > 0)
		{
			System.assertEquals(
				controller.displayInfo.get(x),
				service.displayInfo.get(x));
		}
	}

	static testMethod void contacts_should_call_service()
	{
		integer x;
		AccountAssessmentService.ConditionDisplay controller;
		AccountAssessmentService.ConditionDisplay service;

		Contact contact = new Contact();
		List<Contact> contacts = new List<Contact>();

		contact.Inactive__c = false;
		contact.Type__c = 'Decision Maker';
		contacts.add(contact.clone());

		controller = AccountDashboardController.StarRatingAccountContacts(createAccount(), contacts);
		service = AccountAssessmentService.StarRatingAccountContacts(createAccount(), contacts);

		System.assertEquals(controller.starRating, service.starRating);
		System.assertEquals(controller.displayInfo.size(), service.displayInfo.size());

		x = controller.displayInfo.size();
		while(x-- > 0)
		{
			System.assertEquals(
				controller.displayInfo.get(x),
				service.displayInfo.get(x));
		}
	}

	static testMethod void risk_should_call_service()
	{
		integer x;
		AccountAssessmentService.ConditionDisplay controller;
		AccountAssessmentService.ConditionDisplay service;

		List<Case> cases = new List<Case>();
		List<Opportunity> saves = new List<Opportunity>();

		controller = AccountDashboardController.StarRatingAccountRiskPotential(createAccount(), cases, saves);
		service = AccountAssessmentService.StarRatingAccountRiskPotential(createAccount(), cases, saves);

		System.assertEquals(controller.starRating, service.starRating);
		System.assertEquals(controller.displayInfo.size(), service.displayInfo.size());

		x = controller.displayInfo.size();
		while(x-- > 0)
		{
			System.assertEquals(
				controller.displayInfo.get(x),
				service.displayInfo.get(x));
		}
	}

	static testMethod void conditions_should_call_service()
	{
		integer x;
		AccountAssessmentService.ConditionDisplay controller;
		AccountAssessmentService.ConditionDisplay service;

		List<Event> events = new List<Event>();

		controller = AccountDashboardController.StarRatingAccountWorkingConditions(createAccount(), events);
		service = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(), events);

		System.assertEquals(controller.starRating, service.starRating);
		System.assertEquals(controller.displayInfo.size(), service.displayInfo.size());

		x = controller.displayInfo.size();
		while(x-- > 0)
		{
			System.assertEquals(
				controller.displayInfo.get(x),
				service.displayInfo.get(x));
		}
	}
}