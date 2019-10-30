/**
 * @description Builder class for dealing with Integration Log records.
 * Solely used for testing, NOT a data factory.
 **/
@isTest
public with sharing class IntegrationLogTestData extends SObjectTestData {
    /**
     * @description Overridden method to set up the default
     * Integration Log state for IntegrationLogTestData.
     * @return A map of Account default fields.
     */
    protected override Map<Schema.SObjectField, Object> getDefaultValueMap() {
        return new Map<Schema.SObjectField, Object>{
            Integration_Log__c.Integration__c => 'Test Integration',
            Integration_Log__c.Severity__c => 'INFO',
            Integration_Log__c.Request__c => '{"Test": "test request"}'
        };
    }

    /**
     * @description Returns the SObject type for IntegrationLogTestData builder.
     * @return Integration_Log__c.SObjectType.
     */
    protected override Schema.SObjectType getSObjectType() {
        return Integration_Log__c.SObjectType;
    }
    
    /* Create a "with" method for each property that can be set */
    
    /**
     * @description Sets the integration on the integration log.
     * @param integration The integration that the integration log will have.
     * @return The instance of IntegrationLogTestData.
     */
    public IntegrationLogTestData withIntegration(String integration) {
        return (IntegrationLogTestData) withDynamicData(Integration_Log__c.Integration__c, integration);
    }
    
    /**
     * @description Sets the severity on the integration log.
     * @param severity The severity that the integration log will have.
     * @return The instance of IntegrationLogTestData.
     */
    public IntegrationLogTestData withSeverity(String severity) {
        return (IntegrationLogTestData) withDynamicData(Integration_Log__c.Severity__c, severity);
    }
    
    /**
     * @description Sets the request on the integration log.
     * @param request The request that the integration log will have.
     * @return The instance of IntegrationLogTestData.
     */
    public IntegrationLogTestData withRequest(String request) {
        return (IntegrationLogTestData) withDynamicData(Integration_Log__c.Request__c, request);
    }
    
    /**
     * @description Sets the response on the integration log.
     * @param response The response that the integration log will have.
     * @return The instance of IntegrationLogTestData.
     */
    public IntegrationLogTestData withResponse(String response) {
        return (IntegrationLogTestData) withDynamicData(Integration_Log__c.Response__c, response);
    }
    
    /**
     * @description Sets the stack trace on the integration log.
     * @param stackTrace The stack trace that the integration log will have.
     * @return The instance of IntegrationLogTestData.
     */
    public IntegrationLogTestData withStackTrace(String stackTrace) {
        return (IntegrationLogTestData) withDynamicData(Integration_Log__c.Stack_Trace__c, stackTrace);
    }
    
    /**
     * @description Builds the Integration Log object.
     * @return The created Integration Log object.
     */
    public Integration_Log__c create() {
        return (Integration_Log__c)super.buildWithReset();
    }

    /**
     * @description Inserts the built Integration_Log__c object.
     * @return The inserted Integration_Log__c object.
     */
    public Integration_Log__c insertIntegrationLog() {
        return (Integration_Log__c)super.insertRecord();
    }
    
    /**
     * @description Gets an instance of IntegrationLogTestData.
     * @return IntegrationLogTestData instance.
     */
    public static IntegrationLogTestData Instance {
        get {
            if (Instance == null) {
                Instance = new IntegrationLogTestData();
            }
            return Instance;
        }
    }

    /**
     * @description Private constructor for singleton.
     */
    private IntegrationLogTestData() {
        super();
    }
}