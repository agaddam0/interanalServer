global with sharing class AccountAssessmentDetailsExt {
		
	//private static string strBuilder = '';
	private static double overallRating = 0.0;
	private static string nullCatch = '';
	
    private static final string SPLIT_CHAR = 'ϟ';    
	private static final double METRICS_COUNT = 8.0;
	
    public AccountAssessmentDetailsExt(ApexPages.StandardController controller){        
    }
    
    @RemoteAction
    public static List<Id> getUsers(List<Id> ids){
    	
    	List<Id> userIds = new List<Id>();
    
    	List<User> childUsers = [
    		Select id FROM User WHERE UserRoleId IN : ids
    	];
    	
    	for(User user : childUsers){
    		userIds.add(user.id);
    	}
    	System.debug(ids);
    	return userIds;
    }
    
    @RemoteAction
    public static string getSplitChar(){
    	return SPLIT_CHAR;
    }
    
    @RemoteAction
    public static String getStarsFromUsers(List<Id> userIds, integer skipAmt, List<Id> offsetId){
    	List<Account> acc = new List<Account>();
    	
    	if(offsetId == null){
	   
    		//Get accounts from every user
		    	acc = [
					SELECT 	id, name,
							ap_percent_of_change__c, annualized_premium__c,
							policy_of_change__c, policy_count__c, Owner.Name, Owner_Region__c,
							Owner_Team_District__c, Status__c, Division__c,
	                		(select name, recordtype.name, status, carrier__c from Assets),
	                		(select id, type__c, activitydate, sub_type__c from Events),
	                		(select id, type__c, inactive__c, email, phone, decision_maker__c from Contacts),
	                		(select id, date__c from Cases),
	                		(select id, record_type__c from Opportunities)
					FROM 	account
					WHERE 	//OwnerId IN : userIds 
					//AND
						 	RecordType.Name = 'Customer Account'
					AND		Status__c = 'Active' 
					AND 	Field_Status__c = 'Active' 
					AND 	Sample_Record__c = False
					AND		Division__c != 'DIRRES'
					LIMIT 2000		
				];
    	} else {
    		acc = [
					SELECT 	id, name,
							ap_percent_of_change__c, annualized_premium__c,
							policy_of_change__c, policy_count__c, Owner.Name, Owner_Region__c,
							Owner_Team_District__c, Status__c, Division__c,
	                		(select name, recordtype.name, status, carrier__c from Assets),
	                		(select id, type__c, activitydate, sub_type__c from Events),
	                		(select id, type__c, inactive__c, email, phone, decision_maker__c from Contacts),
	                		(select id, date__c from Cases),
	                		(select id, record_type__c from Opportunities)
					FROM 	account
					WHERE 	//OwnerId IN : userIds 
					//AND		
							account.Id != : offsetId
					AND 	RecordType.Name = 'Customer Account'
					AND		Status__c = 'Active' 
					AND 	Field_Status__c = 'Active' 
					AND 	Sample_Record__c = False
					AND		Division__c != 'DIRRES'	
					LIMIT 2000		
				];
    	}
				
    	return getStarsFromAccounts(acc);
    }
    
    // Accounts passed in must contain the children 
    // Assets, Events, Contacts, Cases, and Opportunities attached to it
    @RemoteAction
    public static String getStarsFromAccounts(List<Account> accounts){
    	
    	 List<String> strBuilder = new List<String>();
    	 List<String> strIds = new List<String>();
       	 
        double		prodRat = 0.0,
                	servRat = 0.0,
                	premRat = 0.0,
                	poliRat = 0.0,
                	actiRat = 0.0,
                	contRat = 0.0,
                	riskRat = 0.0,
                	condRat = 0.0;
        
    	for(Account ac : accounts){
    		
    		nullCatch = (ac.Owner_Region__c == null) ? 'Region' : ac.Owner_Region__c;
    		
    		nullCatch = (ac.Owner_Team_District__c == null) ? nullCatch + SPLIT_CHAR + 'District' : nullCatch + SPLIT_CHAR + ac.Owner_Team_District__c;
           
        		prodRat = AccountAssessmentService.StarRatingAccountProducts(ac, ac.Assets).starRating;
               	servRat = AccountAssessmentService.StarRatingAccountServices(ac, ac.Assets).starRating;
                premRat = AccountAssessmentService.StarRatingAccountPremium(ac).starRating;
               	poliRat = AccountAssessmentService.StarRatingAccountPolicies(ac).starRating;
              	actiRat = AccountAssessmentService.StarRatingAccountActivity(ac, ac.Events).starRating;
               	contRat = AccountAssessmentService.StarRatingAccountContacts(ac, ac.Contacts).starRating;
               	riskRat = AccountAssessmentService.StarRatingAccountRiskPotential(ac, ac.Cases, ac.Opportunities).starRating;
               	condRat = AccountAssessmentService.StarRatingAccountWorkingConditions(ac, ac.Events).starRating;
                
            overallRating = Math.roundToLong(((prodRat + servRat + premRat + poliRat + actiRat + contRat + riskRat + condRat) / METRICS_COUNT));
            
            strBuilder.add(nullCatch
            	+ SPLIT_CHAR + ac.Division__c
            	+ SPLIT_CHAR + ac.Owner.Name 
                + SPLIT_CHAR + ac.name
    			+ SPLIT_CHAR + overallRating
    			+ SPLIT_CHAR + prodRat
    			+ SPLIT_CHAR + servRat 
    			+ SPLIT_CHAR + premRat 
    			+ SPLIT_CHAR + poliRat 
    			+ SPLIT_CHAR + actiRat 
    			+ SPLIT_CHAR + contRat
    			+ SPLIT_CHAR + riskRat
    			+ SPLIT_CHAR + condRat + '\n');
    		strIds.add(ac.Id + '\n');
            	
        }
       	List<String> comboStrBuilder = new List<String>(strBuilder);
       	comboStrBuilder.addAll(strIds);
       	
        String result = String.join(comboStrBuilder, '');
        
        
        
        return result;
    }
}