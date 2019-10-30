public with sharing class UpcomingEventsCTRL {
	
    @AuraEnabled
    public static List<Event> getEvents(String StringStartDate, String StringEndDate)
    {
        Date startDate;
        Date endDate;
        system.debug('Dates: ' + StringStartDate + ' ' + StringEndDate);
        if(StringStartDate != null && StringStartDate != '')
            startDate = Date.valueOf(StringStartDate);
        
        if(StringEndDate != null && StringEndDate != '')
            endDate = Date.valueOf(StringEndDate);
        
        system.debug('Dates: ' + startDate + ' ' + endDate);
        List<Event> events = [SELECT Id, WhoId, Subject, StartDateTime, EndDateTime, WhatId, What.Name, 
                              Sub_Type__c, Type__c, RecordTypeId, ActivityDate, isAllDayEvent
                              FROM Event
                              WHERE OwnerId =: UserInfo.getUserId() AND
                              (((StartDateTime >= :startDate OR EndDateTIme >= :startDate) 
                               AND (StartDateTime <= :endDate.addDays(1) OR EndDateTime <= :endDate.addDays(1))) 
                              OR ( ActivityDate >= :startDate AND ActivityDate <= :endDate))
                              ORDER By StartDateTime ASC];
                
        return events;
    }
    
    @AuraEnabled
    public static String getGeneralEventRecordType()
    {
        return Schema.SObjectType.Event.getRecordTypeInfosByName().get('General Event').getRecordTypeId();
    }
}