@isTest
public class CopayInformationHelperTester {

    @testSetup
    static void testData()
    {
        Util u = new Util();
        
        Account acct = u.createOneAcc('CoPay Files Test Account', true, Constants.ACCOUNT_CUSTOMER_ACCOUNT);
        
        Copay_Information__c copay = new Copay_Information__c();
        copay.Account__c = acct.Id;
        copay.Flex_Plan_Start_Month__c = 'January';
        copay.Flex_Plan_Start_Year__c = '2017';
        
        insert copay;
    }
    
    @isTest
    static void testInsertFileUpdateCopayRollup()
    {
        try {
	        Copay_Information__c copay = [SELECT Id, of_files__c FROM Copay_Information__c LIMIT 1];
	        
	        ContentVersion ctv = new ContentVersion();
	        ctv.Title = 'Test Content';
	        ctv.PathOnClient = 'Test.jpg';
	        ctv.VersionData = Blob.valueOf('Test Content');
	        ctv.IsMajorVersion = true;
	        insert ctv;
	        
	        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ctv.Id];
	        
	        ContentDocumentLink newFileShare = new ContentDocumentLink();
	        newFileShare.ContentDocumentId = testContent.ContentDocumentId;
	        newFileShare.LinkedEntityId = copay.Id;
	        newFileShare.ShareType = 'V';
	        
	        test.startTest();
	        insert newFileShare;
	        test.stopTest();
	        
	        copay = [SELECT Id, of_files__c FROM Copay_Information__c LIMIT 1];
	        system.assertEquals(1, copay.of_Files__c);
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }
    
    @isTest
    static void testDeleteFileUpdateCopayRollup()
    {
        try {
	        Copay_Information__c copay = [SELECT Id, of_files__c FROM Copay_Information__c LIMIT 1];
	        
	        ContentVersion ctv = new ContentVersion();
	        ctv.Title = 'Test Content';
	        ctv.PathOnClient = 'Test.jpg';
	        ctv.VersionData = Blob.valueOf('Test Content');
	        ctv.IsMajorVersion = true;
	        insert ctv;
	        
	        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: ctv.Id];
	        
	        ContentDocumentLink newFileShare = new ContentDocumentLink();
	        newFileShare.ContentDocumentId = testContent.ContentDocumentId;
	        newFileShare.LinkedEntityId = copay.Id;
	        newFileShare.ShareType = 'V';
	        
	        insert newFileShare;
	        
	        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id =: testContent.ContentDocumentId];
	        
	        test.startTest();
	        delete cd;
	        test.stopTest();
	        
	        copay = [SELECT Id, of_files__c FROM Copay_Information__c LIMIT 1];
	        system.assertEquals(null, copay.of_Files__c);
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }
    }
}