({
	doInit : function(component, event, helper) {
		helper.retrieveTags(component, event);
	},
    
    toggleAccordion : function(component, event, helper) {
        
        var accordionItem = event.currentTarget;
        var controlId = accordionItem.getAttribute("aria-controls");
        var sectionItem = document.getElementById(controlId);
        
        $A.util.toggleClass(sectionItem, 'slds-is-open');
    },
    
    selectAllCheckboxes : function(component, event, helper) {
        helper.selectAll(component, event);
    },
    
    clearAllCheckboxes : function(component, event, helper) {
        helper.clearAll(component, event, true);
    },
    
    expandAllSections : function(component, event, helper) {
        helper.expandAll(component, event);
    },
    
    collapseAllSections : function(component, event, helper) {
        helper.collapseAll(component, event);
    },
    
    filterResultsByKeyword : function(component, event, helper) {
        var keyword = event.getSource().get('v.value');
        component.set("v.keyword", keyword);
        helper.sendSearchParameters(component, event, true);
    },
    
    filterResultsByTag : function(component, event, helper) {
        helper.getCheckedTags(component, event, true); 
    },
    
    clearSearchTerms : function(component, event, helper) {
        if(event.getParam("navigate") == "HomePageView") {
            // Don't fire the "Show Search Results" navigation event because it sometimes causes
            // the Home page to not show depending on whether this event is handled first or not
            // which is controlled by the Lightning framework.
            helper.clearAll(component, event, false);
            helper.expandAll(component, event);
            component.set("v.keyword", '');
        }
    },
    
    checkTagFromEvent : function(component, event, helper) {
        var eventTag = event.getParam("TagClicked");
        var checkboxes = component.find("tagChecks");
        var matchFound = false;
        
        for(var c = 0; c < checkboxes.length; c++)
        {
            var elem = checkboxes[c].getElement();
            if(elem.name == eventTag)
            {
                elem.checked = true;
                matchFound = true;
                break;
            }
        }
        
        // if no match was found, add the tag to the selected tags list
        if(!matchFound) {
            var clickedTags = component.get('v.clickedTagsFromResults');
            clickedTags.push(eventTag);
            component.set('v.clickedTagsFromResults', clickedTags);
        }
        
        helper.getCheckedTags(component, event, true); 
    }
})