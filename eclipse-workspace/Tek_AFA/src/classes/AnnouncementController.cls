public class AnnouncementController {
    
    @AuraEnabled
    public static List<AnnouncementWrapper> getAnnouncement(String RecordTypeName)
    {
        List<AnnouncementWrapper> announcementWrappers = new List<AnnouncementWrapper>();
        List<Id> announcementIds = new List<Id>();
        
        Profile p = [Select Name from Profile where Id =: UserInfo.getProfileId()];
        
        List<Announcement__c> announcements = [SELECT  Id, 
                                           Announcement__c, 
                                           Headline__c,
                                           Link_1_Name__c,
                                           Link_1_URL__c,
                                           Link_2_Name__c,
                                           Link_2_URL__c,
                                           Link_3_Name__c,
                                           Link_3_URL__c,
                                           Link_4_Name__c,
                                           Link_4_URL__c,
                                           Link_5_Name__c,
                                           Link_5_URL__c,
                                           Status__c,
                                           Video_URL__c
                                   FROM Announcement__c
                                   WHERE Status__c = 'Active' AND RecordType.Name =: RecordTypeName
                                   AND Announcement_Visibility__c INCLUDES(:p.Name)];
        
        for(Announcement__c a : announcements)
        {
            announcementIds.add(a.Id);
        }        
        
        if(announcements.size() > 0)
        {
            system.debug('Announcements List: ' + announcements);
            
            List<ContentDocumentLink> thumbnailFiles = [SELECT LinkedEntityId,
                                                       ContentDocument.LatestPublishedVersionId
                                                       FROM ContentDocumentLink
                                                       WHERE LinkedEntityId IN: announcementIds
                                                       ORDER BY LinkedEntityId, ContentDocument.ContentModifiedDate DESC];
            
            for(Announcement__c announcement : announcements) 
            {
                String thumbnailURL = '';
                for(ContentDocumentLink link : thumbnailFiles)
                {                    
                    if(announcement.Id == link.LinkedEntityId)
                    {
                        // First match should be latest based on order from query
                        thumbnailURL = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + link.ContentDocument.LatestPublishedVersionId;
                        
                        system.debug('ThumbnailURL: ' + thumbnailURL);
                        break;
                    }
                }
                
                AnnouncementWrapper aw = new AnnouncementWrapper(announcement, thumbnailURL);
                announcementWrappers.add(aw);
            } 
            
            return announcementWrappers;
        }            
        
        return null;
    }
    
    public class AnnouncementWrapper 
    {
        @AuraEnabled
        Announcement__c Announcement 	{get;set;}
        @AuraEnabled
        String ThumbnailURL				{get;set;}
        
        public AnnouncementWrapper(Announcement__c a, String t)
        {
            Announcement = a;
            ThumbnailURL = t;
        }
    }
}