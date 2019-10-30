/**
 * @description Builder class for dealing with Contact records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public without sharing class AsyncRequestTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Async Request state for AsyncRequestTestData.
     * @return A map of Async Request default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Async_Request__c.Status__c => 'Not Started'
        };
    }

    /**
     * @description Returns the SObject type for AsyncRequestTestData builder.
     * @return Async_Request__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Async_Request__c.SObjectType;
    }
    
    /**
     * @description Sets the operation class on the async request.
     * @param operationClass The operation class that the async request will have.
     * @return The instance of AsyncRequestTestData.
     */
    public AsyncRequestTestData withOperationClass(String operationClass) {
        return (AsyncRequestTestData) withDynamicData(Async_Request__c.Operation_Class__c, operationClass);
    }
    
    /**
     * @description Sets the parameters on the async request.
     * @param parameters The parameters that the async request will have.
     * @return The instance of AsyncRequestTestData.
     */
    public AsyncRequestTestData withParameters(String parameters) {
        return (AsyncRequestTestData) withDynamicData(Async_Request__c.Parameters__c, parameters);
    }
    
    /**
     * @description Builds the async request object.
     * @return The created async request object.
     */
    public Async_Request__c create() {
        return (Async_Request__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built async request object.
     * @return The inserted async request object.
     */
    public Async_Request__c insertAsyncRequest() {
        return (Async_Request__c) super.insertRecord();
    }
    
    /**
     * @description Gets an instance of AsyncRequestTestData.
     * @return AsyncRequestTestData instance.
     */
    public static AsyncRequestTestData Instance {
        get {
            if (Instance == null) {
                Instance = new AsyncRequestTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private AsyncRequestTestData() {
        super();
    }
}