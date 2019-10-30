@isTest
public with sharing class OrderAdminControllerTest {

    @isTest
    static void getOrderAdminDetails_invoke_expectAllowTagCategoryAdminSetTest() {
        Boolean isSystemAdmin = OrderAdminController.isSystemAdmin();
        
        OrderAdminController.OrderAdminContext adminContext =
                OrderAdminController.getOrderAdminDetails();

        system.assert(adminContext.AllowTagCategoryAdmin != null, 'The Allow Tag Category Admin is null when it should not be.');
        system.assertEquals(isSystemAdmin, adminContext.AllowTagCategoryAdmin, 'The Allow Tag Category Admin was not the expected value.');
    }
    
    @isTest
    static void getAllTagCategories_noTagCategories_expectNoTagCategoriesReturnedTest() {
        List<Tag_Category__c> allTagCategories = OrderAdminController.getAllTagCategories();
        
        system.assert(allTagCategories != null, 'The tag categories returned is null.');
        system.assert(allTagCategories.isEmpty(), 'There should be no tag categories returned.');
    }

    @isTest
    static void getAllTagCategories_oneTagCategory_expectOneTagCategoryReturnedTest() {
        Tag_Category__c someTagCategory = TagCategoryTestData.Instance.insertTagCategory();
        List<Tag_Category__c> allTagCategories = OrderAdminController.getAllTagCategories();
        
        system.assert(allTagCategories != null, 'The tag categories returned is null.');
        system.assertEquals(1, allTagCategories.size(), 'There should be one tag category returned.');
        system.assertEquals(someTagCategory.Id, allTagCategories[0].Id, 'The expected tag category was not returned.');
    }
    
    @isTest
    static void getTags_noTags_expectNoTagsReturnedTest() {
        OrderAdminController.TagsContext tagsContext = OrderAdminController.getTags();
        
        assertTagsContextHasFields(tagsContext);
        assertNoTags(tagsContext);
    }
    
    @isTest
    static void getTags_oneTag_expectOneTagReturnedTest() {
        Tag__c someTag = TagTestData.Instance.insertTag();
        
        OrderAdminController.TagsContext tagsContext = OrderAdminController.getTags();
        
        assertTagsContextHasTag(tagsContext, someTag);
    }
    
    @isTest
    static void addNewTag_newTagSupplied_expectNewTagInsertedTest() {
        Tag__c tagToInsert = TagTestData.Instance.create();

        system.assert(tagToInsert.Id == null, 'The tag was inserted.');

        Id newTagId = OrderAdminController.addNewTag(tagToInsert);
        
        system.assert(newTagId != null, 'The new tag was not inserted.');
    }
    
    @isTest
    static void updateTag_tagToUpdateSupplied_expectTagUpdatedTest() {
        Tag__c tagToUpdate = TagTestData.Instance.insertTag();

        tagToUpdate.Name += ' Updated';        

        OrderAdminController.updateTag(tagToUpdate);
        
        Tag__c tagToUpdateQueried = getTagById(tagToUpdate.Id);
        
        system.assertEquals(tagToUpdate.Name, tagToUpdateQueried.Name, 'The tag\'s name was not updated.');
    }
    
    @isTest
    static void addNewMarketingMaterial_newMarketingMaterialSupplied_expectMarketingMaterialInsertedTest() {
        Marketing_Material__c marketingMaterialToAdd = MarketingMaterialTestData.Instance.create();
        
        system.assert(marketingMaterialToAdd.Id == null, 'The marketing material should not be inserted.');
        
        OrderAdminController.addNewMarketingMaterial(marketingMaterialToAdd);
        
        system.assert(marketingMaterialToAdd.Id != null, 'The marketing material was inserted.');
    }
    
    @isTest
    static void updateMarketingMaterial_marketingMaterialUpdated_expectMarketingMaterialUpdatedTest() {
        Marketing_Material__c marketingMaterialToUpdate = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        marketingMaterialToUpdate.Title__c += ' Updated';
        
        OrderAdminController.updateMarketingMaterial(marketingMaterialToUpdate);
        
        Marketing_Material__c marketingMaterialQueried = getMarketingMaterialById(marketingMaterialToUpdate.Id);
        
        system.assertEquals(marketingMaterialToUpdate.Title__c, marketingMaterialQueried.Title__c, 'The title was not updated.');
    }
    
    @isTest
    static void deleteMarketingMaterial_marketingMaterialToDeleteSupplied_expectMarketingMaterialDeletedTest() {
        Marketing_Material__c marketingMaterialToDelete = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        OrderAdminController.deleteMarketingMaterial(marketingMaterialToDelete.Id);
        
        Marketing_Material__c marketingMaterialQueried = getMarketingMaterialById(marketingMaterialToDelete.Id);
        
        system.assertEquals(null, marketingMaterialQueried, 'The marketing material was not deleted.');
    }
    
    @isTest
    static void addMarketingMaterialsToTag_oneTagWithTwoMarketingMaterials_expectTwoMarketingMaterialTagsCreatedTest() {
        Marketing_Material__c mm1 = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        Marketing_Material__c mm2 = MarketingMaterialTestData.Instance.withMaterialNumber(mm1.Material_Number__c + ' 11').insertMarketingMaterial();
        Tag__c tag = TagTestData.Instance.insertTag();
        
        OrderAdminController.addMarketingMaterialsToTag(tag.Id, new List<Marketing_Material__c>{ mm1, mm2 });
        
        List<Marketing_Material_Tag__c> tagMarketingMaterials = getMarketingMaterialTagsByTagId(tag.Id);
        
        system.assert(tagMarketingMaterials != null, 'The tag marketing materials is null.');
        system.assertEquals(2, tagMarketingMaterials.size(), 'There should be two tag marketing materials.');
    }
    
    @isTest
    static void deleteMarketingMaterialTag_oneMarketingMaterialTagToDeleteGiven_expectMarketingMaterialDeletedTest() {
        Marketing_Material__c mm1 = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        Marketing_Material__c mm2 = MarketingMaterialTestData.Instance.withMaterialNumber(mm1.Material_Number__c + ' 11').insertMarketingMaterial();
        Tag__c tag = TagTestData.Instance.insertTag();
        
        OrderAdminController.addMarketingMaterialsToTag(tag.Id, new List<Marketing_Material__c>{ mm1, mm2 });
        
        List<Marketing_Material_Tag__c> tagMarketingMaterials = getMarketingMaterialTagsByTagId(tag.Id);
        
        system.assert(tagMarketingMaterials != null, 'The tag marketing materials is null.');
        system.assertEquals(2, tagMarketingMaterials.size(), 'There should be two tag marketing materials.');
        
        OrderAdminController.deleteMarketingMaterialTag(tagMarketingMaterials[0].Id);
        
        tagMarketingMaterials = getMarketingMaterialTagsByTagId(tag.Id);
        system.assertEquals(1, tagMarketingMaterials.size(), 'There tag marketing material was not deleted.');
    }
    
    @isTest
    static void addTagsToMarketingMaterial_twoTagsWithOneMarketingMaterial_expectTwoMarketingMaterialTagsCreatedTest() {
        Marketing_Material__c mm = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        Tag__c tag1 = TagTestData.Instance.insertTag();
        Tag__c tag2 = TagTestData.Instance.withName(tag1.Name + ' 2').insertTag();
        
        OrderAdminController.addTagsToMarketingMaterial(mm.Id, new List<Tag__c>{ tag1, tag2 });
        
        List<Marketing_Material_Tag__c> marketingMaterialTags = getMarketingMaterialTagsByMarketingMaterialId(mm.Id);
        
        system.assert(marketingMaterialTags != null, 'The tag marketing materials is null.');
        system.assertEquals(2, marketingMaterialTags.size(), 'There should be two marketing material tags.');
    }
    
    @isTest
    static void getMarketingMaterialDetails_marketingMaterialDeletableWithoutFiles_expectIsDeleteableAndNoThumbnailOrDownloadInfoTest() {
        Marketing_Material__c mm = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        User sysAdmin = [SELECT Id, Name FROM User Where Profile.Name = 'System Administrator' AND IsActive = true limit 1];
        OrderAdminController.MarketingMaterialDetails details;
        
        // Run as admin to guarantee that user has permission to delete marketing material.
        system.runAs(sysAdmin) {
            details = OrderAdminController.getMarketingMaterialDetails(mm.Id);
        }
        
        system.assert(details != null, 'The details is null.');
        system.assertEquals(true, details.IsRecordDeletable, 'The marketing material should be deletable.');
        system.assert(String.isBlank(details.ThumbnailURL), 'There should be no thumbnail url.');
        system.assert(String.isBlank(details.DownloadURL), 'There should be no download url.');
        system.assert(String.isBlank(details.ThumbnailContentDocumentId), 'There should be no thumbnail content document id.');
        system.assert(details.DownloadContentDocumentIds.isEmpty(), 'There should be no download content document ids');
    }
    
    @isTest
    static void getMarketingMaterialDetails_marketingMaterialHasThumbnailAndDownloadableDoc_expectThumbnailAndDownloadableDocInfoTest() {
        Marketing_Material__c mm = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        
        ContentDocument thumbnailDocument = insertThumbnail(mm.Id);
        ContentDocument downloadableDoc = insertMarketingMaterialDownloadableDoc(mm.Id);
        
        // If an Unable To Lock Row error occurred, the document is null.
        if (thumbnailDocument == null ||
            downloadableDoc == null) {
            return;
        }
        
        OrderAdminController.onMarketingMaterialThumbnailUploaded(mm.Id, thumbnailDocument.Id);
        OrderAdminController.onMarketingMaterialDownloadableUploaded(mm.Id, downloadableDoc.Id);
        
        OrderAdminController.MarketingMaterialDetails details =
                OrderAdminController.getMarketingMaterialDetails(mm.Id);
                
        system.assert(String.isNotBlank(details.ThumbnailURL), 'The thumbnail url should not be blank.');
        system.assert(String.isNotBlank(details.DownloadURL), 'The download url should not be blank.');
        system.assert(String.isNotBlank(details.ThumbnailContentDocumentId), 'The thumbnail content document id should not be blank.');
        system.assertEquals(1, details.DownloadContentDocumentIds.size(), 'There should be 1 download content document id.');
    }
    
    @isTest
    static void getMarketingMaterialDetails_downloadOnlyProcessingType_expectDownloadingAllowedIsTrueTest() {
        Marketing_Material__c downloadOnlyMM = MarketingMaterialTestData.Instance.withProcessingType('Download Only').insertMarketingMaterial();
        
        OrderAdminController.MarketingMaterialDetails details =
                OrderAdminController.getMarketingMaterialDetails(downloadOnlyMM.Id);

        system.assertEquals(true, details.DownloadingAllowed, 'Downloading should be allowed.');
    }
    
    @isTest
    static void onMarketingMaterialThumbnailUploaded_existingThumbnailUploadedAndNewThumbnailUploaded_expectNewThumbnailContentDocumentDeletedAndVersionedUnderExistingOneTest() {
        Marketing_Material__c mm = MarketingMaterialTestData.Instance.insertMarketingMaterial();
        ContentDocument thumbnailDocument = insertThumbnail(mm.Id);
        
        // Jessica: if the thumbnailDocument doesn't exist, it's probably because there was a "Unable To Lock Row Error"
        // so continue on.
        if(thumbnailDocument == null || thumbnailDocument.Id == null) { return; }
        
        OrderAdminController.onMarketingMaterialThumbnailUploaded(mm.Id, thumbnailDocument.Id);
        
        ContentDocument newThumbnailDocument = insertThumbnail(mm.Id, 'Some awesome thumbnail 2', 'Some Awesome 2', 'AwesomeThumbnail2.png');
        
        // Jessica: if the newThumbnailDocument doesn't exist, it's probably because there was a "Unable To Lock Row Error"
        // so continue on.
        if(newThumbnailDocument == null || newThumbnailDocument.Id == null) { return; }
        
        OrderAdminController.onMarketingMaterialThumbnailUploaded(mm.Id, newThumbnailDocument.Id);
        Id marketingMaterialId = mm.Id;
        
        List<ContentDocumentLink> thumbnailLinks =
        [SELECT Id,
                ContentDocumentId
           FROM ContentDocumentLink
          WHERE LinkedEntityId = :marketingMaterialId];

        system.assertEquals(1, thumbnailLinks.size(), 'There should be only one thumbnail link.');
        
        List<ContentVersion> thumbnailVersions =
        [SELECT Id
           FROM ContentVersion
          WHERE ContentDocumentId = :thumbnailLinks[0].ContentDocumentId];

        system.assertEquals(2, thumbnailVersions.size(), 'There should be 2 thumbnail versions');
    }
    
    @isTest
    static void addNewAnnouncement_newAnnouncementSupplied_expectNewAnnouncementInsertedTest() {
        Announcement__c announcementToInsert = AnnouncementTestData.Instance.create();

        system.assert(announcementToInsert.Id == null, 'The announcement was inserted.');

        Id newAnnouncementId = OrderAdminController.addNewAnnouncement(announcementToInsert);
        
        system.assert(newAnnouncementId != null, 'The new announcement was not inserted.');
    }
    
    @isTest
    static void updateAnnouncement_announcementToUpdateSupplied_expectAnnouncementUpdatedTest() {
        Announcement__c announcementToUpdate = AnnouncementTestData.Instance.insertAnnouncement();

        announcementToUpdate.Headline__c += ' Updated';        

        OrderAdminController.updateAnnouncement(announcementToUpdate);
        
        Announcement__c announcementToUpdateQueried = getAnnouncementById(announcementToUpdate.Id);
        
        system.assertEquals(announcementToUpdate.Headline__c, announcementToUpdateQueried.Headline__c, 'The announcement\'s headline was not updated.');
    }
    
    @isTest
    static void getAnnouncementDetails_announcementHasThumbnail_expectThumbnailInfoTest() {
        Announcement__c announcement = AnnouncementTestData.Instance.insertAnnouncement();
        
        ContentDocument thumbnailDocument = insertThumbnail(announcement.Id);
        
        // If an Unable To Lock Row error occurred, the document is null.
        if (thumbnailDocument == null) {
            return;
        }
        
        OrderAdminController.onAnnouncementThumbnailUploaded(announcement.Id, thumbnailDocument.Id);
        
        OrderAdminController.AnnouncementDetails details =
                OrderAdminController.getAnnouncementDetails(announcement.Id);
                
        system.assert(String.isNotBlank(details.ThumbnailURL), 'The thumbnail url should not be blank.');
        system.assert(String.isNotBlank(details.ThumbnailContentDocumentId), 'The thumbnail content document id should not be blank.');
    }
    
    @isTest
    static void onAnnouncemnetThumbnailUploaded_existingThumbnailUploadedAndNewThumbnailUploaded_expectNewThumbnailContentDocumentDeletedAndVersionedUnderExistingOneTest() {
        Announcement__c announcement = AnnouncementTestData.Instance.insertAnnouncement();
        ContentDocument thumbnailDocument = insertThumbnail(announcement.Id);
        
        // Jessica: if the thumbnailDocument doesn't exist, it's probably because there was a "Unable To Lock Row Error"
        // so continue on.
        if(thumbnailDocument == null || thumbnailDocument.Id == null) { return; }
        
        OrderAdminController.onAnnouncementThumbnailUploaded(announcement.Id, thumbnailDocument.Id);
        
        ContentDocument newThumbnailDocument = insertThumbnail(announcement.Id, 'Some awesome thumbnail 2', 'Some Awesome 2', 'AwesomeThumbnail2.png');
        
        // Jessica: if the newThumbnailDocument doesn't exist, it's probably because there was a "Unable To Lock Row Error"
        // so continue on.
        if(newThumbnailDocument == null || newThumbnailDocument.Id == null) { return; }
        
        OrderAdminController.onAnnouncementThumbnailUploaded(announcement.Id, newThumbnailDocument.Id);
        
        List<ContentDocumentLink> thumbnailLinks =
        [SELECT Id,
                ContentDocumentId
           FROM ContentDocumentLink
          WHERE LinkedEntityId =: announcement.Id];

        system.assertEquals(1, thumbnailLinks.size(), 'There should be only one thumbnail link.');
        
        List<ContentVersion> thumbnailVersions =
        [SELECT Id
           FROM ContentVersion
          WHERE ContentDocumentId = :thumbnailLinks[0].ContentDocumentId];

        system.assertEquals(2, thumbnailVersions.size(), 'There should be 2 thumbnail versions');
    }
    
    static Announcement__c getAnnouncementById(Id announcementId) {
        return
            [SELECT Id,
             		Headline__c
             FROM Announcement__c
             WHERE Id =: announcementId];
    }
    
    static Tag__c getTagById(Id tagId) {
        return
        [SELECT Id,
                Name
           FROM Tag__c
          WHERE Id = :tagId];
    }
    
    static Marketing_Material__c getMarketingMaterialById(Id marketingMaterialId) {
        List<Marketing_Material__c> marketingMaterials =
        [SELECT Id,
                Name,
                Title__c
           FROM Marketing_Material__c
          WHERE Id = :marketingMaterialId];
          
        if (marketingMaterials.size() > 0) {
            return marketingMaterials[0];
        }
        
        return null;
    }
    
    static List<Marketing_Material_Tag__c> getMarketingMaterialTagsByTagId(Id tagId) {
        return
        [SELECT Id,
                Marketing_Material__c,
                Tag__c,
                Name
           FROM Marketing_Material_Tag__c
          WHERE Tag__c = :tagId];
    }
    
    static List<Marketing_Material_Tag__c> getMarketingMaterialTagsByMarketingMaterialId(Id marketingMaterialId) {
        return
        [SELECT Id,
                Marketing_Material__c,
                Tag__c,
                Name
           FROM Marketing_Material_Tag__c
          WHERE Marketing_Material__c = :marketingMaterialId];
    }
    
    static void assertTagsContextHasFields(OrderAdminController.TagsContext tagsContext) {
        system.assert(tagsContext != null, 'The tags context is null.');
        system.assert(tagsContext.Fields != null, 'The fields are null.');
        system.assert(tagsContext.Fields.isEmpty() == false, 'There should be fields.');
    }
    
    static void assertNoTags(OrderAdminController.TagsContext tagsContext) {
        system.assert(tagsContext != null, 'The tags context is null.');
        system.assert(tagsContext.Tags != null, 'The tags are null.');
        system.assert(tagsContext.Tags.isEmpty(), 'There should be no tags.');
    }
    
    static void assertTagsContextContainsTags(OrderAdminController.TagsContext tagsContext) {
        system.assert(tagsContext != null, 'The tags context is null.');
        system.assert(tagsContext.Tags != null, 'The tags are null.');
        system.assert(tagsContext.Tags.isEmpty() == false, 'There should be tags.');
    }

    static void assertTagsContextHasTag(OrderAdminController.TagsContext tagsContext, Tag__c tagToFind) {
        assertTagsContextContainsTags(tagsContext);
        system.assert(tagToFind != null, 'The tagToFind is null.');
        
        Boolean tagFound = false;
        
        for (Tag__c foundTag : tagsContext.Tags) {
            if (foundTag.Id == tagToFind.Id) {
                tagFound = true;
                break;
            }
        }
        
        system.assertEquals(true, tagFound, 'The tag was not found.');
    }
    
    static ContentDocument insertThumbnail(Id recordId) {
        return insertThumbnail(recordId, 'Some awesome thumbnail', 'Some Awesome', 'AwesomeThumbnail.png');
    }
    
    static ContentDocument insertThumbnail(Id recordId, String fileBody, String title, String pathOnClient) {
        try {
            // Insert our content version
            ContentVersion cv = new ContentVersion();
            cv.VersionData = Blob.valueOf(fileBody);
            cv.title = title;
            cv.PathOnClient = pathOnClient;
            cv.FirstPublishLocationId = recordId;
    
            insert cv;
            
            // Once the document is inserted, now we have to query for the contentdocumentid as it is not automatically generated
            // and share it with the objects specified by creating new content document link records.
            
            cv = [SELECT ContentDocumentId,
                         ContentDocument.Id
                    FROM ContentVersion
                   WHERE Id =: cv.Id];
            
            return cv.ContentDocument;
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
            return null;
        }
    }
    
    static ContentDocument insertMarketingMaterialDownloadableDoc(Id marketingMaterialId) {
        try {
            String fileBody = 'Some awesome download';
            
            // Insert our content version
            ContentVersion cv = new ContentVersion();
            cv.VersionData = Blob.valueOf(fileBody);
            cv.title = 'Some Awesome Download';
            cv.PathOnClient = 'AwesomeDownload.pdf';
            cv.FirstPublishLocationId = marketingMaterialId;
    
            insert cv;
            
            // Once the document is inserted, now we have to query for the contentdocumentid as it is not automatically generated
            // and share it with the objects specified by creating new content document link records.
            
            cv = [SELECT ContentDocumentId,
                         ContentDocument.Id
                    FROM ContentVersion
                   WHERE Id =: cv.Id];
            
            return cv.ContentDocument;
        }
        catch (Exception ex) {
            if (ex.getMessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW') == false) {
                throw ex;
            }
            return null;
        }
    }
}