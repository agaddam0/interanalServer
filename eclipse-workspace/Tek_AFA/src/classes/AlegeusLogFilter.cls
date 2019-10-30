public with sharing class AlegeusLogFilter extends IntegrationLogFilter {
    public String ParticipantIdToFilter { get; set; }

    public AlegeusLogFilter(String participantIdToFilterArg) {
        ParticipantIdToFilter = participantIdToFilterArg;
    }

    public override void filter(Integration_Log__c log) {
        if (String.isBlank(ParticipantIdToFilter) ||
            log == null) {
            return;
        }

        String lastFour = ParticipantIdToFilter.right(4);
        
        if (String.isNotBlank(log.Endpoint__c)) {
            log.Endpoint__c = log.Endpoint__c.replace(ParticipantIdToFilter, lastFour);
        }

        if (String.isNotBlank(log.Message__c)) {
            log.Message__c = log.Message__c.replace(ParticipantIdToFilter, lastFour);
        }

        if (String.isNotBlank(log.Request__c)) {
            log.Request__c = log.Request__c.replace(ParticipantIdToFilter, lastFour);
        }

        if (String.isNotBlank(log.Response__c)) {
            log.Response__c = log.Response__c.replace(ParticipantIdToFilter, lastFour);
        }

        if (String.isNotBlank(log.Contextual_Info__c)) {
            log.Contextual_Info__c = log.Contextual_Info__c.replace(ParticipantIdToFilter, lastFour);
        }
    }
}