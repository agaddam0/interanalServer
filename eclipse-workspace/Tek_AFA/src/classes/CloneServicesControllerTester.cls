@isTest
public class CloneServicesControllerTester {
	@testSetup
    static void TestData()
    {
        Util u = new Util();
        Account parentAccount = u.createOneAcc('Test Parent Account', true, Constants.ACCOUNT_CUSTOMER_ACCOUNT);
        Account childAccount = u.createOneAcc('Test Child Account', false, Constants.ACCOUNT_CUSTOMER_ACCOUNT);
        childAccount.ParentId = parentAccount.Id;
        insert childAccount;
        
        Id pricebookId = Test.getStandardPricebookId();
		
		list<Product2> p = u.createProd(5, 'Test', true);
		for(Product2 p2: p)
		{
			PricebookEntry pbe = u.createPBEntry(true, pricebookId, p2.Id, 100);
		}
        Asset parentAsset = u.createOneAsset(false, parentAccount.Id, p[0].Id, 'Test Asset');
        parentAsset.RecordTypeId = Constants.ASSET_EXPENSE_MANAGEMENT_SERVICES;
        insert parentAsset;
    }
    
    static testMethod void CloneServicesControllerTest()
    {
        // Testing both methods here as the conditions are correct for the cloned services removal
         
        Account parent = [SELECT Id FROM Account where Name = 'Test Parent Account'];
        
        CloneServicesController.updateCloneFlag(parent.Id);
        
        List<Asset> assets = [SELECT Id FROM Asset WHERE AccountId IN (SELECT Id FROM Account WHERE Name = 'Test Child Account')];
        
        system.assertEquals(1, assets.size());
        
        // Remove cloned services // 
        
        CloneServicesController.removeClonedServices(parent.Id);
        
        assets = [SELECT Id FROM Asset WHERE AccountId IN (SELECT Id FROM Account WHERE Name = 'Test Child Account')];
        
        system.assertEquals(0, assets.size());
    }
}