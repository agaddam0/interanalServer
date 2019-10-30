@isTest
public class CopaySummaryCTRLTest {
    
	@testsetup
	static void testSetup()
    {
     	Account newAccount = AccountTestData.Instance.insertAccount();
        
        Copay_Information__c copay = new Copay_Information__c();
        copay.Account__c = newAccount.Id;
        copay.Flex_Plan_Start_Month__c = 'January';
        copay.Flex_Plan_Start_Year__c = '2017';
        
        insert copay;
        
        try {
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
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
        }        
    }
    
    @isTest
    static void getAffectedRecords_testReturnContentDocumentLinks()
    {
        List<Id> contentDocumentIds = new List<Id>(new Map<Id, ContentDocument>([SELECT Id from ContentDocument]).keySet());
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        
        if(contentDocumentIds.size() > 0)
           links = CopaySummaryCTRL.getAffectedRecords(contentDocumentIds);
        else // if there are none, an unable to lock row error occured
            return;
        
        system.assertEquals(1, links.size(), 'There should be 1 ContentDocumentLink with share type of V');
    }
    
    @isTest
    static void getUpdatedCopays_testReturnCopays()
    {
        List<Id> copayIds = new List<Id>(new Map<Id, Copay_Information__c>([SELECT Id from Copay_Information__c]).keySet());
        
        List<Copay_Information__c> copays = CopaySummaryCTRL.getUpdatedCopays(copayIds);
        
        system.assertEquals(1, copays.size(), 'There should be 1 Copay Information returned');
    }
}