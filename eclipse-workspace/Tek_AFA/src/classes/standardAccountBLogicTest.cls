@isTest
private class standardAccountBLogicTest {

    static testMethod void clonePositiveAssets() {
        Util uClass = new Util();
        Integer howMany = 5;
        Boolean doInsert = true;
        String prefix = 'Test Apex';
        
    	Id cusId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account' LIMIT 1].Id;
        
        list<Account> a = uClass.createAcc('Apex Test Acc', howMany, true, cusId);
        Account achild = new account(name='child account', parentId = a[0].Id);
        list<Contact> c = uClass.createCont('Apex Test Name', 1, a[0].Id, true);
		
		System.debug(c);
		Id pricebookId = Test.getStandardPricebookId();
		
		list<Product2> p = uClass.createProd(howMany, prefix, doInsert);
		for(Product2 p2: p)
		{
			PricebookEntry pbe = uClass.createPBEntry(true, pricebookId, p2.Id, 100);
		}
        
        // all assets belong to first account (will be parent)
        Id rType = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Expense Management Services').getRecordTypeId();
        list<Asset> asset = uClass.createAsset(howMany, doInsert, prefix, a[0].Id, p[0].Id, rType);
        Asset assetChild = uClass.createOneAsset(true, a[1].Id, p[0].Id, prefix + ' 0', rType);
        list<Account> affectedAccount = new list<Account>();
        // reparent last 4 accounts
        for(Integer i = 0; i < a.size(); i++)
        {
        	if(i != 0)	{a[i].ParentId = a[0].Id;}
        	System.debug('PARENT FROM TEST ' + a[i].ParentId);
        	
        	
        }
        update a;
        a[0].Clone_Flag__c = true;
        System.debug('Updating this many ... ' + affectedAccount.size());
        	update a[0];
      
        
        affectedAccount = [SELECT Id, Name, (SELECT Id, Name FROM Assets) FROM Account];
        for(Account a2 : affectedAccount)
        {
        	System.debug('Assests Name -- > ' + a2.Name + ' Size ->\t' + a2.Assets.size() );
        	for(Asset as1 : a2.Assets){
        		System.debug('ASSETS --> ' + as1.Id);
        	}
        	//system.assertEquals(howMany, a2.assets.size(), 'Sizes do not match up ' + a2.Name + ' \t' + a2.assets.size() );
        }
    }
    
    static testMethod void zeroCount()
    {
    	Decimal empl_count = 0.0;
    	Decimal cust_count = 0.0;
    	Double avg = 0.0; 
    	Util u = new Util();
    	Integer count = 5;
    	Boolean doInsert = true;
    	String prefix = 'Test Apex Account';
    	Id cusId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account' LIMIT 1].Id;
		Id locId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName='Locations' LIMIT 1].Id;
    	
    	list<Account> lstAcc = u.createAcc(prefix, count, doInsert, cusId);
    	list<Account> tstAcc = [SELECT Id, Consolidated_Eligible_Employee_Count__c,Consolidated_Customer_Count__c,Consolidated_Overall_Participation__c
    				FROM Account WHERE Id IN:lstAcc];
    	for(Account a : tstAcc)
    	{
    		//System.assertEquals(empl_count, a.Consolidated_Eligible_Employee_Count__c);
    		//System.assertEquals(cust_count, a.Consolidated_Customer_Count__c);
    		//System.assertEquals(avg, a.Consolidated_Overall_Participation__c);
    	}
    	
    	
    }
    
    static testMethod void postiveRollupInsert()
    {
    	Decimal empl_count = 30;
    	Decimal cust_count = 20;
    	Double avg = (cust_count / empl_count) * 100; 
    	Util u = new Util();
    	Integer count = 5;
    	Boolean doInsert = true;
    	String prefix = 'Test Apex Account';
    	Id cusId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account' LIMIT 1].Id;
		Id locId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName='Locations' LIMIT 1].Id;
    	
    	list<Account> lstAcc = u.createAcc(prefix, count, !doInsert, cusId);
    	list<Account> affectedAcc = new list<Account>();
    	for(Account a : lstAcc)
    	{
    		a.Customer_Count__c = cust_count;
    		a.Eligibile_Employee_Count__c = empl_count;
    		affectedAcc.add(a);
    	}
    	insert affectedAcc;
    	affectedAcc = [SELECT Id, Consolidated_Eligible_Employee_Count__c, Consolidated_Customer_Count__c, Consolidated_Overall_Participation__c 
    					FROM Account WHERE Id IN:affectedAcc];
    	
    	for(Account a : affectedAcc)
    	{
    		System.assertEquals(empl_count, a.Consolidated_Eligible_Employee_Count__c);
    		System.assertEquals(cust_count, a.Consolidated_Customer_Count__c);
    		System.assertEquals(avg, a.Consolidated_Overall_Participation__c);
    	}
    	
    	
    }
    
    static testMethod void postiveRollupUpdate()
    {
    	Decimal empl_count = 30;
    	Decimal cust_count = 20;
    	Double avg = (cust_count / empl_count) * 100; 
    	Util u = new Util();
    	Integer count = 5;
    	Boolean doInsert = true;
    	String prefix = 'Test Apex Account';
    	Id cusId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account' LIMIT 1].Id;
		Id locId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName='Locations' LIMIT 1].Id;
    	
    	list<Account> lstAcc = u.createAcc(prefix, count, doInsert, cusId);
    	list<Account> affectedAcc = new list<Account>();
    	for(Account a : lstAcc)
    	{
    		a.Customer_Count__c = cust_count;
    		a.Eligibile_Employee_Count__c = empl_count;
    		affectedAcc.add(a);
    	}
    	update affectedAcc;
    	affectedAcc = [SELECT Id, Consolidated_Eligible_Employee_Count__c, Consolidated_Customer_Count__c, Consolidated_Overall_Participation__c 
    					FROM Account WHERE Id IN:affectedAcc];
    	
    	for(Account a : affectedAcc)
    	{
    		System.assertEquals(empl_count, a.Consolidated_Eligible_Employee_Count__c);
    		System.assertEquals(cust_count, a.Consolidated_Customer_Count__c);
    		System.assertEquals(avg, a.Consolidated_Overall_Participation__c);
    	}
    	
    	
    }
    
    static testMethod void overRollupInsert()
    {
    	Decimal empl_count = 1;
    	Decimal cust_count = 30;
    	Double avg = 999.99; 
    	Util u = new Util();
    	Integer count = 5;
    	Boolean doInsert = true;
    	String prefix = 'Test Apex Account';
    	Id cusId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account' LIMIT 1].Id;
		Id locId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName='Locations' LIMIT 1].Id;
    	
    	list<Account> lstAcc = u.createAcc(prefix, count, !doInsert, cusId);
    	list<Account> affectedAcc = new list<Account>();
    	for(Account a : lstAcc)
    	{
    		a.Customer_Count__c = cust_count;
    		a.Eligibile_Employee_Count__c = empl_count;
    		affectedAcc.add(a);
    	}
    	insert affectedAcc;
    	affectedAcc = [SELECT Id, Consolidated_Eligible_Employee_Count__c, Consolidated_Customer_Count__c, Consolidated_Overall_Participation__c 
    					FROM Account WHERE Id IN:affectedAcc];
    	
    	for(Account a : affectedAcc)
    	{
    		System.assertEquals(empl_count, a.Consolidated_Eligible_Employee_Count__c);
    		System.assertEquals(cust_count, a.Consolidated_Customer_Count__c);
    		System.assertEquals(avg, a.Consolidated_Overall_Participation__c);
    	}
    	
    	
    }
    
    static testMethod void childRollupUpdate()
    {
    	Decimal empl_count = 30;
    	Decimal cust_count = 20;
    	Double avg = ( (6*cust_count) / (6*empl_count) ) * 100; 
    	Util u = new Util();
    	Integer count = 5;
    	Boolean doInsert = true;
    	String prefix = 'Test Apex Account';
    	Id cusId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account' LIMIT 1].Id;
		Id locId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName='Locations' LIMIT 1].Id;
    	Account parnt = u.createOneAcc('Parent ' + prefix, doInsert, cusId);
    	parnt.Eligibile_Employee_Count__c = empl_count;
    	parnt.Customer_Count__c = cust_count;
    	update parnt;
    	
    	list<Account> lstAcc = u.createAcc(prefix, count, doInsert, cusId);
    	list<Account> affectedAcc = new list<Account>();
    	
    	for(Account a : lstAcc)
    	{
    		a.ParentId = parnt.Id;
    		a.Customer_Count__c = cust_count;
    		a.Eligibile_Employee_Count__c = empl_count;
    		affectedAcc.add(a);
    	}
    	update affectedAcc;
    	affectedAcc = [SELECT Id, Consolidated_Eligible_Employee_Count__c, Consolidated_Customer_Count__c, Consolidated_Overall_Participation__c 
    					FROM Account WHERE Id IN:affectedAcc];
    	
    	for(Account a : affectedAcc)
    	{
    		System.assertEquals(empl_count, a.Consolidated_Eligible_Employee_Count__c);
    		System.assertEquals(cust_count, a.Consolidated_Customer_Count__c);
    		System.assertEquals(avg, a.Consolidated_Overall_Participation__c);
    	}
    	Account p = [SELECT Id, Consolidated_Eligible_Employee_Count__c, Consolidated_Customer_Count__c FROM Account WHERE Id =:parnt.Id];
    	
    	System.assertEquals(6*empl_count,p.Consolidated_Eligible_Employee_Count__c);
    	System.assertEquals(6*cust_count,p.Consolidated_Customer_Count__c);
    	
    	
    }
    
    static testMethod void childRollupDelete()
    {
    	Decimal empl_count = 30;
    	Decimal cust_count = 20;
    	Double avg = ( (6*cust_count) / (6*empl_count) ) * 100; 
    	Util u = new Util();
    	Integer count = 5;
    	
    	Boolean doInsert = true;
    	String prefix = 'Test Apex Account';
    	Id cusId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'Customer_Account' LIMIT 1].Id;
		Id locId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName='Locations' LIMIT 1].Id;
    	Account parnt = u.createOneAcc('Parent ' + prefix, doInsert, cusId);
    	parnt.Eligibile_Employee_Count__c = empl_count;
    	parnt.Customer_Count__c = cust_count;
    	update parnt;
    	
    	list<Account> lstAcc = u.createAcc(prefix, count, doInsert, cusId);
    	list<Account> affectedAcc = new list<Account>();
    	
    	for(Account a : lstAcc)
    	{
    		a.ParentId = parnt.Id;
    		a.Customer_Count__c = cust_count;
    		a.Eligibile_Employee_Count__c = empl_count;
    		affectedAcc.add(a);
    	}
    	update affectedAcc;
    	delete affectedAcc[0];
    	affectedAcc = [SELECT Id, Consolidated_Eligible_Employee_Count__c, Consolidated_Customer_Count__c, Consolidated_Overall_Participation__c 
    					FROM Account WHERE Id IN:affectedAcc];
    	
    	for(Account a : affectedAcc)
    	{
    		System.assertEquals(empl_count, a.Consolidated_Eligible_Employee_Count__c);
    		System.assertEquals(cust_count, a.Consolidated_Customer_Count__c);
    		System.assertEquals(avg, a.Consolidated_Overall_Participation__c);
    	}
    	Account p = [SELECT Id, Consolidated_Eligible_Employee_Count__c, Consolidated_Customer_Count__c FROM Account WHERE Id =:parnt.Id];
    	
    	System.assertEquals(count*empl_count,p.Consolidated_Eligible_Employee_Count__c);
    	System.assertEquals(count*cust_count,p.Consolidated_Customer_Count__c);
    	
    	
    }
}