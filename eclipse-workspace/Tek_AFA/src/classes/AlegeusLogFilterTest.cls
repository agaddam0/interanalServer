@isTest
public with sharing class AlegeusLogFilterTest {
    
    @isTest
    static void filter_logNull_expectNoErrorTest() {
        String errorMessage = '';

        try {
            String participantId = 'ABC';
            Integration_Log__c nullIntegrationLog = null;

            filter(participantId, nullIntegrationLog);
        }
        catch(Exception e) {
            errorMessage = e.getMessage();
        }

        system.assertEquals('', errorMessage, 'Expected no error but error found: ' + errorMessage);
    }

    @isTest
    static void filter_participantIdNull_expectNoErrorTest() {
        String errorMessage = '';

        try {
            String participantIdNull = 'ABC';
            Integration_Log__c log = new Integration_Log__c();

            filter(participantIdNull, log);
        }
        catch(Exception e) {
            errorMessage = e.getMessage();
        }

        system.assertEquals('', errorMessage, 'Expected no error but error found: ' + errorMessage);
    }

    @isTest
    static void filter_participantIdInEndpoint_expectParticipantIdRemovedFromEndpointTest() {
        participantIdfilteredFromFieldTest('Endpoint__c');
    }

    @isTest
    static void filter_participantIdInRequest_expectParticipantIdRemovedFromRequestTest() {
        participantIdfilteredFromFieldTest('Request__c');
    }

    @isTest
    static void filter_participantIdInResponse_expectParticipantIdRemovedFromResponseTest() {
        participantIdfilteredFromFieldTest('Response__c');
    }

    @isTest
    static void filter_participantIdInContextualInfo_expectParticipantIdRemovedFromContextualInfoTest() {
        participantIdfilteredFromFieldTest('Contextual_Info__c');
    }

    @isTest
    static void filter_participantIdInMessage_expectParticipantIdRemovedFromMessageTest() {
        participantIdfilteredFromFieldTest('Message__c');
    }

    static void filter(String participantId, Integration_log__c log) {
        AlegeusLogFilter filter = new AlegeusLogFilter(participantId);
        filter.filter(log);
    }
    
    static void participantIdfilteredFromFieldTest(String logField) {
        String participantId = 'ABC123';
        Integration_Log__c log = new Integration_Log__c();
        log.put(logField, 'https://example.com/' + participantId);
        
        filter(participantId, log);
        
        String fieldValue = (String) log.get(logField);
        
        system.assertEquals(false, fieldValue.containsIgnoreCase(participantId),
                            'The participant id was not removed from the ' + logField);
    }
}