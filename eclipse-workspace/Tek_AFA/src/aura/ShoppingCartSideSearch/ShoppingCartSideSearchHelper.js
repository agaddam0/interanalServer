({
	retrieveTags : function(component, event) {
		var action = component.get("c.getTagCategories");
        
        action.setCallback(this, function(result){
            var state = result.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.TagCategories", result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    selectAll : function(component, event) {
        var checkboxes = component.find("tagChecks");
        for(var c = 0; c < checkboxes.length; c++)
        {
            var elem = checkboxes[c].getElement();
            elem.checked = true;
        }
        
        this.expandAll(component, event);
        this.getCheckedTags(component, event, true);
    },
    
    clearAll : function(component, event, fireNavigationEvent) {
        var checkboxes = component.find("tagChecks");
        if(checkboxes) {
            for(var c = 0; c < checkboxes.length; c++)
            {
                var elem = checkboxes[c].getElement();
                elem.checked = false;
            }
            component.set('v.clickedTagsFromResults', []);
            this.getCheckedTags(component, event, fireNavigationEvent);
        }
    },
    
    expandAll : function(component, event) {
        var sections = component.find("sectionHeader");
        if(sections) {
            for(var s = 0; s < sections.length; s++)
            {
                var elem = sections[s].getElement();
                var isOpen = $A.util.hasClass(elem, 'slds-is-open');
                if(!isOpen)
                    $A.util.addClass(elem, 'slds-is-open');
            }
        }        
    },
    
    collapseAll : function(component, event) {
        var sections = component.find("sectionHeader");
        
        for(var s = 0; s < sections.length; s++)
        {
            var elem = sections[s].getElement();
            var isOpen = $A.util.hasClass(elem, 'slds-is-open');
            if(isOpen)
                $A.util.removeClass(elem, 'slds-is-open');
        }
    }, 
    
    sendSearchParameters : function(component, event, fireNavigationEvent) {
        var Tags = [];
        var clickedTags = component.get('v.clickedTagsFromResults');
        var selectedTags = component.get('v.selectedTags');
        Tags = selectedTags.concat(clickedTags);
        
        // send search terms to Search Results Component
        var newEvent = $A.get("e.c:ShoppingCartSearchTermsEvent");
        newEvent.setParams({
            "keywords" : component.get("v.keyword"),
            "selectedTags" : Tags
        });
        newEvent.fire();
        
        if (fireNavigationEvent) {
            // Send navigation to Main component to show Results Pane
            var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
            newEvent.setParams({
                "navigate" : 'SearchResultsView'
            });
            newEvent.fire();
        }
    },
    
    getCheckedTags : function(component, event, fireNavigationEvent) {    
        var checkboxes = component.find("tagChecks");
        var checkedArray = [];
        for(var c = 0; c < checkboxes.length; c++)
        {
            var elem = checkboxes[c].getElement();
            if(elem.checked)
            {
                checkedArray.push(elem.name);
            }
        }
        
        component.set("v.selectedTags" , checkedArray);
        
        this.sendSearchParameters(component, event, fireNavigationEvent);
    }
})