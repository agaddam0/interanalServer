public with sharing class OrderAdminController {
    public static String DEFAULT_THUMBNAIL_NAME_SUFFIX = '_Thumbnail'; 
    
    @AuraEnabled
    public static OrderAdminContext getOrderAdminDetails() {
        OrderAdminContext context = new OrderAdminContext();
        context.AllowTagCategoryAdmin = isSystemAdmin();

        return context;
    }
    
    @AuraEnabled
    public static TagsContext getTags() {
        TagsContext context = new TagsContext();
        
        context.Fields = getTagFields();
        context.Tags = getAllTags(context.Fields);
        
        return context;
    }
    
    @AuraEnabled
    public static Id addNewTag(Tag__c newTag) {
        insert newTag;
        
        return newTag.Id;
    }
    
    @AuraEnabled
    public static void updateTag(Tag__c tagToUpdate) {
        update tagToUpdate;
    }
    
    @AuraEnabled
    public static List<Tag_Category__c> getAllTagCategories() {
        return
        [SELECT Id,
                Name
           FROM Tag_Category__c
          ORDER BY Display_Order__c, Name];
    }
    
    @AuraEnabled
    public static void addMarketingMaterialsToTag(Id tagId, List<Marketing_Material__c> marketingMaterials) {
        List<Marketing_Material_Tag__c> marketingMaterialTags = new List<Marketing_Material_Tag__c>();
        
        for (Marketing_Material__c marketingMaterial : marketingMaterials) {
            Marketing_Material_Tag__c mmTag = new Marketing_Material_Tag__c(
                Tag__c = tagId,
                Marketing_Material__c = marketingMaterial.Id
            );
            
            marketingMaterialTags.add(mmTag);
        }
        
        if (marketingMaterialTags.size() > 0) {
            insert marketingMaterialTags;
        }
    }
    
    @AuraEnabled
    public static void deleteMarketingMaterialTag(Id marketingMaterialTagIdToDelete) {
        delete new Marketing_Material_Tag__c(Id = marketingMaterialTagIdToDelete);
    }
    
    @AuraEnabled
    public static Id addNewMarketingMaterial(Marketing_Material__c newMarketingMaterial) {
        system.debug('  newMarketingMaterial: ' + newMarketingMaterial);
        
        insert newMarketingMaterial;
        
        return newMarketingMaterial.Id;
    }
    
    @AuraEnabled
    public static void updateMarketingMaterial(Marketing_Material__c marketingMaterialToUpdate) {
        update marketingMaterialToUpdate;
    }
    
    @AuraEnabled
    public static void addTagsToMarketingMaterial(Id marketingMaterialId, List<Tag__c> tags) {
        List<Marketing_Material_Tag__c> marketingMaterialTags = new List<Marketing_Material_Tag__c>();
        
        for (Tag__c tag : tags) {
            Marketing_Material_Tag__c mmTag = new Marketing_Material_Tag__c(
                Tag__c = tag.Id,
                Marketing_Material__c = marketingMaterialId
            );
            
            marketingMaterialTags.add(mmTag);
        }
        
        if (marketingMaterialTags.size() > 0) {
            insert marketingMaterialTags;
        }
    }
    
    @AuraEnabled
    public static MarketingMaterialDetails getMarketingMaterialDetails(Id marketingMaterialId) {
        MarketingMaterialDetails details = new MarketingMaterialDetails();
        details.IsRecordDeletable = Schema.sObjectType.Marketing_Material__c.isDeletable();
        
        if (details.IsRecordDeletable) {
	        Integer marketingMaterialHasOrders =
	        [SELECT Count()
	           FROM Order_Line_Item__c
	          WHERE Marketing_Material__c = :marketingMaterialId
	          LIMIT 1];
	        
	        details.IsRecordDeletable = marketingMaterialHasOrders == 0;
        }
        
        Marketing_Material__c mm = getMarketingMaterialById(marketingMaterialId);
        
        details.ThumbnailURL = mm.Thumbnail_URL__c;
        details.DownloadingAllowed = String.isNotBlank(mm.Processing_Type__c) &&
                                     (mm.Processing_Type__c == 'Download Only' ||
                                      mm.Processing_Type__c == 'AFPress & Download');


        details.DownloadURL = mm.Download_URL__c;
        
        ContentDocument thumbNailDoc = getThumbnail(marketingMaterialId);
        List<ContentDocument> documentDocs = getMarketingMaterialDownloadDocs(marketingMaterialId);
        
        if (thumbNailDoc != null) {
            details.ThumbnailContentDocumentId = thumbNailDoc.Id;
        }
        
        for (ContentDocument doc : documentDocs) {
            details.DownloadContentDocumentIds.add(doc.Id);
        }

        return details;
    }
    
    @AuraEnabled
    public static Marketing_Material__c cloneMarketingMaterial(Id originalMarketingMaterialId) {
        string soql = util.getFields('Marketing_Material__c');
        soql += ' FROM Marketing_Material__c';
        soql += ' WHERE Id = \'' + originalMarketingMaterialId + '\'';
        soql += ' LIMIT 1';
        
        Marketing_Material__c originalMaterial = (Marketing_Material__c)database.query(soql);
        Marketing_Material__c clonedMaterial = originalMaterial.clone(false, false, false);
        clonedMaterial.AFPress_Unique_Id__c = '';
        clonedMaterial.Material_Number__c = '';
        
        return clonedMaterial;        
    }
    
    @AuraEnabled
    public static void deleteMarketingMaterial(Id marketingMaterialToDeleteId) {
        delete new Marketing_Material__c(Id = marketingMaterialToDeleteId);
    }
    
    @AuraEnabled
    public static ThumbnailUploadedContext onMarketingMaterialThumbnailUploaded(Id marketingMaterialId, Id thumbnailContentDocumentId) {
        system.debug('    marketingMaterialId: ' + marketingMaterialId);
        system.debug('    thumbnailContentDocumentId: ' + thumbnailContentDocumentId);
        
        Marketing_Material__c mm = getMarketingMaterialById(marketingMaterialId);
        ContentDocument latestThumbNail = getContentDocumentById(thumbnailContentDocumentId);
        String thumbNailTitle = buildThumbnailTitle(mm);
        
        system.debug('    latestThumbNail: ' + latestThumbNail);
        
        ContentDocument existingThumbNail = getThumbnail(marketingMaterialId);
        
        String latestThumbNailURL = buildThumbNailURL(latestThumbNail);
        String latestThumbNailDescription = 'Thumbnail for Marketing Material ' + mm.Material_Number__c + ' whose id is ' + mm.Id;
        
        system.debug('    existingThumbNail: ' + existingThumbNail);
        
        // First Thumbnail Uploaded. Standardize it.
        if (existingThumbNail == null) {
            ContentDocument firstThumbNail = new ContentDocument(Id = thumbnailContentDocumentId);
            firstThumbNail.Title = thumbNailTitle;
            firstThumbNail.Description = latestThumbNailDescription;
            
            update firstThumbNail;
        }
        else {
	        // Another Thumbnail uploaded so link it to the existing standard thumbnail
	        
	        ContentVersion newThumbnailVersion = new ContentVersion(
	            ContentDocumentId = existingThumbNail.Id,
	            VersionData = latestThumbNail.LatestPublishedVersion.VersionData,
	            Title = thumbNailTitle,
	            PathOnClient = latestThumbNail.LatestPublishedVersion.PathOnClient,
	            Description = latestThumbNailDescription
	        );
        
	        insert newThumbnailVersion;
	        delete latestThumbNail;
	        
	        existingThumbNail = getContentDocumentById(existingThumbNail.Id);
	        
	        latestThumbNailURL = buildThumbNailURL(existingThumbNail);
        }
        
        Marketing_Material__c mmToUpdate = new Marketing_Material__c(Id = marketingMaterialId);
        mmToUpdate.Thumbnail_URL__c = latestThumbNailURL;
        
        update mmToUpdate;
        
        ThumbnailUploadedContext context = new ThumbnailUploadedContext();
        context.ThumbnailURL = latestThumbNailURL;
        
        return context;
    }
    
    @AuraEnabled
    public static DownloadableUploadedContext onMarketingMaterialDownloadableUploaded(Id marketingMaterialId, Id downloadContentDocumentId) {
        system.debug('    marketingMaterialId: ' + marketingMaterialId);
        system.debug('    downloadContentDocumentId: ' + downloadContentDocumentId);
        
        Marketing_Material__c mm = getMarketingMaterialById(marketingMaterialId);
        ContentDocument latestDownloadDoc = getContentDocumentById(downloadContentDocumentId);
        
        // Standardize attributes
        ContentDocument downloadableDoc = new ContentDocument(Id = downloadContentDocumentId);
        downloadableDoc.Title = 'Marketing Material ' + mm.Material_Number__c + ' Download';
        downloadableDoc.Description = 'Download for Marketing Material ' + mm.Material_Number__c + ' whose id is ' + mm.Id;
        
        update downloadableDoc;
        
        Marketing_Material__c mmToUpdate = new Marketing_Material__c(Id = marketingMaterialId);
        mmToUpdate.Download_URL__c = buildDownloadURL(latestDownloadDoc);
        
        update mmToUpdate;
        
        
        DownloadableUploadedContext context = new DownloadableUploadedContext();
        context.DownloadURL = mmToUpdate.Download_URL__c;
        
        return context;
    }
    
     @AuraEnabled
    public static Id addNewAnnouncement(Announcement__c newAnnouncement) {
        insert newAnnouncement;
        
        return newAnnouncement.Id;
    }
    
    @AuraEnabled
    public static void updateAnnouncement(Announcement__c announcementToUpdate) {
        update announcementToUpdate;
    }
    
    @AuraEnabled
    public static AnnouncementDetails getAnnouncementDetails(Id announcementId) {
        
        AnnouncementDetails details = new AnnouncementDetails();
        
        details.IsRecordDeletable = Schema.sObjectType.Announcement__c.isDeletable();
        
        ContentDocument thumbNailDoc = getThumbnail(announcementId);
        
        if (thumbNailDoc != null) {
            details.ThumbnailURL = buildThumbnailURL(thumbNailDoc);
            details.ThumbnailContentDocumentId = thumbNailDoc.Id;
        }

        return details;
    }
    
    @AuraEnabled
    public static ThumbnailUploadedContext onAnnouncementThumbnailUploaded(Id announcementId, Id thumbnailContentDocumentId) {
        system.debug('    announcementId: ' + announcementId);
        system.debug('    thumbnailContentDocumentId: ' + thumbnailContentDocumentId);
        
        Announcement__c ann = getAnnouncementById(announcementId);
        ContentDocument latestThumbNail = getContentDocumentById(thumbnailContentDocumentId);
        String thumbNailTitle = buildThumbnailTitle(ann);
        
        system.debug('    latestThumbNail: ' + latestThumbNail);
        
        ContentDocument existingThumbNail = getThumbnail(announcementId);
        
        String latestThumbNailURL = buildThumbNailURL(latestThumbNail);
        String latestThumbNailDescription = 'Thumbnail for Announcement ' + ann.Name + ' whose id is ' + ann.Id;
        
        system.debug('    existingThumbNail: ' + existingThumbNail);
        
        // First Thumbnail Uploaded. Standardize it.
        if (existingThumbNail == null) {
            ContentDocument firstThumbNail = new ContentDocument(Id = thumbnailContentDocumentId);
            firstThumbNail.Title = thumbNailTitle;
            firstThumbNail.Description = latestThumbNailDescription;
            
            update firstThumbNail;
        }
        else {
	        // Another Thumbnail uploaded so link it to the existing standard thumbnail
	        
	        ContentVersion newThumbnailVersion = new ContentVersion(
	            ContentDocumentId = existingThumbNail.Id,
	            VersionData = latestThumbNail.LatestPublishedVersion.VersionData,
	            Title = thumbNailTitle,
	            PathOnClient = latestThumbNail.LatestPublishedVersion.PathOnClient,
	            Description = latestThumbNailDescription
	        );
        
	        insert newThumbnailVersion;
	        delete latestThumbNail;
	        
	        existingThumbNail = getContentDocumentById(existingThumbNail.Id);
	        
	        latestThumbNailURL = buildThumbNailURL(existingThumbNail);
        }
        
        ThumbnailUploadedContext context = new ThumbnailUploadedContext();
        context.ThumbnailURL = latestThumbNailURL;
        
        return context;
    }
    
    @TestVisible
    private static Boolean isSystemAdmin() {
        Profile currentUserProfile =
        [SELECT Id,
                Name
           FROM Profile
          WHERE Id = :UserInfo.getProfileId()];
        
        return currentUserProfile.Name == 'System Administrator';
    }
    
    private static List<Field> getTagFields() {
        List<Field> fields = new List<Field>();
        List<Schema.FieldSetMember> tagFieldSetMembers =
            SObjectType.Tag__c.FieldSets.Default_List_View.getFields();
        
        for (Schema.FieldSetMember fsm : tagFieldSetMembers) {
            fields.add(new Field(fsm));
        }
        
        return fields;
    }
    
    private static List<Tag__c> getAllTags(List<Field> fields) {
        List<String> selectFields = new List<String>();
        
        for (Field f : fields) {
            selectFields.add(f.APIName);
        }
        
        String soql = 'SELECT ' + String.join(selectFields, ',') +
                      '  FROM Tag__c' +
                      '  ORDER BY Name';
        
        return Database.query(soql);
    }
    
    private static ContentDocument getThumbnail(Id objectId) {
        String likeTitle = '%' + DEFAULT_THUMBNAIL_NAME_SUFFIX + '%';
        
        List<ContentDocumentLink> thumbnailLinks =
        [SELECT Id,
                ContentDocument.Id,
                ContentDocument.Title,
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.LatestPublishedVersion.ContentUrl,
                ContentDocument.LatestPublishedVersion.PathOnClient,
                ContentDocument.Description
           FROM ContentDocumentLink
          WHERE LinkedEntityId = :objectId
            AND ContentDocument.Title like :likeTitle
        ORDER BY ContentDocument.ContentModifiedDate DESC];
        
        if (thumbnailLinks.size() > 0) {
            return thumbnailLinks[0].ContentDocument;
        }

        return null;
    }
    
    private static List<ContentDocument> getMarketingMaterialDownloadDocs(Id marketingMaterialId) {
        List<ContentDocument> downloadDocs = new List<ContentDocument>();
        
        List<ContentDocumentLink> downloadLinks =
        [SELECT Id,
                ContentDocument.Id,
                ContentDocument.Title,
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.LatestPublishedVersion.ContentUrl,
                ContentDocument.LatestPublishedVersion.PathOnClient,
                ContentDocument.Description
           FROM ContentDocumentLink
          WHERE LinkedEntityId = :marketingMaterialId
            AND ContentDocument.Title like '%Download%'];
        
        for (ContentDocumentLink link : downloadLinks) {
            downloadDocs.add(link.ContentDocument);
        }

        return downloadDocs;
    }
    
    private static ContentDocument getContentDocumentById(Id contentDocumentId) {
        return
        [SELECT Id,
                Title,
                LatestPublishedVersionId,
                LatestPublishedVersion.ContentUrl,
                LatestPublishedVersion.VersionData,
                ContentDocument.LatestPublishedVersion.PathOnClient,
                Description
           FROM ContentDocument
          WHERE Id = :contentDocumentId];
    }
    
    private static String buildThumbNailURL(ContentDocument thumbNail) {
        String baseURL = System.Url.getSalesforceBaseURL().toExternalForm();
        String documentDownloadPath = '/sfc/servlet.shepherd/version/download/' + thumbNail.LatestPublishedVersionId;
        
        return baseURL + documentDownloadPath;
    }
    
    private static String buildThumbnailTitle(Marketing_Material__c marketingMaterial) {
        return 'Marketing Material ' + marketingMaterial.Material_Number__c + DEFAULT_THUMBNAIL_NAME_SUFFIX;
    }
    
    private static String buildThumbnailTitle(Announcement__c announcement) {
        return 'Announcement ' + announcement.Name + DEFAULT_THUMBNAIL_NAME_SUFFIX;
    }
    
    private static String buildDownloadURL(ContentDocument latestDownloadDoc) {
        String baseURL = System.Url.getSalesforceBaseURL().toExternalForm();
        String documentDownloadPath = '/sfc/servlet.shepherd/document/download/' + latestDownloadDoc.Id;
        
        return baseURL + documentDownloadPath;
    }
    
    private static Announcement__c getAnnouncementById(Id announcementId) {
        return 
            [SELECT Id,
                    Name,
                    Headline__c
            FROM Announcement__c
            WHERE Id =: announcementId];
    }
    
    private static Marketing_Material__c getMarketingMaterialById(Id marketingMaterialId) {
        return
        [SELECT Id,
                Name,
                Material_Number__c,
                Processing_Type__c,
                Thumbnail_URL__c,
                Download_URL__c
           FROM Marketing_Material__c
          WHERE Id = :marketingMaterialId];
    }
    
    public class OrderAdminContext {
        @AuraEnabled
        public Boolean AllowTagCategoryAdmin { get; set; }

        @AuraEnabled
        public Boolean EditMarketingMaterialAllowed { get; set; }
        
        @AuraEnabled
        public String AllTagCategoriesListViewId { get; set; }

        public OrderAdminContext() {
            AllowTagCategoryAdmin = false;
            EditMarketingMaterialAllowed = Schema.sObjectType.Marketing_Material__c.isUpdateable();

            List<ListView> allTagCategoryListViews =
            [SELECT Id
               FROM ListView
              WHERE SobjectType = 'Tag_Category__c'
                AND DeveloperName = 'All'];

            if (allTagCategoryListViews.isEmpty() == false) {
                AllTagCategoriesListViewId = allTagCategoryListViews[0].Id;
            }
        }
    }
    
    public class TagsContext {
        @AuraEnabled
        public List<Tag__c> Tags { get; set; }
        
        @AuraEnabled
        public List<Field> Fields { get; set; }
        
        public TagsContext() {
            Tags = new List<Tag__c>();
            Fields = new List<Field>();
        }
    }
    
    public class MarketingMaterialDetails {
        @AuraEnabled
        public Boolean IsRecordDeletable { get; set; }
        
        @AuraEnabled
        public String ThumbnailURL { get; set; }
        
        @AuraEnabled
        public Id ThumbnailContentDocumentId { get; set; }
        
        @AuraEnabled
        public Boolean DownloadingAllowed { get; set; }
        
        @AuraEnabled
        public String DownloadURL { get; set; }
        
        @AuraEnabled
        public List<String> DownloadContentDocumentIds { get; set; }
        
        public MarketingMaterialDetails() {
            IsRecordDeletable = false;
            DownloadingAllowed = false;
            DownloadContentDocumentIds = new List<String>();
        }
    }
    
    public class AnnouncementDetails {
        @AuraEnabled
        public Boolean IsRecordDeletable { get; set; }
        
        @AuraEnabled
        public String ThumbnailURL { get; set; }
        
        @AuraEnabled
        public String ThumbnailContentDocumentId { get; set; }
        
        public AnnouncementDetails() {
            IsRecordDeletable = false;
        }
    }
    
    public class ThumbnailUploadedContext {
        @AuraEnabled
        public String ThumbnailURL { get; set; }
        
        public ThumbnailUploadedContext() {
            ThumbnailURL = '';
        }
    }

    public class DownloadableUploadedContext {
        @AuraEnabled
        public String DownloadURL { get; set; }
        
        public DownloadableUploadedContext() {
            DownloadURL = '';
        }
    }
}