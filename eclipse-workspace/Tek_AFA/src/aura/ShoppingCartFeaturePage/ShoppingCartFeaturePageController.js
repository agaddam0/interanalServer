({
	doInit : function(component, event, helper) {
		helper.loadFeaturedItems(component, event);
	},
    
    removeImageContextMenu : function(component, event, helper)
    {
        if(!component.get("v.isDoneRendering")) {
            component.set("v.isDoneRendering", true);
            var images = document.getElementsByClassName('featureImage');
            for(var i = 0; i < images.length; i++)
            {
                images[i].addEventListener('contextmenu', event => event.preventDefault());
            }
        }
    },
    
    onFeaturedItemClick : function(component, event, helper) {
        var materialId = event.currentTarget.getAttribute('data-recId');
        var material;
        var featuredItems = component.get("v.featuredItems");
        
        for(let featuredItem of featuredItems)
        {
            if(featuredItem.Record.Id == materialId)
            {
                material = featuredItem;
                break;
            }
        }
        
        var newEvent = $A.get("e.c:ShoppingCartNavigationEvent");
        newEvent.setParams({
            "navigate" : "MaterialDetailsView",
            "MarketingMaterial" : material,
            "ReturnLocation": "HomePageView"
        });
        newEvent.fire();
    },
    
    onCarouselIndicatorClick : function(component, event, helper) {
    	var currentIndicator = event.currentTarget;
    	var index = currentIndicator.getAttribute('data-item-num');
    	
    	helper.navigateToCarouselItem(component, index);
    },
    
    navToNextItem : function(component, event, helper) {
    	var featuredItems = component.get('v.featuredItems');
    	var currentIndex = helper.getCurrentFeaturedItem(featuredItems);
    	
    	var start = 0;
    	var end = featuredItems.length - 1;
    	var nextIndex = currentIndex + 1;
    	
    	if (nextIndex > end) {
    		nextIndex = start;
    	}
    	
    	helper.navigateToCarouselItem(component, nextIndex);
    },
    
    navToPreviousItem : function(component, event, helper) {
    	var featuredItems = component.get('v.featuredItems');
    	var currentIndex = helper.getCurrentFeaturedItem(featuredItems);
    	
    	var start = 0;
    	var end = featuredItems.length - 1;
    	var nextIndex = currentIndex - 1;
    	
    	if (nextIndex < start) {
    		nextIndex = end;
    	}
    	
    	helper.navigateToCarouselItem(component, nextIndex);
    },
    
    addToCart: function(component, event, helper) {
        helper.addMaterialToCart(component, event);
    },
    
    toggleFavorite : function(component, event, helper) {
        helper.updateFavorite(component, event);
    },
})