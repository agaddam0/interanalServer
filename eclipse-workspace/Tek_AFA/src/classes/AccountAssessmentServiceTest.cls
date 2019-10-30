@isTest
private class AccountAssessmentServiceTest {
	private static Account createAccount (boolean lapsed) {
		return new Account(Status__c = lapsed ? 'L' : 'A');
	}
	// ************************************************************************   Override Rating
	public static testMethod void Should_overide_star_rating_for_lapse_account () {
		AccountAssessmentService.ConditionDisplay display = new AccountAssessmentService.ConditionDisplay();
		display.starRating = 3;

		display = AccountAssessmentService.StarRatingOverride(createAccount(true), display);
		System.assert(display.starRating == 1);
	}

	public static testMethod void Should_not_overide_star_rating_for_lapse_account () {
		AccountAssessmentService.ConditionDisplay display = new AccountAssessmentService.ConditionDisplay();
		display.starRating = 3;

		display = AccountAssessmentService.StarRatingOverride(createAccount(false), display);
		System.assert(display.starRating == 3);
	}
	// ************************************************************************   Products
	public static testMethod void products_should_return_products()
	{
		List<Asset> assets = new List<Asset>();
		AccountAssessmentService.ConditionDisplay display;
		Asset asset;

		asset = new Asset(
			RecordType = new RecordType( Name = 'Benefits' ),
			Status = 'Active'
		);

		asset.Name = 'Some Benefit';
		assets.add(asset.clone(false, false, false, false));

		asset.Name = 'Some Other Benefit';
		assets.add(asset.clone(false, false, false, false));

		display = AccountAssessmentService.StarRatingAccountProducts(createAccount(false), assets);

		System.assert(display.displayInfo.get(0).contains('Some Benefit'));
		System.assert(display.displayInfo.get(1).contains('Some Other Benefit'));

		// formating of ,
		System.assert(display.displayInfo.get(0).startsWith(',') == false);
		System.assert(display.displayInfo.get(1).startsWith(','));

		// star count is correct
		System.assertEquals(2, display.starRating);


		asset.Name = 'Some 1 Benefit';
		assets.add(asset.clone(false, false, false, false));

		asset.Name = 'Some Other 2 Benefit';
		assets.add(asset.clone(false, false, false, false));

		asset.Name = 'Some Other 3 Benefit';
		assets.add(asset.clone(false, false, false, false));

		display = AccountAssessmentService.StarRatingAccountProducts(createAccount(false), assets);

		// star count is correct
		System.assertEquals(5, display.starRating);

		asset.Name = 'Some Other 4 Benefit';
		assets.add(asset.clone(false, false, false, false));

		display = AccountAssessmentService.StarRatingAccountProducts(createAccount(false), assets);

		// star count is correct
		System.assertEquals(5, display.starRating);

	}
	public static testMethod void products_should_return_zero_products()
	{
		List<List<Asset>> assets = new List<List<Asset>>();
		//  *************************  from list of zero products
		assets.add(new List<Asset>());

		//  *************************  from list of wrong record types
		assets.add(new List<Asset>{
			new Asset(
				RecordType = new RecordType( Name = 'Not a needed Record Type' ),
				Status = 'Shouldnt matter',
				Name = 'Doesnt matter'
			)
		});

		//  *************************  from list of inactive

		assets.add(new List<Asset>{
			new Asset(
				RecordType = new RecordType( Name = 'Benefits' ),
				Status = 'InActive',
				Name = 'Doesnt matter'
			)
		});

		//  *************************  from list of aggregated assets
		assets.add(new List<Asset>{
			new Asset(
				RecordType = new RecordType( Name = 'Benefits' ),
				Status = 'Active',
				Name = 'TestTotal'
			)
		});

		for(List<Asset> asset : assets)
		{
			AccountAssessmentService.ConditionDisplay display;
			display = AccountAssessmentService.StarRatingAccountProducts(createAccount(false), asset);
			System.assertEquals('None', display.displayInfo.get(0));
			System.assertEquals(1, 		display.starRating);
		}

	}

	// ************************************************************************   Services
	public static testMethod void services_should_return_zero_services()
	{
		AccountAssessmentService.ConditionDisplay display;
		Asset clone;
		Asset asset = new Asset(
				RecordType = new RecordType( Name = 'Expense Management Services' ),
				Carrier__c = 'AFA',
				Status = 'Active',
				Name = 'Section 125'
		);

		List<Asset> assets = new List<Asset> { asset };

		// asset its a valid asset
		display = AccountAssessmentService.StarRatingAccountServices(createAccount(false), assets);
		System.assertEquals(3, display.starRating);
		System.assertEquals('Section 125', display.displayInfo.get(0));

		// add invalid services
		assets.clear();

		clone = asset.clone(false, true, false, false);
		clone.RecordType.Name = 'Not the right one';
		assets.add(clone);

		clone = asset.clone(false, true, false, false);
		clone.Carrier__c = 'Not the right carrier';
		assets.add(clone);

		clone = asset.clone(false, true, false, false);
		clone.Status = 'Not active';
		assets.add(clone);

		display = AccountAssessmentService.StarRatingAccountServices(createAccount(false), assets);
		System.assertEquals(1, display.starRating);
		System.assertEquals('None', display.displayInfo.get(0));

	}

	public static testMethod void services_should_return_services()
	{
		AccountAssessmentService.ConditionDisplay display;
		List<Asset> assets = new List<Asset>();
		Asset asset = new Asset(
			RecordType = new RecordType( Name = 'Expense Management Services' ),
			Carrier__c = 'AFA',
			Status = 'Active'
		);

		asset.Name = 'other product';
		assets.add(asset.clone(false, true, false, false));

		display = AccountAssessmentService.StarRatingAccountServices(createAccount(false), assets);
		System.assertEquals(1, display.starRating);

		assets.clear();

		asset.Name = 'test section 125';
		assets.add(asset.clone(false, true, false, false));

		display = AccountAssessmentService.StarRatingAccountServices(createAccount(false), assets);
		System.assertEquals(3, display.starRating);

		asset.Name = 'other product';
		assets.add(asset.clone(false, true, false, false));

		display = AccountAssessmentService.StarRatingAccountServices(createAccount(false), assets);
		System.assertEquals(5, display.starRating);
	}

	// ************************************************************************   Premium
	public static testMethod void premium_should_return_changed_premuim()
	{
		AccountAssessmentService.ConditionDisplay display;
		Account account = new Account(
			Status__c = 'A',
			Annualized_Premium__c = 50000,
			AP_Percent_of_Change__c = 5
		);

		display = AccountAssessmentService.StarRatingAccountPremium(account);

		System.assertEquals('$50,000', display.displayInfo.get(0));
		System.assertEquals('5%', display.displayInfo.get(1));
		System.assertEquals(5, display.starRating);

		account.Annualized_Premium__c = 2000;
		account.AP_Percent_of_Change__c = -5;

		display = AccountAssessmentService.StarRatingAccountPremium(account);

		System.assertEquals('$2,000', display.displayInfo.get(0));
		System.assertEquals('-5%', display.displayInfo.get(1));
		System.assertEquals(3, display.starRating);

		account.Annualized_Premium__c = 1000;
		account.AP_Percent_of_Change__c = -35;

		display = AccountAssessmentService.StarRatingAccountPremium(account);

		System.assertEquals('$1,000', display.displayInfo.get(0));
		System.assertEquals('-35%', display.displayInfo.get(1));
		System.assertEquals(1, display.starRating);

	}

	public static testMethod void premium_should_return_na()
	{
		AccountAssessmentService.ConditionDisplay display;
		Account account = new Account(
			Status__c = 'A',
			Annualized_Premium__c 	= null,
			AP_Percent_of_Change__c = null
		);

		display = AccountAssessmentService.StarRatingAccountPremium(account);

		System.assertEquals('N/A', 	display.displayInfo.get(0));
		System.assertEquals('N/A', 	display.displayInfo.get(1));
		System.assertEquals(1, 		display.starRating);
	}

	// ************************************************************************   Policies

	public static testMethod void policies_should_return_na()
	{

		AccountAssessmentService.ConditionDisplay display;
		Account account = new Account(Status__c = 'A');

		display = AccountAssessmentService.StarRatingAccountPolicies(account);

		System.assertEquals(1, 		display.starRating);
		System.assertEquals('N/A', 	display.displayInfo.get(0));
		System.assertEquals('N/A', 	display.displayInfo.get(1));
	}

	// ************************************************************************   Activity

	public static testMethod void acitivities_should_return_activity_count()
	{
		AccountAssessmentService.ConditionDisplay display;
		Event event = new Event();
		Event clone;
		List<Event> events = new List<Event>();

		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('0', display.displayInfo.get(0));

		event.Type__c = 'Call';
		event.ActivityDate = Date.today().addDays(-200);
		events.add(event.clone(false, false, false, false));

		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('1', display.displayInfo.get(0));

		event.Type__c = 'Not a type';
		event.ActivityDate = Date.today().addDays(-20);
		events.add(event.clone(false, false, false, false));

		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('1', display.displayInfo.get(0));

		event.Type__c = 'Meeting';
		event.ActivityDate = Date.today().addDays(-20);
		events.add(event.clone(false, false, false, false));

		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('2', display.displayInfo.get(0));

		event.Type__c = 'Meeting';
		event.ActivityDate = Date.today().addDays(-92);
		events.add(event.clone(false, false, false, false));

		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('3', display.displayInfo.get(0));

		event.Type__c = 'Call';
		event.ActivityDate = Date.today().addDays(-92);
		events.add(event.clone(false, false, false, false));

		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('4', display.displayInfo.get(0));

	}
	public static testMethod void acitivities_should_return_na_last_activity_date()
	{
		AccountAssessmentService.ConditionDisplay display;
		Event event = new Event();
		List<Event> events = new List<Event>();

		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('N/A', display.displayInfo.get(1));

		event.Type__c = 'Call';
		event.ActivityDate = Date.today().addDays(-200);
		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('N/A', display.displayInfo.get(1));

		event.Type__c = 'Meeting';
		event.ActivityDate = Date.today().addDays(-200);
		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('N/A', display.displayInfo.get(1));

		event.Type__c = 'Not the correct type';
		event.ActivityDate = Date.today().addDays(-20);
		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals('N/A', display.displayInfo.get(1));


	}
	public static testMethod void acitivities_should_return_last_activity_date()
	{
		AccountAssessmentService.ConditionDisplay display;
		Event event = new Event();
		List<Event> events = new List<Event>();

		event.Type__c = 'Call';
		event.ActivityDate = Date.today().addDays(-93);
		events.add(event.clone(false, false, false, false));
		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals(Date.today().addDays(-93).format(), display.displayInfo.get(1));

		event.Type__c = 'Call';
		event.ActivityDate = Date.today().addDays(-2);
		events.add(event.clone(false, false, false, false));
		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals(Date.today().addDays(-2).format(), display.displayInfo.get(1));

		events.clear();

		event.Type__c = 'Meeting';
		event.ActivityDate = Date.today().addDays(-93);
		events.add(event.clone(false, false, false, false));
		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals(Date.today().addDays(-93).format(), display.displayInfo.get(1));

		event.Type__c = 'Meeting';
		event.ActivityDate = Date.today().addDays(-2);
		events.add(event.clone(false, false, false, false));
		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals(Date.today().addDays(-2).format(), display.displayInfo.get(1));

	}

	public static testMethod void acitivities_should_return_star_rating()
	{
		AccountAssessmentService.ConditionDisplay display;
		Event event = new Event();
		List<Event> events = new List<Event>();

		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals(1, display.starRating);

		event.Type__c = 'Not the right type';
		event.ActivityDate = Date.today().addDays(-20);
		events.add(event.clone(false, false, false, false));

		event.Type__c = 'Call';
		event.ActivityDate = Date.today().addDays(-200);
		events.add(event.clone(false, false, false, false));

		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals(1, display.starRating);

		event.Type__c = 'Call';
		event.ActivityDate = Date.today().addDays(-95);
		events.add(event.clone(false, false, false, false));
		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals(3, display.starRating);

		event.Type__c = 'Meeting';
		event.ActivityDate = Date.today().addDays(-15);
		events.add(event.clone(false, false, false, false));
		display = AccountAssessmentService.StarRatingAccountActivity(createAccount(false), events);
		System.assertEquals(5, display.starRating);

	}

	// ************************************************************************   Contacts

	// Bug Validation W-001491
	public static testMethod void contacts_should_return_five_star_for_complete_contacts()
	{
		AccountAssessmentService.ConditionDisplay display;
		List<Contact> contacts = new List<Contact>();

		Contact contact = new Contact();

		contact.Inactive__c = false;
		contact.Decision_Maker__c = true;
		contact.Phone = '123456';
		contact.Email = 'email@email.com';

		contacts.add(contact.clone());

		contact.Decision_Maker__c = false;
		contacts.add(contact.clone());
		contacts.add(contact.clone());
		contacts.add(contact.clone());
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals(5, display.starRating);
	}
	public static testMethod void contacts_should_return_decision_maker()
	{
		AccountAssessmentService.ConditionDisplay display;
		Contact contact = new Contact();
		List<Contact> contacts = new List<Contact>();

		contact.Inactive__c = false;
		contact.Type__c = 'Decision Maker';
		contact.Decision_Maker__c = true;
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals('Yes', display.displayInfo.get(2));

		contacts.clear();

		contact.Inactive__c = true;
		contact.Type__c = 'Decision Maker';
		contact.Decision_Maker__c = true;
		contacts.add(contact.clone());

		contact.Inactive__c = false;
		contact.Type__c = 'Not the Decision Maker';
		contact.Decision_Maker__c = false;
		contacts.add(contact.clone());
		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals('No', display.displayInfo.get(2));

	}

	public static testMethod void contacts_should_return_complete_contact_info()
	{
		AccountAssessmentService.ConditionDisplay display;
		Contact contact = new Contact();
		List<Contact> contacts = new List<Contact>();

		contact.Inactive__c = true;
		contact.Email = 'testing';
		contact.Phone = 'testing';
		contact.Type__c = 'Decision Maker';
		contact.Decision_Maker__c = true;
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals('0', display.displayInfo.get(1));

		contact.Inactive__c = false;
		contact.Email = 'testing';
		contact.Phone = 'testing';
		contact.Type__c = 'Decision Maker';
		contact.Decision_Maker__c = true;
		contacts.add(contact.clone());

		contact.Inactive__c = false;
		contact.Email = 'testing';
		contact.Phone = '';
		contact.Type__c = 'Other Type';
		contacts.add(contact.clone());

		contact.Inactive__c = false;
		contact.Email = '';
		contact.Phone = 'testing';
		contact.Type__c = 'Other Type';
		contacts.add(contact.clone());

		contact.Inactive__c = true;
		contact.Email = '';
		contact.Phone = 'testing';
		contact.Type__c = 'Other Type';
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals('1', display.displayInfo.get(1));
	}

	public static testMethod void contact_rule_decision_maker_success()
	{
		AccountAssessmentService.ConditionDisplay display;
		Contact contact = new Contact( Inactive__c = false, Type__c = 'Decision Maker');
		contact.Decision_Maker__c = true;
		List<Contact> contacts = new List<Contact>();

		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals(3, display.starRating);
	}

	public static testMethod void contact_rule_decision_maker_failure()
	{
		AccountAssessmentService.ConditionDisplay display;
		Contact contact = new Contact( Inactive__c = false, Type__c = 'Not Decision Maker' );
		contact.Decision_Maker__c = false;
		List<Contact> contacts = new List<Contact>();

		contact.Email = 'test';
		contact.Phone = 'test';
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals(1, display.starRating);
	}

	public static testMethod void contact_rule_complete_failure()
	{
		AccountAssessmentService.ConditionDisplay display;
		Contact contact = new Contact( Inactive__c = false, Type__c = 'Decision Maker' );
		contact.Decision_Maker__c = true;
		List<Contact> contacts = new List<Contact>();

		contact.Email = 'test';
		contact.Phone = 'test';

		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals(3, display.starRating);
	}

	public static testMethod void contact_rule_complete_success()
	{
		AccountAssessmentService.ConditionDisplay display;
		Contact contact = new Contact( Inactive__c = false, Type__c = 'Decision Maker' );
		contact.Decision_Maker__c = true;
		List<Contact> contacts = new List<Contact>();

		contact.Email = 'test';
		contact.Phone = 'test';
		contacts.add(contact.clone());
		contacts.add(contact.clone());
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals(5, display.starRating);
	}

	public static testMethod void contact_two_decision_makers()
	{
		AccountAssessmentService.ConditionDisplay display;
		Contact contact = new Contact( Inactive__c = false, Type__c = 'Decision Maker' );
		contact.Decision_Maker__c = true;
		List<Contact> contacts = new List<Contact>();

		contact.Email = 'test';
		contact.Phone = 'test';
		contacts.add(contact.clone());
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals(3, display.starRating);
	}
	public static testMethod void contact_rule_incomplete_plus_complete()
	{
		AccountAssessmentService.ConditionDisplay display;
		Contact contact = new Contact( Inactive__c = false, Type__c = 'Decision Maker' );
		contact.Decision_Maker__c = true;
		List<Contact> contacts = new List<Contact>();

		contact.Email = 'test';
		contact.Phone = 'test';
		contacts.add(contact.clone());

		contact.Email = '';
		contact.Phone = 'test';
		contacts.add(contact.clone());

		contact.Email = 'test';
		contact.Phone = '';
		contacts.add(contact.clone());
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals(3, display.starRating);
	}

	public static testMethod void contacts_should_return_type_of_contacts()
	{
		AccountAssessmentService.ConditionDisplay display;
		Contact contact = new Contact();
		List<Contact> contacts = new List<Contact>();

		contact.Inactive__c = true;
		contact.Email = 'testing';
		contact.Phone = 'testing';
		contact.Type__c = 'Decision Maker';
		contact.Decision_Maker__c = true;
		contacts.add(contact.clone());

		contact.Inactive__c = false;
		contact.Email = 'testing';
		contact.Phone = 'testing';
		contact.Type__c = null;
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals('', display.displayInfo.get(0));

		contact.Inactive__c = false;
		contact.Email = 'testing';
		contact.Phone = 'testing';
		contact.Type__c = 'Decision Maker';
		contact.Decision_Maker__c = true;
		contacts.add(contact.clone());

		contact.Inactive__c = false;
		contact.Email = 'testing';
		contact.Phone = 'testing';
		contact.Type__c = 'Another Type of Contact';
		contact.Decision_Maker__c = false;
		contacts.add(contact.clone());

		contact.Inactive__c = false;
		contact.Email = 'testing';
		contact.Phone = 'testing';
		contact.Type__c = 'Other Type';
		contact.Decision_Maker__c = false;
		contacts.add(contact.clone());

		display = AccountAssessmentService.StarRatingAccountContacts(createAccount(false), contacts);
		System.assertEquals('Decision Maker, Another Type of Contact, Other Type', display.displayInfo.get(0));
	}

	// ************************************************************************  Risk Potential

	public static testMethod void risk_should_return_case_numbers() {
		AccountAssessmentService.ConditionDisplay display;
		List<Case> cases = new List<Case>();
		List<Opportunity> opportunites = new List<Opportunity>();
		Case issue = new Case();

		issue.date__c = Date.today().addDays(-60);
		cases.add(issue.clone());

		issue.date__c = Date.today().addDays(-90);
		cases.add(issue.clone());

		issue.date__c = Date.today().addDays(-120);
		cases.add(issue.clone());

		issue.date__c = Date.today().addDays(-160);
		cases.add(issue.clone());

		issue.date__c = Date.today().addDays(-400);
		cases.add(issue.clone());

		display = AccountAssessmentService.StarRatingAccountRiskPotential(createAccount(false), cases, opportunites);
		System.assertEquals('4', display.displayInfo.get(0));
	}

	public static testMethod void risk_should_return_save_numbers() {
		AccountAssessmentService.ConditionDisplay display;
		List<Case> cases = new List<Case>();
		List<Opportunity> opportunites = new List<Opportunity>();
		Opportunity opportunity = new Opportunity();

		opportunites.add(opportunity.clone());

		display = AccountAssessmentService.StarRatingAccountRiskPotential(createAccount(false), cases, opportunites);
		System.assertEquals('0', display.displayInfo.get(0));
	}

	public static testMethod void risk_rule_over_case_number() {
		AccountAssessmentService.ConditionDisplay display;
		List<Case> cases = new List<Case>();
		List<Opportunity> opportunites = new List<Opportunity>();
		Opportunity opportunity = new Opportunity();
		Case issue = new Case();

		display = AccountAssessmentService.StarRatingAccountRiskPotential(createAccount(false), cases, opportunites);
		System.assertEquals(5, display.starRating);

		issue.date__c = Date.today().addDays(-60);
		cases.add(issue.clone());

		issue.date__c = Date.today().addDays(-90);
		cases.add(issue.clone());

		display = AccountAssessmentService.StarRatingAccountRiskPotential(createAccount(false), cases, opportunites);
		System.assertEquals(3, display.starRating);

		issue.date__c = Date.today().addDays(-120);
		cases.add(issue.clone());

		issue.date__c = Date.today().addDays(-160);
		cases.add(issue.clone());

		issue.date__c = Date.today().addDays(-200);
		cases.add(issue.clone());

		display = AccountAssessmentService.StarRatingAccountRiskPotential(createAccount(false), cases, opportunites);
		System.assertEquals(1, display.starRating);
	}

	// ************************************************************************  Working Conditions
	public static testMethod void working_should_return_activity_date_list()
	{
		AccountAssessmentService.ConditionDisplay display;
		List<Event> events = new List<Event>();
		Event event = new Event();

		event.Type__c = 'Call';
		event.Sub_Type__c = 'Reservice';
		event.ActivityDate = Date.today().addDays(-299);
		events.add(event.clone());

		event.Type__c = 'Not a type';
		event.Sub_Type__c = 'Reservice';
		event.ActivityDate = Date.today().addDays(-299);
		events.add(event.clone());

		event.Type__c = 'Call';
		event.Sub_Type__c = 'not a subtype';
		event.ActivityDate = Date.today().addDays(-299);
		events.add(event.clone());

		event.Type__c = 'Call';
		event.Sub_Type__c = 'Reservice';
		event.ActivityDate = Date.today().addDays(-390);
		events.add(event.clone());

		event.Type__c = 'Meeting';
		event.Sub_Type__c = 'Reservice';
		event.ActivityDate = Date.today().addDays(-90);
		events.add(event.clone());

		event.Type__c = 'Call';
		event.Sub_Type__c = 'New Hire Pick-up';
		event.ActivityDate = Date.today().addDays(-90);
		events.add(event.clone());

		event.Type__c = 'Meeting';
		event.Sub_Type__c = 'Faculty/Group Meeting';
		event.ActivityDate = Date.today().addDays(-10);
		events.add(event.clone());

		event.Type__c = 'Call';
		event.Sub_Type__c = 'New Group Enrollment';
		event.ActivityDate = Date.today().addDays(-120);
		events.add(event.clone());

		display = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(false), events);

		integer x = events.size();
		while(x-- > 0)
		{
			if(x == 1 || x == 2 || x == 3)
				continue;

			boolean match = false;
			string format = events.get(x).Sub_Type__c + '|'  + events.get(x).ActivityDate.format();
			for(string result : display.displayInfo)
			{
				match = result == format;

				if(match)
					break;
			}

			System.assert(match);
		}

	}

	public static testMethod void working_rule_under_one_year()
	{
		AccountAssessmentService.ConditionDisplay display;
		List<Event> events = new List<Event>();
		Event event = new Event();

		event.Type__c = 'Call';
		event.Sub_Type__c = 'Reservice';
		event.ActivityDate = Date.today().addDays(-299);
		events.add(event.clone());

		event.Type__c = 'Call';
		event.Sub_Type__c = 'Reservice';
		event.ActivityDate = Date.today().addDays(-390);
		events.add(event.clone());

		event.Type__c = 'Meeting';
		event.Sub_Type__c = 'Reservice';
		event.ActivityDate = Date.today().addDays(-90);
		events.add(event.clone());

		event.Type__c = 'Call';
		event.Sub_Type__c = 'New Hire Pick-up';
		event.ActivityDate = Date.today().addDays(-90);
		events.add(event.clone());

		event.Type__c = 'Meeting';
		event.Sub_Type__c = 'Faculty/Group Meeting';
		event.ActivityDate = Date.today().addDays(-10);
		events.add(event.clone());

		event.Type__c = 'Call';
		event.Sub_Type__c = 'New Group Enrollment';
		event.ActivityDate = Date.today().addDays(-120);
		events.add(event.clone());

		display = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(false), events);

		System.assertEquals(5, display.displayInfo.size());
	}

	public static testMethod void working_rule_must_be_a_service()
	{

		AccountAssessmentService.ConditionDisplay display;
		List<Event> events = new List<Event>();
		Event event = new Event();

		event.Type__c = 'Call';
		event.Sub_Type__c = 'Not a service';
		event.ActivityDate = Date.today().addDays(-390);
		events.add(event.clone());

		event.Type__c = 'Meeting';
		event.Sub_Type__c = 'Faculty/Group Meeting';
		event.ActivityDate = Date.today().addDays(-10);
		events.add(event.clone());

		event.Type__c = 'Call';
		event.Sub_Type__c = 'New Group Enrollment';
		event.ActivityDate = Date.today().addDays(-120);
		events.add(event.clone());

		display = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(false), events);

		System.assertEquals(2, display.displayInfo.size());
	}

	public static testMethod void working_should_return_no_activity()
	{

		AccountAssessmentService.ConditionDisplay display;
		List<Event> events = new List<Event>();
		Event event = new Event();

		display = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(false), events);
		System.assertEquals('No Activity', display.displayInfo.get(0));

		event.ActivityDate = Date.today().addDays(-390);
		events.add(event.clone());

		display = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(false), events);
		System.assertEquals('No Activity', display.displayInfo.get(0));
	}
	public static testMethod void working_rule_must_be_a_type()
	{

		AccountAssessmentService.ConditionDisplay display;
		List<Event> events = new List<Event>();
		Event event = new Event();

		event.Type__c = 'Call';
		event.Sub_Type__c = 'Reservice';
		event.ActivityDate = Date.today().addDays(-39);
		events.add(event.clone());

		event.Type__c = 'Not a type';
		event.Sub_Type__c = 'Faculty/Group Meeting';
		event.ActivityDate = Date.today().addDays(-10);
		events.add(event.clone());

		event.Type__c = 'Call';
		event.Sub_Type__c = 'New Group Enrollment';
		event.ActivityDate = Date.today().addDays(-120);
		events.add(event.clone());

		display = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(false), events);
		System.assertEquals(2, display.displayInfo.size());
	}

	public static testMethod void working_rule_no_activity()
	{
		AccountAssessmentService.ConditionDisplay display;
		List<Event> events = new List<Event>();
		Event event = new Event();

		display = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(false), events);
		System.assertEquals(1, display.starRating);

		events.add(event.clone());

		display = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(false), events);
		System.assertEquals(1, display.starRating);

	}

	public static testMethod void working_rule_has_meeting_and_pickup()
	{
		AccountAssessmentService.ConditionDisplay display;
		List<Event> events = new List<Event>();
		Event event = new Event();
		event.ActivityDate = Date.today().addDays(-10);
		event.Type__c = 'Meeting';

		event.Sub_Type__c = 'Faculty/Group Meeting';
		events.add(event.clone());

		event.Sub_Type__c = 'New Hire Pick-up';
		events.add(event.clone());

		display = AccountAssessmentService.StarRatingAccountWorkingConditions(createAccount(false), events);
		System.assertEquals(5, display.starRating);

	}

	// ************************************************************************  contains
	public static testMethod void contains_should_return_true()
	{
		boolean match;
		match = AccountAssessmentService.contains(new List<string>{ 'test', 'testing' }, 'test');
		System.assert(match);

		match = AccountAssessmentService.contains(new List<string>{ 'test' }, 'test');
		System.assert(match);
	}

	public static testMethod void contains_should_return_false()
	{
		boolean match;

		match = AccountAssessmentService.contains(new List<string>(), 'test');
		System.assert(match == false);

		match = AccountAssessmentService.contains(new List<string>{ 'not test' }, 'test');
		System.assert(match == false);
	}
}