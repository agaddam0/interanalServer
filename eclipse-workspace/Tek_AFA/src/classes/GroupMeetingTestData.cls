/**
 * @description Builder class for dealing with Group_Meeting__c records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class GroupMeetingTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Group_Meeting__c state for AccountTestData.
     * @return A map of Group_Meeting__c default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Group_Meeting__c.Site_Name__c => 'Metillium, Inc.',
            Group_Meeting__c.Date_Start_Time__c => DateTime.Now().addDays(7),
            Group_Meeting__c.Location__c => 'Metillium Inc Home Office'
        };
    }
    
    /**
     * @description Returns the SObject type for GroupMeetingTestData builder.
     * @return Group_Meeting__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Group_Meeting__c.SObjectType;
    }
    
    protected override void beforeBuild() {
        Object marketingFormId = currentValueFor(Group_Meeting__c.Pre_Enrollment_Marketing_Form__c);
        
        if (marketingFormId == null) {
            Pre_Enrollment_Marketing_Form__c marketingForm = PreenrollmentMarketingFormTestData.Instance.insertPreenrollmentMarketingForm();
            
            withPreenrollmentMarketingForm(marketingForm.Id);
        }
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Sets the pre enrollment marketing form on the group meeting.
     * @param preenrollmentMarketingFormId The pre enrollment marketing form that the group meeting will have.
     * @return The instance of GroupMeetingTestData.
     */
    public GroupMeetingTestData withPreenrollmentMarketingForm(Id preenrollmentMarketingFormId) {
        return (GroupMeetingTestData) withDynamicData(Group_Meeting__c.Pre_Enrollment_Marketing_Form__c, preenrollmentMarketingFormId);
    }
    
    /**
     * @description Sets the site name on the group meeting.
     * @param siteName The site name that the group meeting will have.
     * @return The instance of GroupMeetingTestData.
     */
    public GroupMeetingTestData withSiteName(String siteName) {
        return (GroupMeetingTestData) withDynamicData(Group_Meeting__c.Site_Name__c, siteName);
    }
    
    /**
     * @description Sets the date start time on the group meeting.
     * @param dateStartTime The date start time that the group meeting will have.
     * @return The instance of GroupMeetingTestData.
     */
    public GroupMeetingTestData withDateStartTime(DateTime dateStartTime) {
        return (GroupMeetingTestData) withDynamicData(Group_Meeting__c.Date_Start_Time__c, dateStartTime);
    }
    
    /**
     * @description Sets the location on the group meeting.
     * @param location The location that the group meeting will have.
     * @return The instance of GroupMeetingTestData.
     */
    public GroupMeetingTestData withLocation(String location) {
        return (GroupMeetingTestData) withDynamicData(Group_Meeting__c.Location__c, location);
    }
    
    /**
     * @description Builds the Group_Meeting__c object.
     * @return The created Group_Meeting__c object.
     */
    public Group_Meeting__c create() {
        return (Group_Meeting__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Group_Meeting__c object.
     * @return The inserted Group_Meeting__c object.
     */
    public Group_Meeting__c insertGroupMeeting() {
        return (Group_Meeting__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of GroupMeetingTestData.
     * @return GroupMeetingTestData instance.
     */
    public static GroupMeetingTestData Instance {
        get {
            if (Instance == null) {
                Instance = new GroupMeetingTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private GroupMeetingTestData() {
        super();
    }
}