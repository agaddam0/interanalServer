/**
* @description Builder class for dealing with Announcement records.
* Solely used for testing, NOT a data factory.
**/
@isTest
public class AnnouncementTestData extends sObjectTestData{
    /**
     * @description Overridden method to set up the default
     * Announcement state for AnnouncementTestData.
     * @return A map of Sales Office default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
        	Announcement__c.Status__c => 'Active',
            Announcement__c.Headline__c => 'Awesome Headline'
        };
    }

    /**
     * @description Returns the SObject type for AnnouncementTestData builder.
     * @return Announcement.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Announcement__c.SObjectType;
    }
    
    /* Create a "with" method for each property that can be set */
    
    
    
    /**
     * @description Builds the Announcement object.
     * @return The created Announcement object.
     */
    public Announcement__c create() {
        return (Announcement__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Announcement object.
     * @return The inserted Announcement object.
     */
    public Announcement__c insertAnnouncement() {
        return (Announcement__c)super.insertRecord();
    }

    /**
     * @description Gets an instance of AnnouncementTestData.
     * @return AnnouncementTestData instance.
     */
    public static AnnouncementTestData Instance {
        get {
            if (Instance == null) {
                Instance = new AnnouncementTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private AnnouncementTestData() {
        super();
    }
}