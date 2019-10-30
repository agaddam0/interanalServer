/**
 * @description Builder class for dealing with Enrollment Path records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class EnrollmentPathTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Account state for EnrollmentPathTestData.
     * @return A map of Enrollment Path default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Enrollment_Path__c.Name => 'Limited',
            Enrollment_Path__c.Description__c => 'Some description',
            Enrollment_Path__c.Display_Order__c => 1,
            Enrollment_Path__c.Employee_Minimum__c => 5,
            Enrollment_Path__c.Lead_Time__c => 21,
            Enrollment_Path__c.Status__c => 'Active',
            Enrollment_Path__c.Summary__c => 'Some summary'
        };
    }

    /**
     * @description Returns the SObject type for EnrollmentPathTestData builder.
     * @return Enrollment_Path__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Enrollment_Path__c.SObjectType;
    }
    
    /**
     * @description Sets the status on the enrollment path.
     * @param status The status that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withStatus(String status) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Status__c, status);
    }
    
    /**
     * @description Sets the summary on the enrollment path.
     * @param summary The summary that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withSummary(String summary) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Summary__c, summary);
    }
    
    /**
     * @description Sets the name on the enrollment path.
     * @param name The name that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withName(String name) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Name, name);
    }
    
    /**
     * @description Sets the division on the enrollment path.
     * @param division The division that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withDivision(String division) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Division__c, division);
    }

    /**
     * @description Sets the level on the enrollment path.
     * @param level The level that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withLevel(String level) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Level__c, level);
    }
    
    /**
     * @description Sets the lead time on the enrollment path.
     * @param leadTime The lead time that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withLeadTime(Integer leadTime) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Lead_Time__c, leadTime);
    }
    
    /**
     * @description Sets the description on the enrollment path.
     * @param description The description that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withDescription(String description) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Description__c, description);
    }
    
    /**
     * @description Sets the employee minimum on the enrollment path.
     * @param employeeMinimum The employee minimum that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withEmployeeMinimum(Integer employeeMinimum) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Employee_Minimum__c, employeeMinimum);
    }

    /**
     * @description Sets the recommended on the enrollment path.
     * @param recommended The recommended that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withRecommended(Boolean recommended) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Recommended__c, recommended);
    }

    /**
     * @description Sets the display order on the enrollment path.
     * @param displayOrder The employee minimum that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withDisplayOrder(Integer displayOrder) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Display_Order__c, displayOrder);
    }
    
    /**
     * @description Sets the sub name on the enrollment path.
     * @param subName The sub name that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withSubName(String subName) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Sub_Name__c, subName);
    }

    /**
     * @description Sets the platform setup field set on the enrollment path.
     * @param platformSetupFieldSet The platform setup field set that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withPlatformSetupFieldSet(String platformSetupFieldSet) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Platform_Setup_Field_Set__c, platformSetupFieldSet);
    }

    /**
     * @description Sets the default when less than employee minimum field set on the enrollment path.
     * @param defaultWhenLessThanEmployeeMinimum The default when less than employee minimum that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withDefaultWhenLessThanEmployeeMinimum(Boolean defaultWhenLessThanEmployeeMinimum) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Default_When_Less_Than_Employee_Minimum__c, defaultWhenLessThanEmployeeMinimum);
    }

    /**
     * @description Sets the below employee minimum message on the enrollment path.
     * @param belowEmployeeMinimumMessage The below employee minimum message that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withBelowMinimumEmployeeMessage(String belowEmployeeMinimumMessage) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Below_Minimum_Employee_Message__c, belowEmployeeMinimumMessage);
    }

    /**
     * @description Sets the below employee minimum reason required on the enrollment path.
     * @param belowEmployeeMinimumReasonRequired The below employee minimum reason required that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withBelowEmployeeMinimumReasonRequired(Boolean belowEmployeeMinimumReasonRequired) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.Below_Employee_Minimum_Reason_Required__c, belowEmployeeMinimumReasonRequired);
    }

    /**
     * @description Sets the AFEnroll Case Lead Time on the enrollment path.
     * @param afEnrollCaseLeadTime The AFEnroll Case Lead Time that the enrollment path will have.
     * @return The instance of EnrollmentPathTestData.
     */
    public EnrollmentPathTestData withAFEnrollCaseLeadTime(Integer afEnrollCaseLeadTime) {
        return (EnrollmentPathTestData) withDynamicData(Enrollment_Path__c.AFEnroll_Case_Lead_Time__c, afEnrollCaseLeadTime);
    }
    
    /**
     * @description Builds the Enrollment Path object.
     * @return The created Enrollment Path object.
     */
    public Enrollment_Path__c create() {
        return (Enrollment_Path__c)super.buildWithReset();
    }
    
    /**
     * @description Inserts the built Enrollment Path object.
     * @return The inserted Enrollment Path object.
     */
    public Enrollment_Path__c insertEnrollmentPath() {
        return (Enrollment_Path__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of AccountTestData.
     * @return AccountTestData instance.
     */
    public static EnrollmentPathTestData Instance {
        get {
            if (Instance == null) {
                Instance = new EnrollmentPathTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private EnrollmentPathTestData() {
        super();
    }
}