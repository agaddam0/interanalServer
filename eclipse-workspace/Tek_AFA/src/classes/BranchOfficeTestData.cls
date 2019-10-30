/**
 * @description Builder class for dealing with Branch Office records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public without sharing class BranchOfficeTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Branch Office state for BranchOfficeTestData.
     * @return A map of Branch Office default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Branch_Office__c.Name => 'Home Office',
            Branch_Office__c.Address__c => '9000 Cameron Parkway',
            Branch_Office__c.City__c => 'Oklahoma City',
            Branch_Office__c.State__c => 'Oklahoma',
            Branch_Office__c.Zip__c => '74113',
            Branch_Office__c.Local_Phone__c => '7165551982',
            Branch_Office__c.Resource_ID__c => '{1231lkj-1209-adlk-103kd9}',
            Branch_Office__c.Toll_Free_Phone__c => '8005551019',
            Branch_Office__c.Status__c => 'Open',
            Branch_Office__c.Division__c => 'AFES'
        };
    }
    
    /**
     * @description Returns the SObject type for BranchOfficeTestData builder.
     * @return Branch_Office__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Branch_Office__c.SObjectType;
    }
    
    /**
     * @description Builds the Branch Office object.
     * @return The created Branch Office object.
     */
    public Branch_Office__c create() {
        return (Branch_Office__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Branch Office object.
     * @return The inserted Branch Office object.
     */
    public Branch_Office__c insertBranchOffice() {
        return (Branch_Office__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of BranchOfficeTestData.
     * @return BranchOfficeTestData instance.
     */
    public static BranchOfficeTestData Instance {
        get {
            if (Instance == null) {
                Instance = new BranchOfficeTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private BranchOfficeTestData() {
        super();
    }
}