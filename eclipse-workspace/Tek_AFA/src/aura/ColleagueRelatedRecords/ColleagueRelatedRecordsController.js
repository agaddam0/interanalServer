({
	doInit : function(component, event, helper) {
		var action = component.get("c.ColleagueRelatedRecords");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") 
            {
            	component.set("v.colleagues", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);
        
        component.find("searchType").set('v.options', [{label: 'Loading record types...'}]);
        
        var getRecordTypes = component.get("c.availableRecordTypes");
        getRecordTypes.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS")
            {
                var rTypes = response.getReturnValue();
                var newSelectOpts = [];
                newSelectOpts.push({class: 'optionClass', label: 'Select Record Type', value: '', selected: true });
                for (var i = 0; i < rTypes.length; i++) 
                { 
                    newSelectOpts.push({class: 'optionClass', label: rTypes[i], value: rTypes[i] });
                }
                
                component.find('searchType').set('v.options', newSelectOpts);
            }
        });
        $A.enqueueAction(getRecordTypes);
	},
    
    goToRecord : function(component, event, handler) {
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        var selectedId = event.currentTarget.getAttribute("data-recId");
        sObjectEvent.setParams({
            "recordId" : selectedId
        });
        sObjectEvent.fire();
    },
    
    updateSearchByName : function (component, event, handler) {
        var action = component.get("c.ColleaguesBySearchName");
        var searchTerm = component.find("searchTerm").get("v.value");
        action.setParams({
            "keyword" : searchTerm
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") 
            {
            	component.set("v.colleagues", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);
    },
    
    updateSearchByRecordType : function (component, event, handler) {
        var action = component.get("c.ColleaguesByRecordType");
        var searchTerm = component.find("searchType").get("v.value");
        action.setParams({
            "searchType" : searchTerm
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") 
            {
            	component.set("v.colleagues", response.getReturnValue());
            }            
        });
        $A.enqueueAction(action);
    }
})