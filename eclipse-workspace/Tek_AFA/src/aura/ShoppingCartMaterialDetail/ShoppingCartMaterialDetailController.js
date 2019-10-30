({
	loadRecord : function(component, event, helper) {
		if(event.getParam("navigate") == "MaterialDetailsView")
        {
            var material = event.getParam("MarketingMaterial");
            component.set("v.material", material);
            component.set("v.quantity", material.Record.Quantity_Minimum__c);
            
            var returnLocation = event.getParam("ReturnLocation");
            component.set('v.returnLocation', returnLocation);
            window.scrollTo(0, 0);
        }
	},
    
    addToCart : function(component, event, helper) {
        helper.addMaterialToCart(component, event);
    },
    
    backToSearchResults : function(component, event, helper) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "SearchResultsView"
        });
        newEvent.fire();
    },
    
    backToCatalogHome : function(component, event, helper) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "HomePageView"
        });
        newEvent.fire();
    },
    
    backToCart : function(component, event, helper) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "CartReviewView"
        });
        newEvent.fire();
    },
    
    backToHistory : function(component, event, helper) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "OrderHistoryView"
        });
        newEvent.fire();
    },
    
    backToFavorites : function(component, event, helper) {
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "FavoritesView"
        });
        newEvent.fire();
    },
    
    toggleFavorite : function(component, event, helper) {
        helper.updateFavorite(component, event);
    },
    
    removeImageContextMenu : function(component, event, helper)
    {
        if(!component.get("v.isDoneRendering")) {
            component.set("v.isDoneRendering", true);
            var images = document.getElementsByClassName('af-image');
            for(var i = 0; i < images.length; i++)
            {
                images[i].addEventListener('contextmenu', event => event.preventDefault());
            }
        }
    },
    
    openModal : function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    
    closeModal : function(component, event, helper) {
        component.set("v.isOpen" , false);
    },
    
})