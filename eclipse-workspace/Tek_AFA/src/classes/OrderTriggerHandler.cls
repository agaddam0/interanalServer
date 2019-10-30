public with sharing class OrderTriggerHandler extends TriggerHandlerBase {
    protected override void beforeInsert(List<Sobject> newRecords) {
        List<Order__c> newOrders = (List<Order__c>) newRecords;

        assignSalesOffices(newRecords);
    }

    protected override void beforeUpdate(Map<Id, Sobject> oldRecordsMap, Map<Id, Sobject> newRecordsMap) {
        Map<Id, Order__c> oldOrdersMap = (Map<Id, Order__c>) oldRecordsMap;
        Map<Id, Order__c> newOrdersMap = (Map<Id, Order__c>) newRecordsMap;

        assignSalesOfficesToUpdatedOrders(oldOrdersMap, newOrdersMap);
        provisionWebsitesOnOrderSubmission(oldOrdersMap, newOrdersMap);
    }

    private void assignSalesOfficesToUpdatedOrders(Map<Id, Order__c> oldOrdersMap, Map<Id, Order__c> newOrdersMap) {
        List<Order__c> ordersToAssign = new List<Order__c>();

        for (Order__c oldOrder : oldOrdersMap.values()) {
            Order__c newOrder = newOrdersMap.get(oldOrder.Id);

            if (oldOrder.Colleague__c != newOrder.Colleague__c) {
                ordersToAssign.add(newOrder);
            }
        }

        if (ordersToAssign.size() > 0) {
            assignSalesOffices(ordersToAssign);
        }
    }
    
    private void provisionWebsitesOnOrderSubmission(Map<Id, Order__c> oldOrdersMap, Map<Id, Order__c> newOrdersMap) {
        Set<Id> submittedOrderIds = new Set<Id>();
        
        for (Order__c oldOrder : oldOrdersMap.values()) {
            Order__c newOrder = newOrdersMap.get(oldOrder.Id);
            
            if (isNowSubmitted(oldOrder, newOrder)) {
                submittedOrderIds.add(newOrder.Id);
            }
        }
        
        if (submittedOrderIds.isEmpty()) {
            return;
        }
        
        List<Order_Line_Item__c> websiteOrderLines = getWebsiteOrderLinesInOrders(submittedOrderIds);
        List<BenefitsSiteOrderLine> benefitsSiteOrderLines = new List<BenefitsSiteOrderLine>();
        
        for (Order_Line_Item__c websiteOrderLine : websiteOrderLines) {
            if (websiteOrderLine.Marketing_Material__r.Website_Type__c == 'Benefits Site' ||
                websiteOrderLine.Marketing_Material__r.Website_Type__c == 'Appointment Scheduler') {
                BenefitsSiteOrderLine bsol = new BenefitsSiteOrderLine();
                bsol.orderLineItem = websiteOrderLine;
                bsol.isApptScheduler = websiteOrderLine.Marketing_Material__r.Website_Type__c == 'Appointment Scheduler';

                benefitsSiteOrderLines.add(bsol);
            }
        }
        
        provisionBenefitsSiteRequests(benefitsSiteOrderLines);
    }

    private void assignSalesOffices(List<Order__c> orders) {
        Set<Id> colleagueUserIds = getColleagueUserIds(orders);
        
        Map<Id, Branch_Office__c> salesOfficesByColleague = getSalesOfficesByColleague(colleagueUserIds);

        Id currentUserId = UserInfo.getUserId();

        for (Order__c order : orders) {
            Id colleagueUserIdToUse = order.Colleague__c != null ? order.Colleague__c : 
                                      order.CreatedById != null ? order.CreatedById :
                                      currentUserId;
            
            Branch_Office__c colleagueSalesOffice = salesOfficesByColleague.get(colleagueUserIdToUse);
            
            order.Sales_Office__c = colleagueSalesOffice != null ? colleagueSalesOffice.Id : null;
        }
    }

    private Set<Id> getColleagueUserIds(List<Order__c> orders) {
        Set<Id> colleagueUserIds = new Set<Id>();

        for (Order__c order : orders) {
            if (order.CreatedById != null) {
                colleagueUserIds.add(order.CreatedById);
            }
            else {
                Id currentUserId = UserInfo.getUserId();
                
                colleagueUserIds.add(currentUserId);
            }

            if (order.Colleague__c != null) {
                colleagueUserIds.add(order.Colleague__c);
            }
        }

        return colleagueUserIds;
    }

    private Map<Id, Branch_Office__c> getSalesOfficesByColleague(Set<Id> colleageUserIds) {
        Map<Id, Branch_Office__c> salesOfficesByColleague = new Map<Id, Branch_Office__c>();

        List<Colleague_Sales_Office__c> colleagueSalesOffices =
        [SELECT Sales_Office__r.Id,
                Sales_Office__r.Name,
                Sales_Office__r.Charge_Code__c,
                Sales_Office__r.Mailing_Code__c,
                Sales_Office__r.Copy_Code__c,
                Colleague__c
           FROM Colleague_Sales_Office__c
          WHERE Colleague__c in :colleageUserIds
         ORDER BY CreatedDate DESC];
         
        for (Colleague_Sales_Office__c colleagueSalesOffice : colleagueSalesOffices) {
            if (salesOfficesByColleague.containsKey(colleagueSalesOffice.Colleague__c) == false) {
                salesOfficesByColleague.put(colleagueSalesOffice.Colleague__c, colleagueSalesOffice.Sales_Office__r);
            }
        }

        return salesOfficesByColleague;
    }
    
    private Boolean isNowSubmitted(Order__c oldOrder, Order__c newOrder) {
        return oldOrder.Status__c == 'In Progress' &&
               newOrder.Status__c == 'Submitted';
    }
    
    private List<Order_Line_Item__c> getWebsiteOrderLinesInOrders(Set<Id> orderIds) {
        return
        [SELECT Id,
                Name,
                Opportunity__c,
                Opportunity__r.AccountId,
                Opportunity__r.Account.Id,
                Opportunity__r.Account.Employer_Benefits_Site_Request_DateTime__c,
                Opportunity__r.Account.Enrollment_Site__c,
                Opportunity__r.Account.Marketing_Resource_ID__c,
                Marketing_Material__r.Website_Type__c
           FROM Order_Line_Item__c
          WHERE Order__c in :orderIds
            AND Marketing_Material__r.Material_Type__c = 'Website'
            AND Opportunity__c != null];
    }
    
    private void provisionBenefitsSiteRequests(List<BenefitsSiteOrderLine> benefitsSiteOrderLines) {
        if (benefitsSiteOrderLines.isEmpty()) {
            return;
        }
        
        
        Map<Id, Account> accountsToUpdateForEmployerUpsertMap = new Map<Id, Account>();
        Map<Id, Pre_Enrollment_Marketing_Form__c> preenrollmentsToUpdateMap = new Map<Id, Pre_Enrollment_Marketing_Form__c>();
        List<Async_Request__c> asyncRequests = new List<Async_Request__c>();
        Set<Id> opportunityIds = getBenfitsSiteOrderLineOpportunityIds(benefitsSiteOrderLines);
        Map<Id, Pre_Enrollment_Marketing_Form__c> preenrollmentsByOpportunityId = getPreenrollmentMarketingFormIndexedByOpportunity(opportunityIds);
        
        for (BenefitsSiteOrderLine benefitsSiteOrderLine : benefitsSiteOrderLines) {

            Pre_Enrollment_Marketing_Form__c marketingForm = preenrollmentsByOpportunityId.get(benefitsSiteOrderLine.OrderLineItem.Opportunity__c);
            
            // Employer Upsert first and then Microsite Upsert later after the integration writes back the Marketing Resource Id
            if (benefitsSiteOrderLine.OrderLineItem.Opportunity__r.Account.Marketing_Resource_ID__c == null) {
                if (accountsToUpdateForEmployerUpsertMap.containsKey(benefitsSiteOrderLine.OrderLineItem.Opportunity__r.Account.Id)) {
                    continue;
                }

                Async_Request__c employerUpsertRequest = new Async_Request__c(
                    Operation_Class__c = 'ESBEmployerUpsertAsyncRequestHandler',
                    Parameters__c = benefitsSiteOrderLine.OrderLineItem.Opportunity__c
                );
                
                asyncRequests.add(employerUpsertRequest);
                
                benefitsSiteOrderLine.OrderLineItem.Opportunity__r.Account.Employer_Benefits_Site_Request_DateTime__c = DateTime.Now();

                if (benefitsSiteOrderLine.isApptScheduler == false) {
                    benefitsSiteOrderLine.OrderLineItem.Opportunity__r.Account.Requested_Microsite_Prenrollment_Form_Id__c = marketingForm.Id;
                }

                accountsToUpdateForEmployerUpsertMap.put(benefitsSiteOrderLine.OrderLineItem.Opportunity__r.Account.Id, benefitsSiteOrderLine.OrderLineItem.Opportunity__r.Account);
            }
            // Employer Has Benefits Site Already. Send Microsite Upsert Request but only one in case
            // Appointment Scheduler and Benefits Site both ordered.
            else if (preenrollmentsToUpdateMap.containsKey(marketingForm.Id) == false){
                marketingForm.Last_Microsite_Request_DateTime__c = DateTime.Now();
                preenrollmentsToUpdateMap.put(marketingForm.Id, marketingForm);
                
                Async_Request__c micrositeUpsertRequest = new Async_Request__c(
                    Operation_Class__c = 'ESBMicrositeUpdateAsyncRequestHandler',
                    Parameters__c = marketingForm.Id
                );
                
                asyncRequests.add(micrositeUpsertRequest);
            }
        }
        
        if (asyncRequests.size() > 0) {
            insert asyncRequests;
        }
        
        if (accountsToUpdateForEmployerUpsertMap.size() > 0) {
            update accountsToUpdateForEmployerUpsertMap.values();
        }
        
        if (preenrollmentsToUpdateMap.size() > 0) {
            update preenrollmentsToUpdateMap.values();
        }
    }
    
    private Map<Id, Pre_Enrollment_Marketing_Form__c> getPreenrollmentMarketingFormIndexedByOpportunity(Set<Id> opportunityId) {
        Map<Id, Pre_Enrollment_Marketing_Form__c> marketingFormsByOpportunity = new Map<Id, Pre_Enrollment_Marketing_Form__c>();

        List<Pre_Enrollment_Marketing_Form__c> marketingForms =
        [SELECT Id,
                Name,
                First_Microsite_Request_DateTime__c,
                Last_Microsite_Request_DateTime__c,
                Enrollment_Form__r.Enrollment_Opportunity__c
           FROM Pre_Enrollment_Marketing_Form__c
          WHERE Enrollment_Form__r.Enrollment_Opportunity__c in :opportunityId];

        for (Pre_Enrollment_Marketing_Form__c marketingForm : marketingForms) {
            marketingFormsByOpportunity.put(marketingForm.Enrollment_Form__r.Enrollment_Opportunity__c, marketingForm);
        }

        return marketingFormsByOpportunity;
    }

    private class BenefitsSiteOrderLine {
        public Order_Line_Item__c orderLineItem { get; set; }

        public Boolean isApptScheduler { get; set; }

        public BenefitsSiteOrderLine() {
            isApptScheduler = false;
        }
    }

	private Set<Id> getBenfitsSiteOrderLineOpportunityIds(List<BenefitsSiteOrderLine> benefitsSiteOrderLines){
        List<Order_Line_Item__c> orderLineItems = new List<Order_Line_Item__c>();

        for (BenefitsSiteOrderLine bsol : benefitsSiteOrderLines) {
            orderLineItems.add(bsol.OrderLineItem);
        }

		return CollectionUtil.getLookupIds(orderLineItems, 'Opportunity__c');
	} 
}