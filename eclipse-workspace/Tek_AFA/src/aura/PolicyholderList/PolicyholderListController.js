({
	doInit : function(component, event, helper) {
        helper.toggle(component, event);
		helper.getRecords(component, event);
        
        component.set("v.alphaList", ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Other', 'All']);
	},
    
    updateList : function(component, event, helper) {
        helper.toggle(component, event);
        helper.getRecords(component, event);
    },
    
    goToRecord : function(component, event, handler) {
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        var selectedId = event.currentTarget.getAttribute("data-recId");
        sObjectEvent.setParams({
            "recordId" : selectedId
        });
        sObjectEvent.fire();
    },
    
    goToEditRecord : function(component, event, handler) {
        var sObjectEvent = $A.get("e.force:editRecord");
        var selectedId = event.currentTarget.getAttribute("data-recId");
        sObjectEvent.setParams({
            "recordId" : selectedId
        });
        sObjectEvent.fire();
    },
    
    dateChange: function(component, event, helper) {
        helper.toggle(component, event);
        var dateField = component.find("searchDateField");
        var date = dateField.get("v.value");
        component.set("v.searchDate", date);
        helper.getRecords(component, event);
    },
    
    sortByName: function(component, event, helper) {
        helper.sortBy(component, "Name");
    },
    
    sortByLastName: function(component, event, helper) {
        helper.sortBy(component, "Last_Name__c");
    },
    
    sortByFirstName: function(component, event, helper) {
        helper.sortBy(component, "First_Name__c");
    },
    
    sortByBirthdate: function(component, event, helper) {
        helper.sortBy(component, "Birthdate__c");
    },
    
    sortByStatus: function(component, event, helper) {
        helper.sortBy(component, "Status__c");
    },
    
    renderPage: function(component, event, helper) {
        helper.renderPage(component);
    },   
})