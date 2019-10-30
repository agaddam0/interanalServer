({
    doInit : function(component, event, helper) {
        helper.getObjectFields(component, event);
        component.set('v.lineItemFieldSetCustomAttributes', helper.customFieldSetCustomAttributes);
    },    
    
    toggleAccordion : function(component, event, helper) {
        
        var accordionItem = event.currentTarget;
        var controlId = accordionItem.getAttribute("aria-controls");
        var sectionItem = document.getElementById(controlId);
        
        $A.util.toggleClass(sectionItem, 'slds-is-open');
    },
    
    backToSearchResults : function(component, event, helper) {
		helper.fireShoppingCartNavigationEvent('SearchResultsView');
	},
	
	backToPreenrollmentMarketing : function(component, event, helper) {
	    helper.fireShoppingCartNavigationEvent('PreenrollmentView', 'ChooseMaterials');
	},
    
    checkout : function(component, event, helper) {
        helper.saveCart(component, event);
    },
    
    removeFromCart : function(component, event, helper) {
        helper.removeLineItem(component, event);
    },
    
    duplicateLineItemInCart : function(component, event, helper) {
        helper.duplicateItem(component, event);
    },
    
    saveCartOnNavAway : function(component, event, helper) {
        helper.saveCartOnExit(component, event);
    },
    
    goToDetails : function(component, event, helper) {
        var materialId = event.currentTarget.getAttribute('data-recId');
        var material;
        var lineItems = component.get("v.LineItems");
        
        for(var i = 0; i < lineItems.length; i++)
        {
            if(lineItems[i].Record.Marketing_Material__r.Id == materialId)
            {
                material = lineItems[i].MarketingMaterial;
                break;
            }
                
        }
        
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "MaterialDetailsView",
            "MarketingMaterial" : material,
            "ReturnLocation": "CartReviewView"
        });
        newEvent.fire();
        
    },
    
    showHideAdditionalFieldSets : function(component, event, helper) {
        var sourceCmp = event.getSource();
        var sourceCmpId = sourceCmp.getLocalId();

        // When someone changes the OnBehalfOf, the strike change event would fire
        // and the updating of line items would cause the changed OnBehalfOf to revert
        // to its previous value.
        if (sourceCmpId != 'OnBehalfOf') {
            helper.updateLineItems(component, event);
        }
    },
    
    updateFavoriteInShoppingCart : function(component, event, helper) {
        // When a favorite gets updated, update the state in the cart as well
        // If you don't then it gives weird behaviour when you navigate from
        // the Cart to the Marketing Material
        
        var materialId = event.getParam("materialId");
        var isFavorite = event.getParam("isFavorite");
        helper.updateLineItemsInCart(component, materialId, isFavorite);
    }
    
})