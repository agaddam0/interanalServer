/*********************************************************************************************
// Version:             1.0
// Author:				Etherios
// Date Created:        1/16/2015
// Description:         standardAccountBLogic Apex class for customization on triggers for the 
//						Account object
//   
// Copyright 2015 Etherios. All rights reserved. Customer confidential. Do not distribute.
//
// Revision History
// DATE               AUTHOR                    REQUIREMENT#          DETAILS
// 1/16/2015         Brian Knowlton                                  See Class header notes
//
// *********************************************************************************************
// ********************************************************************************************/



/***********************************************************************************************
* Class Header Notes
* Apex class on the modification of fields on the Opportunity object coming from the standardOpportunity Trigger
**
* When User click Add Services button, trigger is run that clones Assets on the Parent Object and 
* sends to Child Accounts. If Child Account already has service/Asset, it does not clone again.
* 
* 
* 
*
***********************************************************************************************/
public without sharing class standardAccountBLogic {

	
	

	/******************************************************************************************
	 * Method Name:		cloneAssetsToChildAcc
	 * Parameters: 		Account object (taken as a list when Clone_Flag__c is already true from Trigger)
	 * Return type:		void
	 * Description:		Clones Parent's Assets/Services and adds them to the Child Accounts. If already exist on Child
	 *					it does not re-copy. Matches the Name of the Assets to determine whether or not to clone.
	 * Notes:			Need to know what fields should be passed to the cloned Asset Objects
	 ******************************************************************************************/
	public static void cloneAssetsToChildAcc(list<Account> accounts)
	{
		
		System.debug('ACCOUNTS -- > ' + accounts + '\t' + accounts.size());
		
		
		// get parentAccount Assets
		// get Affected Child Accounts
		
        Id EMServices = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Expense Management Services').getRecordTypeId();
        
		String soql = Util.getCreatableFieldsSOQL('Asset', 'AccountId IN: accounts AND RecordTypeId =: EMServices');
		list<Asset> parentAccountAsset = database.query(soql);
        //list<Asset> parentAccountAsset = [SELECT Id, Name, AccountId, Record_Type_Developer_Name__c From Asset WHERE AccountId  in:accounts AND Record_Type_Developer_Name__c LIKE '%Services%'];
		list<Account> affectedChildAccounts = [SELECT Id, Name, ParentId, Office_Main_2__c, (SELECT Id, Name, AccountId, Description FROM Assets) FROM Account WHERE ParentId in :accounts];
		
		
		System.debug('PARENT Account Assets and affectedChildAccounts -- > ' + parentAccountAsset + 
                     '\n affectedChildAccounts' + affectedChildAccounts);
		
		// initialize everything
		list<Asset> assetToCreate = new list<Asset>();
		map<String, Asset> m = new map<String, Asset>();
		map<Id, list<Asset>> assetsToCreate = new map<Id, list<Asset>>();
		
		
		// only need to do this if there exists parent and affectedChildAccounts
		if( !parentAccountAsset.isEmpty() && !affectedChildAccounts.isEmpty() )
		{		
			// map of Asset Name & Asset since we are matching the Name of the Asset
			for(Asset a : parentAccountAsset)
			{
			    m.put(a.Name, a);
			}
			
			// loop on affected Childs
			for(Account acc : affectedChildAccounts)
			{
				// loop over childAccount Assets
				// if the asset is matched remove from copied map
			    map<String, Asset> m1 = new map<String, Asset>(m);
			    for(Asset b : acc.Assets)
			    {
			        if(m1.containsKey(b.Name))
			        {
			            m1.remove(b.Name);
			        }
			    }
			    //insert remaining Assets into new map using the Child Account Id as key now
			    system.debug('values' + m1.values());
			    assetsToCreate.put(acc.Id, m1.values());
			}
			
			System.debug('ASSETs TO CREATE -> ' + assetsToCreate.values());
			
			// loop and clone Assets
			// Assign new AccountId 
			for(Id i : assetsToCreate.keySet())
			{
			    list<Asset> manyAssets = assetsToCreate.get(i);
			    for(Asset a : manyAssets)
			    {
			        Asset cloned = a.Clone(false, true);
			        cloned.AccountId = i;
			        // Asset is now a clone of Parent
			        cloned.Cloned__c = true;
                    cloned.RecordTypeId = EMServices;
			        assetToCreate.add(cloned);
			    }
			    System.debug('WHAT - >' + assetsToCreate.get(i) + ' ' + i);
			}	
			// Create our new Assets for childAccounts
			System.debug('About to insert new Assets ' + assetToCreate);
			if(!assetToCreate.isEmpty())
			{
				try{
					upsert assetToCreate;
				}catch(Exception eX){
					System.debug(LoggingLevel.DEBUG, 'Failed to create cloned Assets for Child Accounts ' + eX.getMessage() );
				}
			}	
		}
	}
	
	/******************************************************************************************
	 * Method Name:		updateParentFlag
	 * Parameters: 		Account object (taken as a list when Clone_Flag__c is already true from Trigger)
	 * Return type:		void
	 * Description:		after add services is done, reset parent flag to false.
	 * 
	 *
	 ******************************************************************************************/
	public static void updateParentFlag(list<Account> accounts)
	{
		for(Account a : accounts)
		{		
			a.Clone_Flag__c = false;
		}
	}
	
	

	/******************************************************************************************
	 * Method Name:		updateAggregateTotals
	 * Parameters: 		Account (taken as a list when Overall_Participation_Flag__c is already true from Trigger)
	 * Return type:		void
	 * Description:		rollup summary of fields on Account Records where recordType is Customer Account Or Locations 
	 *						recordtype. 
	 * 
	 *
	 ******************************************************************************************/
	public static void updateAggregateTotals(list<Account> accs)
	{
		System.debug('**** BEGIN AGGREGATE TOTALS****');
		list<Account> accToUpdate = new list<Account>();
		list<Account> prntAcc = new list<Account>();
		
		//Id cusId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account' LIMIT 1].Id;
		//Id locId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName='Locations' LIMIT 1].Id;
		Id cusId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
		Id brokId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Brokerage Customer').getRecordTypeId();
		
		set<Id> recId = new set<Id>();
		
		recId.add(cusId);
		recId.add(brokId);
		
		list<Account> acc = [SELECT Id,
                             Annualized_Premium__c,
                             Consolidated_Annualized_Premium__c,
                             Consolidated_Customer_Count__c,
                             Consolidated_Eligible_Employee_Count__c,
                             Consolidated_Overall_Participation__c,
                             Consolidated_Policy_Count__c,
                             Customer_Count__c, 
					 		 Eligibile_Employee_Count__c, 
                             Overall_Participation__c,
                             Overall_Participation_Flag__c,
                             parentId,
                             Policy_Count__c,
                             RecordTypeId,
                             Parent.Annualized_Premium__c,
                             Parent.Consolidated_Annualized_Premium__c,
                             Parent.Consolidated_Customer_Count__c,
                             Parent.Consolidated_Eligible_Employee_Count__c,
                             Parent.Consolidated_Overall_Participation__c,
                             Parent.Consolidated_Policy_Count__c,
                             Parent.Customer_Count__c, 
                             Parent.Eligibile_Employee_Count__c, 
                             Parent.Overall_Participation__c, 
                             Parent.Overall_Participation_Flag__c,
                             Parent.Policy_Count__c,
                             (SELECT Id, 
                              Annualized_Premium__c,
                              Consolidated_Annualized_Premium__c,
                              Consolidated_Customer_Count__c, 
                              Consolidated_Eligible_Employee_Count__c,
                              Consolidated_Policy_Count__c,
                              Customer_Count__c, 
                              Eligibile_Employee_Count__c, 
                              Overall_Participation__c,
                              Policy_Count__c,
                              RecordTypeId 
                              FROM childAccounts)
                     FROM Account 
                     WHERE Id IN :accs 
                           AND RecordTypeId IN :recId];
          
        System.debug(' $$$ Here is the size of our affected accounts : ' + acc.size() + '\nHere they are ' + acc);           
		for(Account a : acc)
		{		
				//Integer count = 1;
			    //Double avg = 0.0;
			    Decimal empl_count = 0.0; // consolidated overall employee count
			    Decimal cust_count = 0.0; // consolidated overall customer count
            	Decimal policy_count = 0.0; // consolidated overall policy count
            	Decimal annual_premium = 0.00; // consolidated overall annualized premium
			    if(null != a.Eligibile_Employee_Count__c)
			    	empl_count += a.Eligibile_Employee_Count__c;
			    if(null != a.Customer_Count__c)
			    	cust_count += a.Customer_Count__c;
            	if(null != a.Policy_Count__c)
                    policy_count += a.Policy_Count__c;
            	if(null != a.Annualized_Premium__c)
                    annual_premium += a.Annualized_Premium__c;
            	
			    // avg the totals
			    
			    if(a.RecordTypeid == cusId)
			    {
			    	//System.debug('Customer recordType');
			    	//System.debug('*** Overall Part ***' + a.Overall_Participation__c);
			    	//System.debug('*** empl_count ***' + empl_count);
			    	//System.debug('*** cust_count ***' + cust_count);
			        //avg += a.Overall_Participation__c;
                    for(Account b : a.childAccounts)
                    {
                        if(cusId == b.RecordTypeId || brokId == b.RecordTypeId)
                        {
                            if(b.Consolidated_Eligible_Employee_Count__c != null)
                            {
                                System.debug('NULL ?' + b.Eligibile_Employee_Count__c + '\t OR ' + empl_count);
                                empl_count += b.Consolidated_Eligible_Employee_Count__c;
                            }
                        
                            if(b.Consolidated_Customer_Count__c != null)
                                cust_count += b.Consolidated_Customer_Count__c;
                            
                            if(b.Consolidated_Annualized_Premium__c != null)
                                annual_premium += b.Consolidated_Annualized_Premium__c;
                            
                            if(b.Consolidated_Policy_Count__c != null)
                                policy_count += b.Consolidated_Policy_Count__c;
                        }
                    }
                    
			    Double dAvg = 0.0;
                    
			    if((null != cust_count || null != empl_count) && empl_count > 0)
			   		dAvg = (cust_count / empl_count) * 100;           
			   	//Double dAvg = avg / count;
			   	System.debug('*** DAvg *** ' + dAvg);
			    if(dAvg < 999.99)
			    	a.Consolidated_Overall_Participation__c = dAvg;
			    else
			        a.Consolidated_Overall_Participation__c = 999.99;
			    
			    a.Consolidated_Eligible_Employee_Count__c = empl_count;
			    a.Consolidated_Customer_Count__c = cust_count;
                a.Consolidated_Policy_Count__c = policy_count;
                a.Consolidated_Annualized_Premium__c = annual_premium;
			    
			    a.Overall_Participation_Flag__c = false;
			    accToUpdate.add(a);
			    /*	
			    //System.debug('Customer recordType');
			    //System.debug('*** Cons. Overall Part ***' + a.Consolidated_Overall_Participation__c);
			    //System.debug('*** Cons. empl_count ***' + a.Consolidated_Eligible_Employee_Count__c);
			    //System.debug('*** Cons. cust_count ***' + a.Consolidated_Customer_Count__c);
			    */
			    }
			    
			    if(a.parentId != null)
			    {
			    	a.Parent.Overall_Participation_Flag__c = true;
			    	//accToUpdate.add(a.Parent);
			    	 prntAcc.add(a.Parent);
			    }			    
			    //System.debug('Consolidated_Overall_Participation__c  ' +a.Consolidated_Overall_Participation__c);
		}		
		System.debug('++++ NUM ACCOUNTS TO UPDATE +++ ' + accToUpdate.size());		
		//System.debug(accToUpdate[0].Consolidated_Overall_Participation__c);
		if(accToUpdate.size() > 0){
		    try{
		        update accToUpdate;
		   }catch(Exception e){
		        System.debug('*** UNABLE TO UPDATE ***' + e.getMessage());
		    }
		}
		if(prntAcc.size() > 0) updateAggregateTotals(prntAcc);
		System.debug('**** END ****');	
	}
	
	public static void rollupOnDelete(list<Account> accs)
	{
		list<Account> affectedAcc = new list<Account>();
		set<Id> me = new set<Id>();		
		for(Account a : accs)
		{
			if(a.ParentId != null)				
				me.add(a.ParentId);
				
			System.debug(a.Id + '\t' + a.ParentId);
		}
		System.debug('SIZE OF affectedACC ' + affectedAcc.size());
		if(me.size() > 0)
			affectedAcc = [SELECT Id FROM Account WHERE Id IN :me];			
		if(affectedAcc.size() > 0)
			updateAggregateTotals(affectedAcc);
	}
}