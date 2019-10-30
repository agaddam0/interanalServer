public class AccountDashboardController  {
	private final Account account;

	public AccountDashboardController(ApexPages.StandardController controller)
	{
		this.account = (Account)controller.getRecord();
	}

	@RemoteAction
	public static AccountAssessmentService.ConditionDisplay StarRatingAccountProducts(Account account, List<Asset> assets)
	{
		return AccountAssessmentService.StarRatingAccountProducts(account, assets);
	}

	@RemoteAction
	public static AccountAssessmentService.ConditionDisplay StarRatingAccountServices(Account account, List<Asset> assets)
	{
		return AccountAssessmentService.StarRatingAccountServices(account, assets);
	}

	@RemoteAction
	public static AccountAssessmentService.ConditionDisplay StarRatingAccountPremium(Account account)
	{
		return AccountAssessmentService.StarRatingAccountPremium(account);
	}

	@RemoteAction
	public static AccountAssessmentService.ConditionDisplay StarRatingAccountPolicies(Account account)
	{

		return AccountAssessmentService.StarRatingAccountPolicies(account);
	}

	@RemoteAction
	public static AccountAssessmentService.ConditionDisplay StarRatingAccountActivity(Account account, List<Event> events)
	{

		return AccountAssessmentService.StarRatingAccountActivity(account, events);
	}

	@RemoteAction
	public static AccountAssessmentService.ConditionDisplay StarRatingAccountContacts(Account account, List<Contact> contacts)
	{

		return AccountAssessmentService.StarRatingAccountContacts(account, contacts);
	}

	@RemoteAction
	public static AccountAssessmentService.ConditionDisplay StarRatingAccountRiskPotential(Account account, List<Case> cases, List<Opportunity> saves)
	{

		return AccountAssessmentService.StarRatingAccountRiskPotential(account, cases, saves);
	}

	@RemoteAction
	public static AccountAssessmentService.ConditionDisplay StarRatingAccountWorkingConditions(Account account, List<Event> events)
	{
		return AccountAssessmentService.StarRatingAccountWorkingConditions(account, events);
	}

}