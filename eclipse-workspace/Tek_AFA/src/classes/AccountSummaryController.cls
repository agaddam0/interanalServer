public class AccountSummaryController  {
	public decimal starTotal = 0;
	public integer metricsCount = 8;

	public AccountSummaryController(ApexPages.StandardController controller)
	{

		Account account = [
			SELECT 	id, name,
					ap_percent_of_change__c, annualized_premium__c,
					policy_of_change__c, policy_count__c, status__c
			FROM 	account
			WHERE 	id =: ((Account)controller.getRecord()).Id
		];

		List<Asset> assets = [
			SELECT 	name, recordtype.name, status, carrier__c
			FROM 	asset
			WHERE 	accountid =: account.Id
		];

		List<Event> events = [
			SELECT 	id, type__c, activitydate, sub_type__c
			FROM 	event
			WHERE 	accountid =: account.Id
		];

		List<Contact> contacts = [
			SELECT 	id, type__c, inactive__c, email, phone, decision_maker__c
			FROM 	contact
			WHERE 	accountid =: account.Id
		];

		List<Case> cases = [
			SELECT 	id, date__c
			FROM 	case
			WHERE 	accountid =: account.Id
		];

		List<Opportunity> opportunities = [
			SELECT 	id, record_type__c
			FROM 	opportunity
			WHERE 	accountid =: account.Id
		];

		this.starTotal =
			AccountAssessmentService.StarRatingAccountProducts(account, assets).starRating +
			AccountAssessmentService.StarRatingAccountServices(account, assets).starRating +
			AccountAssessmentService.StarRatingAccountPremium(account).starRating +
			AccountAssessmentService.StarRatingAccountPolicies(account).starRating +
			AccountAssessmentService.StarRatingAccountActivity(account, events).starRating +
			AccountAssessmentService.StarRatingAccountContacts(account, contacts).starRating +
			AccountAssessmentService.StarRatingAccountRiskPotential(account, cases, opportunities).starRating +
			AccountAssessmentService.StarRatingAccountWorkingConditions(account, events).starRating;

	}
	public decimal getMetricsCount() {
		return this.metricsCount;
	}

	public decimal getStarTotal() {
		return this.starTotal;
	}
}