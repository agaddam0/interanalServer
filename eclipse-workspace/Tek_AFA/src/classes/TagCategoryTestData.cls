/**
 * @description Builder class for dealing with Tag Category records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class TagCategoryTestData extends SObjectTestData {

    /**
     * @description Overridden method to set up the default
     * Tag Category state for TagCategoryTestData.
     * @return A map of Tag Category default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Tag_Category__c.Name => 'Category 1',
            Tag_Category__c.Display_Order__c => 1,
            Tag_Category__c.Display_in_Search_Navigation__c => true
        };
    }

    /**
     * @description Returns the SObject type for TagCategoryTestData builder.
     * @return Tag_Category__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Tag_Category__c.SObjectType;
    }

    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Sets the name on the tag category.
     * @param name The name that the tag category will have.
     * @return The instance of TagCategoryTestData.
     */
    public TagCategoryTestData withName(String name) {
        return (TagCategoryTestData) withDynamicData(Tag_Category__c.Name, name);
    }

    /**
     * @description Sets the display order on the tag category.
     * @param displayOrder The display order that the tag category will have.
     * @return The instance of TagCategoryTestData.
     */
    public TagCategoryTestData withDisplayOrder(Integer displayOrder) {
        return (TagCategoryTestData) withDynamicData(Tag_Category__c.Display_Order__c, displayOrder);
    }
    
    /**
     * @description Builds the Tag Category object.
     * @return The created Tag Category object.
     */
    public Tag_Category__c create() {
        return (Tag_Category__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Tag Category object.
     * @return The inserted Tag Category object.
     */
    public Tag_Category__c insertTagCategory() {
        return (Tag_Category__c)super.insertRecord();
    }
    
    /**
     * @description Inserts an tag category using only the default values.
     * @return The inserted tag category.
     */
    public Tag_Category__c insertDefaultTagCategory() {
        return (Tag_Category__c) insertDefaultRecord();
    }
    
    /**
     * @description Insert the specified number of tag category.
     * @param numberOfTagCategoriesToInsert The number of tag categories to insert.
     * @return The tag categories that were inserted.
     */
    public List<Tag_Category__c> insertTagCategories(Integer numberOfTagCategoriesToInsert) {
        return (List<Tag_Category__c>) insertRecords(numberOfTagCategoriesToInsert);
    }

    /**
     * @description Gets an instance of TagCategoryTestData.
     * @return TagCategoryTestData instance.
     */
    public static TagCategoryTestData Instance {
        get {
            if (Instance == null) {
                Instance = new TagCategoryTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private TagCategoryTestData() {
        super();
    }
    
}