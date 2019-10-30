@isTest
public class AnnouncementControllerTester {
    private static Boolean UnableToLockRowErrorOccurred = false;

    static void testSetup()
    {
        List<Announcement__c> announcements = new List<Announcement__c>();
        
        for(integer i = 0; i < 2; i++)
        { 
            Announcement__c a = new Announcement__c();
            a.Headline__c = 'Test Announcement';
            a.Status__c = 'Active';
            a.Announcement_Visibility__c = 'System Administrator';
            a.RecordTypeId = Schema.SObjectType.Announcement__c.getRecordTypeInfosByName().get('Marketing Material').getRecordTypeId();
            announcements.add(a);
        }
        
        insert announcements;
        
        List<ContentVersion> versions = new List<ContentVersion>();
        
        for(Announcement__c a : announcements)
        {
            ContentVersion ctv = new ContentVersion();
            ctv.Title = 'Test Content';
            ctv.PathOnClient = 'Test.jpg';
            ctv.VersionData = Blob.valueOf('Test Content ' + a.Id);
            ctv.IsMajorVersion = true;
            ctv.FirstPublishLocationId = a.Id;
            
            versions.add(ctv);
        }
        
        try
        {
            insert versions;
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
            else {
                UnableToLockRowErrorOccurred = true;
            }
        }        
    }
    
    static testmethod void getAnnouncementTestpositive()
    {
        // Luke: Invoke the testSetup here so it's easier to detect if an Unable to Lock Row error occurred.
        testSetup();
        
        if (UnableToLockRowErrorOccurred) {
            return;
        }
        
        User sysAdminUser = Util.getAnActiveSystemAdministrator();
        
        system.runAs(sysAdminUser) {
	        test.startTest();
	        
	        List<AnnouncementController.AnnouncementWrapper> wrapperClass = AnnouncementController.getAnnouncement('Marketing Material');
	        
	        test.stopTest();
	        
	        system.assertNotEquals(null, wrapperClass);
        }
    }
    
    static testMethod void getAnnouncementTestnegative()
    {
        // Luke: Invoke the testSetup here so it's easier to detect if an Unable to Lock Row error occurred.
        testSetup();
        
        if (UnableToLockRowErrorOccurred) {
            return;
        }
        
        test.startTest();
        
        List<AnnouncementController.AnnouncementWrapper> wrapperClass = AnnouncementController.getAnnouncement('Home Page');
        
        test.stopTest();
        
        system.assertEquals(null, wrapperClass, 'should be null');
    }
}