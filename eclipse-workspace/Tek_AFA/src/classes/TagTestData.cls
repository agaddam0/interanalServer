/**
 * @description Builder class for dealing with Tag records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class TagTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Tag state for TagTestData.
     * @return A map of Tag Category default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Tag__c.Name => 'Some Tag 1',
            Tag__c.Status__c => 'Active',
            Tag__c.Display_in_Search_Navigation__c => true
        };
    }

    /**
     * @description Returns the SObject type for TagTestData builder.
     * @return Tag__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Tag__c.SObjectType;
    }
    
    protected override void beforeBuild() {
        Object tagCategoryId = currentValueFor(Tag__c.Tag_Category__c);
        
        if (tagCategoryId == null) {
            Tag_Category__c tagCategory = TagCategoryTestData.Instance.insertTagCategory();
            
            withTagCategory(tagCategory.Id);
        }
    }
    
    /* Create a "with" method for each property that can be set */


    /**
     * @description Sets the tag category on the tag.
     * @param tagCategoryId The tag category that the tag will have.
     * @return The instance of TagTestData.
     */
    public TagTestData withTagCategory(Id tagCategoryId) {
        return (TagTestData) withDynamicData(Tag__c.Tag_Category__c, tagCategoryId);
    }
    
    /**
     * @description Sets the name on the tag.
     * @param name The name that the tag will have.
     * @return The instance of TagTestData.
     */
    public TagTestData withName(String name) {
        return (TagTestData) withDynamicData(Tag__c.Name, name);
    }

    /**
     * @description Sets the display in search navigation on the tag.
     * @param displayInSearchNavigation The display in search navigation that the tag will have.
     * @return The instance of TagTestData.
     */
    public TagTestData withDisplayInSearchNavigation(Boolean displayInSearchNavigation) {
        return (TagTestData) withDynamicData(Tag__c.Display_in_Search_Navigation__c, displayInSearchNavigation);
    }

    /**
     * @description Sets the status on the tag.
     * @param status The status that the tag will have.
     * @return The instance of TagTestData.
     */
    public TagTestData withStatus(String status) {
        return (TagTestData) withDynamicData(Tag__c.Status__c, status);
    }


    /**
     * @description Builds the Tag object.
     * @return The created Tag object.
     */
    public Tag__c create() {
        return (Tag__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Tag object.
     * @return The inserted Tag object.
     */
    public Tag__c insertTag() {
        return (Tag__c)super.insertRecord();
    }
    
    /**
     * @description Inserts a tag using only the default values.
     * @return The inserted tag.
     */
    public Tag__c insertDefaultTag() {
        return (Tag__c) insertDefaultRecord();
    }
    
    /**
     * @description Insert the specified number of tags.
     * @param numberOfTagsToInsert The number of tags to insert.
     * @return The tags that were inserted.
     */
    public List<Tag__c> insertTagCategories(Integer numberOfTagsToInsert) {
        return (List<Tag__c>) insertRecords(numberOfTagsToInsert);
    }

    /**
     * @description Gets an instance of TagCategoryTestData.
     * @return TagCategoryTestData instance.
     */
    public static TagTestData Instance {
        get {
            if (Instance == null) {
                Instance = new TagTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private TagTestData() {
        super();
    }
}