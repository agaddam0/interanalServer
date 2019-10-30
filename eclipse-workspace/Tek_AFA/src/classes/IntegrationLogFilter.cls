// Used to format an integration log's contents such as masking private information like PHI / PII.
public with sharing virtual class IntegrationLogFilter {

    public virtual void filter(Integration_Log__c log) { }
}