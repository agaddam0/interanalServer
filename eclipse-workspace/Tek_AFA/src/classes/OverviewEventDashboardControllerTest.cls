@isTest
public with sharing class OverviewEventDashboardControllerTest {

    @isTest
    static void retrieveEvents_allEventsNoCriteriaNoEventsCreated_expectNoEventsReturnedTest() {
        String objectType = 'Event';
        List<String> fields = new List<String>{ 'Id' };
        Map<String, Object> noCriteria = new Map<String, Object>();
        
        Map<String, Object> result = OverviewEventDashboardController.retrieveEvents(objectType, fields, noCriteria);
        
        system.debug('  result ' + result);
        
        system.assert(result != null, 'The result is null.');
    }
}