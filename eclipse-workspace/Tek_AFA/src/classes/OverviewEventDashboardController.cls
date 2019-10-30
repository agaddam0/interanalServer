public with sharing class OverviewEventDashboardController {
   
    @RemoteAction
    public static Map<String, Object> retrieveEvents(String type, List<String> fields, Map<String, Object> criteria) {
        system.debug('    retrieveEvents::type ' + type);
        system.debug('    retrieveEvents::fields ' + fields);
        system.debug('    retrieveEvents::criteria ' + criteria);
        
        String criteriaJSON = String.valueOf(criteria);
        
        if (String.isNotBlank(criteriaJSON) &&
            criteriaJSON.containsIgnoreCase('OwnerId={in=[') &&
            criteriaJSON.containsIgnoreCase('Sub_Type__c={in=[') &&
            criteriaJSON.containsIgnoreCase('StartDateTime={gte=') &&
            criteriaJSON.containsIgnoreCase('EndDateTime={lt=')) {

			String whereValue = criteriaJSON.substringAfter('where=');
			String ownerIdsPlus = whereValue.substringAfter('OwnerId={in=[');
			String ownerIds = ownerIdsPlus.substringBefore(']');
			
			List<String> ownerIdsValues = ownerIds.split(', ');
			
			String subtypesPlus = whereValue.substringAfter('Sub_Type__c={in=[');
			String subtypes = subtypesPlus.substringBefore(']');
			
			List<String> subTypeValues = subtypes.split(', ');
			
			String startDateTimePlus = whereValue.substringAfter('StartDateTime={gte=');
			String startDateTime = startDateTimePlus.substringBefore('}');
			
			String endDateTimePlus = whereValue.substringAfter('EndDateTime={lt=');
			String endDateTime = endDateTimePlus.substringBefore('}');
			
			Date startDate = Date.valueOf(startDateTime);
	        Date endDate = Date.valueOf(endDateTime);
	        
	        List<Event> events = getEvents(ownerIdsValues, subTypeValues, startDate, endDate, fields);
	        
	        system.debug('    retrieveEvents::events ' + events);
	        
	        return buildRetrieveResult(events, 'Event');
        }
        
        return RemoteObjectController.retrieve(type, fields, criteria);
    }
    
    private static Map<String, Object> buildRetrieveResult(List<SObject> records, String objectType) {
        Map<String, Object> result = new Map<String, Object>();
        
        result.put('records', records);
        result.put('size', records.size());
        result.put('success', true);
        result.put('type', objectType);
        
        system.debug('    buildRetrieveResult::result ' + result);
        
        return result;
    }
    
    private static List<Event> getEvents(List<String> userIds, List<String> subTypes, Date startDateArg, Date endDateExclusiveArg, List<String> fieldsToQuery) {
        system.debug('    getEvents::userIds ' + userIds);
        system.debug('    getEvents::subTypes ' + subTypes);
        system.debug('    getEvents::startDateArg ' + startDateArg);
        system.debug('    getEvents::endDateExclusiveArg ' + endDateExclusiveArg);
        system.debug('    getEvents::fieldsToQuery ' + fieldsToQuery);
        
        Date startDate = Date.newInstance(startDateArg.year(), startDateArg.month(), startDateArg.day());
        Date endDateExclusive = Date.newInstance(endDateExclusiveArg.year(), endDateExclusiveArg.month(), endDateExclusiveArg.day());
        
        system.debug('    getEvents::startDate ' + startDate);
        system.debug('    getEvents::endDateExclusive ' + endDateExclusive);
        
        String query = 'Select ' + String.join(fieldsToQuery, ',') +
                       '  FROM Event ' +
                       ' WHERE OwnerId in :userIds ' +
                       '   AND Sub_Type__c in :subTypes ' +
                       '   AND ((StartDateTime >= :startDate AND ' +
                       '         StartDateTime < :endDateExclusive) ' +
                       '        OR ' +
                       '       (EndDateTime >= :startDate AND ' +
                       '        EndDateTime < :endDateExclusive))';
        
        List<Event> events = Database.query(query);
        
        return events;
    }
}