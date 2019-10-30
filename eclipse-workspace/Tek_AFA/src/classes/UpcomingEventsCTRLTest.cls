@isTest
public class UpcomingEventsCTRLTest {
    
    @testSetup
    static void testData()
    {
        Event e = new Event();
        e.StartDateTime = system.now();
        e.EndDateTime = system.now().addHours(1);
        e.Subject = 'Upcoming Events Test';
        e.Type__c = 'Call';
        
        insert e;
    }
    
    @isTest
    static void testEventsToday()
    {
        DateTime today = system.now();
        String sDay = today.format('yyyy-MM-dd');
        List<Event> events = UpcomingEventsCTRL.getEvents(sDay, sDay);
        
        system.assertEquals(1, events.size());
    }
    
    @isTest
    static void getRecordType()
    {
        String rTypeId = UpcomingEventsCTRL.getGeneralEventRecordType();
        
        system.assertEquals(Schema.SObjectType.Event.getRecordTypeInfosByName().get('General Event').getRecordTypeId(), rTypeId);
    }

}