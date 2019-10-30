public class AccountAssessmentService {
	@TestVisible private static ConditionDisplay StarRatingOverride(Account account, conditionDisplay display) {
		boolean lapsed = account.Status__c == 'L' || account.Status__c == 'Lapsed';
		if (lapsed) {
			display.starRating = 1;
		}

		return display;
	}
	public static ConditionDisplay StarRatingAccountProducts(Account account, List<Asset> assets)
	{
		ConditionDisplay conditionDisplay = new ConditionDisplay();
		string prefix = '';
		integer assetCount = 0;

		for(Asset asset : assets)
		{
			Boolean recordType = asset.RecordType.Name == 'Benefits';
			Boolean notActive = asset.Status != 'Active';
			Boolean isAggregate = asset.Name.contains('Total');

			if(recordType == false || notActive || isAggregate)
				continue;

			assetCount++;

			conditionDisplay.AddDisplayInfo(prefix + asset.Name);
			prefix = ', ';
		}

		if(conditionDisplay.displayInfo.size() == 0)
			conditionDisplay.AddDisplayInfo('None');

		if(assetCount == 0)
			conditionDisplay.starRating = 1;
		else if(assetCount < 5)
			conditionDisplay.starRating = assetCount;
		else
			conditionDisplay.starRating = 5;

		return StarRatingOverride(account, conditionDisplay);
	}

	public static ConditionDisplay StarRatingAccountServices(Account account, List<Asset> assets)
	{
		ConditionDisplay conditionDisplay = new ConditionDisplay();
		boolean hasSection125 = false;
		integer otherProducts = 0;
		string prefix = '';

		// look for section 125
		for(Asset asset : assets)
		{

			boolean isRecordType 	= asset.RecordType.Name	== 'Expense Management Services';
			boolean isCarrier 		= asset.Carrier__c 		== 'AFA';
			boolean isActive 		= asset.Status			== 'Active';
			boolean isSection125	= asset.Name.containsIgnoreCase('Section 125');

			// record does not meet the requirements
			if(isRecordType == false || isCarrier == false || isActive == false)
				continue;

			if(isSection125)
				hasSection125 = true;
			else
				otherProducts ++;

			conditionDisplay.AddDisplayInfo(prefix + asset.Name);
			prefix = ', ';

		}

		if(conditionDisplay.displayInfo.size() == 0)
			conditionDisplay.AddDisplayInfo('None');

		if(hasSection125 == false)
			conditionDisplay.starRating = 1;
		else if(otherProducts == 0)
			conditionDisplay.starRating = 3;
		else
			conditionDisplay.starRating = 5;

		return StarRatingOverride(account, conditionDisplay);
	}

	public static ConditionDisplay StarRatingAccountPremium(Account account)
	{
		ConditionDisplay conditionDisplay = new ConditionDisplay();
		string premiumAmount = (account.Annualized_Premium__c == null) ? 'N/A' : '$' + account.Annualized_Premium__c.format();
		string amountChange = (account.AP_Percent_of_Change__c == null) ? 'N/A' : account.AP_Percent_of_Change__c.format() + '%';

		conditionDisplay.AddDisplayInfo(premiumAmount);
		conditionDisplay.AddDisplayInfo(amountChange);


		if(account.AP_Percent_of_Change__c == null)
			conditionDisplay.starRating = 1;
		else if(account.AP_Percent_of_Change__c > 0)
			conditionDisplay.starRating = 5;
		else if(account.AP_Percent_of_Change__c > -25)
			conditionDisplay.starRating = 3;
		else
			conditionDisplay.starRating = 1;

		return StarRatingOverride(account, conditionDisplay);
	}

	public static ConditionDisplay StarRatingAccountPolicies(Account account)
	{
		ConditionDisplay cDisplay = new ConditionDisplay();

		cDisplay.AddDisplayInfo(account.Policy_of_Change__c == null? 'N/A' :  account.Policy_of_Change__c.format() + '%');
		cDisplay.AddDisplayInfo(account.Policy_Count__c == null? 'N/A' : account.Policy_Count__c.format());

		if(account.Policy_of_Change__c == null)
			cDisplay.starRating = 1;

		else if(account.Policy_of_Change__c > 0)
			cDisplay.starRating = 5;

		else if(account.Policy_of_Change__c > -25)
			cDisplay.starRating = 3;

		else
			cDisplay.starRating = 1;

		return StarRatingOverride(account, cDisplay);
	}

	public static ConditionDisplay StarRatingAccountActivity(Account account, List<Event> events)
	{
		ConditionDisplay conditionDisplay 	= new ConditionDisplay();
		List<string> types 					= new List<string> { 'Call', 'Meeting' };
		Date levelFiveCutOffDate 			= Date.today().addDays(-90);
		Date levelThreeCutOffDate 			= Date.today().addDays(-120);
		Date lastDate						= null;
		integer count						= 0;

		for(Event event : events)
		{
			if(contains(types, event.Type__c))
			{
				if(lastDate == null)
					lastDate = event.ActivityDate;

				count++;

				lastDate = event.ActivityDate > lastDate ? event.ActivityDate : lastDate;
			}

		}

		if(lastDate > levelFiveCutOffDate)
			conditionDisplay.starRating = 5;
		else if(lastDate > levelThreeCutOffDate)
			conditionDisplay.starRating = 3;
		else
			conditionDisplay.starRating = 1;


		conditionDisplay.AddDisplayInfo(count.format());
		conditionDisplay.AddDisplayInfo(count == 0 ? 'N/A' : lastDate.format());

		return StarRatingOverride(account, conditionDisplay);
	}

	public static ConditionDisplay StarRatingAccountContacts(Account account, List<Contact> contacts)
	{
		ConditionDisplay conditionDisplay = new ConditionDisplay();
		boolean hasDecisionMaker 	= false;
		integer complete 			= 0;
		integer incomplete 			= 0;
		string prefix				= '';
		string typeOfContacts		= '';

		for(Contact contact : contacts)
		{
			if(contact.Inactive__c)
				continue;

			if(contact.Email == '' || contact.Phone == '' )
			{
				incomplete++;
				continue;
			}


			if(contact.Decision_Maker__c)
				hasDecisionMaker = true;

			complete++;

			// don't add the type to the output if its null
			if(contact.Type__c == null)
				continue;

			typeOfContacts += prefix + contact.Type__c;
			prefix = ', ';
		}

		conditionDisplay.AddDisplayInfo(typeOfContacts);
		conditionDisplay.AddDisplayInfo(complete.format());
		conditionDisplay.AddDisplayInfo(hasDecisionMaker? 'Yes' : 'No');

		// rule one star
		if(hasDecisionMaker == false)
			conditionDisplay.starRating = 1;
		// rule five star
		else if(complete > 2)
			conditionDisplay.starRating = 5;
		// rule two
		else if(complete <= 2 || complete + incomplete > 3)
			conditionDisplay.starRating = 3;


		return StarRatingOverride(account, conditionDisplay);
	}

	public static ConditionDisplay StarRatingAccountRiskPotential(Account account, List<Case> cases, List<Opportunity> saves)
	{
		ConditionDisplay conditionDisplay = new ConditionDisplay();

		integer caseNumber = 0;
		integer saveNumber = 0;

		for(Case issue : cases)
			if(issue.date__c > Date.today().addDays(-365))
				caseNumber++;

		for(Opportunity save : saves)
			if(save.Record_Type__C == 'Save Opportunity')
				saveNumber++;

		conditionDisplay.AddDisplayInfo(caseNumber.format());
		conditionDisplay.AddDisplayInfo(saveNumber.format());

		if(saveNumber > 0 || caseNumber > 4)
			conditionDisplay.starRating = 1;
		else
			conditionDisplay.starRating = (caseNumber == 0) ? 5 : 3;

		return StarRatingOverride(account, conditionDisplay);
	}

	public static ConditionDisplay StarRatingAccountWorkingConditions(Account account, List<Event> events)
	{
		ConditionDisplay conditionDisplay 	= new ConditionDisplay();
		integer count 						= 0;
		boolean hasService					= false;
		boolean hasPickup					= false;
		boolean hasMeeting					= false;
		string pickup						= 'New Hire Pick-up';
		string meeting						= 'Faculty/Group Meeting';
		List<String> services				= new List<string> {
			'New Group Enrollment',
			'Reservice',
			pickup,
			meeting
		};
		List<string> types 					= new List<string> {
			'Call',
			'Meeting'
		};


		for(Event event : events)
		{
			if(contains(types, event.Type__c) == false)
				continue;

			if(event.ActivityDate < Date.today().addDays(-365))
				continue;

			if(contains(services, event.Sub_Type__c) == false)
				continue;

			count ++;
			hasService = true;

			if(event.Sub_Type__c == pickup)
				hasPickup = true;
			else if(event.Sub_Type__c == meeting)
				hasMeeting = true;

			conditionDisplay.AddDisplayInfo(
				event.Sub_Type__c + '|' + event.ActivityDate.format());
		}

		if(count == 0)
			conditionDisplay.AddDisplayInfo('No Activity');

		conditionDisplay.starRating = 1;

		if(hasService)
			conditionDisplay.starRating = (hasMeeting && hasPickup) ? 5 : 3;

		return StarRatingOverride(account, conditionDisplay);
	}

	@TestVisible private static boolean contains(List<string> items, string search)
	{
		for(string item : items)
			if(search == item)
				return true;

		return false;
	}

	public class ConditionDisplay
	{
		public integer starRating =  0;
		public List<string> displayInfo = new List<string>();

		public void AddDisplayInfo(string info)
		{
			displayInfo.add(info);
		}
	}

}