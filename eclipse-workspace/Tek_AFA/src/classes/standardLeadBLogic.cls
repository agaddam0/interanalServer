public with sharing class standardLeadBLogic {


	public static void createBPRecord(list<Lead> triggerNew)
	{
		list<Id> convertAccId = new list<Id>();
		// get leads that have been affected...
		// converted & has an association.
		list<Lead> affectedLeads = [SELECT Id, Association__c, ConvertedAccountId, Association__r.Name FROM Lead WHERE Id in :triggerNew AND Association__c != null AND isConverted = true ];
		list<Business_Partner__c> busPtnr = new list<Business_Partner__c>();
		
		for(Lead l : affectedLeads){
			convertAccId.add(l.ConvertedAccountId);
		}
		// get account Ids of converted leads...
		list<Business_Partner__c> affectedPtnrs = [SELECT Id, Name, Account__c, Business_Partner__c 
												FROM Business_Partner__c 
												WHERE Account__c in :convertAccId];
		System.debug('Looping through affectedLeads -- > ' + affectedLeads.size() + '\tbptners '+ affectedPtnrs.size() );
		if(!affectedPtnrs.isEmpty()){
			for(Lead l : affectedLeads)
			{
				System.debug('Looping through BPs ' );
				for(Business_Partner__c bptnr : affectedPtnrs ) 
				{
					System.debug('do we have anything to look at? Accounts ... ' + bptnr.Account__c + '\t' + l.ConvertedAccountId +
											'\nAssociations ... ' + bptnr.Business_Partner__c + '\t' + l.Association__c);
						if(bptnr.Account__c != l.ConvertedAccountId || bptnr.Business_Partner__c != l.Association__c) 
						{
							System.debug('We don\'t  have a match! Hoorah! Create a new record .... ');
							busPtnr.add( createNewBPRecord(l.ConvertedAccountId, l.Association__r.Id, l.Association__r.Name) );
						} 
				}
			}
		}else{
			for(Lead l : affectedLeads)
			{
				busPtnr.add( createNewBPRecord(l.ConvertedAccountId, l.Association__c, l.Association__r.Name) );
			}
		}
		
		// if we have a list, try to insert that list 
		if(!busPtnr.isEmpty() )
		{
			System.debug('Inserting new Business Partner Records from standardLeadBLogic.createBPRecord ---> ' + busPtnr.size() );
			try{
				insert busPtnr;
			}catch(Exception eX){
				System.debug('Unable to create new Business Partner Records ---> ' + eX.getMessage() + '\t' + eX.getLineNumber() );
			}
		}
		
	}
	
	public static Business_Partner__c createNewBPRecord(Id acc, Id bp, String name)
	{
		Business_Partner__c newBP = new Business_Partner__c();
		newBp.Account__c = acc;
		newBp.Business_Partner__c = bp;
		//newBp.Name = name;
		
		return newBp;
	}
}